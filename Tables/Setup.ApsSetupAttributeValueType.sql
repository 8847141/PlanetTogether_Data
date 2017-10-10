CREATE TABLE [Setup].[ApsSetupAttributeValueType]
(
[ValueTypeID] [int] NOT NULL IDENTITY(1, 1),
[ValueTypeName] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ValueTypeDescription] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedBy] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__ApsSetupA__Creat__11D4A34F] DEFAULT (suser_sname()),
[DateCreated] [datetime] NULL CONSTRAINT [DF__ApsSetupA__DateC__12C8C788] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Setup].[ApsSetupAttributeValueType] ADD CONSTRAINT [PK_ApsSetupAttributeValueType] PRIMARY KEY CLUSTERED  ([ValueTypeID]) ON [PRIMARY]
GO
ALTER TABLE [Setup].[ApsSetupAttributeValueType] ADD CONSTRAINT [I_ApsSetupAttributeValueType] UNIQUE NONCLUSTERED  ([ValueTypeName]) ON [PRIMARY]
GO
