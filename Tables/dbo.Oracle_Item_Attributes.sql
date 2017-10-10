CREATE TABLE [dbo].[Oracle_Item_Attributes]
(
[unique_id] [decimal] (38, 0) NOT NULL,
[organization_id] [bigint] NULL,
[oracle_item_id] [bigint] NULL,
[spec_id] [bigint] NULL,
[char_id] [bigint] NULL,
[item_number] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spec_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[attribute_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[attribute_value] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[creation_date] [datetime] NULL,
[last_update_date] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Oracle_Item_Attributes] ADD CONSTRAINT [PK_Oracle_Item_Attributes] PRIMARY KEY CLUSTERED  ([unique_id]) ON [PRIMARY]
GO
