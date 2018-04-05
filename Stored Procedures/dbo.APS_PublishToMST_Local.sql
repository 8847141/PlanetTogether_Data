SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		John Cameron
-- Create date: 2017.09.27
-- Description: Populate the _MST_Push table with published data.
-- =============================================
CREATE PROCEDURE [dbo].[APS_PublishToMST_Local] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ImportDB NVARCHAR(50) = 'PlanetTogether_Import_AFL_Test'
	DECLARE @PublishDB NVARCHAR(50) = 'PlanetTogether_Publish_AFL_Test'
	DECLARE @DataDB NVARCHAR(50) = 'PlanetTogether_Data_Test'
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
	+ ' , a.order_number '
	+ ' , a.line_number '
	+ ' , a.component_item '
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
	+ ' FROM ' + @PublishDB + '.dbo.APS_PushToMST_Materials AS a 
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
	+ ' FROM ' + @PublishDB + '.dbo.APS_PushToMST_Operations AS a 
			INNER JOIN dbo.Oracle_Orders AS o ON o.master_schedule_id = a.master_schedule_id ')
/*	EXEC('INSERT INTO ' + @DS
	+ ' SELECT master_schedule_id, organization_code, order_number, conc_order_number,
			a.usac_no_of_cuts, 
			a.usac_cut_length,
			assembly_item, assembly_item AS component_item, operation_seq_num, child_dj_number, 
			a.parent_dj_number, 
			ResourceID AS machine_name, cast(NULL AS DATETIME) AS setup_start_date, start_time_date, end_time_date, 
			a.to_machine, 
			a.reel_size, 
			a.ship_date, 
			a.usac_customer, 
			a.set_name, 
			a.set_number, 
			last_update_date, 
			a.group_id END AS group_id, line_number, true_operation_seq_num, 
			-1 AS total_job_length, -1 AS staging_number, start_quantity '
	+ ' FROM ' + @PublishDB + '.dbo.APS_PushToMST_Operations_test4jcc a ')

	*/







--	EXEC('INSERT INTO ' + @DS
--	+ ' SELECT last_update_date, CAST(NULL AS INT) AS master_schedule_id '
--	+ ' FROM ' + @PublishDB + '.dbo.APS_PushToMST_Operations_test4jcc ')

	-- component materials
	--select 
	--a.last_update_date, o.master_schedule_id, a.organization_code, a.order_number, a.conc_order_number, a.usac_no_of_cuts, a.usac_cut_length, 
	--a.assembly_item, a.component_item, 
	--ISNULL(o.child_dj_number, '(null)') AS child_dj_number, 
 --                        a.parent_dj_number, a.machine_name, a.setup_start_date, a.start_time_date, a.end_time_date, a.to_machine, 
	--					 a.reel_size, a.cuts, a.lengths, a.ship_date, a.usac_customer, a.set_name, a.set_number, 
 --                        a.line_number, a.true_operation_seq_num
	--into _mst_push from PlanetTogether_Publish_AFL_PT_Temp.dbo.APS_PushToMST AS a INNER JOIN
 --                        dbo.Oracle_Orders AS o ON a.order_number = o.order_number AND a.line_number = o.line_number AND a.component_item = o.component_item


	
	/*
-- Materials:
	SELECT      a.last_update_date
	--, o.master_schedule_id, a.organization_code, a.order_number, a.conc_order_number, a.usac_no_of_cuts, a.usac_cut_length, 
--				a.assembly_item, a.component_item, ISNULL(o.child_dj_number, '(null)') AS child_dj_number, a.parent_dj_number, a.machine_name, 
--				a.setup_start_date, a.start_time_date, a.end_time_date, a.to_machine, a.reel_size, a.cuts, a.lengths, a.ship_date, a.usac_customer, 
--                         a.set_name, a.set_number, a.line_number, a.true_operation_seq_num
INTO _mst_push
FROM            PlanetTogether_Publish_AFL_PT_Temp.dbo.APS_PushToMST_Materials_test4jcc AS a INNER JOIN
                         dbo.Oracle_Orders AS o ON a.order_number = o.order_number AND a.line_number = o.line_number AND a.component_item = o.component_item

-- then this:
INSERT INTO _mst_push
	SELECT DISTINCT 
                         last_update_date
						 --, CAST(NULL AS INT) AS master_schedule_id, organization_code, order_number, conc_order_number, usac_no_of_cuts, usac_cut_length, 
--						 assembly_item, CAST(NULL AS NVARCHAR(10)) AS component_item, CAST(child_dj_number AS NVARCHAR(20)), parent_dj_number, machine_name, 
--						 setup_start_date, start_time_date, end_time_date, to_machine, reel_size, cuts, lengths, ship_date, usac_customer, 
--                         set_name, set_number, line_number, true_operation_seq_num
FROM            PlanetTogether_Publish_AFL_PT_Temp.dbo.APS_PushToMST_Operations_test4jcc

*/

jumpend:
END
GO
