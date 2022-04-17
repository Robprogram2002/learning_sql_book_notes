-- Person table querys
SELECT * FROM person;

SELECT fname, lname, eye_color, birth_date, city, state, country from person;

SELECT * FROM person WHERE country = 'United States' ORDER BY lname;

SELECT * FROM person ORDER BY birth_date LIMIT 1;

SELECT * FROM person ORDER BY birth_date DESC LIMIT 1;

-- Food table querys

SELECT * FROM food;

SELECT name FROM food ORDER BY name;

-- person-food table (inner joins)

SELECT * FROM person_food;


