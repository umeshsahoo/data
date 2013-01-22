Rem u0801070.sql
Rem
Rem Copyright (c) 1999, 2003, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      u0801070.sql - upgrade ctxsys schema from 8.1.6.0 to 8.1.7.0
Rem
Rem    DESCRIPTION
Rem      This script upgrades an 8.1.7.0 ctxsys data dictionary to 9.0.1.0.  
Rem      This script should be run as ctxsys on an 8.1.7 ctxsys schema
Rem      (or as SYS with ALTER SESSION SET SCHEMA = CTXSYS)
Rem      No other users or schema versions are supported.
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ehuang      01/24/03 - 
Rem    gkaminag    11/26/02 - increase size of version string
Rem    ehuang      10/10/02 - call current directory
Rem    ehuang      07/30/02 - upgrade script restructuring
Rem    ehuang      06/12/02 - add registry.
Rem    gkaminag    02/19/02 - bug 2232418.
Rem    gkaminag    01/25/02 - no need to run dr0plb.sql now
Rem    gkaminag    05/04/01 - bug 1761162
Rem    gkaminag    04/19/01 - name change to 9.0.1
Rem    gkaminag    04/13/01 - CTXRULE pasystem parameters
Rem    gkaminag    04/10/01 - add partition information into pending
Rem    gkaminag    04/09/01 - protect possible ORA-1 errors
Rem    gkaminag    03/27/01 - add call to dr0ulib
Rem    gkaminag    03/26/01 - remove ctx_ddl references
Rem    gkaminag    03/16/01 -
Rem    yucheng     03/15/01 - transport upgrade fix
Rem    gkaminag    03/15/01 - bug 1684284
Rem    yucheng     03/14/01 - drop temp table
Rem    yucheng     03/13/01 - making association between index and secondary ob
Rem    mfaisal     03/08/01 - inso filter time-out
Rem    ehuang      02/21/01 - CLOB_LOC, BLOB_LOC user datastore output types
Rem    gkaminag    01/08/01 - more upgrade
Rem    gkaminag    12/22/00 - refine
Rem    wclin       12/12/00 - add dr$part_stats table
Rem    gshank      12/08/00 - Bug 1424693 Add BASE_LETTER_TYPE
Rem    ehuang      11/10/00 - version to 9.0
Rem    tsuzuki     10/19/00 - Add new Japanese lexer
Rem    salpha      10/12/00 - add lexer attribute prove_themes
Rem    gkaminag    09/20/00 - use path section group by default for xmltyp
Rem    kangjs      08/22/00 - korean morph lexer attribute changes
Rem    gkaminag    08/28/00 -
Rem    gkaminag    08/14/00 - partition support
Rem    gkaminag    08/14/00 - partitioning support
Rem    gkaminag    08/10/00 - partitioning support
Rem    gkaminag    08/02/00 - korean morph lexer
Rem    gkaminag    07/24/00 - auto_xml_section_group->path_section_group
Rem    ehuang      06/16/00 - XMLType support
Rem    gkaminag    06/22/00 - auto xml sectioner
Rem    ehuang      05/30/00 - 8.2 upgrade script
Rem    ehuang      05/30/00 - Created
Rem

REM ========================================================================
REM XMLType
REM ========================================================================

insert into dr$object values
  (2, 5, 'XMLTYPE_DATATYPE', '', 'Y');

insert into dr$parameter (par_name, par_value)
values ('DEFAULT_SECTION_XML',          'CTXSYS.PATH_SECTION_GROUP');

exec dr$temp_crepref('XMLTYPE_DATATYPE', 'XMLTYPE_DATATYPE');

REM ========================================================================
REM auto XML sectioner
REM ========================================================================

insert into dr$object values
  (5, 8, 'PATH_SECTION_GROUP', 'path section group', 'N');

exec dr$temp_cresg('PATH_SECTION_GROUP', 'PATH_SECTION_GROUP');

REM ========================================================================
REM New attributes for Basic Lexer
REM ========================================================================
insert into dr$object_attribute values
  (60118, 6, 1, 18, 
   'PROVE_THEMES', 'Prove themes during theme indexing',
   'N', 'N', 'Y', 'B', 
   'TRUE', null, null, 'N');

