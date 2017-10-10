SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [Setup].[vAttributeMatrixUnion]
AS
WITH cteAttributeMatrixUnion
as(
	SELECT AttributeNameID, MachineName, TimeValue, cost , NULL FromAttribute, NULL ToAttribute, NULL  AttributeValue, Adder
  FROM [Setup].AttributeMatrixFixedValue

  UNION ALL

  SELECT AttributeNameID, MachineName, TimeValue, cost, FromAttribute, ToAttribute, NULL  AttributeValue, 0 Adder
  FROM Setup.AttributeMatrixFromTo

  UNION ALL

  SELECT AttributeNameID, MachineName, TimeValue, cost , NULL FromAttribute, NULL ToAttribute, AttributeValue, 0 Adder
  FROM Setup.AttributeMatrixVariableValue
  )

  SELECT U.AttributeName,K.*, T.ValueTypeID, T.LogicType, P.ValueTypeName, P.ValueTypeDescription, T.MachineGroupID
  FROM cteAttributeMatrixUnion K INNER JOIN Setup.MachineNames G ON G.MachineName = K.MachineName
  INNER JOIN setup.MachineGroupAttributes T ON T.AttributeNameID = K.AttributeNameID AND T.MachineGroupID = G.MachineGroupID
  INNER JOIN SETUP.ApsSetupAttributeValueType P ON P.ValueTypeID = T.ValueTypeID
  INNER JOIN SETUP.ApsSetupAttributes U ON U.AttributeNameID = K.AttributeNameID


GO
