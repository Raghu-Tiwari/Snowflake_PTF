
-- 9.0.0   Caching and Query Performance
--         The purpose of this lab is to introduce you to the two types of
--         caching Snowflake employs and how you can use the Query Profile to
--         determine if your query is making the best use of caching.
--         - Access and navigate the Query Profile.
--         - Summarize the differences between metadata, query result cache, and
--         data cache.
--         - Determine when and why the query result cache is being used.
--         - Determine if partition pruning is efficient and, if not, how to
--         improve it.
--         - Determine if spillage is taking place.
--         - Use EXPLAIN to determine how to improve your queries.
--         This lab should take you approximately 35 minutes to complete.
--         Like traditional relational database management systems, Snowflake
--         employs caching to help you get the query results you want as quickly
--         as possible. Snowflake caching is turned on by default, and it works
--         for you in the background without you having to do anything. However,
--         if you aren’t sure if you’re writing queries that leverage caching in
--         the most efficient way possible, you can use the Query Profile to
--         determine how caching is impacting your queries.
--         Imagine that you’re a data analyst at Snowbear Air and have just
--         learned that Snowflake has different types of caching. You have been
--         working on a few queries that you think could run faster, but you’re
--         unsure. You’ve decided to become familiar with the Query Profile and
--         use it to see how caching impacts your queries.
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

-- 9.1.0   Access and Navigate the Query Profile
--         In this section, you’ll learn how to access, navigate, and use the
--         Query Profile. This will prepare you for analyzing query performance
--         and caching in this lab.

-- 9.1.1   Set your context.

USE ROLE TRAINING_ROLE;

CREATE WAREHOUSE IF NOT EXISTS LEARNER_WH;
USE WAREHOUSE LEARNER_WH;

CREATE DATABASE IF NOT EXISTS LEARNER_DB;
USE SCHEMA LEARNER_DB.PUBLIC;


-- 9.1.2   Create some data to query.
--         Here, we’ll create a table and populate it with data from the
--         customer table. We’ll also suspend the virtual warehouse to ensure
--         our subsequent query doesn’t just pull from cached data. This will
--         allow us to see what the cache is doing going forward.

CREATE TABLE customer AS
SELECT 
       c_custkey,
       c_firstname,
       c_lastname
  FROM 
       SNOWBEARAIR_DB.PROMO_CATALOG_SALES.customer;

ALTER WAREHOUSE LEARNER_WH SUSPEND;

--         If you try to suspend the virtual warehouse and it is already
--         suspended, you may get an error. This is normal.

-- 9.1.3   Execute the following simple query in your worksheet.
--         We need query results to view in the profile. Run the statement
--         below.

SELECT DISTINCT
        *
FROM 
       customer c;


-- 9.1.4   Access the Query Profile.
--         Now, let’s view the profile. To the right of the query results, you
--         will see a panel saying, Partial results displayed. Click the X in
--         the upper right of this panel to show the usual Query Details panel.
--         Click the ellipsis shown in the screenshot. When the dialog box
--         appears, click View Query Profile. The Query Profile will open in a
--         new tab.
--         Please note that what you see might differ slightly from what is
--         shown here. Since you are working in an environment that is not the
--         same as the environment used to create the screenshots shown here,
--         these differences are normal and to be expected.
--         The query profile will appear as shown below:
--         Note that there are two tabs in the screen’s header: Query Details
--         and Query Profile.

-- 9.1.5   Click the Query Details tab.
--         The Query Details panel shows the status of execution, the overall
--         execution duration, and other details. By looking at this, you can
--         see if the query succeeded and if it ran within the time frame you
--         were hoping for.

-- 9.1.6   Click the Query Profile tab.
--         Note that there are three panels in the Query Profile that show
--         specific aspects of execution.
--         Your results may differ from what is shown in the screenshots below.
--         The Most Expensive Nodes panel shows the nodes that took the longest
--         to execute. This panel lets you identify and analyze the query
--         processing with the purpose of making it run more efficiently.
--         Take a look at your nodes and see which one took the longest.

-- 9.1.7   Click on Node A (TableScan[2]).
--         This node shows statistics related to the scan of the customer table.
--         As we saw in a previous step, the Statistics panel shows that one
--         partition was scanned out of one total partition evaluated. The query
--         was very simple, and the data set wasn’t very large, so this was to
--         be expected.
--         Note that an Attributes panel appears that shows the columns selected
--         during the processing of this node’s query.

