
-- 17.0.0  Creating, Starting, and Stopping a Task
--         This lab has two parts. In Part I, you will create, start, and stop a
--         single task. In Part II, you will create a root task with a child
--         task.
--         - Create tasks.
--         - Run tasks on a schedule or immediately.
--         - Use functions to view task successes and failures.
--         - Troubleshoot task failures.
--         - Create root and child tasks.
--         This lab should take you approximately 20 minutes to complete.
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

-- 17.1.0  Part I - Create, Start, and Stop a Single Task
--         You’ve been asked to find a way to aggregate daily sales totals from
--         the ORDERS table into a single table and time stamp each row at the
--         time of insertion.
--         You’ve decided to implement a task in order to satisfy this request.
--         Tasks left running unsupervised can consume credits. In your training
--         account, it is CRUCIAL that you suspend any tasks you create. Failure
--         to do so could result in your practice account consuming all
--         available trial credits, and locking you out of your Snowflake
--         account before you complete the course.

-- 17.1.1  Set your context.

USE ROLE TRAINING_ROLE;

CREATE WAREHOUSE IF NOT EXISTS LEARNER_WH;
USE WAREHOUSE LEARNER_WH;

CREATE DATABASE IF NOT EXISTS LEARNER_DB;
USE DATABASE LEARNER_DB;

CREATE OR REPLACE SCHEMA LEARNER_DB.TASKS_SCHEMA;
USE SCHEMA LEARNER_DB.TASKS_SCHEMA;


-- 17.1.2  Take a look at the ORDERS table.

SELECT 
      *
FROM 
      SNOWBEARAIR_DB.PROMO_CATALOG_SALES.ORDERS
ORDER 
      BY O_ORDERDATE;

--         As you can see, there are many orders for each day. The column we
--         wish to aggregate on is O_TOTALPRICE.
--         In order to satisfy the request, your table only needs the date for
--         the orders that were aggregated, the aggregated value for
--         O_TOTALPRICE, and a time stamp. Create a table that will store those
--         three values.

-- 17.1.3  Create a table to store the aggregated values.

CREATE OR REPLACE TABLE DAILY_SUM_OF_ORDERS 
   (ORDER_DATE DATE, SUM_OF_ORDER_TOTALS DECIMAL(18,2), TS TIMESTAMP);


-- 17.1.4  Run the statement below to create the task.
--         The WHERE clause in the query below searches the aggregations table
--         first to ensure that a row hasn’t already been inserted. The query
--         also adds a field for the timestamp.
--         Also, note that the schedule is two minutes. In a production setting,
--         you would schedule the task to run daily and would probably use a
--         CRON statement to schedule the execution for a specific time. Our
--         source table ORDERS would also be dynamic, and new rows would be
--         updated daily. Since our ORDERS table is static and we don’t have
--         days to verify the task is running the way we want, we’re going to
--         schedule the task to run every minute so we can see the results in a
--         reasonable amount of time.
--         The query uses a LIMIT value of 1, thus every time the task runs, one
--         order date is picked up for aggregation.

CREATE OR REPLACE TASK LOAD_DAILY_SUM_OF_ORDERS
    WAREHOUSE = 'LEARNER_WH'
    SCHEDULE = '2 MINUTES'
AS    
    INSERT INTO DAILY_SUM_OF_ORDERS
    SELECT O_ORDERDATE AS ORDER_DATE, SUM(O_TOTALPRICE) AS SUM_ORDER_PRICE, CURRENT_TIMESTAMP() AS TS
    FROM SNOWBEARAIR_DB.PROMO_CATALOG_SALES.ORDERS 
    WHERE O_ORDERDATE NOT IN (SELECT ORDER_DATE FROM DAILY_SUM_OF_ORDERS) 
    GROUP BY O_ORDERDATE 
    ORDER BY O_ORDERDATE
    LIMIT 1;


-- 17.1.5  View the details of the task

DESCRIBE TASK LOAD_DAILY_SUM_OF_ORDERS;

--         In the results pane, observe that the state of the task is suspended.

-- 17.1.6  Resume the task and view its details.

-- Start Root Task

ALTER TASK LOAD_DAILY_SUM_OF_ORDERS RESUME;

-- View task details

DESCRIBE TASK LOAD_DAILY_SUM_OF_ORDERS;

--         In the results pane, observe that the state of the task is now
--         started. The task will be executed based on its specified schedule.

-- 17.1.7  Execute the task immediately.

-- Kick Off Root Task Immediately

EXECUTE TASK LOAD_DAILY_SUM_OF_ORDERS;


