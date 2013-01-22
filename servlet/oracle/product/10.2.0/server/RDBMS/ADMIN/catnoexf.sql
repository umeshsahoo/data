Rem
Rem $Header: catnoexf.sql 19-apr-2004.06:14:25 ayalaman Exp $
Rem
Rem catnoexf.sql
Rem
Rem Copyright (c) 2002, 2004, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      catnoexf.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ayalaman    04/19/04 - cleanup export dependeny actions 
Rem    ayalaman    11/19/02 - registry entries
Rem    ayalaman    09/26/02 - ayalaman_expression_filter_support
Rem    ayalaman    09/06/02 - 
Rem    ayalaman    09/06/02 - Created
Rem


REM 
REM Drop the Expression Filter user with cascade option 
REM 
EXECUTE dbms_registry.removing('EXF');
drop user exfsys cascade;
drop package sys.exf$dbms_expfil_syspack;
begin
  -- since this is a fresh install, delete any actions left behind --
  -- from past installations --
  delete from sys.expdepact$ where schema = 'EXFSYS'
    and package = 'DBMS_EXPFIL_DEPASEXP';
  delete from sys.exppkgact$ where package = 'DBMS_EXPFIL_DEPASEXP'
    and schema = 'EXFSYS';
end;
/

execute sys.dbms_java.dropjava('-s rdbms/jlib/ExprFilter.jar');
EXECUTE dbms_registry.removed('EXF');
