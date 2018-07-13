SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






/*
Author:		Bryan Eddy
Date:		2/2/2018
Desc:		Email alert to notify of DJ's with setups missing
Version:	2
Update:		Updated to show all affected DJ's and the op sequence
*/

CREATE PROCEDURE [Setup].[usp_EmailMissingDjSetup]
AS
BEGIN

SET NOCOUNT ON;

	--Get missing setup information
	IF OBJECT_ID(N'tempdb..#Results', N'U') IS NOT NULL
	DROP TABLE #Results;

	WITH cteJobsMissingSetups
	AS(
		SELECT DISTINCT Setup, I.assembly_item,I.wip_entity_name, I.date_released,assembly_description, I.department_code,operation_seq_num
		--,MIN(I.date_released) OVER (PARTITION BY Setup) EarliestReleasedDate
		--,ROW_NUMBER() OVER (PARTITION BY Setup ORDER BY date_released) RowNumber
			--,COUNT(setup) OVER (PARTITION BY Setup) NumberOfJobsAffected
		FROM (
				SELECT DISTINCT Setup, I.assembly_item,I.wip_entity_name, I.date_released  , I.assembly_description, I.department_code, I.operation_seq_num
				FROM	Setup.vMissingSetupsDj K INNER JOIN dbo.Oracle_DJ_Routes  I ON I.true_operation_code = K.Setup 
						INNER JOIN Scheduling.vOracleOrders j ON j.parent_dj_number = i.wip_entity_name
					)  I
	)
	SELECT  G.*
	INTO #Results
	FROM cteJobsMissingSetups G left JOIN Setup.MissingSetups K ON g.Setup = k.Setup
	--WHERE G.EarliestReleasedDate = G.date_released AND G.RowNumber = 1

	--Merge missing setups with the MissingSetups table
	MERGE Setup.MissingSetups AS T
	USING (SELECT DISTINCT Setup FROM #Results) s
	ON t.Setup = S.Setup
	WHEN MATCHED THEN
	UPDATE SET T.DateMostRecentAppearance = GETDATE()
	WHEN NOT MATCHED BY TARGET THEN
	INSERT (SETUP) VALUES (setup);

	--Results to populate the email table
	IF OBJECT_ID(N'tempdb..#FinalResults', N'U') IS NOT NULL
	DROP TABLE #FinalResults;
	SELECT DATEDIFF(dd,K.DateCreated,K.DateMostRecentAppearance) DaysMissing, k.DateCreated, k.DateMostRecentAppearance,CAST(j.operation_seq_num AS INT) operation_seq_num
	,cast(J.date_released AS date) date_released, j.department_code, j.wip_entity_name,j.assembly_item
	,J.Setup
	INTO #FinalResults
	FROM setup.MissingSetups K INNER JOIN	#Results J ON K.Setup = J.Setup
	ORDER BY cast(date_released AS date)--,DaysMissing DESC

	--SELECT *
	--FROM #FinalResults
	--ORDER BY date_released
		
	--Send Email alert
	DECLARE @numRows int
	DECLARE @Receipientlist varchar(1000)
	DECLARE @BlindRecipientlist varchar(1000)

	SELECT @numRows = count(*) FROM #Results;


	SET @ReceipientList = (STUFF((SELECT ';' + UserEmail 
							FROM [NAASPB-PRD04\SQL2014].premise.dbo.tblConfiguratorUser G  INNER JOIN [NAASPB-PRD04\SQL2014].premise.users.UserResponsibility  K ON  G.UserID = K.UserID
  							WHERE K.ResponsibilityID = 1 FOR XML PATH('')),1,1,''))

	SET @ReceipientList = @ReceipientList +';'+ (STUFF((SELECT ';' + UserEmail 
							FROM [NAASPB-PRD04\SQL2014].premise.dbo.tblConfiguratorUser G  INNER JOIN [NAASPB-PRD04\SQL2014].Premise.users.UserResponsibility  K ON  G.UserID = K.UserID
  							WHERE K.ResponsibilityID = 4 FOR XML PATH('')),1,1,''))


	--SET @BlindRecipientlist = @BlindRecipientlist + ';Bryan.Eddy@aflglobal.com';


	DECLARE @body1 VARCHAR(MAX)
	DECLARE @subject VARCHAR(MAX)
	--DECLARE @query VARCHAR(MAX) = N'SELECT * FROM tempdb..#Results;'
	SET @subject = 'Discrete Jobs Missing Setup Alerts ' + CAST(GETDATE() AS NVARCHAR(50))
	SET @body1 = 'There are  ' + CAST(@numRows AS NVARCHAR(20)) + ' item(s) missing setup information for DJs.  Please review.' +CHAR(13)+CHAR(13)

	DECLARE @tableHTML  NVARCHAR(MAX) ;
	IF @numRows > 0
		BEGIN
	
					SET @tableHTML =
						N'<H1>Missing Setup DJ Report</H1>' +
						N'<H2 span style=''font-size:16.0pt;font-family:"Calibri","sans-serif";color:#EB3814''>Items with the setups below will be unable to schedule.</H2>' +
						--N'<H2 style = ''color: EB3814''>' +
						N'<p>'+@body1+'</p>' +
						N'<p class=MsoNormal><span style=''font-size:11.0pt;font-family:"Calibri","sans-serif";color:#1F497D''>'+
						N'<table border="1">' +
						N'<tr><th>Setup</th><th>Days Missing</th>' +
						N'<th>Item</th><th>Op Seq</th>' +
						N'<th>Job</th><th>Job Released Date</th><th>Dept Code</th></tr>' +
						CAST ( ( SELECT		td=Setup,    '',
											td=DaysMissing, '',
											td=assembly_item, '',
											td=operation_seq_num, '',
											td=wip_entity_name, '', 
											td=date_released, '',
											td = department_code, ''
																
									FROM #FinalResults 
									ORDER BY date_released, DaysMissing
									FOR XML PATH('tr'), TYPE 
						) AS NVARCHAR(MAX) ) +
						N'</table>' ;

		
					EXEC msdb.dbo.sp_send_dbmail 
					@recipients=@ReceipientList,
					--@blind_copy_recipients = 'bryan.eddy@aflglobal.com',
					@subject = @subject,
					@body = @tableHTML,
					@body_format = 'HTML';
		END


END
GO
