
-- 8.0.0   Multi-Table Inserts
--         In this lab, you will learn how to execute multi-table inserts, how
--         to use SWAP, and how to execute MERGE statements.
--         - Use sequences to create unique values in a primary key column.
--         - Use unconditional multi-table insert statements.
--         - Use ALTER TABLE  SWAP WITH to swap table content and metadata.
--         - Use MERGE statements to add new rows to a table.
--         This lab should take you approximately 25 minutes to complete.
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

-- 8.1.0   Work with Sequences
--         In this section, you will learn how to create and use a sequence. We
--         will use a sequence in the next section to replace a UUID
--         (universally unique identifier) value with an integer as the unique
--         identifier for each row in a table. Then, we will use the same
--         sequence to express a primary key - foreign key relationship between
--         two tables.
--         Read the section below to get familiar with sequences in Snowflake.
--         SEQUENCE
--         A SEQUENCE is a named object that belongs to a schema in Snowflake.
--         It consists of a set of sequential, unique numbers that increase or
--         decrease in value based on how the sequence is configured. Sequences
--         can be used to populate columns in a Snowflake table with unique
--         values.
--         SEQUENCE PARAMETERS
--         - NAME (required): Identifies the sequence as a unique object within
--         the schema.
--         - START (optional): The first value of the sequence. The default is
--         one.
--         - INCREMENT (optional): The step interval of the sequence. The
--         default is one.
--         - ORDER | NOORDER: Specifies whether or not the values are generated
--         for the sequence in increasing or decreasing order. The default is
--         NOORDER. The behavior can be changed with the
--         NOORDER_SEQUENCE_AS_DEFAULT parameter.
--         NOTE
--         Snowflake does not guarantee the generation of sequence numbers
--         without gaps. The generated numbers are not necessarily contiguous.
--         If the ORDER keyword is specified, the sequence numbers will increase
--         in value if the INCREMENT value is positive or decrease if the
--         INCREMENT value is negative.

-- 8.1.1   Set the context for the lab.

USE ROLE TRAINING_ROLE;

CREATE WAREHOUSE IF NOT EXISTS LEARNER_WH;
USE WAREHOUSE LEARNER_WH;

CREATE DATABASE IF NOT EXISTS LEARNER_DB;

USE SCHEMA LEARNER_DB.PUBLIC;


-- 8.1.2   Create a sequence called item_seq.
--         Here, we’re going to create a sequence called item_seq. We will then
--         use it as a primary key in a table. Note that the start value is one,
--         and the increment value is one. This means we can expect the sequence
--         to start with one and continue with two, three, four, five, etc.

CREATE OR REPLACE SEQUENCE item_seq START = 1 INCREMENT = 1 ORDER;


-- 8.1.3   Now evaluate the nextval expression of the sequence we just created
--         once to see the first value.

-- Show the next value using the nextval method on the sequence object.

SELECT Item_seq.nextval;

--         As you can see, the value is one. The expression <sequence>.nextval
--         returns a new value each time it is evaluated. If you want to apply
--         it to a table, you may want to use the nextval expression for the
--         first time right after creating the sequence. If not, it will pick up
--         the next number in the sequence instead of the first. Let’s test this
--         idea and observe the results.

-- 8.1.4   Create a table, insert some values, and select all values from the
--         table.

-- Create a table with the sequence

CREATE OR REPLACE TABLE item_table ( Item_id INTEGER default Item_seq.nextval, description VARCHAR(20));

-- Insert some rows

INSERT INTO item_table (description) VALUES ('Wheels'), ('Tires'), ('hubcaps');

-- Select all values

SELECT * FROM item_table;

--         As you can see, the first row has an item_id of two rather than one.
--         This is because we iterated to the first sequence value, one when we
--         created the table. So, when we evaluated the nextval expression a
--         second time, the next value was fetched, which was two.
--         Let’s try this again and recreate the sequence and the table.

-- 8.1.5   Recreate the sequence and the table.

-- Reset the sequence. Recreating the sequence is the only way to reset a sequence. 

CREATE OR REPLACE SEQUENCE Item_seq START = 1 INCREMENT = 1 ORDER;

-- Create a table with the sequence.

