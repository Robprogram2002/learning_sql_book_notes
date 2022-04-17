-- retrieve the customer name, the total amount that has payed and the number of payments

-- without customer info
SELECT customer_id, count(*) AS payments, SUM(amount) as total_pay
FROM payment 
GROUP BY customer_id
HAVING count(*) >= 40;

-- with customer info
SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS name , c.email, j.payments , j.total_pay
FROM customer AS c
    INNER JOIN (
        SELECT customer_id, count(*) AS payments, SUM(amount) as total_pay
        FROM payment 
        GROUP BY customer_id
        HAVING count(*) >= 40
    ) as j
    ON j.customer_id = c.customer_id
ORDER BY total_pay DESC;