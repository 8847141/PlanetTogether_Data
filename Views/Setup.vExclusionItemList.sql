SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








/*
Author:			Bryan Eddy
Date:			12/17/2017
Description:	An exclusion list for PlanetTogether to prevent orders from erroring out during import/refresh
Version:		5
Update:			Update exclusion list to not show items with DJ's



*/

CREATE VIEW	[Setup].[vExclusionItemList]
AS
	
WITH cteExcludedItems
AS(
	SELECT DISTINCT AssemblyItemNumber AS ItemNumber--, G.Setup
	FROM Setup.vMissingSetups G CROSS APPLY setup.fn_WhereUsed(item) K
	UNION 
	SELECT  Item AS ItemNumber--, cteSetupLocation.Setup
	FROM Setup.vMissingSetups
	UNION	
	SELECT G.item_number--,NULL
	FROM dbo.APS_ProductClass_ToExclude_HardCoded K INNER JOIN dbo.Oracle_Items G ON G.product_class = K.ExcludedProductClass
)
SELECT K.*, I.inventory_item_status_code, I.product_class
FROM cteExcludedItems k LEFT JOIN dbo.Oracle_Items I ON I.item_number = K.ItemNumber


GO
