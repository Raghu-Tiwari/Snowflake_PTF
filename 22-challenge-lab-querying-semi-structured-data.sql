
-- 22.0.0  Challenge Lab: Querying Semi-Structured Data
--         The purpose of this lab is to give you an on-your-own experience
--         querying semi-structured data in Snowflake. We’ll provide some hints,
--         but otherwise, you’ll do the work on your own.
--         If you need more than the hints provided, the solution can be found
--         at the end of this lab.
--         - Analyze semi-structured JSON data.
--         - Write queries that extract data from nested arrays and objects in
--         semi-structured JSON data.
--         This lab should take you approximately 50 minutes to complete.
--         Snowbear Air has asked you to extract some employee data from some
--         semi-structured JSON data. Specifically, they want you to extract
--         business and personal phone numbers, email addresses, and physical
--         and mailing addresses.
--         There are two parts to this exercise. In the first, part you’ll use
--         dot notation to query the data. In the second, you’ll use FLATTEN to
--         get the data you need.

-- 22.1.0  Hints
--         Take some time to analyze the data and figure out which parts are
--         arrays and which are objects.
--         Square brackets denote arrays.
--         When you see a key-value pair, and the pair has several key-value
--         pairs nested within, that is an object.
--         Expect complex nesting!
--         You can use FLATTEN more than once in the same SQL statement.
--         When writing queries using FLATTEN, think about using recursive =>
--         true in your input if you have repeating rows and there are nested
--         values you can’t seem to extract.
--         This lab may be difficult if you’ve never worked with semi-structured
--         data. Semi-structured data can be tricky to query but very rewarding
--         when you do it successfully. Take your time, really look at the data,
--         and analyze the diagram included in this exercise.
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

-- 22.2.0  Create the JSON Data
--         You must complete all the steps in this section to complete this
--         challenge lab successfully.

-- 22.2.1  Set your context for the lab and make sure you have the standard
--         objects.

USE ROLE TRAINING_ROLE;

CREATE WAREHOUSE IF NOT EXISTS LEARNER_WH INITIALLY_SUSPENDED=TRUE;
USE WAREHOUSE LEARNER_WH;

CREATE DATABASE IF NOT EXISTS LEARNER_DB;
USE DATABASE LEARNER_DB;

CREATE SCHEMA IF NOT EXISTS LEARNER_DB.LEARNER_SCHEMA;
USE LEARNER_DB.LEARNER_SCHEMA;


-- 22.2.2  Run the SQL statement below to create the JSON data.

CREATE OR REPLACE TABLE personnel 
AS 
SELECT
  $1 AS id,
   parse_json($2) AS employee
FROM VALUES
   (
    12712555,
   '{"name": {"first":"John", "last":"Smith"},
     "contact":[
                    {"business": 
                      [{
                        "numbers":[{
                                 "phone": {
                                            "desk":"303-555-1111", 
                                            "cell":"303-555-2222", 
                                            "fax":"303-555-3333",
                                            "pager":"303-555-8989"       
                                          }
                                }],
                        },
                        {     
                        "other":[{
                                "address": {
                                          "office":"1 Tech Ln, Boulder, CO 99999", 
                                          "mailing":"PO Box 1111, Boulder, CO 99999"
                                       },
                                 },
                                {    
                                "email":{"office_email":"j.smith@company.com"}
                                }]
                        }]
                    },
                    {"personal": 
                        [{
                          "numbers":[{   
                                "phone": {
                                            "land":"303-555-4444", 
                                            "cell":"303-555-5555"
                                          }
                                    }]
                         },
                         {
                          "other":[{
                                    "address": {
                                            "home":"123 Main St, Boulder, CO 99999", 
                                            "mailing":"PO Box 2222, Boulder, CO 99999"
                                                },   
                                    },
                                    {
                                    "email":{
                                            "primary":"jsmith@homeemail.com",
                                            "secondary1":"johnny@homeemail.com",                                            
                                            "secondary2":"john@homeemail.com",                
                                            }
                                   }]
                         }]
                  }
                ]
     }'
   ),
   (
    28493821,
   '{"name": {"first":"Jane", "last":"Doe"},
     "contact":[
                    {"business": 
                      [{
                        "numbers":[{
                                 "phone": {
                                            "desk":"303-555-5151", 
                                            "cell":"303-555-7777", 
                                            "fax":"303-555-8888",
                                            "pager":"303-555-7171"       
                                          }
                                }],
                        },
                        {     
                        "other":[{
                                "address": {
                                          "office":"2 Tech Ln, Boulder, CO 99999", 
                                          "mailing":"PO Box 3333, Boulder, CO 99999"
                                       },
                                 },
                                {    
                                "email":{"office_email":"jane.doe@company.com"}
                                }]
                        }]
                    },
                    {"personal": 
                        [{
                          "numbers":[{   
                                "phone": {
                                            "land":"303-555-9999", 
                                            "cell":"303-555-1010"
                                          }
                                    }]
                         },
                         {
                          "other":[{
                                    "address": {
                                            "home":"345 Main St, Boulder, CO 99999", 
                                            "mailing":"PO Box 3333, Boulder, CO 99999"
                                                },   
                                    },
                                    {
       
                                    "email":{
                                            "primary":"janedoe@homeemail.com",
                                            "secondary1":"janie@homeemail.com",                                            
                                            "secondary2":"jane@homeemail.com",                
                                            }
                                   }]
                         }]
                  }
                ]
     }'
   );



