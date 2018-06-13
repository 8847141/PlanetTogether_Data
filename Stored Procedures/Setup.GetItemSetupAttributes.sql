SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
Author:		Bryan Eddy
Date:		3/27/2018
Desc:		Create a table to pull setup attributes from for reporting
Version:	1
Update:		n/a
*/

CREATE PROC [Setup].[GetItemSetupAttributes]

as

/*
Getting setup parameters from setup information for reporting
*/

BEGIN
	SET NOCOUNT ON;

	DECLARE @ErrorNumber INT = ERROR_NUMBER();
	DECLARE @ErrorLine INT = ERROR_LINE();


	/*Insert/Add all setups for each item*/
	BEGIN TRY
		BEGIN TRAN
			INSERT INTO Setup.ItemSetupAttributes(ItemNumber,Setup)
			SELECT DISTINCT R.item_number, R.true_operation_code
			FROM Setup.vRoutesUnion R LEFT JOIN SETUP.ItemSetupAttributes K ON K.ItemNumber = R.item_number AND R.true_operation_code = K.Setup
			WHERE K.ItemNumber IS NULL AND R.true_operation_code IS NOT NULL
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
 
		PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
		PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
		THROW;
	END CATCH;



/*
Pivot the results from the Setup.vSetupTimesItem by building a temp table 
Gathering information for each setup
*/

	BEGIN TRY
		BEGIN TRAN
		--Get Od for each setup
				IF OBJECT_ID(N'tempdb..#OD', N'U') IS NOT NULL
				DROP TABLE #OD;
				SELECT DISTINCT Setup, AttributeNameID,AttributeName,SetupAttributeValue AS OD, MachineID
				INTO #OD
				FROM Setup.vSetupTimesItem WHERE AttributeNameID = 3 AND ISNUMERIC(SetupAttributeValue) = 1

				--Get Jacket Material for each setup
				IF OBJECT_ID(N'tempdb..#JacketMaterial', N'U') IS NOT NULL
				DROP TABLE #JacketMaterial;
				SELECT DISTINCT Setup, AttributeNameID,AttributeName,SetupAttributeValue AS JacketMaterial, MachineID
				INTO #JacketMaterial
				FROM Setup.vSetupTimesItem WHERE AttributeNameID = 5

				--Get number for core positions for cabling setups
				IF OBJECT_ID(N'tempdb..#CorePositions', N'U') IS NOT NULL
				DROP TABLE #CorePositions;
				SELECT DISTINCT Setup, AttributeNameID,AttributeName,SetupAttributeValue AS NumberCorePositions, MachineID
				INTO #CorePositions
				FROM Setup.vSetupTimesItem WHERE AttributeNameID = 17

				IF OBJECT_ID(N'tempdb..#Aramid', N'U') IS NOT NULL
				DROP TABLE #Aramid;
				SELECT DISTINCT Setup, AttributeNameID,AttributeName,SetupAttributeValue AS EndsOfAramid, MachineID
				INTO #Aramid
				FROM Setup.vSetupTimesItem WHERE AttributeNameID = 28



				--Insert information from the temp tables into 
				;WITH cteSetupAttributes
				AS(
				SELECT DISTINCT M.SETUP, OD, j.JacketMaterial, N.NumberCorePositions, A.EndsOfAramid
				FROM SETUP.vMachineCapability M LEFT JOIN #JacketMaterial J ON J.Setup = M.Setup
				LEFT JOIN #OD O ON o.Setup = M.setup 
				LEFT JOIN #CorePositions N ON N.Setup = M.Setup 
				INNER JOIN Setup.ItemSetupAttributes  S ON  S.Setup = M.Setup
				LEFT JOIN #Aramid A ON A.SETUP = M.Setup
				)
				UPDATE  Setup.ItemSetupAttributes
				SET NominalOD = od, NumberCorePositions = g.NumberCorePositions, JacketMaterial = g.JacketMaterial,
				EndsOfAramid = g.EndsOfAramid
				FROM cteSetupAttributes g INNER JOIN Setup.ItemSetupAttributes k ON k.setup = g.Setup
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
 
		PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
		PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
		THROW;
	END CATCH;


--Get UJCM for each cabling operation
	BEGIN TRY
		BEGIN TRAN
			;WITH cteUJCM
			AS(
				SELECT DISTINCT Setup, B.comp_item as UJCM
				--,COUNT(B.comp_item) OVER (PARTITION BY M.Setup,comp_item, r.alternate_routing_designator, R.wip_entity_name) AS UjcmCount
				, B.item_number
				FROM dbo.Oracle_Routes R INNER JOIN Setup.vMachineCapability M ON M.Setup = R.true_operation_code
				INNER JOIN Setup.MachineNames C ON C.MachineID = M.MachineID 
				INNER JOIN dbo.Oracle_BOMs B ON B.alternate_bom_designator = R.alternate_routing_designator AND B.opseq = R.operation_seq_num AND B.item_number = R.item_number
				INNER JOIN dbo.Oracle_Items I ON I.item_number = B.comp_item
				WHERE C.MachineGroupID = 13 AND I.product_class LIKE 'Cable.%.Raw Material.Filler.UJCM' 
			)
			,cteItemUjcm
			AS(
				SELECT *, ROW_NUMBER() OVER (PARTITION BY cteUJCM.Setup, cteUJCM.item_number ORDER BY cteUJCM.UJCM DESC) AS RowNumber
				--INTO #Ujcm
				FROM cteUJCM
			)
			UPDATE G 
			SET UJCM =  k.UJCM
			FROM cteItemUjcm k INNER JOIN Setup.ItemSetupAttributes g ON g.Setup = k.Setup AND g.ItemNumber = k.item_number
			WHERE k.RowNumber =1
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
 
		PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
		PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
		THROW;
	END CATCH;

END
GO
