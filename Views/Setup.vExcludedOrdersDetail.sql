SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
Author:			Bryan Eddy
Date:			3/16/18
Description:	Exclusion list to show just Dj's and sales orders that are affected from missing setups
Version:		2
Update:			added queries to identify jobs with missing material demand


*/

CREATE VIEW [Setup].[vExcludedOrdersDetail]
AS
	

	SELECT DISTINCT K.ConcOrderNumber, k.AssembtlyItem, K.ParentDj, G.Setup, G.operation_seq_num
	FROM Setup.vMissingSetupsDj G CROSS APPLY setup.fn_WhereUsedDj(g.wip_entity_name) K
	UNION 
	SELECT   i.conc_order_number, Item AS ItemNumber, i.wip_entity_name, i.Setup, i.operation_seq_num
	FROM Setup.vMissingSetupsDj i
	UNION 
	SELECT DISTINCT i.conc_order_number,E.AssemblyItemNumber, P.wip_entity_name,NULL,p.Bom_Op_Seq
	FROM Scheduling.vMissingMaterialDemandDj P CROSS APPLY Setup.fn_WhereUsedStdAndDJ(P.item_number) E	INNER JOIN Scheduling.vOracleOrders i ON i.child_dj_number = p.item_number
	UNION
	SELECT DISTINCT i.conc_order_number, p.item_number , p.wip_entity_name, NULL, p.Bom_Op_Seq
	FROM Scheduling.vMissingMaterialDemandDj p INNER JOIN Scheduling.vOracleOrders i ON i.parent_dj_number = p.item_number




GO
