SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






---=========================================================================================
   ---                     AFL Telecommunications
   ---
   ---       Object Name           : xxaflPTMergeOracleDJRoutes
   ---       Object Description    : This script is used to merge records from Oracle and PT
   ---
   ---       Original Standard Object Name  : NA
   ---       Original Standard Object Ver   : NA
   ---
   ---       Date Written          : 12/19/2017
   ---
   ---       Task Number           : 9999
   ---
   ----------------------------------------------------------------------------------------------
   ---
   ---       Development And Modification History:
   ---
   --- Task #  Ver# DATE           Developer    DESCRIPTION
   --- ------ ---- ----------     ------------ --------------------------------------------------
   ---  9999   1.0  12/19/2017      VEGAVI      Initial Version.   

   ---       Copyright 2017 AFL Telecommunications
   ---=============================================================================================
 --**************************************************************************************************
   -- PROCEDURE xxaflPTMergeOracleDJRoutes: This script is used to merge records from Oracle and PT
   --**************************************************************************************************

CREATE procedure [dbo].[xxaflPTMergeOracleDJRoutes]

	@P_BATCH_ID bigint,
	@ReturnStatus AS NVARCHAR(10) OUTPUT ,
    @ErrorMessage AS NVARCHAR(4000) OUTPUT 

