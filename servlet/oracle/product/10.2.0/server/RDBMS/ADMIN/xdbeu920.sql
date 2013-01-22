Rem
Rem $Header: xdbeu920.sql 14-dec-2004.11:51:21 spannala Exp $
Rem
Rem xdbeu920.sql
Rem
Rem Copyright (c) 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      xdbeu920.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    vkapoor     12/14/04 - LRG 1802466. Remove data from xdbconfig.xml 
Rem    spannala    11/05/04 - checking for xdbhi_idx before drop 
Rem    spannala    09/02/04 - spannala_lrg-1734670
Rem    spannala    08/24/04 - Created
Rem

-- First downgrade data to 10.1 release
@@xdbeu101.sql

CREATE OR REPLACE PROCEDURE REMOVE_EXTENSIBLE_OPTIMIZER AS 
  m integer;
BEGIN
  select count(*) into m from xdb.xdb$schema s
  where s.xmldata.schema_url = 'http://xmlns.oracle.com/xdb/stats.xsd';

  IF m != 0 THEN
     exec_stmt_chg_status(990, 'truncate table xdb.XDB$STATS');
     exec_stmt_chg_status(980, 'disassociate statistics from '||
                               'indextypes xdb.xdbhi_idxtyp force');
     exec_stmt_chg_status(970, 'disassociate statistics from' ||
                               ' packages xdb.xdb_funcimpl force');
     exec_stmt_chg_status(960, 'drop type xdb.funcstats');
     drop_schema_chg_status(950, 'http://xmlns.oracle.com/xdb/stats.xsd');
     -- more stuff with status numbers between 950 and 900 may be put here
     -- exec_stmt_chg_status(900, 'select * from dual');
  END IF;
END;
/



Rem Load catxlcr1.sql
@@catxlcr1.sql

-- This function returns true if the downgrade is necessary, false otherwise.
create or replace function lcr_extval_needdwn(schema_url IN VARCHAR2)
  return boolean as
  m integer;
begin
  select count(*) into m from xdb.xdb$element e, xdb.xdb$schema s where
   s.xmldata.schema_url = schema_url
   and ref(s) = e.xmldata.property.parent_schema
   and e.xmldata.property.name = 'extra_attribute_values';
 
  if m > 0 then
    return TRUE;
  else 
    return FALSE;
  end if;
end;
/


create or replace procedure downgrade_lcr as
  lcr_schema_url  varchar2(60);
  cnt             integer;
  sch_urls        xdb.xdb$string_list_t;
  sch_docs        XMLSequenceType;
begin

  lcr_schema_url := lcr$_xml_schema.CONFIGURL;
  select count(*) into cnt from xdb.xdb$schema s
  where s.xmldata.schema_url = lcr_schema_url;

  if cnt > 0 and lcr_extval_needdwn(lcr_schema_url) then

    -- Drop the existing schema. This is going to fail if there are
    -- dependent tables/schemas in which case users have to downgrade using
    -- CopyEvolve.
    dbms_xmlschema.DeleteSchema(lcr$_xml_schema.CONFIGURL,
                                dbms_xmlschema.DELETE_RESTRICT);

    -- Register new schema
    dbms_xmlschema.registerSchema(schemaURL => lcr$_xml_schema.CONFIGURL, 
                                  schemaDoc => lcr$_xml_schema.CONFIGXSD_9204,
                                  local => FALSE,
                                  genTypes => TRUE,
                                  genBean => FALSE,
                                  genTables => FALSE,
                                  force => FALSE);
  end if;
end;
/

create or replace procedure remove_xml_synonyms as
begin
  execute immediate 'DROP SYNONYM xmldom';
  execute immediate 'DROP PUBLIC SYNONYM xmldom';
  execute immediate 'DROP SYNONYM xslprocessor';
  execute immediate 'DROP PUBLIC SYNONYM xslprocessor';
  execute immediate 'DROP SYNONYM xmlparser';
  execute immediate 'DROP PUBLIC SYNONYM xmlparser';
