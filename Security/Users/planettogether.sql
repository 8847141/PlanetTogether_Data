IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'planettogether')
CREATE LOGIN [planettogether] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [planettogether] FOR LOGIN [planettogether]
GO
