SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:		Bryan Eddy
-- ALTER date:  3/21/2018
-- Description:	Send email of publish notification
-- Version:		1
-- Update:		initial creation
-- =============================================
CREATE PROCEDURE [Scheduling].[usp_EmailSchedulePublishNotification]

AS


SET NOCOUNT ON;


DECLARE  @ReceipientList NVARCHAR(1000),
		@BlindRecipientlist NVARCHAR(1000)


SET @ReceipientList = 'SPBCableACSSchedulePublishNotification@aflglobal.com'

--SET @BlindRecipientlist = ';Bryan.Eddy@aflglobal.com';


DECLARE @body1 VARCHAR(MAX)
DECLARE @subject VARCHAR(MAX)
--DECLARE @query VARCHAR(MAX) = N'SELECT * FROM tempdb..#Results;'
SET @subject = 'Schedule Publish Notification' 


DECLARE @tableHTML  NVARCHAR(MAX) ;
BEGIN
	
			SET @tableHTML =
				N'<H1>Schedule Publish</H1>' +
				N'<H2 span style=''font-size:16.0pt;font-family:"Calibri","sans-serif";color:#EB3814''>The schedule has been updated.</H2>' 


			EXEC msdb.dbo.sp_send_dbmail 
			@recipients=@ReceipientList,
			--@blind_copy_recipients =  @BlindRecipientlist, --@ReceipientList
			@subject = @subject,
			@body = @tableHTML,
			@body_format = 'HTML';
END


GO
