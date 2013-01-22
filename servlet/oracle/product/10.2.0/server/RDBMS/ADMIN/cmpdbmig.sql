Rem
Rem $Header: cmpdbmig.sql 30-mar-2005.09:58:02 rburns Exp $
Rem
Rem cmpdbmig.sql
Rem
Rem Copyright (c) 2001, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      cmpdbmig.sql - CoMPonent DataBase MIGration SQL script
Rem
Rem    DESCRIPTION
Rem      This script runs the upgrade scripts for all SERVER components 
Rem
Rem    NOTES
Rem      This script must be run connected AS SYSDBA using SQL*Plus.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    nkandalu    03/28/05 - 4237884: re-install XDB if it was not completed
Rem    rburns      03/30/05 - change ORDIM install 
Rem    rburns      03/14/05 - use dbms_registry_sys
Rem    rburns      01/18/05 - comment out htmldb for 10.2 
Rem    rburns      11/08/04 - add HTMLDB 
Rem    rburns      10/21/04 - move CTX before XDB 
Rem    rburns      09/28/04 - install XDB when XML 
Rem    rburns      09/10/04 - use new sqlplus variables
Rem    rburns      08/14/04 - add XDB, JAVAVM, and ORDIM dependencies 
Rem    rburns      07/13/04 - Add SDO dependency on XML 
Rem    rburns      03/18/04 - remove comp query 
Rem    rburns      02/23/04 - add EM, EXF 
Rem    rburns      08/28/03 - cleanup 
Rem    schakkap    08/03/03 - optimizer stats for system schemas
Rem    rburns      05/21/03 - XML required for ORDIM
Rem    rburns      04/08/03 - use function for script names
Rem    rburns      02/13/03 - order component list
Rem    tbgraves    02/10/03 - DOC comments; remove CATPROC timestamp
Rem    rburns      01/23/03 - re-order OLAP components
Rem    rburns      01/14/03 - move JAVAVM load, fix server registry
Rem    tbgraves    11/06/02 - use dbms_registry for timestamp
Rem    rburns      11/22/02 - add loading JServer for 806 Intermedia upgrade
Rem    rburns      11/12/02 - use dbms_registry.check_server_instance, add WK
Rem    rburns      08/01/02 - remove ORDVIR
Rem    rburns      07/29/02 - revise timestamps
Rem    rburns      04/18/02 - new server version
Rem    rburns      04/11/02 - add timestamps
Rem    rburns      04/10/02 - list components
Rem    rburns      03/28/02 - use relative pathname
Rem    rburns      02/14/02 - add AMD component
Rem    rburns      02/06/02 - add MGW component and instance checks
Rem    rburns      02/04/02 - add ODM component
Rem    rburns      01/09/02 - reset serveroutput
Rem    rburns      12/18/01 - add catdbmig for Java classes
Rem    rburns      12/12/01 - remove ODM
Rem    rburns      12/10/01 - use ODM directories
Rem    rburns      12/06/01 - add other components
Rem    rburns      11/13/01 - add RAC
Rem    rburns      10/18/01 - Merged rburns_downgrade_fixes
Rem    rburns      10/17/01 - Created
Rem
Rem *******************************************************************
Rem  START cmpdbmig.sql
Rem *******************************************************************

Rem =========================================================================
Rem Exit immediately if there are errors in the initial checks
Rem =========================================================================

WHENEVER SQLERROR EXIT;

Rem check instance version and status; set session attributes
EXECUTE dbms_registry.check_server_instance;

Rem =========================================================================
Rem Continue even if there are SQL errors in remainder of script 
Rem =========================================================================

WHENEVER SQLERROR CONTINUE;

Rem Setup component script filename variables
COLUMN dbmig_name NEW_VALUE dbmig_file NOPRINT;
VARIABLE dbinst_name VARCHAR2(256)                   
COLUMN :dbinst_name NEW_VALUE dbinst_file NOPRINT

set serveroutput off

Rem =====================================================================
Rem Upgrade JServer
Rem =====================================================================

SELECT dbms_registry_sys.dbupg_script('JAVAVM') AS dbmig_name FROM DUAL;
@&dbmig_file
Rem If Intermedia, Ultrasearch, Spatial, Data Mining upgrade, 
Rem    first install JAVAVM if it is not loaded

BEGIN
  IF dbms_registry.is_loaded('JAVAVM') IS NULL AND
     (dbms_registry.is_loaded('ORDIM') IS NOT NULL OR
      dbms_registry.is_loaded('WK') IS NOT NULL OR
      dbms_registry.is_loaded('SDO') IS NOT NULL OR
      dbms_registry.is_loaded('EXF') IS NOT NULL OR
      dbms_registry.is_loaded('ODM') IS NOT NULL) THEN
     :dbinst_name := dbms_registry_server.JAVAVM_path || 'initjvm.sql';
  ELSE
     :dbinst_name := dbms_registry.nothing_script;
  END IF;
