SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Setup].[vMachineNames]
as
SELECT        MachineID, MachineName, MachineGroupID, Plant, Department, ShareResource, Grouping, CapacityTypeID, MachineRunEffeciency, MachineSetupEffeciency
FROM            Setup.MachineNames
GO
