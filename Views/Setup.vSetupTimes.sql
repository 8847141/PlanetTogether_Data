SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [Setup].[vSetupTimes]
AS
SELECT  [Setup]
		,AttributeName
		,k.AttributeNameID
      ,[SetupAttributeValue]
      ,[SetupTime]
      ,MachineName
	  ,V.ValueTypeID
	  ,ValueTypeName
	  ,ValueTypeDescription	
	  ,LogicType
	  ,G.MachineGroupID
	  ,K.MachineID
  FROM [Setup].AttributeSetupTime K
  INNER JOIN setup.MachineGroupAttributes G ON K.MachineGroupID = G.MachineGroupID AND G.AttributeNameID = K.AttributeNameID
  INNER JOIN SETUP.ApsSetupAttributeValueType V ON V.ValueTypeID = G.ValueTypeID
  INNER JOIN Setup.ApsSetupAttributes A ON A.AttributeNameID = G.AttributeNameID
   INNER JOIN Setup.MachineNames E ON E.MachineID = K.MachineID





GO
