Rem
Rem $Header: u1001002.sql 23-may-2005.16:47:08 mfaisal Exp $
Rem
Rem u1001002.sql
Rem
Rem Copyright (c) 2004, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      u1001002.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      upgrade CTXSYS from 10.1 to 10.2
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mfaisal     05/22/05 - bug 4385898 
Rem    wclin       03/07/05 - remove pub. priv for TextOptStats 
Rem    wclin       02/23/05 - handle and suppress ora-1927 error 
Rem    wclin       01/28/05 - revoke exec public priv for ODCIIndex impl types 
Rem    gkaminag    10/12/04 - unique constraint mail filter 
Rem    gkaminag    10/07/04 - move val proc to sys 
Rem    gkaminag    09/16/04 - part field style attribute of mail filter 
Rem    tokawa      07/27/04 - Remove KOREAN_LEXER
Rem    mfaisal     08/04/04 - keyview html export release 8.0.0 
Rem    tokawa      03/29/04 - mixed-case for zh/ja/world lexers.
Rem    gkaminag    03/22/04 - gkaminag_misc_040318 
Rem    gkaminag    03/18/04 - Created
Rem

REM
REM  IF YOU ADD ANYTHING TO THIS FILE REMEMBER TO CHANGE DOWNGRADE SCRIPT
REM

REM ========================================================================
REM MIXED CASE FOR JAPANESE LEXERS
REM ========================================================================

insert into dr$object_attribute values
  (60207, 6, 2, 7, 
   'MIXED_CASE_ASCII7', 'Preserve case of 7-bit ASCII characters',
   'N', 'N', 'Y', 'B', 
   'FALSE', null, null, 'N');

insert into dr$object_attribute values
  (60807, 6, 8, 7, 
   'MIXED_CASE_ASCII7', 'Preserve case of 7-bit ASCII characters',
   'N', 'N', 'Y', 'B', 
   'FALSE', null, null, 'N');

commit;

REM ========================================================================
REM MIXED CASE FOR CHINESE LEXERS
REM ========================================================================

insert into dr$object_attribute values
  (60407, 6, 4, 7, 
   'MIXED_CASE_ASCII7', 'Preserve case of 7-bit ASCII characters',
   'N', 'N', 'Y', 'B', 
   'FALSE', null, null, 'N');

insert into dr$object_attribute values
  (60507, 6, 5, 7, 
   'MIXED_CASE_ASCII7', 'Preserve case of 7-bit ASCII characters',
   'N', 'N', 'Y', 'B', 
   'FALSE', null, null, 'N');

commit;

REM ========================================================================
REM MIXED CASE FOR WORLD LEXER
REM ========================================================================

insert into dr$object_attribute values
  (61107, 6, 11, 7, 
   'MIXED_CASE', 'Preserve mixed-case',
   'N', 'N', 'Y', 'B', 
   'FALSE', null, null, 'N');

commit;

REM ========================================================================
REM REMOVE KOREAN_LEXER
REM ========================================================================

update dr$object_attribute set oat_system = 'Y'
    where oat_cla_id = 6 and oat_obj_id = 3;
update dr$object set obj_system = 'Y'
    where obj_cla_id = 6 and obj_id = 3;

commit;

REM ========================================================================
REM PART_FIELD_STYLE of MAIL_FILTER
REM ========================================================================

begin
insert into dr$object_attribute values
  (40704, 4, 7, 4, 
   'PART_FIELD_STYLE', 'output of index fields of parts of multipart mails',
   'N', 'N', 'Y', 'I', 
   'IGNORE', null, null, 'Y');

insert into dr$object_attribute_lov values
  (40704, 'IGNORE', 0, 'Eliminate');

insert into dr$object_attribute_lov values
  (40704, 'TAG', 1, 'Transform to <field>content</field>');

insert into dr$object_attribute_lov values
  (40704, 'FIELD', 2, 'Transform to field: content');

insert into dr$object_attribute_lov values
  (40704, 'TEXT', 3, 'Transform to content');

