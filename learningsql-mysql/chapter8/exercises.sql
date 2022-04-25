-- count the number of payments made by each customer. Show the customer ID and the 
-- total amount paid for each customer

SELECT customer_id, count(*) payments, sum(amount) total_amount
FROM payment
GROUP BY customer_id
ORDER BY 3 DESC;

-- get top customers
SELECT customer_id, count(*) payments, sum(amount) total_amount
FROM payment
GROUP BY customer_id
HAVING count(*) >= 40
ORDER BY 2 DESC;


SELECT customer_id, count(*) payments, sum(amount) total_amount
FROM payment
GROUP BY customer_id
ORDER BY 3 DESC
LIMIT 10;