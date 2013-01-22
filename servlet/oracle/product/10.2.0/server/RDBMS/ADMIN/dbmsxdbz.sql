Rem
Rem $Header: dbmsxdbz.sql 12-apr-2004.23:58:56 abagrawa Exp $
Rem
Rem dbmsxdbz.sql
Rem
Rem Copyright (c) 2001, 2004, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      dbmsxdbz.sql - xdb zecurity 
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    abagrawa    04/12/04 - Add hierarchy_type to enable_hierarchy, is_enabled
Rem    najain      08/08/03 - add get_username
Rem    nmontoya    01/13/03 - add format arg to get_userid
Rem    nmontoya    07/09/02 - ADD dbms_xdbz.purgeLdapCache
Rem    nmontoya    05/10/02 - ADD get_acloid AND get_userid
Rem    nmontoya    03/18/02 - move internal functions to dbms_xdbz0
Rem    nmontoya    02/11/02 - remove xdb_userid, ADD xdb_username
Rem    gviswana    01/29/02 - CREATE OR REPLACE SYNONYM
Rem    spannala    12/28/01 - making dbms_xdbz public
Rem    spannala    12/27/01 - not switching users in xdb install
Rem    nmontoya    11/12/01 - remove insertres function 
Rem    nmontoya    10/17/01 - is_hierarchy_enabled function
Rem    nmontoya    09/12/01 - Add guid argument to checkprivrls
Rem    nmontoya    08/02/01 - Creation
  
CREATE OR REPLACE PACKAGE xdb.dbms_xdbz AUTHID CURRENT_USER IS 

------------
-- CONSTANTS
--
------------
NAME_FORMAT_SHORT         CONSTANT pls_integer := 1;
NAME_FORMAT_DISTINGUISHED CONSTANT pls_integer := 2;

ENABLE_CONTENTS           CONSTANT pls_integer := 1;
ENABLE_RESMETADATA        CONSTANT pls_integer := 2;

IS_ENABLED_CONTENTS       CONSTANT pls_integer := 1;
IS_ENABLED_RESMETADATA    CONSTANT pls_integer := 2;
----------------------------------------------------------------------------
-- PROCEDURE - enable_hierarchy
--     Enables XDB Hierarchy for a particular xmltype table/view
-- PARAMETERS - 
--  object_schema
--     Schema name of the xmltype table/view
--  object_name 
--     Object name of teh xmltype table/view
--  hierarchy_type
--     How to enable the hierarchy. Must be one of the following:
--     ENABLE_CONTENTS : enable hierarchy for contents i.e. this table will
--     store contents of resources in the repository
--     ENABLE_RESMETADATA : enabel hierarchy for resource metadata i.e. this
--     table will store schema based custom metadata for resources
--  If enable_hierarchy was already called on a table, then another call to
--  this procedure will not do anything. Users *CANNOT* enable hierarchy for
--  both contents as well as resource metadata.
----------------------------------------------------------------------------
PROCEDURE enable_hierarchy(object_schema IN VARCHAR2, 
                           object_name VARCHAR2,
                           hierarchy_type IN pls_integer := ENABLE_CONTENTS);

----------------------------------------------------------------------------
-- PROCEDURE - disable_hierarchy
--     Disables XDB Hierarchy for a particular xmltype table/view
-- PARAMETERS - 
--  object_schema
--     Schema name of the xmltype table/view
--  object_name 
--     Object name of teh xmltype table/view
----------------------------------------------------------------------------
PROCEDURE disable_hierarchy(object_schema IN VARCHAR2, 
                            object_name VARCHAR2);

----------------------------------------------------------------------------
-- FUNCTION - is_hierarchy_enabled
--     Checks if the XDB Hierarchy is enabled for a given xmltype table/view
-- PARAMETERS - 
--  object_schema
--     Schema name of the xmltype table/view
--  object_name 
--     Object name of the xmltype table/view
--  hierarchy_type
--     The type of hierarchy to check for. Must be one of the following:
--     IS_ENABLED_CONTENTS : if hierarchy was enabled for contents i.e.
--     enable_hierarchy was called with hierarchy_type as ENABLE_CONTENTS
--     IS_ENABLED_RESMETADATA : if hierarchy was enabled for resource 
--     metadata i.e. enable_hierarchy was called with hierarchy_type as 
--     ENABLE_RESMETADATA
-- RETURN - 
--     True, if given xmltype table/view has the XDB Hierarchy enabled of
--     the specified type
----------------------------------------------------------------------------
FUNCTION is_hierarchy_enabled(object_schema IN VARCHAR2, 
                              object_name VARCHAR2,
                              hierarchy_type IN pls_integer := IS_ENABLED_CONTENTS)
                              RETURN BOOLEAN;

---------------------------------------------
-- FUNCTION - purgeLdapCache
--     Purges ldap nickname cache
-- RETURNS
--     True if successful, false otherwise
---------------------------------------------
FUNCTION purgeLdapCache RETURN BOOLEAN;

----------------------------------------------------------------------------
-- FUNCTION - get_acloid
--     Get's an ACL OID given the XDB Hierarchy path for the ACL Resource
-- PARAMETERS - 
--  acl_path
--     ACL Resource path in the XDB Hierarchy
--  acloid [OUT] 
--     Returns the corresponding ACLOID to the given ACL Resource
-- RETURN - 
--     True, if ACLOID is succesfully retrieved
--     The typical use of this function is to pass the acloid as an 
--     argument to the SYS_CHECKACL sql operator.
----------------------------------------------------------------------------
FUNCTION get_acloid(aclpath IN VARCHAR2, 
                    acloid OUT RAW) RETURN BOOLEAN;

----------------------------------------------------------------------------
-- FUNCTION - get_userid
--     Retrieves the userid for the given user name 
-- PARAMETERS - 
--  username
--     Name of the resource user
--  userid [OUT] 
--     Returns the corresponding USERID for the given user name.
--  format (optional)
--     Format of the specified user name. By default, the name is assumed 
--     to be either a database user name or a LDAP nickname. The following 
--     are the allowed values for this argument : 
--        DBMS_XDBZ.NAME_FORMAT_SHORT
--        DBMS_XDBZ.NAME_FORMAT_DISTINGUISHED
-- RETURN - 
--     True, if USERID is succesfully retrieved
-- NOTE - 
--     The user name is first looked up in the local database, 
--     if it is not found there, and if an ldap server is available,
--     it is looked up in this latter one. In this case a GUID will be 
--     returned in USERID. 
--     The typical use of this function is to pass the userid as an 
--     argument to the SYS_CHECKACL sql operator.
----------------------------------------------------------------------------
FUNCTION get_userid(username IN VARCHAR2, 
                    userid OUT RAW,
                    format IN pls_integer := NAME_FORMAT_SHORT) RETURN BOOLEAN;

----------------------------------------------------------------------------
-- PROCEDURE - get_username
--     Retrieves the username for the given user id.
-- PARAMETERS - 
--  userid [in] 
--     user identifer
--  username [out]
--     Returns the corresponding USERNAME for the given user identifier.
-- NOTE - 
--     The user id. is first looked up in the local database, 
--     if it is not found there, and if an ldap server is available,
--     it is looked up in this latter one. 
----------------------------------------------------------------------------
PROCEDURE get_username(userid in raw, username out varchar2);

end dbms_xdbz;
/

CREATE OR REPLACE PUBLIC SYNONYM dbms_xdbz FOR xdb.dbms_xdbz;
GRANT EXECUTE ON xdb.dbms_xdbz TO PUBLIC;
show errors;

