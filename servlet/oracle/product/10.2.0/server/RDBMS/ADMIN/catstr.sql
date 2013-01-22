Rem
Rem $Header: catstr.sql 09-mar-2005.14:12:08 elu Exp $
Rem
Rem catstr.sql
Rem
Rem Copyright (c) 2001, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catstr.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    elu         03/09/05 - move apply spilling to catapp.sql 
Rem    alakshmi    03/07/05 - recoverable script views 
Rem    alakshmi    02/28/05 - error recovery for maintain_ apis
Rem    nshodhan    03/04/05 - add v$streams_transaction 
Rem    liwong      02/07/05 - Include custom_type 
Rem    htran       02/01/05 - dba_apply_spill_txn view
Rem    alakshmi    01/28/05 - add streams$_apply_spill_msgs_part 
Rem    htran       01/19/05 - apply spill internal view
Rem    htran       01/06/05 - add scn column for spilled messages
Rem    elu         01/05/05 - streams apply spilling 
Rem    nshodhan    11/24/04 - mark encrypted columns unsupported 
Rem    htran       07/20/04 - create streams$_anydata_array type
Rem    bpwang      06/03/04 - streams$internal_transform.column_type to number
Rem    ksurlake    06/01/04 - reg$ has canonicalized subname
Rem    nshodhan    05/24/04 - support IOTs w/ lobs and overflow 
Rem    bpwang      03/11/04 - Adding internal lcr transformation support 
Rem    htran       03/03/04 - load catfgr.sql
Rem    htran       12/01/03 - change message_consumers for anydata context 
Rem    bpwang      10/24/03 - Bug 2984150: Support urowid type 
Rem    wesmith     07/29/03 - view DBA_STREAMS_MESSAGE_CONSUMERS: 
Rem                           remove join to AQ tables
Rem    nshodhan    08/11/03 - bug : add auto_filtered column
Rem    bpwang      07/15/03 - bug 2771770:  add streams$nv_node and nv_array
Rem    wesmith     06/13/03 - allow MV tables in _DBA_STREAMS_UNSUPPORTED_10_1
Rem    elu         05/27/03 - decode for subsetting_operation
Rem    bpwang      05/19/03 - add "_DBA_STREAMS_QUEUES"
Rem    elu         04/29/03 - fix all_streams_message_consumers 
Rem    nshodhan    04/25/03 - filter out CTXSYS objects from strms unsup. view
Rem    elu         04/22/03 - add dba_streams_rules
Rem    nshodhan    04/22/03 - make context indices unsupported
Rem    nshodhan    04/01/03 - Add support for streams_unsupported bit
Rem    bpwang      02/17/03 - Bug 2785745:  Dropping capture and apply 
Rem                           processes when drop user cascade called on 
Rem                           capture or apply user
Rem    liwong      02/14/03 - Bug 2804918
Rem    liwong      01/23/03 - Add dba_streams_unsupported and its siblings
Rem    htran       01/15/03 - add LOCAL_PRIVILEGES and ACCESS_FROM_REMOTE
Rem                           columns to DBA_STREAMS_ADMINISTRATOR.
Rem                           add _DBA_STREAMS_PRIVILEGED_USER view.
Rem    liwong      12/25/02 - Fix dba_streams_message_consumers
Rem    liwong      12/23/02 - Support Dequeue in dba_streams_table_rules
Rem    apadmana    12/06/02 - Add view for exporting streams$_message_rules
Rem    liwong      10/23/02 - Modify dba_streams_message_consumers
Rem    apadmana    10/18/02 - Add view dba_streams_message_rules
Rem    bpwang      09/27/02 - Adding DBA_STREAMS_TRANSFORM_FUNCTION and 
Rem                         -  ALL_STREAMS_TRANSFORM_FUNCTION views
Rem    apadmana    09/27/02 - Add view dba_streams_administrator
Rem    liwong      07/16/02 - Fix all_streams_global_rules
Rem    sbalaram    06/17/02 - Fix bug 2395423
Rem    sbalaram    01/25/02 - Fix all_streams_*_rules views
Rem    wesmith     01/09/02 - Streams export/import support
Rem    sbalaram    12/10/01 - use create or replace synonym
Rem    sbalaram    12/04/01 - decode subsetting_operation
Rem    sbalaram    11/16/01 - Fix comments on some views
Rem    alakshmi    11/08/01 - Merged alakshmi_apicleanup
Rem    sbalaram    10/29/01 - add views
Rem    apadmana    10/26/01 - Created
Rem

@@catcap
@@catapp
@@catprp
@@catfgr

-- This cannot be placed in sql.bsq because of a sys.anydata column
rem streams$_internal_transform is populated by APIs in dbms_streams_adm
create table streams$_internal_transform
(
  rule_owner           varchar2(30) not null,                  /* rule owner */
  rule_name            varchar2(30) not null,                   /* rule name */
  declarative_type     number,                  /* The type of the transform */
  from_schema_name     varchar2(30),                      /* old schema name */
  to_schema_name       varchar2(30),                      /* new schema name */
  from_table_name      varchar2(30),                       /* old table name */
  to_table_name        varchar2(30),                       /* new table name */
  schema_name          varchar2(30),                          /* schema name */
  table_name           varchar2(30),                           /* table name */
  from_column_name     varchar2(4000),                    /* old column name */
  to_column_name       varchar2(4000),                    /* new column name */
  column_name          varchar2(4000),                        /* column name */
  column_value         sys.anydata,                  /* default column value */
  column_type          number,                                /* column type */
  column_function      varchar2(30),                 /* column function name */
  value_type           number,     /* to transform old, new, or both columns */
  step_number          number,                               /* order to run */
  precedence           number,          /* order to run for same step number */
  spare1               number,
  spare2               number,
  spare3               varchar2(4000)
)
/
create index i_streams_internal_transform1 on
  streams$_internal_transform(rule_owner, rule_name)
/

-------------------------------------------------------------------------------
-- Views on streams tables
-------------------------------------------------------------------------------
Rem Views on streams$_process_params

REM streams$_rule_name_s sequence is used to generate rule names for 
REM automatic creation of rule names.

CREATE SEQUENCE streams$_rule_name_s START WITH 1 NOCACHE
/

-------------------------------------------------------------------------------
-- Views on streams message consumers
-------------------------------------------------------------------------------

-- Private view select to all columns from streams$_message_consumers.
-- Used by export. Respective catalog views will select from this view.
create or replace view "_DBA_STREAMS_MESSAGE_CONSUMERS"
as select * from sys.streams$_message_consumers
/
grant select on "_DBA_STREAMS_MESSAGE_CONSUMERS" to exp_full_database
/

-- Private view to list information about message notifications associated
-- with Streams message consumers. This view is used by export.
create or replace view "_DBA_STREAMS_MSG_NOTIFICATIONS"
  (STREAMS_NAME, QUEUE_NAME, QUEUE_OWNER, RULE_SET_NAME, RULE_SET_OWNER,
   NEGATIVE_RULE_SET_NAME, NEGATIVE_RULE_SET_OWNER, NOTIFICATION_TYPE,
   NOTIFICATION_ACTION, USER_CONTEXT, CONTEXT_SIZE, ANY_CONTEXT, CONTEXT_TYPE)
as
select c.streams_name, c.queue_name, c.queue_owner, c.rset_name, c.rset_owner,
       c.neg_rset_name, c.neg_rset_owner,
       decode(UPPER(substr(r.location_name,1,instr(r.location_name,'://') -1)),
              'PLSQL', 'PROCEDURE',
              'MAILTO', 'MAIL',
              'HTTP', 'HTTP'),
       substr(r.location_name, instr(r.location_name, '://') + 3),
       r.user_context, r.context_size, r.any_context, r.context_type
  from sys."_DBA_STREAMS_MESSAGE_CONSUMERS" c, sys.reg$ r
 where '"' ||c.queue_owner||'"."'||c.queue_name||'":"'||c.streams_name || '"'
       = r.subscription_name (+) 
   and NVL(r.namespace, 1) = 1
/
grant select on  "_DBA_STREAMS_MSG_NOTIFICATIONS" to exp_full_database
/

create or replace view DBA_STREAMS_MESSAGE_CONSUMERS
  (STREAMS_NAME, QUEUE_NAME, QUEUE_OWNER, RULE_SET_NAME, RULE_SET_OWNER,
   NEGATIVE_RULE_SET_NAME, NEGATIVE_RULE_SET_OWNER, NOTIFICATION_TYPE,
   NOTIFICATION_ACTION, NOTIFICATION_CONTEXT)
as
select streams_name, queue_name, queue_owner, rule_set_name, rule_set_owner,
       negative_rule_set_name, negative_rule_set_owner, notification_type,
       notification_action,
       decode(context_type,
              0, sys.anydata.ConvertRaw(user_context),
              1, any_context)
  from sys."_DBA_STREAMS_MSG_NOTIFICATIONS"
/

comment on table DBA_STREAMS_MESSAGE_CONSUMERS is
'Streams messaging consumers'
/
comment on column DBA_STREAMS_MESSAGE_CONSUMERS.STREAMS_NAME is
'Name of the consumer'
/
comment on column DBA_STREAMS_MESSAGE_CONSUMERS.QUEUE_NAME is
'Name of the queue'
/
comment on column DBA_STREAMS_MESSAGE_CONSUMERS.QUEUE_OWNER is
'Owner of the queue'
/
comment on column DBA_STREAMS_MESSAGE_CONSUMERS.RULE_SET_NAME is
'Name of the rule set'
/
comment on column DBA_STREAMS_MESSAGE_CONSUMERS.RULE_SET_OWNER is
'Owner of the rule set'
/
comment on column DBA_STREAMS_MESSAGE_CONSUMERS.NEGATIVE_RULE_SET_NAME is
'Name of the negative rule set'
/
comment on column DBA_STREAMS_MESSAGE_CONSUMERS.NEGATIVE_RULE_SET_OWNER is
'Owner of the negative rule set'
/
comment on column DBA_STREAMS_MESSAGE_CONSUMERS.NOTIFICATION_TYPE is
'Type of notification action: plsql/mailto/http'
/
comment on column DBA_STREAMS_MESSAGE_CONSUMERS.NOTIFICATION_ACTION is
'Notification action'
/
comment on column DBA_STREAMS_MESSAGE_CONSUMERS.NOTIFICATION_CONTEXT is
'Context for the notification action'
/
create or replace public synonym DBA_STREAMS_MESSAGE_CONSUMERS
  for DBA_STREAMS_MESSAGE_CONSUMERS
/
grant select on DBA_STREAMS_MESSAGE_CONSUMERS to select_catalog_role
/

----------------------------------------------------------------------------

-- View of streams message consumers
create or replace view ALL_STREAMS_MESSAGE_CONSUMERS
as
select c.*
  from dba_streams_message_consumers c, all_queues q
 where c.queue_name = q.name
   and c.queue_owner = q.owner
   and ((c.rule_set_owner is null and c.rule_set_name is null) or
        ((c.rule_set_owner, c.rule_set_name) in 
          (select r.rule_set_owner, r.rule_set_name
             from all_rule_sets r)))
   and ((c.negative_rule_set_owner is null and 
         c.negative_rule_set_name is null) or
        ((c.negative_rule_set_owner, c.negative_rule_set_name) in 
          (select r.rule_set_owner, r.rule_set_name 
             from all_rule_sets r)))
/

comment on table ALL_STREAMS_MESSAGE_CONSUMERS is
'Streams messaging consumers visible to the current user'
/
comment on column ALL_STREAMS_MESSAGE_CONSUMERS.STREAMS_NAME is
'Name of the consumer'
/
comment on column ALL_STREAMS_MESSAGE_CONSUMERS.QUEUE_NAME is
'Name of the queue'
/
comment on column ALL_STREAMS_MESSAGE_CONSUMERS.QUEUE_OWNER is
'Owner of the queue'
/
comment on column ALL_STREAMS_MESSAGE_CONSUMERS.RULE_SET_NAME is
'Name of the rule set'
/
comment on column ALL_STREAMS_MESSAGE_CONSUMERS.RULE_SET_OWNER is
'Owner of the rule set'
/
comment on column ALL_STREAMS_MESSAGE_CONSUMERS.NEGATIVE_RULE_SET_NAME is
'Name of the negative rule set'
/
comment on column ALL_STREAMS_MESSAGE_CONSUMERS.NEGATIVE_RULE_SET_OWNER is
'Owner of the negative rule set'
/
comment on column DBA_STREAMS_MESSAGE_CONSUMERS.NOTIFICATION_TYPE is
'Type of notification action: plsql/mailto/http'
/
comment on column ALL_STREAMS_MESSAGE_CONSUMERS.NOTIFICATION_ACTION is
'Notification action'
/
comment on column ALL_STREAMS_MESSAGE_CONSUMERS.NOTIFICATION_CONTEXT is
'Context for the notification action'
/
create or replace public synonym ALL_STREAMS_MESSAGE_CONSUMERS
  for ALL_STREAMS_MESSAGE_CONSUMERS
/
grant select on ALL_STREAMS_MESSAGE_CONSUMERS to public with grant option
/

----------------------------------------------------------------------------
-- Internal unified views of streams processes
----------------------------------------------------------------------------

-- View of all streams processes and rule sets. A process will be listed
-- once for each rule set (in other words, a process will be listed twice
-- if it has both a positive and negative rule set).
-- Streams type is represented as a number (capture = 1, propagation = 2,
-- apply = 3, dequeue = 4) to simplify joins with streams$_rules and 
-- streams$_message_rules.
create or replace view "_DBA_STREAMS_PROCESSES"(
  streams_type, streams_name, rule_set_owner, rule_set_name, rule_set_type)
as
select 1 streams_type, c.capture_name streams_name, 
       c.ruleset_owner, c.ruleset_name, 'POSITIVE'
  from streams$_capture_process c
