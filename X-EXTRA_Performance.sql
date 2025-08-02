----- Improving Query Performance
----- Modulo 19: Improving Query Performance
USE Adventureworks
GO

------------------------------- SET STATISTICS TIME ----------------------------

-- Exibe o número de milissegundos necessários para analisar, 
-- compilar e executar cada instrução. 

--SET STATISTICS TIME ON;
--GO

--------------------------------------------------------------------------------


-------------------------------- SET STATISTICS IO -----------------------------

-- Faz o SQL Server exibir informações referentes à quantidade de atividade
-- em disco gerada pelas instruções Transact-SQL.

--SET STATISTICS IO ON;
--GO

--------------------------------------------------------------------------------


-------------------------------- SET SHOWPLAN_TEXT -----------------------------

-- Faz com que o Microsoft SQL Server não execute as instruções Transact-SQL.  
-- Em lugar disso, o SQL Server retorna informações detalhadas sobre como 
-- as instruções são executadas. 

-- SET SHOWPLAN_TEXT ON;
-- GO

--------------------------------------------------------------------------------


-------------------------------- SET SHOWPLAN_XML -------------------------------

-- Faz com que o SQL Server não execute instruções Transact-SQL.  
-- Em vez disso, o SQL Server retorna informações detalhadas sobre como
-- as instruções serão executadas no formulário de um documento XML bem definido. 

-- SET SHOWPLAN_XML ON;
-- GO

--------------------------------------------------------------------------------
SET STATISTICS IO ON;
GO

SELECT 
 [BusinessEntityID]
FROM Person.Person
WHERE BusinessEntityID
NOT IN
	( SELECT DISTINCT(BusinessEntityID) FROM [HumanResources].[Employee] )

--SELECT
--PES.[BusinessEntityID]
-- FROM Person.Person AS PES
--LEFT JOIN [HumanResources].[Employee]  AS EMP
--ON PES.BusinessEntityID = EMP.BusinessEntityID
--WHERE EMP.BusinessEntityID IS NULL

SELECT
PES.[BusinessEntityID]
 FROM Person.Person AS PES
EXCEPT
SELECT EMP.BusinessEntityID
 FROM  [HumanResources].[Employee] EMP

SET STATISTICS IO OFF;
GO



--SET STATISTICS IO OFF;
--GO


SET STATISTICS TIME OFF;
GO

IF OBJECT_ID('SEMINDICE') IS NOT NULL
DROP TABLE SEMINDICE 

IF OBJECT_ID('COMINDICE') IS NOT NULL
DROP TABLE COMINDICE 



CREATE TABLE SEMINDICE -- TABELA HEAP = SEM INDICE
(
	ID   INT IDENTITY
	,NOME VARCHAR(100)
)

CREATE TABLE COMINDICE -- TABELA HEAP = SEM INDICE
(
	ID   INT IDENTITY
	,NOME VARCHAR(100)
)
SP_SPACEUSED 'PERSON.Person'
INSERT INTO SEMINDICE
SELECT FirstName
FROM PERSON.Person

INSERT INTO COMINDICE
SELECT FirstName
FROM PERSON.Person


SET STATISTICS IO ON;
GO

SELECT * from SEMINDICE
WHERE ID = 10

SELECT * from COMINDICE
WHERE ID = 10

SET STATISTICS IO OFF;
GO

SP_SPACEUSED 'COMINDICE'



CREATE TABLE COMINDICE
(
	ID   INT IDENTITY
	,NOME VARCHAR(100)
)

INSERT INTO COMINDICE
SELECT FirstName
FROM PERSON.Person


CREATE CLUSTERED INDEX IX_ID
    ON COMINDICE (ID)
	
	
SET STATISTICS IO ON;
GO

SELECT * from SEMINDICE
WHERE ID = 10


SELECT * from COMINDICE
WHERE ID = 10

SET STATISTICS IO OFF;
GO


SP_SPACEUSED SEMINDICE

SET STATISTICS IO ON;
GO

SELECT * from SEMINDICE
WHERE NOME LIKE 'A%'


SELECT * from COMINDICE 
WHERE NOME LIKE 'A%' 


SET STATISTICS IO OFF;
GO

SP_SPACEUSED COMINDICE

CREATE NONCLUSTERED INDEX IX_NOME
    ON COMINDICE (NOME)
	


-- SET STATISTICS TIME ON;
SET STATISTICS TIME ON;
GO
SET STATISTICS TIME OFF;
GO 

SET STATISTICS TIME ON;
GO

