CREATE TABLE [dbo].[_report_3f_mrg_fiber]
(
[StartDate] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderLine] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchedDate] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PromDate] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Final_Assembly] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FiberKM] [float] NULL,
[ScheduleApproved] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FiberItem] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerName] [nvarchar] (360) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderQty] [float] NULL,
[Department] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UnitsPerFG] [float] NULL,
[Scheduler] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OffsetWeekStart] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OffsetMonthYear] [nvarchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SumOfStartUp_Scrap] [float] NULL,
[ComponentUOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UOM] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JobID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportSource] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartDateTime] [datetime] NULL
) ON [PRIMARY]
GO
