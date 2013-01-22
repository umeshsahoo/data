-- 
-- $Header: dbmssum.sql 27-oct-2003.11:15:12 mxiao Exp $
-- 
-- dbmssum.sql
-- 
--  Copyright (c) Oracle Corporation 1997, 1998, 1999, 2000. All Rights Reserved.
-- 
--    NAME
--      dbmssum.sql - PUBLIC interface FOR SUMMARY refresh
-- 
--    DESCRIPTION
--      defines specifification FOR packages dbms_summary
--   
-- 
--    NOTES
--      <other useful comments, qualifications, etc.>
-- 
--    MODIFIED   (MM/DD/YY)
--    mxiao       10/27/03 - change the argument in describe_dimension 
--    mxiao       01/14/03 - remove the incremental from validate_dimension
--    mxiao       12/13/02 - add dbms_dimension package
--    mxiao       07/25/02 - add describe_dimension to dbms_olap
--    gssmith     08/24/01 - Adjustments to filters
--    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
--    btao        03/23/01 - Remove old 9i interface.
--    gssmith     02/22/01 - MV to MVIEW
--    btao        03/02/01 - fix constants FILTER_NONE and WORKLOAD_NONE.
--    gssmith     01/02/01 - Bug 1488357.
--    gssmith     11/02/00 - Script bug.
--    gssmith     10/31/00 - Bug 1479115.
--    btao        10/26/00 - fix typo regarding ADVISOR_RPT_RECOMMEDATION.
--    gssmith     09/19/00 - Purge workload bug
--    gssmith     08/25/00 - Advisor call change
--    mthiyaga    09/12/00 - Move EXPLAIN_REWRITE to dbmssnap.sql
--    btao        07/19/00 - fix comments
--    btao        07/13/00 - add ADVISOR_WORKLOAD_OVERWRITE flag
--    btao        07/06/00 - update 8.2 interface to include collection_id
--    btao        06/20/00 - remove redundant refresh code
--    mthiyaga    03/29/00 - Add EXPLAIN_REWRITE interface
--    gssmith     04/10/00 - Fine tuning Advisor calls and constants
--    btao        01/07/00 - add 8.2 advisor interface
--    bpanchap    06/02/99 - Adding user info
--    btao        04/23/99 - Disable anchorness
--    wnorcott    10/14/98 - Enable anchorness
--    ncramesh    08/10/98 - change for sqlplus
--    wnorcott    08/19/98 - Logging and set on/off qsmkganc
--    qiwang      08/07/98 - Rename verify_dimension to validate_dimension
--    sramakri    06/30/98 - Replace CREATE LIBRARY dbms_sumadv_lib with 
--                           @@dbmssml.sql
--    wnorcott    06/16/98 - procedure set_logfile_name
--    wnorcott    06/16/98 - get rid of set echo
--    ato         06/18/98 - remove set echo off to allow debugging
--    wnorcott    06/02/98 - Add DBMS_OLAP synonym
--    qiwang      05/28/98 - Add interface for Verify Dimension
--    wnorcott    05/22/98 - change specification for compute_variance, compute
--    wnorcott    05/18/98 - Required changes to refresh interface
--    wnorcott    04/09/98 - Move private interfaces to prvtsum.sql
--    wnorcott    04/03/98 - set_session_longops changed without warning
--    wnorcott    04/22/98 - Add on/off switch for cleanup_sumdelta
--    sramakri    04/08/98 - Summary Advisor functions
--    wnorcott    04/07/98 - procedure for nullness in stat functions
--    wnorcott    04/03/98 - set_session_longops changed without warning
--    wnorcott    02/21/98 - add refresh_mask output to qsmkrfx
--    wnorcott    02/12/98 - Add Refresh_in_C
--    wnorcott    02/04/98 - Add 3gl for callout to kprb
--    wnorcott    01/28/98 - Move qsmkanc out of ICD vector
--    wnorcott    01/20/98 - New ICD to test for anchorness
--    wnorcott    12/31/97 - make anchorlist a package global
--    wnorcott    12/30/97 - rename a couple procedures for clarity
--    wnorcott    12/23/97 - Split refresh into 3 packages in the same file
--    wnorcott    11/17/97 - Add entry for qsmkscn
--    wnorcott    10/16/97 - PUBLIC interface for summary refresh.
--    wnorcott    10/16/97 - Created
-- 
CREATE OR REPLACE PACKAGE dbms_summary authid current_user                                       
  /*                                                                            
 || Program: dbms_summary                                                      
 ||  Author: William D. Norcott, Oracle Corportation
 ||    File: dbmssum.sql                                                  
 || Created: September 11, 1997 15:11:36                                       
 */                                                                            
