Rem
Rem $Header: utltzuv2.sql 18-may-2005.11:20:49 srsubram Exp $
Rem
Rem utltzuv2.sql
Rem
Rem Copyright (c) 2003, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      utltzuv2.sql - time zone file upgrade to version 2 script 
Rem
Rem    DESCRIPTION
Rem      In 10g, the contents of the file timezone.dat and timezlrg.dat 
Rem      are updated to the version 2 to reflect the transition rule 
Rem      changes for some time zone region names. The transition rule 
Rem      changes of some time zones might affect the column data of
Rem      TIMESTAMP WITH TIME ZONE data type. For example, if users
Rem      enter TIMESTAMP '2003-02-17 09:00:00 America/Sao_Paulo', 
Rem      we convert the data to UTC based on the transition rules in the 
Rem      time zone file and store them on the disk. So '2003-02-17 11:00:00'
Rem      along with the time zone id for 'America/Sao_Paulo' is stored 
Rem      because the offset for this particular time is '-02:00' . Now the 
Rem      transition rules are modified and the offset for this particular 
Rem      time is changed to '-03:00'. when users retrieve the data, 
Rem      they will get '2003-02-17 08:00:00 America/Sao_Paulo'. There is
Rem      one hour difference compared to the original value.
Rem     
Rem      Refer to $ORACLE_HOME/oracore/zoneinfo/readme.txt for detailed 
Rem      information about time zone file updates.
Rem 
Rem      This script should be run before you update your database's
Rem      time zone file to the new version.
Rem
Rem      This script scans the database to find out all columns
Rem      of TIMESTAMP WITH TIME ZONE data type. If the column is
Rem      in the regular table, the script also finds out how many
Rem      rows might be affected by checking whether the column data
Rem      contain the values for these specific time zone names.
Rem      If the column is in the nested table's storage table, we
Rem      don't scan the data to find out how many rows are affected but
Rem      we still report the table and column info.
Rem      
Rem      The result is stored in the table sys.sys_tzuv2_temptab.
Rem      Before running the script, make sure the table name doesn't
Rem      conflict with any existing table object. It it does,
Rem      change the table name sys.sys_tzuv2_temptab to some other name
Rem      in the script. You can query the table to view the result:
Rem         select * from sys.sys_tzuv2_temptab;   
Rem
Rem      If your database has column data that will be affected by the
Rem      time zone file update, dump the data before you upgrade to the
Rem      new version. After the upgrade, you need update the data
Rem      to make sure the data is stored based on the new rules.
Rem      
Rem      For example, user scott has a table tztab:
Rem      create table tztab(x number primary key, y timestamp with time zone);
Rem      insert into tztab values(1, timestamp '');
Rem
Rem      Before upgrade, you can create a table tztab_back, note
Rem      column y here is defined as VARCHAR2 to preserve the original
Rem      value.
Rem      create table tztab_back(x number primary key, y varchar2(256));
Rem      insert into tztab_back select x, 
Rem                  to_char(y, 'YYYY-MM-DD HH24.MI.SSXFF TZR') from tztab;
Rem
Rem      After upgrade, you need update the data in the table tztab using
Rem      the value in tztab_back.
Rem      update tztab t set t.y = (select to_timestamp_tz(t1.y, 
Rem        'YYYY-MM-DD HH24.MI.SSXFF TZR') from tztab_back t1 where t.x=t1.x); 
Rem
Rem      Or you can use export utility to export your data before the upgrade
Rem      and them import your data again after the upgrade. 
Rem     
Rem      drop table sys.sys_tzuv2_temptab;
Rem      once you are done with the time zone file upgrade.
Rem    
Rem    NOTES
Rem      * This script needs to be run before upgrading to the version 2 time 
Rem        zone file.
Rem      * This script must be run using SQL*PLUS.
Rem      * You must be connected AS SYSDBA to run this script.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    srsubram    05/12/05 - 4331865:Modify script to work with prior 
Rem                           releases 
Rem    lkumar      05/11/04 - Fix lrg 1691434.
Rem    rchennoj    12/02/03 - Fix query 
Rem    qyu         11/22/03 - qyu_bug-3236585 
Rem    qyu         11/17/03 - Created
Rem

SET SERVEROUTPUT ON
Rem=========================================================================
Rem Check any existing table with this name sys.sys_tzuv2_temptab
Rem=========================================================================  
DROP TABLE sys.sys_tzuv2_temptab
/
CREATE TABLE sys.sys_tzuv2_temptab
(
 table_owner  VARCHAR2(30),
 table_name   VARCHAR2(30),
 column_name  VARCHAR2(30),
 rowcount     NUMBER,
 nested_tab   VARCHAR2(3)
)
/

DECLARE

  dbv           VARCHAR2(10);
  numrows       NUMBER;
  TYPE cursor_t IS REF CURSOR;
  cursor_tstz   cursor_t;
  tstz_owner    VARCHAR2(30);
  tstz_tname    VARCHAR2(30);
  tstz_qcname   VARCHAR2(4000);
  tz_version    NUMBER;