-- 17.1.8  View the task history to observe the state of the task.

SELECT 
   * 
FROM 
   TABLE(information_schema.task_history())
WHERE database_name = 'LEARNER_DB';


-- 17.1.9  Observe progress over the next five minutes.
--         Use the two select statements below to ensure your table populated as
--         expected. By checking the task history, you can see whether the task
--         succeeds or fails each time it executes.

-- Verify that the table is being populated

SELECT * FROM DAILY_SUM_OF_ORDERS DESC;  

SELECT 
   * 
FROM 
   TABLE(information_schema.task_history())
WHERE database_name = 'LEARNER_DB';


-- 17.1.10 Suspend and drop the task to make sure it does not continue to run.

-- Suspend the task

ALTER TASK LOAD_DAILY_SUM_OF_ORDERS SUSPEND;

-- Drop the task

DROP TASK LOAD_DAILY_SUM_OF_ORDERS;

-- Verify the task is gone

SHOW TASKS;

--         Tasks left running unsupervised can consume credits. Make sure you
--         have run the ALTER TASK…SUSPEND and DROP statements to stop your
--         task. Failure to do so could result in all credits being consumed. If
--         that happens, you will be locked out of your Snowflake account and
--         unable to perform any more exercises.

-- 17.2.0  Part II - Create a Root Task with Child Tasks
--         Snowbear Air gathers information on competing airlines on a quarterly
--         basis. The US Operations team uses information on other airlines
--         based in the United States. The New Business team is investigating
--         the feasibility of adding some flights to popular diving destinations
--         and wants information on airlines in the Bahamas, the Cayman Islands,
--         and Turks and Caicos.
--         You have been asked to automate the loading and transforming of this
--         data about competing airlines and allocate the necessary information
--         into tables for the US Operations and New Business teams.
--         You decide to create a schema that will contain all your tasks and
--         another schema to hold the tables that are generated. Before you
--         start writing your tasks, set up your development environment.

-- 17.2.1  Set your context.

USE ROLE training_role;

CREATE DATABASE IF NOT EXISTS LEARNER_db;

CREATE WAREHOUSE IF NOT EXISTS LEARNER_wh INITIALLY_SUSPENDED=true;
USE WAREHOUSE LEARNER_wh;


-- 17.2.2  Create your new schemas.

CREATE SCHEMA LEARNER_db.airline_tasks;
CREATE SCHEMA LEARNER_db.airline_data;


-- 17.2.3  Create a table for staging new data.
--         Create this staging table in your airline_data schema.

CREATE OR REPLACE TRANSIENT TABLE LEARNER_db.airline_data.staging (
    country VARCHAR,
    region VARCHAR,
    name VARCHAR,
    code1 VARCHAR(5),
    code2 VARCHAR(5),
    founded INTEGER,
    alliance VARCHAR);


-- 17.2.4  Create the tables that will hold the collected data.
--         These will also reside in the airline_data schema.

CREATE OR REPLACE TABLE LEARNER_db.airline_data.us_airlines (
   country VARCHAR,
   region VARCHAR,
   name VARCHAR, 
   alliance VARCHAR);
           
CREATE OR REPLACE TABLE LEARNER_db.airline_data.dive_destinations (
   country VARCHAR,
   name VARCHAR);


-- 17.2.5  Set your context to use the tasks schema.

USE LEARNER_db.airline_tasks;


-- 17.2.6  Create a root task to copy data into the staging table.
--         Ultimately, your tasks will run once per quarter, but you want it to
--         run more frequently than that for testing purposes. So, create the
--         task and have it run every minute.

CREATE TASK load_staging_table
   WAREHOUSE = 'LEARNER_WH'
   SCHEDULE = '1 minute'
AS
   COPY INTO 
      LEARNER_db.airline_data.staging
   FROM 
      @training_db.traininglab.datasets_stage/sba_data/airline_info/airlines.csv;


-- 17.2.7  Create a child task to merge information on US airlines.
--         Once the staging table is loaded with the new data, this task will
--         take selected columns from the staging table and merge them into the
--         us_airlines table. Using the MERGE command will ensure duplicate
--         records are not loaded into the us_airlines table and that no records
--         where the name column is NULL are loaded.

CREATE TASK load_us_airlines
   WAREHOUSE = 'LEARNER_WH'
   AFTER load_staging_table
