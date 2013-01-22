Rem
Rem $Header: catapp.sql 10-mar-2005.16:44:44 elu Exp $
Rem
Rem catapp.sql
Rem
Rem Copyright (c) 2001, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catapp.sql - streams apply views
Rem
Rem    DESCRIPTION
Rem      This file contains all the streams apply views
Rem
Rem    NOTES
Rem
Rem    The order of the from clause listed from left to right
Rem    should be from highest cardinality to lowest cardinality for better
Rem    performance.  The optimizer choses driving tables from right to left
Rem    and using smaller tables first will eliminate more rows early on.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    elu         03/09/05 - move apply spilling to catapp.sql 
Rem    lkaplan     06/09/04 - add assemble_lobs to all_apply_dml_handlers 
Rem    liwong      06/08/04 - Add oldest_transaction_id 
Rem    dcassine    05/27/04 - added UA_NOTIFICATION_HANDLER to _DBA_APPLY 
Rem    lkaplan     02/22/04 - generic lob assembly 
Rem    dcassine    05/13/04 - add DBA_APPLY_VALUE_DEPENDENCIES
Rem    dcassine    05/13/04 - add DBA_APPLY_OBJECT_DEPENDENCIES
Rem    bpwang      01/08/04 - add error creation time in dba_apply_error 
Rem    sbalaram    02/02/04 - Add _DBA_APPLY_ERROR_TXN
Rem    sbalaram    09/18/03 - Fix DBA_APPLY_TABLE_COLUMNS view for remote apply
Rem    sbalaram    08/26/03 - Fix DBA_APPLY_TABLE_COLUMNS view
Rem    wesmith     07/29/03 - view DBA_APPLY: remove join to AQ tables
Rem    alakshmi    07/10/03 - facilitate apply name generation
Rem    htran       06/30/03 - optimize some views
Rem    liwong      06/19/03 - Modify dba_apply_dml_handlers
Rem    nshodhan    06/04/03 - grabtrans 'lkaplan_assemble_dml1'
Rem    lkaplan     06/04/03 - assemble lobs
Rem    liwong      05/30/03 - Support virtual constraints
Rem    sbalaram    05/21/03 - add views for streams$_dest_ops,
Rem                           streams$_dest_obj_cols
Rem    elu         05/19/03 - add start_scn to milestone table
Rem    elu         04/23/03 - modify all_apply
Rem    htran       12/31/02 - all_apply_enqueue: add double quotes
Rem    htran       12/11/02 - move dictionary changes to sql.bsq
Rem    htran       11/11/02 - increase size of procedure columns
Rem                           streams$_apply_process table
Rem    liwong      10/23/02 - Add status_changed_date
Rem    dcassine    10/07/02 - added start & end date the _DBA_APPLY view
Rem    elu         09/26/02 - add negative rulesets
Rem    htran       08/19/02 - DBA_APPLY_ENQUEUE, ALL_APPLY_ENQUEUE,
Rem                           DBA_APPLY_EXECUTE, and ALL_APPLY_EXECUTE
Rem    apadmana    08/22/02 - add view dba_apply_instantiated_schemas
Rem    alakshmi    07/26/02 - restrict max value for inittrans
Rem    sbalaram    06/17/02 - Fix bug 2395423
Rem    elu         06/14/02 - modify all_apply_error
Rem    elu         06/13/02 - add index on apply# to apply$_error
Rem    dcassine    07/01/02 - added precommit_handler to apply views
Rem    alakshmi    05/06/02 - Bug 2265160: set inittrans, freelists, pctfree 
Rem                           for apply_progress
Rem    sbalaram    01/24/02 - Fix view dba_apply_instantiated_objects
Rem    wesmith     01/09/02 - Streams export/import support
Rem    rgmani      01/19/02 - Code review comments
Rem    elu         12/28/01 - modify dba_apply_error
Rem    rgmani      01/10/02 - Add apply dblink to several views
Rem    sbalaram    12/10/01 - use create or replace synonym
Rem    sbalaram    12/04/01 - ALL_APPLY_PARAMETERS - join with all_apply
Rem    wesmith     11/19/01 - dba_apply: apply_user renamed to apply_userid
Rem    sbalaram    11/16/01 - Fix comments on some views
Rem    alakshmi    11/08/01 - Merged alakshmi_apicleanup
Rem    narora      11/02/01 - rename apply_slave
Rem    nshodhan    11/01/01 - Change apply$_error
Rem    nshodhan    11/01/01 - Change apply$_error
Rem    sbalaram    10/29/01 - add views
Rem    lkaplan     10/29/01 - API - dml hdlr, lcr.execute, set key options 
Rem    apadmana    10/26/01 - Created
Rem

Rem This cannot be placed in sql.bsq because of a sys.anydata column
rem apply spilling message information
rem NOTE: the shape of streams$_apply_spill_messages should be the
rem       same as that of streams$_apply_spill_msgs_part below.
create table streams$_apply_spill_messages
(
  txnkey           number NOT NULL,      /* key that maps to apply_name, xid */
  sequence         number NOT NULL,       /* sequence within the transaction */
  scn              number,                                 /* scn of the lcr */
  scnseq           number,                                   /* scn sequence */
  capinst          number,                        /* capture instance number */
  flags            number,                                  /* knallcr flags */
  flags2           number,                                  /* knlqdqm flags */
  message          sys.AnyData,                           /* spilled message */
  destqueue        varchar2(66),             /* destination queue owner.name */
  ubaafn           number,
  ubaobj           number,
  ubadba           number,
  ubaslt           number,
  ubarci           number,
  ubafsc           number,
  spare1           number,
  spare2           number,
  spare3           number,
  spare4           varchar2(4000),
  spare5           varchar2(4000),
  spare6           varchar2(4000)
)
tablespace SYSAUX
/
create unique index i_streams_apply_spill_mesgs1 on
  streams$_apply_spill_messages(txnkey, sequence)
tablespace SYSAUX
/

alter session set events  '14524 trace name context forever, level 1';
rem partitioned apply spilling message information
rem NOTE: the shape of streams$_apply_spill_msgs_part should be the
rem       same as that of streams$_apply_spill_messages above.
rem A partitioned version of the table for spilled messages has
rem been added to speed up clean up after the transaction is
rem applied. Each transaction is stored in a separate partition,
rem which can be truncated during clean up (instead of deleting the
rem rows for the transaction).
create table streams$_apply_spill_msgs_part
(
  txnkey           number NOT NULL,/* partition key, maps to apply_name, xid */
  sequence         number NOT NULL,       /* sequence within the transaction */
  scn              number,                                 /* scn of the lcr */
  scnseq           number,                                   /* scn sequence */
  capinst          number,                        /* capture instance number */
  flags            number,                                  /* knallcr flags */
  flags2           number,                                  /* knlqdqm flags */
  message          sys.AnyData,                           /* spilled message */
  destqueue        varchar2(66),             /* destination queue owner.name */
  ubaafn           number,
  ubaobj           number,
  ubadba           number,
  ubaslt           number,
  ubarci           number,
  ubafsc           number,
  spare1           number,
  spare2           number,
  spare3           number,
  spare4           varchar2(4000),
  spare5           varchar2(4000),
  spare6           varchar2(4000)
)
PARTITION BY LIST(txnkey)
(
  partition p0 values (0)
)
tablespace SYSAUX
/
create unique index i_streams_apply_spill_msgs_pt1 on
  streams$_apply_spill_msgs_part(sequence, txnkey)
local
tablespace SYSAUX
/
alter session set events  '14524 trace name context off'; 

-- apply spill txnkey sequence
BEGIN
  execute immediate
    'CREATE SEQUENCE streams$_apply_spill_txnkey_s
     MINVALUE 1 MAXVALUE 4294967295 START WITH 1 NOCACHE CYCLE';
EXCEPTION WHEN others THEN
  -- ok if the object exists
  IF sqlcode = -955 THEN
    NULL;
  ELSE
    RAISE;
  END IF;
END;
/

----------------------------------------------------------------------------
-- view to get the apply process details
----------------------------------------------------------------------------

-- Private view select to all columns from streams$_apply_process.
-- Used by export. Respective catalog views will select from this view.
create or replace view "_DBA_APPLY"
as select 
  apply#, apply_name, queue_oid, queue_owner, queue_name, status, flags,
  ruleset_owner, ruleset_name, message_handler, ddl_handler, precommit_handler,
  apply_userid, apply_dblink, apply_tag, start_date, end_date, 
  negative_ruleset_owner, negative_ruleset_name, spare1, spare2, spare3,
  status_change_time, error_number, error_message, ua_notification_handler,
  ua_ruleset_owner, ua_ruleset_name  
