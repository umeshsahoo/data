Rem
Rem $Header: catupgrd.sql 14-mar-2005.12:53:30 rburns Exp $
Rem
Rem catupgrd.sql
Rem
Rem Copyright (c) 1999, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catupgrd.sql - CATalog UPGraDe to the new release
Rem
Rem    DESCRIPTION
Rem     This script is to be used for upgrading an 8.1.7, 9.0.1, 9.2 
Rem     or 10.1 database to the new release.  This script provides a direct 
Rem     upgrade path from these releases to the new Oracle release.
Rem
Rem      The upgrade is partitioned into the following 5 stages:
Rem        STAGE 1: call the "i" script for the oldest supported release:
Rem                 This loads all tables that are necessary
Rem                 to perform basic DDL commands for the new release
Rem        STAGE 2: call utlip.sql to invalidate PL/SQL objects
Rem        STAGE 3: Determine the original release and call the 
Rem                 c0x0x0x0.sql for the release.  This performs all 
Rem                 necessary dictionary upgrade actions to bring the 
Rem                 database from the original release to new release.
Rem        STAGE 4: call the a0x0x0x0.sql for the original release:
Rem                 This performs all necessary upgrade using
Rem                 anonymous blocks.
Rem        STAGE 5: call cmpdbmig.sql
Rem                 This calls the upgrade scripts for all of the
Rem                 components that have been loaded into the database
Rem
Rem    NOTES
Rem
Rem      * This script needs to be run in the new release's environment
Rem        (after installing the release to which you want to upgrade).
Rem      * You must be connected AS SYSDBA to run this script.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rburns      03/14/05 - dbms_registry_sys timestamp 
Rem    rburns      02/27/05 - record action for history 
Rem    rburns      10/18/04 - remove catpatch.sql 
Rem    rburns      09/02/04 - remove dbms_output compile 
Rem    rburns      06/17/04 - use registry log and utlusts 
Rem    mvemulap    05/26/04 - grid mcode compatibility 
Rem    jstamos     05/20/04 - utlip workaround 
Rem    rburns      05/17/04 - rburns_single_updown_scripts
Rem    rburns      01/27/04 - Created
Rem

Rem =====================================================================
Rem Exit immediately if there are errors in the initial checks
Rem =====================================================================

WHENEVER SQLERROR EXIT;        

DOC
######################################################################
######################################################################
    The following statement will cause an "ORA-01722: invalid number"
    error if the user running this script is not SYS.  Disconnect
    and reconnect with AS SYSDBA.
######################################################################
######################################################################
#

SELECT TO_NUMBER('MUST_BE_AS_SYSDBA') FROM DUAL
WHERE USER != 'SYS';

DOC
######################################################################
######################################################################
    The following statement will cause an "ORA-01722: invalid number"
    error if the database server version is not correct for this script.
    Shutdown ABORT and use a different script or a different server.
######################################################################
######################################################################
#

SELECT TO_NUMBER('MUST_BE_10_2') FROM v$instance
WHERE substr(version,1,6) != '10.2.0';

DOC
#######################################################################
#######################################################################
   The following statement will cause an "ORA-01722: invalid number"
   error if the database has not been opened for UPGRADE.  

   Perform a "SHUTDOWN ABORT"  and 
   restart using UPGRADE.
#######################################################################
#######################################################################
#

SELECT TO_NUMBER('MUST_BE_OPEN_UPGRADE') FROM v$instance
WHERE status != 'OPEN MIGRATE';

DOC 
#######################################################################
#######################################################################
    The following statements will cause an "ORA-01722: invalid number"
    error if the SYSAUX tablespace does not exist or is not
    ONLINE for READ WRITE, PERMANENT, EXTENT MANAGEMENT LOCAL, and
    SEGMENT SPACE MANAGEMENT AUTO.
 
    The SYSAUX tablespace is used in 10.1 to consolidate data from
    a number of tablespaces that were separate in prior releases. 
    Consult the Oracle Database Upgrade Guide for sizing estimates.

    Create the SYSAUX tablespace, for example,

     create tablespace SYSAUX datafile 'sysaux01.dbf' 
         size 70M reuse 
         extent management local 
         segment space management auto 
         online;

    Then rerun the catupgrd.sql script.
#######################################################################
#######################################################################
#

SELECT TO_NUMBER('No SYSAUX tablespace') FROM dual 
WHERE 'SYSAUX' NOT IN (SELECT name from ts$);

SELECT TO_NUMBER('Not ONLINE for READ/WRITE') from ts$
WHERE name='SYSAUX' AND online$ !=1;

SELECT TO_NUMBER ('Not PERMANENT') from ts$
WHERE name='SYSAUX' AND 
      (contents$ !=0 or (contents$ = 0 AND bitand(flags, 16)= 16));

SELECT TO_NUMBER ('Not LOCAL extent management') from ts$
WHERE name='SYSAUX' AND bitmapped = 0;

SELECT TO_NUMBER ('Not AUTO segment space management') from ts$
WHERE name='SYSAUX' AND bitand(flags,32) != 32;

