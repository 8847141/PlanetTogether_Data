IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'NAA\service_spbcable')
CREATE LOGIN [NAA\service_spbcable] FROM WINDOWS
GO
CREATE USER [naa\service_spbcable] FOR LOGIN [NAA\service_spbcable]
GO
