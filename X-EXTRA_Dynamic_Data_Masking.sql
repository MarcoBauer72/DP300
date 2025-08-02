/*------------------------------------------------------------------------- */
/*                                                                          */
/* --------------------  EXTRA - Dynamic Data Masking  -------------------- */
/*                                                                          */
/*------------------------------------------------------------------------- */

-- Recurso para ofuscar (obfuscating) colunas atraves de adicionando mascaras diferentes pre-definidas
   para diferentes colunas como por exemplo: 
   
   default() -	substitui os valores da colunas por: xxxxx

   email() -	substitui os valores de emails por: mXXX@XXXX.com

   partial() -  substtitui os valores da coluna por um padrão a ser definido dentro do parentesis

   random() -   apenas para colunas numericas substitui os valores por uma faixa de valores numericos
				definidos dentro do parentesis da funcao


--Microsoft---------------------------------------------------------------------------------------------
Topic Status: Some information in this topic is preview and subject to change in future releases. 
Preview information describes new features or changes to existing features 
in SQL Server 2016 Release Candidate (RC3).

Dynamic data masking limits sensitive data exposure by masking it to non-privileged users. 
Dynamic data masking helps prevent unauthorized access to sensitive data by enabling customers
to designate how much of the sensitive data to reveal with minimal impact on the application layer.
It’s a data protection feature that hides the sensitive data in the result set of a query over 
designated database fields, while the data in the database is not changed.

Dynamic data masking is easy to USE with existing applications, since masking rules are applied in the 
query results. Many applications can mask sensitive data without modifying existing queries.

For example, a call center support person may identify callers by several digits of their social 
security number or credit card number, but those data items should not be fully exposed to the support person. 
A masking rule can be defined that masks all but the last four digits of any social security number
or credit card number in the result set of any query.
For another example, by using the appropriate data mask to protect personally identifiable information (PII)
data, a developer can query production environments for troubleshooting purposes without violating
compliance regulations.

The purpose of dynamic data masking is to limit exposure of sensitive data, preventing users 
who should not have access to the data from viewing it. Dynamic data masking does not aim to 
prevent database users from connecting directly to the database and running exhaustive queries 
that expose pieces of the sensitive data. Dynamic data masking is complementary to other SQL Server 
security features (auditing, encryption, row level security…) and it is highly recommended to USE 
this feature in conjunction with them in addition in order to better protect the sensitive data 
in the database.

Dynamic data masking is available by using Transact-SQL in SQL Server 2016 Release Candidate (RC3) 
and Azure SQL Database. 
For additional information about configuring dynamic data masking by using the Azure portal, 
see Get started with SQL Database Dynamic Data Masking (Azure portal).

----- DEMO -----
-- Using Dynamic Data Masking
DROP DATABASE DDM
GO

-- Step 1 - create a new table with data masks
CREATE DATABASE DDM
GO

USE DDM
GO

CREATE USER [test_user] FOR LOGIN [test_user]


CREATE TABLE dbo.EmployeePersonalData
(empid int NOT NULL PRIMARY KEY,
salary int  MASKED WITH (FUNCTION = 'default()') NOT NULL,
email_address varchar(255)  MASKED WITH (FUNCTION = 'email()')  NULL,
voice_mail_pin smallint MASKED WITH (FUNCTION = 'random(0, 9)') NULL,
company_credit_card_number varchar(30) MASKED WITH (FUNCTION = 'partial(1,"xxxxx-",2)') NULL,
home_phone_number varchar(30) NULL
);
GO
-- grant permission to a low-privilege user
GRANT SELECT ON dbo.EmployeePersonalData TO test_user;
GO

-- insert test data 
INSERT dbo.EmployeePersonalData
(empid, salary, email_address, voice_mail_pin, company_credit_card_number, home_phone_number)
VALUES (1,25000,'emp1@adventure-works.net',9991,'9999-5656-4433-2211', '1234-567890'),
(2,35000,'qx3e@adventure-works.org',1151,'9999-7676-5566-3141', '2345-314253'),
(3,35000,'zn4456@adventure-works.net',6514,'9999-7676-5567-2444', '3456-777266')

-- Step 2 - demonstrate that an adminstrator can see the unmasked data
SELECT * FROM dbo.EmployeePersonalData

-- Step 3 - demonstrate that a user with only SELECT permission sees masked data  
EXECUTE AS USER = 'test_user'
SELECT * FROM dbo.EmployeePersonalData
REVERT
GO
-- Step 4 - alter the home_phone_number column to add a mask
ALTER TABLE EmployeePersonalData 
ALTER COLUMN home_phone_number
ADD MASKED WITH (FUNCTION = 'partial(2,"-@@@@@",1)');
GO

-- Step 5 - demonstrate the new mask  
EXECUTE AS USER = 'test_user'
SELECT * FROM EmployeePersonalData
REVERT
GO

-- Step 6 - remove the mask from the email_address column
ALTER TABLE EmployeePersonalData 
ALTER COLUMN voice_mail_pin
DROP MASKED;
GO

-- Step 7 - demonstrate that salary is now unmasked 
EXECUTE AS USER = 'test_user'
SELECT * FROM EmployeePersonalData
REVERT
GO

-- Step 8 - grant the UNMASK permission to the test user
GRANT UNMASK TO test_user;

-- Step 9 - demonstrate that the UNMASK permission disables masking
EXECUTE AS USER = 'test_user'
SELECT * FROM EmployeePersonalData
REVERT
GO

-- Step 10 - remove test table
DROP TABLE EmployeePersonalData;
GO

USE MASTER
GO

DROP DATABASE DDM
GO


Referencias:
https://msdn.microsoft.com/en-us/library/mt130841.aspx
https://social.msdn.microsoft.com/Forums/en-US/81cc9d38-fc7b-43e6-9378-e8e75c0eff9a/data-masking?forum=sqlsecurity
https://social.msdn.microsoft.com/Forums/en-US/6f6e88b3-42aa-4cb3-8aa4-96314ed3d19a/data-masking-in-sql-server?forum=transactsql
https://msdn.microsoft.com/en-us/library/azure/dn912660.aspx


Videos:
https://www.youtube.com/watch?v=7ch8tbstkyM
https://www.youtube.com/watch?v=_dIPY0g_2kg



