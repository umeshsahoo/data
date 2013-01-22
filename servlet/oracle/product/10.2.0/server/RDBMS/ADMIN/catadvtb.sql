Rem
Rem $Header: catadvtb.sql 07-nov-2004.14:55:16 kyagoub Exp $
Rem
Rem catadvtb.sql
Rem
Rem Copyright (c) 2002, 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catadvtb.sql - Manageability Advisor tables and types
Rem
Rem    DESCRIPTION
Rem      Creates base tables and types for the Advisor framework and 
Rem      advisor components
Rem
Rem    NOTES
Rem      none
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    kyagoub     10/10/04 - add other column to objects table 
Rem    gssmith     04/20/04 - Bug 3501493 
Rem    pbelknap    01/15/04 - add call to drop task when user dies 
Rem    gssmith     02/05/04 - Change journal flags 
Rem    gssmith     01/29/04 - Adding flags to wri$_adv_recommendations 
Rem    gssmith     11/10/03 - 
Rem    gssmith     10/23/03 - Bug 3207351 
Rem    gssmith     08/26/03 - Extend AA workload column 
Rem    ushaft      07/09/03 - added sub_get_report to type wri$_adv_hdm_t
Rem    kyagoub     07/08/03 - implement sub_get_report for sqltune
Rem    smuthuli    07/15/03 - remove create table/index advisors
Rem    kdias       06/27/03 - clean up dependencies for upgrade/downgrade
Rem    slawande    03/27/03 - change default value of prm
Rem    slawande    03/13/03 - add prm for access advisor
Rem    wyang       05/04/03 - fix undo advisor default parameter
Rem    kyagoub     05/03/03 - remove message from recommendation and 
Rem                           add type to rationale
Rem    bdagevil    04/28/03 - merge new file
Rem    gssmith     05/01/03 - AA workload adjustments
Rem    gssmith     04/15/03 - Change MODE
Rem    gssmith     03/26/03 - Bug 2869857
Rem    sramakri    03/11/03 - CREATION_COST parameter
Rem    sramakri    01/28/03 - volatility weight factors
Rem    slawande    01/24/03 - Add more internal prms for acc advisor
Rem    kyagoub     03/27/03 - add news attributes to the rationale table and 
Rem                           object reference in finding table
Rem    kyagoub     03/17/03 - add type to recommendation table
Rem    kdias       03/12/03 - fix obj adv id
Rem    ushaft      03/07/03 - modifed comments about flags field for params
Rem    kdias       03/04/03 - replace time window w/ start/end time/snapshot
Rem    kyagoub     03/08/03 - add _INDEX_ANALYZE_CONTROL/_SQLTUNE_CONTROL/
Rem                           _PLAN_ANALYZE_CONTROL parameters for sqltune
Rem    kyagoub     02/19/03 - correct default parameter values for sqltune adv
Rem    gssmith     03/18/03 - Access Advisor column name changes
Rem    mxiao       12/23/02 - add attr6 to adv_actions
Rem    gssmith     01/09/03 - Bug 2657007
Rem    gssmith     01/06/03 - Add task parameter for Access Advisor
Rem    wyang       01/14/03 - Undo Advisor Parameters
Rem    nwhyte      12/03/02 - Add object space advisors
Rem    gssmith     12/11/02 - Adding version to task record
Rem    gssmith     11/27/02 - Access Advisor parameter change
Rem    gssmith     11/22/02 - Adjust Access Advisor task parameters
Rem    gssmith     11/19/02 - Bad bit settings
Rem    kdias       12/05/02 - add hdm parameters
Rem    wyang       11/21/02 - undo advisor
Rem    kdias       11/16/02 - add hdm type and data
Rem    kdias       10/31/02 - modify findings table
Rem    gssmith     10/30/02 - Bug 2647626
Rem    kdias       10/12/02 - add err# out param to sub_execute
Rem    kdias       10/08/02 - modify pk constraint for message_groups
Rem    gssmith     10/18/02 - Fix for bug 2632538
Rem    btao        10/21/02 - add parameter _BUCKET_QRYMAX
Rem    gssmith     10/10/02 - Fix Access Advisor parameter
Rem    kdias       10/08/02 - modify pk constraint for message_groups
Rem    btao        10/08/02 - add column flags to wri$_adv_actions
Rem    sramakri    09/30/02 - add commands 16 thru 21
Rem    kdias       09/26/02 - add constraint to the objects table
Rem    kdias       09/24/02 - remove type from advisor definition
Rem    gssmith     09/27/02 - wip
Rem    gssmith     09/26/02 - Add usage table entry
Rem    gssmith     09/25/02 - grabtrans 'gssmith_adv0920'
Rem    btao        09/24/02 - add additional parameters for idx and mv
Rem    gssmith     09/13/02 - Adding templates
Rem    gssmith     09/10/02 - wip
Rem    gssmith     09/04/02 - wip
Rem    gssmith     08/27/02 - Add tablespace clauses
Rem    gssmith     08/21/02 - Adding new sequence for sqlw
Rem    gssmith     08/21/02 - Created
Rem

Rem Manageability Advisor repository tables

Rem super type definition (abstract class) that defines the methods that 
Rem each advisor has to implement
Rem