BEGIN

  SELECT substr(version,1,6) INTO dbv FROM v$instance;


  IF dbv = '8.1.7.'
  THEN
    DBMS_OUTPUT.PUT_LINE('TIMEZONE data type was not supported in ' ||
                         'Release 8.1.7');
    DBMS_OUTPUT.PUT_LINE('No need to validate TIMEZONE data');
    RETURN;
  END IF;

  IF dbv = '10.1.0'
  THEN

      EXECUTE IMMEDIATE 'SELECT version FROM v$timezone_file' INTO tz_version;

      IF tz_version = 2
      THEN
        DBMS_OUTPUT.PUT_LINE('TIMEZONE data is consistent with version 2 ' ||
                             'transition rules');
        DBMS_OUTPUT.PUT_LINE('No need to validate TIMEZONE data');
        RETURN;
      END IF;

  END IF;

  IF dbv in ('9.0.1.','9.2.0.','10.1.0') 
  THEN

     IF dbv in ('9.0.1.','9.2.0.')
     THEN
       OPEN cursor_tstz FOR
          'SELECT owner, table_name, column_name ' ||
           'FROM   ALL_TAB_COLS ' ||
           'WHERE  data_type LIKE ''TIMESTAMP%WITH TIME ZONE''';
     ELSE
       OPEN cursor_tstz FOR
          'SELECT owner, table_name, qualified_col_name ' ||
           'FROM   ALL_TAB_COLS ' ||
           'WHERE  data_type LIKE ''TIMESTAMP%WITH TIME ZONE''';
     END IF;

     LOOP
      BEGIN
        FETCH cursor_tstz INTO tstz_owner, tstz_tname, tstz_qcname;
        EXIT WHEN cursor_tstz%NOTFOUND;
        EXECUTE IMMEDIATE 
          'SELECT COUNT(1) FROM ' ||
            tstz_owner || '."' || tstz_tname || '" t_alias' ||
            ' WHERE TO_CHAR(t_alias.' || tstz_qcname || ', ''TZR'') 
              IN (''AMERICA/ST_JOHNS'',     ''AMERICA/WINNIPEG'',
                ''AMERICA/MEXICO_CITY'',  ''AMERICA/MAZATLAN'',
                ''AMERICA/TIJUANA'',      ''AMERICA/HAVANA'',
                ''AMERICA/SAO_PAULO'',    ''AMERICA/SANTIAGO'',
                ''AMERICA/GOOSE_BAY'',    ''AMERICA/IQUALUIT'',
                ''AMERICA/RAMKIN_INLET'', ''AMERICA/CAMBRIDGE_BAY'',
                ''AMERICA/CANCUN'',       ''AMERICA/CHIHUAHUA'',
                ''AMERICA/BUENOS_AIRES'', ''AMERICA/FORTALEZA'',
                ''AMERICA/ARAGUAINA'',    ''AMERICA/MACEIO'',
                ''AMERICA/CUIABA'',       ''AMERICA/BOA_VISTA'',
                ''ASIA/TEHRAN'',          ''ASIA/JERUSALEM'',
                ''ASIA/BAGHDAD'',         ''ASIA/AMMAN'',
                ''ASIA/ALMATY'',          ''ASIA/AQTOBE'',
                ''ASIA/AQTAU'',           ''ASIA/KARACHI'',
                ''ASIA/ANADYR'',          ''ATLANTIC/STANLEY'', 
                ''AUSTRALIA/LORD_HOWE'',  ''PACIFIC/FIJI'',
                ''PACIFIC/GUAM'',         ''PACIFIC/SAIPAN'',
                ''PACIFIC/EASTER'',       ''PACIFIC/TONGATAPU'',
                ''EUROPE/TALLINN'',       ''EUROPE/RIGA'',
                ''EUROPE/VILNUS'')' INTO numrows;

        IF numrows > 0 THEN
          EXECUTE IMMEDIATE ' INSERT INTO sys.sys_tzuv2_temptab VALUES (''' ||
           tstz_owner || ''',''' || tstz_tname || ''',''' || 
           tstz_qcname || ''',' || numrows || ', ''NO'')';
       END IF;
  
       EXCEPTION
         WHEN OTHERS THEN
           dbms_output.put_line('OWNER : ' || tstz_owner);
           dbms_output.put_line('TABLE : ' || tstz_tname);
           dbms_output.put_line('COLUMN : ' || tstz_qcname);
           dbms_output.put_line(sqlerrm);
      END;
     END LOOP;

     IF dbv in ('10.1.0')
     THEN

        BEGIN
         EXECUTE IMMEDIATE
           'INSERT INTO sys.sys_tzuv2_temptab 
              SELECT owner, table_name, qualified_col_name, NULL, ''YES''
              FROM ALL_NESTED_TABLE_COLS
              WHERE data_type like ''TIMESTAMP%WITH TIME ZONE''';
       END;

     END IF;

     DBMS_OUTPUT.PUT_LINE('Query sys.sys_tzuv2_temptab Table to see ' ||
                          'if any TIMEZONE data is affected by version 2 ' ||
                          'transition rules');
  END IF;

END;
/

COMMIT
/

Rem=========================================================================
SET SERVEROUTPUT OFF
Rem=========================================================================
