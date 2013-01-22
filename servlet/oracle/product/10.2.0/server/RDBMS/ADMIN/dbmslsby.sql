Rem
Rem $Header: dbmslsby.sql 27-may-2005.14:15:01 sslim Exp $
Rem
Rem dbmslsby.sql
Rem
Rem Copyright (c) 2000, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmslsby.sql - DBMS Logical StandBY
Rem
Rem    DESCRIPTION
Rem      dbms_logstdby package definition.
Rem      Used for administering Logical Standby
Rem
Rem    NOTES
Rem      execution requires logstdby_administrator role
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sslim       05/27/05 - new addition: prepare_for_new_primary 
Rem    ajadams     05/04/05 - remove stop_on_ddl 
Rem    ajadams     05/02/05 - dbms_logstdby_public now deprecated 
Rem    ajadams     04/15/05 - move internal package out
Rem    ajadams     09/01/04 - corrupted dictionary fixup support 
Rem    sslim       08/13/04 - New prototype for rebuild 
Rem    jnesheiw    08/03/04 - Remove grant of CONNECT role to 
Rem                           LOGSTDBY_ADMINISTRATOR 
Rem    sslim       06/06/04 - fast failover: dbms_logstdby.rebuild
Rem    mtao        05/31/04 - add verify_session_logautodelete for internal use
Rem    sslim       05/25/04 - add end_stream_shared internal routine
Rem    ajadams     04/28/04 - add update_dynamic_lsby_options 
Rem    sslim       04/13/04 - obsolete: get_mtime 
Rem    raguzman    04/16/04 - max_event_records 
Rem    jkundu      11/07/03 - add purge session 
Rem    mtao        10/17/03 - lock set_tablespace, bug: 2921044
Rem    wfisher     10/03/03 - Add version parameters to need_scn 
Rem    gmulagun    09/11/03 - change type of audit PROCESS# column
Rem    htran       06/01/03 - set_export_scn: add original schema and name
Rem    raguzman    06/20/03 - dbms_logstdby should be invokers rights
Rem    raguzman    06/17/03 - fix up logstdby.set_export_scn param names
Rem    htran       05/05/03 - add set_session_state.
Rem                           add flashback_scn to get_export_dml_scn
Rem    gmulagun    03/27/03 - bug 2822534: rename tran_id to xid
Rem    raguzman    01/22/03 - new col names for seq* aud* par* job* procs
Rem    sslim       12/31/02 - 1110668: correct end_stream
Rem    jmzhang     12/31/02  - update audins, audel, audupd 
Rem    jmzhang     11/13/02 -  update audins, auddel, audupd
Rem    sslim       10/15/02 - zero data loss historian prototypes
Rem    dvoss       10/18/02 - add set_tablespace
Rem    rguzman     10/07/02 - declare history record procedures
Rem    jmzhang     09/23/02 - declare dbms_internal_safe_scn
Rem    rguzman     10/01/02 - skip using like feature
Rem    jnesheiw    09/03/02 - create DBMS_LOGSTDBY_PUBLIC package
Rem    jnesheiw    07/23/02 - grant connect, resource to logstdby_administrator
Rem    jmzhang     08/20/02 - declare unskip(one para)
Rem    gviswana    01/29/02 - CREATE OR REPLACE SYNONYM
Rem    jnesheiw    10/31/01 - fix audins.
Rem    rguzman     10/11/01 - Using internal logmnr interface, drop some procs
Rem    sslim       09/25/01 - Logminer dictionary build as a background process
Rem    sslim       09/04/01 - Mods due new procedures with additional arguments
Rem    rguzman     08/31/01 - Add guard check
Rem    jnesheiw    09/13/01 - Add stop_on_ddl support.
Rem    jnesheiw    08/07/01 - change UTL_LOGSTDBY to DBMS_INTERNAL_LOGSTDBY.
Rem    rguzman     06/19/01 - Add verify_nosession.
Rem    sslim       04/11/01 - Add parins/parupd/pardel procedures
Rem    sslim       02/21/01 - Add procedure to prepare user statement for apply
Rem    jdavison    12/01/00 - Drop extra semicolons
Rem    rguzman     09/12/00 - Handle new flags column for sequences
Rem    svivian     07/27/00 - single table instantiation
Rem    svivian     06/01/00 - delete from job queue
Rem    svivian     05/31/00 - jobupd added
Rem    svivian     05/26/00 - add hidden columns to jobq
Rem    rguzman     05/19/00 - Adding apply_set/unset
Rem    svivian     04/20/00 - continue work on sequences
Rem    svivian     04/18/00 - add callout to set logical apply mode
Rem    svivian     03/31/00 - sequence support
Rem    svivian     03/22/00 - add test_jqc
Rem    svivian     03/13/00 - procedures for audit change record processing
Rem    svivian     02/25/00 - Created
Rem



--
--
-- procedures for administering Logical Standby
--
--
CREATE OR REPLACE PACKAGE sys.dbms_logstdby AUTHID CURRENT_USER IS
   
-- Skip procedure constants   
SKIP_ACTION_SKIP    CONSTANT NUMBER :=  1;
SKIP_ACTION_APPLY   CONSTANT NUMBER :=  0;
SKIP_ACTION_REPLACE CONSTANT NUMBER := -1;
SKIP_ACTION_ERROR   CONSTANT NUMBER := -2;
SKIP_ACTION_NOPRIVS CONSTANT NUMBER := -3;

-- maximum event records that can be recorded in dba_logstdby_events
MAX_EVENTS          CONSTANT NUMBER := 2000000000;


--
-- NAME: apply_set
--
-- DESCRIPTION:
--      This procedure sets configuration options
--
-- PARAMETERS:
--      inname - config option (see documentation or validate_set)
--      value  - value for specified option
--
-- USAGE NOTES:
--      This procedure will return an error if APPLY is active.
--
-- EXCEPTIONS:
--      ora-16104 "invalid Logical Standby option requested"
--      ora-16236 "Logical Standby metadata operation in progress"
--      ora-16103 "Logical Standby must be stopped to allow this operation"
--
PROCEDURE apply_set(inname IN VARCHAR,
                    value  IN VARCHAR);


--
-- NAME: apply_unset
--
-- DESCRIPTION:
--      This procedure sets a configuration option back to its default value
--
-- PARAMETERS:
--      inname - config option (see documentation or validate_set)
--
-- USAGE NOTES:
--      This procedure will return an error if APPLY is active.
--
-- EXCEPTIONS:
--      ora-16104 "invalid Logical Standby option requested"
--      ora-16236 "Logical Standby metadata operation in progress"
--      ora-16103 "Logical Standby must be stopped to allow this operation"
--
PROCEDURE apply_unset(inname IN VARCHAR);


--
-- NAME: build
--
-- DESCRIPTION:
--      Build a LogMiner dictionary into the redo log steam.
--      Captures system catalog metadata from primary database for
--      use by Logical Standby while apply redo log changes.  This procedure
--      also turns on supplemental logging.
--
-- PARAMETERS:
--      none
--
-- USAGE NOTES:
--
-- EXCEPTIONS:
--      none
--
PROCEDURE build;


--
-- NAME: rebuild
--
-- DESCRIPTION:
--      This procedure is called 
--      after an error was detected during the LSP1 LogMiner dictionary build. 
--      Unlike
--      normal LogMiner dictionary builds, the lockdown SCN has already been
--      determined.  This SCN is stored as the FIRST_CHANGE# of a record in 
--      system.logstdby$history that represents the current log stream.  The
--      lockdown SCN is simply fetched and supplied to the dictionary gather
--      routine.  This routine will also attempt to archive SRLs that were
--      purposely deferred during activation.  These two activities, build and
--      SRL archival, must complete in order for reinstatement of standbys
---     to be successful.  The status of these activities is reflected in the
--      REINSTATEMENT_STATUS parameter which can be any of the following values:
--      BUILD PENDING, SRL ARCHIVE PENDING, READY, or NOT POSSIBLE.  A status of 
--      BUILD PENDING means that the LogMiner dictionary build is pending.  A 
--      status of SRL ARCHIVE PENDING means that the SRL archival is pending. 
--      Due to the ordering of this routine, a status of SRL ARCHIVE PENDING also
--      implies that a LogMiner dictionary build was successful.  A status of 
--      READY means that reinstatement of standbys is possible.  A status of 
--      NOT POSSIBLE means that reinstatement is not possible.  The  NOT POSSIBLE 
--      status will only occur if the LogMiner dictionary build returns a snapshot 
--      too old error.  
-- 
-- PARAMETERS:
--      none
--
-- USAGE NOTES:
--
-- EXCEPTIONS:
--      none
--
PROCEDURE rebuild;


-- NAME: validate_auth
--
-- DESCRIPTION:
--      validate security aspects of skip procedures (sec bug 4315344)
--      this proc is here not dbms_logstdby_internal because
--      package is declared authid current_user while internal is
--      declared authid definer; we need roles to be active
--
-- PARAMETERS:
--      none
--
-- USAGE NOTES:
--
-- EXCEPTIONS:
--      none
--
FUNCTION validate_auth RETURN BOOLEAN;

--
-- NAME: skip
--
-- DESCRIPTION:
--      This is a stored procedure that inserts a row in the skip table
--      according to the data passed in.  Used to define filters that
--      prevent application of SQL statements by Logical Standby apply.
--
-- PARAMETERS:
--      see documentation
--
-- USAGE NOTES:
--      This procedure will return an error if APPLY is active.
--
-- EXCEPTIONS:
--      ora-16236 "Logical Standby metadata operation in progress"
--      ora-16103 "Logical Standby must be stopped to allow this operation"
--      ora-16104 "invalid Logical Standby option requested"
--
SUBTYPE CHAR1 IS CHAR(1);
PROCEDURE skip(stmt        IN VARCHAR2,
               schema_name IN VARCHAR2 DEFAULT NULL,
               object_name IN VARCHAR2 DEFAULT NULL,
               proc_name   IN VARCHAR2 DEFAULT NULL,
               use_like    IN BOOLEAN  DEFAULT TRUE,
               esc         IN CHAR1    DEFAULT NULL);


