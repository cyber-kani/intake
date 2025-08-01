<cfsetting showdebugoutput="false">
<cfheader name="Content-Type" value="text/html">

<!--- Security check - only admin access --->
<cfif NOT structKeyExists(session, "user") OR NOT structKeyExists(session.user, "isLoggedIn") OR NOT session.user.isLoggedIn OR NOT listFindNoCase(arrayToList(application.adminEmails), session.user.email)>
    <h1>Access Denied</h1>
    <p>This page is only accessible to administrators.</p>
    <cfabort>
</cfif>

<!DOCTYPE html>
<html>
<head>
    <title>Setup Reference ID Column</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-5">
        <h1>Database Setup - Reference ID Column</h1>
        
        <cftry>
            <!--- Check if column exists --->
            <cfquery name="qCheck" datasource="clitools">
                SELECT COUNT(*) as cnt
                FROM INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_NAME = 'IntakeForms'
                AND COLUMN_NAME = 'reference_id'
            </cfquery>
            
            <cfif qCheck.cnt EQ 0>
                <div class="alert alert-info">Column does not exist. Adding reference_id column...</div>
                
                <!--- Add the column --->
                <cfquery datasource="clitools">
                    ALTER TABLE IntakeForms ADD reference_id VARCHAR(8)
                </cfquery>
                <div class="alert alert-success">✓ Added reference_id column</div>
                
                <!--- Create index --->
                <cfquery datasource="clitools">
                    CREATE INDEX idx_reference_id ON IntakeForms(reference_id)
                </cfquery>
                <div class="alert alert-success">✓ Created index on reference_id</div>
                
                <!--- Update existing records --->
                <cfquery name="qMissing" datasource="clitools">
                    SELECT form_id
                    FROM IntakeForms
                    WHERE reference_id IS NULL OR reference_id = ''
                </cfquery>
                
                <cfif qMissing.recordCount GT 0>
                    <div class="alert alert-info">Updating <cfoutput>#qMissing.recordCount#</cfoutput> existing records...</div>
                    
                    <cfloop query="qMissing">
                        <cfset refId = "">
                        <cfset chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789">
                        <cfloop from="1" to="8" index="i">
                            <cfset refId &= mid(chars, randRange(1, len(chars)), 1)>
                        </cfloop>
                        
                        <cfquery datasource="clitools">
                            UPDATE IntakeForms
                            SET reference_id = <cfqueryparam value="#refId#" cfsqltype="cf_sql_varchar">
                            WHERE form_id = <cfqueryparam value="#qMissing.form_id#" cfsqltype="cf_sql_integer">
                        </cfquery>
                    </cfloop>
                    
                    <div class="alert alert-success">✓ Updated <cfoutput>#qMissing.recordCount#</cfoutput> records with reference IDs</div>
                </cfif>
                
                <div class="alert alert-primary mt-3">
                    <h4>Setup Complete!</h4>
                    <p>The reference_id column has been successfully added to the database.</p>
                </div>
                
            <cfelse>
                <div class="alert alert-warning">
                    <h4>Column Already Exists</h4>
                    <p>The reference_id column already exists in the IntakeForms table.</p>
                </div>
                
                <!--- Check for missing reference IDs --->
                <cfquery name="qMissing" datasource="clitools">
                    SELECT form_id
                    FROM IntakeForms
                    WHERE reference_id IS NULL OR reference_id = ''
                </cfquery>
                
                <cfif qMissing.recordCount GT 0>
                    <div class="alert alert-info">Found <cfoutput>#qMissing.recordCount#</cfoutput> records without reference IDs. Updating...</div>
                    
                    <cfloop query="qMissing">
                        <cfset refId = "">
                        <cfset chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789">
                        <cfloop from="1" to="8" index="i">
                            <cfset refId &= mid(chars, randRange(1, len(chars)), 1)>
                        </cfloop>
                        
                        <cfquery datasource="clitools">
                            UPDATE IntakeForms
                            SET reference_id = <cfqueryparam value="#refId#" cfsqltype="cf_sql_varchar">
                            WHERE form_id = <cfqueryparam value="#qMissing.form_id#" cfsqltype="cf_sql_integer">
                        </cfquery>
                    </cfloop>
                    
                    <div class="alert alert-success">✓ Updated <cfoutput>#qMissing.recordCount#</cfoutput> records with reference IDs</div>
                </cfif>
            </cfif>
            
            <!--- Show current forms with reference IDs --->
            <h3 class="mt-4">Current Forms</h3>
            <cfquery name="qForms" datasource="clitools">
                SELECT TOP 10 form_id, reference_id, first_name, last_name, created_at
                FROM IntakeForms
                ORDER BY created_at DESC
            </cfquery>
            
            <table class="table table-striped">
                <thead>
                    <tr>
                        <th>Form ID</th>
                        <th>Reference ID</th>
                        <th>Customer Name</th>
                        <th>Created</th>
                    </tr>
                </thead>
                <tbody>
                    <cfloop query="qForms">
                        <tr>
                            <td><cfoutput>#form_id#</cfoutput></td>
                            <td><code><cfoutput>#reference_id#</cfoutput></code></td>
                            <td><cfoutput>#first_name# #last_name#</cfoutput></td>
                            <td><cfoutput>#dateFormat(created_at, "mm/dd/yyyy")# #timeFormat(created_at, "hh:mm tt")#</cfoutput></td>
                        </tr>
                    </cfloop>
                </tbody>
            </table>
            
            <cfcatch>
                <div class="alert alert-danger">
                    <h4>Error Occurred</h4>
                    <p><cfoutput>#cfcatch.message#</cfoutput></p>
                    <cfif structKeyExists(cfcatch, "detail")>
                        <p><small><cfoutput>#cfcatch.detail#</cfoutput></small></p>
                    </cfif>
                </div>
            </cfcatch>
        </cftry>
        
        <div class="mt-4">
            <a href="<cfoutput>#application.basePath#</cfoutput>/admin/" class="btn btn-primary">Back to Admin Dashboard</a>
        </div>
    </div>
</body>
</html>