union all
select 1 streams_type, c.capture_name streams_name, 
       c.negative_ruleset_owner, c.negative_ruleset_name, 'NEGATIVE'
  from streams$_capture_process c
union all
select 2 streams_type, p.propagation_name streams_name, 
       p.ruleset_schema, p.ruleset, 'POSITIVE'
  from streams$_propagation_process p
union all
select 2 streams_type, p.propagation_name streams_name, 
       p.negative_ruleset_schema, p.negative_ruleset, 'NEGATIVE'
  from streams$_propagation_process p
union all
select 3 streams_type, a.apply_name streams_name, 
       a.ruleset_owner, a.ruleset_name, 'POSITIVE'
  from streams$_apply_process a
union all
select 3 streams_type, a.apply_name streams_name, 
       a.negative_ruleset_owner, a.negative_ruleset_name, 'NEGATIVE'
  from streams$_apply_process a
union all
select 4 streams_type, d.streams_name, 
       d.rset_owner, d.rset_name, 'POSITIVE'
  from streams$_message_consumers d
union all
select 4 streams_type, d.streams_name, 
       d.neg_rset_owner, d.neg_rset_name, 'NEGATIVE'
  from streams$_message_consumers d
/

-- View of all streams processes
create or replace view "_ALL_STREAMS_PROCESSES"(
  streams_type, streams_name, rule_set_owner, rule_set_name, 
  negative_rule_set_owner, negative_rule_set_name) as
select 'CAPTURE', capture_name, rule_set_owner, rule_set_name, 
       negative_rule_set_owner, negative_rule_set_name
  from all_capture
union all
select 'APPLY', apply_name, rule_set_owner, rule_set_name, 
       negative_rule_set_owner, negative_rule_set_name
  from all_apply
union all
select 'PROPAGATION', propagation_name, rule_set_owner, rule_set_name, 
       negative_rule_set_owner, negative_rule_set_name
  from all_propagation
union all
select 'DEQUEUE', streams_name, rule_set_owner, rule_set_name, 
       negative_rule_set_owner, negative_rule_set_name
  from all_streams_message_consumers
/

----------------------------------------------------------------------------
-- Internal unified views of streams queues
----------------------------------------------------------------------------

-- View of all streams queues
create or replace view "_DBA_STREAMS_QUEUES"(queue_owner, queue_name)
as
select c.queue_owner queue_owner, c.queue_name queue_name
  from streams$_capture_process c
union 
select p.source_queue_schema queue_owner, p.source_queue queue_name
  from streams$_propagation_process p
union 
select a.queue_owner queue_owner, a.queue_name queue_name
  from streams$_apply_process a
union 
select d.queue_owner queue_owner, d.queue_name queue_name
  from streams$_message_consumers d
/

----------------------------------------------------------------------------
-- Views on streams$_rules table
----------------------------------------------------------------------------

-- Private view select to all columns from streams$_rules
-- Used by export. Respective catalog views will select from this view.
create or replace view "_DBA_STREAMS_RULES"
as select 
  streams_name, streams_type, rule_type, include_tagged_lcr, 
  source_database, rule_owner, rule_name, rule_condition, dml_condition, 
  subsetting_operation, schema_name, object_name, object_type,
  spare1, spare2, spare3
from sys.streams$_rules
/
grant select on "_DBA_STREAMS_RULES" to exp_full_database
/

create or replace view DBA_STREAMS_GLOBAL_RULES
  (STREAMS_NAME, STREAMS_TYPE, RULE_TYPE, INCLUDE_TAGGED_LCR,
   SOURCE_DATABASE, RULE_NAME, RULE_OWNER, RULE_CONDITION) 
as
select streams_name, decode(streams_type, 1, 'CAPTURE',
                                          2, 'PROPAGATION',
                                          3, 'APPLY',
                                          4, 'DEQUEUE', 'UNDEFINED'),
       decode(rule_type, 1, 'DML',
                         2, 'DDL', 'UNKNOWN'),
       decode(include_tagged_lcr, 0, 'NO',
                                  1, 'YES'),
       source_database, rule_name, rule_owner, rule_condition
  from "_DBA_STREAMS_RULES"
 where object_type = 3
/

comment on table DBA_STREAMS_GLOBAL_RULES is
'Global rules created by streams administrative APIs'
/
comment on column DBA_STREAMS_GLOBAL_RULES.STREAMS_NAME is
'Name of the streams process: capture/propagation/apply process'
/
comment on column DBA_STREAMS_GLOBAL_RULES.STREAMS_TYPE is
'Type of the streams process: CAPTURE, PROPAGATION or APPLY'
/
comment on column DBA_STREAMS_GLOBAL_RULES.RULE_TYPE is
'Type of rule: DML or DDL'
/
comment on column DBA_STREAMS_GLOBAL_RULES.INCLUDE_TAGGED_LCR is
'Whether or not to include tagged LCR'
/
comment on column DBA_STREAMS_GLOBAL_RULES.SOURCE_DATABASE is
'Name of the database where the LCRs originated'
/
comment on column DBA_STREAMS_GLOBAL_RULES.RULE_OWNER is
'Owner of the rule'
/
comment on column DBA_STREAMS_GLOBAL_RULES.RULE_NAME is
'Name of the rule to be applied'
/
comment on column DBA_STREAMS_GLOBAL_RULES.RULE_CONDITION is
'Generated rule condition evaluated by the rules engine'
/
create or replace public synonym DBA_STREAMS_GLOBAL_RULES
  for DBA_STREAMS_GLOBAL_RULES
/
grant select on DBA_STREAMS_GLOBAL_RULES to select_catalog_role
/

----------------------------------------------------------------------------

create or replace view ALL_STREAMS_GLOBAL_RULES
as
select r.streams_name, r.streams_type, r.rule_type, r.include_tagged_lcr,
       r.source_database, r.rule_name, r.rule_owner, r.rule_condition
 from  dba_streams_global_rules r, "_ALL_STREAMS_PROCESSES" p, all_rules ar
 where r.streams_name = p.streams_name
   and r.streams_type = p.streams_type
   and ar.rule_owner = r.rule_owner
   and ar.rule_name = r.rule_name
/

comment on table ALL_STREAMS_GLOBAL_RULES is
'Global rules created on the streams capture/apply/propagation process that interact with the queue visible to the current user'
/
comment on column ALL_STREAMS_GLOBAL_RULES.STREAMS_NAME is
'Name of the streams process: capture/propagation/apply process'
/
comment on column ALL_STREAMS_GLOBAL_RULES.STREAMS_TYPE is
'Type of the streams process: CAPTURE, PROPAGATION or APPLY'
/
comment on column ALL_STREAMS_GLOBAL_RULES.RULE_TYPE is
'Type of rule: DML or DDL'
/
comment on column ALL_STREAMS_GLOBAL_RULES.INCLUDE_TAGGED_LCR is
'Whether or not to include tagged LCR'
/
comment on column ALL_STREAMS_GLOBAL_RULES.SOURCE_DATABASE is
'Name of the database where the LCRs originated'
/
comment on column ALL_STREAMS_GLOBAL_RULES.RULE_NAME is
'Name of the rule to be applied'
/
comment on column ALL_STREAMS_GLOBAL_RULES.RULE_OWNER is
'Owner of the rule'
/
comment on column ALL_STREAMS_GLOBAL_RULES.RULE_CONDITION is
'Generated rule condition evaluated by the rules engine'
/
create or replace public synonym ALL_STREAMS_GLOBAL_RULES
  for ALL_STREAMS_GLOBAL_RULES
/
grant select on ALL_STREAMS_GLOBAL_RULES to public with grant option
/

----------------------------------------------------------------------------

create or replace view DBA_STREAMS_SCHEMA_RULES
  (STREAMS_NAME, STREAMS_TYPE, SCHEMA_NAME, RULE_TYPE,
   INCLUDE_TAGGED_LCR, SOURCE_DATABASE, RULE_NAME, RULE_OWNER, RULE_CONDITION)
as
select streams_name, decode(streams_type, 1, 'CAPTURE',
                                          2, 'PROPAGATION',
                                          3, 'APPLY',
                                          4, 'DEQUEUE', 'UNDEFINED'),
       schema_name, decode(rule_type, 1, 'DML',
                                      2, 'DDL', 'UNKNOWN'),
       decode(include_tagged_lcr, 0, 'NO',
                                  1, 'YES'),
       source_database, rule_name, rule_owner, rule_condition
  from "_DBA_STREAMS_RULES"
 where object_type = 2
/

comment on table DBA_STREAMS_SCHEMA_RULES is
'Schema rules created by streams administrative APIs'
/
comment on column DBA_STREAMS_SCHEMA_RULES.STREAMS_NAME is
'Name of the streams process: capture/propagation/apply process'
/
comment on column DBA_STREAMS_SCHEMA_RULES.STREAMS_TYPE is
'Type of the streams process: CAPTURE, PROPAGATION or APPLY'
/
comment on column DBA_STREAMS_SCHEMA_RULES.SCHEMA_NAME is
'Name of the schema selected by this rule'
/
comment on column DBA_STREAMS_SCHEMA_RULES.RULE_TYPE is
'Type of rule: DML or DDL'
/
comment on column DBA_STREAMS_SCHEMA_RULES.INCLUDE_TAGGED_LCR is
'Whether or not to include tagged LCR'
/
comment on column DBA_STREAMS_SCHEMA_RULES.SOURCE_DATABASE is
'Name of the database where the LCRs originated'
/
comment on column DBA_STREAMS_SCHEMA_RULES.RULE_NAME is
'Name of the rule to be applied'
/
comment on column DBA_STREAMS_SCHEMA_RULES.RULE_OWNER is
'Owner of the rule'
/
comment on column DBA_STREAMS_SCHEMA_RULES.RULE_CONDITION is
'Generated rule condition evaluated by the rules engine'
/
create or replace public synonym DBA_STREAMS_SCHEMA_RULES
  for DBA_STREAMS_SCHEMA_RULES
/
grant select on DBA_STREAMS_SCHEMA_RULES to select_catalog_role
/

----------------------------------------------------------------------------

create or replace view ALL_STREAMS_SCHEMA_RULES
as
select sr.streams_name, sr.streams_type, sr.schema_name, sr.rule_type,
       sr.include_tagged_lcr, sr.source_database, sr.rule_name, sr.rule_owner,
       sr.rule_condition
  from dba_streams_schema_rules sr, "_ALL_STREAMS_PROCESSES" p, all_rules r
 where sr.rule_owner = r.rule_owner
   and sr.rule_name = r.rule_name
   and sr.streams_name = p.streams_name
   and sr.streams_type = p.streams_type
/

comment on table ALL_STREAMS_SCHEMA_RULES is
'Rules created by streams administrative APIs on all user schemas'
/
comment on column ALL_STREAMS_SCHEMA_RULES.STREAMS_NAME is
'Name of the streams process: capture/propagation/apply process'
/
comment on column ALL_STREAMS_SCHEMA_RULES.STREAMS_TYPE is
'Type of the streams process: CAPTURE, PROPAGATION or APPLY'
/
comment on column ALL_STREAMS_SCHEMA_RULES.SCHEMA_NAME is
'Name of the schema selected by this rule'
/
comment on column ALL_STREAMS_SCHEMA_RULES.RULE_TYPE is
'Type of rule: DML or DDL'
/
comment on column ALL_STREAMS_SCHEMA_RULES.INCLUDE_TAGGED_LCR is
'Whether or not to include tagged LCR'
/
comment on column ALL_STREAMS_SCHEMA_RULES.SOURCE_DATABASE is
'Name of the database where the LCRs originated'
/
comment on column ALL_STREAMS_SCHEMA_RULES.RULE_NAME is
'Name of the rule to be applied'
/
comment on column ALL_STREAMS_SCHEMA_RULES.RULE_OWNER is
'Owner of the rule'
/
comment on column ALL_STREAMS_SCHEMA_RULES.RULE_CONDITION is
'Generated rule condition evaluated by the rules engine'
/
create or replace public synonym ALL_STREAMS_SCHEMA_RULES
  for ALL_STREAMS_SCHEMA_RULES
/
grant select on ALL_STREAMS_SCHEMA_RULES to public with grant option
/

----------------------------------------------------------------------------

create or replace view DBA_STREAMS_TABLE_RULES
  (STREAMS_NAME, STREAMS_TYPE, TABLE_OWNER, TABLE_NAME, RULE_TYPE,
   DML_CONDITION, SUBSETTING_OPERATION, INCLUDE_TAGGED_LCR,
   SOURCE_DATABASE, RULE_NAME, RULE_OWNER, RULE_CONDITION)
as
select streams_name, decode(streams_type, 1, 'CAPTURE',
                                          2, 'PROPAGATION',
                                          3, 'APPLY',
                                          4, 'DEQUEUE', 'UNDEFINED'),
       schema_name, object_name, decode(rule_type, 1, 'DML',
                                                   2, 'DDL', 'UNKNOWN'),
       dml_condition, decode(subsetting_operation, 1, 'INSERT',
                                                   2, 'UPDATE',
                                                   3, 'DELETE'),
       decode(include_tagged_lcr, 0, 'NO',
                                  1, 'YES'),
       source_database, rule_name, rule_owner, rule_condition
  from "_DBA_STREAMS_RULES"
 where object_type = 1
/

