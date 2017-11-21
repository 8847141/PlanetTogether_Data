SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO











CREATE VIEW [Setup].[vMachineCapability] 
AS
SELECT  SetupNumber AS Setup, I.MachineID--, T.PssMachineID
FROM Setup.vInterfaceMachineCapability K
INNER JOIN setup.MachineReference T ON T.PssMachineID = K.PssMachineID AND k.PssProcessID = t.PssProcessID
INNER JOIN setup.MachineNames I ON T.MachineID = I.MachineID 
WHERE   K.IneffectiveDate >= GETDATE()  AND K.Active <> 0 AND SetupNumber IS NOT NULL AND LEN(SetupNumber) > 0










GO
