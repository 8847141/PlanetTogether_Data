SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





/* 
	Author:			Bryan Eddy
	Date:			7/7/2017	
	Description:	View created to pull line speeds from Setup Database to supply to Scheduling for Run Speeds						
	Version:		2
	Update:			Add Routing DJ for PT to pick up line speeds for DJ's routes that differ from standard routes
	
	*/


CREATE VIEW [Setup].[vSetupLineSpeed]
	AS


 WITH cteSetupLineSpeed(OperationCode,LineSpeed, SetupDesc, MachineID, RowNumber, RunTypeID)
 AS(

	 SELECT K.SetupNumber,AttributeValue AS LineSpeed, k.SetupDesc, I.MachineID,
	ROW_NUMBER() OVER (PARTITION BY K.SetupNumber,I.MachineID ORDER BY K.SetupNumber,I.MachineID,AttributeValue  ASC ) AS RowNumber, 2
	 FROM  Setup.vInterfaceSetupLineSpeed k INNER JOIN SETUP.MachineReference I ON I.PssMachineID = K.PssMachineID AND i.PssProcessID = k.PssProcessID
	 WHERE ISNUMERIC(AttributeValue) = 1 AND k.SetupNumber NOT IN ('CH01','CH02')
	 UNION
	 SELECT G.True_Operation_Code, G.Time_Minutes,  G.Description, G.MachineID, 1, G.RunTypeID
	 FROM Scheduling.DefinedOperationDuration G
	),

cteRoute
AS(

	SELECT DISTINCT k.item_number Item ,true_operation_seq_num,'Route' AS SetupLocation
	,true_operation_code, pass_to_aps
	, alternate_routing_designator Alternate
	FROM Oracle_Routes K 
	UNION
	SELECT DISTINCT k.assembly_item Item ,true_operation_seq_num,'Route' AS SetupLocation
	,true_operation_code, K.send_to_aps
	, NULL AS Alternate
	FROM dbo.Oracle_DJ_Routes K 

),
cteLineSpeeds
	AS(
	SELECT DISTINCT cteRoute.Item,CAST(LineSpeed AS FLOAT)  AS LineSpeed,cteSetupLineSpeed.MachineID,
	cteRoute.true_operation_code AS Setup,SetupDesc,  true_operation_seq_num
	,COALESCE(cteRoute.Alternate,'Primary') AS PrimaryAlt, CASE WHEN pass_to_aps IN ('Y','D') THEN 'Y' ELSE pass_to_aps END pass_to_aps, cteSetupLineSpeed.RunTypeID AS RunTypeID
	,ROW_NUMBER() OVER (PARTITION BY cteRoute.Item,cteRoute.true_operation_code,cteSetupLineSpeed.MachineID ORDER BY cteRoute.Item,cteRoute.true_operation_code,cteSetupLineSpeed.MachineID,CAST(LineSpeed AS FLOAT)  DESC ) AS RowNumber
	FROM cteRoute LEFT JOIN cteSetupLineSpeed ON cteRoute.true_operation_code = cteSetupLineSpeed.OperationCode
	WHERE COALESCE(cteSetupLineSpeed.RowNumber,1) = 1 
)
SELECT Item, LineSpeed, G.MachineID,G.Setup, SetupDesc, true_operation_seq_num, PrimaryAlt, pass_to_aps, RunTypeID, MachineName--, G.RowNumber
FROM cteLineSpeeds G INNER JOIN Scheduling.MachineCapabilityScheduler K ON G.MachineID = K.MachineID AND G.Setup = K.Setup
INNER JOIN Setup.MachineNames P ON P.MachineID = G.MachineID
WHERE K.ActiveScheduling = 1 AND G.RowNumber = 1 --AND G.Item = 'DNA-7645'
--ORDER BY G.Item




GO
