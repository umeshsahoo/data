Rem
Rem $Header: dbmsidxu.sql 11-sep-2003.14:07:21 nfolkert Exp $
Rem
Rem dbmsidxu.sql
Rem
Rem Copyright (c) 2002, 2003, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      dbmsidxu.sql - DBMS Index Utility
Rem
Rem    DESCRIPTION
Rem      Utilities for index maintenance
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    nfolkert    09/11/03 - replace strategy parameter with concurrent
Rem    nfolkert    05/02/03 - modify comments
Rem    nfolkert    04/07/03 - add error_number, convenience interfaces
Rem    nfolkert    01/13/03 - list interface
Rem    nfolkert    01/09/03 - added single index rebuild interface
Rem    nfolkert    12/12/02 - Created
Rem

CREATE OR REPLACE PACKAGE dbms_index_utl 
AUTHID CURRENT_USER AS

  -- =========================================================================
  --                         DBMS_INDEX_UTL
  -- =========================================================================
  -- Meant for utility functions involving index rebuild.  

  -- =========================================================================
  -- PROCEDURE: BUILD_SCHEMA_INDEXES
  -- INPUT: list     -> indexes will be rebuilt for this list of schema names.
  --                    The list should take the form:
  --                    <schema> (, <schema>)*
  --                    If the schema list is NULL, then all indexes
  --                    visible to the current user will be rebuilt.
  --   just_unusable -> rebuild only the unusable index components?  If true,
  --                    then only unusable components will be rebuilt.  If 
  --                    false, all components will be rebuilt.
  --        locality -> locality of indexes to be rebuilt.  If 'GLOBAL', 
  --                    rebuild only global indexes.  If 'LOCAL', rebuild 
  --                    only local indexes.  If 'ALL', rebuild both global
  --                    and local.  Otherwise, error.
  --      concurrent -> if true, use jobs to run rebuilds concurrently,
  --                    if not, individual jobs may still run in parallel
  --  cont_after_err -> continue after errors?  If true, then indexes will 
  --                    be rebuilt even after errors.  If false, after the 
  --                    first error, processing will be halted.  
  --      max_slaves -> degree of parallelism.  Maximum number of parallel
  --                    slaves to allocate during the build (across all
  --                    jobs).  NULL (default) means the maximum available 
  --                    in the system.
  -- OUTPUT: num_errors -> number of failed index rebuilds (details on which
  --                       indexes failed are contained in the alert.log
  -- USE:  Implemented to provide an interface for finding and concurrently
  --       and parallelely rebuilding all the index components (including 
  --       entire indexes, index partitions, and index subpartitions) for a
  --       given list of schemas.
  -- =========================================================================
  PROCEDURE build_schema_indexes (
    list           IN  VARCHAR2 DEFAULT NULL,
    just_unusable  IN  BOOLEAN DEFAULT TRUE,
    locality       IN  VARCHAR2 DEFAULT 'ALL',
    concurrent     IN  BOOLEAN DEFAULT TRUE,
    cont_after_err IN  BOOLEAN DEFAULT FALSE,
    max_slaves     IN  INT DEFAULT NULL,
    num_errors     OUT NOCOPY PLS_INTEGER);

  -- Convenience interface: num_errors is captured and removed internally
  PROCEDURE build_schema_indexes (
    list           IN VARCHAR2 DEFAULT NULL,
    just_unusable  IN BOOLEAN DEFAULT TRUE,
    locality       IN VARCHAR2 DEFAULT 'ALL',
    concurrent     IN  BOOLEAN DEFAULT TRUE,
    cont_after_err IN BOOLEAN DEFAULT FALSE,
    max_slaves     IN INT DEFAULT NULL);

  -- =========================================================================
  -- PROCEDURE: BUILD_TABLE_INDEXES
  -- INPUT: list     -> indexes will be rebuilt for this list of tables.  The
  --                    list should take the form:
  --                    <owner>.<table> (, <owner>.<table>)*
  --                    If <owner> is left off, the table is assumed to be in 
  --                    the schema of the current user.
  --                    If the table list is NULL, then all indexes
  --                    visible to the current user will be rebuilt.
  --   just_unusable -> rebuild only the unusable index components?  If true,
  --                    then only unusable components will be rebuilt.  If 
  --                    false, all components will be rebuilt.
  --        locality -> locality of indexes to be rebuilt.  If 'GLOBAL', 
  --                    rebuild only global indexes.  If 'LOCAL', rebuild 
  --                    only local indexes.  If 'ALL', rebuild both global
  --                    and local.  Otherwise, error.
  --      concurrent -> if true, use jobs to run rebuilds concurrently,
  --                    if not, individual jobs may still run in parallel
  --  cont_after_err -> continue after errors?  If true, then indexes will 
  --                    be rebuilt even after errors.  If false, after the 
  --                    first error, processing will be halted.  
  --      max_slaves -> degree of parallelism.  Maximum number of parallel
  --                    slaves to allocate during the build (across all
  --                    jobs).  NULL (default) means the maximum available 
  --                    in the system.
  -- OUTPUT: num_errors -> number of failed index rebuilds (details on which
  --                       indexes failed are contained in the alert.log
  -- USE:  Implemented to provide an interface for finding and concurrently
  --       and parallelely rebuilding all the index components (including 
  --       entire indexes, index partitions, and index subpartitions) for a
  --       given list of tables.
  -- =========================================================================
  PROCEDURE build_table_indexes (
    list           IN  VARCHAR2 DEFAULT NULL,
    just_unusable  IN  BOOLEAN DEFAULT TRUE,
    locality       IN  VARCHAR2 DEFAULT 'ALL',
    concurrent     IN  BOOLEAN DEFAULT TRUE,
    cont_after_err IN  BOOLEAN DEFAULT FALSE,
    max_slaves     IN  INT DEFAULT NULL,
    num_errors     OUT NOCOPY PLS_INTEGER);

  -- Convenience interface: num_errors is captured and removed internally
  PROCEDURE build_table_indexes (
    list           IN VARCHAR2 DEFAULT NULL,
    just_unusable  IN BOOLEAN DEFAULT TRUE,
    locality       IN VARCHAR2 DEFAULT 'ALL',
    concurrent     IN  BOOLEAN DEFAULT TRUE,
    cont_after_err IN BOOLEAN DEFAULT FALSE,
    max_slaves     IN INT DEFAULT NULL);

  -- =========================================================================
  -- PROCEDURE: BUILD_INDEXES
  -- INPUT: list     -> this list of indexes will be rebuilt.  The list should
  --                    take the form:
  --                    <owner>.<index> (, <owner>.<index>)*
  --                    If <owner> is left off, the index is assumed to be in 
  --                    the schema of the current user.
  --                    If the index list is NULL, then all indexes
  --                    visible to the current user will be rebuilt.
  --   just_unusable -> rebuild only the unusable index components?  If true,
  --                    then only unusable components will be rebuilt.  If 
  --                    false, all components will be rebuilt.
  --        locality -> locality of indexes to be rebuilt.  If 'GLOBAL', 
  --                    rebuild only global indexes.  If 'LOCAL', rebuild 
  --                    only local indexes.  If 'ALL', rebuild both global
  --                    and local.  Otherwise, error.
  --      concurrent -> if true, use jobs to run rebuilds concurrently,
  --                    if not, individual jobs may still run in parallel
  --  cont_after_err -> continue after errors?  If true, then indexes will 
  --                    be rebuilt even after errors.  If false, after the 
  --                    first error, processing will be halted.  
  --      max_slaves -> degree of parallelism.  Maximum number of parallel
  --                    slaves to allocate during the build (across all
  --                    jobs).  NULL (default) means the maximum available 
  --                    in the system.
  -- OUTPUT: num_errors -> number of failed index rebuilds (details on which
  --                       indexes failed are contained in the alert.log
  -- USE:  Implemented to provide an interface for finding and concurrently
  --       and parallelely rebuilding all the index components (including 
  --       entire indexes, index partitions, and index subpartitions) for a
  --       given list of indexes.
  -- =========================================================================
  PROCEDURE build_indexes (
    list           IN  VARCHAR2 DEFAULT NULL,
    just_unusable  IN  BOOLEAN DEFAULT TRUE,
    locality       IN  VARCHAR2 DEFAULT 'ALL',
    concurrent     IN  BOOLEAN DEFAULT TRUE,
    cont_after_err IN  BOOLEAN DEFAULT FALSE,
    max_slaves     IN  INT DEFAULT NULL,
    num_errors     OUT NOCOPY PLS_INTEGER);

  -- Convenience interface: num_errors is captured and removed internally
  PROCEDURE build_indexes (
    list           IN VARCHAR2 DEFAULT NULL,
    just_unusable  IN BOOLEAN DEFAULT TRUE,
    locality       IN VARCHAR2 DEFAULT 'ALL',
    concurrent     IN  BOOLEAN DEFAULT TRUE,
    cont_after_err IN BOOLEAN DEFAULT FALSE,
    max_slaves     IN INT DEFAULT NULL);

  -- =========================================================================
  -- PROCEDURE: BUILD_INDEX_COMPONENTS
  -- INPUT: list     -> this list of index components will be rebuilt.  
  --                    The list should take the form:
  --                    <owner>.<index>.<comp> (, <owner>.<index>.<comp>)*
  --                    If <owner> is left off, the index is assumed to be in 
  --                    the schema of the current user.  <index> cannot be 
  --                    left off.
  --                    For subpartitioned indexes, if the component given is
  --                    a composite partition, all the subpartitions for that
  --                    partition will be candidates for rebuild
  --                    If the index component list is NULL, then all indexes
  --                    visible to the current user will be rebuilt.
  --   just_unusable -> rebuild only the unusable index components?  If true,
  --                    then only unusable components will be rebuilt.  If 
  --                    false, all components will be rebuilt.
  --        locality -> locality of indexes to be rebuilt.  If 'GLOBAL', 
  --                    rebuild only global indexes.  If 'LOCAL', rebuild 
  --                    only local indexes.  If 'ALL', rebuild both global
  --                    and local.  Otherwise, error.
  --      concurrent -> if true, use jobs to run rebuilds concurrently,
  --                    if not, individual jobs may still run in parallel
  --  cont_after_err -> continue after errors?  If true, then indexes will 
  --                    be rebuilt even after errors.  If false, after the 
  --                    first error, processing will be halted.  
  --      max_slaves -> degree of parallelism.  Maximum number of parallel
  --                    slaves to allocate during the build (across all
  --                    jobs).  NULL (default) means the maximum available 
  --                    in the system.
  -- OUTPUT: num_errors -> number of failed index rebuilds (details on which
  --                       indexes failed are contained in the alert.log
  -- USE:  Implemented to provide an interface for finding and concurrently
  --       and parallelely rebuilding a given list of index components 
  --       (partitions and subparts).  This will not rebuild entire indexes.
  -- =========================================================================
  PROCEDURE build_index_components (
    list           IN  VARCHAR2 DEFAULT NULL,
    just_unusable  IN  BOOLEAN DEFAULT TRUE,
    locality       IN  VARCHAR2 DEFAULT 'ALL',
    concurrent     IN  BOOLEAN DEFAULT TRUE,
    cont_after_err IN  BOOLEAN DEFAULT FALSE,
    max_slaves     IN  INT DEFAULT NULL,
    num_errors     OUT NOCOPY PLS_INTEGER);

  -- Convenience interface: num_errors is captured and removed internally
  PROCEDURE build_index_components (
    list           IN VARCHAR2 DEFAULT NULL,
    just_unusable  IN BOOLEAN DEFAULT TRUE,
    locality       IN VARCHAR2 DEFAULT 'ALL',
    concurrent     IN  BOOLEAN DEFAULT TRUE,
    cont_after_err IN BOOLEAN DEFAULT FALSE,
    max_slaves     IN INT DEFAULT NULL);


  -- =========================================================================
  -- PROCEDURE: BUILD_TABLE_COMPONENT_INDEXES
  -- INPUT: list     -> indexes will be rebuilt for this list of table 
  --                    components.  The list should take the form:
  --                    <owner>.<table>.<comp> (, <owner>.<table>.<comp>)*
  --                    If <owner> is left off, the table is assumed to be in 
  --                    the schema of the current user.  <table> cannot be 
  --                    left off.
  --                    For subpartitioned tables, if the component given is
  --                    a composite partition, all the subpartitions for that
  --                    partition will be candidates for rebuild
  --                    If the table component list is NULL, then all indexes
  --                    visible to the current user will be rebuilt.
  --   just_unusable -> rebuild only the unusable index components?  If true,
  --                    then only unusable components will be rebuilt.  If 
  --                    false, all components will be rebuilt.
  --        locality -> locality of indexes to be rebuilt.  If 'GLOBAL', 
  --                    rebuild only global indexes.  If 'LOCAL', rebuild 
  --                    only local indexes.  If 'ALL', rebuild both global
  --                    and local.  Otherwise, error.
  --      concurrent -> if true, use jobs to run rebuilds concurrently,
  --                    if not, individual jobs may still run in parallel
  --  cont_after_err -> continue after errors?  If true, then indexes will 
  --                    be rebuilt even after errors.  If false, after the 
  --                    first error, processing will be halted.  
  --      max_slaves -> degree of parallelism.  Maximum number of parallel
  --                    slaves to allocate during the build (across all
  --                    jobs).  NULL (default) means the maximum available 
  --                    in the system.
  -- OUTPUT: num_errors -> number of failed index rebuilds (details on which
  --                       indexes failed are contained in the alert.log
  -- USE:  Implemented to provide an interface for finding and concurrently
  --       and parallelely rebuilding all the index components (including 
  --       index partitions, and index subpartitions) for a given list of
  --       table components.
  -- =========================================================================
  PROCEDURE build_table_component_indexes (
    list           IN  VARCHAR2 DEFAULT NULL,
    just_unusable  IN  BOOLEAN DEFAULT TRUE,
    locality       IN  VARCHAR2 DEFAULT 'ALL',
    concurrent     IN  BOOLEAN DEFAULT TRUE,
    cont_after_err IN  BOOLEAN DEFAULT FALSE,
    max_slaves     IN  INT DEFAULT NULL,
    num_errors     OUT NOCOPY PLS_INTEGER);

  -- Convenience interface: num_errors is captured and removed internally
  PROCEDURE build_table_component_indexes (
    list           IN VARCHAR2 DEFAULT NULL,
    just_unusable  IN BOOLEAN DEFAULT TRUE,
    locality       IN VARCHAR2 DEFAULT 'ALL',
    concurrent     IN  BOOLEAN DEFAULT TRUE,
    cont_after_err IN BOOLEAN DEFAULT FALSE,
    max_slaves     IN INT DEFAULT NULL);

  -- =========================================================================
  -- PROCEDURE: MULTI_LEVEL_BUILD
  -- INPUT:
  --     schema_list -> indexes will be rebuilt for this list of schema names.
  --                    The list should take the form:
  --                    <schema> (, <schema>)*
  --      table_list -> indexes will be rebuilt for this list of tables.  The
  --                    list should take the form:
  --                    <owner>.<table> (, <owner>.<table>)*
  --                    If <owner> is left off, the table is assumed to be in 
  --                    the schema of the current user.
  --      index_list -> this list of indexes will be rebuilt.  The list should
  --                    take the form:
  --                    <owner>.<index> (, <owner>.<index>)*
  --                    If <owner> is left off, the index is assumed to be in 
  --                    the schema of the current user.
  --   idx_comp_list -> this list of index components will be rebuilt.  
  --                    The list should take the form:
  --                    <owner>.<index>.<comp> (, <owner>.<index>.<comp>)*
  --                    If <owner> is left off, the index is assumed to be in 
  --                    the schema of the current user.  <index> cannot be 
  --                    left off.
  --   tab_comp_list -> indexes will be rebuild for this list of table 
  --                    components.  The list should take the form:
  --                    <owner>.<table>.<comp> (, <owner>.<table>.<comp>)*
  --                    If <owner> is left off, the table is assumed to be in 
  --                    the schema of the current user.  <table> cannot be 
  --                    left off.
  -- NOTE: if all lists are NULL, then all indexes visible to the current 
  --       user will be rebuilt.
  --   just_unusable -> rebuild only the unusable index components?  If true,
  --                    then only unusable components will be rebuilt.  If 
  --                    false, all components will be rebuilt.
  --        locality -> locality of indexes to be rebuilt.  If 'GLOBAL', 
  --                    rebuild only global indexes.  If 'LOCAL', rebuild 
  --                    only local indexes.  If 'ALL', rebuild both global
  --                    and local.  Otherwise, error.
  --      concurrent -> if true, use jobs to run rebuilds concurrently,
  --                    if not, individual jobs may still run in parallel
  --  cont_after_err -> continue after errors?  If true, then indexes will 
  --                    be rebuilt even after errors.  If false, after the 
  --                    first error, processing will be halted.  
  --      max_slaves -> degree of parallelism.  Maximum number of parallel
  --                    slaves to allocate during the build (across all
  --                    jobs).  NULL (default) means the maximum available 
  --                    in the system.
  -- OUTPUT: num_errors -> number of failed index rebuilds (details on which
  --                       indexes failed are contained in the alert.log
  -- USE:  Implemented to provide an interface for finding and concurrently
  --       and parallelely rebuilding all the index components (including 
  --       index partitions, and index subpartitions) for several lists of
  --       schema objects.  This function has an advantage over others in
  --       that it provides the maximum amount of concurrency possible by 
  --       removing serialization forced by making sequential calls to 
  --       different rebuild functions.
  -- =========================================================================
  PROCEDURE multi_level_build (
    schema_list    IN  VARCHAR2 DEFAULT NULL,
    table_list     IN  VARCHAR2 DEFAULT NULL,
    index_list     IN  VARCHAR2 DEFAULT NULL,
    idx_comp_list  IN  VARCHAR2 DEFAULT NULL,
    tab_comp_list  IN  VARCHAR2 DEFAULT NULL,
    just_unusable  IN  BOOLEAN DEFAULT TRUE,
    locality       IN  VARCHAR2 DEFAULT 'ALL',
    concurrent     IN  BOOLEAN DEFAULT TRUE,
    cont_after_err IN  BOOLEAN DEFAULT FALSE,
    max_slaves     IN  INT DEFAULT NULL,
    num_errors     OUT NOCOPY PLS_INTEGER);

  -- Convenience interface: num_errors is captured and removed internally
  PROCEDURE multi_level_build (
    schema_list    IN VARCHAR2 DEFAULT NULL,
    table_list     IN VARCHAR2 DEFAULT NULL,
    index_list     IN VARCHAR2 DEFAULT NULL,
    idx_comp_list  IN VARCHAR2 DEFAULT NULL,
    tab_comp_list  IN VARCHAR2 DEFAULT NULL,
    just_unusable  IN BOOLEAN DEFAULT TRUE,
    locality       IN VARCHAR2 DEFAULT 'ALL',
    concurrent     IN  BOOLEAN DEFAULT TRUE,
    cont_after_err IN BOOLEAN DEFAULT FALSE,
    max_slaves     IN INT DEFAULT NULL);

END dbms_index_utl;
/
CREATE OR REPLACE PUBLIC SYNONYM dbms_index_utl FOR SYS.dbms_index_utl
/
GRANT EXECUTE ON dbms_index_utl TO PUBLIC
/

