SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






/*Interface view of needed information from the Recipe Management Syste / PSS DB*/
CREATE VIEW [Setup].[vInterfaceAllMachineSetups]
AS
SELECT        Setup.tblProcessMachines.ProcessID, Setup.tblProcessMachines.MachineID AS PssMachineID, setup.tblProcessMachines.ProcessID AS PssProcessID
				, Setup.tblSetup.SetupID, 
                         Setup.tblSetup.SetupNumber Setup, Setup.tblSetup.IneffectiveDate, Setup.tblProcessMachines.MachineNumber
FROM            Setup.tblSetup INNER JOIN
                         Setup.tblProcessMachines ON Setup.tblSetup.MachineID = Setup.tblProcessMachines.MachineID AND 
                         Setup.tblSetup.ProcessID = Setup.tblProcessMachines.ProcessID
WHERE        (Setup.tblProcessMachines.Active <> 0)






GO
