Rem
Rem $Header: catchnf.sql 10-aug-2004.14:14:25 ssvemuri Exp $
Rem
Rem catchnf.sql
Rem
Rem Copyright (c) 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catchnf.sql - Catalog for change notification
Rem
Rem    DESCRIPTION
Rem      Creates the dictionary objects necessary for the change notification.
Rem
Rem    NOTES
Rem      Refer to the change notification functional spec.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ssvemuri    05/12/05 - increase the size of the row_id col
Rem    ssvemuri    08/10/04 - Add change notification view 
Rem    ssvemuri    07/09/04 - ssvemuri_change_notification
Rem    ssvemuri    04/12/04 - Created
Rem

create table invalidation_registry$ ( 
  regid   number,
  regflags number,
  numobjs number,
  objarray  raw(512),
  plsqlcallback varchar2(128),
  changelag number,
  username varchar2(30)
)
/

create index i_invalidation_registry$ on invalidation_registry$(regid)
/

create sequence invalidation_reg_id$          /* registration sequence number */
  start with 1
  increment by 1
  minvalue 1
  nomaxvalue
  cache 20
  order
  nocycle
/


create or replace type sys.chnf$_reg_info_oc4j as object (
       network_ip_address varchar2(128),
       network_port number,
       qosflags number,
       timeout number,
       operations_filter number,
       transaction_lag number)
/

create or replace type sys.chnf$_reg_info as object (
       callback varchar2(64),
       qosflags number,
       timeout number,
       operations_filter number,
       transaction_lag number)
/


create or replace type chnf$_rdesc as object(
   opflags number,
   row_id varchar2(2000))
/

create or replace type chnf$_rdesc_array as VARRAY(1024) of chnf$_rdesc
/

create or replace type chnf$_tdesc as object(
   opflags number,
   table_name varchar2(64),
   numrows number,
   row_desc_array chnf$_rdesc_array)
/

create or replace type chnf$_tdesc_array as VARRAY(1024) of chnf$_tdesc
/

create or replace type chnf$_desc as object(
   registration_id number,
   transaction_id  raw(8),
   dbname          varchar2(30),
   event_type      number,
   numtables       number,
   table_desc_array   chnf$_tdesc_array)
/

GRANT EXECUTE on chnf$_reg_info_oc4j to PUBLIC;
/
GRANT EXECUTE on chnf$_reg_info to PUBLIC;
/
GRANT EXECUTE on chnf$_desc to PUBLIC;
/
GRANT EXECUTE on chnf$_tdesc to PUBLIC;
/
GRANT EXECUTE on chnf$_tdesc_array to PUBLIC;
/
GRANT EXECUTE on chnf$_rdesc to PUBLIC;
/
GRANT EXECUTE on chnf$_rdesc_array to PUBLIC;
/

create or replace view DBA_CHANGE_NOTIFICATION_REGS 
as select username, regid, regflags, callback, operations_filter, changelag, timeout,
   table_name from sys.x$ktcnreg
/
comment on table DBA_CHANGE_NOTIFICATION_REGS is
'Description of the registrations for change notification'
/
comment on column DBA_CHANGE_NOTIFICATION_REGS.USERNAME is
'owner of the registration'
/
comment on column DBA_CHANGE_NOTIFICATION_REGS.REGID is
'internal registration id'
/
comment on column DBA_CHANGE_NOTIFICATION_REGS.REGFLAGS is
'registration flags'
/
comment on column DBA_CHANGE_NOTIFICATION_REGS.CALLBACK is
'notification callback'
/
comment on column  DBA_CHANGE_NOTIFICATION_REGS.OPERATIONS_FILTER is
'operations filter (if specified)'
/
comment on column DBA_CHANGE_NOTIFICATION_REGS.CHANGELAG is
'transaction lag between notifications (if specified)'
/
comment on  column DBA_CHANGE_NOTIFICATION_REGS.TIMEOUT is
'registration timeout (if specified)'
/
comment on column DBA_CHANGE_NOTIFICATION_REGS.TABLE_NAME is
'name of registered table'
/
create or replace public synonym DBA_CHANGE_NOTIFICATION_REGS for DBA_CHANGE_NOTIFICATION_REGS
/
grant select on DBA_CHANGE_NOTIFICATION_REGS to select_catalog_role
/


create or replace view USER_CHANGE_NOTIFICATION_REGS
as 
select  r.regid, r.regflags, r.callback, r.operations_filter, r.changelag, r.timeout,
        r.table_name from
DBA_CHANGE_NOTIFICATION_REGS r, user$ u where u.user#= userenv('SCHEMAID')
and u.name = r.username
/
comment on table USER_CHANGE_NOTIFICATION_REGS is
'change notification registrations for current user'
/
comment on column USER_CHANGE_NOTIFICATION_REGS.REGID is
'internal registration id'
/
comment on column USER_CHANGE_NOTIFICATION_REGS.REGFLAGS is
'registration flags'
/
comment on column USER_CHANGE_NOTIFICATION_REGS.CALLBACK is
'notification callback'
/
comment on column  USER_CHANGE_NOTIFICATION_REGS.OPERATIONS_FILTER is
'operations filter (if specified)'
/
comment on column USER_CHANGE_NOTIFICATION_REGS.CHANGELAG is
'transaction lag between notifications (if specified)'
/
comment on  column USER_CHANGE_NOTIFICATION_REGS.TIMEOUT is
'registration timeout (if specified)'
/
comment on column USER_CHANGE_NOTIFICATION_REGS.TABLE_NAME is
'name of registered table'
/
create or replace public synonym USER_CHANGE_NOTIFICATION_REGS for USER_CHANGE_NOTIFICATION_REGS
/
grant select on USER_CHANGE_NOTIFICATION_REGS to public with grant option
/
