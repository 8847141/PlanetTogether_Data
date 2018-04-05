SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
Author:			Bryan Eddy
Date:			3/16/18 
Description:	Explode upwards to find where subcomponents are used in DJ's
Revision:		1
Update:			n/a


*/

CREATE FUNCTION [Setup].[fn_WhereUsedDj]
(
-- Input parameters
   @ChildDj varchar(100)
)
returns
@WhereUsed table
(
   ID INTEGER  IDENTITY(1,1) NOT null,
   WhereUsedChildDj NVARCHAR(100),
	ConcOrderNumber NVARCHAR(100),
   ParentDj NVARCHAR(100) NULL,
   ChildDj NVARCHAR(100),
   AssembtlyItem NVARCHAR(100),
   PRIMARY KEY (ID)
)

AS

--CREATE INDEX IX_2 ON @WhereUsed (component)-- INCLUDE (assemblyitemnumber, ComponentItemNumber)
BEGIN 
      -- add current level
   insert into @WhereUsed
   select d.child_dj_number,d.conc_order_number, d.parent_dj_number, d.child_dj_number, d.assembly_item
   from [dbo].Oracle_Orders d
   --GROUP BY  ComponentItemNumber, AssemblyItemNumber,ComponentItemNumber
   WHERE d.child_dj_number = @ChildDj --AND [EffectivityDateTo] IS NULL 
   ;


   -- --explode upward
   insert into @WhereUsed
   select c.WhereUsedChildDj, n.ConcOrderNumber, n.ParentDj,n.ChildDj,n.AssembtlyItem
   from @WhereUsed c
   cross apply setup.fn_WhereUsedDj(C.ParentDj) n
   --GROUP BY c.Component, n.AssemblyItemNumber,n.ComponentItemNumber,n.ComponentQuantity
   --HAVING c.AssemblyItemNumber <> n.AssemblyItemNumber
   return
END 

GO
