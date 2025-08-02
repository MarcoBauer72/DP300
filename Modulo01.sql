------------------------ DP300 - MODULO 01 -------------------------
legalzao
/* ----------------------------------------------------------- */
/* Lab.0 - Azure Storage Account (Blob, File, Table and Queue) */
/* ----------------------------------------------------------- */


----- SETUP INICIAL -----
https://microsoftlearning.github.io/dp-300-database-administrator/Instructions/Labs/00-setup-environment.html

     
---- Modulo 1: Introduction to Microsoft SQL Server 2016

/*

1) Execucao do SQL SERVER MANAGEMENT STUDIO.

2) Criacao de Solution e Projects.

3) Results como GRID, TEXT e FILE (CTRL+D, CTRL+T e CTRL+SHIFT+F)

4) F5 e CTRL-F5 (Parse).

5) IntelliSense (Tools -> Options -> expand Text Editor -> expand Transact-SQL -> IntelliSense).

6) Numeracao Linhas (Tools -> Expand Text Editor -> Transact SQL -> Line Numbers (checkbox).

7) BOOKMARKS: CTRL K + CTRL K, CTRL K + CTRL N, CTRL K + CTRL P, CTRL K + CTRL L

8) CRIAR DATABASE: CREATE DATABASE DP300

9) TOOLS -> OPTIONS -> TEXT EDITOR -> TRANSACT SQL -> LINE NUMBERS (CHECKBOX)

10) FULL SCREEN: SHIFT+ALT+ENTER (Prioriza/Aumenta janela de codigo)

11) HIDDING RESULT SET: CTRL+R

/*

------------------------- DESAFIO --------------------------
-- FactInternetSales
 ProductStandardCost AS 'Custo Unitario'
,SalesAmount AS 'Total Vendido'
,OrderDate AS 'Data Venda'

-- DimProduct
,EnglishProductName AS 'Nome Produto'


-- DimProductSubcategory
,EnglishProductSubcategoryName AS Subcategoria


-- DimProductCategory
,EnglishProductCategoryName AS Categoria


-- Ordernado Ascendente por Categoria, Subcategoria, Nome do Produto, Data Venda
------------------------------------------------------------


/* --- Azure Storage Tutorial | Introduction to Blob, Queue, Table & File Share --- */ 
https://www.youtube.com/watch?v=UzTtastcBsk

/* --- Blob Storage : To Store Text and Binary Data --- */  -- (16'20'')
-- 1) Serving images or docs directly to a browser
-- 2) Streaming video and audio
-- 3) Storing data for Backup and Restore
-- 4) Disaster Recovert
-- 5) Archiving
-- * Hot : Frequent Access / Cool : Large amounts of data infrequently access at least 30 days / Archive : Can tolerate several hours of latency

/* -- File Storage -- */ -- (19'30'')
-- 1) Main goal is sharing files via SMB (Server Message Block)

/* -- Table Storage -- */ -- (20'35'')
-- 1) No SQL Data
-- 2) No table constrains (no relationships between the tables)

/* -- Queue Storage -- */ -- (21'40'')
-- 1) Assyncronous messaging objects

/* Extra: --- File Share --- */
-- by SMB (Server Message Block)
-- by HTTP (FileREST)
-- For "Lift" and "Shift" applications
-- 1) Create Storage Account
-- 2) Create New File Share inside the Storage Account
https://www.youtube.com/watch?reload=9&v=BCzeb0IAy2k


/* --- Azure Files SMB Access with Windows AD --- */
https://www.youtube.com/watch?v=Vm5QXbRPoKI


/* --------------------------------------------------------------- */
/* Lab 1 - Using the Azure Portal and SQL Server Management Studio */
/* --------------------------------------------------------------- */

-- Interact with the Azure portal
-- Create a SQL Server Virtual Machine
-- Use SQL Server Management Studio to restore a database


----- Exercise 1: Provision a SQL Server on an Azure Virtual Machine -----
-- 1) Explore the Azure Portal and locate important functionality.
-- 2) Create a SQL Server on an Azure Virtual Machine using the Azure Portal.
https://microsoftlearning.github.io/dp-300-database-administrator/Instructions/Labs/01-provision-sql-vm.html



----- Exercise 2: Connect to SQL Server and Restore a Backup -----
-- 1) Create an RDP (Remote Desktop Protocol) connection to SQL Server on an Azure Virtual Machine
-- 2) Download a database backup file.
-- 3) Restore the database in SQL Server using SQL Server Management Studio
-- 4) Query the database to confirm its availability
https://microsoftlearning.github.io/dp-300-database-administrator/Instructions/Labs/01-provision-sql-vm.html



/* ----- Clean Up ----- */
-- 1) Exit out of the Remote Desktop.
-- 2) Remove the VM you created in this lab to save costs. You will not be using it for subsequent labs.
-- 3) Navigate to the main (Overview) blade for the dp300sqlvmlab01 Virtual Machine and click the delete button in the menu.


/* ----- Referencias ----- */
-- Labs of the course DP300
https://aka.ms/dp300-labs

-- Public preview – Visible either in the portal, or at 
https://azure.microsoft.com/en-us/updates/

-- Frequently asked questions for SQL Server running on Windows virtual machines in Azure:
https://docs.microsoft.com/en-us/azure/virtual-machines/windows/sql/virtual-machines-windows-sql-server-iaas-faq

-- What is Azure SQL Database managed instance?
https://docs.microsoft.com/en-us/azure/sql-database/sql-database-managed-instance

-- What is the Azure SQL Database service?
https://docs.microsoft.com/en-us/azure/sql-database/sql-database-technical-overview