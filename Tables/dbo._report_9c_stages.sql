CREATE TABLE [dbo].[_report_9c_stages]
(
[last_update_date] [datetime] NOT NULL,
[job] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[qty] [float] NULL,
[assembly_item] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stage] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[conc_order_number] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customer] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[schedule_approved] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[promise_date] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
