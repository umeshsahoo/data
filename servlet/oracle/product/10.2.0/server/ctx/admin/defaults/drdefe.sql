Rem
Rem $Header: drdefe.sql 10-jun-2005.11:28:45 surman Exp $
Rem
Rem drdefe.sql
Rem
Rem Copyright (c) 1998, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      drdefe.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      default preference for Spanish
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      06/10/05 - 4003390: Change comments 
Rem    surman      12/08/04 - 4003390: Remove dependency on NLS_LANG 
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
  CTX_DDL.set_attribute('DEFAULT_WORDLIST','STEMMER', 'SPANISH');
  CTX_DDL.set_attribute('DEFAULT_WORDLIST','FUZZY_MATCH', 'SPANISH');
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
  ctx_ddl.create_stoplist('DEFAULT_STOPLIST');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','a');
  add_utf8_stopword('6163C3A1'); /* acá   */
  add_utf8_stopword('6168C3AD'); /* ahí   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ajena');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ajenas');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ajeno');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ajenos');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','al');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','algo');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','alguna');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','algunas');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','alguno');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','algunos');
  add_utf8_stopword('616C67C3BA6E'); /* algún   */
  add_utf8_stopword('616C6CC3A1'); /* allá   */
  add_utf8_stopword('616C6CC3AD'); /* allí   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','aquel');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','aquella');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','aquellas');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','aquello');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','aquellos');
  add_utf8_stopword('617175C3AD'); /* aquí   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','cada');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','cierta');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ciertas');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','cierto');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ciertos');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','como');
  add_utf8_stopword('63C3B36D6F'); /* cómo   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','con');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','conmigo');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','consigo');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','contigo');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','cualquier');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','cualquiera');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','cualquieras');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','cuan');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','cuanta');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','cuantas');
  add_utf8_stopword('6375C3A16E7461'); /* cuánta   */
  add_utf8_stopword('6375C3A16E746173'); /* cuántas   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','cuanto');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','cuantos');
  add_utf8_stopword('6375C3A16E'); /* cuán   */
  add_utf8_stopword('6375C3A16E746F'); /* cuánto   */
  add_utf8_stopword('6375C3A16E746F73'); /* cuántos   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','de');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','dejar');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','del');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','demasiada');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','demasiadas');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','demasiado');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','demasiados');
  add_utf8_stopword('64656DC3A173'); /* demás   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','el');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ella');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ellas');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ellos');
  add_utf8_stopword('C3A96C'); /* él   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','esa');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','esas');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ese');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','esos');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','esta');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','estar');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','estas');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','este');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','estos');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','hacer');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','hasta');
  add_utf8_stopword('6A616DC3A173'); /* jamás   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','junto');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','juntos');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','la');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','las');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','lo');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','los');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','mas');
  add_utf8_stopword('6DC3A173'); /* más   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','me');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','menos');
  add_utf8_stopword('6DC3AD61'); /* mía   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','mientras');
  add_utf8_stopword('6DC3AD6F'); /* mío   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','misma');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','mismas');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','mismo');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','mismos');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','mucha');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','muchas');
  add_utf8_stopword('6D756368C3AD73696D61'); /* muchísima   */
  add_utf8_stopword('6D756368C3AD73696D6173'); /* muchísimas   */
  add_utf8_stopword('6D756368C3AD73696D6F'); /* muchísimo   */
  add_utf8_stopword('6D756368C3AD73696D6F73'); /* muchísimos   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','mucho');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','muchos');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','muy');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','nada');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ni');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ninguna');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ningunas');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ninguno');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ningunos');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','no');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','nos');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','nosotras');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','nosotros');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','nuestra');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','nuestras');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','nuestro');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','nuestros');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','nunca');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','os');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','otra');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','otras');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','otro');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','otros');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','para');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','parecer');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','poca');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','pocas');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','poco');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','pocos');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','por');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','porque');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','que');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','querer');
  add_utf8_stopword('7175C3A9'); /* qué   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','quien');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','quienes');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','quienesquiera');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','quienquiera');
  add_utf8_stopword('717569C3A96E'); /* quién   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ser');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','si');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','siempre');
  add_utf8_stopword('73C3AD'); /* sí   */
  add_utf8_stopword('73C3AD6E'); /* sín   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','Sr');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','Sra');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','Sres');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','Sta');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','suya');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','suyas');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','suyo');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','suyos');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','tal');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','tales');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','tan');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','tanta');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','tantas');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','tanto');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','tantos');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','te');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','tener');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ti');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','toda');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','todas');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','todo');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','todos');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','tomar');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','tuya');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','tuyo');
  add_utf8_stopword('74C3BA'); /* tú   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','un');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','una');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','unas');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','unos');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','usted');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ustedes');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','varias');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','varios');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','vosotras');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','vosotros');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','vuestra');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','vuestras');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','vuestro');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','vuestros');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','y');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','yo');
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
