SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








/*
Author:			Bryan Eddy
Date:			12/17/2017
Description:	Shows orders lines for all excluded items
Version:		1
Update:			n/a


*/

CREATE VIEW	[Setup].[vExcludedOrdersAll]
AS

SELECT DISTINCT g.ConcOrderNumber AS conc_order_number, K.customer_name, K.assembly_item ItemNumber, K.order_status, K.customer_number,g.ParentDj as parent_dj_number
FROM Setup.vExcludedOrdersDetail G INNER JOIN dbo.Oracle_Orders K ON k.conc_order_number = G.ConcOrderNumber

UNION 

SELECT CAST(k.order_number as nvarchar)+  '-' + CAST(k.line_number AS NVARCHAR), k.customer_name, ItemNumber, k.order_status, k.customer_number, k.parent_dj_number
FROM SETUP.vExclusionItemList g INNER JOIN DBO.Oracle_Orders k ON k.assembly_item = g.ItemNumber



GO
