CREATE TABLE [Setup].[AttributeSetupTimeItem]
(
[Item_Number] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Setup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MachineGroupID] [int] NOT NULL,
[AttributeNameID] [int] NOT NULL,
[SetupAttributeValue] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedBy] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_AttributeItemSetupTime_CreatedBy] DEFAULT (suser_sname()),
[DateCreated] [datetime] NULL CONSTRAINT [DF_AttributeItemSetupTime_DateCreated] DEFAULT (getdate()),
[SetupTime] [float] NULL,
[MachineName] [nvarchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Setup].[AttributeSetupTimeItem] ADD CONSTRAINT [PK_AttributeItemSetupTime_1] PRIMARY KEY CLUSTERED  ([Item_Number], [Setup], [AttributeNameID], [MachineName]) ON [PRIMARY]
GO
ALTER TABLE [Setup].[AttributeSetupTimeItem] ADD CONSTRAINT [FK_AttributeItemSetupTime_MachineNames] FOREIGN KEY ([MachineName], [MachineGroupID]) REFERENCES [Setup].[MachineNames] ([MachineName], [MachineGroupID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
