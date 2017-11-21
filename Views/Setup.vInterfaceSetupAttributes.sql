SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO











/*Interface view of needed information from the Recipe Management Syste / PSS DB*/
CREATE VIEW [Setup].[vInterfaceSetupAttributes]
AS
SELECT        Setup.tblProcessMachines.ProcessID,
                         Setup.tblAttributes.AttributeID, Setup.tblAttributes.AttributeDesc, Setup.tblAttributes.AttributeName, Setup.tblSetup.SetupID, Setup.tblSetup.SetupNumber, 
                         Setup.tblSetupAttributes.AttributeValue, Setup.tblSetupAttributes.MachineSpecific, Setup.tblSetupAttributes.MinValue, Setup.tblAttributes.Active, 
                         Setup.tblSetupAttributes.EffectiveDate, Setup.tblAttributes.AttrEffectiveDate, Setup.tblAttributes.AttributeGroupID, Setup.tblSetup.IneffectiveDate, 
                         Setup.tblAttributes.AttributeUOM, Setup.tblAttributes.AttrIneffectiveDate AS AttributeIneffectiveDate, 
                         Setup.tblSetupAttributes.IneffectiveDate AS SetupAttributesIneffectiveDate, Setup.tblProcessMachines.MachineNumber, tblProcessMachines.MachineID AS PssMachineID
						 ,tblProcessMachines.ProcessID AS PssProcessID
FROM            Setup.tblAttributes INNER JOIN
                         Setup.tblSetupAttributes ON Setup.tblAttributes.AttributeID = Setup.tblSetupAttributes.AttributeID INNER JOIN
                         Setup.tblSetup ON Setup.tblSetupAttributes.SetupID = Setup.tblSetup.SetupID AND Setup.tblSetupAttributes.MachineID = Setup.tblSetup.MachineID INNER JOIN
                         Setup.tblProcessMachines ON Setup.tblSetup.MachineID = Setup.tblProcessMachines.MachineID AND 
                         Setup.tblSetup.ProcessID = Setup.tblProcessMachines.ProcessID
						 
WHERE        (Setup.tblAttributes.AttrIneffectiveDate >= GETDATE()) AND (Setup.tblSetup.IneffectiveDate >= GETDATE()) AND (Setup.tblSetupAttributes.IneffectiveDate >= GETDATE()) 
                         AND (Setup.tblProcessMachines.Active <> 0) 

						 









GO
