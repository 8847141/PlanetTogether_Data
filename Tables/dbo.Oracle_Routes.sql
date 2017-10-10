CREATE TABLE [dbo].[Oracle_Routes]
(
[Unique_ID] [decimal] (38, 0) NOT NULL,
[organization_id] [bigint] NULL,
[item_number] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_description] [varchar] (240) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[alternate_routing_designator] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_type] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[operation_seq_num] [float] NULL,
[standard_operation_id] [bigint] NULL,
[operation_code] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[department_id] [bigint] NULL,
[disable_date] [datetime] NULL,
[department_code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[start_up_scrap] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pass_to_aps] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[setup_item] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[creation_date] [datetime] NULL,
[last_update_date] [datetime] NULL,
[true_operation_code] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[true_operation_seq_num] [float] NULL,
[Effectivity_date] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Oracle_Routes] ADD CONSTRAINT [PK_Oracle_Routes] PRIMARY KEY CLUSTERED  ([Unique_ID]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Oracle_Routes] ON [dbo].[Oracle_Routes] ([item_number], [alternate_routing_designator], [operation_seq_num], [setup_item]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Oracle_Routes_1] ON [dbo].[Oracle_Routes] ([true_operation_code], [item_number], [operation_seq_num]) ON [PRIMARY]
GO
