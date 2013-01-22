Rem
Rem $Header: catdpb.sql 03-may-2005.07:36:21 lbarton Exp $
Rem
Rem catdpb.sql
Rem
Rem Copyright (c) 2004, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catdpb.sql - Main install script for all DataPump package body
Rem                   components
Rem
Rem    DESCRIPTION
Rem     The DataPump is all the infrastructure required for new server-based
Rem     data movement utilities. This script installs the package body portion
Rem     its components including the Metadata API which was previously
Rem     installed separately (and still can be for testing purposes).
Rem     catproc.sql will now just invoke this script.
Rem
Rem    NOTES
Rem     1. Ordering of operations within this file:
Rem        a. Public view definitions
Rem        b. Package and type bodies.
Rem        c. Misc. stuff (like install XSL stylesheets)
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    lbarton     05/03/05 - Bug 4338735: don't export WMSYS 
Rem    emagrath    02/07/05 - Remove unused oper. from DATAPUMP_JOBS view 
Rem    lbarton     01/07/05 - Bug 4109444: exclude schemas 
Rem    dgagne      10/15/04 - dgagne_split_catdp
Rem    dgagne      10/04/04 - Created
Rem

-------------------------------------------------------------------------
---     Public view defs (DBA_/USER_*) go here.
-------------------------------------------------------------------------

--  Fixed (virtual) View Declarations, Synonyms, and Grants
CREATE OR REPLACE VIEW SYS.V_$DATAPUMP_JOB AS
  SELECT * FROM SYS.V$DATAPUMP_JOB;
CREATE OR REPLACE PUBLIC SYNONYM V$DATAPUMP_JOB FOR SYS.V_$DATAPUMP_JOB;
GRANT SELECT ON SYS.V_$DATAPUMP_JOB TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW SYS.V_$DATAPUMP_SESSION AS
  SELECT * FROM SYS.V$DATAPUMP_SESSION;
CREATE OR REPLACE PUBLIC SYNONYM V$DATAPUMP_SESSION FOR
  SYS.V_$DATAPUMP_SESSION;
GRANT SELECT ON SYS.V_$DATAPUMP_SESSION TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW SYS.GV_$DATAPUMP_JOB AS
  SELECT * FROM SYS.GV$DATAPUMP_JOB;
CREATE OR REPLACE PUBLIC SYNONYM GV$DATAPUMP_JOB FOR SYS.GV_$DATAPUMP_JOB;
GRANT SELECT ON SYS.GV_$DATAPUMP_JOB TO SELECT_CATALOG_ROLE;

CREATE OR REPLACE VIEW SYS.GV_$DATAPUMP_SESSION AS
  SELECT * FROM SYS.GV$DATAPUMP_SESSION;
CREATE OR REPLACE PUBLIC SYNONYM GV$DATAPUMP_SESSION FOR
  SYS.GV_$DATAPUMP_SESSION;
GRANT SELECT ON SYS.GV_$DATAPUMP_SESSION TO SELECT_CATALOG_ROLE;

--  Client Views defined on Fixed Views
--
--  FAMILY "DATAPUMP_JOBS"
--  Datapump Jobs.
--  This family has no ALL member.
--
CREATE OR REPLACE VIEW SYS.user_datapump_jobs (
                job_name, operation, job_mode, state, degree,
                attached_sessions, datapump_sessions) AS
        SELECT  j.job_name, j.operation, j.job_mode, j.state, j.workers,
                NVL((SELECT    COUNT(*)
                     FROM      SYS.GV$DATAPUMP_SESSION s
                     WHERE     j.job_id = s.job_id AND
                               s.type = 'DBMS_DATAPUMP'
                     GROUP BY  s.job_id), 0),
                NVL((SELECT    COUNT(*)
                     FROM      SYS.GV$DATAPUMP_SESSION s
                     WHERE     j.job_id = s.job_id
                     GROUP BY  s.job_id), 0)
        FROM    SYS.GV$DATAPUMP_JOB j
        WHERE   j.owner_name = SYS_CONTEXT('USERENV', 'CURRENT_USER')
      UNION ALL                               /* Not Running - Master Tables */
        SELECT o.name,
               SUBSTR (c.comment$, 24, 30), SUBSTR (c.comment$, 55, 30),
               'NOT RUNNING', 0, 0, 0
        FROM sys.obj$ o, sys.user$ u, sys.com$ c
        WHERE SUBSTR (c.comment$, 1, 22) = 'Data Pump Master Table' AND
              RTRIM (SUBSTR (c.comment$, 24, 30)) IN
                ('EXPORT','IMPORT','SQL_FILE') AND
              RTRIM (SUBSTR (c.comment$, 55, 30)) IN
                ('FULL','SCHEMA','TABLE','TABLESPACE','TRANSPORTABLE') AND
              o.obj# = c.obj# AND
              o.type# = 2 AND
              u.user# = o.owner# AND
              u.name = SYS_CONTEXT('USERENV', 'CURRENT_USER') AND
              NOT EXISTS (SELECT 1
                          FROM   SYS.GV$DATAPUMP_JOB
                          WHERE  owner_name = u.name AND
                                 job_name = o.name)
