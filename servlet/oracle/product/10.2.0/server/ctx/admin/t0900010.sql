Rem
Rem $Header: t0900010.sql 28-jan-2003.15:52:00 wclin Exp $
Rem
Rem t0900010.sql
Rem
Rem Copyright (c) 2000, 2003, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      t0900010.sql - type upgrade
Rem
Rem    DESCRIPTION
Rem      This script upgrades the indextypes from 9.0.1 to 9.2.0
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    wclin       01/28/03 - recompile TextOptStats
Rem    ehuang      01/24/03 - 
Rem    gkaminag    11/26/02 - compilation error
Rem    ehuang      09/27/02 - new alter statements
Rem    ehuang      07/30/02 - 
Rem    gkaminag    05/04/01 - add FORCE to drop operator commands
Rem    gkaminag    04/19/01 - name change to 9.0.1
Rem    wclin       03/09/01 - put in real fix for bug 1629476
Rem    gkaminag    02/27/01 - ctxcat, ctxrule -> ODCI V2
Rem    wclin       02/26/01 - bug 1629476 work around
Rem    gkaminag    01/09/01 - remove sql*plus settings
Rem    gkaminag    01/08/01 - more upgrade
Rem    gkaminag    12/28/00 -
Rem    ehuang      11/02/00 - type upgrade
Rem    ehuang      11/02/00 - Created
Rem

PROMPT ============  ConText 9.0.1 to 9.2.0 Type Upgrade  =====================
PROMPT

PROMPT Revalidate TextOptStats type
PROMPT

alter type TextOptStats compile specification reuse settings;

PROMPT Revalidate indextype and operator
PROMPT

alter type textindexmethods compile specification reuse settings;
alter operator contains compile;
alter indextype context compile;

REM ========================================================================
REM Add binding for SYS.URITYPE
REM ========================================================================

PROMPT Remove existing indextype operator bindings ...
PROMPT

alter indextype context add dummyop(varchar2, varchar2);
alter indextype context drop contains(varchar2, varchar2);
alter indextype context drop contains(clob, varchar2);
alter indextype context drop contains(blob, varchar2);
alter indextype context drop contains(bfile, varchar2);
alter indextype context drop contains(sys.xmltype, varchar2);

PROMPT DisAssociate Statistics 
PROMPT

DISASSOCIATE STATISTICS FROM INDEXTYPES CONTEXT FORCE;
DISASSOCIATE STATISTICS FROM PACKAGES CTX_CONTAINS FORCE;

PROMPT Drop SCORE and CONTAINS operators ...
PROMPT

drop operator score FORCE;
drop operator contains FORCE;
drop package ctx_contains;

PROMPT Run itype to re-create contains, bind operators etc.

@@dr0itype.sql

PROMPT Rebind operators and remove the dummyop
PROMPT

alter indextype context add contains(varchar2, varchar2);
alter indextype context add contains(clob, varchar2);
alter indextype context add contains(blob, varchar2);
alter indextype context add contains(bfile, varchar2);
alter indextype context add contains(sys.xmltype, varchar2);
alter indextype context add contains(sys.uritype, varchar2);
alter indextype context drop dummyop(varchar2, varchar2);

REM ========================================================================
REM creating ctxxpath index type
REM ========================================================================

@@dr0typex.pkh
create or replace type body XPathIndexMethods is
static function ODCIGetInterfaces(ifclist out    sys.ODCIObjectList) 
return number is begin
  ifclist := sys.ODCIObjectList(sys.ODCIObject('SYS','ODCIINDEX2')); 
  return sys.ODCIConst.Success; 
end ODCIGetInterfaces; 
static function ODCIIndexCreate(ia in sys.odciindexinfo, parms in varchar2,
env in sys.ODCIEnv) return number 
is begin return sys.ODCIConst.Success; end ODCIIndexCreate;
static function ODCIIndexAlter(ia in sys.odciindexinfo, parms in out varchar2,
altopt in number, env in sys.ODCIEnv) return number 
is begin  return sys.ODCIConst.Success; end ODCIIndexAlter;
static function ODCIIndexTruncate(ia in sys.odciindexinfo, env in sys.ODCIEnv
) return number is begin  return sys.odciconst.success; end ODCIIndexTruncate;
static function ODCIIndexDrop(ia in sys.odciindexinfo, env in sys.ODCIEnv
) return number is begin  return sys.odciconst.success; end ODCIIndexDrop;
static function ODCIIndexInsert(ia sys.odciindexinfo, ridlist sys.odciridlist, 
env sys.odcienv) return number
is begin  return sys.odciconst.success; end ODCIIndexInsert;
static function ODCIIndexDelete(ia sys.odciindexinfo, ridlist sys.odciridlist, 
env sys.ODCIEnv) return number
is begin  return sys.odciconst.success; end ODCIIndexDelete;
static function ODCIIndexUpdate(ia sys.odciindexinfo, ridlist sys.odciridlist, 
env sys.ODCIEnv) return number
is begin  return sys.odciconst.success; end ODCIIndexUpdate;
static function ODCIIndexGetMetaData(ia in sys.odciindexinfo, 
version in varchar2, new_block out PLS_INTEGER, env in sys.ODCIEnv
) return varchar2 is begin  return null; end ODCIIndexGetMetaData;
static function ODCIIndexUtilGetTableNames(ia IN sys.odciindexinfo,
read_only IN PLS_INTEGER, version IN varchar2, context OUT PLS_INTEGER)
return boolean is begin  return null;  end ODCIIndexUtilGetTableNames;
static procedure ODCIIndexUtilCleanup(context IN PLS_INTEGER)
is begin  null; end ODCIIndexUtilCleanup;
static function ODCIIndexSplitPartition(ia IN SYS.ODCIIndexInfo, 
part_name1 IN SYS.ODCIPartInfo, part_name2 IN SYS.ODCIPartInfo,
parms IN varchar2, env IN SYS.ODCIEnv) return number
is begin  return sys.odciconst.success; end ODCIIndexSplitPartition;
static function ODCIIndexMergePartition(ia IN SYS.ODCIIndexInfo,
part_name1 IN SYS.ODCIPartInfo, part_name2 IN SYS.ODCIPartInfo,
parms IN varchar2, env IN SYS.ODCIEnv) return number
is begin  return sys.odciconst.success; end ODCIIndexMergePartition;
static function ODCIIndexExchangePartition(ia IN SYS.ODCIIndexInfo,
ia1 IN SYS.ODCIIndexInfo,env IN SYS.ODCIEnv) return number
is begin  return sys.odciconst.success; end ODCIIndexExchangePartition;
end;
/
show errors
@@dr0itypx.sql
