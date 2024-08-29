
-- 16.0.0  Challenge Lab: Snowflake Stored Procedures and Snowflake Scripting
--         The purpose of this lab is to give you an on-your-own experience
--         creating a stored procedure with CASE statements, looping, and a
--         cursor. We’ll provide details about the expected result and some
--         hints, but you’ll do most of the work yourself.
--         - Create a stored procedure that can insert rows into another table.
--         - Implement a CASE statement in a stored procedure.
--         - Implement a FOR loop in a stored procedure.
--         - Successfully iterate through rows in a cursor.
--         This lab should take you approximately 35 minutes to complete.
--         Snowbear Air has a table called NATION. This table is truncated and
--         re-populated from time to time with different nations and regions
--         based on reporting needs.
--         Now, reporting will be done out of specific region tables instead of
--         the NATION table. You have been tasked with creating a stored
--         procedure that will take rows from the NATION table and insert them
--         into their respective regional tables.
--         Because this re-populating of the NATION table (and thus the need to
--         place rows into regional tables) will continue for the foreseeable
--         future, you’ve been tasked with producing a log of which row was put
--         into which table. You also need to timestamp each row in the log
--         table.
--         Someone else will use your stored procedure in a recurring task, so
--         all you have to do is create the stored procedure. Also, you don’t
--         need to truncate the NATION table.
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
--         - You should create a new schema for this exercise.
--         - You can use the function CURRENT_TIMESTAMP() in a query or INSERT
--         statement.

-- 16.1.0  Create a Stored Procedure

-- 16.1.1  Set your context using a new schema called STORED_PROCS_CHALLENGE.

-- 16.1.2  Create the nation table and put in some values.

CREATE OR REPLACE TABLE NATION AS SELECT 
   N.N_NATIONKEY AS NATIONKEY, 
   N.N_NAME NATION, 
   R.R_NAME REGION
FROM 
   SNOWBEARAIR_DB.PROMO_CATALOG_SALES.NATION N 
   INNER JOIN SNOWBEARAIR_DB.PROMO_CATALOG_SALES.REGION R ON N.N_REGIONKEY = R.R_REGIONKEY;
        
INSERT INTO NATION (NATIONKEY, NATION, REGION) VALUES 
   (25, 'MEXICO', 'AMERICA'),
   (26, 'GHANA', 'AFRICA'),
   (27, 'THAILAND', 'APAC'),
   (28, 'UGANDA', 'AFRICA'),
   (29, 'SPAIN', 'EUROPE');


-- 16.1.3  Create a table for each region in the nations table.
--         The structure of the region-specific tables will be the same as the
--         NATION table. Use CREATE TABLE…LIKE NATION to create empty tables
--         structurally identical to the NATION table but with new names.

-- 16.1.4  Create the log table.

-- 16.1.5  Write and call your stored procedure.

-- 16.1.6  Verify all tables to make sure the data looks as you expect.

-- 16.1.7  Suspend your virtual warehouse.

ALTER WAREHOUSE LEARNER_WH SUSPEND;

--         If you need help, the solution is on the next page. Otherwise,
--         congratulations! You have now completed this lab.

-- 16.2.0  Solution
--         If you really need to, you can look at the solution below. But try
--         not to peek! You’ll learn more if you try it on your own first and
--         rely only on the hints.

-- Set Your Context

USE ROLE TRAINING_ROLE;

CREATE WAREHOUSE IF NOT EXISTS LEARNER_WH;
USE WAREHOUSE LEARNER_WH;

CREATE DATABASE IF NOT EXISTS LEARNER_DB;
USE DATABASE LEARNER_DB;

CREATE OR REPLACE SCHEMA LEARNER_DB.STORED_PROCS_CHALLENGE;
USE SCHEMA LEARNER_DB.STORED_PROCS_CHALLENGE;


-- Create the Nation Table

SELECT * FROM  
   SNOWBEARAIR_DB.PROMO_CATALOG_SALES.NATION N 
   INNER JOIN SNOWBEARAIR_DB.PROMO_CATALOG_SALES.REGION R ON N.N_REGIONKEY = R.R_REGIONKEY;

CREATE OR REPLACE TABLE NATION AS SELECT 
   N.N_NATIONKEY AS NATIONKEY, 
   N.N_NAME NATION, 
   R.R_NAME REGION
