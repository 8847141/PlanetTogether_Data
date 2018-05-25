/*
This migration script replaces uncommitted changes made to these objects:
Oracle_DJ_BOM
Oracle_Onhand
Oracle_Orders
Oracle_USAC_PO_SO
_report_3e_mrg_nonfiber
_report_3f_mrg_fiber
EmailAlertMissingMaterialDemand
usp_EmailMasterAlert
usp_EmailMfgHoldAlert
usp_EmailSchedulingMissingLineSpeed
usp_MasterDailyProcedureRun
usp_QueryToHtmlTable
vLateOrders
vMissingMaterialDemand
vBomUnion
vExclusionItemList
fn_ExplodeBOM

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
PRINT N'Disabling table change tracking'
GO
ALTER TABLE [dbo].[Oracle_Onhand] DISABLE CHANGE_TRACKING
GO
PRINT N'Dropping [dbo].[fn_ExplodeBOM]'
GO
DROP FUNCTION [dbo].[fn_ExplodeBOM]
GO
PRINT N'Altering [Scheduling].[vLateOrders]'
GO
/*
Author:		Bryan Eddy
Date:		4/12/2018
Desc:		View for reporting of late orders
Version:	1
Update:		n/a
*/


/* TO DO : Order Quantity */
ALTER VIEW [Scheduling].[vLateOrders]
as
SELECT DISTINCT  order_number, I.customer_name, assembly_item, pri_uom_order_qty, order_scheduled_end_date,promise_date,
CASE WHEN promise_date < schedule_ship_date THEN schedule_ship_date END Recommit,
 DATEDIFF(MM,promise_date,schedule_ship_date) PromiseDeltaMonths
, late_order, I.schedule_approved, K.last_update_date
FROM dbo._report_4a_production_master_schedule K INNER JOIN (SELECT customer_name, conc_order_number,assembly_item,pri_uom_order_qty, schedule_approved FROM  dbo.Oracle_Orders) I ON I.conc_order_number = K.order_number
WHERE promise_date < order_scheduled_end_date AND late_order = 'Y'
GO
PRINT N'Refreshing [Scheduling].[vOracleOrders]'
GO
EXEC sp_refreshview N'[Scheduling].[vOracleOrders]'
GO
PRINT N'Creating [dbo].[fn_ExplodeBOM]'
GO

CREATE FUNCTION [dbo].[fn_ExplodeBOM] 
(
-- Input parameters
   @FinishedGood VARCHAR(100)
)
RETURNS
@BOM TABLE
(
   -- Returned table layout
   FinishedGood VARCHAR(100),
   item_number VARCHAR(100), 
   comp_item VARCHAR(100),
   comp_qty_per DECIMAL(18,10),
   ExtendedQuantityPer DECIMAL(18,10),
   primary_uom_code  VARCHAR(50),
   BOMLevel INT NULL,
   item_seq SMALLINT,
   opseq SMALLINT,
   unit_id INT NULL,
   layer_id INT NULL,
   count_per_uom INT,
   alternate_designator  NVARCHAR(10),
   FinishedGoodOpSeq SMALLINT, 
   INDEX IX1 NONCLUSTERED(item_number, comp_item)

)
AS
BEGIN
      -- add current level
   INSERT INTO @BOM
   SELECT G.item_number, G.item_number, comp_item, comp_qty_per, 
    CASE WHEN G.basis_type = 'LOT' THEN comp_qty_per / Lot_Size ELSE comp_qty_per END
   ,primary_uom_code,1, item_seq, opseq, unit_id, layer_id,
	    COALESCE(count_per_uom,'1'),alternate_bom_designator, G.opseq
   FROM dbo.Oracle_BOMs G INNER JOIN dbo.Oracle_Items K ON G.item_number = K.item_number  
   WHERE G.item_number = @FinishedGood AND ( GETDATE() <= disable_date OR disable_date IS NULL)

    --explode downward
   INSERT INTO @BOM
   SELECT c.FinishedGood, n.item_number, n.comp_item, n.comp_qty_per
        , n.ExtendedQuantityPer * c.comp_qty_per,n.primary_uom_code,  
		n.BOMLevel+1, n.item_seq, n.opseq,n.unit_id,n.layer_id,
		 COALESCE(N.count_per_uom,'1'),c.alternate_designator,c.opseq
   FROM @BOM c
   CROSS APPLY dbo.[fn_ExplodeBOM](c.comp_item) n
   RETURN
