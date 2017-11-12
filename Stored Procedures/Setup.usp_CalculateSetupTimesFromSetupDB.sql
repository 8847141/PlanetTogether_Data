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
	INSERT INTO [Setup].AttributeSetupTime ([Setup],[MachineGroupID],MachineID,AttributeNameID,[SetupAttributeValue],[SetupTime])
	SELECT DISTINCT Setup, g.MachineGroupID, g.MachineID,g.AttributeNameID, g.TimeValue,G.TimeValue
	  FROM [Setup].[vAttributeMatrixUnion] G INNER JOIN Setup.vMachineCapability K ON K.MachineID= G.MachineID
	  WHERE G.ValueTypeID = 1

	--Insert calculated attribute values for 
	;WITH cteChange
	as(
	SELECT distinct SetupNumber, G.MachineGroupID,g.MachineID, G.AttributeNameID, COALESCE(G.AttributeValue,'0') AttributeValue, TimeValue, G.AttributeName, K.ValueTypeID,k.ValueTypeDescription
	,ROW_NUMBER() OVER (PARTITION BY SetupNumber, G.MachineGroupID,g.MachineID, G.AttributeNameID ORDER BY SetupNumber, G.MachineGroupID,g.MachineID, G.AttributeNameID,COALESCE(G.AttributeValue,'0') DESC) RowNumber
	  FROM [Setup].[vMachineSetupAttributes] G
	  INNER JOIN setup.vAttributeMatrixUnion K ON K.AttributeNameID = G.[AttributeNameID] AND K.MachineGroupID = G.MachineGroupID  and k.MachineID= g.MachineID
	  AND K.ValueTypeID = G.ValueTypeID
	where k.ValueTypeID = 2 --and  G.SetupNumber = 'R045'
	)
	INSERT INTO [Setup].AttributeSetupTime ([Setup],[MachineGroupID],MachineID,AttributeNameID,[SetupAttributeValue],[SetupTime])
	SELECT SetupNumber, cteChange.MachineGroupID, cteChange.MachineID, cteChange.AttributeNameID, cteChange.AttributeValue, cteChange.TimeValue
	FROM cteChange
	WHERE cteChange.RowNumber = 1

	--Insert calulcated setup times for fixed value setups
	;WITH cteMultiply
	AS(
		SELECT SetupNumber, G.MachineGroupID,g.MachineID, G.AttributeNameID, 
		CASE WHEN ISNUMERIC(G.AttributeValue)<>1 THEN 0 ELSE (CAST(G.AttributeValue AS FLOAT))END  AS AttributeValue
		, CASE WHEN ISNUMERIC(G.AttributeValue)<>1 THEN 0 ELSE (CAST(G.AttributeValue AS FLOAT) * TimeValue) + COALESCE(K.Adder,0) END AS SetupTime
		  FROM [Setup].[vMachineSetupAttributes] G
		  INNER JOIN setup.vAttributeMatrixUnion K ON K.AttributeNameID = G.[AttributeNameID] AND K.MachineGroupID = G.MachineGroupID  AND k.MachineID= g.MachineID
		  AND K.ValueTypeID = G.ValueTypeID
		WHERE k.ValueTypeID = 3 --and G.SetupNumber = 'z089'
	)
	INSERT INTO [Setup].AttributeSetupTime ([Setup],[MachineGroupID],MachineID,AttributeNameID,[SetupAttributeValue],[SetupTime])
	SELECT SetupNumber, MachineGroupID, MachineID, AttributeNameID,SUM(AttributeValue), SUM(SetupTime)
	FROM cteMultiply
	GROUP BY  SetupNumber, MachineGroupID, MachineID, AttributeNameID
	--ORDER BY MachineName


	--Insert From To setup values from Setup DB
	INSERT INTO [Setup].AttributeSetupTime ([Setup],[MachineGroupID],MachineID,AttributeNameID,[SetupAttributeValue],[SetupTime])
	SELECT DISTINCT SetupNumber, G.MachineGroupID,MachineID, G.AttributeNameID,
	CASE WHEN G.AttributeNameID = 34 AND COALESCE(AttributeValue,'0') <> '0' THEN '1'
		 ELSE COALESCE(AttributeValue,'0') END , NULL
	  FROM [Setup].[vMachineSetupAttributes] G
	WHERE G.ValueTypeID = 5 AND  G.AttributeNameID <> 34

	--Insert From to Setup for glue.  
	INSERT INTO [Setup].AttributeSetupTime ([Setup],[MachineGroupID],MachineID,AttributeNameID,[SetupAttributeValue],[SetupTime])
	SELECT DISTINCT SetupNumber, G.MachineGroupID,MachineID, G.AttributeNameID,
	CASE WHEN G.AttributeNameID = 34 AND COALESCE(AttributeValue,'0') <> '0' THEN '1'
		 ELSE COALESCE(AttributeValue,'0') END , NULL
	  FROM [Setup].[vMachineSetupAttributesNulls] G
	WHERE G.ValueTypeID = 5 AND  G.AttributeNameID = 34



	--Insert buffering setup as the SetupAttributeValue
	INSERT INTO [Setup].AttributeSetupTime ([Setup],[MachineGroupID],MachineID,AttributeNameID,[SetupAttributeValue],[SetupTime])
	SELECT DISTINCT Setup, K.MachineGroupID, P.MachineID,K.AttributeNameID, Setup,T.TimeValue
	FROM SETUP.MachineGroupAttributes k INNER JOIN SETUP.MachineNames P ON P.MachineGroupID = K.MachineGroupID
	INNER JOIN setup.vMachineCapability G ON P.MachineID= G.MachineID
	INNER JOIN SETUP.AttributeMatrixFixedValue T ON T.MachineID = P.MachineID AND T.AttributeNameID = K.AttributeNameID
	WHERE K.AttributeNameID = 33

	INSERT INTO setup.AttributeSetupTime ([Setup],[MachineGroupID],MachineID,AttributeNameID,[SetupAttributeValue],[SetupTime])
	SELECT DISTINCT setup,K.MachineGroupID, P.MachineID, K.AttributeNameID, NULL,T.TimeValue
	FROM SETUP.MachineGroupAttributes k INNER JOIN SETUP.MachineNames P ON P.MachineGroupID = K.MachineGroupID
	INNER JOIN setup.vMachineCapability G ON P.MachineID= G.MachineID
	INNER JOIN SETUP.AttributeMatrixFixedValue T ON T.MachineID = P.MachineID AND T.AttributeNameID = K.AttributeNameID
	WHERE ApsData = 1




GO
