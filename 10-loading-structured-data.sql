
-- 10.0.0  Loading Structured Data
--         The purpose of this lab is to introduce you to data loading. In the
--         final part of this lab, you’ll have an opportunity to write SQL code
--         to load data into a table. Just in case you need a little extra help,
--         we’ll provide both hints and a solution.
--         - Load data from a file in an external stage into a table using the
--         COPY INTO command.
--         - Define a Gzip file format.
--         - Review the properties of a stage.
--         - Load a Gzip file from an external stage into a table.
--         - Validate data prior to loading.
--         - Handle data loading errors.
--         This lab should take you approximately 20 minutes to complete.
--         You are a data engineer at Snowbear Air. You need to create and
--         populate a table that will be used in reporting. The table will be
--         called Region, and you will populate it from a pre-existing file
--         (region.tbl) in an external stage. The file is headerless, pipe-
--         delimited, and contains five rows.
--         Some of the steps in the lab exercise will intentionally produce
--         errors. Read and follow the instructions closely, so you understand
--         what is happening in each step.
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

-- 10.1.0  Load Data from an External Stage into a Table Using COPY INTO
--         In this exercise, you will learn how to load a file from an external
--         stage into a table using the COPY INTO command.

-- 10.1.1  Set your context.

USE ROLE TRAINING_ROLE;

CREATE WAREHOUSE IF NOT EXISTS LEARNER_WH INITIALLY_SUSPENDED=TRUE;
USE WAREHOUSE LEARNER_WH;

CREATE DATABASE IF NOT EXISTS LEARNER_DB;
USE DATABASE LEARNER_DB;

CREATE SCHEMA IF NOT EXISTS LEARNER_DB.LEARNER_SCHEMA;
USE LEARNER_DB.LEARNER_SCHEMA;


-- 10.1.2  Create a Region table. This table will be loaded from a source file.

CREATE OR REPLACE TABLE REGION (
       R_REGIONKEY NUMBER(38,0) NOT NULL,
       R_NAME      VARCHAR(25)  NOT NULL,
       R_COMMENT   VARCHAR(152)
);

--         The files for this task have been pre-loaded into a location on AWS.
--         The external stage that points to that location has been created for
--         you. The stage is in the TRAININGLAB schema of the TRAINING_DB
--         database. Now, let’s find the files in the stage.

-- 10.1.3  Use the list command below to list the files.

LIST @training_db.traininglab.ed_stage/load/lab_files/region.tbl;

--         Notice there are two files: region.tbl and region.tbl.gz. You’re
--         going to load both of them in this lab. You’ll load region.tbl first.

-- 10.1.4  Review the properties of the stage.
--         Let’s take a look at the properties of the stage where the file
--         resides.

DESCRIBE STAGE TRAINING_DB.TRAININGLAB.ED_STAGE;

--         As you can see, it has a column parent_property that contains several
--         rows where that column’s value is STAGE_FILE_FORMAT. There is also a
--         property column with a property of FIELD_DELIMITER. And last, there
--         is a column named property_value, and it has a comma (,) as its
--         value. This means that the default file format for the stage uses
--         commas as its field delimiter.

-- 10.1.5  Review the contents of region.tbl.
--         Take note of the delimiter used in the file.

SELECT $1
FROM @training_db.traininglab.ed_stage/load/lab_files/(PATTERN=> 'region[.]tbl$');

--         The field $1 returns multiple rows with a single column, and each row
--         contains an entire row from the file, including its pipe delimiters
--         (|). This is because the file is pipe-delimited and not comma-
--         delimited, and the file format of the stage is looking for commas to
--         work out the columns. But since there are no commas, it returns each
--         row as one column.
--         Files delimited with commas, pipes, or other delimiters can be staged
--         in the same stage, but if you try to load the file with the stage’s
--         format, you’ll get an error. You need a different file format to load
--         the file. Let’s create it now.

-- 10.1.6  Create a file format called MYPIPEFORMAT.
--         Run the code below to create a file format you can use to load
--         region.tbl.

CREATE OR REPLACE FILE FORMAT MYPIPEFORMAT
  TYPE = CSV
  COMPRESSION = NONE
  FIELD_DELIMITER = '|'
  ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE;

--         As you can see, we set the field delimiter to pipe (|).
--         Note that we set COMPRESSION = NONE. Snowflake will auto-detect the
--         compression format of files to be loaded, so the COMPRESSION
--         parameter is optional. However, if you want to use a file format
--         exclusively to load files of a specific compression type, you can
--         specify the type.
--         Next, we’ll confirm that the REGION table is empty.