IS                                                                            
-- Package global variables
dimensionnotfound EXCEPTION;

-- Package constant variables

-- add new workload
WORKLOAD_NEW CONSTANT NUMBER := 0;

-- replace current workload
WORKLOAD_OVERWRITE CONSTANT NUMBER := 1;

-- add to current workload
WORKLOAD_APPEND CONSTANT NUMBER := 2;

-- special filter id indicating no filtering
FILTER_NONE CONSTANT NUMBER := -999;

-- special filter id indicating all filters
FILTER_ALL CONSTANT NUMBER := -999;

-- special run id indicating all runids
RUNID_ALL CONSTANT NUMBER := -999;

-- special workload id indicating all workload collections
WORKLOAD_ALL CONSTANT NUMBER := -999;

-- special workload id indicating no workload provided
WORKLOAD_NONE CONSTANT NUMBER := -998;

-- Bit flags for GENERATE_MVIEW_REPORT
RPT_ACTIVITY constant number               := 1;
RPT_JOURNAL constant number                := 2;
RPT_WORKLOAD_FILTER constant number        := 4;
RPT_WORKLOAD_DETAIL constant number        := 8;
RPT_WORKLOAD_QUERY constant number         := 16;
RPT_RECOMMENDATION constant number         := 32;
RPT_USAGE constant number                  := 64;
RPT_ALL constant number                    := 127;

-- Validation flags for VALIDATE_WORKLOAD calls
VALID    CONSTANT NUMBER    := 1;
INVALID  CONSTANT NUMBER    := 0;

-- Interface for private trace facility used by the advisor 
PROCEDURE set_logfile_name(filename IN VARCHAR2 );

-- 8.2 interface for advisory functions 
--    PROCEDURE DBMS_SUMMARY.ADD_FILTER_ITEM
--    PURPOSE: Add a new filter item to an existing filter
--    PARAMETERS:
--         filter_id: NUMBER
--            It should be an internal ID generated by the create_id() 
--            A filter_id uniquely identify a filter, which is composed
--            of one or more filter items
--         filter_name:
--            The following filter item types are supported. Each filter item 
--            may be a comma-separated string list, a numerical
--            value range or a date range
--            'APPLICATION'        - String,    workload's application column 
--            'BASETABLE'          - String,    base tables referenced 
--                                              by workload queries
--            'CARDINALITY'        - Numerical, sum of cardinality of the 
--                                              referenced base tables
--            'FREQUENCY'          - Numerical, workload's frequency column
--            'LASTUSE'            - Date,      workload's lastuse column
--            'PRIORITY'           - Numerical, workload's priority column
--            'RESPONSETIME'       - Numerical  workload's responsetime column
--            'SCHEMA'             - String,    list of schemas 
--            'TRACENAME'          - String,    list of oracle trace collection
--                                              names     
--            'USER'               - String,    name of user who executes query
--         number_min: NUMBER
--            The lower bound of a numerical range 
--            NULL represents the lowest possible value
--         number_max: NUMBER
--            The upper bound of a numerical range, NULL for no upper bound
--            NULL represents the highest possible value
--         string_list: VARCHAR2 
--            A comma-separated list of strings
--            Must be non-NULL for filter of the String type
--         date_min: DATE
--            The lower bound of a date range 
--            NULL represents the lowest possible date value
--         date_max: DATE
--            The upper bound of a date range
--            NULL represents the highest possible date value
--
--         For filters of the String type, only the 'string_list' parameter 
--            is used
--         For filters of the Numerical type, only the 'number_min' and 
--            'number_max' parameters are used
--         For filters of the Date type, only the 'date_min' and 'date_max' 
--            parameters are used

PROCEDURE add_filter_item(
                filter_id               IN NUMBER,
                filter_name             IN VARCHAR2,
                string_list             IN VARCHAR2,
                number_min              IN NUMBER,
                number_max              IN NUMBER,
                date_min                IN VARCHAR2,
                date_max                IN VARCHAR2);

