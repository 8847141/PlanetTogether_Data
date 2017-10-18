CREATE TABLE [Setup].[MachineGroupAttributes]
(
[MachineGroupID] [int] NOT NULL,
[AttributeNameID] [int] NOT NULL,
[LogicType] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ValueTypeID] [int] NOT NULL,
[CreatedBy] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MachineAttributes_CreatedBy] DEFAULT (suser_sname()),
[DateCreated] [datetime] NULL CONSTRAINT [DF_MachineAttributes_DateCreated] DEFAULT (getdate()),
[ApsData] [bit] NULL CONSTRAINT [DF_MachineGroupAttributes_ApsData] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [Setup].[MachineGroupAttributes] ADD CONSTRAINT [CHK_logic] CHECK (([LogicType]='Consecutive' OR [LogicType]='Concurrent'))
GO
ALTER TABLE [Setup].[MachineGroupAttributes] ADD CONSTRAINT [PK_SetupMachineAttributes] PRIMARY KEY CLUSTERED  ([MachineGroupID], [AttributeNameID]) ON [PRIMARY]
GO
ALTER TABLE [Setup].[MachineGroupAttributes] ADD CONSTRAINT [FK_MachineAttributes_AttributeName] FOREIGN KEY ([AttributeNameID]) REFERENCES [Setup].[ApsSetupAttributes] ([AttributeNameID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [Setup].[MachineGroupAttributes] ADD CONSTRAINT [FK_MachineAttributes_MachineGroup] FOREIGN KEY ([MachineGroupID]) REFERENCES [Setup].[MachineGroup] ([MachineGroupID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [Setup].[MachineGroupAttributes] ADD CONSTRAINT [FK_MachineAttributes_ValueType] FOREIGN KEY ([ValueTypeID]) REFERENCES [Setup].[ApsSetupAttributeValueType] ([ValueTypeID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
