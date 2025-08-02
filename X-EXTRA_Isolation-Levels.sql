/*------------------------------------------------------------ */
/*                                                             */
/* -----------------  MS-SQL ISOLATION LEVELS ---------------- */
/*                                                             */
/*------------------------------------------------------------ */


/*
Following are the different types of isolations available in SQL Server.
READ COMMITTED
READ UNCOMMITTED
REPEATABLE READ
SERIALIZABLE
SNAPSHOT
Let us discuss about each isolation level in details.Before this, execute following script to create table and INSERT some 
data that we are going to use in examples for each isolation
*/


----- Concurrency Problems -----

--Dirty Read
-- Ocorre quando uma transacao le linhas que estao sendo modificadas por outra transacao.
-- Retorna linhas que ainda nao foram "commitadas" por outra transacao em andamento.
-- Exemplo: O usuario A abre uma transacao e muda o valor de uma linha de X para Y.
--          O usuario B usuario le o valor alterado para Y forcando leitura suja.
--			O usuario A decide dar "ROLLBACK" da transacao voltando o valor de Y para X.

--Lost Update
-- Ocorre quando uma ou mais transacoes atualizao simultaneamente a mesma linha baseadas no mesmo
-- valor inicial da linha. Quando isso ocorre a ultima transacao sobreescreve as mudancas da primeira,
-- resultando em perda de dados.
-- Exemplo: Usuario C e usuario D querem alterar a mesma linha com valor X. Enquanto o usuario C
--			altera o valor de X para Y o usuario D altera o valor X para Z. A modificacao do usuario C
--          serah sobrescrita pela alteracao do usuario D.

--Non-Repeatable Read
-- Ocorre quando uma transacao le diferente valor para a mesma linha cada vez que a linha eh acessada.
-- Acontece quando o dado eh alterada entre duas operacoes de "SELECT".
-- Exemplo: O usuario E comeca uma transacao contendo dois "SELECTs" parecidos, s1 e s2. 
--			O primeiro "SELECT" s1 retorna o valor X e continua processando outras consultas,
--			antes de atingir a consulta s2. Enquanto isso, o usuario F modifica o valor X
--			para Y, antes do usuario E rodar a consulta s2. Quando o usuario E chega no momento
--			de executar a consulta s2, esta retorna o valor Y ao inves do valor X da consulta s1.

--Phantom Read
-- Eh uma variacao do "non-repeatable read". Ocorre quando uma transacao APAGA ou INSERE uma linha
-- que faz parte do conjunto de linhas utilizadas em outra transacao.
-- Exemplo: Um usuario G tem duas consulta parecidas s1 e s2 dentro da mesma transacao.
--			Ao executar a consulta s1 retorna N linhas e continua processando outras instrucoes.
--			Enquanto isso, o usuario H, apaga uma linha que eh lida pelas consultas s1 e s2.
--			Quando chega o momento da transacao do usuario G rodar a consulta s2 o numero de linhas
--			retornadas passa a ser N-1. A consulta s1 retornou uma "leitura fantasma".


--Double Read
--	Ocorre quando uma transacao le a mesma linha duas vezes enquanto lendo um subconjunto de linhas.
--	Enquanto uma transacao le um cojunto de linhas uma outra transacao atualiza uma ou mais linhas
--	utilizadas pela primeira transacao.
--	Exemplo: O usuario I executa uma consulta que traz nomes de A ate Z utilizando "index scan". 
--			 Apos o "index scan" ler as linhas com letra A, porem, antes de chegar nas linhas
--			 com letra Z, o usuario J, atualiza uma linha com A para Z. Sendo assim, quando
--			 o "index scan" do usuario I chegar nas linhas de letra Z vai ler novamente a linha que
--			 foi atualizada pelo usuario J.
--	* Eh tambem possivel deixar de ler uma linha, no caso que enquanto o "index scan" do usuario I,
--	  nao chegou ainda nas linhas com letra Z e neste intervalo o usuario J atualiza uma linha com
--	  letra Z para letra A. Sendo assim, para o usuario I nao vai ser retornada aquela linha que
--    foi atualizada pelo usuario J. Apesar ser um problema de "pular" linha(s), esse efeito tambem
--    eh classificado como "Double Read".


