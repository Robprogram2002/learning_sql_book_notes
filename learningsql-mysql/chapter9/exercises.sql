-- Construct a query against the film table that uses a filter condition with a noncorrelated 
-- subquery against the category table to find all action films

SELECT film_id, title FROM film 
WHERE film_id IN 
    (SELECT fc.film_id
     FROM film_category fc 
        INNER JOIN category c USING (category_id)
     WHERE c.name = 'Action');

-- Rework the query from Exercise 9-1 using a correlated subquery against the category and 
-- film_category tables to achieve the same results.

SELECT f.title FROM film f 
WHERE EXISTS 
   (SELECT 1 FROM category c 
      INNER JOIN film_category fc 
      ON c.category_id = fc.category_id 
    WHERE c.name = 'Action' 
      AND f.film_id = fc.film_id);

-- Join the following query to a subquery against the film_actor table to show the level of each actor:
SELECT 'Hollywood Star' level, 30 min_roles, 99999 max_roles 
UNION ALL
SELECT 'Prolific Actor' level, 20 min_roles, 29 max_roles 
UNION ALL
SELECT 'Newcomer' level, 1 min_roles, 19 max_roles;

SELECT films.actor_id, a.first_name, a.last_name, 
   films.n_roles, grs.level 
FROM 
   (SELECT count(*) n_roles, actor_id 
    FROM film_actor 
    GROUP BY actor_id
   ) films 
   INNER JOIN 
   (SELECT 'Hollywood Star' level, 30 min_roles, 99999 max_roles 
    UNION ALL
    SELECT 'Prolific Actor' level, 20 min_roles, 29 max_roles 
    UNION ALL
    SELECT 'Newcomer' level, 1 min_roles, 19 max_roles
   ) grs
   ON films.n_roles BETWEEN grs.min_roles 
      AND grs.max_roles
   INNER JOIN actor a 
   ON films.actor_id = a.actor_id;
