-- Application_attendance – Full Schema Initialization
-- Store only bcrypt hashes (60 chars)
-- ENUM constraints per design

CREATE DATABASE IF NOT EXISTS `Application_attendance` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `Application_attendance`;

-- Drop old tables (respect FK dependency order)
DROP TABLE IF EXISTS `users`;
DROP TABLE IF EXISTS `Gender`;
DROP TABLE IF EXISTS `Prefix`;
DROP TABLE IF EXISTS `Day`;
DROP TABLE IF EXISTS `Course`;
DROP TABLE IF EXISTS `Schedule`;
DROP TABLE IF EXISTS `Schedule_Detail`;
DROP TABLE IF EXISTS `Leave`;
DROP TABLE IF EXISTS `QR_Code`;
DROP TABLE IF EXISTS `Attendance`;
DROP TABLE IF EXISTS `Attendance_Detail`;

-- =========================
-- GENDER TABLE
-- =========================
CREATE TABLE `Gender` (
  `gender_id` INT PRIMARY KEY,
  `gender_name` VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================
-- PREFIX TABLE
-- =========================
CREATE TABLE `Prefix` (
  `prefix_id` INT PRIMARY KEY,
  `prefix_name` VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================
-- USERS TABLE
-- =========================
CREATE TABLE `users` (
  `user_id`             INT PRIMARY KEY,
  `full_name`           VARCHAR(255),
  `email`               VARCHAR(255),
  `phone_number`        VARCHAR(20),
  `address`             TEXT,
  `profile_attachment`  VARCHAR(255),
  `role_id`             ENUM('student','teacher','admin') DEFAULT 'student',
  `hash_password`       VARCHAR(255),
  `student_id`          VARCHAR(255),
  `gender_id`           INT,
  `prefix_id`           INT,
  
  FOREIGN KEY           (`gender_id`) REFERENCES `Gender`(`gender_id`),
  FOREIGN KEY           (`prefix_id`) REFERENCES `Prefix`(`prefix_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================
-- DAY TABLE
-- =========================
CREATE TABLE `Day` (
  `day_id` INT PRIMARY KEY,
  `day_name` VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================
-- COURSES TABLE
-- =========================
CREATE TABLE `Course` (
  `course_id` INT PRIMARY KEY,
  `code` VARCHAR(50),
  `credit` INT,
  `user_id` INT,
  `day_id` INT,
  `time` TIME,
  `class` VARCHAR(50),
  `max_leave` INT,
  `teacher_name` VARCHAR(255),
  `section` VARCHAR(50),
  `course_name` VARCHAR(255),

  FOREIGN KEY (`user_id`) REFERENCES `User`(`user_id`),
  FOREIGN KEY (`day_id`) REFERENCES `Day`(`day_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================
-- SCHEDULE TABLE
-- =========================
CREATE TABLE `Schedule` (
  `schedule_id` INT PRIMARY KEY,
  `course_id` INT,
  `course_name` VARCHAR(255),
  `teacher_id` INT,
  `teacher_name` VARCHAR(255),
  `day_id` INT,
  `day_name` VARCHAR(255),

  FOREIGN KEY (`course_id`) REFERENCES `Course`(`course_id`),
  FOREIGN KEY (`teacher_id`) REFERENCES `User`(`user_id`),
  FOREIGN KEY (`day_id`) REFERENCES `Day`(`day_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================
-- SCHEDULE_DETAIL TABLE
-- =========================
CREATE TABLE `Schedule_Detail` (
  `schedule_detail_id` INT PRIMARY KEY,
  `schedule_id` INT,
  `user_id` INT,
  `user_name` VARCHAR(255),
  `student_id` VARCHAR(255),

  FOREIGN KEY (`schedule_id`) REFERENCES `Schedule`(`schedule_id`),
  FOREIGN KEY (`user_id`) REFERENCES `User`(`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================
-- LEAVE TABLE
-- =========================
CREATE TABLE `Leave` (
  `leave_id` INT PRIMARY KEY,
  `student_id` VARCHAR(255),
  `leave_type` VARCHAR(255),
  `reason` TEXT,
  `leave_date` DATE,
  `status` VARCHAR(50),
  `attachment` VARCHAR(255),
  `approve_date` DATE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================
-- QR_CODE TABLE
-- =========================
CREATE TABLE `QR_Code` (
  `qr_code_id` INT PRIMARY KEY,
  `course_id` INT,
  `qr_code_password` VARCHAR(255),
  `qr_code_hash` VARCHAR(255),

  FOREIGN KEY (`course_id`) REFERENCES `Course`(`course_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================
-- ATTENDANCE TABLE
-- =========================
CREATE TABLE `Attendance` (
  `attendance_id` INT PRIMARY KEY,
  `course_id` INT,
  `course_name` VARCHAR(255),
  `day` DATE,
  `time` TIME,
  `teacher_name` VARCHAR(255),
  `section` VARCHAR(50),
  `class` VARCHAR(50),
  `qr_code_id` INT,

  FOREIGN KEY (`course_id`) REFERENCES `Course`(`course_id`),
  FOREIGN KEY (`qr_code_id`) REFERENCES `QR_Code`(`qr_code_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================
-- ATTENDANCE_DETAIL TABLE
-- =========================
CREATE TABLE `Attendance_Detail` (
  `attendance_detail_id` INT PRIMARY KEY,
  `attendance_id` INT,
  `user_id` INT,
  `student_id` VARCHAR(255),
  `student_name` VARCHAR(255),
  `time` TIME,
  `latitude` DECIMAL(10, 8),
  `longitude` DECIMAL(11, 8),
  `qr_code_id` INT,
  `schedule_id` INT,
  `leave` VARCHAR(50),
  `device_id` VARCHAR(255),

  FOREIGN KEY (`attendance_id`) REFERENCES `Attendance`(`attendance_id`),
  FOREIGN KEY (`user_id`) REFERENCES `User`(`user_id`),
  FOREIGN KEY (`qr_code_id`) REFERENCES `QR_Code`(`qr_code_id`),
  FOREIGN KEY (`schedule_id`) REFERENCES `Schedule`(`schedule_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;