from sys.streams$_apply_process
/
grant select on "_DBA_APPLY" to exp_full_database
/

create or replace view DBA_APPLY
  (APPLY_NAME, QUEUE_NAME, QUEUE_OWNER, APPLY_CAPTURED, 
   RULE_SET_NAME,   RULE_SET_OWNER, APPLY_USER, APPLY_DATABASE_LINK, 
   APPLY_TAG, DDL_HANDLER, PRECOMMIT_HANDLER, MESSAGE_HANDLER, STATUS, 
   MAX_APPLIED_MESSAGE_NUMBER, NEGATIVE_RULE_SET_NAME, 
   NEGATIVE_RULE_SET_OWNER, STATUS_CHANGE_TIME,
   ERROR_NUMBER, ERROR_MESSAGE)
as
select ap.apply_name, ap.queue_name, ap.queue_owner, 
       decode(bitand(ap.flags, 1), 1, 'YES',
                                   0, 'NO'),
       ap.ruleset_name, ap.ruleset_owner,
       u.name, ap.apply_dblink, ap.apply_tag, ap.ddl_handler,
       ap.precommit_handler, ap.message_handler,
       decode(ap.status, 1, 'DISABLED',
                         2, 'ENABLED',
                         4, 'ABORTED', 'UNKNOWN'),
       ap.spare1,
       ap.negative_ruleset_name, ap.negative_ruleset_owner,
       ap.status_change_time, ap.error_number, ap.error_message
  from "_DBA_APPLY" ap, sys.user$ u
 where  ap.apply_userid = u.user# (+)
/

comment on table DBA_APPLY is
'Details about the apply process'
/
comment on column DBA_APPLY.APPLY_NAME is
'Name of the apply process'
/
comment on column DBA_APPLY.QUEUE_NAME is
'Name of the queue the apply process dequeues from'
/
comment on column DBA_APPLY.QUEUE_OWNER is
'Owner of the queue the apply process dequeues from'
/
comment on column DBA_APPLY.APPLY_CAPTURED is
'Yes, if applying captured messages; No, if applying enqueued messages'
/
comment on column DBA_APPLY.RULE_SET_NAME is
'Rule set used by apply process for filtering'
/
comment on column DBA_APPLY.RULE_SET_OWNER is
'Owner of the rule set'
/
comment on column DBA_APPLY.APPLY_USER is
'Current user who is applying the messages'
/
comment on column DBA_APPLY.APPLY_DATABASE_LINK is
'For remote objects, the database link pointing to the remote database'
/
comment on column DBA_APPLY.APPLY_TAG is
'Tag associated with DDL and DML change records that will be applied'
/
comment on column DBA_APPLY.DDL_HANDLER is
'Name of the user specified ddl handler'
/
comment on column DBA_APPLY.PRECOMMIT_HANDLER is
'Name of the user specified precommit handler'
/
comment on column DBA_APPLY.MESSAGE_HANDLER is
'User specified procedure to handle messages other than DDL and DML messages'
/
comment on column DBA_APPLY.STATUS is
'Status of the apply process: DISABLED, ENABLED, ABORTED'
/
comment on column DBA_APPLY.MAX_APPLIED_MESSAGE_NUMBER is
'Maximum value of message that has been applied'
/
comment on column DBA_APPLY.STATUS_CHANGE_TIME is
'The time that STATUS of the apply process was changed'
/
comment on column DBA_APPLY.ERROR_NUMBER is
'Error number if the apply process was aborted'
/
comment on column DBA_APPLY.ERROR_MESSAGE is
'Error message if the apply process was aborted'
/
create or replace public synonym DBA_APPLY for DBA_APPLY
/
grant select on DBA_APPLY to select_catalog_role
/
comment on column DBA_APPLY.NEGATIVE_RULE_SET_NAME is
'Negative rule set used by apply process for filtering'
/
comment on column DBA_APPLY.RULE_SET_OWNER is
'Owner of the negative rule set'
/

----------------------------------------------------------------------------

-- View of apply processes
create or replace view ALL_APPLY
as
select a.*
  from dba_apply a, all_queues q
 where a.queue_name = q.name
   and a.queue_owner = q.owner
   and ((a.rule_set_owner is null and a.rule_set_name is null) or
        ((a.rule_set_owner, a.rule_set_name) in 
          (select r.rule_set_owner, r.rule_set_name
             from all_rule_sets r)))
   and ((a.negative_rule_set_owner is null and 
         a.negative_rule_set_name is null) or
        ((a.negative_rule_set_owner, a.negative_rule_set_name) in 
          (select r.rule_set_owner, r.rule_set_name
             from all_rule_sets r)))
/

comment on table ALL_APPLY is
'Details about each apply process that dequeues from the queue visible to the current user'
/
comment on column ALL_APPLY.APPLY_NAME is
'Name of the apply process'
/
comment on column ALL_APPLY.QUEUE_NAME is
'Name of the queue the apply process dequeues from'
/
comment on column ALL_APPLY.QUEUE_OWNER is
'Owner of the queue the apply process dequeues from'
/
comment on column ALL_APPLY.APPLY_CAPTURED is
'Yes, if applying captured messages; No, if applying enqueued messages'
/
comment on column ALL_APPLY.RULE_SET_NAME is
'Rule set used by apply process for filtering'
/
comment on column ALL_APPLY.RULE_SET_OWNER is
'Owner of the rule set'
/
comment on column ALL_APPLY.APPLY_USER is
'Current user who is applying the messages'
/
comment on column ALL_APPLY.APPLY_DATABASE_LINK is
'For remote objects, the database link pointing to the remote database'
/
comment on column ALL_APPLY.APPLY_TAG is
'Tag associated with DDL and DML change records that will be applied'
/
comment on column ALL_APPLY.DDL_HANDLER is
'Name of the user specified ddl handler'
/
comment on column ALL_APPLY.PRECOMMIT_HANDLER is
'Name of the user specified precommit handler'
/
comment on column ALL_APPLY.MESSAGE_HANDLER is
'User specified procedure to handle messages other than DDL and DML messages'
/
comment on column ALL_APPLY.STATUS is
'Status of the apply process: DISABLED, ENABLED, ABORTED'
/
comment on column ALL_APPLY.STATUS_CHANGE_TIME is
'The time that STATUS of the apply process was changed'
/
comment on column ALL_APPLY.ERROR_NUMBER is
'Error number if the apply process was aborted'
/
comment on column ALL_APPLY.ERROR_MESSAGE is
'Error message if the apply process was aborted'
/
comment on column ALL_APPLY.NEGATIVE_RULE_SET_NAME is
'Negative rule set used by apply process for filtering'
/
comment on column ALL_APPLY.NEGATIVE_RULE_SET_OWNER is
'Owner of the negative rule set'
/
comment on column ALL_APPLY.MAX_APPLIED_MESSAGE_NUMBER is
'Maximum value of message that has been applied'
/
create or replace public synonym ALL_APPLY for ALL_APPLY
/
grant select on ALL_APPLY to public with grant option
/

----------------------------------------------------------------------------
-- view to get apply process parameters
--
-- Note: process_type = 1 corresponds to the package variable
--       dbms_streams_adm_utl.proc_type_apply (prvtbsdm.sql)
--       and the macro KNLU_APPLY_PROC (knlu.h). This *must* be
--        kept in sync with both of these.
----------------------------------------------------------------------------
create or replace view DBA_APPLY_PARAMETERS
  (APPLY_NAME, PARAMETER, VALUE, SET_BY_USER)
as
select ap.apply_name, pp.name, pp.value,
       decode(pp.user_changed_flag, 1, 'YES', 'NO')
  from sys.streams$_process_params pp, sys.streams$_apply_process ap
 where pp.process_type = 1
   and pp.process# = ap.apply#
   and /* display internal parameters if the user changed them */
       (pp.internal_flag = 0
        or
        (pp.internal_flag = 1 and pp.user_changed_flag = 1)
       )
/

comment on table DBA_APPLY_PARAMETERS is
'All parameters for apply process'
/
comment on column DBA_APPLY_PARAMETERS.APPLY_NAME is
'Name of the apply process'
/
comment on column DBA_APPLY_PARAMETERS.PARAMETER is
'Name of the parameter'
/
comment on column DBA_APPLY_PARAMETERS.VALUE is
'Either the default value or the value set by the user for the parameter'
/
comment on column DBA_APPLY_PARAMETERS.SET_BY_USER is
'YES if the value is set by the user, NO otherwise'
/
create or replace public synonym DBA_APPLY_PARAMETERS
  for DBA_APPLY_PARAMETERS