--
-- NAME: skip_error
--
-- DESCRIPTION:
--      This is a stored procedure that inserts a row into the
--      skip table according to the data passed in.  Used to tell Logical
--      Standby apply how to behave when encountering an error.
--
-- PARAMETERS:
--      see documentation
--
-- USAGE NOTES:
--      This procedure will return an error if APPLY is active.
-- 
-- EXCEPTIONS:
--      ora-16236 "Logical Standby metadata operation in progress"
--      ora-16103 "Logical Standby must be stopped to allow this operation"
--      ora-16104 "invalid Logical Standby option requested"
--      ora-01031 "insufficient privileges"
--
PROCEDURE skip_error(stmt        IN VARCHAR2,
                     schema_name IN VARCHAR2 DEFAULT NULL,
                     object_name IN VARCHAR2 DEFAULT NULL,
                     proc_name   IN VARCHAR2 DEFAULT NULL,
                     use_like    IN BOOLEAN  DEFAULT TRUE,
                     esc         IN CHAR1    DEFAULT NULL);


--
-- NAME: skip_transaction
--
-- DESCRIPTION:
--      This is a stored procedure that inserts a row into the
--      skip transaction table according to the data passed in.
--      Used to tell Logical Standby to skip a particular txn.
--
-- PARAMETERS
--      xid
--
-- USAGE NOTES:
--      This procedure will return an error if APPLY is active.
--      WARNING: be sure skipping of this transaction will not affect
--      applying future transactions.
--
-- EXCEPTIONS:
--      ora-16236 "Logical Standby metadata operation in progress"
--      ora-16103 "Logical Standby must be stopped to allow this operation"
--      ora-01031 "insufficient privileges"
--
PROCEDURE skip_transaction(xidusn_p IN NUMBER,
                           xidslt_p IN NUMBER,
                           xidsqn_p IN NUMBER);


--
-- NAME: unskip
--
-- DESCRIPTION:
--      This is a stored procedure that deletes a row from the
--      skip table according to the data passed in.  Negates effects
--      from skip procedure.
--
-- PARAMETERS
--      see documentation
--
-- USAGE NOTES:
--      This procedure will return an error if APPLY is active.
--
-- EXCEPTIONS:
--      ora-16236 "Logical Standby metadata operation in progress"
--      ora-16103 "Logical Standby must be stopped to allow this operation"
--      ora-16104 "invalid Logical Standby option requested"
--      ora-01031 "insufficient privileges"
--
PROCEDURE unskip(stmt        IN VARCHAR2,
                 schema_name IN VARCHAR2 DEFAULT NULL,
                 object_name IN VARCHAR2 DEFAULT NULL);


--
-- NAME: unskip_error
--
-- DESCRIPTION:
--      This is a stored procedure that deletes a row from the
--      skip table according to the data passed in.  Negates effects
--      from skip_error procedure.
--
-- PARAMETERS:
--      see documentation
--
-- USAGE NOTES:
--      This procedure will return an error if APPLY is active.
--
-- EXCEPTIONS:
--      ora-16236 "Logical Standby metadata operation in progress"
--      ora-16103 "Logical Standby must be stopped to allow this operation"
--      ora-16104 "invalid Logical Standby option requested"
--      ora-01031 "insufficient privileges"
--
PROCEDURE unskip_error(stmt        IN VARCHAR2,
                       schema_name IN VARCHAR2 DEFAULT NULL,
                       object_name IN VARCHAR2 DEFAULT NULL);


--
-- NAME: unskip_transaction
--
-- DESCRIPTION:
--      This is a stored procedure that deletes a row from the
--      skip transaction table according to the data passed in.
--      Negates effects from skip_transaction procedure.
--
-- PARAMETERS
--      xid
--
-- USAGE NOTES:
--      This procedure will return an error if APPLY is active.
--
-- EXCEPTIONS:
--      ora-16236 "Logical Standby metadata operation in progress"
--      ora-16103 "Logical Standby must be stopped to allow this operation"
--      ora-16100 "not a valid Logical Standby database"
--      ora-01031 "insufficient privileges"
--
PROCEDURE unskip_transaction(xidusn_p IN NUMBER,
                             xidslt_p IN NUMBER,
                             xidsqn_p IN NUMBER);


--
-- NAME: instantiate_table
--
-- DESCRIPTION:
--      This procedure creates and populates a table and its
--      children from a table existing on a source database as
--      accessed via the dblink parameter.
--
--      If the table currently exists in the target database,
--      it will be dropped. Any constraint or index that exists
--      on the source table will also be created but physical 
--      storage characteristics will be omitted.
--
-- PARAMETERS:
--      table_name      Name of table to be instantiated
--      schema_name     Schema name in which the table resides
--      dblink          link to database in which the table resides
--
-- USAGE NOTES:
--      This procedure should be called on a logical standby database
--      whenever a table needs to be re-instantiated. If the apply
--      engine is currently running, and exception will be raised.
--      The target table will be dropped first if it currently exists.
--      Uses datapump so datapump rules apply.
--
-- EXCEPTIONS:
--      ora-16236 "Logical Standby metadata operation in progress"
--      ora-16103 "Logical Standby must be stopped to allow this operation"
--
PROCEDURE instantiate_table(schema_name IN VARCHAR2,
                            table_name  IN VARCHAR2,
                            dblink      IN VARCHAR2);


--
-- NAME: set_tablespace
--
-- DESCRIPTION:
--      This procedure changes the tablespace used to store logical
--      standby metadata.  By default this data is stored in SYSAUX.
--      Users have the option to move the metadata to another schema
--      provided APPLY is not running when the data is moved.
--
-- PARAMETERS:
--      new_tablespace      Name of tablespace to hold metadata
--
-- USAGE NOTES:
--      This procedure will return an error if APPLY is active.
--
-- EXCEPTIONS:
--      ora-16236 "Logical Standby metadata operation in progress"
--      ora-16103 "Logical Standby must be stopped to allow this operation"
--
PROCEDURE set_tablespace(new_tablespace IN VARCHAR2);


--
-- NAME: purge_session
--
-- DESCRIPTION:
--      This procedure purges the session metadata up to the latest
--      safe purge scn. This procedure can be called while the logical
--      standby apply is running
--
-- PARAMETERS:
--      NONE
--
-- USAGE NOTES:
--      This procedure can be called while apply is running
--
-- EXCEPTIONS:
--      ora-01309 "invalid session"
--
PROCEDURE purge_session;


--
-- NAME: prepare_for_new_primary
--
-- DESCRIPTION:
--
--      This procedure is called to ready the local logical standby
--      for configuration with a failed-over primary.  This routine will:
--      
--        1. Ensure the primary is only one role transition ahead of us.
--        2. Ensure we haven't applied too far (i.e. flashback required).
--        3. Purge log$ of all logfiles that need to be obtained from the
--           new primary's copy (a.k.a terminal logs).
--
--      If the new primary was formerly a physical standby, the user should
--      issue a START LOGICAL STANDBY APPLY.  If the new primary was formerly 
--      a logical standby, the user must ensure to copy and re-register the
--      terminal logs, as indicated in the alert.log, and issue a START 
--      LOGICAL STANDBY APPLY NEW PRIMARY.  This DDL will ensure the apply
--      runs in the appropriate apply mode.
--
-- PARAMETERS:
--      former_standby_type -- Type of standby the new primary was activated
--                             from.  Valid values are 'PHYSICAL' | 'LOGICAL'
--      dblink              -- dblink to the activated primary
--
-- USAGE NOTES:
--      NONE
--
-- EXCEPTIONS:
--      NONE
--
PROCEDURE prepare_for_new_primary (former_standby_type IN VARCHAR2, 
                                   dblink              IN VARCHAR2);

END dbms_logstdby;
/
show errors
  
CREATE OR REPLACE PUBLIC SYNONYM dbms_logstdby FOR sys.dbms_logstdby;

-- Revoke execute on DBMS_LOGSTDBY from public.  If it has already
-- been revoked, do not throw an error. NOTE this is to accomodate
-- 9iR1 databases that formerly had the package executable to public. 
DECLARE
  already_revoked EXCEPTION;
  PRAGMA EXCEPTION_INIT(already_revoked,-01927);
BEGIN
   execute immediate 'REVOKE EXECUTE ON dbms_logstdby FROM public';
EXCEPTION WHEN already_revoked then null;
END;
/
GRANT EXECUTE ON dbms_logstdby TO dba;

-- Create role lesser than dba to manage logstdby 
-- BUT: they will not be able to skip/unskip which requires 'BECOME USER'
CREATE ROLE logstdby_administrator;
GRANT EXECUTE ON dbms_logstdby TO logstdby_administrator;
GRANT RESOURCE TO logstdby_administrator;
/



--
--
-- internal procedures for administering Logical Standby
--
--
CREATE OR REPLACE PACKAGE sys.dbms_internal_logstdby AUTHID DEFINER IS

PROCEDURE guard_check;

PROCEDURE guard_bypass_on;

PROCEDURE guard_bypass_off;

PROCEDURE apply_is_off;

PROCEDURE apply;

PROCEDURE apply_stop;

PROCEDURE apply_abort;

PROCEDURE lock_lsby_meta;

PROCEDURE unlock_lsby_meta;

PROCEDURE create_future_session(dbid     IN  NUMBER,
				lmnr_sid OUT NUMBER,
                                fscn     IN  NUMBER);

PROCEDURE destroy_future_session(lmnr_sid IN NUMBER);

