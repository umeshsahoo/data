Rem
Rem u0902000.sql
Rem
Rem Copyright (c) 2001, 2003, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      u0902000.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      upgrade ctxsys from 9.2.0.X to 10
Rem
Rem    NOTES
Rem      This script upgrades an 9.2.0.X ctxsys data dictionary to 10.  
Rem      This script should be run as ctxsys on an 9.2.0 ctxsys schema
Rem      (or as SYS with ALTER SESSION SET SCHEMA = CTXSYS)
Rem      No other users or schema versions are supported.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mfaisal     12/17/03 - fast inso filter 
Rem    ehuang      12/16/03 - textk clustering 
Rem    ehuang      12/09/03 - odm kmeans 
Rem    surman      11/13/03 - 3242708: Remove server tables 
Rem    daliao      10/16/03 - remove undocumented attrs in text mining
Rem    ehuang      10/24/03 - tracing 
Rem    yucheng     10/26/03 - local online indexing 
Rem    gkaminag    09/16/03 - mdata 
Rem    gshank      09/08/03 - New German spelling 
Rem    mfaisal     08/06/03 - LRG 1553005 
Rem    tokawa      07/07/03 - Unicode world lexer
Rem    ekwan       07/03/03 - Bug 2999760
Rem    yucheng     07/02/03 - migrate to scheduler
Rem    yucheng     06/19/03 - 
Rem    daliao      04/18/03 - kmean multiple assignments
Rem    yucheng     05/11/03 - migrate dr$index
Rem    yucheng     03/28/03 - remove idx_roption
Rem    wclin       03/03/03 - migrate dr$stats
Rem    daliao      02/24/03 - ctxrule classifier object
Rem    daliao      02/20/03 - field section support for feature preparation
Rem    druthven    02/12/03 - bug 2782584: base letter override for alt spell
Rem    gkaminag    02/06/03 - svm changes
Rem    tokawa      01/31/03 - add Japanese wordlist
Rem    gkaminag    02/04/03 - remove ctxx
Rem    daliao      02/04/03 - add kmean clustering
Rem    gkaminag    01/24/03 - drop unneeded objects
Rem    mfaisal     01/15/03 - drop more packages
Rem    pdixon      01/10/03 - dr$dbo pk mismatch w/ ctxtab.sql
Rem    ehuang      12/16/02 - dbo table
Rem    gkaminag    12/17/02 - 
Rem    smuralid    12/23/02 - add dr$nvtab
Rem    yucheng     11/20/02 - add idx_roption to dr$index
Rem    gkaminag    11/26/02 - increase size of version string
Rem    smuralid    11/26/02 - add/drop number_sequence
Rem    wclin       10/16/02 - add smplsz column to dr$stats
Rem    gkaminag    10/28/02 - security upgrade
Rem    ehuang      05/21/02 - add mail_filter_config_file parametr.
Rem    ehuang      04/27/02 - ehuang_mail_filter_020420
Rem    ehuang      04/20/02 - Created
Rem


REM
REM  IF YOU ADD ANYTHING TO THIS FILE REMEMBER TO CHANGE DOWNGRADE SCRIPT
REM

REM ========================================================================
REM DROP SHARED LIBRARY
REM ========================================================================

drop library dr$libx;

REM ========================================================================
REM DROP OBSOLETE TYPES
REM ========================================================================

drop type drparamethod;
drop type outset_t;
drop type out_t;
drop function parallelpopuindex;

REM ========================================================================
REM CLASSIFICATION CHANGES
REM ========================================================================

rem change class id of CLASSIFIER from 99 to 12

update dr$class set cla_id = 12 where cla_id = 99;
update dr$object set obj_cla_id = 12 where obj_cla_id = 99;
update dr$object_attribute set oat_cla_id = 12, oat_id = oat_id - 870000
where oat_cla_id = 99;
update dr$preference set pre_cla_id = 12 where pre_cla_id = 99;
update dr$preference_value set prv_oat_id = prv_oat_id - 870000 
 where prv_pre_id in (select pre_id from dr$preference 
                       where pre_cla_id = 12);
