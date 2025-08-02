---------- Demo: Using an Application Role ----------
-- Create an Application Role
USE [AdventureWorks]
GO


-- caixa : 123

CREATE TABLE Production.VENDAS (ID INT, PRODUTO MONEY, QTY TINYINT)

DELETE Production.VENDAS

GRANT SELECT,INSERT ON SCHEMA::Production TO [caixa] 


INSERT Production.VENDAS VALUES (4, 200,1)

SELECT [ID]
	,[PRODUTO]
	,[QTY]
FROM Production.VENDAS


DELETE Production.VENDAS
WHERE ID = 4

DROP APPLICATION ROLE  [pay_admin]
GO

CREATE APPLICATION ROLE [gerente_caixa] WITH DEFAULT_SCHEMA = [Production], PASSWORD = N'Pa55w.rd'
GO

GRANT SELECT, INSERT, DELETE ON SCHEMA::Production TO [gerente_caixa]

-- Use an Application Role

-- Passo 3: Open the ApplicationRole.sql script file in the D:\DemoFiles\Mod09 folder. The code in this file
--			displays the identity of the current user and login before, during, and after the activation of the
--			pay_admin application role.

-- Passo 4: Right-click anywhere in the script window, point to Connection, and click Change Connection. Then
--		    connect to the MIA-SQL database engine using SQL Server authentication as Payroll_Application
--			with the password Pa55w.rd.

-- Passo 5: Click Execute and view the results. Note that the System Identity does not change (which may be
--			important for auditing reasons), but that the DB Identity switched to pay_admin while the
--			application role was active.

-- user security context
USE AdventureWorks
GO

-- Use application role
SELECT 
	 'Contexto atual de usuario' As Context
	,user_name() AS [DB Identity]
	,SUSER_NAME() AS [System Identity]

-- Use application role
DECLARE @cookie varbinary(8000);
EXEC sp_setapprole 'gerente_caixa', 'Pa55w.rd', @fCreateCookie = true, @cookie = @cookie OUTPUT;

--SELECT @cookie  -- 0xDDBE0B8A5661F1A6B077A7F0072DB41AECE0FEE8E79EB61DFC898F32B624495CFB9386BB00326E12ABB4504404CA6C210100

--SELECT 
--	 'Contexto atual de usuario' As Context
--	,user_name() AS [DB Identity]
--	,SUSER_NAME() AS [System Identity]

--INSERT Production.ALUNOS VALUES (3,'PEDRO')

DELETE Production.VENDAS
WHERE ID = 4

----SELECT * FROM  Production.ALUNOS
EXEC sp_unsetapprole @cookie;

--SELECT * FROM Production.Vendas

-- user security contenxt
SELECT 'Reverted to user context' As Context, user_name() AS [DB Identity], SUSER_NAME() AS [System Identity]

SELECT ID,NOME FROM Production.ALUNOS


------- (destruindo Cookie) --------
-- Capturar o binario do Cookie
SELECT @cookie

-- Criar uma variavel com o mesmo valor do Cookie capturado acima
DECLARE @c varbinary(8000) = 0xDF52DD3DF38CA1C952651781F8F529F15091E6B19BD868721D503B9282EA8EC95040C1334DF0F0B23717ACFA8B3990A20100

-- Destruir o Cookie
EXEC sp_unsetapprole @c;