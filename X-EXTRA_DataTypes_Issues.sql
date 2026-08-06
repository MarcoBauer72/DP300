
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
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'varchar50')
BEGIN
	CREATE TABLE dbo.varchar50
	(
	id int identity primary key
	,nome varchar(50)
)
    );
END;

declare @i int = 1
while @i < 500000
	begin
		insert dbo.varchar50 values ('teste')
		set @i =+ 1
	end

sp_spaceused 'dbo.varchar50'


IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'varchar1000')
BEGIN
	CREATE TABLE dbo.varchar1000
	(
	id int identity primary key
	,nome varchar(1000)
)
    );
END;

declare @i int = 1
while @i < 500000
	begin
		insert dbo.varchar1000 values ('teste')
		set @i =+ 1
	end

sp_spaceused 'dbo.varchar1000'


IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'varchar2000')
BEGIN
	CREATE TABLE dbo.varchar2000
	(
	id int identity primary key
	,nome varchar(2000)
)
    );
END;

declare @i int = 1
while @i < 500000
	begin
		insert dbo.varchar2000 values ('teste')
		set @i =+ 1
	end

sp_spaceused 'dbo.varchar2000'


-------------------------------------------------------------------------------------
--- Em um SQL PaaS criar uma tabela com muitos VARCHAR e outra tabela apartada porem
--- mesmo schema porem tudo NVARCHAR e comparar tamanho e desempenho
-------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'varchartodos')
BEGIN
	CREATE TABLE dbo.varchartodos
	(
	id int identity primary key
	,nome varchar(200)
)
    );
END;

declare @i int = 1
while @i < 500000
	begin
		insert dbo.varchartodos values ('teste')
		set @i =+ 1
	end



IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'nvarchartodos')
BEGIN
	CREATE TABLE dbo.nvarchartodos
	(
	id int identity primary key
	,nome nvarchar(200)
)
    );
END;

declare @i int = 1
while @i < 500000
	begin
		insert dbo.nvarchartodos values ('teste')
		set @i =+ 1
	end
