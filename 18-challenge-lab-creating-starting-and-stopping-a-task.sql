
-- 18.0.0  Challenge Lab: Creating, Starting, and Stopping a Task
--         The purpose of this lab is to give you an opportunity to practice
--         creating and executing tasks.
--         - Create a task.
--         - Start a task.
--         - Use table function information_schema.task_history() to monitor
--         tasks.
--         - Stop a task.
--         This lab should take you approximately 25 minutes to complete.
--         Imagine that there is a table that stores the average time from
--         shipping to delivery for all orders in a specific month and year.
--         Let’s imagine that the order and shipping data are updated every
--         minute. This means that you need to update the table every minute.
--         In this exercise, you’re going to write a task that updates the
--         contents of the table every minute.
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
--         Tasks left running unsupervised can consume credits. In your training
--         account, it is CRUCIAL that you suspend any tasks you create. Failure
--         to do so could result in your practice account consuming all
--         available trial credits, and locking you out of your Snowflake
--         account before you complete the course.
--         Let’s get started!

-- 18.1.0  Create and Execute a Task

-- 18.1.1  Create a new schema called LEARNER_DB.TASKS_SCHEMA, and set your
--         context.

-- 18.1.2  Create the table that will hold the average shipping time in days.

CREATE OR REPLACE TABLE AVG_SHIPPING_IN_DAYS(
      yr INTEGER,
      mon INTEGER,
      avg_shipping_days DECIMAL(18,2)
);


-- 18.1.3  Create the task.
--         - You should use INSERT OVERWRITE in your task.
--         - Your CRON expression will be: USING CRON 0-59 0-23 * * *
--         America/Chicago.
--         Here is the query you will embed in your task

    SELECT
          YEAR(F.O_ORDERDATE) AS YR,
          MONTH(F.O_ORDERDATE) AS MON,
          AVG (DAYS_TO_SHIP)::DECIMAL(18,2) AS AVG_DAYS_TO_SHIP
    FROM        
        (
            SELECT 
                      O_ORDERDATE,
                      L_SHIPDATE,
                      L_SHIPDATE - O_ORDERDATE AS DAYS_TO_SHIP
            FROM
                    SNOWBEARAIR_DB.PROMO_CATALOG_SALES.ORDERS O 
                    LEFT JOIN SNOWBEARAIR_DB.PROMO_CATALOG_SALES.LINEITEM L ON O.O_ORDERKEY = L.L_ORDERKEY
         ) AS F 

    GROUP BY YR, MON

    ORDER BY YR, MON;


-- 18.1.4  Show the task to ensure it got created correctly.

-- 18.1.5  Start the task and confirm it has been started.

-- 18.1.6  Check the table for data. It may take up to a minute to see it in the
--         table.

-- 18.1.7  View task history for the task.

SELECT *
  FROM table(information_schema.task_history(
    scheduled_time_range_start=>dateadd('hour',-1,current_timestamp())));


-- 18.1.8  Suspend the task and verify that it has been suspended.
--         Use ALTER TASK <task name> SUSPEND to suspend the task.

-- 18.1.9  Drop the schema you created for this lab.
--         Dropping the schema will also drop the task that is in the schema.

-- 18.1.10 Suspend your virtual warehouse.

ALTER WAREHOUSE LEARNER_WH SUSPEND;

--         If you need help, the solution is on the next page. Otherwise,
--         congratulations! You have now completed this lab.

-- 18.2.0  Solution
--         If you need to, you can look at the solution below. But try not to
--         peek! You’ll learn more if you try it on your own first and rely only
--         on the hints.

-- 18.2.1  Set the context.

USE ROLE TRAINING_ROLE;

CREATE DATABASE IF NOT EXISTS LEARNER_DB;
USE DATABASE LEARNER_DB;

CREATE WAREHOUSE IF NOT EXISTS LEARNER_WH;
USE WAREHOUSE LEARNER_WH;

CREATE SCHEMA IF NOT EXISTS LEARNER_DB.TASKS_SCHEMA;
USE SCHEMA LEARNER_DB.TASKS_SCHEMA;

ALTER WAREHOUSE LEARNER_WH SET WAREHOUSE_SIZE = XSmall;


-- 18.2.2  Create the table that will hold the average shipping time in days.
--         Run the CREATE statement below to create the table for average
--         shipping time in days. Also, execute the DESCRIBE TABLE statement to
--         see the details about the table’s structure.

CREATE OR REPLACE TABLE AVG_SHIPPING_IN_DAYS(
      yr INTEGER,
      mon INTEGER,
      avg_shipping_days DECIMAL(18,2)
);

DESCRIBE TABLE avg_shipping_in_days;

--         As you can see, it is a simple table that stores the year, month, and
--         average shipping days in decimal format.

-- 18.2.3  Create the task.
--         This task will calculate and load the data from the orders and
--         lineitem tables into the target table. Notice that we do an INSERT
--         OVERWRITE. This essentially overwrites the table each time the task
--         runs.

CREATE OR REPLACE TASK insert_shipping_by_date_rows
    WAREHOUSE = 'LEARNER_WH'
    SCHEDULE = 'USING CRON 0-59 0-23 * * * America/Chicago'
AS    
    INSERT OVERWRITE INTO LEARNER_DB.TASKS_SCHEMA.AVG_SHIPPING_IN_DAYS (yr, mon, avg_shipping_days)
    SELECT
          YEAR(F.O_ORDERDATE) AS YR,
          MONTH(F.O_ORDERDATE) AS MON,
          AVG (DAYS_TO_SHIP)::DECIMAL(18,2) AS AVG_DAYS_TO_SHIP
    FROM        
        (
            SELECT 
                      O_ORDERDATE,
                      L_SHIPDATE,
                      L_SHIPDATE - O_ORDERDATE AS DAYS_TO_SHIP
            FROM
                    SNOWBEARAIR_DB.PROMO_CATALOG_SALES.ORDERS O 
                    LEFT JOIN SNOWBEARAIR_DB.PROMO_CATALOG_SALES.LINEITEM L ON O.O_ORDERKEY = L.L_ORDERKEY
         ) AS F 

    GROUP BY YR, MON
    ORDER BY YR, MON;

--         Notice that the schedule is set to run every minute of every hour.
--         However, we only need this task to run once for our purposes.

-- 18.2.4  Show the task to ensure it got created correctly.

SHOW TASKS;


-- 18.2.5  Start the task and verify that it has been started.


ALTER TASK insert_shipping_by_date_rows RESUME;

DESCRIBE TASK INSERT_SHIPPING_BY_DATE_ROWS;



-- 18.2.6  Check the table for data.
--         It may take up to a minute to see any data in the table.

SELECT * 
FROM avg_shipping_in_days;


-- 18.2.7  View task history for the task.
--         Here, you can see instances where the task was scheduled, ran and
--         succeeded, or ran and failed.

SELECT *
  FROM table(information_schema.task_history(
    scheduled_time_range_start=>dateadd('hour',-1,current_timestamp())));


-- 18.2.8  Suspend the task and verify that it has been suspended.

ALTER TASK insert_shipping_by_date_rows SUSPEND;

DESCRIBE TASK INSERT_SHIPPING_BY_DATE_ROWS;


-- 18.2.9  Drop the schema you created for this lab.

DROP SCHEMA TASKS_SCHEMA;


-- 18.2.10 Suspend your virtual warehouse.

ALTER WAREHOUSE LEARNER_WH SUSPEND;


-- 18.3.0  Return to the Lab Exercise Page in the Course and Click the Mark as
--         complete Button
