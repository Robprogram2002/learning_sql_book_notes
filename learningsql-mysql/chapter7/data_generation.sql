-- exemple: scape single quotes in a string literal (you must use two single quotes together)
UPDATE string_tbl 
    SET text_fld = 'This string didn''t work, but it does now';

-- if you are retrieving the string to add to a file that another program will read, you may 
-- want to include the escape as part of the retrieved string
-- you can use the built-in function quote()
SELECT quote(text_fld) FROM string_tbl;


-- STRING MANIPULATION --------------------------------

-- length() returns the number of characters in the string

SELECT first_name AS fname, length(first_name) AS fname_length 
FROM actor
WHERE length(first_name) < 5;

-- strings stored in char columns are right-padded with spaces. 
-- The MySQL server removes trailing spaces from char data when 
-- it is retrieved, however, so you will see the same results 
-- from all string functions regardless of the type of column 
-- in which the strings are stored.


-- POSITION: find the location of a substring within a string.
-- If the substring cannot be found, the position() function returns 0.

SELECT concat(first_name,' ',last_name) AS name, 
    POSITION('L' IN first_name) AS L_position 
FROM actor
WHERE POSITION('L' IN first_name) > 0;


-- locate() function  allows an optional third parameter, which is used to 
-- define the search’s start position

SELECT first_name, last_name, 
    LOCATE('L',first_name, 3) AS L_position 
FROM actor
WHERE LOCATE('L',first_name, 3) > 0;

-- Along with the strcmp() function, MySQL also allows you to use the like 
-- and regexp operators to compare strings in the select clause. Such comparisons 
-- will yield 1 (for true) or 0 (for false). Therefore, these operators allow you 
-- to build expressions that return a number

SELECT first_name, 
    first_name LIKE '%E' ends_in_e 
FROM actor;


-- CONCAT() function

-- The concat() function can handle any expression that returns a string and will 
-- even convert numbers and dates to string format, as evidenced by the date column 
-- (cre ate_date) used as an argument.
SELECT concat(first_name, ' ', last_name, 
    ' has been a customer since ', date(create_date)) cust_narrative 
FROM customer;

-- MySQL includes the insert() function, which takes four arguments: the original string, 
-- the position at which to start, the number of characters to replace, and the replacement 
-- string. Depending on the value of the third argument, the function may be used to either 
-- insert or replace characters in a string

SELECT INSERT('goodbye world', 9, 0, 'cruel ') string;

-- With a value of 0 for the third argument, the replacement string is inserted, and any 
-- trailing characters are pushed to the right


-- substring() extract a substring from a string
SELECT SUBSTRING('goodbye cruel world', 9, 5);


-- Four functions are useful when limiting the precision of floating-point numbers: 
-- ceil(), floor(), round(), and trun cate()

SELECT ROUND(72.0909, 1), ROUND(72.0909, 2), ROUND(72.0909, 3);



