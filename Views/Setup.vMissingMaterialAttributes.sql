SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*
Author:		Bryan Eddy
Date:		1/8/2018
Desc:		Identify materials missing item attributes (Oracle Specs for materials that identify what the material is)
Verzion:	1
Update:		Initial creation
*/
CREATE VIEW [Setup].[vMissingMaterialAttributes]
as

WITH cteMaterialPurchasingIndicators
AS(
	SELECT DISTINCT	  I.item_number, LEFT(I.item_number,3) AS MaterialPrefix, I.attribute_name, I.attribute_value
	FROM            --Setup.ApsSetupAttributeReference AS K INNER JOIN
                         Oracle_Item_Attributes AS I-- ON K.OracleAttribute = I.attribute_name INNER JOIN
                         INNER JOIN Oracle_Items P ON P.item_number = I.item_number
						 
)
SELECT DISTINCT K.item_number, K.inventory_item_status_code, K.purchase_category, I.MaterialPrefix, i.attribute_name--, I.attribute_value
				, K.item_description
FROM dbo.Oracle_Items K INNER JOIN cteMaterialPurchasingIndicators I ON LEFT(k.item_number,3) = i.MaterialPrefix
	LEFT JOIN cteMaterialPurchasingIndicators O ON O.item_number = K.item_number
	WHERE O.item_number IS NULL AND K.inventory_item_status_code <> 'OBSOLETE' AND K.make_buy = 'buy'AND I.MaterialPrefix NOT IN ('fbr','dns')
	--AND I.attribute_name = 'MATERIAL TYPE'
	--ORDER BY k.item_number



GO