commit;

rem add PRUNE_LEVEL

insert into dr$object_attribute values
  (120107, 12, 1, 7, 
   'PRUNE_LEVEL', 
   'Specify how much to prune a tree, larger value (in percentage) means '||
   'prune more',
   'N', 'N', 'Y', 'I', 
   '75', 0, 100, 'N');
commit;

rem add new SVM_CLASSIFIER

insert into dr$object values
  (12, 2, 'SVM_CLASSIFIER', 'support vector machine classifier', 'N');

rem bug 2782584

rem need to protect when upgrading from 9.2.0.4 where this attribute
rem already exists
begin
insert into dr$object_attribute values
  (60121, 6, 1, 21,
   'OVERRIDE_BASE_LETTER', 'Alternate Spelling override Base Letter for umlauts'
,
   'N', 'N', 'Y', 'B',
   'FALSE', null, null, 'N');
exception
when dup_val_on_index then
null;
end;
/

insert into dr$object_attribute values
  (120201, 12, 2, 1, 
   'MAX_DOCTERMS', 'Maximun number of distinct terms representing one document',
   'N', 'N', 'Y', 'I', 
   '50', 10, 8192, 'N');

insert into dr$object_attribute values
  (120202, 12, 2, 2, 
   'MAX_FEATURES', 'Maximun number of distinct features used in text mining',
   'N', 'N', 'Y', 'I', 
   '3000', 1, 100000, 'N');

insert into dr$object_attribute values
  (120203, 12, 2, 3, 
   'THEME_ON', 'Theme feature',
   'N', 'N', 'Y', 'B', 
   'FALSE', null, null, 'N');

insert into dr$object_attribute values
  (120204, 12, 2, 4, 
   'TOKEN_ON', 'Token feature',
   'N', 'N', 'Y', 'B', 
   'TRUE', null, null, 'N');

insert into dr$object_attribute values
  (120205, 12, 2, 5, 
   'STEM_ON', 'Stemmed Token feature',
   'N', 'N', 'Y', 'B', 
   'FALSE', null, null, 'N');

insert into dr$object_attribute values
  (120206, 12, 2, 6, 
   'MEMORY_SIZE', 'Typical memory size in MB',
   'N', 'N', 'Y', 'I', 
   '500', 10, 4000, 'N');

insert into dr$object_attribute values
  (120207, 12, 2, 7, 
   'SECTION_WEIGHT', 'the multiplier of term occurrence within field section',
   'N', 'N', 'Y', 'I', 
   '2', 0, 100, 'N');

commit;

rem add new CLUSTERING class at id 99

insert into dr$class values
  (99, 'CLUSTERING', 'clustering preferences', 'N');

insert into dr$object values
  (99, 1, 'KMEAN_CLUSTERING', 'K-MEAN clustering', 'N');

insert into dr$object_attribute values
  (990101, 99, 1, 1, 
   'MAX_DOCTERMS', 'Maximun number of distinct terms representing one document',
   'N', 'N', 'Y', 'I', 
   '50', 10, 8192, 'N');

insert into dr$object_attribute values
  (990102, 99, 1, 2, 
   'MAX_FEATURES', 'Maximun number of distinct features used in text mining',
   'N', 'N', 'Y', 'I', 
   '3000', 1, 500000, 'N');

insert into dr$object_attribute values
  (990103, 99, 1, 3, 
   'THEME_ON', 'Theme feature',
   'N', 'N', 'Y', 'B', 
   'FALSE', null, null, 'N');

insert into dr$object_attribute values
  (990104, 99, 1, 4, 
   'TOKEN_ON', 'Token feature',
   'N', 'N', 'Y', 'B', 
   'TRUE', null, null, 'N');

insert into dr$object_attribute values
  (990105, 99, 1, 5, 
   'STEM_ON', 'Stemmed Token feature',
   'N', 'N', 'Y', 'B', 
   'FALSE', null, null, 'N');

insert into dr$object_attribute values
  (990106, 99, 1, 6, 
   'MEMORY_SIZE', 'Typical memory size in MB',
   'N', 'N', 'Y', 'I', 
   '500', 10, 4000, 'N');

