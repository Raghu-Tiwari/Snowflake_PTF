
-- 5.0.0   Working with Transactions
--         This lab will explore Data Manipulation Language (DML) and various
--         commands for transaction controls. Pay close attention to the
--         separate worksheets and how they process data. Review the list of
--         items we will be covering and what the learning objectives are.
--         By the end of this lab, you should be able to:
--         - Summarize the transaction model and concurrency control.
--         - Explore autocommit default values.
--         - Change session values for the autocommit parameter.
--         - Explore multi-statement transactions.
--         - Monitor the SHOW LOCKS and LOCK_TIMEOUT parameters for concurrency
--         control.
--         - Use SYSTEM$ABORT_TRANSACTION to release locks and terminate
--         transactions.
--         This lab should take you approximately 20 minutes to complete.
--         HOW TO COMPLETE THIS LAB
--         As the workbook PDF may have useful diagrams, we recommend that you
--         read the instructions from the workbook PDF. In order to execute the
--         code presented in each step, use the SQL code file that was provided
--         for this lab.
--         In this lab, you will create two (2) worksheets (SHEET-A and SHEET-B)
--         from the single SQL file we’ve provided for this lab. The
--         instructions below walk you through how to create the worksheets so
--         they have different session numbers. This is necessary in order to
--         emulate two different transaction scopes working in a concurrent
--         environment.
--         Loading SHEET-A
--         In the instructions below, you are making two separate worksheets.
--         There is only one SQL file for this lab!
--         Read the instructions below thoroughly before creating your
--         worksheets.
--         In the left navigation bar select Projects, then select Worksheets.
--         Click the ellipsis (…) in the upper-right corner, then select Create
--         Worksheet from SQL File from the drop-down menu.
--         Navigate to the SQL file for this lab and load it.
--         After the file has loaded, click the ellipsis to the right of the
--         worksheet name and select Rename from the drop-down menu.
--         Rename the worksheet to SHEET-A.
--         Creating SHEET-B
--         Click the Snowflake logo in the upper left corner to return to the
--         Worksheets page.
--         Click the ellipsis (…) in the upper-right corner, then select Create
--         Worksheet from SQL File from the drop-down menu.
--         Navigate to the SQL file for this lab and load it.
--         After the file has loaded, click the ellipsis to the right of the
--         worksheet name and select Rename from the drop-down menu.
--         Rename the worksheet to SHEET-B.
--         Confirm you have two worksheet tabs, one named SHEET-A and the other
--         named SHEET-B.
--         In this exercise you will be asked to switch between SHEET-A and
--         SHEET-B numerous times to run commands. Note the code line number
--         when you change worksheets to help orientate yourself after each
--         switch.
--         Let’s get started!

-- 5.1.0   Transaction Model and Concurrency Control
--         In the two worksheets you just created, there will be statements
--         labeled SHEET-A or SHEET-B. At this point, you will start with
--         SHEET-A and only execute statements enclosed by the SHEET-A comments.
--         See the example immediately below.
--         Example:

-- SHEET-A --


-- 5.2.0   Explore the Autocommit Default Value
--         Autocommit determines whether a DML statement, when executed without
--         an active transaction, is automatically committed after the statement
--         successfully completes. The default value is TRUE. With AUTOCOMMIT
--         set to TRUE, you won’t be able to rollback any transactions because
--         they were automatically committed. Let’s observe this in action.

-- 5.2.1   Set the context for SHEET-A.

-- SHEET-A --
USE ROLE TRAINING_ROLE;

CREATE DATABASE IF NOT EXISTS LEARNER_DB;

USE SCHEMA LEARNER_DB.PUBLIC;

CREATE WAREHOUSE IF NOT EXISTS LEARNER_WH;
USE WAREHOUSE LEARNER_WH;
-- SHEET-A --


-- 5.2.2   Create a table and insert some records.

-- SHEET-A --
CREATE OR REPLACE TABLE t1 (
  c1    BIGINT,
  c2    STRING
);

INSERT INTO t1 (c1, c2)
    VALUES(1,'ONE'), (2, 'TWO'), (3,'THREE');
-- SHEET-A --


-- 5.2.3   Show the session is set to AUTOCOMMIT by default.

-- SHEET-A --
SHOW PARAMETERS LIKE 'AUTOCOMMIT' IN SESSION;
-- SHEET-A --


