use lab
GO
IF DB_ID (N'lab5') IS NOT NULL
	DROP DATABASE lab5;
GO

CREATE DATABASE lab5
	ON (NAME = lab5_dat, FILENAME = 
		'D:\data\lab5dat.mdf',
		SIZE = 10, MAXSIZE = UNLIMITED, FILEGROWTH = 5 %)
	LOG ON (NAME = lab5_log, FILENAME = 
		'D:\data\lab5log.ldf',
		SIZE = 5MB, MAXSIZE = 25MB, FILEGROWTH = 5MB);
GO

USE lab5
GO

IF OBJECT_ID (N'Books') IS NOT NULL
	DROP TABLE Books;
GO

CREATE TABLE Books (
	Name varchar(255) NOT NULL,
	Author varchar(255) NOT NULL,
	Description TEXT ,
	Publication_date Date NOT NULL
);
GO

INSERT INTO Books(Name, Author, Publication_date)
VALUES (
	'The Little Prince',
	'Antoine de Saint-Exupery',
	'1943-04-01'
);
GO

ALTER DATABASE lab5	
	ADD FILEGROUP lab5_filegroup;
GO

ALTER DATABASE lab5
	ADD FILE ( 
		NAME = lab5_data_fg,
		FILENAME = 'D:\data\lab5datfg.ndf',
		SIZE = 5,
		MAXSIZE = UNLIMITED,
		FILEGROWTH = 10%
	) TO FILEGROUP lab5_filegroup;
GO

ALTER DATABASE lab5
	MODIFY FILEGROUP lab5_filegroup DEFAULT;
GO

IF OBJECT_ID (N'Users') IS NOT NULL
	DROP TABLE Users;
GO

CREATE TABLE Users (
	First_name varchar(255) NOT NULL,
	Second_name varchar(255) NOT NULL,
	Birthday DATE,
	PassportID char(12) NOT NULL
);
GO

INSERT INTO Users (First_name, Second_name, PassportID)
VALUES (
	'Nikita',
	'Volkov',
	'9292555123'
);
GO

ALTER DATABASE lab5
	MODIFY FILEGROUP [PRIMARY] DEFAULT;
GO


SELECT * INTO Users_extra FROM Users
GO

DROP TABLE Users;
GO

ALTER DATABASE lab5
	REMOVE FILE lab5_data_fg
GO

ALTER DATABASE lab5
	REMOVE FILEGROUP lab5_filegroup;
GO

IF SCHEMA_ID (N'lab5_schema') IS NOT NULL
	DROP SCHEMA lab5_schema;
GO

CREATE SCHEMA lab5_schema
GO

ALTER SCHEMA lab5_schema TRANSFER Books;

SELECT * FROM Users_extra
GO

SELECT * FROM lab5_schema.Books
GO

DROP TABLE lab5_schema.Books
GO

DROP SCHEMA lab5_schema
