<!--- Admin Configuration Manager --->
<cfif NOT session.isLoggedIn OR NOT listFindNoCase(arrayToList(application.adminEmails), session.user.email)>
    <cflocation url="../login.cfm" addtoken="false">
</cfif>

<!--- Handle form submission --->
<cfif structKeyExists(form, "action") AND form.action EQ "update">
    <cftry>
        <cfloop collection="#form#" item="key">
            <cfif left(key, 7) EQ "config_">
                <cfset configKey = mid(key, 8, len(key))>
                <cfquery datasource="clitools">
                    UPDATE AppConfig 
                    SET config_value = <cfqueryparam value="#form[key]#" cfsqltype="cf_sql_varchar">
                    WHERE config_key = <cfqueryparam value="#configKey#" cfsqltype="cf_sql_varchar">
                </cfquery>
            </cfif>
        </cfloop>
        <cfset successMessage = "Configuration updated successfully!">
        
        <!--- Force application restart to load new config --->
        <cfset applicationStop()>
        
        <cfcatch>
            <cfset errorMessage = "Error updating configuration: #cfcatch.message#">
        </cfcatch>
    </cftry>
</cfif>

<!--- Get current configuration --->
<cfquery name="qConfig" datasource="clitools">
    SELECT * FROM AppConfig
    ORDER BY 
        CASE config_key
            WHEN 'ANTHROPIC_API_KEY' THEN 1
            WHEN 'GOOGLE_CLIENT_ID' THEN 2
            WHEN 'GOOGLE_CLIENT_SECRET' THEN 3
            WHEN 'GOOGLE_API_KEY' THEN 4
            ELSE 5
        END,
        config_key
</cfquery>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Configuration Manager - Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-5">
        <div class="row">
            <div class="col-md-12">
                <h1><i class="fas fa-cogs"></i> Configuration Manager</h1>
                <p class="text-muted">Manage API keys and application settings</p>
                
                <cfif isDefined("successMessage")>
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        <i class="fas fa-check-circle"></i> <cfoutput>#successMessage#</cfoutput>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </cfif>
                
                <cfif isDefined("errorMessage")>
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        <i class="fas fa-exclamation-triangle"></i> <cfoutput>#errorMessage#</cfoutput>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </cfif>
                
                <form method="post" action="config-manager.cfm" class="needs-validation" novalidate>
                    <input type="hidden" name="action" value="update">
                    
                    <div class="card mb-4">
                        <div class="card-header bg-primary text-white">
                            <h5 class="mb-0"><i class="fas fa-key"></i> API Keys</h5>
                        </div>
                        <div class="card-body">
                            <cfoutput query="qConfig">
                                <cfif listFindNoCase("ANTHROPIC_API_KEY,GOOGLE_CLIENT_ID,GOOGLE_CLIENT_SECRET,GOOGLE_API_KEY", config_key)>
                                    <div class="mb-3">
                                        <label for="config_#config_key#" class="form-label">
                                            <strong>#replace(config_key, "_", " ", "all")#</strong>
                                            <cfif config_key EQ "ANTHROPIC_API_KEY">
                                                <span class="badge bg-danger">Required</span>
                                            <cfelseif config_key EQ "GOOGLE_CLIENT_ID" OR config_key EQ "GOOGLE_CLIENT_SECRET">
                                                <span class="badge bg-warning">Required for Google Sign-In</span>
                                            <cfelse>
                                                <span class="badge bg-secondary">Optional</span>
                                            </cfif>
                                        </label>
                                        <cfif config_key CONTAINS "SECRET" OR config_key CONTAINS "API_KEY">
                                            <div class="input-group">
                                                <input type="password" 
                                                       class="form-control" 
                                                       id="config_#config_key#" 
                                                       name="config_#config_key#" 
                                                       value="#config_value#"
                                                       placeholder="Enter #replace(config_key, '_', ' ', 'all')#">
                                                <button class="btn btn-outline-secondary" type="button" onclick="togglePassword('config_#config_key#')">
                                                    <i class="fas fa-eye"></i>
                                                </button>
                                            </div>
                                        <cfelse>
                                            <input type="text" 
                                                   class="form-control" 
                                                   id="config_#config_key#" 
                                                   name="config_#config_key#" 
                                                   value="#config_value#"
                                                   placeholder="Enter #replace(config_key, '_', ' ', 'all')#">
                                        </cfif>
                                        <small class="form-text text-muted">#description#</small>
                                    </div>
                                </cfif>
                            </cfoutput>
                        </div>
                    </div>
                    
                    <div class="card mb-4">
                        <div class="card-header bg-secondary text-white">
                            <h5 class="mb-0"><i class="fas fa-cog"></i> Application Settings</h5>
                        </div>
                        <div class="card-body">
                            <cfoutput query="qConfig">
                                <cfif NOT listFindNoCase("ANTHROPIC_API_KEY,GOOGLE_CLIENT_ID,GOOGLE_CLIENT_SECRET,GOOGLE_API_KEY", config_key)>
                                    <div class="mb-3">
                                        <label for="config_#config_key#" class="form-label">
                                            <strong>#replace(config_key, "_", " ", "all")#</strong>
                                        </label>
                                        <input type="text" 
                                               class="form-control" 
                                               id="config_#config_key#" 
                                               name="config_#config_key#" 
                                               value="#config_value#">
                                        <small class="form-text text-muted">#description#</small>
                                    </div>
                                </cfif>
                            </cfoutput>
                        </div>
                    </div>
                    
                    <div class="d-flex justify-content-between">
                        <a href="index.cfm" class="btn btn-secondary">
                            <i class="fas fa-arrow-left"></i> Back to Admin
                        </a>
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-save"></i> Save Configuration
                        </button>
                    </div>
                </form>
                
                <div class="alert alert-info mt-4">
                    <h5><i class="fas fa-info-circle"></i> Configuration Notes:</h5>
                    <ul class="mb-0">
                        <li><strong>Anthropic API Key:</strong> Get from <a href="https://console.anthropic.com" target="_blank">console.anthropic.com</a></li>
                        <li><strong>Google OAuth:</strong> Configure at <a href="https://console.cloud.google.com" target="_blank">console.cloud.google.com</a></li>
                        <li><strong>Security:</strong> Keys are stored in the database and loaded at application startup</li>
                        <li><strong>Changes:</strong> Configuration changes require application restart (automatic)</li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function togglePassword(fieldId) {
            const field = document.getElementById(fieldId);
            const button = field.nextElementSibling.querySelector('i');
            
            if (field.type === 'password') {
                field.type = 'text';
                button.classList.remove('fa-eye');
                button.classList.add('fa-eye-slash');
            } else {
                field.type = 'password';
                button.classList.remove('fa-eye-slash');
                button.classList.add('fa-eye');
            }
        }
    </script>
</body>
</html>