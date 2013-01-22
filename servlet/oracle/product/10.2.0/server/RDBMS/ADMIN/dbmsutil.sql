rem 
rem $Header: dbmsutil.sql 15-apr-2005.12:44:59 jmuller Exp $ 
rem 
Rem Copyright (c) 1991, 2005, Oracle. All rights reserved.  
Rem    NAME
Rem      dbmsutil.sql - packages of various utility procedures
Rem    DESCRIPTION
Rem      This file contains various packages:
Rem         dbms_transaction      - transaction commands
Rem         dbms_session          - alter session commands
Rem         dbms_utility          - helpful utilities
Rem         dbms_application_info - application information registration
Rem         dbms_system           - database system level commands (moved to
Rem                                 prvtutil.sql for more obscurity)
Rem         dbms_rowid            - rowid creation and interpretation
Rem         dbms_pclxutil         - intra-partition parallelism for creating 
Rem                                 partition-wise local index.
Rem    RETURNS
Rem 
Rem    NOTES
Rem      Must be run when connected to SYS or INTERNAL.
Rem 
Rem      The procedural option is needed to use these facilities.
Rem
Rem      All of the packages below run with the privileges of calling user,
Rem      rather than the package owner ('sys').
Rem
Rem      The dbms_utility package is run-as-caller (psdicd.c) only for
Rem      its name_resolve, compile_schema and analyze_schema
Rem      procedures.  This package is not run-as-caller
Rem      w.r.t. SQL (psdpgi.c) so that the SQL works correctly (runs as
Rem      SYS).  The privileges are checked via dbms_ddl.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem     jmuller    04/15/05 - Fix bug 3741976: reimplement 
Rem                           dbms_utility.compile_schema in terms of 
Rem                           utl_recomp 
Rem     lvbcheng   03/01/05 - Split DBMS_ASSERT into its own file and add NOOP 
Rem                           enhancement 
Rem     ciyer      12/22/04 - add procedure invalidate to dbms_utility 
Rem     jmuller    08/06/04 - Fix bug 3741707: add reuse_settings parm to 
Rem                           compile_schema 
Rem     smuthuli   06/17/04 - remove dbms_space 
Rem     smuthuli   06/08/04 - change prototype for asa_rec 
Rem     gviswana   05/06/04 - Move dbms_ddl to dbmsddl.sql 
Rem     atsukerm   04/20/04 - add session_trace_enable procedure 
Rem     smuthuli   05/12/04 - auto space advisor 
Rem     abrumm     03/17/04 - DML Error Logging: add dbms_errlog 
Rem     ciyer      01/25/04 - new overload for validate 
Rem     bdagevil   11/01/03 - remove explain plan package 
Rem     nmukherj   10/23/03 - passing single_datapoint_flag as varchar2 in
Rem                           object_growth_trend
Rem     hbaer      10/27/03 - awr support with dbms_xplan 
Rem     smuthuli   10/02/03 - create index cost estimate 
Rem     nmukherj   10/06/03 - added new field in object_growth_trend to return
Rem                           space values as single data points
Rem     smuthuli   10/02/03 - create index cost estimate 
Rem     nmukherj   10/06/03 - added new field in object_growth_trend to return
Rem                           space values as single data points
Rem     smuthuli   10/22/03 - 
Rem     mkandarp   09/02/03 - [3117945] get_hash_value returns error when 
Rem                           hash_size is 0 
Rem     svshah     10/13/03 - dbms_utility.get_sql_hash 
Rem     mkandarp   09/02/03 - [3117945] get_hash_value returns error when 
Rem                           hash_size is 0 
Rem     kmuthukk   07/18/03 - dbms_utility.get_cpu_time
Rem     smuthuli   06/02/03 - fix recommendations
Rem     nwhyte     05/20/03 - Need variant of dbms_space.object_growth_trend()
Rem                           that does not use boolean parameter
Rem     gviswana   04/10/03 - Add dbms_utility.validate
Rem     nwhyte     05/21/03 - Change skip_interpolated parameter in
Rem                           dbms_space.object_growth_trend
Rem     nwhyte     05/20/03 - Need variant of dbms_space.object_growth_trend()
Rem                           that does not use boolean parameter
Rem     gviswana   04/10/03 - Add dbms_utility.validate
Rem     nwhyte     05/16/03 - Add dbms_space.object_growth_trend_cur()
Rem     dbronnik   04/30/03 - Add dbms_utility.format_error_backtrace()
Rem     nwhyte     04/29/03 - Add timeout parameter to
Rem                           dbms_space.object_space_usage and
Rem                           dbms_space.object_growth_trend
Rem     smuthuli   04/22/03 - move shrink APIs here
Rem     nwhyte     03/28/03 - create_table_cost and create_index_cost revisions
Rem     bdagevil   05/09/03 - remove tabs
Rem     mlfeng     05/01/03 - add sqlid to sqlhash
Rem     nwhyte     03/17/03 - Set AUTHID CURRENT_USER for dbms_space package
Rem     nwhyte     12/11/02 - Add dbms_space.object_growth_trend()
Rem     hbaer      12/09/02 - enhanced dbms_xplan
Rem     pamor      12/04/02 - pclxutil: remove private interfaces from public
Rem     nfolkert   12/18/02 - split dbms_index_utl to dbmsidxu.sql
Rem     nwhyte     11/06/02 - Add dbms_space.object_space_usage()
Rem     nfolkert   10/10/02 - change dbms_index_util to dbms_index_utl
Rem     bbaddepu   08/29/02 - ROWID changes for BFT support : ts_type param
Rem     nfolkert   09/23/02 - cleanup index_util
Rem     gtarora    08/22/02 - add get_endianness to dbms_utility
Rem     nfolkert   08/20/02 - dbms_index_util, concurrent parallel idx rebuild
Rem     nwhyte     08/19/02 - Add object growth trend and create table cost
Rem                           to dbms_space
Rem     hbaer      08/09/02 - enhance and fix dbms_xplan
Rem     rvissapr   08/29/02 - fix bug 1810225
Rem     hbaer      05/23/02 - fix errors with dynamic SQL
Rem     bwadding   05/13/02 - Add Hermann's changes to DBMS_XPLAN
Rem     bdagevil   01/22/02 - add dbms_xplan package to display explain plans
Rem     gviswana   11/12/01 - 825066: Add old CURRENT_USER/CURRENT_SCHEMA
Rem     gviswana   10/24/01 - dbms_ddl, dbms_session: AUTHID CURRENT_USER
Rem     eyho       06/26/01 - add check for cluster database mode
Rem     kquinn     07/12/01 - 1875128: Support list parameters
Rem     gviswana   05/24/01 - CREATE OR REPLACE SYNONYM
Rem     kmuthukk   04/04/01 - remove ampersand from comment (#1720152)
Rem     kmuthukk   03/19/01 - add dbms_session.modify_package_state
Rem     cbarclay   11/01/00 - get_transitions_for_daylight_savings_region
Rem     smuthuli   10/09/00 - rename page_table_info as space_usage
Rem     smuthuli   07/14/00 -  add dbms_space.page_table_info
Rem     amganesh   09/10/00  - .
Rem     skabraha   06/01/00  - add create_error_table_for_alter_type
Rem     skabraha   05/30/00  - Add get_dependency to dbms_utility
Rem     elu        05/05/00  - add type maxname_array
Rem     sbalaram   05/03/00  - Add wrapper for is_trigger_fire_once
Rem     liwong     05/02/00  - Fire once trigger support
Rem     rvissapr   03/13/00  - add icd interface to global context
Rem     kquinn     01/18/00  - 895238: Rewrite compile_schema
Rem     nireland   11/19/99  - Add run instructions. #176114
Rem     jarnett    09/23/99 -  bug 951528 - fix dba_pending_transaction
Rem     liwong     08/19/99  - Add canonicalize                                
Rem     liwong     08/03/99  - Overload comma_to_table, table_to_comma
Rem     liwong     08/03/99  - Add lname_array                                 
Rem     gviswana   07/16/99  - Add dbms_utility.get_sql_version
Rem     ssamu      01/04/99 -  fix comment
Rem     akalra     10/30/98  - add parameter to switch_current_consumer_group  
Rem     rsujitha   10/15/98 -  Add dbms_pclxutil package
Rem     mramache   07/27/98 -  update free_unused_user_memory description
Rem     akalra     06/01/98  - Add switch_current_consumer_group for Res. Mgr.
Rem     bnnguyen   06/01/98 -  bug617734
Rem     kquinn     01/02/98 -  603979: Improve analyze_object validation
Rem     ansriniv   04/13/98 -  keep functionality for types
Rem     dmwong     04/02/98  - add set_context and list_context for app ctx    
Rem     nlewis     01/15/98 -  remove mlslabels
Rem     jingliu    12/08/97  - add procedures for job affinity                 
Rem     bnnguyen   09/04/97 -  Fix for bug512637
Rem     amozes     09/09/97 -  allow analyze of a single partition
Rem     najain     07/25/97 -  505485: compiling triggers in compile_schema
Rem     rherwadk   06/28/97 -  document get_parameter_value() ICD
Rem     asgoel     11/20/96 -  Add another plsql table for order_user_objects
Rem     rherwadk   11/07/96 -  move query parameter by name icd to dbms_utility
Rem     ssamu      08/21/96 -  change analyze_part_object
Rem     sgsmith    08/21/96 -  add analyze_part_object
Rem     mmonajje   09/16/96 -  Fixing bug 244014; Adding RESTRICT_REFERENCES pr
Rem     jwijaya    08/16/96 -  add dbms_ddl.alter_table_referenceable
Rem     atsukerm   08/02/96 -  change DBMS_ROWID for DBA unification.
Rem     atsukerm   05/20/96 -  add exceptions to DBMS_ROWID package.
Rem     asgoel     07/22/96 -  Added index_table_type table
Rem     ajasuja    04/25/96 -  merge
Rem     boki       04/22/96 -  merge OBJ into BIG
Rem     gpongrac   01/31/96 -  move dbms_application_info to separate file
Rem     atsukerm   03/07/96 -  add ROWID migration function to DBMS_ROWID.
Rem     atsukerm   02/29/96 -  space support for partitions.
Rem     boki       03/27/96 -  merge OBJ_960326
Rem     boki       03/13/96 -  merge from big 0228
Rem     hasun      01/29/96 -  Add procedure db_version()
Rem     ssamu      12/21/95 -  fix another typo
Rem     ssamu      12/21/95 -  fix typo
Rem     sjain      12/20/95 -  Move dbms_system to prvtutil.
Rem     atsukerm   11/15/95 -  new ROWID format - restricted/extended only
Rem     atsukerm   10/24/95 -  new ROWID format - add DBMS_ROWID package.
Rem     ssamu      10/19/95 -  add pragma for data_block_address_file
Rem     rtaranto   08/04/95 -  merge changes from branch 1.50.720.2
Rem     rtaranto   07/12/95 -  Add dbms_utility.get_hash_value
Rem     hrizvi     04/03/95 -  merge changes from branch 1.50.725.2
Rem     jarnett    01/03/95 -  add procedure purge_lost_db_entry
Rem     bhirano    12/23/94 -  merge changes from branch 1.50.720.1
Rem     hjakobss   10/12/94 -  analyze_schema support for histograms
Rem     hrizvi     02/03/95 -  add dist_txn_sync to dbms_system
Rem     bhirano    12/23/94 -  merge changes from branch 1.41.710.6
Rem     jloaiza    09/06/94 -  dbms_registration -> dbms_application_info
Rem     atsukerm   06/20/94 -  adding DBMS_SPACE package
Rem     jloaiza    06/08/94 -  change name to dbms_registration
Rem     jloaiza    04/07/94 -  add dbms_application
Rem     dsdaniel   04/07/94 -  merge changes from branch 1.41.710.4
Rem     wmaimone   04/07/94 -  merge changes from branch 1.41.710.5
Rem     adowning   03/29/94 -  merge changes from branch 1.41.710.3
Rem     wmaimone   02/07/94 -  add set close_cached_open_cursors to dbms_sessio
Rem     dsdaniel   02/04/94 -  dbms_util.port_string icd
Rem     adowning   02/02/94 -  split file into public / private binary files
Rem     rjenkins   11/17/93 -  merge changes from branch 1.41.710.2
Rem     rjenkins   10/20/93 -  merge changes from branch 1.41.710.1
Rem     rjenkins   10/28/93 -  make comma_to_table more consistent
Rem     rjenkins   10/12/93 -  adding comma_to_table
Rem     rjenkins   09/03/93 -  adding name_parse
Rem     hjakobss   07/15/93 -  bug 170473
Rem     hjakobss   07/13/93 -  bug 169577
Rem     dsdaniel   03/12/93 -  local_tid, step_id functions for replication  
Rem     mmoore     01/11/93 -  merge changes from branch 1.37.312.1 
Rem     mmoore     01/05/93 - #(145287) add another exception for discrete mode
Rem     mmoore     12/11/92 -  disable set_role in stored procs 
Rem     rkooi      11/24/92 -  fixes per Peter 
Rem     rkooi      11/21/92 -  get rid of error argument to name_resolve 
Rem     tpystyne   11/20/92 -  fix compile_all and analyze_schema 
Rem     rkooi      11/16/92 -  fix set_label 
Rem     rkooi      11/16/92 -  fix comments 
Rem     rkooi      11/13/92 -  add name_res procedure 
Rem     tpystyne   11/07/92 -  make analyze parameters optional 
Rem     mmoore     11/04/92 -  add new analyze options 
Rem     ghallmar   11/03/92 -  add dbms_transaction.purge_mixed 
Rem     rkooi      10/30/92 -  get rid of caller_id and unique_stmt_id 
Rem     rkooi      10/26/92 -  owner -> schema for SQL2 
Rem     rkooi      10/25/92 -  bug 135880 
Rem     mmoore     10/13/92 - #(131686) change messages 2074,4092,0034 
Rem     rkooi      10/02/92 -  compile_all fix 
Rem     mmoore     10/02/92 -  change pls_integer to binary_integer 
Rem     tpystyne   10/01/92 -  fix Bob's mistakes 
Rem     tpystyne   09/28/92 -  disallow commit/rollback force in rpc and trigge
Rem     mmoore     09/25/92 - #(130566) don't allow set_nls or set_role in trig
Rem     tpystyne   09/23/92 -  rename analyze to analyze_object 
Rem     rkooi      08/24/92 -  handle delimited id's in alter_compile 
Rem     tpystyne   08/06/92 -  add analyze_schema 
Rem     epeeler    07/29/92 -  add function to get time 
Rem     rkooi      06/25/92 -  workaround pl/sql bug with 'in' in SQL
Rem     rkooi      06/03/92 -  add 'get unique session id' 
Rem     jcohen     05/28/92 -  add = to alter session set label 
Rem     jloaiza    05/12/92 -  add discrete 
Rem     rkooi      04/22/92 -  put in checks for execute_sql for triggs, stored
Rem     mmoore     04/14/92 -  move begin_oltp to package transaction 
Rem     rkooi      04/06/92 -  merge changes from branch 1.4.300.1 
Rem     rkooi      04/01/92 -  Creation - split/recombined from other files
Rem     mroberts   02/21/92 -  call alter_compile, not sql_ddl 
Rem     rkooi      02/06/92 -  testing 
Rem     rkooi      02/03/92 -  compilation errors 
Rem     rkooi      01/16/92 -  Creation 

REM ********************************************************************
REM THESE PACKAGES MUST NOT BE MODIFIED BY THE CUSTOMER.  DOING SO
REM COULD CAUSE INTERNAL ERRORS AND SECURITY VIOLATIONS IN THE
REM RDBMS.  SPECIFICALLY, THE PSD* AND EXECUTE_SQL ROUTINES MUST NOT BE
REM CALLED DIRECTLY BY ANY CLIENT AND MUST REMAIN PRIVATE TO THE PACKAGE BODY.
REM ********************************************************************

create or replace package dbms_transaction AUTHID CURRENT_USER is

  ------------
  --  OVERVIEW
  --
  --  This package provides access to SQL transaction statements from
  --  stored procedures.
  --  It also provids functions for monitoring transaction activities
  --  (transaction ids and ordering of steps of transactions )

  ----------------------------
  --  PROCEDURES AND FUNCTIONS
  --
  procedure read_only;
  --  Equivalent to SQL "SET TRANSACTION READ ONLY"
  procedure read_write;
  --  Equivalent to SQL "SET TRANSACTION READ WRITE"
  procedure advise_rollback;
  --  Equivalent to SQL "ALTER SESSION ADVISE ROLLBACK"
  procedure advise_nothing;
  --  Equivalent to SQL "ALTER SESSION ADVISE NOTHING"
  procedure advise_commit;
  --  Equivalent to SQL "ALTER SESSION ADVISE COMMIT"
  procedure use_rollback_segment(rb_name varchar2);
  --  Equivalent to SQL "SET TRANSACTION USE ROLLBACK SEGMENT <rb_seg_name>"
  --  Input arguments:
  --    rb_name
  --      Name of rollback segment to use.
  procedure commit_comment(cmnt varchar2);
  --  Equivalent to SQL "COMMIT COMMENT <text>"
  --  Input arguments:
  --    cmnt
  --      Comment to assoicate with this comment.
  procedure commit_force(xid varchar2, scn varchar2 default null);
  --  Equivalent to SQL "COMMIT FORCE <text>, <number>"
  --  Input arguments:
  --    xid
  --      Local or global transaction id.
  --    scn
  --      System change number.
  procedure commit;
    pragma interface (C, commit);                          -- 1 (see psdicd.c)
  --  Equivalent to SQL "COMMIT".  Here for completeness.  This is
  --    already implemented as part of PL/SQL.
  procedure savepoint(savept varchar2);
    pragma interface (C, savepoint);                       -- 2 (see psdicd.c)
  --  Equivalent to SQL "SAVEPOINT <savepoint_name>".  Here for
  --    completeness. This is already implemented as part of PL/SQL.
  --  Input arguments:
  --    savept
  --      Savepoint identifier.
  procedure rollback;
    pragma interface (C, rollback);                        -- 3 (see psdicd.c)
  --  Equivalent to SQL "ROLLBACK".  Here for completeness. This is 
  --    already implemented as part of PL/SQL.
  procedure rollback_savepoint(savept varchar2);
    pragma interface (C, rollback_savepoint);              -- 4 (see psdicd.c)
  --  Equivalent to SQL "ROLLBACK TO SAVEPOINT <savepoint_name>".  Here for
  --    completeness. This is already implemented as part of PL/SQL.
  --  Input arguments:
  --    savept
  --      Savepoint identifier.
  procedure rollback_force(xid varchar2);
  --  Equivalent to SQL "ROLLBACK FORCE <text>"
  --  Input arguments:
  --    xid
  --      Local or global transaction id.
  procedure begin_discrete_transaction;
    pragma interface (C, begin_discrete_transaction);      -- 5 (see psdicd.c)
  --  Set "discrete transaction mode" for this transaction.
  --  Exceptions:
  --    ORA-08175 will be generated if a transaction attempts an operation 
  --      which cannot be performed as a discrete transaction.  If this 
  --      exception is encountered, rollback and retry the transaction.

  --    ORA-08176 will be generated if a transaction encounters data changed 
  --      by an operation that does not generate rollback data : create index,
  --      direct load or discrete transaction.  If this exception is
  --      encountered, retry the operation that received the exception.
  --    
  DISCRETE_TRANSACTION_FAILED exception;
    pragma exception_init(DISCRETE_TRANSACTION_FAILED, -8175);

  CONSISTENT_READ_FAILURE exception;
    pragma exception_init(CONSISTENT_READ_FAILURE, -8176);

  procedure purge_mixed(xid varchar2);
  --  When indoubt transactions are forced to commit or rollback (instead of
  --    letting automatic recovery resolve their outcomes), there is a
  --    possibility that a transaction can have a mixed outcome: some sites
  --    commit, and others rollback.  Such inconsistency cannot be resolved
  --    automatically by ORACLE; however, ORACLE will flag entries in
  --    DBA_2PC_PENDING by setting the MIXED column to a value of 'yes'.
  --    ORACLE will never automatically delete information about a mixed
  --    outcome transaction.  When the application or DBA is sure all
  --    inconsistencies that might have arisen as a result of the mixed
  --    transaction have been resolved, this procedure can be used to
  --    delete the information about a given mixed outcome transaction.
  --  Input arguments:
  --    xid
  --      This must be set to the value of the LOCAL_TRAN_ID column in 
  --      the DBA_2PC_PENDING table.

  procedure purge_lost_db_entry(xid varchar2);
  --  When a failure occurs during commit processing, automatic recovery will
  --    consistently resolve the results at all sites involved in the 
  --    transaction.  However, if the remote database is destroyed or 
  --    recreated before recovery completes, then the entries used to 
  --    control recovery in DBA_2PC_PENDING and associated tables will never
  --    be removed, and recovery will periodically retry.  Procedure 
  --    purge_lost_db_entry allows removal of such transactions from the 
  --    local site.

  --  WARNING: purge_lost_db_entry should ONLY be used when the other
  --  database is lost or has been recreated.  Any other use may leave the
  --  other database in an unrecoverable or inconsistent state.

  --    Before automatic recovery runs, the transaction may show 
  --    up in DBA_2PC_PENDING as state "collecting", "committed", or
  --    "prepared".  If the DBA has forced an in-doubt transaction to have
  --    a particular result by using "commit force" or "rollback force",
  --    then states "forced commit" or "forced rollback" may also appear.  
  --    Automatic recovery will normally delete entries in any of these 
  --    states.  The only exception is when recovery finds a forced
  --    transaction which is in a state inconsistent with other sites in the 
  --    transaction;  in this case, the entry will be left in the table
  --    and the MIXED column will have a value 'yes'.

  --    However, under certain conditions, it may not be possible for 
  --    automatic recovery to run.  For example, a remote database may have 
  --    been permanently lost.  Even if it is recreated, it will get a new 
  --    database id, so that recovery cannot identify it (a possible symptom 
  --    is ORA-02062).  In this case, the DBA may use the procedure 
  --    purge_lost_db_entry to clean up the entries in any state other 
  --    than "prepared".  The DBA does not need to be in any particular 
  --    hurry to resolve these entries, since they will not be holding any 
  --    database resources.
  
  --    The following table indicates what the various states indicate about
  --    the transaction and what the DBA actions should be:

  --    State       State of     State of     Normal Alternative
  --    Column      Global       Local        DBA    DBA 
  --                Transaction  Transaction  Action Action
  --    ----------  ------------ ------------ ------ ---------------
  --    collecting  rolled back  rolled back  none   purge_lost_db_entry (1)
  --    committed   committed    committed    none   purge_lost_db_entry (1)
  --    prepared    unknown      prepared     none   force commit or rollback
  --    forced      unknown      committed    none   purge_lost_db_entry (1)
  --      commit
  --    forced      unknown      rolled back  none   purge_lost_db_entry (1)
  --      rollback
  --    forced      mixed        committed    (2)
  --      commit
  --      (mixed)                              
  --    forced      mixed        rolled back  (2)
  --      rollback
  --      (mixed)                             
   
  --    Note 1: Use only if significant reconfiguration has occurred so that
  --      automatic recovery cannot resolve the transaction.  Examples are
  --      total loss of the remote database, reconfiguration in software
  --      resulting in loss of two-phase commit capability, or loss of 
  --      information from an external transaction coordinator such as a TP
  --      Monitor.
  --    Note 2: Examine and take any manual action to remove inconsistencies, 
  --      then use the procedure purge_mixed.
  --  Input arguments:
  --    xid
  --      This must be set to the value of the LOCAL_TRAN_ID column in
  --      the DBA_2PC_PENDING table.

  FUNCTION local_transaction_id(create_transaction BOOLEAN := FALSE)
    RETURN VARCHAR2;
  --  Return local (to instance) unique identfier for current transaction
  --  Return null if there is no current transction.
  --  Input parameters:
  --     create_transaction 
  --       If true , start a transaciton if one is not currently 
  --       active.
  --
  FUNCTION step_id RETURN NUMBER;
  --  Return local (to local transaction ) unique positive integer that orders
  --  The DML operations of a transaction.
  --  Input parmaeters:

end;
/
create or replace public synonym dbms_transaction for sys.dbms_transaction
/
grant execute on dbms_transaction to public
/

create or replace package dbms_session AUTHID CURRENT_USER is
  ------------
  --  OVERVIEW
  --
  --  This package provides access to SQL "alter session" statements, and
  --  other session information from, stored procedures.

  ----------------------------
  --  PROCEDURES AND FUNCTIONS
  --
  procedure set_role(role_cmd varchar2);
  --  Equivalent to SQL "SET ROLE ...".
  --  Input arguments:
  --    role_cmd
  --      This text is appended to "set role " and then executed as SQL.
  procedure set_sql_trace(sql_trace boolean);
  --  Equivalent to SQL "ALTER SESSION SET SQL_TRACE ..."
  --  Input arguments:
  --    sql_trace
  --      TRUE or FALSE.  Turns tracing on or off.
  procedure set_nls(param varchar2, value varchar2);
  --  Equivalent to SQL "ALTER SESSION SET <nls_parameter> = <value>"
  --  Input arguments:
  --    param
  --      The NLS parameter. The parameter name must begin with 'NLS'.
  --    value
  --      The value to set the parameter to.  If the parameter is a
  --      text literal then it will need embedded single-quotes.  For
  --      example "set_nls('nls_date_format','''DD-MON-YY''')"
  procedure close_database_link(dblink varchar2);
  --  Equivalent to SQL "ALTER SESSION CLOSE DATABASE LINK <name>"
  --  Input arguments:
  --    name
  --      The name of the database link to close.
  procedure reset_package;
  --  Deinstantiate all packages in this session.  In other words, free
  --    all package state.  This is the situation at the beginning of
  --    a session.

  --------------------------------------------------------------------
  --  action_flags (bit flags) for MODIFY_PACKAGE_STATE  procedure ---
  --------------------------------------------------------------------
  FREE_ALL_RESOURCES   constant PLS_INTEGER := 1;
  REINITIALIZE         constant PLS_INTEGER := 2;
  
  procedure modify_package_state(action_flags IN PLS_INTEGER);
  --  The MODIFY_PACKAGE_STATE procedure can be used to perform
  --  various actions (as specified by the 'action_flags' parameter)
  --  on the session state of ALL PL/SQL program units active in the
  --  session. This takes effect only after the PL/SQL call that
  --  made the current invokation finishes running.
  --
  --  Parameter(s):
  --   action_flags:
  --     Determines what action is taken on the program units.
  --     The following action_flags are supported:
  --
  --     * DBMS_SESSION.FREE_ALL_RESOURCES:
  --         This frees all the memory associated with each of the
  --         previously run PL/SQL programs from the session, and,
  --         consequently, clears the current values of any package
  --         globals and closes any cached cursors. On subsequent use,
  --         the PL/SQL program units are re-instantiated and package
  --         globals are reinitialized. This is essentially the
  --         same as DBMS_SESSION.RESET_PACKAGE() interface.
  --
  --     * DBMS_SESSION.REINITIALIZE:
  --         In terms of program semantics, the DBMS_SESSION.REINITIALIZE
  --         flag is similar to the DBMS_SESSION.FREE_ALL_RESOURCES flag
  --         in that both have the effect of re-initializing all packages.
  --
  --         However, DBMS_SESSION.REINITIALIZE should exhibit much better
  --         performance than the DBMS_SESSION.FREE_ALL_RESOURCES option
  --         because:
  -- 
  --           - packages are reinitialized without actually being freed
  --           and recreated from scratch. Instead the package memory gets
  --           reused.
  --
  --           - any open cursors are closed, semantically speaking. However,
  --           the cursor resource is not actually freed. It is simply
  --           returned to the PL/SQL cursor cache. And more importantly,
  --           the cursor cache is not flushed. Hence, cursors
  --           corresponding to frequently accessed static SQL in PL/SQL
  --           will remain cached in the PL/SQL cursor cache and the
  --           application will not incur the overhead of opening, parsing
  --           and closing a new cursor for those statements on subsequent use.
  --
  --           - the session memory for PL/SQL modules without global state
  --           (such as types, stored-procedures) will not be freed and
  --           recreated.
  --
  --
  --  Usage Example:
  --    begin
  --      dbms_session.modify_package_state(DBMS_SESSION.REINITIALIZE);
  --    end;
  --
  
  function unique_session_id return varchar2;
  pragma restrict_references(unique_session_id,WNDS,RNDS,WNPS);
  --  Return an identifier that is unique for all sessions currently
  --    connected to this database.  Multiple calls to this function 
  --    during the same session will always return the same result.
  --  Output arguments:
  --    unique_session_id
  --      can return up to 24 bytes.
  function is_role_enabled(rolename varchar2) return boolean;
  --  Determine if the named role is enabled for this session.
  --  Input arguments:
  --    rolename
  --      Name of the role.
  --  Output arguments:
  --    is_role_enabled
  --      TRUE or FALSE depending on whether the role is enabled.
  function is_session_alive(uniqueid varchar2) return boolean;
  --  Determine if the specified session is alive.
  --  Input arguments:
  --    uniqueid
  --      Uniqueid of the session.
  --  Output arguments:
  --    is_session_alive
  --      TRUE or FALSE depending on whether the session is alive.
  procedure set_close_cached_open_cursors(close_cursors boolean);
  --  Equivalent to SQL "ALTER SESSION SET CLOSE_CACHED_OPEN_CURSORS ..."
  --  Input arguments:
  --    close_cursors
  --      TRUE or FALSE.  Turns close_cached_open_cursors on or off.
  procedure free_unused_user_memory;
  --  Procedure for users to reclaim unused memory after performing operations
  --  requiring large amounts of memory (where large is >100K).  Note that 
  --  this procedure should only be used in cases where memory is at a 
  --  premium.  
  --
  --  Examples operations using lots of memory are:
  -- 
  --     o  large sorts where entire sort_area_size is used and
  --        sort_area_size is hundreds of KB
  --     o  compiling large PL/SQL packages/procedures/functions
  --     o  storing hundreds of KB of data within PL/SQL indexed tables
  --
  --  One can monitor user memory by tracking the statistics 
  --  "session uga memory" and "session pga memory" in the 
  --  v$sesstat/v$statname fixed views.  Monitoring these statistics will
  --  also show how much memory this procedure has freed.
  --
  --  The behavior of this procedure depends upon the configuration of the 
  --  server operating on behalf of the client:
  --  
  --     o  dedicated server - returns unused PGA memory and session memory
  --          to the OS (session memory is allocated from the PGA in this 
  --          configuration)
  --     o  MTS server       - returns unused session memory to the
  --          shared_pool (session memory is allocated from the shared_pool
  --          in this configuration)
  --  
  --  In order to free memory using this procedure, the memory must 
  --  not be in use.  
  -- 
  --  Once an operation allocates memory, only the same type of operation can 
  --  reuse the allocated memory.  For example, once memory is allocated 
  --  for sort, even if the sort is complete and the memory is no longer 
  --  in use, only another sort can reuse the sort-allocated memory.  For
  --  both sort and compilation, after the operation is complete, the memory
  --  is no longer in use and the user can invoke this procedure to free the
  --  unused memory. 
  --
  --  An indexed table implicitly allocates memory to store values assigned
  --  to the indexed table's elements.  Thus, the more elements in an indexed 
  --  table, the more memory the RDBMS allocates to the indexed table.  As 
  --  long as there are elements within the indexed table, the memory
  --  associated with an indexed table is in use. 
  -- 
  --  The scope of indexed tables determines how long their memory is in use. 
  --  Indexed tables declared globally are indexed tables declared in packages
  --  or package bodies.  They allocate memory from session memory.  For an
  --  indexed table declared globally, the memory will remain in use
  --  for the lifetime of a user's login (lifetime of a user's session),
  --  and is freed after the user disconnects from ORACLE.
  --     
  --  Indexed tables declared locally are indexed tables declared within
  --  functions, procedures, or anonymous blocks.  These indexed tables
  --  allocate memory from PGA memory.  For an indexed table declared 
  --  locally, the memory will remain in use for as long as the user is still
  --  executing the procedure, function, or anonymous block in which the 
  --  indexed table is declared.  After the procedure, function, or anonymous
  --  block is finished executing, the memory is then available for other 
  --  locally declared indexed tables to use (i.e., the memory is no longer
  --  in use).
  --  
  --  Assigning an uninitialized, "empty," indexed table to an existing index
  --  table is a method to explicitly re-initialize the indexed table and the
  --  memory associated with the indexed table.  After this operation,
  --  the memory associated with the indexed table will no longer be in use, 
  --  making it available to be freed by calling this procedure.  This method
  --  is particularly useful on indexed tables declared globally which can grow
  --  during the lifetime of a user's session, as long as the user no 
  --  longer needs the contents of the indexed table.  
  --  
  --  The memory rules associated with an indexed table's scope still apply; 
  --  this method and this procedure, however, allow users to 
  --  intervene and to explictly free the memory associated with an
  --  indexed table. 
  -- 
  --  The PL/SQL fragment below illustrates the method and the use 
  --  of procedure free_unused_user_memory.
  --
  --  create package foobar
  --     type number_idx_tbl is table of number indexed by binary_integer;
  -- 
  --     store1_table  number_idx_tbl;     --  PL/SQL indexed table
  --     store2_table  number_idx_tbl;     --  PL/SQL indexed table
  --     store3_table  number_idx_tbl;     --  PL/SQL indexed table
  --     ...
  --  end;            --  end of foobar
  --
  --  declare
  --     ...
  --     empty_table   number_idx_tbl;     --  uninitialized ("empty") version
  --  
  --  begin
  --     for i in 1..1000000 loop
  --       store1_table(i) := i;           --  load data
  --     end loop;
  --     ...
  --     store1_table := empty_table;      --  "truncate" the indexed table
  --     ... 
  --     -
  --     dbms_session.free_unused_user_memory;  -- give memory back to system
  --  
  --     store1_table(1) := 100;           --  index tables still declared;
  --     store2_table(2) := 200;           --  but truncated.
  --     ...
  --  end;
  -- 
  --  Performance Implication: 
  --     This routine should be used infrequently and judiciously.
  --       
  --  Input arguments:
  --     n/a
  procedure set_context(namespace varchar2, attribute varchar2, value varchar2, username varchar2 default null, client_id varchar2 default null);
  --  Input arguments:
  --    namespace
  --      Name of the namespace to use for the application context
  --    attribute
  --      Name of the attribute to be set
  --    value
  --      Value to be set
  --    username
  --      username attribute for application context . default value is null. 
  --    client_id
  --      client identifier that identifies a user session for which we need
  --      to set this context.
  --
  --
  procedure set_identifier(client_id varchar2);
  --    Input parameters: 
  --    client_id
  --      client identifier being set for this session .
  --
  --
  procedure clear_context(namespace varchar2, client_id varchar2 default null, attribute varchar2 default null);
  -- Input parameters:
  --   namespace
  --     namespace where the application context is to be cleared 
  --   client_id 
  --      all ns contexts associated with this client id are cleared.
  --   attribute
  --     attribute to clear . 
  
  procedure clear_all_context(namespace varchar2);
  --
  -- Input parameters:
  --    namespace
  --      namespace where the application context is to be cleared
  --
  procedure clear_identifier;
  -- Input parameters:
  --   none
  --
  TYPE AppCtxRecTyp IS RECORD ( namespace varchar2(30), attribute varchar2(30), 
      value varchar2(4000));
  TYPE AppCtxTabTyp IS TABLE OF AppCtxRecTyp INDEX BY BINARY_INTEGER;
  procedure list_context(list OUT AppCtxTabTyp, lsize OUT number);
  --  Input arguments:
  --    list
  --      buffer to store a list of application context set in current
  --      session
  --  Output arguments:
  --    list
  --      contains a list of of (namespace,attribute,values) set in current
  --      session
  --    size
  --      returns the number of entries in the buffer returned
  procedure switch_current_consumer_group(new_consumer_group IN VARCHAR2,
                                          old_consumer_group OUT VARCHAR2,
                                          initial_group_on_error IN BOOLEAN);
  -- Input arguments:
  -- new_consumer_group
  --    name of consumer group to switch to
  -- old_consumer_group
  --    name of the consumer group just switched out from
  -- initial_group_on_error
  --   If TRUE, sets the current consumer group of the invoker to his/her 
  --   initial consumer group in the event of an error.
  -- 
  procedure session_trace_enable(waits IN BOOLEAN DEFAULT TRUE,
                                 binds IN BOOLEAN DEFAULT FALSE);
  --  Enables SQL trace for the session. Supports waits and binds
  --  specifications, which makes it more general than set_sql_trace. Using 
  --  this procedure is a preferred way in the future.
  --  Input parameters:
  --    waits
  --      If TRUE, wait information will be present in the trace
  --    binds
  --      If TRUE, bind information will be present in the trace
  procedure session_trace_disable;
  --  Disables SQL trace for the session, which has been enabled by the
  --  session_trace_enable procedure
  -- Input parameters:
  --   none
  --
