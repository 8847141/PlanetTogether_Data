CREATE TABLE [dbo].[APS_BobbinAssignment_HardCoded]
(
[ResourceID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BobbinType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ID] [uniqueidentifier] NOT NULL CONSTRAINT [DF__APS_BobbinAs__ID__155B1B70] DEFAULT (newid())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[APS_BobbinAssignment_HardCoded] ADD CONSTRAINT [PK_APS_BobbinAssignment_HardCoded] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