commit;
exception
when dup_val_on_index then
  null;
end;
/

REM ========================================================================
REM VAL PROC MOVED TO SYS
REM ========================================================================
drop procedure ctx_validate;

REM ========================================================================
REM AUTO_FILTER_TIMEOUT and AUTO_FILTER_OUTPUT_FORMATTING attributes for
REM MAIL_FILTER
REM ========================================================================

REM Trap ORA-00001 error which will be raised when upgrading from 10.1.0.4+
REM or 9.2.0.7+.  AUTO_FILTER will be backported for inclusion in
REM 10.1.0.4 and 9.2.0.7.

begin
insert into dr$object_attribute values
  (40705, 4, 7, 5, 
   'AUTO_FILTER_TIMEOUT', 'Polling interval in seconds to terminate by force',
   'N', 'N', 'Y', 'I', 
   '60', 0, 42949672, 'N');

insert into dr$object_attribute values
  (40706, 4, 7, 6, 
   'AUTO_FILTER_OUTPUT_FORMATTING', 'formatted output',
   'N', 'N', 'Y', 'B', 
   'TRUE', null, null, 'N');

-- ========================================================================
-- AUTO_FILTER
-- ========================================================================

insert into dr$object values
  (4, 8, 'AUTO_FILTER', 'filter for binary document formats', 'N');

insert into dr$object_attribute values
  (40802, 4, 8, 2, 
   'TIMEOUT', 'Polling interval in seconds to terminate by force',
   'N', 'N', 'Y', 'I', 
   '120', 0, 42949672, 'N');

insert into dr$object_attribute values
  (40803, 4, 8, 3, 
   'TIMEOUT_TYPE', 'Time-out type',
   'N', 'N', 'Y', 'I', 
   'HEURISTIC', null, null, 'Y');

insert into dr$object_attribute_lov values
  (40803, 'HEURISTIC', 1, 'Heuristic');

insert into dr$object_attribute_lov values
  (40803, 'FIXED', 2, 'Fixed');

insert into dr$object_attribute values
  (40804, 4, 8, 4, 
   'OUTPUT_FORMATTING', 'formatted output',
   'N', 'N', 'Y', 'B', 
   'TRUE', null, null, 'N');

-- ========================================================================
-- CTXSYS.AUTO_FILTER DEFAULT PREFERENCE
-- ========================================================================

dr$temp_crepref('AUTO_FILTER', 'AUTO_FILTER');

exception
when dup_val_on_index then
  null;
end;
/

REM ========================================================================
REM MIGRATION FROM INSO_FILTER TO AUTO_FILTER
REM ========================================================================

update dr$index_value
  set ixv_oat_id = 40802
  where ixv_oat_id = 40502;
update dr$index_value
  set ixv_oat_id = 40803
  where ixv_oat_id = 40503;
update dr$index_value
  set ixv_oat_id = 40804
  where ixv_oat_id = 40504;

update dr$index_object
  set ixo_obj_id = 8
  where ixo_cla_id = 4 and ixo_obj_id = 5;

REM ========================================================================
REM MIGRATION OF MAIL_FILTER ATTRIBUTES
REM ========================================================================

-- if both old and new timeout attributes are set then delete old attributes
begin
  for idx in (
    select ixv_idx_id 
      from dr$index_value
      where ixv_oat_id in (40702, 40705)
      group by ixv_idx_id
      having count(ixv_idx_id) > 1
  ) loop
    delete from dr$index_value iv
      where iv.ixv_idx_id = idx.ixv_idx_id
      and iv.ixv_oat_id = 40702;
    update dr$index_object io
      set io.ixo_acnt = io.ixo_acnt - 1
      where io.ixo_idx_id = idx.ixv_idx_id
        and io.ixo_cla_id = 4
        and io.ixo_obj_id = 7; 
  end loop;
end;
/

update dr$index_value
  set ixv_oat_id = 40705
  where ixv_oat_id = 40702;

