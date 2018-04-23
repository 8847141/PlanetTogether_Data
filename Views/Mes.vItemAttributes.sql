SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****** Script for SelectTopNRows command from SSMS  ******/

/*
Author:		Bryan Eddy
Date:		4/23/2018
Desc:		Provide MES with attribute information
Version:	1
Update:		n/a
*/


CREATE VIEW [Mes].[vItemAttributes]
as

SELECT k.*,j.MachineName, i.AttributeName, p.DataType, e.UnitOfMeasure
  FROM [Mes].[ItemSetupAttributes] K INNER JOIN Setup.ApsSetupAttributes I ON I.AttributeNameID = K.AttributeNameID
  LEFT JOIN Setup.AttributeDataType p ON p.DataTypeID = I.DataTypeID
  LEFT JOIN Setup.AttributeUOM e ON e.UnitOfMeasureID = I.UnitOfMeasureID
  INNER JOIN Setup.MachineNames j ON j.MachineID = K.MachineID
GO
