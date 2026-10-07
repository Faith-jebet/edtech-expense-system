-- =====================================================
-- Milestone EdTech Expense Control System
-- Complete MySQL Database Schema for phpMyAdmin
-- =====================================================
-- 
-- INSTRUCTIONS:
-- 1. Open phpMyAdmin
-- 2. Create database: milestone_expense_db
-- 3. Select the database
-- 4. Go to SQL tab
-- 5. Copy and paste this entire file
-- 6. Click "Go"
--
-- =====================================================

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

-- =====================================================
-- TABLE: users
-- Stores all system users with role-based access
-- =====================================================
CREATE TABLE IF NOT EXISTS `users` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `email` VARCHAR(120) NOT NULL UNIQUE,
  `password_hash` VARCHAR(255) NOT NULL,
  `full_name` VARCHAR(100) NOT NULL,
  `role` VARCHAR(50) NOT NULL COMMENT 'Staff, Manager, Accountant, Director, Managing Director, Admin',
  `is_active` BOOLEAN DEFAULT TRUE,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_role (`role`),
  INDEX idx_email (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =====================================================
-- TABLE: projects
-- Stores projects for budget tracking
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
-- Predefined expense categories
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
-- Main table for expense/payment requests
-- Tracks complete workflow from submission to closing
-- =====================================================
CREATE TABLE IF NOT EXISTS `expense_requests` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `request_id` VARCHAR(50) NOT NULL UNIQUE COMMENT 'Format: ME-EXP-YYYY-####',
  `project_id` INT NOT NULL,
  `requester_id` INT NOT NULL,
  `request_date` DATE NOT NULL,
  `purpose` TEXT NOT NULL,
  `payee_name` VARCHAR(200) NOT NULL,
  `payment_method` VARCHAR(50) NOT NULL COMMENT 'Cash, Bank Transfer, Mobile Money, Cheque',
  `currency` VARCHAR(3) NOT NULL DEFAULT 'USD',
  `total_amount` DECIMAL(14,2) NOT NULL,
  `exchange_rate_to_usd` DECIMAL(10,6) DEFAULT 1.000000,
  `total_amount_usd` DECIMAL(14,2) NOT NULL,
  `status` VARCHAR(50) NOT NULL DEFAULT 'Submitted' COMMENT 'Workflow status',
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
  `priority` VARCHAR(20) DEFAULT 'Normal' COMMENT 'Normal, Urgent',
  `budget_status` VARCHAR(50) DEFAULT 'Within Budget' COMMENT 'Within Budget, Outside Budget / Exception',
  `is_split_purchase` BOOLEAN DEFAULT FALSE COMMENT 'Flagged if similar requests exist',
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
-- Line items for each expense request
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
-- File attachments for requests
-- =====================================================
CREATE TABLE IF NOT EXISTS `attachments` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `request_id` INT NOT NULL,
  `file_type` VARCHAR(50) NOT NULL COMMENT 'Quotation, Invoice, Receipt, Proof of Payment, etc.',
  `file_name` VARCHAR(255) NOT NULL,
  `file_path` VARCHAR(500) NOT NULL,
  `file_size` INT NOT NULL COMMENT 'Size in bytes',
  `uploaded_by_id` INT NOT NULL,
  `uploaded_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`request_id`) REFERENCES `expense_requests`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`uploaded_by_id`) REFERENCES `users`(`id`) ON DELETE RESTRICT,
  INDEX idx_request (`request_id`),
  INDEX idx_file_type (`file_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =====================================================
-- TABLE: approvals
-- Approval/rejection history
-- =====================================================
CREATE TABLE IF NOT EXISTS `approvals` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `request_id` INT NOT NULL,
  `approver_id` INT NOT NULL,
  `action` VARCHAR(20) NOT NULL COMMENT 'Approved, Rejected',
  `notes` TEXT,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`request_id`) REFERENCES `expense_requests`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`approver_id`) REFERENCES `users`(`id`) ON DELETE RESTRICT,
  INDEX idx_request (`request_id`),
  INDEX idx_approver (`approver_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =====================================================
-- TABLE: payments
-- Payment execution records
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
-- Cash advances requiring retirement
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
-- Tracks all incoming funds
-- =====================================================
CREATE TABLE IF NOT EXISTS `income_receipts` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `receipt_id` VARCHAR(50) NOT NULL UNIQUE COMMENT 'Format: ME-INC-YYYY-####',
  `source` VARCHAR(200) NOT NULL COMMENT 'Donor, Grant, Fee, etc.',
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
-- Bank/Mobile/Petty Cash reconciliations
-- =====================================================
CREATE TABLE IF NOT EXISTS `reconciliations` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `account_type` VARCHAR(50) NOT NULL COMMENT 'Bank, Mobile Money, Petty Cash',
  `account_name` VARCHAR(200) NOT NULL,
  `account_number` VARCHAR(50),
  `period_start` DATE NOT NULL,
  `period_end` DATE NOT NULL,
  `opening_balance` DECIMAL(14,2) NOT NULL,
  `system_closing_balance` DECIMAL(14,2) NOT NULL,
  `actual_closing_balance` DECIMAL(14,2) NOT NULL,
  `difference` DECIMAL(14,2) NOT NULL COMMENT 'Actual - System',
  `status` VARCHAR(20) NOT NULL DEFAULT 'Open' COMMENT 'Open, Explained, Cleared',
  `explanation` TEXT,
  `prepared_by_id` INT NOT NULL,
  `prepared_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `reviewed_by_id` INT COMMENT 'Must be different from preparer (separation of duties)',
  `reviewed_at` DATETIME,
  FOREIGN KEY (`prepared_by_id`) REFERENCES `users`(`id`) ON DELETE RESTRICT,
  FOREIGN KEY (`reviewed_by_id`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  INDEX idx_account (`account_name`),
  INDEX idx_period (`period_end`),
  INDEX idx_status (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =====================================================
-- TABLE: reconciliation_items
-- Individual transactions from bank statements
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
  `matched_request_id` INT COMMENT 'Links to expense_requests if matched',
  `matched_receipt_id` INT COMMENT 'Links to income_receipts if matched',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`reconciliation_id`) REFERENCES `reconciliations`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`matched_request_id`) REFERENCES `expense_requests`(`id`) ON DELETE SET NULL,
  FOREIGN KEY (`matched_receipt_id`) REFERENCES `income_receipts`(`id`) ON DELETE SET NULL,
  INDEX idx_reconciliation (`reconciliation_id`),
  INDEX idx_matched (`matched`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =====================================================
-- TABLE: exchange_rates
-- Currency exchange rates over time
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
-- System configuration settings
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
-- Auto-incrementing counters for request IDs
-- =====================================================
CREATE TABLE IF NOT EXISTS `id_counters` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `counter_type` VARCHAR(50) NOT NULL COMMENT 'expense_request, income_receipt',
  `year` INT NOT NULL,
  `current_value` INT NOT NULL DEFAULT 0,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY unique_counter (`counter_type`, `year`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =====================================================
-- TABLE: audit_log
-- Immutable audit trail (protected by triggers)
-- =====================================================
CREATE TABLE IF NOT EXISTS `audit_log` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT,
  `action` VARCHAR(50) NOT NULL COMMENT 'CREATE, UPDATE, DELETE, APPROVE, REJECT, PAY, etc.',
  `entity_type` VARCHAR(50) NOT NULL COMMENT 'ExpenseRequest, Payment, User, etc.',
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
-- Ensures audit trail cannot be tampered with
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
-- DEFAULT DATA: System settings
-- =====================================================
INSERT INTO `settings` (`key_name`, `value`, `description`) VALUES
('approval_threshold_manager', '100', 'Maximum amount (USD) Manager can approve'),
('approval_threshold_director', '500', 'Maximum amount (USD) Director can approve'),
('approval_threshold_md', '999999', 'Maximum amount (USD) Managing Director can approve'),
('payment_tolerance_percent', '2', 'Allowed variance between approved and actual amount (%)'),
('advance_retirement_days', '30', 'Default days to retire an advance'),
('company_name', 'Milestone EdTech Solutions Ltd', 'Company name for documents'),
('currency_default', 'USD', 'Default currency for transactions');

-- =====================================================
-- DEFAULT DATA: Expense categories
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
-- DEFAULT DATA: Exchange rates
-- =====================================================
INSERT INTO `exchange_rates` (`from_currency`, `to_currency`, `rate`, `effective_date`) VALUES
('USD', 'USD', 1.000000, '2026-01-01'),
('KES', 'USD', 0.0078, '2026-01-01'),
('EUR', 'USD', 1.09, '2026-01-01'),
('GBP', 'USD', 1.27, '2026-01-01');

-- =====================================================
-- DEFAULT DATA: Sample project
-- =====================================================
INSERT INTO `projects` (`code`, `name`, `description`, `budget`, `currency`, `start_date`, `end_date`, `is_active`) VALUES
('PROJ-001', 'General Operations', 'General operational expenses', 100000.00, 'USD', '2026-01-01', '2026-12-31', TRUE);

-- =====================================================
-- SCHEMA IMPORT COMPLETE
-- =====================================================
-- 
-- Next steps:
-- 1. Create users (see DATABASE_SETUP.md for instructions)
-- 2. Configure Flask backend .env file with database credentials
-- 3. Start the application
--
-- =====================================================
