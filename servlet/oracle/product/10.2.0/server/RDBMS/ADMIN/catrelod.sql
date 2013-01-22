Rem
Rem $Header: catrelod.sql 14-mar-2005.11:21:59 rburns Exp $
Rem
Rem catrelod.sql
Rem
Rem Copyright (c) 2001, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catrelod.sql - Script to apply CATalog RELOaD scripts to a database
Rem
Rem    DESCRIPTION
Rem      This script encapsulates the "post downgrade" steps necessary
Rem      to reload the PL/SQL and Java packages, types, and classes.
Rem      It runs the "old" versions of catalog.sql and catproc.sql
Rem      and calls the component reload scripts.
Rem
Rem    NOTES
Rem      Use SQLPLUS and connect AS SYSDBA to run this script.
Rem      The database must be open for MIGRATE
Rem      
Rem    MODIFIED   (MM/DD/YY)
Rem    rburns      02/27/05 - record action for history 
Rem    rburns      01/18/05 - comment out htmldb for 10.2 
Rem    rburns      11/11/04 - move CONTEXT 
Rem    rburns      11/08/04 - add HTMLDB 
Rem    rburns      10/11/04 - add RUL 
Rem    rburns      04/16/04 - change version to 10.2 
Rem    rburns      02/23/04 - add EM 
Rem    rburns      04/25/03 - use timestamp
Rem    rburns      04/08/03 - use function for script names
Rem    rburns      01/18/03 - use 10.1 release, add EXF, reorder OLAP
Rem    rburns      01/16/03 - fix @@ and use server registry
Rem    dvoss       01/14/03 - add utllmup.sql
Rem    srtata      10/16/02 - add olsrelod.sql
Rem    rburns      08/27/02 - Add Ultra Search, remove ORDVIR
Rem    rburns      06/12/02 - remove pl/sql usage
Rem    rburns      04/16/02 - rburns_catpatch_920
Rem    rburns      04/03/02 - Created
Rem

Rem *************************************************************************
Rem BEGIN catrelod.sql
Rem *************************************************************************

SELECT 'COMP_TIMESTAMP RELOD__BGN ' || 
        TO_CHAR(SYSTIMESTAMP,'YYYY-MM-DD HH24:MI:SS ') || 
        TO_CHAR(SYSTIMESTAMP,'J SSSSS ')
        AS timestamp FROM DUAL;

Rem =======================================================================
Rem Verify server version and MIGRATE status (PL/SQL not available yet)
Rem =======================================================================

WHENEVER SQLERROR EXIT;

DOC
#######################################################################
#######################################################################
  The following statement will cause an "ORA-01722: invalid number"
  error if the database server version is not 10.0.0.
  Shutdown ABORT and use a different script or a different server.
#######################################################################
#######################################################################
#

SELECT TO_NUMBER('MUST_BE_10_2') FROM v$instance
WHERE substr(version,1,6) != '10.2.0';

DOC
#######################################################################
#######################################################################
  The following statement will cause an "ORA-01722: invalid number"
  error if the database has not been opened for MIGRATE.  

  Perform a "SHUTDOWN ABORT"  and 
  restart using MIGRATE.
#######################################################################
#######################################################################
#

SELECT TO_NUMBER(status) FROM v$instance
WHERE status != 'OPEN MIGRATE';

Rem =======================================================================
Rem SET nls_length_semantics at session level (bug 1488174)
Rem =======================================================================

ALTER SESSION SET NLS_LENGTH_SEMANTICS=BYTE;

Rem =======================================================================
Rem Invalidate all PL/SQL packages and types
Rem =======================================================================

@@utlip

SELECT 'COMP_TIMESTAMP UTLIP      ' || 
        TO_CHAR(SYSTIMESTAMP,'YYYY-MM-DD HH24:MI:SS ') || 
        TO_CHAR(SYSTIMESTAMP,'J SSSSS ')
        AS timestamp FROM DUAL;

WHENEVER SQLERROR CONTINUE;

Rem =======================================================================
Rem Run catalog.sql and catproc.sql
Rem =======================================================================

Rem Remove any existing rows that would fire on DROP USER statements
delete from duc$;

@@catalog.sql
@@catproc.sql 
SELECT dbms_registry_sys.time_stamp('CATPROC') AS timestamp FROM DUAL;

Rem *************************************************************************
Rem START Component Reloads 
Rem *************************************************************************

Rem Setup component script filename variable
COLUMN relod_name NEW_VALUE relod_file NOPRINT;

Rem JServer
SELECT dbms_registry_sys.relod_script('JAVAVM') AS relod_name FROM DUAL;
@&relod_file
SELECT dbms_registry_sys.time_stamp('JAVAVM') AS timestamp FROM DUAL;

Rem XDK for Java
SELECT dbms_registry_sys.relod_script('XML') AS relod_name FROM DUAL;
@&relod_file
SELECT dbms_registry_sys.time_stamp('XML') AS timestamp FROM DUAL;

Rem Java Supplied Packages
SELECT dbms_registry_sys.relod_script('CATJAVA') AS relod_name FROM DUAL;
@&relod_file
SELECT dbms_registry_sys.time_stamp('CATJAVA') AS timestamp FROM DUAL;

Rem Text
SELECT dbms_registry_sys.relod_script('CONTEXT') AS relod_name FROM DUAL;
@&relod_file
SELECT dbms_registry_sys.time_stamp('CONTEXT') AS timestamp FROM DUAL;

