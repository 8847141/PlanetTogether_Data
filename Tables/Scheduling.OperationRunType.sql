CREATE TABLE [Scheduling].[OperationRunType]
(
[RunTypeID] [int] NOT NULL IDENTITY(1, 1),
[RunTypeDesc] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedBy] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__Operation__Creat__3118447E] DEFAULT (suser_sname()),
[DateCreated] [datetime] NULL CONSTRAINT [DF__Operation__DateC__320C68B7] DEFAULT (getdate()),
[RunType] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Scheduling].[OperationRunType] ADD CONSTRAINT [PK_OperationRunType] PRIMARY KEY CLUSTERED  ([RunTypeID]) ON [PRIMARY]
GO
