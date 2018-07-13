CREATE TABLE [dbo].[_report_9d_fiberset_lengths]
(
[FiberSet UDF] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[job] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Product] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[job_qty] [float] NULL,
[fiber_set_qty] [float] NULL,
[fiber_set_qty_max] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[percent_of_max] [float] NULL,
[last_update_date] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