SET STATISTICS TIME ON;
GO

SELECT Name
FROM Production.Product AS P
WHERE EXISTS
    (
	 SELECT 1 FROM Production.ProductSubcategory AS PS
     WHERE PS.Name = 'Wheels'
    -- AND PS.ProductSubcategoryID = P.ProductSubcategoryID
	)


-- NOT EXISTS	
SELECT Name
FROM Production.Product AS P
WHERE NOT EXISTS
    (
	 SELECT 1 FROM Production.ProductSubcategory AS PS
     WHERE PS.Name = 'Wheals'
    -- AND PS.ProductSubcategoryID = P.ProductSubcategoryID
	)



SET STATISTICS TIME OFF;
GO 



SET STATISTICS TIME ON;
GO

SELECT P.Name
FROM Production.Product AS P
JOIN Production.ProductSubcategory AS PS
ON P.ProductSubcategoryID = PS.ProductSubcategoryID
WHERE PS.Name = 'Socks'




SET STATISTICS TIME OFF;
GO








SET STATISTICS TIME ON;
GO


SELECT Name
FROM Production.Product AS P
WHERE EXISTS
    (
	 SELECT * FROM Production.ProductSubcategory AS PS
     WHERE PS.Name = 'Socks'
     AND PS.ProductSubcategoryID = P.ProductSubcategoryID
	)


SELECT Name
FROM Production.Product AS P
WHERE NOT EXISTS
    (
	 SELECT * FROM Production.ProductSubcategory AS PS
     WHERE PS.Name = 'Socks'
     AND PS.ProductSubcategoryID = P.ProductSubcategoryID
	)

SET STATISTICS TIME OFF;
GO



----- Optimize For Ad Hoc Workloads ----- 
-- Essa opção aumenta a eficiência do Plan Cache em relação a consultas Ad-Hoc.

-- Foi implementada a partir do SQL Server 2008 e permite se habilitado, quando o SQL Server precisar 
-- compilar um batch pela primeira vez, em vez de salvar um Plano de Execução Completo (Full Compiled Plan) 
-- como é realizado por padrão o mesmo ira armazenar do que chamamos de Stub Compiled Plan. 
-- Sendo assim o armazenamento desse plano é muito menos custoso para a Engine do banco de dados ocupando 
-- aproximadamente 18 Byte.

-- Cada Batch (T-SQL, Procedure, View…) quando executado cria um plano de execução no qual é armazenado dentro 
-- do banco de dados para caso utilizado novamente seja reusado. Por padrão quando passamos uma consulta para
-- o banco de dados é necessário que o SQL Server busque essas informações e assim armazene um plano de execução. 
-- Porém, muitas consultas que são realizadas dentro do banco de dados são consultas nas quais provavelmente não 
-- serão executadas novamente, fazendo com que a mesma ocupe espaço e recurso da máquina, essas consultas 
-- são chamadas de Ad-Hoc.


-- Limpando o Cache 
DBCC FREEPROCCACHE

DBCC DROPCLEANBUFFERS


sp_configure 'show advanced options',1
RECONFIGURE
GO

sp_configure 'optimize for ad hoc workloads',1
RECONFIGURE
 

USE Adventureworks
GO

SELECT * FROM Production.ProductSubcategory AS PS
WHERE PS.Name = 'Socks'


SELECT usecounts, cacheobjtype, objtype, TEXT
FROM sys.dm_exec_cached_plans
CROSS APPLY sys.dm_exec_sql_text(plan_handle)
WHERE usecounts > 0 AND
TEXT LIKE 'SELECT * FROM Production.ProductSubcategory%'
ORDER BY usecounts DESC;
GO


sp_configure 'show advanced options',1
RECONFIGURE
GO

sp_configure 'optimize for ad hoc workloads',1
RECONFIGURE


-- Referência:
-- http://luanmorenodba.wordpress.com/2012/05/24/optimize-for-ad-hoc-workloads/


---------------------------------- SET FORCEPLAN  ------------------------------

-- Quando FORCEPLAN está definido como ON, o otimizador de consulta do SQL Server 
-- processa uma ligação na mesma ordem conforme as tabelas são exibidas na 
-- cláusula FROM de uma consulta.  Além disso, configurar FORCEPLAN como ON força 
-- o uso de uma junção de loop aninhado, a não ser que outros tipos de junção 
-- sejam necessários ao construir um plano para a consulta ou eles sejam solicitados
-- com dicas de junção ou dicas de consulta. 
-- SET FORCEPLAN basicamente substitui a lógica usada pelo otimizador de consulta 
-- para processar uma instrução SELECT Transact-SQL.  Os dados retornados pela 
-- instrução SELECT são os mesmos independentemente dessa configuração. 
-- A única diferença é o modo pelo qual o SQL Server processa as tabelas para 
-- satisfazer a consulta. 

