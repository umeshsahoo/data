Rem
Rem $Header: catdwgrd.sql 28-mar-2005.09:31:25 rburns Exp $
Rem
Rem catdwgrd.sql
Rem
Rem Copyright (c) 2000, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catdwgrd.sql -  DataBase DoWnGrade from the current release 
Rem                      to the original release (if supported)
Rem
Rem    DESCRIPTION
Rem
Rem      This script is to be used for downgrading your database from the
Rem      current release you have installed to the release from which 
Rem      you upgraded.
Rem
Rem    NOTES
Rem      * This script needs to be run in the current release's environment
Rem        (before installing the release to which you want to downgrade).
Rem      * You must be connected AS SYSDBA to run this script.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rburns      03/28/05 - enable component check 
Rem    rburns      03/14/05 - dbms_registry_sys timestamp 
Rem    rburns      02/27/05 - record action for history 
Rem    attran      11/04/04 - check for XMLIDX
Rem    htran       07/26/04 - check for commit-time queue tables
Rem    rburns      06/28/04 - consolidate warnings 
Rem    clei        06/10/04 - disallow downgrade if encrypted columns exist
Rem    rburns      05/17/04 - rburns_single_updown_scripts
Rem    rburns      02/04/04 - Created

Rem =======================================================================
Rem Exit immediately if there are errors in the initial checks
Rem =======================================================================

WHENEVER SQLERROR EXIT;

Rem Check instance version and status; set session attributes
EXECUTE dbms_registry.check_server_instance;

Rem Determine the previous release 
CREATE OR REPLACE FUNCTION version_script
RETURN VARCHAR2 IS

  p_prv_version VARCHAR2(30);

BEGIN
  -- Get the previous version of the CATPROC component
  SELECT prv_version INTO p_prv_version
  FROM registry$ WHERE cid='CATPROC';

  IF substr(p_prv_version, 1, 5) = '9.2.0' THEN
     RETURN '0902000';
  ELSIF substr(p_prv_version, 1, 6) = '10.1.0' THEN
     RETURN '1001000';
  ELSE
     RAISE_APPLICATION_ERROR(-20000,
       'Downgrade not supported to version ' || p_prv_version );
  END IF;
END version_script;
/

Rem get the version correct into the "downgrade_file" variable
COLUMN file_name NEW_VALUE downgrade_file NOPRINT;
SELECT version_script AS file_name FROM DUAL;
DROP function version_script;

Rem =========================================================================
Rem BEGIN STAGE 1: Perform checks prior to downgrade to previous release
Rem =========================================================================

SET SERVEROUTPUT ON
SET VERIFY OFF

Rem Verify that compatibility is not greater than previous release
DECLARE
  compat          VARCHAR2(30);
  major           NUMBER;
  minor           NUMBER;
BEGIN
-- Check compatible parameter
   select value into compat from v$parameter
   where name='compatible';
   major := TO_NUMBER(substr(compat,1,instr(compat,'.',1)-1));
   minor := TO_NUMBER(substr(compat,instr(compat,'.',1)+1,1)); 

   if '&downgrade_file' = '0902000' THEN
      if major > 9 then
          dbms_sys_error.raise_system_error(-39707, compat, '9.2.0'); 
      end if;
   else
      if major > 10 OR (major = 10 and minor > 1) then 
          dbms_sys_error.raise_system_error(-39707, compat, '10.1.0');  
      end if; 
   end if;
END;
/

Rem =========================================================================
Rem Perform 10.1 downgrade checks
Rem =========================================================================

DOC
#######################################################################
#######################################################################

 If the below PL/SQL block raises an ORA-30957 error, use the following
 query to identify XMLINDEXes that need to be dropped.

   SELECT index_owner, index_name
   FROM dba_xml_indexes;

 Drop all the XML indexes shown in the above query before downgrade.

#######################################################################
#######################################################################
#

