SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*
Author:			Bryan Eddy
Date:			2/2/2018	
Description:	Shows missing setups and associated items
Version:		2
Update:			Change to just std routes


*/

CREATE VIEW [Setup].[vMissingSetupsDj]
AS

	SELECT    DISTINCT 
	G.assembly_item Item,
	true_operation_code AS Setup
	,G.wip_entity_name
	, conc_order_number
	,G.operation_seq_num
	FROM Setup.vSetupLineSpeed K RIGHT JOIN dbo.Oracle_DJ_Routes G ON G.true_operation_code = K.Setup 
	LEFT JOIN Setup.DepartmentIndicator I ON I.department_code = G.department_code
	INNER JOIN dbo.Oracle_Items P ON P.item_number = G.assembly_item
	INNER JOIN dbo.Oracle_Orders ON parent_dj_number = wip_entity_name
	WHERE P.inventory_item_status_code NOT IN ('obsolete','CAB REVIEW') AND P.make_buy = 'MAKE' AND g.send_to_aps ='Y'
	AND I.department_code IS NULL AND G.true_operation_seq_num IS NOT NULL AND (K.MachineName IS NULL)-- OR K.LineSpeed = 0)


GO
