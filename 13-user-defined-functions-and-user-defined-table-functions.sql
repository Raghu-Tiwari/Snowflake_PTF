
-- 13.0.0  User-Defined Functions and User-Defined Table Functions
--         The purpose of this lab is to familiarize you with user-defined
--         functions and user-defined table functions in Snowflake.
--         - Create a JavaScript user-defined function.
--         - Create a SQL user-defined function.
--         - Create a SQL user-defined table function.
--         This lab should take you approximately 10 minutes to complete.
--         Snowbear Air is creating an application where an internal
--         representative can search for a customer by either country or region.
--         The customer will also be able to view line item details of the top
--         10 orders by order total that the customer placed, including the net
--         line item total.
--         In this lab, you will create a series of user-defined functions and
--         user-defined table functions that will enable the previously
--         mentioned functionality.
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

-- 13.1.0  Enable a Customer Search via a User-defined Table Function
--         First, let’s create a function that will allow us to find customers
--         by either nation or region.
--         Below, we’ll present parts of the code and walk you through what each
--         part does. Don’t run the code until the instructions say to run it,
--         or you’ll get an error.

-- 13.1.1  Set your context.

USE ROLE TRAINING_ROLE;

CREATE WAREHOUSE IF NOT EXISTS LEARNER_WH;
USE WAREHOUSE LEARNER_WH;

CREATE DATABASE IF NOT EXISTS LEARNER_DB;
USE LEARNER_DB.PUBLIC;


-- 13.1.2  Write the CREATE FUNCTION portion of the statement.
--         Take a look at the code below, but don’t run the code as it is
--         incomplete.

CREATE OR REPLACE FUNCTION get_customers_by_nation_region ( region_nation varchar )

--         In the CREATE portion of the statement, the function is named and the
--         input parameters and their data types are specifically designated. In
--         this case, either the region or nation can be passed to the function
--         to be evaluated.

-- 13.1.3  Add the RETURNS TABLE portion of the function.
--         Let’s assume we’ve been given a requirement to return the customer
--         ID, customer first and last names, and the customer’s geographical
--         region and nation. Take a look at the code below, but don’t run it.

CREATE OR REPLACE FUNCTION get_customers_by_nation_region ( region_nation varchar )
  RETURNS TABLE (customer_id number, first_name varchar, last_name varchar, region varchar, nation varchar)
  AS
    $$
    
    $$;

--         In this portion, the return parameters and their data types have been
--         specifically designated.
--         Also, the AS block has been added, and it starts and ends with two
--         dollar sign symbols. We’ll now add the SQL statement that will fetch
--         the values to return.

-- 13.1.4  Add the SQL.
--         Below, the SQL has been added, which completes the function. Go ahead
--         and run the CREATE statement.

CREATE OR REPLACE FUNCTION get_customers_by_nation_region ( region_nation varchar )
  RETURNS TABLE (customer_id number, first_name varchar, last_name varchar, region varchar, nation varchar)
  AS
    $$
    SELECT 
          C.C_CUSTKEY AS customer_id
        , C.C_FIRSTNAME AS first_name
        , C.C_LASTNAME AS last_name
        , R.R_NAME AS region        
        , N.N_NAME AS nation
    FROM 
        SNOWBEARAIR_DB.PROMO_CATALOG_SALES.CUSTOMER C
        INNER JOIN SNOWBEARAIR_DB.PROMO_CATALOG_SALES.NATION N ON C.C_NATIONKEY = N.N_NATIONKEY
        INNER JOIN SNOWBEARAIR_DB.PROMO_CATALOG_SALES.REGION R ON N.N_REGIONKEY = R.R_REGIONKEY
    WHERE
        (
            N.N_NAME = region_nation
            OR
            R.R_NAME = region_nation
          )
    ORDER BY last_name, first_name
    $$;

--         The SQL statement that was added has a WHERE clause that evaluates
--         both the region and nation assigned to the customer. This allows the
--         user to pass either a nation or region to execute the search.
--         Now, let’s try the search out.

-- 13.1.5  Run the statements below.
--         Note that in each of the statements below, the function you just
--         created is wrapped by the TABLE() keyword.

    SELECT * FROM TABLE (get_customers_by_nation_region('APAC'));
    
    SELECT * FROM TABLE (get_customers_by_nation_region('BRAZIL'));

--         In the first SELECT statement, the region APAC is passed, which
--         produces a list of a little over 30,000 customers. The next passes
--         the nation BRAZIL, which produces a list of around 6,000 names.
--         Scroll down to find the last name in the list, which should be Noah
--         Yamada, customer ID 149998. Below, we’ll use this ID number to fetch
--         a list of Noah’s top 10 orders by order total.

