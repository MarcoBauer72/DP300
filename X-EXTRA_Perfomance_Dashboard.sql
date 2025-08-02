--------------------- Performance Dashboard ----------------------

-- SQL Server Performance Dashboard Reports are custom reports made to make performance 
-- monitoring easier. Keep in mind that these are ready to use reports and 
-- SQL Server Reporting Services don’t have to be installed on the SQL Server where you will 
-- use them. Similar to standard reports, these reports help with identifying CPU usage, 
-- IO activity, blocks, bottlenecks, missing indexes, etc. As the values for the reports are
-- mostly obtained from dynamic management views, such as sys.dm_os_performance_counters, 
-- sys. dm_os_memory_clerks, sys.dm_exec_requests, etc. no overhead is added to monitor 
-- the performance. To be able to query these views, the SQL Server login must have the 
-- VIEW SERVER STATE server permission. 
-- See more at:
-- http://www.sqlshack.com/performance-dashboard-reports-sql-server-2014/#sthash.yj903fBK.dpuf


-- 1: Rodar o instalador -> SQLServer_PerformanceDashboard.msi


-- 2: Executar no SSMS o arquivo SETUP.SQL provavelmente localizado em:
--    C:\Program Files (x86)\Microsoft SQL Server\110\Tools\Performance Dashboard\setup.sql


-- 3: Clicar com botão da direita do mouse na instancia pelo SSMS e Reports -> CUSTOM REPORTS


-- 4: Apontar para C:\Program Files (x86)\Microsoft SQL Server\110\Tools\Performance Dashboard


-- 5: Selecionar apenas o relatorio principal: performance_dashboard_main.rdl


----------------------------- FIM ------------------------------
