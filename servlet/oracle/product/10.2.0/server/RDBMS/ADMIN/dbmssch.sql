Rem
Rem $Header: dbmssch.sql 13-may-2005.17:39:06 rramkiss Exp $
Rem
Rem dbmssch.sql
Rem
Rem Copyright (c) 2002, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmssch.sql - DBMS SCHeduler interface
Rem
Rem    DESCRIPTION
Rem      Interface for the job scheduler package
Rem
Rem    NOTES
Rem
Rem      DBMS_SCHEDULER is the only interface for manipulating scheduler jobs.
Rem      Catalog views in catsch.sql are provided for examining jobs.
Rem
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rramkiss    04/27/05 - shortcut event constant 
Rem    rgmani      04/26/05 - Fix maxdur event bug 
Rem    rramkiss    03/21/05 - update run_chain 
Rem    rramkiss    03/11/05 - add CHAIN_STALLED event 
Rem    evoss       02/14/05 - remove create_calendar_schedule, now just 
Rem                             create_schedule
Rem    evoss       01/07/05 - make resolve calendar usable from odbc 
Rem    rramkiss    12/20/04 - get_chain_condition utility function 
Rem    rramkiss    09/23/04 - add utility function for EM 
Rem    evoss       08/10/04 - add timezone get 
Rem    rgmani      07/01/04 - Add job disabled event 
Rem    evoss       05/10/04 - add calendar schedule type 
Rem    rramkiss    04/26/04 - chains API tweaks 
Rem    rramkiss    03/08/04 - add get_action_value 
Rem    rramkiss    02/23/04 - job chaining API 
Rem    rgmani      04/27/04 - Event based scheduling 
Rem    evoss       10/28/03 - #3210672: evaluate calendar string changes 
Rem    rramkiss    09/19/03 - add flag to run_job 
Rem    evoss       09/08/03 - make chains internal 
Rem    rramkiss    08/12/03 - add get_default_value
Rem    srajagop    06/20/03 - add auto_purge proc
Rem    srajagop    06/17/03 - purging of logs contd
Rem    srajagop    06/10/03 - purge log
Rem    rramkiss    06/26/03 - fix generate_job_name
Rem    evoss       06/23/03 - job chaining
Rem    rramkiss    06/10/03 - add create/drop for job chains
Rem    rramkiss    01/23/03 - persistent=>auto_drop
Rem    rramkiss    01/13/03 - DEFAULT_CLASS => DEFAULT_JOB_CLASS
Rem    evoss       12/27/02 - add force option to open window
Rem    rramkiss    12/20/02 - add comments to create_window_group
Rem    rramkiss    12/18/02 - overload get/set_attribute for day-sec intervals
Rem    rramkiss    12/17/02 - interval fields => type interval day to second
Rem    rramkiss    12/02/02 - API tweaks
Rem    rramkiss    11/18/02 - remove schedule type window_once
Rem    rramkiss    11/18/02 - change kill_job to a force option of stop_job
Rem    rramkiss    11/15/02 - Add persistent flag to create job
Rem    rramkiss    11/05/02 - Add default program_type for create_program
Rem    rramkiss    10/28/02 - add check_sys_privs
Rem    evoss       10/31/02 - add calendar utility functions
Rem    srajagop    10/07/02 - add executable prog type
Rem    rramkiss    10/08/02 - Add schedule object API
Rem    rramkiss    09/19/02 - Overload API calls specifying arguments
Rem    rramkiss    09/05/02 - Add window groups procedures
Rem    rramkiss    08/29/02 - Remove obsolete library load
Rem    rramkiss    08/21/02 - Remove fields from create_job/window
Rem    rramkiss    08/21/02 - Merge dbms_scheduler_admin into dbms_scheduler
Rem    rramkiss    08/14/02 - Consolidate get/set_parameter procedures
Rem    rramkiss    07/26/02 - Consolidate enable/disable procedures
Rem    srajagop    07/23/02 - srajagop_scheduler_1
Rem    rramkiss    07/21/02 - Update purge_policy, stop_job and kill_job
Rem    rramkiss    07/16/02 - Remove cruft (incl. privileges, priority lists)
Rem    rgmani      07/16/02 - Add window end time internal argument
Rem    rramkiss    06/26/02 - Move check_compat to dbms_isched
Rem                           Compatibility checking requires definer`s privs
Rem    rramkiss    06/25/02 - Change job_weight to be a PLS_INTEGER
Rem    rramkiss    06/25/02 - Change name in create_job to be an IN variable
Rem    rramkiss    06/21/02 - Remove obsolete window fields
Rem    rramkiss    05/17/02 - Sync with Phase 1 requirements
Rem    rramkiss    04/11/02 - Created
Rem


REM  =========================================================
REM  dbms_scheduler: job scheduler functions for public consumption
REM  =========================================================

-- Main Scheduler package
CREATE OR REPLACE PACKAGE dbms_scheduler  AUTHID CURRENT_USER AS

logging_off   CONSTANT PLS_INTEGER := 32;
logging_runs  CONSTANT PLS_INTEGER := 64;
logging_full  CONSTANT PLS_INTEGER := 256;

-- Program/Job types
-- 'PLSQL_BLOCK'
-- 'STORED_PROCEDURE'
-- 'EXECUTABLE'

-- Metadata attributes (for a program argument)
-- 'JOB_NAME'
-- 'JOB_OWNER'
-- 'JOB_START'
-- 'WINDOW_START'
-- 'WINDOW_END'

-- Window Priorities
-- 'HIGH'
-- 'LOW'

-- Constants for raise events flags

job_started           CONSTANT PLS_INTEGER := 1;
job_succeeded         CONSTANT PLS_INTEGER := 2;
job_failed            CONSTANT PLS_INTEGER := 4;
job_broken            CONSTANT PLS_INTEGER := 8;
job_completed         CONSTANT PLS_INTEGER := 16;
job_stopped           CONSTANT PLS_INTEGER := 32;
job_sch_lim_reached   CONSTANT PLS_INTEGER := 64;
job_disabled          CONSTANT PLS_INTEGER := 128;
job_chain_stalled     CONSTANT PLS_INTEGER := 256;
job_all_events        CONSTANT PLS_INTEGER := 511;
job_over_max_dur      CONSTANT PLS_INTEGER := 512;
job_run_completed     CONSTANT PLS_INTEGER :=
                        job_succeeded + job_failed + job_stopped;

/*************************************************************
 * Program Administration Procedures
 *************************************************************
 */

-- Program attributes which can be used with set_attribute/get_attribute are:
--
-- program_action     - VARCHAR2
--                      This is a string specifying the action. In case of:
--                      'PLSQL_BLOCK': PLSQL code
--                      'STORED_PROCEDURE: name of the database object
--                         representing the type (optionally with schema).
--                      'EXECUTABLE': Full pathname including the name of the
--                         executable, or shell script.
-- program_type       - VARCHAR2
--                      type of program. This must be one of the supported
--                      program types. Currently these are
--                      'PLSQL_BLOCK', 'STORED_PROCEDURE', 'EXECUTABLE'
-- comments              - VARCHAR2
--                      an optional comment. This can describe what the
--                      program does, or give usage details.
-- number_of_arguments- PLS_INTEGER
--                      the number of arguments of the program that can be set
--                      by any job using it, these arguments MUST be defined
--                      before the program can be enabled
-- enabled            - BOOLEAN
--                      whether the program is enabled or not. When the program
--                      is enabled, checks are made to ensure that the program
--                      is valid.

-- Create a new program. The program name can be optionally qualified with a
-- schema. If enabled is set to TRUE, validity checks will be performed and
-- the program will be created in an enabled state if all are passed.
PROCEDURE create_program(
  program_name            IN VARCHAR2,
  program_type            IN VARCHAR2,
  program_action          IN VARCHAR2,
  number_of_arguments     IN PLS_INTEGER DEFAULT 0,
  enabled                 IN BOOLEAN DEFAULT FALSE,
  comments                 IN VARCHAR2 DEFAULT NULL);

-- Drops an existing program (or a comma separated list of programs).
-- When force is set to false the program must not be
-- referred to by any job.  When force is set to true, any jobs referring to
-- this program will be disabled (same behavior as calling the disable routine
-- on those jobs with the force option).
-- Any argument information that was created for this program will be dropped
-- with the program.
PROCEDURE drop_program(
  program_name            IN VARCHAR2,
  force                   IN BOOLEAN DEFAULT FALSE);

-- Define an argument of a program. All arguments of a program must be defined.
-- If given, the argument name must be unique for this program.
-- Any argument already defined at this position will be overwritten.
-- The argument type must be a valid Oracle or user-defined type.
-- out_argument is reserved for future use. The default and only valid value
-- is FALSE.
PROCEDURE define_program_argument(
 program_name            IN VARCHAR2,
 argument_position       IN PLS_INTEGER,
 argument_name           IN VARCHAR2 DEFAULT NULL,
 argument_type           IN VARCHAR2,
 default_value           IN VARCHAR2,
 out_argument            IN BOOLEAN DEFAULT FALSE);

-- Define an argument of a program without a default value.
-- Any job using this program must set a value to this argument.
-- See other notes for define_program_argument above.
PROCEDURE define_program_argument(
 program_name            IN VARCHAR2,
 argument_position       IN PLS_INTEGER,
 argument_name           IN VARCHAR2 DEFAULT NULL,
 argument_type           IN VARCHAR2,
 out_argument            IN BOOLEAN DEFAULT FALSE);

-- Define an argument with a default value encapsulated in an ANYDATA.
-- See other notes for define_program_argument above.
PROCEDURE define_anydata_argument(
  program_name            IN VARCHAR2,
  argument_position       IN PLS_INTEGER,
  argument_name           IN VARCHAR2 DEFAULT NULL,
  argument_type           IN VARCHAR2,
  default_value           IN SYS.ANYDATA,
  out_argument            IN BOOLEAN DEFAULT FALSE);

-- Define a special metadata argument for the program. The program developer
-- can retrieve specific scheduler metadata through this argument.
-- Jobs cannot set values for this argument.
-- valid metadata_attributes are: 'COMPLETION_CODE', 'JOB_SUBNAME','JOB_NAME',
-- 'JOB_OWNER', 'JOB_START', 'WINDOW_START', 'WINDOW_END', 'EVENT_MESSAGE'
-- See other notes for define_program_argument above.
PROCEDURE define_metadata_argument(
  program_name            IN VARCHAR2,
  metadata_attribute      IN VARCHAR2,
  argument_position       IN PLS_INTEGER,
  argument_name           IN VARCHAR2 DEFAULT NULL);

-- drop a program argument either by name or position
PROCEDURE drop_program_argument (
  program_name            IN VARCHAR2,
  argument_position       IN PLS_INTEGER);

PROCEDURE drop_program_argument (
  program_name            IN VARCHAR2,
  argument_name           IN VARCHAR2);

/*************************************************************
 * Job Administration Procedures
 *************************************************************
 */

-- Job attributes which can be used with set_attribute/get_attribute are :
--
-- program_name      - VARCHAR2
--                     The name of a program object to use with this job.
--                     If this is set, job_action, job_type and
--                     number_of_arguments should be NULL
-- job_action        - VARCHAR2
--                     This is a string specifying the action. In case of:
--                      'PLSQL_BLOCK': PLSQL code
--                      'STORED_PROCEDURE': name of the database stored 
--                          procedure (C, Java or PL/SQL), optionally qualified
--                          with a schema name).
--                      'EXECUTABLE': Name of an executable of shell script
--                         including the full pathname and any command-line
--                         flags to it.
--                     If this is set, program_name should be NULL.
-- job_type          - VARCHAR2
--                      type of this job. Can be any of:
--                      'PLSQL_BLOCK', 'STORED_PROCEDURE', 'EXECUTABLE'
--                     If this is set,program_name should be NULL
-- number_of_arguments- PLS_INTEGER
--                     the number of arguments if the program is inlined. If
--                     this is set, program_name should be NULL.
-- schedule_name     - VARCHAR2
--                     The name of a schedule or window or window group to use
--                     as the schedule for this job.
--                     If this is set, end_date, start_date and repeat_interval
--                     should all be NULL.
-- repeat_interval   - VARCHAR2
--                     either a PL/SQL function returning the next date on
--                     which to run,or calendar syntax expression.
--                     If this is set, schedule_name should be NULL.
-- start_date        - TIMESTAMP WITH TIME ZONE
--                     the original date on which this job was or will be
--                     scheduled to start.
--                     If this is set, schedule_name should be NULL.
-- end_date          - TIMESTAMP WITH TIME ZONE
--                     the date after which the job will no longer run (it will
--                     be dropped if auto_drop is set or disabled with the
--                     state changed to 'COMPLETED' if it is)
--                     If this is set, schedule_name should be NULL.
-- schedule_limit    - INTERVAL DAY TO SECOND
--                     time in minutes after the scheduled time after which a
--                     job that has not been run will be rescheduled. This is
--                     only valid for repeating jobs.
--                     If this is NULL, a job will never
--                     be rescheduled unless it has been run (failed or
--                     successfully)
-- job_class         - VARCHAR2
--                     the class this job is associated with.
-- job_priority      - PLS_INTEGER
--                     the priority of this job relative to other jobs in the
--                     same class. The default is 3 and values should
--                     be 1 and 5 (1 being the highest priority)
-- comments           - VARCHAR2
--                     an optional comment.
-- max_runs          - PLS_INTEGER
--                     the maximum number of consecutive times this job will be
--                     allowed to be run (after this number of consecurtive
--                     times it will be disabled and its state will be changed
--                     to 'COMPLETED'
-- job_weight        - PLS_INTEGER
--                     jobs which include parallel queries should set this to
--                     the number of parallel slaves they expect to spawn
-- logging_level     - PLS_INTEGER
--                     represents how much logging pertaining to
--                     this job should be done
-- max_run_duration  - INTERVAL DAY TO SECOND
--                     the max time for the job to run, if the job runs for
--                     longer than this interval, a job_over_max_dur event
--                     will be raised (the job will not be stopped)
-- max_failures      - PLS_INTEGER
--                     the number of times a job can fail on consecutive
--                     scheduled runs before it is automatically disabled. If
--                     this is set to 0 then the job will keep running no
--                     matter how often it has failed. If a job is
--                     automatically disabled after having failed this number
--                     of times, its state will be changed to BROKEN.
-- instance_stickiness- BOOLEAN
--                      If this option is set to TRUE, then for the first run
--                      of the job the scheduler will choose the instance with
--                      the lightest load to run this job on. Subsequent runs
--                      will use the same instance that the first run used
--                      (unless this instance is down). If this is FALSE then
--                      the scheduler will choose the first available instance
--                      to schedule the job on on all runs.
-- stop_on_window_exit - BOOLEAN
--                       If this job has a window or window group as a schedule
--                       it will be stopped if the associated window closes, if
--                       this boolean attribute is set to TRUE.
-- enabled             - BOOLEAN
--                       whether the job is enabled or not
-- auto_drop           - BOOLEAN
--                       whether the job should be dropped after having
--                       completed
-- restartable         - BOOLEAN
--                       whether the job can be safely restarted (and should be
--                       restarted in case of failure). By default this is set
--                       to FALSE.

-- create a job in a single call (without using an existing program or
-- schedule).
-- Valid values for job_type and job_action are the same as those for
-- program_type and program_action. If enabled is set TRUE, it will be
-- attempted to enable this job after creating it. If number_of_arguments is
-- set non-zero, values must be set for each of the arguments before enabling
-- the job.
PROCEDURE create_job(
  job_name                IN VARCHAR2,
  job_type                 IN VARCHAR2,
  job_action              IN VARCHAR2,
  number_of_arguments     IN PLS_INTEGER              DEFAULT 0,
  start_date              IN TIMESTAMP WITH TIME ZONE DEFAULT NULL,
  repeat_interval         IN VARCHAR2                 DEFAULT NULL,
  end_date                IN TIMESTAMP WITH TIME ZONE DEFAULT NULL,
  job_class               IN VARCHAR2              DEFAULT 'DEFAULT_JOB_CLASS',
  enabled                 IN BOOLEAN                  DEFAULT FALSE,
  auto_drop               IN BOOLEAN                  DEFAULT TRUE,
  comments                IN VARCHAR2                 DEFAULT NULL);

-- create a job using inlined program and inlined event schedule.
-- If enabled is set TRUE, it will be attempted to enable this job after
-- creating it.
-- Values must be set for each argument of the program that does not have a
-- default_value specified (before enabling the job).
-- Note that there are no defaults for event_condition and queue_spec. They
-- must be set explicitly to create an event based job.
PROCEDURE create_job(
  job_name                IN VARCHAR2,
  job_type                 IN VARCHAR2,
  job_action              IN VARCHAR2,
  number_of_arguments     IN PLS_INTEGER              DEFAULT 0,
  start_date              IN TIMESTAMP WITH TIME ZONE DEFAULT NULL,
  event_condition         IN VARCHAR2,
  queue_spec              IN VARCHAR2,
  end_date                IN TIMESTAMP WITH TIME ZONE DEFAULT NULL,
  job_class               IN VARCHAR2              DEFAULT 'DEFAULT_JOB_CLASS',
  enabled                 IN BOOLEAN                  DEFAULT FALSE,
  auto_drop               IN BOOLEAN                  DEFAULT TRUE,
  comments                IN VARCHAR2                 DEFAULT NULL);

-- create a job using a named schedule object and a named program object.
-- If enabled is set TRUE, it will be attempted to enable this job after
-- creating it.
-- Values must be set for each argument of the program that does not have a
-- default_value specified (before enabling the job).
PROCEDURE create_job(
  job_name                IN VARCHAR2,
  program_name            IN VARCHAR2,
  schedule_name           IN VARCHAR2,
  job_class               IN VARCHAR2              DEFAULT 'DEFAULT_JOB_CLASS',
  enabled                 IN BOOLEAN                  DEFAULT FALSE,
  auto_drop               IN BOOLEAN                  DEFAULT TRUE,
  comments                 IN VARCHAR2                 DEFAULT NULL);

-- create a job using a named program object and an inlined schedule
-- If enabled is set TRUE, it will be attempted to enable this job after
-- creating it.
-- Values must be set for each argument of the program that does not have a
-- default_value specified (before enabling the job).
PROCEDURE create_job(
  job_name                IN VARCHAR2,
  program_name            IN VARCHAR2,
  start_date              IN TIMESTAMP WITH TIME ZONE DEFAULT NULL,
  repeat_interval         IN VARCHAR2                 DEFAULT NULL,
  end_date                IN TIMESTAMP WITH TIME ZONE DEFAULT NULL,
  job_class               IN VARCHAR2              DEFAULT 'DEFAULT_JOB_CLASS',
  enabled                 IN BOOLEAN                  DEFAULT FALSE,
  auto_drop               IN BOOLEAN                  DEFAULT TRUE,
  comments                 IN VARCHAR2                 DEFAULT NULL);

-- create a job using named program and inlined event schedule.
-- If enabled is set TRUE, it will be attempted to enable this job after
-- creating it.
-- Values must be set for each argument of the program that does not have a
-- default_value specified (before enabling the job).
-- Note that there are no defaults for event_condition and queue_spec. They
-- must be set explicitly to create an event based job.
PROCEDURE create_job(
  job_name                IN VARCHAR2,
  program_name            IN VARCHAR2,
  start_date              IN TIMESTAMP WITH TIME ZONE DEFAULT NULL,
  event_condition         IN VARCHAR2,
  queue_spec              IN VARCHAR2,
  end_date                IN TIMESTAMP WITH TIME ZONE DEFAULT NULL,
  job_class               IN VARCHAR2              DEFAULT 'DEFAULT_JOB_CLASS',
  enabled                 IN BOOLEAN                  DEFAULT FALSE,
  auto_drop               IN BOOLEAN                  DEFAULT TRUE,
  comments                 IN VARCHAR2                 DEFAULT NULL);

-- create a job using a named schedule object and an inlined program
-- Valid values for job_type and job_action are the same as those for
-- program_type and program_action. If enabled is set TRUE, it will be
-- attempted to enable this job after creating it. If number_of_arguments is
-- set non-zero, values must be set for each of the arguments before enabling
-- the job.
PROCEDURE create_job(
  job_name                IN VARCHAR2,
  schedule_name           IN VARCHAR2,
  job_type                 IN VARCHAR2,
  job_action              IN VARCHAR2,
  number_of_arguments     IN PLS_INTEGER              DEFAULT 0,
  job_class               IN VARCHAR2              DEFAULT 'DEFAULT_JOB_CLASS',
  enabled                 IN BOOLEAN                  DEFAULT FALSE,
  auto_drop               IN BOOLEAN                  DEFAULT TRUE,
  comments                 IN VARCHAR2                 DEFAULT NULL);

-- Run a job immediately. If use_current_session is TRUE the job is run in the
-- user's current session. If use_current_session is FALSE the job is run in the
-- background by a dedicated job slave.
PROCEDURE run_job(
  job_name                IN VARCHAR2,
  use_current_session     IN BOOLEAN DEFAULT TRUE);

-- Stop a job or several jobs that are currently running. Job name can also be
-- the name of a job class or a comma-separated list of jobs.
-- If the force option is not specified this will interrupt the job
-- by sending an equivalent of a Ctrl-C to the job. If this fails, an error
-- will be returned.
-- If the force option is specified the job slave will be terminated. Use of
-- the force option requires the MANAGE SCHEDULER system privilege
PROCEDURE stop_job(
  job_name                IN VARCHAR2,
  force                   IN BOOLEAN DEFAULT FALSE);

-- Copy a job. The new_job will contain all the attributes of the old_job,
-- except that it will be created disabled. The state of the old_job will not
-- be altered.
PROCEDURE copy_job(
  old_job                 IN VARCHAR2,
  new_job                 IN VARCHAR2);

-- Drop a job or several jobs.  Job name can also be
-- the name of a job class or a comma-separated list of jobs.
-- If force is true, all running instances of the job will be stopped by
-- calling stop_job with force set to false. If force is
-- false, dropping a job with running instances will fail.
PROCEDURE drop_job(
  job_name                IN VARCHAR2,
  force                   IN BOOLEAN      DEFAULT FALSE);

-- Set a value to be passed to one of the arguments of the program (either
-- named, or inlined). If program is inlined, only setting by position is
-- supported. The passed value will override any default value set during
-- definition of the program argument and overwrite any value previously set
-- for this argument position for this job (the previous value will be lost).
PROCEDURE set_job_argument_value(
  job_name                IN VARCHAR2,
  argument_position       IN PLS_INTEGER,
  argument_value          IN VARCHAR2);

-- This refers to a program argument by its name. It can only be used if the
-- job is using a named program (i.e. program_name points to an existing
-- program). The argument_name used must be the same name defined by the
-- program. 
PROCEDURE set_job_argument_value(
  job_name                IN VARCHAR2,
  argument_name           IN VARCHAR2,
  argument_value          IN VARCHAR2);

-- Same as above but accepts the default value encapsulated in an AnyData
PROCEDURE set_job_anydata_value(
  job_name                IN VARCHAR2,
  argument_position       IN PLS_INTEGER,
  argument_value          IN SYS.ANYDATA);

-- This refers to a program argument by its name. It can only be used if the
-- job is using a named program (i.e. program_name points to an existing
-- program). The argument_name used must be the same name defined by the
-- program. 
PROCEDURE set_job_anydata_value(
  job_name                IN VARCHAR2,
  argument_name           IN VARCHAR2,
  argument_value          IN SYS.ANYDATA);

-- Clear a previously set job argument value. All job specific value
-- information for this argument is erased. The job will revert back to the
-- default value for this argument as defined by the program (if any).
PROCEDURE reset_job_argument_value(
  job_name                IN VARCHAR2,
  argument_position       IN PLS_INTEGER);

-- This refers to a program argument by its name. It can only be used if the
-- job is using a named program (i.e. program_name points to an existing
-- program). The argument_name used must be the same name defined by the
-- program. 
PROCEDURE reset_job_argument_value(
  job_name                IN VARCHAR2,
  argument_name           IN VARCHAR2);

/*************************************************************
 * Job Class Administration Procedures
 *************************************************************
 */

-- Job Class attributes which can be used with set_attribute/get_attribute are:
--
-- resource_consumer_group - VARCHAR2
--                       resource consumer group a class is associated with
-- service             - VARCHAR2
--                       The service the job class belongs to. Default is NULL,
--                       which implies the default service. This should be the
--                       name of the service database object and not the
--                       service name as defined in tnsnames.ora .
-- log_purge_policy    - VARCHAR2
--                       The policy for purging of scheduler log table entries
--                       pertaining to jobs belonging to this class. By default
--                       log table entries are not purged.
-- comments             - VARCHAR2
--                       an optional comment about the class.

-- Create a job class.
PROCEDURE create_job_class(
  job_class_name          IN VARCHAR2,
  resource_consumer_group IN VARCHAR2     DEFAULT NULL,
  service                 IN VARCHAR2     DEFAULT NULL,
  logging_level           IN PLS_INTEGER  DEFAULT DBMS_SCHEDULER.LOGGING_RUNS,
  log_history             IN PLS_INTEGER  DEFAULT NULL,
  comments                IN VARCHAR2     DEFAULT NULL);

-- Drop a job class (or a comma-separated list of classes). This will return
-- an error if force is set to FALSE and
-- there are still jobs (in any state) that are part of this class.
-- If force is set to TRUE, all jobs that are part of this class will be
-- disabled and their class will be set to the default class.
PROCEDURE drop_job_class(
  job_class_name              IN VARCHAR2,
  force                   IN BOOLEAN DEFAULT FALSE);

/*************************************************************
 * System Window Administration Procedures
 *************************************************************
 */

-- System window attributes that can be used with set_attribute/get_attribute
-- are:
--
-- resource_plan       - VARCHAR2
--                       the resource plan to be associated with a window.
--                       When the window opens, the system will switch to
--                       using this resource plan. When the window closes, the
--                       original resource plan will be restored. If a
--                       resource plan has been made active with the force
--                       option, no resource plan switch will occur.
-- window_priority     - VARCHAR2
--                       The priority of the window. Must be one of
--                       'LOW' (default) , 'HIGH'.
-- duration            - INTERVAL DAY TO SECOND
--                       The duration of the window in minutes.
-- schedule_name       - VARCHAR2
--                       The name of a schedule to use with this window. If
--                       this is set, start_date, end_date and repeat_interval
--                       must all be NULL.
-- repeat_interval     - VARCHAR2
--                       A string using the calendar syntax. PL/SQL date
--                       functions are not allowed
--                       If this is set, schedule_name must be NULL
-- start_date          - TIMESTAMP WITH TIME ZONE
--                       next date on which this window is scheduled to open.
--                       If this is set, schedule_name must be NULL.
-- end_date            - TIMESTAMP WITH TIME ZONE
--                       the date after which the window will no longer open.
--                       If this is set, schedule_name must be NULL.
-- enabled             - BOOLEAN
--                       whether the window is enabled or not
-- comments             - VARCHAR2
--                       an optional comment about the window.
-- The below attribute is only visible through the views and not to
-- get_attribute or set_attribute
-- schedule_type     - VARCHAR2
--                     will be one of: 'CALENDAR_STRING', 'NAMED'

-- Create a system window using a named schedule object. The specified
-- schedule must exist.
PROCEDURE create_window(
  window_name             IN VARCHAR2,
  resource_plan            IN VARCHAR2,
  schedule_name           IN VARCHAR2,
  duration                IN INTERVAL DAY TO SECOND,
  window_priority         IN VARCHAR2                 DEFAULT 'LOW',
  comments                 IN VARCHAR2                 DEFAULT NULL);

-- Create a system window using an inlined schedule.
-- repeat_interval must use the calendar syntax. PL/SQL date functions are not
-- allowed.
PROCEDURE create_window(
  window_name             IN VARCHAR2,
  resource_plan           IN VARCHAR2,
  start_date              IN TIMESTAMP WITH TIME ZONE DEFAULT NULL,
  repeat_interval         IN VARCHAR2,
  end_date                IN TIMESTAMP WITH TIME ZONE DEFAULT NULL,
  duration                IN INTERVAL DAY TO SECOND,
  window_priority         IN VARCHAR2                 DEFAULT 'LOW',
  comments                 IN VARCHAR2                 DEFAULT NULL);

-- Drops a scheduler system window. Window name can also be a window group (in
-- which case all the windows in that window group are dropped) or a
-- comma-separated list of windows. Dropping a window disables all jobs which
-- use the window as a schedule (leaving currently running jobs running). If
-- the window is open, dropping it will attempt to close it first
-- The window is also dropped from any referring window groups.
PROCEDURE drop_window(
  window_name             IN VARCHAR2,
  force                   IN BOOLEAN DEFAULT FALSE);

-- Immediately opens a scheduler window independent of its specified schedule.
-- The window will be opened for the specified duration. If the duration is
-- null, the window will be opened for the duration as specified when the
-- window was created.
-- The next open time of the window is not updated, and will be as determined
-- by the regular scheduled opening.
-- Opening of the window will fail if the DBA has blocked the scheduler from
-- switching to a different resource plan.
-- If force option not specified and a current window is active the operation
-- will fail, unless the window is the current open window. 
-- If the current open window equals window_name, the closing time  is set to 
-- the system date plus the given duration, i.e. the closing time of the 
-- current window is moved up or down, but no jobs are stopped.
PROCEDURE open_window(
  window_name             IN VARCHAR2,
  duration                IN INTERVAL DAY TO SECOND,
  force                   IN BOOLEAN DEFAULT FALSE);

-- Prematurely closes the currently active window. This premature closing
-- of a window will have the same effect as a regular close e.g. any jobs that
-- have a window or a window group as their schedule and were started at the
-- beginning of this window because of that schedule and have indicated that
--they must be stopped on closing of the window, will be stopped.
PROCEDURE close_window(
  window_name             IN VARCHAR2);

/*************************************************************
 * System Window Administration Procedures
 *************************************************************
 */

-- enable and disable can be used on window groups. They disable/enable the
-- window group as a whole, not the individual windows in the group. 
--
-- member_list refers to a comma-separated list of windows
-- Window groups cannot contain other window groups.

-- Creates a window group optionally containing windows specified in
-- member_list.
PROCEDURE create_window_group(
  group_name             IN VARCHAR2,
  window_list            IN VARCHAR2 DEFAULT NULL,
  comments               IN VARCHAR2 DEFAULT NULL);

-- Adds a window (or comma-separated list of windows) to a window group.
-- If a window is already in the window group, it will not be added again.
PROCEDURE add_window_group_member(
  group_name             IN VARCHAR2,
  window_list            IN VARCHAR2);

-- Removes a window (or comma-separated list of windows) from a window group.
PROCEDURE remove_window_group_member(
  group_name             IN VARCHAR2,
  window_list            IN VARCHAR2);

-- Drops a window group (does not drop windows that are members of this group)
-- Returns an error when force is set to false and there are jobs whose
-- schedule is the name of the window group. If force is set to true, any jobs
-- whose schedule is the name of the window group will be disabled.
PROCEDURE drop_window_group(
  group_name             IN VARCHAR2,
  force                  IN BOOLEAN DEFAULT FALSE);

-- Get scheduler default time and timezone.
-- This would be used for jobs without a start time specified.
-- Follow default timezone can be set to simulate an object with 
-- this attribute set (i.e system windows etc).
FUNCTION stime (
        follow_default_timezone BOOLEAN DEFAULT FALSE) 
        RETURN TIMESTAMP WITH TIME ZONE;

-- Internal.
-- Used for initializing the scheduler default timezone.
FUNCTION get_sys_time_zone_name  RETURN VARCHAR2;

/*************************************************************
 * Schedule Administration Procedures
 *************************************************************
 */

-- Schedule attributes which can be used with set_attribute/get_attribute are :
--
-- repeat_interval   - VARCHAR2
--                     an expression using the calendar syntax
-- comments          - VARCHAR2
--                     an optional comment.
-- end_date          - TIMESTAMP WITH TIME ZONE
--                     cutoff date after which the schedule will not specify
--                     any dates
-- start_date        - TIMESTAMP WITH TIME ZONE
--                     start or reference date used by the calendar syntax
--
-- Schedules cannot be enabled and disabled.

-- Create a named schedule. This must be a valid schedule.
PROCEDURE create_schedule(
  schedule_name           IN VARCHAR2,
  start_date              IN TIMESTAMP WITH TIME ZONE  DEFAULT NULL,
  repeat_interval         IN VARCHAR2,
  end_date                IN TIMESTAMP WITH TIME ZONE  DEFAULT NULL,
  comments                IN VARCHAR2                  DEFAULT NULL);

--- Import helper function. 
PROCEDURE disable1_calendar_check;

-- Create a named event schedule. This must be a valid schedule.
PROCEDURE create_event_schedule(
  schedule_name           IN VARCHAR2,
  start_date              IN TIMESTAMP WITH TIME ZONE  DEFAULT NULL,
  event_condition         IN VARCHAR2,
  queue_spec              IN VARCHAR2,
  end_date                IN TIMESTAMP WITH TIME ZONE  DEFAULT NULL,
  comments                IN VARCHAR2                  DEFAULT NULL);

-- Drop a schedule (or comma-separated list of schedules). When force is set
-- to false, and there are jobs or windows
-- that point to this schedule an error will be raised.
-- If force is set to true, any jobs or windows pointing to this schedule will
-- be disabled before the schedule is dropped.
-- Schedules may refer to day calendar schedules in which case no checking 
-- occurs. Thus for day calendar drops  force is always assumed true, 
-- even if specified as false.
PROCEDURE drop_schedule(
  schedule_name           IN VARCHAR2,
  force                   IN BOOLEAN      DEFAULT FALSE);

/*************************************************************
 * Chain Administration Procedures
 *************************************************************
 */

-- Chain attributes which can be used with set_attribute/get_attribute
-- are :
--
-- comments            - VARCHAR2
--                       an optional comment.
-- evaluation_interval - INTERVAL DAY TO SECOND
--                       interval between periodic re-evaluations of a
--                       running chain
--

-- Creates a chain.
-- Chains are created disabled and must be enabled before use.
PROCEDURE create_chain(
  chain_name              IN VARCHAR2,
  rule_set_name           IN VARCHAR2   DEFAULT NULL,
  evaluation_interval     IN INTERVAL DAY TO SECOND DEFAULT NULL,
  comments                IN VARCHAR2   DEFAULT NULL);

-- adds or replaces a chain rule
PROCEDURE define_chain_rule(
  chain_name              IN VARCHAR2,
  condition               IN VARCHAR2,
  action                  IN VARCHAR2,
  rule_name               IN VARCHAR2 DEFAULT NULL,
  comments                IN VARCHAR2 DEFAULT NULL);

-- adds or replaces a chain step and associates it with a program
-- or chain
PROCEDURE define_chain_step(
  chain_name              IN VARCHAR2,
  step_name               IN VARCHAR2,
  program_name            IN VARCHAR2);

-- adds or replaces a chain step and associates it with an event schedule
PROCEDURE define_chain_event_step(
  chain_name              IN VARCHAR2,
  step_name               IN VARCHAR2,
  event_schedule_name     IN VARCHAR2,
  timeout                 IN INTERVAL DAY TO SECOND DEFAULT NULL);

-- adds or replaces a chain step and associates it with an inline event
PROCEDURE define_chain_event_step(
  chain_name              IN VARCHAR2,
  step_name               IN VARCHAR2,
  event_condition         IN VARCHAR2,
  queue_spec              IN VARCHAR2,
  timeout                 IN INTERVAL DAY TO SECOND DEFAULT NULL);

-- drops a chain rule
PROCEDURE drop_chain_rule(
  chain_name              IN VARCHAR2,
  rule_name               IN VARCHAR2,
  force                   IN BOOLEAN  DEFAULT FALSE);

-- drops a chain step
PROCEDURE drop_chain_step(
  chain_name              IN VARCHAR2,
  step_name               IN VARCHAR2,
  force                   IN BOOLEAN  DEFAULT FALSE);

-- alters steps of a chain
PROCEDURE alter_chain(
  chain_name              IN VARCHAR2,
  step_name               IN VARCHAR2,
  attribute               IN VARCHAR2,
  value                   IN BOOLEAN);

-- drops a chain
PROCEDURE drop_chain(
  chain_name              IN VARCHAR2,
  force                   IN BOOLEAN DEFAULT FALSE);

-- analyzes a chain or a list of steps and rules and outputs a list of
-- chain dependencies
PROCEDURE analyze_chain(
chain_name  IN VARCHAR2,
rules       IN sys.scheduler$_rule_list,
steps       IN sys.scheduler$_step_type_list,
step_pairs  OUT sys.scheduler$_chain_link_list);

-- alters steps of a running chain
PROCEDURE alter_running_chain(
  job_name                IN VARCHAR2,
  step_name               IN VARCHAR2,
  attribute               IN VARCHAR2,
  value                   IN BOOLEAN);

-- alters steps of a running chain
PROCEDURE alter_running_chain(
  job_name                IN VARCHAR2,
  step_name               IN VARCHAR2,
  attribute               IN VARCHAR2,
  value                   IN VARCHAR2);

-- forces immediate evaluation of a running chain
PROCEDURE evaluate_running_chain(
  job_name                IN VARCHAR2);

-- immediately runs a job pointing to a chain starting with a list of
-- specified steps. The job will be started in the background.
-- If start_steps is NULL, the chain is run from the beginning.
PROCEDURE run_chain(
  chain_name              IN VARCHAR2,
  start_steps             IN VARCHAR2,
  job_name                IN VARCHAR2 DEFAULT NULL);
-- immediately runs a job pointing to a chain starting with the given
-- list of step states. The job will be started in the background.
-- If step_state_list is NULL, the chain is run from the beginning.
PROCEDURE run_chain(
  chain_name              IN VARCHAR2,
  step_state_list         IN SYS.SCHEDULER$_STEP_TYPE_LIST,
  job_name                IN VARCHAR2 DEFAULT NULL);

/*************************************************************
 * Generic Procedures
 *************************************************************
 */

-- Disable a program, chain, job, window or window_group.
-- The procedure will NOT return an error if the object was already disabled.
-- It will return an error when force is set to false and:
--   name points to a program and there are jobs/chains pointing to the program
--   name points to a chain and there are jobs/chains pointing to the chain
--   name points to a window or window group and a job has that object as its
--     schedule
-- The only purpose of the force option is to point out dependencies. No
-- dependent objects are altered.
PROCEDURE disable(
  name                   IN VARCHAR2,
  force                  IN BOOLEAN DEFAULT FALSE);

-- Enable a program, chain, job, window or window group. The procedure will NOT
-- return an error if the object was already enabled.
PROCEDURE enable(
  name                  IN VARCHAR2);

-- Set an attribute of a scheduler object. Name can be the name of a program,
-- schedule, job, window, or job class. The procedure is overloaded to accept
-- different datatypes.
-- number types are implicitly converted to varchar2
PROCEDURE set_attribute(
  name                  IN VARCHAR2,
  attribute             IN VARCHAR2,
  value                 IN BOOLEAN);
PROCEDURE set_attribute(
  name                  IN VARCHAR2,
  attribute             IN VARCHAR2,
  value                 IN VARCHAR2,
  value2                IN VARCHAR2 DEFAULT NULL);
PROCEDURE set_attribute(
  name                  IN VARCHAR2,
  attribute             IN VARCHAR2,
  value                 IN DATE);
PROCEDURE set_attribute(
  name                  IN VARCHAR2,
  attribute             IN VARCHAR2,
  value                 IN TIMESTAMP);
PROCEDURE set_attribute(
  name                  IN VARCHAR2,
  attribute             IN VARCHAR2,
  value                 IN TIMESTAMP WITH TIME ZONE);
PROCEDURE set_attribute(
  name                  IN VARCHAR2,
  attribute             IN VARCHAR2,
  value                 IN TIMESTAMP WITH LOCAL TIME ZONE);
PROCEDURE set_attribute(
  name                  IN VARCHAR2,
  attribute             IN VARCHAR2,
  value                 IN INTERVAL DAY TO SECOND);

-- Set an attribute of a scheduler program to NULL
-- This is necessary because the overloading above does not allow NULL
-- as a valid value.
PROCEDURE set_attribute_null(
  name                  IN VARCHAR2,
  attribute             IN VARCHAR2);

-- Get the value of an attribute of a program, schedule, job, window, or job
-- class. The procedure is overloaded to support different datatypes for the
-- attribute values: PLS_INTEGER, BOOLEAN,VARCHAR2, all date types.
PROCEDURE get_attribute(
  name                  IN  VARCHAR2,
  attribute             IN  VARCHAR2,
  value                 OUT PLS_INTEGER);
PROCEDURE get_attribute(
  name                  IN  VARCHAR2,
  attribute             IN  VARCHAR2,
  value                 OUT BOOLEAN);
PROCEDURE get_attribute(
  name                  IN  VARCHAR2,
  attribute             IN  VARCHAR2,
  value                 OUT DATE);
PROCEDURE get_attribute(
  name                  IN  VARCHAR2,
  attribute             IN  VARCHAR2,
  value                 OUT TIMESTAMP);
PROCEDURE get_attribute(
  name                  IN  VARCHAR2,
  attribute             IN  VARCHAR2,
  value                 OUT TIMESTAMP WITH TIME ZONE);
PROCEDURE get_attribute(
  name                  IN  VARCHAR2,
  attribute             IN  VARCHAR2,
  value                 OUT TIMESTAMP WITH LOCAL TIME ZONE);
PROCEDURE get_attribute(
  name                  IN  VARCHAR2,
  attribute             IN  VARCHAR2,
  value                 OUT INTERVAL DAY TO SECOND);
PROCEDURE get_attribute(
  name                  IN  VARCHAR2,
  attribute             IN  VARCHAR2,
  value                 OUT VARCHAR2);
PROCEDURE get_attribute(
  name                  IN  VARCHAR2,
  attribute             IN  VARCHAR2,
  value                 OUT VARCHAR2,
  value2                OUT VARCHAR2);

/*************************************************************
 * Special Scheduler Administrative Procedures
 *************************************************************
 */

-- There are several scheduler attributes that control the behavior of the
-- scheduler. These have defaults but a DBA may wish to change the default
-- settings or view the current settings. These two functions are provided for
-- this purpose.
-- Even though the scheduler attributes have different types (e.g. strings,
-- numbers) all the values are passed as string literals. The set
-- procedure requires the MANAGE SCHEDULER privilege.
-- This takes effect immediately, but the resulting changes may not be seen
-- immediately.
-- Attributes which may be set are:
-- 'MAX_SLAVE_PROCESSES'(pls_integer), 'DEFAULT_LOG_PURGE_POLICY'(varchar2),
-- 'LOG_HISTORY' (pls_integer)

-- Set the value of a scheduler attribute. This takes effect immediately,
-- but the resulting changes may not be seen immediately.
PROCEDURE set_scheduler_attribute(
  attribute          IN VARCHAR2,
  value              IN VARCHAR2);

-- Get the value of a scheduler attribute.
PROCEDURE get_scheduler_attribute(
  attribute          IN VARCHAR2,
  value             OUT VARCHAR2);

PROCEDURE add_event_queue_subscriber(
  subscriber_name    IN VARCHAR2 DEFAULT NULL);

PROCEDURE remove_event_queue_subscriber(
  subscriber_name    IN VARCHAR2 DEFAULT NULL);

-- The following procedure purges from the logs based on the arguments
-- The default is to purge all entries
PROCEDURE purge_log(
  log_history        IN PLS_INTEGER DEFAULT 0,
  which_log          IN VARCHAR2    DEFAULT 'JOB_AND_WINDOW_LOG',
  job_name           IN VARCHAR2    DEFAULT NULL);


/*************************************************************
 * Auxiliary Functions and Procedures
 *************************************************************
 */

-- This function returns a unique name for a job.
-- If prefix is NULL this will be a number from a sequence, otherwise
-- it will be of the form {prefix}N where N is a number from a sequence.
FUNCTION generate_job_name(
  prefix            IN VARCHAR2 DEFAULT 'JOB$_') RETURN VARCHAR2 ;

-- These functions are for internal scheduler use.
FUNCTION check_sys_privs RETURN PLS_INTEGER ;

FUNCTION get_varchar2_value (a SYS.ANYDATA) RETURN VARCHAR2;

-- The following procedure purges from the logs based on class and global
-- log_history
PROCEDURE auto_purge;

-- This accepts an attribute name and returns the default value.
-- If the attribute is not recognized it returns NULL.
-- If the attribute is of type BOOLEAN, it will return 'TRUE' or 'FALSE'.
FUNCTION get_default_value (attribute_name VARCHAR2) RETURN VARCHAR2 ;

-- this is used by chain views to output rule actions
FUNCTION get_chain_rule_action(action_in IN re$nv_list) RETURN VARCHAR2;

-- this is used by chain views to output rule conditions
FUNCTION get_chain_rule_condition(action_in IN re$nv_list, condition_in IN VARCHAR2)
  RETURN VARCHAR2;

-- this is used to retrieve the canonicalized object owner or name
FUNCTION resolve_name(
   full_name      IN VARCHAR2,
   default_owner  IN VARCHAR2,
   return_part    IN NUMBER) RETURN VARCHAR2;

/*************************************************************
 * Calendar utility functions for schedule type sched_calendar_string
 *************************************************************
 */

TYPE bylist IS VARRAY (256) OF PLS_INTEGER;

Yearly     Constant Pls_Integer := 1;
Monthly    Constant Pls_Integer := 2;
Weekly     Constant Pls_Integer := 3;
Daily      Constant Pls_Integer := 4;
Hourly     Constant Pls_Integer := 5;
Minutely   Constant Pls_Integer := 6;
Secondly   Constant Pls_Integer := 7;


Monday     Constant Integer := 1;
Tuesday    Constant Integer := 2;
Wednesday  Constant Integer := 3;
Thursday   Constant Integer := 4;
Friday     Constant Integer := 5;
Saturday   Constant Integer := 6;
Sunday     Constant Integer := 7;

-- byday_days contains list of days
-- byday_occurrence contains the corresponding monthly (or yearly)
--   occurrence -5 .. -1,0, 1 .. 5    // 0 meaning any this weekday

-- Example  BYDAY=-2MO, -1MO, 1MO, TU
-- byday_day = Monday,Monday,Monday,Tuesday
-- byday_orrurrence= -2,-1, 1, 0

Procedure create_calendar_string(
   frequency         in   pls_integer,
   interval          in   pls_integer,
   bysecond          in   bylist,
   byminute          in   bylist,
   byhour            in   bylist,
   byday_days        in   bylist,
   byday_occurrence  in   bylist,
   bymonthday        in   bylist,
   byyearday         in   bylist,
   byweekno          in   bylist,
   bymonth           in   bylist,
   calendar_string   out  Varchar2);
--
Procedure resolve_calendar_string(
   calendar_string   in   varchar2,
   frequency         out  pls_integer,
   interval          out  pls_integer,
   calendars_used    out  boolean,
   bysecond          out  scheduler$_int_array_type,
   byminute          out  scheduler$_int_array_type,
   byhour            out  scheduler$_int_array_type,
   byday_days        out  scheduler$_int_array_type,
   byday_occurrence  out  scheduler$_int_array_type,
   bydate_y          out  scheduler$_int_array_type,
   bydate_md         out  scheduler$_int_array_type,
   bymonthday        out  scheduler$_int_array_type,
   byyearday         out  scheduler$_int_array_type,
   byweekno          out  scheduler$_int_array_type,
   bymonth           out  scheduler$_int_array_type,
   bysetpos          out  scheduler$_int_array_type);


Procedure resolve_calendar_string(
   calendar_string   in   varchar2,
   frequency         out  pls_integer,
   interval          out  pls_integer,
   bysecond          out  bylist,
   byminute          out  bylist,
   byhour            out  bylist,
   byday_days        out  bylist,
   byday_occurrence  out  bylist,
   bymonthday        out  bylist,
   byyearday         out  bylist,
   byweekno          out  bylist,
   bymonth           out  bylist);

-- Repeat intervals of jobs, windows or schedules are defined using the
-- scheduler's calendar syntax. This procedure evaluates the calendar string
-- and tells you what the next execution date of a job or window will be. This
-- is very useful for testing the correct definition of the calendar string
-- without having to actually schedule the job or window.
--
-- Parameters
-- calendar_string    The to be evaluated calendar string.
-- start_date         The date by which the calendar string becomes valid.
--                    It might also be used to fill in specific items that are
--                    missing from the calendar string. Can optionally be NULL.
-- return_date_after  With the start_date and the calendar string the scheduler
--                    has sufficient information to determine all valid 
--                    execution dates. By setting this argument the scheduler 
--                    determines which one of all possible matches to return.
--                    When a NULL value is passed for this argument the 
--                    scheduler automatically fills in systimestamp as its 
--                    value.
-- next_run_date      The first timestamp that matches the calendar string and
--                    start date that occurs after the value passed in for the
--                    return_date_after argument.



-- This procedure can also be used to get multiple steps of the repeat interval
-- by passing the next_run_date returned by one invocation as the
-- return_date_after argument of the next invocation of this procedure.

Procedure evaluate_calendar_string(
   calendar_string    in  varchar2,
   start_date         in  timestamp with time zone,
   return_date_after  in  timestamp with time zone,
   next_run_date      OUT timestamp with time zone);

-- Internal function. Do not document.
FUNCTION get_job_step_cf
(
   iec                         VARCHAR2, 
   icn                         VARCHAR2, 
   vname                       VARCHAR2, 
   iev                         SYS.RE$NV_LIST
) RETURN SYS.RE$VARIABLE_VALUE;

FUNCTION generate_event_list(statusvec NUMBER) return VARCHAR2;

END dbms_scheduler;
/

show errors;
/

CREATE OR REPLACE PUBLIC SYNONYM dbms_scheduler FOR dbms_scheduler
/

GRANT EXECUTE ON dbms_scheduler TO PUBLIC WITH GRANT OPTION
/
