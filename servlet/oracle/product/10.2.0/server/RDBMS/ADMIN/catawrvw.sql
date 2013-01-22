Rem
Rem $Header: catawrvw.sql 27-may-2005.12:04:46 mlfeng Exp $
Rem
Rem catawrvw.sql
Rem
Rem Copyright (c) 2003, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catawrvw.sql - Catalog script for AWR Views
Rem
Rem    DESCRIPTION
Rem      Catalog script for AWR Views. Used to create the  
Rem      Workload Repository Schema.
Rem
Rem    NOTES
Rem      Must be run when connected as SYSDBA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mlfeng      05/26/05 - Fix tablespace space usage view
Rem    veeve       03/10/05 - made DBA_HIST_ASH.QC* NULL when invalid
Rem    adagarwa    03/04/05 - Added force_matching_sig,blocking_sesison_srl#
Rem                           to DBA_HIST_ACTIVE_SESS_HISTORY
Rem    narora      03/07/05 - add queue_id to WRH$_BUFFERED_QUEUES 
Rem    kyagoub     09/12/04 - add bind_data to dba_hist_sqlstat 
Rem    veeve       10/19/04 - add p1text,p2text,p3text to 
Rem                           dba_hist_active_sess_history 
Rem    mlfeng      09/21/04 - add parsing_schema_name 
Rem    mlfeng      07/27/04 - add new sql columns, new tables 
Rem    bdagevil    08/02/04 - fix DBA_HIST_SQLBIND view 
Rem    mlfeng      05/21/04 - add topnsql column 
Rem    ushaft      05/26/04 - added DBA_HIST_STREAMS_POOL_ADVICE
Rem    ushaft      05/15/04 - add views for WRH$_COMP_IOSTAT, WRH$_SGA_TARGET..
Rem    bdagevil    05/26/04 - add timestamp column in explain plan 
Rem    bdagevil    05/13/04 - add other_xml column 
Rem    narora      05/20/04 - add wrh$_sess_time_stats, streams tables
Rem    veeve       05/12/04 - made DBA_HIST_ASH similiar to its V$
Rem                           add blocking_session,xid to DBA_HIST_ASH
Rem    mlfeng      04/26/04 - p1, p2, p3 for event name 
Rem    mlfeng      01/30/04 - add gc buffer busy 
Rem    mlfeng      01/12/04 - class -> instance cache transfer 
Rem    mlfeng      12/09/03 - fix bug with baseline view 
Rem    mlfeng      11/24/03 - remove rollstat, add latch_misses_summary
Rem    pbelknap    11/03/03 - pbelknap_swrfnm_to_awrnm 
Rem    mlfeng      08/29/03 - sync up with v$ changes
Rem    mlfeng      08/27/03 - add rac tables 
Rem    mlfeng      07/10/03 - add service stats
Rem    nmacnaug    08/13/03 - remove unused statistic 
Rem    mlfeng      08/04/03 - remove address columns from ash, sql_bind 
Rem    mlfeng      07/25/03 - add group_name to metric name
Rem    gngai       08/01/03 - changed event class metrics
Rem    mramache    06/24/03 - hintset_applied -> sql_profile
Rem    gngai       06/17/03 - changed dba_hist_sysmetric_history
Rem    gngai       06/24/03 - fixed wrh$ views to use union all
Rem    mlfeng      06/03/03 - add wrh$_instance_recovery columns
Rem    mramache    05/20/03 - add plsql/java time columns to DBA_HIST_SQLSTAT
Rem    veeve       04/22/03 - Modified DBA_HIST_ACTIVE_SESS_HISTORY
Rem                           sql_hash_value OUT, sql_id IN, sql_address OUT
Rem    bdagevil    04/23/03 - undostat views: use sql_id instead of signature
Rem    mlfeng      04/22/03 - Modify signature/hash value to sql_id
Rem    mlfeng      04/14/03 - Modify DBA_HIST_SQLSTAT, DBA_HIST_SQLTEXT
Rem    mlfeng      04/11/03 - Add DBA_HIST_OPTIMIZER_ENV
Rem    bdagevil    04/28/03 - merge new file
Rem    mlfeng      03/17/03 - Adding hash to name tables
Rem    mlfeng      04/01/03 - add block size to datafile, tempfile
Rem    veeve       03/05/03 - rename service_id to service_hash
Rem                           in DBA_HIST_ACTIVE_SESS_HISTORY
Rem    mlfeng      03/05/03 - add SQL Bind view
Rem    mlfeng      03/04/03 - add new dba_hist views to sync with catswrtb
Rem    mlfeng      03/04/03 - remove wrh$_idle_event
Rem    mlfeng      02/13/03 - modify dba_hist_event_name
Rem    mlfeng      01/27/03 - mlfeng_swrf_reporting
Rem    mlfeng      01/24/03 - update undostat view
Rem    mlfeng      01/16/03 - Creation of DBA_HIST views
Rem    mlfeng      01/16/03 - Created
Rem


Rem ************************************************************************* 
Rem Creating the Workload Repository History (DBA_HIST) Catalog Views ...
Rem ************************************************************************* 


/***************************************
 *     DBA_HIST_DATABASE_INSTANCE
 ***************************************/

create or replace view DBA_HIST_DATABASE_INSTANCE
  (DBID, INSTANCE_NUMBER, STARTUP_TIME, PARALLEL, VERSION, 
   DB_NAME, INSTANCE_NAME, HOST_NAME, LAST_ASH_SAMPLE_ID)
as
select dbid, instance_number, startup_time, parallel, version, 
       db_name, instance_name, host_name, last_ash_sample_id
from WRM$_DATABASE_INSTANCE
/
comment on table DBA_HIST_DATABASE_INSTANCE is
'Database Instance Information'
/
create or replace public synonym DBA_HIST_DATABASE_INSTANCE 
    for DBA_HIST_DATABASE_INSTANCE
/
grant select on DBA_HIST_DATABASE_INSTANCE to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_SNAPSHOT
 ***************************************/

/* only the valid snapshots (status = 0) will be displayed) */
create or replace view DBA_HIST_SNAPSHOT
  (SNAP_ID, DBID, INSTANCE_NUMBER, STARTUP_TIME, 
   BEGIN_INTERVAL_TIME, END_INTERVAL_TIME,
   FLUSH_ELAPSED, SNAP_LEVEL, ERROR_COUNT)
as
select snap_id, dbid, instance_number, startup_time, 
       begin_interval_time, end_interval_time,
       flush_elapsed, snap_level, error_count
from WRM$_SNAPSHOT
where status = 0;
/
comment on table DBA_HIST_SNAPSHOT is
'Snapshot Information'
/
create or replace public synonym DBA_HIST_SNAPSHOT 
    for DBA_HIST_SNAPSHOT
/
grant select on DBA_HIST_SNAPSHOT to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_SNAP_ERROR
 ***************************************/

/* shows error information for each snapshot */
create or replace view DBA_HIST_SNAP_ERROR
  (SNAP_ID, DBID, INSTANCE_NUMBER, TABLE_NAME, ERROR_NUMBER)
as select snap_id, dbid, instance_number, table_name, error_number
  from wrm$_snap_error;
/
comment on table DBA_HIST_SNAP_ERROR is
'Snapshot Error Information'
/
create or replace public synonym DBA_HIST_SNAP_ERROR
    for DBA_HIST_SNAP_ERROR
/
grant select on DBA_HIST_SNAP_ERROR to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_BASELINE
 ***************************************/

create or replace view DBA_HIST_BASELINE
  (dbid, baseline_id, baseline_name, start_snap_id, start_snap_time,
   end_snap_id, end_snap_time)
as
select t1.dbid, t1.baseline_id, 
       max(t1.baseline_name)     baseline_name,
       max(t1.start_snap_id)     start_snap_id,
       max(t1.start_snap_time)   start_snap_time,
       t1.end_snap_id            end_snap_id,
       max(s2.end_interval_time) end_snap_time
from
  (select bl.dbid, bl.baseline_id, max(bl.baseline_name) baseline_name, 
          bl.start_snap_id, min(s1.end_interval_time) start_snap_time,
          max(bl.end_snap_id) end_snap_id
     from WRM$_BASELINE bl, WRM$_SNAPSHOT s1
    where bl.dbid = s1.dbid 
      and bl.start_snap_id = s1.snap_id 
    group by bl.dbid, baseline_id, start_snap_id) t1,
  WRM$_SNAPSHOT s2
where
  t1.dbid          = s2.dbid and
  t1.end_snap_id   = s2.snap_id
group by t1.dbid, baseline_id, end_snap_id
/
comment on table DBA_HIST_BASELINE is
'Baseline Metadata Information'
/
create or replace public synonym DBA_HIST_BASELINE 
    for DBA_HIST_BASELINE
/
grant select on DBA_HIST_BASELINE to SELECT_CATALOG_ROLE
/


/***************************************
 *       DBA_HIST_WR_CONTROL
 ***************************************/

create or replace view DBA_HIST_WR_CONTROL
  (DBID, SNAP_INTERVAL, RETENTION, TOPNSQL)
as
select dbid, snap_interval, retention, 
       decode(topnsql, 2000000000, 'DEFAULT', 
                       2000000001, 'MAXIMUM',
                       to_char(topnsql, '999999999')) topnsql
from WRM$_WR_CONTROL
/
comment on table DBA_HIST_WR_CONTROL is
'Workload Repository Control Information'
/
create or replace public synonym DBA_HIST_WR_CONTROL 
    for DBA_HIST_WR_CONTROL
/
grant select on DBA_HIST_WR_CONTROL to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_DATAFILE
 ***************************************/