PROCEDURE update_dynamic_lsby_option(option_name IN VARCHAR);

PROCEDURE end_stream(dblink IN VARCHAR, status OUT NUMBER);

PROCEDURE end_stream_shared(dblink IN  VARCHAR, 
                            status OUT NUMBER,
                            cdbid  IN  NUMBER,
                            cfscn  IN  NUMBER,
                            clscn  IN  NUMBER,
                            ndbid  IN  NUMBER,
                            nfscn  IN  NUMBER);

PROCEDURE build;

PROCEDURE rebuild(internal IN BOOLEAN);

PROCEDURE verify_session_logautodelete(checkparam IN BOOLEAN);

PROCEDURE verify_session;

PROCEDURE verify_nosession;

PROCEDURE flush_srls(tag IN VARCHAR2, isLogical IN NUMBER);

PROCEDURE primary_dbid(dbid IN NUMBER);

PROCEDURE apply_set(inname  IN VARCHAR,
                    value   IN VARCHAR,
                    dynamic IN BOOLEAN);

PROCEDURE apply_unset(inname  IN VARCHAR,
                      dynamic IN BOOLEAN);

FUNCTION validate_set(inname  IN VARCHAR,
                      value   IN VARCHAR,
                      fulltst IN BOOLEAN) RETURN BOOLEAN;

PROCEDURE capture_scn;

PROCEDURE set_logical_instantiation;

PROCEDURE clear_logical_instantiation;

PROCEDURE get_safe_scn(safe_scn OUT NUMBER);

PROCEDURE lock_tables;

PROCEDURE sequence_update(objnum  IN NUMBER,
                          incrnum IN NUMBER,
                          newval  IN NUMBER);

PROCEDURE audins(sessionid_N          IN NUMBER    DEFAULT 0,
                 entryid_N            IN NUMBER    DEFAULT 0,
                 statement_N          IN NUMBER    DEFAULT 0,
                 timestamp#_N         IN DATE      DEFAULT SYSDATE,
                 userid_N             IN VARCHAR2  DEFAULT NULL,
                 userhost_N           IN VARCHAR2  DEFAULT NULL,
                 terminal_N           IN VARCHAR2  DEFAULT NULL,
                 action#_N            IN NUMBER    DEFAULT 0,
                 returncode_N         IN NUMBER    DEFAULT 0,
                 obj$creator_N        IN VARCHAR2  DEFAULT NULL,
                 obj$name_N           IN VARCHAR2  DEFAULT NULL,
                 auth$privileges_N    IN VARCHAR2  DEFAULT NULL,
                 auth$grantee_N       IN VARCHAR2  DEFAULT NULL,
                 new$owner_N          IN VARCHAR2  DEFAULT NULL,
                 new$name_N           IN VARCHAR2  DEFAULT NULL,
                 ses$actions_N        IN VARCHAR2  DEFAULT NULL,
                 ses$tid_N            IN NUMBER    DEFAULT NULL,
                 logoff$lread_N       IN NUMBER    DEFAULT NULL,
                 logoff$pread_N       IN NUMBER    DEFAULT NULL,
                 logoff$lwrite_N      IN NUMBER    DEFAULT NULL,
                 logoff$dead_N        IN NUMBER    DEFAULT NULL,
                 logoff$time_N        IN DATE      DEFAULT NULL,
                 comment$text_N       IN VARCHAR2  DEFAULT NULL,
                 clientid_N           IN VARCHAR2  DEFAULT NULL,
                 spare1_N             IN VARCHAR2  DEFAULT NULL,
                 spare2_N             IN NUMBER    DEFAULT NULL,
                 obj$label_N          IN RAW       DEFAULT NULL,
                 ses$label_N          IN RAW       DEFAULT NULL,
                 priv$used_N          IN NUMBER    DEFAULT NULL,
                 sessioncpu_N         IN NUMBER    DEFAULT NULL,
                 ntimestamp#_N        IN TIMESTAMP DEFAULT NULL,
                 proxy$sid_N          IN NUMBER    DEFAULT NULL,
                 user$guid_N          IN VARCHAR2  DEFAULT NULL,
                 instance#_N          IN NUMBER    DEFAULT NULL,
                 process#_N           IN VARCHAR2  DEFAULT NULL,
                 xid_N                IN RAW       DEFAULT NULL,
                 auditid_N            IN VARCHAR2  DEFAULT NULL,
                 scn_N                IN NUMBER    DEFAULT NULL,
                 dbid_N               IN NUMBER    DEFAULT NULL,
                 sqlbind_N            IN CLOB      DEFAULT NULL,
                 sqltext_N            IN CLOB      DEFAULT NULL);

