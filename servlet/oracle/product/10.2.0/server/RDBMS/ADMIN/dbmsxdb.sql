Rem
Rem $Header: dbmsxdb.sql 18-nov-2005.16:05:22 rtjoa Exp $
Rem
Rem dbmsxdb.sql
Rem
Rem Copyright (c) 2001, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmsxdb.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rtjoa       11/15/05 - Add setListenerEndPoint API 
Rem    pnath       11/24/04 - PL/SQL API to get and set ports 
Rem    abagrawa    08/03/04 - Add new update resource metadata APIs 
Rem    abagrawa    02/21/04 - Add SB Res metadata APIs 
Rem    spannala    06/10/03 - adding cleansgaforupgrade
Rem    najain      06/05/03 - add getxdb_tablespace
Rem    najain      06/02/03 - add movexdb_tablespace
Rem    nmontoya    01/28/03 - ADD ExistsResource
Rem    nmontoya    10/28/02 - ADD optional sticky arg TO createres. FROM REF
Rem    thoang      08/15/02 - added csid parameter to CreateResource methods 
Rem    rmurthy     10/04/02 - add get_resoid, create_oidpath
Rem    njalali     08/13/02 - removing SET statements
Rem    njalali     06/27/02 - added qmxseq to qmxsq migration functions
Rem    spannala    06/03/02 - adding forced delete
Rem    sichandr    04/17/02 - fix createresource from bfile
Rem    nmontoya    02/12/02 - remove privilege constants
Rem    gviswana    01/29/02 - CREATE OR REPLACE SYNONYM
Rem    nmontoya    01/23/02 - added createresource from BFILE
Rem    nmontoya    01/24/02 - protype change FOR acl_check
Rem                             checkprivileges, changeprivileges
Rem    sidicula    01/29/02 - getPrivileges to return Privilege XOBD
Rem    njalali     01/16/02 - added createresource from REF
Rem    nmontoya    01/19/02 - change comment FOR dbms_xdb.link
Rem    nmontoya    01/10/02 - prototype change IN dbms_xdb.link
Rem    spannala    01/11/02 - making all systems types have standard TOIDs
Rem    nmontoya    01/03/02 - added createresource for xmltype and clob
Rem    nmontoya    01/04/02 - ADD changeprivileges
Rem    nmontoya    12/06/01 - ADD getprivileges
Rem    spannala    12/27/01 - script to run in arbitrary schema with dba
Rem    nmontoya    11/13/01 - add createfolder
Rem    nmontoya    10/23/01 - xdb configuration get fix
Rem    kmuthiah    10/19/01 - add RebuildHierarchicalIndex
Rem    nmontoya    10/17/01 - setacl function
Rem    nmontoya    10/15/01 - xdb configuration api
Rem    nmontoya    09/17/01 - Created
Rem

create or replace type xdb.xdb_privileges OID '0000000000000000000000000002014E'
as varray(1000) of VARCHAR2(200)
/
show errors;

Grant execute on xdb.xdb_privileges to public with grant option;

CREATE OR REPLACE PACKAGE xdb.dbms_xdb AUTHID CURRENT_USER IS 
   
------------
-- CONSTANTS
--
------------
DELETE_RESOURCE        CONSTANT NUMBER := 1;
DELETE_RECURSIVE       CONSTANT NUMBER := 2;
DELETE_FORCE           CONSTANT NUMBER := 3;
DELETE_RECURSIVE_FORCE CONSTANT NUMBER := 4;

DELETE_RES_METADATA_CASCADE   CONSTANT NUMBER := 1;
DELETE_RES_METADATA_NOCASCADE CONSTANT NUMBER := 2;

-- Constant number for 1st argument of setListenerEndPoint
XDB_ENDPOINT_HTTP  CONSTANT NUMBER := 1;
XDB_ENDPOINT_HTTP2 CONSTANT NUMBER := 2;

-- Constant number for 4th argument of setListenerEndPoint
XDB_PROTOCOL_TCP   CONSTANT NUMBER := 1;
XDB_PROTOCOL_TCPS  CONSTANT NUMBER := 2;

