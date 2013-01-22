
Rem
Rem $Header: catqm.sql 17-jan-2006.13:17:09 bkhaladk Exp $
Rem
Rem catqm.sql
Rem
Rem Copyright (c) 1900, 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catqm.sql - CAtalog script for sQl xMl management 
Rem
Rem    DESCRIPTION
Rem      Creates the tables and views needed to run the XDB system 
Rem      Run this script like this:
Rem        catqm.sql <XDB_PASSWD> <TABLESPACE> <TEMP_TABLESPACE>
Rem    NOTES
Rem      Must be run connected as SYS 
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    bkhaladk    01/17/06  - grant execute on utl_file to xdb 
Rem    rmurthy     03/09/05  - drop function for patching namespace 
Rem    vkapoor     01/13/05 -  LRG 1804464 
Rem    pnath       12/01/04 - prvtxdb.sql needs prvtxmld.sql to be compiled 
Rem    pnath       11/16/04 - delete all objects created in installation 
Rem    rpang       11/18/04 - Add catepg.sql
Rem    rmurthy     11/11/04 - add dbmsxidx
Rem    pnath       10/22/04 - Make SYS the owner of package dbms_regxdb 
Rem    fge         10/29/04 - call prvtxdr0
Rem    attran      08/20/04 - xmlidx
Rem    rburns      08/17/04 - conditionally run dbmsxdbt 
Rem    rpang       07/16/04 - Renamed epgc to epg
Rem    sbalaram    06/10/04 - Add catxlcr - xml schema definitions for LCRs
Rem    rpang       06/07/04 - Add dbmsepgc.sql and prvtepgc.plb
Rem    smukkama    02/27/04 - move catxdbtm.sql to after prvtxdb.sql
Rem    smukkama    01/05/04 - add catxdbtm.sql for compact xml token mgmt
Rem    attran      02/17/04 - XMLIndex 
Rem    najain      01/27/04 - call prvtxdb0 and prvtxdz0
Rem    fge         08/01/03 - xdb$h_link: add secondary index on child_oid
Rem    sidicula    07/03/03 - prvtxdb to be executed after prvtxdbz
Rem    fge         05/19/03 - add catxdbeo.sql
Rem    sidicula    04/16/03 - Revoke powerful privileges from XDB
Rem    abagrawa    03/09/03 - Separate dbmsxsch and prvtxsch
Rem    njalali     02/11/03 - setting upgrade state to 1000
Rem    smuralid    01/09/03 - add dbmsxdbt
Rem    sichandr    12/16/02 - invoke pre-condition checks
Rem    njalali     11/14/02 - making sure 9.2.0.1 -> 9.2.0.2 mig. is noop
Rem    mkrishna    07/05/02 - dissallow ref cascade for resource and schema tables
Rem    fge         06/13/02 - rename prvtpidx.sql to prvtxdbp.sql
Rem    sichandr    04/14/02 - remove index on refcount
Rem    spannala    03/26/02 - tieing the xdb version to the database version
Rem    sidicula    02/22/02 - Anonymous login allowed only by HTTP
Rem    njalali     02/11/02 - removed refcount from H_INDEX
Rem    rmurthy     02/20/02 - remove owner user
Rem    fge         01/20/02 - call prvtxdbr.plb
Rem    fge         01/08/02 - rename prvtxdbpi.sql to prvtpidx.sql
Rem    spannala    01/13/02 - correcting compilation errors in prvtxreg
Rem    spannala    01/02/02 - registry
Rem    sichandr    01/11/02 - catxdbstd.sql becomes catxdbst.sql
Rem    spannala    01/11/02 - creating all types with fixed toids
Rem    rmurthy     01/18/02 - add xdbowner role
Rem    nmontoya    12/18/01 - grant select any table to xdb
Rem    spannala    12/19/01 - removing connects, creating objects in xdb schema
Rem    spannala    12/13/01 - beta showstopper cleanup
Rem    nmontoya    11/29/01 - replace calls of prvt*.sql to prvt*.plb
Rem    nmontoya    11/14/01 - changing owner ID to GUID
Rem    nmontoya    11/13/01 - reorder dbmsxdb pkg
Rem    nagarwal    11/12/01 - change ordering of packages
Rem    tsingh      11/09/01 - XDB Fake installation and cleanup.
Rem    nagarwal    11/08/01 - change ordering of catxdbpi.sql 
Rem    najain      11/08/01 - catxdbpi.sql gets loaded before catxdbz.sql
Rem    nagarwal    11/05/01 - add catxdbpi.sql
Rem    nle         09/20/01 - add versioning package
Rem    abagrawa    09/27/01 - Add catxdbc1, catxdbc2
Rem    nmontoya    10/12/01 - ADD xdbadmin role
Rem    nagarwal    09/08/01 - add catxdbpv
Rem    nmontoya    08/21/01 - ADD pl/sql dom, xml parser, AND xsl processor
Rem    nmontoya    08/16/01 - grant alter session and dbms_rls execute to xdb
Rem    nagarwal    08/10/01 - add catxdbr
Rem    esedlar     08/09/01 - XDB standard packages
Rem    njalali     07/11/01 - Resource as XMLType
Rem    spannala    05/18/01 - xmltype_p -> xmltype
Rem    njalali     05/17/01 - split schema OID in resource into two columns
Rem    rmurthy     03/09/01 - move schema related setup to catxdbs.sql
Rem    tsingh      03/01/01 - load xdb.jar
Rem    njalali     02/15/01 - reinstated the WITH ROWID in the resource table
Rem    nmontoya    02/14/01 - Add security initialization
Rem    njalali     02/13/01 - added schema OID to resource table
Rem    rmurthy     02/02/01 - add support for element ref
Rem    mkrishna    01/29/01 - remove xmlindex related stuff 
Rem    rmurthy     01/17/01 - changes to allow case-sensitive names
Rem    rmurthy     12/01/00 - grant create library to xdb
Rem    esedlar     11/01/00 - Add SQL schema
Rem    njalali     10/03/00 - removed 'datatype' from resource table
Rem    esedlar     09/27/00 - Add schema in uniqueness constraints
Rem    njalali     09/26/00 - removed the 'with rowid' in XDB$RESOURCE.
Rem    tsingh      09/22/00 - added catxdbdt.sql
Rem    nmontoya    09/18/00 - Changing default tablespace for xdb schema.
Rem    esedlar     09/05/00 - Type cache
Rem    njalali     08/15/00 - changed H_LINK to XDB$H_LINK.
Rem    tsingh      06/30/00 - Fix tablespace code.
Rem    tsingh      06/28/00 - sys to system.
Rem    tsingh      06/20/00 - Resource tables.
Rem    mkrishna    06/29/00 - add dbmsxidx 
Rem    njalali     04/20/00 - Initial revision
Rem    njalali     01/00/00 - Created
Rem
  