end;
/

create or replace public synonym dbms_session for sys.dbms_session
/
grant execute on dbms_session to public
/

create or replace package dbms_utility is
  ------------
  --  OVERVIEW
  --
  --  This package provides various utility routines.

  ----------------------------
  --  PL/SQL TABLES
  --
  type uncl_array IS table of VARCHAR2(227) index by BINARY_INTEGER;
  --  Lists of "USER"."NAME"."COLUMN"@LINK should be stored here

  type name_array IS table of VARCHAR2(30) index by BINARY_INTEGER;
  --  Lists of NAME should be stored here

  type lname_array IS table of VARCHAR2(4000) index by BINARY_INTEGER;
  --  Lists of Long NAME should be stored here, it includes fully
  --  qualified attribute names.

  type maxname_array IS table of VARCHAR2(32767) index by BINARY_INTEGER;
  --  Lists of large VARCHAR2s should be stored here

  type dblink_array IS table of VARCHAR2(128) index by BINARY_INTEGER;
  --  Lists of database links should be stored here
  
  TYPE index_table_type IS TABLE OF BINARY_INTEGER INDEX BY BINARY_INTEGER;
  --  order in which objects should be generated is returned here
  
  TYPE number_array IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  --  order in which objects should be generated is returned here for users.
  TYPE instance_record IS RECORD (
       inst_number   NUMBER,
       inst_name     VARCHAR2(60));
  
  TYPE instance_table IS TABLE OF instance_record INDEX BY BINARY_INTEGER;
  -- list of active instance number and instance name
  -- the starting index of instance_table is 1
  -- instance_table is dense
  
  TYPE anydata_array IS TABLE OF AnyData INDEX BY BINARY_INTEGER;
  -- array of anydata 

  SUBTYPE maxraw IS RAW(32767);
  
  ----------------------------
  --  PROCEDURES AND FUNCTIONS
  --
  procedure compile_schema(schema varchar2, compile_all boolean default TRUE,
                           reuse_settings boolean default FALSE);
  --  Compile all procedures, functions, packages and triggers in the specified
  --  schema.  After calling this procedure you should select from view
  --  ALL_OBJECTS for items with status of 'INVALID' to see if all objects
  --  were successfully compiled.  You may use the command "SHOW ERRORS
  --  <type> <schema>.<name>" to see the errors assocated with 'INVALID'
  --  objects.
  --  Input arguments:
  --    schema
  --      Name of the schema.
  --    compile_all
  --      This is a boolean flag that indicates whether we should compile all
  --      schema objects or not, regardless of whether the object is currently
  --      flagged as valid or not. The default is to support the previous
  --      compile_schema() behaviour and compile ALL objects.  
  --    reuse_settings
  --      This is a boolean flag that indicates whether the session settings in
  --      the objects should be reused, or whether the current session settings
  --      should be picked up instead.
  --  Exceptions:
  --    ORA-20000: Insufficient privileges for some object in this schema.
  --    ORA-20001: Cannot recompile SYS objects.

   /*
    * NAME:
    *   validate
    *
    * PARAMETERS:
    *   object_id  (IN) - ID number of object to be validated. This is
    *                     the same as the value of the OBJECT_ID column
    *                     from ALL_OBJECTS.
    *
    * DESCRIPTION:
    *   This procedure validates a database object if it is in status
    *   4, 5, or 6 using the same mechanism that is used for automatic
    *   re-validation.
    *
    * EXCEPTIONS:
    *   None. No errors are raised if the object doesn't exist or is
    *   already valid or is an object that cannot be validated.
    */
  procedure validate(object_id number);

   /*
    * NAME:
    *   validate
    *
    * PARAMETERS:
    *   owner     (IN) - name of the user who owns the object. Same as
    *                    the OWNER field in ALL_OBJECTS
    *   objname   (IN) - name of the object to be validated. Same as the
    *                    OBJECT_NAME field in ALL_OBJECTS
    *   namespace (IN) - namespace of the object. Same as the namespace
    *                    field in obj$
    *
    * DESCRIPTION:
    *   This procedure validates a database object using the same
    *   mechanism that is used for automatic re-validation.
    *
    * EXCEPTIONS:
    *   None. No errors are raised if the object doesn't exist or is
    *   already valid or is an object that cannot be validated.
    */
  procedure validate(owner varchar2, objname varchar2, namespace number);

  inv_not_exist_or_no_priv exception;
  pragma exception_init(inv_not_exist_or_no_priv, -24237);

  inv_malformed_settings exception;
  pragma exception_init(inv_malformed_settings, -24238);

  inv_restricted_object exception;
  pragma exception_init(inv_restricted_object, -24239);

  /*
   * Option flags supported by invalidate.
   *   inv_error_on_restrictions - The invalidate routine imposes various
   *   restrictions on the objects that can be invalidated. For example,
   *   the object specified by p_object_id cannot be a table. By default,
   *   invalidate quietly returns on these conditions (and does not raise
   *   an exception). If the caller sets this flag, the exception
   *   inv_restricted_object is raised.
   */
  inv_error_on_restrictions constant pls_integer := 1;

   /*
    * NAME:
    *   invalidate
    *
    * PARAMETERS:
    *   p_object_id (IN)
    *     ID number of object to be invalidated. This is the same as the
    *     value of the OBJECT_ID column from ALL_OBJECTS.
    *
    *     If the object_id argument is null or invalid then the exception
    *     inv_not_exist_or_no_priv is raised.
    *
    *     The caller of this procedure must have create privileges on the
    *     object being invalidated else inv_not_exist_or_no_priv exception
    *     is raised.
    *
    *   p_plsql_object_settings (IN)
    *     This optional parameter is ignored if the object specified by
    *     p_object_id is not a PL/SQL object.
    *
    *     If no value is specified for this parameter then the PL/SQL
    *     compiler settings are left unchanged, that is, equivalent to
    *     REUSE SETTINGS.
    *
    *     If a value is provided, it must specify the values of the PL/SQL
    *     compiler settings separated by one or more spaces. Each setting
    *     can be specified only once else inv_malformed_settings exception
    *     will be raised. The setting values are changed only for the object
    *     specified by p_object_id and do not affect dependent objects that
    *     may be invalidated.
    *
    *     The setting names and values are case insensitive.
    *
    *     If a setting is omitted and REUSE SETTINGS is specified, then if a
    *     value was specified for the compiler setting in an earlier
    *     compilation of this library unit, Oracle Database uses that earlier
    *     value. If a setting is omitted and REUSE SETTINGS was not specified
    *     or no value has been specified for the parameter in an earlier
    *     compilation, then the database will obtain the value for that
    *     setting from the session environment.
    *
    *     Note that an empty, non-null, string can be passed in.  This will
    *     cause all compiler settings to be read from the session environment.
    *
    *   p_option_flags (IN)
    *     Option flags supported (see note above). This parameter is optional
    *     and defaults to zero (no flags).
    *
    * DESCRIPTION:
    *   This procedure invalidates a database object and (optionally) modifies
    *   its PL/SQL compiler parameter settings. It also invalidates any
    *   objects that (directly or indirectly) depend on the object being
    *   invalidated.
    *
    *   The object type (object_type column from ALL_OBJECTS) of the object
    *   specified by p_object_id must be a PROCEDURE, FUNCTION, PACKAGE,
    *   PACKAGE BODY, TRIGGER, TYPE, TYPE BODY, LIBRARY, VIEW, OPERATOR,
    *   SYNONYM, or JAVA CLASS. If the object is not one of these types
    *   and the flag inv_error_on_restrictions is specified in p_option_flags
    *   then the exception inv_restricted_object is raised, else no action
    *   is taken.
    *
    *   If the object specified by p_object_id is the package specification
    *   of STANDARD, DBMS_STANDARD, or specification or body of DBMS_UTILITY
    *   and the flag inv_error_on_restrictions is specified in p_option_flags
    *   then the exception inv_restricted_object is raised, else no action
    *   is taken.
    *
    *   If the object specified by p_object_id is an object type specification
    *   and there exist tables which depend on the type and the flag
    *   inv_error_on_restrictions is specified in p_option_flags then the
    *   exception inv_restricted_object is raised, else no action is taken.
    *
    * EXAMPLES:
    *
    *   dbms_utility.invalidate(1232,
    *                           'PLSQL_OPTIMIZE_LEVEL = 2 REUSE SETTINGS');
    *
    *   Assume that the object_id 1232 refers to the procedure remove_emp
    *   in the hr schema. Then the above call will mark the remove_emp
    *   procedure invalid and change it's  PLSQL_OPTIMIZE_LEVEL compiler
    *   setting to 2. The values of other compiler settings will remain
    *   unchanged since REUSE SETTINGS is specified.
    *
    *   Objects that depend on hr.remove_emp will also get marked invalid.
    *   Their compiler parameters will not be changed.
    *
    *   dbms_utility.invalidate(40775,
    *                           'plsql_code_type = native');
    *
    *   Assume that the object_id 40775 refers to the type body
    *   leaf_category_typ in the oe schema. Then the above call will mark
    *   the type body invalid and change it's  PLSQL_CODE_TYPE compiler
    *   setting to NATIVE. The values of other compiler settings will be
    *   picked up from the current session environment since REUSE SETTINGS
    *   has not been specified.
    *
    *   Since no objects can depend on bodies, there are no cascaded
    *   invalidations.
    *
    *   dbms_utility.invalidate(40796);
    *
    *   Assume that the object_id 40796 refers to the view oc_orders in
    *   the oe schema. Then the above call will mark the oc_orders view
    *   invalid.
    *
    *   Objects that depend on oe.oc_orders will also get marked invalid.
    *
    * EXCEPTIONS:
    *   This procedure can raise various exceptions. See detailed description
    *   above.
    */
  procedure invalidate(p_object_id  number,
                       p_plsql_object_settings varchar2 default NULL,
                       p_option_flags pls_integer default 0);

  procedure analyze_schema(schema varchar2, method varchar2, 
    estimate_rows number default null, 
    estimate_percent number default null, method_opt varchar2 default null);
  --  Analyze all the tables, clusters and indexes in a schema.
  --  Input arguments:
  --    schema
  --      Name of the schema.
  --    method, estimate_rows, estimate_percent, method_opt
  --      See the descriptions above in sql_ddl.analyze.object.
  --  Exceptions:
  --    ORA-20000: Insufficient privileges for some object in this schema.
  procedure analyze_database(method varchar2, 
    estimate_rows number default null, 
    estimate_percent number default null, method_opt varchar2 default null);
  --  Analyze all the tables, clusters and indexes in a database.
  --  Input arguments:
  --    method, estimate_rows, estimate_percent, method_opt
  --      See the descriptions above in sql_ddl.analyze.object.
  --  Exceptions:
  --    ORA-20000: Insufficient privileges for some object in this database.
  function format_error_stack return varchar2;
    pragma interface (C, format_error_stack);               -- 1 (see psdicd.c)
  --  Format the current error stack.  This can be used in exception
  --    handlers to look at the full error stack.
  --  Output arguments:
  --    format_error_stack
  --      Returns the error stack.  May be up to 2000 bytes.
  function format_call_stack return varchar2;
    pragma restrict_references(format_call_stack,WNDS);
    pragma interface (C, format_call_stack);                -- 2 (see psdicd.c)
  --  Format the current call stack.  This can be used an any stored
  --    procedure or trigger to access the call stack.  This can be
  --    useful for debugging.
  --  Output arguments:
  --    format_call_stack
  --      Returns the call stack.  May be up to 2000 bytes.
  function is_cluster_database return boolean;
  --  Find out if this database is running in cluster database mode.
  --  Output arguments:
  --    is_cluster_database
  --      TRUE if this instance was started in cluster database mode,
  --      FALSE otherwise.

  function get_time return number;
  --  Find out the current elapsed time in 100th's of a second.
  --  Output:
  --      The returned elapsed time is the number of 100th's 
  --      of a second from some arbitrary epoch.
  --  Related Function(s): "get_cpu_time" [See below].

  function get_parameter_value(parnam in     varchar2,
                               intval in out binary_integer,
                               strval in out varchar2,
                               listno in     binary_integer default 1)
    return binary_integer;
  --  Gets value of specified init.ora parameter.
  --  Input arguments:
  --    parnam
  --      Parameter name
  --    listno
  --      List item number. If we are retrieving the parameter values for
  --      a parameter that can be specified multiple times to accumulate
  --      values (Eg rollback_segments) then this can be used to get each
  --      individual parameter. Eg, if we have the following :
  --      
  --          rollback_segments = rbs1
  --          rollback_segments = rbs2
  --
  --      then use a value of 1 to get "rbs1" and a value of 2 to get "rbs2".
  --
  --  Output arguments:
  --    intval
  --      Value of an integer parameter or value length of a string parameter
  --    strval
  --      Value of a string parameter
  --  Returns:
  --    partyp
  --      Parameter type
  --        0 if parameter is an integer/boolean parameter
  --        1 if parameter is a  string/file parameter
  --  Notes
  --    1. Certain parameters can store values much larger than can be 
  --       returned by this function. When this function is requested to
  --       retrieve the setting for such parameters and "unsupported parameter"
  --       exception will be raised. The "shared_pool_size" parameter is one
  --       such parameter.
  -- Example usage:
  -- DECLARE
  --   parnam VARCHAR2(256);
  --   intval BINARY_INTEGER;
  --   strval VARCHAR2(256);
  --   partyp BINARY_INTEGER;
  -- BEGIN
  --   partyp := dbms_utility.get_parameter_value('max_dump_file_size',
  --                                               intval, strval);
  --   dbms_output.put('parameter value is: ');
  --   IF partyp = 1 THEN
  --     dbms_output.put_line(strval);
  --   ELSE
  --     dbms_output.put_line(intval);
  --   END IF;
  --   IF partyp = 1 THEN
  --     dbms_output.put('parameter value length is: ');
  --     dbms_output.put_line(intval);
  --   END IF;
  --   dbms_output.put('parameter type is: ');
  --   IF partyp = 1 THEN
  --     dbms_output.put_line('string');
  --   ELSE
  --     dbms_output.put_line('integer');
  --   END IF;
  -- END;
  procedure name_resolve(name in varchar2, context in number,
    schema out varchar2, part1 out varchar2, part2 out varchar2,
    dblink out varchar2, part1_type out number, object_number out number);
  --  Resolve the given name.  Do synonym translation if necessary.  Do
  --    authorization checking.
  --  Input arguments:
  --    name
  --      The name of the object.  This can be of the form [[a.]b.]c[@d]
  --      where a,b,c are SQL identifier and d is a dblink.  No syntax
  --      checking is performed on the dblink.  If a dblink is specified,
  --      of the name resolves to something with a dblink, then object
  --      is not resolved, but the schema, part1, part2 and dblink out
  --      arguments are filled in.  a,b and c may be delimted identifiers,
  --      and may contain NLS characters (single and multi-byte).
  --    context
  --      Must be an integer between 0 and 8.
  --  Output arguments:
  --    schema
  --      The schema of the object.  If no schema is specified in 'name'
  --      then the schema is determined by resolving the name.
  --    part1
  --      The first part of the name.  The type of this name is specified
  --      part1_type (synonym, procedure or package).
  --    part2
  --      If this is non-null, then this is a procedure name within the
  --      package indicated by part1.
  --    dblink
  --      If this is non-null then a database link was either specified
  --      as part of 'name' or 'name' was a synonym which resolved to
  --      something with a database link.  In this later case, part1_type
  --      will indicate a synonym.
  --    part1_type
  --      The type of part1 is
  --        5 - synonym
  --        7 - procedure (top level)
  --        8 - function (top level)
  --        9 - package
  --      If a synonym, it means that 'name' is a synonym that translats
  --      to something with a database link.  In this case, if further
  --      name translation is desired, then you must call the 
  --      dbms_utility.name_resolve procedure on this remote node.
  --    object_number
  --      If non-null then 'name' was successfully resolved and this is the
  --      object number which it resolved to.
  --  Exceptions:
  --    All errors are handled by raising exceptions.  A wide variety of
  --    exceptions are possible, based on the various syntax error that
  --    are possible when specifying object names.
  procedure name_tokenize( name    in  varchar2,
                           a       out varchar2,
                           b       out varchar2,
                           c       out varchar2,
                           dblink  out varchar2, 
                           nextpos out binary_integer);
  --  Call the parser to parse the given name as "a [. b [. c ]][@ dblink ]".
  --  Strip doublequotes, or convert to uppercase if there are no quotes.
  --    Ignore comments of all sorts.  Do no semantic analysis.  Leave any
  --      missing values as null. 
  --  For each of a,b,c,dblink, tell where the following token starts
  --    in anext,bnext,cnext,dnext respectively.
  PROCEDURE comma_to_table( list   IN  VARCHAR2,
                            tablen OUT BINARY_INTEGER,
                            tab    OUT uncl_array);
  --  Convert a comma-separated list of names into a PL/SQL table of names
  --  This uses name_tokenize to figure out what are names and what are commas

  PROCEDURE comma_to_table( list   IN  VARCHAR2,
                            tablen OUT BINARY_INTEGER,
                            tab    OUT lname_array);
  --  Convert a comma-separated list of names into a PL/SQL table of names
  --  This uses aname_parse to figure out what are names and what are commas
  --  This is an overloaded version for supporting fully-qualified attribute
  --  names.

  PROCEDURE table_to_comma( tab    IN  uncl_array, 
                            tablen OUT BINARY_INTEGER,
                            list   OUT VARCHAR2);
  --  Convert a PL/SQL table of names into a comma-separated list of names

  PROCEDURE table_to_comma( tab    IN  lname_array, 
                            tablen OUT BINARY_INTEGER,
                            list   OUT VARCHAR2);
  --  Convert a PL/SQL table of names into a comma-separated list of names
  --  This is an overloaded version for supporting fully-qualified attribute
  --  names.

  FUNCTION port_string RETURN VARCHAR2;
  PRAGMA RESTRICT_REFERENCES(port_string, WNDS, RNDS, WNPS, RNPS);
  --  Return a string that uniquely identifies the port (operating system)
  --  and the two task protocol version of Oracle.  EG "VAX/VMX-7.1.0.0"
  --  "SVR4-be-8.1.0" (SVR4-b(ig)e(ndian)-8.1.0)
  --  maximum length is port specific.

  PROCEDURE db_version(version       OUT VARCHAR2,
                       compatibility OUT VARCHAR2);
  -- Return version information for the database:
  -- version -> A string which represents the internal software version
  --            of the database (e.g., 7.1.0.0.0). The length of this string
  --            is variable and is determined by the database version.
  -- compatibility -> The compatibility setting of the database determined by
  --                  the "compatible" init.ora parameter. If the parameter 
  --                  is not specified in the init.ora file, NULL is returned.

  function make_data_block_address(file number, block number) return number;
  PRAGMA RESTRICT_REFERENCES(make_data_block_address, WNDS, RNDS, WNPS, RNPS);
  --  Creates a data block address given a file# and a block#.  A data block
  --  address is the internal structure used to identify a block in the
  --  database.  This is function useful when accessing certain fixed tables
  --  that contain data block addresses.
  --  Input arguments:
  --    file  - the file that contains the block
  --    block - the offset of the block within the file in terms of block 
  --            increments
  --  Output arguments:
  --    dba   - the data block address
  function data_block_address_file(dba number) return number;
  PRAGMA RESTRICT_REFERENCES(data_block_address_file, WNDS, RNDS, WNPS, RNPS);
  --  Get the file number part of a data block address
  --  Input arguments:
  --    dba   - a data block address
  --  Output Arguments:
  --    file  - the file that contains the block
  function data_block_address_block(dba number) return number;
  PRAGMA RESTRICT_REFERENCES(data_block_address_block, WNDS, RNDS, WNPS, RNPS);
  --  Get the block number part of a data block address
  --  Input arguments:
  --    dba   - a data block address
  --  Output Arguments:
  --    block  - the block offset of the block  
  function get_hash_value(name varchar2, base number, hash_size number)
    return number;
  PRAGMA RESTRICT_REFERENCES(get_hash_value, WNDS, RNDS, WNPS, RNPS);
  --  Compute a hash value for the given string
  --  Input arguments:
  --    name  - The string to be hashed.
  --    base  - A base value for the returned hash value to start at.
  --    hash_size -  The desired size of the hash table.
  --  Returns:
  --    A hash value based on the input string.
  --    For example, to get a hash value on a string where the hash value 
  --    should be between 1000 and 3047, use 1000 as the base value and
  --    2048 as the hash_size value.  Using a power of 2 for the hash_size
  --    parameter works best.
  --  Exceptions:
  --    ORA-29261 will be raised if hash_size is 0

  --  Exceptions:
  --    ORA-29261 will be raised if hash_size is 0

  function get_sql_hash(name IN varchar2, hash OUT raw, 
                        pre10ihash OUT number)
    return number;
  PRAGMA RESTRICT_REFERENCES(get_sql_hash, WNDS, RNDS, WNPS, RNPS);
  --  Compute a hash value for the given string using md5 algo
  --  Input arguments:
  --    name  - The string to be hashed.
  --    hash  - An optional field to store all 16 bytes of returned
  --            hash value.
  --    pre10ihash - An optional field to store the pre 10i database
  --                 version hash value.
  --  Returns:
  --    A hash value (last 4 bytes)  based on the input string.
  --    The md5 hash algorithm computes a 16 byte hash value, but
  --    we only return the last 4 bytes so that we can return an
  --    actual number.  One could use an optional RAW parameter to
  --    get all 16 bytes and to store the pre 10i hash value of 4
  --    4 bytes in the pre10ihash optional parameter.

  function sqlid_to_sqlhash(sql_id varchar2)
    return number;
  PRAGMA RESTRICT_REFERENCES(sqlid_to_sqlhash, WNDS, RNDS, WNPS, RNPS);
  --  This routine will convert a sql_id into a hash value
  --  Input arguments:
  --    sql_id - SQL ID of a sql statement.  Must be VARCHAR2(13).
  --  Returns:
  --    A hash value converted from the sql_id.