insert into dr$object_attribute values
  (990107, 99, 1, 7, 
   'SECTION_WEIGHT', 'the multiplier of term occurrence within field section',
   'N', 'N', 'Y', 'I', 
   '2', 0, 100, 'N');

insert into dr$object_attribute values
  (990108, 99, 1, 8, 
   'CLUSTER_NUM', 'The maximum number of clusters to be generated',
   'N', 'N', 'Y', 'I', 
   '200', 2, 20000, 'N');

commit;

insert into dr$object values
  (99, 2, 'TEXTK_CLUSTERING', 'TEXTK clustering', 'N');

insert into dr$object_attribute values
  (990201, 99, 2, 1, 
   'MAX_DOCTERMS', 'Maximun number of distinct terms representing one document',
   'N', 'N', 'Y', 'I', 
   '50', 10, 8192, 'N');

insert into dr$object_attribute values
  (990202, 99, 2, 2, 
   'MAX_FEATURES', 'Maximun number of distinct features used in text mining',
   'N', 'N', 'Y', 'I', 
   '3000', 1, 500000, 'N');

insert into dr$object_attribute values
  (990203, 99, 2, 3, 
   'THEME_ON', 'Theme feature',
   'N', 'N', 'Y', 'B', 
   'FALSE', null, null, 'N');

insert into dr$object_attribute values
  (990204, 99, 2, 4, 
   'TOKEN_ON', 'Token feature',
   'N', 'N', 'Y', 'B', 
   'TRUE', null, null, 'N');

insert into dr$object_attribute values
  (990205, 99, 2, 5, 
   'STEM_ON', 'Stemmed Token feature',
   'N', 'N', 'Y', 'B', 
   'FALSE', null, null, 'N');

insert into dr$object_attribute values
  (990206, 99, 2, 6, 
   'MEMORY_SIZE', 'Typical memory size in MB',
   'N', 'N', 'Y', 'I', 
   '500', 10, 4000, 'N');

insert into dr$object_attribute values
  (990207, 99, 2, 7, 
   'SECTION_WEIGHT', 'the multiplier of term occurrence within field section',
   'N', 'N', 'Y', 'I', 
   '2', 0, 100, 'N');

insert into dr$object_attribute values
  (990208, 99, 2, 8, 
   'CLUSTER_NUM', 'The maximum number of clusters to be generated',
   'N', 'N', 'Y', 'I', 
   '200', 2, 20000, 'N');

insert into dr$object_attribute values
  (990209, 99, 2, 9, 
   'MIN_SIMILARITY', 'The minimum similarity score for each leaf cluster',
   'N', 'N', 'Y', 'F', 
   '0.2', 0.01, 0.99, 'N');

insert into dr$object_attribute values
  (990210, 99, 2, 10, 
   'HIERARCHY_DEPTH', 'The maximum depth of hierarchy',
   'N', 'N', 'Y', 'I', 
   '1', 1, 20, 'N');

commit;

insert into dr$parameter (par_name, par_value)
values ('DEFAULT_CLUSTERING',     'CTXSYS.DEFAULT_CLUSTERING');

commit;

exec dr$temp_crepref('DEFAULT_CLUSTERING', 'KMEAN_CLUSTERING');

rem add default object (RULE_CLASSIFIER) of classifier class (12) to  
rem     ctxrule index table dr$index_object
insert into dr$index_object 
       (select idx_id, 12, 1, 0 from dr$index where idx_type=2);

commit;

REM ========================================================================
REM MULTI_COLUMN_DATASTORE
REM ========================================================================

insert into dr$object_attribute values
  (10702, 1, 7, 2, 
   'FILTER', 'comma separated list of formats corresponding to the columns',
   'N', 'N', 'Y', 'S', 
   'NONE', null, null, 'N');

insert into dr$object_attribute values
  (10703, 1, 7, 3, 
   'DELIMITER', 'controls in-between column values tagging behaviour',
   'N', 'N', 'Y', 'I', 
   'COLUMN_NAME_TAG', null, null, 'Y');

