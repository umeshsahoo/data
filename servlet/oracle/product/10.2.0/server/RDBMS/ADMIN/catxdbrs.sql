Rem
Rem $Header: catxdbrs.sql 19-feb-2004.13:43:18 abagrawa Exp $
Rem
Rem catxdbrs.sql
Rem
Rem Copyright (c) 2001, 2004, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      catxdbrs.sql - XDB Resource Schema related types and tables
Rem
Rem    DESCRIPTION
Rem      This script creates the types, tables, etc required for 
Rem      XDB Resource schema.
Rem
Rem    NOTES
Rem      This script should be run as the user "XDB".
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    abagrawa    02/19/04 - Add SBRESEXTRA to XDB$RESOURCE_T 
Rem    spannala    07/27/03 - changing xdb$resource_oid_index to xdb ownership
Rem    njalali     01/17/03 - adding unique index on XMLREF column
Rem    fge         02/04/02 - grant execute on xdb$resource_t to public
Rem    spannala    01/08/02 - incorporating fge_caxdb_priv_indx_fix
Rem    spannala    12/27/01 - not switching users in xdb install
Rem    spannala    01/11/02 - making all systems types have standard TOIDs
Rem    njalali     12/04/01 - changed some integers to RAW in the resource type
Rem    mkrishna    11/01/01 - change xmldata to xmldata
Rem    njalali     10/27/01 - using timestamp
Rem    njalali     10/26/01 - fixing OIDs to be 16 bytes
Rem    nle         10/05/01 - versioning
Rem    nagarwal    08/28/01 - add version attrs
Rem    rmurthy     10/01/01 - allow primary key in xmlref col
Rem    rmurthy     08/10/01 - change XDB namespace
Rem    njalali     08/09/01 - resource format changes
Rem    spannala    08/03/01 - DAV
Rem    njalali     07/29/01 - Merged njalali_xmlres2
Rem    nagarwal    07/27/01 - add versionid, activityid to resource_t
Rem    njalali     07/19/01 - added column for the ANY element
Rem    njalali     07/06/01 - Created
Rem

/* ------------------------------------------------------------------- */
/*                   MISC TYPES                                        */   
/* ------------------------------------------------------------------- */


/* ------------------------------------------------------------------- */
/*                   ENUM TYPES                                        */   
/* ------------------------------------------------------------------- */

/*
* Later will inherit from xdb.xdb$enum
*/
create or replace type XDB.XDB$LOCKSCOPE_T 
OID '00000000000000000000000000020119' AS OBJECT
(
  VALUE           RAW(1)
);
/

/* ------------------------------------------------------------------- */
/*              RESOURCE-LOCK RELATED TYPES                            */
/* ------------------------------------------------------------------- */

create or replace type XDB.XDB$RESLOCK_T OID '0000000000000000000000000002011A'
 as object
(
  LOCKSCOPE       XDB.XDB$LOCKSCOPE_T,
  OWNER           VARCHAR2(30),
  EXPIRES         TIMESTAMP,
  LOCKTOKEN       RAW(2000)
);
/

create or replace type XDB.XDB$RESLOCK_ARRAY_T 
      OID '0000000000000000000000000002011B' as VARRAY(65535) of XDB.XDB$RESLOCK_T;
/

create or replace type xdb.xdb$nlocks_t OID '0000000000000000000000000002011C'
 AS OBJECT
(
    PARENT_OID  RAW(16),
    CHILD_NAME  VARCHAR2(256),
    RAWTOKEN    RAW(18)
);
/

create or replace type XDB.XDB$PREDECESSOR_LIST_T OID
'0000000000000000000000000002011D' AS varray(1000) of raw(16);
/

grant execute on xdb.xdb$predecessor_list_t to public with grant option;

/* ------------------------------------------------------------------- */
/*                  RESOURCE RELATED TYPES                             */
/* ------------------------------------------------------------------- */

create or replace type XDB.XDB$RESOURCE_T OID 
'0000000000000000000000000002011E' as object
(
  VERSIONID           INTEGER,
  CREATIONDATE        TIMESTAMP,
  MODIFICATIONDATE    TIMESTAMP,
  AUTHOR              VARCHAR2(128),
  DISPNAME            VARCHAR2(128),
  RESCOMMENT          VARCHAR2(128),
  LANGUAGE            VARCHAR2(128),
  CHARSET             VARCHAR2(128),
  CONTYPE             VARCHAR2(128),
  REFCOUNT            RAW(4),
  LOCKS               RAW(2000),  /* For future use: XDB.XDB$RESLOCK_ARRAY_T, */
  ACLOID              RAW(16),
  OWNERID             RAW(16),
  CREATORID           RAW(16),
  LASTMODIFIERID      RAW(16),
  ELNUM               INTEGER,
  SCHOID              RAW(16),
  XMLREF              REF SYS.XMLTYPE,
  XMLLOB              BLOB,
  FLAGS               RAW(4),
  RESEXTRA            CLOB,
  ACTIVITYID          INTEGER,
  VCRUID              RAW(16),
  PARENTS             XDB.XDB$PREDECESSOR_LIST_T,
  SBRESEXTRA          XDB.XDB$XMLTYPE_REF_LIST_T 
);
/

grant execute on xdb.xdb$resource_t to public with grant option;


/* ------------------------------------------------------------------- */
/*                      TABLES                                         */   
/* ------------------------------------------------------------------- */

/* Well known ID for XDB schema for resources */
/* '8758D485E6004793E034080020B242C6' */

create table XDB.XDB$RESOURCE of sys.xmltype
        xmlschema "http://xmlns.oracle.com/xdb/XDBResource.xsd" 
                id '8758D485E6004793E034080020B242C6'
        element "Resource" id 734
        type XDB.XDB$RESOURCE_T;

alter table XDB.XDB$RESOURCE add (ref(xmldata.XMLREF) with rowid);
alter table XDB.XDB$RESOURCE add (ref(xmldata.XMLREF) allow primary key);

create unique index xdb.xdb$resource_oid_index on XDB.XDB$RESOURCE e
  (sys_op_r2o(e.xmldata.xmlref));

/*
NOLOGGING LOB (xmllob) STORE AS 
  (tablespace xdb_resinfo storage (initial 100m next 100m pctincrease 0)
   nocache nologging chunk 32k);
*/

create table xdb.xdb$nlocks of xdb.xdb$nlocks_t;

/* ------------------------------------------------------------------- */
/*                          INDEXES                                    */   
/* ------------------------------------------------------------------- */

/*
create index xdb$resource_xmlref_i on xdb$resource (sys_op_r2o(xmldata.xmlref));
*/

create index xdb.xdb$nlocks_rawtoken_idx on xdb.xdb$nlocks (rawtoken);
create index xdb.xdb$nlocks_child_name_idx on xdb.xdb$nlocks (child_name);
create index xdb.xdb$nlocks_parent_oid_idx on xdb.xdb$nlocks (parent_oid);
/* None for now */