END;
/
SELECT :dbinst_name FROM DUAL;
@&dbinst_file

SELECT dbms_registry_sys.time_stamp('JAVAVM') AS timestamp FROM DUAL;

Rem =====================================================================
Rem Upgrade XDK for Java
Rem =====================================================================

SELECT dbms_registry_sys.dbupg_script('XML') AS dbmig_name FROM DUAL;
@&dbmig_file

Rem If Intermedia upgrade, first install XML if it is not loaded
BEGIN
   IF dbms_registry.is_loaded('XML') IS NULL AND
      (dbms_registry.is_loaded('ORDIM') IS NOT NULL OR
       dbms_registry.is_loaded('SDO') IS NOT NULL) THEN
     :dbinst_name := dbms_registry_server.XML_path || 'initxml.sql';
  ELSE
     :dbinst_name := dbms_registry.nothing_script;
  END IF;
END;
/
SELECT :dbinst_name FROM DUAL;
@&dbinst_file

SELECT dbms_registry_sys.time_stamp('XML') AS timestamp FROM DUAL;

Rem =====================================================================
Rem Java Supplied Packages
Rem =====================================================================

SELECT dbms_registry_sys.dbupg_script('CATJAVA') AS dbmig_name FROM DUAL;
@&dbmig_file

Rem If JAVAVM install for dependencies no CATJAVA, load it
BEGIN
  IF dbms_registry.is_loaded('CATJAVA') IS NULL AND
     dbms_registry.is_loaded('JAVAVM') IS NOT NULL THEN
     :dbinst_name := dbms_registry_server.CATJAVA_path || 'catjava.sql';
  ELSE
     :dbinst_name := dbms_registry.nothing_script;
  END IF;
END;
/
SELECT :dbinst_name FROM DUAL;
@&dbinst_file

SELECT dbms_registry_sys.time_stamp('CATJAVA') AS timestamp FROM DUAL;

Rem =====================================================================
Rem Upgrade Text
Rem =====================================================================

SELECT dbms_registry_sys.dbupg_script('CONTEXT') AS dbmig_name FROM DUAL;
@&dbmig_file
SELECT dbms_registry_sys.time_stamp('CONTEXT') AS timestamp FROM DUAL;

Rem =====================================================================
Rem Oracle XML Database
Rem =====================================================================

Rem If XDB install was incomplete (status still LOADING),
Rem uninstall first and then re-install. 

BEGIN
  IF dbms_registry.status('XDB') = 'LOADING'  THEN 
    :dbinst_name := dbms_registry_server.XDB_path || 'catnoqm.sql';
  ELSE
     :dbinst_name := dbms_registry.nothing_script;
  END IF;
END;
/ 
SELECT :dbinst_name FROM DUAL;
@&dbinst_file

Rem If XML, Intermedia or Spatial upgrade, first install XDB if it is
Rem not loaded. Otherwise, if XDB is in the database, run the XDB
Rem upgrade script

DECLARE
  temp_ts  VARCHAR2(30);
BEGIN
  IF dbms_registry.is_loaded('XDB') IS NULL AND
      (dbms_registry.is_loaded('XML') IS NOT NULL OR
       dbms_registry.is_loaded('SDO') IS NOT NULL OR
       dbms_registry.is_loaded('ORDIM') IS NOT NULL) THEN
     SELECT temporary_tablespace INTO temp_ts FROM dba_users
            WHERE username='SYS'; -- use SYS temporary tablespace
     :dbinst_name := dbms_registry_server.XDB_path || 
                     'catqm.sql XDB SYSAUX ' || temp_ts; 
  ELSE
     :dbinst_name := dbms_registry_sys.dbupg_script('XDB');
  END IF;
END;
/
SELECT :dbinst_name FROM DUAL;
@&dbinst_file

SELECT dbms_registry_sys.time_stamp('XDB') AS timestamp FROM DUAL;

Rem =====================================================================
Rem Upgrade Real Application Clusters
Rem =====================================================================

SELECT dbms_registry_sys.dbupg_script('RAC') AS dbmig_name FROM DUAL;
@&dbmig_file
SELECT dbms_registry_sys.time_stamp('RAC') AS timestamp FROM DUAL;

Rem =====================================================================
Rem Upgrade Oracle Workspace Manager

Rem =====================================================================
SELECT dbms_registry_sys.dbupg_script('OWM') AS dbmig_name FROM DUAL;
@&dbmig_file
SELECT dbms_registry_sys.time_stamp('OWM') AS timestamp FROM DUAL;

Rem =====================================================================
Rem Upgrade Oracle Data Mining
Rem =====================================================================