/
grant select on DBA_APPLY_PARAMETERS to select_catalog_role
/

----------------------------------------------------------------------------

create or replace view ALL_APPLY_PARAMETERS
  (APPLY_NAME, PARAMETER, VALUE, SET_BY_USER)
as
select pa.apply_name, pa.parameter, pa.value, pa.set_by_user
  from dba_apply_parameters pa, all_apply aa
 where pa.apply_name = aa.apply_name
/

comment on table ALL_APPLY_PARAMETERS is
'Details about parameters of each apply process that dequeues from the queue visible to the current user'
/
comment on column ALL_APPLY_PARAMETERS.APPLY_NAME is
'Name of the apply process'
/
comment on column ALL_APPLY_PARAMETERS.PARAMETER is
'Name of the parameter'
/
comment on column ALL_APPLY_PARAMETERS.VALUE is
'Either the default value or the value set by the user for the parameter'
/
comment on column ALL_APPLY_PARAMETERS.SET_BY_USER is
'YES if the value is set by the user, NO otherwise'
/
create or replace public synonym ALL_APPLY_PARAMETERS
  for ALL_APPLY_PARAMETERS
/
grant select on ALL_APPLY_PARAMETERS to public with grant option
/

----------------------------------------------------------------------------
-- view to get apply instantiated objects
----------------------------------------------------------------------------

-- Private view select to all columns from apply$_source_schema.
-- Used by export. Respective catalog views will select from this view.
create or replace view "_DBA_APPLY_SOURCE_SCHEMA"
as select 
  source_db_name, global_flag, name, dblink, inst_scn, spare1
from sys.apply$_source_schema
/
grant select on "_DBA_APPLY_SOURCE_SCHEMA" to exp_full_database
/

----------------------------------------------------------------------------

-- Private view select to all columns from apply$_source_obj
-- Used by export. Respective catalog views will select from this view.
create or replace view "_DBA_APPLY_SOURCE_OBJ"
as select 
  id, owner, name, decode(type, 2, 'TABLE', 'UNSUPPORTED') type,
  source_db_name, dblink, inst_scn, ignore_scn,
  spare1
from sys.apply$_source_obj
/
grant select on "_DBA_APPLY_SOURCE_OBJ" to exp_full_database
/

----------------------------------------------------------------------------

create or replace view DBA_APPLY_INSTANTIATED_OBJECTS
  (SOURCE_DATABASE, SOURCE_OBJECT_OWNER, SOURCE_OBJECT_NAME,
   SOURCE_OBJECT_TYPE, INSTANTIATION_SCN, IGNORE_SCN, APPLY_DATABASE_LINK)
as
select source_db_name, owner, name,
       type, inst_scn, ignore_scn, dblink
  from "_DBA_APPLY_SOURCE_OBJ"
/

comment on table DBA_APPLY_INSTANTIATED_OBJECTS is
'Details about objects instantiated'
/
comment on column DBA_APPLY_INSTANTIATED_OBJECTS.SOURCE_DATABASE is
'Name of the database where the objects originated'
/
comment on column DBA_APPLY_INSTANTIATED_OBJECTS.SOURCE_OBJECT_OWNER is
'Owner of the object at the source database'
/
comment on column DBA_APPLY_INSTANTIATED_OBJECTS.SOURCE_OBJECT_NAME is
'Name of the object at source'
/
comment on column DBA_APPLY_INSTANTIATED_OBJECTS.SOURCE_OBJECT_TYPE is
'Type of the object at source'
/
comment on column DBA_APPLY_INSTANTIATED_OBJECTS.INSTANTIATION_SCN is
'Point in time when the object was instantiated at source'
/
comment on column DBA_APPLY_INSTANTIATED_OBJECTS.IGNORE_SCN is
'SCN lower bound for messages that will be considered for apply'
/
comment on column DBA_APPLY_INSTANTIATED_OBJECTS.APPLY_DATABASE_LINK is
'For remote objects, the database link pointing to the remote database'
/
create or replace public synonym DBA_APPLY_INSTANTIATED_OBJECTS
  for DBA_APPLY_INSTANTIATED_OBJECTS
/
grant select on DBA_APPLY_INSTANTIATED_OBJECTS to select_catalog_role
/

----------------------------------------------------------------------------

create or replace view DBA_APPLY_INSTANTIATED_SCHEMAS
  (SOURCE_DATABASE, SOURCE_SCHEMA, INSTANTIATION_SCN, APPLY_DATABASE_LINK)
as
select source_db_name, name, inst_scn, dblink
  from "_DBA_APPLY_SOURCE_SCHEMA"
 where global_flag = 0
/

comment on table DBA_APPLY_INSTANTIATED_SCHEMAS is
'Details about schemas instantiated'
/
comment on column DBA_APPLY_INSTANTIATED_SCHEMAS.SOURCE_DATABASE is
'Name of the database where the schemas originated'
/
comment on column DBA_APPLY_INSTANTIATED_SCHEMAS.INSTANTIATION_SCN is
'Point in time when the schema was instantiated at source'
/
comment on column DBA_APPLY_INSTANTIATED_SCHEMAS.APPLY_DATABASE_LINK is
'For remote schemas, the database link pointing to the remote database'
/
create or replace public synonym DBA_APPLY_INSTANTIATED_SCHEMAS
  for DBA_APPLY_INSTANTIATED_SCHEMAS
/
grant select on DBA_APPLY_INSTANTIATED_SCHEMAS to select_catalog_role
/

----------------------------------------------------------------------------

create or replace view DBA_APPLY_INSTANTIATED_GLOBAL
  (SOURCE_DATABASE, INSTANTIATION_SCN, APPLY_DATABASE_LINK)
as
select source_db_name, inst_scn, dblink
  from "_DBA_APPLY_SOURCE_SCHEMA"
 where global_flag = 1
/

comment on table DBA_APPLY_INSTANTIATED_GLOBAL is
'Details about database instantiated'
/
comment on column DBA_APPLY_INSTANTIATED_GLOBAL.SOURCE_DATABASE is
'Name of the database that was instantiated'
/
comment on column DBA_APPLY_INSTANTIATED_GLOBAL.INSTANTIATION_SCN is
'Point in time when the database was instantiated at source'
/
comment on column DBA_APPLY_INSTANTIATED_GLOBAL.APPLY_DATABASE_LINK is
'For a remote database, the database link pointing to the remote database'
/
create or replace public synonym DBA_APPLY_INSTANTIATED_GLOBAL
  for DBA_APPLY_INSTANTIATED_GLOBAL
/
grant select on DBA_APPLY_INSTANTIATED_GLOBAL to select_catalog_role
/

----------------------------------------------------------------------------

create or replace view "_DBA_APPLY_CONSTRAINT_COLUMNS"
as
select constraint_name dependency_name, owner object_owner, name object_name,
       cname column_name, cpos column_position
  from sys.apply$_constraint_columns
/

grant select on "_DBA_APPLY_CONSTRAINT_COLUMNS" to select_catalog_role
/

create or replace public synonym DBA_APPLY_VALUE_DEPENDENCIES
  for "_DBA_APPLY_CONSTRAINT_COLUMNS"
/

grant select on DBA_APPLY_VALUE_DEPENDENCIES to select_catalog_role
/

comment on column DBA_APPLY_VALUE_DEPENDENCIES.DEPENDENCY_NAME is
'Dependency name'
/

comment on column DBA_APPLY_VALUE_DEPENDENCIES.OBJECT_OWNER is
'Schema of owning object'
/

comment on column DBA_APPLY_VALUE_DEPENDENCIES.OBJECT_NAME is
'Owning object'
/

comment on column DBA_APPLY_VALUE_DEPENDENCIES.COLUMN_NAME is
'Dependency column name'
/

comment on column DBA_APPLY_VALUE_DEPENDENCIES.COLUMN_POSITION is
'Dependency column position'
/

----------------------------------------------------------------------------

create or replace view "_DBA_APPLY_OBJECT_CONSTRAINTS"
as
select owner object_owner, name object_name,
       powner parent_object_owner, pname parent_object_name
  from sys.apply$_virtual_obj_cons
/

grant select on "_DBA_APPLY_OBJECT_CONSTRAINTS" to select_catalog_role
/


create or replace public synonym DBA_APPLY_OBJECT_DEPENDENCIES
  for "_DBA_APPLY_OBJECT_CONSTRAINTS"
/

grant select on DBA_APPLY_OBJECT_DEPENDENCIES to select_catalog_role
/

comment on column DBA_APPLY_OBJECT_DEPENDENCIES.OBJECT_OWNER is
'Schema of the object'
/

