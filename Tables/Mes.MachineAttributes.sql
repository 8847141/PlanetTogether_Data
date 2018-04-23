CREATE TABLE [Mes].[MachineAttributes]
(
[MachineAttributeID] [int] NOT NULL IDENTITY(1, 1),
[MachineID] [int] NOT NULL,
[AttributeNameID] [int] NOT NULL,
[DateCreated] [datetime] NULL CONSTRAINT [DF__MachineAt__DateC__0A1E72EE] DEFAULT (getdate()),
[CreatedBy] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__MachineAt__Creat__0B129727] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [Mes].[MachineAttributes] ADD CONSTRAINT [PK_MachineAttributes] PRIMARY KEY CLUSTERED  ([MachineAttributeID]) ON [PRIMARY]
GO
ALTER TABLE [Mes].[MachineAttributes] ADD CONSTRAINT [IX_MachineAttributes] UNIQUE NONCLUSTERED  ([MachineID], [AttributeNameID]) ON [PRIMARY]
GO
ALTER TABLE [Mes].[MachineAttributes] ADD CONSTRAINT [FK_MachineAttributes_ApsSetupAttributes] FOREIGN KEY ([AttributeNameID]) REFERENCES [Setup].[ApsSetupAttributes] ([AttributeNameID]) ON UPDATE CASCADE
GO
ALTER TABLE [Mes].[MachineAttributes] ADD CONSTRAINT [FK_MachineAttributes_MachineNames] FOREIGN KEY ([MachineID]) REFERENCES [Setup].[MachineNames] ([MachineID]) ON UPDATE CASCADE
GO
