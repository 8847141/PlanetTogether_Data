SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*
Author:		Bryan Eddy
Date:		5/31/2018
Desc:		Flattened version of the stale materials view
Version:	1
Update:		n/a
*/

CREATE VIEW [Scheduling].[vStaleMaterialsFlat]
as
SELECT DISTINCT FinishedGood, d.Materials, E.Orders
    FROM [Scheduling].[vStaleMaterials]  p1
   CROSS APPLY ( SELECT DISTINCT  Material + ',' 
                     FROM [Scheduling].[vStaleMaterials] p2
                     WHERE p2.FinishedGood = p1.FinishedGood 
                     FOR XML PATH('') )  D ( Materials )
	CROSS APPLY ( SELECT DISTINCT p3.conc_order_number + ',' 
                     FROM [Scheduling].[vStaleMaterials] p3
                     WHERE p3.FinishedGood = p1.FinishedGood
                     FOR XML PATH('') )  E ( Orders )

GO
