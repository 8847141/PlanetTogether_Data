SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



/*	Author: Bryan Eddy
	Date:	11/16/2017
	Desc:	Interface for Recipe Management System
	*/

	CREATE VIEW	[Setup].[vInterfaceRecipeManagementSystem]
	AS
    SELECT G.MachineID, G.MachineName, AttributeID, AttributeDesc, AttributeName, SetupNumber, AttributeValue, AttributeUOM, E.AttributeGroupID, E.AttributeGroupDesc
	,E.GroupViewOrder
	FROM Setup.vInterfaceSetupAttributes k INNER JOIN Setup.MachineReference I ON I.PssMachineID = K.PssMachineID AND I.PssProcessID = K.PssProcessID
	INNER JOIN Setup.MachineNames G ON G.MachineID = I.MachineID
	INNER JOIN setup.tblAttributesGroup E ON E.AttributeGroupID = k.AttributeGroupID AND E.AttributeGroupProcess = k.ProcessID
GO
