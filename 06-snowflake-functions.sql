
-- 6.0.0   Snowflake Functions
--         The purpose of this lab is to introduce you to Snowflake’s extensive,
--         built-in function library.
--         The average Snowflake user uses three Snowflake components to get
--         work done: core SQL constructs (SQL itself), the compute layer, and
--         functions. Thus, functions are helpful in every workload, including
--         data engineering, data lake, data warehousing, data science, data
--         applications, and collaboration.
--         In this lab, you’ll become familiar with several SQL functions. You
--         may be familiar with similar or identical functions from other
--         database or data warehouse systems.
--         This lab has two parts. In Part I, you will execute different kinds
--         of functions to learn how they work. In Part II, you will apply some
--         of the functions from Part I to queries that you will write.
--         - Apply scalar functions.
--         - Apply conditional functions such as IFF() and CASE.
--         - Apply aggregate functions such as MIN, MAX, SUM, AVG, and MEDIAN.
--         - Apply window functions.
--         - Apply date/context functions.
--         - Apply table functions.
--         This lab should take you approximately 35 minutes to complete.
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

-- 6.1.0   Part I - Learn About Snowflake Functions

-- 6.1.1   Set your context.

USE ROLE TRAINING_ROLE;

CREATE WAREHOUSE IF NOT EXISTS LEARNER_wh;
USE WAREHOUSE LEARNER_wh;

USE SCHEMA SNOWBEARAIR_db.PROMO_CATALOG_SALES;


