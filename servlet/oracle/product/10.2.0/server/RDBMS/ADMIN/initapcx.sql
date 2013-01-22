Rem
Rem $Header: initapcx.sql 03-jun-2003.10:59:43 rvissapr Exp $
Rem
Rem initapcx.sql
Rem
Rem Copyright (c) 2000, 2003, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      initapcx.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      Loads appctxapi.jar for JavaVm enabled Database.Called by jcoreini.tsc
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rvissapr    06/03/03 - bug 2980591
Rem    rburns      12/03/01 - remove echo
Rem    jnarasin    09/28/01 - Remove set echo off.
Rem    jnarasin    04/04/01 - Using jschwarz workaround till 1720684 is fixed
Rem    rvissapr    01/11/01 - Merged rvissapr_chg_jinitappctx_nm
Rem    rvissapr    12/17/00 - Created
Rem
Rem  

call sys.dbms_java.loadjava('-v -r -g  public -f rdbms/jlib/appctxapi.jar');

alter java class "oracle/security/rdbms/server/AppCtx/AppCtxManager" authid definer;

