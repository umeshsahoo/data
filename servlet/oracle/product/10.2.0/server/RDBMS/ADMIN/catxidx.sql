Rem
Rem $Header: catxidx.sql 08-mar-2005.15:42:49 attran Exp $
Rem
Rem catxidx.sql
Rem
Rem Copyright (c) 2004, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catxidx.sql - XMLIndex related schema objects
Rem
Rem    DESCRIPTION
Rem     This script creates the views, packages, index types, operators and 
Rem     indexes required for supporting the XMLIndex
Rem
Rem    NOTES
Rem      This script should be run as "XDB".
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    attran      03/08/05 - Execute Privilege to the LOAD func
Rem    sichandr    03/03/05 - pipelined table func implementation 
Rem    attran      03/01/05 - Load into VALUE LOBs
Rem    attran      11/08/04 - STATISTICS
Rem    smukkama    09/27/04 - move xmlidx token plsql stuff from catxdbtm.sql
Rem    attran      10/31/04 - Security: obsolete operators.
Rem    attran      09/17/04 - Security: grant to public
Rem    attran      08/20/04 - Up/Down/grade
Rem    sichandr    08/26/04 - Add isnode function
Rem    athusoo     07/30/04 - Add hastext function 
Rem    athusoo     07/20/04 - use VARCHAR2 for value 
Rem    sichandr    07/18/04 - Load into CLOB
Rem    athusoo     07/08/04 - Add isattr function 
Rem    sichandr    06/18/04 - add pull table function 
Rem    athusoo     06/03/04 - Add support for xmlindex_parent operator 
Rem    sichandr    04/08/04 - add xmlindex_depth 
Rem    athusoo     03/30/04 - Add maxchild function 
Rem    athusoo     03/18/04 - Add pathstr parameter to IndexStart
Rem    athusoo     03/16/04 - Convert to xmlindex_getnodes operator 
Rem    attran      02/17/04 - Created

disassociate statistics from indextypes XDB.XMLINDEX;
disassociate statistics from packages XDB.XMLINDEX_FUNCIMPL;
--drop library xdb.xmlindex_lib;
--drop indextype XDB.XMLIndex;

declare
  exist number;
begin
  select count(*) into exist from DBA_TABLES where table_name = 'XDB$DXPTAB'
  and owner = 'XDB';

  if exist = 0 then
    execute immediate
      'create table xdb.xdb$dxptab (
         idxobj#     number,                            -- object # of XMLIndex
         pathtabobj# number not null,                 -- object # of PATH TABLE
         flags       number,                      -- 0x01 INCLUDED vs EXCLUDED
                                                  -- 0x08 STORE AS BLOB vs RAW,
                              --    this could be obtained from TAB$ X COL$ ...
         rawsize     number,                               -- size of RAW value
           constraint xdb$dxptabpk primary key (idxobj#))';
    execute immediate
      'create unique index xdb.xdb$idxptab on xdb.xdb$dxptab(pathtabobj#)';

    execute immediate
      'create table xdb.xdb$dxpath (
         idxobj# number not null,                       -- object # of XMLIndex
         xpath   NVARCHAR2(2000) not null,                -- namespace or xpath
         flags   number not null)';             -- 0x01 NAMESPACE aka non-XPATH
    execute immediate
      'create index xdb.xdb$idxpath on xdb.xdb$dxpath(idxobj#)';
  end if;

end;
/

/*-----------------------------------------------------------------------*/
/*  LIBRARY                                                              */
/*-----------------------------------------------------------------------*/
create or replace library XDB.XMLIndex_lib trusted as static;
/
show errors;

/*-----------------------------------------------------------------------*/
/*  TYPE IMPLEMENTATION                                                  */
/*-----------------------------------------------------------------------*/
create or replace type xdb.XMLIndexMethods
  OID '10000000000000000000000000020118'
  authid current_user as object