insert into dr$object_attribute_lov values
  (10703, 'COLUMN_NAME_TAG', 1, 'COLUMN_NAME_TAG');

insert into dr$object_attribute_lov values
  (10703, 'NEWLINE', 2, 'NEWLINE');

commit;

REM ========================================================================
REM JAPANESE LEXER DELIMITER CHARACTERS
REM ========================================================================

insert into dr$object_attribute values
  (60209, 6, 2, 9, 
   'DELIMITER', 
   'Special treatment for the delimiter characters of Japanese text',
   'N', 'N', 'Y', 'I', 
   'NONE', null, null, 'Y');

insert into dr$object_attribute_lov values
  (60209, 'NONE', 0, 'Default');

insert into dr$object_attribute_lov values
  (60209, 'ALL', 1, 'Special delimiter handle(#2195868)');

insert into dr$object_attribute values
  (60809, 6, 8, 9, 
   'DELIMITER', 
   'Special treatment for the delimiter characters of Japanese text',
   'N', 'N', 'Y', 'I', 
   'NONE', null, null, 'Y');

insert into dr$object_attribute_lov values
  (60809, 'NONE', 0, 'Default');

insert into dr$object_attribute_lov values
  (60809, 'ALL', 1, 'Special delimiter handle(#2195868)');

commit;

REM ========================================================================
REM JAPANESE WORDLIST
REM ========================================================================

insert into dr$object_attribute_lov values
  (70101, 'JAPANESE', 10, 'Japanese');

insert into dr$object_attribute_lov values
  (70102, 'JAPANESE', 13, 'Japanese');

commit;

REM ========================================================================
REM Unicode world lexer
REM ========================================================================

insert into dr$object values
  (6, 11, 'WORLD_LEXER', 'Unicode world lexer', 'N');

commit;

REM ========================================================================
REM NEW GERMAN SPELLING
REM ========================================================================

insert into dr$object_attribute values
  (60122, 6, 1, 22,
   'NEW_GERMAN_SPELLING', 'Convert words to new German Spelling',
   'N', 'N', 'Y', 'B',
   'FALSE', null, null, 'N');

commit;

REM ========================================================================
REM MAIL_FILTER
REM ========================================================================

delete from dr$object where obj_id = 7 and obj_cla_id = 4;
delete from dr$object_attribute where oat_id = 40701;
delete from dr$object_attribute where oat_id = 40702;

insert into dr$object values
  (4, 7, 'MAIL_FILTER', 'filter for RFC-822/RFC-2045 mail messages', 'N');

insert into dr$object_attribute values
  (40701, 4, 7, 1, 
   'INDEX_FIELDS', 'colon separated list of fields to preserve',
   'N', 'N', 'Y', 'S', 
   'SUBJECT:CONTENT-DESCRIPTION', null, null, 'N');

insert into dr$object_attribute values
  (40702, 4, 7, 2, 
   'INSO_TIMEOUT', 'Polling interval in seconds to terminate by force',
   'N', 'N', 'Y', 'I', 
   '60', 0, 42949672, 'N');

insert into dr$object_attribute values
  (40703, 4, 7, 3, 
   'INSO_OUTPUT_FORMATTING', 'formatted output',
   'N', 'N', 'Y', 'B', 
   'TRUE', null, null, 'N');

insert into dr$parameter (par_name, par_value)
values ('MAIL_FILTER_CONFIG_FILE','drmailfl.txt');

commit;

exec dr$temp_crepref('MAIL_FILTER', 'MAIL_FILTER');

REM ========================================================================
REM INSO_FILTER
REM ========================================================================

insert into dr$object_attribute values
  (40504, 4, 5, 4, 
   'OUTPUT_FORMATTING', 'formatted output',
   'N', 'N', 'Y', 'B', 
   'TRUE', null, null, 'N');

commit;

REM ========================================================================
REM SECURITY
REM ========================================================================

rem obsolete packages

