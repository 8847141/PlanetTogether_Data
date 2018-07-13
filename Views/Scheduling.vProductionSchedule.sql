SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
Author:		Bryan Eddy
Date:		3/14/2018
Desc:		View for SSRS reporting
Version:	2
Update:		Add stage and fiberset to the view
Note:		OD first uses OD from Setup information else it uses OD from item.  Item OD and setup OD are not the same.  
			This will not be accurate for all items, just tubes, and sheathing.  Not cabling.
			Color does not apply to sheathing
*/

CREATE VIEW [Scheduling].[vProductionSchedule]
AS
SELECT R.planned_setup_start,
       R.planned_setup_end,
       R.previous_op_machine,
       R.previous_op_status,
       R.current_op_machine,
       R.current_op_status,
       R.next_op_machine,
       R.dj_number,
       R.sf_group_id,
       R.job,
       R.op,
       R.setup,
       R.customer,
       R.order_number,
       R.order_scheduled_end_date,
       R.oracle_dj_status,
       R.part_no,
       R.job_qty,
       R.ujcm,
       R.earliest_material_availability_date,
       R.need_date,
       R.promise_date,
       R.schedule_ship_date,
       R.scheduled_end_date,
       R.scheduled_run_hours,
       R.scheduled_setup_hours,
       R.scheduled_total_hours,
       R.late_order,
       R.remake,
       R.last_update_date, m.Plant, M.Department, M.DepartmentID, COALESCE(I.NominalOD, A.NominalOD) AS NominalOD
, I.NumberCorePositions, i.UJCM UpJacketCM, I.JacketMaterial, I.EndsOfAramid,r.fiberset, r.stage
, CASE WHEN R.promise_date < GETDATE() THEN ROUND(CAST(DATEDIFF(MINUTE,R.promise_date, R.planned_setup_start) AS FLOAT)/60/24,3) END AS PromiseLatenessDays 
, A.FiberCount, CASE WHEN M.DepartmentID = 5 AND A.Printed = 1 THEN A.CableColor + ' ----' ELSE A.CableColor END AS CableColor, A.Printed
FROM Setup.vMachineNames M RIGHT JOIN dbo._report_4a_production_master_schedule R ON r.current_op_machine = m.MachineName
LEFT JOIN Setup.ItemAttributes A ON A.ItemNumber = R.part_no
LEFT JOIN SETUP.ItemSetupAttributes I ON I.Setup = R.setup AND I.ItemNumber = R.part_no
WHERE R.planned_setup_start < GETDATE() + 60 
GO
