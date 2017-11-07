SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



--/****** Script for SelectTopNRows command from SSMS  ******/


/* Bryan Eddy
	10/25/2017
	Daily update of all setups and machines for the scheduler to flag on/off*/
CREATE PROCEDURE [Scheduling].[usp_MachineCapabilitySchedulerUpdate]
AS

 SET NOCOUNT ON;
 BEGIN
	--Get setups from Setup DB
	INSERT INTO [Scheduling].[MachineCapabilityScheduler](Setup, MachineName, ActiveScheduling)
	SELECT K.Setup, K.MachineName, K.ActiveSetup
	FROM [Setup].[vSetupStatus] K
	LEFT JOIN [Scheduling].[MachineCapabilityScheduler] G  ON G.Setup = K.Setup AND g.MachineName = K.MachineName
	WHERE g.Setup IS NULL

	--Get setups from Setup Calculation
	INSERT INTO [Scheduling].[MachineCapabilityScheduler](Setup, MachineName, ActiveScheduling)
	SELECT DISTINCT K.Setup, K.MachineName, 1
	FROM setup.SetupStatusAll K LEFT JOIN [Scheduling].[MachineCapabilityScheduler] G  ON G.Setup = K.Setup AND g.MachineName = K.MachineName
	WHERE g.Setup IS NULL

	--Get setups from manually created scheduler
	INSERT INTO [Scheduling].[MachineCapabilityScheduler](Setup, MachineName, ActiveScheduling)
	SELECT DISTINCT K.True_Operation_Code, K.MachineName, 1
	FROM [Scheduling].[DefinedOperationDuration] K LEFT JOIN [Scheduling].[MachineCapabilityScheduler] G  ON G.Setup = K.True_Operation_Code AND g.MachineName = K.MachineName
	WHERE g.Setup IS NULL
END


GO
