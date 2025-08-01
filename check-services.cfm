<!--- Check application services structure --->
<cfif NOT structKeyExists(session, "user") OR NOT structKeyExists(session.user, "isLoggedIn") OR NOT session.user.isLoggedIn>
    <h1>Please log in first</h1>
    <cfabort>
</cfif>

<!DOCTYPE html>
<html>
<head>
    <title>Check Services Structure</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<div class="container mt-5">
    <h1>Application Services Structure</h1>
    
    <cfif structKeyExists(application, "serviceCategories")>
        <cfloop collection="#application.serviceCategories#" item="catKey">
            <h3><cfoutput>#catKey#</cfoutput></h3>
            <cfset cat = application.serviceCategories[catKey]>
            <p>Name: <cfoutput>#cat.name#</cfoutput></p>
            <p>Services:</p>
            <ul>
                <cfloop collection="#cat.services#" item="serviceKey">
                    <li><cfoutput>#serviceKey# = #cat.services[serviceKey]#</cfoutput></li>
                </cfloop>
            </ul>
            <hr>
        </cfloop>
    <cfelse>
        <div class="alert alert-danger">
            serviceCategories not found in application scope!
        </div>
    </cfif>
    
    <h2>Test Service Type Parsing</h2>
    <cfset testValue = "education_learning_language_learning">
    <p>Testing: <cfoutput>#testValue#</cfoutput></p>
    
    <cfif structKeyExists(application, "serviceCategories")>
        <cfset parts = listToArray(testValue, "_")>
        <p>Parts: <cfoutput>#arrayToList(parts, ", ")#</cfoutput></p>
        
        <cfloop from="1" to="#arrayLen(parts)-1#" index="splitIdx">
            <cfset possibleCategory = arrayToList(arraySlice(parts, 1, splitIdx), "_")>
            <cfset possibleService = arrayToList(arraySlice(parts, splitIdx + 1), "_")>
            
            <p>Try <cfoutput>#splitIdx#</cfoutput>: cat=<cfoutput>#possibleCategory#</cfoutput>, svc=<cfoutput>#possibleService#</cfoutput></p>
            
            <cfif structKeyExists(application.serviceCategories, possibleCategory)>
                <p style="color: green;">✓ Found category!</p>
                <cfset cat = application.serviceCategories[possibleCategory]>
                <p>Available services: <cfoutput>#structKeyList(cat.services)#</cfoutput></p>
                
                <cfif structKeyExists(cat.services, possibleService)>
                    <p style="color: green;">✓ Found service: <cfoutput>#cat.services[possibleService]#</cfoutput></p>
                <cfelse>
                    <p style="color: red;">✗ Service not found</p>
                </cfif>
            <cfelse>
                <p style="color: red;">✗ Category not found</p>
            </cfif>
        </cfloop>
    </cfif>
</div>
</body>
</html>