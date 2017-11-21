CREATE TABLE [Setup].[ItemFiberCountByOperation]
(
[ItemNumber] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TrueOperationCode] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PrimaryAlternate] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FiberCount] [int] NULL,
[CreatedBy] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__ItemFiber__Creat__76B698BF] DEFAULT (suser_sname()),
[DateCreated] [datetime] NULL CONSTRAINT [DF__ItemFiber__DateC__77AABCF8] DEFAULT (getdate()),
[RevisedBy] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__ItemFiber__Revis__789EE131] DEFAULT (suser_sname()),
[DateRevised] [datetime] NULL CONSTRAINT [DF__ItemFiber__DateR__7993056A] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Setup].[ItemFiberCountByOperation] ADD CONSTRAINT [PK_ItemFiberCountByOperation] PRIMARY KEY CLUSTERED  ([ItemNumber], [TrueOperationCode], [PrimaryAlternate]) ON [PRIMARY]
GO
