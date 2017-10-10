CREATE TABLE [Setup].[tblSetup]
(
[SetupID] [int] NOT NULL,
[ProcessID] [int] NULL,
[SetupNumber] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SetupDesc] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EffectiveDate] [datetime2] (0) NULL,
[IneffectiveDate] [datetime2] (0) NULL,
[EnteredBy] [int] NULL,
[EnteredOnDate] [datetime2] (0) NULL,
[Comments] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ApprovedOnDate] [datetime2] (0) NULL,
[ApprovedBy] [int] NULL,
[Status] [int] NULL,
[MachineID] [int] NULL,
[SSMA_TimeStamp] [timestamp] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Setup].[tblSetup] ADD CONSTRAINT [PK_tblSetup] PRIMARY KEY CLUSTERED  ([SetupID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblSetup] ON [Setup].[tblSetup] ([ProcessID], [MachineID], [IneffectiveDate], [SetupID], [SetupNumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblSetup_1] ON [Setup].[tblSetup] ([SetupNumber], [IneffectiveDate], [ProcessID], [MachineID]) ON [PRIMARY]
GO
