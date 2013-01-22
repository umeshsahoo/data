Rem
Rem $Header: catrm.sql 24-aug-2004.01:04:28 avaliani Exp $
Rem
Rem catrm.sql
Rem
Rem Copyright (c) 1998, 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catrm.sql - Catalog script for dbms Resource Manager package
Rem
Rem    DESCRIPTION
Rem      Installs packages for the DBMS Resource Manager.
Rem
Rem    NOTES
Rem      
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    avaliani    08/24/04 - bug 3688272: change ACTIVE to NULL
Rem    sridsubr    07/08/04 - Fix Status in DBA_RSRC_PLANS -- Bug 3688272 
Rem    rburns      05/01/03 - recompile synonym
Rem    asundqui    10/09/02 - new parameters
Rem    asundqui    05/07/02 - consumer group mapping interface
Rem    rherwadk    11/09/01 - #1817695: unlimit default resmgr parameter values
Rem    ykunitom    08/28/01 - Bug 1928353: change switch_estimate
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    rherwadk    06/19/00 - change switch_group parameters
Rem    rmurthy     06/20/00 - change objauth.option column to hold flag bits
Rem    wixu        03/16/00 - wixu_resman_chg
Rem    wixu        01/20/00 - change_for_RES_MANGR_extensions
Rem    akalra      06/24/99 - rename some files
Rem    akalra      11/20/98 - grant sys. privilege to export and import roles
Rem                         - set up more built-ins and their privileges
Rem    klcheung    11/17/98 - move rmexptab$ creation
Rem    akalra      08/17/98 - support for import export
Rem    akalra      06/17/98 - Allow object grant
Rem    akalra      06/12/98 - inicongroup -> defschclass
Rem    akalra      06/10/98 - Change -1 to UWORDMAXVAL
Rem    akalra      06/09/98 - Change file names
Rem    akalra      06/03/98 - Change views                                     
Rem    akalra      05/26/98 - Change and add views                             
Rem    akalra      05/22/98 - Use new interface                                
Rem    akalra      01/19/98 - Created
Rem

-- Create the library where 3GL callouts will reside
CREATE OR REPLACE LIBRARY dbms_rmgr_lib TRUSTED as STATIC
/

-- Load DBMS RESOURCE MANAGER interface packages
@@dbmsrmin.plb
@@prvtrmin.plb
@@dbmsrmad.sql
@@prvtrmad.plb
@@dbmsrmpr.sql
@@prvtrmpr.plb
@@prvtrmie.plb
@@dbmsrmpe.plb
@@prvtrmpe.plb
@@dbmsrmge.plb
@@prvtrmge.plb
ALTER PUBLIC SYNONYM DBMS_RMGR_PLAN_EXPORT COMPILE; 
@@dbmsrmpa.plb
@@prvtrmpa.plb

-- install mandatory and system managed (but non-mandatory) objects.
execute dbms_rmin.install;

-- set initial consumer group for SYS and SYSTEM to be SYS_GROUP
execute dbms_resource_manager.create_pending_area;
execute dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'SYSTEM', 'SYS_GROUP');
execute dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, 'SYS', 'SYS_GROUP');
execute dbms_resource_manager.submit_pending_area;

-- grant system privilege to IMP_FULL_DATABASE and EXP_FULL_DATABASE
execute dbms_resource_manager_privs.grant_system_privilege('IMP_FULL_DATABASE', 'ADMINISTER_RESOURCE_MANAGER', FALSE);
execute dbms_resource_manager_privs.grant_system_privilege('EXP_FULL_DATABASE', 'ADMINISTER_RESOURCE_MANAGER', FALSE);

-- Set up export actions.  Delete existing export data
DELETE FROM exppkgobj$ where package like 'DBMS_RMGR_%'
/
DELETE FROM exppkgact$ where package like 'DBMS_RMGR_%'
/

