-- Creating thea database
USE master;
IF EXISTS (SELECT * FROM sys.sysdatabases WHERE name = 'DemoPartition')
	DROP DATABASE DemoPartition;
GO
CREATE DATABASE DemoPartition;
GO
ALTER DATABASE DemoPartition SET RECOVERY SIMPLE 
GO

CREATE TABLE VENDAS (ID INT)

-- Create filegroups
Use DemoPartition;
ALTER DATABASE DemoPartition ADD FILEGROUP FG0000
GO
ALTER DATABASE DemoPartition ADD FILE (NAME = F0000, FILENAME = 'D:\DP300\Demofiles\F0000.ndf', SIZE = 3MB, FILEGROWTH = 50%) TO FILEGROUP FG0000;
GO
ALTER DATABASE DemoPartition ADD FILEGROUP FG2016
GO
ALTER DATABASE DemoPartition ADD FILE (NAME = F2016, FILENAME = 'D:\DP300\Demofiles\F2016.ndf', SIZE = 3MB, FILEGROWTH = 50%) TO FILEGROUP FG2016;
GO
ALTER DATABASE DemoPartition ADD FILEGROUP FG2017
GO
ALTER DATABASE DemoPartition ADD FILE (NAME = F2017, FILENAME = 'D:\DP300\Demofiles\F2017.ndf', SIZE = 3MB, FILEGROWTH = 50%) TO FILEGROUP FG2017;
GO
ALTER DATABASE DemoPartition ADD FILEGROUP FG2018
GO
ALTER DATABASE DemoPartition ADD FILE (NAME = F2018, FILENAME = 'D:\DP300\Demofiles\F2018.ndf', SIZE = 3MB, FILEGROWTH = 50%) TO FILEGROUP FG2018;
GO

-- Create partition function and scheme
CREATE PARTITION FUNCTION PF (int) AS RANGE RIGHT FOR VALUES (20160101, 20170101, 20180101);
CREATE PARTITION SCHEME PS AS PARTITION PF TO (FG0000, FG2016, FG2017, FG2018);

-- Create a partitioned table
CREATE TABLE fact_table
 (datekey int, measure int)
ON PS(datekey);
GO

-- Insert old data into the partitioned table
INSERT fact_table VALUES (20000101, 100);
INSERT fact_table VALUES (20001231, 100);

INSERT fact_table VALUES (20010101, 100);
INSERT fact_table VALUES (20010403, 100);

INSERT fact_table VALUES (20150101, 100);
INSERT fact_table VALUES (20151231, 100);
GO

-- Insert 2016/2017 data into the partitioned table
INSERT fact_table VALUES (20160101, 328);
INSERT fact_table VALUES (20160403, 721);

INSERT fact_table VALUES (20170101, 13);
INSERT fact_table VALUES (20170706, 99);
GO

-- Insert Current Year 2018 data into the partitioned table
INSERT fact_table VALUES (20180101, 76);
INSERT fact_table VALUES (20180403, 450);
INSERT fact_table VALUES (20180706, 330);
INSERT fact_table VALUES (20181122, 1200);
INSERT fact_table VALUES (20180101, 73);
INSERT fact_table VALUES (20180403, 420);
INSERT fact_table VALUES (20180706, 310);
INSERT fact_table VALUES (20181122, 1300);

GO

INSERT fact_table VALUES (20190101, 76);
INSERT fact_table VALUES (20190403, 450);
INSERT fact_table VALUES (20190706, 330);
INSERT fact_table VALUES (20191122, 1200);
INSERT fact_table VALUES (20190101, 73);
INSERT fact_table VALUES (20190403, 420);
INSERT fact_table VALUES (20190706, 310);
INSERT fact_table VALUES (20191122, 1300);
INSERT fact_table VALUES (20191122, 2200);


select count(1) from dbo.fact_table

-- Query the table
SELECT datekey, measure, $PARTITION.PF(datekey) PartitionNo
FROM fact_table;

-- View filegroups, partitions, and rows
SELECT OBJECT_NAME(p.object_id) as obj_name, f.name, p.partition_number, p.rows
FROM sys.system_internals_allocation_units a
JOIN sys.partitions p
ON p.partition_id = a.container_id
JOIN sys.filegroups f ON a.filegroup_id = f.data_space_id
WHERE p.object_id = OBJECT_ID(N'dbo.fact_table')
ORDER BY obj_name, p.index_id, p.partition_number;
GO

-- Add a new filegroup and make it the next used
ALTER DATABASE DemoPartition ADD FILEGROUP FG2019
GO
ALTER DATABASE DemoPartition ADD FILE (NAME = F2019, FILENAME = 'D:\DP300\Demofiles\F2019.ndf', SIZE = 3MB, FILEGROWTH = 50%) TO FILEGROUP FG2019;
GO
ALTER PARTITION SCHEME PS
NEXT USED FG2019;
GO
-- Split the empty partition at the end
ALTER PARTITION FUNCTION PF() SPLIT RANGE(20190101);
GO

-- Insert NEW YEAR 2019 data
INSERT fact_table VALUES (20190101, 99);    -- jan
INSERT fact_table VALUES (20190203, 126);	-- feb
INSERT fact_table VALUES (20190319, 71);	-- mar
INSERT fact_table VALUES (20190413, 34);	-- apr
INSERT fact_table VALUES (20190517, 68);	-- may
INSERT fact_table VALUES (20190628, 72);	-- jun
INSERT fact_table VALUES (20190709, 11);	-- jul
INSERT fact_table VALUES (20190805, 25);	-- aug
INSERT fact_table VALUES (20190910, 87);	-- sep

GO

-- View partition metadata
SELECT DISTINCT OBJECT_NAME(p.object_id) as obj_name, f.name, p.partition_number, p.rows
FROM sys.system_internals_allocation_units a
JOIN sys.partitions p
ON p.partition_id = a.container_id
JOIN sys.filegroups f ON a.filegroup_id = f.data_space_id
WHERE p.object_id = OBJECT_ID(N'dbo.fact_table')
ORDER BY obj_name, p.partition_number;
GO

-- Merge the 2016 and 2017 partitions
ALTER PARTITION FUNCTION PF() MERGE RANGE(20160101);
GO

-- View partition metadata
SELECT DISTINCT OBJECT_NAME(p.object_id) as obj_name, f.name, p.partition_number, p.rows
FROM sys.system_internals_allocation_units a
JOIN sys.partitions p
ON p.partition_id = a.container_id
JOIN sys.filegroups f ON a.filegroup_id = f.data_space_id
WHERE p.object_id = OBJECT_ID(N'dbo.fact_table')
ORDER BY obj_name, p.partition_number;
GO