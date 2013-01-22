Rem
Rem $Header: catxdbv.sql 20-may-2005.10:53:07 pnath Exp $
Rem
Rem catxdbv.sql
Rem
Rem Copyright (c) 2001, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catxdbv.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pnath       05/18/05 - add view for bug 4376605 
Rem    thbaby      01/20/05 - Add HIER_TYPE column to XXX_XML_SCHEMAS
Rem    sichandr    07/19/04 - add xmlindex catalog views 
Rem    spannala    05/24/04 - upgrade might disable xdbhi_idx, rebuild it 
Rem    najain      12/08/03 - add xml_schema_name_present
Rem    njalali     05/12/03 - added all_xml_schemas2
Rem    amanikut    04/29/03 - 2917744 : include NSB cols/views in catalog views
Rem    amanikut    04/29/03 - bug 2917744 : include NSB XVs in USER_XML_VIEWS
Rem    njalali     03/26/03 - removing connect statement and recompiles
Rem    abagrawa    04/02/03 - Add comment to keep in sync
Rem    abagrawa    10/17/02 - Fix element name for element refs
Rem    njalali     08/13/02 - removing SET statements
Rem    ataracha    08/12/02 - compile KU$ views after catmetx
Rem    sichandr    02/25/02 - add int/qualified schema
Rem    sichandr    02/07/02 - fix hex conversions
Rem    gviswana    01/29/02 - CREATE OR REPLACE SYNONYM
Rem    spannala    01/08/02 - correcting name in comments
Rem    lbarton     01/09/02 - add catmetx.sql
Rem    nmontoya    12/12/01 - remove set echo on
Rem    mkrishna    11/01/01 - change xmldata to xmldata
Rem    sichandr    11/28/01 - catalog view fixes
Rem    mkrishna    09/26/01 - fix catxdbv
Rem    sichandr    09/05/01 - add xxx_XML_SCHEMAS and xxx_XML_VIEWS
Rem    mkrishna    08/02/01 - Merged mkrishna_bug-1753473
Rem    mkrishna    07/29/01 - Created
Rem

create or replace force view DBA_XML_TABLES
 (OWNER, TABLE_NAME, XMLSCHEMA, SCHEMA_OWNER, ELEMENT_NAME, STORAGE_TYPE)
 as select u.name, o.name, null, null, null,
    decode(bitand(opq.flags,5),1,'OBJECT-RELATIONAL','CLOB')
 from sys.opqtype$ opq, sys.tab$ t, sys.user$ u, sys.obj$ o, 
      sys.coltype$ ac, sys.col$ tc
 where o.owner# = u.user# 
  and o.obj# = t.obj#
  and bitand(t.property, 1) = 1
  and t.obj# = tc.obj#
  and tc.name = 'SYS_NC_ROWINFO$'
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and ac.toid = '00000000000000000000000000020100'
  and tc.intcol# =  opq.intcol# 
  and tc.obj# =  opq.obj#
  and bitand(opq.flags,2) = 0
 union all
 select u.name, o.name, schm.xmldata.schema_url, schm.xmldata.schema_owner,
        decode(xel.xmldata.property.name, null, 
        xel.xmldata.property.propref_name.name, xel.xmldata.property.name),
        decode(bitand(opq.flags,5),1,'OBJECT-RELATIONAL','CLOB')
 from xdb.xdb$element xel, xdb.xdb$schema schm, sys.opqtype$ opq,
      sys.tab$ t, sys.user$ u, sys.obj$ o, sys.coltype$ ac, sys.col$ tc
where o.owner# = u.user# 
  and o.obj# = t.obj#
  and bitand(t.property, 1) = 1
  and t.obj# = tc.obj#
  and tc.name = 'SYS_NC_ROWINFO$'
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and ac.toid = '00000000000000000000000000020100'
  and tc.intcol# =  opq.intcol# 
  and tc.obj# =  opq.obj#
  and bitand(opq.flags,2) = 2
  and opq.schemaoid =  schm.sys_nc_oid$ 
  and ref(schm) =  xel.xmldata.property.parent_schema 
  and opq.elemnum =  xel.xmldata.property.prop_number
/
grant select on dba_xml_tables to select_catalog_role;

create or replace public synonym dba_xml_tables for dba_xml_tables; 

comment on table DBA_XML_TABLES is
'Description of all XML tables in the database'
/
comment on column DBA_XML_TABLES.OWNER is
'Name of the owner of the XML table'
/
comment on column DBA_XML_TABLES.TABLE_NAME is
'Name of the XML table'
/
comment on column DBA_XML_TABLES.XMLSCHEMA is
'Name of the XMLSchema that is used for the table definition'
/
comment on column DBA_XML_TABLES.SCHEMA_OWNER is
'Name of the owner of the XMLSchema used for table definition'
/
comment on column DBA_XML_TABLES.ELEMENT_NAME is
'Name XMLSChema element that is used for the table' 
/
comment on column DBA_XML_TABLES.STORAGE_TYPE is
'Type of storage option for the XMLtype data'
/

create or replace force view ALL_XML_TABLES
 (OWNER, TABLE_NAME, XMLSCHEMA, SCHEMA_OWNER, ELEMENT_NAME, STORAGE_TYPE)
 as 
  select u.name, o.name, null, null, null,
    decode(bitand(opq.flags,5),1,'OBJECT-RELATIONAL','CLOB')
 from sys.opqtype$ opq, sys.tab$ t, sys.user$ u, sys.obj$ o, 
      sys.coltype$ ac, sys.col$ tc
 where o.owner# = u.user# 
  and o.obj# = t.obj#
  and bitand(t.property, 1) = 1
  and t.obj# = tc.obj#
  and tc.name = 'SYS_NC_ROWINFO$'
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and ac.toid = '00000000000000000000000000020100'
  and tc.intcol# =  opq.intcol# 
  and tc.obj# =  opq.obj#
  and bitand(opq.flags,2) = 0
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
 union all
 select u.name, o.name, schm.xmldata.schema_url, schm.xmldata.schema_owner,
 decode(xel.xmldata.property.name, null, 
        xel.xmldata.property.propref_name.name, xel.xmldata.property.name),
  decode(bitand(opq.flags,5),1,'OBJECT-RELATIONAL','CLOB')
from xdb.xdb$element xel, xdb.xdb$schema schm, sys.opqtype$ opq,
      sys.tab$ t, sys.user$ u, sys.obj$ o, sys.coltype$ ac, sys.col$ tc
where o.owner# = u.user#
  and o.obj# = t.obj#
  and bitand(t.property, 1) = 1
  and t.obj# = tc.obj#
  and tc.name = 'SYS_NC_ROWINFO$'
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and ac.toid = '00000000000000000000000000020100'
  and tc.intcol# =  opq.intcol# 
  and tc.obj# =  opq.obj#
  and opq.schemaoid =  schm.sys_nc_oid$ 
  and bitand(opq.flags,2) = 2
  and ref(schm) =  xel.xmldata.property.parent_schema 
  and opq.elemnum =  xel.xmldata.property.prop_number
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
/
grant select on all_xml_tables to public;

create or replace public synonym all_xml_tables for all_xml_tables; 

comment on table ALL_XML_TABLES is
'Description of the all XMLType tables that the user has privileges on'
/
comment on column ALL_XML_TABLES.OWNER is
'Owner of the table '
/
comment on column ALL_XML_TABLES.TABLE_NAME is
'Name of the table '
/
comment on column ALL_XML_TABLES.XMLSCHEMA is
'Name of the XMLSchema that is used for the table definition'
/
comment on column ALL_XML_TABLES.SCHEMA_OWNER is
'Name of the owner of the XMLSchema used for table definition'
/
comment on column ALL_XML_TABLES.ELEMENT_NAME is
'Name XMLSChema element that is used for the table' 
/
comment on column ALL_XML_TABLES.STORAGE_TYPE is
'Type of storage option for the XMLtype data'
/

