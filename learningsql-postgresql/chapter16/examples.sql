SELECT quarter(payment_date) quarter, 
        monthname(payment_date) month_nm, 
        sum(amount) monthly_sales,
        max(sum(amount)) ->
            over () max_overall_sales,
        max(sum(amount)) 
            over (partition by quarter(payment_date)) max_qrtr_sales 
FROM payment 
WHERE year(payment_date) = 2005
GROUP BY quarter(payment_date), monthname(payment_date);


-- How each rank function handle ties ?
-- analyze the result set to see the answer
SELECT customer_id, count(*) num_rentals, 
        row_number() over (order by count(*) desc) row_number_rnk, 
        rank() over (order by count(*) desc) rank_rnk, 
        dense_rank() over (order by count(*) desc) dense_rank_rnk 
FROM rental
GROUP BY customer_id 
ORDER BY 2 desc;

-- The third column uses the row_number function to assign a unique ranking to each row, without regard to ties with 
-- the ranking value arbitrarily assigned for customers who have the same number of film rentals. The next two columns, 
-- however, assign the same ranking in case of a tie, but the difference lies in whether or not a gap is left in the 
-- ranking values after a tie. 

-- Generating multiple ranks for the same column

SELECT customer_id, rental_month, num_rentals, rank_rnk ranking
FROM
    (SELECT customer_id, 
            monthname(rental_date) rental_month, 
            count(*) num_rentals, 
            rank() over (partition by monthname(rental_date)
                order by count(*) desc) rank_rnk 
    FROM rental
    GROUP BY customer_id, monthname(rental_date) 
    ) cust_rankings
WHERE rank_rnk <= 5
ORDER BY rental_month, num_rentals desc, rank_rnk;

-- Example of an aggregation funnction with window data

SELECT monthname(payment_date) payment_month, 
       sum(amount) month_total, 
       round(sum(amount) / sum(sum(amount)) over ()
         * 100, 2) pct_of_total 
FROM payment
GROUP BY monthname(payment_date);

-- This query calculates the total payments for each month by summing the amount column, and then calculates the 
-- percentage of the total payments for each month by summing the monthly sums to use as the denominator in the 
-- calculation


-- Reporting functions may also be used for comparisons, such as the next query, which uses a case expression to 
-- determine whether a monthly total is the max, min, or somewhere in the middle:

SELECT  monthname(payment_date) payment_month, 
        sum(amount) month_total, 
        CASE sum(amount) 
            WHEN max(sum(amount)) over () THEN 'Highest'
            WHEN min(sum(amount)) over () THEN 'Lowest' ELSE 'Middle'
        END descriptor 
FROM payment
GROUP BY monthname(payment_date);

-- The descriptor column acts as a quasi-ranking function

-- Example of a window frame

SELECT  yearweek(payment_date) payment_week, 
        sum(amount) week_total,  
        sum(sum(amount)) 
            over (order by yearweek(payment_date) 
                rows unbounded preceding) rolling_sum 
FROM payment
GROUP BY yearweek(payment_date) 
ORDER BY 1;


-- changing sum by avg
-- a query that calculates a three-week rolling average of total payments:
SELECT  yearweek(payment_date) payment_week, 
        sum(amount) week_total, 
        avg(sum(amount)) 
            over (order by yearweek(payment_date) 
                rows between 1 preceding and 1 following) rolling_3wk_avg 
FROM payment
GROUP BY yearweek(payment_date) 
ORDER BY 1;

-- using between range instead of number of rows

SELECT  date(payment_date), sum(amount), 
        avg(sum(amount)) over (order by date(payment_date) 
            range between interval 3 day preceding 
                and interval 3 day following) 7_day_avg
FROM payment
WHERE payment_date BETWEEN '2005-07-01' AND '2005-09-01' 
GROUP BY date(payment_date) 
ORDER BY 1;

--  Lag and Lead analytic function example 

SELECT  yearweek(payment_date) payment_week, 
        sum(amount) week_total, 
        lag(sum(amount), 1) 
            over (order by yearweek(payment_date)) prev_wk_tot,
        lead(sum(amount), 1) 
            over (order by yearweek(payment_date)) next_wk_tot 
FROM payment
GROUP BY yearweek(payment_date) 
ORDER BY 1;

-- how you could use the lag function to generate the percentage difference from the prior week:

SELECT  yearweek(payment_date) payment_week, 
        sum(amount) week_total, 
        round((sum(amount) - lag(sum(amount), 1) 
            over (order by yearweek(payment_date)))
            / lag(sum(amount), 1)
                over (order by yearweek(payment_date)) * 100, 1) pct_diff
FROM payment
GROUP BY yearweek(payment_date) 
ORDER BY 1;

-- group_concat function example

SELECT  f.title, 
        group_concat(a.last_name order by a.last_name 
            separator ', ') actors
FROM actor a 
    INNER JOIN film_actor fa 
    ON a.actor_id = fa.actor_id 
    INNER JOIN film f 
    ON fa.film_id = f.film_id 
GROUP BY f.title 
HAVING count(*) = 3;

