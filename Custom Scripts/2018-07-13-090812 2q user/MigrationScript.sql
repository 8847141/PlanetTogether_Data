/*
This migration script replaces uncommitted changes made to these objects:
AttributeMatrixFromTo
_mst_push
_report_4a_production_master_schedule
_report_9b_capacity
_report_9d_fiberset_lengths
usp_GetItemAttributes
usp_EmailAlertMissingMaterialDemandDj
usp_EmailAlertMissingMaterialDemand
usp_EmailMfgHoldAlert
usp_EmailOrdersStaleMaterials
usp_EmailSchedulePublishNotification
usp_EmailSchedulerMachineCapabilityIssue
usp_EmailSchedulingMissingLineSpeed
usp_CreateBufferingMatrix
usp_CreateSheathingMatrix
usp_EmailMissingDjSetup
usp_EmailOracleTableRecordCount
vProductionSchedule
vInterfaceSetupAttributes
Mes
Job

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
PRINT N'Altering [Setup].[vInterfaceSetupAttributes]'
GO
/*Interface view of needed information from the Recipe Management Syste / PSS DB*/
ALTER VIEW [Setup].[vInterfaceSetupAttributes]
AS
SELECT        Setup.tblProcessMachines.ProcessID,
                         Setup.tblAttributes.AttributeID, Setup.tblAttributes.AttributeDesc, Setup.tblAttributes.AttributeName, Setup.tblSetup.SetupID, Setup.tblSetup.SetupNumber, 
                         Setup.tblSetupAttributes.AttributeValue, Setup.tblSetupAttributes.MachineSpecific, Setup.tblSetupAttributes.MinValue, Setup.tblAttributes.Active, 
                         Setup.tblSetupAttributes.EffectiveDate, Setup.tblAttributes.AttrEffectiveDate, Setup.tblAttributes.AttributeGroupID, Setup.tblSetup.IneffectiveDate, 
                         Setup.tblAttributes.AttributeUOM, Setup.tblAttributes.AttrIneffectiveDate AS AttributeIneffectiveDate, 
                         Setup.tblSetupAttributes.IneffectiveDate AS SetupAttributesIneffectiveDate, Setup.tblProcessMachines.MachineNumber, tblProcessMachines.MachineID AS PssMachineID
						 ,tblProcessMachines.ProcessID AS PssProcessID, AttributeViewOrder, AttributeDataType,SigDigits, DefaultMinTol, DefaultMaxTol
FROM            Setup.tblAttributes INNER JOIN
                         Setup.tblSetupAttributes ON Setup.tblAttributes.AttributeID = Setup.tblSetupAttributes.AttributeID INNER JOIN
                         Setup.tblSetup ON Setup.tblSetupAttributes.SetupID = Setup.tblSetup.SetupID AND Setup.tblSetupAttributes.MachineID = Setup.tblSetup.MachineID INNER JOIN
                         Setup.tblProcessMachines ON Setup.tblSetup.MachineID = Setup.tblProcessMachines.MachineID AND 
                         Setup.tblSetup.ProcessID = Setup.tblProcessMachines.ProcessID
						 
WHERE        (Setup.tblAttributes.AttrIneffectiveDate >= GETDATE()) AND (Setup.tblSetup.IneffectiveDate >= GETDATE()) AND (Setup.tblSetupAttributes.IneffectiveDate >= GETDATE()) 
                         AND (Setup.tblProcessMachines.Active <> 0) 
						 









GO
PRINT N'Altering [Setup].[AttributeMatrixFromTo]'
GO
ALTER TABLE [Setup].[AttributeMatrixFromTo] ADD
[RevisedBy] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_AttributeMatrixFromTo_UpdatedBy] DEFAULT (suser_sname()),
[DateRevised] [datetime] NULL CONSTRAINT [DF_AttributeMatrixFromTo_DateRevised] DEFAULT (getdate()),
[GUIID] [uniqueidentifier] NULL CONSTRAINT [DF__Attribute__GUIID__412F7C0D] DEFAULT (newid())
GO
PRINT N'Creating index [IX_AttributeMatrixFromTo] on [Setup].[AttributeMatrixFromTo]'
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_AttributeMatrixFromTo] ON [Setup].[AttributeMatrixFromTo] ([GUIID]) ON [PRIMARY]
GO
PRINT N'Altering [Setup].[usp_CreateSheathingMatrix]'
GO









-- =============================================
-- Author:      Bryan Eddy
-- Create date: 7/31/2017
-- Description: Create all combinations for sheathing compound To From logic
-- Version: 2
-- Update:	Updated color time value logic and added MachineID to sheathing compound logic
-- =============================================
ALTER PROCEDURE [Setup].[usp_CreateSheathingMatrix]
AS
	SET NOCOUNT ON;
BEGIN

