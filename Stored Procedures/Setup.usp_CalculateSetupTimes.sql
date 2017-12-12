SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:      Bryan Eddy
-- Create date: 8/11/2017
-- Description: Run series of procedurse for calculating the setup time
-- Version: 2
-- Update: Removed delete from statements and added truncate table statements to the procedures
-- =============================================

CREATE PROCEDURE [Setup].[usp_CalculateSetupTimes]
AS

BEGIN
SET NOCOUNT ON;

	EXEC setup.usp_CalculateSetupTimesFromSetupDB

	EXEC Setup.usp_CalculateSetupTimesFromOracle

END

GO
