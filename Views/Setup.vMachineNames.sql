SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
Author:			Bryan Eddy
Description:	View for PT to get information on machine resources
Version:		1
Update:			Added header and ManualSchedule field



*/

CREATE VIEW [Setup].[vMachineNames]
AS
SELECT        MachineID, MachineName, MachineGroupID, Plant, Department, ShareResource, Grouping, CapacityTypeID, MachineRunEffeciency, MachineSetupEffeciency
			,ManualSchedule
FROM            Setup.MachineNames
GO
