SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*
Author:		Bryan Eddy
Date:		4/9/2018
Desc:		View of capacity calendar
Version:	1
Update:		n/a
*/
CREATE VIEW [Scheduling].[vCapacityCalendar]
AS
SELECT *
FROM dbo._report_1b_capacity_calendar 
WHERE CalDay <= GETDATE()+365
GO
