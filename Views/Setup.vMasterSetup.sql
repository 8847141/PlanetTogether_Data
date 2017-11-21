SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO













-- =============================================
-- Author:      Bryan Eddy
-- Create date: 7/25/2017
-- Description: Get setup data from Setup DB for all machines
-- =============================================

CREATE VIEW [Setup].[vMasterSetup]
AS

SELECT DISTINCT K.SetupNumber,K.AttributeValue,K.AttributeNamE SetupAttributeName, K.AttributeID,G.AttributeNameID, P.AttributeName, I.MachineID, I.MachineName
  FROM [Setup].vInterfaceSetupAttributes K INNER JOIN Setup.ApsSetupAttributeReference G ON K.AttributeID = G.AttributeID
  INNER JOIN SETUP.ApsSetupAttributes P ON P.AttributeNameID = G.AttributeNameID
  INNER JOIN SETUP.MachineReference O ON O.PssMachineID = K.PssMachineID AND O.PssProcessID = K.PssProcessID
  INNER JOIN Setup.MachineNames I ON I.MachineID = o.MachineID














GO