----- Transactions -----
---READ UNCOMMITTED---
--READ UNCOMMITTED is the lowest level of isolation available in SQL Server. The READ UNCOMMITTED
--isolation level has the following properties:
--? No locks are taken for data being read.
--? During read operations, a lock is taken to protect the underlying database schema from being
--  modified.
--? Readers do not block writers, and writers do not block readers; however, writers do block writers.
--? All of the concurrency problems (dirty reads, non-repeatable reads, double reads, and phantom
--  reads) can occur.
--? Data consistency is not guaranteed.
--? Not supported on FILESTREAM enabled databases.


---READ COMMITTED---
--READ COMMITTED is the SQL Server default isolation level. The READ COMMITTED isolation level has the
--following properties when the READ_COMMITTED_SNAPSHOT database option is OFF (the default for
--SQL Server installations):
--? Read locks are acquired and held until the end of the statement.
--? Dirty reads are eliminated by allowing access to committed data only.
--? Because read locks are held until the end of the statement, data can be changed by other
--transactions between individual statements within the current transaction, resulting in non-repeatable
--reads, double reads, and phantom reads.
--When the READ_COMMITTED_SNAPSHOT database option is ON (the default for Azure SQL Database),
--the READ COMMITTED isolation level has the following properties:
--? Row versioning is used to provide statement-level read consistency. Because each statement in a
--transaction executes, a snapshot of old data is taken and stored in version store. The snapshot is
--consistent until the statement finishes execution.
--? Read locks are not held because the data is read from the version store, and not from the underlying
--object.
--? Dirty reads do not occur because a transaction reads only committed data, but non-repeatable reads
--and phantom reads can occur during a transaction.
--READ COMMITTED isolation is supported on FILESTREAM enabled databases.

---REPEATABLE READ---
--REPEATABLE READ has the following properties:
--? Read locks are acquired and held until the end of the transaction. Therefore, a transaction cannot
--read uncommitted data and cannot modify the data being read by other transactions until that
--transaction completes.
--? Eliminates non-repeatable reads. Phantom reads and double reads still occur. Other transactions can
--insert or delete rows in the range of data being read.
--? Not supported on FILESTREAM enabled databases.

---SERIALIZABLE---
--SERIALIZABLE is the highest level of isolation available in SQL Server. It has the following properties:
--? Range locks are acquired on the range of values being read and are held until the end of the
--transaction.
--? Transactions cannot read uncommitted data, and cannot modify the data being read by other
--transactions until the transaction completes; another transaction cannot insert or delete the rows in
--the range of rows being read.
--? Provides lowest level of concurrency.
--? Not supported on FILESTREAM enabled databases.


---SNAPSHOT---
--SNAPSHOT isolation is based on an optimistic concurrency model. SNAPSHOT isolation has the following
--properties:
--? Uses row versioning to provide transaction-level read consistency. A data snapshot is taken at the
--start of the transaction and remains consistent until the end of the transaction.
--? Transaction-level read consistency eliminates dirty reads, non-repeatable reads, and phantom reads.
--? If update conflicts are detected, a participating transaction will roll back.
--? Supported on FILESTREAM enabled databases.
--? The ALLOW_SNAPSHOT_ISOLATION database option must be ON before you can USE the SNAPSHOT
--isolation level (OFF by default in SQL Server installations, ON by default in Azure SQL Database).


USE AdventureWorks
GO

IF OBJECT_ID('Emp') is not null
BEGIN 
DROP TABLE Emp
END

CREATE TABLE Emp(ID int,Name Varchar(50),Salary Int)


CREATE PROC xsp_Emp AS
BEGIN

DELETE Emp

INSERT INTO Emp(ID,Name,Salary)
VALUES( 1,'David',1000)

INSERT INTO Emp(ID,Name,Salary)
VALUES( 2,'Steve',2000)

INSERT INTO Emp(ID,Name,Salary)
VALUES( 3,'Chris',3000)        

END
	  
	  
SP_HELPTEXT 'xsp_Emp'
	  
xsp_Emp 
    
