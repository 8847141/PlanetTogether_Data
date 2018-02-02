SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*
Author:			Bryan Eddy
Date:			2/2/2018
Description:	Explode upwards to find where subcomponents are used in DJ and Std boms
Revision:		1
Update:			n/a


*/

CREATE FUNCTION [Setup].[fn_WhereUsedStdAndDJ] 
(
-- Input parameters
   @Component VARCHAR(100)
)
RETURNS
@WhereUsed TABLE
(
   ID INTEGER  IDENTITY(1,1) NOT NULL,
   Component VARCHAR(100) ,
   AssemblyItemNumber VARCHAR(100) NOT NULL, 
   ComponentItemNumber VARCHAR(100),
   ComponentQuantity REAL,
   --ExtendedQuantityPer decimal(18,10),
   [PrimaryUOM]  VARCHAR(50) 
   ,PRIMARY KEY (ID)
)

AS


BEGIN 

      -- add current level
   INSERT INTO @WhereUsed
   SELECT d.comp_item, d.item_number, d.comp_item,d.comp_qty_per,d.count_per_uom
   FROM ( SELECT d.comp_item, d.item_number, d.comp_item AS ComponentItemNumber,d.comp_qty_per,d.count_per_uom
			FROM [dbo].Oracle_BOMs d
		UNION 
		SELECT d.component_item, d.assembly_item, d.component_item AS ComponentItemNumber,d.quantity_per_assembly,d.count_per_uom
			FROM [dbo].Oracle_DJ_BOM d
		) d

   WHERE comp_item = @Component 
   ;


   -- --explode upward
   INSERT INTO @WhereUsed
   SELECT c.Component, n.AssemblyItemNumber, n.ComponentItemNumber,n.ComponentQuantity *C.ComponentQuantity ,n.[PrimaryUOM]
   FROM @WhereUsed c
   CROSS APPLY setup.[fn_WhereUsed](c.AssemblyItemNumber) n

   RETURN
END 

GO
