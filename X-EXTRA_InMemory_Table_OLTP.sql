/*-------------------------------------------------------------------- */
/*                                                                     */
/* -------------------  EXTRA - InMemory Table/OLTP  ----------------- */
/*                                                                     */
/*-------------------------------------------------------------------- */

--	NOTA: Necessario baixar e restaurar o banco de dados Adventureworks2016CTP3:
	https://www.microsoft.com/en-us/download/details.aspx?id=49502

1. In-Memory OLTP 
-	Introduzido a partir do SQL 2014

-	Melhorias no SQL 2016:

    Simplified analysis to help with app migration;
	
	Reduced complexity of app migration through increased Transact-SQL language 
	support (e.g., foreign key, triggers, procedures); 

	Previously you could have, at most, 256 gigas of data per database, 
	in SQL 2016 up to 2TB per database.

	Suporta Alter Table

	Suporta Planos de paralelos

	Suporta TDE (Transparent Data Encryption)

	Migração de objetos para gerenciamento pela memória com par de clicks.
	Agora no SQL2016 disponível no Azure SQL DB.

-	1.2 million transactions per second for session state
-	900 MB/s of data written to the database for order processing workload (throughput)

O que é:
-	Performance optimization using memory-optimized technology
-	High scalability, through lock-free architecture
-	Low Latency through efficient data access and native compilation

Por que utilizar:
-	Large memory sizes
-	Many core processors 
-	Explosion in data being generated. Diversas fontes na internet.
-	Operations need to be instant (low latency)
-	Many different types of applications, database systems

Benefícios / Características:
-	Até 30x mais rápido no processamento de transações
-	Fully durable – data survives server failures (usa Transaction Log)
-	Fully integrated in SQL Server
-	Data can live in memory and part of your data live on disk
-	Eliminate TempDB contention
-	Lower latency data retrieval
-	Optional IO reduction or removal, when using non-durable tables
-	Os códigos de tabelas e SP são convertidos para linguagem C e compilados em um DLL e
	carregados em memória
-	Reduce logging


Referencias:
https://msdn.microsoft.com/library/dn133186.aspx
https://blogs.technet.microsoft.com/dataplatforminsider/2015/12/10/speeding-up-transactions-with-in-memory-oltp-in-sql-server-2016-and-azure-sql-database/

Videos:
https://www.youtube.com/watch?v=l5l5eophmK4
https://www.youtube.com/watch?v=CikrAKCXFWw


Demo 0:  Botao da direito nos databases (AdventureWorks2016 e AdventureworksDW2016)
	    -> Reports -> Standard Reports -> Transaction Performance Analysis Overview (Table Analysis)
		• Potenciais ganhos, descobrir canditados a utilizar In-Memory OLTP

Demo 1: Botao da direta do mouse em cima de uma tabela (AdventureworksDW2016.ProspectiveBuyer) 
		e Memory Optimization Advisor (mover tabela para InMemory)

Escolher uma tabela -> botão direito do mouse -> Memory Optimization Advisor
•	Facilita mover a tabela para In-Memory
•	Check-box :  Also copy table data to the new memory optimized table
•	Opcionalmente mudar os índices se desejável

-- Estimar Bucket Counts
* Bucket count deve ser algum valor entre 1 a 2 vezes o número de valores distintos na
  chave indexada.
  
SELECT * FROM sys.dm_db_xtp_hash_index_stats

----------------------------------------------

USE [AdventureworksDW2017]
GO

[dbo].[ProspectiveBuyer_old]
[dbo].[ProspectiveBuyer_old]


-- INSERCOES NA TABELA EM DISCO
TRUNCATE TABLE [dbo].[ProspectiveBuyer_OLD]
delete [dbo].[ProspectiveBuyer]


 TRUNCATE TABLE  [dbo].[ProspectiveBuyer] -- The statement 'TRUNCATE TABLE' is not supported with memory optimized tables.


select count(1) from  [dbo].[ProspectiveBuyer_old];
select count(1) from [dbo].[ProspectiveBuyer]


DECLARE @I INT = 1 --(>SQL2005)

WHILE @I <= 200000
BEGIN
INSERT INTO [dbo].[ProspectiveBuyer]  -- 39''  38''
           ([ProspectAlternateKey]
           ,[FirstName]
           ,[MiddleName]
		   )
     VALUES (@I,'NADA','NOMEMEIO')
		   
SET @I = @I + 1  -- @I +=1
END
GO

SELECT COUNT(1) FROM [dbo].[ProspectiveBuyer_old] -- Elapsed time : 27 sec
SELECT COUNT(1) FROM [dbo].[ProspectiveBuyer]  -- Elapsed time :  29 sec


-- INSERCOES NA TABELA EM MEMORIA
DELETE [dbo].[ProspectiveBuyer]


DECLARE @I INT = 1

WHILE @I <= 200000
BEGIN

INSERT INTO [dbo].[ProspectiveBuyer]
           ([ProspectAlternateKey]
           ,[FirstName]
           ,[MiddleName]
		   )
     VALUES (@I,'NADA','NOMEMEIO')
		   
SET @I+=1
END
GO

SELECT COUNT(1) FROM [dbo].[ProspectiveBuyer] -- Elapsed time : xx sec


