----- Linked Server -----

# User name: psUser 
# Password:  Pa$$w0rd

--- Create a linked server to an Azure SQL database using Transact-SQL

EXEC master.dbo.sp_addlinkedserver
@server = N'AZUREDB', 
@srvproduct=N'',
  @provider=N'SQLNCLI',
   @datasrc=N'bauerkasqldp300.database.windows.net',
    @catalog=N'TestPS'
/* For security reasons, the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin
@rmtsrvname=N'AZUREDB',
@useself=N'False',
@locallogin=NULL,
@rmtuser=N'psUser',@rmtpassword='Pa$$w0rd'
GO
 

EXEC master.dbo.sp_serveroption @server=N'AZUREDB', @optname=N'rpc', @optvalue=N'true'
GO
EXEC master.dbo.sp_serveroption @server=N'AZUREDB', @optname=N'rpc out', @optvalue=N'true'
GO


SELECT * FROM OPENQUERY([AZUREDB],'SELECT * FROM dbo.TestTable')

SELECT * FROM [AZUREDB].[TestPS].dbo.TestTable
 
---- Connecting to Azure SQL database and querying data using the distributed queries -----

To connect to Azure SQL database and access data without creating a linked server first, use the T-SQL OPENROWSET or OPENDATASOURCE functions.


To open a connection and querying data from the Azure SQL database using the OPENROWSET function, type the following code in a query editor:
	 
SELECT * FROM OPENROWSET('SQLNCLI', 'Server=bauerkasqldp300.database.windows.net;Database=TestPS;UID=psUser;PWD=Pa$$w0rd;', 'SELECT * FROM dbo.TestTable')
	 
-- If, for some reasons, the above code does not work, use the code below to connect and query data from Azure SQL database:

SELECT * FROM  OPENROWSET('MSDASQL', 'Driver={SQL SERVER}; Server=server.database.windows.net;Database=TestDatabase;UID=zivko; PWD=######;', 'SELECT * FROM SalesLT.CustomerAddress')

-- Another way of connecting and querying data from the Azure SQL database is by using the OPENDATASOURCE function.
-- In a query editor, paste and execute one of the following codes:
	 
SELECT *  
FROM OPENDATASOURCE('MSDASQL','Driver=SQLNCLI;Server=bauerkasqldp300.database.windows.net;Database=TestPS;UID=psUser;PWD=Pa$$w0rd;').TestTable.SalesLT.CustomerAddress
 
 
 
SELECT * FROM OPENDATASOURCE('SQLNCLI', 'Server=server.database.windows.net;Database=TestDatabase;UID=zivko;PWD==######;').TestDatabase.SalesLT.CustomerAddress
 
--- Common error that may occur when using the T-SQL OPENROWSET and OPENDATASOURCE functions:
--- Msg 15281, Level 16, State 1, Line 1


-- To resolve this the Ad Hoc Distributed Queries option should be enabled. To enable the Ad Hoc Distributed Queries option, use the sp_configure procedure and in a query editor, paste and execute the following code:
	 
EXEC sp_configure 'show advanced options', 1
RECONFIGURE
GO
EXEC sp_configure 'ad hoc distributed queries', 1
RECONFIGURE
GO