/
COMMENT ON TABLE SYS.user_datapump_jobs IS
'Datapump jobs for current user'
/
COMMENT ON COLUMN SYS.user_datapump_jobs.job_name IS
'Job name'
/
COMMENT ON COLUMN SYS.user_datapump_jobs.operation IS
'Type of operation being performed'
/
COMMENT ON COLUMN SYS.user_datapump_jobs.job_mode IS
'Mode of operation being performed'
/
COMMENT ON COLUMN SYS.user_datapump_jobs.state IS
'Current job state'
/
COMMENT ON COLUMN SYS.user_datapump_jobs.degree IS
'Number of worker processes performing the operation'
/
COMMENT ON COLUMN SYS.user_datapump_jobs.attached_sessions IS
'Number of sessions attached to the job'
/
COMMENT ON COLUMN SYS.user_datapump_jobs.datapump_sessions IS
'Number of Datapump sessions participating in the job'
/
CREATE OR REPLACE PUBLIC SYNONYM user_datapump_jobs FOR
  SYS.user_datapump_jobs
/
GRANT SELECT ON SYS.user_datapump_jobs TO PUBLIC WITH GRANT OPTION
/
CREATE OR REPLACE VIEW SYS.dba_datapump_jobs (
                owner_name, job_name, operation, job_mode, state, degree,
                attached_sessions, datapump_sessions) AS
        SELECT  j.owner_name, j.job_name, j.operation, j.job_mode, j.state,
                j.workers,
                NVL((SELECT    COUNT(*)
                     FROM      SYS.GV$DATAPUMP_SESSION s
                     WHERE     j.job_id = s.job_id AND
                               s.type = 'DBMS_DATAPUMP'
                     GROUP BY  s.job_id), 0),
                NVL((SELECT    COUNT(*)
                     FROM      SYS.GV$DATAPUMP_SESSION s
                     WHERE     j.job_id = s.job_id
                     GROUP BY  s.job_id), 0)
        FROM    SYS.GV$DATAPUMP_JOB j
      UNION ALL                               /* Not Running - Master Tables */
        SELECT u.name, o.name,
               SUBSTR (c.comment$, 24, 30), SUBSTR (c.comment$, 55, 30),
               'NOT RUNNING', 0, 0, 0
        FROM sys.obj$ o, sys.user$ u, sys.com$ c
        WHERE SUBSTR (c.comment$, 1, 22) = 'Data Pump Master Table' AND
              RTRIM (SUBSTR (c.comment$, 24, 30)) IN
                ('EXPORT','ESTIMATE','IMPORT','SQL_FILE','NETWORK') AND
              RTRIM (SUBSTR (c.comment$, 55, 30)) IN
                ('FULL','SCHEMA','TABLE','TABLESPACE','TRANSPORTABLE') AND
              o.obj# = c.obj# AND
              o.type# = 2 AND
              u.user# = o.owner# AND
              NOT EXISTS (SELECT 1
                          FROM   SYS.GV$DATAPUMP_JOB
                          WHERE  owner_name = u.name AND
                                 job_name = o.name)
