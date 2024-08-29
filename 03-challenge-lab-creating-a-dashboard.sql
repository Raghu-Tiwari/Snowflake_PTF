
-- 3.0.0   Challenge Lab: Creating A Dashboard
--         The purpose of this lab is to give you an on-your-own experience
--         creating dashboards in Snowsight. We’ll provide some SQL code,
--         details about the expected result, and some hints. Otherwise, you’ll
--         create the final dashboard on your own.
--         If you need more than the hints provided, the solution can be found
--         at the end of this lab.
--         - Create a dashboard.
--         - Add tiles to a dashboard.
--         - Create a bar chart.
--         This lab should take you approximately 60 minutes to complete.
--         Snowbear Air has assigned you to create a dashboard for the sales
--         team that displays the following:
--         - Top five customers
--         - Top five countries
--         - Top five suppliers by net revenue
--         - Net revenue for all regions
--         The sales team wants this dashboard to display the data visually, so
--         you’ll need to create bar charts for each of the four data sets.

-- 3.1.0   Look at the Expected Result Before Starting
--         Your final dashboard should look like the one shown below.
--         The numbers in your charts may differ from what is shown in this
--         screenshot.

-- 3.2.0   Be Sure to Set Your Context
--         Below is what your context should be when you are creating your
--         dashboard.
--         - Role: TRAINING_ROLE
--         - Warehouse: LEARNER_WH
--         - Database: SNOWBEARAIR_DB
--         - Schema: PROMO_CATALOG_SALES

-- 3.3.0   Read the Hints Before Starting
--         There are two ways to add tiles to a dashboard: The + New Tile button
--         in the center of a new empty dashboard, and the + button just below
--         the home button.
--         You can click on a tile and hold down the mouse button to reposition
--         it.
--         You must select a role and virtual warehouse before any code in the
--         worksheets will run.
--         In each worksheet, you must select the database and schema before any
--         code will run.
--         HOW TO COMPLETE THIS LAB
--         In the previous lab, you may have created a new worksheet, loaded the
--         SQL file for the lab, and then followed the instructions contained in
--         the file without ever looking at the workbook PDF. That approach will
--         be modified due to the nature of this exercise.
--         Let’s get started!

-- 3.4.0   Create Your Dashboard
--         Follow the steps below to create your dashboard.

-- 3.4.1   Open the workbook PDF if you haven’t already done so.
--         If you use the SQL file instead of the workbook PDF to follow the
--         instructions for this lab, you will not see the screenshot of the
--         expected result that can only be seen in the workbook PDF. The best
--         way to complete this lab is to use the PDF workbook instructions for
--         the entire lab from start to finish.

-- 3.4.2   Open the SQL file in the text editor of your choice if you haven’t
--         already done so.
--         Copying and pasting from the workbook PDF will result in errors!
--         Also, importing the entire file into a single tile’s worksheet means
--         all four queries will be executed when the tile refreshes, negatively
--         impacting performance. The best way to put code in each tile’s
--         worksheet is to open the SQL file in the text editor of your choice
--         and copy and paste from there.

-- 3.4.3   Create a new dashboard

-- 3.4.4   Place each of the four queries below into the worksheet for the new
--         dashboard tiles you create.
--         As you create each new tile, put the appropriate query into the
--         worksheet, run the query, and then click the Chart button.

-------------------
-- Query 1 of 4
-- Top 5 Customers
-------------------

SELECT TOP 5
          C.C_FIRSTNAME||' '||C.C_LASTNAME AS CUSTOMER_NAME,
          SUM(L_QUANTITY*P_RETAILPRICE*(1-L_DISCOUNT)*(1+L_TAX))::DECIMAL(18,2) AS SUM_NET_REVENUE

FROM
        CUSTOMER C 
        INNER JOIN ORDERS O ON C.C_CUSTKEY = O.O_CUSTKEY
        INNER JOIN LINEITEM L ON O.O_ORDERKEY = L.L_ORDERKEY
        INNER JOIN PART P ON L.L_PARTKEY = P.P_PARTKEY
GROUP BY
        CUSTOMER_NAME
  
ORDER BY
        SUM_NET_REVENUE DESC;

-------------------
-- Query 2 of 4
-- Top 5 Nations
-------------------

SELECT TOP 5
          N.N_NAME AS NATION,
          SUM(L_QUANTITY*P_RETAILPRICE*(1-L_DISCOUNT)*(1+L_TAX))::DECIMAL(18,2) AS SUM_NET_REVENUE

FROM
        REGION R
        INNER JOIN NATION N ON R.R_REGIONKEY = N.N_REGIONKEY
        INNER JOIN CUSTOMER C ON N.N_NATIONKEY = C.C_NATIONKEY
        INNER JOIN ORDERS O ON C.C_CUSTKEY = O.O_CUSTKEY
        INNER JOIN LINEITEM L ON O.O_ORDERKEY = L.L_ORDERKEY
        INNER JOIN PART P ON L.L_PARTKEY = P.P_PARTKEY

GROUP BY
        N.N_NAME
  
