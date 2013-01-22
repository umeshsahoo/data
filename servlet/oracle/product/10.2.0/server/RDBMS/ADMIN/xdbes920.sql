Rem
Rem $Header: xdbes920.sql 02-sep-2004.00:28:35 spannala Exp $
Rem
Rem xdbes920.sql
Rem
Rem Copyright (c) 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      xdbes920.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      downgrade schema from current release to 9.2
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    spannala    09/02/04 - spannala_lrg-1734670
Rem    spannala    08/24/04 - Created
Rem

-- First do the schema downgrade to 10.1
@@xdbes101.sql

CREATE OR REPLACE PROCEDURE downgrade_config AS
  m                 INTEGER;
  config_schema_ref REF XMLTYPE;
  sysconf_seq_ref   REF XMLTYPE;
  config_schema_url CONSTANT VARCHAR2(100)
                    := 'http://xmlns.oracle.com/xdb/xdbconfig.xsd';
  sysconf_elem_arr  XDB.XDB$XMLTYPE_REF_LIST_T; 
  type_owner        VARCHAR2(50);
  type_name         VARCHAR2(50);
BEGIN
  select ref(s) into config_schema_ref from xdb.xdb$schema s where
     s.xmldata.schema_url = config_schema_url;

  select n into m from xdb.migr9202status;
  IF m > 480 THEN
    -- this will get commited along with the following deletes
    update xdb.migr9202status set n = 480;

    -- get the ref to the xdb.xdb$sequence_model
    select c.xmldata.sequence_kid into sysconf_seq_ref from
    xdb.xdb$complex_type c where ref(c) =
    (select e.xmldata.cplx_type_decl from xdb.xdb$element e
     where e.xmldata.property.name='sysconfig' and
     e.xmldata.property.parent_schema = config_schema_ref);

    -- get the varray of elements from the syconf sequence
    select m.xmldata.elements into sysconf_elem_arr from xdb.xdb$sequence_model
    m where ref(m) = sysconf_seq_ref;

    -- delete the last two elements, they are the two new elements
    -- added in 10.1
    delete_elem_by_ref(sysconf_elem_arr(sysconf_elem_arr.last-1));
    delete_elem_by_ref(sysconf_elem_arr(sysconf_elem_arr.last));

    -- remove the two elements from the sysconf array
    sysconf_elem_arr.trim(2);

    -- TODO: determine the PD to be used here.
    update xdb.xdb$sequence_model s set
      s.xmldata.elements = sysconf_elem_arr,
      s.xmldata.sys_xdbpd$ = xdb.xdb$raw_list_t('23020002000200182067656E65726963205844422070726F7065727469657320020E1E2070726F746F636F6C2073706563696669632070726F706572746965732081800F07')
      where ref(s) = sysconf_seq_ref;
    commit;

  END IF; -- end if m >= 480

  -- Remove the 'xdbcore-loadableunit-size' from sysconfig object type
  select n into m from xdb.migr9202status;
  IF m > 461 THEN
    -- update the status to 461
    update xdb.migr9202status set n = 461;
    
    -- Get the object type of sysconfig schema
    element_type(config_schema_url, 'sysconfig', type_owner, type_name);
    alt_type_drop_attribute(type_owner, type_name, '"xdbcore-xobmem-bound"');
  END IF;

  -- Remove the 'xdbcore-loadableunit-size' from sysconfig object type
  select n into m from xdb.migr9202status;
  IF m > 460 THEN
    -- update the status to 460
    update xdb.migr9202status set n = 460;
    
    -- Get the object type of sysconfig schema
    element_type(config_schema_url, 'sysconfig', type_owner, type_name);
    alt_type_drop_attribute(type_owner, type_name,
                            '"xdbcore-loadableunit-size"');
  END IF;
END;
/


-- downgrade the resource schema
-- The caller will commit the actions of this function
CREATE OR REPLACE PROCEDURE DOWNGRADE_RESOURCESCHEMA AS
  PN_RES_TOTAL_PROPNUMS   CONSTANT INTEGER := 43;
  attlist                 xdb.xdb$xmltype_ref_list_t;
  sch_ref                 REF SYS.XMLTYPE;
  attr_ref                REF SYS.XMLTYPE;
  numprops                number;
  RESOURCE_SCHEMA_URL     CONSTANT STRING(100)
                          := 'http://xmlns.oracle.com/xdb/XDBResource.xsd';
