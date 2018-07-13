CREATE TABLE [dbo].[_report_9b_capacity]
(
[day] [date] NOT NULL,
[machine] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[machine_capacity_type] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[department] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[plant] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hours_available] [float] NOT NULL,
[hours_utilized] [numeric] (38, 6) NOT NULL,
[hours_utilized_bottlenecked] [numeric] (38, 6) NOT NULL,
[hours_utilized_late] [numeric] (38, 6) NOT NULL,
[percent_utilized] [float] NULL,
[percent_utilized_bottlenecked] [float] NULL,
[percent_utilized_late] [float] NULL,
[qty] [float] NOT NULL,
[last_update_date] [datetime] NOT NULL,
[planning_horizon_end_date] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
