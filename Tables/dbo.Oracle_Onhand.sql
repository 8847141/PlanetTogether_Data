CREATE TABLE [dbo].[Oracle_Onhand]
(
[organization_id] [bigint] NULL,
[organization_code] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[oracle_item_id] [bigint] NULL,
[item_number] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_description] [varchar] (240) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[serial_code] [float] NULL,
[onhand_qty] [float] NULL,
[subinventory_code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[locator_id] [bigint] NULL,
[item_locator] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lot_number] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[serial_number] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[primary_uom_code] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[product_class] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[creation_date] [datetime] NULL,
[last_update_date] [datetime] NULL,
[unique_id] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Oracle_Onhand] ADD CONSTRAINT [PK_Oracle_onhand] PRIMARY KEY CLUSTERED  ([unique_id]) ON [PRIMARY]
GO