-- Também podem ser usadas dicas do otimizador de consulta em consultas para 
-- afetar a forma como o SQL Server processa a instrução SELECT.  

-- SET FORCEPLAN é aplicado na execução ou em tempo de execução e não no 
-- momento da análise. 


--SET FORCEPLAN ON;
--GO

--------------------------------------------------------------------------------


-- SQL HINTS:
-- http://technet.microsoft.com/pt-br/library/ms181714(v=sql.110).aspx


-- Exibe a última instrução enviada de um cliente a uma instância do MicrosoftSQL Server
-- DBCC INPUTBUFFER (SESSIONID)


-- Lab. 19 - Página 658 ou 823 (PDF único)
-- Página 310 (Part2.pdf) ou Página 475 (Part2.pdf)
-- Exercícios 1 e 2 - 25 minutos





USE Adventureworks
GO

------------------------------- SET STATISTICS TIME ----------------------------

-- Exibe o número de milissegundos necessários para analisar, 
-- compilar e executar cada instrução. 

--SET STATISTICS TIME ON;
--GO

--------------------------------------------------------------------------------


-------------------------------- SET STATISTICS IO -----------------------------

-- Faz o SQL Server exibir informações referentes à quantidade de atividade
-- em disco gerada pelas instruções Transact-SQL.

--SET STATISTICS IO ON;
--GO

--------------------------------------------------------------------------------


-------------------------------- SET SHOWPLAN_TEXT -----------------------------

-- Faz com que o Microsoft SQL Server não execute as instruções Transact-SQL.  
-- Em lugar disso, o SQL Server retorna informações detalhadas sobre como 
-- as instruções são executadas. 

-- SET SHOWPLAN_TEXT ON;
-- GO

--------------------------------------------------------------------------------


-------------------------------- SET SHOWPLAN_XML -------------------------------

-- Faz com que o SQL Server não execute instruções Transact-SQL.  
-- Em vez disso, o SQL Server retorna informações detalhadas sobre como
-- as instruções serão executadas no formulário de um documento XML bem definido. 

-- SET SHOWPLAN_XML ON;
-- GO

--------------------------------------------------------------------------------
SET STATISTICS IO ON;
GO

----- SELECT STAR (*) -----
-- Todos os CAMPOS (Nao recomendado o uso de asterisco !)
SELECT * FROM Adventureworks.Person.Person


SELECT 
	BusinessEntityID, PersonType, NameStyle, Title, FirstName MiddleName, LastName, Suffix, EmailPromotion, AdditionalContactInfo, Demographics, rowguid, ModifiedDate
FROM
	 PERSON.Person 


----- AMOSTRAGEM DE LINHAS -----
-- Amostragem
SELECT TOP 50 *
FROM Person.Person -- 19972 linhas

SELECT TOP 10 PERCENT
	     PS.FirstName
		,PS.MiddleName
		,PS.LastName
		,PS.Title
FROM Person.Person AS PS


SELECT 
		 BusinessEntityID
		,FirstName
		,MiddleName
		,LastName
		,FirstName + ' ' + LastName 
		,Title
FROM Person.Person
TABLESAMPLE(10)


----- CONVERSAO IMPLICITA -----
USE [Adventureworks];
GO

-- Conversão implícita:


SELECT 1 + 'GREEN' AS result;

SELECT '11' + 24 as result;


DECLARE @NOME AS NVARCHAR(10) = 'Michael'

SELECT * FROM [Person].[Person]
WHERE FirstName = @NOME


SP_HELP '[Person].[Person]'



-- * CONVERT ou CAST !?!















-- USAR CONVERT DE DATA PARA TEXTO E VICE-VERSA QUANDO NECESSÁRIO MÁSCARA
-- PARA TODAS OUTRAS CONVERSOES USAR CAST


----- DATA TYPES: VARCHAR, CHAR, NVARCHAR, NCHAR -----
DECLARE @VAR1 VARCHAR(20) -- ??? BYTES
DECLARE @VAR2 CHAR(20)    -- ??? BYTES
DECLARE @VAR3 NVARCHAR(20)-- ??? BYTES
DECLARE @VAR4 NCHAR(20)   -- ??? BYTES
DECLARE @VAR5 CHAR(8000)  -- ??? BYTES
DECLARE @VAR6 VARCHAR(8000)-- ??? BYTES

