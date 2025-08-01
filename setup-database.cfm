<!DOCTYPE html>
<html>
<head>
    <title>Database Setup</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-5">
        <h2>Database Setup for Customer Intake System</h2>
        
        <cftry>
            <!--- Create Users table --->
            <cfquery datasource="clitools">
                IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Users' AND xtype='U')
                CREATE TABLE Users (
                    user_id INT IDENTITY(1,1) PRIMARY KEY,
                    google_id VARCHAR(255) UNIQUE,
                    email VARCHAR(255) NOT NULL,
                    display_name VARCHAR(255),
                    username VARCHAR(100) UNIQUE,
                    password_hash VARCHAR(255),
                    profile_picture VARCHAR(500),
                    created_at DATETIME DEFAULT GETDATE(),
                    last_login DATETIME
                );
            </cfquery>
            <div class="alert alert-success">✓ Users table created/verified</div>
            
            <!--- Create IntakeForms table --->
            <cfquery datasource="clitools">
                IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='IntakeForms' AND xtype='U')
                CREATE TABLE IntakeForms (
                    form_id INT IDENTITY(1,1) PRIMARY KEY,
                    user_id INT NOT NULL,
                    project_type VARCHAR(50),
                    service_type VARCHAR(100),
                    first_name VARCHAR(100),
                    last_name VARCHAR(100),
                    email VARCHAR(255),
                    phone_number VARCHAR(20),
                    company_name VARCHAR(255),
                    form_data NVARCHAR(MAX),
                    is_finalized BIT DEFAULT 0,
                    created_at DATETIME DEFAULT GETDATE(),
                    updated_at DATETIME DEFAULT GETDATE(),
                    submitted_at DATETIME,
                    FOREIGN KEY (user_id) REFERENCES Users(user_id)
                );
            </cfquery>
            <div class="alert alert-success">✓ IntakeForms table created/verified</div>
            
            <!--- Create indexes --->
            <cfquery datasource="clitools">
                IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_user_forms')
                CREATE INDEX idx_user_forms ON IntakeForms(user_id, is_finalized);
            </cfquery>
            <div class="alert alert-success">✓ Index idx_user_forms created/verified</div>
            
            <cfquery datasource="clitools">
                IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_form_dates')
                CREATE INDEX idx_form_dates ON IntakeForms(created_at DESC);
            </cfquery>
            <div class="alert alert-success">✓ Index idx_form_dates created/verified</div>
            
            <div class="alert alert-info mt-4">
                <h5>Database setup completed successfully!</h5>
                <p>The following tables have been created:</p>
                <ul>
                    <li>Users - For storing user accounts</li>
                    <li>IntakeForms - For storing customer intake forms</li>
                </ul>
                <a href="/intake/" class="btn btn-primary mt-3">Go to Application</a>
            </div>
            
            <cfcatch>
                <div class="alert alert-danger">
                    <h5>Error setting up database:</h5>
                    <p><cfoutput>#cfcatch.message#</cfoutput></p>
                    <cfif len(cfcatch.detail)>
                        <p><small><cfoutput>#cfcatch.detail#</cfoutput></small></p>
                    </cfif>
                </div>
            </cfcatch>
        </cftry>
    </div>
</body>
</html>