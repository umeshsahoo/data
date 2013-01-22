rem 
rem Copyright (c) Oracle Corporation 1998, 1999.  All Rights Reserved.
rem
rem  NAME
rem    drmig.pkb - MIGration logic
rem
rem  DESCRIPTION
rem    This package contains the migration logic
rem
rem  MODIFIED    (MM/DD/YY)
rem    gkaminag 02/11/99 -  obsolete keyword dstore
rem    gkaminag 01/20/99 -  bug 801446
rem    ehuang   09/04/98 -  default preference name changes
rem    gkaminag 07/28/98 -  bug 706739/706688
rem    gkaminag 07/23/98 -  bug 705281
rem    gkaminag 07/23/98 -  bugs
rem    gkaminag 06/10/98 -  handle NEWLINE
rem    gkaminag 06/10/98 -  sentence/paragraph
rem    ehuang   06/04/98 -  DEFAULT_ENGINE to DEFAULT_STORAGE
rem    gkaminag 06/03/98 -  migrate blaster filter to inso filter
rem    gkaminag 06/02/98 -  Creation 

create or replace package body dr_migrate as

  lineno      number;
  pv_new_name varchar2(30);

/*-------------------------------------------------------------------------*/

procedure writeln(linetxt in varchar2 default null)
is
begin
   lineno := lineno + 1;
   insert into dr$msql values (lineno, linetxt);
   commit;
end writeln;

/*-------------------------------------------------------------------------*/

procedure comment(comtxt in varchar2)
is
begin
   writeln('REM '||comtxt);
end comment;

/*-------------------------------------------------------------------------*/

procedure warn(warntxt in varchar2)
is
begin
   writeln('REM WARNING: '||warntxt);
end warn;

/*-------------------------------------------------------------------------*/

procedure plsql(
  call in varchar2,
  arg1 in varchar2,
  arg2 in varchar2 default null,
  arg3 in varchar2 default null
) 
is
  temp  varchar2(500);
  line  varchar2(200);