comment on table DBA_STREAMS_TABLE_RULES is
'Table rules created by streams administrative APIs'
/
comment on column DBA_STREAMS_TABLE_RULES.STREAMS_NAME is
'Name of the streams process: capture/propagation/apply process'
/
comment on column DBA_STREAMS_TABLE_RULES.STREAMS_TYPE is
'Type of the streams process: CAPTURE, PROPAGATION or APPLY'
/
comment on column DBA_STREAMS_TABLE_RULES.TABLE_OWNER is
'Owner of the table selected by this rule'
/
comment on column DBA_STREAMS_TABLE_RULES.TABLE_NAME is
'Name of the table selected by this rule'
/
comment on column DBA_STREAMS_TABLE_RULES.RULE_TYPE is
'Type of rule: DML or DDL'
/
comment on column DBA_STREAMS_TABLE_RULES.DML_CONDITION is
'Row subsetting condition'
/
comment on column DBA_STREAMS_TABLE_RULES.SUBSETTING_OPERATION is
'DML operation for row subsetting'
/
comment on column DBA_STREAMS_TABLE_RULES.INCLUDE_TAGGED_LCR is
'Whether or not to include tagged LCR'
/
comment on column DBA_STREAMS_TABLE_RULES.SOURCE_DATABASE is
'Name of the database where the LCRs originated'
/
comment on column DBA_STREAMS_TABLE_RULES.RULE_NAME is
'Name of the rule to be applied'
/
comment on column DBA_STREAMS_TABLE_RULES.RULE_OWNER is
'Owner of the rule'
/
comment on column DBA_STREAMS_TABLE_RULES.RULE_CONDITION is
'Generated rule condition evaluated by the rules engine'
/
create or replace public synonym DBA_STREAMS_TABLE_RULES
  for DBA_STREAMS_TABLE_RULES
/
grant select on DBA_STREAMS_TABLE_RULES to select_catalog_role
/

----------------------------------------------------------------------------

create or replace view ALL_STREAMS_TABLE_RULES
as
select tr.streams_name, tr.streams_type, tr.table_owner, tr.table_name,
       tr.rule_type, tr.dml_condition, tr.subsetting_operation,
       tr.include_tagged_lcr, tr.source_database, tr.rule_name,
       tr.rule_owner, tr.rule_condition
  from dba_streams_table_rules tr, "_ALL_STREAMS_PROCESSES" p, all_rules ar
 where tr.rule_owner = ar.rule_owner
   and tr.rule_name = ar.rule_name
   and tr.streams_name = p.streams_name
   and tr.streams_type = p.streams_type
/

comment on table ALL_STREAMS_TABLE_RULES is
'Rules created by streams administrative APIs on tables visible to the current user'
/
comment on column ALL_STREAMS_TABLE_RULES.STREAMS_NAME is
'Name of the streams process: capture/propagation/apply process'
/
comment on column ALL_STREAMS_TABLE_RULES.STREAMS_TYPE is
'Type of the streams process: CAPTURE, PROPAGATION or APPLY'
/
comment on column ALL_STREAMS_TABLE_RULES.TABLE_OWNER is
'Owner of the table selected by this rule'
/
comment on column ALL_STREAMS_TABLE_RULES.TABLE_NAME is
'Name of the table selected by this rule'
/
comment on column ALL_STREAMS_TABLE_RULES.RULE_TYPE is
'Type of rule: DML or DDL'
/
comment on column ALL_STREAMS_TABLE_RULES.DML_CONDITION is
'Row subsetting condition'
/
comment on column ALL_STREAMS_TABLE_RULES.SUBSETTING_OPERATION is
'DML operation for row subsetting'
/
comment on column ALL_STREAMS_TABLE_RULES.INCLUDE_TAGGED_LCR is
'Whether or not to include tagged LCR'
/
comment on column ALL_STREAMS_TABLE_RULES.SOURCE_DATABASE is
'Name of the database where the LCRs originated'
/
comment on column ALL_STREAMS_TABLE_RULES.RULE_NAME is
'Name of the rule to be applied'
/
comment on column ALL_STREAMS_TABLE_RULES.RULE_OWNER is
'Owner of the rule'
/
comment on column ALL_STREAMS_TABLE_RULES.RULE_CONDITION is
'Generated rule condition evaluated by the rules engine'
/
create or replace public synonym ALL_STREAMS_TABLE_RULES
  for ALL_STREAMS_TABLE_RULES
/
grant select on ALL_STREAMS_TABLE_RULES to public with grant option
/

----------------------------------------------------------------------------
-- Views on streams$_message_rules tables
----------------------------------------------------------------------------

-- Private view select to all columns from streams$_message_rules.
-- Used by export. Respective catalog views will select from this view.
create or replace view "_DBA_STREAMS_MESSAGE_RULES"
as select * from sys.streams$_message_rules
/
grant select on "_DBA_STREAMS_MESSAGE_RULES" to exp_full_database
/

create or replace view DBA_STREAMS_MESSAGE_RULES
  (STREAMS_NAME, STREAMS_TYPE, MESSAGE_TYPE_NAME, MESSAGE_TYPE_OWNER,
   MESSAGE_RULE_VARIABLE, RULE_NAME, RULE_OWNER, RULE_CONDITION)
as
select streams_name, decode(streams_type, 2, 'PROPAGATION',
                                          3, 'APPLY', 
                                          4, 'DEQUEUE', 'UNDEFINED'),
       msg_type_name, msg_type_owner, msg_rule_var, rule_name, 
       rule_owner, rule_condition
  from "_DBA_STREAMS_MESSAGE_RULES"
/

comment on table DBA_STREAMS_MESSAGE_RULES is
'Rules for Streams messaging'
/
comment on column DBA_STREAMS_MESSAGE_RULES.STREAMS_NAME is
'Name of the streams process : propagation/apply/dequeue'
/
comment on column DBA_STREAMS_MESSAGE_RULES.STREAMS_TYPE is
'Type of the streams process: PROPAGATION, APPLY, or DEQUEUE'
/
comment on column DBA_STREAMS_MESSAGE_RULES.MESSAGE_TYPE_NAME is
'Name of the message type'
/
comment on column DBA_STREAMS_MESSAGE_RULES.MESSAGE_TYPE_OWNER is
'Owner of the message type'
/
comment on column DBA_STREAMS_MESSAGE_RULES.MESSAGE_RULE_VARIABLE is
'Name of variable in the message rule'
/
comment on column DBA_STREAMS_MESSAGE_RULES.RULE_NAME is
'Name of the rule'
/
comment on column DBA_STREAMS_MESSAGE_RULES.RULE_OWNER is
'Owner of the rule'
/
comment on column DBA_STREAMS_MESSAGE_RULES.RULE_CONDITION is
'Rule condition'
/
create or replace public synonym DBA_STREAMS_MESSAGE_RULES
  for DBA_STREAMS_MESSAGE_RULES
/
grant select on DBA_STREAMS_MESSAGE_RULES to select_catalog_role
/

----------------------------------------------------------------------------

create or replace view ALL_STREAMS_MESSAGE_RULES
as
select mr.*
  from dba_streams_message_rules mr, "_ALL_STREAMS_PROCESSES" p, all_rules ar
 where mr.rule_owner = ar.rule_owner
   and mr.rule_name  = ar.rule_name
   and mr.streams_name = p.streams_name
   and mr.streams_type = p.streams_type
/

comment on table ALL_STREAMS_MESSAGE_RULES is
'Rules for Streams messaging visible to the current user'
/
comment on column ALL_STREAMS_MESSAGE_RULES.STREAMS_NAME is
'Name of the streams process : propagation/apply/dequeue'
/
comment on column ALL_STREAMS_MESSAGE_RULES.STREAMS_TYPE is
'Type of the streams process: PROPAGATION, APPLY, or DEQUEUE'
/
comment on column ALL_STREAMS_MESSAGE_RULES.MESSAGE_TYPE_NAME is
'Name of the message type'
/
comment on column ALL_STREAMS_MESSAGE_RULES.MESSAGE_TYPE_OWNER is
'Owner of the message type'
/
comment on column ALL_STREAMS_MESSAGE_RULES.MESSAGE_RULE_VARIABLE is
'Name of variable in the message rule'
/
comment on column ALL_STREAMS_MESSAGE_RULES.RULE_NAME is
'Name of the rule'
/
comment on column ALL_STREAMS_MESSAGE_RULES.RULE_OWNER is
'Owner of the rule'
/
comment on column ALL_STREAMS_MESSAGE_RULES.RULE_CONDITION is
'Rule condition'
/
create or replace public synonym ALL_STREAMS_MESSAGE_RULES
  for ALL_STREAMS_MESSAGE_RULES
/
grant select on ALL_STREAMS_MESSAGE_RULES to public with grant option
/

----------------------------------------------------------------------------
-- Unified streams rules views
----------------------------------------------------------------------------

-- view of rules used by streams processes
create or replace view "_DBA_STREAMS_RULES_H"(
  streams_type, streams_name, rule_set_type, rule_set_owner, rule_set_name, 
  rule_owner, rule_name, rule_condition)
as 
select sp.streams_type, sp.streams_name, sp.rule_set_type, 
       sp.rule_set_owner, sp.rule_set_name, 
       ru.name rule_owner, ro.name rule_name, 
       r.condition
  from "_DBA_STREAMS_PROCESSES" sp, obj$ rso, user$ rsu,
       rule$ r, obj$ ro, user$ ru, rule_map$ rm
  where sp.rule_set_owner = rsu.name
    and sp.rule_set_name = rso.name
    and rso.owner# = rsu.user#
    and rso.obj# = rm.rs_obj#
    and r.obj# = rm.r_obj#
    and ro.obj# = rm.r_obj#
    and ru.user# = ro.owner#
/

-- This view of all the rules used by streams processes assumes that
-- rule names are unique over streams$_rules and streams$_message_rules.
-- Column same_rule_condition compares the original rule condition (ORC) 
-- to the current rule condition (CRC), and has value 'Y' if they
-- are the same, 'N' if they are different, and NULL if it cannot be
-- determined. The algorithm used to find the value of the column is:
--   if ORC is NULL then 
--     same_rule_condition = NULL;
--   else
--     if ORC = CRC then
--       same_rule_condition = 'Y';
--     else 
--       if length(CRC) > 4000
--         -- ORC only stores the first 4000 bytes, so unable to compare
--         -- if length(CRC) > 4000
--         same_rule_condition = NULL;
--       else
--         same_rule_condition = 'N';
--       end if;
--     end if;
--   end if;
create or replace view DBA_STREAMS_RULES
as
select decode(r.streams_type, 1, 'CAPTURE',
                              2, 'PROPAGATION',
                              3, 'APPLY', 
                              4, 'DEQUEUE') streams_type,
       r.streams_name, r.rule_set_owner, r.rule_set_name,
       r.rule_owner, r.rule_name, r.rule_condition, r.rule_set_type,        
       decode(sr.object_type, 1, 'TABLE',
                              2, 'SCHEMA',
                              3, 'GLOBAL') streams_rule_type,
       sr.schema_name, sr.object_name,
       decode(sr.subsetting_operation, 1, 'INSERT',
                                       2, 'UPDATE',
                                       3, 'DELETE') subsetting_operation, 
       sr.dml_condition,
       decode(sr.include_tagged_lcr, 0, 'NO',
                                     1, 'YES') include_tagged_lcr,
       sr.source_database, 
       decode(sr.rule_type, 1, 'DML',
                            2, 'DDL') rule_type,
       smr.msg_type_owner message_type_owner, 
       smr.msg_type_name message_type_name, 
       smr.msg_rule_var message_rule_variable,
       NVL(sr.rule_condition, smr.rule_condition) original_rule_condition, 
       decode(NVL(sr.rule_condition, smr.rule_condition), 
              NULL, NULL,
              dbms_lob.substr(r.rule_condition), 'YES',
              decode(least(4001,dbms_lob.getlength(r.rule_condition)), 
                     4001, NULL, 'NO')) same_rule_condition
  from "_DBA_STREAMS_RULES_H" r, streams$_rules sr, streams$_message_rules smr
  where r.rule_name = sr.rule_name(+) 
    and r.rule_owner = sr.rule_owner(+)
    and r.streams_name = sr.streams_name(+)
    and r.streams_type = sr.streams_type(+)
    and r.rule_name = smr.rule_name(+)
    and r.rule_owner = smr.rule_owner(+)
    and r.streams_name = smr.streams_name(+)
    and r.streams_type = smr.streams_type(+)
/

comment on table DBA_STREAMS_RULES is
'Rules used by Streams processes'
/
comment on column DBA_STREAMS_RULES.STREAMS_TYPE is
'Type of the Streams process: CAPTURE, PROPAGATION, APPLY or DEQUEUE'
/
comment on column DBA_STREAMS_RULES.STREAMS_NAME is
'Name of the Streams process'
/
comment on column DBA_STREAMS_RULES.RULE_SET_OWNER is
'Owner of the rule set'
/
comment on column DBA_STREAMS_RULES.RULE_SET_NAME is
'Name of the rule set'
/
comment on column DBA_STREAMS_RULES.RULE_OWNER is
'Owner of the rule'
/
comment on column DBA_STREAMS_RULES.RULE_NAME is
'Name of the rule'
/
comment on column DBA_STREAMS_RULES.RULE_CONDITION is
'Current rule condition'
/
comment on column DBA_STREAMS_RULES.RULE_SET_TYPE is
'Type of the rule set: POSITIVE or NEGATIVE'
/
comment on column DBA_STREAMS_RULES.STREAMS_RULE_TYPE is
'For global, schema or table rules, type of rule: TABLE, SCHEMA or GLOBAL'
/
comment on column DBA_STREAMS_RULES.SCHEMA_NAME is
'For table and schema rules, the schema name'
/
comment on column DBA_STREAMS_RULES.OBJECT_NAME is
'For table rules, the table name'
/
comment on column DBA_STREAMS_RULES.SUBSETTING_OPERATION is
'For subset rules, the type of operation: INSERT, UPDATE, or DELETE'
/
comment on column DBA_STREAMS_RULES.DML_CONDITION is
'For subset rules, the row subsetting condition'
/
comment on column DBA_STREAMS_RULES.INCLUDE_TAGGED_LCR is
'For global, schema or table rules, whether or not to include tagged LCRs'
/
comment on column DBA_STREAMS_RULES.SOURCE_DATABASE is
'For global, schema or table rules, the name of the database where the LCRs originated'
/
comment on column DBA_STREAMS_RULES.RULE_TYPE is
'For global, schema or table rules, type of rule: DML or DDL'
/
comment on column DBA_STREAMS_RULES.MESSAGE_TYPE_OWNER is
'For message rules, the owner of the message type'
/
comment on column DBA_STREAMS_RULES.MESSAGE_TYPE_NAME is
'For message rules, the name of the message type'
/
comment on column DBA_STREAMS_RULES.MESSAGE_RULE_VARIABLE is
'For message rules, the name of the variable in the message rule'
/
comment on column DBA_STREAMS_RULES.ORIGINAL_RULE_CONDITION is
'For rules created by Streams administrative APIs, the original rule condition when the rule was created'
/
comment on column DBA_STREAMS_RULES.SAME_RULE_CONDITION is
'For rules created by Streams administrative APIs, whether or not the current rule condition is the same as the original rule condition'
/
create or replace public synonym DBA_STREAMS_RULES
  for DBA_STREAMS_RULES
