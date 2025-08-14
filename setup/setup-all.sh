#!/bin/bash

# ============================================================
# Complete Database Setup Script for Customer Intake System
# ============================================================
# This script runs all SQL files in sequence to set up the database
# 
# Usage: ./setup-all.sh
# ============================================================

echo "============================================"
echo "Customer Intake System - Database Setup"
echo "============================================"
echo ""

# Check if MySQL is available
if ! command -v mysql &> /dev/null; then
    echo "Error: MySQL client is not installed or not in PATH"
    exit 1
fi

# Prompt for MySQL credentials
read -p "Enter MySQL username (default: root): " DB_USER
DB_USER=${DB_USER:-root}

echo "Enter MySQL password for user '$DB_USER':"
read -s DB_PASS
echo ""

# Test connection
echo "Testing MySQL connection..."
mysql -u "$DB_USER" -p"$DB_PASS" -e "SELECT 1" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Error: Unable to connect to MySQL. Please check your credentials."
    exit 1
fi

echo "✓ Connection successful"
echo ""

# Step 1: Create Database
echo "Step 1: Creating database..."
mysql -u "$DB_USER" -p"$DB_PASS" < 01-create-database.sql
if [ $? -eq 0 ]; then
    echo "✓ Database created successfully"
else
    echo "✗ Error creating database"
    exit 1
fi
echo ""

# Step 2: Create Tables
echo "Step 2: Creating tables..."
mysql -u "$DB_USER" -p"$DB_PASS" clitools < 02-create-tables.sql
if [ $? -eq 0 ]; then
    echo "✓ Tables created successfully"
else
    echo "✗ Error creating tables"
    exit 1
fi
echo ""

# Step 3: Load Initial Data
echo "Step 3: Loading initial data..."
mysql -u "$DB_USER" -p"$DB_PASS" clitools < 03-initial-data.sql
if [ $? -eq 0 ]; then
    echo "✓ Initial data loaded successfully"
else
    echo "✗ Error loading initial data"
    exit 1
fi
echo ""

# Verify installation
echo "Verifying installation..."
TABLE_COUNT=$(mysql -u "$DB_USER" -p"$DB_PASS" -s -N -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'clitools'")
echo "✓ Found $TABLE_COUNT tables in database"
echo ""

echo "============================================"
echo "✅ Database setup completed successfully!"
echo "============================================"
echo ""
echo "IMPORTANT NEXT STEPS:"
echo "1. Navigate to /admin/config-manager.cfm to add your API keys"
echo "2. Update admin email addresses in configuration"
echo "3. Change default passwords if sample data was loaded"
echo "4. Test the application at /login.cfm"
echo ""
echo "Configuration can be managed at:"
echo "  https://yourdomain.com/intake/admin/config-manager.cfm"
echo ""
echo "============================================"