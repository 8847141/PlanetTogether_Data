CREATE TABLE [dbo].[Oracle_POs]
(
[ORG_PO_LINE_ID] [float] NOT NULL,
[organization_id] [bigint] NULL,
[planner_code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[buyer_name] [varchar] (240) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vendor_name] [varchar] (240) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[po_number] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[line_num] [float] NULL,
[shipment_num] [float] NULL,
[category_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[oracle_item_id] [bigint] NULL,
[item_number] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mfg_part_number] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[promised_date] [datetime] NULL,
[need_by_date] [datetime] NULL,
[open_po_quantity] [float] NULL,
[unit_price] [float] NULL,
[extended_value] [float] NULL,
[line_comment] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[requisitioner_name] [varchar] (240) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UOM] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[po_quantity] [float] NULL,
[organization_code] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[received_quantity] [float] NULL,
[authorization_status] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[primary_uom_code] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[open_po_qty_primary] [float] NULL,
[unit_item_cost] [float] NULL,
[po_approval_date] [datetime] NULL,
[receipt_date] [datetime] NULL,
[po_creation_date] [datetime] NULL,
[last_60days] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[creation_date] [datetime] NULL,
[last_update_date] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Oracle_POs] ADD CONSTRAINT [PK_Oracle_POs] PRIMARY KEY CLUSTERED  ([ORG_PO_LINE_ID]) ON [PRIMARY]
GO
DENY DELETE ON  [dbo].[Oracle_POs] TO [NAA\SPB_Scheduling_RW]
GO
