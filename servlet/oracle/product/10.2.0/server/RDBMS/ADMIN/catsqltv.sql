Rem
Rem $Header: catsqltv.sql 02-may-2005.10:03:36 pbelknap Exp $
Rem
Rem catsqltv.sql
Rem
Rem Copyright (c) 2004, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catsqltv.sql - CATalog script for SQL Tune Views 
Rem
Rem    DESCRIPTION
Rem      Catalog script for sqltune views. This script contains view definitions
Rem      for (dba/user/all) sqltune advisor, sql tuning set and sql profile.
Rem
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pbelknap    03/17/05 - add STATISTICS_ONLY view
Rem    kyagoub     11/08/04 - kyagoub_sqlset_perf
Rem    kyagoub     10/01/04 - add captured column to sqlset views 
Rem    kyagoub     09/26/04 - Created
Rem

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
--                         -------------------------                          --
--                         SQL TUNE VIEW DEFINITIONS                          --
--                         -------------------------                          --
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
--------------------------------------------------------------------------------
--                            dba view definitions                            --
--------------------------------------------------------------------------------
---------------------------- view dba_sqltune_binds ----------------------------
CREATE OR REPLACE view dba_sqltune_binds AS
  SELECT task_id, object_id, position, value 
  FROM   wri$_adv_sqlt_binds;

-- create a PUBLIC SYNONYM for the view
CREATE OR REPLACE PUBLIC SYNONYM dba_sqltune_binds
  FOR SYS.dba_sqltune_binds;

-- GRANT a SELECT privilege on the view to the SELECT_CATALOG_ROLE role
GRANT SELECT ON dba_sqltune_binds to SELECT_CATALOG_ROLE;

-------------------------- view dba_sqltune_statistics -------------------------
CREATE OR REPLACE view dba_sqltune_statistics AS
  SELECT TASK_ID, OBJECT_ID, PARSING_SCHEMA_ID, MODULE, ACTION, ELAPSED_TIME,
         CPU_TIME, BUFFER_GETS, DISK_READS, DIRECT_WRITES, 
         ROWS_PROCESSED, FETCHES, EXECUTIONS,
         END_OF_FETCH_COUNT, OPTIMIZER_COST, OPTIMIZER_ENV, COMMAND_TYPE  
  FROM   wri$_adv_sqlt_statistics;

-- create a PUBLIC SYNONYM for the view
CREATE OR REPLACE PUBLIC SYNONYM dba_sqltune_statistics
  FOR SYS.dba_sqltune_statistics;

-- GRANT a SELECT privilege on the view to the PUBLIC role
GRANT SELECT ON dba_sqltune_statistics to SELECT_CATALOG_ROLE;

----------------------------- view dba_sqltune_plans --------------------------
CREATE OR REPLACE view dba_sqltune_plans AS
  SELECT task_id,
         object_id, 
         decode(attribute, 
                0, 'Original', 
                1, 'Original with adjusted cost', 
                2, 'Using SQL profile',
                3, 'Using new indices') AS attribute,
         statement_id,
         plan_hash_value,
         plan_id,
         timestamp,
         remarks,
         operation,
         options,
         object_node,
         object_owner,
         object_name,
         object_alias,
         object_instance,
         object_type,
         optimizer,
         search_columns,
         id,
         parent_id,
         depth,
         position,
         cost,
         cardinality,
         bytes,
         other_tag,
         partition_start,
         partition_stop,
         partition_id,
         other,
         distribution,
         cpu_cost,
         io_cost,
         temp_space,
         access_predicates,
         filter_predicates,
         projection,
         time,
         qblock_name,
         other_xml
  FROM wri$_adv_sqlt_plans;

-- create a PUBLIC SYNONYM for the view
CREATE OR REPLACE PUBLIC SYNONYM dba_sqltune_plans
  FOR SYS.dba_sqltune_plans;

-- GRANT a SELECT privilege on the view to the SELECT_CATALOG_ROLE role
GRANT SELECT ON dba_sqltune_plans to SELECT_CATALOG_ROLE;

-------------------------- view dba_sqltune_rationale_plan ---------------------
CREATE OR REPLACE view dba_sqltune_rationale_plan AS
  SELECT task_id, rtn_id AS rationale_id, object_id, 
         operation_id,
         decode(plan_attr,
                0, 'Original', 
                1, 'Original with adjusted cost', 
                2, 'Using SQL profile',
                3, 'Using new indices') AS plan_attribute   
  FROM WRI$_adv_sqlt_rtn_plan;

-- create a PUBLIC SYNONYM for the view
CREATE OR REPLACE PUBLIC SYNONYM dba_sqltune_rationale_plan
  FOR SYS.dba_sqltune_rationale_plan;

-- GRANT a SELECT privilege on the view to the SELECT_CATALOG_ROLE role
GRANT SELECT ON dba_sqltune_rationale_plan to SELECT_CATALOG_ROLE;


