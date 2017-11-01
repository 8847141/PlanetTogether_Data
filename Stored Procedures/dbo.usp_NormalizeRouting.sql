SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Bryan Eddy
-- Create date: 7/7/2017
-- Description:	Normalize the Operation Sequence in the routing to call for the Trueoperation(Setup Indicator)
-- Date Modified: 9/15/2017
-- Modifications: 
-- =============================================
CREATE PROCEDURE [dbo].[usp_NormalizeRouting]

AS

SET NOCOUNT ON

UPDATE Oracle_Routes
SET true_operation_code = null, true_operation_seq_num = null

UPDATE Oracle_Routes
SET pass_to_aps  = 'Y'
WHERE pass_to_aps IS NULL --or operation_code like 'd%'


IF OBJECT_ID(N'tempdb..#OrderHold', N'U') IS NOT NULL
DROP TABLE #OrderHold;


CREATE TABLE #OrderHold(
 item_number varchar(50),
 operation_seq_num INT,
 SeqLayer int,
 operation_code varchar(5),
 DummyFlag bit,
 OperationDescription varchar(300),
 alternate_routing_designator varchar(50),
 pass_to_aps varchar(2)
);

--Using Cursor
DECLARE @MyCursor CURSOR;
 
--sample variables to hold each row's content
DECLARE @item_number varchar(50);
DECLARE @operation_seq_num INT;
DECLARE @SeqLayer int = 10;
DECLARE @LastItem varchar(50);
DECLARE @LastOp varchar(50);
DECLARE @operation_code VARCHAR(5);
DECLARE @Lastoperation_code varchar(5);
DECLARE @pass_to_aps varchar(1);
DECLARE @Lastpass_to_aps varchar(2);
DECLARE @DummyFlag bit;
DECLARE @OperationDescription varchar(300);
DECLARE @alternate_routing_designator varchar(50);
DECLARE @Last_Alternate varchar(100);
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
         select item_number, operation_seq_num, operation_code,alternate_routing_designator,pass_to_aps
		 FROM  Oracle_Routes
		 WHERE pass_to_aps <> 'N' --and item_number in ('rd2014-0012','PS10262-10','O-SS-1273-02','A-BT-1130-12')
		 ORDER BY item_number,alternate_routing_designator,operation_seq_num
		
 
    OPEN @MyCursor
    FETCH NEXT FROM @MyCursor
    INTO @item_number,@operation_seq_num, @operation_code,@alternate_routing_designator,@pass_to_aps


    WHILE @@FETCH_STATUS = 0
    BEGIN
     --Recongizes change in Assembly item and resets indicators
	 IF (@item_number = @LastItem AND @alternate_routing_designator = @Last_Alternate )
		BEGIN
			SELECT @SeqLayer = @SeqLayer, @NewItem = 0;
		END
	ELSE 
		BEGIN 
			SELECT @SeqLayer = 10, @NewItem = 1,@FirstTrueOp = 0;
		END

	--Recognizes a change in operation and assigns the appropriate sequence
	IF (--(@operation_code <> @Lastoperation_code) AND
		 (@Lastpass_to_aps <> 'D' AND @pass_to_aps <>'D')
		AND @NewItem = 0) 
		BEGIN
			SET @NextSeq = 1;
		END
	ELSE
		BEGIN
			SET @NextSeq = 0;
		END
	--If the criteria is passed from the last if statment and there is no proceeding true operation code then execute
	IF  @NextSeq = 1 or (@FirstTrueOp = 1 and @Lastpass_to_aps = 'D' AND @pass_to_aps ='Y') OR (@FirstTrueOp = 0 and @Lastpass_to_aps = 'Y' AND @pass_to_aps ='D') 
		BEGIN
			SET @SeqLayer = @SeqLayer + 10
		END

		
		
	IF @pass_to_aps = 'Y' or @pass_to_aps is null
		BEGIN
			SELECT @DummyFlag = 0
		END
	ELSE
		BEGIN
			SELECT @DummyFlag = 1
		END


	--Reset the FirstTrueOperation
	IF @NewItem = 1 and @pass_to_aps = 'Y'
		BEGIN
			SET @FirstTrueOp = 1
		END
		 

	 SELECT @LastItem = @item_number, @Lastoperation_code = @operation_code, @Lastpass_to_aps =  @pass_to_aps, @Last_Alternate = @alternate_routing_designator;


  --Insert data into temp table
  INSERT INTO #OrderHold(item_number,SeqLayer,operation_code,operation_seq_num,DummyFlag,alternate_routing_designator,pass_to_aps)
  VALUES (@item_number,@SeqLayer,@operation_code,@operation_seq_num,@DummyFlag,@alternate_routing_designator,@pass_to_aps)


  FETCH NEXT FROM @MyCursor
  INTO @item_number,@operation_seq_num, @operation_code,@alternate_routing_designator,@pass_to_aps
   
    END; 
 
    CLOSE @MyCursor ;
    DEALLOCATE @MyCursor;