Rem Oracle XML Database
SELECT dbms_registry_sys.relod_script('XDB') AS relod_name FROM DUAL;
@&relod_file
SELECT dbms_registry_sys.time_stamp('XDB') AS timestamp FROM DUAL;

Rem Real Application Clusters
SELECT dbms_registry_sys.relod_script('RAC') AS relod_name FROM DUAL;
@&relod_file
SELECT dbms_registry_sys.time_stamp('RAC') AS timestamp FROM DUAL;

Rem Oracle Workspace Manager
SELECT dbms_registry_sys.relod_script('OWM') AS relod_name FROM DUAL;
@&relod_file
SELECT dbms_registry_sys.time_stamp('OWM') AS timestamp FROM DUAL;

Rem Oracle Data Mining
SELECT dbms_registry_sys.relod_script('ODM') AS relod_name FROM DUAL;
@&relod_file
SELECT dbms_registry_sys.time_stamp('ODM') AS timestamp FROM DUAL;

Rem Messaging Gateway
SELECT dbms_registry_sys.relod_script('MGW') AS relod_name FROM DUAL;
@&relod_file
SELECT dbms_registry_sys.time_stamp('MGW') AS timestamp FROM DUAL;

Rem OLAP Analytic Workspace
SELECT dbms_registry_sys.relod_script('APS') AS relod_name FROM DUAL;
@&relod_file
SELECT dbms_registry_sys.time_stamp('APS') AS timestamp FROM DUAL;

Rem OLAP Catalog 
SELECT dbms_registry_sys.relod_script('AMD') AS relod_name FROM DUAL;
@&relod_file
SELECT dbms_registry_sys.time_stamp('AMD') AS timestamp FROM DUAL;

Rem OLAP API
SELECT dbms_registry_sys.relod_script('XOQ') AS relod_name FROM DUAL;
@&relod_file
SELECT dbms_registry_sys.time_stamp('XOQ') AS timestamp FROM DUAL;

Rem Intermedia
SELECT dbms_registry_sys.relod_script('ORDIM') AS relod_name FROM DUAL;
@&relod_file
SELECT dbms_registry_sys.time_stamp('ORDIM') AS timestamp FROM DUAL;

Rem Spatial
SELECT dbms_registry_sys.relod_script('SDO') AS relod_name FROM DUAL;
@&relod_file
SELECT dbms_registry_sys.time_stamp('SDO') AS timestamp FROM DUAL;

Rem Ultrasearch
SELECT dbms_registry_sys.relod_script('WK') AS relod_name FROM DUAL;
@&relod_file
SELECT dbms_registry_sys.time_stamp('WK') AS timestamp FROM DUAL;

Rem Oracle Label Security
SELECT dbms_registry_sys.relod_script('OLS') AS relod_name FROM DUAL;
@&relod_file
SELECT dbms_registry_sys.time_stamp('OLS') AS timestamp FROM DUAL;

Rem Expression Filter
SELECT dbms_registry_sys.relod_script('EXF') AS relod_name FROM DUAL;
@&relod_file
SELECT dbms_registry_sys.time_stamp('EXF') AS timestamp FROM DUAL;

Rem Enterprise Manager Repository
SELECT dbms_registry_sys.relod_script('EM') AS relod_name FROM DUAL;
@&relod_file
SELECT dbms_registry_sys.time_stamp('EM') AS timestamp FROM DUAL;

Rem Rule Manager
SELECT dbms_registry_sys.relod_script('RUL') AS relod_name FROM DUAL;
@&relod_file     
SELECT dbms_registry_sys.time_stamp('RUL') AS timestamp FROM DUAL;

Rem HTML DB
-- SELECT dbms_registry_sys.relod_script('HTMLDB') AS relod_name FROM DUAL;
-- @&relod_file     
-- SELECT dbms_registry_sys.time_stamp('HTMLDB') AS timestamp FROM DUAL;

set serveroutput off

Rem **********************************************************************
Rem END Component Reloads 
Rem **********************************************************************

Rem =======================================================================
Rem Update Logminer Metadata in Redo Stream
Rem =======================================================================
@@utllmup.sql

Rem =====================================================================
Rem Record Reload Completion
Rem =====================================================================

BEGIN  
   dbms_registry_sys.record_action('RELOAD',NULL,
             'Reloaded after downgrade from ' || 
              dbms_registry.prev_version('CATPROC'));
END;
/

SELECT dbms_registry_sys.time_stamp('relod_end') AS timestamp FROM DUAL;

Rem =======================================================================
Rem Display new versions and status
Rem =======================================================================

column comp_name format a35
SELECT comp_name, status, substr(version,1,10) as version 
from dba_server_registry order by modified;

DOC
#######################################################################
#######################################################################

   The above query lists the SERVER components now loaded in the
   database, along with their current version and status. 

   Please review the status and version columns and look for
   any errors in the spool log file.  If there are errors in the spool
   file, or any components are not VALID or not the correct 10.1.0
   patch version, consult the downgrade chapter of the current release
   Database Upgrade book.

   Next shutdown immediate, restart for normal operation, and then
   run utlrp.sql to recompile any invalid application objects.

#######################################################################
#######################################################################
#  

Rem *******************************************************************
Rem END catrelod.sql 
Rem *******************************************************************
