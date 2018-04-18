IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'planettogether_RO')
CREATE LOGIN [planettogether_RO] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [planettogether_RO] FOR LOGIN [planettogether_RO] WITH DEFAULT_SCHEMA=[planettogether_RO]
GO
