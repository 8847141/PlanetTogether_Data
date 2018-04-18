SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
---=========================================================================================
   ---                     AFL Telecommunications
   ---
   ---       Object Name           : xxaflPTUpdatetableinterfacestatus
   ---       Object Description    : This script is used by all CI PT integrations
   ---                                to update interface status on PT table
   ---
   ---       Original Standard Object Name  : NA
   ---       Original Standard Object Ver   : NA
   ---
   ---       Date Written          : 07/26/2017
   ---
   ---       Task Number           : 6084
   ---
   ----------------------------------------------------------------------------------------------
   ---
   ---       Development And Modification History:
   ---
   --- Task #  Ver# DATE           Developer    DESCRIPTION
   --- ------ ---- ----------     ------------ --------------------------------------------------
   ---  6084   1.0  07/26/2017      vemurkr     Initial Version.   

   ---       Copyright 2017 AFL Telecommunications
   ---=============================================================================================
 --**************************************************************************************************
   -- PROCEDURE xxaflPTUpdatetableinterfacestatus: This procedure updates interface status and
   --  last updated date and processed dates columns on PT table based on table/integration 
   --  name as in put parameter
   --**************************************************************************************************
   
CREATE PROCEDURE [dbo].[xxaflPTUpdatetableinterfacestatus]
      (
      @Interfacename nvarchar(100),
  @Status nvarchar(50)  ,     
  @ErrorMessage NVARCHAR(4000) OUTPUT ,
  @ReturnStatus NVARCHAR(10)OUTPUT 
      )
AS
BEGIN TRY
IF @Status = 'Complete'
      UPDATE [Oracle_Interface_Status] SET [Last_Update_date]=GETDATE(), [Interface_Status]=@Status, [Interface_Last_Processed_Date]=GETDATE()
      WHERE [Interface_Name]=@Interfacename
  ELSE IF
  @Status = 'In Process'
  UPDATE [Oracle_Interface_Status] SET [Last_Update_date]=GETDATE(), [Interface_Status]=@Status , [Interface_Last_Processed_Date]=null
      WHERE [Interface_Name]=@Interfacename
  ELSE IF
  @Status = 'Error'
  UPDATE [Oracle_Interface_Status] SET [Last_Update_date]=GETDATE(), [Interface_Status]=@Status , [Interface_Last_Processed_Date]=null
      WHERE [Interface_Name]=@Interfacename
  SELECT
  @ReturnStatus = 'Success'

  END TRY  
  
   
  BEGIN CATCH

    SELECT 
        @ErrorMessage = ERROR_MESSAGE()
         
     IF @ErrorMessage IS NOT NULL 
     SELECT
        @ReturnStatus = 'Failure'    

END CATCH;

GO
DENY EXECUTE ON  [dbo].[xxaflPTUpdatetableinterfacestatus] TO [NAA\SPB_Scheduling_RW]
GO