-- Test data
SELECT * FROM Emp
-- Note: Before executing each example in this article, reset the Emp table VALUES by executing the above script.


---------- READ COMMITTED ----------
-- In select query it will take only commited VALUES of table. If any transaction is opened and incompleted on table in others 
-- sessions then select query will wait till no transactions are pending on same table.

-- READ COMMITTED is the default transaction isolation level.

--- Example 1:
--Session 1
	BEGIN TRAN
	UPDATE emp
	SET Salary = 999
	WHERE ID = 1
	WAITFOR DELAY '00:00:15'
	COMMIT


            
--Session 2
        set transaction isolation level READ COMMITTED
        select Salary from Emp where ID=1

-- * Run both sessions side by side.
-- In second session, it returns the result only after execution of complete transaction in first session because of the lock on 
-- Emp table. We have used wait command to delay 15 seconds after updating the Emp table in transaction.

EXEC xsp_Emp

--- Example 2
--Session1
        BEGIN tran
        select * from Emp
        waitfor delay '00:00:15'
        COMMIT
            
--Session2
        set transaction isolation level READ COMMITTED
        select * from Emp


EXEC xsp_Emp

--- Example 3
--Session 1
        BEGIN tran
        select * from emp            
        waitfor delay '00:00:15'
        UPDATE emp set Salary=999 where ID=1
        COMMIT
            
--Session 2
        set transaction isolation level READ COMMITTED
        select Salary from Emp where ID=1
        



-- * Run both sessions side by side.
-- In session2, there won't be any delay in execution because when session2 is executed Emp table in session1 is not 
-- locked(used only select command, locking on Emp table occurs after wait delay command).

EXEC xsp_Emp


--- Example 4 (UM VARIANTE DE LEITURA SUJA!!! BY JAMES)
--Session1
        BEGIN tran
        select * from Emp
        waitfor delay '00:00:15'
        COMMIT
            
--Session2
        set transaction isolation level READ COMMITTED -- ESSE EH O PADRAO DO SQL - A PRINCIPIO DESNECESSARIO O USO
  		UPDATE emp
		SET Salary = 999
		WHERE ID = 1

-- * Run both sessions side by side.
-- In session2, there won't be any delay in execution because in session1 Emp table is used under transaction but it is not 
-- used UPDATE or delete command hence Emp table is not locked.


---------- READ UNCOMMITTED ---------- * LEITURA SUJA!!!
-- If any table is updated(INSERT or UPDATE or delete) under a transaction and same transaction is not 
-- completed that is not committed or roll backed then uncommitted VALUES will displaly(Dirty Read) in select query of "READ UNCOMMITTED" 
-- isolation transaction sessions. There won't be any delay in select query execution because this transaction level does not 
-- wait for committed VALUES on table.

EXEC xsp_Emp

--- Example 1
--Session 1
        BEGIN tran
        UPDATE emp set Salary=999 where ID=1
        waitfor delay '00:00:15'
        rollback
            
--Session 2
        set transaction isolation level READ UNCOMMITTED
		select Salary from Emp where ID=1

-- * Run both sessions at a time one by one.
-- Select query in Session2 executes after UPDATE Emp table in transaction and before transaction rolled back. Hence 999 
-- is returned instead of 1000.

-- If you want to maintain Isolation level "READ COMMITTED" but you want dirty read VALUES for specific tables then use 
-- with(nolock) in select query for same tables as shown below.

    set transaction isolation level READ COMMITTED
    select * from Emp with(nolock)


---------- REPEATABLE READ ----------
-- select query data of table that is used under transaction of isolation level "REPEATABLE READ" can not be modified from 
-- any other sessions till transcation is completed.

--? Read locks are acquired and held until the end of the transaction. Therefore, a transaction cannot
--read uncommitted data and cannot modify the data being read by other transactions until that
--transaction completes.
--? Eliminates non-repeatable reads. Phantom reads and double reads still occur. Other transactions can
--insert or delete rows in the range of data being read.
--? Not supported on FILESTREAM enabled databases.

EXEC xsp_Emp

--- Example 1
--Session 1
    set transaction isolation level REPEATABLE READ
    BEGIN tran
    select * from emp where ID in(1,2)
    waitfor delay '00:00:15'
    select * from Emp where ID in (1,2)
    rollback

