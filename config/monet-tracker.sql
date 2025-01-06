-- Create database
CREATE DATABASE MONEY_TRACKER;


--Create user table
CREATE TABLE MONEY_TRACKER.USERS (
    EMAIL_ID VARCHAR(50) PRIMARY KEY,
    NAME VARCHAR(100) NOT NULL,
    PASSWORD TEXT NOT NULL,
    REGISTRATION_DATE TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PROFILE_PICTURE TEXT
);



-- Start of Stored procedure to register user----

DELIMITER $$

CREATE PROCEDURE RegisterUser(
    IN input_EMAIL_ID VARCHAR(50),
    IN input_NAME VARCHAR(100),
    IN input_PASSWORD TEXT,
	IN input_imageURL TEXT,
    OUT returncode INT,
    OUT returnmessage VARCHAR(255)
)
BEGIN
    -- Check if the email already exists in the USERS table
    IF EXISTS (SELECT 1 FROM MONEY_TRACKER.USERS WHERE EMAIL_ID = input_EMAIL_ID) THEN
        -- Email exists, set return values for already existing user
        SET returncode = 0;
        SET returnmessage = 'User already exists in database, please login';
    ELSE
        -- Email does not exist, insert the user into the table
        INSERT INTO MONEY_TRACKER.USERS (EMAIL_ID, NAME, PASSWORD,PROFILE_PICTURE) 
        VALUES (input_EMAIL_ID, input_NAME, input_PASSWORD,input_imageURL);
        
        -- Set return values for successful registration
        SET returncode = 1;
        SET returnmessage = 'User successfully registered, please proceed for login';
    END IF;
END $$

DELIMITER ;

-- End of Stored procedure to register user----

--Create table to log user login login report--

CREATE TABLE MONEY_TRACKER.USERS_LOGIN_EVENTS (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    LOGIN_EMAIL_ID VARCHAR(50) NOT NULL,
    EVENT_TYPE ENUM('LogIn', 'LogOut') NOT NULL,
    BROWSER_DETAILS TEXT NOT NULL,
    LOGIN_TIME DATETIME NOT NULL,
    LOGOUT_TIME DATETIME
);

--Category table--
CREATE TABLE CATEGORIES (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    CATEGORY_NAME VARCHAR(255) NOT NULL,
    CATEGORY_TYPE VARCHAR(100) NOT NULL,
    USER VARCHAR(50) NOT NULL,
    IMAGE_URL TEXT
);

------Insert category stored procedure----------------
DELIMITER $$

CREATE PROCEDURE CreateCategory(
    IN input_email VARCHAR(50),
    IN input_categoryName VARCHAR(100),
    IN input_categoryType TEXT,
    IN input_imageURL TEXT,
    OUT returncode INT,
    OUT returnmessage VARCHAR(255)
)
BEGIN
    -- Check if the email exists in the USERS table
    IF EXISTS (SELECT 1 FROM MONEY_TRACKER.USERS WHERE EMAIL_ID = input_email) THEN
        -- Email exists, proceed to insert the category
        INSERT INTO MONEY_TRACKER.CATEGORIES (CATEGORY_NAME, CATEGORY_TYPE, IMAGE_URL, USER)
        VALUES (input_categoryName, input_categoryType, input_imageURL, input_email);

        -- Check if the category insertion was successful
        IF ROW_COUNT() > 0 THEN
            SET returncode = 1;
            SET returnmessage = 'Category created successfully.';
        ELSE
            -- Handle cases where category insertion fails
            SET returncode = 0;
            SET returnmessage = 'Unable to create category.';
        END IF;
    ELSE
        -- Email does not exist in USERS table
        SET returncode = 0;
        SET returnmessage = 'No user found with the provided email.';
    END IF;
END $$

DELIMITER ;


---Transaction table
CREATE TABLE TRANSACTIONS (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    CATEGORY_NAME VARCHAR(50) NOT NULL,
    CATEGORY_TYPE VARCHAR(50) NOT NULL,
    USER VARCHAR(50) NOT NULL,
    IMAGE_ID TEXT NOT NULL,
    SHORT_NOTE TEXT,
    TRANSACTION_DATE DATE NOT NULL,
	AMOUNT varchar(10) NOT NULL
);

