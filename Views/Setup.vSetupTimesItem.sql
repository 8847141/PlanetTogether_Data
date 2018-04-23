SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






/*
Author:		Bryan Eddy
Desc:		Interface view with PlanetTogether.  Only passes setups the scheduler chooses and informationw we want to pass to PlanetTogether (APS).
Date:		4/23/2018	
Version:	2
Update:		Added MachineGroupID to the fields displayed

*/



/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [Setup].[vSetupTimesItem]
AS
SELECT  Item_Number
		,K.[Setup]
		,AttributeName
		,k.AttributeNameID
      ,[SetupAttributeValue]
      ,[SetupTime]
      ,MachineName
	  ,V.ValueTypeID
	  ,ValueTypeName
	  ,ValueTypeDescription	
	  ,LogicType
	  ,ApsData
	  ,I.MachineID
	  ,E.MachineGroupID
  FROM [Setup].AttributeSetupTimeItem K
  INNER JOIN setup.MachineGroupAttributes G ON K.MachineGroupID = G.MachineGroupID AND G.AttributeNameID = K.AttributeNameID
  INNER JOIN SETUP.ApsSetupAttributeValueType V ON V.ValueTypeID = G.ValueTypeID
  INNER JOIN Setup.ApsSetupAttributes A ON A.AttributeNameID = G.AttributeNameID
  INNER JOIN Scheduling.MachineCapabilityScheduler I ON I.MachineID = K.MachineID AND I.Setup = K.Setup
  INNER JOIN Setup.MachineNames E ON E.MachineID = I.MachineID
  WHERE I.ActiveScheduling = 1 AND g.PassToAps = 1
 







GO
