/*
This migration script replaces uncommitted changes made to these objects:
_report_3b_specialty_order_detail
_report_3c_acs_order_status_review
_report_9a_bobbin_usage_release
_report_9a_bobbin_usage_running_total
EmailAlertMissingMaterialDemand
usp_EmailAlertMissingMaterialDemandDj
usp_EmailAlertMissingMaterialDemand
usp_EmailMasterAlert
usp_EmailMfgHoldAlert
usp_EmailOrdersStaleMaterials
GetItemSetupAttributes
usp_CalculateSetupTimesFromOracle
usp_GetItemAttributeData
vAlertMfgHold
vDjStatusConflict
vMissingMaterialDemandDj
vMissingMaterialDemand
vOpenPOs
vOrdersWithMaterialsNotOrderedInNineMonths
vSpecialOrders
vStaleMaterialsFlatByBuyer
vStaleMaterialsFlat
vStaleMaterials
vExcludedOrdersDetail

Use this script to make necessary schema and data changes for these objects only. Schema changes to any other objects won't be deployed.

Schema changes and migration scripts are deployed in the order they're committed.

Migration scripts must not reference static data. When you deploy migration scripts alongside static data 
changes, the migration scripts will run first. This can cause the deployment to fail. 
Read more at https://documentation.red-gate.com/display/SOC6/Static+data+and+migrations.
*/

SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
PRINT N'Dropping [dbo].[_report_9a_bobbin_usage_running_total]'
GO
DROP TABLE [dbo].[_report_9a_bobbin_usage_running_total]
GO
PRINT N'Dropping [Scheduling].[vOrdersWithMaterialsNotOrderedInNineMonths]'
GO
DROP VIEW [Scheduling].[vOrdersWithMaterialsNotOrderedInNineMonths]
GO
PRINT N'Dropping [Scheduling].[EmailAlertMissingMaterialDemand]'
GO
DROP PROCEDURE [Scheduling].[EmailAlertMissingMaterialDemand]
GO
PRINT N'Refreshing [Setup].[vInterfaceSetupAttributes]'
GO
EXEC sp_refreshview N'[Setup].[vInterfaceSetupAttributes]'
GO
PRINT N'Refreshing [Scheduling].[vOracleOrders]'
GO
EXEC sp_refreshview N'[Scheduling].[vOracleOrders]'
GO
PRINT N'Refreshing [Setup].[vInterfaceAllMachineSetups]'
GO
EXEC sp_refreshview N'[Setup].[vInterfaceAllMachineSetups]'
GO
PRINT N'Refreshing [Setup].[vSetupStatus]'
GO
EXEC sp_refreshview N'[Setup].[vSetupStatus]'
GO
PRINT N'Refreshing [Scheduling].[vSchedulerMachineCapabilityIssue]'
GO
EXEC sp_refreshview N'[Scheduling].[vSchedulerMachineCapabilityIssue]'
GO
PRINT N'Refreshing [Scheduling].[vItemAttributes]'
GO
EXEC sp_refreshview N'[Scheduling].[vItemAttributes]'
GO
PRINT N'Refreshing [Setup].[vSetupTimesItem]'
GO
EXEC sp_refreshview N'[Setup].[vSetupTimesItem]'
GO
PRINT N'Altering [Setup].[usp_GetItemAttributeData]'
GO









-- =============================================
-- Author:      Bryan Eddy
-- Create date: 9/11/2017
-- Description: Procedure insert data into Setup.ItemAttributes table for Oracle to pick up
-- Version: 3
-- Update:	Added condition to OD update statment to ensure the value is numeric
-- =============================================

ALTER PROCEDURE [Setup].[usp_GetItemAttributeData]
AS

	SET NOCOUNT ON;
BEGIN
 
		DECLARE @ErrorNumber INT = ERROR_NUMBER();
		DECLARE @ErrorLine INT = ERROR_LINE();


--Update all items with the latest fiber count
EXEC [Setup].usp_GetFiberCount @RunType = 2

--Get cable color.  Find color chips or compound in BOM and rank to find the sheathed cable color
	BEGIN TRY
		BEGIN TRAN
			;WITH cteSetup
			as(
		
				SELECT DISTINCT G.item_number,R.AttributeNameID,G.comp_item, P.attribute_name, P.attribute_value, o.inventory_item_status_code,G.opseq,
				DENSE_RANK() OVER (PARTITION BY G.item_number ORDER BY G.item_number,G.opseq ASC) AS OpSeqRank
				,ROW_NUMBER() OVER (PARTITION BY G.item_number,G.opseq   ORDER BY G.item_number,(CASE WHEN z.attribute_value = 'COLOR CHIPS' THEN 1 ELSE 0 END)  Desc ) AS RowNumber
				--,COUNT(comp_item) OVER (PARTITION BY true_operation_code, comp_item) CountOfComponent
				FROM DBO.Oracle_BOMs G
				INNER JOIN Oracle_Item_Attributes P ON P.item_number = G.comp_item
				INNER JOIN setup.ApsSetupAttributeReference R ON R.OracleAttribute = P.attribute_name
				INNER JOIN dbo.Oracle_Items O ON O.item_number = P.item_number
				INNER JOIN dbo.Oracle_Item_Attributes Z ON G.comp_item = Z.item_number
				WHERE P.attribute_name = 'COLOR'  AND Z.attribute_name = 'MATERIAL TYPE' AND Z.attribute_value IN ('COMPOUND','COLOR CHIPS','INK') and alternate_bom_designator = 'primary'
		

			)
			UPDATE K
			SET K.CableColor = g.attribute_value
			--select *
			FROM cteSetup G INNER JOIN setup.ItemAttributes K ON G.item_Number = K.ItemNumber
			WHERE OpSeqRank = 1 and RowNumber = 1 AND DATEDIFF(day,DateRevised,getdate()) = 0
		COMMIT TRAN
	END TRY
	BEGIN CATCH	
		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
 
		PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
		PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
		THROW;
	END CATCH;


	--Get if the BOM contains GEL
	BEGIN TRY
		BEGIN TRAN
			;WITH cteGel
			as(
				SELECT DISTINCT K.item_number, comp_item, ROW_NUMBER() OVER (PARTITION BY k.item_number ORDER BY k.item_number) RowNumber
				FROM DBO.Oracle_BOMs K INNER JOIN dbo.Oracle_Item_Attributes G ON G.item_number = K.comp_item
				WHERE G.attribute_name = 'MATERIAL TYPE' AND G.attribute_value = 'GEL' AND alternate_bom_designator = 'primary'
			)
			UPDATE K
			SET K.Gel = comp_item
			--select *
			FROM cteGel G INNER JOIN setup.ItemAttributes K ON G.item_Number = K.ItemNumber
			WHERE RowNumber = 1 AND DATEDIFF(day,DateRevised,getdate()) = 0
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
 
		PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
		PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
		THROW;
	END CATCH;

	--Get OD of items from setup data
	BEGIN TRY
		BEGIN TRAN
			;WITH cteAttributes
			AS (
				SELECT DISTINCT AttributeValue, K.AttributeName, SetupNumber,P.AttributeNameID
				FROM [Setup].vInterfaceSetupAttributes K INNER JOIN Setup.ApsSetupAttributeReference G ON K.AttributeID = G.AttributeID
				  INNER JOIN SETUP.ApsSetupAttributes P ON P.AttributeNameID = G.AttributeNameID 
				  INNER JOIN setup.MachineNames M ON M.MachineID = MachineID
				  WHERE P.AttributeNameID = 3 AND AttributeValue IS NOT NULL
			),
			 cteOD
			AS(
				SELECT DISTINCT item_number, true_operation_seq_num, true_operation_code, AttributeValue, AttributeName,
				ROW_NUMBER() OVER (PARTITION BY item_number ORDER BY item_number,true_operation_seq_num DESC) RowNumber
				FROM Oracle_Routes K INNER JOIN cteAttributes G 
				ON K.true_operation_code = G.SetupNumber
				WHERE alternate_routing_designator = 'PRIMARY'
			)
			UPDATE K
			SET K.NominalOD = G.AttributeValue
			FROM cteOD G INNER JOIN Setup.ItemAttributes K ON G.item_number = K.ItemNumber
			WHERE RowNumber = 1 AND DATEDIFF(DAY,DateRevised,GETDATE()) = 0 AND ISNUMERIC(G.AttributeValue) = 1
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
 
		PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
		PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
		THROW;
	END CATCH;


