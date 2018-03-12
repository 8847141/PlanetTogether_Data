SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Bryan Eddy
-- Create date: 2/12/2018
-- Description:	Function to remove non-numeric characters from a string
-- =============================================
CREATE FUNCTION [dbo].[NumericParser] 
(	
	-- Add the parameters for the function here

	@textval nvarchar(MAX)
)
RETURNS
@NumericValues 
TABLE (NumericValue int)
AS
	begin

		INSERT INTO  @NumericValues
		SELECT LEFT(SUBSTRING(@textval, PATINDEX('%[0-9.-]%', @textval), 8000),
				   PATINDEX('%[^0-9.-]%', SUBSTRING(@textval, PATINDEX('%[0-9.-]%', @textval), 8000) + 'X') -1)
	RETURN
	end

GO
