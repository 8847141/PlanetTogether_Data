SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*
Author:		Bryan Eddy
Desc:		View to show items with materials not assigned to an operation passing to the APS system
Date:		5/30/2018
Version:	1
Update:		n/a
*/

CREATE VIEW [Scheduling].[vMissingMaterialDemandDj]
AS


WITH cteRoutes
AS(
	SELECT *
	FROM dbo.Oracle_DJ_Routes
	WHERE send_to_aps <> 'N'
)
SELECT b.assembly_item AS item_number,b.component_item,CAST(b.operation_seq_num AS INT) AS Bom_Op_Seq, R.operation_seq_num AS Route_Op_Seq, I.inventory_item_status_code, B.wip_entity_name
FROM dbo.Oracle_DJ_BOM b LEFT JOIN cteRoutes R ON R.assembly_item = B.assembly_item AND B.operation_seq_num = R.operation_seq_num AND R.wip_entity_name = b.wip_entity_name
	INNER JOIN dbo.Oracle_Items I ON B.assembly_item = I.item_number
WHERE R.assembly_item IS NULL AND b.required_quantity <> 0 AND I.inventory_item_status_code NOT IN ('obsolete','cab review')
--ORDER BY I.inventory_item_status_code
GO
