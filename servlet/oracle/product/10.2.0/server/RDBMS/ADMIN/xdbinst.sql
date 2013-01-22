Rem
Rem $Header: xdbinst.sql 20-jan-2005.19:43:15 pnath Exp $
Rem
Rem xdbinst.sql
Rem
Rem Copyright (c) 2004, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      xdbinst.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pnath       01/20/05 - pnath_bug-4112707
Rem    pnath       01/19/05 - remove all SET statements 
Rem    pnath       12/08/04 - pnath_bug-3936353
Rem    pnath       12/02/04 - Created
Rem

declare 
  val number;
begin
  select count(*) into val from all_tables where owner = 'SYS' and table_name = 'XDB_INSTALLATION_TAB';
  if val = 0 then
     execute immediate 'create table xdb_installation_tab (owner varchar2(200), object_name varchar2(200), object_type varchar2(200))';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','XDB$STRING_LIST_T','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','DBMS_XMLSCHEMA','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','DBMS_XDBZ','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','DBMS_XDB','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','DBMS_XDBZ0','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','ISXMLTYPETABLE','FUNCTION';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','SET_TABLESPACE','PROCEDURE';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','CHECK_UPGRADE','FUNCTION';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','DBMS_XDBUTIL_INT','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','UNDER_PATH','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','EQUALS_PATH','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','PATH','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','DEPTH','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','ABSPATH','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','RESOURCE_VIEW','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','XDB_RVTRIG_PKG','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','CONTENTSCHEMAIS','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','DBMS_XMLDOM','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','XMLDOM','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','XMLDOM','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','DBMS_XMLPARSER','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','XMLPARSER','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','XMLPARSER','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','DBMS_XSLPROCESSOR','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','XSLPROCESSOR','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','XSLPROCESSOR','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','DBMS_XDB_VERSION','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','ALL_PATH','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','PATH_VIEW','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','XDB_PVTRIG_PKG','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','DBMS_EPG','PACKAGE';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','DBMS_EPG','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','EPG$_AUTH','TABLE';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','EPG$_AUTH_PK','INDEX';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','USER_EPG_DAD_AUTHORIZATION','VIEW';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','USER_EPG_DAD_AUTHORIZATION','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','DBA_EPG_DAD_AUTHORIZATION','VIEW';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','DBA_EPG_DAD_AUTHORIZATION','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','DBA_XML_TABLES','VIEW';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','DBA_XML_TABLES','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','ALL_XML_TABLES','VIEW';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','ALL_XML_TABLES','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','USER_XML_TABLES','VIEW';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','USER_XML_TABLES','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','DBA_XML_TAB_COLS','VIEW';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','DBA_XML_TAB_COLS','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','ALL_XML_TAB_COLS','VIEW';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','ALL_XML_TAB_COLS','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','USER_XML_TAB_COLS','VIEW';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','USER_XML_TAB_COLS','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','DBA_XML_VIEWS','VIEW';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','DBA_XML_VIEWS','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','ALL_XML_VIEWS','VIEW';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','ALL_XML_VIEWS','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','USER_XML_VIEWS','VIEW';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','USER_XML_VIEWS','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','DBA_XML_VIEW_COLS','VIEW';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','DBA_XML_VIEW_COLS','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','ALL_XML_VIEW_COLS','VIEW';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','ALL_XML_VIEW_COLS','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','USER_XML_VIEW_COLS','VIEW';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','USER_XML_VIEW_COLS','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','DBA_XML_SCHEMAS','VIEW';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','DBA_XML_SCHEMAS','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','ALL_XML_SCHEMAS','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','ALL_XML_SCHEMAS2','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','USER_XML_SCHEMAS','VIEW';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','USER_XML_SCHEMAS','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','DBA_XML_INDEXES','VIEW';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','DBA_XML_INDEXES','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','ALL_XML_INDEXES','VIEW';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','ALL_XML_INDEXES','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','USER_XML_INDEXES','VIEW';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','USER_XML_INDEXES','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'PUBLIC','DBMS_XMLINDEX','SYNONYM';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','LCR$_XML_SCHEMA','PACKAGE';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','datetime_format73_T','TYPE';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','anydata72_T','TYPE';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','extra_attribute71_T','TYPE';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','column_value74_T','TYPE';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','extra_attribute_valu77_COLL','TYPE';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','extra_attribute_values76_T','TYPE';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','DDL_LCR75_T','TYPE';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','old_value80_COLL','TYPE';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','old_values79_T','TYPE';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','new_values81_T','TYPE';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','extra_attribute_values82_T','TYPE';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','ROW_LCR78_T','TYPE';
     execute immediate 'insert into xdb_installation_tab values (:1, :2, :3)' using 'SYS','DBMS_REGXDB','PACKAGE';
     commit;
   end if;
exception
   when others then
      select count(*) into val from all_tables where owner = 'SYS' and table_name = 'XDB_INSTALLATION_TAB';
      if val = 1 then
         execute immediate 'drop table xdb_installation_tab';
      end if;
end;
/
