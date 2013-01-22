Rem
Rem $Header: u0900010.sql 24-jan-2003.12:11:53 ehuang Exp $
Rem
Rem u0900010.sql
Rem
Rem Copyright (c) 2000, 2003, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      u0900010.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      This script upgrades an 9.0.1.X ctxsys data dictionary to 9.2.0.1.  
Rem      This script should be run as ctxsys on an 9.0.1 ctxsys schema
Rem      (or as SYS with ALTER SESSION SET SCHEMA = CTXSYS)
Rem      No other users or schema versions are supported.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ehuang      01/24/03 - 
Rem    gkaminag    11/26/02 - increase size of version string
Rem    ehuang      10/10/02 - call current directory
Rem    ehuang      06/12/02 - add registry.
Rem    gkaminag    02/19/02 - bug 2232407.
Rem    mfaisal     02/03/02 - inso_filter timeout_type
Rem    daliao      01/31/02 - add classification update
Rem    gkaminag    01/17/02 - update
Rem    gkaminag    01/08/02 - call dbms_registry.valid.
Rem    yucheng     01/11/02 - create online pending table
Rem    gkaminag    12/17/01 - bug 2154029.
Rem    gkaminag    12/05/01 - change name in upgrading....
Rem    salpha      11/20/01 - need to change default theme lexer for ctxcat
Rem    gkaminag    11/20/01 - policy name to default_policy_oracontains.
Rem    mfaisal     10/24/01 - user-defined lexer
Rem    gshank      10/22/01 - Stem Indexing
Rem    gkaminag    10/23/01 - policy.
Rem    wclin       09/25/01 - ctxxpath
Rem    gkaminag    10/08/01 - component registry.
Rem    ehuang      09/29/01 - URITypeIndexing.
Rem    gkaminag    08/08/01 - creation

REM ========================================================================
REM all existing ctxcat index created with default/theme lexer, need to set
REM index_themes=no
REM ========================================================================

update dr$index_value
  set ixv_value = '0'
where (ixv_oat_id = 60113
       or ixv_sub_oat_id=60113)
  and ixv_idx_id in
      (select idx_id from
         dr$index
         where idx_type=1);   

REM ========================================================================
REM  dr$unindexed
REM ========================================================================

PROMPT ... creating table dr$unindexed

create table dr$unindexed (
  unx_idx_id    number,
  unx_ixp_id    number,
  unx_rowid     rowid,
  constraint drc$unx_key primary key (unx_idx_id, unx_ixp_id, unx_rowid)
)
organization index;

REM ========================================================================
REM dr$pending
REM ========================================================================

alter table dr$pending add (pnd_lock_failed char(1));
update dr$pending set pnd_lock_failed = 'N';
commit;

REM ========================================================================
REM new view definitions
REM ========================================================================

create or replace view ctx_section_groups as
select
   u.name      sgp_owner,
   sgp_name,
   obj_name    sgp_type
from dr$section_group, dr$object, dr$class, sys.user$ u
where sgp_obj_id = obj_id
  and obj_system = 'N'
  and obj_cla_id = cla_id
  and cla_name = 'SECTION_GROUP'
  and sgp_owner# = u.user#
/

create or replace view ctx_user_section_groups as
select
   sgp_name,
   obj_name    sgp_type
from dr$section_group, dr$object, dr$class
where sgp_obj_id = obj_id
  and obj_system = 'N'
  and obj_cla_id = cla_id
  and cla_name = 'SECTION_GROUP'
  and sgp_owner# = userenv('SCHEMAID')
/

REM ========================================================================
REM BASIC LEXER - INDEX STEM
REM ========================================================================

delete from dr$object_attribute where oat_id = 60120;
delete from dr$object_attribute_lov where oal_oat_id = 60120;

insert into dr$object_attribute values
  (60120, 6, 1, 20, 
   'INDEX_STEMS', 'Language for indexing stemmer',
   'N', 'N', 'Y', 'I', 
   'NONE', null, null, 'Y');