(
  -- cursor set by IndexStart and used in IndexFetch
  scanctx RAW(8),

  -- DCLs
  static function ODCIGetInterfaces (ilist OUT sys.ODCIObjectList)
         return NUMBER,

  -- DDLs
  static function ODCIIndexCreate   (idxinfo  sys.ODCIIndexInfo,
                                     idxparms VARCHAR2,
                                     idxenv   sys.ODCIEnv)
         return NUMBER
  is language C name "QMIX_CREATE" library XDB.XMLINDEX_LIB
     with context
     parameters (
       context,
       idxinfo, idxinfo  INDICATOR struct,
       idxparms,idxparms INDICATOR,
       idxenv,  idxenv   INDICATOR struct,
       RETURN OCINumber),

  static function ODCIIndexDrop     (idxinfo sys.ODCIIndexInfo,
                                     idxenv  sys.ODCIEnv)
         return NUMBER
  is language C name "QMIX_DROP" library XDB.XMLINDEX_LIB
     with context
     parameters (
       context,
       idxinfo, idxinfo INDICATOR struct,
       idxenv,  idxenv  INDICATOR struct,
       RETURN OCINumber),

  static function ODCIIndexAlter    (idxinfo          sys.ODCIIndexInfo, 
                                     idxparms  IN OUT VARCHAR2,
                                     opt              NUMBER,
                                     idxenv           sys.ODCIEnv)
         return NUMBER
  is language C name "QMIX_ALTER" library XDB.XMLINDEX_LIB
     with context
     parameters (
       context,
       idxinfo, idxinfo  INDICATOR struct,
       idxparms,idxparms INDICATOR,
       opt,     opt      INDICATOR,
       idxenv,  idxenv   INDICATOR struct,
       RETURN OCINumber),

  static function ODCIIndexTruncate (idxinfo sys.ODCIIndexInfo,
                                     idxenv  sys.ODCIEnv)
         return NUMBER
  is language C name "QMIX_TRUNC" library XDB.XMLINDEX_LIB
     with context
     parameters (
       context,
       idxinfo, idxinfo INDICATOR struct,
       idxenv,  idxenv  INDICATOR struct,
       RETURN OCINumber),

  --- DMLs ---
  static function ODCIIndexInsert (idxinfo sys.ODCIIndexInfo,
                                   rid     VARCHAR2,
                                   doc     sys.xmltype,
                                   idxenv  sys.ODCIEnv)
         return NUMBER
  is language C name "QMIX_INSERT" library XDB.XMLINDEX_LIB
     with context
     parameters (
       context,
       idxinfo, idxinfo INDICATOR struct,
       rid,     rid     INDICATOR,
       doc,     doc     INDICATOR,
       idxenv,  idxenv  INDICATOR struct,
       RETURN OCINumber),

  static function ODCIIndexDelete (idxinfo sys.ODCIIndexInfo,
                                   rid     VARCHAR2,
                                   doc     sys.xmltype,
                                   idxenv  sys.ODCIEnv)
         return NUMBER
  is language C name "QMIX_DELETE" library XDB.XMLINDEX_LIB
     with context
     parameters (
       context,
       idxinfo, idxinfo INDICATOR struct,
       rid,     rid     INDICATOR,
       doc,     doc     INDICATOR,
       idxenv,  idxenv  INDICATOR struct,
       RETURN OCINumber),

  static function ODCIIndexUpdate (idxinfo sys.ODCIIndexInfo,
                                   rid     VARCHAR2,
                                   olddoc  sys.xmltype,
                                   newdoc  sys.xmltype,
                                   idxenv  sys.ODCIEnv)
         return NUMBER
  is language C name "QMIX_UPDATE" library XDB.XMLINDEX_LIB
     with context
     parameters (
       context,
       idxinfo, idxinfo INDICATOR struct,
       rid,     rid     INDICATOR,
       olddoc,  olddoc  INDICATOR,
       newdoc,  newdoc  INDICATOR,
       idxenv,  idxenv  INDICATOR struct,
       RETURN OCINumber),

  --- Query ---
  static function ODCIIndexStart (ictx    IN OUT XMLIndexMethods,
                                  idxinfo        sys.ODCIIndexInfo,
                                  opi            sys.ODCIPredInfo, 
                                  oqi            sys.ODCIQueryInfo,
                                  strt           NUMBER,
                                  stop           NUMBER,
                                  pathstr        varchar2,
                                  idxenv         sys.ODCIEnv)
         return NUMBER
  is language C name "QMIX_START" library XDB.XMLINDEX_LIB
     with context
     parameters (
       context,
       ictx,    ictx    INDICATOR struct,
       idxinfo, idxinfo INDICATOR struct,
       opi,     opi     INDICATOR struct,
       oqi,     oqi     INDICATOR struct,
       strt,    strt    INDICATOR, 
       stop,    stop    INDICATOR,
       pathstr, pathstr LENGTH,
       idxenv,  idxenv  INDICATOR struct,
       return OCINumber),

  member function ODCIIndexFetch (nrows      NUMBER,
                                  rids   OUT sys.ODCIRidList,
                                  idxenv     sys.ODCIEnv)
         return  NUMBER
  is language C name "QMIX_FETCH" library XDB.XMLINDEX_LIB
     with context
     parameters (
       context,
       self,     self INDICATOR struct,
       nrows,   nrows INDICATOR,
       rids,     rids INDICATOR,
       idxenv, idxenv INDICATOR struct,
       return OCINumber),

  member function ODCIIndexClose (idxenv sys.ODCIEnv)
         return NUMBER
  is language C name "QMIX_CLOSE" LIBRARY XDB.XMLINDEX_LIB
     with context parameters (
       context,
       self,     self INDICATOR struct,
       idxenv, idxenv INDICATOR struct,
       return OCINumber),

  --- MOVE / TRANSPORTABLE TBS / IM/EXPORT ---
  static function ODCIIndexGetMetadata (idxinfo  IN  sys.ODCIIndexInfo,
                                        expver   IN  VARCHAR2,
                                        newblock OUT number,
                                        idxenv   IN  sys.ODCIEnv)
         return NUMBER
  is language C name "QMIX_METADATA" library XDB.XMLINDEX_LIB
     with context
     parameters (
       context,
       idxinfo, idxinfo  INDICATOR struct,
       expver,  expver   INDICATOR,
       newblock,newblock INDICATOR,
       idxenv,  idxenv   INDICATOR struct,
       RETURN OCINumber),


  static function ODCIIndexUtilGetTableNames (idxinfo  IN  sys.ODCIIndexInfo,
                                              rdonly   IN  number,
                                              version  IN  VARCHAR2,
                                              ctxt     OUT number) 
         return NUMBER
  is language C name "QMIX_TABNAM" library XDB.XMLINDEX_LIB
     with context
     parameters (
       context,
       idxinfo, idxinfo  INDICATOR struct,
       rdonly,  rdonly   INDICATOR,
       version, version  INDICATOR,
       ctxt,    ctxt     INDICATOR,
       RETURN OCINumber)
);
/
show errors;

