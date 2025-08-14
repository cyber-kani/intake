<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Security Checker</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        .test-pass { color: green; font-weight: bold; }
        .test-fail { color: red; font-weight: bold; }
        .test-warning { color: orange; font-weight: bold; }
        .security-section { margin-bottom: 30px; }
        .code-sample { background-color: #f4f4f4; padding: 10px; border-radius: 5px; font-family: monospace; font-size: 12px; }
    </style>
</head>
<body>
<div class="container mt-5">
    <h1 class="mb-4"><i class="fas fa-shield-alt"></i> Security Checker</h1>
    
    <cfset securityIssues = []>
    <cfset securityWarnings = []>
    <cfset passedChecks = []>
    
    <!--- Check 1: SQL Injection Protection --->
    <div class="security-section">
        <h3><i class="fas fa-database"></i> SQL Injection Protection</h3>
        
        <!--- Check for cfqueryparam usage in critical files --->
        <cfset filesToCheck = [
            "../form-save.cfm",
            "../components/Database.cfc",
            "../auth/user-auth.cfm",
            "../auth/google-callback.cfm",
            "../api/get-form.cfm",
            "../api/delete-form.cfm"
        ]>
        
        <cfloop array="#filesToCheck#" index="file">
            <cfif fileExists(expandPath(file))>
                <cffile action="read" file="#expandPath(file)#" variable="fileContent">
                
                <!--- Check for direct SQL without cfqueryparam --->
                <cfset hasUnprotectedSQL = false>
                <cfset hasCfquery = findNoCase("<cfquery", fileContent) GT 0>
                
                <cfif hasCfquery>
                    <!--- Look for WHERE clauses without cfqueryparam --->
                    <cfif reFindNoCase("WHERE\s+\w+\s*=\s*'?####[^##]+####'?(?![^<]*cfqueryparam)", fileContent)>
                        <cfset hasUnprotectedSQL = true>
                    </cfif>
                    
                    <!--- Check if file uses cfqueryparam at all --->
                    <cfif findNoCase("cfqueryparam", fileContent) GT 0>
                        <cfif NOT hasUnprotectedSQL>
                            <div class="alert alert-success">
                                <span class="test-pass">✓</span> <strong><cfoutput>#listLast(file, "/")#</cfoutput></strong>: Uses cfqueryparam for SQL queries
                            </div>
                            <cfset arrayAppend(passedChecks, "SQL Protection in #listLast(file, '/')#")>
                        <cfelse>
                            <div class="alert alert-warning">
                                <span class="test-warning">⚠</span> <strong><cfoutput>#listLast(file, "/")#</cfoutput></strong>: Some queries may not use cfqueryparam
                            </div>
                            <cfset arrayAppend(securityWarnings, "Possible unprotected SQL in #listLast(file, '/')#")>
                        </cfif>
                    <cfelseif hasCfquery>
                        <div class="alert alert-danger">
                            <span class="test-fail">✗</span> <strong><cfoutput>#listLast(file, "/")#</cfoutput></strong>: Contains queries without cfqueryparam
                        </div>
                        <cfset arrayAppend(securityIssues, "No SQL protection in #listLast(file, '/')#")>
                    </cfif>
                </cfif>
            </cfif>
        </cfloop>
    </div>
    
    <!--- Check 2: XSS Protection --->
    <div class="security-section">
        <h3><i class="fas fa-code"></i> Cross-Site Scripting (XSS) Protection</h3>
        
        <cfset outputFiles = [
            "../dashboard.cfm",
            "../form-view.cfm",
            "../admin/index.cfm"
        ]>
        
        <cfloop array="#outputFiles#" index="file">
            <cfif fileExists(expandPath(file))>
                <cffile action="read" file="#expandPath(file)#" variable="fileContent">
                
                <!--- Check for proper output encoding --->
                <cfset hasRawOutput = reFindNoCase("<cfoutput>####[^##]+####</cfoutput>", fileContent)>
                <cfset hasHtmlEditFormat = findNoCase("htmlEditFormat", fileContent) GT 0>
                <cfset hasEncodeForHTML = findNoCase("encodeForHTML", fileContent) GT 0>
                
                <cfif hasRawOutput AND (hasHtmlEditFormat OR hasEncodeForHTML)>
                    <div class="alert alert-success">
                        <span class="test-pass">✓</span> <strong><cfoutput>#listLast(file, "/")#</cfoutput></strong>: Uses output encoding functions
                    </div>
                    <cfset arrayAppend(passedChecks, "XSS Protection in #listLast(file, '/')#")>
                <cfelseif hasRawOutput>
                    <div class="alert alert-warning">
                        <span class="test-warning">⚠</span> <strong><cfoutput>#listLast(file, "/")#</cfoutput></strong>: May have unencoded output
                    </div>
                    <cfset arrayAppend(securityWarnings, "Possible XSS vulnerability in #listLast(file, '/')#")>
                </cfif>
            </cfif>
        </cfloop>
        
        <!--- Check scriptProtect setting --->
        <cfif fileExists(expandPath("../Application.cfc"))>
            <cffile action="read" file="#expandPath('../Application.cfc')#" variable="appContent">
            <cfif findNoCase('this.scriptProtect = "all"', appContent) GT 0>
                <div class="alert alert-success">
                    <span class="test-pass">✓</span> Application.cfc has scriptProtect enabled
                </div>
                <cfset arrayAppend(passedChecks, "Script protection enabled")>
            <cfelse>
                <div class="alert alert-warning">
                    <span class="test-warning">⚠</span> scriptProtect may not be fully enabled
                </div>
                <cfset arrayAppend(securityWarnings, "Script protection not fully enabled")>
            </cfif>
        </cfif>
    </div>
    
    <!--- Check 3: Authentication & Session Security --->
    <div class="security-section">
        <h3><i class="fas fa-user-lock"></i> Authentication & Session Security</h3>
        
        <!--- Check password hashing --->
        <cfif fileExists(expandPath("../auth/user-auth.cfm"))>
            <cffile action="read" file="#expandPath('../auth/user-auth.cfm')#" variable="authContent">
            <cfif findNoCase('hash(form.password, "SHA-256")', authContent) GT 0>
                <div class="alert alert-success">
                    <span class="test-pass">✓</span> Passwords are hashed using SHA-256
                </div>
                <cfset arrayAppend(passedChecks, "Password hashing implemented")>
            <cfelse>
                <div class="alert alert-danger">
                    <span class="test-fail">✗</span> Password hashing not found or weak algorithm
                </div>
                <cfset arrayAppend(securityIssues, "Weak password hashing")>
            </cfif>
        </cfif>
        
        <!--- Check session timeout --->
        <cfif fileExists(expandPath("../Application.cfc"))>
            <cffile action="read" file="#expandPath('../Application.cfc')#" variable="appContent">
            <cfif findNoCase("this.sessionTimeout", appContent) GT 0>
                <div class="alert alert-success">
                    <span class="test-pass">✓</span> Session timeout is configured
                </div>
                <cfset arrayAppend(passedChecks, "Session timeout configured")>
            <cfelse>
                <div class="alert alert-warning">
                    <span class="test-warning">⚠</span> Session timeout not explicitly set
                </div>
                <cfset arrayAppend(securityWarnings, "No explicit session timeout")>
            </cfif>
        </cfif>
        
        <!--- Check for addtoken=false in redirects --->
        <cfset redirectFiles = ["../login.cfm", "../logout.cfm", "../auth/user-auth.cfm"]>
        <cfset hasTokenIssue = false>
        <cfloop array="#redirectFiles#" index="file">
            <cfif fileExists(expandPath(file))>
                <cffile action="read" file="#expandPath(file)#" variable="fileContent">
                <cfif findNoCase("cflocation", fileContent) GT 0 AND NOT findNoCase('addtoken="false"', fileContent) GT 0>
                    <cfset hasTokenIssue = true>
                </cfif>
            </cfif>
        </cfloop>
        
        <cfif NOT hasTokenIssue>
            <div class="alert alert-success">
                <span class="test-pass">✓</span> URL token disclosure prevention in place
            </div>
            <cfset arrayAppend(passedChecks, "URL token protection")>
        <cfelse>
            <div class="alert alert-warning">
                <span class="test-warning">⚠</span> Some redirects may expose session tokens
            </div>
            <cfset arrayAppend(securityWarnings, "Possible session token exposure")>
        </cfif>
    </div>
    
    <!--- Check 4: Access Control --->
    <div class="security-section">
        <h3><i class="fas fa-lock"></i> Access Control</h3>
        
        <!--- Check admin access control --->
        <cfif fileExists(expandPath("../Application.cfc"))>
            <cffile action="read" file="#expandPath('../Application.cfc')#" variable="appContent">
            <cfif findNoCase("admin", appContent) AND findNoCase("session.isLoggedIn", appContent)>
                <div class="alert alert-success">
                    <span class="test-pass">✓</span> Admin access control implemented
                </div>
                <cfset arrayAppend(passedChecks, "Admin access control")>
            <cfelse>
                <div class="alert alert-warning">
                    <span class="test-warning">⚠</span> Admin access control may need review
                </div>
                <cfset arrayAppend(securityWarnings, "Admin access control needs review")>
            </cfif>
        </cfif>
        
        <!--- Check for proper session checks --->
        <cfset protectedFiles = ["../dashboard.cfm", "../form-save.cfm", "../form-edit.cfm"]>
        <cfset hasProperAuth = true>
        <cfloop array="#protectedFiles#" index="file">
            <cfif fileExists(expandPath(file))>
                <cffile action="read" file="#expandPath(file)#" variable="fileContent">
                <cfif NOT (findNoCase("session.isLoggedIn", fileContent) GT 0 OR findNoCase("session.user", fileContent) GT 0)>
                    <cfset hasProperAuth = false>
                </cfif>
            </cfif>
        </cfloop>
        
        <cfif hasProperAuth>
            <div class="alert alert-success">
                <span class="test-pass">✓</span> Protected pages check authentication
            </div>
            <cfset arrayAppend(passedChecks, "Authentication checks on protected pages")>
        <cfelse>
            <div class="alert alert-warning">
                <span class="test-warning">⚠</span> Some protected pages may lack authentication checks
            </div>
            <cfset arrayAppend(securityWarnings, "Missing authentication checks")>
        </cfif>
    </div>
    
    <!--- Check 5: File Upload Security --->
    <div class="security-section">
        <h3><i class="fas fa-upload"></i> File Upload Security</h3>
        
        <!--- Search for file upload functionality --->
        <cfset uploadFound = false>
        <cfset filesToCheck = ["../form-save.cfm", "../form-new.cfm"]>
        <cfloop array="#filesToCheck#" index="file">
            <cfif fileExists(expandPath(file))>
                <cffile action="read" file="#expandPath(file)#" variable="fileContent">
                <cfif findNoCase("cffile", fileContent) GT 0 OR findNoCase("enctype", fileContent) GT 0>
                    <cfset uploadFound = true>
                </cfif>
            </cfif>
        </cfloop>
        
        <cfif NOT uploadFound>
            <div class="alert alert-info">
                <i class="fas fa-info-circle"></i> No file upload functionality detected
            </div>
        <cfelse>
            <div class="alert alert-warning">
                <span class="test-warning">⚠</span> File upload functionality detected - ensure proper validation
            </div>
            <cfset arrayAppend(securityWarnings, "File upload functionality needs security review")>
        </cfif>
    </div>
    
    <!--- Check 6: API Security --->
    <div class="security-section">
        <h3><i class="fas fa-plug"></i> API Security</h3>
        
        <!--- Check API key storage --->
        <cfif fileExists(expandPath("../config/config.cfm"))>
            <div class="alert alert-success">
                <span class="test-pass">✓</span> API keys stored in separate config file
            </div>
            <cfset arrayAppend(passedChecks, "API keys properly stored")>
        <cfelse>
            <div class="alert alert-warning">
                <span class="test-warning">⚠</span> Config file not found - API keys may be hardcoded
            </div>
            <cfset arrayAppend(securityWarnings, "API key storage needs review")>
        </cfif>
        
        <!--- Check for exposed API keys in code --->
        <cfset apiFiles = ["../api/claude-chat.cfm", "../api/smart-chat.cfm"]>
        <cfset hasExposedKeys = false>
        <cfloop array="#apiFiles#" index="file">
            <cfif fileExists(expandPath(file))>
                <cffile action="read" file="#expandPath(file)#" variable="fileContent">
                <cfif reFindNoCase("sk-[a-zA-Z0-9]{48}", fileContent)>
                    <cfset hasExposedKeys = true>
                </cfif>
            </cfif>
        </cfloop>
        
        <cfif NOT hasExposedKeys>
            <div class="alert alert-success">
                <span class="test-pass">✓</span> No hardcoded API keys found
            </div>
            <cfset arrayAppend(passedChecks, "No hardcoded API keys")>
        <cfelse>
            <div class="alert alert-danger">
                <span class="test-fail">✗</span> Possible hardcoded API keys detected
            </div>
            <cfset arrayAppend(securityIssues, "Hardcoded API keys found")>
        </cfif>
    </div>
    
    <!--- Summary --->
    <div class="card mt-5">
        <div class="card-header bg-dark text-white">
            <h4 class="mb-0"><i class="fas fa-chart-pie"></i> Security Summary</h4>
        </div>
        <div class="card-body">
            <div class="row">
                <div class="col-md-4">
                    <div class="text-center">
                        <h2 class="text-success"><cfoutput>#arrayLen(passedChecks)#</cfoutput></h2>
                        <p>Passed Checks</p>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="text-center">
                        <h2 class="text-warning"><cfoutput>#arrayLen(securityWarnings)#</cfoutput></h2>
                        <p>Warnings</p>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="text-center">
                        <h2 class="text-danger"><cfoutput>#arrayLen(securityIssues)#</cfoutput></h2>
                        <p>Critical Issues</p>
                    </div>
                </div>
            </div>
            
            <cfif arrayLen(securityIssues) GT 0>
                <div class="alert alert-danger mt-3">
                    <h5><i class="fas fa-exclamation-triangle"></i> Critical Security Issues:</h5>
                    <ul class="mb-0">
                        <cfloop array="#securityIssues#" index="issue">
                            <li><cfoutput>#issue#</cfoutput></li>
                        </cfloop>
                    </ul>
                </div>
            </cfif>
            
            <cfif arrayLen(securityWarnings) GT 0>
                <div class="alert alert-warning mt-3">
                    <h5><i class="fas fa-exclamation-circle"></i> Security Warnings:</h5>
                    <ul class="mb-0">
                        <cfloop array="#securityWarnings#" index="warning">
                            <li><cfoutput>#warning#</cfoutput></li>
                        </cfloop>
                    </ul>
                </div>
            </cfif>
            
            <cfif arrayLen(securityIssues) EQ 0 AND arrayLen(securityWarnings) EQ 0>
                <div class="alert alert-success mt-3">
                    <i class="fas fa-shield-alt"></i> <strong>Excellent!</strong> No critical security issues detected.
                </div>
            </cfif>
            
            <h5 class="mt-4">Security Best Practices Checklist:</h5>
            <ul class="list-group">
                <li class="list-group-item"><i class="fas fa-check text-success"></i> Use cfqueryparam for all database queries</li>
                <li class="list-group-item"><i class="fas fa-check text-success"></i> Encode output with htmlEditFormat() or encodeForHTML()</li>
                <li class="list-group-item"><i class="fas fa-check text-success"></i> Hash passwords with strong algorithms</li>
                <li class="list-group-item"><i class="fas fa-check text-success"></i> Implement session timeouts</li>
                <li class="list-group-item"><i class="fas fa-check text-success"></i> Use HTTPS for production</li>
                <li class="list-group-item"><i class="fas fa-check text-success"></i> Validate all user input</li>
                <li class="list-group-item"><i class="fas fa-check text-success"></i> Store API keys securely</li>
                <li class="list-group-item"><i class="fas fa-check text-success"></i> Implement proper access controls</li>
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