-- package to export resource plans
INSERT INTO exppkgobj$ (package,schema,class,type#,prepost,level#)
values('DBMS_RMGR_PLAN_EXPORT', 'SYS', 1, 47, 1, 1000)
/

-- package to export consumer groups
INSERT INTO exppkgobj$ (package,schema,class,type#,prepost,level#)
values('DBMS_RMGR_GROUP_EXPORT', 'SYS', 1, 48, 1, 1000)
/

-- package to export plan directives.  This also does the procedural actions
-- work.
INSERT INTO exppkgact$ (package,schema,class,level#)
values('DBMS_RMGR_PACT_EXPORT', 'SYS', 1, 1000)
/

---------------------------------------------------------------------------------
--                              VIEWS                                          --
---------------------------------------------------------------------------------

--
-- Create the view DBA_RSRC_PLANS
--
create or replace view DBA_RSRC_PLANS
   (PLAN,NUM_PLAN_DIRECTIVES,CPU_METHOD,ACTIVE_SESS_POOL_MTH,
    PARALLEL_DEGREE_LIMIT_MTH,QUEUEING_MTH,COMMENTS,STATUS,MANDATORY)
as
select name,num_plan_directives,cpu_method,mast_method,pdl_method,que_method,
       description,decode(status,'PENDING',status, NULL),
       decode(mandatory,1,'YES','NO')
from resource_plan$
order by status
/
comment on table DBA_RSRC_PLANS is
'All the resource plans'
/
comment on column DBA_RSRC_PLANS.PLAN is
'Plan name'
/
comment on column DBA_RSRC_PLANS.NUM_PLAN_DIRECTIVES is
'Number of plan directives for the plan'
/
comment on column DBA_RSRC_PLANS.CPU_METHOD is
'CPU resource allocation method for the plan'
/
comment on column DBA_RSRC_PLANS.ACTIVE_SESS_POOL_MTH is
'maximum active sessions target resource allocation method for the plan'
/
comment on column DBA_RSRC_PLANS.PARALLEL_DEGREE_LIMIT_MTH is
'parallel degree limit resource allocation method for the plan'
/
comment on column DBA_RSRC_PLANS.QUEUEING_MTH is
'queueing method for groups'
/
comment on column DBA_RSRC_PLANS.COMMENTS is
'Text comment on the plan'
/
comment on column DBA_RSRC_PLANS.STATUS is
'PENDING if it is part of the pending area, NULL otherwise'
/
comment on column DBA_RSRC_PLANS.MANDATORY is
'Whether the plan is mandatory'
/
create or replace public synonym DBA_RSRC_PLANS for DBA_RSRC_PLANS
/
grant select on DBA_RSRC_PLANS to SELECT_CATALOG_ROLE
/

--
-- Create the view DBA_RSRC_CONSUMER_GROUPS
--
create or replace view DBA_RSRC_CONSUMER_GROUPS
   (CONSUMER_GROUP,CPU_METHOD,COMMENTS,STATUS,MANDATORY)
as
select name,cpu_method,description,decode(status,'PENDING',status, NULL),
       decode(mandatory,1,'YES','NO')
from resource_consumer_group$
/
comment on table DBA_RSRC_CONSUMER_GROUPS is
'all the resource consumer groups'
/
comment on column DBA_RSRC_CONSUMER_GROUPS.CONSUMER_GROUP is
'consumer group name'
/
comment on column DBA_RSRC_CONSUMER_GROUPS.CPU_METHOD is
'CPU resource allocation method for the consumer group'
/
comment on column DBA_RSRC_CONSUMER_GROUPS.COMMENTS is
'Text comment on the consumer group'
/
comment on column DBA_RSRC_CONSUMER_GROUPS.STATUS is
'PENDING if it is part of the pending area, NULL otherwise'
/
comment on column DBA_RSRC_CONSUMER_GROUPS.MANDATORY is
'Whether the consumer group is mandatory'
/
create or replace public synonym DBA_RSRC_CONSUMER_GROUPS
   for DBA_RSRC_CONSUMER_GROUPS
/
grant select on DBA_RSRC_CONSUMER_GROUPS to SELECT_CATALOG_ROLE
/

--
-- create the view DBA_RSRC_PLAN_DIRECTIVES
--
create or replace view DBA_RSRC_PLAN_DIRECTIVES
   (PLAN, GROUP_OR_SUBPLAN, TYPE, CPU_P1, CPU_P2, CPU_P3, CPU_P4, CPU_P5,
    CPU_P6, CPU_P7, CPU_P8, ACTIVE_SESS_POOL_P1, 
    QUEUEING_P1, PARALLEL_DEGREE_LIMIT_P1,
    SWITCH_GROUP, SWITCH_TIME, SWITCH_ESTIMATE, MAX_EST_EXEC_TIME, UNDO_POOL,
    MAX_IDLE_TIME, MAX_IDLE_BLOCKER_TIME, SWITCH_TIME_IN_CALL,
    COMMENTS, STATUS, MANDATORY)
as
select plan, group_or_subplan, decode(is_subplan, 1, 'PLAN', 'CONSUMER_GROUP'),
decode(cpu_p1, 4294967295, 0, cpu_p1),
decode(cpu_p2, 4294967295, 0, cpu_p2), 
decode(cpu_p3, 4294967295, 0, cpu_p3),
decode(cpu_p4, 4294967295, 0, cpu_p4),
decode(cpu_p5, 4294967295, 0, cpu_p5),
decode(cpu_p6, 4294967295, 0, cpu_p6),
decode(cpu_p7, 4294967295, 0, cpu_p7),
decode(cpu_p8, 4294967295, 0, cpu_p8),
decode(active_sess_pool_p1, 4294967295, to_number(null), active_sess_pool_p1),
decode(queueing_p1, 4294967295, to_number(null), queueing_p1),
decode(parallel_degree_limit_p1,
       4294967295, to_number(null),
       parallel_degree_limit_p1), 
switch_group,
case when (switch_time = 4294967295) then to_number(null)
     when (switch_back <> 0) then to_number(null)
     else switch_time end,
decode(switch_estimate, 4294967295, 'FALSE', 0, 'FALSE', 1, 'TRUE'),
decode(max_est_exec_time, 4294967295, to_number(null), max_est_exec_time),
decode(undo_pool, 4294967295, to_number(null), undo_pool),
decode(max_idle_time, 4294967295, to_number(null), max_idle_time),
decode(max_idle_blocker_time, 4294967295, to_number(null), 
       max_idle_blocker_time),
case when (switch_time = 4294967295) then to_number(null)
     when (switch_back = 0) then to_number(null)
     else switch_time end,
description, decode(status,'PENDING',status, NULL), 
decode(mandatory, 1, 'YES', 'NO')
from resource_plan_directive$
/
comment on table DBA_RSRC_PLAN_DIRECTIVES is
'all the resource plan directives'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.PLAN is
'Name of the plan to which this directive belongs'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.GROUP_OR_SUBPLAN is
'Name of the consumer group/sub-plan referred to'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.TYPE is
'Whether GROUP_OR_SUBPLAN refers to a consumer group or a plan'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.CPU_P1 is
'first parameter for the CPU resource allocation method'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.CPU_P2 is
'second parameter for the CPU resource allocation method'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.CPU_P3 is
'third parameter for the CPU resource allocation method'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.CPU_P4 is
'fourth parameter for the CPU resource allocation method'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.CPU_P5 is
'fifth parameter for the CPU resource allocation method'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.CPU_P6 is
'sixth parameter for the CPU resource allocation method'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.CPU_P7 is
'seventh parameter for the CPU resource allocation method'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.CPU_P8 is
'eight parameter for the CPU resource allocation method'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.active_sess_pool_p1 is
'first parameter for the maximum active sessions target resource allocation 
method'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.queueing_p1 is
'first parameter for the queueing method'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.parallel_degree_limit_p1 is
'first parameter for the parallel degree limit resource allocation method'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.switch_group is
'group to switch to once switch time is reached'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.switch_time is
'switch time limit for execution within a group'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.switch_estimate is
'use execution estimate to determine group?'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.max_est_exec_time is
'use of max. estimated execution time'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.undo_pool is
'max. undo allocation for consumer groups'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.max_idle_time is
'max. idle time'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.max_idle_blocker_time is
'max. idle time when blocking other sessions'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.switch_time_in_call is
'call switch time limit for execution in a group'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.COMMENTS is
'Text comment on the plan directive'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.STATUS is
'PENDING if it is part of the pending area, NULL otherwise'
/
comment on column DBA_RSRC_PLAN_DIRECTIVES.MANDATORY is
'Whether the plan directive is mandatory'
/
create or replace public synonym DBA_RSRC_PLAN_DIRECTIVES
   for DBA_RSRC_PLAN_DIRECTIVES
/
grant select on DBA_RSRC_PLAN_DIRECTIVES to SELECT_CATALOG_ROLE
/

--
-- create view DBA_RSRC_CONSUMER_GROUP_PRIVS
--
create or replace view DBA_RSRC_CONSUMER_GROUP_PRIVS
   (GRANTEE,GRANTED_GROUP,GRANT_OPTION,INITIAL_GROUP)
as
select ue.name, g.name, 
       decode(min(mod(o.option$,2)), 1, 'YES', 'NO'),
       decode(nvl(cgm.consumer_group, 'DEFAULT_CONSUMER_GROUP'),
              g.name, 'YES', 'NO')
from sys.user$ ue left outer join sys.resource_group_mapping$ cgm on
     (cgm.attribute = 'ORACLE_USER' and cgm.status = 'ACTIVE' and
      cgm.value = ue.name),
     sys.resource_consumer_group$ g, sys.objauth$ o
where o.obj# = g.obj# and o.grantee# = ue.user#
group by ue.name, g.name, 
      decode(nvl(cgm.consumer_group, 'DEFAULT_CONSUMER_GROUP'),
             g.name, 'YES', 'NO')
/
comment on table DBA_RSRC_CONSUMER_GROUP_PRIVS is
'Switch privileges for consumer groups'
/
comment on column DBA_RSRC_CONSUMER_GROUP_PRIVS.GRANTEE is
'Grantee name'
/
comment on column DBA_RSRC_CONSUMER_GROUP_PRIVS.GRANTED_GROUP is
'consumer group granted to the grantee'
/
comment on column DBA_RSRC_CONSUMER_GROUP_PRIVS.GRANT_OPTION is
'whether the grantee can grant the privilege to others' 
/
create or replace public synonym DBA_RSRC_CONSUMER_GROUP_PRIVS
   for DBA_RSRC_CONSUMER_GROUP_PRIVS
/
grant select on DBA_RSRC_CONSUMER_GROUP_PRIVS to SELECT_CATALOG_ROLE
/

--
-- create view USER_RSRC_CONSUMER_GROUP_PRIVS
--
create or replace view USER_RSRC_CONSUMER_GROUP_PRIVS
   (GRANTED_GROUP,GRANT_OPTION,INITIAL_GROUP)
as
select g.name, decode(mod(o.option$,2),1,'YES','NO'),
       decode(nvl(cgm.consumer_group, 'DEFAULT_CONSUMER_GROUP'),
              g.name, 'YES', 'NO')
from sys.user$ u left outer join sys.resource_group_mapping$ cgm on
     (cgm.attribute = 'ORACLE_USER' and cgm.status = 'ACTIVE' and
      cgm.value = u.name), sys.resource_consumer_group$ g, sys.objauth$ o
where o.obj# = g.obj# and o.grantee# = u.user#
and o.grantee# = userenv('SCHEMAID')
/
comment on table USER_RSRC_CONSUMER_GROUP_PRIVS is
'Switch privileges for consumer groups for the user'
/
comment on column USER_RSRC_CONSUMER_GROUP_PRIVS.GRANTED_GROUP is
'consumer groups to which the user can switch'
/
comment on column USER_RSRC_CONSUMER_GROUP_PRIVS.GRANT_OPTION is
'whether the user can grant the privilege to others'
/
create or replace public synonym USER_RSRC_CONSUMER_GROUP_PRIVS
   for USER_RSRC_CONSUMER_GROUP_PRIVS
/
grant select on USER_RSRC_CONSUMER_GROUP_PRIVS to PUBLIC with grant option
/

--
-- create view DBA_RSRC_MANAGER_SYSTEM_PRIVS
--
create or replace view DBA_RSRC_MANAGER_SYSTEM_PRIVS
   (GRANTEE,PRIVILEGE,ADMIN_OPTION)
as
select u.name,spm.name,decode(min(sa.option$),1,'YES','NO')
from sys.user$ u, system_privilege_map spm, sys.sysauth$ sa
where sa.grantee# = u.user# and sa.privilege# = spm.privilege
and sa.privilege# = -227 group by u.name, spm.name
/
comment on table DBA_RSRC_MANAGER_SYSTEM_PRIVS is
'system privileges for the resource manager'
/
comment on column DBA_RSRC_MANAGER_SYSTEM_PRIVS.GRANTEE is
'Grantee name'
/
comment on column DBA_RSRC_MANAGER_SYSTEM_PRIVS.PRIVILEGE is
'name of the system privilege'
/
comment on column DBA_RSRC_MANAGER_SYSTEM_PRIVS.ADMIN_OPTION is
'whether the grantee can grant the privilege to others'
/
create or replace public synonym DBA_RSRC_MANAGER_SYSTEM_PRIVS
   for DBA_RSRC_MANAGER_SYSTEM_PRIVS
/
grant select on DBA_RSRC_MANAGER_SYSTEM_PRIVS to SELECT_CATALOG_ROLE
/

--
-- create view USER_RSRC_MANAGER_SYSTEM_PRIVS
--
create or replace view USER_RSRC_MANAGER_SYSTEM_PRIVS
   (PRIVILEGE,ADMIN_OPTION)
as
select spm.name,decode(min(sa.option$),1,'YES','NO')
from sys.user$ u, system_privilege_map spm, sys.sysauth$ sa
where sa.grantee# = u.user# and sa.privilege# = spm.privilege
and sa.privilege# = -227 and sa.grantee# = userenv('SCHEMAID')
group by spm.name
/
comment on table USER_RSRC_MANAGER_SYSTEM_PRIVS is
'system privileges for the resource manager for the user'
/
comment on column USER_RSRC_MANAGER_SYSTEM_PRIVS.PRIVILEGE is
'name of the system privilege'
/
comment on column USER_RSRC_MANAGER_SYSTEM_PRIVS.ADMIN_OPTION is
'whether the user can grant the privilege to others'
/
create or replace public synonym USER_RSRC_MANAGER_SYSTEM_PRIVS
   for USER_RSRC_MANAGER_SYSTEM_PRIVS
/
grant select on USER_RSRC_MANAGER_SYSTEM_PRIVS to PUBLIC with grant option
/

--
-- create the view DBA_RSRC_GROUP_MAPPINGS
--
create or replace view DBA_RSRC_GROUP_MAPPINGS
   (ATTRIBUTE, VALUE, CONSUMER_GROUP, STATUS)
as
select m.attribute, m.value, m.consumer_group, 
       decode(m.status,'PENDING',m.status, NULL)
from sys.resource_group_mapping$ m
order by m.status,
         (select p.priority from sys.resource_mapping_priority$ p
          where m.status = p.status and m.attribute = p.attribute),
         m.consumer_group, m.value
/
comment on table DBA_RSRC_GROUP_MAPPINGS is
'all the consumer group mappings'
/
comment on column DBA_RSRC_GROUP_MAPPINGS.ATTRIBUTE is
'which session attribute to match'
/
comment on column DBA_RSRC_GROUP_MAPPINGS.VALUE is
'attribute value'
/
comment on column DBA_RSRC_GROUP_MAPPINGS.CONSUMER_GROUP is
'target consumer group name'
/
comment on column DBA_RSRC_GROUP_MAPPINGS.STATUS is
'PENDING if it is part of the pending area, NULL otherwise'
/
create or replace public synonym DBA_RSRC_GROUP_MAPPINGS
   for DBA_RSRC_GROUP_MAPPINGS
/
grant select on DBA_RSRC_GROUP_MAPPINGS to SELECT_CATALOG_ROLE
/

--
-- create the view DBA_RSRC_MAPPING_PRIORITY
--
create or replace view DBA_RSRC_MAPPING_PRIORITY
   (ATTRIBUTE, PRIORITY, STATUS)
as
select attribute, priority, decode(status,'PENDING',status, NULL)
from sys.resource_mapping_priority$
where attribute <> 'CLIENT_ID'
order by status, priority
/
comment on table DBA_RSRC_MAPPING_PRIORITY is
'the consumer group mapping attribute priorities'
/
comment on column DBA_RSRC_MAPPING_PRIORITY.ATTRIBUTE is
'session attribute'
/
comment on column DBA_RSRC_MAPPING_PRIORITY.PRIORITY is
'priority (1 = highest)'
/
comment on column DBA_RSRC_MAPPING_PRIORITY.STATUS is
'PENDING if it is part of the pending area, NULL otherwise'
/
create or replace public synonym DBA_RSRC_MAPPING_PRIORITY
   for DBA_RSRC_MAPPING_PRIORITY
/
grant select on DBA_RSRC_MAPPING_PRIORITY to SELECT_CATALOG_ROLE
/
