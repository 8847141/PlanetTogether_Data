SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Bryan Eddy
-- ALTER date: 6/12/17
-- Description:	Send email of missing line speeds to Process Engineers
-- Version:		1
-- Update:		Initial creation.  Migrate script from NAASPB-PRD04\SQL2014
--				Not all oracle data is available for implementation.   Need live BOMs, Routes, and orders.
-- =============================================
CREATE PROCEDURE [Scheduling].[usp_EmailSchedulingMissingLineSpeed]

AS



SET NOCOUNT ON;
EXECUTE AS USER = 'dbo' 




/*******************************************************************
First query is to determine what setups are either not present in the setup database or
what setups are shutoff in the setup db that is in active items.
All setups in query following are in activec items.
*********************************************************************
**********************************************************************/


/*******************************************************************
Query is to determine what items have no run speed in the setup db.
*********************************************************************
**********************************************************************/


	
	IF OBJECT_ID(N'tempdb..#LineSpeeds', N'U') IS NOT NULL
	DROP TABLE #LineSpeeds;

	SELECT Item, SETUP,MachineName, MachineID
	INTO #LineSpeeds
	FROM Setup.vSetupLineSpeed

CREATE NONCLUSTERED INDEX Temp_LineSpeed_Index ON #LineSpeeds
(
	Setup ASC

)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]




	IF OBJECT_ID(N'tempdb..#SetupLocation', N'U') IS NOT NULL
	DROP TABLE #SetupLocation;

	SELECT    DISTINCT 
		G.item_number Item, 
		true_operation_code Setup,
		g.alternate_routing_designator,
		k.MachineName,
		g.department_code
	INTO #SetupLocation 
	--SELECT COUNT(*)
	FROM #LineSpeeds K RIGHT JOIN dbo.Oracle_Routes G ON G.true_operation_code = K.Setup 
	LEFT JOIN Setup.DepartmentIndicator I ON I.department_code = G.department_code
	WHERE I.department_code IS NULL AND G.true_operation_seq_num IS NOT NULL --AND K.MachineName IS null


--	CREATE NONCLUSTERED INDEX TEMP_Index ON #SetupLocation
--(
--	Item ASC
--)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

