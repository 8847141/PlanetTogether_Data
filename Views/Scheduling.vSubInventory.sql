SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  CREATE VIEW [Scheduling].[vSubInventory]
  as 
  SELECT [SubinventoryID]
      ,[SubinventoryName]
      ,[SubDescription]
      ,[SendToAPS]
  FROM [Scheduling].[Subinventory]

GO
