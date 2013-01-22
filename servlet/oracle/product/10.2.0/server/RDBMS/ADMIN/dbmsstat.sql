Rem
Rem $Header: dbmsstat.sql 17-mar-2005.16:17:28 schakkap Exp $
Rem
Rem dbmsstat.sql
Rem
Rem Copyright (c) 1998, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmsstat.sql - statistics gathering package
Rem
Rem    DESCRIPTION
Rem      This package provides a mechanism for users to view and modify
Rem      optimizer statistics gathered for database objects.
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    schakkap    03/03/05 - #(4219954) force for gather*stats 
Rem    mtakahar    09/15/04 - add cleanup_stats_job_proc
Rem    schakkap    09/01/04 - #(3867864): no_invalidate for restore 
Rem    schakkap    06/03/04 - add reset_param_defaults 
Rem    dgagne      06/23/04 - allow stats table to be global temporary 
Rem    schakkap    12/23/03 - add comments for restore 
Rem    schakkap    12/09/03 - granularity and AUTOSTATS_TARGET for set_param
Rem    schakkap    10/28/03 - AUTO_INVALIDATE
Rem    schakkap    09/29/03 - [get|set]_param 
Rem    schakkap    08/26/03 - lock, copy partition stats 
Rem    schakkap    08/04/03 - gather_sys => true
Rem    schakkap    06/02/03 - make stats retention configurable
Rem    schakkap    01/15/03 - restore stats
Rem    mtyulene    01/07/03 - add gather cache stats
Rem    schakkap    12/31/02 - lock/unlock statistics
Rem    mtakahar    09/10/02 - automated statistics collection
Rem    schakkap    11/20/02 - statistics on dictionary
Rem    mtyulene    10/03/02 - add support for cache stats
Rem    mdcallag    10/22/02 - support binary_float and binary_double
Rem    schakkap    09/09/02 - gather/delete/export/import_fixed_objects_stats
Rem    mtakahar    09/25/02 - add AUTO_DEGREE/granularity='AUTO'
Rem    mtakahar    08/07/02 - make alter_*_tab_monitoring no-op
Rem    mtyulene    01/22/02 - change default gathering_mode in 
Rem                           gather_system_stats to NOWORKLOAD
Rem    mtakahar    01/31/02 - #(2200979): removed gather_index_stats overload
Rem    schakkap    10/12/01 - add gather_fixed.
Rem    mtakahar    10/15/01 - remove 'drop role gather_system_statistics'
Rem    ayoaz       09/24/01 - support user statistics
Rem    mtakahar    09/26/01 - gather_index_stats enhancements
Rem    mtakahar    07/20/01 - IOT guess quality
Rem    mtakahar    07/23/01 - #(1107252): add gather_temp
Rem    mtyulene    05/30/01 - #(1805416): create role gather_system_statistics 
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    mtakahar    03/28/01 - alter_*_tab_monitoring
Rem    mtakahar    03/26/01 - flush_database_monitoring_info
Rem    mtakahar    02/14/01 - add no_invalidate
Rem    mtakahar    02/20/01 - add gather_sys arg
Rem    mtakahar    11/15/00 - add options=>'GATHER AUTO' and 'LIST AUTO'
Rem    mtakahar    10/17/00 - add DEFAULT_DEGREE
Rem    mtyulene    09/05/00 - add *_system_stats procedures
Rem    amozes      07/28/99 - simple gather stats                              
Rem    amozes      06/15/99 - #(909413) split create_stat_table errors         
Rem    amozes      03/08/99 - add upgrade_stat_table                           
Rem    amozes      10/29/98 - bug 755475: string buffer to small               
Rem    amozes      10/21/98 - bug 598799
Rem    amozes      09/11/98 - add statown to most procedures                   
Rem    amozes      07/22/98 - add generate stats functionality                 
Rem    ncramesh    08/07/98 - change for sqlplus
Rem    amozes      06/16/98 - add dbms_stats library                           
Rem    ddas        05/06/98 - add purity pragmas
Rem    amozes      04/30/98 - auto_gather_stats feature support                
Rem    amozes      03/26/98 - new subpartition and func index options          
Rem    amozes      03/23/98 - allow flags to be passed in for import           
Rem    amozes      02/16/98 - delete functionality
Rem    amozes      01/14/98 - Created
Rem

create or replace package dbms_stats authid current_user is