BEGIN
  -- get schema ref
  select ref(s) into sch_ref from xdb.xdb$schema s where 
    s.xmldata.schema_url = RESOURCE_SCHEMA_URL;

  -- get num props
  select s.xmldata.num_props into numprops from xdb.xdb$schema s where 
    s.xmldata.schema_url = RESOURCE_SCHEMA_URL;

  -- This is a sanity check, we really dont need this as the status number
  -- will ensure that this routine is not called twice.
  IF numprops > PN_RES_TOTAL_PROPNUMS THEN
    -- get the attributes of the resourcetype complextype
    select c.xmldata.attributes into attlist from xdb.xdb$complex_type c where
      c.xmldata.name = 'ResourceType' and c.xmldata.parent_schema = sch_ref;

    -- Remove the HierSchmResource attribute
    attr_ref := attlist(9);
    delete from xdb.xdb$attribute a where ref(a) = attr_ref;

    -- Remove the attribute from the attlist
    attlist.trim(1);

    -- set this as the attribute list for the complex type
    update xdb.xdb$complex_type c set c.xmldata.attributes = attlist where
      c.xmldata.name = 'ResourceType' and c.xmldata.parent_schema = sch_ref;

    -- update the total number of properties
    update xdb.xdb$schema s set s.xmldata.num_props = PN_RES_TOTAL_PROPNUMS
      where ref(s) = sch_ref;
  END IF;
END;
/


-- downgrade the schema of schemas
-- moves the downgrade status to 400 from 420
CREATE OR REPLACE PROCEDURE DOWNGRADE_ROOTSCHEMA AS
  m              integer;
  rootschref     ref xmltype;
  text_elt_ref   ref xmltype;
  final_attr_ref ref xmltype;
  NUM_PROPS_9204 CONSTANT  integer := 269;
  ellist         xdb.xdb$xmltype_ref_list_t; 
  attlist        xdb.xdb$xmltype_ref_list_t; 
BEGIN

  select n into m from xdb.migr9202status;

  IF m > 420 THEN
    -- this will get commited with the rest of the stuff
    update xdb.migr9202status set n = 420;

    -- Get the ref of the root schema
    select ref(s) into rootschref from xdb.xdb$schema s where
      s.xmldata.schema_url = 'http://xmlns.oracle.com/xdb/XDBSchema.xsd';

    -- get the list of elements of the root schema into ellist
    select s.xmldata.elements into ellist from xdb.xdb$schema s where
      ref(s) = rootschref;

    -- the text element is at index 14 (pl/sql index) in the elements of
    -- schema of schemas
    text_elt_ref := ellist(14);

    -- remove the text element ref from this list
    ellist.trim(1);

    -- delete the text element
    delete_elem_by_ref(text_elt_ref);

    -- alter the root schema to remove the text element and set the correct
    -- number for props
    update xdb.xdb$schema s set
      s.xmldata.elements = ellist,
      s.xmldata.num_props = NUM_PROPS_9204
      where ref(s) = rootschref;

    -- delete the 'final' attribute of simpleType type
    -- fetch the list of all attributes of the simpleType complex type
    select c.xmldata.attributes into attlist  from xdb.xdb$complex_type c
      where c.xmldata.parent_schema = rootschref and
      c.xmldata.name = 'simpleType';

    -- get the ref of the final attribute
    final_attr_ref := attlist(5);

    -- remove this ref from the list of attributes of the complextype
    attlist.trim(1);

    -- delete the corresponding attribute
    delete from xdb.xdb$attribute a where ref(a) = final_attr_ref;

    -- update the complext_type table with the reduced list of attrs
    update xdb.xdb$complex_type c
      set c.xmldata.attributes = attlist
    where c.xmldata.name = 'simpleType'
    and c.xmldata.parent_schema = rootschref;

    -- commit the whole txn, this will also update the status
    commit;
  END IF; -- end if m > 420

  -- remove the final_info attribute
  exec_stmt_chg_status(400, 'alter type xdb.xdb$simple_t drop attribute ' ||
                            'final_info cascade');
END;
/

-- Downgrade the config. Needs status to be 480 or above
CALL downgrade_config();

select n from xdb.migr9202status;

-- downgrade the acl schema
-- No downgrade necessary for acl schema

-- downgrade the resource_schema
call exec_stmt_chg_status(440, 'CALL downgrade_resourceschema()');

-- reset facet list before downgrade
Rem call exec_stmt_chg_status(430, 'alter type xdb.xdb$facet_list_t reset');

CALL downgrade_rootschema();

select n from xdb.migr9202status;

-- remove temporary procedures
DROP PROCEDURE downgrade_config;
DROP PROCEDURE downgrade_rootschema;
DROP PROCEDURE downgrade_resourceschema;
