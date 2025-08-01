<!--- Fix missing reference IDs for user's forms --->
<cfif NOT structKeyExists(session, "isLoggedIn") OR NOT session.isLoggedIn>
    <cflocation url="#application.basePath#/index.cfm" addtoken="false">
</cfif>

<!DOCTYPE html>
<html>
<head>
    <title>Fix Reference IDs</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<div class="container mt-5">
    <h2>Fix Missing Reference IDs</h2>
    
    <cftry>
        <!--- Get user's forms without reference_id --->
        <cfquery name="qMissing" datasource="clitools">
            SELECT form_id, first_name, last_name, created_at
            FROM IntakeForms
            WHERE user_id = <cfqueryparam value="#session.user.userId#" cfsqltype="cf_sql_integer">
            AND (reference_id IS NULL OR reference_id = '')
        </cfquery>
        
        <cfif qMissing.recordCount GT 0>
            <p>Found <cfoutput>#qMissing.recordCount#</cfoutput> forms without reference IDs. Fixing...</p>
            
            <cfset db = createObject("component", "components.Database")>
            <cfset fixed = 0>
            
            <cfloop query="qMissing">
                <!--- Generate unique reference ID using the same method as Database.cfc --->
                <cfset chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789">
                <cfset refId = "">
                <cfset isUnique = false>
                
                <cfloop condition="NOT isUnique">
                    <cfset refId = "">
                    <cfloop from="1" to="8" index="i">
                        <cfset refId &= mid(chars, randRange(1, len(chars)), 1)>
                    </cfloop>
                    
                    <!--- Check if unique --->
                    <cfquery name="qCheck" datasource="clitools">
                        SELECT COUNT(*) as cnt
                        FROM IntakeForms
                        WHERE reference_id = <cfqueryparam value="#refId#" cfsqltype="cf_sql_varchar">
                    </cfquery>
                    
                    <cfif qCheck.cnt EQ 0>
                        <cfset isUnique = true>
                    </cfif>
                </cfloop>
                
                <!--- Update the form with new reference_id --->
                <cfquery datasource="clitools">
                    UPDATE IntakeForms
                    SET reference_id = <cfqueryparam value="#refId#" cfsqltype="cf_sql_varchar">
                    WHERE form_id = <cfqueryparam value="#qMissing.form_id#" cfsqltype="cf_sql_integer">
                </cfquery>
                
                <cfset fixed++>
                <p class="text-success">✓ Form #<cfoutput>#qMissing.form_id#</cfoutput> now has reference ID: <code><cfoutput>#refId#</cfoutput></code></p>
            </cfloop>
            
            <div class="alert alert-success mt-3">
                Successfully updated <cfoutput>#fixed#</cfoutput> forms with new reference IDs!
            </div>
            
            <a href="<cfoutput>#application.basePath#</cfoutput>/dashboard.cfm" class="btn btn-primary">Go to Dashboard</a>
        <cfelse>
            <div class="alert alert-info">
                All your forms already have reference IDs!
            </div>
            <a href="<cfoutput>#application.basePath#</cfoutput>/dashboard.cfm" class="btn btn-primary">Go to Dashboard</a>
        </cfif>
        
        <cfcatch>
            <div class="alert alert-danger">
                Error: <cfoutput>#cfcatch.message#</cfoutput>
            </div>
        </cfcatch>
    </cftry>
</div>
</body>
</html>