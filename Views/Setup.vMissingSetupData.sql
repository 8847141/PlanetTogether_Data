SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
Author:		Bryan Eddy
Desc:		View to show attributes that are missing setup information from vSetupTimesItem
Date:		6/13/2018
Version:	2
Update:		Rewrote the view to accurately show missing setup data
*/

CREATE VIEW [Setup].[vMissingSetupData]
AS
WITH cteSetupTimesCalculated
AS(
	SELECT Setup, AttributeNameID, MachineID
	FROM            Setup.vSetupTimesItem 
),
cteMachineGroupAttributes
AS(
SELECT DISTINCT i.*, S.Setup, AttributeName, g.AttributeNameID, g.PassToAps
FROM                    setup.MachineGroupAttributes g INNER JOIN
                         Setup.MachineNames AS I ON I.MachineGroupID = G.MachineGroupID
						INNER JOIN Setup.vSetupLineSpeed S ON S.MachineID = I.MachineID
						INNER JOIN Setup.ApsSetupAttributes P ON P.AttributeNameID = g.AttributeNameID
--WHERE setup = 'J069'
)
SELECT DISTINCT G.Setup, g.AttributeName, g.AttributeNameID, g.MachineName, g.MachineID
FROM cteMachineGroupAttributes G LEFT JOIN  cteSetupTimesCalculated I ON I.Setup = G.Setup AND I.MachineID = G.MachineID  AND      I.AttributeNameID = G.AttributeNameID             
WHERE  i.setup IS NULL AND G.PassToAps = 1

GO
