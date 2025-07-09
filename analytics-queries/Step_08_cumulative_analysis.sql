/*
====================================================================================================
-- Project: SQL Data Warehouse and Analytics
-- Script Name: 08_cumulative_analysis.sql
-- Description: This script performs "Cumulative Analysis," which involves calculating metrics that
--              accumulate over time, such as running totals or moving averages. This type of
--              analysis is essential for visualizing growth trajectories and smoothing out
--              short-term fluctuations to see the underlying long-term trend. It helps answer
--              questions like, "What is our total revenue growth since we started?"
--
-- Objectives:
--              1. To first aggregate sales data by a specific time period (e.g., year).
--              2. To then calculate a running total of sales to track cumulative growth.
--              3. To calculate a moving average of the price to observe trends in pricing.
--
-- SQL Functions Used:
--              - Window Functions: SUM() OVER(), AVG() OVER() are the core of this analysis.
--              - Subquery/Derived Table: Used to pre-aggregate data before applying window functions.
--
-- Author: Yeswanth Sai Tirumalsetty
-- Date: 2025-07-08
====================================================================================================
*/

----------------------------------------------------------------------------------------------------
-- Query: Calculate Yearly Sales with Running Total and Moving Average Price
-- Purpose: This query generates a report showing the total sales for each year, alongside a
--          cumulative running total of sales and a moving average of the price over time.
--
-- Query Structure:
--   1. Inner Query (Derived Table 't'): First, it calculates the total sales and average price
--      for each year by grouping the raw sales data.
--   2. Outer Query: It then takes the yearly aggregated results from the inner query and applies
--      window functions to calculate the cumulative metrics across the years.
----------------------------------------------------------------------------------------------------
SELECT
	order_date,
	total_sales,
	-- This calculates the running total. For each row (year), it sums the 'total_sales' of that
	-- year and all preceding years, showing the cumulative revenue growth.
	SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
	
	-- This calculates a moving average. For each row (year), it calculates the average of the
	-- 'avg_price' from the first year up to the current year.
	AVG(avg_price) OVER (ORDER BY order_date) AS moving_average_price
FROM
(
    -- Inner query to pre-aggregate data on a yearly basis.
    SELECT 
        DATETRUNC(year, order_date) AS order_date, -- Truncates each date to the start of its year.
        SUM(sales_amount) AS total_sales,
        AVG(price) AS avg_price
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(year, order_date)
) AS t; -- The derived table is aliased as 't'.