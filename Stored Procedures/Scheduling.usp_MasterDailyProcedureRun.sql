SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Bryan Eddy
-- Create date: 10/6/2017
-- Description:	Run all major operations for setup and item attributes
-- =============================================
CREATE PROCEDURE [Scheduling].[usp_MasterDailyProcedureRun]
AS

	SET NOCOUNT ON;
BEGIN
	
	EXEC dbo.usp_NormalizeRouting

	EXEC dbo.usp_NormalizeRouting_DJ

	EXEC [Setup].[usp_LoadFromToMatrix]

	EXEC [Setup].[usp_GetItemAttributeData]

	EXEC [Setup].[usp_CalculateSetupTimes]

	EXEC Scheduling.usp_GetNewSubinventory

END
GO