---------------------------------------------
-- FUNCTION - Lock
--     Gets a webdav-like lock for XDB resource given its path
-- PARAMETERS -
--  abspath
--     Absolute path in the Hierarchy of the resource 
--  depthzero
--     depth zero boolean
--  shared
--     shared boolean
-- RETURNS -
--     Returns TRUE if successful
---------------------------------------------
FUNCTION LockResource(abspath IN VARCHAR2, depthzero IN BOOLEAN, 
                                           shared IN boolean) 
              RETURN boolean;

---------------------------------------------
-- PROCEDURE - GetLockToken
--     Gets lock token for current user for XDB resource given its path
-- PARAMETERS -
--  abspath
--     Absolute path in the Hierarchy of the resource 
--  locktoken (OUT)
--     Returns lock token
---------------------------------------------
PROCEDURE GetLockToken(abspath IN VARCHAR2, locktoken OUT VARCHAR2);

---------------------------------------------
-- FUNCTION - Unlock
--     Removes lock for XDB resource given lock token
-- PARAMETERS -
--  abspath
--     Absolute path in the Hierarchy of the resource 
--  delToken
--     Lock token name to be removed
-- RETURNS -
--     Returns TRUE if successful
---------------------------------------------
FUNCTION UnlockResource(abspath IN VARCHAR2, deltoken IN VARCHAR2) 
                        RETURN boolean;

---------------------------------------------
-- FUNCTION - ExistsResource(VARCHAR2)
--     Given a string, returns true if the resource exists in the hierarchy.
-- PARAMETERS - 
--  abspath
--     Absolute path to the resource
-- RETURNS -
--     Returns TRUE if resource was found in the hierarchy.
---------------------------------------------
FUNCTION ExistsResource(abspath IN VARCHAR2) RETURN BOOLEAN;

---------------------------------------------
-- FUNCTION - CreateResource(VARCHAR2, VARCHAR2)
--     Given a string, inserts a new resource into the hierarchy with
--     the string as the contents.
-- PARAMETERS - 
--  abspath
--     Absolute path to the resource
--  data
--     String buffer containing the resource contents
-- RETURNS -
--     Returns TRUE if resource was successfully inserted or updated
---------------------------------------------
FUNCTION CreateResource(abspath IN VARCHAR2, 
                        data IN VARCHAR2) RETURN BOOLEAN;

---------------------------------------------
-- FUNCTION - CreateResource(VARCHAR2, SYS.XMLTYPE)
--     Given an XMLTYPE, inserts a new resource into the hierarchy with
--     the XMLTYPE as the contents.
-- PARAMETERS - 
--  abspath
--     Absolute path to the resource
--  data
--     XMLTYPE containing the resource contents
-- RETURNS -
--     Returns TRUE if resource was successfully inserted or updated
---------------------------------------------
FUNCTION CreateResource(abspath IN VARCHAR2, 
                        data IN SYS.XMLTYPE) RETURN BOOLEAN;

---------------------------------------------
-- FUNCTION - CreateResource(VARCHAR2, REF SYS.XMLTYPE, BOOLEAN)
--     Given a PREF to an existing XMLType row, inserts a new resource
--     whose contents point directly at that row.  That row should
--     not already exist inside another resource.
-- PARAMETERS - 
--  abspath
--     Absolute path to the resource
--  data
--     REF to the XMLType row containing the resource contents
--  sticky
--     If TRUE creates a sticky REF, otherwise non-sticky.
--     Default is TRUE (for backwards compatibility).
-- RETURNS -
--     Returns TRUE if resource was successfully inserted or updated
---------------------------------------------
FUNCTION CreateResource(abspath IN VARCHAR2, 
                        data IN REF SYS.xmltype, 
                        sticky IN BOOLEAN := TRUE) RETURN BOOLEAN;

---------------------------------------------
-- FUNCTION - CreateResource(VARCHAR2, CLOB)
--     Given a CLOB, inserts a new resource into the hierarchy with
--     the CLOB as the contents.
-- PARAMETERS - 
--  abspath
--     Absolute path to the resource
--  data
--     CLOB containing the resource contents
-- RETURNS -
--     Returns TRUE if resource was successfully inserted or updated
---------------------------------------------
FUNCTION CreateResource(abspath IN VARCHAR2, 
                        data IN CLOB) RETURN BOOLEAN;