begin
insert into dr$object_attribute values
  (60119, 6, 1, 19,
   'BASE_LETTER_TYPE', 'Type of base_letter',
   'N', 'N', 'Y', 'I',
   'GENERIC', null, null, 'Y');

insert into dr$object_attribute_lov values
  (60119, 'GENERIC', 0, 'Works in all languages');

insert into dr$object_attribute_lov values
  (60119, 'SPECIFIC', 1, 'NLS_LANG specific');
exception
when dup_val_on_index then
null;
end;
/

commit;

REM ========================================================================
REM Korean Morphological Lexer
REM ========================================================================

insert into dr$object values
  (6, 7, 'KOREAN_MORPH_LEXER', 'Korean Morphological lexer', 'N');

insert into dr$object_attribute values
  (60701, 6, 7, 1, 
   'VERB_ADJECTIVE', 'index verbs and adjectives',
   'N', 'N', 'Y', 'B', 
   'FALSE', null, null, 'N');

insert into dr$object_attribute values
  (60702, 6, 7, 2, 
   'ONE_CHAR_WORD', 'index single characters',
   'N', 'N', 'Y', 'B', 
   'FALSE', null, null, 'N');

insert into dr$object_attribute values
  (60703, 6, 7, 3, 
   'NUMBER', 'index numbers',
   'N', 'N', 'Y', 'B', 
   'FALSE', null, null, 'N');

insert into dr$object_attribute values
  (60704, 6, 7, 4, 
   'USER_DIC', 'index words in user dictionary',
   'N', 'N', 'Y', 'B', 
   'TRUE', null, null, 'N');

insert into dr$object_attribute values
  (60705, 6, 7, 5, 
   'STOP_DIC', 'index words in x-user dictionary',
   'N', 'N', 'Y', 'B', 
   'TRUE', null, null, 'N');

insert into dr$object_attribute values
  (60706, 6, 7, 6, 
   'MORPHEME', 'perform morphological analysis',
   'N', 'N', 'Y', 'B', 
   'TRUE', null, null, 'N');

insert into dr$object_attribute values
  (60707, 6, 7, 7, 
   'COMPOSITE', 'define indexing style of composite nouns',
   'N', 'N', 'Y', 'I', 
   'COMPONENT_WORD', null, null, 'Y');

insert into dr$object_attribute_lov values
  (60707, 'COMPOSITE_ONLY', 0, 'index only composite nouns');

insert into dr$object_attribute_lov values
  (60707, 'COMPONENT_WORD', 1, 'index single nouns');

insert into dr$object_attribute_lov values
  (60707, 'NGRAM', 2, 'use n-gram indexing style');

insert into dr$object_attribute values
  (60708, 6, 7, 8, 
   'TO_UPPER', 'convert english words to uppercase',
   'N', 'N', 'Y', 'B', 
   'TRUE', null, null, 'N');

insert into dr$object_attribute values
  (60709, 6, 7, 9, 
   'HANJA', 'index hanja itself without converting to hangeul',
   'N', 'N', 'Y', 'B', 
   'FALSE', null, null, 'N');

insert into dr$object_attribute values
  (60710, 6, 7, 10, 
   'LONG_WORD', 'index words with original length greater than 16',
   'N', 'N', 'Y', 'B', 
   'FALSE', null, null, 'N');

insert into dr$object_attribute values
  (60711, 6, 7, 11, 
   'JAPANESE', 'index japanese character in current character set.',
   'N', 'N', 'Y', 'B', 
   'FALSE', null, null, 'N');

insert into dr$object_attribute values
  (60712, 6, 7, 12, 
   'ENGLISH', 'index alphanumeric string that starts with alphabet',
   'N', 'N', 'Y', 'B', 
   'TRUE', null, null, 'N');

commit;

REM ========================================================================
REM Japanese (Lexical) Lexer
REM ========================================================================

insert into dr$object values
  (6, 8, 'JAPANESE_LEXER', 'Japanese lexer', 'N');

commit;