--Get OD of items from Premise DB
	BEGIN TRY
		BEGIN TRAN
			DECLARE @RecordCount INT;
			SELECT @RecordCount = COUNT(*) FROM [NAASPB-PRD04\SQL2014].Premise.Schedule.vInterfaceItemAttributes
			IF @RecordCount > 0 
				BEGIN

					UPDATE G
					SET G.NominalOD = CASE WHEN G.NominalOD IS NULL THEN K.NominalOD ELSE G.NominalOD END, G.CableColor = CASE WHEN G.CableColor IS NULL THEN K.CableColor ELSE K.CableColor END
					FROM [NAASPB-PRD04\SQL2014].Premise.Schedule.vInterfaceItemAttributes K INNER JOIN setup.ItemAttributes G ON G.ItemNumber = K.ItemNumber
					WHERE g.NominalOD IS NULL
				END
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
 
		PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
		PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
		THROW;
	END CATCH;

--Get OD of items from Oracle Specs that are still null
	BEGIN TRY
		BEGIN TRAN
		--IF OBJECT_ID('[NAASPB-PRD04\SQL2014].Premise.dbo.AFLPRD_INVSysItemSpec_CAB', 'U') IS NOT NULL 
		--	BEGIN
				--DECLARE @RecordCount int;
				SELECT @RecordCount = COUNT(*) FROM [NAASPB-PRD04\SQL2014].Premise.dbo.AFLPRD_INVSysItemSpec_CAB
				IF @RecordCount > 0 
					BEGIN
						
						;WITH cteNominalOD
						AS(
						SELECT G.ItemNumber, NominalOD, SpecificationElement, CAST(REPLACE(TargetValue,',','.') AS FLOAT) AS attribute_value
						,ROW_NUMBER() OVER (PARTITION BY K.ItemNumber ORDER BY K.ItemNumber ASC,CAST(REPLACE(TargetValue,',','.') AS FLOAT) DESC) AS RowNumber
						  FROM [Scheduling].[vItemAttributes] G INNER JOIN [NAASPB-PRD04\SQL2014].Premise.dbo.AFLPRD_INVSysItemSpec_CAB K ON K.ItemNumber = G.ItemNumber
						  WHERE NominalOD IS NULL AND K.SpecificationElement IN( 'UNIT NOMINAL OD','JACKET OD') AND TargetValue IS NOT NULL  
						)
						UPDATE G
						SET NominalOD = attribute_value
						FROM cteNominalOD K INNER JOIN setup.ItemAttributes G ON G.ItemNumber = K.ItemNumber
						WHERE RowNumber = 1
					END
			--END
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
 
		PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
		PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
		THROW;
	END CATCH;



	--Get cables that have colored binders
BEGIN TRY
		BEGIN TRAN
			UPDATE P
			SET P.ContainsFiberIdBinders = 1
			FROM DBO.Oracle_Item_Attributes K INNER JOIN DBO.Oracle_BOMs G ON K.item_number = G.comp_item
			INNER JOIN setup.ItemAttributes P ON P.ItemNumber = G.item_number
			WHERE attribute_value = 'COLOR BINDER'
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
 
		PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
		PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
		THROW;
	END CATCH;

	--Get if cable contains any binder
	BEGIN TRY
		BEGIN TRAN
			UPDATE P
			SET P.ContainsBinder = 1
			FROM DBO.Oracle_BOMs G 
			INNER JOIN setup.ItemAttributes P ON P.ItemNumber = G.item_number
			WHERE G.comp_item LIKE 'bin%'
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
 
		PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
		PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
		THROW;
	END CATCH;

	--Get if cable contains a stripe
	BEGIN TRY
		BEGIN TRAN
			UPDATE K
			SET Printed = SetupAttributeValue
			FROM Setup.vSetupTimesItem G INNER JOIN Setup.ItemAttributes K ON K.ItemNumber = G.Item_Number
			WHERE G.AttributeNameID = 37
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
 
		PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
		PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
		THROW;
	END CATCH;


END



GO
PRINT N'Creating [Scheduling].[vStaleMaterials]'
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
PRINT N'Creating [Scheduling].[vStaleMaterialsFlatByBuyer]'
GO



/*
Author:		Bryan Eddy
Date:		6/7/2018
Desc:		Flattened version of the stale materials view with information by buyer
Version:	1
Update:		n/a
*/

CREATE VIEW [Scheduling].[vStaleMaterialsFlatByBuyer]
AS
SELECT DISTINCT buyer,Material, D.FinishedGood,E.Orders
    FROM [Scheduling].[vStaleMaterials]  p1
   CROSS APPLY ( SELECT DISTINCT  p2.FinishedGood + ',' 
                     FROM [Scheduling].[vStaleMaterials] p2
                     WHERE p2.Material = p1.Material
                     FOR XML PATH('') )  D ( FinishedGood )
	CROSS APPLY ( SELECT DISTINCT p3.conc_order_number + ',' 
                     FROM [Scheduling].[vStaleMaterials] p3
                     WHERE p3.Material= p1.Material
                     FOR XML PATH('') )  E ( Orders )

GO
PRINT N'Rebuilding [dbo].[_report_3b_specialty_order_detail]'
GO
CREATE TABLE [dbo].[RG_Recovery_1__report_3b_specialty_order_detail]
(
[return_osp] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ncmir_notes] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[print_notes] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[conc_order_number] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customer_name] [varchar] (360) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[job] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[part_number] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[so_qty] [float] NULL,
[request_date] [datetime] NULL,
[promise_date] [datetime] NULL,
[schedule_ship_date] [datetime] NULL,
[schedule_approved] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[has_credit_hold] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[has_mfg_hold] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[has_export_hold] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[has_shipping_hold] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[scheduled_setup_start] [datetime] NULL,
[machine_name] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[component_item] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProductionStatus] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[material_earliest_start_date] [datetime] NULL,
[last_update_date] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
INSERT INTO [dbo].[RG_Recovery_1__report_3b_specialty_order_detail]([return_osp], [ncmir_notes], [print_notes], [conc_order_number], [customer_name], [job], [part_number], [so_qty], [request_date], [promise_date], [schedule_ship_date], [schedule_approved], [scheduled_setup_start], [machine_name], [component_item], [ProductionStatus], [material_earliest_start_date], [last_update_date]) SELECT [return_osp], [ncmir_notes], [print_notes], [conc_order_number], [customer_name], [job], [part_number], [so_qty], [request_date], [promise_date], [schedule_ship_date], [schedule_approved], [scheduled_setup_start], [machine_name], [component_item], [ProductionStatus], [material_earliest_start_date], [last_update_date] FROM [dbo].[_report_3b_specialty_order_detail]
GO
DROP TABLE [dbo].[_report_3b_specialty_order_detail]
GO
EXEC sp_rename N'[dbo].[RG_Recovery_1__report_3b_specialty_order_detail]', N'_report_3b_specialty_order_detail', N'OBJECT'
GO
PRINT N'Creating [Scheduling].[vSpecialOrders]'
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
PRINT N'Refreshing [Setup].[vInterfaceSetupLineSpeed]'
GO
EXEC sp_refreshview N'[Setup].[vInterfaceSetupLineSpeed]'
GO
PRINT N'Refreshing [Setup].[vSetupLineSpeed]'
GO
EXEC sp_refreshview N'[Setup].[vSetupLineSpeed]'
GO
PRINT N'Refreshing [Setup].[vMissingSetups]'
GO
EXEC sp_refreshview N'[Setup].[vMissingSetups]'
GO
PRINT N'Refreshing [Setup].[vMissingSetupsDj]'
GO
EXEC sp_refreshview N'[Setup].[vMissingSetupsDj]'
GO
PRINT N'Altering [Scheduling].[vMissingMaterialDemand]'
GO


/*
Author:		Bryan Eddy
Desc:		View to show items with materials not assigned to an operation passing to the APS system
Date:		5/16/2018
Version:	1
Update:		n/a
*/

ALTER VIEW [Scheduling].[vMissingMaterialDemand]
AS


