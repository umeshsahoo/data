Rem
Rem $Header: dbmsrlsa.sql 13-oct-2003.15:45:58 clei Exp $
Rem
Rem dbmsrlsa.sql
Rem
Rem Copyright (c) 1998, 2003, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      dbmsrlsa.sql - Row Level Security Adminstrative interface
Rem
Rem    DESCRIPTION
Rem      dbms_rls package for row level security adminstrative interface
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    clei        10/13/03 - ALL_COLUMNS -> ALL_ROWS
Rem    clei        08/13/03 - add security relevant column option
Rem    clei        05/28/02 - policy types, sec relevant cols, and predicate sz
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    clei        04/12/01 - support static policy 
Rem    dmwong      08/16/00 - rename UI to grouped_policies.
Rem    dmwong      02/09/00 - add groups for refresh and enable
Rem    dmwong      01/25/00 - add group extension
Rem    clei        03/16/98 -
Rem    clei        02/24/98 - Created
Rem

CREATE OR REPLACE PACKAGE dbms_rls AS

  STATIC                     CONSTANT   BINARY_INTEGER := 1;
  SHARED_STATIC              CONSTANT   BINARY_INTEGER := 2;
  CONTEXT_SENSITIVE          CONSTANT   BINARY_INTEGER := 3;
  SHARED_CONTEXT_SENSITIVE   CONSTANT   BINARY_INTEGER := 4;
  DYNAMIC                    CONSTANT   BINARY_INTEGER := 5;

  -- security relevant columns options, default is null
  ALL_ROWS                   CONSTANT   BINARY_INTEGER := 1;

  -- ------------------------------------------------------------------------
  -- add_policy -  add a row level security policy to a table or view
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the table/view, current user if NULL
  --   object_name     - name of table or view
  --   policy_name     - name of policy to be added
  --   function_schema - schema of the policy function, current user if NULL
  --   policy_function - function to generate predicates for this policy
  --   statement_types - statement type that the policy apply, default is any
  --   update_check    - policy checked against updated or inserted value?
  --   enable          - policy is enabled?
  --   static_policy   - policy is static (predicate is always the same)?
  --   policy_type     - policy type - overwrite static_policy if non-null
  --   long_predicate  - max predicate length 4000 bytes (default) or 32K
  --   sec_relevant_cols - list of security relevant columns
  --   sec_relevant_cols_opt - security relevant column option

  PROCEDURE add_policy(object_schema   IN VARCHAR2 := NULL,
                       object_name     IN VARCHAR2,
                       policy_name     IN VARCHAR2,
                       function_schema IN VARCHAR2 := NULL,
                       policy_function IN VARCHAR2,
                       statement_types IN VARCHAR2 := NULL,
                       update_check    IN BOOLEAN  := FALSE,
                       enable          IN BOOLEAN  := TRUE,
                       static_policy   IN BOOLEAN  := FALSE,
                       policy_type     IN BINARY_INTEGER := NULL,
                       long_predicate BOOLEAN  := FALSE,
                       sec_relevant_cols IN VARCHAR2  := NULL,
                       sec_relevant_cols_opt IN BINARY_INTEGER := NULL);
 
  -- drop_policy - drop a row level security policy from a table or view
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the table/view, current user if NULL
  --   object_name     - name of table or view
  --   policy_name     - name of policy to be dropped
 
  PROCEDURE drop_policy(object_schema IN VARCHAR2 := NULL,
                        object_name   IN VARCHAR2,
                        policy_name   IN VARCHAR2); 

  -- refresh_policy - invalidate all cursors associated with the policy
  --                  if no argument provides, all cursors with
  --                  policies involved will be invalidated
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the table/view, current user if NULL
  --   object_name     - name of table or view
  --   policy_name     - name of policy to be refreshed
 
  PROCEDURE refresh_policy(object_schema IN VARCHAR2 := NULL,
                           object_name   IN VARCHAR2 := NULL,
                           policy_name   IN VARCHAR2 := NULL); 

  -- enable_policy - enable or disable a security policy for a table or view
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the table/view, current user if NULL
  --   object_name     - name of table or view
  --   policy_name     - name of policy to be enabled or disabled
  --   enable          - TRUE to enable the policy, FALSE to disable the policy
 
  PROCEDURE enable_policy(object_schema IN VARCHAR2 := NULL,
                          object_name   IN VARCHAR2,
                          policy_name   IN VARCHAR2,
                          enable        IN BOOLEAN := TRUE );

  -- create_policy_group - create a policy group for a table or view
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the table/view, current user if NULL
  --   object_name     - name of table or view
  --   policy_group    - name of policy to be created

  PROCEDURE create_policy_group(object_schema IN VARCHAR2 := NULL,
                                object_name   IN VARCHAR2,
                                policy_group  IN VARCHAR2);


  -- ------------------------------------------------------------------------
  -- add_grouped_policy -  add a row level security policy to a policy group
  --                        for a table or view
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the table/view, current user if NULL
  --   object_name     - name of table or view
  --   policy_group    - name of policy group to be added
  --   policy_name     - name of policy to be added
  --   function_schema - schema of the policy function, current user if NULL
  --   policy_function - function to generate predicates for this policy
  --   statement_types - statement type that the policy apply, default is any
  --   update_check    - policy checked against updated or inserted value?
  --   enable          - policy is enabled?
  --   static_policy   - policy is static (predicate is always the same)?
  --   policy_type     - policy type - overwrite static_policy if non-null
  --   long_predicate  - max predicate length 4000 bytes (default) or 32K
  --   sec_relevant_cols - list of security relevant columns
  --   sec_relevant_cols_opt - security relevant columns option

  PROCEDURE add_grouped_policy(object_schema   IN VARCHAR2 := NULL,
                                object_name     IN VARCHAR2,
                                policy_group    IN VARCHAR2 := 'SYS_DEFAULT',
                                policy_name     IN VARCHAR2,
                                function_schema IN VARCHAR2 := NULL,
                                policy_function IN VARCHAR2,
                                statement_types IN VARCHAR2 := NULL,
                                update_check    IN BOOLEAN  := FALSE,
                                enable          IN BOOLEAN  := TRUE,
                                static_policy   IN BOOLEAN  := FALSE,
                                policy_type     IN BINARY_INTEGER := NULL,
                                long_predicate BOOLEAN  := FALSE,
                                sec_relevant_cols IN VARCHAR2  := NULL,
                              sec_relevant_cols_opt IN BINARY_INTEGER := NULL);


  -- ------------------------------------------------------------------------
  -- add_policy_context -  add a driving context to a table or view
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the table/view, current user if NULL
  --   object_name     - name of table or view
  --   namespace       - namespace of driving context
  --   attribute       - attribute of driving context

  PROCEDURE add_policy_context(object_schema   IN VARCHAR2 := NULL,
                        object_name     IN VARCHAR2,
                        namespace       IN VARCHAR2,
                        attribute       IN VARCHAR2);

  -- delete_policy_group - drop a policy group for a table or view
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the table/view, current user if NULL
  --   object_name     - name of table or view
  --   policy_group    - name of policy to be dropped

  PROCEDURE delete_policy_group(object_schema IN VARCHAR2 := NULL,
                                object_name   IN VARCHAR2,
                                policy_group  IN VARCHAR2);


  -- drop_grouped_policy - drop a row level security policy from a policy
  --                          group of a table or view
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the table/view, current user if NULL
  --   object_name     - name of table or view
  --   policy_group     - name of policy to be dropped
  --   policy_name     - name of policy to be dropped

  PROCEDURE drop_grouped_policy(object_schema IN VARCHAR2 := NULL,
                                   object_name   IN VARCHAR2,
                                   policy_group  IN VARCHAR2 := 'SYS_DEFAULT',
                                   policy_name   IN VARCHAR2);

  -- ------------------------------------------------------------------------
  -- drop_policy_context -  drop a driving context from a table or view
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the table/view, current user if NULL
  --   object_name     - name of table or view
  --   namespace       - namespace of driving context
  --   attribute       - attribute of driving context

  PROCEDURE drop_policy_context(object_schema   IN VARCHAR2 := NULL,
                        object_name     IN VARCHAR2,
                        namespace       IN VARCHAR2,
                        attribute       IN VARCHAR2);

  -- refresh_grouped_policy - invalidate all cursors associated with the policy
  --                  if no argument provides, all cursors with
  --                  policies involved will be invalidated
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the table/view, current user if NULL
  --   object_name     - name of table or view
  --   policy_group     - name of group of the policy to be refreshed
  --   policy_name     - name of policy to be refreshed

  PROCEDURE refresh_grouped_policy(object_schema IN VARCHAR2 := NULL,
                           object_name   IN VARCHAR2 := NULL,
                           group_name    IN VARCHAR2 := NULL,
                           policy_name   IN VARCHAR2 := NULL);

  -- enable_grouped_policy - enable or disable a policy for a table or view
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the table/view, current user if NULL
  --   object_name     - name of table or view
  --   policy_name     - name of policy to be enabled or disabled
  --   enable          - TRUE to enable the policy, FALSE to disable the policy

  PROCEDURE enable_grouped_policy(object_schema IN VARCHAR2 := NULL,
                          object_name   IN VARCHAR2,
                          group_name    IN VARCHAR2,
                          policy_name   IN VARCHAR2,
                          enable        IN BOOLEAN := TRUE);

  -- disable_grouped_policy - enable or disable a policy for a table or view
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the table/view, current user if NULL
  --   object_name     - name of table or view
  --   policy_name     - name of policy to be enabled or disabled
  --   enable          - TRUE to enable the policy, FALSE to disable the policy

  PROCEDURE disable_grouped_policy(object_schema IN VARCHAR2 := NULL,
                          object_name   IN VARCHAR2,
                          group_name    IN VARCHAR2,
                          policy_name   IN VARCHAR2);

END dbms_rls;
/
CREATE OR REPLACE PUBLIC SYNONYM dbms_rls FOR sys.dbms_rls
/

--
-- Grant execute right to EXECUTE_CATALOG_ROLE
--
GRANT EXECUTE ON sys.dbms_rls TO execute_catalog_role
/
