CREATE TABLE [dbo].[APS_Calendar_HardCoded]
(
[calendar_name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[machine_name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[start] [datetime] NULL,
[end] [datetime] NULL,
[interval_type] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ID] [uniqueidentifier] NOT NULL CONSTRAINT [DF__APS_Calendar__ID__174363E2] DEFAULT (newid())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[APS_Calendar_HardCoded] ADD CONSTRAINT [PK_APS_Calendar_HardCoded] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