-- 9.1.8   Click on Node B (Aggregate[1]).
--         This node shows the statistics related to the aggregation of the
--         data.
--         NOTE: You should also get similar results, but it’s possible yours
--         may differ slightly.

-- 9.1.9   Click on Node C (Result[0]).
--         This node shows the columns that were in the output.
--         Note that an Attributes panel appears that shows the columns produced
--         by the processing of this node.

-- 9.1.10  Close the tab.
--         You’ll remember that the Query Profile opened up in a new tab. While
--         we could navigate back to our worksheet, that would leave us with two
--         tabs open. Close this tab and return to the tab with your worksheet.

-- 9.1.11  Rerun your query.

SELECT DISTINCT
        *
FROM 
       customer c;

--         Once you’ve rerun the query, you should notice that it ran in a few
--         milliseconds, much faster than before. Now, let’s look at the Query
--         Profile again to see what happened.
--         As you can see, the query gave us the exact same result in just a few
--         milliseconds because it was serving us the same results from the
--         query result cache in the cloud services layer. This is a ready-to-go
--         feature that you don’t have to think about. You can just run your
--         query a second time and get the same results again if needed.

-- 9.1.12  Close the tab.
--         Close this tab and return to the tab with your worksheet.

-- 9.2.0   Metadata
--         When data is written into Snowflake partitions, the MAX, MIN, COUNT,
--         and other values are stored in the metadata in the Cloud Services
--         layer. This means that when your query needs these values, rather
--         than scanning the table and calculating the values, it simply pulls
--         them from the metadata. This makes your query run much faster. Let’s
--         try it out!

-- 9.2.1   Scenario:
--         Let’s imagine you’ve been asked to analyze part and supplier data. We
--         will use the PARTSUPP table in our database called
--         SNOWFLAKE_SAMPLE_DATA because it provides enough data for this
--         exercise.

-- 9.2.2   Set the context.
--         Note that we’re setting USE_CACHED_RESULT = FALSE to avoid using the
--         query result cache. Then, you’ll suspend your virtual warehouse to
--         ensure you’re not using previously cached data.

USE ROLE TRAINING_ROLE;
USE WAREHOUSE LEARNER_WH;
USE SCHEMA SNOWFLAKE_SAMPLE_DATA.TPCH_SF10;
ALTER SESSION SET USE_CACHED_RESULT = FALSE;

ALTER WAREHOUSE LEARNER_WH SUSPEND;

--         If you got an error when you tried to suspend your virtual warehouse,
--         that’s probably because it was already suspended. That means the
--         cache has already been cleared.

-- 9.2.3   Run the following SQL statement.

SELECT 
          MIN(ps_partkey),
          MAX(ps_partkey)     
FROM 
        PARTSUPP;

--         Now check the Query Profile. You should see a single node that says
--         METADATA-BASED RESULT. This is because the required information is
--         available in the metadata that is cached in the cloud services layer.
--         A table scan is not required.
--         Close the Query Profile tab when you are done.

-- 9.3.0   Data Cache
--         Snowflake caches data from queries you run so it can be accessed
--         later by other queries. This cache is saved to disk in the virtual
--         warehouse. Let’s take a look at how it works. Once again, let’s
--         assume you’ve been asked to analyze part and supplier data.

-- 9.3.1   Run the SQL statement below.
--         Let’s start by selecting two columns, ps_partkey, and ps_availqty,
--         with a WHERE clause that selects only part of the dataset. For any
--         rows the query retrieves, this will cache the data for the two
--         columns.

SELECT 
          ps_partkey,
          ps_availqty
        
FROM 
        PARTSUPP
        
WHERE 
        ps_partkey > 1000000; 


-- 9.3.2   Look at Percentage scanned from cache under Statistics in the Query
--         Profile.
--         You should see that the percentage scanned from cache is 0.00%. This
--         is because we ran the query for the first time on a newly resumed
--         virtual warehouse.
--         Close the Query Profile tab when you are done.

-- 9.3.3   Rerun the query.

SELECT 
          ps_partkey,
          ps_availqty
        
FROM 
        PARTSUPP
        
WHERE 
        ps_partkey > 1000000; 


-- 9.3.4   Look at percentage scanned from cache under Statistics in the Query
--         Profile.
--         You should see that the percentage scanned from cache is 100.00%.
--         This is because the query got 100% of the data it needed from the
--         data cache. This results in faster performance than a query that does
--         a lot of disk I/O.
--         Close the Query Profile tab when you are done.

