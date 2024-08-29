
-- 24.0.0  Challenge Lab: Monitoring Billing and Usage
--         The purpose of this lab is to give you an on-your-own experience
--         creating dashboards that can be used to monitor usage and billing.
--         In the first part of this two-part exercise, you’ll write queries
--         using the QUERY_HISTORY view in the SNOWFLAKE.ACCOUNT_USAGE schema
--         and use them to create a dashboard for monitoring query execution
--         statistics.
--         In the second part, we’ll give you queries that use the
--         QUERY_HISTORY, METERING_HISTORY, STORAGE_USAGE, and
--         WAREHOUSE_METERING_HISTORY views, and you’ll create your own
--         dashboard for monitoring credit usage.
--         Solutions for both Part I and Part II are included at the end of this
--         lab.
--         - Create a dashboard.
--         - Add tiles to a dashboard.
--         - Add filters to a dashboard.
--         - Create a bar chart.
--         - Write basic queries using the QUERY_HISTORY view in the
--         SNOWFLAKE.ACCOUNT_USAGE schema.
--         - Apply an existing custom filter to a query in a dashboard.
--         This lab should take you approximately 30 minutes to complete.
--         HOW TO COMPLETE THIS LAB
--         In the previous lab, you may have created a new worksheet, loaded the
--         SQL file for the lab, and then followed the instructions contained in
--         the file without ever looking at the workbook PDF. That approach will
--         be modified due to the nature of this exercise.
--         First, you will need to open the workbook PDF to follow the
--         instructions. Next, you will need to open the SQL file for this lab
--         using the text editor of your choice. This will make it easy for you
--         to copy and paste code from the file into your dashboard.
--         Copying and pasting from the workbook PDF will result in errors!
--         Also, importing the entire file into a single tile’s worksheet means
--         all the queries from the sheet will be executed when the tile gets
--         refreshed, which will negatively impact performance. The best
--         approach is to put code in each tile’s worksheet is to open the SQL
--         file in the text editor of your choice and copy and paste from there.
--         Turn to the next page to get started!

-- 24.1.0  Part I - Create a Dashboard for Monitoring Query Execution Statistics
--         In this part of the exercise, you’ll write your own queries for the
--         scenario described below.
--         The administration team for Snowbear Air has assigned you to create a
--         dashboard that can be used to monitor query execution statistics.
--         Specifically, the dashboard needs to display the following:
--         - The maximum run time in seconds for queries run in the last four
--         days.
--         - The minimum run time in milliseconds for queries run in the last
--         four days.
--         - The median run time time in milliseconds for queries run the last
--         four days.
--         - The five longest query run times in the last four days and the user
--         who ran those queries.
--         - The five fastest queries in the last four days and the text from
--         those queries.
--         - A bar chart that displays the total number of queries over the last
--         four days.
--         The queries should omit all rows where the EXECUTION_TIME = 0 AND THE
--         USER_NAME = SYSTEM.
--         The dashboard should also have a date range filter.
--         Let’s get started!

-- 24.1.1  Set your context.
--         For this lab, you will use SNOWFLAKE.ACCOUNT_USAGE for your database
--         and schema.

USE ROLE TRAINING_ROLE;

CREATE WAREHOUSE IF NOT EXISTS LEARNER_WH INITIALLY_SUSPENDED=TRUE;
USE WAREHOUSE LEARNER_WH;

USE SCHEMA SNOWFLAKE.ACCOUNT_USAGE;


-- 24.1.2  Look at the expected result below.
--         Your dashboard should look similar to the one shown below. The three
--         labeled numeric panels at the top of the dashboard are tiles that are
--         produced by, running a query that produces a single number, and
--         displaying the result in a chart with Chart type set to Scorecard.
--         The numbers that appear in your charts may differ from what is shown
--         in this screenshot.

