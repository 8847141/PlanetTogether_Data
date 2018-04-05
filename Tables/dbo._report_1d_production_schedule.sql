CREATE TABLE [dbo].[_report_1d_production_schedule]
(
[last_update_date] [datetime] NOT NULL,
[JobID] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OpID] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JobRequiredQty] [float] NULL,
[OpRequiredQty] [float] NULL,
[assembly_item] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EquipmentLine] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProductionStatus] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ScheduledSetupHours] [float] NULL,
[ScheduledRunHours] [float] NULL,
[ScheduledTotalHours] [float] NULL,
[ScheduledStartDate] [datetime] NULL,
[ScheduledEndOfSetupDate] [datetime] NULL,
[ScheduledEndDate] [datetime] NULL,
[schedule_approved] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[min_schedule_ship_date] [datetime] NULL,
[min_promise_date] [datetime] NULL,
[min_need_by_date] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
