SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



/*Author:	Bryan Eddy
	Date:	11/12/2017
	Desc:	View for scheduler to see what setups have been deactivated
	*/

CREATE VIEW [Scheduling].[vMachineCapabilityScheduler]
AS
SELECT I.MachineID, I.MachineName, K.Setup, K.ActiveScheduling,K.InactiveReason, K.EngineeringAssist,K.EngineeringAssistReason,K.ActiveStatusChangedBy, k.ActiveStatusChangedDate
FROM scheduling.MachineCapabilityScheduler K INNER JOIN SETUP.MachineNames I ON I.MachineID = K.MachineID

GO
