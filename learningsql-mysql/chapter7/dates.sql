-- str_to_date() allows you to provide a format string along with the date string.

UPDATE rental 
    SET return_date = STR_TO_DATE('September 17, 2019', '%M %d, %Y') 
WHERE rental_id = 99999;

-- The str_to_date() function returns a datetime, date, or time value depending on 
-- the contents of the format string

SELECT CURRENT_DATE(), CURRENT_TIME(), CURRENT_TIMESTAMP();

-- MySQL’s date_add() function allows you to add any kind of interval (e.g., days,
-- months, years) to a specified date to generate another date.

SELECT DATE_ADD(CURRENT_DATE(), INTERVAL 5 DAY);

-- The second argument is composed of three elements: the interval keyword, the desired 
-- quantity, and the type of interval (second, minute, hour, day, month, year, minute_second (:),
-- hour_second, year_month).

UPDATE rental
    SET return_date = DATE_ADD(return_date, INTERVAL '3:27:11' HOUR_SECOND) 
WHERE rental_id = 99999;


-- you could find the last day of September via the following:
SELECT LAST_DAY('2019-09-17');


-- dayname() determine which day of the week a certain date falls on
SELECT DAYNAME('2019-09-18');


-- The extract() function uses the same interval types as the date_add() function allows
-- to define which element of the date interests you. For example, if you want to extract 
-- just the year portion of a datetime value, you can do the following:
SELECT EXTRACT(YEAR FROM '2019-09-18 22:19:05');

-- datediff() returns the number of full days between two dates (it ignores the time of day 
-- in its arguments.).
SELECT DATEDIFF('2019-09-03', '2019-06-21');

-- Conversion Functions --------------------------------

-- To use cast(), you provide a value or expression, the as keyword, and the type to which 
-- you want the value converted. Here’s an example that converts a string to an integer:

SELECT CAST('1456328' AS SIGNED INTEGER);
SELECT CAST('2019-09-17 15:30:00' AS DATETIME);
SELECT CAST('2019-09-17' AS DATE) date_field, 
    CAST('108:17:57' AS TIME) time_field;
    