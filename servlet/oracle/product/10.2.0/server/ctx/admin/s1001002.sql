Rem
Rem $Header: s1001002.sql 03-aug-2004.16:06:04 gkaminag Exp $
Rem
Rem s1001002.sql
Rem
Rem Copyright (c) 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      s1001002.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      SYS changes for CTXSYS upgrade 10.1 to 10.2
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    gkaminag    08/03/04 - deprecate connect 
Rem    gkaminag    03/22/04 - gkaminag_misc_040318 
Rem    gkaminag    03/18/04 - Created
Rem

REM
REM  IF YOU ADD ANYTHING TO THIS FILE REMEMBER TO CHANGE CTXE* SCRIPT
REM

REM connect deprecated

revoke CONNECT from CTXSYS;
grant create session, alter session, create view, create synonym to CTXSYS;

