Rem
Rem $Header: i0801070.sql 05-feb-2004.07:33:43 rburns Exp $
Rem
Rem i0801070.sql
Rem
Rem Copyright (c) 1999, 2004, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      i0801070.sql - load 9.0.1 specific tables that are need to
Rem                     process basic sql statements
Rem
Rem    DESCRIPTION
Rem      This script MUST be one of the first things called from the 
Rem      one path upgrade scripts (ie - u0703040.sql, u0800050.sql, ...)
Rem
Rem      Only put statements in here that must be run in order
Rem      to process basic sql commands.  For example, in order to 
Rem      drop a package, the code depends on the tables below.
Rem      If these tables do not exist, we get a recursive sql error
Rem      causing the command to be aborted.
Rem
Rem      The upgrade is performed in the following stages:
Rem        STAGE 1: load 9.0.1 specific tables 
Rem        STAGE 2: invoke script for subsequent version
Rem
Rem    NOTES
Rem      * This script must be run using SQL*PLUS.
Rem      * You must be connected AS SYSDBA to run this script.
Rem 
Rem    MODIFIED   (MM/DD/YY)
Rem    rburns      02/05/04 - move CDC inserts to c0801070.sql 
Rem    arithikr    10/24/03 - 3126930 - add drop_segments column to mon_mods 
Rem    kesriniv    08/19/03 - fix hard tabs 
Rem    kesriniv    08/18/03 - 2856745: prevent duplicate rows in props$ 
Rem    ssubrama    06/10/02 - bug 2385207 move delete from dependency$
Rem    arithikr    05/31/02 - 2384233: truncate table cdc_system$ 
Rem    vmarwah     10/18/01 - LOB Retention compatibility reorg.
Rem    rburns      10/08/01 - move delete from duc$
Rem    rburns      06/04/01 - add 9.0.1 upgrade, move UPDATEs to c0801070.sql
Rem    narora      04/18/01 - add index on ntab$(ntab#)
Rem    mkrishna    04/18/01 - fix bug 1743345 in upgrading opaque types
Rem    wnorcott    02/14/01 - add type, version fields to cdc_change_tables$..
Rem    rburns      02/07/01 - move update trigger$ back to c08000050.sql
Rem    rburns      01/22/01 - include trigger alters from i0800050.sql.
Rem    rburns      01/04/01 - delete from duc$ table before upgrade
Rem    bemeng      12/11/00 - change object_stats to object_usage
Rem    rburns      12/04/00 - add audit rows to procedure$
Rem    rburns      11/22/00 - move cdc and viewcon$ to i0801070.sql
Rem    bemeng      09/20/00 - insert default temp tablespace name into props$
Rem    rburns      10/04/00 - changes required by migrate
Rem    rburns      09/12/00 - move partition columns to c0801070.sql
Rem    rburns      09/08/00 - remove tab_ovf creation
Rem    rburns      08/17/00 - add left out tables and columns
Rem    araghava    08/24/00 - Update spare1 (charsetid), charsetform in  
Rem                           partcol$, subpartcol$.
Rem    jdavison    07/31/00 - Miscellaneous script cleanup.
Rem    rburns      07/31/00 - put table creations/additions into i0801070.sql
Rem    kosinski    06/14/00 - Persistent parameters
Rem    jdavison    04/11/00 - Modify usage notes for 9.0 changes.
Rem    rshaikh     09/14/99 - Created
Rem

Rem =========================================================================
Rem BEGIN STAGE 1: load 9.0.1 specific tables
Rem =========================================================================

Rem Make sure this is loaded before standard.sql is called or else
Rem we will get a recursive sql error while loading standard.sql

REM ================================================================
REM Persistent parameter settings
REM ================================================================
 
create table settings$ (
  obj#          number not null,                            /* object number */
  param         varchar2(30) not null,                     /* parameter name */
  value         varchar2(4000))                           /* parameter value */
/

create index i_settings1 on settings$(obj#)
/

Rem ================================================================
Rem BEGIN  Identifying Unused Indexes Upgrade 
Rem (required for DROP object)      
Rem ================================================================

create table object_usage                         /* object usage statistics */
( obj#               number not null,   /* object number of monitored object */
  flags              number not null,                       /* various flags */
                           /* index accessed during monitoring period : 0x01 */
  start_monitoring   char(19),                      /* start monitoring time */
  end_monitoring     char(19)                         /* end monitoring time */
)
/

create index i_stats_obj# on object_usage(obj#)
/

Rem ================================================================
Rem END Identifying Unused Indexes Upgrade 
Rem ================================================================

Rem ================================================================
Rem BEGIN Inheritance related changes 
Rem (required for ALTER statements)
Rem ================================================================

create table superobj$           /* stores info about table/view hierarchies */
( subobj#         number not null,            /* object number of sub object */
  superobj#       number not null)          /* object number of super object */
/

create unique index i_superobj1 on superobj$(subobj#)
/
create index i_superobj2 on superobj$(superobj#)
/

create table subcoltype$
( obj#          number not null,             /* object number of base object */
  intcol#       number not null,                   /* internal column number */
  toid          raw(16) not null,                   /* column's ADT type OID */
  version#      number not null,             /* internal type version number */
  intcols       number,                        /* number of internal columns */
                                          /* storing the exploded ADT column */
  intcol#s      raw(2000),        /* list of intcol#s of columns storing */
                          /* the unpacked ADT column; stored in packed form; */
                                          /* each intcol# is stored as a ub2 */
  flags         number)
cluster c_obj#(obj#)
/
create index i_subcoltype1 on subcoltype$(obj#, intcol#)
/

Rem ================================================================
Rem END Inheritance related changes
Rem ================================================================

REM ================================================================
REM BEGIN OF SQLJ tables upgrade 
REM ================================================================

create table procedureinfo$               /* function/procedure/method table */
( obj#          number not null,                            /* object number */
  procedure#    number not null,               /* procedure or method number */
  overload#      number not null,
  procedurename varchar2(30),                        /* procedure name */
  properties    number not null,                     /* procedure properties */
  itypeobj#     number,                 /* implementation type object number */
  spare1        number,
  spare2        number,
  spare3        number,
  spare4        number
)
/
create unique index i_procedureinfo1 on
  procedureinfo$(obj#, procedurename, overload#)
/

ALTER TABLE argument$
add
(
  procedure#     number,                       /* procedure or method number */
  properties     number                            /* argument's properties: */
)
/

create index i_argument2 on
  argument$(obj#, procedure#, sequence#)
  storage (initial 10k next 100k maxextents unlimited pctincrease 0)
/

create table procedurec$
( obj#          number not null,                 /* spec/body object number */
  procedure#    number not null,                  /* procedure# or position */
  entrypoint#   number not null)                 /* entrypoint table entry# */
/
create unique index i_procedurec$ on procedurec$ (obj#, procedure#)
/

create table procedurejava$
( obj#          number not null,                 /* spec/body object number */
  procedure#    number not null,                  /* procedure# or position */
  ownername     varchar2(30) not null,                  /* class owner name */
  ownerlength   number not null,              /* length of class owner name */
  usersignature varchar2(4000),                  /* User signature for java */
  usersiglen    number,                /* Length of user signature for java */
  classname     varchar2(4000) not null,               /* method class name */
  classlength   number not null,             /* length of method class name */
  methodname    varchar2(4000) not null,                /* java method name */
  methodlength  number not null,              /* length of java method name */
  signature     long not null,                        /* internal signature */
  siglength     number not null,            /* length of internal signature */
  flags         varchar2(4000) not null,                  /* internal flags */
  flagslength   number not null,                /* length of internal flags */
  cookiesize    number)                                      /* cookie size */
/
create unique index i_procedurejava$ on procedurejava$ (obj#, procedure#)
/

create table vtable$                                               /* vtable */
(
  obj#          number not null,               /* object number of type spec */
  vindex        number not null,                             /* vtable index */
  itypetoid     raw(16),                         /* implementation type toid */
  itypeowner    varchar2(30),         /* owner name component of implem type */
  itypename     varchar2(30),                            /* implem type name */
  imethod#      number not null,           /* method# in implementation type */
  iflags        number)                              /* implementation flags */
/

rem create unique index i_vtable1 on vtable$(obj#, vindex)
rem /

ALTER TABLE type$
add
(
  externtype    number,                                     /* external type */
  externname    varchar2(4000),      /* java class implementing the type */
  hiddenMethods number,                                 /* number of methods */
  helperclassname varchar2(4000)        /* Generated helper class (SQLJ) */
)
/
ALTER TABLE type$
modify
( 
  externname    varchar2(4000),               /* migrated from 7.3.4 at 2000 */
  helperclassname varchar2(4000)
)
/
ALTER TABLE attribute$
add
(
  externname    varchar2(4000),    /* field in java class for SQLJ types */
  setter        number,                                       /* Setter SQLJ */
  getter        number                                       /* Getter SQLJ */
)
/

ALTER TABLE attribute$ 
modify
(
  externname    varchar2(4000)                /* migrated from 7.3.4 at 2000 */
)
/

ALTER TABLE method$
add
(
  externVarName varchar2(4000)        /* external variable name for SQLJ */
)
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

REM ================================================================
REM END OF SQLJ tables upgrade
REM ================================================================

Rem ================================================================
Rem BEGIN add new column to partobj$ (required for DROP statements)
Rem ================================================================

alter table partobj$ add (parameters  varchar2(1000))
/
Rem ================================================================
Rem END add new column to partobj$ (required for DROP statements)
Rem ================================================================

Rem ================================================================
Rem BEGIN OF Opaque type related changes
Rem ================================================================

/* The opqtype$ stores extra information for the xmltype */
create table opqtype$                         /* extra info for opaque types */
(
  obj#        number not null,                /* object number of base table */
  intcol#     number not null,                     /* internal column number */
  type        number,                              /* The opaque type - type */
                                                           /* 0x01 - XMLType */
  flags       number,                           /* flags for the opaque type */
                              /* -------------- XMLType flags ---------
                               * 0x0001 (1) -- XMLType stored as lob
                               * 0x0002 (2) -- XMLType stored as object
                               * 0x0004 (4) -- XMLType schema is specified
                               * 0x0008 (8) -- XMLType stores extra column
                               */
  /* Flags for XMLType (type == 0x01). Override them when necessary  */
  lobcol      number,                                          /* lob column */
  objcol      number,                                      /* obj rel column */
  extracol    number,                                      /* extra info col */
  schemaoid   raw(16),                                     /* schema oid col */
  elemnum     number,                                      /* element number */
  schemaurl   varchar2(4000)                       /* The name of the schema */
)
cluster c_obj#(obj#)
/
create unique index i_opqtype1 on opqtype$(obj#, intcol#)
/

Rem ================================================================
Rem END OF Opaque type related changes
Rem ================================================================


REM ================================================================
REM BEGIN of Default Temporary Tablespace Upgrade 
REM ================================================================

Rem insert default temp tablespace name into props$
Rem which is 'SYSTEM'

delete from props$ where name = 'DEFAULT_TEMP_TABLESPACE';
insert into props$
values('DEFAULT_TEMP_TABLESPACE', 'SYSTEM',
       'ID of default temporary tablespace');
commit
/

REM ================================================================
REM END of Default Temporary Tablespace Upgrade 
REM ================================================================


Rem=========================================================================
Rem  BEGIN Change Data Capture upgrade
Rem=========================================================================

create table cdc_system$          /* things that apply to all change sources */
(
  major_version      number         not null,       /* i.e. release 1 of CDC */
  minor_version      number         not null     /* maintenance level i.e. 0 */
)
/
truncate table cdc_system$
/
insert into cdc_system$ (major_version, minor_version) values(1,0)
/
create table cdc_change_sources$              /* origin of change stream     */
(                                             /* a collection of change sets */
  source_name        varchar2(30) not null,       /* user specified          */
  dbid               number,                      /* Oracle DBID of origin   */
  logfile_location   varchar2(4000) not null,     /* redo log directory      */
  logfile_suffix     varchar2(30),                /* "log", etc.             */
  source_description varchar2(255),               /* user comment            */
  created            date           not null      /* when row inserted       */
)
/
create unique index i_cdc_change_sources$ on cdc_change_sources$(source_name)
/

create table cdc_change_sets$              /* a collection of change tables  */
(
  set_name           varchar2(30)   not null,     /* user specified          */
  change_source_name varchar2(30)   not null,     /* parent                  */
  begin_date         date,       /* starting point for capturing change data */
  end_date           date,        /* stoping point for capturing change data */
  begin_scn          number,     /* starting point for capturing change data */
  end_scn            number,      /* stoping point for capturing change data */
  freshness_date     date,     /* stopping point for last successful advance */
  freshness_scn      number,   /* stopping point for last successful advance */
  advance_enabled    char(1)        not null,/* Y or N - eligible for advance*/
  ignore_ddl         char(1)        not null,  /* Y or N - continue vs. stop */
  created            date           not null,     /* when row inserted       */
  rollback_segment_name varchar2(30),   /* for use during advance - optional */
  advancing          char(1)        not null,/* Y or N - being advanced now? */
  purging            char(1)        not null,  /* Y or N - being purged now? */
  lowest_scn         number         not null,          /* LWM of change data */
  tablespace         varchar2(30)   not null,     /* for advance LCR staging */
  lm_session_id      number,          /* for LogMiner session during advance */
  partial_tx_detected char(1),    /* advance detected partial transaction(s) */
  last_advance       date,                     /* when set was last advanced */
  last_purge         date                        /* when set was last purged */
)
/
create unique index i_cdc_change_sets$ on cdc_change_sets$(set_name)
/

create table cdc_change_tables$           /* information about change tables */
(
  obj#                number        not null,    /* object # of change table */
  change_set_name     varchar2(30)  not null,                      /* parent */
  source_schema_name  varchar2(30)  not null,/* table owner in source system */
  source_table_name   varchar2(30)  not null,  /* corresponding source table */
  change_table_schema varchar2(30)  not null,/* needed for DROP_CHANGE_TABLE */
  change_table_name   varchar2(30)  not null,/* needed for DROP_CHANGE_TABLE */
  created             date          not null,           /* when row inserted */
  created_scn         number,  /* system commit scn of this table's creation */
  mvl_flag            number,                    /* for MV Log compatability */
  captured_values     char(1)       not null,     /* Old values, New or Both */
  mvl_temp_log        varchar2(30),         /* MV Log temp. update. log name */
  mvl_v7trigger       varchar2(30),                     /* MV Log V7 trigger */
  last_altered        date,       /* last successful ALTER_CHANGE_TABLE date */
  lowest_scn          number        not null,  /* LWM for this table (PURGE) */
  mvl_oldest_rid      number,                     /* MV Log oldest rowid scn */
  mvl_oldest_pk       number,               /* MV Log oldest primary key scn */
  mvl_oldest_oid      number,                 /* MV Log oldest object id scn */
  mvl_oldest_new      number,                 /* MV Log oldest new value scn */
  mvl_oldest_rid_time date,                      /* MV Log oldest rowid time */
  mvl_oldest_pk_time  date,                /* MV Log oldest primary key time */
  mvl_oldest_oid_time date,                  /* MV Log oldest object id time */
  mvl_oldest_new_time date,                  /* MV Log oldest new value time */
  mvl_backcompat_view varchar2(30),        /* MV Log back. compat. view name */
  mvl_physmvl             varchar2(30),                   /* physical mv log */
  highest_scn         NUMBER,                  /* high water mark scn for ct */
  highest_timestamp   date              /* time of last extend_window[_list] */
)
/
alter table cdc_change_tables$ 
add 
(
  change_table_type  number         not null, /* type of change table:       */
                                              /* 1 MV log style synchronous  */
                                              /* 2 asynchronous              */
                                              /* 3 improved synchronous      */
  major_version      number         not null,       /* i.e. release 1 of CDC */
  minor_version      number         not null     /* maintenance level i.e. 0 */
)
/
create unique index i_cdc_change_tables$ on cdc_change_tables$(obj#)
/
create table cdc_subscribers$                /* subscriptions to change data */
(
  handle             number         not null,         /* subscription handle */
  set_name           varchar2(30)   not null,       /* change set identifier */
  username           varchar2(30)   not null,               /* of subscriber */
  created            date           not null,           /* when row inserted */
  status             char(1)        not null,  /* Not active (yet) or Active */
  earliest_scn       number         not null,   /* starting point for window */
  latest_scn         number         not null,     /* ending point for window */
  description        varchar2(30),                       /* for user comment */
  last_purged        date,             /* last time user called PURGE_WINDOW */
  last_extended      DATE,              /* time of last extend_window[_list] */
  mvl_invalid        char(1)           /* subscription invalid,  'Y'         */
                                       /* or 'N', used only by MV refresh    */
)    
/
create unique index i_cdc_subscribers$ on cdc_subscribers$(handle)
/  
create table cdc_subscribed_tables$               /* tables of subscriptions */
(
  handle             number not null,                 /* subscription handle */
  change_table_obj#  number not null,    /* subscribed change table object # */
  view_name          varchar2(30),                    /* generated view name */
  view_status        char(1)        not null,          /* Created or Dropped */
  mv_flag            number,                  /*  types of info. mv requires */
  mv_colvec          raw(128)           /* bit vector of columns mv requires */
)
/
create unique index i_cdc_subscribed_tables$ on  cdc_subscribed_tables$(handle, change_table_obj#)
/
create table cdc_subscribed_columns$         /* columns of subscribed tables */
(
  handle             number not null,                 /* subscription handle */
  change_table_obj#  number not null,    /* subscribed change table object # */
  column_name        varchar2(30) not null /* source table column identifier */
)
/
create unique index i_cdc_subscribed_columns$ on cdc_subscribed_columns$(handle, change_table_obj#, column_name)
/
create sequence cdc_subscribe_seq$     /* CDC subscription handle allocation */
  start with 1
  increment by 1
  nomaxvalue
  minvalue 1
  nocycle
  cache 20
  noorder
/
create table cdc_change_columns$   /* track when columns added to tables */
(
  change_table_obj#  number not null,    /* subscribed change table object # */
  column_name        varchar2(30) not null,             /* column identifier */
  created            date           not null,           /* when row inserted */
  created_scn        number         not null /* scn of this columns creation */
)
/
create unique index i_cdc_change_columns$  on cdc_change_columns$(change_table_obj#, column_name)
/
create sequence cdc_rsid_seq$   /* CDC row sequence ids for sync capture */
  start with 1
  increment by 1
  nomaxvalue
  minvalue 1
  nocycle
  cache 10000
  order
/
Rem ================================================================
Rem END Change Data Capture upgrade
Rem ================================================================

Rem ================================================================
Rem BEGIN add new column to argument$ (required for recompile)
Rem ================================================================

Rem Moved from i0801050.sql to avoid ALTER errors.
Rem Column will already exist for 8.1.6 & 8.1.7 upgrades.
Rem Bug 822440: Add PLS_TYPE to ARGUMENT$

alter table argument$ add (
  pls_type          varchar2(30)                       /* pl/sql type name */
)
/

Rem ================================================================
Rem END add new column to argument$ (required for recompile)
Rem ================================================================

Rem ================================================================
Rem BEGIN i0800050.sql trigger$ changes (for utlip execution)
Rem       must be at end of this script, since ALTER TABLE used.
Rem ================================================================

alter table trigger$ add
(
  sys_evts      number,                                    /* system events */
  nttrigcol     number,               /* intcol# on which trigger is defined */
  refprtname    varchar2(30)               /* PARENT referencing name */
)
/
alter table trigger$ add (nttrigatt     number)
/

Rem ================================================================
Rem END i0800050.sql trigger$ changes (for utlip execution)
Rem ================================================================

Rem ================================================================
Rem BEGIN add i0800050.sql dependencies (for utlip DROP TABLE)
Rem ================================================================

alter table refcon$ add (
  expctoid      raw(16) /* TOID of exploded columns when ref is user-defined */
)
/

alter table sys.hist_head$
add
(
  avgcln          number,                           /* average column length */
  spare3          number,                                           /* spare */
  spare4          number                                            /* spare */
)
/

Rem ================================================================
Rem END add i0800050.sql dependencies (for utlip DROP TABLE)
Rem ================================================================

Rem ================================================================
Rem BEGIN add index on nttab$(ntab#) to improve performance
Rem ================================================================
create index i_ntab3 on ntab$(ntab#)
/

Rem ================================================================
Rem END add index on nttab$(ntab#) to improve performance
Rem ================================================================

Rem =========================================================================
Rem END STAGE 1: load 9.0.1 specific tables
Rem =========================================================================

Rem =========================================================================
Rem BEGIN STAGE 2: invoke script for subsequent version 
Rem =========================================================================

@@i0900010

Rem =========================================================================
Rem END STAGE 2: invoke script for subsequent version 
Rem =========================================================================

Rem=========================================================================
Rem Delete dependencies for x$kcbbmc x$kcluh, x$kclui and x$traces from
Rem dependency$.
Rem=========================================================================

delete from dependency$ where p_obj# in ( '4294951027', '4294951249',
                                          '4294951250', '4294951003');
commit;
alter system flush shared_pool;

Rem *************************************************************************
Rem END i0801070.sql
Rem *************************************************************************