Rem Raise error if there are XML indexes
DECLARE
   cnt                 NUMBER;
   xix_downgrade_error exception;
   PRAGMA EXCEPTION_INIT(xix_downgrade_error, -30957);
   missing exception;
   PRAGMA EXCEPTION_INIT(missing, -942);
BEGIN
   execute immediate 'select count(*) from xdb.xdb$dxptab' into cnt;
   IF cnt != 0 THEN
     RAISE xix_downgrade_error;
   END IF;
exception
   when missing then NULL; 
   when OTHERS then RAISE;
END;
/

DOC
#######################################################################
#######################################################################

 If the below PL/SQL block raises an ORA-25331 error, use the following
 query to identify commit-time queue tables that need to be dropped.

   SELECT owner, queue_table
   FROM dba_queue_tables
   WHERE sort_order like '%COMMIT_TIME%';

 Drop all the queue tables shown in the above query before downgrade.

#######################################################################
#######################################################################
#

Rem Raise error if there are commit-time queue tables
DECLARE
  cnt                 NUMBER;
  ct_downgrade_error  exception;
  PRAGMA EXCEPTION_INIT(ct_downgrade_error, -25331);
BEGIN
  select count(*) into cnt from dba_queue_tables where
    sort_order like '%COMMIT_TIME%';
  IF cnt != 0 THEN
    RAISE ct_downgrade_error; 
  END IF;
END;
/

DOC
#######################################################################
#######################################################################

 If the following PL/SQL block gets an ORA-25427 error, use the 
 following  query to list all the database links that must be dropped
 prior to downgrading:

 SELECT  name, flag  FROM sys.link$
 WHERE  bitand(flag, 2) = 2; 

 Consult Oracle  documentation for instructions to drop a database link.

#######################################################################
#######################################################################
#

Rem Raise errors if database link data dictionary has passwords
DECLARE
  CURSOR d_link IS
  SELECT  name, flag  FROM sys.link$;
  dblink_upgraded_error exception;
  PRAGMA EXCEPTION_INIT(dblink_upgraded_error, -25427);
BEGIN
  FOR rec IN d_link LOOP
    -- Raise error if dblink data dictionary has passwords
   IF bitand(rec.flag, 2) = 2 THEN
      RAISE dblink_upgraded_error;
    END IF;
  END LOOP;
END;
/

DOC
#######################################################################
#######################################################################

 If the following PL/SQL block raises an ORA-26740 error, use the following
 query to identify file groups that need to be dropped.

   SELECT file_group_owner, file_group_name
   FROM dba_file_groups;

 Drop all the file groups shown in the above query before downgrade.

#######################################################################
#######################################################################
#

Rem Raise error if there are file groups
DECLARE
  cnt                 NUMBER;
  fg_downgrade_error  exception;
  PRAGMA EXCEPTION_INIT(fg_downgrade_error, -26740);
BEGIN
  select count(*) into cnt from sys.fgr$_file_groups;
  IF cnt != 0 THEN
    RAISE fg_downgrade_error; 
  END IF;
END;
/

DOC
#######################################################################
#######################################################################

 If the below PL/SQL block raises an ORA-28345 error, use the following
 query to identify tables with encrypted columns that need to be
 decrypted.

   SELECT owner, table_name, column_name
   FROM dba_encrypted_columns;

 Decrypt all the encrypted columns shown in the above query before
 downgrade.

#######################################################################
#######################################################################
#
 
Rem Raise error if there exists any encrypted column
DECLARE
  cnt                  NUMBER;
  tce_downgrade_error  exception;
  PRAGMA EXCEPTION_INIT(tce_downgrade_error, -28345);
BEGIN
  select count(*) into cnt from sys.enc$;
  IF cnt != 0 THEN
    RAISE tce_downgrade_error;
  END IF;
END;
/

Rem ***********************************************************************
Rem Perform 9.2 downgrade checks
Rem ***********************************************************************

