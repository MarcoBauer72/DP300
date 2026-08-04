/*----------------------------------------------------------------- */
/*                                                                  */
/* ----------------------  EXTRA - Query Store  ------------------- */
/*                                                                  */
/*----------------------------------------------------------------- */

-   Recurso novo integrado ao SQL 2016 para armazenar estatísticas de execuções
	de consultas SQL a fim de ajudar a comparar desempenho entre as várias execuções
	da mesma consulta.

-	Grande auxílio para "troubleshooting" de consultas problemáticas.

-	Visibilidade de pontos de melhoria para "tunning" de código SQL.

-	Armazenamento de consultas SQL, planos de execução, compilação 
	e estatísticas de execução.

-	Podemos facilmente encontrar o código completo de consultas executadas no passado e
	identificar qual recurso cada consulta mais consome.

-	Possível forçar um plano de execução específico para determinada consulta para
	"evitar" grande variação de desempenho.
DROP DATABASE [qstr]

CREATE DATABASE qstr
GO 
 
USE qstr
GO

ALTER DATABASE [qstr] SET AUTO_UPDATE_STATISTICS OFF 
GO
ALTER DATABASE [qstr] SET AUTO_CREATE_STATISTICS OFF 
GO
ALTER DATABASE [qstr] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [qstr] SET QUERY_STORE = OFF
GO


-- Creating Table (HEAP)
CREATE TABLE dbo.db_store 
(c1 CHAR(3) NOT NULL
,c2 CHAR(3) NOT NULL
,c3 SMALLINT NULL)
GO

SELECT [c1], [c2], [c3]
FROM [dbo].[db_store]

-- Create a stored procedure
CREATE PROC dbo.proc_1 @par1 SMALLINT
AS 
SET NOCOUNT ON
SELECT c1, c2 FROM dbo.db_store
WHERE c3 = @par1
GO

-- Populating the table (this may take a couple of minutes)
SET NOCOUNT ON
INSERT INTO [dbo].db_store (c1,c2,c3) SELECT '18','2f',2
go 20000
INSERT INTO [dbo].db_store (c1,c2) SELECT '171','1ff'
go 4000  
INSERT INTO [dbo].db_store (c1,c2,c3) SELECT '172','1ff',0
go 10
INSERT INTO [dbo].db_store (c1,c2,c3)   SELECT '172','1ff',4 
go 15000

SELECT COUNT(1) FROM [dbo].db_store

-- Enabling Query Store on the database
ALTER DATABASE [qstr] SET QUERY_STORE = ON
GO

----------------------------------------------------------------
-- PART 1: Review the state of the Query Store
----------------------------------------------------------------
/* 	This query returns the most important Query Store parameters*/
SELECT actual_state_desc, desired_state_desc, current_storage_size_mb, max_storage_size_mb, readonly_reason,
stale_query_threshold_days, size_based_cleanup_mode_desc, query_capture_mode_desc 
FROM sys.database_query_store_options;


/*If actual_state is OFF, turn on Query Store again*/
USE master;
GO

ALTER DATABASE 
[qstr] 
SET QUERY_STORE = ON
(	
	CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 31), 
	DATA_FLUSH_INTERVAL_SECONDS = 120, 
	INTERVAL_LENGTH_MINUTES = 1, 
	MAX_STORAGE_SIZE_MB = 1024, 
	QUERY_CAPTURE_MODE = ALL, 
	SIZE_BASED_CLEANUP_MODE = AUTO
)
GO

sp_spaceused '[dbo].[db_store]'

-- Executing the PROCEDURE without indexes created
EXEC dbo.proc_1 0
GO 20

--In SSMS under "Query Store" database's container open
--"Top Resource Consuming Queries" pane.
--Change the vertical axis to USE "exec count" and change the "Metric" 
--drop down from "Duration" to "Logical Reads".

--CREATE PROC dbo.proc_1 @par1 SMALLINT
--AS 
--SET NOCOUNT ON
--SELECT c1, c2 FROM dbo.db_store
--WHERE c3 = @par1
--GO

--Testing with a Non Clustered Index
CREATE NONCLUSTERED INDEX NCI_1
ON dbo.db_store (c3)
GO

EXEC dbo.proc_1 0
GO 20 


