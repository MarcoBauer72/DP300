/*----------------------------------------------------------------- */
/*                                                                  */
/* --------------------   Profiling SQL / XE   -------------------- */
/*                                                                  */
/*----------------------------------------------------------------- */


----- Demo 1: Using SQL Server Profiler ----------

SELECT * FROM fn_trace_gettable ('D:\DP300\trace\SQLPROFILER20250425.trc', default);

-- Passo1: SSMS -> Tools -> Sql Profiler

-- Passo2: Trace name: Demo Trace
--		   Use the template: TSQL
--		   Save to file: D:\Demofiles\Demo Trace.trc

-- Passo3: Events Selection-> TSQL-> Show all events-> 
--		   under TSQL, select SQL:StmtCompleted

-- Passo4: Show all columns and select the Duration column for the SQL:StmtCompleted EVENT
 
-- Passo5: Show all columns->Column header for the Database Name
--		   Like, enter AdventureWorks, and click OK. Run Trace.

-- Passo6: Rodar a query abaixo e nao fechar o SQL Profiler ao final
USE AdventureWorks;
GO

SELECT	YEAR(o.OrderDate) AS CalendarYear,
		s.Name AS SubCategory,
		SUM (d.OrderQty) ItemsSold,
		SUM(d.LineTotal) As Revenue
FROM Sales.SalesOrderHeader o
JOIN Sales.SalesOrderDetail d ON o.SalesOrderID = d.SalesOrderID
JOIN Production.Product p ON d.ProductID = p.ProductID
JOIN Production.ProductSubcategory s ON p.ProductSubcategoryID = s.ProductSubcategoryID
JOIN Production.ProductCategory pc ON s.ProductCategoryID = pc.ProductCategoryID
WHERE pc.Name = 'Bikes'
GROUP BY YEAR(o.OrderDate), s.Name
ORDER BY YEAR(o.OrderDate), s.Name;
GO 20

----- Demo 2: Using SQL Trace (SERVER SIDE TRACE) ----------

-- Passo1: SQL Server Profiler -> File -> Export -> Script Trace Definition ->
--		   For SQL Server 2005 - 2014

-- Passo2: Save DemoTrace.sql in the D:\Demofiles\Mod08 folder. Deixar SQL Profiler aberto

-- Passo3: SSMS -> open the DemoTrace.sql

-- Passo4: Substituir InsertFileNameHere em exec @rc = sp_trace_create
--         por D:\Demofiles\Mod08\SQLTraceDemo

-- Passo5: Execute e anote o TraceID

-- Passo6: Execute a query abaixo:
USE AdventureWorks;
GO

SELECT	YEAR(o.OrderDate) AS CalendarYear,
		s.Name AS SubCategory,
		SUM (d.OrderQty) ItemsSold,
		SUM(d.LineTotal) As Revenue
FROM Sales.SalesOrderHeader o
JOIN Sales.SalesOrderDetail d ON o.SalesOrderID = d.SalesOrderID
JOIN Production.Product p ON d.ProductID = p.ProductID
JOIN Production.ProductSubcategory s ON p.ProductSubcategoryID = s.ProductSubcategoryID
JOIN Production.ProductCategory pc ON s.ProductCategoryID = pc.ProductCategoryID
WHERE pc.Name = 'Bikes'
GROUP BY YEAR(o.OrderDate), s.Name
ORDER BY YEAR(o.OrderDate), s.Name;
GO 20


-- Passo7: Stop the trace
DECLARE @TraceID int = 2; --Replace with correct TraceID if necessary
EXEC sp_trace_setstatus @TraceID, 0;
EXEC sp_trace_setstatus @TraceID, 2;
GO

-- Passo8: View the trace
SELECT * FROM sys.traces -- Verificar TRACES ativos

SELECT * FROM fn_trace_getinfo(default) -- Verificar TRACES ativos

SELECT * FROM fn_trace_gettable('D:\DP300\trace\ssdtrace.trc', default);



----- Demo 3: Creating an Extended Events Session -----
--1. In the D:\Demofiles\Mod12 folder, run Setup.cmd as Administrator.

