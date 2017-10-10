IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'NAA\simonda')
CREATE LOGIN [NAA\simonda] FROM WINDOWS
GO
CREATE USER [NAA\simonda] FOR LOGIN [NAA\simonda]
GO