-- 10.1.7  Execute the statement below.

SELECT * FROM REGION;


-- 10.1.8  Create and execute a COPY INTO statement.
--         Now, you’ll load the data from the external stage region.tbl into
--         your REGION table using the file format you created in the previous
--         task.

COPY INTO REGION
FROM @training_db.traininglab.ed_stage/load/lab_files/
FILES = ('region.tbl')
FILE_FORMAT = (FORMAT_NAME = MYPIPEFORMAT);


-- 10.1.9  Select and review the data in the REGION table.

SELECT * FROM REGION;

--         If you have data, your load was successful!

-- 10.2.0  Load a Gzip Compressed File on an External Stage into a Table
--         The scenario for this activity is fundamentally the same as the
--         previous activity. The difference is that you will load the REGION
--         table from a Gzip compressed file that is in the external stage. You
--         will create the MYGZIPPIPEFORMAT file format in this exercise.

-- 10.2.1  Empty the REGION Table in your schema.

TRUNCATE TABLE region;


-- 10.2.2  Confirm again that the region.tbl.gz file is in the external stage.

LIST @training_db.traininglab.ed_stage/load/lab_files/region.tbl;


-- 10.2.3  Create a file format called MYGZIPPIPEFORMAT.
--         This file format will read the compressed version of the region.tbl
--         file.
--         It should be identical to the MYPIPEFORMAT, except you will set
--         COMPRESSION = GZIP.

CREATE OR REPLACE FILE FORMAT MYGZIPPIPEFORMAT
 TYPE = CSV
 COMPRESSION = GZIP
 FIELD_DELIMITER = '|'
 ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE;


-- 10.2.4  Reload the REGION table from the region.tbl.gz file.
--         Review the syntax of the COPY INTO command used in the previous task.
--         Specify the file to COPY as region.tbl.gz.

COPY INTO region
FROM @training_db.traininglab.ed_stage/load/lab_files/
FILES = ('region.tbl.gz')
FILE_FORMAT = ( FORMAT_NAME = MYGZIPPIPEFORMAT);


-- 10.2.5  Query the table to confirm the data was successfully loaded.

SELECT * FROM region;


-- 10.2.6  Try to load an uncompressed file using a file format with Gzip
--         compression.
--         Before, we said that if you specify compression in a file format, you
--         can only load files with that type of compression. Let’s put that
--         theory to the test by executing the statements below.

-- Empty the table

TRUNCATE TABLE REGION;

-- Verify the table is empty

SELECT * FROM REGION;

-- Load the data into the table

COPY INTO region
FROM @training_db.traininglab.ed_stage/load/lab_files/
FILES = ('region.tbl')
FILE_FORMAT = ( FORMAT_NAME = MYGZIPPIPEFORMAT);

--         As you can see, the load failed, and you got a long error message. If
--         you can, it’s best not to specify compression in your file formats
--         and let Snowflake auto-detect the compression. Let’s try that out
--         now.

-- 10.2.7  Practice loading a file where compression format is auto-detected.
--         Below, you’ll do the same thing as before, but you’ll leave the
--         compression level out of the file format. Run the statements below to
--         load an uncompressed file.

-- Empty the table

TRUNCATE TABLE region;

-- Confirm the table is empty

SELECT * FROM REGION;

-- Create a file format to auto-detect the compression

CREATE OR REPLACE FILE FORMAT AUTO_DETECT_COMPRESSION
  TYPE = CSV
  FIELD_DELIMITER = '|'
  ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE;

-- Copy the uncompressed file

COPY INTO REGION
FROM @training_db.traininglab.ed_stage/load/lab_files/
FILES = ('region.tbl')
FILE_FORMAT = (FORMAT_NAME = AUTO_DETECT_COMPRESSION);

-- Confirm it loaded

SELECT * FROM REGION;

--         As you can see, it worked! Now, let’s load a compressed file with the
--         same file format and see if it works.

-- Empty the table

TRUNCATE TABLE region;

-- Confirm the table is empty

SELECT * FROM REGION;

-- Copy the compressed file

COPY INTO REGION
FROM @training_db.traininglab.ed_stage/load/lab_files/
FILES = ('region.tbl.gz')
FILE_FORMAT = (FORMAT_NAME = AUTO_DETECT_COMPRESSION);

-- Confirm it loaded

SELECT * FROM REGION;

--         Again, Snowflake’s ability to auto-detect the compression format of
--         the file worked in your favor and enabled the loading of the file.

-- 10.2.8  Resize and suspend the virtual warehouse.