define xdb_pass    = &1
define res_tbs     = &2
define temp_tbs    = &3


Rem Table xdb_installation_tab will store all objects created
Rem as a part of XDB installation, where owner is not XDB.
Rem Objects already existing in the database and recreated 
Rem as a part of the installation, will not be added to the table.
Rem This table will be used during un-installation of XDB, 
Rem when all these objects will then be dropped. This table 
Rem need not contain objects which will be dropped automatically 
Rem as a result of dropping some other object 
Rem (eg. all PACKAGE BODY objects will be dropped when corresponding
Rem PACKAGE object is dropped).
Rem Point to note: Currently only certain object types are 
Rem inserted into this table. The creation of objects of 
Rem object type not handled will result in the need to modify 
Rem the trigger responsible for populating xdb_installation_tab.
CREATE TABLE sys.xdb_installation_tab (
   Owner           VARCHAR2(200),
   Object_name     VARCHAR2(200),
   Object_type     VARCHAR2(200));


Rem Table dropped_xdb_instll_tab will consist of the items that
Rem existed prior to XDB installation and were dropped during 
Rem XDB installation. Creation of an object during the installation
Rem that is present in this table will not be added to 
Rem xdb_installation_tab, as this implies that the object did 
Rem exist prior to the installation.
CREATE TABLE sys.dropped_xdb_instll_tab (
   Owner           VARCHAR2(200),
   Object_name     VARCHAR2(200),
   Object_type     VARCHAR2(200));

Rem A trigger for every successful drop on the database during 
Rem XDB installation
create or replace trigger sys.dropped_xdb_instll_trigger
  AFTER
    DROP ON DATABASE
    BEGIN
      insert into dropped_xdb_instll_tab values
          (dictionary_obj_owner, dictionary_obj_name, dictionary_obj_type);
    END;
