-- AI Smart School Management System
-- MySQL Schema (compatible with MySQL 5.7+ and MariaDB 10.3+)

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

-- ─── Schools ───────────────────────────────────────────────────────────────
CREATE TABLE `schools` (
    `id`         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `name`       VARCHAR(200) NOT NULL,
    `address`    TEXT,
    `city`       VARCHAR(100),
    `state`      VARCHAR(100),
    `country`    VARCHAR(100) DEFAULT 'Pakistan',
    `phone`      VARCHAR(30),
    `email`      VARCHAR(150),
    `website`    VARCHAR(200),
    `logo`       VARCHAR(300),
    `status`     ENUM('active','inactive','suspended') DEFAULT 'active',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── Users ─────────────────────────────────────────────────────────────────
CREATE TABLE `users` (
    `id`            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `school_id`     INT UNSIGNED NULL,
    `first_name`    VARCHAR(100) NOT NULL,
    `last_name`     VARCHAR(100) NOT NULL,
    `email`         VARCHAR(150) NOT NULL UNIQUE,
    `password`      VARCHAR(255) NOT NULL,
    `role`          ENUM('super_admin','admin','school_owner','teacher','student','parent','staff','government','community') NOT NULL,
    `phone`         VARCHAR(30),
    `address`       TEXT,
    `avatar`        VARCHAR(300),
    `gender`        ENUM('male','female','other') NULL,
    `date_of_birth` DATE NULL,
    `status`        ENUM('active','inactive','suspended') DEFAULT 'active',
    `last_login`    DATETIME NULL,
    `reset_token`   VARCHAR(100) NULL,
    `reset_expiry`  DATETIME NULL,
    `created_at`    DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at`    DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`school_id`) REFERENCES `schools`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── Classes ───────────────────────────────────────────────────────────────
CREATE TABLE `classes` (
    `id`               INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `school_id`        INT UNSIGNED NOT NULL,
    `name`             VARCHAR(100) NOT NULL,
    `section`          VARCHAR(20),
    `grade_level`      INT NULL,
    `room`             VARCHAR(50),
    `capacity`         INT DEFAULT 40,
    `class_teacher_id` INT UNSIGNED NULL,
    `academic_year`    VARCHAR(20),
    `status`           ENUM('active','inactive') DEFAULT 'active',
    `created_at`       DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`school_id`) REFERENCES `schools`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`class_teacher_id`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── Subjects ──────────────────────────────────────────────────────────────
CREATE TABLE `subjects` (
    `id`          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `school_id`   INT UNSIGNED NOT NULL,
    `class_id`    INT UNSIGNED NOT NULL,
    `name`        VARCHAR(150) NOT NULL,
    `code`        VARCHAR(30),
    `teacher_id`  INT UNSIGNED NULL,
    `credits`     DECIMAL(4,1) DEFAULT 1.0,
    `description` TEXT,
    `status`      ENUM('active','inactive') DEFAULT 'active',
    `created_at`  DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`school_id`)  REFERENCES `schools`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`class_id`)   REFERENCES `classes`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`teacher_id`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── Student Profiles ──────────────────────────────────────────────────────
CREATE TABLE `student_profiles` (
    `id`                INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `user_id`           INT UNSIGNED NOT NULL UNIQUE,
    `class_id`          INT UNSIGNED NULL,
    `admission_no`      VARCHAR(50) UNIQUE,
    `admission_date`    DATE NULL,
    `roll_no`           VARCHAR(30),
    `blood_group`       VARCHAR(10),
    `emergency_contact` VARCHAR(30),
    `medical_notes`     TEXT,
    `created_at`        DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`)   REFERENCES `users`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`class_id`)  REFERENCES `classes`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── Parent-Student Links ──────────────────────────────────────────────────