--------------------------------------------------------------------------------
--                           user view definitions                            --
--------------------------------------------------------------------------------
--------------------------- view user_sqltune_binds ----------------------------
CREATE OR REPLACE view user_sqltune_binds AS
  SELECT b.task_id, b.object_id, b.position, b.value 
  FROM   wri$_adv_sqlt_binds b, wri$_adv_objects o, wri$_adv_tasks t
  WHERE  b.object_id = o.id and b.task_id = o.task_id and o.task_id = t.id and 
         t.owner# = SYS_CONTEXT('USERENV', 'CURRENT_USERID');

-- create a PUBLIC SYNONYM for the view
CREATE OR REPLACE PUBLIC SYNONYM user_sqltune_binds
  FOR SYS.user_sqltune_binds;

-- GRANT a SELECT privilege on the view to the PUBLIC role
GRANT SELECT ON user_sqltune_binds to PUBLIC;

------------------------- view user_sqltune_statistics -------------------------
CREATE OR REPLACE view user_sqltune_statistics AS
  SELECT b.TASK_ID, b.OBJECT_ID, PARSING_SCHEMA_ID, MODULE, ACTION,ELAPSED_TIME,
         CPU_TIME, BUFFER_GETS, DISK_READS, DIRECT_WRITES, 
         ROWS_PROCESSED, FETCHES, EXECUTIONS,
         END_OF_FETCH_COUNT, OPTIMIZER_COST, OPTIMIZER_ENV, COMMAND_TYPE  
  FROM   wri$_adv_sqlt_statistics b, wri$_adv_objects o, wri$_adv_tasks t
  WHERE  b.object_id = o.id and b.task_id = o.task_id and o.task_id = t.id and 
         t.owner# = SYS_CONTEXT('USERENV', 'CURRENT_USERID');

-- create a PUBLIC SYNONYM for the view
CREATE OR REPLACE PUBLIC SYNONYM user_sqltune_statistics
  FOR SYS.user_sqltune_statistics;

-- GRANT a SELECT privilege on the view to the PUBLIC role
GRANT SELECT ON user_sqltune_statistics to PUBLIC;

--------------------------- view user_sqltune_plans ---------------------------
CREATE OR REPLACE view user_sqltune_plans AS
  SELECT p.task_id,
         p.object_id,
         decode(p.attribute, 
                0, 'Original', 
                1, 'Original with adjusted cost', 
                2, 'Using SQL profile',
                3, 'Using new indices') AS attribute,     
         p.statement_id,
         p.plan_hash_value,
         p.plan_id,
         p.timestamp,
         p.remarks,
         p.operation,
         p.options,
         p.object_node,
         p.object_owner,
         p.object_name,
         p.object_alias,
         p.object_instance,
         p.object_type,
         p.optimizer,
         p.search_columns,
         p.id,
         p.parent_id,
         p.depth,
         p.position,
         p.cost,
         p.cardinality,
         p.bytes,
         p.other_tag,
         p.partition_start,
         p.partition_stop,
         p.partition_id,
         p.other,
         p.distribution,
         p.cpu_cost,
         p.io_cost,
         p.temp_space,
         p.access_predicates,
         p.filter_predicates,
         p.projection,
         p.time,
         p.qblock_name,
         p.other_xml
  FROM   wri$_adv_sqlt_plans p, wri$_adv_objects o, wri$_adv_tasks t
  WHERE  p.object_id = o.id and p.task_id = o.task_id and o.task_id = t.id and 
         t.owner# = SYS_CONTEXT('USERENV', 'CURRENT_USERID');

-- create a PUBLIC SYNONYM for the view
CREATE OR REPLACE PUBLIC SYNONYM user_sqltune_plans
  FOR SYS.user_sqltune_plans;

-- GRANT a SELECT privilege on the view to the PUBLIC role
GRANT SELECT ON user_sqltune_plans to PUBLIC;
    
----------------------- view user_sqltune_rationale_plan -----------------------
CREATE OR REPLACE view user_sqltune_rationale_plan AS
  SELECT rp.task_id, rp.rtn_id AS rationale_id, rp.object_id, rp.operation_id,
    decode(rp.plan_attr,
           0, 'Original', 
           1, 'Original with adjusted cost', 
           2, 'Using SQL profile',
           3, 'Using new indices') AS plan_attribute            
  FROM   wri$_adv_sqlt_rtn_plan rp, wri$_adv_objects o, wri$_adv_tasks t
  WHERE  rp.object_id = o.id and rp.task_id = o.task_id and 
         o.task_id = t.id and 
         t.owner# = SYS_CONTEXT('USERENV', 'CURRENT_USERID');

-- create a PUBLIC SYNONYM for the view
CREATE OR REPLACE PUBLIC SYNONYM user_sqltune_rationale_plan
  FOR SYS.user_sqltune_rationale_plan;

-- GRANT a SELECT privilege on the view to the PUBLIC role
GRANT SELECT ON user_sqltune_rationale_plan to PUBLIC;