CREATE OR REPLACE TABLE item_table ( Item_id INTEGER default Item_seq.nextval, description VARCHAR(20));

-- Insert some rows.

INSERT INTO item_table (description) VALUES ('Wheels'), ('Tires'), ('hubcaps');

-- Select all rows from the table

SELECT * FROM item_table;

--         As you can see, the sequence applied to the table now starts with
--         one.

-- 8.1.6   DROP table and sequence.

DROP SEQUENCE item_seq;
DROP TABLE item_table;

--         Before dropping a sequence, verify that no tables or other database
--         objects reference the sequence. View the knowledge base article for
--         details - https://community.snowflake.com/s/article/ERROR-SQL-
--         compilation-error-Sequence-used-as-a-default-value-in-table-table-
--         name-column-column-name-was-not-found-or-could-not-be-accessed

-- 8.1.7   Try the different sequences below and examine the results.
--         The activity below shows how the START and INCREMENT values change
--         the resulting values in a sequence.

CREATE OR REPLACE SEQUENCE seq_1 START = 1 INCREMENT = 1 ORDER;
CREATE OR REPLACE SEQUENCE seq_2 START = 2 INCREMENT = 2 ORDER;
CREATE OR REPLACE SEQUENCE seq_3 START = 3 INCREMENT = 3 ORDER;

-- Run each statement below three or four times

SELECT seq_1.nextval;
SELECT seq_2.nextval;
SELECT seq_3.nextval;


-- 8.2.0   Work with Unconditional Multi-Table Inserts
--         In this section, we will take the SNOWBEARAIR_DB.MODELED.MEMBERS
--         table and divide the data between a customer table, an address table,
--         and a phone table. This will allow a single customer to have multiple
--         addresses and multiple phone numbers.
--         Since we are splitting the original table into three disparate
--         tables, MEMBER_ID is going to be used for the primary key-foreign key
--         relationship between the three tables; an AUTOINCREMENT will not
--         work. We will solve this by using a sequence to insert a new numeric
--         value into each table.
--         In order to do this, we will use a multi-table insert to copy the
--         member data into the three different tables. We will also replace the
--         UUID-based primary key with a sequence.

-- 8.2.1   Create a sequence.
--         Before executing the multi-table insert, we will create a sequence to
--         create a unique ID outside of the table and use it for the MEMBER_ID
--         column. The default for a sequence is START = 1 and INCREMENT = 1.
--         Use this as the default for the MEMBERS table.

CREATE OR REPLACE SEQUENCE member_seq START = 1 INCREMENT = 1 ORDER;


-- 8.2.2   Create the member, member_address and member_phone tables.

CREATE OR REPLACE TABLE member (
   member_id INTEGER DEFAULT member_seq.nextval,
   points_balance NUMBER,
   started_date DATE,
   ended_date DATE,
   registered_date DATE,
   firstname VARCHAR,
   lastname VARCHAR,
   gender VARCHAR,
   age NUMBER,
   email VARCHAR
);

CREATE OR REPLACE TABLE member_address (
   member_id INTEGER,
   street VARCHAR,
   city VARCHAR,
   state VARCHAR,
   zip VARCHAR
);

CREATE OR REPLACE TABLE member_phone (
   member_id INTEGER,
   phone VARCHAR
);


-- 8.2.3   Populate the tables.
--         Next, you’ll execute a multi-table insert statement to copy the data
--         from an existing table into the member, member_address, and
--         member_phone tables.
--         UNCONDITIONAL MULTI-TABLE INSERT SYNTAX A multi-table insert
--         statement can insert rows into multiple tables from the same
--         statement. Note the syntax below:
--         Now, execute the statement below to populate your tables. Note that
--         the sequence member_seq creates our member IDs for us. Also, note how
--         the syntax below reflects what you see in the box above.

INSERT ALL
    INTO member(member_id,
            points_balance,
            started_date,
            ended_date,
            registered_date,
            firstname,
            lastname,
            gender,
            age,
            email)
    VALUES (member_id,
            points_balance,
            started_date,
            ended_date,
            registered_date,
            firstname,
            lastname,
            gender,
            age,
            email)
    INTO member_address (member_id,
            street,
            city,
            state,
             zip)
    VALUES (member_id,
            street,
            city,
            state,
            zip)
    INTO member_phone(member_id,
            phone)
    VALUES (member_id,
            phone)
    SELECT member_seq.NEXTVAL AS member_id,
           points_balance,
           started_date,
           ended_date,
           registered_date,
           firstname,
           lastname,
           gender,
           age,
           email,
           street,
           city,
           state,
           zip,
           phone
     FROM SNOWBEARAIR_DB.MODELED.MEMBERS;


