-- Create the database if it doesn't exist
CREATE DATABASE IF NOT EXISTS flutter;

-- Use the database
USE flutter;

-- Create the user table
CREATE TABLE IF NOT EXISTS user (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    password VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20),
    profile_image VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Add a unique constraint on username and email
ALTER TABLE user ADD CONSTRAINT unique_name UNIQUE (name);
ALTER TABLE user ADD CONSTRAINT unique_email UNIQUE (email);

-- Insert some sample users
INSERT INTO user (name, email, password, phone_number) 
VALUES 
('john_doe', 'john@example.com', 'password123', '1234567890'),
('jane_smith', 'jane@example.com', 'password456', '0987654321')
ON DUPLICATE KEY UPDATE 
    email = VALUES(email),
    password = VALUES(password),
    phone_number = VALUES(phone_number);
