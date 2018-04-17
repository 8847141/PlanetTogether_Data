SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*
Author:		Bryan Eddy
Date:		4/3/2018
Desc:		Display jobs with status conflicts.  Created to report issues with jobs having process status conflicts.  Example: Two simultaneous operations running for a single job
Version:	1
Update:		N/A
*/
CREATE VIEW [Scheduling].[vDjStatusConflict]
AS


WITH

next_op
AS
(
SELECT        r.wip_entity_name, r.operation_seq_num as c_op, MIN(r2.operation_seq_num) AS n_op
                          FROM            dbo.Oracle_DJ_Routes AS r LEFT OUTER JOIN
                                                    dbo.Oracle_DJ_Routes AS r2 ON r.wip_entity_name = r2.wip_entity_name AND r.operation_seq_num < r2.operation_seq_num
                          GROUP BY r.wip_entity_name, r.operation_seq_num
),

op_status
AS
(
SELECT        n.wip_entity_name, n.c_op, cr.true_operation_seq_num as c_true_op, cr.dj_status as c_status, cp.setup_start_time as c_setup_start_time, cp.run_start_time as c_run_start, cr.op_quantity_completed as c_qty_complete, cr.start_quantity as c_qty_start, n.n_op, nr.true_operation_seq_num as n_true_op, nr.op_quantity_completed as n_qty_completed,
				CASE WHEN (cr.op_quantity_completed >= cr.start_quantity) OR (nr.op_quantity_completed > 0) OR (cr.dj_status IN ('Complete','Closed')) THEN 'finished' 
				WHEN (cr.op_quantity_completed > 0) OR (cp.run_start_time IS NOT NULL) THEN 'running' 
				WHEN (cp.setup_start_time IS NOT NULL) THEN 'settingup' ELSE 'ready_wait' END AS p_status
FROM            next_op AS n INNER JOIN	
				Oracle_DJ_Routes as cr ON n.wip_entity_name = cr.wip_entity_name and n.c_op = cr.operation_seq_num LEFT OUTER JOIN
				Oracle_DJ_Processing_Times as cp ON n.wip_entity_name = cp.wip_entity_name and n.c_op = cp.op_sequence LEFT OUTER JOIN
				Oracle_DJ_Routes as nr ON n.wip_entity_name = nr.wip_entity_name and n.n_op = nr.operation_seq_num
),

running_counts
AS
(
 SELECT wip_entity_name, count(p_status) as [count] from op_status
 WHERE p_status = 'running'
 GROUP BY wip_entity_name
)

	SELECT o.wip_entity_name, o.c_op AS operation_seq_num, o.n_true_op AS true_operation_seq_num
	FROM op_status o INNER JOIN
	running_counts r ON o.wip_entity_name = r.wip_entity_name
	where [count] > 1

--SELECT        a.wip_entity_name, a.operation_seq_num, r4.true_operation_seq_num
--FROM            (SELECT        r.wip_entity_name, r.operation_seq_num, MIN(r2.operation_seq_num) AS next_op_seq_num
--                          FROM            dbo.Oracle_DJ_Routes AS r LEFT OUTER JOIN
--                                                    dbo.Oracle_DJ_Routes AS r2 ON r.wip_entity_name = r2.wip_entity_name AND r.operation_seq_num < r2.operation_seq_num
--                          GROUP BY r.wip_entity_name, r.operation_seq_num) AS a INNER JOIN
--                         dbo.Oracle_DJ_Routes AS r3 ON a.wip_entity_name = r3.wip_entity_name AND a.operation_seq_num = r3.operation_seq_num INNER JOIN
--                         dbo.Oracle_DJ_Processing_Times AS p3 ON r3.wip_entity_name = p3.wip_entity_name AND r3.operation_seq_num = p3.op_sequence INNER JOIN
--                         dbo.Oracle_DJ_Routes AS r4 ON a.wip_entity_name = r4.wip_entity_name AND a.operation_seq_num = r4.operation_seq_num
--WHERE        (r3.dj_status NOT IN ('Complete', 'Closed')) AND (r3.op_quantity_completed < r3.start_quantity) AND (r3.op_quantity_completed > 0) AND (r4.op_quantity_completed = 0)
--GO

--WITH cteConflict
--AS(
--	SELECT K.assembly_item,I.wip_entity_name, K.job_type, K.dj_status, I.run_start_time, I.run_end_time, I.success_flag, I.reject_flag, K.true_operation_code, K.operation_code
--	,K.operation_seq_num, COALESCE(K.quantity_completed,0) AS quantity_completed, K.start_quantity, K.net_quantity
--	,LEAD(I.run_start_time,1) OVER (PARTITION BY I.wip_entity_name ORDER BY K.operation_seq_num) NextProcessRunStartTime
--	,LEAD(K.quantity_completed,1,0) OVER (PARTITION BY I.wip_entity_name ORDER BY K.operation_seq_num) NextProcessQuantityCompleted
--	,LEAD(true_operation_code,1,true_operation_code) OVER (PARTITION BY I.wip_entity_name ORDER BY K.operation_seq_num) NextTrueOperationCode
--	FROM Oracle_DJ_Routes K INNER JOIN dbo.Oracle_DJ_Processing_Times I ON I.wip_entity_name = K.wip_entity_name AND I.op_sequence = K.operation_seq_num
--	WHERE K.dj_status NOT IN ('COMPLETE', 'CLOSED')
--)
--SELECT * 
--FROM cteConflict i
--WHERE ((i.run_end_time IS NULL AND NextProcessRunStartTime IS NOT NULL AND NextProcessQuantityCompleted <=0) 
--OR (i.run_start_time IS NULL AND i.quantity_completed >0 AND i.NextProcessQuantityCompleted = 0)) --AND i.true_operation_code <> i.NextTrueOperationCode

--ORDER BY I.wip_entity_name, I.operation_seq_num
GO
