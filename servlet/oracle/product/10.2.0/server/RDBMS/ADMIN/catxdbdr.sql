Rem
Rem $Header: catxdbdr.sql 24-feb-2005.14:57:32 rmurthy Exp $
Rem
Rem catxdbdr.sql
Rem
Rem Copyright (c) 2001, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catxdbdr.sql -XDB initialization Data for Resource type
Rem
Rem    DESCRIPTION
Rem      Initialization data (schema for resource) for XDB.
Rem
Rem    NOTES
Rem      Property numbers for resources start at 701.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rmurthy     02/17/05 - populate namespace array 
Rem    abagrawa    02/10/04 - Add SBResExtra 
Rem    najain      08/11/03 - add HierSchmBasedRes property
Rem    njalali     01/06/03 - making some props read-only
Rem    abagrawa    01/15/03 - Update insertSimple usage
Rem    najain      07/23/02 - sticky ref support
Rem    rmurthy     06/28/02 - change memtype from XOBD to XOB
Rem    mkrishna    04/03/02 - fix catxdbdr for XMLLob
Rem    rmurthy     03/15/02 - change to xdb$schema_t constructor
Rem    njalali     02/13/02 - adding boolan property VersionHistory
Rem    mkrishna    01/29/02 - fix xdb$resource to be non-PD
Rem    mkrishna    01/28/02 - fix xdb$resource to have ##other namespace
Rem    spannala    12/27/01 - not switching users in xdb install
Rem    njalali     12/19/01 - making versionid and activityid sb4''s
Rem    njalali     12/04/01 - transient properties
Rem    mkrishna    11/01/01 - change xmldata to xmldata
Rem    rmurthy     11/21/01 - specify sql colltype names
Rem    sichandr    11/28/01 - set global flag in bootstrap schemas
Rem    sichandr    10/31/01 - add ID attribute
Rem    nmontoya    11/02/01 - setting max namelen to 4000 for LDAP
Rem    njalali     10/27/01 - using timestamp
Rem    njalali     10/26/01 - changing to date
Rem    nle         10/05/01 - versioning
Rem    nagarwal    08/28/01 - add version attrs
Rem    njalali     10/25/01 - using GUIDs instead of kusr
Rem    njalali     09/26/01 - propagating H_INDEX flags to resource
Rem    sichandr    09/18/01 - support storeVarrayAsTable
Rem    rmurthy     08/26/01 - add support for substitutionGroup, named group
Rem    njalali     08/01/01 - changed ANY types
Rem    rmurthy     08/10/01 - change XDB namespace
Rem    njalali     07/29/01 - Merged njalali_xmlres2
Rem    njalali     07/19/01 - added versatile ANY element
Rem    njalali     07/02/01 - Created
Rem


create or replace package xdb.xdb$bootstrapres as

        PN_RES_LOCKSCOPE        CONSTANT INTEGER := 701;
        PN_RES_LOCKOWNER        CONSTANT INTEGER := 702;
        PN_RES_LOCKEXPIRES      CONSTANT INTEGER := 703;
        PN_RES_LOCKTOKEN        CONSTANT INTEGER := 704;
        PN_RES_HIDDEN           CONSTANT INTEGER := 705;
        PN_RES_INVALID          CONSTANT INTEGER := 706;
        PN_RES_VERSIONID        CONSTANT INTEGER := 707;
        PN_RES_ACTIVITYID       CONSTANT INTEGER := 708;
        PN_RES_CREDAT           CONSTANT INTEGER := 709;
        PN_RES_MODDAT           CONSTANT INTEGER := 710;
        PN_RES_AUTHOR           CONSTANT INTEGER := 711;
        PN_RES_DISPNAME         CONSTANT INTEGER := 712;
        PN_RES_RESCOMMENT       CONSTANT INTEGER := 713;
        PN_RES_LANGUAGE         CONSTANT INTEGER := 714;
        PN_RES_CHARSET          CONSTANT INTEGER := 715;
        PN_RES_CONTYPE          CONSTANT INTEGER := 716;
        PN_RES_REFCOUNT         CONSTANT INTEGER := 717;
        PN_RES_LOCKS            CONSTANT INTEGER := 718;
        PN_RES_ACLOID           CONSTANT INTEGER := 719;
        PN_RES_OWNER            CONSTANT INTEGER := 720;
        PN_RES_OWNERID          CONSTANT INTEGER := 721;
        PN_RES_CREATOR          CONSTANT INTEGER := 722;
        PN_RES_CREATORID        CONSTANT INTEGER := 723;
        PN_RES_LASTMODIFIER     CONSTANT INTEGER := 724;
        PN_RES_LASTMODIFIERID   CONSTANT INTEGER := 725;
        PN_RES_SCHELEM          CONSTANT INTEGER := 726;
        PN_RES_ELNUM            CONSTANT INTEGER := 727;
        PN_RES_SCHOID           CONSTANT INTEGER := 728;
        PN_RES_XMLREF           CONSTANT INTEGER := 729;
        PN_RES_XMLLOB           CONSTANT INTEGER := 730;
        PN_RES_FLAGS            CONSTANT INTEGER := 731;
        PN_RES_ACL              CONSTANT INTEGER := 732;
        PN_RES_CONTENTS         CONSTANT INTEGER := 733;
        PN_RES_RESOURCE         CONSTANT INTEGER := 734;
        PN_RES_RESEXTRA         CONSTANT INTEGER := 735;
        PN_RES_CONTENTS_ANY     CONSTANT INTEGER := 736;
        PN_RES_ACL_ANY          CONSTANT INTEGER := 737;
        PN_RES_CONTAINER        CONSTANT INTEGER := 738;
        PN_RES_CUSTRSLV         CONSTANT INTEGER := 739;
        PN_RES_VCRUID           CONSTANT INTEGER := 740;
        PN_RES_PARENTS          CONSTANT INTEGER := 741;
        PN_RES_VERHIS           CONSTANT INTEGER := 742;
        PN_RES_STICKYREF        CONSTANT INTEGER := 743;
        PN_RES_HIERSCHMRES      CONSTANT INTEGER := 744;
        PN_RES_SBRESEXTRA       CONSTANT INTEGER := 745;

        PN_RES_TOTAL_PROPNUMS   CONSTANT INTEGER := 45;

        FALSE        CONSTANT RAW(1) := '0';
        TRUE         CONSTANT RAW(1) := '1';

        procedure driver;
