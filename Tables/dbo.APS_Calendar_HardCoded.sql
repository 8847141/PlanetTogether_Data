CREATE TABLE [dbo].[APS_Calendar_HardCoded]
(
[calendar_name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[machine_name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[start] [datetime] NULL,
[end] [datetime] NULL,
[interval_type] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
