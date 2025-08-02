/*-------------------------------------------------------------------- */
/*                                                                     */
/* --------------------  EXTRA - Always Encrypted -------------------- */
/*                                                                     */
/*-------------------------------------------------------------------- */




-	Criptografar dados sensíveis do banco de dados.

-	Apenas aplicacoes e usuarios que possuem o certificao instalado localmente podem acessar esses dados sensíveis.

Always Encrypted is a feature designed to protect sensitive data, such as credit card numbers 
or national identification numbers (e.g. U.S. social security numbers), 
stored in Azure SQL Database or SQL Server databases. Always Encrypted allows clients to encrypt sensitive 
data inside client applications and never reveal the encryption keys to the Database Engine (SQL Database or SQL Server).
As a result, Always Encrypted provides a separation between those who own the data (and can view it) and those who manage 
the data (but should have no access). By ensuring on-premises database administrators, cloud database operators, 
or other high-privileged, but unauthorized users, cannot access the encrypted data, 
Always Encrypted enables customers to confidently store sensitive data outside of their direct control. 
This allows organizations to encrypt data at rest and in USE for storage in Azure, to enable delegation 
of on-premises database administration to third parties, or to reduce security clearance requirements 
for their own DBA staff.

Always Encrypted makes encryption transparent to applications. 
An Always Encrypted-enabled driver installed on the client computer achieves this by automatically 
encrypting and decrypting sensitive data in the client application. 
The driver encrypts the data in sensitive columns before passing the data to the Database Engine, 
and automatically rewrites queries so that the semantics to the application are preserved. 
Similarly, the driver transparently decrypts data, stored in encrypted database columns, contained in query results.

Always Encrypted is available in SQL Server 2016 Release Candidate (RC3) and in preview in SQL Database. 
For a Channel 9 presentation that includes Always Encrypted, see Keeping Sensitive Data Secure with Always Encrypted.


Typical Scenarios


--------------------------------------------------------------------------------

-- Client and Data On-Premises

A customer has a client application and SQL Server both running on-premises,
at their business location. 
The customer wants to hire an external vendor to administer SQL Server. 
In order to protect sensitive data stored in SQL Server, the customer 
uses Always Encrypted to ensure the separation of duties between database administrators and application administrators. 
The customer stores plaintext values of Always Encrypted keys in a trusted key store which the client application can access.
SQL Server administrators have no access to the keys and, therefore, are unable to decrypt sensitive data stored 
in SQL Server.


--  Client On-Premises with Data in Azure

A customer has an on-premises client application at their business location. 
The application operates on sensitive data stored in a database hosted in Azure (SQL Database or SQL Server running 
in a virtual machine on Microsoft Azure). The customer uses Always Encrypted and stores Always Encrypted keys in a 
trusted key store hosted on-premises, to ensure Microsoft cloud administrators have no access to sensitive data.


-- Client and Data in Azure

A customer has a client application, 
hosted in Microsoft Azure (e.g. in a worker role or a web role), 
which operates on sensitive data stored also stored in Microsoft Azure. 
The customer uses Always Encrypted to reduce security attack surface area 
(the data is always encrypted in the database and on the machine hosting the database).


----- DEMO ------
USE AdventureWorks2016
GO

-- SSN and CreditCardNumber columns
SELECT TOP 1000 * FROM AdventureWorks2016PII.Sales.CustomerPII

-- Close the database connection from step 1 and reconnect by adding the following connection 
-- string keyword/value in the Additional Connection Parameters of the Connect to Database Engine dialog: 

-- !!!!! column encryption setting=enabled !!!!! (No momento da conexao , na connection string)

-- SSN and CreditCardNumber columns
USE AdventureWorks2016
GO


SELECT TOP 1000 * FROM Sales.CustomerPII


-- Install AlwaysEncryptedCMK.pfx
-- Enter the password for the certificate: AlwaysEncrypted


-- Criar tabela nova de salarios com campo salario e Encrypt Column
CREATE DATABASE BSW
GO

USE BSW
GO


DROP TABLE Salarios


CREATE TABLE Salarios
(
 ID INT, NOME VARCHAR(100), SALARIO MONEY
)



INSERT Salarios VALUES (1,'JOAO',10000),(2,'MARIA',12000)

-- Botao da direita na tabela dbo.Salarios e Encrypt Columns
SELECT * FROM Salarios
-- certmgr.msc 

C:\Users\MARCO\AppData\Roaming\Microsoft\SystemCertificates\My\Certificates


Referencias:
https://channel9.msdn.com/shows/data-exposed/getting-started-with-always-encrypted-with-ssms
https://channel9.msdn.com/Shows/Data-Exposed/SQL-Server-2016-Always-Encrypted
https://blogs.msdn.microsoft.com/sqlsecurity/2015/06/04/getting-started-with-always-encrypted/
https://msdn.microsoft.com/en-US/library/mt459280.aspx
https://msdn.microsoft.com/en-us/library/mt163865.aspx
https://msdn.microsoft.com/en-us/library/mt147923.aspx
http://aka.ms/alwaysencrypted


Videos:
https://www.youtube.com/watch?v=Y4lzKB5LdaI
https://www.youtube.com/watch?v=EPIq70NzQ4k