DECLARE @ErrorNumber INT = ERROR_NUMBER();
DECLARE @ErrorLine INT = ERROR_LINE();

	BEGIN TRY
		BEGIN TRAN
			--delete from Setup.ToFromAttributeMatrix;
			;WITH cteSheathingJacket
			AS (
			SELECT G.item_number AS FromAttribute, k.item_number AS ToAttribute, MachineID,5 AS AttributeNameID,
			CASE WHEN g.item_number = k.item_number THEN 0
			WHEN G.attribute_value = k.attribute_value THEN 0.33*60
				WHEN G.attribute_value = 'PVC'  THEN 1*60
				WHEN G.attribute_value = 'PVDF'  THEN 3*60
				WHEN G.attribute_value = 'NYLON' THEN 6*60
				WHEN G.attribute_value <> K.attribute_value THEN 2.25*60
				ELSE 99999
				END AS Timevalue
				FROM dbo.Oracle_Item_Attributes K CROSS APPLY dbo.Oracle_Item_Attributes G CROSS APPLY Setup.MachineNames I
				WHERE K.attribute_name = 'Jacket' AND g.attribute_name = 'Jacket'  AND MachineGroupID = 8
			)
			INSERT INTO Setup.AttributeMatrixFromTo(FromAttribute,ToAttribute,  TimeValue, MachineID,AttributeNameID)
			SELECT K.FromAttribute,K.ToAttribute,K.Timevalue,K.MachineID, K.AttributeNameID
			FROM cteSheathingJacket K LEFT JOIN SETUP.AttributeMatrixFromTo G ON K.FromAttribute = G.FromAttribute AND K.ToAttribute = G.ToAttribute AND G.MachineID = K.MachineID
			WHERE G.FromAttribute IS NULL
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION; 
		PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
		PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
		THROW;
	END CATCH;



	--Insert Color Matrix in From To Table
	BEGIN TRY
		BEGIN TRAN
			;WITH cteSheathingColor
			AS(
				SELECT DISTINCT G.attribute_value FromAttribute, k.attribute_value ToAttribute,4 AS AttributeNameID,
					 CASE WHEN FromAtt.PreferedSequence = ToAtt.PreferedSequence THEN 0
							WHEN FromAtt.PreferedSequence > ToAtt.PreferedSequence THEN 60
							WHEN fromAtt.PreferedSequence < ToAtt.PreferedSequence THEN 20 
					 ELSE 99999
					 END AS Timevalue, T.MachineID
				FROM dbo.Oracle_Item_Attributes G CROSS APPLY dbo.Oracle_Item_Attributes K
				LEFT JOIN Setup.ColorSequencePreference ToAtt ON ToAtt.Color = K.attribute_value
				LEFT JOIN Setup.ColorSequencePreference FromAtt ON FromAtt.Color = G.attribute_value
				CROSS APPLY Setup.MachineNames T 
				WHERE G.attribute_name = 'COLOR' AND K.attribute_name = 'COLOR' AND T.MachineGroupID = 8
			)
			INSERT INTO Setup.AttributeMatrixFromTo(FromAttribute,ToAttribute,  TimeValue, MachineID,AttributeNameID)
			SELECT DISTINCT K.FromAttribute,K.ToAttribute,K.Timevalue,K.MachineID,K.AttributeNameID--, k.FromAttribute, k.ToAttribute
			FROM cteSheathingColor K
			LEFT JOIN SETUP.AttributeMatrixFromTo G ON K.FromAttribute = G.FromAttribute AND K.ToAttribute = G.ToAttribute AND g.MachineID = K.MachineID
			WHERE   G.FromAttribute IS NULL 
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION; 
		PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
		PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
		THROW;
	END CATCH;


	--Inserting armor matrix in From To table
	BEGIN TRY
		BEGIN TRAN
			INSERT INTO Setup.AttributeMatrixFromTo(FromAttribute,ToAttribute,  TimeValue, AttributeMatrixFromTo.MachineID,AttributeNameID)
			SELECT  DISTINCT COALESCE(K.FromAttribute,'0') FromAttribute,COALESCE(K.ToAttribute,'0') ToAttribute, K.Timevalue, T.MachineID,1 AttributeNameID
			FROM SETUP.vMatrixSheathingArmor K CROSS APPLY SETUP.MachineNames T
			LEFT JOIN SETUP.AttributeMatrixFromTo G ON K.FromAttribute  = G.FromAttribute AND K.ToAttribute = G.ToAttribute AND T.MachineID = G.MachineID
			WHERE T.MachineGroupID = 8 AND  G.FromAttribute IS NULL AND G.ToAttribute IS NULL AND K.FromAttribute <> 0 AND G.FromAttribute <> 0
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
PRINT N'Rebuilding [dbo].[_report_4a_production_master_schedule]'
GO
CREATE TABLE [dbo].[RG_Recovery_1__report_4a_production_master_schedule]
(
[planned_setup_start] [datetime] NULL,
[planned_setup_end] [datetime] NULL,
[previous_op_machine] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[previous_op_status] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[current_op_machine] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[current_op_status] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[next_op_machine] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dj_number] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sf_group_id] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[job] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[op] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[setup] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customer] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[order_number] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[order_scheduled_end_date] [datetime] NULL,
[oracle_dj_status] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[part_no] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[job_qty] [float] NULL,
[ujcm] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[earliest_material_availability_date] [datetime] NULL,
[need_date] [datetime] NULL,
[promise_date] [datetime] NULL,
[schedule_ship_date] [datetime] NULL,
[scheduled_end_date] [datetime] NULL,
[scheduled_run_hours] [float] NULL,
[scheduled_setup_hours] [float] NULL,
[scheduled_total_hours] [float] NULL,
[late_order] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[remake] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fiberset] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stage] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_update_date] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
INSERT INTO [dbo].[RG_Recovery_1__report_4a_production_master_schedule]([planned_setup_start], [planned_setup_end], [previous_op_machine], [previous_op_status], [current_op_machine], [current_op_status], [next_op_machine], [dj_number], [sf_group_id], [job], [op], [setup], [customer], [order_number], [order_scheduled_end_date], [oracle_dj_status], [part_no], [job_qty], [ujcm], [earliest_material_availability_date], [need_date], [promise_date], [schedule_ship_date], [scheduled_end_date], [scheduled_run_hours], [scheduled_setup_hours], [scheduled_total_hours], [late_order], [remake], [last_update_date]) SELECT [planned_setup_start], [planned_setup_end], [previous_op_machine], [previous_op_status], [current_op_machine], [current_op_status], [next_op_machine], [dj_number], [sf_group_id], [job], [op], [setup], [customer], [order_number], [order_scheduled_end_date], [oracle_dj_status], [part_no], [job_qty], [ujcm], [earliest_material_availability_date], [need_date], [promise_date], [schedule_ship_date], [scheduled_end_date], [scheduled_run_hours], [scheduled_setup_hours], [scheduled_total_hours], [late_order], [remake], [last_update_date] FROM [dbo].[_report_4a_production_master_schedule]
GO
DROP TABLE [dbo].[_report_4a_production_master_schedule]
GO
EXEC sp_rename N'[dbo].[RG_Recovery_1__report_4a_production_master_schedule]', N'_report_4a_production_master_schedule', N'OBJECT'
GO
PRINT N'Refreshing [Scheduling].[vLateOrders]'
GO
EXEC sp_refreshview N'[Scheduling].[vLateOrders]'
GO
PRINT N'Altering [Setup].[usp_CreateBufferingMatrix]'
GO
-- =============================================
-- Author:      Bryan Eddy
-- Create date: 8/22/2017
-- Description: Create all combinations for buffering compound From To logic
-- Version: 1
-- Update:	Added error handling
-- =============================================
ALTER PROC [Setup].[usp_CreateBufferingMatrix]
AS
BEGIN

	SET NOCOUNT ON;

	BEGIN TRY
			BEGIN TRAN
				;WITH
				cteBufferingJacket
				AS(
					SELECT DISTINCT I.MachineName,g.item_number AS FromAttribute, k.item_number AS ToAttribute, 5 AS AttributeNameID, I.MachineID,
					CASE WHEN G.attribute_value = k.attribute_value THEN 0
						WHEN G.attribute_value = 'PBT' AND k.attribute_value IN('HDPE','LSZH','MDPE') THEN 30
						WHEN G.attribute_value = 'MDPE' AND k.attribute_value IN('HDPE','LSZH','PBT','POLYURETHANE','SANTOPRENE') THEN 30
						WHEN G.attribute_value = 'HDPE' AND k.attribute_value IN('HDPE','LSZH','PBT','POLYURETHANE','SANTOPRENE') THEN 120
						WHEN G.attribute_value = 'PVC' THEN 120
						WHEN G.attribute_value IN ('LSZH','PVDF','TRC','TPU','HYTREL','POLYURETHANE','SANTOPRENE','PBT','HDPE','TPX') THEN 240
						WHEN G.attribute_value = 'Nylon'THEN 360
						ELSE 0
						END AS Timevalue
					FROM dbo.Oracle_Item_Attributes K CROSS APPLY dbo.Oracle_Item_Attributes G CROSS APPLY Setup.MachineNames I
					WHERE K.attribute_name = 'Jacket' AND g.attribute_name = 'Jacket'  AND MachineGroupID = 2
				)
				INSERT INTO Setup.AttributeMatrixFromTo(FromAttribute, ToAttribute, TimeValue, MachineID, AttributeNameID)
				SELECT K.FromAttribute, K.ToAttribute, K.Timevalue, k.MachineID, K.AttributeNameID
				FROM cteBufferingJacket K LEFT JOIN SETUP.AttributeMatrixFromTo G ON G.FromAttribute = K.FromAttribute AND G.ToAttribute = G.ToAttribute AND G.MachineID = K.MachineID
				WHERE G.FromAttribute IS NULL OR G.ToAttribute IS NULL
			COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
 
		DECLARE @ErrorNumber INT = ERROR_NUMBER();
		DECLARE @ErrorLine INT = ERROR_LINE();
 
		PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
		PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
		THROW;
	END CATCH

