Rem
Rem $Header: dbmsxmlt.sql 21-jan-2005.17:29:56 mture Exp $
Rem
Rem dbmsxmlt.sql
Rem
Rem Copyright (c) 1900, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmsxmlt.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mture       01/17/05 - Mv XMLAGG to prvtxmlt.sql, remove AggXMLInputType
Rem    amanikut    07/29/03 - grant execute on AggXMLImp with grant option
Rem    ayoaz       03/20/03 - add in/out opn args to XMLAGG init callout
Rem    zliu        03/06/03 - fix 2798283, no pq for getclob() etc
Rem    jwwarner    01/27/03 - change creation of xmlgenformattype
Rem    njalali     01/16/03 - bug 2744444
Rem    amanikut    11/15/02 - Add insertXML, appendChildXML, deleteXML
Rem    zliu        11/12/02 - pq for xmltype
Rem    mkrishna    11/15/02 - add deterministic to xmlgenformattype
Rem    mkrishna    11/14/02 - add arguments to XMLGenfOrmattype
Rem    thoang      10/15/02 - Add createXML for BLOB and BFILE input 
Rem    jwwarner    10/14/02 - add xmltype constructor from anydata
Rem    abagrawa    09/18/02 - Add BLOB constructor
Rem    ayoaz       05/15/02 - change key to raw(8) in AggXMLImp.
Rem    amanikut    02/02/02 - switch wellformed, validated flags
Rem    amanikut    01/30/02 - change ctors to return deterministic
Rem    amanikut    01/18/02 - add wellformed flag
Rem    spannala    01/14/02 - changing OID of the XMLSequenceType
Rem    spannala    01/11/02 - making all systems types have standard TOIDs
Rem    amanikut    12/06/01 - LRG 82051 : fix constructor signature
Rem    amanikut    11/26/01 - make NOT VALIDATED as default
Rem    jwwarner    11/01/01 - fix upgrade issues
Rem    vnimani     10/11/01 - rename isValid to validate; create new isValid
Rem    vnimani     10/01/01 - add setValid
Rem    smuralid    10/24/01 - change ALTER TYPE REPLACE to CREATE
Rem    jwwarner    10/18/01 - Change to alter type replace
Rem    jwwarner    10/15/01 - upgrade/downgrade changes
Rem    amanikut    09/28/01 - add validated flag
Rem    amanikut    09/28/01 - add XMLType constructors taking schema
Rem    amanikut    09/25/01 - add cons_XMLType_.*
Rem    amanikut    09/05/01 - add XMLType constructors
Rem    mkrishna    10/01/01 - update\040constructors,\040static\040functions
Rem    mkrishna    09/14/01 - add synonym for xmltype & xmlgenformat
Rem    amanikut    08/27/01 - add XMLAGG
Rem    mkrishna    08/29/01 - remove  EXISTSNODE, EXTRACT operators
Rem    jwwarner    08/16/01 - XMLSequence -> XMLSequenceType
Rem    amanikut    08/10/01 - modify toObject()
Rem    mkrishna    07/29/01 - move catalog views to catxdbv.sql
Rem    amanikut    08/03/01 - add toObject()
Rem    bkhaladk    07/18/01 - add NS support to extract.
Rem    jwwarner    07/27/01 - XML table functions changes
Rem    mkrishna    07/02/01 - use rowtype of XMLType for catalog views
Rem    jwwarner    07/11/01 - add XMLTable function
Rem    amanikut    07/26/01 - add createXML(REF CURSOR)
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    bkhaladk    06/08/01 - add xslt transform function.
Rem    rmurthy     06/04/01 - add schema related functions
Rem    mkrishna    05/10/01 - Add xmltype tables and views
Rem    njalali     04/30/01 - added second VARRAY to XMLTypeExtra
Rem    nmontoya    04/17/01 - 
Rem    njalali     04/16/01 - added second top-level extras
Rem    mkrishna    02/26/01 - disable parallel clause for SYS_XMLAGG
Rem    mkrishna    02/15/01 - add wrap context for SYS_XMLAGG
Rem    mkrishna    12/06/00 - change TOIDs for XML, uri types
Rem    mkrishna    11/15/00 - add TOID for replication
Rem    mkrishna    11/04/00 - add deterministic keyword
Rem    mkrishna    10/23/00 - change boolean in existsnode to number
Rem    mkrishna    09/20/00 - change to operators
Rem    mkrishna    09/19/00 - fix ctx rewrite
Rem    mkrishna    11/08/00 - fix varray column
Rem    mkrishna    11/04/00 - add varray of varchar
Rem    mkrishna    09/15/00 - change ops to functions
Rem    mkrishna    08/12/00 - add xmlgenformattype
Rem    mkrishna    07/21/00 - add flags to Terminate
Rem    mkrishna    07/17/00 - change AGG_XML to SYS_XMLAGG
Rem    mkrishna    06/30/00 - add TO_AGG_XML 
Rem    mkrishna    04/11/00 - change to boolean
Rem    mkrishna    03/09/00 - XMLType definition
Rem    mkrishna    01/00/00 - Created
Rem

