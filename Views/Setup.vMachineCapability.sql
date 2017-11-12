SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE VIEW [Setup].[vMachineCapability] 
AS
SELECT  SetupNumber AS Setup, I.MachineID, T.PssMachineID
FROM setup.tblProcessMachines G INNER JOIN SETUP.tblSetup K ON G.ProcessID = K.ProcessID AND G.MachineID = K.MachineID
INNER JOIN setup.MachineReference T ON T.PssMachineID = G.ProcessMachineID
INNER JOIN setup.MachineNames I ON T.MachineID = I.MachineID 
WHERE   K.IneffectiveDate >= GETDATE()  AND G.Active <> 0 AND SetupNumber IS NOT NULL AND LEN(SetupNumber) > 0







GO
