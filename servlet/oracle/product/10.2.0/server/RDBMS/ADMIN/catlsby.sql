Rem
Rem $Header: catlsby.sql 06-sep-2005.16:02:23 dvoss Exp $
Rem
Rem catlsby.sql
Rem
Rem Copyright (c) 2000, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catlsby.sql - Logical Standby tables and views
Rem
Rem    DESCRIPTION
Rem      This file implements the following:
Rem      Tables:
Rem         logstdby$parameters
Rem         logstdby$events
Rem         logstdby$apply_progress
Rem         logstdby$apply_milestone
Rem         logstdby$event_options
Rem         logstdby$scn
Rem         logstdby$skip_transaction
Rem         logstdby$skip
Rem         logstdby$skip_support
Rem
Rem    NOTES
Rem      Must be run when connected to SYS or INTERNAL
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    dvoss       08/31/05 - add entries in sys.noexp$ 
Rem    sslim       05/26/05 - Reveal corruption state in dba_logstdby_log 
Rem    rmacnico    05/19/05 - Update skip_support categories
Rem    jmzhang     03/23/05 - change default ts for parameter table
Rem    jmzhang     03/29/05 - update dba_logstdby_unsupported
Rem    jmzhang     08/26/04 - remove logstdby_status
Rem                         - remove logstdby_thread
Rem    jmzhang     08/17/04 - add logstdby_status
Rem                           add logstdby_thread
Rem    clei        06/10/04 - disallow encrypted columns
Rem    ajadams     06/15/04 - add index to logstdby events table 
Rem    rgupta      04/23/04 - create tables in SYSAUX tablespace
Rem    ajadams     05/13/04 - add logstdby_transaction 
Rem    jmzhang     05/05/04 - add timestamp to apply_milestone
Rem    jnesheiw    03/11/04 - fix LOGSTDBY_PROGRESS view to show correct 
Rem                           thread# for RAC 
Rem    mcusson     01/15/04 - LogMiner 10g IOT support 
Rem    jnesheiw    12/18/03 - Re-enable partition check 
Rem    raguzman    11/12/03 - use dba_server_registry not dba_registry 
Rem    raguzman    10/29/03 - add list of schema names to skip 
Rem    raguzman    09/24/03 - fix bit check for table_compression
Rem    jmzhang     09/11/03 - fix newest_scn in dba_logstdby_progress
Rem    raguzman    08/28/03 - add column to logstdby_support to support new
Rem                           view logstdby_unsupported_tables for GUI
Rem    jnesheiw    08/28/03 - DBA_LOGSTDBY_PARAMETERS only displays type < 2 
Rem    jmzhang     07/28/03 - fix logstdby_support by adding s.ts#
Rem    gkulkarn    07/09/03 - IOT with mapping table is supported
Rem    jnesheiw    05/19/03 - increase objname size in logstdby$scn
Rem    raguzman    05/27/03 - support view are missing object tables
Rem    raguzman    05/31/03 - real time apply and views
Rem    smangala    05/05/03 - fix bug#2691312: ignore gaps for newest_scn
Rem    narora      03/19/03 - bug 2842797: default value of fetchlwm_scn
Rem    narora      01/13/03 - add fetchlwm_scn to apply_milestone
Rem    raguzman    12/19/02 - add logstdby_support internal use view
Rem    sslim       12/02/02 - lrg 1112873: should not drop tables
Rem    raguzman    11/18/02 - Simply supported queries
Rem    rguzman     07/19/02 - update views for data type support
Rem    rguzman     07/19/02 - do not drop tables, needed for upgrades
Rem    rguzman     10/25/02 - Fix PARAMETERS view and UNSUPPORTED attributes
Rem    jmzhang     10/10/02 - modify the comments of logstdby$parameters 
Rem    rguzman     10/11/02 - Attributes column for DBA_LOGSTDBY_UNSUPPORTED
Rem    jmzhang     09/23/02 - Update system.logstdby$scn
Rem    rguzman     07/07/02 - DBA_LOGSTDBY_PROGRESS must work on RAC
Rem    rguzman     10/01/02 - skip using like feature
Rem    sslim       09/26/02 - Log Stream History Table
Rem    jmzhang     08/12/02 - UPdate DBA_LOGSTDBY_PROGRESS
Rem    jmzhang     08/12/02 - Update DBA_LOGSTDBY_LOG
Rem    gviswana    01/29/02 - CREATE OR REPLACE SYNONYM
Rem    narora      01/17/02 - milestone.spare1 = oldest scn,
Rem                         - spare2=primary syncpoint scn
Rem    rguzman     01/24/02 - Modify UNSUPPORTED view, no ADTs
Rem    cfreiwal    11/14/01 - move logstby views to catlsby.sql
Rem    rguzman     10/12/01 - New columns for logstdby$paramters.
Rem    narora      09/21/01 - remove logstdby_coordinator/slave
Rem    dcassine    08/27/01 - 
Rem    rguzman     09/12/01 - PROGRESS view to report better progress
Rem    dcassine    08/27/01 - LOGSTDBY$APPLY_MILESTONE.PROCESSED_SCN
Rem    jnesheiw    08/02/01 - skip_transaction spare1 name change.
Rem    rguzman     05/18/01 - Fix skip default.
Rem    rguzman     05/17/01 - No Long/Lob support for Alpha kit.
Rem    sslim       05/11/01 - Drop tables before creating them
Rem    jdavison    10/12/00 - Change varchar sizes to 2000.
Rem    narora      08/01/00 - make apply progress a partitioned table
Rem    rguzman     08/11/00 - Views: synonyms, snapshot logs & functional index
Rem    narora      06/20/00 - grant select on v$logstdby_coordinator, 
Rem                         - v$logstdby_apply
Rem    rguzman     05/26/00 - Add views
Rem    rguzman     04/11/00 - Created
Rem

-- This is needed so that SYS can later grant select_catalog to the views.
grant select any table to sys with admin option
/

create table system.logstdby$parameters (
  name            varchar2(30),                 /* The name of the parameter */
  value           varchar2(2000),              /* The value of the parameter */
  type            number,  /* null = internal, 1 = persistent, 2 = sessional */
  scn             number,                          /* null or meaningful scn */
  spare1          number,                                /* Future expansion */
  spare2          number,                                /* Future expansion */
  spare3          varchar2(2000)                         /* Future expansion */
) tablespace SYSTEM
/

create table system.logstdby$events (
  event_time      timestamp,           /* The timetamp the event took effect */
  current_scn     number,            /* The change vector SCN for the change */
  commit_scn      number,     /* SCN of commit record for failed transaction */
  xidusn          number,      /* Trans id component of a failed transaction */
  xidslt          number,      /* Trans id component of a failed transaction */
  xidsqn          number,      /* Trans id component of a failed transaction */
  errval          number,                                    /* Error number */
  event           varchar2(2000),      /* first 2000 characters of statement */
  full_event      clob,                            /* The complete statement */
  error           varchar2(2000),      /* error text associated with failure */
  spare1          number,                                /* Future expansion */
  spare2          number,                                /* Future expansion */
  spare3          varchar2(2000)                                 /* Future expansion */
) LOB (full_event) STORE AS (TABLESPACE SYSAUX CACHE PCTVERSION 0
                             CHUNK 16k STORAGE (INITIAL 16K NEXT 16K))
