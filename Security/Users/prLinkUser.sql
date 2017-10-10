IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'prLinkUser')
CREATE LOGIN [prLinkUser] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [prLinkUser] FOR LOGIN [prLinkUser]
GO
