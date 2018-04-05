SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO









/*
Author:			Bryan Eddy
Date:			3/16/18
Description:	Exclusion list to show just Dj's and sales orders that are affected from missing setups
Version:		1
Update:			Initial creation



*/

CREATE VIEW	[Setup].[vExcludedOrdersDetail]
AS
	

	SELECT DISTINCT K.ConcOrderNumber, k.AssembtlyItem, K.ParentDj, G.Setup, G.operation_seq_num
	FROM Setup.vMissingSetupsDj G CROSS APPLY setup.fn_WhereUsedDj(g.wip_entity_name) K
	UNION 
	SELECT   i.conc_order_number, Item AS ItemNumber, i.wip_entity_name, i.Setup, i.operation_seq_num
	FROM Setup.vMissingSetupsDj i



GO
