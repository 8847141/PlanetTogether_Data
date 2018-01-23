SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





/*
Author:			Bryan Eddy
Date:			12/17/2017
Description:	Shows orders lines for excluded items
Version:		1
Update:			NONE


*/

CREATE VIEW	[Setup].[vExcludedOrders]
AS

SELECT DISTINCT K.order_number, K.line_number, G.ItemNumber, K.order_status, K.customer_name, K.customer_number
FROM Setup.vExclusionItemList G INNER JOIN dbo.Oracle_Orders K ON K.assembly_item = G.ItemNumber



GO