WITH cteRoutes
AS(
	SELECT *
	FROM dbo.Oracle_Routes
	WHERE pass_to_aps <> 'N'
)
SELECT B.item_number,B.comp_item, CAST(B.item_seq AS INT) item_seq,CAST(B.opseq AS INT) AS Bom_Op_Seq, R.operation_seq_num AS Route_Op_Seq, I.inventory_item_status_code
FROM dbo.Oracle_BOMs B LEFT JOIN cteRoutes R ON R.item_number = B.item_number AND B.opseq = R.operation_seq_num AND B.alternate_bom_designator = R.alternate_routing_designator
	INNER JOIN dbo.Oracle_Items I ON B.item_number = I.item_number
WHERE R.item_number IS NULL AND B.comp_qty_per <> 0 AND I.inventory_item_status_code NOT IN ('obsolete','cab review')
--ORDER BY I.inventory_item_status_code
GO
PRINT N'Refreshing [Setup].[vExclusionItemList]'
GO
EXEC sp_refreshview N'[Setup].[vExclusionItemList]'
GO
PRINT N'Creating [Scheduling].[vMissingMaterialDemandDj]'
GO


/*
Author:		Bryan Eddy
Desc:		View to show items with materials not assigned to an operation passing to the APS system
Date:		5/30/2018
Version:	1
Update:		n/a
*/

CREATE VIEW [Scheduling].[vMissingMaterialDemandDj]
AS


WITH cteRoutes
AS(
	SELECT *
	FROM dbo.Oracle_DJ_Routes
	WHERE send_to_aps <> 'N'
)
SELECT b.assembly_item AS item_number,b.component_item,CAST(b.operation_seq_num AS INT) AS Bom_Op_Seq, R.operation_seq_num AS Route_Op_Seq, I.inventory_item_status_code, B.wip_entity_name
FROM dbo.Oracle_DJ_BOM b LEFT JOIN cteRoutes R ON R.assembly_item = B.assembly_item AND B.operation_seq_num = R.operation_seq_num AND R.wip_entity_name = b.wip_entity_name
	INNER JOIN dbo.Oracle_Items I ON B.assembly_item = I.item_number
WHERE R.assembly_item IS NULL AND b.required_quantity <> 0 AND I.inventory_item_status_code NOT IN ('obsolete','cab review')
--ORDER BY I.inventory_item_status_code
GO
PRINT N'Altering [Setup].[vExcludedOrdersDetail]'
GO
/*
Author:			Bryan Eddy
Date:			3/16/18
Description:	Exclusion list to show just Dj's and sales orders that are affected from missing setups
Version:		2
Update:			added queries to identify jobs with missing material demand


*/

ALTER VIEW [Setup].[vExcludedOrdersDetail]
AS
	

	SELECT DISTINCT K.ConcOrderNumber, k.AssembtlyItem, K.ParentDj, G.Setup, G.operation_seq_num
	FROM Setup.vMissingSetupsDj G CROSS APPLY setup.fn_WhereUsedDj(g.wip_entity_name) K
	UNION 
	SELECT   i.conc_order_number, Item AS ItemNumber, i.wip_entity_name, i.Setup, i.operation_seq_num
	FROM Setup.vMissingSetupsDj i
	UNION 
	SELECT DISTINCT i.conc_order_number,E.AssemblyItemNumber, P.wip_entity_name,NULL,p.Bom_Op_Seq
	FROM Scheduling.vMissingMaterialDemandDj P CROSS APPLY Setup.fn_WhereUsedStdAndDJ(P.item_number) E	INNER JOIN Scheduling.vOracleOrders i ON i.child_dj_number = p.item_number
	UNION
	SELECT DISTINCT i.conc_order_number, p.item_number , p.wip_entity_name, NULL, p.Bom_Op_Seq
	FROM Scheduling.vMissingMaterialDemandDj p INNER JOIN Scheduling.vOracleOrders i ON i.parent_dj_number = p.item_number




GO
PRINT N'Refreshing [Setup].[vExcludedOrders]'
GO
EXEC sp_refreshview N'[Setup].[vExcludedOrders]'
GO
PRINT N'Refreshing [Setup].[vMissingMaterialAttributes]'
GO
EXEC sp_refreshview N'[Setup].[vMissingMaterialAttributes]'
GO
PRINT N'Refreshing [Setup].[vInterfaceMachineCapability]'
GO
EXEC sp_refreshview N'[Setup].[vInterfaceMachineCapability]'
GO
PRINT N'Refreshing [Setup].[vMachineCapability]'
GO
EXEC sp_refreshview N'[Setup].[vMachineCapability]'
GO
PRINT N'Refreshing [Setup].[vMachineAttributes]'
GO
EXEC sp_refreshview N'[Setup].[vMachineAttributes]'
GO
PRINT N'Refreshing [Setup].[vRoutesUnion]'
GO
EXEC sp_refreshview N'[Setup].[vRoutesUnion]'
GO
PRINT N'Refreshing [Setup].[vBomUnion]'
GO
EXEC sp_refreshview N'[Setup].[vBomUnion]'
GO
PRINT N'Refreshing [Setup].[vAttributeMatrixUnion]'
GO
EXEC sp_refreshview N'[Setup].[vAttributeMatrixUnion]'
GO
PRINT N'Creating [Scheduling].[usp_EmailAlertMissingMaterialDemandDj]'
GO
/*
Author:		Bryan Eddy
Date:		5/25/2018
Desc:		Email alert to show missing material demand due to material not referencing correct op sequence
Version:	1
Update:		n/a
*/

CREATE PROCEDURE [Scheduling].[usp_EmailAlertMissingMaterialDemandDj]
AS
BEGIN
	DECLARE @html nvarchar(MAX),
	@SubjectLine NVARCHAR(1000),
	@ReceipientList NVARCHAR(1000),
	@RowCount INT,
	@qry NVARCHAR(MAX),
	@body1 VARCHAR(MAX)

		SET @ReceipientList = (STUFF((SELECT ';' + UserEmail 
							FROM [NAASPB-PRD04\SQL2014].Premise.dbo.tblConfiguratorUser G  INNER JOIN [NAASPB-PRD04\SQL2014].Premise.users.UserResponsibility  K ON  G.UserID = K.UserID
	  						WHERE K.ResponsibilityID = 21 FOR XML PATH('')),1,1,''))

	SET @qry = 'SELECT item_number,
       component_item,
       Bom_Op_Seq,
       Route_Op_Seq,
       inventory_item_status_code,
       wip_entity_name
		FROM [Scheduling].[vMissingMaterialDemandDj]'

	EXEC sp_executesql @qry
	IF @@ROWCOUNT > 0 
		BEGIN

		SET @body1 = N'<H1>Missing Material DJ Demand Report</H1>' +
				N'<H2 span style=''font-size:16.0pt;font-family:"Calibri","sans-serif";color:#EB3814''>DJ Materials are not assigned to an operation passing into the APS system.</H2>' 
	

			SET @SubjectLine = 'Missing Material Demand ' + CAST(GETDATE() AS NVARCHAR(50))
			EXEC Scheduling.usp_QueryToHtmlTable @html = @html OUTPUT,  
			@query =@qry, @orderBy = N'ORDER BY item_number'

			SET @html = @body1 + @html

			EXEC msdb.dbo.sp_send_dbmail 
			@recipients=@ReceipientList,
			--@recipients = 'bryan.eddy@aflglobal.com',
			@blind_copy_recipients = 'bryan.eddy@aflglobal.com',
			@subject = @SubjectLine,
			@body = @html,
			@body_format = 'HTML',
			@query_no_truncate = 1,
			@attach_query_result_as_file = 0;
		END
END

GO
PRINT N'Refreshing [Setup].[vSetupTimes]'
GO
EXEC sp_refreshview N'[Setup].[vSetupTimes]'
GO
PRINT N'Altering [Setup].[usp_CalculateSetupTimesFromOracle]'
GO






-- =============================================
-- Author:      Bryan Eddy
-- Create date: 8/14/2017
-- Description: Procedure pulls data from various Oracle points to calculate item setup times
-- Version:		6
-- Update:		Added insert to get DJ items missing from the setup data
-- =============================================

ALTER PROCEDURE [Setup].[usp_CalculateSetupTimesFromOracle]
AS

	SET NOCOUNT ON;
BEGIN

TRUNCATE TABLE SETUP.AttributeSetupTimeItem

