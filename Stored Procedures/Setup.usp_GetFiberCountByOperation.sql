SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




/*
-- =============================================
-- Author:      Bryan Eddy
-- Create date: 11/15/2017
-- Description: Procedure to aggregate the fiber count for all cables by operation
-- Version: 5
-- Update:	Added query to insert items missing from Setup.ItemFiberCountByOperation table.
			Added query to insert make items missing from the table with an inspection step
-- =============================================

*/

CREATE PROCEDURE [Setup].[usp_GetFiberCountByOperation]

@RunType INT
AS


	SET NOCOUNT ON;
BEGIN
 
		DECLARE @ErrorNumber INT = ERROR_NUMBER();
		DECLARE @ErrorLine INT = ERROR_LINE();



	BEGIN TRY
		BEGIN TRAN
		DECLARE @sql NVARCHAR(MAX);

	
				IF OBJECT_ID(N'tempdb..##BomExplode', N'U') IS NOT NULL
				DROP TABLE ##BomExplode;

				--DECLARE @RunType INT;
				--SET @RunType = 2

				--Run type 1 updates/inserts all item BOM's into dataset
				IF @RunType = 1
					BEGIN
						
						SET @sql = 'SELECT E.*
						INTO ##BomExplode
						FROM dbo.Oracle_Items G CROSS APPLY dbo.fn_ExplodeBOM(G.item_number) E
						'--WHERE g.item_number in (''RD2016-0040'',''DNO-9671'',''DNO-1558'')'
					END
				ELSE --Else update only open order items to greatly reduce the time to run procedure
					BEGIN
						SET @sql = 'SELECT X.* 
						INTO ##BomExplode
						FROM (
							SELECT e.*
							FROM (SELECT distinct assembly_item FROM dbo.Oracle_Orders) G CROSS APPLY dbo.fn_ExplodeBOM(G.assembly_item) E
							UNION
							SELECT e.* 
							FROM (SELECT distinct E.item_number 
									FROM dbo.Oracle_Items E left JOIN SETUP.ItemFiberCountByOperation I ON I.ItemNumber = E.item_number
									WHERE I.ItemNumber IS NULL AND E.make_buy =''make'' ) G CROSS APPLY dbo.fn_ExplodeBOM(G.item_number) E
								)X
						'--WHERE G.assembly_item = ''DNO-11046'''
					END


				EXEC(@sql)

				CREATE INDEX iBomXplode ON ##BomExplode (comp_item, FinishedGood, ExtendedQuantityPer)

				--Explode all BOM's from the previous query and aggregate the fiber count
				IF OBJECT_ID(N'tempdb..#FiberCount', N'U') IS NOT NULL
				DROP TABLE #FiberCount;
				;WITH cteFiber
				AS(
					SELECT FinishedGood,p.comp_item, part, position ,make_buy, ExtendedQuantityPer, p.FinishedGoodOpSeq, P.alternate_designator
					FROM dbo.Oracle_Items G CROSS APPLY dbo.usf_SplitString(g.product_class,'.')  
					INNER JOIN ##BomExplode P ON P.comp_item = G.item_number
					WHERE  ((part IN ('Fiber','Ribbon') AND position = 4)  OR (part ='Bare Ribbon' AND position = 5)) AND make_buy = 'buy' --AND p.alternate_designator = 'primary'
				),
				cteFiberCount
				AS(

				SELECT FinishedGood,SUM(CAST(ExtendedQuantityPer AS INT)) AS FiberCount, SUM(ExtendedQuantityPer) AS FiberMeters,cteFiber.FinishedGoodOpSeq,cteFiber.alternate_designator
				FROM cteFiber
				GROUP BY FinishedGood,cteFiber.FinishedGoodOpSeq,alternate_designator
					)
				SELECT k.FinishedGood, k.FinishedGoodOpSeq,alternate_designator,SUM(k.FiberCount) OVER (PARTITION BY FinishedGood,alternate_designator ORDER BY  alternate_designator,FinishedGoodOpSeq,FinishedGoodOpSeq  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW ) FiberCount
				INTO #FiberCount
				FROM cteFiberCount K

				CREATE INDEX IX_FiberCount ON #FiberCount (FinishedGood, FinishedGoodOpSeq, alternate_designator)


				--Remove any duplicates found in the #FiberCount and assign the fiber count to the appropriate operation
				IF OBJECT_ID(N'tempdb..#FiberCountByOp', N'U') IS NOT NULL
				DROP TABLE #FiberCountByOp;
				;WITH cteFiberCountByOp
				AS(
				SELECT DISTINCT G.true_operation_code, J.FiberCount, G.item_number, G.department_code, J.alternate_designator,FinishedGoodOpSeq,true_operation_seq_num
				, MIN(G.true_operation_seq_num) OVER (PARTITION BY J.FiberCount, G.item_number, J.alternate_designator, FinishedGoodOpSeq) Min_true_operation_seq_num
				FROM dbo.Oracle_Routes G 
				INNER JOIN #FiberCount J ON J.alternate_designator = G.alternate_routing_designator AND J.FinishedGood = G.item_number AND G.operation_seq_num >= j.FinishedGoodOpSeq
				INNER JOIN Setup.DepartmentIndicator B ON B.department_code = G.department_code AND g.pass_to_aps = 'y'
				)
				,cteUniqueFiberCountByOp
				AS(
					SELECT item_number,cteFiberCountByOp.true_operation_code,cteFiberCountByOp.FiberCount,alternate_designator, cteFiberCountByOp.true_operation_seq_num, cteFiberCountByOp.department_code
					,ROW_NUMBER() OVER (PARTITION BY item_number,cteFiberCountByOp.true_operation_code,alternate_designator ORDER BY cteFiberCountByOp.FiberCount DESC) RowNumber
					FROM cteFiberCountByOp INNER JOIN Setup.DepartmentIndicator B ON B.department_code = cteFiberCountByOp.department_code
				)
				SELECT G.item_number, G.true_operation_code, G.FiberCount, G.alternate_designator, G.RowNumber
				INTO #FiberCountByOp
				FROM cteUniqueFiberCountByOp G
				WHERE RowNumber = 1 AND G.true_operation_code IS NOT NULL

                
				--Merge data set into setup.ItemFiberCountByOperation for fiber count
				MERGE setup.ItemFiberCountByOperation AS Target
				USING (
						SELECT item_number, true_operation_code, FiberCount, alternate_designator 
						FROM #FiberCountByOp
						) AS Source ON (Source.item_number = Target.ItemNumber AND Source.true_operation_code = Target.TrueOperationCode
						AND Target.PrimaryAlternate = Source.alternate_designator)
				WHEN MATCHED THEN
					UPDATE SET Target.FiberCount = Source.FiberCount
				WHEN NOT MATCHED BY TARGET THEN
					INSERT (ItemNumber, TrueOperationCode, FiberCount, PrimaryAlternate)
					VALUES	(Source.item_number, Source.true_operation_code, Source.FiberCount, Source.alternate_designator);
				--OUTPUT $action, Inserted.*, Deleted.*; 


				IF OBJECT_ID(N'tempdb..##BomExplode', N'U') IS NOT NULL
				DROP TABLE ##BomExplode;
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;

 
		PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
		PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
		THROW;
	END CATCH

	--Insert any missing make item's with an inspection step
		BEGIN TRY
		BEGIN TRAN
			INSERT INTO Setup.ItemFiberCountByOperation
			(
				ItemNumber,
				TrueOperationCode,
				PrimaryAlternate,
				FiberCount
			)
			SELECT DISTINCT G.item_number, G.operation_code, G.alternate_routing_designator, 0
			FROM Setup.ItemFiberCountByOperation k RIGHT JOIN dbo.Oracle_Routes G
			 ON K.ItemNumber = G.item_number AND G.operation_code = K.TrueOperationCode AND k.PrimaryAlternate = G.alternate_routing_designator
			INNER JOIN Setup.DepartmentIndicator i ON i.department_code = g.department_code
			WHERE K.ItemNumber IS NULL AND G.pass_to_aps = 'y' --AND G.item_number = 'DNO-9269'
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;

 
		PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
		PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
		THROW;
	END CATCH

			--Add any missing items with a QC step with the fiber count of 0
	BEGIN TRY
		BEGIN TRAN
			MERGE setup.ItemFiberCountByOperation AS Target
			USING (
					SELECT DISTINCT	K.item_number, A.operation_code, A.alternate_routing_designator, 0 AS FiberCount
					FROM dbo.Oracle_Items K LEFT JOIN Setup.ItemFiberCountByOperation G ON K.item_number = G.ItemNumber
					LEFT JOIN dbo.Oracle_Routes	A ON A.item_number = K.item_number 
					INNER JOIN Setup.DepartmentIndicator B ON B.department_code = A.department_code
					WHERE make_buy  = 'BUY' AND G.ItemNumber IS NULL AND A.pass_to_aps = 'y'
				) AS Source ON (Source.item_number = Target.ItemNumber AND Source.operation_code = Target.TrueOperationCode
					AND Target.PrimaryAlternate = Source.alternate_routing_designator)
			WHEN MATCHED THEN
				UPDATE SET Target.FiberCount = Source.FiberCount
			WHEN NOT MATCHED BY TARGET THEN
				INSERT (ItemNumber, TrueOperationCode, FiberCount, PrimaryAlternate)
				VALUES	(Source.item_number, Source.operation_code, Source.FiberCount, Source.alternate_routing_designator);
			--OUTPUT $action, Inserted.*, Deleted.*; 
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;

 
		PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
		PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
		THROW;
	END CATCH


	--Update any fiber count that is 0 and has a fiber count product category > 0
	BEGIN TRY
		BEGIN TRAN
			;WITH cteZeroFiberCount
			AS(
				SELECT G.ItemNumber, k.TrueOperationCode, k.PrimaryAlternate,CategoryName, k.ItemFiberCountByOp_ID
				FROM Setup.ItemFiberCountByOperation K INNER JOIN [NAASPB-PRD04\SQL2014].Premise.dbo.AFLPRD_INVItmCatg_CAB G ON K.ItemNumber = G.ItemNumber
				WHERE FiberCount = 0 AND G.CategorySetName LIKE '%FIBER COUNT%' --AND ISNUMERIC(G.CategoryName) = 1

			)
			UPDATE K
			SET FiberCount = X.FiberCount
			FROM(
				SELECT SUM(CAST(cteZeroFiberCount.CategoryName AS INT)) FiberCount, cteZeroFiberCount.ItemFiberCountByOp_ID
				FROM cteZeroFiberCount
				GROUP BY ItemNumber, TrueOperationCode, PrimaryAlternate,ItemFiberCountByOp_ID
				) X INNER JOIN Setup.ItemFiberCountByOperation K ON K.ItemFiberCountByOp_ID = X.ItemFiberCountByOp_ID
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;

 
		PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
		PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
		THROW;
	END CATCH

	--Update any fiber count that is 0 to the last 3 positions of the Q operation.
	BEGIN TRY
		BEGIN TRAN
			;WITH cteFiberCount
			AS(
				SELECT K.ItemNumber, k.TrueOperationCode, CAST(RIGHT(K.TrueOperationCode,3) AS INT) AS FiberCount,ItemFiberCountByOp_ID
				FROM Setup.ItemFiberCountByOperation K 
				WHERE FiberCount = 0 AND ISNUMERIC(RIGHT(K.TrueOperationCode,3)) = 1

			)
			UPDATE K
			SET FiberCount = X.FiberCount
			FROM cteFiberCount X INNER JOIN Setup.ItemFiberCountByOperation K ON K.ItemFiberCountByOp_ID = X.ItemFiberCountByOp_ID
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;

 
		PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
		PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
		THROW;
	END CATCH



END




GO
