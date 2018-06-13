SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*
Author:		Bryan Eddy
Date:		4/4/2018
Desc:		View to show orders having materials that haven't been ordered in 9 months.
Version:	3
Update:		Input logic canged to capture po_reciept_date is null
*/


CREATE VIEW [Scheduling].[vStaleMaterials]
AS
/************ Old query.  Keeping until data is confirmed*********************/

WITH cteBomExplode
AS (
	SELECT  E.conc_order_number, E.assembly_item,E.order_quantity, i.FinishedGood, i.comp_item,I.ExtendedQuantityPer
	,MAX(E.order_quantity) OVER (PARTITION BY I.comp_item) AS MaxOrderQuantityPerMaterial, I.primary_uom_code
	FROM (SELECT DISTINCT conc_order_number, assembly_item, order_quantity FROM dbo.Oracle_Orders WHERE schedule_approved = 'n' AND order_type NOT LIKE '%rma%' AND order_quantity > 0
	) E CROSS APPLY dbo.fn_ExplodeBOM(E.assembly_item) I
	INNER JOIN dbo.Oracle_Items P ON P.item_number = I.item_number
	WHERE P.make_buy = 'make'
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
, po_receipt_date, J.make_buy, K.MaxOrderQuantityPerMaterial, K.MaterialDemandTotal, J.buyer
,J.item_description MaterialDescription, O.TotalQuantityOnHand, O.TotalQuantityOnHand - K.MaterialDemandTotal MaterialDemandDelta, 1 - (O.TotalQuantityOnHand - K.MaterialDemandTotal)/O.TotalQuantityOnHand DemandPercentOfOnHand
FROM dbo.Oracle_Items J INNER JOIN cteBomAgg K ON J.item_number = K.comp_item 
INNER JOIN cteOnHnad O ON O.item_number = J.item_number
WHERE (DATEDIFF(MM,po_date,GETDATE()) >= 9 OR DATEDIFF(MM,po_receipt_date,GETDATE()) >=9 OR J.po_receipt_date IS NULL )
	AND J.make_buy = 'buy'

GO
