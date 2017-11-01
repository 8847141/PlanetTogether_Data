SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






-- =============================================
-- Author:      Bryan Eddy
-- Create date: 8/11/2017
-- Description: Create setup times for all attributes from Setup DB
-- =============================================

CREATE PROCEDURE [Setup].[usp_CalculateSetupTimesFromSetupDB]
AS
	SET NOCOUNT ON;
	--Insert fixed time values for setup times
	INSERT INTO [Setup].AttributeSetupTime ([Setup],[MachineGroupID],[MachineName],AttributeNameID,[SetupAttributeValue],[SetupTime])
	SELECT DISTINCT Setup, g.MachineGroupID, g.MachineName,g.AttributeNameID, g.TimeValue,G.TimeValue
	  FROM [Setup].[vAttributeMatrixUnion] G INNER JOIN Setup.vMachineCapability K ON K.MachineName = G.MachineName
	  WHERE G.ValueTypeID = 1

  
	--Insert calculated attribute values for 
	INSERT INTO [Setup].AttributeSetupTime ([Setup],[MachineGroupID],[MachineName],AttributeNameID,[SetupAttributeValue],[SetupTime])
	SELECT distinct SetupNumber, G.MachineGroupID,MachineName, G.AttributeNameID, COALESCE(G.AttributeValue,'0'), TimeValue--, G.AttributeName, K.ValueTypeID,k.ValueTypeDescription
	  FROM [Setup].[vMachineSetupAttributes] G
	  INNER JOIN setup.vAttributeMatrixUnion K ON K.AttributeNameID = G.[AttributeNameID] AND K.MachineGroupID = G.MachineGroupID  and k.MachineName = g.PlanetTogetherMachineNumber
	  AND K.ValueTypeID = G.ValueTypeID
	where k.ValueTypeID = 2 --and  K.ATTRIBUTENAMEID = 1

	--Insert calulcated setup times for fixed value setups
	;WITH cteMultiply
	AS(
		SELECT SetupNumber, G.MachineGroupID,MachineName, G.AttributeNameID, 
		CASE WHEN ISNUMERIC(G.AttributeValue)<>1 THEN 0 ELSE (CAST(G.AttributeValue AS FLOAT))END  AS AttributeValue
		, CASE WHEN ISNUMERIC(G.AttributeValue)<>1 THEN 0 ELSE (CAST(G.AttributeValue AS FLOAT) * TimeValue) + COALESCE(K.Adder,0) END AS SetupTime
		  FROM [Setup].[vMachineSetupAttributes] G
		  INNER JOIN setup.vAttributeMatrixUnion K ON K.AttributeNameID = G.[AttributeNameID] AND K.MachineGroupID = G.MachineGroupID  AND k.MachineName = g.PlanetTogetherMachineNumber
		  AND K.ValueTypeID = G.ValueTypeID
		WHERE k.ValueTypeID = 3 --and G.SetupNumber = 'z089'
	)
	INSERT INTO [Setup].AttributeSetupTime ([Setup],[MachineGroupID],[MachineName],AttributeNameID,[SetupAttributeValue],[SetupTime])
	SELECT SetupNumber, MachineGroupID, MachineName, AttributeNameID,SUM(AttributeValue), SUM(SetupTime)
	FROM cteMultiply
	GROUP BY  SetupNumber, MachineGroupID, MachineName, AttributeNameID
	--ORDER BY MachineName


	--Insert From To setup values from Setup DB
	INSERT INTO [Setup].AttributeSetupTime ([Setup],[MachineGroupID],[MachineName],AttributeNameID,[SetupAttributeValue],[SetupTime])
	SELECT DISTINCT SetupNumber, G.MachineGroupID,PlanetTogetherMachineNumber, G.AttributeNameID,
	CASE WHEN G.AttributeNameID = 34 AND COALESCE(AttributeValue,'0') <> '0' THEN '1'
		 ELSE COALESCE(AttributeValue,'0') END , NULL
	  FROM [Setup].[vMachineSetupAttributes] G
	WHERE G.ValueTypeID = 5 AND  G.AttributeNameID <> 34

	--Insert From to Setup for glue.  
	INSERT INTO [Setup].AttributeSetupTime ([Setup],[MachineGroupID],[MachineName],AttributeNameID,[SetupAttributeValue],[SetupTime])
	SELECT DISTINCT SetupNumber, G.MachineGroupID,PlanetTogetherMachineNumber, G.AttributeNameID,
	CASE WHEN G.AttributeNameID = 34 AND COALESCE(AttributeValue,'0') <> '0' THEN '1'
		 ELSE COALESCE(AttributeValue,'0') END , NULL
	  FROM [Setup].[vMachineSetupAttributesNulls] G
	WHERE G.ValueTypeID = 5 AND  G.AttributeNameID = 34



	--Insert buffering setup as the SetupAttributeValue
	INSERT INTO [Setup].AttributeSetupTime ([Setup],[MachineGroupID],[MachineName],AttributeNameID,[SetupAttributeValue],[SetupTime])
	SELECT DISTINCT Setup, K.MachineGroupID, P.MachineName,K.AttributeNameID, Setup,T.TimeValue
	FROM SETUP.MachineGroupAttributes k INNER JOIN SETUP.MachineNames P ON P.MachineGroupID = K.MachineGroupID
	INNER JOIN setup.vMachineCapability G ON P.MachineName = G.MachineName
	INNER JOIN SETUP.AttributeMatrixFixedValue T ON T.MachineName = P.MachineName AND T.AttributeNameID = K.AttributeNameID
	WHERE K.AttributeNameID = 33

	INSERT INTO setup.AttributeSetupTime ([Setup],[MachineGroupID],[MachineName],AttributeNameID,[SetupAttributeValue],[SetupTime])
	SELECT DISTINCT setup,K.MachineGroupID, P.MachineName, K.AttributeNameID, NULL,T.TimeValue
	FROM SETUP.MachineGroupAttributes k INNER JOIN SETUP.MachineNames P ON P.MachineGroupID = K.MachineGroupID
	INNER JOIN setup.vMachineCapability G ON P.MachineName = G.MachineName
	INNER JOIN SETUP.AttributeMatrixFixedValue T ON T.MachineName = P.MachineName AND T.AttributeNameID = K.AttributeNameID
	WHERE ApsData = 1



GO