--
-- This package provides a mechanism for users to view and modify
-- optimizer statistics gathered for database objects.
-- The statistics can reside in two different locations:
--  1) in the dictionary
--  2) in a table created in the user's schema for this purpose
-- Only statistics stored in the dictionary itself will have an
-- impact on the cost-based optimizer.
--
-- This package also facilitates the gathering of some statistics 
-- in parallel.
-- 
-- The package is divided into three main sections:
--  1) procedures which set/get individual stats.
--  2) procedures which transfer stats between the dictionary and
--     user stat tables.
--  3) procedures which gather certain classes of optimizer statistics
--     and have improved (or equivalent) performance characteristics as 
--     compared to the analyze command.
--
-- Most of the procedures include the three parameters: statown,
-- stattab, and statid.  
-- These parameters are provided to allow users to store statistics in 
-- their own tables (outside of the dictionary) which will not affect 
-- the optimizer.  Users can thereby maintain and experiment with "sets" 
-- of statistics without fear of permanently changing good dictionary 
-- statistics.  The stattab parameter is used to specify the name of a 
-- table in which to hold statistics and is assumed to reside in the same
-- schema as the object for which statistics are collected (unless the
-- statown parameter is specified).  Users may create 
-- multiple such tables with different stattab identifiers to hold separate 
-- sets of statistics.  Additionally, users can maintain different sets of 
-- statistics within a single stattab by making use of the statid 
-- parameter (which can help avoid cluttering the user's schema).
--
-- For all of the set/get procedures, if stattab is not provided (i.e., null), 
-- the operation will work directly on the dictionary statistics; therefore, 
-- users need not create these statistics tables if they only plan to 
-- modify the dictionary directly.  However, if stattab is not null, 
-- then the set/get operation will work on the specified user statistics 
-- table, not the dictionary.
--
-- lock_*_stats/unlock_*_stats procedures: When statistics on a table is
-- locked, all the statistics depending on the table, including table
-- statistics, column statistics, histograms and statistics on all
-- dependent indexes, are considered to be locked. 
-- set_*, delete_*, import_*, gather_* procedures that modify statistics
-- in dictionary of an individual table/index/column will raise an error 
-- if statistics of the object is locked. Procedures that operates on
-- multiple objects (eg: gather_schema_stats) will skip modifying the
-- statistics of an object if it is locked. Most of the procedures have
-- force argument to override the lock. 
-- 
-- Whenever statistics in dictionary are modified, old versions of statistics 
-- are saved automatically for future restoring. Statistics can be restored 
-- using RESTORE procedures. These procedures use a time stamp as an argument 
-- and restore statistics as of that time stamp.
-- There are dictionary views that display the time of statistics 
-- modifications. These views are useful in determining the time stamp to 
-- be used for statistics restoration. 
--
--     Catalog view DBA_OPTSTAT_OPERATIONS contain history of 
--     statistics operations performed at schema and database level 
--     using DBMS_STATS. 
--
--     The views *_TAB_STATS_HISTORY views (ALL, DBA, or USER) contain 
--     history of table statistics modifications. 
--
-- The old statistics are purged automatically at regular intervals based on 
-- the statistics history retention setting and the time of the recent 
-- analyze of the system. Retention is configurable using the
-- ALTER_STATS_HISTORY_RETENTION procedure. The default value is 31 days, 
-- which means that you would be able to restore the optimizer statistics to 
-- any time in last 31 days. 
-- Automatic purging is enabled when STATISTICS_LEVEL parameter is set 
-- to TYPICAL or ALL. If automatic purging is disabled, the old versions 
-- of statistics need to be purged manually using the PURGE_STATS procedure. 
--
-- Other related functions:
--   GET_STATS_HISTORY_RENTENTION: This function can be used to get the 
--     current statistics history retention value. 
--   GET_STATS_HISTORY_AVAILABILTY: This function gets the oldest time stamp 
--     where statistics history is available. Users cannot restore statistics 
--     to a time stamp older than the oldest time stamp. 
--
--
-- When a dbms_stats subprogram modifies or deletes the statistics
-- for an object, all the dependent cursors are invalidated by
-- default and corresponding statements are subject to recompilation
-- next time so that new statistics have immediate effects.  This
-- behavior can be altered with the no_invalidate argument when
-- applicable.
--
-- Nearly all the procedures in this package (more specifically, the
-- set_*, delete_*, export_*, import_*, gather_*, and *_stat_table
-- procedures) commit the current transaction, perform the operation, 
-- and then commit again.
--



-- types for minimum/maximum values and histogram endpoints
type numarray is varray(256) of number;
type datearray is varray(256) of date;
type chararray is varray(256) of varchar2(4000);
type rawarray is varray(256) of raw(2000);
type fltarray is varray(256) of binary_float;
type dblarray is varray(256) of binary_double;

type StatRec is record (
  epc    number,
  minval raw(2000),
  maxval raw(2000),
  bkvals numarray,
  novals numarray,
  chvals chararray,
  eavs   number);

-- type for listing stale tables
type ObjectElem is record (
  ownname     varchar2(32),     -- owner
  objtype     varchar2(6),      -- 'TABLE' or 'INDEX'
  objname     varchar2(32),     -- table/index
  partname    varchar2(32),     -- partition
  subpartname varchar2(32),     -- subpartition
  confidence  number);          -- not used
type ObjectTab is table of ObjectElem;


-- oracle decides whether to collect stats for indexes or not
AUTO_CASCADE CONSTANT BOOLEAN := null;

-- oracle decides when to invalidate dependend cursors
AUTO_INVALIDATE CONSTANT BOOLEAN := null;

-- constant used to indicate auto sample size algorithms should
-- be used.
AUTO_SAMPLE_SIZE        CONSTANT NUMBER := 0;


-- constant to indicate use of the system default degree of
-- parallelism determined based on the initialization parameters.
DEFAULT_DEGREE          CONSTANT NUMBER := 32767;
-- force serial execution if the object is relatively small.
-- use the system default degree of parallelism otherwise.
AUTO_DEGREE             CONSTANT NUMBER := 32768;


--
-- This set of procedures enable the storage and retrieval of 
-- individual column-, index-, table- and system-  related statistics
--
-- The procedures are:
--
--  prepare_column_values*
--
--  set_column_stats
--  set_index_stats
--  set_table_stats
--  set_system_stats
--
--  convert_raw_value*
--
--  get_column_stats
--  get_index_stats
--  get_table_stats
--  get_system_stats
--
--  delete_column_stats
--  delete_index_stats
--  delete_table_stats
--  delete_schema_stats
--  delete_database_stats
--  delete_system_stats
--  delete_fixed_objects_stats
--  delete_dictionary_stats
--


  procedure prepare_column_values(
        srec in out StatRec, charvals chararray);
  pragma restrict_references(prepare_column_values, WNDS, RNDS, WNPS, RNPS);
  procedure prepare_column_values(
        srec in out StatRec, datevals datearray);
  pragma restrict_references(prepare_column_values, WNDS, RNDS, WNPS, RNPS);
  procedure prepare_column_values(
        srec in out StatRec, numvals numarray);
  pragma restrict_references(prepare_column_values, WNDS, RNDS, WNPS, RNPS);
  procedure prepare_column_values(
        srec in out StatRec, fltvals fltarray);
  pragma restrict_references(prepare_column_values, WNDS, RNDS, WNPS, RNPS);
  procedure prepare_column_values(
        srec in out StatRec, dblvals dblarray);
  pragma restrict_references(prepare_column_values, WNDS, RNDS, WNPS, RNPS);
  procedure prepare_column_values(
        srec in out StatRec, rawvals rawarray);
  pragma restrict_references(prepare_column_values, WNDS, RNDS, WNPS, RNPS);
  procedure prepare_column_values_nvarchar(
        srec in out StatRec, nvmin nvarchar2, nvmax nvarchar2);
  pragma restrict_references(prepare_column_values, WNDS, RNDS, WNPS, RNPS);
  procedure prepare_column_values_rowid(
        srec in out StatRec, rwmin rowid, rwmax rowid);
  pragma restrict_references(prepare_column_values, WNDS, RNDS, WNPS, RNPS);
--
-- Convert user-specified minimum, maximum, and histogram endpoint
-- datatype-specific values into Oracle's internal representation 
-- for future storage via set_column_stats.
--
-- Generic input arguments:
--   srec.epc - The number of values specified in charvals, datevals,
--      numvals, or rawvals.  This value must be between 2 and 256 inclusive.
--      Should be set to 2 for procedures which don't allow histogram
--      information (nvarchar and rowid).
--      The first corresponding array entry should hold the minimum 
--      value for the column and the last entry should hold the maximum.
--      If there are more than two entries, then all the others hold the
--      remaining height-balanced or frequency histogram endpoint values
--      (with in-between values ordered from next-smallest to next-largest).  
--      This value may be adjusted to account for compression, so the
--      returned value should be left as is for a call to set_column_stats.
--   srec.bkvals - If a frequency distribution is desired, this array contains
--      the number of occurrences of each distinct value specified in
--      charvals, datevals, numvals, or rawvals.  Otherwise, it is merely an
--      ouput argument and must be set to null when this procedure is
--      called.
--
-- Datatype specific input arguments (one of these):
--   charvals - The array of values when the column type is character-based.
--      Up to the first 32 bytes of each string should be provided.
--      Arrays must have between 2 and 256 entries, inclusive.
--      If the datatype is fixed char, the strings must be space padded
--      to 15 characters for correct normalization.
--   datevals - The array of values when the column type is date-based.
--   numvals - The array of values when the column type is numeric-based.
--   rawvals - The array of values when the column type is raw.
--      Up to the first 32 bytes of each strings should be provided.
--   nvmin,nvmax - The minimum and maximum values when the column type
--      is national character set based (NLS).  No histogram information
--      can be provided for a column of this type.
--      If the datatype is fixed char, the strings must be space padded
--      to 15 characters for correct normalization.
--   rwmin,rwmax - The minimum and maximum values when the column type
--      is rowid.  No histogram information can be provided for a column 
--      of this type.
--
-- Output arguments:
--   srec.minval - Internal representation of the minimum which is
--      suitable for use in a call to set_column_stats.
--   srec.maxval - Internal representation of the maximum which is
--      suitable for use in a call to set_column_stats.
--   srec.bkvals - array suitable for use in a call to set_column_stats.
--   srec.novals - array suitable for use in a call to set_column_stats.
--
-- Exceptions:
--   ORA-20001: Invalid or inconsistent input values
--

  procedure set_param(
    pname in varchar2,
    pval  in varchar2);
--
-- This procedure can be used to set default value for parameters 
-- of dbms_stats procedures.
--
-- The function get_param can be used to get the current
-- default value of a parameter. 
--
-- To run this procedure, you must have the SYSDBA OR 
-- both ANALYZE ANY DICTIONARY and ANALYZE ANY system privilege. 
--
-- Input arguments:
--   pname   - parameter name
--             The default value for following parameters can be set.
--                CASCADE - The default value for CASCADE set by set_param
--                          is not used by export/import procedures.
--                          It is used only by gather procedures.
--                DEGREE 
--                ESTIMATE_PERCENT
--                METHOD_OPT
--                NO_INVALIDATE
--                GRANULARITY
--                AUTOSTATS_TARGET
                        -- This parameter is applicable only for auto stats
--                         collection. The value of this parameter controls
--                         the objects considered for stats collection
--                         It takes the following values
--                         'ALL'    -- statistics collected 
--                                     for all objects in system
--                         'ORACLE' -- statistics collected 
--                                     for all oracle owned objects
--                         'AUTO'   -- oracle descide which objects 
--                                     to collect stats
--   pval    - parameter value. 
--             if null is specified, it will set the oracle default value
-- Examples:
--        dbms_stats.set_param('CASCADE','DBMS_STATS.AUTO_CASCADE');
--        dbms_stats.set_param('ESTIMATE_PERCENT','5');
--        dbms_stats.set_param('DEGREE','NULL');
--     Note that both arguments are of type varchar2 and the values are
--     enclosed in quotes.
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: Invalid or Illegal input values
--

  function get_param(
    pname in varchar2) return varchar2;
-- 
-- Get default value of parameters of dbms_stats procedures 
--
-- Input arguments:
--   pname   - parameter name
--
-- Exceptions:
--   ORA-20001: Invalid input values
--

  procedure reset_param_defaults;
--
-- This procedure resets the default of parameters to ORACLE
-- recommended values.
--

-- THE FOLLOWING PROCEDURES ARE FOR INTERNAL USE ONLY.
  function to_cascade_type(cascade varchar2) return boolean;
  function to_estimate_percent_type(estimate_percent varchar2) return number;
  function to_degree_type(degree varchar2) return number;
  function to_no_invalidate_type(no_invalidate varchar2) return boolean;
  procedure init_package;
-- THE ABOVE PROCEDURES ARE FOR INTERNAL USE ONLY.


  procedure set_column_stats(
        ownname varchar2, tabname varchar2, colname varchar2, 
        partname varchar2 default null,
        stattab varchar2 default null, statid varchar2 default null,
        distcnt number default null, density number default null,
        nullcnt number default null, srec StatRec default null,
        avgclen number default null, flags number default null,
        statown varchar2 default null,
        no_invalidate boolean default 
          to_no_invalidate_type(get_param('NO_INVALIDATE')),
        force boolean default FALSE);

  procedure set_column_stats(
        ownname varchar2, tabname varchar2, colname varchar2, 
        partname varchar2 default null,
        stattab varchar2 default null, statid varchar2 default null,
        ext_stats raw,
        stattypown varchar2 default null,
        stattypname varchar2 default null,
        statown varchar2 default null,
        no_invalidate boolean default 
          to_no_invalidate_type(get_param('NO_INVALIDATE')),
        force boolean default FALSE);
--
-- Set column-related information 
--
-- Input arguments:
--   ownname - The name of the schema
--   tabname - The name of the table to which this column belongs
--   colname - The name of the column
--   partname - The name of the table partition in which to store
--      the statistics.  If the table is partitioned and partname
--      is null, the statistics will be stored at the global table
--      level.
--   stattab - The user stat table identifier describing where
--      to store the statistics.  If stattab is null, the statistics
--      will be stored directly in the dictionary.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab (Only pertinent if stattab is not NULL).
--   distcnt - The number of distinct values
--   density - The column density.  If this value is null and distcnt is
--      not null, density will be derived from distcnt.
--   nullcnt - The number of nulls
--   srec - StatRec structure filled in by a call to prepare_column_values
--      or get_column_stats.
--   avgclen - The average length for the column (in bytes)
--   flags - For internal Oracle use (should be left as null)
--   statown - The schema containing stattab (if different then ownname)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   force - set the values even if statistics of the object is locked
--
-- Input arguments for user-defined statistics:
--   ext_stats - external (user-defined) statistics
--   stattypown - owner of statistics type associated with column
--   stattypname - name of statistics type associated with column
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20001: Invalid or inconsistent input values
--   ORA-20002: Bad user statistics table, may need to upgrade it
--   ORA-20005: object statistics are locked
--


  procedure set_index_stats(
        ownname varchar2, indname varchar2,
        partname varchar2 default null,
        stattab varchar2 default null, statid varchar2 default null,
        numrows number default null, numlblks number default null,
        numdist number default null, avglblk number default null,
        avgdblk number default null, clstfct number default null,
        indlevel number default null, flags number default null,
        statown varchar2 default null,
        no_invalidate boolean default 
          to_no_invalidate_type(get_param('NO_INVALIDATE')),
        guessq number default null,
        cachedblk number default null,
        cachehit number default null,
        force boolean default FALSE);

  procedure set_index_stats(
        ownname varchar2, indname varchar2,
        partname varchar2 default null,
        stattab varchar2 default null, statid varchar2 default null,
        ext_stats raw,
        stattypown varchar2 default null,
        stattypname varchar2 default null,
        statown varchar2 default null,
        no_invalidate boolean default 
          to_no_invalidate_type(get_param('NO_INVALIDATE')),
        force boolean default FALSE);
--
-- Set index-related information
-- Input arguments:
--   ownname - The name of the schema
--   indname - The name of the index
--   partname - The name of the index partition in which to store
--      the statistics.  If the index is partitioned and partname
--      is null, the statistics will be stored at the global index
--      level.
--   stattab - The user stat table identifier describing where
--      to store the statistics.  If stattab is null, the statistics
--      will be stored directly in the dictionary.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab (Only pertinent if stattab is not NULL).
--   numrows - The number of rows in the index (partition)
--   numlblks - The number of leaf blocks in the index (partition)
--   numdist - The number of distinct keys in the index (partition)
--   avglblk - Average integral number of leaf blocks in which each
--      distinct key appears for this index (partition).  If not provided,
--      this value will be derived from numlblks and numdist.
--   avgdblk - Average integral number of data blocks in the table
--      pointed to by a distinct key for this index (partition).
--      If not provided, this value will be derived from clstfct
--      and numdist.
--   clstfct - See clustering_factor column of the all_indexes view
--      for a description.
--   indlevel - The height of the index (partition)
--   flags - For internal Oracle use (should be left as null)
--   statown - The schema containing stattab (if different then ownname)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   guessq - IOT guess quality.  See pct_direct_access column of the
--      all_indexes view for a description.
--   force - set the values even if statistics of the object is locked
--
-- Input arguments for user-defined statistics:
--   ext_stats - external (user-defined) statistics
--   stattypown - owner of statistics type associated with index
--   stattypname - name of statistics type associated with index
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20001: Invalid input value
--   ORA-20002: Bad user statistics table, may need to upgrade it
--   ORA-20005: object statistics are locked
-- 

  procedure set_table_stats(
        ownname varchar2,
        tabname varchar2, 
        partname varchar2 default null,
        stattab varchar2 default null,
        statid varchar2 default null,
        numrows number default null,
        numblks number default null,
        avgrlen number default null, 
        flags number default null,
        statown varchar2 default null,
        no_invalidate boolean default 
          to_no_invalidate_type(get_param('NO_INVALIDATE')),
        cachedblk number default null,
        cachehit number default null,
        force boolean default FALSE);
--
-- Set table-related information
--
-- Input arguments:
--   ownname - The name of the schema
--   tabname - The name of the table
--   partname - The name of the table partition in which to store
--      the statistics.  If the table is partitioned and partname
--      is null, the statistics will be stored at the global table
--      level.
--   stattab - The user stat table identifier describing where
--      to store the statistics.  If stattab is null, the statistics
--      will be stored directly in the dictionary.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab (Only pertinent if stattab is not NULL).
--   numrows - Number of rows in the table (partition)
--   numblks - Number of blocks the table (partition) occupies
--   avgrlen - Average row length for the table (partition)
--   flags - For internal Oracle use (should be left as null)
--   statown - The schema containing stattab (if different then ownname)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   force - set the values even if statistics of the object is locked
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20001: Invalid input value
--   ORA-20002: Bad user statistics table, may need to upgrade it
--   ORA-20005: object statistics are locked
--


  procedure convert_raw_value(
        rawval raw, resval out varchar2);
  pragma restrict_references(convert_raw_value, WNDS, RNDS, WNPS, RNPS);
  procedure convert_raw_value(
        rawval raw, resval out date);
  pragma restrict_references(convert_raw_value, WNDS, RNDS, WNPS, RNPS);
  procedure convert_raw_value(
        rawval raw, resval out number);
  pragma restrict_references(convert_raw_value, WNDS, RNDS, WNPS, RNPS);
  procedure convert_raw_value(
        rawval raw, resval out binary_float);
  pragma restrict_references(convert_raw_value, WNDS, RNDS, WNPS, RNPS);
  procedure convert_raw_value(
        rawval raw, resval out binary_double);
  pragma restrict_references(convert_raw_value, WNDS, RNDS, WNPS, RNPS);
  procedure convert_raw_value_nvarchar(
        rawval raw, resval out nvarchar2);
  pragma restrict_references(convert_raw_value_nvarchar,
                             WNDS, RNDS, WNPS, RNPS);
  procedure convert_raw_value_rowid(
        rawval raw, resval out rowid);
  pragma restrict_references(convert_raw_value_rowid, WNDS, RNDS, WNPS, RNPS);
--
-- Convert the internal representation of a minimum or maximum value
-- into a datatype-specific value.  The minval and maxval fields
-- of the StatRec structure as filled in by get_column_stats or
-- prepare_column_values are appropriate values for input.
--
-- Input argument
--   rawval - The raw representation of a column minimum or maximum
--
-- Datatype specific output arguments:
--   resval - The converted, type-specific value
--
-- Exceptions:
--   None
--


  procedure get_column_stats(
        ownname varchar2, tabname varchar2, colname varchar2, 
        partname varchar2 default null,
        stattab varchar2 default null, statid varchar2 default null,
        distcnt out number, density out number,
        nullcnt out number, srec out StatRec,
        avgclen out number,
        statown varchar2 default null);

  procedure get_column_stats(
        ownname varchar2, tabname varchar2, colname varchar2, 
        partname varchar2 default null,
        stattab varchar2 default null, statid varchar2 default null,
        ext_stats out raw, 
        stattypown out varchar2, stattypname out varchar2,
        statown varchar2 default null);
--
-- Gets all column-related information
--
-- Input arguments:
--   ownname - The name of the schema
--   tabname - The name of the table to which this column belongs
--   colname - The name of the column
--   partname - The name of the table partition from which to get
--      the statistics.  If the table is partitioned and partname
--      is null, the statistics will be retrieved from the global table
--      level.
--   stattab - The user stat table identifier describing from where
--      to retrieve the statistics.  If stattab is null, the statistics
--      will be retrieved directly from the dictionary.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab (Only pertinent if stattab is not NULL).
--   statown - The schema containing stattab (if different then ownname)
--
-- Output arguments:
--   distcnt - The number of distinct values
--   density - The column density
--   nullcnt - The number of nulls
--   srec - structure holding internal representation of column minimum,
--      maximum, and histogram values
--   avgclen - The average length of the column (in bytes)
--
-- Output arguments for user-defined column statistics:
--   ext_stats - external (user-defined) statistics
--   stattypown - owner of statistics type associated with column
--   stattypname - name of statistics type associated with column
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges or
--              no statistics have been stored for requested object
--   ORA-20002: Bad user statistics table, may need to upgrade it
--


  procedure get_index_stats(
        ownname varchar2, indname varchar2,
        partname varchar2 default null,
        stattab varchar2 default null, statid varchar2 default null,
        numrows out number, numlblks out number,
        numdist out number, avglblk out number,
        avgdblk out number, clstfct out number,
        indlevel out number,
        statown varchar2 default null,
        guessq out number,
        cachedblk out number,
        cachehit out number);

  procedure get_index_stats(
        ownname varchar2, indname varchar2,
        partname varchar2 default null,
        stattab varchar2 default null, statid varchar2 default null,
        numrows out number, numlblks out number,
        numdist out number, avglblk out number,
        avgdblk out number, clstfct out number,
        indlevel out number,
        statown varchar2 default null,
        guessq out number);
  
  procedure get_index_stats(
        ownname varchar2, indname varchar2,
        partname varchar2 default null,
        stattab varchar2 default null, statid varchar2 default null,
        numrows out number, numlblks out number,
        numdist out number, avglblk out number,
        avgdblk out number, clstfct out number,
        indlevel out number,
        statown varchar2 default null);

  procedure get_index_stats(
        ownname varchar2, indname varchar2,
        partname varchar2 default null,
        stattab varchar2 default null, statid varchar2 default null,
        ext_stats out raw,
        stattypown out varchar2, stattypname out varchar2,
        statown varchar2 default null);
--
-- Gets all index-related information
--
-- Input arguments:
--   ownname - The name of the schema
--   indname - The name of the index
--   partname - The name of the index partition for which to get
--      the statistics.  If the index is partitioned and partname
--      is null, the statistics will be retrieved for the global index
--      level.
--   stattab - The user stat table identifier describing from where
--      to retrieve the statistics.  If stattab is null, the statistics
--      will be retrieved directly from the dictionary.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab (Only pertinent if stattab is not NULL).
--   statown - The schema containing stattab (if different then ownname)
--
-- Output arguments:
--   numrows - The number of rows in the index (partition)
--   numlblks - The number of leaf blocks in the index (partition)
--   numdist - The number of distinct keys in the index (partition)
--   avglblk - Average integral number of leaf blocks in which each
--      distinct key appears for this index (partition).
--   avgdblk - Average integral number of data blocks in the table
--      pointed to by a distinct key for this index (partition).
--   clstfct - The clustering factor for the index (partition).
--   indlevel - The height of the index (partition).
--   guessq - IOT guess quality of the index (partition).
--
-- Output arguments for user defined statistics:
--   ext_stats - external (user-defined) statistics
--   stattypown - owner of statistics type associated with index
--   stattypname - name of statistics type associated with index
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges or
--              no statistics have been stored for requested object
--   ORA-20002: Bad user statistics table, may need to upgrade it
--


  procedure get_table_stats(
        ownname varchar2, tabname varchar2, 
        partname varchar2 default null,
        stattab varchar2 default null, statid varchar2 default null,
        numrows out number, numblks out number,
        avgrlen out number,
        statown varchar2 default null);

  procedure get_table_stats(
        ownname varchar2,
        tabname varchar2, 
        partname varchar2 default null,
        stattab varchar2 default null,
        statid varchar2 default null,
        numrows out number,
        numblks out number,
        avgrlen out number,
        statown varchar2 default null,
        cachedblk out number,
        cachehit out number);
--
-- Gets all table-related information
--
-- Input arguments:
--   ownname - The name of the schema
--   tabname - The name of the table to which this column belongs
--   partname - The name of the table partition from which to get
--      the statistics.  If the table is partitioned and partname
--      is null, the statistics will be retrieved from the global table
--      level.
--   stattab - The user stat table identifier describing from where
--      to retrieve the statistics.  If stattab is null, the statistics
--      will be retrieved directly from the dictionary.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab (Only pertinent if stattab is not NULL).
--   statown - The schema containing stattab (if different then ownname)
--
-- Output arguments:
--   numrows - Number of rows in the table (partition)
--   numblks - Number of blocks the table (partition) occupies
--   avgrlen - Average row length for the table (partition)
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges or
--              no statistics have been stored for requested object
--   ORA-20002: Bad user statistics table, may need to upgrade it
--



  procedure delete_column_stats(
        ownname varchar2, tabname varchar2, colname varchar2, 
        partname varchar2 default null,
        stattab varchar2 default null, statid varchar2 default null,
        cascade_parts boolean default true,
        statown varchar2 default null,
        no_invalidate boolean default 
          to_no_invalidate_type(get_param('NO_INVALIDATE')),
        force boolean default FALSE);
--
-- Deletes column-related statistics
--
-- Input arguments:
--   ownname - The name of the schema
--   tabname - The name of the table to which this column belongs
--   colname - The name of the column
--   partname - The name of the table partition for which to delete
--      the statistics.  If the table is partitioned and partname
--      is null, global column statistics will be deleted.
--   stattab - The user stat table identifier describing from where
--      to delete the statistics.  If stattab is null, the statistics
--      will be deleted directly from the dictionary.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab (Only pertinent if stattab is not NULL).
--   cascade_parts - If the table is partitioned and partname is null,
--      setting this to true will cause the deletion of statistics for
--      this column for all underlying partitions as well.
--   statown - The schema containing stattab (if different then ownname)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   force - delete statistics even if it is locked
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20002: Bad user statistics table, may need to upgrade it
--   ORA-20005: object statistics are locked
--


  procedure delete_index_stats(
        ownname varchar2, indname varchar2,
        partname varchar2 default null,
        stattab varchar2 default null, statid varchar2 default null,
        cascade_parts boolean default true,
        statown varchar2 default null,
        no_invalidate boolean default 
          to_no_invalidate_type(get_param('NO_INVALIDATE')),
        stattype varchar2 default 'ALL',
        force boolean default FALSE);
--
-- Deletes index-related statistics
--
-- Input arguments:
--   ownname - The name of the schema
--   indname - The name of the index
--   partname - The name of the index partition for which to delete
--      the statistics.  If the index is partitioned and partname
--      is null, index statistics will be deleted at the global level.
--   stattab - The user stat table identifier describing from where
--      to delete the statistics.  If stattab is null, the statistics
--      will be deleted directly from the dictionary.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab (Only pertinent if stattab is not NULL).
--   cascade_parts - If the index is partitioned and partname is null,
--      setting this to true will cause the deletion of statistics for
--      this index for all underlying partitions as well.
--   statown - The schema containing stattab (if different then ownname)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   force - delete the statistics even if it is locked
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20002: Bad user statistics table, may need to upgrade it
--   ORA-20005: object statistics are locked
--


  procedure delete_table_stats(
        ownname varchar2, tabname varchar2, 
        partname varchar2 default null,
        stattab varchar2 default null, statid varchar2 default null,
        cascade_parts boolean default true, 
        cascade_columns boolean default true,
        cascade_indexes boolean default true,
        statown varchar2 default null,
        no_invalidate boolean default 
          to_no_invalidate_type(get_param('NO_INVALIDATE')),
        stattype varchar2 default 'ALL',
        force boolean default FALSE);
--
-- Deletes table-related statistics
--
-- Input arguments:
--   ownname - The name of the schema
--   tabname - The name of the table to which this column belongs
--   colname - The name of the column
--   partname - The name of the table partition from which to get
--      the statistics.  If the table is partitioned and partname
--      is null, the statistics will be retrieved from the global table
--      level.
--   stattab - The user stat table identifier describing from where
--      to retrieve the statistics.  If stattab is null, the statistics
--      will be retrieved directly from the dictionary.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab (Only pertinent if stattab is not NULL).
--   cascade_parts - If the table is partitioned and partname is null,
--      setting this to true will cause the deletion of statistics for
--      this table for all underlying partitions as well.
--   cascade_columns - Indicates that delete_column_stats should be
--      called for all underlying columns (passing the cascade_parts
--      parameter).
--   cascade_indexes - Indicates that delete_index_stats should be
--      called for all underlying indexes (passing the cascade_parts
--      parameter).
--   statown - The schema containing stattab (if different then ownname)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   force - delete the statistics even if it is locked
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20002: Bad user statistics table, may need to upgrade it
--   ORA-20005: object statistics are locked
--


  procedure delete_schema_stats(
        ownname varchar2, 
        stattab varchar2 default null, statid varchar2 default null,
        statown varchar2 default null,
        no_invalidate boolean default 
          to_no_invalidate_type(get_param('NO_INVALIDATE')),
        stattype varchar2 default 'ALL',
        force boolean default FALSE);
--
-- Deletes statistics for a schema
--
-- Input arguments:
--   ownname - The name of the schema
--   stattab - The user stat table identifier describing from where
--      to delete the statistics.  If stattab is null, the statistics
--      will be deleted directly in the dictionary.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab (Only pertinent if stattab is not NULL).
--   statown - The schema containing stattab (if different then ownname)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   stattype - The type of statistics to be deleted
--     ALL   - both data and cache statistics will be deleted
--     CACHE - only cache statistics will be deleted 
--   force - Ignores the statistics lock on objects and delete
--           the statistics if set to TRUE.
--           
--           
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20002: Bad user statistics table, may need to upgrade it
--


  procedure delete_database_stats(
        stattab varchar2 default null, statid varchar2 default null,
        statown varchar2 default null,
        no_invalidate boolean default 
          to_no_invalidate_type(get_param('NO_INVALIDATE')),
        stattype varchar2 default 'ALL',
        force boolean default FALSE);
--
-- Deletes statistics for an entire database
--
-- Input arguments:
--   stattab - The user stat table identifier describing from where
--      to delete the statistics.  If stattab is null, the statistics
--      will be deleted directly in the dictionary.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab (Only pertinent if stattab is not NULL).
--   statown - The schema containing stattab.
--      If stattab is not null and statown is null, it is assumed that
--      every schema in the database contains a user statistics table
--      with the name stattab.
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   stattype - The type of statistics to be deleted
--     ALL   - both data and cache statistics will be deleted
--     CACHE - only cache statistics will be deleted 
--   force - Ignores the statistics lock on objects and delete
--           the statistics if set to TRUE.
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20002: Bad user statistics table, may need to upgrade it
--






--
-- This set of procedures enable the transferrance of statistics
-- from the dictionary to a user stat table (export_*) and from a user
-- stat table to the dictionary (import_*).
--
-- The procedures are:
--
--  create_stat_table
--  drop_stat_table
--  upgrade_stat_table
--
--  export_column_stats
--  export_index_stats
--  export_table_stats
--  export_schema_stats
--  export_database_stats
--  export_system_stats
--  export_fixed_objects_stats
--  export_dictionary_stats
--
--  import_column_stats
--  import_index_stats
--  import_table_stats
--  import_schema_stats
--  import_database_stats
--  import_system_stats
--  import_fixed_objects_stats
--  import_dictionary_stats
--


  procedure create_stat_table(
        ownname varchar2, stattab varchar2,
        tblspace varchar2 default null,
        global_temporary boolean default false);
--
-- Creates a table with name 'stattab' in 'ownname's
-- schema which is capable of holding statistics.  The columns
-- and types that compose this table are not relevant as it
-- should be accessed solely through the procedures in this
-- package.
--
-- Input arguments:
--   ownname - The name of the schema
--   stattab - The name of the table to create.  This value should
--      be passed as the 'stattab' argument to other procedures
--      when the user does not wish to modify the dictionary statistics
--      directly.
--   tblspace - The tablespace in which to create the stat tables.
--      If none is specified, they will be created in the user's 
--      default tablespace.
--   table_options - Whether or not the table should be created as a global
--      temporary table.
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: Tablespace does not exist
--   ORA-20002: Table already exists
--


  procedure drop_stat_table(
        ownname varchar2, stattab varchar2);
--
-- Drops a user stat table
--
-- Input arguments:
--   ownname - The name of the schema
--   stattab - The user stat table identifier
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: Table is not a statistics table
--   ORA-20002: Table does not exist
--


  procedure upgrade_stat_table(
        ownname varchar2, stattab varchar2);
--
-- Upgrade a user stat table from an older version
--
-- Input arguments:
--   ownname - The name of the schema
--   stattab - The user stat table identifier
--
-- Exceptions:
--   ORA-20000: Unable to upgrade table
--


  procedure export_column_stats(
        ownname varchar2, tabname varchar2, colname varchar2, 
        partname varchar2 default null,
        stattab varchar2, statid varchar2 default null,
        statown varchar2 default null);
--
-- Retrieves statistics for a particular column and stores them in the user
-- stat table identified by stattab
--
-- Input arguments:
--   ownname - The name of the schema
--   tabname - The name of the table to which this column belongs
--   colname - The name of the column
--   partname - The name of the table partition.  If the table is 
--      partitioned and partname is null, global and partition column 
--      statistics will be exported.
--   stattab - The user stat table identifier describing where
--      to store the statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different then ownname)
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20002: Bad user statistics table, may need to upgrade it
--


  procedure export_index_stats(
        ownname varchar2, indname varchar2, 
        partname varchar2 default null,
        stattab varchar2, statid varchar2 default null,
        statown varchar2 default null);
