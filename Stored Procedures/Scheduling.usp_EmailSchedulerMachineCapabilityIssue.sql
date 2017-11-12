SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Bryan Edy
-- Create date: 10/31/2017
-- Description:	Email notification to scheduling when an item is set to pass by scheduler but is inactive in the Setup data
-- =============================================
CREATE PROCEDURE [Scheduling].[usp_EmailSchedulerMachineCapabilityIssue] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

DECLARE @numRows int
DECLARE @Receipientlist varchar(1000)

/*Chec what can schedule against active setups being passed over.  If a setup is being passed as active, but doesn't show up on any machine 
then this procedure will notify the scheduler*/
IF OBJECT_ID(N'tempdb..#NotSchedulingSetups', N'U') IS NOT NULL
DROP TABLE #NotSchedulingSetups;
WITH cteSchedulingActive  --Determine what can schedule
AS(
	SELECT DISTINCT G.SETUP
	FROM setup.[vSetupStatus] K INNER JOIN Scheduling.MachineCapabilityScheduler G ON G.SETUP = K.Setup AND G.MachineID = K.Machineid
	WHERE G.ActiveScheduling = 1
	)
SELECT DISTINCT K.Setup AS Setup  
INTO #NotSchedulingSetups
FROM setup.[vSetupStatus] K LEFT JOIN cteSchedulingActive G ON G.Setup = K.Setup
WHERE G.Setup IS NULL AND k.Machineid IS NOT NULL AND K.ActiveSetup = 1

--SELECT * FROM #NotSchedulingSetups

IF OBJECT_ID(N'tempdb..#Results', N'U') IS NOT NULL
DROP TABLE #Results;
SELECT DISTINCT K.MachineID,K.Setup, k.ActiveScheduling, G.ActiveSetup, K.ActiveStatusChangedBy, K.ActiveStatusChangedDate, P.MachineName
INTO #Results
FROM #NotSchedulingSetups I INNER JOIN setup.vSetupStatus G ON G.Setup = I.Setup
INNER JOIN Scheduling.MachineCapabilityScheduler K ON K.SETUP = I.Setup
INNER JOIN setup.MachineNames P ON P.MachineID = K.MachineID
WHERE G.ActiveSetup = 1

--SELECT *FROM #Results

SELECT @numRows = COUNT(*) FROM #Results



--SET @ReceipientList = (STUFF((SELECT ';' + UserEmail 
--						FROM tblConfiguratorUser G  INNER JOIN users.UserResponsibility  K ON  G.UserID = K.UserID
--  						WHERE K.ResponsibilityID = 5 FOR XML PATH('')),1,1,''))
--						--WHERE g.UserTypeID = 1 FOR XML PATH('')),1,1,''))

DECLARE @body1 VARCHAR(MAX)
DECLARE @subject VARCHAR(MAX)
DECLARE @query VARCHAR(MAX) = N'SELECT * FROM tempdb..#Results;'
SET @subject = 'Inactive Setups' 
SET @body1 = 'There are  ' + CAST(@numRows AS NVARCHAR) + ' setup(s) active from Setup System that are not scheduling due to Scheduling Active flag.' +CHAR(13)+CHAR(13)

DECLARE @tableHTML  NVARCHAR(MAX) ;
IF @numRows > 0

	BEGIN
	
				SET @tableHTML =
					N'<H1>Inactive setups with active scheduling capability.</H1>' +
					N'<p>'+@body1+'</p>' +
					N'<p class=MsoNormal><span style=''font-size:11.0pt;font-family:"Calibri","sans-serif";color:#1F497D''>'+
					N'<table border="1">' +
					N'<tr><th>Setup</th><th>MachineID</th><th>Machine</th>' +
					N'<th>Active Setup</th><th>Active Scheduling</th>'+
					N'<th>Altered By</th><th>Date Altered</th>'+
					'</tr>' +
					CAST ( ( SELECT		td=Setup,       '',
										td=MachineID, '',
										td=MachineName, '',
										td=ActiveSetup, '',
										td=ActiveScheduling, '',
										td=ActiveStatusChangedBy, '',
										td=ActiveStatusChangedDate,''
								FROM #Results 
							  FOR XML PATH('tr'), TYPE 
					) AS NVARCHAR(MAX) ) +
					N'</table>' ;
				--SET @tableHTML =
				--	N'<H1>Premise Cut Sheet Approval</H1>' +
				--	N'<p>'+@body1+'</p>' +
				--	N'</table>' ;
		
				EXEC msdb.dbo.sp_send_dbmail 
				@recipients='Jeff.Gilfillan@aflglobal.com',
				--@recipients='Bryan.Eddy@aflglobal.com',
				@blind_copy_recipients = 'Bryan.Eddy@aflglobal.com',
				@subject = @subject,
				@body = @tableHTML,
				@body_format = 'HTML';



	END
END


GO
