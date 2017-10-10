SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[usf_SplitString]
(
    @sString nvarchar(2048),
    @cDelimiter nchar(1)
)
RETURNS 
@tParts 
TABLE ( part nvarchar(2048),
		Position int)
AS
BEGIN
    if @sString is null return
    declare @iStart int,
            @iPos int,
			@Count int
    if substring( @sString, 1, 1 ) = @cDelimiter 
    begin
        set @iStart = 2
        insert into @tParts
        values( null,null )
    end
    else 
        set @iStart = 1
		set @count = 1
    while 1=1
    begin

        set @iPos = charindex( @cDelimiter, @sString, @iStart )
        if @iPos = 0
            set @iPos = len( @sString )+1
        if @iPos - @iStart > 0          
            insert into @tParts
            values  ( substring( @sString, @iStart, @iPos-@iStart ), @count)
        else
            insert into @tParts
            values( null ,null)
        set @iStart = @iPos+1
        if @iStart > len( @sString ) 
            break
		select @count = @count + 1
    end
	
    RETURN

END
GO
