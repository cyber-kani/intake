-- ============================================================
-- MSSQL Table Creation Script for Customer Intake System
-- ============================================================
-- This script creates all necessary tables for the application
-- 
-- Usage:
-- sqlcmd -S servername -U sa -P password -d clitools -i 02-create-tables.sql
-- OR run in SQL Server Management Studio
-- ============================================================

USE clitools;
GO

-- ============================================================
-- Table: Users
-- Purpose: Store user authentication and profile information
-- ============================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Users]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[Users] (
        [id] INT IDENTITY(1,1) PRIMARY KEY,
        [google_id] NVARCHAR(255) UNIQUE,
        [email] NVARCHAR(255) UNIQUE NOT NULL,
        [display_name] NVARCHAR(255),
        [profile_picture] NVARCHAR(MAX),
        [username] NVARCHAR(100) UNIQUE,
        [password] NVARCHAR(255),
        [created_at] DATETIME DEFAULT GETDATE(),
        [updated_at] DATETIME DEFAULT GETDATE(),
        [last_login] DATETIME NULL,
        [is_active] BIT DEFAULT 1
    );
    
    CREATE INDEX IX_Users_Email ON [Users]([email]);
    CREATE INDEX IX_Users_GoogleId ON [Users]([google_id]);
    CREATE INDEX IX_Users_Username ON [Users]([username]);
    
    PRINT 'Table Users created successfully.';
END
ELSE
BEGIN
    PRINT 'Table Users already exists.';
END
GO

-- ============================================================
-- Table: IntakeForms
-- Purpose: Store customer intake form submissions
-- ============================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[IntakeForms]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[IntakeForms] (
        [id] INT IDENTITY(1,1) PRIMARY KEY,
        [user_id] INT,
        [reference_id] NVARCHAR(20) UNIQUE,
        
        -- Customer Information
        [customer_name] NVARCHAR(255) NOT NULL,
        [business_name] NVARCHAR(255),
        [email] NVARCHAR(255) NOT NULL,
        [phone] NVARCHAR(50),
        
        -- Project Information
        [project_type] NVARCHAR(50),
        [service_category] NVARCHAR(100),
        [service_type] NVARCHAR(100),
        [project_description] NVARCHAR(MAX),
        
        -- Budget and Timeline
        [budget_range] NVARCHAR(50),
        [timeline] NVARCHAR(100),
        [start_date] DATE,
        
        -- Technical Requirements
        [features_required] NVARCHAR(MAX),
        [target_audience] NVARCHAR(MAX),
        [competitors] NVARCHAR(MAX),
        [special_requirements] NVARCHAR(MAX),
        
        -- Additional Information
        [has_existing_site] BIT DEFAULT 0,
        [existing_site_url] NVARCHAR(500),
        [has_branding] BIT DEFAULT 0,
        [needs_hosting] BIT DEFAULT 0,
        [needs_maintenance] BIT DEFAULT 0,
        
        -- Status and Metadata
        [status] NVARCHAR(20) DEFAULT 'draft' CHECK ([status] IN ('draft', 'submitted', 'in_review', 'approved', 'rejected', 'completed')),
        [is_ai_generated] BIT DEFAULT 0,
        [ai_conversation_id] NVARCHAR(100),
        [source] NVARCHAR(50) DEFAULT 'manual',
        
        -- Timestamps
        [created_at] DATETIME DEFAULT GETDATE(),
        [updated_at] DATETIME DEFAULT GETDATE(),
        [submitted_at] DATETIME NULL,
        
        -- Foreign Key
        CONSTRAINT FK_IntakeForms_User FOREIGN KEY ([user_id]) 
            REFERENCES [Users]([id]) ON DELETE SET NULL
    );
    
    CREATE INDEX IX_IntakeForms_UserId ON [IntakeForms]([user_id]);
    CREATE INDEX IX_IntakeForms_ReferenceId ON [IntakeForms]([reference_id]);
    CREATE INDEX IX_IntakeForms_Status ON [IntakeForms]([status]);
    CREATE INDEX IX_IntakeForms_CreatedAt ON [IntakeForms]([created_at]);
    CREATE INDEX IX_IntakeForms_Email ON [IntakeForms]([email]);
    
    PRINT 'Table IntakeForms created successfully.';
END
ELSE
BEGIN
    PRINT 'Table IntakeForms already exists.';
END
GO

-- ============================================================
-- Table: AppConfig
-- Purpose: Store application configuration and API keys
-- ============================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AppConfig]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[AppConfig] (
        [id] INT IDENTITY(1,1) PRIMARY KEY,
        [config_key] NVARCHAR(100) UNIQUE NOT NULL,
        [config_value] NVARCHAR(MAX),
        [description] NVARCHAR(255),
        [is_encrypted] BIT DEFAULT 0,
        [created_at] DATETIME DEFAULT GETDATE(),
        [updated_at] DATETIME DEFAULT GETDATE()
    );
    
    CREATE INDEX IX_AppConfig_Key ON [AppConfig]([config_key]);
    
    PRINT 'Table AppConfig created successfully.';
