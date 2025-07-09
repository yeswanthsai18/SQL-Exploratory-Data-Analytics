/*
====================================================================================================
-- Project: SQL Data Warehouse and Analytics
-- Script Name: 02_dimensions_exploration.sql
-- Description: This script focuses on exploring the categorical data within our dimension tables.
--              Dimension exploration is a key step in Exploratory Data Analysis (EDA) where we
--              investigate the distinct values in columns that describe our data. This helps us
--              understand the breadth and variety of our business entities, such as the different
--              customer countries we operate in or the hierarchy of our product catalog.
--
-- Objectives:
--              1. To identify the unique values within key descriptive columns (dimensions).
--              2. To validate the data's integrity and variety (e.g., check for typos or unexpected values).
--              3. To understand the attributes available for filtering, grouping, and segmenting
--                 data in more advanced analytical queries.
--
-- SQL Functions Used:
--              - DISTINCT: Used to return only unique (different) values from a column.
--              - ORDER BY: Used to sort the result set in ascending order for better readability.
--
-- Author: Yeswanth Sai Tirumalasetty
-- Date: 2025-07-08
====================================================================================================
*/

----------------------------------------------------------------------------------------------------
-- Query 1: Explore Unique Customer Countries
-- Purpose: To generate a distinct, alphabetized list of all countries where our customers are located.
--          This query is fundamental for understanding our business's geographical footprint and
--          is often a starting point for geographical sales analysis.
----------------------------------------------------------------------------------------------------
SELECT DISTINCT 
    country 
FROM gold.dim_customers
ORDER BY country; -- Sorting the list makes it easy to read and review.

----------------------------------------------------------------------------------------------------
-- Query 2: Explore the Product Hierarchy
-- Purpose: To retrieve a unique list of all product combinations, showing the full hierarchy from
--          category down to the specific product name. This is crucial for understanding the
--          structure of our product catalog and for performing analysis at different levels of
--          granularity (e.g., total sales by category vs. by subcategory).
----------------------------------------------------------------------------------------------------
SELECT DISTINCT 
    category, 
    subcategory, 
    product_name 
FROM gold.dim_products
-- Ordering by the hierarchy ensures a structured and logical output.
ORDER BY category, subcategory, product_name;