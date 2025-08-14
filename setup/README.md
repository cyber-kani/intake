# Database Setup Instructions

## Overview
This directory contains SQL scripts to set up the database for the Customer Intake System.

## Prerequisites
- MySQL 5.7+ or MariaDB 10.3+
- MySQL command-line client or phpMyAdmin
- Database administrator access

## Setup Files

### 1. `01-create-database.sql`
Creates the main database and optional dedicated user.

### 2. `02-create-tables.sql`
Creates all required tables, indexes, stored procedures, and views.

### 3. `03-initial-data.sql`
Populates initial configuration values and optional sample data.

### 4. `setup-all.sh` (Optional)
Bash script to run all SQL files in sequence.

## Installation Steps

### Method 1: Command Line (Recommended)

```bash
# Step 1: Create the database
mysql -u root -p < 01-create-database.sql

# Step 2: Create tables and schema
mysql -u root -p clitools < 02-create-tables.sql

# Step 3: Load initial data
mysql -u root -p clitools < 03-initial-data.sql
```

### Method 2: Using the Setup Script

```bash
# Make the script executable
chmod +x setup-all.sh

# Run the setup
./setup-all.sh
```

### Method 3: phpMyAdmin
1. Log into phpMyAdmin
2. Run each SQL file in order:
   - First: `01-create-database.sql`
   - Second: `02-create-tables.sql`
   - Third: `03-initial-data.sql`

### Method 4: Via Web Interface
1. Navigate to `/setup-config-table.cfm` in your browser
2. This will create the tables and basic structure
3. Use `/admin/config-manager.cfm` to add your API keys

## Post-Installation Configuration

### 1. Add API Keys
After installation, you need to add your API keys:

**Via Admin Interface (Recommended):**
1. Navigate to `/admin/config-manager.cfm`
2. Enter your API keys:
   - Anthropic API Key (from console.anthropic.com)
   - Google Client ID (from console.cloud.google.com)
   - Google Client Secret

**Via SQL:**
```sql
UPDATE AppConfig SET config_value = 'your-api-key-here' 
WHERE config_key = 'ANTHROPIC_API_KEY';

UPDATE AppConfig SET config_value = 'your-client-id' 
WHERE config_key = 'GOOGLE_CLIENT_ID';

UPDATE AppConfig SET config_value = 'your-client-secret' 
WHERE config_key = 'GOOGLE_CLIENT_SECRET';
```

### 2. Update Admin Settings
```sql
-- Update admin email
UPDATE AppConfig SET config_value = 'your-email@example.com' 
WHERE config_key = 'ADMIN_EMAILS';

-- Update system email
UPDATE AppConfig SET config_value = 'noreply@yourdomain.com' 
WHERE config_key = 'FROM_EMAIL';
```

### 3. Change Default Password
If you created the sample admin user:
```sql
UPDATE Users SET password = SHA2('your-new-password', 256) 
WHERE username = 'admin';
```

## Database Schema

### Main Tables
- **Users** - User authentication and profiles
- **IntakeForms** - Customer intake form submissions
- **AppConfig** - Application configuration and API keys
- **ChatSessions** - AI chat conversation history
- **FormAttachments** - File attachments for forms
- **ActivityLogs** - User activity tracking

### Key Features
- UTF8MB4 support for emoji and international characters
- Proper indexes for performance
- Foreign key constraints for data integrity
- Stored procedures for common operations
- Views for simplified data access

## Troubleshooting

### Connection Issues
If you get connection errors:
1. Verify MySQL is running: `systemctl status mysql`
2. Check credentials: `mysql -u root -p`
3. Verify database exists: `SHOW DATABASES;`

### Permission Issues
```sql
-- Grant all privileges to application user
GRANT ALL PRIVILEGES ON clitools.* TO 'your_user'@'localhost';
FLUSH PRIVILEGES;
```

### Character Set Issues
If you see character encoding problems:
```sql
ALTER DATABASE clitools 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;
```

## Backup and Restore

### Create Backup
```bash
mysqldump -u root -p clitools > backup_$(date +%Y%m%d).sql
```

### Restore from Backup
```bash
mysql -u root -p clitools < backup_20240101.sql
```

## Security Notes

1. **Never commit API keys** to version control
2. **Use strong passwords** for database users
3. **Limit database user privileges** to only what's needed
4. **Enable SSL** for remote database connections
5. **Regular backups** are essential

## Support

For issues or questions:
1. Check the `/testing/db-check.cfm` page for connection testing
2. Review application logs for errors
3. Ensure all required tables exist: `SHOW TABLES;`

## Version History

- v2.0.0 - Database-based configuration system
- v1.0.0 - Initial release with file-based configuration