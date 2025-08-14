-- ============================================================
-- Database Creation Script for Customer Intake System
-- ============================================================
-- Run this script as a MySQL root or admin user
-- 
-- Usage:
-- mysql -u root -p < 01-create-database.sql
-- ============================================================

-- Create database if it doesn't exist
CREATE DATABASE IF NOT EXISTS clitools
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- Create a dedicated user for the application (optional)
-- Uncomment and modify the following lines if you want a dedicated user
-- CREATE USER IF NOT EXISTS 'clitools_user'@'localhost' IDENTIFIED BY 'your_secure_password_here';
-- GRANT ALL PRIVILEGES ON clitools.* TO 'clitools_user'@'localhost';
-- FLUSH PRIVILEGES;

-- Use the database for subsequent operations
USE clitools;

-- Display confirmation
SELECT 'Database clitools created successfully!' AS Status;