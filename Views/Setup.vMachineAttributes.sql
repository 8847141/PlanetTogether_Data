SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE VIEW [Setup].[vMachineAttributes]
AS
SELECT        Setup.ApsSetupAttributes.AttributeName, Setup.MachineGroupAttributes.LogicType, Setup.ApsSetupAttributeValueType.ValueTypeName, 
                         Setup.ApsSetupAttributeValueType.ValueTypeDescription, Setup.MachineGroup.MachineGroupName, 
                         Setup.MachineGroupAttributes.ValueTypeID, Setup.MachineGroupAttributes.AttributeNameID, Setup.MachineGroupAttributes.MachineGroupID,
						 setup.MachineGroupAttributes.ApsData, MachineID
FROM            Setup.ApsSetupAttributes INNER JOIN
                         Setup.MachineGroupAttributes ON Setup.ApsSetupAttributes.AttributeNameID = Setup.MachineGroupAttributes.AttributeNameID INNER JOIN
                         Setup.ApsSetupAttributeValueType ON Setup.MachineGroupAttributes.ValueTypeID = Setup.ApsSetupAttributeValueType.ValueTypeID INNER JOIN
                         Setup.MachineGroup ON Setup.MachineGroupAttributes.MachineGroupID = Setup.MachineGroup.MachineGroupID INNER JOIN
                         Setup.MachineNames ON Setup.MachineGroup.MachineGroupID = Setup.MachineNames.MachineGroupID






GO