end;
/
show errors;

-- Actually, this function undoes everything from catxdbr.sql
-- and not just resource_view
create or replace procedure remove_resource_view_stuff as
ct number;
begin
  execute immediate 'DROP TRIGGER xdb.xdb_rv_trig';
  execute immediate 'DROP PUBLIC SYNONYM xdb_rvtrig_pkg FORCE';
  execute immediate 'DROP PACKAGE xdb.xdb_rvtrig_pkg';
  execute immediate 'DROP PUBLIC SYNONYM resource_view FORCE';
  execute immediate 'DROP VIEW xdb.resource_view FORCE';
  select count(*) into ct from dba_indexes where owner = 'XDB' and
     INDEX_NAME = 'XDBHI_IDX';
  if ct = 1 then
    execute immediate 'DROP INDEX xdb.xdbhi_idx FORCE';
  end if;
  execute immediate 'DROP INDEXTYPE xdb.xdbhi_idxtyp FORCE';
  execute immediate 'DROP PUBLIC SYNONYM abspath';
  execute immediate 'DROP PUBLIC SYNONYM depth';
  execute immediate 'DROP PUBLIC SYNONYM path';
  execute immediate 'DROP OPERATOR xdb.abspath FORCE';
  execute immediate 'DROP OPERATOR xdb.depth FORCE';
  execute immediate 'DROP OPERATOR xdb.path FORCE';
  execute immediate 'DROP PUBLIC SYNONYM equals_path';
  execute immediate 'DROP PUBLIC SYNONYM under_path';
  execute immediate 'DROP OPERATOR xdb.equals_path FORCE';
  execute immediate 'DROP OPERATOR xdb.under_path FORCE';
  execute immediate 'DROP PACKAGE xdb.xdb_ancop';
  execute immediate 'DROP PACKAGE xdb.xdb_funcimpl';
  execute immediate 'DROP TYPE xdb.xdbhi_im FORCE';
  execute immediate 'DROP TYPE xdb.path_array FORCE';
  execute immediate 'DROP TYPE xdb.path_linkinfo FORCE';
  execute immediate 'DROP LIBRARY xdb.resource_view_lib';
  execute immediate 'DROP LIBRARY xdb.path_view_lib';
end;
/

-- This function undoes everything in catxdbpv.sql
-- and not just path_view
create or replace procedure remove_path_view_stuff as
begin
  execute immediate 'DROP TRIGGER xdb.xdb_pv_trig';
  execute immediate 'DROP PUBLIC SYNONYM xdb_pvtrig_pkg';
  execute immediate 'DROP PACKAGE xdb.xdb_pvtrig_pkg';
  execute immediate 'DROP PUBLIC SYNONYM path_view FORCE';
  execute immediate 'DROP VIEW xdb.path_view FORCE';
  execute immediate 'DROP PUBLIC SYNONYM all_path FORCE';
  execute immediate 'DROP OPERATOR xdb.all_path FORCE';
end;
/
-- This function removes TWO elements from xmlconfig.xml
-- as part of downgrade. This is done to remove PD information
create or replace procedure remove_xdbconfig_data_elements as
  configxml sys.xmltype;
  doc       dbms_xmldom.DOMDocument;
  dn        dbms_xmldom.DOMNode;
  de        dbms_xmldom.DOMElement;
  nl        dbms_xmldom.DOMNodeList;
  sysn      dbms_xmldom.DOMNode;
  syse      dbms_xmldom.DOMElement;
  cn        dbms_xmldom.DOMNode;
  begin
