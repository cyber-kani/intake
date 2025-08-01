<!--- Direct SQL execution page - REMOVE AFTER USE --->
<cfif NOT structKeyExists(session, "user") OR NOT structKeyExists(session.user, "isLoggedIn") OR NOT session.user.isLoggedIn OR NOT listFindNoCase(arrayToList(application.adminEmails), session.user.email)>
    <h1>Access Denied</h1>
    <cfabort>
</cfif>

<!DOCTYPE html>
<html>
<head>
    <title>Execute SQL - Add Reference ID</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<div class="container mt-5">
    <h1>Add Reference ID Column</h1>
    
    <cfif structKeyExists(form, "execute")>
        <cftry>
            <!--- Step 1: Add column --->
            <cfquery datasource="clitools">
                ALTER TABLE IntakeForms ADD reference_id VARCHAR(8)
            </cfquery>
            <div class="alert alert-success">✓ Added reference_id column</div>
            
            <!--- Step 2: Create index --->
            <cfquery datasource="clitools">
                CREATE INDEX idx_reference_id ON IntakeForms(reference_id)
            </cfquery>
            <div class="alert alert-success">✓ Created index</div>
            
            <!--- Step 3: Generate reference IDs for existing records --->
            <cfquery name="qForms" datasource="clitools">
                SELECT form_id FROM IntakeForms WHERE reference_id IS NULL
            </cfquery>
            
            <cfloop query="qForms">
                <cfset refId = "">
                <cfset chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789">
                <cfloop from="1" to="8" index="i">
                    <cfset refId &= mid(chars, randRange(1, len(chars)), 1)>
                </cfloop>
                
                <!--- Make sure it's unique --->
                <cfquery name="qCheck" datasource="clitools">
                    SELECT COUNT(*) as cnt FROM IntakeForms WHERE reference_id = <cfqueryparam value="#refId#" cfsqltype="cf_sql_varchar">
                </cfquery>
                
                <cfloop condition="qCheck.cnt GT 0">
                    <cfset refId = "">
                    <cfloop from="1" to="8" index="i">
                        <cfset refId &= mid(chars, randRange(1, len(chars)), 1)>
                    </cfloop>
                    <cfquery name="qCheck" datasource="clitools">
                        SELECT COUNT(*) as cnt FROM IntakeForms WHERE reference_id = <cfqueryparam value="#refId#" cfsqltype="cf_sql_varchar">
                    </cfquery>
                </cfloop>
                
                <cfquery datasource="clitools">
                    UPDATE IntakeForms 
                    SET reference_id = <cfqueryparam value="#refId#" cfsqltype="cf_sql_varchar">
                    WHERE form_id = <cfqueryparam value="#qForms.form_id#" cfsqltype="cf_sql_integer">
                </cfquery>
            </cfloop>
            
            <div class="alert alert-success">✓ Generated reference IDs for <cfoutput>#qForms.recordCount#</cfoutput> existing records</div>
            
            <h3 class="mt-4">Success!</h3>
            <p>The reference_id column has been added and populated. You can now use 8-character reference IDs instead of numeric IDs.</p>
            
            <cfcatch>
                <cfif findNoCase("already exists", cfcatch.message)>
                    <div class="alert alert-warning">
                        The reference_id column already exists. Checking for missing reference IDs...
                    </div>
                    
                    <!--- Update any missing reference IDs --->
                    <cfquery name="qMissing" datasource="clitools">
                        SELECT form_id FROM IntakeForms WHERE reference_id IS NULL OR reference_id = ''
                    </cfquery>
                    
                    <cfif qMissing.recordCount GT 0>
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
                    <cfelse>
                        <div class="alert alert-info">All records already have reference IDs</div>
                    </cfif>
                <cfelse>
                    <div class="alert alert-danger">
                        <h5>Error:</h5>
                        <cfoutput>#cfcatch.message#</cfoutput>
                        <cfif structKeyExists(cfcatch, "detail")>
                            <br><small><cfoutput>#cfcatch.detail#</cfoutput></small>
                        </cfif>
                    </div>
                </cfif>
            </cfcatch>
        </cftry>
    <cfelse>
        <form method="post">
            <p>This will add the reference_id column to the IntakeForms table and generate unique 8-character IDs for all existing forms.</p>
            <button type="submit" name="execute" value="1" class="btn btn-primary">Execute SQL</button>
            <a href="<cfoutput>#application.basePath#</cfoutput>/admin/" class="btn btn-secondary">Cancel</a>
        </form>
    </cfif>
    
    <hr class="mt-4">
    <h4>Sample Forms with Reference IDs</h4>
    <cfquery name="qSample" datasource="clitools">
        SELECT TOP 5 form_id, reference_id, first_name, last_name, created_at
        FROM IntakeForms
        ORDER BY created_at DESC
    </cfquery>
    
    <table class="table table-striped">
        <thead>
            <tr>
                <th>Form ID</th>
                <th>Reference ID</th>
                <th>Customer</th>
                <th>Created</th>
            </tr>
        </thead>
        <tbody>
            <cfloop query="qSample">
                <tr>
                    <td><cfoutput>#form_id#</cfoutput></td>
                    <td><code><cfoutput>#reference_id ?: "NULL"#</cfoutput></code></td>
                    <td><cfoutput>#first_name# #last_name#</cfoutput></td>
                    <td><cfoutput>#dateFormat(created_at, "mm/dd/yyyy")#</cfoutput></td>
                </tr>
            </cfloop>
        </tbody>
    </table>
</div>
</body>
</html>