Rem
Rem $Header: drdefzht.sql 10-jun-2005.11:29:39 surman Exp $
Rem
Rem drdefzht.sql
Rem
Rem Copyright (c) 1998, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      drdefzht.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      default preference for traditional Chinese
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      06/10/05 - 4003390: Change comments 
Rem    surman      12/07/04 - 4003390: Remove dependency on NLS_LANG 
Rem    gkaminag    11/20/01 - policy name to default_policy_oracontains
Rem    jachen      10/30/01 - add stopwords
Rem    gkaminag    10/23/01 - default policy
Rem    ehuang      04/12/01 - add description
Rem    mfaisal     10/05/98 - change default stemmer to NULL
Rem    ehuang      09/04/98 -
Rem    ehuang      09/04/98 - Created
Rem

PROMPT Creating lexer preference...
begin
  CTX_DDL.create_preference('DEFAULT_LEXER', 'CHINESE_VGRAM_LEXER');
end;
/

PROMPT Creating wordlist preference...
begin
  CTX_DDL.create_preference('DEFAULT_WORDLIST','BASIC_WORDLIST');
  CTX_DDL.set_attribute('DEFAULT_WORDLIST','STEMMER', 'NULL');
  CTX_DDL.set_attribute('DEFAULT_WORDLIST','FUZZY_MATCH', 'CHINESE_VGRAM');
end;
/

PROMPT Creating stoplist...
declare
  db_charset VARCHAR2(500);

  procedure add_utf8_stopword(hexstring in VARCHAR2) is
  begin
    CTX_DDL.add_stopword('DEFAULT_STOPLIST', UTL_RAW.cast_to_varchar2(
      UTL_RAW.convert(HEXTORAW(hexstring), db_charset,
                                           'AMERICAN_AMERICA.UTF8')));
  end add_utf8_stopword;