-- Select the resource and set it into the config
  select sys_nc_rowinfo$ into configxml from xdb.xdb$config ;

  doc  := dbms_xmldom.newDOMDocument(configxml);
  dn   := dbms_xmldom.makeNode(doc);
  dn   := dbms_xmldom.getFirstChild(dn);
  de   := dbms_xmldom.makeElement(dn);

  nl   := dbms_xmldom.getChildrenByTagName(de, 'sysconfig');
  sysn := dbms_xmldom.item(nl, 0);
  syse := dbms_xmldom.makeElement(sysn);

  nl   := dbms_xmldom.getChildrenByTagName(syse, 'xdbcore-xobmem-bound');

  if not(dbms_xmldom.isNull(nl)) then
    cn := dbms_xmldom.item(nl, 0);
    if not(dbms_xmldom.isNull(cn)) then
      cn := dbms_xmldom.removeChild(sysn, cn);
    end if;
  end if;

  nl   := dbms_xmldom.getChildrenByTagName(syse, 'xdbcore-loadableunit-size');

  if not(dbms_xmldom.isNull(nl)) then
    cn := dbms_xmldom.item(nl, 0);
    if not(dbms_xmldom.isNull(cn)) then
      cn := dbms_xmldom.removeChild(sysn, cn);
    end if;
  end if;

  dbms_xdb.cfg_update(configxml);
  commit;

end;
/

show errors;
-- On an upgraded instances, the status starts at 1000
select n from xdb.migr9202status;

-- Remove extra data elements from xdbconfig first
CALL remove_xdbconfig_data_elements();

-- First remove the extensible optimizer
CALL remove_extensible_optimizer();

select n from xdb.migr9202status;

-- Remove XDBFolderListing.xsd
CALL drop_schema_chg_status(890,
                      'http://xmlns.oracle.com/xdb/XDBFolderListing.xsd');

-- Downgrade the LCR schema
call exec_stmt_chg_status(850, 'call downgrade_lcr()');

call exec_stmt_chg_status(750, 'drop index xdb.xdb_h_link_child_oid');

select n from xdb.migr9202status;

-- Grant XDB user a bunch of privilges that have been removed in 10i
call exec_stmt_chg_status(540, 'grant select any table to xdb');
call exec_stmt_chg_status(539, 'grant create any trigger to xdb');
call exec_stmt_chg_status(538, 'grant exempt access policy to xdb');
call exec_stmt_chg_status(537, 'grant administer database trigger to xdb');

-- remove the synonyms for xmldom
call exec_stmt_chg_status(530, 'call remove_xml_synonyms()');

-- remove the synonyms for xdb.xdb$string_list_t and revoke the execute on it
-- note that this has to be done after calling downgrade on LCR
call exec_stmt_chg_status(520, 'DROP SYNONYM xdb$string_list_t');
call exec_stmt_chg_status(519, 
     'REVOKE EXECUTE on xdb.xdb$string_list_t from public');

-- remove the 10g objects from db.
call exec_stmt_chg_status(518, 'DROP FUNCTION XDB.GET_XDB_TABLESPACE');
call exec_stmt_chg_status(517, 'DROP PROCEDURE XDB.SETMODFLG');
call exec_stmt_chg_status(516, 'DROP PROCEDURE SET_TABLESPACE');
call exec_stmt_chg_status(515, 'DROP PACKAGE XDB.DBMS_XDBT');
call exec_stmt_chg_status(514, 'DROP PROCEDURE XDB.XDB_DATASTORE_PROC');

select n from xdb.migr9202status;

-- remove path view and resource_view from the system. They will be
-- created properly during the reload.
call exec_stmt_chg_status(510, 'call remove_path_view_stuff()');
call exec_stmt_chg_status(509, 'call remove_resource_view_stuff()');

DROP PROCEDURE remove_extensible_optimizer;
DROP PROCEDURE downgrade_lcr;
DROP FUNCTION  lcr_extval_needdwn;
DROP PROCEDURE remove_xml_synonyms;
DROP PROCEDURE remove_path_view_stuff;
DROP PROCEDURE remove_resource_view_stuff;
DROP PROCEDURE remove_xdbconfig_data_elements;
