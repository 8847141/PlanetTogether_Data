CREATE TABLE [dbo].[_report_3d_osp_component_demand]
(
[customer] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[order_number] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[part_number] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[department] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[job_number] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[alternate] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[job_status] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[request_date] [datetime] NULL,
[promise_date] [datetime] NULL,
[schedule_ship_date] [datetime] NULL,
[schedule_approved_date] [datetime] NULL,
[schedule_approved] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_update_date] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