REM ========================================================================
REM New attribute for Inso Filter 
REM ========================================================================

begin
insert into dr$object_attribute values
  (40502, 4, 5, 2, 
   'TIMEOUT', 'Polling interval in seconds to terminate by force',
   'N', 'N', 'Y', 'I', 
   '120', 0, 42949672, 'N');
exception
when dup_val_on_index then
null;
end;
/
commit;

REM ========================================================================
REM Index Sub Lexer Views
REM ========================================================================

CREATE or replace function dri_sublxv_lang(value in varchar2)
return varchar2 
is
begin
  return null;
end dri_sublxv_lang;
/

CREATE or replace view ctx_index_sub_lexers as
select /*+ ORDERED */
       u.name    isl_index_owner,
       idx_name  isl_index_name,
       substr(dri_sublxv_lang(ixv_value),1,30) isl_language,
       substr(substr(ixv_value,instr(ixv_value,':',-1)+1),1,30) isl_alt_value,
       substr(substr(ixv_value,instr(ixv_value,':')+1,
                     instr(ixv_value, ':', -1) - instr(ixv_value,':') - 1),
              1,30) isl_object
from dr$index, 
     sys.user$ u,
     dr$index_value
where ixv_oat_id = 60601
  and idx_id     = ixv_idx_id
  and idx_owner# = u.user#
/

CREATE or replace view ctx_user_index_sub_lexers as
select /*+ ORDERED */
       idx_name  isl_index_name,
       substr(dri_sublxv_lang(ixv_value),1,30) isl_language,
       substr(substr(ixv_value,instr(ixv_value,':',-1)+1),1,30) isl_alt_value,
       substr(substr(ixv_value,instr(ixv_value,':')+1,
                     instr(ixv_value, ':', -1) - instr(ixv_value,':') - 1),
              1,30) isl_object
from dr$index, 
     dr$index_value
where ixv_oat_id = 60601
  and idx_id     = ixv_idx_id
  and idx_owner# = userenv('SCHEMAID')
/

CREATE OR REPLACE PUBLIC SYNONYM ctx_user_index_sub_lexers FOR
  ctxsys.ctx_user_index_sub_lexers;

GRANT select ON ctx_user_index_sub_lexers to public;

create or replace view ctx_index_sub_lexer_values as
select /*+ ORDERED */
       u.name    isv_index_owner,
       idx_name  isv_index_name,
       substr(dri_sublxv_lang(iv2.ixv_value),1,30) isv_language,
       obj_name  isv_object,
       oat_name  isv_attribute,
       decode(oat_datatype, 'B', decode(iv1.ixv_value, 1, 'YES', 'NO'),
         nvl(oal_label, iv1.ixv_value)) isv_value
from dr$index, 
     sys.user$ u,
     dr$index_value iv1,
     dr$index_value iv2,
     dr$object_attribute,
     dr$object, 
     dr$object_attribute_lov
where iv1.ixv_value = nvl(oal_value, iv1.ixv_value)
  and oat_id = oal_oat_id (+)
  and oat_system = 'N'
  and oat_cla_id = obj_cla_id
  and oat_obj_id = obj_id
  and iv1.ixv_sub_oat_id = oat_id
  and iv2.ixv_oat_id = 60601
  and iv1.ixv_sub_group = iv2.ixv_sub_group
  and iv1.ixv_idx_id = iv2.ixv_idx_id
  and iv1.ixv_oat_id = 60602
  and idx_id     = iv1.ixv_idx_id
  and idx_owner# = u.user#
/

create or replace view ctx_user_index_sub_lexer_vals as
select /*+ ORDERED */
       idx_name  isv_index_name,
       substr(dri_sublxv_lang(iv2.ixv_value),1,30) isv_language,
       obj_name  isv_object,
       oat_name  isv_attribute,
       decode(oat_datatype, 'B', decode(iv1.ixv_value, 1, 'YES', 'NO'),
         nvl(oal_label, iv1.ixv_value)) isv_value
from dr$index, 
     dr$index_value iv1,
     dr$index_value iv2,
     dr$object_attribute,
     dr$object, 
     dr$object_attribute_lov
