CREATE TABLE [Setup].[ItemAttributes]
(
[ItemNumber] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FiberCount] [int] NULL,
[DateCreated] [datetime] NULL CONSTRAINT [DF__ItemAttri__DateC__1387E197] DEFAULT (getdate()),
[CreatedBy] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__ItemAttri__Creat__147C05D0] DEFAULT (suser_sname()),
[CableColor] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Gel] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NominalOD] [float] NULL,
[DateRevised] [datetime] NULL CONSTRAINT [DF_ItemAttributes_DateRevised] DEFAULT (getdate()),
[RevisedBy] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContainsFiberIdBinders] [bit] NULL CONSTRAINT [DF_ItemAttributes_ContainsFiberIdBinders] DEFAULT ((0)),
[JacketMaterial] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FiberMeters] [float] NULL,
[ContainsBinder] [bit] NULL CONSTRAINT [DF_ItemAttributes_ContainsBinder] DEFAULT ((0))
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Bryan
-- Create date: 9/13/2017
-- Description:	Update revision information for Setup.ItemAttributes
-- =============================================
CREATE TRIGGER [Setup].[RecordUpdate_trgr] 
   ON  [Setup].[ItemAttributes] 
   AFTER INSERT,UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    	--Capture the user and time a change occured 
	BEGIN 
		IF NOT (UPDATE(DateRevised) or UPDATE(RevisedBy) or UPDATE(DateCreated) or Update(CreatedBy))
			BEGIN
			  UPDATE t
			  SET t.DateRevised = GETDATE() , t.RevisedBy = (SUSER_SNAME()) 
			  FROM Setup.ItemAttributes  as t
			  JOIN inserted i
			  ON i.ItemNumber = t.ItemNumber
			END
	END

END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Bryan Eddy
-- Create date: 11/1/2017
-- Description:	Update the date revised and revised by when a record is updated
-- Rev: 1
-- Update: Initial creation
-- =============================================
CREATE TRIGGER [Setup].[trg_RevisedItemAttributes] 
   ON  [Setup].[ItemAttributes] 
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		IF  NOT UPDATE(RevisedBy) OR UPDATE(DateRevised)
			BEGIN
			  UPDATE t
			  SET  t.DateRevised= GETDATE() , t.RevisedBy = (SUSER_SNAME()) 
			  FROM setup.[ItemFiberCountByOperation]  as t
			  JOIN inserted i
			  ON i.ItemNumber = t.ItemNumber 
		END 

END

GO
ALTER TABLE [Setup].[ItemAttributes] ADD CONSTRAINT [PK__ItemAttr__C28ACDB61FFC0AE3] PRIMARY KEY CLUSTERED  ([ItemNumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ItemAttributes_XI] ON [Setup].[ItemAttributes] ([FiberCount]) INCLUDE ([ItemNumber]) ON [PRIMARY]
GO