create or replace force view USER_XML_TABLES
 (TABLE_NAME, XMLSCHEMA, SCHEMA_OWNER, ELEMENT_NAME, STORAGE_TYPE)
 as select o.name, null, null, null,
    decode(bitand(opq.flags,5),1,'OBJECT-RELATIONAL','CLOB')
from sys.opqtype$ opq, sys.tab$ t, sys.obj$ o, sys.coltype$ ac, sys.col$ tc
where o.owner# = userenv('SCHEMAID')
  and o.obj# = t.obj#
  and bitand(t.property, 1) = 1
  and t.obj# = tc.obj#
  and tc.name = 'SYS_NC_ROWINFO$'
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and ac.toid = '00000000000000000000000000020100'
  and tc.intcol# =  opq.intcol# 
  and tc.obj# =  opq.obj#
  and bitand(opq.flags,2) = 0
 union all
  select o.name, schm.xmldata.schema_url, schm.xmldata.schema_owner,
decode(xel.xmldata.property.name, null, 
        xel.xmldata.property.propref_name.name, xel.xmldata.property.name),
  decode(bitand(opq.flags,5),1,'OBJECT-RELATIONAL','CLOB')
from xdb.xdb$element xel, xdb.xdb$schema schm, sys.opqtype$ opq,
      sys.tab$ t, sys.obj$ o, sys.coltype$ ac, sys.col$ tc
where o.owner# = userenv('SCHEMAID')
  and o.obj# = t.obj#
  and bitand(t.property, 1) = 1
  and t.obj# = tc.obj#
  and tc.name = 'SYS_NC_ROWINFO$'
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and ac.toid = '00000000000000000000000000020100'
  and tc.intcol# =  opq.intcol# 
  and tc.obj# =  opq.obj# 
  and opq.schemaoid =  schm.sys_nc_oid$ 
  and bitand(opq.flags,2) = 2
  and ref(schm) =  xel.xmldata.property.parent_schema 
  and opq.elemnum =  xel.xmldata.property.prop_number
/
grant select on user_xml_tables to public;

create or replace public synonym user_xml_tables for user_xml_tables; 

comment on table USER_XML_TABLES is
'Description of the user''s own XMLType tables'
/
comment on column USER_XML_TABLES.TABLE_NAME is
'Name of the XMLType table'
/
comment on column USER_XML_TABLES.XMLSCHEMA is
'Name of the XMLSchema that is used for the table definition'
/
comment on column USER_XML_TABLES.SCHEMA_OWNER is
'Name of the owner of the XMLSchema used for table definition'
/
comment on column USER_XML_TABLES.ELEMENT_NAME is
'Name XMLSChema element that is used for the table' 
/
comment on column USER_XML_TABLES.STORAGE_TYPE is
'Type of storage option for the XMLtype data'
/

create or replace force view DBA_XML_TAB_COLS
 (OWNER, TABLE_NAME, COLUMN_NAME, XMLSCHEMA, SCHEMA_OWNER,
  ELEMENT_NAME, STORAGE_TYPE)
 as select u.name, o.name, 
   decode(bitand(tc.property, 1), 1, attr.name, tc.name),
   null, null, null,
   decode(bitand(opq.flags,5),1,'OBJECT-RELATIONAL','CLOB')
from sys.opqtype$ opq, sys.tab$ t, sys.user$ u, sys.obj$ o, 
     sys.coltype$ ac, sys.col$ tc, sys.attrcol$ attr
where o.owner# = u.user# 
  and o.obj# = t.obj#
  and t.obj# = tc.obj#
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and tc.obj#    = attr.obj#(+)
  and tc.intcol# = attr.intcol#(+)
  and tc.name != 'SYS_NC_ROWINFO$'
  and ac.toid = '00000000000000000000000000020100'
  and tc.intcol# =  opq.intcol# 
  and tc.obj# =  opq.obj#
  and bitand(opq.flags,2) = 0
 union all
  select u.name, o.name, 
   decode(bitand(tc.property, 1), 1, attr.name, tc.name),
   schm.xmldata.schema_url, schm.xmldata.schema_owner, 
decode(xel.xmldata.property.name, null, 
        xel.xmldata.property.propref_name.name, xel.xmldata.property.name),
    decode(bitand(opq.flags,5),1,'OBJECT-RELATIONAL','CLOB')
from xdb.xdb$element xel, xdb.xdb$schema schm, sys.opqtype$ opq,
      sys.tab$ t, sys.user$ u, sys.obj$ o, sys.coltype$ ac, sys.col$ tc,
      sys.attrcol$ attr
where o.owner# = u.user# 
  and o.obj# = t.obj#
  and t.obj# = tc.obj#
  and tc.obj# = ac.obj#
  and ac.toid = '00000000000000000000000000020100'
  and tc.intcol# = ac.intcol#
  and tc.obj#    = attr.obj#(+)
  and tc.intcol# = attr.intcol#(+)
  and tc.name != 'SYS_NC_ROWINFO$'
  and tc.intcol# =  opq.intcol# 
  and tc.obj# =  opq.obj# 
  and opq.schemaoid =  schm.sys_nc_oid$ 
  and bitand(opq.flags,2) = 2
  and ref(schm) =  xel.xmldata.property.parent_schema 
  and opq.elemnum =  xel.xmldata.property.prop_number
/
grant select on dba_xml_tab_cols to select_catalog_role;

create or replace public synonym dba_xml_tab_cols for dba_xml_tab_cols; 

comment on table DBA_XML_TAB_COLS is
'Description of all XML tables in the database'
/
comment on column DBA_XML_TAB_COLS.OWNER is
'Name of the owner of the XML table'
/
comment on column DBA_XML_TAB_COLS.TABLE_NAME is
'Name of the XML table'
/
comment on column DBA_XML_TAB_COLS.COLUMN_NAME is
'Name of the XML table column'
/
comment on column DBA_XML_TAB_COLS.XMLSCHEMA is
'Name of the XMLSchema that is used for the table definition'
/
comment on column DBA_XML_TAB_COLS.SCHEMA_OWNER is
'Name of the owner of the XMLSchema used for table definition'
/
comment on column DBA_XML_TAB_COLS.ELEMENT_NAME is
'Name XMLSChema element that is used for the table' 
/
comment on column DBA_XML_TAB_COLS.STORAGE_TYPE is
'Type of storage option for the XMLtype data'
/

create or replace force view ALL_XML_TAB_COLS
 (OWNER, TABLE_NAME, COLUMN_NAME, XMLSCHEMA, SCHEMA_OWNER,
  ELEMENT_NAME, STORAGE_TYPE)
  as select u.name, o.name, 
   decode(bitand(tc.property, 1), 1, attr.name, tc.name),null,null,null,
   decode(bitand(opq.flags,5),1,'OBJECT-RELATIONAL','CLOB')
from  sys.opqtype$ opq,
      sys.tab$ t, sys.user$ u, sys.obj$ o, sys.coltype$ ac, sys.col$ tc, 
      sys.attrcol$ attr
