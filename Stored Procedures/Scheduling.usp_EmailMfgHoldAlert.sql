SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
Author:		Bryan Eddy
Date:		5/16/2018
Desc:		Alert for items with mfg hold that are <= 21 days from promised date
Version:	1
Update:		n/a

*/

CREATE PROCEDURE [Scheduling].[usp_EmailMfgHoldAlert]
AS
BEGIN
	DECLARE @html nvarchar(MAX),
	@SubjectLine NVARCHAR(1000),
	@ReceipientList NVARCHAR(1000),
	@qry NVARCHAR(MAX)

		SET @ReceipientList = (STUFF((SELECT ';' + UserEmail 
							FROM [NAASPB-PRD04\SQL2014].Premise.dbo.tblConfiguratorUser G  INNER JOIN [NAASPB-PRD04\SQL2014].Premise.users.UserResponsibility  K ON  G.UserID = K.UserID
	  						WHERE K.ResponsibilityID = 19 FOR XML PATH('')),1,1,''))


	SET @qry = N'SELECT order_number, conc_order_number, CAST(promise_date as DATE) promise_date, CAST(need_by_date AS DATE) need_by_date, has_mfg_hold, assembly_item, 
	customer_name, scheduler, CAST(pri_uom_order_qty AS INT) pri_uom_order_qty FROM Scheduling.vAlertMfgHold'


	EXEC sp_executesql @qry
	IF @@ROWCOUNT > 0 
	BEGIN

		SET @SubjectLine = 'MFG Hold Alert ' + CAST(GETDATE() AS NVARCHAR(50))
		EXEC Scheduling.usp_QueryToHtmlTable @html = @html OUTPUT,  
		@query = @qry, @orderBy = N'ORDER BY order_number';




						EXEC msdb.dbo.sp_send_dbmail 
						@recipients=@ReceipientList,
						--@recipients = 'bryan.eddy@aflglobal.com',
						--@blind_copy_recipients =  @BlindRecipientlist, --@ReceipientList
						@blind_copy_recipients = 'bryan.eddy@aflglobal.com',
						@subject = @SubjectLine,
						@body = @html,
						@body_format = 'HTML',
						@query_no_truncate = 1,
						@attach_query_result_as_file = 0;
	END
END
GO