TABLESPACE SYSAUX LOGGING 
/

create index system.logstdby$events_ind
      on system.logstdby$events (event_time asc) tablespace SYSAUX;

-- Turns off partition check --
alter session set events  '14524 trace name context forever, level 1';

create table system.logstdby$apply_progress (
  xidusn          number,    /* Trans id component of an applied transaction */
  xidslt          number,    /* Trans id component of an applied transaction */
  xidsqn          number,    /* Trans id component of an applied transaction */
  commit_scn      number,    /* SCN of commit record for applied transaction */
  commit_time     date,     /* The timestamp corresponding to the commit scn */
  spare1          number,                                /* Future expansion */
  spare2          number,                                /* Future expansion */
  spare3          varchar2(2000)                                 /* Future expansion */
) tablespace SYSAUX 
partition by range (commit_scn) (partition P0 values less than (0))
/

-- Turns on partition check --
alter session set events  '14524 trace name context off';

create table system.logstdby$apply_milestone (
  session_id      number not null,                   /* Log miner session id */
  commit_scn      number not null,                         /* low-water mark */
  commit_time     date,                                /* low-water mark time*/
  synch_scn       number not null,                       /* Synch-point SCN. */
  epoch           number not null,    /* Incarnation number for apply engine */
  processed_scn   number not null, /* all comp txn<processed_scn are applied */
  processed_time  date,             /*timestamp corresponding to process_scn */
  fetchlwm_scn    number default(0) not null,    /* maximum SCN ever fetched */
  spare1          number,                                /* oldest_scn       */
  spare2          number,                           /* primary syncpoint scn */
  spare3          varchar2(2000)                         /* Future expansion */
) tablespace SYSAUX
/

Rem   Logical Instantiation, beginning scn for each table.
create table system.logstdby$scn (
  obj#      number,
  objname   varchar2(4000),
  schema    varchar2(30),
  type      varchar2(20),
  scn       number,
  spare1          number,                                /* Future expansion */
  spare2          number,                                /* Future expansion */
  spare3          varchar2(2000)                         /* Future expansion */
) tablespace SYSAUX
/

create table system.logstdby$plsql (
  session_id      number,               /* Id of session issuing the command */
  start_finish    number,        /* Boolean, 0 = 1st record, 1 = last record */
  call_text       clob,                   /* Text of call to pl/sql routine. */
  spare1          number,                                /* Future expansion */
  spare2          number,                                /* Future expansion */
  spare3          varchar2(2000)                         /* Future expansion */
) tablespace SYSAUX
/

create table system.logstdby$skip_transaction (
  xidusn          number,    /* Trans id component of an applied transaction */
  xidslt          number,    /* Trans id component of an applied transaction */
  xidsqn          number,    /* Trans id component of an applied transaction */
  active          number,           /* Boolean to indicate current or active */
  commit_scn      number,                    /* SCN at which tx commited at  */
  spare2          number,                                /* Future expansion */
  spare3          varchar2(2000)                         /* Future expansion */
) tablespace SYSAUX
/

create table system.logstdby$skip (
  error           number,            /* Should statement or error be skipped */
  statement_opt   varchar2(30), /* name from audit_actions or logstdby$skip_support */
  schema          varchar2(30),      /* schema name for object being skipped */
  name            varchar2(30),              /* name of object being skipped */
  use_like        number, /* 0 = exact match, 1 = like, 2 = like with escape */
  esc             varchar2(1),             /* Escape character if using like */
  proc            varchar2(98),      /* schema.package.proc to call for skip */
  active          number,           /* Boolean to indicate current or active */
  spare1          number,                                /* Future expansion */
  spare2          number,                                /* Future expansion */
  spare3          varchar2(2000)                         /* Future expansion */
) tablespace SYSAUX
/

Rem   Statement auditting options for objects encoded here for skip support
Rem   It is ok to drop this table, contains only these rows ever
drop table system.logstdby$skip_support
/
create table system.logstdby$skip_support (
  action          number not null,    /* number as seen in sys.audit_actions */
                   /* reserving actions 0 & -1 for internal skip schema list */
  name            varchar2(30) not null,         /* action to skip or schema */
  spare1          number,                                /* Future expansion */
  spare2          number,                                /* Future expansion */
  spare3          varchar2(2000)                         /* Future expansion */
) tablespace SYSAUX
/

insert into system.logstdby$skip_support                           /* INSERT */
             (action, name) values (2, 'DML');
insert into system.logstdby$skip_support                           /* UPDATE */
             (action, name) values (6, 'DML');
insert into system.logstdby$skip_support                           /* DELETE */
             (action, name) values (7, 'DML');

                      /* SCHEMA_DDL & NONSCHEMA_DDL computed during start up */

insert into system.logstdby$skip_support                   /* CREATE CLUSTER */
             (action, name) values (4, 'CLUSTER');
insert into system.logstdby$skip_support                    /* ALTER CLUSTER */
             (action, name) values (5, 'CLUSTER');
insert into system.logstdby$skip_support                     /* DROP CLUSTER */
             (action, name) values (8, 'CLUSTER');
insert into system.logstdby$skip_support                 /* TRUNCATE CLUSTER */
             (action, name) values (86, 'CLUSTER');

insert into system.logstdby$skip_support                   /* CREATE CONTEXT */
             (action, name) values (177, 'CONTEXT');
insert into system.logstdby$skip_support                     /* DROP CONTEXT */
             (action, name) values (178, 'CONTEXT');

insert into system.logstdby$skip_support             /* CREATE DATABASE LINK */
             (action, name) values (32, 'DATABASE LINK');
insert into system.logstdby$skip_support               /* DROP DATABASE LINK */
             (action, name) values (33, 'DATABASE LINK');
insert into system.logstdby$skip_support      /* CREATE PUBLIC DATABASE LINK */
             (action, name) values (112, 'DATABASE LINK');
insert into system.logstdby$skip_support        /* DROP PUBLIC DATABASE LINK */
             (action, name) values (113, 'DATABASE LINK');

insert into system.logstdby$skip_support                 /* CREATE DIMENSION */
             (action, name) values (174, 'DIMENSION');
insert into system.logstdby$skip_support                  /* ALTER DIMENSION */
             (action, name) values (175, 'DIMENSION');
insert into system.logstdby$skip_support                   /* DROP DIMENSION */
             (action, name) values (176, 'DIMENSION');

insert into system.logstdby$skip_support                 /* CREATE DIRECTORY */
             (action, name) values (157, 'DIRECTORY');
insert into system.logstdby$skip_support                   /* DROP DIRECTORY */
             (action, name) values (158, 'DIRECTORY');

insert into system.logstdby$skip_support                     /* CREATE INDEX */
             (action, name) values (9, 'INDEX');
insert into system.logstdby$skip_support                      /* ALTER INDEX */
             (action, name) values (11, 'INDEX');
