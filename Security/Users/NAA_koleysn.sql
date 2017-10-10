IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'NAA\koleysn')
CREATE LOGIN [NAA\koleysn] FROM WINDOWS
GO
CREATE USER [NAA\koleysn] FOR LOGIN [NAA\koleysn]
GO