end;
/
show errors


create or replace package body xdb.xdb$bootstrapres is

procedure driver is

        ellist          xdb.xdb$xmltype_ref_list_t;
        simplelist      xdb.xdb$xmltype_ref_list_t;
        complexlist     xdb.xdb$xmltype_ref_list_t;
        schels          xdb.xdb$xmltype_ref_list_t;
        attlist         xdb.xdb$xmltype_ref_list_t;
        anylist         xdb.xdb$xmltype_ref_list_t;
        schref          ref sys.xmltype;
        oraclename_ref  ref sys.xmltype;
        resmetastr_ref  ref sys.xmltype;
        schelemtype_ref ref sys.xmltype;
        guid_ref        ref sys.xmltype;
        locksraw_ref    ref sys.xmltype;
        lockscopetype_ref  ref sys.xmltype;
        locktype_ref    ref sys.xmltype;
        conttype_ref    ref sys.xmltype;
        acltype_ref     ref sys.xmltype;
        resource_ref    ref sys.xmltype;
        schema_i        xdb.xdb$schema_t;
	extras_i        sys.xmltypeextra;
        lock_colcount   integer;
        res_colcount    integer;

BEGIN
        schema_i := xdb.xdb$schema_t('http://xmlns.oracle.com/xdb/XDBResource.xsd',
              'http://xmlns.oracle.com/xdb/XDBResource.xsd',
              '1.0', 0, null, null, XDB$BOOTSTRAP.FC_QUAL, null, null, null, null, null,
              null, null, '17', null, null, FALSE, FALSE, null, null,
              null, FALSE, 'XDB',null,null);

	extras_i := 
         sys.xmltypeextra( 
            sys.xmltypepi( 
               xdb.xdb$getpickledns(
                    'http://www.w3.org/2001/XMLSchema', 
                    null), 
               xdb.xdb$getpickledns(
                    'http://xmlns.oracle.com/xdb', 
                    'xdb'), 
               xdb.xdb$getpickledns(
                    'http://xmlns.oracle.com/xdb/XDBResource.xsd', 
                    'xdbres') 
              ), 
            null);

        execute immediate 'insert into xdb.xdb$schema s 
                (sys_nc_oid$, xmlextra, xmldata) values (:1, :2, :3) 
                returning ref(s) into :4' 
                using '8758D485E6004793E034080020B242C6', extras_i, schema_i
                returning into schref;

        /* VARRAY tracking top-level schema elements */
        schels := xdb.xdb$xmltype_ref_list_t();
        schels.extend(1);

        simplelist := xdb.xdb$xmltype_ref_list_t();
        simplelist.extend(6);

        complexlist := xdb.xdb$xmltype_ref_list_t();
        complexlist.extend(4);

        select attributes into lock_colcount from all_types
                where type_name in ('XDB$RESLOCK_T') and owner = 'XDB';

        select attributes into res_colcount from all_types
                where type_name in ('XDB$RESOURCE_T') and owner = 'XDB';

/*--------------------------------------------------------------------------*/
/* Simple type definition for "OracleUserName"                              */
/*--------------------------------------------------------------------------*/

        /* LDAP users require a 4000-byte maximum length */
        oraclename_ref := xdb.xdb$bootstrap.xdb$insertSimple(schref, 
               null, 'OracleUserName', 
               xdb.xdb$BOOTSTRAP.TR_STRING,
               null, xdb.xdb$BOOTSTRAP.TD_RESTRICTION, '0',null, null, 
               1, 4000, null, null, null, null, null, null, null);

        simplelist(1) := oraclename_ref;


/*--------------------------------------------------------------------------*/
/* Simple type definition for "ResMetaStr"                                  */
/*--------------------------------------------------------------------------*/

        resmetastr_ref := xdb.xdb$bootstrap.xdb$insertSimple(schref, 
               null, 'ResMetaStr', 
               xdb.xdb$BOOTSTRAP.TR_STRING,
               null, xdb.xdb$BOOTSTRAP.TD_RESTRICTION, '0', null, null, 
               1, 128, null, null, null, null, null, null, null);

        simplelist(2) := resmetastr_ref;

/*--------------------------------------------------------------------------*/
/* Simple type definition for "SchElemType"                                 */
/*--------------------------------------------------------------------------*/

        schelemtype_ref := xdb.xdb$bootstrap.xdb$insertSimple(schref, 
               null, 'SchElemType', 
               xdb.xdb$BOOTSTRAP.TR_STRING,
               null, xdb.xdb$BOOTSTRAP.TD_RESTRICTION, '0', null, null, 
               1, 4000, null, null, null, null, null, null, null);

        simplelist(3) := schelemtype_ref;


