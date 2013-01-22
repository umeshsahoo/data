Rem
Rem $Header: xdbu101.sql 16-jun-2005.19:50:25 pnath Exp $
Rem
Rem xdbu101.sql
Rem
Rem Copyright (c) 2004, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      xdbu101.sql - xdb upgrade from 10.1 relese to main.
Rem
Rem    DESCRIPTION
Rem      XDB upgrade for the 101. release
Rem
Rem    NOTES
Rem      XDB Upgrade document.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pnath       06/16/05 - set default ftp and http ports to 0 
Rem    rmurthy     03/08/05 - fix namespaces for bootstrapped schemas 
Rem    thbaby      02/16/05 - set acl of xdbconfig.xml by all_owner_acl.xml
Rem    abagrawa    02/08/05 - Protect xdbconfig.xml by xdbadmin role 
Rem    vkapoor     01/13/05 - LRG 1804464 
Rem    spannala    05/22/04 - adjust status to match the one in xdbs101
Rem    spannala    05/07/04 - prevent execution of xdbs101 repetedly 
Rem    thbaby      04/26/04 - thbaby_https
Rem    thbaby      04/21/04 - Created
Rem

-- First upgrade the schemas, if necessary
COLUMN :sch101_name NEW_VALUE comp101_file NOPRINT
VARIABLE sch101_name VARCHAR2(50)

DECLARE
  a number;
BEGIN
  select n into a from xdb.migr9202status;
  if a < 750 then
    :sch101_name  := '@xdbs101.sql';
  else
    :sch101_name := '@nothing.sql';
  end if;
end;
/
select :sch101_name from dual;
@&comp101_file;

-- Protect xdbconfig.xml with the xdbadmin role
-- First revoke privileges from public, and make sure xdbadmin has all priv
revoke all on xdb.xdb$config from public;
grant all on xdb.xdb$config to xdbadmin ; 

-- set the acl of xdbconfig.xml to all_owner_acl.xml
-- no need to modify migrate status since setacl is an idempotent opern
DECLARE
  acl_abspath          VARCHAR2(200);
  b_abspath VARCHAR(20) := '/xdbconfig.xml';
BEGIN
   acl_abspath := '/sys/acls/all_owner_acl.xml';

   dbms_xdb.setAcl(b_abspath, acl_abspath);	
END;
/

exec dbms_xdb.setftpport(0);
exec dbms_xdb.sethttpport(0);

drop package xdb.xdb$bootstrap;
drop package xdb.xdb$bootstrapres;

-- Fix namespace array for bootstrapped schemas
-- First create the function that converts namespace array to internal
-- pickled form (same as the one defined in catxdbdt.sql during install)
-- This is an idempotent operation.
create or replace function xdb.xdb$getPickledNS
       (nsuri IN VARCHAR2, pfx IN VARCHAR2) 
return raw is
  external
  name "GET_PICKLED_NS"
  language C
  library XMLSCHEMA_LIB
  with context
  parameters (context,
              nsuri        STRING,
              nsuri        INDICATOR sb4,
              nsuri        LENGTH sb4,
              pfx        STRING,
              pfx        INDICATOR sb4,
              pfx        LENGTH sb4,
	      return         LENGTH sb4,
              return      INDICATOR sb4, 
              return);
/
-- update namespace array for schema for schemas and resource schema
update xdb.xdb$schema e
set e.xmlextra = 
         sys.xmltypeextra( 
            sys.xmltypepi( 
               xdb.xdb$getpickledns(
                    'http://www.w3.org/2001/XMLSchema', 
                    null), 
               xdb.xdb$getpickledns(
                    'http://xmlns.oracle.com/xdb', 
                    'xdb'), 
               xdb.xdb$getpickledns(
                    'http://xmlns.oracle.com/xdb/XDBResource.xsd', 
                    'xdbres') 
              ), 
            null)
where 
e.object_id = '6C3FCF2D9D354DC1E03408002087A0B7' or 
e.object_id = '8758D485E6004793E034080020B242C6';
commit;
drop function xdb.xdb$getPickledNS;


-- Nothing else for now, no other stuff needs to be touched.
