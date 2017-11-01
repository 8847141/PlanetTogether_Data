SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [Setup].[vSetupTimesItem]
AS
SELECT  Item_Number
		,K.[Setup]
		,AttributeName
		,k.AttributeNameID
      ,[SetupAttributeValue]
      ,[SetupTime]
      ,K.[MachineName]
	  ,V.ValueTypeID
	  ,ValueTypeName
	  ,ValueTypeDescription	
	  ,LogicType
	  ,ApsData
  FROM [Setup].AttributeSetupTimeItem K
  INNER JOIN setup.MachineGroupAttributes G ON K.MachineGroupID = G.MachineGroupID AND G.AttributeNameID = K.AttributeNameID
  INNER JOIN SETUP.ApsSetupAttributeValueType V ON V.ValueTypeID = G.ValueTypeID
  INNER JOIN Setup.ApsSetupAttributes A ON A.AttributeNameID = G.AttributeNameID
  INNER JOIN Scheduling.MachineCapabilityScheduler I ON I.MachineName = K.MachineName AND I.Setup = K.Setup
  WHERE I.ActiveScheduling = 1
 






GO
