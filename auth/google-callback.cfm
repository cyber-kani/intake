<cfparam name="form.credential" default="">

<cftry>
    <!--- Validate credential exists --->
    <cfif NOT len(trim(form.credential))>
        <cfthrow message="No credential provided">
    </cfif>
    
    <!--- Decode the JWT token to get user info --->
    <!--- Google ID tokens are JWT tokens with 3 parts separated by dots --->
    <cfset tokenParts = listToArray(form.credential, ".")>
    
    <cfif arrayLen(tokenParts) NEQ 3>
        <cfthrow message="Invalid credential format">
    </cfif>
    
    <!--- Decode the payload (middle part) --->
    <cfset payload = tokenParts[2]>
    
    <!--- Add padding if needed for base64 decoding --->
    <cfset padding = 4 - (len(payload) mod 4)>
    <cfif padding NEQ 4>
        <cfset payload = payload & repeatString("=", padding)>
    </cfif>
    
    <!--- Decode base64 --->
    <cfset decodedPayload = toString(binaryDecode(payload, "base64"))>
    <cfset userInfo = deserializeJSON(decodedPayload)>
    
    <!--- Extract user information --->
    <cfset googleId = userInfo.sub>
    <cfset email = userInfo.email>
    <cfset displayName = userInfo.name>
    <cfset profilePicture = userInfo.picture>
    
    <!--- Create database component --->
    <cfset db = createObject("component", "intake.components.Database")>
    
    <!--- Check if user exists --->
    <cfset qUser = db.getUserByGoogleId(googleId)>
    
    <cfif qUser.recordCount EQ 0>
        <!--- Create new user --->
        <cfset userId = db.createUser(
            googleId = googleId,
            email = email,
            displayName = displayName,
            profilePicture = profilePicture
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
        "isAdmin" = listFindNoCase(arrayToList(application.adminEmails), qUser.email) GT 0,
        "isLoggedIn" = true
    }>
    
    <!--- Redirect to index page --->
    <cflocation url="#application.basePath#/" addtoken="false">
    
    <cfcatch>
        <cflocation url="#application.basePath#/?error=#urlEncodedFormat(cfcatch.message)#" addtoken="false">
    </cfcatch>
</cftry>