END

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
PRINT N'Altering [Setup].[usp_EmailMissingDjSetup]'
GO






/*
Author:		Bryan Eddy
Date:		2/2/2018
Desc:		Email alert to notify of DJ's with setups missing
Version:	2
Update:		Updated to show all affected DJ's and the op sequence
*/

ALTER PROCEDURE [Setup].[usp_EmailMissingDjSetup]
AS
BEGIN

SET NOCOUNT ON;

	--Get missing setup information
	IF OBJECT_ID(N'tempdb..#Results', N'U') IS NOT NULL
	DROP TABLE #Results;

	WITH cteJobsMissingSetups
	AS(
		SELECT DISTINCT Setup, I.assembly_item,I.wip_entity_name, I.date_released,assembly_description, I.department_code,operation_seq_num
		--,MIN(I.date_released) OVER (PARTITION BY Setup) EarliestReleasedDate
		--,ROW_NUMBER() OVER (PARTITION BY Setup ORDER BY date_released) RowNumber
			--,COUNT(setup) OVER (PARTITION BY Setup) NumberOfJobsAffected
		FROM (
				SELECT DISTINCT Setup, I.assembly_item,I.wip_entity_name, I.date_released  , I.assembly_description, I.department_code, I.operation_seq_num
				FROM	Setup.vMissingSetupsDj K INNER JOIN dbo.Oracle_DJ_Routes  I ON I.true_operation_code = K.Setup 
						INNER JOIN Scheduling.vOracleOrders j ON j.parent_dj_number = i.wip_entity_name
					)  I
	)
	SELECT  G.*
	INTO #Results
	FROM cteJobsMissingSetups G left JOIN Setup.MissingSetups K ON g.Setup = k.Setup
	--WHERE G.EarliestReleasedDate = G.date_released AND G.RowNumber = 1

	--Merge missing setups with the MissingSetups table
	MERGE Setup.MissingSetups AS T
	USING (SELECT DISTINCT Setup FROM #Results) s
	ON t.Setup = S.Setup
	WHEN MATCHED THEN
	UPDATE SET T.DateMostRecentAppearance = GETDATE()
	WHEN NOT MATCHED BY TARGET THEN
	INSERT (SETUP) VALUES (setup);

	--Results to populate the email table
	IF OBJECT_ID(N'tempdb..#FinalResults', N'U') IS NOT NULL
	DROP TABLE #FinalResults;
	SELECT DATEDIFF(dd,K.DateCreated,K.DateMostRecentAppearance) DaysMissing, k.DateCreated, k.DateMostRecentAppearance,CAST(j.operation_seq_num AS INT) operation_seq_num
	,cast(J.date_released AS date) date_released, j.department_code, j.wip_entity_name,j.assembly_item
	,J.Setup
	INTO #FinalResults
	FROM setup.MissingSetups K INNER JOIN	#Results J ON K.Setup = J.Setup
	ORDER BY cast(date_released AS date)--,DaysMissing DESC

	--SELECT *
	--FROM #FinalResults
	--ORDER BY date_released
		
	--Send Email alert
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


	--SET @BlindRecipientlist = @BlindRecipientlist + ';Bryan.Eddy@aflglobal.com';


	DECLARE @body1 VARCHAR(MAX)
	DECLARE @subject VARCHAR(MAX)
	--DECLARE @query VARCHAR(MAX) = N'SELECT * FROM tempdb..#Results;'
	SET @subject = 'Discrete Jobs Missing Setup Alerts ' + CAST(GETDATE() AS NVARCHAR(50))
	SET @body1 = 'There are  ' + CAST(@numRows AS NVARCHAR(20)) + ' item(s) missing setup information for DJs.  Please review.' +CHAR(13)+CHAR(13)

	DECLARE @tableHTML  NVARCHAR(MAX) ;
	IF @numRows > 0
		BEGIN
	
					SET @tableHTML =
						N'<H1>Missing Setup DJ Report</H1>' +
						N'<H2 span style=''font-size:16.0pt;font-family:"Calibri","sans-serif";color:#EB3814''>Items with the setups below will be unable to schedule.</H2>' +
						--N'<H2 style = ''color: EB3814''>' +
						N'<p>'+@body1+'</p>' +
						N'<p class=MsoNormal><span style=''font-size:11.0pt;font-family:"Calibri","sans-serif";color:#1F497D''>'+
						N'<table border="1">' +
						N'<tr><th>Setup</th><th>Days Missing</th>' +
						N'<th>Item</th><th>Op Seq</th>' +
						N'<th>Job</th><th>Job Released Date</th><th>Dept Code</th></tr>' +
						CAST ( ( SELECT		td=Setup,    '',
											td=DaysMissing, '',
											td=assembly_item, '',
											td=operation_seq_num, '',
											td=wip_entity_name, '', 
											td=date_released, '',
											td = department_code, ''
																
									FROM #FinalResults 
									ORDER BY date_released, DaysMissing
									FOR XML PATH('tr'), TYPE 
						) AS NVARCHAR(MAX) ) +
						N'</table>' ;

		
					EXEC msdb.dbo.sp_send_dbmail 
					@recipients=@ReceipientList,
					--@blind_copy_recipients = 'bryan.eddy@aflglobal.com',
					@subject = @subject,
					@body = @tableHTML,
					@body_format = 'HTML';
		END


END
GO
PRINT N'Refreshing [Setup].[vInterfaceMachineCapability]'
GO
EXEC sp_refreshview N'[Setup].[vInterfaceMachineCapability]'
GO
PRINT N'Refreshing [Setup].[vMachineCapability]'
GO
EXEC sp_refreshview N'[Setup].[vMachineCapability]'
GO
PRINT N'Refreshing [Setup].[vRoutesUnion]'
GO
EXEC sp_refreshview N'[Setup].[vRoutesUnion]'
GO
PRINT N'Refreshing [Setup].[vAttributeMatrixUnion]'
GO
EXEC sp_refreshview N'[Setup].[vAttributeMatrixUnion]'
GO
PRINT N'Altering [Scheduling].[usp_EmailAlertMissingMaterialDemandDj]'
GO


/*
Author:		Bryan Eddy
Date:		5/25/2018
Desc:		Email alert to show missing material demand due to material not referencing correct op sequence
Version:	1
Update:		n/a
*/

ALTER PROCEDURE [Scheduling].[usp_EmailAlertMissingMaterialDemandDj]
AS
BEGIN
	DECLARE @html NVARCHAR(MAX),
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
			--@blind_copy_recipients = 'bryan.eddy@aflglobal.com',
			@subject = @SubjectLine,
			@body = @html,
			@body_format = 'HTML',
			@query_no_truncate = 1,
			@attach_query_result_as_file = 0;
		END
END

GO
PRINT N'Altering [Mes].[usp_GetItemAttributes]'
GO




-- =============================================
-- Author:      Bryan Eddy
-- Create date: 4/23/2018
-- Description: Procedure to get the designated attributes values for information in Mes.MachineAttributes
-- Version:		3
-- Update:		Added print attribute
-- =============================================

ALTER PROCEDURE [Mes].[usp_GetItemAttributes]
AS
	SET NOCOUNT ON;
BEGIN

TRUNCATE TABLE mes.ItemSetupAttributes

DECLARE @ErrorNumber INT = ERROR_NUMBER();
DECLARE @ErrorLine INT = ERROR_LINE();


		
	--Insert fixed time values for setup times
	BEGIN TRY
		BEGIN TRAN

		;WITH cteAttributes
		AS(
			SELECT CableColor AS AttrbiuteValue, AttributeName, AttributeNameID, i.DataType, ItemNumber
			FROM Setup.ItemAttributes CROSS APPLY Setup.ApsSetupAttributes k INNER JOIN Setup.AttributeDataType i ON i.DataTypeID = k.DataTypeID
			WHERE AttributeNameID = 4

			UNION

			SELECT CAST(NominalOD AS NVARCHAR(50)) AS AttrbiuteValue, AttributeName, AttributeNameID, i.DataType, ItemNumber
			FROM Setup.ItemAttributes CROSS APPLY Setup.ApsSetupAttributes k INNER JOIN Setup.AttributeDataType i ON i.DataTypeID = k.DataTypeID
			WHERE AttributeNameID = 3

			UNION

			SELECT  CAST(FiberCount AS NVARCHAR(50)) AS AttrbiuteValue, AttributeName, AttributeNameID, i.DataType, ItemNumber
			FROM Setup.ItemAttributes CROSS APPLY Setup.ApsSetupAttributes k INNER JOIN Setup.AttributeDataType i ON i.DataTypeID = k.DataTypeID
			WHERE AttributeNameID = 7

			UNION

			SELECT  CAST(Printed AS NVARCHAR(50)) AS AttrbiuteValue, AttributeName, AttributeNameID, i.DataType, ItemNumber
			FROM Setup.ItemAttributes CROSS APPLY Setup.ApsSetupAttributes k INNER JOIN Setup.AttributeDataType i ON i.DataTypeID = k.DataTypeID
			WHERE AttributeNameID = 37
		)
		INSERT INTO Mes.ItemSetupAttributes([Setup],MachineID,AttributeNameID,Item_Number, AttributeValue)
		SELECT DISTINCT P.Setup, M.MachineID, K.AttributeNameID, I.item_number, K.AttrbiuteValue
		FROM cteAttributes K INNER JOIN Setup.vRoutesUnion I ON K.ItemNumber = I.item_number 
		INNER JOIN Setup.vMachineCapability P ON P.Setup = I.true_operation_code 
		INNER JOIN MES.MachineAttributes M ON M.MachineID = P.MachineID AND K.AttributeNameID = M.AttributeNameID

		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
 
		PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
		PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
		THROW;
	END CATCH;



	BEGIN TRY
		BEGIN TRAN
			INSERT INTO Mes.ItemSetupAttributes([Setup],MachineID,AttributeNameID,Item_Number, AttributeValue)
			SELECT DISTINCT K.SetupNumber, M.MachineID, i.AttributeNameID, r.item_number, K.AttributeValue
			FROM Setup.vInterfaceSetupAttributes K INNER JOIN Setup.ApsSetupAttributeReference i ON i.AttributeID = K.AttributeID
			INNER JOIN Mes.MachineAttributes M ON M.AttributeNameID = i.AttributeNameID
			INNER JOIN Setup.vRoutesUnion r ON r.true_operation_code = K.SetupNumber
			INNER JOIN Setup.MachineReference MR ON MR.PssMachineID = K.PssMachineID AND MR.MachineID = M.MachineID AND MR.PssProcessID = K.PssProcessID
			LEFT JOIN Mes.ItemSetupAttributes Mes ON Mes.AttributeNameID = i.AttributeNameID 
				AND Mes.MachineID = M.MachineID AND Mes.Item_Number = r.item_number AND K.SetupNumber = Mes.Setup
			WHERE mes.Item_Number IS NULL 
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
PRINT N'Altering [Scheduling].[usp_EmailSchedulerMachineCapabilityIssue]'
GO





-- =============================================
-- Author:		Bryan Edy
-- Create date: 10/31/2017
-- Description:	Email notification to scheduling when an item is set to pass by scheduler but is inactive in the Setup data
-- Version:		2
-- Update Reason: Removed query and created Scheduling.vSchedulerMachineCapabilityIssue view for procedure to pull data from
-- =============================================
ALTER PROCEDURE [Scheduling].[usp_EmailSchedulerMachineCapabilityIssue] 
AS
BEGIN

	BEGIN TRY
		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		SET NOCOUNT ON;

	DECLARE @numRows int
	DECLARE @Receipientlist varchar(1000)

	/*Chec what can schedule against active setups being passed over.  If a setup is being passed as active, but doesn't show up on any machine 
	then this procedure will notify the scheduler*/


	IF OBJECT_ID(N'tempdb..#Results', N'U') IS NOT NULL
	DROP TABLE #Results;
	SELECT *
	INTO #Results
	FROM Scheduling.vSchedulerMachineCapabilityIssue

	--SELECT *FROM #Results

	SELECT @numRows = COUNT(*) FROM #Results

	--SET @ReceipientList = (STUFF((SELECT ';' + UserEmail 
	--						FROM tblConfiguratorUser G  INNER JOIN users.UserResponsibility  K ON  G.UserID = K.UserID
	--  						WHERE K.ResponsibilityID = 5 FOR XML PATH('')),1,1,''))
	--						--WHERE g.UserTypeID = 1 FOR XML PATH('')),1,1,''))

	DECLARE @body1 VARCHAR(MAX)
	DECLARE @subject VARCHAR(MAX)
	DECLARE @query VARCHAR(MAX) = N'SELECT * FROM tempdb..#Results;'
	SET @subject = 'Inactive Setups' 
	SET @body1 = 'There are  ' + CAST(@numRows AS NVARCHAR) + ' setup(s) active from Setup System that are not scheduling due to Scheduling Active flag.' +CHAR(13)+CHAR(13)

	DECLARE @tableHTML  NVARCHAR(MAX) ;
	IF @numRows > 0

		BEGIN
	
					SET @tableHTML =
						N'<H1>Inactive setups with active scheduling capability.</H1>' +
						N'<p>'+@body1+'</p>' +
						N'<p class=MsoNormal><span style=''font-size:11.0pt;font-family:"Calibri","sans-serif";color:#1F497D''>'+
						N'<table border="1">' +
						N'<tr><th>Setup</th><th>MachineID</th><th>Machine</th>' +
						N'<th>Active Setup</th><th>Active Scheduling</th>'+
						N'<th>Altered By</th><th>Date Altered</th>'+
						'</tr>' +
						CAST ( ( SELECT		td=Setup,       '',
											td=MachineID, '',
											td=MachineName, '',
											td=ActiveSetup, '',
											td=ActiveScheduling, '',
											td=ActiveStatusChangedBy, '',
											td=ActiveStatusChangedDate,''
									FROM #Results 
								  FOR XML PATH('tr'), TYPE 
						) AS NVARCHAR(MAX) ) +
						N'</table>' ;
					--SET @tableHTML =
					--	N'<H1>Premise Cut Sheet Approval</H1>' +
					--	N'<p>'+@body1+'</p>' +
					--	N'</table>' ;
		
					EXEC msdb.dbo.sp_send_dbmail 
					@recipients='Jeff.Gilfillan@aflglobal.com; Rich.DiDonato@aflglobal.com',
					--@recipients='Bryan.Eddy@aflglobal.com',
					--@blind_copy_recipients = 'Bryan.Eddy@aflglobal.com',
					@subject = @subject,
					@body = @tableHTML,
					@body_format = 'HTML';



		END
	END TRY
	BEGIN CATCH
 
		DECLARE @ErrorNumber INT = ERROR_NUMBER();
		DECLARE @ErrorLine INT = ERROR_LINE();
 
		PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
		PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
		THROW;
	END CATCH