procedure analyze_part_object 
   (schema in varchar2 default null,
    object_name in varchar2 default null,
    object_type in char default 'T',
    command_type in char default 'E',
    command_opt in varchar2 default null,
    sample_clause in varchar2 default 'sample 5 percent');
  --  Equivalent to SQL "ANALYZE TABLE|INDEX [<schema>.]<object_name>
  --    PARTITION <pname> [<command_type>] [<command_opt>] [<sample_clause>]
  --  for each partition of the object, run in parallel using job queues.
  --  The package will submit a job for each partition
  --  It is the users responsibilty to control the number of concurrent
  --  jobs by setting the INIT parameter JOB_QUEUE_PROCESSES correctly
  --  There is minimal error checking for correct syntax.  Any error will be 
  --  reported in SNP trace files.
  --  Input arguments:
  --  schema
  --    schema of the object_name
  --  object_name
  --    name of object to be analyzed, must be partitioned
  --  object_type
  --    type of object, must be T(able) or I(ndex)
  --  command_type
  --    must be one of the following
  --      - C(omput statistics)
  --      - E(stimate statistics)
  --      - D(elete statistics)
  --      - V(alidate structure)
  --  command_opt
  --    Other options for the command type.
  --    For C, E it can be FOR table, FOR all LOCAL indexes, FOR all columns or
  --    combination of some of the 'for' options of analyze statistics (table)
  --    For V, it can be 'CASCADE' when object_type is T
  --  sample_clause
  --    Specifies the sample clause to use when command_type is 'E'
