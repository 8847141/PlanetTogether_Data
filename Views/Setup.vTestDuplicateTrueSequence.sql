SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/****** Script for SelectTopNRows command from SSMS  ******/


-- =============================================
-- Author:      Bryan Eddy
-- Create date: 10/1/2017
-- Description: 

/*View to show over lapping true operation sequence numbers
Each pass_to_aps = 'Y' must have it's own unique operation sequence number.
This query will return any results where this is not true.*/
CREATE VIEW [Setup].[vTestDuplicateTrueSequence]
AS

WITH cteTrueOp
AS(
SELECT item_number, alternate_routing_designator, operation_seq_num,operation_code, true_operation_seq_num, true_operation_code, pass_to_aps
,ROW_NUMBER() OVER (PARTITION BY item_number, alternate_routing_designator, true_operation_seq_num, pass_to_aps ORDER BY item_number, alternate_routing_designator, true_operation_seq_num) RowNumber
FROM dbo.Oracle_Routes
WHERE pass_to_aps = 'Y'
)
SELECT cteTrueOp.item_number,
       cteTrueOp.alternate_routing_designator,
       cteTrueOp.operation_seq_num,
       cteTrueOp.operation_code,
       cteTrueOp.true_operation_seq_num,
       cteTrueOp.true_operation_code,
       cteTrueOp.pass_to_aps,
       cteTrueOp.RowNumber
FROM cteTrueOp
WHERE cteTrueOp.RowNumber >1
GO