---------------------------------------------
-- FUNCTION - CreateResource(VARCHAR2, BFILE, NUMBER)
--     Given a BFILE, inserts a new resource into the hierarchy with
--     the contents loaded from the BFILE.
-- PARAMETERS - 
--  abspath
--     Absolute path to the resource
--  data
--     BFILE containing the resource contents
--  csid
--     character set id of the input bfile
-- RETURNS -
--     Returns TRUE if resource was successfully inserted or updated
---------------------------------------------
FUNCTION CreateResource(abspath IN VARCHAR2, 
                        data IN BFILE,
                        csid IN NUMBER := 0) RETURN BOOLEAN;

---------------------------------------------
-- FUNCTION - CreateResource(VARCHAR2, BLOB, NUMBER)
--     Given a BLOB, inserts a new resource into the hierarchy with
--     the BLOB as the contents.
-- PARAMETERS -
--  abspath
--     Absolute path to the resource
--  data
--     BLOB containing the resource contents
--  csid
--     character set id of the input blob
-- RETURNS -
--     Returns TRUE if resource was successfully inserted or updated
---------------------------------------------
FUNCTION CreateResource(abspath IN VARCHAR2,
                        data IN BLOB,
                        csid IN NUMBER := 0) RETURN BOOLEAN;


---------------------------------------------
-- FUNCTION - CreateFolder
--     Creates a folder in the Repository 
-- PARAMETERS - 
--  abspath
--     Absolute path iin the Hierarchy were the resource will be stored
-- RETURNS -
--     Returns TRUE if folder was created succesfully in Repository
---------------------------------------------
FUNCTION CreateFolder(abspath IN VARCHAR2) RETURN BOOLEAN;

---------------------------------------------
-- PROCEDURE - DeleteResource
--     Deletes a resource from the Hierarchy
-- PARAMETERS - 
--  abspath
--     Absolute path in the Hierarchy for resource to be deleted
--  delete_option : one of the following
--    DELETE_RESOURCE ::
--      delete the resource alone. Fails if the resource has children
--    DELETE_RECURSIVE ::
--      delete the resource with the children, if any.
--    DELETE_FORCE ::
--      delete the resource even if the object it contains is invalid.
--    DELETE_RECURSIVE_FORCE ::
--      delete the resource and all children, ignoring any errors raised
--      by contained objects being invalid
---------------------------------------------
PROCEDURE DeleteResource(abspath IN VARCHAR2,
                         delete_option IN pls_integer := DELETE_RESOURCE);

---------------------------------------------
-- PROCEDURE - Link
--     Creates a link between two XDB resources
-- PARAMETERS -
--  srcpath
--     Absolute path in the Hierarchy of the source resource 
--  linkfolder
--     Absolute path in the Hierarchy of the link folder  
--  linkname
--     Name of the child to be linked
---------------------------------------------
PROCEDURE Link(srcpath IN VARCHAR2, linkfolder IN VARCHAR2,
               linkname IN VARCHAR2);

---------------------------------------------
-- PROCEDURE - Rename
--     Renames a XDB resource
-- PARAMETERS -
--  srcpath
--     Absolute path in the Hierarchy of the source resource 
--  destfolder
--     Absolute path in the Hierarchy of the dest folder  
--  newname
--     Name of the child in the destination folder
---------------------------------------------
PROCEDURE RenameResource(srcpath IN VARCHAR2, destfolder IN VARCHAR2,
                         newname IN VARCHAR2);

---------------------------------------------
-- FUNCTION - getAclDoc
--     gets acl document that protects resource given in path
-- PARAMETERS -
--  abspath
--     Absolute path in the Hierarchy of the resource whose acl doc is required
-- RETURNS -
--     Returns xmltype for acl document
---------------------------------------------
FUNCTION getAclDocument(abspath IN VARCHAR2) RETURN sys.xmltype;

