/*
This migration script replaces uncommitted changes made to these objects:
RJTEst

Use this script to make necessary schema and data changes for these objects only. Schema changes to any other objects won't be deployed.

Schema changes and migration scripts are deployed in the order they're committed.

Migration scripts must not reference static data. When you deploy migration scripts alongside static data 
changes, the migration scripts will run first. This can cause the deployment to fail. 
Read more at https://documentation.red-gate.com/display/SOC6/Static+data+and+migrations.
*/

SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
PRINT N'Dropping constraints from [dbo].[RJTEst]'
GO
ALTER TABLE [dbo].[RJTEst] DROP CONSTRAINT [PK__RJTEst__D86D1816BE9882BC]
GO
PRINT N'Dropping [dbo].[RJTEst]'
GO
DROP TABLE [dbo].[RJTEst]
GO

