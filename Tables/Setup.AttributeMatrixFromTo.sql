CREATE TABLE [Setup].[AttributeMatrixFromTo]
(
[AttributeNameID] [int] NOT NULL,
[MachineID] [int] NOT NULL,
[FromAttribute] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ToAttribute] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TimeValue] [float] NOT NULL,
[CreatedBy] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__FromToAtt__Creat__3335971A] DEFAULT (suser_sname()),
[DateCreated] [datetime] NULL CONSTRAINT [DF__FromToAtt__DateC__3429BB53] DEFAULT (getdate()),
[cost] [decimal] (8, 6) NULL
) ON [PRIMARY]
GO
ALTER TABLE [Setup].[AttributeMatrixFromTo] ADD CONSTRAINT [PK_FromToAttributeMatrix] PRIMARY KEY CLUSTERED  ([AttributeNameID], [MachineID], [FromAttribute], [ToAttribute]) ON [PRIMARY]
GO
ALTER TABLE [Setup].[AttributeMatrixFromTo] ADD CONSTRAINT [FK_FromToAttributeMatrix_ApsSetupAttributes] FOREIGN KEY ([AttributeNameID]) REFERENCES [Setup].[ApsSetupAttributes] ([AttributeNameID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [Setup].[AttributeMatrixFromTo] ADD CONSTRAINT [FK_FromToAttributeMatrix_MachineNames] FOREIGN KEY ([MachineID]) REFERENCES [Setup].[MachineNames] ([MachineID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
