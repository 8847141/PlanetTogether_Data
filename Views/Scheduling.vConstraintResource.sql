SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Bryan Eddy
-- Create date: 9/15/2017
-- Description:	Interface view for PT to get resource contraints
-- =============================================
CREATE VIEW [Scheduling].[vConstraintResource]
as

SELECT MachineName, NominalOD, Max_Length, MaxFiberCount, Binder
FROM scheduling.ConstraintResource
	 

GO
