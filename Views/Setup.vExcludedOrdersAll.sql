SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
Author:			Bryan Eddy
Date:			12/17/2017
Description:	Shows orders lines for all excluded items
Version:		2
Update:			Added Schedule Approved Field


*/

CREATE VIEW [Setup].[vExcludedOrdersAll]
AS

SELECT DISTINCT g.ConcOrderNumber AS conc_order_number, K.customer_name, K.assembly_item ItemNumber, K.order_status, K.customer_number,g.ParentDj as parent_dj_number, K.schedule_approved
FROM Setup.vExcludedOrdersDetail G INNER JOIN dbo.Oracle_Orders K ON k.conc_order_number = G.ConcOrderNumber

UNION 

SELECT CAST(k.order_number as nvarchar)+  '-' + CAST(k.line_number AS NVARCHAR), k.customer_name, ItemNumber, k.order_status, k.customer_number, k.parent_dj_number, k.schedule_approved
FROM SETUP.vExclusionItemList g INNER JOIN DBO.Oracle_Orders k ON k.assembly_item = g.ItemNumber



GO
