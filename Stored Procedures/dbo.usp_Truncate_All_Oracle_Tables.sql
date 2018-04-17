SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[usp_Truncate_All_Oracle_Tables]

as

Declare @t table(query varchar(1000),tables varchar(50))


Insert into @t 

    SELECT 'Truncate table ['+T.table_name+']', T.Table_Name  

    FROM INFORMATION_SCHEMA.TABLES T

	WHERE T.TABLE_NAME LIKE 'Oracle%' 



 

--Insert into @t 

--    select 'delete table ['+T.table_name+']', T.Table_Name from 

--    INFORMATION_SCHEMA.TABLES T

--    left outer join INFORMATION_SCHEMA.TABLE_CONSTRAINTS TC

--    on T.table_name=TC.table_name where TC.constraint_Type ='Primary Key' and 

--    T.table_name <>'dtproperties'and Table_type='BASE TABLE' 


Declare @sql varchar(8000)


Select @sql=IsNull(@sql+' ','')+ query from @t


Exec(@sql)


GO
