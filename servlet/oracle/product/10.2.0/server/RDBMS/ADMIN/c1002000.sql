Rem
Rem $Header: c1002000.sql 14-mar-2005.11:22:09 rburns Exp $
Rem
Rem c1002000.sql
Rem
Rem Copyright (c) 2001, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      c1002000.sql - Script to apply 10.2 patch releases
Rem
Rem    DESCRIPTION
Rem      This script encapsulates the "post install" steps necessary
Rem      to upgrade the SERVER dictionary to the new patchset version.
Rem      It runs the new patchset versions of catalog.sql and catproc.sql
Rem      and calls the component patch scripts.
Rem
Rem    NOTES
Rem      Use SQLPLUS and connect AS SYSDBA to run this script.
Rem      The database must be open for UPGRADE
Rem      
Rem    MODIFIED   (MM/DD/YY)
Rem    rburns      03/14/05 - use dbms_registry_sys
Rem    rburns      01/18/05 - comment out htmldb for 10.2 
Rem    rburns      11/11/04 - move CONTEXT 
Rem    rburns      11/08/04 - add HTMLDB 
Rem    rburns      10/21/04 - rburns_rename_catpatch
Rem    rburns      10/18/04 - rename to c1002000.sql (was catpatch.sql)
Rem    rburns      10/11/04 - add RUL 
Rem    rburns      06/17/04 - final timestamp to catupgrd 
Rem    rburns      04/07/04 - move utllmup.sql to catupgrd 
Rem    rburns      02/23/04 - add EM 
Rem    rburns      08/28/03 - cleanup 
Rem    rburns      04/25/03 - use timestamp
Rem    rburns      04/08/03 - use function for script names
Rem    rburns      01/20/03 - fix version, add exf, re-order olap
Rem    rburns      01/18/03 - use server registry
Rem    dvoss       01/14/03 - add utllmup.sql
Rem    rburns      08/27/02 - add Ultra Search patch
Rem    rburns      07/18/02 - comment components not in patch release
Rem    rburns      05/14/02 - convert for 9.2.0.2
Rem    rburns      03/29/02 - convert for 9.2.0
Rem    rburns      10/15/01 - add scope argument
Rem    rburns      10/10/01 - Merged rburns_patchset_tests
Rem    rburns      09/26/01 - Version for 9.0.1.2.0 patchset
Rem    rburns      09/26/01 - Created
Rem

Rem *************************************************************************
Rem BEGIN c1002000.sql
Rem *************************************************************************

SELECT dbms_registry_sys.time_stamp('PATCH_BGN') AS timestamp FROM DUAL;

WHENEVER SQLERROR EXIT;

Rem =======================================================================
Rem Verify server version and UPGRADE status
Rem =======================================================================

EXECUTE dbms_registry.check_server_instance;

Rem =======================================================================
Rem Set event to avoid unnecessary re-compilations
Rem =======================================================================

ALTER SESSION SET EVENTS '10520 TRACE NAME CONTEXT FOREVER, LEVEL 10'; 

WHENEVER SQLERROR CONTINUE;

Rem =======================================================================
Rem Run catalog.sql and catproc.sql
Rem =======================================================================

@@catalog.sql
@@catproc.sql 
SELECT dbms_registry_sys.time_stamp('CATPROC') AS timestamp FROM DUAL;

Rem *************************************************************************
Rem START Component Patches 
Rem *************************************************************************

Rem Setup component script filename variable
COLUMN patch_name NEW_VALUE patch_file NOPRINT;

Rem JServer
SELECT dbms_registry_sys.patch_script('JAVAVM') AS patch_name FROM DUAL;
@&patch_file
SELECT dbms_registry_sys.time_stamp('JAVAVM') AS timestamp FROM DUAL;

Rem XDK for Java
SELECT dbms_registry_sys.patch_script('XML') AS patch_name FROM DUAL;
@&patch_file
SELECT dbms_registry_sys.time_stamp('XML') AS timestamp FROM DUAL;

Rem Java Supplied Packages
SELECT dbms_registry_sys.patch_script('CATJAVA') AS patch_name FROM DUAL;
@&patch_file
SELECT dbms_registry_sys.time_stamp('CATJAVA') AS timestamp FROM DUAL;

Rem Text
SELECT dbms_registry_sys.patch_script('CONTEXT') AS patch_name FROM DUAL;
@&patch_file
SELECT dbms_registry_sys.time_stamp('CONTEXT') AS timestamp FROM DUAL;

