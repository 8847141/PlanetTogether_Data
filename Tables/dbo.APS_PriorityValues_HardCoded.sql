CREATE TABLE [dbo].[APS_PriorityValues_HardCoded]
(
[priority_type] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[schedule_approved] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[priority_number] [float] NULL,
[ID] [uniqueidentifier] NOT NULL CONSTRAINT [DF__APS_Priority__ID__20CCCE1C] DEFAULT (newid())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[APS_PriorityValues_HardCoded] ADD CONSTRAINT [PK_APS_PriorityValues_HardCoded] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