DECLARE @ErrorNumber INT = ERROR_NUMBER();
DECLARE @ErrorLine INT = ERROR_LINE();



	--Add to procedure to only grab the top row in case of dupblicate values
	IF OBJECT_ID(N'tempdb..#Temp', N'U') IS NOT NULL
	DROP TABLE #Temp;
	WITH cteSetup
	as(
		SELECT DISTINCT k.item_number,true_operation_code,U.MachineGroupID,M.MachineID,R.AttributeNameID,G.comp_item, attribute_name, attribute_value, o.inventory_item_status_code, ValueTypeID
		--,COUNT(comp_item) OVER (PARTITION BY true_operation_code, comp_item) CountOfComponent
		FROM dbo.Oracle_Routes K INNER JOIN DBO.Oracle_BOMs G ON G.item_number = K.item_number AND G.opseq = K.operation_seq_num
		INNER JOIN Oracle_Item_Attributes P ON P.item_number = G.comp_item
		INNER JOIN setup.vMachineCapability M ON M.Setup = K.true_operation_code
		INNER JOIN setup.ApsSetupAttributeReference R ON R.OracleAttribute = P.attribute_name
		INNER JOIN [Setup].[vMachineAttributes] V ON R.AttributeNameID = V.AttributeNameID 
		INNER JOIN SETUP.MachineNames U ON U.MachineGroupID = V.MachineGroupID AND U.MachineID = M.MachineID
		INNER JOIN dbo.Oracle_Items O ON O.item_number = P.item_number
		--WHERE G.alternate_bom_designator = 'primary'
	),
	cteDup
	as(
		SELECT item_number,true_operation_code,MachineGroupID,MachineID,AttributeNameID,comp_item,attribute_name,attribute_value,ValueTypeID,
		COUNT(comp_item) OVER (PARTITION BY item_number) Countof
		FROM cteSetup
	)
	SELECT DISTINCT *
	INTO #TEMP
	FROM cteDup

	--Create index on #Temp table to speed up insert statements
	CREATE NONCLUSTERED INDEX Temp_Index
	ON [dbo].#temp ([attribute_name])
	INCLUDE ([item_number],[true_operation_code],[MachineGroupID],MachineID,[AttributeNameID],[comp_item],[attribute_value],[ValueTypeID])

	--SELECT DISTINCT true_operation_code, attribute_name
	--FROM #TEMP
	--WHERE MACHINEGROUPID = 2
	--ORDER BY true_operation_code

	--Insert jacket type for each operation with a jacket
	BEGIN TRY
		BEGIN TRAN
			;WITH cteJacket
			as(
				SELECT *, ROW_NUMBER() OVER (PARTITION BY item_number,true_operation_Code,MachineGroupID,MachineID,AttributeNameID  ORDER BY item_number,comp_item Desc ) AS RowNumber
				FROM #TEMP
				WHERE attribute_name = 'JACKET' 
			)

			INSERT INTO [Setup].AttributeSetupTimeItem (Item_Number,[Setup],[MachineGroupID],MachineID,AttributeNameID,[SetupAttributeValue],[SetupTime])
			SELECT DISTINCT item_number,true_operation_code,T.MachineGroupID,T.MachineID,T.AttributeNameID,comp_item,CASE WHEN T.ValueTypeID = 5 THEN NULL ELSE TimeValue END 
			FROM cteJacket T LEFT JOIN setup.AttributeMatrixFixedValue K ON K.AttributeNameID = T.AttributeNameID AND  K.MachineID = T.MachineID
			WHERE Rownumber = 1 --AND  item_number ='DNA-28547-01'
			ORDER BY true_operation_code

			COMMIT TRAN
		END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
 

 
		PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
		PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
		THROW;
	END CATCH;



	--Insert color for each operation.
	--Looks at color chips and compound. Color chips take precedence over compound for coloring
	BEGIN TRY
		BEGIN TRAN
			;WITH cteColor
			as(
				SELECT K.item_number,
                       K.true_operation_code,
                       K.MachineGroupID,
                       K.MachineID,
                       K.AttributeNameID,
                       K.comp_item,
                       K.attribute_name,
                       K.attribute_value,
                       K.ValueTypeID,
                       K.Countof, ROW_NUMBER() OVER (PARTITION BY K.item_number,true_operation_Code,MachineGroupID,MachineID,AttributeNameID   ORDER BY K.item_number,(CASE WHEN G.attribute_value = 'COLOR CHIPS' THEN 1 ELSE 0 END)  Desc ) AS RowNumber
				,CASE WHEN G.attribute_value = 'COLOR CHIPS' THEN 1 ELSE 0 END  ColorOrder, g.attribute_value Material_Type
				FROM #TEMP K  INNER JOIN dbo.Oracle_Item_Attributes G ON K.comp_item = G.item_number
				WHERE K.attribute_name = 'COLOR'  AND G.attribute_name = 'MATERIAL TYPE' AND G.attribute_value IN ('COLOR CHIPS','COMPOUND')
			)

			INSERT INTO [Setup].AttributeSetupTimeItem (Item_Number,[Setup],[MachineGroupID],MachineID,AttributeNameID,[SetupAttributeValue],[SetupTime])
			SELECT DISTINCT item_number,true_operation_code,T.MachineGroupID,T.MachineID,T.AttributeNameID,attribute_value,CASE WHEN T.ValueTypeID = 5 THEN NULL ELSE TimeValue END-- , T.ValueTypeID
			FROM cteColor T LEFT JOIN setup.AttributeMatrixFixedValue K ON K.AttributeNameID = T.AttributeNameID AND K.MachineID = T.MachineID
			WHERE Rownumber = 1 --AND T.MachineGroupID = 4
			--ORDER BY true_operation_code
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
 
 
		PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
		PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
		THROW;
	END CATCH;


	--Calculate aramid setup time
	--Each end of aramid is multiplied by a time value
	BEGIN TRY
		BEGIN TRAN
			;WITH cteAramid
			as(
				SELECT K.item_number,[Setup],MG.[MachineGroupID],M.MachineID,MG.AttributeNameID,CAST(count_per_uom AS INT) SetupAttributeValue,TimeValue * cast(count_per_uom as int) + COALESCE(Adder,0) as SetupTime--, MG.ValueTypeID
				FROM setup.MachineGroupAttributes MG INNER JOIN setup.MachineNames M ON M.MachineGroupID = MG.MachineGroupID
				INNER JOIN setup.vMachineCapability T ON T.MachineID = M.MachineID
				INNER JOIN dbo.Oracle_Routes G ON G.true_operation_code = T.Setup
				INNER JOIN dbo.Oracle_BOMs K ON K.item_number = G.item_number AND K.opseq = G.operation_seq_num AND G.alternate_routing_designator = K.alternate_bom_designator
				INNER JOIN dbo.Oracle_Item_Attributes A ON A.item_number = K.comp_item 
				INNER JOIN setup.ApsSetupAttributeReference R ON R.AttributeNameID = MG.AttributeNameID AND R.OracleAttribute = A.attribute_value
				INNER JOIN setup.vAttributeMatrixUnion MU ON MU.AttributeNameID = MG.AttributeNameID AND MU.MachineGroupID = MG.MachineGroupID and mu.MachineID = t.MachineID
				WHERE MG.ValueTypeID = 3 and k.alternate_bom_designator = 'primary' --AND K.item_number = 'o-ts-0151-02'
			)
			INSERT INTO [Setup].AttributeSetupTimeItem (Item_Number,[Setup],[MachineGroupID],MachineID,AttributeNameID,[SetupAttributeValue],[SetupTime])
			SELECT item_number,Setup, MachineGroupID, MachineID, AttributeNameID, SUM(SetupAttributeValue) EndsOfAramid, SUM(SetupTime) SetupTime
			FROM cteAramid
			GROUP BY item_number,Setup, MachineGroupID, MachineID, AttributeNameID
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
 
 
		PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
		PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
		THROW;
	END CATCH;


	--Calculate EFL gain for SS RW 
	--Get's EFL from the Oracle specs
	BEGIN TRY
		BEGIN TRAN
			;WITH cteEFL
			AS(
			SELECT  DISTINCT a.itemnumber,[Setup],MG.[MachineGroupID],M.MachineID,MG.AttributeNameID,COALESCE(CAST(a.TargetValue AS FLOAT),0) SetupAttributeValue,TimeValue--, a.SpecificationElement
			,ROW_NUMBER() OVER (PARTITION BY a.itemnumber,[Setup],MG.[MachineGroupID],M.MachineID,MG.AttributeNameID ORDER BY  a.itemnumber) RowNumber
			FROM setup.MachineGroupAttributes MG INNER JOIN setup.MachineNames M ON M.MachineGroupID = MG.MachineGroupID
				INNER JOIN setup.vMachineCapability T ON T.MachineID = M.MachineID
				INNER JOIN dbo.Oracle_Routes G ON G.true_operation_code = T.Setup
				INNER JOIN [NAASPB-PRD04\SQL2014].Premise.dbo.AFLPRD_INVSysItemSpec_CAB A ON a.itemnumber = g.item_number 
				INNER JOIN setup.ApsSetupAttributeReference R ON R.AttributeNameID = MG.AttributeNameID AND A.SpecificationElement = r.OracleAttribute
				INNER JOIN setup.vAttributeMatrixUnion MU ON MU.AttributeNameID = MG.AttributeNameID AND MU.MachineGroupID = MG.MachineGroupID AND mu.MachineID = t.MachineID AND MG.ValueTypeID = MU.ValueTypeID
			WHERE mg.MachineGroupID = 11 AND mg.ValueTypeID = 2 
			)
			INSERT INTO [Setup].AttributeSetupTimeItem (Item_Number,[Setup],[MachineGroupID],MachineID,AttributeNameID,[SetupAttributeValue],[SetupTime])
			SELECT itemnumber,[Setup],[MachineGroupID],MachineID,AttributeNameID,SetupAttributeValue,TimeValue
			FROM cteEFL
			WHERE RowNumber = 1
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
 
		PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
		PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));

		THROW;
	END CATCH;

	--Insert all items for setups
	BEGIN TRY
		BEGIN TRAN
			INSERT INTO [Setup].AttributeSetupTimeItem (Item_Number,[Setup],[MachineGroupID],MachineID,AttributeNameID,[SetupAttributeValue],[SetupTime])
			SELECT DISTINCT Item_Number,[Setup],g.[MachineGroupID],MachineID,AttributeNameID,[SetupAttributeValue],[SetupTime]
			FROM Setup.vSetupTimes G INNER JOIN  dbo.Oracle_Routes K ON K.true_operation_code = G.Setup
			--WHERE  AttributeNameID = 8
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;

		PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
		PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
		THROW;
	END CATCH;


	--Insert fibercount time values based on Value Type 4 (multiply depending on the value)
	--Fiber Count is calculated using the Value Type 4 logic, but then is inserted as a FiberSet with value type 2 logic for PT to interpret
	--Using the FiberCount calculation is dependent upon if the FiberSet has changed.  
	--Reduced to 8 seconds to insert data.  
	BEGIN TRY

		IF OBJECT_ID(N'tempdb..#MachineCapability', N'U') IS NOT NULL
		DROP TABLE #MachineCapability;

		SELECT *
		INTO #MachineCapability
		FROM Setup.vMachineCapability

		CREATE NONCLUSTERED INDEX MachineCapability_IXX
		ON [dbo].#MachineCapability (MachineID)

		CREATE NONCLUSTERED INDEX MachineCapability_Setup_IX
		ON [dbo].#MachineCapability (Setup)
		--INCLUDE ([item_number],[true_operation_code],[MachineGroupID],MachineID,[AttributeNameID],[comp_item],[attribute_value],[ValueTypeID])
		
		BEGIN TRAN
			INSERT INTO [Setup].AttributeSetupTimeItem (Item_Number,[Setup],[MachineGroupID],MachineID,AttributeNameID,[SetupAttributeValue],[SetupTime])
  			SELECT DISTINCT Item_Number,G.true_operation_code,I.[MachineGroupID],I.MachineID,8 AttributeNameID,K.FiberCount,K.FiberCount * TimeValue--, K.FiberCount, U.TimeValue, I.MachineName		--Calculates the TimeValue per fibercount and then inserts it for FiberSet for PT to pick up
			FROM Setup.ItemAttributes K INNER JOIN dbo.Oracle_Routes G ON G.item_number = K.ItemNumber 
			INNER JOIN #MachineCapability P ON P.Setup = G.true_operation_code
			INNER JOIN Setup.AttributeMatrixFixedValue U ON  P.MachineID = U.MachineID
			INNER JOIN Setup.MachineGroupAttributes Y ON Y.AttributeNameID = U.AttributeNameID 
			INNER JOIN Setup.MachineNames I ON I.MachineGroupID = Y.MachineGroupID AND U.MachineID = I.MachineID
			WHERE ValueTypeID = 3 AND U.AttributeNameID = 7 AND I.MachineGroupID = 2
		COMMIT TRAN
	END TRY
	BEGIN CATCH	
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
		PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
		PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
		THROW;
	END CATCH;


	--Insert fibercount based setup time based on the fiber count Value Type 7 (fixed value chosen that is dependent on the fiber count) for QC operations
	BEGIN TRY
		BEGIN TRAN
			INSERT INTO [Setup].AttributeSetupTimeItem (Item_Number,[Setup],[MachineGroupID],MachineID,AttributeNameID,[SetupAttributeValue],[SetupTime])
			SELECT DISTINCT Item_Number,operation_code,[MachineGroupID],p.MachineID AS MachineID,u.AttributeNameID,FiberCount,TimeValue
			FROM setup.ItemFiberCountByOperation K INNER JOIN dbo.Oracle_Routes G ON G.item_number = K.ItemNumber AND K.TrueOperationCode = G.true_operation_code
			INNER JOIN Setup.DepartmentIndicator P ON p.department_code = g.department_code
			INNER JOIN Setup.AttributeMatrixVariableValue U ON U.AttributeValue = K.FiberCount AND P.MachineID = U.MachineID
			INNER JOIN Setup.vMachineAttributes Y ON Y.MachineID = P.MachineID AND Y.AttributeNameID = U.AttributeNameID 
			WHERE ValueTypeID = 7 AND pass_to_aps NOT IN ('d','N') AND K.PrimaryAlternate = 'primary' 
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
		PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
		PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
		THROW;
	END CATCH;


	--Insert fibercount based setup time based on the fiber count Value Type 3 (multiply by number of fibers) for QC operations
	BEGIN TRY
		BEGIN TRAN
			INSERT INTO [Setup].AttributeSetupTimeItem (Item_Number,[Setup],[MachineGroupID],AttributeSetupTimeItem.MachineID,AttributeNameID,[SetupAttributeValue],[SetupTime])
			SELECT DISTINCT K.ItemNumber,TrueOperationCode,[MachineGroupID],G.MachineID AS MachineID,u.AttributeNameID,FiberCount,TimeValue*FiberCount
			FROM setup.ItemFiberCountByOperation K
			INNER JOIN Scheduling.MachineCapabilityScheduler G ON G.Setup = K.TrueOperationCode
			INNER JOIN Setup.AttributeMatrixFixedValue U ON G.MachineID = U.MachineID
			INNER JOIN Setup.vMachineAttributes Y ON Y.MachineID = G.MachineID AND Y.AttributeNameID = U.AttributeNameID 
			WHERE ValueTypeID = 3 AND k.PrimaryAlternate = 'primary' AND U.AttributeNameID = 7

		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
		PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
		PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
		THROW;
	END CATCH;


	--Insert if buffering item is printed based on the %-[wb]/s% indicator in the item description.
	--This is for ACS buffering items only
	BEGIN TRY
		BEGIN TRAN
			INSERT INTO [Setup].AttributeSetupTimeItem (Item_Number,[Setup],[MachineGroupID],AttributeSetupTimeItem.MachineID,AttributeNameID,[SetupAttributeValue],[SetupTime])
			SELECT DISTINCT G.item_number,I.Setup,[MachineGroupID],I.MachineID,u.AttributeNameID,(CASE WHEN G.item_description LIKE '%-[WB]/S%' THEN '1' ELSE '0' END), NULL--, K.product_class
			FROM dbo.Oracle_Items K INNER JOIN dbo.Oracle_Routes G ON G.item_number = K.item_number
			INNER JOIN SETUP.vMachineCapability I ON I.SETUP = G.true_operation_code
			INNER JOIN Setup.AttributeMatrixFromTo U ON I.MachineID = U.MachineID
			INNER JOIN Setup.vMachineAttributes Y ON Y.MachineID = I.MachineID AND Y.AttributeNameID = U.AttributeNameID 
			WHERE ValueTypeID = 5 AND U.AttributeNameID = 37 AND k.product_class  NOT LIKE '%Premise%'
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
		PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
		PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
		THROW;
	END CATCH;



	
	--Insert color prefered sequence
	BEGIN TRY
		BEGIN TRAN
			INSERT INTO [Setup].AttributeSetupTimeItem (Item_Number,[Setup],[MachineGroupID],AttributeSetupTimeItem.MachineID,AttributeNameID,[SetupAttributeValue],[SetupTime])
			SELECT k.Item_Number, k.Setup, I.MachineGroupID, K.MachineID, I.AttributeNameID, PreferedSequence, 0 AS SetupTime
			FROM [Setup].AttributeSetupTimeItem k INNER JOIN Setup.ColorSequencePreference J ON J.Color = k.SetupAttributeValue
				INNER JOIN Setup.MachineGroupAttributes I ON I.MachineGroupID = K.MachineGroupID
				WHERE I.AttributeNameID = 38
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
 
 
		PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
		PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
		THROW;
	END CATCH;


			--Insert setup information for all DJ's with setup that is not located on the std op
	BEGIN TRY
		BEGIN TRAN
			;WITH cteSetups --Get setup information for all Routing DJs
			AS(
				SELECT DISTINCT Item_Number,[Setup],[MachineGroupID],MachineID,AttributeNameID,[SetupAttributeValue],[SetupTime]
						FROM setup.AttributeSetupTimeItem K INNER JOIN dbo.Oracle_DJ_Routes B ON K.Setup = b.true_operation_code
				),
			cteMissingSetupItems --GEt which DJ items are missing from the setup data
				AS(
				SELECT R.assembly_item, R.true_operation_code 
				FROM dbo.Oracle_DJ_Routes R LEFT JOIN  Setup.AttributeSetupTimeItem S ON R.assembly_item = S.Item_Number
				WHERE S.Item_Number IS NULL AND R.send_to_aps <> 'N'
				)
			INSERT INTO setup.AttributeSetupTimeItem ([Setup],[MachineGroupID],MachineID,AttributeNameID,[SetupAttributeValue],[SetupTime])
			SELECT DISTINCT [Setup],[MachineGroupID],MachineID,AttributeNameID,[SetupAttributeValue],[SetupTime]
			FROM cteMissingSetupItems K INNER JOIN cteSetups S ON S.Item_Number = K.assembly_item AND S.Setup = K.true_operation_code
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;

		PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
		PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
		THROW;
	END CATCH;