DOC
#######################################################################
#######################################################################

 If the following PL/SQL block get an ORA-26705 error, use the following
 query to list all the capture processes that must be dropped
 prior to downgrading to 9.2.0.

   SELECT capture_name 
   FROM sys.streams$_capture_process 
   WHERE bitand(flags, 32) = 32;

 Consult Oracle Streams documentation for instructions to drop a 
 capture process.

#######################################################################
#######################################################################
#

Rem Raise error if Streams data dictionary was upgraded during start_capture
DECLARE
  CURSOR c_capture IS
  SELECT capture_name, flags FROM sys.streams$_capture_process;
  mvdd_decouple_error  exception;
  PRAGMA EXCEPTION_INIT(mvdd_decouple_error, -26705);

BEGIN
  IF '&downgrade_file' = '1001000' THEN
     RETURN;
  END IF;
  FOR rec IN c_capture LOOP
    -- Raise error if Streams data dictionary was upgraded during 
    -- start capture.
    IF bitand(rec.flags, 32) = 32 THEN
      dbms_output.put_line('Downgrade not allowed after Streams Data ' ||
                           'Dictionary has been upgraded ');
      dbms_output.put_line('by capture process ' || 
                           rec.capture_name);
      RAISE mvdd_decouple_error; 
    END IF;
  END LOOP;
END;
/

DOC
#######################################################################
#######################################################################

 If the following PL/SQL block raises an ORA-26706 error, use the following
 query to identify capture processes with a version higher then 9.2.

   SELECT capture_name, version 
   FROM DBA_CAPTURE;

 Drop all the capture processes with version higher than 9.2.
 Consult Oracle Streams documentation for instructions to drop a 
 capture process.

#######################################################################
#######################################################################
#

Rem Raise error if capture version is > 9.2
DECLARE
  CURSOR c_capture IS
  SELECT capture_name, version FROM streams$_capture_process;
  version_num            NUMBER := 0;
  release_num            NUMBER := 0;
  pos                    NUMBER;
  initpos                NUMBER;
  capture_version_error  exception;
  PRAGMA EXCEPTION_INIT(capture_version_error, -26706);
BEGIN
  IF '&downgrade_file' = '1001000' THEN
     RETURN;  
  END IF;
  FOR rec IN c_capture LOOP
    IF rec.version IS NOT NULL THEN

      -- Extract version number
      initpos := 1;
      pos := INSTR(rec.version, '.', initpos, 1);
      IF pos > 0 THEN
        version_num := TO_NUMBER(SUBSTR(rec.version, initpos, pos - initpos));
        initpos := pos + 1;

        -- Extract release number
        pos := INSTR(rec.version, '.', initpos, 1);
        IF pos > 0 THEN
          release_num := TO_NUMBER(SUBSTR(rec.version, initpos, 
                                                              pos - initpos));
          initpos := pos + 1;
        ELSE
          release_num := TO_NUMBER(SUBSTR(rec.version, initpos));
        END IF;
      ELSE
        version_num := TO_NUMBER(SUBSTR(rec.version, initpos));
      END IF;

      -- Raise error if version > 9.2
      IF (version_num > 9) OR
         ((version_num = 9) AND (release_num > 2)) THEN
        dbms_output.put_line('Downgrade not allowed for capture process ' ||
                             rec.capture_name ||
                             ' with version number ' ||
                             rec.version);
        RAISE capture_version_error; 
      END IF;
    END IF;
  END LOOP;
END;
/

DOC
#######################################################################
#######################################################################

 If the following PL/SQL block raises an ORA-26725 error, use the following
 query to identify apply handlers that are not associated with local
 database objects or the apply handlers are associated with a specific
 apply process.

   SELECT distinct object_owner, object_name
   FROM dba_apply_dml_handlers
     WHERE (object_owner, object_name) NOT IN
       (SELECT owner, object_name FROM dba_objects) OR
       (apply_name IS NOT NULL);

 Drop all the apply handlers shown in the above query before downgrade.

#######################################################################
#######################################################################
#

Rem Raise error if there are dml handlers for virtual objects
DECLARE
  owner                  VARCHAR2(30);
  name                   VARCHAR2(30);
  handlers_error         EXCEPTION;
  PRAGMA EXCEPTION_INIT(handlers_error, -26725);
