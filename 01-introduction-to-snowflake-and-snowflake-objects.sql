
-- 1.0.0   Introduction to Snowflake and Snowflake Objects
--         The purpose of this lab is to familiarize you with Snowflake’s
--         Snowsight user interface. Specifically, you will learn how to use
--         Snowsight worksheets to create and use Snowflake objects that you
--         will use to run queries in your day-to-day work.
--         - Navigate Snowsight to find the tools you’ll need.
--         - Create and manage folders and worksheets.
--         - Set the context.
--         - Create warehouses, databases, schemas, and tables.
--         - Run a simple query.
--         - Set your user defaults.
--         This lab should take you approximately 40 minutes to complete.
--         You are working for Snowbear Air, which is an airline that flies to
--         fun destinations all over the world. You’ve been asked to create a
--         few Snowflake objects in a development environment to test out your
--         SQL statements. You will need to:
--         - Create a database and a schema
--         - Create a virtual warehouse
--         - Create a table and populate it with data
--         - Run some test queries
--         HOW TO COMPLETE THIS LAB
--         You will need to use the PDF workbook supplied with your course
--         materials. Follow the instructions in the PDF to log in and explore
--         the home page.
--         Since the workbook PDF has useful diagrams and illustrations (not
--         present in the .SQL files), we recommend that you read the
--         instructions from the workbook PDF. In order to execute the code
--         presented in each step, use the SQL code file provided for this lab.
--         For this lab in particular, you MUST use the workbook for the first
--         part, as you will be doing things outside of the Worksheet area (and
--         thus, the SQL file will not be visible).
--         Let’s get started!

-- 1.1.0   Explore the Home Screen.
--         When you first log in, you will be placed into the home screen, which
--         will look similar to the screen below:

-- 1.1.1   Locate the user menu.
--         This is located in the lower left corner. Here, you will find your
--         username and the role that you currently have set. You will learn
--         more about roles later on. Your Snowflake account information is also
--         available from the user menu.

-- 1.1.2   Locate the left navigation bar.
--         This is located along the left side, above the user menu. You can use
--         the navigation bar to move through various areas of the user
--         interface.

-- 1.1.3   Locate the active panel.
--         This is the large area on the right. This will change based on which
--         menu you have activated from the navigation bar.

-- 1.2.0   Set Up Your User Profile

-- 1.2.1   Access the profile.
--         Click the up arrow to the right side of the user menu, then select My
--         Profile.

-- 1.2.2   Enter your name.
--         In the screen that appears, enter your name.
--         Changing your name in the Profile area does not change the username
--         you enter to log into Snowsight. It simply changes your name in the
--         display.

-- 1.2.3   Optionally, upload a profile photo.

-- 1.2.4   Optionally, enter your email address.
--         If you enter an email address, a verification link will be sent to
--         the address you specify.

-- 1.2.5   Set the Default Experience to Snowsight.
--         The default experience is probably already set to Snowsight, but
--         change it if it is not. This determines whether you will be directed
--         to the Classic UI or Snowsight when you log in. In this course, we
--         will be exclusively using Snowsight.
--         The Classic UI is going to be removed at some point in the future.
--         Unless you need to access UI functionality that has not yet been
--         ported to Snowsight, we recommend that you use Snowsight so you are
--         accustomed to it when the Classic UI is no longer available.

-- 1.2.6   Explore multi-factor authentication (MFA).
--         Click the learn more link in the multi-factor authentication section
--         (this will open in a new tab). Scroll down in the documentation to
--         the section on MFA Login Flow and review the process. You can enable
--         multi-factor authentication if you want to.

-- 1.2.7   Save your profile changes.
--         Close the documentation tab, return to the Snowsight tab, and click
--         Save.

-- 1.2.8   Open the documentation from the user menu.
--         Expand the user menu again, and click the Documentation link. This
--         will open the Snowflake documentation in a new browser tab.

-- 1.2.9   Click the Reference link at the top of the page and then click the
--         SQL Command Reference link from the list returned.

-- 1.2.10  Browse the SQL command reference.
--         The SQL Command Reference is a valuable resource. From here, you can
--         view all the SQL commands supported by Snowflake. The All Commands
--         entry provides an alphabetical list where you can find specific
--         commands and click on them to be taken to the documentation page for
--         that command.

-- 1.2.11  Click the Snowflake logo in the upper left corner of the web page to
--         return to the main page.

-- 1.2.12  Search for virtual warehouse in the search bar.
--         Searching the documentation returns links to places in the
--         documentation. Depending upon the topic, it also returns links to
--         related resources, such as YouTube videos, based on your search term.

