SELECT quarter(payment_date) quarter, 
    monthname(payment_date) month_nm, 
    sum(amount) monthly_sales, 
    max(sum(amount)) 
        over () max_overall_sales,
    max(sum(amount)) 
        over (partition by quarter(payment_date)) max_qrtr_sales 
FROM payment 
WHERE year(payment_date) = 2005
GROUP BY quarter(payment_date), monthname(payment_date);

-- To accommodate this type of analysis, analytic functions include the ability to group rows into windows, 
-- which effectively partition the data for use by the analytic function without changing the overall result 
-- set. Windows are defined using the over clause combined with an optional partition by subclause

-- In the previous query, both analytic functions include an over clause, but the first one is empty, indicating 
-- that the window should include the entire result set, whereas the second one specifies that the window should 
-- include only rows within the same quarter.

-- different analytic functions can define different data windows like before query.

-- Localized Sorting
-- Along with partitioning your result set into data windows you may also specify a sort order.

SELECT quarter(payment_date) quarter, 
    monthname(payment_date) month_nm, 
    sum(amount) monthly_sales, 
    rank() over (order by sum(amount) desc) sales_rank 
FROM payment
WHERE year(payment_date) = 2005
GROUP BY quarter(payment_date), monthname(payment_date) 
ORDER BY 1, month(payment_date);

-- In some cases, you will want to use both the partition by and order by subclauses in the same analytic 
-- function call. For example, the previous example can be modified to provide a different set of rankings 
-- per quarter, rather than a single ranking across the entire result set:

SELECT quarter(payment_date) quarter, 
    monthname(payment_date) month_nm, 
    sum(amount) monthly_sales, 
    rank() over (partition by quarter(payment_date)
        order by sum(amount) desc) qtr_sales_rank 
FROM payment 
WHERE year(payment_date) = 2005
GROUP BY quarter(payment_date), monthname(payment_date) 
ORDER BY 1, month(payment_date);

-- Window Frames

-- what if you need even finer control over which rows to include in a data window?
-- you can include a “frame” subclause to define exactly which rows to include in the data window. 
-- Here’s a query that sums payments for each week and includes a reporting function to calculate 
-- sthe rolling sum:

SELECT yearweek(payment_date) payment_week, 
    sum(amount) week_total, 
    sum(sum(amount)) 
        over (order by yearweek(payment_date) 
            rows unbounded preceding) rolling_sum 
FROM payment
GROUP BY yearweek(payment_date) 
ORDER BY 1;

-- The rolling_sum column expression includes the rows unbounded preceding subclause to define a 
-- data window from the beginning of the result set up to and including the current row

-- Here’s a query that calculates a three-week rolling average of total payments:

SELECT yearweek(payment_date) payment_week, 
    sum(amount) week_total, 
    avg(sum(amount)) 
        over (order by yearweek(payment_date) 
            rows between 1 preceding and 1 following) rolling_3wk_avg 
FROM payment
GROUP BY yearweek(payment_date) 
ORDER BY 1;

-- The rolling_3wk_avg column defines a data window consisting of the current row, the prior row, and the next row.

-- In the previous result set, there is data for weeks 200521, 200522, and 200524, but no data for week 200523. 
-- If you want to specify a date interval rather than a number of rows, you can specify a range for your data 
-- window, as shown in the following query:

SELECT date(payment_date), sum(amount), 
    avg(sum(amount)) over (order by date(payment_date) 
        range between interval 3 day preceding 
            and interval 3 day following) 7_day_avg
FROM payment
WHERE payment_date BETWEEN '2005-07-01' AND '2005-09-01' 
GROUP BY date(payment_date) 
ORDER BY 1;


-- The 7_day_avg column specifies a range of +/-3 days and will include only those rows whose payment_date 
-- values fall within that range. For the 2005-08-16 calculation, for example, only the values for 08-16, 
-- 08-17, 08-18, and 08-19 are included, since there are no rows for the three prior dates (08-13 through 08-15)