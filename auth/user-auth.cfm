<cfparam name="form.username" default="">
<cfparam name="form.password" default="">

<cftry>
    <!--- Validate input --->
    <cfif NOT len(trim(form.username)) OR NOT len(trim(form.password))>
        <cfthrow message="Please provide both username and password">
    </cfif>
    
    <!--- Hash the password --->
    <cfset hashedPassword = hash(form.password, "SHA-256")>
    
    <!--- Create database component --->
    <cfset db = createObject("component", "intake.components.Database")>
    
    <!--- Check user credentials --->
    <cfquery name="qUser" datasource="clitools">
        SELECT user_id, google_id, email, display_name, username, profile_picture, created_at
        FROM Users
        WHERE username = <cfqueryparam value="#form.username#" cfsqltype="cf_sql_varchar">
        AND password_hash = <cfqueryparam value="#hashedPassword#" cfsqltype="cf_sql_varchar">
    </cfquery>
    
    <cfif qUser.recordCount EQ 0>
        <cfthrow message="Invalid username or password">
    </cfif>
    
    <!--- Update last login --->
    <cfset db.updateLastLogin(qUser.user_id)>
    
    <!--- Set session variables --->
    <cfset session.isLoggedIn = true>
    <cfset session.user = {
        "userId" = qUser.user_id,
        "googleId" = qUser.google_id,
        "email" = qUser.email,
        "displayName" = qUser.display_name,
        "username" = qUser.username,
        "profilePicture" = qUser.profile_picture,
        "isAdmin" = arrayFind(application.adminEmails, qUser.email) GT 0,
        "isLoggedIn" = true
    }>
    
    <!--- Redirect to index page --->
    <cflocation url="#application.basePath#/" addtoken="false">
    
    <cfcatch>
        <cflocation url="#application.basePath#/?error=#urlEncodedFormat(cfcatch.message)#" addtoken="false">
    </cfcatch>
</cftry>