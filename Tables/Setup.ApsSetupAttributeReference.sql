CREATE TABLE [Setup].[ApsSetupAttributeReference]
(
[AttributeNameID] [int] NOT NULL,
[AttributeID] [int] NOT NULL,
[CreatedBy] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__ApsSetupA__Creat__6ABAD62E] DEFAULT (suser_sname()),
[DateCreated] [datetime] NULL CONSTRAINT [DF__ApsSetupA__DateC__6BAEFA67] DEFAULT (getdate()),
[timestamp] [timestamp] NULL,
[OracleAttribute] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SourceID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Setup].[ApsSetupAttributeReference] ADD CONSTRAINT [PK_ApsSetupAttributeReference] PRIMARY KEY CLUSTERED  ([AttributeID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ApsSetupAttributeReference] ON [Setup].[ApsSetupAttributeReference] ([AttributeID], [AttributeNameID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ApsSetupAttributeReference_1] ON [Setup].[ApsSetupAttributeReference] ([OracleAttribute], [AttributeNameID]) ON [PRIMARY]
GO
ALTER TABLE [Setup].[ApsSetupAttributeReference] ADD CONSTRAINT [FK_ApsSetupAttributeReference_ApsSetupAttributes] FOREIGN KEY ([AttributeNameID]) REFERENCES [Setup].[ApsSetupAttributes] ([AttributeNameID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [Setup].[ApsSetupAttributeReference] ADD CONSTRAINT [FK_ApsSetupAttributeReference_ApsSetupAttributeSource] FOREIGN KEY ([SourceID]) REFERENCES [Setup].[ApsSetupAttributeSource] ([SourceID]) ON DELETE SET NULL ON UPDATE CASCADE
GO
