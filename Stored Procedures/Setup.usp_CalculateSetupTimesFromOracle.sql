SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:      Bryan Eddy
-- Create date: 8/14/2017
-- Description: Procedure pulls data from various Oracle points to calculate item setup times
-- Version:		6
-- Update:		Added insert to get DJ items missing from the setup data
-- =============================================

CREATE PROCEDURE [Setup].[usp_CalculateSetupTimesFromOracle]
AS

	SET NOCOUNT ON;
BEGIN

TRUNCATE TABLE SETUP.AttributeSetupTimeItem

DECLARE @ErrorNumber INT = ERROR_NUMBER();
DECLARE @ErrorLine INT = ERROR_LINE();



	--Add to procedure to only grab the top row in case of dupblicate values
	IF OBJECT_ID(N'tempdb..#Temp', N'U') IS NOT NULL
	DROP TABLE #Temp;
	WITH cteSetup
	as(
		SELECT DISTINCT k.item_number,true_operation_code,U.MachineGroupID,M.MachineID,R.AttributeNameID,G.comp_item, attribute_name, attribute_value, o.inventory_item_status_code, ValueTypeID
		--,COUNT(comp_item) OVER (PARTITION BY true_operation_code, comp_item) CountOfComponent
		FROM dbo.Oracle_Routes K INNER JOIN DBO.Oracle_BOMs G ON G.item_number = K.item_number AND G.opseq = K.operation_seq_num
		INNER JOIN Oracle_Item_Attributes P ON P.item_number = G.comp_item
		INNER JOIN setup.vMachineCapability M ON M.Setup = K.true_operation_code
		INNER JOIN setup.ApsSetupAttributeReference R ON R.OracleAttribute = P.attribute_name
		INNER JOIN [Setup].[vMachineAttributes] V ON R.AttributeNameID = V.AttributeNameID 
		INNER JOIN SETUP.MachineNames U ON U.MachineGroupID = V.MachineGroupID AND U.MachineID = M.MachineID
		INNER JOIN dbo.Oracle_Items O ON O.item_number = P.item_number
		--WHERE G.alternate_bom_designator = 'primary'
	),
	cteDup
	as(
		SELECT item_number,true_operation_code,MachineGroupID,MachineID,AttributeNameID,comp_item,attribute_name,attribute_value,ValueTypeID,
		COUNT(comp_item) OVER (PARTITION BY item_number) Countof
		FROM cteSetup
	)
	SELECT DISTINCT *
	INTO #TEMP
	FROM cteDup

	--Create index on #Temp table to speed up insert statements
	CREATE NONCLUSTERED INDEX Temp_Index
	ON [dbo].#temp ([attribute_name])
	INCLUDE ([item_number],[true_operation_code],[MachineGroupID],MachineID,[AttributeNameID],[comp_item],[attribute_value],[ValueTypeID])

	--SELECT DISTINCT true_operation_code, attribute_name
	--FROM #TEMP
	--WHERE MACHINEGROUPID = 2
	--ORDER BY true_operation_code

	--Insert jacket type for each operation with a jacket
	BEGIN TRY
		BEGIN TRAN
			;WITH cteJacket
			as(
				SELECT *, ROW_NUMBER() OVER (PARTITION BY item_number,true_operation_Code,MachineGroupID,MachineID,AttributeNameID  ORDER BY item_number,comp_item Desc ) AS RowNumber
				FROM #TEMP
				WHERE attribute_name = 'JACKET' 
			)

			INSERT INTO [Setup].AttributeSetupTimeItem (Item_Number,[Setup],[MachineGroupID],MachineID,AttributeNameID,[SetupAttributeValue],[SetupTime])
			SELECT DISTINCT item_number,true_operation_code,T.MachineGroupID,T.MachineID,T.AttributeNameID,comp_item,CASE WHEN T.ValueTypeID = 5 THEN NULL ELSE TimeValue END 
			FROM cteJacket T LEFT JOIN setup.AttributeMatrixFixedValue K ON K.AttributeNameID = T.AttributeNameID AND  K.MachineID = T.MachineID
			WHERE Rownumber = 1 --AND  item_number ='DNA-28547-01'
			ORDER BY true_operation_code

			COMMIT TRAN
		END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
 

 
		PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
		PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
		THROW;
	END CATCH;



	--Insert color for each operation.
	--Looks at color chips and compound. Color chips take precedence over compound for coloring
	BEGIN TRY
		BEGIN TRAN
			;WITH cteColor
			as(
				SELECT K.*, ROW_NUMBER() OVER (PARTITION BY K.item_number,true_operation_Code,MachineGroupID,MachineID,AttributeNameID   ORDER BY K.item_number,(CASE WHEN G.attribute_value = 'COLOR CHIPS' THEN 1 ELSE 0 END)  Desc ) AS RowNumber
				,CASE WHEN G.attribute_value = 'COLOR CHIPS' THEN 1 ELSE 0 END  ColorOrder, g.attribute_value Material_Type
				FROM #TEMP K  INNER JOIN dbo.Oracle_Item_Attributes G ON K.comp_item = G.item_number
				WHERE K.attribute_name = 'COLOR'  AND G.attribute_name = 'MATERIAL TYPE' AND G.attribute_value IN ('COLOR CHIPS','COMPOUND')
			)

			INSERT INTO [Setup].AttributeSetupTimeItem (Item_Number,[Setup],[MachineGroupID],MachineID,AttributeNameID,[SetupAttributeValue],[SetupTime])
			SELECT DISTINCT item_number,true_operation_code,T.MachineGroupID,T.MachineID,T.AttributeNameID,attribute_value,CASE WHEN T.ValueTypeID = 5 THEN NULL ELSE TimeValue END-- , T.ValueTypeID
			FROM cteColor T LEFT JOIN setup.AttributeMatrixFixedValue K ON K.AttributeNameID = T.AttributeNameID AND K.MachineID = T.MachineID
			WHERE Rownumber = 1 --AND T.MachineGroupID = 4
			--ORDER BY true_operation_code
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
 
 
		PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
		PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
		THROW;
	END CATCH;


	--Calculate aramid setup time
	--Each end of aramid is multiplied by a time value
	BEGIN TRY
		BEGIN TRAN
			;WITH cteAramid
			as(
				SELECT K.item_number,[Setup],MG.[MachineGroupID],M.MachineID,MG.AttributeNameID,CAST(count_per_uom AS INT) SetupAttributeValue,TimeValue * cast(count_per_uom as int) + COALESCE(Adder,0) as SetupTime--, MG.ValueTypeID
				FROM setup.MachineGroupAttributes MG INNER JOIN setup.MachineNames M ON M.MachineGroupID = MG.MachineGroupID
				INNER JOIN setup.vMachineCapability T ON T.MachineID = M.MachineID
				INNER JOIN dbo.Oracle_Routes G ON G.true_operation_code = T.Setup
				INNER JOIN dbo.Oracle_BOMs K ON K.item_number = G.item_number AND K.opseq = G.operation_seq_num AND G.alternate_routing_designator = K.alternate_bom_designator
				INNER JOIN dbo.Oracle_Item_Attributes A ON A.item_number = K.comp_item 
				INNER JOIN setup.ApsSetupAttributeReference R ON R.AttributeNameID = MG.AttributeNameID AND R.OracleAttribute = A.attribute_value
				INNER JOIN setup.vAttributeMatrixUnion MU ON MU.AttributeNameID = MG.AttributeNameID AND MU.MachineGroupID = MG.MachineGroupID and mu.MachineID = t.MachineID
				WHERE MG.ValueTypeID = 3 and k.alternate_bom_designator = 'primary' --AND K.item_number = 'o-ts-0151-02'
			)
			INSERT INTO [Setup].AttributeSetupTimeItem (Item_Number,[Setup],[MachineGroupID],MachineID,AttributeNameID,[SetupAttributeValue],[SetupTime])
			SELECT item_number,Setup, MachineGroupID, MachineID, AttributeNameID, SUM(SetupAttributeValue) EndsOfAramid, SUM(SetupTime) SetupTime
			FROM cteAramid
			GROUP BY item_number,Setup, MachineGroupID, MachineID, AttributeNameID
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
 
 
		PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
		PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
		THROW;
	END CATCH;


	--Calculate EFL gain for SS RW 
	--Get's EFL from the Oracle specs
	BEGIN TRY
		BEGIN TRAN
			;WITH cteEFL
			AS(
			SELECT  DISTINCT a.itemnumber,[Setup],MG.[MachineGroupID],M.MachineID,MG.AttributeNameID,COALESCE(CAST(a.TargetValue AS FLOAT),0) SetupAttributeValue,TimeValue--, a.SpecificationElement
			,ROW_NUMBER() OVER (PARTITION BY a.itemnumber,[Setup],MG.[MachineGroupID],M.MachineID,MG.AttributeNameID ORDER BY  a.itemnumber) RowNumber
			FROM setup.MachineGroupAttributes MG INNER JOIN setup.MachineNames M ON M.MachineGroupID = MG.MachineGroupID
				INNER JOIN setup.vMachineCapability T ON T.MachineID = M.MachineID
				INNER JOIN dbo.Oracle_Routes G ON G.true_operation_code = T.Setup
				INNER JOIN [NAASPB-PRD04\SQL2014].Premise.dbo.AFLPRD_INVSysItemSpec_CAB A ON a.itemnumber = g.item_number 
				INNER JOIN setup.ApsSetupAttributeReference R ON R.AttributeNameID = MG.AttributeNameID AND A.SpecificationElement = r.OracleAttribute
				INNER JOIN setup.vAttributeMatrixUnion MU ON MU.AttributeNameID = MG.AttributeNameID AND MU.MachineGroupID = MG.MachineGroupID AND mu.MachineID = t.MachineID AND MG.ValueTypeID = MU.ValueTypeID
			WHERE mg.MachineGroupID = 11 AND mg.ValueTypeID = 2 
			)
			INSERT INTO [Setup].AttributeSetupTimeItem (Item_Number,[Setup],[MachineGroupID],MachineID,AttributeNameID,[SetupAttributeValue],[SetupTime])
			SELECT itemnumber,[Setup],[MachineGroupID],MachineID,AttributeNameID,SetupAttributeValue,TimeValue
			FROM cteEFL
			WHERE RowNumber = 1
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
 
		PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
		PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));

		THROW;
	END CATCH;

	--Insert all items for setups
	BEGIN TRY
		BEGIN TRAN
			INSERT INTO [Setup].AttributeSetupTimeItem (Item_Number,[Setup],[MachineGroupID],MachineID,AttributeNameID,[SetupAttributeValue],[SetupTime])
			SELECT DISTINCT Item_Number,[Setup],g.[MachineGroupID],MachineID,AttributeNameID,[SetupAttributeValue],[SetupTime]
			FROM Setup.vSetupTimes G INNER JOIN  dbo.Oracle_Routes K ON K.true_operation_code = G.Setup
			--WHERE  AttributeNameID = 8
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;

		PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
		PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
		THROW;
	END CATCH;


	--Insert fibercount time values based on Value Type 4 (multiply depending on the value)
	--Fiber Count is calculated using the Value Type 4 logic, but then is inserted as a FiberSet with value type 2 logic for PT to interpret
	--Using the FiberCount calculation is dependent upon if the FiberSet has changed.  
	--Reduced to 8 seconds to insert data.  
	BEGIN TRY

		IF OBJECT_ID(N'tempdb..#MachineCapability', N'U') IS NOT NULL
		DROP TABLE #MachineCapability;

		SELECT *
		INTO #MachineCapability
		FROM Setup.vMachineCapability

		CREATE NONCLUSTERED INDEX MachineCapability_IXX
		ON [dbo].#MachineCapability (MachineID)

		CREATE NONCLUSTERED INDEX MachineCapability_Setup_IX
		ON [dbo].#MachineCapability (Setup)
		--INCLUDE ([item_number],[true_operation_code],[MachineGroupID],MachineID,[AttributeNameID],[comp_item],[attribute_value],[ValueTypeID])
		
		BEGIN TRAN
			INSERT INTO [Setup].AttributeSetupTimeItem (Item_Number,[Setup],[MachineGroupID],MachineID,AttributeNameID,[SetupAttributeValue],[SetupTime])
			SELECT DISTINCT Item_Number,G.true_operation_code,I.[MachineGroupID],I.MachineID,8 AttributeNameID,null,FiberCount * TimeValue		--Calculates the TimeValue per fibercount and then inserts it for FiberSet for PT to pick up
			FROM Setup.ItemAttributes K INNER JOIN dbo.Oracle_Routes G ON G.item_number = K.ItemNumber 
			INNER JOIN #MachineCapability P ON P.Setup = G.true_operation_code
			INNER JOIN Setup.AttributeMatrixVariableValue U ON U.AttributeValue = K.FiberCount AND P.MachineID = U.MachineID
			INNER JOIN Setup.MachineGroupAttributes Y ON Y.AttributeNameID = U.AttributeNameID 
			INNER JOIN Setup.MachineNames I ON I.MachineGroupID = Y.MachineGroupID AND U.MachineID = I.MachineID
			WHERE ValueTypeID = 4 
		COMMIT TRAN
	END TRY
	BEGIN CATCH	
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
		PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
		PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
		THROW;
	END CATCH;


	--Insert fibercount based setup time based on the fiber count Value Type 7 (fixed value chosen that is dependent on the fiber count) for QC operations
	BEGIN TRY
		BEGIN TRAN
			INSERT INTO [Setup].AttributeSetupTimeItem (Item_Number,[Setup],[MachineGroupID],MachineID,AttributeNameID,[SetupAttributeValue],[SetupTime])
			SELECT DISTINCT Item_Number,operation_code,[MachineGroupID],p.MachineID AS MachineID,u.AttributeNameID,FiberCount,TimeValue
			FROM setup.ItemFiberCountByOperation K INNER JOIN dbo.Oracle_Routes G ON G.item_number = K.ItemNumber AND K.TrueOperationCode = G.true_operation_code
			INNER JOIN Setup.DepartmentIndicator P ON p.department_code = g.department_code
			INNER JOIN Setup.AttributeMatrixVariableValue U ON U.AttributeValue = K.FiberCount AND P.MachineID = U.MachineID
			INNER JOIN Setup.vMachineAttributes Y ON Y.MachineID = P.MachineID AND Y.AttributeNameID = U.AttributeNameID 
			WHERE ValueTypeID = 7 AND pass_to_aps NOT IN ('d','N') AND K.PrimaryAlternate = 'primary' 
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
		PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
		PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
		THROW;
	END CATCH;


	--Insert fibercount based setup time based on the fiber count Value Type 3 (multiply by number of fibers) for QC operations
	BEGIN TRY
		BEGIN TRAN
			INSERT INTO [Setup].AttributeSetupTimeItem (Item_Number,[Setup],[MachineGroupID],AttributeSetupTimeItem.MachineID,AttributeNameID,[SetupAttributeValue],[SetupTime])
			SELECT DISTINCT K.ItemNumber,TrueOperationCode,[MachineGroupID],G.MachineID AS MachineID,u.AttributeNameID,FiberCount,TimeValue*FiberCount
			FROM setup.ItemFiberCountByOperation K
			INNER JOIN Scheduling.MachineCapabilityScheduler G ON G.Setup = K.TrueOperationCode
			INNER JOIN Setup.AttributeMatrixFixedValue U ON G.MachineID = U.MachineID
			INNER JOIN Setup.vMachineAttributes Y ON Y.MachineID = G.MachineID AND Y.AttributeNameID = U.AttributeNameID 
			WHERE ValueTypeID = 3 AND k.PrimaryAlternate = 'primary' AND U.AttributeNameID = 7

		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
		PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
		PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
		THROW;
	END CATCH;


	--Insert if buffering item is printed based on the %-[wb]/s% indicator in the item description.
	--This is for ACS buffering items only
	BEGIN TRY
		BEGIN TRAN
			INSERT INTO [Setup].AttributeSetupTimeItem (Item_Number,[Setup],[MachineGroupID],AttributeSetupTimeItem.MachineID,AttributeNameID,[SetupAttributeValue],[SetupTime])
			SELECT DISTINCT G.item_number,I.Setup,[MachineGroupID],I.MachineID,u.AttributeNameID,(CASE WHEN G.item_description LIKE '%-[WB]/S%' THEN '1' ELSE '0' END), NULL--, K.product_class
			FROM dbo.Oracle_Items K INNER JOIN dbo.Oracle_Routes G ON G.item_number = K.item_number
			INNER JOIN SETUP.vMachineCapability I ON I.SETUP = G.true_operation_code
			INNER JOIN Setup.AttributeMatrixFromTo U ON I.MachineID = U.MachineID
			INNER JOIN Setup.vMachineAttributes Y ON Y.MachineID = I.MachineID AND Y.AttributeNameID = U.AttributeNameID 
			WHERE ValueTypeID = 5 AND U.AttributeNameID = 37 AND k.product_class  NOT LIKE '%Premise%'
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
		PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
		PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
		THROW;
	END CATCH;



	
	--Insert color prefered sequence
	BEGIN TRY
		BEGIN TRAN
			INSERT INTO [Setup].AttributeSetupTimeItem (Item_Number,[Setup],[MachineGroupID],AttributeSetupTimeItem.MachineID,AttributeNameID,[SetupAttributeValue],[SetupTime])
			SELECT k.Item_Number, k.Setup, I.MachineGroupID, K.MachineID, I.AttributeNameID, PreferedSequence, 0 AS SetupTime
			FROM [Setup].AttributeSetupTimeItem k INNER JOIN Setup.ColorSequencePreference J ON J.Color = k.SetupAttributeValue
				INNER JOIN Setup.MachineGroupAttributes I ON I.MachineGroupID = K.MachineGroupID
				WHERE I.AttributeNameID = 38
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
 
 
		PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
		PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
		THROW;
	END CATCH;


			--Insert setup information for all DJ's with setup that is not located on the std op
	BEGIN TRY
		BEGIN TRAN
			;WITH cteSetups --Get setup information for all Routing DJs
			AS(
				SELECT DISTINCT Item_Number,[Setup],[MachineGroupID],MachineID,AttributeNameID,[SetupAttributeValue],[SetupTime]
						FROM setup.AttributeSetupTimeItem K INNER JOIN dbo.Oracle_DJ_Routes B ON K.Setup = b.true_operation_code
				),
			cteMissingSetupItems --GEt which DJ items are missing from the setup data
				as(
				SELECT R.assembly_item, R.true_operation_code 
				FROM dbo.Oracle_DJ_Routes R LEFT JOIN  Setup.AttributeSetupTimeItem S ON R.assembly_item = S.Item_Number
				WHERE S.Item_Number IS NULL AND R.send_to_aps <> 'N'
				)
			INSERT INTO setup.AttributeSetupTimeItem ([Setup],[MachineGroupID],MachineID,AttributeNameID,[SetupAttributeValue],[SetupTime])
			SELECT DISTINCT [Setup],[MachineGroupID],MachineID,AttributeNameID,[SetupAttributeValue],[SetupTime]
			FROM cteMissingSetupItems K INNER JOIN cteSetups S ON S.Item_Number = K.assembly_item AND S.Setup = K.true_operation_code
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
