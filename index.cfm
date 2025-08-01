<!--- Check if application variables exist --->
<cfif NOT structKeyExists(application, "serviceCategories")>
    <cfset applicationStop()>
    <cflocation url="#cgi.script_name#" addtoken="false">
</cfif>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Intake Form</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="<cfoutput>#application.basePath#</cfoutput>/css/style.css" rel="stylesheet">
    <script src="https://accounts.google.com/gsi/client" async defer></script>
</head>
<body>
    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-10">
                <div class="text-center mb-5">
                    <h1 class="display-4 mb-3">Welcome to Customer Intake</h1>
                    <p class="lead text-muted">Start your project journey with us</p>
                </div>

                <!--- Check if user is logged in --->
                <cfif structKeyExists(session, "user") AND structKeyExists(session.user, "isLoggedIn") AND session.user.isLoggedIn>
                    <!--- Don't redirect admins if they explicitly want to create a new form --->
                    <cfif structKeyExists(session.user, "email") AND listFindNoCase(arrayToList(application.adminEmails), session.user.email)>
                        <cfif NOT structKeyExists(url, "new") OR url.new NEQ "true">
                            <cflocation url="#application.basePath#/admin/" addtoken="false">
                        </cfif>
                    </cfif>
                    
                    <!--- Check if user has existing forms --->
                    <cfif NOT structKeyExists(url, "new") OR url.new NEQ "true">
                        <cfset db = createObject("component", "components.Database")>
                        <cfset userForms = db.getUserForms(session.user.userId)>
                        <cfif userForms.recordCount GT 0>
                            <cflocation url="#application.basePath#/dashboard.cfm" addtoken="false">
                        </cfif>
                    </cfif>
                    <!--- User is logged in, show options --->
                    <div class="row justify-content-center">
                        <!--- AI Chat Option --->
                        <div class="col-md-5 mb-4">
                            <div class="card h-100 shadow-lg option-card">
                                <div class="card-body text-center p-5">
                                    <div class="mb-4">
                                        <div class="ai-icon-wrapper mx-auto">
                                            <div class="ai-icon-glow"></div>
                                            <div class="ai-icon">
                                                <svg width="60" height="60" viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
                                                    <defs>
                                                        <linearGradient id="torusGradient" x1="0%" y1="0%" x2="100%" y2="100%">
                                                            <stop offset="0%" style="stop-color:#667eea;stop-opacity:1" />
                                                            <stop offset="100%" style="stop-color:#764ba2;stop-opacity:1" />
                                                        </linearGradient>
                                                    </defs>
                                                    <g class="torus-group">
                                                        <circle cx="50" cy="50" r="35" fill="none" stroke="url(#torusGradient)" stroke-width="12" opacity="0.3" />
                                                        <circle cx="50" cy="50" r="35" fill="none" stroke="url(#torusGradient)" stroke-width="12" stroke-dasharray="55 165" class="torus-ring" />
                                                        <circle cx="50" cy="50" r="20" fill="none" stroke="url(#torusGradient)" stroke-width="8" opacity="0.5" />
                                                        <circle cx="50" cy="50" r="20" fill="none" stroke="url(#torusGradient)" stroke-width="8" stroke-dasharray="30 95" class="torus-ring-inner" />
                                                    </g>
                                                </svg>
                                            </div>
                                        </div>
                                    </div>
                                    <h3 class="card-title mb-3">Chat with AI Assistant</h3>
                                    <p class="card-text text-muted mb-4">Tell our AI assistant about your project in your own words. We'll understand your needs and guide you to the right solution.</p>
                                    <a href="<cfoutput>#application.basePath#</cfoutput>/form-new-ai.cfm" class="btn btn-primary btn-lg px-5">
                                        <i class="fas fa-comments"></i> Start Chat
                                    </a>
                                </div>
                            </div>
                        </div>
                        
                        <!--- Manual Selection Option --->
                        <div class="col-md-5 mb-4">
                            <div class="card h-100 shadow-lg option-card">
                                <div class="card-body text-center p-5">
                                    <div class="mb-4">
                                        <div class="manual-icon-wrapper mx-auto">
                                            <i class="fas fa-mouse-pointer fa-4x text-primary"></i>
                                        </div>
                                    </div>
                                    <h3 class="card-title mb-3">Select Manually</h3>
                                    <p class="card-text text-muted mb-4">Know exactly what you need? Choose your project type and service category from our comprehensive list.</p>
                                    <a href="<cfoutput>#application.basePath#</cfoutput>/form-new.cfm" class="btn btn-outline-primary btn-lg px-5">
                                        <i class="fas fa-list-ul"></i> Select Manually
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="text-center mt-5">
                        <p class="text-muted">
                            <i class="fas fa-info-circle"></i> Not sure which to choose? Try our AI chat for a guided experience!
                        </p>
                        <p class="text-muted mt-3">
                            Logged in as: <strong><cfoutput>#session.user.email#</cfoutput></strong> | 
                            <a href="<cfoutput>#application.basePath#</cfoutput>/logout.cfm" class="text-decoration-none">Sign Out</a>
                        </p>
                    </div>
                <cfelse>
                    <!--- User not logged in, show login button --->
                    <div class="row justify-content-center">
                        <div class="col-md-6">
                            <div class="card shadow-lg">
                                <div class="card-body p-5">
                                    <h2 class="text-center mb-4">Start Your Project</h2>
                                    <p class="text-center text-muted mb-4">Sign in to create your project intake form</p>
                                    
                                    <!--- Google Sign-In Button --->
                                    <div class="d-flex justify-content-center mb-3">
                                        <div id="g_id_onload"
                                            data-client_id="<cfoutput>#application.googleClientId#</cfoutput>"
                                            data-callback="handleCredentialResponse"
                                            data-auto_prompt="false">
                                        </div>
                                        <div class="g_id_signin"
                                            data-type="standard"
                                            data-size="large"
                                            data-theme="outline"
                                            data-text="sign_in_with"
                                            data-shape="rectangular"
                                            data-logo_alignment="left">
                                        </div>
                                    </div>
                                    
                                    <hr class="my-4">
                                    
                                    <!--- Username/Password login --->
                                    <p class="text-center text-muted">Or sign in with username:</p>
                                    <form action="<cfoutput>#application.basePath#</cfoutput>/auth/user-auth.cfm" method="POST">
                                        <div class="mb-3">
                                            <label for="username" class="form-label">Username</label>
                                            <input type="text" class="form-control" id="username" name="username" required>
                                        </div>
                                        <div class="mb-3">
                                            <label for="password" class="form-label">Password</label>
                                            <input type="password" class="form-control" id="password" name="password" required>
                                        </div>
                                        <div class="d-grid">
                                            <button type="submit" class="btn btn-primary">
                                                <i class="fas fa-sign-in-alt"></i> Sign In
                                            </button>
                                        </div>
                                    </form>
                                    
                                    <div class="text-center mt-3">
                                        <p class="mb-0">Don't have an account? <a href="<cfoutput>#application.basePath#</cfoutput>/register.cfm">Create one</a></p>
                                    </div>
                                    
                                    <cfif structKeyExists(url, "error")>
                                        <div class="alert alert-danger mt-3">
                                            <cfoutput>#url.error#</cfoutput>
                                        </div>
                                    </cfif>
                                    
                                    <cfif structKeyExists(url, "success")>
                                        <div class="alert alert-success mt-3">
                                            <cfoutput>#url.success#</cfoutput>
                                        </div>
                                    </cfif>
                                </div>
                            </div>
                        </div>
                    </div>
                </cfif>
            </div>
        </div>
    </div>

    <style>
    .option-card {
        transition: all 0.3s ease;
        border: 2px solid transparent;
        cursor: pointer;
    }

    .option-card:hover {
        transform: translateY(-5px);
        border-color: #0d6efd;
    }

    .ai-icon-wrapper {
        position: relative;
        width: 120px;
        height: 120px;
        display: flex;
        align-items: center;
        justify-content: center;
    }

    .ai-icon {
        background: rgba(255, 255, 255, 0.9);
        width: 100px;
        height: 100px;
        border-radius: 30px;
        display: flex;
        align-items: center;
        justify-content: center;
        box-shadow: 0 10px 30px rgba(102, 126, 234, 0.3);
        position: relative;
        z-index: 2;
        animation: float 3s ease-in-out infinite;
    }

    .torus-group {
        animation: rotate3d 8s linear infinite;
        transform-origin: center;
    }

    .torus-ring {
        animation: rotateTorus 4s linear infinite;
        transform-origin: center;
    }

    .torus-ring-inner {
        animation: rotateTorusInner 3s linear infinite reverse;
        transform-origin: center;
    }

    @keyframes rotate3d {
        0% { transform: rotateY(0deg) rotateX(15deg); }
        100% { transform: rotateY(360deg) rotateX(15deg); }
    }

    @keyframes rotateTorus {
        0% { stroke-dashoffset: 0; }
        100% { stroke-dashoffset: 220; }
    }

    @keyframes rotateTorusInner {
        0% { stroke-dashoffset: 0; }
        100% { stroke-dashoffset: 125; }
    }

    .ai-icon-glow {
        position: absolute;
        width: 120px;
        height: 120px;
        background: radial-gradient(circle, rgba(102, 126, 234, 0.3) 0%, transparent 70%);
        border-radius: 50%;
        animation: pulse 2s ease-in-out infinite;
        z-index: 1;
    }

    @keyframes float {
        0%, 100% { transform: translateY(0px); }
        50% { transform: translateY(-10px); }
    }

    @keyframes pulse {
        0%, 100% { transform: scale(1); opacity: 0.5; }
        50% { transform: scale(1.2); opacity: 0.3; }
    }

    .manual-icon-wrapper {
        width: 120px;
        height: 120px;
        display: flex;
        align-items: center;
        justify-content: center;
        background: #f8f9fa;
        border-radius: 30px;
        box-shadow: 0 10px 30px rgba(13, 110, 253, 0.2);
    }

    .manual-icon-wrapper i {
        transition: all 0.3s ease;
    }

    .option-card:hover .manual-icon-wrapper i {
        transform: scale(1.1);
    }
    </style>

    <script>
    function handleCredentialResponse(response) {
        // Submit the credential to our backend
        const form = document.createElement('form');
        form.method = 'POST';
        form.action = '<cfoutput>#application.basePath#</cfoutput>/auth/google-callback.cfm';
        
        const input = document.createElement('input');
        input.type = 'hidden';
        input.name = 'credential';
        input.value = response.credential;
        
        form.appendChild(input);
        document.body.appendChild(form);
        form.submit();
    }
    </script>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>