where iv1.ixv_value = nvl(oal_value, iv1.ixv_value)
  and oat_id = oal_oat_id (+)
  and oat_system = 'N'
  and oat_cla_id = obj_cla_id
  and oat_obj_id = obj_id
  and iv1.ixv_sub_oat_id = oat_id
  and iv2.ixv_oat_id = 60601
  and iv1.ixv_sub_group = iv2.ixv_sub_group
  and iv1.ixv_idx_id = iv2.ixv_idx_id
  and iv1.ixv_oat_id = 60602
  and idx_id     = iv1.ixv_idx_id
  and idx_owner# = userenv('SCHEMAID')
/

CREATE OR REPLACE PUBLIC SYNONYM ctx_user_index_sub_lexer_vals FOR
  ctxsys.ctx_user_index_sub_lexer_vals;

GRANT select ON ctx_user_index_sub_lexer_vals to public;

REM ========================================================================
REM Partitioning Support
REM ========================================================================

alter table dr$index add (idx_option VARCHAR2(40));

alter view ctx_indexes compile;
alter view ctx_user_indexes compile;

CREATE TABLE dr$index_partition
(
  ixp_id                   NUMBER(38,0)  NOT  NULL,
  ixp_name                 VARCHAR2(30)  NOT  NULL,
  ixp_idx_id               NUMBER(38,0)  NOT  NULL,
  ixp_table_partition#     NUMBER(38,0)  NOT  NULL,
  ixp_docid_count          NUMBER(38,0)  DEFAULT 0,
  ixp_status               VARCHAR2(12)  NOT NULL,
  ixp_nextid               NUMBER(38,0),
  ixp_opt_token            VARCHAR2(64),
  ixp_opt_type             NUMBER(38,0),
  ixp_opt_count            NUMBER(38,0),
 CONSTRAINT drc$ixp_key    PRIMARY KEY (ixp_idx_id, ixp_id)
);

create unique index drx$ixp_name 
on dr$index_partition(ixp_idx_id, ixp_name);

create or replace view ctx_index_partitions as
select
  ixp_id
 ,u1.name                ixp_index_owner
 ,idx_name               ixp_index_name
 ,ixp_name               ixp_index_partition_name
 ,u2.name                ixp_table_owner
 ,o1.name                ixp_table_name
 ,o2.subname             ixp_table_partition_name 
 ,ixp_docid_count        ixp_docid_count
 ,ixp_status             ixp_status
 from dr$index_partition, dr$index, sys.user$ u1, sys.user$ u2, 
      sys.obj$ o1, sys.obj$ o2
where idx_owner# = u1.user#
  and idx_table_owner# = u2.user#
  and ixp_table_partition# = o2.obj#
  and idx_table# = o1.obj#
  and ixp_idx_id = idx_id
/

create or replace view ctx_user_index_partitions as
select
  ixp_id
 ,idx_name               ixp_index_name
 ,ixp_name               ixp_index_partition_name
 ,u2.name                ixp_table_owner
 ,o1.name                ixp_table_name
 ,o2.subname             ixp_table_partition_name 
 ,ixp_docid_count        ixp_docid_count
 ,ixp_status             ixp_status
 from dr$index_partition, dr$index, sys.user$ u2, 
      sys.obj$ o1, sys.obj$ o2
where idx_owner# = userenv('SCHEMAID')
  and idx_table_owner# = u2.user#
  and ixp_table_partition# = o2.obj#
  and idx_table# = o1.obj#
  and ixp_idx_id = idx_id
/


create or replace public synonym ctx_user_index_partitions 
for ctxsys.ctx_user_index_partitions;
grant select on ctx_user_index_partitions to public;

