CREATE TABLE IF NOT EXISTS person (
    person_id INTEGER UNSIGNED AUTO_INCREMENT,
    fname VARCHAR(100) NOT NULL,
    lname VARCHAR(100) NOT NULL,
    eye_color CHAR(2) NOT NULL, # possible values are : BL, BR, GR, 
    birth_date DATE NOT NULL,
    street VARCHAR(50) NOT NULL,
    city VARCHAR(20) NOT NULL,
    state VARCHAR(20) NOT NULL,
    country VARCHAR(20) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    CONSTRAINT pk_person PRIMARY KEY (person_id)
);

CREATE TABLE IF NOT EXISTS food (
    food_id INTEGER UNSIGNED AUTO_INCREMENT,
    name VARCHAR(200),
    CONSTRAINT pk_food PRIMARY KEY (food_id)
);

CREATE TABLE IF NOT EXISTS person_food (
    person_id INTEGER UNSIGNED,
    food_id INTEGER UNSIGNED,
    CONSTRAINT pk_person_food PRIMARY KEY (person_id, food_id),
    CONSTRAINT fk_person_food_persond_id FOREIGN KEY (person_id) REFERENCES person (person_id),
    CONSTRAINT fk_person_food_food_id FOREIGN KEY (food_id) REFERENCES food (food_id)
);

ALTER TABLE person CHANGE eye_color eye_color ENUM('BR','BL','GR');

ALTER TABLE food MODIFY name VARCHAR(200) NOT NULL;