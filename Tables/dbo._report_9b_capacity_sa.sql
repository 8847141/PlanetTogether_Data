CREATE TABLE [dbo].[_report_9b_capacity_sa]
(
[day] [date] NOT NULL,
[machine] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[department] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[plant] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[available_hours] [float] NULL,
[utilized_hours] [numeric] (17, 6) NOT NULL,
[output_qty] [float] NOT NULL,
[sa_type] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