insert into system.logstdby$skip_support                       /* DROP INDEX */
             (action, name) values (10, 'INDEX');

insert into system.logstdby$skip_support                 /* CREATE PROCEDURE */
             (action, name) values (24, 'PROCEDURE');
insert into system.logstdby$skip_support                  /* ALTER PROCEDURE */
             (action, name) values (25, 'PROCEDURE');
insert into system.logstdby$skip_support                   /* DROP PROCEDURE */
             (action, name) values (68, 'PROCEDURE');
insert into system.logstdby$skip_support                  /* CREATE FUNCTION */
             (action, name) values (91, 'PROCEDURE');
insert into system.logstdby$skip_support                   /* ALTER FUNCTION */
             (action, name) values (92, 'PROCEDURE');
insert into system.logstdby$skip_support                    /* DROP FUNCTION */
             (action, name) values (93, 'PROCEDURE');
insert into system.logstdby$skip_support                   /* CREATE PACKAGE */
             (action, name) values (94, 'PROCEDURE');
insert into system.logstdby$skip_support                    /* ALTER PACKAGE */
             (action, name) values (95, 'PROCEDURE');
insert into system.logstdby$skip_support                     /* DROP PACKAGE */
             (action, name) values (96, 'PROCEDURE');
insert into system.logstdby$skip_support              /* CREATE PACKAGE BODY */
             (action, name) values (97, 'PROCEDURE');
insert into system.logstdby$skip_support               /* ALTER PACKAGE BODY */
             (action, name) values (98, 'PROCEDURE');
insert into system.logstdby$skip_support                /* DROP PACKAGE BODY */
             (action, name) values (99, 'PROCEDURE');
insert into system.logstdby$skip_support                   /* CREATE LIBRARY */
             (action, name) values (159, 'PROCEDURE');
insert into system.logstdby$skip_support                     /* DROP LIBRARY */
             (action, name) values (84, 'PROCEDURE');

insert into system.logstdby$skip_support                   /* CREATE PROFILE */
             (action, name) values (65, 'PROFILE');
insert into system.logstdby$skip_support                    /* ALTER PROFILE */
             (action, name) values (67, 'PROFILE');
insert into system.logstdby$skip_support                     /* DROP PROFILE */
             (action, name) values (66, 'PROFILE');

insert into system.logstdby$skip_support                      /* CREATE ROLE */
             (action, name) values (52, 'ROLE');
insert into system.logstdby$skip_support                       /* ALTER ROLE */
             (action, name) values (79, 'ROLE');
insert into system.logstdby$skip_support                        /* DROP ROLE */
             (action, name) values (54, 'ROLE');
insert into system.logstdby$skip_support                         /* SET ROLE */
             (action, name) values (55, 'ROLE');

insert into system.logstdby$skip_support          /* CREATE ROLLBACK SEGMENT */
             (action, name) values (36, 'ROLLBACK STATEMENT');
insert into system.logstdby$skip_support           /* ALTER ROLLBACK SEGMENT */
             (action, name) values (37, 'ROLLBACK STATEMENT');
insert into system.logstdby$skip_support            /* DROP ROLLBACK SEGMENT */
             (action, name) values (38, 'ROLLBACK STATEMENT');

                         /* SYSTEM AUDIT & SYSTEM GRANT options not included */

insert into system.logstdby$skip_support                  /* CREATE SEQUENCE */
             (action, name) values (13, 'SEQUENCE');
insert into system.logstdby$skip_support                   /* ALTER SEQUENCE */
             (action, name) values (14, 'SEQUENCE');
insert into system.logstdby$skip_support                    /* DROP SEQUENCE */
             (action, name) values (16, 'SEQUENCE');

insert into system.logstdby$skip_support                   /* CREATE SYNONYM */
             (action, name) values (19, 'SYNONYM');
insert into system.logstdby$skip_support                     /* DROP SYNONYM */
             (action, name) values (20, 'SYNONYM');
insert into system.logstdby$skip_support            /* CREATE PUBLIC SYNONYM */
             (action, name) values (110, 'SYNONYM');
insert into system.logstdby$skip_support              /* DROP PUBLIC SYNONYM */
             (action, name) values (111, 'SYNONYM');

insert into system.logstdby$skip_support                     /* CREATE TABLE */
             (action, name) values (1, 'TABLE');
insert into system.logstdby$skip_support                      /* ALTER TABLE */
             (action, name) values (15, 'TABLE');
insert into system.logstdby$skip_support                       /* DROP TABLE */
             (action, name) values (12, 'TABLE');
insert into system.logstdby$skip_support                   /* TRUNCATE TABLE */
             (action, name) values (85, 'TABLE');
                                                /* COMMENT ON TABLE included */

insert into system.logstdby$skip_support                /* CREATE TABLESPACE */
             (action, name) values (39, 'TABLESPACE');
insert into system.logstdby$skip_support                 /* ALTER TABLESPACE */
             (action, name) values (40, 'TABLESPACE');
insert into system.logstdby$skip_support                  /* DROP TABLESPACE */
             (action, name) values (41, 'TABLESPACE');

insert into system.logstdby$skip_support                   /* CREATE TRIGGER */
             (action, name) values (59, 'TRIGGER');
insert into system.logstdby$skip_support                    /* ALTER TRIGGER */
             (action, name) values (60, 'TRIGGER');
insert into system.logstdby$skip_support                     /* DROP TRIGGER */
             (action, name) values (61, 'TRIGGER');
insert into system.logstdby$skip_support                   /* ENABLE TRIGGER */
             (action, name) values (118, 'TRIGGER');
insert into system.logstdby$skip_support                  /* DISABLE TRIGGER */
             (action, name) values (119, 'TRIGGER');
insert into system.logstdby$skip_support              /* ENABLE ALL TRIGGERS */
             (action, name) values (120, 'TRIGGER');
insert into system.logstdby$skip_support             /* DISABLE ALL TRIGGERS */
             (action, name) values (121, 'TRIGGER');

insert into system.logstdby$skip_support                      /* CREATE TYPE */
             (action, name) values (77, 'TYPE');
insert into system.logstdby$skip_support                        /* DROP TYPE */
             (action, name) values (78, 'TYPE');
insert into system.logstdby$skip_support                       /* ALTER TYPE */
             (action, name) values (80, 'TYPE');
insert into system.logstdby$skip_support                 /* CREATE TYPE BODY */
             (action, name) values (81, 'TYPE');
insert into system.logstdby$skip_support                  /* ALTER TYPE BODY */
             (action, name) values (82, 'TYPE');
insert into system.logstdby$skip_support                   /* DROP TYPE BODY */
             (action, name) values (83, 'TYPE');

insert into system.logstdby$skip_support                      /* CREATE USER */
             (action, name) values (51, 'USER');
insert into system.logstdby$skip_support                       /* ALTER USER */
             (action, name) values (43, 'USER');
insert into system.logstdby$skip_support                        /* DROP USER */
             (action, name) values (53, 'USER');

insert into system.logstdby$skip_support                      /* CREATE VIEW */
             (action, name) values (21, 'VIEW');
