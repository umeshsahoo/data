Rem
Rem $Header: xdbdbmig.sql 15-feb-2005.11:06:31 vkapoor Exp $
Rem
Rem xdbdbmig.sql
Rem
Rem Copyright (c) 2002, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      xdbdbmig.sql - Xml DB DataBase MIGrate
Rem
Rem    DESCRIPTION
Rem      Upgrade script for XDB from all supported prior releases.
Rem
Rem    NOTES
Rem      None
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    vkapoor     02/15/05 - LRG 1830972. xdbreload needs to be called if upgrade
Rem                           is rerun.
Rem    pnath       01/19/05 - call xdbinst.sql instead of xdbinstlltab.sql 
Rem    vkapoor     12/16/04 - A new script for upgrade reload 
Rem    pnath       11/22/04 - delete all objects introduced in xdb 
Rem                           installation 
Rem    pnath       10/25/04 - Make SYS the owner of DBMS_REGXDB package 
Rem    spannala    05/04/04 - drop xdbhi_idx and recreate later
Rem    thbaby      01/30/04 - adding 10GR1 upgrade 
Rem    spannala    10/20/03 - migrate status at the beginning of upgrade 
Rem                           should be set correctly as per release
Rem    spannala    06/18/03 - making xdbreload generic enough for all upgrades
Rem    spannala    06/09/03 - in 9201 upgd, call xdbptrl2 at the end
Rem    njalali     04/16/03 - removing ?/ notation
Rem    njalali     04/02/03 - not calling xdbrelod twice on 9.2.0.1 upgrade
Rem    njalali     03/27/03 - dropping xdb$patchupschema
Rem    njalali     02/10/03 - enabling upgrade from 9.2.0.3 to 10i
Rem    njalali     01/16/03 - bug 2744444
Rem    njalali     11/21/02 - njalali_migscripts_10i
Rem    njalali     11/21/02 - Incorporated review comments
Rem    njalali     11/14/02 - Created
Rem

Rem Clean up any shared memory taken by JavaVM or anyone else
alter system flush shared_pool;
alter system flush shared_pool;
alter system flush shared_pool;

WHENEVER SQLERROR EXIT;
EXECUTE dbms_registry.check_server_instance;
WHENEVER SQLERROR CONTINUE;

Rem Note that a trigger needs to be added in future releases
Rem so that all objects created during upgrade is added
Rem to the table xdb_installation_tab, and the dropping
Rem of these objects are to be handled in catnoqm.sql


Rem Create the table xdb_installation_tab if it doesn't exist
Rem This table ensures that all objects are deleted 
Rem during the time of XDB un-installation, which were
Rem created as a part of XDB installation.
@@xdbinst

-- Create the table that keeps track of how far along we are in the migration
begin
  execute immediate 'select count(*) from xdb.migr9202status';
exception
  when others then
    execute immediate 'create table xdb.migr9202status (n integer)';
    execute immediate 'insert into xdb.migr9202status values (400)';
    commit;
end;
/

Rem XDB$PATCHUPSCHEMA will have errors
drop procedure xdb$patchupschema;

Rem Setup component script filename variable
COLUMN :relo_name NEW_VALUE relo_file NOPRINT
VARIABLE relo_name VARCHAR2(50)
COLUMN :script_name NEW_VALUE comp_file NOPRINT
VARIABLE script_name VARCHAR2(50)

-- DROP package xdb.dbms_regxdb
drop package xdb.dbms_regxdb;

-- Create the registry package and the validation procedure
@@dbmsxreg

-- Load package sys.dbms_regxdb
@@prvtxreg.plb

Rem We must run xdbrelod.sql at the end of the upgrade
Rem in order to reload the XML DB packages.
Rem
DECLARE
  start_status integer := 400;
  version      varchar2(60);
BEGIN
  :relo_name := '@xdbrelod.sql';
  select dbms_registry.version('XDB') into version from dual;
  IF substr(version, 1, 7) = '9.2.0.1' THEN
    :script_name := '@xdbu920.sql';
    :relo_name := '@xdbrlu.sql';
    start_status := 0;
  ELSIF substr(version, 1, 5) = '9.2.0'   THEN
    -- The upgrade script for all other 92 versions
    :script_name := '@xdbu9202.sql';
    :relo_name := '@xdbrlu.sql';
  ELSIF substr(version, 1, 6) = '10.1.0'   THEN
    :script_name := '@xdbu101.sql';
    :relo_name := '@xdbrlu.sql';
    start_status := 500;
  END IF;

  -- Set the start status correctly if this script is being run for the
  -- first time.
  IF dbms_registry.status('XDB') = 'VALID' THEN
    -- This change will get committed along with the dbms_registry.upgrading
    -- commit below.
    update xdb.migr9202status set n = start_status;
  END IF;
END;
/


-- This sets the stauts to upgrading and commits the above change 
-- to migr9202status, if any
EXECUTE dbms_registry.upgrading('XDB', 'Oracle XML Database', 'DBMS_REGXDB.VALIDATEXDB');

-- Drop the xdbhi_idx index This will get recreated later in the upgrade
declare
 ct number;
begin
  select count(*) into ct from dba_indexes where owner = 'XDB' and 
    index_name = 'XDBHI_IDX';
    if ct > 0 then
      execute immediate 'disassociate statistics from ' ||
                        'indextypes xdb.xdbhi_idxtyp force';
      execute immediate 'disassociate statistics from ' ||
                        'packages xdb.xdb_funcimpl force';
      execute immediate 'drop index xdb.xdbhi_idx';
    end if;
end;
/

SELECT :script_name FROM DUAL;
@&comp_file
SELECT :relo_name FROM DUAL;
@&relo_file

EXECUTE dbms_registry.upgraded('XDB');

Rem EXECUTE sys.dbms_regxdb.validatexdb();
Rem Set XDB version to the current release.
execute dbms_registry.loaded('XDB');

Rem Set XDB to a valid state.
Rem We cannot use sys.dbms_regxdb.validatexdb() because 
Rem resource_view is unusable until the DB is restarted.
execute sys.dbms_registry.valid('XDB');
