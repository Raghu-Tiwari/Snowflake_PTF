
-- 15.0.0  Snowflake Stored Procedures and Snowflake Scripting
--         The purpose of this lab is to familiarize you with stored procedures
--         in Snowflake as well as with Snowflake Scripting.
--         Snowflake Scripting is an extension to Snowflake SQL that adds
--         support for procedural logic, and you can use it to write stored
--         procedures. You can even use it to write procedural code outside of a
--         stored procedure. In this case, we’ll use it only inside a stored
--         procedure.
--         Snowflake Scripting also allows you to use IF-THEN and CASE
--         statements. You can even loop through cursors and RESULTSETS,
--         evaluate the data in each row, and perform some action based on that
--         evaluation.
--         In Part I of this lab, you’ll create stored procedures to move data
--         from one table to another. You’ll get a chance to apply both IF-THEN
--         statements and CASE statements, and you’ll have an opportunity to
--         work with a cursor.
--         In Part II of this lab, you’ll create two functionally identical
--         stored procedures: one with Snowflake Scripting and the other with
--         JavaScript. This will give you an opportunity to see the similarities
--         and differences between these two types of stored procedures.
--         - Write and call stored procedures.
--         - Use Snowflake Scripting to add procedural logic to a stored
--         procedure.
--         - Write an IF-THEN statement and a CASE statement.
--         - Open a cursor and iterate through rows.
--         - Apply a concatenation operator to join two or more strings.
--         - Write a stored procedure in JavaScript.
--         This lab should take you approximately 25 minutes to complete.
--         HOW TO COMPLETE THIS LAB
--         Since the workbook PDF has useful diagrams and illustrations (not
--         present in the .SQL files), we recommend that you read the
--         instructions from the workbook PDF. In order to execute the code
--         presented in each step, use the SQL code file provided for this lab.
--         OPENING THE SQL FILE
--         To load the SQL file, in the left navigation bar select Projects,
--         then select Worksheets. From the Worksheets page, in the upper-right
--         corner, click the ellipsis (…) to the left of the blue plus (+)
--         button. Select Create Worksheet from SQL File from the drop-down
--         menu. Navigate to the SQL file for this lab and load it.
--         Let’s get started!

-- 15.1.0  Part I - Move Data from One Table to Another Using a Stored Procedure
--         You’ve been asked to write a stored procedure that will move data
--         from a staging table to a permanent one. The NATION table that is
--         used in various queries is sometimes supplemented with new rows, so
--         your stored procedure needs to take the rows from the staging table
--         and insert them into the NATION table.
--         This might be triggered by a task or in some other programmatic way.
--         In this exercise, we will focus solely on the stored procedures and
--         Snowflake Scripting.

-- 15.1.1  Set the context.
--         We’re going to create a new schema to separate the work we do here
--         from anything else we’ve done previously.

USE ROLE TRAINING_ROLE;

CREATE WAREHOUSE IF NOT EXISTS LEARNER_WH;
USE WAREHOUSE LEARNER_WH;

CREATE DATABASE IF NOT EXISTS LEARNER_DB;
USE DATABASE LEARNER_DB;

CREATE SCHEMA IF NOT EXISTS LEARNER_DB.STORED_PROCS;
USE SCHEMA LEARNER_DB.STORED_PROCS;


-- 15.1.2  Create stored procedures that will set up the data you need for this
--         exercise.
--         We will have two primary tables in this exercise: NATION and
--         NATIONS_NEW. NATION will be our standard production table, while
--         NATIONS_NEW will be a staging table where rows listing new nations to
--         be added to the NATIONS table will be staged.
--         We’re going to use stored procedures to set up our tables for two
--         reasons. First, we will need to recreate the tables multiple times
--         throughout this exercise, so it’s easier to do that by calling a
--         single stored procedure. Second, since this lab exercise is about
--         stored procedures, it gives us a chance to see more stored procedures
--         in action!
--         Execute the statement below.