drop package drixtabx;
drop package drixtabr;
drop package drixtabc;
drop package drixtab;
drop package drirept;
drop package drireps;
drop package dripipe;
drop package body drilist;
drop package driddlx;
drop package driddlr;
drop package driddlc;
drop package driddl;
drop package driadm;

CREATE OR REPLACE VIEW drv$pending as 
select * from dr$pending 
 where pnd_cid = SYS_CONTEXT('DR$APPCTX','IDXID')
with check option;

grant select, insert on drv$pending to public;

CREATE OR REPLACE VIEW drv$waiting as 
select * from dr$waiting 
 where wtg_cid = SYS_CONTEXT('DR$APPCTX','IDXID')
with check option;

grant select, insert on drv$waiting to public;

CREATE OR REPLACE VIEW drv$online_pending as 
select * from dr$online_pending
where onl_cid = SYS_CONTEXT('DR$APPCTX','IDXID')
with check option;

grant select, insert on drv$online_pending to public;

CREATE OR REPLACE VIEW drv$delete as
select * from dr$delete;

grant select on drv$delete to public;

CREATE OR REPLACE VIEW drv$delete2 as 
select * from dr$delete
where del_idx_id = SYS_CONTEXT('DR$APPCTX','IDXID')
with check option;

grant insert on drv$delete2 to public;

CREATE OR REPLACE VIEW drv$unindexed as
select * from dr$unindexed;

grant select on drv$unindexed to public;

CREATE OR REPLACE VIEW drv$unindexed2 as 
select * from dr$unindexed
where unx_idx_id = SYS_CONTEXT('DR$APPCTX','IDXID')
with check option;

grant insert, delete on drv$unindexed2 to public;

grant select on SYS.DBA_TAB_COLS to ctxsys;


REM ========================================================================
REM PROCEDURE type in attributes
REM ========================================================================

update dr$object_attribute set oat_datatype = 'P'
where oat_id in (10501, 40601, 61001, 61003);
commit;

CREATE OR REPLACE VIEW ctx_object_attributes AS
select cla_name      oat_class,
       obj_name      oat_object,
       oat_name      oat_attribute,
       oat_desc      oat_description,
       oat_required  oat_required, 
       oat_static    oat_static, 
       decode(oat_datatype,'S','STRING','I','INTEGER','B','BOOLEAN',
                           'P','PROCEDURE')  
                     oat_datatype, 
       oat_default   oat_default,
       oat_val_min   oat_min, 
       decode(oat_datatype, 'S', null, oat_val_max) oat_max,
       decode(oat_datatype, 'S', oat_val_max, null) oat_max_length
  from dr$class, 
       dr$object, 
       dr$object_attribute 
 where cla_id     = obj_cla_id 
   and obj_cla_id = oat_cla_id 
   and obj_id     = oat_obj_id
   and oat_system = 'N'
   and cla_system = 'N';

update dr$preference_value set prv_value = 'CTXSYS.'||prv_value
 where prv_oat_id in (10501, 40601, 61001, 61003);
update dr$index_value set ixv_value = 'CTXSYS.'||ixv_value
 where ixv_oat_id in (10501, 40601, 61001, 61003);
commit;

REM ========================================================================
REM CTX_VERSION
REM ========================================================================

create or replace function dri_version return varchar2
is begin return '0.0.0.0.0'; end;
/

CREATE OR REPLACE VIEW ctx_version AS
select '10.0.0.0.0' ver_dict, 
substr(dri_version,1,10) ver_code from dual;

REM ========================================================================
REM Extensible Optimizer
REM ========================================================================
ALTER TABLE dr$stats RENAME TO dr$stats_pre10i;
ALTER TABLE dr$stats_pre10i drop primary key;
ALTER TABLE dr$part_stats RENAME TO dr$part_stats_pre10i;
ALTER TABLE dr$part_stats_pre10i drop primary key;
ALTER TABLE dr$index add (
     idx_sync_type        varchar2(20)   DEFAULT NULL,
     idx_sync_memory      varchar2(100)  DEFAULT NULL,
     idx_sync_para_degree number         DEFAULT NULL, 
     idx_sync_interval    varchar2(2000) DEFAULT NULL,
     idx_sync_jobname     varchar2(50)   DEFAULT NULL
);

