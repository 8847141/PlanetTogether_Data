CREATE TABLE [dbo].[APS_Resources_QC_HardCoded]
(
[QCResourceID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QCDeptID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QCPlantID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ID] [uniqueidentifier] NOT NULL CONSTRAINT [DF__APS_Resource__ID__1CFC3D38] DEFAULT (newid())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[APS_Resources_QC_HardCoded] ADD CONSTRAINT [PK_APS_Resources_QC_HardCoded] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
