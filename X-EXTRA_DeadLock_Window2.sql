USE MarketDev; 
GO


WAITFOR DELAY '00:00:10'; 




BEGIN TRAN 

UPDATE Marketing.Product 
SET SellEndDate = GETDATE()+365
WHERE ProductID = 2

WAITFOR DELAY '00:00:05'; 

UPDATE Marketing.Prospect 
SET EmailAddress = 'Secao60@AdventureWorks.com'  
WHERE ProspectID = 6
 
 
 COMMIT TRAN









--SELECT SellEndDate FROM Marketing.Product WHERE ProductID = 2
--SELECT EmailAddress FROM Marketing.Prospect WHERE ProspectID = 6
 
 --SET DEADLOCK_PRIORITY 9;