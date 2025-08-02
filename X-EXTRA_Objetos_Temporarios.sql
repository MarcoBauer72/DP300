USE master
GO


ALTER DATABASE [tempdb] MODIFY FILE ( NAME = N'tempdev', SIZE = 8192KB );
GO

DBCC SHRINKDATABASE (tempdb,0)

CHECKPOINT;

USE TEMPDB
GO

SELECT file_id,
       name, 
       size*8 as Size_mb,
       FILEPROPERTY(name, 'SpaceUsed') as SpaceUsedInPages,
       physical_name
FROM sys.database_files;

file_id	name	Size_mb	SpaceUsedInPages	physical_name
1	tempdev	8192	488	D:\Databases\SQL14\tempdb.mdf
2	templog	512	67	D:\Databases\SQL14\templog.ldf


USE TEMPDB
GO

CREATE TABLE TESTETEMP
(
ID INT
)

SELECT COUNT(*) FROM TESTETEMP

INSERT TESTETEMP VALUES (1) 
GO 1000


-- NOMES PARA O SIMBOLO #
-------------------------------------------------
# HASHTAG
# SUSTENIDO
# JOGO DA VELHA
# BAND-AID
# TRALHA
# FEPASA
# CERQUILHA 
# CERQUINHA 
-------------------------------------------------


--DROP TABLE #Pessoas (tralha, sustenido, hashtag, jogo da velha)
-- Tabela temporária local:
-- Tem um único símbolo (#) antes do nome.
-- Visivel apenas para a "section" corrente
-- É apagada assim que a "section" é fechada.
CREATE TABLE #Pessoas
(
   ID int
   ,TIPO char(2)
   ,NOME varchar(200)
)



INSERT INTO #Pessoas 
SELECT 
	BusinessEntityID
	,PersonType
	,FirstName + ' ' + LastName
FROM Adventureworks.Person.PERSON 
WHERE FirstName LIKE 'B%'

--select * from #Pessoas 

--SELECT * FROM tempdb.sys.tables


-- CASO EXISTA A TABELA TEMPORARIA ENTAO APAGAR
IF OBJECT_ID('tempdb..#Pessoas') IS NOT NULL
DROP TABLE #Pessoas 



-- Tabela temporária Global:
-- Tem dois símbolos (##) antes do nome.
-- Visível para todos após criada.
CREATE TABLE ##Pessoas
(
   ID int
   ,TIPO char(2)
   ,NOME varchar(200)
)


INSERT INTO ##Pessoas 
SELECT 
	BusinessEntityID
	,PersonType
	,FirstName + ' ' + LastName
FROM Adventureworks.PERSON.PERSON 
WHERE FirstName LIKE 'G%'



SELECT TOP(1) Name, Color FROM PRODUCTION.PRODUCT


Select * from ##Pessoas 

--DROP TABLE ##Pessoas 

--SELECT * FROM tempdb.sys.tables



-- Variável tipo Tabela:
-- Possui o símbolo (@) antes do nome.
-- Só é acessível dentro do mesmo "batch".
-- Também cria objeto na TEMPDB.

GO



USE tempdb
GO

 
CHECKPOINT;


SELECT *
FROM fn_dblog(null, null);

DECLARE @NUMPESSOAS AS INT = 100

PRINT @NUMPESSOAS


DECLARE @PESSOAS AS TABLE (ID INT, OBS VARCHAR(50))



INSERT INTO @PESSOAS
SELECT BusinessEntityID, FirstName
FROM Adventureworks.Person.Person

SELECT * FROM @PESSOAS

--INSERT INTO @PESSOAS VALUES (1,'UM'),(2,'DOIS'),(3,'TRES')


--SELECT * FROM @PESSOAS



ALTER DATABASE [tempdb] MODIFY FILE ( NAME = N'tempdev', SIZE = 8192KB );
GO

DBCC SHRINKDATABASE (tempdb,0)

CHECKPOINT;

USE TEMPDB
GO

SELECT file_id,
       name, 
       size*8 as Size_mb,
       FILEPROPERTY(name, 'SpaceUsed') as SpaceUsedInPages,
       physical_name
FROM sys.database_files;


SET NOCOUNT ON;
DECLARE @I AS INT = 1
DECLARE @PESSOAS AS TABLE (ID INT, OBS VARCHAR(50))

WHILE @I < 1000000
BEGIN
	INSERT INTO @PESSOAS VALUES (1,'UM'),(2,'DOIS'),(3,'TRES')
    
	--PRINT @I
	 
	SET @I +=1   -- SET @I = @I + 1
END
SET NOCOUNT OFF;


SELECT * FROM @PESSOAS


IF  OBJECT_ID('TEMPDB..#DIR') IS NOT NULL
DROP TABLE #DIR


CREATE TABLE #DIR
(
SAIDA VARCHAR(MAX)
)




----- STORED PROCEDURE TEMPORARIA -----
IF OBJECT_ID ('TEMPDB..##XSP_PROCED', 'P') IS NOT NULL
DROP PROCEDURE ##XSP_PROCED;


CREATE PROCEDURE ##XSP_PROCED
@IN INT
AS
(
SELECT @IN * 30
)
GO


EXEC ##XSP_PROCED 100



CREATE TABLE #DIR (DIR VARCHAR(1000))

SELECT * FROM SYS.configurations


-- PROC TEMPORARIA RETORNANDO VALOR E SENDO USADO POSTERIORMENTE (* SEBASTIAO)
CREATE PROC ##P1
(@VALOR INT, @RETORNO INT OUTPUT)
AS
(
SELECT @RETORNO = @VALOR * 5
)

DECLARE @VL AS INT
EXEC ##P1 @VALOR=10, @RETORNO=@VL OUTPUT;

SELECT @VL + 1000



-- CMD_SHELL
sp_configure 'show advanced option', 1
RECONFIGURE

sp_configure 'xp_cmdshell',1
RECONFIGURE

SET NOCOUNT ON;


INSERT #DIR
EXEC xp_cmdshell 'dir d:\*.*';

SET NOCOUNT OFF;


SELECT * FROM #DIR

USE master;
GO
EXEC sp_configure 'xp_cmdshell', '1';
RECONFIGURE WITH OVERRIDE;

EXEC sys.xp_fixeddrives;
GO


EXEC sys.xp_dirtree 'D:\';
GO


SHUTDOWN