---------------------------------------------
-- FUNCTION - getPrivileges
--     Gets all system and user privileges granted to the current user 
--     on the given XDB resource
-- PARAMETERS -
--  res_path
--     Absolute path in the Hierarchy for XDB resource 
-- RETURNS -
--     Returns a XMLType instance of <privilege> element 
--     which contains the list of all (leaf) privileges 
--     granted on this resource to the current user.
--     It includes all granted system and user privileges.
--     Example : 
--       <privilege xmlns="http://xmlns.oracle.com/xdb/acl.xsd"
--                  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
--                  xsi:schemaLocation="http://xmlns.oracle.com/xdb/acl.xsd 
--                                      http://xmlns.oracle.com/xdb/acl.xsd"
--                  xmlns:dav="DAV:"
--                  xmlns:emp="http://www.example.com/emp.xsd">
--          <read-contents/>
--          <read-properties/>
--          <resolve/>
--          <dav:read-acl/>
--          <emp:Hire/>
--       </privilege>
---------------------------------------------
FUNCTION getPrivileges(res_path IN VARCHAR2) RETURN sys.xmltype;

---------------------------------------------
-- FUNCTION - changePrivileges
--     change access privileges on given XDB resource 
-- PARAMETERS -
--  res_path
--     Absolute path in the Hierarchy for XDB resource 
--  ace 
--     an XMLType instance of the <ace> element which specifies 
--     the <principal>, the operation <grant> and the list of 
--     privileges.
--     If no ACE with the same principal and the same operation 
--     (grant/deny) already exists in the ACL, the new ACE is added 
--     at the end of the ACL.
--  replace
--    This argument determines the result of changePrivileges if 
--    an ACE with the same principal and same operation (grant/deny) 
--    already exists in the ACL.
--  
--    If set to TRUE, 
--       the old ACE is replaced with the new one.
--    else
--       the privileges of the old and new ACEs are combined into a 
--       single ACE.
--
-- RETURNS -
--     Returns positive integer if ACL was successfully modified
---------------------------------------------
FUNCTION changePrivileges(res_path IN VARCHAR2, 
                          ace      IN xmltype)
                          RETURN pls_integer;

---------------------------------------------
-- FUNCTION - checkPrivileges
--     checks access privileges granted on specified XDB resource
-- PARAMETERS -
--  res_path
--     Absolute path in the Hierarchy for XDB resource 
--  privs
--     Requested set of access privileges  
--     This argument is a XMLType instance of the <privilege> element.
-- RETURNS -
--     Returns positive integer if all requested privileges granted
---------------------------------------------
FUNCTION checkPrivileges(res_path IN VARCHAR2, 
                         privs IN xmltype)
                         RETURN pls_integer;
---------------------------------------------
-- PROCEDURE - setFTPPort
--     sets the FTP port to new value
-- PARAMETERS -
--     new_port
--         value that the ftp port will be set to
---------------------------------------------

PROCEDURE setFTPPort(new_port IN NUMBER);

---------------------------------------------
-- FUNCTION - getFTPPort
--     gets the current value of FTP port
-- PARAMETERS -
--     none
-- RETURNS
--     ftp_port
--         current value of ftp-port
---------------------------------------------

FUNCTION getFTPPort RETURN NUMBER;

---------------------------------------------
-- PROCEDURE - setHTTPPort
--     sets the HTTP port to new value
-- PARAMETERS -
--     new_port
--         value that the http port will be set to
---------------------------------------------

PROCEDURE setHTTPPort(new_port IN NUMBER);

---------------------------------------------
-- FUNCTION - getHTTPPort
--     gets the current value of HTTP port
-- PARAMETERS -
--     none
-- RETURNS
--     http_port
--         current value of http-port
---------------------------------------------

FUNCTION getHTTPPort RETURN NUMBER;

---------------------------------------------
-- PROCEDURE - setListenerEndPoint
--    sets the listener (HTTP/HTTP2) end point
-- PARAMETERS -
--    endpoint
--         Either constant XDB_ENDPOINT_HTTP or XDB_ENDPOINT_HTTP2
--    host
--         The hostname, e.g. 'localhost', '127.0.0.1', NULL, 'stadn19'.
--    port
--         The port number
--    protocol
--         Either constant XDB_PROTOCOL_TCP or XDB_PROTOCOL_TCPS
---------------------------------------------

PROCEDURE setListenerEndPoint(endpoint IN number, host IN varchar2, 
                              port IN number, protocol IN number);

