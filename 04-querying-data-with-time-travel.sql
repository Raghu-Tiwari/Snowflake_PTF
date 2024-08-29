
-- 4.0.0   Querying Data with Time Travel
--         The purpose of this lab is to familiarize you with how Time Travel
--         works and how it can be used to protect data and analyze changes in
--         data.
--         By the end of this lab, you should be able to:
--         - Clone a table.
--         - Write query clauses that support Time Travel actions.
--         - Fetch and use the ID of the last query you ran.
--         - Use Time Travel to restore data.
--         This lab should take you approximately 15 minutes to complete.
--         Snowbear Air is expanding into several new areas and would like you
--         to make some changes to the nation and region tables. Unfortunately,
--         the person organizing this effort is still deciding what the changes
--         will look like, so you may have to go through several iterations.
--         You will be setting and using Snowflake variables to help you keep
--         track of the changes you are making.
--         HOW TO COMPLETE THIS LAB
--         As the workbook PDF may have useful diagrams, we recommend that you
--         read the instructions from the workbook PDF. In order to execute the
--         code presented in each step, use the SQL code file provided for this
--         lab.
--         OPENING THE SQL FILE
--         To load the SQL file, in the left navigation bar select Projects,
--         then select Worksheets. From the Worksheets page, in the upper-right
--         corner, click the ellipsis (…) to the left of the blue plus (+)
--         button. Select Create Worksheet from SQL File from the drop-down
--         menu. Navigate to the SQL file for this lab and load it.
--         Let’s get started!
--         Note that various steps in this lab intentionally generate errors.
--         The purpose of these errors is to demonstrate and reinforce Time
--         Travel concepts. So, proceed slowly through the lab and read the
--         instructions carefully.

-- 4.1.0   Create a Test Environment
--         You don’t want to be working on production data, so you will start by
--         creating a clone of the table you will be working with.

-- 4.1.1   Set your context.

USE ROLE training_role;

CREATE WAREHOUSE IF NOT EXISTS LEARNER_WH;
ALTER WAREHOUSE LEARNER_WH SET WAREHOUSE_SIZE=XSmall;
USE WAREHOUSE LEARNER_WH;

CREATE DATABASE IF NOT EXISTS LEARNER_DB;
USE DATABASE LEARNER_DB;

CREATE SCHEMA IF NOT EXISTS LEARNER_db.regions_dev;
USE SCHEMA LEARNER_db.regions_dev;


-- 4.1.2   Clone the table you need into the regions_dev schema.

CREATE OR REPLACE TABLE region 
CLONE snowbearair_db.promo_catalog_sales.region;

--         You will begin by making changes to the region table, following the
--         direction of the project manager. They gave you a list of the new
--         regions and told you to add them as the sixth through ninth regions.

-- 4.2.0   Add Regions to the Region Table

-- 4.2.1   Check that the table has five rows.

SELECT * FROM region;


-- 4.2.2   Fetch the current timestamp and save it as a session variable.

SET dev_before_changes = current_timestamp();


-- 4.2.3   Insert four rows into the region table.

INSERT INTO 
   region
VALUES
   (6, 'Western Europe'),
   (7, 'Eastern Europe'),
   (8, 'Northern Europe'),
   (9, 'Southern Europe');


-- 4.2.4   Fetch the last query ID and save it as a session variable.

SET dev_new_europe_regions = LAST_QUERY_ID();


-- 4.2.5   Check that the region table has nine rows.

SELECT * FROM region;

--         Note that you created two variables, one that recorded the moment
--         before you inserted the new regions and one that recorded the ID of
--         the INSERT statement. These will come in handy later.
--         The project manager notices that the new regions are in mixed case,
--         but the existing regions are in all upper-case. They have asked you
--         to make them match.

-- 4.3.0   Standardize Region Names in the Region Table
--         Since you were not provided with specifics, you decided to make all
--         the entries mixed-case. You will delete the existing regions and then
--         re-add them.

-- 4.3.1   Delete the pre-existing regions from the region table.

DELETE FROM 
   region
WHERE
   r_regionkey < 6;


-- 4.3.2   Fetch the query id of the DELETE statement and save it in a session
--         variable.

SET dev_remove_existing_UC_regions = LAST_QUERY_ID();

--         By saving the execution of this DELETE statement as a point-in-time
--         in variable dev_remove_existing_UC_regions, we can leverage Time
--         Travel to check the state of the table prior to that DELETE
--         statement. We’ll do that in just a moment.

-- 4.3.3   Determine the regions to add back in.
--         Now, you need to add the existing regions back in using mixed-case.
--         However, you realize you don’t know what the existing regions were or
--         their region IDs. So you need to use Time Travel to look at the table
--         before you took that information out.

SELECT *
FROM region
BEFORE(statement=>$dev_remove_existing_UC_regions);

--         As you can see, the BEFORE clause allowed us to see what regions were
--         in the table before we deleted them.

-- 4.3.4   Add the previous regions back into the table in mixed case.
--         Now you know the regions and can add them back in.

