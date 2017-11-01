SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create VIEW [Setup].[vMissingSetupDataByOperation]
AS
WITH ctevMachine
AS(
SELECT DISTINCT I.Setup, I.MachineName, G.AttributeName, G.AttributeNameID, G.ValueTypeID, G.ValueTypeDescription
FROM            Setup.vMachineCapability AS I INNER JOIN
                         Setup.vMachineAttributes AS G ON I.MachineName = G.MachineName 
)
SELECT g.*
FROM     ctevMachine G LEFT JOIN Setup.vSetupTimesItem K ON G.MachineName = K.MachineName AND G.AttributeNameID = K.AttributeNameID
WHERE K.AttributeNameID IS NULL

GO