insert into system.logstdby$skip_support                        /* DROP VIEW */
             (action, name) values (22, 'VIEW');
commit;


Rem
Rem   List of schemas that ship with database
Rem   This list should match select username from dba_users on a shiphome.
Rem   action = 0  means we will skip acitivity in that schema
Rem   action = -1 means we will not skip acitivity in that schema
Rem   On seed, test by performing:
Rem   SELECT USERNAME FROM DBA_USERS 
Rem   WHERE USERNAME NOT IN
Rem             (SELECT SCHEMA NAME FROM DBA_SERVER_REGISTRY D
Rem              UNION ALL
Rem              SELECT S.NAME FROM SYSTEM.LOGSTDBY$SKIP_SUPPORT S
Rem              WHERE S.ACTION < 1);
Rem
insert into system.logstdby$skip_support                       /* pre-V6 doc */
                  (action, name) values (-1, 'ADAMS');
insert into system.logstdby$skip_support                       /* pre-V6 doc */
                  (action, name) values (-1, 'BLAKE');
insert into system.logstdby$skip_support                       /* pre-V6 doc */
                  (action, name) values (-1, 'CLARK');
insert into system.logstdby$skip_support                       /* pre-V6 doc */
                  (action, name) values (-1, 'JONES');
insert into system.logstdby$skip_support                       /* pre-V6 doc */
                  (action, name) values (-1, 'SCOTT');

insert into system.logstdby$skip_support                       /* Schema doc */
                  (action, name) values (-1, 'HR');
insert into system.logstdby$skip_support                       /* Schema doc */
                  (action, name) values (-1, 'IX');
insert into system.logstdby$skip_support                       /* Schema doc */
                  (action, name) values (-1, 'OE');
insert into system.logstdby$skip_support                       /* Schema doc */
                  (action, name) values (-1, 'PM');
insert into system.logstdby$skip_support                       /* Schema doc */
                  (action, name) values (-1, 'SH');


/* Features with schemas not in registry */
insert into system.logstdby$skip_support    /* ODM has schema no in registry */
                  (action, name) values (0,  'ODM');
insert into system.logstdby$skip_support                       /* Intermedia */
                  (action, name) values (0,  'SI_INFORMTN_SCHEMA');
insert into system.logstdby$skip_support                       /* Intermedia */
                  (action, name) values (0,  'ORDPLUGINS');
insert into system.logstdby$skip_support                        /* Out lines */
                  (action, name) values (0,  'OUTLN');

insert into system.logstdby$skip_support
                  (action, name) values (0,  'DBSNMP');
insert into system.logstdby$skip_support
                  (action, name) values (0,  'DIP');
insert into system.logstdby$skip_support
                  (action, name) values (0,  'SYS');
insert into system.logstdby$skip_support
                  (action, name) values (0,  'SYSTEM');
insert into system.logstdby$skip_support
                  (action, name) values (0,  'ANONYMOUS');
insert into system.logstdby$skip_support
                  (action, name) values (0,  'BI');
insert into system.logstdby$skip_support
                  (action, name) values (0,  'MDDATA');
insert into system.logstdby$skip_support
                  (action, name) values (0,  'MGMT_VIEW');
insert into system.logstdby$skip_support
                  (action, name) values (0,  'SYSMAN');
insert into system.logstdby$skip_support
                  (action, name) values (0,  'WKPROXY');
insert into system.logstdby$skip_support
                  (action, name) values (0,  'WKSYS');
insert into system.logstdby$skip_support
                  (action, name) values (0,  'WK_TEST');
commit;


Rem   Maintains history of log streams processed.
create table system.logstdby$history (
  stream_sequence#  number,                             /* Stream identifier */
  lmnr_sid          number,                           /* LogMiner session id */
  dbid              number,                                          /* DBID */
  first_change#     number,                  /* Starting scn for this stream */
  last_change#      number,                      /* Last scn for this stream */
  source            number,                            /* Stream info source */
  status            number,                             /* Processing status */
  first_time        date,             /* Time corresponding to first_change# */
  last_time         date,              /* Time corresponding to last_change# */
  dgname            varchar2(255),                  /* Dataguard name string */
  spare1            number,                              /* Future expansion */
  spare2            number,                              /* Future expansion */
  spare3            varchar2(2000)                       /* Future expansion */
) tablespace SYSAUX
/


Rem
Rem  Create views over the metadata tables.
Rem



