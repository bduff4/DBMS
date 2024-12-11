-- Drop table if it already exists
DROP TABLE IF EXISTS accounts;

-- Step 1: Create the `accounts` table
CREATE TABLE accounts (
    account_num INT PRIMARY KEY, 
    branch_name VARCHAR(50), 
    balance DECIMAL(10, 2), 
    account_type VARCHAR(20)
);

-- Step 2: Create the stored procedure to populate the table
DELIMITER //

CREATE PROCEDURE generate_accounts(IN num_records INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    START TRANSACTION;
    WHILE i < num_records DO
        INSERT INTO accounts (account_num, branch_name, balance, account_type)
        VALUES (
            i + 10000,
            CONCAT('Branch_', FLOOR(RAND() * 10)),  -- Random branch names
            FLOOR(RAND() * 100000),                -- Random balance between 0 and 100,000
            CASE WHEN RAND() < 0.5 THEN 'Checking' ELSE 'Savings' END -- Random account type
        );
        SET i = i + 1;
    END WHILE;
    COMMIT;
END //

DELIMITER ;

-- Populate the table with datasets of varying sizes
CALL generate_accounts(50000);
CALL generate_accounts(100000);
CALL generate_accounts(150000);

-- Step 3: Create indexes to optimize performance
CREATE INDEX idx_branch_name ON accounts(branch_name);
CREATE INDEX idx_account_type ON accounts(account_type);
CREATE INDEX idx_balance ON accounts(balance);


-- Step 4: Create a stored procedure to measure query execution time
DELIMITER //


CREATE PROCEDURE measure_query_time(IN query_text TEXT)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE start_time DATETIME(6);
    DECLARE end_time DATETIME(6);
    DECLARE total_time BIGINT DEFAULT 0;
    DECLARE elapsed_time BIGINT;
    DECLARE avg_time BIGINT;

    WHILE i < 10 DO
        SET @sql_query = query_text;

        SET start_time = CURRENT_TIMESTAMP(6);
        PREPARE stmt FROM @sql_query;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        SET end_time = CURRENT_TIMESTAMP(6);
        
        SET elapsed_time = TIMESTAMPDIFF(MICROSECOND, start_time, end_time);
        SET total_time = total_time + elapsed_time;
        SET i = i + 1;
    END WHILE;

    SET avg_time = total_time / 10;
    SELECT avg_time AS avg_execution_time_microseconds;
END //

DELIMITER ;


-- Step 5: Execute queries with and without indexes and compare results

-- Test Point Query 
CALL measure_query_time('SELECT COUNT(*) FROM accounts WHERE branch_name = "Branch_1" AND balance = 50000');

-- Test Range Query 
CALL measure_query_time('SELECT COUNT(*) FROM accounts WHERE branch_name = "Branch_1" AND balance BETWEEN 10000 AND 50000');

-- Remove indexes for testing without them
DROP INDEX idx_branch_name ON accounts;

DROP INDEX idx_account_type ON accounts;

DROP INDEX idx_balance ON accounts;

-- Test Point Query without indexes
CALL measure_query_time('SELECT COUNT(*) FROM accounts WHERE branch_name = "Branch_1" AND balance = 50000');

-- Test Range Query without indexes
CALL measure_query_time('SELECT COUNT(*) FROM accounts WHERE branch_name = "Branch_1" AND balance BETWEEN 10000 AND 50000');