insert into dr$object_attribute_lov values
  (60120, 'NONE', 0, 'Do not index stems');

insert into dr$object_attribute_lov values
  (60120, 'ENGLISH', 1, 'English (inflectional)');

insert into dr$object_attribute_lov values
  (60120, 'DERIVATIONAL', 2, 'English (derivational)');

insert into dr$object_attribute_lov values
  (60120, 'DUTCH', 3, 'Dutch');

insert into dr$object_attribute_lov values
  (60120, 'FRENCH', 4, 'French');

insert into dr$object_attribute_lov values
  (60120, 'GERMAN', 5, 'German');

insert into dr$object_attribute_lov values
  (60120, 'ITALIAN', 6, 'Italian');

insert into dr$object_attribute_lov values
  (60120, 'SPANISH', 7, 'Spanish');

commit;

REM ========================================================================
REM USER LEXER
REM ========================================================================

delete from dr$object where obj_cla_id = 6 and obj_id = 10;
delete from dr$object_attribute where oat_id = 61001;
delete from dr$object_attribute where oat_id = 61002;
delete from dr$object_attribute_lov where oal_oat_id = 61002;
delete from dr$object_attribute where oat_id = 61003;

insert into dr$object values
  (6, 10, 'USER_LEXER', 'user-defined lexer', 'N');

insert into dr$object_attribute values
  (61001, 6, 10, 1, 
   'INDEX_PROCEDURE', 'name of the indexing stored procedure',
   'Y', 'N', 'Y', 'S', 
   'REQUIRED', null, null, 'N');

insert into dr$object_attribute values
  (61002, 6, 10, 2, 
   'INPUT_TYPE', 'datatype of the input arguments of indexing stored procedure',
   'N', 'N', 'Y', 'I', 
   'CLOB', null, null, 'Y');

insert into dr$object_attribute_lov values
  (61002, 'CLOB', 1, 'CLOB');

insert into dr$object_attribute_lov values
  (61002, 'VARCHAR2', 2, 'VARCHAR2');

insert into dr$object_attribute values
  (61003, 6, 10, 3, 
   'QUERY_PROCEDURE', 'name of the query stored procedure',
   'Y', 'N', 'Y', 'S', 
   'REQUIRED', null, null, 'N');

commit;

REM ========================================================================
REM NULL LEXER
REM ========================================================================

delete from dr$object where obj_cla_id = 6 and obj_id = 9;
delete from dr$preference where pre_cla_id = 6 and pre_obj_id = 9;

insert into dr$object values
  (6, 9, 'NULL_LEXER', 'special lexer for use in ctxxpath indexes only', 'Y');

begin
  dr$temp_crepref('NULL_LEXER','NULL_LEXER');
end;
/

REM ========================================================================
REM CTXXPATH_SECTION_GROUP
REM ========================================================================

delete from dr$object where obj_cla_id = 5 and obj_id = 9;
delete from dr$section_group where sgp_obj_id = 9;
delete from dr$parameter where par_name = 'DEFAULT_CTXXPATH_STORAGE';

insert into dr$object values
  (5, 9, 'CTXXPATH_SECTION_GROUP', 
'special section group for ctxxpath indexes only', 'Y');

begin
  dr$temp_cresg('CTXXPATH_SECTION_GROUP','CTXXPATH_SECTION_GROUP');
end;
/

insert into dr$parameter (par_name, par_value)
values ('DEFAULT_CTXXPATH_STORAGE',     'CTXSYS.DEFAULT_STORAGE');

commit;

REM ========================================================================
REM BASIC_WORDLIST preference
REM ========================================================================

begin
  dr$temp_crepref('BASIC_WORDLIST','BASIC_WORDLIST');
end;
/

REM ========================================================================
REM URITYPE DATATYPE
REM ========================================================================

delete from dr$object where obj_cla_id = 2 and obj_id = 6;
delete from dr$preference where pre_cla_id = 2 and pre_obj_id = 6;

