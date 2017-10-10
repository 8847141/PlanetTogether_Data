SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Bryan Eddy
-- Create date: 9/12/2017
-- Description:	Run all Routing Normalization procedures accross all databse instances
-- Date Modified:
-- Modifications: 
-- =============================================

CREATE PROCEDURE [dbo].[usp_MasterNormalizeRouting]
AS

BEGIN
	SET NOCOUNT ON;
	
	EXEC dbo.usp_NormalizeRouting

	EXEC dbo.usp_NormalizeRouting_DJ


END


GO