ALTER WAREHOUSE LEARNER_WH SET WAREHOUSE_SIZE=XSmall;
ALTER WAREHOUSE LEARNER_WH SUSPEND;


-- 10.3.0  Validate Data Prior to Load
--         Now, we will use the VALIDATION_MODE parameter of the COPY INTO
--         statement to check for problems with the file prior to loading it.
--         Some of the steps will intentionally produce errors. Read and follow
--         the instructions closely, so you understand what is happening in each
--         step.

-- 10.3.1  Create the Nation table by running the statement below.

CREATE OR REPLACE TABLE nation (
                          NATION_KEY INTEGER,
                          NATION VARCHAR,
                          REGION_KEY INTEGER,
                          COMMENTS VARCHAR
                    );             


-- 10.3.2  Try to copy into the Nation table by executing the COPY INTO
--         statement below.
--         Notice that the validation mode is RETURN_ALL_ERRORS. This returns
--         all errors across all files specified in the COPY statement,
--         including files with errors that were partially loaded during an
--         earlier load because the ON_ERROR copy option was set to CONTINUE
--         during the load.
--         After you run the statement below, you will discover that no data was
--         loaded. This is because by providing a value for VALIDATION_MODE, we
--         are indicating we only want to check the file, not load the file.

COPY INTO NATION
FROM @training_db.traininglab.ed_stage/load/lab_files/
FILES = ('nation.tbl')
FILE_FORMAT = (FORMAT_NAME = MYPIPEFORMAT)
VALIDATION_MODE = RETURN_ALL_ERRORS;

--         You should have gotten a message that says, Query produced no
--         results. This means there were no errors and that you can load the
--         table. But now we’re going to recreate the table and switch the order
--         of the columns. By making REGION_KEY, which is an integer column, the
--         second column in the table, we will have errors because the second
--         column in the file is a VARCHAR field.

-- 10.3.3  Recreate the NATION table and execute the COPY INTO statement.
--         Note that in this case, we are using RETURN_ERRORS. This returns all
--         errors (parsing, conversion, etc.) across all files specified in the
--         COPY statement.
--         Run the statement below.

CREATE OR REPLACE TABLE nation (
                          NATION_KEY INTEGER,
                          REGION_KEY INTEGER,    
                          NATION VARCHAR,
                          COMMENTS VARCHAR
                    );

COPY INTO NATION
FROM @training_db.traininglab.ed_stage/load/lab_files/
FILES = ('nation.tbl')
FILE_FORMAT = (FORMAT_NAME = MYPIPEFORMAT)
VALIDATION_MODE = RETURN_ERRORS;

--         Now, you should have 25 rows indicating that the VARCHAR value we
--         tried to load into the REGION_KEY column has created an error. You
--         may need to scroll to the right to see the entire error message.
--         Had we tried to load the file, none of the rows would have loaded.

-- 10.3.4  Check only the first 10 rows.
--         In the next statement, we set the VALIDATION_MODE to RETURN_10_ROWS.
--         So, our statement will only check the first ten rows and return the
--         first error it encounters.

COPY INTO NATION
FROM @training_db.traininglab.ed_stage/load/lab_files/
FILES = ('nation.tbl')
FILE_FORMAT = (FORMAT_NAME = MYPIPEFORMAT)
VALIDATION_MODE = RETURN_10_ROWS;

--         As you can see, we have a message saying that the numeric value
--         ALGERIA is not recognized.

-- 10.4.0  Error Handling
--         In this section, we will intentionally generate errors in the
--         following queries so you can examine how the Snowflake data loading
--         error handling options function.

-- 10.4.1  Recreate the table with all columns in the same order as they are in
--         the nation.tbl file.


CREATE OR REPLACE TABLE nation (
                          NATION_KEY INTEGER,
                          NATION VARCHAR,
                          REGION_KEY INTEGER,
                          COMMENTS VARCHAR
                    );


--         Now, let’s write a query so we can attempt to insert some data.

-- 10.4.2  Write a query that generates errors.
--         Our query uses a CASE expression to convert the region key integer
--         value in the third column to America if its value is one. Run the
--         query and examine the result.

SELECT    
          n.$1 AS N_KEY,
          n.$2 AS NATION,    
          CASE 
            WHEN n.$3 = 1 THEN 'AMERICA'
            ELSE n.$3
          END AS R_KEY,
          n.$4 AS COMMENTS
FROM @training_db.traininglab.ed_stage/load/lab_files/nation.tbl (file_format => 'MYPIPEFORMAT') n;