-- if both old and new output formatting attributes are set then delete old 
-- attributes
begin
  for idx in (
    select ixv_idx_id 
      from dr$index_value
      where ixv_oat_id in (40703, 40706)
      group by ixv_idx_id
      having count(ixv_idx_id) > 1
  ) loop
    delete from dr$index_value iv
      where iv.ixv_idx_id = idx.ixv_idx_id
      and iv.ixv_oat_id = 40703;
    update dr$index_object io
      set io.ixo_acnt = io.ixo_acnt - 1
      where io.ixo_idx_id = idx.ixv_idx_id
        and io.ixo_cla_id = 4
        and io.ixo_obj_id = 7; 
  end loop;
end;
/

update dr$index_value
  set ixv_oat_id = 40706
  where ixv_oat_id = 40703;

REM ========================================================================
REM DEFAULT_FILTER_FILE AND DEFAULT_FILTER_BINARY SYSTEM PARAMETERS
REM ========================================================================

update dr$parameter 
set par_value = 'CTXSYS.AUTO_FILTER'
where par_name = 'DEFAULT_FILTER_BINARY' and par_value = 'CTXSYS.INSO_FILTER';

update dr$parameter 
set par_value = 'CTXSYS.AUTO_FILTER'
where par_name = 'DEFAULT_FILTER_FILE' and par_value = 'CTXSYS.INSO_FILTER';

commit;

REM ========================================================================
REM Revoke execute priv. on TextIndexMethods, CatIndexMethods, 
REM RuleIndexMethods, and XpathIndexMethods  from public
REM ========================================================================

BEGIN
  EXECUTE IMMEDIATE 'revoke execute on TextIndexMethods from public';
EXCEPTION
  WHEN OTHERS THEN
    IF ( SQLCODE = -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
alter type TextIndexMethods compile;

BEGIN
  EXECUTE IMMEDIATE 'revoke execute on CatIndexMethods from public';
EXCEPTION
  WHEN OTHERS THEN
    IF ( SQLCODE = -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
alter type CatIndexMethods compile;

BEGIN
  EXECUTE IMMEDIATE 'revoke execute on RuleIndexMethods from public';
EXCEPTION
  WHEN OTHERS THEN
    IF ( SQLCODE = -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
alter type RuleIndexMethods compile;

BEGIN
  EXECUTE IMMEDIATE 'revoke execute on XpathIndexMethods from public';
EXCEPTION
  WHEN OTHERS THEN
    IF ( SQLCODE = -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
alter type XpathIndexMethods compile;

BEGIN
  EXECUTE IMMEDIATE 'revoke execute on ctx_contains from public';
EXCEPTION
  WHEN OTHERS THEN
    IF ( SQLCODE = -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
alter package ctx_contains compile;

BEGIN
  EXECUTE IMMEDIATE 'revoke execute on driscore from public';
EXCEPTION
  WHEN OTHERS THEN
    IF ( SQLCODE = -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
alter package driscore compile;

BEGIN
  EXECUTE IMMEDIATE 'revoke execute on ctx_catsearch from public';
EXCEPTION
  WHEN OTHERS THEN
    IF ( SQLCODE = -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
alter package ctx_catsearch compile;

BEGIN
  EXECUTE IMMEDIATE 'revoke execute on ctx_matches  from public';
EXCEPTION
  WHEN OTHERS THEN
    IF ( SQLCODE = -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
alter package ctx_matches  compile;

BEGIN
  EXECUTE IMMEDIATE 'revoke execute on driscorr from public';
EXCEPTION
  WHEN OTHERS THEN
    IF ( SQLCODE = -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
alter package driscorr compile;

BEGIN
  EXECUTE IMMEDIATE 'revoke execute on ctx_xpcontains from public';
EXCEPTION
  WHEN OTHERS THEN
    IF ( SQLCODE = -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
alter package ctx_xpcontains  compile;

BEGIN
  EXECUTE IMMEDIATE 'revoke execute on TextOptStats from public';
EXCEPTION
  WHEN OTHERS THEN
    IF ( SQLCODE = -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
alter type TextOptStats  compile;

