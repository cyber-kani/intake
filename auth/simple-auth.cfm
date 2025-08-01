<cfparam name="form.email" default="">
<cfparam name="form.displayName" default="">

<cftry>
    <!--- Validate input --->
    <cfif NOT len(trim(form.email)) OR NOT len(trim(form.displayName))>
        <cfthrow message="Please provide both email and name">
    </cfif>
    
    <!--- Create a simple Google ID from email --->
    <cfset googleId = "simple_" & hash(form.email)>
    
    <!--- Create database component --->
    <cfset db = createObject("component", "intake.components.Database")>
    
    <!--- Check if user exists --->
    <cfset qUser = db.getUserByGoogleId(googleId)>
    
    <cfif qUser.recordCount EQ 0>
        <!--- Create new user --->
        <cfset userId = db.createUser(
            googleId = googleId,
            email = form.email,
            displayName = form.displayName,
            profilePicture = "https://ui-avatars.com/api/?name=" & urlEncodedFormat(form.displayName) & "&background=4285f4&color=fff"
        )>
        <cfset qUser = db.getUserByGoogleId(googleId)>
    <cfelse>
        <!--- Update last login --->
        <cfset db.updateLastLogin(qUser.user_id)>
    </cfif>
    
    <!--- Set session variables --->
    <cfset session.isLoggedIn = true>
    <cfset session.user = {
        "userId" = qUser.user_id,
        "googleId" = qUser.google_id,
        "email" = qUser.email,
        "displayName" = qUser.display_name,
        "profilePicture" = qUser.profile_picture,
        "isAdmin" = arrayFind(application.adminEmails, qUser.email) GT 0
    }>
    
    <!--- Redirect to dashboard --->
    <cflocation url="#application.basePath#/dashboard.cfm" addtoken="false">
    
    <cfcatch>
        <cflocation url="#application.basePath#/simple-login.cfm?error=#urlEncodedFormat(cfcatch.message)#" addtoken="false">
    </cfcatch>
</cftry>