-- 5.2.4   Run the query and confirm the data is available.

-- SHEET-A --
SELECT * FROM t1;
-- SHEET-A --


-- 5.2.5   Rollback the above INSERT statement.

-- SHEET-A --
ROLLBACK;
-- SHEET-A --


-- 5.2.6   Re-run query to query from the table.

-- SHEET-A --
SELECT * FROM t1;
-- SHEET-A --

--         You should see all three records. Since AUTOCOMMIT is true, the three
--         records that were inserted are already committed and there was
--         nothing to roll back.

-- 5.3.0   Change the Session Value for the Autocommit Parameter
--         Now, we’re going to set AUTOCOMMIT to FALSE and observe what happens
--         when we attempt to insert records into a table.

-- 5.3.1   Set the AUTOCOMMIT parameter to FALSE.

-- SHEET-A --
ALTER SESSION SET AUTOCOMMIT = FALSE;
-- SHEET-A --


-- 5.3.2   Confirm that AUTOCOMMIT is set to FALSE.

-- SHEET-A --
SHOW PARAMETERS LIKE 'AUTOCOMMIT' IN SESSION;
-- SHEET-A --


-- 5.3.3   Insert some new records.

-- SHEET-A --
INSERT INTO T1 (C1, C2)
    VALUES(4,'FOUR'), (5, 'FIVE');
-- SHEET-A --


-- 5.3.4   Run a query to check for the new records.
--         The two new records are uncommitted data but are visible to the
--         current transaction.

-- SHEET-A --
SELECT * FROM t1;
-- SHEET-A --

--         You should see five (5) rows. Confirm this is the case.

-- 5.3.5   SWITCH TO OTHER WORKSHEET WINDOW ——> SHEET-B
--         In the earlier part of the exercise, you only executed statements in
--         SHEET-A that were labeled SHEET-A. Now, you will execute statements
--         in SHEET-B that are enclosed by SHEET-B comments. From now on, the
--         instructions will tell you when to alternate between SHEET-B and
--         SHEET-A, so make sure you read them carefully.

-- 5.3.6   Set your context.

-- SHEET-B --
USE ROLE TRAINING_ROLE;

USE SCHEMA LEARNER_DB.PUBLIC;

USE WAREHOUSE LEARNER_WH;
-- SHEET-B --


-- 5.3.7   Run the following query in Worksheet SHEET-B.
--         This query will demonstrate that SHEET-B cannot see uncommitted data
--         produced in SHEET-A.

-- SHEET-B --
-- With READ COMMITTED isolation support for table, a statement sees
-- only data that was committed before the statement began.
SELECT * FROM T1;
-- SHEET-B --

--         You should see only three rows since the transaction for SHEET-A’s
--         insert (of two rows) is still not yet complete. Thus, those two rows
--         are not visible to any new transactions in SHEET-B.

-- 5.3.8   SWITCH BACK TO OTHER WORKSHEET WINDOW ——> SHEET-A
--         Now, you’re going to roll back the uncommitted insert, then re-insert
--         and commit the transaction.

-- 5.3.9   Rollback the INSERT statement in the transaction originated in Lab
--         SHEET-A.

-- SHEET-A --
ROLLBACK;
-- SHEET-A --


-- 5.3.10  Run the query to select from the table.
--         You should see only three rows as the two new records have been
--         rolled back successfully:

-- SHEET-A --
SELECT * FROM t1;
-- SHEET-A --


-- 5.3.11  Insert the two rows again in Lab SHEET-A worksheet.

-- SHEET-A --
INSERT INTO T1 (C1, C2)
    VALUES(4,'FOUR'), (5, 'FIVE');
-- SHEET-A --


-- 5.3.12  Execute a COMMIT statement and commit the two extra rows.

-- SHEET-A --
COMMIT;
-- SHEET-A --


-- 5.3.13  Query the table again.

-- SHEET-A --
SELECT * FROM t1;
-- SHEET-A --

--         You should be able to see five rows; the two new records are made
--         permanent to the table after the commit.

-- 5.3.14  SWITCH TO OTHER WORKSHEET WINDOW ——> SHEET-B

-- 5.3.15  Query the table again.

-- SHEET-B --
SELECT * FROM t1;
-- SHEET-B --

--         You should also be able to see five rows; the two new records are
--         made permanent to the table after the commit.

