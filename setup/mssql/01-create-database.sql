-- ============================================================
-- MSSQL Database Creation Script for Customer Intake System
-- ============================================================
-- Run this script as a SQL Server admin user
-- 
-- Usage:
-- sqlcmd -S servername -U sa -P password -i 01-create-database.sql
-- OR run in SQL Server Management Studio
-- ============================================================

-- Check if database exists and create if not
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'clitools')
BEGIN
    CREATE DATABASE clitools;
    PRINT 'Database clitools created successfully!';
END
ELSE
BEGIN
    PRINT 'Database clitools already exists.';
END
GO

-- Use the database
USE clitools;
GO

-- Optional: Create a login and user for the application
-- Uncomment and modify the following lines if needed
/*
-- Create login if not exists
IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = 'clitools_user')
BEGIN
    CREATE LOGIN clitools_user WITH PASSWORD = 'YourSecurePassword123!';
END
GO

-- Create user for the login
IF NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'clitools_user')
BEGIN
    CREATE USER clitools_user FOR LOGIN clitools_user;
END
GO

-- Grant permissions
ALTER ROLE db_owner ADD MEMBER clitools_user;
GO
*/

PRINT 'Database setup completed!';
GO