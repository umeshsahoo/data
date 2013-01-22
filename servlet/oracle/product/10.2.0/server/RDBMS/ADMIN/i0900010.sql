Rem
Rem $Header: i0900010.sql 24-oct-2003.12:54:29 arithikr Exp $
Rem
Rem i0900010.sql
Rem
Rem Copyright (c) 1999, 2003, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      i0900010.sql - load 9.2.0 specific tables that are need to
Rem		 	process basic sql statements
Rem
Rem    DESCRIPTION
Rem	 This script MUST be one of the first things called from the 
Rem	 one path upgrade scripts (ie - u0703040.sql, u0800050.sql, ...)
Rem
Rem	 Only put statements in here that must be run in order
Rem	 to process basic sql commands.  For example, in order to 
Rem	 drop a package, the server code may depend on new tables.
Rem	 If these tables do not exist, we get a recursive sql error
Rem	 causing the command to be aborted.
Rem
Rem      The upgrade is performed in the following stages:
Rem        STAGE 1: load 9.2.0 specific tables 
Rem        STAGE 2: invoke script for subsequent version
Rem
Rem    NOTES
Rem      * This script must be run using SQL*PLUS.
Rem      * You must be connected AS SYSDBA to run this script.
Rem 
Rem    MODIFIED   (MM/DD/YY)
Rem    arithikr    10/24/03 - 3126930 - add drop_segments column to mon_mods 
Rem    ssubrama    06/10/02 - bug 2385207 move delete from dependency$
Rem    rburns      02/13/02 - call 9.2.0 script
Rem    jdraaije    01/07/02 - Add dblink to index i_apply_source_obj2
Rem    rburns      11/07/01 - move index change
Rem    wesmith     11/06/01 - Streams upgrade
Rem    apadmana    11/05/01 - make index on exppkgobj$ non-unique
Rem    ayoaz       10/03/01 - Add synobj# to subcoltype$.
Rem    vmarwah     10/18/01 - LOB Retention compatibility (upgrade script).
Rem    rburns      10/08/01 - move delete from duc
Rem    rburns      08/23/01 - move attribute synonym columns to i script
Rem    shshanka    07/23/01 - Add defsubpart$ and defsubpartlob$.
Rem    rburns      06/07/01 - Merged rburns_setup_901_upgrade
Rem    rburns      06/05/01 - Created
Rem

Rem =========================================================================
Rem BEGIN STAGE 1: load 9.2.0 specific tables
Rem =========================================================================


REM Add retention and freepools to LOB$
ALTER TABLE sys.lob$
ADD
(
    retention    number,
    freepools    number
)
/
UPDATE sys.lob$ SET retention = 0
/
UPDATE sys.lob$ SET freepools = 65535
/
ALTER TABLE sys.lob$
MODIFY
(
    retention    number not null,
    freepools    number not null
)
/


Rem =========================================================================
Rem BEGIN join index changes (moved from 8.1.7 script)
Rem =========================================================================