END


GO
PRINT N'Altering [Scheduling].[vProductionSchedule]'
GO
/*
Author:		Bryan Eddy
Date:		3/14/2018
Desc:		View for SSRS reporting
Version:	2
Update:		Add stage and fiberset to the view
Note:		OD first uses OD from Setup information else it uses OD from item.  Item OD and setup OD are not the same.  
			This will not be accurate for all items, just tubes, and sheathing.  Not cabling.
			Color does not apply to sheathing
*/

ALTER VIEW [Scheduling].[vProductionSchedule]
AS
SELECT R.planned_setup_start,
       R.planned_setup_end,
       R.previous_op_machine,
       R.previous_op_status,
       R.current_op_machine,
       R.current_op_status,
       R.next_op_machine,
       R.dj_number,
       R.sf_group_id,
       R.job,
       R.op,
       R.setup,
       R.customer,
       R.order_number,
       R.order_scheduled_end_date,
       R.oracle_dj_status,
       R.part_no,
       R.job_qty,
       R.ujcm,
       R.earliest_material_availability_date,
       R.need_date,
       R.promise_date,
       R.schedule_ship_date,
       R.scheduled_end_date,
       R.scheduled_run_hours,
       R.scheduled_setup_hours,
       R.scheduled_total_hours,
       R.late_order,
       R.remake,
       R.last_update_date, m.Plant, M.Department, M.DepartmentID, COALESCE(I.NominalOD, A.NominalOD) AS NominalOD
