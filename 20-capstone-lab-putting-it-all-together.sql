
-- 20.0.0  Capstone Lab: Putting it All Together
--         The purpose of this lab is to give you an opportunity to apply
--         several of the skills you’ve practiced in a single scenario that
--         combines all of them. We’ll provide some SQL code, details about the
--         expected result, the steps you need to take, and some hints.
--         Otherwise, you’ll create the entire solution on your own.
--         If you need more than the hints provided, the solution can be found
--         at the end of this lab.
--         Also, make sure you take advantage of https://docs.snowflake.com/en/
--         to complete this exercise. If you haven’t looked at our documentation
--         yet, you’ll find it very comprehensive and helpful. We produce that
--         documentation to help you find solutions for your on-the-job tasks,
--         so now is a great time to get familiar with it.
--         Finally, you may solve this exercise in a very different way than we
--         did. If you think you have a better or more elegant solution, go for
--         it! The point here is for you to get some practice that will
--         reinforce what you’ve learned in this course.
--         - Create a table.
--         - Load data from a file in an internal named stage into a table.
--         - Create and call a user-defined function.
--         - Create and call a user-defined table function.
--         - Create a dashboard.
--         - Add tiles to a dashboard.
--         - Create a bar chart in a dashboard tile.
--         This lab should take you approximately 60 minutes to complete.
--         Snowbear Air has assigned you to create a dashboard with a bar chart
--         that illustrates the number of flights that did not land on time. The
--         bar chart will need to display individual bars for flights that are
--         10, 20, 30, 40, 50, 60, and 61+ minutes over the planned flight time.
--         You will create a table, load the data, write a user-defined table
--         function that will produce the data you need for the dashboard, and
--         then create the dashboard itself. The dashboard will have two tiles:
--         one with the graph and one listing the data.
--         Expected Result
--         Your dashboard should look like the one shown below when completed.
--         The figures in your charts may differ from what is shown in this
--         screenshot.
--         How to Complete this Lab
--         In a previous lab, you may have used the SQL code file for that lab
--         to create a new worksheet and then just run the code provided within
--         that worksheet. That approach will be modified a bit for this lab due
--         to the nature of what you will be doing.
--         If you use the SQL file instead of the workbook PDF to follow the
--         instructions for this lab, you will not have access to the screenshot
--         of the expected result that can only be seen in the workbook PDF. The
--         best way to complete this lab is to use the PDF workbook instructions
--         for the entire lab from start to finish.
--         Open the SQL file in the text editor of your choice. Copying and
--         pasting from the workbook PDF will result in errors! Also, importing
--         the entire file into a single tile’s worksheet means all queries will
--         be executed when the tile gets refreshed, which will negatively
--         impact performance. The best way to put code in each tile’s worksheet
--         is to open the SQL file in the text editor of your choice and copy
--         and paste from there into your worksheet.
--         Let’s get started!

-- 20.1.0  Create the Data Needed for this Exercise
--         In this section of the lab, you will run some SQL code we have
--         provided, so you will have a stage that contains the files you will
--         need to load in a later step. You must complete all the steps in this
--         section to complete the capstone lab successfully.

-- 20.1.1  Create a new worksheet.

-- 20.1.2  Copy and paste the SQL code below from your SQL file into the new
--         worksheet.
--         This code will set the context, create the file format you’ll use,
--         create an internal named stage, and populate it with the files you
--         need for this exercise. Execute these statements line-by-line, and
--         make sure you do not miss any.

-- Set context
USE ROLE TRAINING_ROLE;

CREATE WAREHOUSE IF NOT EXISTS LEARNER_WH INITIALLY_SUSPENDED=TRUE;
USE WAREHOUSE LEARNER_WH;

CREATE DATABASE IF NOT EXISTS LEARNER_DB;
USE DATABASE LEARNER_DB;

CREATE SCHEMA IF NOT EXISTS LEARNER_DB.LEARNER_SCHEMA;
USE LEARNER_DB.LEARNER_SCHEMA;

-- Create an internal named stage

