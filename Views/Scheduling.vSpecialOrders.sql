SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*
Author:		Bryan Eddy
Desc:		view of special orders
Date:		6/7/2018
Version:	1
Update:		n/a
*/

CREATE VIEW [Scheduling].[vSpecialOrders]
AS
WITH cteSpecialOrders
AS(
SELECT e.return_osp,
       e.ncmir_notes,
       e.print_notes,
       e.conc_order_number,
       e.customer_name,
       e.job,
       e.part_number,
       e.so_qty,
       e.request_date,
       e.promise_date,
       e.schedule_ship_date,
       e.schedule_approved,
       e.has_credit_hold,
       e.has_mfg_hold,
       e.has_export_hold,
       e.has_shipping_hold,
       e.scheduled_setup_start,
       e.machine_name,
       e.component_item,
       e.ProductionStatus,
       e.material_earliest_start_date,
       e.last_update_date,
	   CASE WHEN e.schedule_approved = 'N' THEN 1 
			WHEN E.schedule_approved = 'Y' THEN 2
			ELSE	3 END ScheduleApprovedOrder
FROM _report_3b_specialty_order_detail e
)
SELECT E.return_osp,
       E.ncmir_notes,
       E.print_notes,
       E.conc_order_number,
       E.customer_name,
       E.job,
       E.part_number,
       E.so_qty,
       E.request_date,
       E.promise_date,
       E.schedule_ship_date,
       E.schedule_approved,
       E.has_credit_hold,
       E.has_mfg_hold,
       E.has_export_hold,
       E.has_shipping_hold,
       E.scheduled_setup_start,
       E.machine_name,
       E.component_item,
       E.ProductionStatus,
       E.material_earliest_start_date,
       E.last_update_date,
       E.ScheduleApprovedOrder,
		ROW_NUMBER() OVER (PARTITION BY e.conc_order_number ORDER BY ScheduleApprovedOrder, promise_date, scheduled_setup_start) OrderNumberStart
FROM cteSpecialOrders E
GO
