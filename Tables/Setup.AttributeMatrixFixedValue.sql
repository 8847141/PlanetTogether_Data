CREATE TABLE [Setup].[AttributeMatrixFixedValue]
(
[AttributeNameID] [int] NOT NULL,
[MachineID] [int] NOT NULL,
[TimeValue] [float] NULL CONSTRAINT [DF_AttributeMatrixFixedValue_TimeValue] DEFAULT ((0)),
[Cost] [decimal] (8, 6) NULL,
[CreatedBy] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__FixedAttr__Creat__047AA831] DEFAULT (suser_sname()),
[DateCreated] [datetime] NULL CONSTRAINT [DF__FixedAttr__DateC__056ECC6A] DEFAULT (getdate()),
[Adder] [float] NULL CONSTRAINT [DF_AttributeMatrixFixedValue_Adder] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [Setup].[AttributeMatrixFixedValue] ADD CONSTRAINT [PK_FixedAttributeValueMatrix] PRIMARY KEY CLUSTERED  ([AttributeNameID], [MachineID]) ON [PRIMARY]
GO
ALTER TABLE [Setup].[AttributeMatrixFixedValue] ADD CONSTRAINT [FK_FixedAttributeValueMatrix_ApsSetupAttributes] FOREIGN KEY ([AttributeNameID]) REFERENCES [Setup].[ApsSetupAttributes] ([AttributeNameID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [Setup].[AttributeMatrixFixedValue] ADD CONSTRAINT [FK_FixedAttributeValueMatrix_MachineNames] FOREIGN KEY ([MachineID]) REFERENCES [Setup].[MachineNames] ([MachineID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
