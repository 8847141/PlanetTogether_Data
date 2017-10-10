CREATE TABLE [Setup].[MachineNames]
(
[MachineID] [int] NOT NULL IDENTITY(1, 1),
[MachineName] [nvarchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MachineGroupID] [int] NULL,
[Plant] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Department] [nvarchar] (70) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShareResource] [bit] NULL,
[timestamp] [timestamp] NULL,
[Grouping] [bit] NULL CONSTRAINT [DF_MachineNames_Grouping] DEFAULT ((1)),
[CapacityTypeID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Setup].[MachineNames] ADD CONSTRAINT [PK_MachineNames] PRIMARY KEY CLUSTERED  ([MachineID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_MachineNames] ON [Setup].[MachineNames] ([MachineName]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_MachineNames_1] ON [Setup].[MachineNames] ([MachineName], [MachineGroupID]) ON [PRIMARY]
GO
ALTER TABLE [Setup].[MachineNames] ADD CONSTRAINT [FK_MachineNames_MachineCapacityType] FOREIGN KEY ([CapacityTypeID]) REFERENCES [Setup].[MachineCapacityType] ([CapacityTypeID]) ON DELETE SET NULL ON UPDATE CASCADE
GO
ALTER TABLE [Setup].[MachineNames] ADD CONSTRAINT [FK_MachineNames_MachineGroup] FOREIGN KEY ([MachineGroupID]) REFERENCES [Setup].[MachineGroup] ([MachineGroupID]) ON DELETE SET NULL ON UPDATE CASCADE
GO
ALTER TABLE [Setup].[MachineNames] ADD CONSTRAINT [FK_MachineNames_Plant] FOREIGN KEY ([Plant]) REFERENCES [Setup].[Plant] ([Plant]) ON DELETE SET NULL ON UPDATE CASCADE
GO
