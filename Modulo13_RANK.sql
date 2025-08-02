----- Modulo 13: Using Window Ranking, Offset, and Aggregate Functions

USE Adventureworks
GO

SELECT COUNT(*) FROM Production.Product
-- 504 ROWS

-- WHERE
SELECT 
	 P.Name AS PRODUTO
	,P.ListPrice
	,P.ProductSubcategoryID
	,PSC.Name AS SUBCATEGORIA
FROM Production.Product AS P
INNER JOIN Production.ProductSubcategory AS PSC
ON P.ProductSubcategoryID = PSC.ProductSubcategoryID
WHERE P.ProductSubcategoryID IS NOT NULL

SELECT COUNT(*) FROM Production.Product
WHERE ProductSubcategoryID IS NULL --209

SELECT COUNT(*) FROM Production.Product
WHERE ProductSubcategoryID IS NOT NULL--295

--SELECT * FROM Production.Product WHERE ProductSubcategoryID IS NULL



SELECT
	 DENSE_RANK() OVER (PARTITION BY PSC.Name ORDER BY P.ListPrice DESC) AS NUMERACAO
	,PSC.Name AS SUBCATEGORIA
	,P.Name AS PRODUTO
	,P.ListPrice
	,P.ProductSubcategoryID
FROM Production.Product AS P
JOIN Production.ProductSubCategory  AS PSC
ON P.ProductSubCategoryID = PSC.ProductSubCategoryID
ORDER BY SUBCATEGORIA, P.ListPrice DESC





-- ROW NUMBER
-- Retorna o número sequencial de uma linha em uma partição de um conjunto de resultados, iniciando em 1 para a primeira linha de cada partição. 

-- SEM PARTITION
SELECT
	-- ROW_NUMBER() OVER (ORDER BY P.ListPrice DESC) AS NUMERACAO
	 NTILE(30) OVER(ORDER BY P.ListPrice ASC) AS NUMERACAO 
	 ,P.PRODUCTID
	,P.Name AS PRODUTO
	,P.ListPrice
	,P.ProductSubcategoryID
	,PSC.Name AS SUBCATEGORIA
FROM Production.Product P
JOIN Production.ProductSubCategory PSC
ON P.ProductSubCategoryID = PSC.ProductSubCategoryID





--PARTITION BY P.ListPrice
SELECT
	 ROW_NUMBER() OVER(PARTITION BY PSC.Name ORDER BY  P.ListPrice DESC)
	 AS NUMERACAO
	,P.ProductSubcategoryID AS SubCatID
	,p.ProductID 
	,P.Name AS PRODUTO
	,P.ListPrice
	,PSC.Name AS SUBCATEGORIA
FROM Production.Product P
JOIN Production.ProductSubCategory PSC
ON P.ProductSubCategoryID = PSC.ProductSubCategoryID
--WHERE  psc.Name = 'Handlebars'


--PARTITION BY PSC.Name





-- RANK E DENSE RANK
-- Retorna a classificação de cada linha na partição de um conjunto de resultados
-- A classificação de uma linha é um mais o número de classificações que vêm antes da linha em questão.

-- SEM PARTITION
SELECT 
	 NTILE(2) OVER(PARTITION BY PSC.NAME ORDER BY P.ListPrice DESC) --AS PrecoRanking
	-- ,ROW_NUMBER() OVER(ORDER BY P.ListPrice DESC) AS PrecoRanking
	,PSC.Name AS SUBCATEGORIA
	,P.ProductID
	,P.Name AS PRODUTO
	,P.ListPrice
	,P.ProductSubcategoryID

FROM Production.Product P
JOIN Production.ProductSubCategory PSC
ON P.ProductSubCategoryID = PSC.ProductSubCategoryID
--WHERE psc.Name = 'Handlebars'

--PARTITION BY PSC.NAME 



-- COM PARTITION
SELECT 
P.Name Product, 
P.ListPrice, 
PSC.Name Category,
RANK() OVER(ORDER BY P.ListPrice DESC)
AS PriceRank
FROM Production.Product P
JOIN Production.ProductSubCategory PSC
ON P.ProductSubCategoryID = PSC.ProductSubCategoryID

