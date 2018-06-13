SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*	Author:	Bryan Eddy
	Date:	11/18/2017
	Desc:	Master scheduling alert that has been added to the daily run job.	
	Version:	2
	Update:		Added email alert for missing material demand
*/

CREATE PROCEDURE [Scheduling].[usp_EmailMasterAlert]
AS
BEGIN
	EXEC Scheduling. usp_EmailSchedulerMachineCapabilityIssue

	EXEC [Setup].usp_EmailMissingMaterialAttribute

	EXEC [Setup].[usp_EmailMissingDjSetup]

	EXEC Scheduling.usp_EmailSchedulingMissingLineSpeed

	EXEC Scheduling.usp_EmailAlertMissingMaterialDemand

	EXEC [Scheduling].[usp_EmailAlertMissingMaterialDemandDj]

	EXEC Scheduling.usp_EmailOrdersStaleMaterials

END
GO