END



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
PRINT N'Refreshing [Setup].[vRoutesUnion]'
GO
EXEC sp_refreshview N'[Setup].[vRoutesUnion]'
GO
PRINT N'Altering [Setup].[vBomUnion]'
GO
/*
Author:		Bryan Eddy
Date:		2/5/2018
Desc:		Union of both BOMs (DJ and Std) 
Version:	1
Update:		Initial creation
*/

ALTER VIEW [Setup].[vBomUnion]
AS 

SELECT item_number, comp_item, comp_qty_per, opseq, alternate_bom_designator, count_per_uom, '1' AS wip_entity_name, item_seq
FROM dbo.Oracle_BOMs


UNION

SELECT assembly_item, component_item, quantity_issued ,operation_seq_num,'Primary', count_per_uom, wip_entity_name, NULL
FROM dbo.Oracle_DJ_BOM
GO
PRINT N'Creating [Scheduling].[vMissingMaterialDemand]'
GO

/*
Author:		Bryan Eddy
Desc:		View to show items with materials not assigned to an operation passing to the APS system
Date:		5/16/2018
Version:	1
Update:		n/a
*/

CREATE VIEW [Scheduling].[vMissingMaterialDemand]
AS


WITH cteRoutes
AS(
	SELECT *
	FROM Setup.vRoutesUnion
	WHERE pass_to_aps <> 'N'
)
SELECT B.item_number,B.comp_item, CAST(B.item_seq AS INT) item_seq,CAST(B.opseq AS INT) AS Bom_Op_Seq, R.operation_seq_num AS Route_Op_Seq, I.inventory_item_status_code, B.wip_entity_name
FROM Setup.vBomUnion B LEFT JOIN cteRoutes R ON R.item_number = B.item_number AND B.opseq = R.operation_seq_num AND B.alternate_bom_designator = R.alternate_routing_designator
	AND R.wip_entity_name = B.wip_entity_name
	INNER JOIN dbo.Oracle_Items I ON B.item_number = I.item_number
WHERE R.item_number IS NULL AND B.comp_qty_per <> 0 AND I.inventory_item_status_code NOT IN ('obsolete','cab review')
--ORDER BY I.inventory_item_status_code
GO
PRINT N'Altering [Setup].[vExclusionItemList]'
GO











/*
Author:			Bryan Eddy
Date:			12/17/2017
Description:	An exclusion list for PlanetTogether to prevent orders from erroring out during import/refresh
Version:		6
Update:			Update exclusion list to included items in the missing material demand report and where those items are used

*/

ALTER VIEW	[Setup].[vExclusionItemList]
AS
	
WITH cteExcludedItems
AS(
	SELECT DISTINCT AssemblyItemNumber AS ItemNumber--, G.Setup
	FROM Setup.vMissingSetups G CROSS APPLY setup.fn_WhereUsed(item) K
	UNION 
	SELECT  Item AS ItemNumber--, cteSetupLocation.Setup
	FROM Setup.vMissingSetups
	UNION	
	SELECT G.item_number--,NULL
	FROM dbo.APS_ProductClass_ToExclude_HardCoded K INNER JOIN dbo.Oracle_Items G ON G.product_class = K.ExcludedProductClass
	UNION 
	SELECT DISTINCT E.AssemblyItemNumber
	FROM Scheduling.vMissingMaterialDemand CROSS APPLY Setup.fn_WhereUsedStdAndDJ(item_number) E
	UNION
	SELECT DISTINCT item_number
	FROM Scheduling.vMissingMaterialDemand 
)
SELECT k.ItemNumber, I.inventory_item_status_code, I.product_class
FROM cteExcludedItems k LEFT JOIN dbo.Oracle_Items I ON I.item_number = K.ItemNumber


GO
PRINT N'Refreshing [Setup].[vExcludedOrdersDetail]'
GO
EXEC sp_refreshview N'[Setup].[vExcludedOrdersDetail]'
GO
PRINT N'Refreshing [Setup].[vExcludedOrders]'
GO
EXEC sp_refreshview N'[Setup].[vExcludedOrders]'
GO
PRINT N'Altering [Scheduling].[usp_MasterDailyProcedureRun]'
GO