--Go back to the Query Store pane in SSMS and refresh the results.
--Note, that the new plan (Plan #13) was created and used. 
--This plan has less logical reads now.


-- Create Another Non Clustered Index
CREATE NONCLUSTERED INDEX NCI_2
ON dbo.db_store (c3, c1)
GO

EXEC dbo.proc_1 0
GO 20

-- Review the results in SSMS and note that another plan (Plan #20) was created.

-- Let's run some table updates and execute the procedure again
UPDATE  dbo.db_store SET c1  ='1' WHERE c3 = '0'
UPDATE  dbo.db_store SET c2  ='3ff' WHERE c3 = '1'
DELETE FROM dbo.db_store  WHERE c3 = 3
INSERT INTO  dbo.db_store (c1,c2,c3) SELECT '173','1fa',0
GO 5

EXEC dbo.proc_1 0
GO 20


 ----------------------------------------------------------------
-- PART 2: Analyze Query Store data
-----------------------------------------------------------------
USE qstr;
GO

/*Find last 10 queries executed in the database*/
SELECT TOP 20 qt.query_sql_text, q.query_id, 
    qt.query_text_id, p.plan_id, rs.last_execution_time
FROM sys.query_store_query_text AS qt 
JOIN sys.query_store_query AS q 
    ON qt.query_text_id = q.query_text_id 
JOIN sys.query_store_plan AS p 
    ON q.query_id = p.query_id 
JOIN sys.query_store_runtime_stats AS rs 
    ON p.plan_id = rs.plan_id
ORDER BY rs.last_execution_time DESC;

/*Get number of executions for each query*/
SELECT q.query_id, qt.query_text_id, qt.query_sql_text, 
    SUM(rs.avg_dop) AS dop
FROM sys.query_store_query_text AS qt 
JOIN sys.query_store_query AS q 
    ON qt.query_text_id = q.query_text_id 
JOIN sys.query_store_plan AS p 
    ON q.query_id = p.query_id 
JOIN sys.query_store_runtime_stats AS rs 
    ON p.plan_id = rs.plan_id
GROUP BY q.query_id, qt.query_text_id, qt.query_sql_text
ORDER BY dop DESC;

GO

--Go back to the Query Store pane in SSMS and click 
--"View plan summary in a grid format" button

--Note, that the latest plan #20 has more logical reads 
--than the old plan #13.

--Click on the "Force Plan" button under the "Plan Summary" or "Execution Plan" 
--section of the Query Store report. You can also right click on plan #13 and force 
--the plan as well. Confirm that you want to force this plan for the query:

-- Another way to force the plan is by using  sp_query_store_force_plan stored procedure:
EXEC sp_query_store_force_plan @query_id = 50, @plan_id = 62;

--CREATE PROC dbo.proc_1 @par1 SMALLINT
--AS 
--SET NOCOUNT ON
--SELECT c1, c2 FROM dbo.db_store
--WHERE c3 = @par1
--GO

--Create the final, optimal index for the stored procedure
CREATE NONCLUSTERED INDEX NCI_3
ON dbo.db_store (c3)
INCLUDE (c1,c2)


EXEC dbo.proc_1 0
GO 20

--Now we will un-force plan #13 and run the stored procedure again
EXEC sp_query_store_unforce_plan @query_id = 2, @plan_id = 16
GO

EXEC dbo.proc_1 0
GO


/*Get queries with more than one execution plan (plan forcing candidates)*/
;WITH Query_MultPlans
AS
(
SELECT COUNT(*) AS cnt, q.query_id 
FROM sys.query_store_query_text AS qt
JOIN sys.query_store_query AS q
    ON qt.query_text_id = q.query_text_id
JOIN sys.query_store_plan AS p
    ON p.query_id = q.query_id
GROUP BY q.query_id
HAVING COUNT(distinct plan_id) > 1
)
SELECT q.query_id, object_name(object_id) AS ContainingObject, query_sql_text,
plan_id, p.query_plan AS plan_xml,
p.last_compile_start_time, p.last_execution_time
FROM Query_MultPlans AS qm
JOIN sys.query_store_query AS q
    ON qm.query_id = q.query_id
JOIN sys.query_store_plan AS p
    ON q.query_id = p.query_id
JOIN sys.query_store_query_text qt 
    ON qt.query_text_id = q.query_text_id
ORDER BY query_id, plan_id;

GO


/*Get detailed info for top 25 queries with the longest execution in last hour*/
;WITH AggregatedDurationLastHour
AS
(
   SELECT q.query_id, SUM(count_executions * avg_duration) AS total_duration,
   COUNT (distinct p.plan_id) AS number_of_plans
   FROM sys.query_store_query_text AS qt JOIN sys.query_store_query AS q 
   ON qt.query_text_id = q.query_text_id
   JOIN sys.query_store_plan AS p ON q.query_id = p.query_id
   JOIN sys.query_store_runtime_stats AS rs ON rs.plan_id = p.plan_id
   JOIN sys.query_store_runtime_stats_interval AS rsi 
   ON rsi.runtime_stats_interval_id = rs.runtime_stats_interval_id
   WHERE rsi.start_time >= DATEADD(hour, -1, GETUTCDATE()) 
   AND rs.execution_type_desc = 'Regular'
   GROUP BY q.query_id
)
,OrderedDuration
AS
(
   SELECT query_id, total_duration, number_of_plans, 
   ROW_NUMBER () OVER (ORDER BY total_duration DESC, query_id) AS RN
   FROM AggregatedDurationLastHour
)
SELECT qt.query_sql_text, object_name(q.object_id) AS containing_object,
total_duration AS total_duration_microseconds, number_of_plans,
CONVERT(xml, p.query_plan) AS query_plan_xml, p.is_forced_plan, p.last_compile_start_time,q.last_execution_time
FROM OrderedDuration od JOIN sys.query_store_query AS q ON q.query_id  = od.query_id
JOIN sys.query_store_query_text qt ON q.query_text_id = qt.query_text_id
JOIN sys.query_store_plan p ON q.query_id = p.query_id
WHERE OD.RN <=25 ORDER BY total_duration DESC

GO

/*
	Queries with multiple plans among those with longest duration within last hour
	USE results to identify which plan had the best performance 
	as it can be a good candidate for plan forcing 
*/
;WITH AggregatedDurationLastHour
AS
(
   SELECT q.query_id, SUM(count_executions * avg_duration) AS total_duration,
   COUNT (distinct p.plan_id) AS number_of_plans
   FROM sys.query_store_query_text AS qt JOIN sys.query_store_query AS q 
   ON qt.query_text_id = q.query_text_id
   JOIN sys.query_store_plan AS p ON q.query_id = p.query_id
   JOIN sys.query_store_runtime_stats AS rs ON rs.plan_id = p.plan_id
   JOIN sys.query_store_runtime_stats_interval AS rsi 
   ON rsi.runtime_stats_interval_id = rs.runtime_stats_interval_id
   WHERE rsi.start_time >= DATEADD(hour, -1, GETUTCDATE()) 
   AND rs.execution_type_desc = 'Regular'
   GROUP BY q.query_id
)
,OrderedDuration
AS
(
   SELECT query_id, total_duration, number_of_plans, 
   ROW_NUMBER () OVER (ORDER BY total_duration DESC, query_id) AS RN
   FROM AggregatedDurationLastHour
)
SELECT qt.query_sql_text, object_name(q.object_id) AS containing_object, q.query_id,
p.plan_id,rsi.start_time as interval_start, rs.avg_duration,
CONVERT(xml, p.query_plan) AS query_plan_xml
FROM OrderedDuration od JOIN sys.query_store_query AS q ON q.query_id  = od.query_id
JOIN sys.query_store_query_text AS qt ON q.query_text_id = qt.query_text_id
JOIN sys.query_store_plan AS p ON q.query_id = p.query_id
JOIN sys.query_store_runtime_stats AS rs ON rs.plan_id = p.plan_id
JOIN sys.query_store_runtime_stats_interval AS rsi ON rsi.runtime_stats_interval_id = rs.runtime_stats_interval_id
WHERE rsi.start_time >= DATEADD(hour, -1, GETUTCDATE())
AND OD.RN <=25 AND number_of_plans > 1
ORDER BY total_duration DESC, query_id, rsi.runtime_stats_interval_id, p.plan_id

/*Check the state of forced plans. Inspect force_failure_reason and last_force_failure_reason_desc*/
SELECT p.plan_id, p.query_id, q.object_id as containing_object_id,
force_failure_count, last_force_failure_reason_desc
FROM sys.query_store_plan p
JOIN sys.query_store_query q on p.query_id = q.query_id
WHERE is_forced_plan = 1;


----------------------------------------------------------------
-- PART 3: Clear Query Store data (optionally)
----------------------------------------------------------------
USE master;
GO

ALTER DATABASE qstr SET QUERY_STORE CLEAR;


Referencias:
https://channel9.msdn.com/Blogs/TechDays-Russia/Query-Store--SQL-Server-2016
https://channel9.msdn.com/events/DataDriven/SQLServer2016/QueryStore
https://channel9.msdn.com/events/Microsoft-Data-Driven-So-Paulo/Microsoft-Data-Driven-So-Paulo/Query-Store-no-SQL-2016-Tuning-Pergunte-me-como
https://msdn.microsoft.com/en-us/library/dn817826.aspx 
https://msdn.microsoft.com/en-US/library/mt631173.aspx
https://msdn.microsoft.com/en-us/library/mt604821.aspx
https://msdn.microsoft.com/en-US/library/mt614796.aspx
https://azure.microsoft.com/en-us/blog/query-store-a-flight-data-recorder-for-your-database/ 

Videos:
https://www.youtube.com/watch?v=VU7-05SOUxE
https://www.youtube.com/watch?v=HxBRjZXi3L0