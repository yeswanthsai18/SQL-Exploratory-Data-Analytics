/*
====================================================================================================
-- Project: SQL Data Warehouse and Analytics
-- Script Name: 11_part_to_whole_analysis.sql
-- Description: This script performs "Part-to-Whole Analysis," a technique used to understand the
--              proportional contribution of different segments to a total metric. In this case,
--              we analyze what percentage of total sales each product category is responsible for.
--              This is crucial for identifying the most important areas of the business and for
--              understanding concentration risk (e.g., are we too reliant on one category?).
--
-- Objectives:
--              1. To calculate the total sales for each individual product category.
--              2. To calculate the grand total of all sales across all categories.
--              3. To compute the percentage contribution of each category to the grand total.
--
-- SQL Functions Used:
--              - Common Table Expression (WITH): To pre-aggregate sales by category.
--              - Window Functions: SUM() OVER() is used to calculate the grand total without
--                requiring a separate query or join.
--              - CAST/ROUND: To ensure accurate division for the percentage calculation and to
--                format the final result.
--
-- Author: Yeswanth Sai Tirumalsetty
-- Date: 2025-07-08
====================================================================================================
*/

----------------------------------------------------------------------------------------------------
-- Query: Calculate the Percentage Contribution of Each Product Category to Total Sales
-- Purpose: This query generates a report that not only shows the total sales for each category
--          but also calculates what percentage of the overall company sales each category represents.
-- Method: A CTE first aggregates sales by category. The main query then uses a window function
--         to calculate the total sales and compute the percentage.
----------------------------------------------------------------------------------------------------
WITH category_sales AS (
    -- Step 1: Create a temporary result set (CTE) that calculates the total sales for each category.
    SELECT
        p.category,
        SUM(f.sales_amount) AS total_sales
    FROM gold.fact_sales AS f
    LEFT JOIN gold.dim_products AS p
        ON p.product_key = f.product_key
    GROUP BY p.category
)
-- Step 2: Use the aggregated data from the CTE to perform the part-to-whole calculation.
SELECT
    category,
    total_sales,
    
    -- This window function calculates the grand total of sales across all categories.
    -- The empty OVER() clause tells the function to operate on the entire result set from the CTE.
    SUM(total_sales) OVER () AS overall_sales,
    
    -- This calculates the percentage contribution.
    -- We CAST total_sales to FLOAT to ensure the division results in a decimal, not an integer.
    -- We then multiply by 100 and ROUND to 2 decimal places for a clean percentage format.
    ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER ()) * 100, 2) AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC; -- Order by sales to easily see the largest contributors at the top.