--         As you can see, five rows have the VARCHAR value America instead of
--         an integer value. Because the data type of the REGION_KEY column in
--         the table we just created is an integer, five errors will be
--         generated when we attempt to load the data.
--         If, by examining this query, you realized that CASE expressions (as
--         well as other functions and SQL commands) could be used to transform
--         data before loading it, congratulations! You now have another
--         valuable tool in your data-loading toolbox. Regardless, using a CASE
--         expression here is not to illustrate using CASE expressions or data
--         transformation but to generate the errors we need to demonstrate
--         error handling.

-- 10.4.3  Attempt to load the data.
--         Notice that in the query below, we’ve set the ON_ERROR parameter to
--         continue. This means that all rows that don’t generate an error will
--         get loaded.

COPY INTO nation
FROM (
        SELECT    
              n.$1 AS N_KEY,
              n.$2 AS NATION,    
              CASE 
                WHEN n.$3 = 1 THEN 'AMERICA'
                ELSE n.$3
              END AS R_KEY,
              n.$4 AS COMMENTS

        FROM @training_db.traininglab.ed_stage/load/lab_files/nation.tbl (file_format => 'MYPIPEFORMAT') n
    )
FILE_FORMAT = (FORMAT_NAME = MYPIPEFORMAT)
ON_ERROR = CONTINUE;

--         As you can see from the results, the status is PARTIALLY_LOADED, and
--         rows_loaded is 20 out of the original 25.

-- 10.4.4  Run the SELECT statement below to verify the contents of the table,
--         then truncate the table.

SELECT * FROM nation;

TRUNCATE TABLE nation;


-- 10.4.5  Retry the insert with ON_ERROR = ABORT_STATEMENT.
--         ABORT_STATEMENT is the default value, and it will cause the entire
--         load to fail.

COPY INTO nation
FROM (
        SELECT    
              n.$1 AS N_KEY,
              n.$2 AS NATION,    
              CASE 
                WHEN n.$3 = 1 THEN 'AMERICA'
                ELSE n.$3
              END AS R_KEY,
              n.$4 AS COMMENTS

        FROM @training_db.traininglab.ed_stage/load/lab_files/nation.tbl (file_format => 'MYPIPEFORMAT') n
    )
FILE_FORMAT = (FORMAT_NAME = MYPIPEFORMAT)
ON_ERROR = ABORT_STATEMENT; 

--         As you can see, the error is Numeric value AMERICA is not recognized.
--         No data was loaded.

-- 10.4.6  Retry the insert with ON_ERROR = SKIP_FILE_4.
--         With this statement, we’re telling Snowflake that we don’t want to
--         load the file if we have four or more errors. Since we know our file
--         will generate five errors, the load should fail completely.

COPY INTO nation
FROM (
        SELECT    
              n.$1 AS N_KEY,
              n.$2 AS NATION,    
              CASE 
                WHEN n.$3 = 1 THEN 'AMERICA'
                ELSE n.$3
              END AS R_KEY,
              n.$4 AS COMMENTS

        FROM @training_db.traininglab.ed_stage/load/lab_files/nation.tbl (file_format => 'MYPIPEFORMAT') n
    )
FILE_FORMAT = (FORMAT_NAME = MYPIPEFORMAT)
ON_ERROR = SKIP_FILE_4; 

--         As you can see, you got an error that says LOAD_FAILED.

-- 10.4.7  Run query to validate error.
--         Run the query below to validate that the table is empty.

SELECT * FROM nation;


-- 10.4.8  Retry the insert with ON_ERROR = SKIP_FILE_6.
--         With this statement, we’re telling Snowflake that we don’t want to
--         load the file if we have six or more errors. Since we know our file
--         will generate five errors, we should get a partial load.

COPY INTO nation
FROM (
        SELECT    
              n.$1 AS N_KEY,
              n.$2 AS NATION,    
              CASE 
                WHEN n.$3 = 1 THEN 'AMERICA'
                ELSE n.$3
              END AS R_KEY,
              n.$4 AS COMMENTS

        FROM @training_db.traininglab.ed_stage/load/lab_files/nation.tbl (file_format => 'MYPIPEFORMAT') n
    )
FILE_FORMAT = (FORMAT_NAME = MYPIPEFORMAT)
ON_ERROR = SKIP_FILE_6;

--         As you can see, the file was partially loaded. Snowflake loaded 20
--         out of 25 rows.

