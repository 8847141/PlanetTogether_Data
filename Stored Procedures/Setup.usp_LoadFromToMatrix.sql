SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:		Bryan Eddy
-- Create date: 8/1/2017
-- Description:	Master procedure to run all other procedures to create setup logic
-- Version: 1
-- Update:	Added error handling
-- =============================================
CREATE PROCEDURE [Setup].[usp_LoadFromToMatrix]

AS

	SET NOCOUNT ON;
BEGIN

--EXEC dbo.usp_CreateSetupTables

--DELETE FROM setup.AttributeMatrixFromTo

EXEC Setup.usp_CreateSheathingMatrix

EXEC Setup.usp_CreateOpgwPipeMatrix

EXEC Setup.usp_CreateSzMatrix

EXEC Setup.usp_CreateBufferingMatrix

END



GO