CREATE OR REPLACE TYPE wri$_adv_abstract_t AS OBJECT 
(
  advisor_id      number,                        
  member procedure sub_create (task_id IN NUMBER,
                               from_task_id IN number),
  member procedure sub_execute (task_id IN NUMBER,
                                err_num OUT NUMBER),
  member procedure sub_reset (task_id IN NUMBER),
  member procedure sub_resume (task_id IN NUMBER),
  member procedure sub_delete (task_id IN NUMBER),
  member procedure sub_param_validate (task_id IN NUMBER,
                                       name IN VARCHAR2,
                                       value IN OUT VARCHAR2),
  member procedure sub_get_script (task_id IN NUMBER,
                                   type IN VARCHAR2,
                                   buffer IN OUT NOCOPY CLOB,
                                   rec_id IN NUMBER,
                                   act_id IN NUMBER),
  member procedure sub_get_report (task_id IN NUMBER,
                                   type IN VARCHAR2,
                                   level IN VARCHAR2,
                                   section IN VARCHAR2,
                                   buffer IN OUT NOCOPY CLOB),
  member procedure sub_validate_directive(task_id IN NUMBER,
                                          command_id IN NUMBER,
                                          attr1 IN OUT VARCHAR2,
                                          attr2 IN OUT VARCHAR2,
                                          attr3 IN OUT VARCHAR2,
                                          attr4 IN OUT VARCHAR2,
                                          attr5 IN OUT VARCHAR2),
  member procedure sub_update_rec_attr (task_id IN NUMBER,
                                        rec_id IN NUMBER,
                                        act_id IN NUMBER,
                                        name IN VARCHAR2,
                                        value IN VARCHAR2),
  member procedure sub_get_rec_attr (task_id IN NUMBER,
                                     rec_id IN NUMBER,
                                     act_id IN NUMBER,
                                     name IN VARCHAR2,
                                     value OUT VARCHAR2),
  member procedure sub_cleanup(task_id IN NUMBER),
  member procedure sub_implement(task_id IN NUMBER),
  member procedure sub_implement(task_id in number, 
                                 rec_id in number,
                                 exit_on_error in number),
  member procedure sub_user_setup(adv_id IN NUMBER),
  member procedure sub_import_directives (task_id in number,
                                          from_id in number,
                                          import_mode in varchar2,
                                          accepted out number,
                                          rejected out number),
  member procedure sub_quick_tune (task_name in varchar2,
                                   attr_clob in clob,
                                   attr_vc in varchar2,
                                   attr_num in number,
                                   template in varchar2,
                                   implement in boolean)
) not final;
/
 