where o.owner# = u.user#
  and o.obj# = t.obj#
  and t.obj# = tc.obj#
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and ac.toid = '00000000000000000000000000020100'
  and tc.intcol# = opq.intcol# 
  and tc.obj# =  opq.obj# 
  and tc.obj#    = attr.obj#(+)
  and tc.intcol# = attr.intcol#(+)
  and bitand(opq.flags,2) = 0
  and tc.name != 'SYS_NC_ROWINFO$'
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
  union all
 select u.name, o.name, 
  decode(bitand(tc.property, 1), 1, attr.name, tc.name),
  schm.xmldata.schema_url, schm.xmldata.schema_owner, 
decode(xel.xmldata.property.name, null, 
        xel.xmldata.property.propref_name.name, xel.xmldata.property.name),
    decode(bitand(opq.flags,5),1,'OBJECT-RELATIONAL','CLOB')
 from xdb.xdb$element xel, xdb.xdb$schema schm, sys.opqtype$ opq,
      sys.tab$ t, sys.user$ u, sys.obj$ o, sys.coltype$ ac, sys.col$ tc, 
      sys.attrcol$ attr
 where o.owner# = u.user#
  and o.obj# = t.obj#
  and t.obj# = tc.obj#
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and ac.toid = '00000000000000000000000000020100'
  and tc.intcol# = opq.intcol# 
  and tc.obj# =  opq.obj# 
  and tc.obj#    = attr.obj#(+)
  and tc.intcol# = attr.intcol#(+)
  and tc.name != 'SYS_NC_ROWINFO$'
  and opq.schemaoid =  schm.sys_nc_oid$ 
  and ref(schm) =  xel.xmldata.property.parent_schema 
  and opq.elemnum =  xel.xmldata.property.prop_number
  and bitand(opq.flags,2) = 2
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
/
grant select on all_xml_tab_cols to public;

create or replace public synonym all_xml_tab_cols for all_xml_tab_cols; 

comment on table ALL_XML_TAB_COLS is
'Description of the all XMLType tables that the user has privileges on'
/
comment on column ALL_XML_TAB_COLS.OWNER is
'Owner of the table '
/
comment on column ALL_XML_TAB_COLS.TABLE_NAME is
'Name of the table '
/
comment on column ALL_XML_TAB_COLS.XMLSCHEMA is
'Name of the XMLSchema that is used for the table definition'
/
comment on column ALL_XML_TAB_COLS.SCHEMA_OWNER is
'Name of the owner of the XMLSchema used for table definition'
/
comment on column ALL_XML_TAB_COLS.ELEMENT_NAME is
'Name XMLSChema element that is used for the table' 
/
comment on column ALL_XML_TAB_COLS.STORAGE_TYPE is
'Type of storage option for the XMLtype data'
/

create or replace force view USER_XML_TAB_COLS 
 (TABLE_NAME, COLUMN_NAME, XMLSCHEMA, SCHEMA_OWNER, ELEMENT_NAME, STORAGE_TYPE)
 as select o.name, 
   decode(bitand(tc.property, 1), 1, attr.name, tc.name),null, null, null,
   decode(bitand(opq.flags,5),1,'OBJECT-RELATIONAL','CLOB')
from  sys.opqtype$ opq,
      sys.tab$ t, sys.obj$ o, sys.coltype$ ac, sys.col$ tc,
      sys.attrcol$ attr
where o.owner# = userenv('SCHEMAID')
  and o.obj# = t.obj#
  and t.obj# = tc.obj#
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and ac.toid = '00000000000000000000000000020100'
  and tc.intcol# =  opq.intcol# 
  and tc.obj# =  opq.obj# 
  and tc.obj#    = attr.obj#(+)
  and tc.intcol# = attr.intcol#(+)
  and tc.name != 'SYS_NC_ROWINFO$'
  and bitand(opq.flags,2) = 0
  union all
 select o.name, 
   decode(bitand(tc.property, 1), 1, attr.name, tc.name),
   schm.xmldata.schema_url, schm.xmldata.schema_owner, 
decode(xel.xmldata.property.name, null, 
        xel.xmldata.property.propref_name.name, xel.xmldata.property.name),
    decode(bitand(opq.flags,5),1,'OBJECT-RELATIONAL','CLOB')
 from xdb.xdb$element xel, xdb.xdb$schema schm, sys.opqtype$ opq,
      sys.tab$ t, sys.obj$ o, sys.coltype$ ac, sys.col$ tc,
      sys.attrcol$ attr
 where o.owner# = userenv('SCHEMAID')
  and o.obj# = t.obj#
  and t.obj# = tc.obj#
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and ac.toid = '00000000000000000000000000020100'
  and tc.intcol# =  opq.intcol# 
  and tc.obj# =  opq.obj# 
  and tc.obj#    = attr.obj#(+)
  and tc.intcol# = attr.intcol#(+)
  and bitand(opq.flags,2) = 2
  and opq.schemaoid =  schm.sys_nc_oid$ 
  and ref(schm) =  xel.xmldata.property.parent_schema 
  and opq.elemnum =  xel.xmldata.property.prop_number
/
grant select on user_xml_tab_cols to public;

create or replace public synonym user_xml_tab_cols for user_xml_tab_cols; 

comment on table USER_XML_TAB_COLS is
'Description of the user''s own XMLType tables'
/
comment on column USER_XML_TAB_COLS.TABLE_NAME is
'Name of the XMLType table'
/
comment on column USER_XML_TAB_COLS.XMLSCHEMA is
'Name of the XMLSchema that is used for the table definition'
/
comment on column USER_XML_TAB_COLS.SCHEMA_OWNER is
'Name of the owner of the XMLSchema used for table definition'
/
comment on column USER_XML_TAB_COLS.ELEMENT_NAME is
'Name XMLSChema element that is used for the table' 
/
comment on column USER_XML_TAB_COLS.STORAGE_TYPE is
'Type of storage option for the XMLtype data'
/

create or replace force view DBA_XML_VIEWS
 (OWNER, VIEW_NAME, XMLSCHEMA, SCHEMA_OWNER, ELEMENT_NAME)
 as 
select u.name, o.name, null, null, null
 from sys.opqtype$ opq, sys.view$ v, sys.user$ u, sys.obj$ o, 
      sys.coltype$ ac, sys.col$ tc
 where o.owner# = u.user# 
  and o.obj# = v.obj#
  and bitand(v.property, 1) = 1
  and v.obj# = tc.obj#
  and tc.name = 'SYS_NC_ROWINFO$'
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and ac.toid = '00000000000000000000000000020100'
  and tc.intcol# =  opq.intcol# 
  and tc.obj# =  opq.obj#
  and bitand(opq.flags,2) = 0
 union all
  select u.name, o.name, schm.xmldata.schema_url, schm.xmldata.schema_owner,
decode(xel.xmldata.property.name, null, 
        xel.xmldata.property.propref_name.name, xel.xmldata.property.name)
from xdb.xdb$element xel, xdb.xdb$schema schm, sys.opqtype$ opq,
      sys.view$ v, sys.user$ u, sys.obj$ o, sys.coltype$ ac, sys.col$ tc
where o.owner# = u.user# 
  and o.obj# = v.obj#
  and bitand(v.property, 1) = 1
  and v.obj# = tc.obj#
  and tc.name = 'SYS_NC_ROWINFO$'
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and ac.toid = '00000000000000000000000000020100'
  and tc.intcol# =  opq.intcol# 
  and tc.obj# =  opq.obj# 
  and bitand(opq.flags,2) = 2
  and opq.schemaoid =  schm.sys_nc_oid$ 
  and ref(schm) =  xel.xmldata.property.parent_schema 
  and opq.elemnum =  xel.xmldata.property.prop_number
/
grant select on dba_xml_views to select_catalog_role;

create or replace public synonym dba_xml_views for dba_xml_views; 