--
-- Retrieves statistics for a particular index and stores them 
-- in the user stat table identified by stattab
--
-- Input arguments:
--   ownname - The name of the schema
--   indname - The name of the index
--   partname - The name of the index partition.  If the index is 
--      partitioned and partname is null, global and partition index 
--      statistics will be exported.
--   stattab - The user stat table identifier describing where
--      to store the statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different then ownname)
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20002: Bad user statistics table, may need to upgrade it
--


  procedure export_table_stats(
        ownname varchar2, tabname varchar2, 
        partname varchar2 default null,
        stattab varchar2, statid varchar2 default null,
        cascade boolean default true,
        statown varchar2 default null);
--
-- Retrieves statistics for a particular table and stores them 
-- in the user stat table.
-- Cascade will result in all index and column stats associated
-- with the specified table being exported as well.
--
-- Input arguments:
--   ownname - The name of the schema
--   tabname - The name of the table
--   partname - The name of the table partition.  If the table is 
--      partitioned and partname is null, global and partition table 
--      statistics will be exported.
--   stattab - The user stat table identifier describing where
--      to store the statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   cascade - If true, column and index statistics for this table
--      will also be exported.
--   statown - The schema containing stattab (if different then ownname)
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20002: Bad user statistics table, may need to upgrade it
--


  procedure export_schema_stats(
        ownname varchar2,
        stattab varchar2, statid varchar2 default null,
        statown varchar2 default null);
