rem 
rem $Header: catdefer.sql 05-may-2005.16:33:49 lkaplan Exp $ 
rem 
Rem Copyright (c) 1992, 2005, Oracle. All rights reserved.  
Rem    NAME
Rem      catdefer.sql - catalog of deferred rpc queues
Rem    DESCRIPTION
Rem      catalog of deferred rpc queues
Rem      This file contains sql which creates the base tables
Rem      used to store deferred remote procedure calls for used in
Rem      transaction replication.
Rem      Tables:
Rem         defTran
Rem         defTranDest
Rem         defError
Rem         defCallDest
Rem         defDefaultDest
Rem         defCall
Rem         defSchedule
Rem    RETURNS
Rem 
Rem    NOTES
Rem      Tables created in this file are owned by user system (not) sys
Rem      views are owned by sys.
Rem      The defcall view is implemented by the prvtdfri.plb script.
Rem      The defcalldest view is implemented by the catrepc.sql script.
Rem      The deftrandest view is reimplemented by the catrepc.sql script.
Rem      If the repcat tables are installed,
Rem      the catrepc.sql script should always be run after this script is run.
Rem 
Rem      Tables are created in catdefrt.sql.  All other objects created here
Rem 
Rem    MODIFIED   (MM/DD/YY)
Rem     lkaplan    05/05/05  - grant analyze any to allow lock_table_stats
Rem     gviswana   01/29/02  - CREATE OR REPLACE SYNONYM
Rem     gviswana   05/24/01  - CREATE OR REPLACE SYNONYM
Rem     liwong     10/23/00  - Add disabled_internally_set
Rem     narora     10/02/00  - code review comments
Rem     narora     09/29/00  - use decode for txn_count=0 in defschedule
Rem     narora     09/13/00  - add comments to new def$_destination columns
Rem     narora     08/30/00  - enhance defschedule
Rem     elu        09/12/00  - add catchup to defschedule
Rem     liwong     09/03/00  - add master db w/o quiesce: fixes
Rem     narora     07/11/00  - grant priviliges to v$ views
Rem     jingliu    07/29/97 -  change deflob.enq_tid to deferred_tran_id
Rem     jstamos    04/04/97 -  tighter AQ integration
Rem     liwong     03/07/97 -  merge 433785 manually
Rem     liwong     02/10/97 -  Comment out defcalldest, 
Rem                         -  modify deftrandest, add queue_batch to deftran
Rem     liwong     01/15/97 -  Modified delete statement for expact$ and added
Rem                         -  def$_aqcall and def$_aqerror
Rem     jstamos    01/03/97 -  add drop user cascade support
Rem     jstamos    12/23/96 -  comment on nclob_col
Rem     jstamos    11/21/96 -  nchar support
Rem     ato        11/08/96 -  remove catqueue.sql
Rem     sjain      11/06/96 -  Change defcall and deftran for backwards compata
Rem     sjain      11/05/96 -  Fix type in defcall
Rem     mluong     10/28/96 -  remove dup calls to build AQ package
Rem     sjain      10/17/96 -  AQ Conversion
Rem     sjain      10/15/96 -  aq conversion
Rem     sjain      10/14/96 -  Aq conversion
Rem     sjain      10/01/96 -  AQ conversion
Rem     sjain      09/04/96 -  AQ cont.
Rem     sjain      07/25/96 -  continue with the aq conversion
Rem     sjain      07/22/96 -  Convert to AQ
Rem     jstamos    06/12/96 -  LOB support for deferred RPCs
Rem     ldoo       05/09/96 -  New security model
Rem     mmonajje   05/21/96 -  Replace interval col name with interval#
Rem     ixhu       04/11/96 -  AQ support: add obj_type in expact$
Rem     asurpur    04/08/96 -  Dictionary Protection Implementation
Rem     jstamos    08/17/95 -  code review changes
Rem     jstamos    08/16/95 -  add comments to views
Rem     hasun      01/23/95 -  Modify views for Rep3 - Object Groups
Rem     dsdaniel   01/25/95 -  merge changes from branch 1.5.720.4
Rem     dsdaniel   01/23/95 -  merge changes from branch 1.1.710.11
Rem     dsdaniel   01/05/95 -  need extra at sign
Rem     dsdaniel   12/23/94 -  merge changes from branch 1.5.720.1-3
Rem     dsdaniel   12/21/94 -  merge changes from branch 1.1.710.8-10
Rem     dsdaniel   12/08/94 -  revise defcalldest, deftrandest views
Rem     dsdaniel   11/22/94 -  split out table creations
Rem     dsdaniel   11/18/94 -  deftran-ectomy, deftrandest-ectomy
Rem     dsdaniel   11/17/94 -  merge changes from branch 1.1.710.7
Rem     dsdaniel   11/09/94 -  defcalldest, deftrandest changes
Rem     dsdaniel   08/04/94 -  make it a cluster (again)
Rem     dsdaniel   08/04/94 -  create a version without the cluster
Rem     dsdaniel   08/03/94 -  eliminate ON DELETE CASCADE *again
Rem     dsdaniel   08/02/94 -  make it a cluster
Rem     dsdaniel   07/28/94 -  restore ON DELETE CASCADE
Rem     dsdaniel   07/27/94 -  eliminate ON DELETE CASCADE
Rem     dsdaniel   07/19/94 -  export support changes
Rem     rjenkins   03/22/94 -  merge changes from branch 1.1.710.4
Rem     rjenkins   01/19/94 -  merge changes from branch 1.1.710.3
Rem     dsdaniel   01/18/94 -  merge changes from branch 1.1.710.2
Rem     rjenkins   01/17/94 -  changing jq to job
Rem     rjenkins   12/17/93 -  creating job queue
Rem     dsdaniel   10/31/93 -  merge changes from branch 1.1.710.1
Rem     dsdaniel   10/28/93 -  deferred rpc dblink security
Rem                         -  also removed table drops, since shouldnt
Rem                         -  loose data on upgrade
Rem     dsdaniel   10/26/93 -  merge changes from branch 1.1.400.1
Rem     dsdaniel   10/10/93 -  Creation from dbmsdefr
rem create base tables

