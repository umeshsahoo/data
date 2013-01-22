Rem
Rem $Header: dbmsawr.sql 27-may-2005.10:44:43 ysarig Exp $
Rem
Rem dbmsawr.sql
Rem
Rem Copyright (c) 2002, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmsawr.sql - DBMS Automatic Workload Repository
Rem                    package for administrators.
Rem
Rem    DESCRIPTION
Rem      Specification for dbms_workload_repository interface
Rem
Rem    NOTES
Rem      Package will include procedures that make Trusted Callouts
Rem      to the kernel
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ysarig      05/26/05 - Fix comments for compare period report 
Rem    veeve       01/10/05 - modify xtra_predicate to args in ash_report
Rem    adagarwa    09/15/04 - Add SQL report procedures
Rem    veeve       07/01/04 - add xtra_predicate option to ash_report
Rem    jxchen      04/26/04 - Split awr_diff_report into text and html 
Rem                           functions. 
Rem    jxchen      12/26/03 - Add Diff-Diff report procedure
Rem    veeve       02/27/04 - added ash_report_text
Rem    mlfeng      05/21/04 - add interfaces for Top N SQL
Rem    mlfeng      11/19/03 - remove stat_changes
Rem    mlfeng      11/25/03 - constant for max interval 
Rem    pbelknap    11/03/03 - pbelknap_swrfnm_to_awrnm 
Rem    pbelknap    10/28/03 - changing swrf to awr 
Rem    pbelknap    09/19/03 - updating with addition of table type 
Rem    mlfeng      08/11/03 - add options 
Rem    gngai       06/02/03 - changed drop_baseline
Rem    mlfeng      06/10/03 - add reporting logic
Rem    mlfeng      04/30/03 - return just completed snap_id and baseline_id
Rem    gngai       04/09/03 - added support for global DBID
Rem    gngai       02/25/03 - changed comments for modify_snapshot_settings
Rem    mlfeng      01/28/03 - Changing create_snapshot interface to 
Rem                           take 'TYPICAL' and 'ALL' string
Rem    mlfeng      01/22/03 - Update comments for stat_changes
Rem    gngai       01/22/03 - changed Drop_Snapshot_Range
Rem    mlfeng      08/01/02 - Updating DBMS_WORKLOAD_REPOSITORY
Rem    mlfeng      07/08/02 - swrf flushing
Rem    mlfeng      06/11/02 - Created
Rem


