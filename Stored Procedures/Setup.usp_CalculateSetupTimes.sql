SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:      Bryan Eddy
-- Create date: 8/11/2017
-- Description: Run series of procedurse for calculating the setup time
-- Version: 3
-- Update: Added [usp_MachineCapabilitySchedulerUpdate] to ensure any new setups from the calculated data are passed into the MachineCapabilityScheduler
-- =============================================

CREATE PROCEDURE [Setup].[usp_CalculateSetupTimes]
AS

BEGIN
SET NOCOUNT ON;
	--Calculate setup information from setup data
	EXEC setup.usp_CalculateSetupTimesFromSetupDB
	--Caclulate setup information from oracle data
	EXEC Setup.usp_CalculateSetupTimesFromOracle
	--Add any missing setups to the MachineCapabilityScheduler table to ensure they aren't filtered out
	EXEC [Scheduling].[usp_MachineCapabilitySchedulerUpdate]

END

GO
