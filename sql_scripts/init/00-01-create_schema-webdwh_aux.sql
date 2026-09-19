create schema if not exists webdwh_aux authorization webdwh;

set role webdwh;

-- sequence ID_RUN_SEQ
create sequence if not exists webdwh_aux.id_run_seq;

-- table SYSTEM_HEARTBEAT
create unlogged table if not exists webdwh_aux.system_heartbeat(
  subsystem varchar(64) primary key,
  last_activity timestamptz not null default now()
)
with
(
  fillfactor = 70,
  autovacuum_vacuum_scale_factor = 0.05,
  autovacuum_vacuum_threshold = 50,
  autovacuum_vacuum_cost_delay = 2,
  autovacuum_vacuum_cost_limit = 1000/*,
  autovacuum_analyze_scale_factor = 0.5,
  autovacuum_analyze_threshold = 10000*/
);

/*
insert into webdwh_aux.system_heartbeat(subsystem) values
('pf')
-- , ('more..')
on conflict do nothing;

vacuum webdwh_aux.system_heartbeat;
*/
