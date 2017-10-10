SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:      Bryan Eddy
-- Create date: 9/11/2017
-- Description: Procedure insert data into Setup.ItemAttributes table for Oracle to pick up
-- =============================================

CREATE PROCEDURE [Setup].[usp_GetItemAttributeData]
as

	SET NOCOUNT ON;
BEGIN



--Update all items with the latest fiber count
EXEC [Setup].[usp_GetUpdatedFiberCount]

--Get cable color.  Find color chips or compound in BOM and rank to find the sheathed cable color
	
	;WITH cteSetup
	as(
		
		SELECT DISTINCT G.item_number,R.AttributeNameID,G.comp_item, P.attribute_name, P.attribute_value, o.inventory_item_status_code,G.opseq,
		DENSE_RANK() OVER (PARTITION BY G.item_number ORDER BY G.item_number,G.opseq ASC) AS OpSeqRank
		,ROW_NUMBER() OVER (PARTITION BY G.item_number,G.opseq   ORDER BY G.item_number,(CASE WHEN z.attribute_value = 'COLOR CHIPS' THEN 1 ELSE 0 END)  Desc ) AS RowNumber
		--,COUNT(comp_item) OVER (PARTITION BY true_operation_code, comp_item) CountOfComponent
		FROM DBO.Oracle_BOMs G
		INNER JOIN Oracle_Item_Attributes P ON P.item_number = G.comp_item
		INNER JOIN setup.ApsSetupAttributeReference R ON R.OracleAttribute = P.attribute_name
		INNER JOIN dbo.Oracle_Items O ON O.item_number = P.item_number
		INNER JOIN dbo.Oracle_Item_Attributes Z ON G.comp_item = Z.item_number
		WHERE P.attribute_name = 'COLOR'  AND Z.attribute_name = 'MATERIAL TYPE' AND Z.attribute_value IN ('COMPOUND','COLOR CHIPS','INK') and alternate_bom_designator = 'primary'
		

	)
	UPDATE K
	SET K.CableColor = g.attribute_value
	--select *
	FROM cteSetup G INNER JOIN setup.ItemAttributes K ON G.item_Number = K.ItemNumber
	WHERE OpSeqRank = 1 and RowNumber = 1 AND DATEDIFF(day,DateRevised,getdate()) = 0


	--Get if the BOM contains GEL
	;WITH cteGel
	as(
		SELECT DISTINCT K.item_number, comp_item, ROW_NUMBER() OVER (PARTITION BY k.item_number ORDER BY k.item_number) RowNumber
		FROM DBO.Oracle_BOMs K INNER JOIN dbo.Oracle_Item_Attributes G ON G.item_number = K.comp_item
		WHERE G.attribute_name = 'MATERIAL TYPE' AND G.attribute_value = 'GEL' AND alternate_bom_designator = 'primary'
	)
	UPDATE K
	SET K.Gel = comp_item
	--select *
	FROM cteGel G INNER JOIN setup.ItemAttributes K ON G.item_Number = K.ItemNumber
	WHERE RowNumber = 1 AND DATEDIFF(day,DateRevised,getdate()) = 0


	--Get OD of items from setup data
	;WITH cteAttributes
	as (
		SELECT DISTINCT AttributeValue, K.AttributeName, SetupNumber,P.AttributeNameID
		FROM [Setup].vInterfaceSetupAttributes K INNER JOIN Setup.ApsSetupAttributeReference G ON K.AttributeID = G.AttributeID
		  INNER JOIN SETUP.ApsSetupAttributes P ON P.AttributeNameID = G.AttributeNameID 
		  INNER JOIN setup.MachineNames M ON M.MachineName = PlanetTogetherMachineNumber
		  WHERE P.AttributeNameID = 3 AND AttributeValue IS NOT NULL
	),
	 cteOD
	as(
		SELECT DISTINCT item_number, true_operation_seq_num, true_operation_code, AttributeValue, AttributeName,
		ROW_NUMBER() OVER (PARTITION BY item_number ORDER BY item_number,true_operation_seq_num DESC) RowNumber
		FROM Oracle_Routes K INNER JOIN cteAttributes G 
		ON K.true_operation_code = G.SetupNumber
		WHERE alternate_routing_designator = 'PRIMARY'
	)
	UPDATE K
	SET K.NominalOD = G.AttributeValue
	FROM cteOD G INNER JOIN Setup.ItemAttributes K ON G.item_number = K.ItemNumber
	WHERE RowNumber = 1 AND DATEDIFF(day,DateRevised,getdate()) = 0

	DECLARE @RecordCount int;
	SELECT @RecordCount = COUNT(*) FROM [NAASPB-PRD04\SQL2014].Premise.Schedule.vInterfaceItemAttributes
	IF @RecordCount > 0 
		BEGIN
			--Get OD of items from Premise DB
			UPDATE G
			SET G.NominalOD = CASE WHEN G.NominalOD is null THEN K.NominalOD ELSE G.NominalOD END, G.CableColor = CASE WHEN G.CableColor IS NULL THEN K.CableColor ELSE K.CableColor END
			FROM [NAASPB-PRD04\SQL2014].Premise.Schedule.vInterfaceItemAttributes K INNER JOIN setup.ItemAttributes G ON G.ItemNumber = K.ItemNumber
			WHERE g.NominalOD is null
		END

	--IF OBJECT_ID('[NAASPB-PRD04\SQL2014].Premise.dbo.AFLPRD_INVSysItemSpec_CAB', 'U') IS NOT NULL 
	--	BEGIN
			--DECLARE @RecordCount int;
			SELECT @RecordCount = COUNT(*) FROM [NAASPB-PRD04\SQL2014].Premise.dbo.AFLPRD_INVSysItemSpec_CAB
			IF @RecordCount > 0 
				BEGIN
					--Get OD of items from Oracle Specs that are still null
					;WITH cteNominalOD
					as(
					SELECT G.ItemNumber, NominalOD, SpecificationElement, CAST(REPLACE(TargetValue,',','.') AS FLOAT) AS attribute_value
					,row_number() OVER (PARTITION BY K.ItemNumber ORDER BY K.ItemNumber asc,CAST(REPLACE(TargetValue,',','.') AS FLOAT) desc) AS RowNumber
					  FROM [Scheduling].[vItemAttributes] G INNER JOIN [NAASPB-PRD04\SQL2014].Premise.dbo.AFLPRD_INVSysItemSpec_CAB K ON K.ItemNumber = G.ItemNumber
					  where NominalOD is null AND K.SpecificationElement in( 'UNIT NOMINAL OD','JACKET OD') AND TargetValue IS NOT NULL  
					)
					UPDATE G
					SET NominalOD = attribute_value
					FROM cteNominalOD K INNER JOIN setup.ItemAttributes G ON G.ItemNumber = K.ItemNumber
					WHERE RowNumber = 1
				END
		--END

	--Get cables that have colored binders
	UPDATE P
	SET P.ContainsFiberIdBinders = 1
	FROM DBO.Oracle_Item_Attributes K INNER JOIN DBO.Oracle_BOMs G ON K.item_number = G.comp_item
	INNER JOIN setup.ItemAttributes P ON P.ItemNumber = G.item_number
	WHERE attribute_value = 'COLOR BINDER'


END


GO