-- 8.2.4   Confirm there is data in the tables.

SELECT * FROM member ORDER BY member_id;

SELECT * FROM member_address;

SELECT * FROM member_phone;


-- 8.2.5   Join the tables and examine the results.
--         Now, let’s run a few queries to see how we can join the tables we
--         created to answer questions about the members and their contact
--         information.

-- Execute a join between the member and the member_address table

SELECT 
          m.member_id,
          firstname,
          lastname,
          street,
          city,
          state,
          zip 
FROM 
    member m 
    LEFT JOIN member_address ma on m.member_id = ma.member_id;

-- Run a join between the member, member_address, and phone tables

SELECT 
          m.member_id,
          firstname,
          lastname,
          street,
          city,
          state,
          zip, 
          phone
FROM 
    member m 
    LEFT JOIN member_address ma on m.member_id = ma.member_id
    LEFT JOIN member_phone mp on m.member_id = mp.member_id;


-- 8.2.6   Add another row to the MEMBER table.
--         Since the MEMBER table uses the sequence as the default, we can
--         insert another row, which will fetch the next unique value.

INSERT 
    INTO member(points_balance,
            started_date,
            registered_date,
            firstname,
            lastname,
            gender,
            age,
            email)
    VALUES (102000,
            '2014-9-12',
            '2014-8-1',
            'Fred',
            'Wiffle',
            'M',
            '34',
            'Fwiffle@AOL.com');


-- 8.2.7   Check the sequence number of the new row.
--         Notice the value might not be what you would expect. In other words,
--         it may be unique, but it may not be the next value in the sequence,
--         which would be 1001. This is because sequence values are generally
--         contiguous, but sometimes, there can be a gap, related to how
--         Snowflake caches sequence values for better performance.

SELECT * FROM member WHERE member_id > 1000;


-- 8.3.0   Work with Conditional Multi-Table Inserts
--         In this section, we’re going to expand on our earlier work.
--         Specifically, we will use a conditional multi-table insert to break
--         the member table into a gold_member and a club_member table. Gold
--         members have greater than or equal to 5,000,000 points in their
--         balance, and club members have less than 5,000,000. We will use the
--         points_balance column to determine who is a gold member.

-- 8.3.1   Create the tables.

-- The first table will be the gold_member table 

CREATE OR REPLACE TABLE gold_member(
    member_id INTEGER DEFAULT member_seq.nextval,
    points_balance NUMBER,
    started_date DATE,
    ended_date DATE,
    registered_date DATE,
    firstname VARCHAR,
    lastname VARCHAR,
    gender VARCHAR,
    age NUMBER,
    email VARCHAR
);

-- The second table will be the club_member table

CREATE OR REPLACE TABLE club_member (
    member_id INTEGER DEFAULT member_seq.nextval,
    points_balance NUMBER,
    started_date DATE,
    ended_date DATE,
    registered_date DATE,
    firstname VARCHAR,
    lastname VARCHAR,
    gender VARCHAR,
    age NUMBER,
    email VARCHAR
);


-- 8.3.2   Execute the inserts.

INSERT ALL
    WHEN points_balance >= 5000000 THEN    
        INTO gold_member(member_id,
            points_balance,
            started_date,
            ended_date,
            registered_date,
            firstname,
            lastname,
            gender,
            age,
            email)
    VALUES (member_id,
            points_balance,
            started_date,
            ended_date,
            registered_date,
            firstname,
            lastname,
            gender,
            age,
            email)
    ELSE        -- Points_balance is less than 5,000,000, so this member is a club member
            INTO club_member (member_id,
            points_balance,
            started_date,
            ended_date,
            registered_date,
            firstname,
            lastname,
            gender,
            age,
            email)
    VALUES (member_id,
            points_balance,
            started_date,
            ended_date,
            registered_date,
            firstname,
            lastname,
            gender,
            age,
            email)
    SELECT member_id,
            points_balance,
            started_date,
            ended_date,
            registered_date,
            firstname,
            lastname,
            gender,
            age,
            email
 from member;