rem join index join conditions
create table jijoin$
(
  obj#      number not null,				  /* join index obj# */
  tab1obj#  number not null,			       /* table 1 obj number */
  tab1col#  number not null,	       /* internal column number for table 1 */
  tab2obj#  number not null,			       /* table 2 obj number */
  tab2col#  number not null,	       /* internal column number for table 2 */
  joinop    number not null,	       /* Op code as defined in opndef.h (=) */
  flags     number,					       /* misc flags */
  tab1inst# number default 0,	  /* instance of table 1 (for multiple refs) */
  tab2inst# number default 0	  /* instance of table 2 (for multiple refs) */
)
/
create index i_jijoin$ on jijoin$(obj#)
/
create index i2_jijoin$ on jijoin$(tab1obj#,tab1col#)
/
create index i3_jijoin$ on jijoin$(tab2obj#,tab2col#)
/
rem join index refresh sql statements
create table jirefreshsql$
(
  iobj#     number not null,				  /* join index obj# */
  tobj#     number not null,				  /* base table obj# */
  sqltext   clob       /* sql to refresh iobj# when tobj# is modified by DML */
)
/
create unique index i1_jirefreshsql$ on jirefreshsql$(iobj#, tobj#)
/
create index i2_jirefreshsql$ on jirefreshsql$(tobj#)
/
create table log$
(
  btable#    number not null,                        /* base table object id */
  colname    varchar2(30) not null,                   /* logging column name */
  refcount   number not null,                        /* number of references */
  ltable#    number not null                      /* logging table object id */
)
/
create sequence log$sequence   /* sequence for logging table name generation */
  increment by 1
  start with 1
  minvalue 0
  nomaxvalue
  cache 10
  order
  nocycle
/


Rem =========================================================================
Rem END join index changes
Rem =========================================================================


Rem=========================================================================
Rem  BEGIN View Constraint Changes (moved fron 8.1.7 script)
Rem=========================================================================

create table viewcon$                          /* constraint text for view */
( obj#            number not null,                   /* view object number */
  con#            number,                             /* constraint number */
  conname         varchar2(30),                         /* constraint name */
  type#           number,                               /* constraint type */
                            /* 2 = primary key, 3 = unique, 4= referential */
  con_text        clob,                                 /* constraint text */
  robj#           number,                      /* referenced object number */
  property        number                       /* view constraint property */
                                                 /* 0x00040000 set RELY on */
                                               /* 0x00080000 /* Reset RELY */
)
/

create index i_viewcon1 on viewcon$(obj#)
/

create index i_viewcon2 on viewcon$(robj#)
/

Rem=========================================================================
Rem  END View Constraint changes
Rem=========================================================================


Rem  defsubpart$ stores information on subpartition templates

create table defsubpart$ (
bo#            number not null,       /* Object number of table */
spart_position number,                /* subpartition position */
spart_name     varchar2(34) not null, /* name assigned by user */
ts#            number,                /* Default tablespace NULL if none */
flags          number,                
hiboundlen     number not null,      /* high bound text of this subpartition */
hiboundval     long,                 /* length of the text */  
bhiboundval    blob)                 /* binary form of high bound */
/
create index i_defsubpart$ on defsubpart$(bo#, spart_position)
/
rem
rem defsubpartlob$ stores information on lob subpartition templates
rem
create table defsubpartlob$ (
bo#            number not null,      /* object number of table */
intcol#        number not null,      /* column number of lob column */
spart_position number not null,      /* subpartition position */
flags          number,               /* Type of lob column */
                                     /* 0x01 varray */
                                     /* 0x02 opaque */
lob_spart_name varchar2(34) not null, /* segment name for lob subpartition */
lob_spart_ts#  number)                /* tablespace (if any) assigned */
/
create index i_defsubpartlob$ on defsubpartlob$ (bo#, intcol#, spart_position)
/

Rem =========================================================================
Rem Add columns for attribute synonyms
Rem =========================================================================

alter table coltype$ add (synobj# number)
/

alter table collection$ add (synobj# number)
/

alter table attribute$ add (synobj# number)
/

alter table parameter$ add (synobj# number)
/

alter table result$ add (synobj# number)
/

alter table subcoltype$ add (synobj# number)
/

Rem ===========================================
Rem add drop_segments column to mon_mods$ table
Rem See comments in sql.bsq
Rem if the column is already existed, just ignore the ORA-01430
Rem ===========================================
alter table sys.mon_mods$ add
(
   drop_segments number default 0
)
/

Rem ================================================================
Rem Remove entries (some now JAVA) from sys.duc$ 
Rem       (allow DROP user to work during upgrade and catproc)
Rem ================================================================

delete from duc$;

Rem ================================================================
Rem END remove entries from sys.duc$ 
Rem ================================================================

Rem ================================================================
Rem Streams tables
Rem ================================================================

create table streams$_prepare_object
(
  obj#            number  not null,
  ignore_scn      number  not null,
  timestamp       date,
  spare1          number
)
/
create unique index i_streams_prepare1 on streams$_prepare_object (obj#)
/

rem streams$_prepare_ddl is for DDL support.
rem DDL looks up this table to see if a schema or database
rem is prepared for instantiation
create table streams$_prepare_ddl
(
  global_flag number not null,            /* 1 if usrid is null, 0 otherwise */
  usrid       number,             /* user id (NULL for database instantiate) */
  scn         number,                       /* ignore scn (currently unused) */
  timestamp   date,                   /* time at which schema was registered */
  spare1      number
)
/
create unique index i_streams_prepare_ddl on
  streams$_prepare_ddl(global_flag, usrid)
/

rem subscriptions of source objects
create table apply$_source_obj
(
  id             number              not null,                 /* sequence # */
  owner          varchar2(30      )  not null,        /* source object owner */
  name           varchar2(30      )  not null,         /* source object name */
  type           number              not null,         /* source object type */
  source_db_name varchar2(128     )  not null,       /* source database name */
  dblink         varchar2(128     ),   /* database link for HS instantiation */
  inst_scn       number,                                /* instantiation scn */
  ignore_scn     number,     /* scn used to determine LCR selection by apply */
  spare1         number
)
/
create unique index i_apply_source_obj1 on
  apply$_source_obj (id)
/
create unique index i_apply_source_obj2 on
  apply$_source_obj (owner, name, type, source_db_name, dblink)
/
rem sequence for apply$_source_obj.id
create sequence apply$_source_obj_id nocache
/

rem source schema instantiation scns
rem a NULL name means a global inst_scn
create table apply$_source_schema
(
  source_db_name varchar2(128     ) not null,        /* source database name */
  global_flag    number             not null,   /* 1 if name is null, else 0 */
  name           varchar2(30      ),                   /* source schema name */
  dblink         varchar2(128     ),   /* database link for HS instantiation */
  inst_scn       number,                                /* instantiation scn */
  spare1         number
)
/
create unique index i_apply_source_schema1 on
  apply$_source_schema (source_db_name, global_flag, name, dblink)
/

Rem ================================================================
Rem END: Streams tables
Rem ================================================================

Rem =========================================================================
Rem END STAGE 1: load 9.2.0 specific tables
Rem =========================================================================

Rem =========================================================================
Rem BEGIN STAGE 2: invoke script for subsequent version 
Rem =========================================================================

@@i0902000

Rem =========================================================================
Rem END STAGE 2: invoke script for subsequent version 
Rem =========================================================================

Rem ==========================================================================
Rem Delete dependencies on x$ioa_fm,x$kjmsq,x$kllcnt, x$klltab, x$ksmsp_nwext
Rem x$ksxtmpt from dependency$
Rem==========================================================================

delete from dependency$ where p_obj# in ( '4294951780','4294951695',
                                          '4294950968','4294950969',
                                          '4294951768','4294951505');
commit;
alter system flush shared_pool;
Rem *************************************************************************
Rem END i0900010.sql
Rem *************************************************************************
