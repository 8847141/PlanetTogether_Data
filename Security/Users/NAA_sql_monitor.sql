IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'NAA\sql_monitor')
CREATE LOGIN [NAA\sql_monitor] FROM WINDOWS
GO
CREATE USER [NAA\sql_monitor] FOR LOGIN [NAA\sql_monitor]
GO