PROCEDURE audupd(sessionid_N          IN NUMBER    DEFAULT 0,
                 sessionid_I          IN NUMBER    DEFAULT 0,
                 sessionid_O          IN NUMBER    DEFAULT 0,
                 sessionid_OI         IN NUMBER    DEFAULT 0,
                 entryid_N            IN NUMBER    DEFAULT 0,
                 entryid_I            IN NUMBER    DEFAULT 0,
                 entryid_O            IN NUMBER    DEFAULT 0,
                 entryid_OI           IN NUMBER    DEFAULT 0,
                 statement_N          IN NUMBER    DEFAULT 0,
                 statement_I          IN NUMBER    DEFAULT 0,
                 statement_O          IN NUMBER    DEFAULT 0,
                 statement_OI         IN NUMBER    DEFAULT 0,
                 timestamp#_N         IN DATE      DEFAULT SYSDATE,
                 timestamp#_I         IN NUMBER    DEFAULT 0,
                 timestamp#_O         IN DATE      DEFAULT SYSDATE,
                 timestamp#_OI        IN NUMBER    DEFAULT 0,
                 userid_N             IN VARCHAR2  DEFAULT NULL,
                 userid_I             IN NUMBER    DEFAULT 0,
                 userid_O             IN VARCHAR2  DEFAULT NULL,
                 userid_OI            IN NUMBER    DEFAULT 0,
                 userhost_N           IN VARCHAR2  DEFAULT NULL,
                 userhost_I           IN NUMBER    DEFAULT 0,
                 userhost_O           IN VARCHAR2  DEFAULT NULL,
                 userhost_OI          IN NUMBER    DEFAULT 0,
                 terminal_N           IN VARCHAR2  DEFAULT NULL,
                 terminal_I           IN NUMBER    DEFAULT 0,
                 terminal_O           IN VARCHAR2  DEFAULT NULL,
                 terminal_OI          IN NUMBER    DEFAULT 0,
                 action#_N            IN NUMBER    DEFAULT 0,
                 action#_I            IN NUMBER    DEFAULT 0,
                 action#_O            IN NUMBER    DEFAULT 0,
                 action#_OI           IN NUMBER    DEFAULT 0,
                 returncode_N         IN NUMBER    DEFAULT 0,
                 returncode_I         IN NUMBER    DEFAULT 0,
                 returncode_O         IN NUMBER    DEFAULT 0,
                 returncode_OI        IN NUMBER    DEFAULT 0,
                 obj$creator_N        IN VARCHAR2  DEFAULT NULL,
                 obj$creator_I        IN NUMBER    DEFAULT 0,
                 obj$creator_O        IN VARCHAR2  DEFAULT NULL,
                 obj$creator_OI       IN NUMBER    DEFAULT 0,
                 obj$name_N           IN VARCHAR2  DEFAULT NULL,
                 obj$name_I           IN NUMBER    DEFAULT 0,
                 obj$name_O           IN VARCHAR2  DEFAULT NULL,
                 obj$name_OI          IN NUMBER    DEFAULT 0,
                 auth$privileges_N    IN VARCHAR2  DEFAULT NULL,
                 auth$privileges_I    IN NUMBER    DEFAULT 0,
                 auth$privileges_O    IN VARCHAR2  DEFAULT NULL,
                 auth$privileges_OI   IN NUMBER    DEFAULT 0,
                 auth$grantee_N       IN VARCHAR2  DEFAULT NULL,
                 auth$grantee_I       IN NUMBER    DEFAULT 0,
                 auth$grantee_O       IN VARCHAR2  DEFAULT NULL,
                 auth$grantee_OI      IN NUMBER    DEFAULT 0,
                 new$owner_N          IN VARCHAR2  DEFAULT NULL,
                 new$owner_I          IN NUMBER    DEFAULT 0,
                 new$owner_O          IN VARCHAR2  DEFAULT NULL,
                 new$owner_OI         IN NUMBER    DEFAULT 0,
                 new$name_N           IN VARCHAR2  DEFAULT NULL,
                 new$name_I           IN NUMBER    DEFAULT 0,
                 new$name_O           IN VARCHAR2  DEFAULT NULL,
                 new$name_OI          IN NUMBER    DEFAULT 0,
                 ses$actions_N        IN VARCHAR2  DEFAULT NULL,
                 ses$actions_I        IN NUMBER    DEFAULT 0,
                 ses$actions_O        IN VARCHAR2  DEFAULT NULL,
                 ses$actions_OI       IN NUMBER    DEFAULT 0,
                 ses$tid_N            IN NUMBER    DEFAULT NULL,
                 ses$tid_I            IN NUMBER    DEFAULT 0,
                 ses$tid_O            IN NUMBER    DEFAULT NULL,
                 ses$tid_OI           IN NUMBER    DEFAULT 0,
                 logoff$lread_N       IN NUMBER    DEFAULT NULL,
                 logoff$lread_I       IN NUMBER    DEFAULT 0,
                 logoff$lread_O       IN NUMBER    DEFAULT NULL,
                 logoff$lread_OI      IN NUMBER    DEFAULT 0,
                 logoff$pread_N       IN NUMBER    DEFAULT NULL,
                 logoff$pread_I       IN NUMBER    DEFAULT 0,
                 logoff$pread_O       IN NUMBER    DEFAULT NULL,
                 logoff$pread_OI      IN NUMBER    DEFAULT 0,
                 logoff$lwrite_N      IN NUMBER    DEFAULT NULL,
                 logoff$lwrite_I      IN NUMBER    DEFAULT 0,
                 logoff$lwrite_O      IN NUMBER    DEFAULT NULL,
                 logoff$lwrite_OI     IN NUMBER    DEFAULT 0,
                 logoff$dead_N        IN NUMBER    DEFAULT NULL,
                 logoff$dead_I        IN NUMBER    DEFAULT 0,
                 logoff$dead_O        IN NUMBER    DEFAULT NULL,
                 logoff$dead_OI       IN NUMBER    DEFAULT 0,
                 logoff$time_N        IN DATE      DEFAULT NULL,
                 logoff$time_I        IN NUMBER    DEFAULT 0,
                 logoff$time_O        IN DATE      DEFAULT NULL,
                 logoff$time_OI       IN NUMBER    DEFAULT 0,
                 comment$text_N       IN VARCHAR2  DEFAULT NULL,
                 comment$text_I       IN NUMBER    DEFAULT 0,
                 comment$text_O       IN VARCHAR2  DEFAULT NULL,
                 comment$text_OI      IN NUMBER    DEFAULT 0,
                 clientid_N           IN VARCHAR2  DEFAULT NULL,
                 clientid_I           IN NUMBER    DEFAULT 0,
                 clientid_O           IN VARCHAR2  DEFAULT NULL,
                 clientid_OI          IN NUMBER    DEFAULT 0,
                 spare1_N             IN VARCHAR2  DEFAULT NULL,
                 spare1_I             IN NUMBER    DEFAULT 0,
                 spare1_O             IN VARCHAR2  DEFAULT NULL,
                 spare1_OI            IN NUMBER    DEFAULT 0,
                 spare2_N             IN NUMBER    DEFAULT NULL,
                 spare2_I             IN NUMBER    DEFAULT 0,
                 spare2_O             IN NUMBER    DEFAULT NULL,
                 spare2_OI            IN NUMBER    DEFAULT 0,
                 obj$label_N          IN RAW       DEFAULT NULL,
                 obj$label_I          IN NUMBER    DEFAULT 0,
                 obj$label_O          IN RAW       DEFAULT NULL,
                 obj$label_OI         IN NUMBER    DEFAULT 0,
                 ses$label_N          IN RAW       DEFAULT NULL,
                 ses$label_I          IN NUMBER    DEFAULT 0,
                 ses$label_O          IN RAW       DEFAULT NULL,
                 ses$label_OI         IN NUMBER    DEFAULT 0,
                 priv$used_N          IN NUMBER    DEFAULT NULL,
                 priv$used_I          IN NUMBER    DEFAULT 0,
                 priv$used_O          IN NUMBER    DEFAULT NULL,
                 priv$used_OI         IN NUMBER    DEFAULT 0,
                 sessioncpu_N         IN NUMBER    DEFAULT NULL,
                 sessioncpu_I         IN NUMBER    DEFAULT 0,
                 sessioncpu_O         IN NUMBER    DEFAULT NULL,
                 sessioncpu_OI        IN NUMBER    DEFAULT 0,
                 ntimestamp#_N        IN TIMESTAMP DEFAULT NULL,
                 ntimestamp#_I        IN NUMBER    DEFAULT 0,
                 ntimestamp#_O        IN TIMESTAMP DEFAULT NULL,
                 ntimestamp#_OI       IN NUMBER    DEFAULT 0,
                 proxy$sid_N          IN NUMBER    DEFAULT NULL,
                 proxy$sid_I          IN NUMBER    DEFAULT 0,
                 proxy$sid_O          IN NUMBER    DEFAULT NULL,
                 proxy$sid_OI         IN NUMBER    DEFAULT 0,
                 user$guid_N          IN VARCHAR2  DEFAULT NULL,
                 user$guid_I          IN NUMBER    DEFAULT 0,
                 user$guid_O          IN VARCHAR2  DEFAULT NULL,
                 user$guid_OI         IN NUMBER    DEFAULT 0,
                 instance#_N          IN NUMBER    DEFAULT NULL,
                 instance#_I          IN NUMBER    DEFAULT 0,
                 instance#_O          IN NUMBER    DEFAULT NULL,
                 instance#_OI         IN NUMBER    DEFAULT 0,
                 process#_N           IN VARCHAR2  DEFAULT NULL,
                 process#_I           IN NUMBER    DEFAULT 0,
                 process#_O           IN VARCHAR2  DEFAULT NULL,
                 process#_OI          IN NUMBER    DEFAULT 0,
                 xid_N                IN RAW       DEFAULT NULL,
                 xid_I                IN NUMBER    DEFAULT 0,
                 xid_O                IN RAW       DEFAULT NULL,
                 xid_OI               IN NUMBER    DEFAULT 0,
                 auditid_N            IN VARCHAR2  DEFAULT NULL,
                 auditid_I            IN NUMBER    DEFAULT 0,
                 auditid_O            IN VARCHAR2  DEFAULT NULL,
                 auditid_OI           IN NUMBER    DEFAULT 0,
                 scn_N                IN NUMBER    DEFAULT NULL,
                 scn_I                IN NUMBER    DEFAULT 0,
                 scn_O                IN NUMBER    DEFAULT NULL,
                 scn_OI               IN NUMBER    DEFAULT 0,
                 dbid_N               IN NUMBER    DEFAULT NULL,
                 dbid_I               IN NUMBER    DEFAULT 0,
                 dbid_O               IN NUMBER    DEFAULT NULL,
                 dbid_OI              IN NUMBER    DEFAULT 0,
                 sqlbind_N            IN CLOB      DEFAULT NULL,
                 sqlbind_I            IN NUMBER    DEFAULT 0,
                 sqlbind_O            IN CLOB      DEFAULT NULL,
                 sqlbind_OI           IN NUMBER    DEFAULT 0,
                 sqltext_N            IN CLOB      DEFAULT NULL,
                 sqltext_I            IN NUMBER    DEFAULT 0,
                 sqltext_O            IN CLOB      DEFAULT NULL,
                 sqltext_OI           IN NUMBER    DEFAULT 0);

PROCEDURE auddel(sessionid_O          IN NUMBER    DEFAULT 0,
                 entryid_O            IN NUMBER    DEFAULT 0,
                 statement_O          IN NUMBER    DEFAULT 0,
                 timestamp#_O         IN DATE      DEFAULT SYSDATE,
                 userid_O             IN VARCHAR2  DEFAULT NULL,
                 userhost_O           IN VARCHAR2  DEFAULT NULL,
                 terminal_O           IN VARCHAR2  DEFAULT NULL,
                 action#_O            IN NUMBER    DEFAULT 0,
                 returncode_O         IN NUMBER    DEFAULT 0,
                 obj$creator_O        IN VARCHAR2  DEFAULT NULL,
                 obj$name_O           IN VARCHAR2  DEFAULT NULL,
                 auth$privileges_O    IN VARCHAR2  DEFAULT NULL,
                 auth$grantee_O       IN VARCHAR2  DEFAULT NULL,
                 new$owner_O          IN VARCHAR2  DEFAULT NULL,
                 new$name_O           IN VARCHAR2  DEFAULT NULL,
                 ses$actions_O        IN VARCHAR2  DEFAULT NULL,
                 ses$tid_O            IN NUMBER    DEFAULT NULL,
                 logoff$lread_O       IN NUMBER    DEFAULT NULL,
                 logoff$pread_O       IN NUMBER    DEFAULT NULL,
                 logoff$lwrite_O      IN NUMBER    DEFAULT NULL,
                 logoff$dead_O        IN NUMBER    DEFAULT NULL,
                 logoff$time_O        IN DATE      DEFAULT NULL,
                 comment$text_O       IN VARCHAR2  DEFAULT NULL,
                 clientid_O           IN VARCHAR2  DEFAULT NULL,
                 spare1_O             IN VARCHAR2  DEFAULT NULL,
                 spare2_O             IN NUMBER    DEFAULT NULL,
                 obj$label_O          IN RAW       DEFAULT NULL,
                 ses$label_O          IN RAW       DEFAULT NULL,
                 priv$used_O          IN NUMBER    DEFAULT NULL,
                 sessioncpu_O         IN NUMBER    DEFAULT NULL,
                 ntimestamp#_O        IN TIMESTAMP DEFAULT NULL,
                 proxy$sid_O          IN NUMBER    DEFAULT NULL,
                 user$guid_O          IN VARCHAR2  DEFAULT NULL,
                 instance#_O          IN NUMBER    DEFAULT NULL,
                 process#_O           IN VARCHAR2  DEFAULT NULL,
                 xid_O                IN RAW       DEFAULT NULL,
                 auditid_O            IN VARCHAR2  DEFAULT NULL,
                 scn_O                IN NUMBER    DEFAULT NULL,
                 dbid_O               IN NUMBER    DEFAULT NULL,
                 sqlbind_O            IN CLOB      DEFAULT NULL,
                 sqltext_O            IN CLOB      DEFAULT NULL);