--Insert Transaction---

DELIMITER $$

CREATE PROCEDURE InsertTransaction(
    IN input_CATEGORY_NAME VARCHAR(50),
    IN input_CATEGORY_TYPE VARCHAR(20),
    IN input_USER VARCHAR(50),
    IN input_IMAGE_ID TEXT,
    IN input_SHORT_NOTE TEXT,
    IN input_TRANSACTION_DATE DATE,
	IN input_Amount varchar(10),
    OUT returncode INT,
    OUT returnmessage VARCHAR(255)
)
BEGIN
    -- Check if the email exists in the USERS table
    IF EXISTS (SELECT 1 FROM MONEY_TRACKER.USERS WHERE EMAIL_ID = input_USER) THEN
        -- Email exists, proceed to insert the transaction
        INSERT INTO MONEY_TRACKER.TRANSACTIONS (CATEGORY_NAME, CATEGORY_TYPE, USER, IMAGE_ID, SHORT_NOTE, TRANSACTION_DATE,AMOUNT)
        VALUES (input_CATEGORY_NAME, input_CATEGORY_TYPE, input_USER, input_IMAGE_ID, input_SHORT_NOTE, input_TRANSACTION_DATE,input_Amount);

        -- Check if the transaction insertion was successful
        IF ROW_COUNT() > 0 THEN
            SET returncode = 1;
            SET returnmessage = 'Transaction added successfully!';
        ELSE
            -- Handle cases where transaction insertion fails
            SET returncode = 0;
            SET returnmessage = 'Unable to insert transaction';
        END IF;
    ELSE
        -- Email does not exist in USERS table
        SET returncode = 0;
        SET returnmessage = 'No user found with the provided email.';
    END IF;
END $$

DELIMITER ;

--Get transaction by filter--

DELIMITER $$

CREATE PROCEDURE GetTransactionsByFilter(
    IN filter VARCHAR(50),
    IN startdate DATE,
    IN enddate DATE
)
BEGIN
    -- Declare variables for dynamic date ranges
    DECLARE startOfMonth DATE;
    DECLARE endOfMonth DATE;
    DECLARE startOfYear DATE;
    DECLARE endOfYear DATE;
    DECLARE startOfLast6Months DATE;

    -- Calculate dynamic date ranges
    SET startOfMonth = DATE_FORMAT(CURDATE(), '%Y-%m-01');
    SET endOfMonth = LAST_DAY(CURDATE());
    SET startOfYear = DATE_FORMAT(CURDATE(), '%Y-01-01');
    SET endOfYear = DATE_FORMAT(CURDATE(), '%Y-12-31');
    SET startOfLast6Months = DATE_SUB(startOfMonth, INTERVAL 6 MONTH);

    -- Retrieve data based on the filter condition
    IF filter = 'Today' THEN
        SELECT * 
        FROM Transactions
        WHERE TRANSACTION_DATE = CURDATE();

    ELSEIF filter = 'this-month' THEN
        SELECT * 
        FROM Transactions
        WHERE TRANSACTION_DATE BETWEEN startOfMonth AND endOfMonth;

    ELSEIF filter = 'last-6-months' THEN
        SELECT * 
        FROM Transactions
        WHERE TRANSACTION_DATE BETWEEN startOfLast6Months AND endOfMonth;

    ELSEIF filter = 'this-year' THEN
        SELECT * 
        FROM Transactions
        WHERE TRANSACTION_DATE BETWEEN startOfYear AND endOfYear;

    ELSEIF filter = 'custom' AND startdate IS NOT NULL AND enddate IS NOT NULL THEN
        SELECT * 
        FROM Transactions
        WHERE TRANSACTION_DATE BETWEEN startdate AND enddate;

    ELSE
        SELECT 'Invalid filter or missing date parameters' AS ErrorMessage;
    END IF;
END$$

DELIMITER ;
