CREATE TABLE [dbo].[Oracle_Interface_Status]
(
[interface_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[interface_status] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[interface_last_processed_date] [datetime] NULL,
[last_update_date] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Bryan Eddy
-- Create date: 4/16/2018
-- Description:	Detect if Oracle_DJ_BOM interface has been update
-- =============================================
CREATE TRIGGER [dbo].[trgr_RecordCountAlert]
   ON [dbo].[Oracle_Interface_Status]
   AFTER Update
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @NumRows AS int

    IF  UPDATE(interface_status)
		BEGIN
			SELECT @NumRows =  COUNT(*) FROM Inserted I INNER JOIN dbo.Oracle_Interface_Status J ON I.interface_name = J.interface_name
			 WHERE J.interface_name = 'Oracle_DJ_BOM' AND I.interface_status = 'Complete'

			IF @NumRows > 0
			BEGIN
				EXEC dbo.usp_EmailOracleTableRecordCount
			END

		END 

END
GO
ALTER TABLE [dbo].[Oracle_Interface_Status] ADD CONSTRAINT [PK_Oracle_Interface_Status_1] PRIMARY KEY CLUSTERED  ([interface_name]) ON [PRIMARY]
GO
DENY DELETE ON  [dbo].[Oracle_Interface_Status] TO [NAA\SPB_Scheduling_RW]
GO
