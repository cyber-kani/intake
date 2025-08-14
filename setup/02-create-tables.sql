-- ============================================================
-- Table Creation Script for Customer Intake System
-- ============================================================
-- This script creates all necessary tables for the application
-- 
-- Usage:
-- mysql -u root -p clitools < 02-create-tables.sql
-- ============================================================

USE clitools;

-- ============================================================
-- Table: Users
-- Purpose: Store user authentication and profile information
-- ============================================================
CREATE TABLE IF NOT EXISTS Users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    google_id VARCHAR(255) UNIQUE,
    email VARCHAR(255) UNIQUE NOT NULL,
    display_name VARCHAR(255),
    profile_picture TEXT,
    username VARCHAR(100) UNIQUE,
    password VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    is_active BOOLEAN DEFAULT TRUE,
    INDEX idx_email (email),
    INDEX idx_google_id (google_id),
    INDEX idx_username (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Table: IntakeForms
-- Purpose: Store customer intake form submissions
-- ============================================================
CREATE TABLE IF NOT EXISTS IntakeForms (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    reference_id VARCHAR(20) UNIQUE,
    
    -- Customer Information
    customer_name VARCHAR(255) NOT NULL,
    business_name VARCHAR(255),
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    
    -- Project Information
    project_type VARCHAR(50),
    service_category VARCHAR(100),
    service_type VARCHAR(100),
    project_description TEXT,
    
    -- Budget and Timeline
    budget_range VARCHAR(50),
    timeline VARCHAR(100),
    start_date DATE,
    
    -- Technical Requirements
    features_required TEXT,
    target_audience TEXT,
    competitors TEXT,
    special_requirements TEXT,
    
    -- Additional Information
    has_existing_site BOOLEAN DEFAULT FALSE,
    existing_site_url VARCHAR(500),
    has_branding BOOLEAN DEFAULT FALSE,
    needs_hosting BOOLEAN DEFAULT FALSE,
    needs_maintenance BOOLEAN DEFAULT FALSE,
    
    -- Status and Metadata
    status ENUM('draft', 'submitted', 'in_review', 'approved', 'rejected', 'completed') DEFAULT 'draft',
    is_ai_generated BOOLEAN DEFAULT FALSE,
    ai_conversation_id VARCHAR(100),
    source VARCHAR(50) DEFAULT 'manual',
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    submitted_at TIMESTAMP NULL,
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_reference_id (reference_id),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at),
    INDEX idx_email (email),
    
    -- Foreign Keys
    CONSTRAINT fk_intake_user FOREIGN KEY (user_id) 
        REFERENCES Users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Table: AppConfig
-- Purpose: Store application configuration and API keys
-- ============================================================
CREATE TABLE IF NOT EXISTS AppConfig (
    id INT PRIMARY KEY AUTO_INCREMENT,
    config_key VARCHAR(100) UNIQUE NOT NULL,
    config_value TEXT,
    description VARCHAR(255),
    is_encrypted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_config_key (config_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Table: ChatSessions
-- Purpose: Store AI chat conversations
-- ============================================================
CREATE TABLE IF NOT EXISTS ChatSessions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    session_id VARCHAR(100) UNIQUE NOT NULL,
    user_id INT,
    form_id INT,
    messages JSON,
    context JSON,
    status ENUM('active', 'completed', 'abandoned') DEFAULT 'active',
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMP NULL,
    
    INDEX idx_session_id (session_id),
    INDEX idx_user_id (user_id),
    INDEX idx_form_id (form_id),
    INDEX idx_status (status),
    
    CONSTRAINT fk_chat_user FOREIGN KEY (user_id) 
        REFERENCES Users(id) ON DELETE SET NULL,
    CONSTRAINT fk_chat_form FOREIGN KEY (form_id) 
        REFERENCES IntakeForms(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Table: FormAttachments
-- Purpose: Store file attachments for intake forms
-- ============================================================
CREATE TABLE IF NOT EXISTS FormAttachments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    form_id INT NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_type VARCHAR(100),
    file_size INT,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_form_id (form_id),
    
    CONSTRAINT fk_attachment_form FOREIGN KEY (form_id) 
        REFERENCES IntakeForms(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Table: ActivityLogs
-- Purpose: Track user activities and system events
-- ============================================================
CREATE TABLE IF NOT EXISTS ActivityLogs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50),
    entity_id INT,
    details JSON,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_user_id (user_id),
    INDEX idx_action (action),
    INDEX idx_entity (entity_type, entity_id),
    INDEX idx_created_at (created_at),
    
    CONSTRAINT fk_activity_user FOREIGN KEY (user_id) 
        REFERENCES Users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Stored Procedures
-- ============================================================

DELIMITER //

-- Procedure: GetConfigValue
-- Purpose: Retrieve a configuration value by key
CREATE PROCEDURE IF NOT EXISTS GetConfigValue(IN p_key VARCHAR(100))
BEGIN
    SELECT config_value 
    FROM AppConfig 
    WHERE config_key = p_key 
    LIMIT 1;
END //

-- Procedure: SetConfigValue
-- Purpose: Set or update a configuration value
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

-- Procedure: GenerateReferenceId
-- Purpose: Generate a unique reference ID for forms
CREATE PROCEDURE IF NOT EXISTS GenerateReferenceId()
BEGIN
    DECLARE new_ref VARCHAR(20);
    DECLARE ref_exists INT DEFAULT 1;
    
    WHILE ref_exists > 0 DO
        SET new_ref = CONCAT('CLI-', 
            YEAR(NOW()), 
            LPAD(MONTH(NOW()), 2, '0'),
            '-',
            LPAD(FLOOR(RAND() * 10000), 4, '0')
        );
        
        SELECT COUNT(*) INTO ref_exists 
        FROM IntakeForms 
        WHERE reference_id = new_ref;
    END WHILE;
    
    SELECT new_ref AS reference_id;
END //

DELIMITER ;

-- ============================================================
-- Views
-- ============================================================

-- View: RecentForms
-- Purpose: Show recent form submissions with user details
CREATE OR REPLACE VIEW RecentForms AS
SELECT 
    f.id,
    f.reference_id,
    f.customer_name,
    f.business_name,
    f.email,
    f.project_type,
    f.status,
    f.created_at,
    u.display_name AS submitted_by,
    u.email AS user_email
FROM IntakeForms f
LEFT JOIN Users u ON f.user_id = u.id
ORDER BY f.created_at DESC;

-- View: ConfigStatus
-- Purpose: Show configuration status without sensitive values
CREATE OR REPLACE VIEW ConfigStatus AS
SELECT 
    config_key,
    CASE 
        WHEN LENGTH(config_value) > 0 THEN 'SET' 
        ELSE 'NOT SET' 
    END AS status,
    description,
    updated_at
FROM AppConfig
ORDER BY config_key;

-- ============================================================
-- Display confirmation
-- ============================================================
SELECT 'All tables created successfully!' AS Status;

-- Show created tables
SHOW TABLES;