CREATE OR REPLACE PROCEDURE CREATE_NATION_TABLE()
RETURNS VARCHAR NOT NULL
LANGUAGE SQL
AS
BEGIN
    CREATE OR REPLACE TABLE NATION AS SELECT 
        N.N_NATIONKEY AS NATIONKEY, 
        N.N_NAME NATION, 
        R.R_NAME REGION
    FROM 
        SNOWBEARAIR_DB.PROMO_CATALOG_SALES.NATION N 
        INNER JOIN SNOWBEARAIR_DB.PROMO_CATALOG_SALES.REGION R ON N.N_REGIONKEY = R.R_REGIONKEY;
        
    RETURN 'Creation of table NATION complete.';
END;

--         As you can see from the statement above, the stored procedure creates
--         a table called NATION. It will be structurally similar to the NATION
--         table in the Snowbear Air database, except that the third column will
--         be a region name instead of a numeric region key. This new table will
--         be our production table.
--         Other things to note:
--         The stored procedure declares a return value of VARCHAR.
--         The language has been designated as SQL (rather than JavaScript).
--         There is a BEGIN-END block containing statements to be executed one
--         by one until they are all completed.
--         We return a message to the user that the creation of the table is
--         complete.

-- 15.1.3  Call the stored procedure to create the NATION table and verify it
--         contains 25 rows.

CALL CREATE_NATION_TABLE();

SELECT * FROM NATION ORDER BY REGION, NATION;


-- 15.1.4  Create a stored procedure to create the NATIONS_NEW table.
--         This stored procedure will create the staging table and add five rows
--         of staged data. Run the statement now.

CREATE OR REPLACE PROCEDURE CREATE_NATIONS_NEW_TABLE()
RETURNS VARCHAR NOT NULL
LANGUAGE SQL
AS
BEGIN
    CREATE OR REPLACE TABLE NATIONS_NEW LIKE NATION;

    INSERT INTO NATIONS_NEW (NATIONKEY, NATION, REGION) VALUES (25, 'MEXICO', 'AMERICA');
    INSERT INTO NATIONS_NEW (NATIONKEY, NATION, REGION) VALUES (26, 'GHANA', 'AFRICA');
    INSERT INTO NATIONS_NEW (NATIONKEY, NATION, REGION) VALUES (27, 'THAILAND', 'APAC');
    INSERT INTO NATIONS_NEW (NATIONKEY, NATION, REGION) VALUES (28, 'GHANA', 'AFRICA');
    INSERT INTO NATIONS_NEW (NATIONKEY, NATION, REGION) VALUES (29, 'SPAIN', 'EUROPE');
    
    RETURN 'Creation of table NATIONS_NEW complete.';
END;


-- 15.1.5  Call the stored procedure to create the NATIONS_NEW table and verify
--         five rows were inserted.

CALL CREATE_NATIONS_NEW_TABLE();

SELECT * FROM NATIONS_NEW;


-- 15.1.6  Create a stored procedure that will insert the staged rows into the
--         NATION table.
--         Execute the statements below to create and call the stored procedure
--         and to verify the transfer worked. You should have 30 rows in NATION
--         and five rows in NATIONS_NEW.

CREATE OR REPLACE PROCEDURE TRANSFER_STAGED_ROWS()
RETURNS VARCHAR NOT NULL
LANGUAGE SQL
AS
BEGIN
  INSERT INTO NATION SELECT NATIONKEY, NATION, REGION FROM NATIONS_NEW;
  RETURN 'Transfer of newly staged rows complete';
END;

CALL TRANSFER_STAGED_ROWS();

SELECT * FROM NATION;

SELECT * FROM NATIONS_NEW;


-- 15.1.7  Create a stored procedure that calls the two previously created
--         stored procedures.
--         This procedure shows that you can call other stored procedures from
--         within a single procedure. We will call this stored procedure
--         throughout this exercise in order to reset our data as needed.
--         Execute the statements below to create and call the procedure and
--         verify the tables are ready to go. You should see 25 rows in NATION
--         and five rows in NATIONS_NEW.

CREATE OR REPLACE PROCEDURE CREATE_NATIONS_TABLES()
RETURNS VARCHAR NOT NULL
LANGUAGE SQL
AS
BEGIN
    CALL CREATE_NATION_TABLE();
    CALL CREATE_NATIONS_NEW_TABLE();
    RETURN 'Both tables created.';
