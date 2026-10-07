# MySQL Database Setup Guide (phpMyAdmin)

This guide shows you how to set up the MySQL database **externally** using phpMyAdmin, then connect it to your Python Flask backend.

---

## Overview

The system uses **15 tables** with:
- Workflow state machine for expense requests
- Separation of duties enforcement
- Audit logging with MySQL triggers
- Support for advances, reconciliations, and income receipts

---

## Part 1: Setting Up MySQL Database in phpMyAdmin

### Step 1: Access phpMyAdmin

1. Open your web browser
2. Go to: `http://localhost/phpmyadmin` (or your server's phpMyAdmin URL)
3. Login with your MySQL root credentials

### Step 2: Create Database

1. Click on **"Databases"** tab at the top
2. In the "Create database" section:
   - Database name: `milestone_expense_db`
   - Collation: `utf8mb4_general_ci`
3. Click **"Create"**

### Step 3: Create Database User

1. Click on **"User accounts"** tab at the top
2. Click **"Add user account"**
3. Fill in the details:
   - **User name**: `milestone_user`
   - **Host name**: Select "Local" (localhost)
   - **Password**: Choose a strong password (e.g., `Milestone@2026!`)
   - **Re-type**: Enter the same password
4. In the "Database for user account" section:
   - Check: **"Grant all privileges on database `milestone_expense_db`"**
5. Click **"Go"** at the bottom

### Step 4: Import Database Schema

1. Click on **"Databases"** tab
2. Click on `milestone_expense_db` database name
3. Click on **"SQL"** tab at the top
4. Copy the entire contents of the file `database_schema.sql` (see below)
5. Paste it into the SQL text box
6. Click **"Go"** at the bottom

The database will now create all 15 tables with relationships, indexes, and triggers.

---

## Part 2: SQL Schema for phpMyAdmin

Save this as `database_schema.sql` and use it in phpMyAdmin:

```sql
-- =====================================================
-- Milestone EdTech Expense Control System
-- MySQL Database Schema
-- =====================================================

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

-- =====================================================
-- TABLE: users
-- =====================================================
CREATE TABLE IF NOT EXISTS `users` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `email` VARCHAR(120) NOT NULL UNIQUE,
  `password_hash` VARCHAR(255) NOT NULL,
  `full_name` VARCHAR(100) NOT NULL,
  `role` VARCHAR(50) NOT NULL,
  `is_active` BOOLEAN DEFAULT TRUE,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_role (`role`),
  INDEX idx_email (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =====================================================
-- TABLE: projects
-- =====================================================
CREATE TABLE IF NOT EXISTS `projects` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `code` VARCHAR(20) NOT NULL UNIQUE,
  `name` VARCHAR(200) NOT NULL,
  `description` TEXT,
  `budget` DECIMAL(14,2),
  `currency` VARCHAR(3) DEFAULT 'USD',
  `start_date` DATE,
  `end_date` DATE,
  `is_active` BOOLEAN DEFAULT TRUE,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_code (`code`),
  INDEX idx_active (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =====================================================
-- TABLE: expense_categories
-- =====================================================
CREATE TABLE IF NOT EXISTS `expense_categories` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `code` VARCHAR(20) NOT NULL UNIQUE,
  `name` VARCHAR(100) NOT NULL,
  `description` TEXT,
  `is_active` BOOLEAN DEFAULT TRUE,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_code (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =====================================================
-- TABLE: expense_requests
-- =====================================================
CREATE TABLE IF NOT EXISTS `expense_requests` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `request_id` VARCHAR(50) NOT NULL UNIQUE,
  `project_id` INT NOT NULL,
  `requester_id` INT NOT NULL,
  `request_date` DATE NOT NULL,
  `purpose` TEXT NOT NULL,
  `payee_name` VARCHAR(200) NOT NULL,
  `payment_method` VARCHAR(50) NOT NULL,
  `currency` VARCHAR(3) NOT NULL DEFAULT 'USD',
  `total_amount` DECIMAL(14,2) NOT NULL,
  `exchange_rate_to_usd` DECIMAL(10,6) DEFAULT 1.000000,
  `total_amount_usd` DECIMAL(14,2) NOT NULL,
  `status` VARCHAR(50) NOT NULL DEFAULT 'Submitted',
  `verified_by_id` INT,
  `verified_at` DATETIME,
  `approved_by_id` INT,
  `approved_at` DATETIME,
  `paid_by_id` INT,
  `paid_at` DATETIME,
  `payment_reference` VARCHAR(100),
  `actual_amount_paid` DECIMAL(14,2),
  `posted_by_id` INT,
  `posted_at` DATETIME,
  `ledger_reference` VARCHAR(100),
  `closed_by_id` INT,
  `closed_at` DATETIME,
  `is_split_purchase` BOOLEAN DEFAULT FALSE,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`project_id`) REFERENCES `projects`(`id`) ON DELETE RESTRICT,
  FOREIGN KEY (`requester_id`) REFERENCES `users`(`id`) ON DELETE RESTRICT,
  FOREIGN KEY (`verified_by_id`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  FOREIGN KEY (`approved_by_id`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  FOREIGN KEY (`paid_by_id`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  FOREIGN KEY (`posted_by_id`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  FOREIGN KEY (`closed_by_id`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  INDEX idx_request_id (`request_id`),
  INDEX idx_status (`status`),
  INDEX idx_requester (`requester_id`),
  INDEX idx_project (`project_id`),
  INDEX idx_request_date (`request_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =====================================================
-- TABLE: request_items
-- =====================================================
CREATE TABLE IF NOT EXISTS `request_items` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `request_id` INT NOT NULL,
  `category_id` INT NOT NULL,
  `description` TEXT NOT NULL,
  `quantity` DECIMAL(10,2) NOT NULL,
  `unit_price` DECIMAL(14,2) NOT NULL,
  `total_price` DECIMAL(14,2) NOT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`request_id`) REFERENCES `expense_requests`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`category_id`) REFERENCES `expense_categories`(`id`) ON DELETE RESTRICT,
  INDEX idx_request (`request_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =====================================================
-- TABLE: attachments
-- =====================================================
CREATE TABLE IF NOT EXISTS `attachments` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `request_id` INT NOT NULL,
  `file_type` VARCHAR(50) NOT NULL,
  `file_name` VARCHAR(255) NOT NULL,
  `file_path` VARCHAR(500) NOT NULL,
  `file_size` INT NOT NULL,
  `uploaded_by_id` INT NOT NULL,
  `uploaded_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`request_id`) REFERENCES `expense_requests`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`uploaded_by_id`) REFERENCES `users`(`id`) ON DELETE RESTRICT,
  INDEX idx_request (`request_id`),
  INDEX idx_file_type (`file_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =====================================================
-- TABLE: approvals
-- =====================================================
CREATE TABLE IF NOT EXISTS `approvals` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `request_id` INT NOT NULL,
  `approver_id` INT NOT NULL,
  `action` VARCHAR(20) NOT NULL,
  `notes` TEXT,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`request_id`) REFERENCES `expense_requests`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`approver_id`) REFERENCES `users`(`id`) ON DELETE RESTRICT,
  INDEX idx_request (`request_id`),
  INDEX idx_approver (`approver_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =====================================================
-- TABLE: payments
-- =====================================================
CREATE TABLE IF NOT EXISTS `payments` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `request_id` INT NOT NULL,
  `payment_reference` VARCHAR(100) NOT NULL,
  `amount_paid` DECIMAL(14,2) NOT NULL,
  `payment_date` DATE NOT NULL,
  `notes` TEXT,
  `paid_by_id` INT NOT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`request_id`) REFERENCES `expense_requests`(`id`) ON DELETE RESTRICT,
  FOREIGN KEY (`paid_by_id`) REFERENCES `users`(`id`) ON DELETE RESTRICT,
  INDEX idx_request (`request_id`),
  INDEX idx_payment_date (`payment_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =====================================================
-- TABLE: advances
-- =====================================================
CREATE TABLE IF NOT EXISTS `advances` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `request_id` INT NOT NULL,
  `advance_amount` DECIMAL(14,2) NOT NULL,
  `retirement_deadline` DATE NOT NULL,
  `is_retired` BOOLEAN DEFAULT FALSE,
  `retired_at` DATETIME,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`request_id`) REFERENCES `expense_requests`(`id`) ON DELETE RESTRICT,
  INDEX idx_request (`request_id`),
  INDEX idx_retired (`is_retired`),
  INDEX idx_deadline (`retirement_deadline`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =====================================================
-- TABLE: income_receipts
-- =====================================================
CREATE TABLE IF NOT EXISTS `income_receipts` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `receipt_id` VARCHAR(50) NOT NULL UNIQUE,
  `source` VARCHAR(200) NOT NULL,
  `project_id` INT NOT NULL,
  `description` TEXT NOT NULL,
  `currency` VARCHAR(3) NOT NULL,
  `amount` DECIMAL(14,2) NOT NULL,
  `exchange_rate_to_usd` DECIMAL(10,6) DEFAULT 1.000000,
  `amount_usd` DECIMAL(14,2) NOT NULL,
  `payment_method` VARCHAR(50) NOT NULL,
  `reference_number` VARCHAR(100),
  `receipt_date` DATE NOT NULL,
  `ledger_reference` VARCHAR(100),
  `recorded_by_id` INT NOT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`project_id`) REFERENCES `projects`(`id`) ON DELETE RESTRICT,
  FOREIGN KEY (`recorded_by_id`) REFERENCES `users`(`id`) ON DELETE RESTRICT,
  INDEX idx_receipt_id (`receipt_id`),
  INDEX idx_project (`project_id`),
  INDEX idx_receipt_date (`receipt_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =====================================================
-- TABLE: reconciliations
-- =====================================================
CREATE TABLE IF NOT EXISTS `reconciliations` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `account_type` VARCHAR(50) NOT NULL,
  `account_name` VARCHAR(200) NOT NULL,
  `account_number` VARCHAR(50),
  `period_start` DATE NOT NULL,
  `period_end` DATE NOT NULL,
  `opening_balance` DECIMAL(14,2) NOT NULL,
  `system_closing_balance` DECIMAL(14,2) NOT NULL,
  `actual_closing_balance` DECIMAL(14,2) NOT NULL,
  `difference` DECIMAL(14,2) NOT NULL,
  `status` VARCHAR(20) NOT NULL DEFAULT 'Open',
  `explanation` TEXT,
  `prepared_by_id` INT NOT NULL,
  `prepared_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `reviewed_by_id` INT,
  `reviewed_at` DATETIME,
  FOREIGN KEY (`prepared_by_id`) REFERENCES `users`(`id`) ON DELETE RESTRICT,
  FOREIGN KEY (`reviewed_by_id`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  INDEX idx_account (`account_name`),
  INDEX idx_period (`period_end`),
  INDEX idx_status (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =====================================================
-- TABLE: reconciliation_items
-- =====================================================
CREATE TABLE IF NOT EXISTS `reconciliation_items` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `reconciliation_id` INT NOT NULL,
  `transaction_date` DATE NOT NULL,
  `description` TEXT NOT NULL,
  `reference` VARCHAR(100),
  `debit` DECIMAL(14,2) DEFAULT 0.00,
  `credit` DECIMAL(14,2) DEFAULT 0.00,
  `matched` BOOLEAN DEFAULT FALSE,
  `matched_request_id` INT,
  `matched_receipt_id` INT,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`reconciliation_id`) REFERENCES `reconciliations`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`matched_request_id`) REFERENCES `expense_requests`(`id`) ON DELETE SET NULL,
  FOREIGN KEY (`matched_receipt_id`) REFERENCES `income_receipts`(`id`) ON DELETE SET NULL,
  INDEX idx_reconciliation (`reconciliation_id`),
  INDEX idx_matched (`matched`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =====================================================
-- TABLE: exchange_rates
-- =====================================================
CREATE TABLE IF NOT EXISTS `exchange_rates` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `from_currency` VARCHAR(3) NOT NULL,
  `to_currency` VARCHAR(3) NOT NULL,
  `rate` DECIMAL(10,6) NOT NULL,
  `effective_date` DATE NOT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY unique_rate (`from_currency`, `to_currency`, `effective_date`),
  INDEX idx_currencies (`from_currency`, `to_currency`),
  INDEX idx_effective_date (`effective_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =====================================================
-- TABLE: settings
-- =====================================================
CREATE TABLE IF NOT EXISTS `settings` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `key_name` VARCHAR(100) NOT NULL UNIQUE,
  `value` TEXT NOT NULL,
  `description` TEXT,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_key (`key_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =====================================================
-- TABLE: id_counters
-- =====================================================
CREATE TABLE IF NOT EXISTS `id_counters` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `counter_type` VARCHAR(50) NOT NULL UNIQUE,
  `year` INT NOT NULL,
  `current_value` INT NOT NULL DEFAULT 0,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY unique_counter (`counter_type`, `year`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =====================================================
-- TABLE: audit_log
-- =====================================================
CREATE TABLE IF NOT EXISTS `audit_log` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT,
  `action` VARCHAR(50) NOT NULL,
  `entity_type` VARCHAR(50) NOT NULL,
  `entity_id` INT NOT NULL,
  `note` TEXT,
  `ip_address` VARCHAR(45),
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  INDEX idx_user (`user_id`),
  INDEX idx_entity (`entity_type`, `entity_id`),
  INDEX idx_action (`action`),
  INDEX idx_created (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =====================================================
-- TRIGGERS: Protect audit_log from modifications
-- =====================================================
DELIMITER $$

CREATE TRIGGER prevent_audit_update
BEFORE UPDATE ON audit_log
FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'Audit log records cannot be modified';
END$$

CREATE TRIGGER prevent_audit_delete
BEFORE DELETE ON audit_log
FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'Audit log records cannot be deleted';
END$$

DELIMITER ;

-- =====================================================
-- DEFAULT DATA: Insert initial settings
-- =====================================================
INSERT INTO `settings` (`key_name`, `value`, `description`) VALUES
('approval_threshold_manager', '500', 'Maximum amount (USD) Manager can approve'),
('approval_threshold_director', '2000', 'Maximum amount (USD) Director can approve'),
('approval_threshold_md', '999999', 'Maximum amount (USD) Managing Director can approve'),
('payment_tolerance_percent', '2', 'Allowed variance between approved and actual amount (%)'),
('advance_retirement_days', '30', 'Default days to retire an advance'),
('company_name', 'Milestone EdTech Solutions Ltd', 'Company name for documents'),
('currency_default', 'USD', 'Default currency for transactions');

-- =====================================================
-- DEFAULT DATA: Insert default expense categories
-- =====================================================
INSERT INTO `expense_categories` (`code`, `name`, `description`) VALUES
('TRANS', 'Transport', 'Transportation and travel expenses'),
('UTIL', 'Utilities', 'Electricity, water, internet bills'),
('SUPPLY', 'Supplies', 'Office supplies and materials'),
('EQUIP', 'Equipment', 'Hardware and equipment purchases'),
('SERVICE', 'Services', 'Professional services and consultancy'),
('RENT', 'Rent', 'Office and facility rental'),
('SALARY', 'Salaries', 'Staff salaries and wages'),
('TRAIN', 'Training', 'Staff training and development'),
('MARKET', 'Marketing', 'Marketing and advertising expenses'),
('OTHER', 'Other', 'Miscellaneous expenses');

-- =====================================================
-- DEFAULT DATA: Insert sample exchange rates
-- =====================================================
INSERT INTO `exchange_rates` (`from_currency`, `to_currency`, `rate`, `effective_date`) VALUES
('USD', 'USD', 1.000000, '2026-01-01'),
('KES', 'USD', 0.0078, '2026-01-01'),
('EUR', 'USD', 1.09, '2026-01-01'),
('GBP', 'USD', 1.27, '2026-01-01');

-- =====================================================
-- END OF SCHEMA
-- =====================================================
```

---

## Part 3: Connecting Flask Backend to External MySQL

### How Flask Connects to External MySQL

Flask uses **SQLAlchemy** to connect to external databases. The connection is configured in the `backend/config.py` file using a **connection string**.

### Connection String Format:
```
mysql+pymysql://USERNAME:PASSWORD@HOST:PORT/DATABASE_NAME?charset=utf8mb4
```

### Step 1: Update Your `.env` File

Open `backend/.env` (create it if it doesn't exist) and add:

```bash
# Database Configuration
DB_USER=milestone_user
DB_PASSWORD=Milestone@2026!
DB_HOST=localhost
DB_PORT=3306
DB_NAME=milestone_expense_db

# Flask Configuration
FLASK_APP=run.py
FLASK_ENV=development
SECRET_KEY=your-secret-key-change-in-production
JWT_SECRET_KEY=your-jwt-secret-key-change-in-production

# Upload Configuration
UPLOAD_FOLDER=uploads
MAX_CONTENT_LENGTH=10485760
```

### Step 2: How the Connection Works

The `backend/config.py` file reads these environment variables and creates the connection:

```python
import os
from datetime import timedelta

class Config:
    # Database connection string
    SQLALCHEMY_DATABASE_URI = (
        f"mysql+pymysql://{os.getenv('DB_USER')}:{os.getenv('DB_PASSWORD')}"
        f"@{os.getenv('DB_HOST')}:{os.getenv('DB_PORT')}"
        f"/{os.getenv('DB_NAME')}?charset=utf8mb4"
    )
    # Example result:
    # mysql+pymysql://milestone_user:Milestone@2026!@localhost:3306/milestone_expense_db?charset=utf8mb4
```

### Step 3: Flask Uses This Connection

In `backend/app/__init__.py`, Flask creates the database connection:

```python
from flask import Flask
from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()  # Create database object

def create_app():
    app = Flask(__name__)
    app.config.from_object('config.Config')
    
    db.init_app(app)  # Connect to external MySQL using connection string
    
    return app
```

**This is how Flask connects to your external MySQL database!**

### Step 4: Test the Connection

After setting up the database in phpMyAdmin:

```powershell
# Navigate to backend folder
cd backend

# Activate virtual environment (if using one)
.\venv\Scripts\Activate.ps1

# Test the connection
python
>>> from app import create_app, db
>>> app = create_app()
>>> with app.app_context():
...     db.session.execute('SELECT 1')
... 
# If successful, you'll see: <sqlalchemy.engine.cursor.CursorResult object>
```

---

## Part 4: Create Sample User Account

After importing the schema, create a test user:

1. In phpMyAdmin, click on `milestone_expense_db` database
2. Click on **"SQL"** tab
3. Run this SQL to create a demo admin user:

```sql
-- Insert demo admin user (password: admin123)
INSERT INTO users (email, password_hash, full_name, role, is_active) VALUES
('admin@milestone.com', 'pbkdf2:sha256:600000$XxYyZz$abc123...', 'System Administrator', 'Admin', TRUE);
```

Note: You'll need to hash the password properly using Flask's password hashing. Run this Python script:

```python
from werkzeug.security import generate_password_hash
print(generate_password_hash('admin123'))
```

---

## Summary: How It All Works Together

```
┌─────────────────┐
│   phpMyAdmin    │
│  (Web Browser)  │
└────────┬────────┘
         │ 1. Create database
         │ 2. Import schema
         │ 3. Manage data
         ▼
┌─────────────────┐
│  MySQL Server   │ ◄──── External database running on your system
│  (Port 3306)    │
└────────┬────────┘
         │
         │ Connection String:
         │ mysql+pymysql://milestone_user:password@localhost:3306/milestone_expense_db
         │
         ▼
┌─────────────────┐
│  Flask Backend  │
│  (Python)       │
│                 │
│  - config.py ───┼──── Reads DB credentials from .env
│  - SQLAlchemy ──┼──── Uses connection string to connect
│  - Models ──────┼──── Map to database tables
│  - API Routes ──┼──── Query/insert/update data
└─────────────────┘
```

---

## Troubleshooting

### Connection Error: "Access denied for user"
- Check username and password in `.env` file
- Verify user has privileges in phpMyAdmin

### Connection Error: "Can't connect to MySQL server"
- Ensure MySQL service is running
- Check DB_HOST is correct (localhost or IP address)
- Check DB_PORT is correct (default: 3306)

### Table doesn't exist
- Verify you imported the complete schema in phpMyAdmin
- Check you selected the correct database

---

## Next Steps

1. Set up database in phpMyAdmin (Part 1 & 2)
2. Configure `.env` file (Part 3)
3. Run Flask backend and test connection
4. Create demo users
5. Start using the system!
