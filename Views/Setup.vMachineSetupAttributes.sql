SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








/* This view is designed to give values of 0 when the attribute does not appear in the Setup Attribute data.
Use limited.  Only glue calculation is using this view at this time*/

CREATE VIEW [Setup].[vMachineSetupAttributes]
AS

	SELECT     DISTINCT  p.Setup AS SetupNumber, I.AttributeValue, K.AttributeName SetupAttributeName, G.AttributeID, K.MachineID, G.AttributeNameID, I.AttributeName,
				K.MachineGroupID, K.ValueTypeDescription, K.ValueTypeName, K.ValueTypeID, K.MachineGroupName
	FROM            Setup.vMachineAttributes AS K INNER JOIN
							 Setup.ApsSetupAttributeReference AS G ON G.AttributeNameID = K.AttributeNameID INNER JOIN
							 Setup.vMachineCapability AS P ON P.machineID = K.machineID 
							 INNER JOIN setup.MachineReference O ON O.MachineID = P.MachineID
							 INNER JOIN Setup.vInterfaceSetupAttributes AS I ON G.AttributeID = I.AttributeID AND I.PssMachineID = O.PssMachineID AND I.SetupNumber = P.Setup AND O.PssProcessID = I.PssProcessID
	--WHERE G.SourceID	= 1000  AND P.Setup LIKE '1701'--AND K.MachineName = 'sz07'--AND VALUETYPEID = 5--

--AND cteSetup.SetupAttributeName = 'glue' AND cteSetup.PlanetTogetherMachineNumber = 'sz07'








GO
