-- ============================================
--  DATABASE CREATION FOR SPRING BOOT USER APP
-- ============================================

-- Create database only if it doesn't exist
CREATE DATABASE IF NOT EXISTS userdb;
USE userdb;

-- ===========================
--  USERS TABLE
-- ===========================
DROP TABLE IF EXISTS users;

CREATE TABLE users (
    id BIGINT NOT NULL AUTO_INCREMENT,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    tel VARCHAR(20) NOT NULL UNIQUE,
    psw VARCHAR(255) NOT NULL,
    
    PRIMARY KEY (id)
);