FROM 
   SNOWBEARAIR_DB.PROMO_CATALOG_SALES.NATION N 
   INNER JOIN SNOWBEARAIR_DB.PROMO_CATALOG_SALES.REGION R ON N.N_REGIONKEY = R.R_REGIONKEY;
        

INSERT INTO NATION (NATIONKEY, NATION, REGION) VALUES 
   (25, 'MEXICO', 'AMERICA'),
   (26, 'GHANA', 'AFRICA'),
   (27, 'THAILAND', 'APAC'),
   (28, 'UGANDA', 'AFRICA'),
   (29, 'SPAIN', 'EUROPE');
    
SELECT * from nation;

-- Create the Region Table

SELECT DISTINCT REGION
FROM NATION
ORDER BY REGION;

--AFRICA
--AMERICA
--APAC
--EUROPE
--MIDDLE EAST

CREATE OR REPLACE TABLE AFRICA
   LIKE NATION;

CREATE OR REPLACE TABLE AMERICA
   LIKE NATION;

CREATE OR REPLACE TABLE APAC
   LIKE NATION;

CREATE OR REPLACE TABLE EUROPE
   LIKE NATION;

CREATE OR REPLACE TABLE MIDDLE_EAST
   LIKE NATION;


-- Create the Log Table

CREATE OR REPLACE TABLE INSERT_LOG(
                        NATIONKEY NUMBER(38,0),
                        NATION VARCHAR(25),
                        REGION VARCHAR(25),
                        TABLENAME VARCHAR(25),
                        TS TIMESTAMP
);


-- Verify All Tables are Empty

SELECT * FROM AFRICA;

SELECT * FROM AMERICA;

SELECT * FROM APAC;

SELECT * FROM EUROPE;

SELECT * FROM MIDDLE_EAST;

SELECT * FROM INSERT_LOG;

-- Create Your Stored Procedure

CREATE OR REPLACE PROCEDURE INSERT_NATIONS_INTO_REGION_TABLES()
RETURNS VARCHAR NOT NULL
LANGUAGE SQL
AS
DECLARE
        counter integer DEFAULT 0;
        cur cursor for select nationkey, nation, region from nation;  
        nationkey NUMBER(38,0) DEFAULT 0;
        nation varchar;
        region varchar;

BEGIN   
            open cur;            
            FOR record IN cur DO
                nationkey := to_NUMBER(record.nationkey);
                nation := TO_CHAR(record.nation);
                region := TO_CHAR(record.region);
                                
                CASE 
                    WHEN region='AFRICA' THEN
                        INSERT INTO AFRICA (NATIONKEY, NATION, REGION)
                        VALUES (:NATIONKEY, :NATION, :REGION);
                    WHEN region='AMERICA' THEN
                        INSERT INTO AMERICA (NATIONKEY, NATION, REGION)
                        VALUES (:NATIONKEY, :NATION, :REGION);
                    WHEN region='APAC' THEN
                        INSERT INTO APAC (NATIONKEY, NATION, REGION)
                        VALUES (:NATIONKEY, :NATION, :REGION);            
                    WHEN region='EUROPE' THEN
                        INSERT INTO EUROPE (NATIONKEY, NATION, REGION)
                        VALUES (:NATIONKEY, :NATION, :REGION);            
                    WHEN region='MIDDLE EAST' THEN
                        INSERT INTO MIDDLE_EAST (NATIONKEY, NATION, REGION)
                        VALUES (:NATIONKEY, :NATION, :REGION);       
                END;
                
                INSERT INTO INSERT_LOG (NATIONKEY, NATION, REGION, TABLENAME, TS)
                VALUES (:NATIONKEY, :NATION, :REGION, :REGION, current_timestamp(2));                
                
                counter := counter + 1;   
                
            END FOR;
            close cur;
            RETURN 'Insertion and logging complete.';
END;


-- Call Your Stored Procedure

CALL INSERT_NATIONS_INTO_REGION_TABLES();

-- Verify all data appears as you expected

SELECT * FROM AFRICA;

SELECT * FROM AMERICA;

SELECT * FROM APAC;

SELECT * FROM EUROPE;

SELECT * FROM MIDDLE_EAST;

SELECT * FROM INSERT_LOG;

-- Suspend Your Virtual Warehouse

ALTER WAREHOUSE LEARNER_WH SUSPEND;


-- 16.3.0  Return to the Lab Exercise Page in the Course and Click the Mark as
--         complete Button
