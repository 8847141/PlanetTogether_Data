SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*
Author:		Bryan Eddy
Date:		4/13/2018
Desc:		View linked to SSRS reporting for wire demand shop floor status
Version:	1
Update:		n/a
*/
CREATE VIEW [Scheduling].[vWireDemandShopFloorStatus]
AS
SELECT
  Oracle_USAC_PO_SO.item_number
  ,Oracle_USAC_PO_SO.sales_order_ln
  ,Oracle_USAC_PO_SO.shop_order_status
  ,Oracle_USAC_PO_SO.so_item
  ,Oracle_USAC_PO_SO.so_qty
  ,Oracle_USAC_PO_SO.so_uom
  ,Oracle_USAC_PO_SO.customer_name
  ,Oracle_USAC_PO_SO.mutl_number
  ,Oracle_USAC_PO_SO.mult_length
  ,Oracle_USAC_PO_SO.mult_uom
  ,Oracle_USAC_PO_SO.inv_item_desc
,  _report_3e_mrg_nonfiber.OrderLine
  ,_report_3e_mrg_nonfiber.SchedDate
  ,_report_3e_mrg_nonfiber.PromDate
  ,_report_3e_mrg_nonfiber.Item
FROM
  Oracle_USAC_PO_SO INNER JOIN _report_3e_mrg_nonfiber ON OrderLine = sales_order_ln AND Item = item_number

GO
