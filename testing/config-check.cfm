<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Configuration Settings Checker</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        .test-pass { color: green; font-weight: bold; }
        .test-fail { color: red; font-weight: bold; }
        .test-warning { color: orange; font-weight: bold; }
        .config-section { margin-bottom: 30px; }
        .config-info { background-color: #f8f9fa; padding: 15px; border-radius: 5px; margin: 10px 0; }
        .sensitive-data { background-color: #fffacd; color: #8b7355; padding: 2px 6px; border-radius: 3px; font-family: monospace; }
    </style>
</head>
<body>
<div class="container mt-5">
    <h1 class="mb-4"><i class="fas fa-cogs"></i> Configuration Settings Checker</h1>
    
    <cfset configIssues = []>
    <cfset configWarnings = []>
    <cfset passedChecks = []>
    
    <!--- Test 1: Configuration Files --->
    <div class="config-section">
        <h3><i class="fas fa-file-alt"></i> Configuration Files</h3>
        
        <!--- Check config.cfm --->
        <cftry>
            <cfif fileExists(expandPath("../config/config.cfm"))>
                <div class="alert alert-success">
                    <span class="test-pass">✓</span> <strong>config.cfm</strong>: Configuration file exists
                </div>
                <cfset arrayAppend(passedChecks, "Configuration file exists")>
                
                <!--- Try to include the config file --->
                <cftry>
                    <cfinclude template="../config/config.cfm">
                    <div class="alert alert-success">
                        <span class="test-pass">✓</span> <strong>config.cfm</strong>: Configuration file loads successfully
                    </div>
                    <cfset arrayAppend(passedChecks, "Configuration file loads successfully")>
                    
                    <cfcatch>
                        <div class="alert alert-danger">
                            <span class="test-fail">✗</span> <strong>config.cfm</strong>: Error loading configuration file<br>
                            <small><cfoutput>#cfcatch.message#</cfoutput></small>
                        </div>
                        <cfset arrayAppend(configIssues, "Configuration file has syntax errors")>
                    </cfcatch>
                </cftry>
            <cfelse>
                <div class="alert alert-danger">
                    <span class="test-fail">✗</span> <strong>config.cfm</strong>: Configuration file not found
                </div>
                <cfset arrayAppend(configIssues, "Configuration file missing")>
            </cfif>
            
            <!--- Check if example file exists --->
            <cfif fileExists(expandPath("../config/config.cfm.example"))>
                <div class="alert alert-info">
                    <i class="fas fa-info-circle"></i> <strong>config.cfm.example</strong>: Template file available
                </div>
            <cfelse>
                <div class="alert alert-warning">
                    <span class="test-warning">⚠</span> <strong>config.cfm.example</strong>: Template file not found
                </div>
                <cfset arrayAppend(configWarnings, "Configuration template file missing")>
            </cfif>
            
            <cfcatch>
                <div class="alert alert-danger">
                    <span class="test-fail">✗</span> Error checking configuration files: <cfoutput>#cfcatch.message#</cfoutput>
                </div>
                <cfset arrayAppend(configIssues, "Error checking configuration files")>
            </cfcatch>
        </cftry>
    </div>
    
    <!--- Test 2: Application Configuration Variables --->
    <div class="config-section">
        <h3><i class="fas fa-server"></i> Application Configuration Variables</h3>
        
        <cftry>
            <!--- Check base path --->
            <cfif structKeyExists(application, "basePath") AND len(application.basePath)>
                <div class="alert alert-success">
                    <span class="test-pass">✓</span> <strong>Base Path</strong>: Configured
                    <div class="config-info">
                        Path: <code><cfoutput>#application.basePath#</cfoutput></code>
                    </div>
                </div>
                <cfset arrayAppend(passedChecks, "Application base path configured")>
            <cfelse>
                <div class="alert alert-danger">
                    <span class="test-fail">✗</span> <strong>Base Path</strong>: Not configured
                </div>
                <cfset arrayAppend(configIssues, "Application base path missing")>
            </cfif>
            
            <!--- Check datasource --->
            <cfif structKeyExists(application, "datasource") AND len(application.datasource)>
                <div class="alert alert-success">
                    <span class="test-pass">✓</span> <strong>Database Datasource</strong>: Configured
                    <div class="config-info">
                        Datasource: <code><cfoutput>#application.datasource#</cfoutput></code>
                    </div>
                </div>
                <cfset arrayAppend(passedChecks, "Database datasource configured")>
            <cfelse>
                <div class="alert alert-warning">
                    <span class="test-warning">⚠</span> <strong>Database Datasource</strong>: Using default "clitools"
                </div>
                <cfset arrayAppend(configWarnings, "Database datasource using default value")>
            </cfif>
            
            <!--- Check session timeout --->
            <cfif structKeyExists(this, "sessionTimeout") AND isDate(this.sessionTimeout)>
                <div class="alert alert-success">
                    <span class="test-pass">✓</span> <strong>Session Timeout</strong>: Configured
                    <div class="config-info">
                        Timeout: <cfoutput>#this.sessionTimeout#</cfoutput>
                    </div>
                </div>
                <cfset arrayAppend(passedChecks, "Session timeout configured")>
            <cfelse>
                <div class="alert alert-warning">
                    <span class="test-warning">⚠</span> <strong>Session Timeout</strong>: Using default settings
                </div>
                <cfset arrayAppend(configWarnings, "Session timeout not explicitly configured")>
            </cfif>
            
            <cfcatch>
                <div class="alert alert-danger">
                    <span class="test-fail">✗</span> Error checking application configuration: <cfoutput>#cfcatch.message#</cfoutput>
                </div>
                <cfset arrayAppend(configIssues, "Error accessing application configuration")>
            </cfcatch>
        </cftry>
    </div>
    
    <!--- Test 3: API Keys Configuration --->
    <div class="config-section">
        <h3><i class="fas fa-key"></i> API Keys Configuration</h3>
        
        <cftry>
            <!--- Check Claude API Key --->
            <cfif structKeyExists(application, "claudeApiKey") AND len(application.claudeApiKey)>
                <cfset keyLength = len(application.claudeApiKey)>
                <cfset keyPreview = left(application.claudeApiKey, 8) & "..." & right(application.claudeApiKey, 4)>
                <div class="alert alert-success">
                    <span class="test-pass">✓</span> <strong>Claude API Key</strong>: Configured
                    <div class="config-info">
                        Length: <cfoutput>#keyLength#</cfoutput> characters<br>
                        Preview: <span class="sensitive-data"><cfoutput>#keyPreview#</cfoutput></span>
                    </div>
                </div>
                <cfset arrayAppend(passedChecks, "Claude API key configured")>
                
                <!--- Basic format validation --->
                <cfif left(application.claudeApiKey, 3) EQ "sk-">
                    <div class="alert alert-success">
                        <span class="test-pass">✓</span> <strong>Claude API Key Format</strong>: Appears to be valid format
                    </div>
                    <cfset arrayAppend(passedChecks, "Claude API key format valid")>
                <cfelse>
                    <div class="alert alert-warning">
                        <span class="test-warning">⚠</span> <strong>Claude API Key Format</strong>: Unexpected format (should start with 'sk-')
                    </div>
                    <cfset arrayAppend(configWarnings, "Claude API key format unexpected")>
                </cfif>
            <cfelse>
                <div class="alert alert-danger">
                    <span class="test-fail">✗</span> <strong>Claude API Key</strong>: Not configured
                </div>
                <cfset arrayAppend(configIssues, "Claude API key missing")>
            </cfif>
            
            <!--- Check Google OAuth Configuration --->
            <cfif structKeyExists(application, "googleClientId") AND len(application.googleClientId)>
                <div class="alert alert-success">
                    <span class="test-pass">✓</span> <strong>Google Client ID</strong>: Configured
                    <div class="config-info">
                        Length: <cfoutput>#len(application.googleClientId)#</cfoutput> characters<br>
                        Preview: <span class="sensitive-data"><cfoutput>#left(application.googleClientId, 12)#</cfoutput>...</span>
                    </div>
                </div>
                <cfset arrayAppend(passedChecks, "Google Client ID configured")>
            <cfelse>
                <div class="alert alert-warning">
                    <span class="test-warning">⚠</span> <strong>Google Client ID</strong>: Not configured
                </div>
                <cfset arrayAppend(configWarnings, "Google OAuth not configured")>
            </cfif>
            
            <cfif structKeyExists(application, "googleClientSecret") AND len(application.googleClientSecret)>
                <div class="alert alert-success">
                    <span class="test-pass">✓</span> <strong>Google Client Secret</strong>: Configured
                    <div class="config-info">
                        Length: <cfoutput>#len(application.googleClientSecret)#</cfoutput> characters
                    </div>
                </div>
                <cfset arrayAppend(passedChecks, "Google Client Secret configured")>
            <cfelse>
                <div class="alert alert-warning">
                    <span class="test-warning">⚠</span> <strong>Google Client Secret</strong>: Not configured
                </div>
                <cfset arrayAppend(configWarnings, "Google Client Secret missing")>
            </cfif>
            
            <cfcatch>
                <div class="alert alert-danger">
                    <span class="test-fail">✗</span> Error checking API keys: <cfoutput>#cfcatch.message#</cfoutput>
                </div>
                <cfset arrayAppend(configIssues, "Error checking API keys")>
            </cfcatch>
        </cftry>
    </div>
    
    <!--- Test 4: Email Configuration --->
    <div class="config-section">
        <h3><i class="fas fa-envelope"></i> Email Configuration</h3>
        
        <cftry>
            <!--- Check admin emails --->
            <cfif structKeyExists(application, "adminEmails") AND isArray(application.adminEmails)>
                <div class="alert alert-success">
                    <span class="test-pass">✓</span> <strong>Admin Emails</strong>: Configured
                    <div class="config-info">
                        Count: <cfoutput>#arrayLen(application.adminEmails)#</cfoutput> admin email(s)
                        <cfif arrayLen(application.adminEmails) GT 0>
                            <ul class="mt-2">
                                <cfloop array="#application.adminEmails#" index="adminEmail">
                                    <li>
                                        <cfif isValid("email", adminEmail)>
                                            <span class="test-pass">✓</span>
                                        <cfelse>
                                            <span class="test-fail">✗</span>
                                        </cfif>
                                        <cfoutput>#adminEmail#</cfoutput>
                                    </li>
                                </cfloop>
                            </ul>
                        </cfif>
                    </div>
                </div>
                <cfset arrayAppend(passedChecks, "Admin emails configured")>
            <cfelse>
                <div class="alert alert-warning">
                    <span class="test-warning">⚠</span> <strong>Admin Emails</strong>: Not configured
                </div>
                <cfset arrayAppend(configWarnings, "Admin emails not configured")>
            </cfif>
            
            <!--- Check mail server configuration --->
            <cfif structKeyExists(application, "mailServer") AND len(application.mailServer)>
                <div class="alert alert-success">
                    <span class="test-pass">✓</span> <strong>Mail Server</strong>: Configured
                    <div class="config-info">
                        Server: <code><cfoutput>#application.mailServer#</cfoutput></code>
                    </div>
                </div>
                <cfset arrayAppend(passedChecks, "Mail server configured")>
            <cfelse>
                <div class="alert alert-warning">
                    <span class="test-warning">⚠</span> <strong>Mail Server</strong>: Not configured (using default)
                </div>
                <cfset arrayAppend(configWarnings, "Mail server not explicitly configured")>
            </cfif>
            
            <!--- Check from email --->
            <cfif structKeyExists(application, "fromEmail") AND len(application.fromEmail)>
                <cfif isValid("email", application.fromEmail)>
                    <div class="alert alert-success">
                        <span class="test-pass">✓</span> <strong>From Email</strong>: Valid
                        <div class="config-info">
                            Email: <code><cfoutput>#application.fromEmail#</cfoutput></code>
                        </div>
                    </div>
                    <cfset arrayAppend(passedChecks, "From email configured and valid")>
                <cfelse>
                    <div class="alert alert-danger">
                        <span class="test-fail">✗</span> <strong>From Email</strong>: Invalid format
                    </div>
                    <cfset arrayAppend(configIssues, "From email has invalid format")>
                </cfif>
            <cfelse>
                <div class="alert alert-warning">
                    <span class="test-warning">⚠</span> <strong>From Email</strong>: Not configured
                </div>
                <cfset arrayAppend(configWarnings, "From email not configured")>
            </cfif>
            
            <cfcatch>
                <div class="alert alert-danger">
                    <span class="test-fail">✗</span> Error checking email configuration: <cfoutput>#cfcatch.message#</cfoutput>
                </div>
                <cfset arrayAppend(configIssues, "Error checking email configuration")>
            </cfcatch>
        </cftry>
    </div>
    
    <!--- Test 5: Service Categories Configuration --->
    <div class="config-section">
        <h3><i class="fas fa-list"></i> Service Categories Configuration</h3>
        
        <cftry>
            <cfif structKeyExists(application, "serviceCategories") AND structCount(application.serviceCategories) GT 0>
                <div class="alert alert-success">
                    <span class="test-pass">✓</span> <strong>Service Categories</strong>: Loaded
                    <div class="config-info">
                        Categories: <cfoutput>#structCount(application.serviceCategories)#</cfoutput>
                        <ul class="mt-2">
                            <cfloop collection="#application.serviceCategories#" item="categoryKey">
                                <li>
                                    <strong><cfoutput>#categoryKey#</cfoutput></strong>
                                    <cfif structKeyExists(application.serviceCategories[categoryKey], "services") AND arrayLen(application.serviceCategories[categoryKey].services) GT 0>
                                        (<cfoutput>#arrayLen(application.serviceCategories[categoryKey].services)#</cfoutput> services)
                                    </cfif>
                                </li>
                            </cfloop>
                        </ul>
                    </div>
                </div>
                <cfset arrayAppend(passedChecks, "Service categories loaded")>
            <cfelse>
                <div class="alert alert-danger">
                    <span class="test-fail">✗</span> <strong>Service Categories</strong>: Not loaded
                </div>
                <cfset arrayAppend(configIssues, "Service categories not loaded")>
            </cfif>
            
            <cfcatch>
                <div class="alert alert-danger">
                    <span class="test-fail">✗</span> Error checking service categories: <cfoutput>#cfcatch.message#</cfoutput>
                </div>
                <cfset arrayAppend(configIssues, "Error checking service categories")>
            </cfcatch>
        </cftry>
    </div>
    
    <!--- Test 6: Security Configuration --->
    <div class="config-section">
        <h3><i class="fas fa-shield-alt"></i> Security Configuration</h3>
        
        <cftry>
            <!--- Check Application.cfc security settings --->
            <cfif fileExists(expandPath("../Application.cfc"))>
                <cffile action="read" file="#expandPath('../Application.cfc')#" variable="appContent">
                
                <!--- Check scriptProtect --->
                <cfif findNoCase('this.scriptProtect = "all"', appContent) GT 0>
                    <div class="alert alert-success">
                        <span class="test-pass">✓</span> <strong>Script Protection</strong>: Enabled (all)
                    </div>
                    <cfset arrayAppend(passedChecks, "Script protection fully enabled")>
                <cfelseif findNoCase("this.scriptProtect", appContent) GT 0>
                    <div class="alert alert-warning">
                        <span class="test-warning">⚠</span> <strong>Script Protection</strong>: Partially enabled
                    </div>
                    <cfset arrayAppend(configWarnings, "Script protection partially enabled")>
                <cfelse>
                    <div class="alert alert-danger">
                        <span class="test-fail">✗</span> <strong>Script Protection</strong>: Not configured
                    </div>
                    <cfset arrayAppend(configIssues, "Script protection not configured")>
                </cfif>
                
                <!--- Check session management --->
                <cfif findNoCase("this.sessionManagement", appContent) GT 0>
                    <div class="alert alert-success">
                        <span class="test-pass">✓</span> <strong>Session Management</strong>: Configured
                    </div>
                    <cfset arrayAppend(passedChecks, "Session management configured")>
                <cfelse>
                    <div class="alert alert-warning">
                        <span class="test-warning">⚠</span> <strong>Session Management</strong>: Not explicitly configured
                    </div>
                    <cfset arrayAppend(configWarnings, "Session management not explicitly configured")>
                </cfif>
                
                <!--- Check secure JSON --->
                <cfif findNoCase("this.secureJSON", appContent) GT 0>
                    <div class="alert alert-success">
                        <span class="test-pass">✓</span> <strong>Secure JSON</strong>: Configured
                    </div>
                    <cfset arrayAppend(passedChecks, "Secure JSON configured")>
                <cfelse>
                    <div class="alert alert-warning">
                        <span class="test-warning">⚠</span> <strong>Secure JSON</strong>: Not configured
                    </div>
                    <cfset arrayAppend(configWarnings, "Secure JSON not configured")>
                </cfif>
            </cfif>
            
            <cfcatch>
                <div class="alert alert-danger">
                    <span class="test-fail">✗</span> Error checking security configuration: <cfoutput>#cfcatch.message#</cfoutput>
                </div>
                <cfset arrayAppend(configIssues, "Error checking security configuration")>
            </cfcatch>
        </cftry>
    </div>
    
    <!--- Summary --->
    <div class="card mt-5">
        <div class="card-header bg-dark text-white">
            <h4 class="mb-0"><i class="fas fa-chart-pie"></i> Configuration Summary</h4>
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
                        <h2 class="text-warning"><cfoutput>#arrayLen(configWarnings)#</cfoutput></h2>
                        <p>Warnings</p>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="text-center">
                        <h2 class="text-danger"><cfoutput>#arrayLen(configIssues)#</cfoutput></h2>
                        <p>Issues</p>
                    </div>
                </div>
            </div>
            
            <cfif arrayLen(configIssues) GT 0>
                <div class="alert alert-danger mt-3">
                    <h5><i class="fas fa-exclamation-triangle"></i> Critical Configuration Issues:</h5>
                    <ul class="mb-0">
                        <cfloop array="#configIssues#" index="issue">
                            <li><cfoutput>#issue#</cfoutput></li>
                        </cfloop>
                    </ul>
                </div>
            </cfif>
            
            <cfif arrayLen(configWarnings) GT 0>
                <div class="alert alert-warning mt-3">
                    <h5><i class="fas fa-exclamation-circle"></i> Configuration Warnings:</h5>
                    <ul class="mb-0">
                        <cfloop array="#configWarnings#" index="warning">
                            <li><cfoutput>#warning#</cfoutput></li>
                        </cfloop>
                    </ul>
                </div>
            </cfif>
            
            <cfif arrayLen(configIssues) EQ 0 AND arrayLen(configWarnings) LT 3>
                <div class="alert alert-success mt-3">
                    <i class="fas fa-check-circle"></i> <strong>Configuration looks good!</strong> The application is properly configured.
                </div>
            <cfelseif arrayLen(configIssues) EQ 0>
                <div class="alert alert-info mt-3">
                    <i class="fas fa-info-circle"></i> <strong>Configuration is functional</strong> but could be improved by addressing the warnings above.
                </div>
            </cfif>
            
            <h5 class="mt-4">Configuration Best Practices:</h5>
            <ul class="list-group">
                <li class="list-group-item"><i class="fas fa-check text-success"></i> Store sensitive data in separate config files</li>
                <li class="list-group-item"><i class="fas fa-check text-success"></i> Use environment variables for different environments</li>
                <li class="list-group-item"><i class="fas fa-check text-success"></i> Enable security settings in Application.cfc</li>
                <li class="list-group-item"><i class="fas fa-check text-success"></i> Configure proper session timeouts</li>
                <li class="list-group-item"><i class="fas fa-check text-success"></i> Validate all email addresses</li>
                <li class="list-group-item"><i class="fas fa-check text-success"></i> Keep config files out of version control</li>
                <li class="list-group-item"><i class="fas fa-check text-success"></i> Use strong API keys with proper formatting</li>
                <li class="list-group-item"><i class="fas fa-check text-success"></i> Configure backup admin contacts</li>
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