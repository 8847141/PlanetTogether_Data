CREATE TABLE [dbo].[_report_2a_mes_downtime]
(
[last_update_date] [datetime] NOT NULL,
[EquipmentLine] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JobID] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JobType] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartTime] [datetime] NULL,
[EndTime] [datetime] NULL,
[Duration] [int] NULL,
[ModifiedFlag] [int] NOT NULL,
[ProcessedFlag] [int] NOT NULL,
[ModifiedDate] [int] NULL,
[CreatedDate] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