-- 5.3.16  SWITCH BACK TO OTHER WORKSHEET WINDOW ——> SHEET-A

-- 5.4.0   Explore Multi-Statement Transactions
--         Since AUTOCOMMIT is still set to FALSE, any INSERT transactions will
--         need to be explicitly committed. Here, you’ll practice executing
--         several INSERT statements in a single transaction instead of in
--         separate transactions.

-- 5.4.1   Start a new multi-statement transaction in SHEET-A.

-- SHEET-A --
BEGIN TRANSACTION;
-- SHEET-A --


-- 5.4.2   Execute two insert statements in this transaction.

-- SHEET-A --
INSERT INTO t1 (c1, c2)  VALUES(6,'SIX');
INSERT INTO t1 (c1, c2)  VALUES(7,'SEVEN'), (8,'EIGHT');
-- SHEET-A --


-- 5.4.3   End the new multi-statement transaction by running the COMMIT
--         statement.

-- SHEET-A --
COMMIT;
-- SHEET-A --

--         The COMMIT statement ends the multi-statement transaction and commits
--         the two INSERT statements.

-- 5.4.4   Query the table to see the new rows added by the two INSERT
--         statements above.

-- SHEET-A --
SELECT * FROM t1;
-- SHEET-A --

--         You should see eight rows in the result.

-- 5.4.5   Insert a new row to the table.

-- SHEET-A --
INSERT INTO T1 (C1, C2)  VALUES(9,'NINE');
-- SHEET-A --


-- 5.4.6   Execute a ROLLBACK statement.

-- SHEET-A --
ROLLBACK;
-- SHEET-A --

--         This Rollback statement should rollback the INSERT statement, which
--         was started in its own new transaction.

-- 5.4.7   Confirm that AUTOCOMMIT in the current session is still set to FALSE:

-- SHEET-A --
SHOW PARAMETERS LIKE 'AUTOCOMMIT' IN SESSION;
-- SHEET-A --


-- 5.4.8   Query the table.
--         You should see only eight (8) rows because the newly started
--         transaction was rolled back successfully.

-- SHEET-A --
SELECT * FROM t1;
-- SHEET-A --


-- 5.5.0   Monitor Using SHOW LOCKS and LOCK_TIMEOUT Parameters for Concurrency
--         Control
--         Snowflake acquires resource locks while executing DML commands. The
--         locks are released when the transaction is committed or rolled back.
--         In this lab, AUTOCOMMIT has been set to false in Sheet A. Thus, any
--         DML command executed on Sheet A acquires the required resource lock.
--         This is to prevent any other session from making changes to the same
--         resource until the change has been committed or rolled back.
--         Explore the transaction-related parameter, LOCK_TIMEOUT, which
--         controls the number of seconds to wait while trying to lock a
--         resource before timing out and aborting the waiting statement.

-- SHEET-A --
SHOW PARAMETERS LIKE '%lock%';
-- SHEET-A --

--         By default, this parameter is set to 43200 seconds (i.e. 12 hours).

-- 5.5.1   Run a SELECT statement on table t1.

-- SHEET-A --
SELECT * FROM t1;
-- SHEET-A --


-- 5.5.2   Issue the SHOW LOCKS command.
--         This is to show that SELECT does not place any lock on the underlying
--         table.

-- SHEET-A --
SHOW LOCKS;
-- SHEET-A --

--         The SHOW command in this step should return no records, as the query
--         does not place a lock on the underlying table.

-- 5.5.3   Confirm that AUTOCOMMIT in the current session is still set to FALSE.

-- SHEET-A --
SHOW PARAMETERS LIKE 'AUTOCOMMIT' IN SESSION;
-- SHEET-A --


-- 5.5.4   Run UPDATE on table t1.

-- SHEET-A --
UPDATE t1
  SET c2='Second UPDATE'
  WHERE c1=8;
-- SHEET-A --


-- 5.5.5   Check that the record has been updated.

-- SHEET-A --
SELECT c2
FROM t1
WHERE c1 = 8;
-- SHEET-A --


-- 5.5.6   Run the SHOW LOCKS command.
--         This is to confirm that the UPDATE statement has placed a partition
--         lock on the target table t1 within the current transaction, which is
--         still active. Even though only a single row is being updated the
--         partition lock applies to all the partitions in the table.

-- SHEET-A --
SHOW LOCKS;
-- SHEET-A --

