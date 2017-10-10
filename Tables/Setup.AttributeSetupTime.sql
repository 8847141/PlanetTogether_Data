CREATE TABLE [Setup].[AttributeSetupTime]
(
[Setup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MachineGroupID] [int] NOT NULL,
[AttributeNameID] [int] NOT NULL,
[SetupAttributeValue] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedBy] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ApsSetupAttributeValue_CreatedBy] DEFAULT (suser_sname()),
[DateCreated] [datetime] NULL CONSTRAINT [DF_ApsSetupAttributeValue_DateCreated] DEFAULT (getdate()),
[SetupTime] [float] NULL,
[MachineName] [nvarchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Setup].[AttributeSetupTime] ADD CONSTRAINT [PK_ApsSetupAttributeValue_1] PRIMARY KEY CLUSTERED  ([Setup], [AttributeNameID], [MachineName]) ON [PRIMARY]
GO
ALTER TABLE [Setup].[AttributeSetupTime] ADD CONSTRAINT [FK_ApsSetupAttributeValue_MachineNames] FOREIGN KEY ([MachineName], [MachineGroupID]) REFERENCES [Setup].[MachineNames] ([MachineName], [MachineGroupID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
