SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--/****** Script for SelectTopNRows command from SSMS  ******/


/* Bryan Eddy
	10/25/2017
	Daily update of all setups and machines for the scheduler to flag on/off*/
CREATE PROCEDURE [Scheduling].[MachineCapabilitySchedulerUpdate]
AS

 SET NOCOUNT ON;


INSERT INTO [Scheduling].[MachineCapabilityScheduler](Setup, MachineName, ActiveScheduling)
SELECT K.Setup, K.MachineName, K.ActiveSetup
FROM [Setup].[vSetupStatus] K
LEFT JOIN [Scheduling].[MachineCapabilityScheduler] G  ON G.Setup = K.Setup AND g.MachineName = K.MachineName
WHERE g.Setup IS NULL


GO
