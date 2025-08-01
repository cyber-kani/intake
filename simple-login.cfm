<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Customer Intake Form</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-6">
                <div class="card shadow">
                    <div class="card-body p-5">
                        <h2 class="text-center mb-4">Sign In</h2>
                        
                        <cfif structKeyExists(url, "error")>
                            <div class="alert alert-danger">
                                <cfoutput>#url.error#</cfoutput>
                            </div>
                        </cfif>
                        
                        <form action="<cfoutput>#application.basePath#</cfoutput>/auth/simple-auth.cfm" method="POST">
                            <div class="mb-3">
                                <label class="form-label">Email Address</label>
                                <input type="email" class="form-control" name="email" required 
                                       placeholder="your.email@gmail.com">
                                <small class="text-muted">Use your Gmail or any email address</small>
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label">Your Name</label>
                                <input type="text" class="form-control" name="displayName" required 
                                       placeholder="John Doe">
                            </div>
                            
                            <button type="submit" class="btn btn-primary w-100">
                                <i class="fas fa-sign-in-alt"></i> Sign In
                            </button>
                        </form>
                        
                        <hr class="my-4">
                        
                        <div class="text-center">
                            <p class="text-muted mb-0">
                                <small>This is a simplified login for testing. In production, Google OAuth will be properly configured.</small>
                            </p>
                            <a href="<cfoutput>#application.basePath#</cfoutput>/" class="btn btn-link">
                                <i class="fas fa-arrow-left"></i> Back to Home
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>