-- 24.1.3  Read through the hints below before getting started.
--         There are two ways to add tiles to a dashboard: The + New Tile button
--         in the center of a new, empty dashboard and the + button just below
--         the home button.
--         You can click on a tile and hold down the mouse button to reposition
--         tiles.
--         You will need to select a role and virtual warehouse before any of
--         the code in the worksheets will run.
--         In each worksheet, you’ll need to select the database and schema
--         before any code will run.
--         To order the bars in a bar chart, select Ascending or Descending in
--         Order Direction in the bar chart menu.
--         Check the solution if you’re having trouble writing your queries.
--         Now that you’ve reviewed all the instructions and hints above, let’s
--         create the dashboard!

-- 24.1.4  Open the workbook PDF if you haven’t done so already.

-- 24.1.5  Open the SQL file in the text editor of your choice if you haven’t
--         done so already.

-- 24.1.6  Create a new dashboard.

-- 24.1.7  Write your queries.
--         Put each query in a separate tile. Make sure to set the context for
--         the database and schema to be used (database SNOWFLAKE and schema
--         ACCOUNT_USAGE).
--         Since we want to adjust the dashboard using the date range filter
--         button, make sure to specify the :daterange filter in the WHERE
--         clause of each of your queries.
--         Don’t worry if your queries aren’t perfect or if your final dashboard
--         isn’t exactly like the example above. The point of this exercise is
--         for you to become familiar with the QUERY_HISTORY view and for you to
--         practice creating a dashboard. While the queries required here are a
--         bit simplistic, try to grasp the overall concept of using the data in
--         the view to create a dashboard that can be used for monitoring query
--         execution.
--         If the dashboard looks the way you intended, then great! If not, a
--         suggested solution can be found at the end of this lab.
--         Congratulations! You have now completed Part I of this lab! Go to the
--         next page to continue to Part II.

-- 24.2.0  Part II - Create a Dashboard for Monitoring Credit Usage
--         You’ll use the queries we provide for the scenario below.
--         The administration team for Snowbear Air has assigned you to create a
--         dashboard that can be used to monitor credit usage on its Snowflake
--         account. Specifically, the dashboard needs to display:
--         - Credits used
--         - Total number of queries executed
--         - Current storage used in terabytes
--         - Credit usage by virtual warehouse
--         - The total number of queries broken out by virtual warehouse
--         - A bar chart showing credit usage day-by-day
--         The dashboard should also have a date range filter.
--         Let’s get started!

-- 24.2.1  Look at the expected result below before getting started.
--         Your dashboard should look similar to the one shown below.
--         The numbers that appear in your charts may differ from what is shown
--         in this screenshot.
--         You will need to set your context as follows:
--         - Role: TRAINING_ROLE
--         - Virtual Warehouse: LEARNER_WH
--         - Database: SNOWFLAKE
--         - Schema: ACCOUNT_USAGE
--         Read through the hints below before getting started.
--         There are two ways to add tiles to a dashboard: The + New Tile button
--         in the center of a new, empty dashboard and the + button just below
--         the home button.
--         You can click on a tile and hold down the mouse button to reposition
--         tiles.
--         You will need to select a role and virtual warehouse before any of
--         the code in the worksheets will run.
--         In each worksheet, you’ll need to select the database and schema
--         before any code will run.
--         To order the bars in a bar chart, select Ascending or Descending in
--         Order Direction in the bar chart parameter.
--         Now that you’ve reviewed all the instructions and hints above, let’s
--         create the dashboard!

-- 24.2.2  Open the workbook PDF if you haven’t done so already.

-- 24.2.3  Open the SQL file in the text editor of your choice if you haven’t
--         done so already.

-- 24.2.4  Create a new dashboard.
--         Place each of the six queries below into the worksheet of each new
--         dashboard tile you create.
--         Make sure to set the database to SNOWFLAKE and the schema to
--         ACCOUNT_USAGE.
--         As you create each new tile, put the appropriate query into the
--         worksheet and run the query. If you are going to create a chart in
--         the tile, then click the Chart button after running the query.

-------------------
-- Query 1 of 6
-- Credits Used
-------------------

SELECT
    SUM(credits_used)
FROM
    account_usage.metering_history
WHERE
    start_time = :daterange;

-------------------
-- Query 2 of 6
-- Total Number of Queries Executed
-------------------

SELECT
    COUNT(*) AS number_of_jobs
