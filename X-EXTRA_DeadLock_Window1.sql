USE MarketDev; 
GO


WAITFOR DELAY '00:00:07';



BEGIN TRAN 

UPDATE Marketing.Prospect 
SET EmailAddress = 'Secao58@AdventureWorks.com'  
WHERE ProspectID = 6; 

WAITFOR DELAY '00:00:05'; 


UPDATE Marketing.Product 	
SET SellEndDate = GETDATE() 
WHERE ProductID = 2;



COMMIT TRAN







--SELECT SellEndDate FROM Marketing.Product WHERE ProductID = 2
--SELECT EmailAddress FROM Marketing.Prospect WHERE ProspectID = 6
 
--UPDATE Marketing.Prospect 
--SET EmailAddress = 'NADA'  
--WHERE ProspectID = 6; 

--UPDATE Marketing.Product 	
--SET SellEndDate = GETDATE() -730
--WHERE ProductID = 2;

--SET DEADLOCK_PRIORITY 9;