AS 
   MERGE INTO LEARNER_db.airline_data.us_airlines u
   USING LEARNER_db.airline_data.staging s
   ON u.name = s.name
   WHEN NOT MATCHED AND s.country = 'United States' AND s.name IS NOT NULL
   THEN
   INSERT (country, region, name, alliance)
   VALUES (s.country, s.region, s.name, s.alliance);


-- 17.2.8  Create a child task to insert information about dive destinations.
--         This task will also start after the load of the staging table has
--         been completed. Note that you are doing an insert instead of a merge
--         in this task.

CREATE TASK load_dive_destinations
   WAREHOUSE = 'LEARNER_WH'
   AFTER load_staging_table
AS
   INSERT INTO LEARNER_db.airline_data.dive_destinations (country, name)
   SELECT country, name
   FROM LEARNER_db.airline_data.staging
   WHERE country IN ('Bahamas', 'Cayman Islands', 'Turks and Caicos Islands');
  


-- 17.2.9  Create a task to truncate the staging table.
--         Once the destination tables have been successfully updated, truncate
--         the staging table so it is ready for the next task run.

CREATE TASK truncate_staging_table
   WAREHOUSE = 'LEARNER_WH'
   AFTER load_dive_destinations, load_us_airlines
AS
   TRUNCATE TABLE LEARNER_db.airline_data.staging;

--         This task has two predecessor tasks: load_dive_destinations and
--         load_us_airlines. This task will only run if BOTH of the predecessor
--         tasks complete successfully.

-- 17.2.10 Verify that all your tasks have been created.

SHOW TASKS;


-- 17.2.11 Check the dependencies of the root task (load_staging_table):

SELECT 
   *
FROM 
   TABLE(information_schema.task_dependents
   (task_name => 'LEARNER_db.airline_tasks.load_staging_table'));

--         By default, the task_dependents function will show direct children of
--         the root task, as well as any descendants of the children. If you
--         only want to see the direct children, run this function with
--         RECURSIVE set to FALSE.
--         The function also returns a column, PREDECESSORS, that contains the
--         list of predecessor tasks for a child task in a DAG.

-- 17.2.12 View only the direct children of the root task.

SELECT 
   *
FROM 
   TABLE(information_schema.task_dependents
   (task_name => 'LEARNER_db.airline_tasks.load_staging_table', RECURSIVE => FALSE));

--         When you create a task, it is created in a suspended state. Before
--         the root task will run on a schedule, it must be resumed. If you have
--         child tasks, the children should be resumed BEFORE the root task.

-- 17.2.13 Enable all the tasks.

SELECT SYSTEM$TASK_DEPENDENTS_ENABLE('LEARNER_db.airline_tasks.load_staging_table');

--         Using this function will enable (resume) your root task and all of
--         its child tasks, recursively. Especially with many children (and
--         grandchildren, etc.), using this function is much faster than
--         resuming all the child tasks individually.

-- 17.2.14 Execute the root task immediately.

EXECUTE TASK load_staging_table;


-- 17.2.15 Verify that your task has started.

SELECT 
   * 
FROM 
   TABLE(information_schema.task_history())
WHERE database_name = 'LEARNER_DB' AND schema_name = 'AIRLINE_TASKS';


-- 17.2.16 Wait for the next run of the root task to start on its schedule.
--         Check the status until you see a second run of the root task shown.
--         Keep running the command below until all tasks have completed at
--         least twice.

SELECT 
   * 
FROM 
   TABLE(information_schema.task_history())
WHERE database_name = 'LEARNER_DB' AND schema_name = 'AIRLINE_TASKS';


-- 17.2.17 Check your tables to see if information has been added.
--         If your staging table is empty, that’s because the
--         truncate_staging_table has run, but the load_staging_table task has
--         not yet been re-run. Check again in a few seconds.

SELECT * FROM LEARNER_db.airline_data.staging;

SELECT * FROM LEARNER_db.airline_data.us_airlines
ORDER BY name;

SELECT * FROM LEARNER_db.airline_data.dive_destinations
ORDER BY name;

--         Notice that there are duplicate entries in the dive_destinations
--         table but not in the us_airlines table. That is because you did an
--         INSERT with dive_destinations, but a MERGE with us_airlines. Now, you
--         need to fix this issue.

-- 17.2.18 Suspend the root task.
--         Before you can do any work on a child task, you need to suspend the
--         root task. You do not need to suspend the child tasks.

ALTER TASK load_staging_table SUSPEND;


-- 17.2.19 Truncate the dive_destinations table.

TRUNCATE TABLE LEARNER_db.airline_data.dive_destinations;


-- 17.2.20 Replace the load_dive_destinations task with one that uses MERGE.

