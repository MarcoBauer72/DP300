/*--------------------------------------------------------- */
/*                                                          */
/* -----------------  ColumnStore - Demo1  ---------------- */
/*                                                          */
/*--------------------------------------------------------- */

-	Colunas de uma mesma tabela são armazendas independente das outras colunas
	e como todos os valores de uma mesma coluna possuem o mesmo datatype então pode-se
	otimizar a compressão dos dados na coluna (em média 10 vezes mais compressão).

-	Executando uma consulta para retornar menos colunas e uma faixa de linhas o
	uso de "I/O" pode ser reduzido em 60%.

-	Recomendado para tabelas grandes com milhões de linhas enquanto os índices
	tradicionais por linha (rowstore) para tabela com menos de 1 milhão de linhas.

-	Ideal para cargas de DataWarehouse em grandes tabelas FATO e DIMENSÕES.

-	As linhas de uma tabela são armazenadas em porções "chunck" de dados, chamados
	de "rowgroup". (Ex.: 1 tabela de 100 milhões de linhas é "quebrada" em 100
	"rowgroups" de 1 milhão de linhas cada). 

-	Cada coluna do mesmo "rowgroup" é chamada de "segment".

-	USE clustered columnstore index em tabelas fatos e dimensoes grandes do DW.

-	USE non-clustered columstore index para análise em tempo real nos sistemas OLTP.

INDEX ROW (FILTRAR TABELA, TRAZER AMOSTRAGEM, SEEK PREDICATE) * SQL D.PEDRO
INDEX COLUMN STORE (TABELA MAIOR QUE 1 MILHAO DE LINHAS. LER TODAS OU MAIS QUE
50% DA TABELA E APLICAR FUNCOES DE AGREGAÇÃO: SUM(),AVG(),COUNT(),MIN(),MAX())

-- (Column_Store.jpg)

-	Melhorias ColumnStore no SQL2016:

	Índice clustered columnstore suporta outros índicies por linha, PKs and FKs.

	Índice noncluster columnstore suporta Update.

	Índice noncluster columnstore suporta filtro condicional.

	Melhor desempenho dos operadores de Sort, Window Aggregates e outros (Batch mode).

	Melhor desemepenho nas operações de agregação (Aggregate pushdown).

	Melhor eficiencia de processamento de predicados de uma consulta.

	Índices Btree (NCI) adicionais para procura mais eficiente de PK/FK. 
	* Possível criar índice colunar clusterizado em tabela não clusterizada.

	-- SUM, AVG, COUNT, MIN, MAX (FUNCOES DE AGREGACAO REGULARES)


ColumnStored index:

SQL 2012
--------

-> NonClustered index (tabela passa a ser readonly). Pode se escolher as colunas para o índice.
   HINT: IGNORE_NONCLUSTERED_COLUMNSTORE_INDEX
   
   
SQL 2014
--------

-> NonClustered tabela readonly porém podendo combinar com rowindex. Para alterar dados da tabela somente rebuild index ou
   switch partition
   
-> Clustered columnstore (tabela updateable). Apenas versão Enterprise, Developer e Evaluation. Não pode co-existir com rowindex.

-> Dados da mesma coluna podem ser até 7x mais comprimidas


SQL 2016
--------

-> NonClustered tabela updateable porém podendo combinar com rowindex. 
   
-> Clustered columnstore (tabela updateable). Apenas versão Enterprise, Developer e Evaluation. 
   Não pode co-existir com rowindex.

-> Dados da mesma coluna podem ser até 10x mais comprimidas

-> Podendo combinar os recursos Columnstore e InMemory no mesmo objeto do banco de dados.

	
Referencias:
https://msdn.microsoft.com/en-us/library/gg492088.aspx
https://blogs.technet.microsoft.com/dataplatforminsider/2015/12/10/speeding-up-transactions-with-in-memory-oltp-in-sql-server-2016-and-azure-sql-database/
http://social.technet.microsoft.com/wiki/contents/articles/9251.entendendo-o-column-store-index-no-sql-server-2012-pt-br.aspx


Videos:
https://www.youtube.com/watch?v=EB0MzVdc-ZI
https://www.youtube.com/watch?v=QIqZSuERvQ0
https://www.youtube.com/watch?v=5FY240SUz18


/*--------------------------------------------------------- */
/*                                                          */
/* -----------------  ColumnStore - Demo   ---------------- */
/*                                                          */
/*--------------------------------------------------------- */

--	NOTA: Necessario baixar e restaurar o banco de dados Adventureworks2016CTP3:
	https://www.microsoft.com/en-us/download/details.aspx?id=49502

USE AdventureworksDW2016
GO

