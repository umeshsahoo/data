Rem
Rem $Header: catmetx.sql 18-may-2005.11:21:41 vkapoor Exp $
Rem
Rem catmetx.sql
Rem
Rem Copyright (c) 2001, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catmetx.sql - Metadata API: Real definitions for XDB object views.
Rem
Rem    DESCRIPTION
Rem      Metadata API object views for XDB objects
Rem
Rem    NOTES
Rem     For reasons having to do with compatibility, the XDB objects
Rem     can't be created by catproc.sql; they must instead be created
Rem     by a separate script catqm.sql.  Since catmeta.sql is run
Rem     by catproc.sql, it contains fake object views for XDB objects.
Rem     The real object views are defined in this file which is
Rem     invoked by catxdbv.sql (which is invoked by catqm.sql).
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    vkapoor     05/18/05 - LRG 1798757. Freeing some memory 
Rem    ataracha    10/21/04 - ku$_xmlschema_elmt_view - use the base element's 
Rem                         - name for ref elements
Rem    spannala    05/20/04 - workaround for disabled xdbhi_idx 
Rem    bmccarth    01/17/03 - add procedure to revalidate ku$ views if needed
Rem    bmccarth    11/15/02 - enable stripusername for url
Rem    amanikut    10/25/02 - specify namespace correctly in extractvalue()
Rem    bmccarth    08/22/02 - XDB 92->main merge - disable (for now)
Rem                           call to stripschema in xdb utility package (not 
Rem                           available yet)
Rem    bmccarth    03/01/02 - add schemaoid to xmlschema
Rem    lbarton     01/16/02 - Merged lbarton_mdapi_xdb
Rem    lbarton     01/15/02 - fix comment
Rem    lbarton     12/03/01 - debug
Rem    lbarton     11/21/01 - Created
Rem

-- indexes get disabled on compilation of function. Workaround.
alter package xdb.xdb_funcimpl compile;
alter index xdb.xdbhi_idx rebuild;

create or replace force view sys.ku$_xmlschema_view of sys.ku$_xmlschema_t
  with object identifier (owner_name, url) as
  select '1','0',
        u.user#, u.name, extractvalue(VALUE(s), '/schema/@x:schemaURL',
'xmlns="http://www.w3.org/2001/XMLSchema" xmlns:x="http://xmlns.oracle.com/xdb"'),
        s.sys_nc_oid$,
           case when under_path(value(r), '/sys/schemas/PUBLIC') = 1
                then 0 else 1 end,
         s.getclobval(),                                          -- unstripped
         xdb.dbms_xdbutil_int.XMLSchemaStripUsername(XMLTYPE(s.getClobVal()),
                                                      u.name)     -- stripped 
    from sys.user$ u, xdb.xdb$schema s, xdb.xdb$resource r
    where extractvalue(VALUE(r), '/Resource/XMLRef') = ref(s)
    and u.user# = sys_op_rawtonum(extractvalue(VALUE(r),'/Resource/OwnerID'))
        AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (u.user#, 0) OR
                EXISTS ( SELECT * FROM session_roles
                        WHERE role='SELECT_CATALOG_ROLE' ))
/
grant select on sys.ku$_xmlschema_view to public
/
create or replace force view sys.ku$_xmlschema_elmt_view
  of sys.ku$_xmlschema_elmt_t with object identifier(schemaoid, elemnum) as
  select schm.sys_nc_oid$, extractValue(value(schm), '/schema/@x:schemaURL',
'xmlns="http://www.w3.org/2001/XMLSchema" xmlns:x="http://xmlns.oracle.com/xdb"'),
            extractValue(value(xel), '/element/@x:propNumber',
'xmlns="http://www.w3.org/2001/XMLSchema" xmlns:x="http://xmlns.oracle.com/xdb"'), 
            case WHEN (extractValue(value(xel) , '/element/@name') is NULL)then 
                   xel.xmldata.property.propref_name.name 
            else extractValue(value(xel) , '/element/@name')
            end
  from xdb.xdb$element xel, xdb.xdb$schema schm
  where ref(schm) = extractValue(value(xel), '/element/@x:parentSchema',
'xmlns="http://www.w3.org/2001/XMLSchema" xmlns:x="http://xmlns.oracle.com/xdb"')
/
grant select on sys.ku$_xmlschema_elmt_view to select_catalog_role
/

Rem
Rem During the XDB setup, several KU$_ views go invalid, recompile 
Rem them as needed.
Rem 

CREATE OR REPLACE PROCEDURE recomp_catmeta_views AS
  TYPE cur_type is REF CURSOR;
  data_cursor cur_type;
  invalid_view VARCHAR2(100);
  sql_stmt  VARCHAR2(1000);

BEGIN
-- 
-- Only get KU$_ views with invalid states back
--
  OPEN data_cursor FOR 'SELECT name FROM obj$ WHERE STATUS > 1 ' ||
                       'AND TYPE# = 4 AND name like ''KU$_%''';
  LOOP                                          

    FETCH data_cursor INTO invalid_view;
    EXIT WHEN data_cursor%NOTFOUND;

    sql_stmt := 'ALTER VIEW ' || invalid_view || ' COMPILE';
    EXECUTE IMMEDIATE sql_stmt;

  END LOOP;
  CLOSE data_cursor;
end recomp_catmeta_views;
/

alter system flush shared_pool;
alter system flush shared_pool;
alter system flush shared_pool;

Rem 
Rem Execute then drop the procedure.
Rem

BEGIN
  recomp_catmeta_views;
end;
/

drop procedure recomp_catmeta_views;