--    PROCEDURE DBMS_SUMMARY.DELETE_FILTER_ITEM
--    PURPOSE: Removes a filter item from an existing filter
--    PARAMETERS:
--         filter_id: NUMBER
--            It should be an internal ID generated by the create_id() 
--            A filter_id uniquely identify a filter, which is composed
--            of one or more filter items
--         filter_name:
--            The following filter item types are supported. Each filter item 
--            may be a comma-separated string list, a numerical
--            value range or a date range
--            'APPLICATION'        - String,    workload's application column 
--            'BASETABLE'          - String,    base tables referenced 
--                                              by workload queries
--            'CARDINALITY'        - Numerical, sum of cardinality of the 
--                                              referenced base tables
--            'FREQUENCY'          - Numerical, workload's frequency column
--            'LASTUSE'            - Date,      workload's lastuse column
--            'PRIORITY'           - Numerical, workload's priority column
--            'RESPONSETIME'       - Numerical  workload's responsetime column
--            'SCHEMA'             - String,    list of schemas 
--            'TRACENAME'          - String,    list of oracle trace collection
--                                              names     
--            'USER'               - String,    name of user who executes query

PROCEDURE delete_filter_item(
                filter_id               IN NUMBER,
                filter_name             IN VARCHAR2);

--    PROCEDURE: DBMS_SUMMARY.PURGE_FILTER
--    PURPOSE: Delete a filter definition from the advisor system
--    PARAMETERS:         
--         filter_id: NUMBER
--            A unique sequence number used to identify a filter
--            Or FILTER_ALL for purging all filters
PROCEDURE purge_filter(
                       filter_id               IN NUMBER);

--    PROCEDURE: DBMS_SUMMARY.CREATE_ID
--    PURPOSE: Generate an internal ID used by a new workload collection,
--             a new filter or a new advisor run
--    PARAMETERS:         
--         id: NUMBER
--            A unique sequence number used to identify a filter, a workload 
--            collection or a unique advisor run
PROCEDURE create_id(
                id                      OUT NUMBER);

--    PROCEDURE: DBMS_SUMMARY.LOAD_WORKLOAD_TRACE
--    PURPOSE: Load workload into advisor resporitory from an Oracle Trace
--             collection. If a filter is provided, the workload
--             source is filtered before being loaded into advisor repository
--    PARAMETERS:
--         workload_id: NUMBER
--            It should be an internal ID generated by the create_id() 
--         flags: NUMBER
--            WORKLOAD_NEW         the workload is new
--            WORKLOAD_APPEND      append to current workload
--            WORKLOAD_OVERWRITE   overwrite current workload 
--         filter_id: NUMBER
--             A filter_id created by create_id(),
--             Or FILTER_NONE, indicating no filtering
--         application: VARCHAR2
--            The default application value associated with a workload 
--         priority: NUMBER
--            The default priority value to be associated with a workload 
--            collection
--         owner_name: VARCHAR2
--            The name of the schema containing trace tables.
--            If NULL or empty string, current caller's schema is used

PROCEDURE load_workload_trace (
                workload_id             IN NUMBER,
                flags                   IN NUMBER,
                filter_id               IN NUMBER,
                application             IN VARCHAR2,
                priority                IN NUMBER,
                owner_name              IN VARCHAR2);

--    PROCEDURE: DBMS_SUMMARY.LOAD_WORKLOAD_USER
--    PURPOSE: Load workload into advisor resporitory from a user-supplied
--             table or view.  If a filter is provided, the workload
--             source is filtered before being loaded into advisor repository
--    PARAMETERS:
--         workload_id: NUMBER
--            It should be an internal ID generated by the create_id() 
--         flags: NUMBER
--            WORKLOAD_NEW         the workload is new
--            WORKLOAD_APPEND      append to current workload
--            WORKLOAD_OVERWRITE   overwrite current workload 
--         filter_id: NUMBER
--             A filter_id created by create_id(),
--             Or FILTER_NONE, indicating no filtering
--         owner_name: VARCHAR2
--            The name of the schema containing user-supplied workload tables, 
--            If NULL or empty string, current caller's schema is used
--         table_name: VARCHAR2
--            The parameter must be 
--                not NULL and non-empty. It refers to a workload table or 
--                view name. The table/view should contain one or more of
--                the following columns:
--                'APPLICATION'   - String,    application issuing queries
--                'FREQUENCY'     - Numerical, the frequency of the query
--                'LASTUSE'       - Date,      when the query is last issued
--                'OWNER'         - String,    the user issuing the query
--                'PRIORITY'      - Numerical, priority of a query
--                'QUERY'         - String,    SQL text 
--                'RESULTSIZE'    - Numerical, number of bytes of query result
--                'RESPONSETIME'  - Numerical  the response time of the query
--                'SQL_HASH'      - Numerical  the hash value of the SQL text
--                'SQL_ADDR'      - Numerical  the SQL cursor address
--           
--             Among all the columns listed above, only the 'QUERY' column 
--             and the 'OWNER' column are mandatory.
--

