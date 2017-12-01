SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Bryan Eddy
-- Create date: 9/14/2017
-- Description:	Add new subinventories to the Scheduling.Subinventory table
-- Version: 1
-- Update:	Added error handling
-- =============================================
CREATE PROCEDURE [Scheduling].[usp_GetNewSubinventory] 

AS
BEGIN
		SET NOCOUNT ON;

		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
	BEGIN TRY
		BEGIN TRAN
			INSERT INTO Scheduling.Subinventory(SubinventoryName)
			SELECT DISTINCT G.subinventory_code
			FROM [dbo].[Oracle_Onhand] G LEFT JOIN Scheduling.Subinventory K ON K.SubinventoryName  = G.subinventory_code
			WHERE K.SubinventoryName IS NULL
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
 
		DECLARE @ErrorNumber INT = ERROR_NUMBER();
		DECLARE @ErrorLine INT = ERROR_LINE();
 
		PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
		PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
		THROW;
	END CATCH

END
GO
