
-- 12.0.0  Unloading Structured Data
--         The purpose of this lab is to introduce you to data unloading.
--         - Unload table data into a Table Stage in pipe-delimited file format.
--         - Write a SQL statement containing a JOIN to unload a table into an
--         internal stage.
--         This lab should take you approximately 10 minutes to complete.
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

-- 12.1.0  Unload Table Data into a Table Stage in Pipe-delimited File Format

-- 12.1.1  Set your context.

USE ROLE TRAINING_ROLE;

CREATE WAREHOUSE IF NOT EXISTS LEARNER_WH;
USE WAREHOUSE LEARNER_WH;

CREATE DATABASE IF NOT EXISTS LEARNER_DB;

USE LEARNER_DB.PUBLIC;


-- 12.1.2  Create a fresh version of the REGION table with five records to
--         unload.

CREATE or REPLACE table region AS 
   SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.REGION;

-- Run the query below to validate the load was successful

SELECT * FROM REGION;


-- 12.1.3  Create a file format called mypipeformat.

CREATE OR REPLACE FILE FORMAT mypipeformat
  TYPE = CSV
  COMPRESSION = NONE
  FIELD_DELIMITER = '|'
  FILE_EXTENSION = 'tbl';


-- 12.1.4  Unload the data to the REGION table stage.
--         Remember that a table stage is automatically created for each table.
--         Use the slides, workbook, or Snowflake documentation for questions on
--         the syntax. You will use MYPIPEFORMAT for the unloading. This will
--         cause the unloaded file to be formatted according to the
--         specifications of the MYPIPEFORMAT file format. The file format
--         specified COMPRESSION = NONE. So, the files that are created during
--         the unloading process will not be compressed.

COPY INTO @%region
FROM region
FILE_FORMAT = (FORMAT_NAME = MYPIPEFORMAT);


-- 12.1.5  List the stage and query the file to verify that the data is there.

LIST @%region;

SELECT * 
FROM @%region/data_0_0_0.tbl
( FILE_FORMAT => 'MYPIPEFORMAT');


-- 12.1.6  Remove the file from the region table’s stage and verify it is gone.

REMOVE @%region;

LIST @%region;


-- 12.2.0  Use a SQL statement Containing a JOIN to Unload Data into an Internal
--         Stage
--         This activity is essentially the same as the previous activity. The
--         difference is that you will unload data from more than one table into
--         a single file.

-- 12.2.1  Do a SELECT with a JOIN on the region and nation tables.
--         Review the output from your JOIN.

SELECT * 
FROM "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF1"."REGION" r 
JOIN "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF1"."NATION" n ON r.r_regionkey = n.n_regionkey;


-- 12.2.2  Create a named stage (you can give any name to a named stage).

CREATE OR REPLACE STAGE mystage;


-- 12.2.3  Unload the joined data into the stage you created.

COPY INTO @mystage FROM
(SELECT * 
  FROM "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF1"."REGION" r 
  JOIN "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF1"."NATION" n
  ON r.r_regionkey = n.n_regionkey)
FILE_FORMAT = (FORMAT_NAME = MYPIPEFORMAT);


-- 12.2.4  Verify the file is in the stage.

LIST @mystage;

SELECT $1, $2, $3, $4, $5, $6, $7 
FROM @mystage/data_0_0_0.tbl (FILE_FORMAT => MYPIPEFORMAT);


-- 12.2.5  Remove the file from the stage and verify removal.

REMOVE @mystage;

LIST @mystage;


-- 12.2.6  Remove the stage.

DROP STAGE mystage;


-- 12.2.7  Resize and suspend the virtual warehouse.

ALTER WAREHOUSE LEARNER_WH SET WAREHOUSE_SIZE=XSmall;

ALTER WAREHOUSE LEARNER_WH SUSPEND;


-- 12.3.0  Key Takeaways
--         - The COPY INTO command can be used to unload data.
--         - Data from multiple tables can be unloaded using a JOIN statement.
--         - You can use the LIST command to see what files are in a stage.

-- 12.4.0  Return to the Lab Exercise Page in the Course and Click the Mark as
--         complete Button