insert into dr$object values
  (2, 6, 'URITYPE_DATATYPE', '', 'Y');

begin
  dr$temp_crepref('URITYPE_DATATYPE','URITYPE_DATATYPE');
end;
/

REM ========================================================================
REM INSO FILTER
REM ========================================================================

delete from dr$object_attribute where oat_id = 40503;
delete from dr$object_attribute_lov where oal_oat_id = 40503;

insert into dr$object_attribute values
  (40503, 4, 5, 3, 
   'TIMEOUT_TYPE', 'Time-out type',
   'N', 'N', 'Y', 'I', 
   'HEURISTIC', null, null, 'Y');

insert into dr$object_attribute_lov values
  (40503, 'HEURISTIC', 1, 'Heuristic');

insert into dr$object_attribute_lov values
  (40503, 'FIXED', 2, 'Fixed');

commit;

REM ========================================================================
REM DR$POLICY_TAB
REM ========================================================================

CREATE TABLE dr$policy_tab
(
 plt_policy               CHAR(1),
 plt_langcol              CHAR(1)
);

GRANT select ON dr$policy_tab to public;

commit;

REM ========================================================================
REM dr$online_pending
REM ========================================================================

create table dr$online_pending (
  onl_cid             number not null,
  onl_rowid           varchar(18) not null,
  onl_indexpartition  varchar(30) default null,
  primary key (onl_cid, onl_rowid)
)
organization index
storage (freelists 10);


REM ========================================================================
REM CTX_VERSION
REM ========================================================================

create or replace function dri_version return varchar2
is begin return '0.0.0.0.0'; end;
/

CREATE OR REPLACE VIEW ctx_version AS
select '9.2.0.0.0' ver_dict, 
substr(dri_version,1,10) ver_code from dual;

REM ========================================================================
REM classification
REM ========================================================================

insert into dr$class values
  (99, 'CLASSIFIER', 'classification preferences', 'N');

insert into dr$object values
  (99, 1, 'RULE_CLASSIFIER', 'rule based classifier', 'N');

insert into dr$object_attribute values
  (990101, 99, 1, 1, 
   'THRESHOLD', 'Minimum confidence level (in percentage) for rule generation for all classes',
   'N', 'N', 'Y', 'I', 
   '50', 1, 100, 'N');

insert into dr$object_attribute values
  (990102, 99, 1, 2, 
   'MAX_TERMS', 'Maximum number of terms in one class',
   'N', 'N', 'Y', 'I', 
   '100', 20, 2000, 'N');

insert into dr$object_attribute values
  (990103, 99, 1, 3, 
   'MEMORY_SIZE', 'Typical memory size in MB',
   'N', 'N', 'Y', 'I', 
   '500', 10, 2000000, 'N');

insert into dr$object_attribute values
  (990104, 99, 1, 4, 
   'NT_THRESHOLD', 'minimum term occurring frequency (in the fraction of total number of do cuments)',
   'N', 'N', 'Y', 'F', 
   '0.001', 0, 0.90, 'N');

insert into dr$object_attribute values
  (990105, 99, 1, 5, 
   'TERM_THRESHOLD', 'Threshold value (in percentage) for term selection in one class',
   'N', 'N', 'Y', 'I', 
   '10', 0, 100, 'N');

insert into dr$object_attribute values
  (990106, 99, 1, 6, 
   'TREENUM', 'Number of trees built for one class',
   'N', 'N', 'Y', 'I', 
   '1', 1, 10, 'N');

begin
  dr$temp_crepref('DEFAULT_CLASSIFIER','RULE_CLASSIFIER');
end;
/
insert into dr$parameter (par_name, par_value)
         values ('DEFAULT_CLASSIFIER',     'CTXSYS.DEFAULT_CLASSIFIER');
commit;

REM ========================================================================
REM default policy
REM ========================================================================

REM MOVED TO CTXU817, CTXU901