--
-- Retrieves statistics for all objects in the schema identified
-- by ownname and stores them in the user stat table identified
-- by stattab
--
-- Input arguments:
--   ownname - The name of the schema
--   stattab - The user stat table identifier describing where
--      to store the statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different then ownname)
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20002: Bad user statistics table, may need to upgrade it
--


  procedure export_database_stats(
        stattab varchar2, statid varchar2 default null,
        statown varchar2 default null);
--
-- Retrieves statistics for all objects in the database
-- and stores them in the user stat tables identified
-- by statown.stattab
--
-- Input arguments:
--   stattab - The user stat table identifier describing where
--      to store the statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab.
--      If statown is null, it is assumed that every schema in the database 
--      contains a user statistics table with the name stattab.
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20002: Bad user statistics table, may need to upgrade it
--


  procedure import_column_stats(
        ownname varchar2, tabname varchar2, colname varchar2,
        partname varchar2 default null,
        stattab varchar2, statid varchar2 default null,
        statown varchar2 default null,
        no_invalidate boolean default 
          to_no_invalidate_type(get_param('NO_INVALIDATE')),
        force boolean default FALSE);
--
-- Retrieves statistics for a particular column from the user stat table
-- identified by stattab and stores them in the dictionary
--
-- Input arguments:
--   ownname - The name of the schema
--   tabname - The name of the table to which this column belongs
--   colname - The name of the column
--   partname - The name of the table partition.  If the table is 
--      partitioned and partname is null, global and partition column 
--      statistics will be imported.
--   stattab - The user stat table identifier describing from where
--      to retrieve the statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different then ownname)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   force - import statistics even if it is locked
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20001: Invalid or inconsistent values in the user stat table
--   ORA-20002: Bad user statistics table, may need to upgrade it
--   ORA-20005: object statistics are locked
--


  procedure import_index_stats(
        ownname varchar2, indname varchar2,
        partname varchar2 default null,
        stattab varchar2, statid varchar2 default null,
        statown varchar2 default null,
        no_invalidate boolean default 
          to_no_invalidate_type(get_param('NO_INVALIDATE')),
        force boolean default FALSE);
--
-- Retrieves statistics for a particular index from the user
-- stat table identified by stattab and stores them in the 
-- dictionary
--
-- Input arguments:
--   ownname - The name of the schema
--   indname - The name of the index
--   partname - The name of the index partition.  If the index is 
--      partitioned and partname is null, global and partition index 
--      statistics will be imported.
--   stattab - The user stat table identifier describing from where
--      to retrieve the statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different then ownname)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   force - import the statistics even if it is locked
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20001: Invalid or inconsistent values in the user stat table
--   ORA-20002: Bad user statistics table, may need to upgrade it
--   ORA-20005: object statistics are locked
--


  procedure import_table_stats(
        ownname varchar2, tabname varchar2,
        partname varchar2 default null,
        stattab varchar2, statid varchar2 default null,
        cascade boolean default true,
        statown varchar2 default null,
        no_invalidate boolean default 
          to_no_invalidate_type(get_param('NO_INVALIDATE')),
        force boolean default FALSE);
--
-- Retrieves statistics for a particular table from the user
-- stat table identified by stattab and stores them in the dictionary.
-- Cascade will result in all index and column stats associated
-- with the specified table being imported as well.
--
-- Input arguments:
--   ownname - The name of the schema
--   tabname - The name of the table
--   partname - The name of the table partition.  If the table is 
--      partitioned and partname is null, global and partition table 
--      statistics will be imported.
--   stattab - The user stat table identifier describing from where
--      to retrieve the statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   cascade - If true, column and index statistics for this table
--      will also be imported.
--   statown - The schema containing stattab (if different then ownname)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   force - import even if statistics of the object is locked
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20001: Invalid or inconsistent values in the user stat table
--   ORA-20002: Bad user statistics table, may need to upgrade it
--   ORA-20005: object statistics are locked
--


  procedure import_schema_stats(
        ownname varchar2,
        stattab varchar2, statid varchar2 default null,
        statown varchar2 default null,
        no_invalidate boolean default 
          to_no_invalidate_type(get_param('NO_INVALIDATE')),
        force boolean default FALSE);
--
-- Retrieves statistics for all objects in the schema identified
-- by ownname from the user stat table and stores them in the
-- dictionary 
--
-- Input arguments:
--   ownname - The name of the schema
--   stattab - The user stat table identifier describing from where
--      to retrieve the statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different then ownname)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   force - Override statistics lock.
--     TRUE- Ignores the statistics lock on objects and import
--           the statistics. 
--     FALSE-The statistics of an object will be imported only if it 
--           is not locked. 
--           ie if both DATA and CACHE statistics is locked, it will not
--           import anything. If CACHE statistics of an object is locked, 
--           only DATA statistics will be imported and vice versa.
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20001: Invalid or inconsistent values in the user stat table
--   ORA-20002: Bad user statistics table, may need to upgrade it
--


  procedure import_database_stats(
        stattab varchar2, statid varchar2 default null,
        statown varchar2 default null,
        no_invalidate boolean default 
          to_no_invalidate_type(get_param('NO_INVALIDATE')),
        force boolean default FALSE);
--
-- Retrieves statistics for all objects in the database
-- from the user stat table(s) and stores them in the
-- dictionary 
--
-- Input arguments:
--   stattab - The user stat table identifier describing from where
--      to retrieve the statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab.
--      If statown is null, it is assumed that every schema in the database 
--      contains a user statistics table with the name stattab.
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   force - Override statistics lock.
--     TRUE- Ignores the statistics lock on objects and import
--           the statistics. 
--     FALSE-The statistics of an object will be imported only if it 
--           is not locked. 
--           ie if both DATA and CACHE statistics is locked, it will not
--           import anything. If CACHE statistics of an object is locked, 
--           only DATA statistics will be imported and vice versa.
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20001: Invalid or inconsistent values in the user stat table
--   ORA-20002: Bad user statistics table, may need to upgrade it
--








--
-- This set of procedures enable the gathering of certain
-- classes of optimizer statistics with possible performance 
-- improvements over the analyze command.
--
-- The procedures are:
--
--  gather_index_stats
--  gather_table_stats
--  gather_schema_stats
--  gather_database_stats
--  gather_system_stats
--  gather_fixed_objects_stats
--  gather_dictionary_stats
--
-- We also provide the following procedure for generating some
-- statistics for derived objects when we have sufficient statistics 
-- on related objects
--
-- generate_stats
--

  procedure gather_index_stats
    (ownname varchar2, indname varchar2, partname varchar2 default null,
     estimate_percent number default 
       to_estimate_percent_type(get_param('ESTIMATE_PERCENT')),
     stattab varchar2 default null, statid varchar2 default null,
     statown varchar2 default null,
     degree number default to_degree_type(get_param('DEGREE')),
     granularity varchar2 default get_param('GRANULARITY'),
     no_invalidate boolean default 
       to_no_invalidate_type(get_param('NO_INVALIDATE')),
     stattype varchar2 default 'DATA',
     force boolean default FALSE);