FROM
    account_usage.query_history
WHERE
    start_time = :daterange
    and is_client_generated_statement = false;

-------------------
-- Query 3 of 6
-- Current Storage
-------------------

SELECT
    AVG(storage_bytes + stage_bytes + failsafe_bytes) / POWER(1024, 4) AS billable_tb
FROM
    account_usage.storage_usage
WHERE
    usage_date = current_date() -1;

-------------------
-- Query 4 of 6
-- Credit Usage by Virtual Warehouse
-------------------

SELECT
    warehouse_name,
    sum(credits_used) as total_credits_used
FROM
    account_usage.warehouse_metering_history
WHERE
    start_time = :daterange   
GROUP BY
    1
ORDER BY
    2 DESC;

-------------------
-- Query 5 of 6
-- Number of Queries by Virtual Warehouse
-------------------

SELECT warehouse_name,
    COUNT(*) AS number_of_jobs
FROM
    account_usage.query_history
WHERE
    start_time = :daterange
    and is_client_generated_statement = false
GROUP BY 
    warehouse_name;

-------------------
-- Query 6 of 6
-- Credit Usage Over Time
-------------------

SELECT
    start_time::date AS usage_date,
    warehouse_name,
    sum(credits_used) AS total_credits_used
FROM
    account_usage.warehouse_metering_history
WHERE
    start_time = :daterange    
GROUP BY
    1,
    2
ORDER BY
    2,
    1;


-- 24.2.5  Select a value for :daterange and click the Apply button.

-- 24.2.6  View the results.
--         If the dashboard looks the way you intended, then great! If not, a
--         suggested solution can be found at the end of this lab.

-- 24.2.7  Congratulations! You have finished Part II of this lab.

-- 24.3.0  Solution for Part I Queries


--------------------
-- QUERY 1 OF 6
-- MAXIMUM RUN TIME 
-- FOR THE LAST FOUR DAYS
-- IN SECONDS
--------------------     

SELECT 
    MAX(COMPILATION_TIME + EXECUTION_TIME)/1000 AS MAX_RUN_TIME_IN_SEC
    
FROM
    SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY QH
    
WHERE
    USER_NAME <> 'SYSTEM'
    AND
    DATE(QH.START_TIME) = :daterange
    AND
    COMPILATION_TIME + EXECUTION_TIME <>0;    

--------------------
-- QUERY 2 OF 6
-- MINIMUM RUN TIME 
-- FOR THE LAST FOUR DAYS
-- IN MILLISECONDS
--------------------

SELECT 
    MIN(COMPILATION_TIME + EXECUTION_TIME) AS MIN_RUN_TIME_IN_MS
    
FROM
    SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY QH
    
WHERE
    DATE(QH.START_TIME) = :daterange 
    AND
    USER_NAME <> 'SYSTEM'    
    AND
    COMPILATION_TIME + EXECUTION_TIME <>0;

--------------------
-- QUERY 3 OF 6
-- MEDIAN RUN TIME TIME
-- FOR THE LAST FOUR DAYS
-- IN MILLISECONDS
--------------------

SELECT 
    MEDIAN(COMPILATION_TIME + EXECUTION_TIME) AS MED_EXECUTION_TIME_MS
    
FROM
    SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY QH
    
WHERE
    DATE(QH.START_TIME) = :daterange 
    AND
    USER_NAME <> 'SYSTEM'    
    AND
    EXECUTION_TIME <>0;
    
--------------------
-- QUERY 4 OF 6
-- TOP FIVE RUN TIMES
-- IN MILLISECONDS
-- FOR THE LAST FOUR DAYS
--------------------
  
SELECT 
    QH.USER_NAME,
    QH.COMPILATION_TIME + QH.EXECUTION_TIME AS RUN_TIME_MS
    
FROM
    SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY QH
    
WHERE
    DATE(QH.START_TIME) = :daterange 
    AND
    EXECUTION_TIME <> 0
    AND
    USER_NAME <> 'SYSTEM'
ORDER BY 
    RUN_TIME_MS DESC
LIMIT 5;
       
