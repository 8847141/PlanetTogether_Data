SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Setup].[vMissingSetupData]
AS
SELECT DISTINCT G.MachineName, G.AttributeName, G.AttributeNameID, G.ValueTypeID, G.ValueTypeDescription
FROM Setup.vSetupTimesItem K RIGHT JOIN Setup.vMachineAttributes G ON G.MachineName = K.MachineName AND G.AttributeNameID = K.AttributeNameID
WHERE K.MachineName IS NULL AND K.AttributeNameID IS NULL
GO