SET @VAR1='10987C'
SET @VAR2='10987C' 
SET @VAR3='10987C' 
SET @VAR4='10987C'
SET @VAR5='10987C' 
SET @VAR6='10987C' 

PRINT LEN(@VAR1);
PRINT LEN(@VAR2);
PRINT LEN(@VAR3);
PRINT LEN(@VAR4);
PRINT LEN(@VAR5);
PRINT LEN(@VAR6);

-- NAO CONSIDERA OS 2 BYTES
-- DE CONTROLE DO VARCHAR
--PRINT DATALENGTH(@VAR1);
--PRINT DATALENGTH(@VAR2);
--PRINT DATALENGTH(@VAR3);
--PRINT DATALENGTH(@VAR4);
--PRINT DATALENGTH(@VAR5);
--PRINT DATALENGTH(@VAR6);




----- UNICODE -----
create table ##unicodeinsert (valor nvarchar(10))

insert ##unicodeinsert values (N'???????')

insert ##unicodeinsert values ('???????')

select * from ##unicodeinsert


----- DATA TYPES: DATETIME, DATETIME2,... -----
DECLARE @DT1 DATETIME			= GETDATE()
DECLARE @DT2 DATETIME2(0)		= GETDATE()
DECLARE @DT3 DATETIME2(3)		= GETDATE()
DECLARE @DT4 DATETIME2(7)		= GETDATE()
DECLARE @DT5 DATE				= GETDATE()
DECLARE @DT6 TIME				= GETDATE()
DECLARE @DT7 SMALLDATETIME		= GETDATE()
DECLARE @DT8 DATETIMEOFFSET		= GETDATE()


--SELECT 
--	 @DT1 AS [DATETIME]
--	,@DT2 AS [DATETIME2(0)]
--	,@DT3 AS [DATETIME2(3)]
--	,@DT4 AS [DATETIME2(7)]
--	,@DT5 AS DATA
--	,@DT6 AS HORA
--	,@DT7 AS [SMALL]
--	,@DT8 AS [DATETIMEOFFSET]


SELECT 
	 DATALENGTH(@DT1) DTIME
	,DATALENGTH(@DT2) DTIME2_ZERO
	,DATALENGTH(@DT3) DTIME2_3
	,DATALENGTH(@DT4) DTIME2_FULL
	,DATALENGTH(@DT5) DATA
	,DATALENGTH(@DT6) HORA	
	,DATALENGTH(@DT7) SMALL



----- ORDER BY -----
SELECT COUNT(1) 
FROM AdventureWorks.Sales.SalesOrderDetail

SET STATISTICS IO ON;
GO

SELECT [SalesOrderID]
	,[SalesOrderDetailID]
	,[CarrierTrackingNumber]
	,[OrderQty]
	,[ProductID]
	,[SpecialOfferID]
	,[UnitPrice]
	,[UnitPriceDiscount]
	,[LineTotal]
	,[rowguid]
	,[ModifiedDate]
FROM AdventureWorks.Sales.SalesOrderDetail



SELECT [SalesOrderID]
	,[SalesOrderDetailID]
	,[CarrierTrackingNumber]
	,[OrderQty]
	,[ProductID]
	,[SpecialOfferID]
	,[UnitPrice]
	,[UnitPriceDiscount]
	,[LineTotal]
	,[rowguid]
	,[ModifiedDate]
FROM AdventureWorks.Sales.SalesOrderDetail
ORDER BY [UnitPrice] DESC




----- UNION x UNION ALL -----
USE tempdb
GO


-- DELETE CANDIDATES
CREATE TABLE dbo.CANDIDATES
(
	ID INT
	,NAME VARCHAR(50)
)

-- DELETE CANDIDATOS
CREATE TABLE dbo.CANDIDATOS
(
	ID INT 
	,NOME VARCHAR(50) 
)

INSERT INTO dbo.CANDIDATES (ID,NAME) VALUES (1,'Ana'),(2,'Alexander'),(3,'Albert')
GO

INSERT INTO dbo.CANDIDATOS VALUES (1,'Ana'),(4,'Joao'),(5,'Maria')
GO


SELECT * FROM dbo.CANDIDATES
SELECT * FROM dbo.CANDIDATOS


SELECT ID, NAME FROM dbo.CANDIDATES
UNION
SELECT ID, NOME FROM dbo.CANDIDATOS


