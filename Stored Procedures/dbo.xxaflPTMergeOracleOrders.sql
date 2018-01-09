SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





---=========================================================================================
   ---                     AFL Telecommunications
   ---
   ---       Object Name           : xxaflPTMergeOracleOrders
   ---       Object Description    : This script is used to merge records from Oracle and PT
   ---
   ---       Original Standard Object Name  : NA
   ---       Original Standard Object Ver   : NA
   ---
   ---       Date Written          : 11/24/2017
   ---
   ---       Task Number           : 9999
   ---
   ----------------------------------------------------------------------------------------------
   ---
   ---       Development And Modification History:
   ---
   --- Task #  Ver# DATE           Developer    DESCRIPTION
   --- ------ ---- ----------     ------------ --------------------------------------------------
   ---  9999   1.0  11/24/2017      VEGAVI      Initial Version.   

   ---       Copyright 2017 AFL Telecommunications
   ---=============================================================================================
 --**************************************************************************************************
   -- PROCEDURE xxaflPTMergeOracleOrders: This script is used to merge records from Oracle and PT
   --**************************************************************************************************

CREATE procedure [dbo].[xxaflPTMergeOracleOrders]

	@P_BATCH_ID bigint,
	@ReturnStatus AS NVARCHAR(10) OUTPUT ,
    @ErrorMessage AS NVARCHAR(4000) OUTPUT 

