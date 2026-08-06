-------------------- Curso 20-764 - Modulo 4 --------------------

----- Demo 1: Auditing with Temporal Tables
-- A PARTIR DO SQL2016 ON-PREMISES OU NATIVO NO AZURE SQL DATABASE
CREATE DATABASE MTC
GO


USE MTC
GO
 
/*Cria tabela de dbo.Pessoas*/
CREATE TABLE dbo.Pessoas
( 
	 ID INT NOT NULL
	,NOME VARCHAR(100) NOT NULL
	,SALARIO MONEY
	,CPF CHAR(11)
)

INSERT dbo.Pessoas 
VALUES (1,'JOAO',1000,'1484'),(2,'MARIA',2000,'1234')

 SELECT * FROM dbo.Pessoas

/*Adiciona colunas de tempo*/
ALTER TABLE dbo.Pessoas
	 ADD DataHoraInicio datetime2(0) GENERATED ALWAYS AS ROW START   
         CONSTRAINT DF_SysStart DEFAULT DATEADD(second, -1, SYSUTCDATETIME()),
	 DataHoraFinal datetime2(0) GENERATED ALWAYS AS ROW END   
         CONSTRAINT DF_SysEnd DEFAULT CONVERT(datetime2 (0), '9999-12-31 23:59:59'),
	 PERIOD FOR SYSTEM_TIME (DataHoraInicio, DataHoraFinal);
GO

SELECT  SYSUTCDATETIME()

SELECT * FROM dbo.Pessoas

SELECT *
	,DataHoraInicio
	,DataHoraFinal
FROM dbo.Pessoas


/*Gera tabela de historico com mesmo schema*/
ALTER TABLE dbo.Pessoas
SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.Pessoas_Historico));
GO

/*A tabela PAI deve ter chave primaria*/
ALTER TABLE dbo.Pessoas
ADD CONSTRAINT PK_Pessoas_ID PRIMARY KEY CLUSTERED (ID);
GO


/*Gera tabela de historico com mesmo schema*/
ALTER TABLE dbo.Pessoas
SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.Pessoas_Historico));
GO

SELECT *
	,DataHoraInicio
	,DataHoraFinal
FROM dbo.Pessoas

SELECT * FROM dbo.Pessoas_Historico

/*Adiciona coluna na tabela*/
ALTER TABLE dbo.Pessoas
	ADD DataNascimento DATE NULL;
GO


SELECT * FROM dbo.Pessoas
SELECT * FROM dbo.Pessoas_Historico

/*Exclui coluna da tabela*/
ALTER TABLE dbo.Pessoas
	DROP COLUMN DataNascimento;
GO

-- Alterando os dados da tabela
UPDATE dbo.Pessoas SET SALARIO=5500 WHERE NOME='JOAO'
UPDATE dbo.Pessoas SET SALARIO=3300 WHERE NOME='MARIA'

INSERT dbo.Pessoas VALUES (3,'PEDRO',2800,1414)
INSERT dbo.Pessoas VALUES (4,'ANTONIO',4800,4444)

UPDATE dbo.Pessoas SET SALARIO=7800 WHERE NOME='PEDRO'

DELETE dbo.Pessoas WHERE NOME='MARIA'

----
SELECT * FROM dbo.Pessoas

SELECT * FROM [dbo].[dbo.Pessoas_Historico]



/*Consultando historico completo*/
SELECT *,DataHoraInicio,DataHoraFinal 
FROM dbo.Pessoas
FOR SYSTEM_TIME ALL
ORDER BY ID, DataHoraInicio DESC

SELECT * --, DataHoraInicio, DataHoraFinal
FROM dbo.Pessoas
FOR SYSTEM_TIME ALL
ORDER BY ID, DataHoraInicio DESC

/*Remove o flag de HIDDEN das colunas de controle temporal*/
ALTER TABLE dbo.Pessoas
ALTER COLUMN DataHoraInicio add HIDDEN;

ALTER TABLE dbo.Pessoas
ALTER COLUMN DataHoraFinal add HIDDEN;
GO

SELECT * FROM dbo.Pessoas
FOR SYSTEM_TIME ALL
ORDER BY ID, DataHoraInicio DESC


/*Consulta temporal usando BETWEEN*/
SELECT *  --, DataHoraInicio, DataHoraFinal
FROM dbo.Pessoas
FOR SYSTEM_TIME BETWEEN '2022-10-21 13:44:17' AND '2022-10-21 13:49:17'
ORDER BY ID, DataHoraInicio DESC;


/*Consulta temporal usando AS OF*/
DECLARE @now datetime2 = sysutcdatetime()
DECLARE @fromTime datetime2
SET @fromTime = DATEADD (minute, -6, @now)


SELECT * FROM dbo.Pessoas
EXCEPT 
SELECT * FROM dbo.Pessoas
FOR SYSTEM_TIME AS OF @fromTime


/*Consultando historico com CONTAINED IN */
DECLARE @now datetime2 = sysutcdatetime()
DECLARE @fromTime datetime2
SET @fromTime = DATEADD (minute, -5, @now)


SELECT * FROM dbo.Pessoas
FOR SYSTEM_TIME CONTAINED IN (@fromTime, @now)


/*Adiciona o flag de HIDDEN das colunas de controle temporal*/
ALTER TABLE dbo.Pessoas
ALTER COLUMN DataHoraInicio ADD HIDDEN;

ALTER TABLE dbo.Pessoas
ALTER COLUMN DataHoraFinal ADD HIDDEN;
GO

SELECT COUNT(1) FROM [dbo].[dbo.Pessoas]
UNION ALL
SELECT COUNT(1) FROM [dbo].[dbo.Pessoas_Historico]


/*Disvincula tabela Historico associada*/
ALTER TABLE dbo.Pessoas SET (SYSTEM_VERSIONING = OFF);

DROP TABLE IF EXISTS dbo.Pessoas;
DROP TABLE IF EXISTS dbo.Pessoas_Historico;

 