SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
Author:		Bryan Eddy
Date:		4/18/2018
Desc:		Displays setups that are active in the PSS system, but scheduler has blocked the ability for the setup to schedule
			Used in email alerts and reporting
Version:	1
Update.
*/

CREATE VIEW [Scheduling].[vSchedulerMachineCapabilityIssue]
AS

	--IF OBJECT_ID(N'tempdb..#NotSchedulingSetups', N'U') IS NOT NULL
	--DROP TABLE #NotSchedulingSetups;

	--IF OBJECT_ID(N'tempdb..#Results', N'U') IS NOT NULL
	--DROP TABLE #Results;
	WITH cteSchedulingActive  --Determine what can schedule
	AS(
		SELECT DISTINCT G.SETUP
		FROM setup.[vSetupStatus] K INNER JOIN Scheduling.MachineCapabilityScheduler G ON G.SETUP = K.Setup AND G.MachineID = K.Machineid
		WHERE G.ActiveScheduling = 1
		)
	,cteNotSchedulignSetups
	AS(
	SELECT DISTINCT K.Setup AS Setup  
	--INTO #NotSchedulingSetups
	FROM setup.[vSetupStatus] K LEFT JOIN cteSchedulingActive G ON G.Setup = K.Setup
	WHERE G.Setup IS NULL AND k.Machineid IS NOT NULL AND K.ActiveSetup = 1
	)
	
	SELECT DISTINCT K.MachineID,K.Setup, k.ActiveScheduling, G.ActiveSetup, K.ActiveStatusChangedBy, K.ActiveStatusChangedDate, P.MachineName
	--INTO #Results
	FROM cteNotSchedulignSetups I INNER JOIN setup.vSetupStatus G ON G.Setup = I.Setup
	INNER JOIN Scheduling.MachineCapabilityScheduler K ON K.SETUP = I.Setup
	INNER JOIN setup.MachineNames P ON P.MachineID = K.MachineID
	WHERE G.ActiveSetup = 1
GO