END
ELSE
BEGIN
    PRINT 'Table AppConfig already exists.';
END
GO

-- ============================================================
-- Table: ChatSessions
-- Purpose: Store AI chat conversations
-- ============================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ChatSessions]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[ChatSessions] (
        [id] INT IDENTITY(1,1) PRIMARY KEY,
        [session_id] NVARCHAR(100) UNIQUE NOT NULL,
        [user_id] INT,
        [form_id] INT,
        [messages] NVARCHAR(MAX), -- JSON stored as string
        [context] NVARCHAR(MAX), -- JSON stored as string
        [status] NVARCHAR(20) DEFAULT 'active' CHECK ([status] IN ('active', 'completed', 'abandoned')),
        [started_at] DATETIME DEFAULT GETDATE(),
        [ended_at] DATETIME NULL,
        
        CONSTRAINT FK_ChatSessions_User FOREIGN KEY ([user_id]) 
            REFERENCES [Users]([id]) ON DELETE SET NULL,
        CONSTRAINT FK_ChatSessions_Form FOREIGN KEY ([form_id]) 
            REFERENCES [IntakeForms]([id]) ON DELETE CASCADE
    );
    
    CREATE INDEX IX_ChatSessions_SessionId ON [ChatSessions]([session_id]);
    CREATE INDEX IX_ChatSessions_UserId ON [ChatSessions]([user_id]);
    CREATE INDEX IX_ChatSessions_FormId ON [ChatSessions]([form_id]);
    CREATE INDEX IX_ChatSessions_Status ON [ChatSessions]([status]);
    
    PRINT 'Table ChatSessions created successfully.';
END
ELSE
BEGIN
    PRINT 'Table ChatSessions already exists.';
END
GO

-- ============================================================
-- Table: FormAttachments
-- Purpose: Store file attachments for intake forms
-- ============================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FormAttachments]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[FormAttachments] (
        [id] INT IDENTITY(1,1) PRIMARY KEY,
        [form_id] INT NOT NULL,
        [file_name] NVARCHAR(255) NOT NULL,
        [file_path] NVARCHAR(500) NOT NULL,
        [file_type] NVARCHAR(100),
        [file_size] INT,
        [uploaded_at] DATETIME DEFAULT GETDATE(),
        
        CONSTRAINT FK_FormAttachments_Form FOREIGN KEY ([form_id]) 
            REFERENCES [IntakeForms]([id]) ON DELETE CASCADE
    );
    
    CREATE INDEX IX_FormAttachments_FormId ON [FormAttachments]([form_id]);
    
    PRINT 'Table FormAttachments created successfully.';
END
ELSE
BEGIN
    PRINT 'Table FormAttachments already exists.';
END
GO

-- ============================================================
-- Table: ActivityLogs
-- Purpose: Track user activities and system events
-- ============================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ActivityLogs]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[ActivityLogs] (
        [id] INT IDENTITY(1,1) PRIMARY KEY,
        [user_id] INT,
        [action] NVARCHAR(100) NOT NULL,
        [entity_type] NVARCHAR(50),
        [entity_id] INT,
        [details] NVARCHAR(MAX), -- JSON stored as string
        [ip_address] NVARCHAR(45),
        [user_agent] NVARCHAR(MAX),
        [created_at] DATETIME DEFAULT GETDATE(),
        
        CONSTRAINT FK_ActivityLogs_User FOREIGN KEY ([user_id]) 
            REFERENCES [Users]([id]) ON DELETE SET NULL
    );
    
    CREATE INDEX IX_ActivityLogs_UserId ON [ActivityLogs]([user_id]);
    CREATE INDEX IX_ActivityLogs_Action ON [ActivityLogs]([action]);
    CREATE INDEX IX_ActivityLogs_Entity ON [ActivityLogs]([entity_type], [entity_id]);
    CREATE INDEX IX_ActivityLogs_CreatedAt ON [ActivityLogs]([created_at]);
    
    PRINT 'Table ActivityLogs created successfully.';
END
ELSE
BEGIN
    PRINT 'Table ActivityLogs already exists.';
END
GO

-- ============================================================
-- Stored Procedures
-- ============================================================

-- Drop existing procedures if they exist
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetConfigValue]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[GetConfigValue];
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SetConfigValue]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[SetConfigValue];
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GenerateReferenceId]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[GenerateReferenceId];
GO

-- Procedure: GetConfigValue
-- Purpose: Retrieve a configuration value by key
CREATE PROCEDURE [dbo].[GetConfigValue]
    @Key NVARCHAR(100)
AS
BEGIN
    SELECT TOP 1 config_value 
    FROM AppConfig 
    WHERE config_key = @Key;
END
GO