PROCEDURE load_workload_user (
                workload_id             IN NUMBER,
                flags                   IN NUMBER,
                filter_id               IN NUMBER,
                owner_name              IN VARCHAR2,
                table_name              IN VARCHAR2);

--    PROCEDURE: DBMS_SUMMARY.LOAD_WORKLOAD_CACHE
--    PURPOSE: Load workload into advisor resporitory from the SQL cache.
--             If a filter is provided, the workload
--             source is filtered before being loaded into advisor repository
--    PARAMETERS:
--         workload_id: NUMBER
--            It should be an internal ID generated by the create_id() 
--         flags: NUMBER
--            WORKLOAD_NEW         the workload is new
--            WORKLOAD_APPEND      append to current workload
--            WORKLOAD_OVERWRITE   overwrite current workload 
--         filter_id: NUMBER
--             A filter_id created by create_id(),
--             Or FILTER_NONE, indicating no filtering
--         application: VARCHAR2
--            The default application value associated with a workload 
--         priority: NUMBER
--            The default priority value to be associated with a workload 
--            collection

PROCEDURE load_workload_cache (
                workload_id             IN NUMBER,
                flags                   IN NUMBER,
                filter_id               IN NUMBER,
                application             IN VARCHAR2,
                priority                IN NUMBER);

--    PROCEDURE DBMS_SUMMARY.VALIDATE_WORKLOAD_TRACE
--    PURPOSE: Validate the Oracle Trace workload before performing load operations
--    PARAMETERS:
--         owner_name see LOAD_WORKLOAD_TRACE
--
--         valid: NUMBER
--            Indicate whether a workload is valid. To be called before loading
--            the workload.
--
--             Valid return values:
--
--                VALID
--                INVALID
--
--         error: VARCHAR2
--            Error text 

PROCEDURE validate_workload_trace (
                owner_name              IN VARCHAR2,
                valid                   OUT NUMBER,
                error                   OUT VARCHAR2);

--    PROCEDURE DBMS_SUMMARY.VALIDATE_WORKLOAD_USER
--    PURPOSE: Validate the user-supplied workload before performing load operations
--    PARAMETERS:
--         owner_name, table_name: see LOAD_WORKLOAD_USER
--
--         valid: NUMBER
--            Indicate whether a workload is valid. To be called before loading
--            the workload.
--
--             Valid return values:
--
--                VALID
--                INVALID

--         error: VARCHAR2
--            Error text 

PROCEDURE validate_workload_user (
                owner_name              IN VARCHAR2,
                table_name              IN VARCHAR2,
                valid                   OUT NUMBER,
                error                   OUT VARCHAR2);

--    PROCEDURE DBMS_SUMMARY.VALIDATE_WORKLOAD_CACHE
--    PURPOSE: Validate the workload before performing load operations
--    PARAMETERS:
--         valid: NUMBER
--            Indicate whether a workload is valid. To be called before loading
--            the workload.
--
--             Valid return values:
--
--                VALID
--                INVALID
--
--         error: VARCHAR2
--            Error text 
PROCEDURE validate_workload_cache (
                valid                   OUT NUMBER,
                error                   OUT VARCHAR2);

--    PROCEDURE DBMS_SUMMARY.GENERATE_MVIEW_REPORT
--    PURPOSE: Generates an HTML-based report on the current Advisor repositor
--    PARAMETERS: 
--          filename:  VARCHAR2
--             Output file to receive HTML data
--          id:        NUMBER
--             Optional ID number for detail report
--          flags:     NUMBER
--             Bit masked flags indicating type of report
PROCEDURE generate_mview_report(filename  IN VARCHAR2,
                                id        IN NUMBER,
                                flags     IN NUMBER);


