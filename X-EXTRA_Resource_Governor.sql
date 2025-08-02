--------------------- Resource Governor ----------------------

--What is Resource Governor?

--Resource Governor is a feature which can manage SQL Server Workload and System Resource Consumption. We can limit the amount of CPU and memory consumption by limiting /governing /throttling on the SQL Server.

--Why is resource governor required?

--If there are different workloads running on SQL Server and each of the workload needs different resources or when workloads are competing for resources with each other and affecting the performance of the whole server resource governor is a very important task.

--What will be the real world example of need of resource governor?

--Here are two simple scenarios where the resource governor can be very useful.

--Scenario 1: A server which is running OLTP workload and various resource intensive reports on the same server.
--The ideal situation is where there are two servers which are data synced with each other and one server 
--runs OLTP transactions and the second server runs all the resource intensive reports. 
--However, not everybody has the luxury to set up this kind of environment. 
--In case of the situation where reports and OLTP transactions are running on the same server, 
--limiting the resources to the reporting workload it can be ensured that OTLP’s critical transaction 
--is not throttled.

--Scenario 2: There are two DBAs in one organization. One DBA A runs critical queries for business and 
--another DBA B is doing maintenance of the database. At any point in time the DBA A’s work should not be 
--affected but at the same time DBA B should be allowed to work as well. The ideal situation is that 
--when DBA B starts working he get some resources but he can’t get more than defined resources.


--SQL Server has two by default created resource governor component.

--1) Internal –This is used by database engine exclusives and user have no control.

--2) Default – This is used by all the workloads which are not assigned to any other group.

--What are the major components of the resource governor?
--•Resource Pools
--•Workload Groups
--•Classification

--In simple words here is what the process of resource governor is:
--•Create resource pool
--•Create a workload group
--•Create classification function based on the criteria specified
--•Enable Resource Governor with classification function


--Step 0: Here we are assuming that there are separate login accounts for Reporting server and OLTP server.

/*-----------------------------------------------
Step 0: (Optional and for Demo Purpose)
Create Two User Logins
1) ReportUser, 2) PrimaryUser
Use ReportUser login for Reports workload
Use PrimaryUser login for OLTP workload
-----------------------------------------------*/
 

--Step 1: Creating Resource Pool

--We are creating two resource pools. 1) Report Server and 2) Primary OLTP Server. 
--We are giving only a few resources to the Report Server Pool as described in the scenario 1 the other 
--server is mission critical and not the report server.

-----------------------------------------------
-- Step 1: Create Resource Pool
-----------------------------------------------
-- Creating Resource Pool for Report Server
CREATE RESOURCE POOL ReportServerPool
WITH
( MIN_CPU_PERCENT=0,
MAX_CPU_PERCENT=30,
MIN_MEMORY_PERCENT=0,
MAX_MEMORY_PERCENT=30)
GO
-- Creating Resource Pool for OLTP Primary Server
CREATE RESOURCE POOL PrimaryServerPool
WITH
( MIN_CPU_PERCENT=50,
MAX_CPU_PERCENT=100,
MIN_MEMORY_PERCENT=50,
MAX_MEMORY_PERCENT=100)
GO


--Step 2: Creating Workload Group

--We are creating two workloads each mapping to each of the resource pool which we have just created.

-----------------------------------------------
-- Step 2: Create Workload Group
-----------------------------------------------
-- Creating Workload Group for Report Server
CREATE WORKLOAD GROUP ReportServerGroup
USING ReportServerPool ;
GO
-- Creating Workload Group for OLTP Primary Server
CREATE WORKLOAD GROUP PrimaryServerGroup
USING PrimaryServerPool ;
GO


-- Step 3: Creating user defined function which routes the workload to the appropriate workload group.

--In this example we are checking SUSER_NAME() and making the decision of Workgroup selection. 
--We can use other functions such as HOST_NAME(), APP_NAME(), IS_MEMBER() etc.

-----------------------------------------------
-- Step 3: Create UDF to Route Workload Group
-----------------------------------------------
CREATE FUNCTION dbo.UDFClassifier()
RETURNS SYSNAME
WITH SCHEMABINDING
AS
BEGIN
DECLARE @WorkloadGroup AS SYSNAME
IF(SUSER_NAME() = 'ReportUser')
SET @WorkloadGroup = 'ReportServerGroup'
ELSE IF (SUSER_NAME() = 'PrimaryUser')
SET @WorkloadGroup = 'PrimaryServerGroup'
ELSE
SET @WorkloadGroup = 'default'
RETURN @WorkloadGroup
END
GO


-- Step 4: In this final step we enable the resource governor with the classifier 
-- function created in earlier step 3.
-----------------------------------------------
-- Step 4: Enable Resource Governer
-- with UDFClassifier
-----------------------------------------------
ALTER RESOURCE GOVERNOR
WITH (CLASSIFIER_FUNCTION=dbo.UDFClassifier);
GO
ALTER RESOURCE GOVERNOR RECONFIGURE
GO


--Step 5: If you are following this demo and want to clean up your example, you should run following script. 
--Running them will disable your resource governor as well delete all the objects created so far.

-----------------------------------------------
-- Step 5: Clean Up
-- Run only if you want to clean up everything
-----------------------------------------------
ALTER RESOURCE GOVERNOR WITH (CLASSIFIER_FUNCTION = NULL)
GO
ALTER RESOURCE GOVERNOR DISABLE
GO
DROP FUNCTION dbo.UDFClassifier
GO
DROP WORKLOAD GROUP ReportServerGroup
GO
DROP WORKLOAD GROUP PrimaryServerGroup
GO
DROP RESOURCE POOL ReportServerPool
GO
DROP RESOURCE POOL PrimaryServerPool
GO
ALTER RESOURCE GOVERNOR RECONFIGURE
GO


--Referencias:
https://docs.microsoft.com/pt-br/sql/relational-databases/resource-governor/resource-governor


