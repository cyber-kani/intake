<!--- Setup configuration table in database --->
<cftry>
    <cfquery datasource="clitools">
        -- Create table for storing application configuration and API keys
        CREATE TABLE IF NOT EXISTS AppConfig (
            id INT PRIMARY KEY AUTO_INCREMENT,
            config_key VARCHAR(100) UNIQUE NOT NULL,
            config_value TEXT,
            description VARCHAR(255),
            is_encrypted BOOLEAN DEFAULT FALSE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            INDEX idx_config_key (config_key)
        )
    </cfquery>
    
    <cfquery datasource="clitools">
        -- Insert default configuration placeholders (you'll need to add your actual keys via the admin interface)
        INSERT INTO AppConfig (config_key, config_value, description, is_encrypted) VALUES 
            ('ANTHROPIC_API_KEY', '', 'Claude/Anthropic API Key', FALSE),
            ('GOOGLE_CLIENT_ID', '', 'Google OAuth Client ID', FALSE),
            ('GOOGLE_CLIENT_SECRET', '', 'Google OAuth Client Secret', FALSE),
            ('GOOGLE_API_KEY', '', 'Google API Key (optional)', FALSE),
            ('ADMIN_EMAILS', 'kanishka@cfnetworks.com', 'Comma-separated list of admin emails', FALSE),
            ('FROM_EMAIL', 'noreply@clitools.app', 'System email sender address', FALSE),
            ('MAIL_SERVER', 'localhost', 'Mail server hostname', FALSE)
        ON DUPLICATE KEY UPDATE 
            config_key = VALUES(config_key)
    </cfquery>
    
    <cfoutput>
        <h2>Configuration Table Setup Complete!</h2>
        <p>The AppConfig table has been created and populated with your API keys.</p>
        
        <h3>Verify Configuration:</h3>
        <cfquery name="qConfig" datasource="clitools">
            SELECT config_key, 
                   CASE 
                       WHEN LENGTH(config_value) > 0 THEN 'SET' 
                       ELSE 'NOT SET' 
                   END as status,
                   description
            FROM AppConfig
            ORDER BY config_key
        </cfquery>
        
        <table border="1" cellpadding="5">
            <tr>
                <th>Configuration Key</th>
                <th>Status</th>
                <th>Description</th>
            </tr>
            <cfloop query="qConfig">
                <tr>
                    <td>#config_key#</td>
                    <td style="color: <cfif status EQ 'SET'>green<cfelse>red</cfif>">#status#</td>
                    <td>#description#</td>
                </tr>
            </cfloop>
        </table>
        
        <p><a href="index.cfm">Go to Home</a> | <a href="admin/config-manager.cfm">Manage Configuration</a></p>
    </cfoutput>
    
    <cfcatch>
        <cfoutput>
            <h2>Error Setting Up Configuration Table</h2>
            <p style="color: red;">#cfcatch.message#</p>
            <p>#cfcatch.detail#</p>
        </cfoutput>
    </cfcatch>
</cftry>