--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
--                     -------------------------------                        --
--                     SQL TUNING SET VIEW DEFINITIONS                        --
--                     -------------------------------                        --
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
--------------------------------------------------------------------------------
--                             dba view definitionss                          --
--------------------------------------------------------------------------------
------------------------------------ DBA_SQLSET --------------------------------
create or replace view DBA_SQLSET as
  select ID, NAME, OWNER, DESCRIPTION, CREATED, LAST_MODIFIED, STATEMENT_COUNT
  from WRI$_SQLSET_DEFINITIONS
/
-- create a public synonym for the view
create or replace public synonym DBA_SQLSET
  for DBA_SQLSET
/
-- this synonym is kept here for compatibility reasons. SHOULD BE DROPED LATER
create or replace public synonym DBA_SQLSET_DEFINITIONS
  for DBA_SQLSET
/
-- grant a select privilege on the view to the SELECT_CATALOG_ROLE role
grant select on DBA_SQLSET to select_catalog_role
/

------------------------------- DBA_SQLSET_REFERENCES --------------------------
create or replace view DBA_SQLSET_REFERENCES as
  select d.name as sqlset_name, d.owner as sqlset_owner, r.sqlset_id,
         r.id, r.owner, r.created, r.description  
  from   WRI$_SQLSET_DEFINITIONS d, WRI$_SQLSET_REFERENCES r
  where  d.id = r.sqlset_id
/
-- create a public synonym for the view
create or replace public synonym DBA_SQLSET_REFERENCES
   for DBA_SQLSET_REFERENCES
/
-- grant a select privilege on the view to the SELECT_CATALOG_ROLE role
grant select on DBA_SQLSET_REFERENCES to select_catalog_role
/

------------------------------ DBA_SQLSET_STATEMENTS ---------------------------
create or replace view DBA_SQLSET_STATEMENTS as
select f.name as sqlset_name, f.owner as sqlset_owner, sqlset_id, 
       s.sql_id, s.force_matching_signature, t.sql_text, 
       p.parsing_schema_name, user# as parsing_schema_id, 
       p.plan_hash_value, p.bind_data, p.binds_captured,
       s.module, s.action, c.elapsed_time, c.cpu_time, c.buffer_gets, 
       c.disk_reads, c.direct_writes, c.rows_processed, c.fetches, 
       c.executions, c.end_of_fetch_count, 
       c.optimizer_cost, p.optimizer_env, m.priority, s.command_type, 
       c.first_load_time, c.stat_period, c.active_stat_period, m.other, 
       p.plan_timestamp, s.id as sql_seq
from   WRI$_SQLSET_DEFINITIONS f, WRI$_SQLSET_STATEMENTS s, WRI$_SQLSET_PLANS p,
       WRI$_SQLSET_MASK m, WRH$_SQLTEXT t, WRI$_SQLSET_STATISTICS c,
       V$DATABASE d, user$ u
where  f.id = s.sqlset_id and s.id = p.stmt_id AND 
       p.stmt_id = c.stmt_id AND p.plan_hash_value = c.plan_hash_value AND
       p.stmt_id = m.stmt_id AND p.plan_hash_value = m.plan_hash_value AND
       s.sql_id = t.sql_id AND t.dbid = d.dbid AND
       p.parsing_schema_name = u.NAME(+);
/
-- create a public synonym for the view
create or replace public synonym DBA_SQLSET_STATEMENTS
   for DBA_SQLSET_STATEMENTS
/
-- grant a select privilege on the view to the SELECT_CATALOG_ROLE role
grant select on DBA_SQLSET_STATEMENTS to select_catalog_role
/

-------------------------------- DBA_SQLSET_BINDS ------------------------------
create or replace VIEW DBA_SQLSET_BINDS as
  select d.name as sqlset_name, d.owner as sqlset_owner, s.sqlset_id, 
         s.sql_id, s.force_matching_signature, p.plan_hash_value, 
         b.position, b.value, p.binds_captured as captured, s.id as sql_seq
  from   WRI$_SQLSET_DEFINITIONS d, WRI$_SQLSET_STATEMENTS s, 
         WRI$_SQLSET_PLANS p, WRI$_SQLSET_BINDS b
  where  d.id = s.sqlset_id and s.id = p.stmt_id AND p.stmt_id = b.stmt_id AND 
         p.plan_hash_value = b.plan_hash_value
  UNION ALL 
  select d.name as sqlset_name, d.owner as sqlset_owner, s.sqlset_id, 
         s.sql_id, s.force_matching_signature, p.plan_hash_value, 
         b.position, b.value_anydata as value, p.binds_captured as captured, 
         s.id as sql_seq
  from   WRI$_SQLSET_DEFINITIONS d, WRI$_SQLSET_STATEMENTS s, 
         WRI$_SQLSET_PLANS p, TABLE(dbms_sqltune.extract_binds(p.bind_data)) b 
  where  d.id = s.sqlset_id AND s.id = p.stmt_id