CREATE TABLE `parent_student` (
    `id`         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `parent_id`  INT UNSIGNED NOT NULL,
    `student_id` INT UNSIGNED NOT NULL,
    `relation`   VARCHAR(50) DEFAULT 'parent',
    UNIQUE KEY `unique_link` (`parent_id`, `student_id`),
    FOREIGN KEY (`parent_id`)  REFERENCES `users`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`student_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── Attendance ────────────────────────────────────────────────────────────
CREATE TABLE `attendance` (
    `id`         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `student_id` INT UNSIGNED NOT NULL,
    `class_id`   INT UNSIGNED NOT NULL,
    `subject_id` INT UNSIGNED NULL,
    `date`       DATE NOT NULL,
    `status`     ENUM('present','absent','late','excused') NOT NULL,
    `note`       TEXT,
    `marked_by`  INT UNSIGNED NULL,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY `unique_att` (`student_id`, `class_id`, `date`, `subject_id`),
    FOREIGN KEY (`student_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`class_id`)   REFERENCES `classes`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`subject_id`) REFERENCES `subjects`(`id`) ON DELETE SET NULL,
    FOREIGN KEY (`marked_by`)  REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── Grades / Marks ────────────────────────────────────────────────────────
CREATE TABLE `grades` (
    `id`              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `student_id`      INT UNSIGNED NOT NULL,
    `subject_id`      INT UNSIGNED NOT NULL,
    `assessment_type` ENUM('exam','quiz','assignment','project','midterm','final','classwork') DEFAULT 'exam',
    `title`           VARCHAR(200),
    `marks_obtained`  DECIMAL(6,2),
    `max_marks`       DECIMAL(6,2) DEFAULT 100,
    `term`            VARCHAR(50),
    `academic_year`   VARCHAR(20),
    `graded_by`       INT UNSIGNED NULL,
    `remarks`         TEXT,
    `created_at`      DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`student_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`subject_id`) REFERENCES `subjects`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`graded_by`)  REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── Assignments ───────────────────────────────────────────────────────────
CREATE TABLE `assignments` (
    `id`          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `subject_id`  INT UNSIGNED NOT NULL,
    `class_id`    INT UNSIGNED NOT NULL,
    `title`       VARCHAR(200) NOT NULL,
    `description` TEXT,
    `file_path`   VARCHAR(300),
    `due_date`    DATETIME NULL,
    `max_marks`   DECIMAL(6,2) DEFAULT 100,
    `created_by`  INT UNSIGNED NULL,
    `status`      ENUM('active','inactive') DEFAULT 'active',
    `created_at`  DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`subject_id`) REFERENCES `subjects`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`class_id`)   REFERENCES `classes`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `assignment_submissions` (
    `id`             INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `assignment_id`  INT UNSIGNED NOT NULL,
    `student_id`     INT UNSIGNED NOT NULL,
    `file_path`      VARCHAR(300),
    `notes`          TEXT,
    `submitted_at`   DATETIME DEFAULT CURRENT_TIMESTAMP,
    `marks_obtained` DECIMAL(6,2) NULL,
    `feedback`       TEXT,
    `graded_by`      INT UNSIGNED NULL,
    `graded_at`      DATETIME NULL,
    `status`         ENUM('submitted','graded','late') DEFAULT 'submitted',
    UNIQUE KEY `unique_sub` (`assignment_id`, `student_id`),
    FOREIGN KEY (`assignment_id`) REFERENCES `assignments`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`student_id`)    REFERENCES `users`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`graded_by`)     REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── Timetable ─────────────────────────────────────────────────────────────
CREATE TABLE `timetable` (
    `id`            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `class_id`      INT UNSIGNED NOT NULL,
    `subject_id`    INT UNSIGNED NOT NULL,
    `teacher_id`    INT UNSIGNED NULL,
    `day_of_week`   TINYINT NOT NULL COMMENT '1=Mon 7=Sun',
    `start_time`    TIME NOT NULL,
    `end_time`      TIME NOT NULL,
    `room`          VARCHAR(50),
    `academic_year` VARCHAR(20),
    `created_at`    DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`class_id`)   REFERENCES `classes`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`subject_id`) REFERENCES `subjects`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`teacher_id`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── Fee Management ────────────────────────────────────────────────────────
CREATE TABLE `fee_types` (
    `id`          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `school_id`   INT UNSIGNED NOT NULL,
    `name`        VARCHAR(150) NOT NULL,
    `amount`      DECIMAL(10,2) NOT NULL,
    `frequency`   ENUM('one_time','monthly','quarterly','yearly') DEFAULT 'monthly',
    `description` TEXT,
    `status`      ENUM('active','inactive') DEFAULT 'active',
    FOREIGN KEY (`school_id`) REFERENCES `schools`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `fee_invoices` (
    `id`             INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `student_id`     INT UNSIGNED NOT NULL,
    `fee_type_id`    INT UNSIGNED NULL,
    `amount`         DECIMAL(10,2) NOT NULL,
    `due_date`       DATE NULL,
    `paid_date`      DATE NULL,
    `payment_method` VARCHAR(50),
    `transaction_id` VARCHAR(100),
    `status`         ENUM('pending','paid','overdue','waived') DEFAULT 'pending',
    `notes`          TEXT,
    `created_by`     INT UNSIGNED NULL,
    `created_at`     DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`student_id`)  REFERENCES `users`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`fee_type_id`) REFERENCES `fee_types`(`id`) ON DELETE SET NULL,
    FOREIGN KEY (`created_by`)  REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── Announcements ─────────────────────────────────────────────────────────
CREATE TABLE `announcements` (
    `id`           INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `school_id`    INT UNSIGNED NULL,
    `title`        VARCHAR(300) NOT NULL,
    `content`      TEXT NOT NULL,
    `target_roles` VARCHAR(300) DEFAULT 'all' COMMENT 'comma-separated roles or all',
    `priority`     ENUM('low','normal','high','urgent') DEFAULT 'normal',
    `created_by`   INT UNSIGNED NULL,
    `publish_at`   DATETIME DEFAULT CURRENT_TIMESTAMP,
    `expires_at`   DATETIME NULL,
    `status`       ENUM('draft','published') DEFAULT 'published',
    `created_at`   DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`school_id`)  REFERENCES `schools`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── Community Posts ───────────────────────────────────────────────────────
CREATE TABLE `community_posts` (
    `id`          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `school_id`   INT UNSIGNED NULL,
    `title`       VARCHAR(300) NOT NULL,
    `content`     TEXT NOT NULL,
    `category`    VARCHAR(100),
    `author_id`   INT UNSIGNED NULL,
    `approved`    TINYINT(1) DEFAULT 0,
    `approved_by` INT UNSIGNED NULL,
    `views`       INT DEFAULT 0,
    `created_at`  DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`school_id`)   REFERENCES `schools`(`id`) ON DELETE SET NULL,
    FOREIGN KEY (`author_id`)   REFERENCES `users`(`id`) ON DELETE SET NULL,
    FOREIGN KEY (`approved_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── Audit Log ─────────────────────────────────────────────────────────────
CREATE TABLE `audit_log` (
    `id`         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `user_id`    INT UNSIGNED NULL,
    `action`     VARCHAR(200) NOT NULL,
    `table_name` VARCHAR(100),
    `record_id`  INT UNSIGNED NULL,
    `old_values` JSON NULL,
    `new_values` JSON NULL,
    `ip_address` VARCHAR(50),
    `user_agent` TEXT,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── AI Interactions (for future) ──────────────────────────────────────────
CREATE TABLE `ai_interactions` (
    `id`           INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `user_id`      INT UNSIGNED NULL,
    `session_id`   VARCHAR(100),
    `role`         VARCHAR(30),
    `user_message` TEXT,
    `ai_response`  TEXT,
    `tokens_used`  INT NULL,
    `model`        VARCHAR(100),
    `created_at`   DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── Indexes ───────────────────────────────────────────────────────────────
CREATE INDEX `idx_users_role`        ON `users`(`role`);
CREATE INDEX `idx_users_school`      ON `users`(`school_id`);
CREATE INDEX `idx_attendance_student` ON `attendance`(`student_id`, `date`);
CREATE INDEX `idx_grades_student`    ON `grades`(`student_id`);
CREATE INDEX `idx_fees_student`      ON `fee_invoices`(`student_id`);
CREATE INDEX `idx_announcements_school` ON `announcements`(`school_id`);

-- ─── Default Super Admin ───────────────────────────────────────────────────
-- Password: Admin@1234 (bcrypt hash)
INSERT INTO `users` (`first_name`, `last_name`, `email`, `password`, `role`, `status`)
VALUES (
    'Super', 'Admin',
    'admin@school.local',
    '$2y$12$TKh8H1.PfQx37YgCzwiKb.KjNyWgaHb9cbcoQgdIVFlYg7B56G3oK',
    'super_admin',
    'active'
);
