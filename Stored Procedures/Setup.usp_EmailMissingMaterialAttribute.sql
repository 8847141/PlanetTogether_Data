SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*
Author:		Bryan Eddy
Date:		2/13/2018
Desc:		Email alert to notify of msising material attributes
Version:	2
Update:		Updated subject line
*/

CREATE PROCEDURE [Setup].[usp_EmailMissingMaterialAttribute]
AS
BEGIN

SET NOCOUNT ON;

	--Get missing setup information
	IF OBJECT_ID(N'tempdb..#Results', N'U') IS NOT NULL
	DROP TABLE #Results;

	SELECT item_number, attribute_name, item_description
	INTO #Results
	FROM Setup.vMissingMaterialAttributes


	--Send Email alert
	DECLARE @numRows int
	DECLARE @Receipientlist varchar(1000)
	DECLARE @BlindRecipientlist varchar(1000)

	SELECT @numRows = count(*) FROM #Results;


	SET @ReceipientList = (STUFF((SELECT ';' + UserEmail 
							FROM [NAASPB-PRD04\SQL2014].Premise.dbo.tblConfiguratorUser G  INNER JOIN [NAASPB-PRD04\SQL2014].Premise.users.UserResponsibility  K ON  G.UserID = K.UserID
	  						WHERE K.ResponsibilityID = 12 FOR XML PATH('')),1,1,''))

	/*
	************************************************************
	Temporary until scheduling has production data******
	************************************************************
	*/



	DECLARE @body1 VARCHAR(MAX)
	DECLARE @subject VARCHAR(MAX)
	--DECLARE @query VARCHAR(MAX) = N'SELECT * FROM tempdb..#Results;'
	SET @subject = 'Missing Material Attribute Alert' 
	SET @body1 =  CAST(@numRows AS NVARCHAR(20)) + ' item(s) missing attributes.  Please review.' +CHAR(13)+CHAR(13)

	DECLARE @tableHTML  NVARCHAR(MAX) ;
	IF @numRows > 0
		BEGIN
	
					SET @tableHTML =
						N'<H1>Missing Material Attribute Report</H1>' +
						--N'<H2 span style=''font-size:16.0pt;font-family:"Calibri","sans-serif";color:#EB3814''>Items with the setups below will be unable to schedule.</H2>' +
						--N'<H2 style = ''color: EB3814''>' +
						N'<p>'+@body1+'</p>' +
						N'<p class=MsoNormal><span style=''font-size:11.0pt;font-family:"Calibri","sans-serif";color:#1F497D''>'+
						N'<table border="1">' +
						N'<tr><th>Item</th><th>Missing Attribute</th>' +
						N'<th>Item Description</th>' +
						N'</tr>' +
						CAST ( ( SELECT		td=item_number,    '',
											td=attribute_name, '',
											td=item_description, ''	
									FROM #Results 
									FOR XML PATH('tr'), TYPE 
						) AS NVARCHAR(MAX) ) +
						N'</table>' ;

		
					EXEC msdb.dbo.sp_send_dbmail 
					@recipients=@ReceipientList,
					@subject = @subject,
					@body = @tableHTML,
					@body_format = 'HTML';
		END


END
GO
