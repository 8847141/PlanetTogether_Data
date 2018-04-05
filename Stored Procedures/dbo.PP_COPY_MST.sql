SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[PP_COPY_MST] 
	-- Add the parameters for the stored procedure here
	--@p1 int = 0, 
	--@p2 int = 0
	--@tablename as nvarchar(300) = 'temp'
AS

DECLARE @tablename as nvarchar(300)

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	--------------------
	--------------------
	--MST PUSH--


	SET @tablename = '_mst_push'
	IF EXISTS (Select 1 From INFORMATION_SCHEMA.TABLES where TABLE_NAME = @tablename) EXEC('Drop Table ' +@tablename)
	EXEC('SELECT * 
	into '+@tablename+' 
	FROM PlanetTogether_Publish_AFL_Test.dbo.z_mst_push')
	--
	
END

GO