-- 22.2.3  Analyze the diagram to understand the paths.
--         As you know, to successfully query any kind of data, you must
--         understand how the data is structured. The challenge of querying
--         nested JSON data (or any other kind of semi-structured data) is
--         identifying the arrays and the objects and figuring out the paths and
--         the nesting.
--         Analyze the diagram below and the SQL statement you just executed to
--         figure out the paths. Keep in mind that semi-structured data could be
--         nested in any number of ways. You could have objects with nested
--         arrays or arrays with nested objects. An object could contain more
--         objects, arrays, simple key-value pairs, or all three. While the
--         beauty of nested data is that you have this kind of flexibility, it
--         also means that figuring out the structure of the data can be
--         challenging. With some patience and perseverance, you can write
--         successful queries against complex, nested, semi-structured data.
--         The SQL statements for the exercises below are included in the
--         solution on the last page of the exercise. Try your best to figure it
--         out on your own without looking at the solution.

-- 22.3.0  Part I - Use Dot Notation
--         In this portion of the lab, you will use dot notation to get only the
--         data you need.

-- 22.3.1  Write a query that extracts all business and personal phone numbers.

-- 22.3.2  Write a query that extracts all business and personal email
--         addresses.

-- 22.3.3  Write a query that extracts all business and personal addresses.

-- 22.3.4  Continue to the next page for the rest of the exercise.

-- 22.4.0  Part II - Use FLATTEN
--         In this portion of the lab, you will use FLATTEN to get only the data
--         you need. The diagram has been included for your reference. The SQL
--         is included in the solution on the last page of the exercise. Try
--         your best to figure it out on your own without looking at the
--         solution.

-- 22.4.1  Write a query that extracts all business phone numbers.

-- 22.4.2  Write a query that extracts all personal phone numbers.

-- 22.4.3  Write a query that extracts all business and personal phone numbers.

-- 22.4.4  Write a query that extracts all business email addresses.

-- 22.4.5  Write a query that extracts all personal email addresses.

-- 22.4.6  Write a query that extracts all business and personal email
--         addresses.

-- 22.4.7  Write a query that extracts all business addresses (office and
--         mailing).

-- 22.4.8  Write a query that extracts all personal addresses (home and
--         mailing).

-- 22.4.9  Write a query that extracts all business and personal addresses.

-- 22.4.10 When you are finished, suspend your virtual warehouse.

ALTER WAREHOUSE LEARNER_WH SUSPEND;

--         If you need help, the solution is on the next page. Otherwise,
--         congratulations! You have now completed this lab.

-- 22.5.0  Solution
--         If you really need to, you can look at the solution below. But try
--         not to peek! You’ll learn more if you try it on your own first and
--         rely only on the hints. The diagram is included below so you can
--         compare it to the code.

  
SELECT * 
FROM personnel;

----------------------------------------
--------- DOT NOTATION -----------------
----------------------------------------

-- Select all business and personal phone numbers

SELECT 
    id,
    employee:name.first::varchar as first_name,
    employee:name.last::varchar as last_name,
    employee:contact[0].business[0].numbers[0].phone.desk::varchar AS desk_phone,
    employee:contact[0].business[0].numbers[0].phone.cell::varchar AS office_cell,
    employee:contact[0].business[0].numbers[0].phone.fax::varchar AS fax_num,
    employee:contact[0].business[0].numbers[0].phone.pager::varchar AS pager,        
    employee:contact[1].personal[0].numbers[0].phone.land::varchar AS home_phone,
    employee:contact[1].personal[0].numbers[0].phone.cell::varchar AS home_cell
    
FROM
    personnel;


-- Select all business and personal email addresses

SELECT 
    id,
    employee:name.first::varchar as first_name,
    employee:name.last::varchar as last_name,
    employee:contact[0].business[1].other[1].email.office_email::varchar AS office_email_addr,    
    employee:contact[1].personal[1].other[1].email.primary::varchar AS primary_email_addr,    
    employee:contact[1].personal[1].other[1].email.secondary1::varchar AS secondary1_email_addr1,
    employee:contact[1].personal[1].other[1].email.secondary2::varchar AS secondary2_email_addr2   
FROM
    personnel;

-- Select all business and personal addresses

SELECT 
    id,
    employee:name.first::varchar as first_name,
    employee:name.last::varchar as last_name,
    employee:contact[0].business[1].other[0].address.office::varchar AS office_addr,
    employee:contact[0].business[1].other[0].address.mailing::varchar AS office_mailing_addr,
    employee:contact[1].personal[1].other[0].address.home::varchar AS home_addr,
    employee:contact[1].personal[1].other[0].address.mailing::varchar AS home_mailing_addr
