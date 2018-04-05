SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
Author:		Bryan Eddy
Date:		3/28/2018
Desc:		List of procedures to run when the schedule is published
Version:	1
Update:		n/a
*/

CREATE PROC [Scheduling].[usp_RunOnPublish]
AS
BEGIN

EXEC Scheduling.usp_EmailSchedulePublishNotification
EXEC setup.GetItemSetupAttributes




end
GO
