/*----------------------------------------------------------------- */
/*                                                                  */
/* ----------------------  EXTRA - SargAbility  ------------------- */
/*                                                                  */
/*----------------------------------------------------------------- */

--O termo SARG nada mais é que a coluna que você está utilizando como “predicate” na cláusula WHERE se ela 
--pode ser utilizada em uma operação de “Index Seek“.

--Já quando o nosso “predicate” não permite a operação de “Index Seek”, podemos dizer que estamos utilizando 
--um “predicate Non-Sargable” e consequentemente teremos um custo maior para execução da query.

USE [AdventureWorks2016]
GO

-- 1 -- Query contra o AdventureWorks (Retornar todos os funcionários com o nome "Paul")
SELECT B.FirstName,B.LastName,A.BirthDate
FROM HumanResources.Employee A
JOIN Person.Person B ON B.BusinessEntityID = A.BusinessEntityID
WHERE B.FirstName = 'Paul'
-- * Observando o plano de execução, podemos ver que o próprio SQL nos sugere a criação de um índice na coluna FirstName

-- 2 -- Criando o índice
CREATE INDEX IX_Person ON Person.Person
(FirstName) -- WITH(FILLFACTOR=90)
-- O custo da execução foi reduziu. O SQL deixou de fazer um “Index Scan” na tabela “Person.Person” 
-- para realizar um “Index Seek“

-- 3 -- “Non-Sargable“
-- Dependendo da consulta, a coluna “FirstName” pode deixar de ser Sargable, 
-- principalmente quando utilizamos funções ou utilizamos alguns operadores
SELECT B.FirstName,B.LastName,A.BirthDate
FROM HumanResources.Employee A
JOIN Person.Person B ON B.BusinessEntityID = A.BusinessEntityID
WHERE LEFT(B.FirstName,5) = 'Paul'
-- * Este eh um exemplo “Non-Sargable“. A função "LEFT" impossibilita o otimizador de consulta 
-- de utilizar o índice para fazer a operação de “Index Seek“.

-- 4 -- “BirthDate” da tabela “HumanResources.Employee“
-- Nessa segunda consulta vamos realizar um SELECT que vai nos retornar todos os funcionários nascidos em 1980. 
-- Para isso, vamos criar um índice na coluna “BirthDate” da tabela “HumanResources.Employee“.
CREATE INDEX IX1_Employee ON HumanResources.Employee
(BirthDate)
WITH(FILLFACTOR=90)

set statistics io on

SELECT B.FirstName,B.LastName,A.BirthDate
FROM HumanResources.Employee A
JOIN Person.Person B ON B.BusinessEntityID = A.BusinessEntityID
WHERE A.BirthDate BETWEEN '1980-01-01' AND '1980-12-31'

-- 5 -- Função YEAR()
-- Como tentativa de otimizacao poderiamos mudar o codigo acima para utilizar a função “Year“
SELECT B.FirstName,B.LastName,A.BirthDate
FROM HumanResources.Employee A
JOIN Person.Person B ON B.BusinessEntityID = A.BusinessEntityID
WHERE YEAR(A.BirthDate) = '1980'

-- * Nem sempre é ruim você “pagar”. Usar uma função vai ter um momento que a diferença 
-- no custo será tão irrelevante que não vai justificar o trabalho de modificar toda a query


-- 6 -- Conversao Implicita
-- Quando o SQL faz uma conversão implícita, o otimizador de consulta não consegue realizar
-- a operação de Index Seek, tornando ele um predicado non-sargable
CREATE INDEX IX1_Customer ON sales.Customer
(AccountNumber)
WITH (FILLFACTOR = 90)

SELECT b.FirstName,
       b.LastName,
       a.AccountNumber
FROM sales.Customer a
    JOIN Person.Person b
        ON b.BusinessEntityID = a.PersonID
WHERE a.AccountNumber = 'AW00029594';

-- Eh normal quando o desenvolvedor utiliza algum framework, 
-- até mesmo por costume colocar o parâmetro “N” no varchar. 
-- Quando fazemos isso estamos informando ao SQL que vamos trabalhar com o tipo de dados NVarchar

SELECT b.FirstName,
       b.LastName,
       a.AccountNumber
FROM sales.Customer a
    JOIN Person.Person b
        ON b.BusinessEntityID = a.PersonID
WHERE a.AccountNumber = N'AW00029594';


--CREATE TABLE ABC 
--( ID INT IDENTITY
--,NOME VARCHAR(100)
--,OBS NVARCHAR(100)
--)

--INSERT ABC (NOME,OBS) VALUES ('NAO ISSUE',N'???????')
--SELECT * FROM ABC

