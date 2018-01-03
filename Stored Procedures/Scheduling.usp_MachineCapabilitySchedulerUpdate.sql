SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






--/****** Script for SelectTopNRows command from SSMS  ******/


/*	Author:		Bryan Eddy
	Date:		10/25/2017
	Desc:		Daily update of all setups and machines for the scheduler to flag on/off
	Version:	3
	Update:		Changed the first query to always add new setups as active.
*/
CREATE PROCEDURE [Scheduling].[usp_MachineCapabilitySchedulerUpdate]
AS

	DECLARE @ErrorNumber INT = ERROR_NUMBER();
	DECLARE @ErrorLine INT = ERROR_LINE();

	 SET NOCOUNT ON;
	 BEGIN 
		 BEGIN TRY
			BEGIN TRAN
				--Get setups from Setup DB
				INSERT INTO [Scheduling].[MachineCapabilityScheduler](Setup, MachineID, ActiveScheduling)
				SELECT K.Setup, K.Machineid,1-- K.ActiveSetup
				FROM [Setup].[vSetupStatus] K
				LEFT JOIN [Scheduling].[MachineCapabilityScheduler] G  ON G.Setup = K.Setup AND g.MachineID = K.Machineid
				WHERE g.Setup IS NULL
			COMMIT TRAN
		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
 
			PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
			PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
			THROW;
		END CATCH;

		BEGIN TRY
			BEGIN TRAN
				--Get setups from Setup Calculation
				INSERT INTO [Scheduling].[MachineCapabilityScheduler](Setup, MachineID, ActiveScheduling)
				SELECT DISTINCT K.Setup, K.Machineid, 1
				FROM Setup.vSetupStatusAll K LEFT JOIN [Scheduling].[MachineCapabilityScheduler] G  ON G.Setup = K.Setup AND g.MachineID = K.Machineid
				WHERE g.Setup IS NULL
			COMMIT TRAN
		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
			PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
			PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
			THROW;
		END CATCH;

		BEGIN TRY
			BEGIN TRAN
				--Get setups that are manually created scheduler
				INSERT INTO [Scheduling].[MachineCapabilityScheduler](Setup, MachineID, ActiveScheduling)
				SELECT DISTINCT K.True_Operation_Code, K.MachineID, 1
				FROM [Scheduling].[DefinedOperationDuration] K LEFT JOIN [Scheduling].[MachineCapabilityScheduler] G  ON G.Setup = K.True_Operation_Code AND g.MachineID = K.MachineID
				WHERE g.Setup IS NULL
			COMMIT TRAN
		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
			PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
			PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
			THROW;
		END CATCH
	END;



GO
