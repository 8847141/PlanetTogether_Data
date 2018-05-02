SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
Author:		Bryan Eddy
Date:		4/4/2018
Desc:		Alert of materials that haven't been orderd in more than 9 months
Version:	1
Update:		n/a

*/

CREATE PROCEDURE [Scheduling].[usp_EmailOrdersStaleMaterials]
AS
BEGIN
	DECLARE @html nvarchar(MAX),
	@SubjectLine NVARCHAR(1000)

	SET @SubjectLine = 'Orders with Stale Materials ' + CAST(GETDATE() AS NVARCHAR(50))
	EXEC Scheduling.usp_QueryToHtmlTable @html = @html OUTPUT,  
	@query = N'SELECT * FROM Scheduling.vOrdersWithMaterialsNotOrderedInNineMonths', @orderBy = N'ORDER BY order_number';


					EXEC msdb.dbo.sp_send_dbmail 
					@recipients='Jeff.Gilfillan@aflglobal.com; Rich.DiDonato@aflglobal.com',
					--@recipients = 'bryan.eddy@aflglobal.com',
					--@blind_copy_recipients =  @BlindRecipientlist, --@ReceipientList
					@blind_copy_recipients = 'bryan.eddy@aflglobal.com',
					@subject = @SubjectLine,
					@body = @html,
					@body_format = 'HTML',
					@query_no_truncate = 1,
					@attach_query_result_as_file = 0;
END
GO