-- * O SQL gerou um “warning” informando que o otimizador de consulta teve que fazer uma conversão implícita e, 
-- por consequência, ele nem utilizou o índice que criamos na coluna “AccountNumber“
-- realizou um Index Scan no índice “IX_Customer_TerritoryID”.
-- Além disso, o custo de execução na CPU aumentou em praticamente 50%, 
-- então quando ocorre uma conversão implícita no predicado, temos um predicado non-sargable.


-- 7 -- Uso da clausula LIKE
SELECT b.firstname,
       a.AccountNumber
FROM sales.Customer a
    JOIN Person.Person b
        ON b.BusinessEntityID = a.PersonID
WHERE b.firstname COLLATE SQL_Latin1_General_CP1_CI_AS LIKE ('Paul%');

-- * Como foi utilizado no predicado FullName“%Paul%”, o otimizador de consulta não consegue efetuar 
-- uma operação de Index Seek no índice “IX02_Person”.

-- Se queremos somente o clientes que se chamamm Paulo, Paul ou Paula, 
-- podemos deixar essa consulta um pouco diferente, removendo o coringa “%” inicial, deixando apenas FullName LIKE “Paul%”

SELECT b.firstname,
       a.AccountNumber
FROM sales.Customer a
    JOIN Person.Person b
        ON b.BusinessEntityID = a.PersonID
WHERE b.firstname LIKE ('%Paul%');

-- * Agora o SQL conseguiu fazer uma operação de Index Seek utilizando o índice “IX02_Person”,
-- derrubando o mito de que o LIKE sempre fará com que o predicado seja Non-Sargable.



--------------- OTIMIZANDO  LIKE %TEXTO% ---------------
--CREATE DATABASE [10987]

USE [10987]
GO

DROP TABLE IF EXISTS COLAT_TEST

CREATE TABLE COLAT_TEST
(
 ID int IDENTITY PRIMARY KEY
,DATA datetime
,OBS varchar(50)
)

------- POPULA TABELA NOVA -----
INSERT COLAT_TEST
SELECT getdate(), REPLICATE('B',50)
GO 2
 
INSERT COLAT_TEST (DATA,OBS)
SELECT DATA,OBS
FROM COLAT_TEST
GO 2
 
SELECT COUNT(1) FROM COLAT_TEST

INSERT COLAT_TEST
SELECT getdate(),'INFORMATICA'

INSERT COLAT_TEST
SELECT getdate(),'CENTRO INFORMATICA DE TREINAMENTO'

INSERT COLAT_TEST
SELECT getdate(),'ESCOLA INFORMATICA'

SP_SPACEUSED 'COLAT_TEST'

COLAT_TEST	41943043            	3148488 KB	3135936 KB	11704 KB	848 KB

CREATE NONCLUSTERED INDEX IX_OBS ON COLAT_TEST (OBS) WITH (FILLFACTOR=90)

SP_SPACEUSED 'COLAT_TEST'

COLAT_TEST	41943043            	6117776 KB	3135936 KB	2980920 KB	920 KB


SET STATISTICS IO ON
SET STATISTICS TIME ON
-- + CTRL+M

SELECT *
FROM COLAT_TEST
WHERE OBS LIKE '%INFORMATICA%' -- 33''

----- NON-UNICODE -----
SELECT *
FROM COLAT_TEST
WHERE OBS COLLATE SQL_Latin1_General_CP1_CI_AS LIKE '%INFORMATICA%'   --- ATEH 8 VEZES MAIS PERFORMATICO DO QUE WINDOWS COLLATION


----- UNICODE SORT RULES -----
SELECT COUNT(1)
FROM COLAT_TEST
WHERE OBS COLLATE Latin1_General_CI_AS LIKE '%GREEN%'



-- Eh possivel melhor mais alem do uso da Collation SQL_Latin1_General_CP1_CI_AS ???



-- Talvez?












-- Possível!?!
















-- Sim, eh possivel !!!
























----- COLATION BIN EH CS_AS -----
SELECT *
FROM COLAT_TEST
WHERE OBS COLLATE Latin1_General_BIN2 LIKE '%INFORMATICA%' --- ATEH 10 VEZES MAIS PERFORMATICO DO QUE WINDOWS COLLATION



-- * A COLLATION BIN é Case Sentitive e Accent Sensitive
-- ** Se usar uma coluna Nvarchar ao inves de varchar, isso nao acontece. O tempo eh o mesmo

https://www.fabriciolima.net/blog/2017/02/06/video-melhorando-a-performance-de-uma-consulta-com-like-string-alterando-a-collation/
https://support.microsoft.com/en-us/help/322112/comparing-sql-collations-to-windows-collations