-- =============================================
-- Author:		Bryan Eddy
-- Create date: 10/6/2017
-- Description:	Run all major operations for setup and item attributes
-- Version: 2	
-- Update: Added MES attribute procedure to the master run
-- =============================================
ALTER PROCEDURE [Scheduling].[usp_MasterDailyProcedureRun]
AS

	SET NOCOUNT ON;
BEGIN
	
	EXEC dbo.usp_NormalizeRouting

	EXEC dbo.usp_NormalizeRouting_DJ

	EXEC [Setup].[usp_LoadFromToMatrix]

	EXEC [Setup].[usp_GetItemAttributeData]

	EXEC [Setup].[usp_CalculateSetupTimes]

	EXEC Scheduling.usp_GetNewSubinventory

	EXEC Scheduling.usp_MachineCapabilitySchedulerUpdate

	EXEC [Setup].[usp_GetFiberCountByOperation] @RunType = 2

	EXEC mes.usp_GetItemAttributes

END



GO
PRINT N'Altering [Scheduling].[usp_EmailSchedulingMissingLineSpeed]'
GO



-- =============================================
-- Author:		Bryan Eddy
-- ALTER date: 6/12/17
-- Description:	Send email of missing line speeds to Process Engineers
-- Version:		10
-- Update:		Added logic to produce only a single missing setup for each record
-- =============================================
ALTER PROC [Scheduling].[usp_EmailSchedulingMissingLineSpeed]

AS



SET NOCOUNT ON;


/*******************************************************************
First query is to determine what setups are either not present in the setup database or
what setups are shutoff in the setup db that is in active items.
All setups in query following are in activec items.
*********************************************************************
**********************************************************************/


/*******************************************************************
Query is to determine what items have no run speed in the setup db.
*********************************************************************
**********************************************************************/

	
	IF OBJECT_ID(N'tempdb..#SetupLocation', N'U') IS NOT NULL
	DROP TABLE #SetupLocation;
	WITH cteMissingSetups
	AS(
		--SELECT DISTINCT K.AssemblyItemNumber AS Item,K.Component AS Component, G.Setup, G.department_code,G.alternate_routing_designator
		--FROM Setup.vMissingSetups G CROSS APPLY setup.fn_WhereUsed(item) K
		--UNION 
		SELECT  Item ,Item AS Component, Setup, department_code, alternate_routing_designator
		FROM Setup.vMissingSetups
	)
	SELECT *
	INTO #SetupLocation 
	FROM cteMissingSetups
    


/*******************************************************************
Determine what items and sub-items are located in open orders.
*********************************************************************
**********************************************************************/


	
	IF OBJECT_ID(N'tempdb..#OpenOrders', N'U') IS NOT NULL
	DROP TABLE #OpenOrders;
	WITH cteOrders
	AS(
		SELECT DISTINCT [Item Number] ItemNumber, [Item Description] ItemDesc,[Schedule Date] need_by_date, [Sales Order] SalesOrder, [Line No] SalesOrderLineNumber
		FROM [NAASPB-PRD04\SQL2014].Premise.dbo.AFLPRD_ORDDTLREPT_UPLOAD_CAB
		UNION
		SELECT DISTINCT assembly_item, i.item_description, need_by_date, order_number, line_number
		FROM Scheduling.vOracleOrders INNER JOIN dbo.Oracle_Items i ON i.item_number = assembly_item
	)
	SELECT *
	INTO #OpenOrders
	FROM cteOrders



--Check if any open item requests need commercial approval
IF OBJECT_ID(N'tempdb..#Results', N'U') IS NOT NULL
DROP TABLE #Results;
;WITH cteMissingSetupOrders
as(	
	SELECT DISTINCT FinishedGood,K.Item,i.ItemDesc, need_by_date, B.item_number, Setup, Make_Buy, alternate_routing_designator AS PrimaryAlt
	, K.department_code, i.SalesOrder,SalesOrderLineNumber
	, MIN(need_by_date) OVER (PARTITION BY Setup) Max_SechuduleDate--, ROW_NUMBER() OVER (PARTITION BY Setup ORDER BY setup,G.FinishedGood) RowNumber
	FROM #OpenOrders i CROSS APPLY fn_ExplodeBOM(i.ItemNumber) G
	INNER JOIN #SetupLocation K ON g.item_number = K.Item
	INNER JOIN dbo.Oracle_Items B ON B.item_number = K.ITEM 
	WHERE B.Make_Buy = 'MAKE'  and left(ITEM,3) NOT in ('WTC','DNT')
	and LEFT(setup,1) not in ('O','I') and setup not in ('R696','R093','PQC','pk01','SK01') AND setup NOT LIKE 'm00[4-9]'
	AND K.department_code NOT LIKE '%INSPEC%'
	) 
	,cteConsolidatedMissingSetupOrders
	AS(
		SELECT *, COUNT(SalesOrder) OVER (PARTITION BY cteMissingSetupOrders.Setup) SoLinesMissingSetups--Determine the amount of sales order affected by missing setups
		FROM cteMissingSetupOrders
		--WHERE	
	)
	,cteMaxItem
