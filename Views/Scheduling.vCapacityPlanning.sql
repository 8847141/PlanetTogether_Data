SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*
Author:		Bryan Eddy
Date:		4/9/2018
Desc:		View of capacity planning ifnromation.
Version:	1
Update:		n/a
*/
CREATE VIEW [Scheduling].[vCapacityPlanning]
AS
SELECT DATEADD(wk, 0, DATEADD(DAY, 1-DATEPART(WEEKDAY, setup_start_date), DATEDIFF(dd, 0, setup_start_date))) WeekStartDate,*
FROM _report_1a_capacity_planning 
WHERE setup_start_date >= GETDATE() -365
GO
