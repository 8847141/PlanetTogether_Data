CREATE TABLE [dbo].[_report_9b_capacity]
(
[day] [date] NOT NULL,
[machine] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hours_available] [float] NOT NULL,
[hours_utilized] [numeric] (38, 6) NOT NULL,
[percent_utilized] [float] NULL,
[qty] [float] NOT NULL,
[last_update_date] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