/*--------------------------------------------------------------------------*/
/* Simple type definition for "GUID"                                        */
/*--------------------------------------------------------------------------*/

        /*
         * DB users will continue to be stored as KUSRs (4 bytes), whereas
         * LDAP users will be stored as GUIDs (16 bytes).  Doubling these
         * values for hexBinary output, we end up with a range of 8 to 32
         * characters for this simpletype.  We use hexBinary because it 
         * makes it easier to cut-and-paste OIDs into SQL*Plus.
         */
        guid_ref := xdb.xdb$bootstrap.xdb$insertSimple(schref, null, 'GUID', 
               xdb.xdb$BOOTSTRAP.TR_BINARY,
               null, xdb.xdb$BOOTSTRAP.TD_RESTRICTION, '0', null, null, 
               8, 32, null, null, null, null, null, null, null);

        simplelist(4) := guid_ref;


/*--------------------------------------------------------------------------*/
/* Simple type definition for "LocksRaw"                                    */
/*--------------------------------------------------------------------------*/

        locksraw_ref := xdb.xdb$bootstrap.xdb$insertSimple(schref, null, 
               'LocksRaw', xdb.xdb$BOOTSTRAP.TR_BINARY,
               null, xdb.xdb$BOOTSTRAP.TD_RESTRICTION, '0', null, null, 
               0, 2000, null, null, null, null, null, null, null);

        simplelist(5) := locksraw_ref;


/*--------------------------------------------------------------------------*/
/* Simple type definition for "LockScopeType"                               */
/*--------------------------------------------------------------------------*/

        lockscopetype_ref := xdb.xdb$bootstrap.xdb$insertSimple(schref, 
               null, 'LockScopeType', 
               xdb.xdb$BOOTSTRAP.TR_STRING,
               null, xdb.xdb$BOOTSTRAP.TD_RESTRICTION, '0', null, null, 
               null, null, null, null, null, null, null, null, 
               xdb.xdb$enum_values_t('Exclusive', 'Shared'));

        simplelist(6) := lockscopetype_ref;



/*--------------------------------------------------------------------------*/
/* Complex type definition for "LockType"                                   */
/*--------------------------------------------------------------------------*/

      attlist := xdb.xdb$xmltype_ref_list_t();
      attlist.extend(1);

      attlist(1) := xdb.xdb$bootstrap.xdb$insertAttr(schref, 
                               PN_RES_LOCKSCOPE, 'LockScope', 
                               xdb.xdb$qname('01','LockScopeType'), 1, 1, 
                               '01', xdb.xdb$BOOTSTRAP.T_ENUM, FALSE, 
                               FALSE, FALSE, 
                               'LOCKSCOPE', 'XDB$LOCKSCOPE_T', 'XDB',
                               xdb.xdb$BOOTSTRAP.JT_ENUM, null, null, 
                               lockscopetype_ref, null, null);


      ellist := xdb.xdb$xmltype_ref_list_t();
      ellist.extend(3);

      ellist(1) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_LOCKOWNER,
                      'owner', xdb.xdb$BOOTSTRAP.TR_STRING,
                      1, 1, null, xdb.xdb$BOOTSTRAP.T_CSTRING,
                      FALSE, FALSE, FALSE, 
                      'OWNER', 'VARCHAR2', null,
                      xdb.xdb$BOOTSTRAP.JT_STRING, null, null, null, null, null, 
                      null, 1, FALSE, null, null, 
                      FALSE, FALSE, TRUE, FALSE, FALSE, 
                      null, null, null, null, FALSE, null, null, null);

      ellist(2) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_LOCKEXPIRES,
                      'expires', xdb.xdb$qname('00', 'dateTime'), 1, 1,
                      null, xdb.xdb$BOOTSTRAP.T_TIMESTAMP, FALSE, FALSE, FALSE, 
                      'EXPIRES', 'TIMESTAMP', null,
                      xdb.xdb$BOOTSTRAP.JT_TIMESTAMP, null,
                      null, null, null, null, 
                      null, 1, FALSE, null, null, 
                      FALSE, TRUE, TRUE, FALSE, FALSE, 
                      null, null, null, null, FALSE, null, null, null);

      ellist(3) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_LOCKTOKEN,
                      'lockToken', xdb.xdb$BOOTSTRAP.TR_BINARY,
                      1, 1, null, xdb.xdb$BOOTSTRAP.T_BINARY, FALSE, FALSE, FALSE, 
                      'LOCKTOKEN', 'RAW', null,
                      xdb.xdb$BOOTSTRAP.JT_BYTEARRAY, null, null, 
                      null, null, null, 
                      null, 1, FALSE, null, null, 
                      FALSE, FALSE, TRUE, FALSE, FALSE, 
                      null, null, null, null, FALSE, null, null, null);


     locktype_ref := xdb.xdb$bootstrap.xdb$insertComplex(schref, null, 'LockType',
                          null, FALSE, null, '0',
                          null, null, null, null, null, null, null, null, null,
                          null, null, null, null, null, null, ellist, attlist,
                          null);
     complexlist(1) := locktype_ref;


/*--------------------------------------------------------------------------*/
/* Complex type definition for "ResContentsType"                            */
/*--------------------------------------------------------------------------*/


      anylist := xdb.xdb$xmltype_ref_list_t();
      anylist.extend(1);

      anylist(1) := xdb.xdb$bootstrap.xdb$insertAny(schref, PN_RES_CONTENTS_ANY,
                                  'ContentsAny', null, null, 0, 1, null, 
                                  xdb.xdb$BOOTSTRAP.T_XOB, FALSE, FALSE, FALSE, 
                                  null, null, null,
                                  xdb.xdb$BOOTSTRAP.JT_XMLTYPE, null,
                                  null, null, null, null);

     conttype_ref := xdb.xdb$bootstrap.xdb$insertComplex(schref, null, 
                          'ResContentsType', null, FALSE, null, '0',
                          null, null, null, null, null, null, null, null, null,
                          null, null, null, null, null, null, null, null,
                          anylist);
     complexlist(2) := conttype_ref;


