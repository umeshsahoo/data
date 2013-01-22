------------------------------------------------------------------------------
--
-- $Header: dbmsdmxf.sql 03-feb-2005.11:49:40 dmukhin Exp $
--
-- dbmsdmxf.sql
--
-- Copyright (c) 2003, Oracle Corporation. All rights reserved.
--
-- NAME
--   dbmsdmxf.sql - DBMS Data Mining XForms
--
-- DESCRIPTION
--       The main principle behind the design of this package is a fact that 
--   SQL has enough power to efficiently perform most of the common mining 
--   xforms. For example, binning can be done using CASE expression or DECODE
--   function, and linear normalization is just a simple algebraic expression
--   of the form (x - shift)/scale. However, the queries that perform the 
--   xfroms can be rather lengthy, thus it seems quite desirable to have some
--   convenience routines that will help in query generation. Thus, the goal 
--   of this package is to provide query generation services for the most 
--   common mining xforms, as well as to provide a framework that can be 
--   easily extended for implementing other xforms.
--       Query generation (xfrom_*) is driven by a few simple xform specific
--   definition tables with a predefined schema. The tables can be created
--   either directly or by means of create_* routines. Query generation
--   routines should be viewed as macros, and xform definition tables as
--   parameters used in macro expansions. Similar to C #define  macros,
--   invoker is responsible for ensuring the correctness of the expanded
--   macro, in other words, that the result is a valid SQL query. Normally
--   consistency and integrity of xform definition tables is guaranteed by the
--   creation process. Alternatively it can be achived by leveraging integrity
--   constraints mechanism. This can be done either by altering the tables
--   created with create_* routines, or by creating the tables manually with
--   the neccessary integrity constraints. 
--       The most common way of defining the xform (populating the xform 
--   definition tables) is based on the data inspection using some predifined
--   methods (also known as automatic xform definition). Some of the most 
--   popular methods have been captured by insert_* routines. For example,
--   zscore normalization method estimates mean and standard deviation from 
--   the data to be used as a shift and scale parameters of the linear 
--   normalization xform. After performing automatic xform definition some or
--   all of the definitions can be adjusted by issueing DML statements against
--   the xfrom definition tables, thus providing virtually infinite
--   flexibility in defining custom xforms.
--       Most of the convenience routines are equivalent to one (or can be 
--   viewed as one) of the SQL statements:
--       create_* - CREATE TABLE <table> (...)
--       insert_* - INSERT INTO <table> SELECT ...
--       xform_*  - CREATE VIEW <view> AS SELECT ...
--
-- NOTES
--       Internally input data is provided by p_*_tref parameters representing
--   table_reference clause allowed in the FROM clause of the SELECT 
--   statement. The data is obtained by perfroming 
--           SELECT * FROM p_*_tref
--       Internally output data is provided by p_*_texpr parameters
--   representing dml_table_expression clause allowed in the INTO clause of
--   the INSERT statement. The data is stored by performing 
--           INSERT INTO p_*_texpr (...) VALUES (...)
--
-- MODIFIED   (MM/DD/YY)
--   dmukhin   02/02/05 - bug 4148499: use dbms_assert
--   dmukhin   01/12/05 - bug 4053211: add missing value treatment
--   dmukhin   12/23/04 - bug 4075208: parameter sample_size is not used
--   dmukhin   10/28/04 - clean up
--   dmukhin   10/06/04 - add scale normalization
--   gtang     09/10/04 - Typo correction
--   gtang     08/26/04 - Add max number of bins in autobin for security 
--                        purposes 
--   gtang     08/13/04 - rename max_buffer to sample_size in autobin 
--   gtang     08/09/04 - Fix bug #3785785 
--   gtang     07/15/04 - Refine checking empty exclusion list 
--   gtang     07/14/04 - Fix bug #3742118 
--   xbarr     06/25/04 - xbarr_dm_rdbms_migration
--   gtang     04/28/04 - fix debugging code
--   gtang     02/23/04 - add adaptive binning
--   dmukhin   09/25/03 - add trimming and winsorizing
--   dmukhin   09/12/03 - open source dbmsdmxf
--   dmukhin   09/02/03 - synchronize dbms_dm_xform and dm_xform
--   dmukhin   04/15/03 - rework xforms
--   dmukhin   01/15/03 - creation
--
------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE dbms_data_mining_transform AUTHID CURRENT_USER AS 
  ----------------------------------------------------------------------------
  -- COLUMN LIST collection type
  ----------------------------------------------------------------------------
  -- This type is used to store both quoted and non-quoted identifiers for 
  -- column names of a table.
  TYPE
    COLUMN_LIST IS VARRAY(1000) OF VARCHAR2(32);

  ----------------------------------------------------------------------------
  --                            create_norm_lin                             --
  ----------------------------------------------------------------------------
  -- NAME
  --   create_norm_lin - CREATE LINear NORMalization definition table
  -- DESCRIPTION
  --   Creates linear normalization definition table:
  --       CREATE TABLE <norm_lin>(
  --         col   VARCHAR2(30),
  --         shift NUMBER,
  --         scale NUMBER)
  --   This table is used to guide query generation process to construct
  --   linear normalization expressions of the following form:
  --       ("{col}" - {shift})/{scale} "{col}"
  --   For example when col = 'my_col', shift = -1.5 and scale = 20 the 
  --   following expression is generated:
  --       ("my_col" - (-1.5))/20 "my_col"
  -- PARAMETERS
  --   norm_table_name                - linear normalization definition table
  --   norm_schema_name               - definition table schema name 
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Note, that {col} is case sensitive since it generates quoted 
  --   identifiers.  When there are multiple entries in the xform defintion 
  --   table for the same {col} the behavior is undefined.  Any one of the 
  --   definitions may be used in query generation. NULL values remain 
  --   unchanged.
  ----------------------------------------------------------------------------
  PROCEDURE create_norm_lin(
    norm_table_name                VARCHAR2,
    norm_schema_name               VARCHAR2 DEFAULT NULL);

  ----------------------------------------------------------------------------
  --                          insert_norm_lin_minmax                        --
  ----------------------------------------------------------------------------
  -- NAME
  --   insert_norm_lin_minmax - INSERT into LINear NORMalization MINMAX
  -- DESCRIPTION
  --   For every NUMBER column in the data table that is not in the exclusion
  --   list finds normalization definition and inserts it into the definition
  --   table. Definition for each relevant column is computed based on the min
  --   and max values that are computed from the data table:
  --       shift = min
  --       scale = max - min
  --   The values of shift and scale are rounded to round_num significant 
  --   digits prior to storing them in the definition table.
  -- PARAMETERS
  --   norm_table_name                - linear normalization definition table
  --   data_table_name                - data table
  --   exclude_list                   - column exclusion list
  --   round_num                      - number of significant digits
  --   norm_schema_name               - definition table schema name
  --   data_schema_name               - data table schema name
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Columns with all NULLs or only one unique value are ignored.
  ----------------------------------------------------------------------------
  PROCEDURE insert_norm_lin_minmax(
    norm_table_name                VARCHAR2,
    data_table_name                VARCHAR2,
    exclude_list                   COLUMN_LIST DEFAULT NULL,
    round_num                      PLS_INTEGER DEFAULT 6,
    norm_schema_name               VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL);

  ----------------------------------------------------------------------------
  --                          insert_norm_lin_scale                         --
  ----------------------------------------------------------------------------
  -- NAME
  --   insert_norm_lin_scale - INSERT into LINear NORMalization SCALE
  -- DESCRIPTION
  --   For every NUMBER column in the data table that is not in the exclusion
  --   list finds normalization definition and inserts it into the definition
  --   table. Definition for each relevant column is computed based on the min
  --   and max values that are computed from the data table:
  --       shift = 0
  --       scale = greatest(abs(max), abs(min))
  --   The value of scale is rounded to round_num significant digits prior to
  --   storing it in the definition table.
  -- PARAMETERS
  --   norm_table_name                - linear normalization definition table
  --   data_table_name                - data table
  --   exclude_list                   - column exclusion list
  --   round_num                      - number of significant digits
  --   norm_schema_name               - definition table schema name
  --   data_schema_name               - data table schema name
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Columns with all NULLs or all zeros are ignored.
  ----------------------------------------------------------------------------
  PROCEDURE insert_norm_lin_scale(
    norm_table_name                VARCHAR2,
    data_table_name                VARCHAR2,
    exclude_list                   COLUMN_LIST DEFAULT NULL,
    round_num                      PLS_INTEGER DEFAULT 6,
    norm_schema_name               VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL);

  ----------------------------------------------------------------------------
  --                          insert_norm_lin_zscore                        --
  ----------------------------------------------------------------------------
  -- NAME
  --   insert_norm_lin_zscore - INSERT into LINear NORMalization Z-SCORE
  -- DESCRIPTION
  --   For every NUMBER column in the data table that is not in the exclusion
  --   list finds normalization definition and inserts it into the definition
  --   table. Definition for each relevant column is computed based on the 
  --   mean and standard deviation that are estimated from the data table:
  --       shift = mean
  --       scale = stddev
  --   The values of shift and scale are rounded to round_num significant 
  --   digits prior to storing them in the definition table.
  -- PARAMETERS
  --   norm_table_name                - linear normalization definition table
  --   data_table_name                - data table
  --   exclude_list                   - column exclusion list
  --   round_num                      - number of significant digits
  --   norm_schema_name               - definition table schema name
  --   data_schema_name               - data table schema name
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Columns with all NULLs or only one unique value are ignored.
  ----------------------------------------------------------------------------
  PROCEDURE insert_norm_lin_zscore(
    norm_table_name                VARCHAR2,
    data_table_name                VARCHAR2,
    exclude_list                   COLUMN_LIST DEFAULT NULL,
    round_num                      PLS_INTEGER DEFAULT 6,
    norm_schema_name               VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL);

  ----------------------------------------------------------------------------
  --                              xform_norm_lin                            --
  ----------------------------------------------------------------------------
  -- NAME
  --   xform_norm_lin - XFORMation LINear NORMalization
  -- DESCRIPTION
  --   Creates a view that perfoms linear normalization of the data table 
  --   Only the columns that are specified in the xform definition are 
  --   normalized, the remaining columns do not change.
  -- PARAMETERS
  --   norm_table_name                - xform definition table
  --   data_table_name                - data table
  --   xform_view_name                - xform view
  --   norm_schema_name               - xform definition table schema name
  --   data_schema_name               - data table schema name
  --   xform_schema_name              - xform view schema name
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   None
  ----------------------------------------------------------------------------
  PROCEDURE xform_norm_lin(
    norm_table_name                VARCHAR2,
    data_table_name                VARCHAR2,
    xform_view_name                VARCHAR2,
    norm_schema_name               VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL,
    xform_schema_name              VARCHAR2 DEFAULT NULL);

  ----------------------------------------------------------------------------
  --                            create_bin_num                              --
  ----------------------------------------------------------------------------
  -- NAME
  --   create_bin_num - CREATE NUMerical BINning definition table
  -- DESCRIPTION
  --   Creates numerical binning definition table:
  --       CREATE TABLE <bin_num>(
  --         col   VARCHAR2(30),
  --         val   NUMBER,
  --         bin   VARCHAR2(4000))
  --   This table is used to guide query generation process to construct
  --   numerical binning expressions of the following form:
  --       CASE WHEN "{col}" <  {val0}   THEN '{bin0}'
  --            WHEN "{col}" <= {val1}   THEN '{bin1}'
  --            ...
  --            WHEN "{col}" <= {valN}   THEN '{binN}'
  --            WHEN "{col}" IS NOT NULL THEN '{bin(N+1)}'
  --       END "{col}"
  --   This expression maps values in the range [{val0};{valN}] into N bins
  --   {bin1}, ..., {binN}, values outside of this range into {bin0} or 
  --   {bin(N+1)}, such that 
  --       (-inf; {val0})       -> {bin0}
  --       [{val0}; {val1}]     -> {bin1}
  --       ... 
  --       ({val(N-1)}; {valN}] -> {binN}
  --       ({valN}; +inf)       -> {bin(N+1)}.
  --   NULL values remain unchanged. {bin(N+1)} is optional. If it is not 
  --   specified the values ("{col}" > {valN}) are mapped to NULL. To specify
  --   {bin(N+1)} provide a row with {val} = NULL. The order of the WHEN .. 
  --   THEN pairs is based on the ascending order of {val} for a given {col}.
  --   Example 1. <bin_num> contains four rows with {col} = 'mycol':
  --       {col = 'mycol', val = 15.5, bin = 'small'}
  --       {col = 'mycol', val = 10,   bin = 'tiny'}
  --       {col = 'mycol', val = 20,   bin = 'large'}
  --       {col = 'mycol', val = NULL, bin = 'huge'}
  --   the following expression is generated:
  --       CASE WHEN "mycol" <  10       THEN 'tiny'
  --            WHEN "mycol" <= 15.5     THEN 'small'
  --            WHEN "mycol" <= 20       THEN 'large'
  --            WHEN "mycol" IS NOT NULL THEN 'huge'
  --       END "mycol"
  --   Example 2. <bin_num> contains three rows with {col} = 'mycol':
  --       {col = 'mycol', val = 15.5, bin = NULL}
  --       {col = 'mycol', val = 10,   bin = 'tiny'}
  --       {col = 'mycol', val = 20,   bin = 'large'}
  --   the following expression is generated:
  --       CASE WHEN "mycol" <  10   THEN NULL
  --            WHEN "mycol" <= 15.5 THEN 'small'
  --            WHEN "mycol" <= 20   THEN 'large'
  --       END "mycol"
  -- PARAMETERS
  --   bin_table_name                 - numerical binning definition table
  --   bin_schema_name                - definition table schema name 
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Note, that {col} is case sensitive since it generates quoted 
  --   identifiers. In cases when there are multiple entries with the same 
  --   {col}, {val} combiniation with different {bin} the behavior is 
  --   undefined. Any one of the {bin} might be used. The maximum number of 
  --   arguments in a CASE expression is 255, and each WHEN ... THEN pair 
  --   counts as two arguments.
  ----------------------------------------------------------------------------
  PROCEDURE create_bin_num(
    bin_table_name                 VARCHAR2,
    bin_schema_name                VARCHAR2 DEFAULT NULL);

  ----------------------------------------------------------------------------
  --                          insert_bin_num_eqwidth                        --
  ----------------------------------------------------------------------------
  -- NAME
  --   insert_bin_num_eqwidth - INSERT into NUMerical BINning EQual-WIDTH
  -- DESCRIPTION
  --   For every NUMBER column in the data table that is not in the exclusion
  --   list finds numerical binning definition and inserts it into the
  --   definition table. Definition for each relevant column is computed based
  --   on the min and max values that are computed from the data table. Each
  --   of the N (p_bin_num) bins {bin1}, ..., {binN} span ranges of equal
  --   width
  --       inc = (max - min) / N
  --   where {binI} = I when N > 0 or {binI} = N+1-I when N < 0, and 
  --   {bin0} = {bin(N+1)} = NULL. For example, when N=2, col='mycol', min=10,
  --   and max = 21, the following three rows are inserted into the 
  --   definition table (inc = 5.5):
  --       COL     VAL BIN
  --       ----- ----- -----
  --       mycol    10 NULL
  --       mycol  15.5 1
  --       mycol    21 2
  --   The values of {val} are rounded to round_num significant digits prior
  --   to storing them in the definition table.
  -- PARAMETERS
  --   bin_table_name                 - numerical binning definition table
  --   data_table_name                - data table
  --   bin_num                        - number of bins
  --   exclude_list                   - column exclusion list
  --   round_num                      - number of significant digits
  --   bin_schema_name                - definition table schema name 
  --   data_schema_name               - data table schema name
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Columns with all NULLs or only one unique value are ignored. Nothing
  --   is done when bin_num IS NULL or bin_num = 0.
  ----------------------------------------------------------------------------
  PROCEDURE insert_bin_num_eqwidth(
    bin_table_name                 VARCHAR2,
    data_table_name                VARCHAR2,
    bin_num                        PLS_INTEGER DEFAULT 10,
    exclude_list                   COLUMN_LIST DEFAULT NULL,
    round_num                      PLS_INTEGER DEFAULT 6,
    bin_schema_name                VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL);

  ----------------------------------------------------------------------------
  --                          insert_bin_num_qtile                          --
  ----------------------------------------------------------------------------
  -- NAME
  --   insert_bin_num_qtile - INSERT into NUMerical BINning QuanTILE
  -- DESCRIPTION
  --   For every NUMBER column in the data table that is not in the exclusion
  --   list finds numerical binning definition and inserts it into the
  --   definition table. Definition for each relevant column is computed based
  --   on the min values per quantile, where quantiles are computed from the
  --   data using NTILE function. Bin {bin1} spans range [min(1), min(2)],
  --   bins {bin2}, ..., {bin(N-1)} span ranges (min(I), min(I+1)] and {binN}
  --   range (min(N), max(N)] with {binI} = I when N > 0 or {binI} = N+1-I
  --   when N < 0, and {bin0}={bin(N+1)} = NULL. Bins with equal left and
  --   right boundaries are collapsed. For example, when N=4, col='mycol',
  --   and data is {1,2,2,2,2,3,4}, the following three rows are inserted into
  --   the definition table:
  --       COL     VAL BIN
  --       ----- ----- -----
  --       mycol     1 NULL
  --       mycol     2 1
  --       mycol     4 2
  --   Here quantiles are {1,2}, {2,2}, {2,3}, {4} and min(1) = 1, min(2) = 2,
  --   min(3) = 2, min(4) = 4, max(4) = 4, and ranges are [1,2], (2,2], (2,4],
  --   (4,4]. After collapsing [1,2], (2,4].
  -- PARAMETERS
  --   bin_table_name                 - numerical binning definition table
  --   data_table_name                - data table
  --   bin_num                        - number of bins
  --   exclude_list                   - column exclusion list
  --   bin_schema_name                - definition table schema name 
  --   data_schema_name               - data table schema name
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Columns with all NULLs or only one unique value are ignored. Nothing
  --   is done when bin_num IS NULL or bin_num = 0.
  ----------------------------------------------------------------------------
  PROCEDURE insert_bin_num_qtile(
    bin_table_name                 VARCHAR2,
    data_table_name                VARCHAR2,
    bin_num                        PLS_INTEGER DEFAULT 10,
    exclude_list                   COLUMN_LIST DEFAULT NULL,
    bin_schema_name                VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL);

  ----------------------------------------------------------------------------
  --                      insert_autobin_num_eqwidth                        --
  ----------------------------------------------------------------------------
  -- NAME
  --   insert_autobin_num_eqwidth - INSERT into NUMerical BINning AUTOmated
  --                                EQual-WIDTH
  -- DESCRIPTION
  --   For every NUMBER column in the data table that is not in the exclusion
  --   list finds numerical binning definition and inserts it into the
  --   definition table. Definition for each relevant column is computed using
  --   equal-width method (see description for insert_bin_nume_eqwidth). The
  --   number of bins (N) is computed for each column separately and is based
  --   on the number of non-NULL values (cnt), min and max values, and the
  --   standard deviation (dev)
  --       N = floor(power(cnt, 1/3)*(max - min)/(C*dev))
  --   where C = 3.49/0.9. Parameter bin_num is used to adjust N to be at
  --   least bin_num. No adjustment is done when bin_num is NULL or zero.
  --   Parameter max_bin_num is used to adjust N to be at most max_bin_num.
  --   No adjustment is done when max_bin_num is NULL or zero. For columns
  --   with all integer values (discrete columns) N is adjusted to be at most
  --   the maximum number of distinct values in the obseved range
  --       max - min + 1
  --   Parameter sample_size is used to adjust cnt to be at most sample_size.
  --   No adjustment is done when sample_size is NULL or zero.
  -- PARAMETERS
  --   bin_table_name                 - numerical binning definition table
  --   data_table_name                - data table
  --   bin_num                        - minimum number of bins
  --   max_bin_num                    - maximum number of bins
  --   exclude_list                   - column exclusion list
  --   round_num                      - number of significant digits
  --   sample_size                    - maximum size of the sample
  --   bin_schema_name                - definition table schema name
  --   data_schema_name               - data table schema name
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Columns with all NULLs or only one unique value are ignored. The sign
  --   of bin_num, max_bin_num, sample_size has no effect on the result, only
  --   the absolute values are being used. The value adjustment for N is done
  --   in the following order: first, bin_num, then max_bin_num, and then
  --   discrete column adjustment.
  ----------------------------------------------------------------------------
  PROCEDURE insert_autobin_num_eqwidth(
    bin_table_name                 VARCHAR2,
    data_table_name                VARCHAR2,
    bin_num                        PLS_INTEGER DEFAULT 3,
    max_bin_num                    PLS_INTEGER DEFAULT 100,
    exclude_list                   COLUMN_LIST DEFAULT NULL,
    round_num                      PLS_INTEGER DEFAULT 6,
    sample_size                    PLS_INTEGER DEFAULT 50000,
    bin_schema_name                VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL);

  ----------------------------------------------------------------------------
  --                              xform_bin_num                             --
  ----------------------------------------------------------------------------
  -- NAME
  --   xform_bin_num - XFORMation NUMerical BINning 
  -- DESCRIPTION
  --   Creates a view that perfoms numerical binning of the data table. Only
  --   the columns that are specified in the xform definition are binned, the
  --   remaining columns do not change.
  -- PARAMETERS
  --   bin_table_name                 - xform definition table
  --   data_table_name                - data table
  --   xform_view_name                - xform view
  --   literal_flag                   - literal flag
  --   bin_schema_name                - xform definition table schema name
  --   data_schema_name               - data table schema name
  --   xform_schema_name              - xform view schema name
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Literal flag indicates whether the values in {bin} are valid SQL 
  --   literals. When the the flag is set to TRUE the value of {bin} is used 
  --   as is in query generation, otherwise it is converted into a valid text
  --   literal (surround by quotes and double the quotes inside). By default 
  --   the flag is set to FALSE. One example when it can be set to TRUE is in
  --   cases when all {bin} are numbers. In that case the xformed column will
  --   remain numeric as opposed to textual (default behavior). For example,
  --   for the following xfrom definition:
  --       COL     VAL BIN
  --       ----- ----- -----
  --       mycol    10 NULL
  --       mycol  15.5 1
  --       mycol    21 2
  --   the following expression is generated when the flag is set to FALSE:
  --       CASE WHEN "mycol" <  10   THEN NULL
  --            WHEN "mycol" <= 15.5 THEN '1'
  --            WHEN "mycol" <= 20   THEN '2'
  --       END "mycol"
  --   and when the flag is set to TRUE:
  --       CASE WHEN "mycol" <  10   THEN NULL
  --            WHEN "mycol" <= 15.5 THEN 1
  --            WHEN "mycol" <= 20   THEN 2
  --       END "mycol"
  ----------------------------------------------------------------------------
  PROCEDURE xform_bin_num(
    bin_table_name                 VARCHAR2,
    data_table_name                VARCHAR2,
    xform_view_name                VARCHAR2,
    literal_flag                   BOOLEAN DEFAULT FALSE,
    bin_schema_name                VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL,
    xform_schema_name              VARCHAR2 DEFAULT NULL);

  ----------------------------------------------------------------------------
  --                            create_bin_cat                              --
  ----------------------------------------------------------------------------
  -- NAME
  --   create_bin_cat - CREATE CATegorical BINning definition table
  -- DESCRIPTION
  --   Creates categorical binning definition table:
  --       CREATE TABLE <bin_cat>(
  --         col   VARCHAR2(30),
  --         val   VARCHAR2(4000),
  --         bin   VARCHAR2(4000))
  --   This table is used to guide query generation process to construct
  --   categorical binning expressions of the following form:
  --       DECODE("{col}", {val1}, {bin1},
  --                       ...
  --                       {valN}, {binN},
  --                       NULL,   NULL,
  --                               {bin(N+1)}) "{col}"
  --   This expression maps values {val1}, ..., {valN} into N bins {bin1},...,
  --   {binN}, and other values into {bin(N+1)}, while NULL values remain 
  --   unchanged. {bin(N+1)} is optional. If it is not specified it defaults
  --   to NULL. To specify {bin(N+1)} provide a row with {val} = NULL. 
  --   Example 1. <bin_cat> contains four rows with {col} = 'mycol':
  --       {col = 'mycol', val = 'Waltham',        bin = 'MA'}
  --       {col = 'mycol', val = 'Burlington',     bin = 'MA'}
  --       {col = 'mycol', val = 'Redwood Shores', bin = 'CA'}
  --       {col = 'mycol', val = NULL,             bin = 'OTHER'}
  --   the following expression is generated:
  --       DECODE("mycol", 'Waltham',        'MA',
  --                       'Burlington',     'MA',
  --                       'Redwood Shores', 'CA',
  --                       NULL,             NULL,
  --                                         'OTHER') "mycol"
  --   Example 2. <bin_cat> contains three rows with {col} = 'mycol':
  --       {col = 'mycol', val = 'Waltham',        bin = 'MA'}
  --       {col = 'mycol', val = 'Burlington',     bin = 'MA'}
  --       {col = 'mycol', val = 'Redwood Shores', bin = 'CA'}
  --   the following expression is generated:
  --       DECODE("mycol", 'Waltham',        'MA',
  --                       'Burlington',     'MA',
  --                       'Redwood Shores', 'CA') "mycol"
  -- PARAMETERS
  --   bin_table_name                 - categorical binning definition table
  --   bin_schema_name                - definition table schema name 
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Note, that {col} is case sensitive since it generates quoted 
  --   identifiers. In cases when there are multiple entries with the same 
  --   {col}, {val} combiniation with different {bin} the behavior is 
  --   undefined. Any one of the {bin} might be used. The maximum number of 
  --   arguments of a DECODE function is 255.
  ----------------------------------------------------------------------------
  PROCEDURE create_bin_cat(
    bin_table_name                 VARCHAR2,
    bin_schema_name                VARCHAR2 DEFAULT NULL);

  ----------------------------------------------------------------------------
  --                          insert_bin_cat_freq                           --
  ----------------------------------------------------------------------------
  -- NAME
  --   insert_bin_cat_freq - INSERT into CATegorical BINning top-FREQuency
  -- DESCRIPTION
  --   For every VARCHAR2, CHAR column in the data table that is not in the
  --   exclusion list finds categorical binning definition and inserts it into
  --   the definition table. Definition for each relevant column is computed
  --   based on occurence frequency of column values that are computed from
  --   the data table reference. Each of the N (bin_num) bins {bin1}, ...,
  --   {binN} correspond to the values with top frequencies when N > 0 or
  --   bottom frequencies when N < 0, and {bin(N+1)} to all remaining
  --   values, where {binI} = I. Ordering ties among identical frequencies are
  --   broken by ordering on column values (ASC for N > 0 or DESC for N < 0).
  --   When the the number of distinct values C < N only C+1 bins will be 
  --   created. Parameter default_num (D) is used for prunning based on the
  --   number of values that fall in the default bin. When D > 0 only columns
  --   that have at least D defaults are kept while others are ignored. When
  --   D < 0 only columns that have at most D values are kept. No prunning is
  --   done when D is NULL or when D = 0. Parameter bin_support (SUP) is used
  --   for restricting bins to frequent (SUP > 0) values frq >= SUP*tot, or
  --   infrequent (SUP < 0) ones frq <= (-SUP)*tot, where frq is a given value
  --   count and tot is a sum of all counts as computed from the data. No
  --   support filtering is done when SUP is NULL or when SUP = 0.
  -- PARAMETERS
  --   bin_table_name                 - categorical binning definition table
  --   data_table_name                - data table
  --   bin_num                        - number of bins
  --   exclude_list                   - column exclusion list
  --   default_num                    - number of default values
  --   bin_support                    - bin support (fraction)
  --   bin_schema_name                - definition table schema name
  --   data_schema_name               - data table schema name
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Nothing is done when bin_num IS NULL or bin_num = 0. NULL values 
  --   are not counted. Columns with all NULLs are ignored. 
  ----------------------------------------------------------------------------
  PROCEDURE insert_bin_cat_freq(
    bin_table_name                 VARCHAR2,
    data_table_name                VARCHAR2,
    bin_num                        PLS_INTEGER DEFAULT 9,
    exclude_list                   COLUMN_LIST DEFAULT NULL,
    default_num                    PLS_INTEGER DEFAULT 2,
    bin_support                    NUMBER DEFAULT NULL,
    bin_schema_name                VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL);

  ----------------------------------------------------------------------------
  --                              xform_bin_cat                             --
  ----------------------------------------------------------------------------
  -- NAME
  --   xform_bin_num - XFORMation CATegorical BINning 
  -- DESCRIPTION
  --   Creates a view that perfoms categorical binning of the data table. Only
  --   the columns that are specified in the xform definition are binned, the
  --   remaining columns do not change.
  -- PARAMETERS
  --   bin_table_name                 - xform definition table
  --   data_table_name                - data table
  --   xform_view_name                - xform view
  --   litiral_flag                   - literal flag
  --   bin_schema_name                - xform definition table schema name
  --   data_schema_name               - data table schema name
  --   xform_schema_name              - xform view schema name
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Literal flag indicates whether the values in {bin} are valid SQL 
  --   literals. When the the flag is set to TRUE the value of {bin} is used 
  --   as is in query generation, otherwise it is converted into a valid text
  --   literal (surround by quotes and double the quotes inside). By default 
  --   the flag is set to FALSE. One example when it can be set to TRUE is in
  --   cases when all {bin} are numbers. In that case the xformed column will
  --   be numeric as opposed to textual (default behavior). For example,
  --   for the following xfrom definition:
  --       COL   VAL            BIN
  --       ----- -------------- ----
  --       mycol Waltham        1
  --       mycol Burlington     1
  --       mycol Redwood Shores 2
  --   the following expression is generated when the flag is set to FALSE:
  --       DECODE("mycol", 'Waltham',       '1',
  --                       'Burlington',    '1',
  --                       'Redwood Shores','2') "mycol"
  --   and when the flag is set to TRUE:
  --       DECODE("mycol", 'Waltham',        1,
  --                       'Burlington',     1,
  --                       'Redwood Shores', 2) "mycol"
  ----------------------------------------------------------------------------
  PROCEDURE xform_bin_cat(
    bin_table_name                 VARCHAR2,
    data_table_name                VARCHAR2,
    xform_view_name                VARCHAR2,
    literal_flag                   BOOLEAN DEFAULT FALSE,
    bin_schema_name                VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL,
    xform_schema_name              VARCHAR2 DEFAULT NULL);

  ----------------------------------------------------------------------------
  --                             xform_expr_num                             --
  ----------------------------------------------------------------------------
  -- NAME
  --   xform_expr_num - XFORMation EXPRession NUMber 
  -- DESCRIPTION
  --   Creates a view that applies a given expression for every NUMBER column
  --   in the data table that is not in the exclusion list and in the
  --   inclusion list. The remaining columns do not change. Expressions are 
  --   constructed from the expression pattern by replacing every occurance of
  --   the column pattern with an actual column name.
  --   Example 1. For a table TAB with two NUMBER columns CN1, CN3 and one
  --   CHAR columns CC2 and expression pattern TO_CHAR(:col) the following
  --   query is generated:
  --       SELECT TO_CHAR("CN1") "CN1", "CC2", TO_CHAR("CN3") "CN3"
  --         FROM TAB
  --   Example 2. This procedure can be used for clipping (winsorizing) 
  --   normalized data to a [0..1] range, that is values x > 1 become 1 and
  --   values x < 0 become 0. For the table in example 1 and pattern
  --       CASE WHEN :col < 0 THEN 0 WHEN :col > 1 THEN 1 ELSE :col END
  --   the following query is generated:
  --       SELECT CASE WHEN "CN1" < 0 THEN 0 WHEN "CN1" > 1 THEN 1 
  --                   ELSE "CN1" END "CN1", 
  --              "CC2",
  --              CASE WHEN "CN3" < 0 THEN 0 WHEN "CN3" > 1 THEN 1 
  --                   ELSE "CN3" END "CN3"
  --         FROM TAB
  -- PARAMETERS
  --   expr_pattern                   - expression pattern
  --   data_table_name                - data table
  --   xform_view_name                - xform view
  --   exclude_list                   - column exclusion list
  --   include_list                   - column inclusion list
  --   col_pattern                    - column pattern
  --   data_schema_name               - data table schema name
  --   xform_schema_name              - xform view schema name
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   The default value of column pattern is ':col'. Column pattern is case
  --   sensetive. Expressions are constructed using SQL REPLACE function:
  --       REPALCE(expr_pattern, col_pattern, '"<column>"')||' "<column>"'
  --   NULL exclusion list is treated as an empty set (exclude none) and NULL
  --   inclusion list is treated as a full set (include all).
  ----------------------------------------------------------------------------
  PROCEDURE xform_expr_num(
    expr_pattern                   VARCHAR2,
    data_table_name                VARCHAR2,
    xform_view_name                VARCHAR2,
    exclude_list                   COLUMN_LIST DEFAULT NULL,
    include_list                   COLUMN_LIST DEFAULT NULL,
    col_pattern                    VARCHAR2 DEFAULT ':col',
    data_schema_name               VARCHAR2 DEFAULT NULL,
    xform_schema_name              VARCHAR2 DEFAULT NULL);

  ----------------------------------------------------------------------------
  --                             xform_expr_str                             --
  ----------------------------------------------------------------------------
  -- NAME
  --   xform_expr_str - XFORMation EXPRession STRing
  -- DESCRIPTION
  --   Similar to xform_expr_num, except that it applies to CHAR and VARCHAR2
  --   columns instead of NUMBER.
  -- PARAMETERS
  --   expr_pattern                   - expression pattern
  --   data_table_name                - data table
  --   xform_view_name                - xform view
  --   exclude_list                   - column exclusion list
  --   include_list                   - column inclusion list
  --   col_pattern                    - column pattern
  --   data_schema_name               - data table schema name
  --   xform_schema_name              - xform view schema name
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   None
  ----------------------------------------------------------------------------
  PROCEDURE xform_expr_str(
    expr_pattern                   VARCHAR2,
    data_table_name                VARCHAR2,
    xform_view_name                VARCHAR2,
    exclude_list                   COLUMN_LIST DEFAULT NULL,
    include_list                   COLUMN_LIST DEFAULT NULL,
    col_pattern                    VARCHAR2 DEFAULT ':col',
    data_schema_name               VARCHAR2 DEFAULT NULL,
    xform_schema_name              VARCHAR2 DEFAULT NULL);

  ----------------------------------------------------------------------------
  --                              create_clip                               --
  ----------------------------------------------------------------------------
  -- NAME
  --   create_clip - CREATE CLIPping definition table
  -- DESCRIPTION
  --   Creates clippping definition table:
  --       CREATE TABLE <clip>(
  --         col  VARCHAR2(30),
  --         lcut NUMBER,
  --         lval NUMBER,
  --         rcut NUMBER,
  --         rval NUMBER)
  --   This table is used to guide query generation process to construct
  --   clipping expressions of the following form:
  --       CASE WHEN "{col}" < {lcut} THEN {lval}
  --            WHEN "{col}" > {rcut} THEN {rval}
  --                                  ELSE "{col}"
  --       END "{col}"
  --   Example 1. (winsorizing) When col = 'my_col', lcut = -1.5, lval = -1.5,
  --   and rcut = 4.5 and rval = 4.5 the following expression is generated:
  --       CASE WHEN "my_col" < -1.5 THEN -1.5
  --            WHEN "my_col" >  4.5 THEN  4.5
  --                                 ELSE "my_col"
  --       END "my_col"
  --   Example 2. (trimming) When col = 'my_col', lcut = -1.5, lval = NULL,
  --   and rcut = 4.5 and rval = NULL the following expression is generated:
  --       CASE WHEN "my_col" < -1.5 THEN NULL
  --            WHEN "my_col" >  4.5 THEN NULL
  --                                 ELSE "my_col"
  --       END "my_col"
  -- PARAMETERS
  --   clip_table_name                - clipping definition table
  --   clip_schema_name               - clipping definition table schema name 
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Note, that {col} is case sensitive since it generates quoted 
  --   identifiers.  When there are multiple entries in the xform defintion 
  --   table for the same {col} the behavior is undefined.  Any one of the 
  --   definitions may be used in query generation. NULL values remain 
  --   unchanged.
  ----------------------------------------------------------------------------
  PROCEDURE create_clip(
    clip_table_name                VARCHAR2,
    clip_schema_name               VARCHAR2 DEFAULT NULL);

  ----------------------------------------------------------------------------
  --                        insert_clip_winsor_tail                         --
  ----------------------------------------------------------------------------
  -- NAME
  --   insert_clip_winsor_tail - INSERT into CLIPping WINSORizing TAIL
  -- DESCRIPTION
  --   For every NUMBER column in the data table that is not in the exclusion
  --   list finds clipping definition and inserts it into the definition
  --   table. Definition for each relevant column is computed based on the
  --   non-NULL values sorted in ascending order such that val(1)<val(2)<...<
  --   val(N), where N is a total number of non-NULL values in a column:
  --       lcut = val(1+floor(N*q))
  --       lval = lcut
  --       rcut = val(N-floor(N*q))
  --       rval = rcut
  --   where q = ABS(NVL(tail_frac,0)). Nothing is done when q >= 0.5.
  -- PARAMETERS
  --   clip_table_name                - clipping definition table
  --   data_table_name                - data table
  --   tail_frac                      - tail fraction
  --   exclude_list                   - column exclusion list
  --   clip_schema_name               - definition table schema name
  --   data_schema_name               - data table schema name
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Columns with all NULLs are ignored.
  ----------------------------------------------------------------------------
  PROCEDURE insert_clip_winsor_tail(
    clip_table_name                VARCHAR2,
    data_table_name                VARCHAR2,
    tail_frac                      NUMBER DEFAULT 0.025,
    exclude_list                   COLUMN_LIST DEFAULT NULL,
    clip_schema_name               VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL);

  ----------------------------------------------------------------------------
  --                        insert_clip_trim_tail                           --
  ----------------------------------------------------------------------------
  -- NAME
  --   insert_clip_trim_tail - INSERT into CLIPping TRIMming TAIL
  -- DESCRIPTION
  --   For every NUMBER column in the data table that is not in the exclusion
  --   list finds clipping definition and inserts it into the definition
  --   table. Definition for each relevant column is computed based on the
  --   non-NULL values sorted in ascending order such that val(1)<val(2)<...<
  --   val(N), where N is a total number of non-NULL values in a column:
  --       lcut = val(1+floor(N*q))
  --       lval = NULL
  --       rcut = val(N-floor(N*q))
  --       rval = NULL
  --   where q = ABS(NVL(tail_frac,0)). Nothing is done when q >= 0.5.
  -- PARAMETERS
  --   clip_table_name                - clipping definition table
  --   data_table_name                - data table
  --   tail_frac                      - tail fraction
  --   exclude_list                   - column exclusion list
  --   clip_schema_name               - definition table schema name
  --   data_schema_name               - data table schema name
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Columns with all NULLs are ignored.
  ----------------------------------------------------------------------------
  PROCEDURE insert_clip_trim_tail(
    clip_table_name                VARCHAR2,
    data_table_name                VARCHAR2,
    tail_frac                      NUMBER DEFAULT 0.025,
    exclude_list                   COLUMN_LIST DEFAULT NULL,
    clip_schema_name               VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL);

  ----------------------------------------------------------------------------
  --                               xform_clip                               --
  ----------------------------------------------------------------------------
  -- NAME
  --   xform_norm_lin - XFORMation LINear NORMalization
  -- DESCRIPTION
  --   Creates a view that perfoms clipping of the data table. Only the
  --   columns that are specified in the xform definition are clipped, the
  --   remaining columns do not change.
  -- PARAMETERS
  --   clip_table_name                - xform definition table
  --   data_table_name                - data table
  --   xform_view_name                - xform view
  --   clip_schema_name               - xform definition table schema name
  --   data_schema_name               - data table schema name
  --   xform_schema_name              - xform view schema name
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   None
  ----------------------------------------------------------------------------
  PROCEDURE xform_clip(
    clip_table_name                VARCHAR2,
    data_table_name                VARCHAR2,
    xform_view_name                VARCHAR2,
    clip_schema_name               VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL,
    xform_schema_name              VARCHAR2 DEFAULT NULL);

  ----------------------------------------------------------------------------
  --                            create_miss_num                             --
  ----------------------------------------------------------------------------
  -- NAME
  --   create_miss_num - CREATE NUMerical MISSing value treatment definition
  --                     table
  -- DESCRIPTION
  --   Creates numerical missing value treatment definition table:
  --       CREATE TABLE <miss_num>(
  --         col VARCHAR2(30),
  --         val NUMBER)
  --   This table is used to guide query generation process to construct
  --   missing value treatment expressions of the following form:
  --       NVL("{col}", {val}) "{col}"
  --   For example when col = 'my_col', val = 20 the 
  --   following expression is generated:
  --       NVL("my_col", 20) "my_col"
  -- PARAMETERS
  --   miss_table_name                - definition table
  --   miss_schema_name               - definition table schema name 
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Note, that {col} is case sensitive since it generates quoted 
  --   identifiers.  When there are multiple entries in the xform defintion 
  --   table for the same {col} the behavior is undefined.  Any one of the 
  --   definitions may be used in query generation.
  ----------------------------------------------------------------------------
  PROCEDURE create_miss_num(
    miss_table_name                VARCHAR2,
    miss_schema_name               VARCHAR2 DEFAULT NULL);

  ----------------------------------------------------------------------------
  --                           insert_miss_num_mean                         --
  ----------------------------------------------------------------------------
  -- NAME
  --   insert_miss_num_mean - INSERT into NUMerical MISSining value treatment
  --                          MEAN
  -- DESCRIPTION
  --   For every NUMBER column in the data table that is not in the exclusion
  --   list finds missing value treatment definition and inserts it into the
  --   definition table. Definition for each relevant column is computed based
  --   on the mean (average) value that is computed from the data table:
  --       val = mean
  --   The value of mean is rounded to round_num significant digits prior to
  --   storing it in the definition table.
  -- PARAMETERS
  --   miss_table_name                - definition table
  --   data_table_name                - data table
  --   exclude_list                   - column exclusion list
  --   round_num                      - number of significant digits
  --   miss_schema_name               - definition table schema name
  --   data_schema_name               - data table schema name
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Columns with all NULLs are ignored.
  ----------------------------------------------------------------------------
  PROCEDURE insert_miss_num_mean(
    miss_table_name                VARCHAR2,
    data_table_name                VARCHAR2,
    exclude_list                   COLUMN_LIST DEFAULT NULL,
    round_num                      PLS_INTEGER DEFAULT 6,
    miss_schema_name               VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL);

  ----------------------------------------------------------------------------
  --                              xform_miss_num                            --
  ----------------------------------------------------------------------------
  -- NAME
  --   xform_miss_num - XFORMation NUMerical MISSing value treatment
  -- DESCRIPTION
  --   Creates a view that perfoms numerical missing value treatment of the
  --   data table. Only the columns that are specified in the xform definition
  --   are treated, the remaining columns do not change.
  -- PARAMETERS
  --   miss_table_name                - xform definition table
  --   data_table_name                - data table
  --   xform_view_name                - xform view
  --   miss_schema_name               - xform definition table schema name
  --   data_schema_name               - data table schema name
  --   xform_schema_name              - xform view schema name
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   None
  ----------------------------------------------------------------------------
  PROCEDURE xform_miss_num(
    miss_table_name                VARCHAR2,
    data_table_name                VARCHAR2,
    xform_view_name                VARCHAR2,
    miss_schema_name               VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL,
    xform_schema_name              VARCHAR2 DEFAULT NULL);

  ----------------------------------------------------------------------------
  --                            create_miss_cat                             --
  ----------------------------------------------------------------------------
  -- NAME
  --   create_miss_cat - CREATE CATegorical MISSing value treatment definition
  --                     table
  -- DESCRIPTION
  --   Creates categorical missing value treatment definition table:
  --       CREATE TABLE <miss_cat>(
  --         col VARCHAR2(30),
  --         val VARCHAR2(4000))
  --   This table is used to guide query generation process to construct
  --   missing value treatment expressions of the following form:
  --       NVL("{col}", {val}) "{col}"
  --   For example when col = 'zip_code', val = 'MA' the 
  --   following expression is generated:
  --       NVL("zip_code", 'MA') "zip_code"
  -- PARAMETERS
  --   miss_table_name                - definition table
  --   miss_schema_name               - definition table schema name 
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Note, that {col} is case sensitive since it generates quoted 
  --   identifiers.  When there are multiple entries in the xform defintion 
  --   table for the same {col} the behavior is undefined.  Any one of the 
  --   definitions may be used in query generation.
  ----------------------------------------------------------------------------
  PROCEDURE create_miss_cat(
    miss_table_name                VARCHAR2,
    miss_schema_name               VARCHAR2 DEFAULT NULL);

  ----------------------------------------------------------------------------
  --                           insert_miss_cat_mode                         --
  ----------------------------------------------------------------------------
  -- NAME
  --   insert_miss_cat_mode - INSERT into CATegorical MISSining value
  --                          treatment MODE
  -- DESCRIPTION
  --   For every VARCHAR2, CHAR column in the data table that is not in the
  --   exclusion list finds missing value treatment definition and inserts it
  --   into the definition table. Definition for each relevant column is
  --   computed based on the mode value that is computed from the data table:
  --       val = mode
  -- PARAMETERS
  --   miss_table_name                - definition table
  --   data_table_name                - data table
  --   exclude_list                   - column exclusion list
  --   miss_schema_name               - definition table schema name
  --   data_schema_name               - data table schema name
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Columns with all NULLs are ignored.
  ----------------------------------------------------------------------------
  PROCEDURE insert_miss_cat_mode(
    miss_table_name                VARCHAR2,
    data_table_name                VARCHAR2,
    exclude_list                   COLUMN_LIST DEFAULT NULL,
    miss_schema_name               VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL);

  ----------------------------------------------------------------------------
  --                              xform_miss_cat                            --
  ----------------------------------------------------------------------------
  -- NAME
  --   xform_miss_cat - XFORMation CATegorical MISSing value treatment
  -- DESCRIPTION
  --   Creates a view that perfoms categorical missing value treatment of the
  --   data table. Only the columns that are specified in the xform definition
  --   are treated, the remaining columns do not change.
  -- PARAMETERS
  --   miss_table_name                - xform definition table
  --   data_table_name                - data table
  --   xform_view_name                - xform view
  --   miss_schema_name               - xform definition table schema name
  --   data_schema_name               - data table schema name
  --   xform_schema_name              - xform view schema name
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   The data type of the xformed columns is preseved by putting a CAST
  --   expression around NVL. For example, when col = 'zip_code', val = 'MA'
  --   the data type is CHAR(2) the following expression is generated:
  --       CAST(NVL("zip_code", 'MA') AS CHAR(2)) "zip_code"
  ----------------------------------------------------------------------------
  PROCEDURE xform_miss_cat(
    miss_table_name                VARCHAR2,
    data_table_name                VARCHAR2,
    xform_view_name                VARCHAR2,
    miss_schema_name               VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL,
    xform_schema_name              VARCHAR2 DEFAULT NULL);
