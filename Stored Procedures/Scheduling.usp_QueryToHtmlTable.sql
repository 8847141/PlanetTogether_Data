SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Description: Turns a query into a formatted HTML table. Useful for emails. 
-- Any ORDER BY clause needs to be passed in the separate ORDER BY parameter.
-- =============================================
CREATE PROC [Scheduling].[usp_QueryToHtmlTable] 
(
  @query NVARCHAR(MAX), --A query to turn into HTML format. It should not include an ORDER BY clause.
  @orderBy NVARCHAR(MAX) = NULL, --An optional ORDER BY clause. It should contain the words 'ORDER BY'.
  @html NVARCHAR(MAX) = NULL OUTPUT--, --The HTML output of the procedure.
  --@RecordCount INT OUTPUT
)
AS
BEGIN   
  SET NOCOUNT ON;

  IF @orderBy IS NULL BEGIN
    SET @orderBy = ''  
  END

  SET @orderBy = REPLACE(@orderBy, '''', '''''');

  DECLARE @realQuery NVARCHAR(MAX) = '
    DECLARE @headerRow nvarchar(MAX);
    DECLARE @cols nvarchar(MAX);    

    SELECT * INTO #dynSql FROM (' + @query + ') sub;

    SELECT @cols = COALESCE(@cols + '', '''''''', '', '''') + ''['' + name + ''] AS ''''td''''''
    FROM tempdb.sys.columns 
    WHERE object_id = object_id(''tempdb..#dynSql'')
    ORDER BY column_id;

    SET @cols = ''SET @html = CAST(( SELECT '' + @cols + '' FROM #dynSql ' + @orderBy + ' FOR XML PATH(''''tr''''), ELEMENTS XSINIL) AS nvarchar(max))''    

    EXEC sys.sp_executesql @cols, N''@html nvarchar(MAX) OUTPUT'', @html=@html OUTPUT

    SELECT @headerRow = COALESCE(@headerRow + '''', '''') + ''<th>'' + name + ''</th>'' 
    FROM tempdb.sys.columns 
    WHERE object_id = object_id(''tempdb..#dynSql'')
    ORDER BY column_id;

    SET @headerRow = ''<tr>'' + @headerRow + ''</tr>'';

    SET @html = ''<table border="1">'' + @headerRow + @html + ''</table>'';    
    ';

  EXEC sys.sp_executesql @realQuery, N'@html nvarchar(MAX) OUTPUT', @html=@html OUTPUT--, @RecordCount = @@ROWCOUNT
END 
GO
