/*
====================================================================================================
-- Project: SQL Data Warehouse and Analytics
-- Script Name: 09_performance_analysis.sql
-- Description: This script conducts "Performance Analysis" by comparing a metric against a benchmark.
--              Here, we analyze the yearly sales of each product against two different benchmarks:
--              1. The product's own average yearly sales (to see if a year was above/below average).
--              2. The product's sales from the previous year (to calculate Year-over-Year growth/decline).
--              This type of analysis is crucial for understanding performance trends, identifying outlier
--              years, and evaluating the impact of marketing or strategic changes.
--
-- Objectives:
--              1. To calculate each product's sales on a yearly basis.
--              2. To compare each year's sales against the product's historical average.
--              3. To calculate the Year-over-Year (YoY) sales difference and label the trend.
--
-- SQL Functions Used:
--              - Common Table Expression (WITH): To create a temporary, named result set (yearly_product_sales).
--              - Window Functions:
--                  - AVG() OVER(): To compute the average sales for each product across all years.
--                  - LAG(): To access data from a previous row within the same result set (i.e., the previous year's sales).
--              - CASE Statement: To apply conditional logic and create descriptive labels for the analysis.
--
-- Author: Yeswanth Sai Tirumalsetty
-- Date: 2025-07-08
====================================================================================================
*/

-- We use a Common Table Expression (CTE) to first prepare our base data.
-- This CTE aggregates sales for each product for each year.
WITH yearly_product_sales AS (
    SELECT
        YEAR(f.order_date) AS order_year,
        p.product_name,
        SUM(f.sales_amount) AS current_sales
    FROM gold.fact_sales AS f
    LEFT JOIN gold.dim_products AS p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY 
        YEAR(f.order_date),
        p.product_name
)
-- The main query now uses the pre-aggregated data from our CTE.
SELECT
    order_year,
    product_name,
    current_sales,
    
    ------------------------------------------------------------------------------------------------
    -- Part 1: Comparison to the Product's Historical Average Sales
    ------------------------------------------------------------------------------------------------
    -- Calculate the average yearly sales for each product across all years it was sold.
    -- `PARTITION BY product_name` ensures the average is calculated separately for each product.
    AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales_for_product,
    
    -- Calculate the difference between the current year's sales and the product's average sales.
    current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS variance_from_average,
    
    -- Use a CASE statement to create a simple, human-readable label for the performance.
    CASE 
        WHEN current_sales > AVG(current_sales) OVER (PARTITION BY product_name) THEN 'Above Average'
        WHEN current_sales < AVG(current_sales) OVER (PARTITION BY product_name) THEN 'Below Average'
        ELSE 'Average'
    END AS performance_vs_average,
    
    ------------------------------------------------------------------------------------------------
    -- Part 2: Year-over-Year (YoY) Performance Analysis
    ------------------------------------------------------------------------------------------------
    -- Use the LAG() function to retrieve the sales amount from the previous year for the same product.
    -- `PARTITION BY product_name` ensures we only look at the same product.
    -- `ORDER BY order_year` tells LAG() that the "previous" row is the one from the prior year.
    LAG(current_sales, 1, 0) OVER (PARTITION BY product_name ORDER BY order_year) AS previous_year_sales,
    
    -- Calculate the absolute difference in sales compared to the previous year.
    current_sales - LAG(current_sales, 1, 0) OVER (PARTITION BY product_name ORDER BY order_year) AS year_over_year_change,
    
    -- Use a CASE statement to label the YoY trend as an increase, decrease, or no change.
    CASE 
        WHEN current_sales > LAG(current_sales, 1, 0) OVER (PARTITION BY product_name ORDER BY order_year) THEN 'Increase'
        WHEN current_sales < LAG(current_sales, 1, 0) OVER (PARTITION BY product_name ORDER BY order_year) THEN 'Decrease'
        ELSE 'No Change'
    END AS year_over_year_trend

FROM yearly_product_sales
ORDER BY product_name, order_year; -- Order results for clear, chronological viewing for each product.