FROM
    personnel;

----------------------------------------
------------- FLATTEN ------------------
----------------------------------------

-- Fetch all business phone numbers    

SELECT
    d.id,
    d.employee:name.first::varchar as first_name,
    d.employee:name.last::varchar as last_name,
    b.value:desk::varchar AS office_phone,
    b.value:cell::varchar AS office_cell,
    b.value:fax::varchar AS office_fax,
    b.value:pager::varchar AS office_pager
FROM    
    personnel d, 
    lateral flatten(input => d.employee, path => 'contact', recursive=>true) b
    WHERE (b.path like '%business%number%phone')
    ;

-- Fetch all personal phone numbers

SELECT
    d.id,
    d.employee:name.first::varchar as first_name,
    d.employee:name.last::varchar as last_name,
    p.value:land::varchar AS home_phone,
    p.value:cell::varchar AS home_cell
FROM
    personnel d, 
    lateral flatten(input => d.employee, path => 'contact', recursive=>true) p
    WHERE (p.path like '%personal%number%phone')
    ;

-- Fetch all business and personal phone numbers

SELECT
    d.id,
    d.employee:name.first::varchar as first_name,
    d.employee:name.last::varchar as last_name,    
    b.value:desk::varchar AS office_phone,
    b.value:cell::varchar AS office_cell,
    b.value:fax::varchar AS office_fax,
    b.value:pager::varchar AS office_pager,
    p.value:land::varchar AS home_phone,
    p.value:cell::varchar AS home_cell
FROM
    personnel d, 
    lateral flatten(input => d.employee, path => 'contact', recursive=>true) b,
    lateral flatten(input => d.employee, path => 'contact', recursive=>true) p
    WHERE (b.path like '%business%number%phone') AND (p.path like '%personal%number%phone')
    ;

-- Fetch all business email addresses

SELECT
    d.id,
    d.employee:name.first::varchar as first_name,
    d.employee:name.last::varchar as last_name,     
    b.value::varchar office_email
FROM
    personnel d,
    lateral flatten(input => d.employee, path => 'contact', recursive=>true) b
    WHERE (b.path like '%business%other%email%office_email')
    ;
-- Fetch all personal email addresses

SELECT
    d.id,
    d.employee:name.first::varchar as first_name,
    d.employee:name.last::varchar as last_name,
    p.value:primary::varchar personal_email,
    p.value:secondary1::varchar secondary_email_1,
    p.value:secondary2::varchar secondary_email_2
    FROM
    personnel d,
    lateral flatten(input => d.employee, path => 'contact', recursive=>true) p
    WHERE (p.path like '%personal%other%email')
    ;

-- Fetch all business and personal email addresses

SELECT
    d.id,
    d.employee:name.first::varchar as first_name,
    d.employee:name.last::varchar as last_name,     
    b.value::varchar office_email,
    p.value:primary::varchar personal_email,
    p.value:secondary1::varchar secondary_email_1,
    p.value:secondary2::varchar secondary_email_2
FROM
    personnel d,
    lateral flatten(input => d.employee, path => 'contact', recursive=>true) b,
    lateral flatten(input => d.employee, path => 'contact', recursive=>true) p
    WHERE (b.path like '%business%other%email%office_email') AND  (p.path like '%personal%other%email')
    ;
      
-- Fetch all business addresses (office and mailing)

SELECT
    d.id,
    d.employee:name.first::varchar as first_name,
    d.employee:name.last::varchar as last_name,
    b.value:office::varchar as office_addr, 
    b.value:mailing::varchar as office_mailing_addr,
    b.path,
    b.value
FROM
    personnel d, 
    lateral flatten(input => d.employee, path => 'contact', recursive => true) b
    WHERE (b.path like '%business%other%address')
    ;
    
-- Fetch all personal addresses (home and mailing)

SELECT
    d.id,
    d.employee:name.first::varchar as first_name,
    d.employee:name.last::varchar as last_name,
    p.value:home::varchar as home_addr, 
    p.value:mailing::varchar as home_mailing_addr
FROM
    personnel d, 
    lateral flatten(input => d.employee, path => 'contact', recursive => true) p
    WHERE (p.path like '%personal%other%address')
    ;
    
-- Fetch all personal and business addresses

SELECT
    d.id,
    d.employee:name.first::varchar as first_name,
    d.employee:name.last::varchar as last_name,
    b.value:office::varchar as office_addr, 
    b.value:mailing::varchar as office_mailing_addr,
    p.value:home::varchar as home_addr, 
    p.value:mailing::varchar as home_mailing_addr
FROM
    personnel d, 
    lateral flatten(input => d.employee, path => 'contact', recursive => true) b,
    lateral flatten(input => d.employee, path => 'contact', recursive => true) p
    WHERE (b.path like '%business%other%address') AND (p.path like '%personal%other%address')
    ;


-- Suspend your virtual warehouse

ALTER WAREHOUSE LEARNER_wh SUSPEND;



-- 22.6.0  Return to the Lab Exercise Page in the Course and Click the Mark as
--         complete Button
