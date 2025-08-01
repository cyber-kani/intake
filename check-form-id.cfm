<!--- Check form reference ID --->
<cfif NOT structKeyExists(session, "isLoggedIn") OR NOT session.isLoggedIn>
    <cflocation url="#application.basePath#/index.cfm" addtoken="false">
</cfif>

<cfparam name="url.id" default="">

<!DOCTYPE html>
<html>
<head>
    <title>Check Form Reference ID</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<div class="container mt-5">
    <h2>Check Form Reference ID</h2>
    
    <cfif len(url.id)>
        <cfquery name="qCheck" datasource="clitools">
            SELECT form_id, reference_id, user_id, first_name, last_name, created_at
            FROM IntakeForms
            WHERE form_id = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_integer">
        </cfquery>
        
        <cfif qCheck.recordCount GT 0>
            <div class="card">
                <div class="card-body">
                    <h5>Form Details:</h5>
                    <table class="table">
                        <tr>
                            <th>Form ID:</th>
                            <td><cfoutput>#qCheck.form_id#</cfoutput></td>
                        </tr>
                        <tr>
                            <th>Reference ID:</th>
                            <td>
                                <cfif len(qCheck.reference_id)>
                                    <code class="text-success"><cfoutput>#qCheck.reference_id#</cfoutput></code>
                                <cfelse>
                                    <span class="text-danger">MISSING</span>
                                </cfif>
                            </td>
                        </tr>
                        <tr>
                            <th>User ID:</th>
                            <td><cfoutput>#qCheck.user_id#</cfoutput></td>
                        </tr>
                        <tr>
                            <th>Name:</th>
                            <td><cfoutput>#qCheck.first_name# #qCheck.last_name#</cfoutput></td>
                        </tr>
                        <tr>
                            <th>Created:</th>
                            <td><cfoutput>#dateTimeFormat(qCheck.created_at, "mm/dd/yyyy hh:nn tt")#</cfoutput></td>
                        </tr>
                    </table>
                    
                    <cfif NOT len(qCheck.reference_id) AND qCheck.user_id EQ session.user.userId>
                        <hr>
                        <h5>Generate Reference ID</h5>
                        <p>This form doesn't have a reference ID. Click below to generate one:</p>
                        
                        <form method="post">
                            <input type="hidden" name="form_id" value="<cfoutput>#qCheck.form_id#</cfoutput>">
                            <button type="submit" name="generate" class="btn btn-primary">Generate Reference ID</button>
                        </form>
                        
                        <cfif structKeyExists(form, "generate")>
                            <!--- Generate reference ID --->
                            <cfset chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789">
                            <cfset refId = "">
                            <cfset isUnique = false>
                            
                            <cfloop condition="NOT isUnique">
                                <cfset refId = "">
                                <cfloop from="1" to="8" index="i">
                                    <cfset refId &= mid(chars, randRange(1, len(chars)), 1)>
                                </cfloop>
                                
                                <cfquery name="qCheckRef" datasource="clitools">
                                    SELECT COUNT(*) as cnt
                                    FROM IntakeForms
                                    WHERE reference_id = <cfqueryparam value="#refId#" cfsqltype="cf_sql_varchar">
                                </cfquery>
                                
                                <cfif qCheckRef.cnt EQ 0>
                                    <cfset isUnique = true>
                                </cfif>
                            </cfloop>
                            
                            <cfquery datasource="clitools">
                                UPDATE IntakeForms
                                SET reference_id = <cfqueryparam value="#refId#" cfsqltype="cf_sql_varchar">
                                WHERE form_id = <cfqueryparam value="#form.form_id#" cfsqltype="cf_sql_integer">
                            </cfquery>
                            
                            <div class="alert alert-success mt-3">
                                Generated Reference ID: <code><cfoutput>#refId#</cfoutput></code>
                            </div>
                            
                            <a href="<cfoutput>#application.basePath#</cfoutput>/form-view.cfm?id=<cfoutput>#refId#</cfoutput>" class="btn btn-success">View Form with Reference ID</a>
                        </cfif>
                    </cfif>
                </div>
            </div>
        <cfelse>
            <div class="alert alert-warning">Form not found.</div>
        </cfif>
    <cfelse>
        <form method="get" class="row g-3">
            <div class="col-auto">
                <label class="col-form-label">Enter Form ID:</label>
            </div>
            <div class="col-auto">
                <input type="number" name="id" class="form-control" placeholder="e.g., 23">
            </div>
            <div class="col-auto">
                <button type="submit" class="btn btn-primary">Check</button>
            </div>
        </form>
    </cfif>
    
    <hr>
    <a href="<cfoutput>#application.basePath#</cfoutput>/dashboard.cfm" class="btn btn-secondary">Back to Dashboard</a>
</div>
</body>
</html>