-- 1.2.13  Return to the Snowsight UI.

-- 1.3.0   Create Folders and Worksheets
--         In this course, most of the work you do will be through worksheets.
--         Worksheets can be created inside a folder for additional
--         organization, but they do not NEED to be in folders. We will show you
--         how to create a folder in case you want to use them.

-- 1.3.1   Create a folder.
--         From the home screen, ensure that you are on the Worksheets page. In
--         the left navigation bar select Projects, then select Worksheets.
--         To create a folder, click the blue plus (+) button in the upper right
--         corner of the screen. From the drop-down list that displays, select
--         Folder. In the New Folder dialog box, name your folder Working with
--         Snowsight and then click Create Folder. You will now be positioned
--         inside your empty folder.

-- 1.3.2   Load your SQL file for this lab into a worksheet.
--         Click the down arrow just to the right of your folder name. Select
--         Create Worksheet from SQL File. Then:
--         - Navigate to where you downloaded the lab files.
--         - Open the file for this lab. A new worksheet will open with the
--         selected SQL file loaded.
--         - Follow the instructions using the PDF workbook for support!

-- 1.3.3   Return to the Worksheets page.
--         Click the Snowflake logo in the upper left corner. This will return
--         you to the Worksheets page.

-- 1.3.4   Click My Worksheets.
--         Below the Worksheets heading is a row of tab names - Recent, Shared
--         with me, My Worksheets, and Folders. Click the My Worksheets tab. You
--         will see the worksheet you just created. Directly to the right of the
--         worksheet’s name will be the name of the folder it is in.
--         Below your worksheet will be the folder you created, Working with
--         Snowsight.

-- 1.3.5   Click the Folders tab.
--         On this screen, you will see just the name of your folder.

-- 1.3.6   Click the folder name.
--         Once you have opened the folder, you will see the folder name at the
--         top of the screen. Below that is a list of all the worksheets in the
--         folder (currently, there is only one).

-- 1.3.7   Create a new worksheet.
--         Click the blue plus(+) button in the upper right corner and select
--         SQL Worksheet from the drop-down list. This will open a new worksheet
--         inside your folder.
--         Check the name of the worksheet. You will see a new tab to the right
--         of your first worksheet. The name of the new worksheet is a date and
--         timestamp. When you open a worksheet from a SQL file, the worksheet
--         takes on the file’s name. When you open a new worksheet without using
--         a file, the worksheet name will be the date and time the worksheet
--         was created.

-- 1.3.8   Change the name of your worksheet to Empty Worksheet.
--         Click the three vertical dots to the right of the worksheet name and
--         select Rename from the drop-down list. You can also simply double-
--         click on the name of the worksheet to edit the name. Regardless of
--         your chosen method, the current name should automatically be
--         highlighted - type in a new worksheet name and press ENTER (or
--         RETURN). The new worksheet name appears in the tab on the screen.

-- 1.3.9   Click the Snowflake logo in the upper left corner to return to the
--         Worksheets page.

-- 1.3.10  Click My Worksheets from the list of tabs under Worksheets.
--         Your new worksheet is listed, with the folder name to the right.

-- 1.3.11  Click Folders from the list of tabs and open your folder.
--         You will also see your new worksheet listed there.

-- 1.3.12  Open the worksheet containing your SQL file.
--         From the list of worksheets, click the one you first created by
--         loading a SQL file.

-- 1.3.13  Move the worksheet out of the folder.
--         - In the object browser on the left side, make sure the Worksheets
--         tab is selected.
--         - Select the worksheet you created from the SQL file.
--         - In the object browser, hover over and click the ellipsis (…) to the
--         right of the worksheet name.
--         - In the drop-down menu that opens, click Move > and then Remove from
--         Folder.
--         You will remain in the worksheet you just moved, but look at the
--         Worksheets list in the object browser on the left. Notice that your
--         worksheet is no longer in the folder.
--         You will see that the Empty Worksheet is still in the folder.

-- 1.4.0   Explore Worksheets
--         Take a few minutes to familiarize yourself with the components of a
--         worksheet. Each worksheet is a session connected to Snowflake. You
--         can have many active worksheets (or sessions) at once. Each worksheet
--         has a context, which defines the default components you are working
--         with during this session.
--         Your context is an important concept to understand. It defines the
--         objects that are being used by default in this session. It consists
--         of a database, a schema, a role, and a virtual warehouse.
--         - The role that is active will impact what objects you can see and
--         what you can do with them.
--         - The warehouse defines what virtual warehouse you will use to run
--         commands.
--         - The database and schema define the default location you are acting
--         in. For example, if you run SELECT * FROM mytable, Snowflake will
--         look for mytable in the database and schema currently set in your
--         context. If you want to select from a table outside your current
--         context, you must provide the full path to that object, for example,
--         SELECT * FROM my_database.my_schema.mytable.

