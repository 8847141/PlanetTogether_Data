CREATE TABLE [dbo].[Oracle_BOMs]
(
[ORG_ITEM_ID] [decimal] (38, 0) NOT NULL,
[organization_id] [bigint] NULL,
[oracle_item_id] [bigint] NULL,
[item_number] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inventory_item_status_code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[alternate_bom_designator] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[product_class] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_seq] [float] NULL,
[opseq] [float] NULL,
[comp_item] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[make_buy] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[comp_qty_per] [float] NULL,
[effectivity_date] [datetime] NULL,
[wip_supply_type] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[count_per_uom] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[layer_id] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unit_id] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_update_date] [datetime] NULL,
[creation_date] [datetime] NULL,
[disable_date] [datetime] NULL,
[basis_type] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Oracle_BOMs] ADD CONSTRAINT [PK_Oracle_BOMs] PRIMARY KEY CLUSTERED  ([ORG_ITEM_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>] ON [dbo].[Oracle_BOMs] ([comp_item]) INCLUDE ([alternate_bom_designator], [item_number], [layer_id], [opseq], [unit_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IIX_Oracle_BOMs] ON [dbo].[Oracle_BOMs] ([comp_item]) INCLUDE ([alternate_bom_designator], [item_number], [layer_id], [opseq], [unit_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Oracle_BOMs_1] ON [dbo].[Oracle_BOMs] ([comp_item], [item_number], [inventory_item_status_code], [opseq]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Oracle_BOMs] ON [dbo].[Oracle_BOMs] ([item_number], [opseq], [inventory_item_status_code], [comp_item]) ON [PRIMARY]
GO
DENY DELETE ON  [dbo].[Oracle_BOMs] TO [NAA\SPB_Scheduling_RW]
GO