as 
BEGIN TRY

	SET NOCOUNT ON;
	
	MERGE Oracle_Orders as TARGET
	USING Oracle_Orders_stg as SOURCE 
	ON (TARGET.master_schedule_id = SOURCE.master_schedule_id)
	WHEN MATCHED 
	AND SOURCE.batch_id = @P_BATCH_ID 
	THEN
		UPDATE Set  
			TARGET.fiber_set_id = SOURCE.fiber_set_id
			,TARGET.master_schedule_id = SOURCE.master_schedule_id
			,TARGET.active_flag = SOURCE.active_flag
			,TARGET.disable_reason = SOURCE.disable_reason
			,TARGET.disable_date = SOURCE.disable_date
			,TARGET.organization_code = SOURCE.organization_code
			,TARGET.order_number = SOURCE.order_number
			,TARGET.order_status = SOURCE.order_status
			,TARGET.order_type = SOURCE.order_type
			,TARGET.conc_order_number = SOURCE.conc_order_number
			,TARGET.line_number = SOURCE.line_number
			,TARGET.current_shipment_number = SOURCE.current_shipment_number
			,TARGET.line_status = SOURCE.line_status
			,TARGET.order_line_source_type = SOURCE.order_line_source_type
			,TARGET.source = SOURCE.source
			,TARGET.request_date = SOURCE.request_date
			,TARGET.promise_date = SOURCE.promise_date
			,TARGET.need_by_date = SOURCE.need_by_date
			,TARGET.schedule_approved = SOURCE.schedule_approved
			,TARGET.usac_no_of_cuts = SOURCE.usac_no_of_cuts
			,TARGET.usac_cut_length = SOURCE.usac_cut_length
			,TARGET.bom_route_alt = SOURCE.bom_route_alt
			,TARGET.has_credit_hold = SOURCE.has_credit_hold
			,TARGET.has_mfg_hold = SOURCE.has_mfg_hold
			,TARGET.has_export_hold = SOURCE.has_export_hold
			,TARGET.has_shipping_hold = SOURCE.has_shipping_hold
			,TARGET.scheduler = SOURCE.scheduler
			,TARGET.order_uom = SOURCE.order_uom
			,TARGET.order_quantity = SOURCE.order_quantity
			,TARGET.assembly_item = SOURCE.assembly_item
			,TARGET.assy_primary_uom = SOURCE.assy_primary_uom
			,TARGET.make_buy_flag = SOURCE.make_buy_flag
			,TARGET.pri_uom_order_qty = SOURCE.pri_uom_order_qty
			,TARGET.component_item = SOURCE.component_item
			,TARGET.comp_primary_uom = SOURCE.comp_primary_uom
			,TARGET.operation_seq_num = SOURCE.operation_seq_num
			,TARGET.operation_code = SOURCE.operation_code
			,TARGET.department_code = SOURCE.department_code
			,TARGET.bom_level = SOURCE.bom_level
			,TARGET.bom_op_sequence = SOURCE.bom_op_sequence
			,TARGET.start_up_scrap = SOURCE.start_up_scrap
			,TARGET.qty_per = SOURCE.qty_per
			,TARGET.bom_required_qty = SOURCE.bom_required_qty
			,TARGET.intended_job_qty = SOURCE.intended_job_qty
			,TARGET.minimum_cut_length = SOURCE.minimum_cut_length
			,TARGET.send_to_aps = SOURCE.send_to_aps
			,TARGET.count_per_uom = SOURCE.count_per_uom
			,TARGET.unit_id = SOURCE.unit_id
			,TARGET.layer_id = SOURCE.layer_id
			,TARGET.group_id = SOURCE.group_id
			,TARGET.total_job_length = SOURCE.total_job_length
			,TARGET.fiber_planned = SOURCE.fiber_planned
			,TARGET.comp_product_class = SOURCE.comp_product_class
			,TARGET.child_dj_number = SOURCE.child_dj_number
			,TARGET.parent_dj_number = SOURCE.parent_dj_number
			,TARGET.actual_job_qty = SOURCE.actual_job_qty
			,TARGET.machine_name = SOURCE.machine_name
			,TARGET.regrouping_allowed = SOURCE.regrouping_allowed
			,TARGET.creation_date = SOURCE.creation_date
			,TARGET.last_update_date = SOURCE.last_update_date
			,TARGET.mfg_sched_refresh_date = SOURCE.mfg_sched_refresh_date
			,TARGET.setup_start_date = SOURCE.setup_start_date
			,TARGET.start_time_date = SOURCE.start_time_date
			,TARGET.end_time_date = SOURCE.end_time_date
			,TARGET.to_machine = SOURCE.to_machine
			,TARGET.reel_size = SOURCE.reel_size
			,TARGET.ship_date = SOURCE.ship_date
			,TARGET.usac_customer = SOURCE.usac_customer
			,TARGET.set_name = SOURCE.set_name
			,TARGET.set_number = SOURCE.set_number
			,TARGET.customer_name = SOURCE.customer_name
			,TARGET.schedule_ship_date = SOURCE.schedule_ship_date
			,TARGET.transfer_to_aps = SOURCE.transfer_to_aps
			,TARGET.customer_number = SOURCE.customer_number
			,TARGET.schedule_approved_date = SOURCE.schedule_approved_date
			,TARGET.sf_group_id = SOURCE.sf_group_id
			,TARGET.sf_fiber_set_id = SOURCE.sf_fiber_set_id
	WHEN NOT MATCHED 
	AND SOURCE.batch_id = @P_BATCH_ID 
	THEN
		INSERT (
			fiber_set_id
			,master_schedule_id
			,active_flag
			,disable_reason
			,disable_date
			,organization_code
			,order_number
			,order_status
			,order_type
			,conc_order_number
			,line_number
			,current_shipment_number
			,line_status
			,order_line_source_type
			,source
			,request_date
			,promise_date
			,need_by_date
			,schedule_approved
			,usac_no_of_cuts
			,usac_cut_length
			,bom_route_alt
			,has_credit_hold
			,has_mfg_hold
			,has_export_hold
			,has_shipping_hold
			,scheduler
			,order_uom
			,order_quantity
			,assembly_item
			,assy_primary_uom
			,make_buy_flag
			,pri_uom_order_qty
			,component_item
			,comp_primary_uom
			,operation_seq_num
			,operation_code
			,department_code
			,bom_level
			,bom_op_sequence
			,start_up_scrap
			,qty_per
			,bom_required_qty
			,intended_job_qty
			,minimum_cut_length
			,send_to_aps
			,count_per_uom
			,unit_id
			,layer_id
			,group_id
			,total_job_length
			,fiber_planned
			,comp_product_class
			,child_dj_number
			,parent_dj_number
			,actual_job_qty
			,machine_name
			,regrouping_allowed
			,creation_date
			,last_update_date
			,mfg_sched_refresh_date
			,setup_start_date
			,start_time_date
			,end_time_date
			,to_machine
			,reel_size
			,ship_date
			,usac_customer
			,set_name
			,set_number
			,customer_name
			,schedule_ship_date
			,transfer_to_aps
			,customer_number
			,schedule_approved_date
			,sf_group_id
			,sf_fiber_set_id
			)
		VALUES (
			SOURCE.fiber_set_id
			,SOURCE.master_schedule_id
			,SOURCE.active_flag
			,SOURCE.disable_reason
			,SOURCE.disable_date
			,SOURCE.organization_code
			,SOURCE.order_number
			,SOURCE.order_status
			,SOURCE.order_type
			,SOURCE.conc_order_number
			,SOURCE.line_number
			,SOURCE.current_shipment_number
			,SOURCE.line_status
			,SOURCE.order_line_source_type
			,SOURCE.source
			,SOURCE.request_date
			,SOURCE.promise_date
			,SOURCE.need_by_date
			,SOURCE.schedule_approved
			,SOURCE.usac_no_of_cuts
			,SOURCE.usac_cut_length
			,SOURCE.bom_route_alt
			,SOURCE.has_credit_hold
			,SOURCE.has_mfg_hold
			,SOURCE.has_export_hold
			,SOURCE.has_shipping_hold
			,SOURCE.scheduler
			,SOURCE.order_uom
			,SOURCE.order_quantity
			,SOURCE.assembly_item
			,SOURCE.assy_primary_uom
			,SOURCE.make_buy_flag
			,SOURCE.pri_uom_order_qty
			,SOURCE.component_item
			,SOURCE.comp_primary_uom
			,SOURCE.operation_seq_num
			,SOURCE.operation_code
			,SOURCE.department_code
			,SOURCE.bom_level
			,SOURCE.bom_op_sequence
			,SOURCE.start_up_scrap
			,SOURCE.qty_per
			,SOURCE.bom_required_qty
			,SOURCE.intended_job_qty
			,SOURCE.minimum_cut_length
			,SOURCE.send_to_aps
			,SOURCE.count_per_uom
			,SOURCE.unit_id
			,SOURCE.layer_id
			,SOURCE.group_id
			,SOURCE.total_job_length
			,SOURCE.fiber_planned
			,SOURCE.comp_product_class
			,SOURCE.child_dj_number
			,SOURCE.parent_dj_number
			,SOURCE.actual_job_qty
			,SOURCE.machine_name
			,SOURCE.regrouping_allowed
			,SOURCE.creation_date
			,SOURCE.last_update_date
			,SOURCE.mfg_sched_refresh_date
			,SOURCE.setup_start_date
			,SOURCE.start_time_date
			,SOURCE.end_time_date
			,SOURCE.to_machine
			,SOURCE.reel_size
			,SOURCE.ship_date
			,SOURCE.usac_customer
			,SOURCE.set_name
			,SOURCE.set_number
			,SOURCE.customer_name
			,SOURCE.schedule_ship_date
			,SOURCE.transfer_to_aps
			,SOURCE.customer_number
			,SOURCE.schedule_approved_date
			,SOURCE.sf_group_id
			,SOURCE.sf_fiber_set_id
			);
	--OUTPUT  $action;
	
	--Send records to BKP table
	INSERT INTO Oracle_Orders_stg_bkp
	SELECT * FROM Oracle_Orders_stg
	WHERE batch_id = @P_BATCH_ID;
	
	--Delete records from STG table
	DELETE Oracle_Orders_stg
	WHERE batch_id = @P_BATCH_ID;
	
	SELECT @ReturnStatus = 'Success'
END TRY 

BEGIN CATCH
	SELECT 
		@ErrorMessage = ERROR_MESSAGE()    
	IF ERROR_MESSAGE() IS NOT NULL
	SELECT
		@ReturnStatus = 'Failure'            
END CATCH;






GO