PROCEDURE fgains(sessionid_N    IN NUMBER    DEFAULT NULL,
                 timestamp#_N   IN DATE      DEFAULT NULL,
                 dbuid_N        IN VARCHAR2  DEFAULT NULL,
                 osuid_N        IN VARCHAR2  DEFAULT NULL,
                 oshst_N        IN VARCHAR2  DEFAULT NULL,
                 clientid_N     IN VARCHAR2  DEFAULT NULL,
                 extid_N        IN VARCHAR2  DEFAULT NULL,
                 obj$schema_N   IN VARCHAR2  DEFAULT NULL,
                 obj$name_N     IN VARCHAR2  DEFAULT NULL,
                 policyname_N   IN VARCHAR2  DEFAULT NULL,
                 scn_N          IN NUMBER    DEFAULT NULL,
                 sqltext_N      IN VARCHAR2  DEFAULT NULL,
                 lsqltext_N     IN CLOB      DEFAULT NULL,
                 sqlbind_N      IN VARCHAR2  DEFAULT NULL,
                 comment$text_N IN VARCHAR2  DEFAULT NULL,
                 plhol_N        IN LONG      DEFAULT NULL,
                 stmt_type_N    IN NUMBER    DEFAULT NULL,
                 ntimestamp#_N  IN TIMESTAMP DEFAULT NULL,
                 proxy$sid_N    IN NUMBER    DEFAULT NULL,
                 user$guid_N    IN VARCHAR2  DEFAULT NULL,
                 instance#_N    IN NUMBER    DEFAULT NULL,
                 process#_N     IN VARCHAR2  DEFAULT NULL,
                 xid_N          IN RAW       DEFAULT NULL, 
                 auditid_N      IN VARCHAR2  DEFAULT NULL,
                 statement_N    IN NUMBER    DEFAULT NULL,
                 entryid_N      IN NUMBER    DEFAULT NULL,
                 dbid_N         IN NUMBER    DEFAULT NULL,
                 lsqlbind_N     IN CLOB      DEFAULT NULL);

PROCEDURE fgadel(sessionid_O    IN NUMBER    DEFAULT NULL,
                 timestamp#_O   IN DATE      DEFAULT NULL,
                 dbuid_O        IN VARCHAR2  DEFAULT NULL,
                 osuid_O        IN VARCHAR2  DEFAULT NULL,
                 oshst_O        IN VARCHAR2  DEFAULT NULL,
                 clientid_O     IN VARCHAR2  DEFAULT NULL,
                 extid_O        IN VARCHAR2  DEFAULT NULL,
                 obj$schema_O   IN VARCHAR2  DEFAULT NULL,
                 obj$name_O     IN VARCHAR2  DEFAULT NULL,
                 policyname_O   IN VARCHAR2  DEFAULT NULL,
                 scn_O          IN NUMBER    DEFAULT NULL,
                 sqltext_O      IN VARCHAR2  DEFAULT NULL,
                 lsqltext_O     IN CLOB      DEFAULT NULL,
                 sqlbind_O      IN VARCHAR2  DEFAULT NULL,
                 comment$text_O IN VARCHAR2  DEFAULT NULL,
                 plhol_O        IN LONG      DEFAULT NULL,
                 stmt_type_O    IN NUMBER    DEFAULT NULL,
                 ntimestamp#_O  IN TIMESTAMP DEFAULT NULL,
                 proxy$sid_O    IN NUMBER    DEFAULT NULL,
                 user$guid_O    IN VARCHAR2  DEFAULT NULL,
                 instance#_O    IN NUMBER    DEFAULT NULL,
                 process#_O     IN VARCHAR2  DEFAULT NULL,
                 xid_O          IN RAW       DEFAULT NULL, 
                 auditid_O      IN VARCHAR2  DEFAULT NULL,
                 statement_O    IN NUMBER    DEFAULT NULL,
                 entryid_O      IN NUMBER    DEFAULT NULL,
                 dbid_O         IN NUMBER    DEFAULT NULL,
                 lsqlbind_O     IN CLOB      DEFAULT NULL);

PROCEDURE fgaupd(sessionid_N    IN NUMBER    DEFAULT NULL,
                 sessionid_I    IN NUMBER    DEFAULT 0,
                 sessionid_O    IN NUMBER    DEFAULT NULL,
                 sessionid_OI   IN NUMBER    DEFAULT 0,
                 timestamp#_N   IN DATE      DEFAULT NULL,
                 timestamp#_I   IN NUMBER    DEFAULT 0,
                 timestamp#_O   IN DATE      DEFAULT NULL,
                 timestamp#_OI  IN NUMBER    DEFAULT 0,
                 dbuid_N        IN VARCHAR2  DEFAULT NULL,
                 dbuid_I        IN NUMBER    DEFAULT 0,
                 dbuid_O        IN VARCHAR2  DEFAULT NULL,
                 dbuid_OI       IN NUMBER    DEFAULT 0,
                 osuid_N        IN VARCHAR2  DEFAULT NULL,
                 osuid_I        IN NUMBER    DEFAULT 0,
                 osuid_O        IN VARCHAR2  DEFAULT NULL,
                 osuid_OI       IN NUMBER    DEFAULT 0,
                 oshst_N        IN VARCHAR2  DEFAULT NULL,
                 oshst_I        IN NUMBER    DEFAULT 0,
                 oshst_O        IN VARCHAR2  DEFAULT NULL,
                 oshst_OI       IN NUMBER    DEFAULT 0,
                 clientid_N     IN VARCHAR2  DEFAULT NULL,
                 clientid_I     IN NUMBER    DEFAULT 0,
                 clientid_O     IN VARCHAR2  DEFAULT NULL,
                 clientid_OI    IN NUMBER    DEFAULT 0,
                 extid_N        IN VARCHAR2  DEFAULT NULL,
                 extid_I        IN NUMBER    DEFAULT 0,
                 extid_O        IN VARCHAR2  DEFAULT NULL,
                 extid_OI       IN NUMBER    DEFAULT 0,
                 obj$schema_N   IN VARCHAR2  DEFAULT NULL,
                 obj$schema_I   IN NUMBER    DEFAULT 0,
                 obj$schema_O   IN VARCHAR2  DEFAULT NULL,
                 obj$schema_OI  IN NUMBER    DEFAULT 0,
                 obj$name_N     IN VARCHAR2  DEFAULT NULL,
                 obj$name_I     IN NUMBER    DEFAULT 0,
                 obj$name_O     IN VARCHAR2  DEFAULT NULL,
                 obj$name_OI    IN NUMBER    DEFAULT 0,
                 policyname_N   IN VARCHAR2  DEFAULT NULL,
                 policyname_I   IN NUMBER    DEFAULT 0,
                 policyname_O   IN VARCHAR2  DEFAULT NULL,
                 policyname_OI  IN NUMBER    DEFAULT 0,
                 scn_N          IN NUMBER    DEFAULT NULL,
                 scn_I          IN NUMBER    DEFAULT 0,
                 scn_O          IN NUMBER    DEFAULT NULL,
                 scn_OI         IN NUMBER    DEFAULT 0,
                 sqltext_N      IN VARCHAR2  DEFAULT NULL,
                 sqltext_I      IN NUMBER    DEFAULT 0,
                 sqltext_O      IN VARCHAR2  DEFAULT NULL,
                 sqltext_OI     IN NUMBER    DEFAULT 0,
                 lsqltext_N     IN CLOB      DEFAULT NULL,
                 lsqltext_I     IN NUMBER    DEFAULT 0,
                 lsqltext_O     IN CLOB      DEFAULT NULL,
                 lsqltext_OI    IN NUMBER    DEFAULT 0,
                 sqlbind_N      IN VARCHAR2  DEFAULT NULL,
                 sqlbind_I      IN NUMBER    DEFAULT 0,
                 sqlbind_O      IN VARCHAR2  DEFAULT NULL,
                 sqlbind_OI     IN NUMBER    DEFAULT 0,
                 comment$text_N IN VARCHAR2  DEFAULT NULL,
                 comment$text_I IN NUMBER    DEFAULT 0,
                 comment$text_O IN VARCHAR2  DEFAULT NULL,
                 comment$text_OI IN NUMBER   DEFAULT 0,
                 plhol_N        IN LONG      DEFAULT NULL,
                 plhol_I        IN NUMBER    DEFAULT 0,
                 plhol_O        IN LONG      DEFAULT NULL,
                 plhol_OI       IN NUMBER    DEFAULT 0,
                 stmt_type_N    IN NUMBER    DEFAULT NULL,
                 stmt_type_I    IN NUMBER    DEFAULT 0,
                 stmt_type_O    IN NUMBER    DEFAULT NULL,
                 stmt_type_OI   IN NUMBER    DEFAULT 0,
                 ntimestamp#_N  IN TIMESTAMP DEFAULT NULL,
                 ntimestamp#_I  IN NUMBER    DEFAULT 0,
                 ntimestamp#_O  IN TIMESTAMP DEFAULT NULL,
                 ntimestamp#_OI IN NUMBER    DEFAULT 0,
                 proxy$sid_N    IN NUMBER     DEFAULT NULL,
                 proxy$sid_I    IN NUMBER    DEFAULT 0,
                 proxy$sid_O    IN NUMBER    DEFAULT NULL,
                 proxy$sid_OI   IN NUMBER    DEFAULT 0,
                 user$guid_N    IN VARCHAR2  DEFAULT NULL,
                 user$guid_I    IN NUMBER    DEFAULT 0,
                 user$guid_O    IN VARCHAR2  DEFAULT NULL,
                 user$guid_OI   IN NUMBER    DEFAULT 0,
                 instance#_N    IN NUMBER    DEFAULT NULL,
                 instance#_I    IN NUMBER    DEFAULT 0,
                 instance#_O    IN NUMBER    DEFAULT NULL,
                 instance#_OI   IN NUMBER    DEFAULT 0,
                 process#_N     IN VARCHAR2  DEFAULT NULL,
                 process#_I     IN NUMBER    DEFAULT 0,
                 process#_O     IN VARCHAR2  DEFAULT NULL,
                 process#_OI    IN NUMBER    DEFAULT 0,
                 xid_N          IN RAW       DEFAULT NULL, 
                 xid_I          IN NUMBER    DEFAULT 0,
                 xid_O          IN RAW       DEFAULT NULL, 
                 xid_OI         IN NUMBER    DEFAULT 0,
                 auditid_N      IN VARCHAR2  DEFAULT NULL,
                 auditid_I      IN NUMBER    DEFAULT 0,
                 auditid_O      IN VARCHAR2  DEFAULT NULL,
                 auditid_OI     IN NUMBER    DEFAULT 0,
                 statement_N    IN NUMBER    DEFAULT NULL,
                 statement_I    IN NUMBER    DEFAULT 0,
                 statement_O    IN NUMBER    DEFAULT NULL,
                 statement_OI   IN NUMBER    DEFAULT 0,
                 entryid_N      IN NUMBER    DEFAULT NULL,
                 entryid_I      IN NUMBER    DEFAULT 0,
                 entryid_O      IN NUMBER    DEFAULT NULL,
                 entryid_OI     IN NUMBER    DEFAULT 0,
                 dbid_N         IN NUMBER    DEFAULT NULL,
                 dbid_I         IN NUMBER    DEFAULT 0,
                 dbid_O         IN NUMBER    DEFAULT NULL,
                 dbid_OI        IN NUMBER    DEFAULT 0,
                 lsqlbind_N     IN CLOB      DEFAULT NULL,
                 lsqlbind_I     IN NUMBER    DEFAULT 0,
                 lsqlbind_O     IN CLOB      DEFAULT NULL,
                 lsqlbind_OI    IN NUMBER    DEFAULT 0);

