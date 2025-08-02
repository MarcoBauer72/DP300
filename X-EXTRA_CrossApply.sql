----- Modulo 12: Using Set Operators
USE Adventureworks
GO


BEGIN TRY

	CREATE TABLE NOMES
	(
	    ID INT
		,NAME VARCHAR(50)
	)
END TRY
BEGIN CATCH
    TRUNCATE TABLE NOMES
END CATCH


INSERT INTO NOMES (ID,NAME) VALUES (1,'Ana'),(2,'Augusto'),(3,'Alberto')
GO



BEGIN TRY
	CREATE TABLE NOMES_ID
	(
	 ID INT 
	,NOME VARCHAR(50) 
	)
END TRY
BEGIN CATCH
	TRUNCATE TABLE NOMES_ID
END CATCH

INSERT INTO NOMES_ID VALUES (1,'Ana'),(4,'Joao'),(5,'Maria')
GO


BEGIN TRY
	CREATE TABLE NOMES_SOBRENOME
	(
	 ID INT 
	,PRIMEIRONOME VARCHAR(50) 
	,SOBRENOME VARCHAR(100)
	)
END TRY
BEGIN CATCH
	TRUNCATE TABLE NOMES_SOBRENOME
END CATCH

INSERT NOMES_SOBRENOME (ID,PRIMEIRONOME) VALUES (1,'Pedro'),(2,'Rita'),(3,'Alberto'),(4,'Ana')
GO


SELECT  * FROM NOMES
SELECT * FROM NOMES_ID

SELECT * FROM NOMES_SOBRENOME


-- UNION  (Retorna todas as linhas de ambas porém sem repeticao caso exista nas duas)
SELECT -1,NAME FROM NOMES
UNION 
SELECT ID, NOME FROM NOMES_ID



UNION
SELECT * FROM NOMES_SOBRENOME



-- UNION ALL (Retorna todas as linhas de ambas as tabelas)
SELECT NAME FROM NOMES
UNION 
SELECT NOME FROM NOMES_ID

SELECT NAME FROM NOMES
UNION ALL 
SELECT NOME FROM NOMES_ID




UNION ALL
SELECT PRIMEIRONOME FROM NOMES_SOBRENOME

-- UNION ALL
-- SELECT PRIMEIRONOME FROM NOMES_SOBRENOME




-- INTERSECT                              (Retorna valores comuns as duas consultas)
SELECT NAME FROM Nomes
INTERSECT
SELECT NOME FROM Nomes_ID


SELECT NAME FROM Nomes AS T1
INNER JOIN Nomes_ID AS T2
ON T1.ID = T2.ID


INTERSECT
SELECT PRIMEIRONOME FROM NOMES_SOBRENOME





-- EXCEPT (Retorna valores que existam na consulta da esquerda porem nao existam na consulta da direita)
SELECT * FROM Nomes
EXCEPT
SELECT * FROM Nomes_ID

SELECT * FROM dbo.NOMES AS N1
WHERE N1.ID NOT IN 
	(
		SELECT N2.ID FROM NOMES_ID AS N2
	)



EXCEPT
SELECT PRIMEIRONOME FROM NOMES_SOBRENOME



------------------------------ Usando APPLY ------------------------------
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

[shippeddate]
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
	ORDER BY shippeddate DESC 
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




SELECT * FROM Sales.Orders WHERE 
--------------------------------------------------------------------------------------------------
-- Neste exemplo de APPLY, vemos as 20 querys que estão requisitando mais disco:
--------------------------------------------------------------------------------------------------

SELECT TOP 10 SUBSTRING(qt.TEXT, (qs.statement_start_offset / 2) + 1, (
			(
				CASE qs.statement_end_offset
					WHEN - 1
						THEN DATALENGTH(qt.TEXT)
					ELSE qs.statement_end_offset
					END - qs.statement_start_offset
				) / 2
			) + 1) AS TOMATE
	,qs.execution_count
	,qs.total_logical_reads
	,qs.last_logical_reads
	,qs.min_logical_reads
	,qs.max_logical_reads
	,qs.total_elapsed_time
	,qs.last_elapsed_time
	,qs.min_elapsed_time
	,qs.max_elapsed_time
	,qs.last_execution_time
	,qp.query_plan
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
WHERE qt.encrypted = 0
ORDER BY qs.total_logical_reads DESC



--qs.total_logical_reads DESC


-- Lab. 12 - Pg.83_Part2 ou Pg.407_Part2
-- Página 431 ou 755 (PDF)
-- Exercícios 1,2 e 3 - 60 minutos

