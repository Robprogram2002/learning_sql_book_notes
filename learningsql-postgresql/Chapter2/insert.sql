INSERT INTO person (fname, lname, eye_color, birth_date, created_on)
    VALUES ('Willian', 'Turner', 'BR', '1972-05-27', now());

-- NOTE: The value provided for the birth_date column was a string. As long as you match the required format
-- MySQL will convert the string to a date for you.

-- The column names and the values provided must correspond in number and type. 

INSERT INTO favorite_food (person_id, food)
    VALUES (2, 'pizza');

INSERT INTO favorite_food (person_id, food)
    VALUES (2, 'cookies');

INSERT INTO favorite_food (person_id, food)
    VALUES (2, 'pasta');

INSERT INTO favorite_food (person_id, food)
    VALUES (2, 'nachos');