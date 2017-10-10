IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'NAA\v-mcmarry')
CREATE LOGIN [NAA\v-mcmarry] FROM WINDOWS
GO
CREATE USER [NAA\v-mcmarry] FOR LOGIN [NAA\v-mcmarry]
GO
