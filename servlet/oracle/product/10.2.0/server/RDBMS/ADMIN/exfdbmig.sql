Rem
Rem $Header: exfdbmig.sql 15-oct-2004.11:12:14 ayalaman Exp $
Rem
Rem exfdbmig.sql
Rem
Rem Copyright (c) 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      exfdbmig.sql - Migration script for Expression Filter (EXF) 
Rem
Rem    DESCRIPTION
Rem      Migration script for the Expression Filter(EXF) component.
Rem      This component was first introduced in 10.1 
Rem
Rem    NOTES
Rem      None. 
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ayalaman    10/15/04 - set validation script explicitly in upgrading 
Rem    ayalaman    10/08/04 - compile invalid objects 
Rem    ayalaman    04/23/04 - ayalaman_rule_manager_support 
Rem    ayalaman    03/24/04 - Created
Rem

WHENEVER SQLERROR EXIT;
EXECUTE dbms_registry.check_server_instance;
WHENEVER SQLERROR CONTINUE;

REM Indicate that the upgrade of EXF has begun 
EXECUTE dbms_registry.upgrading(comp_id=>'EXF', new_proc=>'VALIDATE_EXF');

REM Set current schema to EXFSYS 
ALTER SESSION SET CURRENT_SCHEMA = EXFSYS;

REM Get the appropriate file name for upgrade 
COLUMN :script_name NEW_VALUE comp_file NOPRINT
VARIABLE script_name VARCHAR2(12)

BEGIN
  IF (substr(dbms_registry.version('EXF'),1,6)='10.1.0') THEN 
    :script_name := '@exfu101.sql';
  ELSE 
    :script_name := dbms_registry.nothing_script;
  END IF;
END;
/

SELECT :script_name FROM DUAL;
@&comp_file

REM
REM Recreate the Java library in EXFSYS schema. 
REM (This is not optional for Expression Filter.)
REM
@@initexf.sql

REM
REM Recreate Public PL/SQL Package specifications
REM
@@exfpbs.sql

REM
REM Recreate the view definitions
REM
@@exfview.sql

REM
REM Create package/type implementations
REM
prompt .. creating Expression Filter package/type implementations
@@exfsppvs.plb

@@exfeapvs.plb

@@exfimpvs.plb

@@exfxppvs.plb

alter indextype expfilter compile;

alter operator evaluate compile;

REM
REM End of Upgrade (use the RDBMS release version number)
REM
EXECUTE dbms_registry.upgraded('EXF'); 

EXECUTE sys.validate_exf;

ALTER SESSION SET CURRENT_SCHEMA = SYS;