-- 10.5.0  OPTIONAL - Try it out!
--         In this section, you will write file formats and COPY INTO commands
--         to practice what you’ve learned. The solutions are at the end of this
--         lab.
--         Snowbear Air has asked you to load data for a parts table into
--         Snowflake. The file with the data is sitting in an external stage.
--         All you have to do is create the table and execute a one-time load
--         into that table using COPY INTO.
--         Start by setting your context as follows:

USE ROLE TRAINING_ROLE;
USE WAREHOUSE LEARNER_WH;
USE LEARNER_DB.LEARNER_SCHEMA;

--         The data can be found in the database TRAINING_DB, schema
--         TRAININGLAB, and stage ED_STAGE. You can use the SQL below to query
--         the file prior to load.

SELECT p.$1
FROM @training_db.traininglab.ed_stage/load/lab_files/part.tbl p;

--         As you can see, each row contains product values separated by pipe-
--         delimiters for the following columns: a product number, a product
--         description, product manufacturer, brand, physical attributes of the
--         product, quantity per container, the container the product is
--         delivered in, the price, and some notes.
--         The path in the FROM clause above is the same one you’ll use in your
--         COPY INTO statement.
--         As for your file format, you’ll be loading a CSV file, the field
--         delimiter will be a pipe, no compression will be necessary, and the
--         ERROR_ON_COLUMN_MISMATCH parameter should be set to false.
--         Click here for File Format tips. (https://docs.snowflake.com/en/sql-
--         reference/sql/create-file-format.html)
--         Click here for COPY INTO tips. (https://docs.snowflake.com/en/user-
--         guide/data-load-overview.html)

-- 10.5.1  Suspend your virtual warehouse.

ALTER WAREHOUSE LEARNER_WH SUSPEND;

--         If you need help, the solution is on the next page. Otherwise,
--         congratulations! You have now completed this lab.

-- 10.6.0  Key Takeaways
--         - Files to be loaded can be compressed or uncompressed.
--         - The COPY INTO command can be used to load.
--         - You can use the LIST command to see what files are in a stage.
--         - Use the VALIDATION_MODE parameter of the COPY INTO statement to
--         check for problems with the file prior to loading.
--         - You can set the ON_ERROR parameter of the COPY INTO statement to
--         load all, some, or none of the data if one or more errors are
--         detected.

-- 10.7.0  Solution
--         If you really need to, you can look at the solution below. But try
--         not to peek! You’ll learn more if you try it on your own first and
--         rely only on the hints.

USE ROLE TRAINING_ROLE;

CREATE DATABASE IF NOT EXISTS LEARNER_DB;
USE DATABASE LEARNER_DB;

CREATE SCHEMA IF NOT EXISTS LEARNER_DB.LEARNER_SCHEMA;
USE LEARNER_DB.LEARNER_SCHEMA;

CREATE WAREHOUSE IF NOT EXISTS LEARNER_WH INITIALLY_SUSPENDED=TRUE;
USE WAREHOUSE LEARNER_WH;

-- Preview the data in an external stage

SELECT p.$1
FROM @training_db.traininglab.ed_stage/load/lab_files/part.tbl p;

-- Create a table to load data into

CREATE OR REPLACE TABLE PART (
    PRODNUMBER          NUMBER,
    DESCRIPTION         VARCHAR,
    MANUFACTURER        VARCHAR,
    BRAND               VARCHAR,
    ATTRIBUTES          VARCHAR,
    QTY_PER_CONTAINER   NUMBER,
    CONTAINER           VARCHAR,
    PRICE               NUMBER,
    NOTES               VARCHAR
);


-- 10.7.1  Create a FILE FORMAT to use in the COPY INTO command.
--         Click here for information on file formats.
--         (https://docs.snowflake.com/en/sql-reference/sql/create-file-
--         format.html)
--         – Solution–>

CREATE OR REPLACE FILE FORMAT MYPIPEFORMAT
  TYPE = CSV
  COMPRESSION = NONE
  FIELD_DELIMITER = '|'
  FILE_EXTENSION = 'tbl'
  ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE;


-- 10.7.2  Copy data into the table.
--         Click here for information on COPY INTO.
--         (https://docs.snowflake.com/en/user-guide/data-load-overview.html)
--         – Solution–>

COPY INTO PART
FROM @training_db.traininglab.ed_stage/load/lab_files/
FILES = ('part.tbl')
FILE_FORMAT = (FORMAT_NAME = MYPIPEFORMAT);

-- Verify data in table

SELECT *
FROM PART
LIMIT 100;

-- Suspend your virtual warehouse

ALTER WAREHOUSE LEARNER_WH SUSPEND;


-- 10.8.0  Return to the Lab Exercise Page in the Course and Click the Mark as
--         complete Button