begin
  line := call||'('''||replace(arg1,'''','''''')||'''';
  if (arg2 is not null) then

    if (length(arg2) > 70) then

      line := line||',';
      writeln(line);

      temp := arg2;
      while (length(temp) > 70) 
      loop
        writeln('    '''||replace(substr(temp,1,70),'''','''''')||'''||');
        temp := substr(temp, 71);
      end loop;

      line := '     '''||replace(temp,'''','''''')||'''';

    else
      line := line||','''||replace(arg2,'''','''''')||'''';
    end if;


    if (arg3 is not null)then
      line := line||',';
      writeln(line);

      temp := arg3;
      while (length(temp) > 70) 
      loop
        writeln('    '''||replace(substr(temp,1,70),'''','''''')||'''||');
        temp := substr(temp, 71);
      end loop;

      line := '     '''||replace(temp,'''','''''')||'''';
    end if;
  end if;

  line := line||');';
  writeln(line);
end plsql;

/*-------------------------------------------------------------------------*/

function prename(
  p_pre_owner in varchar2
, p_pre_name  in varchar2
) return varchar2 is
begin
  return '"'||p_pre_owner||'"."'||p_pre_name||'"';
end;


/*-------------------------------------------------------------------------*/

procedure writepref (
  p_pre_id    in number,
  p_pre_owner in varchar2,
  p_pre_name  in varchar2,
  p_pre_obj   in varchar2,
  p_attr_ig1  in varchar2 default null,
  p_attr_ig2  in varchar2 default null,
  p_attr_ig3  in varchar2 default null,
  p_attr_ig4  in varchar2 default null
) is
begin
  writeln('begin');
  plsql('ctx_ddl.create_preference',
        prename(p_pre_owner, p_pre_name),
        p_pre_obj);

  for c1 in (select pat_name, pat_value
               from dr$preference_attribute
              where pat_pre_id = p_pre_id)
  loop
    -- if there are attributes to ignore then ignore them!
    if (p_attr_ig1 is null or 
        c1.pat_name not in (p_attr_ig1, 
                            nvl(p_attr_ig2,'ZZ'),
                            nvl(p_attr_ig3,'ZZ'), 
                            nvl(p_attr_ig4,'ZZ'))) 
    then
      if (c1.pat_value is not null) then
        plsql('ctx_ddl.set_attribute',
              prename(p_pre_owner, p_pre_name),
              c1.pat_name, 
              c1.pat_value);
      end if;
    end if;
  end loop;

  writeln('end;');
  writeln('/');

  pv_new_name := p_pre_name;

end writepref;

/*-------------------------------------------------------------------------*/

procedure obspref(
  p_pre_owner in varchar2,
  p_pre_name in varchar2,
  p_reason in varchar2
)
is
begin
  if (p_pre_owner != 'CTXSYS' or
      p_pre_name not in ('MD_BINARY', 'MD_TEXT', 'DEFAULT_NULL_COMPRESSOR',
                         'AUTOB', 'WW6B', 'HTML_FILTER', 'BASIC_HTML_FILTER',
                         'DEFAULT_LOADER', 'DEFAULT_TRANSLATOR', 
			 'DEFAULT_READER'))
  then
    warn('preference '||p_pre_owner||'.'||p_pre_name||' not migrated');
    warn(p_reason);
  end if;
  pv_new_name := null;
end obspref;

/*-------------------------------------------------------------------------*/

procedure migrate_datastore(
  p_pre_id    in number,
  p_obj_id    in number,
  p_pre_owner in varchar2,
  p_pre_name  in varchar2
) is
begin
  if (p_obj_id = 1) then
    if (p_pre_owner != 'CTXSYS' or
        p_pre_name != 'DEFAULT_DIRECT_DATASTORE')
    then
      writepref(p_pre_id, p_pre_owner, p_pre_name, 'DIRECT_DATASTORE');
    else
      pv_new_name := 'DEFAULT_DATASTORE';      
    end if;

  elsif (p_obj_id = 2) then
    obspref(p_pre_owner, p_pre_name, 
            'MASTER DETAIL is obsolete -- use DETAIL_DATASTORE');

  elsif (p_obj_id = 3) then
    if (p_pre_owner != 'CTXSYS' or
        p_pre_name != 'DEFAULT_OSFILE')
    then
      writepref(p_pre_id, p_pre_owner, p_pre_name, 'FILE_DATASTORE');
    else
      pv_new_name := 'FILE_DATASTORE';
    end if;

  elsif (p_obj_id = 4) then
    if (p_pre_owner != 'CTXSYS' or
        p_pre_name != 'DEFAULT_URL')
    then
      writepref(p_pre_id, p_pre_owner, p_pre_name, 'URL_DATASTORE');
    else
      pv_new_name := 'URL_DATASTORE';
    end if;

  elsif (p_obj_id = 5) then
    writepref(p_pre_id, p_pre_owner, p_pre_name, 'DETAIL_DATASTORE',
              'DETAIL_TEXT_SIZE');
  end if;

end migrate_datastore;

/*-------------------------------------------------------------------------*/

procedure migrate_filter(
  p_pre_id    in number,
  p_obj_id    in number,
  p_pre_owner in varchar2,
  p_pre_name  in varchar2
) is
  dummy number;
begin
  if (p_obj_id = 1) then
    if (p_pre_owner != 'CTXSYS' or
        p_pre_name != 'DEFAULT_NULL_FILTER')
    then
      writepref(p_pre_id, p_pre_owner, p_pre_name, 'NULL_FILTER');
    else
      pv_new_name := 'NULL_FILTER';
    end if;

  elsif (p_obj_id = 2) then
    if (p_pre_owner != 'CTXSYS' or
        p_pre_name not in ('WW6B', 'AUTOB'))
    then
      -- check if they use EXECUTABLE
      select count(*)
        into dummy 
        from dr$preference_attribute
       where pat_pre_id = p_pre_id
         and pat_name = 'EXECUTABLE';

      if (dummy > 0) then
        obspref(p_pre_owner, p_pre_name, 
               'BLASTER FILTER with EXECUTABLE is obsolete');
      else
        writepref(p_pre_id, p_pre_owner, p_pre_name, 'INSO_FILTER', 'FORMAT');
      end if;
    else
      pv_new_name := 'INSO_FILTER';
    end if;
      
  elsif (p_obj_id = 3) then
    obspref(p_pre_owner, p_pre_name, 
            'HTML FILTER is obsolete -- use HTML_SECTION_GROUP');

  elsif (p_obj_id = 4) then
    writepref(p_pre_id, p_pre_owner, p_pre_name, 'USER_FILTER');

  end if;

end migrate_filter;

/*-------------------------------------------------------------------------*/

procedure migrate_lexer(
  p_pre_id    in number,
  p_obj_id    in number,
  p_pre_owner in varchar2,
  p_pre_name  in varchar2
) is
begin
  if (p_obj_id = 1) then
    if (p_pre_owner != 'CTXSYS' or
        p_pre_name != 'DEFAULT_LEXER')
    then
   
      -- check if SENT_PARA is set

      for c1 in (select null from dr$preference_attribute
                  where pat_pre_id = p_pre_id
                    and pat_name = 'SENT_PARA') 
      loop
        warn('sent_para cannot be migrated');
        warn('use a section group with special sections');
      end loop;

      writepref(p_pre_id, p_pre_owner, p_pre_name, 'BASIC_LEXER', 
                'SENT_PARA', 'NEWLINE');

      -- handle NEWLINE migration

      for c1 in (select pat_value from dr$preference_attribute
                  where pat_pre_id = p_pre_id
                    and pat_name = 'NEWLINE') 
      loop
        writeln('begin');

        if (c1.pat_value = '\n') then
          plsql('ctx_ddl.set_attribute',
                prename(p_pre_owner, p_pre_name),
                'NEWLINE', '1');
        else
          plsql('ctx_ddl.set_attribute',
                prename(p_pre_owner, p_pre_name),
                'NEWLINE', '2');
        end if;

        writeln('end;');
        writeln('/');
      end loop;

    else
      pv_new_name := 'DEFAULT_LEXER';
    end if;

  elsif (p_obj_id = 2) then
    if (p_pre_owner != 'CTXSYS' or
        p_pre_name not in ('VGRAM_JAPANESE',
                           'VGRAM_JAPANESE_1','VGRAM_JAPANESE_2'))
    then
      writepref(p_pre_id, p_pre_owner, p_pre_name, 'JAPANESE_VGRAM_LEXER');
    else
      pv_new_name := 'JAPANESE_LEXER';
    end if;
      
  elsif (p_obj_id = 3) then
    if (p_pre_owner != 'CTXSYS' or
        p_pre_name != 'KOREAN') 
    then
      writepref(p_pre_id, p_pre_owner, p_pre_name, 'KOREAN_LEXER');
    else
      pv_new_name := 'KOREAN_LEXER';
    end if;

  elsif (p_obj_id = 4) then
    writeln('begin');
    plsql('ctx_ddl.create_preference',
          prename(p_pre_owner, p_pre_name),
          'BASIC_LEXER');
    plsql('ctx_ddl.set_attribute',
          prename(p_pre_owner, p_pre_name),
          'INDEX_TEXT', '0');
    plsql('ctx_ddl.set_attribute',
          prename(p_pre_owner, p_pre_name),
          'INDEX_THEMES', '1');
    writeln('end;');
    writeln('/');
    pv_new_name := p_pre_name;
   
  elsif (p_obj_id = 5) then
    if (p_pre_owner != 'CTXSYS' or
        p_pre_name not in ('VGRAM_CHINESE',
                           'VGRAM_CHINESE_1','VGRAM_CHINESE_2'))
    then
      writepref(p_pre_id, p_pre_owner, p_pre_name, 'CHINESE_VGRAM_LEXER');
    else
      pv_new_name := 'CHINESE_LEXER';
    end if;

  elsif (p_obj_id = 7) then
    obspref(p_pre_owner, p_pre_name, 'NLS LEXER is obsolete');

  end if;

end migrate_lexer;

/*-------------------------------------------------------------------------*/

procedure migrate_wordlist(
  p_pre_id    in number,
  p_pre_owner in varchar2,
  p_pre_name  in varchar2
) is
begin
  if (p_pre_owner != 'CTXSYS' or
      p_pre_name not in ('VGRAM_JAPANESE_WORDLIST',
                         'KOREAN_WORDLIST',
                         'VGRAM_CHINESE_WORDLIST'))
  then
    writepref(p_pre_id, p_pre_owner, p_pre_name, 'BASIC_WORDLIST',
	      'STCLAUSE', 'INSTCLAUSE', 'SOUNDEX_AT_INDEX', 'SECTION_GROUP');
  else
    if (instr(p_pre_name, 'VGRAM_') != 0) then
      pv_new_name := substr(p_pre_name, 7);
    else
      pv_new_name := p_pre_name;
    end if;
  end if;
end migrate_wordlist;

/*-------------------------------------------------------------------------*/

procedure migrate_stoplist(
  p_pre_id    in number,
  p_pre_owner in varchar2,
  p_pre_name  in varchar2
) is
begin
  if (p_pre_owner != 'CTXSYS' or
      p_pre_name not in ('DEFAULT_STOPLIST',
                         'NO_STOPLIST'))
  then
    writeln('begin');
    plsql('ctx_ddl.create_stoplist',
          prename(p_pre_owner, p_pre_name));

    for c1 in (select pat_name, pat_value
                 from dr$preference_attribute
                where pat_pre_id = p_pre_id)
    loop
      plsql('ctx_ddl.add_stopword', 
            prename(p_pre_owner, p_pre_name),
            c1.pat_value);
    end loop;

    writeln('end;');
    writeln('/');
    pv_new_name := p_pre_name;
    
  else
    if (p_pre_name = 'DEFAULT_STOPLIST') then
      pv_new_name := 'DEFAULT_STOPLIST';
    else
      pv_new_name := 'EMPTY_STOPLIST';
    end if;
  end if;

end migrate_stoplist;

/*-------------------------------------------------------------------------*/

procedure migrate_engine(
  p_pre_id    in number,
  p_obj_id    in number,
  p_pre_owner in varchar2,
  p_pre_name  in varchar2
) is

  i_tablespace varchar2(500);
  i_storage    varchar2(500);
  i_other      varchar2(500);
  i_clause     varchar2(500);

  k_tablespace varchar2(500);
  k_storage    varchar2(500);
  k_other      varchar2(500);
  k_clause     varchar2(500);

  x_tablespace varchar2(500);
  x_storage    varchar2(500);
  x_other      varchar2(500);
  x_clause     varchar2(500);

  n_tablespace varchar2(500);
  n_storage    varchar2(500);
  n_other      varchar2(500);
  n_clause     varchar2(500);

begin
  if (p_obj_id = 2) then
    obspref(p_pre_owner, p_pre_name, 'ENGINE NOP is obsolete');
    return;
  end if;

  if (p_pre_owner != 'CTXSYS' or
      p_pre_name  != 'DEFAULT_INDEX')
  then
    for c1 in (select pat_name, pat_value
                 from dr$preference_attribute
                where pat_pre_id = p_pre_id)
    loop
      if (c1.pat_name = 'I1I_TABLESPACE') then
        x_tablespace := 'tablespace ' || c1.pat_value;
      elsif (c1.pat_name = 'I1I_STORAGE') then
        x_storage := ' storage (' || c1.pat_value||')';
      elsif (c1.pat_name = 'I1I_OTHER_PARMS') then
        x_other := c1.pat_value;
      elsif (c1.pat_name = 'I1T_TABLESPACE') then
        i_tablespace := ' tablespace ' || c1.pat_value;
      elsif (c1.pat_name = 'I1T_STORAGE') then
        i_storage := ' storage (' || c1.pat_value||')';
      elsif (c1.pat_name = 'I1T_OTHER_PARMS') then
        i_other := c1.pat_value;
      elsif (c1.pat_name = 'KTB_TABLESPACE') then
        k_tablespace := ' tablespace ' || c1.pat_value;
      elsif (c1.pat_name = 'KTB_STORAGE') then
        k_storage := ' storage (' || c1.pat_value||')';
      elsif (c1.pat_name = 'KTB_OTHER_PARMS') then
        k_other := c1.pat_value;
      elsif (c1.pat_name = 'LST_TABLESPACE') then
        n_tablespace := ' tablespace ' || c1.pat_value;
      elsif (c1.pat_name = 'LST_STORAGE') then
        n_storage := ' storage (' || c1.pat_value ||')';
      elsif (c1.pat_name = 'LST_OTHER_PARMS') then
        n_other := c1.pat_value;
      end if;
    end loop;

    x_clause := x_tablespace || x_storage || x_other;
    i_clause := i_tablespace || i_storage || i_other;
    n_clause := n_tablespace || n_storage || n_other;
    k_clause := k_tablespace || k_storage || k_other;

    writeln('begin');

    plsql('ctx_ddl.create_preference',
          prename(p_pre_owner, p_pre_name), 'BASIC_STORAGE');

    if (i_clause is not null) then
      plsql('ctx_ddl.set_attribute',
            'I_TABLE_CLAUSE',
            prename(p_pre_owner, p_pre_name),
	    i_clause);
    end if;

    if (k_clause is not null) then
      plsql('ctx_ddl.set_attribute',
            'K_TABLE_CLAUSE',
            prename(p_pre_owner, p_pre_name),
            k_clause);
    end if;

    if (n_clause is not null) then
      plsql('ctx_ddl.set_attribute',
            'N_TABLE_CLAUSE',
            prename(p_pre_owner, p_pre_name),
            n_clause);
    end if;

    if (x_clause is not null) then
      plsql('ctx_ddl.set_attribute',
            'I_INDEX_CLAUSE',
            prename(p_pre_owner, p_pre_name),
            x_clause);
    end if;
            
    writeln('end;');
    writeln('/');
    pv_new_name := p_pre_name;
    
  else
    pv_new_name := 'DEFAULT_STORAGE';
  end if;
end migrate_engine;


/*-------------------------------------------------------------------------*/

procedure migrate_system_prefs is
  jl boolean := false;
  cl boolean := false;
begin
  writeln('begin');
  writeln('null;');
  
  for c1 in (select unique(pre_name) pre_name
               from dr$preference_usage, dr$preference, dr$policy
              where pol_tablename != 'TEMPLATE_POLICY'
                and pus_pol_id = pol_id
                and pus_pre_id = pre_id
                and pre_name in ('VGRAM_JAPANESE',
                                 'VGRAM_JAPANESE_1',
                                 'VGRAM_JAPANESE_2',
                                 'VGRAM_CHINESE',
                                 'VGRAM_CHINESE_1',
                                 'VGRAM_CHINESE_2',
                                 'KOREAN',
                                 'KOREAN_WORDLIST')
                and pre_owner = 'CTXSYS')
  loop
    if (c1.pre_name like 'VGRAM_J%') then
      if (c1.pre_name like '%WORDLIST') then
        -- vgram_japanese_wordlist -> japanese_wordlist
        plsql('ctx_ddl.create_preference',
              'CTXSYS.JAPANESE_WORDLIST',
              'BASIC_WORDLIST');
        plsql('ctx_ddl.set_attribute',
              'CTXSYS.JAPANESE_WORDLIST',
              'STEMMER', 'NULL');
        plsql('ctx_ddl.set_attribute',
              'CTXSYS.JAPANESE_WORDLIST',
              'FUZZY_MATCH', 'JAPANESE_VGRAM');
      else
        if (not jl) then
          -- vgram_japanese, 1, 2 -> japanese_lexer
          plsql('ctx_ddl.create_preference',
                'CTXSYS.JAPANESE_LEXER',
                'JAPANESE_VGRAM_LEXER');
          jl := true;
        end if;
      end if;
    elsif (c1.pre_name like 'VGRAM_C%') then
      if (c1.pre_name like '%WORDLIST') then
        -- vgram_chinese_wordlist -> chinese_wordlist
        plsql('ctx_ddl.create_preference',
              'CTXSYS.CHINESE_WORDLIST',
              'BASIC_WORDLIST');
        plsql('ctx_ddl.set_attribute',
              'CTXSYS.CHINESE_WORDLIST',
              'STEMMER', 'NULL');
        plsql('ctx_ddl.set_attribute',
              'CTXSYS.CHINESE_WORDLIST',
              'FUZZY_MATCH', 'CHINESE_VGRAM');
      else
        if (not cl) then
          -- vgram_chinese, vgram_chinese_1, vgram_chinese_2 -> chinese_lexer
          plsql('ctx_ddl.create_preference',
                'CTXSYS.CHINESE_LEXER',
                'CHINESE_VGRAM_LEXER');
          cl := true;
        end if;
      end if;
    elsif (c1.pre_name = 'KOREAN') then
      -- korean -> korean_lexer
      plsql('ctx_ddl.create_preference',
            'CTXSYS.KOREAN_LEXER',
            'KOREAN_LEXER');
    else
      -- korean_wordlist -> korean_wordlist
        plsql('ctx_ddl.create_preference',
              'CTXSYS.KOREAN_WORDLIST',
              'BASIC_WORDLIST');
        plsql('ctx_ddl.set_attribute',
              'CTXSYS.KOREAN_WORDLIST',
              'STEMMER', 'NULL');
        plsql('ctx_ddl.set_attribute',
              'CTXSYS.KOREAN_WORDLIST',
              'FUZZY_MATCH', 'KOREAN');
    end if;
  end loop;

  writeln('end;');
  writeln('/');

end migrate_system_prefs;

/*-------------------------------------------------------------------------*/

procedure migrate_prefs is
begin

  -- bug 801446: migrate certain system-defined preferences 
  -- if used in non-template policies

  migrate_system_prefs;

  for c1 in (select pre_id, pre_owner, pre_name,
                    pre_cla_id, pre_obj_id
               from dr$preference
              order by pre_owner, pre_cla_id, pre_obj_id)
  loop
    pv_new_name := null;

    if (c1.pre_cla_id = 1) then
      migrate_datastore(c1.pre_id, c1.pre_obj_id, c1.pre_owner, c1.pre_name);
    elsif (c1.pre_cla_id = 2)  then
      obspref(c1.pre_owner, c1.pre_name, 'COMPRESSOR class is obsolete');
    elsif (c1.pre_cla_id = 3)  then
      migrate_filter(c1.pre_id, c1.pre_obj_id, c1.pre_owner, c1.pre_name);
    elsif (c1.pre_cla_id = 4)  then
      migrate_lexer(c1.pre_id, c1.pre_obj_id, c1.pre_owner, c1.pre_name);
    elsif (c1.pre_cla_id = 5)  then
      migrate_wordlist(c1.pre_id, c1.pre_owner, c1.pre_name);
    elsif (c1.pre_cla_id = 6)  then 
      migrate_stoplist(c1.pre_id, c1.pre_owner, c1.pre_name);
    elsif (c1.pre_cla_id = 7)  then 
      migrate_engine(c1.pre_id, c1.pre_obj_id, c1.pre_owner, c1.pre_name);
    elsif (c1.pre_cla_id = 8)  then 
      obspref(c1.pre_owner, c1.pre_name, 'LOAD ENGINE class is obsolete');
    elsif (c1.pre_cla_id = 9)  then
      obspref(c1.pre_owner, c1.pre_name, 'TRANSLATOR class is obsolete');
    elsif (c1.pre_cla_id = 10) then 
      obspref(c1.pre_owner, c1.pre_name, 'READER class is obsolete');
    end if;

    writeln;

    update dr$mpref set mp_new = pv_new_name
     where mp_pre_owner = c1.pre_owner
       and mp_pre_name = c1.pre_name;

    commit;

  end loop;

end migrate_prefs;

/*-------------------------------------------------------------------------*/

procedure migrate_thes is
begin
  for c1 in (select ths_name from dr$ths order by ths_name) loop
    warn('use ctxload -thesdump to migrate thesaurus '||c1.ths_name);
    writeln;
  end loop;
end migrate_thes;

/*-------------------------------------------------------------------------*/

procedure migrate_section_groups is
  error boolean := FALSE;
  l_start varchar2(60);
  l_end varchar2(60);
begin

  delete from dr$msec;
  commit;
  insert into dr$msec 
    select sgrp_owner, sgrp_name, null
      from dr$section_groups;
  commit;

  for c1 in (select sgrp_id, sgrp_owner, sgrp_name
               from dr$section_groups
              order by sgrp_owner, sgrp_name)
  loop

    -- analyze sections to make sure they are ML-like

    for c2 in (select sec_start_tag, sec_end_tag
                 from dr$sections
                where sec_sgrp_id = c1.sgrp_id)
    loop

      if (c2.sec_start_tag like '<%>') then
        l_start := rtrim(ltrim(c2.sec_start_tag, '<'),'>');
      else
        error := true;
        goto elbl;
      end if;

      if (c2.sec_end_tag is not null) then
        if (c2.sec_end_tag like '<%>') then
          l_end := rtrim(ltrim(c2.sec_end_tag, '<'),'>');
          if (upper(l_end) != '/'||upper(l_start)) then
            error := true;
            goto elbl;
          end if;
        else
          error := true;
          goto elbl;
        end if;
      end if;

      <<elbl>>
      if (error) then
        warn('section group '||c1.sgrp_owner||'.'||c1.sgrp_name||
             ' not migrated');
        warn('section tags are not in ML-format');
        exit;
      end if;

    end loop;

    if (error) then 
      goto next; 
    end if;

    -- okay, section group is in ML format

    if (c1.sgrp_owner = 'CTXSYS' and c1.sgrp_name = 'BASIC_HTML_SECTION') then

      writeln('begin');

      plsql('ctx_ddl.create_section_group',
            prename(c1.sgrp_owner, c1.sgrp_name),
            'HTML_SECTION_GROUP');

    else

      comment('Change to HTML_SECTION_GROUP if indexing HTML documents');  

      writeln;
      writeln('begin');

      plsql('ctx_ddl.create_section_group',
            prename(c1.sgrp_owner, c1.sgrp_name),
            'BASIC_SECTION_GROUP');

    end if;

    for c2 in (select sec_name, sec_start_tag, sec_end_tag
                 from dr$sections
                where sec_sgrp_id = c1.sgrp_id)
    loop
      l_start := upper(rtrim(ltrim(c2.sec_start_tag, '<'),'>'));
      plsql('ctx_ddl.add_zone_section',
            prename(c1.sgrp_owner, c1.sgrp_name),
            c2.sec_name,
            l_start);
    end loop;

    writeln('end;');
    writeln('/');

    update dr$msec set ms_new = ms_sg_name
     where ms_sg_owner = c1.sgrp_owner
       and ms_sg_name = c1.sgrp_name;

    <<next>>
    null;

    writeln('');

  end loop;

end migrate_section_groups;

/*-------------------------------------------------------------------------*/

procedure migrate_sqes is
begin
  for c1 in (select pol_owner, query_name, query_text
               from dr$sqe sqe, dr$policy pol
              where sqe.pol_id = pol.pol_id
                and session_id = 'SYSTEM'
              order by pol_owner, query_name)
  loop
    warn('SQEs are no longer associated with policies');
    warn('ensure that this name does not conflict with other SQEs');

    writeln('begin');
    plsql('ctx_query.store_sqe',prename(c1.pol_owner, c1.query_name),
          c1.query_text);
    writeln('end;');
    writeln('/');

  end loop;
end migrate_sqes;

/*-------------------------------------------------------------------------*/

procedure migrate_policies is
  l_status varchar2(11);
  l_dummy  number;
  warning  boolean;
  l_dstore   varchar2(70);
  l_filter   varchar2(70);
  l_lexer    varchar2(70);
  l_wordlist varchar2(70);
  l_stoplist varchar2(70);
  l_storage  varchar2(70);
  l_secgrp   varchar2(70);
  l_newname  varchar2(70);
  l_prename  varchar2(70);
begin 
  for c1 in (select pol_id, pol_owner, pol_name, pol_tablename,
                    pol_text_expr
               from dr$policy
              order by pol_owner, pol_name)
  loop

    warning := FALSE;
    l_dstore   := null;
    l_filter   := null;
    l_lexer    := null;
    l_wordlist := null;
    l_stoplist := null;
    l_storage  := null;
    l_secgrp   := null;

    -- check for template policies

    if (c1.pol_tablename = 'TEMPLATE_POLICY') then
      if (c1.pol_owner != 'CTXSYS' or
          c1.pol_name not in ('DEFAULT_POLICY', 'TEMPLATE_WW6B', 
                              'TEMPLATE_DIRECT', 'TEMPLATE_MD',
                              'TEMPLATE_MD_BIN', 'TEMPLATE_AUTOB',
                              'TEMPLATE_LONGTEXT_STOPLIST_OFF',
                              'TEMPLATE_LONGTEXT_STOPLIST_ON',
                              'TEMPLATE_BASIC_WEB'))
      then
        warn('policy '||c1.pol_owner||'.'||c1.pol_name||' not migrated');
        warn('template policies are no longer supported');
        warning := TRUE;
      else
        goto next;
      end if;
      goto more_checks;
    end if;
    
    -- check for non-indexed policies

    begin
      select txi_status 
        into l_status 
        from dr$text_index
       where txi_pol_id = c1.pol_id;
    exception
      when no_data_found then
        l_status := 'NO_INDEX';
    end;

    if (l_status = 'NO_INDEX') then
        if (not warning) then
          warn('policy '||c1.pol_owner||'.'||c1.pol_name||' not migrated');
        end if;
        warn('non-indexed policies are no longer supported');
        warning := TRUE;
    end if;

    -- check for policy on view

    select count(*) 
      into l_dummy
      from dba_tables 
     where owner = c1.pol_owner
       and table_name = c1.pol_tablename;

    if (l_dummy < 1) then
      if (not warning) then
        warn('policy '||c1.pol_owner||'.'||c1.pol_name||' not migrated');
      end if;
      warn('indexes on views are no longer supported');
      warning := TRUE;
    end if;      

<<more_checks>>
      
    -- check for multiple policy on same column

    select count(*)
      into l_dummy
      from dr$policy
     where pol_owner = c1.pol_owner
       and pol_tablename = c1.pol_tablename
       and pol_text_expr = c1.pol_text_expr
       and pol_name != c1.pol_name;

    if (l_dummy > 0) then
      if (not warning) then
        warn('policy '||c1.pol_owner||'.'||c1.pol_name||' not migrated');
      end if;
      warn('multiple policies on a single column no longer supported');
      warning := TRUE;
    end if;    

    -- now check preferences of the policy

    for c2 in (select pre_id, pre_cla_id, pre_owner, pre_name
                 from dr$preference, dr$preference_usage
                where pus_pre_id = pre_id
                  and pus_pol_id = c1.pol_id
                  and pre_cla_id != 2)
    loop
      select mp_new
        into l_newname
        from dr$mpref
       where mp_pre_owner = c2.pre_owner
         and mp_pre_name = c2.pre_name;

      if (l_newname) is null then
        if (not warning) then
          warn('policy '||c1.pol_owner||'.'||c1.pol_name||' not migrated');
        end if;
        warn('depends on non-migrated preference '||
             c2.pre_owner||'.'||c2.pre_name);
        warning := TRUE;
        l_newname := c2.pre_name;
      end if;

      if (c2.pre_cla_id = 1) then
        l_dstore := prename(c2.pre_owner,l_newname);
      elsif (c2.pre_cla_id = 3)  then
        l_filter := prename(c2.pre_owner,l_newname);
      elsif (c2.pre_cla_id = 4)  then
        l_lexer := prename(c2.pre_owner,l_newname);
      elsif (c2.pre_cla_id = 5)  then
        l_wordlist := prename(c2.pre_owner,l_newname);

        begin
          select pat_value into l_secgrp
            from dr$preference_attribute
           where pat_pre_id = c2.pre_id
             and pat_name = 'SECTION_GROUP';
          
          for c3 in (select ms_sg_owner, ms_sg_name, ms_new
                       from dr$msec
                      where ms_sg_owner||'.'||ms_sg_name = l_secgrp)
          loop
            if (c3.ms_new is null) then
              if (not warning) then
              warn('policy '||c1.pol_owner||'.'||c1.pol_name||' not migrated');
              end if;
              warn('depends on non-migrated section group '||
                    c2.pre_owner||'.'||c2.pre_name);
              warning := TRUE;
            else
              l_secgrp := prename(c3.ms_sg_owner, c3.ms_new);
            end if;
            exit;
          end loop;

        exception
          when no_data_found then null;
        end;

      elsif (c2.pre_cla_id = 6)  then 
        l_stoplist := prename(c2.pre_owner,l_newname);
      elsif (c2.pre_cla_id = 7)  then 
        l_storage := prename(c2.pre_owner,l_newname);
      end if;

    end loop;

    -- now dump policy

    writeln;

    if (warning) then
      comment('create index "'||c1.pol_owner||'"."'||c1.pol_name||'"');
      comment('on "'||c1.pol_owner||'"."'||c1.pol_tablename||'"("'||
              c1.pol_text_expr||'")');
      comment('indextype is context');
      comment('parameters (''datastore '||l_dstore);
      comment('filter '||l_filter);
      comment('lexer '||l_lexer);
      comment('wordlist '||l_wordlist);
      comment('stoplist '||l_stoplist);
      if (l_secgrp is not null) then
        comment('section group '||l_secgrp);
      end if;
      comment('storage '||l_storage||''');'); 
    else
      writeln('create index "'||c1.pol_owner||'"."'||c1.pol_name||'"');
      writeln('on "'||c1.pol_owner||'"."'||c1.pol_tablename||'"("'||
              c1.pol_text_expr||'")');
      writeln('indextype is context');
      writeln('parameters (''datastore '||l_dstore);
      writeln('filter '||l_filter);
      writeln('lexer '||l_lexer);
      writeln('wordlist '||l_wordlist);
      writeln('stoplist '||l_stoplist);
      if (l_secgrp is not null) then
        writeln('section group '||l_secgrp);
      end if;
      writeln('storage '||l_storage||''');'); 
    end if;
  
    writeln;

    <<next>>
    null;

  end loop;

end migrate_policies;

/*-------------------------------------------------------------------------*/

procedure migrate is
begin

  -- start with clean preference migration table

  delete from dr$mpref;
  commit;
  insert into dr$mpref 
    select pre_owner, pre_name, null
      from dr$preference;
  commit;
 
  migrate_thes;
  migrate_prefs;
  migrate_section_groups;
  migrate_sqes;
  migrate_policies;

end migrate;

/*-------------------------------------------------------------------------*/

begin
  lineno := 0;
end dr_migrate;
/