-- 13.1.6  Fetch a list of the top 10 orders for Noah Yamada.
--         Run the statement below to create a user-defined table function that
--         will fetch the top 10 orders for the customer ID provided:

CREATE OR REPLACE FUNCTION fetch_top_ten_orders ( customer_id number )  
    RETURNS TABLE (order_id number, order_date date, order_total number)
    AS
    $$
     SELECT TOP 10
         O.O_ORDERKEY as order_id,
         O.O_ORDERDATE as order_date,
         (SUM(L_QUANTITY*P_RETAILPRICE*(1-L_DISCOUNT)*(1+L_TAX)))::NUMBER(18,2) AS net_line_item_total
      FROM
         SNOWBEARAIR_DB.PROMO_CATALOG_SALES.CUSTOMER C
         INNER JOIN SNOWBEARAIR_DB.PROMO_CATALOG_SALES.ORDERS O ON C.C_CUSTKEY = O.O_CUSTKEY
         INNER JOIN SNOWBEARAIR_DB.PROMO_CATALOG_SALES.LINEITEM L ON O.O_ORDERKEY = L.L_ORDERKEY
         INNER JOIN SNOWBEARAIR_DB.PROMO_CATALOG_SALES.PART P ON L.L_PARTKEY = P.P_PARTKEY 
      WHERE
         L_RETURNFLAG <> 'R'
         AND
         C.C_CUSTKEY = customer_id 
      GROUP BY
         O.O_ORDERKEY, O.O_ORDERDATE
      ORDER BY 
          net_line_item_total DESC
    $$;    

--         As you can see, the function above will return an order ID, order
--         date, and order total. The grand total for each order is calculated
--         by multiplying the quantity of items purchased by the price per item,
--         applying a discount rate and tax rate to the result, and summing up
--         the values for all rows.
--         Notice that the WHERE clause excludes rows with a return flag of R.
--         There are two possible values for that field: R for returned and N
--         for not returned. We’re excluding items that were returned.

-- 13.1.7  Fetch the top 10 orders.
--         Run the statement below.

SELECT * FROM TABLE(fetch_top_ten_orders(149998));

--         You now have a list of the top 10 orders for Noah Yamada. The top-
--         level order should have order ID 67298. We’ll use that below to fetch
--         the order’s line items.
--         Let’s say that the user-defined table function fetches the line items
--         and needs to return the following values for each line item: order
--         id, the line number, the part name, the retail price, quantity sold,
--         the discount percentage applied, the tax percentage applied, and the
--         net line item total. We will create a scalar user-defined function
--         that will do that calculation. Let’s do that now.

-- 13.2.0  Create a Scalar User-defined Function (SQL)
--         In order to calculate the net line item total for each line, we will
--         need to multiply the quantity of a specific part times the retail
--         price and then apply both the discount and the tax rate.
--         Run the statement below to create the function.

CREATE OR REPLACE FUNCTION fetch_net_line_item_total(quantity double, retail_price double, discount_rate double, tax_rate double)
    RETURNS number(18,2)
    AS
    $$
    SELECT (quantity*retail_price*(1-discount_rate)*(1+tax_rate))::number(18,2)
    $$;

--         This user-defined function is not much different than a user-defined
--         table function. It also defines the input and output parameters and
--         their data types. It also applies logic. As you can see, the function
--         selects a single field and casts it as a number with two decimal
--         places.
--         The only differences are that we use the keyword RETURNS instead of
--         RETURNS TABLE, and only a single scalar value is returned. In this
--         case, it is a number with two decimal places.
--         Now, let’s try it out.

-- 13.2.1  Execute the SQL function.
--         Run the statement below to test your new function.

-- Passing in the quantity, retail price, discount rate, and tax rate

SELECT fetch_net_line_item_total(48, 16.35, 0.02, 0.06);

--         You should see a value of 815.25.
--         The function we created above uses SQL to apply our logic, but you
--         can also use JavaScript in the AS block of a function. Let’s look at
--         an example.

-- 13.3.0  Create a Scalar User-defined Function (JavaScript)
--         Run the statement below to create a JavaScript user-defined function.
--         You will see it is functionally the same as the one we created
--         earlier.

CREATE OR REPLACE FUNCTION fetch_net_line_item_total_js(quantity double, retail_price double, discount_rate double, tax_rate double)
    RETURNS double
    LANGUAGE javascript
    AS
    $$
    var net_total = (QUANTITY*RETAIL_PRICE*(1-DISCOUNT_RATE)*(1+TAX_RATE));
    return net_total.toFixed(2);
    $$;