END dbms_data_mining_transform;
/
GRANT EXECUTE ON dmsys.dbms_data_mining_transform 
   TO PUBLIC
/
CREATE OR REPLACE PUBLIC SYNONYM dbms_data_mining_transform
   FOR dmsys.dbms_data_mining_transform
/
CREATE OR REPLACE PACKAGE BODY dbms_data_mining_transform AS
  ----------------------------------------------------------------------------
  -- STateMenT TYPE
  ----------------------------------------------------------------------------
  -- This type can be used for statements that are at most 32K and can be 
  -- processed by both dbms_sql package and native PL/SQL.
  SUBTYPE 
    STMT_VCHAR_TYPE                IS VARCHAR2(32767);

  ----------------------------------------------------------------------------
  -- Long STateMenT TYPE
  ----------------------------------------------------------------------------
  -- This type should be used for statements that can grow larger than 32K,
  -- however it can only be processed by dbms_sql package and not by native
  -- PL/SQL. Field lb is the smallest index and ub is the largest index of the
  -- elements of the VARCHAR2A array. Note that the largest query that can be 
  -- processed is 64K. For more details refer to Oracle Database Reference/
  -- Database Limits/Logical Database Limits/SQL Statement Length. 
  TYPE 
    LSTMT_REC_TYPE                 IS RECORD (
      lstmt                          dbms_sql.VARCHAR2A,
      lb                             BINARY_INTEGER DEFAULT 1,
      ub                             BINARY_INTEGER DEFAULT 0);

  ----------------------------------------------------------------------------
  -- IDENtifier type
  ----------------------------------------------------------------------------
  -- This type is used for storing both non-quoted and quoted identifiers. 
  SUBTYPE
    IDEN_VCHAR_TYPE                IS VARCHAR2(32);

  ----------------------------------------------------------------------------
  -- Canonical IDENtifier TYPE 
  ----------------------------------------------------------------------------
  -- This type is used for storing canonical identifiers that are obtained
  -- from either quoted identifiers by striping quotes or from non-qutoted 
  -- ones by converting them to upper case.
  SUBTYPE
    CIDEN_VCHAR_TYPE               IS VARCHAR2(30);

  ----------------------------------------------------------------------------
  -- DESCribe TYPE
  ----------------------------------------------------------------------------
  -- This type holds the results of describe operations. Note that col_name 
  -- field of DESC_TAB2 is VARCHAR2(32767). This is applicable to cases when
  -- a SELECT expression is not given an alias and thus the expression itself
  -- is used as name (with whitespaces removed) and thus can be larger than
  -- 30 bytes. However when those names get larger than 30 bytes the 
  -- corresponding SELECT cannont be used as an inline view.
  SUBTYPE
    DESC_ITAB_TYPE                 IS dbms_sql.DESC_TAB2;

  ----------------------------------------------------------------------------
  -- STateMenT collection types
  ----------------------------------------------------------------------------
  TYPE
    STMT_NTAB_TYPE                 IS TABLE OF STMT_VCHAR_TYPE;

  ----------------------------------------------------------------------------
  -- IDENtifier collection types
  ----------------------------------------------------------------------------
  SUBTYPE
    IDEN_VARR_TYPE                 IS COLUMN_LIST;

  ----------------------------------------------------------------------------
  -- Canonical IDENtifier collection types
  ----------------------------------------------------------------------------
  TYPE
    CIDEN_ITAB_TYPE                IS TABLE OF CIDEN_VCHAR_TYPE
                                      INDEX BY BINARY_INTEGER;
  TYPE
    CIDEN_ATAB_TYPE                IS TABLE OF BINARY_INTEGER
                                      INDEX BY CIDEN_VCHAR_TYPE;

  ----------------------------------------------------------------------------
  -- NUMber collection types
  ----------------------------------------------------------------------------
  TYPE
    NUM_NTAB_TYPE                  IS TABLE OF NUMBER;
  TYPE
    NUM_ITAB_TYPE                  IS TABLE OF NUMBER
                                      INDEX BY BINARY_INTEGER;

  ----------------------------------------------------------------------------
  -- STRing collection types
  ----------------------------------------------------------------------------
  TYPE
    STR_ITAB_TYPE                  IS TABLE OF VARCHAR2(4000)
                                      INDEX BY BINARY_INTEGER;

  ----------------------------------------------------------------------------
  -- LINear NORMalization xform definition RECord TYPE
  ----------------------------------------------------------------------------
  TYPE
    NORM_LIN_REC_TYPE              IS RECORD (
      col_itab                       CIDEN_ITAB_TYPE,        -- xform def: COL
      shift_itab                     NUM_ITAB_TYPE,        -- xform def: SHIFT
      scale_itab                     NUM_ITAB_TYPE,        -- xform def: SCALE
      cnt                            PLS_INTEGER DEFAULT 0);          -- CouNT
      
  ----------------------------------------------------------------------------
  -- BINning NUMerical xform definition RECord TYPE
  ----------------------------------------------------------------------------
  TYPE
    BIN_NUM_REC_TYPE               IS RECORD (
      col_itab                       CIDEN_ITAB_TYPE,        -- xform def: COL
      val_itab                       NUM_ITAB_TYPE,          -- xform def: VAL
      bin_itab                       STR_ITAB_TYPE,          -- xform def: BIN
      cnt                            PLS_INTEGER DEFAULT 0);          -- CouNT

  ----------------------------------------------------------------------------
  -- BINning CATegorical xform definition RECord TYPE
  ----------------------------------------------------------------------------
  TYPE
    BIN_CAT_REC_TYPE               IS RECORD (
      col_itab                       CIDEN_ITAB_TYPE,        -- xform def: COL
      val_itab                       STR_ITAB_TYPE,          -- xform def: VAL
      bin_itab                       STR_ITAB_TYPE,          -- xform def: BIN
      cnt                            PLS_INTEGER DEFAULT 0);          -- CouNT

  ----------------------------------------------------------------------------
  -- CLIPping xform definition RECord TYPE
  ----------------------------------------------------------------------------
  TYPE
    CLIP_REC_TYPE                  IS RECORD (
      col_itab                       CIDEN_ITAB_TYPE,        -- xform def: COL
      lcut_itab                      NUM_ITAB_TYPE,         -- xform def: LCUT
      lval_itab                      NUM_ITAB_TYPE,         -- xform def: LVAL
      rcut_itab                      NUM_ITAB_TYPE,         -- xform def: RCUT
      rval_itab                      NUM_ITAB_TYPE,         -- xform def: RVAL
      cnt                            PLS_INTEGER DEFAULT 0);          -- CouNT

  ----------------------------------------------------------------------------
  -- MISSing value treatment NUMerical xform definition RECord TYPE
  ----------------------------------------------------------------------------
  TYPE
    MISS_NUM_REC_TYPE               IS RECORD (
      col_itab                       CIDEN_ITAB_TYPE,        -- xform def: COL
      val_itab                       NUM_ITAB_TYPE,          -- xform def: VAL
      cnt                            PLS_INTEGER DEFAULT 0);          -- CouNT

  ----------------------------------------------------------------------------
  -- MISSing value treatment CATegorical xform definition RECord TYPE
  ----------------------------------------------------------------------------
  TYPE
    MISS_CAT_REC_TYPE               IS RECORD (
      col_itab                       CIDEN_ITAB_TYPE,        -- xform def: COL
      val_itab                       STR_ITAB_TYPE,          -- xform def: VAL
      cnt                            PLS_INTEGER DEFAULT 0);          -- CouNT

  ----------------------------------------------------------------------------
  -- NUMber Column TYPes Nested TABle
  ----------------------------------------------------------------------------
  -- This constant contains the list of number column types that are supported
  -- in this package.
  c_num_ctyp_ntab                CONSTANT NUM_NTAB_TYPE := NUM_NTAB_TYPE(
                                   2);                               -- NUMBER

  ----------------------------------------------------------------------------
  -- STRing Column TYPes Nested TABle
  ----------------------------------------------------------------------------
  -- This constant contains the list of string column types that are supported
  -- in this package.
  c_str_ctyp_ntab                CONSTANT NUM_NTAB_TYPE := NUM_NTAB_TYPE(
                                   1,                              -- VARCHAR2
                                   96);                                -- CHAR

  ----------------------------------------------------------------------------
  -- CANONical identifier MAXimum LENgth (in bytes)
  ----------------------------------------------------------------------------
  -- This constant contains the list of string column types that are supported
  -- in this package.
  c_canon_maxlen                 CONSTANT BINARY_INTEGER := 30;

  ----------------------------------------------------------------------------
  -- Data Types
  ----------------------------------------------------------------------------
  -- Columns with sign(sum(abs(:col - trunc(:col)))) = 1 have non-integer
  -- values and thus are treated as continues. Value 0 indicates that all
  -- values of the column are integers and the column is treated as discrete.
  c_dty_discrete                 CONSTANT NUMBER := 0;
  c_dty_continuos                CONSTANT NUMBER := 1;

  ----------------------------------------------------------------------------
  --                               ls_append                                --
  ----------------------------------------------------------------------------
  -- NAME
  --   ls_append - Long Statement APPEND
  -- DESCRIPTION
  --   Appends text to long statement.
  -- PARAMETERS
  --   r_lstmt                         - long statement
  --   p_txt                           - text
  -- RETURNS
  --   r_lstmt                         - updated long statement
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   None
  ----------------------------------------------------------------------------
  PROCEDURE ls_append(
    r_lstmt                        IN OUT NOCOPY LSTMT_REC_TYPE,
    p_txt                          VARCHAR2) 
  IS
  BEGIN
    r_lstmt.ub := r_lstmt.ub + 1;
    r_lstmt.lstmt(r_lstmt.ub) := p_txt;
  END ls_append;

  ----------------------------------------------------------------------------
  --                                ls_parse                                --
  ----------------------------------------------------------------------------
  -- NAME
  --   ls_parse - Long Statement PARSE
  -- DESCRIPTION
  --   Parses long statement for given opened cursor.
  -- PARAMETERS
  --   p_cur                           - dbms_sql cursor
  --   p_lstmt                         - long statement
  --   p_lf_flag                       - dbms_sql.parse line feed flag
  --   p_lang_flag                     - dbms_sql.parse language flag
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   None
  ----------------------------------------------------------------------------
  PROCEDURE ls_parse(
    p_cur                          NUMBER,
    p_lstmt                        LSTMT_REC_TYPE,
    p_lf_flag                      BOOLEAN DEFAULT FALSE,
    p_lang_flag                    NUMBER DEFAULT dbms_sql.native)
  IS
  BEGIN      
    dbms_sql.parse(
      c                              => p_cur,                       -- Cursor
      statement                      => p_lstmt.lstmt, 
      lb                             => p_lstmt.lb,             -- Lower Bound
      ub                             => p_lstmt.ub,             -- Upper Bound
      lfflg                          => p_lf_flag,            -- LineFeed FLaG
      language_flag                  => p_lang_flag);
  END ls_parse;
  
  ----------------------------------------------------------------------------
  --                                ls_exec                                 --
  ----------------------------------------------------------------------------
  -- NAME
  --   ls_exec - Long Statement EXECute
  -- DESCRIPTION
  --   Executes long DDL statement.
  -- PARAMETERS
  --   p_lstmt                         - long statement
  --   p_lf_flag                       - dbms_sql.parse line feed flag
  --   p_lang_flag                     - dbms_sql.parse language flag
  -- RETURNS
  --    None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Opens a cursor, parses and executes the statements and then closes
  --   the cursor.
  ----------------------------------------------------------------------------
  PROCEDURE ls_exec(
    p_lstmt                        LSTMT_REC_TYPE,
    p_lf_flag                      BOOLEAN DEFAULT FALSE,
    p_lang_flag                    NUMBER DEFAULT dbms_sql.native)
  IS  
    v_cur                          INTEGER;
    v_row                          INTEGER;
  BEGIN  
    v_cur := dbms_sql.open_cursor;
    ls_parse(
      p_cur                          => v_cur,
      p_lstmt                        => p_lstmt,
      p_lf_flag                      => p_lf_flag,
      p_lang_flag                    => p_lang_flag);
    v_row := dbms_sql.execute(v_cur);
    dbms_sql.close_cursor(v_cur);
  EXCEPTION
    WHEN OTHERS THEN
      IF dbms_sql.is_open(v_cur) THEN
        dbms_sql.close_cursor(v_cur);
      END IF;
      RAISE;
  END ls_exec;  
  
  ----------------------------------------------------------------------------
  --                                ls_desc                                 --
  ----------------------------------------------------------------------------
  -- NAME
  --   ls_desc - Long Statement DESCribe
  -- DESCRIPTION
  --   Describes long query statement.
  -- PARAMETERS
  --   p_lstmt                         - long statement
  --   p_lf_flag                       - dbms_sql.parse line feed flag
  --   p_lang_flag                     - dbms_sql.parse language flag
  -- RETURNS
  --   r_desc_itab                     - describe table
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   None
  ----------------------------------------------------------------------------
  PROCEDURE ls_desc(
    p_lstmt                        LSTMT_REC_TYPE,
    r_desc_itab                    OUT NOCOPY DESC_ITAB_TYPE,
    p_lf_flag                      BOOLEAN DEFAULT FALSE,
    p_lang_flag                    NUMBER DEFAULT dbms_sql.native)
  IS
    v_cur                          INTEGER;
    v_col_cnt                      INTEGER;
  BEGIN
    v_cur := dbms_sql.open_cursor;
    ls_parse(
      p_cur                          => v_cur,
      p_lstmt                        => p_lstmt,
      p_lf_flag                      => p_lf_flag,
      p_lang_flag                    => p_lang_flag);
    dbms_sql.describe_columns2(
      c                              => v_cur,                       -- Cursor
      col_cnt                        => v_col_cnt,             -- COLumn CouNT
      desc_t                         => r_desc_itab);        -- DESCribe Table
    dbms_sql.close_cursor(v_cur);
  EXCEPTION
    WHEN OTHERS THEN
      IF dbms_sql.is_open(v_cur) THEN
        dbms_sql.close_cursor(v_cur);
      END IF;
      RAISE;
  END ls_desc;

  ----------------------------------------------------------------------------
  --                               to_literal                               --
  ----------------------------------------------------------------------------
  -- NAME
  --   to_literal - number TO number LITERAL
  -- DESCRIPTION
  --   Converts number value to number literal. If parenthesis flag is set to
  --   TRUE, negative values are surronded by parenthesis. When input value is
  --   NULL the string 'NULL' is returned. 
  -- PARAMETERS
  --   p_val                          - number value
  --   p_paren_flag                   - parenthesis flag
  -- RETURNS
  --   Number literal.
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Picks the shortest representation among fixed and scientific.
  ----------------------------------------------------------------------------
  FUNCTION to_literal(
    p_val                            NUMBER,
    p_paren_flag                     BOOLEAN DEFAULT TRUE)
  RETURN VARCHAR2
  IS
    v_lit                            STMT_VCHAR_TYPE;               -- LITeral
    v_lit_e                          STMT_VCHAR_TYPE;    -- scientific LITeral
  BEGIN
    IF p_val IS NULL THEN
      RETURN 'NULL';
    ELSE
      v_lit := TO_CHAR(                                 -- fixed or scientific
        p_val, 'TM9', 'NLS_NUMERIC_CHARACTERS=''.,''');
      v_lit_e := TO_CHAR(                                 -- always scientific
        p_val, 'TME', 'NLS_NUMERIC_CHARACTERS=''.,''');
      IF LENGTH(v_lit_e) < LENGTH(v_lit) THEN         -- scientific is shorter
        v_lit := v_lit_e;
      END IF;
      IF p_val < 0 AND p_paren_flag THEN                    -- add parenthesis
        v_lit := '(' || v_lit || ')';
      END IF;
      RETURN v_lit;
    END IF;
  END to_literal;

  ----------------------------------------------------------------------------
  --                               to_literal                               --
  ----------------------------------------------------------------------------
  -- NAME
  --   to_literal - varchar2 TO text LITERAL
  -- DESCRIPTION
  --   Converts varchar2 value to text literal. Setting literal flag to TRUE
  --   means that the input value is already a literal (return unchaged). When
  --   input value is NULL the string 'NULL' is returned irrespective of the 
  --   value of the literal flag.
  -- PARAMETERS
  --   p_val                          - varchar2 value
  --   p_lit_flag                     - literal flag
  -- RETURNS
  --   Text literal.
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Encloses the value in quotes and doubles the quotes inside if 
  --   necessary.
  ----------------------------------------------------------------------------
  FUNCTION to_literal(
    p_val                            VARCHAR2,
    p_lit_flag                       BOOLEAN DEFAULT FALSE)
  RETURN VARCHAR2
  IS
  BEGIN
    IF p_val IS NULL THEN
      RETURN 'NULL';
    ELSIF p_lit_flag THEN                                 -- already a literal
      RETURN p_val;
    ELSE
      RETURN '''' || REPLACE(p_val, '''', '''''') || '''';
    END IF;
  END to_literal;

  ----------------------------------------------------------------------------
  --                                 sdigit                                 --
  ----------------------------------------------------------------------------
  -- NAME
  --   sdigit - Significant DIGIT
  -- DESCRIPTION
  --   Finds the possition of the first (p_integer>0) or last (p_integer<=0)
  --   significant digit relative to the decimal point. Can be used in 
  --   conjunction with TRUNC or ROUND to truncate or round the significant
  --   digits.  
  -- PARAMETERS
  --   p_number                       - input number
  --   p_integer                      - number of significant digits
  -- RETURNS
  --   Position of the first/last significant digit.
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Returns NULL when at least one of the parameters is NULL.
  ----------------------------------------------------------------------------
  FUNCTION sdigit(
    p_number                       NUMBER,
    p_integer                      NUMBER DEFAULT 0)
  RETURN NUMBER
  IS
    v_shift                        NUMBER;
  BEGIN
    IF p_number IS NULL OR p_integer IS NULL THEN
      RETURN NULL;
    ELSIF p_number = 0 THEN
      RETURN 0;
    ELSE
      -- find the first significant digit
      --   Log computation for some numbers does not give desirable result, 
      --   thus overshooting followed by correction procedure is used to 
      --   overcome this problem.
      v_shift := -FLOOR(LOG(10,ABS(TO_BINARY_DOUBLE(p_number))));     -- guess
      v_shift := v_shift - 2;                                     -- overshoot
      WHILE TRUNC(p_number, v_shift) = 0 LOOP          -- correct overshooting
        v_shift := v_shift + 1;
      END LOOP;
      v_shift := v_shift - 1;            -- before the first significant digit

      -- find the last significant digit
      IF p_integer <= 0 THEN       -- move to after the last significant digit
        WHILE TRUNC(p_number, v_shift) != p_number LOOP
          v_shift := v_shift + 1;
        END LOOP;
      END IF;

      RETURN v_shift;
    END IF;
  END sdigit; 

  ----------------------------------------------------------------------------
  --                                 sround                                 --
  ----------------------------------------------------------------------------
  -- NAME
  --   sround - Significant digits ROUND
  -- DESCRIPTION
  --   Rounds p_number to p_integer places right of the point before the first
  --   significant digit (p_integer > 0) or left of the point after the last
  --   significant digit. When p_integer = 0 the result is always the same as
  --   the input p_number. When p_number or p_integer is NULL the result is 
  --   also NULL.
  -- PARAMETERS
  --   p_number                       - input number
  --   p_integer                      - number of significant digits
  -- RETURNS
  --   Rounded number.
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   None
  ----------------------------------------------------------------------------
  FUNCTION sround(
    p_number                       NUMBER,
    p_integer                      NUMBER)
  RETURN NUMBER
  IS
  BEGIN
    RETURN ROUND(p_number, sdigit(p_number, p_integer) + p_integer);
  END sround; 

  ----------------------------------------------------------------------------
  --                                tref_desc                               --
  ----------------------------------------------------------------------------
  -- NAME
  --   tref_desc - Table REFerence DESCribe
  -- DESCRIPTION
  --   Describes data table reference.
  -- PARAMETERS
  --   p_data_tref                    - DATA Table REFerence
  -- RETURNS
  --   r_desc_itab                    - DESCribe table
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   It is necessary to use two ls_append calls since p_data_tref can use
  --   all 32K of VARCHAR2 and thus 'SELECT * FROM ' || p_data_tref will not
  --   fit into 32K.
  ----------------------------------------------------------------------------
  PROCEDURE tref_desc(
    p_data_tref                    VARCHAR2,
    r_desc_itab                    OUT DESC_ITAB_TYPE)
  IS
    v_lstmt                        LSTMT_REC_TYPE;
  BEGIN
    ls_append(
      r_lstmt                        => v_lstmt,
      p_txt                          => 'SELECT * FROM ');
    ls_append(
      r_lstmt                        => v_lstmt,
      p_txt                          => p_data_tref);
    ls_desc(
      p_lstmt                        => v_lstmt,
      r_desc_itab                    => r_desc_itab);
  END tref_desc;

  ----------------------------------------------------------------------------
  --                               get_columns                              --
  ----------------------------------------------------------------------------
  -- NAME
  --   get_columns
  -- DESCRIPTION
  --   Finds a list of columns in the describe table (p_desc_itab) of the 
  --   given types (p_ctyp_ntab) not in the exclusion list (p_excl_varr) and
  --   in the inclusion list (p_incl_varr). NULL exclusion list is treated as
  --   an empty set (exclude none) and NULL inclusion list is treated as a
  --   full set (include all).
  -- PARAMETERS
  --   p_desc_itab                    - DESCribe table
  --   p_ctyp_ntab                    - Column TYPes
  --   p_excl_varr                    - EXCLusion columns
  --   p_incl_varr                    - INCLusion columns
  -- RETURNS
  --   r_incl_itab                    - INCLusion columns
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   None
  ----------------------------------------------------------------------------
  PROCEDURE get_columns(
    r_incl_itab                    OUT NOCOPY CIDEN_ITAB_TYPE,
    p_desc_itab                    DESC_ITAB_TYPE,
    p_ctyp_ntab                    NUM_NTAB_TYPE DEFAULT NULL,
    p_excl_varr                    IDEN_VARR_TYPE DEFAULT NULL,
    p_incl_varr                    IDEN_VARR_TYPE DEFAULT NULL)
  IS
    v_excl_atab                    CIDEN_ATAB_TYPE;       -- EXCLusion columns
    v_incl_atab                    CIDEN_ATAB_TYPE;       -- INCLusion columns
    v_col                          CIDEN_VCHAR_TYPE;
    v_num                          PLS_INTEGER;
  BEGIN
    -- get exlusion associative array ----------------------------------------
    IF p_excl_varr IS NOT NULL THEN
      FOR i IN 1..p_excl_varr.COUNT LOOP
        dbms_utility.canonicalize(
          name                           => p_excl_varr(i),
          canon_name                     => v_col,
          canon_len                      => c_canon_maxlen);
        IF v_col IS NOT NULL THEN                              -- ignore NULLs
          v_excl_atab(v_col) := 1;
        END IF;
      END LOOP;
    END IF;

    -- get inclusion associative array ---------------------------------------
    IF p_incl_varr IS NOT NULL THEN
      FOR i IN 1..p_incl_varr.COUNT LOOP
        dbms_utility.canonicalize(
          name                           => p_incl_varr(i),
          canon_name                     => v_col,
          canon_len                      => c_canon_maxlen);
        IF v_col IS NOT NULL THEN                              -- ignore NULLs
          v_incl_atab(v_col) := 1;
        END IF;
      END LOOP;
    END IF;
            
    -- get inclusion columns -------------------------------------------------
    v_num := 0;
    FOR i IN 1..p_desc_itab.COUNT LOOP
      v_col := p_desc_itab(i).col_name;
      IF (p_ctyp_ntab IS NULL                                      -- any type
          OR p_desc_itab(i).col_type MEMBER OF p_ctyp_ntab)      -- right type
         AND (p_excl_varr IS NULL                        -- nothing to exclude
              OR NOT v_excl_atab.EXISTS(v_col))                -- not excluded
         AND (p_incl_varr IS NULL                               -- include all
              OR v_incl_atab.EXISTS(v_col)) THEN                   -- included
        v_num := v_num + 1;
        r_incl_itab(v_num) := v_col;
      END IF;
    END LOOP;
  END get_columns;

  ----------------------------------------------------------------------------
  --                               get_columns                              --
  ----------------------------------------------------------------------------
  -- NAME
  --   get_columns
  -- DESCRIPTION
  --   Similar to the other version of get_columns with the exception of 
  --   taking table reference instead of descibe table.
  -- PARAMETERS
  --   p_data_tref                    - DATA Table REFerence
  --   p_ctyp_ntab                    - Column TYPes
  --   p_excl_varr                    - EXCLusion columns
  --   p_incl_varr                    - INCLusion columns
  -- RETURNS
  --   r_incl_itab                    - INCLusion columns
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   None
  ----------------------------------------------------------------------------
  PROCEDURE get_columns(
    r_incl_itab                    OUT NOCOPY CIDEN_ITAB_TYPE,
    p_data_tref                    VARCHAR2,
    p_ctyp_ntab                    NUM_NTAB_TYPE,
    p_excl_varr                    IDEN_VARR_TYPE DEFAULT NULL,
    p_incl_varr                    IDEN_VARR_TYPE DEFAULT NULL)
  IS
    v_desc_itab                    DESC_ITAB_TYPE;           -- DESCribe table
  BEGIN
    -- describe data table reference -----------------------------------------
    tref_desc(
      p_data_tref                    => p_data_tref,
      r_desc_itab                    => v_desc_itab);

    -- get columns -----------------------------------------------------------
    get_columns(
      r_incl_itab                    => r_incl_itab,
      p_desc_itab                    => v_desc_itab,
      p_ctyp_ntab                    => p_ctyp_ntab,
      p_excl_varr                    => p_excl_varr,
      p_incl_varr                    => p_incl_varr);
  END get_columns;

  ----------------------------------------------------------------------------
  --                              prep_stat_cursor                          --
  ----------------------------------------------------------------------------
  -- NAME
  --   prep_stat_cursor
  -- DESCRIPTION
  --   Forms, parses and defines the results of the statement for computing 
  --   column statistics (p_expr_ntab) such as min, max, avg, etc., for every
  --   column in the inclusion list (p_incl_itab) of the data table reference
  --   (p_data_tref). All results should be of type NUMBER (dtyp = 2) or
  --   VARCHAR2 (dtyp = 1) (i.e. the results should be convertable to NUMBER
  --   or VARCHAR2). When no data types are specified (p_dtyp_ntab) the
  --   default is NUMBER. For example, when inclusion list contains ('col1',
  --   'col2'), expression list ('min(:col)', 'max(:col) - min(:col)') and
  --   data table reference is 'my_tab', the following statement is generated:
  --     SELECT min("col1"), max("col1") - min("col1"), min("col2"),
  --            max("col2") - min("col2")
  --       FROM my_tab
  --   Generated expressions follow the order specified by, first inclusion 
  --   list, and then by expression list. For example, first col1, then col2,
  --   and within col1, first min, then max - min.
  -- PARAMETERS
  --   p_cur                          - dbms_sql CURsor
  --   p_data_tref                    - DATA Table REFerence
  --   p_incl_itab                    - INCLusion columns
  --   p_expr_ntab                    - EXPRessions
  --   p_dtyp_ntab                    - expression Data TYPes
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Both inclusion list and expression list should have at least one 
  --   element: p_incl_itab.COUNT > 0 and p_expr_ntab.COUNT > 0. p_data_tref
  --   needs its own ls_append because it can be exactly 32K. Pattern ":col"
  --   is case sensitive. Every occurance of ":col" in the expression is
  --   replaced with a column name (including literals). Expanded expressions
  --   should not exceed 32K. When p_dtyp_ntab is not NULL it should have the
  --   same number of elements as p_expr_ntab.
  ----------------------------------------------------------------------------
  PROCEDURE prep_stat_cursor(
    p_cur                          NUMBER,
    p_data_tref                    VARCHAR2,
    p_incl_itab                    CIDEN_ITAB_TYPE,
    p_expr_ntab                    STMT_NTAB_TYPE,
    p_dtyp_ntab                    NUM_NTAB_TYPE DEFAULT NULL)
  IS
    v_lstmt                        LSTMT_REC_TYPE;
    v_delim                        CHAR(1);                       -- DELIMiter
    v_col_number                   NUMBER;               -- NUMBER type define
    v_col_varchar2                 VARCHAR2(4000);     -- VARCHAR2 type define
  BEGIN
    -- form the statement ----------------------------------------------------
    ls_append(
      r_lstmt                        => v_lstmt,
      p_txt                          => 'SELECT');
    v_delim := ' ';
    FOR i IN 1..p_incl_itab.COUNT LOOP
      FOR j IN 1..p_expr_ntab.COUNT LOOP
        ls_append(
          r_lstmt                        => v_lstmt,
          p_txt                          =>
            v_delim || REPLACE(p_expr_ntab(j), ':col',
                               '"'||p_incl_itab(i)||'"'));
        v_delim := ',';
      END LOOP;
    END LOOP;
    ls_append(
      r_lstmt                        => v_lstmt,
      p_txt                          => ' FROM ');
    ls_append(
      r_lstmt                        => v_lstmt,
      p_txt                          => p_data_tref);
    
    -- prepare the statement -------------------------------------------------
    ls_parse(
      p_cur                          => p_cur,
      p_lstmt                        => v_lstmt);
    FOR i IN 1..p_incl_itab.COUNT LOOP
      FOR j IN 1..p_expr_ntab.COUNT LOOP
        IF p_dtyp_ntab IS NOT NULL AND p_dtyp_ntab(j) = 1 THEN
          dbms_sql.define_column(
            c                              => p_cur,                 -- Cursor
            position                       => (i - 1)*p_expr_ntab.COUNT + j, 
            column                         => v_col_varchar2,
            column_size                    => 4000);
        ELSE
          dbms_sql.define_column(
            c                              => p_cur,                 -- Cursor
            position                       => (i - 1)*p_expr_ntab.COUNT + j, 
            column                         => v_col_number);
        END IF;
      END LOOP;
    END LOOP;
  END prep_stat_cursor;

  ----------------------------------------------------------------------------
  --                         compute_norm_lin_minmax                        --
  ----------------------------------------------------------------------------
  -- NAME
  --   compute_norm_lin_minmax
  -- DESCRIPTION
  --   Computes min-max linear normalization xform definition.
  -- PARAMETERS
  --   p_data_tref                    - data table reference
  --   p_excl_varr                    - column exclusion list
  --   p_round_num                    - number of significant digits
  -- RETURNS
  --   r_norm_xdef                    - xform definition
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Ready to be used by ls_append_norm_lin.
  ----------------------------------------------------------------------------
  PROCEDURE compute_norm_lin_minmax(
    r_norm_xdef                    OUT NOCOPY NORM_LIN_REC_TYPE,
    p_data_tref                    VARCHAR2,
    p_excl_varr                    IDEN_VARR_TYPE DEFAULT NULL,
    p_round_num                    PLS_INTEGER DEFAULT 6)
  IS
    v_incl_itab                    CIDEN_ITAB_TYPE;       -- INCLusion columns
   
    v_cur                          INTEGER;                          -- CURsor
    v_cnt                          PLS_INTEGER;                       -- CouNT
    v_row                          NUMBER;
    v_min                          NUMBER;                    -- MINinum value
    v_max                          NUMBER;                    -- MAXimum value
  BEGIN
    -- get inclusion columns -------------------------------------------------
    get_columns(
      r_incl_itab                    => v_incl_itab,
      p_data_tref                    => p_data_tref,
      p_ctyp_ntab                    => c_num_ctyp_ntab,       -- number types
      p_excl_varr                    => p_excl_varr);
    IF v_incl_itab.COUNT = 0 THEN
      RETURN;                                           -- no relevant columns
    END IF;

    -- get data statistics ---------------------------------------------------
    v_cur := dbms_sql.open_cursor;
    prep_stat_cursor(
      p_cur                          => v_cur,
      p_data_tref                    => p_data_tref,
      p_incl_itab                    => v_incl_itab,
      p_expr_ntab                    => STMT_NTAB_TYPE(
                                          'MIN(:col)', 'MAX(:col)'));
    v_row := dbms_sql.execute_and_fetch(v_cur);                   -- v_row = 1
    
    -- compute xform definition ----------------------------------------------
    v_cnt := 0;
    FOR i IN 1..v_incl_itab.COUNT LOOP
      dbms_sql.column_value(v_cur, 2*i - 1, v_min);
      dbms_sql.column_value(v_cur, 2*i,     v_max);

      IF v_min IS NULL                                 -- all NULLs or no data
         OR v_min = v_max THEN                        -- only one unique value
        NULL;                                                        -- ignore
      ELSE
        v_cnt := v_cnt + 1;
        r_norm_xdef.col_itab(v_cnt)   := v_incl_itab(i);
        r_norm_xdef.shift_itab(v_cnt) := sround(v_min, p_round_num);
        r_norm_xdef.scale_itab(v_cnt) := sround(v_max - v_min, p_round_num);
      END IF;                                          
    END LOOP;
    r_norm_xdef.cnt := v_cnt;
    dbms_sql.close_cursor(v_cur);

  -- clean up ----------------------------------------------------------------
  EXCEPTION
    WHEN OTHERS THEN
      IF dbms_sql.is_open(v_cur) THEN
        dbms_sql.close_cursor(v_cur);
      END IF;
      RAISE;
  END compute_norm_lin_minmax;

  ----------------------------------------------------------------------------
  --                         compute_norm_lin_scale                         --
  ----------------------------------------------------------------------------
  -- NAME
  --   compute_norm_lin_scale
  -- DESCRIPTION
  --   Computes scaling linear normalization xform definition.
  -- PARAMETERS
  --   p_data_tref                    - data table reference
  --   p_excl_varr                    - column exclusion list
  --   p_round_num                    - number of significant digits
  -- RETURNS
  --   r_norm_xdef                    - xform definition
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Ready to be used by ls_append_norm_lin.
  ----------------------------------------------------------------------------
  PROCEDURE compute_norm_lin_scale(
    r_norm_xdef                    OUT NOCOPY NORM_LIN_REC_TYPE,
    p_data_tref                    VARCHAR2,
    p_excl_varr                    IDEN_VARR_TYPE DEFAULT NULL,
    p_round_num                    PLS_INTEGER DEFAULT 6)
  IS
    v_incl_itab                    CIDEN_ITAB_TYPE;       -- INCLusion columns
   
    v_cur                          INTEGER;                          -- CURsor
    v_cnt                          PLS_INTEGER;                       -- CouNT
    v_row                          NUMBER;
    v_min                          NUMBER;                    -- MINinum value
    v_max                          NUMBER;                    -- MAXimum value
  BEGIN
    -- get inclusion columns -------------------------------------------------
    get_columns(
      r_incl_itab                    => v_incl_itab,
      p_data_tref                    => p_data_tref,
      p_ctyp_ntab                    => c_num_ctyp_ntab,       -- number types
      p_excl_varr                    => p_excl_varr);
    IF v_incl_itab.COUNT = 0 THEN
      RETURN;                                           -- no relevant columns
    END IF;

    -- get data statistics ---------------------------------------------------
    v_cur := dbms_sql.open_cursor;
    prep_stat_cursor(
      p_cur                          => v_cur,
      p_data_tref                    => p_data_tref,
      p_incl_itab                    => v_incl_itab,
      p_expr_ntab                    => STMT_NTAB_TYPE(
                                          'MIN(:col)', 'MAX(:col)'));
    v_row := dbms_sql.execute_and_fetch(v_cur);                   -- v_row = 1
    
    -- compute xform definition ----------------------------------------------
    v_cnt := 0;
    FOR i IN 1..v_incl_itab.COUNT LOOP
      dbms_sql.column_value(v_cur, 2*i - 1, v_min);
      dbms_sql.column_value(v_cur, 2*i,     v_max);

      IF v_min IS NULL                                 -- all NULLs or no data
         OR (v_min = 0 AND v_max = 0) THEN                        -- all zeros
        NULL;                                                        -- ignore
      ELSE
        v_cnt := v_cnt + 1;
        r_norm_xdef.col_itab(v_cnt)   := v_incl_itab(i);
        r_norm_xdef.shift_itab(v_cnt) := 0;
        r_norm_xdef.scale_itab(v_cnt) := sround(
          p_number                       => greatest(abs(v_max), abs(v_min)),
          p_integer                      => p_round_num);
      END IF;                                          
    END LOOP;
    r_norm_xdef.cnt := v_cnt;
    dbms_sql.close_cursor(v_cur);

  -- clean up ----------------------------------------------------------------
  EXCEPTION
    WHEN OTHERS THEN
      IF dbms_sql.is_open(v_cur) THEN
        dbms_sql.close_cursor(v_cur);
      END IF;
      RAISE;
  END compute_norm_lin_scale;

  ----------------------------------------------------------------------------
  --                         compute_norm_lin_zscore                        --
  ----------------------------------------------------------------------------
  -- NAME
  --   compute_norm_lin_zscore
  -- DESCRIPTION
  --   Computes z-score linear normalization xform definition.
  -- PARAMETERS
  --   p_data_tref                    - data table reference
  --   p_excl_varr                    - column exclusion list
  --   p_round_num                    - number of significant digits
  -- RETURNS
  --   r_norm_xdef                    - xform definition
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Ready to be used by ls_append_norm_lin.
  ----------------------------------------------------------------------------
  PROCEDURE compute_norm_lin_zscore(
    r_norm_xdef                    OUT NOCOPY NORM_LIN_REC_TYPE,
    p_data_tref                    VARCHAR2,
    p_excl_varr                    IDEN_VARR_TYPE DEFAULT NULL,
    p_round_num                    PLS_INTEGER DEFAULT 6)
  IS
    v_incl_itab                    CIDEN_ITAB_TYPE;       -- INCLusion columns
    
    v_cur                          INTEGER;                          -- CURsor
    v_cnt                          PLS_INTEGER;                       -- CouNT
    v_row                          NUMBER;
    v_avg                          NUMBER;                    -- AVeraGe value
    v_dev                          NUMBER;               -- standard DEViation
  BEGIN
    -- get inclusion columns -------------------------------------------------
    get_columns(
      r_incl_itab                    => v_incl_itab,
      p_data_tref                    => p_data_tref,
      p_ctyp_ntab                    => c_num_ctyp_ntab,       -- number types
      p_excl_varr                    => p_excl_varr);
    IF v_incl_itab.COUNT = 0 THEN
      RETURN;                                           -- no relevant columns
    END IF;

    -- get data statistics ---------------------------------------------------
    v_cur := dbms_sql.open_cursor;
    prep_stat_cursor(
      p_cur                          => v_cur,
      p_data_tref                    => p_data_tref,
      p_incl_itab                    => v_incl_itab,
      p_expr_ntab                    => STMT_NTAB_TYPE(
                                          'AVG(:col)', 'STDDEV(:col)'));
    v_row := dbms_sql.execute_and_fetch(v_cur);                   -- v_row = 1
    
    -- compute xform definition ----------------------------------------------
    v_cnt := 0;
    FOR i IN 1..v_incl_itab.COUNT LOOP
      dbms_sql.column_value(v_cur, 2*i - 1, v_avg);
      dbms_sql.column_value(v_cur, 2*i,     v_dev);

      IF v_dev IS NULL                                 -- all NULLs or no data
         OR v_dev = 0 THEN                            -- only one unique value
        NULL;                                                        -- ignore
      ELSE
        v_cnt := v_cnt + 1;
        r_norm_xdef.col_itab(v_cnt)   := v_incl_itab(i);
        r_norm_xdef.shift_itab(v_cnt) := sround(v_avg, p_round_num);
        r_norm_xdef.scale_itab(v_cnt) := sround(v_dev, p_round_num);
      END IF;                                          
    END LOOP;
    r_norm_xdef.cnt := v_cnt;
    dbms_sql.close_cursor(v_cur);

  -- clean up ----------------------------------------------------------------
  EXCEPTION
    WHEN OTHERS THEN
      IF dbms_sql.is_open(v_cur) THEN
        dbms_sql.close_cursor(v_cur);
      END IF;
      RAISE;
  END compute_norm_lin_zscore;

  ----------------------------------------------------------------------------
  --                             insert_norm_lin                            --
  ----------------------------------------------------------------------------
  -- NAME
  --   insert_norm_lin
  -- DESCRIPTION
  --   Writes linear normalization definition into a table.
  -- PARAMETERS
  --   p_norm_texpr                   - xform table expression
  --   p_norm_xdef                    - xform definition
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   None
  ----------------------------------------------------------------------------
  PROCEDURE insert_norm_lin(
    p_norm_texpr                   VARCHAR2,
    p_norm_xdef                    NORM_LIN_REC_TYPE)
  IS
  BEGIN
    SAVEPOINT insert_norm_lin;            -- rollback here in case of an error
    FORALL i IN 1..p_norm_xdef.cnt
      EXECUTE IMMEDIATE
        'INSERT INTO '||p_norm_texpr||'('||
          'col, shift, scale) ' ||
        'VALUES (' ||
          ':1, :2, :3)'
      USING 
        p_norm_xdef.col_itab(i), 
        p_norm_xdef.shift_itab(i), 
        p_norm_xdef.scale_itab(i);
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO insert_norm_lin;
      RAISE;
  END insert_norm_lin;

  ----------------------------------------------------------------------------
  --                             select_norm_lin                            --
  ----------------------------------------------------------------------------
  -- NAME
  --   select_norm_lin
  -- DESCRIPTION
  --   Reads linear normalization definition from a table.
  -- PARAMETERS
  --   p_norm_tref                    - xform table reference
  -- RETURNS
  --   r_norm_xdef                    - xform definition
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Removes rows with NULL values in COL. Ready to be used by
  --   ls_append_norm_lin.
  ----------------------------------------------------------------------------
  PROCEDURE select_norm_lin(
    r_norm_xdef                    OUT NOCOPY NORM_LIN_REC_TYPE,
    p_norm_tref                    VARCHAR2)
  IS
  BEGIN
    EXECUTE IMMEDIATE
      'SELECT col, shift, scale '||
        'FROM '||p_norm_tref||' '||
       'WHERE col IS NOT NULL'                                 -- ignore NULLs
    BULK COLLECT INTO 
      r_norm_xdef.col_itab, r_norm_xdef.shift_itab, r_norm_xdef.scale_itab;
    r_norm_xdef.cnt := SQL%ROWCOUNT;
  END select_norm_lin;

  ----------------------------------------------------------------------------
  --                             ls_append_norm_lin                         --
  ----------------------------------------------------------------------------
  -- NAME
  --   ls_append_norm_lin - Long Statement APPEND NORMalization LINear xfrom
  -- DESCRIPTION
  --   Appends a SELECT statement performing linear normalization.
  -- PARAMETERS
  --   r_xform_lstmt                  - input query statement
  --   p_data_tref                    - data table reference
  --   p_norm_xdef                    - xform definition
  -- RETURNS
  --   r_xform_lstmt                  - output query statement
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   It is assumed that xform definition does not have entries with NULL
  --   values in COL.
  ----------------------------------------------------------------------------
  PROCEDURE ls_append_norm_lin(
    r_xform_lstmt                  IN OUT NOCOPY LSTMT_REC_TYPE,
    p_data_tref                    VARCHAR2,
    p_norm_xdef                    NORM_LIN_REC_TYPE)
  IS
    v_desc_itab                    DESC_ITAB_TYPE;           -- DESCribe table
    v_col_atab                     CIDEN_ATAB_TYPE;   -- COL associative array

    v_idx                          PLS_INTEGER;
    v_col                          CIDEN_VCHAR_TYPE;
    v_delim                        CHAR(1);                       -- DELIMiter
    v_shift                        STMT_VCHAR_TYPE;           -- SHIFT literal
    v_scale                        STMT_VCHAR_TYPE;           -- SCALE literal
  BEGIN
    -- form column associative array -----------------------------------------
    FOR i IN 1..p_norm_xdef.cnt LOOP
      v_col := p_norm_xdef.col_itab(i);
      v_col_atab(v_col) := i;
    END LOOP;
            
    -- describe data table ---------------------------------------------------
    tref_desc(
      p_data_tref                    => p_data_tref,
      r_desc_itab                    => v_desc_itab);

    -- form the statement ----------------------------------------------------
    ls_append(
      r_lstmt                        => r_xform_lstmt,
      p_txt                          => 'SELECT');
    v_delim := ' ';    
    FOR i IN 1..v_desc_itab.COUNT LOOP
      v_col := v_desc_itab(i).col_name;
      IF v_col_atab.EXISTS(v_col) THEN                            -- normalize
        v_idx := v_col_atab(v_col);
        v_shift := to_literal(p_norm_xdef.shift_itab(v_idx));
        v_scale := to_literal(p_norm_xdef.scale_itab(v_idx));
        ls_append(
          r_lstmt                        => r_xform_lstmt,
          p_txt                          =>
            v_delim||'("'||v_col||'"-'||v_shift||')/'||v_scale||' '||
                      '"'||v_col||'"');
      ELSE                                                    -- carry forward
        ls_append(
          r_lstmt                        => r_xform_lstmt,
          p_txt                          =>
            v_delim||'"'||v_col||'"');
      END IF;
      v_delim := ',';
    END LOOP;
    ls_append(
      r_lstmt                        => r_xform_lstmt,
      p_txt                          => ' FROM ');
    ls_append(
      r_lstmt                        => r_xform_lstmt,
      p_txt                          => p_data_tref);
  END ls_append_norm_lin;

  ----------------------------------------------------------------------------
  --                          append_bin_num_eqwidth                        --
  ----------------------------------------------------------------------------
  -- NAME
  --   append_bin_num_eqwidth
  -- DESCRIPTION
  --   Computes and appends equi-width numerical binning xform definition for
  --   a given column.
  -- PARAMETERS
  --   r_bin_xdef                     - xform definition
  --   p_col                          - column name
  --   p_min                          - minimum value
  --   p_max                          - maximum value
  --   p_bin_num                      - number of bins
  --   p_round_num                    - number of significant digits
  -- RETURNS
  --   r_bin_xdef                     - xform definition
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Xform definition is oredered by VAL in ascending order.
  ----------------------------------------------------------------------------
  PROCEDURE append_bin_num_eqwidth(
    r_bin_xdef                     IN OUT NOCOPY BIN_NUM_REC_TYPE,
    p_col                          VARCHAR2,
    p_min                          NUMBER,
    p_max                          NUMBER,
    p_bin_num                      PLS_INTEGER,
    p_round_num                    PLS_INTEGER)
  IS
    v_cnt                          PLS_INTEGER;                       -- CouNT
    v_bin                          PLS_INTEGER;                 -- current BIN
    v_bin_abs                      PLS_INTEGER;              -- ABS(p_bin_num)
    v_bin_ini                      PLS_INTEGER;          -- INItial BIN number
    v_bin_inc                      PLS_INTEGER;               -- BIN INCrement
    v_val                          NUMBER;                    -- current VALue
    v_val_inc                      NUMBER;                  -- VALue INCrement
  BEGIN
    -- verify parameters -----------------------------------------------------
    IF p_min IS NULL                                   -- all NULLs or no data
       OR p_min = p_max THEN                          -- only one unique value
      RETURN;
    END IF;

    -- init variables --------------------------------------------------------
    v_bin_abs := ABS(p_bin_num);
    v_bin_inc := SIGN(p_bin_num);                     -- +1 (N>0), or -1 (N<0)
    v_bin_ini := (CASE WHEN p_bin_num > 0 THEN 0 ELSE v_bin_abs + 1 END);
    v_val_inc := (p_max - p_min) / v_bin_abs;

    -- compute and append ----------------------------------------------------
    v_cnt := r_bin_xdef.cnt;
    v_val := p_min;
    v_bin := v_bin_ini;
    FOR j IN 0..v_bin_abs LOOP
      v_cnt := v_cnt + 1;
      r_bin_xdef.col_itab(v_cnt) := p_col;
      r_bin_xdef.val_itab(v_cnt) := sround(v_val, p_round_num);
      r_bin_xdef.bin_itab(v_cnt) := v_bin;

      v_val := v_val + v_val_inc;
      v_bin := v_bin + v_bin_inc;
    END LOOP;
    r_bin_xdef.val_itab(v_cnt) := sround(p_max, p_round_num);    -- M!=m+inc*N
    r_bin_xdef.bin_itab(v_cnt - v_bin_abs) := NULL;     -- default bin (j = 0)
    r_bin_xdef.cnt := v_cnt;
  END append_bin_num_eqwidth;

  ----------------------------------------------------------------------------
  --                         compute_bin_num_eqwidth                        --
  ----------------------------------------------------------------------------
  -- NAME
  --   compute_bin_num_eqwidth
  -- DESCRIPTION
  --   Computes equi-width numerical binning xform definition.
  -- PARAMETERS
  --   p_data_tref                    - data table reference
  --   p_bin_num                      - number of bins
  --   p_excl_varr                    - column exclusion list
  --   p_round_num                    - number of significant digits
  -- RETURNS
  --   r_bin_xdef                     - xform definition
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Xform definition is clustered by COL and each cluster is oredered by
  --   VAL in ascending order. Ready to be used by ls_append_bin_num.
  ----------------------------------------------------------------------------
  PROCEDURE compute_bin_num_eqwidth(
    r_bin_xdef                     OUT NOCOPY BIN_NUM_REC_TYPE,
    p_data_tref                    VARCHAR2,
    p_bin_num                      PLS_INTEGER DEFAULT 10,
    p_excl_varr                    IDEN_VARR_TYPE DEFAULT NULL,
    p_round_num                    PLS_INTEGER DEFAULT 6)
  IS
    v_incl_itab                    CIDEN_ITAB_TYPE;       -- INCLusion columns
    v_cur                          INTEGER;                          -- CURsor
    v_row                          NUMBER;
    v_min                          NUMBER;                    -- MINimum value
    v_max                          NUMBER;                    -- MAXimum value
  BEGIN
    -- verify parameters -----------------------------------------------------
    IF p_bin_num IS NULL OR p_bin_num = 0 THEN
      RETURN;                                                 -- nothing to do
    END IF;

    -- get inclusion columns -------------------------------------------------
    get_columns(
      r_incl_itab                    => v_incl_itab,
      p_data_tref                    => p_data_tref,
      p_ctyp_ntab                    => c_num_ctyp_ntab,       -- number types
      p_excl_varr                    => p_excl_varr);
    IF v_incl_itab.COUNT = 0 THEN
      RETURN;                                           -- no relevant columns
    END IF;
    
    -- get data statistics ---------------------------------------------------
    v_cur := dbms_sql.open_cursor;
    prep_stat_cursor(
      p_cur                          => v_cur,
      p_data_tref                    => p_data_tref,
      p_incl_itab                    => v_incl_itab,
      p_expr_ntab                    => STMT_NTAB_TYPE(
                                          'MIN(:col)', 'MAX(:col)'));
    v_row := dbms_sql.execute_and_fetch(v_cur);                   -- v_row = 1

    -- compute xform definition ----------------------------------------------
    FOR i IN 1..v_incl_itab.COUNT LOOP
      dbms_sql.column_value(v_cur, 2*i - 1, v_min);
      dbms_sql.column_value(v_cur, 2*i,     v_max);

      append_bin_num_eqwidth(
        r_bin_xdef                     => r_bin_xdef,
        p_col                          => v_incl_itab(i),
        p_min                          => v_min,
        p_max                          => v_max,
        p_bin_num                      => p_bin_num,
        p_round_num                    => p_round_num);
    END LOOP;
    dbms_sql.close_cursor(v_cur);

  -- clean up ----------------------------------------------------------------
  EXCEPTION
    WHEN OTHERS THEN
      IF dbms_sql.is_open(v_cur) THEN
        dbms_sql.close_cursor(v_cur);
      END IF;
      RAISE;
  END compute_bin_num_eqwidth;

  ----------------------------------------------------------------------------
  --                      compute_bin_num_eqwidth_auto                      --
  ----------------------------------------------------------------------------
  -- NAME
  --   compute_bin_num_eqwidth_auto
  -- DESCRIPTION
  --   Estimates number of bins for every column based on the data and then
  --   computes equi-width numerical binning xform definition.
  -- PARAMETERS
  --   p_data_tref                    - data table reference
  --   p_min_bin                      - minimum number of bins
  --   p_max_bin                      - maximum number of bins
  --   p_excl_varr                    - column exclusion list
  --   p_round_num                    - number of significant digits
  --   p_sample_size                  - sample size
  --   p_bin_coef                     - calibrating coefficient C
  -- RETURNS
  --   r_bin_xdef                     - xform definition
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Xform definition is clustered by COL and each cluster is oredered by
  --   VAL in ascending order. Ready to be used by ls_append_bin_num.
  ----------------------------------------------------------------------------
  PROCEDURE compute_bin_num_eqwidth_auto(
    r_bin_xdef                     OUT NOCOPY BIN_NUM_REC_TYPE,
    p_data_tref                    VARCHAR2,
    p_min_bin                      PLS_INTEGER DEFAULT 3,
    p_max_bin                      PLS_INTEGER DEFAULT 100,
    p_excl_varr                    IDEN_VARR_TYPE DEFAULT NULL,
    p_round_num                    PLS_INTEGER DEFAULT 6,
    p_sample_size                  PLS_INTEGER DEFAULT 50000,
    p_bin_coef                     NUMBER DEFAULT 3.49/0.9)
  IS
    v_incl_itab                    CIDEN_ITAB_TYPE;       -- INCLusion columns
    v_cur                          INTEGER;                          -- CURsor
    v_row                          NUMBER;
    v_min                          NUMBER;                    -- MINimum value
    v_max                          NUMBER;                    -- MAXimum value
    v_dev                          NUMBER;               -- standard DEViation
    v_cnt                          NUMBER;                       -- data CouNT
    v_dty                          NUMBER;   -- Data TYpe (continuos/discrete)
    v_bin_num                      PLS_INTEGER;    -- estimated NUMber of BINs
  BEGIN
    -- verify parameters -----------------------------------------------------
    IF p_bin_coef IS NULL OR p_bin_coef = 0 THEN
      RETURN;                                                 -- nothing to do
    END IF;

    -- get inclusion columns -------------------------------------------------
    get_columns(
      r_incl_itab                    => v_incl_itab,
      p_data_tref                    => p_data_tref,
      p_ctyp_ntab                    => c_num_ctyp_ntab,       -- number types
      p_excl_varr                    => p_excl_varr);
    IF v_incl_itab.COUNT = 0 THEN
      RETURN;                                           -- no relevant columns
    END IF;

    -- get data statistics ---------------------------------------------------
    --   Columns with sign(sum(abs(:col - trunc(:col)))) = 1 have non-integer
    --   values and thus are treated as continues. Value 0 indicates that all
    --   values of the column are integers and the column is treated as
    --   discrete.
    v_cur := dbms_sql.open_cursor;
    prep_stat_cursor(
      p_cur                          => v_cur,
      p_data_tref                    => p_data_tref,
      p_incl_itab                    => v_incl_itab,
      p_expr_ntab                    => STMT_NTAB_TYPE(
                                         'MIN(:col)', 'MAX(:col)',
                                         'STDDEV(:col)', 'COUNT(:col)',
                                         'SIGN(SUM(ABS(:col-TRUNC(:col))))'));
    v_row := dbms_sql.execute_and_fetch(v_cur);                   -- v_row = 1

    -- compute xform definition ----------------------------------------------
    FOR i IN 1..v_incl_itab.COUNT LOOP
      dbms_sql.column_value(v_cur, 5*i - 4, v_min);
      dbms_sql.column_value(v_cur, 5*i - 3, v_max);
      dbms_sql.column_value(v_cur, 5*i - 2, v_dev);
      dbms_sql.column_value(v_cur, 5*i - 1, v_cnt);
      dbms_sql.column_value(v_cur, 5*i,     v_dty);

      -- compute number of bins ----------------------------------------------
      IF v_dev IS NULL                                 -- all NULLs or no data
         OR v_dev = 0 THEN                            -- only one unique value
        v_bin_num := NULL;                                           -- ignore
      ELSE
        -- sample size adjustment
        v_cnt := (CASE WHEN NVL(p_sample_size, 0) = 0 THEN v_cnt
                       ELSE LEAST(v_cnt, ABS(p_sample_size)) END);

        -- number of bins
        v_bin_num := FLOOR(
          POWER(v_cnt, 1/3) * (v_max - v_min) / (ABS(p_bin_coef) * v_dev));

        -- min bin number adjustment
        v_bin_num := (CASE WHEN NVL(p_min_bin, 0) = 0 THEN v_bin_num
                           ELSE GREATEST(v_bin_num, ABS(p_min_bin)) END);

        -- max bin number adjustment
        v_bin_num := (CASE WHEN NVL(p_max_bin, 0) = 0 THEN v_bin_num
                           ELSE LEAST(v_bin_num, ABS(p_max_bin)) END);

        -- max bin number adjustment for discrete columns
        --   For discrete columns the number of bins is limited by the number
        --   of distint values in the range (max - min + 1)
        v_bin_num := (CASE WHEN v_dty = c_dty_continuos THEN v_bin_num
                           ELSE LEAST(v_max - v_min + 1, v_bin_num) END);
      END IF;

      -- append and compute xform definition ---------------------------------
      append_bin_num_eqwidth(
        r_bin_xdef                     => r_bin_xdef,
        p_col                          => v_incl_itab(i),
        p_min                          => v_min,
        p_max                          => v_max,
        p_bin_num                      => SIGN(p_bin_coef)*v_bin_num,
        p_round_num                    => p_round_num);
    END LOOP;
    dbms_sql.close_cursor(v_cur);

  -- clean up ----------------------------------------------------------------
  EXCEPTION
    WHEN OTHERS THEN
      IF dbms_sql.is_open(v_cur) THEN
        dbms_sql.close_cursor(v_cur);
      END IF;
      RAISE;
  END compute_bin_num_eqwidth_auto;

  ----------------------------------------------------------------------------
  --                         compute_bin_num_qtile                          --
  ----------------------------------------------------------------------------
  -- NAME
  --   compute_bin_num_qtile
  -- DESCRIPTION
  --   Computes quantile numerical binning xform definition.
  -- PARAMETERS
  --   p_data_tref                    - data table reference
  --   p_bin_num                      - number of bins
  --   p_excl_varr                    - column exclusion list
  -- RETURNS
  --   r_bin_xdef                     - xform definition
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Xform definition is clustered by COL and each cluster is oredered by
  --   VAL in ascending order. Ready to be used by ls_append_bin_num.
  ----------------------------------------------------------------------------
  PROCEDURE compute_bin_num_qtile(
    r_bin_xdef                     OUT NOCOPY BIN_NUM_REC_TYPE,
    p_data_tref                    VARCHAR2,
    p_bin_num                      PLS_INTEGER DEFAULT 10,
    p_excl_varr                    IDEN_VARR_TYPE DEFAULT NULL)
  IS
    v_incl_itab                    CIDEN_ITAB_TYPE;       -- INCLusion columns
    v_min_itab                     NUM_ITAB_TYPE;      -- MINimum qtile values
    v_max_itab                     NUM_ITAB_TYPE;      -- MAXimum qtile values

    v_stmt                         STMT_VCHAR_TYPE;
    v_num                          PLS_INTEGER;            -- NUMber of qtiles
    v_cnt                          PLS_INTEGER;                       -- CouNT
    v_bin                          PLS_INTEGER;              -- number of BINs
  BEGIN
    -- verify parameters -----------------------------------------------------
    IF p_bin_num IS NULL OR p_bin_num = 0 THEN
      RETURN;                                                 -- nothing to do
    END IF;

    -- get inclusion columns -------------------------------------------------
    get_columns(
      r_incl_itab                    => v_incl_itab,
      p_data_tref                    => p_data_tref,
      p_ctyp_ntab                    => c_num_ctyp_ntab,       -- number types
      p_excl_varr                    => p_excl_varr);
    IF v_incl_itab.COUNT = 0 THEN
      RETURN;                                           -- no relevant columns
    END IF;
    
    -- statement template ----------------------------------------------------
    v_stmt :=
      'SELECT MIN(val), MAX(val) '||
        'FROM (SELECT "%col%" val,'||
                     'NTILE('||TO_CHAR(ABS(p_bin_num))||') OVER('||
                       'ORDER BY "%col%" ASC) qtile '||
                'FROM '||p_data_tref||' '||
               'WHERE "%col%" IS NOT NULL) '||
       'GROUP BY qtile '||
       'ORDER BY qtile ASC';

    -- compute xform definition ----------------------------------------------
    v_cnt := 0;
    FOR i IN 1..v_incl_itab.COUNT LOOP
      v_min_itab.DELETE;
      v_max_itab.DELETE;
      EXECUTE IMMEDIATE
        REPLACE(v_stmt, '%col%', v_incl_itab(i))
      BULK COLLECT INTO v_min_itab, v_max_itab;

      v_num := SQL%ROWCOUNT;
      IF v_num = 0                                     -- all NULLs or no data
         OR v_min_itab(1) = v_max_itab(v_num) THEN    -- only one unique value
        NULL;                                                        -- ignore
      ELSE
        v_min_itab(v_num+1) := v_max_itab(v_num);
        v_bin := -1;
        FOR j IN 1..v_num+1 LOOP
          IF j > 1 AND v_min_itab(j) = v_min_itab(j-1) THEN
            NULL;                                                  -- collapse
          ELSE
            v_cnt := v_cnt + 1;
            v_bin := v_bin + 1;
            r_bin_xdef.col_itab(v_cnt) := v_incl_itab(i);
            r_bin_xdef.val_itab(v_cnt) := v_min_itab(j);
            r_bin_xdef.bin_itab(v_cnt) := NULLIF(v_bin, 0);    -- NULL default
          END IF;
        END LOOP;  
        
        IF p_bin_num < 0 THEN                           -- reverse bin numbers
          FOR j IN 1..v_bin LOOP
            r_bin_xdef.bin_itab(v_cnt-v_bin+j) := v_bin-j+1;
          END LOOP;
        END IF;
      END IF;
    END LOOP;
    r_bin_xdef.cnt := v_cnt;
  END compute_bin_num_qtile;

  ----------------------------------------------------------------------------
  --                             insert_bin_num                             --
  ----------------------------------------------------------------------------
  -- NAME
  --   insert_bin_num
  -- DESCRIPTION
  --   Writes numerical binning definition into a table.
  -- PARAMETERS
  --   p_bin_texpr                    - xform table expression
  --   p_bin_xdef                     - xform definition
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   None
  ----------------------------------------------------------------------------
  PROCEDURE insert_bin_num(
    p_bin_texpr                    VARCHAR2,
    p_bin_xdef                     BIN_NUM_REC_TYPE)
  IS
  BEGIN
    SAVEPOINT insert_bin_num;             -- rollback here in case of an error
    FORALL i IN 1..p_bin_xdef.cnt
      EXECUTE IMMEDIATE
        'INSERT INTO '||p_bin_texpr||'('||
          'col, val, bin) ' ||
        'VALUES (' ||
          ':1, :2, :3)'
      USING 
        p_bin_xdef.col_itab(i),
        p_bin_xdef.val_itab(i),
        p_bin_xdef.bin_itab(i);
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO insert_bin_num;
      RAISE;
  END insert_bin_num;

  ----------------------------------------------------------------------------
  --                             select_bin_num                             --
  ----------------------------------------------------------------------------
  -- NAME
  --   select_bin_num
  -- DESCRIPTION
  --   Reads numerical binning definition from a table.
  -- PARAMETERS
  --   p_bin_tref                     - xform table reference
  -- RETURNS
  --   r_bin_xdef                     - xform definition
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Removes rows with NULL values in COL. Clusters by COL. Each cluster is
  --   ordered by VAL in ascending order with default bin comming last. Ready
  --   to used by ls_append_bin_num.
  ----------------------------------------------------------------------------
  PROCEDURE select_bin_num(
    r_bin_xdef                     OUT NOCOPY BIN_NUM_REC_TYPE,
    p_bin_tref                     VARCHAR2)
  IS
  BEGIN
    EXECUTE IMMEDIATE
      'SELECT col, val, bin '||
        'FROM '||p_bin_tref||' '||
       'WHERE col IS NOT NULL '||                       -- ignore NULLs in COL
       'ORDER BY col ASC,'||                                 -- cluster by COL
                'val ASC NULLS LAST'                           -- order by VAL
    BULK COLLECT INTO
      r_bin_xdef.col_itab, r_bin_xdef.val_itab, r_bin_xdef.bin_itab;
    r_bin_xdef.cnt := SQL%ROWCOUNT;
  END select_bin_num;

  ----------------------------------------------------------------------------
  --                             ls_append_bin_num                          --
  ----------------------------------------------------------------------------
  -- NAME
  --   ls_append_bin_num - Long Statement APPEND BINning NUMerical xfrom
  -- DESCRIPTION
  --   Appends a SELECT statement performing numerical binning.
  -- PARAMETERS
  --   r_xform_lstmt                  - input query statement
  --   p_data_tref                    - data table reference
  --   p_bin_xdef                     - xform definition
  --   p_lit_flag                     - literal flag
  -- RETURNS
  --   r_xform_lstmt                  - output query statement
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   It is assumed that xform definition does not have entries with NULL
  --   values in COL, and it is clustered by COL, and each cluster is ordered
  --   by VAL in ascending order with default bin comming last (if any).
  ----------------------------------------------------------------------------
  PROCEDURE ls_append_bin_num(
    r_xform_lstmt                  IN OUT NOCOPY LSTMT_REC_TYPE,
    p_data_tref                    VARCHAR2,
    p_bin_xdef                     BIN_NUM_REC_TYPE,
    p_lit_flag                     BOOLEAN DEFAULT FALSE)
  IS
    v_desc_itab                    DESC_ITAB_TYPE;           -- DESCribe table
    v_col_atab                     CIDEN_ATAB_TYPE;   -- COL associative array

    v_idx                          PLS_INTEGER;
    v_col                          CIDEN_VCHAR_TYPE;
    v_val                          STMT_VCHAR_TYPE;             -- VAL literal
    v_bin                          STMT_VCHAR_TYPE;             -- BIN literal
    v_cmp                          CHAR(1);             -- CoMParison operator
    v_delim                        CHAR(1);                       -- DELIMiter
  BEGIN
    -- form column associative array -----------------------------------------
    v_col := NULL;
    FOR i IN 1..p_bin_xdef.cnt LOOP
      IF i = 1 OR p_bin_xdef.col_itab(i) != v_col THEN    -- start new cluster
        v_col := p_bin_xdef.col_itab(i);
        v_col_atab(v_col) := i;
      END IF;
    END LOOP;

    -- describe data table ---------------------------------------------------
    tref_desc(
      p_data_tref                    => p_data_tref,
      r_desc_itab                    => v_desc_itab);

    -- form the statement ----------------------------------------------------
    ls_append(
      r_lstmt                        => r_xform_lstmt,
      p_txt                          => 'SELECT');
    v_delim := ' ';
    FOR i IN 1..v_desc_itab.COUNT LOOP
      v_col := v_desc_itab(i).col_name;
      IF v_col_atab.EXISTS(v_col) THEN                                  -- bin
        v_idx := v_col_atab(v_col);                -- beginning of the cluster
        ls_append(
          r_lstmt                        => r_xform_lstmt,
          p_txt                          => v_delim||'CASE');
        v_cmp := ' ';                        -- first boundary is not included
        WHILE v_idx <= p_bin_xdef.cnt                             -- in bounds
              AND p_bin_xdef.col_itab(v_idx) = v_col             -- in cluster
              AND p_bin_xdef.val_itab(v_idx) IS NOT NULL LOOP   -- not def bin
          v_val := to_literal(p_bin_xdef.val_itab(v_idx));
          v_bin := to_literal(p_bin_xdef.bin_itab(v_idx), p_lit_flag);
          ls_append(
            r_lstmt                        => r_xform_lstmt,
            p_txt                          =>
              ' WHEN "'||v_col||'"<'||v_cmp||v_val||' THEN '||v_bin);
          v_cmp := '=';             -- all but the first boundary are included
          v_idx := v_idx + 1;
        END LOOP;
        IF v_idx <= p_bin_xdef.cnt                                -- in bounds
           AND p_bin_xdef.col_itab(v_idx) = v_col                -- in cluster
           AND p_bin_xdef.val_itab(v_idx) IS NULL THEN          -- default bin
          v_bin := to_literal(p_bin_xdef.bin_itab(v_idx), p_lit_flag);
          ls_append(
            r_lstmt                        => r_xform_lstmt,
            p_txt                          =>
              ' WHEN "'||v_col||'" IS NOT NULL THEN '||v_bin);
        END IF;
        ls_append(
          r_lstmt                        => r_xform_lstmt,
          p_txt                          => ' END "'||v_col||'"');
      ELSE                                                    -- carry forward
        ls_append(
          r_lstmt                        => r_xform_lstmt,
          p_txt                          =>
            v_delim||'"'||v_col||'"');
      END IF;
      v_delim := ',';
    END LOOP;
    ls_append(
      r_lstmt                        => r_xform_lstmt,
      p_txt                          => ' FROM ');
    ls_append(
      r_lstmt                        => r_xform_lstmt,
      p_txt                          => p_data_tref);
  END ls_append_bin_num;

  ----------------------------------------------------------------------------
  --                          compute_bin_cat_freq                          --
  ----------------------------------------------------------------------------
  -- NAME
  --   compute_bin_cat_freq
  -- DESCRIPTION
  --   Computes frequency-based categorical binning xform definition.
  -- PARAMETERS
  --   p_data_tref                    - data table reference
  --   p_bin_num                      - number of bins
  --   p_excl_varr                    - column exclusion list
  --   p_def_num                      - number of default values
  -- RETURNS
  --   r_norm_xdef                    - xform definition
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Xform definition is clustered by COL and each cluster is ordered by
  --   VAL in ascending order with dafault value (VAL IS NULL) comming last.
  --   Ready to be used by ls_append_bin_cat.
  ----------------------------------------------------------------------------
  PROCEDURE compute_bin_cat_freq(
    r_bin_xdef                     OUT NOCOPY BIN_CAT_REC_TYPE,
    p_data_tref                    VARCHAR2,
    p_bin_num                      PLS_INTEGER DEFAULT 9,
    p_excl_varr                    IDEN_VARR_TYPE DEFAULT NULL,
    p_def_num                      PLS_INTEGER DEFAULT 2,
    p_bin_sup                      NUMBER DEFAULT NULL)
  IS
    v_incl_itab                    CIDEN_ITAB_TYPE;       -- INCLusion columns
    v_temp_itab                    STR_ITAB_TYPE; -- TEMP bin values (one col)

    v_sort_rnk                     STMT_VCHAR_TYPE;
    v_expr_cnt                     STMT_VCHAR_TYPE;
    v_expr_tot                     STMT_VCHAR_TYPE;
    v_expr_bin                     STMT_VCHAR_TYPE;
    v_filt_cnt                     STMT_VCHAR_TYPE;
    v_filt_frq                     STMT_VCHAR_TYPE;
    v_stmt_val                     STMT_VCHAR_TYPE;
    v_num                          PLS_INTEGER;
    v_cnt                          PLS_INTEGER;
  BEGIN
    -- verify parameters -----------------------------------------------------
    IF p_bin_num IS NULL OR p_bin_num = 0 THEN
      RETURN;                                                 -- nothing to do
    END IF;
    
    -- get inclusion columns -------------------------------------------------
    get_columns(
      r_incl_itab                    => v_incl_itab,
      p_data_tref                    => p_data_tref,
      p_ctyp_ntab                    => c_str_ctyp_ntab,       -- string types
      p_excl_varr                    => p_excl_varr);
    IF v_incl_itab.COUNT = 0 THEN
      RETURN;                                           -- no relevant columns
    END IF;

    -- bin support filtering -------------------------------------------------
    IF p_bin_sup IS NULL OR p_bin_sup = 0 THEN              -- ignore prunning
      v_expr_tot := NULL;
      v_filt_frq := NULL;
      v_expr_bin := ','||TO_CHAR(ABS(p_bin_num))||' bin';
    ELSIF p_bin_sup > 0 THEN                                   -- at least SUP
      v_expr_tot := ',SUM(frq) OVER() tot';
      v_filt_frq := ' WHERE frq >= tot*'||to_literal(p_bin_sup);
      v_expr_bin := ',LEAST('||TO_CHAR(ABS(p_bin_num))||','||
                            'COUNT(*) OVER()) bin';
    ELSE                                                        -- at most SUP
      v_expr_tot := ',SUM(frq) OVER() tot';
      v_filt_frq := ' WHERE frq <= tot*'||to_literal(-p_bin_sup);
      v_expr_bin := ',LEAST('||TO_CHAR(ABS(p_bin_num))||','||
                            'COUNT(*) OVER()) bin';
    END IF;

    -- default bin filtering -------------------------------------------------
    IF p_def_num IS NULL OR p_def_num = 0 THEN              -- ignore prunning
      v_expr_cnt := NULL;
      v_filt_cnt := NULL;
    ELSIF p_def_num > 0 THEN                            -- at least D defaults
      v_expr_cnt := ',COUNT(*) OVER() cnt';
      v_filt_cnt := ' WHERE cnt >= bin+'||TO_CHAR(p_def_num);
    ELSE                                                 -- at most D defaults
      v_expr_cnt := ',COUNT(*) OVER() cnt';
      v_filt_cnt := ' WHERE cnt <= bin+'||TO_CHAR(-p_def_num);
    END IF;

    -- frequency sorting -----------------------------------------------------
    IF p_bin_num > 0 THEN                                   -- top frequencies
      v_sort_rnk := 'frq DESC, val ASC';
    ELSE                                                 -- bottom frequencies
      v_sort_rnk := 'frq ASC, val DESC';
    END IF;

    -- statement template ----------------------------------------------------
    v_stmt_val :=
     'SELECT val '||
       'FROM (SELECT val '|| 
               'FROM (SELECT t2.* '||
                             v_expr_bin||' '||
                       'FROM (SELECT t1.* '||
                                     v_expr_cnt||
                                     v_expr_tot||' '||
                               'FROM (SELECT "%col%" val,'||
                                            'COUNT(*) frq '||
                                       'FROM '||p_data_tref||' '||
                                      'GROUP BY "%col%" '||
                                     'HAVING "%col%" IS NOT NULL) t1) t2 '||
                       v_filt_frq||')'||
               v_filt_cnt||' '||
              'ORDER BY '||v_sort_rnk||') '||
      'WHERE rownum <= '||TO_CHAR(ABS(p_bin_num));

    -- compute xform definition ----------------------------------------------
    v_cnt := 0;
    FOR i IN 1..v_incl_itab.COUNT LOOP
      v_temp_itab.DELETE;
      EXECUTE IMMEDIATE
        REPLACE(v_stmt_val, '%col%', v_incl_itab(i))
      BULK COLLECT INTO v_temp_itab;

      v_num := v_temp_itab.COUNT;
      IF v_num > 0 THEN
        v_temp_itab(v_num+1) := NULL;                          -- overflow bin
        FOR j IN 1..v_num+1 LOOP
          v_cnt := v_cnt + 1;
          r_bin_xdef.col_itab(v_cnt) := v_incl_itab(i);
          r_bin_xdef.val_itab(v_cnt) := v_temp_itab(j);
          r_bin_xdef.bin_itab(v_cnt) := j;
        END LOOP;
      END IF;
    END LOOP;
    r_bin_xdef.cnt := v_cnt;
  END compute_bin_cat_freq;
 
  ----------------------------------------------------------------------------
  --                             insert_bin_cat                             --
  ----------------------------------------------------------------------------
  -- NAME
  --   insert_bin_cat
  -- DESCRIPTION
  --   Writes categorical binning definition into a table.
  -- PARAMETERS
  --   p_bin_texpr                    - xform table expression
  --   p_bin_xdef                     - xform definition
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   None
  ----------------------------------------------------------------------------
  PROCEDURE insert_bin_cat(
    p_bin_texpr                    VARCHAR2,
    p_bin_xdef                     BIN_CAT_REC_TYPE)
  IS
  BEGIN
    SAVEPOINT insert_bin_cat;             -- rollback here in case of an error
    FORALL i IN 1..p_bin_xdef.cnt
      EXECUTE IMMEDIATE
        'INSERT INTO '||p_bin_texpr||'('||
          'col, val, bin) ' ||
        'VALUES (' ||
          ':1, :2, :3)'
      USING 
        p_bin_xdef.col_itab(i),
        p_bin_xdef.val_itab(i),
        p_bin_xdef.bin_itab(i);
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO insert_bin_cat;
      RAISE;
  END insert_bin_cat;

  ----------------------------------------------------------------------------
  --                             select_bin_cat                             --
  ----------------------------------------------------------------------------
  -- NAME
  --   select_bin_cat
  -- DESCRIPTION
  --   Reads categorical binning definition from a table.
  -- PARAMETERS
  --   p_bin_tref                     - xform table reference
  -- RETURNS
  --   r_bin_xdef                     - xform definition
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Removes rows with NULL values in COL. Clusters by COL. Each cluster is
  --   ordered by VAL in ascending order with default bin comming last. Ready
  --   to used by ls_append_bin_cat.
  ----------------------------------------------------------------------------
  PROCEDURE select_bin_cat(
    r_bin_xdef                     OUT NOCOPY BIN_CAT_REC_TYPE,
    p_bin_tref                     VARCHAR2)
  IS
  BEGIN
    EXECUTE IMMEDIATE
      'SELECT col, val, bin '||
        'FROM '||p_bin_tref||' '||
       'WHERE col IS NOT NULL '||                       -- ignore NULLs in COL
       'ORDER BY col ASC,'||                                 -- cluster by COL
                'val ASC NULLS LAST'                           -- order by VAL
    BULK COLLECT INTO
      r_bin_xdef.col_itab, r_bin_xdef.val_itab, r_bin_xdef.bin_itab;
    r_bin_xdef.cnt := SQL%ROWCOUNT;
  END select_bin_cat;

  ----------------------------------------------------------------------------
  --                           ls_append_bin_cat                            --
  ----------------------------------------------------------------------------
  -- NAME
  --   ls_append_bin_cat - Long Statement APPEND BINning CATegorical xfrom
  -- DESCRIPTION
  --   Appends a SELECT statement performing categorical binning.
  -- PARAMETERS
  --   r_xform_lstmt                  - input query statement
  --   p_data_tref                    - data table reference
  --   p_bin_xdef                     - xform definition
  --   p_lit_flag                     - literal flag
  -- RETURNS
  --   r_xform_lstmt                  - output query statement
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   It is assumed that xform definition does not have entries with NULL
  --   values in COL, and it is clustered by COL, and each cluster is ordered
  --   by VAL in ascending order with default bin comming last (if any).
  ----------------------------------------------------------------------------
  PROCEDURE ls_append_bin_cat(
    r_xform_lstmt                  IN OUT NOCOPY LSTMT_REC_TYPE,
    p_data_tref                    VARCHAR2,
    p_bin_xdef                     BIN_CAT_REC_TYPE,
    p_lit_flag                     BOOLEAN DEFAULT FALSE)
  IS
    v_desc_itab                    DESC_ITAB_TYPE;           -- DESCribe table
    v_col_atab                     CIDEN_ATAB_TYPE;   -- COL associative array

    v_idx                          PLS_INTEGER;
    v_col                          CIDEN_VCHAR_TYPE;
    v_val                          STMT_VCHAR_TYPE;             -- VAL literal
    v_bin                          STMT_VCHAR_TYPE;             -- BIN literal
    v_delim                        CHAR(1);                       -- DELIMiter
  BEGIN
    -- form column associative array -----------------------------------------
    v_col := NULL;
    FOR i IN 1..p_bin_xdef.cnt LOOP
      IF i = 1 OR p_bin_xdef.col_itab(i) != v_col THEN    -- start new cluster
        v_col := p_bin_xdef.col_itab(i);
        v_col_atab(v_col) := i;
      END IF;
    END LOOP;

    -- describe data table ---------------------------------------------------
    tref_desc(
      p_data_tref                    => p_data_tref,
      r_desc_itab                    => v_desc_itab);

    -- form the statement ----------------------------------------------------
    ls_append(
      r_lstmt                        => r_xform_lstmt,
      p_txt                          => 'SELECT');
    v_delim := ' ';
    FOR i IN 1..v_desc_itab.COUNT LOOP
      v_col := v_desc_itab(i).col_name;
      IF v_col_atab.EXISTS(v_col) THEN                                  -- bin
        v_idx := v_col_atab(v_col);                -- beginning of the cluster
        ls_append(
          r_lstmt                        => r_xform_lstmt,
          p_txt                          => v_delim||'DECODE("'||v_col||'"');
        WHILE v_idx <= p_bin_xdef.cnt                             -- in bounds
              AND p_bin_xdef.col_itab(v_idx) = v_col             -- in cluster
              AND p_bin_xdef.val_itab(v_idx) IS NOT NULL LOOP   -- not def bin
          v_val := to_literal(p_bin_xdef.val_itab(v_idx));
          v_bin := to_literal(p_bin_xdef.bin_itab(v_idx), p_lit_flag);
          ls_append(
            r_lstmt                        => r_xform_lstmt,
            p_txt                          => ','||v_val||','||v_bin);
          v_idx := v_idx + 1;
        END LOOP;
        IF v_idx <= p_bin_xdef.cnt                                -- in bounds
           AND p_bin_xdef.col_itab(v_idx) = v_col                -- in cluster
           AND p_bin_xdef.val_itab(v_idx) IS NULL THEN          -- default bin
          v_bin := to_literal(p_bin_xdef.bin_itab(v_idx), p_lit_flag);
          ls_append(
            r_lstmt                        => r_xform_lstmt,
            p_txt                          => ',NULL,NULL,'||v_bin);
        END IF;
        ls_append(
          r_lstmt                        => r_xform_lstmt,
          p_txt                          => ') "'||v_col||'"');
      ELSE                                                    -- carry forward
        ls_append(
          r_lstmt                        => r_xform_lstmt,
          p_txt                          =>
            v_delim||'"'||v_col||'"');
      END IF;
      v_delim := ',';
    END LOOP;
    ls_append(
      r_lstmt                        => r_xform_lstmt,
      p_txt                          => ' FROM ');
    ls_append(
      r_lstmt                        => r_xform_lstmt,
      p_txt                          => p_data_tref);
  END ls_append_bin_cat;

  ----------------------------------------------------------------------------
  --                              ls_append_expr                            --
  ----------------------------------------------------------------------------
  -- NAME
  --   ls_append_expr - Long Statement APPEND EXPRession xfrom
  -- DESCRIPTION
  --   Appends a SELECT statement performing expression xfromation.
  -- PARAMETERS
  --   r_xform_lstmt                  - input query statement
  --   p_data_tref                    - data table reference
  --   p_expr_pat                     - expression pattern
  --   p_ctyp_ntab                    - applicable column types
  --   p_excl_varr                    - column exclusion list
  --   p_incl_varr                    - column inclusion list
  --   p_col_pat                      - column pattern
  -- RETURNS
  --   r_xform_lstmt                  - output query statement
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   None
  ----------------------------------------------------------------------------
  PROCEDURE ls_append_expr(
    r_xform_lstmt                  IN OUT NOCOPY LSTMT_REC_TYPE,
    p_data_tref                    VARCHAR2,
    p_expr_pat                     VARCHAR2,
    p_ctyp_ntab                    NUM_NTAB_TYPE DEFAULT NULL,
    p_excl_varr                    IDEN_VARR_TYPE DEFAULT NULL,
    p_incl_varr                    IDEN_VARR_TYPE DEFAULT NULL,
    p_col_pat                      VARCHAR2 DEFAULT ':col')
  IS
    v_desc_itab                    DESC_ITAB_TYPE;           -- DESCribe table
    v_col_itab                     CIDEN_ITAB_TYPE;   -- xfrom definition: COL
    v_col_atab                     CIDEN_ATAB_TYPE;   -- COL associative array

    v_col                          CIDEN_VCHAR_TYPE;
    v_expr                         STMT_VCHAR_TYPE;              -- EXPRession
    v_delim                        CHAR(1);                       -- DELIMiter
  BEGIN
    -- describe data table reference -----------------------------------------
    tref_desc(
      p_data_tref                    => p_data_tref,
      r_desc_itab                    => v_desc_itab);

    -- get xform columns -----------------------------------------------------
    get_columns(
      r_incl_itab                    => v_col_itab,
      p_desc_itab                    => v_desc_itab,
      p_ctyp_ntab                    => p_ctyp_ntab,
      p_excl_varr                    => p_excl_varr,
      p_incl_varr                    => p_incl_varr);
                        
    -- get xform columns associative array -----------------------------------
    FOR i IN 1..v_col_itab.COUNT LOOP
      v_col := v_col_itab(i);
      v_col_atab(v_col) := i;                             -- associative array
    END LOOP;
            
    -- form the statement ----------------------------------------------------
    ls_append(
      r_lstmt                        => r_xform_lstmt,
      p_txt                          => 'SELECT');
    v_delim := ' ';    
    FOR i IN 1..v_desc_itab.COUNT LOOP
      v_col := v_desc_itab(i).col_name;
      IF v_col_atab.EXISTS(v_col) THEN                                -- xform
        v_expr := REPLACE(p_expr_pat, p_col_pat, '"'||v_col||'"');
        ls_append(
          r_lstmt                        => r_xform_lstmt,
          p_txt                          =>
            v_delim||v_expr||' "'||v_col||'"');
      ELSE                                                    -- carry forward
        ls_append(
          r_lstmt                        => r_xform_lstmt,
          p_txt                          =>
            v_delim||'"'||v_col||'"');
      END IF;
      v_delim := ',';
    END LOOP;
    ls_append(
      r_lstmt                        => r_xform_lstmt,
      p_txt                          => ' FROM ');
    ls_append(
      r_lstmt                        => r_xform_lstmt,
      p_txt                          => p_data_tref);
  END ls_append_expr;

  ----------------------------------------------------------------------------
  --                            compute_clip_tail                           --
  ----------------------------------------------------------------------------
  -- NAME
  --   compute_clip_tail
  -- DESCRIPTION
  --   Computes cut values (LCUT, RCUT) for a clipping xform definition given
  --   the tail fraction. The values of LVAL and RVAL are not computed.
  -- PARAMETERS
  --   p_data_tref                    - data table reference
  --   p_tail_frac                    - tail fraction
  --   p_excl_varr                    - column exclusion list
  -- RETURNS
  --   r_clip_xdef                    - xform definition
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   When n=2m and frac=0.499... (full precision) the values for left and
  --   right pos switch places. This is not a problem though, since
  --       lcut = min[val(lpos), val(rpos)] instead of val(lpos)
  --       rcut = max[val(lpos), val(rpos)] instead of val(rpos)
  --   This is not happening when n=2m+1. Ready to be used by ls_append_clip.
  ----------------------------------------------------------------------------
  PROCEDURE compute_clip_tail(
    r_clip_xdef                    OUT NOCOPY CLIP_REC_TYPE,
    p_data_tref                    VARCHAR2,
    p_tail_frac                    NUMBER DEFAULT 0.025,
    p_excl_varr                    IDEN_VARR_TYPE DEFAULT NULL)
  IS
    v_tail_frac                    NUMBER := ABS(NVL(p_tail_frac, 0));
    v_incl_itab                    CIDEN_ITAB_TYPE;       -- INCLusion columns
    v_stmt_cut                     STMT_VCHAR_TYPE;
    v_cnt                          PLS_INTEGER;                       -- CouNT
    v_num                          PLS_INTEGER;
    v_lcut                         NUMBER;
    v_rcut                         NUMBER;
  BEGIN
    -- verify parameters -----------------------------------------------------
    IF v_tail_frac >= 0.5 THEN
      RETURN;                                                 -- nothing to do
    END IF;

    -- get inclusion columns -------------------------------------------------
    get_columns(
      r_incl_itab                    => v_incl_itab,
      p_data_tref                    => p_data_tref,
      p_ctyp_ntab                    => c_num_ctyp_ntab,       -- number types
      p_excl_varr                    => p_excl_varr);
    IF v_incl_itab.COUNT = 0 THEN
      RETURN;                                           -- no relevant columns
    END IF;

    -- statement template ----------------------------------------------------
    v_stmt_cut :=
      'SELECT MIN(val) lcut, MAX(val) rcut '||
        'FROM (SELECT val,'||
                     'ROW_NUMBER() OVER (ORDER BY val ASC) pos,'||
                     'COUNT(*) OVER () n '||
                'FROM (SELECT "%col%" val '||
                        'FROM '||p_data_tref||') '||
               'WHERE val IS NOT NULL) '||
       'WHERE pos = 1 + FLOOR('||to_literal(v_tail_frac)||'*n) '||
          'OR pos = n - FLOOR('||to_literal(v_tail_frac)||'*n)';
        
    -- compute xform definition ----------------------------------------------
    v_cnt := 0;
    FOR i IN 1..v_incl_itab.COUNT LOOP
      EXECUTE IMMEDIATE
        REPLACE(v_stmt_cut, '%col%', v_incl_itab(i))
      INTO v_lcut, v_rcut;

      IF v_lcut IS NULL THEN                           -- all NULLs or no data
        NULL;                                                        -- ignore
      ELSE
        v_cnt := v_cnt + 1;
        r_clip_xdef.col_itab(v_cnt)  := v_incl_itab(i);
        r_clip_xdef.lcut_itab(v_cnt) := v_lcut;
        r_clip_xdef.rcut_itab(v_cnt) := v_rcut;
      END IF;
    END LOOP;
    r_clip_xdef.cnt := v_cnt;
  END compute_clip_tail;

  ----------------------------------------------------------------------------
  --                                insert_clip                             --
  ----------------------------------------------------------------------------
  -- NAME
  --   insert_clip
  -- DESCRIPTION
  --   Writes clipping definition into a table.
  -- PARAMETERS
  --   p_clip_texpr                   - xform table expression
  --   p_clip_xdef                    - xform definition
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   None
  ----------------------------------------------------------------------------
  PROCEDURE insert_clip(
    p_clip_texpr                   VARCHAR2,
    p_clip_xdef                    CLIP_REC_TYPE)
  IS
  BEGIN
    SAVEPOINT insert_clip;                -- rollback here in case of an error
    FORALL i IN 1..p_clip_xdef.cnt
      EXECUTE IMMEDIATE
        'INSERT INTO '||p_clip_texpr||'('||
          'col, lcut, lval, rcut, rval) ' ||
        'VALUES (' ||
          ':1, :2, :3, :4, :5)'
      USING 
        p_clip_xdef.col_itab(i), 
        p_clip_xdef.lcut_itab(i), 
        p_clip_xdef.lval_itab(i),
        p_clip_xdef.rcut_itab(i), 
        p_clip_xdef.rval_itab(i);
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO insert_clip;
      RAISE;
  END insert_clip;

  ----------------------------------------------------------------------------
  --                               select_clip                              --
  ----------------------------------------------------------------------------
  -- NAME
  --   select_clip
  -- DESCRIPTION
  --   Reads clipping definition from a table.
  -- PARAMETERS
  --   p_clip_tref                    - xform table reference
  -- RETURNS
  --   r_clip_xdef                    - xform definition
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Removes rows with NULL values in COL. Ready to be used by
  --   ls_append_clip.
  ----------------------------------------------------------------------------
  PROCEDURE select_clip(
    r_clip_xdef                    OUT NOCOPY CLIP_REC_TYPE,
    p_clip_tref                    VARCHAR2)
  IS
  BEGIN
    EXECUTE IMMEDIATE
      'SELECT col, lcut, lval, rcut, rval '||
        'FROM '||p_clip_tref||' '||
       'WHERE col IS NOT NULL'                                 -- ignore NULLs
    BULK COLLECT INTO 
      r_clip_xdef.col_itab,
      r_clip_xdef.lcut_itab, r_clip_xdef.lval_itab,
      r_clip_xdef.rcut_itab, r_clip_xdef.rval_itab;
    r_clip_xdef.cnt := SQL%ROWCOUNT;
  END select_clip;

  ----------------------------------------------------------------------------
  --                              ls_append_clip                            --
  ----------------------------------------------------------------------------
  -- NAME
  --   ls_append_clip - Long Statement APPEND CLIPping xfrom
  -- DESCRIPTION
  --   Appends a SELECT statement performing clipping.
  -- PARAMETERS
  --   r_xform_lstmt                  - input query statement
  --   p_data_tref                    - data table reference
  --   p_clip_xdef                    - xform definition
  -- RETURNS
  --   r_xform_lstmt                  - output query statement
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   It is assumed that xform definition does not have entries with NULL
  --   values in COL.
  ----------------------------------------------------------------------------
  PROCEDURE ls_append_clip(
    r_xform_lstmt                  IN OUT NOCOPY LSTMT_REC_TYPE,
    p_data_tref                    VARCHAR2,
    p_clip_xdef                    CLIP_REC_TYPE)
  IS
    v_desc_itab                    DESC_ITAB_TYPE;           -- DESCribe table
    v_col_atab                     CIDEN_ATAB_TYPE;   -- COL associative array

    v_idx                          PLS_INTEGER;
    v_col                          CIDEN_VCHAR_TYPE;
    v_delim                        CHAR(1);                       -- DELIMiter
    v_lcut                         STMT_VCHAR_TYPE;            -- LCUT literal
    v_lval                         STMT_VCHAR_TYPE;            -- LVAL literal
    v_rcut                         STMT_VCHAR_TYPE;            -- RCUT literal
    v_rval                         STMT_VCHAR_TYPE;            -- RVAL literal
  BEGIN
    -- form column associative array -----------------------------------------
    FOR i IN 1..p_clip_xdef.cnt LOOP
      v_col := p_clip_xdef.col_itab(i);
      v_col_atab(v_col) := i;
    END LOOP;
            
    -- describe data table ---------------------------------------------------
    tref_desc(
      p_data_tref                    => p_data_tref,
      r_desc_itab                    => v_desc_itab);

    -- form the statement ----------------------------------------------------
    ls_append(
      r_lstmt                        => r_xform_lstmt,
      p_txt                          => 'SELECT');
    v_delim := ' ';    
    FOR i IN 1..v_desc_itab.COUNT LOOP
      v_col := v_desc_itab(i).col_name;
      IF v_col_atab.EXISTS(v_col) THEN                                 -- clip
        v_idx := v_col_atab(v_col);
        v_lcut := to_literal(p_clip_xdef.lcut_itab(v_idx));
        v_lval := to_literal(p_clip_xdef.lval_itab(v_idx));
        v_rcut := to_literal(p_clip_xdef.rcut_itab(v_idx));
        v_rval := to_literal(p_clip_xdef.rval_itab(v_idx));
        ls_append(
          r_lstmt                        => r_xform_lstmt,
          p_txt                          =>
            v_delim||'CASE '||
              'WHEN "'||v_col||'"<'||v_lcut||' THEN '||v_lval||' '||
              'WHEN "'||v_col||'">'||v_rcut||' THEN '||v_rval||' '||
                                              'ELSE "'||v_col||'" '||
            'END "'||v_col||'"');
      ELSE                                                    -- carry forward
        ls_append(
          r_lstmt                        => r_xform_lstmt,
          p_txt                          =>
            v_delim||'"'||v_col||'"');
      END IF;
      v_delim := ',';
    END LOOP;
    ls_append(
      r_lstmt                        => r_xform_lstmt,
      p_txt                          => ' FROM ');
    ls_append(
      r_lstmt                        => r_xform_lstmt,
      p_txt                          => p_data_tref);
  END ls_append_clip;

  ----------------------------------------------------------------------------
  --                          compute_miss_num_mean                         --
  ----------------------------------------------------------------------------
  -- NAME
  --   compute_miss_num_mean
  -- DESCRIPTION
  --   Computes "replace with the mean" numerical missing value treatment
  --   xform definition.
  -- PARAMETERS
  --   p_data_tref                    - data table reference
  --   p_excl_varr                    - column exclusion list
  --   p_round_num                    - number of significant digits
  -- RETURNS
  --   r_miss_xdef                    - xform definition
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Ready to be used by ls_append_miss_num.
  ----------------------------------------------------------------------------
  PROCEDURE compute_miss_num_mean(
    r_miss_xdef                    OUT NOCOPY MISS_NUM_REC_TYPE,
    p_data_tref                    VARCHAR2,
    p_excl_varr                    IDEN_VARR_TYPE DEFAULT NULL,
    p_round_num                    PLS_INTEGER DEFAULT 6)
  IS
    v_incl_itab                    CIDEN_ITAB_TYPE;       -- INCLusion columns
   
    v_cur                          INTEGER;                          -- CURsor
    v_cnt                          PLS_INTEGER;                       -- CouNT
    v_row                          NUMBER;
    v_avg                          NUMBER;                    -- AVeraGe value
  BEGIN
    -- get inclusion columns -------------------------------------------------
    get_columns(
      r_incl_itab                    => v_incl_itab,
      p_data_tref                    => p_data_tref,
      p_ctyp_ntab                    => c_num_ctyp_ntab,       -- number types
      p_excl_varr                    => p_excl_varr);
    IF v_incl_itab.COUNT = 0 THEN
      RETURN;                                           -- no relevant columns
    END IF;

    -- get data statistics ---------------------------------------------------
    v_cur := dbms_sql.open_cursor;
    prep_stat_cursor(
      p_cur                          => v_cur,
      p_data_tref                    => p_data_tref,
      p_incl_itab                    => v_incl_itab,
      p_expr_ntab                    => STMT_NTAB_TYPE('AVG(:col)'));
    v_row := dbms_sql.execute_and_fetch(v_cur);                   -- v_row = 1
    
    -- compute xform definition ----------------------------------------------
    v_cnt := 0;
    FOR i IN 1..v_incl_itab.COUNT LOOP
      dbms_sql.column_value(v_cur, i, v_avg);

      IF v_avg IS NULL THEN                            -- all NULLs or no data
        NULL;                                                        -- ignore
      ELSE
        v_cnt := v_cnt + 1;
        r_miss_xdef.col_itab(v_cnt) := v_incl_itab(i);
        r_miss_xdef.val_itab(v_cnt) := sround(v_avg, p_round_num);
      END IF;                                          
    END LOOP;
    r_miss_xdef.cnt := v_cnt;
    dbms_sql.close_cursor(v_cur);

  -- clean up ----------------------------------------------------------------
  EXCEPTION
    WHEN OTHERS THEN
      IF dbms_sql.is_open(v_cur) THEN
        dbms_sql.close_cursor(v_cur);
      END IF;
      RAISE;
  END compute_miss_num_mean;

  ----------------------------------------------------------------------------
  --                             insert_miss_num                            --
  ----------------------------------------------------------------------------
  -- NAME
  --   insert_miss_num
  -- DESCRIPTION
  --   Writes numerical missing value treatment definition into a table.
  -- PARAMETERS
  --   p_miss_texpr                   - xform table expression
  --   p_miss_xdef                    - xform definition
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   None
  ----------------------------------------------------------------------------
  PROCEDURE insert_miss_num(
    p_miss_texpr                   VARCHAR2,
    p_miss_xdef                    MISS_NUM_REC_TYPE)
  IS
  BEGIN
    SAVEPOINT insert_miss_num;            -- rollback here in case of an error
    FORALL i IN 1..p_miss_xdef.cnt
      EXECUTE IMMEDIATE
        'INSERT INTO '||p_miss_texpr||'('||
          'col, val) ' ||
        'VALUES (' ||
          ':1, :2)'
      USING 
        p_miss_xdef.col_itab(i), 
        p_miss_xdef.val_itab(i);
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO insert_miss_num;
      RAISE;
  END insert_miss_num;

  ----------------------------------------------------------------------------
  --                             select_miss_num                            --
  ----------------------------------------------------------------------------
  -- NAME
  --   select_miss_num
  -- DESCRIPTION
  --   Reads numerical missing value treatment definition from a table.
  -- PARAMETERS
  --   p_miss_tref                    - xform table reference
  -- RETURNS
  --   r_miss_xdef                    - xform definition
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Removes rows with NULL values in COL. Ready to be used by
  --   ls_append_miss_num.
  ----------------------------------------------------------------------------
  PROCEDURE select_miss_num(
    r_miss_xdef                    OUT NOCOPY MISS_NUM_REC_TYPE,
    p_miss_tref                    VARCHAR2)
  IS
  BEGIN
    EXECUTE IMMEDIATE
      'SELECT col, val '||
        'FROM '||p_miss_tref||' '||
       'WHERE col IS NOT NULL'                                 -- ignore NULLs
    BULK COLLECT INTO 
      r_miss_xdef.col_itab, r_miss_xdef.val_itab;
    r_miss_xdef.cnt := SQL%ROWCOUNT;
  END select_miss_num;

  ----------------------------------------------------------------------------
  --                             ls_append_miss_num                         --
  ----------------------------------------------------------------------------
  -- NAME
  --   ls_append_miss_num - Long Statement APPEND NUMerical MISSing value
  --                        treatment xfrom
  -- DESCRIPTION
  --   Appends a SELECT statement performing numerical missing value
  --   treatment.
  -- PARAMETERS
  --   r_xform_lstmt                  - input query statement
  --   p_data_tref                    - data table reference
  --   p_miss_xdef                    - xform definition
  -- RETURNS
  --   r_xform_lstmt                  - output query statement
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   It is assumed that xform definition does not have entries with NULL
  --   values in COL.
  ----------------------------------------------------------------------------
  PROCEDURE ls_append_miss_num(
    r_xform_lstmt                  IN OUT NOCOPY LSTMT_REC_TYPE,
    p_data_tref                    VARCHAR2,
    p_miss_xdef                    MISS_NUM_REC_TYPE)
  IS
    v_desc_itab                    DESC_ITAB_TYPE;           -- DESCribe table
    v_col_atab                     CIDEN_ATAB_TYPE;   -- COL associative array

    v_idx                          PLS_INTEGER;
    v_col                          CIDEN_VCHAR_TYPE;
    v_delim                        CHAR(1);                       -- DELIMiter
    v_val                          STMT_VCHAR_TYPE;             -- VAL literal
  BEGIN
    -- form column associative array -----------------------------------------
    FOR i IN 1..p_miss_xdef.cnt LOOP
      v_col := p_miss_xdef.col_itab(i);
      v_col_atab(v_col) := i;
    END LOOP;
            
    -- describe data table ---------------------------------------------------
    tref_desc(
      p_data_tref                    => p_data_tref,
      r_desc_itab                    => v_desc_itab);

    -- form the statement ----------------------------------------------------
    ls_append(
      r_lstmt                        => r_xform_lstmt,
      p_txt                          => 'SELECT');
    v_delim := ' ';    
    FOR i IN 1..v_desc_itab.COUNT LOOP
      v_col := v_desc_itab(i).col_name;
      IF v_col_atab.EXISTS(v_col) THEN      -- perform missing value treatment
        v_idx := v_col_atab(v_col);
        v_val := to_literal(p_miss_xdef.val_itab(v_idx));
        ls_append(
          r_lstmt                        => r_xform_lstmt,
          p_txt                          =>
            v_delim||'NVL("'||v_col||'",'||v_val||') "'||v_col||'"');
      ELSE                                                    -- carry forward
        ls_append(
          r_lstmt                        => r_xform_lstmt,
          p_txt                          =>
            v_delim||'"'||v_col||'"');
      END IF;
      v_delim := ',';
    END LOOP;
    ls_append(
      r_lstmt                        => r_xform_lstmt,
      p_txt                          => ' FROM ');
    ls_append(
      r_lstmt                        => r_xform_lstmt,
      p_txt                          => p_data_tref);
  END ls_append_miss_num;

  ----------------------------------------------------------------------------
  --                          compute_miss_cat_mode                         --
  ----------------------------------------------------------------------------
  -- NAME
  --   compute_miss_cat_mode
  -- DESCRIPTION
  --   Computes "replace with the mode" categorical missing value treatment
  --   xform definition.
  -- PARAMETERS
  --   p_data_tref                    - data table reference
  --   p_excl_varr                    - column exclusion list
  -- RETURNS
  --   r_miss_xdef                    - xform definition
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Ready to be used by ls_append_miss_cat.
  ----------------------------------------------------------------------------
  PROCEDURE compute_miss_cat_mode(
    r_miss_xdef                    OUT NOCOPY MISS_CAT_REC_TYPE,
    p_data_tref                    VARCHAR2,
    p_excl_varr                    IDEN_VARR_TYPE DEFAULT NULL)
  IS
    v_incl_itab                    CIDEN_ITAB_TYPE;       -- INCLusion columns
   
    v_cur                          INTEGER;                          -- CURsor
    v_cnt                          PLS_INTEGER;                       -- CouNT
    v_row                          NUMBER;
    v_mode                         VARCHAR2(4000);               -- MODE value
  BEGIN
    -- get inclusion columns -------------------------------------------------
    get_columns(
      r_incl_itab                    => v_incl_itab,
      p_data_tref                    => p_data_tref,
      p_ctyp_ntab                    => c_str_ctyp_ntab,       -- string types
      p_excl_varr                    => p_excl_varr);
    IF v_incl_itab.COUNT = 0 THEN
      RETURN;                                           -- no relevant columns
    END IF;

    -- get data statistics ---------------------------------------------------
    v_cur := dbms_sql.open_cursor;
    prep_stat_cursor(
      p_cur                          => v_cur,
      p_data_tref                    => p_data_tref,
      p_incl_itab                    => v_incl_itab,
      p_expr_ntab                    => STMT_NTAB_TYPE('STATS_MODE(:col)'),
      p_dtyp_ntab                    => NUM_NTAB_TYPE(1));
    v_row := dbms_sql.execute_and_fetch(v_cur);                   -- v_row = 1
    
    -- compute xform definition ----------------------------------------------
    v_cnt := 0;
    FOR i IN 1..v_incl_itab.COUNT LOOP
      dbms_sql.column_value(v_cur, i, v_mode);

      IF v_mode IS NULL THEN                           -- all NULLs or no data
        NULL;                                                        -- ignore
      ELSE
        v_cnt := v_cnt + 1;
        r_miss_xdef.col_itab(v_cnt) := v_incl_itab(i);
        r_miss_xdef.val_itab(v_cnt) := v_mode;
      END IF;                                          
    END LOOP;
    r_miss_xdef.cnt := v_cnt;
    dbms_sql.close_cursor(v_cur);

  -- clean up ----------------------------------------------------------------
  EXCEPTION
    WHEN OTHERS THEN
      IF dbms_sql.is_open(v_cur) THEN
        dbms_sql.close_cursor(v_cur);
      END IF;
      RAISE;
  END compute_miss_cat_mode;

  ----------------------------------------------------------------------------
  --                             insert_miss_cat                            --
  ----------------------------------------------------------------------------
  -- NAME
  --   insert_miss_cat
  -- DESCRIPTION
  --   Writes categorical missing value treatment definition into a table.
  -- PARAMETERS
  --   p_miss_texpr                   - xform table expression
  --   p_miss_xdef                    - xform definition
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   None
  ----------------------------------------------------------------------------
  PROCEDURE insert_miss_cat(
    p_miss_texpr                   VARCHAR2,
    p_miss_xdef                    MISS_CAT_REC_TYPE)
  IS
  BEGIN
    SAVEPOINT insert_miss_cat;            -- rollback here in case of an error
    FORALL i IN 1..p_miss_xdef.cnt
      EXECUTE IMMEDIATE
        'INSERT INTO '||p_miss_texpr||'('||
          'col, val) ' ||
        'VALUES (' ||
          ':1, :2)'
      USING 
        p_miss_xdef.col_itab(i), 
        p_miss_xdef.val_itab(i);
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO insert_miss_cat;
      RAISE;
  END insert_miss_cat;

  ----------------------------------------------------------------------------
  --                             select_miss_cat                            --
  ----------------------------------------------------------------------------
  -- NAME
  --   select_miss_cat
  -- DESCRIPTION
  --   Reads categorical missing value treatment definition from a table.
  -- PARAMETERS
  --   p_miss_tref                    - xform table reference
  -- RETURNS
  --   r_miss_xdef                    - xform definition
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Removes rows with NULL values in COL. Ready to be used by
  --   ls_append_miss_cat.
  ----------------------------------------------------------------------------
  PROCEDURE select_miss_cat(
    r_miss_xdef                    OUT NOCOPY MISS_CAT_REC_TYPE,
    p_miss_tref                    VARCHAR2)
  IS
  BEGIN
    EXECUTE IMMEDIATE
      'SELECT col, val '||
        'FROM '||p_miss_tref||' '||
       'WHERE col IS NOT NULL'                                 -- ignore NULLs
    BULK COLLECT INTO 
      r_miss_xdef.col_itab, r_miss_xdef.val_itab;
    r_miss_xdef.cnt := SQL%ROWCOUNT;
  END select_miss_cat;

  ----------------------------------------------------------------------------
  --                             ls_append_miss_cat                         --
  ----------------------------------------------------------------------------
  -- NAME
  --   ls_append_miss_num - Long Statement APPEND CATegorical MISSing value
  --                        treatment xfrom
  -- DESCRIPTION
  --   Appends a SELECT statement performing categorical missing value
  --   treatment.
  -- PARAMETERS
  --   r_xform_lstmt                  - input query statement
  --   p_data_tref                    - data table reference
  --   p_miss_xdef                    - xform definition
  -- RETURNS
  --   r_xform_lstmt                  - output query statement
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   It is assumed that xform definition does not have entries with NULL
  --   values in COL.
  ----------------------------------------------------------------------------
  PROCEDURE ls_append_miss_cat(
    r_xform_lstmt                  IN OUT NOCOPY LSTMT_REC_TYPE,
    p_data_tref                    VARCHAR2,
    p_miss_xdef                    MISS_CAT_REC_TYPE)
  IS
    v_desc_itab                    DESC_ITAB_TYPE;           -- DESCribe table
    v_col_atab                     CIDEN_ATAB_TYPE;   -- COL associative array

    v_idx                          PLS_INTEGER;
    v_col                          CIDEN_VCHAR_TYPE;
    v_delim                        CHAR(1);                       -- DELIMiter
    v_val                          STMT_VCHAR_TYPE;             -- VAL literal
    v_typ                          STMT_VCHAR_TYPE;       -- data TYPe literal
    v_len                          STMT_VCHAR_TYPE;     -- type LENgth literal
  BEGIN
    -- form column associative array -----------------------------------------
    FOR i IN 1..p_miss_xdef.cnt LOOP
      v_col := p_miss_xdef.col_itab(i);
      v_col_atab(v_col) := i;
    END LOOP;
            
    -- describe data table ---------------------------------------------------
    tref_desc(
      p_data_tref                    => p_data_tref,
      r_desc_itab                    => v_desc_itab);

    -- form the statement ----------------------------------------------------
    ls_append(
      r_lstmt                        => r_xform_lstmt,
      p_txt                          => 'SELECT');
    v_delim := ' ';    
    FOR i IN 1..v_desc_itab.COUNT LOOP
      v_col := v_desc_itab(i).col_name;
      v_len := to_literal(v_desc_itab(i).col_max_len);
      v_typ := CASE v_desc_itab(i).col_type WHEN 1 THEN 'VARCHAR2'
               ELSE 'CHAR' END;
      IF v_col_atab.EXISTS(v_col) THEN      -- perform missing value treatment
        v_idx := v_col_atab(v_col);
        v_val := to_literal(p_miss_xdef.val_itab(v_idx));
        ls_append(
          r_lstmt                        => r_xform_lstmt,
          p_txt                          =>
            v_delim||'CAST(NVL("'||v_col||'",'||v_val||') AS '||
            v_typ||'('||v_len||')) "'||v_col||'"');
      ELSE                                                    -- carry forward
        ls_append(
          r_lstmt                        => r_xform_lstmt,
          p_txt                          =>
            v_delim||'"'||v_col||'"');
      END IF;
      v_delim := ',';
    END LOOP;
    ls_append(
      r_lstmt                        => r_xform_lstmt,
      p_txt                          => ' FROM ');
    ls_append(
      r_lstmt                        => r_xform_lstmt,
      p_txt                          => p_data_tref);
  END ls_append_miss_cat;

  ----------------------------------------------------------------------------
  --                           create_norm_lin                              --
  ----------------------------------------------------------------------------
  PROCEDURE create_norm_lin(
    norm_table_name                VARCHAR2,
    norm_schema_name               VARCHAR2 DEFAULT NULL)
  IS
  BEGIN
    EXECUTE IMMEDIATE
      'CREATE TABLE '||dbms_assert.qualified_sql_name(
        NULLIF(norm_schema_name||'.','.')||norm_table_name)||'('||
        'col   VARCHAR2(30),'||
        'shift NUMBER,'||
        'scale NUMBER)';
  END create_norm_lin;

  ----------------------------------------------------------------------------
  --                          insert_norm_lin_minmax                        --
  ----------------------------------------------------------------------------
  PROCEDURE insert_norm_lin_minmax(
    norm_table_name                VARCHAR2,
    data_table_name                VARCHAR2,
    exclude_list                   COLUMN_LIST DEFAULT NULL,
    round_num                      PLS_INTEGER DEFAULT 6,
    norm_schema_name               VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL)
  IS
    v_xdef                         NORM_LIN_REC_TYPE;      -- Xform DEFinition
  BEGIN
    -- compute xform definition ----------------------------------------------
    compute_norm_lin_minmax(
      r_norm_xdef                    => v_xdef,
      p_data_tref                    => NULLIF(data_schema_name||'.','.')
                                        ||data_table_name,
      p_excl_varr                    => exclude_list,
      p_round_num                    => round_num);

    -- populate xform definition table ---------------------------------------
    insert_norm_lin(
      p_norm_texpr                   => NULLIF(norm_schema_name||'.','.')
                                        ||norm_table_name,
      p_norm_xdef                    => v_xdef);
  END insert_norm_lin_minmax;

  ----------------------------------------------------------------------------
  --                          insert_norm_lin_scale                         --
  ----------------------------------------------------------------------------
  PROCEDURE insert_norm_lin_scale(
    norm_table_name                VARCHAR2,
    data_table_name                VARCHAR2,
    exclude_list                   COLUMN_LIST DEFAULT NULL,
    round_num                      PLS_INTEGER DEFAULT 6,
    norm_schema_name               VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL)
  IS
    v_xdef                         NORM_LIN_REC_TYPE;      -- Xform DEFinition
  BEGIN
    -- compute xform definition ----------------------------------------------
    compute_norm_lin_scale(
      r_norm_xdef                    => v_xdef,
      p_data_tref                    => NULLIF(data_schema_name||'.','.')
                                        ||data_table_name,
      p_excl_varr                    => exclude_list,
      p_round_num                    => round_num);

    -- populate xform definition table ---------------------------------------
    insert_norm_lin(
      p_norm_texpr                   => NULLIF(norm_schema_name||'.','.')
                                        ||norm_table_name,
      p_norm_xdef                    => v_xdef);
  END insert_norm_lin_scale;

  ----------------------------------------------------------------------------
  --                          insert_norm_lin_zscore                        --
  ----------------------------------------------------------------------------
  PROCEDURE insert_norm_lin_zscore(
    norm_table_name                VARCHAR2,
    data_table_name                VARCHAR2,
    exclude_list                   COLUMN_LIST DEFAULT NULL,
    round_num                      PLS_INTEGER DEFAULT 6,
    norm_schema_name               VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL)
  IS
    v_xdef                         NORM_LIN_REC_TYPE;      -- Xform DEFinition
  BEGIN
    -- compute xform definition ----------------------------------------------
    compute_norm_lin_zscore(
      r_norm_xdef                    => v_xdef,
      p_data_tref                    => NULLIF(data_schema_name||'.','.')
                                        ||data_table_name,
      p_excl_varr                    => exclude_list,
      p_round_num                    => round_num);

    -- populate xform definition table ---------------------------------------
    insert_norm_lin(
      p_norm_texpr                   => NULLIF(norm_schema_name||'.','.')
                                        ||norm_table_name,
      p_norm_xdef                    => v_xdef);
  END insert_norm_lin_zscore;

  ----------------------------------------------------------------------------
  --                             xform_norm_lin                             --
  ----------------------------------------------------------------------------
  PROCEDURE xform_norm_lin(
    norm_table_name                VARCHAR2,
    data_table_name                VARCHAR2,
    xform_view_name                VARCHAR2,
    norm_schema_name               VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL,
    xform_schema_name              VARCHAR2 DEFAULT NULL)
  IS
    v_xdef                         NORM_LIN_REC_TYPE;
    v_xform_lstmt                  LSTMT_REC_TYPE;
  BEGIN
    -- get xform definition --------------------------------------------------
    select_norm_lin(
      r_norm_xdef                    => v_xdef,
      p_norm_tref                    => NULLIF(norm_schema_name||'.','.')
                                        ||norm_table_name);

    -- form the statement ----------------------------------------------------
    ls_append(
      r_lstmt                        => v_xform_lstmt,
      p_txt                          => 
        'CREATE VIEW '||dbms_assert.qualified_sql_name(
        NULLIF(xform_schema_name||'.','.')||xform_view_name)||' '||
        'AS ');
    ls_append_norm_lin(
      r_xform_lstmt                  => v_xform_lstmt,
      p_data_tref                    => NULLIF(data_schema_name||'.','.')
                                        ||data_table_name,
      p_norm_xdef                    => v_xdef);

    -- execute the statement -------------------------------------------------
    ls_exec(
      p_lstmt                        => v_xform_lstmt);
  END xform_norm_lin;

  ----------------------------------------------------------------------------
  --                            create_bin_num                              --
  ----------------------------------------------------------------------------
  PROCEDURE create_bin_num(
    bin_table_name                 VARCHAR2,
    bin_schema_name                VARCHAR2 DEFAULT NULL)
  IS
  BEGIN
    EXECUTE IMMEDIATE
      'CREATE TABLE '||dbms_assert.qualified_sql_name(
      NULLIF(bin_schema_name||'.','.')||bin_table_name)||'('||
        'col VARCHAR2(30),'||
        'val NUMBER,'||
        'bin VARCHAR2(4000))';
  END create_bin_num;

  ----------------------------------------------------------------------------
  --                          insert_bin_num_eqwidth                        --
  ----------------------------------------------------------------------------
  PROCEDURE insert_bin_num_eqwidth(
    bin_table_name                 VARCHAR2,
    data_table_name                VARCHAR2,
    bin_num                        PLS_INTEGER DEFAULT 10,
    exclude_list                   COLUMN_LIST DEFAULT NULL,
    round_num                      PLS_INTEGER DEFAULT 6,
    bin_schema_name                VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL)
  IS
    v_xdef                         BIN_NUM_REC_TYPE;       -- Xform DEFinition
  BEGIN
    -- compute xform definition ----------------------------------------------
    compute_bin_num_eqwidth(
      r_bin_xdef                     => v_xdef,
      p_data_tref                    => NULLIF(data_schema_name||'.','.')
                                        ||data_table_name,
      p_bin_num                      => bin_num,
      p_excl_varr                    => exclude_list,
      p_round_num                    => round_num);

    -- populate xform definition table ---------------------------------------
    insert_bin_num(
      p_bin_texpr                    => NULLIF(bin_schema_name||'.','.')
                                        ||bin_table_name,
      p_bin_xdef                     => v_xdef);
  END insert_bin_num_eqwidth;

  ----------------------------------------------------------------------------
  --                      insert_autobin_num_eqwidth                        --
  ----------------------------------------------------------------------------
  PROCEDURE insert_autobin_num_eqwidth(
    bin_table_name                 VARCHAR2,
    data_table_name                VARCHAR2,
    bin_num                        PLS_INTEGER DEFAULT 3,
    max_bin_num                    PLS_INTEGER DEFAULT 100,
    exclude_list                   COLUMN_LIST DEFAULT NULL,
    round_num                      PLS_INTEGER DEFAULT 6,
    sample_size                    PLS_INTEGER DEFAULT 50000,
    bin_schema_name                VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL)
  IS
    c_bin_factor                   CONSTANT NUMBER := 0.9;
    c_bin_coef                     CONSTANT NUMBER := 3.49;

    v_xdef                         BIN_NUM_REC_TYPE;       -- Xform DEFinition
  BEGIN
    -- compute xform definition ----------------------------------------------
    compute_bin_num_eqwidth_auto(
      r_bin_xdef                     => v_xdef,
      p_data_tref                    => NULLIF(data_schema_name||'.','.')
                                        ||data_table_name,
      p_min_bin                      => bin_num,
      p_max_bin                      => max_bin_num,
      p_excl_varr                    => exclude_list,
      p_round_num                    => round_num,
      p_sample_size                  => sample_size,
      p_bin_coef                     => c_bin_coef/c_bin_factor);

    -- populate xform definition table ---------------------------------------
    insert_bin_num(
      p_bin_texpr                    => NULLIF(bin_schema_name||'.','.')
                                        ||bin_table_name,
      p_bin_xdef                     => v_xdef);
  END insert_autobin_num_eqwidth;

  ----------------------------------------------------------------------------
  --                          insert_bin_num_qtile                          --
  ----------------------------------------------------------------------------
  PROCEDURE insert_bin_num_qtile(
    bin_table_name                 VARCHAR2,
    data_table_name                VARCHAR2,
    bin_num                        PLS_INTEGER DEFAULT 10,
    exclude_list                   COLUMN_LIST DEFAULT NULL,
    bin_schema_name                VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL)
  IS
    v_xdef                         BIN_NUM_REC_TYPE;       -- Xform DEFinition
  BEGIN
    -- compute xform definition ----------------------------------------------
    compute_bin_num_qtile(
      r_bin_xdef                     => v_xdef,
      p_data_tref                    => NULLIF(data_schema_name||'.','.')
                                        ||data_table_name,
      p_bin_num                      => bin_num,
      p_excl_varr                    => exclude_list);

    -- populate xform definition table ---------------------------------------
    insert_bin_num(
      p_bin_texpr                    => NULLIF(bin_schema_name||'.','.')
                                        ||bin_table_name,
      p_bin_xdef                     => v_xdef);
  END insert_bin_num_qtile;

  ----------------------------------------------------------------------------
  --                             xform_bin_num                              --
  ----------------------------------------------------------------------------
  PROCEDURE xform_bin_num(
    bin_table_name                 VARCHAR2,
    data_table_name                VARCHAR2,
    xform_view_name                VARCHAR2,
    literal_flag                   BOOLEAN DEFAULT FALSE,
    bin_schema_name                VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL,
    xform_schema_name              VARCHAR2 DEFAULT NULL)
  IS
    v_xdef                         BIN_NUM_REC_TYPE;
    v_xform_lstmt                  LSTMT_REC_TYPE;
  BEGIN
    -- get xform definition --------------------------------------------------
    select_bin_num(
      r_bin_xdef                     => v_xdef,
      p_bin_tref                     => NULLIF(bin_schema_name||'.','.')
                                        ||bin_table_name);

    -- form the statement ----------------------------------------------------
    ls_append(
      r_lstmt                        => v_xform_lstmt,
      p_txt                          => 
        'CREATE VIEW '||dbms_assert.qualified_sql_name(
        NULLIF(xform_schema_name||'.','.')||xform_view_name)||' '||
        'AS ');
    ls_append_bin_num(
      r_xform_lstmt                  => v_xform_lstmt,
      p_data_tref                    => NULLIF(data_schema_name||'.','.')
                                        ||data_table_name,
      p_bin_xdef                     => v_xdef,
      p_lit_flag                     => literal_flag);

    -- execute the statement -------------------------------------------------
    ls_exec(
      p_lstmt                        => v_xform_lstmt);
  END xform_bin_num;

  ----------------------------------------------------------------------------
  --                            create_bin_cat                              --
  ----------------------------------------------------------------------------
  PROCEDURE create_bin_cat(
    bin_table_name                 VARCHAR2,
    bin_schema_name                VARCHAR2 DEFAULT NULL)
  IS
  BEGIN
    EXECUTE IMMEDIATE
      'CREATE TABLE '||dbms_assert.qualified_sql_name(
      NULLIF(bin_schema_name||'.','.')||bin_table_name)||'('||
        'col VARCHAR2(30),'||
        'val VARCHAR2(4000),'||
        'bin VARCHAR2(4000))';
  END create_bin_cat;

  ----------------------------------------------------------------------------
  --                          insert_bin_cat_freq                           --
  ----------------------------------------------------------------------------
  PROCEDURE insert_bin_cat_freq(
    bin_table_name                 VARCHAR2,
    data_table_name                VARCHAR2,
    bin_num                        PLS_INTEGER DEFAULT 9,
    exclude_list                   COLUMN_LIST DEFAULT NULL,
    default_num                    PLS_INTEGER DEFAULT 2,
    bin_support                    NUMBER DEFAULT NULL,
    bin_schema_name                VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL)
  IS
    v_xdef                         BIN_CAT_REC_TYPE;       -- Xform DEFinition
  BEGIN
    -- compute xform definition ----------------------------------------------
    compute_bin_cat_freq(
      r_bin_xdef                     => v_xdef,
      p_data_tref                    => NULLIF(data_schema_name||'.','.')
                                        ||data_table_name,
      p_bin_num                      => bin_num,
      p_excl_varr                    => exclude_list,
      p_def_num                      => default_num,
      p_bin_sup                      => bin_support);

    -- populate xform definition table ---------------------------------------
    insert_bin_cat(
      p_bin_texpr                    => NULLIF(bin_schema_name||'.','.')
                                        ||bin_table_name,
      p_bin_xdef                     => v_xdef);
  END insert_bin_cat_freq;

  ----------------------------------------------------------------------------
  --                             xform_bin_cat                              --
  ----------------------------------------------------------------------------
  PROCEDURE xform_bin_cat(
    bin_table_name                 VARCHAR2,
    data_table_name                VARCHAR2,
    xform_view_name                VARCHAR2,
    literal_flag                   BOOLEAN DEFAULT FALSE,
    bin_schema_name                VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL,
    xform_schema_name              VARCHAR2 DEFAULT NULL) 
  IS
    v_xdef                         BIN_CAT_REC_TYPE;
    v_xform_lstmt                  LSTMT_REC_TYPE;
  BEGIN
    -- get xform definition --------------------------------------------------
    select_bin_cat(
      r_bin_xdef                     => v_xdef,
      p_bin_tref                     => NULLIF(bin_schema_name||'.','.')
                                        ||bin_table_name);

    -- form the statement ----------------------------------------------------
    ls_append(
      r_lstmt                        => v_xform_lstmt,
      p_txt                          => 
        'CREATE VIEW '||dbms_assert.qualified_sql_name(
        NULLIF(xform_schema_name||'.','.')||xform_view_name)||' '||
        'AS ');
    ls_append_bin_cat(
      r_xform_lstmt                  => v_xform_lstmt,
      p_data_tref                    => NULLIF(data_schema_name||'.','.')
                                        ||data_table_name,
      p_bin_xdef                     => v_xdef,
      p_lit_flag                     => literal_flag);

    -- execute the statement -------------------------------------------------
    ls_exec(
      p_lstmt                        => v_xform_lstmt);
  END xform_bin_cat;

  ----------------------------------------------------------------------------
  --                             xform_expr_num                             --
  ----------------------------------------------------------------------------
  PROCEDURE xform_expr_num(
    expr_pattern                   VARCHAR2,
    data_table_name                VARCHAR2,
    xform_view_name                VARCHAR2,
    exclude_list                   COLUMN_LIST DEFAULT NULL,
    include_list                   COLUMN_LIST DEFAULT NULL,
    col_pattern                    VARCHAR2 DEFAULT ':col',
    data_schema_name               VARCHAR2 DEFAULT NULL,
    xform_schema_name              VARCHAR2 DEFAULT NULL)
  IS
    v_xform_lstmt                  LSTMT_REC_TYPE;
  BEGIN
    -- form the statement ----------------------------------------------------
    ls_append(
      r_lstmt                        => v_xform_lstmt,
      p_txt                          => 
        'CREATE VIEW '||dbms_assert.qualified_sql_name(
        NULLIF(xform_schema_name||'.','.')||xform_view_name)||' '||
        'AS ');
    ls_append_expr(
      r_xform_lstmt                  => v_xform_lstmt,
      p_data_tref                    => NULLIF(data_schema_name||'.','.')
                                        ||data_table_name,
      p_expr_pat                     => expr_pattern,
      p_ctyp_ntab                    => c_num_ctyp_ntab,
      p_excl_varr                    => exclude_list,
      p_incl_varr                    => include_list,
      p_col_pat                      => col_pattern);

    -- execute the statement -------------------------------------------------
    ls_exec(
      p_lstmt                        => v_xform_lstmt);
  END xform_expr_num;

  ----------------------------------------------------------------------------
  --                             xform_expr_str                             --
  ----------------------------------------------------------------------------
  PROCEDURE xform_expr_str(
    expr_pattern                   VARCHAR2,
    data_table_name                VARCHAR2,
    xform_view_name                VARCHAR2,
    exclude_list                   COLUMN_LIST DEFAULT NULL,
    include_list                   COLUMN_LIST DEFAULT NULL,
    col_pattern                    VARCHAR2 DEFAULT ':col',
    data_schema_name               VARCHAR2 DEFAULT NULL,
    xform_schema_name              VARCHAR2 DEFAULT NULL)
  IS
    v_xform_lstmt                  LSTMT_REC_TYPE;
  BEGIN
    -- form the statement ----------------------------------------------------
    ls_append(
      r_lstmt                        => v_xform_lstmt,
      p_txt                          => 
        'CREATE VIEW '||dbms_assert.qualified_sql_name(
        NULLIF(xform_schema_name||'.','.')||xform_view_name)||' '||
        'AS ');
    ls_append_expr(
      r_xform_lstmt                  => v_xform_lstmt,
      p_data_tref                    => NULLIF(data_schema_name||'.','.')
                                        ||data_table_name,
      p_expr_pat                     => expr_pattern,
      p_ctyp_ntab                    => c_str_ctyp_ntab,
      p_excl_varr                    => exclude_list,
      p_incl_varr                    => include_list,
      p_col_pat                      => col_pattern);

    -- execute the statement -------------------------------------------------
    ls_exec(
      p_lstmt                        => v_xform_lstmt);
  END xform_expr_str;

  ----------------------------------------------------------------------------
  --                              create_clip                               --
  ----------------------------------------------------------------------------
  PROCEDURE create_clip(
    clip_table_name                VARCHAR2,
    clip_schema_name               VARCHAR2 DEFAULT NULL)
  IS
  BEGIN
    EXECUTE IMMEDIATE
      'CREATE TABLE '||dbms_assert.qualified_sql_name(
      NULLIF(clip_schema_name||'.','.')||clip_table_name)||'('||
        'col  VARCHAR2(30),'||
        'lcut NUMBER,'||
        'lval NUMBER,'||
        'rcut NUMBER,'||
        'rval NUMBER)';
  END create_clip;

  ----------------------------------------------------------------------------
  --                        insert_clip_winsor_tail                         --
  ----------------------------------------------------------------------------
  PROCEDURE insert_clip_winsor_tail(
    clip_table_name                VARCHAR2,
    data_table_name                VARCHAR2,
    tail_frac                      NUMBER DEFAULT 0.025,
    exclude_list                   COLUMN_LIST DEFAULT NULL,
    clip_schema_name               VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL)
  IS
    v_xdef                         CLIP_REC_TYPE;          -- Xform DEFinition
  BEGIN
    -- compute xform definition ----------------------------------------------
    compute_clip_tail(
      r_clip_xdef                    => v_xdef,
      p_data_tref                    => NULLIF(data_schema_name||'.','.')
                                        ||data_table_name,
      p_tail_frac                    => tail_frac,
      p_excl_varr                    => exclude_list);
    FOR i IN 1..v_xdef.cnt LOOP
      v_xdef.lval_itab(i) := v_xdef.lcut_itab(i);
      v_xdef.rval_itab(i) := v_xdef.rcut_itab(i);
    END LOOP;

    -- populate xform definition table ---------------------------------------
    insert_clip(
      p_clip_texpr                   => NULLIF(clip_schema_name||'.','.')
                                        ||clip_table_name,
      p_clip_xdef                    => v_xdef);
  END insert_clip_winsor_tail;

  ----------------------------------------------------------------------------
  --                        insert_clip_trim_tail                           --
  ----------------------------------------------------------------------------
  PROCEDURE insert_clip_trim_tail(
    clip_table_name                VARCHAR2,
    data_table_name                VARCHAR2,
    tail_frac                      NUMBER DEFAULT 0.025,
    exclude_list                   COLUMN_LIST DEFAULT NULL,
    clip_schema_name               VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL)
  IS
    v_xdef                         CLIP_REC_TYPE;          -- Xform DEFinition
  BEGIN
    -- compute xform definition ----------------------------------------------
    compute_clip_tail(
      r_clip_xdef                    => v_xdef,
      p_data_tref                    => NULLIF(data_schema_name||'.','.')
                                        ||data_table_name,
      p_tail_frac                    => tail_frac,
      p_excl_varr                    => exclude_list);
    FOR i IN 1..v_xdef.cnt LOOP
      v_xdef.lval_itab(i) := NULL;
      v_xdef.rval_itab(i) := NULL;
    END LOOP;

    -- populate xform definition table ---------------------------------------
    insert_clip(
      p_clip_texpr                   => NULLIF(clip_schema_name||'.','.')
                                        ||clip_table_name,
      p_clip_xdef                    => v_xdef);
  END insert_clip_trim_tail;

  ----------------------------------------------------------------------------
  --                               xform_clip                               --
  ----------------------------------------------------------------------------
  PROCEDURE xform_clip(
    clip_table_name                VARCHAR2,
    data_table_name                VARCHAR2,
    xform_view_name                VARCHAR2,
    clip_schema_name               VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL,
    xform_schema_name              VARCHAR2 DEFAULT NULL)
  IS
    v_xdef                         CLIP_REC_TYPE;
    v_xform_lstmt                  LSTMT_REC_TYPE;
  BEGIN
    -- get xform definition --------------------------------------------------
    select_clip(
      r_clip_xdef                    => v_xdef,
      p_clip_tref                    => NULLIF(clip_schema_name||'.','.')
                                        ||clip_table_name);

    -- form the statement ----------------------------------------------------
    ls_append(
      r_lstmt                        => v_xform_lstmt,
      p_txt                          => 
        'CREATE VIEW '||dbms_assert.qualified_sql_name(
        NULLIF(xform_schema_name||'.','.')||xform_view_name)||' '||
        'AS ');
    ls_append_clip(
      r_xform_lstmt                  => v_xform_lstmt,
      p_data_tref                    => NULLIF(data_schema_name||'.','.')
                                        ||data_table_name,
      p_clip_xdef                    => v_xdef);

    -- execute the statement -------------------------------------------------
    ls_exec(
      p_lstmt                        => v_xform_lstmt);
  END xform_clip;

  ----------------------------------------------------------------------------
  --                            create_miss_num                             --
  ----------------------------------------------------------------------------
  PROCEDURE create_miss_num(
    miss_table_name                VARCHAR2,
    miss_schema_name               VARCHAR2 DEFAULT NULL)
  IS
  BEGIN
    EXECUTE IMMEDIATE
      'CREATE TABLE '||dbms_assert.qualified_sql_name(
      NULLIF(miss_schema_name||'.','.')||miss_table_name)||'('||
        'col VARCHAR2(30),'||
        'val NUMBER)';
  END create_miss_num;

  ----------------------------------------------------------------------------
  --                          insert_miss_num_mean                          --
  ----------------------------------------------------------------------------
  PROCEDURE insert_miss_num_mean(
    miss_table_name                VARCHAR2,
    data_table_name                VARCHAR2,
    exclude_list                   COLUMN_LIST DEFAULT NULL,
    round_num                      PLS_INTEGER DEFAULT 6,
    miss_schema_name               VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL)
  IS
    v_xdef                         MISS_NUM_REC_TYPE;      -- Xform DEFinition
  BEGIN
    -- compute xform definition ----------------------------------------------
    compute_miss_num_mean(
      r_miss_xdef                    => v_xdef,
      p_data_tref                    => NULLIF(data_schema_name||'.','.')
                                        ||data_table_name,
      p_excl_varr                    => exclude_list,
      p_round_num                    => round_num);

    -- populate xform definition table ---------------------------------------
    insert_miss_num(
      p_miss_texpr                   => NULLIF(miss_schema_name||'.','.')
                                        ||miss_table_name,
      p_miss_xdef                    => v_xdef);
  END insert_miss_num_mean;

  ----------------------------------------------------------------------------
  --                            xform_miss_num                              --
  ----------------------------------------------------------------------------
  PROCEDURE xform_miss_num(
    miss_table_name                VARCHAR2,
    data_table_name                VARCHAR2,
    xform_view_name                VARCHAR2,
    miss_schema_name               VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL,
    xform_schema_name              VARCHAR2 DEFAULT NULL)
  IS
    v_xdef                         MISS_NUM_REC_TYPE;
    v_xform_lstmt                  LSTMT_REC_TYPE;
  BEGIN
    -- get xform definition --------------------------------------------------
    select_miss_num(
      r_miss_xdef                    => v_xdef,
      p_miss_tref                    => NULLIF(miss_schema_name||'.','.')
                                        ||miss_table_name);

    -- form the statement ----------------------------------------------------
    ls_append(
      r_lstmt                        => v_xform_lstmt,
      p_txt                          => 
        'CREATE VIEW '||dbms_assert.qualified_sql_name(
        NULLIF(xform_schema_name||'.','.')||xform_view_name)||' '||
        'AS ');
    ls_append_miss_num(
      r_xform_lstmt                  => v_xform_lstmt,
      p_data_tref                    => NULLIF(data_schema_name||'.','.')
                                        ||data_table_name,
      p_miss_xdef                    => v_xdef);

    -- execute the statement -------------------------------------------------
    ls_exec(
      p_lstmt                        => v_xform_lstmt);
  END xform_miss_num;

  ----------------------------------------------------------------------------
  --                            create_miss_cat                             --
  ----------------------------------------------------------------------------
  PROCEDURE create_miss_cat(
    miss_table_name                VARCHAR2,
    miss_schema_name               VARCHAR2 DEFAULT NULL)
  IS
  BEGIN
    EXECUTE IMMEDIATE
      'CREATE TABLE '||dbms_assert.qualified_sql_name(
      NULLIF(miss_schema_name||'.','.')||miss_table_name)||'('||
        'col VARCHAR2(30),'||
        'val VARCHAR2(4000))';
  END create_miss_cat;

  ----------------------------------------------------------------------------
  --                          insert_miss_cat_mode                          --
  ----------------------------------------------------------------------------
  PROCEDURE insert_miss_cat_mode(
    miss_table_name                VARCHAR2,
    data_table_name                VARCHAR2,
    exclude_list                   COLUMN_LIST DEFAULT NULL,
    miss_schema_name               VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL)
  IS
    v_xdef                         MISS_CAT_REC_TYPE;      -- Xform DEFinition
  BEGIN
    -- compute xform definition ----------------------------------------------
    compute_miss_cat_mode(
      r_miss_xdef                    => v_xdef,
      p_data_tref                    => NULLIF(data_schema_name||'.','.')
                                        ||data_table_name,
      p_excl_varr                    => exclude_list);

    -- populate xform definition table ---------------------------------------
    insert_miss_cat(
      p_miss_texpr                   => NULLIF(miss_schema_name||'.','.')
                                        ||miss_table_name,
      p_miss_xdef                    => v_xdef);
  END insert_miss_cat_mode;

  ----------------------------------------------------------------------------
  --                            xform_miss_cat                              --
  ----------------------------------------------------------------------------
  PROCEDURE xform_miss_cat(
    miss_table_name                VARCHAR2,
    data_table_name                VARCHAR2,
    xform_view_name                VARCHAR2,
    miss_schema_name               VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL,
    xform_schema_name              VARCHAR2 DEFAULT NULL)
  IS
    v_xdef                         MISS_CAT_REC_TYPE;
    v_xform_lstmt                  LSTMT_REC_TYPE;
  BEGIN
    -- get xform definition --------------------------------------------------
    select_miss_cat(
      r_miss_xdef                    => v_xdef,
      p_miss_tref                    => NULLIF(miss_schema_name||'.','.')
                                        ||miss_table_name);

    -- form the statement ----------------------------------------------------
    ls_append(
      r_lstmt                        => v_xform_lstmt,
      p_txt                          => 
        'CREATE VIEW '||dbms_assert.qualified_sql_name(
        NULLIF(xform_schema_name||'.','.')||xform_view_name)||' '||
        'AS ');
    ls_append_miss_cat(
      r_xform_lstmt                  => v_xform_lstmt,
      p_data_tref                    => NULLIF(data_schema_name||'.','.')
                                        ||data_table_name,
      p_miss_xdef                    => v_xdef);

    -- execute the statement -------------------------------------------------
    ls_exec(
      p_lstmt                        => v_xform_lstmt);
  END xform_miss_cat;
END dbms_data_mining_transform;
/
------------------------------------------------------------------------------
-- end of file dbmsdmxf.sql
------------------------------------------------------------------------------
