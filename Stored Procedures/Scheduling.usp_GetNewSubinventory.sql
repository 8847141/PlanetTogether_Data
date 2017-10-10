SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Bryan Eddy
-- Create date: 9/14/2017
-- Description:	Add new subinventories to the Scheduling.Subinventory table
-- =============================================
CREATE PROCEDURE [Scheduling].[usp_GetNewSubinventory] 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

	SET NOCOUNT ON;
	INSERT INTO Scheduling.Subinventory(SubinventoryName)
	SELECT DISTINCT G.subinventory_code
	FROM [dbo].[Oracle_Onhand] G LEFT JOIN Scheduling.Subinventory K ON K.SubinventoryName  = G.subinventory_code
	WHERE K.SubinventoryName IS NULL

END
GO
