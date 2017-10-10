SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:		Bryan Eddy
-- Create date: 9/15/2017
-- Description:	Interface view for PT to get material contraints
-- =============================================
CREATE VIEW [Scheduling].[vConstraintMaterial]
as

SELECT item_number, attribute_name, attribute_value
FROM dbo.Oracle_Item_Attributes 
WHERE attribute_name = 'MAX_LENGTH'
	 


GO
