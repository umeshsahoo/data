Rem
Rem $Header: s0801070.sql 18-mar-2004.12:29:16 gkaminag Exp $
Rem
Rem s0801070.sql
Rem
Rem Copyright (c) 2000, 2004, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      s0801070.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem     This script upgrades an 8.1.7.X schema to 9.0.1.0.
Rem     This script should be run as SYS on an 8.1.7 database
Rem     No other users or schema versions are supported.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    gkaminag    03/18/04 - 
Rem    ehuang      10/10/02 - call current directory
Rem    ehuang      07/30/02 - upgrade script restructuring
Rem    ehuang      04/05/00 - grant dba_roles to ctxsys
Rem    wclin       01/27/00 - fix bug 1134309
Rem    wclin       01/27/00 - Created
Rem

grant execute on dbms_pipe to ctxsys;
grant execute on dbms_lock to ctxsys;

REM now we are at 9.0.1 -- call 9.0.1 upgrade
@@s0900010.sql
