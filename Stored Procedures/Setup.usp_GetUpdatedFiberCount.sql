SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:      Bryan Eddy
-- Create date: 8/23/2017
-- Description: Procedure to update the fiber count of cables with open orders
-- =============================================

CREATE PROCEDURE [Setup].[usp_GetUpdatedFiberCount]
AS

	SET NOCOUNT ON;
BEGIN
	
	IF OBJECT_ID(N'tempdb..#OrderItems', N'U') IS NOT NULL
	DROP TABLE #OrderItems;
	SELECT DISTINCT assembly_item 
	INTO #OrderItems
	FROM PlanetTogether_Data_Test.dbo.Oracle_Orders

	INSERT INTO #OrderItems
	SELECT DISTINCT G.item_number
	FROM dbo.Oracle_Items G LEFT JOIN #OrderItems K ON G.item_number = K.assembly_item
	LEFT JOIN SETUP.ItemAttributes P ON P.ItemNumber = G.item_number
	INNER JOIN Oracle_BOMs I ON I.item_number = G.item_number
	WHERE K.assembly_item IS NULL AND P.ItemNumber IS NULL

	DELETE Setup.ItemAttributes 
	FROM Setup.ItemAttributes G INNER JOIN #OrderItems K ON G.ItemNumber = K.assembly_item

	INSERT INTO #OrderItems(assembly_item)
	SELECT DISTINCT g.item_number FROM Setup.ItemAttributes K RIGHT JOIN dbo.Oracle_Items G ON K.ItemNumber = G.item_number
	LEFT JOIN #OrderItems P ON P.assembly_item = G.item_number
	WHERE K.ItemNumber IS NULL and g.make_buy = 'make' AND P.assembly_item is null


	IF OBJECT_ID(N'tempdb..#BomExplode', N'U') IS NOT NULL
	DROP TABLE #BomExplode;
	SELECT E.*
	INTO #BomExplode 
	FROM #OrderItems G CROSS APPLY dbo.fn_ExplodeBOM(G.assembly_item) E



	;WITH cteFiber
	as(
		SELECT FinishedGood,p.comp_item, part, position ,make_buy, ExtendedQuantityPer
		FROM dbo.Oracle_Items G cross apply dbo.usf_SplitString(g.product_class,'.') 
		INNER JOIN #BomExplode P ON P.comp_item = G.item_number
		where  ((part in ('Fiber','Ribbon') AND position = 4)  OR (part ='Bare Ribbon' and position = 5)) and make_buy = 'buy' and p.alternate_designator = 'primary'
	)
	INSERT INTO Setup.ItemAttributes(ItemNumber,FiberCount, FiberMeters)
	SELECT FinishedGood,sum(cast(ExtendedQuantityPer as int)) as FiberCount,sum(ExtendedQuantityPer)
	FROM cteFiber
	GROUP BY FinishedGood


	INSERT INTO Setup.ItemAttributes(ItemNumber,FiberCount,FiberMeters)
	SELECT DISTINCT K.assembly_item, 0,0
	FROM #OrderItems K INNER JOIN dbo.Oracle_BOMs P ON K.assembly_item = P.item_number
	LEFT JOIN setup.ItemAttributes G ON K.assembly_item = G.ItemNumber
	WHERE G.ItemNumber  IS NULL 
	ORDER BY assembly_item


END



GO
