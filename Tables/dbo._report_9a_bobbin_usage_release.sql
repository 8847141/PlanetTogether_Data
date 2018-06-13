CREATE TABLE [dbo].[_report_9a_bobbin_usage_release]
(
[ProductName] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UsageDate] [datetime] NULL,
[BobbinCount] [int] NULL,
[BobbinStageUsageDurationDays] [float] NOT NULL,
[last_update_date] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
