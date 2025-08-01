<!--- Clear session --->
<cfset structClear(session)>
<cfset session.isLoggedIn = false>
<cfset session.user = {}>

<!--- Redirect to home page --->
<cflocation url="#application.basePath#/" addtoken="false">