END







GO
PRINT N'Creating [Scheduling].[vStaleMaterialsFlat]'
GO

/*
Author:		Bryan Eddy
Date:		5/31/2018
Desc:		Flattened version of the stale materials view
Version:	1
Update:		n/a
*/

CREATE VIEW [Scheduling].[vStaleMaterialsFlat]
as
SELECT DISTINCT FinishedGood, d.Materials, E.Orders
    FROM [Scheduling].[vStaleMaterials]  p1
   CROSS APPLY ( SELECT DISTINCT  Material + ',' 
                     FROM [Scheduling].[vStaleMaterials] p2
                     WHERE p2.FinishedGood = p1.FinishedGood 
                     FOR XML PATH('') )  D ( Materials )
	CROSS APPLY ( SELECT DISTINCT p3.conc_order_number + ',' 
                     FROM [Scheduling].[vStaleMaterials] p3
                     WHERE p3.FinishedGood = p1.FinishedGood
                     FOR XML PATH('') )  E ( Orders )

GO
PRINT N'Altering [Scheduling].[usp_EmailOrdersStaleMaterials]'
GO

/*
Author:		Bryan Eddy
Date:		4/4/2018
Desc:		Alert of materials that haven't been orderd in more than 9 months
Version:	2
Update:		Changed the view to pull stale materials data to a flattened data set
*/