END;

CALL CREATE_NATIONS_TABLES();

SELECT * FROM NATION;
SELECT * FROM NATIONS_NEW;


-- 15.1.8  Call the stored procedure to transfer the staged data from the
--         NATIONS_NEW table to the NATION table.
--         Execute the statements below to call the procedure and verify the
--         rows were inserted. You should see 30 rows in NATION and five rows in
--         NATIONS_NEW.

CALL TRANSFER_STAGED_ROWS();

SELECT * FROM NATION;
SELECT * FROM NATIONS_NEW;


-- 15.1.9  Restore your data to the starting state.
--         We’re going to do something a little different in the next step, so
--         let’s reset our data and verify the reset. Once again, you should see
--         25 rows in NATION and five in NATIONS_NEW.

CALL CREATE_NATIONS_TABLES();
SELECT * FROM NATION;
SELECT * FROM NATIONS_NEW;


-- 15.1.10 Use an IF-THEN statement.
--         Our stored procedure TRANSFER_STAGED_ROWS() only copies rows from the
--         staging table into NATION, but it leaves the rows in the staging
--         table alone. Ideally, after we copy the rows, we would want to
--         truncate the staging table so we don’t add the same rows again the
--         next time we call the stored procedure.
--         Below, we’re going to modify our original stored procedure by adding
--         an IF-THEN statement. We will also require the call to pass in the
--         value N to indicate that we don’t want to truncate the staging table.
--         If we don’t provide that value, the truncate will occur.
--         Execute the statements below to create and call the procedure and to
--         verify the rows were inserted. You should see 30 rows in NATION and
--         five rows in NATIONS_NEW.

CREATE OR REPLACE PROCEDURE TRANSFER_STAGED_ROWS(T VARCHAR)
RETURNS VARCHAR NOT NULL
LANGUAGE SQL
AS
BEGIN
    IF (T='N') THEN
        INSERT INTO NATION SELECT NATIONKEY, NATION, REGION FROM NATIONS_NEW;
        RETURN 'Completed insert.';
    ELSE
        INSERT INTO NATION SELECT NATIONKEY, NATION, REGION FROM NATIONS_NEW;
        TRUNCATE NATIONS_NEW;
        RETURN 'Completed insert and truncate.';
    END IF;
END;

CALL TRANSFER_STAGED_ROWS('N');
SELECT * FROM NATION;
SELECT * FROM NATIONS_NEW;

--         Now, let’s pass in a different value to test the ELSE condition.

-- 15.1.11 Restore your data to the starting state.

CALL CREATE_NATIONS_TABLES();
SELECT * FROM NATION;
SELECT * FROM NATIONS_NEW;


-- 15.1.12 Call the stored procedure but pass in Y instead of N.
--         Execute the statements below. You should have 30 rows in NATION and
--         zero rows in NATIONS_NEW.

CALL TRANSFER_STAGED_ROWS('Y');
SELECT * FROM NATION;
SELECT * FROM NATIONS_NEW;


-- 15.1.13 Use a CASE statement.
--         Now, let’s expand the logic and use a CASE statement. Here, we’re
--         adding an option to simply truncate the NATIONS_NEW table and not do
--         an insert at all.
--         Execute the statement below to create the stored procedure.

CREATE OR REPLACE PROCEDURE TRANSFER_STAGED_ROWS(T VARCHAR)
RETURNS VARCHAR NOT NULL
LANGUAGE SQL
AS
BEGIN
    CASE 
        WHEN T='N' THEN
            INSERT INTO NATION SELECT NATIONKEY, NATION, REGION FROM NATIONS_NEW;
            RETURN 'Completed insert.';
        WHEN T='Y' THEN
            INSERT INTO NATION SELECT NATIONKEY, NATION, REGION FROM NATIONS_NEW;
            TRUNCATE NATIONS_NEW;
            RETURN 'Completed insert and truncate.';
        ELSE
            TRUNCATE NATIONS_NEW;
            RETURN 'Completed truncate. No rows inserted.';        
    END;
END;


-- 15.1.14 Run the statements below to reset the data.

