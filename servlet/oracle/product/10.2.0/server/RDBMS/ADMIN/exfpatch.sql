Rem
Rem $Header: exfpatch.sql 15-oct-2004.11:15:34 ayalaman Exp $
Rem
Rem exfpatch.sql
Rem
Rem Copyright (c) 2002, 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      exfpatch.sql - Script to patch Expression Filter implementations.
Rem
Rem    DESCRIPTION
Rem      This script patches the Expression filter implementations.
Rem
Rem    NOTES
Rem      See Documentation.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ayalaman    10/15/04 - Use new validation script 
Rem    ayalaman    10/07/04 - new validation procedure in SYS 
Rem    ayalaman    07/23/04 - forward merge: compile invalid objects 
Rem    ayalaman    11/23/02 - ayalaman_exf_tests
Rem    ayalaman    11/19/02 - Created
Rem

WHENEVER SQLERROR EXIT
EXECUTE dbms_registry.check_server_instance;
WHENEVER SQLERROR CONTINUE;
          
ALTER SESSION SET CURRENT_SCHEMA = EXFSYS;
begin
  sys.dbms_registry.loading(comp_id=>'EXF', 
                            comp_name=>'Oracle Expression Filter',
                            comp_proc=>'VALIDATE_EXF');
end;
/

REM
REM Create the Java library in EXFSYS schema
REM
prompt .. loading the Expression Filter Java library
@@initexf.sql

REM
REM Reload the view definitions
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

EXECUTE sys.dbms_registry.loaded('EXF');

EXECUTE sys.validate_exf;

ALTER SESSION SET CURRENT_SCHEMA = SYS;
