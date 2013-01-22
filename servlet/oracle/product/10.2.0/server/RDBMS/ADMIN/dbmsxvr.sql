Rem
Rem $Header: dbmsxvr.sql 15-feb-2005.17:30:12 vkapoor Exp $
Rem
Rem dbmsxvr.sql
Rem
Rem Copyright (c) 2003, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmsxvr.sql - DBMS_XDB_VERSION package
Rem
Rem    DESCRIPTION
Rem      Package definiton and body of dbms_xdb_version package.
Rem
Rem    NOTES
Rem      Split out from catxdbvr for the purposes of independent loading
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    vkapoor     02/03/05 - bug 4075243 
Rem    vkapoor     02/06/05 - bug 4075253 
Rem    najain      10/01/04 - dbms_xdb_version is invoker's rights
Rem    spannala    12/23/03 - spannala_bug-3321840 
Rem    spannala    12/16/03 - Created
Rem

/* Package DBMS_XDB_VERSION */
create or replace package XDB.DBMS_XDB_VERSION authid current_user as

  SUBTYPE resid_type is RAW(16);
  TYPE resid_list_type is VARRAY(1000) of RAW(16);

  FUNCTION makeversioned(pathname VARCHAR2) RETURN resid_type;
  PROCEDURE checkout(pathname VARCHAR2);
  FUNCTION checkin(pathname VARCHAR2) RETURN resid_type;
  FUNCTION uncheckout(pathname VARCHAR2) RETURN resid_type;
  FUNCTION ischeckedout(pathname VARCHAR2) RETURN BOOLEAN;
  FUNCTION GetPredecessors(pathname VARCHAR2) RETURN resid_list_type;
  FUNCTION GetPredsByResId(resid resid_type) RETURN resid_list_type;
  FUNCTION GetSuccessors(pathname VARCHAR2) RETURN resid_list_type;
  FUNCTION GetSuccsByResId(resid resid_type) RETURN resid_list_type;
  FUNCTION GetResourceByResId(resid resid_type) RETURN XMLType;
  FUNCTION GetContentsBlobByResId(resid resid_type) RETURN BLOB;
  FUNCTION GetContentsClobByResId(resid resid_type) RETURN CLOB;
  FUNCTION GetContentsXmlByResId(resid resid_type) RETURN XMLType;

end DBMS_XDB_VERSION;
/
show errors;

/* library for DBMS_XDB_VERSION */
CREATE OR REPLACE LIBRARY XDB.DBMS_XDB_VERSION_LIB TRUSTED AS STATIC
/

/* package body */
create or replace package body XDB.DBMS_XDB_VERSION as
  FUNCTION makeversioned(pathname varchar2) RETURN resid_type is
    LANGUAGE C NAME "qmevsMakeVersioned"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  pathname OCIString, pathname indicator sb4,
                  RETURN INDICATOR sb4,
                  RETURN LENGTH size_t
                 );

  PROCEDURE checkout(pathname varchar2) is
    LANGUAGE C NAME "qmevsCheckout"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  pathname OCIString, pathname indicator sb4
                 );

  FUNCTION checkin(pathname varchar2) RETURN resid_type is
    LANGUAGE C NAME "qmevsCheckin"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  pathname OCIString, pathname indicator sb4,
                  RETURN INDICATOR sb4,
                  RETURN LENGTH size_t
                 );

  FUNCTION uncheckout(pathname varchar2) RETURN resid_type is
    LANGUAGE C NAME "qmevsUncheckout"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  pathname OCIString, pathname indicator sb4,
                  RETURN INDICATOR sb4,
                  RETURN LENGTH size_t
                 );

  FUNCTION ischeckedout(pathname varchar2) RETURN BOOLEAN is
    LANGUAGE C NAME "qmevsIsResCheckedOut"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  pathname OCIString, pathname indicator sb4,
                  RETURN INDICATOR sb4, 
                  return
                 );

  FUNCTION getresid(pathname varchar2) RETURN resid_type is
    LANGUAGE C NAME "qmevsGetResID"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  pathname OCIString, pathname indicator sb4,
                  RETURN INDICATOR sb4,
                  RETURN LENGTH size_t
                 );

  FUNCTION GetPredecessors(pathname varchar2) RETURN resid_list_type is
    resid  resid_type;
  BEGIN
    resid := getresid(pathname);
    return GetPredsByResId(resid);
  END;

  FUNCTION GetPredsByResId(resid resid_type) RETURN resid_list_type is
    LANGUAGE C NAME "qmevsGetPredsByResId"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  resid OCIRaw, resid indicator sb2,
                  RETURN INDICATOR sb4,
                  RETURN DURATION OCIDuration,
                  RETURN
                 );

  FUNCTION GetSuccessors(pathname varchar2) RETURN resid_list_type is
    resid  resid_type;
  BEGIN
    resid := getresid(pathname);
    return GetSuccsByResId(resid);
  END;

  FUNCTION GetSuccsByResId(resid resid_type) RETURN resid_list_type is
    LANGUAGE C NAME "qmevsGetSuccsByResId"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  resid OCIRaw, resid indicator sb2,
                  RETURN INDICATOR sb4,
                  RETURN DURATION OCIDuration,
                  RETURN
                 );

  FUNCTION GetResourceByResId(resid resid_type) RETURN XMLType is
    LANGUAGE C NAME "qmevsGetResByResId"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  resid OCIRaw, resid indicator sb2,
                  RETURN INDICATOR sb4,
                  RETURN DURATION OCIDuration,
                  RETURN
                 );

  FUNCTION GetContentsBlobByResId(resid resid_type) RETURN BLOB is
    LANGUAGE C NAME "qmevsGetCtsBlobByResId"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  resid OCIRaw, resid indicator sb2,
                  RETURN INDICATOR sb4,
                  RETURN DURATION OCIDuration,
                  RETURN OCILobLocator
                 );

  FUNCTION GetContentsClobByResId(resid resid_type) RETURN CLOB is
    LANGUAGE C NAME "qmevsGetCtsClobByResId"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  resid OCIRaw, resid indicator sb2,
                  RETURN INDICATOR sb4,
                  RETURN DURATION OCIDuration,
                  RETURN OCILobLocator
                 );

  FUNCTION GetContentsXmlByResId(resid resid_type) RETURN XMLType is
    LANGUAGE C NAME "qmevsGetCtsXmlByResId"
      LIBRARY XDB.DBMS_XDB_VERSION_LIB
      WITH CONTEXT
      PARAMETERS (context,
                  resid OCIRaw, resid indicator sb2,
                  RETURN INDICATOR sb4,
                  RETURN DURATION OCIDuration,
                  RETURN
                 );


end DBMS_XDB_VERSION;
/
show errors;
GRANT EXECUTE ON XDB.DBMS_XDB_VERSION TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM DBMS_XDB_VERSION FOR XDB.DBMS_XDB_VERSION;
