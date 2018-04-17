CREATE TABLE [dbo].[_report_9a_bobbin_usage_release]
(
[Job] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Op] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderNumber] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProductName] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UsageDate] [datetime] NULL,
[BobbinCount] [int] NULL,
[BobbinStageUsageDurationDays] [float] NULL,
[last_update_date] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