, I.NumberCorePositions, i.UJCM UpJacketCM, I.JacketMaterial, I.EndsOfAramid,r.fiberset, r.stage
, CASE WHEN R.promise_date < GETDATE() THEN ROUND(CAST(DATEDIFF(MINUTE,R.promise_date, R.planned_setup_start) AS FLOAT)/60/24,3) END AS PromiseLatenessDays 
, A.FiberCount, CASE WHEN M.DepartmentID = 5 AND A.Printed = 1 THEN A.CableColor + ' ----' ELSE A.CableColor END AS CableColor, A.Printed
FROM Setup.vMachineNames M RIGHT JOIN dbo._report_4a_production_master_schedule R ON r.current_op_machine = m.MachineName
LEFT JOIN Setup.ItemAttributes A ON A.ItemNumber = R.part_no
LEFT JOIN SETUP.ItemSetupAttributes I ON I.Setup = R.setup AND I.ItemNumber = R.part_no
WHERE R.planned_setup_start < GETDATE() + 60 
GO
PRINT N'Creating trigger [Setup].[FromToMatrix_Trgr] on [Setup].[AttributeMatrixFromTo]'
GO
-- =============================================
-- Author:		Bryan Eddy
-- Create date: 7/2/2018
-- Description:	Trigger to update revision fields
-- =============================================
CREATE TRIGGER [Setup].[FromToMatrix_Trgr] 
   ON  [Setup].[AttributeMatrixFromTo] 
   AFTER INSERT,DELETE,UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	IF NOT (UPDATE(RevisedBy) OR UPDATE(DateRevised))
		BEGIN
			UPDATE T
			SET RevisedBy = SUSER_SNAME(), DateRevised = GETDATE()
			FROM Setup.AttributeMatrixFromTo T INNER JOIN Inserted I ON I.GUIID = T.GUIID
		END