CREATE OR REPLACE STAGE flight_stage;

-- Create a file format

CREATE OR REPLACE FILE FORMAT flight_file_format TYPE = CSV
COMPRESSION = NONE
FIELD_DELIMITER = '|'
field_optionally_enclosed_by = '"'
FILE_EXTENSION = 'tbl' 
ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE;

-- Create the source files

COPY INTO @flight_stage
FROM (SELECT fl_date, op_carrier_fl_num, origin, dest, crs_dep_time, dep_time, crs_arr_time, arr_time
      FROM SNOWBEARAIR_DB.RAW.ONTIME_REPORTING
      WHERE year = 2015 AND length(arr_time)<>0 and length(dep_time)<>0
      AND crs_dep_time < crs_arr_time 
      AND dep_time < arr_time)
FILE_FORMAT = (FORMAT_NAME = flight_file_format)
OVERWRITE=TRUE;

-- Verify the stage has files
list @flight_stage;


--         In the statement above that creates the source files, the crs in
--         crs_dep_time stands for Computerized Reservations System. So the
--         column crs_dep_time is the scheduled departure time, and crs_arr_time
--         is the scheduled arrival time. The columns dep_time and arr_time
--         contain the actual departure and arrival times.

-- 20.1.3  Close the worksheet since you no longer need it.

-- 20.2.0  Create a Target Table and Load it with Data

-- 20.2.1  Create a new worksheet and inspect the data in the stage
--         @flight_stage.
--         Notice there are a number of files. Below is a SQL statement to view
--         one of the files. You can change the title of the file name in the
--         statement to view different files, but as you see, they all have the
--         same structure.

SELECT $1 FROM @LEARNER_db.LEARNER_schema.flight_stage/data_0_0_0.tbl;

--         Each row represents a single flight on a specific date, and each has
--         the scheduled departure and arrival, as well as the actual departure
--         and arrival. You can use these figures to determine both the
--         scheduled and actual flight times.

-- 20.2.2  Create the target table.
--         Load all the data from the files into a table.
--         You’ll need to set the data type for all fields to VARCHAR.

-- 20.2.3  Copy the file data into the target table and verify the data was
--         added successfully.
--         For this, you need a simple COPY INTO statement.
--         Use the file format that you used to create the data for this
--         exercise.
--         The fully qualified path should include the database name, schema
--         name, stage name, and file path. Rather than load each file one by
--         one, you can load all the files by ending the FROM clause of your
--         COPY INTO statement with the folder name where the files are located.
--         If you need to clear out your table and start over for any reason,
--         you can use TRUNCATE to delete the data.

-- 20.3.0  Write a User-Defined Function and a User-Defined Table Function

-- 20.3.1  Write a user-defined function to convert VARCHAR values into INTEGER
--         values.
--         The user-defined function will convert the four-digit VARCHAR time
--         values into an INTEGER.

-- 20.3.2  Write a user-defined function to calculate flight delay time.
--         Write a SQL user-defined function that calculates the difference
--         between the actual flight and scheduled flight times. This is a very
--         simple function that requires the calculation below. You’ll use this
--         function in your user-defined table function.
--         - (arrival_actual - departure_actual) - (arrival_scheduled -
--         departure_scheduled)
--         You will pass four values of data type VARCHAR into your function,
--         and your function will return a scalar value of data type INTEGER.

-- 20.3.3  Write a SQL user-defined table function.
--         The user-defined table function you will create in this step should
--         call the user-defined function you just created and return a table
--         with the data you need for your query.
--         The user-defined function you just wrote produces the bands below.
--         If the flight time is between 1 AND 10, the band is 1 - 10.
--         If the flight time is between 11 AND 20, the band is 11 - 20.
--         If the flight time is between 21 AND 30, the band is 21 - 30.
--         If the flight time is between 30 AND 40, the band is 31 - 40.
--         If the flight time is between 40 AND 50, the band is 41 - 50.
--         If the flight time is between 51 AND 60, the band is 51 - 60.
--         If the flight time is greater than 60, the band is 60 +.
--         You can use a CASE statement to produce the bands. CASE is a
--         conditional expression function. Check the documentation for details
--         about syntax and how to use it.
--         Also, remember that some flights will have an actual flight time
--         shorter than the scheduled flight time, while others will have a
--         flight time equal to the scheduled flight time. You will exclude
--         those bands from the final dashboard.