CREATE OR REPLACE TASK load_dive_destinations
   WAREHOUSE = 'LEARNER_WH'
   AFTER load_staging_table
AS
   MERGE INTO LEARNER_db.airline_data.dive_destinations d
   USING LEARNER_db.airline_data.staging s
   ON d.name = s.name
   WHEN NOT MATCHED 
      AND s.country IN ('Bahamas', 'Cayman Islands', 'Turks and Caicos Islands')
      AND s.name IS NOT NULL
   THEN
      INSERT (country, name)
      VALUES (s.country, s.name);


-- 17.2.21 Resume the load_dive_destinations task.

ALTER TASK load_dive_destinations RESUME;


-- 17.2.22 Resume the root task.

ALTER TASK load_staging_table RESUME;


-- 17.2.23 Execute the root task immediately.

EXECUTE TASK load_staging_table;

--         When developing or troubleshooting tasks, it can be helpful to
--         execute the task immediately rather than waiting for the task to
--         start on its regular schedule.

-- 17.2.24 Check the status of your task.
--         Use the following command to make sure your root task is running:

SELECT 
   * 
FROM 
   TABLE(information_schema.task_history())
WHERE database_name = 'LEARNER_DB' AND schema_name = 'AIRLINE_TASKS';


-- 17.2.25 Select from the destination tables.
--         You want to verify that your dive_destinations table is no longer
--         getting duplicate records. Wait until the root task has been
--         completed at least twice, then select from the tables.

SELECT * FROM LEARNER_db.airline_data.staging;

SELECT * FROM LEARNER_db.airline_data.us_airlines
ORDER BY name;

SELECT * FROM LEARNER_db.airline_data.dive_destinations
ORDER BY name;

--         Notice that the rows in dive_destinations are no longer duplicated.

-- 17.2.26 Drop the us_airlines table.
--         This will introduce an error into your task run.

DROP TABLE LEARNER_db.airline_data.us_airlines;


-- 17.2.27 Wait until the load_us_airlines task fails.

SELECT 
   * 
FROM 
   TABLE(information_schema.task_history())
WHERE 
   state = 'FAILED';


-- 17.2.28 Look at the status of all tasks.

SELECT 
   * 
FROM 
   TABLE(information_schema.task_history())
WHERE database_name = 'LEARNER_DB' AND schema_name = 'AIRLINE_TASKS';

--         The truncate_staging_table task did not run. The history does not
--         show it as a failure; it just skips the run of that child task. This
--         is because one of the predecessor tasks failed. In order for a child
--         task to run, ALL its predecessor tasks must be completed
--         successfully.

-- 17.2.29 Review failed tasks.

SELECT 
   root_task_name, state, first_error_task_name, first_error_message
FROM 
   table(information_schema.complete_task_graphs(
      ROOT_TASK_NAME => 'LOAD_STAGING_TABLE', ERROR_ONLY => TRUE))
WHERE 
   database_name = 'LEARNER_DB';

--         You may not see data returned from this query, as there is some
--         latency before the snowflake.account_usage schema is updated.

-- 17.2.30 Suspend the root task.

ALTER TASK load_staging_table SUSPEND;

--         Once the root task has been suspended, none of the child tasks will
--         run.

-- 17.2.31 Drop the schemas you created.

DROP SCHEMA LEARNER_db.airline_tasks;
DROP SCHEMA LEARNER_db.airline_data;

--         If the root task was still active, you could not drop the schema
--         containing the task.

-- 17.2.32 Suspend your virtual warehouse.

ALTER WAREHOUSE LEARNER_wh SUSPEND;

--         In normal production, your virtual warehouse will auto-suspend after
--         some amount of idle time. You manually suspend the virtual warehouse
--         here to save some compute credits.

-- 17.3.0  Key Takeaways
--         - The commands to start or stop a task are ALTER TASK <task name>
--         RESUME and ALTER TASK <task name> SUSPEND.
--         - To immediately start a task, the command is EXECUTE TASK <task
--         name>.
--         - You can use the table function information_schema.task_history() to
--         query the history of task execution.
--         - If you have child tasks, the children should be resumed BEFORE the
--         root task.
--         - You can use SELECT SYSTEM$TASK_DEPENDENTS_ENABLE(<task name>) to
--         resume a root task and all dependent tasks in your DAG, using just
--         one statement.
--         - It is imperative to stop a task you no longer need to avoid
--         unnecessary credit consumption.

-- 17.4.0  Return to the Lab Exercise Page in the Course and Click the Mark as
--         complete Button
