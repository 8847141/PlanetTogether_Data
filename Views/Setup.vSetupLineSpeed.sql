SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




/* 
	
	Author:	Bryan Eddy
	Date:	7/7/2017 - Bryan Eddy		
	Desc:	View created to pull line speeds from Setup Database to supply to Scheduling for Run Speeds
	Rev:	1
	Update:	Removed routing from data
*/


CREATE VIEW [Setup].[vSetupLineSpeed]
	AS

	 WITH cteSetupLineSpeed(OperationCode,LineSpeed, SetupDesc, MachineID, RowNumber)
	 AS(

		 SELECT K.SetupNumber,AttributeValue AS LineSpeed, k.SetupDesc, I.MachineID,
		ROW_NUMBER() OVER (PARTITION BY K.SetupNumber,I.MachineID ORDER BY K.SetupNumber,I.MachineID,AttributeValue  ASC ) AS RowNumber
		 FROM  Setup.vInterfaceSetupLineSpeed k INNER JOIN SETUP.MachineReference I ON I.PssMachineID = K.PssMachineID AND i.PssProcessID = k.PssProcessID
		 WHERE ISNUMERIC(AttributeValue) = 1 
		),

	cteLineSpeeds
		AS(
		SELECT  COALESCE(g.Time_Minutes,CAST(LineSpeed AS FLOAT),0)  AS LineSpeed,COALESCE(g.MachineID,cteSetupLineSpeed.MachineID) MachineID,
		COALESCE(g.true_operation_code,OperationCode) AS Setup,SetupDesc
		, COALESCE(g.RunTypeID,2) RunTypeID
		FROM  cteSetupLineSpeed  LEFT JOIN Scheduling.DefinedOperationDuration G ON G.True_Operation_Code = OperationCode
		WHERE COALESCE(cteSetupLineSpeed.RowNumber,1) = 1 
	)
	SELECT  DISTINCT LineSpeed,G.Setup, SetupDesc, G.RunTypeID,G.MachineID, MachineName, i.item_number AS Item--, I.pass_to_aps
	FROM cteLineSpeeds G INNER JOIN Scheduling.MachineCapabilityScheduler K ON G.MachineID = K.MachineID AND G.Setup = K.Setup
	INNER JOIN Setup.MachineNames P ON P.MachineID = G.MachineID
	INNER JOIN dbo.Oracle_Routes I ON I.operation_code = G.SETUP
	--INNER JOIN [Scheduling].[OperationRunType] I ON I.RunTypeID = G.RunTypeID
	WHERE K.ActiveScheduling = 1 --AND g.Setup LIKE 'ch%'




GO
