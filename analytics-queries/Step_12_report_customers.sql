/*
====================================================================================================
-- Project: SQL Data Warehouse and Analytics
-- Script Name: 12_report_customers.sql
-- Description: This script culminates our analysis by creating a comprehensive customer report.
--              The goal is to build a "single customer view" that consolidates demographic data,
--              transactional history, and calculated Key Performance Indicators (KPIs) into a single,
--              reusable data object. This report serves as a foundational asset for marketing teams,
--              sales analysis, and customer service.
--
-- Report Highlights:
--              1. Gathers essential fields like customer name, age, and transaction details.
--              2. Segments customers into value-based categories (VIP, Regular, New) and age groups.
--              3. Aggregates key customer-level metrics like total orders, sales, and products purchased.
--              4. Calculates advanced KPIs such as recency, average order value, and average monthly spend.
--
-- Object Created:
--              - A SQL VIEW named `gold.report_customers` is created. Using a view encapsulates the
--                complex logic, making it easy for end-users to query the final report without
--                needing to understand the underlying calculations.
--
-- Author: Yeswanth Sai Tirumalsetty
-- Date: 2025-07-08
====================================================================================================
*/

-- =============================================================================
-- Create or Replace the View: gold.report_customers
-- This ensures that if the view already exists, it is dropped and recreated with the latest logic.
-- =============================================================================
IF OBJECT_ID('gold.report_customers', 'V') IS NOT NULL
    DROP VIEW gold.report_customers;
GO

CREATE VIEW gold.report_customers AS

WITH base_query AS (
/*---------------------------------------------------------------------------
Step 1: Base Query - Gather Raw Transactional and Customer Data
Purpose: This CTE joins the fact and dimension tables to create a flat list of
         all transactions, enriched with basic customer details like name and age.
         This serves as the foundational dataset for all subsequent aggregations.
---------------------------------------------------------------------------*/
SELECT
    f.order_number,
    f.product_key,
    f.order_date,
    f.sales_amount,
    f.quantity,
    c.customer_key,
    c.customer_number,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    DATEDIFF(year, c.birthdate, GETDATE()) AS age
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
    ON c.customer_key = f.customer_key
WHERE f.order_date IS NOT NULL
),

customer_aggregation AS (
/*---------------------------------------------------------------------------
Step 2: Customer-Level Aggregation
Purpose: This CTE takes the raw data from `base_query` and rolls it up to the
         customer level. It calculates key summary metrics for each unique customer,
         such as their total spending, total orders, and purchasing lifespan.
---------------------------------------------------------------------------*/
SELECT 
	customer_key,
	customer_number,
	customer_name,
	age,
	COUNT(DISTINCT order_number) AS total_orders,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	COUNT(DISTINCT product_key) AS total_products,
	MAX(order_date) AS last_order_date,
	-- Lifespan is the number of months between a customer's first and last order.
	DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan_in_months
FROM base_query
GROUP BY 
	customer_key,
	customer_number,
	customer_name,
	age
)
/*---------------------------------------------------------------------------
Step 3: Final Report Generation - Segmentation and KPI Calculation
Purpose: This final SELECT statement takes the aggregated customer data and applies
         the final layer of business logic. It creates customer segments based on
         age and value, and calculates advanced KPIs like recency and average spend.
---------------------------------------------------------------------------*/
SELECT
    customer_key,
    customer_number,
    customer_name,
    age,
    -- Segment customers into logical age brackets for demographic analysis.
    CASE 
        WHEN age < 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50 and Above'
    END AS age_group,
    -- Segment customers based on their value and tenure.
    CASE 
        WHEN lifespan_in_months >= 12 AND total_sales > 5000 THEN 'VIP'
        WHEN lifespan_in_months >= 12 AND total_sales <= 5000 THEN 'Regular'
        ELSE 'New'
    END AS customer_segment,
    last_order_date,
    -- Recency: A critical KPI indicating how recently a customer has engaged with the business.
    DATEDIFF(month, last_order_date, GETDATE()) AS recency_in_months,
    total_orders,
    total_sales,
    total_quantity,
    total_products,
    lifespan_in_months,
    -- Average Order Value (AOV): Total spending divided by the number of orders.
    CASE 
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders
    END AS avg_order_value,
    -- Average Monthly Spend: Total spending divided by their active lifespan.
    -- If lifespan is 0 (only one month of activity), their monthly spend is their total spend.
    CASE 
        WHEN lifespan_in_months = 0 THEN total_sales
        ELSE total_sales / lifespan_in_months
    END AS avg_monthly_spend
FROM customer_aggregation;
GO

-- After creating the view, you can easily query it like any other table.
-- Example: SELECT * FROM gold.report_customers WHERE customer_segment = 'VIP';