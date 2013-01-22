Rem
Rem $Header: xdbrlu.sql 27-dec-2004.13:42:46 vkapoor Exp $
Rem
Rem xdbrlu.sql
Rem
Rem Copyright (c) 2002, 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      xdbrlu.sql - Xml DB ReLoad Upgrade packages
Rem
Rem    DESCRIPTION
Rem      Replaces all XDB-related packages with the current versions.
Rem
Rem    NOTES
Rem      None
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    vkapoor    12/27/04 - vkapoor_lrg-1802906
Rem    vkapoor    12/16/04 - Creating new file for upgrade only scripts 
Rem

WHENEVER SQLERROR EXIT;
EXECUTE dbms_registry.check_server_instance;
WHENEVER SQLERROR CONTINUE;

-- Some implementations have these operators defined, and some don't.
-- Regardless, they are unused in 9.2.0.2 and should be dropped.
begin
  execute immediate 'drop indextype xdb.path_index';
exception
  when others then
    commit;
end;
/
begin
  execute immediate 'drop operator xdb.xdbpi_noop';
exception
  when others then
    commit;
end;
/

Rem Reload the XML DB packages.  This is the main step.
@@dbmsxsch.sql
@@xdbptrl2.sql

Rem Clean up invalidated objects
@@xdbvlo.sql