-- Procedure: SetConfigValue
-- Purpose: Set or update a configuration value
CREATE PROCEDURE [dbo].[SetConfigValue]
    @Key NVARCHAR(100),
    @Value NVARCHAR(MAX),
    @Description NVARCHAR(255) = NULL
AS
BEGIN
    IF EXISTS (SELECT 1 FROM AppConfig WHERE config_key = @Key)
    BEGIN
        UPDATE AppConfig 
        SET config_value = @Value,
            updated_at = GETDATE()
        WHERE config_key = @Key;
    END
    ELSE
    BEGIN
        INSERT INTO AppConfig (config_key, config_value, description)
        VALUES (@Key, @Value, @Description);
    END
END
GO

-- Procedure: GenerateReferenceId
-- Purpose: Generate a unique reference ID for forms
CREATE PROCEDURE [dbo].[GenerateReferenceId]
AS
BEGIN
    DECLARE @NewRef NVARCHAR(20);
    DECLARE @RefExists INT = 1;
    DECLARE @Counter INT = 0;
    
    WHILE @RefExists > 0 AND @Counter < 100
    BEGIN
        SET @NewRef = CONCAT('CLI-', 
            YEAR(GETDATE()), 
            RIGHT('0' + CAST(MONTH(GETDATE()) AS NVARCHAR(2)), 2),
            '-',
            RIGHT('0000' + CAST(ABS(CHECKSUM(NEWID())) % 10000 AS NVARCHAR(4)), 4)
        );
        
        SELECT @RefExists = COUNT(*) 
        FROM IntakeForms 
        WHERE reference_id = @NewRef;
        
        SET @Counter = @Counter + 1;
    END
    
    SELECT @NewRef AS reference_id;
END
GO

-- ============================================================
-- Views
-- ============================================================

-- Drop existing views if they exist
IF EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[RecentForms]'))
    DROP VIEW [dbo].[RecentForms];
GO

IF EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[ConfigStatus]'))
    DROP VIEW [dbo].[ConfigStatus];
GO

-- View: RecentForms
-- Purpose: Show recent form submissions with user details
CREATE VIEW [dbo].[RecentForms] AS
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
LEFT JOIN Users u ON f.user_id = u.id;
GO

-- View: ConfigStatus
-- Purpose: Show configuration status without sensitive values
CREATE VIEW [dbo].[ConfigStatus] AS
SELECT 
    config_key,
    CASE 
        WHEN LEN(config_value) > 0 THEN 'SET' 
        ELSE 'NOT SET' 
    END AS status,
    description,
    updated_at
FROM AppConfig;
GO

-- ============================================================
-- Create Update Trigger for updated_at columns
-- ============================================================

-- Trigger for Users table
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TR_Users_UpdatedAt]'))
    DROP TRIGGER [dbo].[TR_Users_UpdatedAt];
GO

CREATE TRIGGER [dbo].[TR_Users_UpdatedAt]
ON [dbo].[Users]
AFTER UPDATE
AS
BEGIN
    UPDATE Users
    SET updated_at = GETDATE()
    FROM Users u
    INNER JOIN inserted i ON u.id = i.id;
END
GO

-- Trigger for IntakeForms table
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TR_IntakeForms_UpdatedAt]'))
    DROP TRIGGER [dbo].[TR_IntakeForms_UpdatedAt];
GO

CREATE TRIGGER [dbo].[TR_IntakeForms_UpdatedAt]
ON [dbo].[IntakeForms]
AFTER UPDATE
AS
BEGIN
    UPDATE IntakeForms
    SET updated_at = GETDATE()
    FROM IntakeForms f
    INNER JOIN inserted i ON f.id = i.id;
END
GO

-- Trigger for AppConfig table
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TR_AppConfig_UpdatedAt]'))
    DROP TRIGGER [dbo].[TR_AppConfig_UpdatedAt];
GO

CREATE TRIGGER [dbo].[TR_AppConfig_UpdatedAt]
ON [dbo].[AppConfig]
AFTER UPDATE
AS
BEGIN
    UPDATE AppConfig
    SET updated_at = GETDATE()
    FROM AppConfig c
    INNER JOIN inserted i ON c.id = i.id;
END
GO

-- ============================================================
-- Display confirmation
-- ============================================================
PRINT '==========================================';
PRINT 'All tables and database objects created successfully!';
PRINT '==========================================';
PRINT '';
PRINT 'Tables created:';
PRINT '  - Users';
PRINT '  - IntakeForms';
PRINT '  - AppConfig';
PRINT '  - ChatSessions';
PRINT '  - FormAttachments';
PRINT '  - ActivityLogs';
PRINT '';
PRINT 'Stored Procedures created:';
PRINT '  - GetConfigValue';
PRINT '  - SetConfigValue';
PRINT '  - GenerateReferenceId';
PRINT '';
PRINT 'Views created:';
PRINT '  - RecentForms';
PRINT '  - ConfigStatus';
PRINT '==========================================';
GO