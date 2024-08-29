
-- 19.0.0  Access Control and User Management
--         There are two parts to this lab.
--         In Part I, you’ll learn about role-based access control (RBAC) in
--         Snowflake. Specifically, you’ll become familiar with the Snowflake
--         security model and learn how to create roles, grant privileges, and
--         build and implement basic security models.
--         In Part II, you’ll learn about secondary roles and how you can use
--         them to access both primary and secondary roles already granted to
--         the user within a single session.
--         - Show grants to users and roles.
--         - Grant usage on objects to roles.
--         - Use Secondary Roles to aggregate permissions from more than one
--         role.
--         This lab should take you approximately 20 minutes to complete.
--         The purpose of this exercise is to give you a chance to see how you
--         can manage access to data in Snowflake by granting privileges to some
--         roles and not to others.
--         In this lab, TRAINING_ROLE will represent the privileges of a user
--         who should have access to a specific table in a particular database.
--         In contrast, role PUBLIC will represent the privileges of a user who
--         shouldn’t.
--         This lab will walk you through the process of setting all this up so
--         you can test the roles and observe the results.
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

-- 19.1.0  Part I - Determine Privileges (GRANTs)
--         In this section of the lab, you’ll use SHOW GRANTS to determine what
--         roles a USER has and what privileges a role has received. This is an
--         important step in determining what a USER is or isn’t allowed to do.

-- 19.1.1  Set your context and make sure you have the standard lab objects.

USE ROLE TRAINING_ROLE;

CREATE WAREHOUSE IF NOT EXISTS LEARNER_WH INITIALLY_SUSPENDED=TRUE;
USE WAREHOUSE LEARNER_WH;

CREATE DATABASE IF NOT EXISTS LEARNER_DB;
USE DATABASE LEARNER_DB;

CREATE SCHEMA IF NOT EXISTS LEARNER_DB.LEARNER_SCHEMA;
USE LEARNER_DB.LEARNER_SCHEMA;


-- 19.1.2  Run these commands one at a time to see what roles have been granted
--         to you as a user and what privileges have been granted to specified
--         roles.

SHOW GRANTS TO USER LEARNER;
SHOW GRANTS TO ROLE PUBLIC;
SHOW GRANTS TO ROLE TRAINING_ROLE;

--         You should see that TRAINING_ROLE has some specific privileges
--         granted and is quite powerful. This has been done intentionally so
--         you can do the labs more easily. In a production environment, it is
--         unlikely that you would ever see a role like this.
--         Next, you’ll use GRANT ROLE to give additional privileges to a ROLE
--         and use GRANT USAGE to permit a user to perform actions on or with a
--         database object.

-- 19.1.3  Create a database called LEARNER_CLASSIFIED_DB.

CREATE DATABASE LEARNER_CLASSIFIED_DB;


-- 19.1.4  Create a table.
--         Using the role TRAINING_ROLE, create a table named SUPER_SECRET_TBL
--         inside the LEARNER_CLASSIFIED_DB.PUBLIC schema.

USE SCHEMA LEARNER_CLASSIFIED_DB.PUBLIC;
CREATE TABLE SUPER_SECRET_TBL (id INT);


-- 19.1.5  Insert some data into the table.

INSERT INTO SUPER_SECRET_TBL VALUES (1), (10), (30);


-- 19.1.6  GRANT SELECT privileges on SUPER_SECRET_TBL to the role PUBLIC.
--         Here, we’re going to GRANT SELECT to PUBLIC, but we’re NOT going to
--         GRANT USAGE on the database. We are going to grant usage on a virtual
--         warehouse as PUBLIC doesn’t have permission to use any virtual
--         warehouses at the moment.
--         If we DON’T grant usage on the database AND its schemas to a role,
--         that role won’t be able to do things like create tables or select
--         from tables even IF that role has create or select privileges. In
--         other words, you must have the appropriate permissions on all objects
--         in the hierarchy from top to bottom in order to work at the lowest
--         level of the hierarchy.

GRANT USAGE ON WAREHOUSE LEARNER_WH TO ROLE PUBLIC;
GRANT SELECT ON TABLE SUPER_SECRET_TBL TO ROLE PUBLIC;


-- 19.1.7  Use the role PUBLIC to SELECT * from the table SUPER_SECRET_TBL.
--         Now let’s try to select some data using PUBLIC. What do you think is
--         going to happen?

USE ROLE PUBLIC;
SELECT * FROM LEARNER_CLASSIFIED_DB.PUBLIC.SUPER_SECRET_TBL;

--         We’re not able to select any data. That’s because the role we’re
--         using has not been granted USAGE on the database or the schema
--         PUBLIC. Let’s GRANT USAGE on both of those objects to PUBLIC and see
--         what happens.

-- 19.1.8  Grant role PUBLIC usage on all schemas in LEARNER_CLASSIFIED_DB.

USE ROLE TRAINING_ROLE;

GRANT USAGE ON DATABASE LEARNER_CLASSIFIED_DB TO ROLE PUBLIC;
GRANT USAGE ON SCHEMA LEARNER_CLASSIFIED_DB.PUBLIC TO ROLE PUBLIC;

USE ROLE PUBLIC;
SELECT * FROM LEARNER_CLASSIFIED_DB.PUBLIC.SUPER_SECRET_TBL;

--         This time, it worked! This is because your role has the appropriate
--         permissions at all levels of the hierarchy.

-- 19.1.9  Drop the database LEARNER_CLASSIFIED_DB.

USE ROLE TRAINING_ROLE;
DROP DATABASE LEARNER_CLASSIFIED_DB;


