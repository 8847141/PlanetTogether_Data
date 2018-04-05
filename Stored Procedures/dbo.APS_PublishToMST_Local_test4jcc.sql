SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		John Cameron
-- Create date: 2017.09.27
-- Description: Populate the _MST_Push table with published data.
-- =============================================
CREATE PROCEDURE [dbo].[APS_PublishToMST_Local_test4jcc] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ImportDB NVARCHAR(50) = 'PlanetTogether_Import_AFL_PT_Temp'
	DECLARE @PublishDB NVARCHAR(50) = 'PlanetTogether_Publish_AFL_PT_Temp'
	DECLARE @DataDB NVARCHAR(50) = 'PlanetTogether_Data_Test'

-- Transaction Log
	DECLARE @TL NVARCHAR(50) = 'APS_GetData_TranLog'
	DECLARE @TLA NVARCHAR(100) = 'INSERT INTO ' + @TL + ' SELECT GETDATE(), '''
	DECLARE @TLB NVARCHAR(50) = ''''
	DECLARE @strng NVARCHAR(300) = '----- Start -----'
	IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @TL) EXEC('DROP TABLE ' + @TL)
	EXEC('SELECT GETDATE() AS TLDate, CAST(''' + @strng + ''' AS NVARCHAR(300)) AS TLEntry INTO ' + @TL)


	DECLARE @mst_CURSOR CURSOR
	DECLARE @mst_master_schedule_id FLOAT
	DECLARE @mst_order_number BIGINT
	DECLARE @mst_line_number BIGINT
	DECLARE @mst_bom_route_alt VARCHAR(50)
	DECLARE @mst_order_quantity FLOAT
	DECLARE @mst_assembly_item VARCHAR(50)




	DECLARE @DS NVARCHAR(50) = '_mst_push'
	IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @DS) EXEC('DROP TABLE ' + @DS)
	CREATE TABLE _mst_push (master_schedule_id FLOAT NOT NULL
		, organization_code VARCHAR(3)
		, order_number BIGINT
		, line_number BIGINT
		, component_item VARCHAR(50)
		, conc_order_number VARCHAR(50)
		, usac_no_of_cuts FLOAT
		, usac_cut_length FLOAT
		, assembly_item VARCHAR(50)
		, operation_seq_num FLOAT
		, child_dj_number VARCHAR(50)
		, parent_dj_number VARCHAR(50)
		, machine_name VARCHAR(50)
		, setup_start_date DATETIME
		, start_time_date DATETIME
		, end_time_date DATETIME
		, to_machine VARCHAR(50)
		, reel_size VARCHAR(50)
		, ship_date DATETIME
		, usac_customer VARCHAR(100)
		, set_name VARCHAR(50)
		, set_number VARCHAR(50)
		, last_update_date DATETIME
		, group_id VARCHAR(100)
		, true_operation_seq_num FLOAT
		, total_job_length FLOAT
		, staging_number FLOAT
		, start_quantity FLOAT 
		)


 
-- Materials
	EXEC('INSERT INTO ' + @DS
	+ ' SELECT o.master_schedule_id '
	+ ' , o.organization_code '
	+ ' , o.order_number '
	+ ' , o.line_number '
	+ ' , o.component_item '
	+ ' , o.conc_order_number '
	+ ' , o.usac_no_of_cuts '
	+ ' , o.usac_cut_length '
	+ ' , o.assembly_item '
	+ ' , o.operation_seq_num '
	+ ' , o.child_dj_number ' 
	+ ' , o.parent_dj_number '
	+ ' , a.ResourceID AS machine_name '
	+ ' , a.setup_start_date '
	+ ' , a.start_time_date '
	+ ' , a.end_time_date '
	+ ' , o.to_machine '
	+ ' , o.reel_size '
	+ ' , o.ship_date '
	+ ' , o.usac_customer '
	+ ' , o.set_name '
	+ ' , o.set_number '
	+ ' , a.last_update_date '
	+ ' , o.group_id '
	+ ' , a.true_operation_seq_num '
	+ ' , o.total_job_length '
	+ ' , -999 AS staging_number '
	+ ' , a.start_quantity '
	+ ' FROM ' + @PublishDB + '.dbo.APS_PushToMST_Materials_test4jcc AS a 
			INNER JOIN dbo.Oracle_Orders AS o ON a.order_number = o.order_number AND a.line_number = o.line_number AND a.component_item = o.component_item ')
 

-- Operations
	EXEC('INSERT INTO ' + @DS
	+ ' SELECT a.master_schedule_id '
	+ ' , o.organization_code '
	+ ' , o.order_number '
	+ ' , o.line_number '
	+ ' , o.component_item '
	+ ' , o.conc_order_number '
	+ ' , o.usac_no_of_cuts '
	+ ' , o.usac_cut_length '
	+ ' , o.assembly_item '
	+ ' , o.operation_seq_num '
	+ ' , o.child_dj_number ' 
	+ ' , o.parent_dj_number '
	+ ' , a.ResourceID AS machine_name '
	+ ' , a.setup_start_date '
	+ ' , a.start_time_date '
	+ ' , a.end_time_date '
	+ ' , o.to_machine '
	+ ' , o.reel_size '
	+ ' , o.ship_date '
	+ ' , o.usac_customer '
	+ ' , o.set_name '
	+ ' , o.set_number '
	+ ' , a.last_update_date '
	+ ' , o.group_id '
	+ ' , a.true_operation_seq_num '
	+ ' , o.total_job_length '
	+ ' , -999 AS staging_number '
	+ ' , a.start_quantity '
	+ ' FROM ' + @PublishDB + '.dbo.APS_PushToMST_Operations_test4jcc AS a 
			INNER JOIN dbo.Oracle_Orders AS o ON o.master_schedule_id = a.master_schedule_id ')


 

jumpend:
END
GO
