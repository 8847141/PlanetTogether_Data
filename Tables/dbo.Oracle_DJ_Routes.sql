CREATE TABLE [dbo].[Oracle_DJ_Routes]
(
[unique_id] [decimal] (38, 0) NOT NULL,
[organization_code] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[wip_entity_name] [varchar] (240) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[job_type] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[assembly_item] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[assembly_description] [varchar] (240) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[class_code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dj_status] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[start_quantity] [float] NULL,
[net_quantity] [float] NULL,
[dj_wip_supply_type] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[completion_subinventory] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[completion_locator] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[quantity_remaining] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[quantity_completed] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[quantity_scrapped] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[date_released] [datetime] NULL,
[date_completed] [datetime] NULL,
[date_closed] [datetime] NULL,
[schedule_group_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[description] [varchar] (240) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dj_creation_date] [datetime] NULL,
[dj_last_update_date] [datetime] NULL,
[operation_seq_num] [float] NULL,
[operation_code] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[department_code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[count_point] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[autocharge_flag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[backflush_flag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[check_skill] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[minimum_transfer_quantity] [float] NULL,
[date_last_moved] [datetime] NULL,
[op_quantity_in_queue] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[op_quantity_running] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[op_quantity_waiting_to_move] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[op_quantity_rejected] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[op_quantity_scrapped] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[op_quantity_completed] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[progress_percentageg] [float] NULL,
[first_unit_start_date] [datetime] NULL,
[first_unit_completion_date] [datetime] NULL,
[last_unit_start_date] [datetime] NULL,
[last_unit_completion_date] [datetime] NULL,
[operation_description] [varchar] (240) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[startup_scrap] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[send_to_aps] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[creation_date] [datetime] NULL,
[last_update_date] [datetime] NULL,
[true_operation_code] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[true_operation_seq_num] [float] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Oracle_DJ_Routes] ADD CONSTRAINT [PK_Oracle_DJ_Routes] PRIMARY KEY CLUSTERED  ([unique_id]) ON [PRIMARY]
GO
