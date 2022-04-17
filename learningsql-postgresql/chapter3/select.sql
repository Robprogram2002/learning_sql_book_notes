
SELECT c.first_name, c.last_name, count(*)
FROM customer AS c
    INNER JOIN rental AS r 
    ON c.customer_id = r.customer_id
GROUP BY c.first_name, c.last_name
HAVING count(*) >= 40
ORDER BY c.first_name, c.last_name;  
-- ORDER BY 1, 2;  You can use numeri placeholder to order by

-- Example : Order by and Desc keyword

-- SELECT c.first_name, c.last_name, time(r.rental_date) AS rental_time
-- FROM customer AS c
--     INNER JOIN rental AS r
--     ON c.customer_id = r.customer_id
-- WHERE date(r.rental_date) = '2005-06-14'
-- ORDER BY time(r.rental_date) desc;