CREATE TABLE [Setup].[AttributeSetupTimeItem]
(
[Item_Number] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Setup] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MachineGroupID] [int] NOT NULL,
[AttributeNameID] [int] NOT NULL,
[SetupAttributeValue] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedBy] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_AttributeItemSetupTime_CreatedBy] DEFAULT (suser_sname()),
[DateCreated] [datetime] NULL CONSTRAINT [DF_AttributeItemSetupTime_DateCreated] DEFAULT (getdate()),
[SetupTime] [float] NULL,
[MachineID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Setup].[AttributeSetupTimeItem] ADD CONSTRAINT [PK_AttributeItemSetupTime_1] PRIMARY KEY CLUSTERED  ([Item_Number], [Setup], [AttributeNameID], [MachineID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [AttributeSetupTimeItem_IXX] ON [Setup].[AttributeSetupTimeItem] ([MachineGroupID], [AttributeNameID]) INCLUDE ([Item_Number], [MachineID], [Setup], [SetupAttributeValue], [SetupTime]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [AttributeSetupTimeItem_XI] ON [Setup].[AttributeSetupTimeItem] ([Setup], [MachineID]) INCLUDE ([AttributeNameID], [MachineGroupID]) ON [PRIMARY]
GO
ALTER TABLE [Setup].[AttributeSetupTimeItem] ADD CONSTRAINT [FK_AttributeSetupTimeItem_ApsSetupAttributes] FOREIGN KEY ([AttributeNameID]) REFERENCES [Setup].[ApsSetupAttributes] ([AttributeNameID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [Setup].[AttributeSetupTimeItem] ADD CONSTRAINT [FK_AttributeSetupTimeItem_MachineNames] FOREIGN KEY ([MachineID], [MachineGroupID]) REFERENCES [Setup].[MachineNames] ([MachineID], [MachineGroupID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