--2. In the User Account Control dialog box, click Yes and wait for the script to finish.

--3. Start SQL Server Management Studio and connect to the MIA-SQL database engine instance using
--Windows authentication.

--4. Create XE Session  (Step 1 to Step 5)

-- Step 1 - Define an Extended Events session to capture the text of completed SQL statements
-- when executed by the ADVENTUREWORKS\Student login
CREATE EVENT SESSION xe_stmtcompleted_adventureworks ON SERVER
ADD EVENT sqlserver.sql_statement_completed (
	ACTION (sqlserver.sql_text,sqlserver.session_id)

)
ADD TARGET package0.ring_buffer
WITH (MAX_MEMORY=4096 KB,
	EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,
	MAX_DISPATCH_LATENCY=30 SECONDS,
	MAX_EVENT_SIZE=0 KB,
	MEMORY_PARTITION_MODE=NONE,
	TRACK_CAUSALITY=OFF,
	STARTUP_STATE=ON);
GO

-- Idem ao acima porem TARGET FILE
CREATE EVENT SESSION xe_stmtcompleted_file ON SERVER
ADD EVENT sqlserver.sql_statement_completed (
	ACTION (sqlserver.sql_text,sqlserver.session_id)

)
ADD TARGET package0.event_file(SET filename=N'D:\DP300\XE\xe_stmtcompleted.xel')
WITH (MAX_MEMORY=4096 KB,
	EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,
	MAX_DISPATCH_LATENCY=30 SECONDS,
	MAX_EVENT_SIZE=0 KB,
	MEMORY_PARTITION_MODE=NONE,
	TRACK_CAUSALITY=OFF,
	STARTUP_STATE=ON);
GO


--- Referencia gravando no Ring Buffer sem filtrar o banco de dados
CREATE EVENT SESSION [xeringbuffer] ON SERVER 
ADD EVENT sqlserver.sp_statement_completed(
    ACTION(sqlos.cpu_id,SQLSatellite.AppName,sqlserver.client_hostname,sqlserver.database_name,sqlserver.sql_text,sqlserver.username,XtpCompile.AppName)
    ),
ADD EVENT sqlserver.sql_statement_completed(
    ACTION(sqlos.cpu_id,SQLSatellite.AppName,sqlserver.client_hostname,sqlserver.database_name,sqlserver.sql_text,sqlserver.username,XtpCompile.AppName)
   )
ADD TARGET package0.ring_buffer
WITH (STARTUP_STATE=ON)
GO



--- Referencia gravando no Ring Buffer e filtrando banco "AdventureWorks"
CREATE EVENT SESSION [xeringbuffer] ON SERVER 
ADD EVENT sqlserver.sp_statement_completed(
    ACTION(sqlos.cpu_id,SQLSatellite.AppName,sqlserver.client_hostname,sqlserver.database_name,sqlserver.sql_text,sqlserver.username,XtpCompile.AppName)
    WHERE ([sqlserver].[database_name]=N'AdventureWorks')),
ADD EVENT sqlserver.sql_statement_completed(
    ACTION(sqlos.cpu_id,SQLSatellite.AppName,sqlserver.client_hostname,sqlserver.database_name,sqlserver.sql_text,sqlserver.username,XtpCompile.AppName)
    WHERE ([sqlserver].[database_name]=N'AdventureWorks'))
ADD TARGET package0.ring_buffer
WITH (STARTUP_STATE=ON)
GO


--- Referencia gravando em arquivos XEL e filtrando banco "AdventureWorks"
CREATE EVENT SESSION [minhacapturaxe] ON SERVER 
ADD EVENT sqlserver.sp_statement_completed(
    ACTION(sqlos.cpu_id,SQLSatellite.AppName,sqlserver.client_app_name,sqlserver.context_info,sqlserver.database_name,sqlserver.sql_text,sqlserver.username,XtpCompile.AppName)
    WHERE ([sqlserver].[database_name]=N'AdventureWorks')),
ADD EVENT sqlserver.sql_statement_completed(
    ACTION(sqlos.cpu_id,SQLSatellite.AppName,sqlserver.client_app_name,sqlserver.context_info,sqlserver.database_name,sqlserver.sql_text,sqlserver.username,XtpCompile.AppName)
    WHERE ([sqlserver].[database_name]=N'AdventureWorks'))
