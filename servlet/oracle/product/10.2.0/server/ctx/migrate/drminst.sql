Rem
Rem $Header: drminst.sql 02-jun-98.14:22:01 gkaminag Exp $
Rem
Rem drminst.sql
Rem
Rem  Copyright (c) Oracle Corporation 1998. All Rights Reserved.
Rem
Rem    NAME
Rem      drminst.sql - Migration INSTall
Rem
Rem    DESCRIPTION
Rem      installation of migration (2.X -> 8.1) tables
Rem
Rem    NOTES
Rem      
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    gkaminag    06/02/98 - migration install
Rem    gkaminag    06/02/98 - Created
Rem

drop table dr$msql;
create table dr$msql
( line number primary key,
  text varchar2(200)
);

REM objects

drop table dr$mpref;
create table dr$mpref
(
  mp_pre_owner varchar2(30),
  mp_pre_name  varchar2(30),
  mp_new       varchar2(30),
  constraint drc$mp_key primary key (mp_pre_owner, mp_pre_name)
);


drop table dr$msec;
create table dr$msec
(
  ms_sg_owner varchar2(30),
  ms_sg_name  varchar2(30),
  ms_new      varchar2(30),
  constraint drc$ms_key primary key (ms_sg_owner, ms_sg_name)
);

@drmig.pkh
show errors

@drmig.pkb
show errors
