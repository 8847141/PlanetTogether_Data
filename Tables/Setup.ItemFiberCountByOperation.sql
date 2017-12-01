CREATE TABLE [Setup].[ItemFiberCountByOperation]
(
[ItemNumber] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TrueOperationCode] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PrimaryAlternate] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FiberCount] [int] NULL,
[CreatedBy] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__ItemFiber__Creat__76B698BF] DEFAULT (suser_sname()),
[DateCreated] [datetime] NULL CONSTRAINT [DF__ItemFiber__DateC__77AABCF8] DEFAULT (getdate()),
[RevisedBy] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__ItemFiber__Revis__789EE131] DEFAULT (suser_sname()),
[DateRevised] [datetime] NULL CONSTRAINT [DF__ItemFiber__DateR__7993056A] DEFAULT (getdate()),
[ItemFiberCountByOp_ID] [int] NOT NULL IDENTITY(10000, 1)
) ON [PRIMARY]
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
CREATE TRIGGER [Setup].[trg_RevisedItemFiberCountByOperation] 
   ON  [Setup].[ItemFiberCountByOperation] 
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		IF  UPDATE(FiberCount)
			BEGIN
			  UPDATE t
			  SET  t.DateRevised= GETDATE() , t.RevisedBy = (SUSER_SNAME()) 
			  FROM setup.[ItemFiberCountByOperation]  as t
			  JOIN inserted i
			  ON i.ItemFiberCountByOp_ID = t.ItemFiberCountByOp_ID 
		END 

END

GO
ALTER TABLE [Setup].[ItemFiberCountByOperation] ADD CONSTRAINT [PK_ItemFiberCountByOperation] PRIMARY KEY CLUSTERED  ([ItemNumber], [TrueOperationCode], [PrimaryAlternate]) ON [PRIMARY]
GO