--
-- This procedure gathers index statistics.
-- It attempts to parallelize as much of the work as possible.
-- are some restrictions as described in the individual parameters.
-- This operation will not parallelize with certain types of indexes,
-- including cluster indexes, domain indexes and bitmap join indexes.
-- The "granularity" and "no_invalidate" arguments are also not pertinent to
-- these types of indexes.
--
--   ownname - schema of index to analyze
--   indname - name of index
--   partname - name of partition
--   estimate_percent - Percentage of rows to estimate (NULL means compute).
--      The valid range is [0.000001,100].  Use the constant
--      DBMS_STATS.AUTO_SAMPLE_SIZE to have Oracle determine the
--      appropriate sample size for good statistics. This is the default.
--      The default value can be changed using set_param procedure.
--   degree - degree of parallelism (NULL means use of table default value
--      which was specified by DEGREE clause in CREATE/ALTER INDEX statement)
--      Use the constant DBMS_STATS.DEFAULT_DEGREE for the default value
--      based on the initialization parameters.
--      default for degree is NULL.
--      The default value can be changed using set_param procedure.
--   granularity - the granularity of statistics to collect (only pertinent
--      if the table is partitioned)
--     'AUTO' - the procedure determines what level of statistics to collect
--     'GLOBAL AND PARTITION' - gather global- and partition-level statistics
--     'SUBPARTITION' - gather subpartition-level statistics
--     'PARTITION' - gather partition-level statistics
--     'GLOBAL' - gather global statistics
--     'ALL' - gather all (subpartition, partition, and global) statistics
--     default for granularity is AUTO. 
--     The default value can be changed using set_param procedure.
--   stattab - The user stat table identifier describing where to save
--      the current statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different then ownname)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   force - gather statistics of index even if it is locked.
--
-- Exceptions:
--   ORA-20000: Index does not exist or insufficient privileges
--   ORA-20001: Bad input value
--   ORA-20002: Bad user statistics table, may need to upgrade it
--   ORA-20005: object statistics are locked
--

  procedure gather_table_stats
    (ownname varchar2, tabname varchar2, partname varchar2 default null,
     estimate_percent number default 
       to_estimate_percent_type(get_param('ESTIMATE_PERCENT')),
     block_sample boolean default FALSE,
     method_opt varchar2 default get_param('METHOD_OPT'),
     degree number default to_degree_type(get_param('DEGREE')),
     granularity varchar2 default get_param('GRANULARITY'),
     cascade boolean default to_cascade_type(get_param('CASCADE')),
     stattab varchar2 default null, statid varchar2 default null,
     statown varchar2 default null,
     no_invalidate boolean default 
       to_no_invalidate_type(get_param('NO_INVALIDATE')),
     stattype varchar2 default 'DATA',
     force boolean default FALSE);

--
-- This procedure gathers table and column (and index) statistics.
-- It attempts to parallelize as much of the work as possible, but there
-- are some restrictions as described in the individual parameters.
-- This operation will not parallelize if the user does not have select
-- privilege on the table being analyzed.
--
-- Input arguments:
--   ownname - schema of table to analyze
--   tabname - name of table
--   partname - name of partition
--   estimate_percent - Percentage of rows to estimate (NULL means compute).
--      The valid range is [0.000001,100].  Use the constant
--      DBMS_STATS.AUTO_SAMPLE_SIZE to have Oracle determine the
--      appropriate sample size for good statistics. This is the default.
--      The default value can be changed using set_param procedure.
--   block_sample - whether or not to use random block sampling instead of
--      random row sampling.  Random block sampling is more efficient, but
--      if the data is not randomly distributed on disk then the sample values
--      may be somewhat correlated.  Only pertinent when doing an estimate 
--      statistics.
--   method_opt - method options of the following format 
--           size_clause := SIZE [integer | auto | skewonly | repeat],
--              where integer is between 1 and 254
--         FOR ALL [INDEXED | HIDDEN] COLUMNS [size_clause]
--         FOR COLUMNS [size_clause] 
--              column|attribute [size_clause] 
--              [,column|attribute [size_clause] ... ]
--      default is FOR ALL COLUMNS SIZE AUTO.
--      The default value can be changed using set_param procedure.
--      Optimizer related table statistics are always gathered.
--   degree - degree of parallelism (NULL means use of table default value
--      which was specified by DEGREE clause in CREATE/ALTER TABLE statement)
--      Use the constant DBMS_STATS.DEFAULT_DEGREE for the default value
--      based on the initialization parameters.
--      default for degree is NULL.
--      The default value can be changed using set_param procedure.
--   granularity - the granularity of statistics to collect (only pertinent
--      if the table is partitioned)
--     'AUTO' - the procedure determines what level of statistics to collect
--     'GLOBAL AND PARTITION' - gather global- and partition-level statistics
--     'SUBPARTITION' - gather subpartition-level statistics
--     'PARTITION' - gather partition-level statistics
--     'GLOBAL' - gather global statistics
--     'ALL' - gather all (subpartition, partition, and global) statistics
--     default for granularity is AUTO. 
--     The default value can be changed using set_param procedure.
--   cascade - gather statistics on the indexes for this table.
--      Use the constant DBMS_STATS.AUTO_CASCADE to have Oracle determine 
--      whether index stats to be collected or not. This is the default.
--      The default value can be changed using set_param procedure.
--      Index statistics gathering will not be parallelized.  Using this
--      option is equivalent to running the gather_index_stats procedure
--      on each of the table's indexes.
--   stattab - The user stat table identifier describing where to save
--      the current statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different then ownname)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--     The procedure invalidates the dependent cursors immediately
--     if set to FALSE.
--     Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--     invalidate dependend cursors. This is the default. The default 
--     can be changed using set_param procedure.
--     When the 'cascade' argument is specified, not pertinent with certain
--     types of indexes described in the gather_index_stats section.
--   force - gather statistics of table even if it is locked.
--   
-- Exceptions:
--   ORA-20000: Table does not exist or insufficient privileges
--   ORA-20001: Bad input value
--   ORA-20002: Bad user statistics table, may need to upgrade it
--   ORA-20005: object statistics are locked
--

  procedure gather_schema_stats
    (ownname varchar2,
     estimate_percent number default 
       to_estimate_percent_type(get_param('ESTIMATE_PERCENT')),
     block_sample boolean default FALSE,
     method_opt varchar2 default get_param('METHOD_OPT'),
     degree number default to_degree_type(get_param('DEGREE')),
     granularity varchar2 default get_param('GRANULARITY'),
     cascade boolean default to_cascade_type(get_param('CASCADE')),
     stattab varchar2 default null, statid varchar2 default null,
     options varchar2 default 'GATHER', objlist out ObjectTab,
     statown varchar2 default null,
     no_invalidate boolean default 
       to_no_invalidate_type(get_param('NO_INVALIDATE')),
     gather_temp boolean default FALSE,
     gather_fixed boolean default FALSE,
     stattype varchar2 default 'DATA',
     force boolean default FALSE);
  procedure gather_schema_stats
    (ownname varchar2,
     estimate_percent number default 
       to_estimate_percent_type(get_param('ESTIMATE_PERCENT')),
     block_sample boolean default FALSE,
     method_opt varchar2 default get_param('METHOD_OPT'),
     degree number default to_degree_type(get_param('DEGREE')),
     granularity varchar2 default get_param('GRANULARITY'),
     cascade boolean default to_cascade_type(get_param('CASCADE')),
     stattab varchar2 default null, statid varchar2 default null,
     options varchar2 default 'GATHER', statown varchar2 default null,
     no_invalidate boolean default 
       to_no_invalidate_type(get_param('NO_INVALIDATE')),
     gather_temp boolean default FALSE,
     gather_fixed boolean default FALSE,
     stattype varchar2 default 'DATA',
     force boolean default FALSE);
--
-- Input arguments:
--   ownname - schema to analyze (NULL means current schema)
--   estimate_percent - Percentage of rows to estimate (NULL means compute).
--      The valid range is [0.000001,100].  Use the constant
--      DBMS_STATS.AUTO_SAMPLE_SIZE to have Oracle determine the
--      appropriate sample size for good statistics. This is the default.
--      The default value can be changed using set_param procedure.
--   block_sample - whether or not to use random block sampling instead of
--      random row sampling.  Random block sampling is more efficient, but
--      if the data is not randomly distributed on disk then the sample values
--      may be somewhat correlated.  Only pertinent when doing an estimate 
--      statistics.
--   method_opt - method options of the following format 
--           size_clause := SIZE [integer | auto | skewonly | repeat],
--              where integer is between 1 and 254
--         FOR ALL [INDEXED | HIDDEN] COLUMNS [size_clause]
--      default is FOR ALL COLUMNS SIZE AUTO.
--      The default value can be changed using set_param procedure.
--      This value will be passed to all of the individual tables.
--   degree - degree of parallelism (NULL means use table default value which
--      is specified by DEGREE clause in CREATE/ALTER TABLE statement)
--      Use the constant DBMS_STATS.DEFAULT_DEGREE for the default value
--      based on the initialization parameters.
--      default for degree is NULL.
--      The default value can be changed using set_param procedure.
--   granularity - the granularity of statistics to collect (only pertinent
--      if the table is partitioned)
--     'AUTO' - the procedure determines what level of statistics to collect
--     'GLOBAL AND PARTITION' - gather global- and partition-level statistics
--     'SUBPARTITION' - gather subpartition-level statistics
--     'PARTITION' - gather partition-level statistics
--     'GLOBAL' - gather global statistics
--     'ALL' - gather all (subpartition, partition, and global) statistics
--     default for granularity is AUTO. 
--     The default value can be changed using set_param procedure.
--   cascade - gather statistics on the indexes as well.
--      Use the constant DBMS_STATS.AUTO_CASCADE to have Oracle determine 
--      whether index stats to be collected or not. This is the default.
--      The default value can be changed using set_param procedure.
--      Index statistics gathering will not be parallelized.  Using this
--      option is equivalent to running the gather_index_stats procedure
--      on each of the indexes in the schema in addition to gathering
--      table and column statistics.
--   stattab - The user stat table identifier describing where to save
--      the current statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   options - further specification of which objects to gather statistics for
--      'GATHER' - gather statistics on all objects in the schema
--      'GATHER AUTO' - gather all necessary statistics automatically.  Oracle
--        implicitly determines which objects need new statistics, and
--        determines how to gather those statistics.  When 'GATHER AUTO' is
--        specified, the only additional valid parameters are ownname, stattab,
--        statid, objlist and statown; all other parameter settings will be
--        ignored.  Also, return a list of objects processed.
--      'GATHER STALE' - gather statistics on stale objects as determined
--        by looking at the *_tab_modifications views.  Also, return
--        a list of objects found to be stale.
--      'GATHER EMPTY' - gather statistics on objects which currently
--        have no statistics.  also, return a list of objects found
--        to have no statistics.
--      'LIST AUTO' - return list of objects to be processed with 'GATHER AUTO'
--      'LIST STALE' - return list of stale objects as determined
--        by looking at the *_tab_modifications views
--      'LIST EMPTY' - return list of objects which currently
--        have no statistics
--   objlist - list of objects found to be stale or empty
--   statown - The schema containing stattab (if different then ownname)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--     The procedure invalidates the dependent cursors immediately
--     if set to FALSE.
--     Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--     invalidate dependend cursors. This is the default. The default 
--     can be changed using set_param procedure.
--     When 'cascade' option is specified, not pertinent with certain types
--     of indexes described in the gather_index_stats section.
--   gather_temp - gather stats on global temporary tables also.  The
--     temporary table must be created with "on commit preserve rows" clause,
--     and the statistics being collected are based on the data in the session
--     which this procedure is run but shared across all the sessions.
--   gather_fixed - Gather statistics on fixed tables also. 
--     Statistics for fixed tables can be collected only by user SYS.
--     Also the ownname should be SYS or NULL.
--     Specified values for the following arguments will be ignored while 
--     gathering statistics for fixed tables.
--       estimate_percent, block_sample, stattab, statid, statown  
--     It will not invalidate the dependent cursors on fixed table
--     on which stats is collected.
--     This option is meant for internal use only.
--   force - gather statistics of objects even if they are locked.
-- Exceptions:
--   ORA-20000: Schema does not exist or insufficient privileges
--   ORA-20001: Bad input value
--   ORA-20002: Bad user statistics table, may need to upgrade it
--

  procedure gather_database_stats
    (estimate_percent number default 
       to_estimate_percent_type(get_param('ESTIMATE_PERCENT')),
     block_sample boolean default FALSE,
     method_opt varchar2 default get_param('METHOD_OPT'),
     degree number default to_degree_type(get_param('DEGREE')),
     granularity varchar2 default get_param('GRANULARITY'),
     cascade boolean default to_cascade_type(get_param('CASCADE')),
     stattab varchar2 default null, statid varchar2 default null,
     options varchar2 default 'GATHER', objlist out ObjectTab,
     statown varchar2 default null,
     gather_sys boolean default TRUE,
     no_invalidate boolean default 
       to_no_invalidate_type(get_param('NO_INVALIDATE')),
     gather_temp boolean default FALSE,
     gather_fixed boolean default FALSE,
     stattype varchar2 default 'DATA');
  procedure gather_database_stats
    (estimate_percent number default 
       to_estimate_percent_type(get_param('ESTIMATE_PERCENT')),
     block_sample boolean default FALSE,
     method_opt varchar2 default get_param('METHOD_OPT'),
     degree number default to_degree_type(get_param('DEGREE')),
     granularity varchar2 default get_param('GRANULARITY'),
     cascade boolean default to_cascade_type(get_param('CASCADE')),
     stattab varchar2 default null, statid varchar2 default null,
     options varchar2 default 'GATHER', statown varchar2 default null,
     gather_sys boolean default TRUE,
     no_invalidate boolean default 
       to_no_invalidate_type(get_param('NO_INVALIDATE')),
     gather_temp boolean default FALSE,
     gather_fixed boolean default FALSE,
     stattype varchar2 default 'DATA');
