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
);

-- Insert default configuration values (empty initially)
INSERT INTO AppConfig (config_key, config_value, description, is_encrypted) VALUES 
    ('ANTHROPIC_API_KEY', '', 'Claude/Anthropic API Key', TRUE),
    ('GOOGLE_CLIENT_ID', '', 'Google OAuth Client ID', FALSE),
    ('GOOGLE_CLIENT_SECRET', '', 'Google OAuth Client Secret', TRUE),
    ('GOOGLE_API_KEY', '', 'Google API Key (optional)', TRUE),
    ('ADMIN_EMAILS', 'kanishka@cfnetworks.com', 'Comma-separated list of admin emails', FALSE),
    ('FROM_EMAIL', 'noreply@clitools.app', 'System email sender address', FALSE),
    ('MAIL_SERVER', 'localhost', 'Mail server hostname', FALSE)
ON DUPLICATE KEY UPDATE 
    config_key = VALUES(config_key);

-- Create stored procedure to get config value
DELIMITER //
CREATE PROCEDURE IF NOT EXISTS GetConfigValue(IN p_key VARCHAR(100))
BEGIN
    SELECT config_value FROM AppConfig WHERE config_key = p_key LIMIT 1;
END //
DELIMITER ;

-- Create stored procedure to set config value
DELIMITER //
CREATE PROCEDURE IF NOT EXISTS SetConfigValue(
    IN p_key VARCHAR(100), 
    IN p_value TEXT,
    IN p_description VARCHAR(255)
)
BEGIN
    INSERT INTO AppConfig (config_key, config_value, description) 
    VALUES (p_key, p_value, p_description)
    ON DUPLICATE KEY UPDATE 
        config_value = VALUES(config_value),
        updated_at = CURRENT_TIMESTAMP;
END //
DELIMITER ;