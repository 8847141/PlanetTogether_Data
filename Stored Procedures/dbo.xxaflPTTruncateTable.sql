SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
---=========================================================================================
   ---                     AFL Telecommunications
   ---
   ---       Object Name           : xxaflPTTruncateTable
   ---       Object Description    : This script is used by all CI PT integrations
   ---                                to truncate table get as parameter
   ---
   ---       Original Standard Object Name  : NA
   ---       Original Standard Object Ver   : NA
   ---
   ---       Date Written          : 07/26/2017
   ---
   ---       Task Number           : 6132
   ---
   ----------------------------------------------------------------------------------------------
   ---
   ---       Development And Modification History:
   ---
   --- Task #  Ver# DATE           Developer    DESCRIPTION
   --- ------ ---- ----------     ------------ --------------------------------------------------
   ---  6132   1.0  07/26/2017      VEGAVI      Initial Version.   

   ---       Copyright 2017 AFL Telecommunications
   ---=============================================================================================
 --**************************************************************************************************
   -- PROCEDURE xxaflPTTruncateTable: This script is used by all CI PT integrations
   ---                                to truncate table get as parameter
   --**************************************************************************************************
   
CREATE PROCEDURE [dbo].[xxaflPTTruncateTable]
  @TableName AS NVarchar(50) ,
  @RowsCount AS NVARCHAR(50) OUTPUT ,
  @ReturnStatus AS NVARCHAR(10) OUTPUT ,
  @ErrorMessage AS NVARCHAR(4000) OUTPUT 
AS
BEGIN TRY 
   DECLARE @ActualTableName AS NVarchar(255)
   DECLARE @sql AS NVARCHAR(MAX)
   DECLARE @counts int

  SELECT @ActualTableName = QUOTENAME( TABLE_NAME )
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = @TableName

  SELECT @sql = 'SELECT @cnt = COUNT(*) FROM ' + @ActualTableName + ';'

  EXECUTE sp_executesql @SQL, N'@cnt int OUTPUT', @cnt=@counts OUTPUT
  SELECT @RowsCount = @counts
  SELECT @sql = 'Truncate TABLE ' + @ActualTableName + ';'
  EXEC(@SQL)

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