procedure exec_ddl_statement(parse_string in varchar2);
  -- Will execute the DDL statement in parse_string
  --  parse_string
  --    DDL statement to be executed

function current_instance return number;
  -- Return the current connected instance number
  -- Return NULL when connected instance is down

procedure  active_instances(instance_table   OUT instance_table,
                            instance_count   OUT number);
  -- instance_table contains a list of the active instance numbers and names
  -- When no instance is up ( or non-OPS setting), the list is empty
  -- instance_count is  the number of active instances, 0 under non-ops setting

procedure get_dependency (type   IN VARCHAR2, 
                          schema IN VARCHAR2, 
                          name   IN VARCHAR2);
 -- This procedure will show all the dependencies on the object passed in.
 -- The inputs are
 --   type: The type of the object, for example if the object is a table
 --         give the type as 'TABLE'.
 --   schema: The schema name of the object.
 --   name: The name of the object.


procedure create_alter_type_error_table ( schema_name IN VARCHAR2,
                                          table_name  IN VARCHAR2);
 -- This procedure will create an error table to be used in the EXCEPTION
 -- clause of ALTER TYPE statement. An error will be returned if the table
 -- already exists.
 -- The inputs are:
 --   schema: The schema name
 --   table: The name of the table to be created.

procedure canonicalize(name           IN   VARCHAR2,
                       canon_name     OUT  VARCHAR2,
                       canon_len      IN   BINARY_INTEGER);
  -- canonicalize the given string
  -- if name is NULL, canon_name becomes NULL
  -- if name is not a dotted name,
  --    if name begins and ends with a double quote, remove both
  --    otherwise, convert to upper case with NLS_UPPER
  --    Note that this case does not include a name with special
  --    characters, e.g., space, but is not doubly quoted.
  -- if name is a dotted name, e.g., a."b".c,
  --    for each component in the dotted name,
  --      if the component begins and ends with a double quote,
  --        no transformation will be done in this component
  --      else
  --        this component will be capitalized with NLS_UPPER and
  --        a begin and end double quotes will be applied to the
  --        capitalized form of this component.
  --    each canonicalized component will be concatenated together in
  --    the input position, separated by ".".
  -- return the first canon_len bytes in canon_name
  --
  -- Any other character after a[.b]* will be ignored.
  --
  -- NOTES:
  --   1. It does not handle cases like 'A B';
  --   2. It handles a single reserved/key word, e.g., 'table';
  --   3. It strips off white spaces for a single identifier, e.g., ' table '
  --      becomes TABLE.
  --
  -- Examples:
  --   a becomes A
  --   "a" becomes a
  --   "a".b becomes "a"."B"
  --   "a".b,c.f becomes "a"."B", ",c.f" is ignored.
  --