ALTER TABLE dr$index_partition add (
     ixp_sync_type            VARCHAR2(20)     DEFAULT NULL,
     ixp_sync_memory          VARCHAR2(100)    DEFAULT NULL,
     ixp_sync_para_degree     NUMBER           DEFAULT NULL,
     ixp_sync_interval        VARCHAR2(2000)   DEFAULT NULL,
     ixp_sync_jobname         VARCHAR2(50)     DEFAULT NULL,
     ixp_option               VARCHAR2(40)
);

CREATE TABLE dr$stats(
 idx_id          NUMBER(38,0)     primary key,
 smplsz          NUMBER           default 0
);

INSERT INTO dr$stats (IDX_ID, SMPLSZ)
  SELECT idx_id, 0 FROM dr$stats_pre10i;

REM -------------------------------------------------------------------
REM  dr$number_sequence
REM  Contains integers from 1..256. Used for parallel optimize
REM -------------------------------------------------------------------

CREATE TABLE dr$number_sequence(num number);
TRUNCATE TABLE dr$number_sequence;
DECLARE
  i INTEGER;
BEGIN
  FOR i IN 1..256 LOOP
    INSERT INTO dr$number_sequence VALUES(i);
  END LOOP;
  COMMIT;
END;
/
GRANT SELECT ON dr$number_sequence TO PUBLIC;

REM -------------------------------------------------------------------
REM  dr$dbo
REM -------------------------------------------------------------------

CREATE TABLE dr$dbo(
  dbo_name  varchar2(30),
  dbo_type  varchar2(30),
  primary key (dbo_name, dbo_type)
) organization index;

REM -------------------------------------------------------------------
REM  dr$nvtab
REM  Contains hash keys and values
REM -------------------------------------------------------------------

CREATE TABLE dr$nvtab(
  name  VARCHAR2(256) PRIMARY KEY,
  val   sys.ANYDATA
);

create or replace view ctx_indexes as
select
  idx_id
 ,u.name                 idx_owner
 ,idx_name               idx_name
 ,u2.name                idx_table_owner
 ,o.name                 idx_table
 ,idx_key_name           idx_key_name
 ,idx_text_name          idx_text_name
 ,idx_docid_count        idx_docid_count
 ,idx_status             idx_status
 ,idx_language_column    idx_language_column
 ,idx_format_column      idx_format_column
 ,idx_charset_column     idx_charset_column
 ,decode(idx_type, 0, 'CONTEXT', 1, 'CTXCAT', 2, 'CTXRULE') idx_type
 ,idx_sync_type          idx_sync_type
 ,idx_sync_memory        idx_sync_memory
 ,idx_sync_para_degree   idx_sync_para_degree
 ,idx_sync_interval      idx_sync_interval
 ,idx_sync_jobname       idx_sync_jobname
 from dr$index, sys.user$ u, sys.obj$ o, sys.user$ u2
where idx_owner# = u.user#
  and idx_table_owner# = u2.user#
  and idx_table# = o.obj#
;

create or replace view ctx_user_indexes as
select
  idx_id
 ,idx_name               idx_name
 ,u.name                 idx_table_owner
 ,o.name                 idx_table
 ,idx_key_name           idx_key_name
 ,idx_text_name          idx_text_name
 ,idx_docid_count        idx_docid_count
 ,idx_status             idx_status
 ,idx_language_column    idx_language_column
 ,idx_format_column      idx_format_column
 ,idx_charset_column     idx_charset_column
 ,decode(idx_type, 0, 'CONTEXT', 1, 'CTXCAT', 2, 'CTXRULE') idx_type
 ,idx_sync_type          idx_sync_type
 ,idx_sync_memory        idx_sync_memory
 ,idx_sync_para_degree   idx_sync_para_degree
 ,idx_sync_interval      idx_sync_interval
 ,idx_sync_jobname       idx_sync_jobname
 from dr$index, sys.user$ u, sys.obj$ o
