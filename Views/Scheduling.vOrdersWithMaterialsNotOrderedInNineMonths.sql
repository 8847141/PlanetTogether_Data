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
AS
/************ Old query.  Keeping until data is confirmed*********************/

WITH cteBomExplode
AS (
	SELECT  E.conc_order_number, E.assembly_item,E.order_quantity, i.FinishedGood, i.comp_item,I.ExtendedQuantityPer
	,MAX(E.order_quantity) OVER (PARTITION BY I.comp_item) AS MaxOrderQuantityPerMaterial, I.primary_uom_code
	FROM (SELECT DISTINCT conc_order_number, assembly_item, order_quantity FROM dbo.Oracle_Orders WHERE schedule_approved = 'n') E CROSS APPLY dbo.fn_ExplodeBOM(E.assembly_item) I
	--GROUP BY E.conc_order_number, E.assembly_item,E.order_quantity, i.FinishedGood, i.comp_item,

	)
,cteBomAgg
AS(
	SELECT   G.conc_order_number, G.assembly_item, G.FinishedGood,G.MaxOrderQuantityPerMaterial,G.comp_item
	, SUM(G.ExtendedQuantityPer* G.order_quantity) OVER (PARTITION BY G.comp_item) AS MaterialDemandTotal
	, G.primary_uom_code, G.order_quantity
	FROM cteBomExplode G

),
cteOnHnad
AS(
SELECT DISTINCT item_number, SUM(onhand_qty) OVER (PARTITION BY item_number) AS TotalQuantityOnHand
FROM dbo.Oracle_Onhand
WHERE subinventory_code <> 'FLOORSTK'
)
SELECT DISTINCT  k.conc_order_number, K.FinishedGood,K.order_quantity,K.comp_item AS Material, j.primary_uom_code, inventory_item_status_code, po_date
, po_receipt_date, J.make_buy, K.MaxOrderQuantityPerMaterial, K.MaterialDemandTotal
,J.item_description MaterialDescription, O.TotalQuantityOnHand, O.TotalQuantityOnHand - K.MaterialDemandTotal MaterialDemandDelta, 1 - (O.TotalQuantityOnHand - K.MaterialDemandTotal)/O.TotalQuantityOnHand DemandPercentOfOnHand
FROM dbo.Oracle_Items J INNER JOIN cteBomAgg K ON J.item_number = K.comp_item 
INNER JOIN cteOnHnad O ON O.item_number = J.item_number
WHERE (DATEDIFF(MM,po_date,GETDATE()) >= 9 OR DATEDIFF(MM,po_receipt_date,GETDATE()) >=9)
	AND J.make_buy = 'buy' --D K.MaterialDemand > O.TotalQuantityOnHand
--ORDER BY Material, K.order_quantity

GO