Rem =====================================================================
Rem Assure CHAR semantics are not used in the dictionary
Rem =====================================================================

ALTER SESSION SET NLS_LENGTH_SEMANTICS=BYTE;

Rem =====================================================================
Rem Turn off PL/SQL event used by APPS
Rem =====================================================================

ALTER SESSION SET EVENTS='10933 trace name context off';

Rem =====================================================================
Rem Continue even if there are SQL errors in remainder of script
Rem =====================================================================

WHENEVER SQLERROR CONTINUE;  

Rem
Rem Pre-create log to record upgrade operations and errors
Rem

CREATE TABLE registry$log (
             cid         VARCHAR2(30),              /* component identifier */
             namespace   VARCHAR2(30),               /* component namespace */
             operation   NUMBER NOT NULL,              /* current operation */
             optime      TIMESTAMP,                  /* operation timestamp */
             errmsg      varchar2(1000)         /* ORA error message number */
             );
Rem Clear log entries if the table already exists
DELETE FROM registry$log;

Rem put timestamps into spool log and registry$log
INSERT INTO registry$log (cid, namespace, operation, optime)
       VALUES ('UPGRD_BGN','SERVER',-1,SYSTIMESTAMP);
COMMIT;
SELECT 'COMP_TIMESTAMP UPGRD__BGN ' || 
        TO_CHAR(SYSTIMESTAMP,'YYYY-MM-DD HH24:MI:SS ')  || 
        TO_CHAR(SYSTIMESTAMP,'J SSSSS ')
        AS timestamp FROM DUAL;

Rem =====================================================================
Rem BEGIN STAGE 1: load dictionary changes for basic SQL processing
Rem =====================================================================

Rem run all of the "i" scripts from the earliest supported release
@@i0801070

Rem =====================================================================
Rem END STAGE 1: load dictionary changes for basic SQL processing
Rem =====================================================================

Rem =====================================================================
Rem BEGIN STAGE 2: invalidate all non-Java objects
Rem =====================================================================

-- Use the existence of a 10.1 table to determine the need for 
-- utlip.sql.  STATS_TARGET$ is the last table created in the upgrade 
-- to 10.1; if it exists, then utlip.sql is not needed.

DEFINE utlip_file = utlip.sql
COLUMN utlip_name NEW_VALUE utlip_file NOPRINT;
SELECT 'nothing.sql' AS utlip_name FROM obj$ 
       WHERE name = 'STATS_TARGET$';

@@&utlip_file

Rem =====================================================================
Rem END STAGE 2: invalidate all non-Java objects
Rem =====================================================================

Rem =====================================================================
Rem BEGIN STAGE 3: dictionary upgrade
Rem =====================================================================

WHENEVER SQLERROR EXIT

Rem Determine original release and run the appropriate script
CREATE OR REPLACE FUNCTION version_script 
RETURN VARCHAR2 IS
PRAGMA AUTONOMOUS_TRANSACTION;  -- executes DDL 

  p_null         char(1);
  p_version      VARCHAR2(30);
  p_prv_version  VARCHAR2(30);
  server_version VARCHAR2(30);

BEGIN
  -- See if the registry$ table exists 
  SELECT NULL into p_null from obj$ where name='REGISTRY$' and owner#=0;
  -- If so, get the version of the CATPROC component
  EXECUTE IMMEDIATE 'SELECT version
                     FROM registry$ where cid=''CATPROC'''
          INTO p_version;
  IF substr(p_version,1,5) = '8.1.7' THEN
     RETURN '0801070';
  ELSIF substr(p_version,1,5) = '9.0.1' THEN
     RETURN '0900010';
  ELSIF substr(p_version,1,5) = '9.2.0' THEN
     RETURN '0902000';
  ELSIF substr(p_version,1,6) = '10.1.0' THEN
     RETURN '1001000';
  ELSIF substr(p_version,1,6) = '10.2.0' THEN -- current version
     SELECT version INTO server_version FROM v$instance;
     IF p_version != server_version THEN -- run c1002000
        RETURN '1002000';
     ELSE -- version is the same as instance, so rerun the previous upgrade
     -- rerun upgrade of previous release 
        EXECUTE IMMEDIATE 'SELECT prv_version
                     FROM registry$ where cid=''CATPROC'''
           INTO p_prv_version;
        IF substr(p_prv_version,1,5) = '8.1.7' THEN
           RETURN '0801070';
        ELSIF substr(p_prv_version,1,5) = '9.0.1' THEN
           RETURN '0900010';
        ELSIF substr(p_prv_version,1,5) = '9.2.0' THEN
           RETURN '0902000';
        ELSIF substr(p_prv_version,1,6) = '10.1.0' THEN
           RETURN '1001000';
        ELSIF substr(p_prv_version,1,6) = '10.2.0' THEN
           RETURN '1002000';
        ELSE
           RAISE_APPLICATION_ERROR(-20000,
          'Upgrade re-run not supported from version ' || p_prv_version );
        END IF;
      END IF;
  END IF;
  RAISE_APPLICATION_ERROR(-20000,
       'Upgrade not supported from version ' || p_version );

