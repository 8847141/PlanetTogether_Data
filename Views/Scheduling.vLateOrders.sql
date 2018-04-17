SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
Author:		Bryan Eddy
Date:		4/12/2018
Desc:		View for reporting of late orders
Version:	1
Update:		n/a
*/


/* TO DO : Order Quantity */
CREATE VIEW [Scheduling].[vLateOrders]
as
SELECT DISTINCT  order_number, I.customer_name, assembly_item, pri_uom_order_qty, order_scheduled_end_date,promise_date,
CASE WHEN promise_date < schedule_ship_date THEN schedule_ship_date END Recommit,
 DATEDIFF(MM,promise_date,schedule_ship_date) PromiseDeltaMonths
, late_order, I.schedule_approved
FROM dbo._report_4a_production_master_schedule K INNER JOIN (SELECT customer_name, conc_order_number,assembly_item,pri_uom_order_qty, schedule_approved FROM  dbo.Oracle_Orders) I ON I.conc_order_number = K.order_number
WHERE promise_date < order_scheduled_end_date AND late_order = 'Y'
GO
