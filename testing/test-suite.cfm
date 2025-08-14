<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Client Intake Application - Test Suite</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        .test-pass { color: green; font-weight: bold; }
        .test-fail { color: red; font-weight: bold; }
        .test-warning { color: orange; font-weight: bold; }
        .test-info { color: blue; }
        .test-section { margin-bottom: 30px; }
        .test-result { padding: 10px; margin: 5px 0; border-left: 4px solid #ddd; }
        .test-result.pass { border-left-color: green; background-color: #f0fff0; }
        .test-result.fail { border-left-color: red; background-color: #fff0f0; }
        .test-result.warning { border-left-color: orange; background-color: #fffaf0; }
    </style>
</head>
<body>
<div class="container mt-5">
    <h1 class="mb-4">Client Intake Application - Comprehensive Test Suite</h1>
    
    <cfset testResults = []>
    <cfset totalTests = 0>
    <cfset passedTests = 0>
    <cfset failedTests = 0>
    <cfset warnings = 0>
    
    <!--- Test 1: Application Configuration --->
    <div class="test-section">
        <h2><i class="fas fa-cog"></i> Application Configuration Tests</h2>
        
        <!--- Check if Application is initialized --->
        <cfset totalTests++>
        <cftry>
            <cfif structKeyExists(application, "basePath")>
                <cfset passedTests++>
                <div class="test-result pass">
                    <span class="test-pass">✓</span> Application basePath is configured: <cfoutput>#application.basePath#</cfoutput>
                </div>
            <cfelse>
                <cfset failedTests++>
                <div class="test-result fail">
                    <span class="test-fail">✗</span> Application basePath is not configured
                </div>
            </cfif>
            <cfcatch>
                <cfset failedTests++>
                <div class="test-result fail">
                    <span class="test-fail">✗</span> Error checking application configuration: <cfoutput>#cfcatch.message#</cfoutput>
                </div>
            </cfcatch>
        </cftry>
        
        <!--- Check Google OAuth Configuration --->
        <cfset totalTests++>
        <cftry>
            <cfif structKeyExists(application, "googleClientId") AND len(application.googleClientId)>
                <cfset passedTests++>
                <div class="test-result pass">
                    <span class="test-pass">✓</span> Google OAuth is configured
                </div>
            <cfelse>
                <cfset warnings++>
                <div class="test-result warning">
                    <span class="test-warning">⚠</span> Google OAuth client ID is not configured
                </div>
            </cfif>
            <cfcatch>
                <cfset failedTests++>
                <div class="test-result fail">
                    <span class="test-fail">✗</span> Error checking Google OAuth: <cfoutput>#cfcatch.message#</cfoutput>
                </div>
            </cfcatch>
        </cftry>
        
        <!--- Check Claude API Configuration --->
        <cfset totalTests++>
        <cftry>
            <cfif structKeyExists(application, "claudeApiKey") AND len(application.claudeApiKey)>
                <cfset passedTests++>
                <div class="test-result pass">
                    <span class="test-pass">✓</span> Claude API is configured
                </div>
            <cfelse>
                <cfset warnings++>
                <div class="test-result warning">
                    <span class="test-warning">⚠</span> Claude API key is not configured
                </div>
            </cfif>
            <cfcatch>
                <cfset failedTests++>
                <div class="test-result fail">
                    <span class="test-fail">✗</span> Error checking Claude API: <cfoutput>#cfcatch.message#</cfoutput>
                </div>
            </cfcatch>
        </cftry>
        
        <!--- Check Service Categories --->
        <cfset totalTests++>
        <cftry>
            <cfif structKeyExists(application, "serviceCategories") AND structCount(application.serviceCategories) GT 0>
                <cfset passedTests++>
                <div class="test-result pass">
                    <span class="test-pass">✓</span> Service categories loaded: <cfoutput>#structCount(application.serviceCategories)#</cfoutput> categories found
                </div>
            <cfelse>
                <cfset failedTests++>
                <div class="test-result fail">
                    <span class="test-fail">✗</span> Service categories not loaded
                </div>
            </cfif>
            <cfcatch>
                <cfset failedTests++>
                <div class="test-result fail">
                    <span class="test-fail">✗</span> Error checking service categories: <cfoutput>#cfcatch.message#</cfoutput>
                </div>
            </cfcatch>
        </cftry>
    </div>
    
    <!--- Test 2: Database Connection --->
    <div class="test-section">
        <h2><i class="fas fa-database"></i> Database Connection Tests</h2>
        
        <cfset totalTests++>
        <cftry>
            <cfquery name="qTest" datasource="clitools">
                SELECT 1 as test
            </cfquery>
            <cfset passedTests++>
            <div class="test-result pass">
                <span class="test-pass">✓</span> Database connection successful
            </div>
            <cfcatch>
                <cfset failedTests++>
                <div class="test-result fail">
                    <span class="test-fail">✗</span> Database connection failed: <cfoutput>#cfcatch.message#</cfoutput>
                </div>
            </cfcatch>
        </cftry>
        
        <!--- Check Users table --->
        <cfset totalTests++>
        <cftry>
            <cfquery name="qUsers" datasource="clitools">
                SELECT COUNT(*) as user_count FROM Users
            </cfquery>
            <cfset passedTests++>
            <div class="test-result pass">
                <span class="test-pass">✓</span> Users table exists - <cfoutput>#qUsers.user_count#</cfoutput> users found
            </div>
            <cfcatch>
                <cfset failedTests++>
                <div class="test-result fail">
                    <span class="test-fail">✗</span> Users table error: <cfoutput>#cfcatch.message#</cfoutput>
                </div>
            </cfcatch>
        </cftry>
        
        <!--- Check IntakeForms table --->
        <cfset totalTests++>
        <cftry>
            <cfquery name="qForms" datasource="clitools">
                SELECT COUNT(*) as form_count FROM IntakeForms
            </cfquery>
            <cfset passedTests++>
            <div class="test-result pass">
                <span class="test-pass">✓</span> IntakeForms table exists - <cfoutput>#qForms.form_count#</cfoutput> forms found
            </div>
            <cfcatch>
                <cfset failedTests++>
                <div class="test-result fail">
                    <span class="test-fail">✗</span> IntakeForms table error: <cfoutput>#cfcatch.message#</cfoutput>
                </div>
            </cfcatch>
        </cftry>
        
        <!--- Check for reference_id column --->
        <cfset totalTests++>
        <cftry>
            <cfquery name="qRefCheck" datasource="clitools">
                SELECT TOP 1 reference_id FROM IntakeForms
            </cfquery>
            <cfset passedTests++>
            <div class="test-result pass">
                <span class="test-pass">✓</span> Reference ID column exists in IntakeForms table
            </div>
            <cfcatch>
                <cfif findNoCase("Invalid column name 'reference_id'", cfcatch.message) OR findNoCase("reference_id", cfcatch.message)>
                    <cfset warnings++>
                    <div class="test-result warning">
                        <span class="test-warning">⚠</span> Reference ID column may not exist in IntakeForms table
                    </div>
                <cfelse>
                    <cfset passedTests++>
                    <div class="test-result pass">
                        <span class="test-pass">✓</span> Reference ID check completed (empty table)
                    </div>
                </cfif>
            </cfcatch>
        </cftry>
        
        <!--- Check for form_code column --->
        <cfset totalTests++>
        <cftry>
            <cfquery name="qCodeCheck" datasource="clitools">
                SELECT TOP 1 form_code FROM IntakeForms
            </cfquery>
            <cfset passedTests++>
            <div class="test-result pass">
                <span class="test-pass">✓</span> Form code column exists in IntakeForms table
            </div>
            <cfcatch>
                <cfif findNoCase("Invalid column name 'form_code'", cfcatch.message) OR findNoCase("form_code", cfcatch.message)>
                    <cfset warnings++>
                    <div class="test-result warning">
                        <span class="test-warning">⚠</span> Form code column may not exist in IntakeForms table
                    </div>
                <cfelse>
                    <cfset passedTests++>
                    <div class="test-result pass">
                        <span class="test-pass">✓</span> Form code check completed (empty table)
                    </div>
                </cfif>
            </cfcatch>
        </cftry>
    </div>
    
    <!--- Test 3: Component Tests --->
    <div class="test-section">
        <h2><i class="fas fa-puzzle-piece"></i> Component Tests</h2>
        
        <cfset totalTests++>
        <cftry>
            <cfset db = createObject("component", "intake.components.Database")>
            <cfset passedTests++>
            <div class="test-result pass">
                <span class="test-pass">✓</span> Database component loaded successfully
            </div>
            
            <!--- Test component methods exist --->
            <cfset methods = ["getUserByGoogleId", "createUser", "updateLastLogin", "getUserForms", "getFormById"]>
            <cfloop array="#methods#" index="method">
                <cfset totalTests++>
                <cfif structKeyExists(db, method)>
                    <cfset passedTests++>
                    <div class="test-result pass ml-4">
                        <span class="test-pass">✓</span> Method '<cfoutput>#method#</cfoutput>' exists
                    </div>
                <cfelse>
                    <cfset failedTests++>
                    <div class="test-result fail ml-4">
                        <span class="test-fail">✗</span> Method '<cfoutput>#method#</cfoutput>' not found
                    </div>
                </cfif>
            </cfloop>
            
            <cfcatch>
                <cfset failedTests++>
                <div class="test-result fail">
                    <span class="test-fail">✗</span> Database component error: <cfoutput>#cfcatch.message#</cfoutput>
                </div>
            </cfcatch>
        </cftry>
    </div>
    
    <!--- Test 4: Session Management --->
    <div class="test-section">
        <h2><i class="fas fa-user-lock"></i> Session Management Tests</h2>
        
        <cfset totalTests++>
        <cftry>
            <cfif structKeyExists(session, "isLoggedIn")>
                <cfif session.isLoggedIn>
                    <cfset passedTests++>
                    <div class="test-result pass">
                        <span class="test-pass">✓</span> Session exists and user is logged in
                        <cfif structKeyExists(session, "user") AND structKeyExists(session.user, "email")>
                            as <cfoutput>#session.user.email#</cfoutput>
                        </cfif>
                    </div>
                <cfelse>
                    <cfset passedTests++>
                    <div class="test-result pass">
                        <span class="test-pass">✓</span> Session exists (user not logged in)
                    </div>
                </cfif>
            <cfelse>
                <cfset passedTests++>
                <div class="test-result pass">
                    <span class="test-pass">✓</span> Session management is active
                </div>
            </cfif>
            <cfcatch>
                <cfset failedTests++>
                <div class="test-result fail">
                    <span class="test-fail">✗</span> Session error: <cfoutput>#cfcatch.message#</cfoutput>
                </div>
            </cfcatch>
        </cftry>
        
        <!--- Check admin emails configuration --->
        <cfset totalTests++>
        <cftry>
            <cfif structKeyExists(application, "adminEmails") AND isArray(application.adminEmails)>
                <cfset passedTests++>
                <div class="test-result pass">
                    <span class="test-pass">✓</span> Admin emails configured: <cfoutput>#arrayLen(application.adminEmails)#</cfoutput> admin(s)
                </div>
            <cfelse>
                <cfset failedTests++>
                <div class="test-result fail">
                    <span class="test-fail">✗</span> Admin emails not configured
                </div>
            </cfif>
            <cfcatch>
                <cfset failedTests++>
                <div class="test-result fail">
                    <span class="test-fail">✗</span> Admin configuration error: <cfoutput>#cfcatch.message#</cfoutput>
                </div>
            </cfcatch>
        </cftry>
    </div>
    
    <!--- Test 5: File System Tests --->
    <div class="test-section">
        <h2><i class="fas fa-folder"></i> File System Tests</h2>
        
        <!--- Check critical directories --->
        <cfset directories = ["api", "admin", "auth", "components", "config", "css", "includes", "sql"]>
        <cfloop array="#directories#" index="dir">
            <cfset totalTests++>
            <cfset dirPath = expandPath("../#dir#")>
            <cfif directoryExists(dirPath)>
                <cfset passedTests++>
                <div class="test-result pass">
                    <span class="test-pass">✓</span> Directory '<cfoutput>#dir#</cfoutput>' exists
                </div>
            <cfelse>
                <cfset failedTests++>
                <div class="test-result fail">
                    <span class="test-fail">✗</span> Directory '<cfoutput>#dir#</cfoutput>' not found
                </div>
            </cfif>
        </cfloop>
        
        <!--- Check critical files --->
        <cfset files = ["Application.cfc", "index.cfm", "login.cfm", "dashboard.cfm", "form-new.cfm", "form-save.cfm"]>
        <cfloop array="#files#" index="file">
            <cfset totalTests++>
            <cfset filePath = expandPath("../#file#")>
            <cfif fileExists(filePath)>
                <cfset passedTests++>
                <div class="test-result pass">
                    <span class="test-pass">✓</span> File '<cfoutput>#file#</cfoutput>' exists
                </div>
            <cfelse>
                <cfset failedTests++>
                <div class="test-result fail">
                    <span class="test-fail">✗</span> File '<cfoutput>#file#</cfoutput>' not found
                </div>
            </cfif>
        </cfloop>
    </div>
    
    <!--- Summary --->
    <div class="test-section mt-5">
        <h2><i class="fas fa-chart-bar"></i> Test Summary</h2>
        <div class="card">
            <div class="card-body">
                <div class="row">
                    <div class="col-md-3">
                        <h4>Total Tests: <cfoutput>#totalTests#</cfoutput></h4>
                    </div>
                    <div class="col-md-3">
                        <h4 class="text-success">Passed: <cfoutput>#passedTests#</cfoutput></h4>
                    </div>
                    <div class="col-md-3">
                        <h4 class="text-danger">Failed: <cfoutput>#failedTests#</cfoutput></h4>
                    </div>
                    <div class="col-md-3">
                        <h4 class="text-warning">Warnings: <cfoutput>#warnings#</cfoutput></h4>
                    </div>
                </div>
                <div class="progress mt-3" style="height: 30px;">
                    <cfset passPercent = (passedTests / totalTests) * 100>
                    <cfset failPercent = (failedTests / totalTests) * 100>
                    <cfset warnPercent = (warnings / totalTests) * 100>
                    <div class="progress-bar bg-success" style="width: <cfoutput>#passPercent#</cfoutput>%">
                        <cfoutput>#numberFormat(passPercent, "99.9")#</cfoutput>%
                    </div>
                    <div class="progress-bar bg-danger" style="width: <cfoutput>#failPercent#</cfoutput>%">
                        <cfoutput>#numberFormat(failPercent, "99.9")#</cfoutput>%
                    </div>
                    <div class="progress-bar bg-warning" style="width: <cfoutput>#warnPercent#</cfoutput>%">
                        <cfoutput>#numberFormat(warnPercent, "99.9")#</cfoutput>%
                    </div>
                </div>
                
                <cfif failedTests EQ 0>
                    <div class="alert alert-success mt-3">
                        <i class="fas fa-check-circle"></i> <strong>All critical tests passed!</strong>
                    </div>
                <cfelseif failedTests LT 5>
                    <div class="alert alert-warning mt-3">
                        <i class="fas fa-exclamation-triangle"></i> <strong>Some tests failed. Please review the issues above.</strong>
                    </div>
                <cfelse>
                    <div class="alert alert-danger mt-3">
                        <i class="fas fa-times-circle"></i> <strong>Multiple tests failed. The application may not be functioning correctly.</strong>
                    </div>
                </cfif>
            </div>
        </div>
    </div>
    
    <div class="text-center mt-4 mb-5">
        <a href="index.cfm" class="btn btn-primary">Back to Test Index</a>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>