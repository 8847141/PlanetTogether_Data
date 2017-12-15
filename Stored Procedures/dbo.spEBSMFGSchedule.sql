SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[spEBSMFGSchedule] @pBatchId nvarchar(50) = NULL
WITH EXEC AS CALLER
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
declare @ExportToEBS as nvarchar(250)
set @ExportToEBS = '"D:\PlanetTogether APS\Software\Publish\InterfacePTtoOracle" ' + @pBatchId
--set @ExportToEBS = 'd: && cd PlanetTogether APS\Software\ && dir *.*'
EXEC xp_cmdshell @ExportToEBS	

END
GO