ALTER PROCEDURE [Scheduling].[usp_EmailOrdersStaleMaterials]
AS
BEGIN
	DECLARE @html nvarchar(MAX),
	@SubjectLine NVARCHAR(1000),
	@ReceipientList NVARCHAR(1000),
	@RowCount INT,
	@qry NVARCHAR(MAX),
	@body1 VARCHAR(MAX),
	@html2 NVARCHAR(MAX);

		--Get list of users to email
		SET @ReceipientList = (STUFF((SELECT ';' + UserEmail 
							FROM [NAASPB-PRD04\SQL2014].Premise.dbo.tblConfiguratorUser G  INNER JOIN [NAASPB-PRD04\SQL2014].Premise.users.UserResponsibility  K ON  G.UserID = K.UserID
	  						WHERE K.ResponsibilityID = 22 FOR XML PATH('')),1,1,''))

	--Get count of records to ensure alert should fire off
	SET @qry = 'SELECT count(*) FROM Scheduling.vStaleMaterials'

	EXEC sp_executesql @qry
	IF @@ROWCOUNT > 0 
		BEGIN

		SET @body1 = N'<H1>Stale Materials Report</H1>' +
				N'<H2 span style=''font-size:16.0pt;font-family:"Calibri","sans-serif";color:#EB3814''>Materials not purchased in the past 9 months, Booked / Not Schedule Approved.</H2>' 
	
			SET @SubjectLine = 'Stale Materials Report ' + CAST(GETDATE() AS NVARCHAR(50))

			--Get flattened material demand grouped by finished good
			EXEC Scheduling.usp_QueryToHtmlTable @query = N'SELECT FinishedGood,
								Materials,
								Orders
								FROM Scheduling.vStaleMaterialsFlat',   
                            @orderBy = N'FinishedGood',     
                            @html = @html OUTPUT 

			--Get flattened material demand data grouped by Material and buyer
			EXEC Scheduling.usp_QueryToHtmlTable @query = N'SELECT Material,Buyer,
								FinishedGood,
								Orders
								FROM Scheduling.vStaleMaterialsFlatByBuyer',        
                            @orderBy = N'Buyer',     
                            @html = @html2 OUTPUT 

							PRINT @html2
SET @html =  @html + '<H1>Stale Materials Report Grouped By Material/Buyer</H1><div></div><div>' +  @html2 + '</div>'

			SET @html = @body1 + @html

			EXEC msdb.dbo.sp_send_dbmail 
			--@recipients=@ReceipientList,
			@recipients = 'bryan.eddy@aflglobal.com',
			@blind_copy_recipients = 'bryan.eddy@aflglobal.com',
			@subject = @SubjectLine,
			@body = @html,
			@body_format = 'HTML',
			@query_no_truncate = 1,
			@attach_query_result_as_file = 0;
		END
END


GO
PRINT N'Creating [Scheduling].[usp_EmailAlertMissingMaterialDemand]'
GO
/*
Author:		Bryan Eddy
Date:		5/25/2018
Desc:		Email alert to show missing material demand due to material not referencing correct op sequence
Version:	1
Update:		n/a
*/

CREATE PROCEDURE [Scheduling].[usp_EmailAlertMissingMaterialDemand]
AS
BEGIN
	DECLARE @html nvarchar(MAX),
	@SubjectLine NVARCHAR(1000),
	@ReceipientList NVARCHAR(1000),
	@RowCount INT,
	@qry NVARCHAR(MAX),
	@body1 VARCHAR(MAX)

		SET @ReceipientList = (STUFF((SELECT ';' + UserEmail 
							FROM [NAASPB-PRD04\SQL2014].Premise.dbo.tblConfiguratorUser G  INNER JOIN [NAASPB-PRD04\SQL2014].Premise.users.UserResponsibility  K ON  G.UserID = K.UserID
	  						WHERE K.ResponsibilityID = 21 FOR XML PATH('')),1,1,''))

	SET @qry = 'SELECT item_number,
       comp_item,
       item_seq,
       Bom_Op_Seq,
       Route_Op_Seq,
       inventory_item_status_code
		FROM [Scheduling].[vMissingMaterialDemand]'

	EXEC sp_executesql @qry
	IF @@ROWCOUNT > 0 
		BEGIN

		SET @body1 = N'<H1>Missing Material Demand Report</H1>' +
				N'<H2 span style=''font-size:16.0pt;font-family:"Calibri","sans-serif";color:#EB3814''>Materials are not assigned to an operation passing into the APS system.</H2>' 
	

			SET @SubjectLine = 'Missing Material Demand ' + CAST(GETDATE() AS NVARCHAR(50))
			EXEC Scheduling.usp_QueryToHtmlTable @html = @html OUTPUT,  
			@query =@qry, @orderBy = N'ORDER BY item_number'

			SET @html = @body1 + @html

			EXEC msdb.dbo.sp_send_dbmail 
			@recipients=@ReceipientList,
			--@recipients = 'bryan.eddy@aflglobal.com',
			@blind_copy_recipients = 'bryan.eddy@aflglobal.com',
			@subject = @SubjectLine,
			@body = @html,
			@body_format = 'HTML',
			@query_no_truncate = 1,
			@attach_query_result_as_file = 0;
		END
