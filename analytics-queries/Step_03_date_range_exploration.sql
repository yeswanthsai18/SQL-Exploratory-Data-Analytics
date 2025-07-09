/*
====================================================================================================
-- Project: SQL Data Warehouse and Analytics
-- Script Name: 03_date_range_exploration.sql
-- Description: This script is dedicated to exploring the temporal (time-based) dimensions of our
--              dataset. Understanding the date ranges is a fundamental part of EDA, as it provides
--              context for the entire dataset. It helps us determine the time frame of our transactional
--              data and understand the age demographics of our customers.
--
-- Objectives:
--              1. To determine the start and end dates of our sales history, which defines the scope
--                 for any time-series analysis.
--              2. To calculate the age range of our customer base to inform demographic analysis
--                 and marketing segmentation.
--
-- SQL Functions Used:
--              - MIN(): Returns the earliest date in a column.
--              - MAX(): Returns the latest date in a column.
--              - DATEDIFF(): Calculates the difference between two dates in a specified unit (e.g., MONTH, YEAR).
--              - GETDATE(): Returns the current database server date and time.
--
-- Author: Yeswanth Sai Tirumalsetty
-- Date: 2025-07-08
====================================================================================================
*/

----------------------------------------------------------------------------------------------------
-- Query 1: Determine the Operational Time Frame of Sales Data
-- Purpose: To find the very first and the most recent order dates recorded in our sales data.
--          This establishes the complete historical scope of our transactions and indicates the
--          freshness of the data.
----------------------------------------------------------------------------------------------------
SELECT 
    MIN(order_date) AS first_order_date,        -- The earliest date an order was placed.
    MAX(order_date) AS last_order_date,         -- The most recent date an order was placed.
    DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS order_range_months -- The total duration of sales history in months.
FROM gold.fact_sales;

----------------------------------------------------------------------------------------------------
-- Query 2: Analyze the Age Demographics of the Customer Base
-- Purpose: To determine the age range of our customers by finding the birthdates of the
--          oldest and youngest individuals. This is a key piece of demographic information
--          for marketing and product development.
-- Note: The calculated ages are dynamic and will change depending on the date this script is executed.
----------------------------------------------------------------------------------------------------
SELECT
    MIN(birthdate) AS oldest_customer_birthdate,    -- The earliest birthdate, corresponding to our oldest customer.
    DATEDIFF(YEAR, MIN(birthdate), GETDATE()) AS oldest_customer_age, -- Calculated age of the oldest customer.
    MAX(birthdate) AS youngest_customer_birthdate,  -- The latest birthdate, corresponding to our youngest customer.
    DATEDIFF(YEAR, MAX(birthdate), GETDATE()) AS youngest_customer_age  -- Calculated age of the youngest customer.
FROM gold.dim_customers;