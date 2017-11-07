CREATE TABLE [Scheduling].[MachineCapabilityScheduler]
(
[MachineCapabilityID] [int] NOT NULL IDENTITY(1, 1),
[MachineName] [nvarchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Setup] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ActiveScheduling] [bit] NULL CONSTRAINT [DF__MachineCa__Activ__4EDDB18F] DEFAULT ((1)),
[InactiveReason] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ActiveStatusChangedDate] [datetime] NULL CONSTRAINT [DF__MachineCa__Activ__4FD1D5C8] DEFAULT (getdate()),
[ActiveStatusChangedBy] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__MachineCa__Activ__50C5FA01] DEFAULT (suser_sname()),
[EngineeringAssist] [bit] NULL CONSTRAINT [DF__MachineCa__Engin__51BA1E3A] DEFAULT ((0)),
[EngineeringAssistReason] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedBy] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__MachineCa__Creat__52AE4273] DEFAULT (suser_sname()),
[DateCreated] [datetime] NULL CONSTRAINT [DF__MachineCa__DateC__53A266AC] DEFAULT (getdate())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Bryan Eddy
-- Create date: 11/1/2017
-- Description:	Update the ActiveStatusUpdate field with a user and time the ActiveScheduling status is changed
-- =============================================
CREATE TRIGGER [Scheduling].[trg_ActiveSchedulerStatusChange] 
   ON  [Scheduling].[MachineCapabilityScheduler] 
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		IF  UPDATE(ActiveScheduling)
			BEGIN
			  UPDATE t
			  SET t.ActiveStatusChangedDate = GETDATE() , t.ActiveStatusChangedBy = (SUSER_SNAME()) 
			  FROM Scheduling.MachineCapabilityScheduler  as t
			  JOIN inserted i
			  ON i.MachineCapabilityID = t.MachineCapabilityID 
		END 

END
GO
ALTER TABLE [Scheduling].[MachineCapabilityScheduler] ADD CONSTRAINT [pk_MachineCapability] PRIMARY KEY CLUSTERED  ([MachineName], [Setup]) ON [PRIMARY]
GO
ALTER TABLE [Scheduling].[MachineCapabilityScheduler] ADD CONSTRAINT [fk_MachineCapability_MachineName] FOREIGN KEY ([MachineName]) REFERENCES [Setup].[MachineNames] ([MachineName]) ON DELETE CASCADE ON UPDATE CASCADE
GO
