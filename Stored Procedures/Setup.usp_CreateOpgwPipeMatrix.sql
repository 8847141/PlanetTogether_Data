SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:      Bryan Eddy
-- Create date: 8/1/2017
-- Description: Create all combinations for OPGW Pipe
-- Version: 1
-- Update:	Added error handling
-- =============================================
CREATE PROCEDURE [Setup].[usp_CreateOpgwPipeMatrix]
AS
	SET NOCOUNT ON;


BEGIN

DECLARE @TapeThicknessChange as int = 15;
DECLARE @TapeWidthChange as int = 360;
	BEGIN TRY
			BEGIN TRAN
				DELETE setup.AttributeMatrixFromTo FROM setup.AttributeMatrixFromTo G INNER JOIN SETUP.MachineNames K ON K.MachineID = G.MachineID
				WHERE G.AttributeNameID IN (22,23) AND K.MachineGroupID = 10

						;WITH cteToAttribute
						AS(
							SELECT DISTINCT P.AttributeID, P.AttributeName, K.MachineID, CAST(P.AttributeValue AS FLOAT) FromAttribute,AttributeValue TrueFromAttribute,AttributeNameID
							FROM setup.MachineGroup G INNER JOIN setup.MachineNames K ON G.MachineGroupID = K.MachineGroupID
							INNER JOIN setup.vMasterSetup P ON P.MachineID = K.MachineID
							WHERE K.MachineGroupID = 10 AND AttributeNameID IN (23,22)
						),
							cteFromAttribute
						AS(
							SELECT DISTINCT P.AttributeID, P.AttributeName, K.MachineID, CAST(P.AttributeValue AS FLOAT) ToAttribute,  AttributeValue TrueToAttribute, AttributeNameID
							FROM setup.MachineGroup G INNER JOIN setup.MachineNames K ON G.MachineGroupID = K.MachineGroupID
							INNER JOIN setup.vMasterSetup P ON P.MachineID = K.MachineID
							WHERE K.MachineGroupID = 10 AND AttributeNameID IN (23,22)
						),
							cteRank
						AS(
							SELECT DISTINCT RANK() OVER (PARTITION BY AttributeNameID ORDER BY AttributeValue) AttributeRank, AttributeNameID, AttributeValue
							FROM (SELECT DISTINCT AttributeNameID, CAST(P.AttributeValue AS FLOAT) AttributeValue FROM setup.MachineGroup G INNER JOIN setup.MachineNames K ON G.MachineGroupID = K.MachineGroupID
							INNER JOIN setup.vMasterSetup P ON P.MachineID = K.MachineID
							WHERE K.MachineGroupID = 10 AND AttributeNameID IN (23,22) ) X
						),
							cteOpgwPipe
						AS(
						SELECT  K.AttributeID, K.AttributeNamE, K.MachineID, K.FromAttribute, FromRank = U.AttributeRank , G.ToAttribute, ToRank = P.AttributeRank,CAST((U.AttributeRank - P.AttributeRank)/2 AS INT) AS RankDelta,
						'Concurrent'  LogicType, K.AttributeNameID, G.TrueToAttribute, K.TrueFromAttribute,
						CASE WHEN k.AttributeNameID = 23 AND k.FromAttribute <> g.ToAttribute THEN @TapeWidthChange 
							ELSE CAST((ABS(U.AttributeRank - P.AttributeRank)+1)/2 AS INT) * @TapeThicknessChange
							END AS TimeValue
						FROM cteToAttribute K INNER JOIN cteFromAttribute G ON G.AttributeID = K.AttributeID
						INNER JOIN cteRank P ON P.AttributeNameID = K.AttributeNameID AND P.AttributeValue = K.FromAttribute
						INNER JOIN cteRank U ON U.AttributeNameID = G.AttributeNameID AND U.AttributeValue = G.ToAttribute
						AND G.MachineID = K.MachineID 
					)
					INSERT INTO setup.AttributeMatrixFromTo(AttributeNameID,MachineID,FromAttribute, ToAttribute,TimeValue)
					SELECT DISTINCT AttributeNameID,MachineID,cteOpgwPipe.TrueFromAttribute, cteOpgwPipe.TrueToAttribute,TimeValue
					FROM cteOpgwPipe
			COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
 
		DECLARE @ErrorNumber INT = ERROR_NUMBER();
		DECLARE @ErrorLine INT = ERROR_LINE();
 
		PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
		PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
		THROW;
	END CATCH
END;

GO
