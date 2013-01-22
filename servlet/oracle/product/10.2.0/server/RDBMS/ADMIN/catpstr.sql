Rem
Rem $Header: catpstr.sql 31-mar-2005.13:17:56 alakshmi Exp $
Rem
Rem catpstr.sql
Rem
Rem Copyright (c) 2001, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catpstr.sql - load STREAMS pl/sql packages
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    alakshmi    03/31/05 - split prvthstr.sql, prvtbstr.sql 
Rem    narora      03/03/05 - add prvthprp 
Rem    htran       06/15/04 - disable file group job. move prvthlin.plb
Rem    dcassine    05/27/04 - added prvthlua and prvtblua
Rem    htran       04/27/04 - grant read_any_file_group to EXP_FULL_DATABASE
Rem    alakshmi    04/19/04 - system privilege READ_ANY_FILE_GROUP 
Rem    htran       04/14/04 - create autopurge job for file groups
Rem    htran       03/10/04 - register file group procedure object export
Rem    htran       03/02/04 - register file group export import
Rem    alakshmi    02/16/04 - add dbmsfgr.sql 
Rem    rramkiss    04/22/03 - move prvtdsch.plb
Rem    rramkiss    04/10/03 - load prvtdsch.plb for distributed job scheduling
Rem    alakshmi    04/08/03 - Load dbmsstr.sql after dbmssts.sql
Rem    jstamos     03/18/03 - add dbms_streams_tablespaces
Rem    nshodhan    04/15/03 - move prvthlut.plb to catproc
Rem    htran       02/14/03 - load prvtbsdp.plb
Rem    elu         02/03/03 - move prvtlmrd
Rem    elu         01/14/03 - remove prvthlrp, prvtblrp
Rem    apadmana    07/24/02 - Add prvthcdc.plb
Rem    liwong      07/09/02 - Get prvthsrp, prvtbsrp
Rem    alakshmi    01/29/02 - Bug 2190723: move dbmslcr/prvthlcr to the top
Rem    wesmith     01/10/02 - change level# for schema-level export action
Rem    alakshmi    11/08/01 - Merged alakshmi_apicleanup
Rem    wesmith     11/06/01 - prvthlcr before dbmslcr
Rem    wesmith     11/03/01 - add dbmsprp, prvtbprp
Rem    wesmith     11/01/01 - register export procedural actions for streams
Rem    wesmith     10/23/01 - add apply, capture packages
Rem    liwong      10/23/01 - Created
Rem

Rem package specifications
@@prvthlcr.plb
@@dbmslcr.sql

@@dbmssts.sql
@@prvthsts.plb

@@prvthrse.plb
@@prvthsmt.plb

Rem dbmsstr should be loaded after dbmslcr
@@dbmsstr.sql
@@prvthstr.plb
@@dbmsapp.sql
@@prvthapp.plb
@@dbmscap.sql
@@dbmsprp.sql
@@prvthcap.plb
@@prvthprp.plb

Rem prvthlut.plb will be loaded by catproc
Rem prvthlin.plb will be loaded by catproc
@@prvthlru.plb
@@prvthsrp.plb
@@prvthcdc.plb
@@prvthlua.plb

Rem logiminer replication package
@@prvtlmrd.plb

Rem File Group headers
@@dbmsfgr.sql
@@prvthfgr.plb
@@prvthfie.plb

Rem package bodies
@@prvtbrse.plb
@@prvtbsmt.plb
@@prvtbstr.plb
@@prvtbapp.plb
@@prvtbcap.plb
@@prvtbprp.plb
@@prvtblcr.plb
@@prvtblru.plb
@@prvtblut.plb
@@prvtblin.plb
@@prvtbsrp.plb
@@prvtbcdc.plb
-- NOTE: prvthsdp.plb is loaded in catproc.sql since prvtlsby.sql needs it
@@prvtbsdp.plb
@@prvtbsts.plb
@@prvtblua.plb