INSERT INTO
   region
VALUES
   (0, 'Africa'),
   (1, 'America'),
   (2, 'Apac'),
   (3, 'Europe'),
   (4, 'Middle East');

SET dev_old_regions_mixed_case = LAST_QUERY_ID();

SELECT * FROM region;

--         When you look at the output, you notice a problem. You have added
--         four new regions for different areas of Europe, but the region Europe
--         is still in the table. You point this out to the project manager.

-- 4.3.5   Remove the region Europe from the table.

DELETE FROM 
   region
WHERE
   r_name = 'Europe';

SET dev_remove_europe = LAST_QUERY_ID();

--         Once again, we save the point-in-time this last query was run into a
--         variable called dev_remove_europe. We can use this later in a BEFORE
--         statement.
--         Everything should be set now so you show the result to the project
--         manager. They don’t like the names in mixed case, and they also point
--         out that you should have numbered the sixth region as five since the
--         numbering starts with zero. Oh, and they want the new region names to
--         be formatted like EUROPE: EASTERN and to be in alphabetical order.
--         Back to the drawing board.

-- 4.4.0   Change the Region Names to Upper Case
--         Rather than recreate the old table, you decide to restore the
--         original version, remove Europe, and then add the new regions. You no
--         longer have the ability to clone the table from production, so you
--         decide to drop the table and then undrop the earliest version.

-- 4.4.1   Drop the current version of the region table.

DROP TABLE region;


-- 4.4.2   Try to UNDROP the earliest version of the region table.
--         The following command tries to UNDROP the table at a prior point in
--         time. The command will fail with an Unsupported Feature error because
--         only the most recent version of a table can be restored.

UNDROP TABLE 
   region
BEFORE(statement=>$dev_new_europe_regions);

--         As expected you got the Unsupported Feature error. Next you will use
--         both Time Travel and cloning.

-- 4.4.3   Try to clone the region table at the point in time before inserting
--         the new European regions.
--         The command below will fail because the region table was dropped. You
--         cannot clone a table that does not exist.

CREATE TABLE
   restored_region
CLONE
   region
BEFORE(statement=>$dev_new_europe_regions);

--         As expected the command failed. Now what!? Let’s UNDROP the region
--         table and clone it from its state just before your first changes.

-- 4.4.4   UNDROP the region table and clone it.

UNDROP TABLE region;

CREATE TABLE
   restored_region
CLONE
   region
BEFORE(timestamp=>$dev_before_changes);

SELECT * FROM restored_region;


-- 4.5.0   Make the Necessary Changes to the Restored Region Table
--         Now that you fully understand the requirements, you can make the
--         necessary changes.

-- 4.5.1   Delete the EUROPE record from the restored table and verify the table
--         data.

DELETE FROM
   restored_region
WHERE
   r_name = 'EUROPE';

SET dev_dropped_europe = LAST_QUERY_ID();

SELECT * FROM restored_region;


-- 4.5.2   Insert the new EUROPE records into the restored table and verify the
--         table data.

INSERT INTO
   restored_region
VALUES
   (5, 'EUROPE: EASTERN'),
   (6, 'EUROPE: NORTHERN'),
   (7, 'EUROPE: SOUTHERN'),
   (8, 'EUROPE: WESTERN');


SET dev_added_new_UC_regions = LAST_QUERY_ID();

SELECT * FROM restored_region;


-- 4.5.3   Compare the restored_region table with the original.

SELECT * FROM restored_region
MINUS
SELECT * FROM region AT(timestamp=>$dev_before_changes);

--         You can also compare the tables with a JOIN:

SELECT 
   o.r_regionkey AS original_key,
   o.r_name AS original_name,
   n.r_regionkey AS new_key,
   n.r_name AS new_name
FROM 
   restored_region n
FULL JOIN
   region AT(timestamp=>$dev_before_changes) o
ON 
   o.r_regionkey = n.r_regionkey
ORDER BY
   original_key, 
   new_key;


-- 4.5.4   Drop the table region and rename restored_region to region.

DROP TABLE region;

ALTER TABLE
   restored_region
RENAME TO
   region;

SELECT * FROM region;

--         Congratulations! You now have a region table that meets the
--         requirements you’ve been given.

-- 4.5.5   Suspend your virtual warehouse.

ALTER WAREHOUSE LEARNER_wh SUSPEND;

--         The SUSPEND statement will generate an error message if your virtual
--         warehouse is already suspended. You can safely ignore this message.

-- 4.6.0   Key Takeaways
--         - With Time Travel, you can go back in time to see how data looked or
--         to compare it to current data to find changes.
--         - Extensions for Time Travel include BEFORE and AT.
--         - You can recover earlier versions of a table using a combination of
--         cloning and Time Travel.
--         - The UNDROP command allows you to quickly recover tables, schemas,
--         or databases that have been dropped.
--         - You can use Time Travel in JOINs.

-- 4.7.0   Return to the Lab Exercise Page in the Course and Click the Mark as
--         complete Button