begin
  SELECT 'AMERICAN_AMERICA.' || value
    INTO db_charset
    FROM v$nls_parameters
    WHERE parameter = 'NLS_CHARACTERSET';

  /* Why the extra spaces around the comments?  If the client character set
   * (as identified by NLS_LANG) is AL32UTF8 (or possibly others as well)
   * then the accented characters in the comments, which are in ISO8859-1,
   * are interpreted as multibyte characters.  Thus up to 3 characters after
   * the accented character are mis-interpreted.  If one of these characters
   * happens to be the end comment marker, then the following line or lines
   * is commented out, which leads to missing stopwords and/or PL/SQL parse
   * errors.  End result - the extra spaces before the end comment markers
   * are necessary to ensure that the marker is processed correctly. 
   */
  CTX_DDL.create_stoplist('DEFAULT_STOPLIST');

  /* 目前   */
  add_utf8_stopword('E79BAEE5898D');

  /* 由於   */
  add_utf8_stopword('E794B1E696BC');

  /* 因此   */
  add_utf8_stopword('E59BA0E6ADA4');

  /* 他們   */
  add_utf8_stopword('E4BB96E58091');

  /* 可能   */
  add_utf8_stopword('E58FAFE883BD');

  /* 沒有   */
  add_utf8_stopword('E6B292E69C89');

  /* 希望   */
  add_utf8_stopword('E5B88CE69C9B');

  /* 有關   */
  add_utf8_stopword('E69C89E9979C');

  /* 不過   */
  add_utf8_stopword('E4B88DE9818E');

  /* 可以   */
  add_utf8_stopword('E58FAFE4BBA5');

  /* 如果   */
  add_utf8_stopword('E5A682E69E9C');

  /* 對於   */
  add_utf8_stopword('E5B08DE696BC');

  /* 因為   */
  add_utf8_stopword('E59BA0E782BA');

  /* 是否   */
  add_utf8_stopword('E698AFE590A6');

  /* 但是   */
  add_utf8_stopword('E4BD86E698AF');

  /* 相當   */
  add_utf8_stopword('E79BB8E795B6');

  /* 其中   */
  add_utf8_stopword('E585B6E4B8AD');

  /* 其他   */
  add_utf8_stopword('E585B6E4BB96');

  /* 雖然   */
  add_utf8_stopword('E99B96E784B6');

  /* 我們   */
  add_utf8_stopword('E68891E58091');

  /* 包括   */
  add_utf8_stopword('E58C85E68BAC');

  /* 必須   */
  add_utf8_stopword('E5BF85E9A088');

  /* 以上   */
  add_utf8_stopword('E4BBA5E4B88A');

  /* 之後   */
  add_utf8_stopword('E4B98BE5BE8C');

  /* 所以   */
  add_utf8_stopword('E68980E4BBA5');

  /* 以及   */
  add_utf8_stopword('E4BBA5E58F8A');

  /* 許多   */
  add_utf8_stopword('E8A8B1E5A49A');

  /* 最近   */
  add_utf8_stopword('E69C80E8BF91');

  /* 至於   */
  add_utf8_stopword('E887B3E696BC');

  /* 一般   */
  add_utf8_stopword('E4B880E888AC');

  /* 不是   */
  add_utf8_stopword('E4B88DE698AF');

  /* 不能   */
  add_utf8_stopword('E4B88DE883BD');

  /* 而且   */
  add_utf8_stopword('E8808CE4B894');

  /* 引起   */
  add_utf8_stopword('E5BC95E8B5B7');

  /* 如何   */
  add_utf8_stopword('E5A682E4BD95');

  /* 除了   */
  add_utf8_stopword('E999A4E4BA86');

  /* 不少   */
  add_utf8_stopword('E4B88DE5B091');

  /* 最後   */
  add_utf8_stopword('E69C80E5BE8C');

  /* 就是   */
  add_utf8_stopword('E5B0B1E698AF');

  /* 分別   */
  add_utf8_stopword('E58886E588A5');

  /* 加強   */
  add_utf8_stopword('E58AA0E5BCB7');

  /* 甚至   */
  add_utf8_stopword('E7949AE887B3');

  /* 繼續   */
  add_utf8_stopword('E7B9BCE7BA8C');

  /* 另外   */
  add_utf8_stopword('E58FA6E5A496');

  /* 共同   */
  add_utf8_stopword('E585B1E5908C');

  /* 只有   */
  add_utf8_stopword('E58FAAE69C89');

  /* 了解   */
  add_utf8_stopword('E4BA86E8A7A3');

  /* 根據   */
  add_utf8_stopword('E6A0B9E6939A');

  /* 已經   */
  add_utf8_stopword('E5B7B2E7B693');

  /* 過去   */
  add_utf8_stopword('E9818EE58EBB');

  /* 所有   */
  add_utf8_stopword('E68980E69C89');

  /* 不會   */
  add_utf8_stopword('E4B88DE69C83');

  /* 以來   */
  add_utf8_stopword('E4BBA5E4BE86');

  /* 任何   */
  add_utf8_stopword('E4BBBBE4BD95');

  /* 一直   */
  add_utf8_stopword('E4B880E79BB4');

  /* 不同   */
  add_utf8_stopword('E4B88DE5908C');

  /* 立即   */
  add_utf8_stopword('E7AB8BE58DB3');

  /* 左右   */
  add_utf8_stopword('E5B7A6E58FB3');

  /* 經過   */
  add_utf8_stopword('E7B693E9818E');

  /* 尤其   */
  add_utf8_stopword('E5B0A4E585B6');

  /* 使得   */
  add_utf8_stopword('E4BDBFE5BE97');

  /* 相關   */
  add_utf8_stopword('E79BB8E9979C');

  /* 當時   */
  add_utf8_stopword('E795B6E69982');

  /* 進入   */
  add_utf8_stopword('E980B2E585A5');

  /* 並不   */
  add_utf8_stopword('E4B8A6E4B88D');

  /* 據了解   */
  add_utf8_stopword('E6939AE4BA86E8A7A3');

  /* 現在   */
  add_utf8_stopword('E78FBEE59CA8');

  /* 只是   */
  add_utf8_stopword('E58FAAE698AF');

  /* 需要   */
  add_utf8_stopword('E99C80E8A681');

  /* 原因   */
  add_utf8_stopword('E58E9FE59BA0');

  /* 只要   */
  add_utf8_stopword('E58FAAE8A681');

  /* 否則   */
  add_utf8_stopword('E590A6E58987');

  /* 並未   */
  add_utf8_stopword('E4B8A6E69CAA');

  /* 什麼   */
  add_utf8_stopword('E4BB80E9BABC');

  /* 如此   */
  add_utf8_stopword('E5A682E6ADA4');

  /* 不要   */
  add_utf8_stopword('E4B88DE8A681');
end;
/

PROMPT Creating default policy...
begin
  CTX_DDL.create_policy('DEFAULT_POLICY_ORACONTAINS',
    filter        => 'CTXSYS.NULL_FILTER',
    section_group => 'CTXSYS.NULL_SECTION_GROUP',
    lexer         => 'CTXSYS.DEFAULT_LEXER',
    stoplist      => 'CTXSYS.DEFAULT_STOPLIST',
    wordlist      => 'CTXSYS.DEFAULT_WORDLIST'
);
end;
/
