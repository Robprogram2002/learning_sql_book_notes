-- Ranking

-- identify the top 10 customers so they can be offered a free film rental. 

SELECT customer_id, count(*) num_rentals, 
    row_number() over (order by count(*) desc) row_number_rnk, 
    rank() over (order by count(*) desc) rank_rnk, 
    dense_rank() over (order by count(*) desc) dense_rank_rnk 
FROM rental
GROUP BY customer_id 
ORDER BY 2 desc;

-- To extend the prior example, let’s say the marketing department decides to offer free film rentals 
-- to the top five customers every month. To generate the data, the rental_month column can be added to 
-- the previous query:

SELECT customer_id, 
    monthname(rental_date) rental_month, 
    count(*) num_rentals, 
    rank() over (partition by monthname(rental_date) 
        order by count(*) desc) rank_rnk 
FROM rental
GROUP BY customer_id, monthname(rental_date)
ORDER BY 2, 3 desc;

-- In order to generate the desired results for the marketing department (top five customers from each month), 
-- you can simply wrap the previous query in a subquery and add a filter condition to exclude any rows with a 
-- ranking higher than five:

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

-- Since analytic functions can be used only in the SELECT clause, you will often need to nest queries if you 
-- need to do any filtering or grouping based on the results from the analytic function.


-- Reporting Functions

-- Here’s an example that generates monthly and grand totals for all payments of $10 or higher:

SELECT monthname(payment_date) payment_month, 
    amount, 
    sum(amount) 
        over (partition by monthname(payment_date)) monthly_total,
    sum(amount) over () grand_total 
FROM payment 
WHERE amount >= 10 
ORDER BY 1;

-- these types of columns can also be used for calculations, as shown in the following query:

SELECT monthname(payment_date) payment_month, 
    sum(amount) month_total, 
    round(sum(amount) / sum(sum(amount)) over () * 100, 2) pct_of_total 
FROM payment
GROUP BY monthname(payment_date);

-- Reporting functions may also be used for comparisons, 

SELECT monthname(payment_date) payment_month, 
    sum(amount) month_total, 
    CASE sum(amount) 
        WHEN max(sum(amount)) over () THEN 'Highest'
        WHEN min(sum(amount)) over () THEN 'Lowest' 
        ELSE 'Middle'
    END descriptor 
FROM payment
GROUP BY monthname(payment_date);

-- Lag and Lead

-- if you are generating monthly sales totals, you may be asked to create a column showing the percentage 
-- difference from the prior month, which will require a way to retrieve the monthly sales total from the 
-- previous row. This can be accomplished using the lag function, which will retrieve a column value from 
-- a prior row in the result set, or the lead function, which will retrieve a column value from a following 
-- row. Here’s an example using both functions:

SELECT yearweek(payment_date) payment_week, 
    sum(amount) week_total, 
    lag(sum(amount), 1) 
        over (order by yearweek(payment_date)) prev_wk_tot,
    lead(sum(amount), 1) 
        over (order by yearweek(payment_date)) next_wk_tot 
FROM payment
GROUP BY yearweek(payment_date) 
ORDER BY 1;

-- Both lag and lead allow for an optional second parameter (which defaults to 1) to describe the number 
-- of rows prior/following from which to retrieve the column value.

-- Here’s how you could use the lag function to generate the percentage difference from the prior week:

SELECT yearweek(payment_date) payment_week, 
    sum(amount) week_total, 
    round((sum(amount) - lag(sum(amount), 1) 
        over (order by yearweek(payment_date))) / 
        lag(sum(amount), 1) over (order by yearweek(payment_date)) * 100, 
        1) pct_diff
FROM payment
GROUP BY yearweek(payment_date) 
ORDER BY 1;


-- Column Value Concatenation

-- The group_concat function is used to pivot a set of column values into a single 
-- delimited string, which is a handy way to denormalize your result set

-- Here’s an example of how this function could be used to generate a comma-delimited 
-- list of actors for each film:

SELECT f.title, 
    group_concat(a.last_name order by a.last_name 
        separator ', ') actors
FROM actor a 
    INNER JOIN film_actor fa 
    ON a.actor_id = fa.actor_id 
    INNER JOIN film f 
    ON fa.film_id = f.film_id 
GROUP BY f.title 
HAVING count(*) = 3;

-- The group_concat function acts like a special type of aggregate function that pivots all of 
-- the last names of all actors appearing in each film into a single string.