-- 8.3.3   Check that the inserts are correct.
--         Run the statements below and check that the POINTS_BALANCE field in
--         gold_member is greater than or equal to 5,000,000 and less than
--         5,000,000 for club_member.

  SELECT * FROM gold_member
    LIMIT 10;

SELECT * FROM club_member 
    LIMIT 10;


-- 8.4.0   Use ALTER TABLE table_name SWAP WITH to Swap Table Content and
--         Metadata
--         ALTER TABLE  SWAP WITH swaps all content and metadata between two
--         specified tables, including any integrity constraints defined for the
--         tables. The two tables are essentially renamed in a single
--         transaction.
--         You’ll practice using SWAP WITH in this activity. You will truncate
--         the gold_member and club_member tables from the previous activity,
--         insert the data for the gold_member table into the club_member table,
--         and vice versa; then you’ll swap the tables to correct the problem.

-- 8.4.1   Truncate the tables and replace the data.

TRUNCATE TABLE gold_member;
TRUNCATE TABLE club_member;

INSERT ALL
    WHEN points_balance < 5000000 THEN  --inserts the club_member data into the gold_member table  
        INTO gold_member(member_id,
            points_balance,
            started_date,
            ended_date,
            registered_date,
            firstname,
            lastname,
            gender,
            age,
            email)
    VALUES (member_id,
            points_balance,
            started_date,
            ended_date,
            registered_date,
            firstname,
            lastname,
            gender,
            age,
            email)
    ELSE        -- inserts the gold_member data into the club_member table
            INTO club_member (member_id,
            points_balance,
            started_date,
            ended_date,
            registered_date,
            firstname,
            lastname,
            gender,
            age,
            email)
    VALUES (member_id,
            points_balance,
            started_date,
            ended_date,
            registered_date,
            firstname,
            lastname,
            gender,
            age,
            email)
    SELECT member_id,
            points_balance,
            started_date,
            ended_date,
            registered_date,
            firstname,
            lastname,
            gender,
            age,
            email
 FROM member;


-- 8.4.2   Verify the data.
--         Execute the statements below to verify the values in the
--         points_balance column.

 SELECT * FROM gold_member
    LIMIT 10;

SELECT * FROM club_member 
    LIMIT 10;

--         Notice that the two tables have the wrong values for points_balance.
--         The gold_member table should show values equal to or greater than
--         5,000,000, and the club_member table should show values less than
--         5,000,000. Run a check to see how many rows are correct in each
--         table. Since the multi-table insert was incorrect, these two queries
--         shouldn’t return any rows.

SELECT * FROM gold_member WHERE points_balance >= 5000000;

SELECT * FROM club_member WHERE points_balance < 5000000;

--         It is clear that the two tables are reversed: members with more than
--         5,000,000 points are in the club_member table, and members with fewer
--         points are in the gold_member table. One solution would be to drop
--         both tables and re-run the multi-table insert. The more
--         straightforward solution is to use the ALTER TABLE <table_name> SWAP
--         WITH, which swaps the names and all metadata information on the two
--         tables. In the next couple of steps, you will see the ALTER TABLE
--         <table_name> SWAP WITH command in action.

-- 8.4.3   Suspend your virtual warehouse.
--         Before we execute our ALTER TABLE <table_name> SWAP WITH statement,
--         we’ll suspend our virtual warehouse and check the status. This will
--         demonstrate that the action of swapping is serverless.
--         Run both statements below and confirm that your virtual warehouse is
--         indeed suspended.

ALTER WAREHOUSE LEARNER_WH SUSPEND;

SHOW WAREHOUSES LIKE '%LEARNER_WH%';


-- 8.4.4   Execute the table swap below:

ALTER TABLE gold_member SWAP WITH club_member;


-- 8.4.5   Confirm the virtual warehouse is still suspended.

SHOW WAREHOUSES LIKE '%LEARNER_WH%';