create library xmltype_lib trusted as static
/

Rem ************************** XMLType Definition ***************************
Rem ** IMPORTANT: The create or replace XMLType is FROZEN as of 9.0.1.1.0.
Rem ** All new additions to XMLType must be placed in the ALTER TYPE REPLACE
Rem ** following the create or replace type.
Rem *************************************************************************
create or replace type XMLType OID '00000000000000000000000000020100'
  authid current_user as opaque varying (*) 
 using library xmltype_lib 
( 
  -- creates the XML data 
  static function createXML (xmlData IN clob) return sys.XMLType deterministic,
  static function createXML (xmlData IN varchar2) return sys.XMLType deterministic,

  -- extract function
  member function extract(xpath IN varchar2) return sys.XMLType deterministic,

  -- existsNode function
  member function existsNode(xpath IN varchar2) return number deterministic,
  
  -- is it a fragment? 
  member function isFragment return number deterministic,

  -- extraction functions..!  
  -- do we want the encoding to be specified in the result or not ..? 
  member function getClobVal return CLOB deterministic,
  member function getStringVal return varchar2 deterministic,
  member function getNumberVal return number deterministic

)
/
show errors

Rem *************************************************************************

Rem *********************** ADDITIONS TO XMLTYPE ****************************
Rem ** All additions to XMLType must be put as an ALTER TYPE add here.
Rem *************************************************************************
alter type sys.XMLType replace
  authid current_user as opaque varying (*) 
  using library xmltype_lib 
