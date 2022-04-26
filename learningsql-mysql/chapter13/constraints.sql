-- A constraint is simply a restriction placed on one or more columns of a table.

-- Primary key constraints 
-- Identify the column or columns that guarantee uniqueness within a table

-- Foreign key constraints
-- Restrict one or more columns to contain only values found in another table’s primary key columns 

-- Unique constraints
-- Restrict one or more columns to contain unique values within a table

-- Check constraints 
-- Restrict the allowable values for a column

CREATE TABLE customer (
    customer_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT, 
    store_id TINYINT UNSIGNED NOT NULL, 
    first_name VARCHAR(45) NOT NULL, 
    last_name VARCHAR(45) NOT NULL, 
    email VARCHAR(50) DEFAULT NULL, 
    address_id SMALLINT UNSIGNED NOT NULL, 
    active BOOLEAN NOT NULL DEFAULT TRUE, 
    create_date DATETIME NOT NULL,
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP 
        ON UPDATE CURRENT_TIMESTAMP, 
    PRIMARY KEY (customer_id), 
    KEY idx_fk_store_id (store_id), 
    KEY idx_fk_address_id (address_id), 
    KEY idx_last_name (last_name), 
    CONSTRAINT fk_customer_address FOREIGN KEY (address_id) REFERENCES address (address_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE, 
    CONSTRAINT fk_customer_store FOREIGN KEY (store_id) REFERENCES store (store_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE 
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Hpw to add a constraint after table creation:

ALTER TABLE customer
ADD CONSTRAINT fk_customer_address FOREIGN KEY (address_id) 
REFERENCES address (address_id) ON DELETE RESTRICT ON UPDATE CASCADE;

-- • on delete restrict, will cause the server to raise an error if a row is deleted in the parent table 
-- (address or store) that is referenced in the child table (customer)

-- • on update cascade, will cause the server to propagate a change to the primary key value of a 
-- parent table (address or store) to the child table (customer)

-- there are six different options to choose from when defining foreign key constraints:

-- • on delete restrict 
-- • on update cascade 
-- • on delete set null 
-- • on update restrict 
-- • on update cascade

-- These are optional, so you can choose zero, one, or two (one on delete and one on update)