END

GO
PRINT N'Altering [Scheduling].[usp_EmailMasterAlert]'
GO


/*	Author:	Bryan Eddy
	Date:	11/18/2017
	Desc:	Master scheduling alert that has been added to the daily run job.	
	Version:	2
	Update:		Added email alert for missing material demand
*/

ALTER PROCEDURE [Scheduling].[usp_EmailMasterAlert]
AS
BEGIN
	EXEC Scheduling. usp_EmailSchedulerMachineCapabilityIssue

	EXEC [Setup].usp_EmailMissingMaterialAttribute

	EXEC [Setup].[usp_EmailMissingDjSetup]

	EXEC Scheduling.usp_EmailSchedulingMissingLineSpeed

	EXEC Scheduling.usp_EmailAlertMissingMaterialDemand

	EXEC [Scheduling].[usp_EmailAlertMissingMaterialDemandDj]

	EXEC Scheduling.usp_EmailOrdersStaleMaterials

END
GO
PRINT N'Altering [Scheduling].[usp_EmailMfgHoldAlert]'
GO
/*
Author:		Bryan Eddy
Date:		5/16/2018
Desc:		Alert for items with mfg hold that are <= 21 days from promised date
Version:	1
Update:		n/a

*/

ALTER PROCEDURE [Scheduling].[usp_EmailMfgHoldAlert]
AS
BEGIN
	DECLARE @html nvarchar(MAX),
	@SubjectLine NVARCHAR(1000),
	@ReceipientList NVARCHAR(1000),
	@qry NVARCHAR(MAX)

		SET @ReceipientList = (STUFF((SELECT ';' + UserEmail 
							FROM [NAASPB-PRD04\SQL2014].Premise.dbo.tblConfiguratorUser G  INNER JOIN [NAASPB-PRD04\SQL2014].Premise.users.UserResponsibility  K ON  G.UserID = K.UserID
	  						WHERE K.ResponsibilityID = 19 FOR XML PATH('')),1,1,''))


	SET @qry = N'SELECT order_number, conc_order_number, CAST(promise_date as DATE) promise_date, CAST(need_by_date AS DATE) need_by_date, has_mfg_hold, assembly_item, 
	customer_name, scheduler, CAST(pri_uom_order_qty AS INT) pri_uom_order_qty FROM Scheduling.vAlertMfgHold'


	EXEC sp_executesql @qry
	IF @@ROWCOUNT > 0 
	BEGIN

		SET @SubjectLine = 'MFG Hold Alert ' + CAST(GETDATE() AS NVARCHAR(50))
		EXEC Scheduling.usp_QueryToHtmlTable @html = @html OUTPUT,  
		@query = @qry, @orderBy = N'ORDER BY order_number';




						EXEC msdb.dbo.sp_send_dbmail 
						@recipients=@ReceipientList,
						--@recipients = 'bryan.eddy@aflglobal.com',
						--@blind_copy_recipients =  @BlindRecipientlist, --@ReceipientList
						@blind_copy_recipients = 'bryan.eddy@aflglobal.com',
						@subject = @SubjectLine,
						@body = @html,
						@body_format = 'HTML',
						@query_no_truncate = 1,
						@attach_query_result_as_file = 0;
	END
END
GO
PRINT N'Refreshing [Setup].[vExcludedOrdersAll]'
GO
EXEC sp_refreshview N'[Setup].[vExcludedOrdersAll]'
GO
PRINT N'Altering [Scheduling].[vDjStatusConflict]'
GO


/*
Author:		Bryan Eddy
Date:		4/3/2018
Desc:		Display jobs with status conflicts.  Created to report issues with jobs having process status conflicts.  Example: Two simultaneous operations running for a single job
Version:	2
Update:		Added additional fields to display in the email alert
*/
ALTER VIEW [Scheduling].[vDjStatusConflict]
AS


WITH

next_op
AS
(
SELECT        r.wip_entity_name, r.operation_seq_num AS c_op, MIN(r2.operation_seq_num) AS n_op
                          FROM            dbo.Oracle_DJ_Routes AS r LEFT OUTER JOIN
                                                    dbo.Oracle_DJ_Routes AS r2 ON r.wip_entity_name = r2.wip_entity_name AND r.operation_seq_num < r2.operation_seq_num
                          GROUP BY r.wip_entity_name, r.operation_seq_num
),

op_status
AS
(
SELECT        n.wip_entity_name, n.c_op, cr.true_operation_seq_num AS c_true_op, cr.dj_status AS c_status, cp.setup_start_time AS c_setup_start_time, cp.run_start_time AS c_run_start, cr.op_quantity_completed AS c_qty_complete, cr.start_quantity AS c_qty_start, n.n_op, nr.true_operation_seq_num AS n_true_op, nr.op_quantity_completed AS n_qty_completed,
				CASE WHEN (cr.op_quantity_completed >= cr.start_quantity) OR (nr.op_quantity_completed > 0) OR (cr.dj_status IN ('Complete','Closed')) THEN 'finished' 
				WHEN (cr.op_quantity_completed > 0) OR (cp.run_start_time IS NOT NULL) THEN 'running' 
				WHEN (cp.setup_start_time IS NOT NULL) THEN 'settingup' ELSE 'ready_wait' END AS p_status, cr.operation_code
				, cr.department_code, cp.run_end_time, cr.op_quantity_completed, cr.start_quantity
FROM            next_op AS n INNER JOIN	
				Oracle_DJ_Routes AS cr ON n.wip_entity_name = cr.wip_entity_name AND n.c_op = cr.operation_seq_num LEFT OUTER JOIN
				Oracle_DJ_Processing_Times AS cp ON n.wip_entity_name = cp.wip_entity_name AND n.c_op = cp.op_sequence LEFT OUTER JOIN
				Oracle_DJ_Routes AS nr ON n.wip_entity_name = nr.wip_entity_name AND n.n_op = nr.operation_seq_num
),

running_counts
AS
(
 SELECT wip_entity_name, COUNT(p_status) AS [count] FROM op_status
 WHERE p_status = 'running'
 GROUP BY wip_entity_name
)

	SELECT o.wip_entity_name, o.c_op AS operation_seq_num, o.n_true_op AS true_operation_seq_num, o.c_status, o.p_status, o.operation_code, o.department_code
	, o.c_setup_start_time, o.c_run_start, o.run_end_time, o.op_quantity_completed, o.start_quantity
	FROM op_status o INNER JOIN
	running_counts r ON o.wip_entity_name = r.wip_entity_name
	WHERE [count] > 1


GO
PRINT N'Altering [Scheduling].[vAlertMfgHold]'
GO


/*
Author:		Bryan Eddy
Date:		4/5/2018
Desc:		Mfg Hold Alert
Version:	1
Update:		n/a
*/

ALTER VIEW [Scheduling].[vAlertMfgHold]
AS
SELECT DISTINCT order_number, conc_order_number, promise_date, need_by_date, has_mfg_hold, assembly_item, customer_name, scheduler, pri_uom_order_qty
FROM dbo.Oracle_Orders
WHERE has_mfg_hold = 'Y' AND DATEDIFF(DD,GETDATE(),promise_date) <= 21 AND active_flag <> 'N'
GO
PRINT N'Altering [Setup].[GetItemSetupAttributes]'
GO
/*
Author:		Bryan Eddy
Date:		3/27/2018
Desc:		Create a table to pull setup attributes from for reporting
Version:	1
Update:		n/a
*/