AS(
	SELECT DISTINCT FinishedGood,ItemDesc, CAST(need_by_date AS DATE) need_by_date, Setup, PrimaryAlt,department_code, SoLinesMissingSetups
	, MAX(ITEM) OVER (PARTITION BY setup) MaxItem, e.Item
	FROM cteConsolidatedMissingSetupOrders e
	WHERE Max_SechuduleDate = need_by_date
)
SELECT DISTINCT FinishedGood,Item,ItemDesc, need_by_date, Setup, PrimaryAlt,department_code, SoLinesMissingSetups
INTO #Results
FROM cteMaxItem
WHERE cteMaxItem.MaxItem = Item

--SELECT *
--FROM #Results


--Add new missing setups
INSERT INTO setup.MissingSetups(Setup)
SELECT DISTINCT G.Setup
FROM #Results G LEFT JOIN setup.MissingSetups K ON K.Setup = G.Setup
WHERE K.Setup IS NULL

--Update existing records with the most recent date of the apperance
UPDATE K
SET K.DateMostRecentAppearance = GETDATE()
FROM setup.MissingSetups K INNER JOIN	#Results J ON K.Setup = J.Setup

--Results to populate the email table
IF OBJECT_ID(N'tempdb..#FinalResults', N'U') IS NOT NULL
DROP TABLE #FinalResults;
SELECT J.*,DATEDIFF(dd,K.DateCreated,K.DateMostRecentAppearance) DaysMissing--, ROW_NUMBER() OVER (PARTITION BY J.Setup, J.need_by_date
INTO #FinalResults
FROM setup.MissingSetups K INNER JOIN	#Results J ON K.Setup = J.Setup
ORDER BY DaysMissing DESC

--SELECT *
--FROM #FinalResults

DECLARE @numRows int
DECLARE @Receipientlist varchar(1000)
DECLARE @BlindRecipientlist varchar(1000)

SELECT @numRows = count(*) FROM #Results;


SET @ReceipientList = (STUFF((SELECT ';' + UserEmail 
						FROM [NAASPB-PRD04\SQL2014].premise.dbo.tblConfiguratorUser G  INNER JOIN [NAASPB-PRD04\SQL2014].premise.users.UserResponsibility  K ON  G.UserID = K.UserID
  						WHERE K.ResponsibilityID = 1 FOR XML PATH('')),1,1,''))

SET @ReceipientList = @ReceipientList +';'+ (STUFF((SELECT ';' + UserEmail 
						FROM [NAASPB-PRD04\SQL2014].premise.dbo.tblConfiguratorUser G  INNER JOIN [NAASPB-PRD04\SQL2014].Premise.users.UserResponsibility  K ON  G.UserID = K.UserID
  						WHERE K.ResponsibilityID = 4 FOR XML PATH('')),1,1,''))

SET @BlindRecipientlist = 'Bryan.Eddy@aflglobal.com';


DECLARE @body1 VARCHAR(MAX)
DECLARE @subject VARCHAR(MAX)
DECLARE @query VARCHAR(MAX) = N'SELECT * FROM tempdb..#Results;'
SET @subject = 'Missing Setup Line Speeds for Open Orders ' + CAST(GETDATE() AS NVARCHAR)
SET @body1 = 'There are  ' + CAST(@numRows AS NVARCHAR) + ' items that are missing setup line speeds with open orders.  Please review.' +CHAR(13)+CHAR(13)

DECLARE @tableHTML  NVARCHAR(MAX) ;
IF @numRows > 0
BEGIN
	
			SET @tableHTML =
				N'<H1>Missing Setup Line Speed Report</H1>' +
				N'<H2 span style=''font-size:16.0pt;font-family:"Calibri","sans-serif";color:#EB3814''>Items with the setups below will be unable to schedule.</H2>' +
				--N'<H2 style = ''color: EB3814''>' +
				N'<p>'+@body1+'</p>' +
				N'<p class=MsoNormal><span style=''font-size:11.0pt;font-family:"Calibri","sans-serif";color:#1F497D''>'+
				N'<table border="1">' +
				N'<tr>' +
				'<th>Days Missing</th><th># Affected SO Lines</th>' +
				'<th>FinishedGood</th><th>Item</th>' +
				N'<th>ItemDesc</th><th>Need By Date</th>' +
				N'<th>Setup</th><th>Atlernate</th><th>DepartmentCode</th>'+
				'</tr>' +
				CAST ( ( SELECT		td=DaysMissing, '',
									td=SoLinesMissingSetups, '',
									td=FinishedGood,    '',
									td=Item, '',
									td=ItemDesc, '', 
									td=need_by_date, '',
									td=Setup, '', 
									td=PrimaryAlt, '',
									td=department_code
									
							FROM #FinalResults 
							ORDER BY need_by_date
						  FOR XML PATH('tr'), TYPE 
				) AS NVARCHAR(MAX) ) +
				N'</table>' ;

		
			EXEC msdb.dbo.sp_send_dbmail 
			@recipients=@ReceipientList,
			--@recipients = 'bryan.eddy@aflglobal.com;',
			@blind_copy_recipients =  @BlindRecipientlist, --@ReceipientList
			@subject = @subject,
			@body = @tableHTML,
			@body_format = 'HTML';
END


GO
PRINT N'Altering [Scheduling].[usp_QueryToHtmlTable]'
GO
-- Description: Turns a query into a formatted HTML table. Useful for emails. 
-- Any ORDER BY clause needs to be passed in the separate ORDER BY parameter.
-- =============================================
ALTER PROC [Scheduling].[usp_QueryToHtmlTable] 
(
  @query NVARCHAR(MAX), --A query to turn into HTML format. It should not include an ORDER BY clause.
  @orderBy NVARCHAR(MAX) = NULL, --An optional ORDER BY clause. It should contain the words 'ORDER BY'.
  @html NVARCHAR(MAX) = NULL OUTPUT--, --The HTML output of the procedure.
  --@RecordCount INT OUTPUT
)
AS
BEGIN   
  SET NOCOUNT ON;

  IF @orderBy IS NULL BEGIN
    SET @orderBy = ''  
  END

  SET @orderBy = REPLACE(@orderBy, '''', '''''');

  DECLARE @realQuery NVARCHAR(MAX) = '
    DECLARE @headerRow nvarchar(MAX);
    DECLARE @cols nvarchar(MAX);    

    SELECT * INTO #dynSql FROM (' + @query + ') sub;

    SELECT @cols = COALESCE(@cols + '', '''''''', '', '''') + ''['' + name + ''] AS ''''td''''''
    FROM tempdb.sys.columns 
    WHERE object_id = object_id(''tempdb..#dynSql'')
    ORDER BY column_id;

    SET @cols = ''SET @html = CAST(( SELECT '' + @cols + '' FROM #dynSql ' + @orderBy + ' FOR XML PATH(''''tr''''), ELEMENTS XSINIL) AS nvarchar(max))''    

    EXEC sys.sp_executesql @cols, N''@html nvarchar(MAX) OUTPUT'', @html=@html OUTPUT

    SELECT @headerRow = COALESCE(@headerRow + '''', '''') + ''<th>'' + name + ''</th>'' 
    FROM tempdb.sys.columns 
    WHERE object_id = object_id(''tempdb..#dynSql'')
    ORDER BY column_id;

    SET @headerRow = ''<tr>'' + @headerRow + ''</tr>'';

    SET @html = ''<table border="1">'' + @headerRow + @html + ''</table>'';    
    ';

  EXEC sys.sp_executesql @realQuery, N'@html nvarchar(MAX) OUTPUT', @html=@html OUTPUT--, @RecordCount = @@ROWCOUNT
END 
GO
PRINT N'Creating [Scheduling].[EmailAlertMissingMaterialDemand]'
GO
/*
Author:		Bryan Eddy
Date:		5/25/2018
Desc:		Email alert to show missing material demand due to material not referencing correct op sequence
Version:	1
Update:		n/a
*/

CREATE PROCEDURE [Scheduling].[EmailAlertMissingMaterialDemand]
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
       inventory_item_status_code,
       wip_entity_name
		FROM [Scheduling].[vMissingMaterialDemand]'

	EXEC sp_executesql @qry
	IF @@ROWCOUNT > 0 
		BEGIN

		SET @body1 = N'<H1>Missing Material Demand Report</H1>' +
				N'<H2 span style=''font-size:16.0pt;font-family:"Calibri","sans-serif";color:#EB3814''>Materials are not assigned to an operation passing into the APS system.</H2>' 
	

			SET @SubjectLine = 'Missing Material Demand' + CAST(GETDATE() AS NVARCHAR(50))
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

	EXEC Scheduling.EmailAlertMissingMaterialDemand

END
GO
PRINT N'Altering [dbo].[_report_3e_mrg_nonfiber]'
GO
ALTER TABLE [dbo].[_report_3e_mrg_nonfiber] ALTER COLUMN [last_update_date] [datetime] NOT NULL
GO
ALTER TABLE [dbo].[_report_3e_mrg_nonfiber] ALTER COLUMN [StartDate] [date] NULL
GO
ALTER TABLE [dbo].[_report_3e_mrg_nonfiber] ALTER COLUMN [OrderLine] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[_report_3e_mrg_nonfiber] ALTER COLUMN [SchedDate] [date] NULL
GO
ALTER TABLE [dbo].[_report_3e_mrg_nonfiber] ALTER COLUMN [PromDate] [date] NULL
GO
ALTER TABLE [dbo].[_report_3e_mrg_nonfiber] ALTER COLUMN [Final_Assembly] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[_report_3e_mrg_nonfiber] ALTER COLUMN [ScheduleApproved] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[_report_3e_mrg_nonfiber] ALTER COLUMN [Item] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[_report_3e_mrg_nonfiber] ALTER COLUMN [CustomerName] [varchar] (360) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[_report_3e_mrg_nonfiber] ALTER COLUMN [Department] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[_report_3e_mrg_nonfiber] ALTER COLUMN [OpID] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[_report_3e_mrg_nonfiber] ALTER COLUMN [Scheduler] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[_report_3e_mrg_nonfiber] ALTER COLUMN [OffsetWeekStart] [date] NULL
GO
ALTER TABLE [dbo].[_report_3e_mrg_nonfiber] ALTER COLUMN [OffsetMonthYear] [nvarchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[_report_3e_mrg_nonfiber] ALTER COLUMN [DJ] [varchar] (240) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[_report_3e_mrg_nonfiber] ALTER COLUMN [DJ_Status] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[_report_3e_mrg_nonfiber] ALTER COLUMN [ComponentUOM] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[_report_3e_mrg_nonfiber] ALTER COLUMN [UOM] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[_report_3e_mrg_nonfiber] ALTER COLUMN [JobID] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[_report_3e_mrg_nonfiber] ALTER COLUMN [ReportSource] [int] NULL
GO
PRINT N'Refreshing [Scheduling].[vWireDemandShopFloorStatus]'
GO
EXEC sp_refreshview N'[Scheduling].[vWireDemandShopFloorStatus]'
GO
PRINT N'Creating [Scheduling].[usp_EmailMfgHoldAlert]'
GO
/*
Author:		Bryan Eddy
Date:		5/16/2018
Desc:		Alert for items with mfg hold that are <= 21 days from promised date
Version:	1
Update:		n/a

*/

CREATE PROCEDURE [Scheduling].[usp_EmailMfgHoldAlert]
AS
BEGIN
	DECLARE @html nvarchar(MAX),
	@SubjectLine NVARCHAR(1000),
	@ReceipientList NVARCHAR(1000)

		SET @ReceipientList = (STUFF((SELECT ';' + UserEmail 
							FROM [NAASPB-PRD04\SQL2014].Premise.dbo.tblConfiguratorUser G  INNER JOIN [NAASPB-PRD04\SQL2014].Premise.users.UserResponsibility  K ON  G.UserID = K.UserID
	  						WHERE K.ResponsibilityID = 19 FOR XML PATH('')),1,1,''))



	SET @SubjectLine = 'MFG Hold Alert ' + CAST(GETDATE() AS NVARCHAR(50))
	EXEC Scheduling.usp_QueryToHtmlTable @html = @html OUTPUT,  
	@query = N'SELECT order_number, conc_order_number, CAST(promise_date as DATE) promise_date, CAST(need_by_date AS DATE) need_by_date, has_mfg_hold, assembly_item, 
	customer_name, scheduler, CAST(pri_uom_order_qty AS INT) pri_uom_order_qty FROM Scheduling.vAlertMfgHold', @orderBy = N'ORDER BY order_number';


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
GO
PRINT N'Refreshing [Setup].[vExcludedOrdersAll]'
GO
EXEC sp_refreshview N'[Setup].[vExcludedOrdersAll]'
GO
PRINT N'Refreshing [Scheduling].[vOrdersWithMaterialsNotOrderedInNineMonths]'
GO
EXEC sp_refreshview N'[Scheduling].[vOrdersWithMaterialsNotOrderedInNineMonths]'
GO
PRINT N'Refreshing [Scheduling].[vAlertShortShip]'
GO
EXEC sp_refreshview N'[Scheduling].[vAlertShortShip]'
GO
PRINT N'Refreshing [Scheduling].[vAlertMfgHold]'
GO
EXEC sp_refreshview N'[Scheduling].[vAlertMfgHold]'
GO
PRINT N'Altering [dbo].[_report_3f_mrg_fiber]'
GO
ALTER TABLE [dbo].[_report_3f_mrg_fiber] ALTER COLUMN [last_update_date] [datetime] NOT NULL
GO
ALTER TABLE [dbo].[_report_3f_mrg_fiber] ALTER COLUMN [StartDate] [date] NULL
GO
ALTER TABLE [dbo].[_report_3f_mrg_fiber] ALTER COLUMN [OrderLine] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[_report_3f_mrg_fiber] ALTER COLUMN [SchedDate] [date] NULL
GO
ALTER TABLE [dbo].[_report_3f_mrg_fiber] ALTER COLUMN [PromDate] [date] NULL
GO
ALTER TABLE [dbo].[_report_3f_mrg_fiber] ALTER COLUMN [Final_Assembly] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[_report_3f_mrg_fiber] ALTER COLUMN [ScheduleApproved] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[_report_3f_mrg_fiber] ALTER COLUMN [FiberItem] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[_report_3f_mrg_fiber] ALTER COLUMN [CustomerName] [varchar] (360) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[_report_3f_mrg_fiber] ALTER COLUMN [Department] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[_report_3f_mrg_fiber] ALTER COLUMN [Scheduler] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[_report_3f_mrg_fiber] ALTER COLUMN [OffsetWeekStart] [date] NULL
GO
ALTER TABLE [dbo].[_report_3f_mrg_fiber] ALTER COLUMN [OffsetMonthYear] [nvarchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[_report_3f_mrg_fiber] ALTER COLUMN [ComponentUOM] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[_report_3f_mrg_fiber] ALTER COLUMN [UOM] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[_report_3f_mrg_fiber] ALTER COLUMN [JobID] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[_report_3f_mrg_fiber] ALTER COLUMN [ReportSource] [int] NULL
GO
PRINT N'Creating index [IX_OracleDjBom] on [dbo].[Oracle_DJ_BOM]'
GO
CREATE NONCLUSTERED INDEX [IX_OracleDjBom] ON [dbo].[Oracle_DJ_BOM] ([assembly_item]) INCLUDE ([component_item], [count_per_uom], [operation_seq_num], [quantity_issued], [wip_entity_name]) ON [PRIMARY]
GO
PRINT N'Creating index [IX_Oracle_Orders] on [dbo].[Oracle_Orders]'
GO
CREATE NONCLUSTERED INDEX [IX_Oracle_Orders] ON [dbo].[Oracle_Orders] ([assembly_item]) ON [PRIMARY]
GO
PRINT N'Altering permissions on  [dbo].[Oracle_USAC_PO_SO]'
GO
GRANT INSERT ON  [dbo].[Oracle_USAC_PO_SO] TO [NAA\SPB_Scheduling_RO]
GO
GRANT UPDATE ON  [dbo].[Oracle_USAC_PO_SO] TO [NAA\SPB_Scheduling_RO]
GO

