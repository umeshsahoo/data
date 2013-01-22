rem 
rem $Header: dbmssql.sql 09-oct-2002.13:35:57 mxyang Exp $ 
rem 
Rem Copyright (c) 1991, 2002, Oracle Corporation.  All rights reserved.  
Rem    NAME
Rem      dbmssql.sql - DBMS package for dynamic SQL
Rem   DESCRIPTION
Rem     This package provides a means to use dynamic SQL to access
Rem     the database.
Rem   NOTES
Rem     The procedural option is needed to use this package.
Rem     This package must be created under SYS.
Rem     The operations provided by this package are performed under the current
Rem     calling user, not under the package owner SYS. The old file name
Rem     for this package was dbms_sql.sql.
Rem
Rem     
Rem   MODIFIED     (MM/DD/YY)
Rem     mxyang     10/09/02  - Binary_Float_Table/Binary_Double_Table
Rem     mxyang     09/09/02  - binary_float and binary_double
Rem     lvbcheng   10/01/02  - Remove tabs
Rem     lvbcheng   09/09/02  - Redefine varchar2a with smaller length
Rem     lvbcheng   07/31/02  - bug 2410688: Add varchar2a
Rem     celsbern   10/19/01  - merge LOG to MAIN
Rem     alakshmi   09/12/01  - Remove command codes for streams
Rem     alakshmi   09/07/01  - object type codes
Rem     arrajara   08/21/01  - Expose SQL command codes
Rem     gviswana   10/24/01  - AUTHID CURRENT_USER
Rem     gviswana   05/24/01  - CREATE OR REPLACE SYNONYM
Rem     sbedarka   10/13/00  - #(702903) handle col_name overflow via new API
Rem     cbarclay   11/23/99  - new datetime subtypes
Rem     mvemulap   09/02/99 -  array support for datetime and urowid
Rem     rshaikh    08/09/99 -  remove v80, v815, v816
Rem     gviswana   07/20/99  - Add MAX for SQL version numbers                 
Rem     mvemulap   06/22/99  - add support for datetime types                  
Rem     mvemulap   06/03/99  - enhancements for datetime and urowid            
Rem     rshaikh    05/03/99  - add v815,v816 sql version                       
Rem     nlewis     01/15/98 -  remove mlslabels
Rem     sbedarka   09/25/97 -  #(384171) fix WNDS for parse
Rem     sbedarka   09/23/97 -  #(384171): add restrict_references assertions to
Rem                            DBMS_SQL routinnes, as appropriate
Rem     mluong     04/14/97 -  fix compile err
Rem     bgoyal     04/09/97 -  add date, varchar, lob, bfile support in 
Rem                            variable value
Rem     bgoyal     03/30/97 -  adding ntab to variable_value
Rem     gviswana   03/19/97 -  Bug 411390 - get public types from prvtsql
Rem     ajasuja    11/23/96 -  nchar support
Rem     nmichael   09/04/96 -  Bulk SQL lob support
Rem     rmurthy    11/01/96 -  remove cfile references
Rem     nmichael   08/30/96 -  Addition of array_define functionality
Rem     nmichael   08/09/96 -  Bulk SQL for dbms_sql
Rem     nmichael   07/15/96 -  Remove show errors statements
Rem     nmichael   06/12/96 -  Lob support for dynamic SQL
Rem     nmichael   06/02/96 -  Enhancements for V8 for dynamic SQL
Rem     hjakobss   01/18/95 -  merge changes from branch 1.8.720.2
Rem     adowning   03/29/94 -  merge changes from branch 1.4.710.4
Rem     adowning   02/02/94 -  split file into public / private binary files
Rem     dsdaniel   01/18/94 -  merge changes from branch 1.4.710.3
Rem     hjakobss   01/06/94 -  merge changes from branch 1.4.710.2
Rem     dsdaniel   12/27/93 -  create dbms_sys_sql package for parse as user
Rem     hjakobss   12/10/93 -  support array parse and mlslabel
Rem     hjakobss   12/09/93 -  merge changes from branch 1.4.710.1
Rem     hjakobss   10/26/93 -  appease marketing
Rem     hjakobss   07/06/93 -  add new datatypes
Rem     hjakobss   06/17/93 -  add get_rpi_cursor
Rem     hjakobss   05/10/93 -  Merge from 7.0.14 
Rem     hjakobss   05/07/93 -  change procedure names 
Rem     hjakobss   04/02/93 -  Branch_for_the_patch 
Rem     hjakobss   01/28/93 -  Add new features 
Rem     jwijaya    01/11/93 -  merge changes from branch 1.1.312.1 
Rem     jwijaya    01/11/93 -  bug 139792 
Rem     jwijaya    10/21/92 -  Creation 

REM  ************************************************************
REM  THIS PACKAGE MUST NOT BE MODIFIED BY THE CUSTOMER.  DOING SO
REM  COULD CAUSE INTERNAL ERRORS AND CORRUPTIONS IN THE RDBMS.
REM  ************************************************************

REM  ***************************************
REM  THIS PACKAGE MUST BE CREATED UNDER SYS.
REM  ***************************************

