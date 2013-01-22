Rem
Rem $Header: dbmsxreg.sql 01-nov-2004.13:06:41 pnath Exp $
Rem
Rem dbmsxreg.sql
Rem
Rem Copyright (c) 2002, 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmsxreg.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      Package definiton of the registry package.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pnath       10/25/04 - Make SYS the owner of DBMS_REGXDB package 
Rem    spannala    01/09/02 - Merged spannala_upg
Rem    spannala    01/03/02 - Created
Rem

create or replace package sys.DBMS_REGXDB authid current_user as
  procedure validatexdb;
end dbms_regxdb;
/


