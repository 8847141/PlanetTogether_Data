SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Setup].[vInterfaceMachineCapability]
AS
SELECT K.SetupNumber, G.ProcessID AS PssProcessID, g.MachineID AS PssMachineID, K.IneffectiveDate, g.Active
FROM setup.tblProcessMachines G INNER JOIN SETUP.tblSetup K ON G.ProcessID = K.ProcessID AND G.MachineID = K.MachineID
GO
