CREATE TABLE [dbo].[Oracle_Interface_Status]
(
[interface_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[interface_status] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[interface_last_processed_date] [datetime] NULL,
[last_update_date] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Oracle_Interface_Status] ADD CONSTRAINT [PK_Oracle_Interface_Status_1] PRIMARY KEY CLUSTERED  ([interface_name]) ON [PRIMARY]
GO
