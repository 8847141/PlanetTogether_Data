CREATE TABLE [dbo].[_report_3g_pt_export]
(
[last_update_date] [datetime] NOT NULL,
[OrderNo] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PartNo] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SetupStartDate] [datetime] NULL,
[JobNumber] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Department] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RequiredResource] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ScheduleApproved] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Customer] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MachineName] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Quantity] [float] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
