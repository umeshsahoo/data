Rem
Rem $Header: t0801070.sql 11-mar-2003.16:09:22 daliao Exp $
Rem
Rem t0801070.sql
Rem
Rem Copyright (c) 2002, 2003, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      t0801070.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      This script upgrades the indextypes from 8.1.7 to 9.0.1
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    daliao      02/28/03 - ctxrule change
Rem    ehuang      01/24/03 - 
Rem    gkaminag    12/23/02 - typo
Rem    gkaminag    11/26/02 - 
Rem    gkaminag    11/06/02 - workaround pre-compile indextype
Rem    ehuang      09/27/02 - add alter statements
Rem    ehuang      08/02/02 - ehuang_component_upgrade_2
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


PROMPT ==============  ConText 8.1 to 9.0 Type Upgrade  =====================
PROMPT

PROMPT Revalidate indextype and operator
PROMPT

alter type textindexmethods compile specification reuse settings;
alter operator contains compile;
alter indextype context compile;

PROMPT Remove existing indextype operator bindings ...
PROMPT

alter indextype context add dummyop(varchar2, varchar2);
alter indextype context drop contains(varchar2, varchar2);
alter indextype context drop contains(clob, varchar2);
alter indextype context drop contains(blob, varchar2);
alter indextype context drop contains(bfile, varchar2);

PROMPT Drop SCORE and CONTAINS operators ...
PROMPT

drop operator score FORCE;
drop operator contains FORCE;
drop package ctx_contains;
DISASSOCIATE STATISTICS FROM INDEXTYPES CONTEXT FORCE;

PROMPT Shift indextype implementation to dummy implementation type ...
PROMPT

alter indextype context using DummyIndexMethods;

PROMPT Create new 9.0 version of TextIndexMethods ...
PROMPT

drop type TextIndexMethods;
@@dr0type.pkh

REM create a dummy type body.  We can't run dr0type.plb here because the
REM packages may not be instantiated.  (Packages cannot be instantiated
REM before this, because they depend on type .pkh's)

create or replace type body TextIndexMethods is
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

PROMPT Shift indextype implementation to TextIndexMethods ...
PROMPT

alter indextype context using TextIndexMethods with local range partition;

PROMPT Run itype to re-create contains, bind operators etc.

@@dr0itype.sql

PROMPT Rebind operators and remove the dummyop
PROMPT

alter indextype context add contains(varchar2, varchar2);
alter indextype context add contains(clob, varchar2);
alter indextype context add contains(blob, varchar2);
alter indextype context add contains(bfile, varchar2);
alter indextype context add contains(sys.xmltype, varchar2);
alter indextype context drop dummyop(varchar2, varchar2);

PROMPT ========================================================================
PROMPT CTXCAT 8.1 to 9.0 Type Upgrade
PROMPT ========================================================================

alter type catindexmethods compile specification reuse settings;
alter operator catsearch compile;
alter indextype ctxcat compile;

PROMPT Remove existing ctxcat operator bindings ...
PROMPT

alter indextype ctxcat add dummyop(varchar2, varchar2);
alter indextype ctxcat drop catsearch(varchar2, varchar2, varchar2);
alter indextype ctxcat drop catsearch(clob, varchar2, varchar2);

PROMPT Drop CATSEARCH operators ...
PROMPT

drop operator catsearch FORCE;
drop package ctx_catsearch;

PROMPT Shift indextype implementation to dummy implementation type ...
PROMPT

alter indextype ctxcat using DummyIndexMethods;

PROMPT Create new 9.0 version of CatIndexMethods ...
PROMPT

drop type CatIndexMethods;
@@dr0typec.pkh

REM create a dummy type body.  We can't run dr0typec.plb here because the
REM packages may not be instantiated.  (Packages cannot be instantiated
REM before this, because they depend on type .pkh's)

create or replace type body CatIndexMethods is
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

PROMPT Shift indextype implementation to CatIndexMethods ...
PROMPT

alter indextype ctxcat using CatIndexMethods;

PROMPT Re-bind operators to indextype  ...
PROMPT

@@dr0itypc.sql

alter indextype ctxcat add catsearch(varchar2, varchar2, varchar2);
alter indextype ctxcat add catsearch(clob, varchar2, varchar2);
alter indextype ctxcat drop dummyop(varchar2, varchar2);

alter package ctx_catsearch compile;
alter operator catsearch compile;
alter indextype ctxcat compile;

REM ========================================================================
REM CTXRULE
REM ========================================================================

@@dr0typer.pkh
create or replace type body RuleIndexMethods is
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
@@dr0itypr.sql

REM  these two bindings of matches are not support for version 9
alter indextype ctxrule drop matches(blob, varchar2);
alter indextype ctxrule drop matches(blob, clob);

REM match_score operator is not supported for version 9
drop operator match_score FORCE;
drop package driscorr;
alter indextype ctxrule compile;
