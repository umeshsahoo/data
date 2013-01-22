Rem
Rem $Header: drdefzhs.sql 10-jun-2005.11:29:38 surman Exp $
Rem
Rem drdefzhs.sql
Rem
Rem Copyright (c) 1998, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      drdefzhs.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      default preference for simplied Chinese
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      06/10/05 - 4003390: Change comments 
Rem    surman      12/02/04 - 4003390: Remove dependency on NLS_LANG 
Rem    gkaminag    11/20/01 - policy name to default_policy_oracontains
Rem    jachen      10/30/01 - add stopwords
Rem    gkaminag    10/23/01 - default policy
Rem    ehuang      04/12/01 - add description
Rem    mfaisal     10/05/98 - change default stemmer to NULL
Rem    ehuang      09/04/98 - language-specific defaults
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

  /* 必将   */
  add_utf8_stopword('E5BF85E5B086');

  /* 必须   */
  add_utf8_stopword('E5BF85E9A1BB');

  /* 并非   */
  add_utf8_stopword('E5B9B6E99D9E');

  /* 由于   */
  add_utf8_stopword('E794B1E4BA8E');

  /* 一同   */
  add_utf8_stopword('E4B880E5908C');

  /* 一再   */
  add_utf8_stopword('E4B880E5868D');

  /* 一得   */
  add_utf8_stopword('E4B880E5BE97');

  /* 超过   */
  add_utf8_stopword('E8B685E8BF87');

  /* 成为   */
  add_utf8_stopword('E68890E4B8BA');

  /* 除了   */
  add_utf8_stopword('E999A4E4BA86');

  /* 处在   */
  add_utf8_stopword('E5A484E59CA8');

  /* 此项   */
  add_utf8_stopword('E6ADA4E9A1B9');

  /* 从而   */
  add_utf8_stopword('E4BB8EE8808C');

  /* 存在着   */
  add_utf8_stopword('E5AD98E59CA8E79D80');

  /* 达到   */
  add_utf8_stopword('E8BEBEE588B0');

  /* 大量   */
  add_utf8_stopword('E5A4A7E9878F');

  /* 带来   */
  add_utf8_stopword('E5B8A6E69DA5');

  /* 带着   */
  add_utf8_stopword('E5B8A6E79D80');

  /* 但是   */
  add_utf8_stopword('E4BD86E698AF');

  /* 当时   */
  add_utf8_stopword('E5BD93E697B6');

  /* 得到   */
  add_utf8_stopword('E5BE97E588B0');

  /* 都是   */
  add_utf8_stopword('E983BDE698AF');

  /* 对于   */
  add_utf8_stopword('E5AFB9E4BA8E');

  /* 这个   */
  add_utf8_stopword('E8BF99E4B8AA');

  /* 而且   */
  add_utf8_stopword('E8808CE4B894');

  /* 而言   */
  add_utf8_stopword('E8808CE8A880');

  /* 方面   */
  add_utf8_stopword('E696B9E99DA2');

  /* 各方面   */
  add_utf8_stopword('E59084E696B9E99DA2');

  /* 各种   */
  add_utf8_stopword('E59084E7A78D');

  /* 共同   */
  add_utf8_stopword('E585B1E5908C');

  /* 还将   */
  add_utf8_stopword('E8BF98E5B086');

  /* 还有   */
  add_utf8_stopword('E8BF98E69C89');

  /* 很少   */
  add_utf8_stopword('E5BE88E5B091');

  /* 很有   */
  add_utf8_stopword('E5BE88E69C89');

  /* 还是   */
  add_utf8_stopword('E8BF98E698AF');

  /* 回到   */
  add_utf8_stopword('E59B9EE588B0');

  /* 获得了   */
  add_utf8_stopword('E88EB7E5BE97E4BA86');

  /* 或者   */
  add_utf8_stopword('E68896E88085');

  /* 基本上   */
  add_utf8_stopword('E59FBAE69CACE4B88A');

  /* 基于   */
  add_utf8_stopword('E59FBAE4BA8E');

  /* 即可   */
  add_utf8_stopword('E58DB3E58FAF');

  /* 较大   */
  add_utf8_stopword('E8BE83E5A4A7');

  /* 尽管   */
  add_utf8_stopword('E5B0BDE7AEA1');

  /* 就是   */
  add_utf8_stopword('E5B0B1E698AF');

  /* 具有   */
  add_utf8_stopword('E585B7E69C89');

  /* 可能   */
  add_utf8_stopword('E58FAFE883BD');

  /* 可以   */
  add_utf8_stopword('E58FAFE4BBA5');

  /* 来自   */
  add_utf8_stopword('E69DA5E887AA');

  /* 两个   */
  add_utf8_stopword('E4B8A4E4B8AA');

  /* 之一   */
  add_utf8_stopword('E4B98BE4B880');

  /* 没有   */
  add_utf8_stopword('E6B2A1E69C89');

  /* 目前   */
  add_utf8_stopword('E79BAEE5898D');

  /* 哪里   */
  add_utf8_stopword('E593AAE9878C');

  /* 那里   */
  add_utf8_stopword('E982A3E9878C');

  /* 却是   */
  add_utf8_stopword('E58DB4E698AF');

  /* 如果   */
  add_utf8_stopword('E5A682E69E9C');

  /* 如何   */
  add_utf8_stopword('E5A682E4BD95');

  /* 什么   */
  add_utf8_stopword('E4BB80E4B988');

  /* 实在   */
  add_utf8_stopword('E5AE9EE59CA8');

  /* 所需   */
  add_utf8_stopword('E68980E99C80');

  /* 所有   */
  add_utf8_stopword('E68980E69C89');

  /* 它的   */
  add_utf8_stopword('E5AE83E79A84');

  /* 他们   */
  add_utf8_stopword('E4BB96E4BBAC');

  /* 为了   */
  add_utf8_stopword('E4B8BAE4BA86');

  /* 我们   */
  add_utf8_stopword('E68891E4BBAC');

  /* 下去   */
  add_utf8_stopword('E4B88BE58EBB');

  /* 现在   */
  add_utf8_stopword('E78EB0E59CA8');

  /* 相当   */
  add_utf8_stopword('E79BB8E5BD93');

  /* 新的   */
  add_utf8_stopword('E696B0E79A84');

  /* 许多   */
  add_utf8_stopword('E8AEB8E5A49A');

  /* 也是   */
  add_utf8_stopword('E4B99FE698AF');

  /* 以及   */
  add_utf8_stopword('E4BBA5E58F8A');

  /* 已经   */
  add_utf8_stopword('E5B7B2E7BB8F');

  /* 以上   */
  add_utf8_stopword('E4BBA5E4B88A');

  /* 因此   */
  add_utf8_stopword('E59BA0E6ADA4');

  /* 因为   */
  add_utf8_stopword('E59BA0E4B8BA');
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
