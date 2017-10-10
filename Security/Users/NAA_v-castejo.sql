IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'NAA\v-castejo')
CREATE LOGIN [NAA\v-castejo] FROM WINDOWS
GO
CREATE USER [NAA\v-castejo] FOR LOGIN [NAA\v-castejo]
GO