-- 19.2.0  Part II - Use Secondary Roles
--         In this section, you’ll learn how to use GRANT ROLE to give
--         additional privileges to other roles and see how to use GRANT USAGE
--         to permit a role to perform actions on or with a database object.
--         You will use USE SECONDARY ROLES to aggregate permissions from two
--         different roles, TRAINING_ROLE and PUBLIC.
--         First, you will use TRAINING_ROLE to create a database and table and
--         to insert a row into the table. You will then switch to PUBLIC and
--         try to access the table.
--         Next, you will enable secondary roles and try accessing the table
--         again with PUBLIC.
--         You will then disable secondary roles and switch back to
--         TRAINING_ROLE in order to grant PUBLIC access to the database,
--         schema, and table. You will then switch back to PUBLIC and try the
--         access again.

-- 19.2.1  Change to the role TRAINING_ROLE to create the new database and
--         table.

USE ROLE TRAINING_ROLE;


-- 19.2.2  If you haven’t created the virtual warehouse, do it now.

CREATE WAREHOUSE IF NOT EXISTS LEARNER_WH;


-- 19.2.3  Create a database called LEARNER_ROLETEST_DB.

CREATE DATABASE LEARNER_ROLETEST_DB;
USE LEARNER_ROLETEST_DB.PUBLIC;

CREATE TABLE ROLE_TBL (id INT);

-- Insert a row of data into the table

INSERT INTO ROLE_TBL VALUES (1), (10), (30);

-- Check the table to make sure the data was loaded

SELECT * FROM ROLE_TBL;


-- 19.2.4  Switch to the role PUBLIC and try to access the database, schema, and
--         table created above.

USE ROLE PUBLIC;
SELECT * FROM LEARNER_ROLETEST_DB.PUBLIC.ROLE_TBL;

--         We cannot select any data because PUBLIC has not been granted access
--         to select from the table ROLE_TBL.

-- 19.2.5  Enable SECONDARY ROLES ALL and try again.

USE SECONDARY ROLES ALL;
SELECT * FROM LEARNER_ROLETEST_DB.PUBLIC.ROLE_TBL;

--         With SECONDARY ROLES ALL set, the current user can use any permission
--         from any role the user has been granted except CREATE.

-- 19.2.6  Alter the table while SECONDARY ROLES ALL is set.

ALTER TABLE LEARNER_ROLETEST_DB.PUBLIC.ROLE_TBL ADD COLUMN name STRING(20);
SELECT * FROM LEARNER_ROLETEST_DB.PUBLIC.ROLE_TBL;

--         This should work since the roles granted to your user include
--         TRAINING_ROLE, the owner of the table.

-- 19.2.7  Try creating a new table in the LEARNER_ROLETEST_DB.

CREATE TABLE LEARNER_ROLETEST_DB.PUBLIC.NOROLE_TBL (name STRING(20));

--         You cannot create a table because the current role PUBLIC does not
--         have CREATE TABLE privileges on the database. As mentioned before,
--         USE SECONDARY ROLES does not include CREATE privileges given to other
--         roles.

-- 19.2.8  Disable secondary roles.

USE SECONDARY ROLES NONE;


-- 19.2.9  Switch back to the TRAINING_ROLE role and give PUBLIC permission to
--         select from the table.
--         Here. we’re going to GRANT SELECT to the ROLETEST_TBL, but we’re NOT
--         going to GRANT USAGE on the database or on its schemas.

USE ROLE TRAINING_ROLE;
GRANT SELECT ON LEARNER_ROLETEST_DB.PUBLIC.ROLE_TBL TO ROLE PUBLIC;


-- 19.2.10 Select some data using PUBLIC.

USE ROLE PUBLIC;
SELECT * FROM LEARNER_ROLETEST_DB.PUBLIC.ROLE_TBL;

--         We’re not able to select any data. That’s because the role we’re
--         using does not have USAGE on the database or the schema PUBLIC. Let’s
--         GRANT USAGE on both of those objects and see what happens.

-- 19.2.11 Grant role PUBLIC usage on all schemas in LEARNER_ROLETEST_DB.

USE ROLE TRAINING_ROLE;
GRANT USAGE ON DATABASE LEARNER_ROLETEST_DB TO ROLE PUBLIC;
GRANT USAGE ON SCHEMA LEARNER_ROLETEST_DB.PUBLIC TO ROLE PUBLIC;


-- 19.2.12 Now try again.

USE ROLE PUBLIC;
SELECT * FROM LEARNER_ROLETEST_DB.PUBLIC.ROLE_TBL;

--         This time, it worked! This is because PUBLIC has all the needed
--         permissions, without having to resort to any secondary roles.

-- 19.2.13 Suspend your virtual warehouse and drop the database
--         LEARNER_ROLETEST_DB.

USE ROLE TRAINING_ROLE;

ALTER WAREHOUSE LEARNER_WH SUSPEND;

USE LEARNER_DB.LEARNER_SCHEMA;

DROP DATABASE LEARNER_ROLETEST_DB;


-- 19.3.0  Key Takeaways
--         - Usage is granted to roles, which in turn are granted to users.
--         - Usage must be granted on all levels in a hierarchy (database and
--         schema) in order for a role to have the ability to select from a
--         table.
--         - Secondary roles can be used to aggregate permissions in a single
--         session.
--         - When using secondary roles, you can only create objects if the
--         primary role has permissions to do that.

-- 19.4.0  Return to the Lab Exercise Page in the Course and Click the Mark as
--         complete Button