create or replace type body xdb.XMLIndexMethods
is 
  static function ODCIGetInterfaces(ilist OUT sys.ODCIObjectList) 
    return number is 
  begin 
    ilist := sys.ODCIObjectList(sys.ODCIObject('SYS','ODCIINDEX2'));
    return ODCICONST.SUCCESS;
  end ODCIGetInterfaces;
end;
/
show errors;
--grant execute on XDB.XMLIndexMethods to public;


create or replace type xdb.XMLIdxStatsMethods
  OID '20000000000000000000000000023456'
  authid current_user as object
(
  -- user-defined function cost and selectivity functions
  cost number,

  -- DCLs
  static function ODCIGetInterfaces (ilist OUT sys.ODCIObjectList)
         return NUMBER,

  --- STATISTICs ---
  static function ODCIStatsCollect(colinfo   sys.ODCIColInfo,
                                   options   sys.ODCIStatsOptions,
                                   stats OUT RAW,
                                   idxenv    sys.ODCIEnv)
         return NUMBER
  is language C name "QMIX_COL_STATS" LIBRARY XDB.XMLINDEX_LIB
     with context parameters (
       context,
       colinfo, colinfo INDICATOR struct,
       options, options INDICATOR struct,
       stats,   stats   INDICATOR, stats LENGTH,
       idxenv,  idxenv  INDICATOR struct,
       return OCINumber),

  static function ODCIStatsCollect(idxinfo   sys.ODCIIndexInfo,
                                   options   sys.ODCIStatsOptions,
                                   stats OUT RAW,
                                   idxenv    sys.ODCIEnv)
         return NUMBER
  is language C name "QMIX_IDX_STATS" LIBRARY XDB.XMLINDEX_LIB
     with context parameters (
       context,
       idxinfo, idxinfo INDICATOR struct,
       options, options INDICATOR struct,
       stats,   stats   INDICATOR, stats LENGTH,
       idxenv,  idxenv  INDICATOR struct,
       return OCINumber),

  static function ODCIStatsDelete(colinfo   sys.ODCIColInfo,
                                  statistics OUT RAW,
                                  idxenv    sys.ODCIEnv)
         return NUMBER
  is language C name "QMIX_DEL_COLSTATS" LIBRARY XDB.XMLINDEX_LIB
     with context parameters (
       context,
       colinfo,    colinfo    INDICATOR struct,
       statistics, statistics INDICATOR, statistics LENGTH,
       idxenv,     idxenv     INDICATOR struct,
       return OCINumber),

  static function ODCIStatsDelete(idxinfo   sys.ODCIIndexInfo,
                                  statistics OUT RAW,
                                  idxenv    sys.ODCIEnv)
         return NUMBER
  is language C name "QMIX_DEL_IDXSTATS" LIBRARY XDB.XMLINDEX_LIB
     with context parameters (
       context,
       idxinfo,    idxinfo    INDICATOR struct,
       statistics, statistics INDICATOR, statistics LENGTH,
       idxenv,     idxenv     INDICATOR struct,
       return OCINumber),

  static function ODCIStatsSelectivity(predinfo sys.ODCIPredInfo,
                                       sel  OUT number,
                                       args     sys.ODCIArgDescList,
                                       strt     number,
                                       stop     number,
                                       expr     VARCHAR2,
                                       datai    VARCHAR2,
                                       idxenv   sys.ODCIEnv)
         return NUMBER
  is language C name "QMIX_SELECTIVITY" library XDB.XMLINDEX_LIB
     with context
     parameters (
       context,
       predinfo,predinfo INDICATOR struct,
       sel,     sel      INDICATOR,
       args,    args     INDICATOR,
       strt,    strt     INDICATOR, 
       stop,    stop     INDICATOR,
       expr,    expr     INDICATOR,
       datai,   datai    INDICATOR,
       idxenv,  idxenv   INDICATOR struct,
       return OCINumber),

  static function ODCIStatsFunctionCost(funcinfo sys.ODCIFuncInfo,
                                        cost OUT sys.ODCICost,
                                        args     sys.ODCIArgDescList,
                                        expr     VARCHAR2,
                                        datai    VARCHAR2,
                                        idxenv   sys.ODCIEnv)
         return NUMBER
  is language C name "QMIX_FUN_COST" library XDB.XMLINDEX_LIB
     with context
     parameters (
       context,
       funcinfo,funcinfo INDICATOR struct,
       cost,    cost     INDICATOR struct,
       args,    args     INDICATOR,
       expr,    expr     INDICATOR,
       datai,   datai    INDICATOR,
       idxenv,  idxenv   INDICATOR struct,
       return OCINumber),

  static function ODCIStatsIndexCost(idxinfo  sys.ODCIIndexInfo,
                                     sel      number,
                                     cost OUT sys.ODCICost,
                                     qi       sys.ODCIQueryInfo,
                                     pred     sys.ODCIPredInfo,
                                     args     sys.ODCIArgDescList,
                                     strt     number,
                                     stop     number,
                                     datai    varchar2,
                                     idxenv   sys.ODCIEnv)
         return NUMBER
  is language C name "QMIX_IDX_COST" library XDB.XMLINDEX_LIB
     with context
     parameters (
       context,
       idxinfo, idxinfo INDICATOR struct,
       sel,     sel     INDICATOR,
       cost,    cost    INDICATOR struct,
       qi,      qi      INDICATOR struct,
       pred,    pred    INDICATOR struct,
       args,    args    INDICATOR,
       strt,    strt    INDICATOR, 
       stop,    stop    INDICATOR,
       datai,   datai   INDICATOR,
       idxenv,  idxenv  INDICATOR struct,
       return OCINumber)
);
/
show errors;

