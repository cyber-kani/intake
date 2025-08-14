<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Client Intake Application - Test Index</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        .test-card {
            transition: transform 0.2s ease-in-out;
            border: 1px solid #dee2e6;
        }
        .test-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }
        .test-icon {
            font-size: 3rem;
            margin-bottom: 1rem;
        }
        .test-description {
            color: #6c757d;
            font-size: 0.95rem;
        }
        .badge-status {
            position: absolute;
            top: 15px;
            right: 15px;
        }
        .quick-stats {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 10px;
            padding: 30px;
            margin-bottom: 30px;
        }
    </style>
</head>
<body>
<div class="container mt-5">
    <div class="row">
        <div class="col-12">
            <h1 class="mb-4 text-center">
                <i class="fas fa-vial text-primary"></i> 
                Client Intake Application - Test Suite
            </h1>
            <p class="lead text-center text-muted mb-5">
                Comprehensive testing tools to verify application functionality, security, and performance
            </p>
        </div>
    </div>
    
    <!--- Quick Statistics --->
    <div class="quick-stats">
        <div class="row text-center">
            <div class="col-md-3">
                <h3><i class="fas fa-check-circle"></i></h3>
                <h4>7 Test Suites</h4>
                <p class="mb-0">Available</p>
            </div>
            <div class="col-md-3">
                <h3><i class="fas fa-database"></i></h3>
                <h4>Database</h4>
                <p class="mb-0">Integrity Checks</p>
            </div>
            <div class="col-md-3">
                <h3><i class="fas fa-shield-alt"></i></h3>
                <h4>Security</h4>
                <p class="mb-0">Vulnerability Scans</p>
            </div>
            <div class="col-md-3">
                <h3><i class="fas fa-cogs"></i></h3>
                <h4>Configuration</h4>
                <p class="mb-0">Validation</p>
            </div>
        </div>
    </div>
    
    <!--- Test Cards Grid --->
    <div class="row">
        <!--- Comprehensive Test Suite --->
        <div class="col-md-6 col-lg-4 mb-4">
            <div class="card test-card h-100 position-relative">
                <span class="badge bg-primary badge-status">Core</span>
                <div class="card-body text-center">
                    <div class="test-icon text-primary">
                        <i class="fas fa-clipboard-check"></i>
                    </div>
                    <h5 class="card-title">Comprehensive Test Suite</h5>
                    <p class="test-description">
                        Complete system test covering application configuration, database connections, 
                        components, session management, and file system integrity.
                    </p>
                    <div class="mt-auto">
                        <a href="test-suite.cfm" class="btn btn-primary">
                            <i class="fas fa-play"></i> Run Tests
                        </a>
                    </div>
                </div>
                <div class="card-footer bg-light">
                    <small class="text-muted">
                        <i class="fas fa-clock"></i> ~30 seconds
                        <span class="float-end">
                            <i class="fas fa-list"></i> 20+ checks
                        </span>
                    </small>
                </div>
            </div>
        </div>
        
        <!--- Database Integrity Checker --->
        <div class="col-md-6 col-lg-4 mb-4">
            <div class="card test-card h-100 position-relative">
                <span class="badge bg-success badge-status">Database</span>
                <div class="card-body text-center">
                    <div class="test-icon text-success">
                        <i class="fas fa-database"></i>
                    </div>
                    <h5 class="card-title">Database Integrity</h5>
                    <p class="test-description">
                        Verify table structures, foreign key relationships, data integrity, 
                        indexes, and identify orphaned records or duplicate data.
                    </p>
                    <div class="mt-auto">
                        <a href="db-check.cfm" class="btn btn-success">
                            <i class="fas fa-search"></i> Check Database
                        </a>
                    </div>
                </div>
                <div class="card-footer bg-light">
                    <small class="text-muted">
                        <i class="fas fa-clock"></i> ~15 seconds
                        <span class="float-end">
                            <i class="fas fa-table"></i> Schema validation
                        </span>
                    </small>
                </div>
            </div>
        </div>
        
        <!--- Security Checker --->
        <div class="col-md-6 col-lg-4 mb-4">
            <div class="card test-card h-100 position-relative">
                <span class="badge bg-warning badge-status">Security</span>
                <div class="card-body text-center">
                    <div class="test-icon text-warning">
                        <i class="fas fa-shield-alt"></i>
                    </div>
                    <h5 class="card-title">Security Checker</h5>
                    <p class="test-description">
                        Scan for SQL injection vulnerabilities, XSS protection, authentication 
                        security, access controls, and API key exposure.
                    </p>
                    <div class="mt-auto">
                        <a href="security-check.cfm" class="btn btn-warning">
                            <i class="fas fa-shield-alt"></i> Security Scan
                        </a>
                    </div>
                </div>
                <div class="card-footer bg-light">
                    <small class="text-muted">
                        <i class="fas fa-clock"></i> ~20 seconds
                        <span class="float-end">
                            <i class="fas fa-bug"></i> Vulnerability scan
                        </span>
                    </small>
                </div>
            </div>
        </div>
        
        <!--- Form Data Validation --->
        <div class="col-md-6 col-lg-4 mb-4">
            <div class="card test-card h-100 position-relative">
                <span class="badge bg-info badge-status">Data</span>
                <div class="card-body text-center">
                    <div class="test-icon text-info">
                        <i class="fas fa-check-double"></i>
                    </div>
                    <h5 class="card-title">Form Data Validation</h5>
                    <p class="test-description">
                        Validate all form entries for data integrity, JSON structure, 
                        required fields, email formats, and reference ID uniqueness.
                    </p>
                    <div class="mt-auto">
                        <a href="validate-forms.cfm" class="btn btn-info">
                            <i class="fas fa-check"></i> Validate Forms
                        </a>
                    </div>
                </div>
                <div class="card-footer bg-light">
                    <small class="text-muted">
                        <i class="fas fa-clock"></i> Variable
                        <span class="float-end">
                            <i class="fas fa-list-alt"></i> Per form analysis
                        </span>
                    </small>
                </div>
            </div>
        </div>
        
        <!--- API Endpoints Test --->
        <div class="col-md-6 col-lg-4 mb-4">
            <div class="card test-card h-100 position-relative">
                <span class="badge bg-danger badge-status">New</span>
                <div class="card-body text-center">
                    <div class="test-icon text-danger">
                        <i class="fas fa-plug"></i>
                    </div>
                    <h5 class="card-title">API Endpoints Test</h5>
                    <p class="test-description">
                        Test all API endpoints including Claude chat, form operations 
                        (save/load/delete), response formats, and security measures.
                    </p>
                    <div class="mt-auto">
                        <a href="api-test.cfm" class="btn btn-danger">
                            <i class="fas fa-code"></i> Test APIs
                        </a>
                    </div>
                </div>
                <div class="card-footer bg-light">
                    <small class="text-muted">
                        <i class="fas fa-clock"></i> ~25 seconds
                        <span class="float-end">
                            <i class="fas fa-network-wired"></i> API analysis
                        </span>
                    </small>
                </div>
            </div>
        </div>
        
        <!--- Configuration Check --->
        <div class="col-md-6 col-lg-4 mb-4">
            <div class="card test-card h-100 position-relative">
                <span class="badge bg-secondary badge-status">New</span>
                <div class="card-body text-center">
                    <div class="test-icon text-secondary">
                        <i class="fas fa-cogs"></i>
                    </div>
                    <h5 class="card-title">Configuration Check</h5>
                    <p class="test-description">
                        Verify all configuration settings including API keys, database 
                        connections, email settings, and security configurations.
                    </p>
                    <div class="mt-auto">
                        <a href="config-check.cfm" class="btn btn-secondary">
                            <i class="fas fa-wrench"></i> Check Config
                        </a>
                    </div>
                </div>
                <div class="card-footer bg-light">
                    <small class="text-muted">
                        <i class="fas fa-clock"></i> ~10 seconds
                        <span class="float-end">
                            <i class="fas fa-key"></i> Settings validation
                        </span>
                    </small>
                </div>
            </div>
        </div>
        
        <!--- Run All Tests --->
        <div class="col-md-6 col-lg-4 mb-4">
            <div class="card test-card h-100 position-relative border-primary">
                <span class="badge bg-primary badge-status">Recommended</span>
                <div class="card-body text-center">
                    <div class="test-icon text-primary">
                        <i class="fas fa-rocket"></i>
                    </div>
                    <h5 class="card-title">Run All Tests</h5>
                    <p class="test-description">
                        Execute all test suites in sequence for a complete system health check. 
                        Best for deployment validation and regular maintenance.
                    </p>
                    <div class="mt-auto">
                        <button class="btn btn-primary btn-lg" onclick="runAllTests()">
                            <i class="fas fa-play-circle"></i> Run All Tests
                        </button>
                    </div>
                </div>
                <div class="card-footer bg-light">
                    <small class="text-muted">
                        <i class="fas fa-clock"></i> ~2 minutes
                        <span class="float-end">
                            <i class="fas fa-chart-line"></i> Full coverage
                        </span>
                    </small>
                </div>
            </div>
        </div>
    </div>
    
    <!--- Test Guidelines --->
    <div class="card mt-5">
        <div class="card-header bg-dark text-white">
            <h4 class="mb-0"><i class="fas fa-info-circle"></i> Testing Guidelines</h4>
        </div>
        <div class="card-body">
            <div class="row">
                <div class="col-md-6">
                    <h5><i class="fas fa-lightbulb text-warning"></i> When to Run Tests</h5>
                    <ul class="list-unstyled">
                        <li><i class="fas fa-arrow-right text-primary"></i> After new deployments</li>
                        <li><i class="fas fa-arrow-right text-primary"></i> Before major releases</li>
                        <li><i class="fas fa-arrow-right text-primary"></i> During troubleshooting</li>
                        <li><i class="fas fa-arrow-right text-primary"></i> Weekly maintenance checks</li>
                        <li><i class="fas fa-arrow-right text-primary"></i> After configuration changes</li>
                    </ul>
                </div>
                <div class="col-md-6">
                    <h5><i class="fas fa-exclamation-triangle text-danger"></i> Important Notes</h5>
                    <ul class="list-unstyled">
                        <li><i class="fas fa-arrow-right text-danger"></i> Tests are read-only and safe</li>
                        <li><i class="fas fa-arrow-right text-danger"></i> No data will be modified</li>
                        <li><i class="fas fa-arrow-right text-danger"></i> Run during low-traffic periods</li>
                        <li><i class="fas fa-arrow-right text-danger"></i> Review failures immediately</li>
                        <li><i class="fas fa-arrow-right text-danger"></i> Keep test results for reference</li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
    
    <!--- System Information --->
    <div class="card mt-4">
        <div class="card-header bg-info text-white">
            <h5 class="mb-0"><i class="fas fa-server"></i> System Information</h5>
        </div>
        <div class="card-body">
            <div class="row">
                <div class="col-md-3">
                    <strong>Application:</strong><br>
                    <span class="text-muted">Client Intake Tool</span>
                </div>
                <div class="col-md-3">
                    <strong>Environment:</strong><br>
                    <span class="text-muted">
                        <cfif structKeyExists(cgi, "server_name")>
                            <cfoutput>#cgi.server_name#</cfoutput>
                        <cfelse>
                            Unknown
                        </cfif>
                    </span>
                </div>
                <div class="col-md-3">
                    <strong>Test Suite Version:</strong><br>
                    <span class="text-muted">v1.0</span>
                </div>
                <div class="col-md-3">
                    <strong>Last Updated:</strong><br>
                    <span class="text-muted"><cfoutput>#dateFormat(now(), "mm/dd/yyyy")#</cfoutput></span>
                </div>
            </div>
        </div>
    </div>
    
    <div class="text-center mt-4 mb-5">
        <a href="../dashboard.cfm" class="btn btn-outline-primary">
            <i class="fas fa-arrow-left"></i> Back to Dashboard
        </a>
    </div>
