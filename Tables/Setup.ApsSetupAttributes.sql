CREATE TABLE [Setup].[ApsSetupAttributes]
(
[AttributeName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedBy] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__ApsSetupA__Creat__36470DEF] DEFAULT (suser_sname()),
[DateCreated] [datetime] NULL CONSTRAINT [DF__ApsSetupA__DateC__373B3228] DEFAULT (getdate()),
[AttributeNameID] [int] NOT NULL IDENTITY(1, 1),
[DataTypeID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Setup].[ApsSetupAttributes] ADD CONSTRAINT [PK_ApsSetupAttributes] PRIMARY KEY CLUSTERED  ([AttributeNameID]) ON [PRIMARY]
GO
ALTER TABLE [Setup].[ApsSetupAttributes] ADD CONSTRAINT [I_ApsSetupAttributes] UNIQUE NONCLUSTERED  ([AttributeName]) ON [PRIMARY]
GO
ALTER TABLE [Setup].[ApsSetupAttributes] ADD CONSTRAINT [FK_ApsSetupAttributes_AttributeDataType] FOREIGN KEY ([DataTypeID]) REFERENCES [Setup].[AttributeDataType] ([DataTypeID]) ON DELETE SET NULL ON UPDATE CASCADE
GO