--         As you can see, just after the RETURNS declaration, this function
--         declares the language as JavaScript and the body of the function
--         contains JavaScript.
--         Note that the input parameters within the body of the function are
--         all written in uppercase. This is required in a JavaScript user-
--         defined function, or the parameters won’t be recognized.
--         The return line uses the toFixed() method of the net_total variable
--         to restrict the value returned to two decimals.

-- 13.3.1  Execute the function.
--         Run the statement below to test your new function.

-- Passing in the quantity, retail price, discount rate, and tax rate

SELECT fetch_net_line_item_total_js(48, 16.35, 0.02, 0.06);

--         You should see a value of 815.25.
--         So, as you can see, you can write a scalar user-defined function in
--         either SQL or JavaScript to apply the same logic and get the same
--         result. The only difference is that you cannot query a table or
--         execute any other SQL statements in a JavaScript user-defined
--         function. If you want to do that, you need to write a SQL user-
--         defined function.
--         Next, we’ll write a user-defined table function that will use our
--         scalar user-defined function to fetch the line items for a specific
--         order ID.

-- 13.4.0  Create a User-defined Table Function to Fetch Line Items for a
--         Specific Order
--         Run the SQL statement required to create the function.

CREATE OR REPLACE FUNCTION fetch_order_items ( order_id number )  
    RETURNS TABLE (order_id number, line_number number, part_name varchar, 
                    retail_price number(18,2), quantity number, discount number(18,2), 
                    tax number(18,2), net_line_item_total number(18,2))
    AS
      $$
      SELECT 
                  O.O_ORDERKEY as ord_id
                  , L.L_LINENUMBER AS line_number
                  , P.P_NAME AS part_name
                  , P.P_RETAILPRICE as retail_price
                  , L.L_QUANTITY
                  , L.L_DISCOUNT
                  , L.L_TAX
                  , fetch_net_line_item_total(L.L_QUANTITY, P.P_RETAILPRICE, L.L_DISCOUNT, L.L_TAX) AS net_line_item_total
            FROM
                  SNOWBEARAIR_DB.PROMO_CATALOG_SALES.CUSTOMER C
                  INNER JOIN SNOWBEARAIR_DB.PROMO_CATALOG_SALES.ORDERS O ON C.C_CUSTKEY = O.O_CUSTKEY
                  INNER JOIN SNOWBEARAIR_DB.PROMO_CATALOG_SALES.LINEITEM L ON O.O_ORDERKEY = L.L_ORDERKEY
                  INNER JOIN SNOWBEARAIR_DB.PROMO_CATALOG_SALES.PART P ON L.L_PARTKEY = P.P_PARTKEY
            WHERE
                  L_RETURNFLAG <> 'R'
                  AND
                  O.O_ORDERKEY = order_id
            ORDER BY
                  line_number
      $$;

--         Notice that we call our scalar SQL function fetch_net_line_item_total
--         in the body of the SQL rather than calculate the net line item total
--         within the SQL statement.
--         Now let’s try our function.

-- 13.4.1  Run the query below.

SELECT * FROM TABLE (fetch_order_items(67298));

--         As you can see, our function pulled the line items for a specified
--         order.

-- 13.5.0  Select from a Table Using a Scalar User-defined Function
--         Earlier, we said that you must write a SQL (rather than JavaScript)
--         user-defined function if you need to query a table within a function.
--         Here is a SQL-based user-defined function that pulls the account
--         balance for a specific customer. Run the statement to create the
--         function, then run the SELECT statement to view the result.

  CREATE OR REPLACE FUNCTION fetch_account_balance ( customer_id number )  
    RETURNS number(18,2)
    AS
    $$
    SELECT 
            C.C_ACCTBAL
      FROM
            SNOWBEARAIR_DB.PROMO_CATALOG_SALES.CUSTOMER C
      WHERE
            C.C_CUSTKEY = customer_id
    $$;          
              
 SELECT fetch_account_balance (149998);

--         Note that you can only execute one SQL statement within a SQL user-
--         defined function.

-- 13.5.1  Suspend your virtual warehouse.

ALTER WAREHOUSE LEARNER_wh SUSPEND;


-- 13.6.0  Key Takeaways
--         - In the LANGUAGE clause of a user-defined function, you can
--         explicitly state that the language is JavaScript. Snowflake will then
--         know exactly what to do with the script between the dollar sign
--         marks.
--         - The input parameters within the body of a JavaScript user-defined
--         function must be written entirely in uppercase. This is necessary
--         because the function won’t recognize the parameters if they have any
--         lowercase characters.
--         - You cannot query a table or execute any other SQL statements in a
--         JavaScript user-defined function.
--         - You can have only one SQL statement in a SQL user-defined function.

-- 13.7.0  Return to the Lab Exercise Page in the Course and Click the Mark as
--         complete Button