/*************************************************************************************
STEP 1 - Space comparison between CCI and PAGE compressed table
*************************************************************************************/
-- How about space? Data space is much smaller. One key point to note is that PAGE compression can 
-- compress 2-4x. The difference is less as we have a Primary Key on the table that creates a Unique Non-clustered index
-- The actual data compression savings will depend upon the data and the schema
sp_spaceused


sp_spaceused 'FactResellerSalesXL_CCI' -- A PARTIR SQL2012
GO
sp_spaceused 'FactResellerSalesXL_PageCompressed' -- ATEH SQL2008
GO

-- Validate that both tables have the same amount of rows
SELECT count(1) as CCITableCount
FROM FactResellerSalesXL_CCI
GO
SELECT count(1) as PageCompressedTableCount
FROM FactResellerSalesXL_PageCompressed
GO

-- You can query the following DMV 
--to show that most data in CCI is compressed
SELECT *
FROM sys.dm_db_column_store_row_group_physical_stats
WHERE object_id = object_id('FactResellerSalesXL_CCI')

/*********************************************************************
Step 2 -- Overview
-- Page Compressed BTree table v/s Columnstore table performance differences
-- Enable actual Query Plan in order to see Plan differences when Executing
*************************************************************************************/

USE AdventureworksDW2016
GO

-- Ensure Database is in 130 compatibility mode
ALTER DATABASE AdventureworksDW2016 SET compatibility_level = 130
GO
DBCC DROPCLEANBUFFERS
GO

-- Execute a typical query that joins the Fact Table with dimension tables
-- Note this query will run on the Page Compressed table, Note down the time
SET STATISTICS IO ON
SET STATISTICS TIME ON
GO

-- ROW INDEX (POR LINHA)
CREATE CLUSTERED INDEX CIX_PESSOAS_CPF ON TABELA_PESSOAS
(CPF)
CREATE NONCLUSTERED INDEX CIX_PESSOAS_CPF ON TABELA_PESSOAS
(CPF)


-- COLUMNSTORE INDEX (COLUNAR)
CREATE CLUSTERED COLUMNSTORE INDEX CCI_PESSOAS ON TABELA_PESSOAS

CREATE NONCLUSTERED COLUMNSTORE INDEX CCI_PESSOAS ON TABELA_PESSOAS
(C1,C3,C6,C9)




SET STATISTICS IO ON
SET STATISTICS TIME ON
GO

SELECT c.CalendarYear
	,b.SalesTerritoryRegion
	,FirstName + ' ' + LastName AS FullName
	,count(SalesOrderNumber) AS NumSales
	,sum(SalesAmount) AS TotalSalesAmt
	,Avg(SalesAmount) AS AvgSalesAmt
	,count(DISTINCT SalesOrderNumber) AS NumOrders
	,count(DISTINCT ResellerKey) AS NumResellers
FROM [dbo].FactResellerSalesXL_CCI a
INNER JOIN DimSalesTerritory b ON b.SalesTerritoryKey = a.SalesTerritoryKey
INNER JOIN DimEmployee d ON d.Employeekey = a.EmployeeKey
INNER JOIN DimDate c ON c.DateKey = a.OrderDateKey
WHERE b.SalesTerritoryKey = 3
	AND c.FullDateAlternateKey BETWEEN '1/1/2006'
		AND '1/1/2010'
GROUP BY b.SalesTerritoryRegion
	,d.EmployeeKey
	,d.FirstName
	,d.LastName
	,c.CalendarYear
GO






SET STATISTICS IO OFF
SET STATISTICS TIME OFF
GO

-- This is the same Prior query on a table with a Clustered Columnstore index CCI 
-- The comparison numbers are even more dramatic the larger the table is, this is a 11 million row table only.
SET STATISTICS IO ON
SET STATISTICS TIME ON
GO

SELECT b.SalesTerritoryRegion
	,FirstName + ' ' + LastName AS FullName
	,count(SalesOrderNumber) AS NumSales
	,sum(SalesAmount) AS TotalSalesAmt
	,Avg(SalesAmount) AS AvgSalesAmt
	,count(DISTINCT SalesOrderNumber) AS NumOrders
	,count(DISTINCT ResellerKey) AS NumResellers
FROM FactResellerSalesXL_CCI a
INNER JOIN DimSalesTerritory b ON b.SalesTerritoryKey = a.SalesTerritoryKey
INNER JOIN DimEmployee d ON d.Employeekey = a.EmployeeKey
INNER JOIN DimDate c ON c.DateKey = a.OrderDateKey
WHERE b.SalesTerritoryKey = 3
	AND c.FullDateAlternateKey BETWEEN '1/1/2006' AND '1/1/2010'
GROUP BY b.SalesTerritoryRegion,d.EmployeeKey,d.FirstName,d.LastName,c.CalendarYear
GO

SET STATISTICS IO OFF
SET STATISTICS TIME OFF
GO