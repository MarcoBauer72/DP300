/*------------------------------------------------------------------ */
/*                                                                   */
/* --------------------  Data-Tier Applications -------------------- */
/*                                                                   */
/*------------------------------------------------------------------ */

--1. In SQL Server Management Studio, in Object Explorer, under MIA-SQL, expand Databases, rightclick
--Finance, point to Tasks, and then click Extract Data-tier Application.

--2. In the Extract Data-tier Application dialog box, click Next.

--3. On the Set Properties page, in the Save to DAC package file (include .dacpac extension with the
--file name) box, type D:\Demofiles\Mod15\dacpac\Finance.dacpac, and then click Next.

--4. On the Validation and Summary page, click Next. The extract will begin.

--5. On the Build Package page, when the extraction process is complete, click Finish.

--6. In File Explorer, navigate to D:\Demofiles\Mod15\dacpac to view the exported DACPAC file.

--7. To import the DACPAC, in SSMS, in Object Explorer, under MIA-SQL, right-click Databases, and then
--click Deploy Data-tier Application.

--8. In the Deploy Data-tier Application window, click Next.

--9. On the Select Package page, in the DAC package (file name with the .dacpac extension) box,
--type D:\Demofiles\Mod15\dacpac\Finance.dacpac, and then click Next.

--10. On the Update Configuration page, in the Name (the name of the deployed DAC and database)
--box, type FinanceDAC, and then click Next.

--11. On the Summary page click Next. The deployment will run.

--12. On the Deploy DAC page, when the deployment is complete, click Finish.

--13. In Object Explorer, right-click Databases, and then click Refresh. Verify that the FinanceDAC
--database exists.

--14. Expand FinanceDAC, expand Tables, right-click dbo.Currency, and then click Select Top 1000
--Rows to verify that the table has been created with no data.


-------------------- Curso 20-765 - Modulo 3 --------------------

--Demo 1: Preparing for an Upgrade with Data Migration Assistant

--1. Ensure that the 20765C-MIA-DC-UPGRADE and 20765C-MIA-SQL-UPGRADE virtual machines are
--running and log on to 20765C-MIA-SQL-UPGRADE as ADVENTUREWORKS\Student with the
--password Pa55w.rd.

--2. Run Setup.cmd in the D:\Demofiles\Mod03 folder as Administrator.

--3. When the script has completed, press any key to close the window.

--4. Navigate to https://www.microsoft.com/en-us/download/details.aspx?id=42642.

--5. In the Microsoft .NET Framework 4.5.2 (Offline Installer) page, ensure that English is selected,
--then click Download.

--6. In Internet Explorer, click Save.

--7. When the download has completed, click Run.

--8. In the User Account Control window, click Yes.

--9. Check I have read and accept the license terms, then click Install.

--10. When prompted, restart the 20765-MIA-SQL-UPGRADE computer and log on again as
--ADVENTUREWORKS\Student with a password of Pa55w.rd.

--11. Download Data Migration Assistant from https://www.microsoft.com/enus/download/confirmation.aspx?id=53595.

--12. In Internet Explorer, click Save.

--13. When the file has downloaded, click Run.

--14. In the Microsoft Data Migration Assistant Setup window, click Next.

--15. Select the I accept the terms in the License Agreement check box, and then click Next.

--16. Select the I agree to the Privacy Policy check box, and then click Install.

--17. In the User Account Control dialog box, click Yes, and then click Finish.

--18. On the Start screen, type Microsoft Data Migration Assistant, and then click Microsoft Data

--Migration Assistant.
--19. In the Data Migration Assistant, on the left-hand side, click the + sign.

--20. Under New, click Assessment.

--21. In the Project Name Field, enter 2014 Migration.

--22. Ensure that Source server type and Target server type are both set to SQL Server.

--23. Click Create.

--24. In the Options pane, ensure that Select target version is set to SQL Server 2017 on Windows, and
--that Compatibility Issues is selected, then click Next.

--25. In the SERVER NAME box, type MIA-SQL, check that Authentication type is set to Windows
--Authentication.

--26. Check the Trust server certificate box and then click Connect.

--27. In the Select sources pane, under the list of databases, check TSQL and MDS, and click Add.

--28. Click Start Assessment.

--29. When analysis is complete, in the left-hand pane under MIA-SQL (SQL Server 2014), click TSQL.

--30. In the Compatibility 140 (1) blade, under Behavior changes (1), click SET ROWCOUNT used in

--the context of DML statements such as INSERT, UPDATE, or DELETE.

--31. Show the students the output from this check and the implications when using SET ROWCOUNT statements.

--32. Close the Data Migration Assistant.

--33. In the Data Migration Assistant dialog box, click Yes.


