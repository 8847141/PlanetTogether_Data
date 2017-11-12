SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





-- =============================================
-- Author:      Bryan Eddy
-- Create date: 8/14/2017
-- Description: create From To Matrix for SZ Glue
-- =============================================
CREATE PROCEDURE [Setup].[usp_CreateSzMatrix]
AS
	SET NOCOUNT ON;
BEGIN

DELETE setup.AttributeMatrixFromTo FROM setup.AttributeMatrixFromTo K INNER JOIN SETUP.MachineNames G ON G.MachineID = K.MachineID
WHERE AttributeNameID = 34 AND MachineGroupID = 13

	INSERT INTO setup.AttributeMatrixFromTo(AttributeNameID,MachineID,FromAttribute, ToAttribute,TimeValue)
	VALUES  (34, 8,'0','0',0),
			(34, '8','0','1',20),
			(34, '8','1','0',10),
			(34, '8','1','1',10),
			(34, '7','0','0',0),
			(34, '7','0','1',20),
			(34, '7','1','0',10),
			(34, '7','1','1',10)

END

GO
