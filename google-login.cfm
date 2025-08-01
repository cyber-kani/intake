<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Customer Intake Form</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <meta name="google-signin-client_id" content="YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com">
    <script src="https://apis.google.com/js/platform.js" async defer></script>
</head>
<body>
    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-6">
                <div class="card shadow">
                    <div class="card-body p-5">
                        <h2 class="text-center mb-4">Sign In with Google</h2>
                        
                        <div class="alert alert-info">
                            <h5>Google Sign-In Setup Required</h5>
                            <p>To use Google Sign-In, you need to:</p>
                            <ol class="mb-0">
                                <li>Go to <a href="https://console.cloud.google.com/" target="_blank">Google Cloud Console</a></li>
                                <li>Create a new project or select existing</li>
                                <li>Enable Google+ API</li>
                                <li>Create OAuth 2.0 credentials</li>
                                <li>Add <code>https://clitools.app</code> to authorized domains</li>
                                <li>Get your Client ID (ends with .apps.googleusercontent.com)</li>
                                <li>Update Application.cfc with the Client ID</li>
                            </ol>
                        </div>
                        
                        <hr class="my-4">
                        
                        <div class="text-center">
                            <p class="mb-3">For now, use the test login:</p>
                            <a href="<cfoutput>#application.basePath#</cfoutput>/test-login.cfm" class="btn btn-primary">
                                <i class="fas fa-user"></i> Use Test Login
                            </a>
                            
                            <div class="mt-3">
                                <a href="<cfoutput>#application.basePath#</cfoutput>/" class="btn btn-link">
                                    <i class="fas fa-arrow-left"></i> Back to Home
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>