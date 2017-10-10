SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:      Bryan Eddy
-- Create date: 8/11/2017
-- Description: Run series of procedurse for calculating the setup time
-- =============================================

CREATE PROCEDURE [Setup].[usp_CalculateSetupTimes]
as

BEGIN
SET NOCOUNT ON;

	DELETE FROM setup.AttributeSetupTime

	DELETE FROM SETUP.AttributeSetupTimeItem

	EXEC setup.usp_CalculateSetupTimesFromSetupDB

	EXEC Setup.usp_CalculateSetupTimesFromOracle

END

GO