--Demo 2: Carry Out an In-Place Upgrade
--1. Ensure that the 20765C-MIA-DC-UPGRADE and 20765C-MIA-SQL-UPGRADE virtual machines are
--running, and log on to 20765C-MIA-SQL-UPGRADE as ADVENTUREWORKS\Student with the
--password Pa55w.rd.

--2. In File Manager, double-click X:\setup.exe.

--3. In the User Account Control dialog box, click Yes.

--4. In SQL Server Installation Center, click Installation, and then click Upgrade from a previous version
--of SQL Server.

--5. On the Product Key page, click Next.

--6. On the License Terms page, select I accept the license terms, and then click Next.

--7. On the Product Updates page, click Next. Any error relating to a failure to search for updates
--through Windows Update can be ignored.

--8. On the Select Instance page, set the value of the Instance to upgrade box to MSSQLSERVER, and
--then click Next.

--9. On the Reporting Services Migration page, check Uninstall Reporting Services, then click Next.

--10. On the Select Features page, click Next.

--11. On the Instance Configuration page, click Next.

--12. On the Server Configuration page, click Next.

--13. On the Full-text Upgrade page, click Next.

--14. The demonstration stops at this point because you cannot complete the upgrade with an Evaluation
--version of SQL Server.

--15. On the Feature Rules page, click Cancel, and then click Yes to Cancel the installation.

--16. Close the SQL Server Installation Center.


--Demo 3: Scripting SQL Server Logins
--1. Ensure that the 20765C-MIA-DC-UPGRADE and 20765C-MIA-SQL-UPGRADE virtual machines are
--running, and log on to 20765C-MIA-SQL-UPGRADE as ADVENTUREWORKS\Student with the
--password Pa55w.rd.

--2. On the taskbar, click the SQL Server Management Studio shortcut.

--3. In the Connect to Server dialog box, click Connect.

--4. On the File menu, point to Open, and then click File.

--5. In the Open File dialog box, navigate to D:\Demofiles\Mod03, click Demonstration - Login and
--User.sql, and then click Open.

--6. Select the code under the comment Demonstration - Login and User, and then click Execute.

USE master;
GO

-- Step 1 - create the logins DemoLogin1 and DemoLogin2
CREATE LOGIN DemoLogin1 WITH PASSWORD = 'Pa$$w0rd';
CREATE LOGIN DemoLogin2 WITH PASSWORD = 'Pa$$w0rd';

-- Step 2 - examine DemoLogin1 and DemoLogin2 in sys.sql_logins
-- note the sid values, and that even though the users have the same password, it has a different password_hash value
SELECT * FROM sys.sql_logins WHERE name IN ('DemoLogin1','DemoLogin2');

-- Step 3 - add users to the TSQL database for these logins
USE TSQL;
GO
CREATE USER DemoUser1 FOR LOGIN DemoLogin1;
CREATE USER DemoUser2 FOR LOGIN DemoLogin2;

-- Step 4 - examine the users in sys.database_principals
-- note that the sid matches the values in sys.server_principals
SELECT * FROM TSQL.sys.database_principals WHERE name IN ('DemoUser1','DemoUser2');

-- Step 5 - script DemoLogin1 using SSMS
-- 1. In Object Explorer, then expand Security. Expand Logins.
-- 2. Right-click DemoUser1 and select Script Login as... > CREATE to > New Query Editor window
--    (if DemoLogin1 is not visible, right-click the Logins node and click Refresh)
-- 3. Examine the generated script. Note that the password is not correct

-- Step 6 - generate a script for DemoLogin1 and DemoLogin2 including SID and password hash
--          note that this script uses CONCAT and so is compatibile with SQL 2014 and later

SELECT	CONCAT('CREATE LOGIN [', name, '] WITH PASSWORD=', CONVERT(varchar(256),password_hash,1), ' HASHED,SID=',CONVERT(varchar(85),sid,1),';')
FROM	sys.sql_logins
WHERE	name IN ('DemoLogin1','DemoLogin2');

--7. In Object Explorer, expand Security, and then expand Logins.

--8. Right-click DemoLogin1, point to Script Login as, point to CREATE To, and then click New Query
--Editor Window. If DemoLogin1 is not visible, right-click the Logins node and click Refresh.

--9. Examine the generated script. Note that the password is not correct, and then close the tab.

--10. Select the code under the comment Step 6, and then click Execute.

--11. Close SQL Server Management Studio without saving changes.


-------------------- Curso 20-765 - Modulo 8 --------------------


----- Demo 1: Test Compatibility of a SQL Server Database with Azure -----

--1. Run Setup.cmd in the D:\Demofiles\Mod08 folder as Administrator.

--2. In the User Account Control dialog box, click Yes.

