Rem
Rem $Header: u1002000.sql 21-feb-2005.11:45:16 gkaminag Exp $
Rem
Rem u1002000.sql
Rem
Rem Copyright (c) 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      u1002000.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      upgrade ctxsys from 9.2.0.X to 10
Rem
Rem    NOTES
Rem      This script upgrades a 10.2.0.X ctxsys data dictionary to latest  
Rem      This script should be run as ctxsys on an 10.2.0 ctxsys schema
Rem      (or as SYS with ALTER SESSION SET SCHEMA = CTXSYS)
Rem      No other users or schema versions are supported.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    gkaminag    02/21/05 - gkaminag_test_050217
Rem    gkaminag    02/17/05 - Created
Rem

REM
REM  IF YOU ADD ANYTHING TO THIS FILE REMEMBER TO CHANGE DOWNGRADE SCRIPT
REM
