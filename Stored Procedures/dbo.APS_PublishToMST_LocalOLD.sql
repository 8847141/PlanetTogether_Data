SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		John Cameron
-- Create date: 2017.09.27
-- Description: Populate the _MST_Push table with published data.
-- =============================================
CREATE PROCEDURE [dbo].[APS_PublishToMST_LocalOLD] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ImportDB NVARCHAR(50) = 'PlanetTogether_Import_AFL_PT_Temp'
	DECLARE @PublishDB NVARCHAR(50) = 'PlanetTogether_Publish_AFL_PT_Temp'
	DECLARE @DataDB NVARCHAR(50) = 'PlanetTogether_Data_Test'
	DECLARE @DS NVARCHAR(50) = '_mst_push'
	IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @DS) EXEC('DROP TABLE ' + @DS)

	-- component materials
	select 
	a.last_update_date, o.master_schedule_id, a.organization_code, a.order_number, a.conc_order_number, a.usac_no_of_cuts, a.usac_cut_length, a.assembly_item, a.component_item, 
	ISNULL(o.child_dj_number, '(null)') AS child_dj_number, 
                         a.parent_dj_number, a.machine_name, a.setup_start_date, a.start_time_date, a.end_time_date, a.to_machine, a.reel_size, a.cuts, a.lengths, a.ship_date, a.usac_customer, a.set_name, a.set_number, 
                         a.line_number
	into _mst_push from PlanetTogether_Publish_AFL_Test.dbo.APS_PushToMST AS a INNER JOIN
                         dbo.Oracle_Orders AS o ON a.order_number = o.order_number AND a.line_number = o.line_number AND a.component_item = o.component_item

	-- operations


END
GO
