Rem
Rem $Header: catsch.sql 26-may-2005.17:22:43 rramkiss Exp $
Rem
Rem catsch.sql
Rem
Rem Copyright (c) 2002, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catsch.sql - Create tables and catalog views for the job scheduler
Rem
Rem    DESCRIPTION
Rem
Rem
Rem    NOTES
Rem This script must be run while connected as SYS or INTERNAL.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rramkiss    05/24/05 - expose DETACHED attribute 
Rem    rramkiss    05/12/05 - update running_chains views 
Rem    evoss       05/09/05 - remove calendar column 
Rem    rramkiss    04/19/05 - add missing entry in views 
Rem    rramkiss    03/15/05 - add RESTART_ON_RECOVERY chain step flag 
Rem    rramkiss    03/07/05 - add CHAIN_STALLED job state 
Rem    samepate    02/02/05 - add NEXT_START_DATE to window_group views
Rem    samepate    01/06/05 - bug #3838374 
Rem    evoss       01/07/05 - make resolve calendar usable from odbc 
Rem    rramkiss    12/20/04 - updatre chain rule views for new syntax 
Rem    rramkiss    11/04/04 - bug #3987649 - fix 
Rem                           all_scheduler_job_log/job_run_details 
Rem    evoss       10/26/04 - #3971324: fix reporting of cpu used 
Rem    rramkiss    10/20/04 - bug #3953140 - asynch run jobs have no status 
Rem    rramkiss    09/24/04 - show state of subchain steps even after the 
Rem                           subchain is complete 
Rem    rramkiss    04/21/04 - grant CREATE EXTERNAL JOB to SCHEDULER_ADMIN 
Rem    rgmani      09/24/04 - Add new fields to global attribute 
Rem    rgmani      09/02/04 - grabtrans 'evoss_bug-3484069' 
Rem    evoss       08/30/04 - add STOPPED status 
Rem    rramkiss    08/24/04 - add log_id to chain step_state table 
Rem    rgmani      08/25/04 - Fix running jobs view definition 
Rem    evoss       08/11/04 - set scheduler default timezone from system env 
Rem    rramkiss    07/22/04 - *_SCHEDULER_RUNNING_JOBS should show running 
Rem                           chains 
Rem    rgmani      07/19/04 - Fix enabled column defn in *_scheduler_jobs 
Rem    evoss       07/06/04 - make calendar resolve types global 
Rem    rramkiss    06/23/04 - update *running_chains views 
Rem    rramkiss    06/14/04 - OEM bug, add step_type to *_CHAIN_STEP views 
Rem    rgmani      05/13/04 - Notify for queue subscribe/unsubscribe 
Rem    rgmani      05/12/04 - Add event-related global attributes 
Rem    rgmani      05/05/04 - Create sequence for generating rule names 
Rem    rgmani      05/04/04 - Fix errors 
Rem    rgmani      04/27/04 - Event based scheduling 
Rem    evoss       05/14/04 - add calendar column to schedule views 
Rem    rramkiss    04/07/04 - remove job_step (merge into job_step_state)
Rem    rramkiss    04/07/04 - don't need duration in step_state base table 
Rem    rramkiss    04/06/04 - updates names, new columns 
Rem    rramkiss    03/25/04 - views for running job chain steps 
Rem    rramkiss    03/25/04 - update job_step_state format 
Rem    rramkiss    03/16/04 - job step state views and updates to table 
Rem    rramkiss    03/12/04 - job_chain->chain 
Rem    rramkiss    03/08/04 - all_* and user_* chain views 
Rem    rramkiss    03/08/04 - chains views 
Rem    evoss       12/16/03 - add session serial number to scheduler running 
Rem                           jobs view 
Rem    evoss       11/17/03 - add default_timezone, follow_default_timezone 
Rem    rramkiss    12/04/03 - fix last_start_date in windows views 
Rem    rramkiss    09/23/03 - bug #3154787 
Rem    rgmani      09/08/03 - 
Rem    rramkiss    08/30/03 - restore job table 
Rem    rramkiss    08/04/03 - enable created indexes (bug #3078899) 
Rem    rramkiss    08/13/03 - SUCCESS->SUCCEEDED
Rem    rramkiss    06/26/03 - add sequence for job_name suffixes
Rem    rgmani      07/03/03 - Move current open window to end
Rem    rramkiss    06/30/03 - trap already_exists error
Rem    rramkiss    07/08/03 - trivial view tweaks
Rem    rramkiss    06/16/03 - flag default job class as SYSTEM
Rem    rramkiss    05/29/03 - do not replace type sys.scheduler$_job_external
Rem    rramkiss    05/08/03 - remote jobs are enabled by definition
Rem    rramkiss    04/10/03 - remove distributed scheduling setup stuff
Rem    rramkiss    03/24/03 - add new subscriber for incoming external jobs
Rem    rramkiss    03/24/03 - add job status accessor fn to job_fixed type
Rem    rramkiss    03/19/03 - add new REMOTE job state
Rem    rramkiss    03/06/03 - alter external job type
Rem    rramkiss    02/18/03 - add external job type
Rem    rramkiss    02/04/03 - add destination accessor method to _job_fixed
Rem    rramkiss    02/03/03 - add source and destination job fields
Rem    rramkiss    06/10/03 - grabtrans 'rramkiss_bug-2996860'
Rem    rramkiss    06/03/03 - remove comments for max_run_dur
Rem    rramkiss    06/03/03 - add new 'RETRY SCHEDULED' status
Rem    rramkiss    06/03/03 - Expose retries in job views
Rem    rramkiss    06/09/03 - mask already_exists error
Rem    rramkiss    06/09/03 - update comments for running_jobs
Rem    rgmani      06/10/03 - Add global parameters view
Rem    srajagop    06/10/03 - purging log
Rem    rramkiss    05/08/03 - comments for new system flag
Rem    rramkiss    05/07/03 - add SYSTEM flag to jobs views
Rem    rramkiss    04/22/03 - don't show SYS objects to non-SYS users w/out object privs
Rem    rgmani      05/20/03 - Modify global sttrib table
Rem    srajagop    03/20/03 - make additional info a clob
Rem    rramkiss    04/09/03 - bug #2875611-all_job_log not showing dropped jobs
Rem    rramkiss    03/31/03 - bug #2869920 - mask "already exists" errors
Rem    rgmani      04/03/03 - Add parameters table
Rem    rramkiss    02/21/03 - all all_scheduler_ views should be views
Rem    rramkiss    02/17/03 - stop_on_window_exit=>stop_on_window_close
Rem    raavudai    03/12/03 - add order clause to scheduler$_instance_s
Rem    rramkiss    02/18/03 - service colmn for classes should be 64 chars long
Rem    rgmani      02/26/03 - Add new window fields
Rem    rramkiss    02/10/03 - update argument types
Rem    srajagop    02/07/03 - add actual_start_date to win
Rem    srajagop    01/31/03 - add comments to logging views
Rem    rramkiss    02/14/03 - expose job flags field in views
Rem    rramkiss    01/23/03 - persistent=>auto_drop
Rem    srajagop    01/15/03 - add clientid and guid to job views
Rem    evoss       01/16/03 - add scheduler_running_jobs
Rem    srajagop    01/17/03 - make type number in evtlog
Rem    rramkiss    01/09/03 - JS_COORDINATOR => SCHEDULER_COORDINATOR
Rem    rramkiss    01/07/03 - Remove instance-specific cols from job views
Rem    rramkiss    12/19/02 - View tweaks
Rem    rramkiss    12/17/02 - Change schedule_limit and duration to intervals
Rem    srajagop    01/03/03 - add nls env to job view
Rem    rramkiss    01/13/03 - DEFAULT_CLASS => DEFAULT_JOB_CLASS
Rem    srajagop    01/06/03 - job logging update
Rem    rramkiss    12/04/02 - API tweaks
Rem    rgmani      12/19/02 - Use cscn/dscn for job mutable data
Rem    rgmani      12/13/02 - Add ODCI Describe and Prepare functions
Rem    rramkiss    11/21/02 - window creator should be varchar2
Rem    rramkiss    11/20/02 - Move job and window log tables to sysaux tblspace
Rem    rramkiss    11/20/02 - Update log tables to store names instead of ids
Rem    rramkiss    12/02/02 - update job views to show new statuses
Rem    rramkiss    11/26/02 - Add window creator to views
Rem    rramkiss    11/18/02 - Add ALL_SCHEDULER_* views
Rem    rramkiss    11/18/02 - update job views to show schedule_type now
Rem    rramkiss    11/15/02 - Add persistent flag to job views
Rem    srajagop    11/26/02 - new fields for job q for nls
Rem    rramkiss    11/11/02 - Add new creator field to job_t
Rem    rramkiss    11/05/02 - grant execute on default_class to public
Rem    evoss       11/13/02 - rename simple schedule to calendar string
Rem    rramkiss    10/23/02 - create scheduler_admin role and grant it to dba
Rem    rgmani      10/18/02 - Fix typo
Rem    rgmani      10/18/02 - Add sequence and table for old oids
Rem    rramkiss    10/15/02 - Register export pkg for schedule objects
Rem    rramkiss    10/08/02 - Add tables and views for new schedule object
Rem    rramkiss    09/24/02 - Register procedural objects for export
Rem    rgmani      10/14/02 - Add functional index on job queue table
Rem    rramkiss    09/17/02 - Fixes for argument views
Rem    rramkiss    09/05/02 - Add window groups tables and views
Rem    srajagop    08/30/02 - add failed next time computation to job log
Rem    rramkiss    08/21/02 - dbms_scheduler_admin=>dbms_scheduler.create_class
Rem    rramkiss    08/13/02 - Add missing start_date for windows view
Rem    rgmani      08/12/02 - Add job object type
Rem    rgmani      08/01/02 - Add user callback columns to job table
Rem    rramkiss    07/26/02 - Add missing fields to job views
Rem    srajagop    07/23/02 - srajagop_scheduler_1
Rem    srajagop    07/21/02 - add job, window logs
Rem    rramkiss    07/18/02 - Add schedule_type of once to job views
Rem    rramkiss    07/17/02 - Add program/job argument views
Rem    rramkiss    07/17/02 - Add windows/classes views. Remove priority_list
Rem    rramkiss    07/16/02 - Add views for programs and jobs
Rem    rgmani      07/16/02 - Add columns to scheduler job table
Rem    rramkiss    07/10/02 - Remove default_exists col from program_arg table
Rem    rramkiss    07/10/02 - Update argument table field names
Rem    rramkiss    07/09/02 - Add creation of DEFAULT_CLASS
Rem    rramkiss    07/02/02 - Update $_window fields
Rem    rramkiss    06/26/02 - Add prvthsch and prvtbsch package scripts
Rem    rramkiss    06/25/02 - Add program_action field to scheduler$_job
Rem    rramkiss    05/23/02 - Change timestamp to timestamp_with_time_zone
Rem    rramkiss    04/11/02 - Created
Rem

CREATE TABLE sys.scheduler$_program
(
  obj#            number              NOT NULL         /* program identifier */
                  CONSTRAINT scheduler$_program_pk PRIMARY KEY,
  action          varchar2(4000),               /* filename/subprogram/block */
  number_of_args  number,     /* number of arguments required by the program */
  comments        varchar2(240),                        /* program comments */
  flags           number,                         /* includes execution type */
  run_count       number                              /* number of times run */
)
/

CREATE TABLE sys.scheduler$_class
(
  obj#             number             NOT NULL          /* class identifier */
                   CONSTRAINT scheduler$_class_pk PRIMARY KEY,
  res_grp_name     varchar2(30),             /* name of assoc resource group */
  default_priority number,          /* The default priority for the class in 
                                             any window that does not have a
                                            priority plan associated with it */
  affinity         varchar2(64),     /* name of the affined service/instance */
  log_history      number,   /* The number of days worth of logs to preserve */
  flags            number,     /* includes purge policy, stop on window exit */
  comments         varchar2(240)                          /* class comments */
)
/

create or replace library scheduler_job_lib trusted is static;
/

/* job queue dependecies */
create or replace type sys.scheduler$_job_fixed 
   oid '00000000000000000000000000020016'
   as opaque varying (*)
   using library scheduler_job_lib (

   member function get_destination return varchar2,

   member function get_flags return number

);
/

create or replace type sys.scheduler$_job_mutable as object
(
  job_status      number,                 /* Job status running/disabled etc */
  next_run_date   timestamp with time zone,/* next date this job will run on */
  last_start_date timestamp with time zone,/* last date on which the job was
                                                                     started */
  last_end_date   timestamp with time zone,   /* last date on which this job
                                                                   completed */
  retry_count     number,            /* Current number of unsuccessful 
                                        retries of this job */
  run_count       number,                             /* number of times run */
  failure_count   number,                          /* number of times failed */
  running_instance number,              /* Instance on which job is running */
  running_slave    number          /* Slave ID of slave that is running job */  
);
/

/* this is the object type that is propagated between nodes. It needs to be
  declared here because internal packages need it for the propagation
  transformation function */
/* we don't replace the type because this would invalidate existing rules on
 * the job queue */
create type sys.scheduler$_job_external as object
(
  job_name   varchar2(30),
  job_schema varchar2(30),
  job_object sys.scheduler$_job_fixed                   /* internal job type */
);
/

create or replace type sys.scheduler$_job_t as object
(
   /* Fixed fields */
  obj#            number,                                  /* job identifier */
  program_oid     number,                              /* program identifier */
  program_action  varchar2(4000),                          /* program action */
  schedule_expr   varchar2(4000),          /* string specifying the schedule */
  schedule_limit  interval day(3) to second (0),  /* interval after which the 
                                                     job must be rescheduled */
  schedule_id     number,            /* object ID representing the schedule
                                        this can be a window, a window group or
                                        a named schedule */
  start_date      timestamp with time zone,    /* the date on which this job
                                                                     started */
  end_date        timestamp with time zone, /* the date after which this job
                                                             will not be run */
  last_enabled_time timestamp with time zone,   /* time job was last enabled */
  class_oid       number,          /* identifier of associated class, if any */
  priority        number,                      /* requested program priority */
  job_weight      number,            /* weight of job */
  number_of_args  number,                  /* Number of times to retry a job 
                                                            before giving up */
  max_runs        number,            /* Maximum number of runs after which job 
                                        will be disabled */
  max_failures    number,          /* Maximum number of times a job can fail 
                                         before it is automatically disabled */
  max_run_duration interval day(3) to second(0), /* reserved for future use */
  flags           number,    /* state code, execution/schedule type, output? */
  comments        varchar2(240),                            /* job comments */
  user_callback    varchar2(92),                   /* User callback routine */
  user_callback_ctx number,  /* Context in which callback should be invoked */
  creator           varchar2(30),           /* original creator of this job */
  client_id         varchar2(64),                   /* clientid of this job */
  guid              varchar2(32),                       /* GUID of this job */
  nls_env           varchar2(4000),           /* NLS environment of this job */
  env               raw(32),                         /* Misc env of this job */
  char_env          varchar2(4000),               /* Used for Trusted Oracle */
  source            varchar2(128),                  /* source global DB name */
  destination       varchar2(128),             /* destination global DB name */

   /* Mutable fields */
  job_status      number,                 /* Job status running/disabled etc */
  next_run_date   timestamp with time zone,/* next date this job will run on */
  last_start_date timestamp with time zone,/* last date on which the job was
                                                                     started */
  last_end_date   timestamp with time zone,   /* last date on which this job
                                                                   completed */
  retry_count     number,            /* Current number of unsuccessful 
                                        retries of this job */
  run_count       number,                             /* number of times run */
  failure_count   number,                          /* number of times failed */
  running_instance number,              /* Instance on which job is running */
  running_slave    number          /* Slave ID of slave that is running job */
);
/

create or replace type sys.scheduler$_job_argument_t as object
(
  oid             number,                                  /* job identifier */
  name            varchar2(30),                             /* argument name */
  position        number,                         /* posn of arg in arg list */
  type_number     number,                          /* type of value expected */
  user_type_num   number,           /* for a user type, the user type number */
  value           sys.anydata,                             /* assigned value */
  flags           number                                      /* flags field */
);
/

create or replace type sys.scheduler$_joblst_t as table of 
  sys.scheduler$_job_t;
/

create or replace type sys.scheduler$_jobarglst_t as table of 
  sys.scheduler$_job_argument_t;
/

create or replace type sys.scheduler$_job_view_t as object
(
  shared_key   RAW(8),
  session_key  RAW(8),

  static function ODCITableDescribe(rettyp OUT SYS.AnyType,
                                    arg number)
                      return number,
  static function ODCITablePrepare(sctx OUT sys.scheduler$_job_view_t,
                                   tf_info SYS.ODCITabFuncInfo,
                                   rws_ptr in RAW, heap_ptr in RAW)
                      return number,
  static function ODCITableStart(sctx IN OUT sys.scheduler$_job_view_t,
                                 rws RAW)
                      return number,
  member function ODCITableFetch(self in out sys.scheduler$_job_view_t,
                                 nrows in number,
                                 outset out sys.scheduler$_joblst_t)
                      return number,
  member function ODCITableClose(self in sys.scheduler$_job_view_t)
                      return number
);
/

create or replace type sys.scheduler$_jobarg_view_t as object
(
  shared_key   RAW(8),
  session_key  RAW(8),

  static function ODCITableDescribe(rettyp OUT SYS.AnyType,
                                    arg number)
                      return number,
  static function ODCITablePrepare(sctx OUT sys.scheduler$_jobarg_view_t,
                                   tf_info SYS.ODCITabFuncInfo,
                                   rws_ptr in RAW, heap_ptr in RAW)
                      return number,
  static function ODCITableStart(sctx IN OUT sys.scheduler$_jobarg_view_t,
                                 rws RAW)
                      return number,
  member function ODCITableFetch(self in out sys.scheduler$_jobarg_view_t,
                                 nrows in number,
                                 outset out sys.scheduler$_jobarglst_t)
                      return number,
  member function ODCITableClose(self in sys.scheduler$_jobarg_view_t)
                      return number
);
/

begin
  dbms_aqadm.create_queue_table
    (queue_table => 'scheduler$_jobqtab',
     queue_payload_type => 'sys.anydata',
     multiple_consumers => true,
     comment => 'Scheduler job queue table');
exception
  when others then
    if sqlcode = -24001 then NULL;
    else raise;
    end if;
end;
/

begin
  dbms_aqadm.create_queue
    (queue_name => 'scheduler$_jobq',
     queue_table => 'scheduler$_jobqtab',
     comment => 'Scheduler job queue');
exception
  when others then
    if sqlcode = -24006 then NULL;
    else raise;
    end if;
end;
/

begin
  dbms_aqadm.start_queue(queue_name => 'scheduler$_jobq');
end;
/

-- This is the main subscriber that the job views and the job coordinator use.
declare
  jc  sys.aq$_agent;
begin
  jc := sys.aq$_agent('SCHEDULER_COORDINATOR', NULL, NULL);
  dbms_aqadm.add_subscriber('scheduler$_jobq', jc);
exception
  when others then
    if sqlcode = -24034 then NULL;
    else raise;
    end if;
end;
/

create or replace function sys.scheduler$_jobpipe 
  return sys.scheduler$_joblst_t
pipelined using sys.scheduler$_job_view_t;
/

create or replace function sys.scheduler$_argpipe 
  return sys.scheduler$_jobarglst_t
pipelined using sys.scheduler$_jobarg_view_t;
/

CREATE TABLE sys.scheduler$_job
(
  /* Fixed fields */
  obj#            number              NOT NULL             /* job identifier */
                  CONSTRAINT scheduler$_job_pk PRIMARY KEY,
  program_oid     number,                              /* program identifier */
  program_action  varchar2(4000),                          /* program action */
  schedule_expr   varchar2(4000),          /* string specifying the schedule */
  queue_owner     varchar2(30),               /* Owner of event source queue */
  queue_name      varchar2(30),                    /* Source queue for event */
  queue_agent     varchar2(30),        /* For secure queues - agent used for 
                                                subscription to source queue */
  event_rule      varchar2(65),            /* Rule name associated with this 
                                              job (if event based else NULL) */
  schedule_limit  interval day(3) to second (0),  /* interval after which the 
                                                     job must be rescheduled */
  schedule_id     number,            /* object ID representing the schedule
                                        this can be a window, a window group or
                                        a named schedule */
  start_date      timestamp with time zone,    /* the date on which this job
                                                                     started */
  end_date        timestamp with time zone, /* the date after which this job
                                                             will not be run */
  last_enabled_time timestamp with time zone,   /* time job was last enabled */
  class_oid       number,          /* identifier of associated class, if any */
  priority        number,                      /* requested program priority */
  job_weight      number,            /* weight of job */
  number_of_args  number,                  /* Number of times to retry a job 
                                                            before giving up */
  max_runs        number,            /* Maximum number of runs after which job 
                                        will be disabled */
  max_failures    number,          /* Maximum number of times a job can fail 
                                         before it is automatically disabled */
  max_run_duration interval day(3) to second(0), /* reserved for future use */
  mxdur_msgid     raw(16),          /* Message ID of max run duration event */
  flags           number,    /* state code, execution/schedule type, output? */
  comments        varchar2(240),                            /* job comments */
  user_callback    varchar2(92),                   /* User callback routine */
  user_callback_ctx number,  /* Context in which callback should be invoked */
  creator           varchar2(30),           /* original creator of this job */
  client_id         varchar2(64),                   /* clientid of this job */
  guid              varchar2(32),                       /* GUID of this job */
  nls_env           varchar2(4000),           /* NLS environment of this job */
  env               raw(32),                         /* Misc env of this job */
  char_env          varchar2(4000),               /* Used for Trusted Oracle */
  source            varchar2(128),                  /* source global DB name */
  destination       varchar2(128),             /* destination global DB name */
/* Mutable fields */
  job_status      number,                 /* Job status running/disabled etc */
  next_run_date   timestamp with time zone,/* next date this job will run on */
  last_start_date timestamp with time zone,/* last date on which the job was
                                                                     started */
  last_end_date   timestamp with time zone,   /* last date on which this job
                                                                   completed */
  retry_count     number,            /* Current number of unsuccessful 
                                        retries of this job */
  run_count       number,                             /* number of times run */
  failure_count   number,                          /* number of times failed */
  running_instance number,              /* Instance on which job is running */
  running_slave    number          /* Slave ID of slave that is running job */
)
/
CREATE INDEX sys.i_scheduler_job1
  ON sys.scheduler$_job (next_run_date)
/
CREATE INDEX sys.i_scheduler_job2
  ON sys.scheduler$_job (class_oid)
/
CREATE INDEX sys.i_scheduler_job3
  ON sys.scheduler$_job (schedule_id)
/
CREATE INDEX sys.i_scheduler_job4
  ON sys.scheduler$_job (bitand(job_status, 515))
/

CREATE TABLE sys.scheduler$_job_argument
(
  oid             number              NOT NULL,            /* job identifier */
  name            varchar2(30),                             /* argument name */
  position        number              NOT NULL,   /* posn of arg in arg list */
                  CONSTRAINT scheduler$_job_arg_pk
                    PRIMARY KEY (oid, position) ,
  type_number     number,                          /* type of value expected */
  user_type_num   number,           /* for a user type, the user type number */
  value           sys.anydata,                             /* assigned value */
  flags           number                                      /* flags field */
)
/
CREATE INDEX sys.i_scheduler_job_argument1
  ON sys.scheduler$_job_argument (oid)
/

CREATE TABLE sys.scheduler$_window
(
  obj#            number              NOT NULL          /* window identifier */
                  CONSTRAINT scheduler$_window_pk PRIMARY KEY,
  res_plan        varchar2(30),                 /* ID of assoc resource plan */
  next_start_date timestamp with time zone,     /* next scheduled start date
                                                               of the window */
  manual_open_time timestamp with time zone,    /* Time when manually opened */
  duration        interval day(3) to second(0),    /* duration of the window */
  manual_duration interval day(3) to second(0),   /* duration of manual open */
  schedule_expr   varchar2(4000),              /* inline schedule expression */
  start_date      timestamp with time zone,   /* Date when this window first
                                                                     started */
  end_date        timestamp with time zone,  /* Date after which this window
                                                             will be invalid */
  last_start_date timestamp with time zone, /* Date this window last started
                                                                          on */
  actual_start_date timestamp with time zone, /* Date this window actually 
                                                                  started on */
  scaling_factor  number,            /* The scaling factor to use to determine
                                        the throughput target of the scheduler.
                                        By default it is three times number of
                                        CPUs */
  creator              varchar2(30),/* logged-in user who created the window */
  unused_slave_policy  number,    /* Policy of what to do with unused slaves */
  min_slave_percent    number,           /* Valid for only certain policies,
                                         minimum percentage of typical slave
                                          allocation guaranteed to any class */
  max_slave_percent    number,          /* The maximum percentage of typical
                                          slave allocation that can be given
                                                                to any class */
  schedule_id     number,            /* object ID representing the schedule
                                        this can be a window, a window group or
                                        a named schedule */
  flags                number,  /* includes enabled?, logging, schedule type */
  max_conc_jobs        number,    /* maximum concurrent jobs for this window */
  priority             number,                    /* priority of this window */
  comments             varchar2(240)                     /* window comments */
)
/
CREATE INDEX sys.i_scheduler_window1
  ON sys.scheduler$_window (next_start_date)
/

CREATE TABLE sys.scheduler$_program_argument
(
  oid             number              NOT NULL,        /* program identifier */
  name            varchar2(30),                             /* argument name */
  position        number              NOT NULL,   /* posn of arg in arg list */
                  CONSTRAINT scheduler$_program_arg_pk 
                    PRIMARY KEY (oid, position) ,
  type_number     number,                          /* type of value expected */
  user_type_num   number,           /* for a user type, the user type number */
  value           sys.anydata,                      /* default value, if any */
  flags           number                                      /* flags field */
)
/
CREATE INDEX sys.i_scheduler_program_argument1
  ON sys.scheduler$_program_argument (oid, name)
/

CREATE TABLE sys.scheduler$_srcq_info
(
  obj#            number              NOT NULL
                  CONSTRAINT scheduler$_qinfo_pk PRIMARY KEY,
  ruleset_name    varchar2(30),
  rule_count      number,
  flags           number
)
/

CREATE TABLE sys.scheduler$_srcq_map
(
  oid            number               NOT NULL,
  rule_name      VARCHAR2(65)         NOT NULL,
                  CONSTRAINT scheduler$_srcq_map_pk 
                    PRIMARY KEY (oid, rule_name) ,
  joboid         number               NOT NULL
)
/

CREATE TABLE sys.scheduler$_evtq_sub
(
  agt_name       VARCHAR2(30)         NOT NULL
                 CONSTRAINT scheduler$_evtq_sub_pk PRIMARY KEY,
  uname          VARCHAR2(30)         NOT NULL
)
/

REM We can`t create unique index because name can be NULL, however uniqueness
REM of a name which is not NULL should be enforced by the API

CREATE SEQUENCE sys.scheduler$_instance_s
/

create table scheduler$_event_log
(
 log_id   number NOT NULL   /* assigned job instance ID */
                  CONSTRAINT scheduler$_instance_pk PRIMARY KEY
                  USING INDEX TABLESPACE sysaux,
 log_date timestamp with time zone,  /* The timestamp of the operation */
 type#      number,             /* Type of object for this entry is made */
 name       varchar2(65),                      /* The name of the object */
 owner      varchar2(30),                    /* The schema of the object */
 class_id   number,  /* id of the class the job belonged to at time of entry */
 operation  varchar2(30),                  /* The kind of operation done */
 status     varchar2(30),                        /* success/failure, etc */
 user_name        varchar2(30),                 /* Who performed the operation */
 client_id  varchar2(64),                 /* The client_id of the object */
 guid       varchar2(32),                      /* The guid of the object */
 additional_info clob                  /* add. info. in name value pairs */
) TABLESPACE sysaux;

create table scheduler$_job_run_details
(
  log_id       number, 
  log_date     timestamp with time zone, /* The timestamp of the operation */
  req_start_date  timestamp with time zone,      /* Requested start date */
  start_date      timestamp with time zone,         /* Actual start date */
  run_duration    interval day(3) to second(0),         /* Run duration */
  instance_id     number,              /* Instance on which the job ran */
  session_id      varchar2(30),  /* ID of the session this job ran with */
  slave_pid       varchar2(30), /* process ID of the slave this job ran with */
                                        /* amount of cpu used for this job */
  cpu_used        interval day(3) to second(2),
  error#          number,              /* The error returned for this run */
  additional_info   varchar2(4000)      /* add. info. in name value pairs */
) TABLESPACE sysaux;

create table scheduler$_window_details
(
  log_id     number, 
  log_date   timestamp with time zone, /* The timestamp of the operation */
  instance_id    number,                 /* The instance this window ran on */
  req_start_date  timestamp with time zone,    /* The requested start date */
  start_date   timestamp with time zone,         /* Actual start of window */
  duration     interval day(3) to second(0), /* The duration of the window */
  actual_duration interval day(3) to second(0),    /* The actual duration */
  additional_info  varchar2(4000)       /* add. info. in name value pairs */
) TABLESPACE sysaux;



CREATE TABLE sys.scheduler$_window_group
(
  obj#             number             NOT NULL    /* window group identifier */
                   CONSTRAINT scheduler$_window_group_pk PRIMARY KEY,
  comments         varchar2(240),                        /* optional comment */
  flags            number                          /* includes enabled flag */
)
/

CREATE TABLE sys.scheduler$_wingrp_member
(
  oid             number              NOT NULL,   /* window group identifier */
  member_oid      number              NOT NULL,            /* job identifier */
                  CONSTRAINT scheduler$_wingrp_member_pk
                    PRIMARY KEY (oid, member_oid)
)
/
CREATE INDEX sys.i_scheduler_wingrp_member1
  ON sys.scheduler$_wingrp_member (oid)
/
CREATE INDEX sys.i_scheduler_wingrp_member2
  ON sys.scheduler$_wingrp_member (member_oid)
/

CREATE TABLE sys.scheduler$_schedule
(
  obj#            number              NOT NULL        /* schedule identifier */
                  CONSTRAINT scheduler$_schedule_pk PRIMARY KEY,
  recurrence_expr varchar2(4000),          /* string specifying the schedule */
  queue_owner     varchar2(30),               /* Owner of event source queue */
  queue_name      varchar2(30),                /* Name of event source queue */
  queue_agent     varchar2(30),     /* For secure queues - AQ agent name for 
                                                                source queue */
  reference_date  timestamp with time zone,    /* reference date for special
                                                           recurrence syntax */
  end_date        timestamp with time zone,           /* the end cutoff date */
  comments        varchar2(240),                        /* schedule comments */
  flags           number,                                   /* schedule type */
  max_count       number                    /* Maximum number of occurrences */
)
/

CREATE TABLE sys.scheduler$_chain
(
  obj#            number              NOT NULL   /* running chain identifier */
                  CONSTRAINT scheduler$_chain_pk PRIMARY KEY,
  rule_set        varchar2(30),            /* rule set assoc with this chain */
  rule_set_owner  varchar2(30),                    /* schema of the rule set */
  comments        varchar2(240),                        /* schedule comments */
  eval_interval   interval day(3) to second(0),    /* period of reevaluation */
  flags           number                                    /* schedule type */
)
/

CREATE TABLE sys.scheduler$_step
(
  oid             number              NOT NULL,  /* running chain identifier */
  var_name        varchar2(30)        NOT NULL,            /* job identifier */
  object_name     varchar2(98),
  timeout         interval day(3) to second(0),
  queue_owner     varchar2(30),               /* Owner of event source queue */
  queue_name      varchar2(30),                    /* Source queue for event */
  queue_agent     varchar2(30),        /* For secure queues - agent used for
                                                subscription to source queue */
  condition       varchar2(4000),           /* condition for an inline event */
  flags           number              NOT NULL
)
/
CREATE INDEX sys.i_scheduler_step1
  ON sys.scheduler$_step (oid)
/

CREATE TABLE sys.scheduler$_step_state
(
  job_oid         number        NOT NULL,
  step_name       varchar2(30)  NOT NULL,
                  CONSTRAINT scheduler$_step_state_pk PRIMARY KEY
                  (job_oid, step_name)  USING INDEX TABLESPACE sysaux,
  status          char,
  error_code      number,
  start_date      timestamp with time zone,    /* the date on which this job
                                                                step started */
  end_date        timestamp with time zone,    /* the date on which this job
                                                              step completed */
  job_step_oid    number,
  job_step_log_id number,                /* log id if the step has completed */
  destination     varchar2(128),             /* remote destination for step  */
  flags           number
) TABLESPACE sysaux
/

create or replace type sys.scheduler$_job_step_type as object (
   state           varchar2(12),
   error_code      number,
   completed       varchar2(5),
   start_date      timestamp with time zone,   /* the date on which this job
                                                                step started */
   end_date        timestamp with time zone,   /* the date on which this job
                                                              step completed */
   duration        interval day (3) to second(3)
)
/

-- the below types are used by dbms_scheduler.analyze_chain
CREATE TYPE sys.scheduler$_rule  IS OBJECT (
       rule_name         VARCHAR2(65),
       rule_condition    VARCHAR2(4000),
       rule_action       VARCHAR2(4000))
/
CREATE TYPE sys.scheduler$_rule_list IS
 TABLE OF sys.scheduler$_rule
/

-- step type is not interpreted (just output in the chain_link_list)
-- step types used by the scheduler are 'PROGRAM', 'EVENT', 'BEGIN', 'END'
-- steps of type 'BEGIN' and 'END' are not real steps
CREATE TYPE sys.scheduler$_step_type IS OBJECT (
       step_name    VARCHAR2(32),
       step_type    VARCHAR2(32))
/
CREATE TYPE sys.scheduler$_step_type_list IS
 TABLE OF sys.scheduler$_step_type
/

-- pseudo-steps of type 'BEGIN' will be named '"BEGIN"'
-- pseudo-steps of type 'END' will be named '"END"'
-- possible action types are 'START', 'STOP', 'END_SUCCESS', 'END_FAILURE',
-- 'END_STEP_ERROR_CODE'
CREATE TYPE sys.scheduler$_chain_link IS OBJECT (
       first_step_name    VARCHAR2(32),
       first_step_type    VARCHAR2(32),
       second_step_name   VARCHAR2(32),
       second_step_type   VARCHAR2(32),
       rule_name          VARCHAR2(32),
       rule_owner         VARCHAR2(32),
       action_type        VARCHAR2(32))
/
CREATE TYPE sys.scheduler$_chain_link_list IS
 TABLE OF sys.scheduler$_chain_link
/

GRANT EXECUTE ON sys.scheduler$_rule TO PUBLIC
/
GRANT EXECUTE ON sys.scheduler$_rule_list TO PUBLIC
/
GRANT EXECUTE ON sys.scheduler$_step_type TO PUBLIC
/
GRANT EXECUTE ON sys.scheduler$_step_type_list TO PUBLIC
/
GRANT EXECUTE ON sys.scheduler$_chain_link TO PUBLIC
/
GRANT EXECUTE ON sys.scheduler$_chain_link_list TO PUBLIC
/

CREATE TABLE sys.scheduler$_global_attribute
(
  obj#            number              NOT NULL              /* Attribute OID */
                  CONSTRAINT scheduler$_attrib_pk PRIMARY KEY,
  value           varchar2(128),                          /* Attribute value */
  flags           number,                                      /* Misc flags */
  modified_inst   number,               /* Instance that last modified param */
  additional_info varchar2(128),         /* Any other additional information */
  attr_tstamp     timestamp with time zone,             /* A timestamp field */
  attr_intv       interval day(3) to second(0)          /* An interval field */
)
/

/* Scheduler Event Queue ADT */

create or replace type sys.scheduler$_event_info as object
(
  event_type         VARCHAR2(4000),
  object_owner       VARCHAR2(4000),
  object_name        VARCHAR2(4000),
  event_timestamp    TIMESTAMP WITH TIME ZONE,
  error_code         NUMBER,
  error_msg          VARCHAR2(4000),
  event_status       NUMBER,
  log_id             NUMBER,
  run_count          NUMBER,
  failure_count      NUMBER,
  retry_count        NUMBER,
  spare1             NUMBER,
  spare2             NUMBER,
  spare3             VARCHAR2(4000),
  spare4             VARCHAR2(4000),
  spare5             TIMESTAMP WITH TIME ZONE,
  spare6             TIMESTAMP WITH TIME ZONE,
  spare7             RAW(2000),
  spare8             RAW(2000),
  CONSTRUCTOR FUNCTION scheduler$_event_info (
    event_type         VARCHAR2,
    object_owner       VARCHAR2,
    object_name        VARCHAR2,
    event_timestamp    TIMESTAMP WITH TIME ZONE DEFAULT SYSTIMESTAMP,
    error_code         NUMBER DEFAULT NULL,
    error_msg          VARCHAR2 DEFAULT NULL,
    event_status       NUMBER DEFAULT NULL,
    log_id             NUMBER DEFAULT NULL,
    run_count          NUMBER DEFAULT NULL,
    failure_count      NUMBER DEFAULT NULL,
    retry_count        NUMBER DEFAULT NULL,
    spare1             NUMBER DEFAULT NULL,
    spare2             NUMBER DEFAULT NULL,
    spare3             VARCHAR2 DEFAULT NULL,
    spare4             VARCHAR2 DEFAULT NULL,
    spare5             TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    spare6             TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    spare7             RAW DEFAULT NULL,
    spare8             RAW DEFAULT NULL)
    RETURN SELF AS RESULT
);
/

create or replace type body sys.scheduler$_event_info as
  CONSTRUCTOR FUNCTION scheduler$_event_info (
    event_type         VARCHAR2,
    object_owner       VARCHAR2,
    object_name        VARCHAR2,
    event_timestamp    TIMESTAMP WITH TIME ZONE DEFAULT SYSTIMESTAMP,
    error_code         NUMBER DEFAULT NULL,
    error_msg          VARCHAR2 DEFAULT NULL,
    event_status       NUMBER DEFAULT NULL,
    log_id             NUMBER DEFAULT NULL,
    run_count          NUMBER DEFAULT NULL,
    failure_count      NUMBER DEFAULT NULL,
    retry_count        NUMBER DEFAULT NULL,
    spare1             NUMBER DEFAULT NULL,
    spare2             NUMBER DEFAULT NULL,
    spare3             VARCHAR2 DEFAULT NULL,
    spare4             VARCHAR2 DEFAULT NULL,
    spare5             TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    spare6             TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    spare7             RAW DEFAULT NULL,
    spare8             RAW DEFAULT NULL)
    RETURN SELF AS RESULT
  AS
  BEGIN
    SELF.event_type  := event_type;
    SELF.object_owner := object_owner;
    SELF.object_name := object_name;
    SELF.event_timestamp := event_timestamp;
    SELF.error_code := error_code;
    SELF.error_msg := error_msg;
    SELF.event_status := event_status;
    SELF.log_id := log_id;
    SELF.run_count := run_count;
    SELF.failure_count := failure_count;
    SELF.retry_count := retry_count;
    SELF.spare1 := spare1;
    SELF.spare2 := spare2;
    SELF.spare3 := spare3;
    SELF.spare4 := spare4;
    SELF.spare5 := spare5;
    SELF.spare6 := spare6;
    SELF.spare7 := spare7;
    SELF.spare8 := spare8;
    RETURN;
  END;
END;
/

grant execute on sys.scheduler$_event_info to public;

create sequence sys.scheduler$_evtseq
/

begin
  dbms_aqadm.create_queue_table
    (queue_table => 'scheduler$_event_qtab',
     queue_payload_type => 'sys.scheduler$_event_info',
     multiple_consumers => true,
     comment => 'Scheduler event queue table',
     secure => true);
exception
  when others then
    if sqlcode = -24001 then NULL;
    else raise;
    end if;
end;
/

begin
  dbms_aqadm.create_queue
    (queue_name => 'scheduler$_event_queue',
     queue_table => 'scheduler$_event_qtab',
     retention_time => 3600,
     comment => 'Scheduler event queue');
exception
  when others then
    if sqlcode = -24006 then NULL;
    else raise;
    end if;
end;
/

begin
  dbms_aqadm.start_queue(queue_name => 'scheduler$_event_queue');
end;
/

begin
  dbms_aqadm.grant_queue_privilege('DEQUEUE', 'SYS.SCHEDULER$_EVENT_QUEUE',
                                   'PUBLIC');
end;
/

/*************************************************************
 * Calendar types and constants
 *************************************************************
 */

CREATE OR REPLACE TYPE scheduler$_int_array_type IS VARRAY (1000) OF INTEGER
/

GRANT EXECUTE ON scheduler$_int_array_type TO public
/

@@dbmssch.sql

/* Create Dictionary Views for Scheduler */

CREATE OR REPLACE VIEW dba_scheduler_programs
  (OWNER, PROGRAM_NAME, PROGRAM_TYPE, PROGRAM_ACTION, NUMBER_OF_ARGUMENTS,
   ENABLED, DETACHED, COMMENTS) AS
  SELECT u.name, o.name,
  DECODE(bitand(p.flags,2+4+8+16+32), 2,'PLSQL_BLOCK',
         4,'STORED_PROCEDURE', 32, 'EXECUTABLE', ''),
  p.action, p.number_of_args, DECODE(BITAND(p.flags,1),0,'FALSE',1,'TRUE'),
  DECODE(BITAND(p.flags,256),0,'FALSE','TRUE'),
  p.comments
  FROM obj$ o, user$ u, sys.scheduler$_program p
  WHERE p.obj# = o.obj# AND u.user# = o.owner#
/
COMMENT ON TABLE dba_scheduler_programs IS
'All scheduler programs in the database'
/
COMMENT ON COLUMN dba_scheduler_programs.program_name IS
'Name of the scheduler program'
/
COMMENT ON COLUMN dba_scheduler_programs.owner IS
'Owner of the scheduler program'
/
COMMENT ON COLUMN dba_scheduler_programs.program_action IS
'String specifying the program action'
/
COMMENT ON COLUMN dba_scheduler_programs.program_type IS
'Type of program action'
/
COMMENT ON COLUMN dba_scheduler_programs.comments IS
'Comments on the program'
/
COMMENT ON COLUMN dba_scheduler_programs.number_of_arguments IS
'Number of arguments accepted by the program'
/
COMMENT ON COLUMN dba_scheduler_programs.enabled IS
'Whether the program is enabled'
/
COMMENT ON COLUMN dba_scheduler_programs.detached IS
'This column is for internal use'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_scheduler_programs
  FOR dba_scheduler_programs
/
GRANT SELECT ON dba_scheduler_programs TO select_catalog_role
/

CREATE OR REPLACE VIEW user_scheduler_programs
  (PROGRAM_NAME, PROGRAM_TYPE, PROGRAM_ACTION, NUMBER_OF_ARGUMENTS,
   ENABLED, DETACHED, COMMENTS) AS
  SELECT po.name,
  DECODE(bitand(p.flags,2+4+8+16+32), 2,'PLSQL_BLOCK',
         4,'STORED_PROCEDURE', 32, 'EXECUTABLE', ''),
  p.action, p.number_of_args, DECODE(BITAND(p.flags,1),0,'FALSE',1,'TRUE'),
  DECODE(BITAND(p.flags,256),0,'FALSE','TRUE'),
  p.comments
  FROM obj$ po, sys.scheduler$_program p
  WHERE po.owner# = USERENV('SCHEMAID') AND p.obj# = po.obj#
/
COMMENT ON TABLE user_scheduler_programs IS
'Scheduler programs owned by the current user'
/
COMMENT ON COLUMN user_scheduler_programs.program_name IS
'Name of the scheduler program'
/
COMMENT ON COLUMN user_scheduler_programs.program_action IS
'String specifying the program action'
/
COMMENT ON COLUMN user_scheduler_programs.program_type IS
'Type of program action'
/
COMMENT ON COLUMN user_scheduler_programs.comments IS
'Comments on the program'
/
COMMENT ON COLUMN user_scheduler_programs.number_of_arguments IS
'Number of arguments accepted by the program'
/
COMMENT ON COLUMN user_scheduler_programs.enabled IS
'Whether the program is enabled'
/
COMMENT ON COLUMN user_scheduler_programs.detached IS
'This column is for internal use'
/
CREATE OR REPLACE PUBLIC SYNONYM user_scheduler_programs
  FOR user_scheduler_programs
/
GRANT SELECT ON user_scheduler_programs TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW all_scheduler_programs
  (OWNER, PROGRAM_NAME, PROGRAM_TYPE, PROGRAM_ACTION, NUMBER_OF_ARGUMENTS,
   ENABLED, DETACHED, COMMENTS) AS
  SELECT u.name, o.name,
  DECODE(bitand(p.flags,2+4+8+16+32), 2,'PLSQL_BLOCK',
         4,'STORED_PROCEDURE', 32, 'EXECUTABLE', ''),
  p.action, p.number_of_args, DECODE(BITAND(p.flags,1),0,'FALSE',1,'TRUE'),
  DECODE(BITAND(p.flags,256),0,'FALSE','TRUE'),
  p.comments
  FROM obj$ o, user$ u, sys.scheduler$_program p
  WHERE p.obj# = o.obj# AND u.user# = o.owner# AND
    (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         (exists (select null from v$enabledprivs
                 where priv_number in (-265 /* CREATE ANY JOB */,
                                       -266 /* EXECUTE ANY PROGRAM */ )
                 )
          and o.owner#!=0)
      )
/
COMMENT ON TABLE all_scheduler_programs IS
'All scheduler programs visible to the user'
/
COMMENT ON COLUMN all_scheduler_programs.program_name IS
'Name of the scheduler program'
/
COMMENT ON COLUMN all_scheduler_programs.owner IS
'Owner of the scheduler program'
/
COMMENT ON COLUMN all_scheduler_programs.program_action IS
'String specifying the program action'
/
COMMENT ON COLUMN all_scheduler_programs.program_type IS
'Type of program action'
/
COMMENT ON COLUMN all_scheduler_programs.comments IS
'Comments on the program'
/
COMMENT ON COLUMN all_scheduler_programs.number_of_arguments IS
'Number of arguments accepted by the program'
/
COMMENT ON COLUMN all_scheduler_programs.enabled IS
'Whether the program is enabled'
/
COMMENT ON COLUMN all_scheduler_programs.detached IS
'This column is for internal use'
/
CREATE OR REPLACE PUBLIC SYNONYM all_scheduler_programs
  FOR all_scheduler_programs
/
GRANT SELECT ON all_scheduler_programs TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW dba_scheduler_jobs
  ( OWNER, JOB_NAME, JOB_SUBNAME, JOB_CREATOR, CLIENT_ID, GLOBAL_UID, 
    PROGRAM_OWNER, PROGRAM_NAME, JOB_TYPE, 
    JOB_ACTION, NUMBER_OF_ARGUMENTS, SCHEDULE_OWNER, SCHEDULE_NAME,
    SCHEDULE_TYPE, START_DATE, REPEAT_INTERVAL, EVENT_QUEUE_OWNER, 
    EVENT_QUEUE_NAME, EVENT_QUEUE_AGENT, EVENT_CONDITION, EVENT_RULE, END_DATE,
    JOB_CLASS, ENABLED, AUTO_DROP, RESTARTABLE, STATE, JOB_PRIORITY,
    RUN_COUNT, MAX_RUNS, FAILURE_COUNT, MAX_FAILURES, RETRY_COUNT,
    LAST_START_DATE,
    LAST_RUN_DURATION, NEXT_RUN_DATE, SCHEDULE_LIMIT, MAX_RUN_DURATION,
    LOGGING_LEVEL, STOP_ON_WINDOW_CLOSE, INSTANCE_STICKINESS, RAISE_EVENTS, SYSTEM,
    JOB_WEIGHT, NLS_ENV, SOURCE, DESTINATION, COMMENTS, FLAGS )
  AS SELECT ju.name, jo.name, jo.subname,
    j.creator, j.client_id, j.guid,
    DECODE(bitand(j.flags,4194304),4194304,
      substr(j.program_action,1,instr(j.program_action,'"')-1),NULL),
    DECODE(bitand(j.flags,4194304),4194304,
      substr(j.program_action,instr(j.program_action,'"')+1,
        length(j.program_action)-instr(j.program_action,'"')) ,NULL),
    DECODE(BITAND(j.flags,131072+262144+2097152+524288),
      131072, 'PLSQL_BLOCK', 262144, 'STORED_PROCEDURE',
      2097152, 'EXECUTABLE', 524288, 'CHAIN', NULL),
    DECODE(bitand(j.flags,4194304),0,j.program_action,NULL), j.number_of_args,
    DECODE(bitand(j.flags,1024+4096),0,NULL,
      substr(j.schedule_expr,1,instr(j.schedule_expr,'"')-1)),
    DECODE(bitand(j.flags,1024+4096),0,NULL,
      substr(j.schedule_expr,instr(j.schedule_expr,'"') + 1,
        length(j.schedule_expr)-instr(j.schedule_expr,'"'))),
    DECODE(BITAND(j.flags, 1+2+512+1024+2048+4096+8192+16384+134217728), 
      512,'PLSQL',1024,'NAMED',2048,'CALENDAR',4096,'WINDOW',4098,'WINDOW_GROUP',
      8192,'ONCE',16384,'IMMEDIATE',134217728,'EVENT',NULL),
    j.start_date,
    DECODE(BITAND(j.flags,1024+4096+134217728), 0, j.schedule_expr, NULL),
    j.queue_owner, j.queue_name, j.queue_agent, 
    DECODE(BITAND(j.flags,134217728), 0, NULL, 
      DECODE(BITAND(j.flags,1024+4096), 0, j.schedule_expr, NULL)),
    j.event_rule,
    j.end_date, co.name,
    DECODE(BITAND(j.job_status,1),0,'FALSE','TRUE'),
    DECODE(BITAND(j.flags,32768),0,'TRUE','FALSE'),
    DECODE(BITAND(j.flags,65536),0,'FALSE','TRUE'),
    DECODE(BITAND(j.job_status,2+65536),2,'RUNNING',2+65536,'CHAIN_STALLED',
    DECODE(BITAND(j.job_status,1+4+8+16+32+128+8192),0,'DISABLED',1,
      (CASE WHEN j.retry_count>0 THEN 'RETRY SCHEDULED' ELSE 'SCHEDULED' END),
      4,'COMPLETED',8,'BROKEN',16,'FAILED',
      32,'SUCCEEDED' ,128,'REMOTE',8192, 'STOPPED', NULL)),
    j.priority, j.run_count, j.max_runs, j.failure_count, j.max_failures,
    j.retry_count,
    j.last_start_date,
    (CASE WHEN j.last_end_date>j.last_start_date THEN j.last_end_date-j.last_start_date
       ELSE NULL END), j.next_run_date,
    j.schedule_limit, j.max_run_duration,
    DECODE(BITAND(j.flags,32+64+128+256),32,'OFF',64,'RUNS',128,'',
      256,'FULL',NULL),
    DECODE(BITAND(j.flags,8),0,'FALSE','TRUE'),
    DECODE(BITAND(j.flags,16),0,'FALSE','TRUE'),
    /* BITAND(j.job_status, 16711680)/65536, */
    sys.dbms_scheduler.generate_event_list(j.job_status),
    DECODE(BITAND(j.flags,16777216),0,'FALSE','TRUE'),
    j.job_weight, j.nls_env,
    j.source, j.destination, j.comments, j.flags
  FROM obj$ jo, user$ ju, obj$ co, sys.scheduler$_job j
  WHERE j.obj# = jo.obj# AND jo.owner# = ju.user# AND j.class_oid = co.obj#(+)
/
COMMENT ON TABLE dba_scheduler_jobs IS
'All scheduler jobs in the database'
/
COMMENT ON COLUMN dba_scheduler_jobs.owner IS
'Owner of the scheduler job'
/
COMMENT ON COLUMN dba_scheduler_jobs.job_name IS
'Name of the scheduler job'
/
COMMENT ON COLUMN dba_scheduler_jobs.job_subname IS
'Subname of the scheduler job (for a job running a chain step)'
/
COMMENT ON COLUMN dba_scheduler_jobs.program_name IS
'Name of the program associated with the job'
/
COMMENT ON COLUMN dba_scheduler_jobs.program_owner IS
'Owner of the program associated with the job'
/
COMMENT ON COLUMN dba_scheduler_jobs.job_action IS
'Inlined job action'
/
COMMENT ON COLUMN dba_scheduler_jobs.job_type IS
'Inlined job action type'
/
COMMENT ON COLUMN dba_scheduler_jobs.number_of_arguments IS
'Inlined job number of arguments'
/
COMMENT ON COLUMN dba_scheduler_jobs.schedule_name IS
'Name of the schedule that this job uses (can be a window or window group)'
/
COMMENT ON COLUMN dba_scheduler_jobs.schedule_type IS
'Type of the schedule that this job uses'
/
COMMENT ON COLUMN dba_scheduler_jobs.schedule_owner IS
'Owner of the schedule that this job uses (can be a window or window group)'
/
COMMENT ON COLUMN dba_scheduler_jobs.repeat_interval IS
'Inlined schedule PL/SQL expression or calendar string'
/
COMMENT ON COLUMN dba_scheduler_jobs.event_queue_owner IS
'Owner of source queue into which event will be raised'
/
COMMENT ON COLUMN dba_scheduler_jobs.event_queue_name IS
'Name of source queue into which event will be raised'
/
COMMENT ON COLUMN dba_scheduler_jobs.event_queue_agent IS
'Name of AQ agent used by user on the event source queue (if it is a secure queue)'
/
COMMENT ON COLUMN dba_scheduler_jobs.event_condition IS
'Boolean expression used as subscription rule for event on the source queue'
/
COMMENT ON COLUMN dba_scheduler_jobs.event_rule IS
'Name of rule used by the coordinator to trigger event based job'
/
COMMENT ON COLUMN dba_scheduler_jobs.start_date IS
'Original scheduled start date of this job (for an inlined schedule)'
/
COMMENT ON COLUMN dba_scheduler_jobs.end_date IS
'Date after which this job will no longer run (for an inlined schedule)'
/
COMMENT ON COLUMN dba_scheduler_jobs.schedule_limit IS
'Time in minutes after which a job which has not run yet will be rescheduled'
/
COMMENT ON COLUMN dba_scheduler_jobs.next_run_date IS
'Next date the job is scheduled to run on'
/
COMMENT ON COLUMN dba_scheduler_jobs.job_class IS
'Name of job class associated with the job'
/
COMMENT ON COLUMN dba_scheduler_jobs.comments IS
'Comments on the job'
/
COMMENT ON COLUMN dba_scheduler_jobs.job_priority IS
'Priority of the job relative to others within the same class'
/
COMMENT ON COLUMN dba_scheduler_jobs.state IS
'Current state of the job'
/
COMMENT ON COLUMN dba_scheduler_jobs.enabled IS
'Whether the job is enabled'
/
COMMENT ON COLUMN dba_scheduler_jobs.max_run_duration IS
'This column is reserved for future use'
/
COMMENT ON COLUMN dba_scheduler_jobs.last_start_date IS
'Last date on which the job started running'
/
COMMENT ON COLUMN dba_scheduler_jobs.last_run_duration IS
'How long the job took last time'
/
COMMENT ON COLUMN dba_scheduler_jobs.run_count IS
'Number of times this job has run'
/
COMMENT ON COLUMN dba_scheduler_jobs.failure_count IS
'Number of times this job has failed to run'
/
COMMENT ON COLUMN dba_scheduler_jobs.max_runs IS
'Maximum number of times this job is scheduled to run'
/
COMMENT ON COLUMN dba_scheduler_jobs.max_failures IS
'Number of times this job will be allowed to fail before being marked broken'
/
COMMENT ON COLUMN dba_scheduler_jobs.retry_count IS
'Number of times this job has retried, if it is retrying.'
/
COMMENT ON COLUMN dba_scheduler_jobs.logging_level IS
'Amount of logging that will be done pertaining to this job'
/
COMMENT ON COLUMN dba_scheduler_jobs.job_weight IS
'Weight of this job'
/
COMMENT ON COLUMN dba_scheduler_jobs.instance_stickiness IS
'Whether this job is sticky'
/
COMMENT ON COLUMN dba_scheduler_jobs.stop_on_window_close IS
'Whether this job will stop if a window it is associated with closes'
/
COMMENT ON COLUMN dba_scheduler_jobs.raise_events IS
'List of job events to raise for this job'
/
COMMENT ON COLUMN dba_scheduler_jobs.system IS
'Whether this is a system job'
/
COMMENT ON COLUMN dba_scheduler_jobs.job_creator IS
'Original creator of this job'
/
COMMENT ON COLUMN dba_scheduler_jobs.client_id IS
'Client id of user creating job'
/
COMMENT ON COLUMN dba_scheduler_jobs.global_uid IS
'Global uid of user creating this job'
/
COMMENT ON COLUMN dba_scheduler_jobs.nls_env IS
'NLS environment of this job'
/
COMMENT ON COLUMN dba_scheduler_jobs.auto_drop IS
'Whether this job will be dropped when it has completed'
/
COMMENT ON COLUMN dba_scheduler_jobs.restartable IS
'Whether this job can be restarted or not'
/
COMMENT ON COLUMN dba_scheduler_jobs.source IS
'Source global database identifier'
/
COMMENT ON COLUMN dba_scheduler_jobs.destination IS
'Destination global database identifier'
/
COMMENT ON COLUMN dba_scheduler_jobs.flags IS
'This column is for internal use.'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_scheduler_jobs
  FOR dba_scheduler_jobs
/
GRANT SELECT ON dba_scheduler_jobs TO select_catalog_role
/

CREATE OR REPLACE VIEW user_scheduler_jobs
  ( JOB_NAME, JOB_SUBNAME, JOB_CREATOR, CLIENT_ID, GLOBAL_UID, 
    PROGRAM_OWNER, PROGRAM_NAME, JOB_TYPE, 
    JOB_ACTION, NUMBER_OF_ARGUMENTS, SCHEDULE_OWNER, SCHEDULE_NAME,
    SCHEDULE_TYPE, START_DATE, REPEAT_INTERVAL, EVENT_QUEUE_OWNER, 
    EVENT_QUEUE_NAME, EVENT_QUEUE_AGENT, EVENT_CONDITION, EVENT_RULE, END_DATE,
    JOB_CLASS, ENABLED, AUTO_DROP, RESTARTABLE, STATE, JOB_PRIORITY,
    RUN_COUNT, MAX_RUNS, FAILURE_COUNT, MAX_FAILURES, RETRY_COUNT,
    LAST_START_DATE,
    LAST_RUN_DURATION, NEXT_RUN_DATE, SCHEDULE_LIMIT, MAX_RUN_DURATION,
    LOGGING_LEVEL, STOP_ON_WINDOW_CLOSE, INSTANCE_STICKINESS, RAISE_EVENTS, SYSTEM,
    JOB_WEIGHT, NLS_ENV, SOURCE, DESTINATION, COMMENTS, FLAGS )
  AS SELECT jo.name, jo.subname, j.creator, j.client_id, j.guid,
    DECODE(bitand(j.flags,4194304),4194304,
      substr(j.program_action,1,instr(j.program_action,'"')-1),NULL),
    DECODE(bitand(j.flags,4194304),4194304,
      substr(j.program_action,instr(j.program_action,'"')+1,
        length(j.program_action)-instr(j.program_action,'"')) ,NULL),
    DECODE(BITAND(j.flags,131072+262144+2097152+524288),
      131072, 'PLSQL_BLOCK', 262144, 'STORED_PROCEDURE',
      2097152, 'EXECUTABLE', 524288, 'CHAIN', NULL),
    DECODE(bitand(j.flags,4194304),0,j.program_action,NULL), j.number_of_args,
    DECODE(bitand(j.flags,1024+4096),0,NULL,
      substr(j.schedule_expr,1,instr(j.schedule_expr,'"')-1)),
    DECODE(bitand(j.flags,1024+4096),0,NULL,
      substr(j.schedule_expr,instr(j.schedule_expr,'"') + 1,
        length(j.schedule_expr)-instr(j.schedule_expr,'"'))),
    DECODE(BITAND(j.flags, 1+2+512+1024+2048+4096+8192+16384+134217728), 
      512,'PLSQL',1024,'NAMED',2048,'CALENDAR',4096,'WINDOW',4098,'WINDOW_GROUP',
      8192,'ONCE',16384,'IMMEDIATE',134217728,'EVENT',NULL),
    j.start_date,
    DECODE(BITAND(j.flags,1024+4096+134217728), 0, j.schedule_expr, NULL),
    j.queue_owner, j.queue_name, j.queue_agent, 
    DECODE(BITAND(j.flags,134217728), 0, NULL, 
      DECODE(BITAND(j.flags,1024+4096), 0, j.schedule_expr, NULL)),
    j.event_rule,
    j.end_date, co.name,
    DECODE(BITAND(j.job_status,1),0,'FALSE','TRUE'),
    DECODE(BITAND(j.flags,32768),0,'TRUE','FALSE'),
    DECODE(BITAND(j.flags,65536),0,'FALSE','TRUE'),
    DECODE(BITAND(j.job_status,2+65536),2,'RUNNING',2+65536,'CHAIN_STALLED',
    DECODE(BITAND(j.job_status,1+4+8+16+32+128+8192),0,'DISABLED',1,
      (CASE WHEN j.retry_count>0 THEN 'RETRY SCHEDULED' ELSE 'SCHEDULED' END),
      4,'COMPLETED',8,'BROKEN',16,'FAILED',
      32,'SUCCEEDED' ,128,'REMOTE',8192, 'STOPPED', NULL)),
    j.priority, j.run_count, j.max_runs, j.failure_count, j.max_failures,
    j.retry_count,
    j.last_start_date,
    (CASE WHEN j.last_end_date>j.last_start_date THEN j.last_end_date-j.last_start_date
       ELSE NULL END), j.next_run_date,
    j.schedule_limit, j.max_run_duration,
    DECODE(BITAND(j.flags,32+64+128+256),32,'OFF',64,'RUNS',128,'',
      256,'FULL',NULL),
    DECODE(BITAND(j.flags,8),0,'FALSE','TRUE'),
    DECODE(BITAND(j.flags,16),0,'FALSE','TRUE'), 
    sys.dbms_scheduler.generate_event_list(j.job_status),
    DECODE(BITAND(j.flags,16777216),0,'FALSE','TRUE'),
    j.job_weight, j.nls_env,
    j.source, j.destination, j.comments, j.flags
  FROM sys.scheduler$_job j, obj$ jo, obj$ co
  WHERE j.obj# = jo.obj# AND
    j.class_oid = co.obj#(+) AND jo.owner# = USERENV('SCHEMAID')
/
COMMENT ON TABLE user_scheduler_jobs IS
'All scheduler jobs in the database'
/
COMMENT ON COLUMN user_scheduler_jobs.job_name IS
'Name of the scheduler job'
/
COMMENT ON COLUMN user_scheduler_jobs.job_subname IS
'Subname of the scheduler job (for a job running a chain step)'
/
COMMENT ON COLUMN user_scheduler_jobs.program_name IS
'Name of the program associated with the job'
/
COMMENT ON COLUMN user_scheduler_jobs.program_owner IS
'Owner of the program associated with the job'
/
COMMENT ON COLUMN user_scheduler_jobs.job_action IS
'Inlined job action'
/
COMMENT ON COLUMN user_scheduler_jobs.job_type IS
'Inlined job action type'
/
COMMENT ON COLUMN user_scheduler_jobs.number_of_arguments IS
'Inlined job number of arguments'
/
COMMENT ON COLUMN user_scheduler_jobs.schedule_name IS
'Name of the schedule that this job uses (can be a window or window group)'
/
COMMENT ON COLUMN user_scheduler_jobs.schedule_type IS
'Type of the schedule that this job uses'
/
COMMENT ON COLUMN user_scheduler_jobs.schedule_owner IS
'Owner of the schedule that this job uses (can be a window or window group)'
/
COMMENT ON COLUMN user_scheduler_jobs.repeat_interval IS
'Inlined schedule PL/SQL expression or calendar string'
/
COMMENT ON COLUMN user_scheduler_jobs.event_queue_owner IS
'Owner of source queue into which event will be raised'
/
COMMENT ON COLUMN user_scheduler_jobs.event_queue_name IS
'Name of source queue into which event will be raised'
/
COMMENT ON COLUMN user_scheduler_jobs.event_queue_agent IS
'Name of AQ agent used by user on the event source queue (if it is a secure queue)'
/
COMMENT ON COLUMN user_scheduler_jobs.event_condition IS
'Boolean expression used as subscription rule for event on the source queue'
/
COMMENT ON COLUMN user_scheduler_jobs.event_rule IS
'Name of rule used by the coordinator to trigger event based job'
/
COMMENT ON COLUMN user_scheduler_jobs.start_date IS
'Original scheduled start date of this job (for an inlined schedule)'
/
COMMENT ON COLUMN user_scheduler_jobs.end_date IS
'Date after which this job will no longer run (for an inlined schedule)'
/
COMMENT ON COLUMN user_scheduler_jobs.schedule_limit IS
'Time in minutes after which a job which has not run yet will be rescheduled'
/
COMMENT ON COLUMN user_scheduler_jobs.next_run_date IS
'Next date the job is scheduled to run on'
/
COMMENT ON COLUMN user_scheduler_jobs.job_class IS
'Name of job class associated with the job'
/
COMMENT ON COLUMN user_scheduler_jobs.comments IS
'Comments on the job'
/
COMMENT ON COLUMN user_scheduler_jobs.job_priority IS
'Priority of the job relative to others within the same class'
/
COMMENT ON COLUMN user_scheduler_jobs.state IS
'Current state of the job'
/
COMMENT ON COLUMN user_scheduler_jobs.enabled IS
'Whether the job is enabled'
/
COMMENT ON COLUMN user_scheduler_jobs.max_run_duration IS
'This column is reserved for future use'
/
COMMENT ON COLUMN user_scheduler_jobs.last_start_date IS
'Last date on which the job started running'
/
COMMENT ON COLUMN user_scheduler_jobs.last_run_duration IS
'How long the job took last time'
/
COMMENT ON COLUMN user_scheduler_jobs.run_count IS
'Number of times this job has run'
/
COMMENT ON COLUMN user_scheduler_jobs.failure_count IS
'Number of times this job has failed to run'
/
COMMENT ON COLUMN user_scheduler_jobs.max_runs IS
'Maximum number of times this job is scheduled to run'
/
COMMENT ON COLUMN user_scheduler_jobs.max_failures IS
'Number of times this job will be allowed to fail before being marked broken'
/
COMMENT ON COLUMN user_scheduler_jobs.retry_count IS
'Number of times this job has retried, if it is retrying.'
/
COMMENT ON COLUMN user_scheduler_jobs.logging_level IS
'Amount of logging that will be done pertaining to this job'
/
COMMENT ON COLUMN user_scheduler_jobs.job_weight IS
'Weight of this job'
/
COMMENT ON COLUMN user_scheduler_jobs.instance_stickiness IS
'Whether this job is sticky'
/
COMMENT ON COLUMN user_scheduler_jobs.stop_on_window_close IS
'Whether this job will stop if a window it is associated with closes'
/
COMMENT ON COLUMN user_scheduler_jobs.raise_events IS
'List of job events to raise for this job'
/
COMMENT ON COLUMN user_scheduler_jobs.system IS
'Whether this is a system job'
/
COMMENT ON COLUMN user_scheduler_jobs.job_creator IS
'Original creator of this job'
/
COMMENT ON COLUMN user_scheduler_jobs.client_id IS
'Client id of user creating this job'
/
COMMENT ON COLUMN user_scheduler_jobs.global_uid IS
'Global uid of user creating this job'
/
COMMENT ON COLUMN user_scheduler_jobs.nls_env IS
'NLS environment of this job'
/
COMMENT ON COLUMN user_scheduler_jobs.auto_drop IS
'Whether this job will be dropped when it has completed'
/
COMMENT ON COLUMN user_scheduler_jobs.restartable IS
'Whether this job can be restarted or not'
/
COMMENT ON COLUMN user_scheduler_jobs.source IS
'Source global database identifier'
/
COMMENT ON COLUMN user_scheduler_jobs.destination IS
'Destination global database identifier'
/
COMMENT ON COLUMN user_scheduler_jobs.flags IS
'This column is for internal use.'
/
CREATE OR REPLACE PUBLIC SYNONYM user_scheduler_jobs
  FOR user_scheduler_jobs
/
GRANT SELECT ON user_scheduler_jobs TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW all_scheduler_jobs
  ( OWNER, JOB_NAME, JOB_SUBNAME, JOB_CREATOR, CLIENT_ID, GLOBAL_UID, 
    PROGRAM_OWNER, PROGRAM_NAME, JOB_TYPE, 
    JOB_ACTION, NUMBER_OF_ARGUMENTS, SCHEDULE_OWNER, SCHEDULE_NAME,
    SCHEDULE_TYPE, START_DATE, REPEAT_INTERVAL, EVENT_QUEUE_OWNER, 
    EVENT_QUEUE_NAME, EVENT_QUEUE_AGENT, EVENT_CONDITION, EVENT_RULE, END_DATE,
    JOB_CLASS, ENABLED, AUTO_DROP, RESTARTABLE, STATE, JOB_PRIORITY,
    RUN_COUNT, MAX_RUNS, FAILURE_COUNT, MAX_FAILURES, RETRY_COUNT,
    LAST_START_DATE,
    LAST_RUN_DURATION, NEXT_RUN_DATE, SCHEDULE_LIMIT, MAX_RUN_DURATION,
    LOGGING_LEVEL, STOP_ON_WINDOW_CLOSE, INSTANCE_STICKINESS, RAISE_EVENTS, SYSTEM,
    JOB_WEIGHT, NLS_ENV, SOURCE, DESTINATION, COMMENTS, FLAGS )
  AS SELECT ju.name, jo.name, jo.subname, j.creator, j.client_id, j.guid,
    DECODE(bitand(j.flags,4194304),4194304,
      substr(j.program_action,1,instr(j.program_action,'"')-1),NULL),
    DECODE(bitand(j.flags,4194304),4194304,
      substr(j.program_action,instr(j.program_action,'"')+1,
        length(j.program_action)-instr(j.program_action,'"')) ,NULL),
    DECODE(BITAND(j.flags,131072+262144+2097152+524288),
      131072, 'PLSQL_BLOCK', 262144, 'STORED_PROCEDURE',
      2097152, 'EXECUTABLE', 524288, 'CHAIN', NULL),
    DECODE(bitand(j.flags,4194304),0,j.program_action,NULL), j.number_of_args,
    DECODE(bitand(j.flags,1024+4096),0,NULL,
      substr(j.schedule_expr,1,instr(j.schedule_expr,'"')-1)),
    DECODE(bitand(j.flags,1024+4096),0,NULL,
      substr(j.schedule_expr,instr(j.schedule_expr,'"') + 1,
        length(j.schedule_expr)-instr(j.schedule_expr,'"'))),
    DECODE(BITAND(j.flags, 1+2+512+1024+2048+4096+8192+16384+134217728), 
      512,'PLSQL',1024,'NAMED',2048,'CALENDAR',4096,'WINDOW',4098,'WINDOW_GROUP',
      8192,'ONCE',16384,'IMMEDIATE',134217728,'EVENT',NULL),
    j.start_date,
    DECODE(BITAND(j.flags,1024+4096+134217728), 0, j.schedule_expr, NULL),
    j.queue_owner, j.queue_name, j.queue_agent, 
    DECODE(BITAND(j.flags,134217728), 0, NULL, 
      DECODE(BITAND(j.flags,1024+4096), 0, j.schedule_expr, NULL)),
    j.event_rule,
    j.end_date, co.name,
    DECODE(BITAND(j.job_status,1),0,'FALSE','TRUE'),
    DECODE(BITAND(j.flags,32768),0,'TRUE','FALSE'),
    DECODE(BITAND(j.flags,65536),0,'FALSE','TRUE'),
    DECODE(BITAND(j.job_status,2+65536),2,'RUNNING',2+65536,'CHAIN_STALLED',
    DECODE(BITAND(j.job_status,1+4+8+16+32+128+8192),0,'DISABLED',1,
      (CASE WHEN j.retry_count>0 THEN 'RETRY SCHEDULED' ELSE 'SCHEDULED' END),
      4,'COMPLETED',8,'BROKEN',16,'FAILED',
      32,'SUCCEEDED' ,128,'REMOTE',8192, 'STOPPED', NULL)),
    j.priority, j.run_count, j.max_runs, j.failure_count, j.max_failures,
    j.retry_count,
    j.last_start_date,
    (CASE WHEN j.last_end_date>j.last_start_date THEN j.last_end_date-j.last_start_date
       ELSE NULL END), j.next_run_date,
    j.schedule_limit, j.max_run_duration,
    DECODE(BITAND(j.flags,32+64+128+256),32,'OFF',64,'RUNS',128,'',
      256,'FULL',NULL),
    DECODE(BITAND(j.flags,8),0,'FALSE','TRUE'),
    DECODE(BITAND(j.flags,16),0,'FALSE','TRUE'), 
    sys.dbms_scheduler.generate_event_list(j.job_status),
    DECODE(BITAND(j.flags,16777216),0,'FALSE','TRUE'),
    j.job_weight, j.nls_env,
    j.source, j.destination, j.comments, j.flags
  FROM obj$ jo, user$ ju, sys.scheduler$_job j, obj$ co
  WHERE j.obj# = jo.obj# AND jo.owner# = ju.user# AND
    j.class_oid = co.obj#(+) AND
    (jo.owner# = userenv('SCHEMAID')
       or jo.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         (exists (select null from v$enabledprivs
                 where priv_number = -265 /* CREATE ANY JOB */
                 )
          and jo.owner#!=0)
       )
/
COMMENT ON TABLE all_scheduler_jobs IS
'All scheduler jobs visible to the user'
/
COMMENT ON COLUMN all_scheduler_jobs.owner IS
'Owner of the scheduler job'
/
COMMENT ON COLUMN all_scheduler_jobs.job_name IS
'Name of the scheduler job'
/
COMMENT ON COLUMN all_scheduler_jobs.job_subname IS
'Subname of the scheduler job (for a job running a chain step)'
/
COMMENT ON COLUMN all_scheduler_jobs.program_name IS
'Name of the program associated with the job'
/
COMMENT ON COLUMN all_scheduler_jobs.program_owner IS
'Owner of the program associated with the job'
/
COMMENT ON COLUMN all_scheduler_jobs.job_action IS
'Inlined job action'
/
COMMENT ON COLUMN all_scheduler_jobs.job_type IS
'Inlined job action type'
/
COMMENT ON COLUMN all_scheduler_jobs.number_of_arguments IS
'Inlined job number of arguments'
/
COMMENT ON COLUMN all_scheduler_jobs.schedule_name IS
'Name of the schedule that this job uses (can be a window or window group)'
/
COMMENT ON COLUMN all_scheduler_jobs.schedule_type IS
'Type of the schedule that this job uses'
/
COMMENT ON COLUMN all_scheduler_jobs.schedule_owner IS
'Owner of the schedule that this job uses (can be a window or window group)'
/
COMMENT ON COLUMN all_scheduler_jobs.repeat_interval IS
'Inlined schedule PL/SQL expression or calendar string'
/
COMMENT ON COLUMN all_scheduler_jobs.event_queue_owner IS
'Owner of source queue into which event will be raised'
/
COMMENT ON COLUMN all_scheduler_jobs.event_queue_name IS
'Name of source queue into which event will be raised'
/
COMMENT ON COLUMN all_scheduler_jobs.event_queue_agent IS
'Name of AQ agent used by user on the event source queue (if it is a secure queue)'
/
COMMENT ON COLUMN all_scheduler_jobs.event_condition IS
'Boolean expression used as subscription rule for event on the source queue'
/
COMMENT ON COLUMN all_scheduler_jobs.event_rule IS
'Name of rule used by the coordinator to trigger event based job'
/
COMMENT ON COLUMN all_scheduler_jobs.start_date IS
'Original scheduled start date of this job (for an inlined schedule)'
/
COMMENT ON COLUMN all_scheduler_jobs.end_date IS
'Date after which this job will no longer run (for an inlined schedule)'
/
COMMENT ON COLUMN all_scheduler_jobs.schedule_limit IS
'Time in minutes after which a job which has not run yet will be rescheduled'
/
COMMENT ON COLUMN all_scheduler_jobs.next_run_date IS
'Next date the job is scheduled to run on'
/
COMMENT ON COLUMN all_scheduler_jobs.job_class IS
'Name of job class associated with the job'
/
COMMENT ON COLUMN all_scheduler_jobs.comments IS
'Comments on the job'
/
COMMENT ON COLUMN all_scheduler_jobs.job_priority IS
'Priority of the job relative to others within the same class'
/
COMMENT ON COLUMN all_scheduler_jobs.state IS
'Current state of the job'
/
COMMENT ON COLUMN all_scheduler_jobs.enabled IS
'Whether the job is enabled'
/
COMMENT ON COLUMN all_scheduler_jobs.max_run_duration IS
'This column is reserved for future use'
/
COMMENT ON COLUMN all_scheduler_jobs.last_start_date IS
'Last date on which the job started running'
/
COMMENT ON COLUMN all_scheduler_jobs.last_run_duration IS
'How long the job took last time'
/
COMMENT ON COLUMN all_scheduler_jobs.run_count IS
'Number of times this job has run'
/
COMMENT ON COLUMN all_scheduler_jobs.failure_count IS
'Number of times this job has failed to run'
/
COMMENT ON COLUMN all_scheduler_jobs.max_runs IS
'Maximum number of times this job is scheduled to run'
/
COMMENT ON COLUMN all_scheduler_jobs.max_failures IS
'Number of times this job will be allowed to fail before being marked broken'
/
COMMENT ON COLUMN all_scheduler_jobs.retry_count IS
'Number of times this job has retried, if it is retrying.'
/
COMMENT ON COLUMN all_scheduler_jobs.logging_level IS
'Amount of logging that will be done pertaining to this job'
/
COMMENT ON COLUMN all_scheduler_jobs.job_weight IS
'Weight of this job'
/
COMMENT ON COLUMN all_scheduler_jobs.instance_stickiness IS
'Whether this job is sticky'
/
COMMENT ON COLUMN all_scheduler_jobs.stop_on_window_close IS
'Whether this job will stop if a window it is associated with closes'
/
COMMENT ON COLUMN all_scheduler_jobs.raise_events IS
'List of job events to raise for this job'
/
COMMENT ON COLUMN all_scheduler_jobs.system IS
'Whether this is a system job'
/
COMMENT ON COLUMN all_scheduler_jobs.job_creator IS
'Original creator of this job'
/
COMMENT ON COLUMN all_scheduler_jobs.client_id IS
'Client id of user creating this job'
/
COMMENT ON COLUMN all_scheduler_jobs.global_uid IS
'Global uid of user creating this job'
/
COMMENT ON COLUMN all_scheduler_jobs.nls_env IS
'NLS environment of this job'
/
COMMENT ON COLUMN all_scheduler_jobs.auto_drop IS
'Whether this job will be dropped when it has completed'
/
COMMENT ON COLUMN all_scheduler_jobs.restartable IS
'Whether this job can be restarted or not'
/
COMMENT ON COLUMN all_scheduler_jobs.source IS
'Source global database identifier'
/
COMMENT ON COLUMN all_scheduler_jobs.destination IS
'Destination global database identifier'
/
COMMENT ON COLUMN all_scheduler_jobs.flags IS
'This column is for internal use.'
/
CREATE OR REPLACE PUBLIC SYNONYM all_scheduler_jobs
  FOR all_scheduler_jobs
/
GRANT SELECT ON all_scheduler_jobs TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW dba_scheduler_job_classes
  ( JOB_CLASS_NAME, RESOURCE_CONSUMER_GROUP,
    SERVICE, LOGGING_LEVEL, LOG_HISTORY, COMMENTS) AS
  SELECT co.name, c.res_grp_name,
    c.affinity ,
    DECODE(BITAND(c.flags,32+64+128+256),32,'OFF',64,'RUNS',128,'',
      256,'FULL',NULL), 
    c.log_history, c.comments
  FROM obj$ co, sys.scheduler$_class c
  WHERE c.obj# = co.obj#
/
COMMENT ON TABLE dba_scheduler_job_classes IS
'All scheduler classes in the database'
/
COMMENT ON COLUMN dba_scheduler_job_classes.job_class_name IS
'Name of the scheduler class'
/
COMMENT ON COLUMN dba_scheduler_job_classes.resource_consumer_group IS
'Resource consumer group associated with the class'
/
COMMENT ON COLUMN dba_scheduler_job_classes.service IS
'Name of the service this class is affined with'
/
COMMENT ON COLUMN dba_scheduler_job_classes.logging_level IS
'Amount of logging that will be done pertaining to this class'
/
COMMENT ON COLUMN dba_scheduler_job_classes.log_history IS
'The history to maintain in the job log (in days) for this class'
/
COMMENT ON COLUMN dba_scheduler_job_classes.comments IS
'Comments on this class'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_scheduler_job_classes
  FOR dba_scheduler_job_classes
/
GRANT SELECT ON dba_scheduler_job_classes TO select_catalog_role
/

CREATE OR REPLACE VIEW all_scheduler_job_classes
  ( JOB_CLASS_NAME, RESOURCE_CONSUMER_GROUP,
    SERVICE, LOGGING_LEVEL, LOG_HISTORY, COMMENTS) AS
  SELECT co.name, c.res_grp_name,
    c.affinity , 
    DECODE(BITAND(c.flags,32+64+128+256),32,'OFF',64,'RUNS',128,'',
      256,'FULL',NULL), 
    c.log_history, c.comments
  FROM obj$ co, sys.scheduler$_class c
  WHERE c.obj# = co.obj# AND
    (co.obj# in
         (select oa.obj#
          from sys.objauth$ oa
          where grantee# in ( select kzsrorol
                              from x$kzsro
                            )
         )
     or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-267, /* EXECUTE ANY CLASS */
                                       -268  /* MANAGE SCHEDULER */ )
                 )
      )
/
COMMENT ON TABLE all_scheduler_job_classes IS
'All scheduler classes visible to the user'
/
COMMENT ON COLUMN all_scheduler_job_classes.job_class_name IS
'Name of the scheduler class'
/
COMMENT ON COLUMN all_scheduler_job_classes.resource_consumer_group IS
'Resource consumer group associated with the class'
/
COMMENT ON COLUMN all_scheduler_job_classes.service IS
'Name of the service this class is affined with'
/
COMMENT ON COLUMN all_scheduler_job_classes.logging_level IS
'Amount of logging that will be done pertaining to this class'
/
COMMENT ON COLUMN all_scheduler_job_classes.log_history IS
'The history to maintain in the job log (in days) for this class'
/
COMMENT ON COLUMN all_scheduler_job_classes.comments IS
'Comments on this class'
/
CREATE OR REPLACE PUBLIC SYNONYM all_scheduler_job_classes
  FOR all_scheduler_job_classes
/
GRANT SELECT ON all_scheduler_job_classes TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW dba_scheduler_windows
  ( WINDOW_NAME, RESOURCE_PLAN, SCHEDULE_OWNER, SCHEDULE_NAME, SCHEDULE_TYPE,
    START_DATE, REPEAT_INTERVAL, END_DATE, DURATION, WINDOW_PRIORITY,
    NEXT_START_DATE, LAST_START_DATE, ENABLED, ACTIVE, 
    MANUAL_OPEN_TIME, MANUAL_DURATION, COMMENTS) AS
  SELECT wo.name, w.res_plan, 
    DECODE(bitand(w.flags,16),16,
      substr(w.schedule_expr,1,instr(w.schedule_expr,'"')-1),NULL),
    DECODE(bitand(w.flags,16),16,
      substr(w.schedule_expr,instr(w.schedule_expr,'"')+1,
        length(w.schedule_expr)-instr(w.schedule_expr,'"')) ,NULL),
    (CASE WHEN w.schedule_expr is null THEN 'ONCE'
       ELSE DECODE(bitand(w.flags,16+32),16,'NAMED',32,'CALENDAR',NULL) END),
    w.start_date,
    DECODE(bitand(w.flags,16),0,w.schedule_expr,NULL), w.end_date, w.duration,
    DECODE(w.priority,1,'HIGH',2,'LOW',NULL), w.next_start_date,
    w.actual_start_date,
    DECODE(bitand(w.flags, 1),0,'FALSE',1,'TRUE'),
    DECODE(bitand(w.flags,1+2),2,'TRUE',3,'TRUE','FALSE'), 
    w.manual_open_time, w.manual_duration, w.comments
  FROM obj$ wo, sys.scheduler$_window w
  WHERE w.obj# = wo.obj#
/
COMMENT ON TABLE dba_scheduler_windows IS
'All scheduler windows in the database'
/
COMMENT ON COLUMN dba_scheduler_windows.window_name IS
'Name of the scheduler window'
/
COMMENT ON COLUMN dba_scheduler_windows.resource_plan IS
'Resource plan associated with the window'
/
COMMENT ON COLUMN dba_scheduler_windows.next_start_date IS
'Next date on which this window is scheduled to start'
/
COMMENT ON COLUMN dba_scheduler_windows.duration IS
'Duration of the window'
/
COMMENT ON COLUMN dba_scheduler_windows.schedule_name IS
'Name of the schedule of this window'
/
COMMENT ON COLUMN dba_scheduler_windows.schedule_type IS
'Type of the schedule of this window'
/
COMMENT ON COLUMN dba_scheduler_windows.schedule_owner IS
'Owner of the schedule of this window'
/
COMMENT ON COLUMN dba_scheduler_windows.repeat_interval IS
'Calendar string for this window (for an inlined schedule)'
/
COMMENT ON COLUMN dba_scheduler_windows.start_date IS
'Start date of the window (for an inlined schedule)'
/
COMMENT ON COLUMN dba_scheduler_windows.end_date IS
'Date after which the window will no longer open (for an inlined schedule)'
/
COMMENT ON COLUMN dba_scheduler_windows.last_start_date IS
'The last date on which this window opened'
/
COMMENT ON COLUMN dba_scheduler_windows.window_priority IS
'Priority of this job relative to other windows'
/
COMMENT ON COLUMN dba_scheduler_windows.enabled IS
'True if the window is enabled'
/
COMMENT ON COLUMN dba_scheduler_windows.active IS
'True if the window is open'
/
COMMENT ON COLUMN dba_scheduler_windows.manual_open_time IS
'Open time of window if it was manually opened, else NULL'
/
COMMENT ON COLUMN dba_scheduler_windows.manual_duration IS
'Duration of window if it was manually opened, else NULL'
/
COMMENT ON COLUMN dba_scheduler_windows.comments IS
'Comments on the window'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_scheduler_windows
  FOR dba_scheduler_windows
/
GRANT SELECT ON dba_scheduler_windows TO select_catalog_role
/

CREATE OR REPLACE VIEW all_scheduler_windows AS
  SELECT * FROM dba_scheduler_windows;
/
COMMENT ON TABLE all_scheduler_windows IS
'All scheduler windows in the database'
/
COMMENT ON COLUMN all_scheduler_windows.window_name IS
'Name of the scheduler window'
/
COMMENT ON COLUMN all_scheduler_windows.resource_plan IS
'Resource plan associated with the window'
/
COMMENT ON COLUMN all_scheduler_windows.next_start_date IS
'Next date on which this window is scheduled to start'
/
COMMENT ON COLUMN all_scheduler_windows.duration IS
'Duration of the window'
/
COMMENT ON COLUMN all_scheduler_windows.schedule_name IS
'Name of the schedule of this window'
/
COMMENT ON COLUMN all_scheduler_windows.schedule_type IS
'Type of the schedule of this window'
/
COMMENT ON COLUMN all_scheduler_windows.schedule_owner IS
'Owner of the schedule of this window'
/
COMMENT ON COLUMN all_scheduler_windows.repeat_interval IS
'Calendar string for this window (for an inlined schedule)'
/
COMMENT ON COLUMN all_scheduler_windows.start_date IS
'Start date of the window (for an inlined schedule)'
/
COMMENT ON COLUMN all_scheduler_windows.end_date IS
'Date after which the window will no longer open (for an inlined schedule)'
/
COMMENT ON COLUMN all_scheduler_windows.last_start_date IS
'The last date on which this window opened'
/
COMMENT ON COLUMN all_scheduler_windows.window_priority IS
'Priority of this job relative to other windows'
/
COMMENT ON COLUMN all_scheduler_windows.enabled IS
'True if the window is enabled'
/
COMMENT ON COLUMN all_scheduler_windows.active IS
'True if the window is open'
/
COMMENT ON COLUMN all_scheduler_windows.manual_open_time IS
'Open time of window if it was manually opened, else NULL'
/
COMMENT ON COLUMN all_scheduler_windows.manual_duration IS
'Duration of window if it was manually opened, else NULL'
/
COMMENT ON COLUMN all_scheduler_windows.comments IS
'Comments on the window'
/
CREATE OR REPLACE PUBLIC SYNONYM all_scheduler_windows
  FOR all_scheduler_windows
/
GRANT SELECT ON all_scheduler_windows TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW dba_scheduler_program_args
  (OWNER, PROGRAM_NAME, ARGUMENT_NAME, ARGUMENT_POSITION, ARGUMENT_TYPE,
   METADATA_ATTRIBUTE, DEFAULT_VALUE, DEFAULT_ANYDATA_VALUE, OUT_ARGUMENT) AS
  SELECT u.name, o.name, a.name, a.position,
  CASE WHEN (a.user_type_num IS NULL) THEN 
    DECODE(a.type_number,
0, null,
1, decode(a.flags, 512, 'NVARCHAR2', 'VARCHAR2'),
2, decode(a.flags, 512, 'FLOAT', 'NUMBER'),
3, 'NATIVE INTEGER',
8, 'LONG',
9, decode(a.flags, 512, 'NCHAR VARYING', 'VARCHAR'),
11, 'ROWID',
12, 'DATE',
23, 'RAW',
24, 'LONG RAW',
29, 'BINARY_INTEGER',
69, 'ROWID',
96, decode(a.flags, 512, 'NCHAR', 'CHAR'),
100, 'BINARY_FLOAT',
101, 'BINARY_DOUBLE',
102, 'REF CURSOR',
104, 'UROWID',
105, 'MLSLABEL',
106, 'MLSLABEL',
110, 'REF',
111, 'REF',
112, decode(a.flags, 512, 'NCLOB', 'CLOB'),
113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
121, 'OBJECT',
122, 'TABLE',
123, 'VARRAY',
178, 'TIME',
179, 'TIME WITH TIME ZONE',
180, 'TIMESTAMP',
181, 'TIMESTAMP WITH TIME ZONE',
231, 'TIMESTAMP WITH LOCAL TIME ZONE',
182, 'INTERVAL YEAR TO MONTH',
183, 'INTERVAL DAY TO SECOND',
250, 'PL/SQL RECORD',
251, 'PL/SQL TABLE',
252, 'PL/SQL BOOLEAN',
'UNDEFINED')
    ELSE t_u.name ||'.'|| t_o.name END,
  DECODE(bitand(a.flags,2+4+64+128+256+1024), 2,'JOB_NAME',4,'JOB_OWNER',
         64, 'JOB_START', 128, 'WINDOW_START',
         256, 'WINDOW_END', 1024, 'JOB_SUBNAME', ''),
  dbms_scheduler.get_varchar2_value(a.value), a.value,
  DECODE(BITAND(a.flags,1),0,'FALSE',1,'TRUE')
  FROM obj$ o, user$ u, sys.scheduler$_program_argument a, obj$ t_o, user$ t_u
  WHERE a.oid = o.obj# AND u.user# = o.owner#
    AND a.user_type_num = t_o.obj#(+) AND t_o.owner# = t_u.user#(+)
/
COMMENT ON TABLE dba_scheduler_program_args IS
'All arguments of all scheduler programs in the database'
/
COMMENT ON COLUMN dba_scheduler_program_args.program_name IS
'Name of the program this argument belongs to'
/
COMMENT ON COLUMN dba_scheduler_program_args.owner IS
'Owner of the program this argument belongs to'
/
COMMENT ON COLUMN dba_scheduler_program_args.argument_name IS
'Optional name of this argument'
/
COMMENT ON COLUMN dba_scheduler_program_args.argument_position IS
'Position of this argument in the argument list'
/
COMMENT ON COLUMN dba_scheduler_program_args.argument_type IS
'Data type of this argument'
/
COMMENT ON COLUMN dba_scheduler_program_args.metadata_attribute IS
'Metadata attribute (if a metadata argument)'
/
COMMENT ON COLUMN dba_scheduler_program_args.default_anydata_value IS
'Default value taken by this argument in AnyData format'
/
COMMENT ON COLUMN dba_scheduler_program_args.default_value IS
'Default value taken by this argument in string format (if a string)'
/
COMMENT ON COLUMN dba_scheduler_program_args.out_argument IS
'Whether this is an out argument'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_scheduler_program_args
  FOR dba_scheduler_program_args
/
GRANT SELECT ON dba_scheduler_program_args TO select_catalog_role
/

CREATE OR REPLACE VIEW user_scheduler_program_args
  (PROGRAM_NAME, ARGUMENT_NAME, ARGUMENT_POSITION, ARGUMENT_TYPE,
   METADATA_ATTRIBUTE, DEFAULT_VALUE, DEFAULT_ANYDATA_VALUE, OUT_ARGUMENT) AS
  SELECT o.name, a.name, a.position,
  CASE WHEN (a.user_type_num IS NULL) THEN 
    DECODE(a.type_number,
0, null,
1, decode(a.flags, 512, 'NVARCHAR2', 'VARCHAR2'),
2, decode(a.flags, 512, 'FLOAT', 'NUMBER'),
3, 'NATIVE INTEGER',
8, 'LONG',
9, decode(a.flags, 512, 'NCHAR VARYING', 'VARCHAR'),
11, 'ROWID',
12, 'DATE',
23, 'RAW',
24, 'LONG RAW',
29, 'BINARY_INTEGER',
69, 'ROWID',
96, decode(a.flags, 512, 'NCHAR', 'CHAR'),
100, 'BINARY_FLOAT',
101, 'BINARY_DOUBLE',
102, 'REF CURSOR',
104, 'UROWID',
105, 'MLSLABEL',
106, 'MLSLABEL',
110, 'REF',
111, 'REF',
112, decode(a.flags, 512, 'NCLOB', 'CLOB'),
113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
121, 'OBJECT',
122, 'TABLE',
123, 'VARRAY',
178, 'TIME',
179, 'TIME WITH TIME ZONE',
180, 'TIMESTAMP',
181, 'TIMESTAMP WITH TIME ZONE',
231, 'TIMESTAMP WITH LOCAL TIME ZONE',
182, 'INTERVAL YEAR TO MONTH',
183, 'INTERVAL DAY TO SECOND',
250, 'PL/SQL RECORD',
251, 'PL/SQL TABLE',
252, 'PL/SQL BOOLEAN',
'UNDEFINED')
    ELSE t_u.name ||'.'|| t_o.name END,
  DECODE(bitand(a.flags,2+4+64+128+256+1024), 2,'JOB_NAME',4,'JOB_OWNER',
         64, 'JOB_START', 128, 'WINDOW_START',
         256, 'WINDOW_END', 1024, 'JOB_SUBNAME', ''),
  dbms_scheduler.get_varchar2_value(a.value), a.value,
  DECODE(BITAND(a.flags,1),0,'FALSE',1,'TRUE')
  FROM sys.scheduler$_program_argument a, obj$ t_o, user$ t_u, obj$ o
  WHERE a.oid = o.obj# AND o.owner# = USERENV('SCHEMAID')
    AND a.user_type_num = t_o.obj#(+) AND t_o.owner# = t_u.user#(+)
/
COMMENT ON TABLE user_scheduler_program_args IS
'All arguments of all scheduler programs in the database'
/
COMMENT ON COLUMN user_scheduler_program_args.program_name IS
'Name of the program this argument belongs to'
/
COMMENT ON COLUMN user_scheduler_program_args.argument_name IS
'Optional name of this argument'
/
COMMENT ON COLUMN user_scheduler_program_args.argument_position IS
'Position of this argument in the argument list'
/
COMMENT ON COLUMN user_scheduler_program_args.argument_type IS
'Data type of this argument'
/
COMMENT ON COLUMN user_scheduler_program_args.metadata_attribute IS
'Metadata attribute (if a metadata argument)'
/
COMMENT ON COLUMN user_scheduler_program_args.default_anydata_value IS
'Default value taken by this argument in AnyData format'
/
COMMENT ON COLUMN user_scheduler_program_args.default_value IS
'Default value taken by this argument in string format (if a string)'
/
COMMENT ON COLUMN user_scheduler_program_args.out_argument IS
'Whether this is an out argument'
/
CREATE OR REPLACE PUBLIC SYNONYM user_scheduler_program_args
  FOR user_scheduler_program_args
/
GRANT SELECT ON user_scheduler_program_args TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW all_scheduler_program_args
  (OWNER, PROGRAM_NAME, ARGUMENT_NAME, ARGUMENT_POSITION, ARGUMENT_TYPE,
   METADATA_ATTRIBUTE, DEFAULT_VALUE, DEFAULT_ANYDATA_VALUE, OUT_ARGUMENT) AS
  SELECT u.name, o.name, a.name, a.position,
  CASE WHEN (a.user_type_num IS NULL) THEN 
    DECODE(a.type_number,
0, null,
1, decode(a.flags, 512, 'NVARCHAR2', 'VARCHAR2'),
2, decode(a.flags, 512, 'FLOAT', 'NUMBER'),
3, 'NATIVE INTEGER',
8, 'LONG',
9, decode(a.flags, 512, 'NCHAR VARYING', 'VARCHAR'),
11, 'ROWID',
12, 'DATE',
23, 'RAW',
24, 'LONG RAW',
29, 'BINARY_INTEGER',
69, 'ROWID',
96, decode(a.flags, 512, 'NCHAR', 'CHAR'),
100, 'BINARY_FLOAT',
101, 'BINARY_DOUBLE',
102, 'REF CURSOR',
104, 'UROWID',
105, 'MLSLABEL',
106, 'MLSLABEL',
110, 'REF',
111, 'REF',
112, decode(a.flags, 512, 'NCLOB', 'CLOB'),
113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
121, 'OBJECT',
122, 'TABLE',
123, 'VARRAY',
178, 'TIME',
179, 'TIME WITH TIME ZONE',
180, 'TIMESTAMP',
181, 'TIMESTAMP WITH TIME ZONE',
231, 'TIMESTAMP WITH LOCAL TIME ZONE',
182, 'INTERVAL YEAR TO MONTH',
183, 'INTERVAL DAY TO SECOND',
250, 'PL/SQL RECORD',
251, 'PL/SQL TABLE',
252, 'PL/SQL BOOLEAN',
'UNDEFINED')
    ELSE t_u.name ||'.'|| t_o.name END,
  DECODE(bitand(a.flags,2+4+64+128+256+1024), 2,'JOB_NAME',4,'JOB_OWNER',
         64, 'JOB_START', 128, 'WINDOW_START',
         256, 'WINDOW_END', 1024, 'JOB_SUBNAME', ''),
  dbms_scheduler.get_varchar2_value(a.value), a.value,
  DECODE(BITAND(a.flags,1),0,'FALSE',1,'TRUE')
  FROM obj$ o, user$ u, sys.scheduler$_program_argument a, obj$ t_o, user$ t_u
  WHERE a.oid = o.obj# AND u.user# = o.owner# AND
    a.user_type_num = t_o.obj#(+) AND t_o.owner# = t_u.user#(+) AND
    (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         (exists (select null from v$enabledprivs
                 where priv_number in (-265 /* CREATE ANY JOB */,
                                       -266 /* EXECUTE ANY PROGRAM */ )
                 )
          and o.owner#!=0)
      )
/
COMMENT ON TABLE all_scheduler_program_args IS
'All arguments of all scheduler programs visible to the user'
/
COMMENT ON COLUMN all_scheduler_program_args.program_name IS
'Name of the program this argument belongs to'
/
COMMENT ON COLUMN all_scheduler_program_args.owner IS
'Owner of the program this argument belongs to'
/
COMMENT ON COLUMN all_scheduler_program_args.argument_name IS
'Optional name of this argument'
/
COMMENT ON COLUMN all_scheduler_program_args.argument_position IS
'Position of this argument in the argument list'
/
COMMENT ON COLUMN all_scheduler_program_args.argument_type IS
'Data type of this argument'
/
COMMENT ON COLUMN all_scheduler_program_args.metadata_attribute IS
'Metadata attribute (if a metadata argument)'
/
COMMENT ON COLUMN all_scheduler_program_args.default_anydata_value IS
'Default value taken by this argument in AnyData format'
/
COMMENT ON COLUMN all_scheduler_program_args.default_value IS
'Default value taken by this argument in string format (if a string)'
/
COMMENT ON COLUMN all_scheduler_program_args.out_argument IS
'Whether this is an out argument'
/
CREATE OR REPLACE PUBLIC SYNONYM all_scheduler_program_args
  FOR all_scheduler_program_args
/
GRANT SELECT ON all_scheduler_program_args TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW dba_scheduler_job_args
  (OWNER, JOB_NAME, ARGUMENT_NAME, ARGUMENT_POSITION, ARGUMENT_TYPE,
   VALUE, ANYDATA_VALUE, OUT_ARGUMENT)
  AS SELECT u.name, o.name, b.name, t.position,
  CASE WHEN (b.user_type_num IS NULL) THEN
    DECODE(b.type_number,
0, null,
1, decode(b.flags, 512, 'NVARCHAR2', 'VARCHAR2'),
2, decode(b.flags, 512, 'FLOAT', 'NUMBER'),
3, 'NATIVE INTEGER',
8, 'LONG',
9, decode(b.flags, 512, 'NCHAR VARYING', 'VARCHAR'),
11, 'ROWID',
12, 'DATE',
23, 'RAW',
24, 'LONG RAW',
29, 'BINARY_INTEGER',
69, 'ROWID',
96, decode(b.flags, 512, 'NCHAR', 'CHAR'),
100, 'BINARY_FLOAT',
101, 'BINARY_DOUBLE',
102, 'REF CURSOR',
104, 'UROWID',
105, 'MLSLABEL',
106, 'MLSLABEL',
110, 'REF',
111, 'REF',
112, decode(b.flags, 512, 'NCLOB', 'CLOB'),
113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
121, 'OBJECT',
122, 'TABLE',
123, 'VARRAY',
178, 'TIME',
179, 'TIME WITH TIME ZONE',
180, 'TIMESTAMP',
181, 'TIMESTAMP WITH TIME ZONE',
231, 'TIMESTAMP WITH LOCAL TIME ZONE',
182, 'INTERVAL YEAR TO MONTH',
183, 'INTERVAL DAY TO SECOND',
250, 'PL/SQL RECORD',
251, 'PL/SQL TABLE',
252, 'PL/SQL BOOLEAN',
'UNDEFINED')
    ELSE t_u.name ||'.'|| t_o.name END,
  dbms_scheduler.get_varchar2_value(t.value), t.value,
  DECODE(BITAND(b.flags,1),0,'FALSE',1,'TRUE')
  FROM obj$ o, user$ u, (SELECT a.oid job_oid, a.position position,
      j.program_oid program_oid, a.value value
    FROM sys.scheduler$_job j, sys.scheduler$_job_argument a
    WHERE a.oid = j.obj#) t, obj$ t_o, user$ t_u,
    sys.scheduler$_program_argument b
  WHERE t.job_oid = o.obj# AND u.user# = o.owner#
    AND b.user_type_num = t_o.obj#(+) AND t_o.owner# = t_u.user#(+)
    AND t.program_oid=b.oid(+) AND t.position=b.position(+)
/
COMMENT ON TABLE dba_scheduler_job_args IS
'All arguments with set values of all scheduler jobs in the database'
/
COMMENT ON COLUMN dba_scheduler_job_args.job_name IS
'Name of the job this argument belongs to'
/
COMMENT ON COLUMN dba_scheduler_job_args.owner IS
'Owner of the job this argument belongs to'
/
COMMENT ON COLUMN dba_scheduler_job_args.argument_name IS
'Optional name of this argument'
/
COMMENT ON COLUMN dba_scheduler_job_args.argument_position IS
'Position of this argument in the argument list'
/
COMMENT ON COLUMN dba_scheduler_job_args.argument_type IS
'Data type of this argument'
/
COMMENT ON COLUMN dba_scheduler_job_args.anydata_value IS
'Value set to this argument in AnyData format'
/
COMMENT ON COLUMN dba_scheduler_job_args.value IS
'Value set to this argument in string format (if a string)'
/
COMMENT ON COLUMN dba_scheduler_job_args.out_argument IS
'Reserved for future use'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_scheduler_job_args
  FOR dba_scheduler_job_args
/
GRANT SELECT ON dba_scheduler_job_args TO select_catalog_role
/

CREATE OR REPLACE VIEW user_scheduler_job_args
  (JOB_NAME, ARGUMENT_NAME, ARGUMENT_POSITION, ARGUMENT_TYPE,
   VALUE, ANYDATA_VALUE, OUT_ARGUMENT)
  AS SELECT o.name, b.name, t.position,
  CASE WHEN (b.user_type_num IS NULL) THEN
    DECODE(b.type_number,
0, null,
1, decode(b.flags, 512, 'NVARCHAR2', 'VARCHAR2'),
2, decode(b.flags, 512, 'FLOAT', 'NUMBER'),
3, 'NATIVE INTEGER',
8, 'LONG',
9, decode(b.flags, 512, 'NCHAR VARYING', 'VARCHAR'),
11, 'ROWID',
12, 'DATE',
23, 'RAW',
24, 'LONG RAW',
29, 'BINARY_INTEGER',
69, 'ROWID',
96, decode(b.flags, 512, 'NCHAR', 'CHAR'),
100, 'BINARY_FLOAT',
101, 'BINARY_DOUBLE',
102, 'REF CURSOR',
104, 'UROWID',
105, 'MLSLABEL',
106, 'MLSLABEL',
110, 'REF',
111, 'REF',
112, decode(b.flags, 512, 'NCLOB', 'CLOB'),
113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
121, 'OBJECT',
122, 'TABLE',
123, 'VARRAY',
178, 'TIME',
179, 'TIME WITH TIME ZONE',
180, 'TIMESTAMP',
181, 'TIMESTAMP WITH TIME ZONE',
231, 'TIMESTAMP WITH LOCAL TIME ZONE',
182, 'INTERVAL YEAR TO MONTH',
183, 'INTERVAL DAY TO SECOND',
250, 'PL/SQL RECORD',
251, 'PL/SQL TABLE',
252, 'PL/SQL BOOLEAN',
'UNDEFINED')
    ELSE t_u.name ||'.'|| t_o.name END,
  dbms_scheduler.get_varchar2_value(t.value), t.value,
  DECODE(BITAND(b.flags,1),0,'FALSE',1,'TRUE')
  FROM  sys.scheduler$_program_argument b, obj$ t_o, user$ t_u,
    (SELECT a.oid job_oid, a.position position,
      j.program_oid program_oid, a.value value
    FROM sys.scheduler$_job_argument a,  sys.scheduler$_job j
    WHERE a.oid = j.obj#) t,
   obj$ o
  WHERE t.job_oid = o.obj# AND o.owner# = USERENV('SCHEMAID')
    AND b.user_type_num = t_o.obj#(+) AND t_o.owner# = t_u.user#(+)
    AND t.program_oid=b.oid(+) AND t.position=b.position(+)
/
COMMENT ON TABLE user_scheduler_job_args IS
'All arguments with set values of all scheduler jobs in the database'
/
COMMENT ON COLUMN user_scheduler_job_args.job_name IS
'Name of the job this argument belongs to'
/
COMMENT ON COLUMN user_scheduler_job_args.argument_name IS
'Optional name of this argument'
/
COMMENT ON COLUMN user_scheduler_job_args.argument_position IS
'Position of this argument in the argument list'
/
COMMENT ON COLUMN user_scheduler_job_args.argument_type IS
'Data type of this argument'
/
COMMENT ON COLUMN user_scheduler_job_args.anydata_value IS
'Value set to this argument in AnyData format'
/
COMMENT ON COLUMN user_scheduler_job_args.value IS
'Value set to this argument in string format (if a string)'
/
COMMENT ON COLUMN user_scheduler_job_args.out_argument IS
'Reserved for future use'
/
CREATE OR REPLACE PUBLIC SYNONYM user_scheduler_job_args
  FOR user_scheduler_job_args
/
GRANT SELECT ON user_scheduler_job_args TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW all_scheduler_job_args
  (OWNER, JOB_NAME, ARGUMENT_NAME, ARGUMENT_POSITION, ARGUMENT_TYPE,
   VALUE, ANYDATA_VALUE, OUT_ARGUMENT)
  AS SELECT u.name, o.name, b.name, t.position,
  CASE WHEN (b.user_type_num IS NULL) THEN
    DECODE(b.type_number,
0, null,
1, decode(b.flags, 512, 'NVARCHAR2', 'VARCHAR2'),
2, decode(b.flags, 512, 'FLOAT', 'NUMBER'),
3, 'NATIVE INTEGER',
8, 'LONG',
9, decode(b.flags, 512, 'NCHAR VARYING', 'VARCHAR'),
11, 'ROWID',
12, 'DATE',
23, 'RAW',
24, 'LONG RAW',
29, 'BINARY_INTEGER',
69, 'ROWID',
96, decode(b.flags, 512, 'NCHAR', 'CHAR'),
100, 'BINARY_FLOAT',
101, 'BINARY_DOUBLE',
102, 'REF CURSOR',
104, 'UROWID',
105, 'MLSLABEL',
106, 'MLSLABEL',
110, 'REF',
111, 'REF',
112, decode(b.flags, 512, 'NCLOB', 'CLOB'),
113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
121, 'OBJECT',
122, 'TABLE',
123, 'VARRAY',
178, 'TIME',
179, 'TIME WITH TIME ZONE',
180, 'TIMESTAMP',
181, 'TIMESTAMP WITH TIME ZONE',
231, 'TIMESTAMP WITH LOCAL TIME ZONE',
182, 'INTERVAL YEAR TO MONTH',
183, 'INTERVAL DAY TO SECOND',
250, 'PL/SQL RECORD',
251, 'PL/SQL TABLE',
252, 'PL/SQL BOOLEAN',
'UNDEFINED')
    ELSE t_u.name ||'.'|| t_o.name END,
  dbms_scheduler.get_varchar2_value(t.value), t.value,
  DECODE(BITAND(b.flags,1),0,'FALSE',1,'TRUE')
  FROM obj$ t_o, user$ t_u,
    sys.scheduler$_program_argument b, obj$ o, user$ u,
    (SELECT a.oid job_oid, a.position position,
      j.program_oid program_oid, a.value value
    FROM sys.scheduler$_job j, sys.scheduler$_job_argument a
    WHERE a.oid = j.obj#) t
  WHERE t.job_oid = o.obj# AND u.user# = o.owner#
    AND b.user_type_num = t_o.obj#(+) AND t_o.owner# = t_u.user#(+)
    AND t.program_oid=b.oid(+) AND t.position=b.position(+) AND
    (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         (exists (select null from v$enabledprivs
                 where priv_number = -265 /* CREATE ANY JOB */
                 )
          and o.owner#!=0)
      )
/
COMMENT ON TABLE all_scheduler_job_args IS
'All arguments with set values of all scheduler jobs in the database'
/
COMMENT ON COLUMN all_scheduler_job_args.job_name IS
'Name of the job this argument belongs to'
/
COMMENT ON COLUMN all_scheduler_job_args.owner IS
'Owner of the job this argument belongs to'
/
COMMENT ON COLUMN all_scheduler_job_args.argument_name IS
'Optional name of this argument'
/
COMMENT ON COLUMN all_scheduler_job_args.argument_position IS
'Position of this argument in the argument list'
/
COMMENT ON COLUMN all_scheduler_job_args.argument_type IS
'Data type of this argument'
/
COMMENT ON COLUMN all_scheduler_job_args.anydata_value IS
'Value set to this argument in AnyData format'
/
COMMENT ON COLUMN all_scheduler_job_args.value IS
'Value set to this argument in string format (if a string)'
/
COMMENT ON COLUMN all_scheduler_job_args.out_argument IS
'Reserved for future use'
/
CREATE OR REPLACE PUBLIC SYNONYM all_scheduler_job_args
  FOR all_scheduler_job_args
/
GRANT SELECT ON all_scheduler_job_args TO public WITH GRANT OPTION
/

/* Job and Window Log views */

CREATE OR REPLACE VIEW dba_scheduler_job_log
  ( LOG_ID, LOG_DATE, OWNER, JOB_NAME, JOB_SUBNAME, JOB_CLASS, OPERATION, STATUS, 
    USER_NAME, CLIENT_ID, GLOBAL_UID, ADDITIONAL_INFO)
  AS 
  (SELECT 
     LOG_ID, LOG_DATE, OWNER,
     DECODE(instr(e.NAME,'"'),0, e.NAME,substr(e.NAME,1,instr(e.NAME,'"')-1)),
     DECODE(instr(e.NAME,'"'),0,NULL,substr(e.NAME,instr(e.NAME,'"')+1)),
     co.NAME, OPERATION,e.STATUS, USER_NAME, CLIENT_ID, GUID, ADDITIONAL_INFO
  FROM scheduler$_event_log e, obj$ co
  WHERE e.type# = 66 and e.class_id = co.obj#(+))
/
COMMENT ON TABLE dba_scheduler_job_log IS
'Logged information for all scheduler jobs'
/
COMMENT ON COLUMN dba_scheduler_job_log.log_id IS
'The unique id that identifies a row'
/
COMMENT ON COLUMN dba_scheduler_job_log.log_date IS
'The date of this log entry'
/
COMMENT ON COLUMN dba_scheduler_job_log.owner IS
'The owner of the scheduler job'
/
COMMENT ON COLUMN dba_scheduler_job_log.job_name IS
'The name of the scheduler job'
/
COMMENT ON COLUMN dba_scheduler_job_log.job_subname IS
'The subname of the scheduler job (for a chain step job)'
/
COMMENT ON COLUMN dba_scheduler_job_log.job_class IS
'The class the job belonged to at the time of entry'
/
COMMENT ON COLUMN dba_scheduler_job_log.operation IS
'The operation corresponding to this log entry'
/
COMMENT ON COLUMN dba_scheduler_job_log.status IS
'The status of the operation, if applicable'
/
COMMENT ON COLUMN dba_scheduler_job_log.user_name IS
'The name of the user who performed the operation, if applicable'
/
COMMENT ON COLUMN dba_scheduler_job_log.client_id IS
'The client id of the user who performed the operation, if applicable'
/
COMMENT ON COLUMN dba_scheduler_job_log.global_uid IS
'The global_uid of the user who performed the operation, if applicable'
/
COMMENT ON COLUMN dba_scheduler_job_log.additional_info IS
'Additional information on this entry, if applicable'
/

CREATE OR REPLACE VIEW dba_scheduler_job_run_details
  ( LOG_ID, LOG_DATE, OWNER, JOB_NAME, JOB_SUBNAME, STATUS, ERROR#, REQ_START_DATE, 
    ACTUAL_START_DATE, RUN_DURATION, INSTANCE_ID, SESSION_ID, SLAVE_PID, 
    CPU_USED, ADDITIONAL_INFO)
  AS
  (SELECT 
     j.LOG_ID, j.LOG_DATE, e.OWNER,
     DECODE(instr(e.NAME,'"'),0, e.NAME,substr(e.NAME,1,instr(e.NAME,'"')-1)),
     DECODE(instr(e.NAME,'"'),0,NULL,substr(e.NAME,instr(e.NAME,'"')+1)),
     e.STATUS, j.ERROR#, j.REQ_START_DATE, j.START_DATE, j.RUN_DURATION,
     j.INSTANCE_ID, j.SESSION_ID, j.SLAVE_PID, j.CPU_USED, j.ADDITIONAL_INFO
   FROM scheduler$_job_run_details j, scheduler$_event_log e
   WHERE j.log_id = e.log_id
   AND e.type# = 66)
/
COMMENT ON TABLE dba_scheduler_job_run_details IS
'The details of a job run'
/
COMMENT ON COLUMN dba_scheduler_job_run_details.log_id IS
'The unique id of the log entry. Foreign key on entry in dba_scheduler_job_log'
/
COMMENT ON COLUMN dba_scheduler_job_run_details.log_date IS
'The date of the log entry'
/
COMMENT ON COLUMN dba_scheduler_job_run_details.owner IS
'The owner of the scheduler job'
/
COMMENT ON COLUMN dba_scheduler_job_run_details.job_name IS
'The name of the scheduler job'
/
COMMENT ON COLUMN dba_scheduler_job_run_details.job_subname IS
'The subname of the scheduler job (for a chain step job)'
/
COMMENT ON COLUMN dba_scheduler_job_run_details.status IS
'The status of the job run'
/
COMMENT ON COLUMN dba_scheduler_job_run_details.error# IS
'The error number in the case of error'
/
COMMENT ON COLUMN dba_scheduler_job_run_details.req_start_date IS
'The requested start date of the job run'
/
COMMENT ON COLUMN dba_scheduler_job_run_details.actual_start_date IS
'The actual date the job ran'
/
COMMENT ON COLUMN dba_scheduler_job_run_details.run_duration IS
'The duration that the job ran'
/
COMMENT ON COLUMN dba_scheduler_job_run_details.instance_id IS
'The id of the instance on which the job ran'
/
COMMENT ON COLUMN dba_scheduler_job_run_details.session_id IS
'The session id of the job run'
/
COMMENT ON COLUMN dba_scheduler_job_run_details.slave_pid IS
'The process id of the slave on which the job ran'
/
COMMENT ON COLUMN dba_scheduler_job_run_details.cpu_used IS
'The amount of cpu used for this job run'
/
COMMENT ON COLUMN dba_scheduler_job_run_details.additional_info IS
'Additional information on the job run, if applicable'
/

CREATE OR REPLACE PUBLIC SYNONYM dba_scheduler_job_log
  FOR dba_scheduler_job_log
/
GRANT SELECT ON dba_scheduler_job_log TO select_catalog_role
/
CREATE OR REPLACE PUBLIC SYNONYM dba_scheduler_job_run_details
  FOR dba_scheduler_job_run_details
/
GRANT SELECT ON dba_scheduler_job_run_details TO select_catalog_role
/


CREATE OR REPLACE VIEW user_scheduler_job_log
  ( LOG_ID, LOG_DATE, OWNER, JOB_NAME, JOB_SUBNAME, JOB_CLASS, OPERATION, STATUS, 
    USER_NAME, CLIENT_ID, GLOBAL_UID, ADDITIONAL_INFO)
  AS 
  (SELECT 
     LOG_ID, LOG_DATE, OWNER,
     DECODE(instr(e.NAME,'"'),0, e.NAME,substr(e.NAME,1,instr(e.NAME,'"')-1)),
     DECODE(instr(e.NAME,'"'),0,NULL,substr(e.NAME,instr(e.NAME,'"')+1)),
     co.NAME, OPERATION,e.STATUS, USER_NAME, CLIENT_ID, GUID, ADDITIONAL_INFO
  FROM scheduler$_event_log e, obj$ co 
  WHERE e.type# = 66 and e.class_id = co.obj#(+)
  AND owner = SYS_CONTEXT('USERENV','CURRENT_SCHEMA'))
/
COMMENT ON TABLE user_scheduler_job_log IS
'Logged information for all scheduler jobs'
/
COMMENT ON COLUMN user_scheduler_job_log.log_id IS
'The unique id that identifies a row'
/
COMMENT ON COLUMN user_scheduler_job_log.log_date IS
'The date of this log entry'
/
COMMENT ON COLUMN user_scheduler_job_log.owner IS
'The owner of the scheduler job'
/
COMMENT ON COLUMN user_scheduler_job_log.job_name IS
'The name of the scheduler job'
/
COMMENT ON COLUMN user_scheduler_job_log.job_subname IS
'The subname of the scheduler job (for a chain step job)'
/
COMMENT ON COLUMN user_scheduler_job_log.job_class IS
'The class the job belonged to at the time of entry'
/
COMMENT ON COLUMN user_scheduler_job_log.operation IS
'The operation corresponding to this log entry'
/
COMMENT ON COLUMN user_scheduler_job_log.status IS
'The status of the operation, if applicable'
/
COMMENT ON COLUMN user_scheduler_job_log.user_name IS
'The name of the user who performed the operation, if applicable'
/
COMMENT ON COLUMN user_scheduler_job_log.client_id IS
'The client id of the user who performed the operation, if applicable'
/
COMMENT ON COLUMN user_scheduler_job_log.global_uid IS
'The global_uid of the user who performed the operation, if applicable'
/
COMMENT ON COLUMN user_scheduler_job_log.additional_info IS
'Additional information on this entry, if applicable'
/

CREATE OR REPLACE VIEW user_scheduler_job_run_details
  ( LOG_ID, LOG_DATE, OWNER, JOB_NAME, JOB_SUBNAME, STATUS, ERROR#, REQ_START_DATE, 
    ACTUAL_START_DATE, RUN_DURATION, INSTANCE_ID, SESSION_ID, SLAVE_PID, 
    CPU_USED, ADDITIONAL_INFO)
  AS
  (SELECT 
     j.LOG_ID, j.LOG_DATE, e.OWNER,
     DECODE(instr(e.NAME,'"'),0, e.NAME,substr(e.NAME,1,instr(e.NAME,'"')-1)),
     DECODE(instr(e.NAME,'"'),0,NULL,substr(e.NAME,instr(e.NAME,'"')+1)),
     e.STATUS, j.ERROR#, j.REQ_START_DATE, j.START_DATE, j.RUN_DURATION,
     j.INSTANCE_ID, j.SESSION_ID, j.SLAVE_PID, j.CPU_USED, j.ADDITIONAL_INFO
   FROM scheduler$_job_run_details j, scheduler$_event_log e
   WHERE j.log_id = e.log_id
   AND e.type# = 66
   AND e.owner = SYS_CONTEXT('USERENV','CURRENT_SCHEMA'))
/
COMMENT ON TABLE user_scheduler_job_run_details IS
'The details of a job run'
/
COMMENT ON COLUMN user_scheduler_job_run_details.log_id IS
'The unique id of the log entry. Foreign key on entry in dba_scheduler_job_log'
/
COMMENT ON COLUMN user_scheduler_job_run_details.log_date IS
'The date of the log entry'
/
COMMENT ON COLUMN user_scheduler_job_run_details.owner IS
'The owner of the scheduler job'
/
COMMENT ON COLUMN user_scheduler_job_run_details.job_name IS
'The name of the scheduler job'
/
COMMENT ON COLUMN user_scheduler_job_run_details.job_subname IS
'The subname of the scheduler job (for a chain step job)'
/
COMMENT ON COLUMN user_scheduler_job_run_details.status IS
'The status of the job run'
/
COMMENT ON COLUMN user_scheduler_job_run_details.error# IS
'The error number in the case of error'
/
COMMENT ON COLUMN user_scheduler_job_run_details.req_start_date IS
'The requested start date of the job run'
/
COMMENT ON COLUMN user_scheduler_job_run_details.actual_start_date IS
'The actual date the job ran'
/
COMMENT ON COLUMN user_scheduler_job_run_details.run_duration IS
'The duration that the job ran'
/
COMMENT ON COLUMN user_scheduler_job_run_details.instance_id IS
'The id of the instance on which the job ran'
/
COMMENT ON COLUMN user_scheduler_job_run_details.session_id IS
'The session id of the job run'
/
COMMENT ON COLUMN user_scheduler_job_run_details.slave_pid IS
'The process id of the slave on which the job ran'
/
COMMENT ON COLUMN user_scheduler_job_run_details.cpu_used IS
'The amount of cpu used for this job run'
/
COMMENT ON COLUMN user_scheduler_job_run_details.additional_info IS
'Additional information on the job run, if applicable'
/

CREATE OR REPLACE PUBLIC SYNONYM user_scheduler_job_log
  FOR user_scheduler_job_log
/
GRANT SELECT ON user_scheduler_job_log TO public with GRANT OPTION
/
CREATE OR REPLACE PUBLIC SYNONYM user_scheduler_job_run_details
  FOR user_scheduler_job_run_details
/
GRANT SELECT ON user_scheduler_job_run_details TO public with GRANT OPTION
/



CREATE OR REPLACE VIEW all_scheduler_job_log
  ( LOG_ID, LOG_DATE, OWNER, JOB_NAME, JOB_SUBNAME, JOB_CLASS, OPERATION, STATUS, 
    USER_NAME, CLIENT_ID, GLOBAL_UID, ADDITIONAL_INFO)
  AS 
  (SELECT 
     e.LOG_ID, e.LOG_DATE, e.OWNER,
     DECODE(instr(e.NAME,'"'),0, e.NAME,substr(e.NAME,1,instr(e.NAME,'"')-1)),
     DECODE(instr(e.NAME,'"'),0,NULL,substr(e.NAME,instr(e.NAME,'"')+1)),
     co.NAME, OPERATION, e.STATUS, e.USER_NAME, e.CLIENT_ID, e.GUID,
     e.ADDITIONAL_INFO
   FROM scheduler$_event_log e, obj$ co
   WHERE e.type# = 66 and e.class_id = co.obj#(+)
   AND ( e.owner = SYS_CONTEXT('USERENV','CURRENT_SCHEMA')
         or  /* user has object privileges */
            ( select jo.obj# from obj$ jo, user$ ju where
              DECODE(instr(e.NAME,'"'),0, e.NAME,substr(e.NAME,1,instr(e.NAME,'"')-1)) = jo.name
                and e.owner = ju.name and jo.owner# = ju.user# 
                and jo.subname is null
            ) in
            ( select oa.obj#
                from sys.objauth$ oa
                where grantee# in ( select kzsrorol from x$kzsro )
            )
         or /* user has system privileges */
            (exists ( select null from v$enabledprivs
                       where priv_number = -265 /* CREATE ANY JOB */
                   )
             and e.owner!='SYS')
        )
  )
/
COMMENT ON TABLE all_scheduler_job_log IS
'Logged information for all scheduler jobs'
/
COMMENT ON COLUMN all_scheduler_job_log.log_id IS
'The unique id that identifies a row'
/
COMMENT ON COLUMN all_scheduler_job_log.log_date IS
'The date of this log entry'
/
COMMENT ON COLUMN all_scheduler_job_log.owner IS
'The owner of the scheduler job'
/
COMMENT ON COLUMN all_scheduler_job_log.job_name IS
'The name of the scheduler job'
/
COMMENT ON COLUMN all_scheduler_job_log.job_subname IS
'The subname of the scheduler job (for a chain step job)'
/
COMMENT ON COLUMN all_scheduler_job_log.job_class IS
'The class the job belonged to at the time of entry'
/
COMMENT ON COLUMN all_scheduler_job_log.operation IS
'The operation corresponding to this log entry'
/
COMMENT ON COLUMN all_scheduler_job_log.status IS
'The status of the operation, if applicable'
/
COMMENT ON COLUMN all_scheduler_job_log.user_name IS
'The name of the user who performed the operation, if applicable'
/
COMMENT ON COLUMN all_scheduler_job_log.client_id IS
'The client id of the user who performed the operation, if applicable'
/
COMMENT ON COLUMN all_scheduler_job_log.global_uid IS
'The global_uid of the user who performed the operation, if applicable'
/
COMMENT ON COLUMN all_scheduler_job_log.additional_info IS
'Additional information on this entry, if applicable'
/

CREATE OR REPLACE VIEW all_scheduler_job_run_details
  ( LOG_ID, LOG_DATE, OWNER, JOB_NAME, JOB_SUBNAME, STATUS, ERROR#, REQ_START_DATE, 
    ACTUAL_START_DATE, RUN_DURATION, INSTANCE_ID, SESSION_ID, SLAVE_PID, 
    CPU_USED, ADDITIONAL_INFO)
  AS
  (SELECT 
     j.LOG_ID, j.LOG_DATE, e.OWNER,
     DECODE(instr(e.NAME,'"'),0, e.NAME,substr(e.NAME,1,instr(e.NAME,'"')-1)),
     DECODE(instr(e.NAME,'"'),0,NULL,substr(e.NAME,instr(e.NAME,'"')+1)),
     e.STATUS, j.ERROR#, j.REQ_START_DATE, j.START_DATE, j.RUN_DURATION,
     j.INSTANCE_ID, j.SESSION_ID, j.SLAVE_PID, j.CPU_USED, j.ADDITIONAL_INFO
   FROM scheduler$_job_run_details j, scheduler$_event_log e
   WHERE j.log_id = e.log_id
   AND e.type# = 66
   AND ( e.owner = SYS_CONTEXT('USERENV','CURRENT_SCHEMA')
         or  /* user has object privileges */
            ( select jo.obj# from obj$ jo, user$ ju where
                DECODE(instr(e.NAME,'"'),0, e.NAME,substr(e.NAME,1,instr(e.NAME,'"')-1)) = jo.name
                and e.owner = ju.name and jo.owner# = ju.user# 
                and jo.subname is null
            ) in
            ( select oa.obj#
                from sys.objauth$ oa
                where grantee# in ( select kzsrorol from x$kzsro )
            )
         or /* user has system privileges */
            (exists ( select null from v$enabledprivs
                       where priv_number = -265 /* CREATE ANY JOB */
                   )
             and e.owner!='SYS')
        )
  )
/
COMMENT ON TABLE all_scheduler_job_run_details IS
'The details of a job run'
/
COMMENT ON COLUMN all_scheduler_job_run_details.log_id IS
'The unique id of the log entry. Foreign key on entry in dba_scheduler_job_log'
/
COMMENT ON COLUMN all_scheduler_job_run_details.log_date IS
'The date of the log entry'
/
COMMENT ON COLUMN all_scheduler_job_run_details.owner IS
'The owner of the scheduler job'
/
COMMENT ON COLUMN all_scheduler_job_run_details.job_name IS
'The name of the scheduler job'
/
COMMENT ON COLUMN all_scheduler_job_run_details.job_subname IS
'The subname of the scheduler job (for a chain step job)'
/
COMMENT ON COLUMN all_scheduler_job_run_details.status IS
'The status of the job run'
/
COMMENT ON COLUMN all_scheduler_job_run_details.error# IS
'The error number in the case of error'
/
COMMENT ON COLUMN all_scheduler_job_run_details.req_start_date IS
'The requested start date of the job run'
/
COMMENT ON COLUMN all_scheduler_job_run_details.actual_start_date IS
'The actual date the job ran'
/
COMMENT ON COLUMN all_scheduler_job_run_details.run_duration IS
'The duration that the job ran'
/
COMMENT ON COLUMN all_scheduler_job_run_details.instance_id IS
'The id of the instance on which the job ran'
/
COMMENT ON COLUMN all_scheduler_job_run_details.session_id IS
'The session id of the job run'
/
COMMENT ON COLUMN all_scheduler_job_run_details.slave_pid IS
'The process id of the slave on which the job ran'
/
COMMENT ON COLUMN all_scheduler_job_run_details.cpu_used IS
'The amount of cpu used for this job run'
/
COMMENT ON COLUMN all_scheduler_job_run_details.additional_info IS
'Additional information on the job run, if applicable'
/


CREATE OR REPLACE PUBLIC SYNONYM all_scheduler_job_log
  FOR all_scheduler_job_log
/
GRANT SELECT ON all_scheduler_job_log TO public WITH GRANT OPTION
/
CREATE OR REPLACE PUBLIC SYNONYM all_scheduler_job_run_details
  FOR all_scheduler_job_run_details
/
GRANT SELECT ON all_scheduler_job_run_details TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW dba_scheduler_window_log
  ( LOG_ID, LOG_DATE, WINDOW_NAME, OPERATION, STATUS, USER_NAME, CLIENT_ID, 
    GLOBAL_UID, ADDITIONAL_INFO)
  AS 
  (SELECT
        LOG_ID, LOG_DATE, NAME, OPERATION, STATUS, USER_NAME, CLIENT_ID, 
        GUID, ADDITIONAL_INFO
  FROM scheduler$_event_log 
  WHERE type# = 69)
/
COMMENT ON TABLE dba_scheduler_window_log IS
'Logged information for all scheduler windows'
/
COMMENT ON COLUMN dba_scheduler_window_log.log_id IS
'The unique id of the log entry'
/
COMMENT ON COLUMN dba_scheduler_window_log.log_date IS
'The date of this log entry'
/
COMMENT ON COLUMN dba_scheduler_window_log.window_name IS
'The name of the scheduler window'
/
COMMENT ON COLUMN dba_scheduler_window_log.operation IS
'The operation corresponding to this log entry'
/
COMMENT ON COLUMN dba_scheduler_window_log.status IS
'The status of the operation, if applicable'
/
COMMENT ON COLUMN dba_scheduler_window_log.user_name IS
'The name of the user who performed the operation, if applicable'
/
COMMENT ON COLUMN dba_scheduler_window_log.client_id IS
'The client id of the user who performed the operation, if applicable'
/
COMMENT ON COLUMN dba_scheduler_window_log.global_uid IS
'The global_uid of the user who performed the operation, if applicable'
/
COMMENT ON COLUMN dba_scheduler_window_log.additional_info IS
'Additional information on this entry, if applicable'
/

CREATE OR REPLACE VIEW dba_scheduler_window_details
  ( LOG_ID, LOG_DATE, WINDOW_NAME, REQ_START_DATE, 
    ACTUAL_START_DATE, WINDOW_DURATION, ACTUAL_DURATION, INSTANCE_ID, 
    ADDITIONAL_INFO)
  AS
  (SELECT
        w.LOG_ID, w.LOG_DATE, e.NAME, w.REQ_START_DATE, w.START_DATE,
        w.DURATION, w.ACTUAL_DURATION, w.INSTANCE_ID, w.ADDITIONAL_INFO
  FROM scheduler$_window_details w, scheduler$_event_log e
  WHERE e.log_id = w.log_id
  AND e.type# = 69) 
/
COMMENT ON TABLE dba_scheduler_window_details IS
'The details of a window'
/
COMMENT ON COLUMN dba_scheduler_window_details.log_id IS
'The unique id of the log entry. Foreign key on entry in dba_scheduler_window_log'
/
COMMENT ON COLUMN dba_scheduler_window_details.log_date IS
'The date of the log entry'
/
COMMENT ON COLUMN dba_scheduler_window_details.window_name IS
'The name of the scheduler window'
/
COMMENT ON COLUMN dba_scheduler_window_details.req_start_date IS
'The requested start date for the scheduler window'
/
COMMENT ON COLUMN dba_scheduler_window_details.actual_start_date IS
'The date the scheduler window actually started'
/
COMMENT ON COLUMN dba_scheduler_window_details.window_duration IS
'The original duration of the scheduler window'
/
COMMENT ON COLUMN dba_scheduler_window_details.actual_duration IS
'The actual duration for which the scheduler window lasted'
/
COMMENT ON COLUMN dba_scheduler_window_details.instance_id IS
'The id of the instance on which this window ran'
/
COMMENT ON COLUMN dba_scheduler_window_details.additional_info IS
'Additional information on this entry, if applicable'
/

CREATE OR REPLACE PUBLIC SYNONYM dba_scheduler_window_log
  FOR dba_scheduler_window_log
/
GRANT SELECT ON dba_scheduler_window_log TO select_catalog_role
/
CREATE OR REPLACE PUBLIC SYNONYM dba_scheduler_window_details
  FOR dba_scheduler_window_details
/
GRANT SELECT ON dba_scheduler_window_details TO select_catalog_role
/

CREATE OR REPLACE VIEW all_scheduler_window_log AS
  SELECT * FROM dba_scheduler_window_log
/
COMMENT ON TABLE all_scheduler_window_log IS
'Logged information for all scheduler windows'
/
COMMENT ON COLUMN all_scheduler_window_log.log_id IS
'The unique id of the log entry'
/
COMMENT ON COLUMN all_scheduler_window_log.log_date IS
'The date of this log entry'
/
COMMENT ON COLUMN all_scheduler_window_log.window_name IS
'The name of the scheduler window'
/
COMMENT ON COLUMN all_scheduler_window_log.operation IS
'The operation corresponding to this log entry'
/
COMMENT ON COLUMN all_scheduler_window_log.status IS
'The status of the operation, if applicable'
/
COMMENT ON COLUMN all_scheduler_window_log.user_name IS
'The name of the user who performed the operation, if applicable'
/
COMMENT ON COLUMN all_scheduler_window_log.client_id IS
'The client id of the user who performed the operation, if applicable'
/
COMMENT ON COLUMN all_scheduler_window_log.global_uid IS
'The global_uid of the user who performed the operation, if applicable'
/
COMMENT ON COLUMN all_scheduler_window_log.additional_info IS
'Additional information on this entry, if applicable'
/

CREATE OR REPLACE VIEW all_scheduler_window_details AS
  SELECT * FROM dba_scheduler_window_details
/
COMMENT ON TABLE all_scheduler_window_details IS
'The details of a window'
/
COMMENT ON COLUMN all_scheduler_window_details.log_id IS
'The unique id of the log entry. Foreign key on entry in dba_scheduler_window_log'
/
COMMENT ON COLUMN all_scheduler_window_details.log_date IS
'The date of the log entry'
/
COMMENT ON COLUMN all_scheduler_window_details.window_name IS
'The name of the scheduler window'
/
COMMENT ON COLUMN all_scheduler_window_details.req_start_date IS
'The requested start date for the scheduler window'
/
COMMENT ON COLUMN all_scheduler_window_details.actual_start_date IS
'The date the scheduler window actually started'
/
COMMENT ON COLUMN all_scheduler_window_details.window_duration IS
'The original duration of the scheduler window'
/
COMMENT ON COLUMN all_scheduler_window_details.actual_duration IS
'The actual duration for which the scheduler window lasted'
/
COMMENT ON COLUMN all_scheduler_window_details.instance_id IS
'The id of the instance on which this window ran'
/
COMMENT ON COLUMN all_scheduler_window_details.additional_info IS
'Additional information on this entry, if applicable'
/

CREATE OR REPLACE PUBLIC SYNONYM all_scheduler_window_log
  FOR all_scheduler_window_log
/
GRANT SELECT ON all_scheduler_window_log TO public WITH GRANT OPTION
/
CREATE OR REPLACE PUBLIC SYNONYM all_scheduler_window_details
  FOR all_scheduler_window_details
/
GRANT SELECT ON all_scheduler_window_details TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW dba_scheduler_window_groups
  ( WINDOW_GROUP_NAME, ENABLED, NUMBER_OF_WINDOWS, NEXT_START_DATE, COMMENTS )
  AS SELECT o.name, DECODE(BITAND(w.flags,1),0,'FALSE',1,'TRUE'),
    (SELECT COUNT(*) FROM scheduler$_wingrp_member wg WHERE wg.oid = w.obj#),
    DECODE(BITAND(w.flags,1),0,'NULL',1,
     (SELECT min(next_start_date) FROM scheduler$_window win WHERE win.obj# IN
      (SELECT wgm.member_oid FROM scheduler$_wingrp_member wgm 
        WHERE wgm.oid = w.obj#) AND bitand(win.flags, 1) = 1)),
    w.comments 
  FROM obj$ o, scheduler$_window_group w WHERE o.obj# = w.obj#
/
COMMENT ON TABLE dba_scheduler_window_groups IS
'All scheduler window groups in the database'
/
COMMENT ON COLUMN dba_scheduler_window_groups.window_group_name IS
'Name of the window group'
/
COMMENT ON COLUMN dba_scheduler_window_groups.enabled IS
'Whether the window group is enabled'
/
COMMENT ON COLUMN dba_scheduler_window_groups.number_of_windows IS
'Number of members in this window group'
/
COMMENT ON COLUMN dba_scheduler_window_groups.next_start_date IS
'Next start date of this window group'
/
COMMENT ON COLUMN dba_scheduler_window_groups.comments IS
'An optional comment about this window group'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_scheduler_window_groups
  FOR dba_scheduler_window_groups
/
GRANT SELECT ON dba_scheduler_window_groups TO select_catalog_role
/

CREATE OR REPLACE VIEW all_scheduler_window_groups as
  SELECT * FROM dba_scheduler_window_groups
/
COMMENT ON TABLE all_scheduler_window_groups IS
'All scheduler window groups in the database'
/
COMMENT ON COLUMN all_scheduler_window_groups.window_group_name IS
'Name of the window group'
/
COMMENT ON COLUMN all_scheduler_window_groups.enabled IS
'Whether the window group is enabled'
/
COMMENT ON COLUMN all_scheduler_window_groups.number_of_windows IS
'Number of members in this window group'
/
COMMENT ON COLUMN all_scheduler_window_groups.next_start_date IS
'Next start date of this window group'
/
COMMENT ON COLUMN all_scheduler_window_groups.comments IS
'An optional comment about this window group'
/
CREATE OR REPLACE PUBLIC SYNONYM all_scheduler_window_groups
  FOR all_scheduler_window_groups
/
GRANT SELECT ON all_scheduler_window_groups TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW dba_scheduler_wingroup_members
  ( WINDOW_GROUP_NAME, WINDOW_NAME)
  AS SELECT o.name, wmo.name 
  FROM obj$ o, obj$ wmo, scheduler$_wingrp_member wg
  WHERE o.type# = 72 AND o.obj# = wg.oid AND wg.member_oid = wmo.obj#
/
COMMENT ON TABLE dba_scheduler_wingroup_members IS
'Members of all scheduler window groups in the database'
/
COMMENT ON COLUMN dba_scheduler_wingroup_members.window_group_name IS
'Name of the window group'
/
COMMENT ON COLUMN dba_scheduler_wingroup_members.window_name IS
'Name of the window member of this window group'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_scheduler_wingroup_members
  FOR dba_scheduler_wingroup_members
/
GRANT SELECT ON dba_scheduler_wingroup_members TO select_catalog_role
/

CREATE OR REPLACE VIEW all_scheduler_wingroup_members AS
  SELECT * FROM dba_scheduler_wingroup_members
/
COMMENT ON TABLE all_scheduler_wingroup_members IS
'Members of all scheduler window groups in the database'
/
COMMENT ON COLUMN all_scheduler_wingroup_members.window_group_name IS
'Name of the window group'
/
COMMENT ON COLUMN all_scheduler_wingroup_members.window_name IS
'Name of the window member of this window group'
/
CREATE OR REPLACE PUBLIC SYNONYM all_scheduler_wingroup_members
  FOR all_scheduler_wingroup_members
/
GRANT SELECT ON all_scheduler_wingroup_members TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW dba_scheduler_schedules
  (OWNER,SCHEDULE_NAME,SCHEDULE_TYPE,START_DATE,REPEAT_INTERVAL,
   EVENT_QUEUE_OWNER,EVENT_QUEUE_NAME, EVENT_QUEUE_AGENT, 
   EVENT_CONDITION, END_DATE, COMMENTS)
  AS SELECT su.name, so.name, 
    (CASE WHEN s.recurrence_expr is null THEN 'ONCE'
       ELSE DECODE(BITAND(s.flags,4),0,'CALENDAR',4,'EVENT',NULL) END),
    s.reference_date, 
    decode(bitand(s.flags,4+8), 0, recurrence_expr,null), 
    s.queue_owner, s.queue_name, s.queue_agent, 
    DECODE(BITAND(s.flags, 4+8), 4, s.recurrence_expr,null),
    s.end_date, s.comments
  FROM obj$ so, user$ su, sys.scheduler$_schedule s
  WHERE s.obj# = so.obj# AND so.owner# = su.user#
/
COMMENT ON TABLE dba_scheduler_schedules IS
'All schedules in the database'
/
COMMENT ON COLUMN dba_scheduler_schedules.owner IS
'Owner of the schedule'
/
COMMENT ON COLUMN dba_scheduler_schedules.schedule_name IS
'Name of the schedule'
/
COMMENT ON COLUMN dba_scheduler_schedules.schedule_type IS
'Type of the schedule'
/
COMMENT ON COLUMN dba_scheduler_schedules.repeat_interval IS
'Calendar syntax expression for this schedule'
/
COMMENT ON COLUMN dba_scheduler_schedules.event_queue_owner IS
'Owner of source queue into which event will be raised'
/
COMMENT ON COLUMN dba_scheduler_schedules.event_queue_name IS
'Name of source queue into which event will be raised'
/
COMMENT ON COLUMN dba_scheduler_schedules.event_queue_agent IS
'Name of AQ agent used by user on the event source queue (if it is a secure queue)'
/
COMMENT ON COLUMN dba_scheduler_schedules.event_condition IS
'Boolean expression used as subscription rule for event on the source queue'
/
COMMENT ON COLUMN dba_scheduler_schedules.start_date IS
'Start date for the repeat interval'
/
COMMENT ON COLUMN dba_scheduler_schedules.comments IS
'Comments on this schedule'
/
COMMENT ON COLUMN dba_scheduler_schedules.end_date IS
'Cutoff date after which the schedule will not specify any dates'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_scheduler_schedules
  FOR dba_scheduler_schedules
/
GRANT SELECT ON dba_scheduler_schedules TO select_catalog_role
/

CREATE OR REPLACE VIEW user_scheduler_schedules
  (SCHEDULE_NAME,SCHEDULE_TYPE,START_DATE,REPEAT_INTERVAL,
   EVENT_QUEUE_OWNER, EVENT_QUEUE_NAME, EVENT_QUEUE_AGENT, EVENT_CONDITION, 
   END_DATE, COMMENTS)
  AS SELECT so.name, 
    (CASE WHEN s.recurrence_expr is null THEN 'ONCE'
       ELSE DECODE(BITAND(s.flags,4),0,'CALENDAR',4,'EVENT',NULL) END),
    s.reference_date, 
    decode(bitand(s.flags,4+8), 0, recurrence_expr,null), 
    s.queue_owner, s.queue_name, s.queue_agent, 
    DECODE(BITAND(s.flags, 4+8), 4, s.recurrence_expr,null),
    s.end_date, s.comments
  FROM sys.scheduler$_schedule s, obj$ so
  WHERE s.obj# = so.obj#  AND so.owner# = USERENV('SCHEMAID')
/
COMMENT ON TABLE user_scheduler_schedules IS
'Schedules belonging to the current user'
/
COMMENT ON COLUMN user_scheduler_schedules.schedule_name IS
'Name of the schedule'
/
COMMENT ON COLUMN user_scheduler_schedules.schedule_type IS
'Type of the schedule'
/
COMMENT ON COLUMN user_scheduler_schedules.repeat_interval IS
'Calendar syntax expression for this schedule'
/
COMMENT ON COLUMN user_scheduler_schedules.event_queue_owner IS
'Owner of source queue into which event will be raised'
/
COMMENT ON COLUMN user_scheduler_schedules.event_queue_name IS
'Name of source queue into which event will be raised'
/
COMMENT ON COLUMN user_scheduler_schedules.event_queue_agent IS
'Name of AQ agent used by user on the event source queue (if it is a secure queue)'
/
COMMENT ON COLUMN user_scheduler_schedules.event_condition IS
'Boolean expression used as subscription rule for event on the source queue'
/
COMMENT ON COLUMN user_scheduler_schedules.start_date IS
'Start date for the repeat interval'
/
COMMENT ON COLUMN user_scheduler_schedules.comments IS
'Comments on this schedule'
/
COMMENT ON COLUMN user_scheduler_schedules.end_date IS
'Cutoff date after which the schedule will not specify any dates'
/
CREATE OR REPLACE PUBLIC SYNONYM user_scheduler_schedules
  FOR user_scheduler_schedules
/
GRANT SELECT ON user_scheduler_schedules TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW all_scheduler_schedules AS
  SELECT * FROM dba_scheduler_schedules
/
COMMENT ON TABLE all_scheduler_schedules IS
'All schedules in the database'
/
COMMENT ON COLUMN all_scheduler_schedules.owner IS
'Owner of the schedule'
/
COMMENT ON COLUMN all_scheduler_schedules.schedule_name IS
'Name of the schedule'
/
/
COMMENT ON COLUMN all_scheduler_schedules.schedule_type IS
'Type of the schedule'
/
COMMENT ON COLUMN all_scheduler_schedules.repeat_interval IS
'Calendar syntax expression for this schedule'
/
COMMENT ON COLUMN all_scheduler_schedules.event_queue_owner IS
'Owner of source queue into which event will be raised'
/
COMMENT ON COLUMN all_scheduler_schedules.event_queue_name IS
'Name of source queue into which event will be raised'
/
COMMENT ON COLUMN all_scheduler_schedules.event_queue_agent IS
'Name of AQ agent used by user on the event source queue (if it is a secure queue)'
/
COMMENT ON COLUMN all_scheduler_schedules.event_condition IS
'Boolean expression used as subscription rule for event on the source queue'
/
COMMENT ON COLUMN all_scheduler_schedules.start_date IS
'Start date for the repeat interval'
/
COMMENT ON COLUMN all_scheduler_schedules.comments IS
'Comments on this schedule'
/
COMMENT ON COLUMN all_scheduler_schedules.end_date IS
'Cutoff date after which the schedule will not specify any dates'
/
CREATE OR REPLACE PUBLIC SYNONYM all_scheduler_schedules
  FOR all_scheduler_schedules
/
GRANT SELECT ON all_scheduler_schedules TO public WITH GRANT OPTION
/

/* scheduler running jobs views */
CREATE OR REPLACE VIEW dba_scheduler_running_jobs
   ( OWNER, JOB_NAME, JOB_SUBNAME, SESSION_ID, SLAVE_PROCESS_ID,
     SLAVE_OS_PROCESS_ID, 
     RUNNING_INSTANCE, RESOURCE_CONSUMER_GROUP, ELAPSED_TIME, CPU_USED)
  AS SELECT ju.name, jo.name, jo.subname, rj.session_id, vp.pid, 
      rj.os_process_id, rj.inst_id, vse.resource_consumer_group, 
      CAST (systimestamp-j.last_start_date AS INTERVAL DAY(3) TO SECOND(2)), 
      rj.session_stat_cpu
  FROM
      scheduler$_job j JOIN obj$ jo ON (j.obj# = jo.obj#)
      JOIN user$ ju ON (jo.owner# = ju.user#)
      LEFT OUTER JOIN gv$scheduler_running_jobs rj ON (rj.job_id = j.obj#)
      LEFT OUTER JOIN gv$session vse ON
        (rj.session_id = vse.sid AND rj.session_serial_num = vse.serial#)
      LEFT OUTER JOIN gv$process vp ON 
        (rj.paddr = vp.addr AND rj.inst_id = vp.inst_id)
  WHERE BITAND(j.job_status,2) = 2
/

CREATE OR REPLACE PUBLIC SYNONYM dba_scheduler_running_jobs
  FOR dba_scheduler_running_jobs
/
GRANT SELECT ON dba_scheduler_running_jobs TO select_catalog_role
/
COMMENT ON COLUMN dba_scheduler_running_jobs.owner IS
'Owner of the running scheduler job'
/
COMMENT ON COLUMN dba_scheduler_running_jobs.job_name IS
'Name of the running scheduler job'
/
COMMENT ON COLUMN dba_scheduler_running_jobs.job_subname IS
'Subname of the running scheduler job (for a job running a chain step)'
/
COMMENT ON COLUMN dba_scheduler_running_jobs.slave_process_id IS
'Process number of the slave process running the scheduler job'
/
COMMENT ON COLUMN dba_scheduler_running_jobs.slave_os_process_id IS
'Operating system process number of the slave process running the scheduler job'
/
COMMENT ON COLUMN dba_scheduler_running_jobs.running_instance IS
'Database instance number of the slave process running the scheduler job'
/
COMMENT ON COLUMN dba_scheduler_running_jobs.resource_consumer_group IS
'Resource consumer group of the session in which the scheduler job is running'
/
COMMENT ON COLUMN dba_scheduler_running_jobs.elapsed_time IS
'Time elapsed since the scheduler job started'
/
COMMENT ON COLUMN dba_scheduler_running_jobs.cpu_used IS
'CPU time used by the running scheduler job, if available'
/

CREATE OR REPLACE VIEW all_scheduler_running_jobs
   ( OWNER, JOB_NAME, JOB_SUBNAME, SESSION_ID, SLAVE_PROCESS_ID,
     SLAVE_OS_PROCESS_ID,
     RUNNING_INSTANCE, RESOURCE_CONSUMER_GROUP, ELAPSED_TIME, CPU_USED)
  AS SELECT ju.name, jo.name, jo.subname, rj.session_id, vp.pid, 
      rj.os_process_id, rj.inst_id, vse.resource_consumer_group,
      CAST (systimestamp-j.last_start_date AS INTERVAL DAY(3) TO SECOND(2)), 
      rj.session_stat_cpu
  FROM
      scheduler$_job j JOIN obj$ jo ON (j.obj# = jo.obj#)
      JOIN user$ ju ON (jo.owner# = ju.user# AND
        (jo.owner# = userenv('SCHEMAID')
         or jo.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
         or /* user has system privileges */
           (exists (select null from v$enabledprivs
                 where priv_number  = -265 /* CREATE ANY JOB */
                )
            and jo.owner#!=0)
        )
      )
      LEFT OUTER JOIN gv$scheduler_running_jobs rj ON (rj.job_id = j.obj#)
      LEFT OUTER JOIN gv$session vse ON
        (rj.session_id = vse.sid AND rj.session_serial_num = vse.serial#)
      LEFT OUTER JOIN gv$process vp ON 
        (rj.paddr = vp.addr AND rj.inst_id = vp.inst_id)
  WHERE BITAND(j.job_status,2) = 2
/

CREATE OR REPLACE PUBLIC SYNONYM all_scheduler_running_jobs
  FOR all_scheduler_running_jobs
/
GRANT SELECT ON all_scheduler_running_jobs TO public
/
COMMENT ON COLUMN all_scheduler_running_jobs.owner IS
'Owner of the running scheduler job'
/
COMMENT ON COLUMN all_scheduler_running_jobs.job_name IS
'Name of the running scheduler job'
/
COMMENT ON COLUMN all_scheduler_running_jobs.job_subname IS
'Subname of the running scheduler job (for a job running a chain step)'
/
COMMENT ON COLUMN all_scheduler_running_jobs.slave_process_id IS
'Process number of the slave process running the scheduler job'
/
COMMENT ON COLUMN all_scheduler_running_jobs.slave_os_process_id IS
'Operating system process number of the slave process running the scheduler job'
/
COMMENT ON COLUMN all_scheduler_running_jobs.running_instance IS
'Database instance number of the slave process running the scheduler job'
/
COMMENT ON COLUMN all_scheduler_running_jobs.resource_consumer_group IS
'Resource consumer group of the session in which the scheduler job is running'
/
COMMENT ON COLUMN dba_scheduler_running_jobs.elapsed_time IS
'Time elapsed since the scheduler job started'
/
COMMENT ON COLUMN dba_scheduler_running_jobs.cpu_used IS
'CPU time used by the running scheduler job, if available'
/
/* scheduler running jobs views */
CREATE OR REPLACE VIEW user_scheduler_running_jobs
   ( JOB_NAME, JOB_SUBNAME, SESSION_ID, SLAVE_PROCESS_ID, SLAVE_OS_PROCESS_ID,
     RUNNING_INSTANCE, RESOURCE_CONSUMER_GROUP, ELAPSED_TIME, CPU_USED)
  AS SELECT jo.name, jo.subname, rj.session_id, vp.pid, rj.os_process_id, 
      rj.inst_id, vse.resource_consumer_group, 
      CAST (systimestamp-j.last_start_date AS INTERVAL DAY(3) TO SECOND(2)), 
      rj.session_stat_cpu
  FROM
      scheduler$_job j JOIN obj$ jo ON
        (j.obj# = jo.obj# AND jo.owner# = USERENV('SCHEMAID'))
      LEFT OUTER JOIN gv$scheduler_running_jobs rj ON (rj.job_id = j.obj#)
      LEFT OUTER JOIN gv$session vse ON
        (rj.session_id = vse.sid AND rj.session_serial_num = vse.serial#)
      LEFT OUTER JOIN gv$process vp ON 
        (rj.paddr = vp.addr AND rj.inst_id = vp.inst_id)
  WHERE BITAND(j.job_status,2) = 2
/

CREATE OR REPLACE PUBLIC SYNONYM user_scheduler_running_jobs
  FOR user_scheduler_running_jobs
/
GRANT SELECT ON user_scheduler_running_jobs TO public
/
COMMENT ON COLUMN user_scheduler_running_jobs.job_name IS
'Name of the running scheduler job'
/
COMMENT ON COLUMN user_scheduler_running_jobs.job_subname IS
'Subname of the running scheduler job (for a job running a chain step)'
/
COMMENT ON COLUMN user_scheduler_running_jobs.slave_process_id IS
'Process number of the slave process running the scheduler job'
/
COMMENT ON COLUMN user_scheduler_running_jobs.slave_os_process_id IS
'Operating system process number of the slave process running the scheduler job'
/
COMMENT ON COLUMN user_scheduler_running_jobs.running_instance IS
'Database instance number of the slave process running the scheduler job'
/
COMMENT ON COLUMN user_scheduler_running_jobs.resource_consumer_group IS
'Resource consumer group of the session in which the scheduler job is running'
/
COMMENT ON COLUMN dba_scheduler_running_jobs.elapsed_time IS
'Time elapsed since the scheduler job started'
/
COMMENT ON COLUMN dba_scheduler_running_jobs.cpu_used IS
'CPU time used by the running scheduler job, if available'
/


CREATE OR REPLACE VIEW dba_scheduler_global_attribute
 (ATTRIBUTE_NAME, VALUE) AS
 SELECT o.name, a.value
 FROM sys.obj$ o, sys.scheduler$_global_attribute a
 WHERE o.obj# = a.obj#
/

COMMENT ON TABLE dba_scheduler_global_attribute IS
'All scheduler global attributes'
/

COMMENT ON COLUMN dba_scheduler_global_attribute.attribute_name IS
'Name of the scheduler global attribute'
/

COMMENT ON COLUMN dba_scheduler_global_attribute.value IS
'Value of the scheduler global attribute'
/

CREATE OR REPLACE PUBLIC SYNONYM dba_scheduler_global_attribute
  FOR dba_scheduler_global_attribute
/
GRANT SELECT ON dba_scheduler_global_attribute TO select_catalog_role
/

CREATE OR REPLACE VIEW all_scheduler_global_attribute
 (ATTRIBUTE_NAME, VALUE) AS
 SELECT o.name, a.value
 FROM sys.obj$ o, sys.scheduler$_global_attribute a
 WHERE o.obj# = a.obj#
/

COMMENT ON TABLE all_scheduler_global_attribute IS
'All scheduler global attributes'
/

COMMENT ON COLUMN all_scheduler_global_attribute.attribute_name IS
'Name of the scheduler global attribute'
/

COMMENT ON COLUMN all_scheduler_global_attribute.value IS
'Value of the scheduler global attribute'
/

CREATE OR REPLACE PUBLIC SYNONYM all_scheduler_global_attribute
  FOR all_scheduler_global_attribute
/
GRANT SELECT ON all_scheduler_global_attribute TO public WITH GRANT OPTION
/

-- chain views
CREATE OR REPLACE VIEW dba_scheduler_chains
  (OWNER, CHAIN_NAME, RULE_SET_OWNER, RULE_SET_NAME,
   NUMBER_OF_RULES, NUMBER_OF_STEPS, ENABLED, EVALUATION_INTERVAL,
   USER_RULE_SET, COMMENTS) AS
  SELECT u.name, o.name, c.rule_set_owner, c.rule_set,
  (SELECT count(*) FROM rule_map$ rm, obj$ rmo, user$ rmu
     WHERE rm.rs_obj# = rmo.obj# AND rmo.owner# = rmu.user#
     AND rmu.name = c.rule_set_owner and rmo.name = c.rule_set),
  (SELECT COUNT(*) FROM sys.scheduler$_step cs
     WHERE cs.oid = c.obj#),
  DECODE(BITAND(c.flags,1),0,'FALSE',1,'TRUE'), c.eval_interval,
  DECODE(BITAND(c.flags,2),2,'FALSE',0,'TRUE'),
  c.comments
  FROM obj$ o, user$ u, sys.scheduler$_chain c
  WHERE c.obj# = o.obj# AND u.user# = o.owner#
/
COMMENT ON TABLE dba_scheduler_chains IS
'All scheduler chains in the database'
/
COMMENT ON COLUMN dba_scheduler_chains.chain_name IS
'Name of the scheduler chain'
/
COMMENT ON COLUMN dba_scheduler_chains.owner IS
'Owner of the scheduler chain'
/
COMMENT ON COLUMN dba_scheduler_chains.rule_set_name IS
'Name of the associated rule set'
/
COMMENT ON COLUMN dba_scheduler_chains.rule_set_owner IS
'Owner of the associated rule set'
/
COMMENT ON COLUMN dba_scheduler_chains.number_of_rules IS
'Number of rules in this chain'
/
COMMENT ON COLUMN dba_scheduler_chains.number_of_steps IS
'Number of defined steps in this chain'
/
COMMENT ON COLUMN dba_scheduler_chains.enabled IS
'Whether the chain is enabled'
/
COMMENT ON COLUMN dba_scheduler_chains.evaluation_interval IS
'Periodic interval at which to reevaluate rules for this chain'
/
COMMENT ON COLUMN dba_scheduler_chains.user_rule_set IS
'Whether the chain uses a user-specified rule set'
/
COMMENT ON COLUMN dba_scheduler_chains.comments IS
'Comments on the chain'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_scheduler_chains
  FOR dba_scheduler_chains
/
GRANT SELECT ON dba_scheduler_chains TO select_catalog_role
/

CREATE OR REPLACE VIEW user_scheduler_chains
  (CHAIN_NAME, RULE_SET_OWNER, RULE_SET_NAME,
   NUMBER_OF_RULES, NUMBER_OF_STEPS, ENABLED, EVALUATION_INTERVAL,
   USER_RULE_SET, COMMENTS) AS
  SELECT o.name, c.rule_set_owner, c.rule_set,
  (SELECT count(*) FROM rule_map$ rm, obj$ rmo, user$ rmu
     WHERE rm.rs_obj# = rmo.obj# AND rmo.owner# = rmu.user#
     AND rmu.name = c.rule_set_owner and rmo.name = c.rule_set),
  (SELECT COUNT(*) FROM sys.scheduler$_step cs
     WHERE cs.oid = c.obj#),
  DECODE(BITAND(c.flags,1),0,'FALSE',1,'TRUE'), c.eval_interval,
  DECODE(BITAND(c.flags,2),2,'FALSE',0,'TRUE'),
  c.comments
  FROM obj$ o, sys.scheduler$_chain c
  WHERE c.obj# = o.obj# AND o.owner# = USERENV('SCHEMAID')
/
COMMENT ON TABLE user_scheduler_chains IS
'All scheduler chains owned by the current user'
/
COMMENT ON COLUMN user_scheduler_chains.chain_name IS
'Name of the scheduler chain'
/
COMMENT ON COLUMN user_scheduler_chains.rule_set_name IS
'Name of the associated rule set'
/
COMMENT ON COLUMN user_scheduler_chains.rule_set_owner IS
'Owner of the associated rule set'
/
COMMENT ON COLUMN user_scheduler_chains.number_of_rules IS
'Number of rules in this chain'
/
COMMENT ON COLUMN user_scheduler_chains.number_of_steps IS
'Number of defined steps in this chain'
/
COMMENT ON COLUMN user_scheduler_chains.enabled IS
'Whether the chain is enabled'
/
COMMENT ON COLUMN user_scheduler_chains.evaluation_interval IS
'Periodic interval at which to reevaluate rules for this chain'
/
COMMENT ON COLUMN user_scheduler_chains.user_rule_set IS
'Whether the chain uses a user-specified rule set'
/
COMMENT ON COLUMN user_scheduler_chains.comments IS
'Comments on the chain'
/
CREATE OR REPLACE PUBLIC SYNONYM user_scheduler_chains
  FOR user_scheduler_chains
/
GRANT SELECT ON user_scheduler_chains TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW all_scheduler_chains
  (OWNER, CHAIN_NAME, RULE_SET_OWNER, RULE_SET_NAME,
   NUMBER_OF_RULES, NUMBER_OF_STEPS, ENABLED, EVALUATION_INTERVAL,
   USER_RULE_SET, COMMENTS) AS
  SELECT u.name, o.name, c.rule_set_owner, c.rule_set,
  (SELECT count(*) FROM rule_map$ rm, obj$ rmo, user$ rmu
     WHERE rm.rs_obj# = rmo.obj# AND rmo.owner# = rmu.user#
     AND rmu.name = c.rule_set_owner and rmo.name = c.rule_set),
  (SELECT COUNT(*) FROM sys.scheduler$_step cs
     WHERE cs.oid = c.obj#),
  DECODE(BITAND(c.flags,1),0,'FALSE',1,'TRUE'), c.eval_interval,
  DECODE(BITAND(c.flags,2),2,'FALSE',0,'TRUE'),
  c.comments
  FROM obj$ o, user$ u, sys.scheduler$_chain c
  WHERE c.obj# = o.obj# AND u.user# = o.owner# AND
    (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         (exists (select null from v$enabledprivs
                 where priv_number in (-265 /* CREATE ANY JOB */,
                                       -266 /* EXECUTE ANY PROGRAM */ )
                 )
          and o.owner#!=0)
      )
/
COMMENT ON TABLE all_scheduler_chains IS
'All scheduler chains in the database visible to current user'
/
COMMENT ON COLUMN all_scheduler_chains.chain_name IS
'Name of the scheduler chain'
/
COMMENT ON COLUMN all_scheduler_chains.owner IS
'Owner of the scheduler chain'
/
COMMENT ON COLUMN all_scheduler_chains.rule_set_name IS
'Name of the associated rule set'
/
COMMENT ON COLUMN all_scheduler_chains.rule_set_owner IS
'Owner of the associated rule set'
/
COMMENT ON COLUMN all_scheduler_chains.number_of_rules IS
'Number of rules in this chain'
/
COMMENT ON COLUMN all_scheduler_chains.number_of_steps IS
'Number of defined steps in this chain'
/
COMMENT ON COLUMN all_scheduler_chains.enabled IS
'Whether the chain is enabled'
/
COMMENT ON COLUMN all_scheduler_chains.evaluation_interval IS
'Periodic interval at which to reevaluate rules for this chain'
/
COMMENT ON COLUMN all_scheduler_chains.user_rule_set IS
'Whether the chain uses a user-specified rule set'
/
COMMENT ON COLUMN all_scheduler_chains.comments IS
'Comments on the chain'
/
CREATE OR REPLACE PUBLIC SYNONYM all_scheduler_chains
  FOR all_scheduler_chains
/
GRANT SELECT ON all_scheduler_chains TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW dba_scheduler_chain_rules
  (OWNER, CHAIN_NAME, RULE_OWNER, RULE_NAME,
   CONDITION, ACTION, COMMENTS) AS
  SELECT cu.name, co.name, ru.name, ro.name,
         dbms_scheduler.get_chain_rule_condition(r.r_action, r.condition),
         dbms_scheduler.get_chain_rule_action(r.r_action), r.r_comment
  FROM rule_map$ rm, obj$ rso, user$ rsu, obj$ ro, user$ ru, rule$ r,
     obj$ co, user$ cu, sys.scheduler$_chain c
  WHERE c.obj# = co.obj# AND co.owner# = cu.user#
     AND c.rule_set_owner = rsu.name(+) AND rsu.user# = rso.owner#
     AND c.rule_set = rso.name
     AND rso.obj# = rm.rs_obj#(+)
     AND rm.r_obj# = r.obj#(+)
     AND rm.r_obj# = ro.obj#(+) AND ro.owner# = ru.user#
/
COMMENT ON TABLE dba_scheduler_chain_rules IS
'All rules from scheduler chains in the database'
/
COMMENT ON COLUMN dba_scheduler_chain_rules.chain_name IS
'Name of the scheduler chain the rule is in'
/
COMMENT ON COLUMN dba_scheduler_chain_rules.owner IS
'Owner of the scheduler chain the rule is in'
/
COMMENT ON COLUMN dba_scheduler_chain_rules.rule_name IS
'Name of the rule'
/
COMMENT ON COLUMN dba_scheduler_chain_rules.condition IS
'Boolean condition triggering the rule'
/
COMMENT ON COLUMN dba_scheduler_chain_rules.action IS
'Action to be performed when the rule is triggered'
/
COMMENT ON COLUMN dba_scheduler_chain_rules.comments IS
'User-specified comments about the rule'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_scheduler_chain_rules
  FOR dba_scheduler_chain_rules
/
GRANT SELECT ON dba_scheduler_chain_rules TO select_catalog_role
/

CREATE OR REPLACE VIEW user_scheduler_chain_rules
  (CHAIN_NAME, RULE_OWNER, RULE_NAME,
   CONDITION, ACTION, COMMENTS) AS
  SELECT co.name, ru.name, ro.name,
         dbms_scheduler.get_chain_rule_condition(r.r_action, r.condition),
         dbms_scheduler.get_chain_rule_action(r.r_action), r.r_comment
  FROM rule_map$ rm, obj$ rso, user$ rsu, obj$ ro, user$ ru, rule$ r,
     obj$ co, sys.scheduler$_chain c
  WHERE c.obj# = co.obj# AND co.owner# = USERENV('SCHEMAID')
     AND c.rule_set_owner = rsu.name(+) AND rsu.user# = rso.owner#
     AND c.rule_set = rso.name
     AND rso.obj# = rm.rs_obj#(+)
     AND rm.r_obj# = r.obj#(+)
     AND rm.r_obj# = ro.obj#(+) AND ro.owner# = ru.user#
/
COMMENT ON TABLE user_scheduler_chain_rules IS
'All rules from scheduler chains owned by the current user'
/
COMMENT ON COLUMN user_scheduler_chain_rules.chain_name IS
'Name of the scheduler chain the rule is in'
/
COMMENT ON COLUMN user_scheduler_chain_rules.rule_name IS
'Name of the rule'
/
COMMENT ON COLUMN user_scheduler_chain_rules.condition IS
'Boolean condition triggering the rule'
/
COMMENT ON COLUMN user_scheduler_chain_rules.action IS
'Action to be performed when the rule is triggered'
/
COMMENT ON COLUMN user_scheduler_chain_rules.comments IS
'User-specified comments about the rule'
/
CREATE OR REPLACE PUBLIC SYNONYM user_scheduler_chain_rules
  FOR user_scheduler_chain_rules
/
GRANT SELECT ON user_scheduler_chain_rules TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW all_scheduler_chain_rules
  (OWNER, CHAIN_NAME, RULE_OWNER, RULE_NAME,
   CONDITION, ACTION, COMMENTS) AS
  SELECT cu.name, co.name, ru.name, ro.name,
         dbms_scheduler.get_chain_rule_condition(r.r_action, r.condition),
         dbms_scheduler.get_chain_rule_action(r.r_action), r.r_comment
  FROM rule_map$ rm, obj$ rso, user$ rsu, obj$ ro, user$ ru, rule$ r,
     obj$ co, user$ cu, sys.scheduler$_chain c
  WHERE c.obj# = co.obj# AND co.owner# = cu.user#
     AND c.rule_set_owner = rsu.name(+) AND rsu.user# = rso.owner#
     AND c.rule_set = rso.name
     AND rso.obj# = rm.rs_obj#(+)
     AND rm.r_obj# = r.obj#(+)
     AND rm.r_obj# = ro.obj#(+) AND ro.owner# = ru.user# AND
    (co.owner# = userenv('SCHEMAID')
       or co.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         (exists (select null from v$enabledprivs
                 where priv_number in (-265 /* CREATE ANY JOB */,
                                       -266 /* EXECUTE ANY PROGRAM */ )
                 )
          and co.owner#!=0)
      )
/
COMMENT ON TABLE all_scheduler_chain_rules IS
'All rules from scheduler chains visible to the current user'
/
COMMENT ON COLUMN all_scheduler_chain_rules.chain_name IS
'Name of the scheduler chain the rule is in'
/
COMMENT ON COLUMN all_scheduler_chain_rules.owner IS
'Owner of the scheduler chain the rule is in'
/
COMMENT ON COLUMN all_scheduler_chain_rules.rule_name IS
'Name of the rule'
/
COMMENT ON COLUMN all_scheduler_chain_rules.condition IS
'Boolean condition triggering the rule'
/
COMMENT ON COLUMN all_scheduler_chain_rules.action IS
'Action to be performed when the rule is triggered'
/
COMMENT ON COLUMN all_scheduler_chain_rules.comments IS
'User-specified comments about the rule'
/
CREATE OR REPLACE PUBLIC SYNONYM all_scheduler_chain_rules
  FOR all_scheduler_chain_rules
/
GRANT SELECT ON all_scheduler_chain_rules TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW dba_scheduler_chain_steps
  (OWNER, CHAIN_NAME, STEP_NAME, PROGRAM_OWNER, PROGRAM_NAME,
   EVENT_SCHEDULE_OWNER, EVENT_SCHEDULE_NAME, EVENT_QUEUE_OWNER,
   EVENT_QUEUE_NAME, EVENT_QUEUE_AGENT, EVENT_CONDITION, SKIP, PAUSE,
   RESTART_ON_RECOVERY, STEP_TYPE, TIMEOUT)
  AS SELECT u.name, o.name, cs.var_name,
  DECODE(BITAND(cs.flags,4), 4,
    substr(cs.object_name,1,instr(cs.object_name,'"')-1), NULL),
  DECODE(BITAND(cs.flags,4), 4,
    substr(cs.object_name,instr(cs.object_name,'"')+1,
      length(cs.object_name)-instr(cs.object_name,'"')), NULL),
  DECODE(BITAND(cs.flags,8), 8,
    substr(cs.object_name,1,instr(cs.object_name,'"')-1), NULL),
  DECODE(BITAND(cs.flags,8), 8,
    substr(cs.object_name,instr(cs.object_name,'"')+1,
      length(cs.object_name)-instr(cs.object_name,'"')), NULL),
  cs.queue_owner, cs.queue_name, cs.queue_agent, cs.condition,
  DECODE(BITAND(cs.flags,1),0,'FALSE',1,'TRUE'),
  DECODE(BITAND(cs.flags,2),0,'FALSE',2,'TRUE'),
  DECODE(BITAND(cs.flags,64),0,'FALSE',64,'TRUE'),
  DECODE(BITAND(cs.flags,8+16+32),8,'EVENT_SCHEDULE',16,'INLINE_EVENT',
  32,'SUBCHAIN','PROGRAM'), cs.timeout
  FROM obj$ o, user$ u, sys.scheduler$_step cs
  WHERE cs.oid = o.obj# AND u.user# = o.owner#
/
COMMENT ON TABLE dba_scheduler_chain_steps IS
'All steps of scheduler chains in the database'
/
COMMENT ON COLUMN dba_scheduler_chain_steps.chain_name IS
'Name of the scheduler chain the step is in'
/
COMMENT ON COLUMN dba_scheduler_chain_steps.owner IS
'Owner of the scheduler chain the step is in'
/
COMMENT ON COLUMN dba_scheduler_chain_steps.step_name IS
'Name of the chain step'
/
COMMENT ON COLUMN dba_scheduler_chain_steps.program_owner IS
'Owner of the program that runs during this step'
/
COMMENT ON COLUMN dba_scheduler_chain_steps.program_name IS
'Name of the program that runs during this step'
/
COMMENT ON COLUMN dba_scheduler_chain_steps.event_schedule_owner IS
'Owner of the event schedule that this step waits for'
/
COMMENT ON COLUMN dba_scheduler_chain_steps.event_schedule_name IS
'Name of the event schedule that this step waits for'
/
COMMENT ON COLUMN dba_scheduler_chain_steps.event_queue_owner IS
'Owner of source queue into which event will be raised'
/
COMMENT ON COLUMN dba_scheduler_chain_steps.event_queue_name IS
'Name of source queue into which event will be raised'
/
COMMENT ON COLUMN dba_scheduler_chain_steps.event_queue_agent IS
'Name of AQ agent used by user on the event source queue (for a secure queue)'
/
COMMENT ON COLUMN dba_scheduler_chain_steps.event_condition IS
'Boolean expression used as the subscription rule for event on the source queue'
/
COMMENT ON COLUMN dba_scheduler_chain_steps.skip IS
'Whether this step should be skipped or not'
/
COMMENT ON COLUMN dba_scheduler_chain_steps.pause IS
'Whether this step should be paused after running or not'
/
COMMENT ON COLUMN dba_scheduler_chain_steps.restart_on_recovery IS
'Whether this step should be restarted on database recovery'
/
COMMENT ON COLUMN dba_scheduler_chain_steps.step_type IS
'Type of this step'
/
COMMENT ON COLUMN dba_scheduler_chain_steps.timeout IS
'Timeout for waiting on an event schedule'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_scheduler_chain_steps
  FOR dba_scheduler_chain_steps
/
GRANT SELECT ON dba_scheduler_chain_steps TO select_catalog_role
/

CREATE OR REPLACE VIEW user_scheduler_chain_steps
  (CHAIN_NAME, STEP_NAME, PROGRAM_OWNER, PROGRAM_NAME,
   EVENT_SCHEDULE_OWNER, EVENT_SCHEDULE_NAME, EVENT_QUEUE_OWNER,
   EVENT_QUEUE_NAME, EVENT_QUEUE_AGENT, EVENT_CONDITION, SKIP, PAUSE,
   RESTART_ON_RECOVERY, STEP_TYPE, TIMEOUT)
  AS SELECT o.name, cs.var_name,
  DECODE(BITAND(cs.flags,4), 4,
    substr(cs.object_name,1,instr(cs.object_name,'"')-1), NULL),
  DECODE(BITAND(cs.flags,4), 4,
    substr(cs.object_name,instr(cs.object_name,'"')+1,
      length(cs.object_name)-instr(cs.object_name,'"')), NULL),
  DECODE(BITAND(cs.flags,8), 8,
    substr(cs.object_name,1,instr(cs.object_name,'"')-1), NULL),
  DECODE(BITAND(cs.flags,8), 8,
    substr(cs.object_name,instr(cs.object_name,'"')+1,
      length(cs.object_name)-instr(cs.object_name,'"')), NULL),
  cs.queue_owner, cs.queue_name, cs.queue_agent, cs.condition,
  DECODE(BITAND(cs.flags,1),0,'FALSE',1,'TRUE'),
  DECODE(BITAND(cs.flags,2),0,'FALSE',2,'TRUE'),
  DECODE(BITAND(cs.flags,64),0,'FALSE',64,'TRUE'),
  DECODE(BITAND(cs.flags,8+16+32),8,'EVENT_SCHEDULE',16,'INLINE_EVENT',
  32,'SUBCHAIN','PROGRAM'), cs.timeout
  FROM obj$ o, sys.scheduler$_step cs
  WHERE cs.oid = o.obj# AND o.owner# = USERENV('SCHEMAID')
/
COMMENT ON TABLE user_scheduler_chain_steps IS
'All steps of scheduler chains owned by the current user'
/
COMMENT ON COLUMN user_scheduler_chain_steps.chain_name IS
'Name of the scheduler chain the step is in'
/
COMMENT ON COLUMN user_scheduler_chain_steps.step_name IS
'Name of the chain step'
/
COMMENT ON COLUMN user_scheduler_chain_steps.program_owner IS
'Owner of the program that runs during this step'
/
COMMENT ON COLUMN user_scheduler_chain_steps.program_name IS
'Name of the program that runs during this step'
/
COMMENT ON COLUMN user_scheduler_chain_steps.event_schedule_owner IS
'Owner of the event schedule that this step waits for'
/
COMMENT ON COLUMN user_scheduler_chain_steps.event_schedule_name IS
'Name of the event schedule that this step waits for'
/
COMMENT ON COLUMN user_scheduler_chain_steps.event_queue_owner IS
'Owner of source queue into which event will be raised'
/
COMMENT ON COLUMN user_scheduler_chain_steps.event_queue_name IS
'Name of source queue into which event will be raised'
/
COMMENT ON COLUMN user_scheduler_chain_steps.event_queue_agent IS
'Name of AQ agent used by user on the event source queue (for a secure queue)'
/
COMMENT ON COLUMN user_scheduler_chain_steps.event_condition IS
'Boolean expression used as the subscription rule for event on the source queue'
/
COMMENT ON COLUMN user_scheduler_chain_steps.skip IS
'Whether this step should be skipped or not'
/
COMMENT ON COLUMN user_scheduler_chain_steps.pause IS
'Whether this step should be paused after running or not'
/
COMMENT ON COLUMN user_scheduler_chain_steps.restart_on_recovery IS
'Whether this step should be restarted on database recovery'
/
COMMENT ON COLUMN user_scheduler_chain_steps.step_type IS
'Type of this step'
/
COMMENT ON COLUMN user_scheduler_chain_steps.timeout IS
'Timeout for waiting on an event schedule'
/
CREATE OR REPLACE PUBLIC SYNONYM user_scheduler_chain_steps
  FOR user_scheduler_chain_steps
/
GRANT SELECT ON user_scheduler_chain_steps TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW all_scheduler_chain_steps
  (OWNER, CHAIN_NAME, STEP_NAME, PROGRAM_OWNER, PROGRAM_NAME,
   EVENT_SCHEDULE_OWNER, EVENT_SCHEDULE_NAME, EVENT_QUEUE_OWNER,
   EVENT_QUEUE_NAME, EVENT_QUEUE_AGENT, EVENT_CONDITION, SKIP, PAUSE,
   RESTART_ON_RECOVERY, STEP_TYPE, TIMEOUT)
  AS SELECT u.name, o.name, cs.var_name,
  DECODE(BITAND(cs.flags,4), 4,
    substr(cs.object_name,1,instr(cs.object_name,'"')-1), NULL),
  DECODE(BITAND(cs.flags,4), 4,
    substr(cs.object_name,instr(cs.object_name,'"')+1,
      length(cs.object_name)-instr(cs.object_name,'"')), NULL),
  DECODE(BITAND(cs.flags,8), 8,
    substr(cs.object_name,1,instr(cs.object_name,'"')-1), NULL),
  DECODE(BITAND(cs.flags,8), 8,
    substr(cs.object_name,instr(cs.object_name,'"')+1,
      length(cs.object_name)-instr(cs.object_name,'"')), NULL),
  cs.queue_owner, cs.queue_name, cs.queue_agent, cs.condition,
  DECODE(BITAND(cs.flags,1),0,'FALSE',1,'TRUE'),
  DECODE(BITAND(cs.flags,2),0,'FALSE',2,'TRUE'),
  DECODE(BITAND(cs.flags,64),0,'FALSE',64,'TRUE'),
  DECODE(BITAND(cs.flags,8+16+32),8,'EVENT_SCHEDULE',16,'INLINE_EVENT',
  32,'SUBCHAIN','PROGRAM'), cs.timeout
  FROM obj$ o, user$ u, sys.scheduler$_step cs
  WHERE cs.oid = o.obj# AND u.user# = o.owner# AND
    (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         (exists (select null from v$enabledprivs
                 where priv_number in (-265 /* CREATE ANY JOB */,
                                       -266 /* EXECUTE ANY PROGRAM */ )
                 )
          and o.owner#!=0)
      )
/
COMMENT ON TABLE all_scheduler_chain_steps IS
'All steps of scheduler chains visible to the current user'
/
COMMENT ON COLUMN all_scheduler_chain_steps.chain_name IS
'Name of the scheduler chain the step is in'
/
COMMENT ON COLUMN all_scheduler_chain_steps.owner IS
'Owner of the scheduler chain the step is in'
/
COMMENT ON COLUMN all_scheduler_chain_steps.step_name IS
'Name of the chain step'
/
COMMENT ON COLUMN all_scheduler_chain_steps.program_owner IS
'Owner of the program that runs during this step'
/
COMMENT ON COLUMN all_scheduler_chain_steps.program_name IS
'Name of the program that runs during this step'
/
COMMENT ON COLUMN all_scheduler_chain_steps.event_schedule_owner IS
'Owner of the event schedule that this step waits for'
/
COMMENT ON COLUMN all_scheduler_chain_steps.event_schedule_name IS
'Name of the event schedule that this step waits for'
/
COMMENT ON COLUMN all_scheduler_chain_steps.event_queue_owner IS
'Owner of source queue into which event will be raised'
/
COMMENT ON COLUMN all_scheduler_chain_steps.event_queue_name IS
'Name of source queue into which event will be raised'
/
COMMENT ON COLUMN all_scheduler_chain_steps.event_queue_agent IS
'Name of AQ agent used by user on the event source queue (for a secure queue)'
/
COMMENT ON COLUMN all_scheduler_chain_steps.event_condition IS
'Boolean expression used as the subscription rule for event on the source queue'
/
COMMENT ON COLUMN all_scheduler_chain_steps.skip IS
'Whether this step should be skipped or not'
/
COMMENT ON COLUMN all_scheduler_chain_steps.pause IS
'Whether this step should be paused after running or not'
/
COMMENT ON COLUMN all_scheduler_chain_steps.restart_on_recovery IS
'Whether this step should be restarted on database recovery'
/
COMMENT ON COLUMN all_scheduler_chain_steps.step_type IS
'Type of this step'
/
COMMENT ON COLUMN all_scheduler_chain_steps.timeout IS
'Timeout for waiting on an event schedule'
/
CREATE OR REPLACE PUBLIC SYNONYM all_scheduler_chain_steps
  FOR all_scheduler_chain_steps
/
GRANT SELECT ON all_scheduler_chain_steps TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW dba_scheduler_running_chains
  ( OWNER, JOB_NAME, JOB_SUBNAME, CHAIN_OWNER, CHAIN_NAME, STEP_NAME, STATE, ERROR_CODE,
    COMPLETED, START_DATE, END_DATE, DURATION, SKIP, PAUSE,
    RESTART_ON_RECOVERY, STEP_JOB_SUBNAME, STEP_JOB_LOG_ID) AS 
  SELECT ju.name, jo.name, jo.subname, cu.name, co.name, cv.var_name,
    DECODE(BITAND(jss.flags,2),2,
      DECODE(jss.status, 'K', 'PAUSED', 'F', 'PAUSED', 'R', 'RUNNING',
        'C', 'SCHEDULED', 'T', 'STALLED', 'NOT_STARTED'),
      DECODE(jss.status, 'K', 'STOPPED', 'R', 'RUNNING', 'C', 'SCHEDULED', 'T',
        'STALLED', 'F',
        DECODE(jss.error_code,0,'SUCCEEDED','FAILED'), 'NOT_STARTED')),
    jss.error_code, DECODE(jss.status, 'F', 'TRUE', 'K', 'TRUE','FALSE'),
    jss.start_date, jss.end_date,
    (CASE WHEN jss.end_date>jss.start_date THEN jss.end_date-jss.start_date
       ELSE NULL END),
    DECODE(BITAND(jss.flags,1),0,'FALSE',1,'TRUE',
      DECODE(BITAND(cv.flags,1),0,'FALSE',1,'TRUE')),
    DECODE(BITAND(jss.flags,2),0,'FALSE',2,'TRUE',
      DECODE(BITAND(cv.flags,2),0,'FALSE',2,'TRUE')),
    DECODE(BITAND(jss.flags,64),0,'FALSE',64,'TRUE',
      DECODE(BITAND(cv.flags,64),0,'FALSE',64,'TRUE')),
    jso.subname, jss.job_step_log_id
  FROM sys.scheduler$_job j JOIN obj$ jo ON (j.obj# = jo.obj#)
     JOIN user$ ju ON (jo.owner# = ju.user#)
     JOIN obj$ co ON (co.obj# = j.program_oid)
     JOIN user$ cu ON (co.owner# = cu.user#)
     JOIN scheduler$_step cv ON (cv.oid = j.program_oid)
     LEFT OUTER JOIN scheduler$_step_state jss
       ON (jss.job_oid = j.obj# AND jss.step_name = cv.var_name)
     LEFT OUTER JOIN obj$ jso ON (jss.job_step_oid = jso.obj#)
     WHERE (BITAND(j.job_status,2+256) != 0 OR jo.subname IS NOT NULL)
/
COMMENT ON TABLE dba_scheduler_running_chains IS
'All steps of all running chains in the database'
/
COMMENT ON COLUMN dba_scheduler_running_chains.job_name IS
'Name of the job which is running the chain'
/
COMMENT ON COLUMN dba_scheduler_running_chains.job_subname IS
'Subname of the job which is running the chain (for a subchain)'
/
COMMENT ON COLUMN dba_scheduler_running_chains.owner IS
'Owner of the job which is running the chain'
/
COMMENT ON COLUMN dba_scheduler_running_chains.chain_name IS
'Name of the chain being run'
/
COMMENT ON COLUMN dba_scheduler_running_chains.chain_owner IS
'Owner of the chain being run'
/
COMMENT ON COLUMN dba_scheduler_running_chains.step_name IS
'Name of this step of the running chain'
/
COMMENT ON COLUMN dba_scheduler_running_chains.state IS
'State of this step'
/
COMMENT ON COLUMN dba_scheduler_running_chains.error_code IS
'Error code of this step, if it has finished running'
/
COMMENT ON COLUMN dba_scheduler_running_chains.completed IS
'Whether this step has completed'
/
COMMENT ON COLUMN dba_scheduler_running_chains.start_date IS
'When this step started, if it has already started'
/
COMMENT ON COLUMN dba_scheduler_running_chains.end_date IS
'When this job step finished running, if it has finished running'
/
COMMENT ON COLUMN dba_scheduler_running_chains.duration IS
'How long this step took to complete, if it has completed'
/
COMMENT ON COLUMN dba_scheduler_running_chains.skip IS
'Whether this step will be skipped or not'
/
COMMENT ON COLUMN dba_scheduler_running_chains.pause IS
'Whether this step will be paused after running or not'
/
COMMENT ON COLUMN dba_scheduler_running_chains.restart_on_recovery IS
'Whether this step will be restarted on database recovery'
/
COMMENT ON COLUMN dba_scheduler_running_chains.step_job_subname IS
'Subname of the job running this step, if the step job has been created'
/
COMMENT ON COLUMN dba_scheduler_running_chains.step_job_log_id IS
'Log id of the step job if it has completed and has been logged.'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_scheduler_running_chains
  FOR dba_scheduler_running_chains
/
GRANT SELECT ON dba_scheduler_running_chains TO select_catalog_role
/

CREATE OR REPLACE VIEW user_scheduler_running_chains
  ( JOB_NAME, JOB_SUBNAME, CHAIN_OWNER, CHAIN_NAME, STEP_NAME, STATE, ERROR_CODE,
    COMPLETED, START_DATE, END_DATE, DURATION, SKIP, PAUSE,
    RESTART_ON_RECOVERY, STEP_JOB_SUBNAME, STEP_JOB_LOG_ID) AS
  SELECT jo.name, jo.subname, cu.name, co.name, cv.var_name,
    DECODE(BITAND(jss.flags,2),2,
      DECODE(jss.status, 'K', 'PAUSED', 'F', 'PAUSED', 'R', 'RUNNING',
        'C', 'SCHEDULED', 'T', 'STALLED', 'NOT_STARTED'),
      DECODE(jss.status, 'K', 'STOPPED', 'R', 'RUNNING', 'C', 'SCHEDULED', 'T',
        'STALLED', 'F',
        DECODE(jss.error_code,0,'SUCCEEDED','FAILED'), 'NOT_STARTED')),
    jss.error_code, DECODE(jss.status, 'F', 'TRUE', 'K', 'TRUE','FALSE'),
    jss.start_date, jss.end_date,
    (CASE WHEN jss.end_date>jss.start_date THEN jss.end_date-jss.start_date
       ELSE NULL END),
    DECODE(BITAND(jss.flags,1),0,'FALSE',1,'TRUE',
      DECODE(BITAND(cv.flags,1),0,'FALSE',1,'TRUE')),
    DECODE(BITAND(jss.flags,2),0,'FALSE',2,'TRUE',
      DECODE(BITAND(cv.flags,2),0,'FALSE',2,'TRUE')),
    DECODE(BITAND(jss.flags,64),0,'FALSE',64,'TRUE',
      DECODE(BITAND(cv.flags,64),0,'FALSE',64,'TRUE')),
    jso.subname, jss.job_step_log_id
  FROM sys.scheduler$_job j
     JOIN obj$ jo ON (j.obj# = jo.obj# AND jo.owner# = USERENV('SCHEMAID'))
     JOIN obj$ co ON (co.obj# = j.program_oid)
     JOIN user$ cu ON (co.owner# = cu.user#)
     JOIN scheduler$_step cv ON (cv.oid = j.program_oid)
     LEFT OUTER JOIN scheduler$_step_state jss
       ON (jss.job_oid = j.obj# AND jss.step_name = cv.var_name)
     LEFT OUTER JOIN obj$ jso ON (jss.job_step_oid = jso.obj#)
     WHERE (BITAND(j.job_status,2+256) != 0 OR jo.subname IS NOT NULL)
/
COMMENT ON TABLE user_scheduler_running_chains IS
'All steps of chains being run by jobs owned by the current user'
/
COMMENT ON COLUMN user_scheduler_running_chains.job_name IS
'Name of the job which is running the chain'
/
COMMENT ON COLUMN user_scheduler_running_chains.job_subname IS
'Subname of the job which is running the chain (for a subchain)'
/
COMMENT ON COLUMN user_scheduler_running_chains.chain_name IS
'Name of the chain being run'
/
COMMENT ON COLUMN user_scheduler_running_chains.chain_owner IS
'Owner of the chain being run'
/
COMMENT ON COLUMN user_scheduler_running_chains.step_name IS
'Name of this step of the running chain'
/
COMMENT ON COLUMN user_scheduler_running_chains.state IS
'State of this step'
/
COMMENT ON COLUMN user_scheduler_running_chains.error_code IS
'Error code of this step, if it has finished running'
/
COMMENT ON COLUMN user_scheduler_running_chains.completed IS
'Whether this step has completed'
/
COMMENT ON COLUMN user_scheduler_running_chains.start_date IS
'When this step started, if it has already started'
/
COMMENT ON COLUMN user_scheduler_running_chains.end_date IS
'When this job step finished running, if it has finished running'
/
COMMENT ON COLUMN user_scheduler_running_chains.duration IS
'How long this step took to complete, if it has completed'
/
COMMENT ON COLUMN user_scheduler_running_chains.skip IS
'Whether this step will be skipped or not'
/
COMMENT ON COLUMN user_scheduler_running_chains.pause IS
'Whether this step will be paused after running or not'
/
COMMENT ON COLUMN user_scheduler_running_chains.restart_on_recovery IS
'Whether this step will be restarted on database recovery'
/
COMMENT ON COLUMN user_scheduler_running_chains.step_job_subname IS
'Subname of the job running this step, if the step job has been created'
/
COMMENT ON COLUMN user_scheduler_running_chains.step_job_log_id IS
'Log id of the step job if it has completed and has been logged.'
/
CREATE OR REPLACE PUBLIC SYNONYM user_scheduler_running_chains
  FOR user_scheduler_running_chains
/
GRANT SELECT ON user_scheduler_running_chains TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW all_scheduler_running_chains
  ( OWNER, JOB_NAME, JOB_SUBNAME, CHAIN_OWNER, CHAIN_NAME, STEP_NAME, STATE, ERROR_CODE,
    COMPLETED, START_DATE, END_DATE, DURATION, SKIP, PAUSE,
    RESTART_ON_RECOVERY, STEP_JOB_SUBNAME, STEP_JOB_LOG_ID) AS
  SELECT ju.name, jo.name, jo.subname, cu.name, co.name, cv.var_name,
    DECODE(BITAND(jss.flags,2),2,
      DECODE(jss.status, 'K', 'PAUSED', 'F', 'PAUSED', 'R', 'RUNNING',
        'C', 'SCHEDULED', 'T', 'STALLED', 'NOT_STARTED'),
      DECODE(jss.status, 'K', 'STOPPED', 'R', 'RUNNING', 'C', 'SCHEDULED', 'T',
        'STALLED', 'F',
        DECODE(jss.error_code,0,'SUCCEEDED','FAILED'), 'NOT_STARTED')),
    jss.error_code, DECODE(jss.status, 'F', 'TRUE', 'K', 'TRUE','FALSE'),
    jss.start_date, jss.end_date,
    (CASE WHEN jss.end_date>jss.start_date THEN jss.end_date-jss.start_date
       ELSE NULL END),
    DECODE(BITAND(jss.flags,1),0,'FALSE',1,'TRUE',
      DECODE(BITAND(cv.flags,1),0,'FALSE',1,'TRUE')),
    DECODE(BITAND(jss.flags,2),0,'FALSE',2,'TRUE',
      DECODE(BITAND(cv.flags,2),0,'FALSE',2,'TRUE')),
    DECODE(BITAND(jss.flags,64),0,'FALSE',64,'TRUE',
      DECODE(BITAND(cv.flags,64),0,'FALSE',64,'TRUE')),
    jso.subname, jss.job_step_log_id
  FROM sys.scheduler$_job j JOIN obj$ jo ON (j.obj# = jo.obj#)
     JOIN user$ ju ON 
     (jo.owner# = ju.user# AND
       (jo.owner# = userenv('SCHEMAID')
         or jo.obj# in
              (select oa.obj#
               from sys.objauth$ oa
               where grantee# in ( select kzsrorol
                                   from x$kzsro
                                 )
              )
         or /* user has system privileges */
           (exists (select null from v$enabledprivs
                   where priv_number in (-265 /* CREATE ANY JOB */)
                   )
            and jo.owner#!=0
           )
       )
     )
     JOIN obj$ co ON (co.obj# = j.program_oid)
     JOIN user$ cu ON (co.owner# = cu.user#)
     JOIN scheduler$_step cv ON (cv.oid = j.program_oid)
     LEFT OUTER JOIN scheduler$_step_state jss
       ON (jss.job_oid = j.obj# AND jss.step_name = cv.var_name)
     LEFT OUTER JOIN obj$ jso ON (jss.job_step_oid = jso.obj#)
     WHERE (BITAND(j.job_status,2+256) != 0 OR jo.subname IS NOT NULL)
/
COMMENT ON TABLE all_scheduler_running_chains IS
'All job steps of running job chains visible to the user'
/
COMMENT ON COLUMN all_scheduler_running_chains.job_name IS
'Name of the job which is running the chain'
/
COMMENT ON COLUMN all_scheduler_running_chains.job_subname IS
'Subname of the job which is running the chain (for a subchain)'
/
COMMENT ON COLUMN all_scheduler_running_chains.owner IS
'Owner of the job which is running the chain'
/
COMMENT ON COLUMN all_scheduler_running_chains.chain_name IS
'Name of the chain being run'
/
COMMENT ON COLUMN all_scheduler_running_chains.chain_owner IS
'Owner of the chain being run'
/
COMMENT ON COLUMN all_scheduler_running_chains.step_name IS
'Name of this step of the running chain'
/
COMMENT ON COLUMN all_scheduler_running_chains.state IS
'State of this step'
/
COMMENT ON COLUMN all_scheduler_running_chains.error_code IS
'Error code of this step, if it has finished running'
/
COMMENT ON COLUMN all_scheduler_running_chains.completed IS
'Whether this step has completed'
/
COMMENT ON COLUMN all_scheduler_running_chains.start_date IS
'When this step started, if it has already started'
/
COMMENT ON COLUMN all_scheduler_running_chains.end_date IS
'When this job step finished running, if it has finished running'
/
COMMENT ON COLUMN all_scheduler_running_chains.duration IS
'How long this step took to complete, if it has completed'
/
COMMENT ON COLUMN all_scheduler_running_chains.skip IS
'Whether this step will be skipped or not'
/
COMMENT ON COLUMN all_scheduler_running_chains.pause IS
'Whether this step will be paused after running or not'
/
COMMENT ON COLUMN all_scheduler_running_chains.restart_on_recovery IS
'Whether this step will be restarted on database recovery'
/
COMMENT ON COLUMN all_scheduler_running_chains.step_job_subname IS
'Subname of the job running this step, if the step job has been created'
/
COMMENT ON COLUMN all_scheduler_running_chains.step_job_log_id IS
'Log id of the step job if it has completed and has been logged.'
/
CREATE OR REPLACE PUBLIC SYNONYM all_scheduler_running_chains
  FOR all_scheduler_running_chains
/
GRANT SELECT ON all_scheduler_running_chains TO public WITH GRANT OPTION
/

/* Register procedural objects for export */
DELETE FROM sys.exppkgobj$ WHERE package LIKE 'DBMS_SCHED_%'
/
INSERT INTO sys.exppkgobj$ (package,schema,class,type#,prepost,level#)
  VALUES ('DBMS_SCHED_PROGRAM_EXPORT','SYS',2,67,1, 1500)
/
INSERT INTO sys.exppkgobj$ (package,schema,class,type#,prepost,level#)
  VALUES ('DBMS_SCHED_WINDOW_EXPORT','SYS',1,69,1, 1510)
/
INSERT INTO sys.exppkgobj$ (package,schema,class,type#,prepost,level#)
  VALUES ('DBMS_SCHED_WINGRP_EXPORT','SYS',1,72,1, 1520)
/
INSERT INTO sys.exppkgobj$ (package,schema,class,type#,prepost,level#)
  VALUES ('DBMS_SCHED_CLASS_EXPORT','SYS',1,68,1, 1520)
/
INSERT INTO sys.exppkgobj$ (package,schema,class,type#,prepost,level#)
  VALUES ('DBMS_SCHED_JOB_EXPORT','SYS',2,66,1, 1530)
/
INSERT INTO sys.exppkgobj$ (package,schema,class,type#,prepost,level#)
  VALUES ('DBMS_SCHED_SCHEDULE_EXPORT','SYS',2,74,1, 1525)
/
INSERT INTO sys.exppkgobj$ (package,schema,class,type#,prepost,level#)
  VALUES ('DBMS_SCHED_CHAIN_EXPORT','SYS',2,79,1, 1525)
/
DELETE FROM sys.exppkgact$ WHERE package LIKE 'DBMS_SCHED_%'
/
INSERT INTO sys.exppkgact$ (package, schema, class, level#)
  VALUES ('DBMS_SCHED_EXPORT_CALLOUTS','SYS',6,1000)
/
INSERT INTO sys.exppkgact$ (package, schema, class, level#)
  VALUES ('DBMS_SCHED_EXPORT_CALLOUTS','SYS',2,1000)
/

/* Create table and sequence for storing used-up OIDs */
create table scheduler$_oldoids
(
   idseq    number not null,
     constraint scheduler$_oo_pk primary key (idseq),
   oldoid   number not null
);

create sequence scheduler$_oldoids_s;

/* Create sequence for job_name suffixes. This is used by generate_job_name */
create sequence scheduler$_jobsuffix_s;
grant select on sys.scheduler$_jobsuffix_s to public with grant option;

/* Load Scheduler packages */
/* dbmssch.sql is needed for the views so it is loaded earlier */
@@prvthsch.plb
@@prvtbsch.plb
@@prvtesch.plb
/* prvtdsch.plb is loaded in catpstr since it needs streams hdrs in prvthstr */
/* it contains all the setup req'd for distributed scheduling (remote jobs) */

/* Scheduler admin role */
CREATE ROLE scheduler_admin
/
GRANT create job, create any job, execute any program, execute any class,
manage scheduler, create external job TO scheduler_admin WITH ADMIN OPTION
/
GRANT scheduler_admin TO dba WITH ADMIN OPTION
/

/* Create a default class and grant execute on it to PUBLIC */
begin
dbms_scheduler.create_job_class(job_class_name => 'DEFAULT_JOB_CLASS',
 comments=>'This is the default job class.');
dbms_scheduler.set_attribute('DEFAULT_JOB_CLASS','SYSTEM',TRUE);
exception
  when others then
    if sqlcode = -27477 then NULL;
    else raise;
    end if;
end;
/
grant execute on sys.default_job_class to public with grant option
/

begin
  dbms_scheduler.set_scheduler_attribute('MAX_JOB_SLAVE_PROCESSES', NULL);
exception
  when others then
    if sqlcode = -955 then NULL;
    else raise;
    end if;
end;
/
begin
  dbms_scheduler.set_scheduler_attribute('LOG_HISTORY', 30);
exception
  when others then
    if sqlcode = -955 then NULL;
    else raise;
    end if;
end;
/

begin
  dbms_scheduler.set_scheduler_attribute('DEFAULT_TIMEZONE', 
                          dbms_scheduler.get_sys_time_zone_name);
exception
  when others then
    if sqlcode = -955 then NULL;
    else raise;
    end if;
end;
/

--Create purge log program.
BEGIN
dbms_scheduler.create_program(
  program_name=>'purge_log_prog',
  program_type=>'STORED_PROCEDURE',
  program_action=>'dbms_scheduler.auto_purge',
  number_of_arguments=>0,
  enabled=>TRUE,
  comments=>'purge log program');
exception
  when others then
    if sqlcode = -27477 then NULL;
    else raise;
    end if;
END;
/

-- Create daily schedule. 
BEGIN
dbms_scheduler.create_schedule(
   schedule_name=>'DAILY_PURGE_SCHEDULE',
   repeat_interval=>'freq=daily;byhour=3;byminute=0;bysecond=0');
exception
  when others then
    if sqlcode = -27477 then NULL;
    else raise;
    end if;
END;
/


-- Create purge log job
BEGIN
  sys.dbms_scheduler.create_job(
    job_name=>'PURGE_LOG',
    program_name=>'purge_log_prog',
    schedule_name=>'DAILY_PURGE_SCHEDULE',
    job_class=>'DEFAULT_JOB_CLASS',
    enabled=>TRUE,
    auto_drop=>FALSE,
    comments=>'purge log job');
  sys.dbms_scheduler.set_attribute('PURGE_LOG','FOLLOW_DEFAULT_TIMEZONE',TRUE);
exception
  when others then
    if sqlcode = -27477 then NULL;
    else raise;
    end if;
END;
/

begin
  dbms_scheduler.set_scheduler_attribute('LAST_OBSERVED_EVENT', NULL);
exception
  when others then
    if sqlcode = -955 then NULL;
    else raise;
    end if;
end;
/

begin
  dbms_scheduler.set_scheduler_attribute('EVENT_EXPIRY_TIME', NULL);
exception
  when others then
    if sqlcode = -955 then NULL;
    else raise;
    end if;
end;
/


-- ***************************************************************************
-- This has to be the last thing executed in catsch.sql
-- Do not add anything after this
-- ***************************************************************************

begin
  dbms_scheduler.set_scheduler_attribute('CURRENT_OPEN_WINDOW', NULL);
exception
  when others then
    if sqlcode = -955 then NULL;
    else raise;
    end if;
end;
/
