<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - Customer Intake Form</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-6">
                <div class="card shadow">
                    <div class="card-body p-5">
                        <h2 class="text-center mb-4">Create Account</h2>
                        <p class="text-center text-muted mb-4">Register to create intake forms</p>
                        
                        <form action="<cfoutput>#application.basePath#</cfoutput>/auth/register-user.cfm" method="POST" id="registerForm" novalidate>
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label for="firstName" class="form-label">First Name <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control" id="firstName" name="firstName" required>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label for="lastName" class="form-label">Last Name <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control" id="lastName" name="lastName" required>
                                </div>
                            </div>
                            
                            <div class="mb-3">
                                <label for="email" class="form-label">Email Address <span class="text-danger">*</span></label>
                                <input type="email" class="form-control" id="email" name="email" required>
                                <div class="form-text">We'll use this for important notifications</div>
                            </div>
                            
                            <div class="mb-3">
                                <label for="username" class="form-label">Username <span class="text-danger">*</span></label>
                                <input type="text" class="form-control" id="username" name="username" required 
                                       pattern="[a-zA-Z0-9_]{3,20}" 
                                       title="Username must be 3-20 characters, letters, numbers, and underscores only">
                                <div class="form-text">3-20 characters, letters, numbers, and underscores only</div>
                            </div>
                            
                            <div class="mb-3">
                                <label for="password" class="form-label">Password <span class="text-danger">*</span></label>
                                <input type="password" class="form-control" id="password" name="password" required 
                                       minlength="8"
                                       pattern="(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,}">
                                <div class="form-text">At least 8 characters with uppercase, lowercase, and number</div>
                            </div>
                            
                            <div class="mb-3">
                                <label for="confirmPassword" class="form-label">Confirm Password <span class="text-danger">*</span></label>
                                <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" required>
                            </div>
                            
                            <div class="mb-3">
                                <div class="form-check">
                                    <input class="form-check-input" type="checkbox" id="terms" name="terms" required>
                                    <label class="form-check-label" for="terms">
                                        I agree to the terms and conditions
                                    </label>
                                </div>
                            </div>
                            
                            <div class="d-grid">
                                <button type="submit" class="btn btn-primary">
                                    <i class="fas fa-user-plus"></i> Create Account
                                </button>
                            </div>
                        </form>
                        
                        <hr class="my-4">
                        
                        <div class="text-center">
                            <p class="mb-2">Already have an account? <a href="<cfoutput>#application.basePath#</cfoutput>/login.cfm">Sign in</a></p>
                            <p class="text-muted small">Or continue with Google Sign-In on the login page</p>
                        </div>
                        
                        <cfif structKeyExists(url, "error")>
                            <div class="alert alert-danger mt-3">
                                <cfoutput>#url.error#</cfoutput>
                            </div>
                        </cfif>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!--- Validation Error Modal --->
    <div class="modal fade" id="validationModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header bg-warning text-dark">
                    <h5 class="modal-title">
                        <i class="fas fa-exclamation-triangle"></i> Validation Error
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <p class="mb-3">Please fix the following issues:</p>
                    <ul id="errorList" class="list-unstyled"></ul>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-primary" data-bs-dismiss="modal">OK, I'll fix it</button>
                </div>
            </div>
        </div>
    </div>

    <style>
    .error-item {
        margin-bottom: 10px;
        padding-left: 20px;
    }
    
    .field-error {
        border-color: #dc3545 !important;
        box-shadow: 0 0 0 0.2rem rgba(220, 53, 69, 0.25) !important;
    }
    </style>

    <script>
        // Function to show validation errors
        function showValidationErrors(errors) {
            const errorList = document.getElementById('errorList');
            errorList.innerHTML = '';
            
            errors.forEach(error => {
                const li = document.createElement('li');
                li.className = 'error-item';
                li.innerHTML = `<i class="fas fa-exclamation-circle text-warning me-2"></i>${error}`;
                errorList.appendChild(li);
            });
            
            const modal = new bootstrap.Modal(document.getElementById('validationModal'));
            modal.show();
        }
        
        // Form validation
        document.getElementById('registerForm').addEventListener('submit', function(e) {
            const errors = [];
            const form = this;
            
            // Clear previous error styling
            form.querySelectorAll('.field-error').forEach(field => {
                field.classList.remove('field-error');
            });
            
            // Validate required fields
            const requiredFields = form.querySelectorAll('[required]');
            requiredFields.forEach(field => {
                if (!field.value.trim()) {
                    field.classList.add('field-error');
                    const label = form.querySelector(`label[for="${field.id}"]`);
                    const fieldName = label ? label.textContent.replace('*', '').trim() : field.name;
                    errors.push(`${fieldName} is required`);
                }
            });
            
            // Password validation
            const password = document.getElementById('password').value;
            const confirmPassword = document.getElementById('confirmPassword').value;
            
            if (password && confirmPassword && password !== confirmPassword) {
                document.getElementById('confirmPassword').classList.add('field-error');
                errors.push('Passwords do not match');
            }
            
            // Check password strength
            if (password) {
                const passwordRegex = /^(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,}$/;
                if (!passwordRegex.test(password)) {
                    document.getElementById('password').classList.add('field-error');
                    errors.push('Password must be at least 8 characters long with uppercase, lowercase, and number');
                }
            }
            
            // Username validation
            const username = document.getElementById('username').value;
            if (username) {
                const usernameRegex = /^[a-zA-Z0-9_]{3,20}$/;
                if (!usernameRegex.test(username)) {
                    document.getElementById('username').classList.add('field-error');
                    errors.push('Username must be 3-20 characters (letters, numbers, underscores only)');
                }
            }
            
            // Email validation
            const email = document.getElementById('email').value;
            if (email) {
                const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                if (!emailRegex.test(email)) {
                    document.getElementById('email').classList.add('field-error');
                    errors.push('Please enter a valid email address');
                }
            }
            
            // Terms validation
            const terms = document.getElementById('terms');
            if (!terms.checked) {
                errors.push('You must agree to the terms and conditions');
            }
            
            if (errors.length > 0) {
                e.preventDefault();
                showValidationErrors(errors);
                return false;
            }
        });
        
        // Real-time password match indicator
        document.getElementById('confirmPassword').addEventListener('input', function() {
            const password = document.getElementById('password').value;
            const confirmPassword = this.value;
            
            if (confirmPassword.length > 0) {
                if (password === confirmPassword) {
                    this.classList.remove('is-invalid');
                    this.classList.add('is-valid');
                } else {
                    this.classList.remove('is-valid');
                    this.classList.add('is-invalid');
                }
            } else {
                this.classList.remove('is-valid', 'is-invalid');
            }
        });
    </script>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>