--         As you can see, your virtual warehouse is still suspended. No virtual
--         warehouse was required to swap the names and metadata for the two
--         tables.

-- 8.4.6   Execute the statements below to see if the swap operation fixed the
--         issue.

SELECT * FROM gold_member WHERE points_balance >= 5000000;

SELECT * FROM club_member WHERE points_balance <= 5000000;

--         As you can see, the problem we identified is now fixed.

-- 8.5.0   Use MERGE to Update Rows in a Table
--         SnowBear Air has received two files from their web team containing
--         several individual updates made by various members. The first has
--         changes for the club_member table, and the second for the gold_member
--         table.
--         In this section, you will use MERGE to update data in the two tables.
--         We’ll use an INSERT statement hardcoded with the updated data to
--         simulate the data in the files.
--         MERGE
--         MERGE can insert, update, or delete a table based on values in a
--         second table or a subquery. This can be useful if the second table is
--         a change log that contains new rows (to be inserted), modified rows
--         (to be updated), and marked rows (to be deleted) in the target table.
--         The command supports semantics for handling the following cases:
--         Values that match (for updates and deletes).
--         Values that do not match (for inserts).
--         MERGE SYNTAX
--         MERGE INTO <target_table> USING <source> ON <join_expr>;
--         Example:
--         Note that the WHEN MATCHED THEN clause triggers the updating of one
--         field with another. This allows updates to be merged into existing
--         data.

-- 8.5.1   Create temporary tables for the new data.
--         In this step, you’ll create the tmp_gold_member_change and
--         tmp_club_member_change tables to hold the changes for both member
--         tables.

CREATE or REPLACE TEMP TABLE tmp_gold_member_change (
    member_id INTEGER,
    points_balance NUMBER,
    started_date DATE,
    ended_date DATE,
    registered_date DATE,
    firstname VARCHAR,
    lastname VARCHAR,
    gender VARCHAR,
    age NUMBER,
    email VARCHAR
);

CREATE or REPLACE TEMP TABLE tmp_club_member_change (
    member_id INTEGER,
    points_balance NUMBER,
    started_date DATE,
    ended_date DATE,
    registered_date DATE,
    firstname VARCHAR,
    lastname VARCHAR,
    gender VARCHAR,
    age NUMBER,
    email VARCHAR
);

INSERT INTO tmp_gold_member_change (member_id, points_balance, started_date, ended_date, registered_date, firstname, lastname, gender, age, email)
    values
        (NULL,5000000,current_date(),NULL,current_date(),'Jessie','James',
                'M',64,'jjames@outlaw.com'),
        (NULL,5000000,current_date(),NULL,current_date(),'Kyle','Benton',
                'M',39,'kbenton@companyx.com'),
        (NULL,5000000,current_date(),NULL,current_date(),'Charles','Xavier',
                'M',76,'ProfessorX@Xmen.com'),
        (6,7630775,'2012-02-28','2014-04-14','2015-12-28','Anna-diana','Gookey',
                'F',29,'agookey5@hhs.gov'),
        (7,5128459,'2017-02-01',NULL,'2019-07-08','Damara','Kilfeder',
                'F',85,'dkilfeder6@scribd.com'),
        (34,9287918,'2018-12-13',NULL,'2018-03-24','Igor','Danell',
                'M',64,'idanellx@facebook.com'),
        (67,7684309,'2014-05-24',NULL,'2018-06-25','Ky','Bree',
                'M',39,'kbree1u@wikia.com'),
        (107,5221084,'2018-05-22',current_date(),'2016-03-07','Persis','Keri',
                'F',76,'pkeri2y@soundcloud.com'),
        (172,6720892,'2020-03-28',NULL,'2014-03-05','Jessalyn','Smith',
                'F',27,'jgilberthorpe4r@bbc.co.uk'),
        (177,9175745,'2012-12-22',NULL,'2012-08-02','Giacomo','Careswell',
                'M',63,'gcareswell4w@comsenz.com'),
        (236,8372164,'2016-12-22',current_date(),'2017-05-02','Guendolen',
                'Girdlestone','F',38,'ggirdlestone6j@nationalgeographic.com'),
        (426,6051750,'2018-05-06',NULL,'2020-06-28','Marietta','Busfield',
                'M',71,'mbusfieldbt@wordview.com'),
        (431,9323224,'2013-01-08',NULL,'2015-05-19','Malcolm','Eastes',
                'M',39,'meastesby@lulu.com'),
        (437,6917699,'2015-01-02',NULL,'2012-09-18','Fremont','Rizzardo',
                'M',64,'frizzardoc4@biglobe.ne.jp'),
        (453,6547799,'2012-08-27',NULL,'2011-01-01','Roselia','McMillen',
                'F',51,'rtaptonck@cdc.gov'),
        (531,6361513,'2010-11-16',NULL,'2019-03-26','Sally','O Duilleain',
                'F',76,'hoduilleaineq@printfriendly.com');

