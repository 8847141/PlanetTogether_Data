SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO









-- =============================================
-- Author:      Bryan Eddy
-- Create date: 7/31/2017
-- Description: Create all combinations for sheathing compound To From logic
-- Version: 2
-- Update:	Updated color time value logic and added MachineID to sheathing compound logic
-- =============================================
CREATE PROCEDURE [Setup].[usp_CreateSheathingMatrix]
AS
	SET NOCOUNT ON;
BEGIN

DECLARE @ErrorNumber INT = ERROR_NUMBER();
DECLARE @ErrorLine INT = ERROR_LINE();

	BEGIN TRY
		BEGIN TRAN
			--delete from Setup.ToFromAttributeMatrix;
			;WITH cteSheathingJacket
			AS (
			SELECT G.item_number AS FromAttribute, k.item_number AS ToAttribute, MachineID,5 AS AttributeNameID,
			CASE WHEN g.item_number = k.item_number THEN 0
			WHEN G.attribute_value = k.attribute_value THEN 0.33*60
				WHEN G.attribute_value = 'PVC'  THEN 1*60
				WHEN G.attribute_value = 'PVDF'  THEN 3*60
				WHEN G.attribute_value = 'NYLON' THEN 6*60
				WHEN G.attribute_value <> K.attribute_value THEN 2.25*60
				ELSE 99999
				END AS Timevalue
				FROM dbo.Oracle_Item_Attributes K CROSS APPLY dbo.Oracle_Item_Attributes G CROSS APPLY Setup.MachineNames I
				WHERE K.attribute_name = 'Jacket' AND g.attribute_name = 'Jacket'  AND MachineGroupID = 8
			)
			INSERT INTO Setup.AttributeMatrixFromTo(FromAttribute,ToAttribute,  TimeValue, MachineID,AttributeNameID)
			SELECT K.FromAttribute,K.ToAttribute,K.Timevalue,K.MachineID, K.AttributeNameID
			FROM cteSheathingJacket K LEFT JOIN SETUP.AttributeMatrixFromTo G ON K.FromAttribute = G.FromAttribute AND K.ToAttribute = G.ToAttribute AND G.MachineID = K.MachineID
			WHERE G.FromAttribute IS NULL
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION; 
		PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
		PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
		THROW;
	END CATCH;



	--Insert Color Matrix in From To Table
	BEGIN TRY
		BEGIN TRAN
			;WITH cteSheathingColor
			AS(
				SELECT DISTINCT G.attribute_value FromAttribute, k.attribute_value ToAttribute,4 AS AttributeNameID,
					 CASE WHEN FromAtt.PreferedSequence = ToAtt.PreferedSequence THEN 0
							WHEN FromAtt.PreferedSequence > ToAtt.PreferedSequence THEN 60
							WHEN fromAtt.PreferedSequence < ToAtt.PreferedSequence THEN 20 
					 ELSE 99999
					 END AS Timevalue, T.MachineID
				FROM dbo.Oracle_Item_Attributes G CROSS APPLY dbo.Oracle_Item_Attributes K
				LEFT JOIN Setup.ColorSequencePreference ToAtt ON ToAtt.Color = K.attribute_value
				LEFT JOIN Setup.ColorSequencePreference FromAtt ON FromAtt.Color = G.attribute_value
				CROSS APPLY Setup.MachineNames T 
				WHERE G.attribute_name = 'COLOR' AND K.attribute_name = 'COLOR' AND T.MachineGroupID = 8
			)
			INSERT INTO Setup.AttributeMatrixFromTo(FromAttribute,ToAttribute,  TimeValue, MachineID,AttributeNameID)
			SELECT DISTINCT K.FromAttribute,K.ToAttribute,K.Timevalue,K.MachineID,K.AttributeNameID--, k.FromAttribute, k.ToAttribute
			FROM cteSheathingColor K
			LEFT JOIN SETUP.AttributeMatrixFromTo G ON K.FromAttribute = G.FromAttribute AND K.ToAttribute = G.ToAttribute AND g.MachineID = K.MachineID
			WHERE   G.FromAttribute IS NULL 
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION; 
		PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
		PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
		THROW;
	END CATCH;


	--Inserting armor matrix in From To table
	BEGIN TRY
		BEGIN TRAN
			INSERT INTO Setup.AttributeMatrixFromTo(FromAttribute,ToAttribute,  TimeValue, AttributeMatrixFromTo.MachineID,AttributeNameID)
			SELECT  DISTINCT COALESCE(K.FromAttribute,'0') FromAttribute,COALESCE(K.ToAttribute,'0') ToAttribute, K.Timevalue, T.MachineID,1 AttributeNameID
			FROM SETUP.vMatrixSheathingArmor K CROSS APPLY SETUP.MachineNames T
			LEFT JOIN SETUP.AttributeMatrixFromTo G ON K.FromAttribute  = G.FromAttribute AND K.ToAttribute = G.ToAttribute AND T.MachineID = G.MachineID
			WHERE T.MachineGroupID = 8 AND  G.FromAttribute IS NULL AND G.ToAttribute IS NULL AND K.FromAttribute <> 0 AND G.FromAttribute <> 0
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
