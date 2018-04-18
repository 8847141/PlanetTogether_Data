SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



/*
Author:		Bryan Eddy
Date:		2/2/2018
Desc:		Email alert to notify of DJ's with setups missing
Version:	1
Update:		Initial creation
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
		SELECT DISTINCT Setup, I.assembly_item,I.wip_entity_name, I.date_released,assembly_description, I.department_code
		,MIN(I.date_released) OVER (PARTITION BY Setup) EarliestReleasedDate
		,ROW_NUMBER() OVER (PARTITION BY Setup ORDER BY date_released) RowNumber
			,COUNT(setup) OVER (PARTITION BY Setup) NumberOfJobsAffected
		FROM (
				SELECT DISTINCT Setup, I.assembly_item,I.wip_entity_name, I.date_released  , I.assembly_description, I.department_code
				FROM	Setup.vMissingSetupsDj K INNER JOIN dbo.Oracle_DJ_Routes  I ON I.true_operation_code = K.Setup 
						--INNER JOIN Scheduling.vOracleOrders j ON j.parent_dj_number = i.wip_entity_name
					)  I
	)
	SELECT  G.*
	INTO #Results
	FROM cteJobsMissingSetups G left JOIN Setup.MissingSetups K ON g.Setup = k.Setup
	WHERE G.EarliestReleasedDate = G.date_released AND G.RowNumber = 1

	--Merge missing setups with the MissingSetups table
	MERGE Setup.MissingSetups AS T
	USING #Results s
	ON t.Setup = S.Setup
	WHEN MATCHED THEN
	UPDATE SET T.DateMostRecentAppearance = GETDATE()
	WHEN NOT MATCHED BY TARGET THEN
	INSERT (SETUP) VALUES (setup);

	--Results to populate the email table
	IF OBJECT_ID(N'tempdb..#FinalResults', N'U') IS NOT NULL
	DROP TABLE #FinalResults;
	SELECT DATEDIFF(dd,K.DateCreated,K.DateMostRecentAppearance) DaysMissing, k.DateCreated, k.DateMostRecentAppearance
	,cast(EarliestReleasedDate AS date) EarliestReleasedDate, j.NumberOfJobsAffected, j.department_code, j.wip_entity_name,j.assembly_item
	,J.Setup
	INTO #FinalResults
	FROM setup.MissingSetups K INNER JOIN	#Results J ON K.Setup = J.Setup
	ORDER BY cast(EarliestReleasedDate AS date)--,DaysMissing DESC

	--SELECT *
	--FROM #FinalResults
	--ORDER BY EarliestReleasedDate
		
	--Send Email alert
	DECLARE @numRows int
	DECLARE @Receipientlist varchar(1000)
	DECLARE @BlindRecipientlist varchar(1000)

	SELECT @numRows = count(*) FROM #Results;


	SET @ReceipientList = (STUFF((SELECT ';' + UserEmail 
							FROM [NAASPB-PRD04\SQL2014].premise.dbo.tblConfiguratorUser G  INNER JOIN [NAASPB-PRD04\SQL2014].premise.users.UserResponsibility  K ON  G.UserID = K.UserID
  							WHERE K.ResponsibilityID IN (1,16) FOR XML PATH('')),1,1,''))

	SET @ReceipientList = @ReceipientList +';'+ (STUFF((SELECT ';' + UserEmail 
							FROM [NAASPB-PRD04\SQL2014].premise.dbo.tblConfiguratorUser G  INNER JOIN [NAASPB-PRD04\SQL2014].Premise.users.UserResponsibility  K ON  G.UserID = K.UserID
  							WHERE K.ResponsibilityID = 4 FOR XML PATH('')),1,1,''))


	SET @BlindRecipientlist = @BlindRecipientlist + ';Bryan.Eddy@aflglobal.com';


	DECLARE @body1 VARCHAR(MAX)
	DECLARE @subject VARCHAR(MAX)
	--DECLARE @query VARCHAR(MAX) = N'SELECT * FROM tempdb..#Results;'
	SET @subject = 'Discrete Jobs Missing Setup Alerts' 
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
						N'<th># Jobs Affected</th><th>Item</th>' +
						N'<th>Job</th><th>Earliest Job Date</th><th>Dept Code</th></tr>' +
						CAST ( ( SELECT		td=Setup,    '',
											td=DaysMissing, '',
											td=NumberOfJobsAffected, ''	,
											td=assembly_item, '',
											td=wip_entity_name, '', 
											td=EarliestReleasedDate, '',
											td = department_code, ''
																
									FROM #FinalResults 
									ORDER BY EarliestReleasedDate, DaysMissing
									FOR XML PATH('tr'), TYPE 
						) AS NVARCHAR(MAX) ) +
						N'</table>' ;

		
					EXEC msdb.dbo.sp_send_dbmail 
					@recipients=@ReceipientList,
					--@recipients = 'bryan.eddy@aflglobal.com',
					--@blind_copy_recipients =  @BlindRecipientlist, --@ReceipientList
					@blind_copy_recipients = 'bryan.eddy@aflglobal.com',
					@subject = @subject,
					@body = @tableHTML,
					@body_format = 'HTML';
		END


END
GO
