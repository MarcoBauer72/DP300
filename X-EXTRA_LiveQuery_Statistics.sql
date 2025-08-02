/*----------------------------------------------------------------- */
/*                                                                  */
/* ----------------  EXTRA - Live Query Statistics  --------------- */
/*                                                                  */
/*----------------------------------------------------------------- */

SQL Server Management Studio fornece a capacidade de exibir o plano de execução ao vivo de 
uma consulta ativa. Esse plano de consulta dinâmica fornece informações em tempo real sobre
o processo de execução da consulta, conforme os controles fluem de um operador de plano de 
consulta para outro. O plano de consulta ao vivo exibe o progresso geral da consulta e as 
estatísticas de tempo de execução do nível de operador, como o número de linhas produzido, 
tempo decorrido, progresso do operador, etc. Como esses dados estão disponíveis em tempo real 
sem a necessidade de aguardar a conclusão da consulta, essas estatísticas de execução são 
extremamente úteis para depurar problemas de desempenho de consulta. Este recurso está 
disponível do SQL Server 2016 Management Studioem diante; no entanto, ele pode funcionar 
com o SQL Server 2014.

Aplica-se a: SQL Server ( SQL Server 2014 a SQL Server 2017).


!!! Warning !!!
Este recurso é usado principalmente para a solução de problemas. 
O uso desse recurso pode diminuir moderadamente o desempenho geral da consulta. 
Esse recurso pode ser usado com o Depurador Transact-SQL.


-- Live Query Stats
-- Turn on LQS in SSMS before running this query
USE AdventureWorks2016
GO

DBCC FREEPROCCACHE
DBCC TRACEON (9481)

SELECT e.[BusinessEntityID],
       p.[Title],
       p.[FirstName],
       p.[MiddleName],
       p.[LastName],
       p.[Suffix],
       e.[JobTitle],
       pp.[PhoneNumber],
       pnt.[Name] AS [PhoneNumberType],
       ea.[EmailAddress],
       p.[EmailPromotion],
       a.[AddressLine1],
       a.[AddressLine2],
       a.[City],
       sp.[Name] AS [StateProvinceName],
       a.[PostalCode],
       cr.[Name] AS [CountryRegionName],
       p.[AdditionalContactInfo]
FROM   [HumanResources].[Employee] AS e
INNER JOIN [Person].[Person] AS p
       ON RTRIM(LTRIM(p.[BusinessEntityID])) = RTRIM(LTRIM(e.[BusinessEntityID]))
INNER JOIN [Person].[BusinessEntityAddress] AS bea
       ON RTRIM(LTRIM(bea.[BusinessEntityID])) = RTRIM(LTRIM(e.[BusinessEntityID]))
INNER JOIN [Person].[Address] AS a
       ON RTRIM(LTRIM(a.[AddressID])) = RTRIM(LTRIM(bea.[AddressID]))
INNER JOIN [Person].[StateProvince] AS sp
       ON RTRIM(LTRIM(sp.[StateProvinceID])) = RTRIM(LTRIM(a.[StateProvinceID]))
INNER JOIN [Person].[CountryRegion] AS cr
       ON RTRIM(LTRIM(cr.[CountryRegionCode])) = RTRIM(LTRIM(sp.[CountryRegionCode]))
LEFT OUTER JOIN [Person].[PersonPhone] AS pp
       ON RTRIM(LTRIM(pp.BusinessEntityID)) = RTRIM(LTRIM(p.[BusinessEntityID]))
LEFT OUTER JOIN [Person].[PhoneNumberType] AS pnt
       ON RTRIM(LTRIM(pp.[PhoneNumberTypeID])) = RTRIM(LTRIM(pnt.[PhoneNumberTypeID]))
LEFT OUTER JOIN [Person].[EmailAddress] AS ea
       ON RTRIM(LTRIM(p.[BusinessEntityID])) = RTRIM(LTRIM(ea.[BusinessEntityID]))
GO



--O plano de execução ao vivo também pode ser acessado pelo Activity Monitor clicando com 
--O botão direito nas consultas, na guia Active Expensive Queries.


Referencias:
https://docs.microsoft.com/pt-br/sql/relational-databases/performance/live-query-statistics
https://blogs.technet.microsoft.com/cansql/2017/02/28/live-query-statistics-in-sql-server-2016/