CREATE NONCLUSTERED INDEX TEMP_Index
ON [dbo].[#SetupLocation] ([MachineName],[Item])
INCLUDE ([Setup],[alternate_routing_designator],[department_code])


/*******************************************************************
Determine what items and sub-items are located in open orders.
*********************************************************************
**********************************************************************/


--Check if any open item requests need commercial approval
IF OBJECT_ID(N'tempdb..#cteOrders', N'U') IS NOT NULL
DROP TABLE #cteOrders;

WITH 
	cteOrders(ItemNumber, ItemDesc,ScheduleDate)
	as
	(
		SELECT distinct assembly_item, item_description, need_by_date
		FROM(
			SELECT G.assembly_item, K.item_description, MIN(G.need_by_date) OVER (PARTITION BY assembly_item) Max_Schedule_Date,need_by_date
			FROM dbo.Oracle_Orders G INNER JOIN dbo.Oracle_Items K ON K.item_number = G.assembly_item
			--WHERE [Job Status] NOT IN  ('CLOSED', 'COMPLETE','Cancelled')
			)X
		WHERE Max_Schedule_Date = need_by_date
	)
SELECT * 
INTO #cteOrders
FROM cteOrders


IF OBJECT_ID(N'tempdb..#Results', N'U') IS NOT NULL
DROP TABLE #Results;
SELECT FinishedGood,Item,Item_Description ItemDesc, ScheduleDate, X.item_number, Setup, alternate_routing_designator,department_code, X.MachineName
INTO #Results
FROM 
	(	
	SELECT DISTINCT FinishedGood,K.Item,Item_Description, ScheduleDate, B.item_number, Setup, Make_Buy, k.alternate_routing_designator, K.department_code, MachineName
	, MIN(ScheduleDate) OVER (PARTITION BY Setup) Max_SechuduleDate, MAX(Item) OVER (PARTITION BY Setup) Max_Item--, ROW_NUMBER() OVER (PARTITION BY Setup ORDER BY setup,G.FinishedGood) RowNumber
	FROM #cteOrders CROSS APPLY fn_ExplodeBOM(ItemNumber) G
	INNER JOIN #SetupLocation K ON G.item_number = K.Item
	INNER JOIN dbo.Oracle_Items B ON B.item_number = K.ITEM 
	WHERE B.Make_Buy = 'MAKE' AND K.MachineName IS NULL  AND  B.product_class NOT LIKE '%wtc%' 
	) X 
WHERE X.Max_SechuduleDate = x.ScheduleDate and x.item = x.Max_Item --AND X.RowNumber = 1
ORDER BY ScheduleDate

SELECT DISTINCT k.AssemblyItemNumber, component
FROM (SELECT DISTINCT Item FROM #Results) x CROSS APPLY setup.fn_whereused(x.Item) k

SELECT * 
FROM #Results


--Run around 8:30am everyday
DECLARE @numRows int
DECLARE @Receipientlist varchar(1000)
DECLARE @BlindRecipientlist varchar(1000)

SELECT @numRows = count(*) FROM #Results;


SET @ReceipientList = (STUFF((SELECT ';' + UserEmail 
						FROM [NAASPB-PRD04\SQL2014].Premise.dbo.tblConfiguratorUser G  INNER JOIN [NAASPB-PRD04\SQL2014].Premise.users.UserResponsibility  K ON  G.UserID = K.UserID
  						WHERE K.ResponsibilityID = 1 FOR XML PATH('')),1,1,''))

SET @BlindRecipientlist = (STUFF((SELECT ';' + UserEmail 
						FROM [NAASPB-PRD04\SQL2014].Premise.dbo.tblConfiguratorUser G  INNER JOIN [NAASPB-PRD04\SQL2014].Premise.users.UserResponsibility  K ON  G.UserID = K.UserID
  						WHERE K.ResponsibilityID = 4 FOR XML PATH('')),1,1,''))

SET @BlindRecipientlist = @BlindRecipientlist + ';Bryan.Eddy@aflglobal.com';


DECLARE @body1 VARCHAR(MAX)
DECLARE @subject VARCHAR(MAX)
--DECLARE @query VARCHAR(MAX) = N'SELECT * FROM tempdb..#Results;'
SET @subject = 'Missing Setup Line Speeds for Open Orders' 
SET @body1 = 'There are  ' + CAST(@numRows AS NVARCHAR(20)) + ' items that are missing setup line speeds with open orders.  Please review.' +CHAR(13)+CHAR(13)

DECLARE @tableHTML  NVARCHAR(MAX) ;
IF @numRows > 0
BEGIN
	
			SET @tableHTML =
				N'<H1>Missing Setup Line Speed Report</H1>' +
				N'<H2 span style=''font-size:16.0pt;font-family:"Calibri","sans-serif";color:#EB3814''>Items with the setups below will be unable to schedule.</H2>' +
				--N'<H2 style = ''color: EB3814''>' +
				N'<p>'+@body1+'</p>' +
				N'<p class=MsoNormal><span style=''font-size:11.0pt;font-family:"Calibri","sans-serif";color:#1F497D''>'+
				N'<table border="1">' +
				N'<tr><th>FinishedGood</th><th>Item</th>' +
				N'<th>ItemDesc</th><th>ScheduleDate</th>' +
				N'<th>Setup</th><th>Atlernate</th><th>DepartmentCode</th></tr>' +
				CAST ( ( SELECT		td=FinishedGood,    '',
									td=Item, '',
									td=ItemDesc, '', 
									td=ScheduleDate, '',
									td=Setup, '', 
									td=alternate_routing_designator, '',
									td=department_code, ''
									
							FROM #Results 
						  FOR XML PATH('tr'), TYPE 
				) AS NVARCHAR(MAX) ) +
				N'</table>' ;
			--SET @tableHTML =
			--	N'<H1>Premise Cut Sheet Approval</H1>' +
			--	N'<p>'+@body1+'</p>' +
			--	N'</table>' 
		
			EXEC msdb.dbo.sp_send_dbmail 
			@recipients=@ReceipientList,
			--@recipients = 'bryan.eddy@aflglobal.com',
			@blind_copy_recipients =  @BlindRecipientlist, --@ReceipientList
			@subject = @subject,
			@body = @tableHTML,
			@body_format = 'HTML';
END


GO