-- Sys is granted privileges through roles, which don't apply to
-- packages owned by sys.  Explicitly grant permissions.
grant select any table to sys with admin option
/
grant insert any table to sys
/
grant update any table to sys
/
grant delete any table to sys
/
grant analyze any to sys
/
rem drop existing synonyms from sys -system

DROP SYNONYM def$_tran
/
DROP SYNONYM def$_call
/
DROP SYNONYM def$_defaultdest
/

--
--
@@catdefrt  
--
--
-- Create a synonym for the new deferred queue table.
-- Note columns in def$_aqcall are different from the old def$_call
CREATE OR REPLACE SYNONYM def$_aqcall FOR system.def$_aqcall
/
 
CREATE OR REPLACE SYNONYM def$_calldest FOR system.def$_calldest
/
CREATE OR REPLACE SYNONYM def$_schedule FOR system.def$_schedule
/
CREATE OR REPLACE SYNONYM def$_error FOR system.def$_error
/

-- This view is for internal use only and may change without notice.
-- PROPAGATION_WAS_ENABLED is only meaningful if DISABLED_INTERNALLY_SET
-- is 'Y'.
CREATE OR REPLACE VIEW "_DEFSCHEDULE"  AS
  SELECT s.dblink, s.job, j.interval# interval, next_date, 
         j.last_date, s.disabled, s.last_txn_count, s.last_error_number, 
         s.last_error_message, s.catchup,
         s.total_txn_count,
         to_number(decode(s.total_prop_time_throughput, 0, NULL, 
         s.total_txn_count/s.total_prop_time_throughput)) avg_throughput,
         to_number(decode(s.total_txn_count, 0, NULL,
         s.total_prop_time_latency/s.total_txn_count)) avg_latency,
         s.to_communication_size total_bytes_sent,
         s.from_communication_size total_bytes_received,
         s.spare1 total_round_trips,
         s.spare2 total_admin_count,
         s.spare3 total_error_count,
         s.spare4 total_sleep_time,
         DECODE(utl_raw.bit_and(utl_raw.substr(s.flag, 1, 1), '02'),
               '00', 'N', 'Y') disabled_internally_set,
         DECODE(utl_raw.bit_and(utl_raw.substr(s.flag, 1, 1), '01'),
               '00', 'N', 'Y') propagation_was_enabled
    FROM system.def$_destination s, sys.job$ j where s.job = j.job(+)
/

CREATE OR REPLACE VIEW defschedule  AS
  SELECT dblink, job, interval, next_date,
         last_date, disabled, last_txn_count, last_error_number,
         last_error_message, catchup,
         total_txn_count,
         avg_throughput,
         avg_latency,
         total_bytes_sent,
         total_bytes_received,
         total_round_trips,
         total_admin_count,
         total_error_count,
         total_sleep_time,
         disabled_internally_set
    FROM sys."_DEFSCHEDULE"
/

grant select on defschedule to select_catalog_role
/