FUNCTION is_bit_set(r                 IN  RAW,
                 n                 IN  NUMBER)
  RETURN NUMBER;
  PRAGMA RESTRICT_REFERENCES(is_bit_set, RNPS, WNPS, RNDS, WNDS);
  --  Return 1 if bit n in raw r is set.  Bits are numbered high to low
  --  with the lowest bit being bit number 1.  This is a utility to assist
  --  the view DBA_PENDING_TRANSACTION.  
  
  
procedure get_tz_transitions(regionid number,transitions OUT maxraw);  


  --  Get timezeone transitions from the timezone.dat file
  --  Input arguments:
  --    regionid 
  --      Number corresponding to the region
  --  Output arguments:
  --    transitions
  --      The raw bytes from the timezone.dat file
  
  --
  -- The following two functions provide the pre-825066-fix behavior of
  -- SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') and 
  -- SYS_CONTEXT('USERENV', 'CURRENT_USER')
  --                  These functions are temporarily provided for
  -- *** Warning ***: backward compatibility and will be removed in
  --                  near future.
  -- 
  function old_current_schema return varchar2;
  function old_current_user   return varchar2;

  function get_endianness return number;
    pragma interface (C, get_endianness);                   -- 3 (see psdicd.c)

  function format_error_backtrace return varchar2;
    pragma interface (C, format_error_backtrace);           -- 4 (see psdicd.c)
  --  Format the backtrace from the point of the current error
  --  to the exception handler where the error has been caught.
  --  NULL string is returned if no error is currently being
  --  handled.

 function get_cpu_time return number;
  --  Find out the current CPU time in 100th's of a second.
  --
  --  Output:
  --    The returned CPU time is the number of 100th's
  --    of a second from some arbitrary epoch.
  --
  --  Related Function(s): 
  --    "get_time" [See above].
  --
  --  Usage Example:
  --     ..
  --     start_cpu_time NUMBER;
  --     end_cpu_time   NUMBER;
  --     ..
  --   BEGIN
  --
  --     start_cpu_time := dbms_utility.GET_CPU_TIME;
  --
  --     ... -- some work that needs to be timed
  --
  --     end_cpu_time := dbms_utility.GET_CPU_TIME;
  --
  --     dbms_output.put_line('CPU Time (in seconds)= ' 
  --                          || ((end_cpu_time - start_cpu_time)/100));
  --