/
-- create a public synonym for the view
create or replace public synonym DBA_SQLSET_BINDS
   for DBA_SQLSET_BINDS
/
-- grant a select privilege on the view to the SELECT_CATALOG_ROLE role
grant select on DBA_SQLSET_BINDS to select_catalog_role
/

--------------------------------- DBA_SQLSET_PLANS -----------------------------
create or replace VIEW DBA_SQLSET_PLANS as
  select d.name as sqlset_name, d.owner as sqlset_owner, sqlset_id, 
         sql_id, force_matching_signature, p.plan_hash_value, s.id as sql_seq,
         statement_id,
         plan_id,
         timestamp,
         remarks,
         operation,
         options,
         object_node,
         object_owner,
         object_name,
         object_alias,
         object_instance,
         object_type,
         optimizer,
         search_columns,
         l.id,
         parent_id,
         depth,
         position,
         cost,
         cardinality,
         bytes,
         other_tag,
         partition_start,
         partition_stop,
         partition_id,
         other,
         distribution,
         cpu_cost,
         io_cost,
         temp_space,
         access_predicates,
         filter_predicates,
         projection,
         time,
         qblock_name,
         other_xml,
         executions, 
         starts, 
         output_rows, 
         cr_buffer_gets, 
         cu_buffer_gets, 
         disk_reads, 
         disk_writes, 
         elapsed_time
  from   WRI$_SQLSET_DEFINITIONS d, WRI$_SQLSET_STATEMENTS s, 
         WRI$_SQLSET_PLANS p, WRI$_SQLSET_PLAN_LINES l
  where  d.id = s.sqlset_id and s.id = p.stmt_id and 
         p.stmt_id=l.stmt_id and p.plan_hash_value = l.plan_hash_value
/
-- create a public synonym for the view
create or replace public synonym DBA_SQLSET_PLANS
   for DBA_SQLSET_PLANS
/
-- grant a select privilege on the view to the SELECT_CATALOG_ROLE role
grant select on DBA_SQLSET_PLANS to select_catalog_role
/



--------------------------------------------------------------------------------
--                           user view definitions                            --
--------------------------------------------------------------------------------
---------------------------------- USER_SQLSET ---------------------------------
create or replace view USER_SQLSET as
select NAME, ID, DESCRIPTION, CREATED, LAST_MODIFIED, STATEMENT_COUNT   
  from WRI$_SQLSET_DEFINITIONS
  where owner = SYS_CONTEXT('USERENV', 'CURRENT_USER')
/
-- create a public synonym for the USER_SQLSET_DEFINITIONS view
create or replace 
  public synonym USER_SQLSET for USER_SQLSET
/
-- this synonym is kept here for compatibility reasons. SHOULD BE DROPED LATER  
create or replace 
  public synonym USER_SQLSET_DEFINITIONS for USER_sqlset
/
-- grant a select privilege on the view to the PUBLIC role
grant select on USER_SQLSET to PUBLIC
/  
  
---------------------------- USER_SQLSET_STATEMENTS ----------------------------
create or replace view USER_SQLSET_STATEMENTS as
select f.name as sqlset_name, sqlset_id, s.sql_id, s.force_matching_signature,
       t.sql_text, p.parsing_schema_name, user# as parsing_schema_id, 
       p.plan_hash_value, p.bind_data, p.binds_captured,
       s.module, s.action, c.elapsed_time, c.cpu_time, c.buffer_gets, 
       c.disk_reads, c.direct_writes, c.rows_processed, c.fetches, c.executions,
       c.end_of_fetch_count, c.optimizer_cost, p.optimizer_env, m.priority, 
       s.command_type, c.first_load_time, c.stat_period, c.active_stat_period, 
       m.other, p.plan_timestamp, s.id as sql_seq
from   WRI$_SQLSET_DEFINITIONS f, WRI$_SQLSET_STATEMENTS s, 
       WRI$_SQLSET_MASK m, WRH$_SQLTEXT t, 
       WRI$_SQLSET_PLANS p, WRI$_SQLSET_STATISTICS c, 
       V$DATABASE d, user$ u
where  s.id = p.stmt_id AND 
       p.stmt_id = c.stmt_id AND p.plan_hash_value = c.plan_hash_value AND
       p.stmt_id = m.stmt_id AND p.plan_hash_value = m.plan_hash_value AND
       s.sql_id = t.sql_id AND t.dbid = d.dbid and 
       f.id = s.sqlset_id and owner = SYS_CONTEXT('USERENV', 'CURRENT_USER') AND
       p.parsing_schema_name = u.NAME(+);
/
-- create a public synonym for the view
create or replace 
  public synonym USER_SQLSET_STATEMENTS for USER_SQLSET_STATEMENTS
/
-- grant a select privilege on the view the PUBLIC role. 
grant select on USER_SQLSET_STATEMENTS to PUBLIC
/  
  
