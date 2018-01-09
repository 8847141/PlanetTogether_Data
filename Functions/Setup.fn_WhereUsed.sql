SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
Author:			Bryan Eddy
Date:			12/15/2017
Description:	Explode upwards to find where subcomponents are used.
Revision:		1
Update:			n/a


*/

CREATE FUNCTION [Setup].[fn_WhereUsed] 
(
-- Input parameters
   @Component varchar(100)
)
returns
@WhereUsed table
(
   ID INTEGER  IDENTITY(1,1) NOT null,
   Component varchar(100) ,
   AssemblyItemNumber varchar(100) not null, 
   ComponentItemNumber varchar(100),
   ComponentQuantity real,
   --ExtendedQuantityPer decimal(18,10),
   [PrimaryUOM]  varchar(50) 
   ,PRIMARY KEY (ID)
)

AS

--CREATE INDEX IX_2 ON @WhereUsed (component)-- INCLUDE (assemblyitemnumber, ComponentItemNumber)
BEGIN 
      -- add current level
   insert into @WhereUsed
   select d.comp_item, d.item_number, d.comp_item,d.comp_qty_per,d.count_per_uom
   from [dbo].Oracle_BOMs d
   --GROUP BY  ComponentItemNumber, AssemblyItemNumber,ComponentItemNumber
   WHERE comp_item = @Component --AND [EffectivityDateTo] IS NULL 
   ;


   -- --explode upward
   insert into @WhereUsed
   select c.Component, n.AssemblyItemNumber, n.ComponentItemNumber,n.ComponentQuantity *C.ComponentQuantity ,n.[PrimaryUOM]
   from @WhereUsed c
   cross apply setup.[fn_WhereUsed](c.AssemblyItemNumber) n
   --GROUP BY c.Component, n.AssemblyItemNumber,n.ComponentItemNumber,n.ComponentQuantity
   --HAVING c.AssemblyItemNumber <> n.AssemblyItemNumber
   return
END 

GO
