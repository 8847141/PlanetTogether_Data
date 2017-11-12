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
AS

SELECT  MachineName, NominalOD, Max_Length, MaxFiberCount, Binder, G.MachineID
FROM scheduling.ConstraintResource K INNER JOIN Setup.MachineNames G ON G.MachineID = K.MachineID
	 



GO