comment on table DEFSCHEDULE is
'Information about propagation to different destinations'
/
comment on column DEFSCHEDULE.DBLINK is
'Destination'
/
comment on column DEFSCHEDULE.JOB is
'Number of job that pushes queue'
/
comment on column DEFSCHEDULE.INTERVAL is
'Function used to calculate the next time to push the queue to destination'
/
comment on column DEFSCHEDULE.NEXT_DATE is
'Next date that job is scheduled to be executed'
/
comment on column DEFSCHEDULE.LAST_DATE is
'Last time queue was (attempted to be) pushed to destination'
/
comment on column DEFSCHEDULE.DISABLED is
'Is propagation to destination disabled'
/
comment on column DEFSCHEDULE.LAST_TXN_COUNT is
'Number of transactions pushed during last attempt'
/
comment on column DEFSCHEDULE.LAST_ERROR_NUMBER is
'Oracle error number from last push'
/
comment on column DEFSCHEDULE.LAST_ERROR_MESSAGE is
'Error message from last push'
/
comment on column DEFSCHEDULE.CATCHUP is
'Used to break transaction into pieces'
/
comment on column DEFSCHEDULE.DISABLED_INTERNALLY_SET is
'disabled was set internally for propagation synchronization'
/
comment on column DEFSCHEDULE.TOTAL_TXN_COUNT is
'Total number of transactions propagated (including error transactions)'
/
comment on column DEFSCHEDULE.AVG_THROUGHPUT is
'Average number of transactions (including errors) propagated per second'
/
comment on column DEFSCHEDULE.AVG_LATENCY is
'Average time in seconds since start of transaction to remote commit'
/
comment on column DEFSCHEDULE.TOTAL_BYTES_SENT is
'Total number of bytes sent over SQL*Net during propagation'
/
comment on column DEFSCHEDULE.TOTAL_BYTES_RECEIVED is
'Total number of bytes received over SQL*Net during propagation'
/
comment on column DEFSCHEDULE.TOTAL_ROUND_TRIPS is
'Total number of SQL*Net round trips during propagation'
/
comment on column DEFSCHEDULE.TOTAL_ADMIN_COUNT is
'Total number of administrative requests'
/
comment on column DEFSCHEDULE.TOTAL_ERROR_COUNT is
'Total number of error transactions propagated'
/
comment on column DEFSCHEDULE.TOTAL_SLEEP_TIME is
'Total time in seconds spent sleeping during propagation'
/

CREATE OR REPLACE PUBLIC SYNONYM defschedule FOR defschedule
/

CREATE OR REPLACE VIEW deferror AS SELECT
   e.enq_tid deferred_tran_id,
   e.origin_tran_db,
   e.origin_enq_tid origin_tran_id,
   e.step_no callno,
   e.destination, 
   e.enq_time start_time, e.error_number, e.error_msg, u.name receiver 
    FROM system.def$_error e, sys.user$ u
    WHERE e.receiver = u.user# (+)
/
grant select on deferror to select_catalog_role
/

comment on table DEFERROR is
'Information about all deferred transactions that caused an error'
/
comment on column DEFERROR.DEFERRED_TRAN_ID is
'The ID of the transaction that created the error'
/
comment on column DEFERROR.ORIGIN_TRAN_DB is
'The database originating the deferred transaction'
/
comment on column DEFERROR.ORIGIN_TRAN_ID is
'The original ID of the transaction'
/
comment on column DEFERROR.CALLNO is
'Unique ID of call that caused an error'
/
comment on column DEFERROR.DESTINATION is
'Database link used to address destination'
/
comment on column DEFERROR.START_TIME is
'Time original transaction enqueued'
/
comment on column DEFERROR.ERROR_NUMBER is
'Oracle error number'
/
comment on column DEFERROR.ERROR_MSG is
'Error message text'
/
comment on column DEFERROR.RECEIVER is
'The original receiver of the deferred transaction'
/

CREATE OR REPLACE PUBLIC SYNONYM deferror for deferror
/

CREATE OR REPLACE VIEW deferrcount AS
  SELECT count(1) errcount, destination 
    FROM deferror GROUP BY destination
/
grant select on deferrcount to select_catalog_role
/

comment on table DEFERRCOUNT is
'Summary information about deferred transactions that caused an error'
/
comment on column DEFERRCOUNT.ERRCOUNT is
'Number of existing transactions that caused an error for given destination'
/
comment on column DEFERRCOUNT.DESTINATION is
'Database link used to address destination'
/