--
-- DENSE RANK
-- Retorna a classificação de linhas dentro da partição de um conjunto de resultados.
-- Sem qualquer lacuna na classificação.
SELECT 
P.Name Product, 
P.ListPrice, 
PSC.Name Category,
dense_rank() OVER(PARTITION BY PSC.Name
ORDER BY P.ListPrice)
AS PriceRank
FROM Production.Product P
JOIN Production.ProductSubCategory PSC
ON P.ProductSubCategoryID = PSC.ProductSubCategoryID
--WHERE psc.Name = 'Handlebars'



-- NTILE
-- Distribui as linhas de uma partição ordenada em um número de grupos especificado
SELECT 
P.Name Product
,P.ListPrice
,PSC.Name Category
,ROW_NUMBER()  OVER  (PARTITION BY PSC.NAME ORDER BY P.ListPrice DESC) AS SUBGRUPO
,COUNT(P.ProductID) OVER (PARTITION BY PSC.NAME) AS totalproducts
,SUM(P.ListPrice) OVER (PARTITION BY PSC.NAME) AS totalpersubcategory
,MIN(P.ListPrice) OVER (PARTITION BY PSC.NAME) AS PriceMin
,MAX(P.ListPrice) OVER (PARTITION BY PSC.NAME) AS PriceMax
,AVG(P.ListPrice) OVER (PARTITION BY PSC.NAME) AS PriceAVG
FROM Production.Product P
JOIN Production.ProductSubCategory PSC
ON P.ProductSubCategoryID = PSC.ProductSubCategoryID
--WHERE psc.Name = 'Handlebars'


--PARTITION BY PSC.Name 


SELECT  custid,
        ordermonth,
        qty,
        COUNT(qty) OVER ( PARTITION BY custid ) AS totalpercust
FROM    Sales.CustOrders ;

USE TSQL
GO

IF OBJECT_ID('Production.CategorizedProducts','V') IS NOT NULL DROP VIEW Production.CategorizedProducts
GO
CREATE VIEW Production.CategorizedProducts
AS
    SELECT  Production.Categories.categoryid AS CatID,
			Production.Categories.categoryname AS CatName,
            Production.Products.productname AS ProdName,
            Production.Products.unitprice AS UnitPrice
    FROM    Production.Categories
            INNER JOIN Production.Products ON Production.Categories.categoryid=Production.Products.categoryid;
GO


IF OBJECT_ID('Sales.CategoryQtyYear','V') IS NOT NULL DROP VIEW Sales.CategoryQtyYear
GO
CREATE VIEW Sales.CategoryQtyYear
AS
SELECT  c.categoryname AS Category,
        SUM(od.qty) AS Qty,
        YEAR(o.orderdate) AS Orderyear
FROM    Production.Categories AS c
        INNER JOIN Production.Products AS p ON c.categoryid=p.categoryid
        INNER JOIN Sales.OrderDetails AS od ON p.productid=od.productid
        INNER JOIN Sales.Orders AS o ON od.orderid=o.orderid
GROUP BY c.categoryname, YEAR(o.orderdate);
GO

-- Step 3: Using OVER with ordering
-- Rank products by price from high to low
SELECT CatID, CatName, ProdName, UnitPrice,
	RANK() OVER(ORDER BY UnitPrice DESC) AS PriceRank
FROM Production.CategorizedProducts
ORDER BY PriceRank; 

-- Rank products by price in descending order in each category.
-- Note the ties.
SELECT CatID, CatName, ProdName, UnitPrice,
	RANK() OVER(PARTITION BY CatID ORDER BY UnitPrice DESC) AS PriceRank
FROM Production.CategorizedProducts
ORDER BY CatID; 

-- Step 4: Use framing to create running total
-- Display a running total of quantity per product category. 
-- This uses framing to set boundaries at the start
-- of the set and the current row, for each partition
SELECT * FROM Sales.CategoryQtyYear;


SELECT Category, Qty, Orderyear,
	SUM(Qty) OVER (
		PARTITION BY category
		ORDER BY orderyear
		ROWS BETWEEN UNBOUNDED PRECEDING
		AND CURRENT ROW) AS RunningQty