PROCEDURE jobins(job_N             IN NUMBER   DEFAULT 0,
                 lowner_N          IN VARCHAR2 DEFAULT NULL,
                 powner_N          IN VARCHAR2 DEFAULT NULL,
                 cowner_N          IN VARCHAR2 DEFAULT NULL,
                 last_date_N       IN DATE     DEFAULT NULL,
                 this_date_N       IN DATE     DEFAULT SYSDATE,
                 next_date_N       IN DATE     DEFAULT SYSDATE,
                 total_N           IN NUMBER   DEFAULT 0,
                 interval#_N       IN VARCHAR2 DEFAULT NULL,
                 failures_N        IN NUMBER   DEFAULT NULL,
                 flag_N            IN NUMBER   DEFAULT 0,
                 what_N            IN VARCHAR2 DEFAULT NULL,
                 nlsenv_N          IN VARCHAR2 DEFAULT NULL,
                 env_N             IN RAW      DEFAULT NULL,
                 cur_ses_label_N   IN MLSLABEL DEFAULT NULL,
                 clearance_hi_N    IN MLSLABEL DEFAULT NULL,
                 clearance_lo_N    IN MLSLABEL DEFAULT NULL,
                 charenv_N         IN VARCHAR2 DEFAULT NULL,
                 field1_N          IN NUMBER   DEFAULT 0);

PROCEDURE jobupd(job_N             IN NUMBER   DEFAULT 0,
                 job_I             IN NUMBER   DEFAULT 0,
                 job_O             IN NUMBER   DEFAULT 0,
                 job_OI            IN NUMBER   DEFAULT 0,
                 lowner_N          IN VARCHAR2 DEFAULT NULL,
                 lowner_I          IN NUMBER   DEFAULT 0,
                 lowner_O          IN VARCHAR2 DEFAULT NULL,
                 lowner_OI         IN NUMBER   DEFAULT 0,
                 powner_N          IN VARCHAR2 DEFAULT NULL,
                 powner_I          IN NUMBER   DEFAULT 0,
                 powner_O          IN VARCHAR2 DEFAULT NULL,
                 powner_OI         IN NUMBER   DEFAULT 0,
                 cowner_N          IN VARCHAR2 DEFAULT NULL,
                 cowner_I          IN NUMBER   DEFAULT 0,
                 cowner_O          IN VARCHAR2 DEFAULT NULL,
                 cowner_OI         IN NUMBER   DEFAULT 0,
                 last_date_N       IN DATE     DEFAULT NULL,
                 last_date_I       IN NUMBER   DEFAULT 0,
                 last_date_O       IN DATE     DEFAULT NULL,
                 last_date_OI      IN NUMBER   DEFAULT 0,
                 this_date_N       IN DATE     DEFAULT SYSDATE,
                 this_date_I       IN NUMBER   DEFAULT 0,
                 this_date_O       IN DATE     DEFAULT SYSDATE,
                 this_date_OI      IN NUMBER   DEFAULT 0,
                 next_date_N       IN DATE     DEFAULT SYSDATE,
                 next_date_I       IN NUMBER   DEFAULT 0,
                 next_date_O       IN DATE     DEFAULT SYSDATE,
                 next_date_OI      IN NUMBER   DEFAULT 0,
                 total_N           IN NUMBER   DEFAULT 0,
                 total_I           IN NUMBER   DEFAULT 0,
                 total_O           IN NUMBER   DEFAULT 0,
                 total_OI          IN NUMBER   DEFAULT 0,
                 interval#_N       IN VARCHAR2 DEFAULT NULL,
                 interval#_I       IN NUMBER   DEFAULT 0,
                 interval#_O       IN VARCHAR2 DEFAULT NULL,
                 interval#_OI      IN NUMBER   DEFAULT 0,
                 failures_N        IN NUMBER   DEFAULT NULL,
                 failures_I        IN NUMBER   DEFAULT 0,
                 failures_O        IN NUMBER   DEFAULT NULL,
                 failures_OI       IN NUMBER   DEFAULT 0,
                 flag_N            IN NUMBER   DEFAULT 0,
                 flag_I            IN NUMBER   DEFAULT 0,
                 flag_O            IN NUMBER   DEFAULT 0,
                 flag_OI           IN NUMBER   DEFAULT 0,
                 what_N            IN VARCHAR2 DEFAULT NULL,
                 what_I            IN NUMBER   DEFAULT 0,
                 what_O            IN VARCHAR2 DEFAULT NULL,
                 what_OI           IN NUMBER   DEFAULT 0,
                 nlsenv_N          IN VARCHAR2 DEFAULT NULL,
                 nlsenv_I          IN NUMBER   DEFAULT 0,
                 nlsenv_O          IN VARCHAR2 DEFAULT NULL,
                 nlsenv_OI         IN NUMBER   DEFAULT 0,
                 env_N             IN RAW      DEFAULT NULL,
                 env_I             IN NUMBER   DEFAULT 0,
                 env_O             IN RAW      DEFAULT NULL,
                 env_OI            IN NUMBER   DEFAULT 0,
                 cur_ses_label_N   IN MLSLABEL DEFAULT NULL,
                 cur_ses_label_I   IN NUMBER   DEFAULT 0,
                 cur_ses_label_O   IN MLSLABEL DEFAULT NULL,
                 cur_ses_label_OI  IN NUMBER   DEFAULT 0,
                 clearance_hi_N    IN MLSLABEL DEFAULT NULL,
                 clearance_hi_I    IN NUMBER   DEFAULT 0,
                 clearance_hi_O    IN MLSLABEL DEFAULT NULL,
                 clearance_hi_OI   IN NUMBER   DEFAULT 0,
                 clearance_lo_N    IN MLSLABEL DEFAULT NULL,
                 clearance_lo_I    IN NUMBER   DEFAULT 0,
                 clearance_lo_O    IN MLSLABEL DEFAULT NULL,
                 clearance_lo_OI   IN NUMBER   DEFAULT 0,
                 charenv_N         IN VARCHAR2 DEFAULT NULL,
                 charenv_I         IN NUMBER   DEFAULT 0,
                 charenv_O         IN VARCHAR2 DEFAULT NULL,
                 charenv_OI        IN NUMBER   DEFAULT 0,
                 field1_N          IN NUMBER   DEFAULT 0,
                 field1_I          IN NUMBER   DEFAULT 0,
                 field1_O          IN NUMBER   DEFAULT 0,
                 field1_OI         IN NUMBER   DEFAULT 0);

PROCEDURE jobdel(job_O             IN NUMBER   DEFAULT 0,
                 lowner_O          IN VARCHAR2 DEFAULT NULL,
                 powner_O          IN VARCHAR2 DEFAULT NULL,
                 cowner_O          IN VARCHAR2 DEFAULT NULL,
                 last_date_O       IN DATE     DEFAULT NULL,
                 this_date_O       IN DATE     DEFAULT SYSDATE,
                 next_date_O       IN DATE     DEFAULT SYSDATE,
                 total_O           IN NUMBER   DEFAULT 0,
                 interval#_O       IN VARCHAR2 DEFAULT NULL,
                 failures_O        IN NUMBER   DEFAULT NULL,
                 flag_O            IN NUMBER   DEFAULT 0,
                 what_O            IN VARCHAR2 DEFAULT NULL,
                 nlsenv_O          IN VARCHAR2 DEFAULT NULL,
                 env_O             IN RAW      DEFAULT NULL,
                 cur_ses_label_O   IN MLSLABEL DEFAULT NULL,
                 clearance_hi_O    IN MLSLABEL DEFAULT NULL,
                 clearance_lo_O    IN MLSLABEL DEFAULT NULL,
                 charenv_O         IN VARCHAR2 DEFAULT NULL,
                 field1_O          IN NUMBER   DEFAULT 0);