SELECT ID, NAME FROM dbo.CANDIDATES
UNION ALL
SELECT ID, NOME FROM dbo.CANDIDATOS


----- EXCEPT -----
SELECT * FROM dbo.CANDIDATES
EXCEPT
SELECT * FROM dbo.CANDIDATOS

SELECT * FROM dbo.CANDIDATES AS C1
WHERE C1.ID NOT IN 
	(
		SELECT C2.ID FROM CANDIDATOS AS C2
	)

SELECT C1.ID,C1.NAME FROM dbo.CANDIDATES C1
LEFT JOIN dbo.CANDIDATOS C2
ON C1.ID = C2.ID
WHERE C2.ID IS NULL



--* Escrever com LEFT JOIN EXCLUSIVO (semi-join)


----- COLLATION -----
USE AdventureWorks

SELECT * FROM Person.Person
WHERE FirstName = 'MICHAEL'

SELECT * FROM Person.Person
WHERE LOWER(FirstName) = 'michael'


SELECT * FROM Person.Person
WHERE FirstName COLLATE Latin1_General_CI_AS = 'MIcHaeL'

USE CL
GO

CREATE TABLE NOMES (ID INT, NOME VARCHAR(100))

INSERT NOMES VALUES (1,'Marco'),(2,'MARCO'),(3,'marco'),(4,'maRcO')

CREATE CLUSTERED INDEX IX_NOMES_NOME ON NOMES
(NOME ASC)

SELECT
ID
,NOME
FROM dbo.Nomes
WHERE NOME = 'MaRcO'


 








WHERE NOME COLLATE Latin1_General_CI_AS = 'MaRcO'

-- * Usar de preferencia sempre COLLATION do Windows, nao iniciada por SQL_xxx




----- DISTINCT OU GROUP BY -----
SELECT [Color]
FROM AdventureWorks.Production.Product

SELECT DISTINCT [Color]
FROM AdventureWorks.Production.Product

SELECT Color
FROM AdventureWorks.Production.Product
GROUP BY Color



----- ORDEM DE FILTRAGEM -----
SELECT Color
FROM AdventureWorks.Production.Product
GROUP BY Color


SET STATISTICS TIME ON

SELECT Color, COUNT(1) QUANTIDADE
FROM AdventureWorks.Production.Product
GROUP BY Color
HAVING Color IS NOT NULL


SELECT Color, COUNT(1) QUANTIDADE
FROM AdventureWorks.Production.Product
WHERE Color IS NOT NULL
GROUP BY Color

SET STATISTICS TIME OFF


CREATE TABLE dbo.Produtos (ID int identity primary key, nome varchar(100), cor varchar(50))

INSERT dbo.Produtos
SELECT name, color FROM Production.Product
GO 100

SELECT COUNT(1) FROM dbo.Produtos


CREATE NONCLUSTERED INDEX IX_PRODUTOS_COR ON dbo.Produtos
(cor) 

CREATE NONCLUSTERED INDEX IX_PRODUTOS_COR_NOTNULL ON dbo.Produtos
(cor) 
WHERE cor IS NOT NULL


SET STATISTICS TIME ON
SET STATISTICS IO ON

SELECT cor, COUNT(1) QUANTIDADE
FROM dbo.Produtos 
GROUP BY cor
HAVING cor IS NOT NULL


SELECT cor, COUNT(1) QUANTIDADE
FROM dbo.Produtos WITH (INDEX(IX_PRODUTOS_COR_NOTNULL))
WHERE cor IS NOT NULL
GROUP BY cor

SET STATISTICS TIME OFF
SET STATISTICS IO OFF



----- JOINS: ANSI 89 versus ANSI 92 ------
SELECT COUNT(*) FROM Person.Person   --19972
SELECT COUNT(*) FROM HumanResources.Employee -- 290

SELECT  P.BusinessEntityID, P.FirstName, E.JobTitle
FROM Person.Person as P
INNER JOIN HumanResources.Employee as E
ON P.BusinessEntityID = e.BusinessEntityID


SELECT P.BusinessEntityID, P.FirstName, E.JobTitle
FROM Person.Person as P, HumanResources.Employee as E
WHERE P.BusinessEntityID = e.BusinessEntityID


SELECT P.BusinessEntityID, P.FirstName, E.JobTitle
FROM Person.Person as P, HumanResources.Employee as E
WHERE P.BusinessEntityID *= e.BusinessEntityID


----- NAO ACEITO MAIS DESDE SQL2005 - TROCAR POR ANSI JOIN















