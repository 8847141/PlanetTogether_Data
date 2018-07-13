CREATE TABLE [Setup].[AttributeMatrixFromTo]
(
[AttributeNameID] [int] NOT NULL,
[MachineID] [int] NOT NULL,
[FromAttribute] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ToAttribute] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TimeValue] [float] NOT NULL,
[CreatedBy] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__FromToAtt__Creat__3335971A] DEFAULT (suser_sname()),
[DateCreated] [datetime] NULL CONSTRAINT [DF__FromToAtt__DateC__3429BB53] DEFAULT (getdate()),
[cost] [decimal] (8, 6) NULL,
[RevisedBy] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_AttributeMatrixFromTo_UpdatedBy] DEFAULT (suser_sname()),
[DateRevised] [datetime] NULL CONSTRAINT [DF_AttributeMatrixFromTo_DateRevised] DEFAULT (getdate()),
[GUIID] [uniqueidentifier] NULL CONSTRAINT [DF__Attribute__GUIID__412F7C0D] DEFAULT (newid())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Bryan Eddy
-- Create date: 7/2/2018
-- Description:	Trigger to update revision fields
-- =============================================
CREATE TRIGGER [Setup].[FromToMatrix_Trgr] 
   ON  [Setup].[AttributeMatrixFromTo] 
   AFTER INSERT,DELETE,UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	IF NOT (UPDATE(RevisedBy) OR UPDATE(DateRevised))
		BEGIN
			UPDATE T
			SET RevisedBy = SUSER_SNAME(), DateRevised = GETDATE()
			FROM Setup.AttributeMatrixFromTo T INNER JOIN Inserted I ON I.GUIID = T.GUIID
		END

END
GO
ALTER TABLE [Setup].[AttributeMatrixFromTo] ADD CONSTRAINT [PK_FromToAttributeMatrix] PRIMARY KEY CLUSTERED  ([AttributeNameID], [MachineID], [FromAttribute], [ToAttribute]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_AttributeMatrixFromTo] ON [Setup].[AttributeMatrixFromTo] ([GUIID]) ON [PRIMARY]
GO
ALTER TABLE [Setup].[AttributeMatrixFromTo] ADD CONSTRAINT [FK_FromToAttributeMatrix_ApsSetupAttributes] FOREIGN KEY ([AttributeNameID]) REFERENCES [Setup].[ApsSetupAttributes] ([AttributeNameID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [Setup].[AttributeMatrixFromTo] ADD CONSTRAINT [FK_FromToAttributeMatrix_MachineNames] FOREIGN KEY ([MachineID]) REFERENCES [Setup].[MachineNames] ([MachineID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
