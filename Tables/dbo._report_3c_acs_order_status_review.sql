CREATE TABLE [dbo].[_report_3c_acs_order_status_review]
(
[conc_order_number] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customer_name] [varchar] (360) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[job] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[part_number] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[so_qty] [float] NULL,
[request_date] [datetime] NULL,
[promise_date] [datetime] NULL,
[schedule_ship_date] [datetime] NULL,
[schedule_approved] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[has_credit_hold] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[has_mfg_hold] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[has_export_hold] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[has_shipping_hold] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[scheduled_setup_start] [datetime] NULL,
[machine_name] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[component_item] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProductionStatus] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[material_earliest_start_date] [datetime] NULL,
[last_update_date] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
