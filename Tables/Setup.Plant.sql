CREATE TABLE [Setup].[Plant]
(
[Plant] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PlandID] [int] NOT NULL IDENTITY(1, 1),
[CreatedBy] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__Plant__CreatedBy__442B18F2] DEFAULT (suser_sname()),
[DateCreated] [datetime] NULL CONSTRAINT [DF__Plant__DateCreat__451F3D2B] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Setup].[Plant] ADD CONSTRAINT [PK_Plant] PRIMARY KEY CLUSTERED  ([Plant]) ON [PRIMARY]
GO
