
--------------------------------------------------------------------------------
--- Exemplo de aplicar CHAR(100) em uma coluna depois move-la para VARCHAR(100)
--------------------------------------------------------------------------------
CREATE DATABASE [types]
GO

USE [types]
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'charzao')
BEGIN
    CREATE TABLE [dbo].[charzao](
        [ID] INT IDENTITY(1,1) PRIMARY KEY,
        [Nome] CHAR(100)
    );
END;

declare @i int = 1
while @i < 500000
	begin
		insert dbo.charzao values ('teste')
		set @i =+ 1
	end

sp_spaceused 'dbo.charzao'


ALTER TABLE [dbo].[charzaoa]
ALTER COLUMN [Nome] VARCHAR(100);

sp_spaceused 'dbo.charzao'


--------------------------------------------------------------------------------
--- Exemplo de comparar coluna com VARCHAR(50)> VARCHAR(1000) e VARCHAR(2000)
--- e planos de execucao
--------------------------------------------------------------------------------
CREATE TABLE dbo.varchar50
(
id int identity primary key
,nome varchar(50)
)

CREATE TABLE dbo.varchar1000
(
id int identity primary key
,nome varchar(1000)
)

CREATE TABLE dbo.varchar2000
(
id int identity primary key
,nome varchar(2000)
)

-------------------------------------------------------------------------------------
--- Em um SQL PaaS criar uma tabela com muitos VARCHAR e outra tabela apartada porem
--- mesmo schema porem tudo NVARCHAR e comparar tamanho e desempenho
-------------------------------------------------------------------------------------
CREATE TABLE dbo.varchartodos


CREATE TABLE dbo.nvarchartodos