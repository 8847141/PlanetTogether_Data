CREATE TABLE [Setup].[MachineReference]
(
[MachineID] [int] NOT NULL,
[PssMachineID] [int] NOT NULL,
[MachineReferenceID] [int] NOT NULL IDENTITY(100, 1)
) ON [PRIMARY]
GO
ALTER TABLE [Setup].[MachineReference] ADD CONSTRAINT [PK_MachineReference] PRIMARY KEY CLUSTERED  ([MachineID], [PssMachineID]) ON [PRIMARY]
GO
ALTER TABLE [Setup].[MachineReference] ADD CONSTRAINT [fk_MachineID_MachineReference] FOREIGN KEY ([MachineID]) REFERENCES [Setup].[MachineNames] ([MachineID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
