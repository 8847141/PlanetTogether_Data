CREATE SCHEMA [Scheduling]
AUTHORIZATION [dbo]
GO
GRANT EXECUTE ON SCHEMA:: [Scheduling] TO [NAA\SPB_Scheduling_RO]
GO
GRANT EXECUTE ON SCHEMA:: [Scheduling] TO [NAA\SPB_Scheduling_RW]
GO
DENY DELETE ON SCHEMA:: [Scheduling] TO [NAA\SPB_Scheduling_RW]
GO
GRANT INSERT ON SCHEMA:: [Scheduling] TO [NAA\SPB_Scheduling_RW]
GO
GRANT SELECT ON SCHEMA:: [Scheduling] TO [NAA\SPB_Scheduling_RW]
GO
GRANT UPDATE ON SCHEMA:: [Scheduling] TO [NAA\SPB_Scheduling_RW]
GO
