SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
Author:			Bryan Eddy
Date:			4/16/2017
Description:	Send email of the record count of all Oracle tables in the [Oracle_Interface_Status] table.
Version:		2
Update:			Updated recipients to pull from the DL
*/

CREATE PROCEDURE [dbo].[usp_EmailOracleTableRecordCount]

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

DECLARE @Receipientlist varchar(1000)

SET @Receipientlist = (STUFF((SELECT ';' + UserEmail 
						FROM [NAASPB-PRD04\SQL2014].premise.dbo.tblConfiguratorUser G  INNER JOIN [NAASPB-PRD04\SQL2014].premise.users.UserResponsibility  K ON  G.UserID = K.UserID
  						WHERE K.ResponsibilityID = 18 FOR XML PATH('')),1,1,''))

			


	DECLARE @html nvarchar(MAX),
@SubjectLine NVARCHAR(1000)

	SET @SubjectLine = 'Oracle Table Record Count ' + CAST(GETDATE() AS NVARCHAR(50))
	EXEC Scheduling.usp_QueryToHtmlTable @html = @html OUTPUT,  
	@query = N'SELECT * FROM #OracleRecordCount', @orderBy = N'TableName';


					EXEC msdb.dbo.sp_send_dbmail 
					@recipients=@Receipientlist ,
					--@recipients='Bryan.Eddy@aflglobal.com;',
					@blind_copy_recipients = 'bryan.eddy@aflglobal.com',
					@subject = @SubjectLine,
					@body = @html,
					@body_format = 'HTML',
					@query_no_truncate = 1,
					@attach_query_result_as_file = 0;


GO
