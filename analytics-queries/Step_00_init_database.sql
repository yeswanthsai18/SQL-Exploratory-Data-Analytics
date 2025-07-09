/*
====================================================================================================
-- Project: SQL Data Warehouse and Analytics
-- Script Name: 00_init_database.sql
-- Description: This script handles the complete initialization of the 'DataWarehouseAnalytics' 
--              database. It performs the following sequential operations:
--              1. Checks for the existence of the database and, if found, drops it to ensure a 
--                 clean slate.
--              2. Creates a new, empty 'DataWarehouseAnalytics' database.
--              3. Creates the 'gold' schema, which is designated to hold the final, business-ready
--                 data models as per the Medallion Architecture.
--              4. Defines the table structures for the star schema (dim_customers, dim_products, 
--                 fact_sales) within the 'gold' schema.
--              5. Populates these tables by bulk inserting data from local CSV files.
--
-- Author: Yeswanth Sai Tirumalasetty
-- Date: 2025-07-08
====================================================================================================
--! IMPORTANT WARNING !
--! This script is DESTRUCTIVE and will PERMANENTLY DELETE the existing 'DataWarehouseAnalytics' 
--! database and all of its contents without recovery.
--!
--! It is intended for:
--!   - The initial setup of the project environment.
--!   - A complete reset of the database to its original state for testing or demonstration.
--!
--! ==> DO NOT run this script on a production environment or on a database with valuable data 
--!     unless you have a complete backup and understand the consequences.
====================================================================================================
*/

-- Switch context to the master database to perform database-level operations like DROP and CREATE.
USE master;
GO

----------------------------------------------------------------------------------------------------
-- Section 1: Drop and Recreate the Primary Database
-- This section ensures a clean, consistent starting environment by removing any previous
-- version of the database before creating a new one.
----------------------------------------------------------------------------------------------------

-- Check if the 'DataWarehouseAnalytics' database already exists in the SQL Server instance.
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouseAnalytics')
BEGIN
    -- If the database exists, first set it to single-user mode. This will disconnect all other
    -- users and roll back any open transactions, allowing the DROP command to execute without conflicts.
    ALTER DATABASE DataWarehouseAnalytics SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    
    -- Drop the existing database. All tables, data, and objects will be deleted.
    DROP DATABASE DataWarehouseAnalytics;
    PRINT 'Existing database "DataWarehouseAnalytics" dropped.';
END;
GO

-- Create a new, empty database named 'DataWarehouseAnalytics'.
CREATE DATABASE DataWarehouseAnalytics;
PRINT 'Database "DataWarehouseAnalytics" created successfully.';
GO

-- Switch the current session's context to the newly created database for all subsequent operations.
USE DataWarehouseAnalytics;
GO

----------------------------------------------------------------------------------------------------
-- Section 2: Schema and Table Creation for the Gold Layer
-- This section builds the structure of our data warehouse's Gold Layer, which contains
-- the final, denormalized data model (Star Schema) optimized for analytics.
----------------------------------------------------------------------------------------------------

-- Create the 'gold' schema to logically group our business-ready tables.
CREATE SCHEMA gold;
GO

-- Create the Customer Dimension table.
-- This table stores descriptive attributes about customers. Each row represents a unique customer.
CREATE TABLE gold.dim_customers(
	customer_key int,         -- The primary key for this dimension, used to link to the fact table.
	customer_id int,          -- The original customer identifier from the source system.
	customer_number nvarchar(50), -- A business-facing customer number or code.
	first_name nvarchar(50),
	last_name nvarchar(50),
	country nvarchar(50),
	marital_status nvarchar(50),
	gender nvarchar(50),
	birthdate date,
	create_date date          -- The date the customer record was created.
);
GO
PRINT 'Table "gold.dim_customers" created.';

-- Create the Product Dimension table.
-- This table stores descriptive attributes about products. Each row represents a unique product.
CREATE TABLE gold.dim_products(
	product_key int,          -- The primary key for this dimension, used to link to the fact table.
	product_id int,           -- The original product identifier from the source system.
	product_number nvarchar(50),  -- A business-facing product number or SKU.
	product_name nvarchar(50),
	category_id nvarchar(50),
	category nvarchar(50),
	subcategory nvarchar(50),
	maintenance nvarchar(50), -- An indicator for whether the product requires maintenance.
	cost int,
	product_line nvarchar(50),
	start_date date           -- The date the product was first introduced.
);
GO
PRINT 'Table "gold.dim_products" created.';

-- Create the Sales Fact table.
-- This is the central table in our star schema. It stores quantitative measures (facts)
-- about each sales transaction. Each row represents a specific line item in an order.
CREATE TABLE gold.fact_sales(
	order_number nvarchar(50), -- The identifier for the sales order.
	product_key int,           -- Foreign key linking to gold.dim_products.
	customer_key int,          -- Foreign key linking to gold.dim_customers.
	order_date date,
	shipping_date date,
	due_date date,
	sales_amount int,
	quantity tinyint,
	price int 
);
GO
PRINT 'Table "gold.fact_sales" created.';

----------------------------------------------------------------------------------------------------
-- Section 3: Data Population via Bulk Insert
-- This section loads data from external CSV files into the newly created tables.
-- NOTE: The file paths used here are absolute and must be updated to match the location
--       of the CSV files on your local machine.
----------------------------------------------------------------------------------------------------

-- Load data into the Customer Dimension table.
-- First, truncate the table to ensure it's empty before loading, preventing duplicate data on re-runs.
TRUNCATE TABLE gold.dim_customers;
GO

BULK INSERT gold.dim_customers
-- IMPORTANT: Update this file path to the correct location on your system.
FROM 'C:\Users\yeswa\Downloads\Projects\sql-data-analytics-project\datasets\csv-files'