comment on table DBA_XML_VIEWS is
'Description of all XML views in the database'
/
comment on column DBA_XML_VIEWS.OWNER is
'Name of the owner of the XML view'
/
comment on column DBA_XML_VIEWS.VIEW_NAME is
'Name of the XML view'
/
comment on column DBA_XML_VIEWS.XMLSCHEMA is
'Name of the XMLSchema that is used for the view definition'
/
comment on column DBA_XML_VIEWS.SCHEMA_OWNER is
'Name of the owner of the XMLSchema used for table definition'
/
comment on column DBA_XML_VIEWS.ELEMENT_NAME is
'Name XMLSChema element that is used for the view' 
/

create or replace force view ALL_XML_VIEWS
 (OWNER, VIEW_NAME, XMLSCHEMA, SCHEMA_OWNER, ELEMENT_NAME)
 as 
 select u.name, o.name, null, null, null
 from sys.opqtype$ opq,
      sys.view$ v, sys.user$ u, sys.obj$ o, sys.coltype$ ac, sys.col$ tc
 where o.owner# = u.user#
  and o.obj# = v.obj#
  and bitand(v.property, 1) = 1
  and v.obj# = tc.obj#
  and tc.name = 'SYS_NC_ROWINFO$'
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and ac.toid = '00000000000000000000000000020100'
  and tc.intcol# =  opq.intcol# 
  and tc.obj# =  opq.obj# 
  and bitand(opq.flags,2) = 0
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
 union all
 select u.name, o.name, schm.xmldata.schema_url, schm.xmldata.schema_owner,
   decode(xel.xmldata.property.name, null, 
        xel.xmldata.property.propref_name.name, xel.xmldata.property.name)
 from xdb.xdb$element xel, xdb.xdb$schema schm, sys.opqtype$ opq,
      sys.view$ v, sys.user$ u, sys.obj$ o, sys.coltype$ ac, sys.col$ tc
 where o.owner# = u.user#
  and o.obj# = v.obj#
  and bitand(v.property, 1) = 1
  and v.obj# = tc.obj#
  and tc.name = 'SYS_NC_ROWINFO$'
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and ac.toid = '00000000000000000000000000020100'
  and tc.intcol# =  opq.intcol# 
  and tc.obj# =  opq.obj# 
  and opq.schemaoid =  schm.sys_nc_oid$ 
  and ref(schm) =  xel.xmldata.property.parent_schema 
  and opq.elemnum =  xel.xmldata.property.prop_number
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
/
grant select on all_xml_views to public;

create or replace public synonym all_xml_views for all_xml_views; 

comment on table ALL_XML_VIEWS is
'Description of the all XMLType views that the user has privileges on'
/
comment on column ALL_XML_VIEWS.OWNER is
'Owner of the view '
/
comment on column ALL_XML_VIEWS.VIEW_NAME is
'Name of the view '
/
comment on column ALL_XML_VIEWS.XMLSCHEMA is
'Name of the XMLSchema that is used for the view definition'
/
comment on column ALL_XML_VIEWS.SCHEMA_OWNER is
'Name of the owner of the XMLSchema used for table definition'
/
comment on column ALL_XML_VIEWS.ELEMENT_NAME is
'Name XMLSChema element that is used for the view' 
/

create or replace force view USER_XML_VIEWS
 (VIEW_NAME, XMLSCHEMA, SCHEMA_OWNER, ELEMENT_NAME)
 as
 select o.name, null, null, null
from sys.opqtype$ opq,
      sys.view$ v, sys.obj$ o, sys.coltype$ ac, sys.col$ tc
where o.owner# = userenv('SCHEMAID')
  and o.obj# = v.obj#
  and bitand(v.property, 1) = 1
  and v.obj# = tc.obj#
  and tc.name = 'SYS_NC_ROWINFO$'
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and ac.toid = '00000000000000000000000000020100'
  and tc.intcol# =  opq.intcol# 
  and tc.obj# =  opq.obj# 
  and bitand(opq.flags,2) = 0
union all
 select o.name, schm.xmldata.schema_url, schm.xmldata.schema_owner,
decode(xel.xmldata.property.name, null, 
        xel.xmldata.property.propref_name.name, xel.xmldata.property.name)
from xdb.xdb$element xel, xdb.xdb$schema schm, sys.opqtype$ opq,
      sys.view$ v, sys.obj$ o, sys.coltype$ ac, sys.col$ tc
where o.owner# = userenv('SCHEMAID')
  and o.obj# = v.obj#
  and bitand(v.property, 1) = 1
  and v.obj# = tc.obj#
  and tc.name = 'SYS_NC_ROWINFO$'
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and ac.toid = '00000000000000000000000000020100'
  and tc.intcol# =  opq.intcol# 
  and tc.obj# =  opq.obj# 
  and opq.schemaoid =  schm.sys_nc_oid$ 
  and ref(schm) =  xel.xmldata.property.parent_schema 
  and opq.elemnum =  xel.xmldata.property.prop_number
/
grant select on user_xml_views to public;

create or replace public synonym user_xml_views for user_xml_views; 

comment on table USER_XML_VIEWS is
'Description of the user''s own XMLType views'
/
comment on column USER_XML_VIEWS.VIEW_NAME is
'Name of the XMLType view'
/
comment on column USER_XML_VIEWS.XMLSCHEMA is
'Name of the XMLSchema that is used for the view definition'
/
comment on column USER_XML_VIEWS.SCHEMA_OWNER is
'Name of the owner of the XMLSchema used for table definition'
/
comment on column USER_XML_VIEWS.ELEMENT_NAME is
'Name XMLSChema element that is used for the view' 
/
create or replace force view DBA_XML_VIEW_COLS
 (OWNER, VIEW_NAME, COLUMN_NAME, XMLSCHEMA, SCHEMA_OWNER, ELEMENT_NAME)
 as 
select u.name, o.name, 
   decode(bitand(tc.property, 1), 1, attr.name, tc.name),
   null, null, null
from  sys.opqtype$ opq,
      sys.view$ v, sys.user$ u, sys.obj$ o, sys.coltype$ ac, sys.col$ tc,
      sys.attrcol$ attr
where o.owner# = u.user# 
  and o.obj# = v.obj#
  and bitand(v.property, 1) = 1
  and v.obj# = tc.obj#
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and tc.obj#    = attr.obj#(+)
  and tc.intcol# = attr.intcol#(+)
  and ac.toid = '00000000000000000000000000020100'
  and tc.intcol# =  opq.intcol# 
  and tc.obj# =  opq.obj# 
  and bitand(opq.flags,2) = 0
union all
select u.name, o.name, 
   decode(bitand(tc.property, 1), 1, attr.name, tc.name),
   schm.xmldata.schema_url, schm.xmldata.schema_owner, 
decode(xel.xmldata.property.name, null, 
        xel.xmldata.property.propref_name.name, xel.xmldata.property.name)
from xdb.xdb$element xel, xdb.xdb$schema schm, sys.opqtype$ opq,
      sys.view$ v, sys.user$ u, sys.obj$ o, sys.coltype$ ac, sys.col$ tc,
      sys.attrcol$ attr
where o.owner# = u.user# 
  and o.obj# = v.obj#
  and bitand(v.property, 1) = 1
  and v.obj# = tc.obj#
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and tc.obj#    = attr.obj#(+)
  and tc.intcol# = attr.intcol#(+)
  and ac.toid = '00000000000000000000000000020100'
  and tc.intcol# =  opq.intcol# 
  and tc.obj# =  opq.obj# 
  and opq.schemaoid =  schm.sys_nc_oid$ 
  and ref(schm) =  xel.xmldata.property.parent_schema 
  and opq.elemnum =  xel.xmldata.property.prop_number
