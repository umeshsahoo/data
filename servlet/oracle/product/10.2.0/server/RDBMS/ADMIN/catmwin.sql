Rem
Rem $Header: catmwin.sql 23-feb-2005.16:21:16 mtakahar Exp $
Rem
Rem catmwin.sql
Rem
Rem Copyright (c) 2003, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catmwin.sql - Catalog script for Maintenance WINdow
Rem
Rem    DESCRIPTION
Rem      Defines maintenance window and stats collection job.
Rem
Rem    NOTES
Rem      Must be run when connected as SYSDBA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mtakahar    02/23/05 - #(4175406) change gather_stats_* comments
Rem    mtakahar    09/15/04 - gather_stats_job termination callback
Rem    ilistvin    07/14/04 - move set_attribute outside exception block 
Rem    smuthuli    04/26/04 - auto space advisor 
Rem    jxchen      12/19/03 - Set "restartable" attribute for GATHER_STATS_JOB 
Rem    schakkap    12/05/03 - stop auto stats collection at end of mgmt window 
Rem    evoss       12/02/03 - 
Rem    evoss       11/17/03 - add follow_default_timezone attr for windows and 
Rem    rramkiss    06/16/03 - flag system-managed objects
Rem    rramkiss    06/16/03 - suppress already_exists errors
Rem    jxchen      06/12/03 - Add job definition
Rem    jxchen      06/04/03 - jxchen_mwin_main
Rem    jxchen      05/12/03 - Created
Rem

-- Create weeknight window.  Weeknight window is 10pm - 6am Mon - Fri. 
BEGIN
   BEGIN
   dbms_scheduler.create_window(
      window_name=>'WEEKNIGHT_WINDOW',
      resource_plan=>NULL,
      repeat_interval=>'freq=daily;byday=MON,TUE,WED,THU,FRI;byhour=22;' ||
                    'byminute=0; bysecond=0',
      duration=>interval '480' minute,
      comments=>'Weeknight window for maintenance task');
   EXCEPTION
      when others then
        if sqlcode = -27477 then NULL;
        else raise;
        end if;
   END;
   dbms_scheduler.set_attribute('WEEKNIGHT_WINDOW','SYSTEM',TRUE);
   dbms_scheduler.set_attribute('WEEKNIGHT_WINDOW',
                                 'FOLLOW_DEFAULT_TIMEZONE',TRUE);
EXCEPTION
      when others then
        if sqlcode = -27477 then NULL;
        else raise;
        end if;
END;
/

-- Create weekend window.  Weekend window is from 12am Saturday through 12am
-- Monday.
BEGIN 
    BEGIN
    dbms_scheduler.create_window(
       window_name=>'WEEKEND_WINDOW',
       resource_plan=>NULL,
       repeat_interval=>'freq=daily;byday=SAT;byhour=0;byminute=0;bysecond=0',
       duration=>interval '2880' minute,
       comments=>'Weekend window for maintenance task');
    EXCEPTION
      when others then
        if sqlcode = -27477 then NULL;
        else raise;
        end if;
    END;
    dbms_scheduler.set_attribute('WEEKEND_WINDOW','SYSTEM',TRUE);
    dbms_scheduler.set_attribute('WEEKEND_WINDOW',
                                 'FOLLOW_DEFAULT_TIMEZONE',TRUE);
EXCEPTION
      when others then
        if sqlcode = -27477 then NULL;
        else raise;
        end if;
END;
/ 

-- Create maintenance window group and add weeknight and weekend windows to it.
BEGIN
   BEGIN
   dbms_scheduler.create_window_group('MAINTENANCE_WINDOW_GROUP');
   dbms_scheduler.add_window_group_member('MAINTENANCE_WINDOW_GROUP', 
                    'WEEKNIGHT_WINDOW');
   dbms_scheduler.add_window_group_member('MAINTENANCE_WINDOW_GROUP', 
                    'WEEKEND_WINDOW');
   EXCEPTION
     when others then
       if sqlcode = -27477 then NULL;
       else raise;
       end if;
   END;
   dbms_scheduler.set_attribute('MAINTENANCE_WINDOW_GROUP','SYSTEM',TRUE);