CREATE OR REPLACE PUBLIC SYNONYM deferrcount for deferrcount
/
GRANT SELECT ON deferrcount TO PUBLIC
/

CREATE OR REPLACE VIEW deftran AS SELECT 
  enq_tid deferred_tran_id, 
  cscn delivery_order, 
  decode(recipient_key, 0, 'D', 'R') destination_list,
  enq_time start_time 
  FROM system.def$_aqcall t 
  WHERE cscn is NOT NULL 
UNION ALL 
SELECT enq_tid deferred_tran_id, 
  cscn delivery_order, 
  'D' destination_list, 
  enq_time start_time 
  FROM system.def$_aqerror t 
  WHERE cscn is NOT NULL 
/
grant select on deftran to select_catalog_role
/

comment on table DEFTRAN is
'Information about all deferred transactions'
/
comment on column DEFTRAN.DEFERRED_TRAN_ID is
'The transaction that enqueued the calls'
/
comment on column DEFTRAN.DELIVERY_ORDER is
'Total ordering on transactions'
/
comment on column DEFTRAN.DESTINATION_LIST is
'Determine destinations from deftrandest (D) or repcat (R)'
/
comment on column DEFTRAN.START_TIME is
'Time original transaction enqueued'
/

CREATE OR REPLACE PUBLIC SYNONYM deftran FOR deftran
/

--- just select from def$_calldest (D-type txn). We need repcat$_repprop
--- to determine destination for R-type txn. We can't remove this one
--- because dbms_snapshot needs it
create or replace view deftrandest as SELECT 
C.enq_tid deferred_tran_id, 
C.cscn delivery_order, 
D.dblink 
from system.def$_aqcall C, system.def$_destination D 
where C.cscn IS NOT NULL 
AND C.cscn >= D.last_delivered 
AND 
  (C.cscn > D.last_delivered 
  OR 
   (C.cscn = D.last_delivered AND (C.enq_tid > D.last_enq_tid))) 
AND EXISTS ( 
 select /*+ index(def$_calldest_primary) */ NULL 
 from system.def$_calldest CD 
 where CD.enq_tid = C.enq_tid 
   AND CD.dblink = D.dblink
   AND CD.catchup = D.catchup)
/
 
Rem The deftrandest view defined above is replaced in catrepc.
grant select on deftrandest to select_catalog_role
/

comment on table DEFTRANDEST is
'Information about destinations for deferred transactions'
/
comment on column DEFTRANDEST.DEFERRED_TRAN_ID is
'Transaction ID'
/
comment on column DEFTRANDEST.DELIVERY_ORDER is
'Total ordering of transactions: second element in the tuple'
/
comment on column DEFTRANDEST.DBLINK is
'The destination database'
/
CREATE OR REPLACE PUBLIC SYNONYM deftrandest FOR deftrandest
/

--  Create table of default nodes for replication targets
--  this table is managed by calls in dbms_defer_sys

CREATE SYNONYM def$_defaultdest FOR system.def$_defaultdest
/
CREATE OR REPLACE VIEW defdefaultdest AS
  SELECT * from system.def$_defaultdest
/
grant select on defdefaultdest to select_catalog_role
/

comment on table DEFDEFAULTDEST is
'Default destinations for deferred remote procedure calls'
/
comment on column DEFDEFAULTDEST.DBLINK is
'Default destination'
/

CREATE OR REPLACE PUBLIC SYNONYM defdefaultdest for defdefaultdest
/

CREATE OR REPLACE SYNONYM def$_lob FOR system.def$_lob
/

CREATE OR REPLACE VIEW DefLOB 
  (id, deferred_tran_id, blob_col, clob_col, nclob_col)
  AS SELECT
     d.id,
     d.enq_tid,
     d.blob_col,
     d.clob_col,
     d.nclob_col
  FROM sys.def$_lob d
/

grant select on deflob to select_catalog_role
/

comment on table DEFLOB is
'Storage for LOB parameters to deferred RPCs'
/
comment on column DEFLOB.ID is
'Identifier of LOB parameter'
/
comment on column DEFLOB.DEFERRED_TRAN_ID is
'Transaction identifier for deferred RPC with this LOB parameter'
/
comment on column DEFLOB.BLOB_COL is
'Binary LOB parameter'
/
comment on column DEFLOB.CLOB_COL is
'Character LOB parameter'
/
comment on column DEFLOB.NCLOB_COL is
'National Character LOB parameter'
/

CREATE OR REPLACE PUBLIC SYNONYM DefLOB for DefLOB
/