--------------------------- USER_SQLSET_REFERENCES -----------------------------
create or replace view USER_SQLSET_REFERENCES as
  select d.name as sqlset_name, 
         r.sqlset_id, r.id, r.owner, r.description, r.created 
  from   wri$_sqlset_definitions d, wri$_sqlset_references r
  where d.id=r.sqlset_id and d.owner = SYS_CONTEXT('USERENV', 'CURRENT_USER')
/
-- create a pulbic synonym 
create or replace 
  public synonym USER_SQLSET_REFERENCES for USER_SQLSET_REFERENCES
/
-- grant select privilege to the PUBLIC role.
grant select on USER_SQLSET_REFERENCES to PUBLIC
/  

------------------------------ USER_SQLSET_BINDS -------------------------------
create or replace VIEW USER_SQLSET_BINDS as
  select name as sqlset_name, sqlset_id, s.sql_id, s.force_matching_signature, 
         p.plan_hash_value, b.position, b.value, p.binds_Captured as captured, 
         s.id as sql_seq
  from   WRI$_SQLSET_DEFINITIONS d, WRI$_SQLSET_STATEMENTS s, 
         WRI$_SQLSET_PLANS p, WRI$_SQLSET_BINDS b
  where  d.id = s.sqlset_id AND s.id = p.stmt_id AND p.stmt_id = b.stmt_id AND 
         p.plan_hash_value = b.plan_hash_value AND  
         d.owner = SYS_CONTEXT('USERENV', 'CURRENT_USER')
  UNION ALL 
  select d.name as sqlset_name, s.sqlset_id, s.sql_id, 
         s.force_matching_signature, p.plan_hash_value, 
         b.position, b.value_anydata as value, p.binds_captured as captured, 
         s.id as sql_seq 
  from   WRI$_SQLSET_DEFINITIONS d, WRI$_SQLSET_STATEMENTS s, 
         WRI$_SQLSET_PLANS p, TABLE(dbms_sqltune.extract_binds(p.bind_data)) b 
  where  d.id = s.sqlset_id AND s.id = p.stmt_id AND 
         d.owner = SYS_CONTEXT('USERENV', 'CURRENT_USER')

/
-- create a public synonym for the view
create or replace public synonym USER_SQLSET_BINDS
   for USER_SQLSET_BINDS
/
-- grant a select privilege on the view to the SELECT_CATALOG_ROLE role
grant select on USER_SQLSET_BINDS to PUBLIC
/

--------------------------------- USER_SQLSET_PLANS ----------------------------
create or replace VIEW USER_SQLSET_PLANS as
  select d.name as sqlset_name, sqlset_id, sql_id, force_matching_signature,
         p.plan_hash_value, s.id as sql_seq,
         statement_id,
         plan_id,
         timestamp,
         remarks,
         operation,
         options,
         object_node,
         object_owner,
         object_name,
         object_alias,
         object_instance,
         object_type,
         optimizer,
         search_columns,
         l.id,
         parent_id,
         depth,
         position,
         cost,
         cardinality,
         bytes,
         other_tag,
         partition_start,
         partition_stop,
         partition_id,
         other,
         distribution,
         cpu_cost,
         io_cost,
         temp_space,
         access_predicates,
         filter_predicates,
         projection,
         time,
         qblock_name,
         other_xml,
         executions, 
         starts, 
         output_rows, 
         cr_buffer_gets, 
         cu_buffer_gets, 
         disk_reads, 
         disk_writes, 
         elapsed_time
  from   WRI$_SQLSET_DEFINITIONS d, WRI$_SQLSET_STATEMENTS s, 
         WRI$_SQLSET_PLANS p, WRI$_SQLSET_PLAN_LINES l
  where  d.id = s.sqlset_id and s.id = p.stmt_id and 
         p.stmt_id=l.stmt_id and p.plan_hash_value = l.plan_hash_value and 
         d.owner = SYS_CONTEXT('USERENV', 'CURRENT_USER')
/
-- create a public synonym for the view
create or replace public synonym USER_SQLSET_PLANS
   for USER_SQLSET_PLANS
/
-- grant a select privilege on the view to the public role
grant select on USER_SQLSET_PLANS to public
/



--------------------------------------------------------------------------------
--                            all view definitions                            --
--------------------------------------------------------------------------------
---------------------------------- ALL_SQLSET ----------------------------------
create or replace view ALL_SQLSET as
select name, id, owner, 
       description, created, last_modified, statement_count   
  from WRI$_SQLSET_DEFINITIONS
  where owner = SYS_CONTEXT('USERENV', 'CURRENT_USER') OR
        EXISTS (select 1 
                from   V$ENABLEDPRIVS
                where  priv_number in (-273 /*ADMINISTER ANY SQL TUNING SET*/))
/
-- create a public synonym for the ALL_SQLSET_DEFINITIONS view
create or replace 
  public synonym ALL_SQLSET for ALL_SQLSET
/
-- grant a select privilege on the view to the PUBLIC role
grant select on ALL_SQLSET to PUBLIC
/  
  
