SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








/*
Author:		Bryan Eddy
Date:		2/5/2018
Desc:		Union of both routes for 
Version:	1
Update:		Initial creation
*/

CREATE VIEW [Setup].[vRoutesUnion]
AS 

SELECT item_number, true_operation_code, true_operation_seq_num, alternate_routing_designator, pass_to_aps, department_code, item_description, operation_seq_num, operation_code, '1' AS wip_entity_name
FROM dbo.Oracle_Routes


UNION

SELECT assembly_item, true_operation_code, true_operation_seq_num, 'Primary', send_to_aps, department_code, assembly_description, operation_seq_num, operation_code, wip_entity_name
FROM dbo.Oracle_DJ_Routes
GO
