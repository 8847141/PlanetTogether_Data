IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'NAA\didonrt')
CREATE LOGIN [NAA\didonrt] FROM WINDOWS
GO
CREATE USER [NAA\didonrt] FOR LOGIN [NAA\didonrt]
GO
