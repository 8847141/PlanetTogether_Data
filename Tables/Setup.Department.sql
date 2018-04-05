CREATE TABLE [Setup].[Department]
(
[DepartmentID] [int] NOT NULL IDENTITY(1, 1),
[Department] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedBy] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__Departmen__Creat__44160A59] DEFAULT (suser_sname()),
[DateCreated] [datetime] NULL CONSTRAINT [DF__Departmen__DateC__450A2E92] DEFAULT (getdate()),
[PlantID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Setup].[Department] ADD CONSTRAINT [PK_Department] PRIMARY KEY CLUSTERED  ([DepartmentID]) ON [PRIMARY]
GO
ALTER TABLE [Setup].[Department] ADD CONSTRAINT [IX_Department] UNIQUE NONCLUSTERED  ([Department], [PlantID]) ON [PRIMARY]
GO
ALTER TABLE [Setup].[Department] ADD CONSTRAINT [FK_Department_Plant] FOREIGN KEY ([PlantID]) REFERENCES [Setup].[Plant] ([PlantID]) ON DELETE SET NULL ON UPDATE CASCADE
GO
