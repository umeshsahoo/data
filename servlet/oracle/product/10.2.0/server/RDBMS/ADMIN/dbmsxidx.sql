Rem
Rem $Header: dbmsxidx.sql 08-feb-2005.13:30:23 attran Exp $
Rem
Rem dbmsxidx.sql
Rem
Rem Copyright (c) 2000, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmsxidx.sql - DBMS XMLIndex index support routines 
Rem
Rem    DESCRIPTION
Rem      Defines the XMLIndex index creation routines using the extensibility
Rem    mechanism 
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    attran      02/04/05 - bug4148624: SQLInjection
Rem    sichandr    11/22/04 - remove set echo statements 
Rem    sichandr    08/11/04 - utility package for XMLIndex 
Rem    mkrishna    09/06/01 - remove existsnode/extract
Rem    mkrishna    06/29/00 - Created
Rem


CREATE OR REPLACE PACKAGE xdb.dbms_xmlindex AUTHID CURRENT_USER IS

----------------------------------------------------------------------------
-- PROCEDURE - CreateNumberIndex
--     Creates an index for number values in the XMLIndex. The index
--     is created on the VALUE column of the XMLIndex path table on the
--     expression TO_BINARY_DOUBLE(VALUE).
-- PARAMETERS -    
--  xml_index_schema
--     Schema of the XMLIndex
--  xml_index_name
--     Name of the XMLIndex
--  num_index_name
--     Name of the number index to create
--  num_index_clause
--     Storage clause for the number index. This would simply be appended
--     to the CREATE INDEX statement.
----------------------------------------------------------------------------
PROCEDURE CreateNumberIndex(xml_index_schema IN VARCHAR2,
                            xml_index_name   IN VARCHAR2,
                            num_index_name   IN VARCHAR2,
                            num_index_clause IN VARCHAR2 := '');


----------------------------------------------------------------------------
-- PROCEDURE - CreateDateIndex
--     Creates an index for date values in the XMLIndex. The user specifies
--     the XML type name (date, dateTime etc.) and the index is created
--     on SYS_XMLCONV(VALUE) which would always return a TIMESTAMP datatype.
-- PARAMETERS -    
--  xml_index_schema
--     Schema of the XMLIndex
--  xml_index_name
--     Name of the XMLIndex
--  date_index_name
--     Name of the date index to be created
--  xmltypename
--     XML type name - one of the following
--         dateTime
--         time
--         date
--         gDay
--         gMonth
--         gYear
--         gYearMonth
--         gMonthDay
--  date_index_clause
--     Storage clause for the date index. This would simply be appended
--     to the CREATE INDEX statement.
----------------------------------------------------------------------------
PROCEDURE CreateDateIndex(xml_index_schema  IN VARCHAR2,
                          xml_index_name    IN VARCHAR2,
                          date_index_name   IN VARCHAR2,
                          xmltypename       IN VARCHAR2,
                          date_index_clause IN VARCHAR2 := '');

end dbms_xmlindex;
/

grant execute on xdb.dbms_xmlindex to public;
create or replace public synonym dbms_xmlindex for xdb.dbms_xmlindex;

CREATE OR REPLACE PACKAGE BODY xdb.dbms_xmlindex AS

PROCEDURE CreateNumberIndex(xml_index_schema IN VARCHAR2,
                            xml_index_name   IN VARCHAR2,
                            num_index_name   IN VARCHAR2,
                            num_index_clause IN VARCHAR2) IS

  ptname VARCHAR2(32);
BEGIN

--   obtain path table name
  select path_table_name into ptname from all_xml_indexes
  where index_owner = xml_index_schema
  and   index_name =  xml_index_name;

--   set event to disable conversion errors during index creation
  execute immediate 'alter session set events=''30980 trace name context level 1, forever''';

--   create the number index
  BEGIN
    execute immediate 'CREATE INDEX ' ||
       DBMS_ASSERT.ENQUOTE_NAME(num_index_name) || ' ON ' ||
       DBMS_ASSERT.ENQUOTE_NAME(xml_index_schema) || '.' ||
       DBMS_ASSERT.ENQUOTE_NAME(ptname) || ' (TO_BINARY_DOUBLE(VALUE)) ' ||
       DBMS_ASSERT.NOOP(num_index_clause);
-- dynamic sql doesn't allow multiple statements separated with semicolons.
-- Thus no chance for SQL injection into the index_clause.

  EXCEPTION
    WHEN OTHERS THEN
    BEGIN
      execute immediate 'alter session set events=''30980 trace name context off''';
      RAISE;
    END;
  END;

  execute immediate 'alter session set events=''30980 trace name context off''';

END;

PROCEDURE CreateDateIndex(xml_index_schema  IN VARCHAR2,
                          xml_index_name    IN VARCHAR2,
                          date_index_name   IN VARCHAR2,
                          xmltypename       IN VARCHAR2,
                          date_index_clause IN VARCHAR2) IS

  ptname      VARCHAR2(32);
  xmltypecode number;
BEGIN

--   obtain path table name
  select path_table_name into ptname from all_xml_indexes
  where index_owner = xml_index_schema
  and   index_name =  xml_index_name;

--   obtain internal xmltype code
  if xmltypename = 'date' then
    xmltypecode := 10;
  elsif xmltypename = 'dateTime' then
    xmltypecode := 8;
  elsif xmltypename = 'time' then
    xmltypecode := 9;
  elsif xmltypename = 'gDay' then
    xmltypecode := 11;
  elsif xmltypename = 'gMonth' then
    xmltypecode := 12;
  elsif xmltypename = 'gYearMonth' then
    xmltypecode := 14;
  elsif xmltypename = 'gMonthDay' then
    xmltypecode := 15;
  elsif xmltypename = 'gYear' then
    xmltypecode := 13;
  else
    xmltypecode := 10;
  end if;

--   set event to disable conversion errors during index creation
  execute immediate 'alter session set events=''30980 trace name context level 1, forever''';

--   create the number index
  BEGIN
    execute immediate 'CREATE INDEX ' ||
       DBMS_ASSERT.ENQUOTE_NAME(date_index_name) || ' ON ' ||
       DBMS_ASSERT.ENQUOTE_NAME(xml_index_schema) || '.' ||
       DBMS_ASSERT.ENQUOTE_NAME(ptname) || 
         ' (SYS_XMLCONV(VALUE, 3,' || xmltypecode || ',0,0,181)) ' ||
       DBMS_ASSERT.NOOP(date_index_clause);
-- dynamic sql doesn't allow multiple statements separated with semicolons.
-- Thus no chance for SQL injection into the index_clause.

  EXCEPTION
    WHEN OTHERS THEN
    BEGIN
      execute immediate 'alter session set events=''30980 trace name context off''';
      RAISE;
    END;
  END;

  execute immediate 'alter session set events=''30980 trace name context off''';

END;


END dbms_xmlindex;
/
