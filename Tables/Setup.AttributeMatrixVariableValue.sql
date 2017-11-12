CREATE TABLE [Setup].[AttributeMatrixVariableValue]
(
[AttributeNameID] [int] NOT NULL,
[MachineID] [int] NOT NULL,
[AttributeValue] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TimeValue] [float] NULL,
[Cost] [decimal] (8, 6) NULL,
[CreatedBy] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__VariableA__Creat__1881A0DE] DEFAULT (suser_sname()),
[DateCreated] [datetime] NULL CONSTRAINT [DF__VariableA__DateC__1975C517] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Setup].[AttributeMatrixVariableValue] ADD CONSTRAINT [PK_AttributeMatrixVariableValue] PRIMARY KEY CLUSTERED  ([AttributeNameID], [MachineID], [AttributeValue]) ON [PRIMARY]
GO
ALTER TABLE [Setup].[AttributeMatrixVariableValue] ADD CONSTRAINT [FK_AttributeMatrixVariableValue_ApsSetupAttributes] FOREIGN KEY ([AttributeNameID]) REFERENCES [Setup].[ApsSetupAttributes] ([AttributeNameID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [Setup].[AttributeMatrixVariableValue] ADD CONSTRAINT [FK_AttributeMatrixVariableValue_MachineNames] FOREIGN KEY ([MachineID]) REFERENCES [Setup].[MachineNames] ([MachineID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