--
-- Input arguments:
--   estimate_percent - Percentage of rows to estimate (NULL means compute).
--      The valid range is [0.000001,100].  Use the constant
--      DBMS_STATS.AUTO_SAMPLE_SIZE to have Oracle determine the
--      appropriate sample size for good statistics. This is the default.
--      The default value can be changed using set_param procedure.
--   block_sample - whether or not to use random block sampling instead of
--      random row sampling.  Random block sampling is more efficient, but
--      if the data is not randomly distributed on disk then the sample values
--      may be somewhat correlated.  Only pertinent when doing an estimate 
--      statistics.
--   method_opt - method options of the following format 
--           size_clause := SIZE [integer | auto | skewonly | repeat],
--              where integer is between 1 and 254
--         FOR ALL [INDEXED | HIDDEN] COLUMNS [size_clause]
--      default is FOR ALL COLUMNS SIZE AUTO.
--      The default value can be changed using set_param procedure.
--      This value will be passed to all of the individual tables.
--   degree - degree of parallelism (NULL means use table default value which
--      is specified by DEGREE clause in CREATE/ALTER TABLE statement)
--      Use the constant DBMS_STATS.DEFAULT_DEGREE for the default value
--      based on the initialization parameters.
--      default for degree is NULL.
--      The default value can be changed using set_param procedure.
--   granularity - the granularity of statistics to collect (only pertinent
--      if the table is partitioned)
--     'AUTO' - the procedure determines what level of statistics to collect
--     'GLOBAL AND PARTITION' - gather global- and partition-level statistics
--     'SUBPARTITION' - gather subpartition-level statistics
--     'PARTITION' - gather partition-level statistics
--     'GLOBAL' - gather global statistics
--     'ALL' - gather all (subpartition, partition, and global) statistics
--     default for granularity is AUTO. 
--     The default value can be changed using set_param procedure.
--   cascade - gather statistics on the indexes as well.
--      Use the constant DBMS_STATS.AUTO_CASCADE to have Oracle determine 
--      whether index stats to be collected or not. This is the default.
--      The default value can be changed using set_param procedure.
--      Index statistics gathering will not be parallelized.  Using this
--      option is equivalent to running the gather_index_stats procedure
--      on each of the indexes in the database in addition to gathering
--      table and column statistics.
--   stattab - The user stat table identifier describing where to save
--      the current statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   options - further specification of which objects to gather statistics for
--      'GATHER' - gather statistics on all objects in the schema
--      'GATHER AUTO' - gather all necessary statistics automatically.  Oracle
--        implicitly determines which objects need new statistics, and
--        determines how to gather those statistics.  When 'GATHER AUTO' is
--        specified, the only additional valid parameters are stattab,
--        statid, objlist and statown; all other parameter settings will be
--        ignored.  Also, return a list of objects processed.
--      'GATHER STALE' - gather statistics on stale objects as determined
--        by looking at the *_tab_modifications views.  Also, return
--        a list of objects found to be stale.
--      'GATHER EMPTY' - gather statistics on objects which currently
--        have no statistics.  also, return a list of objects found
--        to have no statistics.
--      'LIST AUTO' - return list of objects to be processed with 'GATHER AUTO'
--      'LIST STALE' - return list of stale objects as determined
--        by looking at the *_tab_modifications views
--      'LIST EMPTY' - return list of objects which currently
--        have no statistics
--   objlist - list of objects found to be stale or empty
--   statown - The schema containing stattab.  If null, it will assume
--      there is a table named stattab in each relevant schema in the 
--      database if stattab is specified for saving current statistics.
--   gather_sys - Gather statistics on the objects owned by the 'SYS' user
--      as well.
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--     The procedure invalidates the dependent cursors immediately
--     if set to FALSE.
--     Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--     invalidate dependend cursors. This is the default. The default 
--     can be changed using set_param procedure.
--     When 'cascade' option is specified, not pertinent with certain types
--     of indexes described in the gather_index_stats section.
--   gather_temp - gather stats on global temporary tables also.  The
--     temporary table must be created with "on commit preserve rows" clause,
--     and the statistics being collected are based on the data in the session
--     which this procedure is run but shared across all the sessions.
--   gather_fixed - Gather stats on fixed tables also.
--     Statistics for fixed tables can be collected only by user SYS.
--     Specified values for the following arguments will be ignored while 
--     gathering statistics for fixed tables.
--     gathering statistics for fixed tables.
--       estimate_percent, block_sample, stattab, statid, statown  
--     It will not invalidate the dependent cursors on fixed table
--     on which stats is collected.
--     This option is meant for internal use only.
--   
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: Bad input value
--   ORA-20002: Bad user statistics table, may need to upgrade it
--


  procedure generate_stats
    (ownname varchar2, objname varchar2,
     organized number default 7,
     force boolean default FALSE);
--
-- This procedure generates object statistics from previously collected
-- statistics of related objects.  For fully populated
-- schemas, the gather procedures should be used instead when more
-- accurate statistics are desired.
-- The currently supported objects are b-tree and bitmap indexes.
--
--   ownname - schema of object
--   objname - name of object
--   organized - the amount of ordering associated between the index and
--     its undelrying table.  A heavily organized index would have consecutive
--     index keys referring to consecutive rows on disk for the table
--     (the same block).  A heavily disorganized index would have consecutive
--     keys referencing different table blocks on disk.  This parameter is
--     only used for b-tree indexes.
--     The number can be in the range of 0-10, with 0 representing a completely
--     organized index and 10 a completely disorganized one.
--   force - generate statistics even if it is locked
-- Exceptions:
--   ORA-20000: Unsupported object type of object does not exist
--   ORA-20001: Invalid option or invalid statistics
--   ORA-20005: object statistics are locked
--




--
-- This procedure enables the flushing of in-memory monitoring
-- information to the dictionary.  Corresponding entries in the
-- *_tab_modifications views are updated immediately, without waiting
-- for Oracle to flush it periodically.  Useful for the users who need
-- up-to-date information in those views.
-- The gather_*_stats procedures internally flush the monitoring information
-- accordingly, and it is NOT necessary to run this procedure before
-- gathering the statistics.
-- 
--
-- The procedure is:
--
--  flush_database_monitoring_info
--
-- The modification monitoring mechanism is now controled by the
-- STATISTICS_LEVEL initialization parameter, and the following
-- procedures no longer have any effect:
--
--  alter_schema_tab_monitoring
--  alter_database_tab_monitoring
--

procedure flush_database_monitoring_info;
--
-- Flush in-memory monitoring information for all the tables to the dictionary.
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--

procedure alter_schema_tab_monitoring
  (ownname varchar2 default NULL, monitoring boolean default TRUE);
procedure alter_database_tab_monitoring
  (monitoring boolean default TRUE, sysobjs boolean default FALSE);



procedure gather_system_stats (
  gathering_mode  varchar2 default 'NOWORKLOAD',
  interval  integer  default 60,
  stattab   varchar2 default null, 
  statid    varchar2 default null,
  statown   varchar2 default null);
--
-- This procedure gathers system statistics. 
--
-- Input arguments:
--   mode - Allowable values: INTERVAL, START, STOP.
--     INTERVAL:
--       In INTERVAL mode user can provide interval parameter. After <interval>
--       minutes elapsed system statistics in dictionary or stattab will be
--       updated or created. This statistics captures system activity during
--       specified interval.
--     START | STOP:
--       START will initiate gathering statistics. STOP will calculate 
--       statistics for elapsed period of time (since START) and refresh
--       dictionary or stattab. Interval in these modes is ignored.
--   interval - Specifies period of time in minutes for gathering statistics
--      in INTERVAL mode.
--   stattab - The user stat table identifier describing where to save
--      the current statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different then ownname)
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20001: Bad input value
--   ORA-20002: Bad user statistics table, may need to upgrade it
--   ORA-20003: Unable to gather system statistics
--   ORA-20004: Error in "INTERVAL" mode :
--              system parameter job_queue_processes must be > 0
--

procedure get_system_stats (
   status     out   varchar2,
   dstart     out   date,
   dstop      out   date,
   pname            varchar2,
   pvalue     out   number,
   stattab          varchar2 default null, 
   statid           varchar2 default null,
   statown          varchar2 default null);

--
-- Input arguments:
--   stattab - The user stat table identifier describing from where to get
--      the current statistics info. If stattab is null, the statistics info
--      will be obtained directly from the dictionary.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different then ownname)
--   pname - parameter name to get
--
-- Output arguments:
--   status - returns one of the following: COMPLETED, AUTOGATHERING, 
--   MANUALGATHERING, BADSTATS
--   dstart - date when system stats gathering has been started
--   dstop - date when gathering was finished if status =  COMPLETE,
--   will be finished if status = AUTOGATHERING, 
--   had to be finished if status = BADSTATS,
--   dstarted if status = MANUALGATHERING,
--   the following parameters defined only if status = COMPLETE
--   pvalue   - parameter value to get
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20002: Bad user statistics table, may need to upgrade it
--   ORA-20003: Unable to get system statistics
--   ORA-20004: Parameter doesn't exist 
--

procedure set_system_stats (
   pname            varchar2,
   pvalue           number,
   stattab          varchar2 default null, 
   statid           varchar2 default null,
   statown          varchar2 default null);

--
-- Input arguments:
--   pname - parameter name to set
--   pvalue   - parameter value to set
--   stattab - The user stat table identifier describing from where to get
--      the current statistics info. If stattab is null, the statistics info
--      will be obtained directly from the dictionary.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different then ownname)
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20001: Invalid input value
--   ORA-20002: Bad user statistics table, may need to upgrade it
--   ORA-20003: Unable to set system statistics
--   ORA-20004: Parameter doesn't exist 
--