CREATE OR REPLACE PACKAGE dbms_workload_repository AS

  -- ************************************ --
  --  DBMS_WORKLOAD_REPOSITORY Constants
  -- ************************************ --
  
  -- Minimum and Maximum values for the 
  -- Snapshot Interval Setting (in minutes)
  MIN_INTERVAL    CONSTANT NUMBER := 10;                       /* 10 minutes */
  MAX_INTERVAL    CONSTANT NUMBER := 52560000;                  /* 100 years */

  -- Minimum and Maximum values for the  
  -- Snapshot Retention Setting (in minutes)
  MIN_RETENTION   CONSTANT NUMBER := 1440;                          /* 1 day */
  MAX_RETENTION   CONSTANT NUMBER := 52560000;                  /* 100 years */


  -- *********************************** --
  --  DBMS_WORKLOAD_REPOSITORY Routines
  -- *********************************** --

  -- 
  -- create_snapshot()
  --   Creates a snapshot in the workload repository.  
  -- 
  --   This routine will come in two forms: procedure and function.  
  --   The function returns the snap_id for the snapshot just taken.
  --
  -- Input arguments:
  --   flush_level               - flush level for the snapshot:
  --                               either 'TYPICAL' or 'ALL'
  --
  -- Returns:
  --   NUMBER                    - snap_id for snapshot just taken.
  --

  PROCEDURE create_snapshot(flush_level IN VARCHAR2 DEFAULT 'TYPICAL'
                            );

  FUNCTION create_snapshot(flush_level IN VARCHAR2 DEFAULT 'TYPICAL'
                           )  RETURN NUMBER;

  --
  -- drop_snapshot_range()
  -- purge the snapshots for the given range of snapshots.
  --
  -- Input arguments:
  --   low_snap_id              - low snapshot id of snapshots to drop
  --   high_snap_id             - high snapshot id of snapshots to drop
  --   dbid                     - database id (default to local DBID)
  --

  PROCEDURE drop_snapshot_range(low_snap_id      IN NUMBER,
                                high_snap_id     IN NUMBER,
                                dbid             IN NUMBER DEFAULT NULL
                                );


  --
  -- modify_snapshot_settings()
  -- Procedure to adjust the settings of the snapshot collection.
  --
  -- Input arguments:
  --   retention                - new retention time (in minutes). The
  --                              specified value must be in the range:
  --                              MIN_RETENTION (1 day) to 
  --                              MAX_RETENTION (100 years)
  --
  --                              If ZERO is specified, snapshots will be 
  --                              retained forever. A large system-defined
  --                              value will be used as the retention setting.
  --
  --                              If NULL is specified, the old value for 
  --                              retention is preserved.
  --
  --   interval                 - the interval between each snapshot, in
  --                              units of minutes. The specified value 
  --                              must be in the range:
  --                              MIN_INTERVAL (10 minutes) to 
  --                              MAX_INTERVAL (100 years)
  --
  --                              If ZERO is specified, automatic and manual 
  --                              snapshots will be disabled.  A large 
  --                              system-defined value will be used as the 
  --                              interval setting.
  --
  --                              If NULL is specified, the 
  --                              current value is preserved.
  --
  --   topnsql (NUMBER)         - Top N SQL size.  The number of Top SQL 
  --                              to flush for each SQL criteria 
  --                              (Elapsed Time, CPU Time, Parse Calls, 
  --                               Shareable Memory, Version Count).  
  --
  --                              The value for this setting will be not 
  --                              be affected by the statistics/flush level 
  --                              and will override the system default 
  --                              behavior for the AWR SQL collection.  The 
  --                              setting will have a minimum value of 30 
  --                              and a maximum value of 100000000.  
  --
  --                              IF NULL is specified, the 
  --                              current value is preserved.
  --
  --   topnsql (VARCHAR2)       - Users are allowed to specify the following
  --                              values: ('DEFAULT', 'MAXIMUM', 'N')
  --
  --                              Specifying 'DEFAULT' will revert the system 
  --                              back to the default behavior of Top 30 for 
  --                              level TYPICAL and Top 100 for level ALL.
  --
  --                              Specifying 'MAXIMUM' will cause the system 
  --                              to capture the complete set of SQL in the 
  --                              cursor cache.  Specifying the number 'N' is 
  --                              equivalent to setting the Top N SQL with 
  --                              the NUMBER type. 
  --
  --                              Specifying 'N' will cause the system
  --                              to flush the Top N SQL for each criteria.
  --                              The 'N' string is converted into the number
  --                              for Top N SQL.
  --
  --   dbid                     - database identifier for the database to 
  --                              adjust setting. If NULL is specified, the
  --                              local dbid will be used.
  --
  --  For example, the following statement can be used to set the
  --  Retention and Interval to their minimum settings:
  --
  --    dbms_workload_repository.modify_snapshot_settings
  --              (retention => DBMS_WORKLOAD_REPOSITORY.MIN_RETENTION
  --               interval  => DBMS_WORKLOAD_REPOSITORY.MIN_INTERVAL)
  --
  --  The following statement can be used to set the Retention to 
  --  7 days and the Interval to 60 minutes and the Top N SQL to 
  --  the default setting:
  --
  --    dbms_workload_repository.modify_snapshot_settings
  --              (retention => 10080, interval  => 60, topnsql => 'DEFAULT');
  --
  --  The following statement can be used to set the Top N SQL 
  --  setting to 200:
  --    dbms_workload_repository.modify_snapshot_settings
  --              (topnsql => 200);
  --

  PROCEDURE modify_snapshot_settings(retention  IN NUMBER DEFAULT NULL,
                                     interval   IN NUMBER DEFAULT NULL,
                                     topnsql    IN NUMBER DEFAULT NULL,
                                     dbid       IN NUMBER DEFAULT NULL
                                     );


  PROCEDURE modify_snapshot_settings(retention  IN NUMBER   DEFAULT NULL,
                                     interval   IN NUMBER   DEFAULT NULL,
                                     topnsql    IN VARCHAR2,
                                     dbid       IN NUMBER   DEFAULT NULL
                                     );

  --
  -- create_baseline()
  --   Routine to create a baseline.  A baseline is set of
  --   of statistics defined by a (begin, end) pair of snapshots.
  --
  --   This routine will come in two forms: procedure and function.  
  --   The function returns the baseline_id for the baseline just created.
  --
  -- Input arguments:
  --   start_snap_id            - start snapshot sequence number for baseline
  --   end_snap_id              - end snapshot sequence number for baseline
  --   baseline_name            - name of baseline (required)
  --   dbid                     - optional dbid, default to Local DBID
  --
  -- Returns:
  --   NUMBER                   - baseline_id for the baseline just created
  --

  PROCEDURE create_baseline(start_snap_id  IN NUMBER, 
                            end_snap_id    IN NUMBER,
                            baseline_name  IN VARCHAR2,
                            dbid           IN NUMBER DEFAULT NULL
                            );

  FUNCTION create_baseline(start_snap_id  IN NUMBER, 
                           end_snap_id    IN NUMBER,
                           baseline_name  IN VARCHAR2,
                           dbid           IN NUMBER DEFAULT NULL
                           )  RETURN NUMBER;

  --
  -- drop_baseline()
  -- drops a baseline (by name)
  --
  -- Input arguments:
  --   baseline_name            - name of baseline to drop
  --   dbid                     - database id, default to local DBID
  --   cascade                  - if TRUE, the range of snapshots associated 
  --                              with the baseline will also be dropped. 
  --                              Otherwise, only the baseline is removed.
  --
  PROCEDURE drop_baseline(baseline_name IN VARCHAR2,
                          cascade       IN BOOLEAN DEFAULT false,
                          dbid          IN NUMBER DEFAULT NULL
                          );


  -- ***********************************************************
  --  awr_report_text and _html (FUNCTION)
  --    This is the table function that will display the 
  --    AWR report in either text or HTML.  The output will be 
  --     one column of VARCHAR2(80) or (150), respectively
  --
  --    The report will take as input the following parameters:
  --      l_dbid     - database identifier
  --      l_inst_num - instance number
  --      l_bid      - Begin Snap Id
  --      l_eid      - End Snapshot Id
  -- ***********************************************************
  FUNCTION awr_report_text(l_dbid     IN NUMBER, 
                           l_inst_num IN NUMBER, 
                           l_bid      IN NUMBER, 
                           l_eid      IN NUMBER,
                           l_options  IN NUMBER DEFAULT 0)
  RETURN awrrpt_text_type_table PIPELINED;

  FUNCTION awr_report_html(l_dbid     IN NUMBER, 
                           l_inst_num IN NUMBER, 
                           l_bid      IN NUMBER, 
                           l_eid      IN NUMBER,
                           l_options  IN NUMBER DEFAULT 0)
  RETURN awrrpt_html_type_table PIPELINED;


  -- ***********************************************************
  --  awr_sql_report_text (FUNCTION)
  --    This is the function that will return the 
  --    AWR SQL Report in text format
  --    Output will be one column of VARCHAR2(120)
  --
  --  awr_sql_report_html (FUNCTION)
  --    This is the function that will return the 
  --    AWR SQL Report in html format
  --    Output will be one column of VARCHAR2(500)
  --
  --    The report will take as input the following parameters:
  --      l_dbid     - database identifier
  --      l_inst_num - instance number
  --      l_bid      - Begin Snapshot Id
  --      l_eid      - End Snapshot Id
  --      l_sqlid    - SQL Id of statement to be analyzed
  --      l_options  - Report level (not used yet)
  FUNCTION awr_sql_report_text(l_dbid     IN NUMBER, 
                               l_inst_num IN NUMBER, 
                               l_bid      IN NUMBER, 
                               l_eid      IN NUMBER,
                               l_sqlid    IN VARCHAR2,
                               l_options  IN NUMBER DEFAULT 0)
  RETURN awrsqrpt_text_type_table PIPELINED;

  FUNCTION awr_sql_report_html(l_dbid     IN NUMBER, 
                               l_inst_num IN NUMBER, 
                               l_bid      IN NUMBER, 
                               l_eid      IN NUMBER,
                               l_sqlid    IN VARCHAR2,
                               l_options  IN NUMBER DEFAULT 0)
  RETURN awrrpt_html_type_table PIPELINED;

 
  -- ***********************************************************
  --  awr_diff_report_text (FUNCTION)
  --    This is the table function that will display the
  --    AWR Compare Periods Report in text format.  The output 
  --    will be one column of VARCHAR2(240).
  --
  --    The report will take as input the following parameters:
  --      dbid1     - 1st database identifier
  --      inst_num1 - 1st instance number
  --      bid1      - 1st Begin Snap Id
  --      eid1      - 1st End Snapshot Id
  --      dbid2     - 2nd database identifier
  --      inst_num2 - 2nd instance number
  --      bid2      - 2nd Begin Snap Id
  --      eid2      - 2nd End Snapshot Id
  -- ***********************************************************
  FUNCTION awr_diff_report_text(dbid1     IN NUMBER,
                                inst_num1 IN NUMBER,
                                bid1      IN NUMBER,
                                eid1      IN NUMBER,
                                dbid2     IN NUMBER,
                                inst_num2 IN NUMBER,
                                bid2      IN NUMBER,
                                eid2      IN NUMBER)
  RETURN awrdrpt_text_type_table PIPELINED;

  -- ***********************************************************
  --  awr_diff_report_html (FUNCTION)
  --    This is the table function that will display the
  --    AWR Compare Periods Report in HTML format.  The output 
  --    will be one column of VARCHAR2(500).
  --
  --    The report will take as input the following parameters:
  --      dbid1     - 1st database identifier
  --      inst_num1 - 1st instance number
  --      bid1      - 1st Begin Snap Id
  --      eid1      - 1st End Snapshot Id
  --      dbid2     - 2nd database identifier
  --      inst_num2 - 2nd instance number
  --      bid2      - 2nd Begin Snap Id
  --      eid2      - 2nd End Snapshot Id
  -- ***********************************************************
  FUNCTION awr_diff_report_html(dbid1     IN NUMBER,
                                inst_num1 IN NUMBER,
                                bid1      IN NUMBER,
                                eid1      IN NUMBER,
                                dbid2     IN NUMBER,
                                inst_num2 IN NUMBER,
                                bid2      IN NUMBER,
                                eid2      IN NUMBER)
  RETURN awrrpt_html_type_table PIPELINED;

  -- ***********************************************************
  --  ash_report_text (FUNCTION)
  --    This is the function that will return the 
  --    ASH Spot report in text format. 
  --    Output will be one column of VARCHAR2(80)
  --
  --  ash_report_html (FUNCTION)
  --    This is the function that will return the 
  --    ASH Spot report in html format.
  --    Output will be one column of VARCHAR2(500)
  --
  --    The report will take as input the following parameters:
  --      l_dbid        - Database identifier
  --      l_inst_num    - Instance number
  --      l_btime       - Begin time
  --      l_etime       - End time
  --      l_options     - Report level (not used yet)
  --      l_slot_width  - Specifies (in seconds) how wide the slots used 
  --                      in the "Top Activity" section of the report 
  --                      should be. This argument is optional, and if it is
  --                      not specified the time interval between l_btime and
  --                      l_etime is appropriately split into not 
  --                      more than 10 slots.
  --
  --    The rest of the optional arguments are all used to specify 
  --    'report targets', if you want to generate the ASH Report on a 
  --    particular target like a sql statement, or a session, or a particular
  --    Service/Module combination. 
  --
  --    In other words, these arguments can be specified 
  --    to restrict the ASH rows that would be used to generate the report. 
  --
  --         For example, to generate an ASH report on a 
  --         particular SQL statement, say SQL_ID 'abcdefghij123'
  --         pass that sql_id value to the l_sql_id argument:
  --            l_sql_id => 'abcdefghij123'
  --
  --    Any combination of those optional arguments can be passed in, and
  --    the only rows in ASH that satisfy all of those 'report targets' will
  --    be used. In other words, if multiple 'report targets' are specified
  --    AND conditional logic is used to connect them.
  --
  --         For example, to generate an ASH report on
  --         MODULE "PAYROLL" and ACTION "PROCESS"
  --         one can use the following predicate:
  --            l_module => 'PAYROLL', l_action => 'PROCESS'
  --
  --    Valid SQL wildcards can be used in all the arguments that are of type
  --    VARCHAR2.
  --
  --       ===============   =================================   =========
  --           Argument      Comment                             Wildcards
  --             Name                                            Allowed?
  --       ===============   =================================   =========
  --        l_sid            Session id                          No
  --                         eg. V$SESSION.SID
  --                         
  --        l_sql_id         SQL id                              Yes
  --                         eg. V$SQL.SQL_ID
  --
  --        l_wait_class     Wait class name                     Yes
  --                         eg. V$EVENT_NAME.WAIT_CLASS
  --
  --        l_service_hash   Service name hash                   No
  --                         eg. V$ACTIVE_SERVICES.NAME_HASH
  --
  --        l_module         Module name                         Yes
  --                         eg. V$SESSION.MODULE
  --
  --        l_action         Action name                         Yes
  --                         eg. V$SESSION.ACTION
  --
  --        l_client_id      Client identifier for               Yes
  --                         end-to-end tracing
  --                         eg. V$SESSION.CLIENT_IDENTIFIER
  --       ===============   =================================   =========
  --
  -- ***********************************************************
  FUNCTION ash_report_text(l_dbid          IN NUMBER, 
                           l_inst_num      IN NUMBER, 
                           l_btime         IN DATE,
                           l_etime         IN DATE,
                           l_options       IN NUMBER    DEFAULT 0,
                           l_slot_width    IN NUMBER    DEFAULT 0,
                           l_sid           IN NUMBER    DEFAULT NULL,
                           l_sql_id        IN VARCHAR2  DEFAULT NULL,
                           l_wait_class    IN VARCHAR2  DEFAULT NULL,
                           l_service_hash  IN NUMBER    DEFAULT NULL,
                           l_module        IN VARCHAR2  DEFAULT NULL,
                           l_action        IN VARCHAR2  DEFAULT NULL,
                           l_client_id     IN VARCHAR2  DEFAULT NULL
                          )
  RETURN awrrpt_text_type_table PIPELINED;

  FUNCTION ash_report_html(l_dbid          IN NUMBER, 
                           l_inst_num      IN NUMBER, 
                           l_btime         IN DATE,
                           l_etime         IN DATE,
                           l_options       IN NUMBER    DEFAULT 0,
                           l_slot_width    IN NUMBER    DEFAULT 0,
                           l_sid           IN NUMBER    DEFAULT NULL,
                           l_sql_id        IN VARCHAR2  DEFAULT NULL,
                           l_wait_class    IN VARCHAR2  DEFAULT NULL,
                           l_service_hash  IN NUMBER    DEFAULT NULL,
                           l_module        IN VARCHAR2  DEFAULT NULL,
                           l_action        IN VARCHAR2  DEFAULT NULL,
                           l_client_id     IN VARCHAR2  DEFAULT NULL
                          )
  RETURN awrrpt_html_type_table PIPELINED;

END dbms_workload_repository;
/
CREATE OR REPLACE PUBLIC SYNONYM dbms_workload_repository 
FOR sys.dbms_workload_repository
/
GRANT EXECUTE ON dbms_workload_repository TO dba
/
-- create the trusted pl/sql callout library
CREATE OR REPLACE LIBRARY DBMS_SWRF_LIB TRUSTED AS STATIC;
/
