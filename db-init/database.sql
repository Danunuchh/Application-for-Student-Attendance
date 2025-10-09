-- Application_attendance – Fixed (minimal changes to run)

CREATE DATABASE IF NOT EXISTS `Application_attendance`
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `Application_attendance`;

-- 1) Drop children first
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS `attendance_detail`;
DROP TABLE IF EXISTS `attendance`;
DROP TABLE IF EXISTS `qr_code`;
DROP TABLE IF EXISTS `schedule_detail`;
DROP TABLE IF EXISTS `schedule`;
DROP TABLE IF EXISTS `course`;
DROP TABLE IF EXISTS `leave_request`;
DROP TABLE IF EXISTS `users`;
DROP TABLE IF EXISTS `gender`;
DROP TABLE IF EXISTS `prefix`;
DROP TABLE IF EXISTS `day`;
SET FOREIGN_KEY_CHECKS = 1;

-- =========================
-- GENDER
-- =========================
CREATE TABLE `gender` (
  `gender_id` INT NOT NULL AUTO_INCREMENT,
  `gender_name` VARCHAR(255),
  PRIMARY KEY (`gender_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================
-- PREFIX
-- =========================
CREATE TABLE `prefix` (
  `prefix_id` INT NOT NULL AUTO_INCREMENT,
  `prefix_name` VARCHAR(255),
  PRIMARY KEY (`prefix_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================
-- USERS
-- =========================
CREATE TABLE `users` (
  `user_id`             INT NOT NULL AUTO_INCREMENT,
  `full_name`           VARCHAR(255),
  `email`               VARCHAR(255),
  `phone_number`        VARCHAR(20),
  `address`             TEXT,
  `profile_attachment`  VARCHAR(255),
  `role_id`             ENUM('student','teacher','admin') DEFAULT 'student',
  `hash_password`       VARCHAR(60),              
  `student_id`          VARCHAR(255),
  `gender_id`           INT,
  `prefix_id`           INT,
  PRIMARY KEY (`user_id`),
  KEY `idx_users_gender` (`gender_id`),
  KEY `idx_users_prefix` (`prefix_id`),
  CONSTRAINT `fk_users_gender` FOREIGN KEY (`gender_id`) REFERENCES `gender`(`gender_id`)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT `fk_users_prefix` FOREIGN KEY (`prefix_id`) REFERENCES `prefix`(`prefix_id`)
    ON UPDATE CASCADE ON DELETE SET NULL,
  UNIQUE KEY `uk_users_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================
-- DAY
-- =========================
CREATE TABLE `day` (
  `day_id` INT NOT NULL AUTO_INCREMENT,
  `day_name` VARCHAR(255),
  PRIMARY KEY (`day_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================
-- COURSE
-- =========================
CREATE TABLE `course` (
  `course_id` INT NOT NULL AUTO_INCREMENT,
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
  PRIMARY KEY (`course_id`),
  KEY `idx_course_user` (`user_id`),
  KEY `idx_course_day` (`day_id`),
  CONSTRAINT `fk_course_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`user_id`)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT `fk_course_day` FOREIGN KEY (`day_id`) REFERENCES `day`(`day_id`)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================
-- SCHEDULE
-- =========================
CREATE TABLE `schedule` (
  `schedule_id` INT NOT NULL AUTO_INCREMENT,
  `course_id` INT,
  `course_name` VARCHAR(255),
  `teacher_id` INT,
  `teacher_name` VARCHAR(255),
  `day_id` INT,
  `day_name` VARCHAR(255),
  PRIMARY KEY (`schedule_id`),
  KEY `idx_schedule_course` (`course_id`),
  KEY `idx_schedule_teacher` (`teacher_id`),
  KEY `idx_schedule_day` (`day_id`),
  CONSTRAINT `fk_schedule_course` FOREIGN KEY (`course_id`) REFERENCES `course`(`course_id`)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT `fk_schedule_teacher` FOREIGN KEY (`teacher_id`) REFERENCES `users`(`user_id`)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT `fk_schedule_day` FOREIGN KEY (`day_id`) REFERENCES `day`(`day_id`)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================
-- SCHEDULE_DETAIL
-- =========================
CREATE TABLE `schedule_detail` (
  `schedule_detail_id` INT NOT NULL AUTO_INCREMENT,
  `schedule_id` INT,
  `user_id` INT,
  `user_name` VARCHAR(255),
  `student_id` VARCHAR(255),
  PRIMARY KEY (`schedule_detail_id`),
  KEY `idx_schedetail_schedule` (`schedule_id`),
  KEY `idx_schedetail_user` (`user_id`),
  CONSTRAINT `fk_schedetail_schedule` FOREIGN KEY (`schedule_id`) REFERENCES `schedule`(`schedule_id`)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT `fk_schedetail_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`user_id`)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================
-- LEAVE (renamed table)
-- =========================
CREATE TABLE `leave_request` (
  `leave_id` INT NOT NULL AUTO_INCREMENT,
  `student_id` VARCHAR(255),
  `leave_type` VARCHAR(255),
  `reason` TEXT,
  `leave_date` DATE,
  `leave_status` VARCHAR(50),
  `attachment` VARCHAR(255),
  `approve_date` DATE,
  PRIMARY KEY (`leave_id`),
  KEY `idx_leave_student` (`student_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================
-- QR_CODE
-- =========================
CREATE TABLE `qr_code` (
  `qr_code_id` INT NOT NULL AUTO_INCREMENT,
  `course_id` INT,
  `qr_code_password` VARCHAR(255),
  `qr_code_hash` VARCHAR(255),
  PRIMARY KEY (`qr_code_id`),
  KEY `idx_qr_course` (`course_id`),
  CONSTRAINT `fk_qr_course` FOREIGN KEY (`course_id`) REFERENCES `course`(`course_id`)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================
-- ATTENDANCE
-- =========================
CREATE TABLE `attendance` (
  `attendance_id` INT NOT NULL AUTO_INCREMENT,
  `course_id` INT,
  `course_name` VARCHAR(255),
  `day` DATE,
  `time` TIME,
  `teacher_name` VARCHAR(255),
  `section` VARCHAR(50),
  `class` VARCHAR(50),
  `qr_code_id` INT,
  PRIMARY KEY (`attendance_id`),
  KEY `idx_att_course` (`course_id`),
  KEY `idx_att_qr` (`qr_code_id`),
  CONSTRAINT `fk_att_course` FOREIGN KEY (`course_id`) REFERENCES `course`(`course_id`)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT `fk_att_qr` FOREIGN KEY (`qr_code_id`) REFERENCES `qr_code`(`qr_code_id`)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================
-- ATTENDANCE_DETAIL
-- =========================
CREATE TABLE `attendance_detail` (
  `attendance_detail_id` INT NOT NULL AUTO_INCREMENT,
  `attendance_id` INT,
  `user_id` INT,
  `student_id` VARCHAR(255),
  `student_name` VARCHAR(255),
  `time` TIME,
  `latitude` DECIMAL(10, 8),
  `longitude` DECIMAL(11, 8),
  `qr_code_id` INT,
  `schedule_id` INT,
  `leave_status` VARCHAR(50),     -- renamed from `leave` (keyword)
  `device_id` VARCHAR(255),
  PRIMARY KEY (`attendance_detail_id`),
  KEY `idx_attd_att` (`attendance_id`),
  KEY `idx_attd_user` (`user_id`),
  KEY `idx_attd_qr` (`qr_code_id`),
  KEY `idx_attd_sched` (`schedule_id`),
  CONSTRAINT `fk_attd_att` FOREIGN KEY (`attendance_id`) REFERENCES `attendance`(`attendance_id`)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT `fk_attd_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`user_id`)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT `fk_attd_qr` FOREIGN KEY (`qr_code_id`) REFERENCES `qr_code`(`qr_code_id`)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT `fk_attd_sched` FOREIGN KEY (`schedule_id`) REFERENCES `schedule`(`schedule_id`)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
