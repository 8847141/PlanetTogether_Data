SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*
Author:		Bryan Eddy
Date:		4/3/2018
Desc:		Display jobs with status conflicts.  Created to report issues with jobs having process status conflicts.  Example: Two simultaneous operations running for a single job
Version:	2
Update:		Added additional fields to display in the email alert
*/
CREATE VIEW [Scheduling].[vDjStatusConflict]
AS


WITH

next_op
AS
(
SELECT        r.wip_entity_name, r.operation_seq_num AS c_op, MIN(r2.operation_seq_num) AS n_op
                          FROM            dbo.Oracle_DJ_Routes AS r LEFT OUTER JOIN
                                                    dbo.Oracle_DJ_Routes AS r2 ON r.wip_entity_name = r2.wip_entity_name AND r.operation_seq_num < r2.operation_seq_num
                          GROUP BY r.wip_entity_name, r.operation_seq_num
),

op_status
AS
(
SELECT        n.wip_entity_name, n.c_op, cr.true_operation_seq_num AS c_true_op, cr.dj_status AS c_status, cp.setup_start_time AS c_setup_start_time, cp.run_start_time AS c_run_start, cr.op_quantity_completed AS c_qty_complete, cr.start_quantity AS c_qty_start, n.n_op, nr.true_operation_seq_num AS n_true_op, nr.op_quantity_completed AS n_qty_completed,
				CASE WHEN (cr.op_quantity_completed >= cr.start_quantity) OR (nr.op_quantity_completed > 0) OR (cr.dj_status IN ('Complete','Closed')) THEN 'finished' 
				WHEN (cr.op_quantity_completed > 0) OR (cp.run_start_time IS NOT NULL) THEN 'running' 
				WHEN (cp.setup_start_time IS NOT NULL) THEN 'settingup' ELSE 'ready_wait' END AS p_status, cr.operation_code
				, cr.department_code, cp.run_end_time, cr.op_quantity_completed, cr.start_quantity
FROM            next_op AS n INNER JOIN	
				Oracle_DJ_Routes AS cr ON n.wip_entity_name = cr.wip_entity_name AND n.c_op = cr.operation_seq_num LEFT OUTER JOIN
				Oracle_DJ_Processing_Times AS cp ON n.wip_entity_name = cp.wip_entity_name AND n.c_op = cp.op_sequence LEFT OUTER JOIN
				Oracle_DJ_Routes AS nr ON n.wip_entity_name = nr.wip_entity_name AND n.n_op = nr.operation_seq_num
),

running_counts
AS
(
 SELECT wip_entity_name, COUNT(p_status) AS [count] FROM op_status
 WHERE p_status = 'running'
 GROUP BY wip_entity_name
)

	SELECT o.wip_entity_name, o.c_op AS operation_seq_num, o.n_true_op AS true_operation_seq_num, o.c_status, o.p_status, o.operation_code, o.department_code
	, o.c_setup_start_time, o.c_run_start, o.run_end_time, o.op_quantity_completed, o.start_quantity
	FROM op_status o INNER JOIN
	running_counts r ON o.wip_entity_name = r.wip_entity_name
	WHERE [count] > 1


GO
