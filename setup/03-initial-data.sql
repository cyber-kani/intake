-- ============================================================
-- Initial Data Setup for Customer Intake System
-- ============================================================
-- This script populates initial configuration and sample data
-- 
-- Usage:
-- mysql -u root -p clitools < 03-initial-data.sql
-- ============================================================

USE clitools;

-- ============================================================
-- Initial Configuration Values
-- ============================================================
-- IMPORTANT: Update these values with your actual API keys
-- You can also update them later via the admin interface

INSERT INTO AppConfig (config_key, config_value, description, is_encrypted) VALUES 
    ('ANTHROPIC_API_KEY', '', 'Claude/Anthropic API Key - Get from console.anthropic.com', FALSE),
    ('GOOGLE_CLIENT_ID', '', 'Google OAuth Client ID - Get from console.cloud.google.com', FALSE),
    ('GOOGLE_CLIENT_SECRET', '', 'Google OAuth Client Secret', FALSE),
    ('GOOGLE_API_KEY', '', 'Google API Key (optional)', FALSE),
    ('ADMIN_EMAILS', 'admin@example.com', 'Comma-separated list of admin email addresses', FALSE),
    ('FROM_EMAIL', 'noreply@example.com', 'System email sender address', FALSE),
    ('MAIL_SERVER', 'localhost', 'Mail server hostname', FALSE),
    ('MAIL_PORT', '25', 'Mail server port', FALSE),
    ('MAIL_USE_SSL', 'false', 'Use SSL for mail server', FALSE),
    ('MAIL_USERNAME', '', 'Mail server username (if required)', FALSE),
    ('MAIL_PASSWORD', '', 'Mail server password (if required)', FALSE),
    ('APP_NAME', 'Customer Intake System', 'Application name', FALSE),
    ('APP_URL', 'https://clitools.app/intake', 'Application base URL', FALSE),
    ('SESSION_TIMEOUT', '30', 'Session timeout in minutes', FALSE),
    ('MAX_FILE_SIZE', '10485760', 'Maximum file upload size in bytes (10MB)', FALSE),
    ('ALLOWED_FILE_TYPES', 'pdf,doc,docx,xls,xlsx,png,jpg,jpeg,gif', 'Allowed file extensions', FALSE)
ON DUPLICATE KEY UPDATE 
    config_key = VALUES(config_key);

-- ============================================================
-- Sample Admin User (Optional)
-- ============================================================
-- Creates a sample admin user for testing
-- Password: admin123 (you should change this immediately)
-- Note: This uses a simple hash - implement proper password hashing in production

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
    SHA2('admin123', 256), -- Change this password immediately!
    TRUE
) ON DUPLICATE KEY UPDATE 
    email = VALUES(email);

-- ============================================================
-- Sample Intake Form (Optional)
-- ============================================================
-- Creates a sample form for testing

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
) ON DUPLICATE KEY UPDATE 
    reference_id = VALUES(reference_id);

-- ============================================================
-- Display Configuration Status
-- ============================================================
SELECT 
    '===========================================' AS '';
SELECT 'Initial data loaded successfully!' AS Status;
SELECT 
    '===========================================' AS '';

-- Show configuration status
SELECT 'Configuration Status:' AS '';
SELECT 
    config_key AS 'Configuration Key',
    CASE 
        WHEN LENGTH(config_value) > 0 THEN 'SET' 
        ELSE 'NOT SET - Please update via admin interface' 
    END AS 'Status',
    description AS 'Description'
FROM AppConfig
WHERE config_key IN ('ANTHROPIC_API_KEY', 'GOOGLE_CLIENT_ID', 'GOOGLE_CLIENT_SECRET')
ORDER BY config_key;

SELECT 
    '===========================================' AS '';
SELECT 'IMPORTANT NEXT STEPS:' AS '';
SELECT '1. Update API keys via /admin/config-manager.cfm' AS '';
SELECT '2. Change the default admin password' AS '';
SELECT '3. Update admin email addresses' AS '';
SELECT '4. Configure mail server settings' AS '';
SELECT 
    '===========================================' AS '';