EXCEPTION
      when others then
        if sqlcode = -27477 then NULL;
        else raise;
        end if;
END;
/ 

-- Create gather stats program.
BEGIN
dbms_scheduler.create_program(
  program_name=>'gather_stats_prog', 
  program_type=>'STORED_PROCEDURE', 
  program_action=>'dbms_stats.gather_database_stats_job_proc',
  number_of_arguments=>0,
  enabled=>TRUE,
  comments
      =>'Oracle defined automatic optimizer statistics collection program');
EXCEPTION
  when others then
    if sqlcode = -27477 then NULL;
    else raise;
    end if;
END;
/

-- Create auto space advisor program.
BEGIN
dbms_scheduler.create_program(
  program_name=>'auto_space_advisor_prog',
  program_type=>'STORED_PROCEDURE',
  program_action=>'dbms_space.auto_space_advisor_job_proc',
  number_of_arguments=>0,
  enabled=>TRUE,
  comments=>'auto space advisor maintenance program');
EXCEPTION
  when others then
    if sqlcode = -27477 then NULL;
    else raise;
    end if;
END;
/



-- Create resource manager consumer group.
execute dbms_resource_manager.create_pending_area;

BEGIN
  dbms_resource_manager.create_consumer_group(
     consumer_group=>'AUTO_TASK_CONSUMER_GROUP', 
     comment=>'System maintenance task consumer group');
EXCEPTION
  when others then
    if sqlcode = -29357 then NULL;
    else raise;
    end if;
END; 
/

execute dbms_resource_manager.submit_pending_area;

-- Create autotask job class
BEGIN 
   BEGIN
      sys.dbms_scheduler.create_job_class(
        job_class_name=>'AUTO_TASKS_JOB_CLASS', 
        resource_consumer_group=>'AUTO_TASK_CONSUMER_GROUP',
        comments=>'System maintenance job class');
    EXCEPTION
      when others then
        if sqlcode = -27477 then NULL;
        else raise;
        end if;
    END;
    dbms_scheduler.set_attribute('AUTO_TASKS_JOB_CLASS','SYSTEM',TRUE);
EXCEPTION
  when others then
    if sqlcode = -27477 then NULL;
    else raise;
    end if;
END;
/

-- Create stats collection job
BEGIN
    BEGIN
    dbms_scheduler.create_job(
      job_name=>'gather_stats_job',
      program_name=>'gather_stats_prog',
      job_class=>'auto_tasks_job_class',
      schedule_name=>'MAINTENANCE_WINDOW_GROUP',
      enabled=>TRUE,
      auto_drop=>FALSE,
      comments
          =>'Oracle defined automatic optimizer statistics collection job');
    EXCEPTION
      when others then
        if sqlcode = -27477 then NULL;
        else raise;
        end if;
    END;
    dbms_scheduler.set_attribute('gather_stats_job','stop_on_window_close', 
             true);
    dbms_scheduler.set_attribute('gather_stats_job','restartable', true);
    dbms_scheduler.set_attribute('gather_stats_job',
        'user_operations_callback','dbms_stats.cleanup_stats_job_proc');
    dbms_scheduler.set_attribute('gather_stats_job','user_callback_context',1);
EXCEPTION
  when others then
    if sqlcode = -27477 then NULL;
    else raise;
    end if;
END;
/

-- Create auto space advisor maintenancejob
BEGIN
    BEGIN
    dbms_scheduler.create_job(
      job_name=>'auto_space_advisor_job',
      program_name=>'auto_space_advisor_prog',
      job_class=>'auto_tasks_job_class',
      schedule_name=>'MAINTENANCE_WINDOW_GROUP',
      enabled=>TRUE,
      auto_drop=>FALSE,
      comments=>'auto space advisor maintenance job');
    EXCEPTION
      when others then
        if sqlcode = -27477 then NULL;
        else raise;
        end if;
    END;
    dbms_scheduler.set_attribute('auto_space_advisor_job',
             'stop_on_window_close', true);
    dbms_scheduler.set_attribute('auto_space_advisor_job','restartable', true);
EXCEPTION
  when others then
    if sqlcode = -27477 then NULL;
    else raise;
    end if;
END;
/