-- 20.4.0  Write the Query

-- 20.4.1  Write a query that uses the user-defined table function to produce
--         the data for the dashboard.
--         The query should produce a band and the flight count for each band.
--         You will need a GROUP BY statement.
--         Check our documentation for details about how to use a user-defined
--         table function in a SQL statement.

-- 20.4.2  Create a dashboard with two tiles, one for the data and one for the
--         bar chart.

-- 20.4.3  When you are finished, suspend your virtual warehouse.

ALTER WAREHOUSE LEARNER_WH SUSPEND;

--         Congratulations! You have now completed this lab.
--         If you need help, the solution is on the next page.

-- 20.5.0  Solution for SQL Portion of Lab
--         Remember to set your context based on the Create the Data Needed for
--         this Exercise section before you use the solution.


-- Create the target table

CREATE OR REPLACE TABLE flight_reporting (
      FLIGHT_DATE DATE,  
      FLIGHT_NUM VARCHAR(16777216),
      ORIGIN_AIRPORT VARCHAR(16777216),   
      DEST_AIRPORT VARCHAR(16777216),      
      DEPARTURE_SCHEDULED VARCHAR(16777216), 
      DEPARTURE_ACTUAL VARCHAR(16777216),   
      ARRIVAL_SCHEDULED VARCHAR(16777216),   
      ARRIVAL_ACTUAL VARCHAR(16777216)      
);

-- Copy the files into the target table

COPY INTO flight_reporting
FROM @LEARNER_db.LEARNER_schema.flight_stage/ pattern='.*\.tbl.*'
FILE_FORMAT = (FORMAT_NAME = flight_file_format);

-- Verify the table is populated

SELECT * FROM flight_reporting;

-- Convert the time values in your table to minutes

CREATE OR REPLACE FUNCTION convert_to_minutes(time_to_convert varchar)
RETURNS INTEGER
AS $$
((substr(time_to_convert,1,2)::integer)*60) + (substr(time_to_convert,3,2)::integer)
$$;


-- Create the function that calculates the difference between the actual flight time and the scheduled flight time

CREATE OR REPLACE function flight_time_difference(departure_scheduled VARCHAR, departure_actual VARCHAR, arrival_scheduled VARCHAR, arrival_actual VARCHAR) 
RETURNS INTEGER
AS $$
     (convert_to_minutes(arrival_actual)-convert_to_minutes(departure_actual))-
     (convert_to_minutes(arrival_scheduled)-convert_to_minutes(departure_scheduled))
$$;

-- Verify the function works as expected

SELECT  
        f.*,
        flight_time_difference(departure_scheduled, departure_actual, arrival_scheduled, arrival_actual) AS time_difference
FROM 
        flight_reporting f 
WHERE 
        time_difference > 0;

-- Create the UDTF to return the data

CREATE OR REPLACE FUNCTION time_band_table()
RETURNS TABLE (time_band varchar)
AS
$$
    SELECT  
    CASE 
        WHEN flight_time_difference(departure_scheduled, departure_actual, arrival_scheduled, arrival_actual) < 0 THEN 'Shorter flight'
        WHEN flight_time_difference(departure_scheduled, departure_actual, arrival_scheduled, arrival_actual) = 0 THEN 'Scheduled=Actual'
        WHEN flight_time_difference(departure_scheduled, departure_actual, arrival_scheduled, arrival_actual) BETWEEN  1 AND 10 THEN  '1 - 10'
        WHEN flight_time_difference(departure_scheduled, departure_actual, arrival_scheduled, arrival_actual) BETWEEN 11 AND 20 THEN '11 - 20'
        WHEN flight_time_difference(departure_scheduled, departure_actual, arrival_scheduled, arrival_actual) BETWEEN 21 AND 30 THEN '21 - 30'
        WHEN flight_time_difference(departure_scheduled, departure_actual, arrival_scheduled, arrival_actual) BETWEEN 30 AND 40 THEN '31 - 40'
        WHEN flight_time_difference(departure_scheduled, departure_actual, arrival_scheduled, arrival_actual) BETWEEN 40 AND 50 THEN '41 - 50'
        WHEN flight_time_difference(departure_scheduled, departure_actual, arrival_scheduled, arrival_actual) BETWEEN 51 AND 60 THEN '51 - 60'
        ELSE '60 +'
    END as time_band
    FROM flight_reporting f 
    WHERE flight_time_difference(departure_scheduled, departure_actual, arrival_scheduled, arrival_actual) > 0
    ORDER BY time_band
