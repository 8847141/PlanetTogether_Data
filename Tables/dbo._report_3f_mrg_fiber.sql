CREATE TABLE [dbo].[_report_3f_mrg_fiber]
(
[last_update_date] [datetime] NOT NULL,
[StartDate] [date] NULL,
[OrderLine] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchedDate] [date] NULL,
[PromDate] [date] NULL,
[Final_Assembly] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FiberKM] [float] NULL,
[ScheduleApproved] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FiberItem] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerName] [varchar] (360) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderQty] [float] NULL,
[Department] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UnitsPerFG] [float] NULL,
[Scheduler] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OffsetWeekStart] [date] NULL,
[OffsetMonthYear] [nvarchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SumOfStartUp_Scrap] [float] NULL,
[ComponentUOM] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UOM] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JobID] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportSource] [int] NULL,
[StartDateTime] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
