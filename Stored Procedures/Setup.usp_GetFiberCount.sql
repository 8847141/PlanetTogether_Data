SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





-- =============================================
-- Author:      Bryan Eddy
-- Create date: 8/23/2017
-- Description: Procedure to aggregate the fiber count for all cables
-- =============================================

CREATE PROCEDURE [Setup].[usp_GetFiberCount]
AS

	SET NOCOUNT ON;
BEGIN
	IF OBJECT_ID(N'tempdb..#BomExplode', N'U') IS NOT NULL
	DROP TABLE #BomExplode;
	SELECT E.*
	INTO #BomExplode
	FROM dbo.Oracle_Items G CROSS APPLY dbo.fn_ExplodeBOM(G.item_number) E

	CREATE INDEX iBomXplode ON #BomExplode (comp_item, FinishedGood, ExtendedQuantityPer)

	;WITH cteFiber
	as(
		SELECT FinishedGood,p.comp_item, part, position ,make_buy, ExtendedQuantityPer
		FROM dbo.Oracle_Items G cross apply dbo.usf_SplitString(g.product_class,'.') 
		INNER JOIN #BomExplode P ON P.comp_item = G.item_number
		where  ((part in ('Fiber','Ribbon') AND position = 4)  OR (part ='Bare Ribbon' and position = 5)) and make_buy = 'buy' and p.alternate_designator = 'primary'
	)
	INSERT INTO Setup.ItemAttributes(ItemNumber,FiberCount, FiberMeters)
	SELECT FinishedGood,sum(cast(ExtendedQuantityPer as int)) as FiberCount, SUM(ExtendedQuantityPer) as FiberMeters
	FROM cteFiber
	GROUP BY FinishedGood
	order by FinishedGood

	INSERT INTO Setup.ItemAttributes(ItemNumber,FiberCount,FiberMeters)
	SELECT DISTINCT K.item_number, 0,0
	FROM dbo.Oracle_Items K INNER JOIN dbo.Oracle_BOMs P ON K.item_number = P.item_number
	LEFT JOIN setup.ItemAttributes G ON K.item_number = G.ItemNumber
	WHERE G.ItemNumber  IS NULL AND K.make_buy = 'MAKE'
	ORDER BY item_number


END




GO
