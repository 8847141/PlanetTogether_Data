CREATE TABLE [Setup].[ColorSequencePreference]
(
[ColorID] [int] NOT NULL IDENTITY(100, 1),
[Color] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PreferedSequence] [int] NULL,
[CreatedBy] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__ColorSequ__Creat__3E3D3572] DEFAULT (suser_sname()),
[DateCreated] [datetime] NULL CONSTRAINT [DF__ColorSequ__DateC__3F3159AB] DEFAULT (getdate()),
[RevisedBy] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__ColorSequ__Revis__40257DE4] DEFAULT (suser_name()),
[DateRevised] [datetime] NULL CONSTRAINT [DF__ColorSequ__DateR__4119A21D] DEFAULT (getdate())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Bryan Eddy
-- Create date: 12/7/2017
-- Description:	Update the revised by and revised date fields
-- =============================================
CREATE TRIGGER [Setup].[trg_ColorSequencePrefered] 
   ON  [Setup].[ColorSequencePreference]
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
			  UPDATE t
			  SET t.DateRevised = GETDATE() , t.RevisedBy = (SUSER_SNAME()) 
			  FROM [Setup].[ColorSequencePreference]   as t
			  JOIN inserted i
			  ON i.ColorID = t.ColorID 

END
GO
ALTER TABLE [Setup].[ColorSequencePreference] ADD CONSTRAINT [PK_ColorSequencePreference] PRIMARY KEY CLUSTERED  ([ColorID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_ColorSequencePreference] ON [Setup].[ColorSequencePreference] ([Color]) ON [PRIMARY]
GO
