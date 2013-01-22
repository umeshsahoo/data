Rem
Rem $Header: drdefus.sql 01-jun-2004.15:10:43 gkaminag Exp $
Rem
Rem drdefus.sql
Rem
Rem Copyright (c) 1998, 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      drdefus.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      default preference for American
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    gkaminag    05/18/04 - refresh
Rem    gkaminag    11/20/01 - policy name to default_policy_oracontains
Rem    gkaminag    10/23/01 - default policy
Rem    ehuang      04/12/01 - add description
Rem    gkaminag    11/06/00 - turn off theme indexing in default default lexer
Rem    kmahesh     03/03/00 - English stopwords in lcase for mixed index
Rem    gkaminag    09/24/98 - theme on by default
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
  CTX_DDL.set_attribute('DEFAULT_WORDLIST','STEMMER', 'ENGLISH');
  CTX_DDL.set_attribute('DEFAULT_WORDLIST','FUZZY_MATCH', 'GENERIC');
end;
/

PROMPT  Creating stoplist...

begin
  CTX_DDL.create_stoplist('DEFAULT_STOPLIST');

  ctx_ddl.add_stopword('DEFAULT_STOPLIST','a');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','all');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','almost');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','also');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','although');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','an');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','and');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','any');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','are');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','as');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','at');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','be');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','because');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','been');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','both');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','but');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','by');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','can');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','could');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','d');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','did');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','do');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','does');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','either');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','for');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','from');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','had');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','has');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','have');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','having');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','he');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','her');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','hers');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','here');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','him');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','his');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','how');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','however');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','i');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','if');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','in');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','into');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','is');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','it');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','its');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','just');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ll');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','me');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','might');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','Mr');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','Mrs');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','Ms');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','my');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','no');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','non');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','nor');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','not');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','of');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','on');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','one');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','only');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','onto');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','or');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','our');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ours');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','s');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','shall');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','she');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','should');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','since');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','so');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','some');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','still');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','such');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','t');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','than');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','that');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','the');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','their');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','them');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','then');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','there');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','therefore');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','these');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','they');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','this');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','those');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','though');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','through');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','thus');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','to');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','too');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','until');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','ve');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','very');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','was');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','we');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','were');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','what');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','when');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','where');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','whether');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','which');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','while');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','who');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','whose');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','why');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','will');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','with');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','would');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','yet');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','you');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','your');
  ctx_ddl.add_stopword('DEFAULT_STOPLIST','yours');
end;
/
        
begin
  CTX_DDL.create_stoplist('EXTENDED_STOPLIST');

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