$$;

-- Create the query that will produce two columns - the time band and the count of flights in that band

SELECT 
    t.time_band, 
    COUNT(t.time_band) AS time_band_count 
FROM 
    TABLE(time_band_table())t 
GROUP BY 
    t.time_band 
ORDER BY 
    time_band;



-- 20.6.0  Solution for Creating a Dashboard
--         The steps below show you how to create a dashboard from scratch. If
--         you have a worksheet that you want to turn into a tile on the
--         dashboard, an alternate method is to create a new dashboard from a
--         worksheet. To do this, click the ellipsis to the right of the
--         worksheet name and navigate to Move to. Then select + New Dashboard
--         from the drop-down list.

-- 20.6.1  From the home page, in the left navigation bar select Projects, then
--         select Dashboards.

-- 20.6.2  Click the blue + Dashboard button in the upper right.

-- 20.6.3  A dialog box will appear. Type a name for the dashboard and click the
--         Create Dashboard button.

-- 20.6.4  Once the dashboard is open, select the role and virtual warehouse at
--         the top right of the page.
--         - Role: TRAINING_ROLE
--         - Warehouse: LEARNER_WH

-- 20.6.5  Click the blue New Tile button in the center of the page.
--         From the drop-down menu, click on From SQL Worksheet.

-- 20.6.6  You should see an empty worksheet. At the top of the worksheet,
--         select the database and schema.
--         - Database: LEARNER_DB
--         - Schema: LEARNER_SCHEMA

-- 20.6.7  To rename the worksheet, click the arrow next to the date/time shown
--         at the top of the worksheet, type in the new name, and hit enter.

-- 20.6.8  Copy and paste your query into the pane, or type your query from
--         scratch.

-- 20.6.9  Click the run button in the upper right of the worksheet to verify
--         your code runs without errors.

-- 20.6.10 If you want to display the query result details in your dashboard,
--         click on the Return to <dashboard-name> link in the upper-left area
--         of the worksheet.

-- 20.6.11 If creating a chart, click the Chart button just above the query
--         results.
--         When the chart is visible, click Chart type in the right side menu to
--         change the chart to a bar chart. Choose the required orientation for
--         the bar chart. Optionally, you may also set labels for the X-axis and
--         Y-axis for your bar chart.
--         When finished, use the Return to <dashboard-name> link in the upper-
--         left area of the worksheet to return to your dashboard. The tile
--         should be displayed on the dashboard.

-- 20.6.12 Create your next tile.
--         To add tiles to your dashboard, click the + button below the < arrow
--         at the top left of your dashboard window.
--         Click on the blue New Tile button at the bottom of the list to add
--         your next tile. From the drop-down list, select From SQL Worksheet.

-- 20.6.13 Repeat the steps for each additional tile.

-- 20.6.14 Drag and reposition your tiles as needed.
--         To reposition a tile, navigate to the dashboard and launch it. Hover
--         your mouse cursor over the tile you wish to move, click and hold the
--         mouse button. Then, while holding down the mouse button, drag the
--         tile to the desired position and release the mouse button.

-- 20.7.0  Return to the Lab Exercise Page in the Course and Click the Mark as
--         complete Button
