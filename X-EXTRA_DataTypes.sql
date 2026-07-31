----- Modulo 6: Working with SQL Server 2012 Data Types

USE [Adventureworks];
GO

-- Conversão implícita:


SELECT 1 + '31' AS result;



SELECT '11' + '24' as result;


DECLARE @NOME AS NVARCHAR(10) = 'Michael'

SELECT * FROM [Person].[Person]
WHERE FirstName = @NOME


SP_HELP '[Person].[Person]'
-----------------------------------------------------------------
-- SQL Server uses the following precedence order for data types:
/*
1. user-defined data types (highest)

2. sql_variant 

3. xml 

4. datetimeoffset 

5. datetime2 

6. datetime 

7. smalldatetime 

8. date 

9. time 

10.float 

11.real 

12.decimal 

13.money 

14.smallmoney 

15.bigint 

16.int 

17.smallint 

18.tinyint 

19.bit 

20.ntext 

21.text 

22.image 

23.timestamp 

24.uniqueidentifier 

25.nvarchar (including nvarchar(max) )

26.nchar 

27.varchar (including varchar(max) )

28.char 

29.varbinary (including varbinary(max) )

30.binary (lowest)
*/
----------------------------------------

-- Conversão explícita: 
SELECT '1'  + '24'

SELECT CAST(1 AS VARCHAR(3)) + '24' AS resultado; 

SELECT 1  + CAST('24' AS INT) AS resultado; 


-- CHAR, VARCHAR, NVARCHAR
DECLARE @VAR1 VARCHAR(20) --  6 BYTES
DECLARE @VAR2 CHAR(20)    --  20
DECLARE @VAR3 NVARCHAR(20)--  12
DECLARE @VAR4 NCHAR(20)   -- 40
DECLARE @VAR5 CHAR(8000)  -- 8000
DECLARE @VAR6 VARCHAR(8000)-- 6

SET @VAR1='20761C'
SET @VAR2='20761C' 
SET @VAR3='20761C' 
SET @VAR4='20761C'
SET @VAR5='20761C' 
SET @VAR6='20761C' 

--PRINT LEN(@VAR1);
--PRINT LEN(@VAR2);
--PRINT LEN(@VAR3);
--PRINT LEN(@VAR4);
--PRINT LEN(@VAR5);
--PRINT LEN(@VAR6);

-- NAO CONSIDERA OS 2 BYTES
-- DE CONTROLE DO VARCHAR
PRINT DATALENGTH(@VAR1);
PRINT DATALENGTH(@VAR2);
PRINT DATALENGTH(@VAR3);
PRINT DATALENGTH(@VAR4);
PRINT DATALENGTH(@VAR5);
PRINT DATALENGTH(@VAR6);


SELECT FirstName, lastname 
FROM Adventureworks.Person.PeRsON
WHERE lastname = N'wright';


SELECT 
*
FROM
[COL].[dbo].[PESSOAS]
WHERE NOME COLLATE Latin1_General_CI_AS = 'mArcO'



--CREATE DATABASE TEST



--WHERE NOME COLLATE Latin1_General_CI_AS = 'marcO'



--USE CL
--GO

--CREATE TABLE NOMES (ID INT, NOME VARCHAR(100))

--INSERT NOMES VALUES (1,'Marco'),(2,'MARCO'),(3,'marco'),(4,'maRcO')



-

-- Collation: 
SELECT FirstName, lastname
FROM Person.Person
WHERE lastname COLLATE Latin1_General_CS_AS = N'Wright';

mfwbauer72@hotmail.com
-- Funcoes com String: 
SELECT SUBSTRING('Microsoft SQL Server',11,3) AS SUBSTRING;
SELECT LEFT('Microsoft SQL Server',9) AS 'LEFT';
SELECT RIGHT('Microsoft SQL Server',6) AS  'RIGHT';
SELECT LEN('Microsoft SQL Server ') AS 'LEN';
SELECT DATALENGTH('Microsoft SQL Server ') AS DATALENG ;
SELECT CHARINDEX('SQL','Microsoft SQL Server') AS CHARIND;
SELECT REPLACE('Microsoft SQL Server Denali','Denali','2012') AS REPL;
SELECT UPPER('Microsoft SQL Server');
SELECT LOWER('Microsoft SQL Server');
SELECT STUFF('MARCO BAUER',6,0,' FABIO');
SELECT REVERSE('REVRES LQS') AS [REVERSE];




--ANTES DO ARROBA
DECLARE @EMAIL VARCHAR(100) = 'mfwbauer33333333@hotmail.com'

SELECT LEFT(@EMAIL, CHARINDEX('@',@EMAIL)-1)



--SELECT SUBSTRING(@EMAIL,0,CHARINDEX('@',@EMAIL))

----DEPOIS DO ARROBA
DECLARE @EMAIL VARCHAR(100) = 'mfwbauer21231231231221312@hotmail.com'