comment on column DBA_APPLY_OBJECT_DEPENDENCIES.OBJECT_NAME is
'Object name'
/

comment on column DBA_APPLY_OBJECT_DEPENDENCIES.PARENT_OBJECT_OWNER is
'Schema of the parent object'
/

comment on column DBA_APPLY_OBJECT_DEPENDENCIES.PARENT_OBJECT_NAME is
'Parent object name'
/
 

----------------------------------------------------------------------------
-- view to get apply key columns
-- TODO: Use long_cname when user-defined type is supported
----------------------------------------------------------------------------
create or replace view DBA_APPLY_KEY_COLUMNS
  (OBJECT_OWNER, OBJECT_NAME, COLUMN_NAME, APPLY_DATABASE_LINK)
as
select sname, oname, cname, dblink
  from sys.streams$_key_columns
/

comment on table DBA_APPLY_KEY_COLUMNS is
'alternative key columns for a table for STREAMS'
/
comment on column DBA_APPLY_KEY_COLUMNS.OBJECT_OWNER is
'Owner of the object'
/
comment on column DBA_APPLY_KEY_COLUMNS.OBJECT_NAME is
'Name of the object'
/
comment on column DBA_APPLY_KEY_COLUMNS.COLUMN_NAME is
'Column name of the object'
/
comment on column DBA_APPLY_KEY_COLUMNS.APPLY_DATABASE_LINK is
'Remote database link to which changes will be aplied'
/
create or replace public synonym DBA_APPLY_KEY_COLUMNS
  for DBA_APPLY_KEY_COLUMNS
/
grant select on DBA_APPLY_KEY_COLUMNS to select_catalog_role
/

----------------------------------------------------------------------------

create or replace view ALL_APPLY_KEY_COLUMNS
  (OBJECT_OWNER, OBJECT_NAME, COLUMN_NAME, APPLY_DATABASE_LINK)
as
select k.object_owner, k.object_name, k.column_name, k.apply_database_link
  from all_tab_columns a, dba_apply_key_columns k
 where k.object_owner = a.owner
   and k.object_name = a.table_name
   and k.column_name = a.column_name
/

comment on table ALL_APPLY_KEY_COLUMNS is
'Alternative key columns for a STREAMS table visible to the current user'
/
comment on column ALL_APPLY_KEY_COLUMNS.OBJECT_OWNER is
'Owner of the object'
/
comment on column ALL_APPLY_KEY_COLUMNS.OBJECT_NAME is
'Name of the object'
/
comment on column ALL_APPLY_KEY_COLUMNS.COLUMN_NAME is
'Column name of the object'
/
comment on column ALL_APPLY_KEY_COLUMNS.APPLY_DATABASE_LINK is
'Remote database link to which changes will be aplied'
/
create or replace public synonym ALL_APPLY_KEY_COLUMNS
  for ALL_APPLY_KEY_COLUMNS
/
grant select on ALL_APPLY_KEY_COLUMNS to PUBLIC with grant option
/

----------------------------------------------------------------------------
-- view to get conflict/error handling information during apply
----------------------------------------------------------------------------

-- Private view select to all columns from apply$_error_handler
-- Used by export. Respective catalog views will select from this view.
create or replace view "_DBA_APPLY_ERROR_HANDLER"
as select 
  eh.object_number, eh.method_name, eh.resolution_column, eh.resolution_id, 
  eh.spare1, o.linkname
from sys.obj$ o, sys.apply$_error_handler eh
where eh.object_number = o.obj#
/
grant select on "_DBA_APPLY_ERROR_HANDLER" to exp_full_database
/

