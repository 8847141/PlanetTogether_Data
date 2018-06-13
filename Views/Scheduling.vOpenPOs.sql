SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/****** Script for SelectTopNRows command from SSMS  ******/
/*
Author:		Bryan Eddy
Date:		4/27/2018
Desc:		View to show open PO's from buyers to vendors for materials
Version:	2
Update:		Removed negative open po qty parameter
*/
CREATE VIEW [Scheduling].[vOpenPOs]
AS
SELECT item_number, open_po_qty_primary, vendor_name, po_number,promised_date, need_by_date, primary_uom_code,category_name
  FROM [dbo].[Oracle_POs]
  WHERE open_po_qty_primary > 0

GO
