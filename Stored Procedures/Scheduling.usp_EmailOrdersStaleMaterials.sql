SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*
Author:		Bryan Eddy
Date:		4/4/2018
Desc:		Alert of materials that haven't been orderd in more than 9 months
Version:	2
Update:		Changed the view to pull stale materials data to a flattened data set
*/

CREATE PROCEDURE [Scheduling].[usp_EmailOrdersStaleMaterials]
AS
BEGIN
	DECLARE @html nvarchar(MAX),
	@SubjectLine NVARCHAR(1000),
	@ReceipientList NVARCHAR(1000),
	@RowCount INT,
	@qry NVARCHAR(MAX),
	@body1 VARCHAR(MAX),
	@html2 NVARCHAR(MAX);

		--Get list of users to email
		SET @ReceipientList = (STUFF((SELECT ';' + UserEmail 
							FROM [NAASPB-PRD04\SQL2014].Premise.dbo.tblConfiguratorUser G  INNER JOIN [NAASPB-PRD04\SQL2014].Premise.users.UserResponsibility  K ON  G.UserID = K.UserID
	  						WHERE K.ResponsibilityID = 22 FOR XML PATH('')),1,1,''))

	--Get count of records to ensure alert should fire off
	SET @qry = 'SELECT count(*) FROM Scheduling.vStaleMaterials'

	EXEC sp_executesql @qry
	IF @@ROWCOUNT > 0 
		BEGIN

		SET @body1 = N'<H1>Stale Materials Report</H1>' +
				N'<H2 span style=''font-size:16.0pt;font-family:"Calibri","sans-serif";color:#EB3814''>Materials not purchased in the past 9 months, Booked / Not Schedule Approved.</H2>' 
	
			SET @SubjectLine = 'Stale Materials Report ' + CAST(GETDATE() AS NVARCHAR(50))

			--Get flattened material demand grouped by finished good
			EXEC Scheduling.usp_QueryToHtmlTable @query = N'SELECT FinishedGood,
								Materials,
								Orders
								FROM Scheduling.vStaleMaterialsFlat',   
                            @orderBy = N'FinishedGood',     
                            @html = @html OUTPUT 

			--Get flattened material demand data grouped by Material and buyer
			EXEC Scheduling.usp_QueryToHtmlTable @query = N'SELECT Material,Buyer,
								FinishedGood,
								Orders
								FROM Scheduling.vStaleMaterialsFlatByBuyer',        
                            @orderBy = N'Buyer',     
                            @html = @html2 OUTPUT 

							PRINT @html2
SET @html =  @html + '<H1>Stale Materials Report Grouped By Material/Buyer</H1><div></div><div>' +  @html2 + '</div>'

			SET @html = @body1 + @html

			EXEC msdb.dbo.sp_send_dbmail 
			@recipients=@ReceipientList,
			--@blind_copy_recipients = 'bryan.eddy@aflglobal.com',
			@subject = @SubjectLine,
			@body = @html,
			@body_format = 'HTML',
			@query_no_truncate = 1,
			@attach_query_result_as_file = 0;
		END
END


GO