CALL CREATE_NATIONS_TABLES();
SELECT * FROM NATION;
SELECT * FROM NATIONS_NEW;


-- 15.1.15 Call the stored procedure and verify the results.
--         You should have 25 rows in NATION and zero rows in NATIONS_NEW.

CALL TRANSFER_STAGED_ROWS('X');
SELECT * FROM NATION;
SELECT * FROM NATIONS_NEW;


-- 15.1.16 Add an option where the user can indicate no change to either table.
--         This might be an option where a tree of tasks evaluates whether or
--         not to transfer the staged rows, and one of the possible outcomes is
--         to not transfer at that time.
--         Execute the statement below.

CREATE OR REPLACE PROCEDURE TRANSFER_STAGED_ROWS(T VARCHAR)
RETURNS VARCHAR NOT NULL
LANGUAGE SQL
AS
BEGIN
    CASE 
        WHEN T='N' THEN
            INSERT INTO NATION SELECT NATIONKEY, NATION, REGION FROM NATIONS_NEW;
            RETURN 'Completed insert.';
        WHEN T='Y' THEN
            INSERT INTO NATION SELECT NATIONKEY, NATION, REGION FROM NATIONS_NEW;
            TRUNCATE NATIONS_NEW;
            RETURN 'Completed insert and truncate.';
        WHEN T='T' THEN
            TRUNCATE NATIONS_NEW;
            RETURN 'Completed truncate. No rows inserted.'; 
        ELSE
            RETURN 'No action.';
    END;
END;


-- 15.1.17 Restore the data in the tables, call the stored procedure, and
--         evaluate the result.
--         You should have 25 rows in NATION and five rows in NATIONS_NEW.

CALL CREATE_NATIONS_TABLES();
SELECT * FROM NATION;
SELECT * FROM NATIONS_NEW;

CALL TRANSFER_STAGED_ROWS('X');
SELECT * FROM NATION;
SELECT * FROM NATIONS_NEW;


-- 15.1.18 Create a log table for truncated rows.
--         Let’s imagine that you need to keep track of the rows that were
--         truncated rather than being added to the NATION table. Let’s create
--         an empty log table with a structure identical to that of NATIONS_NEW.
--         Execute the statement below.

CREATE OR REPLACE TABLE TRUNCATED_NATIONS_LOG LIKE NATIONS_NEW;


-- 15.1.19 Create a stored procedure that will log all the rows to be truncated.
--         This stored procedure is a little more complex than the previous
--         ones.
--         For example, there is a DECLARE section where we set forth several
--         variables.
--         First, we declare a variable (counter) for the FOR loop we’ll use in
--         the BEGIN-END block. Second, we declare a cursor that will select all
--         rows from the NATIONS_NEW table. Third, we create three variables for
--         the values we will extract from each row of the cursor. Those
--         variables will then be used in an INSERT statement to log the row to
--         be truncated.
--         In the BEGIN-END statement, we open the cursor, then start the loop,
--         logging each row as the stored procedure as we iterate through the
--         rows in the cursor.
--         Note the use of the functions TO_NUMBER() and TO_CHAR() to ensure all
--         of the values in the cursor are in the proper data type for the
--         variable. This is especially critical for string values.
--         Execute the statement below.

CREATE OR REPLACE PROCEDURE LOG_TRUNCATED_ROWS()
RETURNS VARCHAR NOT NULL
LANGUAGE SQL
AS
DECLARE
        counter integer DEFAULT 0;
        cur cursor for select nationkey, nation, region from nations_new;  
        nationkey NUMBER(38,0) DEFAULT 0;
        nation varchar;
        region varchar;
BEGIN   
        open cur;            
        FOR record IN cur DO
            nationkey := TO_NUMBER(record.nationkey);
            nation := TO_CHAR(record.nation);
            region := TO_CHAR(record.region); 
                           
            INSERT INTO TRUNCATED_NATIONS_LOG (NATIONKEY, NATION, REGION)
            VALUES (:NATIONKEY, :NATION, :REGION);             
            counter := counter + 1;           
        END FOR;
        close cur;
        RETURN 'Logged rows to be truncated.';
END;