(
  -- creates the XML data 
  static function createXML (xmlData IN clob) return sys.XMLType deterministic parallel_enable,
  static function createXML (xmlData IN varchar2) return sys.XMLType deterministic parallel_enable,
  -- extract function
  member function extract(xpath IN varchar2) return sys.XMLType deterministic parallel_enable,
  -- existsNode function
  member function existsNode(xpath IN varchar2) return number deterministic parallel_enable,
  -- is it a fragment? 
  member function isFragment return number deterministic parallel_enable,
  -- extraction functions..!  
  -- do we want the encoding to be specified in the result or not ..? 
  member function getClobVal return CLOB deterministic ,
  member function getBlobVal(csid IN number) return BLOB deterministic ,
  member function getStringVal return varchar2 deterministic parallel_enable,
  member function getNumberVal return number deterministic parallel_enable,
  -- FUNCTIONS NEW IN 9iR2
  -- new versions of createxml
  STATIC FUNCTION createXML (xmlData IN clob, schema IN varchar2,
                 validated IN number := 0, wellformed IN number := 0) 
                 return sys.XMLType deterministic parallel_enable,
  STATIC FUNCTION createXML (xmlData IN blob, csid IN number,
                 schema IN varchar2,
                 validated IN number := 0, wellformed IN number := 0) 
                 return sys.XMLType deterministic parallel_enable,
  STATIC FUNCTION createXML (xmlData IN bfile, csid IN number,
                 schema IN varchar2,
                 validated IN number := 0, wellformed IN number := 0)
                 return sys.XMLType deterministic parallel_enable,
  STATIC FUNCTION createXML (xmlData IN varchar2, schema IN varchar2,
                 validated IN number := 0, wellformed IN number := 0) 
                 return sys.XMLType deterministic parallel_enable,
  STATIC FUNCTION createXML (xmlData IN "<ADT_1>",
                 schema IN varchar2 := NULL, element IN varchar2 := NULL,
                 validated IN NUMBER := 0)
    return sys.XMLType deterministic parallel_enable,
  STATIC FUNCTION createXML (xmlData IN SYS_REFCURSOR,
                 schema in varchar2 := NULL, element in varchar2 := NULL, 
                 validated in number := 0) 
     return sys.XMLType deterministic parallel_enable,
  STATIC FUNCTION createXML (xmlData IN AnyData,
                 schema in varchar2 := NULL, element in varchar2 := NULL, 
                 validated in number := 0) 
     return sys.XMLType deterministic parallel_enable,
  -- new versions of extract and existsnode with nsmap
  MEMBER FUNCTION extract(xpath IN varchar2, nsmap IN VARCHAR2)
    return sys.XMLType deterministic parallel_enable,
  MEMBER FUNCTION existsNode(xpath in varchar2, nsmap in varchar2)
    return number deterministic parallel_enable,
  -- transform function
  member function transform(xsl IN sys.XMLType,
                                parammap in varchar2 := NULL)
    return sys.XMLType deterministic parallel_enable,
  -- conversion functions
  MEMBER PROCEDURE toObject(SELF in sys.XMLType, object OUT "<ADT_1>",
                                schema in varchar2 := NULL,
                                element in varchar2 := NULL),
  -- schema related functions
  MEMBER FUNCTION isSchemaBased return number deterministic parallel_enable,
  MEMBER FUNCTION getSchemaURL return varchar2 deterministic parallel_enable,
  MEMBER FUNCTION getRootElement return varchar2 deterministic parallel_enable,
  -- create schema and nonschema based
  MEMBER FUNCTION createSchemaBasedXML(schema IN varchar2 := NULL)
     return sys.XMLType deterministic parallel_enable,
  -- creates a non schema based document from self
  MEMBER FUNCTION createNonSchemaBasedXML return sys.XMLType deterministic parallel_enable,
  member function getNamespace return varchar2 deterministic parallel_enable,
  -- validates schema based document if VALIDATED flag is false
  member procedure schemaValidate(self IN OUT NOCOPY XMLType),
  -- returns the value of the VALIDATED flag of the document; tells if
  -- a schema based doc. has been actually validated against its schema.
  member function isSchemaValidated return NUMBER deterministic parallel_enable,
  -- sets the VALIDATED flag to user desired value
  member procedure setSchemaValidated(self IN OUT NOCOPY XMLType, 
                                      flag IN BINARY_INTEGER := 1),
  -- checks if doc is conformant to a specified schema; non mutating
  member function isSchemaValid(schurl IN VARCHAR2 := NULL, 
                         elem IN VARCHAR2 := NULL) return NUMBER 
                         deterministic parallel_enable,
  member function insertXMLBefore(xpath IN VARCHAR2, value_expr IN XMLType, 
           namespace IN VARCHAR2 := NULL) return XMLType 
           deterministic parallel_enable,
  member function appendChildXML(xpath IN VARCHAR2, value_expr IN XMLType, 
         namespace IN VARCHAR2 := NULL) return XMLType 
         deterministic parallel_enable,
  member function deleteXML(xpath IN VARCHAR2, namespace IN VARCHAR2 := NULL)
         return XMLType deterministic parallel_enable,
  -- constructors
  constructor function XMLType(xmlData IN clob, schema IN varchar2 := NULL,
                validated IN number := 0, wellformed IN number := 0) 
    return self as result deterministic parallel_enable,
  constructor function XMLType(xmlData IN blob, csid IN number, 
                               schema IN varchar2 := NULL,
                validated IN number := 0, wellformed IN number := 0) 
    return self as result deterministic parallel_enable,
  constructor function XMLType(xmlData IN bfile, csid IN number, 
                               schema IN varchar2 := NULL,
                validated IN number := 0, wellformed IN number := 0) 
    return self as result deterministic parallel_enable,
  constructor function XMLType(xmlData IN varchar2, schema IN varchar2 := NULL
                , validated IN number := 0, wellformed IN number := 0) 
    return self as result deterministic parallel_enable,
  constructor function XMLType (xmlData IN "<ADT_1>",
                schema IN varchar2 := NULL, element IN varchar2 := NULL,
                validated IN number := 0) 
    return self as result deterministic parallel_enable,
  constructor function XMLType (xmlData IN AnyData,
                schema IN varchar2 := NULL, element IN varchar2 := NULL,
                validated IN number := 0) 
    return self as result deterministic parallel_enable,
  constructor function XMLType(xmlData IN SYS_REFCURSOR,
                schema in varchar2 := NULL, element in varchar2 := NULL, 
                validated in number := 0) 
    return self as result deterministic parallel_enable
  --, PRAGMA RESTRICT_REFERENCES(DEFAULT, WNPS, RNPS)
);