--         The current transaction in SHEET-A has a HOLDING status with a lock
--         on the target table, t1.
--         The SHOW command in this step should return one (1) record. See the
--         following example:

-- 5.5.7   Switch to Worksheet SHEET-B

-- 5.5.8   Run the SHOW LOCKS command here, and you should see the same locking
--         output as in the previous step.

-- SHEET-B --
SHOW LOCKS;
-- SHEET-B --


-- 5.5.9   While remaining in SHEET-B, run the following DELETE statement to the
--         same target table t1.
--         Your DELETE statement in SHEET-B will be blocked from completing
--         because of the lock placed on the target table t1 by the UPDATE
--         statement in SHEET-A.

-- SHEET-B --
DELETE FROM t1
WHERE c1=7;
-- SHEET-B --

--         Do not wait for the DELETE statement to complete, proceed to the next
--         step.

-- 5.5.10  SWITCH TO OTHER WORKSHEET WINDOW ——> SHEET-A

-- 5.5.11  Run the SHOW LOCKS command.

-- SHEET-A --
SHOW LOCKS;
-- SHEET-A --

--         The SHOW command in this step should return two records.
--         You should still see your update statement in SHEET-A with a HOLDING
--         status.
--         You should see your blocked (delete) statement from SHEET-B with a
--         WAITING status.

-- 5.5.12  Execute the ROLLBACK statement to end the transaction and release the
--         lock.

-- SHEET-A --
ROLLBACK;
-- SHEET-A --


-- 5.5.13  Run the SHOW LOCKS command to show that the lock is released.

-- SHEET-A --
SHOW LOCKS;
-- SHEET-A --

--         The SHOW command in this step should return no record as the lock has
--         been released with the ROLLBACK statement.

-- 5.5.14  SWITCH TO Worksheet SHEET-B

-- 5.5.15  Check that the DELETE statement is completed now, as shown above,
--         because the lock on the target table t1 has been released by the
--         other transaction.

-- SHEET-B --
SHOW LOCKS;
-- SHEET-B --


-- 5.6.0   Release Locks and Terminate Transactions

-- 5.6.1   Switch to Worksheet SHEET-A.

-- 5.6.2   Execute DELETE statement on table t1.

-- SHEET-A --
DELETE FROM t1
WHERE c1=6;
-- SHEET-A --


-- 5.6.3   Switch to Worksheet SHEET-B

-- 5.6.4   Execute the SHOW LOCKS statement.

-- SHEET-B --
SHOW LOCKS;
-- SHEET-B --

--         The SHOW LOCKS output shows the target table t1 in HOLDING status.

-- 5.6.5   Review the transaction id associated with the DELETE statement.
--         A user can release any of their transaction locks by executing the
--         system function SYSTEM$ABORT_TRANSACTION, passing the transaction ID
--         from the SHOW LOCKS output. Transactions can be aborted only by the
--         user who started the transaction or an account administrator. In
--         Snowflake classes, the TRAINING_ROLE also has this ability.
--         Copy the transaction ID from the SHOW LOCKS statement and place it
--         between the parentheses of the system function below, then run the
--         statement. You can pass the transaction ID to this function with or
--         without enclosing the ID in single quotes.
--         Do not include commas in the transaction_id value. For example,
--         1654029937500 vs. 1,654,029,937,500

-- SHEET-B --
SELECT SYSTEM$ABORT_TRANSACTION(<transaction_id>);
-- SHEET-B --


-- 5.6.6   Suspend your virtual warehouse.

-- SHEET-B --
ALTER WAREHOUSE LEARNER_wh SUSPEND;
-- SHEET-B --

--         The SUSPEND statement will generate an error message if your virtual
--         warehouse is already suspended. You can safely ignore this message.

-- 5.7.0   Key Takeaways
--         - Duplicating a worksheet creates a new session in the duplicate
--         worksheet.
--         - Multiple statements can be executed in a single transaction.
--         - Partition locks in Snowflake are micro-partition-level locks. Even
--         though the locks are internally acquired on each micro-partition, the
--         locks always target all micro-partitions in the table version to be
--         modified, so all partitions are locked while being modified by a DML.
--         - An account administrator can use the system function
--         SYSTEM$ABORT_TRANSACTION to release any lock on any user’s
--         transactions.

-- 5.8.0   Return to the Lab Exercise Page in the Course and Click the Mark as
--         complete Button