---------------------------- ALL_SQLSET_STATEMENTS -----------------------------
create or replace view ALL_SQLSET_STATEMENTS as
select f.name as sqlset_name, f.owner as sqlset_owner, s.sqlset_id, 
       s.sql_id, s.force_matching_signature, t.sql_text,
       p.parsing_schema_name, p.plan_hash_value, p.bind_data, 
       p.binds_captured, s.module, s.action, c.elapsed_time, c.cpu_time, 
       c.buffer_gets, c.disk_reads, c.direct_writes, c.rows_processed, 
       c.fetches, c.executions, c.end_of_fetch_count, c.optimizer_cost, 
       p.optimizer_env, m.priority, s.command_type, c.first_load_time, 
       c.stat_period, c.active_stat_period, 
       m.other, p.plan_timestamp, s.id as sql_seq
from   WRI$_SQLSET_DEFINITIONS f, WRI$_SQLSET_STATEMENTS s, 
       WRI$_SQLSET_MASK m, WRH$_SQLTEXT t, 
       WRI$_SQLSET_PLANS p, WRI$_SQLSET_STATISTICS c, 
       V$DATABASE d
where  s.id = p.stmt_id AND 
       p.stmt_id = c.stmt_id AND p.plan_hash_value = c.plan_hash_value AND
       p.stmt_id = m.stmt_id AND p.plan_hash_value = m.plan_hash_value AND
       s.sql_id = t.sql_id AND t.dbid = d.dbid and 
       f.id = s.sqlset_id AND 
       (owner = SYS_CONTEXT('USERENV', 'CURRENT_USER') OR
        EXISTS (select 1 
                from   V$ENABLEDPRIVS
                where  priv_number in (-273 /*ADMINISTER ANY SQL TUNING SET*/)))
/
-- create a public synonym for the view
create or replace 
  public synonym ALL_SQLSET_STATEMENTS for ALL_SQLSET_STATEMENTS
/
-- grant a select privilege on the view the PUBLIC role. 
grant select on ALL_SQLSET_STATEMENTS to PUBLIC
/  
  
--------------------------- ALL_SQLSET_REFERENCES ------------------------------
create or replace view ALL_SQLSET_REFERENCES as
select d.name as sqlset_name, d.owner as sqlset_owner, r.sqlset_id, 
       r.id, r.owner, r.description, r.created 
from   wri$_sqlset_definitions d, wri$_sqlset_references r
where d.id=r.sqlset_id AND 
      (d.owner = SYS_CONTEXT('USERENV', 'CURRENT_USER') OR
       EXISTS (select 1 
               from   V$ENABLEDPRIVS
               where  priv_number in (-273 /*ADMINISTER ANY SQL TUNING SET*/)))
/
-- create a pulbic synonym 
create or replace 
  public synonym ALL_SQLSET_REFERENCES for ALL_SQLSET_REFERENCES
/
-- grant select privilege to the PUBLIC role.
grant select on ALL_SQLSET_REFERENCES to PUBLIC
/  

--------------------------------- ALL_SQLSET_PLANS -----------------------------
create or replace VIEW ALL_SQLSET_PLANS as
select d.name as sqlset_name, d.owner as sqlset_owner, sqlset_id, 
       sql_id, force_matching_signature, p.plan_hash_value, s.id as sql_seq,
       statement_id,
       plan_id,
       timestamp,
       remarks,
       operation,
       options,
       object_node,
       object_owner,
       object_name,
       object_alias,
       object_instance,
       object_type,
       optimizer,
       search_columns,
       l.id,
       parent_id,
       depth,
       position,
       cost,
       cardinality,
       bytes,
       other_tag,
       partition_start,
       partition_stop,
       partition_id,
       other,
       distribution,
       cpu_cost,
       io_cost,
       temp_space,
       access_predicates,
       filter_predicates,
       projection,
       time,
       qblock_name,
       other_xml,
       executions, 
       starts, 
       output_rows, 
       cr_buffer_gets, 
       cu_buffer_gets, 
       disk_reads, 
       disk_writes, 
       elapsed_time
from   WRI$_SQLSET_DEFINITIONS d, WRI$_SQLSET_STATEMENTS s, 
       WRI$_SQLSET_PLANS p, WRI$_SQLSET_PLAN_LINES l
where  d.id = s.sqlset_id and s.id = p.stmt_id and 
       p.stmt_id=l.stmt_id and p.plan_hash_value = l.plan_hash_value and 
       (d.owner = SYS_CONTEXT('USERENV', 'CURRENT_USER') OR
       EXISTS (select 1 
               from   V$ENABLEDPRIVS
               where  priv_number in (-273 /*ADMINISTER ANY SQL TUNING SET*/)))
/
-- create a public synonym for the view
create or replace public synonym ALL_SQLSET_PLANS
   for ALL_SQLSET_PLANS
/
-- grant a select privilege on the view to the public role
grant select on ALL_SQLSET_PLANS to public
/

