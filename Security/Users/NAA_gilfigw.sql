IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'NAA\gilfigw')
CREATE LOGIN [NAA\gilfigw] FROM WINDOWS
GO
CREATE USER [NAA\gilfigw] FOR LOGIN [NAA\gilfigw]
GO
