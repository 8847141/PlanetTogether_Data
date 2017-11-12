SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








/* View created to pull line speeds from Setup Database
	to supply to Scheduling for Run Speeds
	7/7/2017 - Bryan Eddy							*/


CREATE VIEW [Setup].[vSetupLineSpeed]
	AS


 WITH cteSetupLineSpeed(OperationCode,LineSpeed, SetupDesc, MachineID, RowNumber)
 AS(

	 SELECT K.SetupNumber,AttributeValue AS LineSpeed, k.SetupDesc, I.MachineID,
	ROW_NUMBER() OVER (PARTITION BY K.SetupNumber,I.MachineID ORDER BY K.SetupNumber,I.MachineID,AttributeValue  ASC ) AS RowNumber
	 FROM  Setup.vInterfaceSetupLineSpeed k INNER JOIN SETUP.MachineReference I ON I.PssMachineID = K.PssMachineID
	 WHERE ISNUMERIC(AttributeValue) = 1 
	),

cteRoute
AS(

	SELECT DISTINCT k.item_number Item ,true_operation_seq_num,'Route' AS SetupLocation
	,true_operation_code, pass_to_aps
	, alternate_routing_designator Alternate
	FROM Oracle_Routes K --INNER JOIN Oracle_Items G ON K.item_number = G.item_number
	  --WHERE k.item_number like 'waw%'

),
cteLineSpeeds
	AS(
	SELECT DISTINCT cteRoute.Item,COALESCE(g.Time_Minutes,CAST(LineSpeed AS FLOAT),0)  AS LineSpeed,COALESCE(g.MachineID,cteSetupLineSpeed.MachineID) MachineID,
	COALESCE(g.true_operation_code,cteRoute.true_operation_code) AS Setup,SetupDesc,  true_operation_seq_num
	,COALESCE(cteRoute.Alternate,'Primary') AS PrimaryAlt, CASE WHEN pass_to_aps IN ('Y','D') THEN 'Y' ELSE pass_to_aps END pass_to_aps, COALESCE(g.RunTypeID,2) RunTypeID
	FROM cteRoute LEFT JOIN cteSetupLineSpeed ON cteRoute.true_operation_code = cteSetupLineSpeed.OperationCode
	LEFT JOIN Scheduling.DefinedOperationDuration G ON G.True_Operation_Code = cteRoute.true_operation_code
	WHERE COALESCE(cteSetupLineSpeed.RowNumber,1) = 1 
)
SELECT Item, LineSpeed, G.MachineID,G.Setup, SetupDesc, true_operation_seq_num, PrimaryAlt, pass_to_aps, RunTypeID, MachineName
FROM cteLineSpeeds G INNER JOIN Scheduling.MachineCapabilityScheduler K ON G.MachineID = K.MachineID AND G.Setup = K.Setup
INNER JOIN Setup.MachineNames P ON P.MachineID = G.MachineID
WHERE K.ActiveScheduling = 1












GO
