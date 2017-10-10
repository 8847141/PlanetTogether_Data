CREATE TABLE [Setup].[tblAttributesGroup]
(
[AttributeGroupID] [int] NOT NULL,
[AttributeGroupProcess] [int] NOT NULL,
[AttributeGroupDesc] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Active] [bit] NOT NULL,
[GroupViewOrder] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Setup].[tblAttributesGroup] ADD CONSTRAINT [PK_tblAttributesGroup] PRIMARY KEY CLUSTERED  ([AttributeGroupID], [AttributeGroupProcess]) ON [PRIMARY]
GO