-- !!! Remover propriedade da conexao ->  column encryption setting=enabled
CREATE OR ALTER PROC ins_ProspectiveBuyer
WITH NATIVE_COMPILATION, SCHEMABINDING
AS
BEGIN ATOMIC WITH
  (TRANSACTION ISOLATION LEVEL = SNAPSHOT,
   LANGUAGE = N'us_english')

   DECLARE @I INT = 1

	WHILE @I <= 200000
	BEGIN

	INSERT INTO [dbo].[ProspectiveBuyer]
			   ([ProspectAlternateKey]
			   ,[FirstName]
			   ,[MiddleName]
			   )
		 VALUES (@I,'NADA','NOMEMEIO')
		   
	SET @I= @I + 1
	END
END

DELETE [dbo].[ProspectiveBuyer]

EXEC ins_ProspectiveBuyer

SELECT COUNT(1) FROM [dbo].[ProspectiveBuyer]


/*----------------------------------------------------------------- */
/*                                                                  */
/* ---------------------  01 - InMemory OLTP  --------------------- */
/*                                                                  */
/*----------------------------------------------------------------- */


SET STATISTICS IO ON
GO
------ Demo 2 ------
USE [AdventureWorks2016]
GO

SELECT name, object_id, type, type_desc, is_memory_optimized, durability, durability_desc
FROM sys.tables
WHERE is_memory_optimized=1

TRUNCATE TABLE [Sales].[SalesOrderDetail_old]
DELETE [Sales].[SalesOrderHeader_old] 

----- Disk-based Inserts -----
DECLARE 
      @i int = 0, 
      @od Sales.SalesOrderDetailType_old, 
      @SalesOrderID int, 
      @DueDate datetime2 = dateadd(month,1,sysdatetime()), 
      @CustomerID int = rand() * 8000, 
      @BillToAddressID int = rand() * 10000, 
      @ShipToAddressID int = rand() * 10000, 
      @ShipMethodID int = (rand() * 5) + 1; 

INSERT INTO @od 
SELECT OrderQty, ProductID, SpecialOfferID 
FROM Demo.DemoSalesOrderDetailSeed 
WHERE OrderID= cast((rand()*106) + 1 as int); 

WHILE (@i < 20000) 
BEGIN; 
      EXEC Sales.usp_InsertSalesOrder_old @SalesOrderID OUTPUT, @DueDate, @CustomerID, @BillToAddressID, @ShipToAddressID, @ShipMethodID, @od; 
      SET @i += 1 
END

SELECT COUNT(*) FROM [Sales].[SalesOrderHeader_old] (nolock) 
SELECT COUNT(*) FROM [Sales].[SalesOrderDetail_old] (nolock) 

SP_HELPTEXT 'Sales.usp_InsertSalesOrder_old'


----- Memory-optimized Inserts -----

SP_HELPTEXT 'Sales.usp_InsertSalesOrder_inmem'

DELETE [Sales].[SalesOrderDetail_inmem] 
DELETE [Sales].[SalesOrderHeader_inmem]

SELECT COUNT(*) FROM [Sales].[SalesOrderHeader_inmem] (nolock) 
SELECT COUNT(*) FROM [Sales].[SalesOrderDetail_inmem] (nolock)


DECLARE 
      @i int = 0, 
      @od Sales.SalesOrderDetailType_inmem, 
      @SalesOrderID int, 
      @DueDate datetime2 = dateadd(month,1,sysdatetime()), 
      @CustomerID int = rand() * 8000, 
      @BillToAddressID int = rand() * 10000, 
      @ShipToAddressID int = rand() * 10000, 
      @ShipMethodID int = (rand() * 5) + 1; 

INSERT INTO @od 
SELECT OrderQty, ProductID, SpecialOfferID 
FROM Demo.DemoSalesOrderDetailSeed 
WHERE OrderID= cast((rand()*106) + 1 as int); 

WHILE (@i < 20000) 
BEGIN; 
      EXEC Sales.usp_InsertSalesOrder_inmem @SalesOrderID OUTPUT, @DueDate, @CustomerID, @BillToAddressID, @ShipToAddressID, @ShipMethodID, @od; 
      SET @i += 1 
END


SELECT COUNT(*) FROM [Sales].[SalesOrderHeader_inmem] (nolock) 
SELECT COUNT(*) FROM [Sales].[SalesOrderDetail_inmem] (nolock)


SP_HELPTEXT 'Sales.usp_InsertSalesOrder_inmem'


-- Lista tabelas InMemory
SELECT name, object_id, type, type_desc, is_memory_optimized, durability, durability_desc
FROM sys.tables
WHERE is_memory_optimized=1


-------------------------------------------------------------------------------------------------------
--Inspect memory-optimized tables through object explorer in SQL Server management studio, or through catalog view queries. 
--Example:
    SELECT name, object_id, type, type_desc, is_memory_optimized, durability, durability_desc
    FROM sys.tables
    WHERE is_memory_optimized=1


-- The natively compiled modules can be inspected through object explorer or queries of the catalog views. The sample contains three kinds of natively compiled modules:
-- •A Stored Procedure
-- •Scalar User-Defined Functions
-- •Inline Table-Valued Functions
-- Example:
SELECT object_name(object_id), object_id, definition, uses_native_compilation 
FROM sys.sql_modules
WHERE uses_native_compilation=1