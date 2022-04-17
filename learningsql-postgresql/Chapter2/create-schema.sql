-- person schema example 
CREATE TABLE IF NOT EXISTS person 
    (
        person_id SERIAL,
        fname VARCHAR(20) NOT NULL,
        lname VARCHAR(20) NOT NULL,
        eye_color CHAR(2),  -- this add a check CONSTRAINT for the value insserted 
        street VARCHAR(30),
        city VARCHAR(20),
        state VARCHAR(20),
        country VARCHAR(20),
        postal_code VARCHAR(20),
        birth_date DATE,
        created_on TIMESTAMP NOT NULL,
        CONSTRAINT pk_person PRIMARY KEY (person_id)
    );

CREATE TABLE IF NOT EXISTS favorite_food 
    (
        person_id INTEGER,
        food VARCHAR(20) NOT NULL,
        CONSTRAINT pk_fav_food PRIMARY KEY (person_id, food),
        CONSTRAINT fk_fav_food_person_id FOREIGN KEY (person_id) REFERENCES person (person_id)
    );

-- it takes more than just the person_id column to guarantee uniqueness in the table. 
-- This table, therefore, has a two-column primary key: person_id and food.

-- this table contains another type of constraint which is called a foreign key constraint. This constrains 
-- the values of the person_id column in the favorite_food table to include only values found in the person table

-- IN MYSQL :
-- ALTER TABLE person MODIFY person_id SMALLINT UNSIGNED AUTO_INCREMENT;

