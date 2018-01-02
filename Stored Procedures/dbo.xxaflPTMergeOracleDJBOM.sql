SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






---=========================================================================================
   ---                     AFL Telecommunications
   ---
   ---       Object Name           : xxaflPTMergeOracleDJBOM
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
   -- PROCEDURE xxaflPTMergeOracleDJBOM: This script is used to merge records from Oracle and PT
   --**************************************************************************************************

CREATE procedure [dbo].[xxaflPTMergeOracleDJBOM]

	@P_BATCH_ID bigint,
	@ReturnStatus AS NVARCHAR(10) OUTPUT ,
    @ErrorMessage AS NVARCHAR(4000) OUTPUT 

as 
BEGIN TRY

	SET NOCOUNT ON;
	
	MERGE Oracle_DJ_BOM as TARGET
	USING Oracle_DJ_BOM_stg as SOURCE 
	ON (TARGET.unique_id = SOURCE.unique_id)
	WHEN MATCHED 
	AND SOURCE.batch_id = @P_BATCH_ID 
	THEN
		UPDATE Set  
		    TARGET.unique_id =          SOURCE.unique_id
			,TARGET.organization_code =          SOURCE.organization_code
			,TARGET.wip_entity_name =            SOURCE.wip_entity_name
			,TARGET.job_type =                   SOURCE.job_type
			,TARGET.assembly_item =              SOURCE.assembly_item
			,TARGET.assembly_description =       SOURCE.assembly_description
			,TARGET.class_code =                 SOURCE.class_code
			,TARGET.dj_status =                  SOURCE.dj_status
			,TARGET.start_quantity =             SOURCE.start_quantity
			,TARGET.net_quantity =               SOURCE.net_quantity
			,TARGET.dj_wip_supply_type =         SOURCE.dj_wip_supply_type
			,TARGET.completion_subinventory =    SOURCE.completion_subinventory  
			,TARGET.completion_locator =         SOURCE.completion_locator
			,TARGET.quantity_remaining =         SOURCE.quantity_remaining
			,TARGET.quantity_completed =         SOURCE.quantity_completed
			,TARGET.quantity_scrapped =          SOURCE.quantity_scrapped
			,TARGET.date_released =              SOURCE.date_released
			,TARGET.date_completed =             SOURCE.date_completed
			,TARGET.date_closed =                SOURCE.date_closed
			,TARGET.schedule_group_name =        SOURCE.schedule_group_name
			,TARGET.description =                SOURCE.description
			,TARGET.dj_creation_date =           SOURCE.dj_creation_date
			,TARGET.dj_last_update_date =        SOURCE.dj_last_update_date
			,TARGET.component_item =             SOURCE.component_item
			,TARGET.operation_seq_num =          SOURCE.operation_seq_num
			,TARGET.department_code =            SOURCE.department_code
			,TARGET.date_required =              SOURCE.date_required
			,TARGET.component_description =      SOURCE.component_description
			,TARGET.component_primary_uom_code = SOURCE.component_primary_uom_code     
			,TARGET.basis_type =                 SOURCE.basis_type
			,TARGET.quantity_per_assembly =      SOURCE.quantity_per_assembly
			,TARGET.required_quantity =          SOURCE.required_quantity
			,TARGET.quantity_issued =            SOURCE.quantity_issued
			,TARGET.quantity_open =              SOURCE.quantity_open
			,TARGET.wip_supply_type =            SOURCE.wip_supply_type
			,TARGET.com_wip_supply_type =        SOURCE.com_wip_supply_type
			,TARGET.quantity_allocated =         SOURCE.quantity_allocated
			,TARGET.comments =                   SOURCE.comments
			,TARGET.supply_subinventory =        SOURCE.supply_subinventory
			,TARGET.supply_locator =             SOURCE.supply_locator
			,TARGET.count_per_uom =              SOURCE.count_per_uom
			,TARGET.layer_id =                   SOURCE.layer_id
			,TARGET.unit_id =                    SOURCE.unit_id
			,TARGET.creation_date =              SOURCE.creation_date
			,TARGET.last_update_date =           GETDATE()
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
			,component_item
			,operation_seq_num
			,department_code
			,date_required
			,component_description
			,component_primary_uom_code
			,basis_type
			,quantity_per_assembly
			,required_quantity
			,quantity_issued
			,quantity_open
			,wip_supply_type
			,com_wip_supply_type
			,quantity_allocated
			,comments
			,supply_subinventory
			,supply_locator
			,count_per_uom
			,layer_id
			,unit_id
			,creation_date
			,last_update_date
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
		,SOURCE.component_item
		,SOURCE.operation_seq_num
		,SOURCE.department_code
		,SOURCE.date_required
		,SOURCE.component_description
		,SOURCE.component_primary_uom_code
		,SOURCE.basis_type
		,SOURCE.quantity_per_assembly
		,SOURCE.required_quantity
		,SOURCE.quantity_issued
		,SOURCE.quantity_open
		,SOURCE.wip_supply_type
		,SOURCE.com_wip_supply_type
		,SOURCE.quantity_allocated
		,SOURCE.comments
		,SOURCE.supply_subinventory
		,SOURCE.supply_locator
		,SOURCE.count_per_uom
		,SOURCE.layer_id
		,SOURCE.unit_id
		,GETDATE()
		,GETDATE()
			);
	--OUTPUT  $action;
	
	--Send records to BKP table
	INSERT INTO Oracle_DJ_BOM_stg_bkp
	SELECT * FROM Oracle_DJ_BOM_stg
	WHERE batch_id = @P_BATCH_ID;
	
	--Delete records from STG table
	DELETE Oracle_DJ_BOM_stg
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
