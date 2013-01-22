Rem
Rem $Header: utlclust.sql 13-apr-2001.19:15:03 eyho Exp $
Rem
Rem utlclust.sql
Rem
Rem  Copyright (c) Oracle Corporation 2001. All Rights Reserved.
Rem
Rem    NAME
Rem      utlclust.sql - Utility to cluster database information
Rem
Rem    DESCRIPTION
Rem      Dump cluster database related information
Rem
Rem    NOTES
Rem      It only dumps enqueue tree across the cluster for the moment. More
Rem      cluster related information can be collected from this script.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    eyho        04/13/01 - Merged eyho_bug-1393413
Rem    eyho        04/09/01 - Merged eyho_rac_name_changes
Rem    aksrivas    02/22/99 - Create utility to dump dlm lock wait-for-graphs
Rem    aksrivas    02/22/99 - Created
Rem

/* Print out the enqueue wait-for graph in a tree structured fashion.
 *
 * This script  prints  the  instance and OS PIDs (as instance-OS PID string in
 * the first column of the output) in the system that are waiting for global
 * locks,  and the locks that they  are waiting for.   The  printout is tree
 * structured.  If a instance-OS PID string is printed immediately below and to
 * the right of another instance-OS PID string, then it is waiting for that
 * instance-OS PID. The instance-OS PID ids printed at the left hand side of
 * the output are  the ones  that everyone is waiting for.
 *
 * For example, in the following printout process 13528 on instance 3 is waiting
 * for process 13526 on instance 2 which is waiting for process 13524 on
 * instance 1.
 *
 * WAITING_PROCESS    [ID1][ID2],[TYPE]              REQUEST_MODE  BLOCKED_MODE
 * ------------------ ------------------------------ ------------- -------------
 * 1-13524
 *    2-13526         [0x10005][0x216],[TX]          Exclusive     Exclusive
 *       3-13528      [0x20014][0x4],[TX]            Exclusive     Exclusive
 *
 * The lock information to the right of the session id describes the lock
 * that the process is waiting for (not the lock it is holding).
 *
 * This script has two  small disadvantages.  One, a  table is created  when
 * this  script is run.   To create  a table   a  number of   locks must  be
 * acquired. This  might cause the session running  the script to get caught
 * in the lock problem it is trying to diagnose.  Two, if a process waits on
 * a lock held by more than one process (share lock) then the wait-for graph
 * is no longer a tree  and the  conenct-by will show the process  (and  any
 * processes waiting on it) several times.
 *
 */

drop table lock_holders;

create table LOCK_HOLDERS   /* temporary table */
(
  waiting_instance_process   varchar2(16),
  holding_instance_process   varchar2(16),
  resource_name              varchar2(30),
  grant_level                varchar2(13),
  request_level              varchar2(13)
);

drop   table dlm_locks_temp;
create table dlm_locks_temp as select * from gv$dlm_locks;

/* select all blockers */
insert into lock_holders
  select concat(concat(w.inst_id, '-'), w.pid),
         concat(concat(h.inst_id, '-'), h.pid),
        w.resource_name1,
        h.grant_level,
        w.request_level
  from dlm_locks_temp w, dlm_locks_temp h
 where h.blocker = 1
  and  (w.inst_id != h.inst_id or  w.pid != h.pid)
  and  w.resource_name1    =  h.resource_name1
  and  h.grant_level      !=  'KJUSERNL'
  and  w.request_level    !=  'KJUSERNL';
commit;

drop table dlm_locks_temp;

/*
 * generate rows for ultimate blockers of wait-for-graphs to facilitae
 * recursive select used for printing below.
 */
insert into lock_holders
  select holding_instance_process, null, null, null, null
    from lock_holders
 minus
  select waiting_instance_process, null, null, null, null
    from lock_holders;
commit;

/* Print out the result in a tree structured fashion */
select  lpad(' ',3*(level-1)) || waiting_instance_process as waiting_process,
        resource_name as "[ID1][ID2],[TYPE]",
        decode(substr(request_level,1,8),
               'KJUSERNL','Null',
               'KJUSERCR','Row-S (SS)',
               'KJUSERCW','Row-X (SX)',
               'KJUSERPR','Share',
               'KJUSERPW','S/Row-X (SSX)',
               'KJUSEREX','Exclusive',
               request_level)
               as request_mode,
        decode(substr(grant_level,1,8),
               'KJUSERNL','Null',
               'KJUSERCR','Row-S (SS)',
               'KJUSERCW','Row-X (SX)',
               'KJUSERPR','Share',
               'KJUSERPW','S/Row-X (SSX)',
               'KJUSEREX','Exclusive',
               grant_level)
              as blocked_mode
 from lock_holders
connect by  prior waiting_instance_process = holding_instance_process
  start with holding_instance_process is null;

drop table lock_holders;
