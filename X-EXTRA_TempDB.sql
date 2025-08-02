----- Demo 1: Moving tempdb Files -----

--1. Ensure that the 20765C-MIA-DC and 20765C-MIA-SQL virtual machines are running, and log on to
--20765C-MIA-SQL as ADVENTUREWORKS\Student with the password Pa55w.rd.

--2. In the D:\Demofiles\Mod06 folder, run Setup.cmd as Administrator. Click Yes when prompted.

--3. Start SQL Server Management Studio and connect to the MIA-SQL database engine using Windows
--authentication.

--4. In Object Explorer, expand Databases, expand System Databases, right-click tempdb, and then click
--Properties.

--5. In the Database Properties dialog box, on the Files page, note the current files and their location.
--Then click Cancel.

--6. Open the MovingTempdb.sql script file in the D:\Demofiles\Mod06 folder.

--7. View the code in the script, and then click Execute. Note the message that is displayed after the code
--has run.

USE master;
GO

ALTER DATABASE tempdb 
MODIFY FILE (NAME = tempdev, FILENAME = 'D:\tempdb.mdf');
ALTER DATABASE tempdb 
MODIFY FILE (NAME = temp2, FILENAME = 'D:\tempdb2.ndf');
ALTER DATABASE tempdb 
MODIFY FILE (NAME = temp3, FILENAME = 'D:\tempdb3.ndf');
ALTER DATABASE tempdb 
MODIFY FILE (NAME = temp4, FILENAME = 'D:\tempdb4.ndf');
ALTER DATABASE tempdb 
MODIFY FILE (NAME = temp5, FILENAME = 'D:\tempdb5.ndf');
ALTER DATABASE tempdb 
MODIFY FILE (NAME = temp6, FILENAME = 'D:\tempdb6.ndf');


ALTER DATABASE tempdb 
MODIFY FILE (NAME = templog, FILENAME = 'D:\templog.ldf');
GO

--8. View the contents of D:\ and note that no files have been created in that location, because the SQL
--Server service has not yet been restarted.

--9. In Object Explorer, right-click MIA-SQL, and then click Restart. When prompted, click Yes.

--10. In the Microsoft SQL Server Management Studio dialog boxes, when prompted to allow changes,
--to restart the service, and to stop the dependent SQL Server Agent service, click Yes.

--11. View the contents of D:\ and note that the tempdb MDF and LDF files have been moved to this
--location.



----- Demo 2: Storing a Database on an SMB Fileshare -----

--1. Ensure that the 20765C-MIA-DC and 20765C-MIA-SQL virtual machines are running, and log on to
--20765C-MIA-SQL as ADVENTUREWORKS\Student with the password Pa55w.rd.

--2. Open File Explorer and navigate to the D:\ drive, right-click the smbshare folder, and then click
--Properties.

--3. In the smbshare Properties dialog box, on the Sharing tab, in the Network File and Folder
--Sharing section, note that this folder is shared with the network path \\MIA-SQL\smbshare, and
--then click Cancel.

--4. In SQL Server Management Studio, open the file SMBDemo.sql located in the D:\Demofiles\Mod06
--folder and execute the code it contains.

USE master;
GO

CREATE DATABASE SMBTest on
(Name='SMBTest_data', Filename='\\MIA-SQL\SmbShare\SMBTest_data.mdf')
LOG ON
(Name='SMBTest_log', Filename='\\MIA-SQL\SmbShare\SMBTest_log.ldf')
GO

--5. In File Explorer, navigate to the D:\smbshare folder and note the database files have been created.

--6. Close SQL Server Management Studio without saving any changes.