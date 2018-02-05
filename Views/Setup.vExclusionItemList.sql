SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






/*
Author:			Bryan Eddy
Date:			12/17/2017
Description:	An exclusion list for PlanetTogether to prevent orders from erroring out during import/refresh
Version:		4
Update:			Exclusion list updated to exclude DJ items missing setups as well
				Refactored query to put old CTE into a view Setup.vMissingSetups


*/

CREATE VIEW	[Setup].[vExclusionItemList]
AS
	

	SELECT DISTINCT AssemblyItemNumber AS ItemNumber--, G.Setup
	FROM Setup.vMissingSetups G CROSS APPLY setup.fn_WhereUsedStdAndDJ(item) K
	UNION 
	SELECT  Item AS ItemNumber--, cteSetupLocation.Setup
	FROM Setup.vMissingSetups
	UNION	
	SELECT G.item_number--,NULL
	FROM dbo.APS_ProductClass_ToExclude_HardCoded K INNER JOIN dbo.Oracle_Items G ON G.product_class = K.ExcludedProductClass



GO