--3. Wait for the script to complete and then press Enter.

--4. Start a command prompt. Type the following command, and then press Enter:

cd C:\Program Files (x86)\Microsoft SQL Server\140\DAC\bin

--5. Type the following command, and then press Enter:

sqlpackage.exe /Action:Export /ssn:MIA-SQL /sdn:TestPSDB /tf:D:\Demofiles\Mod08\TSQL.compatibility.bacpac /p:TableData=Stats.Tests >D:\Demofiles\Mod08\ExportReport.txt 2>&1

--6. Type the following command, and then press Enter:

Notepad D:\Demofiles\Mod08\ExportReport.txt

--7. Examine the contents of the text file, and then close Notepad.

--8. Close the command prompt.

----- Demo 2:
# Demonstration: Creating an Azure SQL Database from PowerShell

# 1. Link Azure account to PowerShell
# At the sign-in screen, use your Azure credentials
Add-AzureRmAccount
# (If your Azure credentials are already linked to PowerShell on this VM, use Login-AzureRMAccount)

# 2. Use the subscription Id returned by the previous command to
# confirm the subscription you want to work with
Select-AzureRmSubscription -SubscriptionId 52b56929-ee84-495c-91c3-a84dfacbc9d2

# 3. Return a list of Azure data centers supporting SQL Database
(Get-AzureRmResourceProvider -ListAvailable | Where-Object {$_.ProviderNamespace -eq 'Microsoft.Sql'}).Locations

# 4. Create a resource group. Replace <location> with one of the 
# locations returned by the previous command
New-AzureRmResourceGroup -Name "20765novo" -Location "CentralUS"

# 5. Create a new database server. Replace <location> with the same 
# value as used in the previous step. Replace <your server name>
# with a unique server name
# Use the following credentials when requested:
# User name: psUser 
# Password:  Pa$$w0rd
#
# This step may take several minutes to complete
New-AzureRmSqlServer -ResourceGroupName "20765novo" -ServerName "bauergreensqlnovo" -Location "CentralUS" -ServerVersion "12.0"

# 6. Create a firewall rule to allow remote connections to the
# server from your current IP Address. Replace <your server name> with the 
# server name used in the previous command.
# You must set the $CurrentIP variable to your current external IP. You can get this from the Azure
# Portal (see the value returned by the "Add Client IP" button on the firewall for an existing server),
# or from third party services like Google (search Google for "what is my ip") 
# or www.whatismyip.com
$currentIP = "177.103.205.186"
New-AzureRmSqlServerFirewallRule -ResourceGroupName "20765novo" -ServerName "bauergreensqlnovo" -FirewallRuleName "clientFirewallRule1" -StartIpAddress 177.103.205.186 -EndIpAddress 177.103.205.186

# 7. Create a new database. Replace <your server name> with the 
# server name used in the previous command
New-AzureRmSqlDatabase -ResourceGroupName "20765novo" -ServerName "bauergreensqlnovo" -DatabaseName "TestPSDB" -Edition Standard -RequestedServiceObjectiveName "S1"

----- Demo 3: Migrate a SQL Server Database to Azure SQL Database -----

--1. Start a command prompt. Type the following to generate an export BACPAC file for the TestPSDB
--database:

cd C:\Program Files (x86)\Microsoft SQL Server\140\DAC\bin

sqlpackage.exe /Action:Export /ssn:MIA-SQL /sdn:TestPSDB /tf:D:\Demofiles\Mod08\TSQL.export.bacpac

--2. Verify that the export BACPAC file exists at D:\Demofiles\Mod08\TSQL.export.bacpac.

--3. Type the following command to import the database to Azure SQL Database. Substitute <your server
--name> with the name of the Azure server hosting the target database:

sqlpackage.exe /Action:Import /tsn:<bauergreensqlserver.database.windows.net> /tdn:TestPSDB /tu:psUser /tp:Pa$$w0rd /sf:D:\Demofiles\Mod08\TSQL.export.bacpac

--Note: This step may take several minutes to complete.

--4. Verify that the import has completed successfully by connecting to the Azure SQL server <your
--server name. database.windows.net> using SSMS, then expanding the database TestPSDB and
--showing the tables that now exist.


----- Demo 4 - connecting to an Azure SQL Database -----

--1. switch to the TestPSDB database

--2. execute the following query
SELECT db_name() AS dbname, @@servername AS servername, getutcdate() AS datetimeutc

--3. Open Windows PowerShell and type the following command:
SQLCMD -S <your server name>.database.windows.net -d TestPSDB -U psUser -Q "SELECT db_name() AS dbname, @@servername AS servername, getutcdate() AS datetimeutc"
-- enter the password Pa$$w0rd when prompted

--4. Close SSMS, and then close the command prompt.