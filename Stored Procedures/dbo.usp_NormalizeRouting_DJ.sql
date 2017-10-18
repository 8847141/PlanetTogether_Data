SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Bryan Eddy
-- Create date: 9/1/2017
-- Description:	Normalize the Operation Sequence in the routing to call for the Trueoperation(Setup Indicator) for DJ
-- Date Modified:
-- Modifications: 
-- =============================================
CREATE PROCEDURE [dbo].[usp_NormalizeRouting_DJ]

AS

SET NOCOUNT	 ON

UPDATE Oracle_DJ_Routes
SET true_operation_code = null, true_operation_seq_num = null

UPDATE Oracle_DJ_Routes
SET send_to_aps  = 'Y'
WHERE send_to_aps IS NULL --or operation_code like 'd%'

IF OBJECT_ID(N'tempdb..#OrderHold', N'U') IS NOT NULL
DROP TABLE #OrderHold;


CREATE TABLE #OrderHold(
 wip_entity_name varchar(50),
 operation_seq_num INT,
 SeqLayer int,
 operation_code varchar(5),
 DummyFlag bit,
 OperationDescription varchar(300),
 alternate_routing_designator varchar(50),
 send_to_aps varchar(2)
);

--Using Cursor
DECLARE @MyCursor CURSOR;
 
--sample variables to hold each row's content
DECLARE @wip_entity_name varchar(50);
DECLARE @operation_seq_num INT;
DECLARE @SeqLayer int = 10;
DECLARE @LastItem varchar(50);
DECLARE @LastOp varchar(50);
DECLARE @operation_code VARCHAR(5);
DECLARE @Lastoperation_code varchar(5);
DECLARE @send_to_aps varchar(1);
DECLARE @Lastsend_to_aps varchar(2);
DECLARE @DummyFlag bit;
DECLARE @OperationDescription varchar(300);
DECLARE @alternate_routing_designator varchar(50);
DECLARE @FirstTrueOp bit;
DECLARE @NextSeq bit;
DECLARE @NewItem bit;

SET @FirstTrueOp = 0;
SET @NextSeq = 0;
SET @SeqLayer = 10;
Set @NewItem = 0;


 --Iterate through table and apply Unit ID and Layer ID
 --Unit ID's are make components or units that schedule needs to schedule to make
 --Layer ID is used to identify what components are used together
BEGIN
    SET @MyCursor = CURSOR FOR
         select distinct wip_entity_name, operation_seq_num, operation_code,send_to_aps
		 FROM  Oracle_DJ_Routes
		 WHERE send_to_aps <> 'N' --and item_number like 'O-SS-%'
		 ORDER BY wip_entity_name,operation_seq_num
 
    OPEN @MyCursor
    FETCH NEXT FROM @MyCursor
    INTO @wip_entity_name,@operation_seq_num, @operation_code,@send_to_aps


    WHILE @@FETCH_STATUS = 0
    BEGIN
     --Recongizes change in Assembly item and resets indicators
	 IF (@wip_entity_name = @LastItem)
		BEGIN
			SELECT @SeqLayer = @SeqLayer, @NewItem = 0;
		END
	ELSE 
		BEGIN 
			SELECT @SeqLayer = 10, @NewItem = 1,@FirstTrueOp = 0;
		END

	--Recognizes a change in operation and assigns the appropriate layer id
	IF (--@operation_code <> @Lastoperation_code  and
		 (@Lastsend_to_aps <> 'D' AND @send_to_aps <>'D')
		AND @NewItem = 0) 
		BEGIN
			SET @NextSeq = 1;
		END
	ELSE
		BEGIN
			SET @NextSeq = 0;
		END
	--If the criteria is passed from the last if statment and there is no proceeding true operation code then execute
	IF  @NextSeq = 1 OR (@FirstTrueOp = 1 and @Lastsend_to_aps = 'D' AND @send_to_aps ='Y') OR (@FirstTrueOp = 0 and @Lastsend_to_aps = 'Y' AND @send_to_aps ='D') 
		BEGIN
			SET @SeqLayer = @SeqLayer + 10
		END

		
	IF @send_to_aps = 'Y' or @send_to_aps is null
		BEGIN
			SELECT @DummyFlag = 0
		END
	ELSE
		BEGIN
			SELECT @DummyFlag = 1
		END
	--Reset the FirstTrueOperation
	IF @NewItem = 1 and @send_to_aps = 'Y'
		BEGIN
			SET @FirstTrueOp = 1
		END
		 


	 SELECT @LastItem = @wip_entity_name, @Lastoperation_code = @operation_code, @Lastsend_to_aps =  @send_to_aps;


  --Insert data into temp table
  INSERT INTO #OrderHold(wip_entity_name,SeqLayer,operation_code,operation_seq_num,DummyFlag,send_to_aps)
  VALUES (@wip_entity_name,@SeqLayer,@operation_code,@operation_seq_num,@DummyFlag,@send_to_aps)


  FETCH NEXT FROM @MyCursor
  INTO @wip_entity_name,@operation_seq_num, @operation_code,@send_to_aps
   
    END; 
 
    CLOSE @MyCursor ;
    DEALLOCATE @MyCursor;