Rem
Rem table containing the list of advisors in the system along with their
Rem method definitions (advisor specific type which is a sub-type of
Rem sys.wri$_adv_abstract_t
Rem
Rem       pk : id
Rem 

create table wri$_adv_definitions
(
 id              number         not null,                       /* unique id */
 name            varchar2(30)   not null,                            /* name */
 property        number         not null,            /* bitvec of properties */
                                       /* supports comprehensive mode = 0x01 */
                                             /* supports limited mode = 0x02 */
                                              /* advisor is resumable = 0x04 */
                                                 /* accepts directive = 0x08 */
                                          /* can generate undo script = 0x16 */
 type            wri$_adv_abstract_t not null,        /* adv specific object */
 constraint wri$_adv_definitions_pk primary key(id)
    using index tablespace SYSAUX
)
tablespace sysaux
/
 
Rem
Rem table storing metadata for tasks in the system
Rem
Rem       pk : id
Rem       fk : advisor_id -> wri$_adv_definitions.id
Rem
Rem Valid values for status column (keep in sync with kea.h)
Rem         1  - initial            
Rem         2  - executing          
Rem         3  - completed
Rem         4  - interrupted     
Rem         5  - cancelled
Rem         6  - fatal error

create table wri$_adv_tasks
( 
 id                   number          not null,    /* unique id for the task */
 owner#               number          not null,         /* owner user number */
 owner_name           varchar2(30),                            /* Owner name */
 name                 varchar2(30),                             /* task name */
 description          varchar2(256),                     /* task description */
 advisor_id           number          not null,        /* associated advisor */
 advisor_name         varchar2(30),                          /* Advisor name */
 ctime                date            not null,             /* creation time */
 mtime                date            not null,    /* last modification time */
 parent_id            number,          /* set if this task is created due to */
                                       /* the recommendation of another task */
 parent_rec_id        number,                  /* the recommendation id that */
                                                    /* recommended this task */
 property             number          not null,      /* bitvec of properties */
                                                        /* 0x01 -> Read only */
                                                        /* 0x02 ->  Template */
                                                             /* 0x04 -> Task */
                                                         /* 0x08 -> Workload */
 version              number,            /* Data version number for the task */
 exec_start           date,                          /* execution start time */
 exec_end             date,                            /* execution end time */
 status               number          not null,               /* task status */
 status_msg_id        number,           /* id of msg group in messages table */
 pct_completion_time  number,                   /* progress in terms of time */
 progress_metric      number,            /* advisor specific progress metric */
 metric_units         varchar2(64),                          /* metric units */
 activity_counter     number,                /* counter denoting active work */
                                                       /* is being performed */
 rec_count            number,                             /* Quality counter */
 error_msg#           number,                                 /* error msg # */
 cleanup              number,            /* boolean denoting if cleanup reqd */
 how_created          varchar2(30),   /* optional source used to create task */
 source               varchar2(30),            /* optional name of base task */
 constraint wri$_adv_tasks_pk primary key (id)
    using index tablespace SYSAUX
)
tablespace sysaux
/

create UNIQUE index wri$_adv_tasks_idx_01
  on wri$_adv_tasks (name, owner#)
  tablespace SYSAUX;

create UNIQUE index wri$_adv_tasks_idx_02
  on wri$_adv_tasks (owner#, id)
  tablespace SYSAUX;

create index wri$_adv_tasks_idx_03
  on wri$_adv_tasks (advisor_id, exec_start)
  tablespace SYSAUX;

create sequence wri$_adv_seq_task            /* Generates unique task number */
  increment by 1
  start with 1
  minvalue 1
  maxvalue 4294967295
  nocycle
  cache 10
/

Rem
Rem   Default parameter table
Rem
Rem      Valid values for the datatype column are:
Rem
Rem         1  - number
Rem         2  - string
Rem         3  - comma-separated list of strings
Rem         4  - table specification (schema.table)
Rem         5  - comma-separated list of table specifications
Rem  Values for flags:
Rem         Flags consists of three bits:
Rem           1 - Invisible. If bitand(flags,1)=1 then the views 
Rem               dba_advisor_parameters and user_advisor_parameters do not
Rem               return the row.
Rem           2 - Internal use only
Rem           4 - Output: If bitand(flags,4)=1 then the value was set during
Rem               task execution. We do not allow output values to be invisible
Rem           8 - Modifiable after execution

create table wri$_adv_def_parameters
   (
      advisor_id    number not null,                    /* Advisor id number */
      name          varchar2(30) not null,                 /* Parameter name */
      datatype      number not null,               /* Data type - see header */
      flags         number not null,            /* 0 = visible, 1 = internal */
      value         varchar2(4000) not null,              /* Parameter value */
      description   varchar2(9),                         /* Description code */
      constraint wri$_adv_def_parameters_pk primary key(advisor_id,name)
        using index tablespace SYSAUX
   )
tablespace sysaux
/

Rem
Rem table storing task parameters for all the tasks
Rem
Rem       pk : (task_id, name)
Rem       fk : task_id -> wri$_adv_tasks.id
Rem
Rem  Values for datatypes: see description above for wri$_adv_def_parameters
Rem
Rem  Values for flags:
Rem         Flags consists of four bits:
Rem           1 - Invisible. If bitand(flags,1)=1 then the views 
Rem               dba_advisor_parameters and user_advisor_parameters do not
Rem               return the row.
Rem           2 - Not-default. If bitand(flags,2)=0 then the value of the 
Rem               parameter was copied from wri$_adv_def_parameters when the
Rem               task was created and not modified since then.
Rem           4 - Output: If bitand(flags,4)=1 then the value was set during
Rem               task execution. We do not allow output values to be invisible
Rem           8 - Modifiable after execution
Rem         Valid values for flags:
Rem            0  - visible   / default value / not output
Rem            1  - invisible / default value / not output
Rem            2  - visible   / not default   / not output
Rem            3  - invisible / not default   / not output
Rem            6  - visible   / not default   / output value

create table wri$_adv_parameters
(
 task_id        number          not null,  
 name           varchar2(30)    not null,
 value          varchar2(4000)  not null,                 /* parameter value */
 datatype       number          not null,           /* datatype of parameter */
 flags          number          not null,       
 description    varchar2(9),                             /* Description code */
 constraint wri$_adv_parameters_pk primary key(task_id,name)
    using index tablespace SYSAUX
)
tablespace sysaux
/

Rem
Rem table containing all the object instances that the advisor tasks refer too.
Rem These objects could be used for input as well as described in the
Rem output (recommendations). Objects are private to a task. Each object
Rem instance has a unique id.
Rem
Rem       pk : task_id, id
Rem       fk : task_id -> wri$_adv_tasks.id
Rem

create table wri$_adv_objects
(
 id             number          not null,      /* unique id for obj instance */
 type           number          not null,  /* type of object (namespace) */
                                               /* see kea.h for entire list. */
                                    /* 1=TABLE, 2=INDEX, 3=MVIEW 4=MVIEW LOG
                 5=UNDO RETENTION 6=UNDO TABLESPACE 5=SQL STATEMENT 6=SQLSET */
                                          /* 5= SQLWORKLOAD, 6=DATAFILE, ... */
 task_id        number          not null,         /* task assoc. w/ this obj */
 attr1          varchar2(4000),                        /* attr of the object */
 attr2          varchar2(4000),
 attr3          varchar2(4000),
 attr4          clob,
 attr5          varchar2(4000),
 other          clob,                /* additional info associated to object */
 constraint wri$_adv_objects_pk primary key(task_id, id)
    using index tablespace SYSAUX
)
tablespace sysaux
/

Rem
Rem table storing the findings for each task
Rem       pk : (id, task_id)
Rem       fk : task_id -> wri$_adv_tasks.id
Rem          : msg_id -> wri$_adv_message_groups.id
Rem          : more_info_id -> wri$_adv_message_groups.id
Rem          : object_id -> wri$_adv_objects.id
Rem 

create table wri$_adv_findings
(
 id              number          not null,                    /* findings id */
 task_id         number          not null,                /* associated task */
 type            number          not null,                /* type of finding */
 parent          number          not null,              /* parent finding id */
 obj_id          number,               /* id of the associated object if any */
 Impact_msg_id   number,                       /* impact due to this finding */
 impact_val      number,                                     /* impact value */
 msg_id          number,                   /* findings msg : id of msg group */
 more_info_id    number,                      /* id of msg grp for addn info */
 constraint wri$_adv_findings_pk primary key(task_id, id)
    using index tablespace SYSAUX
)
tablespace sysaux
/


Rem
Rem table storing the recommendations for each task
Rem       pk : (id, task_id)
Rem       fk : task_id -> wri$_adv_tasks.id
Rem            findind_id -> wri$_adv_findings.id
Rem          : msg_id -> wri$_adv_message_groups.id
Rem 

create table wri$_adv_recommendations
(
 id              number          not null,                         /* rec id */
 task_id         number          not null,                /* associated task */
 type            varchar2(30),        /* rec. type. specific to each advisor */
 finding_id      number,                       /* related finding (optional) */
 rank            number,                           /* rank of recommendation */
 parent_recs     varchar2(4000),                          /* dependency list */
 benefit_msg_id  number,            /* benefit assoc w/ carrying out the rec */
 benefit_val     number,                                    /* benefit value */
 annotation      number,                              /* annotation status : */
                                                               /* ACCEPT = 1 */
                                                               /* REJECT = 2 */
                                                               /* IGNORE = 3 */
                                                          /* IMPLEMENTED = 4 */
 flags           number,                           /* Advisor-Specific flags */
 constraint wri$_adv_rec_pk primary key(task_id, id)
    using index tablespace SYSAUX
)
tablespace sysaux
/

Rem
Rem table storing the set of actions for the task. The association of
Rem actions to recommendations is provided in wri$_adv_rec_actions
Rem
Rem       pk : (task_id, id)
Rem       fk : task_id -> wri$_adv_tasks.id
Rem          : obj_id -> wri$_adv_objects.id
Rem          : msg_id -> wri$_adv_message_groups.id
Rem

create table wri$_adv_actions
(
 id             number          not null,                       /* action id */
 task_id        number          not null,                  /* associate task */
 obj_id         number,           /* object assoc with the action (optional) */
 command        number          not null,        /* command type (see kea.h) */
                          /* 1='CREATE INDEX', 2='CREATE MATERIALIZED VIEW', */
                                /* 3='ALTER TABLE', 4='CALL ADVISOR' etc ... */
 flags          number,                            /* Advisor-specific flags */
 attr1          varchar2(4000),            /* attributes defining the action */
 attr2          varchar2(4000),
 attr3          varchar2(4000),
 attr4          varchar2(4000),
 attr5          clob,
 attr6          clob,
 num_attr1      number,                         /* General numeric attribute */
 num_attr2      number,                         /* General numeric attribute */
 num_attr3      number,                         /* General numeric attribute */
 num_attr4      number,                         /* General numeric attribute */
 num_attr5      number,                         /* General numeric attribute */
 msg_id         number,                       /* action msg: id of msg group */
 constraint wri$_adv_actions_pk primary key(task_id,id)
    using index tablespace SYSAUX
)
tablespace sysaux
/

Rem
Rem table storing the rationale for each recommendation.
Rem
Rem       pk : (task_id, id)
Rem       fk : task_id -> wri$_adv_tasks.id
Rem          : find_id -> wri$_adv_findings.id
Rem          : rec_id -> wri$_adv_recommendations.id
Rem          : obj_id -> wri$_adv_objects.id
Rem          : msg_id -> wri$_adv_message_groups.id
REM          : impact_msg_id -> wri$_adv_message_groups.id
Rem
create table wri$_adv_rationale
(
 id             number          not null,                    /* rationale id */
 task_id        number          not null,                  /* associate task */
 type           varchar2(30),    /* rationale type. specific to each advisor */
 rec_id         number,                         /* associated recommendation */
 impact_msg_id  number,               /* impact due to the finding described */
 impact_val     number,                                      /* impact value */
 obj_id         number,             /* object associated with this rationale */
 msg_id         number,                   /* rationale msg : id of msg group */
 attr1          varchar2(4000),         /* attributes defining the rationale */
 attr2          varchar2(4000),
 attr3          varchar2(4000),
 attr4          varchar2(4000),
 attr5          clob,
 constraint wri$_adv_rationale_pk primary key (task_id, id)
    using index tablespace SYSAUX
)
tablespace sysaux
/


Rem
Rem table storing the association of actions to recommendations. The relation
Rem is many-to-many within a task.
Rem
Rem       pk : (task_id, rec_id, act_id)
Rem       fk : task_id -> wri$_adv_tasks.id
Rem          : act_id -> wri$_adv_actions.id
Rem          : rec_id -> wri$_adv_recommendations.id
Rem

create table wri$_adv_rec_actions
(
 task_id        number          not null,                 /* associated task */
 rec_id         number          not null,                 /* rec within task */
 act_id         number          not null,              /* action within task */
 constraint wri$_adv_rec_actions_pk primary key(task_id,rec_id,act_id)
    using index tablespace SYSAUX
)
tablespace sysaux
/

Rem
Rem   directives table
Rem

create sequence wri$_adv_seq_dir        /* Generates unique directive number */
  increment by 1
  start with 1
  minvalue 1
  maxvalue 4294967295
  nocycle
  cache 10
/

create table wri$_adv_directives
   (
      task_id              number not null,            /* Unique task number */
      src_task_id          number,                     /* Source task number */
      id                   number not null,       /* Unique directive number */
      obj_owner            varchar2(30),         /* Target object owner name */
      obj_name             varchar2(30),                /* Table object name */
      rec_id               number,         /* Imported recommendation number */
      rec_action_id        number,         /* Imported recommendation action */
      command              number,               /* Directive command number */
      attr1                varchar2(2000),            /* Directive attribute */
      attr2                varchar2(2000),            /* Directive attribute */
      attr3                varchar2(2000),            /* Directive attribute */
      attr4                varchar2(2000),            /* Directive attribute */
      attr5                clob,                      /* Directive attribute */
      constraint wri$_adv_directives primary key(task_id,id)
        using index tablespace SYSAUX
   )
tablespace sysaux
/

Rem
Rem Journal table
Rem
Rem   Valid values for the type column are:
Rem
Rem      1  - Fatal
Rem      2  - Error
Rem      3  - Warning
Rem      4  - Information
Rem      5  - Debug level 1
Rem      6  - Debug level 2
Rem      7  - Debug level 3
Rem      8  - Debug level 4
Rem      9  - Debug level 5

create sequence wri$_adv_seq_journal
  increment by 1
  start with 1
  minvalue 1
  maxvalue 4294967295
  nocycle
  cache 10
/

create table wri$_adv_journal
   (
      task_id               number not null,              /* Current task id */
      seq_id               number not null,           /* Unique for the task */
      type                 number not null,   /* See comment for valid value */
      msg_id               number not null,         /* Message set id number */
      constraint wri$_adv_journal primary key(task_id,seq_id)
        using index tablespace SYSAUX
   )
tablespace sysaux
/


Rem
Rem This table stores the set of message ids along with its parameters
Rem for the message fields of all the other tables. 
Rem In general an advisor message is composed of a set of Oracle messages
Rem (each row in the table below is an Oracle message). Each set or group is
Rem given a unique id which is referenced by the message columns in the other
Rem tables.
Rem
Rem Each row is an Oracle message belonging to a facility (eg: ORA, ADV).
Rem The message definition captures formatting information too, since the
Rem advisor will be writing out user readable sentences. The three formatting
Rem fields include
Rem     hdr : a number used as a boolean that denotes if the msg hdr
Rem           (eg: ADV-2300: ) needs to be present in the output.
Rem     lm  : is the number of spaces inserted before the message.
Rem     nl  : is the number of new-lines to appear before the message. 
Rem 
Rem        pk : id
Rem

create table wri$_adv_message_groups
(
 task_id        number          not null,               /* Task or object id */
 id             number          not null,         /* unique id for msg group */
 seq            number          not null,    /* seq# of msg in message group */
 message#       number          not null,                 /* oracle message# */
 fac            varchar2(3),                         /* msg facility. eg ORA */
 hdr            number,                                /* 1 : include header */
                                                             /* 0: no header */
 lm             number,              /* left margin : #spaces to be inserted */
                                                               /* before msg */
 nl             number,                 /* number of newlines before message */
 p1             varchar2(4000),                          /* parameter values */
 p2             varchar2(4000),
 p3             varchar2(4000),
 p4             varchar2(4000),
 p5             varchar2(4000),
 constraint wri$_adv_message_groups_pk primary key(id, seq)
    using index tablespace SYSAUX
)
tablespace sysaux
/

create index wri$_adv_msg_grps_idx_01
  on sys.wri$_adv_message_groups (task_id, id)
  tablespace SYSAUX
/

create sequence wri$_adv_seq_msggroup                      /* Message-set id */
  increment by 1
  start with 1
  minvalue 1
  maxvalue 4294967295
  nocycle
  cache 10
/


Rem
Rem this table is used for tracking advisor usage.
Rem
Rem      pk: advisor_id
Rem      fk: wri$_adv_definitions.id
Rem

create table wri$_adv_usage
(
 advisor_id       number      not null,                        /* advisor id */
 last_exec_time   date        not null,  /* the date that some task for this */
                                                     /* advisor was executed */
 num_execs        number      not null         /* total number of executions */
)
tablespace sysaux
/


REM
REM   SQL Access Advisor tables
REM

Rem
Rem   Sequence for query id numbers
Rem

create sequence wri$_adv_seq_sqlw_query      /* Generates unique task number */
  increment by 1
  start with 1
  minvalue 1
  maxvalue 4294967295
  nocycle
  cache 10
/

Rem
Rem SQL workload rollup table
Rem

create table wri$_adv_sqlw_sum
  (
    workload_id             number,                    /* Workload id number */
    data_source             varchar2(2000),          /* Workload data source */
    num_select              number,         /* Number of selects in workload */
    num_insert              number,        /* Number of insertss in workload */
    num_delete              number,         /* Number of deletes in workload */
    num_update              number,         /* Number of updates in workload */
    num_merge               number,          /* Number of merges in workload */
    sqlset_id               number,                /* Link to SQL Tuning Set */
    constraint wri$_adv_sqlw_sum_pk primary key(workload_id)
      using index tablespace SYSAUX
  )
tablespace sysaux
/

Rem
Rem Access Advisor workload statements
Rem
Rem         Valid values for valid column:
Rem
Rem             0 - unused
Rem             1 - Valid after workload filtering
Rem             2 - Valid after applying importance filtering

create table wri$_adv_sqlw_stmts
   (
      workload_id             number,                 /* Workload identifier */
      sql_id                  number,                    /* SQL statement id */
      hash_value              number,                   /* Statement hash id */
      optimizer_cost          number,             /* Declared optimizer cost */
      username                varchar2(30),   /* User who executed statement */
      module                  varchar2(64),       /* Application module name */
      action                  varchar2(64),       /* Application action name */
      elapsed_time            number,                  /* Total Elapsed time */
      cpu_time                number,                      /* Total CPU time */
      buffer_gets             number,                   /* Total buffer gets */
      disk_reads              number,                    /* Total disk reads */
      rows_processed          number,                /* Total rows processed */
      executions              number,                    /* Total executions */
      priority                number,         /* Statement business priority */
      last_execution_date     date,              /* Last execution date/time */
      command_type            number,                        /* Command type */
      stat_period             number,                    /* Execution window */
      sql_text                clob,                        /* Statement text */
      valid                   number,                  /* Statement is valid */
      constraint wri$_adv_sqlw_stmts_pk primary key(workload_id,sql_id)
        using index tablespace SYSAUX
   )
tablespace sysaux
/


Rem
Rem   sql Workload table references
Rem
Rem         Contains a list of tables referenced by each workload statement
Rem

create table wri$_adv_sqlw_tables
   (
      workload_id             number,                 /* Workload identifier */
      sql_id                  number,                    /* SQL statement id */
      table_owner#            number,         /* Owner id of table reference */
      table#                  number,         /* Table id of table reference */
      table_owner             varchar2(30),              /* Table owner name */
      table_name              varchar2(30),                    /* Table name */
      inst_id                 number,                         /* Instance id */
      hash_value              number,                /* Statement hash value */
      addr                    raw(16),                  /* Statement address */
      obj_type                number                          /* Object type */
   )
tablespace sysaux
/

create index wri$_adv_sqlw_tables_idx_01
   on wri$_adv_sqlw_tables (workload_id,sql_id)
  tablespace SYSAUX
/

Rem
Rem SQL workload table volatility rollup
Rem

create table wri$_adv_sqlw_tabvol
  (
    workload_id             number,                    /* Workload id number */
    owner_name              varchar2(30),                      /* Owner name */
    table_owner#            number,           /* Owner id of table reference */
    table_name              varchar2(30),                      /* Table name */
    table#                  number,           /* Table id of table reference */
    upd_freq                number,                      /* # of update hits */
    ins_freq                number,                      /* # of insert hits */
    del_freq                number,                      /* # of delete hits */
    dir_freq                number,                 /* # of direct load hits */
    upd_rows                number,                     /* # of updated rows */
    ins_rows                number,                    /* # of inserted rows */
    del_rows                number,                     /* # of deleted rows */
    dir_rows                number,                 /* # of direct load rows */
    constraint wri$_adv_sqlw_tv_pk primary key(workload_id,table#)
       using index tablespace SYSAUX
  )
tablespace sysaux
/

Rem
Rem SQL workload column volatility rollup
Rem
Rem     Columns changed by an update statement
Rem

create table wri$_adv_sqlw_colvol
  (
    workload_id             number,                    /* Workload id number */
    table_owner#            number,           /* Owner id of table reference */
    table#                  number,           /* Table id of table reference */
    col#                    number,          /* Column id of table reference */
    upd_freq                number,                             /* # of hits */
    upd_rows                number,         /* Total rows effected by update */
    constraint wri$_adv_sqlw_cv_pk primary key(workload_id,table#,col#)
      using index tablespace SYSAUX
  )
tablespace sysaux
/

Rem
Rem   Workload mapping table
Rem

create table wri$_adv_sqla_map
   (
      task_id                 number,                             /* Task id */
      workload_id             number                          /* Workload id */
   )
tablespace sysaux
/

create index wri$_adv_sqla_map_01
   on wri$_adv_sqla_map (task_id)
  tablespace SYSAUX
/

create index wri$_adv_sqla_map_02
   on wri$_adv_sqla_map (workload_id)
  tablespace SYSAUX
/


Rem
Rem sql workload statements (private to Access Advisor tasks)
Rem
Rem         Valid values for validated column:
Rem
Rem             0 - unused
Rem             1 - Valid after workload filtering
Rem             2 - Valid after applying importance filtering

create table wri$_adv_sqla_stmts
   (
      task_id                 number not null,             /* Task id number */
      workload_id             number,                 /* Workload identifier */
      sql_id                  number,                    /* SQL statement id */
      pre_cost                number,                  /* Optimizer pre-cost */
      post_cost               number,                 /* Optimizer post-cost */
      imp                     number,               /* Calculated importance */
      rec_id                  number,                   /* Recommendation id */
      validated               number                     /* Filtering marker */
   )
tablespace sysaux
/

create index wri$_adv_sqla_stmts_idx_01
   on wri$_adv_sqla_stmts (task_id,workload_id,sql_id)
  tablespace SYSAUX
/

create index wri$_adv_sqla_stmts_idx_02
   on wri$_adv_sqla_stmts (task_id,validated)
  tablespace SYSAUX
/

Rem
Rem   Access Advisor temporary table
Rem

create table wri$_adv_sqla_tmp
   (
      owner#                  number,
      constraint wri$_adv_sqla_tmp_pk primary key(owner#)
        using index tablespace SYSAUX
   )
tablespace sysaux
/

Rem
Rem   Access Advisor fake-mv, fake-index registration table
Rem

create table wri$_adv_sqla_fake_reg
   (
      task_id                 number,                    /* Task id of owner */
      owner                   varchar2(30),          /* Owner name of object */
      name                    varchar2(30),                /* Name of object */
      fake_type               number                    /* 1 = Index, 2 = MV */
   )
tablespace sysaux
/

create index wri$_adv_sqla_freg_idx_01
  on wri$_adv_sqla_fake_reg (task_id)
  tablespace SYSAUX;


Rem 
Rem subtype definition for the HDM
Rem

CREATE OR REPLACE TYPE wri$_adv_hdm_t UNDER wri$_adv_abstract_t
(
  OVERRIDING MEMBER procedure sub_execute (task_id IN NUMBER,
                                           err_num OUT NUMBER),
  overriding member procedure sub_get_report (task_id IN NUMBER,
                                              type IN VARCHAR2,
                                              level IN VARCHAR2,
                                              section IN VARCHAR2,
                                              buffer IN OUT NOCOPY CLOB)
);
/

Rem
Rem  Set up Access Advisor definition
Rem

CREATE OR REPLACE TYPE wri$_adv_sqlaccess_adv under wri$_adv_abstract_t
  (
    overriding member procedure sub_execute(task_id in NUMBER,
                                            err_num out number),
    overriding member procedure sub_reset(task_id in number),
    overriding member procedure sub_resume(task_id in number),
    overriding member procedure sub_delete(task_id in number),
    overriding member procedure sub_param_validate(task_id in number,
                                                   name in varchar2, 
                                                   value in out varchar2),
    overriding member procedure sub_get_script (task_id IN NUMBER,
                                                type IN VARCHAR2,
                                                buffer IN OUT NOCOPY CLOB,
                                                rec_id IN NUMBER,
                                                act_id IN NUMBER),
    overriding member procedure sub_get_report (task_id IN NUMBER,
                                                type IN VARCHAR2,
                                                level IN VARCHAR2,
                                                section IN VARCHAR2,
                                                buffer IN OUT NOCOPY CLOB),
    overriding member procedure sub_validate_directive(task_id IN NUMBER,
                                                       command_id IN NUMBER,
                                                       attr1 IN OUT VARCHAR2,
                                                       attr2 IN OUT VARCHAR2,
                                                       attr3 IN OUT VARCHAR2,
                                                       attr4 IN OUT VARCHAR2,
                                                       attr5 IN OUT VARCHAR2),
    overriding member procedure sub_update_rec_attr (task_id IN NUMBER,
                                                     rec_id IN NUMBER,
                                                     act_id IN NUMBER,
                                                     name IN VARCHAR2,
                                                     value IN VARCHAR2),
    overriding member procedure sub_get_rec_attr (task_id IN NUMBER,
                                                  rec_id IN NUMBER,
                                                  act_id IN NUMBER,
                                                  name IN VARCHAR2,
                                                  value OUT VARCHAR2),
    overriding member procedure sub_cleanup(task_id in number),
    overriding member procedure sub_implement(task_id IN NUMBER),
    overriding member procedure sub_implement(task_id in number, 
                                              rec_id in number,
                                              exit_on_error in number),
    overriding member procedure sub_import_directives (task_id in number,
                                                       from_id in number,
                                                       import_mode in varchar2,
                                                       accepted out number,
                                                       rejected out number),
    overriding member procedure sub_user_setup(adv_id in number),
    overriding member procedure sub_quick_tune (task_name in varchar2,
                                                attr_clob in clob,
                                                attr_vc in varchar2,
                                                attr_num in number,
                                                template in varchar2,
                                                implement in boolean)
  );
/

Rem
Rem Access Advisor Tune MView
Rem

CREATE OR REPLACE TYPE wri$_adv_tunemview_adv under wri$_adv_abstract_t
  (
    overriding member procedure sub_execute(task_id in NUMBER,
                                            err_num out number),
    overriding member procedure sub_reset(task_id in number),
    overriding member procedure sub_resume(task_id in number),
    overriding member procedure sub_delete(task_id in number),
    overriding member procedure sub_param_validate(task_id in number,
                                                   name in varchar2, 
                                                   value in out varchar2),
    overriding member procedure sub_get_script (task_id IN NUMBER,
                                                type IN VARCHAR2,
                                                buffer IN OUT NOCOPY CLOB,
                                                rec_id IN NUMBER,
                                                act_id IN NUMBER),
    overriding member procedure sub_validate_directive(task_id IN NUMBER,
                                                       command_id IN NUMBER,
                                                       attr1 IN OUT VARCHAR2,
                                                       attr2 IN OUT VARCHAR2,
                                                       attr3 IN OUT VARCHAR2,
                                                       attr4 IN OUT VARCHAR2,
                                                       attr5 IN OUT VARCHAR2),
    overriding member procedure sub_update_rec_attr (task_id IN NUMBER,
                                                     rec_id IN NUMBER,
                                                     act_id IN NUMBER,
                                                     name IN VARCHAR2,
                                                     value IN VARCHAR2),
    overriding member procedure sub_get_rec_attr (task_id IN NUMBER,
                                                  rec_id IN NUMBER,
                                                  act_id IN NUMBER,
                                                  name IN VARCHAR2,
                                                  value OUT VARCHAR2),
    overriding member procedure sub_cleanup(task_id in number),
    overriding member procedure sub_implement(task_id IN NUMBER),
    overriding member procedure sub_implement(task_id in number, 
                                              rec_id in number,
                                              exit_on_error in number),
    overriding member procedure sub_import_directives (task_id in number,
                                                       from_id in number,
                                                       import_mode in varchar2,
                                                       accepted out number,
                                                       rejected out number),
    overriding member procedure sub_user_setup(adv_id in number),
    overriding member procedure sub_quick_tune (task_name in varchar2,
                                                attr_clob in clob,
                                                attr_vc in varchar2,
                                                attr_num in number,
                                                template in varchar2,
                                                implement in boolean)
  );
/

Rem
Rem  Access Advisor workload manager
Rem

create OR REPLACE type wri$_adv_workload under wri$_adv_abstract_t
  (
    overriding member procedure sub_create(task_id in number,
                                           from_task_id in number),
    overriding member procedure sub_reset(task_id in number),
    overriding member procedure sub_delete(task_id in number),
    overriding member procedure sub_param_validate(task_id in number,
                                                   name in varchar2, 
                                                   value in out varchar2),
    overriding member procedure sub_get_report (task_id IN NUMBER,
                                                type IN VARCHAR2,
                                                level IN VARCHAR2,
                                                section IN VARCHAR2,
                                                buffer IN OUT NOCOPY CLOB),
    overriding member procedure sub_user_setup(adv_id in number)
  );
/


Rem
Rem subtype definition for Undo Advisor
Rem

create OR replace type wri$_adv_undo_adv UNDER wri$_adv_abstract_t
  (
    OVERRIDING MEMBER PROCEDURE sub_execute(task_id IN NUMBER,
                                            err_num OUT NUMBER)
  );
/


--------------------------------------------------------------------------------
--                  wri$_adv_sqltune sub type specification                   --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- NAME: 
--     wri$_adv_sqltune  
--
-- DESCRIPTION: 
--     This is a sub-type object type that implements the SQL Tuning Advisor.
--     It is mainly used to integrate the advisor within the Advisor Framework. 
--     The implementation of this type resides in .../sqltune/prvtsqlt.sql
--------------------------------------------------------------------------------
create OR replace type wri$_adv_sqltune under wri$_adv_abstract_t 
(    
  overriding MEMBER PROCEDURE sub_execute(task_id IN NUMBER, 
                                          err_num OUT NUMBER),
  overriding MEMBER PROCEDURE sub_reset(task_id IN NUMBER),
  overriding MEMBER PROCEDURE sub_resume(task_id IN NUMBER),
  overriding MEMBER PROCEDURE sub_delete(task_id IN NUMBER),
  overriding MEMBER PROCEDURE sub_get_script(task_id IN NUMBER,
                                             type    IN VARCHAR2,
                                             buffer  IN OUT NOCOPY CLOB,
                                             rec_id  IN NUMBER,
                                             act_id  IN NUMBER),
  overriding MEMBER PROCEDURE sub_get_report(task_id IN NUMBER,
                                             type    IN VARCHAR2,
                                             level   IN VARCHAR2,
                                             section IN VARCHAR2,
                                             buffer  IN OUT NOCOPY CLOB)
) FINAL
/  
--------------------------------------------------------------------------------

Rem
Rem  Subtype for Object Space Growth Trend Advisor
Rem

create OR replace type wri$_adv_objspace_trend_t under wri$_adv_abstract_t
(
  overriding member procedure sub_execute (task_id IN  NUMBER,
                                           err_num OUT NUMBER)
);
/

Rem
Rem  Drop tuning tasks when a user is dropped
Rem
  
DELETE FROM sys.duc$ WHERE owner='SYS' and pack='PRVT_ADVISOR' and
  proc='DELETE_USER_TASKS' and operation#=1
/
INSERT INTO sys.duc$ (owner,pack,proc,operation#,seq,com)
  VALUES ('SYS','PRVT_ADVISOR','DELETE_USER_TASKS',1,1,
  'During drop cascade, drop advisor tasks belonging to user')
/
commit
/
  
Rem
Rem NOTE: all advisor and parameter definitions are now placed in
Rem prvtdadv.sql in procedure SETUP_REPOSITORY.
Rem