</div>

<!--- Run All Tests Modal --->
<div class="modal fade" id="runAllModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="fas fa-rocket"></i> Running All Tests</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="text-center">
                    <div class="spinner-border text-primary mb-3" role="status">
                        <span class="visually-hidden">Loading...</span>
                    </div>
                    <p>This will open each test in a new tab. Please wait...</p>
                    <div class="progress">
                        <div class="progress-bar" role="progressbar" style="width: 0%" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100"></div>
                    </div>
                </div>
                <div id="testResults" class="mt-3" style="display: none;">
                    <h6>Tests Launched:</h6>
                    <ul id="testList"></ul>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
function runAllTests() {
    const modal = new bootstrap.Modal(document.getElementById('runAllModal'));
    modal.show();
    
    const tests = [
        { name: 'Comprehensive Test Suite', url: 'test-suite.cfm' },
        { name: 'Database Integrity Check', url: 'db-check.cfm' },
        { name: 'Security Check', url: 'security-check.cfm' },
        { name: 'Form Data Validation', url: 'validate-forms.cfm' },
        { name: 'API Endpoints Test', url: 'api-test.cfm' },
        { name: 'Configuration Check', url: 'config-check.cfm' }
    ];
    
    const progressBar = document.querySelector('.progress-bar');
    const testList = document.getElementById('testList');
    const testResults = document.getElementById('testResults');
    
    let completed = 0;
    
    testResults.style.display = 'block';
    
    tests.forEach((test, index) => {
        setTimeout(() => {
            // Open test in new tab
            window.open(test.url, '_blank');
            
            // Update progress
            completed++;
            const percentage = (completed / tests.length) * 100;
            progressBar.style.width = percentage + '%';
            progressBar.setAttribute('aria-valuenow', percentage);
            
            // Add to results list
            const li = document.createElement('li');
            li.innerHTML = `<i class="fas fa-external-link-alt text-success"></i> ${test.name}`;
            testList.appendChild(li);
            
            // Update modal text when complete
            if (completed === tests.length) {
                setTimeout(() => {
                    document.querySelector('.modal-body p').textContent = 'All tests have been launched in separate tabs. Review each tab for results.';
                    document.querySelector('.spinner-border').style.display = 'none';
                }, 500);
            }
        }, index * 1000); // Stagger opening by 1 second
    });
}
</script>
</body>
</html>