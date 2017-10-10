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

SELECT DISTINCT K.SetupNumber,K.AttributeValue,K.AttributeNamE SetupAttributeName, K.AttributeID, PlanetTogetherMachineNumber,G.AttributeNameID, P.AttributeName
  FROM [Setup].vInterfaceSetupAttributes K INNER JOIN Setup.ApsSetupAttributeReference G ON K.AttributeID = G.AttributeID
  INNER JOIN SETUP.ApsSetupAttributes P ON P.AttributeNameID = G.AttributeNameID
  --WHERE  AttributeID in (800006,800007,500002,500005,850002,850031,700002 ,700004,700001,700074,625004,625065)










GO