Rem Oracle XML Database
SELECT dbms_registry_sys.patch_script('XDB') AS patch_name FROM DUAL;
@&patch_file
SELECT dbms_registry_sys.time_stamp('XDB') AS timestamp FROM DUAL;

Rem Real Application Clusters
SELECT dbms_registry_sys.patch_script('RAC') AS patch_name FROM DUAL;
@&patch_file
SELECT dbms_registry_sys.time_stamp('RAC') AS timestamp FROM DUAL;

Rem Oracle Workspace Manager
SELECT dbms_registry_sys.patch_script('OWM') AS patch_name FROM DUAL;
@&patch_file
SELECT dbms_registry_sys.time_stamp('OWM') AS timestamp FROM DUAL;

Rem Oracle Data Mining
SELECT dbms_registry_sys.patch_script('ODM') AS patch_name FROM DUAL;
@&patch_file
SELECT dbms_registry_sys.time_stamp('ODM') AS timestamp FROM DUAL;

Rem Messaging Gateway
SELECT dbms_registry_sys.patch_script('MGW') AS patch_name FROM DUAL;
@&patch_file
SELECT dbms_registry_sys.time_stamp('MGW') AS timestamp FROM DUAL;

Rem OLAP Analytic Workspace
SELECT dbms_registry_sys.patch_script('APS') AS patch_name FROM DUAL;
@&patch_file
SELECT dbms_registry_sys.time_stamp('APS') AS timestamp FROM DUAL;

Rem OLAP Catalog 
SELECT dbms_registry_sys.patch_script('AMD') AS patch_name FROM DUAL;
@&patch_file
SELECT dbms_registry_sys.time_stamp('AMD') AS timestamp FROM DUAL;

Rem OLAP API
SELECT dbms_registry_sys.patch_script('XOQ') AS patch_name FROM DUAL;
@&patch_file
SELECT dbms_registry_sys.time_stamp('XOQ') AS timestamp FROM DUAL;

Rem Intermedia
SELECT dbms_registry_sys.patch_script('ORDIM') AS patch_name FROM DUAL;
@&patch_file
SELECT dbms_registry_sys.time_stamp('ORDIM') AS timestamp FROM DUAL;

Rem Spatial
SELECT dbms_registry_sys.patch_script('SDO') AS patch_name FROM DUAL;
@&patch_file
SELECT dbms_registry_sys.time_stamp('SDO') AS timestamp FROM DUAL;

Rem Ultrasearch
SELECT dbms_registry_sys.patch_script('WK') AS patch_name FROM DUAL;
@&patch_file
SELECT dbms_registry_sys.time_stamp('WK') AS timestamp FROM DUAL;

Rem Oracle Label Security
SELECT dbms_registry_sys.patch_script('OLS') AS patch_name FROM DUAL;
@&patch_file
SELECT dbms_registry_sys.time_stamp('OLS') AS timestamp FROM DUAL;

Rem Expression Filter
SELECT dbms_registry_sys.patch_script('EXF') AS patch_name FROM DUAL;
@&patch_file
SELECT dbms_registry_sys.time_stamp('EXF') AS timestamp FROM DUAL;

Rem Enterprise Manager Repository
SELECT dbms_registry_sys.patch_script('EM') AS patch_name FROM DUAL;
@&patch_file
SELECT dbms_registry_sys.time_stamp('EM') AS timestamp FROM DUAL;

Rem Rule Manager
SELECT dbms_registry_sys.patch_script('RUL') AS patch_name FROM DUAL;
@&patch_file
SELECT dbms_registry_sys.time_stamp('RUL') AS timestamp FROM DUAL;

Rem HTML DB
-- SELECT dbms_registry_sys.patch_script('HTMLDB') AS patch_name FROM DUAL;
-- @&patch_file
-- SELECT dbms_registry_sys.time_stamp('HTMLDB') AS timestamp FROM DUAL;

set serveroutput off

Rem *************************************************************************
Rem END Component Patches
Rem *************************************************************************

Rem =======================================================================
Rem Turn SESSION event off
Rem =======================================================================

ALTER SESSION SET EVENTS '10520 TRACE NAME CONTEXT OFF'; 

Rem *************************************************************************
Rem END c1002000.sql
Rem *************************************************************************
