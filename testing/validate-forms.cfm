<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Form Data Validation Checker</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        .test-pass { color: green; font-weight: bold; }
        .test-fail { color: red; font-weight: bold; }
        .test-warning { color: orange; font-weight: bold; }
        .form-details { background-color: #f8f9fa; padding: 15px; border-radius: 5px; margin: 10px 0; }
        .json-display { background-color: #282c34; color: #abb2bf; padding: 10px; border-radius: 5px; font-family: monospace; font-size: 12px; max-height: 300px; overflow-y: auto; }
    </style>
</head>
<body>
<div class="container mt-5">
    <h1 class="mb-4">Form Data Validation Checker</h1>
    
    <!--- Get all forms from database --->
    <cftry>
        <cfquery name="qAllForms" datasource="clitools">
            SELECT 
                f.form_id,
                f.user_id,
                f.reference_id,
                f.form_code,
                f.project_type,
                f.service_type,
                f.first_name,
                f.last_name,
                f.email,
                f.phone_number,
                f.company_name,
                f.form_data,
                f.is_finalized,
                f.created_at,
                f.submitted_at,
                u.email as user_email,
                u.display_name
            FROM IntakeForms f
            INNER JOIN Users u ON f.user_id = u.user_id
            ORDER BY f.created_at DESC
        </cfquery>
        
        <div class="alert alert-info">
            <i class="fas fa-info-circle"></i> Found <strong><cfoutput>#qAllForms.recordCount#</cfoutput></strong> forms in the database
        </div>
        
        <cfif qAllForms.recordCount GT 0>
            <cfset validForms = 0>
            <cfset invalidForms = 0>
            <cfset formIssues = []>
            
            <cfloop query="qAllForms">
                <cfset issues = []>
                <cfset isValid = true>
                
                <div class="card mb-3">
                    <div class="card-header">
                        <h5 class="mb-0">
                            Form #<cfoutput>#qAllForms.form_id#</cfoutput>
                            <cfif len(qAllForms.reference_id)>
                                <span class="badge bg-primary">Ref: <cfoutput>#qAllForms.reference_id#</cfoutput></span>
                            </cfif>
                            <cfif qAllForms.is_finalized>
                                <span class="badge bg-success">Finalized</span>
                            <cfelse>
                                <span class="badge bg-warning">Draft</span>
                            </cfif>
                        </h5>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-6">
                                <h6>Basic Information:</h6>
                                <ul class="list-unstyled">
                                    <!--- Check User ID --->
                                    <li>
                                        <cfif qAllForms.user_id GT 0>
                                            <span class="test-pass">✓</span> User ID: <cfoutput>#qAllForms.user_id#</cfoutput> (<cfoutput>#qAllForms.user_email#</cfoutput>)
                                        <cfelse>
                                            <span class="test-fail">✗</span> Invalid User ID
                                            <cfset arrayAppend(issues, "Invalid User ID")>
                                            <cfset isValid = false>
                                        </cfif>
                                    </li>
                                    
                                    <!--- Check Reference ID uniqueness --->
                                    <li>
                                        <cfif len(qAllForms.reference_id)>
                                            <cfquery name="qRefCount" datasource="clitools">
                                                SELECT COUNT(*) as cnt
                                                FROM IntakeForms
                                                WHERE reference_id = <cfqueryparam value="#qAllForms.reference_id#" cfsqltype="cf_sql_varchar">
                                            </cfquery>
                                            <cfif qRefCount.cnt EQ 1>
                                                <span class="test-pass">✓</span> Reference ID is unique
                                            <cfelse>
                                                <span class="test-fail">✗</span> Duplicate Reference ID found (<cfoutput>#qRefCount.cnt#</cfoutput> occurrences)
                                                <cfset arrayAppend(issues, "Duplicate Reference ID")>
                                                <cfset isValid = false>
                                            </cfif>
                                        <cfelse>
                                            <span class="test-warning">⚠</span> No Reference ID
                                            <cfset arrayAppend(issues, "Missing Reference ID")>
                                        </cfif>
                                    </li>
                                    
                                    <!--- Check Name Fields --->
                                    <li>
                                        <cfif len(qAllForms.first_name) OR len(qAllForms.last_name)>
                                            <span class="test-pass">✓</span> Name: <cfoutput>#qAllForms.first_name# #qAllForms.last_name#</cfoutput>
                                        <cfelse>
                                            <span class="test-warning">⚠</span> Name fields empty
                                        </cfif>
                                    </li>
                                    
                                    <!--- Check Email --->
                                    <li>
                                        <cfif len(qAllForms.email) AND isValid("email", qAllForms.email)>
                                            <span class="test-pass">✓</span> Valid email: <cfoutput>#qAllForms.email#</cfoutput>
                                        <cfelseif len(qAllForms.email)>
                                            <span class="test-fail">✗</span> Invalid email format: <cfoutput>#qAllForms.email#</cfoutput>
                                            <cfset arrayAppend(issues, "Invalid email format")>
                                            <cfset isValid = false>
                                        <cfelse>
                                            <span class="test-warning">⚠</span> No email provided
                                        </cfif>
                                    </li>
                                    
                                    <!--- Check Service Type --->
                                    <li>
                                        <cfif len(qAllForms.service_type)>
                                            <span class="test-pass">✓</span> Service Type: <cfoutput>#qAllForms.service_type#</cfoutput>
                                        <cfelse>
                                            <span class="test-warning">⚠</span> No service type specified
                                        </cfif>
                                    </li>
                                </ul>
                            </div>
                            
                            <div class="col-md-6">
                                <h6>Data Validation:</h6>
                                <ul class="list-unstyled">
                                    <!--- Check form_data JSON --->
                                    <cfif len(qAllForms.form_data)>
                                        <cftry>
                                            <cfset formDataObj = deserializeJSON(qAllForms.form_data)>
                                            <li><span class="test-pass">✓</span> Valid JSON in form_data</li>
                                            
                                            <!--- Check required fields in JSON --->
                                            <cfif structKeyExists(formDataObj, "project_type")>
                                                <li><span class="test-pass">✓</span> Project type in JSON: <cfoutput>#formDataObj.project_type#</cfoutput></li>
                                            <cfelse>
                                                <li><span class="test-warning">⚠</span> No project type in JSON</li>
                                            </cfif>
                                            
                                            <!--- Check for AI conversation data --->
                                            <cfif structKeyExists(formDataObj, "ai_conversation") AND len(formDataObj.ai_conversation)>
                                                <li><span class="test-pass">✓</span> AI conversation data present</li>
                                            </cfif>
                                            
                                            <!--- Check for service fields --->
                                            <cfif structKeyExists(formDataObj, "serviceFields") AND structCount(formDataObj.serviceFields) GT 0>
                                                <li><span class="test-pass">✓</span> Service fields: <cfoutput>#structCount(formDataObj.serviceFields)#</cfoutput> fields</li>
                                            </cfif>
                                            
                                            <cfcatch>
                                                <li><span class="test-fail">✗</span> Invalid JSON in form_data</li>
                                                <cfset arrayAppend(issues, "Invalid JSON in form_data")>
                                                <cfset isValid = false>
                                            </cfcatch>
                                        </cftry>
                                    <cfelse>
                                        <li><span class="test-warning">⚠</span> No form_data JSON</li>
                                    </cfif>
                                    
                                    <!--- Check timestamps --->
                                    <li>
                                        Created: <cfoutput>#dateFormat(qAllForms.created_at, "mm/dd/yyyy")# #timeFormat(qAllForms.created_at, "HH:mm:ss")#</cfoutput>
                                    </li>
                                    <cfif isDate(qAllForms.submitted_at)>
                                        <li>
                                            Submitted: <cfoutput>#dateFormat(qAllForms.submitted_at, "mm/dd/yyyy")# #timeFormat(qAllForms.submitted_at, "HH:mm:ss")#</cfoutput>
                                        </li>
                                    </cfif>
                                </ul>
                            </div>
                        </div>
                        
                        <!--- Show issues if any --->
                        <cfif arrayLen(issues) GT 0>
                            <div class="alert alert-danger mt-3">
                                <strong>Issues Found:</strong>
                                <ul class="mb-0">
                                    <cfloop array="#issues#" index="issue">
                                        <li><cfoutput>#issue#</cfoutput></li>
                                    </cfloop>
                                </ul>
                            </div>
                            <cfset invalidForms++>
                        <cfelse>
                            <div class="alert alert-success mt-3">
                                <i class="fas fa-check-circle"></i> Form data is valid
                            </div>
                            <cfset validForms++>
                        </cfif>
                        
                        <!--- Option to view JSON data --->
                        <cfif len(qAllForms.form_data)>
                            <button class="btn btn-sm btn-secondary" type="button" data-bs-toggle="collapse" data-bs-target="#json-<cfoutput>#qAllForms.form_id#</cfoutput>">
                                View JSON Data
                            </button>
                            <div class="collapse mt-2" id="json-<cfoutput>#qAllForms.form_id#</cfoutput>">
                                <div class="json-display">
                                    <cftry>
                                        <cfset formDataObj = deserializeJSON(qAllForms.form_data)>
                                        <pre><cfoutput>#serializeJSON(formDataObj, false, true)#</cfoutput></pre>
                                        <cfcatch>
                                            <cfoutput>#htmlEditFormat(qAllForms.form_data)#</cfoutput>
                                        </cfcatch>
                                    </cftry>
                                </div>
                            </div>
                        </cfif>
                    </div>
                </div>
            </cfloop>
            
            <!--- Summary --->
            <div class="card mt-4">
                <div class="card-header bg-primary text-white">
                    <h4 class="mb-0">Validation Summary</h4>
                </div>
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-4">
                            <div class="text-center">
                                <h2 class="text-success"><cfoutput>#validForms#</cfoutput></h2>
                                <p>Valid Forms</p>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="text-center">
                                <h2 class="text-danger"><cfoutput>#invalidForms#</cfoutput></h2>
                                <p>Invalid Forms</p>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="text-center">
                                <h2><cfoutput>#qAllForms.recordCount#</cfoutput></h2>
                                <p>Total Forms</p>
                            </div>
                        </div>
                    </div>
                    
                    <cfif invalidForms GT 0>
                        <div class="alert alert-warning mt-3">
                            <i class="fas fa-exclamation-triangle"></i> <strong><cfoutput>#invalidForms#</cfoutput> forms have validation issues that need attention.</strong>
                        </div>
                    <cfelse>
                        <div class="alert alert-success mt-3">
                            <i class="fas fa-check-circle"></i> <strong>All forms passed validation!</strong>
                        </div>
                    </cfif>
                </div>
            </div>
        <cfelse>
            <div class="alert alert-warning">
                <i class="fas fa-exclamation-triangle"></i> No forms found in the database to validate.
            </div>
        </cfif>
        
        <cfcatch>
            <div class="alert alert-danger">
                <i class="fas fa-times-circle"></i> <strong>Error accessing database:</strong><br>
                <cfoutput>#cfcatch.message#</cfoutput><br>
                <cfoutput>#cfcatch.detail#</cfoutput>
            </div>
        </cfcatch>
    </cftry>
    
    <div class="text-center mt-4 mb-5">
        <a href="index.cfm" class="btn btn-primary">Back to Test Index</a>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>