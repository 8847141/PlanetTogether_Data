SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****** Script for SelectTopNRows command from SSMS  ******/
/*
Author:		Bryan Eddy
Date:		4/18/2018
Desc:		View of sales orders filtered for information pertinent to PlanetTogether
Version:	1
Update:		n/a
*/

CREATE VIEW [Scheduling].[vOracleOrders]
as
SELECT DISTINCT conc_order_number, child_dj_number, parent_dj_number, assembly_item, order_status, line_status, promise_date ,need_by_date, order_number, line_number
  FROM [PlanetTogether_Data_Prod].[dbo].[Oracle_Orders]
  WHERE transfer_to_aps = 'yes' AND active_flag = 'y' 
GO
