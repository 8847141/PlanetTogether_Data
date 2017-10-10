SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_ExplodeBOM] 
(
-- Input parameters
   @FinishedGood varchar(100)
)
returns
@BOM table
(
   -- Returned table layout
   FinishedGood varchar(100),
   item_number varchar(100), 
   comp_item varchar(100),
   comp_qty_per decimal(18,10),
   ExtendedQuantityPer decimal(18,10),
   primary_uom_code  varchar(50),
   BOMLevel int NULL,
   item_seq smallint,
   opseq smallint,
   unit_id int NULL,
   layer_id int NULL,
   count_per_uom int,
   alternate_designator  nvarchar(10)

)
as
begin
      -- add current level
   insert into @BOM
   select G.item_number, G.item_number, comp_item, comp_qty_per, 
    CASE WHEN G.basis_type = 'LOT' THEN comp_qty_per / Lot_Size ELSE comp_qty_per END
   ,primary_uom_code,1, item_seq, opseq, unit_id, layer_id,
	    COALESCE(count_per_uom,'1'),alternate_bom_designator
   from dbo.Oracle_BOMs G INNER JOIN dbo.Oracle_Items K ON G.item_number = K.item_number  
   where G.item_number = @FinishedGood AND ( getdate() <= disable_date OR disable_date IS NULL)

    --explode downward
   insert into @BOM
   select c.FinishedGood, n.item_number, n.comp_item, n.comp_qty_per
        , n.ExtendedQuantityPer * c.comp_qty_per,n.primary_uom_code,  
		n.BOMLevel+1, n.item_seq, n.opseq,n.unit_id,n.layer_id,
		 COALESCE(N.count_per_uom,'1'),c.alternate_designator
   from @BOM c
   cross apply dbo.[fn_ExplodeBOM](c.comp_item) n
   return
end


GO
