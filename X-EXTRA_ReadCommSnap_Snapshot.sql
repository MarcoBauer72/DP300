----- SQL SERVER – Difference Between Read Committed Snapshot and Snapshot Isolation Level

-- Data Preparation
SET NOCOUNT ON
GO
USE MASTER
GO

IF DB_ID('SNAPEX') IS NOT NULL
BEGIN
ALTER DATABASE SNAPEX SET single_user WITH ROLLBACK IMMEDIATE
DROP DATABASE SNAPEX
END
GO

CREATE DATABASE SNAPEX
GO
USE SNAPEX
GO

DELETE DemoTable
CREATE TABLE DemoTable(
i INT
,j VARCHAR(100)
)
GO
 
INSERT INTO DemoTable VALUES (1, 'ONE')
INSERT INTO DemoTable VALUES (2, 'TWO')
INSERT INTO DemoTable VALUES (3, 'THREE')
SET NOCOUNT OFF

SELECT * FROM DemoTable

-- Session 1
USE SNAPEX
GO
BEGIN TRAN
UPDATE DemoTable
SET i = 4
WHERE i = 1


--SELECT @@TRANCOUNT
--DBCC OPENTRAN()

-- Session 2
USE SNAPEX
GO
 
SELECT *
FROM   DemoTable
WHERE i = 1

-- Session 1
ROLLBACK

-- Result – Query in Session 2 would be unlocked and would show result. It would show last committed data. 
-- Since we have done rollback in session 1, we would see original values. (1, ONE)




---------- READ COMMITTED SNAPSHOT ----------
-- It´s NOT an isolation level. It is the behavior in reading committed isolation level, 
-- which gets activated only if we turn on database level property)

--Change the database property as below
ALTER DATABASE SNAPEX
SET READ_COMMITTED_SNAPSHOT ON WITH ROLLBACK IMMEDIATE
GO

-- Session 1
USE SNAPEX
GO
BEGIN TRAN
UPDATE DemoTable
SET i = 4
WHERE i = 1
 

-- Session 2
USE SNAPEX
GO
BEGIN TRAN
SELECT *
FROM   DemoTable
WHERE i = 1

-- Result – Query in Session 2 shows old value (1, ONE) because current transaction is NOT committed. This is 
-- the way to avoid blocking and read committed data also.

-- Session 1
COMMIT

-- Session 2
USE SNAPEX
GO
SELECT *
FROM   DemoTable
WHERE i = 1

-- Result – Query in Session 2 shows no rows because row is updated in session 1. 
-- So again, we are seeing committed data.




---------- SNAPSHOT ISOLATION LEVEL ----------

-- This is the new isolation level, which was available from SQL Server 2005 onwards. 
-- For this feature, there is a change needed in the application as it has to use a new isolation level.


ALTER DATABASE SNAPEX SET AllOW_SNAPSHOT_ISOLATION ON


-- Session 1
USE SNAPEX
GO
BEGIN TRAN
UPDATE DemoTable
SET i = 10
WHERE i = 2


-- Session 2
SET TRANSACTION ISOLATION LEVEL SNAPSHOT
GO
USE SNAPEX
GO
BEGIN TRAN
SELECT *
FROM   DemoTable
WHERE i = 2

--Result- Even if we have changed the value to 10, we will still see old record in session 2 (2, TWO). 


-- Session 1
COMMIT

SELECT @@TRANCOUNT

-- Session 2
SELECT *
FROM   DemoTable
WHERE i = 2

-- We will still see the record because session 2 has stated the transaction with snapshot isolation. 
-- Unless we complete the transaction, we will not see latest record.


-- Session 2 Again
COMMIT
SELECT *
FROM   DemoTable
WHERE i = 2

-- Now, we should not see the row as its already updated.


-- In summary, SQL Server 2005 onwards, SQL engine provides only one new isolation level AND an optimistic 
-- implementation of READ COMMITTED. Isolation level SNAPSHOT is a new isolation level and 
-- READ COMMITTED SNAPSHOT is the same isolation level as READ COMMITTED but is the optimistic implementation of it.


-- Referencia:
-- https://blog.sqlauthority.com/2015/07/03/sql-server-difference-between-read-committed-snapshot-and-snapshot-isolation-level/