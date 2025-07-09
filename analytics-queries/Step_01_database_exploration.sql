/*
====================================================================================================
-- Project: SQL Data Warehouse and Analytics
-- Script Name: 01_database_exploration.sql
-- Description: This script performs the initial exploratory phase of our data analysis. It uses
--              the standard INFORMATION_SCHEMA views to inspect the metadata of our data warehouse.
--              This is the first and most crucial step before writing any analytical queries, as it
--              allows us to understand the "lay of the land"—what tables exist and what their
--              internal structures look like.
--
-- Objectives:
--              1. To list all tables available within the current database, confirming that our
--                 initialization script ran successfully.
--              2. To perform a detailed inspection of a specific table's schema (e.g., dim_customers),
--                 examining its columns, data types, and nullability constraints.
--
-- Views Used:
--              - INFORMATION_SCHEMA.TABLES: A system view that contains metadata about all tables
--                and views in a database.
--              - INFORMATION_SCHEMA.COLUMNS: A system view that contains metadata about all columns
--                for all tables and views.
--
-- Author: Yeswanth Sai Tirumalasetty
-- Date: 2025-07-08
====================================================================================================
*/

----------------------------------------------------------------------------------------------------
-- Query 1: High-Level Database Inventory
-- Purpose: To get a complete list of all tables and views within the 'DataWarehouseAnalytics'
--          database. This query acts as a high-level map, showing us what data assets are
--          available for analysis.
----------------------------------------------------------------------------------------------------
SELECT 
    TABLE_CATALOG,  -- The name of the database where the table resides.
    TABLE_SCHEMA,   -- The schema that owns the table (e.g., 'gold'). This helps in understanding the data's stage.
    TABLE_NAME,     -- The name of the table or view.
    TABLE_TYPE      -- The type of object, typically 'BASE TABLE' for tables or 'VIEW' for views.
FROM INFORMATION_SCHEMA.TABLES;

----------------------------------------------------------------------------------------------------
-- Query 2: Detailed Table Schema Inspection
-- Purpose: To "zoom in" on a specific table and inspect the properties of each of its columns.
--          This is essential for understanding the data's structure, data types, and constraints
--          before attempting to query or join the table.
--
-- Instructions: You can change the table name in the WHERE clause to inspect any other table
--               (e.g., 'dim_products' or 'fact_sales').
----------------------------------------------------------------------------------------------------
SELECT 
    COLUMN_NAME,                 -- The name of the column.
    DATA_TYPE,                   -- The data type of the column (e.g., nvarchar, int, date).
    IS_NULLABLE,                 -- Indicates if the column allows NULL values ('YES' or 'NO').
    CHARACTER_MAXIMUM_LENGTH     -- For character-based columns (like nvarchar), this shows the maximum length.
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers'; -- <-- Change this value to inspect a different table.