SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		John Cameron, PlanetTogether
-- Create date: 2017.11.13
-- Description:	wait until Oracle tables have completed their update cycle.
-- =============================================
CREATE PROCEDURE [dbo].[APS_Await_Oracle_Update_Completion]

AS
BEGIN
	SET NOCOUNT ON;

UpdatingLoop:

	IF EXISTS(SELECT 1 FROM Oracle_Interface_Status WHERE interface_status <> 'Complete')
	BEGIN
		WAITFOR DELAY '000:00:05'
		GOTO UpdatingLoop
	END


END
GO