PROCEDURE sequpd(obj#_N         IN NUMBER   DEFAULT NULL,
                obj#_I          IN NUMBER   DEFAULT 0,
                obj#_O          IN NUMBER   DEFAULT NULL,  
                obj#_OI         IN NUMBER   DEFAULT 0,
                increment$_N    IN NUMBER   DEFAULT NULL,
                increment$_I    IN NUMBER   DEFAULT 0,
                increment$_O    IN NUMBER   DEFAULT NULL, 
                increment$_OI   IN NUMBER   DEFAULT 0,
                minvalue_N      IN NUMBER   DEFAULT NULL,
                minvalue_I      IN NUMBER   DEFAULT 0,
                minvalue_O      IN NUMBER   DEFAULT NULL, 
                minvalue_OI     IN NUMBER   DEFAULT 0,
                maxvalue_N      IN NUMBER   DEFAULT NULL,
                maxvalue_I      IN NUMBER   DEFAULT 0,
                maxvalue_O      IN NUMBER   DEFAULT NULL, 
                maxvalue_OI     IN NUMBER   DEFAULT 0,
                cycle#_N        IN NUMBER   DEFAULT NULL,
                cycle#_I        IN NUMBER   DEFAULT 0,
                cycle#_O        IN NUMBER   DEFAULT NULL, 
                cycle#_OI       IN NUMBER   DEFAULT 0,
                order$_N        IN NUMBER   DEFAULT NULL,
                order$_I        IN NUMBER   DEFAULT 0,
                order$_O        IN NUMBER   DEFAULT NULL, 
                order$_OI       IN NUMBER   DEFAULT 0,
                cache_N         IN NUMBER   DEFAULT NULL,
                cache_I         IN NUMBER   DEFAULT 0,
                cache_O         IN NUMBER   DEFAULT NULL, 
                cache_OI        IN NUMBER   DEFAULT 0,
                highwater_N     IN NUMBER   DEFAULT NULL,
                highwater_I     IN NUMBER   DEFAULT 0,
                highwater_O     IN NUMBER   DEFAULT NULL, 
                highwater_OI    IN NUMBER   DEFAULT 0,
                audit$_N        IN VARCHAR2 DEFAULT NULL,
                audit$_I        IN NUMBER   DEFAULT 0,
                audit$_O        IN VARCHAR2 DEFAULT NULL,
                audit$_OI       IN NUMBER   DEFAULT 0,
                flags_N         IN NUMBER   DEFAULT NULL,
                flags_I         IN NUMBER   DEFAULT 0,
                flags_O         IN NUMBER   DEFAULT NULL,
                flags_OI        IN NUMBER   DEFAULT 0);

PROCEDURE parins(name_N     IN VARCHAR2,
                 value_N    IN VARCHAR2 DEFAULT NULL,
                 type_N     IN NUMBER   DEFAULT NULL,
                 scn_N      IN NUMBER   DEFAULT NULL,
                 spare1_N   IN NUMBER   DEFAULT NULL,
                 spare2_N   IN NUMBER   DEFAULT NULL,
                 spare3_N   IN VARCHAR2 DEFAULT NULL);

PROCEDURE parupd(name_N     IN VARCHAR2 DEFAULT NULL,
                 name_I     IN NUMBER   DEFAULT 0,
                 name_O     IN VARCHAR2,
                 name_OI    IN NUMBER   DEFAULT 0,
                 value_N    IN VARCHAR2 DEFAULT NULL,
                 value_I    IN NUMBER   DEFAULT 0,
                 value_O    IN VARCHAR2 DEFAULT NULL,
                 value_OI   IN NUMBER   DEFAULT 0,
                 type_N     IN NUMBER   DEFAULT NULL,
                 type_I     IN NUMBER   DEFAULT 0,
                 type_O     IN NUMBER   DEFAULT NULL,
                 type_OI    IN NUMBER   DEFAULT 0,
                 scn_N      IN NUMBER   DEFAULT NULL,
                 scn_I      IN NUMBER   DEFAULT 0,
                 scn_O      IN NUMBER   DEFAULT NULL,
                 scn_OI     IN NUMBER   DEFAULT 0,
                 spare1_N   IN NUMBER   DEFAULT NULL,
                 spare1_I   IN NUMBER   DEFAULT 0,
                 spare1_O   IN NUMBER   DEFAULT NULL,
                 spare1_OI  IN NUMBER   DEFAULT 0,
                 spare2_N   IN NUMBER   DEFAULT NULL,
                 spare2_I   IN NUMBER   DEFAULT 0,
                 spare2_O   IN NUMBER   DEFAULT NULL,
                 spare2_OI  IN NUMBER   DEFAULT 0,
                 spare3_N   IN VARCHAR2 DEFAULT NULL,
                 spare3_I   IN NUMBER   DEFAULT 0,
                 spare3_O   IN VARCHAR2 DEFAULT NULL,
                 spare3_OI  IN NUMBER   DEFAULT 0);

PROCEDURE pardel(name_O     IN VARCHAR2,
                 value_O    IN VARCHAR2 DEFAULT NULL,
                 type_O     IN NUMBER   DEFAULT NULL,
                 scn_O      IN NUMBER   DEFAULT NULL,
                 spare1_O   IN NUMBER   DEFAULT NULL,
                 spare2_O   IN NUMBER   DEFAULT NULL,
                 spare3_O   IN VARCHAR2 DEFAULT NULL);

PROCEDURE hist_synch(dblink IN VARCHAR);

PROCEDURE hstins(stream_sequence#_N   IN NUMBER,
                 lmnr_sid_N           IN NUMBER,
                 dbid_N               IN NUMBER,
                 first_change#_N      IN NUMBER,
                 last_change#_N       IN NUMBER,
                 source_N             IN NUMBER,
                 status_N             IN NUMBER,
                 first_time_N         IN DATE,  
                 last_time_N          IN DATE,
                 dgname_N             IN VARCHAR2,
                 spare1_N             IN NUMBER,
                 spare2_N             IN NUMBER,
                 spare3_N             IN VARCHAR2);

PROCEDURE hstupd(stream_sequence#_N   IN NUMBER   DEFAULT NULL,
                 stream_sequence#_I   IN NUMBER   DEFAULT 0,
                 stream_sequence#_O   IN NUMBER   DEFAULT NULL,
                 stream_sequence#_OI  IN NUMBER   DEFAULT 0,
                 lmnr_sid_N           IN NUMBER   DEFAULT NULL,
                 lmnr_sid_I           IN NUMBER   DEFAULT 0,
                 lmnr_sid_O           IN NUMBER   DEFAULT NULL,
                 lmnr_sid_OI          IN NUMBER   DEFAULT 0,
                 dbid_N               IN NUMBER   DEFAULT NULL,
                 dbid_I               IN NUMBER   DEFAULT 0,
                 dbid_O               IN NUMBER   DEFAULT NULL,
                 dbid_OI              IN NUMBER   DEFAULT 0,
                 first_change#_N      IN NUMBER   DEFAULT NULL,
                 first_change#_I      IN NUMBER   DEFAULT 0,
                 first_change#_O      IN NUMBER   DEFAULT NULL,
                 first_change#_OI     IN NUMBER   DEFAULT 0,
                 last_change#_N       IN NUMBER   DEFAULT NULL,
                 last_change#_I       IN NUMBER   DEFAULT 0,
                 last_change#_O       IN NUMBER   DEFAULT NULL,
                 last_change#_OI      IN NUMBER   DEFAULT 0,
                 source_N             IN NUMBER   DEFAULT NULL,
                 source_I             IN NUMBER   DEFAULT 0,
                 source_O             IN NUMBER   DEFAULT NULL,
                 source_OI            IN NUMBER   DEFAULT 0,
                 status_N             IN NUMBER   DEFAULT NULL,
                 status_I             IN NUMBER   DEFAULT 0,
                 status_O             IN NUMBER   DEFAULT NULL,
                 status_OI            IN NUMBER   DEFAULT 0,
                 first_time_N         IN DATE     DEFAULT NULL,
                 first_time_I         IN NUMBER   DEFAULT 0,
                 first_time_O         IN DATE     DEFAULT NULL, 
                 first_time_OI        IN NUMBER   DEFAULT 0,
                 last_time_N          IN DATE     DEFAULT NULL,
                 last_time_I          IN NUMBER   DEFAULT 0,
                 last_time_O          IN DATE     DEFAULT NULL,
                 last_time_OI         IN NUMBER   DEFAULT 0,
                 dgname_N             IN VARCHAR2 DEFAULT NULL,
                 dgname_I             IN NUMBER   DEFAULT 0,
                 dgname_O             IN VARCHAR2 DEFAULT NULL,
                 dgname_OI            IN NUMBER   DEFAULT 0,
                 spare1_N             IN NUMBER   DEFAULT NULL,
                 spare1_I             IN NUMBER   DEFAULT 0,
                 spare1_O             IN NUMBER   DEFAULT NULL,
                 spare1_OI            IN NUMBER   DEFAULT 0,
                 spare2_N             IN NUMBER   DEFAULT NULL,
                 spare2_I             IN NUMBER   DEFAULT 0,
                 spare2_O             IN NUMBER   DEFAULT NULL,
                 spare2_OI            IN NUMBER   DEFAULT 0,
                 spare3_N             IN VARCHAR2 DEFAULT NULL,
                 spare3_I             IN NUMBER   DEFAULT 0,
                 spare3_O             IN VARCHAR2 DEFAULT NULL,
                 spare3_OI            IN NUMBER   DEFAULT 0);

PROCEDURE hstdel(stream_sequence#_O   IN NUMBER,
                 lmnr_sid_O           IN NUMBER,
                 dbid_O               IN NUMBER,
                 first_change#_O      IN NUMBER,
                 last_change#_O       IN NUMBER,
                 source_O             IN NUMBER,
                 status_O             IN NUMBER,
                 first_time_O         IN DATE,  
                 last_time_O          IN DATE,
                 dgname_O             IN VARCHAR2,
                 spare1_O             IN NUMBER,
                 spare2_O             IN NUMBER,
                 spare3_O             IN VARCHAR2);

PROCEDURE hist_write_record_cancel(caller  in number,
                                   sseq_in in number,
                                   lsid_in in number,
                                   dbid_in in number,
                                   fscn_in in number   default null,
                                   lscn_in in number   default null,
                                   sorc_in in number   default null,
                                   stat_in in number   default null,
                                   ftim_in in date     default null,  
                                   ltim_in in date     default null,
                                   dgnm_in in varchar2 default null);

