CREATE TABLE [Setup].[tblSetupAttributes]
(
[SetupID] [int] NOT NULL,
[AttributeID] [int] NOT NULL,
[IneffectiveDate] [datetime2] (0) NOT NULL,
[ProcessID] [int] NULL,
[MachineID] [int] NULL,
[EffectiveDate] [datetime2] (0) NULL,
[AttributeValue] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RequiredNew] [bit] NULL,
[RequiredEdit] [bit] NULL,
[ViewNew] [bit] NULL,
[ViewEdit] [bit] NULL,
[Comments] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MinTol] [float] NULL,
[MaxTol] [float] NULL,
[MachineSpecific] [bit] NULL,
[MinValue] [float] NULL,
[MaxValue] [float] NULL,
[EnteredBy] [int] NULL,
[EnteredOnDate] [datetime2] (0) NULL,
[PrintOnSetup] [bit] NULL,
[ApprovedBy] [int] NULL,
[ApprovedOnDate] [datetime2] (0) NULL,
[SSMA_TimeStamp] [timestamp] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Setup].[tblSetupAttributes] ADD CONSTRAINT [PK_tblSetupAttributes] PRIMARY KEY CLUSTERED  ([SetupID], [AttributeID], [IneffectiveDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblSetupAttributes] ON [Setup].[tblSetupAttributes] ([AttributeID], [IneffectiveDate], [SetupID], [MachineID], [AttributeValue]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblSetupAttributes_2] ON [Setup].[tblSetupAttributes] ([AttributeID], [IneffectiveDate], [SetupID], [ProcessID], [AttributeValue]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblSetupAttributes_1] ON [Setup].[tblSetupAttributes] ([IneffectiveDate], [SetupID], [AttributeID], [ProcessID], [AttributeValue]) ON [PRIMARY]
GO
