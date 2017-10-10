CREATE TABLE [Setup].[MachineGroup]
(
[MachineGroupName] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MachineGroupID] [int] NOT NULL IDENTITY(1, 1),
[CreatedBy] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__MachineGr__Creat__0D44F85C] DEFAULT (suser_sname()),
[DateCreated] [datetime] NULL CONSTRAINT [DF__MachineGr__DateC__0E391C95] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Setup].[MachineGroup] ADD CONSTRAINT [PK_MachineGroup] PRIMARY KEY CLUSTERED  ([MachineGroupID]) ON [PRIMARY]
GO
ALTER TABLE [Setup].[MachineGroup] ADD CONSTRAINT [I_MachineGroup] UNIQUE NONCLUSTERED  ([MachineGroupName]) ON [PRIMARY]
GO