create or replace type body xdb.XMLIdxStatsMethods
is 
  static function ODCIGetInterfaces(ilist OUT sys.ODCIObjectList) 
    return number is 
  begin 
    ilist := sys.ODCIObjectList(sys.ODCIObject('SYS','ODCISTATS2'));
    return ODCICONST.SUCCESS;
  end ODCIGetInterfaces;
end;
/
show errors;
grant execute on XDB.XMLIdxStatsMethods to public;


/************************ LOAD TABLE FUNCTION *********/
drop type XDB.XMLIndexTab_t;
create or replace type XDB.XMLIndexLoad_t as object
(
  RID    VARCHAR2(18),
  PID    RAW(8),
  OK     RAW(100),
  LOC    RAW(100),
  VALUE  VARCHAR2(4000),
  VLOB   CLOB
)
/

create or replace type XDB.XMLIndexTab_t as TABLE of XDB.XMLIndexLoad_t
/

create or replace type XDB.XMLIndexLoad_Imp_t authid current_user as object
(
  key RAW(8),      
  static function ODCITableStart(sctx OUT XMLIndexLoad_Imp_t)
                  return PLS_INTEGER
    is
    language C
    library XDB.XMLINDEX_LIB
    name "QMIX_LOADSTART"
    with context
    parameters (
      context,
      sctx,
      sctx INDICATOR STRUCT,
      return INT
    ),

  member function ODCITableFetch(self IN OUT XMLIndexLoad_Imp_t,
                                 nrows IN Number,
                                 xmlrws OUT XDB.XMLIndexTab_t)
                  return PLS_INTEGER
    as language C
    library XDB.XMLINDEX_LIB
    name "QMIX_LOADFETCH"
    with context
    parameters (
      context,
      self,
      self INDICATOR STRUCT,
      nrows,
      xmlrws OCIColl,
      xmlrws INDICATOR sb2,
      xmlrws DURATION OCIDuration,
      return INT
    ),

  member function ODCITableClose(self IN XMLIndexLoad_Imp_t) return PLS_INTEGER
    as language C
    library XDB.XMLINDEX_LIB
    name "QMIX_LOADCLOSE"
    with context
    parameters (
      context,
      self,
      self INDICATOR STRUCT,
      return INT
    )
);
/
create or replace function XDB.XMLIndexLoadFunc
       return XDB.XMLIndexTab_t authid current_user