/
grant select on dba_xml_view_cols to select_catalog_role;

create or replace public synonym dba_xml_view_cols for dba_xml_view_cols; 

comment on table DBA_XML_VIEW_COLS is
'Description of all XML views in the database'
/
comment on column DBA_XML_VIEW_COLS.OWNER is
'Name of the owner of the XML view'
/
comment on column DBA_XML_VIEW_COLS.VIEW_NAME is
'Name of the XML view'
/
comment on column DBA_XML_VIEW_COLS.COLUMN_NAME is
'Name of the XML view column'
/
comment on column DBA_XML_VIEW_COLS.XMLSCHEMA is
'Name of the XMLSchema that is used for the view definition'
/
comment on column DBA_XML_VIEW_COLS.SCHEMA_OWNER is
'Name of the owner of the XMLSchema used for table definition'
/
comment on column DBA_XML_VIEW_COLS.ELEMENT_NAME is
'Name XMLSChema element that is used for the view' 
/

create or replace force view ALL_XML_VIEW_COLS
 (OWNER, VIEW_NAME, COLUMN_NAME, XMLSCHEMA, SCHEMA_OWNER, ELEMENT_NAME)
 as 
 select u.name, o.name, 
  decode(bitand(tc.property, 1), 1, attr.name, tc.name),
  null, null, null
from sys.opqtype$ opq,
      sys.view$ v, sys.user$ u, sys.obj$ o, sys.coltype$ ac, sys.col$ tc, 
      sys.attrcol$ attr
where o.owner# = u.user#
  and o.obj# = v.obj#
  and bitand(v.property, 1) = 1
  and v.obj# = tc.obj#
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and ac.toid = '00000000000000000000000000020100'
  and tc.intcol# = opq.intcol# 
  and tc.obj# =  opq.obj# 
  and tc.obj#    = attr.obj#(+)
  and tc.intcol# = attr.intcol#(+)
  and bitand(opq.flags,2) = 0
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY VIEWLE */,
                                       -47 /* SELECT ANY VIEWLE */,
                                       -48 /* INSERT ANY VIEWLE */,
                                       -49 /* UPDATE ANY VIEWLE */,
                                       -50 /* DELETE ANY VIEWLE */)
                 )
      )
union all
select u.name, o.name, 
  decode(bitand(tc.property, 1), 1, attr.name, tc.name),
  schm.xmldata.schema_url, schm.xmldata.schema_owner, 
decode(xel.xmldata.property.name, null, 
        xel.xmldata.property.propref_name.name, xel.xmldata.property.name)
from xdb.xdb$element xel, xdb.xdb$schema schm, sys.opqtype$ opq,
      sys.view$ v, sys.user$ u, sys.obj$ o, sys.coltype$ ac, sys.col$ tc, 
      sys.attrcol$ attr
where o.owner# = u.user#
  and o.obj# = v.obj#
  and bitand(v.property, 1) = 1
  and v.obj# = tc.obj#
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and ac.toid = '00000000000000000000000000020100'
  and tc.intcol# = opq.intcol# 
  and tc.obj# =  opq.obj# 
  and tc.obj#    = attr.obj#(+)
  and tc.intcol# = attr.intcol#(+)
  and opq.schemaoid =  schm.sys_nc_oid$ 
  and ref(schm) =  xel.xmldata.property.parent_schema 
  and opq.elemnum =  xel.xmldata.property.prop_number
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY VIEWLE */,
                                       -47 /* SELECT ANY VIEWLE */,
                                       -48 /* INSERT ANY VIEWLE */,
                                       -49 /* UPDATE ANY VIEWLE */,
                                       -50 /* DELETE ANY VIEWLE */)
                 )
      )
/
grant select on all_xml_view_cols to public;

create or replace public synonym all_xml_view_cols for all_xml_view_cols; 

comment on table ALL_XML_VIEW_COLS is
'Description of the all XMLType views that the user has privileges on'
/
comment on column ALL_XML_VIEW_COLS.OWNER is
'Owner of the view '
/
comment on column ALL_XML_VIEW_COLS.VIEW_NAME is
'Name of the view '
/
comment on column ALL_XML_VIEW_COLS.XMLSCHEMA is
'Name of the XMLSchema that is used for the view definition'
/
comment on column ALL_XML_VIEW_COLS.SCHEMA_OWNER is
'Name of the owner of the XMLSchema used for table definition'
/
comment on column ALL_XML_VIEW_COLS.ELEMENT_NAME is
'Name XMLSChema element that is used for the view' 
/

create or replace force view USER_XML_VIEW_COLS 
 (VIEW_NAME, COLUMN_NAME, XMLSCHEMA, SCHEMA_OWNER, ELEMENT_NAME)
 as 
select o.name, 
   decode(bitand(tc.property, 1), 1, attr.name, tc.name),
   null, null, null
from  sys.opqtype$ opq,
      sys.view$ v, sys.obj$ o, sys.coltype$ ac, sys.col$ tc,
      sys.attrcol$ attr
where o.owner# = userenv('SCHEMAID')
  and o.obj# = v.obj#
  and bitand(v.property, 1) = 1
  and v.obj# = tc.obj#
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and ac.toid = '00000000000000000000000000020100'
  and tc.intcol# =  opq.intcol# 
  and tc.obj# =  opq.obj# 
  and tc.obj#    = attr.obj#(+)
  and tc.intcol# = attr.intcol#(+)
  and bitand(opq.flags,2) = 0
union all
select o.name, 
   decode(bitand(tc.property, 1), 1, attr.name, tc.name),
   schm.xmldata.schema_url, schm.xmldata.schema_owner, 
decode(xel.xmldata.property.name, null, 
        xel.xmldata.property.propref_name.name, xel.xmldata.property.name)
from xdb.xdb$element xel, xdb.xdb$schema schm, sys.opqtype$ opq,
      sys.view$ v, sys.obj$ o, sys.coltype$ ac, sys.col$ tc,
      sys.attrcol$ attr
where o.owner# = userenv('SCHEMAID')
  and o.obj# = v.obj#
  and bitand(v.property, 1) = 1
  and v.obj# = tc.obj#
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and ac.toid = '00000000000000000000000000020100'
  and tc.intcol# =  opq.intcol# 
  and tc.obj# =  opq.obj# 
  and tc.obj#    = attr.obj#(+)
  and tc.intcol# = attr.intcol#(+)
  and opq.schemaoid =  schm.sys_nc_oid$ 
  and ref(schm) =  xel.xmldata.property.parent_schema 
  and opq.elemnum =  xel.xmldata.property.prop_number
/
grant select on user_xml_view_cols to public;

create or replace public synonym user_xml_view_cols for user_xml_view_cols; 

comment on table USER_XML_VIEW_COLS is
'Description of the user''s own XMLType views'
/
comment on column USER_XML_VIEW_COLS.VIEW_NAME is
'Name of the XMLType view'
/
comment on column USER_XML_VIEW_COLS.XMLSCHEMA is
'Name of the XMLSchema that is used for the view definition'
/
comment on column USER_XML_VIEW_COLS.SCHEMA_OWNER is
'Name of the owner of the XMLSchema used for table definition'
/
comment on column USER_XML_VIEW_COLS.ELEMENT_NAME is
'Name XMLSChema element that is used for the view' 
/

Rem DBA_XML_SCHEMAS
Rem This view presents a listing of all XML Schemas registered
Rem in the system.
 
