CREATE TABLE [dbo].[Oracle_DJ_Processing_Times]
(
[unique_id] [decimal] (38, 0) NOT NULL,
[organization_code] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[wip_entity_name] [varchar] (240) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[op_sequence] [int] NULL,
[setup_start_time] [datetime] NULL,
[setup_end_time] [datetime] NULL,
[run_start_time] [datetime] NULL,
[run_end_time] [datetime] NULL,
[success_flag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reject_flag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reason_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[creation_date] [datetime] NULL,
[last_update_date] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Oracle_DJ_Processing_Times] ADD CONSTRAINT [PK_Oracle_DJ_Processing_Times] PRIMARY KEY CLUSTERED  ([unique_id]) ON [PRIMARY]
GO