/

Rem A trigger for every object creation during XDB installation
Rem The trigger body may need to be modified if other object types
Rem are to be handled, which are currently not handled. In addition,
Rem catnoqm.sql might need to be modified to handle special
Rem cases while dropping objects.
create or replace trigger sys.xdb_installation_trigger
  BEFORE
    CREATE ON DATABASE
    DECLARE
       sql_text varchar2(200);
       val number;
    BEGIN
      if (dictionary_obj_owner != 'XDB') then
        if (dictionary_obj_type = 'FUNCTION' or
            dictionary_obj_type = 'INDEX' or
            dictionary_obj_type = 'PACKAGE' or
            dictionary_obj_type = 'PACKAGE BODY' or
            dictionary_obj_type = 'PROCEDURE' or
            dictionary_obj_type = 'SYNONYM' or
            dictionary_obj_type = 'TABLE' or
            dictionary_obj_type = 'TABLESPACE' or
            dictionary_obj_type = 'TYPE' or
            dictionary_obj_type = 'VIEW' or
            dictionary_obj_type = 'USER'
          )then
          if (dictionary_obj_type  != 'PACKAGE BODY' 
             ) then
            sql_text := 'select count(*) from ALL_OBJECTS where owner = :1 and object_name = :2 and object_type = :3';
            execute immediate sql_text into val using dictionary_obj_owner, dictionary_obj_name, dictionary_obj_type;
            if (val = 0) then
               sql_text := 'select count(*) from dropped_xdb_instll_tab where owner = :1 and object_name = :2 and object_type = :3';
               execute immediate sql_text into val using dictionary_obj_owner, dictionary_obj_name, dictionary_obj_type;
               if (val = 0) then
                  insert into xdb_installation_tab values
                  (dictionary_obj_owner, dictionary_obj_name, dictionary_obj_type);
               end if;
            end if;
          end if;
        else
          raise_application_error(-20000, 'Trigger xdb_installation_trigger does not support object creation of type '||dictionary_obj_type); 
        end if;
      end if;
   end;
/

Rem Check for pre-conditions
@@catxdbck &xdb_pass &res_tbs &temp_tbs

Rem Create XDB User.
create user xdb identified by &xdb_pass account lock password expire 
       default tablespace &res_tbs temporary tablespace &temp_tbs;

Rem Invoke Registry. The package is defined later.
EXECUTE dbms_registry.loading('XDB', 'Oracle XML Database', 'DBMS_REGXDB.VALIDATEXDB', 'XDB');

Rem should go away soon
create user anonymous identified by values 'anonymous' default tablespace &res_tbs;
grant create session to anonymous;
alter user anonymous account lock;

grant resource to xdb;
grant create session to xdb;
grant alter session to xdb;
GRANT execute ON dbms_rls TO xdb;
grant unlimited tablespace to xdb;
grant create library to xdb;
grant create public synonym to xdb;
grant drop public synonym to xdb;
GRANT SELECT ON user$ TO xdb;
grant execute on sys.utl_file to xdb;

CREATE role xdbadmin;
GRANT xdbadmin TO dba;

-- Pseudo user that can be used in ACLs to refer to the resource owner
-- create user owner identified by values 'OWNER';

-- Needed for prvtxdbz
grant administer database trigger to xdb;

-- Needed for catxdbj
GRANT javauserpriv TO xdb;

-- Needed by catxdbr and catxdbpi
grant create view to xdb;
grant query rewrite to xdb;
grant create operator to xdb;
grant create indextype to xdb;

-- Needed by catxdbpi
-- This is needed because we are selecting from the hierarchially enabled
-- table (as a part of the path index trigger) while dropping/truncating it.

/* REF CASCADE IS DISSALLOWED FOR SCHEMA AND RESOURCE TABLES */

/* turn off the REF cascade semantics for resource$ */
alter session set events '22830 trace name context forever, level 4';

-- XDB$ROOT_INFO table
create table xdb.xdb$root_info (resource_root rowid);

-- XDB$H_INDEX table
create table xdb.xdb$h_index 
  (
    oid raw(16), 
    acl_id raw(16), 
    owner_id raw(16),
    flags raw(4), 
    children BLOB
  ) 
  pctfree 99 pctused 1;

