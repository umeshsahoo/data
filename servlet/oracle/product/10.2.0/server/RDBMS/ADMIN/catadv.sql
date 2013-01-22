Rem
Rem $Header: catadv.sql 14-mar-2005.11:23:47 bkuchibh Exp $
Rem
Rem catadv.sql
Rem
Rem Copyright (c) 2002, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catadv.sql - Advisor Framework definitions
Rem
Rem    DESCRIPTION
Rem      This file creates the following components for the advisor framework
Rem        - types
Rem        - tables, indexes
Rem        - views
Rem        - loads the pl/sql packages
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    bkuchibh    03/14/05 - Fix Bug 4113632 
Rem    kyagoub     10/10/04 - add other column to advisor objects view 
Rem    gssmith     02/05/04 - Change journal keywords 
Rem    gssmith     01/29/04 - Adding flags to wri$_adv_recommendations 
Rem    kdias       01/08/04 - 'add new finding type' 
Rem    ushaft      11/25/03 - Finish bug 3207351 -  
Rem                           add column advisor_id to view dba_advisor_tasks 
Rem    gssmith     11/05/03 - 
Rem    gssmith     10/23/03 - Bug 3207351 
Rem    kdias       10/09/03 - use user$ instead of all_users 
Rem    gssmith     09/23/03 - Expose flags in DEF_PARAMETERS view 
Rem    gssmith     10/06/03 - Add Access Advisor hidden actions 
Rem    kyagoub     05/03/03 - remove message from recommendation and 
Rem                           add type to rationale
Rem    kyagoub     03/27/03 - extend finding type, add news attributes to the 
Rem                           rationale table and grant user_xxx to public
Rem    kyagoub     03/17/03 - add recommendation type
Rem    bdagevil    04/28/03 - merge new file
Rem    gssmith     05/01/03 - AA workload adjustments
Rem    gssmith     04/15/03 - 
Rem    gssmith     04/15/03 - Change Mode
Rem    gssmith     04/10/03 - Move static data inserts from catadvtb
Rem    gssmith     03/26/03 - Bug 2869857
Rem    gssmith     02/21/03 - Bug 2815817
Rem    kdias       03/12/03 - modify advisor_usage view
Rem    ushaft      03/07/03 - changed definitions of views over parameters to
Rem                           support new flags
Rem    gssmith     01/30/03 - Fix user view privs
Rem    gssmith     01/29/03 - Typo in USER_ADVISOR_LOG view
Rem    gssmith     01/09/03 - Bug 2657007
Rem    gssmith     11/27/02 - Add new column to actions table
Rem    gssmith     11/12/02 - Fix log table
Rem    kdias       10/31/02 - modify findings, rec view
Rem    gssmith     10/23/02 - Bugs
Rem    gssmith     10/22/02 - Add task_name to views
Rem    gssmith     10/18/02 - Bug 2631064
Rem    btao        10/03/02 - add select_catalog_role
Rem    kdias       10/03/02 - modify adv_commands defn
Rem    kdias       09/30/02 - modify view defns to reflect new cols
Rem    kdias       09/24/02 - remove type from advisor definition
Rem    gssmith     09/20/02 - remove task type
Rem    gssmith     09/13/02 - Adding templates
Rem    gssmith     09/05/02 - gssmith_adv0806
Rem    gssmith     09/04/02 - wip
Rem    gssmith     08/30/02 - 
Rem    gssmith     08/29/02 - wip
Rem    gssmith     08/23/02 - wip
Rem    gssmith     08/19/02 - clean up views
Rem    kdias       07/26/02 - add views
Rem    kdias       07/19/02 - more schema changes.
Rem    kdias       06/11/02 - Created
Rem

Rem
Rem The initial part of this file is for Framework definitions only.
Rem Individual advisors can add their type declarations at the end just
Rem before the tabels are populated.
Rem
 

create or replace view dba_advisor_definitions
   as select id as advisor_id,
             name as advisor_name,
             property as property
      from wri$_adv_definitions
      where id > 0;