------------------------------ ALL_SQLSET_BINDS --------------------------------
create or replace VIEW ALL_SQLSET_BINDS as
  select name as sqlset_name, d.owner as sqlset_owner, sqlset_id, 
         sql_id, force_matching_signature, p.plan_hash_value, 
         b.position, b.value, p.binds_captured as captured, s.id as sql_seq
  from   WRI$_SQLSET_DEFINITIONS d, WRI$_SQLSET_STATEMENTS s, 
         WRI$_SQLSET_PLANS p, WRI$_SQLSET_BINDS b
  where  d.id = s.sqlset_id AND s.id = p.stmt_id AND p.stmt_id = b.stmt_id AND 
         p.plan_hash_value = b.plan_hash_value AND  
         (d.owner = SYS_CONTEXT('USERENV', 'CURRENT_USER')  OR
         EXISTS (select 1 
                 from  V$ENABLEDPRIVS
                 where priv_number in (-273 /*ADMINISTER ANY SQL TUNING SET*/)))
  UNION ALL 
  select d.name as sqlset_name, d.owner as sqlset_owner, s.sqlset_id,
         s.sql_id, s.force_matching_signature, p.plan_hash_value, 
         b.position, b.value_anydata as value, p.binds_captured as captured, 
         s.id as sql_seq      
  from   WRI$_SQLSET_DEFINITIONS d, WRI$_SQLSET_STATEMENTS s, 
         WRI$_SQLSET_PLANS p, TABLE(dbms_sqltune.extract_binds(p.bind_data)) b 
  where  d.id = s.sqlset_id AND s.id = p.stmt_id AND  
         (d.owner = SYS_CONTEXT('USERENV', 'CURRENT_USER') OR
         EXISTS (select 1 
                 from  V$ENABLEDPRIVS
                 where priv_number in (-273 /*ADMINISTER ANY SQL TUNING SET*/)))
/
-- create a public synonym for the view
create or replace public synonym ALL_SQLSET_BINDS for ALL_SQLSET_BINDS
/
-- grant a select privilege on the view to the SELECT_CATALOG_ROLE role
grant select on ALL_SQLSET_BINDS to PUBLIC
/


--------------------------------------------------------------------------------
--                         internal view definitions                          --
--------------------------------------------------------------------------------
--                                                                            --
--  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  --
--  !!! NOTE: DO NOT DOCUMENT THE FOLLOWING VIEWS. THESE VIEWS ARE FOR   !!!  --
--  !!!       INTERNAL USE ONLY AND MAY CHANGE WITHOUT NOTICE.           !!!  --
--  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  --
--                                                                            --
--------------------------------------------------------------------------------

------------------------- _ALL_SQLSET_STATEMENTS_ONLY --------------------------
create or replace view "_ALL_SQLSET_STATEMENTS_ONLY" as
select d.name as sqlset_name,  d.owner as sqlset_owner, s.sqlset_id,
       s.sql_id, s.force_matching_signature, s.command_type, 
       s.parsing_schema_name, module, action, s.id as sql_seq
from   WRI$_SQLSET_DEFINITIONS d, WRI$_SQLSET_STATEMENTS s
where  d.id = s.sqlset_id AND 
       (d.owner = SYS_CONTEXT('USERENV', 'CURRENT_USER') OR
        EXISTS (select 1 
                from   V$ENABLEDPRIVS
                where  priv_number in (-273 /*ADMINISTER ANY SQL TUNING SET*/)))
/
-- create a public synonym for the view
create or replace 
  public synonym "_ALL_SQLSET_STATEMENTS_ONLY" for "_ALL_SQLSET_STATEMENTS_ONLY"
/
-- grant a select privilege on the view the PUBLIC role. 
grant select on "_ALL_SQLSET_STATEMENTS_ONLY" to PUBLIC
/  

------------------------ _ALL_SQLSET_STATISTICS_ONLY ----------------------------
create or replace view "_ALL_SQLSET_STATISTICS_ONLY" as
  SELECT stmts.sqlset_id, stat.stmt_id sql_seq, stat.plan_hash_value, 
         stat.elapsed_time, stat.cpu_time, stat.buffer_gets, stat.disk_reads,
         stat.direct_writes, stat.rows_processed, stat.fetches, stat.executions, 
         stat.end_of_fetch_count, stat.optimizer_cost, stat.first_load_time, 
         stat.stat_period,
         stat.active_stat_period,
         plns.plan_timestamp, plns.binds_captured 
  FROM   WRI$_SQLSET_STATISTICS stat, WRI$_SQLSET_STATEMENTS stmts,
         WRI$_SQLSET_PLANS plns, WRI$_SQLSET_DEFINITIONS defns
  WHERE  defns.id = stmts.sqlset_id AND
         stat.stmt_id = stmts.id AND
         stat.plan_hash_value = plns.plan_hash_value AND
         stat.stmt_id = plns.stmt_id  AND 
         (defns.owner = SYS_CONTEXT('USERENV', 'CURRENT_USER') OR
          EXISTS(SELECT 1 
                 FROM v$enabledprivs 
                 WHERE priv_number = -273));
