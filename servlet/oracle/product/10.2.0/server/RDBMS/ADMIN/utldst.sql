Rem
Rem $Header: utldst.sql 28-jul-00.14:48:17 jdavison Exp $
Rem
Rem utldst.sql
Rem
Rem  Copyright (c) Oracle Corporation 1998, 1999, 2000. All Rights Reserved.
Rem
Rem    NAME
Rem      utldst.sql - Downgrade System Types compatibility
Rem
Rem    DESCRIPTION
Rem      Run this script in order to downgrade the image format of the
Rem	 system types from 8.1 compatibility to 8.0 compatibility.
Rem
Rem    NOTES
Rem      * This script must be run using SQL*PLUS.
Rem      * You must be connected AS SYSDBA to run this script.
Rem      * This script should be run BEFORE the downgrade (d0800050.sql)
Rem	   is run OR if the db compatibility needs to be changed from 8.2 or
Rem	   8.1 to 8.0.  It only needs to be run if the database was created
Rem	   or upgraded with COMPATIBLE=8.2 or COMPATIBLE=8.1 in the
Rem	   init.ora file.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jdavison    07/28/00 - Add KOTTBX$ to list of type tables.
Rem    jdavison    04/28/00 - Downgrade image format of aq_queue_upgrade_tmp ta
Rem    rshaikh     08/11/99 - bug 952195: dont assume SYS is user 0
Rem    rshaikh     12/03/98 - flush shared pools before downgrading sys types
Rem    rshaikh     11/17/98 - fix downgrd procedure
Rem    rshaikh     08/27/98 - Created
Rem

Rem =========================================================================
Rem Downgrade the system types
Rem =========================================================================

REM
REM commit and flush the shared pools before we downgrade sys types
REM because the old version may be hanging around in the cache.
REM If it is, we may no get rid of the 8.1 compatible version, and 
REM then using types on 8.0.x will fail because the image will be
REM bad.
REM
commit
/
alter system flush shared_pool
/

declare
  num_tables number;
  cur        binary_integer;
  dummy      binary_integer;
begin
 
  select count(*) into num_tables
  from obj$ o, coltype$ c, user$ u
  where bitand(c.flags, 128) != 128 and
        c.obj# = o.obj# and
        o.name in ('KOTTD$', 'KOTAD$', 'KOTMD$', 'KOTTB$', 'KOTTBX$') and
        o.owner# = u.user# and o.type# = 2 and
	u.name = 'SYS';
 
  if num_tables > 0 then
    update coltype$ c
    set c.flags = c.flags + 128
    where bitand(c.flags, 128) != 128 and
          c.obj# in (select o.obj# from obj$ o, user$ u
                     where o.name in
                       ('KOTTD$', 'KOTAD$', 'KOTMD$', 'KOTTB$', 'KOTTBX$')
                       and o.owner# = u.user# and u.name = 'SYS' and
                           o.type# = 2);
 
    cur := dbms_sql.open_cursor;
 
    dbms_sql.parse(cur, 'update kottd$ p set value(p) = value(p)',
                   dbms_sql.native);
    dummy := dbms_sql.execute(cur);
    dbms_sql.parse(cur, 'update kotad$ p set value(p) = value(p)',
                   dbms_sql.native);
    dummy := dbms_sql.execute(cur);
    dbms_sql.parse(cur, 'update kotmd$ p set value(p) = value(p)',
                   dbms_sql.native);
    dummy := dbms_sql.execute(cur);
    dbms_sql.parse(cur, 'update kottb$ p set value(p) = value(p)',
                   dbms_sql.native);
    dummy := dbms_sql.execute(cur);
    dbms_sql.parse(cur, 'update kottbx$ p set value(p) = value(p)',
                   dbms_sql.native);
    dummy := dbms_sql.execute(cur);
 
    dbms_sql.close_cursor(cur);
  end if;
end;
/

Rem procedure used in downgrading AQ tables with 8.1 object format

create or replace procedure downgrd(sch in varchar2, tbnm in varchar2) as
  cur     binary_integer;
  stmt    varchar2(1000);
  status  binary_integer;
  dotname varchar2(1000);
begin
  dotname := sch || '.' || tbnm;
  cur := dbms_sql.open_cursor;
 
  dbms_sql.parse(cur, 'alter session set events ''22932 trace name context forever, level 1''', dbms_sql.native);
  status := dbms_sql.execute(cur);
  dbms_sql.parse(cur, 'create table ' || dotname || '_TEMP as select * from ' || dotname, dbms_sql.native);
  status := dbms_sql.execute(cur);
  dbms_sql.parse(cur, 'drop table ' || dotname, dbms_sql.native);
  status := dbms_sql.execute(cur);
  stmt := 'update obj$ set name = ''' || tbnm || ''' where name = ''' || tbnm || '_TEMP'' and owner# = (select user# from user$ where name = ''' || sch || ''')';
  dbms_sql.parse(cur, stmt, dbms_sql.native);
  status := dbms_sql.execute(cur);
  dbms_sql.parse(cur, 'alter session set events ''22932 trace name context off''', dbms_sql.native);
  status := dbms_sql.execute(cur);
 
  dbms_sql.close_cursor(cur);
end;
/
 
Rem =========================================================================
Rem Downgrade AQ tables that store objects in the new image format
Rem =========================================================================
 
declare
  aq81 binary_integer;
begin
  select count(*) into aq81 from coltype$ ct, obj$ o, user$ u
  where o.name = 'AQ$_QUEUES' and u.name = 'SYSTEM' and
        u.user# = o.owner# and ct.obj# = o.obj# and bitand(ct.flags, 128) = 0;
  if aq81 > 0 then
    downgrd('SYSTEM', 'AQ$_QUEUES');
  end if;
  select count(*) into aq81 from coltype$ ct, obj$ o, user$ u
  where o.name = 'AQ$_QUEUE_UPGRADE_TMP' and u.name = 'SYSTEM' and
        u.user# = o.owner# and ct.obj# = o.obj# and bitand(ct.flags, 128) = 0;
  if aq81 > 0 then
    downgrd('SYSTEM', 'AQ$_QUEUE_UPGRADE_TMP');
  end if;
end;
/

commit
/