where idx_owner# = userenv('SCHEMAID')
  and idx_table_owner# = u.user#
  and idx_table# = o.obj#
;

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
 ,ixp_sync_type          ixp_sync_type
 ,ixp_sync_memory        ixp_sync_memory
 ,ixp_sync_para_degree   ixp_sync_para_degree
 ,ixp_sync_interval      ixp_sync_interval
 ,ixp_sync_jobname       ixp_sync_jobname
 from dr$index_partition, dr$index, sys.user$ u1, sys.user$ u2,
      sys.obj$ o1, sys.obj$ o2
where idx_owner# = u1.user#
  and idx_table_owner# = u2.user#
  and ixp_table_partition# = o2.obj#
  and idx_table# = o1.obj#
  and ixp_idx_id = idx_id
;

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
 ,ixp_sync_type          ixp_sync_type
 ,ixp_sync_memory        ixp_sync_memory
 ,ixp_sync_para_degree   ixp_sync_para_degree
 ,ixp_sync_interval      ixp_sync_interval
 ,ixp_sync_jobname       ixp_sync_jobname
 from dr$index_partition, dr$index, sys.user$ u2,
      sys.obj$ o1, sys.obj$ o2
where idx_owner# = userenv('SCHEMAID')
  and idx_table_owner# = u2.user#
  and ixp_table_partition# = o2.obj#
  and idx_table# = o1.obj#
  and ixp_idx_id = idx_id
;

REM -------------------------------------------------------------------
REM  MDATA
REM -------------------------------------------------------------------

insert into dr$object_attribute values
  (50207, 5, 2, 7, 
   'MDATA', '',
   'N', 'N', 'Y', 'S', 
   'NONE', null, null, 'N');

insert into dr$object_attribute values
  (50307, 5, 3, 7, 
   'MDATA', '',
   'N', 'N', 'Y', 'S', 
   'NONE', null, null, 'N');

insert into dr$object_attribute values
  (50507, 5, 5, 7, 
   'MDATA', '',
   'N', 'N', 'Y', 'S', 
   'NONE', null, null, 'N');

insert into dr$object_attribute values
  (50607, 5, 6, 7, 
   'MDATA', '',
   'N', 'N', 'Y', 'S', 
   'NONE', null, null, 'N');

commit;

create or replace view ctx_sections as
select
   u.name            sec_owner,
   sgp_name          sec_section_group,
   decode(sec_type, 1, 'ZONE', 2, 'FIELD', 3, 'SPECIAL', 4, 'STOP', 
                    5, 'ATTR', 7, 'MDATA', null)
                     sec_type,
   sec_id            sec_id,
   decode(sec_type, 4, null, sec_name)
                     sec_name,
   sec_tag           sec_tag,
   sec_visible       sec_visible
from dr$section sec, dr$section_group sgp, sys.user$ u
where sgp.sgp_id = sec.sec_sgp_id
  and sgp_owner# = u.user#
/

create or replace view ctx_user_sections as
select
   sgp_name          sec_section_group,
   decode(sec_type, 1, 'ZONE', 2, 'FIELD', 3, 'SPECIAL', 4, 'STOP', 
                    5, 'ATTR', 7, 'MDATA', null)
                     sec_type,
   sec_id            sec_id,
   decode(sec_type, 4, null, sec_name)
                     sec_name,
   sec_tag           sec_tag,
   sec_visible       sec_visible
from dr$section sec, dr$section_group sgp
where sgp.sgp_id = sec.sec_sgp_id
  and sgp_owner# = userenv('SCHEMAID')
/

REM -------------------------------------------------------------------
REM  ctx_trace_values stub
REM -------------------------------------------------------------------

create or replace view ctx_trace_values as
select 0 trc_id, 0 trc_value from dual where 1 = 2;
create or replace public synonym ctx_trace_values for
ctxsys.ctx_trace_values;
grant select on ctx_trace_values to public;


REM -------------------------------------------------------------------
REM  Remove server tables
REM -------------------------------------------------------------------

drop view ctx_servers;
drop table dr$server;
