CREATE TABLE [Setup].[MissingSetups]
(
[Setup] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DateCreated] [datetime] NOT NULL CONSTRAINT [DF__SetupsMis__DateC__0D2FE9C3] DEFAULT (getdate()),
[DateMostRecentAppearance] [datetime] NULL CONSTRAINT [DF_SetupsMissing_DateClosed] DEFAULT (getdate()),
[SetupMissingID] [int] NOT NULL IDENTITY(100, 1)
) ON [PRIMARY]
GO
ALTER TABLE [Setup].[MissingSetups] ADD CONSTRAINT [pk_SetupsMissing] PRIMARY KEY CLUSTERED  ([SetupMissingID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_SetupsMissing] ON [Setup].[MissingSetups] ([Setup]) ON [PRIMARY]
GO
