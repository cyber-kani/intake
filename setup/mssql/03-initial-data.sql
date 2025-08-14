-- ============================================================
-- MSSQL Initial Data Setup for Customer Intake System
-- ============================================================
-- This script populates initial configuration and sample data
-- 
-- Usage:
-- sqlcmd -S servername -U sa -P password -d clitools -i 03-initial-data.sql
-- OR run in SQL Server Management Studio
-- ============================================================

USE clitools;
GO

-- ============================================================
-- Initial Configuration Values
-- ============================================================
-- IMPORTANT: Update these values with your actual API keys
-- You can also update them later via the admin interface

-- Delete existing config if needed (for re-runs)
DELETE FROM AppConfig WHERE config_key IN (
    'ANTHROPIC_API_KEY',
    'GOOGLE_CLIENT_ID', 
    'GOOGLE_CLIENT_SECRET',
    'GOOGLE_API_KEY',
    'ADMIN_EMAILS',
    'FROM_EMAIL',
    'MAIL_SERVER',
    'MAIL_PORT',
    'MAIL_USE_SSL',
    'MAIL_USERNAME',
    'MAIL_PASSWORD',
    'APP_NAME',
    'APP_URL',
    'SESSION_TIMEOUT',
    'MAX_FILE_SIZE',
    'ALLOWED_FILE_TYPES'
);
GO

-- Insert configuration values
INSERT INTO AppConfig (config_key, config_value, description, is_encrypted) VALUES 
    ('ANTHROPIC_API_KEY', '', 'Claude/Anthropic API Key - Get from console.anthropic.com', 0),
    ('GOOGLE_CLIENT_ID', '', 'Google OAuth Client ID - Get from console.cloud.google.com', 0),
    ('GOOGLE_CLIENT_SECRET', '', 'Google OAuth Client Secret', 0),
    ('GOOGLE_API_KEY', '', 'Google API Key (optional)', 0),
    ('ADMIN_EMAILS', 'admin@example.com', 'Comma-separated list of admin email addresses', 0),
    ('FROM_EMAIL', 'noreply@example.com', 'System email sender address', 0),
    ('MAIL_SERVER', 'localhost', 'Mail server hostname', 0),
    ('MAIL_PORT', '25', 'Mail server port', 0),
    ('MAIL_USE_SSL', 'false', 'Use SSL for mail server', 0),
    ('MAIL_USERNAME', '', 'Mail server username (if required)', 0),
    ('MAIL_PASSWORD', '', 'Mail server password (if required)', 0),
    ('APP_NAME', 'Customer Intake System', 'Application name', 0),
    ('APP_URL', 'https://clitools.app/intake', 'Application base URL', 0),
    ('SESSION_TIMEOUT', '30', 'Session timeout in minutes', 0),
    ('MAX_FILE_SIZE', '10485760', 'Maximum file upload size in bytes (10MB)', 0),
    ('ALLOWED_FILE_TYPES', 'pdf,doc,docx,xls,xlsx,png,jpg,jpeg,gif', 'Allowed file extensions', 0);
GO

-- ============================================================
-- Sample Admin User (Optional)
-- ============================================================
-- Creates a sample admin user for testing
-- Password: admin123 (you should change this immediately)
-- Note: Using HASHBYTES for password hashing - implement proper hashing in production

IF NOT EXISTS (SELECT 1 FROM Users WHERE email = 'admin@example.com')
BEGIN
    INSERT INTO Users (
        email, 
        display_name, 
        username, 
        password,
        is_active
    ) VALUES (
        'admin@example.com',
        'System Administrator',
        'admin',
        CONVERT(NVARCHAR(255), HASHBYTES('SHA2_256', 'admin123'), 2), -- Change this password immediately!
        1
    );
    PRINT 'Sample admin user created (username: admin, password: admin123)';
END
ELSE
BEGIN
    PRINT 'Admin user already exists';
END
GO

-- ============================================================
-- Sample Intake Form (Optional)
-- ============================================================
-- Creates a sample form for testing

IF NOT EXISTS (SELECT 1 FROM IntakeForms WHERE reference_id = 'CLI-2024-SAMPLE')
BEGIN
    INSERT INTO IntakeForms (
        reference_id,
        customer_name,
        business_name,
        email,
        phone,
        project_type,
        service_category,
        service_type,
        project_description,
        budget_range,
        timeline,
        features_required,
        target_audience,
        status,
        source
    ) VALUES (
        'CLI-2024-SAMPLE',
        'John Doe',
        'Sample Business Inc.',
        'john@example.com',
        '555-0123',
        'website',
        'business_corporate',
        'small_business',
        'This is a sample intake form for demonstration purposes.',
        '$5,000 - $10,000',
        '2-3 months',
        'Responsive design, Contact forms, SEO optimization',
        'Small business owners and entrepreneurs',
        'draft',
        'manual'
    );
    PRINT 'Sample intake form created';
END
ELSE
BEGIN
    PRINT 'Sample intake form already exists';
END
GO

-- ============================================================
-- Display Configuration Status
-- ============================================================
PRINT '';
PRINT '===========================================';
PRINT 'Initial data loaded successfully!';
PRINT '===========================================';
PRINT '';

-- Show configuration status
PRINT 'Configuration Status:';
SELECT 
    config_key AS 'Configuration Key',
    CASE 
        WHEN LEN(config_value) > 0 THEN 'SET' 
        ELSE 'NOT SET - Please update via admin interface' 
    END AS 'Status',
    description AS 'Description'
FROM AppConfig
WHERE config_key IN ('ANTHROPIC_API_KEY', 'GOOGLE_CLIENT_ID', 'GOOGLE_CLIENT_SECRET')
ORDER BY config_key;
GO

PRINT '';
PRINT '===========================================';
PRINT 'IMPORTANT NEXT STEPS:';
PRINT '1. Update API keys via /admin/config-manager.cfm';
PRINT '2. Change the default admin password';
PRINT '3. Update admin email addresses';
PRINT '4. Configure mail server settings';
PRINT '===========================================';
GO