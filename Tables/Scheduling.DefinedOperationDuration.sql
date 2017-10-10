CREATE TABLE [Scheduling].[DefinedOperationDuration]
(
[MachineName] [nvarchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[True_Operation_Code] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Time_Minutes] [float] NULL CONSTRAINT [DF_DefinedOperationDuration_Time_Minutes] DEFAULT ((0)),
[RunTypeID] [int] NULL CONSTRAINT [DF_DefinedOperationDuration_RunTypeID] DEFAULT ((1)),
[CreatedBy] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__DefinedRu__Creat__3D7E1B63] DEFAULT (suser_sname()),
[DateCreated] [datetime] NULL CONSTRAINT [DF__DefinedRu__DateC__3E723F9C] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Scheduling].[DefinedOperationDuration] ADD CONSTRAINT [PK_DefinedRunRates] PRIMARY KEY CLUSTERED  ([MachineName], [True_Operation_Code]) ON [PRIMARY]
GO
ALTER TABLE [Scheduling].[DefinedOperationDuration] ADD CONSTRAINT [FK_DefinedRunRates_MachineNames] FOREIGN KEY ([MachineName]) REFERENCES [Setup].[MachineNames] ([MachineName]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [Scheduling].[DefinedOperationDuration] ADD CONSTRAINT [FK_DefinedRunRates_OperationRunType] FOREIGN KEY ([RunTypeID]) REFERENCES [Scheduling].[OperationRunType] ([RunTypeID]) ON DELETE SET NULL ON UPDATE CASCADE
GO
