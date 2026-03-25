-- Initialization script for project database
CREATE DATABASE WebProjectDb;
GO

USE WebProjectDb;
GO

CREATE TABLE Users (
    Id INT PRIMARY KEY IDENTITY,
    Username NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE()
);
GO