CREATE INDEX xdb.xdb$h_index_oid_i ON xdb.xdb$h_index (OID);

create type xdb.xdb$link_t OID '00000000000000000000000000020151' AS OBJECT
(
    parent_oid  raw(16),
    child_oid   raw(16),
    name        varchar2(256),
    flags       raw(4),
    link_sn     raw(16)
);
/

create table xdb.xdb$h_link of xdb.xdb$link_t
(
    constraint xdb_pk_h_link primary key (parent_oid, name)
) organization index;

create index xdb.xdb_h_link_child_oid on xdb.xdb$h_link(child_oid);


------------------------------------------------------------------------------
Rem Create XML schema related types and tables
@@catxdbs.sql

Rem Add XDB schema for schemas
@@catxdbdt.sql

Rem Create XML resource schema related types and tables
@@catxdbrs.sql

Rem Add XDB schema for resources
@@catxdbdr.sql

/* turn off the ref cascade event */
alter session set events '22830 trace name context off';

Rem Add the schema registration/compilation module
@@dbmsxsch.sql

Rem Add the security module
@@dbmsxdbz.sql

Rem Add definition for various xdb utilities  
@@dbmsxdb.sql

Rem Create Path Index
@@catxdbpi

-- Load the dbms_xdbutil_int specification
@@prvtxdb0.plb

-- Load the dbms_xdbz0 specification
@@prvtxdz0.plb

Rem Implementation of XDB Security modules
@@prvtxdbz.plb

REM ADD pl/sql dom, xml parser, AND xsl processor
@@dbmsxmld.sql
@@dbmsxmlp.sql
@@dbmsxslp.sql
@@prvtxmld.plb
@@prvtxmlp.plb
@@prvtxslp.plb

Rem Implementation of XDB Utilities
@@prvtxdb.plb

Rem Create the Compact XML Token Manager tables
@@catxdbtm.sql

Rem Implementation of schema registration/compilation module
@@prvtxsch.plb

Rem Resource View
@@prvtxdr0.plb
@@catxdbr.sql 

Rem Resource view implementaion
@@prvtxdbr.plb

Rem XDB Path Index Implementation
@@prvtxdbp.plb 

Rem Initialize bootstrap acl
@@catxdbz.sql

Rem Initialize XDB standard packages (Configuration, Servlets, etc.)
@@catxdbst.sql

Rem Create the Versioning Package 
@@catxdbvr.sql

Rem Create Path View
@@catxdbpv

Rem Create the XMLIndex
@@catxidx

Rem Initialize extensible optimizer
@@catxdbeo.sql

Rem Initialize XDB configuration management
@@catxdbc1
@@catxdbc2

Rem Create Embedded PL/SQL Gateway package and schema objects
@@dbmsepg
@@prvtepg.plb
@@catepg

Rem Add the various views to be created on xdb data
@@catxdbv

Rem Create helper package for text index on xdb resource data
COLUMN xdb_name NEW_VALUE xdb_file NOPRINT;
SELECT dbms_registry.script('CONTEXT','@dbmsxdbt.sql') AS xdb_name FROM DUAL;
@&xdb_file

Rem Create helper package for xml index
@@dbmsxidx

Rem Add XML schema definitions for LCRs
@@catxlcr

Rem Indicate that xdb has been Loaded
begin
dbms_registry.loaded('XDB', dbms_registry.release_version,
           'Oracle XML Database Version ' || dbms_registry.release_version ||
           ' - ' || dbms_registry.release_status);
end;
/

Rem Create the registry package and the validation procedure
@@dbmsxreg

grant execute on dbms_registry to xdb;

@@prvtxreg.plb

revoke administer database trigger from xdb;

Rem Invoke Validation for registry.
execute sys.dbms_regxdb.validatexdb;

Rem Show that no upgrade is needed to bring XDB to a valid 10.1 state.
create table xdb.migr9202status (n integer);
insert into xdb.migr9202status values (1000);

Rem drop objects created to track object creation during XDB
Rem installation
drop trigger sys.xdb_installation_trigger;
drop trigger sys.dropped_xdb_instll_trigger;
drop table dropped_xdb_instll_tab;
drop package xdb.xdb$bootstrap;
drop package xdb.xdb$bootstrapres;
drop function xdb.xdb$getPickledNS;

commit;