--    PROCEDURE DBMS_SUMMARY.GENERATE_MVIEW_SCRIPT
--    PURPOSE: Generates a simple script containing the SQL commands to 
--             implement Summary Advisor recommendations
--    PARAMETERS: 
--          filename:  VARCHAR2
--             Output file to receive SQL script commands
--          id:        NUMBER
--             Optional ID number for script
--          tapace:    VARCHAR2
--             Optional tablespace name to use when creating materialized views
PROCEDURE generate_mview_script(filename  IN VARCHAR2,
                                id        IN NUMBER,
                                tspace    IN VARCHAR2);

--    FUNCTION DBMS_SUMMARY.GET_PROPERTY
--    PURPOSE: Returns a Summary Advisor runtime property.
--    PARAMETERS: 
--          name:  VARCHAR2
--             The full property name as defined by the Summary Advisor.
FUNCTION get_property (name IN VARCHAR2) RETURN VARCHAR2;

--    PROCEDURE DBMS_SUMMARY.SET_PROPERTY
--    PURPOSE: Sets the value for a Summary Advisor property.  The value is
--             valid for the current session only.
--    PARAMETERS: 
--          name:  VARCHAR2
--             The full property name as defined by the Summary Advisor.
--          value: VARCHAR2
--             The value to be assigned.
PROCEDURE set_property (name     IN VARCHAR2, 
                        value    IN VARCHAR2);

--    PROCEDURE DBMS_SUMMARY.SHOW_PROPERTIES
--    PURPOSE: Displays the current Summary Advisor properties. 
--    PARAMETERS: 
--          none
PROCEDURE show_properties;

--    PROCEDURE DBMS_SUMMARY.PURGE_WORKLOAD
--    PURPOSE: Purge a subset of workload from advisor repository. The subset
--             is again specified with a filter
--    PARAMETERS:
--         workload_id: NUMBER
--             workload id generated by the create_id()
--             Or WORKLOAD_ALL to purge all existing collections
PROCEDURE purge_workload(
                workload_id           IN NUMBER);

--    PROCEDURE DBMS_SUMMARY.PURGE_RESULTS
--    PURPOSE: Purge the output in advisor repository generated by current user.
--             A result will be purged if and only if its runid is within the
--             range specified by the user
--    PARAMETERS:
--         run_id: NUMBER
--            It should be an internal ID generated by the create_id() 
--            Or RUNID_ALL to purge all results generated by the
--            current caller
PROCEDURE purge_results(
                run_id                  IN NUMBER);

--    PROCEDURE DBMS_SUMMARY.SET_CANCELLED
--    PURPOSE: Request to cancel the operation of a run
--    PARAMETERS:
--         run_id: NUMBER
--            See purge_workload
PROCEDURE set_cancelled (
                run_id                  IN NUMBER);

--    PROCEDURE DBMS_SUMMARY.VALIDATE_DIMENSION 
--    PURPOSE: To verify that the relationships specified in a DIMENSION
--             are correct. Offending rowids are stored in advisor repository
--    PARAMETERS:
--         dimension_name: VARCHAR2
--            Name of the dimension to analyze
--
--         dimension_owner: VARCHAR2
--            Owner of the dimension
--
--         incremental: BOOLEAN (default: TRUE)
--            If TRUE, then tests are performed only for the rows specified
--            in the sumdelta$ table for tables of this dimension; if FALSE,
--            check all rows.
--
--         check_nulls: BOOLEAN (default: FALSE)
--            If TRUE, then all level columns are verified to be non-null;
--            If FALSE, this check is omitted. Specify FALSE when non-nullness
--            is guaranteed by other means, such as NOT NULL constraints.
--
--         run_id: NUMBER
--            See purge_workload
--
--    EXCEPTIONS:
--             dimensionnotfound       The specified dimension was not found 
PROCEDURE validate_dimension
                (
                dimension_name          IN VARCHAR2,
                dimension_owner         IN VARCHAR2,
                incremental             IN BOOLEAN,
                check_nulls             IN BOOLEAN,
                run_id                  IN NUMBER);

