<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>API Endpoints Test</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        .test-pass { color: green; font-weight: bold; }
        .test-fail { color: red; font-weight: bold; }
        .test-warning { color: orange; font-weight: bold; }
        .api-section { margin-bottom: 30px; }
        .response-data { background-color: #f4f4f4; padding: 10px; border-radius: 5px; font-family: monospace; font-size: 12px; max-height: 200px; overflow-y: auto; }
    </style>
</head>
<body>
<div class="container mt-5">
    <h1 class="mb-4"><i class="fas fa-plug"></i> API Endpoints Test</h1>
    
    <cfset apiIssues = []>
    <cfset apiWarnings = []>
    <cfset passedTests = []>
    
    <!--- Test 1: API Files Existence --->
    <div class="api-section">
        <h3><i class="fas fa-file-code"></i> API Files Availability</h3>
        
        <cfset apiFiles = [
            "claude-chat.cfm",
            "claude-chat-v4.cfm", 
            "ai-chat.cfm",
            "smart-chat.cfm",
            "get-form.cfm",
            "save-draft.cfm",
            "delete-form.cfm",
            "finalize-ai-form.cfm"
        ]>
        
        <cfloop array="#apiFiles#" index="apiFile">
            <cfif fileExists(expandPath("../api/#apiFile#"))>
                <div class="alert alert-success">
                    <span class="test-pass">✓</span> <strong><cfoutput>#apiFile#</cfoutput></strong>: File exists
                </div>
                <cfset arrayAppend(passedTests, "API file #apiFile# exists")>
            <cfelse>
                <div class="alert alert-danger">
                    <span class="test-fail">✗</span> <strong><cfoutput>#apiFile#</cfoutput></strong>: File not found
                </div>
                <cfset arrayAppend(apiIssues, "Missing API file: #apiFile#")>
            </cfif>
        </cfloop>
    </div>
    
    <!--- Test 2: Claude Chat API Test --->
    <div class="api-section">
        <h3><i class="fas fa-comments"></i> Claude Chat API</h3>
        
        <cftry>
            <!--- Read the Claude chat file to check for basic structure --->
            <cfif fileExists(expandPath("../api/claude-chat.cfm"))>
                <cffile action="read" file="#expandPath('../api/claude-chat.cfm')#" variable="claudeContent">
                
                <!--- Check for required components --->
                <cfset hasApiKey = findNoCase("claudeApiKey", claudeContent) GT 0>
                <cfset hasHttpCall = findNoCase("cfhttp", claudeContent) GT 0>
                <cfset hasJsonHandling = findNoCase("deserializeJSON", claudeContent) GT 0 OR findNoCase("serializeJSON", claudeContent) GT 0>
                <cfset hasErrorHandling = findNoCase("cfcatch", claudeContent) GT 0>
                
                <cfif hasApiKey>
                    <div class="alert alert-success">
                        <span class="test-pass">✓</span> Claude API key configuration found
                    </div>
                    <cfset arrayAppend(passedTests, "Claude API key configured")>
                <cfelse>
                    <div class="alert alert-danger">
                        <span class="test-fail">✗</span> Claude API key configuration missing
                    </div>
                    <cfset arrayAppend(apiIssues, "Claude API key not configured")>
                </cfif>
                
                <cfif hasHttpCall>
                    <div class="alert alert-success">
                        <span class="test-pass">✓</span> HTTP request implementation found
                    </div>
                    <cfset arrayAppend(passedTests, "Claude HTTP request implemented")>
                <cfelse>
                    <div class="alert alert-warning">
                        <span class="test-warning">⚠</span> HTTP request implementation not found
                    </div>
                    <cfset arrayAppend(apiWarnings, "Claude HTTP request not implemented")>
                </cfif>
                
                <cfif hasJsonHandling>
                    <div class="alert alert-success">
                        <span class="test-pass">✓</span> JSON handling implemented
                    </div>
                    <cfset arrayAppend(passedTests, "Claude JSON handling implemented")>
                <cfelse>
                    <div class="alert alert-warning">
                        <span class="test-warning">⚠</span> JSON handling not found
                    </div>
                    <cfset arrayAppend(apiWarnings, "Claude JSON handling missing")>
                </cfif>
                
                <cfif hasErrorHandling>
                    <div class="alert alert-success">
                        <span class="test-pass">✓</span> Error handling implemented
                    </div>
                    <cfset arrayAppend(passedTests, "Claude error handling implemented")>
                <cfelse>
                    <div class="alert alert-warning">
                        <span class="test-warning">⚠</span> Error handling not found
                    </div>
                    <cfset arrayAppend(apiWarnings, "Claude error handling missing")>
                </cfif>
            </cfif>
            
            <cfcatch>
                <div class="alert alert-danger">
                    <span class="test-fail">✗</span> Error analyzing Claude API file: <cfoutput>#cfcatch.message#</cfoutput>
                </div>
                <cfset arrayAppend(apiIssues, "Error analyzing Claude API file")>
            </cfcatch>
        </cftry>
    </div>
    
    <!--- Test 3: Form Operations API Test --->
    <div class="api-section">
        <h3><i class="fas fa-database"></i> Form Operations API</h3>
        
        <!--- Test get-form.cfm --->
        <cftry>
            <cfif fileExists(expandPath("../api/get-form.cfm"))>
                <cffile action="read" file="#expandPath('../api/get-form.cfm')#" variable="getFormContent">
                
                <cfset hasFormIdParam = findNoCase("form.form_id", getFormContent) GT 0 OR findNoCase("url.form_id", getFormContent) GT 0>
                <cfset hasQuery = findNoCase("cfquery", getFormContent) GT 0>
                <cfset hasJsonResponse = findNoCase("serializeJSON", getFormContent) GT 0>
                
                <cfif hasFormIdParam AND hasQuery>
                    <div class="alert alert-success">
                        <span class="test-pass">✓</span> <strong>get-form.cfm</strong>: Form ID parameter and query implementation found
                    </div>
                    <cfset arrayAppend(passedTests, "get-form.cfm properly implemented")>
                <cfelse>
                    <div class="alert alert-warning">
                        <span class="test-warning">⚠</span> <strong>get-form.cfm</strong>: Implementation may be incomplete
                    </div>
                    <cfset arrayAppend(apiWarnings, "get-form.cfm implementation incomplete")>
                </cfif>
                
                <cfif hasJsonResponse>
                    <div class="alert alert-success">
                        <span class="test-pass">✓</span> <strong>get-form.cfm</strong>: JSON response implementation found
                    </div>
                    <cfset arrayAppend(passedTests, "get-form.cfm JSON response implemented")>
                </cfif>
            </cfif>
            
            <cfcatch>
                <div class="alert alert-danger">
                    <span class="test-fail">✗</span> Error analyzing get-form.cfm: <cfoutput>#cfcatch.message#</cfoutput>
                </div>
                <cfset arrayAppend(apiIssues, "Error analyzing get-form.cfm")>
            </cfcatch>
        </cftry>
        
        <!--- Test save-draft.cfm --->
        <cftry>
            <cfif fileExists(expandPath("../api/save-draft.cfm"))>
                <cffile action="read" file="#expandPath('../api/save-draft.cfm')#" variable="saveDraftContent">
                
                <cfset hasFormData = findNoCase("form.form_data", saveDraftContent) GT 0 OR findNoCase("form_data", saveDraftContent) GT 0>
                <cfset hasInsertUpdate = findNoCase("INSERT", saveDraftContent) GT 0 OR findNoCase("UPDATE", saveDraftContent) GT 0>
                
                <cfif hasFormData AND hasInsertUpdate>
                    <div class="alert alert-success">
                        <span class="test-pass">✓</span> <strong>save-draft.cfm</strong>: Form data handling and database operations found
                    </div>
                    <cfset arrayAppend(passedTests, "save-draft.cfm properly implemented")>
                <cfelse>
                    <div class="alert alert-warning">
                        <span class="test-warning">⚠</span> <strong>save-draft.cfm</strong>: Implementation may be incomplete
                    </div>
                    <cfset arrayAppend(apiWarnings, "save-draft.cfm implementation incomplete")>
                </cfif>
            </cfif>
            
            <cfcatch>
                <div class="alert alert-danger">
                    <span class="test-fail">✗</span> Error analyzing save-draft.cfm: <cfoutput>#cfcatch.message#</cfoutput>
                </div>
                <cfset arrayAppend(apiIssues, "Error analyzing save-draft.cfm")>
            </cfcatch>
        </cftry>
        
        <!--- Test delete-form.cfm --->
        <cftry>
            <cfif fileExists(expandPath("../api/delete-form.cfm"))>
                <cffile action="read" file="#expandPath('../api/delete-form.cfm')#" variable="deleteFormContent">
                
                <cfset hasDeleteQuery = findNoCase("DELETE", deleteFormContent) GT 0>
                <cfset hasFormIdParam = findNoCase("form_id", deleteFormContent) GT 0>
                <cfset hasAuth = findNoCase("session", deleteFormContent) GT 0 OR findNoCase("isLoggedIn", deleteFormContent) GT 0>
                
                <cfif hasDeleteQuery AND hasFormIdParam>
                    <div class="alert alert-success">
                        <span class="test-pass">✓</span> <strong>delete-form.cfm</strong>: DELETE operation and form ID parameter found
                    </div>
                    <cfset arrayAppend(passedTests, "delete-form.cfm properly implemented")>
                <cfelse>
                    <div class="alert alert-warning">
                        <span class="test-warning">⚠</span> <strong>delete-form.cfm</strong>: Implementation may be incomplete
                    </div>
                    <cfset arrayAppend(apiWarnings, "delete-form.cfm implementation incomplete")>
                </cfif>
                
                <cfif hasAuth>
                    <div class="alert alert-success">
                        <span class="test-pass">✓</span> <strong>delete-form.cfm</strong>: Authentication check found
                    </div>
                    <cfset arrayAppend(passedTests, "delete-form.cfm has authentication")>
                <cfelse>
                    <div class="alert alert-danger">
                        <span class="test-fail">✗</span> <strong>delete-form.cfm</strong>: No authentication check found
                    </div>
                    <cfset arrayAppend(apiIssues, "delete-form.cfm missing authentication")>
                </cfif>
            </cfif>
            
            <cfcatch>
                <div class="alert alert-danger">
                    <span class="test-fail">✗</span> Error analyzing delete-form.cfm: <cfoutput>#cfcatch.message#</cfoutput>
                </div>
                <cfset arrayAppend(apiIssues, "Error analyzing delete-form.cfm")>
            </cfcatch>
        </cftry>
    </div>
    
    <!--- Test 4: API Response Format Test --->
    <div class="api-section">
        <h3><i class="fas fa-code"></i> API Response Format</h3>
        
        <cftry>
            <!--- Check for consistent response format across API files --->
            <cfset responseFormatGood = 0>
            <cfset responseFormatBad = 0>
            
            <cfloop array="#apiFiles#" index="apiFile">
                <cfif fileExists(expandPath("../api/#apiFile#"))>
                    <cffile action="read" file="#expandPath('../api/#apiFile#')#" variable="apiContent">
                    
                    <!--- Check for JSON content type --->
                    <cfset hasContentType = findNoCase("application/json", apiContent) GT 0>
                    <!--- Check for success/error structure --->
                    <cfset hasStructuredResponse = findNoCase('"success"', apiContent) GT 0 OR findNoCase('"error"', apiContent) GT 0>
                    
                    <cfif hasContentType OR hasStructuredResponse>
                        <cfset responseFormatGood++>
                    <cfelse>
                        <cfset responseFormatBad++>
                    </cfif>
                </cfif>
            </cfloop>
            
            <cfif responseFormatGood GT responseFormatBad>
                <div class="alert alert-success">
                    <span class="test-pass">✓</span> Most API files follow proper response format (<cfoutput>#responseFormatGood#</cfoutput>/<cfoutput>#arrayLen(apiFiles)#</cfoutput>)
                </div>
                <cfset arrayAppend(passedTests, "API response format is consistent")>
            <cfelse>
                <div class="alert alert-warning">
                    <span class="test-warning">⚠</span> API response format inconsistency detected
                </div>
                <cfset arrayAppend(apiWarnings, "API response format needs standardization")>
            </cfif>
            
            <cfcatch>
                <div class="alert alert-danger">
                    <span class="test-fail">✗</span> Error checking API response formats: <cfoutput>#cfcatch.message#</cfoutput>
                </div>
                <cfset arrayAppend(apiIssues, "Error checking API response formats")>
            </cfcatch>
        </cftry>
    </div>
    
    <!--- Test 5: API Security Checks --->
    <div class="api-section">
        <h3><i class="fas fa-shield-alt"></i> API Security</h3>
        
        <cftry>
            <cfset secureApis = 0>
            <cfset insecureApis = 0>
            
            <!--- Check each API file for basic security measures --->
            <cfloop array="#apiFiles#" index="apiFile">
                <cfif fileExists(expandPath("../api/#apiFile#"))>
                    <cffile action="read" file="#expandPath('../api/#apiFile#')#" variable="apiContent">
                    
                    <!--- Check for session validation --->
                    <cfset hasSessionCheck = findNoCase("session.isLoggedIn", apiContent) GT 0 OR findNoCase("session.user", apiContent) GT 0>
                    <!--- Check for parameter validation --->
                    <cfset hasParamValidation = findNoCase("cfqueryparam", apiContent) GT 0>
                    <!--- Check for input sanitization --->
                    <cfset hasInputSanitization = findNoCase("htmlEditFormat", apiContent) GT 0 OR findNoCase("encodeFor", apiContent) GT 0>
                    
                    <cfif hasSessionCheck OR hasParamValidation>
                        <cfset secureApis++>
                    <cfelse>
                        <cfset insecureApis++>
                    </cfif>
                </cfif>
            </cfloop>
            
            <cfif secureApis GTE insecureApis>
                <div class="alert alert-success">
                    <span class="test-pass">✓</span> Most API files have basic security measures (<cfoutput>#secureApis#</cfoutput>/<cfoutput>#arrayLen(apiFiles)#</cfoutput>)
                </div>
                <cfset arrayAppend(passedTests, "API security measures implemented")>
            <cfelse>
                <div class="alert alert-danger">
                    <span class="test-fail">✗</span> Many API files lack basic security measures
                </div>
                <cfset arrayAppend(apiIssues, "API security measures insufficient")>
            </cfif>
            
            <cfcatch>
                <div class="alert alert-danger">
                    <span class="test-fail">✗</span> Error checking API security: <cfoutput>#cfcatch.message#</cfoutput>
                </div>
                <cfset arrayAppend(apiIssues, "Error checking API security")>
            </cfcatch>
        </cftry>
    </div>
    
    <!--- Summary --->
    <div class="card mt-5">
        <div class="card-header bg-dark text-white">
            <h4 class="mb-0"><i class="fas fa-chart-pie"></i> API Test Summary</h4>
        </div>
        <div class="card-body">
            <div class="row">
                <div class="col-md-4">
                    <div class="text-center">
                        <h2 class="text-success"><cfoutput>#arrayLen(passedTests)#</cfoutput></h2>
                        <p>Passed Tests</p>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="text-center">
                        <h2 class="text-warning"><cfoutput>#arrayLen(apiWarnings)#</cfoutput></h2>
                        <p>Warnings</p>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="text-center">
                        <h2 class="text-danger"><cfoutput>#arrayLen(apiIssues)#</cfoutput></h2>
                        <p>Issues</p>
                    </div>
                </div>
            </div>
            
            <cfif arrayLen(apiIssues) GT 0>
                <div class="alert alert-danger mt-3">
                    <h5><i class="fas fa-exclamation-triangle"></i> API Issues:</h5>
                    <ul class="mb-0">
                        <cfloop array="#apiIssues#" index="issue">
                            <li><cfoutput>#issue#</cfoutput></li>
                        </cfloop>
                    </ul>
                </div>
            </cfif>
            
            <cfif arrayLen(apiWarnings) GT 0>
                <div class="alert alert-warning mt-3">
                    <h5><i class="fas fa-exclamation-circle"></i> API Warnings:</h5>
                    <ul class="mb-0">
                        <cfloop array="#apiWarnings#" index="warning">
                            <li><cfoutput>#warning#</cfoutput></li>
                        </cfloop>
                    </ul>
                </div>
            </cfif>
            
            <cfif arrayLen(apiIssues) EQ 0 AND arrayLen(apiWarnings) EQ 0>
                <div class="alert alert-success mt-3">
                    <i class="fas fa-check-shield"></i> <strong>Excellent!</strong> All API endpoints passed testing.
                </div>
            </cfif>
            
            <h5 class="mt-4">API Best Practices Checklist:</h5>
            <ul class="list-group">
                <li class="list-group-item"><i class="fas fa-check text-success"></i> Consistent response format (JSON)</li>
                <li class="list-group-item"><i class="fas fa-check text-success"></i> Proper error handling with try/catch</li>
                <li class="list-group-item"><i class="fas fa-check text-success"></i> Session validation for protected endpoints</li>
                <li class="list-group-item"><i class="fas fa-check text-success"></i> Input validation and sanitization</li>
                <li class="list-group-item"><i class="fas fa-check text-success"></i> Use of cfqueryparam for database queries</li>
                <li class="list-group-item"><i class="fas fa-check text-success"></i> Proper HTTP status codes</li>
                <li class="list-group-item"><i class="fas fa-check text-success"></i> Rate limiting (recommended)</li>
                <li class="list-group-item"><i class="fas fa-check text-success"></i> API documentation (recommended)</li>
            </ul>
        </div>
    </div>
    
    <div class="text-center mt-4 mb-5">
        <a href="index.cfm" class="btn btn-primary">Back to Test Index</a>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>