/*--------------------------------------------------------------------------*/
/* Complex type definition for "ResAclType"                                 */
/*--------------------------------------------------------------------------*/


      anylist := xdb.xdb$xmltype_ref_list_t();
      anylist.extend(1);

      anylist(1) := xdb.xdb$bootstrap.xdb$insertAny(schref, PN_RES_ACL_ANY,
                                  'ACLAny', null, null, 0, 1, null, 
                                  xdb.xdb$BOOTSTRAP.T_XOB, FALSE, FALSE, FALSE, 
                                  null, null, null,
                                  xdb.xdb$BOOTSTRAP.JT_XMLTYPE, null,
                                  null, null, null, null);

     acltype_ref := xdb.xdb$bootstrap.xdb$insertComplex(schref, null, 
                          'ResAclType', null, FALSE, null, '0',
                          null, null, null, null, null, null, null, null, null,
                          null, null, null, null, null, null, null, null,
                          anylist);
     complexlist(3) := acltype_ref;


/*--------------------------------------------------------------------------*/
/* Complex type definition for "ResourceType" */
/*--------------------------------------------------------------------------*/

      attlist := xdb.xdb$xmltype_ref_list_t();
      attlist.extend(9);

      attlist(1) := xdb.xdb$bootstrap.xdb$insertAttr(schref, 
                               PN_RES_HIDDEN, 'Hidden', 
                               xdb.xdb$BOOTSTRAP.TR_BOOLEAN, 1, 1, 
                               '1', xdb.xdb$BOOTSTRAP.T_BOOLEAN, FALSE, 
                               FALSE, FALSE, 
                               null, null, null,
                               xdb.xdb$BOOTSTRAP.JT_BOOLEAN, 'false', null, 
                               null, null, null, null, null, FALSE,
                               xdb.xdb$BOOTSTRAP.TRANSIENT_GENERATED, FALSE);

      attlist(2) := xdb.xdb$bootstrap.xdb$insertAttr(schref, 
                               PN_RES_INVALID, 'Invalid', 
                               xdb.xdb$BOOTSTRAP.TR_BOOLEAN, 1, 1, 
                               '1', xdb.xdb$BOOTSTRAP.T_BOOLEAN, FALSE, 
                               FALSE, FALSE, 
                               null, null, null,
                               xdb.xdb$BOOTSTRAP.JT_BOOLEAN, 'false', null, 
                               null, null, null, null, null, FALSE,
                               xdb.xdb$BOOTSTRAP.TRANSIENT_GENERATED, FALSE);

      attlist(3) := xdb.xdb$bootstrap.xdb$insertAttr(schref, 
                               PN_RES_VERSIONID, 'VersionID', 
                               xdb.xdb$BOOTSTRAP.TR_INT, 0, 1, 
                               '4', xdb.xdb$BOOTSTRAP.T_INTEGER, FALSE, 
                               FALSE, FALSE, 
                               'VERSIONID', 'INTEGER', null,
                               xdb.xdb$BOOTSTRAP.JT_LONG, null, null, 
                               null, null, null);

      attlist(4) := xdb.xdb$bootstrap.xdb$insertAttr(schref, 
                               PN_RES_ACTIVITYID, 'ActivityID',
                               xdb.xdb$BOOTSTRAP.TR_INT, 0, 1, 
                               '4', xdb.xdb$BOOTSTRAP.T_INTEGER, FALSE, 
                               FALSE, FALSE, 
                               'ACTIVITYID', 'INTEGER', null,
                               xdb.xdb$BOOTSTRAP.JT_LONG, null, null, 
                               null, null, null);

      attlist(5) := xdb.xdb$bootstrap.xdb$insertAttr(schref, 
                               PN_RES_CONTAINER, 'Container',
                               xdb.xdb$BOOTSTRAP.TR_BOOLEAN, 1, 1, 
                               '1', xdb.xdb$BOOTSTRAP.T_BOOLEAN, FALSE, 
                               FALSE, FALSE, 
                               null, null, null,
                               xdb.xdb$BOOTSTRAP.JT_BOOLEAN, 'false', null, 
                               null, null, null, null, null, FALSE,
                               xdb.xdb$BOOTSTRAP.TRANSIENT_GENERATED, FALSE);

      attlist(6) := xdb.xdb$bootstrap.xdb$insertAttr(schref, 
                               PN_RES_CUSTRSLV, 'CustomRslv', 
                               xdb.xdb$BOOTSTRAP.TR_BOOLEAN, 1, 1, 
                               '1', xdb.xdb$BOOTSTRAP.T_BOOLEAN, FALSE, 
                               FALSE, FALSE, 
                               null, null, null,
                               xdb.xdb$BOOTSTRAP.JT_BOOLEAN, 'false', null, 
                               null, null, null, null, null, FALSE,
                               xdb.xdb$BOOTSTRAP.TRANSIENT_GENERATED, FALSE);

      attlist(7) := xdb.xdb$bootstrap.xdb$insertAttr(schref, 
                               PN_RES_VERHIS, 'VersionHistory', 
                               xdb.xdb$BOOTSTRAP.TR_BOOLEAN, 1, 1, 
                               '1', xdb.xdb$BOOTSTRAP.T_BOOLEAN, FALSE, 
                               FALSE, FALSE, 
                               null, null, null,
                               xdb.xdb$BOOTSTRAP.JT_BOOLEAN, 'false', null, 
                               null, null, null, null, null, FALSE,
                               xdb.xdb$BOOTSTRAP.TRANSIENT_GENERATED, FALSE);

      attlist(8) := xdb.xdb$bootstrap.xdb$insertAttr(schref,
                               PN_RES_STICKYREF, 'StickyRef',
                               xdb.xdb$BOOTSTRAP.TR_BOOLEAN, 1, 1,
                               '1', xdb.xdb$BOOTSTRAP.T_BOOLEAN, FALSE,
                               FALSE, FALSE,
                               null, null, null,
                               xdb.xdb$BOOTSTRAP.JT_BOOLEAN, 'false', null,
                               null, null, null, null, null, FALSE,
                               xdb.xdb$BOOTSTRAP.TRANSIENT_GENERATED, FALSE);

      attlist(9) := xdb.xdb$bootstrap.xdb$insertAttr(schref,
                               PN_RES_HIERSCHMRES, 'HierSchmResource',
                               xdb.xdb$BOOTSTRAP.TR_BOOLEAN, 1, 1,
                               '1', xdb.xdb$BOOTSTRAP.T_BOOLEAN, FALSE,
                               FALSE, FALSE,
                               null, null, null,
                               xdb.xdb$BOOTSTRAP.JT_BOOLEAN, 'false', null,
                               null, null, null, null, null, TRUE,
                               xdb.xdb$BOOTSTRAP.TRANSIENT_GENERATED, FALSE);

      ellist := xdb.xdb$xmltype_ref_list_t();
      ellist.extend(28);

      ellist(1) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_CREDAT,
                      'CreationDate', xdb.xdb$qname('00', 'dateTime'), 1, 1,
                      null, xdb.xdb$BOOTSTRAP.T_TIMESTAMP, FALSE, FALSE, FALSE, 
                      'CREATIONDATE', 'TIMESTAMP', null,
                      xdb.xdb$BOOTSTRAP.JT_TIMESTAMP, null,
                      null, null, null, null, 
                      null, 1, FALSE, null, null, 
                      FALSE, TRUE, TRUE, FALSE, FALSE, 
                      null, null, null, null, FALSE, null, null, null);

      ellist(2) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_MODDAT,
                      'ModificationDate', xdb.xdb$qname('00', 'dateTime'), 1, 1,
                      null, xdb.xdb$BOOTSTRAP.T_TIMESTAMP, FALSE, FALSE, FALSE, 
                      'MODIFICATIONDATE', 'TIMESTAMP', null,
                      xdb.xdb$BOOTSTRAP.JT_TIMESTAMP, null,
                      null, null, null, null, 
                      null, 1, FALSE, null, null, 
                      FALSE, TRUE, TRUE, FALSE, FALSE, 
                      null, null, null, null, FALSE, null, null, null);

      ellist(3) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_AUTHOR,
                      'Author', xdb.xdb$qname('01', 'ResMetaStr'),
                      0, 1, null, xdb.xdb$BOOTSTRAP.T_CSTRING,
                      FALSE, FALSE, FALSE, 
                      'AUTHOR', 'VARCHAR2', null,
                      xdb.xdb$BOOTSTRAP.JT_STRING, null, null, 
                      resmetastr_ref, null, null, 
                      null, 1, FALSE, null, null, 
                      FALSE, FALSE, TRUE, FALSE, FALSE, 
                      null, null, null, null, FALSE, null, null, null);

      ellist(4) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_DISPNAME,
                      'DisplayName', xdb.xdb$qname('01', 'ResMetaStr'),
                      1, 1, null, xdb.xdb$BOOTSTRAP.T_CSTRING,
                      FALSE, FALSE, FALSE, 
                      'DISPNAME', 'VARCHAR2', null,
                      xdb.xdb$BOOTSTRAP.JT_STRING, null, null, 
                      resmetastr_ref, null, null, 
                      null, 1, FALSE, null, null, 
                      FALSE, FALSE, TRUE, FALSE, FALSE, 
                      null, null, null, null, FALSE, null, null, null);

      ellist(5) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_RESCOMMENT,
                      'Comment', xdb.xdb$qname('01', 'ResMetaStr'),
                      1, 1, null, xdb.xdb$BOOTSTRAP.T_CSTRING,
                      FALSE, FALSE, FALSE, 
                      'RESCOMMENT', 'VARCHAR2', null,
                      xdb.xdb$BOOTSTRAP.JT_STRING, null, null, 
                      resmetastr_ref, null, null, 
                      null, 1, FALSE, null, null, 
                      FALSE, FALSE, TRUE, FALSE, FALSE, 
                      null, null, null, null, FALSE, null, null, null);

      ellist(6) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_LANGUAGE,
                      'Language', xdb.xdb$qname('01', 'ResMetaStr'),
                      1, 1, null, xdb.xdb$BOOTSTRAP.T_CSTRING,
                      FALSE, FALSE, FALSE, 
                      'LANGUAGE', 'VARCHAR2', null,
                      xdb.xdb$BOOTSTRAP.JT_STRING, 'en', null, 
                      resmetastr_ref, null, null, 
                      null, 1, FALSE, null, null, 
                      FALSE, FALSE, TRUE, FALSE, FALSE, 
                      null, null, null, null, FALSE, null, null, null);

      ellist(7) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_CHARSET,
                      'CharacterSet', xdb.xdb$qname('01', 'ResMetaStr'),
                      0, 1, null, xdb.xdb$BOOTSTRAP.T_CSTRING,
                      FALSE, FALSE, FALSE, 
                      'CHARSET', 'VARCHAR2', null,
                      xdb.xdb$BOOTSTRAP.JT_STRING, null, null, 
                      resmetastr_ref, null, null, 
                      null, 1, FALSE, null, null, 
                      FALSE, FALSE, TRUE, FALSE, FALSE, 
                      null, null, null, null, FALSE, null, null, null);

      ellist(8) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_CONTYPE,
                      'ContentType', xdb.xdb$qname('01', 'ResMetaStr'),
                      0, 1, null, xdb.xdb$BOOTSTRAP.T_CSTRING,
                      FALSE, FALSE, FALSE, 
                      'CONTYPE', 'VARCHAR2', null,
                      xdb.xdb$BOOTSTRAP.JT_STRING, null, null, 
                      resmetastr_ref, null, null, 
                      null, 1, FALSE, null, null, 
                      FALSE, FALSE, TRUE, FALSE, FALSE, 
                      null, null, null, null, FALSE, null, null, null);

      ellist(9) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_REFCOUNT,
                      'RefCount', xdb.xdb$BOOTSTRAP.TR_NNEGINT,
                      1, 1, '4', xdb.xdb$BOOTSTRAP.T_UNSIGNINT,
                      FALSE, TRUE, FALSE, 
                      'REFCOUNT', 'RAW', null,
                      xdb.xdb$BOOTSTRAP.JT_LONG, null, null, null, null, null, 
                      null, 1, FALSE, null, null, 
                      FALSE, TRUE, TRUE, FALSE, FALSE, 
                      null, null, null, null, FALSE, null, null, null);

