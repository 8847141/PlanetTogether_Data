SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*	
	Author: Bryan Eddy
	Date:	11/3/2017
	Use:	Identify where jacket materials are missing the 'Jacket' indicator in the Oracle Specs that are located in active BOM's.
			Indicator is needed to for setup calculations.
			Items needs an Oracle spec for 
			Color = <Color>
			Material Type = 'COMPOUND'
			Jacket = <Jacket Type>

			Jacket Types:
			SELECT DISTINCT attribute_value
			FROM DBO.Oracle_Item_Attributes
			WHERE attribute_name = 'jacket'
*/
CREATE VIEW [Setup].[vMissingJacketCompounds]
AS
	
	  WITH cteCompoundPrefix
	  as(
		  SELECT DISTINCT LEFT(item_number,3)AS Prefix
		  FROM DBO.Oracle_Item_Attributes
		  WHERE attribute_name = 'jacket'
		),
		cteExistingCompounds
		AS(
			SELECT DISTINCT item_number
			FROM DBO.Oracle_Item_Attributes
			WHERE attribute_name = 'jacket'
		)

	SELECT DISTINCT K.item_number, K.inventory_item_status_code
	FROM cteCompoundPrefix G INNER JOIN dbo.Oracle_Items K ON LEFT(K.item_number,3)= G.Prefix 
	LEFT JOIN cteExistingCompounds I ON I.item_number = K.item_number INNER JOIN dbo.Oracle_BOMs P ON P.comp_item = K.item_number
	WHERE I.item_number IS NULL AND p.inventory_item_status_code NOT IN( 'obsolete','discontd') AND K.item_number NOT LIKE '%-mb'

GO