SELECT dbms_registry_sys.dbupg_script('ODM') AS dbmig_name FROM DUAL;
@&dbmig_file
SELECT dbms_registry_sys.time_stamp('ODM') AS timestamp FROM DUAL;

Rem =====================================================================
Rem Upgrade Messaging Gateway
Rem =====================================================================

SELECT dbms_registry_sys.dbupg_script('MGW') AS dbmig_name FROM DUAL;
@&dbmig_file
SELECT dbms_registry_sys.time_stamp('MGW') AS timestamp FROM DUAL;

Rem =====================================================================
Rem Upgrade OLAP Analytic Workspace
Rem =====================================================================

SELECT dbms_registry_sys.dbupg_script('APS') AS dbmig_name FROM DUAL;
@&dbmig_file
SELECT dbms_registry_sys.time_stamp('APS') AS timestamp FROM DUAL;

Rem =====================================================================
Rem Upgrade OLAP Catalog 
Rem =====================================================================

SELECT dbms_registry_sys.dbupg_script('AMD') AS dbmig_name FROM DUAL;
@&dbmig_file
SELECT dbms_registry_sys.time_stamp('AMD') AS timestamp FROM DUAL;

Rem =====================================================================
Rem Upgrade OLAP API
Rem =====================================================================

SELECT dbms_registry_sys.dbupg_script('XOQ') AS dbmig_name FROM DUAL;
@&dbmig_file
SELECT dbms_registry_sys.time_stamp('XOQ') AS timestamp FROM DUAL;

Rem =====================================================================
Rem Upgrade Intermedia
Rem =====================================================================

SELECT dbms_registry_sys.dbupg_script('ORDIM') AS dbmig_name FROM DUAL;
@&dbmig_file

Rem If Spatial upgrade,
Rem    first install ORDIM if it is not loaded
BEGIN
  IF dbms_registry.is_loaded('ORDIM') IS NULL AND
     dbms_registry.is_loaded('SDO') IS NOT NULL THEN
     :dbinst_name := dbms_registry_server.ORDIM_path || 'imupins.sql';
     EXECUTE IMMEDIATE 
          'CREATE USER si_informtn_schema IDENTIFIED BY ordsys ' ||
          'ACCOUNT LOCK PASSWORD EXPIRE ' ||
          'DEFAULT TABLESPACE SYSAUX';
  ELSE
     :dbinst_name := dbms_registry.nothing_script;
  END IF;
END;
/

SELECT :dbinst_name FROM DUAL;
@&dbinst_file

SELECT dbms_registry_sys.time_stamp('ORDIM') AS timestamp FROM DUAL;

Rem =====================================================================
Rem Upgrade Spatial
Rem =====================================================================

SELECT dbms_registry_sys.dbupg_script('SDO') AS dbmig_name FROM DUAL;
@&dbmig_file

SELECT dbms_registry_sys.time_stamp('SDO') AS timestamp FROM DUAL;

Rem =====================================================================
Rem Upgrade Ultra Search
Rem =====================================================================

SELECT dbms_registry_sys.dbupg_script('WK') AS dbmig_name FROM DUAL;
@&dbmig_file
SELECT dbms_registry_sys.time_stamp('WK') AS timestamp FROM DUAL;

Rem =====================================================================
Rem Upgrade Oracle Label Security 
Rem =====================================================================

SELECT dbms_registry_sys.dbupg_script('OLS') AS dbmig_name FROM DUAL;
@&dbmig_file
SELECT dbms_registry_sys.time_stamp('OLS') AS timestamp FROM DUAL;

Rem =====================================================================
Rem Upgrade Expression Filter
Rem =====================================================================

SELECT dbms_registry_sys.dbupg_script('EXF') AS dbmig_name FROM DUAL;
@&dbmig_file
SELECT dbms_registry_sys.time_stamp('EXF') AS timestamp FROM DUAL;

Rem =====================================================================
Rem Upgrade Enterprise Manager Repository 
Rem =====================================================================

SELECT dbms_registry_sys.dbupg_script('EM') AS dbmig_name FROM DUAL;
@&dbmig_file
SELECT dbms_registry_sys.time_stamp('EM') AS timestamp FROM DUAL;

Rem =====================================================================
Rem Upgrade HTML DB
Rem =====================================================================

-- SELECT dbms_registry_sys.dbupg_script('HTMLDB') AS dbmig_name FROM DUAL;
-- @&dbmig_file
-- SELECT dbms_registry_sys.time_stamp('HTMLDB') AS timestamp FROM DUAL;

set serveroutput off

Rem =====================================================================
Rem Collect optimizer stats for all RDBMS component schemas
Rem =====================================================================

execute dbms_registry.gather_stats(null);

Rem ******************************************************************
Rem END cmpdbmig.sql
Rem ******************************************************************
