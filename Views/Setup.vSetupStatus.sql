SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*Bryan Eddy
11/1/2017
View of PSS DB's status of each setup for each line. */

CREATE VIEW [Setup].[vSetupStatus]
AS
WITH cteActiveSetups
AS (
	SELECT Setup,MachineName, CASE WHEN Setups.Active = 0 THEN 0 ELSE 1 END ActiveSetup--,  Active, X.CountOf,
	FROM(
		SELECT DISTINCT Setup,MachineName, SUM(CASE WHEN ineffectivedate < GETDATE() THEN 0 ELSE 1 END) Active, COUNT(*) AS CountOf --,ineffectivedate
		FROM setup.vInterfaceAllMachineSetups
		GROUP BY Setup,MachineName
		HAVING MachineName IS NOT NULL AND setup IS NOT NULL
	   )Setups
)
--INSERT INTO [Scheduling].[MachineCapabilityScheduler](Setup, MachineName, ActiveScheduling)
SELECT cteActiveSetups.Setup, cteActiveSetups.MachineName, cteActiveSetups.ActiveSetup
FROM cteActiveSetups
LEFT JOIN [Scheduling].[MachineCapabilityScheduler] G  ON G.Setup = cteActiveSetups.Setup AND g.MachineName = cteActiveSetups.MachineName
--WHERE g.Setup IS NULL

GO
