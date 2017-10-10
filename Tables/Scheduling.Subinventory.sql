CREATE TABLE [Scheduling].[Subinventory]
(
[SubinventoryID] [int] NOT NULL IDENTITY(1000, 1),
[SubinventoryName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SubDescription] [nvarchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SendToAPS] [bit] NULL CONSTRAINT [DF__Subinvent__SendT__51851410] DEFAULT ((1)),
[CreatedBy] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__Subinvent__Creat__52793849] DEFAULT (suser_sname()),
[DateCreated] [datetime] NULL CONSTRAINT [DF__Subinvent__DateC__536D5C82] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Scheduling].[Subinventory] ADD CONSTRAINT [PK_Subinventory] PRIMARY KEY CLUSTERED  ([SubinventoryName]) ON [PRIMARY]
GO
