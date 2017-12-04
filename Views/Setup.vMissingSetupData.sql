SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE VIEW [Setup].[vMissingSetupData]
AS
SELECT DISTINCT I.MachineName, G.AttributeName, G.AttributeNameID, G.ValueTypeID, G.ValueTypeDescription, g.MachineID
FROM Setup.vSetupTimesItem K RIGHT JOIN Setup.vMachineAttributes G ON G.machineID = K.machineID AND G.AttributeNameID = K.AttributeNameID
INNER JOIN Setup.MachineNames I ON I.MachineID = G.MachineID
WHERE k.MachineID IS NULL AND K.AttributeNameID IS NULL AND g.PassToAps = 1




GO