---------------------------------------------
-- PROCEDURE - getListenerEndPoint
--    get the listener end points (HTTP/HTTP2)
-- PARAMETERS -
--    endpoint
--         Either constant XDB_ENDPOINT_HTTP or XDB_ENDPOINT_HTTP2
--    port
--         The port of the listener
--    host
--         The hostname
--    protocol
--         Either constant XDB_PROTOCOL_TCP or XDB_PROTOCOL_TCPS
---------------------------------------------

PROCEDURE getListenerEndPoint(endpoint IN NUMBER, host OUT VARCHAR2,
                              port OUT NUMBER, protocol OUT NUMBER);

---------------------------------------------
-- PROCEDURE - setListenerLocalAccess
--    set/reset the all listeners (HTTP and HTTP2) local access
-- PARAMETERS -
--    l_access
--         Either TRUE or FALSE
---------------------------------------------
PROCEDURE setListenerLocalAccess(l_access boolean);

---------------------------------------------
-- PROCEDURE - setacl
--     sets the ACL on given XDB resource to be the specified in the acl path
-- PARAMETERS -
--  res_path
--     Absolute path in the Hierarchy for XDB resource 
--  acl_path
--     Absolute path in the Hierarchy for XDB acl 
---------------------------------------------
PROCEDURE setacl(res_path IN VARCHAR2, acl_path IN VARCHAR2); 

---------------------------------------------
-- FUNCTION - AclCheckPrivileges
--     checks access privileges granted by specified ACL document
-- PARAMETERS -
--  acl_path
--     Absolute path in the Hierarchy for ACL document
--  owner
--     Resource owner name. The pseudo user "XDBOWNER" is replaced 
--     by this user during ACL privilege resolution
--  privs
--     Requested set of access privileges  
--     This argument is a XMLType instance of the <privilege> element.
-- RETURNS -
--     Returns positive integer if all requested privileges granted
---------------------------------------------
FUNCTION AclCheckPrivileges(acl_path IN VARCHAR2, 
                            owner IN VARCHAR2, 
                            privs IN xmltype)
                            RETURN pls_integer;

---------------------------------------------
-- PROCEDURE - refresh
--     Refreshes the session configuration with the latest configuration
---------------------------------------------
PROCEDURE cfg_refresh;

---------------------------------------------
-- FUNCTION - get
--     retrieves the xdb configuration
-- RETURNS -
--     XMLType for xdb configuration
---------------------------------------------
FUNCTION cfg_get RETURN sys.xmltype;

---------------------------------------------
-- PROCEDURE - update
--     Updates the xdb configuration with the input xmltype document
-- PARAMETERS -
--  xdbconfig
---     XMLType for xdb configuration
--------------------------------------------
PROCEDURE cfg_update(xdbconfig IN sys.xmltype);

---------------------------------------------
-- PROCEDURE - RebuildHierarchicalIndex
--     Rebuilds the hierarchical Index; Used after
--     imp/exp since we do cannot export data from
--     xdb$h_index table since it contains rowids
-- PARAMETERS -
--
---------------------------------------------
PROCEDURE RebuildHierarchicalIndex;

---------------------------------------------
-- PROCEDURE - MigrateColumnFrom9201
--     Migrates one XMLType column from the 9.2.0.1 format to the 9.2.0.2
--     format.  The column must exist inside an object table and must be of
--     type XMLType, schema-based, and stored in object-relational format.
--     An exclusive lock is taken on the table before the column is migrated.
-- PARAMETERS -
--     owner       (IN) - Database user who owns the XMLType table
--     table_name  (IN) - Name of the table
--     column_name (IN) - Name of the XMLType column within the table
--                        (e.g. "FOO"."BAR")
--
---------------------------------------------
PROCEDURE MigrateColumnFrom9201(owner       IN VARCHAR2,
                                table_name  IN VARCHAR2,
                                column_name IN VARCHAR2);

---------------------------------------------
-- PROCEDURE - MigrateTableFrom9201
--     Migrates one XMLType table from the 9.2.0.1 format to the 9.2.0.2
--     format.  The table must have XMLType as its rowtype, and the XMLType
--     row must be schema-based and stored in object-relational format.
--     An exclusive lock is taken on the table before it is operated on.
-- PARAMETERS - 
--     owner      (IN) - Database user who owns the XMLType table
--     table_name (IN) - Name of the XMLType table
--
---------------------------------------------
PROCEDURE MigrateTableFrom9201(owner       IN VARCHAR2, 
                               table_name  IN VARCHAR2);

