SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*
Author:		Bryan Eddy
Date:		3/14/2018
Desc:		View for SSRS reporting
Version:	1
Update:		n/a
Note:		OD first uses OD from Setup information else it uses OD from item.  Item OD and setup OD are not the same.  
			This will not be accurate for all items, just tubes, and sheathing.  Not cabling.
			Color does not apply to sheathing
*/

CREATE VIEW [Scheduling].[vProductionSchedule]
AS
SELECT r.*, m.Plant, M.Department, M.DepartmentID, COALESCE(I.NominalOD, A.NominalOD) AS NominalOD
, I.NumberCorePositions, i.UJCM UpJacketCM, I.JacketMaterial, I.EndsOfAramid
, CASE WHEN R.promise_date < GETDATE() THEN ROUND(CAST(DATEDIFF(MINUTE,R.promise_date, R.planned_setup_start) AS FLOAT)/60/24,3) END AS PromiseLatenessDays 
, A.FiberCount, CASE WHEN M.DepartmentID = 5 AND A.Printed = 1 THEN A.CableColor + ' ----' ELSE A.CableColor END AS CableColor, A.Printed
FROM Setup.vMachineNames M RIGHT JOIN dbo._report_4a_production_master_schedule R ON r.current_op_machine = m.MachineName
LEFT JOIN Setup.ItemAttributes A ON A.ItemNumber = R.part_no
LEFT JOIN SETUP.ItemSetupAttributes I ON I.Setup = R.setup AND I.ItemNumber = R.part_no
WHERE R.planned_setup_start < GETDATE() + 60 
GO