END
GO
PRINT N'Altering [Scheduling].[usp_EmailSchedulingMissingLineSpeed]'
GO

-- =============================================
-- Author:		Bryan Eddy
-- ALTER date: 6/12/17
-- Description:	Send email of missing line speeds to Process Engineers
-- Version:		11
-- Update:		Removed R093 from the exclusion criteria
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
	and LEFT(setup,1) not in ('O','I') and setup not in ('R696','PQC','pk01','SK01') AND setup NOT LIKE 'm00[4-9]'
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
DECLARE @BlindRecipientlist varchar(1000)
DECLARE @Receipientlist varchar(1000)

SELECT @numRows = count(*) FROM #Results;

SET @ReceipientList = (STUFF((SELECT ';' + UserEmail 
						FROM [NAASPB-PRD04\SQL2014].premise.dbo.tblConfiguratorUser G  INNER JOIN [NAASPB-PRD04\SQL2014].premise.users.UserResponsibility  K ON  G.UserID = K.UserID
	  					WHERE K.ResponsibilityID IN (4,16,1) FOR XML PATH('')),1,1,''))


--SET @BlindRecipientlist = 'Bryan.Eddy@aflglobal.com';


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
			--@blind_copy_recipients =  @BlindRecipientlist, --@ReceipientList
			@subject = @subject,
			@body = @tableHTML,
			@body_format = 'HTML';
END


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
			@recipients=@ReceipientList,
			--@blind_copy_recipients = 'bryan.eddy@aflglobal.com',
			@subject = @SubjectLine,
			@body = @html,
			@body_format = 'HTML',
			@query_no_truncate = 1,
			@attach_query_result_as_file = 0;
		END