/
grant select on DBA_STREAMS_RULES to select_catalog_role
/

----------------------------------------------------------------------------

create or replace view ALL_STREAMS_RULES as
select r.* 
  from dba_streams_rules r, "_ALL_STREAMS_PROCESSES" p
where r.streams_type = p.streams_type
  and r.streams_name = p.streams_name
/
 
comment on table ALL_STREAMS_RULES is
'Rules used by streams processes'
/
comment on column ALL_STREAMS_RULES.STREAMS_TYPE is
'Type of the streams process: CAPTURE, PROPAGATION, APPLY or DEQUEUE'
/
comment on column ALL_STREAMS_RULES.STREAMS_NAME is
'Name of the Streams process'
/
comment on column ALL_STREAMS_RULES.RULE_SET_OWNER is
'Owner of the rule set'
/
comment on column ALL_STREAMS_RULES.RULE_SET_NAME is
'Name of the rule set'
/
comment on column ALL_STREAMS_RULES.RULE_OWNER is
'Owner of the rule'
/
comment on column ALL_STREAMS_RULES.RULE_NAME is
'Name of the rule'
/
comment on column ALL_STREAMS_RULES.RULE_CONDITION is
'Current rule condition'
/
comment on column ALL_STREAMS_RULES.RULE_SET_type is
'Type of the rule set: POSITIVE or NEGATIVE'
/
comment on column ALL_STREAMS_RULES.STREAMS_RULE_TYPE is
'For global, schema or table rules, type of rule: TABLE, SCHEMA or GLOBAL'
/
comment on column ALL_STREAMS_RULES.SCHEMA_NAME is
'For table and schema rules, the schema name'
/
comment on column ALL_STREAMS_RULES.OBJECT_NAME is
'For table rules, the table name'
/
comment on column ALL_STREAMS_RULES.SUBSETTING_OPERATION is
'For subset rules, the type of operation: INSERT, UPDATE, or DELETE'
/
comment on column ALL_STREAMS_RULES.DML_CONDITION is
'For subset rules, the row subsetting condition'
/
comment on column ALL_STREAMS_RULES.INCLUDE_TAGGED_LCR is
'For global, schema or table rules, whether or not to include tagged LCRs'
/
comment on column ALL_STREAMS_RULES.SOURCE_DATABASE is
'For global, schema or table rules, the name of the database where the LCRs originated'
/
comment on column ALL_STREAMS_RULES.RULE_TYPE is
'For global, schema or table rules, type of rule: DML or DDL'
/
comment on column ALL_STREAMS_RULES.MESSAGE_TYPE_OWNER is
'For message rules, the owner of the message type'
/
comment on column ALL_STREAMS_RULES.MESSAGE_TYPE_NAME is
'For message rules, the name of the message type'
/
comment on column ALL_STREAMS_RULES.MESSAGE_RULE_VARIABLE is
'For message rules, the name of the variable in the message rule'
/
comment on column ALL_STREAMS_RULES.ORIGINAL_RULE_CONDITION is
'For rules created by Streams administrative APIs, the original rule condition when the rule was created'
/
comment on column ALL_STREAMS_RULES.SAME_RULE_CONDITION is
'For rules created by Streams administrative APIs, whether or not the current rule condition is the same as the original rule condition'
/
create or replace public synonym ALL_STREAMS_RULES
  for ALL_STREAMS_RULES
/
grant select on ALL_STREAMS_RULES to public with grant option
/

----------------------------------------------------------------------------
-- Views on transform functions
----------------------------------------------------------------------------

create or replace view "_DBA_STREAMS_TRANSFM_FUNCTION"
  (RULE_OWNER, RULE_NAME, VALUE_TYPE, TRANSFORM_FUNCTION_NAME, CUSTOM_TYPE)
as
select r.rule_owner, r.rule_name, SYS.ANYDATA.GetTypeName(ctx.nvn_value),
       DECODE(SYS.ANYDATA.GetTypeName(ctx.nvn_value), 
              'SYS.VARCHAR2', SYS.ANYDATA.AccessVarchar2(ctx.nvn_value), 
              NULL),
       DECODE(ctx.nvn_name, 'STREAMS$_TRANSFORM_FUNCTION', 'ONE TO ONE',
                            'STREAMS$_ARRAY_TRANS_FUNCTION', 'ONE TO MANY')
from   DBA_RULES r, table(r.rule_action_context.actx_list) ctx
where  ctx.nvn_name = 'STREAMS$_TRANSFORM_FUNCTION'
   OR  ctx.nvn_name = 'STREAMS$_ARRAY_TRANS_FUNCTION'
/

-- dba_streams_transform_function view
create or replace view DBA_STREAMS_TRANSFORM_FUNCTION
  (RULE_OWNER, RULE_NAME, VALUE_TYPE, TRANSFORM_FUNCTION_NAME, CUSTOM_TYPE) 
as
select rule_owner, rule_name, value_type, transform_function_name, custom_type
from   "_DBA_STREAMS_TRANSFM_FUNCTION"
/
comment on table DBA_STREAMS_TRANSFORM_FUNCTION is
'Rules-based transform functions used by Streams'
/
comment on column DBA_STREAMS_TRANSFORM_FUNCTION.RULE_OWNER is
'The owner of the rule associated with the transform function'
/
comment on column DBA_STREAMS_TRANSFORM_FUNCTION.RULE_NAME is
'The name of the rule associated with the transform function'
/
comment on column DBA_STREAMS_TRANSFORM_FUNCTION.VALUE_TYPE is
'The type of the transform function name.  This type must be VARCHAR2 for a rule-based transformation to work properly'
/
comment on column DBA_STREAMS_TRANSFORM_FUNCTION.TRANSFORM_FUNCTION_NAME is
'The name of the transform function, or NULL if the VALUE_TYPE is not VARCHAR2'
/
comment on column DBA_STREAMS_TRANSFORM_FUNCTION.CUSTOM_TYPE is
'The type of the transform function'
/
create or replace public synonym DBA_STREAMS_TRANSFORM_FUNCTION
  for DBA_STREAMS_TRANSFORM_FUNCTION
/
grant select on DBA_STREAMS_TRANSFORM_FUNCTION to select_catalog_role
/

-- all_streams_transform_function view
create or replace view ALL_STREAMS_TRANSFORM_FUNCTION as
select tf.*
from   DBA_STREAMS_TRANSFORM_FUNCTION tf, ALL_RULES r 
where  tf.rule_owner = r.rule_owner
and    tf.rule_name = r.rule_name
/
comment on table ALL_STREAMS_TRANSFORM_FUNCTION is
'Rules-based transform functions used by Streams'
/
comment on column ALL_STREAMS_TRANSFORM_FUNCTION.RULE_OWNER is
'The owner of the rule associated with the transform function'
/
comment on column ALL_STREAMS_TRANSFORM_FUNCTION.RULE_NAME is
'The name of the rule associated with the transform function'
/
comment on column ALL_STREAMS_TRANSFORM_FUNCTION.VALUE_TYPE is
'The type of the transform function name.  This type must be VARCHAR2 for a rule-based transformation to work properly'
/
comment on column ALL_STREAMS_TRANSFORM_FUNCTION.TRANSFORM_FUNCTION_NAME is
'The name of the transform function, or NULL if the VALUE_TYPE is not VARCHAR2'
/
comment on column ALL_STREAMS_TRANSFORM_FUNCTION.CUSTOM_TYPE is
'The type of the transform function'
/
create or replace public synonym ALL_STREAMS_TRANSFORM_FUNCTION
  for ALL_STREAMS_TRANSFORM_FUNCTION
/
grant select on ALL_STREAMS_TRANSFORM_FUNCTION to public with grant option
/

----------------------------------------------------------------------------
-- Views on streams$_privileged_user table
----------------------------------------------------------------------------

-- Private view to select all columns from sys.streams$_privileged_user.
-- Used by export. Respective catalog views will select from this view.
create or replace view "_DBA_STREAMS_PRIVILEGED_USER"
as select * from sys.streams$_privileged_user
/
grant select on "_DBA_STREAMS_PRIVILEGED_USER" to exp_full_database
/

create or replace view DBA_STREAMS_ADMINISTRATOR (USERNAME, LOCAL_PRIVILEGES,
                                                  ACCESS_FROM_REMOTE)
as
select u.name, decode(bitand(pu.privs, 1), 0, 'NO', 'YES'),
       decode(bitand(pu.privs, 2), 0, 'NO', 'YES')
  from user$ u, "_DBA_STREAMS_PRIVILEGED_USER" pu
 where u.user# = pu.user# AND pu.privs != 0
/

comment on table DBA_STREAMS_ADMINISTRATOR is
'Users granted the privileges to be a streams administrator'
/
comment on column DBA_STREAMS_ADMINISTRATOR.USERNAME is
'Name of the user who has been granted privileges to be streams administrator'
/
comment on column DBA_STREAMS_ADMINISTRATOR.LOCAL_PRIVILEGES is
'YES, if user has been granted local Streams admininstrator privileges.  NO, if the user does not have local Streams administrator privileges.'
/
comment on column DBA_STREAMS_ADMINISTRATOR.ACCESS_FROM_REMOTE is
'YES, if user can be used for remote Streams administration through a database link.  NO, if the user cannot be used for remote Streams administration'
/
create or replace public synonym DBA_STREAMS_ADMINISTRATOR
  for DBA_STREAMS_ADMINISTRATOR
/
grant select on DBA_STREAMS_ADMINISTRATOR to select_catalog_role
/

----------------------------------------------------------------------------
/*
** THE CASE STATEMENTS IN THE SELECT CLAUSE SHOULD BE IDENTICAL
** TO THE OR CLAUSES IN THE WHERE CLAUSE.
**
** WHEN THE "_DBA_STREAMS_UNSUPPORTED_%" VIEWS ARE ADDED/MODIFIED,
** PLEASE ALSO MAKE CORRESPONDING CHANGES IN knlcuDetCompatObj()
** and knlcuDetCompatCol().
**
** It's pretty clear that we can't use dba_% views, e.g., dba_tab_columns
** due to the complexity of our logic.
**
** This view lists unsupported tables in 9.2.
** tproperty, oflags, tflags are included for debugging.
*/
create or replace view "_DBA_STREAMS_UNSUPPORTED_9_2"
  (owner, table_name, tproperty, ttrigflag, oflags, tflags, reason, compatible,
   auto_filtered)