/*  Reserved for when LOCKS is a VARRAY of xdb.xdb$RESLOCK_TYPE
      ellist(10) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_LOCKS,
                      'Lock', xdb.xdb$qname('01', 'LockType'),
                      0, 65535, null, xdb.xdb$BOOTSTRAP.T_XOB,
                      FALSE, TRUE, FALSE, 
                      'LOCKS', 'XDB$RESLOCK_T', 'XDB',
                      xdb.xdb$BOOTSTRAP.JT_XMLTYPE, null, null, locktype_ref,
                      null, null, null, lock_colcount, FALSE, null, null, 
                      FALSE, FALSE, TRUE, FALSE, FALSE, 
                      null, null, 'oracle.xdb.LockType', 
                      'oracle.xdb.LockTypeBean', FALSE, null, null, null); */

      ellist(10) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_LOCKS,
                      'Lock',  xdb.xdb$qname('01', 'LocksRaw'),
                      0, 1, null, xdb.xdb$BOOTSTRAP.T_BINARY,
                      FALSE, TRUE, FALSE, 
                      'LOCKS', 'RAW', null,
                      xdb.xdb$BOOTSTRAP.JT_BYTEARRAY, null, null, locksraw_ref,
                      null, null, null, 1, FALSE, null, null, 
                      FALSE, FALSE, TRUE, FALSE, FALSE, 
                      null, null, null, null, FALSE, null, null, null);

      ellist(11) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_ACL,
                      'ACL', xdb.xdb$qname('01', 'ResAclType'),
                      0, 1, null, xdb.xdb$BOOTSTRAP.T_XOB, FALSE, FALSE, FALSE, 
                      null, null, null,
                      xdb.xdb$BOOTSTRAP.JT_XMLTYPE, null, null, acltype_ref,
                      null, null, null, 0, FALSE, null, null, 
                      FALSE, FALSE, TRUE, FALSE, FALSE, null, null,
                      'oracle.xdb.ResAclType', 
                      'oracle.xdb.ResAclTypeBean', 
                      FALSE, null, null, null, null, null, FALSE, 
                      xdb.xdb$BOOTSTRAP.TRANSIENT_GENERATED, FALSE);

      ellist(12) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_ACLOID,
                      'ACLOID', xdb.xdb$BOOTSTRAP.TR_BINARY,
                      1, 1, null, xdb.xdb$BOOTSTRAP.T_BINARY,
                      FALSE, FALSE, FALSE, 
                      'ACLOID', 'RAW', null,
                      xdb.xdb$BOOTSTRAP.JT_BYTEARRAY, null, null, null,
                      null, null, null, 1, FALSE, null, null, 
                      FALSE, TRUE, TRUE, FALSE, FALSE, 
                      null, null, null, null,
                      FALSE, null, null, null, null, null, TRUE, null, TRUE);

      ellist(13) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_OWNER,
                      'Owner', xdb.xdb$qname('01', 'OracleUserName'),
                      0, 1, null, xdb.xdb$BOOTSTRAP.T_CSTRING,
                      FALSE, FALSE, FALSE, 
                      null, null, null,
                      xdb.xdb$BOOTSTRAP.JT_STRING, null, null, oraclename_ref,
                      null, null, null, 0, FALSE, null, null, 
                      FALSE, FALSE, TRUE, FALSE, FALSE, 
                      null, null, null, null,
                      FALSE, null, null, null, null, null, FALSE, 
                      xdb.xdb$BOOTSTRAP.TRANSIENT_GENERATED, FALSE);

      ellist(14) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_OWNERID,
                      'OwnerID', xdb.xdb$qname('01', 'GUID'),
                      1, 1, null, xdb.xdb$BOOTSTRAP.T_BINARY,
                      FALSE, FALSE, FALSE, 
                      'OWNERID', 'RAW', null,
                      xdb.xdb$BOOTSTRAP.JT_BYTEARRAY, null, null, guid_ref,
                      null, null, null, 1, FALSE, null, null, 
                      FALSE, TRUE, TRUE, FALSE, FALSE, 
                      null, null, null, null,
                      FALSE, null, null, null, null, null, TRUE, null, TRUE);

      ellist(15) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_CREATOR,
                      'Creator', xdb.xdb$qname('01', 'OracleUserName'),
                      0, 1, null, xdb.xdb$BOOTSTRAP.T_CSTRING,
                      FALSE, FALSE, FALSE, 
                      null, null, null,
                      xdb.xdb$BOOTSTRAP.JT_STRING, null, null, oraclename_ref,
                      null, null, null, 0, FALSE, null, null, 
                      FALSE, FALSE, TRUE, FALSE, FALSE, 
                      null, null, null, null,
                      FALSE, null, null, null, null, null, FALSE, 
                      xdb.xdb$BOOTSTRAP.TRANSIENT_GENERATED, FALSE);

      ellist(16) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_CREATORID,
                      'CreatorID', xdb.xdb$qname('01', 'GUID'),
                      1, 1, null, xdb.xdb$BOOTSTRAP.T_BINARY,
                      FALSE, FALSE, FALSE, 
                      'CREATORID', 'RAW', null,
                      xdb.xdb$BOOTSTRAP.JT_BYTEARRAY, null, null, guid_ref,
                      null, null, null, 1, FALSE, null, null, 
                      FALSE, TRUE, TRUE, FALSE, FALSE, 
                      null, null, null, null,
                      FALSE, null, null, null, null, null, TRUE, null, TRUE);

      ellist(17) := xdb.xdb$bootstrap.xdb$insertElement(schref, 
                      PN_RES_LASTMODIFIER,
                      'LastModifier', xdb.xdb$qname('01', 'OracleUserName'),
                      0, 1, null, xdb.xdb$BOOTSTRAP.T_CSTRING,
                      FALSE, FALSE, FALSE, 
                      null, null, null,
                      xdb.xdb$BOOTSTRAP.JT_STRING, null, null, oraclename_ref,
                      null, null, null, 0, FALSE, null, null, 
                      FALSE, FALSE, TRUE, FALSE, FALSE, 
                      null, null, null, null,
                      FALSE, null, null, null, null, null, FALSE, 
                      xdb.xdb$BOOTSTRAP.TRANSIENT_GENERATED, FALSE);

      ellist(18) := xdb.xdb$bootstrap.xdb$insertElement(schref, 
                      PN_RES_LASTMODIFIERID,
                      'LastModifierID', xdb.xdb$qname('01', 'GUID'),
                      1, 1, null, xdb.xdb$BOOTSTRAP.T_BINARY,
                      FALSE, FALSE, FALSE, 
                      'LASTMODIFIERID', 'RAW', null,
                      xdb.xdb$BOOTSTRAP.JT_BYTEARRAY, null, null, guid_ref,
                      null, null, null, 1, FALSE, null, null, 
                      FALSE, TRUE, TRUE, FALSE, FALSE, 
                      null, null, null, null,
                      FALSE, null, null, null, null, null, TRUE, null, TRUE);

      ellist(19) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_SCHELEM,
                      'SchemaElement', xdb.xdb$qname('01', 'SchElemType'),
                      0, 1, null, xdb.xdb$BOOTSTRAP.T_CSTRING,
                      FALSE, FALSE, FALSE, 
                      null, null, null,
                      xdb.xdb$BOOTSTRAP.JT_STRING, null, null, 
                      schelemtype_ref, null, null, 
                      null, 0, FALSE, null, null, 
                      FALSE, FALSE, TRUE, FALSE, FALSE, 
                      null, null, null, null, FALSE, null, null, null, 
                      null, null, FALSE,
                      xdb.xdb$BOOTSTRAP.TRANSIENT_GENERATED, FALSE);

      ellist(20) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_ELNUM,
                      'ElNum', xdb.xdb$BOOTSTRAP.TR_NNEGINT,
                      1, 1, '4', xdb.xdb$BOOTSTRAP.T_INTEGER,
                      FALSE, FALSE, FALSE, 
                      'ELNUM', 'INTEGER', null,
                      xdb.xdb$BOOTSTRAP.JT_LONG, null, null, null, null, null, 
                      null, 1, FALSE, null, null, 
                      FALSE, TRUE, TRUE, FALSE, FALSE, 
                      null, null, null, null, FALSE, null, null, null, 
                      null, null, TRUE, null, TRUE);

      ellist(21) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_SCHOID,
                      'SchOID', xdb.xdb$BOOTSTRAP.TR_BINARY,
                      1, 1, null, xdb.xdb$BOOTSTRAP.T_BINARY,
                      FALSE, FALSE, FALSE, 
                      'SCHOID', 'RAW', null,
                      xdb.xdb$BOOTSTRAP.JT_BYTEARRAY, null, null, null,
                      null, null, null, 1, FALSE, null, null, 
                      FALSE, TRUE, TRUE, FALSE, FALSE, 
                      null, null, null, null,
                      FALSE, null, null, null, null, null, TRUE, null, TRUE);

      ellist(22) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_CONTENTS,
                      'Contents', xdb.xdb$qname('01', 'ResContentsType'),
                      0, 1, null, xdb.xdb$BOOTSTRAP.T_XOB, FALSE, FALSE, FALSE, 
                      null, null, null,
                      xdb.xdb$BOOTSTRAP.JT_XMLTYPE, null, null, conttype_ref,
                      null, null, null, 0, FALSE, null, null, 
                      FALSE, FALSE, TRUE, FALSE, FALSE, null, null,
                      'oracle.xdb.ResContentsType', 
                      'oracle.xdb.ResContentsTypeBean', 
                      FALSE, null, null, null, null, null, FALSE, 
                      xdb.xdb$BOOTSTRAP.TRANSIENT_MANIFESTED, FALSE);

      ellist(23) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_XMLREF,
                      'XMLRef', xdb.xdb$qname('00', 'REF'),
                      0, 1, null, xdb.xdb$BOOTSTRAP.T_REF, FALSE, TRUE, FALSE, 
                      'XMLREF', 'REF', null,
                      xdb.xdb$BOOTSTRAP.JT_REFERENCE, null, null, 
                      null, null, null, 
                      null, 1, FALSE, null, null, 
                      FALSE, FALSE, TRUE, FALSE, FALSE, 
                      null, null, null, null, FALSE, null, null, null,
                      null, null, TRUE, null, FALSE);

      ellist(24) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_XMLLOB,
                      'XMLLob', xdb.xdb$BOOTSTRAP.TR_BINARY,
                      0, 1, null, '71',
                      FALSE, TRUE, FALSE, 
                      'XMLLOB', 'BLOB', null,
                      xdb.xdb$BOOTSTRAP.JT_STRING, null, null, null, null, null, 
                      null, 1, FALSE, null, null, 
                      FALSE, FALSE, TRUE, FALSE, FALSE, 
                      null, null, null, null, FALSE, null, null, null, 
                      null, null, TRUE, null, FALSE);

      ellist(25) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_FLAGS,
                      'Flags', xdb.xdb$BOOTSTRAP.TR_NNEGINT,
                      1, 1, '4', xdb.xdb$BOOTSTRAP.T_INTEGER,
                      FALSE, TRUE, FALSE, 
                      'FLAGS', 'RAW', null,
                      xdb.xdb$BOOTSTRAP.JT_LONG, null, null, null, null, null, 
                      null, 1, FALSE, null, null, 
                      FALSE, TRUE, TRUE, FALSE, FALSE, 
                      null, null, null, null, FALSE, null, null, null,
                      null, null, TRUE, null, TRUE);

      ellist(26) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_VCRUID,
                      'VCRUID', xdb.xdb$qname('01', 'GUID'),
                      1, 1, null, xdb.xdb$BOOTSTRAP.T_BINARY,
                      FALSE, FALSE, FALSE, 
                      'VCRUID', 'RAW', null,
                      xdb.xdb$BOOTSTRAP.JT_BYTEARRAY, null, null, guid_ref,
                      null, null, null, 1, FALSE, null, null, 
                      FALSE, FALSE, TRUE, FALSE, FALSE, 
                      null, null, null, null,
                      FALSE, null, null, null);

      ellist(27) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_PARENTS, 
                      'Parents', xdb.xdb$BOOTSTRAP.TR_BINARY,
                      0, 1000,null, xdb.xdb$BOOTSTRAP.T_BINARY,
                      FALSE, FALSE, FALSE, 
                      'PARENTS', 'RAW', null,
                      xdb.xdb$BOOTSTRAP.JT_REFERENCE, null, null, null,
                      null, null, null, 0, FALSE, null, null,
                      FALSE, FALSE, TRUE, FALSE, FALSE,
                      null, null, null, null,
                      FALSE, null, null, null, 'XDB$PREDECESSOR_LIST_T','XDB');

      ellist(28) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_SBRESEXTRA,
                      'SBResExtra', xdb.xdb$qname('00', 'REF'),
                      0, 2147483647, null, xdb.xdb$BOOTSTRAP.T_REF, FALSE, TRUE, 
                      FALSE, 'SBRESEXTRA', 'REF', null,
                      xdb.xdb$BOOTSTRAP.JT_REFERENCE, null, null, 
                      null, null, null, 
                      null, 1, FALSE, null, null, 
                      FALSE, FALSE, TRUE, FALSE, FALSE, 
                      null, null, null, null, FALSE, null, null, null,
                      'XDB$XMLTYPE_REF_LIST_T', 'XDB', TRUE, null, FALSE);

      anylist := xdb.xdb$xmltype_ref_list_t();
      anylist.extend(1);

      anylist(1) := xdb.xdb$bootstrap.xdb$insertAny(schref, PN_RES_RESEXTRA,
                                'ResExtra', null, '##other', 0, 65535, null, 
                                xdb.xdb$BOOTSTRAP.T_XOB, FALSE, FALSE, FALSE, 
                                'RESEXTRA', 'CLOB', null,
                                xdb.xdb$BOOTSTRAP.JT_XMLTYPE, null,
                                null, null, null, null);

     resource_ref := xdb.xdb$bootstrap.xdb$insertComplex(schref, 
                          null, 'ResourceType',
                          null, FALSE, null, '0',
                          null, null, null, null, null, null, null, null, null,
                          null, null, null, null, null, null, ellist, attlist,
                          anylist);
     complexlist(4) := resource_ref;


