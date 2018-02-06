SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






/*
Author:		Bryan Eddy
Date:		2/5/2018
Desc:		Union of both BOMs (DJ and Std) 
Version:	1
Update:		Initial creation
*/

CREATE VIEW [Setup].[vBomUnion]
AS 

SELECT item_number, comp_item, comp_qty_per, opseq, alternate_bom_designator, count_per_uom
FROM dbo.Oracle_BOMs


UNION

SELECT assembly_item, component_item, quantity_issued ,operation_seq_num,'Primary', count_per_uom
FROM dbo.Oracle_DJ_BOM
GO