-- RIGHT JOIN OU LEFT JOIN ?
SELECT P.BusinessEntityID, P.FirstName, E.JobTitle
FROM Person.Person as P, HumanResources.Employee as E
WHERE E.BusinessEntityID *= P.BusinessEntityID



----- TRANSACAO COM TRY CATCH -----
	BEGIN TRY
		BEGIN TRAN
			--SET NOCOUNT ON;
  
			INSERT INTO PESSOAS 
			(id, nome, email)
			VALUES (11,'Peleh','peleh10@fifa.com')

			INSERT INTO PESSOAS 
			(id, nome, email)
			VALUES (15,'15','15a.com')
		   	
			INSERT INTO PESSOAS 
			(id, nome, email)
			VALUES (15,'OUTRAVEZ','12a.com')
					
		IF @@TRANCOUNT >0 COMMIT;
		
		PRINT 'TODAS INSERCOES COM SUCESSO!!!'
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT >0  ROLLBACK;
		    INSERT INTO PESSOAS_ERROR
			SELECT
   			ERROR_NUMBER() AS ErrorNumber,
			ERROR_SEVERITY() AS ErrorSeverity,
			ERROR_STATE() AS ErrorState,
			ERROR_PROCEDURE() AS ErrorProcedure,
			ERROR_LINE() AS ErrorLine,
			ERROR_MESSAGE() AS ErrorMessage,
			GETDATE(),
			HOST_NAME(),
			SYSTEM_USER

			IF ERROR_NUMBER()=2627
			RAISERROR ('Erro de insercao duplicada em campo UNIQUE !!!',10,1);
	END CATCH




----- CROSS APPLY ------
/*
O operador APPLY permite que você invoque uma função com valor de tabela para cada linha 
retornada por uma expressão de tabela externa de uma consulta. 
A função com valor de tabela age como a entrada à direita e a expressão de tabela exterior age 
como a entrada à esquerda. 
A entrada à direita é avaliada para cada linha da entrada à esquerda e as linhas produzidas 
são combinadas na saída final. A lista de colunas produzida pelo operador APPLY é o conjunto 
de colunas na entrada à esquerda, seguido pela lista de colunas retornadas pela entrada à direita. 

Observacao:  Para usar APPLY, o nível de compatibilidade do banco de dados deve ser no mínimo 90.

Há duas formas de APPLY: CROSS APPLY e OUTER APPLY:

CROSS APPLY só retorna linhas da tabela exterior que produzem 
um conjunto de resultados da função com valor de tabela. 

OUTER APPLY retorna linhas que produzem um conjunto de resultados 
e linhas que não o fazem, com valores NULL nas colunas produzidas 
pela função com valor de tabela.


*/
USE TSQL
GO


DROP FUNCTION dbo.fn_TopProductsByShipper

-- Retorna os 3 produtos mais caros de um fornecedor especifico
CREATE FUNCTION dbo.fn_TopProductsByShipper
(@supplierid int)
RETURNS TABLE
AS
RETURN
	SELECT TOP (3) productid, productname, unitprice
	FROM Production.Products
	WHERE supplierid = @supplierid
	ORDER BY unitprice DESC;
GO


SELECT supplierid ,COUNT(*) AS QTDE
FROM  Production.Products     
GROUP BY supplierid



SELECT * FROM Production.Products   
WHERE supplierid = 12

-- Teste da Funcao
SELECT * FROM dbo.fn_TopProductsByShipper(12);

	
	--SELECT  productid, productname, unitprice
	--FROM Production.Products
	--WHERE supplierid =7
	--ORDER BY unitprice DESC;

	select COUNT(*) from Production.Suppliers
	-- 29 LINHAS / 29 FORNECEDORES

