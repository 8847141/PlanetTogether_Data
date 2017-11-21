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
	SELECT Setup,MachineID, CASE WHEN Setups.Active = 0 THEN 0 ELSE 1 END ActiveSetup--,  Active, X.CountOf,
	FROM(
		SELECT DISTINCT Setup,p.MachineID, SUM(CASE WHEN ineffectivedate < GETDATE() THEN 0 ELSE 1 END) Active, COUNT(*) AS CountOf --,ineffectivedate
		FROM setup.vInterfaceAllMachineSetups E INNER JOIN SETUP.MachineReference p ON p.PssMachineID = e.PssMachineID and p.PssProcessID = e.PssProcessID
		 --INNER JOIN setup.MachineNames G ON G.MachineID = P.PssMachineID
		GROUP BY Setup,p.MachineID
		HAVING p.MachineID IS NOT NULL AND setup IS NOT NULL
	   )Setups
)
--INSERT INTO [Scheduling].[MachineCapabilityScheduler](Setup, MachineName, ActiveScheduling)
SELECT cteActiveSetups.Setup, cteActiveSetups.MachineID, cteActiveSetups.ActiveSetup
FROM cteActiveSetups
LEFT JOIN [Scheduling].[MachineCapabilityScheduler] G  ON G.Setup = cteActiveSetups.Setup AND g.MachineID = cteActiveSetups.MachineID
--WHERE g.Setup IS NULL




GO