Rem Job Scheduler - distributed job scheduling setup (requires prvtbstr)
@@prvtdsch.plb

Rem File Group bodies
@@prvtbfgr.plb
@@prvtbfie.plb

--
-- Grant manage/read_any_file_group privilege to DBA. SYSTEM has the DBA role
-- and should inherit this privilege.
--
BEGIN
  dbms_file_group.grant_system_privilege(
    privilege => dbms_file_group.manage_file_group,
    grantee => 'DBA',
    grant_option => TRUE);
END;
/
BEGIN
  dbms_file_group.grant_system_privilege(
    privilege => dbms_file_group.manage_any_file_group,
    grantee => 'DBA',
    grant_option => TRUE);
END;
/
BEGIN
  dbms_file_group.grant_system_privilege(
    privilege => dbms_file_group.read_any_file_group,
    grantee => 'DBA',
    grant_option => TRUE);
END;
/

-- this grant is for full database export
BEGIN
  dbms_file_group.grant_system_privilege(
    privilege => dbms_file_group.read_any_file_group,
    grantee => 'EXP_FULL_DATABASE',
    grant_option => FALSE);
END;
/

Rem register dbms_logrep_exp for system, schema 
Rem and extended instance level procedural actions

Rem system-level
Rem This should be on of the first system-level actions to be executed,
Rem so set level# to 1.
DELETE FROM exppkgact$ WHERE package = 'DBMS_LOGREP_EXP'
  AND schema = 'SYS' AND class = 1
/
INSERT INTO exppkgact$ (package, schema, class, level#)
VALUES ('DBMS_LOGREP_EXP', 'SYS', 1, 1)
/

Rem schema-level
Rem This should be one of the last schema-level actions to be executed,
Rem so set level# to 5000
DELETE FROM exppkgact$ WHERE package = 'DBMS_LOGREP_EXP'
  AND schema = 'SYS' AND class = 2
/
INSERT INTO exppkgact$ (package, schema, class, level#)
VALUES ('DBMS_LOGREP_EXP', 'SYS', 2, 5000)
/

Rem extended-instance level
DELETE FROM exppkgact$ WHERE package = 'DBMS_LOGREP_EXP'
  AND schema = 'SYS' AND class = 4
/
INSERT INTO exppkgact$ (package, schema, class, level#)
VALUES ('DBMS_LOGREP_EXP', 'SYS', 4, 1)
/


Rem register dbms_file_group_exp for schema level export
Rem schema-level procedural actions
Rem Import file group metadata before Streams, so set level to 4000
DELETE FROM exppkgact$ WHERE package = 'DBMS_FILE_GROUP_EXP'
  AND schema = 'SYS' AND class = 2
/
INSERT INTO exppkgact$ (package, schema, class, level#)
VALUES ('DBMS_FILE_GROUP_EXP', 'SYS', 2, 4000)
/

Rem post-schema procedural objects
DELETE FROM exppkgobj$ WHERE package = 'DBMS_FILE_GROUP_EXP'
  AND schema = 'SYS' AND class = 2
/
INSERT INTO exppkgobj$ (package, schema, class, type#, prepost, level#)
VALUES ('DBMS_FILE_GROUP_EXP', 'SYS', 2, 81, 1, 4000)
/

-- create auto-purge job for file groups
BEGIN
  dbms_scheduler.create_job(
  job_name        => 'FGR$AUTOPURGE_JOB',
  job_type        => 'PLSQL_BLOCK',
  job_action      => 'sys.dbms_file_group.purge_file_group(NULL);',
  repeat_interval => 'freq=daily;byhour=0;byminute=0;bysecond=0',
  enabled         => FALSE,
  comments        => 'file group auto-purge job');

  dbms_scheduler.set_attribute('FGR$AUTOPURGE_JOB',
    'FOLLOW_DEFAULT_TIMEZONE',TRUE);
EXCEPTION WHEN others THEN
    IF sqlcode = -27477 THEN
       NULL;
    ELSE RAISE;
    END IF;
END;
/
