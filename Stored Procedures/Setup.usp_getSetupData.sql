SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:      Bryan Eddy
-- Create date: 12/4/2017
-- Description: Procedure to call SSIS package for PSS setup data import
-- Version:		1
-- Update:		N/A			
-- =============================================

CREATE PROCEDURE [Setup].[usp_getSetupData]

AS
BEGIN


	DECLARE @DB VARCHAR(100);
	DECLARE @Package VARCHAR(100);
	SET @DB = DB_NAME();
	--SELECT @db

	IF @DB LIKE '%DEV'
		SET @Package = 'SetupIndex_Import _APS_Dev.dtsx';
	ELSE IF @DB LIKE '%TEST'
		SET @Package = 'SetupIndex_Import _APS_Test.dtsx';
	ELSE IF @DB LIKE '%Prod'
		SET @Package = 'SetupIndex_Import _APS_Prod.dtsx';


	DECLARE @SQLQuery AS VARCHAR(2000)

	SET @SQLQuery = '\\NAACAB-SCH01\Binn\DTEXEC.exe /F ^"\\NAACAB-SCH01\ImportFiles\AFL\' + @Package + '^" '

	EXEC master..xp_cmdshell @SQLQuery OUTPUT

END

GO
GRANT EXECUTE ON  [Setup].[usp_getSetupData] TO [NAA\gilfigw]
GO
GRANT EXECUTE ON  [Setup].[usp_getSetupData] TO [NAA\SPB_Scheduling_RW]
GO
