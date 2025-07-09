/*
====================================================================================================
-- Project: SQL Data Warehouse and Analytics
-- Script Name: 13_report_products.sql
-- Description: This script creates the final comprehensive report for our project, focusing on
--              a "single product view." It consolidates product attributes, sales history, and
--              calculated performance KPIs into a single, reusable data object. This report is
--              a vital asset for category managers, inventory planners, and marketing teams to
--              make data-driven decisions about the product portfolio.
--
-- Report Highlights:
--              1. Gathers essential fields like product name, category, subcategory, and cost.
--              2. Segments products into performance tiers (High-Performer, Mid-Range, Low-Performer).
--              3. Aggregates key product-level metrics: total orders, sales, quantity, and unique customers.
--              4. Calculates advanced KPIs such as recency, average order revenue, and average monthly revenue.
--
-- Object Created:
--              - A SQL VIEW named `gold.report_products` is created. This encapsulates the complex
--                query logic, providing a simple and stable interface for end-users and BI tools.
--
-- Author: Yeswanth Sai Tirumalsetty
-- Date: 2025-07-08
====================================================================================================
*/

-- =============================================================================
-- Create or Replace the View: gold.report_products
-- This ensures that if the view already exists, it is dropped and recreated with the latest logic.
-- =============================================================================
IF OBJECT_ID('gold.report_products', 'V') IS NOT NULL
    DROP VIEW gold.report_products;
GO

CREATE VIEW gold.report_products AS

WITH base_query AS (
/*---------------------------------------------------------------------------
Step 1: Base Query - Gather Raw Transactional and Product Data
Purpose: This CTE joins the fact and dimension tables to create a flat list of
         all sales transactions, enriched with the details of the product sold
         in each transaction. This forms the foundational dataset for aggregation.
---------------------------------------------------------------------------*/
    SELECT
	    f.order_number,
        f.order_date,
		f.customer_key,
        f.sales_amount,
        f.quantity,
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost
    FROM gold.fact_sales AS f
    LEFT JOIN gold.dim_products AS p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
),

product_aggregations AS (
/*---------------------------------------------------------------------------
Step 2: Product-Level Aggregation
Purpose: This CTE takes the raw data from `base_query` and rolls it up to the
         product level. It calculates key summary metrics for each unique product,
         such as its total sales, total orders, and sales lifespan.
---------------------------------------------------------------------------*/
SELECT
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    -- Lifespan is the number of months between a product's first and last sale.
    DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan_in_months,
    MAX(order_date) AS last_sale_date,
    COUNT(DISTINCT order_number) AS total_orders,
	COUNT(DISTINCT customer_key) AS total_customers, -- Number of unique customers who bought this product.
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity,
    -- Calculate the average selling price, safely handling cases where quantity might be zero.
	ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)), 2) AS avg_selling_price
FROM base_query
GROUP BY
    product_key,
    product_name,
    category,
    subcategory,
    cost
)

/*---------------------------------------------------------------------------
Step 3: Final Report Generation - Segmentation and KPI Calculation
Purpose: This final SELECT statement takes the aggregated product data and applies
         the final layer of business logic. It creates performance segments and
         calculates advanced KPIs like recency and average monthly revenue.
---------------------------------------------------------------------------*/
SELECT 
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	last_sale_date,
	-- Recency: How many months have passed since this product was last sold?
	DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_in_months,
	-- Segment products into performance tiers based on total sales revenue.
	CASE
		WHEN total_sales > 50000 THEN 'High-Performer'
		WHEN total_sales >= 10000 THEN 'Mid-Range'
		ELSE 'Low-Performer'
	END AS product_segment,
	lifespan_in_months,
	total_orders,
	total_sales,
	total_quantity,
	total_customers,
	avg_selling_price,
	-- Average Revenue Per Order (for this product)
	CASE 
		WHEN total_orders = 0 THEN 0
		ELSE total_sales / total_orders
	END AS avg_revenue_per_order,
	-- Average Monthly Revenue (for this product)
	CASE
		WHEN lifespan_in_months = 0 THEN total_sales -- If only sold in one month
		ELSE total_sales / lifespan_in_months
	END AS avg_monthly_revenue
FROM product_aggregations;
GO

-- After creating the view, you can easily query it like any other table.
-- Example: SELECT * FROM gold.report_products WHERE product_segment = 'High-Performer';