-- 1.4.1   Orient yourself to the worksheet components.
--         Spend a few minutes to orient yourself to the worksheet before
--         beginning. Locate the following components:
--         - In the upper left corner, you will see the Snowflake logo. This
--         will take you back to the Worksheets page.
--         - At the top are the tabs for any worksheets you currently have open.
--         If you created the worksheet by loading a SQL file, the worksheet’s
--         name will match the name of the file you loaded. If you just created
--         a blank worksheet, the name will be the date and time the worksheet
--         was created (unless you changed the worksheet name; then that will be
--         displayed).
--         - Directly below that is a filter button - ignore this for now.
--         - Along the left side is the object browser. There are two tabs - one
--         labeled Databases and the other labeled Worksheets. This identifies
--         whether a list of your worksheets is displayed or if a list of
--         database objects is displayed. You can switch between them to change
--         what is shown in the object browser.
--         - The large area on the right is the SQL editor pane. This is where
--         you will run SQL commands.
--         - Just above the SQL pane is where you set your default database and
--         schema for this session. You will probably see No Database selected
--         at this point, but once you set your context, you will see the
--         database and schema names.
--         - In the upper right corner, you will see a place where your role and
--         virtual warehouse for this session are set. This sets the remainder
--         of your context. You should see TRAINING_ROLE set for your role and
--         No Warehouse selected where the virtual warehouse name will be. You
--         will create and set a virtual warehouse later in this exercise.
--         - To the right of that is a Share button - ignore that for now.
--         - On the far right is a blue button with a white arrow in it. This is
--         the run button used to run your SQL commands. To the right of the run
--         button is another down arrow. The down arrow lets you Run All
--         statements in your worksheet. You can ignore that for now.

-- 1.4.2   Set your context.
--         Make sure you are in your 01-introduction-to-snowflake-and-snowflake-
--         objects worksheet.
--         If your current role is not set to TRAINING_ROLE, click on the role
--         that is currently set, and then select TRAINING_ROLE. Click outside
--         the box to close it.
--         Click on the arrow to the right of your current database and schema
--         (part of your context, which may read currently as No Database
--         Selected). A list of available databases appears.
--         Select SNOWBEARAIR_DB as your database and MODELED as your schema.
--         Click outside the box to close it.

-- 1.4.3   Create a virtual warehouse and set it in your context.
--         Before you can run any SQL commands, you need a virtual warehouse.
--         Use the following SQL to create a virtual warehouse and to set it in
--         your context.
--         All the SQL you need to run in this course is inside the .SQL files
--         provided. Scroll down in the first worksheet you created until you
--         find this step in the file. Position your cursor in the command you
--         want to run and either click the run button (the blue button with the
--         white arrow in it) in the top right or, even better, use the keyboard
--         shortcut (CTRL+RETURN for Windows or CMD+RETURN for Mac). This is how
--         you will run SQL commands for the rest of the course. Do not copy and
--         paste from the PDF workbook, as you may get unexpected results.

CREATE OR REPLACE WAREHOUSE LEARNER_wh WITH
  WAREHOUSE_SIZE = XSmall 
  INITIALLY_SUSPENDED = true;

USE WAREHOUSE LEARNER_wh;

--         If you look in the role/warehouse part of your context, you will now
--         see TRAINING_ROLE as your role and LEARNER_wh as your virtual
--         warehouse.

-- 1.4.4   Change your role to PUBLIC.
--         You can do this with SQL or by clicking in the context menu to the
--         left of the Share button and selecting it there.
--         To change your role with SQL, run this:

USE ROLE public;

--         Look at the object browser on the left, and make sure Databases is
--         selected. You should now see a much shorter list of databases that
--         you have access to. This is an illustration of how your role impacts
--         what you can see and what you can do.
--         When you change your role to PUBLIC, your virtual warehouse may be
--         deselected.

-- 1.4.5   Change your role back to TRAINING_ROLE.
--         To change your role with SQL, run this:

USE ROLE TRAINING_ROLE;

--         The list of databases should be re-populated with the full list seen
--         before.
--         Run the following command.

USE WAREHOUSE LEARNER_wh;


-- 1.4.6   Show the tables that are in your current context.

SHOW TABLES;

