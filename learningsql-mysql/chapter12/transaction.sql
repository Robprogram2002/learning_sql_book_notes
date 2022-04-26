-- application logic will frequently include multiple SQL statements that need to execute together 
-- as a logical unit of work. Transactions are the mechanism used to 
-- group a set of SQL statements together such that either all or none of the statements succeed 
-- (a property known as atomicity).

-- the program that handles your transfer request would first begin a transaction, then issue 
-- the SQL statements needed to move the money from your savings to your checking account, and, 
-- if everything succeeds, end the transaction by issuing the commit command. If something unexpected 
-- happens, however, the program would issue a rollback command, which instructs the server to undo 
-- all changes made since the transaction began

-- until you explicitly begin a transaction, you are in what is known as autocommit mode, which means 
-- that individual statements are automatically committed by the server. You can, therefore, decide 
-- that you want to be in a transaction and issue a start/begin transaction command, or you can simply 
-- let the server commit individual statements.

-- MySQL allows you to disable autocommit mode via the following:

SET AUTOCOMMIT=0

-- Once you have left autocommit mode, all SQL commands take place within the scope of a transaction 
-- and must be explicitly committed or rolled back.

-- A word of advice: shut off autocommit mode each time you log in, and get in the habit of running 
-- all of your SQL statements within a transaction.

-- Once a transaction has begun, whether explicitly via the start transaction command or implicitly 
-- by the database server, you must explicitly end your transaction for your changes to become permanent

START TRANSACTION; 

UPDATE product
SET date_retired = CURRENT_TIMESTAMP() 
WHERE product_cd = 'XYZ';

SAVEPOINT before_close_accounts; 

UPDATE account
SET status = 'CLOSED', close_date = CURRENT_TIMESTAMP(), 
    last_activity_date = CURRENT_TIMESTAMP() 
WHERE product_cd = 'XYZ';

ROLLBACK TO SAVEPOINT before_close_accounts; 
COMMIT;

-- Despite the name, nothing is saved when you create a savepoint. You must eventually issue a commit if 
-- you want your transaction to be made permanent.