/
COMMENT ON TABLE SYS.dba_datapump_jobs IS
'Datapump jobs'
/
COMMENT ON COLUMN SYS.dba_datapump_jobs.owner_name IS
'User that initiated the job'
/
COMMENT ON COLUMN SYS.dba_datapump_jobs.job_name IS
'Job name'
/
COMMENT ON COLUMN SYS.dba_datapump_jobs.operation IS
'Type of operation being performed'
/
COMMENT ON COLUMN SYS.dba_datapump_jobs.job_mode IS
'Mode of operation being performed'
/
COMMENT ON COLUMN SYS.dba_datapump_jobs.state IS
'Current job state'
/
COMMENT ON COLUMN SYS.dba_datapump_jobs.degree IS
'Number of worker proceses performing the operation'
/
COMMENT ON COLUMN SYS.dba_datapump_jobs.attached_sessions IS
'Number of sessions attached to the job'
/
COMMENT ON COLUMN SYS.dba_datapump_jobs.datapump_sessions IS
'Number of Datapump sessions participating in the job'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_datapump_jobs FOR
  SYS.dba_datapump_jobs
/
GRANT SELECT ON SYS.dba_datapump_jobs TO SELECT_CATALOG_ROLE
/

--  FAMILY "DATAPUMP_SESSIONS"
--  Datapump Sessions.
--  This family has no ALL or USER member.
--
CREATE OR REPLACE VIEW SYS.dba_datapump_sessions (
                owner_name, job_name, saddr, session_type) AS
        SELECT  j.owner_name, j.job_name, s.saddr, s.type
        FROM    SYS.GV$DATAPUMP_JOB j, SYS.GV$DATAPUMP_SESSION s
        WHERE   j.job_id = s.job_id
/
COMMENT ON TABLE SYS.dba_datapump_sessions IS
'Datapump sessions attached to a job'
/
COMMENT ON COLUMN SYS.dba_datapump_sessions.owner_name IS
'User that initiated the job'
/
COMMENT ON COLUMN SYS.dba_datapump_sessions.job_name IS
'Job name'
/
COMMENT ON COLUMN SYS.dba_datapump_sessions.saddr IS
'Address of session attached to job'
/
COMMENT ON COLUMN SYS.dba_datapump_sessions.session_type IS
'Datapump session type'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_datapump_sessions FOR
  SYS.dba_datapump_sessions
/
GRANT SELECT ON SYS.dba_datapump_sessions TO SELECT_CATALOG_ROLE
/

-- A table to hold objects that are not to be exported in a full export.
-- This and rows from sys.noexp$ form the complete exclusion set (which is
-- built at Data Pump run time into the global temp. table below). We have
-- to leave noexp$ as-is since external products use it.
-- IMPORTANT: Some views in catmeta.sql do not use this table but instead
-- have their own hard-coded list of schemas to exclude.  When a new
-- schema is added to the exclude list, catmeta.sql must also be updated.
-- Also datapump/ddl/prvtmetd.sql may need to be updated for similar reasons.


CREATE TABLE sys.ku_noexp_tab (
        obj_type        VARCHAR2(30),
        schema          VARCHAR2(30),
        name            VARCHAR2(30)
)
/

INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('TABLESPACE', NULL, 'SYSTEM')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('USER', NULL, 'SYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('USER', NULL, 'ORDSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('USER', NULL, 'EXFSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('USER', NULL, 'MDSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('USER', NULL, 'DMSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('USER', NULL, 'CTXSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('USER', NULL, 'ORDPLUGINS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('USER', NULL, 'LBACSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('USER', NULL, 'XDB')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('USER', NULL, 'SI_INFORMTN_SCHEMA')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('USER', NULL, 'DIP')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('USER', NULL, 'DBSNMP')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('USER', NULL, 'WMSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'SYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'ORDSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'EXFSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'MDSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'DMSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'CTXSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'ORDPLUGINS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'LBACSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'XDB')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'SI_INFORMTN_SCHEMA')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'DIP')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'DBSNMP')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SCHEMA', NULL, 'WMSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE_GRANT', NULL, 'ORDSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE_GRANT', NULL, 'EXFSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE_GRANT', NULL, 'MDSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE_GRANT', NULL, 'DMSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE_GRANT', NULL, 'CTXSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE_GRANT', NULL, 'ORDPLUGINS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE_GRANT', NULL, 'LBACSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE_GRANT', NULL, 'XDB')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE_GRANT', NULL, 'SI_INFORMTN_SCHEMA')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE_GRANT', NULL, 'DIP')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE_GRANT', NULL, 'DBSNMP')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE_GRANT', NULL, 'WMSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('PROFILE', NULL, 'DEFAULT')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE', NULL, 'CONNECT')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE', NULL, 'RESOURCE')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE', NULL, 'DBA')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE', NULL, 'PUBLIC')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE', NULL, '_NEXT_USER')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE', NULL, 'EXP_FULL_DATABASE')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLE', NULL, 'IMP_FULL_DATABASE')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('DEFAULT_ROLE', NULL, 'SYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('DEFAULT_ROLE', NULL, 'ORDSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('DEFAULT_ROLE', NULL, 'EXFSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('DEFAULT_ROLE', NULL, 'MDSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('DEFAULT_ROLE', NULL, 'DMSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('DEFAULT_ROLE', NULL, 'CTXSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('DEFAULT_ROLE', NULL, 'ORDPLUGINS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('DEFAULT_ROLE', NULL, 'LBACSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('DEFAULT_ROLE', NULL, 'XDB')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('DEFAULT_ROLE', NULL, 'SI_INFORMTN_SCHEMA')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('DEFAULT_ROLE', NULL, 'DIP')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('DEFAULT_ROLE', NULL, 'DBSNMP')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('DEFAULT_ROLE', NULL, 'WMSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'SYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'ORDSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'EXFSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'MDSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'DMSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'CTXSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'ORDPLUGINS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'LBACSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'XDB')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'SI_INFORMTN_SCHEMA')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'DIP')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'DBSNMP')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'WMSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'CONNECT')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'RESOURCE')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'DBA')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, '_NEXT_USER')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'EXP_FULL_DATABASE')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYSTEM_GRANT', NULL, 'IMP_FULL_DATABASE')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('OBJECT_GRANT', NULL, 'SYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('OBJECT_GRANT', NULL, 'ORDSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('OBJECT_GRANT', NULL, 'EXFSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('OBJECT_GRANT', NULL, 'MDSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('OBJECT_GRANT', NULL, 'DMSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('OBJECT_GRANT', NULL, 'CTXSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('OBJECT_GRANT', NULL, 'ORDPLUGINS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('OBJECT_GRANT', NULL, 'LBACSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('OBJECT_GRANT', NULL, 'XDB')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('OBJECT_GRANT', NULL, 'SI_INFORMTN_SCHEMA')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('OBJECT_GRANT', NULL, 'DIP')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('OBJECT_GRANT', NULL, 'DBSNMP')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('OBJECT_GRANT', NULL, 'WMSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYNONYM', 'SYS', NULL)
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYNONYM', 'ORDSYS', NULL)
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYNONYM', 'EXFSYS', NULL)
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYNONYM', 'MDSYS', NULL)
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYNONYM', 'DMSYS', NULL)
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYNONYM', 'CTXSYS', NULL)
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYNONYM', 'ORDPLUGINS', NULL)
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYNONYM', 'LBACSYS', NULL)
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYNONYM', 'XDB', NULL)
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYNONYM', 'SI_INFORMTN_SCHEMA', NULL)
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYNONYM', 'DIP', NULL)
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYNONYM', 'DBSNMP', NULL)
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('SYNONYM', 'WMSYS', NULL)
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('TABLESPACE_QUOTA', NULL, 'SYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('TABLESPACE_QUOTA', NULL, 'ORDSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('TABLESPACE_QUOTA', NULL, 'EXFSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('TABLESPACE_QUOTA', NULL, 'MDSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('TABLESPACE_QUOTA', NULL, 'DMSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('TABLESPACE_QUOTA', NULL, 'CTXSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('TABLESPACE_QUOTA', NULL, 'ORDPLUGINS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('TABLESPACE_QUOTA', NULL, 'LBACSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('TABLESPACE_QUOTA', NULL, 'XDB')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('TABLESPACE_QUOTA', NULL, 'SI_INFORMTN_SCHEMA')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('TABLESPACE_QUOTA', NULL, 'DIP')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('TABLESPACE_QUOTA', NULL, 'DBSNMP')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('TABLESPACE_QUOTA', NULL, 'WMSYS')
/
INSERT INTO sys.ku_noexp_tab ( obj_type, schema, name ) VALUES
 ('ROLLBACK_SEGMENT', NULL, 'SYSTEM')
/
--
-- Create a view that incorporates everything in the ku$_noexp_tab above and
-- the original catexp sys.noexp$ table. This view is used to populate the
-- global temporary table defined below at runtime. The view *usually* isn't
-- used directly because the union below slows metadata extraction by 10%.
-- It will be used in network mode because the metadata API running on the
-- remote instance can't see our table.
--
CREATE OR REPLACE VIEW sys.ku_noexp_view (
                obj_type, schema, name) AS
        SELECT  decode(n.obj_type, 2, 'TABLE', 6, 'SEQUENCE', 'ERROR'),
                n.owner, n.name
        FROM    sys.noexp$ n
      UNION
        SELECT  k.obj_type, k.schema, k.name
        FROM    sys.ku_noexp_tab k
/

GRANT SELECT ON sys.ku_noexp_view TO PUBLIC
/
--
-- The global temp. table used for all local export operations. Each
-- worker doing metadata loads their own private copy which doesn't have to be
-- cleaned up at session end. prvtbpw has a dependency on this.
--
CREATE GLOBAL TEMPORARY TABLE sys.ku$noexp_tab ON COMMIT PRESERVE ROWS
  AS SELECT * FROM sys.ku_noexp_view
/
GRANT SELECT ON sys.ku$noexp_tab TO PUBLIC
/
GRANT INSERT ON sys.ku$noexp_tab TO PUBLIC
/

--
-- The global temp. table used by datapump import to store statistics
-- information that will be used with dbms_stats.import... The worker will load
-- statistics information into this table and then call the dbms_stats package
-- to take the data in this table and create statistics.
--
BEGIN
  DBMS_STATS.CREATE_STAT_TABLE('SYS','IMPDP_STATS', NULL, TRUE);
END;
/
GRANT SELECT ON sys.impdp_stats TO PUBLIC
/
GRANT INSERT ON sys.impdp_stats TO PUBLIC
/
GRANT DELETE ON sys.impdp_stats TO PUBLIC
/

-------------------------------------------------------------------------
---     Public and private package and type bodies go here towards the
---     bottom as they have the most dependencies
-------------------------------------------------------------------------

-- DBMS_METADATA package body: Dependent on dbmsxml.sql
@@prvtmeta.plb

-- DBMS_METADATA_INT package body
@@prvtmeti.plb

-- DBMS_METADATA_UTIL package body: dependent on prvthpdi
@@prvtmetu.plb

-- DBMS_METADATA_BUILD package body
@@prvtmetb.plb

-- DBMS_METADATA_DPBUILD package body
@@prvtmetd.plb

-- DBMS_DATAPUMP public package body
@@prvtdp.plb

-- KUPC$QUEUE invoker's private package body
@@prvtbpc.plb

-- KUPC$QUEUE_INT definer's private package body
@@prvtbpci.plb

-- KUPW$WORKER private package body
@@prvtbpw.plb

-- KUPM$MCP private package body
@@prvtbpm.plb

-- KUPF$FILE_INT private package body
@@prvtbpfi.plb

-- KUPF$FILE private package body
@@prvtbpf.plb

-- KUPP$PROC private package body
@@prvtbpp.plb

-- KUPD$DATA invoker's private package body
@@prvtbpd.plb

-- KUPD$DATA_INT private package body
@@prvtbpdi.plb

-- KUPV$FT private package body
@@prvtbpv.plb

-- KUPV$FT_INT private package body
@@prvtbpvi.plb

-------------------------------------------------------------------------
---     Finally, miscellaneous stuff like queue tables & stylesheets.
-------------------------------------------------------------------------

-- For transportable import, IMP_FULL_DATABASE needs access to the
-- dictionary table sys.expimp_tts_ct$
grant delete,insert,select,update on sys.expimp_tts_ct$ to imp_full_database;

-- Create our queue table.
BEGIN
dbms_aqadm.create_queue_table(queue_table => 'SYS.KUPC$DATAPUMP_QUETAB', multiple_consumers => TRUE, queue_payload_type =>'SYS.KUPC$_MESSAGE', comment => 'DataPump Queue Table', compatible=>'8.1.3');

EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE = -24001 THEN NULL;
      ELSE RAISE;
      END IF;
END;
/

-- Builds heterogeneous type definitions
-- Installs XSL stylesheets (from rdbms/xml/xsl) in sys.metastylesheet
@@catmet2.sql

-- Create the Data Pump default directory object (DATA_PUMP_DIR)
@@prvtdput.plb