--Session 2
    UPDATE emp set Salary=999 where ID=1

EXEC xsp_Emp

-- * Run both sessions side by side.
-- UPDATE command in session 2 will wait till session 1 transaction is completed because emp table row with ID=1 
-- has locked in session1 transaction.

--- Example 2
--Session 1
    set transaction isolation level REPEATABLE READ
    BEGIN tran
    select * from emp
    waitfor delay '00:00:15'
    select * from Emp
    rollback
--Session 2
    INSERT INTO Emp(ID,Name,Salary)
    VALUES( 11,'Stewart',11000)

-- * Run both sessions side by side.
-- session 2 will execute without any delay because it has INSERT query for new entry. This isolation level allows to INSERT
-- new data but does not allow to modify data that is used in select query executed in transaction.
-- You can notice two results displayed in Session 1 have different number of row count(1 row extra in sectond result set).

EXEC xsp_Emp

--- Example 3
--Session 1
    set transaction isolation level REPEATABLE READ
    BEGIN tran
    select * from emp where ID in(1,2)
    waitfor delay '00:00:15'
    select * from Emp where ID in (1,2)
    rollback
        
--Session 2
    UPDATE emp set Salary=999 where ID=3

-- * Run both sessions side by side.
-- session 2 will execute without any delay because row with ID=3 is not locked, that is only 2 records whose IDs are 1,2
-- are locked in Session 1.

---------- SERIALIZABLE ---------- EH O MAIS PESSIMISTA DE TODOS OS NIVEIS DE TRANSACAO
-- Serializable Isolation is similar to REPEATABLE READ Isolation but the difference is it prevents PHANTOM READ. This works 
-- based on range lock. If table has index then it locks records based on index range used in WHERE clause(like where ID
-- between 1 and 3). If table doesn't have index then it locks complete table.

EXEC xsp_Emp

--- Example 1
--Assume table does not have index column.
--Session 1
    set transaction isolation level serializable
    BEGIN tran
    select * from Emp
    waitfor delay '00:00:15'
    select * from Emp
    rollback
--Session 2
    INSERT INTO Emp(ID,Name,Salary)
    VALUES( 11,'Stewart',11000)

-- * Run both sessions side by side.
-- Complete Emp table will be locked during the transaction in Session 1. Unlike "REPEATABLE READ", INSERT query in 
-- Session 2 will wait till session 1 execution is completed. Hence Phantom read is prevented and both queries in session 1 
-- will display same number of rows.
-- To compare same scenario with "REPEATABLE READ" read REPEATABLE READ Example 2.

EXEC xsp_Emp


-- Assume table has primary key on column "ID". In our example script, primary key is not added. Add primary key 
-- on column Emp.ID before executing below examples.

USE AdventureWorks
GO

IF OBJECT_ID('Emp') is not null
BEGIN 
DROP TABLE Emp
END

CREATE TABLE Emp(ID int primary key,Name Varchar(50),Salary Int)

EXEC xsp_Emp


---------- SNAPSHOT ----------
-- Snapshot isolation is similar to Serializable isolation. The difference is Snapshot does not hold lock on table during the
-- transaction so table can be modified in other sessions. Snapshot isolation maintains versioning in Tempdb for old data in 
-- case of any data modification occurs in other sessions then existing transaction displays the old data from Tempdb.

USE AdventureWorks
GO

ALTER DATABASE AdventureWorks
SET ALLOW_SNAPSHOT_ISOLATION ON
GO


EXEC xsp_Emp


--- Example 1
--Session 1
    set transaction isolation level snapshot
    BEGIN tran
    select * from Emp
    waitfor delay '00:00:15'
    select * from Emp
    rollback
--Session 2
    INSERT INTO Emp(ID,Name,Salary) VALUES( 11,'Stewart',11000)
    UPDATE Emp set Salary=4444 where ID=4
    select * from Emp

-- * Run both sessions side by side.
-- Session 2 queries will be executed in parallel as transaction in session 1 won't lock the table Emp.



/* ----- Referencia ----- */
http://www.besttechtools.com/articles/article/sql-server-isolation-levels-by-example

