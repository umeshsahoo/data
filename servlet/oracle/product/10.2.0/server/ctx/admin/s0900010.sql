Rem
Rem s0900010.sql
Rem
Rem Copyright (c) 2000, 2004, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      s0900010.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem     This script upgrades an 9.0.1.X schema to 9.2.0.1.
Rem     This script should be run as SYS on an 9.0.1 ctxsys schema
Rem     No other users or schema versions are supported.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    gkaminag    03/18/04 - 
Rem    ehuang      10/10/02 - call current directory
Rem    ehuang      07/30/02 - upgrade script restructuring
Rem    gkaminag    04/19/01 - name change to 9.0.1
Rem    wclin       03/09/01 - put in real fix for bug 1629476
Rem    wclin       02/26/01 - bug 1629476 work around
Rem    gkaminag    12/21/00 - Creation
Rem

grant select on SYS.TS$ to ctxsys with grant option;
grant select on SYS.TABPART$ to ctxsys with grant option;
grant select on SYS.IND$ to ctxsys with grant option;
grant select on SYS.INDPART$ to ctxsys with grant option;
grant select on SYS.DBA_TYPES to ctxsys with grant option;
grant execute on dbms_registry to ctxsys with grant option;

