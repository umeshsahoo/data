Rem
Rem $Header: drdefi.sql 10-jun-2005.11:29:04 surman Exp $
Rem
Rem drdefi.sql
Rem
Rem Copyright (c) 1998, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      drdefi.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      default preference for Italian
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      06/10/05 - 4003390: Change comments 
Rem    surman      06/06/05 - 4003390: Fix anziché and bensì   
Rem    surman      12/08/04 - 4003390: Remove dependency on NLS_LANG 
Rem    gkaminag    05/18/04 - refresh
Rem    gkaminag    11/20/01 - policy name to default_policy_oracontains
Rem    gkaminag    10/23/01 - default policy
Rem    ehuang      04/12/01 - add description
Rem    ehuang      09/04/98 - language-specific defaults
Rem    ehuang      09/04/98 - Created
Rem

PROMPT  Creating lexer preference...

begin
  CTX_DDL.create_preference('DEFAULT_LEXER','BASIC_LEXER');
end;
/

PROMPT  Creating wordlist preference...

begin
  CTX_DDL.create_preference('DEFAULT_WORDLIST','BASIC_WORDLIST');
  CTX_DDL.set_attribute('DEFAULT_WORDLIST','STEMMER', 'ITALIAN');
  CTX_DDL.set_attribute('DEFAULT_WORDLIST','FUZZY_MATCH', 'ITALIAN');
end;
/


PROMPT  Creating stoplist...
  
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
  ctx_ddl.create_stoplist('DEFAULT_STOPLIST');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','a');
  add_utf8_stopword('616666696E6368C3A9'); /* affinché   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','agl''');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','agli');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ai');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','al');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','all''');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','alla');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','alle');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','allo');
  add_utf8_stopword('616E7A696368C3A9'); /* anziché   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','avere');
  add_utf8_stopword('62656E73C3AC'); /* bensì   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','che');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','chi');
  add_utf8_stopword('63696FC3A8'); /* cioè   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','come');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','comunque');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','con');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','contro');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','cosa');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','da');
  add_utf8_stopword('6461636368C3A9'); /* dacché   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','dagl''');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','dagli');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','dai');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','dal');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','dall''');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','dalla');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','dalle');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','dallo');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','degl''');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','degli');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','dei');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','del');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','dell''');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','delle');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','dello');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','di');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','dopo');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','dove');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','dunque');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','durante');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','e');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','egli');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','eppure');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','essere');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','essi');
  add_utf8_stopword('66696E6368C3A9'); /* finché   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','fino');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','fra');
  add_utf8_stopword('676961636368C3A9'); /* giacché   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','gl''');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','gli');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','grazie');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','i');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','il');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','in');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','inoltre');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','io');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','l''');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','la');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','le');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','lo');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','loro');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ma');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','mentre');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','mio');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ne');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','neanche');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','negl''');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','negli');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','nei');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','nel');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','nell''');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','nella');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','nelle');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','nello');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','nemmeno');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','neppure');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','noi');
  add_utf8_stopword('6E6F6E6368C3A9'); /* nonché   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','nondimeno');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','nostro');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','o');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','onde');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','oppure');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ossia');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ovvero');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','per');
  add_utf8_stopword('7065726368C3A9'); /* perché   */
  add_utf8_stopword('7065726369C3B2'); /* perciò   */
  add_utf8_stopword('706572C3B2'); /* però   */
  add_utf8_stopword('706F696368C3A9'); /* poiché   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','prima');
  add_utf8_stopword('7075726368C3A9'); /* purché   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','quand''anche');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','quando');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','quantunque');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','quasi');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','quindi');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','se');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','sebbene');
  add_utf8_stopword('73656E6E6F6E6368C3A9'); /* sennonché   */
  add_utf8_stopword('73656E6F6E6368C3A9'); /* senonché   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','senza');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','seppure');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','si');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','siccome');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','sopra');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','sotto');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','su');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','subito');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','sugl''');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','sugli');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','sui');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','sul');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','sull''');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','sulla');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','sulle');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','sullo');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','suo');
  add_utf8_stopword('74616C6368C3A9'); /* talché   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','tu');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','tuo');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','tuttavia');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','tutti');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','un');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','una');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','uno');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','voi');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','vostro');
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