END


GO
PRINT N'Altering [Scheduling].[usp_EmailAlertMissingMaterialDemand]'
GO

/*
Author:		Bryan Eddy
Date:		5/25/2018
Desc:		Email alert to show missing material demand due to material not referencing correct op sequence
Version:	1
Update:		n/a
*/

ALTER PROCEDURE [Scheduling].[usp_EmailAlertMissingMaterialDemand]
AS
BEGIN
	DECLARE @html NVARCHAR(MAX),
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
			--@blind_copy_recipients = 'bryan.eddy@aflglobal.com',
			@subject = @SubjectLine,
			@body = @html,
			@body_format = 'HTML',
			@query_no_truncate = 1,
			@attach_query_result_as_file = 0;
		END
END

GO
PRINT N'Altering [dbo].[usp_EmailOracleTableRecordCount]'
GO

/*
Author:			Bryan Eddy
Date:			4/16/2017
Description:	Send email of the record count of all Oracle tables in the [Oracle_Interface_Status] table.
Version:		2
Update:			Updated recipients to pull from the DL
*/

ALTER PROCEDURE [dbo].[usp_EmailOracleTableRecordCount]

AS
SET NOCOUNT ON; 
DECLARE @t TABLE(query VARCHAR(1000),[tables] VARCHAR(50))

IF OBJECT_ID(N'tempdb..#OracleRecordCount', N'U') IS NOT NULL
DROP TABLE #OracleRecordCount;
CREATE TABLE #OracleRecordCount(
RecordCount INT,
TableName NVARCHAR(100))


