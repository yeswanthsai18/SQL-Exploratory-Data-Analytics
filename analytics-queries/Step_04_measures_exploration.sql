/*
====================================================================================================
-- Project: SQL Data Warehouse and Analytics
-- Script Name: 04_measures_exploration.sql
-- Description: This script focuses on exploring the core quantitative measures (or facts) within
--              our dataset. This stage of EDA is about calculating the "big numbers" or Key
--              Performance Indicators (KPIs) that provide a high-level snapshot of the business's
--              overall performance and scale. These metrics are fundamental for executive
--              summaries, dashboards, and initial health checks.
--
-- Objectives:
--              1. To calculate total revenue, total items sold, and the average price point.
--              2. To quantify the scale of operations by counting total orders, customers, and products.
--              3. To create a consolidated summary report of all key business metrics.
--
-- SQL Functions Used:
--              - SUM(): Calculates the total sum of a numeric column.
--              - AVG(): Calculates the average value of a numeric column.
--              - COUNT(): Counts the number of rows or non-null values.
--              - UNION ALL: Combines the result sets of multiple SELECT statements.
--
-- Author: Yeswanth Sai Tirumalsetty
-- Date: 2025-07-08
====================================================================================================
*/

----------------------------------------------------------------------------------------------------
-- Individual KPI Calculations
-- The following queries calculate individual key metrics. Each provides a specific, isolated
-- insight into a different aspect of the business.
----------------------------------------------------------------------------------------------------

-- Calculate the total revenue generated from all sales. This is a primary business KPI.
SELECT SUM(sales_amount) AS total_sales 
FROM gold.fact_sales;

-- Calculate the total number of individual items sold across all orders.
SELECT SUM(quantity) AS total_quantity_sold 
FROM gold.fact_sales;

-- Calculate the average selling price per item across all transactions.
SELECT AVG(price) AS average_item_price 
FROM gold.fact_sales;

-- Calculate the total number of unique sales orders.
-- Note: Using COUNT(DISTINCT order_number) is crucial here to count each order only once,
-- even if an order contains multiple products (and thus has multiple rows in the fact table).
SELECT COUNT(DISTINCT order_number) AS total_unique_orders 
FROM gold.fact_sales;

-- Calculate the total number of unique products available in our product catalog.
SELECT COUNT(DISTINCT product_name) AS total_unique_products 
FROM gold.dim_products;

-- Calculate the total number of customer records in our system.
SELECT COUNT(customer_key) AS total_customers_in_system
FROM gold.dim_customers;

-- Calculate the total number of unique customers who have actually placed an order.
-- This metric identifies our "active" customer base, which can be different from the total
-- number of customer records in the system.
SELECT COUNT(DISTINCT customer_key) AS total_active_customers 
FROM gold.fact_sales;

----------------------------------------------------------------------------------------------------
-- Consolidated Business KPI Report
-- Purpose: To generate a single, unified report that displays all of the key business metrics
--          calculated above. This format is extremely useful for quick-glance dashboards,
--          automated reports, or for easily exporting a summary of business health.
-- Technique: UNION ALL is used to stack the results of each individual KPI query on top of each other.
----------------------------------------------------------------------------------------------------
SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity Sold', SUM(quantity) FROM gold.fact_sales
UNION ALL
SELECT 'Average Item Price', AVG(price) FROM gold.fact_sales
UNION ALL
SELECT 'Total Unique Orders', COUNT(DISTINCT order_number) FROM gold.fact_sales
UNION ALL
SELECT 'Total Unique Products', COUNT(DISTINCT product_name) FROM gold.dim_products
UNION ALL
SELECT 'Total Active Customers', COUNT(DISTINCT customer_key) FROM gold.fact_sales;