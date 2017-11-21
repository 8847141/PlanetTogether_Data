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
    SELECT G.MachineID, G.MachineName, AttributeID, AttributeDesc, AttributeName, SetupNumber, AttributeValue, AttributeUOM
	FROM Setup.vInterfaceSetupAttributes k INNER JOIN Setup.MachineReference I ON I.PssMachineID = K.PssMachineID AND I.PssProcessID = K.PssProcessID
	INNER JOIN Setup.MachineNames G ON G.MachineID = I.MachineID
GO
