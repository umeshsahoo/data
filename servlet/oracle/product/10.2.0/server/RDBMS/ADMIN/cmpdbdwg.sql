Rem $Header: cmpdbdwg.sql 17-mar-2005.16:54:13 rburns Exp $
Rem
Rem cmpdbdwg.sql
Rem
Rem Copyright (c) 1999, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      cmpdbdwg.sql - downgrade SERVER components to original release
Rem
Rem    DESCRIPTION
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rburns      03/14/05 - use dbms_registry_sys
Rem    rburns      01/18/05 - comment out htmldb for 10.2 
Rem    rburns      11/11/04 - move CONTEXT 
Rem    rburns      11/08/04 - add HTMLDB 
Rem    rburns      07/01/04 - Fix RAC downgrade version 
Rem    rburns      05/17/04 - rburns_single_updown_scripts
Rem    rburns      02/04/04 - Created

Rem ======================================================================
Rem Downgrade HTML DB
Rem ======================================================================

-- SELECT dbms_registry_sys.dbdwg_script('HTMLDB') AS file_name FROM DUAL;
-- @&comp_file
-- SELECT dbms_registry_sys.time_stamp('HTMLDB') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade EM
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('EM') AS file_name FROM DUAL;
@&comp_file
SELECT dbms_registry_sys.time_stamp('EM') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade EXF
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('EXF') AS file_name FROM DUAL;
@&comp_file
SELECT dbms_registry_sys.time_stamp('EXF') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade OLS
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('OLS') AS file_name FROM DUAL;
@&comp_file
SELECT dbms_registry_sys.time_stamp('OLS') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade Ultrasearch
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('WK') AS file_name FROM DUAL;
@&comp_file
SELECT dbms_registry_sys.time_stamp('WK') AS timestamp FROM DUAL;
   
Rem ======================================================================
Rem Downgrade Spatial
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('SDO') AS file_name FROM DUAL;
@&comp_file 
SELECT dbms_registry_sys.time_stamp('SDO') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade Intermedia
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('ORDIM') AS file_name FROM DUAL;
@&comp_file
SELECT dbms_registry_sys.time_stamp('ORDIM') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade OLAP API
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('XOQ') AS file_name FROM DUAL;
@&comp_file
SELECT dbms_registry_sys.time_stamp('XOQ') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade OLAP Catalog
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('AMD') AS file_name FROM DUAL;
@&comp_file
SELECT dbms_registry_sys.time_stamp('AMD') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade OLAP Analytic Workspace
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('APS') AS file_name FROM DUAL;
@&comp_file
SELECT dbms_registry_sys.time_stamp('APS') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade Messaging Gateway
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('MGW') AS file_name FROM DUAL;
@&comp_file
SELECT dbms_registry_sys.time_stamp('MGW') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade Oracle Data Mining
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('ODM') AS file_name FROM DUAL;
@&comp_file
SELECT dbms_registry_sys.time_stamp('ODM') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade Oracle Workspace Manager
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('OWM') AS file_name FROM DUAL;
@&comp_file
SELECT dbms_registry_sys.time_stamp('OWM') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade RAC (no dictionary objects)
Rem ======================================================================

SET VERIFY OFF
BEGIN
   IF dbms_registry.status('RAC') NOT IN ('REMOVING','REMOVED') THEN
      IF  '&downgrade_file' = '0902000' THEN
         dbms_registry.downgraded('RAC','9.2.0');
      ELSE
         dbms_registry.downgraded('RAC','10.1.0');
      END IF;
   END IF;
END;
/
SELECT dbms_registry_sys.time_stamp('RAC') AS timestamp FROM DUAL;
SET VERIFY ON

Rem ======================================================================
Rem Downgrade XDB - XML Database 
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('XDB') AS file_name FROM DUAL;
@&comp_file
SELECT dbms_registry_sys.time_stamp('XDB') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade Text
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('CONTEXT') AS file_name FROM DUAL;
@&comp_file
SELECT dbms_registry_sys.time_stamp('CONTEXT') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade RDBMS java classes (CATJAVA)
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('CATJAVA') AS file_name FROM DUAL;
@&comp_file
SELECT dbms_registry_sys.time_stamp('CATJAVA') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade XDK for Java
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('XML') AS file_name FROM DUAL;
@&comp_file
SELECT dbms_registry_sys.time_stamp('XML') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade JServer (Last)
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('JAVAVM') AS file_name FROM DUAL;
@&comp_file
SELECT dbms_registry_sys.time_stamp('JAVAVM') AS timestamp FROM DUAL;

Rem ***********************************************************************
Rem END cmpdbdwg.sql
Rem ***********************************************************************

