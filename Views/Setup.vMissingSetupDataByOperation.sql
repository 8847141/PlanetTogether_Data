SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [Setup].[vMissingSetupDataByOperation]
AS
WITH ctevMachine
AS(
SELECT DISTINCT I.Setup, I.MachineID, G.AttributeName, G.AttributeNameID, G.ValueTypeID, G.ValueTypeDescription, k.MachineName
FROM            Setup.vMachineCapability AS I INNER JOIN
                         Setup.vMachineAttributes AS G ON I.machineid = G.machineid 
						 INNER JOIN Setup.MachineNames k ON k.MachineID = g.MachineID
)
SELECT g.*
FROM     ctevMachine G LEFT JOIN Setup.vSetupTimesItem K ON G.MachineID = K.MachineID AND G.AttributeNameID = K.AttributeNameID
WHERE K.AttributeNameID IS NULL



GO
