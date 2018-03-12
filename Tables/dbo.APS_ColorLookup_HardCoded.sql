CREATE TABLE [dbo].[APS_ColorLookup_HardCoded]
(
[afl_color_name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[web_color_name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ID] [uniqueidentifier] NOT NULL CONSTRAINT [DF__APS_ColorLoo__ID__1837881B] DEFAULT (newid())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[APS_ColorLookup_HardCoded] ADD CONSTRAINT [PK_APS_ColorLookup_HardCoded] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