END;




IF OBJECT_ID(N'tempdb..#NormalizedRouting', N'U') IS NOT NULL
DROP TABLE #NormalizedRouting
;
SELECT *, FIRST_VALUE(operation_code) OVER (PARTITION BY alternate_routing_designator,item_number,seqLayer ORDER BY item_number,alternate_routing_designator,SeqLayer,DummyFlag,operation_seq_num) TrueOperation
INTO #NormalizedRouting
FROM #OrderHold
--WHERE item_number in( 'PG08030-00','a-bt-1014-01','O-SS-0370-00')-- AND pass_to_aps <> 'n'
ORDER BY item_number,alternate_routing_designator,operation_seq_num
;

UPDATE Oracle_Routes
SET true_operation_code = G.TrueOperation, true_operation_seq_num = SeqLayer
FROM #NormalizedRouting G INNER JOIN Oracle_Routes K ON K.operation_seq_num = G.operation_seq_num AND K.item_number = G.item_number AND K.alternate_routing_designator = G.alternate_routing_designator
--WHERE k.item_number in( 'DNS-5314')
--ORDER BY k.item_number,k.alternate_routing_designator,SeqLayer,k.operation_seq_num;





IF OBJECT_ID(N'tempdb..#SetupNormalize', N'U') IS NOT NULL
DROP TABLE #SetupNormalize;
WITH
	cteBomSetup(Item,operation_seq_num,SetupLocation, BomSetup,Alternate,UnitId,LayerID)
	as(
		SELECT DISTINCT G.item_number,g.opseq,'Bom' as SetupLocation,REPLACE(g.comp_item,'SETUP ','') BomSetup
		,g.alternate_bom_designator,g.unit_id,g.layer_id
		FROM Oracle_BOMs G
		WHERE g.comp_item like 'Setup%'
	),
	cteRoute(Item, operation_seq_num,SetupLocation,operation_code, ItemStatus, Alternate,dummy_seq)
	as(

		SELECT DISTINCT k.item_number,operation_seq_num,'Route' as SetupLocation
		,true_operation_code as operation_code
		, g.inventory_item_status_code, alternate_routing_designator,true_operation_seq_num
		FROM Oracle_Routes K INNER JOIN [Oracle_Items] G ON K.item_number = G.item_number
		--WHERE K.item_number in( 'DNS-5314')

	)

	SELECT DISTINCT cteRoute.Item, dummy_seq,
	COALESCE(BomSetup,cteRoute.operation_code) as Setup ,BomSetup,operation_code
	  , k.item_description as Item_Description, COALESCE(cteBomSetup.operation_seq_num,cteRoute.operation_seq_num) operation_seq_num
	,COALESCE(cteBomSetup.SetupLocation,cteRoute.SetupLocation) as SetupLocation--, cteBomSetup.Alternate as BomAlternate, cteRoute.alternate
	,COALESCE(cteBomSetup.Alternate,cteRoute.Alternate,'Primary') as PrimaryAlt
	,UnitID,LayerID, 
	FIRST_VALUE(COALESCE(BomSetup,cteRoute.operation_code)) OVER (PARTITION BY cteRoute.Item,dummy_seq,COALESCE(cteBomSetup.Alternate,cteRoute.Alternate,'Primary') ORDER BY (CASE WHEN BomSetup IS NULL THEN 1 ELSE 0 END), cteRoute.Item) as TrueOperation
	INTO #SetupNormalize
	FROM cteRoute LEFT JOIN cteBomSetup ON cteRoute.Item = cteBomSetup.item AND cteRoute.operation_seq_num = cteBomSetup.operation_seq_num
	INNER JOIN [Oracle_Items] K ON cteRoute.Item = k.item_number
	AND COALESCE(cteRoute.Alternate,'Primary') = COALESCE(cteBomSetup.Alternate,'Primary')
	--WHERE item_number in( 'DNS-5314')
;



UPDATE Oracle_Routes
SET true_operation_code = G.TrueOperation
FROM #SetupNormalize G INNER JOIN Oracle_Routes K ON K.operation_seq_num = G.operation_seq_num AND K.item_number = G.Item AND K.alternate_routing_designator = G.PrimaryAlt;

UPDATE Oracle_Routes
SET true_operation_code = department_code
WHERE operation_code is null and department_code is not null

GO
