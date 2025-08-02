------------------------ DP300 - MODULO 05 -------------------------


/* ----------------------------------------- */
/* Lab 5 - Query Performance Troubleshooting */
/* ----------------------------------------- */

-- 1) Identify issues with database design
-- 2) Isolate problem areas in poorly performing queries



----- Exercise 1: Identify issues with database design in AdventureWorks2017 -----
https://microsoftlearning.github.io/dp-300-database-administrator/Instructions/Labs/09-identify-issues-database-design.html


----- Exercise 2: Isolate problem areas in poorly performing queries in AdventureWorks2017 -----
https://microsoftlearning.github.io/dp-300-database-administrator/Instructions/Labs/10-isolate-problem-areas-poor-performing-queries.html


DECLARE @NOME AS VARCHAR(10) = 'Michael'

SELECT 
[BusinessEntityID], [PersonType], [FirstName], [LastName]
FROM [Person].[Person]
WHERE FirstName = @NOME



/* ----- Referencias ----- */
-- SQL Server Execution plans:
https://www.red-gate.com/simple-talk/books/sql-server-execution-plans-third-edition-by-grant-fritchey/

-- Monitoring performance by using the Query Store:
https://docs.microsoft.com/en-us/sql/relational-databases/performance/monitoring-performance-by-using-the-query-store?view=sql-server-ver15

-- Query processing architecture guide:
https://docs.microsoft.com/en-us/sql/relational-databases/query-processing-architecture-guide?view=sql-server-ver15

-- Index architecture and design:
https://docs.microsoft.com/en-us/sql/relational-databases/sql-server-index-design-guide?view=sql-server-ver15 