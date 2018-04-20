SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Bryan Eddy
-- ALTER date: 6/12/17
-- Description:	Send email of missing line speeds to Process Engineers
-- Version:		9
-- Update:		Removed the Q & K operations from being filtered.  Changed to filtering out "INSPEC" operations.
-- =============================================
CREATE PROC [Scheduling].[usp_EmailSchedulingMissingLineSpeed]

AS



SET NOCOUNT ON;


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

	
	IF OBJECT_ID(N'tempdb..#SetupLocation', N'U') IS NOT NULL
	DROP TABLE #SetupLocation;
	WITH cteMissingSetups
	AS(
		--SELECT DISTINCT K.AssemblyItemNumber AS Item,K.Component AS Component, G.Setup, G.department_code,G.alternate_routing_designator
		--FROM Setup.vMissingSetups G CROSS APPLY setup.fn_WhereUsed(item) K
		--UNION 
		SELECT  Item ,Item AS Component, Setup, department_code, alternate_routing_designator
		FROM Setup.vMissingSetups
	)
	SELECT *
	INTO #SetupLocation 
	FROM cteMissingSetups
    


/*******************************************************************
Determine what items and sub-items are located in open orders.
*********************************************************************
**********************************************************************/


	
	IF OBJECT_ID(N'tempdb..#OpenOrders', N'U') IS NOT NULL
	DROP TABLE #OpenOrders;
	WITH cteOrders
	AS(
		SELECT DISTINCT [Item Number] ItemNumber, [Item Description] ItemDesc,[Schedule Date] need_by_date, [Sales Order] SalesOrder, [Line No] SalesOrderLineNumber
		FROM [NAASPB-PRD04\SQL2014].Premise.dbo.AFLPRD_ORDDTLREPT_UPLOAD_CAB
		UNION
		SELECT DISTINCT assembly_item, i.item_description, need_by_date, order_number, line_number
		FROM Scheduling.vOracleOrders INNER JOIN dbo.Oracle_Items i ON i.item_number = assembly_item
	)
	SELECT *
	INTO #OpenOrders
	FROM cteOrders



--Check if any open item requests need commercial approval
IF OBJECT_ID(N'tempdb..#Results', N'U') IS NOT NULL
DROP TABLE #Results;
;WITH cteMissingSetupOrders
as(	
	SELECT DISTINCT FinishedGood,K.Item,i.ItemDesc, need_by_date, B.item_number, Setup, Make_Buy, alternate_routing_designator AS PrimaryAlt
	, K.department_code, i.SalesOrder,SalesOrderLineNumber
	, MIN(need_by_date) OVER (PARTITION BY Setup) Max_SechuduleDate--, ROW_NUMBER() OVER (PARTITION BY Setup ORDER BY setup,G.FinishedGood) RowNumber
	FROM #OpenOrders i CROSS APPLY fn_ExplodeBOM(i.ItemNumber) G
	INNER JOIN #SetupLocation K ON g.item_number = K.Item
	INNER JOIN dbo.Oracle_Items B ON B.item_number = K.ITEM 
	WHERE B.Make_Buy = 'MAKE'  and left(ITEM,3) NOT in ('WTC','DNT')
	and LEFT(setup,1) not in ('O','I') and setup not in ('R696','R093','PQC','pk01','SK01') AND setup NOT LIKE 'm00[4-9]'
	AND K.department_code NOT LIKE '%INSPEC%'
	) 
	,cteConsolidatedMissingSetupOrders
	AS(
		SELECT *, COUNT(SalesOrder) OVER (PARTITION BY cteMissingSetupOrders.Setup) SoLinesMissingSetups--Determine the amount of sales order affected by missing setups
		FROM cteMissingSetupOrders
		--WHERE	
	)
SELECT DISTINCT FinishedGood,Item,ItemDesc, CAST(need_by_date AS DATE) need_by_date, item_number, Setup, PrimaryAlt,department_code, SoLinesMissingSetups
INTO #Results
FROM cteConsolidatedMissingSetupOrders
WHERE Max_SechuduleDate = need_by_date

--SELECT *
--FROM #Results


--Add new missing setups
INSERT INTO setup.MissingSetups(Setup)
SELECT DISTINCT G.Setup
FROM #Results G LEFT JOIN setup.MissingSetups K ON K.Setup = G.Setup
WHERE K.Setup IS NULL

--Update existing records with the most recent date of the apperance
UPDATE K
SET K.DateMostRecentAppearance = GETDATE()
FROM setup.MissingSetups K INNER JOIN	#Results J ON K.Setup = J.Setup

--Results to populate the email table
IF OBJECT_ID(N'tempdb..#FinalResults', N'U') IS NOT NULL
DROP TABLE #FinalResults;
SELECT J.*,DATEDIFF(dd,K.DateCreated,K.DateMostRecentAppearance) DaysMissing--, ROW_NUMBER() OVER (PARTITION BY J.Setup, J.need_by_date
INTO #FinalResults
FROM setup.MissingSetups K INNER JOIN	#Results J ON K.Setup = J.Setup
ORDER BY DaysMissing DESC

--SELECT *
--FROM #FinalResults

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

SET @BlindRecipientlist = 'Bryan.Eddy@aflglobal.com';


DECLARE @body1 VARCHAR(MAX)
DECLARE @subject VARCHAR(MAX)
DECLARE @query VARCHAR(MAX) = N'SELECT * FROM tempdb..#Results;'
SET @subject = 'Missing Setup Line Speeds for Open Orders ' + CAST(GETDATE() AS NVARCHAR)
SET @body1 = 'There are  ' + CAST(@numRows AS NVARCHAR) + ' items that are missing setup line speeds with open orders.  Please review.' +CHAR(13)+CHAR(13)

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
				N'<tr>' +
				'<th>Days Missing</th><th># Affected SO Lines</th>' +
				'<th>FinishedGood</th><th>Item</th>' +
				N'<th>ItemDesc</th><th>Need By Date</th>' +
				N'<th>Setup</th><th>Atlernate</th><th>DepartmentCode</th>'+
				'</tr>' +
				CAST ( ( SELECT		td=DaysMissing, '',
									td=SoLinesMissingSetups, '',
									td=FinishedGood,    '',
									td=Item, '',
									td=ItemDesc, '', 
									td=need_by_date, '',
									td=Setup, '', 
									td=PrimaryAlt, '',
									td=department_code
									
							FROM #FinalResults 
						  FOR XML PATH('tr'), TYPE 
				) AS NVARCHAR(MAX) ) +
				N'</table>' ;

		
			EXEC msdb.dbo.sp_send_dbmail 
			@recipients=@ReceipientList,
			--@recipients = 'bryan.eddy@aflglobal.com;',
			@blind_copy_recipients =  @BlindRecipientlist, --@ReceipientList
			@subject = @subject,
			@body = @tableHTML,
			@body_format = 'HTML';
END


GO
