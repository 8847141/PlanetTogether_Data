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
as
SELECT        a.wip_entity_name, a.operation_seq_num, r4.true_operation_seq_num
FROM            (SELECT        r.wip_entity_name, r.operation_seq_num, MIN(r2.operation_seq_num) AS next_op_seq_num
                          FROM            dbo.Oracle_DJ_Routes AS r LEFT OUTER JOIN
                                                    dbo.Oracle_DJ_Routes AS r2 ON r.wip_entity_name = r2.wip_entity_name AND r.operation_seq_num < r2.operation_seq_num
                          GROUP BY r.wip_entity_name, r.operation_seq_num) AS a INNER JOIN
                         dbo.Oracle_DJ_Routes AS r3 ON a.wip_entity_name = r3.wip_entity_name AND a.operation_seq_num = r3.operation_seq_num INNER JOIN
                         dbo.Oracle_DJ_Processing_Times AS p3 ON r3.wip_entity_name = p3.wip_entity_name AND r3.operation_seq_num = p3.op_sequence INNER JOIN
                         dbo.Oracle_DJ_Routes AS r4 ON a.wip_entity_name = r4.wip_entity_name AND a.operation_seq_num = r4.operation_seq_num
WHERE        (r3.dj_status NOT IN ('Complete', 'Closed')) AND (r3.op_quantity_completed < r3.start_quantity) AND (r3.op_quantity_completed > 0) AND (r4.op_quantity_completed = 0)
GO
