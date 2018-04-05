SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
Author:		Bryan Eddy
Date:		4/4/2018
Desc:		View to show orders having materials that haven't been ordered in 9 months.
Version:	1
Update:		n/a
*/


CREATE VIEW [Scheduling].[vOrdersWithMaterialsNotOrderedInNineMonths]
as
WITH cteBomExplode
AS (
	SELECT DISTINCT E.order_number, E.assembly_item, I.*
	FROM (SELECT DISTINCT order_number, assembly_item FROM dbo.Oracle_Orders) E CROSS APPLY dbo.fn_ExplodeBOM(E.assembly_item) I
)

SELECT DISTINCT  K.order_number, K.FinishedGood,j.item_number AS Material, item_description, j.primary_uom_code, inventory_item_status_code, po_date, po_receipt_date
FROM dbo.Oracle_Items J INNER JOIN cteBomExplode K ON J.item_number = K.item_number
WHERE DATEDIFF(MM,po_date,GETDATE()) >= 9 OR DATEDIFF(MM,po_receipt_date,GETDATE()) >=9
GO
