SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO












-- =============================================
-- Author:		Bryan Eddy
-- Create date: 9/14/2017
-- Description:	Interface view of needed information from the Recipe Management Syste / PSS DB
-- =============================================
CREATE VIEW [Setup].[vInterfaceSetupLineSpeed]
AS
	SELECT K.SetupNumber,E.AttributeValue, k.SetupDesc, b.MachineID AS PssMachineID, B.ProcessID AS PssProcessID,I.AttributeID,
	ROW_NUMBER() OVER (PARTITION BY K.SetupNumber,B.MachineID,B.ProcessID ORDER BY K.SetupNumber,b.MachineID,E.AttributeValue,B.ProcessID  ASC ) AS RowNumber
	 FROM  Setup.tblSetup K
	 INNER JOIN setup.tblSetupAttributes E ON E.SetupID = K.SetupID
	 INNER JOIN [Setup].[tblAttributes] I ON E.AttributeID = I.AttributeID
	 INNER JOIN setup.tblProcessMachines B ON B.MachineID = K.MachineID
	 AND B.ProcessID = E.ProcessID
	 WHERE I.AttributeName LIKE 'LINESPEED' 
	  --and K.IneffectiveDate > GETDATE() 
	  AND I.AttrIneffectiveDate > GETDATE()
	 AND e.IneffectiveDate > GETDATE() --AND E.ProcessID NOT IN (510,523,615,850)
	 AND b.Active <> 0 AND K.IneffectiveDate >= GETDATE()
	 










GO