pipelined using XDB.XMLIndexLoad_Imp_t;
/
show errors;
grant execute on XDB.XMLIndexLoadFunc to public;

/*------------------------------------------------------------------------*/
/*  INDEXTYPE                                                             */
/*------------------------------------------------------------------------*/
create or replace package XDB.XMLIndex_FUNCIMPL authid current_user is
  function getnodes_func(res sys.xmltype,
                           pathstr varchar2, 
                           ia sys.odciindexctx,
                           sctx IN OUT XDB.XMLIndexMethods,
                           sflg number)
  return number;

  function load_func
  return XDB.XMLIndexTab_t
  is language C name "QMIX_LOADFUNC" LIBRARY XDB.XMLINDEX_LIB
     with context parameters (
       context,
       RETURN  INDICATOR sb4,
       RETURN  OCIColl);

  function isattr_func(loc IN RAW)
  return Number
  is language C name "QMIX_ISATTR" LIBRARY XDB.XMLINDEX_LIB
     with context parameters (
       context,
       loc    RAW, 
       loc    INDICATOR sb4,
       loc    LENGTH    sb4,
       RETURN OCINumber);

end XMLIndex_FUNCIMPL;
/
show errors;
grant execute on XDB.XMLIndex_FUNCIMPL to public;

drop operator XDB.xmlindex_getnodes force;
create operator XDB.xmlindex_getnodes binding
  (sys.xmltype, varchar2) return number with index context, 
    scan context XDB.XMLIndexMethods
    without column data using XDB.XMLIndex_FUNCIMPL.getnodes_func;
show errors;
grant execute on XDB.xmlindex_getnodes to public;

drop operator XDB.xmlindex_isattribute force;
create operator XDB.xmlindex_isattribute binding
  (RAW) return NUMBER
    using XDB.XMLIndex_FUNCIMPL.isattr_func;
show errors;
grant execute on XDB.xmlindex_isattribute to public;

create or replace indextype XDB.XMLIndex for
  XDB.xmlindex_getnodes(sys.xmltype, varchar2)
  using XDB.XMLIndexMethods;
-- with array dml;
show errors;

--  using XDB.XMLIndexMethods   without column data;
grant execute on XDB.XMLIndex to public;

associate statistics with indextypes XDB.XMLIndex using XDB.XMLIdxStatsMethods;
/*
associate statistics with packages XDB.XMLIndex_FUNCIMPL using XDB.XMLIdxStatsMethods;
*/

/************ Path suffix table function *********************/
-- create trusted library
CREATE OR REPLACE LIBRARY XDB.XMLTM_LIB TRUSTED AS STATIC;
/
show errors

-- Create the table function output collection and element types

create or replace type XDB.PathidSet_t as varray(2147483647) of RAW(8);
/
grant execute on XDB.PathidSet_t to public;

-- Create the implementation type
-- These trusted C functions are defined in qmtm.c
create or replace package XDB.XMLTM_FUNCIMPL authid current_user is
  function SuffixPathids(pathid IN RAW)
  return XDB.PathidSet_t
  is language C name "QMTM_SUFFIXPATHIDS" 
     LIBRARY XDB.XMLTM_LIB
     with context parameters (
       context,
       pathid  RAW, 
       pathid  INDICATOR sb4,
       pathid  LENGTH sb4,
       RETURN  INDICATOR sb4,
       RETURN  OCIColl);
end XMLTM_FUNCIMPL;
/
show errors;
grant execute on XDB.XMLTM_FUNCIMPL to public;
