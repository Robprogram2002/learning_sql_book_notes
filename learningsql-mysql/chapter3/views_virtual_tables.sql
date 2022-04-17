-- A view is a query that is stored in the data dictionary. It looks and acts like a table, 
-- but there is no data associated with a view

-- When you issue a query against a view, your query is merged with the view definition 
-- to create a final query to be executed.

CREATE VIEW cust_vw AS 
    SELECT customer_id, first_name, last_name, active
    FROM customer;

-- When the view is created, no additional data is generated or stored: the server simply 
-- tucks away the select statement for future use

SELECT first_name , last_name 
FROM cust_vw 
WHERE active = 0;


-- Views are created for various reasons, including to hide columns from users and to simplify 
-- complex database designs