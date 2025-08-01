<cfparam name="form.credential" default="">
<cfparam name="url.code" default="">

<cftry>
    <!--- Handle Google Sign-In response --->
    <cfif len(form.credential)>
        <!--- This is from the Google Sign-In button (JWT token) --->
        <!--- In production, you should verify this JWT token --->
        <!--- For now, we'll decode it to get user info --->
        
        <cfset jwt = form.credential>
        <cfset parts = listToArray(jwt, ".")>
        
        <cfif arrayLen(parts) GTE 2>
            <!--- Decode the payload (second part) --->
            <cfset payload = parts[2]>
            <!--- Add padding if needed --->
            <cfset padding = 4 - (len(payload) mod 4)>
            <cfif padding NEQ 4>
                <cfset payload = payload & repeatString("=", padding)>
            </cfif>
            
            <cfset decodedPayload = toString(binaryDecode(payload, "base64"))>
            <cfset userInfo = deserializeJSON(decodedPayload)>
            
            <!--- Extract user information --->
            <cfset googleId = userInfo.sub>
            <cfset email = userInfo.email>
            <cfset name = userInfo.name>
            <cfset picture = structKeyExists(userInfo, "picture") ? userInfo.picture : "">
            
            <!--- Create database component --->
            <cfset db = createObject("component", "clitools.app.wwwroot.intake.components.Database")>
            
            <!--- Check if user exists --->
            <cfset qUser = db.getUserByGoogleId(googleId)>
            
            <cfif qUser.recordCount EQ 0>
                <!--- Create new user --->
                <cfset userId = db.createUser(googleId, email, name, picture)>
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
            
            <!--- Redirect to appropriate dashboard --->
            <cfif listFindNoCase(arrayToList(application.adminEmails), qUser.email)>
                <cflocation url="#application.basePath#/admin/" addtoken="false">
            <cfelse>
                <cflocation url="#application.basePath#/dashboard.cfm" addtoken="false">
            </cfif>
        <cfelse>
            <cfthrow message="Invalid JWT token format">
        </cfif>
    <cfelse>
        <!--- Handle traditional OAuth flow if needed --->
        <cfthrow message="OAuth code handling not implemented">
    </cfif>
    
    <cfcatch>
        <cflocation url="#application.basePath#/login.cfm?error=#urlEncodedFormat(cfcatch.message)#" addtoken="false">
    </cfcatch>
</cftry>