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
as
	SET NOCOUNT ON;
BEGIN

DELETE setup.AttributeMatrixFromTo FROM setup.AttributeMatrixFromTo K INNER JOIN SETUP.MachineNames G ON G.MachineName = K.MachineName
WHERE AttributeNameID = 34 and MachineGroupID = 13

	INSERT INTO setup.AttributeMatrixFromTo(AttributeNameID,MachineName,FromAttribute, ToAttribute,TimeValue)
	VALUES  (34, 'SZ07','0','0',0),
			(34, 'SZ07','0','1',20),
			(34, 'SZ07','1','0',10),
			(34, 'SZ07','1','1',10),
			(34, 'SZ06','0','0',0),
			(34, 'SZ06','0','1',20),
			(34, 'SZ06','1','0',10),
			(34, 'SZ06','1','1',10)

END
GO