-- 9.3.5   Add columns, run the query, and check the Query Profile.

SELECT 
          ps_partkey,
          ps_suppkey,
          ps_availqty,
          PS_supplycost,
          ps_comment
        
FROM 
        PARTSUPP
        
WHERE 
        ps_partkey > 1000000;  

--         When you check the percentage scanned from cache, it should be less
--         than 100%. This is because we added columns that weren’t fetched
--         previously, so some disk I/O must occur to fetch the data in those
--         columns.
--         Close the Query Profile tab when you are done.

-- 9.4.0   Partition Pruning
--         Partition pruning is a process by which Snowflake eliminates
--         partitions from a table scan based on the query’s WHERE clause and
--         the partition’s metadata. This means fewer partitions are read from
--         the storage layer or are involved in filtering and joining, which
--         gives you better performance.
--         Data in Snowflake tables will be organized based on how the data is
--         ingested. For example, if the data in a table has been organized
--         based on a particular column, knowing which column that is and
--         including it in joins or in WHERE clause predicates will result in
--         more partitions being pruned and, thus, better query performance.
--         Let’s look at an example. We will be using a different and larger
--         dataset than our PROMO_CATALOG_SALES dataset to use partition
--         pruning. Let’s select the dataset and set our virtual warehouse size
--         to xsmall.

-- 9.4.1   Set the context and virtual warehouse size.

USE SCHEMA SNOWFLAKE_SAMPLE_DATA.TPCDS_SF10TCL;
ALTER WAREHOUSE LEARNER_WH SET WAREHOUSE_SIZE = 'XSMALL';


-- 9.4.2   Execute a query with partition pruning.
--         Imagine that the Snowbear Air marketing team has asked you for a list
--         of customer addresses via a join on the CUSTOMER and CUSTOMER_ADDRESS
--         tables. The data in the CUSTOMER table has been organized based on
--         C_CUSTOMER_SK, which is a unique identifier for each customer. The
--         WHERE clause filters on both C_CUSTOMER_SK and C_LAST_NAME. Execute
--         the query below and check the Query Profile to see what happens.

SELECT  
          C_CUSTOMER_SK,
          C_LAST_NAME,
          (CA_STREET_NUMBER || ' ' || CA_STREET_NAME) AS CUST_ADDRESS,
          CA_CITY,
          CA_STATE  
FROM 
          CUSTOMER
          INNER JOIN CUSTOMER_ADDRESS ON C_CUSTOMER_ID = CA_ADDRESS_ID
WHERE 
        C_CUSTOMER_SK between 100000 and 600000
        AND
        C_LAST_NAME LIKE 'Johnson' 
ORDER BY 
          CA_CITY,
          CA_STATE;

--         If you click on the nodes for each TableScan and look at the total
--         partitions, you’ll see that the CUSTOMER and CUSTOMER_ADDRESS tables
--         have just over 500 total partitions between them.
--         The Query Profile tells us that the query ran in a few seconds, and
--         only about half of the partitions were scanned. So, this query ran
--         faster than it would have otherwise because partition pruning worked
--         for us.
--         Now, let’s run a query without the C_CUSTOMER_SK field in the WHERE
--         clause predicate and see what happens.

-- 9.4.3   Execute a query without partition pruning and check the Query
--         Profile.

SELECT  
          C_CUSTOMER_SK,
          C_LAST_NAME,
          (CA_STREET_NUMBER || ' ' || CA_STREET_NAME) AS CUST_ADDRESS,
          CA_CITY,
          CA_STATE  
FROM 
          CUSTOMER
          INNER JOIN CUSTOMER_ADDRESS ON C_CUSTOMER_ID = CA_ADDRESS_ID
WHERE 
        C_LAST_NAME = 'Johnson' 
ORDER BY 
          CA_CITY,
          CA_STATE;

--         The Query Profile tells us that this query took longer to run, and
--         all partitions were scanned. This is because the data in the CUSTOMER
--         table is not organized on the C_LAST_NAME column, so more partitions
--         had to be scanned in order for us to get our query result. The
--         takeaway is that understanding how your table’s data is organized can
--         help you write more efficient queries.

