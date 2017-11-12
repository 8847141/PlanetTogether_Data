SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






-- =============================================
-- Author:      Bryan Eddy
-- Create date: 7/31/2017
-- Description: Create all combinations for sheathing compound To From logic
-- =============================================
CREATE PROCEDURE [Setup].[usp_CreateSheathingMatrix]
AS
	SET NOCOUNT ON;
BEGIN
	--delete from Setup.ToFromAttributeMatrix;
	;WITH cteSheathingJacket
	AS (
	SELECT G.item_number AS FromAttribute, k.item_number AS ToAttribute, MachineID,5 AS AttributeNameID,
	CASE WHEN G.attribute_value = k.attribute_value THEN 0.33*60
		WHEN G.attribute_value = 'PVC'  THEN 1*60
		WHEN G.attribute_value = 'PVDF'  THEN 3*60
		WHEN G.attribute_value = 'NYLON' THEN 6*60
		WHEN G.attribute_value <> K.attribute_value THEN 2.25*60
		END AS Timevalue
		FROM dbo.Oracle_Item_Attributes K CROSS APPLY dbo.Oracle_Item_Attributes G CROSS APPLY Setup.MachineNames I
		WHERE K.attribute_name = 'Jacket' AND g.attribute_name = 'Jacket'  AND MachineGroupID = 8
	)
	INSERT INTO Setup.AttributeMatrixFromTo(FromAttribute,ToAttribute,  TimeValue, MachineID,AttributeNameID)
	SELECT K.FromAttribute,K.ToAttribute,K.Timevalue,K.MachineID, K.AttributeNameID
	FROM cteSheathingJacket K LEFT JOIN SETUP.AttributeMatrixFromTo G ON K.FromAttribute = G.FromAttribute AND K.ToAttribute = G.ToAttribute
	WHERE G.FromAttribute IS NULL



	--Insert Color Matrix in From To Table

	;WITH cteSheathingColor
	AS(
		SELECT DISTINCT G.attribute_value FromAttribute, k.attribute_value ToAttribute,4 AS AttributeNameID,
			 CASE WHEN G.attribute_value = K.attribute_value OR K.attribute_value = G.attribute_value THEN 0.00
			 WHEN G.attribute_value <> 'BLACK' AND K.attribute_value <>'BLACK' THEN 20.00
			 WHEN G.attribute_value <> 'BLACK' THEN 20.00
			 WHEN G.attribute_value = 'BLACK' THEN 40.00
			 END AS Timevalue
		FROM dbo.Oracle_Item_Attributes G CROSS APPLY dbo.Oracle_Item_Attributes K
		WHERE G.attribute_name = 'COLOR' AND K.attribute_name = 'COLOR'
	)
	INSERT INTO Setup.AttributeMatrixFromTo(FromAttribute,ToAttribute,  TimeValue, MachineID,AttributeNameID)
	SELECT DISTINCT K.FromAttribute,K.ToAttribute,K.Timevalue,t.MachineID,K.AttributeNameID--, k.FromAttribute, k.ToAttribute
	FROM cteSheathingColor K
	CROSS APPLY SETUP.MachineNames T
	LEFT JOIN SETUP.AttributeMatrixFromTo G ON K.FromAttribute = G.FromAttribute AND K.ToAttribute = G.ToAttribute
	WHERE  T.MachineGroupID = 8 AND (G.FromAttribute IS NULL OR g.ToAttribute IS NULL)



	--Inserting armor matrix in From To table
	INSERT INTO Setup.AttributeMatrixFromTo(FromAttribute,ToAttribute,  TimeValue, AttributeMatrixFromTo.MachineID,AttributeNameID)
	SELECT  DISTINCT COALESCE(K.FromAttribute,'0') FromAttribute,COALESCE(K.ToAttribute,'0') ToAttribute, K.Timevalue, T.MachineID,1 AttributeNameID
	FROM SETUP.vMatrixSheathingArmor K CROSS APPLY SETUP.MachineNames T
	LEFT JOIN SETUP.AttributeMatrixFromTo G ON K.FromAttribute  = G.FromAttribute AND K.ToAttribute = G.ToAttribute AND T.MachineID = G.MachineID
	WHERE T.MachineGroupID = 8 AND  G.FromAttribute IS NULL AND G.ToAttribute IS NULL AND K.FromAttribute <> 0 AND G.FromAttribute <> 0


END

GO
