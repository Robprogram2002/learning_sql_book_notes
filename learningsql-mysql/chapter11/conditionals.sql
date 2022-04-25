-- how to write statements that can behave differently depending on the data encountered during statement execution
-- Conditional logic is the ability to take one of several paths during program execution. 

-- • The case expression is part of the SQL standard (SQL92 release) and has been implemented 
-- by Oracle Database, SQL Server, MySQL, PostgreSQL, IBM UDB, and others.
-- • case expressions are built into the SQL grammar and can be included in select, insert, 
-- update, and delete statements.

-- Searched case Expressions

SELECT first_name, last_name, 
    CASE 
        WHEN active = 1 THEN 'ACTIVE' 
        ELSE 'INACTIVE'
    END activity_type 
FROM customer;

-- If the condition in a when clause evaluates to true, then the case expression returns the corresponding expression. 
-- Additionally, the else clause represents the default expression, which the case expression returns if none of 
-- the before conditions evaluate to true (the else clause is optional).
-- All the expressions returned by the various when clauses must evaluate to the same type

CASE
    WHEN category.name IN ('Children','Family','Sports','Animation') 
        THEN 'All Ages'
    WHEN category.name = 'Horror' 
        THEN 'Adult'
    WHEN category.name IN ('Music','Games') 
        THEN 'Teens' 
    ELSE 'Other'
END;

-- This case expression returns a string that can be used to classify films depending on their category. 
-- When the case expression is evaluated, the when clauses are evaluated in order from top to bottom; 
-- as soon as one of the conditions in a when clause evaluates to true, the corresponding expression is 
-- returned, and any remaining when clauses are ignored. If none of the when clause conditions evaluates 
-- to true, then the expression in the else clause is returned.


-- keep in mind that case expressions may return any type of expression, including subqueries

SELECT c.first_name, c.last_name, 
    CASE 
        WHEN active = 0 THEN 0
        ELSE 
         (SELECT count(*) FROM rental r 
          WHERE r.customer_id = c.customer_id)
    END num_rentals 
FROM customer c;

-- Depending on the percentage of active customers, using this approach may be more efficient 
-- than joining the customer and rental tables and grouping on the customer_id column.

-- Simple case Expressions

-- CASE V0
--     WHEN V1 THEN E1 
--     WHEN V2 THEN E2 
--     ...
--     WHEN VN THEN EN [ELSE ED]
-- END

-- In the preceding definition, V0 represents a value, and the symbols V1, V2, ..., VN represent 
-- values that are to be compared to V0. The symbols E1, E2, ..., EN represent expressions to be 
-- returned by the case expression, and ED represents the expression to be returned if none of the 
-- values in the set V1, V2, ..., VN matches the V0 value

CASE category.name
    WHEN 'Children' THEN 'All Ages' 
    WHEN 'Family' THEN 'All Ages' 
    WHEN 'Sports' THEN 'All Ages' 
    WHEN 'Animation' THEN 'All Ages' 
    WHEN 'Horror' THEN 'Adult' 
    WHEN 'Music' THEN 'Teens' 
    WHEN 'Games' THEN 'Teens'
    ELSE 'Other' 
END;

-- Simple case expressions are less flexible than searched case expressions because you can’t specify your 
-- own conditions, whereas searched case expressions may include range conditions, inequality conditions, 
-- and multipart conditions using and/or/not







