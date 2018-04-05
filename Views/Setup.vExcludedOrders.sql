SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







/*
Author:			Bryan Eddy
Date:			12/17/2017
Description:	Shows orders lines for excluded items
Version:		2
Update:			Updated to concatenate the sales order and line number.  Updated data being pulled from only DJ's missing setups.


*/

CREATE VIEW	[Setup].[vExcludedOrders]
AS

SELECT DISTINCT g.ConcOrderNumber AS conc_order_number, K.customer_name, K.assembly_item ItemNumber, K.order_status, K.customer_number,g.ParentDj
FROM Setup.vExcludedOrdersDetail G INNER JOIN dbo.Oracle_Orders K ON k.conc_order_number = G.ConcOrderNumber



GO
