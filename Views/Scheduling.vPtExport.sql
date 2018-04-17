SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Scheduling].[vPtExport]
AS
SELECT  DATEADD(wk, 0, DATEADD(DAY, 1-DATEPART(WEEKDAY, SetupStartDate), DATEDIFF(dd, 0, SetupStartDate))) AS WeekStartDate,*
FROM dbo._report_3g_pt_export 
GO