--------------------
-- QUERY 5 OF 6
-- TOP FIVE FASTEST QUERIES
-- BY AVERAGE RUN TIME
--------------------

SELECT 
    QH.QUERY_TEXT,
    AVG(QH.COMPILATION_TIME + QH.EXECUTION_TIME) AS AVG_RUN_TIME
    
FROM
    SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY QH
    
WHERE
    DATE(QH.START_TIME) = :daterange 
    AND
    EXECUTION_TIME <>0
    AND
    USER_NAME <> 'SYSTEM'  
GROUP BY
    QH.QUERY_TEXT
    
ORDER BY 
    AVG_RUN_TIME ASC
    
LIMIT 5;

--------------------
-- QUERY 6 OF 6
-- NUMBER OF QUERIES
-- RUN PER DAY
-------------------- 
SELECT
    DATE(QH.START_TIME) AS QUERY_DATE,
    COUNT(*) AS QUERY_COUNT
FROM
    SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY QH
    
WHERE
    DATE(QH.START_TIME) = :daterange 
    AND
    EXECUTION_TIME <>0
    AND
    USER_NAME <> 'SYSTEM'
GROUP BY
    QUERY_DATE
    
ORDER BY 
    QUERY_DATE DESC
    
LIMIT 5;


-- 24.4.0  Solution to Create a Dashboard (Parts I and II)
--         The steps below show you how to create a dashboard from scratch. If
--         you have a worksheet that you want to turn into a tile on the
--         dashboard, an alternate method is to create a new dashboard from a
--         worksheet. To do this, click the arrow to the right of the worksheet
--         name, and navigate to Move to and then + New Dashboard.

-- 24.4.1  From the home page, in the left navigation bar select Projects, then
--         select Dashboards.

-- 24.4.2  Click the blue + Dashboard button in the upper right.

-- 24.4.3  A dialog box will appear. Type a name for the dashboard and click the
--         Create Dashboard button.

-- 24.4.4  Once the dashboard is open, select the role and virtual warehouse at
--         the top right of the page.
--         Role: TRAINING_ROLE
--         Virtual Warehouse: LEARNER_WH

-- 24.4.5  Click the blue New Tile button in the center of the page.
--         From the drop-down list, select From SQL Worksheet.

-- 24.4.6  You should see an empty SQL worksheet. At the top of the worksheet,
--         select the database and schema.
--         - Database: SNOWFLAKE
--         - Schema: ACCOUNT_USAGE

-- 24.4.7  To rename the worksheet, click the arrow next to the date/time shown
--         at the top of the worksheet, type in the new name, and hit enter.

-- 24.4.8  Copy and paste your query into the pane, or type your query from
--         scratch.

-- 24.4.9  Click the run button in the upper right area of the worksheet to
--         verify your code runs without errors.

-- 24.4.10 If you want to display the query result details in your dashboard,
--         click on the Return to <dashboard-name> link in the upper-left area
--         of the worksheet.

-- 24.4.11 If creating a chart, click the Chart button just above the query
--         results.
--         When the chart is visible, click Chart type in the right side menu to
--         change the chart to a bar chart. Choose the required orientation for
--         the bar chart. Optionally, you may also set labels for the X-axis and
--         Y-axis for your bar chart.
--         When finished, use the Return to <dashboard-name> link in the upper-
--         left area of the worksheet to return to your dashboard. The tile
--         should be displayed on the dashboard.

-- 24.4.12 Create your next tile.
--         To add tiles to your dashboard, click the + button below the < arrow
--         at the top left of your dashboard window.
--         Click on the blue New Tile button at the bottom of the list to add
--         your next tile. From the drop-down list, select From SQL Worksheet.

-- 24.4.13 Repeat the steps above for each additional tile.

-- 24.4.14 Drag and reposition the tiles as needed.
--         To reposition a tile, navigate to the dashboard and launch it. Hover
--         your mouse cursor over the tile you wish to move, click and hold the
--         mouse button. Then, while holding down the mouse button, drag the
--         tile to the desired position and release the mouse button.

-- 24.5.0  Return to the Lab Exercise Page in the Course and Click the Mark as
--         complete Button
