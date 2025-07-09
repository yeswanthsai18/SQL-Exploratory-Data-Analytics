/*
====================================================================================================
-- Project: SQL Data Warehouse and Analytics
-- Script Name: 07_change_over_time_analysis.sql
-- Description: This script is dedicated to "Change Over Time Analysis," also known as time-series
--              analysis. This is one of the most powerful forms of analytics, as it allows us to
--              track the performance of key business metrics over specific periods. By doing so,
--              we can identify trends (e.g., is revenue growing?), seasonality (e.g., do we sell
--              more in December?), and the impact of business initiatives. This script demonstrates
--              several common techniques for aggregating data by month.
--
-- Objectives:
--              1. To aggregate key metrics (total sales, customer count, quantity sold) on a
--                 monthly basis.
--              2. To demonstrate and compare different SQL functions for handling date parts and
--                 formatting, including YEAR()/MONTH(), DATETRUNC(), and FORMAT().
--
-- SQL Functions Used:
--              - Date Functions: YEAR(), MONTH(), DATETRUNC(), FORMAT()
--              - Aggregate Functions: SUM(), COUNT()
--
-- Author: Yeswanth Sai Tirumalsetty
-- Date: 2025-07-08
====================================================================================================
*/

----------------------------------------------------------------------------------------------------
-- Method 1: Using YEAR() and MONTH() Functions
-- Purpose: To analyze monthly sales performance by extracting the year and month parts from the
--          order date. This is a straightforward and highly compatible method across most SQL dialects.
-- Pro: Very explicit and easy to understand.
-- Con: Results in two separate columns for year and month, which might require extra handling
--      in a visualization tool.
----------------------------------------------------------------------------------------------------
SELECT
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL -- Best practice to filter out any null dates.
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date);

----------------------------------------------------------------------------------------------------
-- Method 2: Using DATETRUNC() Function
-- Purpose: To achieve the same monthly aggregation by "truncating" each date to the beginning
--          of its respective month (e.g., '2024-03-15' becomes '2024-03-01').
-- Pro: Returns a single, true date column, which is excellent for charting and further date
--      calculations. It maintains the proper date data type.
-- Con: The function name and availability can vary slightly between SQL dialects (e.g., DATE_TRUNC).
----------------------------------------------------------------------------------------------------
SELECT
    DATETRUNC(month, order_date) AS order_month_start, -- Each value is the first day of the month.
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
ORDER BY order_month_start;

----------------------------------------------------------------------------------------------------
-- Method 3: Using FORMAT() Function
-- Purpose: To aggregate by a custom-formatted date string. This method offers the most
--          flexibility in how the date is displayed.
-- Pro: Highly flexible formatting (e.g., '2024-Jul', 'July 2024').
-- Con: The output is a string (text), not a date. This can cause incorrect sorting (e.g., 'Apr'
--      comes before 'Jan' alphabetically) and makes it unsuitable for direct use in charting
--      tools that require a date data type.
----------------------------------------------------------------------------------------------------
SELECT
    FORMAT(order_date, 'yyyy-MMM') AS order_year_month, -- Formats the date as 'YYYY-Mon' (e.g., '2024-Jul').
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY FORMAT(order_date, 'yyyy-MMM')
-- IMPORTANT: Sorting by the formatted string may not be chronological.
-- It's often better to group by the formatted string but order by the actual date.
ORDER BY MIN(order_date); -- A common trick to ensure chronological sorting.