BEGIN
  IF '&downgrade_file' = '1001000' THEN
     RETURN;
  END IF;
  SELECT sname, oname INTO owner, name FROM sys.apply$_dest_obj_ops a
    WHERE ((a.object_number = -1) or (a.apply_name IS NOT NULL))
      AND rownum = 1;

   -- Raise error
   dbms_output.put_line('Downgrade not allowed for dml handlers for '
                         || '"' || owner || '"."' || name || '"');
   RAISE handlers_error;
EXCEPTION 
  WHEN NO_DATA_FOUND THEN NULL;
END;
/

Rem =========================================================================
Rem END STAGE 1: Perform checks prior to downgrade to previous release
Rem =========================================================================

SET SERVEROUTPUT OFF
SET VERIFY ON
WHENEVER SQLERROR CONTINUE

SELECT dbms_registry_sys.time_stamp('DWGRD_BGN') AS timestamp FROM DUAL;

Rem =========================================================================
Rem BEGIN STAGE 2: downgrade installed components to previous release
Rem =========================================================================

Rem Setup component script filename variable
COLUMN file_name NEW_VALUE comp_file NOPRINT;

Rem Run component downgrade scripts
@@cmpdbdwg

Rem Remove Java system classes after components have been downgraded.
SELECT dbms_registry.script('JAVAVM', dbms_registry.script_path('JAVAVM') 
       || 'udjvmrm.sql') 
AS file_name FROM DUAL;
@&comp_file

column comp_name format a35
SELECT comp_name, status, substr(version,1,10) as version from dba_registry
WHERE comp_id NOT IN ('CATPROC','CATALOG');

DOC
#######################################################################
#######################################################################

 All components in the above query must have a status of DOWNGRADED.
 If not, the following check will get an ORA-39709 error, and the
 downgrade will be aborted. Consult the downgrade chapter of the 
 Oracle Database Upgrade Guide and correct the component problem,
 then re-run this script.

#######################################################################
#######################################################################
#

WHENEVER SQLERROR EXIT;
EXECUTE dbms_registry_sys.check_component_downgrades;
WHENEVER SQLERROR CONTINUE;

Rem =========================================================================
Rem END STAGE 2: downgrade installed components to previous release
Rem =========================================================================

Rem =========================================================================
Rem BEGIN STAGE 3: downgrade actions always performed
Rem =========================================================================

Rem Remove all DataPump objects including all Metadata API types
@@catnodp

Rem Truncate export actions tables (reloaded during catrelod.sql)
truncate table noexp$;
truncate table exppkgobj$;
truncate table exppkgact$;
truncate table expdepobj$;
truncate table expdepact$;

Rem Drop dbms_rcvman (refers to new fixed views)
drop package dbms_rcvman;

Rem =========================================================================
Rem END STAGE 3: downgrade actions always performed
Rem =========================================================================

Rem =========================================================================
Rem BEGIN STAGE 4: downgrade dictionary to specified release
Rem =========================================================================

@@e&downgrade_file

Rem =========================================================================
Rem END STAGE 4: downgrade dictionary to specified release
Rem =========================================================================

Rem put timestamps into spool log,registry$history, and registry$log
INSERT INTO registry$log (cid, namespace, operation, optime)
       VALUES ('DWGRD_END','SERVER',-1,SYSTIMESTAMP);
INSERT INTO registry$history (action_time, action)
        VALUES(SYSTIMESTAMP,'DOWNGRADE');
COMMIT;
SELECT 'COMP_TIMESTAMP DWGRD_END ' || 
        TO_CHAR(SYSTIMESTAMP,'YYYY-MM-DD HH24:MI:SS ')  || 
        TO_CHAR(SYSTIMESTAMP,'J SSSSS ')
        AS timestamp FROM DUAL;

Rem ***********************************************************************
Rem END catdwgrd.sql
Rem ***********************************************************************