/*--------------------------------------------------------------------------*/
/* "Resource" top-level element */
/*--------------------------------------------------------------------------*/

     schels(1) := xdb.xdb$bootstrap.xdb$insertElement(schref, PN_RES_RESOURCE,
                'Resource', xdb.xdb$qname('01', 'ResourceType'),
                 1, 1, null, xdb.xdb$BOOTSTRAP.T_XOB, FALSE, FALSE, 
                 FALSE, 'RESOURCE', 'XDB$RESOURCE_T', 'XDB', 
                 xdb.xdb$BOOTSTRAP.JT_XMLTYPE, null, null, 
                 resource_ref, null, null, null,
                 res_colcount, FALSE, null, null, 
                 FALSE, FALSE, FALSE, FALSE, FALSE,
                'XDB$RESOURCE', null, 'oracle.xdb.Resource', 
                'oracle.xdb.ResourceBean', TRUE, null, null, null);


/*--------------------------------------------------------------------------*/
/* Update schema to have all top-level property definitions */
/*--------------------------------------------------------------------------*/

        execute immediate 'update xdb.xdb$schema s set 
                s.xmldata.elements = :1, 
                s.xmldata.simple_type = :2, 
                s.xmldata.complex_types = :3,
                s.xmldata.num_props = :4 
               where s.xmldata.schema_url = 
               ''http://xmlns.oracle.com/xdb/XDBResource.xsd'''
                using schels, simplelist, complexlist, PN_RES_TOTAL_PROPNUMS;

end;

END;
/
show errors


/***** KGL initialization is invoked internally ******/

/* -------------  INVOKE BOOTSTRAP DRIVER FOR RESOURCE SCHEMA -------------- */

begin
  xdb.xdb$bootstrapres.driver();
  commit;       
end;
/

