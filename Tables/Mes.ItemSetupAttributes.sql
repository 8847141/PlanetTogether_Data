CREATE TABLE [Mes].[ItemSetupAttributes]
(
[ItemSetupAttributeID] [uniqueidentifier] NOT NULL CONSTRAINT [DF__ItemSetup__ItemS__0559BDD1] DEFAULT (newid()),
[Item_Number] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Setup] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MachineID] [int] NOT NULL,
[AttributeNameID] [int] NOT NULL,
[AttributeValue] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateCreated] [datetime] NULL CONSTRAINT [DF__ItemSetup__DateC__064DE20A] DEFAULT (getdate()),
[DateRevised] [datetime] NULL CONSTRAINT [DF__ItemSetup__DateR__07420643] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Mes].[ItemSetupAttributes] ADD CONSTRAINT [pk_ItemSetupAttributes] PRIMARY KEY CLUSTERED  ([ItemSetupAttributeID]) ON [PRIMARY]
GO
ALTER TABLE [Mes].[ItemSetupAttributes] ADD CONSTRAINT [ix_UniqueItemSetupAttribute] UNIQUE NONCLUSTERED  ([Item_Number], [Setup], [MachineID], [AttributeNameID]) ON [PRIMARY]
GO
ALTER TABLE [Mes].[ItemSetupAttributes] ADD CONSTRAINT [IX_ItemSetupAttributes_1] UNIQUE NONCLUSTERED  ([Setup], [MachineID], [Item_Number], [AttributeNameID]) ON [PRIMARY]
GO
ALTER TABLE [Mes].[ItemSetupAttributes] ADD CONSTRAINT [FK_ItemSetupAttributes_ApsSetupAttributes] FOREIGN KEY ([AttributeNameID]) REFERENCES [Setup].[ApsSetupAttributes] ([AttributeNameID]) ON UPDATE CASCADE
GO
ALTER TABLE [Mes].[ItemSetupAttributes] ADD CONSTRAINT [FK_ItemSetupAttributes_MachineNames] FOREIGN KEY ([MachineID]) REFERENCES [Setup].[MachineNames] ([MachineID]) ON UPDATE CASCADE
GO