as 
BEGIN TRY

	SET NOCOUNT ON;
	
	MERGE Oracle_DJ_Routes as TARGET
	USING Oracle_DJ_Routes_stg as SOURCE 
	ON (TARGET.unique_id = SOURCE.unique_id)
	WHEN MATCHED 
	AND SOURCE.batch_id = @P_BATCH_ID 
	THEN
		UPDATE Set  
			TARGET.unique_id =      SOURCE.unique_id
			,TARGET.organization_code =      SOURCE.organization_code
			,TARGET.wip_entity_name =        SOURCE.wip_entity_name
			,TARGET.job_type =               SOURCE.job_type
			,TARGET.assembly_item =          SOURCE.assembly_item
			,TARGET.assembly_description =   SOURCE.assembly_description
			,TARGET.class_code =             SOURCE.class_code
			,TARGET.dj_status =              SOURCE.dj_status
			,TARGET.start_quantity =         SOURCE.start_quantity
			,TARGET.net_quantity =           SOURCE.net_quantity
			,TARGET.dj_wip_supply_type =     SOURCE.dj_wip_supply_type
			,TARGET.completion_subinventory =SOURCE.completion_subinventory
			,TARGET.completion_locator =     SOURCE.completion_locator
			,TARGET.quantity_remaining =     SOURCE.quantity_remaining
			,TARGET.quantity_completed =     SOURCE.quantity_completed
			,TARGET.quantity_scrapped =      SOURCE.quantity_scrapped
			,TARGET.date_released =          SOURCE.date_released
			,TARGET.date_completed =         SOURCE.date_completed
			,TARGET.date_closed =            SOURCE.date_closed
			,TARGET.schedule_group_name =    SOURCE.schedule_group_name
			,TARGET.description =            SOURCE.description
			,TARGET.dj_creation_date =       SOURCE.dj_creation_date
			,TARGET.dj_last_update_date =    SOURCE.dj_last_update_date
			,TARGET.operation_seq_num =      SOURCE.operation_seq_num
			,TARGET.operation_code =         SOURCE.operation_code
			,TARGET.department_code =        SOURCE.department_code
			,TARGET.count_point =            SOURCE.count_point
			,TARGET.autocharge_flag =        SOURCE.autocharge_flag
			,TARGET.backflush_flag =         SOURCE.backflush_flag
			,TARGET.check_skill =            SOURCE.check_skill
			,TARGET.minimum_transfer_quantity =  SOURCE.minimum_transfer_quantity
			,TARGET.date_last_moved =        SOURCE.date_last_moved
			,TARGET.op_quantity_in_queue =   SOURCE.op_quantity_in_queue
			,TARGET.op_quantity_running =    SOURCE.op_quantity_running
			,TARGET.op_quantity_waiting_to_move =  SOURCE.op_quantity_waiting_to_move
			,TARGET.op_quantity_rejected =   SOURCE.op_quantity_rejected
			,TARGET.op_quantity_scrapped =   SOURCE.op_quantity_scrapped
			,TARGET.op_quantity_completed =  SOURCE.op_quantity_completed
			,TARGET.progress_percentageg =   SOURCE.progress_percentageg
			,TARGET.first_unit_start_date =  SOURCE.first_unit_start_date
			,TARGET.first_unit_completion_date =  SOURCE.first_unit_completion_date
			,TARGET.last_unit_start_date =   SOURCE.last_unit_start_date
			,TARGET.last_unit_completion_date =    SOURCE.last_unit_completion_date
			,TARGET.operation_description =  SOURCE.operation_description
			,TARGET.startup_scrap =          SOURCE.startup_scrap
			,TARGET.send_to_aps =            SOURCE.send_to_aps
			,TARGET.creation_date =          SOURCE.creation_date
			,TARGET.last_update_date =       GETDATE()
			,TARGET.true_operation_code =    SOURCE.true_operation_code
			,TARGET.true_operation_seq_num = SOURCE.true_operation_seq_num 
	WHEN NOT MATCHED 
	AND SOURCE.batch_id = @P_BATCH_ID 
	THEN
		INSERT (
		unique_id
	  ,organization_code
      ,wip_entity_name
      ,job_type
      ,assembly_item
      ,assembly_description
      ,class_code
      ,dj_status
      ,start_quantity
      ,net_quantity
      ,dj_wip_supply_type
      ,completion_subinventory
      ,completion_locator
      ,quantity_remaining
      ,quantity_completed
      ,quantity_scrapped
      ,date_released
      ,date_completed
      ,date_closed
      ,schedule_group_name
      ,description
      ,dj_creation_date
      ,dj_last_update_date
      ,operation_seq_num
      ,operation_code
      ,department_code
      ,count_point
      ,autocharge_flag
      ,backflush_flag
      ,check_skill
      ,minimum_transfer_quantity
      ,date_last_moved
      ,op_quantity_in_queue
      ,op_quantity_running
      ,op_quantity_waiting_to_move
      ,op_quantity_rejected
      ,op_quantity_scrapped
      ,op_quantity_completed
      ,progress_percentageg
      ,first_unit_start_date
      ,first_unit_completion_date
      ,last_unit_start_date
      ,last_unit_completion_date
      ,operation_description
      ,startup_scrap
      ,send_to_aps
      ,creation_date
      ,last_update_date
      ,true_operation_code
      ,true_operation_seq_num
			)
		VALUES (
		SOURCE.unique_id
	  ,SOURCE.organization_code
      ,SOURCE.wip_entity_name
      ,SOURCE.job_type
      ,SOURCE.assembly_item
      ,SOURCE.assembly_description
      ,SOURCE.class_code
      ,SOURCE.dj_status
      ,SOURCE.start_quantity
      ,SOURCE.net_quantity
      ,SOURCE.dj_wip_supply_type
      ,SOURCE.completion_subinventory
      ,SOURCE.completion_locator
      ,SOURCE.quantity_remaining
      ,SOURCE.quantity_completed
      ,SOURCE.quantity_scrapped
      ,SOURCE.date_released
      ,SOURCE.date_completed
      ,SOURCE.date_closed
      ,SOURCE.schedule_group_name
      ,SOURCE.description
      ,SOURCE.dj_creation_date
      ,SOURCE.dj_last_update_date
      ,SOURCE.operation_seq_num
      ,SOURCE.operation_code
      ,SOURCE.department_code
      ,SOURCE.count_point
      ,SOURCE.autocharge_flag
      ,SOURCE.backflush_flag
      ,SOURCE.check_skill
      ,SOURCE.minimum_transfer_quantity
      ,SOURCE.date_last_moved
      ,SOURCE.op_quantity_in_queue
      ,SOURCE.op_quantity_running
      ,SOURCE.op_quantity_waiting_to_move
      ,SOURCE.op_quantity_rejected
      ,SOURCE.op_quantity_scrapped
      ,SOURCE.op_quantity_completed
      ,SOURCE.progress_percentageg
      ,SOURCE.first_unit_start_date
      ,SOURCE.first_unit_completion_date
      ,SOURCE.last_unit_start_date
      ,SOURCE.last_unit_completion_date
      ,SOURCE.operation_description
      ,SOURCE.startup_scrap
      ,SOURCE.send_to_aps
      ,GETDATE()
      ,GETDATE()
      ,SOURCE.true_operation_code
      ,SOURCE.true_operation_seq_num
			);
	--OUTPUT  $action;
	
	--Send records to BKP table
	INSERT INTO Oracle_DJ_Routes_stg_bkp
	SELECT * FROM Oracle_DJ_Routes_stg
	WHERE batch_id = @P_BATCH_ID;
	
	--Delete records from STG table
	DELETE Oracle_DJ_Routes_stg
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
