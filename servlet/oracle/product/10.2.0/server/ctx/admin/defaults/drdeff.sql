Rem
Rem $Header: drdeff.sql 10-jun-2005.11:28:56 surman Exp $
Rem
Rem drdeff.sql
Rem
Rem Copyright (c) 1998, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      drdeff.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      default preference for French
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
  CTX_DDL.set_attribute('DEFAULT_WORDLIST','STEMMER', 'FRENCH');
  CTX_DDL.set_attribute('DEFAULT_WORDLIST','FUZZY_MATCH', 'FRENCH');
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
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','afin');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ailleurs');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ainsi');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','alors');
  add_utf8_stopword('617072C3A873'); /* après   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','attendant');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','au');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','aucun');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','aucune');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','au-dessous');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','au-dessus');
  add_utf8_stopword('61757072C3A873'); /* auprès   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','auquel');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','aussi');
  add_utf8_stopword('617573736974C3B474'); /* aussitôt   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','autant');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','autour');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','aux');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','auxquelles');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','auxquels');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','avec');
  add_utf8_stopword('C3A0'); /* à   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','beaucoup');
  add_utf8_stopword('C3A761'); /* ça   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ce');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ceci');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','cela');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','celle');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','celles');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','celui');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','cependant');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','certain');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','certaine');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','certaines');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','certains');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ces');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','cet');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','cette');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ceux');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','chacun');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','chacune');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','chaque');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','chez');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','combien');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','comme');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','comment');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','concernant');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','dans');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','de');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','dedans');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','dehors');
  add_utf8_stopword('64C3A96AC3A0'); /* déjà   */
  add_utf8_stopword('64656CC3A0'); /* delà   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','depuis');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','des');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','desquelles');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','desquels');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','dessus');
  add_utf8_stopword('64C3A873'); /* dès'   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','donc');
  add_utf8_stopword('646F6E6EC3A9'); /* donné   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','dont');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','du');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','duquel');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','durant');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','elle');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','elles');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','en');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','encore');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','entre');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','et');
  add_utf8_stopword('C3A9746169656E74'); /* étaient   */
  add_utf8_stopword('C3A974616974'); /* était   */
  add_utf8_stopword('C3A974616E74'); /* étant   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','etc');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','eux');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','furent');
  add_utf8_stopword('6772C3A26365'); /* grâce   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','hormis');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','hors');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ici');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','il');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ils');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','jadis');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','je');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','jusqu');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','jusque');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','la');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','laquelle');
  add_utf8_stopword('6CC3A0'); /* là   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','le');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','lequel');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','les');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','lesquelles');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','lesquels');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','leur');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','leurs');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','lors');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','lorsque');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','lui');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ma');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','mais');
  add_utf8_stopword('6D616C6772C3A9'); /* malgré   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','me');
  add_utf8_stopword('6DC3AA6D65'); /* même   */
  add_utf8_stopword('6DC3AA6D6573'); /* mêmes   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','mes');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','mien');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','mienne');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','miennes');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','miens');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','moins');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','moment');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','mon');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','moyennant');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ne');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ni');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','non');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','nos');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','notamment');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','notre');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','notres');
  add_utf8_stopword('6EC3B4747265'); /* nôtre   */
  add_utf8_stopword('6EC3B474726573'); /* nôtres   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','nous');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','nulle');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','nulles');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','on');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ou');
  add_utf8_stopword('6FC3B9'); /* où   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','par');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','parce');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','parmi');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','plus');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','plusieurs');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','pour');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','pourquoi');
  add_utf8_stopword('7072C3A873'); /* près   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','puis');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','puisque');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','quand');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','quant');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','que');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','quel');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','quelle');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','quelqu''un');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','quelqu''une');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','quelque');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','quelques-unes');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','quelques-uns');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','quels');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','qui');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','quiconque');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','quoi');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','quoique');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','sa');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','sans');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','sauf');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','se');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','selon');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ses');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','sien');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','sienne');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','siennes');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','siens');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','soi');
  add_utf8_stopword('736F692D6DC3AA6D65');  /* soi-même   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','soit');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','sont');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','suis');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','sur');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ta');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','tandis');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','tant');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','te');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','telle');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','telles');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','tes');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','tienne');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','tiennes');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','tiens');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','toi');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ton');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','toujours');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','tous');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','toute');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','toutes');
  add_utf8_stopword('7472C3A873'); /* très   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','trop');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','tu');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','un');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','une');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','vos');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','votre');
  add_utf8_stopword('76C3B4747265'); /* vôtre   */
  add_utf8_stopword('76C3B474726573'); /* vôtres   */
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','vous');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','vu');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','y');
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