EXCEPTION WHEN NO_DATA_FOUND THEN -- No registry$ table -> is 817 or 901
  -- create the registry$ table to store CATPROC version
  EXECUTE IMMEDIATE 'CREATE TABLE registry$ (
             cid      VARCHAR2(30),
             cname    VARCHAR2(255),
             schema#  NUMBER NOT NULL,
             invoker# NUMBER NOT NULL,
             version  VARCHAR2(30),   
             status   NUMBER NOT NULL,
             flags    NUMBER NOT NULL,
             modified DATE,           
             pid      VARCHAR2(30),   
             banner   VARCHAR2(80),   
             vproc    VARCHAR2(61),   
             date_invalid       DATE, 
             date_valid         DATE, 
             date_loading       DATE, 
             date_loaded        DATE, 
             date_upgrading     DATE, 
             date_upgraded      DATE, 
             date_downgrading   DATE, 
             date_downgraded    DATE, 
             date_removing      DATE, 
             date_removed       DATE, 
             namespace          VARCHAR2(30), 
             org_version        VARCHAR2(30), 
             prv_version        VARCHAR2(30), 
             CONSTRAINT registry_pk  PRIMARY KEY (namespace, cid),
             CONSTRAINT registry_parent_fk FOREIGN KEY (namespace, pid)
                        REFERENCES registry$ (namespace, cid) 
                        ON DELETE CASCADE)';

  BEGIN -- look for a 901 table
     SELECT NULL into p_null from obj$ where name='SMON_SCN_TIME' AND OWNER#=0;
     BEGIN  -- when found the first time, store in registry$
       EXECUTE IMMEDIATE 'INSERT INTO registry$ 
           (status, modified, cid, version, schema#, invoker#, 
            flags, date_loaded, namespace, org_version, prv_version)
         VALUES (3, SYSDATE, ''CATPROC'', ''9.0.1.0.0'', 0, 0, 
            0, SYSDATE, ''SERVER'', ''9.0.1.0.0'', NULL)';
       COMMIT;
     EXCEPTION
       WHEN DUP_VAL_ON_INDEX THEN NULL;
     END;
     RETURN '0900010';
  EXCEPTION WHEN NO_DATA_FOUND THEN  -- 901 table does not exist
     BEGIN -- make sure 817 table is there (no 806 upgrade)
        SELECT NULL into p_null from obj$ where name='VIEWTRCOL$' AND OWNER#=0;
        BEGIN
          EXECUTE IMMEDIATE 'INSERT INTO registry$ 
             (status, modified, cid, version, schema#, invoker#, 
              flags, date_loaded, namespace, org_version, prv_version)
          VALUES (3, SYSDATE, ''CATPROC'', ''8.1.7.0.0'', 0, 0, 
             0, SYSDATE, ''SERVER'', ''8.1.7.0.0'', NULL)';
          COMMIT;
        EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN NULL;
        END;
        RETURN '0801070';
     EXCEPTION
        WHEN NO_DATA_FOUND THEN  -- not an 817 database
        RAISE_APPLICATION_ERROR(-20000,
          'Upgrade not supported from versions prior to 8.1.7');
     END;
  END;
END version_script;
/

show errors;

Rem get the correct script name into the "upgrade_file" variable
COLUMN file_name NEW_VALUE upgrade_file NOPRINT;
SELECT version_script AS file_name FROM DUAL;
DROP function version_script;

WHENEVER SQLERROR CONTINUE

Rem run the selected "c" upgrade script
@@c&upgrade_file

Rem =====================================================================
Rem END STAGE 3: dictionary upgrade
Rem =====================================================================

Rem =====================================================================
Rem Update Logminer Metadata in Redo Stream
Rem =====================================================================

@@utllmup

Rem =====================================================================
Rem Record Upgrade Completion
Rem =====================================================================

BEGIN
   dbms_registry_sys.record_action('UPGRADE',NULL,'Upgraded from ' || 
       dbms_registry.prev_version('CATPROC'));
END;
/
SELECT dbms_registry_sys.time_stamp('UPGRD_END') AS timestamp FROM DUAL;

Rem =====================================================================
Rem Run component status as last output
Rem =====================================================================

@@utlusts TEXT
 
DOC
#######################################################################
#######################################################################

   The above PL/SQL lists the SERVER components in the upgraded
   database, along with their current version and status. 

   Please review the status and version columns and look for
   any errors in the spool log file.  If there are errors in the spool
   file, or any components are not VALID or not the current version,
   consult the Oracle Database Upgrade Guide for troubleshooting 
   recommendations.

   Next shutdown immediate, restart for normal operation, and then
   run utlrp.sql to recompile any invalid application objects.

#######################################################################
#######################################################################
#  

Rem *********************************************************************
Rem END catupgrd.sql
Rem *********************************************************************
