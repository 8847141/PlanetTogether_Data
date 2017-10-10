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

CREATE PROCEDURE [dbo].[usp_MasterNormalizeRouting_AllInstances]
AS
	SET NOCOUNT ON;
BEGIN
	IF OBJECT_ID(N'tempdb..#MetaData', N'U') IS NOT NULL
	DROP TABLE #MetaData
	CREATE TABLE #MetaData(Db SYSNAME, ProcName SYSNAME);

	DECLARE @sql NVARCHAR(MAX);
	SET @sql = N'';

	SELECT @sql = @sql + CHAR(13) + CHAR(10)
	  + N'insert #MetaData select ''' + db.name + ''', p.name 
			FROM ' + QUOTENAME(db.name) + N'.sys.procedures AS p
			WHERE p.name like N''usp_NormalizeRouting%'' 
			COLLATE SQL_Latin1_General_CP1_CI_AI;' 
		FROM sys.databases AS db -- 
		WHERE db.name like '%_data%';

	EXEC sp_executesql @sql;

	DECLARE @MyCursor CURSOR;
	DECLARE @Db nvarchar(150)
	DECLARE @Proc nvarchar(150)
 
	--sample variables to hold each row's content
	DECLARE @Procedure varchar(max);

	BEGIN
		SET @MyCursor = CURSOR FOR
			 SELECT Db, ProcName FROM #MetaData ORDER BY Db, ProcName;
 
		OPEN @MyCursor
		FETCH NEXT FROM @MyCursor
		INTO @Db,@Proc


		WHILE @@FETCH_STATUS = 0
		BEGIN


		 SET @PROCEDURE = @Db + '.dbo.' + @Proc;
		 EXEC @Procedure


	  FETCH NEXT FROM @MyCursor
	  INTO @Db,@Proc
   
		END; 
 
		CLOSE @MyCursor ;
		DEALLOCATE @MyCursor;
	END;


END


GO