--    PROCEDURE DBMS_SUMMARY.RECOMMEND_MVIEW_STRATEGY
--    PURPOSE: Recommend summary 
--    PARAMETERS:
--         run_id: NUMBER
--            Unique identifier that was created using the create_id call.
--
--         workload_id: NUMBER
--            Optional workload id that references an existing workload collection
--            in the Advisor repository.  If ommitted, analysis will be performed
--            on a hypothetical workload.
-- 
--         filter_id: NUMBER
--            Optional filter that will be applied to the workload
--
--         storage_in_bytes: NUMBER
--            Optional storage budget in bytes
--
--         retention_pct: NUMBER
--            Optional percentage of materialized view to be retained
--
--         retention_list: VARCHAR2
--            Optional list of materialized view that must be retained
--
--         fact_table_filter: VARCHAR2
--            Optional list of fact tables used to filter real or ideal workload
--
PROCEDURE recommend_mview_strategy (
                run_id                  IN NUMBER,
                workload_id             IN NUMBER,
                filter_id               IN NUMBER,
                storage_in_bytes        IN NUMBER,
                retention_pct           IN NUMBER,
                retention_list          IN VARCHAR2,
                fact_table_filter       IN VARCHAR2);

--    PROCEDURE DBMS_SUMMARY.EVALUATE_MVIEW_STRATEGY
--    PURPOSE: Evaluate summary utilization 
--    PARAMETERS:
--         run_id: NUMBER
--            See purge_workload
--         workload_id: NUMBER
--            See load_workload_trace
--         filter_id: NUMBER
PROCEDURE evaluate_mview_strategy (
                run_id                  IN NUMBER,
                workload_id             IN NUMBER,
                filter_id               IN NUMBER);


--    PROCEDURE DBMS_SUMMARY.ESTIMATE_SUMMARY_SIZE
--    PURPOSE: Estimate summary size in terms of rows and bytes
--    PARAMETERS:
--         stmt_id: NUMBER
--            User-specified id 
--         select_clause: VARCHAR@
--            SQL text for the defining query
--         num_row: NUMBER
--            Estimated number of rows 
--         num_col: NUMBER
--            Estimated number of bytes
--   COMMENTS:
--         This procedure requires that 'utlxplan.sql' be executed
PROCEDURE estimate_summary_size (
                                 stmt_id         IN VARCHAR2,
                                 select_clause   IN VARCHAR2,
                                 num_rows        OUT NUMBER,
                                 num_bytes       OUT NUMBER);
PROCEDURE estimate_mview_size (
                                 stmt_id         IN VARCHAR2,
                                 select_clause   IN VARCHAR2,
                                 num_rows        OUT NUMBER,
                                 num_bytes       OUT NUMBER);
PROCEDURE enable_dependent (
                            detail_tables      IN  VARCHAR2);

PROCEDURE disable_dependent (
                             detail_tables      IN  VARCHAR2);

-- obsolete 8.1 interface begin
PROCEDURE validate_dimension
                (
                dimension_name          IN VARCHAR2,
                dimension_owner         IN VARCHAR2,
                incremental             IN BOOLEAN := TRUE,
                check_nulls             IN BOOLEAN := FALSE);

PROCEDURE recommend_mv       (
                fact_table_filter       IN VARCHAR2,
                storage_in_bytes        IN NUMBER,
                retention_list          IN VARCHAR2,
                retention_pct           IN NUMBER := 50);

PROCEDURE recommend_mv_w (
                fact_table_filter       IN VARCHAR2,
                storage_in_bytes        IN NUMBER,
                retention_list          IN VARCHAR2,
                retention_pct           IN NUMBER := 80);

PROCEDURE evaluate_utilization;

PROCEDURE evaluate_utilization_w;


END dbms_summary;                                                             
/                                                                             
GRANT EXECUTE ON dbms_summary TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM dbms_summary FOR dbms_summary;
CREATE OR REPLACE PUBLIC SYNONYM dbms_olap FOR dbms_summary;
Rem The following line:
Rem CREATE OR REPLACE LIBRARY dbms_sumadv_lib AS '/vobs/rdbms/lib/libqsmashr.so';
Rem now comes from dbmssml.sql, which is generated from osds/dbmssml.sbs
@@dbmssml.sql
/