INSERT INTO tmp_club_member_change (member_id, points_balance, started_date, ended_date, registered_date, firstname, lastname, gender, age, email)
    values
      (NULL,0,current_date(),NULL,'2014-06-02','Al','Bundy',
                'M',45,'abundy@meetup.com'),      
      (NULL,0,current_date(),NULL,'2015-04-15','Jimmy','James',
                'M',55,'jjames@narod.ru'),
      (NULL,0,current_date(),NULL,'2013-01-15','Mary', 'Manners',
                'F',37,'mmanners@ibm.com'),
      (NULL,0,current_date(),NULL,'2017-05-25','Nancy', 'Dew',
                'F',39,'NDew3@wsj.com'),
      (5,806553,'2017-12-15',NULL,'2016-06-16','Jessey','Cotherill',
                'M',37,'jcotherill4@indiegogo.com'),
      (8,1914198,'2012-10-08','2020-08-12','2013-11-14','Robinetta','Slayford',
                'F',33,'rslayford7@prnewswire.com'),
      (9,3527720,'2019-05-30','2020-09-22','2015-01-07','Leonidas','Weatherby',
                'M',35,'lweatherby8@gnu.org'),
      (10,678532,'2016-07-13','2020-12-1','2013-10-28','Wald','Simmank',
                'M',28,'wsimmank9@youku.com'),
      (49,4182743,'2019-07-21',NULL,'2017-09-23','Tomi','Mayweather',
                'F',71,'tgloster1c@nymag.com'),
      (51,2164969,'2012-07-29',NULL,'2011-11-11','Haleigh','Blackway',
                'M',42,'hblackway1e@hilton.com'),
      (86,63441,'2012-06-21',NULL,'2018-03-05','Dniren','West',
                'F',67,'dnorth2d@dyndns.org'),
      (102,1273020,'2019-07-03',NULL,'2016-04-30','Diandra','Peacham',
                'F',54,'dpeacham2t@.com'),
      (143,198814,'2020-01-02',NULL,'2016-09-28','Alayne','Jevons',
                'F',49,'ajevons3y@nytimes.edu'),
      (214,3713155,'2020-06-24',current_date(),'2011-10-21','Licha','MacCurlye',
                'F',62,'lmaccurlye5x@microsoft.it'),
      (221,3642431,'2020-08-21',NULL,'2015-05-19','Codi','Battram',
                'M',32,'cbattram@ft.com');            


-- 8.5.2   Apply the MERGE statement.
--         Now, you’ll use a MERGE statement to apply the updates to the
--         gold_member table. After the MERGE statement runs, you will run some
--         queries to verify the changes.

MERGE INTO gold_member gm USING tmp_gold_member_change gc ON gm.member_id= gc.member_id
    WHEN matched
        THEN UPDATE SET points_balance = gc.points_balance,
                        started_date = gc.started_date,
                        ended_date = gc.ended_date,
                        registered_date = gc.registered_date,
                        firstname = gc.firstname,
                        lastname = gc.lastname,
                        gender = gc.gender,
                        age = gc.age
     WHEN NOT MATCHED THEN INSERT ( points_balance, started_date, ended_date, registered_date, firstname, lastname, gender, age, email)
                VALUES (gc.points_balance,
                        gc.started_date,
                        gc.ended_date,
                        gc.registered_date,
                        gc.firstname,
                        gc.lastname,
                        gc.gender,
                        gc.age,
                        gc.email);


-- 8.5.3   Save the query_id from the merge statement.
--         This will be used to show what you changed in the gold_members table
--         with the merge statement.