--         The SHOW command is a metadata operation - so you did not use your
--         virtual warehouse. You can tell that the virtual warehouse is
--         suspended (not running) because the small dot to the left of the
--         virtual warehouse name is gray.
--         You can also see the status of your virtual warehouse by clicking on
--         TRAINING_ROLE, selecting your virtual warehouse, LEARNER_wh, in the
--         list of warehouses, and finally clicking on the icon to the right of
--         Run on warehouse... All the details for your virtual warehouse will
--         be displayed. To close the virtual warehouse details, click on the X
--         in the upper right corner of the box.

-- 1.4.7   Query some tables.
--         During this course, many of our exercises will use data from the
--         SNOWBEARAIR_DB database. Take a look at some of that data using the
--         two queries below.

SELECT *
FROM members
LIMIT 10;

SELECT TOP 5
    c.c_lastname,
    c.c_firstname,
    c.c_acctbal
FROM snowbearair_db.promo_catalog_sales.customer c
ORDER BY c.c_acctbal DESC;

--         In the second query above, notice that we supplied the full path
--         (database.schema.table) in the FROM clause. This is because our
--         current context is set to snowbearair_db.modeled, and the table we
--         queried is in a different schema.
--         Run another command.

SELECT 
  c_firstname,
  c_lastname,
  o_orderkey,
  o_totalprice
FROM
  promo_catalog_sales.orders
JOIN
  promo_catalog_sales.customer
ON
  o_custkey = c_custkey
ORDER BY o_totalprice DESC
LIMIT 10;

--         In this command, we only provided the schema name
--         (promo_catalog_sales) and the object name (orders) in the FROM
--         clause. This is because our context already has the correct database
--         (snowbearair_db). You can specify the full path, but if the database
--         is correct, you only need to specify the schema.
--         Also, notice that these queries DID require a virtual warehouse, so
--         yours automatically started up - the dot next to the virtual
--         warehouse name is now green. It will auto-suspend itself after some
--         amount of idle time.

-- 1.5.0   Create Objects
--         One of the things you may do during your work is create objects, such
--         as databases, schemas, and tables. Let’s create a few objects that
--         you will use during this course.

-- 1.5.1   Create a database called LEARNER_db and set it in your context.

CREATE OR REPLACE DATABASE LEARNER_db;

USE DATABASE LEARNER_db;


-- 1.5.2   Create a schema called my_schema in the database you just created.

CREATE OR REPLACE SCHEMA LEARNER_db.my_schema;

USE SCHEMA LEARNER_db.my_schema;


-- 1.5.3   Create a temporary table.

CREATE OR REPLACE TEMPORARY TABLE my_favorite_actors (name VARCHAR);

--         Now, put a few rows in your table, substituting the placeholder names
--         for the names of your actual favorite actors.

INSERT INTO my_favorite_actors
VALUES
  ('Heath Ledger'),
  ('Michelle Pfeiffer'),
  ('Meryl Streep'),
  ('Anthony Hopkins'),
  ('Bruce Lee');

--         Check the values in your table.

SELECT * FROM my_favorite_actors;


-- 1.5.4   Suspend (shut down) your virtual warehouse.

ALTER WAREHOUSE LEARNER_wh SUSPEND;

--         Notice that the dot to the left of your virtual warehouse name turns
--         gray (you may need to refresh your browser window to see this
--         update).
--         The virtual warehouses in the lab environment are configured to shut
--         down after 10 minutes of inactivity, but we’ll shut them down early
--         here to save some credits. In your work environment, your role may
--         not have the privileges to shut down virtual warehouses.

-- 1.6.0   Set Your User Defaults
--         If you are usually working with objects in the same database and
--         schema and using the same role and virtual warehouse, it’s helpful to
--         define your default context. This way, any time you open a new
--         worksheet, these values will already be set for you.

-- 1.6.1   Run this command to set your defaults:

ALTER USER LEARNER SET
   DEFAULT_ROLE = training_role
   DEFAULT_WAREHOUSE = LEARNER_wh
   DEFAULT_NAMESPACE = LEARNER_db.my_schema;


-- 1.7.0   Key Takeaways
--         - You can create folders in which to save and organize worksheets.
--         - You can create database objects using the Snowsight UI and by
--         executing SQL code in a worksheet. We did this exercise using SQL
--         code.
--         - You can browse database objects and view their details by using the
--         object browser in the worksheet.
--         - The context of a worksheet session consists of a role, virtual
--         warehouse, database, and schema.
--         - The context of a worksheet can be set via the Snowsight UI or SQL
--         statements.

-- 1.8.0   Return to the Lab Exercise Page in the Course and Click the Mark as
--         complete Button
