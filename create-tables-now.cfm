<!--- Create tables immediately without checking --->
<cftry>
    <!--- First try to create Users table --->
    <cfquery datasource="clitools">
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
        )
    </cfquery>
    <cfoutput>Users table created successfully.<br></cfoutput>
    <cfcatch>
        <cfoutput>Users table already exists or error: #cfcatch.message#<br></cfoutput>
    </cfcatch>
</cftry>

<cftry>
    <!--- Create IntakeForms table --->
    <cfquery datasource="clitools">
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
        )
    </cfquery>
    <cfoutput>IntakeForms table created successfully.<br></cfoutput>
    <cfcatch>
        <cfoutput>IntakeForms table error: #cfcatch.message#<br></cfoutput>
    </cfcatch>
</cftry>

<p><a href="/intake/">Go to Application</a></p>