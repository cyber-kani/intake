<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Customer Intake Form</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <script src="https://accounts.google.com/gsi/client" async defer></script>
</head>
<body>
    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-6">
                <div class="card shadow">
                    <div class="card-body p-5">
                        <h2 class="text-center mb-4">Customer Intake Form</h2>
                        <p class="text-center text-muted mb-4">Sign in to continue</p>
                        
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
    </div>

    <script>
        // This will be called when Google returns the authentication
        function handleCredentialResponse(response) {
            // Submit the credential to our server
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