CREATE TABLE [Setup].[MachineCapacityType]
(
[CapacityTypeID] [int] NOT NULL IDENTITY(1, 1),
[CapacityType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedBy] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Table_1_CreatedBy] DEFAULT (suser_sname()),
[DateCreated] [datetime] NULL CONSTRAINT [DF_Table_1_DateCreated] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Setup].[MachineCapacityType] ADD CONSTRAINT [PK_MachineCapacityType] PRIMARY KEY CLUSTERED  ([CapacityTypeID]) ON [PRIMARY]
GO