--         In the stored procedure presented above, the variables set forth in
--         the DECLARE section are preceded by a colon when included in the
--         BEGIN-END block’s SQL statements. This is necessary for Snowflake to
--         recognize these specifically as variables. However, the colon would
--         not needed if the variable appeared within a logic statement instead
--         of a SQL statement. This is true of input parameters as well.

-- 15.1.20 Add the stored procedure to TRANSFER_STAGED_ROWS().

CREATE OR REPLACE PROCEDURE TRANSFER_STAGED_ROWS(T VARCHAR)
RETURNS VARCHAR NOT NULL
LANGUAGE SQL
AS 
BEGIN
    CASE 
        WHEN T='N' THEN
            INSERT INTO NATION SELECT NATIONKEY, NATION, REGION FROM NATIONS_NEW;
            RETURN 'Completed insert.';
        WHEN T='Y' THEN
            INSERT INTO NATION SELECT NATIONKEY, NATION, REGION FROM NATIONS_NEW;
            TRUNCATE NATIONS_NEW;
            RETURN 'Completed insert and truncate.';
        WHEN T='T' THEN
            CALL LOG_TRUNCATED_ROWS();
            TRUNCATE NATIONS_NEW;
            RETURN 'Completed truncate. No rows inserted.'; 
        ELSE
            RETURN 'No action.';
    END;
END;


-- 15.1.21 Reset the table data and verify the data in the tables.
--         You should have 25 rows in NATION, five in NATIONS_NEW, and zero in
--         TRUNCATED_NATIONS_LOG.

CALL CREATE_NATIONS_TABLES();
SELECT * FROM NATION;
SELECT * FROM NATIONS_NEW;
SELECT * FROM TRUNCATED_NATIONS_LOG;


-- 15.1.22 Call the stored procedure and verify the rows in each table.
--         You should have 25 rows in NATION, zero rows in NATIONS_NEW, and five
--         rows in TRUNCATED_NATIONS_LOG.

CALL TRANSFER_STAGED_ROWS('T');

SELECT * FROM NATION;
SELECT * FROM NATIONS_NEW;
SELECT * FROM TRUNCATED_NATIONS_LOG;


-- 15.2.0  Part II - Analyze SQL Stored Procedures vs. JavaScript Stored
--         Procedures
--         You’ve been asked to write a stored procedure that is able to change
--         the size of a virtual warehouse. Users will need to be able to pass
--         the name of the virtual warehouse and the desired size into the
--         stored procedure.
--         The stored procedure should only recognize the following four sizes
--         as valid sizes: extra small, small, medium, and large. If the desired
--         size is within the four sizes listed above, the stored procedure
--         should change the virtual warehouse size and then return a message
--         indicating that the virtual warehouse has been set to the desired
--         size.
--         If the desired size is extra large or above, the stored procedure
--         should return a message indicating that the desired size is too
--         large.
--         If the size is not valid, the stored procedure should return a
--         message indicating that the size is invalid.

-- 15.2.1  Set the context.

USE ROLE TRAINING_ROLE;

CREATE WAREHOUSE IF NOT EXISTS LEARNER_WH;
ALTER WAREHOUSE LEARNER_WH SET WAREHOUSE_SIZE=XSmall;
USE WAREHOUSE LEARNER_WH;

CREATE DATABASE IF NOT EXISTS LEARNER_DB;
USE DATABASE LEARNER_DB;

CREATE SCHEMA IF NOT EXISTS LEARNER_DB.LEARNER_SCHEMA;
USE SCHEMA LEARNER_DB.LEARNER_SCHEMA;


-- 15.2.2  Run the script below to create a SQL stored procedure.

CREATE or REPLACE procedure ChangeWHSizeSQL(wh_name varchar, wh_size varchar)
    returns varchar
    language sql
AS
declare
    wh_size_uc varchar;