create or replace view DBA_HIST_DATAFILE
  (DBID, FILE#, CREATION_CHANGE#, 
   FILENAME, TS#, TSNAME, BLOCK_SIZE) 
as
select dbid, file#, creation_change#,
       filename, ts#, tsname, block_size
from WRH$_DATAFILE
/
comment on table DBA_HIST_DATAFILE is
'Names of Datafiles'
/
create or replace public synonym DBA_HIST_DATAFILE for DBA_HIST_DATAFILE
/
grant select on DBA_HIST_DATAFILE to SELECT_CATALOG_ROLE
/


/*****************************************
 *        DBA_HIST_FILESTATXS
 *****************************************/
create or replace view DBA_HIST_FILESTATXS 
  (SNAP_ID, DBID, INSTANCE_NUMBER, 
   FILE#, CREATION_CHANGE#, FILENAME, TS#, TSNAME, BLOCK_SIZE,
   PHYRDS, PHYWRTS, SINGLEBLKRDS, READTIM, WRITETIM, 
   SINGLEBLKRDTIM, PHYBLKRD, PHYBLKWRT, WAIT_COUNT, TIME) 
as
select f.snap_id, f.dbid, f.instance_number, 
       f.file#, f.creation_change#, fn.filename, 
       fn.ts#, fn.tsname, fn.block_size,
       phyrds, phywrts, singleblkrds, readtim, writetim, 
       singleblkrdtim, phyblkrd, phyblkwrt, wait_count, time
from WRM$_SNAPSHOT sn, WRH$_FILESTATXS f, DBA_HIST_DATAFILE fn
where      f.dbid             = fn.dbid
      and  f.file#            = fn.file#
      and  f.creation_change# = fn.creation_change#
      and  f.snap_id          = sn.snap_id
      and  f.dbid             = sn.dbid
      and  f.instance_number  = sn.instance_number
      and  sn.status          = 0
      and  sn.bl_moved        = 0
union all
select f.snap_id, f.dbid, f.instance_number, 
       f.file#, f.creation_change#, fn.filename, 
       fn.ts#, fn.tsname, fn.block_size,
       phyrds, phywrts, singleblkrds, readtim, writetim, 
       singleblkrdtim, phyblkrd, phyblkwrt, wait_count, time
from WRM$_SNAPSHOT sn, WRH$_FILESTATXS_BL f, DBA_HIST_DATAFILE fn
where      f.dbid              = fn.dbid
      and  f.file#             = fn.file#
      and  f.creation_change#  = fn.creation_change#
      and  f.snap_id           = sn.snap_id
      and  f.dbid              = sn.dbid
      and  f.instance_number   = sn.instance_number
      and  sn.status           = 0
      and  sn.bl_moved         = 1
/

comment on table DBA_HIST_FILESTATXS is
'Datafile Historical Statistics Information'
/
create or replace public synonym DBA_HIST_FILESTATXS for DBA_HIST_FILESTATXS
/
grant select on DBA_HIST_FILESTATXS to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_TEMPFILE
 ***************************************/

create or replace view DBA_HIST_TEMPFILE
  (DBID, FILE#, CREATION_CHANGE#, 
   FILENAME, TS#, TSNAME, BLOCK_SIZE) 
as
select dbid, file#, creation_change#, 
       filename, ts#, tsname, block_size
from WRH$_TEMPFILE
/
comment on table DBA_HIST_TEMPFILE is
'Names of Temporary Datafiles'
/
create or replace public synonym DBA_HIST_TEMPFILE for DBA_HIST_TEMPFILE
/
grant select on DBA_HIST_TEMPFILE to SELECT_CATALOG_ROLE
/


/*****************************************
 *        DBA_HIST_TEMPSTATXS
 *****************************************/
create or replace view DBA_HIST_TEMPSTATXS
  (SNAP_ID, DBID, INSTANCE_NUMBER, 
   FILE#, CREATION_CHANGE#, FILENAME, TS#, TSNAME, BLOCK_SIZE,
   PHYRDS, PHYWRTS, SINGLEBLKRDS, READTIM, WRITETIM, 
   SINGLEBLKRDTIM, PHYBLKRD, PHYBLKWRT, WAIT_COUNT, TIME) 
as
select t.snap_id, t.dbid, t.instance_number, 
       t.file#, t.creation_change#, tn.filename, 
       tn.ts#, tn.tsname, tn.block_size, 
       phyrds, phywrts, singleblkrds, readtim, writetim, 
       singleblkrdtim, phyblkrd, phyblkwrt, wait_count, time
from WRM$_SNAPSHOT sn, WRH$_TEMPSTATXS t, DBA_HIST_TEMPFILE tn
where     t.dbid             = tn.dbid
      and t.file#            = tn.file#
      and t.creation_change# = tn.creation_change#
      and sn.snap_id         = t.snap_id
      and sn.dbid            = t.dbid
      and sn.instance_number = t.instance_number
      and sn.status          = 0
/

comment on table DBA_HIST_TEMPSTATXS is
'Temporary Datafile Historical Statistics Information'
/
create or replace public synonym DBA_HIST_TEMPSTATXS for DBA_HIST_TEMPSTATXS
/
grant select on DBA_HIST_TEMPSTATXS to SELECT_CATALOG_ROLE
/

/***************************************
 *        DBA_HIST_COMP_IOSTAT
 ***************************************/

create or replace view DBA_HIST_COMP_IOSTAT
  (SNAP_ID, DBID, INSTANCE_NUMBER, COMPONENT, 
   FILE_TYPE, IO_TYPE, OPERATION, BYTES, IO_COUNT) 
as
select io.snap_id, io.dbid, io.instance_number, io.component,
       io.file_type, io.io_type, io.operation, io.bytes, io.io_count
  from wrm$_snapshot sn, WRH$_COMP_IOSTAT io
  where     sn.snap_id         = io.snap_id
        and sn.dbid            = io.dbid
        and sn.instance_number = io.instance_number
        and sn.status          = 0
/
comment on table DBA_HIST_COMP_IOSTAT is
'I/O stats aggregated on component level'
/
create or replace public synonym DBA_HIST_COMP_IOSTAT 
  for DBA_HIST_COMP_IOSTAT
/
grant select on DBA_HIST_COMP_IOSTAT to SELECT_CATALOG_ROLE
/

/***************************************
 *        DBA_HIST_SQLSTAT
 ***************************************/

create or replace view DBA_HIST_SQLSTAT
  (SNAP_ID, DBID, INSTANCE_NUMBER,
   SQL_ID, PLAN_HASH_VALUE, 
   OPTIMIZER_COST, OPTIMIZER_MODE, OPTIMIZER_ENV_HASH_VALUE,
   SHARABLE_MEM, LOADED_VERSIONS, VERSION_COUNT,
   MODULE, ACTION,
   SQL_PROFILE, FORCE_MATCHING_SIGNATURE, 
   PARSING_SCHEMA_ID, PARSING_SCHEMA_NAME, 
   FETCHES_TOTAL, FETCHES_DELTA, 
   END_OF_FETCH_COUNT_TOTAL, END_OF_FETCH_COUNT_DELTA,
   SORTS_TOTAL, SORTS_DELTA, 
   EXECUTIONS_TOTAL, EXECUTIONS_DELTA, 
   PX_SERVERS_EXECS_TOTAL, PX_SERVERS_EXECS_DELTA, 
   LOADS_TOTAL, LOADS_DELTA, 
   INVALIDATIONS_TOTAL, INVALIDATIONS_DELTA,
   PARSE_CALLS_TOTAL, PARSE_CALLS_DELTA, DISK_READS_TOTAL, 
   DISK_READS_DELTA, BUFFER_GETS_TOTAL, BUFFER_GETS_DELTA,
   ROWS_PROCESSED_TOTAL, ROWS_PROCESSED_DELTA, CPU_TIME_TOTAL,
   CPU_TIME_DELTA, ELAPSED_TIME_TOTAL, ELAPSED_TIME_DELTA,
   IOWAIT_TOTAL, IOWAIT_DELTA, CLWAIT_TOTAL, CLWAIT_DELTA,
   APWAIT_TOTAL, APWAIT_DELTA, CCWAIT_TOTAL, CCWAIT_DELTA,
   DIRECT_WRITES_TOTAL, DIRECT_WRITES_DELTA, PLSEXEC_TIME_TOTAL,
   PLSEXEC_TIME_DELTA, JAVEXEC_TIME_TOTAL, JAVEXEC_TIME_DELTA, BIND_DATA)
as
select sql.snap_id, sql.dbid, sql.instance_number,
       sql_id, plan_hash_value, 
       optimizer_cost, optimizer_mode, optimizer_env_hash_value,
       sharable_mem, loaded_versions, version_count,
       module, action,
       sql_profile, force_matching_signature, 
       parsing_schema_id, parsing_schema_name, 
       fetches_total, fetches_delta, 
       end_of_fetch_count_total, end_of_fetch_count_delta,
       sorts_total, sorts_delta, 
       executions_total, executions_delta, 
       px_servers_execs_total, px_servers_execs_delta, 
       loads_total, loads_delta, 
       invalidations_total, invalidations_delta,
       parse_calls_total, parse_calls_delta, disk_reads_total, 
       disk_reads_delta, buffer_gets_total, buffer_gets_delta,
       rows_processed_total, rows_processed_delta, cpu_time_total,
       cpu_time_delta, elapsed_time_total, elapsed_time_delta,
       iowait_total, iowait_delta, clwait_total, clwait_delta,
       apwait_total, apwait_delta, ccwait_total, ccwait_delta,
       direct_writes_total, direct_writes_delta, plsexec_time_total,
       plsexec_time_delta, javexec_time_total, javexec_time_delta,
       bind_data
from WRM$_SNAPSHOT sn, WRH$_SQLSTAT sql
  where     sn.snap_id         = sql.snap_id
        and sn.dbid            = sql.dbid
        and sn.instance_number = sql.instance_number
        and sn.status          = 0
        and sn.bl_moved        = 0
union all
select sql.snap_id, sql.dbid, sql.instance_number,
       sql_id, plan_hash_value, 
       optimizer_cost, optimizer_mode, optimizer_env_hash_value,
       sharable_mem, loaded_versions, version_count,
       module, action,
       sql_profile, force_matching_signature, 
       parsing_schema_id, parsing_schema_name, 
       fetches_total, fetches_delta, 
       end_of_fetch_count_total, end_of_fetch_count_delta,
       sorts_total, sorts_delta, 
       executions_total, executions_delta, 
       px_servers_execs_total, px_servers_execs_delta, 
       loads_total, loads_delta, 
       invalidations_total, invalidations_delta,
       parse_calls_total, parse_calls_delta, disk_reads_total, 
       disk_reads_delta, buffer_gets_total, buffer_gets_delta,
       rows_processed_total, rows_processed_delta, cpu_time_total,
       cpu_time_delta, elapsed_time_total, elapsed_time_delta,
       iowait_total, iowait_delta, clwait_total, clwait_delta,
       apwait_total, apwait_delta, ccwait_total, ccwait_delta,
       direct_writes_total, direct_writes_delta, plsexec_time_total,
       plsexec_time_delta, javexec_time_total, javexec_time_delta,
       bind_data
from WRM$_SNAPSHOT sn, WRH$_SQLSTAT_BL sql
  where     sn.snap_id         = sql.snap_id
        and sn.dbid            = sql.dbid
        and sn.instance_number = sql.instance_number
        and sn.status          = 0
        and sn.bl_moved        = 1
/

comment on table DBA_HIST_SQLSTAT is
'SQL Historical Statistics Information'
/
create or replace public synonym DBA_HIST_SQLSTAT for DBA_HIST_SQLSTAT
/
grant select on DBA_HIST_SQLSTAT to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_SQLTEXT
 ***************************************/

create or replace view DBA_HIST_SQLTEXT
  (DBID, SQL_ID, SQL_TEXT, COMMAND_TYPE)
as
select dbid, sql_id, sql_text, command_type
from WRH$_SQLTEXT
/
comment on table DBA_HIST_SQLTEXT is
'SQL Text'
/
create or replace public synonym DBA_HIST_SQLTEXT for DBA_HIST_SQLTEXT
/
grant select on DBA_HIST_SQLTEXT to SELECT_CATALOG_ROLE
/


/***************************************
 *       DBA_HIST_SQL_SUMMARY
 ***************************************/

create or replace view DBA_HIST_SQL_SUMMARY
  (SNAP_ID, DBID, INSTANCE_NUMBER, TOTAL_SQL, TOTAL_SQL_MEM,
   SINGLE_USE_SQL, SINGLE_USE_SQL_MEM)
as
select ss.snap_id, ss.dbid, ss.instance_number, 
       total_sql, total_sql_mem,
       single_use_sql, single_use_sql_mem
from WRM$_SNAPSHOT sn, WRH$_SQL_SUMMARY ss
where     sn.snap_id         = ss.snap_id
      and sn.dbid            = ss.dbid
      and sn.instance_number = ss.instance_number
      and sn.status          = 0
/

comment on table DBA_HIST_SQL_SUMMARY is
'Summary of SQL Statistics'
/
create or replace public synonym DBA_HIST_SQL_SUMMARY 
   for DBA_HIST_SQL_SUMMARY
/
grant select on DBA_HIST_SQL_SUMMARY to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_SQL_PLAN
 ***************************************/

create or replace view DBA_HIST_SQL_PLAN
  (DBID, SQL_ID, PLAN_HASH_VALUE, ID, OPERATION, OPTIONS,
   OBJECT_NODE, OBJECT#, OBJECT_OWNER, OBJECT_NAME,
   OBJECT_ALIAS, OBJECT_TYPE, OPTIMIZER,
   PARENT_ID, DEPTH, POSITION, SEARCH_COLUMNS, COST, CARDINALITY,
   BYTES, OTHER_TAG, PARTITION_START, PARTITION_STOP, PARTITION_ID,
   OTHER, DISTRIBUTION, CPU_COST, IO_COST, TEMP_SPACE, 
   ACCESS_PREDICATES, FILTER_PREDICATES,
   PROJECTION, TIME, QBLOCK_NAME, REMARKS, TIMESTAMP, OTHER_XML)
as
select dbid, sql_id, plan_hash_value, id, operation, options,
       object_node, object#, object_owner, object_name, 
       object_alias, object_type, optimizer,
       parent_id, depth, position, search_columns, cost, cardinality,
       bytes, other_tag, partition_start, partition_stop, partition_id,
       other, distribution, cpu_cost, io_cost, temp_space, 
       access_predicates, filter_predicates,
       projection, time, qblock_name, remarks, timestamp, other_xml
from WRH$_SQL_PLAN
/
comment on table DBA_HIST_SQL_PLAN is
'SQL Plan Information'
/
create or replace public synonym DBA_HIST_SQL_PLAN for DBA_HIST_SQL_PLAN
/
grant select on DBA_HIST_SQL_PLAN to SELECT_CATALOG_ROLE
/

/***************************************
 *        DBA_HIST_SQL_BIND_METADATA
 ***************************************/

create or replace view DBA_HIST_SQL_BIND_METADATA
  (DBID, SQL_ID, NAME, POSITION, DUP_POSITION, 
   DATATYPE, DATATYPE_STRING, 
   CHARACTER_SID, PRECISION, SCALE, MAX_LENGTH)
as
select dbid, sql_id, name, position, dup_position, 
       datatype, datatype_string, 
       character_sid, precision, scale, max_length
  from WRH$_SQL_BIND_METADATA 
/

comment on table DBA_HIST_SQL_BIND_METADATA is
'SQL Bind Metadata Information'
/
create or replace public synonym DBA_HIST_SQL_BIND_METADATA 
  for DBA_HIST_SQL_BIND_METADATA
/
grant select on DBA_HIST_SQL_BIND_METADATA to SELECT_CATALOG_ROLE
/

/***************************************
 *     DBA_HIST_SQLBIND
 ***************************************/

create or replace view DBA_HIST_SQLBIND
   (SNAP_ID, DBID, INSTANCE_NUMBER, 
    SQL_ID, NAME, POSITION, DUP_POSITION, DATATYPE, DATATYPE_STRING,
    CHARACTER_SID, PRECISION, SCALE, MAX_LENGTH, WAS_CAPTURED,
    LAST_CAPTURED, VALUE_STRING, VALUE_ANYDATA)
as 
select snap_id                                                 snap_id,
       dbid                                                    dbid,
       instance_number                                         instance_number,
       sql_id                                                  sql_id,
       name                                                    name, 
       position                                                position, 
       nvl2(cap_bv, v.cap_bv.dup_position, dup_position)       dup_position,
       nvl2(cap_bv, v.cap_bv.datatype, datatype)               datatype,
       nvl2(cap_bv, v.cap_bv.datatype_string, datatype_string) datatype_string,
       nvl2(cap_bv, v.cap_bv.character_sid, character_sid)     character_sid,
       nvl2(cap_bv, v.cap_bv.precision, precision)             precision,
       nvl2(cap_bv, v.cap_bv.scale, scale)                     scale,
       nvl2(cap_bv, v.cap_bv.max_length, max_length)           max_length,
       nvl2(cap_bv, 'YES', 'NO')                               was_captured,
       nvl2(cap_bv, v.cap_bv.last_captured, NULL)              last_captured,
       nvl2(cap_bv, v.cap_bv.value_string, NULL)               value_string,
       nvl2(cap_bv, v.cap_bv.value_anydata, NULL)              value_anydata
from
(select sql.snap_id, sql.dbid, sql.instance_number, sbm.sql_id,
        dbms_sqltune.extract_bind(sql.bind_data, sbm.position) cap_bv,
        sbm.name,
        sbm.position,
        sbm.dup_position,
        sbm.datatype,
        sbm.datatype_string,
        sbm.character_sid,
        sbm.precision,
        sbm.scale,
        sbm.max_length
 from   wrm$_snapshot sn, wrh$_sql_bind_metadata sbm, wrh$_sqlstat sql
 where      sn.snap_id         = sql.snap_id
        and sn.dbid            = sql.dbid
        and sn.instance_number = sql.instance_number
        and sbm.sql_id         = sql.sql_id
        and sn.status          = 0
        and sn.bl_moved        = 0
 union all
 select sql.snap_id, sql.dbid, sql.instance_number, sbm.sql_id,
        dbms_sqltune.extract_bind(sql.bind_data, sbm.position) cap_bv,
        sbm.name,
        sbm.position,
        sbm.dup_position,
        sbm.datatype,
        sbm.datatype_string,
        sbm.character_sid,
        sbm.precision,
        sbm.scale,
        sbm.max_length
 from   wrm$_snapshot sn, wrh$_sql_bind_metadata sbm, wrh$_sqlstat_bl sql
 where      sn.snap_id         = sql.snap_id
        and sn.dbid            = sql.dbid
        and sn.instance_number = sql.instance_number
        and sbm.sql_id         = sql.sql_id
        and sn.status          = 0
        and sn.bl_moved        = 1) v
/
comment on table DBA_HIST_SQLBIND is
'SQL Bind Information'
/
create or replace public synonym DBA_HIST_SQLBIND for DBA_HIST_SQLBIND
/
grant select on DBA_HIST_SQLBIND to SELECT_CATALOG_ROLE
/


/***************************************
 *      DBA_HIST_OPTIMIZER_ENV
 ***************************************/

create or replace view DBA_HIST_OPTIMIZER_ENV
  (DBID, OPTIMIZER_ENV_HASH_VALUE, OPTIMIZER_ENV)
as
select dbid, optimizer_env_hash_value, optimizer_env
from WRH$_OPTIMIZER_ENV
/
comment on table DBA_HIST_OPTIMIZER_ENV is
'Optimizer Environment Information'
/
create or replace public synonym DBA_HIST_OPTIMIZER_ENV 
   for DBA_HIST_OPTIMIZER_ENV
/
grant select on DBA_HIST_OPTIMIZER_ENV to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_EVENT_NAME
 ***************************************/

create or replace view DBA_HIST_EVENT_NAME
  (DBID, EVENT_ID, EVENT_NAME, PARAMETER1, PARAMETER2, PARAMETER3, 
   WAIT_CLASS_ID, WAIT_CLASS)
as
select dbid, event_id, event_name, parameter1, parameter2, parameter3, 
       wait_class_id, wait_class
  from WRH$_EVENT_NAME
/

comment on table DBA_HIST_EVENT_NAME is
'Event Names'
/
create or replace public synonym DBA_HIST_EVENT_NAME for DBA_HIST_EVENT_NAME
/
grant select on DBA_HIST_EVENT_NAME to SELECT_CATALOG_ROLE
/


/***************************************
 *      DBA_HIST_SYSTEM_EVENT
 ***************************************/

create or replace view DBA_HIST_SYSTEM_EVENT
  (SNAP_ID, DBID, INSTANCE_NUMBER, 
   EVENT_ID, EVENT_NAME, WAIT_CLASS_ID, WAIT_CLASS,
   TOTAL_WAITS, TOTAL_TIMEOUTS, TIME_WAITED_MICRO)
as
select e.snap_id, e.dbid, e.instance_number, 
       e.event_id, en.event_name, en.wait_class_id, en.wait_class,
       total_waits, total_timeouts, time_waited_micro
from WRM$_SNAPSHOT sn, WRH$_SYSTEM_EVENT e, 
     DBA_HIST_EVENT_NAME en
where     e.event_id         = en.event_id
      and e.dbid             = en.dbid
      and e.snap_id          = sn.snap_id
      and e.dbid             = sn.dbid
      and e.instance_number  = sn.instance_number
      and sn.status          = 0
      and sn.bl_moved        = 0
union all
select e.snap_id, e.dbid, e.instance_number, 
       e.event_id, en.event_name, en.wait_class_id, en.wait_class,
       total_waits, total_timeouts, time_waited_micro
from WRM$_SNAPSHOT sn, WRH$_SYSTEM_EVENT_BL e, 
     DBA_HIST_EVENT_NAME en
where     e.event_id         = en.event_id
      and e.dbid             = en.dbid
      and e.snap_id          = sn.snap_id
      and e.dbid             = sn.dbid
      and e.instance_number  = sn.instance_number
      and sn.status          = 0
      and sn.bl_moved        = 1
/

comment on table DBA_HIST_SYSTEM_EVENT is
'System Event Historical Statistics Information'
/
create or replace public synonym DBA_HIST_SYSTEM_EVENT 
    for DBA_HIST_SYSTEM_EVENT
/
grant select on DBA_HIST_SYSTEM_EVENT to SELECT_CATALOG_ROLE
/


/***************************************
 *      DBA_HIST_BG_EVENT_SUMMARY
 ***************************************/

create or replace view DBA_HIST_BG_EVENT_SUMMARY
  (SNAP_ID, DBID, INSTANCE_NUMBER, 
   EVENT_ID, EVENT_NAME, WAIT_CLASS_ID, WAIT_CLASS,
   TOTAL_WAITS, TOTAL_TIMEOUTS, TIME_WAITED_MICRO) 
as
select e.snap_id, e.dbid, e.instance_number, 
       e.event_id, en.event_name, en.wait_class_id, en.wait_class,
       total_waits, total_timeouts, time_waited_micro
from WRM$_SNAPSHOT sn, WRH$_BG_EVENT_SUMMARY e, DBA_HIST_EVENT_NAME en
where     sn.snap_id         = e.snap_id
      and sn.dbid            = e.dbid
      and sn.instance_number = e.instance_number
      and sn.status          = 0
      and e.event_id         = en.event_id
      and e.dbid             = en.dbid
/

comment on table DBA_HIST_BG_EVENT_SUMMARY is
'Summary of Background Event Historical Statistics Information'
/
create or replace public synonym DBA_HIST_BG_EVENT_SUMMARY 
   for DBA_HIST_BG_EVENT_SUMMARY
/
grant select on DBA_HIST_BG_EVENT_SUMMARY to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_WAITSTAT
 ***************************************/

create or replace view DBA_HIST_WAITSTAT
  (SNAP_ID, DBID, INSTANCE_NUMBER, CLASS,
   WAIT_COUNT, TIME) 
as
select wt.snap_id, wt.dbid, wt.instance_number, 
       class, wait_count, time
  from wrm$_snapshot sn, WRH$_WAITSTAT wt
  where     sn.snap_id         = wt.snap_id
        and sn.dbid            = wt.dbid
        and sn.instance_number = wt.instance_number
        and sn.status          = 0
        and sn.bl_moved        = 0
union all
select bl.snap_id, bl.dbid, bl.instance_number, class,
       wait_count, time
  from wrm$_snapshot sn, WRH$_WAITSTAT_BL bl
  where     sn.snap_id         = bl.snap_id
        and sn.dbid            = bl.dbid
        and sn.instance_number = bl.instance_number
        and sn.status          = 0
        and sn.bl_moved        = 1
/

comment on table DBA_HIST_WAITSTAT is
'Wait Historical Statistics Information'
/
create or replace public synonym DBA_HIST_WAITSTAT for DBA_HIST_WAITSTAT
/
grant select on DBA_HIST_WAITSTAT to SELECT_CATALOG_ROLE
/


/***************************************
 *      DBA_HIST_ENQUEUE_STAT
 ***************************************/

create or replace view DBA_HIST_ENQUEUE_STAT
  (SNAP_ID, DBID, INSTANCE_NUMBER, EQ_TYPE, REQ_REASON, TOTAL_REQ#,
   TOTAL_WAIT#, SUCC_REQ#, FAILED_REQ#, CUM_WAIT_TIME, EVENT#) 
as
select eq.snap_id, eq.dbid, eq.instance_number, 
       eq_type, req_reason, total_req#,
       total_wait#, succ_req#, failed_req#, cum_wait_time, event#
  from wrm$_snapshot sn, WRH$_ENQUEUE_STAT eq
  where     sn.snap_id         = eq.snap_id
        and sn.dbid            = eq.dbid
        and sn.instance_number = eq.instance_number
        and sn.status          = 0
/

comment on table DBA_HIST_ENQUEUE_STAT is
'Enqueue Historical Statistics Information'
/
create or replace public synonym DBA_HIST_ENQUEUE_STAT 
    for DBA_HIST_ENQUEUE_STAT
/
grant select on DBA_HIST_ENQUEUE_STAT to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_LATCH_NAME
 ***************************************/

create or replace view DBA_HIST_LATCH_NAME
  (DBID, LATCH_HASH, LATCH_NAME)
as
select dbid, latch_hash, latch_name
from WRH$_LATCH_NAME
/

comment on table DBA_HIST_LATCH_NAME is
'Latch Names'
/
create or replace public synonym DBA_HIST_LATCH_NAME for DBA_HIST_LATCH_NAME
/
grant select on DBA_HIST_LATCH_NAME to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_LATCH
 ***************************************/

create or replace view DBA_HIST_LATCH
  (SNAP_ID, DBID, INSTANCE_NUMBER, 
   LATCH_HASH, LATCH_NAME, LEVEL#, GETS,
   MISSES, SLEEPS, IMMEDIATE_GETS, IMMEDIATE_MISSES, SPIN_GETS,
   SLEEP1, SLEEP2, SLEEP3, SLEEP4, WAIT_TIME) 
as
select l.snap_id, l.dbid, l.instance_number, 
       l.latch_hash, ln.latch_name, level#, 
       gets, misses, sleeps, immediate_gets, immediate_misses, spin_gets,
       sleep1, sleep2, sleep3, sleep4, wait_time
from WRM$_SNAPSHOT sn, WRH$_LATCH l, DBA_HIST_LATCH_NAME ln
where      l.latch_hash       = ln.latch_hash
      and  l.dbid             = ln.dbid
      and  l.snap_id          = sn.snap_id
      and  l.dbid             = sn.dbid
      and  l.instance_number  = sn.instance_number
      and  sn.status          = 0
      and  sn.bl_moved        = 0
union all
select l.snap_id, l.dbid, l.instance_number, 
       l.latch_hash, ln.latch_name, level#, 
       gets, misses, sleeps, immediate_gets, immediate_misses, spin_gets,
       sleep1, sleep2, sleep3, sleep4, wait_time
from WRM$_SNAPSHOT sn, WRH$_LATCH_BL l, DBA_HIST_LATCH_NAME ln
where      l.latch_hash        = ln.latch_hash
      and  l.dbid              = ln.dbid
      and  l.snap_id           = sn.snap_id
      and  l.dbid              = sn.dbid
      and  l.instance_number   = sn.instance_number
      and  sn.status           = 0
      and  sn.bl_moved         = 1
/

comment on table DBA_HIST_LATCH is
'Latch Historical Statistics Information'
/
create or replace public synonym DBA_HIST_LATCH for DBA_HIST_LATCH
/
grant select on DBA_HIST_LATCH to SELECT_CATALOG_ROLE
/


/***************************************
 *      DBA_HIST_LATCH_CHILDREN
 ***************************************/

create or replace view DBA_HIST_LATCH_CHILDREN
  (SNAP_ID, DBID, INSTANCE_NUMBER, 
   LATCH_HASH, LATCH_NAME, CHILD#, GETS,
   MISSES, SLEEPS, IMMEDIATE_GETS, IMMEDIATE_MISSES, SPIN_GETS,
   SLEEP1, SLEEP2, SLEEP3, SLEEP4, WAIT_TIME)
as
select l.snap_id, l.dbid, l.instance_number, 
       l.latch_hash, ln.latch_name, child#, 
       gets, misses, sleeps, immediate_gets, immediate_misses, spin_gets,
       sleep1, sleep2, sleep3, sleep4, wait_time
from WRM$_SNAPSHOT sn, WRH$_LATCH_CHILDREN l, DBA_HIST_LATCH_NAME ln
where      l.latch_hash       = ln.latch_hash
      and  l.dbid             = ln.dbid
      and  l.snap_id          = sn.snap_id
      and  l.dbid             = sn.dbid
      and  l.instance_number  = sn.instance_number
      and  sn.status          = 0
      and  sn.bl_moved        = 0
union all
select l.snap_id, l.dbid, l.instance_number, 
       l.latch_hash, ln.latch_name, child#, 
       gets, misses, sleeps, immediate_gets, immediate_misses, spin_gets,
       sleep1, sleep2, sleep3, sleep4, wait_time
from WRM$_SNAPSHOT sn, WRH$_LATCH_CHILDREN_BL l, DBA_HIST_LATCH_NAME ln
where      l.latch_hash        = ln.latch_hash
      and  l.dbid              = ln.dbid
      and  l.snap_id           = sn.snap_id
      and  l.dbid              = sn.dbid
      and  l.instance_number   = sn.instance_number
      and  sn.status           = 0
      and  sn.bl_moved         = 1
/

comment on table DBA_HIST_LATCH_CHILDREN is
'Latch Children Historical Statistics Information'
/
create or replace public synonym DBA_HIST_LATCH_CHILDREN 
    for DBA_HIST_LATCH_CHILDREN
/
grant select on DBA_HIST_LATCH_CHILDREN to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_LATCH_PARENT
 ***************************************/

create or replace view DBA_HIST_LATCH_PARENT
  (SNAP_ID, DBID, INSTANCE_NUMBER, 
   LATCH_HASH, LATCH_NAME, LEVEL#, GETS,
   MISSES, SLEEPS, IMMEDIATE_GETS, IMMEDIATE_MISSES, SPIN_GETS,
   SLEEP1, SLEEP2, SLEEP3, SLEEP4, WAIT_TIME)
as
select l.snap_id, l.dbid, l.instance_number, 
       l.latch_hash, ln.latch_name, level#, 
       gets, misses, sleeps, immediate_gets, immediate_misses, spin_gets,
       sleep1, sleep2, sleep3, sleep4, wait_time
from WRM$_SNAPSHOT sn, WRH$_LATCH_PARENT l, DBA_HIST_LATCH_NAME ln
where      l.latch_hash       = ln.latch_hash
      and  l.dbid             = ln.dbid
      and  l.snap_id          = sn.snap_id
      and  l.dbid             = sn.dbid
      and  l.instance_number  = sn.instance_number
      and  sn.status          = 0
      and  sn.bl_moved        = 0
union all
select l.snap_id, l.dbid, l.instance_number, 
       l.latch_hash, ln.latch_name, level#, 
       gets, misses, sleeps, immediate_gets, immediate_misses, spin_gets,
       sleep1, sleep2, sleep3, sleep4, wait_time
from WRM$_SNAPSHOT sn, WRH$_LATCH_PARENT_BL l, DBA_HIST_LATCH_NAME ln
where      l.latch_hash        = ln.latch_hash
      and  l.dbid              = ln.dbid
      and  l.snap_id           = sn.snap_id
      and  l.dbid              = sn.dbid
      and  l.instance_number   = sn.instance_number
      and  sn.status           = 0
      and  sn.bl_moved         = 1
/

comment on table DBA_HIST_LATCH_PARENT is
'Latch Parent Historical Historical Statistics Information'
/
create or replace public synonym DBA_HIST_LATCH_PARENT 
    for DBA_HIST_LATCH_PARENT
/
grant select on DBA_HIST_LATCH_PARENT to SELECT_CATALOG_ROLE
/


/***************************************
 *    DBA_HIST_LATCH_MISSES_SUMMARY
 ***************************************/

create or replace view DBA_HIST_LATCH_MISSES_SUMMARY
  (SNAP_ID, DBID, INSTANCE_NUMBER, PARENT_NAME, WHERE_IN_CODE,
   NWFAIL_COUNT, SLEEP_COUNT, WTR_SLP_COUNT) 
as
select l.snap_id, l.dbid, l.instance_number, parent_name, where_in_code,
       nwfail_count, sleep_count, wtr_slp_count
from WRM$_SNAPSHOT sn, WRH$_LATCH_MISSES_SUMMARY l
where      l.snap_id          = sn.snap_id
      and  l.dbid             = sn.dbid
      and  l.instance_number  = sn.instance_number
      and  sn.status          = 0
      and  sn.bl_moved        = 0
union all
select l.snap_id, l.dbid, l.instance_number, parent_name, where_in_code,
       nwfail_count, sleep_count, wtr_slp_count
from WRM$_SNAPSHOT sn, WRH$_LATCH_MISSES_SUMMARY_BL l
where      l.snap_id          = sn.snap_id
      and  l.dbid             = sn.dbid
      and  l.instance_number  = sn.instance_number
      and  sn.status          = 0
      and  sn.bl_moved        = 1
/

comment on table DBA_HIST_LATCH_MISSES_SUMMARY is
'Latch Misses Summary Historical Statistics Information'
/
create or replace public synonym DBA_HIST_LATCH_MISSES_SUMMARY 
    for DBA_HIST_LATCH_MISSES_SUMMARY
/
grant select on DBA_HIST_LATCH_MISSES_SUMMARY to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_LIBRARYCACHE
 ***************************************/

create or replace view DBA_HIST_LIBRARYCACHE
  (SNAP_ID, DBID, INSTANCE_NUMBER, NAMESPACE, GETS, 
   GETHITS, PINS, PINHITS, RELOADS, INVALIDATIONS, 
   DLM_LOCK_REQUESTS, DLM_PIN_REQUESTS, DLM_PIN_RELEASES, 
   DLM_INVALIDATION_REQUESTS, DLM_INVALIDATIONS)
as
select lc.snap_id, lc.dbid, lc.instance_number, namespace, gets, 
       gethits, pins, pinhits, reloads, invalidations, 
       dlm_lock_requests, dlm_pin_requests, dlm_pin_releases, 
       dlm_invalidation_requests, dlm_invalidations
  from wrm$_snapshot sn, WRH$_LIBRARYCACHE lc
  where     sn.snap_id         = lc.snap_id
        and sn.dbid            = lc.dbid
        and sn.instance_number = lc.instance_number
        and sn.status          = 0
/

comment on table DBA_HIST_LIBRARYCACHE is
'Library Cache Historical Statistics Information'
/
create or replace public synonym DBA_HIST_LIBRARYCACHE 
    for DBA_HIST_LIBRARYCACHE
/
grant select on DBA_HIST_LIBRARYCACHE to SELECT_CATALOG_ROLE
/


/***************************************
 *     DBA_HIST_DB_CACHE_ADVICE
 ***************************************/

create or replace view DBA_HIST_DB_CACHE_ADVICE
  (SNAP_ID, DBID, INSTANCE_NUMBER, BPID, BUFFERS_FOR_ESTIMATE,
   NAME, BLOCK_SIZE, ADVICE_STATUS, SIZE_FOR_ESTIMATE, 
   SIZE_FACTOR, PHYSICAL_READS, BASE_PHYSICAL_READS,
   ACTUAL_PHYSICAL_READS)
as
select db.snap_id, db.dbid, db.instance_number, 
       bpid, buffers_for_estimate,
       name, block_size, advice_status, size_for_estimate, 
       size_factor, physical_reads, base_physical_reads,
       actual_physical_reads
from WRM$_SNAPSHOT sn, WRH$_DB_CACHE_ADVICE db
where      db.snap_id          = sn.snap_id
      and  db.dbid             = sn.dbid
      and  db.instance_number  = sn.instance_number
      and  sn.status           = 0
      and  sn.bl_moved         = 0
union all
select db.snap_id, db.dbid, db.instance_number, 
       bpid, buffers_for_estimate,
       name, block_size, advice_status, size_for_estimate, 
       size_factor, physical_reads, base_physical_reads,
       actual_physical_reads
from WRM$_SNAPSHOT sn, WRH$_DB_CACHE_ADVICE_BL db
where      db.snap_id          = sn.snap_id
      and  db.dbid             = sn.dbid
      and  db.instance_number  = sn.instance_number
      and  sn.status           = 0
      and  sn.bl_moved         = 1
/

comment on table DBA_HIST_DB_CACHE_ADVICE is
'DB Cache Advice History Information'
/
create or replace public synonym DBA_HIST_DB_CACHE_ADVICE
    for DBA_HIST_DB_CACHE_ADVICE
/
grant select on DBA_HIST_DB_CACHE_ADVICE to SELECT_CATALOG_ROLE
/


/***************************************
 *     DBA_HIST_BUFFER_POOL_STAT
 ***************************************/

create or replace view DBA_HIST_BUFFER_POOL_STAT
  (SNAP_ID, DBID, INSTANCE_NUMBER, ID, NAME, BLOCK_SIZE, SET_MSIZE,
   CNUM_REPL, CNUM_WRITE, CNUM_SET, BUF_GOT, SUM_WRITE, SUM_SCAN,
   FREE_BUFFER_WAIT, WRITE_COMPLETE_WAIT, BUFFER_BUSY_WAIT,
   FREE_BUFFER_INSPECTED, DIRTY_BUFFERS_INSPECTED,
   DB_BLOCK_CHANGE, DB_BLOCK_GETS, CONSISTENT_GETS,
   PHYSICAL_READS, PHYSICAL_WRITES) 
as
select bp.snap_id, bp.dbid, bp.instance_number, 
       id, name, block_size, set_msize,
       cnum_repl, cnum_write, cnum_set, buf_got, sum_write, sum_scan,
       free_buffer_wait, write_complete_wait, buffer_busy_wait,
       free_buffer_inspected, dirty_buffers_inspected,
       db_block_change, db_block_gets, consistent_gets,
       physical_reads, physical_writes
  from WRM$_SNAPSHOT sn, WRH$_BUFFER_POOL_STATISTICS bp
  where     sn.snap_id         = bp.snap_id
        and sn.dbid            = bp.dbid
        and sn.instance_number = bp.instance_number
        and sn.status          = 0
/
comment on table DBA_HIST_BUFFER_POOL_STAT is
'Buffer Pool Historical Statistics Information'
/
create or replace public synonym DBA_HIST_BUFFER_POOL_STAT
    for DBA_HIST_BUFFER_POOL_STAT
/
grant select on DBA_HIST_BUFFER_POOL_STAT to SELECT_CATALOG_ROLE
/


/***************************************
 *     DBA_HIST_ROWCACHE_SUMMARY
 ***************************************/

create or replace view DBA_HIST_ROWCACHE_SUMMARY
  (SNAP_ID, DBID, INSTANCE_NUMBER, PARAMETER, TOTAL_USAGE,
   USAGE, GETS, GETMISSES, SCANS, SCANMISSES, SCANCOMPLETES,
   MODIFICATIONS, FLUSHES, DLM_REQUESTS, DLM_CONFLICTS, 
   DLM_RELEASES)
as
select rc.snap_id, rc.dbid, rc.instance_number, 
       parameter, total_usage,
       usage, gets, getmisses, scans, scanmisses, scancompletes,
       modifications, flushes, dlm_requests, dlm_conflicts, 
       dlm_releases
  from WRM$_SNAPSHOT sn, WRH$_ROWCACHE_SUMMARY rc
  where     sn.snap_id         = rc.snap_id
        and sn.dbid            = rc.dbid
        and sn.instance_number = rc.instance_number
        and sn.status          = 0
        and sn.bl_moved        = 0
union all
select rc.snap_id, rc.dbid, rc.instance_number, 
       parameter, total_usage,
       usage, gets, getmisses, scans, scanmisses, scancompletes,
       modifications, flushes, dlm_requests, dlm_conflicts, 
       dlm_releases
  from WRM$_SNAPSHOT sn, WRH$_ROWCACHE_SUMMARY_BL rc
  where     sn.snap_id         = rc.snap_id
        and sn.dbid            = rc.dbid
        and sn.instance_number = rc.instance_number
        and sn.status          = 0
        and sn.bl_moved        = 1
/

comment on table DBA_HIST_ROWCACHE_SUMMARY is
'Row Cache Historical Statistics Information Summary'
/
create or replace public synonym DBA_HIST_ROWCACHE_SUMMARY
    for DBA_HIST_ROWCACHE_SUMMARY
/
grant select on DBA_HIST_ROWCACHE_SUMMARY to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_SGA
 ***************************************/

create or replace view DBA_HIST_SGA
 (SNAP_ID, DBID, INSTANCE_NUMBER, NAME, VALUE)
as
select sga.snap_id, sga.dbid, sga.instance_number, name, value
  from wrm$_snapshot sn, WRH$_SGA sga
  where     sn.snap_id         = sga.snap_id
        and sn.dbid            = sga.dbid
        and sn.instance_number = sga.instance_number
        and sn.status          = 0
/

comment on table DBA_HIST_SGA is
'SGA Historical Statistics Information'
/
create or replace public synonym DBA_HIST_SGA for DBA_HIST_SGA
/
grant select on DBA_HIST_SGA to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_SGASTAT
 ***************************************/

create or replace view DBA_HIST_SGASTAT
  (SNAP_ID, DBID, INSTANCE_NUMBER, NAME, POOL, BYTES) 
as
select sga.snap_id, sga.dbid, sga.instance_number, name, pool, bytes
  from wrm$_snapshot sn, WRH$_SGASTAT sga
  where     sn.snap_id         = sga.snap_id
        and sn.dbid            = sga.dbid
        and sn.instance_number = sga.instance_number
        and sn.status          = 0
        and sn.bl_moved        = 0
union all
select sga.snap_id, sga.dbid, sga.instance_number, name, pool, bytes
  from wrm$_snapshot sn, WRH$_SGASTAT_BL sga
  where     sn.snap_id         = sga.snap_id
        and sn.dbid            = sga.dbid
        and sn.instance_number = sga.instance_number
        and sn.status          = 0
        and sn.bl_moved        = 1
/

comment on table DBA_HIST_SGASTAT is
'SGA Pool Historical Statistics Information'
/
create or replace public synonym DBA_HIST_SGASTAT for DBA_HIST_SGASTAT
/
grant select on DBA_HIST_SGASTAT to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_PGASTAT
 ***************************************/

create or replace view DBA_HIST_PGASTAT
  (SNAP_ID, DBID, INSTANCE_NUMBER, NAME, VALUE) 
as
select pga.snap_id, pga.dbid, pga.instance_number, name, value
  from wrm$_snapshot sn, WRH$_PGASTAT pga
  where     sn.snap_id         = pga.snap_id
        and sn.dbid            = pga.dbid
        and sn.instance_number = pga.instance_number
        and sn.status          = 0
/

comment on table DBA_HIST_PGASTAT is
'PGA Historical Statistics Information'
/
create or replace public synonym DBA_HIST_PGASTAT for DBA_HIST_PGASTAT
/
grant select on DBA_HIST_PGASTAT to SELECT_CATALOG_ROLE
/


/***************************************
 *   DBA_HIST_PROCESS_MEM_SUMMARY
 ***************************************/

create or replace view DBA_HIST_PROCESS_MEM_SUMMARY
  (SNAP_ID, DBID, INSTANCE_NUMBER, 
   CATEGORY, NUM_PROCESSES, NON_ZERO_ALLOCS, 
   USED_TOTAL, ALLOCATED_TOTAL, ALLOCATED_AVG, 
   ALLOCATED_STDDEV, ALLOCATED_MAX, MAX_ALLOCATED_MAX)
as
select pmem.snap_id, pmem.dbid, pmem.instance_number,
       category, num_processes, non_zero_allocs, 
       used_total, allocated_total, allocated_total / num_processes, 
       allocated_stddev, allocated_max, max_allocated_max
  from wrm$_snapshot sn, WRH$_PROCESS_MEMORY_SUMMARY pmem
  where     sn.snap_id         = pmem.snap_id
        and sn.dbid            = pmem.dbid
        and sn.instance_number = pmem.instance_number
        and sn.status          = 0
/

comment on table DBA_HIST_PROCESS_MEM_SUMMARY is
'Process Memory Historical Summary Information'
/
create or replace public synonym DBA_HIST_PROCESS_MEM_SUMMARY 
   for DBA_HIST_PROCESS_MEM_SUMMARY
/
grant select on DBA_HIST_PROCESS_MEM_SUMMARY to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_RESOURCE_LIMIT
 ***************************************/

create or replace view DBA_HIST_RESOURCE_LIMIT
  (SNAP_ID, DBID, INSTANCE_NUMBER, RESOURCE_NAME, 
   CURRENT_UTILIZATION, MAX_UTILIZATION, INITIAL_ALLOCATION,
   LIMIT_VALUE)
as
select rl.snap_id, rl.dbid, rl.instance_number, resource_name, 
       current_utilization, max_utilization, initial_allocation,
       limit_value
  from wrm$_snapshot sn, WRH$_RESOURCE_LIMIT rl
  where     sn.snap_id         = rl.snap_id
        and sn.dbid            = rl.dbid
        and sn.instance_number = rl.instance_number
        and sn.status          = 0
/

comment on table DBA_HIST_RESOURCE_LIMIT is
'Resource Limit Historical Statistics Information'
/
create or replace public synonym DBA_HIST_RESOURCE_LIMIT 
    for DBA_HIST_RESOURCE_LIMIT
/
grant select on DBA_HIST_RESOURCE_LIMIT to SELECT_CATALOG_ROLE
/


/***************************************
 *    DBA_HIST_SHARED_POOL_ADVICE
 ***************************************/

create or replace view DBA_HIST_SHARED_POOL_ADVICE
  (SNAP_ID, DBID, INSTANCE_NUMBER, SHARED_POOL_SIZE_FOR_ESTIMATE,
   SHARED_POOL_SIZE_FACTOR, ESTD_LC_SIZE, ESTD_LC_MEMORY_OBJECTS,
   ESTD_LC_TIME_SAVED, ESTD_LC_TIME_SAVED_FACTOR, 
   ESTD_LC_LOAD_TIME, ESTD_LC_LOAD_TIME_FACTOR, 
   ESTD_LC_MEMORY_OBJECT_HITS) 
as
select sp.snap_id, sp.dbid, sp.instance_number, 
       shared_pool_size_for_estimate,
       shared_pool_size_factor, estd_lc_size, estd_lc_memory_objects,
       estd_lc_time_saved, estd_lc_time_saved_factor, 
       estd_lc_load_time, estd_lc_load_time_factor, 
       estd_lc_memory_object_hits
  from wrm$_snapshot sn, WRH$_SHARED_POOL_ADVICE sp
  where     sn.snap_id         = sp.snap_id
        and sn.dbid            = sp.dbid
        and sn.instance_number = sp.instance_number
        and sn.status          = 0
/

comment on table DBA_HIST_SHARED_POOL_ADVICE is
'Shared Pool Advice History'
/
create or replace public synonym DBA_HIST_SHARED_POOL_ADVICE 
    for DBA_HIST_SHARED_POOL_ADVICE
/
grant select on DBA_HIST_SHARED_POOL_ADVICE to SELECT_CATALOG_ROLE
/

/***************************************
 *    DBA_HIST_STREAMS_POOL_ADVICE
 ***************************************/

create or replace view DBA_HIST_STREAMS_POOL_ADVICE
  (SNAP_ID, DBID, INSTANCE_NUMBER, SIZE_FOR_ESTIMATE,
   SIZE_FACTOR, ESTD_SPILL_COUNT, ESTD_SPILL_TIME,
   ESTD_UNSPILL_COUNT, ESTD_UNSPILL_TIME) 
as
select sp.snap_id, sp.dbid, sp.instance_number, 
       size_for_estimate, size_factor, 
       estd_spill_count, estd_spill_time, 
       estd_unspill_count, estd_unspill_time     
  from wrm$_snapshot sn, WRH$_STREAMS_POOL_ADVICE sp
  where     sn.snap_id         = sp.snap_id
        and sn.dbid            = sp.dbid
        and sn.instance_number = sp.instance_number
        and sn.status          = 0
/

comment on table DBA_HIST_STREAMS_POOL_ADVICE is
'Streams Pool Advice History'
/
create or replace public synonym DBA_HIST_STREAMS_POOL_ADVICE 
    for DBA_HIST_STREAMS_POOL_ADVICE
/
grant select on DBA_HIST_STREAMS_POOL_ADVICE to SELECT_CATALOG_ROLE
/


/***************************************
 *     DBA_HIST_SQL_WORKAREA_HSTGRM
 ***************************************/

create or replace view DBA_HIST_SQL_WORKAREA_HSTGRM
  (SNAP_ID, DBID, INSTANCE_NUMBER, LOW_OPTIMAL_SIZE, 
   HIGH_OPTIMAL_SIZE, OPTIMAL_EXECUTIONS, ONEPASS_EXECUTIONS,
   MULTIPASSES_EXECUTIONS, TOTAL_EXECUTIONS) 
as
select swh.snap_id, swh.dbid, swh.instance_number, low_optimal_size, 
       high_optimal_size, optimal_executions, onepass_executions,
       multipasses_executions, total_executions
  from wrm$_snapshot sn, WRH$_SQL_WORKAREA_HISTOGRAM swh
  where     sn.snap_id         = swh.snap_id
        and sn.dbid            = swh.dbid
        and sn.instance_number = swh.instance_number
        and sn.status          = 0
/

comment on table DBA_HIST_SQL_WORKAREA_HSTGRM is
'SQL Workarea Histogram History'
/
create or replace public synonym DBA_HIST_SQL_WORKAREA_HSTGRM 
    for DBA_HIST_SQL_WORKAREA_HSTGRM
/
grant select on DBA_HIST_SQL_WORKAREA_HSTGRM to SELECT_CATALOG_ROLE
/


/***************************************
 *     DBA_HIST_PGA_TARGET_ADVICE
 ***************************************/

create or replace view DBA_HIST_PGA_TARGET_ADVICE
  (SNAP_ID, DBID, INSTANCE_NUMBER, PGA_TARGET_FOR_ESTIMATE,
   PGA_TARGET_FACTOR, ADVICE_STATUS, BYTES_PROCESSED,
   ESTD_EXTRA_BYTES_RW, ESTD_PGA_CACHE_HIT_PERCENTAGE,
   ESTD_OVERALLOC_COUNT)
as
select pga.snap_id, pga.dbid, pga.instance_number, 
       pga_target_for_estimate,
       pga_target_factor, advice_status, bytes_processed,
       estd_extra_bytes_rw, estd_pga_cache_hit_percentage,
       estd_overalloc_count
  from wrm$_snapshot sn, WRH$_PGA_TARGET_ADVICE pga
  where     sn.snap_id         = pga.snap_id
        and sn.dbid            = pga.dbid
        and sn.instance_number = pga.instance_number
        and sn.status          = 0
/

comment on table DBA_HIST_PGA_TARGET_ADVICE is
'PGA Target Advice History'
/
create or replace public synonym DBA_HIST_PGA_TARGET_ADVICE
    for DBA_HIST_PGA_TARGET_ADVICE
/
grant select on DBA_HIST_PGA_TARGET_ADVICE to SELECT_CATALOG_ROLE
/

/***************************************
 *     DBA_HIST_SGA_TARGET_ADVICE
 ***************************************/

create or replace view DBA_HIST_SGA_TARGET_ADVICE
  (SNAP_ID, DBID, INSTANCE_NUMBER, SGA_SIZE, SGA_SIZE_FACTOR,
   ESTD_DB_TIME, ESTD_PHYSICAL_READS)
as
select sga.snap_id, sga.dbid, sga.instance_number, 
       sga.sga_size, sga.sga_size_factor, sga.estd_db_time,   
       sga.estd_physical_reads
  from wrm$_snapshot sn, WRH$_SGA_TARGET_ADVICE sga
  where     sn.snap_id         = sga.snap_id
        and sn.dbid            = sga.dbid
        and sn.instance_number = sga.instance_number
        and sn.status          = 0
/

comment on table DBA_HIST_SGA_TARGET_ADVICE is
'SGA Target Advice History'
/
create or replace public synonym DBA_HIST_SGA_TARGET_ADVICE
    for DBA_HIST_SGA_TARGET_ADVICE
/
grant select on DBA_HIST_SGA_TARGET_ADVICE to SELECT_CATALOG_ROLE
/


/***************************************
 *    DBA_HIST_INSTANCE_RECOVERY
 ***************************************/

create or replace view DBA_HIST_INSTANCE_RECOVERY
  (SNAP_ID, DBID, INSTANCE_NUMBER, RECOVERY_ESTIMATED_IOS,
   ACTUAL_REDO_BLKS, TARGET_REDO_BLKS, LOG_FILE_SIZE_REDO_BLKS,
   LOG_CHKPT_TIMEOUT_REDO_BLKS, LOG_CHKPT_INTERVAL_REDO_BLKS,
   FAST_START_IO_TARGET_REDO_BLKS, TARGET_MTTR, ESTIMATED_MTTR,
   CKPT_BLOCK_WRITES, OPTIMAL_LOGFILE_SIZE, ESTD_CLUSTER_AVAILABLE_TIME,
   WRITES_MTTR, WRITES_LOGFILE_SIZE, WRITES_LOG_CHECKPOINT_SETTINGS,
   WRITES_OTHER_SETTINGS, WRITES_AUTOTUNE, WRITES_FULL_THREAD_CKPT)
as
select ir.snap_id, ir.dbid, ir.instance_number, recovery_estimated_ios,
       actual_redo_blks, target_redo_blks, log_file_size_redo_blks,
       log_chkpt_timeout_redo_blks, log_chkpt_interval_redo_blks,
       fast_start_io_target_redo_blks, target_mttr, estimated_mttr,
       ckpt_block_writes, optimal_logfile_size, estd_cluster_available_time,
       writes_mttr, writes_logfile_size, writes_log_checkpoint_settings,
       writes_other_settings, writes_autotune, writes_full_thread_ckpt
  from wrm$_snapshot sn, WRH$_INSTANCE_RECOVERY ir
  where     sn.snap_id         = ir.snap_id
        and sn.dbid            = ir.dbid
        and sn.instance_number = ir.instance_number
        and sn.status          = 0
/

comment on table DBA_HIST_INSTANCE_RECOVERY is
'Instance Recovery Historical Statistics Information'
/
create or replace public synonym DBA_HIST_INSTANCE_RECOVERY 
    for DBA_HIST_INSTANCE_RECOVERY
/
grant select on DBA_HIST_INSTANCE_RECOVERY to SELECT_CATALOG_ROLE
/


/***************************************
 *    DBA_HIST_JAVA_POOL_ADVICE
 ***************************************/

create or replace view DBA_HIST_JAVA_POOL_ADVICE
  (SNAP_ID, DBID, INSTANCE_NUMBER, 
   JAVA_POOL_SIZE_FOR_ESTIMATE, JAVA_POOL_SIZE_FACTOR, 
   ESTD_LC_SIZE, ESTD_LC_MEMORY_OBJECTS, 
   ESTD_LC_TIME_SAVED, ESTD_LC_TIME_SAVED_FACTOR,
   ESTD_LC_LOAD_TIME, ESTD_LC_LOAD_TIME_FACTOR, 
   ESTD_LC_MEMORY_OBJECT_HITS)
as
select jp.snap_id, jp.dbid, jp.instance_number, 
       java_pool_size_for_estimate, java_pool_size_factor, 
       estd_lc_size, estd_lc_memory_objects, 
       estd_lc_time_saved, estd_lc_time_saved_factor,
       estd_lc_load_time, estd_lc_load_time_factor, 
       estd_lc_memory_object_hits
  from wrm$_snapshot sn, WRH$_JAVA_POOL_ADVICE jp
  where     sn.snap_id         = jp.snap_id
        and sn.dbid            = jp.dbid
        and sn.instance_number = jp.instance_number
        and sn.status          = 0
/

comment on table DBA_HIST_JAVA_POOL_ADVICE is
'Java Pool Advice History'
/
create or replace public synonym DBA_HIST_JAVA_POOL_ADVICE 
    for DBA_HIST_JAVA_POOL_ADVICE
/
grant select on DBA_HIST_JAVA_POOL_ADVICE to SELECT_CATALOG_ROLE
/


/***************************************
 *    DBA_HIST_THREAD
 ***************************************/

create or replace view DBA_HIST_THREAD
  (SNAP_ID, DBID, INSTANCE_NUMBER, 
   THREAD#, THREAD_INSTANCE_NUMBER, STATUS,
   OPEN_TIME, CURRENT_GROUP#, SEQUENCE#)
as
select th.snap_id, th.dbid, th.instance_number, 
       thread#, thread_instance_number, th.status,
       open_time, current_group#, sequence#
  from wrm$_snapshot sn, WRH$_THREAD th
  where     sn.snap_id         = th.snap_id
        and sn.dbid            = th.dbid
        and sn.instance_number = th.instance_number
        and sn.status          = 0
/

comment on table DBA_HIST_THREAD is
'Thread Historical Statistics Information'
/
create or replace public synonym DBA_HIST_THREAD 
    for DBA_HIST_THREAD
/
grant select on DBA_HIST_THREAD to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_STAT_NAME
 ***************************************/

create or replace view DBA_HIST_STAT_NAME
  (DBID, STAT_ID, STAT_NAME)
as
select dbid, stat_id, stat_name
from WRH$_STAT_NAME
/

comment on table DBA_HIST_STAT_NAME is
'Statistic Names'
/
create or replace public synonym DBA_HIST_STAT_NAME for DBA_HIST_STAT_NAME
/
grant select on DBA_HIST_STAT_NAME to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_SYSSTAT
 ***************************************/

create or replace view DBA_HIST_SYSSTAT
  (SNAP_ID, DBID, INSTANCE_NUMBER, 
   STAT_ID, STAT_NAME, VALUE) 
as
select s.snap_id, s.dbid, s.instance_number, 
       s.stat_id, nm.stat_name, value
from WRM$_SNAPSHOT sn, WRH$_SYSSTAT s, DBA_HIST_STAT_NAME nm
where      s.stat_id          = nm.stat_id
      and  s.dbid             = nm.dbid
      and  s.snap_id          = sn.snap_id
      and  s.dbid             = sn.dbid
      and  s.instance_number  = sn.instance_number
      and  sn.status          = 0
      and  sn.bl_moved        = 0
union all
select s.snap_id, s.dbid, s.instance_number, 
       s.stat_id, nm.stat_name, value
from WRM$_SNAPSHOT sn, WRH$_SYSSTAT_BL s, DBA_HIST_STAT_NAME nm
where      s.stat_id           = nm.stat_id
      and  s.dbid              = nm.dbid
      and  s.snap_id           = sn.snap_id
      and  s.dbid              = sn.dbid
      and  s.instance_number   = sn.instance_number
      and  sn.status           = 0
      and  sn.bl_moved         = 1
/

comment on table DBA_HIST_SYSSTAT is
'System Historical Statistics Information'
/
create or replace public synonym DBA_HIST_SYSSTAT for DBA_HIST_SYSSTAT
/
grant select on DBA_HIST_SYSSTAT to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_SYS_TIME_MODEL
 ***************************************/

create or replace view DBA_HIST_SYS_TIME_MODEL
  (SNAP_ID, DBID, INSTANCE_NUMBER, STAT_ID, STAT_NAME, VALUE) 
as
select s.snap_id, s.dbid, s.instance_number, s.stat_id, 
       nm.stat_name, value
from WRM$_SNAPSHOT sn, WRH$_SYS_TIME_MODEL s, DBA_HIST_STAT_NAME nm
where      s.stat_id          = nm.stat_id
      and  s.dbid             = nm.dbid
      and  s.snap_id          = sn.snap_id
      and  s.dbid             = sn.dbid
      and  s.instance_number  = sn.instance_number
      and  sn.status          = 0
      and  sn.bl_moved        = 0
union all
select s.snap_id, s.dbid, s.instance_number, s.stat_id,
       nm.stat_name, value
from WRM$_SNAPSHOT sn, WRH$_SYS_TIME_MODEL_BL s, DBA_HIST_STAT_NAME nm
where      s.stat_id           = nm.stat_id
      and  s.dbid              = nm.dbid
      and  s.snap_id           = sn.snap_id
      and  s.dbid              = sn.dbid
      and  s.instance_number   = sn.instance_number
      and  sn.status           = 0
      and  sn.bl_moved         = 1
/

comment on table DBA_HIST_SYS_TIME_MODEL is
'System Time Model Historical Statistics Information'
/
create or replace public synonym DBA_HIST_SYS_TIME_MODEL 
   for DBA_HIST_SYS_TIME_MODEL
/
grant select on DBA_HIST_SYS_TIME_MODEL to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_OSSTAT_NAME
 ***************************************/

create or replace view DBA_HIST_OSSTAT_NAME
  (DBID, STAT_ID, STAT_NAME)
as
select dbid, stat_id, stat_name
from WRH$_OSSTAT_NAME
/

comment on table DBA_HIST_OSSTAT_NAME is
'Operating System Statistic Names'
/
create or replace public synonym DBA_HIST_OSSTAT_NAME 
  for DBA_HIST_OSSTAT_NAME
/
grant select on DBA_HIST_OSSTAT_NAME to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_OSSTAT
 ***************************************/

create or replace view DBA_HIST_OSSTAT
  (SNAP_ID, DBID, INSTANCE_NUMBER, STAT_ID, STAT_NAME, VALUE) 
as
select s.snap_id, s.dbid, s.instance_number, s.stat_id, 
       nm.stat_name, value
from WRM$_SNAPSHOT sn, WRH$_OSSTAT s, DBA_HIST_OSSTAT_NAME nm
where     s.stat_id          = nm.stat_id
      and s.dbid             = nm.dbid
      and s.snap_id          = sn.snap_id
      and s.dbid             = sn.dbid
      and s.instance_number  = sn.instance_number
      and sn.status          = 0
      and sn.bl_moved        = 0
union all
select s.snap_id, s.dbid, s.instance_number, s.stat_id, 
       nm.stat_name, value
from WRM$_SNAPSHOT sn, WRH$_OSSTAT_BL s, DBA_HIST_OSSTAT_NAME nm
where     s.stat_id          = nm.stat_id
      and s.dbid             = nm.dbid
      and s.snap_id          = sn.snap_id
      and s.dbid             = sn.dbid
      and s.instance_number  = sn.instance_number
      and sn.status          = 0
      and sn.bl_moved        = 1
/

comment on table DBA_HIST_OSSTAT is
'Operating System Historical Statistics Information'
/
create or replace public synonym DBA_HIST_OSSTAT 
   for DBA_HIST_OSSTAT
/
grant select on DBA_HIST_OSSTAT to SELECT_CATALOG_ROLE
/


/***************************************
 *      DBA_HIST_PARAMETER_NAME
 ***************************************/

create or replace view DBA_HIST_PARAMETER_NAME
  (DBID, PARAMETER_HASH, PARAMETER_NAME)
as
select dbid, parameter_hash, parameter_name
from WRH$_PARAMETER_NAME 
where (translate(parameter_name,'_','#') not like '#%')
/

comment on table DBA_HIST_PARAMETER_NAME is
'Parameter Names'
/
create or replace public synonym DBA_HIST_PARAMETER_NAME 
    for DBA_HIST_PARAMETER_NAME
/
grant select on DBA_HIST_PARAMETER_NAME to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_PARAMETER
 ***************************************/

create or replace view DBA_HIST_PARAMETER
  (SNAP_ID, DBID, INSTANCE_NUMBER, PARAMETER_HASH,
   PARAMETER_NAME, VALUE, ISDEFAULT, ISMODIFIED)
as
select p.snap_id, p.dbid, p.instance_number, 
       p.parameter_hash, pn.parameter_name, 
       value, isdefault, ismodified
from WRM$_SNAPSHOT sn, WRH$_PARAMETER p, WRH$_PARAMETER_NAME pn
where     p.parameter_hash   = pn.parameter_hash
      and p.dbid             = pn.dbid
      and p.snap_id          = sn.snap_id
      and p.dbid             = sn.dbid
      and p.instance_number  = sn.instance_number
      and sn.status          = 0
      and sn.bl_moved        = 0
union all
select p.snap_id, p.dbid, p.instance_number, 
       p.parameter_hash, pn.parameter_name, 
       value, isdefault, ismodified
from WRM$_SNAPSHOT sn, WRH$_PARAMETER_BL p, WRH$_PARAMETER_NAME pn
where     p.parameter_hash   = pn.parameter_hash
      and p.dbid             = pn.dbid
      and p.snap_id          = sn.snap_id
      and p.dbid             = sn.dbid
      and p.instance_number  = sn.instance_number
      and sn.status          = 0
      and sn.bl_moved        = 1
/

comment on table DBA_HIST_PARAMETER is
'Parameter Historical Statistics Information'
/
create or replace public synonym DBA_HIST_PARAMETER 
    for DBA_HIST_PARAMETER
/
grant select on DBA_HIST_PARAMETER to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_UNDOSTAT
 ***************************************/

create or replace view DBA_HIST_UNDOSTAT
  (BEGIN_TIME, END_TIME, DBID, INSTANCE_NUMBER, SNAP_ID, UNDOTSN,
   UNDOBLKS, TXNCOUNT, MAXQUERYLEN, MAXQUERYSQLID,
   MAXCONCURRENCY, UNXPSTEALCNT, UNXPBLKRELCNT, UNXPBLKREUCNT, 
   EXPSTEALCNT, EXPBLKRELCNT, EXPBLKREUCNT, SSOLDERRCNT, 
   NOSPACEERRCNT, ACTIVEBLKS, UNEXPIREDBLKS, EXPIREDBLKS,
   TUNED_UNDORETENTION)
as
select begin_time, end_time, ud.dbid, ud.instance_number, 
       ud.snap_id, undotsn,
       undoblks, txncount, maxquerylen, maxquerysqlid,
       maxconcurrency, unxpstealcnt, unxpblkrelcnt, unxpblkreucnt, 
       expstealcnt, expblkrelcnt, expblkreucnt, ssolderrcnt, 
       nospaceerrcnt, activeblks, unexpiredblks, expiredblks,
       tuned_undoretention
  from wrm$_snapshot sn, WRH$_UNDOSTAT ud
  where     sn.snap_id         = ud.snap_id
        and sn.dbid            = ud.dbid
        and sn.instance_number = ud.instance_number
        and sn.status          = 0
/

comment on table DBA_HIST_UNDOSTAT is
'Undo Historical Statistics Information'
/
create or replace public synonym DBA_HIST_UNDOSTAT 
    for DBA_HIST_UNDOSTAT
/
grant select on DBA_HIST_UNDOSTAT to SELECT_CATALOG_ROLE
/


/*****************************************************************************
 *   DBA_HIST_SEG_STAT
 * 
 * Note: In WRH$_SEG_STAT, we have renamed the GC CR/Current Blocks 
 *       Served columns to GC CR/Current Blocks Received.  For 
 *       compatibility reasons, we will keep the Served columns 
 *       in the DBA_HIST_SEG_STAT view in case any product has a
 *       dependency on the column name.  We will remove this column
 *       after two releases (remove in release 12).
 *
 *       To obsolete the columns, simply remove the following:
 *          GC_CR_BLOCKS_SERVED_TOTAL, GC_CR_BLOCKS_SERVED_DELTA,
 *          GC_CU_BLOCKS_SERVED_TOTAL, GC_CU_BLOCKS_SERVED_DELTA,
 *****************************************************************************/

create or replace view DBA_HIST_SEG_STAT
  (SNAP_ID, DBID, INSTANCE_NUMBER, TS#, OBJ#, DATAOBJ#, 
   LOGICAL_READS_TOTAL, LOGICAL_READS_DELTA,
   BUFFER_BUSY_WAITS_TOTAL, BUFFER_BUSY_WAITS_DELTA,
   DB_BLOCK_CHANGES_TOTAL, DB_BLOCK_CHANGES_DELTA,
   PHYSICAL_READS_TOTAL, PHYSICAL_READS_DELTA, 
   PHYSICAL_WRITES_TOTAL, PHYSICAL_WRITES_DELTA,
   PHYSICAL_READS_DIRECT_TOTAL, PHYSICAL_READS_DIRECT_DELTA,
   PHYSICAL_WRITES_DIRECT_TOTAL, PHYSICAL_WRITES_DIRECT_DELTA,
   ITL_WAITS_TOTAL, ITL_WAITS_DELTA,
   ROW_LOCK_WAITS_TOTAL, ROW_LOCK_WAITS_DELTA, 
   GC_CR_BLOCKS_SERVED_TOTAL, GC_CR_BLOCKS_SERVED_DELTA,
   GC_CU_BLOCKS_SERVED_TOTAL, GC_CU_BLOCKS_SERVED_DELTA,
   GC_BUFFER_BUSY_TOTAL, GC_BUFFER_BUSY_DELTA,
   GC_CR_BLOCKS_RECEIVED_TOTAL, GC_CR_BLOCKS_RECEIVED_DELTA,
   GC_CU_BLOCKS_RECEIVED_TOTAL, GC_CU_BLOCKS_RECEIVED_DELTA,
   SPACE_USED_TOTAL, SPACE_USED_DELTA,
   SPACE_ALLOCATED_TOTAL, SPACE_ALLOCATED_DELTA,
   TABLE_SCANS_TOTAL, TABLE_SCANS_DELTA)
as
select seg.snap_id, seg.dbid, seg.instance_number, ts#, obj#, dataobj#, 
       logical_reads_total, logical_reads_delta,
       buffer_busy_waits_total, buffer_busy_waits_delta,
       db_block_changes_total, db_block_changes_delta,
       physical_reads_total, physical_reads_delta, 
       physical_writes_total, physical_writes_delta,
       physical_reads_direct_total, physical_reads_direct_delta,
       physical_writes_direct_total, physical_writes_direct_delta,
       itl_waits_total, itl_waits_delta,
       row_lock_waits_total, row_lock_waits_delta, 
       gc_cr_blocks_received_total, gc_cr_blocks_received_delta,
       gc_cu_blocks_received_total, gc_cu_blocks_received_delta,
       gc_buffer_busy_total, gc_buffer_busy_delta,
       gc_cr_blocks_received_total, gc_cr_blocks_received_delta,
       gc_cu_blocks_received_total, gc_cu_blocks_received_delta,
       space_used_total, space_used_delta,
       space_allocated_total, space_allocated_delta,
       table_scans_total, table_scans_delta
from WRM$_SNAPSHOT sn, WRH$_SEG_STAT seg
where     seg.snap_id         = sn.snap_id
      and seg.dbid            = sn.dbid
      and seg.instance_number = sn.instance_number
      and sn.status           = 0
      and sn.bl_moved         = 0
union all
select seg.snap_id, seg.dbid, seg.instance_number, ts#, obj#, dataobj#, 
       logical_reads_total, logical_reads_delta,
       buffer_busy_waits_total, buffer_busy_waits_delta,
       db_block_changes_total, db_block_changes_delta,
       physical_reads_total, physical_reads_delta, 
       physical_writes_total, physical_writes_delta,
       physical_reads_direct_total, physical_reads_direct_delta,
       physical_writes_direct_total, physical_writes_direct_delta,
       itl_waits_total, itl_waits_delta,
       row_lock_waits_total, row_lock_waits_delta, 
       gc_cr_blocks_received_total, gc_cr_blocks_received_delta,
       gc_cu_blocks_received_total, gc_cu_blocks_received_delta,
       gc_buffer_busy_total, gc_buffer_busy_delta,
       gc_cr_blocks_received_total, gc_cr_blocks_received_delta,
       gc_cu_blocks_received_total, gc_cu_blocks_received_delta,
       space_used_total, space_used_delta,
       space_allocated_total, space_allocated_delta,
       table_scans_total, table_scans_delta
from WRM$_SNAPSHOT sn, WRH$_SEG_STAT_BL seg
where     seg.snap_id          = sn.snap_id
      and seg.dbid             = sn.dbid
      and seg.instance_number  = sn.instance_number
      and sn.status            = 0
      and sn.bl_moved          = 1
/

comment on table DBA_HIST_SEG_STAT is
' Historical Statistics Information'
/
create or replace public synonym DBA_HIST_SEG_STAT 
    for DBA_HIST_SEG_STAT
/
grant select on DBA_HIST_SEG_STAT to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_SEG_STAT_OBJ
 ***************************************/

create or replace view DBA_HIST_SEG_STAT_OBJ
  (DBID, TS#, OBJ#, DATAOBJ#, OWNER, OBJECT_NAME, 
   SUBOBJECT_NAME, OBJECT_TYPE, TABLESPACE_NAME, PARTITION_TYPE)
as
select dbid, ts#, obj#, dataobj#, owner, object_name, 
       subobject_name, object_type, tablespace_name, partition_type
from WRH$_SEG_STAT_OBJ
/
comment on table DBA_HIST_SEG_STAT_OBJ is
'Segment Names'
/
create or replace public synonym DBA_HIST_SEG_STAT_OBJ 
    for DBA_HIST_SEG_STAT_OBJ
/
grant select on DBA_HIST_SEG_STAT_OBJ to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_METRIC_NAME
 ***************************************/

/* The Metric Id will remain the same across releases */
create or replace view DBA_HIST_METRIC_NAME
  (DBID, GROUP_ID, GROUP_NAME, METRIC_ID, METRIC_NAME, METRIC_UNIT)
as
select dbid, group_id, group_name, metric_id, metric_name, metric_unit
from WRH$_METRIC_NAME
/
comment on table DBA_HIST_METRIC_NAME is
'Segment Names'
/
create or replace public synonym DBA_HIST_METRIC_NAME
    for DBA_HIST_METRIC_NAME
/
grant select on DBA_HIST_METRIC_NAME to SELECT_CATALOG_ROLE
/


/***************************************
 *      DBA_HIST_SYSMETRIC_HISTORY
 ***************************************/

create or replace view DBA_HIST_SYSMETRIC_HISTORY
  (SNAP_ID, DBID, INSTANCE_NUMBER, BEGIN_TIME, END_TIME, INTSIZE,
   GROUP_ID, METRIC_ID, METRIC_NAME, VALUE, METRIC_UNIT)
as
select m.snap_id, m.dbid, m.instance_number, 
       begin_time, end_time, intsize,
       m.group_id, m.metric_id, mn.metric_name, value, mn.metric_unit
from wrm$_snapshot sn, WRH$_SYSMETRIC_HISTORY m, DBA_HIST_METRIC_NAME mn
where       m.group_id       = mn.group_id
      and   m.metric_id      = mn.metric_id
      and   m.dbid           = mn.dbid
      and   sn.snap_id       = m.snap_id
      and sn.dbid            = m.dbid
      and sn.instance_number = m.instance_number
      and sn.status          = 0
/

comment on table DBA_HIST_SYSMETRIC_HISTORY is
'System Metrics History'
/
create or replace public synonym DBA_HIST_SYSMETRIC_HISTORY 
    for DBA_HIST_SYSMETRIC_HISTORY
/
grant select on DBA_HIST_SYSMETRIC_HISTORY to SELECT_CATALOG_ROLE
/


/***************************************
 *      DBA_HIST_SYSMETRIC_SUMMARY
 ***************************************/

create or replace view DBA_HIST_SYSMETRIC_SUMMARY
  (SNAP_ID, DBID, INSTANCE_NUMBER, BEGIN_TIME, END_TIME, INTSIZE,
   GROUP_ID, METRIC_ID, METRIC_NAME, METRIC_UNIT, NUM_INTERVAL, 
   MINVAL, MAXVAL, AVERAGE, STANDARD_DEVIATION)
as
select m.snap_id, m.dbid, m.instance_number, 
       begin_time, end_time, intsize,
       m.group_id, m.metric_id, mn.metric_name, mn.metric_unit, 
       num_interval, minval, maxval, average, standard_deviation
  from wrm$_snapshot sn, WRH$_SYSMETRIC_SUMMARY m, DBA_HIST_METRIC_NAME mn
  where     m.group_id         = mn.group_id
        and m.metric_id        = mn.metric_id
        and m.dbid             = mn.dbid
        and sn.snap_id         = m.snap_id
        and sn.dbid            = m.dbid
        and sn.instance_number = m.instance_number
        and sn.status          = 0
/

comment on table DBA_HIST_SYSMETRIC_SUMMARY is
'System Metrics History'
/
create or replace public synonym DBA_HIST_SYSMETRIC_SUMMARY 
    for DBA_HIST_SYSMETRIC_SUMMARY
/
grant select on DBA_HIST_SYSMETRIC_SUMMARY to SELECT_CATALOG_ROLE
/


/***************************************
 *   DBA_HIST_SESSMETRIC_HISTORY
 ***************************************/

create or replace view DBA_HIST_SESSMETRIC_HISTORY
  (SNAP_ID, DBID, INSTANCE_NUMBER, BEGIN_TIME, END_TIME, SESSID,
   SERIAL#, INTSIZE, GROUP_ID, METRIC_ID, METRIC_NAME, VALUE, METRIC_UNIT)
as
select m.snap_id, m.dbid, m.instance_number, begin_time, end_time, sessid,
       serial#, intsize, m.group_id, m.metric_id, mn.metric_name, 
       value, mn.metric_unit
  from wrm$_snapshot sn, WRH$_SESSMETRIC_HISTORY m, DBA_HIST_METRIC_NAME mn
  where     m.group_id         = mn.group_id
        and m.metric_id        = mn.metric_id
        and m.dbid             = mn.dbid
        and sn.snap_id         = m.snap_id
        and sn.dbid            = m.dbid
        and sn.instance_number = m.instance_number
        and sn.status          = 0
/

comment on table DBA_HIST_SESSMETRIC_HISTORY is
'System Metrics History'
/
create or replace public synonym DBA_HIST_SESSMETRIC_HISTORY 
    for DBA_HIST_SESSMETRIC_HISTORY
/
grant select on DBA_HIST_SESSMETRIC_HISTORY to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_FILEMETRIC_HISTORY
 ***************************************/

create or replace view DBA_HIST_FILEMETRIC_HISTORY
  (SNAP_ID, DBID, INSTANCE_NUMBER, FILEID, CREATIONTIME, BEGIN_TIME,
   END_TIME, INTSIZE, GROUP_ID, AVGREADTIME, AVGWRITETIME, PHYSICALREAD,
   PHYSICALWRITE, PHYBLKREAD, PHYBLKWRITE)
as
select fm.snap_id, fm.dbid, fm.instance_number, 
       fileid, creationtime, begin_time,
       end_time, intsize, group_id, avgreadtime, avgwritetime, 
       physicalread, physicalwrite, phyblkread, phyblkwrite
  from wrm$_snapshot sn, WRH$_FILEMETRIC_HISTORY fm
  where     sn.snap_id         = fm.snap_id
        and sn.dbid            = fm.dbid
        and sn.instance_number = fm.instance_number
        and sn.status          = 0
/

comment on table DBA_HIST_FILEMETRIC_HISTORY is
'File Metrics History'
/
create or replace public synonym DBA_HIST_FILEMETRIC_HISTORY 
    for DBA_HIST_FILEMETRIC_HISTORY
/
grant select on DBA_HIST_FILEMETRIC_HISTORY to SELECT_CATALOG_ROLE
/


/***************************************
 *    DBA_HIST_WAITCLASSMET_HISTORY
 ***************************************/

create or replace view DBA_HIST_WAITCLASSMET_HISTORY
  (SNAP_ID, DBID, INSTANCE_NUMBER, WAIT_CLASS_ID, WAIT_CLASS,
   BEGIN_TIME, END_TIME, INTSIZE, GROUP_ID, AVERAGE_WAITER_COUNT,
   DBTIME_IN_WAIT, TIME_WAITED, WAIT_COUNT)
as
select em.snap_id, em.dbid, em.instance_number, 
       em.wait_class_id, wn.wait_class, begin_time, end_time, intsize, 
       group_id, average_waiter_count, dbtime_in_wait,
       time_waited, wait_count
  from wrm$_snapshot sn, WRH$_WAITCLASSMETRIC_HISTORY em,
       (select wait_class_id, wait_class from wrh$_event_name
        group by wait_class_id, wait_class) wn
  where     em.wait_class_id   = wn.wait_class_id
        and sn.snap_id         = em.snap_id
        and sn.dbid            = em.dbid
        and sn.instance_number = em.instance_number
        and sn.status          = 0
/

comment on table DBA_HIST_WAITCLASSMET_HISTORY is
'Wait Class Metric History'
/
create or replace public synonym DBA_HIST_WAITCLASSMET_HISTORY 
    for DBA_HIST_WAITCLASSMET_HISTORY
/
grant select on DBA_HIST_WAITCLASSMET_HISTORY to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_DLM_MISC
 ***************************************/

create or replace view DBA_HIST_DLM_MISC
  (SNAP_ID, DBID, INSTANCE_NUMBER,
   STATISTIC#, NAME, VALUE)
as
select dlm.snap_id, dlm.dbid, dlm.instance_number,
       statistic#, name, value
  from wrm$_snapshot sn, WRH$_DLM_MISC dlm
  where     sn.snap_id         = dlm.snap_id
        and sn.dbid            = dlm.dbid
        and sn.instance_number = dlm.instance_number
        and sn.status          = 0
        and sn.bl_moved        = 0
union all
select dlm.snap_id, dlm.dbid, dlm.instance_number,
       statistic#, name, value
  from wrm$_snapshot sn, WRH$_DLM_MISC_BL dlm
  where     sn.snap_id         = dlm.snap_id
        and sn.dbid            = dlm.dbid
        and sn.instance_number = dlm.instance_number
        and sn.status          = 0
        and sn.bl_moved        = 1
/

comment on table DBA_HIST_DLM_MISC is
'Distributed Lock Manager Miscellaneous Historical Statistics Information'
/
create or replace public synonym DBA_HIST_DLM_MISC 
    for DBA_HIST_DLM_MISC
/
grant select on DBA_HIST_DLM_MISC to SELECT_CATALOG_ROLE
/


/***************************************
 *    DBA_HIST_CR_BLOCK_SERVER
 ***************************************/

create or replace view DBA_HIST_CR_BLOCK_SERVER
(SNAP_ID, DBID, INSTANCE_NUMBER,
 CR_REQUESTS, CURRENT_REQUESTS, 
 DATA_REQUESTS, UNDO_REQUESTS, TX_REQUESTS, 
 CURRENT_RESULTS, PRIVATE_RESULTS, ZERO_RESULTS,
 DISK_READ_RESULTS, FAIL_RESULTS,
 FAIRNESS_DOWN_CONVERTS, FAIRNESS_CLEARS, FREE_GC_ELEMENTS,
 FLUSHES, FLUSHES_QUEUED, FLUSH_QUEUE_FULL, FLUSH_MAX_TIME,
 LIGHT_WORKS, ERRORS)
as
select crb.snap_id, crb.dbid, crb.instance_number,
       cr_requests, current_requests, 
       data_requests, undo_requests, tx_requests, 
       current_results, private_results, zero_results,
       disk_read_results, fail_results,
       fairness_down_converts, fairness_clears, free_gc_elements,
       flushes, flushes_queued, flush_queue_full, flush_max_time,
       light_works, errors
  from wrm$_snapshot sn, WRH$_CR_BLOCK_SERVER crb
  where     sn.snap_id         = crb.snap_id
        and sn.dbid            = crb.dbid
        and sn.instance_number = crb.instance_number
        and sn.status          = 0
/
comment on table DBA_HIST_CR_BLOCK_SERVER is
'Consistent Read Block Server Historical Statistics'
/
create or replace public synonym DBA_HIST_CR_BLOCK_SERVER 
    for DBA_HIST_CR_BLOCK_SERVER
/
grant select on DBA_HIST_CR_BLOCK_SERVER to SELECT_CATALOG_ROLE
/


/***************************************
 *    DBA_HIST_CURRENT_BLOCK_SERVER
 ***************************************/

create or replace view DBA_HIST_CURRENT_BLOCK_SERVER
(SNAP_ID, DBID, INSTANCE_NUMBER,
 PIN1,   PIN10,   PIN100,   PIN1000,   PIN10000,
 FLUSH1, FLUSH10, FLUSH100, FLUSH1000, FLUSH10000,
 WRITE1, WRITE10, WRITE100, WRITE1000, WRITE10000)
as
select cub.snap_id, cub.dbid, cub.instance_number,
       pin1,   pin10,   pin100,   pin1000,   pin10000,
       flush1, flush10, flush100, flush1000, flush10000,
       write1, write10, write100, write1000, write10000
  from wrm$_snapshot sn, WRH$_CURRENT_BLOCK_SERVER cub
  where     sn.snap_id         = cub.snap_id
        and sn.dbid            = cub.dbid
        and sn.instance_number = cub.instance_number
        and sn.status          = 0
/
comment on table DBA_HIST_CURRENT_BLOCK_SERVER is
'Current Block Server Historical Statistics'
/
create or replace public synonym DBA_HIST_CURRENT_BLOCK_SERVER 
    for DBA_HIST_CURRENT_BLOCK_SERVER
/
grant select on DBA_HIST_CURRENT_BLOCK_SERVER to SELECT_CATALOG_ROLE
/


/***************************************
 *    DBA_HIST_INST_CACHE_TRANSFER
 ***************************************/

create or replace view DBA_HIST_INST_CACHE_TRANSFER
(SNAP_ID, DBID, INSTANCE_NUMBER, 
 INSTANCE, CLASS, CR_BLOCK, CR_BUSY, CR_CONGESTED, 
 CURRENT_BLOCK, CURRENT_BUSY, CURRENT_CONGESTED)
as
select ict.snap_id, ict.dbid, ict.instance_number, 
       instance, class, cr_block, cr_busy, cr_congested, 
       current_block, current_busy, current_congested
  from wrm$_snapshot sn, WRH$_INST_CACHE_TRANSFER ict
  where     sn.snap_id         = ict.snap_id
        and sn.dbid            = ict.dbid
        and sn.instance_number = ict.instance_number
        and sn.status          = 0
        and sn.bl_moved        = 0
union all
select ict.snap_id, ict.dbid, ict.instance_number, 
       instance, class, cr_block, cr_busy, cr_congested, 
       current_block, current_busy, current_congested
  from wrm$_snapshot sn, WRH$_INST_CACHE_TRANSFER_BL ict
  where     sn.snap_id         = ict.snap_id
        and sn.dbid            = ict.dbid
        and sn.instance_number = ict.instance_number
        and sn.status          = 0
        and sn.bl_moved        = 1
/
comment on table DBA_HIST_INST_CACHE_TRANSFER is
'Instance Cache Transfer Historical Statistics'
/
create or replace public synonym DBA_HIST_INST_CACHE_TRANSFER 
    for DBA_HIST_INST_CACHE_TRANSFER
/
grant select on DBA_HIST_INST_CACHE_TRANSFER to SELECT_CATALOG_ROLE
/


/***************************************
 *    DBA_HIST_ACTIVE_SESS_HISTORY
 ***************************************/

create or replace view DBA_HIST_ACTIVE_SESS_HISTORY
  (SNAP_ID, DBID, INSTANCE_NUMBER, 
   SAMPLE_ID, SAMPLE_TIME,
   SESSION_ID, SESSION_SERIAL#, USER_ID,
   SQL_ID, SQL_CHILD_NUMBER, 
   SQL_PLAN_HASH_VALUE, FORCE_MATCHING_SIGNATURE, SQL_OPCODE,
   SERVICE_HASH, 
   SESSION_TYPE, 
   SESSION_STATE,
   QC_SESSION_ID, QC_INSTANCE_ID, 
   BLOCKING_SESSION,
   BLOCKING_SESSION_STATUS,
   BLOCKING_SESSION_SERIAL#,
   EVENT, 
   EVENT_ID, 
   SEQ#, 
   P1TEXT, P1, 
   P2TEXT, P2, 
   P3TEXT, P3, 
   WAIT_CLASS, WAIT_CLASS_ID,
   WAIT_TIME, TIME_WAITED,
   XID,
   CURRENT_OBJ#, CURRENT_FILE#, CURRENT_BLOCK#,
   PROGRAM, MODULE, ACTION, CLIENT_ID)
as
select ash.snap_id, ash.dbid, ash.instance_number, 
       ash.sample_id, ash.sample_time,
       ash.session_id, ash.session_serial#, ash.user_id, 
       ash.sql_id, ash.sql_child_number, 
       ash.sql_plan_hash_value, ash.force_matching_signature, ash.sql_opcode,
       ash.service_hash, 
       decode(ash.session_type, 1, 'FOREGROUND', 2, 'BACKGROUND', 'UNKNOWN'),
       decode(ash.wait_time, 0, 'WAITING', 'ON CPU'),
       decode(ash.qc_session_id, 0, to_number(NULL), ash.qc_session_id),
       decode(ash.qc_session_id, 0, to_number(NULL), ash.qc_instance_id),
       (case when ash.blocking_session between 4294967291 and 4294967295
               then to_number(NULL)
             else ash.blocking_session
        end),
       (case when ash.blocking_session = 4294967295
               then 'UNKNOWN'
             when ash.blocking_session = 4294967294
               then 'GLOBAL'
             when ash.blocking_session = 4294967293
               then 'UNKNOWN'
             when ash.blocking_session = 4294967292
               then 'NO HOLDER'
             when ash.blocking_session = 4294967291
               then 'NOT IN WAIT'
             else 'VALID'
        end),
       (case when ash.blocking_session between 4294967291 and 4294967295
               then to_number(NULL)
             else ash.blocking_session_serial#
        end),
       decode(ash.wait_time, 0, evt.event_name, NULL),
       decode(ash.wait_time, 0, evt.event_id,   NULL),
       ash.seq#, 
       evt.parameter1, ash.p1, 
       evt.parameter2, ash.p2, 
       evt.parameter3, ash.p3, 
       decode(ash.wait_time, 0, evt.wait_class,    NULL),
       decode(ash.wait_time, 0, evt.wait_class_id, NULL),
       ash.wait_time, ash.time_waited,
       ash.xid,
       ash.current_obj#, ash.current_file#, ash.current_block#,
       ash.program, ash.module, ash.action, ash.client_id
from WRM$_SNAPSHOT sn, WRH$_ACTIVE_SESSION_HISTORY ash, WRH$_EVENT_NAME evt
where      ash.snap_id          = sn.snap_id
      and  ash.dbid             = sn.dbid
      and  ash.instance_number  = sn.instance_number
      and  sn.status            = 0
      and  sn.bl_moved          = 0
      and  ash.dbid             = evt.dbid
      and  ash.event_id         = evt.event_id
union all
select ash.snap_id, ash.dbid, ash.instance_number, 
       ash.sample_id, ash.sample_time,
       ash.session_id, ash.session_serial#, ash.user_id, 
       ash.sql_id, ash.sql_child_number, 
       ash.sql_plan_hash_value, ash.force_matching_signature, ash.sql_opcode,
       ash.service_hash, 
       decode(ash.session_type, 1, 'FOREGROUND', 2, 'BACKGROUND', 'UNKNOWN'),
       decode(ash.wait_time, 0, 'WAITING', 'ON CPU'),
       decode(ash.qc_session_id, 0, to_number(NULL), ash.qc_session_id),
       decode(ash.qc_session_id, 0, to_number(NULL), ash.qc_instance_id),
       (case when ash.blocking_session between 4294967291 and 4294967295
               then to_number(NULL)
             else ash.blocking_session
        end),
       (case when ash.blocking_session = 4294967295
               then 'UNKNOWN'
             when ash.blocking_session = 4294967294
               then 'GLOBAL'
             when ash.blocking_session = 4294967293
               then 'UNKNOWN'
             when ash.blocking_session = 4294967292
               then 'NO HOLDER'
             when ash.blocking_session = 4294967291
               then 'NOT IN WAIT'
             else 'VALID'
        end),
       (case when ash.blocking_session between 4294967291 and 4294967295
               then to_number(NULL)
             else ash.blocking_session_serial#
        end),
       decode(ash.wait_time, 0, evt.event_name, NULL),
       decode(ash.wait_time, 0, evt.event_id,   NULL),
       ash.seq#,
       evt.parameter1, ash.p1,
       evt.parameter2, ash.p2,
       evt.parameter3, ash.p3,
       decode(ash.wait_time, 0, evt.wait_class,    NULL),
       decode(ash.wait_time, 0, evt.wait_class_id, NULL),
       ash.wait_time, ash.time_waited, 
       ash.xid,
       ash.current_obj#, ash.current_file#, ash.current_block#,
       ash.program, ash.module, ash.action, ash.client_id
from WRM$_SNAPSHOT sn, WRH$_ACTIVE_SESSION_HISTORY_BL ash, WRH$_EVENT_NAME evt
where      ash.snap_id          = sn.snap_id
      and  ash.dbid             = sn.dbid
      and  ash.instance_number  = sn.instance_number
      and  sn.status            = 0
      and  sn.bl_moved          = 1
      and  ash.dbid             = evt.dbid
      and  ash.event_id         = evt.event_id
/

comment on table DBA_HIST_ACTIVE_SESS_HISTORY is
'Active Session Historical Statistics Information'
/
create or replace public synonym DBA_HIST_ACTIVE_SESS_HISTORY 
    for DBA_HIST_ACTIVE_SESS_HISTORY
/
grant select on DBA_HIST_ACTIVE_SESS_HISTORY to SELECT_CATALOG_ROLE
/


/***************************************
 *      DBA_HIST_TABLESPACE_STAT
 ***************************************/

create or replace view DBA_HIST_TABLESPACE_STAT
  (SNAP_ID, DBID, INSTANCE_NUMBER, TS#, TSNAME, CONTENTS, 
   STATUS, SEGMENT_SPACE_MANAGEMENT, EXTENT_MANAGEMENT,
   IS_BACKUP)
as
select tbs.snap_id, tbs.dbid, tbs.instance_number, ts#, tsname, contents, 
       tbs.status, segment_space_management, extent_management,
       is_backup
from WRM$_SNAPSHOT sn, WRH$_TABLESPACE_STAT tbs
where      tbs.snap_id          = sn.snap_id
      and  tbs.dbid             = sn.dbid
      and  tbs.instance_number  = sn.instance_number
      and  sn.status            = 0
      and  sn.bl_moved          = 0
union all
select tbs.snap_id, tbs.dbid, tbs.instance_number, ts#, tsname, contents, 
       tbs.status, segment_space_management, extent_management,
       is_backup
from WRM$_SNAPSHOT sn, WRH$_TABLESPACE_STAT_BL tbs
where      tbs.snap_id          = sn.snap_id
      and  tbs.dbid             = sn.dbid
      and  tbs.instance_number  = sn.instance_number
      and  sn.status            = 0
      and  sn.bl_moved          = 1
/

comment on table DBA_HIST_TABLESPACE_STAT is
'Tablespace Historical Statistics Information'
/
create or replace public synonym DBA_HIST_TABLESPACE_STAT 
    for DBA_HIST_TABLESPACE_STAT
/
grant select on DBA_HIST_TABLESPACE_STAT to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_LOG
 ***************************************/

create or replace view DBA_HIST_LOG
  (SNAP_ID, DBID, INSTANCE_NUMBER, GROUP#, THREAD#, SEQUENCE#,
   BYTES, MEMBERS, ARCHIVED, STATUS, FIRST_CHANGE#, FIRST_TIME)
as
select log.snap_id, log.dbid, log.instance_number, 
       group#, thread#, sequence#, bytes, members, 
       archived, log.status, first_change#, first_time
  from wrm$_snapshot sn, WRH$_LOG log
  where     sn.snap_id         = log.snap_id
        and sn.dbid            = log.dbid
        and sn.instance_number = log.instance_number
        and sn.status          = 0
/

comment on table DBA_HIST_LOG is
'Log Historical Statistics Information'
/
create or replace public synonym DBA_HIST_LOG 
    for DBA_HIST_LOG
/
grant select on DBA_HIST_LOG to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_MTTR_TARGET_ADVICE
 ***************************************/

create or replace view DBA_HIST_MTTR_TARGET_ADVICE
  (SNAP_ID, DBID, INSTANCE_NUMBER, MTTR_TARGET_FOR_ESTIMATE,
   ADVICE_STATUS, DIRTY_LIMIT, 
   ESTD_CACHE_WRITES, ESTD_CACHE_WRITE_FACTOR, 
   ESTD_TOTAL_WRITES, ESTD_TOTAL_WRITE_FACTOR,
   ESTD_TOTAL_IOS, ESTD_TOTAL_IO_FACTOR)
as
select mt.snap_id, mt.dbid, mt.instance_number, mttr_target_for_estimate,
       advice_status, dirty_limit, 
       estd_cache_writes, estd_cache_write_factor, 
       estd_total_writes, estd_total_write_factor,
       estd_total_ios, estd_total_io_factor
  from wrm$_snapshot sn, WRH$_MTTR_TARGET_ADVICE mt
  where     sn.snap_id         = mt.snap_id
        and sn.dbid            = mt.dbid
        and sn.instance_number = mt.instance_number
        and sn.status          = 0
/

comment on table DBA_HIST_MTTR_TARGET_ADVICE is
'Mean-Time-To-Recover Target Advice History'
/
create or replace public synonym DBA_HIST_MTTR_TARGET_ADVICE 
    for DBA_HIST_MTTR_TARGET_ADVICE
/
grant select on DBA_HIST_MTTR_TARGET_ADVICE to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_TBSPC_SPACE_USAGE
 ***************************************/

create or replace view DBA_HIST_TBSPC_SPACE_USAGE
  (SNAP_ID, DBID, TABLESPACE_ID, TABLESPACE_SIZE,
   TABLESPACE_MAXSIZE, TABLESPACE_USEDSIZE, RTIME)
as
select tb.snap_id, tb.dbid, tablespace_id, tablespace_size,
       tablespace_maxsize, tablespace_usedsize, rtime
  from (select distinct snap_id, dbid 
          from WRM$_SNAPSHOT where status = 0) sn, 
       WRH$_TABLESPACE_SPACE_USAGE tb
  where     sn.snap_id         = tb.snap_id
        and sn.dbid            = tb.dbid
/

comment on table DBA_HIST_TBSPC_SPACE_USAGE is
'Tablespace Usage Historical Statistics Information'
/
create or replace public synonym DBA_HIST_TBSPC_SPACE_USAGE 
    for DBA_HIST_TBSPC_SPACE_USAGE
/
grant select on DBA_HIST_TBSPC_SPACE_USAGE to SELECT_CATALOG_ROLE
/


/*********************************
 *     DBA_HIST_SERVICE_NAME
 *********************************/

create or replace view DBA_HIST_SERVICE_NAME
  (DBID, SERVICE_NAME_HASH, SERVICE_NAME)
as
select dbid, service_name_hash, service_name
  from WRH$_SERVICE_NAME sn
/
comment on table DBA_HIST_SERVICE_NAME is
'Service Names'
/
create or replace public synonym DBA_HIST_SERVICE_NAME 
    for DBA_HIST_SERVICE_NAME
/
grant select on DBA_HIST_SERVICE_NAME to SELECT_CATALOG_ROLE
/


/*********************************
 *     DBA_HIST_SERVICE_STAT
 *********************************/

create or replace view DBA_HIST_SERVICE_STAT
  (SNAP_ID, DBID, INSTANCE_NUMBER,
   SERVICE_NAME_HASH, SERVICE_NAME,
   STAT_ID, STAT_NAME, VALUE)
as
select st.snap_id, st.dbid, st.instance_number,
       st.service_name_hash, sv.service_name, 
       nm.stat_id, nm.stat_name, value
  from WRM$_SNAPSHOT sn, WRH$_SERVICE_STAT st, 
       WRH$_SERVICE_NAME sv, WRH$_STAT_NAME nm
  where    st.service_name_hash = sv.service_name_hash
      and  st.dbid              = sv.dbid
      and  st.stat_id           = nm.stat_id
      and  st.dbid              = nm.dbid
      and  st.snap_id           = sn.snap_id
      and  st.dbid              = sn.dbid
      and  st.instance_number   = sn.instance_number
      and  sn.status            = 0
      and  sn.bl_moved          = 0
union all
select st.snap_id, st.dbid, st.instance_number,
       st.service_name_hash, sv.service_name, 
       nm.stat_id, nm.stat_name, value
  from WRM$_SNAPSHOT sn, WRH$_SERVICE_STAT_BL st, 
       WRH$_SERVICE_NAME sv, WRH$_STAT_NAME nm
  where    st.service_name_hash = sv.service_name_hash
      and  st.dbid              = sv.dbid
      and  st.stat_id           = nm.stat_id
      and  st.dbid              = nm.dbid
      and  st.snap_id           = sn.snap_id
      and  st.dbid              = sn.dbid
      and  st.instance_number   = sn.instance_number
      and  sn.status            = 0
      and  sn.bl_moved          = 1
/
comment on table DBA_HIST_SERVICE_STAT is
'Historical Service Statistics'
/
create or replace public synonym DBA_HIST_SERVICE_STAT 
    for DBA_HIST_SERVICE_STAT
/
grant select on DBA_HIST_SERVICE_STAT to SELECT_CATALOG_ROLE
/


/***********************************
 *   DBA_HIST_SERVICE_WAIT_CLASS
 ***********************************/

create or replace view DBA_HIST_SERVICE_WAIT_CLASS
  (SNAP_ID, DBID, INSTANCE_NUMBER,
   SERVICE_NAME_HASH, SERVICE_NAME, 
   WAIT_CLASS_ID, WAIT_CLASS, TOTAL_WAITS, TIME_WAITED)
as
select st.snap_id, st.dbid, st.instance_number,
       st.service_name_hash, nm.service_name, 
       wait_class_id, wait_class, total_waits, time_waited 
  from WRM$_SNAPSHOT sn, WRH$_SERVICE_WAIT_CLASS st, 
       WRH$_SERVICE_NAME nm
  where    st.service_name_hash = nm.service_name_hash
      and  st.dbid              = nm.dbid
      and  st.snap_id           = sn.snap_id
      and  st.dbid              = sn.dbid
      and  st.instance_number   = sn.instance_number
      and  sn.status            = 0
      and  sn.bl_moved          = 0
union all
select st.snap_id, st.dbid, st.instance_number,
       st.service_name_hash, nm.service_name, 
       wait_class_id, wait_class, total_waits, time_waited 
  from WRM$_SNAPSHOT sn, WRH$_SERVICE_WAIT_CLASS_BL st, 
       WRH$_SERVICE_NAME nm
  where    st.service_name_hash = nm.service_name_hash
      and  st.dbid              = nm.dbid
      and  st.snap_id           = sn.snap_id
      and  st.dbid              = sn.dbid
      and  st.instance_number   = sn.instance_number
      and  sn.status            = 0
      and  sn.bl_moved          = 1
/
comment on table DBA_HIST_SERVICE_WAIT_CLASS is
'Historical Service Wait Class Statistics'
/
create or replace public synonym DBA_HIST_SERVICE_WAIT_CLASS 
    for DBA_HIST_SERVICE_WAIT_CLASS
/
grant select on DBA_HIST_SERVICE_WAIT_CLASS to SELECT_CATALOG_ROLE
/


/***********************************
 *   DBA_HIST_SESS_TIME_STATS
 ***********************************/

create or replace view DBA_HIST_SESS_TIME_STATS
  (SNAP_ID, DBID, INSTANCE_NUMBER, SESSION_TYPE, MIN_LOGON_TIME,
   SUM_CPU_TIME, SUM_SYS_IO_WAIT, SUM_USER_IO_WAIT)
as
select st.snap_id, st.dbid, st.instance_number, st.session_type,
       st.min_logon_time, st.sum_cpu_time, st.sum_sys_io_wait,
       st.sum_user_io_wait
  from WRM$_SNAPSHOT sn, WRH$_SESS_TIME_STATS st
  where    st.snap_id           = sn.snap_id
      and  st.dbid              = sn.dbid
      and  st.instance_number   = sn.instance_number
      and  sn.status            = 0
/
comment on table DBA_HIST_SESS_TIME_STATS is
'CPU and I/O time for interesting (STREAMS) sessions'
/
create or replace public synonym DBA_HIST_SESS_TIME_STATS
    for DBA_HIST_SESS_TIME_STATS
/
grant select on DBA_HIST_SESS_TIME_STATS to SELECT_CATALOG_ROLE
/

/***************************************
 *        DBA_HIST_STREAMS_CAPTURE
 ***************************************/

create or replace view DBA_HIST_STREAMS_CAPTURE
  (SNAP_ID, DBID, INSTANCE_NUMBER, CAPTURE_NAME, STARTUP_TIME, LAG,
   TOTAL_MESSAGES_CAPTURED, TOTAL_MESSAGES_ENQUEUED,
   ELAPSED_RULE_TIME, ELAPSED_ENQUEUE_TIME,
   ELAPSED_REDO_WAIT_TIME, ELAPSED_PAUSE_TIME)
as
select cs.snap_id, cs.dbid, cs.instance_number, cs.capture_name, 
       cs.startup_time, cs.lag,
       cs.total_messages_captured, cs.total_messages_enqueued,
       cs.elapsed_rule_time, cs.elapsed_enqueue_time,
       cs.elapsed_redo_wait_time, cs.elapsed_pause_time
  from wrh$_streams_capture cs, wrm$_snapshot sn
  where     sn.snap_id          = cs.snap_id
        and sn.dbid             = cs.dbid
        and sn.instance_number  = cs.instance_number
        and sn.status           = 0
/

comment on table DBA_HIST_STREAMS_CAPTURE is
'STREAMS Capture Historical Statistics Information'
/
create or replace public synonym DBA_HIST_STREAMS_CAPTURE
    for DBA_HIST_STREAMS_CAPTURE
/
grant select on DBA_HIST_STREAMS_CAPTURE to SELECT_CATALOG_ROLE
/

/***********************************************
 *        DBA_HIST_STREAMS_APPLY_SUM
 ***********************************************/

create or replace view DBA_HIST_STREAMS_APPLY_SUM
  (SNAP_ID, DBID, INSTANCE_NUMBER, APPLY_NAME, STARTUP_TIME,
   READER_TOTAL_MESSAGES_DEQUEUED, READER_LAG,
   coord_total_received, coord_total_applied, coord_total_rollbacks,
   coord_total_wait_deps, coord_total_wait_cmts, coord_lwm_lag,
   server_total_messages_applied, server_elapsed_dequeue_time,
   server_elapsed_apply_time)
as
select sas.snap_id, sas.dbid, sas.instance_number, sas.apply_name,
       sas.startup_time, sas.reader_total_messages_dequeued, sas.reader_lag,
       sas.coord_total_received, sas.coord_total_applied,
       sas.coord_total_rollbacks, sas.coord_total_wait_deps,
       sas.coord_total_wait_cmts, sas.coord_lwm_lag,
       sas.server_total_messages_applied, sas.server_elapsed_dequeue_time,
       sas.server_elapsed_apply_time
  from wrh$_streams_apply_sum sas, wrm$_snapshot sn
  where     sn.snap_id          = sas.snap_id
        and sn.dbid             = sas.dbid
        and sn.instance_number  = sas.instance_number
        and sn.status           = 0
/

comment on table DBA_HIST_STREAMS_APPLY_SUM is
'STREAMS Apply Historical Statistics Information'
/
create or replace public synonym DBA_HIST_STREAMS_APPLY_SUM
    for DBA_HIST_STREAMS_APPLY_SUM
/
grant select on DBA_HIST_STREAMS_APPLY_SUM to SELECT_CATALOG_ROLE
/

/*****************************************
 *        DBA_HIST_BUFFERED_QUEUES
 *****************************************/

create or replace view DBA_HIST_BUFFERED_QUEUES
  (SNAP_ID, DBID, INSTANCE_NUMBER, QUEUE_SCHEMA, QUEUE_NAME, STARTUP_TIME,
   QUEUE_ID, NUM_MSGS, SPILL_MSGS, CNUM_MSGS, CSPILL_MSGS)
as
select qs.snap_id, qs.dbid, qs.instance_number, qs.queue_schema, qs.queue_name,
       qs.startup_time, qs.queue_id, qs.num_msgs, qs.spill_msgs, qs.cnum_msgs,
       qs.cspill_msgs
  from wrh$_buffered_queues qs, wrm$_snapshot sn
  where     sn.snap_id          = qs.snap_id
        and sn.dbid             = qs.dbid
        and sn.instance_number  = qs.instance_number
        and sn.status           = 0
/

comment on table DBA_HIST_BUFFERED_QUEUES is
'STREAMS Buffered Queues Historical Statistics Information'
/
create or replace public synonym DBA_HIST_BUFFERED_QUEUES
    for DBA_HIST_BUFFERED_QUEUES
/
grant select on DBA_HIST_BUFFERED_QUEUES to SELECT_CATALOG_ROLE
/

/**********************************************
 *        DBA_HIST_BUFFERED_SUBSCRIBERS
 **********************************************/

create or replace view DBA_HIST_BUFFERED_SUBSCRIBERS
  (SNAP_ID, DBID, INSTANCE_NUMBER, QUEUE_SCHEMA, QUEUE_NAME,
   SUBSCRIBER_ID, SUBSCRIBER_NAME,
   SUBSCRIBER_ADDRESS, SUBSCRIBER_TYPE, STARTUP_TIME, NUM_MSGS, CNUM_MSGS,
   TOTAL_SPILLED_MSG)
as
select ss.snap_id, ss.dbid, ss.instance_number,
       ss.queue_schema, ss.queue_name, ss.subscriber_id,
       ss.subscriber_name, ss.subscriber_address,
       ss.subscriber_type, ss.startup_time, ss.num_msgs, ss.cnum_msgs,
       ss.total_spilled_msg
  from wrh$_buffered_subscribers ss, wrm$_snapshot sn
  where     sn.snap_id          = ss.snap_id
        and sn.dbid             = ss.dbid
        and sn.instance_number  = ss.instance_number
        and sn.status           = 0
/

comment on table DBA_HIST_BUFFERED_SUBSCRIBERS is
'STREAMS Buffered Queue Subscribers Historical Statistics Information'
/
create or replace public synonym DBA_HIST_BUFFERED_SUBSCRIBERS
    for DBA_HIST_BUFFERED_SUBSCRIBERS
/
grant select on DBA_HIST_BUFFERED_SUBSCRIBERS to SELECT_CATALOG_ROLE
/

/**********************************************
 *        DBA_HIST_RULE_SET
 **********************************************/

create or replace view DBA_HIST_RULE_SET
  (SNAP_ID, DBID, INSTANCE_NUMBER, OWNER, NAME,
  STARTUP_TIME, CPU_TIME, ELAPSED_TIME, EVALUATIONS, SQL_FREE_EVALUATIONS,
  SQL_EXECUTIONS, RELOADS)
as
select rs.snap_id, rs.dbid, rs.instance_number,
       rs.owner, rs.name, rs.startup_time, rs.cpu_time, rs.elapsed_time,
       rs.evaluations, rs.sql_free_evaluations, rs.sql_executions, rs.reloads
  from wrh$_rule_set rs, wrm$_snapshot sn
  where     sn.snap_id          = rs.snap_id
        and sn.dbid             = rs.dbid
        and sn.instance_number  = rs.instance_number
        and sn.status           = 0
/

comment on table DBA_HIST_RULE_SET is
'Rule sets historical statistics information'
/
create or replace public synonym DBA_HIST_RULE_SET
    for DBA_HIST_RULE_SET
/
grant select on DBA_HIST_RULE_SET to SELECT_CATALOG_ROLE
/
