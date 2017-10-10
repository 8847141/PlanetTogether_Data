SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:      Bryan Eddy
-- Create date: 8/1/2017
-- Description: Create all combinations for OPGW Pipe
-- =============================================
CREATE PROCEDURE [Setup].[usp_CreateOpgwPipeMatrix]
as
	SET NOCOUNT ON;
DECLARE @TapeThicknessChange as int = 15;
DECLARE @TapeWidthChange as int = 360;

BEGIN

DELETE setup.AttributeMatrixFromTo FROM setup.AttributeMatrixFromTo G INNER JOIN SETUP.MachineNames K ON K.MachineName = G.MachineName
WHERE G.AttributeNameID IN (22,23) AND K.MachineGroupID = 10

		;WITH cteToAttribute
		as(
			SELECT DISTINCT P.AttributeID, P.AttributeName, K.MachineName, CAST(P.AttributeValue AS FLOAT) FromAttribute,AttributeValue TrueFromAttribute,AttributeNameID
			FROM setup.MachineGroup G INNER JOIN setup.MachineNames K ON G.MachineGroupID = K.MachineGroupID
			INNER JOIN setup.vMasterSetup P ON P.PlanetTogetherMachineNumber = K.MachineName
			WHERE K.MachineGroupID = 10 AND AttributeNameID IN (23,22)
		),
			cteFromAttribute
		as(
			SELECT DISTINCT P.AttributeID, P.AttributeName, K.MachineName, CAST(P.AttributeValue AS FLOAT) ToAttribute,  AttributeValue TrueToAttribute, AttributeNameID
			FROM setup.MachineGroup G INNER JOIN setup.MachineNames K ON G.MachineGroupID = K.MachineGroupID
			INNER JOIN setup.vMasterSetup P ON P.PlanetTogetherMachineNumber = K.MachineName
			WHERE K.MachineGroupID = 10 AND AttributeNameID IN (23,22)
		),
			cteRank
		as(
			SELECT DISTINCT RANK() OVER (PARTITION BY AttributeNameID ORDER BY AttributeValue) AttributeRank, AttributeNameID, AttributeValue
			FROM (select DISTINCT AttributeNameID, CAST(P.AttributeValue AS FLOAT) AttributeValue from setup.MachineGroup G INNER JOIN setup.MachineNames K ON G.MachineGroupID = K.MachineGroupID
			INNER JOIN setup.vMasterSetup P ON P.PlanetTogetherMachineNumber = K.MachineName
			WHERE K.MachineGroupID = 10 AND AttributeNameID IN (23,22) ) X
		),
			cteOpgwPipe
		as(
		SELECT  K.AttributeID, K.AttributeNamE, K.MachineName, K.FromAttribute, FromRank = U.AttributeRank , G.ToAttribute, ToRank = P.AttributeRank,CAST((U.AttributeRank - P.AttributeRank)/2 AS INT) AS RankDelta,
		'Concurrent'  LogicType, K.AttributeNameID, G.TrueToAttribute, K.TrueFromAttribute,
		CASE WHEN k.AttributeNameID = 23 AND k.FromAttribute <> g.ToAttribute THEN @TapeWidthChange 
			ELSE CAST((ABS(U.AttributeRank - P.AttributeRank)+1)/2 AS INT) * @TapeThicknessChange
			END AS TimeValue
		FROM cteToAttribute K INNER JOIN cteFromAttribute G ON G.AttributeID = K.AttributeID
		INNER JOIN cteRank P ON P.AttributeNameID = K.AttributeNameID AND P.AttributeValue = K.FromAttribute
		INNER JOIN cteRank U ON U.AttributeNameID = G.AttributeNameID AND U.AttributeValue = G.ToAttribute
		AND G.MachineName = K.MachineName 
	)
	INSERT INTO setup.AttributeMatrixFromTo(AttributeNameID,MachineName,FromAttribute, ToAttribute,TimeValue)
	SELECT distinct AttributeNameID,MachineName,cteOpgwPipe.TrueFromAttribute, cteOpgwPipe.TrueToAttribute,TimeValue
	FROM cteOpgwPipe

END

GO