-- 6.2.0   Scalar Functions
--         Scalar functions take a single row or value as input and return a
--         single value, such as a number, a string, or a boolean value.
--         Click here to learn more about Snowflake’s scalar functions.
--         (https://docs.snowflake.com/en/sql-reference/functions.html)
--         Note that although you are probably familiar with most, if not all,
--         of them, some functions may have different names or syntax than what
--         you’ve seen in other systems. For example, while some systems use an
--         IF…THEN syntax for if-then statements, Snowflake uses IFF().
--         Now, let’s try using a few scalar functions.

-- 6.2.1   Execute the query with the CONCAT() function.
--         The query below uses the CONCAT() function to concatenate the part
--         and supplier names. Execute the query to see the result.

SELECT
    p.p_name as part_name,
    s.s_name AS supplier_name,
    CONCAT(p.p_name, ' - ', s.s_name) AS part_and_supplier

FROM    
    part p
    INNER JOIN partsupp ps ON p.p_partkey = ps.ps_partkey
    INNER JOIN supplier s ON ps.ps_suppkey = s.s_suppkey;

--         In Query Details, in the rightmost portion of the Results Area, you
--         will see a message that states, Partial results displayed. Query
--         results are displayed as a table of up to 10,000 rows. You can use
--         the Download results option to view all of the results. To view the
--         remainder of the Query Details information, select the x in the right
--         corner of the message box.

-- 6.2.2   Execute the query with the || concatenation operator.
--         The query below is functionally identical to the previous one,
--         although it does have a syntactical difference. It uses the double-
--         pipe concatenation operator to achieve the same result.

SELECT
    p.p_name as part_name,
    s.s_name AS supplier_name,
    p.p_name || ' - ' || s.s_name AS part_and_supplier

FROM    
    part p
    INNER JOIN partsupp ps ON p.p_partkey = ps.ps_partkey
    INNER JOIN supplier s ON ps.ps_suppkey = s.s_suppkey;


-- 6.2.3   Execute the query with the LPAD() function
--         You can use the LPAD function to pad a value so that all values in
--         the column have the same length and potentially the same leading
--         characters.
--         In the example below, we pad all the values in the p_partkey column
--         with zeroes so they are all ten characters. If a key was already 10
--         characters, it would not be padded. In this case, however, the
--         maximum length of the key is six characters, so some values will be
--         left padded with at least four zeroes.
--         Execute the statement below to see the result.

SELECT LPAD(p.p_partkey, 10, '0')
FROM    
    part p; 

--         NOTE: As you may have guessed, an RPAD() function behaves
--         identically, except that it pads the right side of the value.

-- 6.2.4   Execute the query with the IFF() function.
--         IFF allows you to do an IF-THEN-ELSE analysis that determines the
--         output of the function.
--         Execute the statement below using the conditional function IFF to see
--         what it does.

SELECT
    s.s_name AS supplier_name,
    IFF(s.s_acctbal > 500, 'Gold Member', 'Silver Member') membership_status    
FROM    
    supplier s; 


-- 6.2.5   Execute the queries with the CASE statements.
--         Here, you’ll use a CASE expression to indicate whether or not a
--         particular part of an order has been returned.

SELECT 
            O_ORDERKEY AS ORDER_NUMBER,
            L.L_PARTKEY AS PART_NUMBER,
            CASE 
                WHEN L.L_RETURNFLAG = 'N'
                    THEN 'NOT RETURNED'
                WHEN L.L_RETURNFLAG = 'R'
                    THEN 'RETURNED'
            END AS RETURN_STATUS
FROM
    ORDERS O 
    INNER JOIN LINEITEM L ON O.O_ORDERKEY = L.L_ORDERKEY
LIMIT 100;

--         In the example below, you’ll determine the membership status of a
--         supplier with a CASE statement.

SELECT
    s.s_name AS supplier_name,
    CASE
        WHEN s.s_acctbal<100 THEN 'Bronze Member'
        WHEN s.s_acctbal>=100 AND s.s_acctbal <500 THEN 'Silver Member'
        WHEN s.s_acctbal >=500 THEN 'Gold Member'
    END AS membership_status
FROM    
    supplier s; 


-- 6.2.6   Run queries with the aggregate functions MIN, MAX, SUM, AVG, and
--         MEDIAN.
--         Aggregate functions work across rows to perform mathematical
--         functions such as MIN, MAX, COUNT, and various statistical functions.
--         Here are several functions you have most likely seen or used in
--         another database system or a spreadsheet program. We won’t go over
--         them because you’re probably familiar with them in detail.
--         Click here to learn more about Snowflake’s Aggregate functions
--         (https://docs.snowflake.com/en/sql-reference/functions-
--         aggregation.html).

--MIN/MAX
SELECT 
    MIN(s.s_acctbal) AS MIN_ACCT_BAL, 
    MAX(s.s_acctbal) AS MAX_ACCT_BAL
FROM supplier s;    
    
--SUM
SELECT 
    r.r_name AS region_name,
    n.n_name AS nation_name,
    MIN(s.s_acctbal) AS MIN_ACCT_BAL, 
    MAX(s.s_acctbal) AS MAX_ACCT_BAL,
    SUM(s.s_ACCTBAL) AS combined_total 
FROM 
    supplier s
    INNER JOIN nation n ON s.s_nationkey = n.n_nationkey
    INNER JOIN region r ON n.n_regionkey = r.r_regionkey
GROUP BY
    region_name,
    nation_name
    ;

 --AVG, MEDIAN
SELECT 
    r.r_name AS region_name,
    n.n_name AS nation_name,
    MIN(S.S_ACCTBAL) AS MIN_ACCT_BAL, 
    MAX(S.S_ACCTBAL) AS MAX_ACCT_BAL,
    SUM(S.S_ACCTBAL)::DECIMAL(18,2) AS combined_total,
    AVG(S.S_ACCTBAL)::DECIMAL(18,2) AS average_acct_bal,
    MEDIAN(S.S_ACCTBAL)::DECIMAL(18,2) AS median_acct_bal      
FROM 
    supplier s
    INNER JOIN nation n ON s.s_nationkey = n.n_nationkey
    INNER JOIN region r ON n.n_regionkey = r.r_regionkey
GROUP BY
    region_name,
    nation_name;


-- 6.2.7   Run a query with a WINDOW function.
--         Window frame functions allow you to perform rolling operations, such
--         as calculating a running total or a moving average, on a subset of
--         the rows in the window. As you’ll see below, the OVER clause allows
--         you to partition rows by a specific value (a window) and order the
--         rows within that window. You can then aggregate values within the
--         window.
--         Many aggregate functions you saw earlier can work with the OVER
--         clause, enabling aggregations across a group of rows.
--         Click here to learn more about Snowflake’s Window functions
--         (https://docs.snowflake.com/en/sql-reference/functions-
--         analytic.html).
--         We will use the query below to determine each virtual warehouse’s
--         credit usage per date and hour. The total usage per virtual warehouse
--         per date is rolled-up as a column for each record. The credit usage
--         per hour per date is also computed as a percentage. The SQL statement
--         accomplishes this by querying the WAREHOUSE_METERING_HISTORY secure
--         view in the ACCOUNT_USAGE schema of the Snowflake database. We
--         partition by date and the virtual warehouse name.
--         Run the query now and examine the result.

SELECT
        warehouse_name,
        DATE(start_time) AS dt,
        HOUR(start_time) AS hour,
        credits_used,
        SUM(credits_used)
            OVER (PARTITION BY dt, warehouse_name) AS dt_tot_credits,
        ((credits_used / dt_tot_credits) * 100)::NUMBER(6,2) as pct_of_dt_total_credits
FROM
        SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE credits_used <> 0 AND warehouse_name is not null
ORDER BY
        warehouse_name, dt, hour;


-- 6.2.8   Run queries with date/context functions.
--         The date functions below extract the year, month, or day from the
--         date. Run the query to see the result.

--DATE FUNCTIONS
SELECT
    YEAR(O.O_ORDERDATE) AS year_of_order,
    MONTH(O.O_ORDERDATE) AS month_of_order,
    DAYOFMONTH(O.O_ORDERDATE) AS day_of_order
FROM 
    ORDERS O;

--         Below is an example of a casting function. This function uses a
--         double colon followed by the data type to which the expression to the
--         left of the colons will be cast.
--         Notice that a string is being cast to a date, time, or date time in
--         each instance.
--         Run the queries below and examine the results.

--CASTING 
--FROM DATE
SELECT DAY('2023-01-16'::DATE);
SELECT MONTH('2023-01-16'::DATE);
SELECT YEAR('2023-01-16'::DATE);    
    
--FROM TIME
SELECT HOUR('19:06:45.988'::TIME);
SELECT MINUTE('19:06:45.988'::TIME);
SELECT SECOND('19:06:45.988'::TIME);

--FROM DATETIME
SELECT HOUR('2023-01-16T19:10:27.848-08:00'::DATETIME);
SELECT MINUTE('2023-01-16T19:10:27.848-08:00'::DATETIME);
SELECT SECOND('2023-01-16T19:10:27.848-08:00'::DATETIME);
SELECT DAY('2023-01-16T19:10:27.848-08:00'::DATETIME);
SELECT MONTH('2023-01-16T19:10:27.848-08:00'::DATETIME);
SELECT YEAR('2023-01-16T19:10:27.848-08:00'::DATETIME);

--         Below are three queries with context functions. Their names are self-
--         explanatory. Run the queries and examine the result.

--CONTEXT FUNCTIONS    
SELECT CURRENT_TIME();

SELECT CURRENT_TIMESTAMP();

SELECT CURRENT_DATE();

--         The DATEADD() function below will allow you to add or subtract years,
--         months, or days from a date and hours, minutes, or seconds from a
--         timestamp. The parameters are the date or time part, the interval to
--         add (a positive integer to add, a negative integer to subtract), and
--         the date.
--         Run the queries below and examine the result. Notice that the
--         TO_DATE() function and ::DATE are being used to convert strings to
--         dates and that ::DATETIME is being used to convert strings into time
--         stamps.

-- DATEADD()
-- The following two queries are functionally identical. 
-- Note the use of TO_DATE() vs. ::DATE.

SELECT 
    TO_DATE('2021-03-30') AS MYDATE,
    DATEADD('days', 2,TO_DATE('2021-03-30')) AS ADDING_2_DAYS;

SELECT 
    TO_DATE('2021-03-30') AS MYDATE,
    DATEADD('days', 2,'2021-03-30'::DATE) AS ADDING_2_DAYS;


-- The following two queries are functionally identical. 
-- Note the use of TO_TIMESTAMP() vs. ::DATETIME.

SELECT 
    '2023-01-16T19:10:27.848-08:00'::DATETIME AS MYTIMESTAMP,
    DATEADD('minutes',2,'2023-01-16T19:10:27.848-08:00'::DATETIME) AS ADDING_2_MINUTES;    

SELECT 
    '2023-01-16T19:10:27.848-08:00'::DATETIME AS MYTIMESTAMP,
    DATEADD('minutes',2,TO_TIMESTAMP('2023-01-16T19:10:27.848-08:00')) AS ADDING_2_MINUTES;   



-- 6.2.9   Write a query using a table function.
--         Table functions return a set of rows instead of a single scalar
--         value. Table functions appear in the FROM clause of a SQL statement
--         and cannot be used as scalar functions.

-- 6.2.10  Use a table function to retrieve one hour of query history.
--         As you can see below, we are querying the query_history table
--         function. It takes two parameters in TIMESTAMP format: start and end
--         times.
--         To get a result set, the query_history table function and the
--         parameter values must be passed into the function TABLE().
--         Run the query below and examine the result.

SELECT
        *
FROM
        TABLE(
                information_schema.query_history(
                        DATEADD('hours', -1, CURRENT_TIMESTAMP()), --START
                        CURRENT_TIMESTAMP()                        --END
                    )
              )
ORDER BY
        start_time;

--         In the Query Details on the right side of the Results Pane, copy your
--         Query ID. To copy the Query ID, click on the ellipsis (…) beside
--         Query Details and select Copy Query ID. We will use the ID with the
--         Result Scan.

-- 6.2.11  Use the RESULT_SCAN function to return the last result set.
--         The function RESULT_SCAN returns the result set of a previous command
--         (within 24 hours of when you executed the query) as if the results
--         were a table. This is useful if you want to process the output of
--         SHOW or DESCRIBE, the output of a query executed on account usage
--         information, such as INFORMATION_SCHEMA or ACCOUNT_USAGE, or the
--         output of a stored procedure.
--         Before running the RESULT_SCAN, we will suspend our virtual
--         warehouse.

ALTER WAREHOUSE LEARNER_wh SUSPEND;

--         If you try to suspend the virtual warehouse and it is already
--         suspended, you may get an error. This is normal.
--         The query below is simple and just produces the results of the query
--         you ran.
--         Replace  in the SQL below with the Query ID you copied. Make sure
--         your Query ID is in single quotes.

SELECT * FROM table(RESULT_SCAN('<query_id>'));

--         The RESULT_SCAN does not need a virtual warehouse unless you are
--         doing other processing (like filtering) with RESULT_SCAN. This helps
--         you save on credits by re-using your result sets.

-- 6.3.0   Part II - Try it Out!
--         Now you’re going to write some queries. There are a lot of queries to
--         write, so don’t feel like you have to write all of them. Just try to
--         complete as many as you can.
--         Some of the examples in Part I will help you write these queries. So,
--         feel free to revisit Part I as necessary. And remember, there is more
--         than one way to write a query that produces the desired result.
--         You will write several queries using
--         SNOWBEARAIR_DB.PROMO_CATALOG_SALES.CUSTOMER and several using
--         SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY. Each query you write for each
--         dataset will build on the previous query, so you won’t always have to
--         build a brand new query from scratch. The last query in the list
--         below is the only one that will use
--         information_schema.query_history() in LEARNER_DB.
--         In Snowflake, setting the context is the first step in writing or
--         executing a query. If you’re having trouble finding your data source,
--         check your database and schema to ensure you’re querying the correct
--         data set.
--         There are solutions at the end of this lab. But try to complete the
--         lab on your own first, as you’ll learn more that way.

-- 6.3.1   Write a query using the customer table
--         (SNOWBEARAIR_DB.PROMO_CATALOG_SALES.CUSTOMER).
--         The query will have two fields: (1) the first initial of the first
--         name followed by a period, followed by a space, then the last name,
--         and (2) the customer’s initials (first and last name) with no
--         punctuation.

-- 6.3.2   Write a query using IFF() and the customer table
--         (SNOWBEARAIR_DB.PROMO_CATALOG_SALES.CUSTOMER).
--         This query will have two fields: (1) the full name (first name and
--         last name) of the customer and (2) the customer’s membership status.
--         Customers with an account balance of greater than 500 will be Gold
--         Members. The rest will be Silver Members.

-- 6.3.3   Write a query that uses a CASE statement and the customer table
--         (SNOWBEARAIR_DB.PROMO_CATALOG_SALES.CUSTOMER).
--         This query should have three fields: (1) the customer’s full name,
--         (2) the customer’s initials, and (3) the customer’s membership
--         status.
--         Bronze members have an account balance of less than 250, Silver
--         members have an account balance greater than or equal to 250 and less
--         than 500, and Gold members have an account balance greater than or
--         equal to 500.

-- 6.3.4   Write a query using LPAD, concatenation, a CASE statement, and the
--         customer table (SNOWBEARAIR_DB.PROMO_CATALOG_SALES.CUSTOMER).
--         For this query, you will provide a region code, nation code, and the
--         region and nation concatenated with the customer’s full name,
--         initials, and membership status (same requirements as the previous
--         query). You should filter for APAC countries only.
--         This statement should have the following fields:
--         - A ten-digit region code left padded with zeroes. (HINT Look for the
--         Region Key field in the Region table).
--         - A ten-digit nation code left padded with zeroes. (HINT Look for the
--         Nation Key field in the Nation table).
--         - A column with the region and nation together, with a hyphen between
--         region and nation.
--         - The customer’s membership status (same requirements as the previous
--         query).
--         Use the query below to get started:

SELECT
    *
FROM    
    CUSTOMER C  
    LEFT JOIN NATION N ON N.N_NATIONKEY = C.C_NATIONKEY
    LEFT JOIN REGION R ON N.N_REGIONKEY = R.R_REGIONKEY; 


-- 6.3.5   Add the SUM, AVG, and MEDIAN account balances to the previous query.
--         HINT: This query requires a GROUP BY clause.

-- 6.3.6   Write a query that produces the fields below from
--         SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY.
--         The Snowflake database provides several queries you can use to
--         monitor how well users are using Snowflake and how credits are being
--         consumed. The QUERY_HISTORY table in the ACCOUNT_USAGE schema allows
--         you to see statistics about what queries have been executed.
--         Each row in QUERY_HISTORY represents a query that was executed.
--         In this query, you’ll need to use the following fields: start_time,
--         total_elapsed_time, and virtual warehouse name.
--         You’ll need to produce the following columns in your query:
--         - The year, month, and day the query was executed (three columns).
--         - The virtual warehouse name
--         - The MIN, MAX, AVG, and MEDIAN elapsed time (four columns)
--         Use the query below to get started:

SELECT 
    qh.start_time,
    qh.total_elapsed_time,
    qh.warehouse_name
FROM 
    SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY qh 
WHERE
        query_text LIKE 'SELECT%'
        AND
        query_text NOT LIKE 'SELECT 1%'
        AND
        qh.warehouse_name NOT LIKE 'COMPUTE_SERVICE_WH_USER_TASKS_POOL_%';

--         HINT: You’ll need a GROUP BY clause.

-- 6.3.7   Extract values from the current date or the current timestamp.
--         Write queries to satisfy the requirements below.
--         - Select the day, month, and year from the current date (three
--         queries or one query).
--         - Select the hour, minute, and second from the current time (three
--         queries or one query).
--         - Select the hour, minute, second, day, month, and year from the
--         current time stamp (six queries or one query).
--         - Select the hour, minute, second, day, month, and year from the
--         following timestamp: 2023-01-16T19:18:22.722-08:00. (HINT: You will
--         need to cast this value to another data type).

-- 6.3.8   Write a query that leverages the information_schema.query_history()
--         table function in LEARNER_DB to list the types of queries executed
--         and the number of instances.
--         This query should produce two fields: the query type (SELECT, INSERT,
--         TRUNCATE, DELETE, CREATE, UPDATE, or OTHER) and the count of each
--         query.
--         HINT: Your query can only go back six days, including the current
--         day, because query_history only has seven days of history.
--         If you’re not getting enough query types, you can run the queries
--         below to ensure that you do:

CREATE DATABASE IF NOT EXISTS LEARNER_DB;
USE DATABASE LEARNER_DB;

CREATE SCHEMA IF NOT EXISTS LEARNER_DB.LEARNER_SCHEMA;
USE SCHEMA LEARNER_DB.LEARNER_SCHEMA;

CREATE OR REPLACE TABLE LEARNER_T(ID INTEGER);
INSERT INTO LEARNER_T (ID) VALUES (1);
UPDATE LEARNER_T SET ID = 2;
UPDATE LEARNER_T SET ID = 1;
DELETE FROM LEARNER_T WHERE ID = 1;
INSERT INTO LEARNER_T (ID) VALUES (3);
TRUNCATE TABLE LEARNER_T;


-- 6.3.9   Suspend your virtual warehouse.

ALTER WAREHOUSE LEARNER_wh SUSPEND;


-- 6.4.0   Key Takeaways
--         - Snowflake has many functions you are already accustomed to using in
--         other software programs.
--         - You can query the query history secure view
--         (SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY) to produce numeric aggregates
--         on query execution times.
--         - Table functions return a set of rows rather than a scalar value.

-- 6.5.0   Solution
--         If you really need to, you can look at the solution below. But try
--         not to peek! You’ll learn more if you try it on your own first and
--         rely only on the hints.

-- 6.5.1   Write a query using the customer table
--         (SNOWBEARAIR_DB.PROMO_CATALOG_SALES.CUSTOMER).

--concatenation using the CONCAT() function    
SELECT
    CONCAT(LEFT(C.C_FIRSTNAME,1), '. ', C.C_LASTNAME)AS first_initial_last_name, 
    CONCAT(LEFT(C.C_FIRSTNAME,1), LEFT(C.C_LASTNAME,1)) AS initials
FROM    
    SNOWBEARAIR_DB.PROMO_CATALOG_SALES.CUSTOMER C;    


-- 6.5.2   Write a query using IFF() and the customer table
--         (SNOWBEARAIR_DB.PROMO_CATALOG_SALES.CUSTOMER).

SELECT
    CONCAT(C.C_FIRSTNAME, ' ', C.C_LASTNAME)AS full_name, 
    IFF(C.C_ACCTBAL >= 500, 'Gold Member', 'Silver Member') membership_status
FROM    
    SNOWBEARAIR_DB.PROMO_CATALOG_SALES.CUSTOMER C;  


-- 6.5.3   Write a query that uses a CASE statement and the customer table
--         (SNOWBEARAIR_DB.PROMO_CATALOG_SALES.CUSTOMER).

SELECT
    CONCAT(C.C_FIRSTNAME, ' ', C.C_LASTNAME)AS full_name, 
    CONCAT(LEFT(C.C_FIRSTNAME,1), LEFT(C.C_LASTNAME,1)) AS initials,
    CASE
        WHEN C.C_ACCTBAL<250 THEN 'Bronze Member'
        WHEN C.C_ACCTBAL>=250 AND C.C_ACCTBAL <500 THEN 'Silver Member'
        WHEN C.C_ACCTBAL >=500 THEN 'Gold Member'
    END AS membership_status
FROM    
    SNOWBEARAIR_DB.PROMO_CATALOG_SALES.CUSTOMER C;    


-- 6.5.4   Write a query using LPAD, concatenation, a CASE statement, and the
--         customer table (SNOWBEARAIR_DB.PROMO_CATALOG_SALES.CUSTOMER).

SELECT
    LPAD(R.R_REGIONKEY,10,0) AS region_code,
    LPAD(N.N_NATIONKEY,10,0) AS nation_code,
    R.R_NAME || ' - ' || N.N_NAME AS region_and_nation,
    CONCAT(C.C_FIRSTNAME, ' ', C.C_LASTNAME)AS full_name, 
    CONCAT(LEFT(C.C_FIRSTNAME,1), LEFT(C.C_LASTNAME,1)) AS initials,
    CASE
        WHEN C.C_ACCTBAL<250 THEN 'Bronze Member'
        WHEN C.C_ACCTBAL>=250 AND C.C_ACCTBAL <500 THEN 'Silver Member'
        WHEN C.C_ACCTBAL >=500 THEN 'Gold Member'
    END AS membership_status
FROM    
    SNOWBEARAIR_DB.PROMO_CATALOG_SALES.CUSTOMER C  
    LEFT JOIN SNOWBEARAIR_DB.PROMO_CATALOG_SALES.NATION N ON N.N_NATIONKEY = C.C_NATIONKEY
    LEFT JOIN SNOWBEARAIR_DB.PROMO_CATALOG_SALES.REGION R ON N.N_REGIONKEY = R.R_REGIONKEY    
WHERE 
    R.R_NAME = 'APAC'    
ORDER BY 
    region_code, 
    nation_code, 
    membership_status;    


-- 6.5.5   Add the SUM, AVG, and MEDIAN account balances to the previous query.

SELECT
    LPAD(C.C_CUSTKEY, 10,0) AS customer_code,
    LPAD(R.R_REGIONKEY,10,0) AS region_code,
    LPAD(N.N_NATIONKEY,10,0) AS nation_code,
    R.R_NAME || ' - ' || N.N_NAME AS region_and_nation,
    CONCAT(C.C_FIRSTNAME, ' ', C.C_LASTNAME)AS full_name,     
    CASE
        WHEN C.C_ACCTBAL<250 THEN 'Bronze Member'
        WHEN C.C_ACCTBAL>=250 AND C.C_ACCTBAL <500 THEN 'Silver Member'
        WHEN C.C_ACCTBAL >=500 THEN 'Gold Member'
    END AS membership_status,
    SUM(C.C_ACCTBAL) AS combined_total,
    AVG(C.C_ACCTBAL) AS average_acct_bal,
    MEDIAN(C.C_ACCTBAL) AS median_acct_bal
FROM    
    SNOWBEARAIR_DB.PROMO_CATALOG_SALES.CUSTOMER C
    LEFT JOIN SNOWBEARAIR_DB.PROMO_CATALOG_SALES.NATION N ON N.N_NATIONKEY = C.C_NATIONKEY
    LEFT JOIN SNOWBEARAIR_DB.PROMO_CATALOG_SALES.REGION R ON N.N_REGIONKEY = R.R_REGIONKEY
WHERE 
    R.R_NAME = 'APAC'
GROUP BY
    region_code,
    nation_code,
    customer_code,
    region_and_nation,
    full_name,
    membership_status
ORDER BY 
    region_code, 
    nation_code, 
    membership_status;


-- 6.5.6   Write a query that produces the fields below from
--         SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY.

--Using date/context functions
SELECT
          YEAR(qh.start_time) AS year_of_query,
          MONTH(qh.start_time) AS month_of_year,
          DAYOFMONTH(qh.start_time) AS day_of_month,
          qh.warehouse_name,
          MIN(qh.total_elapsed_time) AS min_elapsed_time,
          MAX(qh.total_elapsed_time) AS max_elapsed_time,
          AVG(qh.total_elapsed_time) AS avg_elapsed_time,
          MEDIAN(qh.total_elapsed_time) AS median_elapsed_time
FROM
        SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY qh
WHERE
        query_text LIKE 'SELECT%'
        AND
        query_text NOT LIKE 'SELECT 1%'
        AND
        qh.warehouse_name NOT LIKE 'COMPUTE_SERVICE_WH_USER_TASKS_POOL_%'
GROUP BY
        year_of_query,
        month_of_year,
        day_of_month,
        warehouse_name
ORDER BY
        year_of_query DESC,
        month_of_year DESC,
        day_of_month DESC,
        warehouse_name;


-- 6.5.7   Extract values from the current date or timestamp using date/context
--         functions.


-- FROM DATE

SET CDATE = CURRENT_DATE();

SELECT $CDATE, DAY($CDATE), MONTH($CDATE), YEAR($CDATE);    
    
-- FROM TIME

SET CTIME = CURRENT_TIME();

SELECT $CTIME, HOUR($CTIME), MINUTE($CTIME), SECOND($CTIME);

-- FROM TIMESTAMP

SET CTIMESTAMP0 = CURRENT_TIMESTAMP();

SELECT $CTIMESTAMP0, HOUR($CTIMESTAMP0), MINUTE($CTIMESTAMP0), SECOND($CTIMESTAMP0), DAY($CTIMESTAMP0), MONTH($CTIMESTAMP0), YEAR($CTIMESTAMP0);

-- FROM TIMESTAMP, WITH CASTING

SET CTIMESTAMP1 = '2023-01-16T19:18:22.722-08:00'::DATETIME;

SELECT $CTIMESTAMP1, HOUR($CTIMESTAMP1), MINUTE($CTIMESTAMP1), SECOND($CTIMESTAMP1), DAY($CTIMESTAMP1), MONTH($CTIMESTAMP1), YEAR($CTIMESTAMP1);

-- FROM TIMESTAMP, WITHOUT CASTING - GENERATES AN ERROR
-- ERROR MESSAGE = Function EXTRACT does not support VARCHAR(29) argument type

SET CTIMESTAMP2 = '2023-01-16T19:18:22.722-08:00';

SELECT $CTIMESTAMP2, HOUR($CTIMESTAMP2), MINUTE($CTIMESTAMP2), SECOND($CTIMESTAMP2), DAY($CTIMESTAMP2), MONTH($CTIMESTAMP2), YEAR($CTIMESTAMP2);


-- 6.5.8   Set your context to use LEARNER_DB.
--         Write a query that uses the information_schema.query_history() table
--         function to list the types of queries executed and the number of
--         instances.

SELECT 
    QUERY_TYPE,
    COUNT(*) AS QUERY_COUNT
FROM
    TABLE(information_schema.query_history
          (DATEADD('days', -6, CURRENT_TIMESTAMP()), CURRENT_TIMESTAMP())) qh  
GROUP BY QUERY_TYPE          
ORDER BY QUERY_TYPE;


-- 6.5.9   Suspend your virtual warehouse.

ALTER WAREHOUSE LEARNER_wh SUSPEND;


-- 6.6.0   Return to the Lab Exercise Page in the Course and Click the Mark as
--         complete Button
