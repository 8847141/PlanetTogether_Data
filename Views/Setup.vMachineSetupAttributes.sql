SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [Setup].[vMachineSetupAttributes]
AS
WITH cteSetup
AS(
	SELECT     DISTINCT  p.Setup AS SetupNumber, I.AttributeValue, K.AttributeName SetupAttributeName, G.AttributeID, K.MachineName AS PlanetTogetherMachineNumber, G.AttributeNameID, I.AttributeName,
				K.MachineGroupID, K.ValueTypeDescription, K.ValueTypeName, K.ValueTypeID, K.MachineGroupName
				,ROW_NUMBER() OVER (PARTITION BY p.Setup,G.AttributeNameID,
				MachineGroupID, ValueTypeID, K.MachineGroupID, K.MachineName  ORDER BY P.SETUP,g.AttributeNameID, CASE WHEN I.AttributeValue IS NULL THEN 1 ELSE 0 END, EffectiveDate DESC ) AS RowNumber
	FROM            Setup.vMachineAttributes AS K INNER JOIN
							 Setup.ApsSetupAttributeReference AS G ON G.AttributeNameID = K.AttributeNameID INNER JOIN
							 Setup.vMachineCapability AS P ON P.MachineName = K.MachineName LEFT JOIN
							 Setup.vInterfaceSetupAttributes AS I ON G.AttributeID = I.AttributeID AND I.PlanetTogetherMachineNumber = K.MachineName AND I.SetupNumber = P.Setup 
	WHERE G.SourceID	= 1000  --AND K.MachineName = 'sz07'--AND VALUETYPEID = 5--AND P.Setup LIKE '1701'
)
SELECT *
FROM cteSetup
WHERE cteSetup.RowNumber = 1
--AND cteSetup.SetupAttributeName = 'glue' AND cteSetup.PlanetTogetherMachineNumber = 'sz07'

GO