-- 9.5.0   Determine If Spillage Is Taking Place
--         Now, let’s determine if spillage is taking place in one of our
--         queries. Spillage means that data is spilled to disk within the
--         virtual warehouse because an operation cannot fit completely in
--         memory. This is known as local spillage. When the disk in the virtual
--         warehouse is full, the operation begins to spill to storage. This is
--         known as remote spillage. Operations that incur spillage are slower
--         than memory access and can greatly slow query execution. Thus, you
--         need to be able to identify and rectify spillage.
--         Let’s imagine that Snowbear Air wants to determine the average list
--         price, average sales price, and average quantity for both male and
--         female buyers in the year 2000 for the months January through
--         October.
--         Rather than use our PROMO_CATALOG_SALES database for this scenario,
--         we will use another database with enough data to create spillage. The
--         structure and content of the data is less important than the fact
--         that we can generate and resolve a spillage issue.

-- 9.5.1   Clear the data cache.

ALTER WAREHOUSE LEARNER_WH SUSPEND;

ALTER WAREHOUSE LEARNER_WH RESUME;


-- 9.5.2   Run a query that generates spillage.
--         Note that the query below has a nested query. The nested query
--         determines the average list price, average sales price, and average
--         quantity per gender type and order number. The outer query then
--         aggregates those values by gender.
--         Run the query below. It should take about two minutes to run (your
--         results may vary).

SELECT 
          cd_gender,
          AVG(lp) average_list_price,
          AVG(sp) average_sales_price,
          AVG(qu) average_quantity
FROM 
        (
          SELECT 
                  cd_gender,
                  cs_order_number,
                  AVG(cs_list_price) lp,
                  AVG(cs_sales_price) sp,
                  AVG(cs_quantity) qu
          FROM 
                  catalog_sales,
                  date_dim,
                  customer_demographics
          WHERE 
                cs_sold_date_sk = d_date_sk
                AND 
                cs_bill_cdemo_sk = cd_demo_sk
                AND 
                d_year IN (2000) 
                AND 
                d_moy IN (1,2,3,4,5,6,7,8,9,10)
         GROUP BY 
                  cd_gender,
                  cs_order_number
        ) inner_query
GROUP BY 
        cd_gender;


-- 9.5.3   View the results.
--         For female buyers, you should see something very similar to the
--         following figures:
--         average_list_price: 100.995691505527
--         average_sales_price: 50.494185840967
--         average_quantity: 50.497579311044
--         For male buyers, you should see something very similar to the
--         following figures:
--         average_list_price: 100.992076976143
--         average_sales_price: 50.491772005658
--         average_quantity: 50.499846880459

-- 9.5.4   Check out the Query Profile.
--         Go to the Query Profile. As you will see at the bottom of the
--         Statistics, gigabytes of data were spilled to local storage. Notice
--         there are two Aggregate nodes in the query. Click on each and notice
--         the first Aggregate node is where the spillage is happening. This
--         node is part of the inner query. Let’s rectify this issue by
--         rewriting our query.
--         If you look back at the query you just ran, you’ll see that the outer
--         query is not really necessary. All you need to do is remove the
--         cs_order_number column from the nested query and then run it.

-- 9.5.5   Run the modified nested query.
--         We’ll suspend the virtual warehouse first to flush any cache so we
--         can get a true reading of how long it will take for the query to run.

ALTER WAREHOUSE LEARNER_WH SUSPEND;

--         Run the query.

SELECT 
         cd_gender,
         AVG(cs_list_price) lp,
         AVG(cs_sales_price) sp,
         AVG(cs_quantity) qu
FROM 
        catalog_sales,
        date_dim,
        customer_demographics
WHERE 
      cs_sold_date_sk = d_date_sk
      AND 
      cs_bill_cdemo_sk = cd_demo_sk
      AND 
      d_year IN (2000) 
      AND 
      d_moy IN (1,2,3,4,5,6,7,8,9,10)
GROUP BY 
          cd_gender;


-- 9.5.6   Check your results.
--         The query should have run in about one minute (your results may
--         vary). Compare your results to the ones you got previously. They may
--         be slightly different past the hundreds place to the right of the
--         decimal, but that is due to the differences in rounding between the
--         original query and the modified nested query. So, in essence, you got
--         the same results only in far less time.

-- 9.5.7   Check the Query Profile.
--         As you will see at the bottom of the Statistics, there is no longer a
--         spillage entry. This means you resolved your spillage issue by simply
--         rewriting your query to make it more efficient.

