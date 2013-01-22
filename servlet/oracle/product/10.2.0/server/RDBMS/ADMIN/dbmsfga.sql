Rem
Rem $Header: dbmsfga.sql 23-jul-2004.04:47:19 gmulagun Exp $
Rem
Rem dbmsfga.sql
Rem
Rem Copyright (c) 1900, 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmsfga.sql - Package declaration of Fine Grained Access Control
Rem
Rem    DESCRIPTION
Rem      This file contains the declaration of the package DBMS_FGA that
Rem      is used to administer
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    gmulagun    07/21/04 - bug 3784246 XML format records 
Rem    rvissapr    09/10/03 - bug 3095609 - add all_columns 
Rem    nmanappa    08/29/03 - Bug 2826225 - Add audit_trail arg to add_policy 
Rem    rvissapr    12/19/02 - add default NULL to policy text
Rem    rvissapr    12/12/02 - fix bug 2594538
Rem    rvissapr    06/17/02 - add stmttype
Rem    dmwong      07/13/01 - set default of policy condition to 1=1.
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    dmwong      04/10/00 - dbms package DBMS_FGA for fine grained auditing
Rem    dmwong      01/00/00 - Created
Rem


CREATE OR REPLACE PACKAGE dbms_fga AS
  -- ------------------------------------------------------------------------

  -- CONSTANTS
  --
  EXTENDED    CONSTANT PLS_INTEGER := 1;
  DB          CONSTANT PLS_INTEGER := 2;
  DB_EXTENDED CONSTANT PLS_INTEGER := 3;             -- (default)
  XML         CONSTANT PLS_INTEGER := 4;
  
  ALL_COLUMNS CONSTANT BINARY_INTEGER := 1;
  ANY_COLUMNS CONSTANT BINARY_INTEGER := 0;          -- (default)

  -- add_policy -  add a fine grained auditing policy to a table or view
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the table/view, current user if NULL
  --   object_name     - name of table or view
  --   policy_name     - name of policy to be added
  --   audit_column    - column to be audited
  --   audit_condition - predicates for this policy
  --   handler_schema  - schema where the event handler procedure is
  --   handler_module  - name of the event handler
  --   enable          - policy is enabled by DEFAULT
  --   statement_type  - statement type a policy applies to (default SELECT)
  --   audit_trail     - Write sqltext and sqlbind into audit trail by default (DB_EXTENDED)
  --   audit_column_options - option of using 'Any' or 'All' on audit columns for the policy

  PROCEDURE add_policy(object_schema   IN VARCHAR2 := NULL,
                       object_name     IN VARCHAR2,
                       policy_name     IN VARCHAR2,
                       audit_condition IN VARCHAR2 := NULL,
                       audit_column    IN VARCHAR2 := NULL,
                       handler_schema  IN VARCHAR2 := NULL,
                       handler_module  IN VARCHAR2 := NULL,
                       enable          IN BOOLEAN  := TRUE,
                       statement_types IN VARCHAR2 := 'SELECT',
                       audit_trail     IN PLS_INTEGER  := 3,
                       audit_column_opts IN BINARY_INTEGER DEFAULT 0);
 
  -- drop_policy - drop a fine grained auditing policy from a table or view
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the table/view, current user if NULL
  --   object_name     - name of table or view
  --   policy_name     - name of policy to be dropped
 
  PROCEDURE drop_policy(object_schema IN VARCHAR2 := NULL,
                        object_name   IN VARCHAR2,
                        policy_name   IN VARCHAR2); 

  -- enable_policy - enable a security policy for a table or view
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the table/view, current user if NULL
  --   object_name     - name of table or view
  --   policy_name     - name of policy to be enabled or disabled
 
  PROCEDURE enable_policy(object_schema IN VARCHAR2 := NULL,
                          object_name   IN VARCHAR2,
                          policy_name   IN VARCHAR2,
                          enable        IN BOOLEAN := TRUE);

  -- disable_policy - disable a security policy for a table or view
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the table/view, current user if NULL
  --   object_name     - name of table or view
  --   policy_name     - name of policy to be enabled or disabled
 
  PROCEDURE disable_policy(object_schema IN VARCHAR2 := NULL,
                           object_name   IN VARCHAR2,
                           policy_name   IN VARCHAR2);

END dbms_fga;
/
CREATE OR REPLACE PUBLIC SYNONYM dbms_fga FOR sys.dbms_fga
/

--
-- Grant execute right to EXECUTE_CATALOG_ROLE
--
GRANT EXECUTE ON sys.dbms_fga TO execute_catalog_role
/