procedure delete_system_stats (
   stattab         varchar2  default nulL, 
   statid          varchar2  default nulL,
   statown         varchar2  default null);

--
-- Deletes system statistics
--
-- Input arguments:
--   stattab - The user stat table identifier describing from where
--      to delete the statistics.  If stattab is null, the statistics
--      will be deleted directly from the dictionary.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab (Only pertinent if stattab is not NULL).
--   statown - The schema containing stattab (if different then ownname)
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20002: Bad user statistics table, may need to upgrade it
--

procedure import_system_stats (
   stattab  varchar2, 
   statid   varchar2 default null,
   statown  varchar2 default null);

--
-- Retrieves system statistics from the user
-- stat table identified by stattab and stores it in the
-- dictionary
--
-- Input arguments:
--   stattab - The user stat table identifier describing from where
--      to retrieve the statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different then ownname)
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20001: Invalid or inconsistent values in the user stat table
--   ORA-20002: Bad user statistics table, may need to upgrade it
--   ORA-20003: Unable to import system statistics
--


procedure export_system_stats (
   stattab  varchar2, 
   statid   varchar2 default null,
   statown  varchar2 default null);

--
-- Retrieves system statistics and stores it
-- in the user stat table identified by stattab
--
-- Input arguments:
--   stattab - The user stat table identifier describing where
--      to store the statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different then ownname)
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20002: Bad user statistics table, may need to upgrade it
--   ORA-20003: Unable to export system statistics
--


  procedure gather_fixed_objects_stats
    (stattab varchar2 default null, statid varchar2 default null,
     statown varchar2 default null,
     no_invalidate boolean default 
       to_no_invalidate_type(get_param('NO_INVALIDATE')));
--
-- Gather statitsics for fixed tables. 
-- To run this procedure, you must have the SYSDBA or ANALYZE ANY DICTIONARY
-- system privilege. 
--
-- Input arguments:
--   stattab - The user stat table identifier describing where to save
--      the current statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different then ownname)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
-- Exceptions:
--   ORA-20000: insufficient privileges
--   ORA-20001: Bad input value
--   ORA-20002: Bad user statistics table, may need to upgrade it
--


  procedure delete_fixed_objects_stats(
        stattab varchar2 default null, statid varchar2 default null,
        statown varchar2 default null,
        no_invalidate boolean default 
        to_no_invalidate_type(get_param('NO_INVALIDATE')),
        force boolean default FALSE);
--
-- Deletes statistics for fixed tables
-- To run this procedure, you must have the SYSDBA or ANALYZE ANY DICTIONARY
-- system privilege. 
--
-- Input arguments:
--   stattab - The user stat table identifier describing from where
--      to delete the statistics.  If stattab is null, the statistics
--      will be deleted directly in the dictionary.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab (Only pertinent if stattab is not NULL).
--   statown - The schema containing stattab (if different then ownname)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   force - Ignores the statistics lock on objects and delete
--           the statistics if set to TRUE.
--
-- Exceptions:
--   ORA-20000: insufficient privileges
--   ORA-20002: Bad user statistics table, may need to upgrade it
--


  procedure export_fixed_objects_stats(
        stattab varchar2, statid varchar2 default null,
        statown varchar2 default null);
--
-- Retrieves statistics for fixed tables and stores them in the user 
-- stat table identified by stattab
-- To run this procedure, you must have the SYSDBA or ANALYZE ANY DICTIONARY
-- system privilege. 
--
-- Input arguments:
--   stattab - The user stat table identifier describing where
--      to store the statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different then ownname)
--
-- Exceptions:
--   ORA-20000: insufficient privileges
--   ORA-20002: Bad user statistics table, may need to upgrade it
--


  procedure import_fixed_objects_stats(
        stattab varchar2, statid varchar2 default null,
        statown varchar2 default null, 
        no_invalidate boolean default 
           to_no_invalidate_type(get_param('NO_INVALIDATE')),
        force boolean default FALSE);
--
-- Retrieves statistics for fixed tables from the user stat table and 
-- stores them in the dictionary 
-- To run this procedure, you must have the SYSDBA or ANALYZE ANY DICTIONARY
-- system privilege. 
--
-- Input arguments:
--   stattab - The user stat table identifier describing from where
--      to retrieve the statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different then ownname)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   force - Override statistics lock.
--     TRUE- Ignores the statistics lock on objects and import
--           the statistics. 
--     FALSE-The statistics of an object will be imported only if it 
--           is not locked. 
--
-- Exceptions:
--   ORA-20000: insufficient privileges
--   ORA-20001: Invalid or inconsistent values in the user stat table
--   ORA-20002: Bad user statistics table, may need to upgrade it
--

  procedure gather_dictionary_stats
    (comp_id varchar2 default null,
     estimate_percent number default 
       to_estimate_percent_type(get_param('ESTIMATE_PERCENT')),
     block_sample boolean default FALSE,
     method_opt varchar2 default get_param('METHOD_OPT'),
     degree number default to_degree_type(get_param('DEGREE')),
     granularity varchar2 default get_param('GRANULARITY'),
     cascade boolean default to_cascade_type(get_param('CASCADE')),
     stattab varchar2 default null, statid varchar2 default null,
     options varchar2 default 'GATHER AUTO', objlist out ObjectTab,
     statown varchar2 default null,
     no_invalidate boolean default 
       to_no_invalidate_type(get_param('NO_INVALIDATE')),
     stattype varchar2 default 'DATA');
  procedure gather_dictionary_stats
    (comp_id varchar2 default null,
     estimate_percent number default 
       to_estimate_percent_type(get_param('ESTIMATE_PERCENT')),
     block_sample boolean default FALSE,
     method_opt varchar2 default get_param('METHOD_OPT'),
     degree number default to_degree_type(get_param('DEGREE')),
     granularity varchar2 default get_param('GRANULARITY'),
     cascade boolean default to_cascade_type(get_param('CASCADE')),
     stattab varchar2 default null, statid varchar2 default null,
     options varchar2 default 'GATHER AUTO', statown varchar2 default null,
     no_invalidate boolean default 
       to_no_invalidate_type(get_param('NO_INVALIDATE')),
     stattype varchar2 default 'DATA');

--
-- Gather statistics for dictionary schemas 'SYS', 'SYSTEM' and schemas of
-- RDBMS components.
-- To run this procedure, you must have the SYSDBA OR 
-- both ANALYZE ANY DICTIONARY and ANALYZE ANY system privilege. 
--
-- Input arguments:
--   comp_id - component id of the schema to analyze (NULL means schemas
--             of all RDBMS components). 
--             Please refer to comp_id column of dba_registry view.
--             The procedure always gather stats on 'SYS' and 'SYSTEM' schemas
--             regardless of this argument.
--   estimate_percent - Percentage of rows to estimate (NULL means compute).
--      The valid range is [0.000001,100].  Use the constant
--      DBMS_STATS.AUTO_SAMPLE_SIZE to have Oracle determine the
--      appropriate sample size for good statistics. This is the default.
--      The default value can be changed using set_param procedure.
--   block_sample - whether or not to use random block sampling instead of
--      random row sampling.  Random block sampling is more efficient, but
--      if the data is not randomly distributed on disk then the sample values
--      may be somewhat correlated.  Only pertinent when doing an estimate 
--      statistics.
--   method_opt - method options of the following format 
--           size_clause := SIZE [integer | auto | skewonly | repeat],
--              where integer is between 1 and 254
--         FOR ALL [INDEXED | HIDDEN] COLUMNS [size_clause]
--      default is FOR ALL COLUMNS SIZE AUTO.
--      The default value can be changed using set_param procedure.
--      This value will be passed to all of the individual tables.
--   degree - degree of parallelism (NULL means use table default value which
--      is specified by DEGREE clause in CREATE/ALTER TABLE statement)
--      Use the constant DBMS_STATS.DEFAULT_DEGREE for the default value
--      based on the initialization parameters.
--      default for degree is NULL.
--      The default value can be changed using set_param procedure.
--   granularity - the granularity of statistics to collect (only pertinent
--      if the table is partitioned)
--     'AUTO' - the procedure determines what level of statistics to collect
--     'GLOBAL AND PARTITION' - gather global- and partition-level statistics
--     'SUBPARTITION' - gather subpartition-level statistics
--     'PARTITION' - gather partition-level statistics
--     'GLOBAL' - gather global statistics
--     'ALL' - gather all (subpartition, partition, and global) statistics
--     default for granularity is AUTO. 
--     The default value can be changed using set_param procedure.
--   cascade - gather statistics on the indexes as well.
--      Use the constant DBMS_STATS.AUTO_CASCADE to have Oracle determine 
--      whether index stats to be collected or not. This is the default.
--      The default value can be changed using set_param procedure.
--      Index statistics gathering will not be parallelized.  Using this
--      option is equivalent to running the gather_index_stats procedure
--      on each of the indexes in the schema in addition to gathering
--      table and column statistics.
--   stattab - The user stat table identifier describing where to save
--      the current statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   options - further specification of which objects to gather statistics for
--      'GATHER' - gather statistics on all objects in the schema
--      'GATHER AUTO' - gather all necessary statistics automatically.  Oracle
--        implicitly determines which objects need new statistics, and
--        determines how to gather those statistics.  When 'GATHER AUTO' is
--        specified, the only additional valid parameters are comp_id, stattab,
--        statid and statown; all other parameter settings will be
--        ignored. Also, return a list of objects processed.
--      'GATHER STALE' - gather statistics on stale objects as determined
--        by looking at the *_tab_modifications views.  Also, return
--        a list of objects found to be stale.
--      'GATHER EMPTY' - gather statistics on objects which currently
--        have no statistics.  also, return a list of objects found
--        to have no statistics.
--      'LIST AUTO' - return list of objects to be processed with 'GATHER AUTO'
--      'LIST STALE' - return list of stale objects as determined
--        by looking at the *_tab_modifications views
--      'LIST EMPTY' - return list of objects which currently
--        have no statistics
--   objlist - list of objects found to be stale or empty
--   statown - The schema containing stattab (if different from current schema)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--     The procedure invalidates the dependent cursors immediately
--     if set to FALSE.
--     Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--     invalidate dependend cursors. This is the default. The default 
--     can be changed using set_param procedure.
--     When 'cascade' option is specified, not pertinent with certain types
--     of indexes described in the gather_index_stats section.
-- Exceptions:
--   ORA-20000: Schema does not exist or insufficient privileges
--   ORA-20001: Bad input value
--   ORA-20002: Bad user statistics table, may need to upgrade it
--

  procedure delete_dictionary_stats(
        stattab varchar2 default null, statid varchar2 default null,
        statown varchar2 default null,
        no_invalidate boolean default 
          to_no_invalidate_type(get_param('NO_INVALIDATE')),
        stattype varchar2 default 'ALL',
        force boolean default FALSE);
--
-- Deletes statistics for all dictionary schemas ('SYS', 'SYSTEM' and
-- RDBMS component schemas) 
--
-- To run this procedure, you must have the SYSDBA OR 
-- both ANALYZE ANY DICTIONARY and ANALYZE ANY system privilege. 
--
-- Input arguments:
--   stattab - The user stat table identifier describing from where
--      to delete the statistics.  If stattab is null, the statistics
--      will be deleted directly in the dictionary.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab (Only pertinent if stattab is not NULL).
--   statown - The schema containing stattab (if different from current schema)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   stattype - The type of statistics to be deleted
--     ALL   - both data and cache statistics will be deleted
--     CACHE - only cache statistics will be deleted 
--   force - Ignores the statistics lock on objects and delete
--           the statistics if set to TRUE.
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20002: Bad user statistics table, may need to upgrade it
--

  procedure export_dictionary_stats(
        stattab varchar2, statid varchar2 default null,
        statown varchar2 default null);
