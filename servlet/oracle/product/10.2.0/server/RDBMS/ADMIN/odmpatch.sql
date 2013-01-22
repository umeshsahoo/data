Rem ##########################################################################
Rem 
Rem Copyright (c) 2001, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      odmpatch.sql
Rem
Rem    DESCRIPTION
Rem      Script for Data Mining patch loading 
Rem
Rem    RETURNS
Rem 
Rem    NOTES
Rem      This script must be run while connected as SYS. After running the script, 
Rem      ODM should be at 10.2.0.X patch release level   
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    xbarr    02/03/05 - updated banner in registry
Rem    xbarr    01/27/05 - updated for 10.2 patchset 
Rem    xbarr    10/29/04 - move validation proc to SYS 
Rem    xbarr    06/25/04 - xbarr_dm_rdbms_migration
Rem    amozes   06/23/04 - remove hard tabs
Rem    xbarr    04/23/04 - 
Rem    xbarr    03/25/04 - updated for 10.1.0.3 ODM patch release 
Rem    xbarr    12/22/03 - remove dbms_java.set_output 
Rem    fcay     06/23/03 - Update copyright notice
Rem    xbarr    05/30/03 - updated for ODM 9204 patch release 
Rem    xbarr    02/14/03 - xbarr_txn106309
Rem    xbarr    02/12/03 - Creation
Rem
Rem #########################################################################


set serveroutput on;


ALTER SESSION SET CURRENT_SCHEMA = "DMSYS";

Rem Upgrade DMSYS schema objects (TBD post 10.2)
Rem @@dmsyssch_patch.sql

Rem Upgrade DMSYS packages
@@dmproc.sql

Rem Upgrade Trusted Code BLAST
@@dbmsdmbl.sql

Rem Upgrade ODM Predictive package
@@dbmsdmpa.sql
@@prvtdmpa.plb

Rem Upgrade OJDM internal package
@@prvtdmj.plb


ALTER SESSION SET CURRENT_SCHEMA = "SYS";

execute sys.dbms_registry.upgraded('ODM','10.2.0.0.0','Oracle Data Mining Release 10.2.0.0.0 - Beta');

Rem DM validate proc
@@odmproc.sql

execute sys.validate_odm;
