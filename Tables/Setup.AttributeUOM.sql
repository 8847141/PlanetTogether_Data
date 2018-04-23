CREATE TABLE [Setup].[AttributeUOM]
(
[UnitOfMeasureID] [int] NOT NULL IDENTITY(1, 1),
[UnitOfMeasure] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DateCreated] [datetime] NULL CONSTRAINT [DF__ItemAttri__DateC__1590259A] DEFAULT (getdate()),
[CreatedBy] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__ItemAttri__Creat__168449D3] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [Setup].[AttributeUOM] ADD CONSTRAINT [pk_ItemAttributeUOM] PRIMARY KEY CLUSTERED  ([UnitOfMeasureID]) ON [PRIMARY]
GO
ALTER TABLE [Setup].[AttributeUOM] ADD CONSTRAINT [IX_ItemAttributeUOM] UNIQUE NONCLUSTERED  ([UnitOfMeasure]) ON [PRIMARY]
GO