begin
  execute immediate 
    'create table dr$pending_backup as '||
    'select p.*, 0 pnd_pid from dr$pending p';
  execute immediate
    'drop table dr$pending';
  execute immediate
    'create table dr$pending ( '||
    'pnd_cid       number  NOT NULL, '||
    'pnd_pid       number  default 0 NOT NULL, '||
    'pnd_rowid     rowid   NOT NULL, '||
    'pnd_timestamp date, '||
    'primary key (pnd_cid, pnd_pid, pnd_rowid) '||
    ') '||
    'organization index '||
    'storage (freelists 10) ';
  execute immediate
    'insert into dr$pending '||
    'select pnd_cid, pnd_pid, pnd_rowid, pnd_timestamp '||
    'from dr$pending_backup';
  execute immediate
    'drop table dr$pending_backup';
end;
/

alter table dr$waiting add (wtg_pid number default 0);

CREATE OR REPLACE VIEW ctx_pending AS
select /*+ ORDERED USE_NL(i p) */
       u.name      pnd_index_owner,
       idx_name    pnd_index_name,
       ixp_name    pnd_partition_name,
       pnd_rowid,
       pnd_timestamp
  from dr$pending, dr$index i, dr$index_partition p, sys.user$ u
 where idx_owner# = u.user#
   and idx_id = ixp_idx_id
   and pnd_pid = ixp_id
   and pnd_pid != 0
   and pnd_cid = idx_id
UNION ALL
select /*+ ORDERED USE_NL(i) */
       u.name      pnd_index_owner,
       idx_name    pnd_index_name,
       null        pnd_partition_name,
       pnd_rowid,
       pnd_timestamp
  from dr$pending, dr$index i, sys.user$ u
 where idx_owner# = u.user#
   and pnd_pid = 0
   and pnd_cid = idx_id
/

CREATE OR REPLACE VIEW ctx_user_pending AS
select /*+ ORDERED USE_NL(i p)*/ 
       idx_name  pnd_index_name,
       ixp_name  pnd_partition_name,
       pnd_rowid,
       pnd_timestamp
  from dr$pending, dr$index i, dr$index_partition p
 where idx_id = ixp_idx_id
   and pnd_pid = ixp_id
   and pnd_cid != 0
   and pnd_cid = idx_id
   and idx_owner# = userenv('SCHEMAID')
UNION ALL
select /*+ ORDERED USE_NL(i) */ 
       idx_name  pnd_index_name,
       null      pnd_partition_name,
       pnd_rowid,
       pnd_timestamp
  from dr$pending, dr$index i
 where pnd_pid = 0
   and pnd_cid = idx_id
   and idx_owner# = userenv('SCHEMAID')
/

grant select on CTX_USER_PENDING to PUBLIC;

insert into dr$object_attribute values
  (90108, 9, 1, 8, 
   'PART_SUB_STORAGE_ATTR', '',
   'N', 'Y', 'Y', 'S', 
   'NONE', null, 500, 'N');

drop table dr$delete;
create table dr$delete (
  del_idx_id    number,
  del_ixp_id    number,
  del_docid     number,
  constraint drc$del_key primary key (del_idx_id, del_ixp_id, del_docid)
)
organization index;

create or replace procedure syncrn (
  idxid IN binary_integer,
  ixpid IN binary_integer,
  rtabnm IN varchar2
)
  as external
  name "comt_cb"
  library dr$lib
  with context
  parameters(
    context,
    idxid  ub4,
    ixpid  ub4,
    rtabnm OCISTRING
);
/

CREATE TABLE dr$part_stats(
 idx_id          NUMBER(38,0),
 ixp_id          NUMBER(38,0),
 statistics      BLOB,
 PRIMARY KEY (idx_id, ixp_id)
);

REM ========================================================================
REM BLOB_LOC, CLOB_LOC USER_DATASTORE OUTPUT_TYPE
REM ========================================================================

begin
insert into dr$object_attribute_lov values
  (10502, 'CLOB_LOC', 4, 'Permanent CLOB Locator');

insert into dr$object_attribute_lov values
  (10502, 'BLOB_LOC', 5, 'Permanent BLOB Locator');
exception
when dup_val_on_index then
null;
end;
/

commit;

REM ========================================================================
REM change in lov value for theme_language
REM ========================================================================

update dr$object_attribute_lov
set oal_value = 16
where oal_oat_id = 60117
and oal_label = 'FRENCH';

update dr$object_attribute_lov
set oal_value = 13
where oal_oat_id = 60117
and oal_label = 'ENGLISH';

