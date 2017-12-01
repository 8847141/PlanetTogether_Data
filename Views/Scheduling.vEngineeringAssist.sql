SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Scheduling].[vEngineeringAssist]
AS
SELECT K.EngineeringAssist, G.MachineName, G.MachineID, K.Setup
FROM Scheduling.MachineCapabilityScheduler K INNER JOIN Setup.MachineNames G ON G.MachineID = K.MachineID
WHERE K.EngineeringAssist = 1
GO
