CREATE TABLE [dbo].[_report_3h_mrp]
(
[job_id] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[order_number] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[produced_item] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[op_code] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[op_id] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[op_start] [datetime] NULL,
[consumed_item] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[consumed_item_req_qty] [float] NULL,
[op_qty] [float] NULL,
[job_qty] [float] NULL,
[last_update_date] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