create or replace
  public synonym "_ALL_SQLSET_STATISTICS_ONLY" for "_ALL_SQLSET_STATISTICS_ONLY"
/
grant select on "_ALL_SQLSET_STATISTICS_ONLY" to PUBLIC
/

------------------------- _ALL_SQLSET_STATEMENTS_PHV ---------------------------
create or replace view "_ALL_SQLSET_STATEMENTS_PHV" as
select d.name as sqlset_name, d.owner as sqlset_owner, s.sqlset_id,
       s.sql_id, s.force_matching_signature, p.plan_hash_value, 
       s.command_type, p.parsing_schema_name, s.module, s.action, 
       p.plan_timestamp, p.binds_captured, s.id as sql_seq
from   WRI$_SQLSET_DEFINITIONS d, WRI$_SQLSET_STATEMENTS s,
       WRI$_SQLSET_PLANS p
where  d.id = s.sqlset_id AND s.id = p.stmt_id AND 
       (d.owner = SYS_CONTEXT('USERENV', 'CURRENT_USER') OR
        EXISTS (select 1 
                from   V$ENABLEDPRIVS
                where  priv_number in (-273 /*ADMINISTER ANY SQL TUNING SET*/)))
/
-- create a public synonym for the view
create or replace 
  public synonym "_ALL_SQLSET_STATEMENTS_PHV" for "_ALL_SQLSET_STATEMENTS_PHV"
/
-- grant a select privilege on the view the PUBLIC role. 
grant select on "_ALL_SQLSET_STATEMENTS_PHV" to PUBLIC
/  




--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
--                       ----------------------------                         --
--                       SQL PROFILE VIEW DEFINITIONS                         --
--                       ----------------------------                         --
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
--------------------------------------------------------------------------------
--                            dba view definitions                            --
--------------------------------------------------------------------------------
create or replace view dba_sql_profiles
(name, category, signature, sql_text, created, last_modified,
description, type, status, force_matching) as
select sp.sp_name, sp.category, sp.signature, st.sql_text, sp.created,
       sp.last_modified, sd.description,
       DECODE(sp.type, 1, 'MANUAL', 2, 'AUTO-TUNE', 'UNKNOWN'),
       DECODE(sp.status, 1, 'ENABLED', 2, 'DISABLED', 3, 'VOID', 'UNKNOWN'),
       DECODE(BITAND(sq.flags, 1), 1, 'YES', 'NO') 
from   sqlprof$ sp,
       sqlprof$desc sd,
       sql$text st,
       sql$     sq
where sp.signature = st.signature
and sp.signature = sd.signature
and sp.signature = sq.signature
and sp.category = sd.category
/

COMMENT ON COLUMN dba_sql_profiles.name IS
'name of sql profile'
/
COMMENT ON COLUMN dba_sql_profiles.category IS
'category of sql profile'
/
COMMENT ON COLUMN dba_sql_profiles.signature IS
'unique identifier generated from normalized SQL text'
/
COMMENT ON COLUMN dba_sql_profiles.sql_text IS
'un-normalized SQL text'
/
COMMENT ON COLUMN dba_sql_profiles.created IS
'date stamp when sql profile created'
/
COMMENT ON COLUMN dba_sql_profiles.last_modified IS
'date stamp when sql profile was last modified'
/
COMMENT ON COLUMN dba_sql_profiles.description IS
'text description provided for sql profile'
/
COMMENT ON COLUMN dba_sql_profiles.type IS
'type of sql profile (how created)'
/
COMMENT ON COLUMN dba_sql_profiles.status IS
'enabled/disabled status of sql profile'
/

CREATE OR REPLACE PUBLIC SYNONYM dba_sql_profiles FOR dba_sql_profiles
/
GRANT SELECT ON dba_sql_profiles TO select_catalog_role
/




--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
--                         ---------------------------                        --
--                         SQLT PROFILE EXPORT PACKAGE                        --
--                         ---------------------------                        --
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--

Rem create view required for SQL Tuning export Package
create or replace view dbmshsxp_sql_profile_attr
(profile_name, attr_number, attr_value) as
select sp.sp_name, sa.attr#, sa.attr_val
from  sqlprof$      sp,
      sqlprof$attr  sa
where sp.signature = sa.signature
and sp.category = sp.category
/

CREATE OR REPLACE PUBLIC SYNONYM dbmshsxp_sql_profile_attr
 FOR dbmshsxp_sql_profile_attr
/
GRANT SELECT ON dbmshsxp_sql_profile_attr TO select_catalog_role
/

Rem SQL Tuning Export Package
@@dbmshsxp.sql
@@prvthsxp.plb

Rem Register export package as a system export action
DELETE FROM exppkgact$ WHERE package = 'DBMSHSXP'
/
INSERT INTO exppkgact$ (package, schema, class, level#)
 VALUES ('DBMSHSXP', 'SYS', 1, 1000)
/
commit
/