end;
/

create or replace public synonym dbms_utility for sys.dbms_utility
/
grant execute on dbms_utility to public
/

create or replace package dbms_rowid is
  ------------
  --  OVERVIEW
  --
  --  This package provides procedures to create ROWIDs and to interpret
  --  their contents

  --  SECURITY
  --
  --  The execution privilege is granted to PUBLIC. Procedures in this
  --  package run under the caller security. 


  ----------------------------

  ----------------------------

  --  ROWID TYPES:
  --
  --   RESTRICTED - Restricted ROWID
  --
  --   EXTENDED   - Extended ROWID 
  --
  rowid_type_restricted constant integer := 0;
  rowid_type_extended   constant integer := 1;

  --  ROWID VERIFICATION RESULTS:
  --
  --   VALID   - Valid ROWID
  --
  --   INVALID - Invalid ROWID 
  --
  rowid_is_valid   constant integer := 0;
  rowid_is_invalid constant integer := 1;

  --  OBJECT TYPES:
  --
  --   UNDEFINED - Object Number not defined (for restricted ROWIDs)
  --
  rowid_object_undefined constant integer := 0;

  --  ROWID CONVERSION TYPES:
  --
  --   INTERNAL - convert to/from column of ROWID type
  --
  --   EXTERNAL - convert to/from string format
  --
  rowid_convert_internal constant integer := 0;
  rowid_convert_external constant integer := 1;

  --  EXCEPTIONS:
  --
  -- ROWID_INVALID  - invalid rowid format
  --
  -- ROWID_BAD_BLOCK - block is beyond end of file
  --
  ROWID_INVALID exception;
     pragma exception_init(ROWID_INVALID, -1410);
  ROWID_BAD_BLOCK exception;
     pragma exception_init(ROWID_BAD_BLOCK, -28516);

  --  PROCEDURES AND FUNCTIONS:
  --

  --
  -- ROWID_CREATE constructs a ROWID from its constituents:
  --
  -- rowid_type - type (restricted/extended) 
  -- object_number - data object number (rowid_object_undefined for restricted)
  -- relative_fno - relative file number
  -- block_number - block number in this file
  -- file_number - file number in this block
  --
  function rowid_create(rowid_type IN number, 
                        object_number IN number,
                        relative_fno IN number,
                        block_number IN number,
                        row_number IN number) 
                        return rowid;
  pragma RESTRICT_REFERENCES(rowid_create,WNDS,RNDS,WNPS,RNPS);

  --
  -- ROWID_INFO breaks ROWID into its components and returns them:
  --
  -- rowid_in - ROWID to be interpreted
  -- rowid_type - type (restricted/extended) 
  -- object_number - data object number (rowid_object_undefined for restricted)
  -- relative_fno - relative file number
  -- block_number - block number in this file
  -- file_number - file number in this block
  -- ts_type_in - type of tablespace which this row belongs to
  --              'BIGFILE' indicates Bigfile Tablespace 
  --              'SMALLFILE' indicates Smallfile (traditional pre-10i) TS.
  --              NOTE: These two are the only allowed values for this param
  --
  procedure rowid_info( rowid_in IN rowid,
                        rowid_type OUT number, 
                        object_number OUT number,
                        relative_fno OUT number,
                        block_number OUT number,
                        row_number OUT number,
                        ts_type_in IN varchar2 default 'SMALLFILE');
  pragma RESTRICT_REFERENCES(rowid_info,WNDS,RNDS,WNPS,RNPS);

  --
  -- ROWID_TYPE returns the type of a ROWID (restricted/extended_nopart,..)
  --
  -- row_id - ROWID to be interpreted
  --
  function rowid_type(row_id IN rowid) 
                        return number;
  pragma RESTRICT_REFERENCES(rowid_type,WNDS,RNDS,WNPS,RNPS);

  --
  -- ROWID_OBJECT extracts the data object number from a ROWID. 
  -- ROWID_OBJECT_UNDEFINED is returned for restricted rowids.
  --
  -- row_id - ROWID to be interpreted
  --
  function rowid_object(row_id IN rowid) 
                        return number;
  pragma RESTRICT_REFERENCES(rowid_object,WNDS,RNDS,WNPS,RNPS);

  --
  -- ROWID_RELATIVE_FNO extracts the relative file number from a ROWID. 
  --
  -- row_id - ROWID to be interpreted
  -- ts_type_in - type of tablespace which this row belongs to
  --
  function rowid_relative_fno(row_id IN rowid,
                              ts_type_in IN varchar2 default 'SMALLFILE')
                        return number;
  pragma RESTRICT_REFERENCES(rowid_relative_fno,WNDS,RNDS,WNPS,RNPS);

  --
  -- ROWID_BLOCK_NUMBER extracts the block number from a ROWID. 
  --
  -- row_id - ROWID to be interpreted
  -- ts_type_in - type of tablespace which this row belongs to
  --
  --
  function rowid_block_number(row_id IN rowid,
                              ts_type_in IN varchar2 default 'SMALLFILE') 
                        return number;
  pragma RESTRICT_REFERENCES(rowid_block_number,WNDS,RNDS,WNPS,RNPS);

  --
  -- ROWID_ROW_NUMBER extracts the row number from a ROWID. 
  --
  -- row_id - ROWID to be interpreted
  --
  function rowid_row_number(row_id IN rowid) 
                        return number;
  pragma RESTRICT_REFERENCES(rowid_row_number,WNDS,RNDS,WNPS,RNPS);

  --
  -- ROWID_TO_ABSOLUTE_FNO extracts the relative file number from a ROWID,
  -- which addresses a row in a given table
  --
  -- row_id - ROWID to be interpreted
  --
  -- schema_name - name of the schema which contains the table
  --
  -- object_name - table name 
  --
  function rowid_to_absolute_fno(row_id IN rowid,
                                 schema_name IN varchar2,
                                 object_name IN varchar2)
                        return number;
  pragma RESTRICT_REFERENCES(rowid_to_absolute_fno,WNDS,WNPS,RNPS);

  --
  -- ROWID_TO_EXTENDED translates the restricted ROWID which addresses
  -- a row in a given table to the extended format. Later, it may be removed
  -- from this package into a different place
  --
  -- old_rowid - ROWID to be converted
  --
  -- schema_name - name of the schema which contains the table (OPTIONAL)
  --
  -- object_name - table name (OPTIONAL)
  --
  -- conversion_type - rowid_convert_internal/external_convert_external
  --                   (whether old_rowid was stored in a column of ROWID
  --                    type, or the character string)
  --
  function rowid_to_extended(old_rowid IN rowid,
                             schema_name IN varchar2,
                             object_name IN varchar2,
                             conversion_type IN integer)
                        return rowid;
  pragma RESTRICT_REFERENCES(rowid_to_extended,WNDS,WNPS,RNPS);

  --
  -- ROWID_TO_RESTRICTED translates the extnded ROWID into a restricted format
  --
  -- old_rowid - ROWID to be converted
  --
  -- conversion_type - internal/external (IN)
  --
  -- conversion_type - rowid_convert_internal/external_convert_external
  --                   (whether returned rowid will be stored in a column of 
  --                    ROWID type, or the character string)
  --
  function rowid_to_restricted(old_rowid IN rowid,
                               conversion_type IN integer)
                        return rowid;
  pragma RESTRICT_REFERENCES(rowid_to_restricted,WNDS,RNDS,WNPS,RNPS);

  --
  -- ROWID_VERIFY verifies the ROWID. It returns rowid_valid or rowid_invalid
  -- value depending on whether a given ROWID is valid or not. 
  --
  -- rowid_in - ROWID to be verified
  --
  -- schema_name - name of the schema which contains the table
  --
  -- object_name - table name 
  --
  -- conversion_type - rowid_convert_internal/external_convert_external
  --                   (whether old_rowid was stored in a column of ROWID
  --                    type, or the character string)
  --
  function rowid_verify(rowid_in IN rowid,
                        schema_name IN varchar2,
                        object_name IN varchar2,
                        conversion_type IN integer)
                        return number;
  pragma RESTRICT_REFERENCES(rowid_verify,WNDS,WNPS,RNPS);

