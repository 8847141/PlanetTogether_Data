CREATE TABLE [dbo].[Oracle_Items]
(
[ORG_ITEM_ID] [float] NOT NULL,
[organization_id] [bigint] NULL,
[oracle_item_id] [bigint] NULL,
[item_number] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_description] [varchar] (240) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[primary_uom_code] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inventory_item_status_code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_type] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lot_control] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[preprocessing_lead_time] [float] NULL,
[full_lead_time] [float] NULL,
[postprocessing_lead_time] [float] NULL,
[total_lead_time] [float] NULL,
[lot_size] [float] NULL,
[plan_constraint] [varchar] (240) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[make_buy] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[purchase_category] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[product_class] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[creation_date] [datetime] NULL,
[last_update_date] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Oracle_Items] ADD CONSTRAINT [PK_Oracle_Items] PRIMARY KEY CLUSTERED  ([ORG_ITEM_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Oracle_Items] ON [dbo].[Oracle_Items] ([inventory_item_status_code], [item_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Oracle_Items_1] ON [dbo].[Oracle_Items] ([item_number], [inventory_item_status_code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Oracle_Items_IX] ON [dbo].[Oracle_Items] ([make_buy]) INCLUDE ([item_description], [item_number], [product_class]) ON [PRIMARY]
GO