create or replace force view DBA_XML_SCHEMAS
 (OWNER, SCHEMA_URL, LOCAL, SCHEMA, INT_OBJNAME, QUAL_SCHEMA_URL, HIER_TYPE)
 as select s.xmldata.schema_owner, s.xmldata.schema_url,
          case when bitand(to_number(s.xmldata.flags,'xxxxxxxx'), 16) = 16
               then 'NO' else 'YES' end,
          value(s),
          xdb.xdb$Extname2Intname(s.xmldata.schema_url,s.xmldata.schema_owner),
          case when bitand(to_number(s.xmldata.flags,'xxxxxxxx'), 16) = 16
               then s.xmldata.schema_url
               else 'http://xmlns.oracle.com/xdb/schemas/' ||
                    s.xmldata.schema_owner || '/' ||
                    case when substr(s.xmldata.schema_url, 1, 7) = 'http://'
                         then substr(s.xmldata.schema_url, 8)
                         else s.xmldata.schema_url
                    end
          end,
          case when bitand(to_number(s.xmldata.flags, 'xxxxxxxx'), 128) = 128
               then 'NONE'
               else case when 
                    bitand(to_number(s.xmldata.flags, 'xxxxxxxx'), 64) = 64
                    then  'RESMETADATA'
                    else  'CONTENTS'
                    end
          end
    from xdb.xdb$schema s
/
grant select on dba_xml_schemas to select_catalog_role;

create or replace public synonym dba_xml_schemas for dba_xml_schemas;

comment on table DBA_XML_SCHEMAS is
'Description of all the XML Schemas registered'
/
comment on column DBA_XML_SCHEMAS.OWNER is
'Owner of the XML Schema'
/
comment on column DBA_XML_SCHEMAS.SCHEMA_URL is
'Schema URL of the XML Schema'
/
comment on column DBA_XML_SCHEMAS.LOCAL is
'Is this XML Schema local or global'
/
comment on column DBA_XML_SCHEMAS.SCHEMA is
'The XML Schema document'
/
comment on column DBA_XML_SCHEMAS.INT_OBJNAME is
'The internal database object name for the schema'
/
comment on column DBA_XML_SCHEMAS.QUAL_SCHEMA_URL is
'The fully qualified schema URL'
/
comment on column DBA_XML_SCHEMAS.HIER_TYPE is
'The type of hierarchy for which the schema is enabled'
/

Rem NOTE: Make sure that ALL_XML_SCHEMAS AND ALL_XML_SCHEMAS2
Rem are kept in sync with catxdbdv.sql