-- CROSS APPLY (Para cada Fornecedor da tabela Suppliers retorna os 3 produtos mais caros
SELECT S.supplierid
	  ,S.companyname
	  ,P.productid
	  ,P.productname
	  ,P.unitprice
FROM Production.Suppliers AS S
CROSS APPLY dbo.fn_TopProductsByShipper(S.supplierid) AS P
ORDER BY S.supplierid ASC, P.unitprice DESC;






SELECT COUNT(*) FROM Sales.Customers -- 91 rows


-- Retorna os 3 pedidos mais recentes por Cliente
SELECT 
	 C.custid
	,TopOrders.orderid
	,TopOrders.orderdate
	,C.country
	,C.city
	,C.companyname
	,C.contactname
FROM 
	Sales.Customers AS C -- 91 LINHAS
OUTER APPLY
(   
	SELECT TOP (3) orderid, orderdate
	FROM Sales.Orders AS O
	WHERE O.custid = C.custid
	ORDER BY orderdate DESC, orderid DESC
) AS TopOrders;


SELECT COUNT(*) FROM Sales.Customers -- 91 CLIENTES


SELECT  custid, COUNT(*) AS QTDE
	FROM Sales.Orders 
GROUP BY custid

SELECT  orderid, orderdate
	FROM Sales.Orders 
	WHERE custid IN (22,57)


-- Com o OUTER APPLY retornam inclusive Clientes sem pedidos

SELECT 
	 C.custid
	,TopOrders.orderid
	,TopOrders.orderdate
	,C.country
	,C.city
	,C.companyname
	,C.contactname
FROM Sales.Customers AS C
OUTER APPLY
(
	SELECT TOP (3) orderid, orderdate
	FROM Sales.Orders AS O
	WHERE O.custid = C.custid
	ORDER BY orderdate DESC, orderid DESC
) AS TopOrders 


--------------------------------------------------------------------------------------------------
-- Neste exemplo de APPLY, vemos as 20 querys que estão requisitando mais disco:
--------------------------------------------------------------------------------------------------

SELECT TOP 5 SUBSTRING(qt.text, 
(qs.statement_start_offset/2)+1, 
        ((CASE 
qs.statement_end_offset
          WHEN -1 THEN DATALENGTH(qt.text)
         ELSE 
qs.statement_end_offset
         END - 
qs.statement_start_offset)/2)+1) AS TOMATE, 
qs.execution_count, 

qs.total_logical_reads, qs.last_logical_reads,
qs.min_logical_reads, 
qs.max_logical_reads,
qs.total_elapsed_time, 
qs.last_elapsed_time,
qs.min_elapsed_time, 
qs.max_elapsed_time,
qs.last_execution_time,
qp.query_plan
FROM sys.dm_exec_query_stats 
qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
CROSS APPLY 
sys.dm_exec_query_plan(qs.plan_handle) qp
WHERE qt.encrypted=0
ORDER BY 
qs.total_logical_reads DESC





----- INDICES -----
SELECT 
 [BusinessEntityID]
,[FirstName] 
FROM Person.Person
WHERE BusinessEntityID
NOT IN
	( SELECT DISTINCT(BusinessEntityID) FROM [HumanResources].[Employee] )



SELECT
PES.[BusinessEntityID]
,[FirstName]
 FROM Person.Person AS PES
LEFT JOIN [HumanResources].[Employee]  AS EMP
ON PES.BusinessEntityID = EMP.BusinessEntityID
WHERE EMP.BusinessEntityID IS NULL

SET STATISTICS IO OFF;
GO



--SET STATISTICS IO OFF;
--GO


SET STATISTICS TIME OFF;
GO

IF OBJECT_ID('SEMINDICE') IS NOT NULL
DROP TABLE SEMINDICE 

IF OBJECT_ID('COMINDICE') IS NOT NULL
DROP TABLE COMINDICE 



CREATE TABLE SEMINDICE -- TABELA HEAP = SEM INDICE
(
	ID   INT IDENTITY
	,NOME VARCHAR(100)
)

CREATE TABLE COMINDICE -- TABELA HEAP = SEM INDICE
(
	ID   INT IDENTITY
	,NOME VARCHAR(100)
)

INSERT INTO SEMINDICE
SELECT FirstName
FROM PERSON.Person

INSERT INTO COMINDICE
SELECT FirstName
FROM PERSON.Person


SET STATISTICS IO ON;
GO

SELECT * from SEMINDICE
WHERE ID = 10

SELECT * from COMINDICE
WHERE ID = 10

SET STATISTICS IO OFF;
GO

SP_SPACEUSED 'COMINDICE'
SP_SPACEUSED 'SEMINDICE'



CREATE TABLE COMINDICE
(
	ID   INT IDENTITY
	,NOME VARCHAR(100)
)

INSERT INTO COMINDICE
SELECT FirstName
FROM PERSON.Person


CREATE CLUSTERED INDEX IX_ID
    ON COMINDICE (ID)
	
	
SET STATISTICS IO ON;
GO

SELECT * from SEMINDICE
WHERE ID = 10


SELECT * from COMINDICE
WHERE ID = 10

SET STATISTICS IO OFF;
GO

SP_SPACEUSED 'COMINDICE'
SP_SPACEUSED 'SEMINDICE'


SET STATISTICS IO ON;
GO

SELECT * from SEMINDICE
WHERE NOME LIKE 'A%'


SELECT * from COMINDICE 
WHERE NOME LIKE 'A%' 


SET STATISTICS IO OFF;
GO

----
CREATE NONCLUSTERED INDEX IX_NOME
    ON COMINDICE (NOME)
	

SELECT * from SEMINDICE
WHERE NOME LIKE 'A%'

SELECT * from COMINDICE 
WHERE NOME LIKE 'A%' 

SELECT * from COMINDICE WITH (INDEX(IX_ID))
WHERE NOME LIKE 'A%' 

DROP INDEX IX_ID ON COMINDICE
GO

CREATE CLUSTERED INDEX IX_ID
    ON COMINDICE (ID)

SET STATISTICS IO OFF;
GO

SP_SPACEUSED COMINDICE




----- Optimize For Ad Hoc Workloads ----- 
-- Essa opção aumenta a eficiência do Plan Cache em relação a consultas Ad-Hoc.

-- Foi implementada a partir do SQL Server 2008 e permite se habilitado, quando o SQL Server precisar 
-- compilar um batch pela primeira vez, em vez de salvar um Plano de Execução Completo (Full Compiled Plan) 
-- como é realizado por padrão o mesmo ira armazenar do que chamamos de Stub Compiled Plan. 
-- Sendo assim o armazenamento desse plano é muito menos custoso para a Engine do banco de dados ocupando 
-- aproximadamente 18 Byte.

-- Cada Batch (T-SQL, Procedure, View…) quando executado cria um plano de execução no qual é armazenado dentro 
-- do banco de dados para caso utilizado novamente seja reusado. Por padrão quando passamos uma consulta para
-- o banco de dados é necessário que o SQL Server busque essas informações e assim armazene um plano de execução. 
-- Porém, muitas consultas que são realizadas dentro do banco de dados são consultas nas quais provavelmente não 
-- serão executadas novamente, fazendo com que a mesma ocupe espaço e recurso da máquina, essas consultas 
-- são chamadas de Ad-Hoc.


-- Limpando o Cache 
DBCC FREEPROCCACHE

DBCC DROPCLEANBUFFERS


sp_configure 'show advanced options',1
RECONFIGURE
GO

sp_configure 'optimize for ad hoc workloads',1
RECONFIGURE
 

USE Adventureworks
GO

SELECT * FROM Production.ProductSubcategory AS PS
WHERE PS.Name = 'Socks'


SELECT usecounts, cacheobjtype, objtype, TEXT
FROM sys.dm_exec_cached_plans
CROSS APPLY sys.dm_exec_sql_text(plan_handle)
WHERE usecounts > 0 AND
TEXT LIKE 'SELECT * FROM Production.ProductSubcategory%'
ORDER BY usecounts DESC;
GO


sp_configure 'show advanced options',1
RECONFIGURE
GO

sp_configure 'optimize for ad hoc workloads',1
RECONFIGURE


-- Referência:
-- http://luanmorenodba.wordpress.com/2012/05/24/optimize-for-ad-hoc-workloads/


---------------------------------- SET FORCEPLAN  ------------------------------

-- Quando FORCEPLAN está definido como ON, o otimizador de consulta do SQL Server 
-- processa uma ligação na mesma ordem conforme as tabelas são exibidas na 
-- cláusula FROM de uma consulta.  Além disso, configurar FORCEPLAN como ON força 
-- o uso de uma junção de loop aninhado, a não ser que outros tipos de junção 
-- sejam necessários ao construir um plano para a consulta ou eles sejam solicitados
-- com dicas de junção ou dicas de consulta. 
-- SET FORCEPLAN basicamente substitui a lógica usada pelo otimizador de consulta 
-- para processar uma instrução SELECT Transact-SQL.  Os dados retornados pela 
-- instrução SELECT são os mesmos independentemente dessa configuração. 
-- A única diferença é o modo pelo qual o SQL Server processa as tabelas para 
-- satisfazer a consulta. 

-- Também podem ser usadas dicas do otimizador de consulta em consultas para 
-- afetar a forma como o SQL Server processa a instrução SELECT.  

-- SET FORCEPLAN é aplicado na execução ou em tempo de execução e não no 
-- momento da análise. 


--SET FORCEPLAN ON;
--GO

--------------------------------------------------------------------------------


-- SQL HINTS:
-- http://technet.microsoft.com/pt-br/library/ms181714(v=sql.110).aspx


-- Exibe a última instrução enviada de um cliente a uma instância do MicrosoftSQL Server
-- DBCC INPUTBUFFER (SESSIONID)
