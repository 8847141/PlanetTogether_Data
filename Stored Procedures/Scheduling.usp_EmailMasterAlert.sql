SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*	Author:	Bryan Eddy
	Date:	11/18/2017
	Desc:	Master scheduling alert that has been added to the daily run job.	
*/

CREATE PROCEDURE [Scheduling].[usp_EmailMasterAlert]
AS

EXEC Scheduling. usp_EmailSchedulerMachineCapabilityIssue

GO