begin
    SELECT UPPER(:wh_size) into :wh_size_uc; 

    if (wh_size_uc = 'XSMALL' 
      OR wh_size_uc = 'SMALL' 
      OR wh_size_uc = 'MEDIUM' 
      OR wh_size_uc = 'LARGE')
    then
            execute immediate 'ALTER WAREHOUSE IF EXISTS ' || wh_name || ' SET WAREHOUSE_SIZE = ' || wh_size_uc;
            return 'WAREHOUSE ' || wh_name || ' SET TO ' || wh_size_uc;
    elseif (wh_size_uc = 'XLARGE'
        OR wh_size_uc = 'X-LARGE'
        OR wh_size_uc = 'XXLARGE'
        OR wh_size_uc = 'X2LARGE'
        OR wh_size_uc = '2X-LARGE'
        OR wh_size_uc = 'XXXLARGE'
        OR wh_size_uc = 'X3LARGE'
        OR wh_size_uc = '3X-LARGE'
        OR wh_size_uc = 'X4LARGE'
        OR wh_size_uc = '4X-LARGE')
    then
            return 'WAREHOUSE SIZE ' || wh_size_uc || ' IS TOO LARGE';
    else
            return 'WAREHOUSE SIZE ' || wh_size_uc || ' IS NOT A VALID SIZE';
    end if;
end;


-- 15.2.3  Look at the parameters and variables.
--         Our stored procedure, which we’ve named ChangeWHSizeSQL, accepts two
--         varchar values: the name of the target virtual warehouse and the
--         desired size.
--         Our code also declares a varchar value called wh_size_uc. We will use
--         this to store the current size of the virtual warehouse once we’ve
--         fetched it.

-- 15.2.4  Look at the BEGIN and END block.
--         As you know, the BEGIN and END block allows us to encapsulate a
--         series of statements to be executed one by one until all have been
--         completed. The first SELECT statement fetches the virtual warehouse
--         size and converts it to uppercase using the string function
--         UPPER(<expr>). We then assign it to the variable we declared earlier.

-- 15.2.5  Look at the IF-THEN statement.
--         As you can see, like many other systems, an IF-THEN statement in
--         Snowflake offers comparison operators such as IF, THEN, ELSEIF, and
--         ELSE.
--         In the IF portion, we enclose the IF condition in parentheses. Notice
--         that we are able to evaluate more than one potential condition by
--         using the OR operator. If you needed to meet multiple conditions in
--         the IF portion, you could use the AND operator.
--         As you know, the IF portion of the statement evaluates whether the
--         target virtual warehouse size is within the four accepted sizes. If
--         the requested size is too big, the IF-THEN statement tells the user
--         that the size requested is too large. If the size the user passes
--         into the stored procedure simply isn’t valid, the IF-THEN statement
--         returns a message to that effect to the calling user.

-- 15.2.6  Look at the EXECUTE IMMEDIATE statement.
--         The command EXECUTE IMMEDIATE is followed by a dynamically built
--         ALTER WAREHOUSE statement. The stored procedure concatenates several
--         string values using the double-pipe (||) operator to create the ALTER
--         WAREHOUSE statement that will change the virtual warehouse size.
--         Now, let’s try out the stored procedure!

-- 15.3.0  Try Out the Stored Procedure

-- 15.3.1  Change the current virtual warehouse to a SMALL.
--         Execute the statement below. Small is a valid size, so the stored
--         procedure will change the virtual warehouse size for you.

CALL CHANGEWHSIZESQL('LEARNER_wh', 'small');


-- 15.3.2  Change the current virtual warehouse to an XLARGE, which is too large
--         for the script.
--         Execute the statement below. XLarge is too big, so the stored
--         procedure will let you know that and won’t change the virtual
--         warehouse size.

CALL CHANGEWHSIZESQL('LEARNER_wh_wh', 'xlarge');


-- 15.3.3  Change the current virtual warehouse to a VERYSMALL, which is an
--         invalid size.
--         Execute the statement below. The size indicated is not a valid size,
--         so the stored procedure will let you know that.

CALL CHANGEWHSIZESQL('LEARNER_wh', 'verysmall');


-- 15.4.0  Create a JavaScript Stored Procedure
--         Now, we’re going to create a stored procedure that applies the same
--         logic that the SQL stored procedure does, except that this one will
--         be written in JavaScript.
--         Remember that JavaScript is case-sensitive, whereas SQL is not. The
--         JavaScript appears between the $$ delimiters, so make sure the case
--         in the JavaScript portion is preserved.
--         The procedure below demonstrates executing SQL statements in a
--         JavaScript stored procedure.