ADD TARGET package0.event_file(SET filename=N'D:\DP300\XE\minhacapturaxe.xel')
WITH (STARTUP_STATE=ON)
GO


-- Step 2 - the session has been created, so it exists in sys.server_event_sessions
-- but is not visible in sys.dm_xe_sessions
SELECT * FROM sys.server_event_sessions WHERE name = 'xe_stmtcompleted_adventureworks';
SELECT * FROM sys.dm_xe_sessions WHERE name = 'xe_stmtcompleted_adventureworks';

-- Step 3 - alter the session to start it and execute some SQL statements
ALTER EVENT SESSION xe_stmtcompleted_adventureworks ON SERVER
	STATE=START
GO
SELECT 'sample extended events 111' AS v1;
GO
SELECT 'sample extended events 2222' AS v2;
GO

-- Step 4 - query the captured data
-- run the SQL statement below, then click on the XML data in the first row of the xe_data column
-- In the xml window which opens, scroll down to demonstrate that the SELECT statements
-- executed in step 2 were captured. 
-- Demonstrate that the structure of the XML corresponds to the session definition, with actions nested inside events
SELECT CAST(target_data AS XML) AS xe_data
FROM sys.dm_xe_session_targets AS st
JOIN sys.dm_xe_sessions AS  s 
ON st.event_session_address = s.address
WHERE s.name = 'xe_stmtcompleted_file';

-- Step 5 - query the captured data (ii) - to make the data more usable, shred the XML
-- run the SQL statement below, then click on the XML data in the first row of the xe_event column
-- In the xml window which opens, scroll down to demonstrate that it includes a single event
-- Explain that you can use the .value XML method to apply filters and extract individual values
SELECT TOP (10) xa.xe_xml.query('.') AS xe_event,
xa.xe_xml.value('(./data[@name="statement"]/value)[1]', 'nvarchar(MAX)') AS sql_statement,
xa.xe_xml.value('(./data[@name="duration"]/value)[1]', 'bigint')AS duration_ms
FROM	(	SELECT CAST(target_data AS XML) AS xe_data
			FROM sys.dm_xe_session_targets AS st
			JOIN sys.dm_xe_sessions AS  s 
			ON st.event_session_address = s.address
			WHERE s.name = 'xe_stmtcompleted_file'
		) AS xe
CROSS APPLY xe_data.nodes('//event') xa (xe_xml);


--5. In Object Explorer, under MIA-SQL, expand Management, expand Extended Events, expand
--Sessions, expand SqlStatementCompleted, and then double-click package0.ring_buffer.

--6. In the Data column, click the XML value, and note that this is the same data that is returned by the
--query under the comment that begins Step 4 (note that additional statements will have been
--captured because you ran the code earlier).

--7. In Object Explorer, right-click SqlStatementCompleted, and then click Watch Live Data.

--8. In the Demo 1 - create xe sessions.sql query pane, select the code under the comment that begins
--Step 7, and then click Execute to execute some SQL statements.

-- In Object Explorer, right-click the SqlStatementCompleted node then click Watch Live Data.
-- Execute the statements below, then return to the live query results window and wait for the
-- events to appear.

	SELECT 'sample extended events 111' AS v1;
	GO
	SELECT 'sample extended events 222' AS v2;
	GO

-- Demonstrate that events are captured, then return to this window

--9. Return to the MIA-SQL - SqlStatementCompleted: Live Data pane. Wait for the events to be
--captured and displayed; this can take a few seconds. Other SQL statements from background
--processes might be captured by the session.

--10. If the results do not appear, repeat steps 8 and 9.

--11. In the Demo 1 - create xe sessions.sql query pane, select the code under the comment that begins
--Step 8, and then click Execute to stop the session.

ALTER EVENT SESSION SqlStatementCompleted ON SERVER
	STATE=STOP
GO

--12. In Object Explorer, right-click SqlStatementCompleted, and then click Properties.