-- Create an index on apply# for apply$_error
-- TO DO: move this to sql.bsq
create index streams$_apply_error_idx_2
 on apply$_error(apply#)
/

----------------------------------------------------------------------------

-- Private view select to all columns from apply$_conf_hdlr_columns
-- Used by export. Respective catalog views will select from this view.
create or replace view "_DBA_APPLY_CONF_HDLR_COLUMNS"
as select 
  object_number, resolution_id, column_name, spare1
from sys.apply$_conf_hdlr_columns
/
grant select on "_DBA_APPLY_CONF_HDLR_COLUMNS" to exp_full_database
/

----------------------------------------------------------------------------

create or replace view DBA_APPLY_CONFLICT_COLUMNS
  (OBJECT_OWNER, OBJECT_NAME, METHOD_NAME, RESOLUTION_COLUMN, COLUMN_NAME,
   APPLY_DATABASE_LINK)
as
select u.username, o.name, eh.method_name, eh.resolution_column,
       ac.column_name, NULL
  from sys.obj$ o, "_DBA_APPLY_CONF_HDLR_COLUMNS" ac, 
       "_DBA_APPLY_ERROR_HANDLER" eh, dba_users u
 where o.obj# = ac.object_number
   and o.obj# = eh.object_number
   and ac.resolution_id = eh.resolution_id
   and u.user_id = o.owner#
   and o.remoteowner is NULL
union
select o.remoteowner, o.name, eh.method_name, eh.resolution_column,
       ac.column_name, o.linkname
  from sys.obj$ o, apply$_conf_hdlr_columns ac, apply$_error_handler eh
 where o.obj# = ac.object_number
   and o.obj# = eh.object_number
   and ac.resolution_id = eh.resolution_id
   and o.remoteowner is not NULL
/

comment on table DBA_APPLY_CONFLICT_COLUMNS is
'Details about conflict resolution'
/
comment on column DBA_APPLY_CONFLICT_COLUMNS.OBJECT_OWNER is
'Owner of the object'
/
comment on column DBA_APPLY_CONFLICT_COLUMNS.OBJECT_NAME is
'Name of the object'
/
comment on column DBA_APPLY_CONFLICT_COLUMNS.METHOD_NAME is
'Name of the method used to resolve conflict'
/
comment on column DBA_APPLY_CONFLICT_COLUMNS.RESOLUTION_COLUMN is
'Name of the column used to resolve conflict'
/
comment on column DBA_APPLY_CONFLICT_COLUMNS.COLUMN_NAME is
'Name of the column that is to be considered as part of a group to resolve conflict'
/
comment on column DBA_APPLY_CONFLICT_COLUMNS.APPLY_DATABASE_LINK is
'For remote objects, name of database link pointing to remote database'
/
create or replace public synonym DBA_APPLY_CONFLICT_COLUMNS
  for DBA_APPLY_CONFLICT_COLUMNS
/
grant select on DBA_APPLY_CONFLICT_COLUMNS to select_catalog_role
/

----------------------------------------------------------------------------

create or replace view ALL_APPLY_CONFLICT_COLUMNS
  (OBJECT_OWNER, OBJECT_NAME, METHOD_NAME, RESOLUTION_COLUMN, COLUMN_NAME,
   APPLY_DATABASE_LINK)
as
select c.object_owner, c.object_name, c.method_name,
       c.resolution_column, c.column_name, c.apply_database_link
  from all_tab_columns o, dba_apply_conflict_columns c
 where c.object_owner = o.owner
   and c.object_name = o.table_name
   and c.column_name = o.column_name
/

comment on table ALL_APPLY_CONFLICT_COLUMNS is
'Details about conflict resolution on tables visible to the current user'
/
comment on column ALL_APPLY_CONFLICT_COLUMNS.OBJECT_OWNER is
'Owner of the object'
/
comment on column ALL_APPLY_CONFLICT_COLUMNS.OBJECT_NAME is
'Name of the object'
/
comment on column ALL_APPLY_CONFLICT_COLUMNS.METHOD_NAME is
'Name of the method used to resolve conflict'
/
comment on column ALL_APPLY_CONFLICT_COLUMNS.RESOLUTION_COLUMN is
'Name of the column used to resolve conflict'
/
comment on column ALL_APPLY_CONFLICT_COLUMNS.COLUMN_NAME is
'Name of the column that is to be considered as part of a group to resolve conflict'
/
comment on column ALL_APPLY_CONFLICT_COLUMNS.APPLY_DATABASE_LINK is
'For remote objects, name of database link pointing to remote database'
/
create or replace public synonym ALL_APPLY_CONFLICT_COLUMNS
  for ALL_APPLY_CONFLICT_COLUMNS
/
grant select on ALL_APPLY_CONFLICT_COLUMNS to public with grant option
/

----------------------------------------------------------------------------
-- Private helper view to select all the columns from streams$_dest_objs
create or replace view "_DBA_APPLY_OBJECTS"
(OBJECT_OWNER, OBJECT_NAME, PROPERTY, APPLY_DATABASE_LINK, SPARE1, SPARE2,
 SPARE3, SPARE4)
as select
u.name, o.name, do.property, do.dblink, do.spare1, do.spare2,
do.spare3, do.spare4
from sys.streams$_dest_objs do, sys.obj$ o, sys.user$ u
  where o.obj# = do.object_number
   and o.owner# = u.user#
/
----------------------------------------------------------------------------

-- Private view to select all columns from streams$_dest_obj_cols
-- Used by export. Respective catalog views will select from this view.
create or replace view "_DBA_APPLY_TABLE_COLUMNS"
as select
  object_number, column_name, flag, dblink, spare1, spare2
from sys.streams$_dest_obj_cols
/
----------------------------------------------------------------------------

-- Private helper view to create the view dba_apply_table_columns.
-- TODO: does not handle column name for objects. Need to revisit
-- when we support objects.
-- This view selects all the non-key columns in the table which
-- have not been explicitly specified a "compare" action.
create or replace view "_DBA_APPLY_TABLE_COLUMNS_H"
(OBJECT_OWNER, OBJECT_NAME, COLUMN_NAME, APPLY_DATABASE_LINK) as
-- select all the columns in the table
(select u.name, o.name, c.name, do.dblink
  from sys.user$ u, sys.obj$ o, sys.col$ c, sys.streams$_dest_objs do
 where do.object_number = o.obj#
   and o.obj# = c.obj#
   and o.owner# = u.user#
   and ((do.dblink = o.linkname) or (do.dblink is null and o.linkname is null))
minus
-- omit the pk constraint columns from the list of columns
select u.name, o.name, decode(ac.name, null, col.name, ac.name), do.dblink
  from sys.user$ u, sys.con$ c, sys.col$ col, sys.ccol$ cc, sys.cdef$ cd,
       sys.obj$ o, sys.attrcol$ ac, sys.streams$_dest_objs do
 where c.owner# = u.user#
   and o.obj# = do.object_number
   and c.con# = cd.con#
   and cd.type# = 2
   and cd.con# = cc.con#
   and cc.obj# = col.obj#
   and cc.intcol# = col.intcol#
   and cc.obj# = o.obj#
   and col.obj# = ac.obj#(+)
   and col.intcol# = ac.intcol#(+)
   and ((do.dblink = o.linkname) or (do.dblink is null and o.linkname is null))
minus
-- omit columns designated as key columns
select kc.sname, kc.oname, kc.cname, do.dblink
  from sys.streams$_key_columns kc, sys.streams$_dest_objs do,
       sys.obj$ o, sys.user$ u
 where kc.sname = u.name
   and u.user# = o.owner#
   and o.name = kc.oname
   and o.obj# = do.object_number
   and ((kc.dblink = do.dblink) or (kc.dblink is null and do.dblink is null))
   and ((do.dblink = o.linkname) or (do.dblink is null and o.linkname is null))
minus
-- omit the columns which are in sys.streams$_dest_obj_cols
-- These may have a different setting than the one mentioned in
-- streams$_dest_objs. These columns will be included seperately later.
select u.name, o.name, doc.column_name, do.dblink
  from sys.streams$_dest_objs do, sys.streams$_dest_obj_cols doc,
       sys.obj$ o, sys.user$ u
 where do.object_number = doc.object_number
   and doc.object_number = o.obj#
   and ((do.dblink = doc.dblink) or (do.dblink is null and doc.dblink is null))
   and ((do.dblink = o.linkname) or (do.dblink is null and o.linkname is null))
   and o.owner# = u.user#)
/

----------------------------------------------------------------------------

create or replace view DBA_APPLY_TABLE_COLUMNS
(OBJECT_OWNER, OBJECT_NAME, COLUMN_NAME,
 COMPARE_OLD_ON_DELETE, COMPARE_OLD_ON_UPDATE, APPLY_DATABASE_LINK) as
(select daoc.object_owner, daoc.object_name, daoc.column_name,
       decode(bitand(ac.property, 1), 1, 'NO', 0, 'YES'),
       decode(bitand(ac.property, 2), 2, 'NO', 0, 'YES'),
       daoc.apply_database_link
  from "_DBA_APPLY_TABLE_COLUMNS_H" daoc, "_DBA_APPLY_OBJECTS" ac
 where daoc.object_owner = ac.object_owner
   and daoc.object_name  = ac.object_name
union
select u.name, o.name, doc.column_name,
       decode(bitand(doc.flag, 1), 1, 'NO', 0, 'YES'),
       decode(bitand(doc.flag, 2), 2, 'NO', 0, 'YES'),
       null
  from sys.streams$_dest_obj_cols doc, sys.obj$ o, sys.user$ u
 where o.obj# = doc.object_number
   and o.owner# = u.user#
   and o.linkname is null
   and doc.dblink is null
   and o.remoteowner is null
union
select o.remoteowner, o.name, doc.column_name,
       decode(bitand(doc.flag, 1), 1, 'NO', 0, 'YES'),
       decode(bitand(doc.flag, 2), 2, 'NO', 0, 'YES'),
       doc.dblink
  from sys.streams$_dest_obj_cols doc, sys.obj$ o
 where o.obj# = doc.object_number
   and o.linkname = doc.dblink
   and o.remoteowner is not null)
/

comment on table DBA_APPLY_TABLE_COLUMNS is
'Details about the destination table columns'
/
comment on column DBA_APPLY_TABLE_COLUMNS.OBJECT_OWNER is
'Owner of the table'
/
comment on column DBA_APPLY_TABLE_COLUMNS.OBJECT_NAME is
'Name of the table'
/
comment on column DBA_APPLY_TABLE_COLUMNS.COLUMN_NAME is
'Name of column'
/
comment on column DBA_APPLY_TABLE_COLUMNS.COMPARE_OLD_ON_DELETE is
'Compare old value of column on deletes'
/
comment on column DBA_APPLY_TABLE_COLUMNS.COMPARE_OLD_ON_UPDATE is
'Compare old value of column on updates'
/
comment on column DBA_APPLY_TABLE_COLUMNS.APPLY_DATABASE_LINK is
'For remote table, name of database link pointing to remote database'
/
create or replace public synonym DBA_APPLY_TABLE_COLUMNS
  for DBA_APPLY_TABLE_COLUMNS
/
grant select on DBA_APPLY_TABLE_COLUMNS to select_catalog_role
/
----------------------------------------------------------------------------

create or replace view ALL_APPLY_TABLE_COLUMNS
as
select do.*
  from all_tab_columns a, dba_apply_table_columns do
 where do.object_owner = a.owner
   and do.object_name = a.table_name
   and do.column_name = a.column_name
/
comment on table ALL_APPLY_TABLE_COLUMNS is
'Details about the columns of destination table object visible to the user'
/
comment on column ALL_APPLY_TABLE_COLUMNS.OBJECT_OWNER is
'Owner of the table'
/
comment on column ALL_APPLY_TABLE_COLUMNS.OBJECT_NAME is
'Name of the table'
/
comment on column ALL_APPLY_TABLE_COLUMNS.COLUMN_NAME is
'Name of column'
/
comment on column ALL_APPLY_TABLE_COLUMNS.COMPARE_OLD_ON_DELETE is
'Compare old value of column on deletes'
/
comment on column ALL_APPLY_TABLE_COLUMNS.COMPARE_OLD_ON_UPDATE is
'Compare old value of column on updates'
/
comment on column ALL_APPLY_TABLE_COLUMNS.APPLY_DATABASE_LINK is
'For remote tables, name of database link pointing to remote database'
/
create or replace public synonym ALL_APPLY_TABLE_COLUMNS
  for ALL_APPLY_TABLE_COLUMNS
/
grant select on ALL_APPLY_TABLE_COLUMNS to PUBLIC with grant option
/

----------------------------------------------------------------------------
-- view to get user procedure/error handling information during apply
----------------------------------------------------------------------------
create or replace view DBA_APPLY_DML_HANDLERS
  (OBJECT_OWNER, OBJECT_NAME, OPERATION_NAME,
   USER_PROCEDURE, ERROR_HANDLER, APPLY_DATABASE_LINK, APPLY_NAME,
   ASSEMBLE_LOBS)
as
select sname, oname,
       decode(do.apply_operation, 0, 'DEFAULT',
                                  1, 'INSERT',
                                  2, 'UPDATE',
                                  3, 'DELETE',
                                  4, 'LOB_UPDATE',
                                  5, 'ASSEMBLE_LOBS', 'UNKNOWN'),
       do.user_apply_procedure,
       do.error_handler, o.linkname, do.apply_name, do.assemble_lobs
  from sys.obj$ o, apply$_dest_obj_ops do
 where do.object_number = o.obj# (+)
/

comment on table DBA_APPLY_DML_HANDLERS is
'Details about the dml handler'
/
comment on column DBA_APPLY_DML_HANDLERS.OBJECT_OWNER is
'Owner of the object'
/
comment on column DBA_APPLY_DML_HANDLERS.OBJECT_NAME is
'Name of the object'
/
comment on column DBA_APPLY_DML_HANDLERS.OPERATION_NAME is
'Name of the DML operation'
/
comment on column DBA_APPLY_DML_HANDLERS.USER_PROCEDURE is
'Name of the DML handler specified by the user'
/
comment on column DBA_APPLY_DML_HANDLERS.ERROR_HANDLER is
'Y if the user procedure is the error handler, N if it is the DML handler'
/
comment on column DBA_APPLY_DML_HANDLERS.APPLY_DATABASE_LINK is
'For remote objects, name of database link pointing to remote database'
/
comment on column DBA_APPLY_DML_HANDLERS.APPLY_NAME is
'Name of the apply process for the given object'
/
comment on column DBA_APPLY_DML_HANDLERS.ASSEMBLE_LOBS is
'Y if LOBs should be assembled in DML or error handler'
/
create or replace public synonym DBA_APPLY_DML_HANDLERS
  for DBA_APPLY_DML_HANDLERS
/
grant select on DBA_APPLY_DML_HANDLERS to select_catalog_role
/

----------------------------------------------------------------------------

create or replace view ALL_APPLY_DML_HANDLERS
  (OBJECT_OWNER, OBJECT_NAME, OPERATION_NAME,
   USER_PROCEDURE, ERROR_HANDLER, APPLY_DATABASE_LINK, APPLY_NAME,
   ASSEMBLE_LOBS)
as
select h.object_owner, h.object_name, h.operation_name,
       h.user_procedure, h.error_handler, h.apply_database_link, h.apply_name,
       h.assemble_lobs
  from all_tables o, dba_apply_dml_handlers h
 where h.object_owner = o.owner
   and h.object_name = o.table_name
/

comment on table ALL_APPLY_DML_HANDLERS is
'Details about the dml handler on tables visible to the current user'
/
comment on column ALL_APPLY_DML_HANDLERS.OBJECT_OWNER is
'Owner of the object'
/
comment on column ALL_APPLY_DML_HANDLERS.OBJECT_NAME is
'Name of the object'
/
comment on column ALL_APPLY_DML_HANDLERS.OPERATION_NAME is
'Name of the DML operation'
/
comment on column ALL_APPLY_DML_HANDLERS.USER_PROCEDURE is
'Name of the DML handler specified by the user'
/
comment on column ALL_APPLY_DML_HANDLERS.ERROR_HANDLER is
'Y if the user procedure is the error handler, N if it is the DML handler'
/
comment on column ALL_APPLY_DML_HANDLERS.APPLY_DATABASE_LINK is
'For remote objects, name of database link pointing to remote database'
/
comment on column ALL_APPLY_DML_HANDLERS.APPLY_NAME is
'Name of the apply process for the given object'
/
comment on column ALL_APPLY_DML_HANDLERS.ASSEMBLE_LOBS is
'Y if LOBs should be assembled in DML or error handler'
/
create or replace public synonym ALL_APPLY_DML_HANDLERS
  for ALL_APPLY_DML_HANDLERS
/
grant select on ALL_APPLY_DML_HANDLERS to public with grant option
/

----------------------------------------------------------------------------

-- Private view select to all columns from streams$_apply_milestone
-- Used by export. Respective catalog views will select from this view.
create or replace view "_DBA_APPLY_MILESTONE"
as select 
  apply#, source_db_name, oldest_scn, commit_scn, synch_scn, epoch,
  processed_scn, apply_time, applied_message_create_time, spare1, start_scn,
  oldest_transaction_id
from sys.streams$_apply_milestone
/
grant select on "_DBA_APPLY_MILESTONE" to exp_full_database
/

-- Private view select to all columns from streams$_apply_progress
-- Used by export. Respective catalog views will select from this view.
create or replace view "_DBA_APPLY_PROGRESS"
as select 
  apply#, source_db_name, xidusn, xidslt, xidsqn, commit_scn, spare1
from sys.streams$_apply_progress
/
grant select on "_DBA_APPLY_PROGRESS" to exp_full_database
/

create or replace view DBA_APPLY_PROGRESS
  (APPLY_NAME, SOURCE_DATABASE, APPLIED_MESSAGE_NUMBER, OLDEST_MESSAGE_NUMBER,
   APPLY_TIME, APPLIED_MESSAGE_CREATE_TIME, OLDEST_TRANSACTION_ID)
as
select ap.apply_name, am.source_db_name, am.commit_scn, am.oldest_scn, 
       apply_time, applied_message_create_time, oldest_transaction_id
  from streams$_apply_process ap, "_DBA_APPLY_MILESTONE" am
 where ap.apply# = am.apply#
/

comment on table DBA_APPLY_PROGRESS is
'Information about the progress made by apply process'
/
comment on column DBA_APPLY_PROGRESS.APPLY_NAME is
'Name of the apply process'
/
comment on column DBA_APPLY_PROGRESS.SOURCE_DATABASE is
'Applying messages originating from this database'
/
comment on column DBA_APPLY_PROGRESS.APPLIED_MESSAGE_NUMBER is
'All messages before this number have been successfully applied'
/
comment on column DBA_APPLY_PROGRESS.OLDEST_MESSAGE_NUMBER is
'Earliest commit number of the transactions currently being applied'
/
comment on column DBA_APPLY_PROGRESS.APPLY_TIME is
'Time at which the message was applied'
/
comment on column DBA_APPLY_PROGRESS.APPLIED_MESSAGE_CREATE_TIME is
'Time at which the message to be applied was created'
/
comment on column DBA_APPLY_PROGRESS.OLDEST_TRANSACTION_ID is
'Earliest transaction id currently being applied'
/
create or replace public synonym DBA_APPLY_PROGRESS for DBA_APPLY_PROGRESS
/
grant select on DBA_APPLY_PROGRESS to select_catalog_role
/

----------------------------------------------------------------------------
create or replace view ALL_APPLY_PROGRESS
  (APPLY_NAME, SOURCE_DATABASE, APPLIED_MESSAGE_NUMBER, OLDEST_MESSAGE_NUMBER,
   APPLY_TIME, APPLIED_MESSAGE_CREATE_TIME, OLDEST_TRANSACTION_ID)
as
select ap.apply_name, ap.source_database, ap.applied_message_number, 
       ap.oldest_message_number, ap.apply_time, ap.applied_message_create_time,
       ap.oldest_transaction_id
  from dba_apply_progress ap, all_apply a
 where ap.apply_name = a.apply_name
/

comment on table ALL_APPLY_PROGRESS is
'Information about the progress made by the apply process that dequeues from the queue visible to the current user'
/
comment on column ALL_APPLY_PROGRESS.APPLY_NAME is
'Name of the apply process'
/
comment on column ALL_APPLY_PROGRESS.SOURCE_DATABASE is
'Applying messages originating from this database'
/
comment on column ALL_APPLY_PROGRESS.APPLIED_MESSAGE_NUMBER is
'All messages before this number have been successfully applied'
/
comment on column ALL_APPLY_PROGRESS.OLDEST_MESSAGE_NUMBER is
'Earliest commit number of the transactions currently being applied'
/
comment on column ALL_APPLY_PROGRESS.APPLY_TIME is
'Time at which the message was applied'
/
comment on column ALL_APPLY_PROGRESS.APPLIED_MESSAGE_CREATE_TIME is
'Time at which the message to be applied was created'
/
comment on column ALL_APPLY_PROGRESS.OLDEST_TRANSACTION_ID is
'Earliest transaction id currently being applied'
/
create or replace public synonym ALL_APPLY_PROGRESS for ALL_APPLY_PROGRESS
/
grant select on ALL_APPLY_PROGRESS to public with grant option
/

----------------------------------------------------------------------------

-- Private view select to all columns from apply$_error
-- Used by export. Respective catalog views will select from this view.
create or replace view "_DBA_APPLY_ERROR"
as select 
  local_transaction_id, source_transaction_id, source_database,
  queue_owner, queue_name, apply#, message_number, message_count,
  min_step_no, recipient_id, recipient_name, source_commit_scn,
  error_number, error_message, aq_transaction_id, error_creation_time,
  spare1, spare2, spare3
from sys.apply$_error
/
grant select on "_DBA_APPLY_ERROR" to exp_full_database
/

create or replace view DBA_APPLY_ERROR
  (APPLY_NAME, QUEUE_NAME, QUEUE_OWNER, LOCAL_TRANSACTION_ID,
   SOURCE_DATABASE, SOURCE_TRANSACTION_ID,
   SOURCE_COMMIT_SCN, MESSAGE_NUMBER, ERROR_NUMBER,
   ERROR_MESSAGE, RECIPIENT_ID, RECIPIENT_NAME, MESSAGE_COUNT,
   ERROR_CREATION_TIME)
as
select p.apply_name, e.queue_name, e.queue_owner, e.local_transaction_id,
       e.source_database, e.source_transaction_id,
       e.source_commit_scn, e.message_number, e.error_number,
       e.error_message, e.recipient_id, e.recipient_name, e.message_count,
       e.error_creation_time
  from "_DBA_APPLY_ERROR" e, sys.streams$_apply_process p
 where e.apply# = p.apply#(+)
/

comment on table DBA_APPLY_ERROR is
'Error transactions'
/
comment on column DBA_APPLY_ERROR.APPLY_NAME iS
'Name of the apply process at the local site which processed the transaction'
/
comment on column DBA_APPLY_ERROR.QUEUE_NAME is
'Name of the queue at the local site where the transaction came from'
/
comment on column DBA_APPLY_ERROR.QUEUE_OWNER is
'Owner of the queue at the local site where the transaction came from'
/
comment on column DBA_APPLY_ERROR.LOCAL_TRANSACTION_ID is
'Local transaction ID for the error creation transaction'
/
comment on column DBA_APPLY_ERROR.SOURCE_DATABASE is
'Database where the transaction originated'
/
comment on column DBA_APPLY_ERROR.SOURCE_TRANSACTION_ID is
'Original transaction ID at the source database'
/
comment on column DBA_APPLY_ERROR.SOURCE_COMMIT_SCN is
'Original commit SCN for the transaction at the source database'
/
comment on column DBA_APPLY_ERROR.MESSAGE_NUMBER is
'Identifier for the message in the transaction that raised an error'
/
comment on column DBA_APPLY_ERROR.ERROR_NUMBER is
'Error number'
/
comment on column DBA_APPLY_ERROR.ERROR_MESSAGE is
'Error message'
/
comment on column DBA_APPLY_ERROR.RECIPIENT_ID is
'User ID of the original recipient'
/
comment on column DBA_APPLY_ERROR.RECIPIENT_NAME is
'Name of the original recipient'
/
comment on column DBA_APPLY_ERROR.MESSAGE_COUNT is
'Total number of messages inside the error transaction'
/
comment on column DBA_APPLY_ERROR.ERROR_CREATION_TIME is
'The time that this error was created'
/
create or replace public synonym DBA_APPLY_ERROR for DBA_APPLY_ERROR
/
grant select on DBA_APPLY_ERROR to select_catalog_role
/

----------------------------------------------------------------------------
create or replace view ALL_APPLY_ERROR
  (APPLY_NAME, QUEUE_NAME, QUEUE_OWNER, LOCAL_TRANSACTION_ID,
   SOURCE_DATABASE, SOURCE_TRANSACTION_ID,
   SOURCE_COMMIT_SCN, MESSAGE_NUMBER, ERROR_NUMBER,
   ERROR_MESSAGE, RECIPIENT_ID, RECIPIENT_NAME, MESSAGE_COUNT, 
   ERROR_CREATION_TIME)
as (
select e.apply_name, e.queue_name, e.queue_owner, e.local_transaction_id,
       e.source_database, e.source_transaction_id,
       e.source_commit_scn, e.message_number, e.error_number,
       e.error_message, e.recipient_id, e.recipient_name, e.message_count,
       e.error_creation_time
  from dba_apply_error e, all_users u, all_queues q
 where e.recipient_id = u.user_id
   and q.name = e.queue_name
   and q.owner = e.queue_owner
union all
select e.apply_name, e.queue_name, e.queue_owner, e.local_transaction_id,
       e.source_database, e.source_transaction_id,
       e.source_commit_scn, e.message_number, e.error_number,
       e.error_message, e.recipient_id, e.recipient_name, e.message_count,
       e.error_creation_time
  from dba_apply_error e
 where e.recipient_id NOT IN (select user_id from dba_users))
/  

comment on table ALL_APPLY_ERROR is
'Error transactions that were generated after dequeuing from the queue visible to the current user'
/
comment on column ALL_APPLY_ERROR.APPLY_NAME iS
'Name of the apply process at the local site which processed the transaction'
/
comment on column ALL_APPLY_ERROR.QUEUE_NAME is
'Name of the queue at the local site where the transaction came from'
/
comment on column ALL_APPLY_ERROR.QUEUE_OWNER is
'Owner of the queue at the local site where the transaction came from'
/
comment on column ALL_APPLY_ERROR.LOCAL_TRANSACTION_ID is
'Local transaction ID for the error creation transaction'
/
comment on column ALL_APPLY_ERROR.SOURCE_DATABASE is
'Database where the transaction originated'
/
comment on column ALL_APPLY_ERROR.SOURCE_TRANSACTION_ID is
'Original transaction ID at the source database'
/
comment on column ALL_APPLY_ERROR.SOURCE_COMMIT_SCN is
'Original commit SCN for the transaction at the source database'
/
comment on column ALL_APPLY_ERROR.MESSAGE_NUMBER is
'Identifier for the message in the transaction that raised an error'
/
comment on column ALL_APPLY_ERROR.ERROR_NUMBER is
'Error number'
/
comment on column ALL_APPLY_ERROR.ERROR_MESSAGE is
'Error message'
/
comment on column ALL_APPLY_ERROR.RECIPIENT_ID is
'User ID of the original recipient'
/
comment on column ALL_APPLY_ERROR.RECIPIENT_NAME is
'Name of the original recipient'
/
comment on column ALL_APPLY_ERROR.MESSAGE_COUNT is
'Total number of messages inside the error transaction'
/
comment on column ALL_APPLY_ERROR.ERROR_CREATION_TIME is
'The time that this error occurred'
/
create or replace public synonym ALL_APPLY_ERROR for ALL_APPLY_ERROR
/
grant select on ALL_APPLY_ERROR to public with grant option
/

----------------------------------------------------------------------------
-- Private view select to all columns from apply$_error_txn
-- Used by export.
create or replace view "_DBA_APPLY_ERROR_TXN"
as select 
  local_transaction_id, txn_message_number, msg_id
from sys.apply$_error_txn
/

grant select on "_DBA_APPLY_ERROR_TXN" to exp_full_database
/

----------------------------------------------------------------------------
-- view to show where events satisfying the corresponding rules in the apply
-- rule set will be enqueued.
----------------------------------------------------------------------------

create or replace view DBA_APPLY_ENQUEUE
(RULE_OWNER, RULE_NAME, DESTINATION_QUEUE_NAME) as
select r.rule_owner, r.rule_name, sys.anydata.AccessVarchar2(ctx.nvn_value)
from DBA_RULES r, table(r.rule_action_context.actx_list) ctx
where ctx.nvn_name = 'APPLY$_ENQUEUE';

comment on table DBA_APPLY_ENQUEUE is
'Details about the apply enqueue action'
/
comment on column DBA_APPLY_ENQUEUE.RULE_OWNER is
'Owner of the rule'
/
comment on column DBA_APPLY_ENQUEUE.RULE_NAME is
'Name of the rule'
/
comment on column DBA_APPLY_ENQUEUE.DESTINATION_QUEUE_NAME is
'Name of the queue where events satisfying the rule will be enqueued'
/
create or replace public synonym DBA_APPLY_ENQUEUE for DBA_APPLY_ENQUEUE
/
grant select on DBA_APPLY_ENQUEUE to select_catalog_role
/

create or replace view ALL_APPLY_ENQUEUE as
select e.*
from dba_apply_enqueue e, ALL_RULES r, ALL_QUEUES aq
where e.rule_owner = r.rule_owner and e.rule_name = r.rule_name
  and e.destination_queue_name = '"'||aq.owner||'"' ||'.'|| '"'||aq.name||'"';

comment on table ALL_APPLY_ENQUEUE is
'Details about the apply enqueue action for user accessible rules where the destination queue exists and is visible to the user'
/
comment on column ALL_APPLY_ENQUEUE.RULE_OWNER is
'Owner of the rule'
/
comment on column ALL_APPLY_ENQUEUE.RULE_NAME is
'Name of the rule'
/
comment on column ALL_APPLY_ENQUEUE.DESTINATION_QUEUE_NAME is
'Name of the queue where events satisfying the rule will be enqueued'
/
create or replace public synonym ALL_APPLY_ENQUEUE for ALL_APPLY_ENQUEUE
/
grant select on ALL_APPLY_ENQUEUE to public with grant option
/

----------------------------------------------------------------------------
-- view to show rules with a value for APPLY$_EXECUTE in the action context.
----------------------------------------------------------------------------

create or replace view DBA_APPLY_EXECUTE
(RULE_OWNER, RULE_NAME, EXECUTE_EVENT) as
select r.rule_owner, r.rule_name,
  decode(sys.anydata.AccessVarchar2(ctx.nvn_value), 'NO', 'NO', NULL)
from DBA_RULES r, table(r.rule_action_context.actx_list) ctx
where ctx.nvn_name = 'APPLY$_EXECUTE';

comment on table DBA_APPLY_EXECUTE is
'Details about the apply execute action'
/
comment on column DBA_APPLY_EXECUTE.RULE_OWNER is
'Owner of the rule'
/
comment on column DBA_APPLY_EXECUTE.RULE_NAME is
'Name of the rule'
/
comment on column DBA_APPLY_EXECUTE.EXECUTE_EVENT is
'Whether the event satisfying the rule is executed'
/
create or replace public synonym DBA_APPLY_EXECUTE for DBA_APPLY_EXECUTE
/
grant select on DBA_APPLY_EXECUTE to select_catalog_role
/

create or replace view ALL_APPLY_EXECUTE as
select e.*
from dba_apply_execute e, ALL_RULES r
where e.rule_owner = r.rule_owner and e.rule_name = r.rule_name;

comment on table ALL_APPLY_EXECUTE is
'Details about the apply execute action for all rules visible to the user'
/
comment on column ALL_APPLY_EXECUTE.RULE_OWNER is
'Owner of the rule'
/
comment on column ALL_APPLY_EXECUTE.RULE_NAME is
'Name of the rule'
/
comment on column ALL_APPLY_EXECUTE.EXECUTE_EVENT is
'Whether the event satisfying the rule is executed'
/
create or replace public synonym ALL_APPLY_EXECUTE for ALL_APPLY_EXECUTE
/
grant select on ALL_APPLY_EXECUTE to public with grant option
/


-------------------------------------------
-- apply spilling views
-------------------------------------------

-- internal streams apply spilled transactions view
create or replace view "_DBA_APPLY_SPILL_TXN"
  (APPLY_NAME, XIDUSN, XIDSLT, XIDSQN, FIRST_SCN, MESSAGE_COUNT,
   FIRST_MESSAGE_CREATE_TIME, SPILL_CREATION_TIME, SPILL_FLAGS)
as
select applyname, xidusn, xidslt, xidsqn, first_scn, spillcount,
       first_message_create_time, spill_creation_time, spill_flags
  from sys.streams$_apply_spill_txn
/
grant select on "_DBA_APPLY_SPILL_TXN" to exp_full_database
/

-- streams apply spilled transactions view
create or replace view DBA_APPLY_SPILL_TXN
  (APPLY_NAME, XIDUSN, XIDSLT, XIDSQN, FIRST_SCN, MESSAGE_COUNT,
   FIRST_MESSAGE_CREATE_TIME, SPILL_CREATION_TIME)
as
select apply_name, xidusn, xidslt, xidsqn, first_scn, message_count,
       first_message_create_time, spill_creation_time
  from "_DBA_APPLY_SPILL_TXN"
  where bitand(spill_flags, 4) = 0
/

comment on table DBA_APPLY_SPILL_TXN is
'Streams apply spilled transactions info'
/
comment on column DBA_APPLY_SPILL_TXN.APPLY_NAME is
'Name of the apply that spilled the message'
/
comment on column DBA_APPLY_SPILL_TXN.XIDUSN is
'Transaction ID undo segment number'
/
comment on column DBA_APPLY_SPILL_TXN.XIDSLT is
'Transaction ID slot number'
/
comment on column DBA_APPLY_SPILL_TXN.XIDSQN is
'Transaction ID sequence number'
/
comment on column DBA_APPLY_SPILL_TXN.FIRST_SCN is
'SCN of first message in this transaction'
/
comment on column DBA_APPLY_SPILL_TXN.MESSAGE_COUNT is
'Number of messages spilled for this transaction'
/
comment on column DBA_APPLY_SPILL_TXN.FIRST_MESSAGE_CREATE_TIME is
'Source creation time of the first message in this transaction'
/
comment on column DBA_APPLY_SPILL_TXN.SPILL_CREATION_TIME is
'Time first message was spilled'
/
create or replace public synonym DBA_APPLY_SPILL_TXN
  for DBA_APPLY_SPILL_TXN
/
grant select on DBA_APPLY_SPILL_TXN to select_catalog_role
/

----------------------------------------------------------------------------

create or replace view GV_$STREAMS_APPLY_COORDINATOR
as
select * from gv$streams_apply_coordinator;
create or replace public synonym GV$STREAMS_APPLY_COORDINATOR 
  for gv_$streams_apply_coordinator;
grant select on GV_$STREAMS_APPLY_COORDINATOR to select_catalog_role;

----------------------------------------------------------------------------

create or replace view V_$STREAMS_APPLY_COORDINATOR
as
select * from v$streams_apply_coordinator;
create or replace public synonym V$STREAMS_APPLY_COORDINATOR 
  for v_$streams_apply_coordinator;
grant select on V_$STREAMS_APPLY_COORDINATOR to select_catalog_role;

----------------------------------------------------------------------------

create or replace view GV_$STREAMS_APPLY_SERVER
as
select * from gv$streams_apply_server;
create or replace public synonym GV$STREAMS_APPLY_SERVER 
  for gv_$streams_apply_server;
grant select on GV_$STREAMS_APPLY_SERVER to select_catalog_role;

----------------------------------------------------------------------------

create or replace view V_$STREAMS_APPLY_SERVER
as
select * from v$streams_apply_server;
create or replace public synonym V$STREAMS_APPLY_SERVER 
  for v_$streams_apply_server;
grant select on V_$STREAMS_APPLY_SERVER to select_catalog_role;

----------------------------------------------------------------------------

create or replace view GV_$STREAMS_APPLY_READER
as
select * from gv$streams_apply_reader;
create or replace public synonym GV$STREAMS_APPLY_READER 
  for gv_$streams_apply_reader;
grant select on GV_$STREAMS_APPLY_READER to select_catalog_role;

----------------------------------------------------------------------------

create or replace view V_$STREAMS_APPLY_READER
as
select * from v$streams_apply_reader;
create or replace public synonym V$STREAMS_APPLY_READER 
  for v_$streams_apply_reader;
grant select on V_$STREAMS_APPLY_READER to select_catalog_role;

-- ------------------------------------------------------------------------
-- Bug 2265160: Alter initrans, pctfree, freelists values for the 
-- streams$_apply_progress table. 
-- ------------------------------------------------------------------------
DECLARE
  block_size   INTEGER;
  free_lists   INTEGER;
  initrans     INTEGER;
  atb_stmt     VARCHAR2(500);
  done         BOOLEAN      := FALSE;
BEGIN

  SELECT tbs.block_size INTO block_size
  FROM dba_tables tbl, dba_tablespaces tbs
  WHERE tbl.owner = 'SYS' AND
        tbl.table_name = 'STREAMS$_APPLY_PROGRESS' AND
        tbl.tablespace_name = tbs.tablespace_name;

  -- Compute freelists
  -- Formula for computing freelists = 0.25*blocksize/25
  -- 25 is the overhead of each freelist. Using a quarter of (blocksize/25) 
  -- is a good and conservative estimate. 
  free_lists := 0.25*block_size/25;

  -- Since we allow only inserts into this table, set initrans to the number
  -- of rows that could be inserted into a block. Based on some analysis, this
  -- value turned out to be around 30 for a 2k block size. 
  initrans := 30*block_size/2048;

  -- Restrict max value of initrans to 128
  IF initrans > 128 THEN
    initrans := 128;
  END IF;

  -- PCTFREE = 0 since there are no updates to this table.
  WHILE NOT done LOOP
    BEGIN
      atb_stmt := 'ALTER TABLE sys.streams$_apply_progress INITRANS ' || 
                   initrans || ' PCTFREE 0 STORAGE (FREELISTS ' || 
                   free_lists || ')';
      EXECUTE IMMEDIATE atb_stmt;
      done := TRUE;
    EXCEPTION WHEN OTHERS THEN
      IF sqlcode = -1590 THEN
        IF free_lists < 20 THEN
          done := TRUE;
        ELSE
          free_lists := free_lists-2;
        END IF;
      ELSE
        RAISE;
      END IF;
    END;
  END LOOP;

EXCEPTION WHEN OTHERS THEN
  -- Do not raise exceptions in CAT files
  NULL;
END;
/
