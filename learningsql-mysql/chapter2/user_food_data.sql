INSERT INTO person (birth_date, city, country, eye_color, fname, lname, postal_code, state, street) 
    VALUES ('1990-10-24', 'New York', 'United States', 'BR', 'John', 'Hanks', '20311312', 'California', 'Wesconsing 23th');

INSERT INTO person (birth_date, city, country, eye_color, fname, lname, postal_code, state, street) 
    VALUES ('1987-02-12', 'Austin', 'United States', 'GR', 'Tom', 'Billy', '20311312', 'Texas', 'Invictus path 22th');

INSERT INTO person (birth_date, city, country, eye_color, fname, lname, postal_code, state, street) 
    VALUES ('2002-10-30', 'Monterrey', 'Mexico', 'BL', 'Henry', 'Martinez', '20311312', 'Nuevo Leon', 'Welcome avenude');

UPDATE person 
    SET street = 'Avenida Bienvenidos', postal_code = '65290', state = 'Nuevo León' 
    WHERE person_id = 3;

UPDATE person 
    SET birth_date = str_to_date('DEC-21-1987' , '%b-%d-%Y')
    WHERE person_id = 2;

INSERT INTO food (name) VALUES ('Pizza');
INSERT INTO food (name) VALUES ('Pasta');
INSERT INTO food (name) VALUES ('Taco');
INSERT INTO food (name) VALUES ('Chicken');
INSERT INTO food (name) VALUES ('Beef');
INSERT INTO food (name) VALUES ('Potato');
INSERT INTO food (name) VALUES ('Bread');


INSERT INTO person_food (person_id, food_id) VALUES (3, 1);
INSERT INTO person_food (person_id, food_id) VALUES (3, 3);
INSERT INTO person_food (person_id, food_id) VALUES (3, 5);