SELECT  SUBSTRING(@EMAIL,CHARINDEX('@',@EMAIL)+1,LEN(@EMAIL)-CHARINDEX('@',@EMAIL))

SELECT CHARINDEX('@',REVERSE(@EMAIL))


-- Uso do LIKE:
SELECT 
	ProductID
	,Name
	,Color
	,Size
	,Weight
FROM 
	Production.Product
--WHERE Name LIKE 'Mountain-100 Silver%';
WHERE Name LIKE 'Mountain-100 Silver__4%';




-- Funcoes de Tempo:
SELECT
	GETDATE()			AS [GetDate],
	CURRENT_TIMESTAMP	AS [Current_Timestamp],
	GETUTCDATE()		AS [GetUTCDate],
	SYSDATETIME()		AS [SYSDateTime],
	SYSUTCDATETIME()	AS [SYSUTCDateTime],
	SYSDATETIMEOFFSET()	AS [SYSDateTimeOffset];
	
SET LANGUAGE BRAZILIAN
GO

-- Retorno de parte de um campo Data:
SELECT 
     CAST('2007-05-08 12:35:29. 1234567 +12:15' AS time(3)) AS 'time' 
    ,CAST('2007-05-08 12:35:29. 1234567 +12:15' AS date) AS 'date' 
    ,CAST('2007-05-08 12:35:29.123' AS smalldatetime) AS 
        'smalldatetime' 
    ,CAST('2007-05-08 12:35:29.123' AS datetime) AS 'datetime' 
    ,CAST('2007-05-08 12:35:29. 1234567 +12:15' AS datetime2(7)) AS 
        'datetime2'
    ,CAST('2007-05-08 12:35:29.1234567 +12:15' AS datetimeoffset(7)) AS 
        'datetimeoffset'
	,DAY('2007-05-08 12:35:29.1234567 +12:15') AS DIA
	,MONTH('2007-05-08 12:35:29.1234567 +12:15') AS MES
	,YEAR('2007-05-08 12:35:29.1234567 +12:15') AS ANO
	,DATEPART(YEAR, '2007-05-08 12:35:29.1234567 +12:15') AS HORA
	,DATEPART(MINUTE, '2007-05-08 12:35:29.1234567 +12:15') AS MINUTOS
	,DATEPART(SECOND, '2007-05-08 12:35:29.1234567 +12:15') AS SEGUNDOS	
	,DATEPART(WEEK, '2007-05-08 12:35:29.1234567 +12:15') AS SEMANA	
	,DATENAME(MONTH, '2007-05-08 12:35:29.1234567 +12:15') AS NOME_MES





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
	
--SELECT 
--	 LEN(@DT1) DTIME
--	,LEN(@DT2) DTIME2_ZERO
--	,LEN(@DT3) DTIME2_3
--	,LEN(@DT4) DTIME2_FULL
--	,LEN(@DT5) DATA
--	,LEN(@DT6) HORA
--	,LEN(@DT7) SMALL
	


SELECT 
	 DATALENGTH(@DT1) DTIME
	,DATALENGTH(@DT2) DTIME2_ZERO
	,DATALENGTH(@DT3) DTIME2_3
	,DATALENGTH(@DT4) DTIME2_FULL
	,DATALENGTH(@DT5) DATA
	,DATALENGTH(@DT6) HORA	
	,DATALENGTH(@DT7) SMALL

	
-- Retorna Datas pelas partes informadas:
SELECT DATETIMEFROMPARTS(2012,2,12,8,30,0,0) AS Result; --7 arguments
SELECT DATETIME2FROMPARTS(2012,2,12,8,30,00,0,0) AS Result; -- 8 arguments
SELECT DATEFROMPARTS(2012,2,12) AS Result; -- 3args
SELECT DATETIMEOFFSETFROMPARTS(2012,2,12,8,30,0,0,-7,0,0) AS Result;

PRINT GETDATE() 
PRINT GETDATE() + 60

-- DATEDIFF: 
SELECT DATEDIFF(YEAR, GETDATE(),GETDATE()+11); 


-- ISDATE: Verifica se a data informada é valida ou não
SELECT ISDATE('20120212');
SELECT ISDATE('20120230');
SELECT ISDATE('2012ABC');


---------------------------------- COMANDO NOVO T-SQL 2012 ----------------------------------

--- EOMONTH: Retorna ultimo dia do Mes e Ano da Data Informada
SELECT EOMONTH ('2015-02-23') as [FIM DE FEV]
SELECT EOMONTH ('1912-02-13') as [FIM DE FEV] 

-- com offset
SELECT EOMONTH ('2015-08-08',1) as [FIM DE SETEMBRO]

SELECT EOMONTH ('2015/08/08',-1) as [FIM DE JULHO]

SELECT EOMONTH ('20140228')


-- Lab. 6 - Página 258 ou 469 (PDF) 
-- Exercícios (1,2,3 e 4) - 80 minutos

