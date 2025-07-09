/*
====================================================================================================
-- Project: SQL Data Warehouse and Analytics
-- Script Name: 06_ranking_analysis.sql
-- Description: This script performs "Ranking Analysis," a powerful technique used to order business
--              entities (like products or customers) based on specific performance metrics. By ranking,
--              we can quickly identify the most significant contributors (top performers) and those
--              that are lagging (bottom performers). This is essential for focusing resources,
--              identifying opportunities, and mitigating risks.
--
-- Objectives:
--              1. To identify the top and bottom-performing products by total revenue.
--              2. To identify the most valuable customers based on total revenue and engagement.
--              3. To demonstrate both simple (TOP N) and advanced (window functions) ranking techniques.
--
-- SQL Functions Used:
--              - Window Ranking Functions: RANK() is used for more flexible ranking.
--              - TOP: A simpler clause for retrieving the top N rows from an ordered result set.
--              - GROUP BY, ORDER BY: To aggregate data and sort it for ranking.
--
-- Author: Yeswanth Sai Tirumalsetty
-- Date: 2025-07-08
====================================================================================================
*/

----------------------------------------------------------------------------------------------------
-- Query 1: Identify the Top 5 Revenue-Generating Products (Simple Ranking)
-- Purpose: To quickly find the 5 products that have generated the most revenue. This is a common
--          and direct way to identify "superstar" products that drive the business.
-- Method: Uses the `TOP 5` clause with an `ORDER BY` clause in descending order.
----------------------------------------------------------------------------------------------------
SELECT TOP 5
    p.product_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
    ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC;

----------------------------------------------------------------------------------------------------
-- Query 2: Identify the Top 5 Revenue-Generating Products (Advanced Ranking)
-- Purpose: To achieve the same goal as above but using a more flexible and powerful method.
--          Window functions like RANK() allow for more complex ranking logic (e.g., handling ties,
--          ranking within partitions/categories) and are more standard across different SQL dialects.
-- Method: A subquery first calculates the total revenue for each product and assigns a rank using
--         `RANK()`. The outer query then filters for products where the rank is 5 or less.
----------------------------------------------------------------------------------------------------
SELECT *
FROM (
    SELECT
        p.product_name,
        SUM(f.sales_amount) AS total_revenue,
        RANK() OVER (ORDER BY SUM(f.sales_amount) DESC) AS revenue_rank
    FROM gold.fact_sales AS f
    LEFT JOIN gold.dim_products AS p
        ON p.product_key = f.product_key
    GROUP BY p.product_name
) AS ranked_products
WHERE revenue_rank <= 5;

----------------------------------------------------------------------------------------------------
-- Query 3: Identify the 5 Worst-Performing Products by Sales
-- Purpose: To find the products with the lowest total sales revenue. Identifying these "laggards"
--          is crucial for inventory management, marketing strategy (e.g., promotion or
--          discontinuation), and overall product portfolio health.
-- Method: Uses `TOP 5` but sorts the total revenue in ascending order (`ASC`).
----------------------------------------------------------------------------------------------------
SELECT TOP 5
    p.product_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
    ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue ASC; -- Note the ascending order to find the lowest values.

----------------------------------------------------------------------------------------------------
-- Query 4: Identify the Top 10 Most Valuable Customers by Revenue
-- Purpose: To create a ranked list of the top 10 customers who have spent the most. This is
--          a critical list for VIP programs, personalized marketing, and customer retention efforts.
----------------------------------------------------------------------------------------------------
SELECT TOP 10
    c.customer_key,
    c.first_name,
    c.last_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
    ON c.customer_key = f.customer_key
GROUP BY 
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_revenue DESC;

----------------------------------------------------------------------------------------------------
-- Query 5: Identify the 3 Customers with the Fewest Orders
-- Purpose: To find customers with the lowest engagement, measured by the number of distinct
--          orders placed. This can help identify customers at risk of churn or those who may
--          need a re-engagement marketing campaign.
----------------------------------------------------------------------------------------------------
SELECT TOP 3
    c.customer_key,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT f.order_number) AS total_orders
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
    ON c.customer_key = f.customer_key
GROUP BY 
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_orders ASC; -- Note the ascending order to find the lowest counts.