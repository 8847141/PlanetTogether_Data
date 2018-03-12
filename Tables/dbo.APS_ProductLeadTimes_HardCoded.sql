CREATE TABLE [dbo].[APS_ProductLeadTimes_HardCoded]
(
[ProductAttribute1Id] [int] NULL,
[Name] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MfgLeadTime] [float] NULL,
[ID] [uniqueidentifier] NOT NULL CONSTRAINT [DF__APS_ProductL__ID__1A1FD08D] DEFAULT (newid())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[APS_ProductLeadTimes_HardCoded] ADD CONSTRAINT [PK_APS_ProductLeadTimes_HardCoded] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