-------------------------------------------------------------------------------
-- Package: dbms_dimension
-- Creator: Min Xiao, Oracle Corportation
--    File: dbmssum.sql                                                  
-- Created: Dec, 2002
--                                                                            
CREATE OR REPLACE PACKAGE dbms_dimension authid current_user                                       
IS 
   ----------------------------------------------------------------------------
   -- public constants
   ----------------------------------------------------------------------------
   dimensionnotfound EXCEPTION;
 
   ----------------------------------------------------------------------------
   -- public procedures:
   ----------------------------------------------------------------------------
   
   ----------------------------------------------------------------------------
   --    PROCEDURE DBMS_DIMENSION.DESCRIBE_DIMENSION
   --    PURPOSE: prints out the definition of the input dimension, including 
   --             dimension owner and name, levels, hierarchies, attributes. 
   --             It displays the output via dbms_output.
   --    PARAMETERS:
   --         dimension: VARCHAR2
   --            Name of the dimension, e.g. 'scott.dim1', 'scott.%', etc.
   --
   --    EXCEPTIONS:
   --             dimensionnotfound       The specified dimension was not found 
   PROCEDURE describe_dimension(dimension IN VARCHAR2);

   ----------------------------------------------------------------------------
   --    PROCEDURE DBMS_DIMENSION.VALIDATE_DIMENSION 
   --    PURPOSE: To verify that the relationships specified in a DIMENSION
   --             are correct. Offending rowids are stored in advisor repository
   --    PARAMETERS:
   --         dimension: VARCHAR2
   --            Owner and name of the dimension in the format of 'owner.name'.
   --
   --         incremental: BOOLEAN (default: TRUE)
   --            If TRUE, then tests are performed only for the rows specified
   --            in the sumdelta$ table for tables of this dimension; if FALSE,
   --            check all rows.
   --
   --         check_nulls: BOOLEAN (default: FALSE)
   --            If TRUE, then all level columns are verified to be non-null;
   --            If FALSE, this check is omitted. Specify FALSE when non-nullness
   --            is guaranteed by other means, such as NOT NULL constraints.
   --
   --         statement_id: VARCHAR2 (default: NULL)
   --            A client-supplied unique identifier to associate output rows 
   --            with specific invocations of the procedure.
   --
   --    EXCEPTIONS:
   --             dimensionnotfound       The specified dimension was not found 
   -- 
   --    NOTE: It is the 10i new interface. The 8.1 and 9i interfaces are deprecated,
   --          but they should still remain working in 10i and after.
   PROCEDURE validate_dimension
     (
      dimension               IN VARCHAR2,
      incremental             IN BOOLEAN := TRUE,
      check_nulls             IN BOOLEAN := FALSE,
      statement_id            IN VARCHAR2 := NULL );

   ----------------------------------------------------------------------------
   --    PROCEDURE DBMS_DIMENSION.VALIDATE_DIMENSION
   --    PURPOSE: To verify that the relationships specified in a DIMENSION
   --             are correct. Offending rowids are stored in advisor repository
   --    PARAMETERS:
   --         dimension: VARCHAR2
   --            Owner and name of the dimension in the format of 'owner.name'.
   --
   --         check_nulls: BOOLEAN (default: FALSE)
   --            If TRUE, then all level columns are verified to be non-null;
   --            If FALSE, this check is omitted. Specify FALSE when non-nullness
   --            is guaranteed by other means, such as NOT NULL constraints.
   --
   --         statement_id: VARCHAR2 (default: NULL)
   --            A client-supplied unique identifier to associate output rows
   --            with specific invocations of the procedure.
   --
   --    EXCEPTIONS:
   --             dimensionnotfound       The specified dimension was not found
   --
   --    NOTE: It is the 10i new interface. The 8.1 and 9i interfaces are deprecated,
   --          but they should still remain working in 10i and after.
   PROCEDURE validate_dimension
     (
      dimension               IN VARCHAR2,
      check_nulls             IN BOOLEAN := FALSE,
      statement_id            IN VARCHAR2 := NULL );

END dbms_dimension;
/
   
GRANT EXECUTE ON dbms_dimension TO PUBLIC
/ 
CREATE OR REPLACE PUBLIC SYNONYM dbms_dimension FOR sys.dbms_dimension
/ 

