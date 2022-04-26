-- Exercise 1
CREATE VIEW film_ctgry_actor AS
SELECT f.title, c.name category_name, a.first_name, a.last_name 
FROM film f
    INNER JOIN film_category fc ON f.film_id = fc.film_id
    INNER JOIN category c ON fc.category_id = c.category_id
    INNER JOIN film_actor fa ON fa.film_id = f.film_id
    INNER JOIN actor a ON fa.actor_id = a.actor_id;

SELECT title, category_name, first_name, last_name 
FROM film_ctgry_actor 
WHERE last_name = 'FAWCETT';

-- The film rental company manager would like to have a report that includes the name of every country, 
-- along with the total payments for all customers who live in each country. Generate a view definition 
-- that queries the country table and uses a scalar subquery to calculate a value for a column named 
-- tot_payments.

CREATE VIEW tot_payments_country AS 
SELECT c.country, 
    (SELECT SUM(p.amount)  
     FROM payment p 
        INNER JOIN customer ctm ON ctm.customer_id = p.customer_id
        INNER JOIN address adr ON adr.address_id = ctm.address_id
        INNER JOIN city ct ON ct.city_id = adr.city_id
     WHERE ct.country_id = c.country_id) tot_payments 
FROM country c;

SELECT country, tot_payments 
FROM tot_payments_country 
ORDER BY tot_payments DESC;