INSERT INTO @t 
    SELECT ' INSERT INTO #OracleRecordCount(RecordCount, TableName) SELECT COUNT(*) ,'''+T.interface_name+'''   FROM  ['+T.interface_name+']', T.interface_name  

    FROM [dbo].[Oracle_Interface_Status] t


DECLARE @sql VARCHAR(8000)


SELECT @sql=ISNULL(@sql+' ','')+ query FROM @t


EXEC(@sql)

DECLARE @Receipientlist VARCHAR(1000)

SET @Receipientlist = (STUFF((SELECT ';' + UserEmail 
						FROM [NAASPB-PRD04\SQL2014].premise.dbo.tblConfiguratorUser G  INNER JOIN [NAASPB-PRD04\SQL2014].premise.users.UserResponsibility  K ON  G.UserID = K.UserID
  						WHERE K.ResponsibilityID = 18 FOR XML PATH('')),1,1,''))

			


	DECLARE @html NVARCHAR(MAX),
@SubjectLine NVARCHAR(1000)

	SET @SubjectLine = 'Oracle Table Record Count ' + CAST(GETDATE() AS NVARCHAR(50))
	EXEC Scheduling.usp_QueryToHtmlTable @html = @html OUTPUT,  
	@query = N'SELECT * FROM #OracleRecordCount', @orderBy = N'TableName';


					EXEC msdb.dbo.sp_send_dbmail 
					@recipients=@Receipientlist ,
					--@blind_copy_recipients = 'bryan.eddy@aflglobal.com',
					@subject = @SubjectLine,
					@body = @html,
					@body_format = 'HTML',
					@query_no_truncate = 1,
					@attach_query_result_as_file = 0;


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
	DECLARE @html NVARCHAR(MAX),
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
						--@blind_copy_recipients = 'bryan.eddy@aflglobal.com',
						@subject = @SubjectLine,
						@body = @html,
						@body_format = 'HTML',
						@query_no_truncate = 1,
						@attach_query_result_as_file = 0;
	END
END
GO
PRINT N'Altering [Scheduling].[usp_EmailSchedulePublishNotification]'
GO




-- =============================================
-- Author:		Bryan Eddy
-- ALTER date:  3/21/2018
-- Description:	Send email of publish notification
-- Version:		1
-- Update:		initial creation
-- =============================================
ALTER PROCEDURE [Scheduling].[usp_EmailSchedulePublishNotification]

AS


SET NOCOUNT ON;


DECLARE  @ReceipientList NVARCHAR(1000),
		@BlindRecipientlist NVARCHAR(1000)


SET @ReceipientList = 'SPBCableACSSchedulePublishNotification@aflglobal.com'

--SET @BlindRecipientlist = ';Bryan.Eddy@aflglobal.com';


DECLARE @body1 VARCHAR(MAX)
DECLARE @subject VARCHAR(MAX)
--DECLARE @query VARCHAR(MAX) = N'SELECT * FROM tempdb..#Results;'
SET @subject = 'Schedule Publish Notification' 


DECLARE @tableHTML  NVARCHAR(MAX) ;
BEGIN
	
			SET @tableHTML =
				N'<H1>Schedule Publish</H1>' +
				N'<H2 span style=''font-size:16.0pt;font-family:"Calibri","sans-serif";color:#EB3814''>The schedule has been updated.</H2>' 


			EXEC msdb.dbo.sp_send_dbmail 
			@recipients=@ReceipientList,
			--@blind_copy_recipients =  @BlindRecipientlist, --@ReceipientList
			@subject = @subject,
			@body = @tableHTML,
			@body_format = 'HTML';
END


GO
PRINT N'Creating [dbo].[_report_9d_fiberset_lengths]'
GO
CREATE TABLE [dbo].[_report_9d_fiberset_lengths]
(
[FiberSet UDF] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[job] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Product] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[job_qty] [float] NULL,
[fiber_set_qty] [float] NULL,
[fiber_set_qty_max] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[percent_of_max] [float] NULL,
[last_update_date] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
PRINT N'Rebuilding [dbo].[_mst_push]'
GO
CREATE TABLE [dbo].[RG_Recovery_2__mst_push]
(
[last_update_date] [datetime] NOT NULL,
[master_schedule_id] [float] NOT NULL,
[organization_code] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[order_number] [bigint] NULL,
[line_number] [bigint] NULL,
[conc_order_number] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bom_route_alt] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[component_item] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[assembly_item] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[operation_seq_num] [float] NULL,
[operation_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[true_operation_seq_num] [float] NULL,
[true_operation_code] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[child_dj_number] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[parent_dj_number] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[machine_name] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[original_machine_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[regrouping_allowed] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[setup_start_date] [datetime] NULL,
[start_time_date] [datetime] NULL,
[end_time_date] [datetime] NULL,
[to_machine] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reel_size] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_date] [datetime] NULL,
[start_qty] [float] NULL,
[total_job_length] [float] NULL,
[group_id] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[staging_number] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fiber_set_id] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[complete] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[scheduled] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[locked] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[machine_override] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
INSERT INTO [dbo].[RG_Recovery_2__mst_push]([last_update_date], [master_schedule_id], [organization_code], [order_number], [line_number], [conc_order_number], [component_item], [assembly_item], [operation_seq_num], [operation_code], [true_operation_seq_num], [true_operation_code], [child_dj_number], [parent_dj_number], [machine_name], [original_machine_name], [regrouping_allowed], [setup_start_date], [start_time_date], [end_time_date], [to_machine], [reel_size], [ship_date], [start_qty], [total_job_length], [group_id], [staging_number], [fiber_set_id], [complete], [scheduled], [locked], [machine_override]) SELECT [last_update_date], [master_schedule_id], [organization_code], [order_number], [line_number], [conc_order_number], [component_item], [assembly_item], [operation_seq_num], [operation_code], [true_operation_seq_num], [true_operation_code], [child_dj_number], [parent_dj_number], [machine_name], [original_machine_name], [regrouping_allowed], [setup_start_date], [start_time_date], [end_time_date], [to_machine], [reel_size], [ship_date], [start_qty], [total_job_length], [group_id], [staging_number], [fiber_set_id], [complete], [scheduled], [locked], [machine_override] FROM [dbo].[_mst_push]
GO
DROP TABLE [dbo].[_mst_push]
GO
EXEC sp_rename N'[dbo].[RG_Recovery_2__mst_push]', N'_mst_push', N'OBJECT'
GO
PRINT N'Rebuilding [dbo].[_report_9b_capacity]'
GO
CREATE TABLE [dbo].[RG_Recovery_3__report_9b_capacity]
(
[day] [date] NOT NULL,
[machine] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[machine_capacity_type] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[department] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[plant] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hours_available] [float] NOT NULL,
[hours_utilized] [numeric] (38, 6) NOT NULL,
[hours_utilized_bottlenecked] [numeric] (38, 6) NOT NULL,
[hours_utilized_late] [numeric] (38, 6) NOT NULL,
[percent_utilized] [float] NULL,
[percent_utilized_bottlenecked] [float] NULL,
[percent_utilized_late] [float] NULL,
[qty] [float] NOT NULL,
[last_update_date] [datetime] NOT NULL,
[planning_horizon_end_date] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
INSERT INTO [dbo].[RG_Recovery_3__report_9b_capacity]([day], [machine], [hours_available], [hours_utilized], [percent_utilized], [qty], [last_update_date]) SELECT [day], [machine], [hours_available], [hours_utilized], [percent_utilized], [qty], [last_update_date] FROM [dbo].[_report_9b_capacity]
GO
DROP TABLE [dbo].[_report_9b_capacity]
GO
EXEC sp_rename N'[dbo].[RG_Recovery_3__report_9b_capacity]', N'_report_9b_capacity', N'OBJECT'
GO
PRINT N'Altering permissions on  [Mes].[usp_GetItemAttributes]'
GO
GRANT EXECUTE ON  [Mes].[usp_GetItemAttributes] TO [prLinkUser]
GO
PRINT N'Altering permissions on SCHEMA:: [Mes]'
GO
GRANT EXECUTE ON SCHEMA:: [Mes] TO [prLinkUser]
GO


USE [msdb]
GO

/****** Object:  Job [GetSetupData_Prod]    Script Date: 7/13/2018 9:04:14 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Data Collector]    Script Date: 7/13/2018 9:04:14 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Data Collector' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Data Collector'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'GetSetupData_Prod', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Pull setup data from Setup Db source', 
		@category_name=N'Data Collector', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'Jeff Gilfillan', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [GetSetupData_Test]    Script Date: 7/13/2018 9:04:14 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'GetSetupData_Test', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=1, 
		@retry_interval=40, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/FILE "\"\\naacab-sch01\ImportFiles\AFL\SetupIndex_Import _APS_Prod.dtsx\"" /X86  /CHECKPOINTING OFF /REPORTING E', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Push PSS data to MES]    Script Date: 7/13/2018 9:04:14 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Push PSS data to MES', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC [SPBMES-PSQL01].IgnMESDb.aps.usp_getSetupData', 
		@database_name=N'PlanetTogether_Data_Prod', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [NormalizeRouting_CalculateSetupTimes_GetFiberCount]    Script Date: 7/13/2018 9:04:14 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'NormalizeRouting_CalculateSetupTimes_GetFiberCount', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'[Scheduling].[usp_MasterDailyProcedureRun]', 
		@database_name=N'PlanetTogether_Data_Prod', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Email Alert]    Script Date: 7/13/2018 9:04:14 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Email Alert', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec Scheduling.usp_EmailMasterAlert', 
		@database_name=N'PlanetTogether_Data_Prod', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'GetSetupData_Test', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=127, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20170728, 
		@active_end_date=99991231, 
		@active_start_time=30000, 
		@active_end_time=235959, 
		@schedule_uid=N'0f1d8f04-7057-4e35-987a-131c3e7a96e4'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO



