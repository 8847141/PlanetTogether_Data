SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
Author:		Bryan Eddy
Date:		4/5/2018
Desc:		Short Ship alert
Version:	1
Update:		n/a
*/

CREATE VIEW [Scheduling].[vAlertShortShip]
as
SELECT DISTINCT	order_number, conc_order_number, promise_date, need_by_date, assembly_item, customer_name, scheduler,pri_uom_order_qty, pri_uom_shipped_qty, pri_uom_open_qty
FROM dbo.Oracle_Orders
WHERE pri_uom_shipped_qty > 0 AND pri_uom_order_qty > 0
GO
