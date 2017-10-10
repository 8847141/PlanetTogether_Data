IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'NAA\SPB_Scheduling_RW')
CREATE LOGIN [NAA\SPB_Scheduling_RW] FROM WINDOWS
GO
CREATE USER [NAA\SPB_Scheduling_RW] FOR LOGIN [NAA\SPB_Scheduling_RW]
GO