ALTER PROC [Setup].[GetItemSetupAttributes]

as

/*
Getting setup parameters from setup information for reporting
*/

BEGIN
	SET NOCOUNT ON;

	DECLARE @ErrorNumber INT = ERROR_NUMBER();
	DECLARE @ErrorLine INT = ERROR_LINE();


	/*Insert/Add all setups for each item*/
	BEGIN TRY
		BEGIN TRAN
			INSERT INTO Setup.ItemSetupAttributes(ItemNumber,Setup)
			SELECT DISTINCT R.item_number, R.true_operation_code
			FROM Setup.vRoutesUnion R LEFT JOIN SETUP.ItemSetupAttributes K ON K.ItemNumber = R.item_number AND R.true_operation_code = K.Setup
			WHERE K.ItemNumber IS NULL AND R.true_operation_code IS NOT NULL
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
 
		PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
		PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
		THROW;
	END CATCH;



/*
Pivot the results from the Setup.vSetupTimesItem by building a temp table 
Gathering information for each setup
*/

	BEGIN TRY
		BEGIN TRAN
		--Get Od for each setup
				IF OBJECT_ID(N'tempdb..#OD', N'U') IS NOT NULL
				DROP TABLE #OD;
				SELECT DISTINCT Setup, AttributeNameID,AttributeName,SetupAttributeValue AS OD, MachineID
				INTO #OD
				FROM Setup.vSetupTimesItem WHERE AttributeNameID = 3 AND ISNUMERIC(SetupAttributeValue) = 1

				--Get Jacket Material for each setup
				IF OBJECT_ID(N'tempdb..#JacketMaterial', N'U') IS NOT NULL
				DROP TABLE #JacketMaterial;
				SELECT DISTINCT Setup, AttributeNameID,AttributeName,SetupAttributeValue AS JacketMaterial, MachineID
				INTO #JacketMaterial
				FROM Setup.vSetupTimesItem WHERE AttributeNameID = 5

				--Get number for core positions for cabling setups
				IF OBJECT_ID(N'tempdb..#CorePositions', N'U') IS NOT NULL
				DROP TABLE #CorePositions;
				SELECT DISTINCT Setup, AttributeNameID,AttributeName,SetupAttributeValue AS NumberCorePositions, MachineID
				INTO #CorePositions
				FROM Setup.vSetupTimesItem WHERE AttributeNameID = 17

				IF OBJECT_ID(N'tempdb..#Aramid', N'U') IS NOT NULL
				DROP TABLE #Aramid;
				SELECT DISTINCT Setup, AttributeNameID,AttributeName,SetupAttributeValue AS EndsOfAramid, MachineID
				INTO #Aramid
				FROM Setup.vSetupTimesItem WHERE AttributeNameID = 28



				--Insert information from the temp tables into 
				;WITH cteSetupAttributes
				AS(
				SELECT DISTINCT M.SETUP, OD, j.JacketMaterial, N.NumberCorePositions, A.EndsOfAramid
				FROM SETUP.vMachineCapability M LEFT JOIN #JacketMaterial J ON J.Setup = M.Setup
				LEFT JOIN #OD O ON o.Setup = M.setup 
				LEFT JOIN #CorePositions N ON N.Setup = M.Setup 
				INNER JOIN Setup.ItemSetupAttributes  S ON  S.Setup = M.Setup
				LEFT JOIN #Aramid A ON A.SETUP = M.Setup
				)
				UPDATE  Setup.ItemSetupAttributes
				SET NominalOD = od, NumberCorePositions = g.NumberCorePositions, JacketMaterial = g.JacketMaterial,
				EndsOfAramid = g.EndsOfAramid
				FROM cteSetupAttributes g INNER JOIN Setup.ItemSetupAttributes k ON k.setup = g.Setup
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
 
		PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
		PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
		THROW;
	END CATCH;


--Get UJCM for each cabling operation
	BEGIN TRY
		BEGIN TRAN
			;WITH cteUJCM
			AS(
				SELECT DISTINCT Setup, B.comp_item as UJCM
				--,COUNT(B.comp_item) OVER (PARTITION BY M.Setup,comp_item, r.alternate_routing_designator, R.wip_entity_name) AS UjcmCount
				, B.item_number
				FROM dbo.Oracle_Routes R INNER JOIN Setup.vMachineCapability M ON M.Setup = R.true_operation_code
				INNER JOIN Setup.MachineNames C ON C.MachineID = M.MachineID 
				INNER JOIN dbo.Oracle_BOMs B ON B.alternate_bom_designator = R.alternate_routing_designator AND B.opseq = R.operation_seq_num AND B.item_number = R.item_number
				INNER JOIN dbo.Oracle_Items I ON I.item_number = B.comp_item
				WHERE C.MachineGroupID = 13 AND I.product_class LIKE 'Cable.%.Raw Material.Filler.UJCM' 
			)
			,cteItemUjcm
			AS(
				SELECT *, ROW_NUMBER() OVER (PARTITION BY cteUJCM.Setup, cteUJCM.item_number ORDER BY cteUJCM.UJCM DESC) AS RowNumber
				--INTO #Ujcm
				FROM cteUJCM
			)
			UPDATE G 
			SET UJCM =  k.UJCM
			FROM cteItemUjcm k INNER JOIN Setup.ItemSetupAttributes g ON g.Setup = k.Setup AND g.ItemNumber = k.item_number
			WHERE k.RowNumber =1
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
 
		PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
		PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
		THROW;
	END CATCH;

END
GO
PRINT N'Altering [Scheduling].[vOpenPOs]'
GO


/****** Script for SelectTopNRows command from SSMS  ******/
/*
Author:		Bryan Eddy
Date:		4/27/2018
Desc:		View to show open PO's from buyers to vendors for materials
Version:	2
Update:		Removed negative open po qty parameter
*/
ALTER VIEW [Scheduling].[vOpenPOs]
AS
SELECT item_number, open_po_qty_primary, vendor_name, po_number,promised_date, need_by_date, primary_uom_code,category_name
  FROM [dbo].[Oracle_POs]
  WHERE open_po_qty_primary > 0

GO
PRINT N'Altering [dbo].[_report_9a_bobbin_usage_release]'
GO
ALTER TABLE [dbo].[_report_9a_bobbin_usage_release] DROP
COLUMN [Job],
COLUMN [Op],
COLUMN [OrderNumber]
GO
ALTER TABLE [dbo].[_report_9a_bobbin_usage_release] ALTER COLUMN [BobbinStageUsageDurationDays] [float] NOT NULL
GO
PRINT N'Rebuilding [dbo].[_report_3c_acs_order_status_review]'
GO
CREATE TABLE [dbo].[RG_Recovery_2__report_3c_acs_order_status_review]
(
[conc_order_number] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customer_name] [varchar] (360) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[job] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[part_number] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[so_qty] [float] NULL,
[request_date] [datetime] NULL,
[promise_date] [datetime] NULL,
[schedule_ship_date] [datetime] NULL,
[schedule_approved] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[has_credit_hold] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[has_mfg_hold] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[has_export_hold] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[has_shipping_hold] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[scheduled_setup_start] [datetime] NULL,
[machine_name] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[component_item] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProductionStatus] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[material_earliest_start_date] [datetime] NULL,
[last_update_date] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
INSERT INTO [dbo].[RG_Recovery_2__report_3c_acs_order_status_review]([conc_order_number], [customer_name], [job], [part_number], [so_qty], [request_date], [promise_date], [schedule_ship_date], [schedule_approved], [scheduled_setup_start], [machine_name], [component_item], [ProductionStatus], [material_earliest_start_date], [last_update_date]) SELECT [conc_order_number], [customer_name], [job], [part_number], [so_qty], [request_date], [promise_date], [schedule_ship_date], [schedule_approved], [scheduled_setup_start], [machine_name], [component_item], [ProductionStatus], [material_earliest_start_date], [last_update_date] FROM [dbo].[_report_3c_acs_order_status_review]
GO
DROP TABLE [dbo].[_report_3c_acs_order_status_review]
GO
EXEC sp_rename N'[dbo].[RG_Recovery_2__report_3c_acs_order_status_review]', N'_report_3c_acs_order_status_review', N'OBJECT'
GO