show errors;

Rem ********************** END OF XMLTYPE ADDITIONS **************************

GRANT EXECUTE ON XmlType TO PUBLIC with grant option
/
create public synoNYM XMLType for sys.xmltype;


Rem ********************* XMLGenFormatType Definition ***********************
Rem ** IMPORTANT: When adding new attributes or functions to xmlgenformattype
Rem **  you MUST also drop these methods in the downgrade (e***.sql) and
Rem **  do an alter type add of them in the upgrade (c***.sql).
Rem *************************************************************************

create or replace type XMLGenFormatType OID '00000000000000000000000000020102'
  as object
(
  enclTag varchar2(4000),   -- the name for the enclosing tag
  schemaType varchar2(100), -- one of 'NO_SCHEMA', 'GEN_SCHEMA_INLINE',
                            -- 'GEN_SCHEMA_OUTOFLINE', 'USE_GIVEN_SCHEMA'
  schemaName      varchar2(4000), -- the schema name (if USE_GIVEN_SCHEMA)
  targetNameSpace varchar2(4000), -- the target name space (default NULL)
  dbUrlPrefix   varchar2(4000),  -- the url prefix to use for outofline schemas
  processingIns varchar2(4000),-- processing instructions to add, if any,A
  controlflag raw(4),
  STATIC FUNCTION createFormat(
     enclTag IN varchar2 := 'ROWSET',
     schemaType IN varchar2 := 'NO_SCHEMA',
     schemaName IN varchar2 := null,
     targetNameSpace IN varchar2 := null,
     dburlPrefix IN varchar2 := null, 
     processingIns IN varchar2 := null) RETURN XMLGenFormatType
       deterministic parallel_enable,
  MEMBER PROCEDURE genSchema (spec IN varchar2),
  MEMBER PROCEDURE setSchemaName(schemaName IN varchar2),
  MEMBER PROCEDURE setTargetNameSpace(targetNameSpace IN varchar2),
  MEMBER PROCEDURE setEnclosingElementName(enclTag IN varchar2), 
  MEMBER PROCEDURE setDbUrlPrefix(prefix IN varchar2),
  MEMBER PROCEDURE setProcessingIns(pi IN varchar2),
  CONSTRUCTOR FUNCTION XMLGenFormatType (
     enclTag IN varchar2 := 'ROWSET',
     schemaType IN varchar2 := 'NO_SCHEMA',
     schemaName IN varchar2 := null,
     targetNameSpace IN varchar2 := null,
     dbUrlPrefix IN varchar2 := null, 
     processingIns IN varchar2 := null) RETURN SELF AS RESULT
      deterministic parallel_enable,
  STATIC function createFormat2(
      enclTag in varchar2 := 'ROWSET',
      flags in raw) return sys.xmlgenformattype 
      deterministic parallel_enable
);
/

show errors;
Rem *************************************************************************

grant execute on XMLGenFormatType to public with grant option;
create public synonym xmlformat for sys.xmlgenformattype;


Rem varray of varchars to allow processing instructions, comments,
Rem namespaces, prefixes, etc...!
Rem drop type XMLTypeExtra;
Rem drop type XMLTypePI;
create type XMLTypePI OID '0000000000000000000000000002014F' as
varray(2147483647) of RAW(2000);
/
create type XMLTypeExtra OID '00000000000000000000000000020150' as object
(
  namespaces  XMLTypePI,
  extraData   XMLTypePI
); 
/
grant execute on XMLTypePI to public with grant option;
grant execute on XMLTypeExtra to public with grant option;


create or replace type XMLSequenceType OID '00000000000000000000000000020153'
as varray(2147483647) of XMLType;
/
show errors;

Grant execute on XMLSequenceType to public with grant option;