--
-- Retrieves statistics for all dictionary schemas ('SYS', 'SYSTEM' and
-- RDBMS component schemas) and stores them in the user stat table 
-- identified by stattab
--
-- To run this procedure, you must have the SYSDBA OR 
-- both ANALYZE ANY DICTIONARY and ANALYZE ANY system privilege. 
--
-- Input arguments:
--   stattab - The user stat table identifier describing where
--      to store the statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different from current schema)
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20002: Bad user statistics table, may need to upgrade it
--
  procedure import_dictionary_stats(
        stattab varchar2, statid varchar2 default null,
        statown varchar2 default null,
        no_invalidate boolean default 
          to_no_invalidate_type(get_param('NO_INVALIDATE')),
        force boolean default FALSE);
--
-- Retrieves statistics for all dictionary schemas ('SYS', 'SYSTEM' and
-- RDBMS component schemas) from the user stat table and stores them in 
-- the dictionary 
--
-- To run this procedure, you must have the SYSDBA OR 
-- both ANALYZE ANY DICTIONARY and ANALYZE ANY system privilege. 
--
-- Input arguments:
--   stattab - The user stat table identifier describing from where
--      to retrieve the statistics.
--   statid - The (optional) identifier to associate with these statistics
--      within stattab.
--   statown - The schema containing stattab (if different from current schema)
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--   force - Override statistics lock.
--     TRUE- Ignores the statistics lock on objects and import
--           the statistics. 
--     FALSE-The statistics of an object will be imported only if it 
--           is not locked. 
--           ie if both DATA and CACHE statistics is locked, it will not
--           import anything. If CACHE statistics of an object is locked, 
--           only DATA statistics will be imported and vice versa.
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20001: Invalid or inconsistent values in the user stat table
--   ORA-20002: Bad user statistics table, may need to upgrade it
--

  procedure lock_table_stats(
    ownname varchar2, 
    tabname varchar2, 
    stattype varchar2 default 'ALL');
-- 
-- This procedure enables the user to lock the statistics on the table
--
-- Input arguments:
--   ownname  - schema of table to lock
--   tabname  - name of the table
--   stattype - type of statistics to be locked
--     'CACHE'  - lock only caching statistics  
--     'DATA'   - lock only data statistics  
--     'ALL'    - lock both data and caching statistics. This is the default  

-- THE FOLLOWING PROCEDURE IS FOR INTERNAL USE ONLY.
-- This procedure enables the user to lock statistics for a parition
  procedure lock_partition_stats(
    ownname varchar2,
    tabname varchar2,
    partname varchar2);

  procedure lock_schema_stats(
    ownname varchar2, 
    stattype varchar2 default 'ALL');
-- 
-- This procedure enables the user to lock the statistics of all
-- tables of a schema
--
-- Input arguments:
--   ownname  - schema of tables to lock
--   stattype - type of statistics to be locked
--     'CACHE'  - lock only caching statistics  
--     'DATA'   - lock only data statistics  
--     'ALL'    - lock both data and caching statistics. This is the default  


  procedure unlock_table_stats(
    ownname varchar2, 
    tabname varchar2, 
    stattype varchar2 default 'ALL');
-- 
-- This procedure enables the user to unlock the statistics on the table
--
-- Input arguments:
--   ownname  - schema of table to unlock
--   tabname  - name of the table
--   stattype - type of statistics to be unlocked
--     'CACHE'  - unlock only caching statistics  
--     'DATA'   - unlock only data statistics  
--     'ALL'    - unlock both data and caching statistics. This is the default  

-- THE FOLLOWING PROCEDURE IS FOR INTERNAL USE ONLY.
-- This procedure enables the user to unlock statistics for a parition
  procedure unlock_partition_stats(
    ownname varchar2,
    tabname varchar2,
    partname varchar2);

  procedure unlock_schema_stats(
    ownname varchar2, 
    stattype varchar2 default 'ALL');
-- 
-- This procedure enables the user to unlock the statistics of all
-- tables of a schema
--
-- Input arguments:
--   ownname  - schema of tables to unlock
--   stattype - type of statistics to be unlocked
--     'CACHE'  - unlock only caching statistics  
--     'DATA'   - unlock only data statistics  
--     'ALL'    - unlock both data and caching statistics. This is the default  

  procedure restore_table_stats(
    ownname varchar2, 
    tabname varchar2, 
    as_of_timestamp timestamp with time zone,
    restore_cluster_index boolean default FALSE,
    force boolean default FALSE,
    no_invalidate boolean default 
      to_no_invalidate_type(get_param('NO_INVALIDATE')));
-- 
-- This procedure enables the user to restore statistics of a table as of
-- a specified timestamp (as_of_timestamp). The procedure will restore 
-- statistics of associated indexes and columns as well. If the table 
-- statistics were locked at the specified timestamp the procedure will 
-- lock the statistics.
-- Note:
--   The procedure may not restore statistics correctly if analyze interface 
--   is used for computing/deleting statistics.
--   Old statistics versions are not saved when SYSAUX tablespace is
--   offline, this affects restore functionality. 
--   The procedure may not restore statistics if the table defn is
--   changed (eg: column added/deleted, partition exchanged etc).
--   Also it will not restore stats if the object is created after
--   the specified timestamp.
--   The procedure will not restore user defined statistics.
-- Input arguments:
--   ownname  - schema of table for which statistics to be restored
--   tabname  - table name 
--   as_of_timestamp - statistics as of this timestamp will be restored.
--   restore_cluster_index - If the table is part of a cluster,
--     restore statistics of the cluster index if set to TRUE.
--   force - restore statistis even if the table statistics are locked.
--           if the table statistics were not locked at the specified 
--           timestamp, it will unlock the statistics 
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20001: Invalid or inconsistent values 
--   ORA-20006: Unable to restore statistics , statistics history not available

  procedure restore_schema_stats(
    ownname varchar2, 
    as_of_timestamp timestamp with time zone,
    force boolean default FALSE,
    no_invalidate boolean default 
      to_no_invalidate_type(get_param('NO_INVALIDATE')));
-- 
-- This procedure enables the user to restore statistics of all tables of
-- a schema as of a specified timestamp (as_of_timestamp). 

-- Input arguments:
--   ownname  - schema of tables for which statistics to be restored
--   as_of_timestamp - statistics as of this timestamp will be restored.
--   force - restore statistis of tables even if their statisics are locked.
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--
-- Exceptions:
--   ORA-20000: Object does not exist or insufficient privileges
--   ORA-20001: Invalid or inconsistent values 
--   ORA-20006: Unable to restore statistics , statistics history not available

  procedure restore_database_stats(
    as_of_timestamp timestamp with time zone,
    force boolean default FALSE,
    no_invalidate boolean default 
      to_no_invalidate_type(get_param('NO_INVALIDATE')));
-- 
-- This procedure enables the user to restore statistics of all tables of
-- the database as of a specified timestamp (as_of_timestamp). 

-- Input arguments:
--   as_of_timestamp - statistics as of this timestamp will be restored.
--   force - restore statistis of tables even if their statisics are locked.
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: Invalid or inconsistent values 
--   ORA-20006: Unable to restore statistics , statistics history not available

  procedure restore_fixed_objects_stats(
    as_of_timestamp timestamp with time zone,
    force boolean default FALSE,
    no_invalidate boolean default 
      to_no_invalidate_type(get_param('NO_INVALIDATE')));
-- 
-- This procedure enables the user to restore statistics of all fixed tables
-- as of a specified timestamp (as_of_timestamp). 
-- To run this procedure, you must have the SYSDBA or ANALYZE ANY DICTIONARY
-- system privilege.
--
-- Input arguments:
--   as_of_timestamp - statistics as of this timestamp will be restored.
--   force - restore statistis of tables even if their statisics are locked.
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: Invalid or inconsistent values 
--   ORA-20006: Unable to restore statistics , statistics history not available

  procedure restore_dictionary_stats(
    as_of_timestamp timestamp with time zone,
    force boolean default FALSE,
    no_invalidate boolean default 
      to_no_invalidate_type(get_param('NO_INVALIDATE')));
-- 
-- This procedure enables the user to restore statistics of all dictionary 
-- tables (tables of 'SYS', 'SYSTEM' and RDBMS component schemas)
-- as of a specified timestamp (as_of_timestamp). 
--
-- To run this procedure, you must have the SYSDBA OR
-- both ANALYZE ANY DICTIONARY and ANALYZE ANY system privilege.
--
-- Input arguments:
--   as_of_timestamp - statistics as of this timestamp will be restored.
--   force - restore statistis of tables even if their statisics are locked.
--   no_invalidate - Do not invalide the dependent cursors if set to TRUE.
--      The procedure invalidates the dependent cursors immediately
--      if set to FALSE.
--      Use DBMS_STATS.AUTO_INVALIDATE to have oracle decide when to
--      invalidate dependend cursors. This is the default. The default 
--      can be changed using set_param procedure.
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: Invalid or inconsistent values 
--   ORA-20006: Unable to restore statistics , statistics history not available

  procedure restore_system_stats(
    as_of_timestamp timestamp with time zone);
-- 
-- This procedure enables the user to restore system statistics 
-- as of a specified timestamp (as_of_timestamp). 
--
-- Input arguments:
--   as_of_timestamp - statistics as of this timestamp will be restored.
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: Invalid or inconsistent values 
--   ORA-20006: Unable to restore statistics , statistics history not available

  procedure purge_stats(
    before_timestamp timestamp with time zone);
-- 
-- This procedure enables the user to purge old versions of statistics 
-- saved in dictionary
--
-- To run this procedure, you must have the SYSDBA OR 
-- both ANALYZE ANY DICTIONARY and ANALYZE ANY system privilege. 
--
-- Input arguments:
--   before_timestamp - versions of statistics saved before this timestamp
--             will be purged. if null, it uses the purging policy 
--             used by automatic purge. The automatic purge deletes all
--             history older than 
--               min(current time - stats history retention, 
--                   time of recent analyze in the system - 1). 
--             stats history retention value can be changed using 
--             alter_stats_history_retention procedure. 
--             The default is 31 days. 
--             
--
-- Exceptions:
--   ORA-20000: Insufficient privileges
--   ORA-20001: Invalid or inconsistent values 

  procedure alter_stats_history_retention(
    retention in number);
--
-- This procedure enables the user to change stats history retention
-- value.  Stats history retention is used by both the automatic 
-- purge and purge_stats procedure. 
--  
--
-- To run this procedure, you must have the SYSDBA OR 
-- both ANALYZE ANY DICTIONARY and ANALYZE ANY system privilege. 
--
-- Input arguments:
--   retention - The retention time in days. The stats history will be
--               ratained for at least these many number of days.
--               The valid range is [1,365000].  Also the following
--               values can be used for special purposes.
--                 0 - old stats are never saved. The automatic purge will
--                     delete all stats history
--                -1 - stats history is never purged by automatic purge.
--                null -  change stats history retention to default value
 
--               

  function get_stats_history_retention return number;

-- This function returns the current retention value.

  function get_stats_history_availability
             return timestamp with time zone;

--  This function returns oldest timestamp where stats history 
--  is available.
--  Users can not restore stats to timestamp older than  this one.

-- THE FOLLOWING PROCEDURE IS FOR INTERNAL USE ONLY.
-- copy stats for one partition to another
  procedure copy_table_stats(
        ownname varchar2,
        tabname varchar2,
        srcpartname varchar2,
        dstpartname varchar2,
        flags number DEFAULT null,
        force boolean DEFAULT FALSE);


--
-- The following procedure is for internal use only.
--
--  gather_database_stats_job_proc
--  cleanup_stats_job_proc
--
procedure gather_database_stats_job_proc;

procedure cleanup_stats_job_proc(
      ctx number, job_owner varchar2, job_name varchar2,
      sesid number, sesser number);

end;
/
create or replace public synonym dbms_stats for sys.dbms_stats
/
grant execute on dbms_stats to public
/
create role gather_system_statistics
/
grant update, insert, select, delete on aux_stats$ to gather_system_statistics 
/
grant gather_system_statistics to dba
/

-- create the trusted pl/sql callout library
CREATE OR REPLACE LIBRARY DBMS_STATS_LIB TRUSTED AS STATIC;
/