---------------------------------------------
-- PROCEDURE - MigrateAllXmlFrom9201
--     Migrates all object-relational XMLType tables and
--     XMLType columns from the 9.2.0.1 format to the 9.2.0.2 format.
--     An exclusive lock is taken each table before it is
--     operated on.
-- PARAMETERS - None.
--
---------------------------------------------
PROCEDURE MigrateAllXmlFrom9201;

---------------------------------------------
-- FUNCTION - GetResOID(abspath VARCHAR2)
--     Returns the OID of the resource, given its absolute path 
--
-- PARAMETERS -
--  abspath
--     Absolute path to the resource
-- RETURNS -
--     OID of resource if present, NULL otherwise
---------------------------------------------
FUNCTION GetResOID(abspath IN VARCHAR2) RETURN RAW;

---------------------------------------------
-- FUNCTION - CreateOIDPath(oid RAW)
--     Returns the OID-based virtual path to the resource
--
-- PARAMETERS -
--  OID
--     OID of the resource 
-- RETURNS -
--     the OID-based virtual path to the resource
---------------------------------------------
FUNCTION CreateOIDPath(oid IN RAW) RETURN VARCHAR2;


---------------------------------------------
-- PROCEDURE - cleansgaforupgrade
--
-- PARAMETERS -
--   None
-- RETURNS -
--     nothing.
-- Internal procedure for clean sga after upgrade
-- Do Not Document
---------------------------------------------
PROCEDURE CleanSGAForUpgrade;

---------------------------------------------
-- PROCEDURE - movexdb_tablespace
--     Moves xdb in the specified tablespace. The move waits for all
--     concurrent XDB sessions to exit.
-- PARAMETERS - name of the tablespace where xdb is to be moved.
--
---------------------------------------------
PROCEDURE movexdb_tablespace(new_tablespace IN VARCHAR2);

---------------------------------------------
-- PROCEDURE - getxdb_tablespace
--     Gets the current tablespace of xdb. 
-- PARAMETERS - None.
--
---------------------------------------------
FUNCTION getxdb_tablespace RETURN VARCHAR2;
 
-----------------------------------------------------------
-- PROCEDURE - appendResourceMetadata
--     Appends the given piece of metadata to the resource
--
-- PARAMETERS -
--  abspath
--     Absolute path of the resource 
--  data
--     Metadata (can be schema based or NSB). SB metadata
--     will be stored in its own table.
-- RETURNS -
--     Nothing
-----------------------------------------------------------
PROCEDURE appendResourceMetadata(abspath IN VARCHAR2, 
                                 data IN SYS.xmltype);

-----------------------------------------------------------
-- PROCEDURE - appendResourceMetadata
--     Appends the given piece of metadata identified by a REF
--     to the resource
--
-- PARAMETERS -
--  abspath
--     Absolute path of the resource 
--  data
--     REF to the piece of metadata (schema based)
-- RETURNS -
--     Nothing
-----------------------------------------------------------
PROCEDURE appendResourceMetadata(abspath IN VARCHAR2, 
                                 data IN REF SYS.xmltype);

-----------------------------------------------------------
-- PROCEDURE - deleteResourceMetadata
--     Deletes metadata from a resource (can only be used for SB metadata)
--
-- PARAMETERS -
--  abspath
--     Absolute path of the resource 
--  metadata
--     REF to the piece of metadata (schema based) to be deleted
--  delete_option
--     Can be one of the following:
--     DELETE_RES_METADATA_CASCADE : deletes the corresponding row
--     in the metadata table
--     DELETE_RES_METADATA_NOCASCADE : does not delete the row in
--     the metadata table
-- RETURNS -
--     Nothing
-----------------------------------------------------------
PROCEDURE deleteResourceMetadata(abspath IN VARCHAR2,
                                 metadata IN REF SYS.XMLTYPE,
                                 delete_option IN pls_integer := 
                                  DELETE_RES_METADATA_CASCADE);