create or replace package dbms_sql AUTHID CURRENT_USER is

  ------------
  --  OVERVIEW
  --
  --  This package provides a means to use dynamic SQL to access the database.
  --

  -------------------------
  --  RULES AND LIMITATIONS
  --
  --  Bind variables of a SQL statement are identified by their names.
  --  When binding a value to a bind variable, the string identifying
  --  the bind variable in the statement may optionally contain the
  --  leading colon. For example, if the parsed SQL statement is
  --  "SELECT ENAME FROM EMP WHERE SAL > :X", on binding the variable
  --  to a value, it can be identified using either of the strings ':X'
  --  and 'X'.
  --
  --  Columns of the row being selected in a SELECT statement are identified
  --  by their relative positions (1, 2, 3, ...) as they appear on the select
  --  list from left to right.
  --  
  --  Privileges are associated with the caller of the procedures/functions
  --  in this package as follows:
  --    If the caller is an anonymous PL/SQL block, the procedures/functions
  --    are run using the privileges of the current user.
  --    If the caller is a stored procedure, the procedures/functions are run
  --    using the privileges of the owner of the stored procedure.
  --
  --  WARNING: Using the package to dynamically execute DDL statements can 
  --  results in the program hanging. For example, a call to a procedure in a 
  --  package will result in the package being locked until the execution 
  --  returns to the user side. Any operation that results in a conflicting 
  --  lock, such as dynamically trying to drop the package, before the first 
  --  lock is released will result in a hang. 
  --
  --  The flow of procedure calls will typically look like this:
  --
  --                      -----------
  --                    | open_cursor |
  --                      -----------
  --                           |
  --                           |
  --                           v
  --                         -----
  --          ------------>| parse |
  --         |               -----
  --         |                 |
  --         |                 |---------
  --         |                 v         |
  --         |           --------------  |
  --         |-------->| bind_variable | |
  --         |     ^     -------------   |
  --         |     |           |         |
  --         |      -----------|         |
  --         |                 |<--------
  --         |                 v
  --         |               query?---------- yes ---------
  --         |                 |                           |
  --         |                no                           |
  --         |                 |                           |
  --         |                 v                           v
  --         |              -------                  -------------
  --         |----------->| execute |            ->| define_column |
  --         |              -------             |    -------------
  --         |                 |------------    |          |
  --         |                 |            |    ----------|
  --         |                 v            |              v
  --         |           --------------     |           -------
  --         |       ->| variable_value |   |  ------>| execute |
  --         |      |    --------------     | |         -------
  --         |      |          |            | |            |
  --         |       ----------|            | |            |
  --         |                 |            | |            v
  --         |                 |            | |        ----------
  --         |                 |<-----------  |----->| fetch_rows |
  --         |                 |              |        ----------
  --         |                 |              |            |
  --         |                 |              |            v
  --         |                 |              |    --------------------
  --         |                 |              |  | column_value         |
  --         |                 |              |  | variable_value       |
  --         |                 |              |    ---------------------
  --         |                 |              |            |
  --         |                 |<--------------------------
  --         |                 |
  --          -----------------|
  --                           |
  --                           v
  --                      ------------
  --                    | close_cursor |
  --                      ------------ 
  --
  ---------------

  -------------
  --  CONSTANTS
  --
  v6 constant integer := 0;
  native constant integer := 1;
  v7 constant integer := 2;
  --

  --  TYPES
  --
  type varchar2a is table of varchar2(32767) index by binary_integer;
  -- bug 2410688: for users who require larger than varchar2(256),
  -- this type has been introduced together with parse overloads
  -- that take this type.
  type varchar2s is table of varchar2(256) index by binary_integer;
  -- Note that with the introduction of varchar2a we will deprecate
  -- this type, with phase out over a number of releases.
  -- For DateTime types, the field col_scale is used to denote the
  -- fractional seconds precision.
  -- For Interval types, the field col_precision is used to denote
  -- the leading field precision and the field col_scale is used to
  -- denote the fractional seconds precision.
  type desc_rec is record (
        col_type            binary_integer := 0,
        col_max_len         binary_integer := 0,
        col_name            varchar2(32)   := '',
        col_name_len        binary_integer := 0,
        col_schema_name     varchar2(32)   := '',
        col_schema_name_len binary_integer := 0,
        col_precision       binary_integer := 0,
        col_scale           binary_integer := 0,
        col_charsetid       binary_integer := 0,
        col_charsetform     binary_integer := 0,
        col_null_ok         boolean        := TRUE);
  type desc_tab is table of desc_rec index by binary_integer;
  -- bug 702903 reveals that col_name can be of any length, not just 32 which 
  -- can be resolved by changing the maximum size above from 32 to 32767.
  -- However, this will affect the signature of the package and to avoid that
  -- side effect, the current API describe_columns is left unchanged but a new
  -- API describe_columns2 is added at the end of this package specification.
  -- The new API relies on a table type desc_tab2 whose array element is a new
  -- record type desc_rec2, and desc_rec2 contains the variable col_name with a
  -- maximum size of 32,767.
  -- If the original API describe_columns is used and col_name encounters an
  -- overflow, an error will be raised.
  type desc_rec2 is record (
        col_type            binary_integer := 0,
        col_max_len         binary_integer := 0,
        col_name            varchar2(32767) := '',
        col_name_len        binary_integer := 0,
        col_schema_name     varchar2(32)   := '',
        col_schema_name_len binary_integer := 0,
        col_precision       binary_integer := 0,
        col_scale           binary_integer := 0,
        col_charsetid       binary_integer := 0,
        col_charsetform     binary_integer := 0,
        col_null_ok         boolean        := TRUE);
  type desc_tab2 is table of desc_rec2 index by binary_integer;
  ------------
  -- Bulk SQL Types
  --
  type Number_Table   is table of number         index by binary_integer;
  type Varchar2_Table is table of varchar2(2000) index by binary_integer;
  type Date_Table     is table of date           index by binary_integer;

  type Blob_Table     is table of Blob           index by binary_integer;
  type Clob_Table     is table of Clob           index by binary_integer;
  type Bfile_Table    is table of Bfile          index by binary_integer;
  TYPE Urowid_Table   IS TABLE OF urowid         INDEX BY binary_integer;
  TYPE time_Table     IS TABLE OF time_unconstrained           INDEX BY binary_integer;  
  TYPE timestamp_Table   IS TABLE OF timestamp_unconstrained         INDEX BY binary_integer;
  TYPE time_with_time_zone_Table IS TABLE OF TIME_TZ_UNCONSTRAINED INDEX BY binary_integer;
  TYPE timestamp_with_time_zone_Table IS TABLE OF 
    TIMESTAMP_TZ_UNCONSTRAINED INDEX BY binary_integer;
  TYPE timestamp_with_ltz_Table IS TABLE OF 
    TIMESTAMP_LTZ_UNCONSTRAINED INDEX BY binary_integer;
  TYPE interval_year_to_MONTH_Table IS TABLE OF 
    yminterval_unconstrained INDEX BY binary_integer;
  TYPE interval_day_to_second_Table IS TABLE OF 
    dsinterval_unconstrained INDEX BY binary_integer;
  type Binary_Float_Table is table of binary_float index by binary_integer;
  type Binary_Double_Table is table of binary_double index by binary_integer;
  