create or replace public synonym dba_advisor_definitions
   for sys.dba_advisor_definitions;
grant select on dba_advisor_definitions to select_catalog_role;

create or replace view dba_advisor_commands
   as select a.indx as command_id,
             a.command_name as command_name
      from x$keacmdn a;

create or replace public synonym dba_advisor_commands
   for sys.dba_advisor_commands;
grant select on dba_advisor_commands to select_catalog_role;

create or replace view dba_advisor_object_types
   as select a.indx as object_type_id,
             a.object_type as object_type
      from x$keaobjt a;

create or replace public synonym dba_advisor_object_types
   for sys.dba_advisor_object_types;

create or replace view dba_advisor_usage
  as select a.advisor_id,
            a.last_exec_time,
            a.num_execs
     from sys.wri$_adv_usage a
     where a.advisor_id > 0 ;

create or replace public synonym dba_advisor_usage
   for sys.dba_advisor_usage;
grant select on dba_advisor_usage to select_catalog_role;

create or replace view dba_advisor_tasks
   as select a.owner_name as owner,
             a.id as task_id,
             a.name as task_name,
             a.description as description,
             a.advisor_name as advisor_name,
             a.ctime as created,
             a.mtime as last_modified,
             a.parent_id as parent_task_id,
             a.parent_rec_id as parent_rec_id,
             a.exec_start as execution_start,
             a.exec_end as execution_end,
             decode(a.status, 1, 'INITIAL',
                              2, 'EXECUTING',
                              3, 'COMPLETED',
                              4, 'INTERRUPTED',
                              5, 'CANCELLED',
                              6, 'FATAL ERROR') as status,
             dbms_advisor.format_message_group(a.status_msg_id) as status_message,
             a.pct_completion_time as pct_completion_time,
             a.progress_metric as progress_metric,
             a.metric_units as metric_units,
             a.activity_counter as activity_counter,
             a.rec_count as recommendation_count,
             dbms_advisor.format_message_group(a.error_msg#) as error_message,
             a.source as source,
             a.how_created as how_created,
             decode(bitand(a.property,1), 1, 'TRUE', 'FALSE') as read_only,
             a.advisor_id as advisor_id
      from wri$_adv_tasks a
      where bitand(a.property,6) = 4;

create or replace public synonym dba_advisor_tasks
   for dba_advisor_tasks;
grant select on dba_advisor_tasks to select_catalog_role;

create or replace view user_advisor_tasks
   as select a.id as task_id,
             a.name as task_name,
             a.description as description,
             a.advisor_name as advisor_name,
             a.ctime as created,
             a.mtime as last_modified,
             a.parent_id as parent_task_id,
             a.parent_rec_id as parent_rec_id,
             a.exec_start as execution_start,
             a.exec_end as execution_end,
             decode(a.status, 1, 'INITIAL',
                              2, 'EXECUTING',
                              3, 'COMPLETED',
                              4, 'INTERRUPTED',
                              5, 'CANCELLED',
                              6, 'FATAL ERROR') as status,
             dbms_advisor.format_message_group(a.status_msg_id) as status_message,
             a.pct_completion_time as pct_completion_time,
             a.progress_metric as progress_metric,
             a.metric_units as metric_units,
             a.activity_counter as activity_counter,
             a.rec_count as recommendation_count,
             dbms_advisor.format_message_group(a.error_msg#) as error_message,
             a.source as source,
             a.how_created as how_created,
             decode(bitand(a.property,1), 1, 'TRUE', 'FALSE') as read_only,
             a.advisor_id as advisor_id
      from wri$_adv_tasks a
      where a.owner# = userenv('SCHEMAID')
        and bitand(a.property,6) = 4;

create or replace public synonym user_advisor_tasks
   for user_advisor_tasks;
grant select on user_advisor_tasks to public;


create or replace view dba_advisor_templates
   as select a.owner_name as owner,
             a.id as task_id,
             a.name as task_name,
             a.description as description,
             a.advisor_name as advisor_name,
             a.ctime as created,
             a.mtime as last_modified,
             a.source as source,
             decode(bitand(a.property,1), 1, 'TRUE', 'FALSE') as read_only
      from wri$_adv_tasks a
      where bitand(a.property,6) = 6;

create or replace public synonym dba_advisor_templates
   for dba_advisor_templates;
grant select on dba_advisor_templates to select_catalog_role;

create or replace view user_advisor_templates
   as select a.id as task_id,
             a.name as task_name,
             a.description as description,
             a.advisor_name as advisor_name,
             a.ctime as created,
             a.mtime as last_modified,
             a.source as source,
             decode(bitand(a.property,1), 1, 'TRUE', 'FALSE') as read_only
      from wri$_adv_tasks a
      where a.owner# = userenv('SCHEMAID')
        and bitand(a.property,6) = 6;

create or replace public synonym user_advisor_templates
   for user_advisor_templates;
grant select on user_advisor_templates to public;

create or replace view dba_advisor_log as 
  select a.owner_name as owner,
         a.id as task_id,
         a.name as task_name,
         a.exec_start as execution_start,
         a.exec_end as execution_end,
         decode(a.status, 1, 'INITIAL',
                          2, 'EXECUTING',
                          3, 'COMPLETED',
                          4, 'INTERRUPTED',
                          5, 'CANCELLED',
                          6, 'FATAL ERROR') as status,
         dbms_advisor.format_message_group(a.status_msg_id) as status_message,
         a.pct_completion_time as pct_completion_time,
         a.progress_metric as progress_metric,
         a.metric_units as metric_units,
         a.activity_counter as activity_counter,
         a.rec_count as recommendation_count,
         dbms_advisor.format_message_group(a.error_msg#) as error_message
  from wri$_adv_tasks a
  where bitand(a.property,6) = 4;

create or replace public synonym dba_advisor_log
   for dba_advisor_log;
grant select on dba_advisor_log to select_catalog_role;
      
create or replace view user_advisor_log as 
  select a.id as task_id,
         a.name as task_name,
         a.exec_start as execution_start,
         a.exec_end as execution_end,
         decode(a.status, 1, 'INITIAL',
                          2, 'EXECUTING',
                          3, 'COMPLETED',
                          4, 'INTERRUPTED',
                          5, 'CANCELLED',
                          6, 'FATAL ERROR') as status,
          dbms_advisor.format_message_group(a.status_msg_id) as status_message,
          a.pct_completion_time as pct_completion_time,
          a.progress_metric as progress_metric,
          a.metric_units as metric_units,
          a.activity_counter as activity_counter,
          a.rec_count as recommendation_count,
          dbms_advisor.format_message_group(a.error_msg#) as error_message
  from wri$_adv_tasks a
  where bitand(a.property,6) = 4 and 
        a.owner# = userenv('SCHEMAID');

create or replace public synonym user_advisor_log
   for user_advisor_log;
grant select on user_advisor_log to public;

create or replace view dba_advisor_def_parameters
   as select b.name as advisor_name,
             a.name as parameter_name,
             a.value as parameter_value,
             decode(a.datatype, 1, 'NUMBER',
                                2, 'STRING',
                                3, 'STRINGLIST',
                                4, 'TABLE',
                                5, 'TABLELIST',
                                'UNKNOWN')
                 as parameter_type,
             decode(bitand(a.flags,2), 0, 'Y', 'N') as is_default,
             decode(bitand(a.flags,4), 0, 'N', 'Y') as is_output,
             decode(bitand(a.flags,8), 0, 'N', 'Y') as is_modifiable_anytime,
             dbms_advisor.format_message(a.description) as description
      from wri$_adv_def_parameters a, wri$_adv_definitions b
      where a.advisor_id = b.id
        and bitand(a.flags,1) = 0;

create or replace public synonym dba_advisor_def_parameters
   for dba_advisor_def_parameters;
grant select on dba_advisor_def_parameters to select_catalog_role;

create or replace view dba_advisor_parameters
   as select b.owner_name as owner,
             a.task_id as task_id,
             b.name as task_name,
             a.name as parameter_name,
             a.value as parameter_value,
             decode(a.datatype, 1, 'NUMBER',
                                2, 'STRING',
                                3, 'STRINGLIST',
                                4, 'TABLE',
                                5, 'TABLELIST',
                                'UNKNOWN')
                 as parameter_type,
             decode(bitand(a.flags,2), 0, 'Y', 'N') as is_default,
             decode(bitand(a.flags,4), 0, 'N', 'Y') as is_output,
             decode(bitand(a.flags,8), 0, 'N', 'Y') as is_modifiable_anytime,
             dbms_advisor.format_message(a.description) as description
      from wri$_adv_parameters a, wri$_adv_tasks b
      where a.task_id = b.id
        and bitand(b.property,4) = 4
        and bitand(a.flags,1) = 0;

create or replace public synonym dba_advisor_parameters
   for dba_advisor_parameters;
grant select on dba_advisor_parameters to select_catalog_role;

create or replace view user_advisor_parameters
   as select a.task_id as task_id,
             b.name as task_name,
             a.name as parameter_name,
             a.value as parameter_value,
             decode(a.datatype, 1, 'NUMBER',
                                2, 'STRING',
                                3, 'STRINGLIST',
                                4, 'TABLE',
                                5, 'TABLELIST',
                                'UNKNOWN')
                 as parameter_type,
             decode(bitand(a.flags,2), 0, 'Y', 'N') as is_default,
             decode(bitand(a.flags,4), 0, 'N', 'Y') as is_output,
             decode(bitand(a.flags,8), 0, 'N', 'Y') as is_modifiable_anytime,
             dbms_advisor.format_message(a.description) as description
      from wri$_adv_parameters a, wri$_adv_tasks b
      where a.task_id = b.id
        and b.owner# = userenv('SCHEMAID')
        and bitand(b.property,4) = 4
        and bitand(a.flags,1) = 0;

create or replace public synonym user_advisor_parameters
   for user_advisor_parameters;
grant select on user_advisor_parameters to public;

create or replace view dba_advisor_parameters_proj
   as select a.task_id as task_id,
             a.name as parameter_name,
             a.value as parameter_value,
             decode(a.datatype, 1, 'NUMBER',
                                2, 'STRING',
                                3, 'STRINGLIST',
                                4, 'TABLE',
                                5, 'TABLELIST',
                                'UNKNOWN')
                 as parameter_type,
             decode(bitand(a.flags,2), 0, 'Y', 'N') as is_default,
             decode(bitand(a.flags,4), 0, 'N', 'Y') as is_output,
             decode(bitand(a.flags,8), 0, 'N', 'Y') as is_modifiable_anytime,
             dbms_advisor.format_message(a.description) as description
      from wri$_adv_parameters a;

create or replace public synonym dba_advisor_parameters_proj
   for dba_advisor_parameters_proj;
grant select on dba_advisor_parameters_proj to select_catalog_role;

create or replace view dba_advisor_objects
  as select b.owner_name as owner,
            a.id as object_id,
            d.object_type as type,
            a.type as type_id,
            a.task_id as task_id,
            b.name as task_name,
            a.attr1 as attr1,
            a.attr2 as attr2,
            a.attr3 as attr3,
            a.attr4 as attr4,
            a.attr5 as attr5,
            a.other as other
      from wri$_adv_objects a, wri$_adv_tasks b,x$keaobjt d
      where a.task_id = b.id
        and d.indx = a.type;

create or replace public synonym dba_advisor_objects
  for dba_advisor_objects;
grant select on dba_advisor_objects to select_catalog_role;
 
create or replace view user_advisor_objects
  as select a.id as object_id,
            c.object_type as type,
            a.type as type_id,
            a.task_id as task_id,
            b.name as task_name,
            a.attr1 as attr1,
            a.attr2 as attr2,
            a.attr3 as attr3,
            a.attr4 as attr4,
            a.attr5 as attr5
      from wri$_adv_objects a, wri$_adv_tasks b, x$keaobjt c
      where a.task_id = b.id
        and b.owner# = userenv('SCHEMAID')
        and c.indx = a.type;

create or replace public synonym user_advisor_objects
  for user_advisor_objects;
grant select on user_advisor_objects to public;


create or replace view dba_advisor_findings
  as select b.owner_name as owner,
            a.task_id as task_id,    
            b.name as task_name,
            a.id as finding_id,
            decode (a.type, 1, 'PROBLEM', 
                            2, 'SYMPTOM', 
                            3, 'ERROR',
                            4, 'INFORMATION',
                            5, 'WARNING')  as type,
            a.parent as parent,
            a.obj_id as object_id,
            dbms_advisor.format_message_group(a.impact_msg_id) as impact_type,
            a.impact_val as impact,
            dbms_advisor.format_message_group(a.msg_id) as message,
            dbms_advisor.format_message_group(a.more_info_id) as more_info
    from wri$_adv_findings a, wri$_adv_tasks b
    where a.task_id = b.id
        and bitand(b.property,6) = 4;

create or replace public synonym dba_advisor_findings
  for dba_advisor_findings;
grant select on dba_advisor_findings to select_catalog_role;
 
create or replace view user_advisor_findings
  as select a.task_id as task_id,
            b.name as task_name,
            a.id as finding_id,
            decode (a.type,
                    1, 'PROBLEM',
                    2, 'SYMPTOM',
                    3, 'ERROR',
                    4, 'INFORMATION',
                    5, 'WARNING')  as type,
            a.parent as parent,    
            a.obj_id as object_id,
            dbms_advisor.format_message_group(a.impact_msg_id) as impact_type,
            a.impact_val as impact,
            dbms_advisor.format_message_group(a.msg_id) as message,
            dbms_advisor.format_message_group(a.more_info_id) as more_info
    from wri$_adv_findings a, wri$_adv_tasks b
    where a.task_id = b.id
      and b.owner# = userenv('SCHEMAID')
        and bitand(b.property,6) = 4;

create or replace public synonym user_advisor_findings
  for user_advisor_findings;
grant select on user_advisor_findings to public;


create or replace view dba_advisor_recommendations
  as select b.owner_name as owner,
            a.id as rec_id,
            a.task_id as task_id,
            b.name as task_name,
            a.finding_id as finding_id,
            a.type,
            a.rank as rank,
            a.parent_recs as parent_rec_ids,
            dbms_advisor.format_message_group(a.benefit_msg_id) as benefit_type,
            a.benefit_val as benefit,
            decode(annotation, 1, 'ACCEPT',
                               2, 'REJECT',
                               3, 'IGNORE',
                               4, 'IMPLEMENTED') as annotation_status,
            a.flags as flags
     from wri$_adv_recommendations a, wri$_adv_tasks b
     where a.task_id = b.id and 
          bitand(b.property,6) = 4;

create or replace public synonym dba_advisor_recommendations
   for dba_advisor_recommendations;
grant select on dba_advisor_recommendations to select_catalog_role;
             
create or replace view user_advisor_recommendations
  as select a.id as rec_id,
            a.task_id as task_id,
            b.name as task_name,
            a.finding_id as finding_id,
            a.type,
            a.rank as rank,
            a.parent_recs as parent_rec_ids,
            dbms_advisor.format_message_group(a.benefit_msg_id) as benefit_type,
            a.benefit_val as benefit,
            decode(annotation, 1, 'ACCEPT',
                               2, 'REJECT',
                               3, 'IGNORE',
                               4, 'IMPLEMENTED') as annotation_status,
            a.flags as flags
     from wri$_adv_recommendations a, wri$_adv_tasks b
     where a.task_id = b.id and 
           b.owner# = userenv('SCHEMAID') and 
           bitand(b.property,6) = 4;

create or replace public synonym user_advisor_recommendations
   for user_advisor_recommendations;
grant select on user_advisor_recommendations to public;

create or replace view dba_advisor_actions
   as select b.owner_name as owner,
             a.task_id as task_id,
             b.name as task_name,
             d.rec_id as rec_id,
             a.id as action_id,
             a.obj_id as object_id,
             c.command_name as command,
             a.command as command_id,
             a.flags as flags,
             a.attr1 as attr1,
             a.attr2 as attr2,
             a.attr3 as attr3,
             a.attr4 as attr4,
             a.attr5 as attr5,
             a.attr6 as attr6,
             a.num_attr1 as num_attr1,
             a.num_attr2 as num_attr2,
             a.num_attr3 as num_attr3,
             a.num_attr4 as num_attr4,
             a.num_attr5 as num_attr5,
             dbms_advisor.format_message_group(a.msg_id) as message
      from wri$_adv_actions a, wri$_adv_tasks b, x$keacmdn c,
           wri$_adv_rec_actions d
      where a.task_id = b.id
        and a.command = c.indx
        and d.task_id = a.task_id 
        and d.act_id = a.id
        and bitand(b.property,6) = 4
        and ((b.advisor_id = 2 and bitand(a.flags,2048) = 0) or
             (b.advisor_id <> 2));

create or replace public synonym dba_advisor_actions
   for dba_advisor_actions;
grant select on dba_advisor_actions to select_catalog_role;

create or replace view user_advisor_actions
   as select a.task_id as task_id,
             b.name as task_name,
             d.rec_id as rec_id,
             a.id as action_id,
             a.obj_id as object_id,
             c.command_name as command,
             a.command as command_id,
             a.flags as flags,
             a.attr1 as attr1,
             a.attr2 as attr2,
             a.attr3 as attr3,
             a.attr4 as attr4,
             a.attr5 as attr5,
             a.attr6 as attr6,
             a.num_attr1 as num_attr1,
             a.num_attr2 as num_attr2,
             a.num_attr3 as num_attr3,
             a.num_attr4 as num_attr4,
             a.num_attr5 as num_attr5,
             dbms_advisor.format_message_group(a.msg_id) as message
      from wri$_adv_actions a, wri$_adv_tasks b, x$keacmdn c,
           wri$_adv_rec_actions d
      where a.task_id = b.id
        and a.command = c.indx
        and d.task_id = a.task_id 
        and d.act_id = a.id
        and b.owner# = userenv('SCHEMAID')
        and bitand(b.property,6) = 4
        and ((b.advisor_id = 2 and bitand(a.flags,2048) = 0) or
             (b.advisor_id <> 2));

create or replace public synonym user_advisor_actions
   for user_advisor_actions;
grant select on user_advisor_actions to public;

create or replace view dba_advisor_rationale
   as select b.owner_name as owner,
             a.task_id as task_id,
             b.name as task_name,
             a.rec_id as rec_id,
             a.id as rationale_id,
             dbms_advisor.format_message_group(a.impact_msg_id) as impact_type,
             a.impact_val as impact,
             dbms_advisor.format_message_group(a.msg_id) as message,
             a.obj_id as object_id,
             a.type,        
             a.attr1 as attr1,
             a.attr2 as attr2,
             a.attr3 as attr3,
             a.attr4 as attr4,
             a.attr5 as attr5
      from wri$_adv_rationale a, wri$_adv_tasks b
      where a.task_id = b.id
        and bitand(b.property,6) = 4;

create or replace public synonym dba_advisor_rationale
   for dba_advisor_rationale;
grant select on dba_advisor_rationale to select_catalog_role;
             
create or replace view user_advisor_rationale
   as select a.task_id as task_id,
             b.name as task_name,
             a.rec_id as rec_id,
             a.id as rationale_id,
             dbms_advisor.format_message_group(a.impact_msg_id) as impact_type,
             a.impact_val as impact,
             dbms_advisor.format_message_group(a.msg_id) as message,
             a.obj_id as object_id,
             a.type,             
             a.attr1 as attr1,
             a.attr2 as attr2,
             a.attr3 as attr3,
             a.attr4 as attr4,
             a.attr5 as attr5
      from wri$_adv_rationale a, wri$_adv_tasks b
      where a.task_id = b.id
        and b.owner# = userenv('SCHEMAID')
        and bitand(b.property,6) = 4;

create or replace public synonym user_advisor_rationale
   for user_advisor_rationale;
grant select on user_advisor_rationale to public;

create or replace view dba_advisor_directives
   as select b.owner_name as owner,
             a.task_id as task_id,
             b.name as task_name,
             a.src_task_id as source_task_id,
             a.id as directive_id,
             a.obj_owner as rec_obj_owner,
             a.obj_name as rec_obj_name,
             a.rec_id as rec_id,
             a.rec_action_id as rec_action_id,
             c.command_name as command,
             a.attr1 as attr1,
             a.attr2 as attr2,
             a.attr3 as attr3,
             a.attr4 as attr4,
             a.attr5 as attr5
      from wri$_adv_directives a, wri$_adv_tasks b, x$keacmdn c
      where a.task_id = b.id
        and a.command = c.indx
        and bitand(b.property,6) = 4;

create or replace public synonym dba_advisor_directives
   for dba_advisor_directives;
grant select on dba_advisor_directives to select_catalog_role;

create or replace view user_advisor_directives
   as select a.task_id as task_id,
             b.name as task_name,
             a.src_task_id as source_task_id,
             a.id as directive_id,
             a.obj_owner as rec_obj_owner,
             a.obj_name as rec_obj_name,
             a.rec_id as rec_id,
             a.rec_action_id as rec_action_id,
             c.command_name as command,
             a.attr1 as attr1,
             a.attr2 as attr2,
             a.attr3 as attr3,
             a.attr4 as attr4,
             a.attr5 as attr5
      from wri$_adv_directives a, wri$_adv_tasks b, 
           x$keacmdn c
      where a.task_id = b.id
        and a.command = c.indx
        and b.owner# = userenv('SCHEMAID')
        and bitand(b.property,6) = 4;

create or replace public synonym user_advisor_directives
   for user_advisor_directives;
grant select on user_advisor_directives to public;


create or replace view dba_advisor_journal
   as select b.owner_name as owner,
             a.task_id as task_id,
             b.name as task_name,
             a.seq_id as journal_entry_seq,
             decode(a.type, 1, 'FATAL', 
                            2, 'ERROR',
                            3, 'WARNING',
                            4, 'INFORMATION',
                            5, 'INFORMATION2',
                            6, 'INFORMATION3',
                            7, 'INFORMATION4',
                            8, 'INFORMATION5',
                            9, 'INFORMATION6') as journal_entry_type,
             dbms_advisor.format_message_group(a.msg_id) as journal_entry
      from wri$_adv_journal a, wri$_adv_tasks b
      where a.task_id = b.id
        and bitand(b.property,4) = 4;

create or replace public synonym dba_advisor_journal
   for dba_advisor_journal;
grant select on dba_advisor_journal to select_catalog_role;
 
create or replace view user_advisor_journal
   as select a.task_id as task_id,
             b.name as task_name,
             a.seq_id as journal_entry_seq,
             decode(a.type, 1, 'FATAL', 
                            2, 'ERROR',
                            3, 'WARNING',
                            4, 'INFORMATION',
                            5, 'INFORMATION2',
                            6, 'INFORMATION3',
                            7, 'INFORMATION4',
                            8, 'INFORMATION5',
                            9, 'INFORMATION6') as journal_entry_type,
             dbms_advisor.format_message_group(a.msg_id) as journal_entry
      from wri$_adv_journal a, wri$_adv_tasks b
      where a.task_id = b.id
        and bitand(b.property,4) = 4
        and b.owner# = userenv('SCHEMAID');

create or replace public synonym user_advisor_journal
   for user_advisor_journal;
grant select on user_advisor_journal to public;


