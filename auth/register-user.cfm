<cfparam name="form.firstName" default="">
<cfparam name="form.lastName" default="">
<cfparam name="form.email" default="">
<cfparam name="form.username" default="">
<cfparam name="form.password" default="">
<cfparam name="form.confirmPassword" default="">
<cfparam name="form.terms" default="">

<cftry>
    <!--- Validate input --->
    <cfif NOT len(trim(form.firstName)) OR NOT len(trim(form.lastName)) OR 
          NOT len(trim(form.email)) OR NOT len(trim(form.username)) OR 
          NOT len(trim(form.password))>
        <cfthrow message="Please fill in all required fields">
    </cfif>
    
    <!--- Check password match --->
    <cfif form.password NEQ form.confirmPassword>
        <cfthrow message="Passwords do not match">
    </cfif>
    
    <!--- Check password strength --->
    <cfif len(form.password) LT 8>
        <cfthrow message="Password must be at least 8 characters long">
    </cfif>
    
    <!--- Check if terms accepted --->
    <cfif form.terms NEQ "on">
        <cfthrow message="You must accept the terms and conditions">
    </cfif>
    
    <!--- Hash the password --->
    <cfset hashedPassword = hash(form.password, "SHA-256")>
    
    <!--- Create database component --->
    <cfset db = createObject("component", "intake.components.Database")>
    
    <!--- Check if username already exists --->
    <cfquery name="qCheckUsername" datasource="clitools">
        SELECT user_id FROM Users 
        WHERE username = <cfqueryparam value="#form.username#" cfsqltype="cf_sql_varchar">
    </cfquery>
    
    <cfif qCheckUsername.recordCount GT 0>
        <cfthrow message="Username already exists. Please choose another.">
    </cfif>
    
    <!--- Check if email already exists --->
    <cfquery name="qCheckEmail" datasource="clitools">
        SELECT user_id FROM Users 
        WHERE email = <cfqueryparam value="#form.email#" cfsqltype="cf_sql_varchar">
    </cfquery>
    
    <cfif qCheckEmail.recordCount GT 0>
        <cfthrow message="Email already registered. Please use another email or sign in.">
    </cfif>
    
    <!--- Create user with username/password --->
    <cfquery name="qInsertUser" datasource="clitools" result="newUser">
        INSERT INTO Users (
            google_id, 
            email, 
            display_name, 
            username,
            password_hash,
            profile_picture, 
            created_at, 
            last_login
        ) VALUES (
            <cfqueryparam value="user_#createUUID()#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#form.email#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#form.firstName# #form.lastName#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#form.username#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#hashedPassword#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="https://ui-avatars.com/api/?name=#urlEncodedFormat(form.firstName & ' ' & form.lastName)#&background=4285f4&color=fff" cfsqltype="cf_sql_varchar">,
            GETDATE(),
            GETDATE()
        )
    </cfquery>
    
    <!--- Get the newly created user ID --->
    <cfset newUserId = newUser.generatedKey>
    
    <!--- Set up session for automatic login --->
    <cfset session.isLoggedIn = true>
    <cfset session.user = {
        "userId" = newUserId,
        "googleId" = "user_#createUUID()#",
        "email" = form.email,
        "displayName" = form.firstName & " " & form.lastName,
        "profilePicture" = "https://ui-avatars.com/api/?name=#urlEncodedFormat(form.firstName & ' ' & form.lastName)#&background=4285f4&color=fff",
        "isLoggedIn" = true
    }>
    
    <!--- Redirect to dashboard --->
    <cflocation url="#application.basePath#/dashboard.cfm?success=#urlEncodedFormat('Welcome! Your account has been created and you are now logged in.')#" addtoken="false">
    
    <cfcatch>
        <cflocation url="#application.basePath#/register.cfm?error=#urlEncodedFormat(cfcatch.message)#" addtoken="false">
    </cfcatch>
</cftry>