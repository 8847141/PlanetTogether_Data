CREATE TABLE [Setup].[ItemSetupAttributes]
(
[Setup] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ItemNumber] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NominalOD] [decimal] (8, 5) NULL,
[NumberCorePositions] [int] NULL,
[UJCM] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateCreated] [datetime] NULL CONSTRAINT [DF__ItemSetup__DateC__5C02A283] DEFAULT (getdate()),
[DateRevised] [datetime] NULL CONSTRAINT [DF__ItemSetup__DateR__5CF6C6BC] DEFAULT (getdate()),
[JacketMaterial] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ItemSetupID] [uniqueidentifier] NOT NULL CONSTRAINT [DF__ItemSetup__ItemS__5DEAEAF5] DEFAULT (newid()),
[EndsOfAramid] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Bryan Eddy
-- Create date: 3/27/2018
-- Description:	Update the date revised and revised by when a record is updated
-- Rev: 1
-- Update: Initial creation
-- =============================================
CREATE TRIGGER [Setup].[trg_RevisedItemSetupAttribute] 
   ON  [Setup].[ItemSetupAttributes] 
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		IF  NOT(UPDATE(DateRevised))
			BEGIN
			  UPDATE t
			  SET  t.DateRevised= GETDATE() --, t.RevisedBy = (SUSER_SNAME()) 
			  FROM setup.ItemSetupAttributes  as t
			  JOIN inserted i
			  ON I.ItemSetupID = t.ItemSetupID 
		END 

END

GO
ALTER TABLE [Setup].[ItemSetupAttributes] ADD CONSTRAINT [PK_SetupAttributes] PRIMARY KEY CLUSTERED  ([ItemSetupID]) ON [PRIMARY]
GO
ALTER TABLE [Setup].[ItemSetupAttributes] ADD CONSTRAINT [IX_ItemSetupAttributes] UNIQUE NONCLUSTERED  ([Setup], [ItemNumber]) ON [PRIMARY]
GO