-- 15.4.1  Run the statement below to create the JavaScript stored procedure.

CREATE or REPLACE procedure ChangeWHSize(wh_name STRING, wh_size STRING )
    returns string
    language javascript
    AS
    $$
    var wh_size_UC = WH_SIZE.toUpperCase();

    switch(wh_size_UC) {
                            case 'XSMALL':
                            case 'SMALL':
                            case 'MEDIUM':
                            case 'LARGE':
                                break;
                            case 'XLARGE':
                            case 'X-LARGE':
                            case 'XXLARGE':
                            case 'X2LARGE':
                            case '2X-LARGE':
                            case 'XXXLARGE':
                            case 'X3LARGE':
                            case '3X-LARGE':
                            case 'X4LARGE':
                            case '4X-LARGE':
                                return "Size: " + WH_SIZE + " is too large";
                                break; 
                            default:
                                return "Size: " + WH_SIZE + " is not valid";
                                break; 
                        }
        
    var sql_command = 
     "ALTER WAREHOUSE IF EXISTS " + WH_NAME + " SET WAREHOUSE_SIZE = "+ WH_SIZE;

    try {
        snowflake.execute (
            {sqlText: sql_command}
            );
        return "WAREHOUSE " + WH_NAME + " SET TO " + WH_SIZE;   // Return a success/error indicator.
        }
    catch (err)  {
        return "Failed: " + err;   // Return a success/error indicator.
        }
    $$
    ;

--         A quick analysis shows that this stored procedure is functionally
--         identical to the one you created earlier.
--         First, it has a case statement that determines if the requested size
--         meets the criteria to change the virtual warehouse size. If not, it
--         determines if it’s too large or if it is entirely invalid.
--         The SQL statement to execute is dynamically built and assigned to a
--         variable called sql_command.
--         Last, the variable with the SQL statement is passed to
--         snowflake.execute, which is executed within a try-catch block.
--         Now, let’s try our JavaScript stored procedure.

-- 15.4.2  Call the stored procedure with a valid virtual warehouse size:

CALL changewhsize ('LEARNER_wh', 'small');


-- 15.4.3  Call the stored procedure with a virtual warehouse that is too large:

CALL changewhsize ('LEARNER_wh', 'XLARGE');


-- 15.4.4  Call the stored procedure with a non-existent virtual warehouse size:

CALL changewhsize ('LEARNER_wh', 'verysmall');


-- 15.4.5  Resize and suspend the virtual warehouse.

ALTER WAREHOUSE LEARNER_WH SET WAREHOUSE_SIZE=XSmall;

ALTER WAREHOUSE LEARNER_WH SUSPEND;


-- 15.5.0  Key Takeaways
--         - One stored procedure can call multiple other stored procedures.
--         - You can have IF-THEN and CASE statements in stored procedures.
--         - With Snowflake Scripting, you can create and open cursors and you
--         can insert, update, and delete records in a table.
--         - Snowflake Scripting enables you to add procedural logic to your
--         stored procedures. You can also have procedural logic, including try-
--         catch blocks, in a JavaScript stored procedure.
--         - A BEGIN and END block encapsulates several statements to be
--         executed one by one until all have been completed.
--         - UPPER() is a string function to convert a text string to uppercase.
--         - In a SQL statement within a stored procedure, you must precede each
--         variable with a colon so it can be recognized as a variable. This is
--         not the case if the variable appears in a logic statement.
--         - The IF, THEN, and ELSE IF conditions must be enclosed in
--         parentheses.
--         - You can use the AND and OR operators in the IF, THEN, or ELSE IF
--         portions of an IF-THEN statement as needed to evaluate multiple
--         conditions.
--         - You can use the double pipe (||) operator to concatenate string
--         values in order to dynamically build the statement that the EXECUTE
--         IMMEDIATE or RETURN portions of a stored procedure will execute.
--         - Snowflake also supports JavaScript stored procedures.
--         - JavaScript is case-sensitive, whereas SQL is not.

-- 15.6.0  Return to the Lab Exercise Page in the Course and Click the Mark as
--         complete Button
