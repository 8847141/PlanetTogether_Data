SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE VIEW [Setup].[vMatrixSheathingArmor]
AS

SELECT DISTINCT G.AttributeValue AS FromAttribute, k.AttributeValue AS ToAttribute,
CASE WHEN G.AttributeValue = k.AttributeValue THEN 0
	WHEN G.AttributeValue IS NULL AND k.AttributeValue IS NOT NULL THEN 120
	WHEN  G.AttributeValue IS NULL AND k.AttributeValue IS  NULL THEN 0
	WHEN  G.AttributeValue IS NOT NULL AND k.AttributeValue IS  NULL THEN 60
	WHEN G.AttributeValue <> K.AttributeValue THEN 120
	END AS Timevalue
FROM setup.vMasterSetup K CROSS APPLY setup.vMasterSetup G 
WHERE k.AttributeNameID = 1 AND g.AttributeNameID = 1 

GO
