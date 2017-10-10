CREATE TABLE [Setup].[ApsSetupAttributeSource]
(
[SourceID] [int] NOT NULL IDENTITY(1000, 1),
[SourceName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DateCreated] [datetime] NULL CONSTRAINT [DF__ApsSetupA__DateC__25DB9BFC] DEFAULT (getdate()),
[CreatedBy] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__ApsSetupA__Creat__26CFC035] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [Setup].[ApsSetupAttributeSource] ADD CONSTRAINT [ApsSetupAttributeSource_IX] PRIMARY KEY CLUSTERED  ([SourceID]) ON [PRIMARY]
GO
ALTER TABLE [Setup].[ApsSetupAttributeSource] ADD CONSTRAINT [IX_ApsSetupAttributeSource] UNIQUE NONCLUSTERED  ([SourceName]) ON [PRIMARY]
GO