--  type Cfile_Table    is table of Cfile          index by binary_integer;
  --------------
  --  EXCEPTIONS
  --
  inconsistent_type exception;
    pragma exception_init(inconsistent_type, -6562);
  --  This exception is raised by procedure "column_value" or
  --  "variable_value" if the type of the given out argument where
  --  to put the requested value is different from the type of the value.

  ----------------------------
  --  PROCEDURES AND FUNCTIONS
  --
  function open_cursor return integer;
  pragma restrict_references(open_cursor,RNDS,WNDS);
  --  Open a new cursor.
  --  When no longer needed, this cursor MUST BE CLOSED explicitly by
  --  calling "close_cursor".
  --  Return value:
  --    Cursor id number of the new cursor.
  --
  function is_open(c in integer) return boolean;
  pragma restrict_references(is_open,RNDS,WNDS);
  --  Return TRUE is the given cursor is currently open.
  --  Input parameters:
  --    c
  --      Cursor id number of the cursor to check.
  --  Return value:
  --    TRUE if the given cursor is open,
  --    FALSE if it is not.
  --
  procedure close_cursor(c in out integer);
  pragma restrict_references(close_cursor,RNDS,WNDS);
  --  Close the given cursor.
  --  Input parameters:
  --    c
  --      Cursor id number of the cursor to close.
  --  Output parameters:
  --    c
  --      Will be nulled.
  --
  procedure parse(c in integer, statement in varchar2, 
                  language_flag in integer);
  --  Parse the given statement in the given cursor. NOTE THAT PARSING AND
  --  EXECUTING DDL STATEMENTS CAN CAUSE HANGS! 
  --  Currently, the deferred parsing feature of the Oracle  Call Interface
  --  is not used. As a result, statements are parsed immediately. In addition,
  --  DDL statements are executed immediately when parsed. However, 
  --  the behavior may
  --  change in the future so that the actual parsing (and execution of DDL
  --  statement) do not occur until the cursor is executed with "execute".
  --  DO NOT RELY ON THE CURRENT TIMING OF THE ACTUAL PARSING!
  --  Input parameters:
  --    c
  --      Cursor id number of the cursor in where to parse the statement.
  --    statement
  --      Statement to parse.
  --    language_flag
  --      Specifies behavior for statement. Valid values are v6, v7 and NATIVE.
  --      v6 and v7 specifies behavior according to Version 6 and ORACLE7,
  --      respectively. NATIVE specifies behavior according to the version
  --      of the database the program is connected to.
  --    
  procedure parse(c in integer, statement in varchar2a,
                  lb in integer, ub in integer,
                  lfflg in boolean, language_flag in integer);
  --  Description: (copied from parse for varchar2s)
  --  Parse the given statement in the given cursor.  The statement is not in
  --  one piece but resides in little pieces in the PL/SQL table "statement".
  --  Conceptually what happens is that the SQL string is put together as
  --  follows:
  --  String := statement(lb) || statement(lb + 1) || ... || statement(ub);
  --  Then a regular parse follows.
  --  If "lfflg" is TRUE then a newline is inserted after each piece.
  --  For further information and for documentation on the rest of the
  --  arguments see the regular parse procedure below.
  procedure parse(c in integer, statement in varchar2s,
                  lb in integer, ub in integer,
                  lfflg in boolean, language_flag in integer);
  --  Parse the given statement in the given cursor.  The statement is not in
  --  one piece but resides in little pieces in the PL/SQL table "statement".
  --  Conceptually what happens is that the SQL string is put together as
  --  follows:
  --  String := statement(lb) || statement(lb + 1) || ... || statement(ub);
  --  Then a regular parse follows.
  --  If "lfflg" is TRUE then a newline is inserted after each piece.
  --  For further information and for documentation on the rest of the
  --  arguments see the regular parse procedure below.
  --
  procedure bind_variable(c in integer, name in varchar2, value in number);
  pragma restrict_references(bind_variable,WNDS);
  procedure bind_variable(c in integer, name in varchar2, 
                          value in varchar2 character set any_cs);
  pragma restrict_references(bind_variable,WNDS);
  procedure bind_variable(c in integer, name in varchar2,
                          value in varchar2 character set any_cs,
                          out_value_size in integer);
  pragma restrict_references(bind_variable,WNDS);
  procedure bind_variable(c in integer, name in varchar2, value in date);
  pragma restrict_references(bind_variable,WNDS);
  procedure bind_variable(c in integer, name in varchar2, value in blob);
  pragma restrict_references(bind_variable,WNDS);
  procedure bind_variable(c in integer, name in varchar2,
                          value in clob character set any_cs);
  pragma restrict_references(bind_variable,WNDS);
  procedure bind_variable(c in integer, name in varchar2, value in bfile);
  pragma restrict_references(bind_variable,WNDS);

  procedure bind_variable_char(c in integer, name in varchar2,
                               value in char character set any_cs);
  pragma restrict_references(bind_variable_char,WNDS);
  procedure bind_variable_char(c in integer, name in varchar2,
                               value in char character set any_cs,
                               out_value_size in integer);
  pragma restrict_references(bind_variable_char,WNDS);
  procedure bind_variable_raw(c in integer, name in varchar2,
                              value in raw);
  pragma restrict_references(bind_variable_raw,WNDS);
  procedure bind_variable_raw(c in integer, name in varchar2,
                              value in raw, out_value_size in integer);
  pragma restrict_references(bind_variable_raw,WNDS);
  procedure bind_variable_rowid(c in integer, name in varchar2,
                              value in rowid);
  pragma restrict_references(bind_variable_rowid,WNDS);
  procedure bind_array(c in integer, name in varchar2,
                       n_tab in Number_Table);
  pragma restrict_references(bind_array,WNDS);
  procedure bind_array(c in integer, name in varchar2,
                       c_tab in Varchar2_Table);
  pragma restrict_references(bind_array,WNDS);
  procedure bind_array(c in integer, name in varchar2,
                       d_tab in Date_Table);
  pragma restrict_references(bind_array,WNDS);
  procedure bind_array(c in integer, name in varchar2,
                       bl_tab in Blob_Table);
  pragma restrict_references(bind_array,WNDS);
  procedure bind_array(c in integer, name in varchar2,
                       cl_tab in Clob_Table);
  pragma restrict_references(bind_array,WNDS);
  procedure bind_array(c in integer, name in varchar2,
                       bf_tab in Bfile_Table);
  pragma restrict_references(bind_array,WNDS);
  
  procedure bind_array(c in integer, name in varchar2,
                       n_tab in Number_Table,
                       index1 in integer, index2 in integer);
  pragma restrict_references(bind_array,WNDS);
  procedure bind_array(c in integer, name in varchar2,
                       c_tab in Varchar2_Table,
                       index1 in integer, index2 in integer);
  pragma restrict_references(bind_array,WNDS);
  procedure bind_array(c in integer, name in varchar2,
                       d_tab in Date_Table,
                       index1 in integer, index2 in integer);
  pragma restrict_references(bind_array,WNDS);
  procedure bind_array(c in integer, name in varchar2,
                       bl_tab in Blob_Table,
                       index1 in integer, index2 in integer);
  pragma restrict_references(bind_array,WNDS);
  procedure bind_array(c in integer, name in varchar2,
                       cl_tab in Clob_Table,
                       index1 in integer, index2 in integer);
  pragma restrict_references(bind_array,WNDS);
  procedure bind_array(c in integer, name in varchar2,
                       bf_tab in Bfile_Table,
                       index1 in integer, index2 in integer);
  pragma restrict_references(bind_array,WNDS);
  --  Bind the given value to the variable identified by its name
  --  in the parsed statement in the given cursor.
  --  If the variable is an in or in/out variable, the given bind value
  --  should be a valid one.  If the variable is an out variable, the
  --  given bind value is ignored.
  --  Input parameters:
  --    c
  --      Cursor id number of the cursor to bind.
  --    name
  --      Name of the variable in the statement.
  --    value
  --      Value to bind to the variable in the cursor.
  --      If the variable is an out or in/out variable, its type is the same
  --      as the type of the value being passed in for this parameter.
  --    out_value_size
  --      Maximum expected out value size in bytes for the varchar2
  --      out or in/out variable.  If it is not given for the varchar2
  --      out or in/out variable, the size is the length of the current
  --      "value".
  --    n_tab, c_tab, d_tab, bl_tab, cl_tab, bf_tab
  --      For array execute operations, where the user wishes to execute
  --      the SQL statement multiple times without returning control to
  --      the caller, a list of values can be bound to this variable.  This
  --      functionality is like the array execute feature of OCI, where a
  --      list of values in a PLSQL index table can be inserted into a SQL
  --      table with a single (parameterized) call to execute.
  --    index1, index2
  --      For array execute, instead of using the entire index table, the
  --      user may chose to limit it to a range of values.
  --

  procedure define_column(c in integer, position in integer, column in number);
  pragma restrict_references(define_column,RNDS,WNDS);
  procedure define_column(c in integer, position in integer, 
                          column in varchar2 character set any_cs,
                          column_size in integer);
  pragma restrict_references(define_column,RNDS,WNDS);
  procedure define_column(c in integer, position in integer, column in date);
  pragma restrict_references(define_column,RNDS,WNDS);
  procedure define_column(c in integer, position in integer, column in blob);
  pragma restrict_references(define_column,RNDS,WNDS);
  procedure define_column(c in integer, position in integer,
                          column in clob character set any_cs);
  pragma restrict_references(define_column,RNDS,WNDS);
  procedure define_column(c in integer, position in integer, column in bfile);
  pragma restrict_references(define_column,RNDS,WNDS);

  procedure define_column_char(c in integer, position in integer,
                               column in char character set any_cs,
                               column_size in integer);
  pragma restrict_references(define_column_char,RNDS,WNDS);
  procedure define_column_raw(c in integer, position in integer, 
                              column in raw,
                              column_size in integer);
  pragma restrict_references(define_column_raw,RNDS,WNDS);
  procedure define_column_rowid(c in integer, position in integer,
                                column in rowid);
  pragma restrict_references(define_column_rowid,RNDS,WNDS);
  procedure define_array(c in integer, position in integer,
                         n_tab in Number_Table,
                         cnt in integer, lower_bound in integer);
  pragma restrict_references(define_array,RNDS,WNDS);
  procedure define_array(c in integer, position in integer,
                         c_tab in Varchar2_Table,
                         cnt in integer, lower_bound in integer);
  pragma restrict_references(define_array,RNDS,WNDS);
  procedure define_array(c in integer, position in integer,
                         d_tab in Date_Table,
                         cnt in integer, lower_bound in integer);
  pragma restrict_references(define_array,RNDS,WNDS);
  procedure define_array(c in integer, position in integer,
                         bl_tab in Blob_Table,
                         cnt in integer, lower_bound in integer);
  pragma restrict_references(define_array,RNDS,WNDS);
  procedure define_array(c in integer, position in integer,
                         cl_tab in Clob_Table,
                         cnt in integer, lower_bound in integer);
  pragma restrict_references(define_array,RNDS,WNDS);
  procedure define_array(c in integer, position in integer,
                         bf_tab in Bfile_Table,
                         cnt in integer, lower_bound in integer);
  pragma restrict_references(define_array,RNDS,WNDS);
  
  --  Define a column to be selected from the given cursor; so this
  --  procedure is applicable only to SELECT cursors.
  --  The column being defined is identified by its relative position as
  --  it appears on the select list in the statement in the given cursor.
  --  The type of the column to be defined is the type of the value
  --  being passed in for parameter "column".
  --  Input parameters:
  --    c
  --      Cursor id number of the cursor to define the row to be selected.
  --    position
  --      Position of the column in the row being defined.
  --    column
  --      Type of the value being passed in for this parameter is
  --      the type of the column to be defined.
  --    column_size
  --      Maximum expected size of the value in bytes for the
  --      varchar2 column.
  --
  function execute(c in integer) return integer;
  --  Execute the given cursor and return the number of rows processed
  --  (valid and meaningful only for INSERT, DELETE or UPDATE statements;
  --  for other types of statements, the return value is undefined and
  --  should be ignored).
  --  Input parameters:
  --    c
  --      Cursor id number of the cursor to execute.
  --  Return value:
  --    Number of rows processed if the statement in the cursor is
  --    either an INSERT, DELETE or UPDATE statement or undefined otherwise.
  --
  function fetch_rows(c in integer) return integer;
  pragma restrict_references(fetch_rows,WNDS);
  --  Fetch rows from the given cursor. The function tries to fetch a
  --  row. As long as "fetch_rows" is able to fetch a
  --  row, it can be called repeatedly to fetch additional rows. If no
  --  row was actually fetched, "fetch_rows"
  --  cannot be called to fetch additional rows.
  --  Input parameters:
  --    c
  --      Cursor id number of the cursor to fetch.
  --  Return value:
  --    The number of rows actually fetched.
  --
  function execute_and_fetch(c in integer, exact in boolean default false) 
  return integer;
  pragma restrict_references(execute_and_fetch,WNDS);
  --  Execute the given cursor and fetch rows. Gives the same functionality
  --  as a call to "execute" 
  --  followed by a call to "fetch_rows". However, this function can 
  --  potentially cut down on the number of message round-trips compared to
  --  calling "execute" and "fetch_rows" separately.
  --  Input parameters:
  --    c
  --      Cursor id number of the cursor to execute and fetch.
  --    exact 
  --      Raise an exception if the number of rows matching the query 
  --      differs from one.
  --  Return value:
  --    The number of rows actually fetched.
  --    
  procedure column_value(c in integer, position in integer, value out number);
  pragma restrict_references(column_value,RNDS,WNDS);
  procedure column_value(c in integer, position in integer, 
                         value out varchar2 character set any_cs);
  pragma restrict_references(column_value,RNDS,WNDS);
  procedure column_value(c in integer, position in integer, value out date);
  pragma restrict_references(column_value,RNDS,WNDS);
  procedure column_value(c in integer, position in integer, value out blob);
  pragma restrict_references(column_value,RNDS,WNDS);
  procedure column_value(c in integer, position in integer,
                         value out clob character set any_cs);
  pragma restrict_references(column_value,RNDS,WNDS);
  procedure column_value(c in integer, position in integer, value out bfile);
  pragma restrict_references(column_value,RNDS,WNDS);

  procedure column_value_char(c in integer, position in integer,
                              value out char character set any_cs);
  pragma restrict_references(column_value_char,RNDS,WNDS);
  procedure column_value_raw(c in integer, position in integer, value out raw);
  pragma restrict_references(column_value_raw,RNDS,WNDS);
  procedure column_value_rowid(c in integer, position in integer, 
                               value out rowid);
  pragma restrict_references(column_value_rowid,RNDS,WNDS);
  procedure column_value(c in integer, position in integer, value out number,
                         column_error out number, actual_length out integer);
  pragma restrict_references(column_value,RNDS,WNDS);
  procedure column_value(c in integer, position in integer, 
                         value out varchar2 character set any_cs,
                         column_error out number, actual_length out integer);
  pragma restrict_references(column_value,RNDS,WNDS);
  procedure column_value(c in integer, position in integer, value out date,
                         column_error out number, actual_length out integer);
  pragma restrict_references(column_value,RNDS,WNDS);
  procedure column_value_char(c in integer, position in integer,
                              value out char character set any_cs,
                              column_error out number, 
                              actual_length out integer);
  pragma restrict_references(column_value_char,RNDS,WNDS);
  procedure column_value_raw(c in integer, position in integer, value out raw,
                             column_error out number, 
                             actual_length out integer);
  pragma restrict_references(column_value_raw,RNDS,WNDS);
  procedure column_value_rowid(c in integer, position in integer, 
                             value out rowid, column_error out number,
                             actual_length out integer);
  pragma restrict_references(column_value_rowid,RNDS,WNDS);

  procedure column_value(c in integer, position in integer,
                         n_tab in Number_table);
  pragma restrict_references(column_value,RNDS,WNDS);
  procedure column_value(c in integer, position in integer,
                         c_tab in Varchar2_table);
  pragma restrict_references(column_value,RNDS,WNDS);
  procedure column_value(c in integer, position in integer,
                         d_tab in Date_table);
  pragma restrict_references(column_value,RNDS,WNDS);
  procedure column_value(c in integer, position in integer,
                         bl_tab in Blob_table);
  pragma restrict_references(column_value,RNDS,WNDS);
  procedure column_value(c in integer, position in integer,
                         cl_tab in Clob_table);
  pragma restrict_references(column_value,RNDS,WNDS);
  procedure column_value(c in integer, position in integer,
                         bf_tab in Bfile_table);
  pragma restrict_references(column_value,RNDS,WNDS);
  --  Get a value of the column identified by the given position
  --  and the given cursor. This procedure is used to access the data 
  --  retrieved by "fetch_rows".
  --  Input parameters:
  --    c
  --      Cursor id number of the cursor from which to get the value.
  --    position
  --      Position of the column of which to get the value.
  --  Output parameters:
  --    value
  --      Value of the column.  
  --    column_error
  --      Any column error code associated with "value".
  --    actual_length
  --      The actual length of "value" in the table before any truncation
  --      during the fetch.
  --  Exceptions:
  --    inconsistent_type (ORA-06562)
  --      Raised if the type of the given out parameter "value" is
  --      different from the actual type of the value.  This type was
  --      the given type when the column was defined by calling procedure
  --      "define_column".
  --
  procedure variable_value(c in integer, name in varchar2,
                           value out number);
  pragma restrict_references(variable_value,RNDS,WNDS);
  procedure variable_value(c in integer, name in varchar2,
                           value out varchar2 character set any_cs);
  pragma restrict_references(variable_value,RNDS,WNDS);
  procedure variable_value(c in integer, name in varchar2,
                           value out date);
  pragma restrict_references(variable_value,RNDS,WNDS);
  procedure variable_value(c in integer, name in varchar2, value out blob);
  pragma restrict_references(variable_value,RNDS,WNDS);
  procedure variable_value(c in integer, name in varchar2,
                           value out clob character set any_cs);
  pragma restrict_references(variable_value,RNDS,WNDS);
  procedure variable_value(c in integer, name in varchar2, value out bfile);
  pragma restrict_references(variable_value,RNDS,WNDS);

  procedure variable_value(c in integer, name in varchar2, 
                           value in Number_table);
  pragma restrict_references(variable_value,RNDS,WNDS);
  procedure variable_value(c in integer, name in varchar2, 
                           value in Varchar2_table);
  pragma restrict_references(variable_value,RNDS,WNDS);
  procedure variable_value(c in integer, name in varchar2, 
                           value in Date_table);
  pragma restrict_references(variable_value,RNDS,WNDS);
  procedure variable_value(c in integer, name in varchar2, 
                           value in Blob_table);
  pragma restrict_references(variable_value,RNDS,WNDS);
  procedure variable_value(c in integer, name in varchar2, 
                           value in Clob_table);
  pragma restrict_references(variable_value,RNDS,WNDS);
  procedure variable_value(c in integer, name in varchar2, 
                           value in Bfile_table);
  pragma restrict_references(variable_value,RNDS,WNDS);
  procedure variable_value_char(c in integer, name in varchar2,
                                value out char character set any_cs);
  pragma restrict_references(variable_value_char,RNDS,WNDS);
  procedure variable_value_raw(c in integer, name in varchar2,
                               value out raw);
  pragma restrict_references(variable_value_raw,RNDS,WNDS);
  procedure variable_value_rowid(c in integer, name in varchar2,
                                 value out rowid);
  pragma restrict_references(variable_value_rowid,RNDS,WNDS);
  
  --  Get a value or values of the variable identified by the name
  --  and the given cursor.  
  --  Input parameters:
  --    c
  --      Cursor id number of the cursor from which to get the value.
  --    name
  --      Name of the variable of which to get the value.
  --  Output parameters:
  --    value
  --      Value of the variable.  
  --  Exceptions:
  --    inconsistent_type (ORA-06562)
  --      Raised if the type of the given out parameter "value" is
  --      different from the actual type of the value.  This type was
  --      the given type when the variable was bound by calling procedure
  --      "bind_variable".
  --
  function last_error_position return integer;
  pragma restrict_references(last_error_position,RNDS,WNDS);
  function last_sql_function_code return integer;
  pragma restrict_references(last_sql_function_code,RNDS,WNDS);
  function last_row_count return integer;
  pragma restrict_references(last_row_count,RNDS,WNDS);
  function last_row_id return rowid;
  pragma restrict_references(last_row_id,RNDS,WNDS);
  --  Get various information for the last-operated cursor in the session.
  --  To ensure that the information relates to a particular cursor,
  --  the functions should be called after an operation on that cursor and
  --  before any other operation on any other cursor.
  --  Return value:
  --    last_error_position
  --      Relative position in the statement when the error occurs.
  --    last_sql_function_code
  --      SQL function code of the statement. See list in OCI manual.
  --    last_row_count
  --      Cumulative count of rows fetched.
  --    last_row_id
  --      Rowid of the last processed row.
  --
 ------------
  --  EXAMPLES
  --
  --  create or replace procedure copy(source in varchar2,
  --                                   destination in varchar2) is
  --    --  This procedure copies rows from a given source table to
  --        a given destination table assuming that both source and destination
  --    --  tables have the following columns:
  --    --    - ID of type NUMBER,
  --    --    - NAME of type VARCHAR2(30),
  --    --    - BIRTHDATE of type DATE.
  --    id number;
  --    name varchar2(30);
  --    birthdate date;
  --    source_cursor integer;
  --    destination_cursor integer;
  --    rows_processed integer;
  --  begin
  --    -- prepare a cursor to select from the source table
  --    source_cursor := dbms_sql.open_cursor;
  --    dbms_sql.parse(source_cursor,
  --                   'select id, name, birthdate from ' || source);
  --    dbms_sql.define_column(source_cursor, 1, id);
  --    dbms_sql.define_column(source_cursor, 2, name, 30);
  --    dbms_sql.define_column(source_cursor, 3, birthdate);
  --    rows_processed := dbms_sql.execute(source_cursor);
  --
  --    -- prepare a cursor to insert into the destination table
  --    destination_cursor := dbms_sql.open_cursor;
  --    dbms_sql.parse(destination_cursor,
  --                   'insert into ' || destination ||
  --                   ' values (:id, :name, :birthdate)');
  --
  --    -- fetch a row from the source table and
  --    -- insert it into the destination table
  --    loop
  --      if dbms_sql.fetch_rows(source_cursor)>0 then
  --        -- get column values of the row
  --        dbms_sql.column_value(source_cursor, 1, id);
  --        dbms_sql.column_value(source_cursor, 2, name);
  --        dbms_sql.column_value(source_cursor, 3, birthdate);
  --        -- bind the row into the cursor which insert
  --        -- into the destination table
  --        dbms_sql.bind_variable(destination_cursor, 'id', id);
  --        dbms_sql.bind_variable(destination_cursor, 'name', name);
  --        dbms_sql.bind_variable(destination_cursor, 'birthdate', birthdate);
  --        rows_processed := dbms_sql.execute(destination_cursor);
  --      else
  --        -- no more row to copy
  --        exit;
  --      end if;
  --    end loop;
  --
  --    -- commit and close all cursors
  --    commit;
  --    dbms_sql.close_cursor(source_cursor);
  --    dbms_sql.close_cursor(destination_cursor);
  --  exception
  --    when others then
  --      if dbms_sql.is_open(source_cursor) then
  --        dbms_sql.close_cursor(source_cursor);
  --      end if;
  --      if dbms_sql.is_open(destination_cursor) then
  --        dbms_sql.close_cursor(destination_cursor);
  --      end if;
  --      raise;
  --  end;
  --
  procedure column_value_long(c in integer, position in integer, 
                              length in integer, offset in integer,
                              value out varchar2, value_length out integer);
  pragma restrict_references(column_value_long,RNDS,WNDS);
  --  Get (part of) the value of a long column.
  --  Input parameters:
  --    c
  --      Cursor id number of the cursor from which to get the value.
  --    position
  --      Position of the column of which to get the value.
  --    length
  --      Number of bytes of the long value to fetch.
  --    offset
  --      Offset into the long field for start of fetch. 
  --  Output parameters:
  --    value
  --      Value of the column as a varchar2.
  --    value_length
  --      The number of bytes actually returned in value.
  --
  procedure define_column_long(c in integer, position in integer);
  pragma restrict_references(define_column_long,RNDS,WNDS);
  --  Define a column to be selected from the given cursor; so this
  --  procedure is applicable only to SELECT cursors.
  --  The column being defined is identified by its relative position as
  --  it appears on the select list in the statement in the given cursor.
  --  The type of the column to be defined is the type LONG.
  --  Input parameters:
  --    c
  --      Cursor id number of the cursor to define the row to be selected.
  --    position
  --      Position of the column in the row being defined.
  --

  procedure describe_columns(c in integer, col_cnt out integer,
                             desc_t out desc_tab);
  pragma restrict_references(describe_columns,WNDS);
  -- Get the description for the specified column.
  -- Input parameters:
  --    c
  --      Cursor id number of the cursor from which to describe the column.
  -- Output Parameters:
  --     col_cnt
  --      The number of columns in the select list of the query.
  --    desc_tab
  --      The describe table to fill in with the description of each of the
  --      columns of the query.  This table is indexed from one to the number
  --      of elements in the select list of the query.
  --
  -- Urowid support
  procedure bind_variable(c in integer, name in varchar2,
                          value in urowid);

  pragma restrict_references(bind_variable,WNDS);
  
  procedure define_column(c in integer, position in integer,
                          column in urowid);
  pragma restrict_references(define_column,RNDS,WNDS);
  
  procedure column_value(c in integer, position in integer, 
                         value out urowid);
  pragma restrict_references(column_value,RNDS,WNDS);
  
  procedure variable_value(c in integer, name in varchar2,
                           value out urowid);
  pragma restrict_references(variable_value,RNDS,WNDS);
  
  procedure bind_array(c in integer, name in varchar2,
                       ur_tab in Urowid_Table);
  pragma restrict_references(bind_array,WNDS);
  
  procedure bind_array(c in integer, name in varchar2,
                       ur_tab in Urowid_Table,
                       index1 in integer, index2 in integer);
  pragma restrict_references(bind_array,WNDS);
  
  procedure define_array(c in integer, position in integer,
                         ur_tab in Urowid_Table,
                         cnt in integer, lower_bound in integer);
  pragma restrict_references(define_array,RNDS,WNDS);

  procedure column_value(c in integer, position in integer,
                         ur_tab in Urowid_table);
  pragma restrict_references(column_value,RNDS,WNDS);

  procedure variable_value(c in integer, name in varchar2, 
                           value in Urowid_Table);
  pragma restrict_references(variable_value,RNDS,WNDS);

  -- Datetime support
  -- time 
  procedure bind_variable(c in integer, name in varchar2,
                          value in time_unconstrained);

  pragma restrict_references(bind_variable,WNDS);
  
  procedure define_column(c in integer, position in integer,
                          column in time_unconstrained);

  pragma restrict_references(define_column,RNDS,WNDS);
  
  procedure column_value(c in integer, position in integer, 
                         value out time_unconstrained);

  pragma restrict_references(column_value,RNDS,WNDS);
  
  procedure variable_value(c in integer, name in varchar2,
                           value out time_unconstrained);

  pragma restrict_references(variable_value,RNDS,WNDS);
  
  procedure bind_array(c in integer, name in varchar2,
                       tm_tab in Time_Table);
  pragma restrict_references(bind_array,WNDS);
  
  procedure bind_array(c in integer, name in varchar2,
                       tm_tab in Time_Table,
                       index1 in integer, index2 in integer);
  pragma restrict_references(bind_array,WNDS);
  
  procedure define_array(c in integer, position in integer,
                         tm_tab in Time_Table,
                         cnt in integer, lower_bound in integer);
  pragma restrict_references(define_array,RNDS,WNDS);

  procedure column_value(c in integer, position in integer,
                         tm_tab in Time_table);
  pragma restrict_references(column_value,RNDS,WNDS);

  procedure variable_value(c in integer, name in varchar2, 
                           value in Time_Table);
  pragma restrict_references(variable_value,RNDS,WNDS);
  
  -- timestamp_unconstrained
  procedure bind_variable(c in integer, name in varchar2,
                          value in timestamp_unconstrained);

  pragma restrict_references(bind_variable,WNDS);
  
  procedure define_column(c in integer, position in integer,
                          column in timestamp_unconstrained);

  pragma restrict_references(define_column,RNDS,WNDS);
  
  procedure column_value(c in integer, position in integer, 
                         value out timestamp_unconstrained);

  pragma restrict_references(column_value,RNDS,WNDS);
  
  procedure variable_value(c in integer, name in varchar2,
                           value out timestamp_unconstrained);

  pragma restrict_references(variable_value,RNDS,WNDS);
  
  procedure bind_array(c in integer, name in varchar2,
                       tms_tab in Timestamp_Table);
  pragma restrict_references(bind_array,WNDS);
  
  procedure bind_array(c in integer, name in varchar2,
                       tms_tab in Timestamp_Table,
                       index1 in integer, index2 in integer);
  pragma restrict_references(bind_array,WNDS);
  
  procedure define_array(c in integer, position in integer,
                         tms_tab in Timestamp_Table,
                         cnt in integer, lower_bound in integer);
  pragma restrict_references(define_array,RNDS,WNDS);

  procedure column_value(c in integer, position in integer,
                         tms_tab in Timestamp_table);
  pragma restrict_references(column_value,RNDS,WNDS);

  procedure variable_value(c in integer, name in varchar2, 
                           value in Timestamp_Table);
  pragma restrict_references(variable_value,RNDS,WNDS);
  
  -- time with timezone
  procedure bind_variable(c in integer, name in varchar2,
                          value in TIME_TZ_UNCONSTRAINED);

  pragma restrict_references(bind_variable,WNDS);
  
  procedure define_column(c in integer, position in integer,
                          column in TIME_TZ_UNCONSTRAINED);

  pragma restrict_references(define_column,RNDS,WNDS);
  
  procedure column_value(c in integer, position in integer, 
                         value out TIME_TZ_UNCONSTRAINED);

  pragma restrict_references(column_value,RNDS,WNDS);
  
  procedure variable_value(c in integer, name in varchar2,
                           value out TIME_TZ_UNCONSTRAINED );

  pragma restrict_references(variable_value,RNDS,WNDS);
  
  procedure bind_array(c in integer, name in varchar2,
                       ttz_tab in Time_With_Time_Zone_Table);
  pragma restrict_references(bind_array,WNDS);
  
  procedure bind_array(c in integer, name in varchar2,
                       ttz_tab in Time_With_Time_Zone_Table,
                       index1 in integer, index2 in integer);
  pragma restrict_references(bind_array,WNDS);
  
  procedure define_array(c in integer, position in integer,
                         ttz_tab in Time_With_Time_Zone_Table,
                         cnt in integer, lower_bound in integer);
  pragma restrict_references(define_array,RNDS,WNDS);

  procedure column_value(c in integer, position in integer,
                         ttz_tab in time_with_time_zone_table);
  pragma restrict_references(column_value,RNDS,WNDS);

  procedure variable_value(c in integer, name in varchar2, 
                           value in Time_With_Time_Zone_Table);

  pragma restrict_references(variable_value,RNDS,WNDS);
  
  -- timestamp with timezone
  procedure bind_variable(c in integer, name in varchar2,
                          value in TIMESTAMP_TZ_UNCONSTRAINED);

  pragma restrict_references(bind_variable,WNDS);
  
  procedure define_column(c in integer, position in integer,
                          column in TIMESTAMP_TZ_UNCONSTRAINED);

  pragma restrict_references(define_column,RNDS,WNDS);
  
  procedure column_value(c in integer, position in integer, 
                         value out TIMESTAMP_TZ_UNCONSTRAINED);

  pragma restrict_references(column_value,RNDS,WNDS);
  
  procedure variable_value(c in integer, name in varchar2,
                           value out TIMESTAMP_TZ_UNCONSTRAINED);

  pragma restrict_references(variable_value,RNDS,WNDS);
  
  procedure bind_array(c in integer, name in varchar2,
                       tstz_tab in Timestamp_With_Time_Zone_Table);
  pragma restrict_references(bind_array,WNDS);
  
  procedure bind_array(c in integer, name in varchar2,
                       tstz_tab in Timestamp_With_Time_Zone_Table,
                       index1 in integer, index2 in integer);
  pragma restrict_references(bind_array,WNDS);
  
  procedure define_array(c in integer, position in integer,
                         tstz_tab in Timestamp_With_Time_Zone_Table,
                         cnt in integer, lower_bound in integer);
  pragma restrict_references(define_array,RNDS,WNDS);

  procedure column_value(c in integer, position in integer,
                         tstz_tab in timestamp_with_time_zone_table);
  pragma restrict_references(column_value,RNDS,WNDS);

  procedure variable_value(c in integer, name in varchar2, 
                           value in Timestamp_With_Time_Zone_Table);
  pragma restrict_references(variable_value,RNDS,WNDS);
  
    -- timestamp with local timezone
  procedure bind_variable(c in integer, name in varchar2,
                          value in TIMESTAMP_LTZ_UNCONSTRAINED);

  pragma restrict_references(bind_variable,WNDS);
  
  procedure define_column(c in integer, position in integer,
                          column in TIMESTAMP_LTZ_UNCONSTRAINED);

  pragma restrict_references(define_column,RNDS,WNDS);
  
  procedure column_value(c in integer, position in integer, 
                         value out TIMESTAMP_LTZ_UNCONSTRAINED);

  pragma restrict_references(column_value,RNDS,WNDS);
  
  procedure variable_value(c in integer, name in varchar2,
                           value out TIMESTAMP_LTZ_UNCONSTRAINED);

  pragma restrict_references(variable_value,RNDS,WNDS);
  
  procedure bind_array(c in integer, name in varchar2,
                       tstz_tab in timestamp_with_ltz_Table);
  pragma restrict_references(bind_array,WNDS);
  
  procedure bind_array(c in integer, name in varchar2,
                       tstz_tab in timestamp_with_ltz_Table,
                       index1 in integer, index2 in integer);
  pragma restrict_references(bind_array,WNDS);
  
  procedure define_array(c in integer, position in integer,
                         tstz_tab in timestamp_with_ltz_Table,
                         cnt in integer, lower_bound in integer);
  pragma restrict_references(define_array,RNDS,WNDS);

  procedure column_value(c in integer, position in integer,
                         tstz_tab in timestamp_with_ltz_Table);
  pragma restrict_references(column_value,RNDS,WNDS);

  procedure variable_value(c in integer, name in varchar2, 
                           value in timestamp_with_ltz_Table);
  pragma restrict_references(variable_value,RNDS,WNDS);

  
  -- Interval support
  -- yminterval_unconstrained
  procedure bind_variable(c in integer, name in varchar2,
                          value in YMINTERVAL_UNCONSTRAINED);

  pragma restrict_references(bind_variable,WNDS);
  
  procedure define_column(c in integer, position in integer,
                          column in YMINTERVAL_UNCONSTRAINED);

  pragma restrict_references(define_column,RNDS,WNDS);
  
  procedure column_value(c in integer, position in integer, 
                         value out YMINTERVAL_UNCONSTRAINED);

  pragma restrict_references(column_value,RNDS,WNDS);
  
  procedure variable_value(c in integer, name in varchar2,
                           value out YMINTERVAL_UNCONSTRAINED);

  pragma restrict_references(variable_value,RNDS,WNDS);
  
  procedure bind_array(c in integer, name in varchar2,
                       iym_tab in Interval_Year_To_Month_Table);
  pragma restrict_references(bind_array,WNDS);
  
  procedure bind_array(c in integer, name in varchar2,
                       iym_tab in Interval_Year_To_Month_Table,
                       index1 in integer, index2 in integer);
  pragma restrict_references(bind_array,WNDS);
  
  procedure define_array(c in integer, position in integer,
                         iym_tab in Interval_Year_To_Month_Table,
                         cnt in integer, lower_bound in integer);
  pragma restrict_references(define_array,RNDS,WNDS);

  procedure column_value(c in integer, position in integer,
                         iym_tab in interval_year_to_month_table);
  pragma restrict_references(column_value,RNDS,WNDS);

  procedure variable_value(c in integer, name in varchar2, 
                           value in Interval_Year_To_Month_Table);
  pragma restrict_references(variable_value,RNDS,WNDS);
  
  -- DSINTERVAL_UNCONSTRAINED
  procedure bind_variable(c in integer, name in varchar2,
                          value in DSINTERVAL_UNCONSTRAINED);

  pragma restrict_references(bind_variable,WNDS);
  
  procedure define_column(c in integer, position in integer,
                          column in DSINTERVAL_UNCONSTRAINED);

  pragma restrict_references(define_column,RNDS,WNDS);
  
  procedure column_value(c in integer, position in integer, 
                         value out DSINTERVAL_UNCONSTRAINED);

  pragma restrict_references(column_value,RNDS,WNDS);
  
  procedure variable_value(c in integer, name in varchar2,
                           value out DSINTERVAL_UNCONSTRAINED);

  pragma restrict_references(variable_value,RNDS,WNDS);
  
  procedure bind_array(c in integer, name in varchar2,
                       ids_tab in Interval_Day_To_Second_Table);
  pragma restrict_references(bind_array,WNDS);
  
  procedure bind_array(c in integer, name in varchar2,
                       ids_tab in Interval_Day_To_Second_Table,
                       index1 in integer, index2 in integer);
  pragma restrict_references(bind_array,WNDS);
  
  procedure define_array(c in integer, position in integer,
                         ids_tab in Interval_Day_To_Second_Table,
                         cnt in integer, lower_bound in integer);
  pragma restrict_references(define_array,RNDS,WNDS);

  procedure column_value(c in integer, position in integer,
                         ids_tab in interval_day_to_second_table);
  pragma restrict_references(column_value,RNDS,WNDS);

  procedure variable_value(c in integer, name in varchar2, 
                           value in Interval_Day_To_Second_Table);
  pragma restrict_references(variable_value,RNDS,WNDS);

  procedure describe_columns2(c in integer, col_cnt out integer,
                              desc_t out desc_tab2);
  pragma restrict_references(describe_columns2,WNDS);
  -- Get the description for the specified column. 
  -- Bug 702903: This is a replacement for - or an alternative to - the 
  -- describe_columns API.
  -- Input parameters:
  --    c
  --      Cursor id number of the cursor from which to describe the column.
  -- Output Parameters:
  --     col_cnt
  --      The number of columns in the select list of the query.
  --    desc_tab2
  --      The describe table to fill in with the description of each of the
  --      columns of the query.  This table is indexed from one to the number
  --      of elements in the select list of the query.

  -- binary_float
  procedure bind_variable(c in integer, name in varchar2,
                          value in binary_float);
  pragma restrict_references(bind_variable,WNDS);
 
  procedure define_column(c in integer, position in integer,
                          column in binary_float);
  pragma restrict_references(define_column,RNDS,WNDS);
  
  procedure column_value(c in integer, position in integer, 
                         value out binary_float);
  pragma restrict_references(column_value,RNDS,WNDS);

  procedure variable_value(c in integer, name in varchar2,
                           value out binary_float);
  pragma restrict_references(variable_value,RNDS,WNDS);

  procedure bind_array(c in integer, name in varchar2,
                       bflt_tab in Binary_Float_Table);
  pragma restrict_references(bind_array,WNDS);
  
  procedure bind_array(c in integer, name in varchar2,
                       bflt_tab in Binary_Float_Table,
                       index1 in integer, index2 in integer);
  pragma restrict_references(bind_array,WNDS);

  procedure define_array(c in integer, position in integer,
                         bflt_tab in Binary_Float_Table,
                         cnt in integer, lower_bound in integer);
  pragma restrict_references(define_array,RNDS,WNDS);
 
  procedure column_value(c in integer, position in integer,
                         bflt_tab in Binary_Float_Table);
  pragma restrict_references(column_value,RNDS,WNDS);

  procedure variable_value(c in integer, name in varchar2, 
                           value in Binary_Float_Table);
  pragma restrict_references(variable_value,RNDS,WNDS);

  -- binary_double
  procedure bind_variable(c in integer, name in varchar2,
                          value in binary_double);
  pragma restrict_references(bind_variable,WNDS);
 
  procedure define_column(c in integer, position in integer,
                          column in binary_double);
  pragma restrict_references(define_column,RNDS,WNDS);
  
  procedure column_value(c in integer, position in integer, 
                         value out binary_double);
  pragma restrict_references(column_value,RNDS,WNDS);

  procedure variable_value(c in integer, name in varchar2,
                           value out binary_double);
  pragma restrict_references(variable_value,RNDS,WNDS);

  procedure bind_array(c in integer, name in varchar2,
                       bdbl_tab in Binary_Double_Table);
  pragma restrict_references(bind_array,WNDS);
  
  procedure bind_array(c in integer, name in varchar2,
                       bdbl_tab in Binary_Double_Table,
                       index1 in integer, index2 in integer);
  pragma restrict_references(bind_array,WNDS);

  procedure define_array(c in integer, position in integer,
                         bdbl_tab in Binary_Double_Table,
                         cnt in integer, lower_bound in integer);
  pragma restrict_references(define_array,RNDS,WNDS);
 
  procedure column_value(c in integer, position in integer,
                         bdbl_tab in Binary_Double_Table);
  pragma restrict_references(column_value,RNDS,WNDS);

  procedure variable_value(c in integer, name in varchar2, 
                           value in Binary_Double_Table);
  pragma restrict_references(variable_value,RNDS,WNDS);
end;
/

create or replace public synonym dbms_sql for sys.dbms_sql
/
grant execute on dbms_sql to public
/
