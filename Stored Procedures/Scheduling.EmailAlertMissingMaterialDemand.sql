SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
Author:		Bryan Eddy
Date:		5/25/2018
Desc:		Email alert to show missing material demand due to material not referencing correct op sequence
Version:	1
Update:		n/a
*/

CREATE PROCEDURE [Scheduling].[EmailAlertMissingMaterialDemand]
AS
BEGIN
	DECLARE @html nvarchar(MAX),
	@SubjectLine NVARCHAR(1000),
	@ReceipientList NVARCHAR(1000),
	@RowCount INT,
	@qry NVARCHAR(MAX),
	@body1 VARCHAR(MAX)

		SET @ReceipientList = (STUFF((SELECT ';' + UserEmail 
							FROM [NAASPB-PRD04\SQL2014].Premise.dbo.tblConfiguratorUser G  INNER JOIN [NAASPB-PRD04\SQL2014].Premise.users.UserResponsibility  K ON  G.UserID = K.UserID
	  						WHERE K.ResponsibilityID = 21 FOR XML PATH('')),1,1,''))

	SET @qry = 'SELECT item_number,
       comp_item,
       item_seq,
       Bom_Op_Seq,
       Route_Op_Seq,
       inventory_item_status_code,
       wip_entity_name
		FROM [Scheduling].[vMissingMaterialDemand]'

	EXEC sp_executesql @qry
	IF @@ROWCOUNT > 0 
		BEGIN

		SET @body1 = N'<H1>Missing Material Demand Report</H1>' +
				N'<H2 span style=''font-size:16.0pt;font-family:"Calibri","sans-serif";color:#EB3814''>Materials are not assigned to an operation passing into the APS system.</H2>' 
	

			SET @SubjectLine = 'Missing Material Demand' + CAST(GETDATE() AS NVARCHAR(50))
			EXEC Scheduling.usp_QueryToHtmlTable @html = @html OUTPUT,  
			@query =@qry, @orderBy = N'ORDER BY item_number'

			SET @html = @body1 + @html

			EXEC msdb.dbo.sp_send_dbmail 
			@recipients=@ReceipientList,
			--@recipients = 'bryan.eddy@aflglobal.com',
			@blind_copy_recipients = 'bryan.eddy@aflglobal.com',
			@subject = @SubjectLine,
			@body = @html,
			@body_format = 'HTML',
			@query_no_truncate = 1,
			@attach_query_result_as_file = 0;
		END
END

GO
