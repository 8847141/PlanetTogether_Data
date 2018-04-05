SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
Author:		Bryan Eddy
Date:		4/5/2018
Desc:		Mfg Hold Alert
Version:	1
Update:		n/a
*/

CREATE VIEW [Scheduling].[vAlertMfgHold]
as
SELECT DISTINCT order_number, conc_order_number, promise_date, need_by_date, has_mfg_hold, assembly_item, customer_name, scheduler, pri_uom_order_qty
FROM dbo.Oracle_Orders
WHERE has_mfg_hold = 'Y' AND DATEDIFF(DD,promise_date,GETDATE()) <= 21
GO
