CREATE TABLE [dbo].[Oracle_Onhand]
(
[organization_id] [bigint] NULL,
[organization_code] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[oracle_item_id] [bigint] NULL,
[item_number] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_description] [varchar] (240) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[serial_code] [float] NULL,
[onhand_qty] [float] NULL,
[subinventory_code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[locator_id] [bigint] NULL,
[item_locator] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lot_number] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[serial_number] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[primary_uom_code] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[product_class] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[creation_date] [datetime] NULL,
[last_update_date] [datetime] NULL,
[unique_id] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[OnHand_MassDelete]
ON [dbo].[Oracle_Onhand]
FOR DELETE 
AS
	DECLARE @DeleteCount INT = (SELECT COUNT(*) FROM deleted)
	DECLARE @EmailSubject varchar(1000) = 'Oracle_OnHand data is being deleted ' + CAST(GETDATE() AS NVARCHAR(50))

    IF(@DeleteCount > 100)
        EXEC msdb.dbo.sp_send_dbmail
        @recipients = 'Bryan.Eddy@aflglobal.com; Shannon.Jackson@aflglobal.com; Prasad.Patchipulusu@aflglobal.com; Krishna.Vemuri@aflglobal.com; Jeff.Gilfillan@aflglobal.com;' ,
        @body = 'Oracle_OnHand data is being deleted.',
        @subject = @EmailSubject;
GO
ALTER TABLE [dbo].[Oracle_Onhand] ADD CONSTRAINT [PK_Oracle_onhand] PRIMARY KEY CLUSTERED  ([unique_id]) ON [PRIMARY]
GO
DENY DELETE ON  [dbo].[Oracle_Onhand] TO [NAA\SPB_Scheduling_RW]
GO
