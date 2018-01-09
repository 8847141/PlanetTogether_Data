SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
Author:		Bryan Eddy
Date:		1/9/2018
Desc:		Show setups and associated machines requiring engineering assist
			PT uses this data for scheduling in certain windows of time
Version:	1
Update:		Use indicators from current PSS system
*/

CREATE VIEW [Scheduling].[vEngineeringAssist]
AS

SELECT DISTINCT SetupNumber AS Setup, G.MachineID, 1 AS EngineeringAssist, I.MachineName
FROM [Setup].[vInterfaceSetupAttributes] K INNER JOIN Setup.MachineReference G ON K.PssMachineID = G.PssMachineID AND K.PssProcessID = G.PssProcessID
INNER JOIN Setup.MachineNames I ON I.MachineID = G.MachineID
WHERE AttributeValue IN ('Preliminary Industrialized','R & D')

GO
