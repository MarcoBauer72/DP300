CREATE DATABASE AdventureWorksLT_20210905
ON
(
NAME = AdventureWorksLT2008_Data,
FILENAME = 'D:\Databases\Snapshots\AdventureWorksLT_20210905.dss'
)
AS SNAPSHOT OF [AdventureWorksLT]



-- Referencias: 
https://docs.microsoft.com/pt-br/sql/relational-databases/databases/create-a-database-snapshot-transact-sql?view=sql-server-ver15
https://www.youtube.com/watch?v=-_Z86T-0qqk