PROCEDURE hist_write_record_current(caller  in number,
                                    sseq_in in number,
                                    lsid_in in number,
                                    dbid_in in number,
                                    fscn_in in number   default null,
                                    lscn_in in number   default null,
                                    sorc_in in number   default null,
                                    stat_in in number   default null,
                                    ftim_in in date     default null,  
                                    ltim_in in date     default null,
                                    dgnm_in in varchar2 default null);

PROCEDURE hist_write_record_future(caller  in number,
                                   sseq_in in number,
                                   lsid_in in number,
                                   dbid_in in number,
                                   fscn_in in number   default null,
                                   lscn_in in number   default null,
                                   sorc_in in number   default null,
                                   stat_in in number   default null,
                                   ftim_in in date     default null,  
                                   ltim_in in date     default null,
                                   dgnm_in in varchar2 default null);

PROCEDURE hist_write_record_previous(caller  in number,
                                     sseq_in in number,
                                     lsid_in in number,
                                     dbid_in in number,
                                     fscn_in in number   default null,
                                     lscn_in in number   default null,
                                     sorc_in in number   default null,
                                     stat_in in number   default null,
                                     ftim_in in date     default null,  
                                     ltim_in in date     default null,
                                     dgnm_in in varchar2 default null);

PROCEDURE hist_read_record(DMLTYPE                  IN NUMBER DEFAULT 0,
                 	   STREAM_SEQUENCE#_IN      IN NUMBER,
                 	   STREAM_SEQUENCE#_IND     IN NUMBER DEFAULT 0,
                 	   OLDSTREAM_SEQUENCE#_IN   IN NUMBER,
                 	   OLDSTREAM_SEQUENCE#_IND  IN NUMBER DEFAULT 0,
                 	   LMNR_SID_IN              IN NUMBER,
                 	   LMNR_SID_IND             IN NUMBER DEFAULT 0,
                 	   OLDLMNR_SID_IN           IN NUMBER,
                 	   OLDLMNR_SID_IND          IN NUMBER DEFAULT 0,
                 	   DBID_IN                  IN NUMBER,
                 	   DBID_IND                 IN NUMBER DEFAULT 0,
                 	   OLDDBID_IN               IN NUMBER,
                 	   OLDDBID_IND              IN NUMBER DEFAULT 0,
                 	   FIRST_CHANGE#_IN         IN NUMBER,
                 	   FIRST_CHANGE#_IND        IN NUMBER DEFAULT 0,
                 	   OLDFIRST_CHANGE#_IN      IN NUMBER,
                 	   OLDFIRST_CHANGE#_IND     IN NUMBER DEFAULT 0,
                 	   LAST_CHANGE#_IN          IN NUMBER,
                 	   LAST_CHANGE#_IND         IN NUMBER DEFAULT 0,
                 	   OLDLAST_CHANGE#_IN       IN NUMBER,
                 	   OLDLAST_CHANGE#_IND      IN NUMBER DEFAULT 0,
                 	   SOURCE_IN                IN NUMBER,
                 	   SOURCE_IND               IN NUMBER DEFAULT 0,
                 	   OLDSOURCE_IN             IN NUMBER,
                 	   OLDSOURCE_IND            IN NUMBER DEFAULT 0,
                 	   STATUS_IN                IN NUMBER,
                 	   STATUS_IND               IN NUMBER DEFAULT 0,
                 	   OLDSTATUS_IN             IN NUMBER,
                 	   OLDSTATUS_IND            IN NUMBER DEFAULT 0,
                 	   FIRST_TIME_IN            IN DATE,  
                 	   FIRST_TIME_IND           IN NUMBER DEFAULT 0,
                 	   OLDFIRST_TIME_IN         IN DATE,  
                 	   OLDFIRST_TIME_IND        IN NUMBER DEFAULT 0,  
                 	   LAST_TIME_IN             IN DATE,
                 	   LAST_TIME_IND            IN NUMBER DEFAULT 0,
                 	   OLDLAST_TIME_IN          IN DATE,
                 	   OLDLAST_TIME_IND         IN NUMBER DEFAULT 0,
                 	   DGNAME_IN                IN VARCHAR2,
                 	   DGNAME_IND               IN NUMBER DEFAULT 0,
                 	   OLDDGNAME_IN             IN VARCHAR2,
                 	   OLDDGNAME_IND            IN NUMBER DEFAULT 0);

PROCEDURE unsupported_dml(schema_name IN VARCHAR2,
                          object_name IN VARCHAR2);

PROCEDURE skip_support(drop_skip   IN BOOLEAN,
                       errors      IN NUMBER,
                       stmt        IN VARCHAR2,
                       schema_name IN VARCHAR2,
                       object_name IN VARCHAR2,
                       proc_name   IN VARCHAR2,
                       use_likep   IN BOOLEAN,
                       escp        IN VARCHAR2,
                       lsby_admin  IN BOOLEAN);

PROCEDURE skip_transaction(xidusn_p   IN NUMBER,
                           xidslt_p   IN NUMBER,
                           xidsqn_p   IN NUMBER,
                           lsby_admin IN BOOLEAN);

PROCEDURE unskip_transaction(xidusn_p   IN NUMBER,
                             xidslt_p   IN NUMBER,
                             xidsqn_p   IN NUMBER,
                             lsby_admin IN BOOLEAN);

PROCEDURE prepare_instantiation(dblink IN VARCHAR2);
PROCEDURE end_instantiation(dblink IN VARCHAR2);

PROCEDURE report_error(exception_id IN NUMBER);

PROCEDURE retrieve_statement(xidusn_in        IN     NUMBER,
                             xidslt_in        IN     NUMBER,
                             xidsqn_in        IN     NUMBER,
                             errval_in        IN     NUMBER,
                             newstmt_out      OUT    VARCHAR2);
PROCEDURE validate_skip_authid(pname          IN     VARCHAR2,
                               schemaid       OUT    NUMBER);
PROCEDURE validate_skip_action(xidusn_in      IN     NUMBER,
                               xidslt_in      IN     NUMBER,
                               xidsqn_in      IN     NUMBER,
                               newstmt_io     IN OUT VARCHAR2,
                               action_io      IN OUT NUMBER);

PROCEDURE cancel_future;

PROCEDURE need_scn(dblink   IN VARCHAR2,
                   interest OUT BOOLEAN);

FUNCTION get_export_dml_scn(schema      IN     VARCHAR2,
                            tablename   IN     VARCHAR2,
                            cookie      IN     VARCHAR2) RETURN NUMBER;

FUNCTION set_export_scn(ischema   IN   VARCHAR2,
                        iname     IN   VARCHAR2,
                        itype     IN   VARCHAR2,
                        icookie   IN   VARCHAR2,
                        iscn      IN   NUMBER) RETURN BOOLEAN;

FUNCTION matched_primary(dbid   IN NUMBER) RETURN NUMBER;

PROCEDURE wait_for_safe_scn(schema    IN  VARCHAR2,
                            tablename IN  VARCHAR2,
                            timeout   IN  NUMBER,
                            start_scn IN  NUMBER,
                            dbid      IN  NUMBER,
                            safe_scn  OUT NUMBER);

PROCEDURE set_tablespace(new_tablespace IN VARCHAR2);

PROCEDURE replace_dictionary;

PROCEDURE prepare_for_new_primary (former_standby_type IN VARCHAR2, 
                                   dblink              IN VARCHAR2);

FUNCTION purge_logs(session_id    IN NUMBER,
                    purge_scn     IN NUMBER,
                    force         IN NUMBER) RETURN BINARY_INTEGER;


END dbms_internal_logstdby;
/
show errors

-- Revoke execute on DBMS_INTERNAL_LOGSTDBY from logstdby_administrator.
-- If it has already been revoked, do not throw an error. 
-- NOTE: pre-10.2 databases were formerly granted this.
DECLARE
  already_revoked EXCEPTION;
  PRAGMA EXCEPTION_INIT(already_revoked,-01927);
BEGIN
   execute immediate 'REVOKE EXECUTE ON dbms_internal_logstdby FROM logstdby_administrator';
EXCEPTION WHEN already_revoked then null;
END;
/

--
--
-- internal procedures for administering Logical Standby
--
--
CREATE OR REPLACE PACKAGE sys.dbms_internal_safe_scn AUTHID CURRENT_USER IS

PROCEDURE need_scn(dblink        IN     VARCHAR2,
                   dbversion     IN     VARCHAR2,
                   compatibility IN     VARCHAR2,
                   interest      OUT    BOOLEAN,
                   cookie        IN OUT VARCHAR2);


FUNCTION get_export_dml_scn(schema        IN VARCHAR2,
                            tablename     IN VARCHAR2,
                            cookie        IN VARCHAR2,
                            flashback_scn IN NUMBER DEFAULT NULL) RETURN NUMBER;


PROCEDURE set_export_scn(schema          IN   VARCHAR2,
                         name            IN   VARCHAR2,
                         type            IN   VARCHAR2,
                         cookie          IN   VARCHAR2,
                         scn             IN   NUMBER,
                         original_schema IN   VARCHAR2 DEFAULT NULL,
                         original_name   IN   VARCHAR2 DEFAULT NULL);


PROCEDURE set_session_state(cookie IN VARCHAR2);


FUNCTION wait_for_safe_scn(schema    IN VARCHAR2,
                           tablename IN VARCHAR2,
                           timeout   IN VARCHAR2,
                           scn       IN NUMBER,
                           dbid      IN NUMBER) RETURN NUMBER;


FUNCTION matched_primary(dbid IN NUMBER) RETURN NUMBER;


END dbms_internal_safe_scn;
/
show errors
  
GRANT EXECUTE ON dbms_internal_safe_scn TO logstdby_administrator;
GRANT EXECUTE ON dbms_internal_safe_scn TO execute_catalog_role;
/

