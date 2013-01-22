Rem
Rem $Header: xdbrelod.sql 16-dec-2004.11:37:23 spannala Exp $
Rem
Rem xdbrelod.sql
Rem
Rem Copyright (c) 2002, 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      xdbrelod.sql - Xml DB RELOaD packages
Rem
Rem    DESCRIPTION
Rem      Replaces all XDB-related packages with the current versions.
Rem
Rem    NOTES
Rem      None
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    vkapoor     12/16/04 - Creating a new file for upgrade reload script
Rem    spannala    06/18/03 - removing xdbptrl1.sql
Rem    njalali     04/02/03 - using xdbvlo.sql
Rem    njalali     03/28/03 - compiling invalid stuff after upgrade
Rem    nmontoya    02/13/03 - move xdb$patchupdeleteschema comp FROM xdbu920
Rem    njalali     11/14/02 - Created
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

Rem Run the first part of the relod
@@xdbptrl1.sql

Rem Now run the reload script we use for upgrade.
@@xdbrlu.sql
