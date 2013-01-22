rem 
rem $Header: utlscln.sql,v 1.1 1994/08/08 21:48:20 dsdaniel Exp $ 
rem 
Rem  Copyright (c) 1992, 1996, 1997 by Oracle Corporation 
Rem    NAME
Rem      utlscln.sql - UTILITY SNAPshot clone
Rem    DESCRIPTION
Rem      This file is an example of a procedure that clones a snapshot
Rem      repschema.
Rem    RETURNS
Rem 
Rem    NOTES
Rem      This is an example.  It will not work for all snapshot repschemas
Rem      under all circumstances.  See comments.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem     liwong     04/19/97 -  Obsolete parameters and some APIs
Rem     dsdaniel   08/08/94 -  Branch_for_patch
Rem     dsdaniel   08/08/94 -  Creation from Adowings file
 
-- 
-- Toy procedure to clone a snapshot schema from another snapshot site
--
CREATE OR REPLACE PROCEDURE sna_clone(sname   VARCHAR2,
                                      snalink VARCHAR2) IS
sql_cursor   NUMBER;
sql_cursor2  NUMBER;
dummy        NUMBER;
uc_sname     VARCHAR2(30);
oname        VARCHAR2(30);
otype        VARCHAR2(12);
comment      VARCHAR2(80);
master       VARCHAR2(80);
updatable    VARCHAR2(3);
sna_query    VARCHAR2(32767);
BEGIN
  uc_sname := UPPER(sname);
  sql_cursor := dbms_sql.open_cursor;
  BEGIN
    -- get schema comment from snapshot prototype
    dbms_sql.parse(sql_cursor,
                  'select schema_comment from all_repcat @' || snalink 
                   || ' where sname = ''' || uc_sname || '''',
                   dbms_sql.v7);
    dbms_sql.define_column(sql_cursor, 1, comment, 80);
    dummy := dbms_sql.execute_and_fetch(sql_cursor, FALSE);
    dbms_sql.column_value(sql_cursor, 1, comment);

    -- get master from snapshot prototype
    dbms_sql.parse(sql_cursor,
                  'select dblink from all_repschema @' || snalink
                   || ' where snapmaster = ''Y'' '
                   || '   and sname = ''' || uc_sname || '''',
                   dbms_sql.v7);
    dbms_sql.define_column(sql_cursor, 1, master, 80);
    dummy := dbms_sql.execute_and_fetch(sql_cursor, FALSE);
    dbms_sql.column_value(sql_cursor, 1, master);

    -- register snapshot schema with local site
    dbms_repcat.create_snapshot_repgroup(sname, master, comment);
  EXCEPTION WHEN dbms_repcat.duplicateschema THEN
    NULL;
  END;
  dbms_sql.parse(sql_cursor,
                 'select oname, type, object_comment from all_repobject@' 
                 || snalink
                 || ' where sname = ''' || uc_sname || ''''
                 || '   and type != ''TRIGGER''',
                 dbms_sql.v7);
  dbms_sql.define_column(sql_cursor, 1, oname, 30);
  dbms_sql.define_column(sql_cursor, 2, otype, 12);
  dbms_sql.define_column(sql_cursor, 3, comment, 80);
  dummy := dbms_sql.execute(sql_cursor);
  WHILE dbms_sql.fetch_rows(sql_cursor)>0 LOOP
    -- get object information from snapshot prototype
    dbms_sql.column_value(sql_cursor, 1, oname);
    dbms_sql.column_value(sql_cursor, 2, otype);
    dbms_sql.column_value(sql_cursor, 3, comment);
    IF otype = 'SNAPSHOT' THEN
      BEGIN
        sql_cursor2 := dbms_sql.open_cursor;
        -- note: snapshot querys over 32K will fail
        dbms_sql.parse(sql_cursor2,
	         '  select updatable, query from all_snapshots@' || snalink
                 || ' where owner = ''' || uc_sname || ''''
                 || '   and name = ''' || oname || '''',
                 dbms_sql.v7);
        dbms_sql.define_column(sql_cursor2, 1, updatable, 3);
        dbms_sql.define_column(sql_cursor2, 2, sna_query, 32767);
        dummy := dbms_sql.execute_and_fetch(sql_cursor2);
        dbms_sql.column_value(sql_cursor2, 1, updatable);
        dbms_sql.column_value(sql_cursor2, 2, sna_query);
        dbms_sql.close_cursor(sql_cursor2);
      EXCEPTION WHEN others THEN
        IF dbms_sql.is_open(sql_cursor2) THEN
          dbms_sql.close_cursor(sql_cursor2);
        END IF;
        RAISE;
      END;
    ELSE
      sna_query := NULL;
    END IF;
    BEGIN
      -- replicate snapshot object to local site
      IF updatable = 'YES' AND otype = 'SNAPSHOT' THEN
        dbms_repcat.create_snapshot_repobject(sname, oname, otype, 
                 'create snapshot ' || oname || ' for update as ' || sna_query, 
                 comment);
      ELSIF otype = 'SNAPSHOT' THEN
        dbms_repcat.create_snapshot_repobject(sname, oname, otype, 
                 'create snapshot ' || oname || ' as ' || sna_query, 
                 comment);
      ELSE
        dbms_repcat.create_snapshot_repobject(sname, oname, otype, NULL,
                 comment);
      END IF;
    EXCEPTION WHEN dbms_repcat.duplicateobject THEN
      NULL;
    END;
  END LOOP;
  dbms_sql.close_cursor(sql_cursor);
EXCEPTION WHEN others THEN
  IF dbms_sql.is_open(sql_cursor) THEN
    dbms_sql.close_cursor(sql_cursor);
  END IF;
  RAISE;
END;
/