SET merge_query_id = last_query_id();
SHOW VARIABLES;


-- 8.5.4   Verify the effect of the MERGE statement.
--         The following queries use Time Travel to view the state of the tables
--         before and after the MERGE statement.

-- Use Time Travel to show the rows that have been inserted and updated. 

-- First, show the 13 items updated in the gold_member table.

SELECT  m.member_id,  
        m.points_balance, mc.points_balance,
        m.started_date, mc.started_date,
        m.ended_date, mc.ended_date,
        m.registered_date, mc.registered_date,
        m.firstname, mc.firstname,
        m.lastname, mc.lastname,
        m.gender, mc.gender,
        m.age, mc.age,
        m.email, mc.email 
    FROM gold_member m INNER JOIN gold_member BEFORE (STATEMENT => $merge_query_id) mc on m.member_id = mc.member_id
    WHERE mc.member_id IN (SELECT member_id FROM tmp_gold_member_change);


-- 8.5.5   Run the statement below to show the three items inserted into the
--         gold_member table.

SELECT  m.member_id,  
        m.points_balance,
        m.started_date,
        m.ended_date,
        m.registered_date,
        m.firstname,
        m.lastname,
        m.gender,
        m.age,
        m.email
    FROM gold_member m 
    WHERE m.member_id NOT IN (SELECT member_id FROM gold_member BEFORE (STATEMENT => $merge_query_id));


-- 8.5.6   Now execute the same process with the club_member table.

-- Execute the merge statement for the club_member table

MERGE INTO club_member cm USING tmp_club_member_change cc ON cm.member_id= cc.member_id
    WHEN matched
        THEN UPDATE SET points_balance = cc.points_balance,
                        started_date = cc.started_date,
                        ended_date = cc.ended_date,
                        registered_date = cc.registered_date,
                        firstname = cc.firstname,
                        lastname = cc.lastname,
                        gender = cc.gender,
                        age = cc.age
     WHEN NOT MATCHED THEN INSERT ( points_balance, started_date, ended_date, registered_date, firstname, lastname, gender, age, email)
                VALUES (cc.points_balance,
                        cc.started_date,
                        cc.ended_date,
                        cc.registered_date,
                        cc.firstname,
                        cc.lastname,
                        cc.gender,
                        cc.age,
                        cc.email);
                     
-- Save the query_id from the merge statement. This will be used to show what has changed in the club_member table based on the merge statement.

SET merge_query_id = last_query_id();
SHOW VARIABLES;

-- Show the items that were updated

SELECT  m.member_id,  
        m.points_balance, mc.points_balance,
        m.started_date, mc.started_date,
        m.ended_date, mc.ended_date,
        m.registered_date, mc.registered_date,
        m.firstname, mc.firstname,
        m.lastname, mc.lastname,
        m.gender, mc.gender,
        m.age, mc.age,
        m.email, mc.email 
    FROM club_member m INNER JOIN club_member BEFORE (STATEMENT => $merge_query_id) mc ON m.member_id = mc.member_id
    WHERE mc.member_id IN (SELECT member_id FROM tmp_club_member_change);

-- Show the items that were inserted into the member table

SELECT  m.member_id,  
        m.points_balance,
        m.started_date,
        m.ended_date,
        m.registered_date,
        m.firstname,
        m.lastname,
        m.gender,
        m.age,
        m.email
    FROM club_member m 
    WHERE m.member_id NOT IN (SELECT member_id FROM club_member BEFORE (STATEMENT => $merge_query_id));   

--         As you can see, the update was successful.

-- 8.5.7   Suspend your virtual warehouse.

ALTER WAREHOUSE LEARNER_wh SUSPEND;


-- 8.6.0   Key Takeaways
--         - A single multi-insert statement can be used to insert data from one
--         table into multiple tables.
--         - You can use ALTER TABLE SWAP WITH to swap content and metadata
--         between two tables easily.
--         - You can use the MERGE statement to add, update, or delete data in a
--         table.
--         - You can use the query ID of a SQL statement and Time Travel to
--         compare what data looked like before and after an update.

-- 8.7.0   Return to the Lab Exercise Page in the Course and Click the Mark as
--         complete Button