CREATE OR REPLACE VIEW defpropagator
  (username, userid, status, created)
  AS SELECT
       p.username,
       p.userid,
       DECODE(u.name, NULL, 'INVALID', 'VALID'),
       p.created
     FROM system.def$_propagator p, sys.user$ u
     WHERE p.userid = u.user# (+)
/
grant select on defpropagator to select_catalog_role
/

comment on table DEFPROPAGATOR is
'Information about the propagator for all deferred remote procedure calls'
/
comment on column DEFPROPAGATOR.USERNAME is
'Username of the propagator'
/
comment on column DEFPROPAGATOR.USERID is
'User ID of the propagator'
/
comment on column DEFPROPAGATOR.STATUS is
'Status of the propagator'
/
comment on column DEFPROPAGATOR.CREATED is
'Time when the propagator is registered'
/

CREATE OR REPLACE PUBLIC SYNONYM defpropagator FOR defpropagator
/

REM Set up export actions for deferred rpc tables.
rem delete existing export data

DELETE FROM expact$ WHERE name like 'DEF$_%' 
  AND func_package = 'DBMS_DEFER_IMPORT_INTERNAL'
/

insert into expact$ (owner, name, func_schema, func_package, func_proc, code,
obj_type)
values('SYSTEM','DEF$_AQERROR','SYS','DBMS_DEFER_IMPORT_INTERNAL',
        'QUEUE_EXPORT_CHECK',1,2)
/                                       
insert into expact$ (owner, name, func_schema, func_package, func_proc, code,
obj_type)
values('SYSTEM','DEF$_AQCALL','SYS','DBMS_DEFER_IMPORT_INTERNAL',
        'QUEUE_EXPORT_CHECK',1,2)
/
insert into expact$ (owner, name, func_schema, func_package, func_proc, code,
obj_type)
values('SYSTEM','DEF$_CALLDEST','SYS','DBMS_DEFER_IMPORT_INTERNAL',
        'QUEUE_EXPORT_CHECK',1,2)
/
insert into expact$ (owner, name, func_schema, func_package, func_proc, code,
obj_type)
values('SYSTEM','DEF$_ERROR','SYS','DBMS_DEFER_IMPORT_INTERNAL',
        'QUEUE_EXPORT_CHECK',1,2)
/
insert into expact$ (owner, name, func_schema, func_package, func_proc, code,
obj_type)
values('SYSTEM','DEF$_DEFAULTDEST','SYS','DBMS_DEFER_IMPORT_INTERNAL',
        'QUEUE_EXPORT_CHECK',1,2)
/
insert into expact$ (owner, name, func_schema, func_package, func_proc, code,
obj_type)
values('SYSTEM','DEF$_DESTINATION','SYS','DBMS_DEFER_IMPORT_INTERNAL',
        'QUEUE_EXPORT_CHECK',1,2)
/
COMMIT
/

DELETE FROM sys.duc$
  WHERE owner = 'SYS' AND pack = 'DBMS_DEFER_IMPORT_INTERNAL'
    AND proc = 'DROP_PROPAGATOR_CASCADE' AND operation# = 1
/
INSERT INTO sys.duc$ (owner, pack, proc, operation#, seq, com)
  VALUES('SYS', 'DBMS_DEFER_IMPORT_INTERNAL', 'DROP_PROPAGATOR_CASCADE', 1, 1,
         'Remove propagator if necessary')
/
COMMIT
/

-- Create synonyms for replication dynamic performance views and
-- grant select_catalog_role access to these views
create or replace view gv_$replqueue as select * from gv$replqueue
/
create or replace public synonym gv$replqueue for gv_$replqueue
/
grant select on gv_$replqueue to select_catalog_role
/

create or replace view v_$replqueue as select * from v$replqueue
/
create or replace public synonym v$replqueue for v_$replqueue
/
grant select on v_$replqueue to select_catalog_role
/

create or replace view gv_$replprop as select * from gv$replprop
/
create or replace public synonym gv$replprop for gv_$replprop
/
grant select on gv_$replprop to select_catalog_role
/

create or replace view v_$replprop as select * from v$replprop
/
create or replace public synonym v$replprop for v_$replprop
/
grant select on v_$replprop to select_catalog_role
/

create or replace view gv_$mvrefresh as select * from gv$mvrefresh
/
create or replace public synonym gv$mvrefresh for gv_$mvrefresh
/
grant select on gv_$mvrefresh to select_catalog_role
/

create or replace view v_$mvrefresh as select * from v$mvrefresh
/
create or replace public synonym v$mvrefresh for v_$mvrefresh
/
grant select on v_$mvrefresh to select_catalog_role
/
