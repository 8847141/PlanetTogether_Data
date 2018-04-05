CREATE TABLE [dbo].[_report_1b_capacity_calendar]
(
[last_update_date] [datetime] NOT NULL,
[IntervalName] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DurationHrs] [float] NULL,
[StartDateTime] [datetime] NULL,
[CalDay] [date] NULL,
[CalMonth] [date] NULL,
[CalWeek] [date] NULL,
[EndDateTime] [datetime] NULL,
[IntervalType] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NbrOfPeople] [float] NULL,
[machine_name] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[department_name] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[plant_name] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RunEffenciency] [float] NULL,
[SetupEffenciency] [float] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