FROM Sales.CategoryQtyYear;


-- Display a running total of quantity per year. 
SELECT Category, Qty, Orderyear,
	SUM(Qty) OVER (
		PARTITION BY orderyear
		ORDER BY Category
		ROWS BETWEEN UNBOUNDED PRECEDING
		AND CURRENT ROW) AS RunningQty
FROM Sales.CategoryQtyYear;

-- Show both side-by-side per category and per-year

SELECT Category, Qty, Orderyear,
	SUM(Qty) OVER (PARTITION BY orderyear ORDER BY Category	ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RunningTotalByYear,
	SUM(Qty) OVER (PARTITION BY Category ORDER BY OrderYear	ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RunningTotalByCategory
FROM Sales.CategoryQtyYear
ORDER BY Orderyear, Category;

-- Step 5: Clean up
IF OBJECT_ID('Production.CategorizedProducts','V') IS NOT NULL DROP VIEW Production.CategorizedProducts
IF OBJECT_ID('Sales.CategoryQtyYear','V') IS NOT NULL DROP VIEW Sales.CategoryQtyYear
GO

-- Step 2: Setup views for demo
IF OBJECT_ID('Production.CategorizedProducts','V') IS NOT NULL DROP VIEW Production.CategorizedProducts
GO
CREATE VIEW Production.CategorizedProducts
AS
    SELECT  Production.Categories.categoryid AS CatID,
			Production.Categories.categoryname AS CatName,
            Production.Products.productname AS ProdName,
            Production.Products.unitprice AS UnitPrice
    FROM    Production.Categories
            INNER JOIN Production.Products ON Production.Categories.categoryid=Production.Products.categoryid;
GO
IF OBJECT_ID('Sales.CategoryQtyYear','V') IS NOT NULL DROP VIEW Sales.CategoryQtyYear
GO
CREATE VIEW Sales.CategoryQtyYear
AS
SELECT  c.categoryname AS Category,
        SUM(od.qty) AS Qty,
        YEAR(o.orderdate) AS Orderyear
FROM    Production.Categories AS c
        INNER JOIN Production.Products AS p ON c.categoryid=p.categoryid
        INNER JOIN Sales.SalesOrderDetail AS od ON p.productid=od.productid
        INNER JOIN Sales.Orders AS o ON od.orderid=o.orderid
GROUP BY c.categoryname, YEAR(o.orderdate);
GO
IF OBJECT_ID('Sales.OrdersByEmployeeYear','V') IS NOT NULL DROP VIEW Sales.OrdersByEmployeeYear
GO
CREATE VIEW Sales.OrdersByEmployeeYear
AS
SELECT emp.empid AS employee, YEAR(ord.orderdate) AS orderyear, SUM(od.qty * od.unitprice) AS totalsales
FROM HR.Employees AS emp
	JOIN Sales.Orders AS ord ON emp.empid = ord.empid
	JOIN Sales.OrderDetails AS od ON ord.orderid = od.orderid
GROUP BY emp.empid, YEAR(ord.orderdate)
GO
-- Step 3: Using Window Aggregate Functions

-- RANK demo from Lesson 2 slide
SELECT  productid,
        productname,
        unitprice,
        DENSE_RANK() OVER ( ORDER BY unitprice DESC ) AS pricerank
FROM    Production.Products
ORDER BY pricerank ;

-- Step 4: Simple aggregate window function 
-- Show SUM computed per partition
-- Note: no need for ORDER BY within OVER() in this example
SELECT  custid,
        ordermonth,
        qty,
        COUNT(qty) OVER ( PARTITION BY custid ) AS totalpercust
FROM    Sales.CustOrders ;

-- Step 5: Side-by-side use of aggregate functions with OVER()
SELECT CatID, CatName, ProdName, UnitPrice,
	SUM(UnitPrice) OVER(PARTITION BY CatID) AS Total,
	AVG(UnitPrice) OVER(PARTITION BY CatID) AS Average,
	COUNT(UnitPrice) OVER(PARTITION BY CatID) AS ProdsPerCat
FROM Production.CategorizedProducts
ORDER BY CatID; 

-- Step 6: Compare RANK with DENSE_RANK to show treatment of ties
-- Note the gaps in RANK not present in DENSE_RANK
SELECT CatID, CatName, ProdName, UnitPrice,
	RANK() OVER(PARTITION BY CatID ORDER BY UnitPrice DESC) AS PriceRank,
	DENSE_RANK() OVER(PARTITION BY CatID ORDER BY UnitPrice DESC) AS DensePriceRank
FROM Production.CategorizedProducts
ORDER BY CatID; 

-- Step 7: Row_Number
SELECT CatID, CatName, ProdName, UnitPrice,
	ROW_NUMBER() OVER(PARTITION BY CatID ORDER BY UnitPrice DESC) AS RowNumber
FROM Production.CategorizedProducts
ORDER BY CatID; 

-- Step 8: NTILE to create 7 groups
SELECT CatID, CatName, ProdName, UnitPrice,
	NTILE(7) OVER(PARTITION BY CatID ORDER BY UnitPrice DESC) AS NT
FROM Production.CategorizedProducts
ORDER BY CatID, NT; 



-- Step 9: Offset Functions
-- LAG to compare one year's sales to last. 
-- Note partitioning by employee
SELECT employee, orderyear, totalsales AS currentsales
FROM Sales.OrdersByEmployeeYear
ORDER BY employee, orderyear;

SELECT employee, orderyear, totalsales AS currentsales
  -- LAG(totalsales,1,0) OVER (PARTITION BY employee  ORDER BY employee,orderyear) AS ANOANTERIOR
 -- ,LAG(totalsales,2,0) OVER (PARTITION BY employee ORDER BY employee,orderyear) AS ANOANTERIOR_ANTERIOR
--  ,(totalsales- LAG(totalsales,1,0) OVER (PARTITION BY employee  ORDER BY employee,orderyear)) as DIF
  FROM Sales.OrdersByEmployeeYear
ORDER BY employee, orderyear;
GO

--PARTITION BY employee 
WITH TESTE (A,B,C,D,E) AS
(
SELECT 
	   employee, orderyear, totalsales AS currentsales,
       LEAD(totalsales, 1,0) OVER (PARTITION BY employee ORDER BY orderyear) AS V2007
	  ,LEAD(totalsales, 2,0) OVER (PARTITION BY employee ORDER BY orderyear) AS V2008
  FROM Sales.OrdersByEmployeeYear
)
SELECT * FROM TESTE WHERE B = 2006
ORDER BY A, B

GO

SELECT employee, orderyear, totalsales AS currentsales,
      FIRST_VALUE(totalsales) OVER (PARTITION BY employee ORDER BY orderyear) AS previousyearsales
  FROM Sales.OrdersByEmployeeYear
ORDER BY employee, orderyear;
GO

SELECT employee, orderyear, totalsales AS currentsales,
      LAST_VALUE(totalsales) OVER (PARTITION BY employee ORDER BY employee) AS lastyearsales
  FROM Sales.OrdersByEmployeeYear
ORDER BY employee, orderyear;
GO

--Step 10: Use FIRST_VALUE to compare current row to first in partition
SELECT employee
      ,orderyear
      ,totalsales AS currentsales,
      (totalsales - LAG(totalsales,1,0) OVER (PARTITION BY employee ORDER BY orderyear)) AS salesdiffsincefirstyear
  FROM Sales.OrdersByEmployeeYear
ORDER BY employee, orderyear;
GO

-- Step 11: Clean up
IF OBJECT_ID('Production.CategorizedProducts','V') IS NOT NULL DROP VIEW Production.CategorizedProducts
IF OBJECT_ID('Sales.CategoryQtyYear','V') IS NOT NULL DROP VIEW Sales.CategoryQtyYear
IF OBJECT_ID('Sales.OrdersByEmployeeYear','V') IS NOT NULL DROP VIEW Sales.OrdersByEmployeeYear
GO



-- Lab. 13 - Página 466 ou 765 (PDF)
-- Exercícios 1,2 e 3 - 60 minutos
