CREATE TABLE [Setup].[AttributeDataType]
(
[DataTypeID] [int] NOT NULL IDENTITY(1, 1),
[DataType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedBy] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__Attribute__Creat__2724C5F0] DEFAULT (suser_sname()),
[DateCreated] [datetime] NULL CONSTRAINT [DF__Attribute__DateC__2818EA29] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Setup].[AttributeDataType] ADD CONSTRAINT [pk_AttributeDataType] PRIMARY KEY CLUSTERED  ([DataTypeID]) ON [PRIMARY]
GO
