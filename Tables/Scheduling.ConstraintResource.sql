CREATE TABLE [Scheduling].[ConstraintResource]
(
[MachineID] [int] NOT NULL,
[NominalOD] [float] NOT NULL,
[Max_Length] [int] NULL,
[MaxFiberCount] [int] NULL,
[Binder] [bit] NOT NULL CONSTRAINT [DF_ConstraintResource_Binder] DEFAULT ((0)),
[CreatedBy] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__Constrain__Creat__5EDF0F2E] DEFAULT (suser_sname()),
[DateCreated] [datetime] NULL CONSTRAINT [DF__Constrain__DateC__5FD33367] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Scheduling].[ConstraintResource] ADD CONSTRAINT [PK_ConstraintResource] PRIMARY KEY CLUSTERED  ([MachineID], [NominalOD], [Binder]) ON [PRIMARY]
GO
ALTER TABLE [Scheduling].[ConstraintResource] ADD CONSTRAINT [FK_ConstraintResource_MachineNames] FOREIGN KEY ([MachineID]) REFERENCES [Setup].[MachineNames] ([MachineID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
