SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:      Bryan Eddy
-- Create date: 4/23/2018
-- Description: Procedure to get the designated attributes values for information in Mes.MachineAttributes
-- Version:		1
-- Update:		Initial creation
-- =============================================

CREATE PROCEDURE [Mes].[usp_GetItemAttributes]
AS
	SET NOCOUNT ON;
BEGIN

TRUNCATE TABLE mes.ItemSetupAttributes

DECLARE @ErrorNumber INT = ERROR_NUMBER();
DECLARE @ErrorLine INT = ERROR_LINE();


		
	--Insert fixed time values for setup times
	BEGIN TRY
		BEGIN TRAN

		;WITH cteAttributes
		AS(
			SELECT CableColor AS AttrbiuteValue, AttributeName, AttributeNameID, i.DataType, ItemNumber
			FROM Setup.ItemAttributes CROSS APPLY Setup.ApsSetupAttributes k INNER JOIN Setup.AttributeDataType i ON i.DataTypeID = k.DataTypeID
			WHERE AttributeNameID = 4

			UNION

			SELECT CAST(NominalOD AS NVARCHAR(50)) AS AttrbiuteValue, AttributeName, AttributeNameID, i.DataType, ItemNumber
			FROM Setup.ItemAttributes CROSS APPLY Setup.ApsSetupAttributes k INNER JOIN Setup.AttributeDataType i ON i.DataTypeID = k.DataTypeID
			WHERE AttributeNameID = 3

			UNION

			SELECT  CAST(FiberCount AS NVARCHAR(50)) AS AttrbiuteValue, AttributeName, AttributeNameID, i.DataType, ItemNumber
			FROM Setup.ItemAttributes CROSS APPLY Setup.ApsSetupAttributes k INNER JOIN Setup.AttributeDataType i ON i.DataTypeID = k.DataTypeID
			WHERE AttributeNameID = 7
		)
		INSERT INTO Mes.ItemSetupAttributes([Setup],MachineID,AttributeNameID,Item_Number, AttributeValue)
		SELECT DISTINCT P.Setup, M.MachineID, K.AttributeNameID, I.item_number, K.AttrbiuteValue
		FROM cteAttributes K INNER JOIN Setup.vRoutesUnion I ON K.ItemNumber = I.item_number 
		INNER JOIN Setup.vMachineCapability P ON P.Setup = I.true_operation_code 
		INNER JOIN MES.MachineAttributes M ON M.MachineID = P.MachineID AND K.AttributeNameID = M.AttributeNameID

		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
 
		PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
		PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
		THROW;
	END CATCH;


END



GO