end;
/
create or replace public synonym dbms_rowid for sys.dbms_rowid
/
grant execute on dbms_rowid to public
/

create or replace package dbms_pclxutil as 
  ------------
  --  OVERVIEW
  --  
  --  a package that provides intra-partition parallelism for creating 
  --  partition-wise local index.
  --
  --  SECURITY
  --
  --  The execution privilege is granted to PUBLIC. The procedure
  --  build_part_index in this package run under the caller security. 
  --

  ----------------------------

  ----------------------------

  type JobList is table of number;

  procedure build_part_index (
     jobs_per_batch in number default 1,
     procs_per_job  in number default 1,
     tab_name       in varchar2 default null,
     idx_name       in varchar2 default null,
     force_opt      in boolean default FALSE); 
  --
  -- jobs_per_batch: #jobs to be created (1 <= job_count <= #partitions)
  --
  -- procs_per_job:  #slaves per job (1 <= degree <= max_slaves)
  --
  -- tab_name:       name of the partitioned table (an exception is 
  --                 raised if the table does not exist or not 
  --                 partitioned)
  --
  -- idx_name:       name given to the local index (an exception is 
  --                 raised if a local index is not created on the 
  --                 table tab_name)
  --
  -- force_opt:      if TRUE force rebuild of all partitioned indices; 
  --                 otherwise rebuild only the partitions marked 
  --                 'UNUSABLE'
  --

