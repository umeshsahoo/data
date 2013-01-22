Rem
Rem $Header: catnohs.sql 31-jul-2001.11:32:25 pravelin Exp $
Rem
Rem catnohs.sql
Rem
Rem Copyright (c) 1997, 2001, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem
Rem      catnohs.sql - Drop HS data dictionary tables & views
Rem
Rem    DESCRIPTION
Rem      This SQL script drops all database objects created for
Rem      Heterogeneous Services by caths.sql.
Rem
Rem      This script is available to HS content in the DD in the event
Rem      that DD content is seriously damaged.  Beginning with Oracle
Rem      9.0.2 the caths.sql script no longer purges table contents
Rem      in tables that exist when it is executed.  Executing caths.sql
Rem      alone would certail classes of errors but not all. Complete
Rem      replacement of HS DD content requires running catnohs.sql
Rem      first, then rerunning caths.sql.
Rem
Rem    NOTES
Rem      This script must be run while connected as SYS or INTERNAL.
Rem
Rem      catnohs.sql was originally required to deinstall the
Rem      Heterogeneous Option.  This functionality is no longer
Rem      optional, it now comprises the Heterogeneous Services feature
Rem      of Oracle 8 and subsequent RDBMS releases.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pravelin    07/31/01 - Document expected usage of this script.
Rem    rhungund    10/12/00 - adding the HS_FDS_CLASS_DATE table and view
Rem    delson      08/28/00 - remove processing of unused tables.
Rem    jdraaije    03/26/97 - Name consistency: ho => hs
Rem    pravelin    11/22/96 - Resynchronize this script with catho.sql updates
Rem    pravelin    06/26/96 - Drop HS data dictionary tables & views
Rem    pravelin    06/26/96 - Created
Rem


drop role hs_admin_role;
drop table hs$_fds_class cascade constraints; 
drop sequence hs$_fds_class_s; 
drop view hs_fds_class; 
drop table hs$_fds_inst cascade constraints; 
drop sequence hs$_fds_inst_s; 
drop view hs_fds_inst;
drop table hs$_base_caps cascade constraints; 
drop view hs_base_caps;
drop table hs$_class_caps cascade constraints; 
drop sequence hs$_class_caps_s;
drop view hs_class_caps;
drop table hs$_inst_caps cascade constraints; 
drop sequence hs$_inst_caps_s; 
drop view hs_inst_caps;
drop table hs$_base_dd cascade constraints; 
drop sequence hs$_base_dd_s; 
drop view hs_base_dd;
drop table hs$_class_dd cascade constraints; 
drop sequence hs$_class_dd_s; 
drop view hs_class_dd;
drop table hs$_inst_dd cascade constraints; 
drop sequence hs$_inst_dd_s; 
drop view hs_inst_dd;
drop table hs$_class_init cascade constraints; 
drop sequence hs$_class_init_s; 
drop view hs_class_init;
drop table hs$_inst_init cascade constraints; 
drop sequence hs$_inst_init_s; 
drop view hs_inst_init;
drop view hs_all_caps;
drop view hs_all_dd;
drop view hs_all_inits;
drop package dbms_hs;
drop package dbms_hs_alt;
drop package dbms_hs_chk;
drop package dbms_hs_utl;
drop public synonym hs_fds_class;
drop public synonym hs_fds_inst;
drop public synonym hs_base_caps;
drop public synonym hs_class_caps;
drop public synonym hs_inst_caps;
drop public synonym hs_base_dd;
drop public synonym hs_class_dd;
drop public synonym hs_inst_dd;
drop public synonym hs_class_init;
drop public synonym hs_inst_init;
drop public synonym hs_all_caps;
drop public synonym hs_all_dd;
drop public synonym hs_all_inits;
drop public synonym dbms_hs;
drop table hs$_fds_class_date;
drop view hs_fds_class_date;
