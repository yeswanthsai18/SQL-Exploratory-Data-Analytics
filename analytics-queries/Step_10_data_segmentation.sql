/*
====================================================================================================
-- Project: SQL Data Warehouse and Analytics
-- Script Name: 10_data_segmentation.sql
-- Description: This script performs "Data Segmentation," a powerful analytical technique used to
--              divide a broad group into smaller subgroups based on shared characteristics. By
--              creating these segments, we can tailor strategies, understand behavior more deeply,
--              and allocate resources more effectively. This script demonstrates two common use
--              cases: segmenting products by cost and segmenting customers by their value and tenure.
--
-- Objectives:
--              1. To categorize products into predefined cost tiers to understand catalog composition.
--              2. To classify customers into meaningful value segments (e.g., VIP, Regular, New)
--                 based on their historical purchasing behavior.
--
-- SQL Functions Used:
--              - CASE Statement: The core function for defining the rules of each segment.
--              - Common Table Expression (WITH): To structure the queries logically and improve readability.
--              - GROUP BY: To aggregate results for each defined segment.
--
-- Author: Yeswanth Sai Tirumalsetty
-- Date: 2025-07-08
====================================================================================================
*/

----------------------------------------------------------------------------------------------------
-- Query 1: Segment Products by Cost Range
-- Purpose: To understand the distribution of our products across different cost tiers. This helps
--          in analyzing our pricing strategy, identifying our focus on budget vs. premium items,
--          and managing inventory.
-- Method: A CTE first assigns a 'cost_range' label to each product using a CASE statement. The
--         outer query then counts the number of products within each defined range.
----------------------------------------------------------------------------------------------------
WITH product_segments AS (
    SELECT
        product_key,
        product_name,
        cost,
        -- This CASE statement defines the logic for our cost-based segments.
        CASE 
            WHEN cost < 100 THEN 'Budget (<$100)'
            WHEN cost BETWEEN 100 AND 500 THEN 'Standard ($100-$500)'
            WHEN cost BETWEEN 500 AND 1000 THEN 'Premium ($500-$1000)'
            ELSE 'Luxury (>$1000)'
        END AS cost_range
    FROM gold.dim_products
)
-- Final query counts the products in each segment.
SELECT 
    cost_range,
    COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC;

----------------------------------------------------------------------------------------------------
-- Query 2: Segment Customers by Value and Tenure
-- Purpose: To create a more sophisticated customer segmentation model than just total spending.
--          This model considers both spending and customer lifespan to identify VIPs, loyal
--          regulars, and new customers, enabling highly targeted marketing and retention strategies.
--
-- Segmentation Logic:
--   - VIP: Long-term customers (>= 12 months) with high spending (> $5,000).
--   - Regular: Long-term customers (>= 12 months) with moderate or low spending.
--   - New: Customers with less than 12 months of purchasing history, regardless of spending.
--
-- Method: This query uses a nested CTE structure for clarity.
--   1. `customer_spending` CTE: First, calculates the required metrics (total spending, lifespan) for each customer.
--   2. `segmented_customers` Subquery: Applies the CASE statement to assign a segment label.
--   3. Final Query: Counts the number of customers in each final segment.
----------------------------------------------------------------------------------------------------
WITH customer_spending AS (
    -- Step 1: Calculate total spending and lifespan for each customer.
    SELECT
        c.customer_key,
        SUM(f.sales_amount) AS total_spending,
        DATEDIFF(month, MIN(f.order_date), MAX(f.order_date)) AS lifespan_in_months
    FROM gold.fact_sales AS f
    LEFT JOIN gold.dim_customers AS c
        ON f.customer_key = c.customer_key
    GROUP BY c.customer_key
)
-- Step 3: Count the customers in each segment.
SELECT 
    customer_segment,
    COUNT(customer_key) AS total_customers
FROM (
    -- Step 2: Apply the segmentation rules using a CASE statement.
    SELECT 
        customer_key,
        CASE 
            WHEN lifespan_in_months >= 12 AND total_spending > 5000 THEN 'VIP Customer'
            WHEN lifespan_in_months >= 12 AND total_spending <= 5000 THEN 'Regular Customer'
            ELSE 'New Customer'
        END AS customer_segment
    FROM customer_spending
) AS segmented_customers
GROUP BY customer_segment
ORDER BY total_customers DESC;