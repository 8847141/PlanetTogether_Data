SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*
Author:		Bryan Eddy
Desc:		View to show items with materials not assigned to an operation passing to the APS system
Date:		5/16/2018
Version:	1
Update:		n/a
*/

CREATE VIEW [Scheduling].[vMissingMaterialDemand]
AS


WITH cteRoutes
AS(
	SELECT *
	FROM Setup.vRoutesUnion
	WHERE pass_to_aps <> 'N'
)
SELECT B.item_number,B.comp_item, CAST(B.item_seq AS INT) item_seq,CAST(B.opseq AS INT) AS Bom_Op_Seq, R.operation_seq_num AS Route_Op_Seq, I.inventory_item_status_code, B.wip_entity_name
FROM Setup.vBomUnion B LEFT JOIN cteRoutes R ON R.item_number = B.item_number AND B.opseq = R.operation_seq_num AND B.alternate_bom_designator = R.alternate_routing_designator
	AND R.wip_entity_name = B.wip_entity_name
	INNER JOIN dbo.Oracle_Items I ON B.item_number = I.item_number
WHERE R.item_number IS NULL AND B.comp_qty_per <> 0 AND I.inventory_item_status_code NOT IN ('obsolete','cab review')
--ORDER BY I.inventory_item_status_code
GO
