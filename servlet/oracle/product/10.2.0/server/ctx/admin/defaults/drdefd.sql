Rem
Rem $Header: drdefd.sql 10-jun-2005.11:28:41 surman Exp $
Rem
Rem drdefd.sql
Rem
Rem Copyright (c) 1998, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      drdefd.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      default preference for German
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      06/10/05 - 4003390: Change comments 
Rem    surman      12/07/04 - 4003390: Remove dependency on NLS_LANG 
Rem    gkaminag    06/28/04 - corrected default stoplist 
Rem    gkaminag    11/20/01 - policy name to default_policy_oracontains
Rem    gkaminag    10/23/01 - default policy
Rem    ehuang      04/12/01 - add description
Rem    ehuang      09/04/98 - language-specific defaults
Rem    ehuang      09/04/98 - Created
Rem

PROMPT  Creating lexer preference...

begin
  CTX_DDL.create_preference('DEFAULT_LEXER','BASIC_LEXER');
  CTX_DDL.set_attribute('DEFAULT_LEXER','ALTERNATE_SPELLING', 'GERMAN');
  CTX_DDL.set_attribute('DEFAULT_LEXER','COMPOSITE', 'GERMAN');
  CTX_DDL.set_attribute('DEFAULT_LEXER','MIXED_CASE', 'YES');
end;
/

PROMPT  Creating wordlist preference...

begin
  CTX_DDL.create_preference('DEFAULT_WORDLIST','BASIC_WORDLIST');
  CTX_DDL.set_attribute('DEFAULT_WORDLIST','STEMMER', 'GERMAN');
  CTX_DDL.set_attribute('DEFAULT_WORDLIST','FUZZY_MATCH', 'GERMAN');
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
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ab');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','aber');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','allein');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','als');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','also');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','am');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','an');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','auch');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','auf');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','aus');
  add_utf8_stopword('6175C39F6572'); /* außer   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','bald');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','bei');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','beim');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','bin');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','bis');
  add_utf8_stopword('6269C39F6368656E'); /* bißchen   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','bist');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','da');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','dabei');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','dadurch');
  add_utf8_stopword('646166C3BC72'); /* dafür   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','dagegen');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','dahinter');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','damit');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','danach');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','daneben');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','dann');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','daran');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','darauf');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','daraus');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','darin');
  add_utf8_stopword('646172C3BC626572'); /* darüber   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','darum');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','darunter');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','das');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','dasselbe');
  add_utf8_stopword('6461C39F'); /* daß   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','davon');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','davor');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','dazu');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','dazwischen');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','dein');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','deine');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','deinem');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','deinen');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','deiner');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','deines');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','dem');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','demselben');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','den');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','denn');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','der');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','derselben');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','des');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','desselben');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','dessen');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','dich');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','die');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','dies');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','diese');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','dieselbe');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','dieselben');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','diesem');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','diesen');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','dieser');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','dieses');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','dir');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','doch');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','dort');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','du');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ebenso');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ehe');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ein');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','eine');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','einem');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','einen');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','einer');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','eines');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','entlang');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','er');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','es');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','etwa');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','etwas');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','euch');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','euer');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','eure');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','eurem');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','euren');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','eurer');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','eures');
  add_utf8_stopword('66C3BC72'); /* für   */
  add_utf8_stopword('66C3BC7273'); /* fürs   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ganz');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','gar');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','gegen');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','genau');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','gewesen');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','her');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','herein');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','herum ');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','hin');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','hinter');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','hintern');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ich');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ihm');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ihn');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','Ihnen');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ihnen');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ihr');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ihre');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','Ihre');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ihrem');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','Ihrem');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ihren');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','Ihren');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','Ihrer');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ihrer');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ihres');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','Ihres');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','im');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','in');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ist');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ja');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','je');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','jedesmal');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','jedoch');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','jene');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','jenem');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','jenen');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','jener');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','jenes');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','kaum');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','kein');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','keine');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','keinem');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','keinen');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','keiner');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','keines');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','man');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','mehr');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','mein');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','meine');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','meinem');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','meinen');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','meiner');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','meines');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','mich');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','mir');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','mit');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','nach');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','nachdem');
  add_utf8_stopword('6EC3A46D6C696368'); /* nämlich   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','neben');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','nein');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','nicht');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','nichts');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','noch');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','nun');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','nur');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ob');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ober');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','obgleich');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','oder');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ohne');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','paar');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','sehr');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','sei');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','sein');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','seine');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','seinem');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','seinen');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','seiner');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','seines');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','seit');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','seitdem');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','selbst');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','sich');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','Sie');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','sie');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','sind');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','so');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','sogar');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','solch');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','solche');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','solchem');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','solchen');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','solcher');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','solches');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','sondern');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','sonst');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','soviel');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','soweit');
  add_utf8_stopword('C3BC626572'); /* über   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','um');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','und');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','uns');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','unser');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','unsre');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','unsrem');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','unsren');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','unsrer');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','unsres');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','vom');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','von');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','vor');
  add_utf8_stopword('77C3A46872656E64'); /* während   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','war');
  add_utf8_stopword('77C3A47265'); /* wäre   */
  add_utf8_stopword('77C3A472656E'); /* wären   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','warum');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','was');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','wegen');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','weil');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','weit');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','welche');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','welchem');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','welchen');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','welcher');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','welches');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','wem');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','wen');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','wenn');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','wer');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','weshalb');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','wessen');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','wie');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','wir');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','wo');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','womit');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','zu');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','zum');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','zur');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','zwar');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','zwischen');  
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