-- LOGSTDBY_SUPPORT View for internal use only
-- This view makes up the basis for a number of queries made by logical
-- standby to make decisions about what tables to support.  This view along
-- with the dba_logstdby_unsupported view must be modified when ever the
-- collection of data types or table support changes.  If you make a change
-- here, you'll almost certainly need a change there.  All the tables and 
-- sequences are displayed here, but only those with generated_sby == 1
-- will be maintained by logical standby.
create or replace view logstdby_support as
 select owner, name, type#, obj#, gensby full_sby, current_sby,
   (case
     when supposed_sby = 1 and not exists
     (select 1
      from system.logstdby$skip s
      where statement_opt = 'DML' and proc is null 
        and error is null 
        and ((use_like = 0 and l.owner = s.schema and l.name = s.name) or 
             (use_like = 1 and 
              l.owner like s.schema and l.name like s.name) or 
             (use_like = 2 and 
              l.owner like s.schema escape esc and 
              l.name like s.name escape esc)))
     then 1
     else 0 end) generated_sby
 from
  (select owner, name, type#, obj#,
          decode(gensby, 1, 1, 0) supposed_sby,
          decode(bitand(tflags, 1073741824), 1073741824, 1, 0) current_sby,
          gensby
   from
     (select u.name owner, o.name name, o.type#,
             o.obj#, t.property tprop, t.flags tflags, 
/* BEGIN SECTION 1 COMMON CODE: LOGSTDBY_SUPPORT - DBA_LOGSTDBY_UNSUPPORTED */
 (case 
    /* The following are tables that are in an internal schema or
     * are tables like object not visible to the user or
     * are tables we support indirectly like an mv log or
     * are nested tables for which joining together column info eludes me. */
  when ((exists (select 1 from dba_server_registry d where d.schema = u.name)
         or
         exists (select 1 from system.logstdby$skip_support s
                 where s.name = u.name and action = 0))
        and not exists
               (select 1 from system.logstdby$skip_support s
                where s.name = u.name and action = -1))
    or bitand(o.flags,
                2                                       /* temporary object */
              + 4                                /* system generated object */
              + 16                                      /* secondary object */
              + 32                                  /* in-memory temp table */
              + 128                           /* dropped table (RecycleBin) */
             ) != 0
    or bitand(t.flags,
                262144     /* 0x00040000        Summary Container Table, MV */ 
              + 134217728  /* 0x08000000          in-memory temporary table */
             ) != 0
    or bitand(t.property,
                /* 512        0x00000200               iot OVeRflow segment */
                8192       /* 0x00002000                       nested table */
              + 131072     /* 0x00020000 table is used as an AQ queue table */
              + 4194304    /* 0x00400000             global temporary table */
              + 8388608    /* 0x00800000   session-specific temporary table */
              + 33554432   /* 0x02000000        Read Only Materialized View */
              + 67108864   /* 0x04000000            Materialized View table */
              + 134217728  /* 0x08000000                    Is a Sub object */
              + 2147483648 /* 0x80000000                     eXternal TaBle */
             ) != 0
    or exists                                                /* MVLOG table */
       (select 1 
        from sys.mlog$ ml where ml.mowner = u.name and ml.log = o.name) 
  then -1
    /* The following tables are user visible tables that we choose to 
     * skip because of some unsupported attribute of the table or column */
  when bitand(t.property, 
                  1        /* 0x00000001                        typed table */
             ) != 0
    or bitand(t.flags,
                536870912  /* 0x20000000  Mapping Tab for Phys rowid of IOT */
             ) != 0
    or bitand(t.trigflag,
                65536      /* 0X10000           Table has encrypted columns */
             ) != 0
    or                                                       /* Compression */
       (bitand(nvl(s.spare1,0), 2048) = 2048 and bitand(t.property, 32) != 32) 
    or o.oid$ is not null
/* END SECTION 1 COMMON CODE */
       or bitand(t.property,
             /* The following column properties are not checked in the
              * common section because they are reflected in the column
              * definitions and we want to see just those columns */
                + 2        /* 0x00000002                    has ADT columns */
                + 4        /* 0x00000004           has nested-TABLE columns */
                + 8        /* 0x00000008                    has REF columns */
               + 16        /* 0x00000010                  has array columns */
            + 32768        /* 0x00008000                   has FILE columns */
             ) != 0
       or exists
           (select 1 from sys.col$ c 
            where t.obj# = c.obj#
              and bitand(c.property, 32) != 32                /* Not hidden */
              and 
/* BEGIN SECTION 2 COMMON CODE: LOGSTDBY_SUPPORT - DBA_LOGSTDBY_UNSUPPORTED */
 (c.type# not in ( 
                  1,                             /* VARCHAR2 */
                  2,                               /* NUMBER */
                  8,                                 /* LONG */
                  12,                                /* DATE */
                  24,                            /* LONG RAW */
                  96,                                /* CHAR */
                  100,                       /* BINARY FLOAT */
                  101,                      /* BINARY DOUBLE */
                  112,                     /* CLOB and NCLOB */
                  113,                               /* BLOB */
                  180,                     /* TIMESTAMP (..) */
                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                  182,         /* INTERVAL YEAR(..) TO MONTH */
                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
  and (c.type# != 23                      /* RAW not RAW OID */
       or (c.type# = 23 and bitand(c.property, 2) = 2)))
/* END SECTION 2 COMMON CODE */
      ) then 0 else 1 end) gensby
      from sys.obj$ o, sys.user$ u, sys.tab$ t, sys.seg$ s
      where o.owner# = u.user#
        and o.obj# = t.obj#
        and t.file# = s.file# (+)
        and t.block# = s.block# (+)
        and t.ts# = s.ts# (+)
        and t.obj# = o.obj#) ltabs
   union all
   select u.name owner, o.name name, o.type#, o.obj#,
    nvl(                                /* if internal schema then 0 else 1 */
     (select 0 from dual 
      where
       ((exists (select 1 from dba_server_registry d where d.schema = u.name)
         or
         exists (select 1 from system.logstdby$skip_support s
                 where s.name = u.name and action = 0))
        and not exists
               (select 1 from system.logstdby$skip_support s
                where s.name = u.name and action = -1))), 1) supposed_sby,
          decode(bitand(s.flags, 8), 8, 1, 0) current_sby, 
          /* not used for sequences use bogus constant */ 1 gensby 
   from obj$ o, user$ u, seq$ s
   where o.owner# = u.user#
     and o.obj# = s.obj#) l
/

-- LOGSTDBY_UNSUPPORTED_TABLES
-- This undocumented view is created for the Data Guard GUI so that it
-- can get a list of tables that are not supported.  They could use
-- the dba_logstdby_unsupported view, but the query is expensive, mostly
-- because it's column based not table based.
create or replace view logstdby_unsupported_tables
as
  select owner, name table_name 
  from sys.logstdby_support
  where type#=2 and full_sby=0
/

grant select on logstdby_unsupported_tables to select_catalog_role
/

-- DBA_LOGSTDBY_UNSUPPORTED
-- This documented view displays all the unsupported columns.
create or replace view dba_logstdby_unsupported
as
  select c.owner, c.table_name, c.column_name, c.data_type,
    (case when bitand(tflags, 536870912) = 536870912
          then 'Mapping table for physical rowid of IOT'
          when bitand(segspare1, 2048) = 2048 
          then 'Table Compression'
          when bitand(tprop, 1) = 1
          then 'Object Table' /* typed table/object table */
          when bitand(col_property, 67108864) = 67108864  /* 0X4000000 */
          then 'Encrypted Column' /* encrypted column */
          else null end) attributes
  from
(select u.name owner, o.name table_name, c.name column_name, c.type#, 
  o.obj#, t.property tprop, t.flags tflags, nvl(s.spare1,0) segspare1, 
  c.property col_property,
/* BEGIN SECTION 1 COMMON CODE: LOGSTDBY_SUPPORT - DBA_LOGSTDBY_UNSUPPORTED */
 (case 
    /* The following are tables that are in an internal schema or
     * are tables like object not visible to the user or
     * are tables we support indirectly like an mv log or
     * are nested tables for which joining together column info eludes me. */
  when ((exists (select 1 from dba_server_registry d where d.schema = u.name)
         or
         exists (select 1 from system.logstdby$skip_support s
                 where s.name = u.name and action = 0))
        and not exists
               (select 1 from system.logstdby$skip_support s
                where s.name = u.name and action = -1))
    or bitand(o.flags,
                2                                       /* temporary object */
              + 4                                /* system generated object */
              + 16                                      /* secondary object */
              + 32                                  /* in-memory temp table */
              + 128                           /* dropped table (RecycleBin) */
             ) != 0
    or bitand(t.flags,
                262144     /* 0x00040000        Summary Container Table, MV */ 
              + 134217728  /* 0x08000000          in-memory temporary table */
             ) != 0
    or bitand(t.property,
                /* 512        0x00000200               iot OVeRflow segment */
                8192       /* 0x00002000                       nested table */
              + 131072     /* 0x00020000 table is used as an AQ queue table */
              + 4194304    /* 0x00400000             global temporary table */
              + 8388608    /* 0x00800000   session-specific temporary table */
              + 33554432   /* 0x02000000        Read Only Materialized View */
              + 67108864   /* 0x04000000            Materialized View table */
              + 134217728  /* 0x08000000                    Is a Sub object */
              + 2147483648 /* 0x80000000                     eXternal TaBle */
             ) != 0
    or exists                                                /* MVLOG table */
       (select 1 
        from sys.mlog$ ml where ml.mowner = u.name and ml.log = o.name) 
  then -1
    /* The following tables are user visible tables that we choose to 
     * skip because of some unsupported attribute of the table or column */
  when bitand(t.property, 
                  1        /* 0x00000001                        typed table */
             ) != 0
    or bitand(t.flags,
                536870912  /* 0x20000000  Mapping Tab for Phys rowid of IOT */
             ) != 0
    or bitand(t.trigflag,
                65536      /* 0X10000           Table has encrypted columns */
             ) != 0
    or                                                       /* Compression */
       (bitand(nvl(s.spare1,0), 2048) = 2048 and bitand(t.property, 32) != 32) 
    or o.oid$ is not null
/* END SECTION 1 COMMON CODE */
   or 
/* BEGIN SECTION 2 COMMON CODE: LOGSTDBY_SUPPORT - DBA_LOGSTDBY_UNSUPPORTED */
 (c.type# not in ( 
                  1,                             /* VARCHAR2 */
                  2,                               /* NUMBER */
                  8,                                 /* LONG */
                  12,                                /* DATE */
                  24,                            /* LONG RAW */
                  96,                                /* CHAR */
                  100,                       /* BINARY FLOAT */
                  101,                      /* BINARY DOUBLE */
                  112,                     /* CLOB and NCLOB */
                  113,                               /* BLOB */
                  180,                     /* TIMESTAMP (..) */
                  181,       /* TIMESTAMP(..) WITH TIME ZONE */
                  182,         /* INTERVAL YEAR(..) TO MONTH */
                  183,     /* INTERVAL DAY(..) TO SECOND(..) */
                  231) /* TIMESTAMP(..) WITH LOCAL TIME ZONE */
  and (c.type# != 23                      /* RAW not RAW OID */
       or (c.type# = 23 and bitand(c.property, 2) = 2)))
/* END SECTION 2 COMMON CODE */
   then 0 else 1 end) gensby
 from sys.obj$ o, sys.user$ u, sys.tab$ t, sys.seg$ s, sys.col$ c
where o.owner# = u.user#
  and o.obj# = t.obj#
  and o.obj# = c.obj#
  and t.file# = s.file# (+)
  and t.ts# = s.ts# (+)
  and t.block# = s.block# (+)
  and t.obj# = o.obj#
  and bitand(c.property, 32) != 32                         /* Not hidden */
) l, dba_tab_columns c
  where l.owner = c.owner
    and l.table_name = c.table_name
    and l.column_name = c.column_name
    and l.gensby = 0 
/
create or replace public synonym dba_logstdby_unsupported
   for dba_logstdby_unsupported
/
grant select on dba_logstdby_unsupported to select_catalog_role
/
comment on table dba_logstdby_unsupported is 
'List of all the columns that are not supported by Logical Standby'
/
comment on column dba_logstdby_unsupported.owner is 
'Schema name of unsupported column'
/
comment on column dba_logstdby_unsupported.table_name is 
'Table name of unsupported column'
/
comment on column dba_logstdby_unsupported.column_name is 
'Column name of unsupported column'
/
comment on column dba_logstdby_unsupported.data_type is
'Datatype of unsupported column'
/
comment on column dba_logstdby_unsupported.attributes is
'If not a data type issue, gives the reason why the table is unsupported'
/


create or replace view dba_logstdby_not_unique
as
  select owner, name table_name, 
         decode((select count(c.obj#)
                 from sys.col$ c
                 where c.obj# = l.obj#
                     and c.type# in (8,                              /* LONG */
                                     24,                         /* LONG RAW */
                                     112,                            /* CLOB */
                                     113)),                          /* BLOB */
                 0, 'N', 'Y') bad_column
  from logstdby_support l
  where generated_sby = 1
    and type# = 2
    and not exists                                    /* not null unique key */
       (select null
        from ind$ i, icol$ ic, col$ c
        where i.bo# = l.obj#
          and ic.obj# = i.obj#
          and c.col# = ic.col#
          and c.obj# = i.bo#
          and c.null$ > 0
          and i.type# = 1
          and bitand(i.property, 1) = 1)
    and not exists                            /* primary key rely constraint */
       (select null
        from cdef$ cd
        where cd.obj# = l.obj#
          and cd.type# = 2 
          and bitand(cd.defer, 32) = 32)
/
create or replace public synonym dba_logstdby_not_unique
   for dba_logstdby_not_unique
/
grant select on dba_logstdby_not_unique to select_catalog_role
/
comment on table dba_logstdby_not_unique is 
'List of all the tables with out primary or unique key not null constraints'
/
comment on column dba_logstdby_not_unique.owner is 
'Schema name of the non-unique table'
/
comment on column dba_logstdby_not_unique.table_name is 
'Table name of the non-unique table'
/
comment on column dba_logstdby_not_unique.bad_column is 
'Indicates that the table has a column not useful in the where clause'
/

create or replace view dba_logstdby_parameters
as
  select name, value from system.logstdby$parameters
  where name != 'SHUTDOWN'
    and name != 'SEED_PRIMARY_DBID'
    and name != 'SEED_FIRST_SCN'
    and (type < 2 or type is null)
/
create or replace public synonym dba_logstdby_parameters
   for dba_logstdby_parameters
/
grant select on dba_logstdby_parameters to select_catalog_role
/
comment on table dba_logstdby_parameters is 
'Miscellaneous options and settings for Logical Standby'
/
comment on column dba_logstdby_parameters.name is 
'Name of the parameter'
/
comment on column dba_logstdby_parameters.value is 
'Optional value of the parameter'
/


-- DBA_LOGSTDBY_PROGRESS view
-- Just break things down to understand them.
-- First, the logstdby_log view is just an aid so we can include v$standby_log
-- information in our views.  So it combines logs in logmnr_log$ with
-- v$standby_log logs.
-- Second, the dba_logstdby_progress view is just a collection of subqueries.
-- There are three important columns that are computed in the base in-line
-- view X.  These are APPLIED_SCN, READ_SCN (past tense), and NEWEST_SCN.
-- Once these are computed, they are used as the source to compute all the
-- other columns in the view.
create or replace view logstdby_log
as
  select first_change#, next_change#, sequence#, thread#, 
         first_time, next_time
  from system.logmnr_log$ where session# = 
     (select value from system.logstdby$parameters where name = 'LMNR_SID')
    /* comment */
 union
  select first_change#, (last_change# + 1) next_change#, sequence#, thread#,
         first_time, last_time next_time
  from v$standby_log where status = 'ACTIVE'
/

create or replace view dba_logstdby_progress
as
  select
    applied_scn,
    /* thread# derived from applied_scn */
    (select min(thread#) from logstdby_log 
     where sequence# = 
       (select max(sequence#) from logstdby_log l
        where applied_scn >= first_change# and applied_scn <= next_change#)
    and applied_scn >= first_change# 
    and applied_scn <= next_change#)
       applied_thread#,
    /* sequence# derived from applied_scn */
    (select max(sequence#) from logstdby_log l
     where applied_scn >= first_change# and applied_scn <= next_change#)
       applied_sequence#,
    /* estimated time derived from applied_scn */
    (select max(first_time +
        ((next_time - first_time) / (next_change# - first_change#) *
         (applied_scn - first_change#)))
     from logstdby_log l
     where applied_scn >= first_change# and applied_scn <= next_change#)
       applied_time,
    read_scn,
    /* thread# derived from read_scn */
    (select min(thread#) from logstdby_log 
     where sequence# = 
       (select max(sequence#) from logstdby_log l
        where read_scn >= first_change# and read_scn <= next_change#)
     and read_scn >= first_change#
     and read_scn <= next_change#)
       read_thread#,
    /* sequence# derived from read_scn */
    (select max(sequence#) from logstdby_log l
     where read_scn >= first_change# and read_scn <= next_change#)
       read_sequence#,
    /* estimated time derived from read_scn */
    (select min(first_time +
        ((next_time - first_time) / (next_change# - first_change#) *
         (read_scn - first_change#)))
     from logstdby_log l
     where read_scn >= first_change# and read_scn <= next_change#)
       read_time,
    newest_scn,
    /* thread# derived from newest_scn */
    (select min(thread#) from logstdby_log 
     where sequence# = 
       (select max(sequence#) from logstdby_log l
        where newest_scn >= first_change# and newest_scn <= next_change#)
     and newest_scn >= first_change#
     and newest_scn <= next_change#)
       newest_thread#,
    /* sequence# derived from newest_scn */
    (select max(sequence#) from logstdby_log l
     where newest_scn >= first_change# and newest_scn <= next_change#)
       newest_sequence#,
    /* estimated time derived from newest_scn */
    (select max(first_time +
        ((next_time - first_time) / (next_change# - first_change#) *
         (newest_scn - first_change#)))
     from logstdby_log l
     where newest_scn >= first_change# and newest_scn <= next_change#)
       newest_time
  from
    /* in-line view to calculate relavent scn values */
    (select /* APPLIED_SCN */
            greatest(nvl((select max(a.processed_scn) - 1
                          from system.logstdby$apply_milestone a),0),
                     nvl((select max(a.commit_scn)
                          from system.logstdby$apply_milestone a),0),
                     sx.start_scn) applied_scn,
            /* READ_SCN */
            greatest(nvl(sx.spill_scn,1), sx.start_scn) read_scn,
            /* NEWEST_SCN */
            nvl((select max(next_change#)-1 from logstdby_log),
                sx.start_scn) newest_scn
    from system.logmnr_session$ sx
    where sx.session# =
      (select value from system.logstdby$parameters where name = 'LMNR_SID')) x
/

create or replace public synonym dba_logstdby_progress
   for dba_logstdby_progress
/
-- This must be done in catproc, since that's where logmnr tables are created
-- grant select on dba_logstdby_progress to select_catalog_role
-- /
comment on table dba_logstdby_progress is 
'List the SCN values describing read and apply progress'
/
comment on column dba_logstdby_progress.applied_scn is 
'All transactions with a commit SCN <= this value have been applied'
/
comment on column dba_logstdby_progress.applied_thread# is 
'Thread number for a log containing the applied_scn'
/
comment on column dba_logstdby_progress.applied_sequence# is 
'Sequence number for a log containing the applied_scn'
/
comment on column dba_logstdby_progress.applied_time is 
'Estimate of the time the applied_scn was generated'
/
comment on column dba_logstdby_progress.read_scn is 
'All log data less than this SCN has been preserved in the database'
/
comment on column dba_logstdby_progress.read_thread# is 
'Thread number for a log containing the read_scn'
/
comment on column dba_logstdby_progress.read_sequence# is 
'Sequence number for a log containing the read_scn'
/
comment on column dba_logstdby_progress.read_time is 
'Estimate of the time the read_scn was generated'
/
comment on column dba_logstdby_progress.newest_scn is 
'The highest SCN that could be applied given the existing logs'
/
comment on column dba_logstdby_progress.newest_thread# is 
'Thread number for a log containing the newest_scn'
/
comment on column dba_logstdby_progress.applied_sequence# is 
'Sequence number for a log containing the newest_scn'
/
comment on column dba_logstdby_progress.newest_time is 
'Estimate of the time the newest_scn was generated'
/


-- Logmnr tables aren't created yet so FORCE was necessary --
create or replace force view dba_logstdby_log
as
  select thread#, resetlogs_change#, reset_timestamp resetlogs_id, sequence#, 
         first_change#, next_change#, first_time, next_time, file_name, timestamp, 
         dict_begin, dict_end,
    (case when l.next_change# < p.read_scn then 'YES'
          when ((bitand(l.contents, 16) = 16) and
                (bitand(l.status, 4) = 0)) then 'FETCHING'
          when ((bitand(l.contents, 16) = 16) and
                (bitand(l.status, 4) = 4)) then 'CORRUPT'
          when l.first_change# < p.applied_scn then 'CURRENT'
          else 'NO' end) applied
  from system.logmnr_log$ l, dba_logstdby_progress p
  where session# =
        (select value from system.logstdby$parameters where name = 'LMNR_SID')
/
create or replace public synonym dba_logstdby_log for dba_logstdby_log
/
-- This must be done in catproc, since that's where logmnr tables are created
-- grant select on dba_logstdby_log to select_catalog_role
-- /
comment on table dba_logstdby_log is
'List the information about received logs from the primary'
/
comment on column dba_logstdby_log.thread# is 
'Redo thread number'
/
comment on column dba_logstdby_log.sequence# is 
'Redo log sequence number'
/
comment on column dba_logstdby_log.first_change# is 
'First change# in the archived log'
/
comment on column dba_logstdby_log.next_change# is 
'First change in the next log'
/
comment on column dba_logstdby_log.first_time is 
'Timestamp of the first change'
/
comment on column dba_logstdby_log.next_time is 
'Timestamp of the next change'
/
comment on column dba_logstdby_log.file_name is 
'Archived log file name'
/
comment on column dba_logstdby_log.timestamp is 
'Time when the archiving completed'
/
comment on column dba_logstdby_log.dict_begin is 
'Contains beginning of Log Miner Dictionary'
/
comment on column dba_logstdby_log.dict_end is 
'Contains end of Log Miner Dictionary'
/
comment on column dba_logstdby_log.applied is 
'Indicates apply progress through log stream'
/

create or replace view dba_logstdby_skip_transaction
as
  select xidusn, xidslt, xidsqn
  from system.logstdby$skip_transaction
/
create or replace public synonym dba_logstdby_skip_transaction 
   for dba_logstdby_skip_transaction
/
grant select on dba_logstdby_skip_transaction to select_catalog_role
/
comment on table dba_logstdby_skip_transaction is 
'List the transactions to be skipped'
/
comment on column dba_logstdby_skip_transaction.xidusn is 
'Transaction id, component 1 of 3'
/
comment on column dba_logstdby_skip_transaction.xidslt is 
'Transaction id, component 2 of 3'
/
comment on column dba_logstdby_skip_transaction.xidsqn is 
'Transaction id, component 3 of 3'
/

create or replace view dba_logstdby_skip
as
  select * from (
     select decode(error, 1, 'Y', 'N') error,
           statement_opt, schema owner, name,
           decode(use_like, 0, 'N', 'Y') use_like, esc, proc
     from system.logstdby$skip
    union all
     select 'N' error,
           'INTERNAL SCHEMA' statement_opt, username owner, '%' name,
           'Y' use_like, null esc, null proc
     from (select username from dba_users u, 
             ((select schema name from dba_server_registry d
               union all
               select s.name from system.logstdby$skip_support s
               where s.action = 0)
              minus
               select s.name from system.logstdby$skip_support s
               where s.action = -1) i
           where u.username = i.name))
/
create or replace public synonym dba_logstdby_skip for dba_logstdby_skip
/
grant select on dba_logstdby_skip to select_catalog_role
/
comment on table dba_logstdby_skip is 
'List the skip settings choosen'
/
comment on column dba_logstdby_skip.error is 
'Does this skip setting only apply to failed attempts'
/
comment on column dba_logstdby_skip.statement_opt is 
'The statement option choosen to skip'
/
comment on column dba_logstdby_skip.owner is 
'Schema name under which this skip option should be applied'
/
comment on column dba_logstdby_skip.name is 
'Object name under which this skip option should be applied'
/
comment on column dba_logstdby_skip.use_like is 
'Use SQL wildcard search when matching names'
/
comment on column dba_logstdby_skip.esc is 
'The escape character used when performing wildcard matches.'
/
comment on column dba_logstdby_skip.proc is 
'The stored procedure to call for this skip setting.  DDL only'
/


create or replace view dba_logstdby_events
as
  select cast(event_time as date) event_time, event_time event_timestamp, 
         current_scn, commit_scn, xidusn, xidslt, xidsqn, full_event event, 
         errval status_code, error status
  from system.logstdby$events
/
create or replace public synonym dba_logstdby_events for dba_logstdby_events
/
grant select on dba_logstdby_events to select_catalog_role
/
comment on table dba_logstdby_events is 
'Information on why logical standby events'
/
comment on column dba_logstdby_events.event_time is
'Time the event took place'
/
comment on column dba_logstdby_events.current_scn is
'Change vector SCN for the change'
/
comment on column dba_logstdby_events.commit_scn is
'SCN for the commit record of the transaction'
/
comment on column dba_logstdby_events.xidusn is
'Transaction id, part 1 of 3'
/
comment on column dba_logstdby_events.xidslt is
'Transaction id, part 2 of 3'
/
comment on column dba_logstdby_events.xidsqn is
'Transaction id, part 3 of 3'
/
comment on column dba_logstdby_events.event is
'A SQL statement or other text describing the event'
/
comment on column dba_logstdby_events.status is
'A text string describing the event'
/
comment on column dba_logstdby_events.status_code is
'A number describing the event'
/

create or replace view dba_logstdby_history
as
  select stream_sequence#, decode(status, 1, 'Past', 2, 'Immediate Past', 3, 
         'Current', 4, 'Immediate Future', 5, 'Future', 6, 'Canceled', 7,
         'Invalid') status, decode(source, 1, 'Rfs', 2, 'User', 3, 'Synch', 4,
         'Redo') source, dbid, first_change#, last_change#, first_time, 
         last_time, dgname 
  from system.logstdby$history
/
create or replace public synonym dba_logstdby_history for dba_logstdby_history
/
grant select on dba_logstdby_history to select_catalog_role
/
comment on table dba_logstdby_history is 
'Information on processed, active, and pending log streams'
/
comment on column dba_logstdby_history.stream_sequence# is
'Log Stream Identifier'
/
comment on column dba_logstdby_history.status is
'The processing status of this log stream'
/
comment on column dba_logstdby_history.dbid is
'The dbid of the logfile provider'
/
comment on column dba_logstdby_history.first_change# is
'The starting scn for this log stream'
/
comment on column dba_logstdby_history.last_change# is
'The ending scn for this log stream'
/
comment on column dba_logstdby_history.first_time is
'The time associated with first_change#'
/
comment on column dba_logstdby_history.last_time is
'The time associated with last_change#'
/
comment on column dba_logstdby_history.dgname is
'The Dataguard name'
/


Rem Fix (Virtual) Views

create or replace view v_$logstdby as
  select * from v$logstdby;
create or replace public synonym v$logstdby for v_$logstdby;
grant select on v_$logstdby to select_catalog_role;

create or replace view v_$logstdby_stats as
  select * from v$logstdby_stats;
create or replace public synonym v$logstdby_stats for v_$logstdby_stats;
grant select on v_$logstdby_stats to select_catalog_role;

create or replace view v_$logstdby_transaction as
  select * from v$logstdby_transaction;
create or replace public synonym v$logstdby_transaction for v_$logstdby_transaction;
grant select on v_$logstdby_transaction to select_catalog_role;

create or replace view v_$logstdby_progress as
  select * from v$logstdby_progress;
create or replace public synonym v$logstdby_progress for v_$logstdby_progress;
grant select on v_$logstdby_progress to select_catalog_role;

create or replace view v_$logstdby_process as
  select * from v$logstdby_process;
create or replace public synonym v$logstdby_process for v_$logstdby_process;
grant select on v_$logstdby_process to select_catalog_role;

create or replace view v_$logstdby_state as
  select * from v$logstdby_state;
create or replace public synonym v$logstdby_state for v_$logstdby_state;
grant select on v_$logstdby_state to select_catalog_role;

Rem Create synonyms for the global fixed views

create or replace view gv_$logstdby as
  select * from gv$logstdby;
create or replace public synonym gv$logstdby for gv_$logstdby;
grant select on gv_$logstdby to select_catalog_role;

create or replace view gv_$logstdby_stats as
  select * from gv$logstdby_stats;
create or replace public synonym gv$logstdby_stats for gv_$logstdby_stats;
grant select on gv_$logstdby_stats to select_catalog_role;

create or replace view gv_$logstdby_transaction as
  select * from gv$logstdby_transaction;
create or replace public synonym gv$logstdby_transaction for gv_$logstdby_transaction;
grant select on gv_$logstdby_transaction to select_catalog_role;

create or replace view gv_$logstdby_progress as
  select * from gv$logstdby_progress;
create or replace public synonym gv$logstdby_progress for gv_$logstdby_progress;
grant select on gv_$logstdby_progress to select_catalog_role;

create or replace view gv_$logstdby_process as
  select * from gv$logstdby_process;
create or replace public synonym gv$logstdby_process for gv_$logstdby_process;
grant select on gv_$logstdby_process to select_catalog_role;

create or replace view gv_$logstdby_state as
  select * from gv$logstdby_state;
create or replace public synonym gv$logstdby_state for gv_$logstdby_state;
grant select on gv_$logstdby_state to select_catalog_role;

Rem Add logstdby$ tables to noexp$
delete from sys.noexp$ where name like 'LOGSTDBY$%';
insert into sys.noexp$
  select distinct u.name, o.name, o.type#
    from sys.obj$ o, sys.user$ u
    where (o.type# = 2 or o.type# = 6) and
           o.owner# = u.user# and
           o.remoteowner is null and
           u.name = 'SYSTEM' and
           o.name like 'LOGSTDBY$%';
commit;
