SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



/*
Author:		Bryan Eddy
Date:		6/7/2018
Desc:		Flattened version of the stale materials view with information by buyer
Version:	1
Update:		n/a
*/

CREATE VIEW [Scheduling].[vStaleMaterialsFlatByBuyer]
AS
SELECT DISTINCT buyer,Material, D.FinishedGood,E.Orders
    FROM [Scheduling].[vStaleMaterials]  p1
   CROSS APPLY ( SELECT DISTINCT  p2.FinishedGood + ',' 
                     FROM [Scheduling].[vStaleMaterials] p2
                     WHERE p2.Material = p1.Material
                     FOR XML PATH('') )  D ( FinishedGood )
	CROSS APPLY ( SELECT DISTINCT p3.conc_order_number + ',' 
                     FROM [Scheduling].[vStaleMaterials] p3
                     WHERE p3.Material= p1.Material
                     FOR XML PATH('') )  E ( Orders )

GO