update dr$index_value set ixv_value = 16 
 where (ixv_oat_id = 60117 or ixv_sub_oat_id = 60117) 
  and ixv_value = '2'; 

update dr$preference_value
set prv_value = '16'
where prv_oat_id = 60117
and prv_value = '2';

commit;

REM ========================================================================
REM CTXRULE system parameters 
REM ========================================================================

insert into dr$parameter (par_name, par_value)
values ('DEFAULT_CTXRULE_LEXER',        'CTXSYS.DEFAULT_LEXER');

insert into dr$parameter (par_name, par_value)
values ('DEFAULT_CTXRULE_STOPLIST',     'CTXSYS.DEFAULT_STOPLIST');

insert into dr$parameter (par_name, par_value)
values ('DEFAULT_CTXRULE_WORDLIST',     'CTXSYS.DEFAULT_WORDLIST');

insert into dr$parameter (par_name, par_value)
values ('DEFAULT_CTXRULE_STORAGE',      'CTXSYS.DEFAULT_STORAGE');

commit;

REM =======================================================================
REM Make association between index and secondary objects
REM =======================================================================

create table temp_secobj ( 
    pobjschema      varchar2(30),  
    pobjname        varchar2(30),
    objschema       varchar2(30),
    objname         varchar2(30));

declare

  cursor c is
    select idx_name, u.name, idx_id 
    from ctxsys.dr$index, sys.user$ u 
    where idx_owner# = u.user#;  

  indexname varchar2(80);
  indexown  varchar2(80);
  idxid     number;
  ptable    boolean := FALSE;

begin

  open c;
  loop
    fetch c into indexname, indexown, idxid;
    if (c%notfound) then
      exit;
    else
      ptable := FALSE;
      for c1 in (select null from dr$index_value
                  where ixv_value = '1'
                    and ixv_oat_id = 
                   (select oat_id
                      from dr$object_attribute
                     where oat_cla_id = DRIOBJ.CLASS_WORDLIST
                       and oat_obj_id = DRIOBJ.OBJ_BASIC_WORDLIST
                       and oat_name = 'SUBSTRING_INDEX')
                    and ixv_idx_id = idxid)
      loop
        ptable := TRUE;
      end loop;

      if (ptable) then
        insert into temp_secobj values (indexown, indexname, indexown, 
                                        'DR$'||indexname||'$P');
      end if;
  
      insert into temp_secobj values (indexown, indexname, indexown, 
                                      'DR$'||indexname||'$I');
      insert into temp_secobj values (indexown, indexname, indexown, 
                                      'DR$'||indexname||'$K');
      insert into temp_secobj values (indexown, indexname, indexown, 
                                      'DR$'||indexname||'$N');
      insert into temp_secobj values (indexown, indexname, indexown, 
                                      'DR$'||indexname||'$R');
    end if; 
  end loop;
    
  commit;
  close c;

end;
/

declare
  cursor cSecObjs is 
    select * from temp_secobj;
    SecObj SYS.ODCISecObj := SYS.ODCISecObj(NULL, NULL, NULL, NULL);
    SecObjList SYS.ODCISecObjTable := SYS.ODCISecObjTable();
    gNumSecObj binary_integer := 0;

begin
 
    open cSecObjs;
    loop
      fetch cSecObjs into SecObj.pobjschema, SecObj.pobjname, 
                          SecObj.objschema, SecObj.objname;

      exit when cSecObjs%NOTFOUND;

      gNumSecObj := gNumSecObj + 1;
      SecObjList.extend(1);
      SecObjList(gNumSecObj) := SecObj;
    end loop;
    close cSecObjs;

    dbms_odci.upgrade_secobj(SecObjList);
end;
/

drop table temp_secobj;  

REM ========================================================================
REM CTX_VERSION
REM ========================================================================

create or replace function dri_version return varchar2
is begin return '0.0.0.0.0'; end;
/

CREATE OR REPLACE VIEW ctx_version AS
select '9.0.0.0.0' ver_dict, 
substr(dri_version,1,10) ver_code from dual;