END;




IF OBJECT_ID(N'tempdb..#NormalizedRouting', N'U') IS NOT NULL
DROP TABLE #NormalizedRouting
;
SELECT *, FIRST_VALUE(operation_code) OVER (PARTITION BY  SeqLayer,wip_entity_name ORDER BY DummyFlag,wip_entity_name,SeqLayer,operation_seq_num) TrueOperation
INTO #NormalizedRouting
FROM #OrderHold
--WHERE  wip_entity_name LIKE '17584891'
ORDER BY wip_entity_name,SeqLayer,operation_seq_num
;

UPDATE Oracle_DJ_Routes
SET true_operation_code = G.TrueOperation, true_operation_seq_num = SeqLayer
FROM #NormalizedRouting G INNER JOIN Oracle_DJ_Routes K ON K.operation_seq_num = G.operation_seq_num AND K.wip_entity_name = G.wip_entity_name
--WHERE K.assembly_item = 'DNA-31074'
;





IF OBJECT_ID(N'tempdb..#SetupNormalize', N'U') IS NOT NULL
DROP TABLE #SetupNormalize;
WITH
	cteBomSetup(Item,operation_seq_num,SetupLocation, BomSetup,UnitId,LayerID)
	as(
		SELECT DISTINCT G.wip_entity_name,G.operation_seq_num,'Bom' as SetupLocation,REPLACE(G.component_item,'SETUP ','') BomSetup
		,g.unit_id,g.layer_id
		FROM Oracle_DJ_BOM G
		WHERE g.component_item like 'Setup%'
	),
	cteRoute(Item, operation_seq_num,SetupLocation,operation_code, ItemStatus,dummy_seq)
	as(

		SELECT DISTINCT k.wip_entity_name,operation_seq_num,'Route' as SetupLocation
		,true_operation_code as operation_code
		, g.inventory_item_status_code, true_operation_seq_num
		FROM Oracle_DJ_Routes K INNER JOIN [Oracle_Items] G ON K.assembly_item = g.item_number

	)

	SELECT DISTINCT cteRoute.Item, dummy_seq,
	COALESCE(BomSetup,cteRoute.operation_code) as Setup ,BomSetup,operation_code
	  , COALESCE(cteBomSetup.operation_seq_num,cteRoute.operation_seq_num) operation_seq_num
	,COALESCE(cteBomSetup.SetupLocation,cteRoute.SetupLocation) as SetupLocation--, cteBomSetup.Alternate as BomAlternate, cteRoute.alternate
	,UnitID,LayerID, 
	FIRST_VALUE(COALESCE(BomSetup,cteRoute.operation_code)) OVER (PARTITION BY cteRoute.Item,dummy_seq ORDER BY (CASE WHEN BomSetup IS NULL THEN 1 ELSE 0 END), cteRoute.Item) as TrueOperation
	INTO #SetupNormalize
	FROM cteRoute LEFT JOIN cteBomSetup ON cteRoute.Item = cteBomSetup.item AND cteRoute.operation_seq_num = cteBomSetup.operation_seq_num
	--INNER JOIN [Oracle_Items] K ON cteRoute.Item = k.item_number
	--WHERE wip_entity_name in( 'PE03072-00')
;



UPDATE Oracle_DJ_Routes
SET true_operation_code = G.TrueOperation
FROM #SetupNormalize G INNER JOIN Oracle_DJ_Routes K ON K.operation_seq_num = G.operation_seq_num AND K.wip_entity_name = G.Item;


UPDATE Oracle_DJ_Routes
SET true_operation_code = department_code
WHERE operation_code is null and department_code is not null
GO