ORDER BY
        SUM_NET_REVENUE DESC;

-------------------
-- Query 3 of 4
-- TOP 5 SUPPLIERS
-------------------

SELECT TOP 5
          S.S_NAME AS SUPPLIER_NAME,
          SUM(L_QUANTITY*P_RETAILPRICE*(1-L_DISCOUNT)*(1+L_TAX))::DECIMAL(18,2) AS SUM_NET_REVENUE

FROM
        CUSTOMER C
        INNER JOIN ORDERS O ON C.C_CUSTKEY = O.O_CUSTKEY
        INNER JOIN LINEITEM L ON O.O_ORDERKEY = L.L_ORDERKEY
        INNER JOIN SUPPLIER S ON L.L_SUPPKEY = S.S_SUPPKEY
        INNER JOIN PART P ON L.L_PARTKEY = P.P_PARTKEY
        
GROUP BY
        S.S_NAME
  
ORDER BY
        SUM_NET_REVENUE DESC;

-------------------
-- Query 4 of 4
-- ALL REGIONS
-------------------

SELECT 
          R.R_NAME AS REGION_NAME,
          SUM(L_QUANTITY*P_RETAILPRICE*(1-L_DISCOUNT)*(1+L_TAX))::DECIMAL(18,2) AS SUM_NET_REVENUE

FROM
        REGION R
        INNER JOIN NATION N ON R.R_REGIONKEY = N.N_REGIONKEY
        INNER JOIN CUSTOMER C ON N.N_NATIONKEY = C.C_NATIONKEY
        INNER JOIN ORDERS O ON C.C_CUSTKEY = O.O_CUSTKEY
        INNER JOIN LINEITEM L ON O.O_ORDERKEY = L.L_ORDERKEY
        INNER JOIN PART P ON L.L_PARTKEY = P.P_PARTKEY
GROUP BY
        R.R_NAME
  
ORDER BY
        SUM_NET_REVENUE DESC;


--         If you need help, check out the solution on the next page. Otherwise,
--         congratulations! You have now completed this lab.

-- 3.5.0   Solution
--         If you really need to, you can look at the solution below. But try
--         not to peek! You’ll learn more if you try it on your own first and
--         rely only on the hints.

-- 3.6.0   Solution for Creating a Dashboard
--         The steps below show you how to create a dashboard from scratch. If
--         you have a worksheet that you want to turn into a tile on the
--         dashboard, an alternate method is to create a new dashboard from a
--         worksheet. To do this, click the vertical ellipsis to the right of
--         the worksheet name, and in the drop-down menu, navigate to Move to
--         and then select + New Dashboard.

-- 3.6.1   From the home screen, in the left-side navigation bar select
--         Projects, then select Dashboards.

-- 3.6.2   Click the + Dashboard button in the upper right.

-- 3.6.3   A prompt will appear. Type a name for the dashboard and click the
--         Create Dashboard button.

-- 3.6.4   Once the dashboard is open, select the role and virtual warehouse at
--         the very top of the page.
--         - Role: TRAINING_ROLE
--         - Warehouse: LEARNER_WH

-- 3.6.5   Click the New Tile button in the center of the page.
--         Select From SQL Worksheet from the drop-down menu.

-- 3.6.6   Just above the SQL pane, select the database and schema.
--         - Database: SNOWBEARAIR_DB
--         - Schema: PROMO_CATALOG_SALES

-- 3.6.7   Copy and paste your query into the pane.
--         For example, copy and paste Query 1 of 4 from the lab SQL file for
--         the first tile.

-- 3.6.8   Run the query.
--         Either click the run button in the upper-right area of the worksheet
--         or use the keyboard shortcut.

-- 3.6.9   If creating a chart, click the Chart button above the query results.

-- 3.6.10  When the chart is visible, click Chart type in the right side menu to
--         change the chart to a bar chart.

-- 3.6.11  Select the desired Orientation for the bar chart in the Appearance
--         section.

-- 3.6.12  If you want to label the X or Y axis, enable the options and give an
--         appropriate name.

-- 3.6.13  Rename the worksheet.
--         Rename the worksheet based on the expected results shown at the start
--         of the lab, for example, name the first tile Top 5 Customers. Click
--         the arrow next to the date/time at the top of the worksheet, type in
--         the new name, and hit enter.

-- 3.6.14  Return to the dashboard.
--         Click the Return to dashboard name link in the upper-left area of the
--         worksheet. The tile with the chart should be displayed on the
--         dashboard.

-- 3.6.15  Repeat these steps for each additional tile.
--         To add new tiles, click the + sign at the top left below Dashboards
--         and then click the New Tile button.

-- 3.6.16  Drag and reposition tiles as needed
--         To reposition a tile, navigate to the dashboard and launch it. Hover
--         your mouse cursor over the tile you wish to move, click and hold the
--         mouse button. While holding down the mouse button, drag the tile to
--         the desired position and release the mouse button.

-- 3.7.0   Return to the Lab Exercise Page in the Course and Click the Mark as
--         complete Button