as
  select
    distinct u.name, o.name,
             t.property, t.trigflag, o.flags, t.flags,
    (case
      when 
        ( (bitand(t.property, 
                64                                                    /* IOT */
              + 128         /* 0x00000080              IOT with row overflow */
              + 256         /* 0x00000100            IOT with row clustering */
              + 512         /* 0x00000200               iot OVeRflow segment */
             ) != 0
          ) or
          (bitand(t.flags,
                268435456    /* 0x10000000   IOT with Phys Rowid/mapping tab */
              + 536870912    /* 0x20000000 Mapping Tab for Phys rowid of IOT */
             ) != 0
          ) or
          (bitand(t.property, 262208) = 262208  /* 0x40+0x40000 IOT+user LOB */
          ) or
          (bitand(t.property, 2112) = 2112  /* 0x40+0x800 IOT + internal LOB */
          ) or
          (bitand(t.property, 64) != 0 and                           /* 0x40 */
             bitand(t.flags, 131072) != 0                         /* 0x20000 */
          )
        )
        then 'IOT'
      when bitand(t.property,
                  1                                           /* typed table */
                + 2                                           /* ADT columns */
                + 4                                  /* nested table columns */
                + 8                                           /* REF columns */
                + 16                                        /* array columns */
                + 4096                                             /* pk OID */
                + 8192              /* storage table for nested table column */
                + 65536                                              /* sOID */
               ) != 0
         then 'column with user-defined type'
      when bitand(t.trigflag, 65536) = 65536                      /* 0x10000 */
        then 'Table with encrypted column'
      when bitand(t.trigflag, 131072) = 131072                    /* 0x20000 */
        then 'Table with encrypted column'
      when (exists
            (select 1 
             from   sys.col$ c 
             where  t.obj# = c.obj#
               and
               ( (bitand(c.property, 32) = 32                      /* hidden */
                 ) or
                 (c.type# not in ( 
                     1,                                          /* varchar2 */
                     2,                                            /* number */
                     12,                                             /* date */
                     96,                                             /* char */
                     100,                                    /* binary float */
                     101,                                   /* binary double */
                     112,                                  /* clob and nclob */
                     113,                                            /* blob */
                     180,                                  /* timestamp (..) */
                     181,                    /* timestamp(..) with time zone */
                     182,                      /* interval year(..) to month */
                     183,                  /* interval day(..) to second(..) */
                     231)              /* timestamp(..) with local time zone */
                   and (c.type# != 23                     /* raw not raw oid */
                     or (c.type# = 23 and bitand(c.property, 2) = 2))
                 ) or
                 (c.segcol# = 0             /* virtual column: not supported */
                 ) or
                 (bitand(c.property, 
                         2                                     /* OID column */
                       + 67108864                             /* KQLDCOP_ENC */
                       ) != 0
                 ) or
                 (c.type# = 112 and c.charsetform = 2               /* NCLOB */
                 ) or
                 (c.type# = 112 and c.charsetform = 1 and
                  /* discussed with JIYANG, varying width CLOB */
                  c.charsetid >= 800
                 )
               )
             )
          )
         then 'unsupported column exists'
      when bitand(t.property, 1) = 1
        then 'object table'
      when bitand(t.property, 131072) = 131072
        then 'AQ queue table'
      /* x00400000 + 0x00800000 */
      when bitand(t.property, 4194304 + 8388608) != 0
        then 'temporary table'
      when bitand(t.property, 134217728) = 134217728          /* 0x08000000 */
        then 'sub object'
      when bitand(t.property, 2147483648) = 2147483648
        then 'external table'
      when bitand(t.property, 33554432 + 67108864) != 0
        then 'materialized view'
      when bitand(t.property, 32768) = 32768     /* 0x8000 has FILE columns */
        then 'FILE column exists'
      when
        (exists 
          (select 1 
           from sys.mlog$ ml where ml.mowner = u.name and ml.log = o.name
          )
        )
        then 'materialized view log'
      when bitand(t.flags, 262144) = 262144
        then 'materalized view container table'
      when bitand(t.trigflag, 268435456) = 268435456
        then 'streams unsupported object'
      when bitand(o.flags, 16) = 16
        then 'domain index'
      else null end) reason, 
      92,                                                      /* compatible */
      'NO'                                                  /* auto filtered */
  from sys.obj$ o, sys.user$ u, sys.tab$ t
  where t.obj# = o.obj#
    and o.owner# = u.user#
    and u.name not in ('SYS', 'SYSTEM', 'CTXSYS')
    and bitand(o.flags,
                  2                                      /* temporary object */
                + 4                               /* system generated object */
                + 32                                 /* in-memory temp table */
                + 128                          /* dropped table (RecycleBin) */
                  ) = 0
    and
      (  (bitand(t.property, 
                64                                                    /* IOT */
              + 128         /* 0x00000080              IOT with row overflow */
              + 256         /* 0x00000100            IOT with row clustering */
              + 512         /* 0x00000200               iot OVeRflow segment */
             ) != 0
          ) or
          (bitand(t.flags,
                268435456    /* 0x10000000   IOT with Phys Rowid/mapping tab */
              + 536870912    /* 0x20000000 Mapping Tab for Phys rowid of IOT */
             ) != 0
          ) or
          (bitand(t.property, 262208) = 262208  /* 0x40+0x40000 IOT+user LOB */
          ) or
          (bitand(t.property, 2112) = 2112  /* 0x40+0x800 IOT + internal LOB */
          ) or
          (bitand(t.property, 64) != 0 and                           /* 0x40 */
             bitand(t.flags, 131072) != 0                         /* 0x20000 */
          ) or                                    /* IOT with "Row Movement" */
          (bitand(t.property,
                  1                                           /* typed table */
                + 2                                           /* ADT columns */
                + 4                                  /* nested table columns */
                + 8                                           /* REF columns */
                + 16                                        /* array columns */
                + 4096                                             /* pk OID */
                + 8192              /* storage table for nested table column */
                + 65536                                              /* sOID */
               ) != 0
          ) or
          (exists                                      /* unsupported column */
            (select 1 from sys.col$ c 
             where t.obj# = c.obj#
               and
               ( (bitand(c.property,          /* check for encrupted columns */
                         32                                        /* hidden */
                       + 67108864                             /* KQLDCOP_ENC */
                       ) != 0
                 ) or
                 (c.type# not in ( 
                     1,                                          /* varchar2 */
                     2,                                            /* number */
                     12,                                             /* date */
                     96,                                             /* char */
                     112,                                  /* clob and nclob */
                     113,                                            /* blob */
                     180,                                  /* timestamp (..) */
                     181,                    /* timestamp(..) with time zone */
                     182,                      /* interval year(..) to month */
                     183,                  /* interval day(..) to second(..) */
                     231)              /* timestamp(..) with local time zone */
                   and (c.type# != 23                     /* raw not raw oid */
                     or (c.type# = 23 and bitand(c.property, 2) = 2))
                 ) or
                 (c.segcol# = 0             /* virtual column: not supported */
                 ) or
                 (bitand(c.property, 2) = 2                    /* OID column */
                 ) or
                 (c.type# = 112 and c.charsetform = 2               /* NCLOB */
                 ) or
                 (c.type# = 112 and c.charsetform = 1 and
                  /* discussed with JIYANG, varying width CLOB */
                  c.charsetid >= 800
                 )
               )
             )
          ) or
          (bitand(t.property, 1) = 1                         /* object table */
          ) or 
          (bitand(t.property,
                131072      /* 0x00020000 table is used as an AQ queue table */
              + 4194304     /* 0x00400000             global temporary table */
              + 8388608     /* 0x00800000   session-specific temporary table */
              + 33554432    /* 0x02000000        Read Only Materialized View */
              + 67108864    /* 0x04000000            Materialized View table */
              + 134217728   /* 0x08000000                    Is a Sub object */
              + 2147483648   /* 0x80000000                    eXternal TaBle */
             ) != 0
          ) or
          (bitand(t.flags,
                  262144              /* 0x00040000   MV Container Table, MV */
                 ) = 262144
          ) or 
          (bitand(t.property, 32768) = 32768      /* 0x8000 has FILE columns */
          ) or 
          (bitand(t.trigflag, 
                  65536     /* 0x00010000   server held key encrypted column */
                + 131072    /* 0x00020000     user held key encrypted column */
                + 268435456 /* 0x10000000                         strm unsup */
             ) != 0
          ) or 
          (exists 
            (select 1 
             from sys.mlog$ ml where ml.mowner = u.name and ml.log = o.name
            )
          )
        )
/

/*
** THE CASE STATEMENTS IN THE SELECT CLAUSE SHOULD BE IDENTICAL
** TO THE OR CLAUSES IN THE WHERE CLAUSE.
**
** It's pretty clear that we can't use dba_% views, e.g., dba_tab_columns
** due to the complexity of our logic.
**
** This view lists unsupported tables in 10.1.
*/
create or replace view "_DBA_STREAMS_UNSUPPORTED_10_1"
  (owner, table_name, tproperty, ttrigflag, oflags, tflags, reason, compatible,
   auto_filtered)
as
  select
    distinct u.name, o.name,
             t.property, t.trigflag, o.flags, t.flags,
    (case
      when bitand(t.property, 128 + 512 ) != 0             /* 0x080 + 0x200 */
        then 'IOT with overflow'
      when bitand(t.property, 262208) = 262208                   /* 0x40040 */
        then 'IOT with LOB'                                     /* user lob */
      when bitand(t.flags, 268435456) = 268435456             /* 0x10000000 */
        then 'IOT with physical Rowid mapping'
      when bitand(t.flags, 536870912) = 536870912             /* 0x20000000 */
        then 'mapping table for physical rowid of IOT'
      when bitand(t.property, 2112) = 2112 /* 0x40+0x800 IOT + internal LOB */
        then 'IOT with LOB'                                 /* internal lob */
      when (bitand(t.property, 64) = 64 and 
            bitand(t.flags, 131072) = 131072)
        then 'IOT with row movement'                             /* 0x20000 */
      when bitand(t.property,
                  1                                           /* typed table */
                + 2                                           /* ADT columns */
                + 4                                  /* nested table columns */
                + 8                                           /* REF columns */
                + 16                                        /* array columns */
                + 4096                                             /* pk OID */
                + 8192       /* 0x2000 storage table for nested table column */
                + 65536                                      /* 0x10000 sOID */
               ) != 0
        then 'column with user-defined type'
      when bitand(t.trigflag, 65536) = 65536                      /* 0x10000 */
        then 'Table with encrypted column'
      when bitand(t.trigflag, 131072) = 131072                    /* 0x20000 */
        then 'Table with encrypted column'
      when (exists
            (select 1 from sys.col$ c 
             where t.obj# = c.obj#
               and
               ( (bitand(c.property, 32) = 32                      /* hidden */
                 ) or
                 (c.type# not in ( 
                     1,                                          /* varchar2 */
                     2,                                            /* number */
                     8,                                              /* long */
                     12,                                             /* date */
                     24,                                         /* long raw */
                     96,                                             /* char */
                     100,                                    /* binary float */
                     101,                                   /* binary double */
                     112,                                  /* clob and nclob */
                     113,                                            /* blob */
                     180,                                  /* timestamp (..) */
                     181,                    /* timestamp(..) with time zone */
                     182,                      /* interval year(..) to month */
                     183,                  /* interval day(..) to second(..) */
                     208,                                          /* urowid */
                     231)              /* timestamp(..) with local time zone */
                   and (c.type# != 23                     /* raw not raw oid */
                     or (c.type# = 23 and bitand(c.property, 2) = 2))
                 ) or
                 (bitand(c.property, 
                         2                                     /* OID column */
                       + 67108864                             /* KQLDCOP_ENC */
                       ) != 0
                 )
               )
             )
          )
        then 'unsupported column exists'
      when bitand(t.property, 1) = 1
        then 'object table'
      when bitand(t.property, 131072) = 131072
        then 'AQ queue table'
      /* x00400000 + 0x00800000 */
      when bitand(t.property, 4194304 + 8388608) != 0
        then 'temporary table'
      when bitand(t.property, 134217728) = 134217728          /* 0x08000000 */
        then 'sub object'
      when bitand(t.property, 2147483648) = 2147483648        /* 0x80000000 */
        then 'external table'
      when bitand(t.property, 32768) = 32768     /* 0x8000 has FILE columns */
        then 'FILE column exists'
      when
        (exists  /* TO DO: add some bit to tab$.property */
          (select 1 
           from   sys.mlog$ ml 
           where  ml.mowner = u.name and ml.log = o.name)
        )
        then 'materialized view log'
      when bitand(t.trigflag, 268435456) = 268435456
        then 'streams unsupported object'
      when bitand(o.flags, 16) = 16
        then 'domain index'
      else null end) reason, 
      100,                                                     /* compatible */
    (case
      when bitand(t.trigflag, 268435456) = 268435456  /* streams unsupported */
        then 'YES'
      /* x00400000 + 0x00800000  : Temp table */
      when bitand(t.property, 4194304 + 8388608) != 0
        then 'YES'
      when bitand(o.flags, 16) = 16                          /* domain index */
        then 'YES'
      else 'NO' end) auto_filtered     
  from sys.obj$ o, sys.user$ u, sys.tab$ t --, sys.seg$ s
    where t.obj# = o.obj#
      and o.owner# = u.user#
      and u.name not in ('SYS', 'SYSTEM', 'CTXSYS') 
      and bitand(o.flags,
                  2                                      /* temporary object */
                + 4                               /* system generated object */
                + 32                                 /* in-memory temp table */
                + 128                          /* dropped table (RecycleBin) */
                  ) = 0
      and
      (  (bitand(t.property, 
                128         /* 0x00000080              IOT with row overflow */
              + 256         /* 0x00000100            IOT with row clustering */
              + 512         /* 0x00000200               iot OVeRflow segment */
             ) != 0
          ) or
          (bitand(t.flags,
                268435456    /* 0x10000000   IOT with Phys Rowid/mapping tab */
              + 536870912    /* 0x20000000 Mapping Tab for Phys rowid of IOT */
             ) != 0
          ) or
          (bitand(t.property, 262208) = 262208  /* 0x40+0x40000 IOT+user LOB */
          ) or
          (bitand(t.property, 2112) = 2112  /* 0x40+0x800 IOT + internal LOB */
          ) or
          (bitand(t.property, 64) != 0 and
             bitand(t.flags, 131072) != 0
          ) or                                    /* IOT with "Row Movement" */
          (bitand(t.property,
                  1                                           /* typed table */
                + 2                                           /* ADT columns */
                + 4                                  /* nested table columns */
                + 8                                           /* REF columns */
                + 16                                        /* array columns */
                + 4096                                             /* pk OID */
                + 8192       /* 0x2000 storage table for nested table column */
                + 65536                                      /* 0x10000 sOID */
               ) != 0
          ) or
          (exists                                      /* unsupported column */
            (select 1 from sys.col$ c 
             where t.obj# = c.obj#
               and
               ( (bitand(c.property, 32) = 32 and                  /* hidden */
                   /* not function-based index */
                   (not exists (select 1 from sys.ind$ i
                                  where i.bo# = t.obj#
                                    and bitand(i.property, 16) = 16)) and
                   /* not descending index */
                   (bitand(c.property, 131072) != 131072)         /* 0x20000 */
                 ) or
                 (bitand(c.property,          /* check for encrupted columns */
                         67108864                             /* KQLDCOP_ENC */
                       ) != 0
                 ) or
                 (c.type# not in ( 
                     1,                                          /* varchar2 */
                     2,                                            /* number */
                     8,                                              /* long */
                     12,                                             /* date */
                     24,                                         /* long raw */
                     96,                                             /* char */
                     100,                                    /* binary float */
                     101,                                   /* binary double */
                     112,                                  /* clob and nclob */
                     113,                                            /* blob */
                     180,                                  /* timestamp (..) */
                     181,                    /* timestamp(..) with time zone */
                     182,                      /* interval year(..) to month */
                     183,                  /* interval day(..) to second(..) */
                     208,                                          /* urowid */
                     231)              /* timestamp(..) with local time zone */
                   and (c.type# != 23                     /* raw not raw oid */
                     or (c.type# = 23 and bitand(c.property, 2) = 2))
                 ) or
                 (bitand(c.property, 2) = 2                    /* OID column */
                 )
               )
             )
          ) or
          (bitand(t.property, 1) = 1                         /* object table */
          ) or 
          (bitand(t.property,
                131072      /* 0x00020000 table is used as an AQ queue table */
              + 4194304     /* 0x00400000             global temporary table */
              + 8388608     /* 0x00800000   session-specific temporary table */
              + 134217728   /* 0x08000000                    Is a Sub object */
              + 2147483648  /* 0x80000000                     eXternal TaBle */
             ) != 0
          ) or 
          (bitand(t.property, 32768) = 32768      /* 0x8000 has FILE columns */
          ) or   
          (bitand(t.trigflag, 
                  65536     /* 0x00010000   server held key encrypted column */
                + 131072    /* 0x00020000     user held key encrypted column */
                + 268435456 /* 0x10000000                         strm unsup */
             ) != 0
          ) or 
          (exists /* TO DO: add some bit to tab$.property */
            (select 1 
             from sys.mlog$ ml where ml.mowner = u.name and ml.log = o.name
            )
          )
        )
/

/*
** This view lists newly supported tables in 10.1, which are
** not supported in 9.2.
** We will need a similar view in a future release to list
** newly supported tables in that release, comparing with an
** immediate preceding release.
** We can union these "_DBA_STREAMS_NEWLY_SUPTED_%" views
** to construct DBA_STREAMS_NEWLY_SUPPORTED view.
*/
create or replace view "_DBA_STREAMS_NEWLY_SUPTED_10_1"
  (owner, table_name, reason, compatible, str_compat)
as
  select owner, table_name, reason, '10.1', 100
    from "_DBA_STREAMS_UNSUPPORTED_9_2" o
    where not exists
      (select 1 from "_DBA_STREAMS_UNSUPPORTED_10_1" i
         where i.owner = o.owner
           and i.table_name = o.table_name);
/

/*
** THE CASE STATEMENTS IN THE SELECT CLAUSE SHOULD BE IDENTICAL
** TO THE OR CLAUSES IN THE WHERE CLAUSE.
**
** It's pretty clear that we can't use dba_% views, e.g., dba_tab_columns
** due to the complexity of our logic.
**
** This view lists unsupported tables in 10.2.
*/
create or replace view "_DBA_STREAMS_UNSUPPORTED_10_2"
  (owner, table_name, tproperty, ttrigflag, oflags, tflags, reason, compatible,
   auto_filtered)
as
  select
    distinct u.name, o.name,
             t.property, t.trigflag, o.flags, t.flags,
    (case
       when bitand(t.property,
                  1                                           /* typed table */
                + 2                                           /* ADT columns */
                + 4                                  /* nested table columns */
                + 8                                           /* REF columns */
                + 16                                        /* array columns */
                + 4096                                             /* pk OID */
                + 8192       /* 0x2000 storage table for nested table column */
                + 65536                                      /* 0x10000 sOID */
               ) != 0
        then 'column with user-defined type'
      when bitand(t.trigflag, 65536) = 65536                      /* 0x10000 */
        then 'Table with encrypted column'
      when bitand(t.trigflag, 131072) = 131072                    /* 0x20000 */
        then 'Table with encrypted column'
      when (exists
            (select 1 from sys.col$ c 
             where t.obj# = c.obj#
               and
               ( (bitand(c.property, 32) = 32                      /* hidden */
                 ) or
                 (c.type# not in ( 
                     1,                                          /* varchar2 */
                     2,                                            /* number */
                     8,                                              /* long */
                     12,                                             /* date */
                     24,                                         /* long raw */
                     96,                                             /* char */
                     100,                                    /* binary float */
                     101,                                   /* binary double */
                     112,                                  /* clob and nclob */
                     113,                                            /* blob */
                     180,                                  /* timestamp (..) */
                     181,                    /* timestamp(..) with time zone */
                     182,                      /* interval year(..) to month */
                     183,                  /* interval day(..) to second(..) */
                     208,                                          /* urowid */
                     231)              /* timestamp(..) with local time zone */
                   and (c.type# != 23                     /* raw not raw oid */
                     or (c.type# = 23 and bitand(c.property, 2) = 2))
                 ) or
                 (bitand(c.property, 
                         2                                     /* OID column */
                       + 67108864                             /* KQLDCOP_ENC */
                       ) != 0
                 )
               )
             )
          )
        then 'unsupported column exists'
      when bitand(t.property, 1) = 1
        then 'object table'
      when bitand(t.property, 131072) = 131072
        then 'AQ queue table'
      /* x00400000 + 0x00800000 */
      when bitand(t.property, 4194304 + 8388608) != 0
        then 'temporary table'
      when bitand(t.property, 134217728) = 134217728          /* 0x08000000 */
        then 'sub object'
      when bitand(t.property, 2147483648) = 2147483648        /* 0x80000000 */
        then 'external table'
      when bitand(t.property, 32768) = 32768     /* 0x8000 has FILE columns */
        then 'FILE column exists'
      when
        (exists  /* TO DO: add some bit to tab$.property */
          (select 1 
           from   sys.mlog$ ml 
           where  ml.mowner = u.name and ml.log = o.name)
        )
        then 'materialized view log'
      when bitand(t.trigflag, 268435456) = 268435456
        then 'streams unsupported object'
      when bitand(o.flags, 16) = 16
        then 'domain index'
      else null end) reason, 
      102,                                                     /* compatible */
    (case
      when bitand(t.trigflag, 268435456) = 268435456  /* streams unsupported */
        then 'YES'
      /* x00400000 + 0x00800000  : Temp table */
      when bitand(t.property, 4194304 + 8388608) != 0
        then 'YES'
      when bitand(o.flags, 16) = 16                          /* domain index */
        then 'YES'
      else 'NO' end) auto_filtered     
  from sys.obj$ o, sys.user$ u, sys.tab$ t --, sys.seg$ s
    where t.obj# = o.obj#
      and o.owner# = u.user#
      and u.name not in ('SYS', 'SYSTEM', 'CTXSYS') 
      and bitand(o.flags,
                  2                                      /* temporary object */
                + 4                               /* system generated object */
                + 32                                 /* in-memory temp table */
                + 128                          /* dropped table (RecycleBin) */
                  ) = 0
      and
      (   (bitand(t.property,
                  1                                           /* typed table */
                + 2                                           /* ADT columns */
                + 4                                  /* nested table columns */
                + 8                                           /* REF columns */
                + 16                                        /* array columns */
                + 4096                                             /* pk OID */
                + 8192       /* 0x2000 storage table for nested table column */
                + 65536                                      /* 0x10000 sOID */
               ) != 0
          ) or
          (exists                                      /* unsupported column */
            (select 1 from sys.col$ c 
             where t.obj# = c.obj#
               and
               ( (bitand(c.property, 32) = 32 and                  /* hidden */
                   /* not function-based index */
                   (not exists (select 1 from sys.ind$ i
                                  where i.bo# = t.obj#
                                    and bitand(i.property, 16) = 16)) and
                   /* not descending index */
                   (bitand(c.property, 131072) != 131072)         /* 0x20000 */
                 ) or
                 (bitand(c.property,          /* check for encrupted columns */
                         67108864                             /* KQLDCOP_ENC */
                       ) != 0
                 ) or
                 (c.type# not in ( 
                     1,                                          /* varchar2 */
                     2,                                            /* number */
                     8,                                              /* long */
                     12,                                             /* date */
                     24,                                         /* long raw */
                     96,                                             /* char */
                     100,                                    /* binary float */
                     101,                                   /* binary double */
                     112,                                  /* clob and nclob */
                     113,                                            /* blob */
                     180,                                  /* timestamp (..) */
                     181,                    /* timestamp(..) with time zone */
                     182,                      /* interval year(..) to month */
                     183,                  /* interval day(..) to second(..) */
                     208,                                          /* urowid */
                     231)              /* timestamp(..) with local time zone */
                   and (c.type# != 23                     /* raw not raw oid */
                     or (c.type# = 23 and bitand(c.property, 2) = 2))
                 ) or
                 (bitand(c.property, 2) = 2                    /* OID column */
                 )
               )
             )
          ) or
          (bitand(t.property, 1) = 1                         /* object table */
          ) or 
          (bitand(t.property,
                131072      /* 0x00020000 table is used as an AQ queue table */
              + 4194304     /* 0x00400000             global temporary table */
              + 8388608     /* 0x00800000   session-specific temporary table */
              + 134217728   /* 0x08000000                    Is a Sub object */
              + 2147483648  /* 0x80000000                     eXternal TaBle */
             ) != 0
          ) or 
          (bitand(t.property, 32768) = 32768      /* 0x8000 has FILE columns */
          ) or   
          (bitand(t.trigflag, 
                  65536     /* 0x00010000   server held key encrypted column */
                + 131072    /* 0x00020000     user held key encrypted column */
                + 268435456 /* 0x10000000                         strm unsup */
             ) != 0
          ) or 
          (exists /* TO DO: add some bit to tab$.property */
            (select 1 
             from sys.mlog$ ml where ml.mowner = u.name and ml.log = o.name
            )
          )
        )
/


/*
** This view lists newly supported tables in 10.2
** We will need a similar view in a future release to list
** newly supported tables in that release, comparing with an
** immediate preceding release.
** We can union these "_DBA_STREAMS_NEWLY_SUPTED_%" views
** to construct DBA_STREAMS_NEWLY_SUPPORTED view.
*/
create or replace view "_DBA_STREAMS_NEWLY_SUPTED_10_2"
  (owner, table_name, reason, compatible, str_compat)
as
  select owner, table_name, reason, '10.2', 102
    from "_DBA_STREAMS_UNSUPPORTED_10_1" t
   where   bitand(t.tproperty, 128 + 512 ) != 0             /* 0x080 + 0x200 */
           /* 'IOT with overflow' */
    or     bitand(t.tproperty, 262208) = 262208                   /* 0x40040 */
           /* 'IOT with LOB' user lob */
    or     bitand(t.tflags, 268435456) = 268435456             /* 0x10000000 */
           /* 'IOT with physical Rowid mapping'*/
    or     bitand(t.tflags, 536870912) = 536870912             /* 0x20000000 */
           /* 'mapping table for physical rowid of IOT' */
    or     bitand(t.tproperty, 2112) = 2112 /* 0x40+0x800 IOT + internal LOB */
           /* 'IOT with LOB'  internal lob */
    or     (bitand(t.tproperty, 64) = 64 and 
             bitand(t.tflags, 131072) = 131072);
           /* 'IOT with row movement' 0x20000 */
/

/*
** If we define "_DBA_STREAMS_UNSUPPORTED_%" for a new release,
** we need to add "_DBA_STREAMS_UNSUPPORTED_%" to the union.
** Also, a new return value for get_str_compat() will have to be added.
*/
create or replace view DBA_STREAMS_UNSUPPORTED
as select owner, table_name, reason, auto_filtered
   from (select * from "_DBA_STREAMS_UNSUPPORTED_9_2" 
         where compatible = dbms_logrep_util.get_str_compat() union
         select * from "_DBA_STREAMS_UNSUPPORTED_10_1" 
         where compatible = dbms_logrep_util.get_str_compat() union
         select * from "_DBA_STREAMS_UNSUPPORTED_10_2" 
         where compatible = dbms_logrep_util.get_str_compat());

comment on table DBA_STREAMS_UNSUPPORTED is
'List of all the tables that are not supported by Streams in this release'
/

comment on column DBA_STREAMS_UNSUPPORTED.OWNER is
'Owner of the table'
/
comment on column DBA_STREAMS_UNSUPPORTED.TABLE_NAME is
'Name of the table'
/
comment on column DBA_STREAMS_UNSUPPORTED.REASON is
'Reason why the table is not supported'
/
comment on column DBA_STREAMS_UNSUPPORTED.AUTO_FILTERED is
'Does Streams automatically filter out this object'
/

create or replace public synonym DBA_STREAMS_UNSUPPORTED
  for DBA_STREAMS_UNSUPPORTED
/
grant select on DBA_STREAMS_UNSUPPORTED to select_catalog_role
/


/* we can't use all_tables because object tables aren't listed in it */
create or replace view ALL_STREAMS_UNSUPPORTED
as select s.* from DBA_STREAMS_UNSUPPORTED s, ALL_OBJECTS a
   where s.owner = a.owner
     and s.table_name = a.object_name
     and a.object_type = 'TABLE';

comment on table ALL_STREAMS_UNSUPPORTED is
'List of all the tables that are not supported by Streams in this release'
/

comment on column ALL_STREAMS_UNSUPPORTED.OWNER is
'Owner of the table'
/
comment on column ALL_STREAMS_UNSUPPORTED.TABLE_NAME is
'Name of the table'
/
comment on column ALL_STREAMS_UNSUPPORTED.REASON is
'Reason why the table is not supported'
/
comment on column ALL_STREAMS_UNSUPPORTED.AUTO_FILTERED is
'Does Streams automatically filter out this object'
/

create or replace public synonym ALL_STREAMS_UNSUPPORTED
  for ALL_STREAMS_UNSUPPORTED
/

grant select on ALL_STREAMS_UNSUPPORTED to PUBLIC with grant option
/

create or replace view DBA_STREAMS_NEWLY_SUPPORTED
  (owner, table_name, reason, compatible)
as
  select owner, table_name, reason, compatible
    from (select * from "_DBA_STREAMS_NEWLY_SUPTED_10_1" 
          where str_compat <= dbms_logrep_util.get_str_compat() union
          select * from "_DBA_STREAMS_NEWLY_SUPTED_10_2" 
          where str_compat <= dbms_logrep_util.get_str_compat());

comment on table DBA_STREAMS_NEWLY_SUPPORTED is
'List of tables that are newly supported by Streams'
/
comment on column DBA_STREAMS_NEWLY_SUPPORTED.OWNER is
'Owner of the table'
/
comment on column DBA_STREAMS_NEWLY_SUPPORTED.TABLE_NAME is
'Name of the table'
/
comment on column DBA_STREAMS_NEWLY_SUPPORTED.REASON is
'Reason why the table was not supported in some previous release'
/
comment on column DBA_STREAMS_NEWLY_SUPPORTED.COMPATIBLE is
'The latest compatible setting when this table was unsupported'
/

create or replace public synonym DBA_STREAMS_NEWLY_SUPPORTED
  for DBA_STREAMS_NEWLY_SUPPORTED
/
grant select on DBA_STREAMS_NEWLY_SUPPORTED to select_catalog_role
/

/* we can't use all_tables because object tables aren't listed in it */
create or replace view all_streams_newly_supported
as
  select s.* from dba_streams_newly_supported s, all_objects a
    where s.owner = a.owner
      and s.table_name = a.object_name
      and a.object_type = 'TABLE';

comment on table ALL_STREAMS_NEWLY_SUPPORTED is
'List of tables that are newly supported by Streams'
/
comment on column ALL_STREAMS_NEWLY_SUPPORTED.OWNER is
'Owner of the table'
/
comment on column ALL_STREAMS_NEWLY_SUPPORTED.TABLE_NAME is
'Name of the table'
/
comment on column ALL_STREAMS_NEWLY_SUPPORTED.REASON is
'Reason why the table was not supported in some previous release'
/
comment on column ALL_STREAMS_NEWLY_SUPPORTED.COMPATIBLE is
'The least compatible setting when this table is supported'
/

create or replace public synonym ALL_STREAMS_NEWLY_SUPPORTED
  for ALL_STREAMS_NEWLY_SUPPORTED
/

grant select on ALL_STREAMS_NEWLY_SUPPORTED to PUBLIC with grant option
/

----------------------------------------------------------------------------
-- Views on streams$_internal_transform table
----------------------------------------------------------------------------

-- Private view select to all columns from streams$_internal_transform
-- Used by export. Respective catalog views will select from this view.
create or replace view "_DBA_STREAMS_TRANSFORMATIONS"
as select * from sys.streams$_internal_transform
/
grant select on "_DBA_STREAMS_TRANSFORMATIONS" to exp_full_database
/

create or replace view DBA_STREAMS_TRANSFORMATIONS
  (RULE_OWNER, RULE_NAME, TRANSFORM_TYPE, FROM_SCHEMA_NAME, TO_SCHEMA_NAME,
   FROM_TABLE_NAME, TO_TABLE_NAME, SCHEMA_NAME, TABLE_NAME,
   FROM_COLUMN_NAME, TO_COLUMN_NAME, COLUMN_NAME, COLUMN_VALUE,
   COLUMN_TYPE, COLUMN_FUNCTION, VALUE_TYPE, USER_FUNCTION_NAME,
   SUBSETTING_OPERATION, DML_CONDITION, DECLARATIVE_TYPE, PRECEDENCE,
   STEP_NUMBER)
as
select rule_owner, rule_name, 'DECLARATIVE TRANSFORMATION',
  from_schema_name, to_schema_name, from_table_name, to_table_name,
  schema_name, table_name, from_column_name, to_column_name,
  column_name, column_value, sys.anydata.gettypename(column_value), 
  column_function, 
  decode(value_type, 1, 'OLD',
                     2, 'NEW',
                     3, '*'), 
  NULL, NULL, NULL,  decode(declarative_type, 1, 'DELETE COLUMN',
                                              2, 'RENAME COLUMN',
                                              3, 'ADD COLUMN',
                                              4, 'RENAME TABLE',
                                              5, 'RENAME SCHEMA'), 
  precedence, step_number
  from "_DBA_STREAMS_TRANSFORMATIONS" t
union all
select rule_owner, rule_name, 'SUBSET RULE', NULL, NULL, NULL, NULL,
  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
  decode(subsetting_operation, 1, 'INSERT',
                               2, 'UPDATE',
                               3, 'DELETE'),
  dml_condition, NULL, NULL, NULL
  from sys.streams$_rules where subsetting_operation is not NULL
union all
select rule_owner, rule_name, 'CUSTOM TRANSFORMATION', NULL, NULL, NULL, NULL,
  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
  transform_function_name, NULL, NULL, NULL, NULL, NULL
  from "_DBA_STREAMS_TRANSFM_FUNCTION"
/

comment on table DBA_STREAMS_TRANSFORMATIONS is
'Transformations defined on rules'
/
comment on column DBA_STREAMS_TRANSFORMATIONS.RULE_OWNER is
'Owner of the rule which has an associated transformation'
/
comment on column DBA_STREAMS_TRANSFORMATIONS.RULE_NAME is
'Name of the rule which has an associated transformation'
/
comment on column DBA_STREAMS_TRANSFORMATIONS.TRANSFORM_TYPE is
'The type of transformation'
/
comment on column DBA_STREAMS_TRANSFORMATIONS.FROM_SCHEMA_NAME is
'The schema to be renamed'
/
comment on column DBA_STREAMS_TRANSFORMATIONS.TO_SCHEMA_NAME is
'The new schema name'
/
comment on column DBA_STREAMS_TRANSFORMATIONS.FROM_TABLE_NAME is
'The table to be renamed'
/
comment on column DBA_STREAMS_TRANSFORMATIONS.TO_TABLE_NAME is
'The new table name'
/
comment on column DBA_STREAMS_TRANSFORMATIONS.SCHEMA_NAME is
'The schema of the column to be modified'
/
comment on column DBA_STREAMS_TRANSFORMATIONS.TABLE_NAME is
'The table of the column to be modified'
/
comment on column DBA_STREAMS_TRANSFORMATIONS.FROM_COLUMN_NAME is
'The column to rename'
/
comment on column DBA_STREAMS_TRANSFORMATIONS.TO_COLUMN_NAME is
'The new column name'
/
comment on column DBA_STREAMS_TRANSFORMATIONS.COLUMN_NAME is
'The column to add or delete'
/
comment on column DBA_STREAMS_TRANSFORMATIONS.COLUMN_VALUE is
'The value of the column to add'
/
comment on column DBA_STREAMS_TRANSFORMATIONS.COLUMN_TYPE is
'The type of the new column'
/
comment on column DBA_STREAMS_TRANSFORMATIONS.COLUMN_FUNCTION is
'The name of the default function used to add a column'
/
comment on column DBA_STREAMS_TRANSFORMATIONS.USER_FUNCTION_NAME is
'The name of the user-defined transformation function to run '
/
comment on column DBA_STREAMS_TRANSFORMATIONS.SUBSETTING_OPERATION is
'DML operation for row subsetting'
/
comment on column DBA_STREAMS_TRANSFORMATIONS.DML_CONDITION is
'Row subsetting condition'
/
comment on column DBA_STREAMS_TRANSFORMATIONS.DECLARATIVE_TYPE is
'The type of declarative transformation to run'
/
comment on column DBA_STREAMS_TRANSFORMATIONS.PRECEDENCE is
'Execution order relative to other declarative transformations on the same step_number'
/
comment on column DBA_STREAMS_TRANSFORMATIONS.STEP_NUMBER is
'The order that this transformation should be executed'
/

create or replace public synonym DBA_STREAMS_TRANSFORMATIONS
  for DBA_STREAMS_TRANSFORMATIONS
/
grant select on DBA_STREAMS_TRANSFORMATIONS to select_catalog_role
/


-- Rename Schema
create or replace view DBA_STREAMS_RENAME_SCHEMA
  (RULE_OWNER, RULE_NAME, FROM_SCHEMA_NAME, TO_SCHEMA_NAME,
   PRECEDENCE, STEP_NUMBER)
as
select rule_owner, rule_name, from_schema_name, to_schema_name,
  precedence, step_number
  from DBA_STREAMS_TRANSFORMATIONS
  where declarative_type = 'RENAME SCHEMA';
/

comment on table DBA_STREAMS_RENAME_SCHEMA is
'Rename schema transformations'
/
comment on column DBA_STREAMS_RENAME_SCHEMA.RULE_OWNER is
'Owner of the rule which has an associated transformation'
/
comment on column DBA_STREAMS_RENAME_SCHEMA.RULE_NAME is
'Name of the rule which has an associated transformation'
/
comment on column DBA_STREAMS_RENAME_SCHEMA.FROM_SCHEMA_NAME is
'The schema to be renamed'
/
comment on column DBA_STREAMS_RENAME_SCHEMA.TO_SCHEMA_NAME is
'The new schema name'
/
comment on column DBA_STREAMS_RENAME_SCHEMA.PRECEDENCE is
'Execution order relative to other declarative transformations on the same step_number'
/
comment on column DBA_STREAMS_RENAME_SCHEMA.STEP_NUMBER is
'The order that this transformation should be executed'
/

create or replace public synonym DBA_STREAMS_RENAME_SCHEMA
  for DBA_STREAMS_RENAME_SCHEMA
/
grant select on DBA_STREAMS_RENAME_SCHEMA to select_catalog_role
/

-- Rename table
create or replace view DBA_STREAMS_RENAME_TABLE
  (RULE_OWNER, RULE_NAME, FROM_SCHEMA_NAME, TO_SCHEMA_NAME,
   FROM_TABLE_NAME, TO_TABLE_NAME, PRECEDENCE, STEP_NUMBER)
as
select rule_owner, rule_name, from_schema_name, to_schema_name,
       from_table_name, to_table_name, precedence, step_number
  from DBA_STREAMS_TRANSFORMATIONS
  where declarative_type = 'RENAME TABLE';
/

comment on table DBA_STREAMS_RENAME_TABLE is
'Rename table transformations'
/
comment on column DBA_STREAMS_RENAME_TABLE.RULE_OWNER is
'Owner of the rule which has an associated transformation'
/
comment on column DBA_STREAMS_RENAME_TABLE.RULE_NAME is
'Name of the rule which has an associated transformation'
/
comment on column DBA_STREAMS_RENAME_TABLE.FROM_SCHEMA_NAME is
'The schema to be renamed'
/
comment on column DBA_STREAMS_RENAME_TABLE.TO_SCHEMA_NAME is
'The new schema name'
/
comment on column DBA_STREAMS_RENAME_TABLE.FROM_TABLE_NAME is
'The table to be renamed'
/
comment on column DBA_STREAMS_RENAME_TABLE.TO_TABLE_NAME is
'The new table name'
/
comment on column DBA_STREAMS_RENAME_TABLE.PRECEDENCE is
'Execution order relative to other declarative transformations on the same step_number'
/
comment on column DBA_STREAMS_RENAME_TABLE.STEP_NUMBER is
'The order that this transformation should be executed'
/

create or replace public synonym DBA_STREAMS_RENAME_TABLE
  for DBA_STREAMS_RENAME_TABLE
/
grant select on DBA_STREAMS_RENAME_TABLE to select_catalog_role
/


-- Delete column
create or replace view DBA_STREAMS_DELETE_COLUMN
  (RULE_OWNER, RULE_NAME, SCHEMA_NAME, TABLE_NAME, COLUMN_NAME,
   VALUE_TYPE, PRECEDENCE, STEP_NUMBER)
as
select rule_owner, rule_name, schema_name, table_name, column_name,
       value_type, precedence, step_number
  from DBA_STREAMS_TRANSFORMATIONS
  where declarative_type = 'DELETE COLUMN';
/

comment on table DBA_STREAMS_DELETE_COLUMN is
'Delete column transformations'
/
comment on column DBA_STREAMS_DELETE_COLUMN.RULE_OWNER is
'Owner of the rule which has an associated transformation'
/
comment on column DBA_STREAMS_DELETE_COLUMN.RULE_NAME is
'Name of the rule which has an associated transformation'
/
comment on column DBA_STREAMS_DELETE_COLUMN.SCHEMA_NAME is
'The schema of the column to be modified'
/
comment on column DBA_STREAMS_DELETE_COLUMN.TABLE_NAME is
'The table of the column to be modified'
/
comment on column DBA_STREAMS_DELETE_COLUMN.COLUMN_NAME is
'The column to delete'
/
comment on column DBA_STREAMS_DELETE_COLUMN.VALUE_TYPE is
'Whether to delete the old column value of the lcr, the new value, or both'
/
comment on column DBA_STREAMS_DELETE_COLUMN.PRECEDENCE is
'Execution order relative to other declarative transformations on the same step_number'
/
comment on column DBA_STREAMS_DELETE_COLUMN.STEP_NUMBER is
'The order that this transformation should be executed'
/

create or replace public synonym DBA_STREAMS_DELETE_COLUMN
  for DBA_STREAMS_DELETE_COLUMN
/
grant select on DBA_STREAMS_DELETE_COLUMN to select_catalog_role
/

-- Rename column
create or replace view DBA_STREAMS_RENAME_COLUMN
  (RULE_OWNER, RULE_NAME, SCHEMA_NAME, TABLE_NAME, FROM_COLUMN_NAME,
   TO_COLUMN_NAME, VALUE_TYPE, PRECEDENCE, STEP_NUMBER)
as
select rule_owner, rule_name, schema_name, table_name, from_column_name,
       to_column_name, value_type, precedence, step_number
  from DBA_STREAMS_TRANSFORMATIONS
  where declarative_type = 'RENAME COLUMN';
/

comment on table DBA_STREAMS_RENAME_COLUMN is
'Rename column transformations'
/
comment on column DBA_STREAMS_RENAME_COLUMN.RULE_OWNER is
'Owner of the rule which has an associated transformation'
/
comment on column DBA_STREAMS_RENAME_COLUMN.RULE_NAME is
'Name of the rule which has an associated transformation'
/
comment on column DBA_STREAMS_RENAME_COLUMN.SCHEMA_NAME is
'The schema of the column to be modified'
/
comment on column DBA_STREAMS_RENAME_COLUMN.TABLE_NAME is
'The table of the column to be modified'
/
comment on column DBA_STREAMS_RENAME_COLUMN.FROM_COLUMN_NAME is
'The column to rename'
/
comment on column DBA_STREAMS_RENAME_COLUMN.TO_COLUMN_NAME is
'The new column name'
/
comment on column DBA_STREAMS_RENAME_COLUMN.VALUE_TYPE is
'Whether to rename to the old column value of the lcr, the new value, or both'
/
comment on column DBA_STREAMS_RENAME_COLUMN.PRECEDENCE is
'Execution order relative to other declarative transformations on the same step_number'
/
comment on column DBA_STREAMS_RENAME_COLUMN.STEP_NUMBER is
'The order that this transformation should be executed'
/

create or replace public synonym DBA_STREAMS_RENAME_COLUMN
  for DBA_STREAMS_RENAME_COLUMN
/
grant select on DBA_STREAMS_RENAME_COLUMN to select_catalog_role
/

-- Add column
create or replace view DBA_STREAMS_ADD_COLUMN
  (RULE_OWNER, RULE_NAME, SCHEMA_NAME, TABLE_NAME, COLUMN_NAME,
   COLUMN_VALUE, COLUMN_TYPE, COLUMN_FUNCTION, VALUE_TYPE, PRECEDENCE,
   STEP_NUMBER) 
as
select rule_owner, rule_name, schema_name, table_name, column_name,
       column_value, sys.anydata.gettypename(column_value), column_function, 
       value_type, precedence, step_number 
  from DBA_STREAMS_TRANSFORMATIONS
  where declarative_type = 'ADD COLUMN';
/

comment on table DBA_STREAMS_ADD_COLUMN is
'Add column transformations'
/
comment on column DBA_STREAMS_ADD_COLUMN.RULE_OWNER is
'Owner of the rule which has an associated transformation'
/
comment on column DBA_STREAMS_ADD_COLUMN.RULE_NAME is
'Name of the rule which has an associated transformation'
/
comment on column DBA_STREAMS_ADD_COLUMN.SCHEMA_NAME is
'The schema of the column to be modified'
/
comment on column DBA_STREAMS_ADD_COLUMN.TABLE_NAME is
'The table of the column to be modified'
/
comment on column DBA_STREAMS_ADD_COLUMN.COLUMN_NAME is
'The column to add'
/
comment on column DBA_STREAMS_ADD_COLUMN.COLUMN_VALUE is
'The value of the column to add'
/
comment on column DBA_STREAMS_ADD_COLUMN.COLUMN_TYPE is
'The type of the new column'
/
comment on column DBA_STREAMS_ADD_COLUMN.COLUMN_FUNCTION is
'The name of the default function used to add a column'
/
comment on column DBA_STREAMS_ADD_COLUMN.VALUE_TYPE is
'Whether to add to the old value of the lcr, the new value, or both'
/
comment on column DBA_STREAMS_ADD_COLUMN.PRECEDENCE is
'Execution order relative to other declarative transformations on the same step_number'
/
comment on column DBA_STREAMS_ADD_COLUMN.STEP_NUMBER is
'The order that this transformation should be executed'
/

create or replace public synonym DBA_STREAMS_ADD_COLUMN
  for DBA_STREAMS_ADD_COLUMN
/
grant select on DBA_STREAMS_ADD_COLUMN to select_catalog_role
/
----------------------------------------------------------------------------

/* support drop user cascade */
DELETE FROM sys.duc$ WHERE owner='SYS' AND pack='DBMS_STREAMS_ADM_UTL' 
  AND proc='PROCESS_DROP_USER_CASCADE' AND operation#=1
/
INSERT INTO sys.duc$ (owner, pack, proc, operation#, seq, com)
  VALUES ('SYS', 'DBMS_STREAMS_ADM_UTL', 'PROCESS_DROP_USER_CASCADE', 1, 1,
          'Drop any capture or apply processes for this user')
/
commit;
                            
/* name-value types to be stored in an anydata object in the user properties
 * column of the queue table.  We would have stored the value as type AnyData, 
 * but wrapping a AnyData inside of a AnyData is prohibited. */
CREATE OR REPLACE TYPE sys.streams$nv_node 
TIMESTAMP '1997-04-12:12:59:00' OID 'BE329A8842822386E0340003BA0FD53F'
AS OBJECT
( nvn_name       varchar2(32),
  nvn_value_vc2  varchar2(4000),
  nvn_value_raw  raw(32),
  nvn_value_num  number,
  nvn_value_date date)
/

CREATE OR REPLACE TYPE sys.streams$nv_array 
TIMESTAMP '1997-04-12:12:59:00' OID 'BE329A88428A2386E0340003BA0FD53F'
AS VARRAY(1024) of sys.streams$nv_node
/

/* Types used in internal lcr transformation */
CREATE OR REPLACE TYPE sys.streams$transformation_info
TIMESTAMP '1997-04-12:12:59:00' OID 'D307723624873404E0340003BA0FD53F'
AS OBJECT
( transform_type     number, 
  operation          number,
  from_schema_name   varchar2(30),  
  to_schema_name     varchar2(30),
  from_table_name    varchar2(30),
  to_table_name      varchar2(30),
  schema_name        varchar2(30),  
  table_name         varchar2(30),
  value_type         number,
  from_column_name   varchar2(4000),
  to_column_name     varchar2(4000),
  column_name        varchar2(4000),
  column_value_vc2   varchar2(4000),
  column_value_raw   raw(4000),
  column_value_num   number,
  column_value_date  date,
  column_value_nvc2  nvarchar2(2000),
  column_value_bflt  binary_float,
  column_value_bdbl  binary_double,
  column_value_ts    timestamp,
  column_value_tz    timestamp with time zone,
  column_value_ltz   timestamp with local time zone, 
  column_value_iym   interval year to month,
  column_value_ids   interval day to second,
  column_value_char  char(2000),
  column_value_nchar nchar(1000),
  column_value_urid  varchar2(4000),
  column_type        number,
  column_function    varchar2(4000),
  step_number        number)
/

CREATE OR REPLACE TYPE sys.streams$_anydata_array
 AS VARRAY(2147483647) of sys.anydata
/

grant execute on sys.streams$_anydata_array to PUBLIC
/

/* Register internal action context export function with the rules
 * engine.  The first parameter should match
 * dbms_streams_decl.inttrans_rule_id. 
 */ 
BEGIN
  sys.dbms_ruleadm_internal.register_internal_actx('streams_it',
           'sys.dbms_logrep_exp.internal_transform_export');
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- Recoverable script : view showing recoverable script operation details
create or replace view DBA_RECOVERABLE_SCRIPT
(SCRIPT_ID, CREATION_TIME, INVOKING_PACKAGE_OWNER, INVOKING_PACKAGE,
 INVOKING_PROCEDURE, INVOKING_USER, STATUS, TOTAL_BLOCKS, DONE_BLOCK_NUM, 
 SCRIPT_COMMENT)
as
select oid, ctime, invoking_package_owner, invoking_package,
  invoking_procedure, invoking_user,
  decode(status, 1, 'GENERATING',
                 2, 'NOT EXECUTED',
                 3, 'EXECUTING',
                 4, 'EXECUTED',
                 5, 'ERROR'),
  total_blocks, done_block_num, script_comment
from sys.reco_script$
/

comment on table DBA_RECOVERABLE_SCRIPT is
'Details about recoverable operations'
/
comment on column DBA_RECOVERABLE_SCRIPT.SCRIPT_ID is
'Unique id of the operation'
/
comment on column DBA_RECOVERABLE_SCRIPT.CREATION_TIME is
'Time the operation was invoked'
/
comment on column DBA_RECOVERABLE_SCRIPT.INVOKING_PACKAGE_OWNER is
'Invoking package owner of the operation'
/
comment on column DBA_RECOVERABLE_SCRIPT.INVOKING_PACKAGE is
'Invoking package of the operation'
/
comment on column DBA_RECOVERABLE_SCRIPT.INVOKING_PROCEDURE is
'Invoking procedure of the operation'
/
comment on column DBA_RECOVERABLE_SCRIPT.INVOKING_USER is
'Script owner'
/
comment on column DBA_RECOVERABLE_SCRIPT.STATUS is
'state of the recoverable script: EXECUTING, GENERATING'
/
comment on column DBA_RECOVERABLE_SCRIPT.DONE_BLOCK_NUM is
'last block so far executed'
/
comment on column DBA_RECOVERABLE_SCRIPT.TOTAL_BLOCKS is
'total number of blocks for the recoverable script to be executed'
/
comment on column DBA_RECOVERABLE_SCRIPT.SCRIPT_COMMENT is
'comment for the recoverable script'
/
create or replace public synonym DBA_RECOVERABLE_SCRIPT
  for DBA_RECOVERABLE_SCRIPT
/
grant select on DBA_RECOVERABLE_SCRIPT to select_catalog_role
/


-- Recoverable script : view showing operation parameters
create or replace view DBA_RECOVERABLE_SCRIPT_PARAMS
(SCRIPT_ID, PARAMETER, PARAM_INDEX, VALUE)
as
select oid, name, param_index, value
from sys.reco_script_params$
/
comment on table DBA_RECOVERABLE_SCRIPT_PARAMS is
'Details about the recoverable operation parameters'
/
comment on column DBA_RECOVERABLE_SCRIPT_PARAMS.SCRIPT_ID is
'Unique id of the operation'
/
comment on column DBA_RECOVERABLE_SCRIPT_PARAMS.PARAMETER is
'Name of the parameter'
/
comment on column DBA_RECOVERABLE_SCRIPT_PARAMS.PARAM_INDEX is
'Index for multi-valued parameter' 
/
comment on column DBA_RECOVERABLE_SCRIPT_PARAMS.VALUE is
'Value of the parameter'
/
create or replace public synonym DBA_RECOVERABLE_SCRIPT_PARAMS
  for DBA_RECOVERABLE_SCRIPT_PARAMS
/
grant select on DBA_RECOVERABLE_SCRIPT_PARAMS to select_catalog_role
/


-- Recoverable script : view showing recoverable script blocks
create or replace view DBA_RECOVERABLE_SCRIPT_BLOCKS
(SCRIPT_ID, BLOCK_NUM, FORWARD_BLOCK, FORWARD_BLOCK_DBLINK, UNDO_BLOCK,
 UNDO_BLOCK_DBLINK, STATUS, BLOCK_COMMENT)
as
select oid, block_num, forward_block, forward_block_dblink, undo_block,
undo_block_dblink,
decode(status, 1, 'GENERATING',
               2, 'NOT EXECUTED',
               3, 'EXECUTING',
               4, 'EXECUTED',
               5, 'ERROR'),
block_comment
from sys.reco_script_block$
/
comment on table DBA_RECOVERABLE_SCRIPT_BLOCKS is
'Details about the recoverable script blocks'
/
comment on column DBA_RECOVERABLE_SCRIPT_BLOCKS.SCRIPT_ID is
'global unique id of the recoverable script to which this block belongs'
/
comment on column DBA_RECOVERABLE_SCRIPT_BLOCKS.BLOCK_NUM is
'nth block in the recoverable script to be executed'
/
comment on column DBA_RECOVERABLE_SCRIPT_BLOCKS.FORWARD_BLOCK is
'forward block to be executed'
/
comment on column DBA_RECOVERABLE_SCRIPT_BLOCKS.FORWARD_BLOCK_DBLINK is
'database where the forward block is executed'
/
comment on column DBA_RECOVERABLE_SCRIPT_BLOCKS.UNDO_BLOCK is
'block to rollback the forward operation'
/
comment on column DBA_RECOVERABLE_SCRIPT_BLOCKS.UNDO_BLOCK_DBLINK is
'database where the undo block is executed'
/
comment on column DBA_RECOVERABLE_SCRIPT_BLOCKS.STATUS is
'status of the block execution - NOT_STARTED, EXECUTING, DONE, ERROR'
/
comment on column DBA_RECOVERABLE_SCRIPT_BLOCKS.BLOCK_COMMENT is
'comment for the block'
/
create or replace public synonym DBA_RECOVERABLE_SCRIPT_BLOCKS
  for DBA_RECOVERABLE_SCRIPT_BLOCKS
/
grant select on DBA_RECOVERABLE_SCRIPT_BLOCKS to select_catalog_role
/


-- Recoverable script : view showing recoverable script errors
create or replace view DBA_RECOVERABLE_SCRIPT_ERRORS
(SCRIPT_ID, BLOCK_NUM, ERROR_NUMBER, ERROR_MESSAGE, ERROR_CREATION_TIME)
as
select oid, block_num, error_number, error_message, error_creation_time
from sys.reco_script_error$ 
/
comment on table DBA_RECOVERABLE_SCRIPT_ERRORS is
'Details showing errors during script execution'
/
comment on column DBA_RECOVERABLE_SCRIPT_ERRORS.SCRIPT_ID is
'global unique id of the recoverable script'
/
comment on column DBA_RECOVERABLE_SCRIPT_ERRORS.BLOCK_NUM is
'nth block that failed'
/
comment on column DBA_RECOVERABLE_SCRIPT_ERRORS.ERROR_NUMBER is
'error number of error encountered while executing the block'
/
comment on column DBA_RECOVERABLE_SCRIPT_ERRORS.ERROR_MESSAGE is
'error message of error encountered while executing the block'
/
comment on column DBA_RECOVERABLE_SCRIPT_ERRORS.ERROR_CREATION_TIME is
'time error was created'
/
create or replace public synonym DBA_RECOVERABLE_SCRIPT_ERRORS
  for DBA_RECOVERABLE_SCRIPT_ERRORS
/
grant select on DBA_RECOVERABLE_SCRIPT_ERRORS to select_catalog_role
/


----------------------------------------------------------------------------
-- V$STREAMS_TRANSACTION
----------------------------------------------------------------------------
create or replace view GV_$STREAMS_TRANSACTION
  as select * from gv$streams_transaction
/
create or replace public synonym GV$STREAMS_TRANSACTION 
  for GV_$STREAMS_TRANSACTION
/
grant select on GV_$STREAMS_TRANSACTION to select_catalog_role
/
----------------------------------------------------------------------------
create or replace view V_$STREAMS_TRANSACTION
  as select * from v$streams_transaction
/
create or replace public synonym V$STREAMS_TRANSACTION 
  for V_$STREAMS_TRANSACTION
/
grant select on V_$STREAMS_TRANSACTION to select_catalog_role
/