--13. In the Session Properties dialog box, review the settings on the General, Events, Data Storage and
--Advanced pages, if necessary referring back to the session definition under the comment that begins

--Step 1.
--14. In the Session Properties dialog box, click Cancel.

--15. Select the code under the comment that begins Step 10, and then click Execute to drop the session.

DROP EVENT SESSION SqlStatementCompleted ON SERVER

--16. Keep SQL Server Management Studio open for the next demonstration.


----- Demo 4: Tracking Session-Level Waits -----

--1. In SSMS, in Solution Explorer, double-click Demo 2 - track waits by session.sql.

--2. In Object Explorer, expand Management, expand Extended Events, right-click Sessions, and then
--click New Session.

--3. In the New Session dialog box, on the General page, in the Session name box, type Waits by Session.

--4. On the Events page, in the Event library box, type wait, and then, in the list below, double-click
--wait_info, to add it to the Selected events list.

--5. Click Configure to display the Event configuration options list.

--6. In the Event configuration options list, on the Global Fields (Actions) tab, select session_id.

--7. On the Filter (Predicate) tab, click Click here to add a clause.

--8. In the Field list, click sqlserver.session_id, in the Operator list, click >, and then in the Value box,
--type 50. This filter will exclude most system sessions from the session.

--9. On the Data Storage page, click Click here to add a target.

--10. In the Type list, click event_file, in the File name on server box, type
--D:\Demofiles\Mod12\waitbysession, in the first Maximum file size box, type 5, in the second
--Maximum file size box, click MB, and then click OK.

--11. In Object Explorer, expand Sessions, right-click Waits by Session, and then click Start Session.

--12. In File Explorer, in the D:\Demofiles\Mod12 folder, right-click start_load_1.ps1, and then click Run
--with PowerShell. If a message is displayed asking you to confirm a change in execution policy, type
--Y, and then press Enter. Leave the workload to run for a minute or so before proceeding.

--13. In SSMS, in the Demo 2 - track waits by session.sql pane, select the code under the comment that
--begins Step 14, click Execute, and then review the results.

SELECT * FROM sys.fn_xe_file_target_read_file('D:\DP300\XE\xe_stmtcompleted*.xel', NULL, NULL, NULL)




-- Step 14 - query to aggregate waits by session id
WITH xeCTE
AS
(
	SELECT CAST(event_data AS xml) AS xe_xml
	FROM sys.fn_xe_file_target_read_file('D:\DP300\XE\xe_stmtcompleted*.xel', NULL, NULL, NULL)
)
,valueCTE
AS
(
	SELECT xe_xml.value('(event/action[@name="session_id"]/value)[1]','int') AS sessionID,
	xe_xml.value('(event/action[@name="sql_text"]/value)[1]','nvarchar(max)') AS sql_text,
	xe_xml.value('(event/data[@name="cpu_time"]/value)[1]','int') AS cpu_time,
	xe_xml.value('(event/data[@name="duration"]/value)[1]','int') AS wait_duration,
	xe_xml.value('(event/data[@name="signal_duration"]/value)[1]','int') AS wait_signal_duration
	FROM xeCTE
)
SELECT
sessionID, 
sql_text,
SUM(wait_duration) AS total_wait_duration, 
SUM(wait_signal_duration) AS signal_wait_duration, 
SUM(wait_duration - wait_signal_duration) AS resource_wait_duration
FROM valueCTE
WHERE wait_duration > 0
GROUP BY sessionID, sql_text
ORDER BY sessionID, total_wait_duration DESC;


--14. Select the code under the comment that begins Step 15, and then click Execute to stop and drop the
--session, and to stop the workload.

-- Step 15 - stop and drop the session, stop the workload
ALTER EVENT SESSION [Waits by Session] ON SERVER
	STATE=STOP
GO

DROP EVENT SESSION [Waits by Session] ON SERVER
GO

CREATE TABLE ##stopload (id int)
GO

--15. In File Explorer, in the D:\Demofiles\Mod12 folder, note that one (or more) files with a name
--matching waitbysession*.xel have been created.

--16. Close File Explorer, close SSMS without saving changes, and then in the Windows PowerShell window,
--press Enter to close the window.