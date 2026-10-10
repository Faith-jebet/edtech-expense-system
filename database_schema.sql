-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Oct 10, 2026 at 01:31 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `milestone_expense_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `advances`
--

CREATE TABLE `advances` (
  `id` int(11) NOT NULL,
  `request_id` int(11) NOT NULL,
  `advance_amount` decimal(14,2) NOT NULL,
  `retirement_deadline` date NOT NULL,
  `is_retired` tinyint(1) DEFAULT 0,
  `retired_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `approvals`
--

CREATE TABLE `approvals` (
  `id` int(11) NOT NULL,
  `request_id` int(11) NOT NULL,
  `approver_id` int(11) NOT NULL,
  `decision` varchar(20) DEFAULT NULL,
  `comments` text DEFAULT NULL,
  `signature_path` varchar(255) DEFAULT NULL,
  `signature_text` varchar(200) DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `action` varchar(20) NOT NULL,
  `notes` text DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `approvals`
--

INSERT INTO `approvals` (`id`, `request_id`, `approver_id`, `decision`, `comments`, `signature_path`, `signature_text`, `ip_address`, `action`, `notes`, `created_at`) VALUES
(1, 7, 6, 'Approved', 'hgfd', NULL, NULL, '127.0.0.1', '', NULL, '2026-10-07 11:17:26'),
(2, 7, 6, 'Rejected', 'hbbvcx', NULL, NULL, '127.0.0.1', '', NULL, '2026-10-07 11:17:44'),
(3, 8, 5, 'Approved', 'c', NULL, NULL, '127.0.0.1', '', NULL, '2026-10-07 11:21:08'),
(4, 5, 6, 'Approved', 'Approved by MD test', NULL, NULL, NULL, '', NULL, '2026-10-07 11:26:03'),
(5, 9, 6, 'Approved', 'hv', NULL, NULL, '127.0.0.1', '', NULL, '2026-10-07 11:49:01'),
(6, 13, 5, 'Approved', 'hvv', NULL, NULL, '127.0.0.1', '', NULL, '2026-10-07 12:50:12'),
(7, 12, 6, 'Approved', '', NULL, NULL, '127.0.0.1', '', NULL, '2026-10-07 14:01:06'),
(8, 20, 6, 'Approved', 'Thhhh', NULL, NULL, '127.0.0.1', '', NULL, '2026-10-09 08:33:05'),
(9, 24, 5, 'Rejected', 'Rejected', NULL, NULL, '127.0.0.1', '', NULL, '2026-10-09 08:41:42'),
(10, 14, 6, 'Approved', 'Approved by MD test', NULL, NULL, NULL, '', NULL, '2026-10-09 09:14:52'),
(11, 21, 5, 'Approved', 'Checked', NULL, NULL, '127.0.0.1', '', NULL, '2026-10-09 09:18:08'),
(12, 23, 5, 'Approved', 'Approved', NULL, NULL, '127.0.0.1', '', NULL, '2026-10-09 09:22:31'),
(13, 25, 4, 'Rejected', 'Try small amount', NULL, NULL, '127.0.0.1', '', NULL, '2026-10-09 09:41:33'),
(14, 15, 6, 'Approved', 'Approved by MD test', NULL, NULL, NULL, '', NULL, '2026-10-09 10:08:59'),
(15, 29, 4, 'Verified', '', NULL, NULL, '127.0.0.1', '', NULL, '2026-10-09 10:31:24'),
(16, 28, 4, 'Verified', '', NULL, NULL, '127.0.0.1', '', NULL, '2026-10-09 10:31:32'),
(17, 26, 4, 'Verified', '', NULL, NULL, '127.0.0.1', '', NULL, '2026-10-09 10:31:40'),
(18, 30, 4, 'Verified', 'Move to next step', NULL, NULL, '127.0.0.1', '', NULL, '2026-10-09 12:23:43'),
(19, 30, 5, 'Approved', 'next', NULL, NULL, '127.0.0.1', '', NULL, '2026-10-09 12:27:48'),
(20, 27, 4, 'Verified', '', NULL, NULL, '127.0.0.1', '', NULL, '2026-10-09 14:27:43'),
(21, 29, 5, 'Approved', '', NULL, NULL, '127.0.0.1', '', NULL, '2026-10-09 20:09:53'),
(22, 26, 6, 'Approved', '', NULL, NULL, '127.0.0.1', '', NULL, '2026-10-09 20:11:44');

-- --------------------------------------------------------

--
-- Table structure for table `attachments`
--

CREATE TABLE `attachments` (
  `id` int(11) NOT NULL,
  `request_id` int(11) NOT NULL,
  `file_type` varchar(50) NOT NULL,
  `file_name` varchar(255) NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `file_size` int(11) NOT NULL,
  `uploaded_by_id` int(11) NOT NULL,
  `uploaded_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `attachments`
--

INSERT INTO `attachments` (`id`, `request_id`, `file_type`, `file_name`, `file_path`, `file_size`, `uploaded_by_id`, `uploaded_at`) VALUES
(1, 13, 'Quotation', 'Milestone_EdTech_Full_Document_No_Tables.docx', 'C:\\Users\\PC\\OneDrive\\Desktop\\EdTech-Expense control\\backend\\uploads\\2026\\10\\256e172ff2ce48bdb5b0c5fb7e32443e_Milestone_EdTech_Full_Document_No_Tables.docx', 12695, 7, '2026-10-07 11:52:17'),
(2, 15, 'Quotation', 'Milestone_EdTech_Full_Document_No_Tables.docx', 'C:\\Users\\PC\\OneDrive\\Desktop\\EdTech-Expense control\\backend\\uploads\\2026\\10\\bde4d46122774d29bc43a3dcd9c5f5ca_Milestone_EdTech_Full_Document_No_Tables.docx', 12695, 4, '2026-10-07 13:08:35'),
(3, 5, 'Proof of Payment', 'Milestone_EdTech_Full_Document_No_Tables.docx', 'C:\\Users\\PC\\OneDrive\\Desktop\\EdTech-Expense control\\backend\\uploads\\2026\\10\\f85ac39e82b84e09a9c2e58b235395d5_Milestone_EdTech_Full_Document_No_Tables.docx', 12695, 8, '2026-10-07 13:20:03'),
(4, 12, 'Quotation', 'Milestone_EdTech_Finance_Framework_and_Request_Form.pdf', 'C:\\Users\\PC\\OneDrive\\Desktop\\EdTech-Expense control\\backend\\uploads\\2026\\10\\671e82de44f048b68ec8bcff6c0c04cd_Milestone_EdTech_Finance_Framework_and_Request_Form.pdf', 190055, 8, '2026-10-07 13:20:35'),
(5, 15, 'Quotation', 'dash.PNG', 'C:\\Users\\PC\\OneDrive\\Desktop\\EdTech-Expense control\\backend\\uploads\\2026\\10\\de569e5f83094f34b73595b8b430803d_dash.PNG', 102613, 4, '2026-10-07 18:13:33'),
(6, 14, 'Quotation', 'Milestone_EdTech_Framework_Sections_1-4.docx', 'C:\\Users\\PC\\OneDrive\\Desktop\\EdTech-Expense control\\backend\\uploads\\2026\\10\\e1a8bd77298f4bed897870ca34e5f750_Milestone_EdTech_Framework_Sections_1-4.docx', 19389, 4, '2026-10-08 07:55:08'),
(7, 17, 'Quotation', 'Milestone_EdTech_Framework_Sections_1-4.docx', 'C:\\Users\\PC\\OneDrive\\Desktop\\EdTech-Expense control\\backend\\uploads\\2026\\10\\2ef809e4177d4b508e7f5aa921f4fe09_Milestone_EdTech_Framework_Sections_1-4.docx', 19389, 5, '2026-10-08 07:56:09'),
(8, 15, 'Quotation', 'Milestone_EdTech_Framework_Sections_1-4.docx', 'C:\\Users\\PC\\OneDrive\\Desktop\\EdTech-Expense control\\backend\\uploads\\2026\\10\\7c0c3cb55d734673b6cb07e89cad0808_Milestone_EdTech_Framework_Sections_1-4.docx', 19389, 4, '2026-10-08 08:36:53'),
(9, 14, 'Quotation', 'Expense_Tracker_Dashboard_Suggested_Improvements.pdf', 'C:\\Users\\PC\\OneDrive\\Desktop\\EdTech-Expense control\\backend\\uploads\\2026\\10\\3e516acc75cf4f7b93e9662f320a29b5_Expense_Tracker_Dashboard_Suggested_Improvements.pdf', 180658, 4, '2026-10-08 08:41:39'),
(10, 20, 'Quotation', 'Milestone_EdTech_Framework_Sections_1-4.docx', 'C:\\Users\\PC\\OneDrive\\Desktop\\EdTech-Expense control\\backend\\uploads\\2026\\10\\163cba66e5bc4a09b394fe21fa05fb48_Milestone_EdTech_Framework_Sections_1-4.docx', 19389, 10, '2026-10-08 08:45:11'),
(11, 21, 'Quotation', 'Milestone_EdTech_Framework_Sections_1-4.docx', 'C:\\Users\\PC\\OneDrive\\Desktop\\EdTech-Expense control\\backend\\uploads\\2026\\10\\07da88b7f42c449b938edd5e42e4f7e5_Milestone_EdTech_Framework_Sections_1-4.docx', 19389, 7, '2026-10-08 08:52:26'),
(12, 22, 'Quotation', 'Milestone_EdTech_Framework_Sections_1-4.docx', 'C:\\Users\\PC\\OneDrive\\Desktop\\EdTech-Expense control\\backend\\uploads\\2026\\10\\852e587a9d2247009bdd30364a9bb35d_Milestone_EdTech_Framework_Sections_1-4.docx', 19389, 9, '2026-10-08 09:04:16'),
(13, 23, 'Quotation', 'Milestone_EdTech_Framework_Sections_1-4.docx', 'C:\\Users\\PC\\OneDrive\\Desktop\\EdTech-Expense control\\backend\\uploads\\2026\\10\\5783fa69220f4d2fb4f4257f1973ee7e_Milestone_EdTech_Framework_Sections_1-4.docx', 19389, 7, '2026-10-08 09:22:45'),
(14, 24, 'Quotation', 'Milestone_EdTech_Framework_Sections_1-4.docx', 'C:\\Users\\PC\\OneDrive\\Desktop\\EdTech-Expense control\\backend\\uploads\\2026\\10\\8ae338f3ae8649daa62bc674614fc91a_Milestone_EdTech_Framework_Sections_1-4.docx', 19389, 6, '2026-10-09 08:38:35'),
(15, 25, 'Quotation', 'Milestone_EdTech_Framework_Sections_1-4.docx', 'C:\\Users\\PC\\OneDrive\\Desktop\\EdTech-Expense control\\backend\\uploads\\2026\\10\\41b8e54926f54a1b9221715320ad0431_Milestone_EdTech_Framework_Sections_1-4.docx', 19389, 9, '2026-10-09 09:39:46'),
(16, 21, 'Proof of Payment', 'expense_requests_2026-10-09.pdf', 'C:\\Users\\PC\\OneDrive\\Desktop\\EdTech-Expense control\\backend\\uploads\\2026\\10\\95f373927902430c87f773a80ce3e6f9_expense_requests_2026-10-09.pdf', 3347, 8, '2026-10-09 09:53:57'),
(17, 26, 'Quotation', 'expense_requests_2026-10-09.pdf', 'C:\\Users\\PC\\OneDrive\\Desktop\\EdTech-Expense control\\backend\\uploads\\2026\\10\\d26c6d4883c446eb83840e0de3a35ca2_expense_requests_2026-10-09.pdf', 3347, 11, '2026-10-09 10:22:50'),
(18, 27, 'Quotation', 'Milestone_EdTech_Framework_Sections_1-4.docx', 'C:\\Users\\PC\\OneDrive\\Desktop\\EdTech-Expense control\\backend\\uploads\\2026\\10\\3262842f25b14f38908cb76849d493bc_Milestone_EdTech_Framework_Sections_1-4.docx', 19389, 9, '2026-10-09 10:25:27'),
(19, 28, 'Quotation', 'expense_requests_2026-10-09.pdf', 'C:\\Users\\PC\\OneDrive\\Desktop\\EdTech-Expense control\\backend\\uploads\\2026\\10\\86f1f9341c6145e59a2435bf2d9971ee_expense_requests_2026-10-09.pdf', 3347, 6, '2026-10-09 10:27:52'),
(20, 29, 'Quotation', 'Milestone_EdTech_Framework_Sections_1-4.docx', 'C:\\Users\\PC\\OneDrive\\Desktop\\EdTech-Expense control\\backend\\uploads\\2026\\10\\9ef2bf5999504bc3b082e78735438a26_Milestone_EdTech_Framework_Sections_1-4.docx', 19389, 7, '2026-10-09 10:29:47'),
(21, 30, 'Quotation', 'Expense_Tracker_Dashboard_Suggested_Improvements.pdf', 'C:\\Users\\PC\\OneDrive\\Desktop\\EdTech-Expense control\\backend\\uploads\\2026\\10\\5ac74e8d5dbc42df9d32bbbb05923af2_Expense_Tracker_Dashboard_Suggested_Improvements.pdf', 180658, 7, '2026-10-09 12:21:19'),
(22, 30, 'Proof of Payment', 'Administration_Specialist_JD.docx', 'C:\\Users\\PC\\OneDrive\\Desktop\\EdTech-Expense control\\backend\\uploads\\2026\\10\\4f39b99776784baeba3234cd6d29c73e_Administration_Specialist_JD.docx', 10093, 8, '2026-10-09 13:58:53'),
(23, 30, 'Proof of Payment', 'Administration_Specialist_JD.docx', 'C:\\Users\\PC\\OneDrive\\Desktop\\EdTech-Expense control\\backend\\uploads\\2026\\10\\a0217632ea5a4848abf96777d51a608a_Administration_Specialist_JD.docx', 10093, 8, '2026-10-09 14:00:33'),
(24, 31, 'Quotation', 'Expense_Tracker_Dashboard_Suggested_Improvements.pdf', 'C:\\Users\\PC\\OneDrive\\Desktop\\EdTech-Expense control\\backend\\uploads\\2026\\10\\560fe4cd9e46479c9acd217cda8fdbaa_Expense_Tracker_Dashboard_Suggested_Improvements.pdf', 180658, 9, '2026-10-09 20:52:52');

-- --------------------------------------------------------

--
-- Table structure for table `audit_log`
--

CREATE TABLE `audit_log` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `action` varchar(50) NOT NULL,
  `entity_type` varchar(50) NOT NULL,
  `entity_id` int(11) NOT NULL,
  `note` text DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `audit_log`
--

INSERT INTO `audit_log` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `note`, `ip_address`, `created_at`) VALUES
(1, 1, 'LOGIN', 'User', 1, 'User logged in', '127.0.0.1', '2026-10-06 20:02:27'),
(2, 1, 'LOGIN', 'User', 1, 'User logged in', '127.0.0.1', '2026-10-06 20:02:51'),
(3, 1, 'LOGIN', 'User', 1, 'User logged in', '127.0.0.1', '2026-10-06 20:04:11'),
(4, 1, 'LOGIN', 'User', 1, 'User logged in', '127.0.0.1', '2026-10-06 20:04:27'),
(5, 1, 'LOGIN', 'User', 1, 'User logged in', '127.0.0.1', '2026-10-06 20:05:17'),
(6, 1, 'LOGIN', 'User', 1, 'User logged in', NULL, '2026-10-06 20:05:45'),
(7, 1, 'LOGIN', 'User', 1, 'User logged in', '127.0.0.1', '2026-10-06 20:06:32'),
(8, 1, 'LOGIN', 'User', 1, 'User logged in', '127.0.0.1', '2026-10-06 20:06:34'),
(9, 1, 'LOGIN', 'User', 1, 'User logged in', '127.0.0.1', '2026-10-06 20:06:49'),
(10, 1, 'LOGIN', 'User', 1, 'User logged in', '127.0.0.1', '2026-10-06 20:09:49'),
(11, 1, 'LOGOUT', 'User', 1, 'User logged out', '127.0.0.1', '2026-10-06 20:10:34'),
(12, 2, 'LOGIN', 'User', 2, 'User logged in', '127.0.0.1', '2026-10-06 20:12:05'),
(13, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-06 20:15:23'),
(14, 1, 'LOGIN', 'User', 1, 'User logged in', '127.0.0.1', '2026-10-06 20:36:25'),
(15, 1, 'LOGIN', 'User', 1, 'User logged in', '127.0.0.1', '2026-10-06 21:07:04'),
(16, 1, 'LOGOUT', 'User', 1, 'User logged out', '127.0.0.1', '2026-10-06 21:09:21'),
(17, 3, 'LOGIN', 'User', 3, 'User logged in', '127.0.0.1', '2026-10-06 21:10:06'),
(18, 3, 'LOGOUT', 'User', 3, 'User logged out', '127.0.0.1', '2026-10-06 21:11:04'),
(19, 5, 'LOGIN', 'User', 5, 'User logged in', '127.0.0.1', '2026-10-06 21:11:36'),
(20, 3, 'LOGIN', 'User', 3, 'User logged in', '127.0.0.1', '2026-10-06 21:19:29'),
(21, 3, 'LOGIN', 'User', 3, 'User logged in', '127.0.0.1', '2026-10-06 21:20:30'),
(22, 3, 'LOGIN', 'User', 3, 'User logged in', '127.0.0.1', '2026-10-06 21:20:59'),
(23, 3, 'LOGIN', 'User', 3, 'User logged in', '127.0.0.1', '2026-10-06 21:22:05'),
(24, 5, 'LOGOUT', 'User', 5, 'User logged out', '127.0.0.1', '2026-10-06 21:23:16'),
(25, 3, 'LOGIN', 'User', 3, 'User logged in', '127.0.0.1', '2026-10-07 07:18:04'),
(26, 3, 'LOGIN', 'User', 3, 'User logged in', '127.0.0.1', '2026-10-07 07:18:13'),
(27, 3, 'CREATE', 'ExpenseRequest', 1, 'Created expense request ME-EXP-2026-0001', '127.0.0.1', '2026-10-07 07:18:57'),
(28, 3, 'LOGIN', 'User', 3, 'User logged in', '127.0.0.1', '2026-10-07 07:28:31'),
(29, 3, 'CREATE', 'ExpenseRequest', 2, 'Created expense request ME-EXP-2026-0002', '127.0.0.1', '2026-10-07 07:29:05'),
(30, 3, 'CREATE', 'ExpenseRequest', 3, 'Created expense request ME-EXP-2026-0003', '127.0.0.1', '2026-10-07 07:29:27'),
(31, 1, 'LOGIN', 'User', 1, 'User logged in', '127.0.0.1', '2026-10-07 07:39:38'),
(32, 1, 'LOGIN', 'User', 1, 'User logged in', '127.0.0.1', '2026-10-07 07:40:53'),
(33, 1, 'CREATE', 'ExpenseRequest', 4, 'Created expense request ME-EXP-2026-0004', '127.0.0.1', '2026-10-07 07:40:53'),
(34, 1, 'LOGIN', 'User', 1, 'User logged in', '127.0.0.1', '2026-10-07 07:45:03'),
(35, 1, 'CREATE', 'ExpenseRequest', 5, 'Created expense request ME-EXP-2026-0005', '127.0.0.1', '2026-10-07 07:45:03'),
(36, 3, 'LOGIN', 'User', 3, 'User logged in', '127.0.0.1', '2026-10-07 07:49:01'),
(37, 3, 'CREATE', 'ExpenseRequest', 6, 'Created expense request ME-EXP-2026-0006', '127.0.0.1', '2026-10-07 07:49:43'),
(38, 1, 'LOGIN', 'User', 1, 'User logged in', '127.0.0.1', '2026-10-07 07:55:23'),
(39, 1, 'LOGIN', 'User', 1, 'User logged in', '127.0.0.1', '2026-10-07 08:01:50'),
(40, 1, 'LOGIN', 'User', 1, 'User logged in', '127.0.0.1', '2026-10-07 08:02:37'),
(41, 1, 'LOGIN', 'User', 1, 'User logged in', '127.0.0.1', '2026-10-07 08:02:38'),
(42, 1, 'LOGIN', 'User', 1, 'User logged in', '127.0.0.1', '2026-10-07 08:04:44'),
(43, 1, 'LOGIN', 'User', 1, 'User logged in', '127.0.0.1', '2026-10-07 08:10:24'),
(44, 1, 'CREATE', 'ExpenseRequest', 7, 'Created expense request ME-EXP-2026-0007', '127.0.0.1', '2026-10-07 08:12:23'),
(45, 1, 'LOGOUT', 'User', 1, 'User logged out', '127.0.0.1', '2026-10-07 08:14:24'),
(46, 7, 'LOGIN', 'User', 7, 'User logged in', '127.0.0.1', '2026-10-07 08:15:41'),
(47, 7, 'CREATE', 'ExpenseRequest', 8, 'Created expense request ME-EXP-2026-0008', '127.0.0.1', '2026-10-07 08:16:41'),
(48, 7, 'LOGOUT', 'User', 7, 'User logged out', '127.0.0.1', '2026-10-07 08:17:22'),
(49, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-07 08:18:00'),
(50, 7, 'LOGIN', 'User', 7, 'User logged in', '127.0.0.1', '2026-10-07 08:19:43'),
(51, 1, 'LOGIN', 'User', 1, 'User logged in', '127.0.0.1', '2026-10-07 08:47:50'),
(52, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-07 08:55:14'),
(53, 4, 'LOGOUT', 'User', 4, 'User logged out', '127.0.0.1', '2026-10-07 08:59:15'),
(54, 7, 'LOGIN', 'User', 7, 'User logged in', '127.0.0.1', '2026-10-07 08:59:42'),
(55, 7, 'LOGOUT', 'User', 7, 'User logged out', '127.0.0.1', '2026-10-07 09:00:41'),
(56, 2, 'LOGIN', 'User', 2, 'User logged in', '127.0.0.1', '2026-10-07 09:01:03'),
(57, 2, 'CREATE', 'ExpenseRequest', 9, 'Created expense request ME-EXP-2026-0009', '127.0.0.1', '2026-10-07 09:02:23'),
(58, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-07 09:40:32'),
(59, 8, 'LOGIN', 'User', 8, 'User logged in', '127.0.0.1', '2026-10-07 09:43:01'),
(60, 3, 'LOGIN', 'User', 3, 'User logged in', '127.0.0.1', '2026-10-07 10:20:50'),
(61, 3, 'CREATE', 'ExpenseRequest', 10, 'Created expense request ME-EXP-2026-0010', '127.0.0.1', '2026-10-07 10:20:52'),
(62, 3, 'LOGIN', 'User', 3, 'User logged in', '127.0.0.1', '2026-10-07 10:21:15'),
(63, 3, 'LOGIN', 'User', 3, 'User logged in', '127.0.0.1', '2026-10-07 10:21:24'),
(64, 3, 'CREATE', 'ExpenseRequest', 11, 'Created expense request ME-EXP-2026-0011', '127.0.0.1', '2026-10-07 10:21:26'),
(65, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-07 10:24:50'),
(66, 4, 'LOGOUT', 'User', 4, 'User logged out', '127.0.0.1', '2026-10-07 10:28:55'),
(67, 8, 'LOGIN', 'User', 8, 'User logged in', '127.0.0.1', '2026-10-07 10:29:35'),
(68, 8, 'CREATE', 'ExpenseRequest', 12, 'Created expense request ME-EXP-2026-0012', '127.0.0.1', '2026-10-07 10:31:24'),
(69, 8, 'LOGOUT', 'User', 8, 'User logged out', '127.0.0.1', '2026-10-07 10:35:19'),
(70, 8, 'LOGIN', 'User', 8, 'User logged in', '127.0.0.1', '2026-10-07 10:35:37'),
(71, 1, 'LOGIN', 'User', 1, 'User logged in', '127.0.0.1', '2026-10-07 10:49:29'),
(72, 1, 'LOGOUT', 'User', 1, 'User logged out', '127.0.0.1', '2026-10-07 10:50:15'),
(73, 8, 'LOGIN', 'User', 8, 'User logged in', '127.0.0.1', '2026-10-07 10:51:06'),
(74, 8, 'LOGOUT', 'User', 8, 'User logged out', '127.0.0.1', '2026-10-07 11:04:18'),
(75, 6, 'LOGIN', 'User', 6, 'User logged in', '127.0.0.1', '2026-10-07 11:16:24'),
(76, 6, 'LOGOUT', 'User', 6, 'User logged out', '127.0.0.1', '2026-10-07 11:19:39'),
(77, 8, 'LOGIN', 'User', 8, 'User logged in', '127.0.0.1', '2026-10-07 11:20:17'),
(78, 8, 'LOGOUT', 'User', 8, 'User logged out', '127.0.0.1', '2026-10-07 11:20:33'),
(79, 5, 'LOGIN', 'User', 5, 'User logged in', '127.0.0.1', '2026-10-07 11:20:52'),
(80, 5, 'LOGOUT', 'User', 5, 'User logged out', '127.0.0.1', '2026-10-07 11:21:28'),
(81, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-07 11:21:37'),
(82, 4, 'STATUS_CHANGE', 'ExpenseRequest', 9, 'Request verified by Mary Accountant', '127.0.0.1', '2026-10-07 11:33:07'),
(83, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-07 11:37:25'),
(84, 4, 'LOGOUT', 'User', 4, 'User logged out', '127.0.0.1', '2026-10-07 11:44:26'),
(85, 7, 'LOGIN', 'User', 7, 'User logged in', '127.0.0.1', '2026-10-07 11:44:49'),
(86, 7, 'CREATE', 'ExpenseRequest', 13, 'Created expense request ME-EXP-2026-0013', '127.0.0.1', '2026-10-07 11:46:07'),
(87, 7, 'STATUS_CHANGE', 'ExpenseRequest', 13, 'Request submitted: ME-EXP-2026-0013', '127.0.0.1', '2026-10-07 11:46:07'),
(88, 7, 'LOGOUT', 'User', 7, 'User logged out', '127.0.0.1', '2026-10-07 11:46:51'),
(89, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-07 11:46:59'),
(90, 4, 'LOGOUT', 'User', 4, 'User logged out', '127.0.0.1', '2026-10-07 11:47:29'),
(91, 7, 'LOGIN', 'User', 7, 'User logged in', '127.0.0.1', '2026-10-07 11:47:37'),
(92, 7, 'LOGOUT', 'User', 7, 'User logged out', '127.0.0.1', '2026-10-07 11:48:37'),
(93, 6, 'LOGIN', 'User', 6, 'User logged in', '127.0.0.1', '2026-10-07 11:48:44'),
(94, 6, 'APPROVE', 'ExpenseRequest', 9, 'Request approved by Sarah Managing Director. Comments: hv', '127.0.0.1', '2026-10-07 11:49:01'),
(95, 6, 'LOGOUT', 'User', 6, 'User logged out', '127.0.0.1', '2026-10-07 11:51:47'),
(96, 7, 'LOGIN', 'User', 7, 'User logged in', '127.0.0.1', '2026-10-07 11:51:56'),
(97, 7, 'UPLOAD', 'Attachment', 1, 'Uploaded Quotation: Milestone_EdTech_Full_Document_No_Tables.docx', '127.0.0.1', '2026-10-07 11:52:17'),
(98, 7, 'LOGOUT', 'User', 7, 'User logged out', '127.0.0.1', '2026-10-07 11:52:27'),
(99, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-07 11:52:34'),
(100, 4, 'STATUS_CHANGE', 'ExpenseRequest', 13, 'Request verified by Mary Accountant', '127.0.0.1', '2026-10-07 11:52:45'),
(101, 4, 'LOGOUT', 'User', 4, 'User logged out', '127.0.0.1', '2026-10-07 11:54:59'),
(102, 1, 'LOGIN', 'User', 1, 'User logged in', '127.0.0.1', '2026-10-07 11:55:35'),
(103, 1, 'LOGOUT', 'User', 1, 'User logged out', '127.0.0.1', '2026-10-07 11:57:03'),
(104, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-07 12:00:10'),
(105, 4, 'LOGOUT', 'User', 4, 'User logged out', '127.0.0.1', '2026-10-07 12:00:12'),
(106, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-07 12:01:11'),
(107, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-07 12:16:31'),
(108, 4, 'LOGOUT', 'User', 4, 'User logged out', '127.0.0.1', '2026-10-07 12:17:37'),
(109, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-07 12:17:52'),
(110, 4, 'LOGOUT', 'User', 4, 'User logged out', '127.0.0.1', '2026-10-07 12:17:54'),
(111, 1, 'LOGIN', 'User', 1, 'User logged in', '127.0.0.1', '2026-10-07 12:18:18'),
(112, 1, 'LOGOUT', 'User', 1, 'User logged out', '127.0.0.1', '2026-10-07 12:26:49'),
(113, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-07 12:26:51'),
(114, 4, 'CREATE', 'IncomeReceipt', 1, 'Created income receipt ME-REC-2026-0014: 11222 KES', '127.0.0.1', '2026-10-07 12:27:16'),
(115, 4, 'LOGOUT', 'User', 4, 'User logged out', '127.0.0.1', '2026-10-07 12:37:58'),
(116, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-07 12:38:46'),
(117, 4, 'LOGOUT', 'User', 4, 'User logged out', '127.0.0.1', '2026-10-07 12:38:52'),
(118, 1, 'LOGIN', 'User', 1, 'User logged in', '127.0.0.1', '2026-10-07 12:39:15'),
(119, 1, 'LOGOUT', 'User', 1, 'User logged out', '127.0.0.1', '2026-10-07 12:41:03'),
(120, 1, 'LOGIN', 'User', 1, 'User logged in', '127.0.0.1', '2026-10-07 12:41:07'),
(121, 1, 'LOGOUT', 'User', 1, 'User logged out', '127.0.0.1', '2026-10-07 12:42:48'),
(122, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-07 12:43:10'),
(123, 4, 'CREATE', 'Reconciliation', 1, 'Created reconciliation for dddd', '127.0.0.1', '2026-10-07 12:43:44'),
(124, 4, 'LOGOUT', 'User', 4, 'User logged out', '127.0.0.1', '2026-10-07 12:48:56'),
(125, 1, 'LOGIN', 'User', 1, 'User logged in', '127.0.0.1', '2026-10-07 12:49:02'),
(126, 1, 'LOGOUT', 'User', 1, 'User logged out', '127.0.0.1', '2026-10-07 12:49:54'),
(127, 5, 'LOGIN', 'User', 5, 'User logged in', '127.0.0.1', '2026-10-07 12:49:59'),
(128, 5, 'APPROVE', 'ExpenseRequest', 13, 'Request approved by David Director. Comments: hvv', '127.0.0.1', '2026-10-07 12:50:12'),
(129, 5, 'LOGOUT', 'User', 5, 'User logged out', '127.0.0.1', '2026-10-07 12:51:59'),
(130, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-07 12:52:06'),
(131, 4, 'CREATE', 'ExpenseRequest', 14, 'Created expense request ME-EXP-2026-0015', '127.0.0.1', '2026-10-07 12:52:53'),
(132, 4, 'STATUS_CHANGE', 'ExpenseRequest', 14, 'Request submitted: ME-EXP-2026-0015', '127.0.0.1', '2026-10-07 12:52:53'),
(133, 4, 'CREATE', 'ExpenseRequest', 15, 'Created expense request ME-EXP-2026-0016', '127.0.0.1', '2026-10-07 12:54:04'),
(134, 4, 'STATUS_CHANGE', 'ExpenseRequest', 15, 'Request submitted: ME-EXP-2026-0016', '127.0.0.1', '2026-10-07 12:54:04'),
(135, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-07 13:07:50'),
(136, 4, 'UPLOAD', 'Attachment', 2, 'Uploaded Quotation: Milestone_EdTech_Full_Document_No_Tables.docx', '127.0.0.1', '2026-10-07 13:08:36'),
(137, 4, 'LOGOUT', 'User', 4, 'User logged out', '127.0.0.1', '2026-10-07 13:19:09'),
(138, 8, 'LOGIN', 'User', 8, 'User logged in', '127.0.0.1', '2026-10-07 13:19:21'),
(139, 8, 'PAYMENT', 'ExpenseRequest', 5, 'Payment executed. Ref: ksavbbbb, Amount: 12222.00', '127.0.0.1', '2026-10-07 13:19:48'),
(140, 8, 'STATUS_CHANGE', 'ExpenseRequest', 5, 'Payment proof attached: Milestone_EdTech_Full_Document_No_Tables.docx', '127.0.0.1', '2026-10-07 13:20:03'),
(141, 8, 'UPLOAD', 'Attachment', 3, 'Uploaded Proof of Payment: Milestone_EdTech_Full_Document_No_Tables.docx', '127.0.0.1', '2026-10-07 13:20:03'),
(142, 8, 'UPLOAD', 'Attachment', 4, 'Uploaded Quotation: Milestone_EdTech_Finance_Framework_and_Request_Form.pdf', '127.0.0.1', '2026-10-07 13:20:35'),
(143, 1, 'LOGIN', 'User', 1, 'User logged in', '127.0.0.1', '2026-10-07 13:44:48'),
(144, 1, 'LOGOUT', 'User', 1, 'User logged out', '127.0.0.1', '2026-10-07 13:45:27'),
(145, 7, 'LOGIN', 'User', 7, 'User logged in', '127.0.0.1', '2026-10-07 13:45:33'),
(146, 7, 'LOGOUT', 'User', 7, 'User logged out', '127.0.0.1', '2026-10-07 13:48:23'),
(147, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-07 13:48:27'),
(148, 4, 'LOGOUT', 'User', 4, 'User logged out', '127.0.0.1', '2026-10-07 13:53:47'),
(149, 1, 'LOGIN', 'User', 1, 'User logged in', '127.0.0.1', '2026-10-07 13:53:52'),
(150, 1, 'LOGOUT', 'User', 1, 'User logged out', '127.0.0.1', '2026-10-07 13:57:23'),
(151, 1, 'LOGIN', 'User', 1, 'User logged in', '127.0.0.1', '2026-10-07 13:57:25'),
(152, 1, 'LOGOUT', 'User', 1, 'User logged out', '127.0.0.1', '2026-10-07 13:57:34'),
(153, 5, 'LOGIN', 'User', 5, 'User logged in', '127.0.0.1', '2026-10-07 13:57:39'),
(154, 5, 'LOGOUT', 'User', 5, 'User logged out', '127.0.0.1', '2026-10-07 13:57:49'),
(155, 7, 'LOGIN', 'User', 7, 'User logged in', '127.0.0.1', '2026-10-07 13:57:56'),
(156, 6, 'LOGIN', 'User', 6, 'User logged in', '127.0.0.1', '2026-10-07 13:58:30'),
(157, 6, 'LOGOUT', 'User', 6, 'User logged out', '127.0.0.1', '2026-10-07 13:59:45'),
(158, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-07 13:59:50'),
(159, 4, 'STATUS_CHANGE', 'ExpenseRequest', 12, 'Request verified by Mary Accountant', '127.0.0.1', '2026-10-07 14:00:29'),
(160, 4, 'LOGOUT', 'User', 4, 'User logged out', '127.0.0.1', '2026-10-07 14:00:52'),
(161, 6, 'LOGIN', 'User', 6, 'User logged in', '127.0.0.1', '2026-10-07 14:00:57'),
(162, 6, 'APPROVE', 'ExpenseRequest', 12, 'Request approved by Sarah Managing Director. Comments: None', '127.0.0.1', '2026-10-07 14:01:06'),
(163, 6, 'LOGOUT', 'User', 6, 'User logged out', '127.0.0.1', '2026-10-07 14:03:08'),
(164, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-07 14:03:13'),
(165, 4, 'LOGOUT', 'User', 4, 'User logged out', '127.0.0.1', '2026-10-07 14:06:28'),
(166, 1, 'LOGIN', 'User', 1, 'User logged in', '127.0.0.1', '2026-10-07 14:06:33'),
(167, 8, 'LOGIN', 'User', 8, 'User logged in', '127.0.0.1', '2026-10-07 14:09:55'),
(168, 8, 'LOGIN', 'User', 8, 'User logged in', '127.0.0.1', '2026-10-07 14:11:44'),
(169, 8, 'LOGIN', 'User', 8, 'User logged in', '127.0.0.1', '2026-10-07 14:14:34'),
(170, 1, 'LOGOUT', 'User', 1, 'User logged out', '127.0.0.1', '2026-10-07 14:19:30'),
(171, 1, 'LOGIN', 'User', 1, 'User logged in', '127.0.0.1', '2026-10-07 14:19:33'),
(172, 1, 'LOGOUT', 'User', 1, 'User logged out', '127.0.0.1', '2026-10-07 14:19:38'),
(173, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-07 14:19:43'),
(174, 1, 'LOGIN', 'User', 1, 'User logged in', '127.0.0.1', '2026-10-07 14:22:16'),
(175, 1, 'LOGOUT', 'User', 1, 'User logged out', '127.0.0.1', '2026-10-07 14:23:17'),
(176, 1, 'LOGIN', 'User', 1, 'User logged in', '127.0.0.1', '2026-10-07 14:23:53'),
(177, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-07 14:24:04'),
(178, 4, 'LOGOUT', 'User', 4, 'User logged out', '127.0.0.1', '2026-10-07 14:28:57'),
(179, 6, 'LOGIN', 'User', 6, 'User logged in', '127.0.0.1', '2026-10-07 14:29:15'),
(180, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-07 14:46:53'),
(181, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-07 14:47:15'),
(182, 9, 'LOGIN', 'User', 9, 'User logged in', '127.0.0.1', '2026-10-07 15:03:37'),
(183, 9, 'LOGOUT', 'User', 9, 'User logged out', '127.0.0.1', '2026-10-07 15:04:02'),
(184, 10, 'LOGIN', 'User', 10, 'User logged in', '127.0.0.1', '2026-10-07 15:04:56'),
(185, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-07 18:09:26'),
(186, 4, 'UPLOAD', 'Attachment', 5, 'Uploaded Quotation: dash.PNG', '127.0.0.1', '2026-10-07 18:13:33'),
(187, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-07 18:25:36'),
(188, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-08 07:05:37'),
(189, 4, 'LOGOUT', 'User', 4, 'User logged out', '127.0.0.1', '2026-10-08 07:08:16'),
(190, 10, 'LOGIN', 'User', 10, 'User logged in', '127.0.0.1', '2026-10-08 07:08:57'),
(191, 10, 'PAYMENT', 'ExpenseRequest', 8, 'Payment executed. Ref: ksavbbbb, Amount: 112212.00', '127.0.0.1', '2026-10-08 07:09:22'),
(192, 10, 'CREATE', 'ExpenseRequest', 16, 'Created expense request ME-EXP-2026-0017', '127.0.0.1', '2026-10-08 07:12:25'),
(193, 10, 'STATUS_CHANGE', 'ExpenseRequest', 16, 'Request submitted: ME-EXP-2026-0017', '127.0.0.1', '2026-10-08 07:12:25'),
(194, 10, 'LOGOUT', 'User', 10, 'User logged out', '127.0.0.1', '2026-10-08 07:14:21'),
(195, 7, 'LOGIN', 'User', 7, 'User logged in', '127.0.0.1', '2026-10-08 07:14:42'),
(196, 7, 'LOGOUT', 'User', 7, 'User logged out', '127.0.0.1', '2026-10-08 07:15:09'),
(197, 5, 'LOGIN', 'User', 5, 'User logged in', '127.0.0.1', '2026-10-08 07:15:20'),
(198, 5, 'LOGOUT', 'User', 5, 'User logged out', '127.0.0.1', '2026-10-08 07:15:45'),
(199, 6, 'LOGIN', 'User', 6, 'User logged in', '127.0.0.1', '2026-10-08 07:15:51'),
(200, 6, 'LOGOUT', 'User', 6, 'User logged out', '127.0.0.1', '2026-10-08 07:16:09'),
(201, 8, 'LOGIN', 'User', 8, 'User logged in', '127.0.0.1', '2026-10-08 07:17:07'),
(202, 6, 'LOGIN', 'User', 6, 'User logged in', '127.0.0.1', '2026-10-08 07:38:33'),
(203, 6, 'LOGOUT', 'User', 6, 'User logged out', '127.0.0.1', '2026-10-08 07:38:38'),
(204, 5, 'LOGIN', 'User', 5, 'User logged in', '127.0.0.1', '2026-10-08 07:38:49'),
(205, 5, 'LOGOUT', 'User', 5, 'User logged out', '127.0.0.1', '2026-10-08 07:39:00'),
(206, 7, 'LOGIN', 'User', 7, 'User logged in', '127.0.0.1', '2026-10-08 07:39:13'),
(207, 1, 'LOGIN', 'User', 1, 'User logged in', '127.0.0.1', '2026-10-08 07:40:15'),
(208, 1, 'LOGIN', 'User', 1, 'User logged in', '127.0.0.1', '2026-10-08 07:44:33'),
(209, 7, 'LOGOUT', 'User', 7, 'User logged out', '127.0.0.1', '2026-10-08 07:45:22'),
(210, 7, 'LOGIN', 'User', 7, 'User logged in', '127.0.0.1', '2026-10-08 07:45:25'),
(211, 7, 'LOGOUT', 'User', 7, 'User logged out', '127.0.0.1', '2026-10-08 07:45:29'),
(212, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-08 07:45:35'),
(213, 4, 'LOGOUT', 'User', 4, 'User logged out', '127.0.0.1', '2026-10-08 07:45:40'),
(214, 5, 'LOGIN', 'User', 5, 'User logged in', '127.0.0.1', '2026-10-08 07:45:47'),
(215, 5, 'LOGOUT', 'User', 5, 'User logged out', '127.0.0.1', '2026-10-08 07:50:17'),
(216, 5, 'LOGIN', 'User', 5, 'User logged in', '127.0.0.1', '2026-10-08 07:50:21'),
(217, 5, 'CREATE', 'ExpenseRequest', 17, 'Created expense request ME-EXP-2026-0018', '127.0.0.1', '2026-10-08 07:51:59'),
(218, 5, 'STATUS_CHANGE', 'ExpenseRequest', 17, 'Request submitted: ME-EXP-2026-0018', '127.0.0.1', '2026-10-08 07:51:59'),
(219, 5, 'LOGOUT', 'User', 5, 'User logged out', '127.0.0.1', '2026-10-08 07:52:06'),
(220, 5, 'LOGIN', 'User', 5, 'User logged in', '127.0.0.1', '2026-10-08 07:52:15'),
(221, 5, 'LOGOUT', 'User', 5, 'User logged out', '127.0.0.1', '2026-10-08 07:52:19'),
(222, 6, 'LOGIN', 'User', 6, 'User logged in', '127.0.0.1', '2026-10-08 07:52:24'),
(223, 6, 'LOGOUT', 'User', 6, 'User logged out', '127.0.0.1', '2026-10-08 07:52:28'),
(224, 7, 'LOGIN', 'User', 7, 'User logged in', '127.0.0.1', '2026-10-08 07:52:35'),
(225, 7, 'LOGOUT', 'User', 7, 'User logged out', '127.0.0.1', '2026-10-08 07:53:47'),
(226, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-08 07:54:49'),
(227, 4, 'UPLOAD', 'Attachment', 6, 'Uploaded Quotation: Milestone_EdTech_Framework_Sections_1-4.docx', '127.0.0.1', '2026-10-08 07:55:08'),
(228, 4, 'LOGOUT', 'User', 4, 'User logged out', '127.0.0.1', '2026-10-08 07:55:29'),
(229, 5, 'LOGIN', 'User', 5, 'User logged in', '127.0.0.1', '2026-10-08 07:55:40'),
(230, 5, 'UPLOAD', 'Attachment', 7, 'Uploaded Quotation: Milestone_EdTech_Framework_Sections_1-4.docx', '127.0.0.1', '2026-10-08 07:56:09'),
(231, 5, 'LOGOUT', 'User', 5, 'User logged out', '127.0.0.1', '2026-10-08 07:56:20'),
(232, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-08 07:56:26'),
(233, 4, 'STATUS_CHANGE', 'ExpenseRequest', 17, 'Request verified by Mary Accountant', '127.0.0.1', '2026-10-08 07:56:31'),
(234, 4, 'LOGOUT', 'User', 4, 'User logged out', '127.0.0.1', '2026-10-08 07:56:47'),
(235, 5, 'LOGIN', 'User', 5, 'User logged in', '127.0.0.1', '2026-10-08 07:56:53'),
(236, 5, 'LOGOUT', 'User', 5, 'User logged out', '127.0.0.1', '2026-10-08 07:56:58'),
(237, 6, 'LOGIN', 'User', 6, 'User logged in', '127.0.0.1', '2026-10-08 07:57:05'),
(238, 6, 'CREATE', 'ExpenseRequest', 18, 'Created expense request ME-EXP-2026-0019', '127.0.0.1', '2026-10-08 07:58:20'),
(239, 6, 'STATUS_CHANGE', 'ExpenseRequest', 18, 'Request submitted: ME-EXP-2026-0019', '127.0.0.1', '2026-10-08 07:58:21'),
(240, 6, 'LOGOUT', 'User', 6, 'User logged out', '127.0.0.1', '2026-10-08 07:58:24'),
(241, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-08 07:58:30'),
(242, 4, 'STATUS_CHANGE', 'ExpenseRequest', 18, 'Request verified by Mary Accountant', '127.0.0.1', '2026-10-08 07:58:38'),
(243, 4, 'LOGOUT', 'User', 4, 'User logged out', '127.0.0.1', '2026-10-08 07:58:44'),
(244, 5, 'LOGIN', 'User', 5, 'User logged in', '127.0.0.1', '2026-10-08 07:58:55'),
(245, 5, 'LOGOUT', 'User', 5, 'User logged out', '127.0.0.1', '2026-10-08 08:04:16'),
(246, 6, 'LOGIN', 'User', 6, 'User logged in', '127.0.0.1', '2026-10-08 08:04:28'),
(247, 6, 'LOGOUT', 'User', 6, 'User logged out', '127.0.0.1', '2026-10-08 08:05:25'),
(248, 7, 'LOGIN', 'User', 7, 'User logged in', '127.0.0.1', '2026-10-08 08:05:32'),
(249, 5, 'LOGIN', 'User', 5, 'User logged in', '127.0.0.1', '2026-10-08 08:24:32'),
(250, 5, 'LOGOUT', 'User', 5, 'User logged out', '127.0.0.1', '2026-10-08 08:24:40'),
(251, 6, 'LOGIN', 'User', 6, 'User logged in', '127.0.0.1', '2026-10-08 08:24:57'),
(252, 6, 'LOGOUT', 'User', 6, 'User logged out', '127.0.0.1', '2026-10-08 08:25:06'),
(253, 7, 'LOGIN', 'User', 7, 'User logged in', '127.0.0.1', '2026-10-08 08:25:29'),
(254, 7, 'LOGOUT', 'User', 7, 'User logged out', '127.0.0.1', '2026-10-08 08:25:50'),
(255, 6, 'LOGIN', 'User', 6, 'User logged in', '127.0.0.1', '2026-10-08 08:29:12'),
(256, 6, 'LOGOUT', 'User', 6, 'User logged out', '127.0.0.1', '2026-10-08 08:29:44'),
(257, 3, 'LOGIN', 'User', 3, 'User logged in', '127.0.0.1', '2026-10-08 08:29:58'),
(258, 3, 'LOGIN', 'User', 3, 'User logged in', '127.0.0.1', '2026-10-08 08:32:23'),
(259, 3, 'CREATE', 'ExpenseRequest', 19, 'Created expense request ME-EXP-2026-0020', '127.0.0.1', '2026-10-08 08:32:25'),
(260, 3, 'LOGOUT', 'User', 3, 'User logged out', '127.0.0.1', '2026-10-08 08:34:02'),
(261, 6, 'LOGIN', 'User', 6, 'User logged in', '127.0.0.1', '2026-10-08 08:34:37'),
(262, 6, 'LOGOUT', 'User', 6, 'User logged out', '127.0.0.1', '2026-10-08 08:34:51'),
(263, 7, 'LOGIN', 'User', 7, 'User logged in', '127.0.0.1', '2026-10-08 08:35:05'),
(264, 7, 'LOGOUT', 'User', 7, 'User logged out', '127.0.0.1', '2026-10-08 08:35:11'),
(265, 5, 'LOGIN', 'User', 5, 'User logged in', '127.0.0.1', '2026-10-08 08:35:32'),
(266, 5, 'LOGOUT', 'User', 5, 'User logged out', '127.0.0.1', '2026-10-08 08:36:11'),
(267, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-08 08:36:30'),
(268, 4, 'UPLOAD', 'Attachment', 8, 'Uploaded Quotation: Milestone_EdTech_Framework_Sections_1-4.docx', '127.0.0.1', '2026-10-08 08:36:53'),
(269, 4, 'LOGOUT', 'User', 4, 'User logged out', '127.0.0.1', '2026-10-08 08:36:57'),
(270, 6, 'LOGIN', 'User', 6, 'User logged in', '127.0.0.1', '2026-10-08 08:37:25'),
(271, 6, 'LOGOUT', 'User', 6, 'User logged out', '127.0.0.1', '2026-10-08 08:37:39'),
(272, 5, 'LOGIN', 'User', 5, 'User logged in', '127.0.0.1', '2026-10-08 08:37:52'),
(273, 5, 'LOGOUT', 'User', 5, 'User logged out', '127.0.0.1', '2026-10-08 08:37:58'),
(274, 7, 'LOGIN', 'User', 7, 'User logged in', '127.0.0.1', '2026-10-08 08:38:14'),
(275, 7, 'LOGOUT', 'User', 7, 'User logged out', '127.0.0.1', '2026-10-08 08:39:57'),
(276, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-08 08:40:14'),
(277, 4, 'STATUS_CHANGE', 'ExpenseRequest', 16, 'Request verified by Mary Accountant', '127.0.0.1', '2026-10-08 08:40:26'),
(278, 4, 'LOGOUT', 'User', 4, 'User logged out', '127.0.0.1', '2026-10-08 08:40:32'),
(279, 7, 'LOGIN', 'User', 7, 'User logged in', '127.0.0.1', '2026-10-08 08:40:53'),
(280, 7, 'LOGOUT', 'User', 7, 'User logged out', '127.0.0.1', '2026-10-08 08:41:09'),
(281, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-08 08:41:21'),
(282, 4, 'UPLOAD', 'Attachment', 9, 'Uploaded Quotation: Expense_Tracker_Dashboard_Suggested_Improvements.pdf', '127.0.0.1', '2026-10-08 08:41:39'),
(283, 4, 'LOGOUT', 'User', 4, 'User logged out', '127.0.0.1', '2026-10-08 08:42:00'),
(284, 10, 'LOGIN', 'User', 10, 'User logged in', '127.0.0.1', '2026-10-08 08:42:11'),
(285, 10, 'CREATE', 'ExpenseRequest', 20, 'Created expense request ME-EXP-2026-0021', '127.0.0.1', '2026-10-08 08:43:41'),
(286, 10, 'STATUS_CHANGE', 'ExpenseRequest', 20, 'Request submitted: ME-EXP-2026-0021', '127.0.0.1', '2026-10-08 08:43:41'),
(287, 10, 'LOGOUT', 'User', 10, 'User logged out', '127.0.0.1', '2026-10-08 08:43:45'),
(288, 6, 'LOGIN', 'User', 6, 'User logged in', '127.0.0.1', '2026-10-08 08:44:07'),
(289, 6, 'LOGOUT', 'User', 6, 'User logged out', '127.0.0.1', '2026-10-08 08:44:12'),
(290, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-08 08:44:26'),
(291, 4, 'LOGOUT', 'User', 4, 'User logged out', '127.0.0.1', '2026-10-08 08:44:34'),
(292, 10, 'LOGIN', 'User', 10, 'User logged in', '127.0.0.1', '2026-10-08 08:44:44'),
(293, 10, 'UPLOAD', 'Attachment', 10, 'Uploaded Quotation: Milestone_EdTech_Framework_Sections_1-4.docx', '127.0.0.1', '2026-10-08 08:45:11'),
(294, 10, 'LOGOUT', 'User', 10, 'User logged out', '127.0.0.1', '2026-10-08 08:45:14'),
(295, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-08 08:45:27'),
(296, 4, 'STATUS_CHANGE', 'ExpenseRequest', 20, 'Request verified by Mary Accountant', '127.0.0.1', '2026-10-08 08:45:34'),
(297, 4, 'LOGOUT', 'User', 4, 'User logged out', '127.0.0.1', '2026-10-08 08:45:36'),
(298, 6, 'LOGIN', 'User', 6, 'User logged in', '127.0.0.1', '2026-10-08 08:45:48'),
(299, 6, 'LOGOUT', 'User', 6, 'User logged out', '127.0.0.1', '2026-10-08 08:45:54'),
(300, 9, 'LOGIN', 'User', 9, 'User logged in', '127.0.0.1', '2026-10-08 08:46:05'),
(301, 9, 'STATUS_CHANGE', 'ExpenseRequest', 14, 'Request verified by hhhh', '127.0.0.1', '2026-10-08 08:46:17'),
(302, 9, 'STATUS_CHANGE', 'ExpenseRequest', 15, 'Request verified by hhhh', '127.0.0.1', '2026-10-08 08:46:25'),
(303, 9, 'LOGOUT', 'User', 9, 'User logged out', '127.0.0.1', '2026-10-08 08:46:36'),
(304, 6, 'LOGIN', 'User', 6, 'User logged in', '127.0.0.1', '2026-10-08 08:46:52'),
(305, 6, 'LOGOUT', 'User', 6, 'User logged out', '127.0.0.1', '2026-10-08 08:47:03'),
(306, 9, 'LOGIN', 'User', 9, 'User logged in', '127.0.0.1', '2026-10-08 08:47:21'),
(307, 9, 'LOGOUT', 'User', 9, 'User logged out', '127.0.0.1', '2026-10-08 08:49:51'),
(308, 7, 'LOGIN', 'User', 7, 'User logged in', '127.0.0.1', '2026-10-08 08:51:00'),
(309, 7, 'CREATE', 'ExpenseRequest', 21, 'Created expense request ME-EXP-2026-0022', '127.0.0.1', '2026-10-08 08:52:14'),
(310, 7, 'STATUS_CHANGE', 'ExpenseRequest', 21, 'Request submitted: ME-EXP-2026-0022', '127.0.0.1', '2026-10-08 08:52:14'),
(311, 7, 'UPLOAD', 'Attachment', 11, 'Uploaded Quotation: Milestone_EdTech_Framework_Sections_1-4.docx', '127.0.0.1', '2026-10-08 08:52:26'),
(312, 7, 'LOGOUT', 'User', 7, 'User logged out', '127.0.0.1', '2026-10-08 08:52:55'),
(313, 5, 'LOGIN', 'User', 5, 'User logged in', '127.0.0.1', '2026-10-08 08:53:17'),
(314, 5, 'LOGOUT', 'User', 5, 'User logged out', '127.0.0.1', '2026-10-08 08:53:23'),
(315, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-08 08:53:39'),
(316, 4, 'STATUS_CHANGE', 'ExpenseRequest', 21, 'Request verified by Mary Accountant', '127.0.0.1', '2026-10-08 08:53:48'),
(317, 4, 'LOGOUT', 'User', 4, 'User logged out', '127.0.0.1', '2026-10-08 08:54:01'),
(318, 5, 'LOGIN', 'User', 5, 'User logged in', '127.0.0.1', '2026-10-08 08:54:15'),
(319, 5, 'LOGOUT', 'User', 5, 'User logged out', '127.0.0.1', '2026-10-08 08:54:23'),
(320, 1, 'LOGIN', 'User', 1, 'User logged in', '127.0.0.1', '2026-10-08 08:54:45'),
(321, 1, 'LOGOUT', 'User', 1, 'User logged out', '127.0.0.1', '2026-10-08 08:55:34'),
(322, 8, 'LOGIN', 'User', 8, 'User logged in', '127.0.0.1', '2026-10-08 08:59:17'),
(323, 8, 'LOGOUT', 'User', 8, 'User logged out', '127.0.0.1', '2026-10-08 09:02:17'),
(324, 7, 'LOGIN', 'User', 7, 'User logged in', '127.0.0.1', '2026-10-08 09:02:32'),
(325, 7, 'LOGOUT', 'User', 7, 'User logged out', '127.0.0.1', '2026-10-08 09:02:42'),
(326, 9, 'LOGIN', 'User', 9, 'User logged in', '127.0.0.1', '2026-10-08 09:02:55'),
(327, 9, 'CREATE', 'ExpenseRequest', 22, 'Created expense request ME-EXP-2026-0023', '127.0.0.1', '2026-10-08 09:04:01'),
(328, 9, 'STATUS_CHANGE', 'ExpenseRequest', 22, 'Request submitted: ME-EXP-2026-0023', '127.0.0.1', '2026-10-08 09:04:01'),
(329, 9, 'UPLOAD', 'Attachment', 12, 'Uploaded Quotation: Milestone_EdTech_Framework_Sections_1-4.docx', '127.0.0.1', '2026-10-08 09:04:16'),
(330, 9, 'LOGOUT', 'User', 9, 'User logged out', '127.0.0.1', '2026-10-08 09:04:19'),
(331, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-08 09:04:43'),
(332, 4, 'STATUS_CHANGE', 'ExpenseRequest', 22, 'Request verified by Mary Accountant', '127.0.0.1', '2026-10-08 09:04:58'),
(333, 4, 'LOGOUT', 'User', 4, 'User logged out', '127.0.0.1', '2026-10-08 09:05:00'),
(334, 7, 'LOGIN', 'User', 7, 'User logged in', '127.0.0.1', '2026-10-08 09:05:55'),
(335, 7, 'LOGOUT', 'User', 7, 'User logged out', '127.0.0.1', '2026-10-08 09:06:16'),
(336, 11, 'LOGIN', 'User', 11, 'User logged in', '127.0.0.1', '2026-10-08 09:12:23'),
(337, 11, 'LOGOUT', 'User', 11, 'User logged out', '127.0.0.1', '2026-10-08 09:16:55'),
(338, 7, 'LOGIN', 'User', 7, 'User logged in', '127.0.0.1', '2026-10-08 09:17:47'),
(339, 7, 'CREATE', 'ExpenseRequest', 23, 'Created expense request ME-EXP-2026-0024', '127.0.0.1', '2026-10-08 09:21:52'),
(340, 7, 'STATUS_CHANGE', 'ExpenseRequest', 23, 'Request submitted: ME-EXP-2026-0024', '127.0.0.1', '2026-10-08 09:21:52'),
(341, 7, 'UPLOAD', 'Attachment', 13, 'Uploaded Quotation: Milestone_EdTech_Framework_Sections_1-4.docx', '127.0.0.1', '2026-10-08 09:22:46'),
(342, 7, 'LOGOUT', 'User', 7, 'User logged out', '127.0.0.1', '2026-10-08 09:23:20'),
(343, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-08 09:23:36'),
(344, 4, 'STATUS_CHANGE', 'ExpenseRequest', 23, 'Request verified by Mary Accountant', '127.0.0.1', '2026-10-08 09:24:11'),
(345, 4, 'LOGOUT', 'User', 4, 'User logged out', '127.0.0.1', '2026-10-08 09:25:40'),
(346, 3, 'LOGIN', 'User', 3, 'User logged in', '127.0.0.1', '2026-10-08 09:26:16'),
(347, 3, 'LOGOUT', 'User', 3, 'User logged out', '127.0.0.1', '2026-10-08 09:27:11'),
(348, 6, 'LOGIN', 'User', 6, 'User logged in', '127.0.0.1', '2026-10-08 09:27:26'),
(349, 6, 'LOGOUT', 'User', 6, 'User logged out', '127.0.0.1', '2026-10-08 09:28:14'),
(350, 8, 'LOGIN', 'User', 8, 'User logged in', '127.0.0.1', '2026-10-08 09:28:38'),
(351, 8, 'PAYMENT', 'ExpenseRequest', 13, 'Payment executed. Ref: ksavbbbb, Amount: 122.00', '127.0.0.1', '2026-10-08 09:29:29'),
(352, 7, 'LOGIN', 'User', 7, 'User logged in', '127.0.0.1', '2026-10-09 08:28:41'),
(353, 7, 'LOGOUT', 'User', 7, 'User logged out', '127.0.0.1', '2026-10-09 08:30:30'),
(354, 6, 'LOGIN', 'User', 6, 'User logged in', '127.0.0.1', '2026-10-09 08:30:41'),
(355, 7, 'LOGIN', 'User', 7, 'User logged in', '127.0.0.1', '2026-10-09 08:31:48'),
(356, 6, 'APPROVE', 'ExpenseRequest', 20, 'Request approved by Sarah Managing Director. Comments: Thhhh', '127.0.0.1', '2026-10-09 08:33:05'),
(357, 7, 'LOGOUT', 'User', 7, 'User logged out', '127.0.0.1', '2026-10-09 08:35:37'),
(358, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-09 08:36:01'),
(359, 6, 'CREATE', 'ExpenseRequest', 24, 'Created expense request ME-EXP-2026-0025', '127.0.0.1', '2026-10-09 08:38:20'),
(360, 6, 'STATUS_CHANGE', 'ExpenseRequest', 24, 'Request submitted: ME-EXP-2026-0025', '127.0.0.1', '2026-10-09 08:38:20'),
(361, 6, 'UPLOAD', 'Attachment', 14, 'Uploaded Quotation: Milestone_EdTech_Framework_Sections_1-4.docx', '127.0.0.1', '2026-10-09 08:38:35'),
(362, 4, 'STATUS_CHANGE', 'ExpenseRequest', 24, 'Request verified by Mary Accountant', '127.0.0.1', '2026-10-09 08:39:16'),
(363, 6, 'LOGOUT', 'User', 6, 'User logged out', '127.0.0.1', '2026-10-09 08:41:02'),
(364, 5, 'LOGIN', 'User', 5, 'User logged in', '127.0.0.1', '2026-10-09 08:41:16'),
(365, 5, 'REJECT', 'ExpenseRequest', 24, 'Request rejected by David Director. Reason: Rejected', '127.0.0.1', '2026-10-09 08:41:42'),
(366, 4, 'LOGOUT', 'User', 4, 'User logged out', '127.0.0.1', '2026-10-09 08:43:11'),
(367, 8, 'LOGIN', 'User', 8, 'User logged in', '127.0.0.1', '2026-10-09 08:43:42'),
(368, 8, 'PAYMENT', 'ExpenseRequest', 20, 'Payment executed. Ref: wwww, Amount: 2000.00', '127.0.0.1', '2026-10-09 08:44:55'),
(369, 6, 'APPROVE', 'ExpenseRequest', 14, 'Request approved by Sarah Managing Director. Comments: Approved by MD test', NULL, '2026-10-09 09:14:52'),
(370, 5, 'LOGIN', 'User', 5, 'User logged in', '127.0.0.1', '2026-10-09 09:17:40'),
(371, 5, 'APPROVE', 'ExpenseRequest', 21, 'Request approved by David Director. Comments: Checked', '127.0.0.1', '2026-10-09 09:18:08'),
(372, 5, 'APPROVE', 'ExpenseRequest', 23, 'Request approved by David Director. Comments: Approved', '127.0.0.1', '2026-10-09 09:22:32'),
(373, 5, 'LOGOUT', 'User', 5, 'User logged out', '127.0.0.1', '2026-10-09 09:22:54'),
(374, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-09 09:23:13'),
(375, 4, 'LOGOUT', 'User', 4, 'User logged out', '127.0.0.1', '2026-10-09 09:23:50'),
(376, 9, 'LOGIN', 'User', 9, 'User logged in', '127.0.0.1', '2026-10-09 09:25:16'),
(377, 9, 'CREATE', 'ExpenseRequest', 25, 'Created expense request ME-EXP-2026-0026', '127.0.0.1', '2026-10-09 09:38:59'),
(378, 9, 'STATUS_CHANGE', 'ExpenseRequest', 25, 'Request submitted: ME-EXP-2026-0026', '127.0.0.1', '2026-10-09 09:38:59'),
(379, 9, 'UPLOAD', 'Attachment', 15, 'Uploaded Quotation: Milestone_EdTech_Framework_Sections_1-4.docx', '127.0.0.1', '2026-10-09 09:39:46'),
(380, 9, 'LOGOUT', 'User', 9, 'User logged out', '127.0.0.1', '2026-10-09 09:39:48'),
(381, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-09 09:40:06'),
(382, 4, 'REJECT', 'ExpenseRequest', 25, 'Request rejected by Mary Accountant. Reason: Try small amount', '127.0.0.1', '2026-10-09 09:41:33'),
(383, 4, 'LOGOUT', 'User', 4, 'User logged out', '127.0.0.1', '2026-10-09 09:43:03'),
(384, 8, 'LOGIN', 'User', 8, 'User logged in', '127.0.0.1', '2026-10-09 09:43:23'),
(385, 8, 'PAYMENT', 'ExpenseRequest', 21, 'Payment executed. Ref: TXN-2165-2026, Amount: 200.00', '127.0.0.1', '2026-10-09 09:45:14'),
(386, 8, 'STATUS_CHANGE', 'ExpenseRequest', 21, 'Payment proof attached: expense_requests_2026-10-09.pdf', '127.0.0.1', '2026-10-09 09:53:57'),
(387, 8, 'UPLOAD', 'Attachment', 16, 'Uploaded Proof of Payment: expense_requests_2026-10-09.pdf', '127.0.0.1', '2026-10-09 09:53:57'),
(388, 8, 'LOGOUT', 'User', 8, 'User logged out', '127.0.0.1', '2026-10-09 09:54:11'),
(389, 1, 'LOGIN', 'User', 1, 'User logged in', '127.0.0.1', '2026-10-09 09:54:32'),
(390, 6, 'APPROVE', 'ExpenseRequest', 15, 'Request approved by Sarah Managing Director. Comments: Approved by MD test', NULL, '2026-10-09 10:08:59'),
(391, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-09 10:12:10'),
(392, 4, 'LOGOUT', 'User', 4, 'User logged out', '127.0.0.1', '2026-10-09 10:16:50'),
(393, 9, 'LOGIN', 'User', 9, 'User logged in', '127.0.0.1', '2026-10-09 10:17:04'),
(394, 9, 'LOGOUT', 'User', 9, 'User logged out', '127.0.0.1', '2026-10-09 10:18:07'),
(395, 11, 'LOGIN', 'User', 11, 'User logged in', '127.0.0.1', '2026-10-09 10:19:45'),
(396, 11, 'PAYMENT', 'ExpenseRequest', 9, 'Payment executed. Ref: TXN-20261006-001, Amount: 5852.00', '127.0.0.1', '2026-10-09 10:21:02'),
(397, 11, 'CREATE', 'ExpenseRequest', 26, 'Created expense request ME-EXP-2026-0027', '127.0.0.1', '2026-10-09 10:22:34'),
(398, 11, 'STATUS_CHANGE', 'ExpenseRequest', 26, 'Request submitted: ME-EXP-2026-0027', '127.0.0.1', '2026-10-09 10:22:34'),
(399, 11, 'UPLOAD', 'Attachment', 17, 'Uploaded Quotation: expense_requests_2026-10-09.pdf', '127.0.0.1', '2026-10-09 10:22:50'),
(400, 11, 'LOGOUT', 'User', 11, 'User logged out', '127.0.0.1', '2026-10-09 10:22:54'),
(401, 9, 'LOGIN', 'User', 9, 'User logged in', '127.0.0.1', '2026-10-09 10:23:22'),
(402, 9, 'CREATE', 'ExpenseRequest', 27, 'Created expense request ME-EXP-2026-0028', '127.0.0.1', '2026-10-09 10:25:14'),
(403, 9, 'STATUS_CHANGE', 'ExpenseRequest', 27, 'Request submitted: ME-EXP-2026-0028', '127.0.0.1', '2026-10-09 10:25:14'),
(404, 9, 'UPLOAD', 'Attachment', 18, 'Uploaded Quotation: Milestone_EdTech_Framework_Sections_1-4.docx', '127.0.0.1', '2026-10-09 10:25:27'),
(405, 9, 'LOGOUT', 'User', 9, 'User logged out', '127.0.0.1', '2026-10-09 10:25:52'),
(406, 6, 'LOGIN', 'User', 6, 'User logged in', '127.0.0.1', '2026-10-09 10:26:37'),
(407, 6, 'CREATE', 'ExpenseRequest', 28, 'Created expense request ME-EXP-2026-0029', '127.0.0.1', '2026-10-09 10:27:30'),
(408, 6, 'STATUS_CHANGE', 'ExpenseRequest', 28, 'Request submitted: ME-EXP-2026-0029', '127.0.0.1', '2026-10-09 10:27:30'),
(409, 6, 'UPLOAD', 'Attachment', 19, 'Uploaded Quotation: expense_requests_2026-10-09.pdf', '127.0.0.1', '2026-10-09 10:27:52'),
(410, 6, 'LOGOUT', 'User', 6, 'User logged out', '127.0.0.1', '2026-10-09 10:27:57'),
(411, 7, 'LOGIN', 'User', 7, 'User logged in', '127.0.0.1', '2026-10-09 10:28:21'),
(412, 7, 'CREATE', 'ExpenseRequest', 29, 'Created expense request ME-EXP-2026-0030', '127.0.0.1', '2026-10-09 10:29:36'),
(413, 7, 'STATUS_CHANGE', 'ExpenseRequest', 29, 'Request submitted: ME-EXP-2026-0030', '127.0.0.1', '2026-10-09 10:29:36'),
(414, 7, 'UPLOAD', 'Attachment', 20, 'Uploaded Quotation: Milestone_EdTech_Framework_Sections_1-4.docx', '127.0.0.1', '2026-10-09 10:29:47'),
(415, 7, 'LOGOUT', 'User', 7, 'User logged out', '127.0.0.1', '2026-10-09 10:29:53'),
(416, 5, 'LOGIN', 'User', 5, 'User logged in', '127.0.0.1', '2026-10-09 10:30:19'),
(417, 5, 'LOGOUT', 'User', 5, 'User logged out', '127.0.0.1', '2026-10-09 10:30:29'),
(418, 6, 'LOGIN', 'User', 6, 'User logged in', '127.0.0.1', '2026-10-09 10:30:44'),
(419, 6, 'LOGOUT', 'User', 6, 'User logged out', '127.0.0.1', '2026-10-09 10:30:58'),
(420, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-09 10:31:12'),
(421, 4, 'STATUS_CHANGE', 'ExpenseRequest', 29, 'Request verified by Mary Accountant. Comments: None', '127.0.0.1', '2026-10-09 10:31:24'),
(422, 4, 'STATUS_CHANGE', 'ExpenseRequest', 28, 'Request verified by Mary Accountant. Comments: None', '127.0.0.1', '2026-10-09 10:31:32'),
(423, 4, 'STATUS_CHANGE', 'ExpenseRequest', 26, 'Request verified by Mary Accountant. Comments: None', '127.0.0.1', '2026-10-09 10:31:40'),
(424, 4, 'LOGOUT', 'User', 4, 'User logged out', '127.0.0.1', '2026-10-09 10:31:42'),
(425, 5, 'LOGIN', 'User', 5, 'User logged in', '127.0.0.1', '2026-10-09 10:31:55'),
(426, 5, 'LOGOUT', 'User', 5, 'User logged out', '127.0.0.1', '2026-10-09 10:32:09'),
(427, 6, 'LOGIN', 'User', 6, 'User logged in', '127.0.0.1', '2026-10-09 10:32:22'),
(428, 6, 'LOGOUT', 'User', 6, 'User logged out', '127.0.0.1', '2026-10-09 10:32:28'),
(429, 7, 'LOGIN', 'User', 7, 'User logged in', '127.0.0.1', '2026-10-09 10:32:52'),
(430, 7, 'LOGOUT', 'User', 7, 'User logged out', '127.0.0.1', '2026-10-09 10:36:35'),
(431, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-09 10:55:02'),
(432, 4, 'LOGOUT', 'User', 4, 'User logged out', '127.0.0.1', '2026-10-09 10:56:22'),
(433, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-09 11:05:18'),
(434, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-09 11:13:11'),
(435, 4, 'LOGOUT', 'User', 4, 'User logged out', '127.0.0.1', '2026-10-09 11:24:29'),
(436, 9, 'LOGIN', 'User', 9, 'User logged in', '127.0.0.1', '2026-10-09 11:24:41'),
(437, 9, 'LOGOUT', 'User', 9, 'User logged out', '127.0.0.1', '2026-10-09 11:24:55'),
(438, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-09 11:25:08'),
(439, 4, 'LOGOUT', 'User', 4, 'User logged out', '127.0.0.1', '2026-10-09 11:25:32'),
(440, 7, 'LOGIN', 'User', 7, 'User logged in', '127.0.0.1', '2026-10-09 11:25:48'),
(441, 7, 'LOGOUT', 'User', 7, 'User logged out', '127.0.0.1', '2026-10-09 11:38:19'),
(442, 7, 'LOGIN', 'User', 7, 'User logged in', '127.0.0.1', '2026-10-09 11:38:33'),
(443, 7, 'LOGIN', 'User', 7, 'User logged in', '127.0.0.1', '2026-10-09 12:17:14'),
(444, 7, 'CREATE', 'ExpenseRequest', 30, 'Created expense request ME-EXP-2026-0031', '127.0.0.1', '2026-10-09 12:18:49'),
(445, 7, 'STATUS_CHANGE', 'ExpenseRequest', 30, 'Request submitted: ME-EXP-2026-0031', '127.0.0.1', '2026-10-09 12:18:49'),
(446, 7, 'UPLOAD', 'Attachment', 21, 'Uploaded Quotation: Expense_Tracker_Dashboard_Suggested_Improvements.pdf', '127.0.0.1', '2026-10-09 12:21:19'),
(447, 7, 'LOGOUT', 'User', 7, 'User logged out', '127.0.0.1', '2026-10-09 12:21:35'),
(448, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-09 12:21:55'),
(449, 4, 'STATUS_CHANGE', 'ExpenseRequest', 30, 'Request verified by Mary Accountant. Comments: Move to next step', '127.0.0.1', '2026-10-09 12:23:43'),
(450, 4, 'LOGOUT', 'User', 4, 'User logged out', '127.0.0.1', '2026-10-09 12:25:10'),
(451, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-09 12:25:41'),
(452, 4, 'LOGOUT', 'User', 4, 'User logged out', '127.0.0.1', '2026-10-09 12:26:12'),
(453, 5, 'LOGIN', 'User', 5, 'User logged in', '127.0.0.1', '2026-10-09 12:26:52'),
(454, 5, 'APPROVE', 'ExpenseRequest', 30, 'Request approved by David Director. Comments: next', '127.0.0.1', '2026-10-09 12:27:48'),
(455, 5, 'LOGOUT', 'User', 5, 'User logged out', '127.0.0.1', '2026-10-09 12:30:16'),
(456, 8, 'LOGIN', 'User', 8, 'User logged in', '127.0.0.1', '2026-10-09 12:30:35'),
(457, 8, 'LOGOUT', 'User', 8, 'User logged out', '127.0.0.1', '2026-10-09 12:37:24'),
(458, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-09 12:37:37'),
(459, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-09 13:55:21'),
(460, 4, 'LOGOUT', 'User', 4, 'User logged out', '127.0.0.1', '2026-10-09 13:56:40'),
(461, 8, 'LOGIN', 'User', 8, 'User logged in', '127.0.0.1', '2026-10-09 13:57:14'),
(462, 8, 'PAYMENT', 'ExpenseRequest', 30, 'Payment executed. Ref: TXN-20261006-001, Amount: 400.00', '127.0.0.1', '2026-10-09 13:57:59'),
(463, 8, 'STATUS_CHANGE', 'ExpenseRequest', 30, 'Payment proof attached: Administration_Specialist_JD.docx', '127.0.0.1', '2026-10-09 13:58:53'),
(464, 8, 'UPLOAD', 'Attachment', 22, 'Uploaded Proof of Payment: Administration_Specialist_JD.docx', '127.0.0.1', '2026-10-09 13:58:53'),
(465, 8, 'PAYMENT', 'ExpenseRequest', 23, 'Payment executed. Ref: TXN-20261006-001, Amount: 200.00', '127.0.0.1', '2026-10-09 14:00:00'),
(466, 8, 'STATUS_CHANGE', 'ExpenseRequest', 30, 'Payment proof attached: Administration_Specialist_JD.docx', '127.0.0.1', '2026-10-09 14:00:33'),
(467, 8, 'UPLOAD', 'Attachment', 23, 'Uploaded Proof of Payment: Administration_Specialist_JD.docx', '127.0.0.1', '2026-10-09 14:00:33'),
(468, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-09 14:21:48'),
(469, 4, 'LOGOUT', 'User', 4, 'User logged out', '127.0.0.1', '2026-10-09 14:22:14'),
(470, 5, 'LOGIN', 'User', 5, 'User logged in', '127.0.0.1', '2026-10-09 14:22:29'),
(471, 5, 'LOGOUT', 'User', 5, 'User logged out', '127.0.0.1', '2026-10-09 14:23:27'),
(472, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-09 14:23:42'),
(473, 4, 'STATUS_CHANGE', 'ExpenseRequest', 27, 'Request verified by Mary Accountant. Comments: None', '127.0.0.1', '2026-10-09 14:27:43'),
(474, 4, 'LOGOUT', 'User', 4, 'User logged out', '127.0.0.1', '2026-10-09 14:28:58'),
(475, 8, 'LOGIN', 'User', 8, 'User logged in', '127.0.0.1', '2026-10-09 14:29:20'),
(476, 8, 'PAYMENT', 'ExpenseRequest', 15, 'Payment executed. Ref: TXN-20261006-001, Amount: 74688642.00', '127.0.0.1', '2026-10-09 14:31:14'),
(477, 8, 'LOGOUT', 'User', 8, 'User logged out', '127.0.0.1', '2026-10-09 14:38:37'),
(478, 8, 'LOGIN', 'User', 8, 'User logged in', '127.0.0.1', '2026-10-09 20:01:35'),
(479, 8, 'LOGOUT', 'User', 8, 'User logged out', '127.0.0.1', '2026-10-09 20:05:08'),
(480, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-09 20:05:23'),
(481, 4, 'LOGOUT', 'User', 4, 'User logged out', '127.0.0.1', '2026-10-09 20:08:00'),
(482, 7, 'LOGIN', 'User', 7, 'User logged in', '127.0.0.1', '2026-10-09 20:08:16'),
(483, 7, 'LOGOUT', 'User', 7, 'User logged out', '127.0.0.1', '2026-10-09 20:09:09'),
(484, 5, 'LOGIN', 'User', 5, 'User logged in', '127.0.0.1', '2026-10-09 20:09:23'),
(485, 5, 'APPROVE', 'ExpenseRequest', 29, 'Request approved by David Director. Comments: None', '127.0.0.1', '2026-10-09 20:09:53'),
(486, 5, 'LOGOUT', 'User', 5, 'User logged out', '127.0.0.1', '2026-10-09 20:11:13'),
(487, 6, 'LOGIN', 'User', 6, 'User logged in', '127.0.0.1', '2026-10-09 20:11:33'),
(488, 6, 'APPROVE', 'ExpenseRequest', 26, 'Request approved by Sarah Managing Director. Comments: None', '127.0.0.1', '2026-10-09 20:11:44'),
(489, 6, 'LOGOUT', 'User', 6, 'User logged out', '127.0.0.1', '2026-10-09 20:12:15'),
(490, 6, 'LOGIN', 'User', 6, 'User logged in', '127.0.0.1', '2026-10-09 20:14:07'),
(491, 6, 'LOGOUT', 'User', 6, 'User logged out', '127.0.0.1', '2026-10-09 20:21:07'),
(492, 8, 'LOGIN', 'User', 8, 'User logged in', '127.0.0.1', '2026-10-09 20:21:22'),
(493, 8, 'PAYMENT', 'ExpenseRequest', 29, 'Payment executed. Ref: TXN-20261006-001, Amount: 200.00', '127.0.0.1', '2026-10-09 20:22:05'),
(494, 8, 'LOGIN', 'User', 8, 'User logged in', '127.0.0.1', '2026-10-09 20:37:22'),
(495, 8, 'LOGOUT', 'User', 8, 'User logged out', '127.0.0.1', '2026-10-09 20:40:37'),
(496, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-09 20:41:12'),
(497, 4, 'LOGOUT', 'User', 4, 'User logged out', '127.0.0.1', '2026-10-09 20:44:28'),
(498, 8, 'LOGIN', 'User', 8, 'User logged in', '127.0.0.1', '2026-10-09 20:44:45'),
(499, 8, 'LOGOUT', 'User', 8, 'User logged out', '127.0.0.1', '2026-10-09 20:45:01'),
(500, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-09 20:45:30'),
(501, 4, 'LOGOUT', 'User', 4, 'User logged out', '127.0.0.1', '2026-10-09 20:46:54'),
(502, 9, 'LOGIN', 'User', 9, 'User logged in', '127.0.0.1', '2026-10-09 20:47:13'),
(503, 9, 'CREATE', 'ExpenseRequest', 31, 'Created expense request ME-EXP-2026-0032', '127.0.0.1', '2026-10-09 20:52:02'),
(504, 9, 'STATUS_CHANGE', 'ExpenseRequest', 31, 'Request submitted: ME-EXP-2026-0032', '127.0.0.1', '2026-10-09 20:52:02'),
(505, 9, 'UPLOAD', 'Attachment', 24, 'Uploaded Quotation: Expense_Tracker_Dashboard_Suggested_Improvements.pdf', '127.0.0.1', '2026-10-09 20:52:52'),
(506, 9, 'LOGOUT', 'User', 9, 'User logged out', '127.0.0.1', '2026-10-09 20:53:07'),
(507, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-09 20:53:33'),
(508, 4, 'LOGOUT', 'User', 4, 'User logged out', '127.0.0.1', '2026-10-09 20:55:34'),
(509, 8, 'LOGIN', 'User', 8, 'User logged in', '127.0.0.1', '2026-10-09 20:55:51'),
(510, 8, 'PAYMENT', 'ExpenseRequest', 26, 'Payment executed. Ref: TXN-20261006-001, Amount: 1600.00', '127.0.0.1', '2026-10-09 20:56:23'),
(511, 8, 'PAYMENT', 'ExpenseRequest', 14, 'Payment executed. Ref: TXN-20261006-001, Amount: 2211.00', '127.0.0.1', '2026-10-09 20:58:39'),
(512, 8, 'LOGOUT', 'User', 8, 'User logged out', '127.0.0.1', '2026-10-09 21:09:15'),
(513, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-09 21:09:34'),
(514, 4, 'LOGOUT', 'User', 4, 'User logged out', '127.0.0.1', '2026-10-09 21:09:57'),
(515, 1, 'LOGIN', 'User', 1, 'User logged in', '127.0.0.1', '2026-10-09 21:10:20'),
(516, 1, 'LOGOUT', 'User', 1, 'User logged out', '127.0.0.1', '2026-10-09 21:12:21'),
(517, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-09 21:12:34'),
(518, 4, 'LOGOUT', 'User', 4, 'User logged out', '127.0.0.1', '2026-10-09 21:12:44'),
(519, 7, 'LOGIN', 'User', 7, 'User logged in', '127.0.0.1', '2026-10-10 08:30:26'),
(520, 7, 'LOGOUT', 'User', 7, 'User logged out', '127.0.0.1', '2026-10-10 08:33:11'),
(521, 7, 'LOGIN', 'User', 7, 'User logged in', '127.0.0.1', '2026-10-10 08:34:47'),
(522, 7, 'LOGOUT', 'User', 7, 'User logged out', '127.0.0.1', '2026-10-10 08:34:49'),
(523, 13, 'LOGIN', 'User', 13, 'User logged in', '127.0.0.1', '2026-10-10 08:36:40'),
(524, 13, 'LOGOUT', 'User', 13, 'User logged out', '127.0.0.1', '2026-10-10 08:36:55'),
(525, 10, 'LOGIN', 'User', 10, 'User logged in', '127.0.0.1', '2026-10-10 08:37:03'),
(526, 10, 'LOGOUT', 'User', 10, 'User logged out', '127.0.0.1', '2026-10-10 08:37:08'),
(527, 4, 'LOGIN', 'User', 4, 'User logged in', '127.0.0.1', '2026-10-10 08:37:15'),
(528, 4, 'LOGOUT', 'User', 4, 'User logged out', '127.0.0.1', '2026-10-10 08:37:24'),
(529, 5, 'LOGIN', 'User', 5, 'User logged in', '127.0.0.1', '2026-10-10 08:37:29'),
(530, 5, 'LOGOUT', 'User', 5, 'User logged out', '127.0.0.1', '2026-10-10 08:37:32'),
(531, 13, 'LOGIN', 'User', 13, 'User logged in', '127.0.0.1', '2026-10-10 08:37:41'),
(532, 13, 'CREATE', 'ExpenseRequest', 32, 'Created expense request ME-EXP-2026-0033', '127.0.0.1', '2026-10-10 08:39:12'),
(533, 13, 'STATUS_CHANGE', 'ExpenseRequest', 32, 'Request submitted: ME-EXP-2026-0033', '127.0.0.1', '2026-10-10 08:39:13'),
(534, 13, 'LOGOUT', 'User', 13, 'User logged out', '127.0.0.1', '2026-10-10 08:40:40');
INSERT INTO `audit_log` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `note`, `ip_address`, `created_at`) VALUES
(535, 13, 'LOGIN', 'User', 13, 'User logged in', '127.0.0.1', '2026-10-10 08:42:53'),
(536, 13, 'LOGOUT', 'User', 13, 'User logged out', '127.0.0.1', '2026-10-10 08:46:06');

--
-- Triggers `audit_log`
--
DELIMITER $$
CREATE TRIGGER `prevent_audit_delete` BEFORE DELETE ON `audit_log` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'Audit log records cannot be deleted';
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `prevent_audit_update` BEFORE UPDATE ON `audit_log` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'Audit log records cannot be modified';
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `exchange_rates`
--

CREATE TABLE `exchange_rates` (
  `id` int(11) NOT NULL,
  `from_currency` varchar(3) NOT NULL,
  `to_currency` varchar(3) NOT NULL,
  `rate` decimal(10,6) NOT NULL,
  `effective_date` date NOT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `exchange_rates`
--

INSERT INTO `exchange_rates` (`id`, `from_currency`, `to_currency`, `rate`, `effective_date`, `created_at`) VALUES
(1, 'USD', 'USD', 1.000000, '2026-01-01', '2026-10-06 19:55:24'),
(2, 'KES', 'USD', 0.007800, '2026-01-01', '2026-10-06 19:55:24'),
(3, 'EUR', 'USD', 1.090000, '2026-01-01', '2026-10-06 19:55:24'),
(4, 'GBP', 'USD', 1.270000, '2026-01-01', '2026-10-06 19:55:24');

-- --------------------------------------------------------

--
-- Table structure for table `expense_categories`
--

CREATE TABLE `expense_categories` (
  `id` int(11) NOT NULL,
  `code` varchar(20) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `expense_categories`
--

INSERT INTO `expense_categories` (`id`, `code`, `name`, `description`, `is_active`, `created_at`) VALUES
(1, 'TRANS', 'Transport', 'Transportation and travel expenses', 1, '2026-10-06 19:55:24'),
(2, 'UTIL', 'Utilities', 'Electricity, water, internet bills', 1, '2026-10-06 19:55:24'),
(3, 'SUPPLY', 'Supplies', 'Office supplies and materials', 1, '2026-10-06 19:55:24'),
(4, 'EQUIP', 'Equipment', 'Hardware and equipment purchases', 1, '2026-10-06 19:55:24'),
(5, 'SERVICE', 'Services', 'Professional services and consultancy', 1, '2026-10-06 19:55:24'),
(6, 'RENT', 'Rent', 'Office and facility rental', 1, '2026-10-06 19:55:24'),
(7, 'SALARY', 'Salaries', 'Staff salaries and wages', 1, '2026-10-06 19:55:24'),
(8, 'TRAIN', 'Training', 'Staff training and development', 1, '2026-10-06 19:55:24'),
(9, 'MARKET', 'Marketing', 'Marketing and advertising expenses', 1, '2026-10-06 19:55:24'),
(10, 'OTHER', 'Other', 'Miscellaneous expenses', 1, '2026-10-06 19:55:24');

-- --------------------------------------------------------

--
-- Table structure for table `expense_requests`
--

CREATE TABLE `expense_requests` (
  `id` int(11) NOT NULL,
  `request_id` varchar(50) NOT NULL,
  `project_id` int(11) NOT NULL,
  `requester_id` int(11) NOT NULL,
  `department` varchar(100) DEFAULT NULL,
  `priority` varchar(20) NOT NULL DEFAULT 'Normal',
  `request_date` date NOT NULL,
  `purpose` text NOT NULL,
  `payee_name` varchar(200) NOT NULL,
  `payee_details` text DEFAULT NULL,
  `payment_method` varchar(50) NOT NULL,
  `currency` varchar(3) NOT NULL DEFAULT 'USD',
  `currency_other` varchar(20) DEFAULT NULL,
  `total_amount` decimal(14,2) NOT NULL,
  `exchange_rate_to_usd` decimal(10,6) DEFAULT 1.000000,
  `total_amount_usd` decimal(14,2) NOT NULL,
  `budget_status` varchar(50) NOT NULL DEFAULT 'Within Budget',
  `expected_payment_date` date DEFAULT NULL,
  `is_advance` tinyint(1) NOT NULL DEFAULT 0,
  `advance_retirement_deadline` date DEFAULT NULL,
  `status` varchar(50) NOT NULL DEFAULT 'Submitted',
  `submitted_at` datetime DEFAULT NULL,
  `approval_due_date` datetime DEFAULT NULL,
  `verified_by_id` int(11) DEFAULT NULL,
  `verified_at` datetime DEFAULT NULL,
  `approved_by_id` int(11) DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `rejected_by_id` int(11) DEFAULT NULL,
  `rejected_at` datetime DEFAULT NULL,
  `rejection_reason` text DEFAULT NULL,
  `payment_due_date` datetime DEFAULT NULL,
  `paid_by_id` int(11) DEFAULT NULL,
  `paid_at` datetime DEFAULT NULL,
  `receipt_due_date` datetime DEFAULT NULL,
  `payment_reference` varchar(100) DEFAULT NULL,
  `actual_amount_paid` decimal(14,2) DEFAULT NULL,
  `posted_by_id` int(11) DEFAULT NULL,
  `posted_at` datetime DEFAULT NULL,
  `ledger_reference` varchar(100) DEFAULT NULL,
  `closed_by_id` int(11) DEFAULT NULL,
  `closed_at` datetime DEFAULT NULL,
  `is_split_purchase` tinyint(1) DEFAULT 0,
  `split_purchase_flag` tinyint(1) NOT NULL DEFAULT 0,
  `split_purchase_note` text DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `expense_requests`
--

INSERT INTO `expense_requests` (`id`, `request_id`, `project_id`, `requester_id`, `department`, `priority`, `request_date`, `purpose`, `payee_name`, `payee_details`, `payment_method`, `currency`, `currency_other`, `total_amount`, `exchange_rate_to_usd`, `total_amount_usd`, `budget_status`, `expected_payment_date`, `is_advance`, `advance_retirement_deadline`, `status`, `submitted_at`, `approval_due_date`, `verified_by_id`, `verified_at`, `approved_by_id`, `approved_at`, `rejected_by_id`, `rejected_at`, `rejection_reason`, `payment_due_date`, `paid_by_id`, `paid_at`, `receipt_due_date`, `payment_reference`, `actual_amount_paid`, `posted_by_id`, `posted_at`, `ledger_reference`, `closed_by_id`, `closed_at`, `is_split_purchase`, `split_purchase_flag`, `split_purchase_note`, `created_at`, `updated_at`) VALUES
(1, 'ME-EXP-2026-0001', 2, 3, NULL, 'Normal', '2026-10-07', 'dddssc jhcvuyft', 'ABC', NULL, 'Bank Transfer', 'USD', NULL, 0.14, 1.000000, 0.14, 'Within Budget', NULL, 0, NULL, 'Draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, NULL, '2026-10-07 07:18:57', '2026-10-07 07:18:57'),
(2, 'ME-EXP-2026-0002', 1, 3, NULL, 'Normal', '2026-10-07', 'ddc jklkn kmnbvbn', 'jjjj', NULL, 'Bank Transfer', 'USD', NULL, 0.09, 1.000000, 0.09, 'Within Budget', NULL, 0, NULL, 'Draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, NULL, '2026-10-07 07:29:05', '2026-10-07 07:29:05'),
(3, 'ME-EXP-2026-0003', 1, 3, NULL, 'Normal', '2026-10-07', 'ddc jklkn kmnbvbn', 'jjjj', NULL, 'Bank Transfer', 'USD', NULL, 0.09, 1.000000, 0.09, 'Within Budget', NULL, 0, NULL, 'Draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, NULL, '2026-10-07 07:29:27', '2026-10-07 07:29:27'),
(4, 'ME-EXP-2026-0004', 1, 1, NULL, 'Normal', '2026-10-07', 'Purchase test office supplies for operations', 'Test Supplier', NULL, 'Bank Transfer', 'USD', NULL, 20.00, 1.000000, 20.00, 'Within Budget', NULL, 0, NULL, 'Draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, NULL, '2026-10-07 07:40:53', '2026-10-07 07:40:53'),
(5, 'ME-EXP-2026-0005', 1, 1, NULL, 'Normal', '2026-10-07', 'Purchase test office supplies for operations', 'Test Supplier', NULL, 'Bank Transfer', 'USD', NULL, 20.00, 1.000000, 20.00, 'Within Budget', NULL, 0, NULL, 'Paid', NULL, NULL, 4, '2026-10-07 11:21:46', 6, '2026-10-07 11:26:03', NULL, NULL, NULL, NULL, NULL, '2026-10-07 13:19:48', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, NULL, '2026-10-07 07:45:03', '2026-10-07 13:19:48'),
(6, 'ME-EXP-2026-0006', 1, 3, NULL, 'Normal', '2026-10-07', 'cdc  kkjhfbnj nnnn', 'fds ', NULL, 'Bank Transfer', 'USD', NULL, 0.15, 1.000000, 0.15, 'Within Budget', NULL, 0, NULL, 'Draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, NULL, '2026-10-07 07:49:43', '2026-10-07 07:49:43'),
(7, 'ME-EXP-2026-0007', 2, 1, NULL, 'Normal', '2026-10-07', 'bvchygv bhxv cbdc ', 'AJC Solutions', NULL, 'Mobile Money', 'KES', NULL, 191331.42, 0.007800, 1492.39, 'Within Budget', NULL, 0, NULL, 'Rejected', NULL, NULL, 4, '2026-10-07 08:21:05', 6, '2026-10-07 11:17:26', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, NULL, '2026-10-07 08:12:23', '2026-10-07 11:17:44'),
(8, 'ME-EXP-2026-0008', 2, 7, NULL, 'Normal', '2026-10-07', 'nbvcdssc gfdssc gfds', 'nbvc', NULL, 'Bank Transfer', 'USD', NULL, 73999815.00, 1.000000, 73999815.00, 'Within Budget', NULL, 0, NULL, 'Paid', NULL, NULL, 4, '2026-10-07 08:18:17', 5, '2026-10-07 11:21:08', NULL, NULL, NULL, NULL, NULL, '2026-10-08 07:09:22', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, NULL, '2026-10-07 08:16:41', '2026-10-08 07:09:22'),
(9, 'ME-EXP-2026-0009', 3, 2, NULL, 'Normal', '2026-10-07', 'dxnncnc ddd', 'hhhhh', NULL, 'Bank Transfer', 'KES', NULL, 5852.00, 0.007800, 45.65, 'Within Budget', NULL, 0, NULL, 'Paid', NULL, NULL, 4, '2026-10-07 11:33:07', 6, '2026-10-07 11:49:01', NULL, NULL, NULL, NULL, NULL, '2026-10-09 10:21:02', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, NULL, '2026-10-07 09:02:23', '2026-10-09 10:21:02'),
(10, 'ME-EXP-2026-0010', 1, 3, NULL, 'Normal', '2026-10-07', 'Testing expense request creation process', 'Test Supplier', NULL, 'Bank Transfer', 'USD', NULL, 100.00, 1.000000, 100.00, 'Within Budget', NULL, 0, NULL, 'Draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, NULL, '2026-10-07 10:20:52', '2026-10-07 10:20:52'),
(11, 'ME-EXP-2026-0011', 1, 3, NULL, 'Normal', '2026-10-07', 'Testing expense request creation process', 'Test Supplier', NULL, 'Bank Transfer', 'USD', NULL, 100.00, 1.000000, 100.00, 'Within Budget', NULL, 0, NULL, 'Draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, NULL, '2026-10-07 10:21:26', '2026-10-07 10:21:26'),
(12, 'ME-EXP-2026-0012', 2, 8, NULL, 'Normal', '2026-10-07', 'dc jhvfcdx jhcxz jhgfd', 'ddd', NULL, 'Bank Transfer', 'USD', NULL, 111.00, 1.000000, 111.00, 'Within Budget', NULL, 0, NULL, 'Approved', NULL, NULL, 4, '2026-10-07 14:00:29', 6, '2026-10-07 14:01:06', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, NULL, '2026-10-07 10:31:24', '2026-10-07 14:01:06'),
(13, 'ME-EXP-2026-0013', 2, 7, NULL, 'Normal', '2026-10-07', 'fxcvbnmn bvcx cx', 'mknbv', NULL, 'Bank Transfer', 'KES', NULL, 0.02, 0.007800, 0.00, 'Within Budget', NULL, 0, NULL, 'Paid', NULL, NULL, 4, '2026-10-07 11:52:45', 5, '2026-10-07 12:50:12', NULL, NULL, NULL, NULL, NULL, '2026-10-08 09:29:29', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, NULL, '2026-10-07 11:46:07', '2026-10-08 09:29:29'),
(14, 'ME-EXP-2026-0015', 3, 4, NULL, 'Normal', '2026-10-07', ' bcccc ggff', 'vcxz', NULL, 'Bank Transfer', 'USD', NULL, 2211.00, 1.000000, 2211.00, 'Within Budget', NULL, 0, NULL, 'Paid', NULL, NULL, 9, '2026-10-08 08:46:17', 6, '2026-10-09 09:14:52', NULL, NULL, NULL, NULL, NULL, '2026-10-09 20:58:39', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, NULL, '2026-10-07 12:52:53', '2026-10-09 20:58:39'),
(15, 'ME-EXP-2026-0016', 2, 4, NULL, 'Urgent', '2026-10-07', 'jbvvv gghh', 'bv bb', NULL, 'Bank Transfer', 'USD', NULL, 74688642.00, 1.000000, 74688642.00, 'Outside Budget-Exception', NULL, 0, NULL, 'Paid', NULL, NULL, 9, '2026-10-08 08:46:24', 6, '2026-10-09 10:08:59', NULL, NULL, NULL, NULL, NULL, '2026-10-09 14:31:14', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, NULL, '2026-10-07 12:54:04', '2026-10-09 14:31:14'),
(16, 'ME-EXP-2026-0017', 3, 10, NULL, 'Urgent', '2026-10-08', 'Last three months rent was not paid', 'Equity Bank', NULL, 'Bank Transfer', 'KES', NULL, 2000.00, 0.007800, 15.60, 'Outside Budget-Exception', NULL, 0, NULL, 'Verified', NULL, NULL, 4, '2026-10-08 08:40:26', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, NULL, '2026-10-08 07:12:25', '2026-10-08 08:40:26'),
(17, 'ME-EXP-2026-0018', 3, 5, NULL, 'Normal', '2026-10-08', 'jhgfds lkjhgfds lkjhgfd', 'hhhhh', NULL, 'Bank Transfer', 'KES', NULL, 46000.00, 0.007800, 358.80, 'Within Budget', NULL, 0, NULL, 'Verified', NULL, NULL, 4, '2026-10-08 07:56:31', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, NULL, '2026-10-08 07:51:59', '2026-10-08 07:56:31'),
(18, 'ME-EXP-2026-0019', 3, 6, NULL, 'Normal', '2026-10-08', 'fcxdbn  uhygszsdfghj ', 'hhhhh', NULL, 'Bank Transfer', 'USD', NULL, 90.00, 1.000000, 90.00, 'Within Budget', NULL, 0, NULL, 'Verified', NULL, NULL, 4, '2026-10-08 07:58:38', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, NULL, '2026-10-08 07:58:20', '2026-10-08 07:58:38'),
(19, 'ME-EXP-2026-0020', 1, 3, NULL, 'Normal', '2026-10-08', 'Testing expense request creation process', 'Test Supplier', NULL, 'Bank Transfer', 'USD', NULL, 100.00, 1.000000, 100.00, 'Within Budget', NULL, 0, NULL, 'Draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, NULL, '2026-10-08 08:32:25', '2026-10-08 08:32:25'),
(20, 'ME-EXP-2026-0021', 3, 10, NULL, 'Urgent', '2026-10-08', 'hgfc cdchhh hhhhs', 'ABC', NULL, 'Bank Transfer', 'USD', NULL, 2000.00, 1.000000, 2000.00, 'Within Budget', NULL, 0, NULL, 'Paid', NULL, NULL, 4, '2026-10-08 08:45:34', 6, '2026-10-09 08:33:05', NULL, NULL, NULL, NULL, NULL, '2026-10-09 08:44:55', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, NULL, '2026-10-08 08:43:41', '2026-10-09 08:44:55'),
(21, 'ME-EXP-2026-0022', 3, 7, NULL, 'Normal', '2026-10-08', 'ljhgfdx kdsa kjfds ', 'Chandaria Ltd', NULL, 'Bank Transfer', 'USD', NULL, 200.00, 1.000000, 200.00, 'Within Budget', NULL, 0, NULL, 'Paid', NULL, NULL, 4, '2026-10-08 08:53:48', 5, '2026-10-09 09:18:08', NULL, NULL, NULL, NULL, NULL, '2026-10-09 09:45:14', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, NULL, '2026-10-08 08:52:14', '2026-10-09 09:45:14'),
(22, 'ME-EXP-2026-0023', 1, 9, NULL, 'Normal', '2026-10-08', 'lmnb fds gfx ', 'ABC suppliers', NULL, 'Mobile Money', 'KES', NULL, 1000.00, 0.007800, 7.80, 'Within Budget', NULL, 0, NULL, 'Verified', NULL, NULL, 4, '2026-10-08 09:04:58', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, NULL, '2026-10-08 09:04:01', '2026-10-08 09:04:58'),
(23, 'ME-EXP-2026-0024', 2, 7, NULL, 'Urgent', '2026-10-08', 'jdx  hgfds ', 'ABC suppliers', NULL, 'Mobile Money', 'USD', NULL, 200.00, 1.000000, 200.00, 'Within Budget', NULL, 0, NULL, 'Paid', NULL, NULL, 4, '2026-10-08 09:24:11', 5, '2026-10-09 09:22:31', NULL, NULL, NULL, NULL, NULL, '2026-10-09 14:00:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, NULL, '2026-10-08 09:21:52', '2026-10-09 14:00:00'),
(24, 'ME-EXP-2026-0025', 3, 6, NULL, 'Normal', '2026-10-09', 'For the two interns', 'FAJET Ssolutions', NULL, 'Bank Transfer', 'KES', NULL, 60000.00, 0.007800, 468.00, 'Within Budget', NULL, 0, NULL, 'Rejected', NULL, NULL, 4, '2026-10-09 08:39:16', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, NULL, '2026-10-09 08:38:20', '2026-10-09 08:41:42'),
(25, 'ME-EXP-2026-0026', 1, 9, NULL, 'Normal', '2026-10-09', 'The reception room has no new tables.', 'G4S', NULL, 'Cash', 'KES', NULL, 20000.00, 0.007800, 156.00, 'Within Budget', NULL, 0, NULL, 'Rejected', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, NULL, '2026-10-09 09:38:59', '2026-10-09 09:41:33'),
(26, 'ME-EXP-2026-0027', 1, 11, NULL, 'Normal', '2026-10-09', 'one for quests and another one for new attachee', 'jhgfdsvvvv ', NULL, 'Bank Transfer', 'USD', NULL, 1600.00, 1.000000, 1600.00, 'Within Budget', NULL, 0, NULL, 'Paid', NULL, NULL, 4, '2026-10-09 10:31:40', 6, '2026-10-09 20:11:44', NULL, NULL, NULL, NULL, NULL, '2026-10-09 20:56:23', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, NULL, '2026-10-09 10:22:34', '2026-10-09 20:56:23'),
(27, 'ME-EXP-2026-0028', 2, 9, NULL, 'Urgent', '2026-10-09', 'For the AGM', 'Mac Donald\'s ', NULL, 'Bank Transfer', 'USD', NULL, 4200.00, 1.000000, 4200.00, 'Within Budget', NULL, 0, NULL, 'Verified', NULL, NULL, 4, '2026-10-09 14:27:43', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, NULL, '2026-10-09 10:25:14', '2026-10-09 14:27:43'),
(28, 'ME-EXP-2026-0029', 2, 6, NULL, 'Normal', '2026-10-09', 'weeeee ddddd', ';lkjhgfd', NULL, 'Bank Transfer', 'USD', NULL, 2.00, 1.000000, 2.00, 'Within Budget', NULL, 0, NULL, 'Verified', NULL, NULL, 4, '2026-10-09 10:31:32', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, NULL, '2026-10-09 10:27:30', '2026-10-09 10:31:32'),
(29, 'ME-EXP-2026-0030', 3, 7, NULL, 'Normal', '2026-10-09', ';puyds mbvcxzcvn mhfdsazxcv', 'lhgfdscv ', NULL, 'Bank Transfer', 'USD', NULL, 200.00, 1.000000, 200.00, 'Within Budget', NULL, 0, NULL, 'Paid', NULL, NULL, 4, '2026-10-09 10:31:24', 5, '2026-10-09 20:09:53', NULL, NULL, NULL, NULL, NULL, '2026-10-09 20:22:05', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, NULL, '2026-10-09 10:29:36', '2026-10-09 20:22:05'),
(30, 'ME-EXP-2026-0031', 3, 7, NULL, 'Normal', '2026-10-09', 'hhgg jgff jhhh', 'ABC suppliers', NULL, 'Bank Transfer', 'USD', NULL, 400.00, 1.000000, 400.00, 'Within Budget', NULL, 0, NULL, 'Paid', NULL, NULL, 4, '2026-10-09 12:23:43', 5, '2026-10-09 12:27:48', NULL, NULL, NULL, NULL, NULL, '2026-10-09 13:57:58', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, NULL, '2026-10-09 12:18:48', '2026-10-09 13:57:58'),
(31, 'ME-EXP-2026-0032', 2, 9, NULL, 'Normal', '2026-10-09', 'lkfkfkf lflfllf ', 'kjjjjj', NULL, 'Bank Transfer', 'USD', NULL, 22.00, 1.000000, 22.00, 'Within Budget', NULL, 0, NULL, 'Submitted', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, NULL, '2026-10-09 20:52:02', '2026-10-09 20:52:02'),
(32, 'ME-EXP-2026-0033', 2, 13, NULL, 'Normal', '2026-10-10', 'To be used at the front desk', 'Naivas ', NULL, 'Bank Transfer', 'USD', NULL, 10000.00, 1.000000, 10000.00, 'Within Budget', NULL, 0, NULL, 'Submitted', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, NULL, '2026-10-10 08:39:12', '2026-10-10 08:39:13');

-- --------------------------------------------------------

--
-- Table structure for table `id_counters`
--

CREATE TABLE `id_counters` (
  `id` int(11) NOT NULL,
  `counter_type` varchar(50) NOT NULL,
  `year` int(11) NOT NULL,
  `current_value` int(11) NOT NULL DEFAULT 0,
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `id_counters`
--

INSERT INTO `id_counters` (`id`, `counter_type`, `year`, `current_value`, `updated_at`) VALUES
(3, 'expense_request', 2026, 33, '2026-10-10 08:39:12');

-- --------------------------------------------------------

--
-- Table structure for table `income_receipts`
--

CREATE TABLE `income_receipts` (
  `id` int(11) NOT NULL,
  `receipt_id` varchar(50) NOT NULL,
  `source` varchar(200) NOT NULL,
  `project_id` int(11) NOT NULL,
  `description` text NOT NULL,
  `currency` varchar(3) NOT NULL,
  `amount` decimal(14,2) NOT NULL,
  `exchange_rate_to_usd` decimal(10,6) DEFAULT 1.000000,
  `amount_usd` decimal(14,2) NOT NULL,
  `payment_method` varchar(50) NOT NULL,
  `reference_number` varchar(100) DEFAULT NULL,
  `receipt_date` date NOT NULL,
  `ledger_reference` varchar(100) DEFAULT NULL,
  `recorded_by_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `proof_attachment_id` int(11) DEFAULT NULL,
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `income_receipts`
--

INSERT INTO `income_receipts` (`id`, `receipt_id`, `source`, `project_id`, `description`, `currency`, `amount`, `exchange_rate_to_usd`, `amount_usd`, `payment_method`, `reference_number`, `receipt_date`, `ledger_reference`, `recorded_by_id`, `created_at`, `proof_attachment_id`, `updated_at`) VALUES
(1, 'ME-REC-2026-0014', 'BbBB', 2, 'ddd', 'KES', 11222.00, 0.007800, 87.53, 'Bank Transfer', 'Bank www', '2026-10-07', NULL, 4, '2026-10-07 12:27:16', NULL, '2026-10-07 12:27:16');

-- --------------------------------------------------------

--
-- Table structure for table `payments`
--

CREATE TABLE `payments` (
  `id` int(11) NOT NULL,
  `request_id` int(11) NOT NULL,
  `payment_reference` varchar(100) NOT NULL,
  `payment_method` varchar(50) DEFAULT NULL,
  `actual_amount_paid` decimal(14,2) DEFAULT NULL,
  `payment_notes` text DEFAULT NULL,
  `receipt_attached` tinyint(1) NOT NULL DEFAULT 0,
  `receipt_attachment_id` int(11) DEFAULT NULL,
  `ledger_reference` varchar(200) DEFAULT NULL,
  `posted_by_id` int(11) DEFAULT NULL,
  `posted_at` datetime DEFAULT NULL,
  `posting_notes` text DEFAULT NULL,
  `amount_paid` decimal(14,2) NOT NULL,
  `payment_date` date NOT NULL,
  `notes` text DEFAULT NULL,
  `paid_by_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `payments`
--

INSERT INTO `payments` (`id`, `request_id`, `payment_reference`, `payment_method`, `actual_amount_paid`, `payment_notes`, `receipt_attached`, `receipt_attachment_id`, `ledger_reference`, `posted_by_id`, `posted_at`, `posting_notes`, `amount_paid`, `payment_date`, `notes`, `paid_by_id`, `created_at`, `updated_at`) VALUES
(1, 5, 'ksavbbbb', 'Bank Transfer', 12222.00, 'bbb', 1, 3, NULL, NULL, NULL, NULL, 0.00, '2026-10-07', NULL, 8, '2026-10-07 13:19:48', '2026-10-07 13:20:03'),
(2, 8, 'ksavbbbb', 'Bank Transfer', 112212.00, '', 0, NULL, NULL, NULL, NULL, NULL, 0.00, '2026-10-08', NULL, 10, '2026-10-08 07:09:22', '2026-10-08 07:09:22'),
(3, 13, 'ksavbbbb', 'Bank Transfer', 122.00, 'hj', 0, NULL, NULL, NULL, NULL, NULL, 0.00, '2026-10-08', NULL, 8, '2026-10-08 09:29:29', '2026-10-08 09:29:29'),
(4, 20, 'wwww', 'Bank Transfer', 2000.00, 'fff', 0, NULL, NULL, NULL, NULL, NULL, 0.00, '2026-10-09', NULL, 8, '2026-10-09 08:44:55', '2026-10-09 08:44:55'),
(5, 21, 'TXN-2165-2026', 'Bank Transfer', 200.00, '', 1, 16, NULL, NULL, NULL, NULL, 0.00, '2026-10-09', NULL, 8, '2026-10-09 09:45:14', '2026-10-09 09:53:57'),
(6, 9, 'TXN-20261006-001', 'Bank Transfer', 5852.00, 'Paid', 0, NULL, NULL, NULL, NULL, NULL, 0.00, '2026-10-09', NULL, 11, '2026-10-09 10:21:02', '2026-10-09 10:21:02'),
(7, 30, 'TXN-20261006-001', 'Bank Transfer', 400.00, 'www', 1, 23, NULL, NULL, NULL, NULL, 0.00, '2026-10-09', NULL, 8, '2026-10-09 13:57:58', '2026-10-09 14:00:33'),
(8, 23, 'TXN-20261006-001', 'Mobile Money', 200.00, 'ss', 0, NULL, NULL, NULL, NULL, NULL, 0.00, '2026-10-09', NULL, 8, '2026-10-09 14:00:00', '2026-10-09 14:00:00'),
(9, 15, 'TXN-20261006-001', 'Bank Transfer', 74688642.00, 'ww', 0, NULL, NULL, NULL, NULL, NULL, 0.00, '2026-10-09', NULL, 8, '2026-10-09 14:31:14', '2026-10-09 14:31:14'),
(10, 29, 'TXN-20261006-001', 'Bank Transfer', 200.00, '', 0, NULL, NULL, NULL, NULL, NULL, 0.00, '2026-10-09', NULL, 8, '2026-10-09 20:22:05', '2026-10-09 20:22:05'),
(11, 26, 'TXN-20261006-001', 'Bank Transfer', 1600.00, 'm', 0, NULL, NULL, NULL, NULL, NULL, 0.00, '2026-10-09', NULL, 8, '2026-10-09 20:56:23', '2026-10-09 20:56:23'),
(12, 14, 'TXN-20261006-001', 'Bank Transfer', 2211.00, '', 0, NULL, NULL, NULL, NULL, NULL, 0.00, '2026-10-09', NULL, 8, '2026-10-09 20:58:39', '2026-10-09 20:58:39');

-- --------------------------------------------------------

--
-- Table structure for table `projects`
--

CREATE TABLE `projects` (
  `id` int(11) NOT NULL,
  `code` varchar(20) NOT NULL,
  `name` varchar(200) NOT NULL,
  `description` text DEFAULT NULL,
  `budget` decimal(14,2) DEFAULT NULL,
  `currency` varchar(3) DEFAULT 'USD',
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `projects`
--

INSERT INTO `projects` (`id`, `code`, `name`, `description`, `budget`, `currency`, `start_date`, `end_date`, `is_active`, `created_at`) VALUES
(1, 'GEN-2026', 'General Operations 2026', 'General operational expenses for 2026', 50000.00, 'USD', '2026-01-01', '2026-12-31', 1, '2026-10-06 20:59:11'),
(2, 'EDU-001', 'EdTech Platform Development', 'Development of online learning platform', 100000.00, 'USD', '2026-01-01', '2026-06-30', 1, '2026-10-06 20:59:11'),
(3, 'MKT-001', 'Marketing Campaign Q1 2026', 'Digital marketing and brand awareness campaign', 25000.00, 'USD', '2026-01-01', '2026-03-31', 1, '2026-10-06 20:59:11');

-- --------------------------------------------------------

--
-- Table structure for table `reconciliations`
--

CREATE TABLE `reconciliations` (
  `id` int(11) NOT NULL,
  `account_type` varchar(50) NOT NULL,
  `account_name` varchar(200) NOT NULL,
  `account_number` varchar(50) DEFAULT NULL,
  `period_start` date NOT NULL,
  `period_end` date NOT NULL,
  `opening_balance` decimal(14,2) NOT NULL,
  `system_closing_balance` decimal(14,2) NOT NULL,
  `actual_closing_balance` decimal(14,2) NOT NULL,
  `difference` decimal(14,2) NOT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'Open',
  `explanation` text DEFAULT NULL,
  `prepared_by_id` int(11) NOT NULL,
  `prepared_at` datetime DEFAULT current_timestamp(),
  `reviewed_by_id` int(11) DEFAULT NULL,
  `reviewed_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `reconciliations`
--

INSERT INTO `reconciliations` (`id`, `account_type`, `account_name`, `account_number`, `period_start`, `period_end`, `opening_balance`, `system_closing_balance`, `actual_closing_balance`, `difference`, `status`, `explanation`, `prepared_by_id`, `prepared_at`, `reviewed_by_id`, `reviewed_at`, `created_at`, `updated_at`) VALUES
(1, 'Mobile Money', 'dddd', '12212256', '2026-09-27', '2026-10-22', 112.00, 112212.00, 1221.00, -110991.00, 'Open', NULL, 4, '2026-10-07 12:43:44', NULL, NULL, '2026-10-07 12:43:44', '2026-10-07 12:43:44');

-- --------------------------------------------------------

--
-- Table structure for table `reconciliation_items`
--

CREATE TABLE `reconciliation_items` (
  `id` int(11) NOT NULL,
  `reconciliation_id` int(11) NOT NULL,
  `transaction_date` date NOT NULL,
  `description` text NOT NULL,
  `reference` varchar(100) DEFAULT NULL,
  `debit` decimal(14,2) DEFAULT 0.00,
  `credit` decimal(14,2) DEFAULT 0.00,
  `matched` tinyint(1) DEFAULT 0,
  `matched_request_id` int(11) DEFAULT NULL,
  `matched_receipt_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `request_items`
--

CREATE TABLE `request_items` (
  `id` int(11) NOT NULL,
  `request_id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL,
  `description` text NOT NULL,
  `quantity` decimal(10,2) NOT NULL,
  `unit_price` decimal(14,2) NOT NULL,
  `total_price` decimal(14,2) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `request_items`
--

INSERT INTO `request_items` (`id`, `request_id`, `category_id`, `description`, `quantity`, `unit_price`, `total_price`, `created_at`) VALUES
(1, 1, 1, 'www', 1.00, 0.14, 0.14, '2026-10-07 07:18:57'),
(2, 2, 4, 'ddsas', 1.00, 0.09, 0.09, '2026-10-07 07:29:05'),
(3, 3, 4, 'ddsas', 1.00, 0.09, 0.09, '2026-10-07 07:29:27'),
(4, 4, 1, 'Printer paper', 2.00, 10.00, 20.00, '2026-10-07 07:40:53'),
(5, 5, 1, 'Printer paper', 2.00, 10.00, 20.00, '2026-10-07 07:45:03'),
(6, 6, 2, 'ddvx ', 1.15, 0.13, 0.15, '2026-10-07 07:49:43'),
(7, 7, 3, 'dbvcjhgfdxszxc', 2.46, 77777.00, 191331.42, '2026-10-07 08:12:23'),
(8, 8, 9, 'hbvfcdx', 133333.00, 555.00, 73999815.00, '2026-10-07 08:16:41'),
(9, 9, 4, 'dv j', 133.00, 44.00, 5852.00, '2026-10-07 09:02:23'),
(10, 10, 1, 'Test item 1', 2.00, 50.00, 100.00, '2026-10-07 10:20:52'),
(11, 11, 1, 'Test item 1', 2.00, 50.00, 100.00, '2026-10-07 10:21:26'),
(12, 12, 4, 'ddd', 1.00, 111.00, 111.00, '2026-10-07 10:31:24'),
(13, 13, 4, 'mnbv', 1.00, 0.02, 0.02, '2026-10-07 11:46:07'),
(14, 14, 4, 'hjjjj', 1.00, 2211.00, 2211.00, '2026-10-07 12:52:53'),
(15, 15, 3, 'dc vv', 12222.00, 6111.00, 74688642.00, '2026-10-07 12:54:04'),
(16, 16, 6, 'Bills', 2.00, 1000.00, 2000.00, '2026-10-08 07:12:25'),
(17, 17, 5, 'ssss', 2.00, 23000.00, 46000.00, '2026-10-08 07:51:59'),
(18, 18, 4, 'wwww', 1.00, 90.00, 90.00, '2026-10-08 07:58:20'),
(19, 19, 1, 'Test item 1', 2.00, 50.00, 100.00, '2026-10-08 08:32:25'),
(20, 20, 5, 'vvv', 1.00, 2000.00, 2000.00, '2026-10-08 08:43:41'),
(21, 21, 6, 'hhjjjjj', 1.00, 200.00, 200.00, '2026-10-08 08:52:14'),
(22, 22, 2, 'ddddd', 1.00, 1000.00, 1000.00, '2026-10-08 09:04:01'),
(23, 23, 8, 'hgffd ', 1.00, 200.00, 200.00, '2026-10-08 09:21:52'),
(24, 24, 4, 'Laptop', 2.00, 30000.00, 60000.00, '2026-10-09 08:38:20'),
(25, 25, 1, 'Two Tables', 2.00, 10000.00, 20000.00, '2026-10-09 09:38:59'),
(26, 26, 5, 'Chairs', 2.00, 800.00, 1600.00, '2026-10-09 10:22:34'),
(27, 27, 10, 'pizza', 6.00, 700.00, 4200.00, '2026-10-09 10:25:14'),
(28, 28, 3, 'GGGGG', 1.00, 2.00, 2.00, '2026-10-09 10:27:30'),
(29, 29, 6, 'gggggg', 1.00, 200.00, 200.00, '2026-10-09 10:29:36'),
(30, 30, 1, 'Two Tablles', 2.00, 200.00, 400.00, '2026-10-09 12:18:48'),
(31, 31, 4, 'Hello', 1.00, 22.00, 22.00, '2026-10-09 20:52:02'),
(32, 32, 5, 'Desktops ', 2.00, 5000.00, 10000.00, '2026-10-10 08:39:12');

-- --------------------------------------------------------

--
-- Table structure for table `settings`
--

CREATE TABLE `settings` (
  `id` int(11) NOT NULL,
  `key_name` varchar(100) NOT NULL,
  `value` text NOT NULL,
  `description` text DEFAULT NULL,
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `settings`
--

INSERT INTO `settings` (`id`, `key_name`, `value`, `description`, `updated_at`) VALUES
(1, 'approval_threshold_manager', '500', 'Maximum amount (USD) Manager can approve', '2026-10-06 19:55:24'),
(2, 'approval_threshold_director', '2000', 'Maximum amount (USD) Director can approve', '2026-10-06 19:55:24'),
(3, 'approval_threshold_md', '999999', 'Maximum amount (USD) Managing Director can approve', '2026-10-06 19:55:24'),
(4, 'payment_tolerance_percent', '2', 'Allowed variance between approved and actual amount (%)', '2026-10-06 19:55:24'),
(5, 'advance_retirement_days', '30', 'Default days to retire an advance', '2026-10-06 19:55:24'),
(6, 'company_name', 'Milestone EdTech Solutions Ltd', 'Company name for documents', '2026-10-06 19:55:24'),
(7, 'currency_default', 'USD', 'Default currency for transactions', '2026-10-06 19:55:24');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `email` varchar(120) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `role` varchar(50) NOT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `email`, `password_hash`, `full_name`, `role`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'admin@milestone.com', 'scrypt:32768:8:1$JrCjdpFUbKloLrtf$279b074a92b980563ec74d51710225644c72f9d0651cc385afc7bbed408eeba2a4086588f9a259fb0e2afe6120680d7a577e7e5ebddadc42352382748d66b62e', 'System Administrator', 'Admin', 1, '2026-10-06 20:02:01', '2026-10-08 08:32:27'),
(2, 'staff@milestone.com', 'scrypt:32768:8:1$lhXKN0NjUAFLJzgq$cd9d874dd9ba12b20d5a971926f6ac0ab632099559f4cde7a2cb0fd32e964991fa115c0007e1eedc6114d2abd5fc7c038bdd4b8a442d10a66431d34da82d1078', 'John Staff', 'Staff', 1, '2026-10-06 20:02:14', '2026-10-06 21:06:26'),
(3, 'manager@milestone.com', 'scrypt:32768:8:1$ilMbtgHMonQi0QEo$68f122f3e758070896811cae9742bf4a4c3dc6dd47d8717ccd9dde535f77c43a220b31ca33dade6a44a07199824286d48d207afbe65255fccf6b1013b5bfe3e8', 'Jane Manager', 'Manager', 1, '2026-10-06 20:02:15', '2026-10-06 21:06:26'),
(4, 'accountant@milestone.com', 'scrypt:32768:8:1$buv1Ijhn31xofzcL$e75ace7c49a8b79607c1850062daef7762f3e8ea54f5df47855701d55e840ccf4c1e424ad4c94b9bca19c7eefc81d5eaf478952d5a0867484592b8c5c4627bf4', 'Mary Accountant', 'Accountant', 1, '2026-10-06 20:02:15', '2026-10-06 21:06:26'),
(5, 'director@milestone.com', 'scrypt:32768:8:1$uWr9azCCuAAEpRMV$cc996e6c7329283f707ef4e88373268ddc302ec33203acb137b4c22e45509369bb722ffe7f70a8df39657b720705454185d45610fe4b4c0d869f35c6b24c6ac1', 'David Director', 'Director', 1, '2026-10-06 20:02:15', '2026-10-06 21:06:26'),
(6, 'md@milestone.com', 'scrypt:32768:8:1$SCZPqVlKJwotKrU8$61c38fdaf820524b9646a6148ef2004e695361c2627e2022c720428fdafc54f43fb002ec271eff51812ddec6a79cec364df8d163038cc22469d7be0f614c589b', 'Sarah Managing Director', 'Managing Director', 1, '2026-10-06 20:02:15', '2026-10-06 21:06:26'),
(7, 'operations@milestone.com', 'scrypt:32768:8:1$EkgdmpJnroaI97cu$9f9f790d0ee62409bb5564d7f30141e5a99457a1ef0457bc89cfc58d9d5b677c8442db672970c2a249c8430bb0be3a3dbedffc48c1d72d0eef68823ae80d1dbf', 'Sarah Operations', 'Operation Manager', 1, '2026-10-06 20:24:49', '2026-10-06 21:06:26'),
(8, 'payments@milestone.com', 'scrypt:32768:8:1$XIpEIpDbcbVpmulS$1cbcc29950d99f699d8cf59971bc1665462b9f7ab196856532674762f44ec853ffd2a843daf9f1c6f161c4724f3162b8a1ac33d377faab3ca66505f5fd4e4a86', 'David Payments', 'Paying Officer', 1, '2026-10-06 20:24:49', '2026-10-07 14:09:55'),
(9, 'faith@milestone.com', 'scrypt:32768:8:1$VSYxRd5qu6Hnjo9U$81fb1f7a3e60dad3ef97b9740fee0b089baa2aab0feffa435b409210cbfdf445d66edf0425f072a715cc5fc663e68f9ec884b38724a4064f528a0a83ceff3098', 'hhhh', 'Accountant', 1, '2026-10-07 15:03:21', '2026-10-07 15:03:21'),
(10, 'jebet@milestone.com', 'scrypt:32768:8:1$vmsYsGFqEZgBtGaa$dbbd445136464a52451f3993b653b2fce2cc0f1d49e6a3e1a835b5fe98a04672cccb3fcdeada363feb5dd96aa3b59e87e8ed6089d5e60000d14c2d1ed4130fbb', 'Jebet', 'Paying Officer', 1, '2026-10-07 15:04:47', '2026-10-07 15:04:47'),
(11, 'kiprono@milestone.com', 'scrypt:32768:8:1$Ji4r2w5VBHGr3OLy$1f683bc6b131fbffa9645c8f8b7457a84a9ca1334d3e7b5e489a12e757be05905b71bdba48d5e08de3d92a74f8ae06924b52ee8cf859ab93eb4e9af8be9f59c7', 'kiprono', 'Paying Officer', 1, '2026-10-08 09:12:13', '2026-10-08 09:12:13'),
(12, 'lk@milestone.com', 'scrypt:32768:8:1$k9Kuxd1waczT9RqJ$1996187abd193417a4614cec9ff3751081039967989d6cecdc05465831bb5ad328b159a244ea8754a5113ebb3ec08889d9f190db660fcabe3678578bcecf108e', 'LK', 'Staff', 1, '2026-10-09 10:56:51', '2026-10-09 10:56:51'),
(13, 'wamboi@milestone.com', 'scrypt:32768:8:1$fxE5MKoa6VqkCgYZ$2ff14495df4c2abc93e0c5c1c2a579f2562f7da58c93ff5dd361e4bc91e07ea2159e42dded1a4ce74fc17632b49559023be639b755012de80b12753d0a668ba2', 'Wamboi', 'Operation Manager', 1, '2026-10-10 08:36:17', '2026-10-10 08:36:17');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `advances`
--
ALTER TABLE `advances`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_request` (`request_id`),
  ADD KEY `idx_retired` (`is_retired`),
  ADD KEY `idx_deadline` (`retirement_deadline`);

--
-- Indexes for table `approvals`
--
ALTER TABLE `approvals`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_request` (`request_id`),
  ADD KEY `idx_approver` (`approver_id`);

--
-- Indexes for table `attachments`
--
ALTER TABLE `attachments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `uploaded_by_id` (`uploaded_by_id`),
  ADD KEY `idx_request` (`request_id`),
  ADD KEY `idx_file_type` (`file_type`);

--
-- Indexes for table `audit_log`
--
ALTER TABLE `audit_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_entity` (`entity_type`,`entity_id`),
  ADD KEY `idx_action` (`action`),
  ADD KEY `idx_created` (`created_at`);

--
-- Indexes for table `exchange_rates`
--
ALTER TABLE `exchange_rates`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_rate` (`from_currency`,`to_currency`,`effective_date`),
  ADD KEY `idx_currencies` (`from_currency`,`to_currency`),
  ADD KEY `idx_effective_date` (`effective_date`);

--
-- Indexes for table `expense_categories`
--
ALTER TABLE `expense_categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`),
  ADD KEY `idx_code` (`code`);

--
-- Indexes for table `expense_requests`
--
ALTER TABLE `expense_requests`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `request_id` (`request_id`),
  ADD KEY `verified_by_id` (`verified_by_id`),
  ADD KEY `approved_by_id` (`approved_by_id`),
  ADD KEY `paid_by_id` (`paid_by_id`),
  ADD KEY `posted_by_id` (`posted_by_id`),
  ADD KEY `closed_by_id` (`closed_by_id`),
  ADD KEY `idx_request_id` (`request_id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_requester` (`requester_id`),
  ADD KEY `idx_project` (`project_id`),
  ADD KEY `idx_request_date` (`request_date`),
  ADD KEY `fk_expense_requests_rejected_by` (`rejected_by_id`);

--
-- Indexes for table `id_counters`
--
ALTER TABLE `id_counters`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `counter_type` (`counter_type`),
  ADD UNIQUE KEY `unique_counter` (`counter_type`,`year`);

--
-- Indexes for table `income_receipts`
--
ALTER TABLE `income_receipts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `receipt_id` (`receipt_id`),
  ADD KEY `recorded_by_id` (`recorded_by_id`),
  ADD KEY `idx_receipt_id` (`receipt_id`),
  ADD KEY `idx_project` (`project_id`),
  ADD KEY `idx_receipt_date` (`receipt_date`),
  ADD KEY `fk_income_attachment` (`proof_attachment_id`);

--
-- Indexes for table `payments`
--
ALTER TABLE `payments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `paid_by_id` (`paid_by_id`),
  ADD KEY `idx_request` (`request_id`),
  ADD KEY `idx_payment_date` (`payment_date`),
  ADD KEY `fk_payments_receipt_attachment` (`receipt_attachment_id`),
  ADD KEY `fk_payments_posted_by` (`posted_by_id`);

--
-- Indexes for table `projects`
--
ALTER TABLE `projects`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`),
  ADD KEY `idx_code` (`code`),
  ADD KEY `idx_active` (`is_active`);

--
-- Indexes for table `reconciliations`
--
ALTER TABLE `reconciliations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `prepared_by_id` (`prepared_by_id`),
  ADD KEY `reviewed_by_id` (`reviewed_by_id`),
  ADD KEY `idx_account` (`account_name`),
  ADD KEY `idx_period` (`period_end`),
  ADD KEY `idx_status` (`status`);

--
-- Indexes for table `reconciliation_items`
--
ALTER TABLE `reconciliation_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `matched_request_id` (`matched_request_id`),
  ADD KEY `matched_receipt_id` (`matched_receipt_id`),
  ADD KEY `idx_reconciliation` (`reconciliation_id`),
  ADD KEY `idx_matched` (`matched`);

--
-- Indexes for table `request_items`
--
ALTER TABLE `request_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `category_id` (`category_id`),
  ADD KEY `idx_request` (`request_id`);

--
-- Indexes for table `settings`
--
ALTER TABLE `settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `key_name` (`key_name`),
  ADD KEY `idx_key` (`key_name`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `idx_role` (`role`),
  ADD KEY `idx_email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `advances`
--
ALTER TABLE `advances`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `approvals`
--
ALTER TABLE `approvals`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `attachments`
--
ALTER TABLE `attachments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT for table `audit_log`
--
ALTER TABLE `audit_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=537;

--
-- AUTO_INCREMENT for table `exchange_rates`
--
ALTER TABLE `exchange_rates`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `expense_categories`
--
ALTER TABLE `expense_categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `expense_requests`
--
ALTER TABLE `expense_requests`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT for table `id_counters`
--
ALTER TABLE `id_counters`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `income_receipts`
--
ALTER TABLE `income_receipts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `payments`
--
ALTER TABLE `payments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `projects`
--
ALTER TABLE `projects`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `reconciliations`
--
ALTER TABLE `reconciliations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `reconciliation_items`
--
ALTER TABLE `reconciliation_items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `request_items`
--
ALTER TABLE `request_items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT for table `settings`
--
ALTER TABLE `settings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `advances`
--
ALTER TABLE `advances`
  ADD CONSTRAINT `advances_ibfk_1` FOREIGN KEY (`request_id`) REFERENCES `expense_requests` (`id`);

--
-- Constraints for table `approvals`
--
ALTER TABLE `approvals`
  ADD CONSTRAINT `approvals_ibfk_1` FOREIGN KEY (`request_id`) REFERENCES `expense_requests` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `approvals_ibfk_2` FOREIGN KEY (`approver_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `attachments`
--
ALTER TABLE `attachments`
  ADD CONSTRAINT `attachments_ibfk_1` FOREIGN KEY (`request_id`) REFERENCES `expense_requests` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `attachments_ibfk_2` FOREIGN KEY (`uploaded_by_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `audit_log`
--
ALTER TABLE `audit_log`
  ADD CONSTRAINT `audit_log_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `expense_requests`
--
ALTER TABLE `expense_requests`
  ADD CONSTRAINT `expense_requests_ibfk_1` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`),
  ADD CONSTRAINT `expense_requests_ibfk_2` FOREIGN KEY (`requester_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `expense_requests_ibfk_3` FOREIGN KEY (`verified_by_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `expense_requests_ibfk_4` FOREIGN KEY (`approved_by_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `expense_requests_ibfk_5` FOREIGN KEY (`paid_by_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `expense_requests_ibfk_6` FOREIGN KEY (`posted_by_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `expense_requests_ibfk_7` FOREIGN KEY (`closed_by_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_expense_requests_rejected_by` FOREIGN KEY (`rejected_by_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `income_receipts`
--
ALTER TABLE `income_receipts`
  ADD CONSTRAINT `fk_income_attachment` FOREIGN KEY (`proof_attachment_id`) REFERENCES `attachments` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `income_receipts_ibfk_1` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`),
  ADD CONSTRAINT `income_receipts_ibfk_2` FOREIGN KEY (`recorded_by_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `payments`
--
ALTER TABLE `payments`
  ADD CONSTRAINT `fk_payments_posted_by` FOREIGN KEY (`posted_by_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_payments_receipt_attachment` FOREIGN KEY (`receipt_attachment_id`) REFERENCES `attachments` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `payments_ibfk_1` FOREIGN KEY (`request_id`) REFERENCES `expense_requests` (`id`),
  ADD CONSTRAINT `payments_ibfk_2` FOREIGN KEY (`paid_by_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `reconciliations`
--
ALTER TABLE `reconciliations`
  ADD CONSTRAINT `reconciliations_ibfk_1` FOREIGN KEY (`prepared_by_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `reconciliations_ibfk_2` FOREIGN KEY (`reviewed_by_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `reconciliation_items`
--
ALTER TABLE `reconciliation_items`
  ADD CONSTRAINT `reconciliation_items_ibfk_1` FOREIGN KEY (`reconciliation_id`) REFERENCES `reconciliations` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `reconciliation_items_ibfk_2` FOREIGN KEY (`matched_request_id`) REFERENCES `expense_requests` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `reconciliation_items_ibfk_3` FOREIGN KEY (`matched_receipt_id`) REFERENCES `income_receipts` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `request_items`
--
ALTER TABLE `request_items`
  ADD CONSTRAINT `request_items_ibfk_1` FOREIGN KEY (`request_id`) REFERENCES `expense_requests` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `request_items_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `expense_categories` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