-- 9.6.0   Review the output from the EXPLAIN
--         Now, let’s compare the EXPLAIN from both queries we ran to see how
--         they are different.

-- 9.6.1   Use EXPLAIN to see the plan for the first query.

EXPLAIN
SELECT 
          cd_gender,
          AVG(lp) average_list_price,
          AVG(sp) average_sales_price,
          AVG(qu) average_quantity
FROM 
        (
          SELECT 
                  cd_gender,
                  cs_order_number,
                  AVG(cs_list_price) lp,
                  AVG(cs_sales_price) sp,
                  AVG(cs_quantity) qu
          FROM 
                  catalog_sales,
                  date_dim,
                  customer_demographics
          WHERE 
                cs_sold_date_sk = d_date_sk
                AND 
                cs_bill_cdemo_sk = cd_demo_sk
                AND 
                d_year IN (2000) 
                AND 
                d_moy IN (1,2,3,4,5,6,7,8,9,10)
          
          GROUP BY 
                  cd_gender,
                  cs_order_number
        ) inner_query
GROUP BY 
        cd_gender;


-- 9.6.2   Sort the rows using the operation column.
--         Hover over the operation column header. Click the ellipsis that
--         appears, and select the upward-pointing arrow to sort the column in
--         ascending order.
--         Note that there are 12 rows that correspond to the execution nodes
--         that you would see in the Query Profile. Also, note that two of the
--         rows are aggregate rows. The aggregation expression below does the
--         averaging of the list price, sales price, and quantity:

-- 9.6.3   Run the EXPLAIN for the second query.

EXPLAIN        
SELECT 
         cd_gender,
         AVG(cs_list_price) lp,
         AVG(cs_sales_price) sp,
         AVG(cs_quantity) qu
FROM 
        catalog_sales,
        date_dim,
        customer_demographics
WHERE 
      cs_sold_date_sk = d_date_sk
      AND 
      cs_bill_cdemo_sk = cd_demo_sk
      AND 
      d_year IN (2000) 
      AND 
      d_moy IN (1,2,3,4,5,6,7,8,9,10)
GROUP BY 
          cd_gender;

--         Notice now that this plan is identical to the first one except that
--         there is one less aggregate row than in the previous explain (for a
--         total of 11 rows). Specifically, the node shown in the previous step
--         in this lab is the one that is gone because we removed the outer
--         query. Making that change alone was enough to cut query time by more
--         than half.

-- 9.6.4   Change your virtual warehouse’s size, then suspend it.

ALTER WAREHOUSE LEARNER_WH
    SET WAREHOUSE_SIZE = 'XSmall';

ALTER WAREHOUSE LEARNER_WH SUSPEND;


-- 9.7.0   Summary
--         Writing efficient queries is an art that takes a solid understanding
--         of how Snowflake caching and query pruning impact query performance.
--         While it’s impossible to show you every single scenario, you should
--         know that getting proficient at using tools like the Query Profile
--         and the EXPLAIN will help you better understand how caching impacts
--         your query performance. This, in turn, will allow you to write better
--         queries that achieve a shorter run time.

-- 9.8.0   Key takeaways
--         - Snowflake employs caching to help you get the query results you
--         want as quickly as possible.
--         - Cache is turned on by default, and it works for you in the
--         background without you having to do anything.
--         - The Query Profile is a useful tool for understanding how caching
--         and partition pruning impact your queries.
--         - As you add or remove columns to/from a SELECT clause or a WHERE
--         clause, your percentage scanned from cache value could go up or down.
--         - If your query only requests MIN or MAX values on INTEGER, DATE, or
--         DATETIME data types, those values will come from metadata in the
--         Cloud Services layer rather than from disk I/O, which results in
--         better performance.
--         - Query Result cache is invoked when you run the exact same query
--         twice.
--         - Data cache resides in the virtual warehouse and stores data from
--         past queries on a least recently used (LRU) basis until the virtual
--         warehouse is suspended. However, once the virtual warehouse is
--         suspended, its data cache is cleared.
--         - Including the column on which a table’s data is organized in a
--         WHERE clause predicate can improve partition pruning, which in turn
--         improves performance.
--         - Using EXPLAIN can give you insight into how Snowflake will execute
--         your query. You can use it to identify and remove bottlenecks in your
--         query so you can resolve them and get better efficiency.

-- 9.9.0   Return to the Lab Exercise Page in the Course and Click the Mark as
--         complete Button
