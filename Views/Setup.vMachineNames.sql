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
SELECT        MachineID, MachineName, MachineGroupID, P.Plant, D.Department, ShareResource, Grouping, CapacityTypeID, MachineRunEffeciency, MachineSetupEffeciency
			,ManualSchedule, D.DepartmentID
FROM            Setup.MachineNames M INNER JOIN Setup.Department D ON D.DepartmentID = M.DepartmentID 
				INNER JOIN Setup.Plant P ON P.PlantID = D.PlantID
GO