Rem ALL_XML_SCHEMAS
Rem Lists all schemas that user has permission to see. This should
Rem be the ones owned by the user plus the global ones. Note that we
Rem do not have the concept of "schema/user" qualified names so we
Rem don't need to include schemas owned by others that this user
Rem has permission to read (because anyway they can't be used)

create or replace force view ALL_XML_SCHEMAS
 (OWNER, SCHEMA_URL, LOCAL, SCHEMA, INT_OBJNAME, QUAL_SCHEMA_URL, HIER_TYPE)
 as select u.name, s.xmldata.schema_url,
          case when bitand(to_number(s.xmldata.flags,'xxxxxxxx'), 16) = 16
               then 'NO' else 'YES' end,
          value(s),
          xdb.xdb$Extname2Intname(s.xmldata.schema_url,s.xmldata.schema_owner),
          case when bitand(to_number(s.xmldata.flags,'xxxxxxxx'), 16) = 16
               then s.xmldata.schema_url
               else 'http://xmlns.oracle.com/xdb/schemas/' ||
                    s.xmldata.schema_owner || '/' ||
                    case when substr(s.xmldata.schema_url, 1, 7) = 'http://'
                         then substr(s.xmldata.schema_url, 8)
                         else s.xmldata.schema_url
                    end
          end,
          case when bitand(to_number(s.xmldata.flags, 'xxxxxxxx'), 128) = 128
               then 'NONE'
               else case when 
                    bitand(to_number(s.xmldata.flags, 'xxxxxxxx'), 64) = 64
                    then  'RESMETADATA'
                    else  'CONTENTS'
                    end
          end
    from user$ u, xdb.xdb$schema s
    where u.user# = userenv('SCHEMAID')
    and   u.name  = s.xmldata.schema_owner
    union all
    select s.xmldata.schema_owner, s.xmldata.schema_url, 'NO', value(s),
          xdb.xdb$Extname2Intname(s.xmldata.schema_url,s.xmldata.schema_owner),
          s.xmldata.schema_url,
          case when bitand(to_number(s.xmldata.flags, 'xxxxxxxx'), 128) = 128
               then 'NONE'
               else case when 
                    bitand(to_number(s.xmldata.flags, 'xxxxxxxx'), 64) = 64
                    then  'RESMETADATA'
                    else  'CONTENTS'
                    end
          end
    from xdb.xdb$schema s
    where bitand(to_number(s.xmldata.flags,'xxxxxxxx'), 16) = 16
    and s.xmldata.schema_url
       not in (select s2.xmldata.schema_url
               from xdb.xdb$schema s2, user$ u2
               where u2.user# = userenv('SCHEMAID')
               and   u2.name  = s.xmldata.schema_owner)
/
grant select on all_xml_schemas to public with grant option;

create or replace public synonym all_xml_schemas for all_xml_schemas;

comment on table ALL_XML_SCHEMAS is
'Description of all XML Schemas that user has privilege to reference'
/
comment on column ALL_XML_SCHEMAS.OWNER is
'Owner of the XML Schema'
/
comment on column ALL_XML_SCHEMAS.SCHEMA_URL is
'Schema URL of the XML Schema'
/
comment on column ALL_XML_SCHEMAS.LOCAL is
'Is this XML Schema local or global'
/
comment on column ALL_XML_SCHEMAS.SCHEMA is
'The XML Schema document'
/
comment on column ALL_XML_SCHEMAS.INT_OBJNAME is
'The internal database object name for the schema'
/
comment on column ALL_XML_SCHEMAS.QUAL_SCHEMA_URL is
'The fully qualified schema URL'
/
comment on column ALL_XML_SCHEMAS.HIER_TYPE is
'The type of hierarchy for which the schema is enabled'
/
Rem ALL_XML_SCHEMAS2
Rem Since XMLTYPE may not be present at the stage when catalog.sql runs
Rem this file, we need a version of ALL_XML_SCHEMAS that ALL_OBJECTS
Rem can depend on that doesn't include XMLTYPE.  This way, ALL_OBJECTS
Rem won't be invalidated when we redefine the real ALL_XML_SCHEMAS from
Rem dbmsxmlt.sql.

create or replace force view ALL_XML_SCHEMAS2
 (OWNER, SCHEMA_URL, LOCAL, INT_OBJNAME, QUAL_SCHEMA_URL)
 as select u.name, s.xmldata.schema_url,
          case when bitand(to_number(s.xmldata.flags,'xxxxxxxx'), 16) = 16
               then 'NO' else 'YES' end,
          xdb.xdb$Extname2Intname(s.xmldata.schema_url,s.xmldata.schema_owner),
          case when bitand(to_number(s.xmldata.flags,'xxxxxxxx'), 16) = 16
               then s.xmldata.schema_url
               else 'http://xmlns.oracle.com/xdb/schemas/' ||
                    s.xmldata.schema_owner || '/' ||
                    case when substr(s.xmldata.schema_url, 1, 7) = 'http://'
                         then substr(s.xmldata.schema_url, 8)
                         else s.xmldata.schema_url
                    end
          end
    from user$ u, xdb.xdb$schema s
    where u.user# = userenv('SCHEMAID')
    and   u.name  = s.xmldata.schema_owner
    union all
    select s.xmldata.schema_owner, s.xmldata.schema_url, 'NO', 
          xdb.xdb$Extname2Intname(s.xmldata.schema_url,s.xmldata.schema_owner),
          s.xmldata.schema_url
    from xdb.xdb$schema s
    where bitand(to_number(s.xmldata.flags,'xxxxxxxx'), 16) = 16
    and s.xmldata.schema_url
       not in (select s2.xmldata.schema_url
               from xdb.xdb$schema s2, user$ u2
               where u2.user# = userenv('SCHEMAID')
               and   u2.name  = s.xmldata.schema_owner)
/
grant select on all_xml_schemas2 to public with grant option;

create or replace public synonym all_xml_schemas2 for all_xml_schemas2;

comment on table ALL_XML_SCHEMAS2 is
'Dummy version of ALL_XML_SCHEMAS that does not have an XMLTYPE column'
/
comment on column ALL_XML_SCHEMAS2.OWNER is
'Owner of the XML Schema'
/
comment on column ALL_XML_SCHEMAS2.SCHEMA_URL is
'Schema URL of the XML Schema'
/
comment on column ALL_XML_SCHEMAS2.LOCAL is
'Is this XML Schema local or global'
/
comment on column ALL_XML_SCHEMAS2.INT_OBJNAME is
'The internal database object name for the schema'
/
comment on column ALL_XML_SCHEMAS2.QUAL_SCHEMA_URL is
'The fully qualified schema URL'
/

Rem ALL_OBJECTS depends on xml_schema_name_present. Recreate the package 
Rem body, nothing will get invalidated

create or replace package body xml_schema_name_present as

function is_schema_present(objname in varchar2,
                           userno  in number) return number as

  sel_stmt        VARCHAR2(4000);
  tmp_num         NUMBER;

BEGIN

    sel_stmt := ' select count(*) ' ||
    ' from user$ u, xdb.xdb$schema s ' ||
    ' where u.user# = :1 ' ||
    ' and   u.name  = s.xmldata.schema_owner ' ||
    ' and  (xdb.xdb$Extname2Intname(s.xmldata.schema_url, s.xmldata.schema_owner) = :2)';

    EXECUTE IMMEDIATE sel_stmt INTO tmp_num USING userno, objname;

    /* schema found */   
    IF (tmp_num > 0) THEN
      RETURN 1;
    END IF;

    sel_stmt := ' select count(*) '||
    ' from xdb.xdb$schema s ' ||
    ' where bitand(to_number(s.xmldata.flags, ''xxxxxxxx''), 16) = 16 ' ||
    ' and xdb.xdb$Extname2Intname(s.xmldata.schema_url,s.xmldata.schema_owner) = :1 ' ||
    ' and s.xmldata.schema_url ' ||
    '   not in (select s2.xmldata.schema_url ' ||
    '          from xdb.xdb$schema s2, user$ u2 ' ||
    '          where u2.user# = :2 ' ||
    '          and   u2.name  = s.xmldata.schema_owner) ';

    EXECUTE IMMEDIATE sel_stmt INTO tmp_num USING objname, userno;

    /* schema found */   
    IF (tmp_num > 0) THEN
      RETURN 1;
    END IF;

    RETURN 0;
END;

end xml_schema_name_present;
/

show errors;

Rem USER_XML_SCHEMAS
Rem List of all XML Schemas owned by the current user
create or replace force view USER_XML_SCHEMAS
 (SCHEMA_URL, LOCAL, SCHEMA, INT_OBJNAME, QUAL_SCHEMA_URL, HIER_TYPE)
 as select s.xmldata.schema_url,
          case when bitand(to_number(s.xmldata.flags,'xxxxxxxx'), 16) = 16
               then 'NO' else 'YES' end,
          value(s),
          xdb.xdb$Extname2Intname(s.xmldata.schema_url,s.xmldata.schema_owner),
          case when bitand(to_number(s.xmldata.flags,'xxxxxxxx'), 16) = 16
               then s.xmldata.schema_url
               else 'http://xmlns.oracle.com/xdb/schemas/' ||
                    s.xmldata.schema_owner || '/' ||
                    case when substr(s.xmldata.schema_url, 1, 7) = 'http://'
                         then substr(s.xmldata.schema_url, 8)
                         else s.xmldata.schema_url
                    end
          end, 
          case when bitand(to_number(s.xmldata.flags, 'xxxxxxxx'), 128) = 128
               then 'NONE'
               else case when 
                    bitand(to_number(s.xmldata.flags, 'xxxxxxxx'), 64) = 64
                    then  'RESMETADATA'
                    else  'CONTENTS'
                    end
          end
    from user$ u, xdb.xdb$schema s
    where u.name = s.xmldata.schema_owner
    and u.user# = userenv('SCHEMAID')
/
grant select on user_xml_schemas to public with grant option;

create or replace public synonym user_xml_schemas for user_xml_schemas;

comment on table USER_XML_SCHEMAS is
'Description of XML Schemas registered by the user'
/
comment on column USER_XML_SCHEMAS.SCHEMA_URL is
'Schema URL of the XML Schema'
/
comment on column USER_XML_SCHEMAS.LOCAL is
'Is this XML Schema local or global'
/
comment on column USER_XML_SCHEMAS.SCHEMA is
'The XML Schema document'
/
comment on column USER_XML_SCHEMAS.INT_OBJNAME is
'The internal database object name for the schema'
/
comment on column USER_XML_SCHEMAS.QUAL_SCHEMA_URL is
'The fully qualified schema URL'
/
comment on column USER_XML_SCHEMAS.HIER_TYPE is
'The type of hierarchy for which the schema is enabled'
/

create or replace force view DBA_XML_INDEXES
 (INDEX_OWNER, INDEX_NAME, TABLE_OWNER, TABLE_NAME, PATH_TABLE_NAME, PATHS)
 as select
   u.name         INDEX_OWNER,
   oi.name        INDEX_NAME,
   bu.name        TABLE_OWNER,
   bo.name        TABLE_NAME,
   ot.name        PATH_TABLE_NAME,
   case when (select count(*)
              from xdb.xdb$dxpath x
              where x.idxobj# = oi.obj# and x.flags=2) > 0 then
   xmlelement("ExcludedPaths",
     (select xmlagg(xmlelement("Path", x.xpath))
      from xdb.xdb$dxpath x
      where x.idxobj# = oi.obj# and x.flags=2),
     (select xmlagg(xmlelement("Namespace", x.xpath))
      from xdb.xdb$dxpath x
      where x.idxobj# = oi.obj# and x.flags=1)) else
   xmlelement("IncludedPaths",
     (select xmlagg(xmlelement("Path", x.xpath))
      from xdb.xdb$dxpath x
      where x.idxobj# = oi.obj# and x.flags=0),
     (select xmlagg(xmlelement("Namespace", x.xpath))
      from xdb.xdb$dxpath x
      where x.idxobj# = oi.obj# and x.flags=1)) end PATHS
from xdb.xdb$dxptab p, sys.obj$ ot, sys.obj$ oi, sys.user$ u,
     sys.obj$ bo, sys.user$ bu, sys.ind$ i
where oi.owner# = u.user# and
       oi.obj# = p.idxobj# and p.pathtabobj# = ot.obj# and
       i.obj# = oi.obj# and i.bo# = bo.obj# and bo.owner# = bu.user#
/

grant select on dba_xml_indexes to select_catalog_role;

create or replace public synonym dba_xml_indexes for dba_xml_indexes; 

comment on table DBA_XML_INDEXES is
'Description of all XML indexes in the database'
/
comment on column DBA_XML_INDEXES.INDEX_OWNER is
'Username of the owner of the XML index'
/
comment on column DBA_XML_INDEXES.INDEX_NAME is
'Name of the XML index'
/
comment on column DBA_XML_INDEXES.TABLE_OWNER is
'Username of the owner of the indexed object'
/
comment on column DBA_XML_INDEXES.TABLE_NAME is
'Name of the indexed object'
/
comment on column DBA_XML_INDEXES.PATH_TABLE_NAME is
'Name of the PATH TABLE'
/
comment on column DBA_XML_INDEXES.PATHS is
'Indexed Paths and namespaces'
/

create or replace force view ALL_XML_INDEXES
 (INDEX_OWNER, INDEX_NAME, TABLE_OWNER, TABLE_NAME, PATH_TABLE_NAME, PATHS)
 as select
   u.name         INDEX_OWNER,   
   oi.name        INDEX_NAME,
   bu.name        TABLE_OWNER,
   bo.name        TABLE_NAME,
   ot.name        PATH_TABLE_NAME,
   case when (select count(*)
              from xdb.xdb$dxpath x
              where x.idxobj# = oi.obj# and x.flags=2) > 0 then
   xmlelement("ExcludedPaths",
     (select xmlagg(xmlelement("Path", x.xpath))
      from xdb.xdb$dxpath x
      where x.idxobj# = oi.obj# and x.flags=2),
     (select xmlagg(xmlelement("Namespace", x.xpath))
      from xdb.xdb$dxpath x
      where x.idxobj# = oi.obj# and x.flags=1)) else
   xmlelement("IncludedPaths",
     (select xmlagg(xmlelement("Path", x.xpath))
      from xdb.xdb$dxpath x
      where x.idxobj# = oi.obj# and x.flags=0),
     (select xmlagg(xmlelement("Namespace", x.xpath))
      from xdb.xdb$dxpath x
      where x.idxobj# = oi.obj# and x.flags=1)) end PATHS
 from xdb.xdb$dxptab p, sys.obj$ ot, sys.obj$ oi, sys.user$ u,
      sys.user$ bu, sys.obj$ bo, sys.ind$ i
 where oi.owner# = u.user# and
       oi.obj# = p.idxobj# and p.pathtabobj# = ot.obj# and
       i.obj# = oi.obj# and i.bo# = bo.obj# and bo.owner# = bu.user# and
       (u.user# = userenv('SCHEMAID')
        or oi.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)))
/
grant select on all_xml_indexes to public;

create or replace public synonym all_xml_indexes for all_xml_indexes; 

comment on table ALL_XML_INDEXES is
'Description of the all XMLType indexes that the user has privileges on'
/
comment on column ALL_XML_INDEXES.INDEX_OWNER is
'Username of the owner of the XML index'
/
comment on column ALL_XML_INDEXES.INDEX_NAME is
'Name of the XML index'
/
comment on column ALL_XML_INDEXES.TABLE_OWNER is
'Username of the owner of the indexed object'
/
comment on column ALL_XML_INDEXES.TABLE_NAME is
'Name of the indexed object'
/
comment on column ALL_XML_INDEXES.PATH_TABLE_NAME is
'Name of the PATH TABLE'
/
comment on column ALL_XML_INDEXES.PATHS is
'Indexed Paths and namespaces'
/

create or replace force view USER_XML_INDEXES
 (INDEX_NAME, TABLE_OWNER, TABLE_NAME, PATH_TABLE_NAME, PATHS)
 as select
   oi.name        INDEX_NAME,
   bu.name        TABLE_OWNER,
   bo.name        TABLE_NAME,
   ot.name        PATH_TABLE_NAME,
   case when (select count(*)
              from xdb.xdb$dxpath x
              where x.idxobj# = oi.obj# and x.flags=2) > 0 then
   xmlelement("ExcludedPaths",
     (select xmlagg(xmlelement("Path", x.xpath))
      from xdb.xdb$dxpath x
      where x.idxobj# = oi.obj# and x.flags=2),
     (select xmlagg(xmlelement("Namespace", x.xpath))
      from xdb.xdb$dxpath x
      where x.idxobj# = oi.obj# and x.flags=1)) else
   xmlelement("IncludedPaths",
     (select xmlagg(xmlelement("Path", x.xpath))
      from xdb.xdb$dxpath x
      where x.idxobj# = oi.obj# and x.flags=0),
     (select xmlagg(xmlelement("Namespace", x.xpath))
      from xdb.xdb$dxpath x
      where x.idxobj# = oi.obj# and x.flags=1)) end PATHS
 from xdb.xdb$dxptab p, sys.obj$ ot, sys.obj$ oi, sys.user$ u,
      sys.user$ bu, sys.obj$ bo, sys.ind$ i
 where oi.owner# = u.user# and
       oi.obj# = p.idxobj# and p.pathtabobj# = ot.obj# and
       i.obj# = oi.obj# and i.bo# = bo.obj# and bo.owner# = bu.user# and
       u.user# = userenv('SCHEMAID')
/
grant select on user_xml_indexes to public;

create or replace public synonym user_xml_indexes for user_xml_indexes; 

comment on table USER_XML_INDEXES is
'Description of the user''s own XMLType indexes'
/
comment on column USER_XML_INDEXES.INDEX_NAME is
'Name of the XML index'
/
comment on column USER_XML_INDEXES.TABLE_OWNER is
'Username of the owner of the indexed object'
/
comment on column USER_XML_INDEXES.TABLE_NAME is
'Name of the indexed object'
/
comment on column USER_XML_INDEXES.PATH_TABLE_NAME is
'Name of the PATH TABLE'
/
comment on column USER_XML_INDEXES.PATHS is
'Indexed Paths and namespaces'
/

Rem Bug fix 4376605, create a view owned by SYS which queries the 
Rem dictionary tables, and exposes only necessary columns to 
Rem qmxdpGetColName in qmxdp.c.
create or replace force view USER_XML_COLUMN_NAMES
 (SCHEMA_NAME, TABLE_NAME, COLUMN_NAME, OBJECT_COLUMN_NAME, EXTERNAL_COLUMN_NAME)
 as 
 select 
   u.name, o.name, c.name,
   (select name from sys.col$ c where c.obj# = o.obj# and c.intcol# = p.objcol),
   (select name from sys.col$ c where c.obj# = o.obj# and c.intcol# = p.extracol)
 from
   sys.opqtype$ p, sys.col$ c, sys.obj$ o, sys.user$ u
 where
   u.user# = o.owner# and
   o.type# = 2 and
   c.obj# = o.obj# and 
   p.intcol# = c.intcol# and
   p.obj# = o.obj# and
   (u.user# = userenv('SCHEMAID')
     or o.obj# in
        (select oa.obj#
         from sys.objauth$ oa
         where grantee# in ( select kzsrorol
                             from x$kzsro
                           )
        )
     or /* user has system privileges */
       exists (select null from v$enabledprivs
               where priv_number in (-45 /* LOCK ANY TABLE */,
                                     -47 /* SELECT ANY TABLE */,
                                     -48 /* INSERT ANY TABLE */,
                                     -49 /* UPDATE ANY TABLE */,
                                     -50 /* DELETE ANY TABLE */)))

/ 

grant select on USER_XML_COLUMN_NAMES to public;

create or replace public synonym USER_XML_COLUMN_NAMES for USER_XML_COLUMN_NAMES;

Rem Upgrade Might disbale xdbhi_idx, rebuild it
alter package xdb.xdb_funcimpl compile;
alter index xdb.xdbhi_idx rebuild;

rem
rem create metadata API views
rem
@@catmetx.sql