-----------------------------------------------------------
-- PROCEDURE - deleteResourceMetadata
--     Deletes metadata from a resource (can be used for SB or 
--     NSB metadata)
--
-- PARAMETERS -
--  abspath
--     Absolute path of the resource 
--  metadatans
--     Namespace of the metadata fragment to be removed
--  metadataname
--     Local name of the metadata fragment to be removed
--  delete_option
--     This is only applicable for SB metadata.
--     Can be one of the following:
--     DELETE_RES_METADATA_CASCADE : deletes the corresponding row
--     in the metadata table
--     DELETE_RES_METADATA_NOCASCADE : does not delete the row in
--     the metadata table
-- RETURNS -
--     Nothing
-----------------------------------------------------------
procedure deleteResourceMetadata(abspath IN VARCHAR2,
                                 metadatans IN VARCHAR2,
                                 metadataname IN VARCHAR2,
                                 delete_option IN pls_integer := 
                                 DELETE_RES_METADATA_CASCADE);

-----------------------------------------------------------
-- PROCEDURE - updateResourceMetadata
--     Updates metadata for a resource (can be used to update SB 
--     metadata only). The new metadata must be SB.
--
-- PARAMETERS -
--  abspath
--     Absolute path of the resource 
--  oldmetadata
--     REF to the old piece of metadata
--  newmetadata
--     REF to the new piece of metadata to replace it with
-- RETURNS -
--     Nothing
-----------------------------------------------------------
PROCEDURE updateResourceMetadata(abspath  IN VARCHAR2, 
                                 oldmetadata IN REF SYS.XMLTYPE,
                                 newmetadata IN REF SYS.XMLTYPE);

-----------------------------------------------------------
-- PROCEDURE - updateResourceMetadata
--     Updates metadata for a resource (can be used to update SB 
--     metadata only). The new metadata can be either SB or NSB
--
-- PARAMETERS -
--  abspath
--     Absolute path of the resource 
--  oldmetadata
--     REF to the old piece of metadata
--  newmetadata
--     New piece of metadata (can be either SB or NSB)
-- RETURNS -
--     Nothing
-----------------------------------------------------------
PROCEDURE updateResourceMetadata(abspath  IN VARCHAR2, 
                                 oldmetadata IN REF SYS.XMLTYPE,
                                 newmetadata IN XMLTYPE);

-----------------------------------------------------------
-- PROCEDURE - updateResourceMetadata
--     Updates metadata for a resource - can be used for both
--     SB or NSB metadata.
--
-- PARAMETERS -
--  abspath
--     Absolute path of the resource 
--  oldns, oldname
--     namespace and local name pair identifying old metadata
--  newmetadata
--     New piece of metadata (can be either SB or NSB)
-- RETURNS -
--     Nothing
-----------------------------------------------------------
PROCEDURE updateResourceMetadata(abspath  IN VARCHAR2, 
                                 oldns IN VARCHAR2,
                                 oldname IN VARCHAR,
                                 newmetadata IN XMLTYPE);

-----------------------------------------------------------
-- PROCEDURE - updateResourceMetadata
--     Updates metadata for a resource - can be used for both
--     SB or NSB metadata. New metadata must be SB.
--
-- PARAMETERS -
--  abspath
--     Absolute path of the resource 
--  oldns, oldname
--     namespace and local name pair identifying old metadata
--  newmetadata
--     REF to new metadata
-- RETURNS -
--     Nothing
-----------------------------------------------------------
PROCEDURE updateResourceMetadata(abspath  IN VARCHAR2, 
                                 oldns IN VARCHAR2,
                                 oldname IN VARCHAR,
                                 newmetadata IN REF SYS.XMLTYPE);

-----------------------------------------------------------
-- PROCEDURE - purgeResourceMetadata
--     Deletes all user metadata from a resource 
--     SB metadata is removed in cascade mode i.e. the rows
--     are deleted from the corresponding metadata tables
--
-- PARAMETERS -
--  abspath
--     Absolute path of the resource 
-- RETURNS -
--     Nothing
-----------------------------------------------------------
PROCEDURE purgeResourceMetadata(abspath  IN VARCHAR2);

end dbms_xdb;
/
show errors;

CREATE OR REPLACE PUBLIC SYNONYM DBMS_XDB FOR xdb.dbms_xdb
/
GRANT EXECUTE ON xdb.dbms_xdb TO PUBLIC
/
show errors;