end dbms_pclxutil;
/
create or replace public synonym dbms_pclxutil for sys.dbms_pclxutil
/
grant execute on dbms_pclxutil to public
/

  --------------------
create or replace package dbms_errlog AUTHID CURRENT_USER is
  --------------------
  -- OVERVIEW
  --
  -- This package is provided to ease the creation of a DML error
  -- logging table based on the shape of a table which DML operations
  -- are to be done on.
  --
  --------------------
  -- PROCEDURES AND FUNCTIONS
  --
  procedure create_error_log(dml_table_name      varchar2,
                             err_log_table_name  varchar2 default NULL,
                             err_log_table_owner varchar2 default NULL,
                             err_log_table_space varchar2 default NULL,
                             skip_unsupported    boolean  default FALSE);
  -- Input arguments:
  --   dml_table_name
  --     Name of the DML table to use to base the shape of error logging
  --     table on.  Name can be fully qualified
  --     (e.g. 'emp', 'scott.emp', '"EMP"', '"SCOTT"."EMP"')
  --     If a name component is enclosed in double quotes, it will not
  --     be upper cased.
  --     DEFAULT: None, mandatory argument.
  --   err_log_table_name
  --     Name of the error logging table to create.
  --     DEFAULT: First 25 characters in the name of the DML table prefixed
  --              with 'ERR$_'.
  --              Example: dml_table_name: 'EMP',
  --                       err_log_table_name: 'ERR$_EMP'
  --              Example: dml_table_name: '"Emp2"',
  --                       err_log_table_name: 'ERR$_Emp2'
  --   err_log_table_owner
  --     Name of the owner of the error table.
  --     DEFAULT: If owner specified in dml_table_name, then default
  --              is owner specified in dml_table_name.
  --              Otherwise, uses schema of current connected user.
  --   err_log_table_space
  --     Tablespace to create the error logging table in.
  --     DEFAULT:  Creating users default tablespace.
  --   skip_unsupported
  --     When skip_unsupported is TRUE, column types which are not
  --     supported by DML Error logging will be skipped over and not
  --     added to the error logging table.
  --     When skip_unsupported is FALSE, an unsupported column type will
  --     cause the procedure to terminate.
  --     DEFAULT: FALSE.
  --
end;
/

create or replace public synonym dbms_errlog for sys.dbms_errlog
/

grant execute on dbms_errlog to public
/


