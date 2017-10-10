IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'NAA\SPB_Scheduling_RO')
CREATE LOGIN [NAA\SPB_Scheduling_RO] FROM WINDOWS
GO
CREATE USER [NAA\SPB_Scheduling_RO] FOR LOGIN [NAA\SPB_Scheduling_RO]
GO
