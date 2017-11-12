SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







-- =============================================
-- Author:      Bryan Eddy
-- Create date: 8/22/2017
-- Description: Create all combinations for buffering compound From To logic
-- =============================================
CREATE PROCEDURE [Setup].[usp_CreateBufferingMatrix]
AS
BEGIN
	SET NOCOUNT ON;
	;WITH
	cteBufferingJacket
	AS(
		SELECT DISTINCT I.MachineName,g.item_number AS FromAttribute, k.item_number AS ToAttribute, 5 AS AttributeNameID, 
		CASE WHEN G.attribute_value = k.attribute_value THEN 0
			WHEN G.attribute_value = 'PBT' AND k.attribute_value IN('HDPE','LSZH','MDPE') THEN 30
			WHEN G.attribute_value = 'MDPE' AND k.attribute_value IN('HDPE','LSZH','PBT','POLYURETHANE','SANTOPRENE') THEN 30
			WHEN G.attribute_value = 'HDPE' AND k.attribute_value IN('HDPE','LSZH','PBT','POLYURETHANE','SANTOPRENE') THEN 120
			WHEN G.attribute_value = 'PVC' THEN 120
			WHEN G.attribute_value IN ('LSZH','PVDF','TRC','TPU','HYTREL','POLYURETHANE','SANTOPRENE','PBT','HDPE','TPX') THEN 240
			WHEN G.attribute_value = 'Nylon'THEN 360
			ELSE 0
			END AS Timevalue
		FROM dbo.Oracle_Item_Attributes K CROSS APPLY dbo.Oracle_Item_Attributes G CROSS APPLY Setup.MachineNames I
		WHERE K.attribute_name = 'Jacket' AND g.attribute_name = 'Jacket'  AND MachineGroupID = 2
	)
	INSERT INTO Setup.AttributeMatrixFromTo(FromAttribute, ToAttribute, TimeValue, MachineID, AttributeNameID)
	SELECT K.FromAttribute, K.ToAttribute, K.Timevalue, G.MachineID, K.AttributeNameID
	FROM cteBufferingJacket K LEFT JOIN SETUP.AttributeMatrixFromTo G ON G.FromAttribute = K.FromAttribute AND G.ToAttribute = G.ToAttribute
	WHERE G.FromAttribute IS NULL OR G.ToAttribute IS NULL


END

GO
