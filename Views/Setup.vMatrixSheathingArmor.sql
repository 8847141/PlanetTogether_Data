SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [Setup].[vMatrixSheathingArmor]
AS

SELECT DISTINCT G.AttributeValue AS FromAttribute, k.AttributeValue as ToAttribute, 
CASE WHEN G.AttributeValue = k.AttributeValue THEN 0
	WHEN G.AttributeValue is null AND k.AttributeValue is not null THEN 120
	WHEN  G.AttributeValue is null AND k.AttributeValue is  null THEN 0
	WHEN  G.AttributeValue is NOT null AND k.AttributeValue is  null THEN 60
	WHEN G.AttributeValue <> K.AttributeValue THEN 120
	END AS Timevalue
FROM setup.vMasterSetup K CROSS APPLY setup.vMasterSetup G 
WHERE k.AttributeID = 850031 and g.AttributeID = 850031 

GO
