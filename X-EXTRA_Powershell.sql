/*------------------------------------------------------------ */
/*                                                             */
/* -----------------   Powershell para Azure  ---------------- */
/*                                                             */
/*------------------------------------------------------------ */


-- Por CLI (Command Line Interface)
$resourceGroup = "DP300CLI"
$location = "eastus"

-- cria resource group novo
New-AzResourceGroup -Name $resourceGroup -Location $location 

-- cria storage account novo
New-AzStorageAccount -ResourceGroupName $resourceGroup -Location $location -Name 'datalakebauerka' -SkuName 'Standard_LRS' -EnableHierarchicalNamespace $True



----- Demo 1: Test Compatibility of a SQL Server Database with Azure -----

CREATE DATABASE TestPS
GO

USE TestPS
GO

CREATE TABLE [dbo].[TestTable] (ID INT, NAME VARCHAR(100))


INSERT  [dbo].[TestTable] VALUES (1,'JOAO'),(2,'MARIA'),(3,'JOSE')


SELECT * FROM [dbo].[TestTable]

--1. Run Setup.cmd in the D:\Demofiles\Mod08 folder as Administrator.

--2. In the User Account Control dialog box, click Yes.

--3. Wait for the script to complete and then press Enter.

--4. Start a command prompt. Type the following command, and then press Enter:

cd C:\Program Files (x86)\Microsoft SQL Server\140\DAC\bin

sqlpackage.exe /help
sqlpackage.exe /?

--5. Type the following command, and then press Enter:

sqlpackage.exe /Action:Export /ssn:localhost /sdn:TestPS /tf:D:\DP-300\TestPS.compatibility.bacpac /p:TableData=dbo.TestTable >D:\DP-300\TestPS_ExportReport.txt 2>&1

--6. Type the following command, and then press Enter:

Notepad D:\DP-300\TestPS_ExportReport.txt

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

Select-AzureRmSubscription -SubscriptionId f8edd306-ba2f-4dcf-8fe5-2012b9eb2957


# 3. Return a list of Azure data centers supporting SQL Database

(Get-AzureRmResourceProvider -ListAvailable | Where-Object {$_.ProviderNamespace -eq 'Microsoft.Sql'}).Locations

# 4. Create a resource group. Replace <location> with one of the 
# locations returned by the previous command

New-AzureRmResourceGroup -Name "DP300" -Location "CentralUS"

# 5. Create a new database server. Replace <location> with the same 
# value as used in the previous step. Replace <your server name>
# with a unique server name
# Use the following credentials when requested:
# User name: psUser 
# Password:  Pa$$w0rd
#
# This step may take several minutes to complete

New-AzureRmSqlServer -ResourceGroupName "DP300" -ServerName "bauerkasqldp300" -Location "eastus" -ServerVersion "12.0"

# 6. Create a firewall rule to allow remote connections to the
# server from your current IP Address. Replace <your server name> with the 
# server name used in the previous command.
# You must set the $CurrentIP variable to your current external IP. You can get this from the Azure
# Portal (see the value returned by the "Add Client IP" button on the firewall for an existing server),
# or from third party services like Google (search Google for "what is my ip") 
# or www.whatismyip.com

$currentIP = "201.42.116.138"
New-AzureRmSqlServerFirewallRule -ResourceGroupName "DP300" -ServerName "bauerkasqldp300" -FirewallRuleName "clientFirewallMBAUER" -StartIpAddress "201.42.116.138" -EndIpAddress "201.42.116.138"

# 7. Create a new database. Replace <your server name> with the 
# server name used in the previous command

New-AzureRmSqlDatabase -ResourceGroupName "DP300" -ServerName "bauerkasqldp300" -DatabaseName "TestPS" -Edition Standard -RequestedServiceObjectiveName "S1"

----- Demo 3: Migrate a SQL Server Database to Azure SQL Database -----

--1. Start a command prompt. Type the following to generate an export BACPAC file for the TestPS
--database:

cd C:\Program Files (x86)\Microsoft SQL Server\140\DAC\bin

 
--2. Verify that the export BACPAC file exists at D:\Demofiles\Mod08\TSQL.export.bacpac.

--3. Type the following command to import the database to Azure SQL Database. Substitute <your server
--name> with the name of the Azure server hosting the target database:

sqlpackage.exe /Action:Import /tsn:bauerkasqldp300.database.windows.net /tdn:TestPS /tu:psUser /tp:Pa$$w0rd /sf:D:\DP-300\TestPS.compatibility.bacpac

OU

sqlpackage.exe /Action:Export /ssn:localhost /sdn:TestPS /tf:D:\DP-300\TestPS.bacpac
sqlpackage.exe /Action:Import /tsn:bauerkasqldp300.database.windows.net /tdn:TestPS /tu:psUser /tp:Pa$$w0rd /sf:D:\DP-300\TestPS.bacpac


--Note: This step may take several minutes to complete.

--4. Verify that the import has completed successfully by connecting to the Azure SQL server <your
--server name. database.windows.net> using SSMS, then expanding the database TestPS and
--showing the tables that now exist.


----- Demo 4 - connecting to an Azure SQL Database -----

--1. switch to the TestPS database

--2. execute the following query
 
USE TestPS
GO

CREATE TABLE TestTable_ondisk (ID INT, NAME VARCHAR(100))
GO

INSERT TestTable_ondisk VALUES (5,'PEDRO'),(6,'ANTONIO')


SELECT ID,NAME FROM TestTable
UNION ALL
SELECT ID,NAME FROM TestTable_ondisk

SELECT db_name() AS dbname, @@servername AS servername, getutcdate() AS datetimeutc

--3. Open Windows PowerShell and type the following command:
SQLCMD -S bauerkasqldp300.database.windows.net -d TestPS -U psUser -Q "SELECT db_name() AS dbname, @@servername AS servername, getutcdate() AS datetimeutc"


SQLCMD -S bauerkasqldp300.database.windows.net -d TestPS -U psUser -P 'Pa$$w0rd' -Q "SELECT ID,NAME FROM TestTable UNION ALL SELECT ID,NAME FROM TestTable_ondisk"

-- enter the password Pa$$w0rd when prompted

--4. Close SSMS, and then close the command prompt.


