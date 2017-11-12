CREATE TABLE [Setup].[DepartmentIndicator]
(
[department_code] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MachineID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Setup].[DepartmentIndicator] ADD CONSTRAINT [PK_DepartmentIndicator] PRIMARY KEY CLUSTERED  ([department_code]) ON [PRIMARY]
GO
ALTER TABLE [Setup].[DepartmentIndicator] ADD CONSTRAINT [FK_DepartmentIndicator_MachineNames] FOREIGN KEY ([MachineID]) REFERENCES [Setup].[MachineNames] ([MachineID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
