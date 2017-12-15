CREATE TABLE [Setup].[AttributeSetupTime]
(
[Setup] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MachineGroupID] [int] NOT NULL,
[AttributeNameID] [int] NOT NULL,
[SetupAttributeValue] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedBy] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ApsSetupAttributeValue_CreatedBy] DEFAULT (suser_sname()),
[DateCreated] [datetime] NULL CONSTRAINT [DF_ApsSetupAttributeValue_DateCreated] DEFAULT (getdate()),
[SetupTime] [float] NULL,
[MachineID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Setup].[AttributeSetupTime] ADD CONSTRAINT [PK_ApsSetupAttributeValue_1] PRIMARY KEY CLUSTERED  ([Setup], [AttributeNameID], [MachineID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_AttributeSetupTime] ON [Setup].[AttributeSetupTime] ([MachineGroupID], [AttributeNameID]) INCLUDE ([MachineID], [Setup], [SetupAttributeValue], [SetupTime]) ON [PRIMARY]
GO
ALTER TABLE [Setup].[AttributeSetupTime] ADD CONSTRAINT [FK_ApsSetupAttributeValue_MachineNames] FOREIGN KEY ([MachineID], [MachineGroupID]) REFERENCES [Setup].[MachineNames] ([MachineID], [MachineGroupID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [Setup].[AttributeSetupTime] ADD CONSTRAINT [FK_AttributeSetupTime_ApsSetupAttributes] FOREIGN KEY ([AttributeNameID]) REFERENCES [Setup].[ApsSetupAttributes] ([AttributeNameID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
