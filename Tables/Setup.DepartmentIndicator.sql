CREATE TABLE [Setup].[DepartmentIndicator]
(
[department_code] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MachineName] [nvarchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Setup].[DepartmentIndicator] ADD CONSTRAINT [PK_DepartmentIndicator] PRIMARY KEY CLUSTERED  ([department_code]) ON [PRIMARY]
GO
ALTER TABLE [Setup].[DepartmentIndicator] ADD CONSTRAINT [FK_DepartmentIndicator_MachineNames] FOREIGN KEY ([MachineName]) REFERENCES [Setup].[MachineNames] ([MachineName]) ON DELETE SET NULL ON UPDATE CASCADE
GO
