Rem
Rem $Header: xdbeu101.sql 18-feb-2005.15:51:11 thbaby Exp $
Rem
Rem xdbeu101.sql
Rem
Rem Copyright (c) 2004, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      xdbeu101.sql - XDB Downgrade Data Script
Rem
Rem    DESCRIPTION
Rem      Downgrade XDB data (i.e., not schemas) from 10.2 to 10.1
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    thbaby      02/18/05 - grant PUBLIC access to xdbconfig.xml
Rem    spannala    09/02/04 - spannala_lrg-1734670
Rem    spannala    08/24/04 - Created
Rem
--
-- data downgrade to 10.1

-- set the acl of xdbconfig.xml to the bootstrap acl
-- don't care about migrate status since setacl is an idempotent opern
DECLARE
  acl_abspath          VARCHAR2(200);
  b_abspath VARCHAR(20) := '/xdbconfig.xml';
BEGIN
   acl_abspath := '/sys/acls/bootstrap_acl.xml';
   dbms_xdb.setAcl(b_abspath, acl_abspath);	
END;
/

-- Revoke XDBADMIN privileges on xdbconfig
-- Grant PUBLIC access to xdbconfig
revoke all on xdb.xdb$config from xdbadmin;
grant all on xdb.xdb$config to public ; 


