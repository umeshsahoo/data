Rem
Rem $Header: catreps.sql 08-mar-2001.11:11:29 arrajara Exp $
Rem
Rem catreps.sql
Rem
Rem  Copyright (c) Oracle Corporation 1996, 2000. All Rights Reserved.
Rem
Rem    NAME
Rem      catreps.sql - This script handles the installation of the
Rem      PL/SQL packages for snapshot functionality.
Rem
Rem    DESCRIPTION
Rem      This script contains all of the packages and procedures 
Rem      for snapshot functionality.  This script must be loaded
Rem      before the master (catrepm.sql) script, and is always
Rem      installed if replication is installed.
Rem
Rem    NOTES
Rem      Any additional packages that are required for snapshots
Rem      are installed from this script.  Any other replication 
Rem      related procedures are called from the catrepm.sql 
Rem      script.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    arrajara    03/08/01 - remove set echo statements
Rem    nshodhan    03/02/01 - Bug#1567478: remove synonym for dbms_offline_snapshot
Rem    arithikr    12/28/00 - 1489592: regression
Rem    arithikr    11/27/00 - 1489592: drop synonym dbms_offline_snapshot
Rem    elu         07/27/00 - type evolution: use hashcode
Rem    elu         07/18/00 - prvtobjg split into prvthobg, prvtbobg,
Rem                           prvtbog2, prvtbog3
Rem    elu         06/14/00 - add prvthsqu.sql, prvtbsql.sql
Rem    liwong      06/14/00 - Add prvthcut.plb, prvtbcut.plb
Rem    liwong      11/11/99 - repl obj: add system.repcat_object_null_vector
Rem    liwong      07/29/99 - Add prvthout, prvtbout                           
Rem    celsbern    07/07/99 - added synonyms for offline_snapshot and 
Rem                           offline_og
Rem    nshodhan    02/26/99 - bug-789058: Remove obsolete files
Rem    liwong      12/04/98 - Support multiple grps at same snap site          
Rem    wesmith     11/09/98 - Changed package location for exp/imp 
Rem                           procedural action
Rem    wesmith     11/06/98 - Register an exp/imp procedural action for 
Rem                           sys.snap_site$, system.def$_pushed_tranactions
Rem    liwong      07/30/98 - Move prvthutl before prvtdefr                    
Rem    arrajara    06/30/98 - synonym for dbms_internal_repcat
Rem    celsbern    06/15/98 - added calls for prvtbtop.sql prvthtop.sql        
Rem    celsbern    06/11/98 - added prvthoft.plb and prvtboft.sql              
Rem    liwong      06/01/98 - move prvtbint, prvtbipk after prvthdcl
Rem    celsbern    04/24/98 - added synonym for dbms_repcat_rgt                
Rem    jstamos     04/17/98 - snapshot factoring for flavors                   
Rem    liwong      12/01/97 - add prvthint, prvtbint
Rem    liwong      10/31/97 - add prvthipk, prvtbipk                           
Rem    wesmith     09/16/97 - Untrusted security model enhancements
Rem    jstamos     12/20/96 - move dbmsdefr earlier
Rem    liwong      11/25/96 - move prvthunt.plb, prvtbunt.plb from catrepm.sql
Rem    liwong      11/18/96 - Added synonyms for dbms_repcat_rpc, 
Rem                           dbms_repcat_utl2, dbms_rectifier_diff,
Rem                           dbmsobjgwrapper, dbms_repcat
Rem    liwong      11/15/96 - Moved prvtdrep.plb to this file
Rem    celsbern    11/14/96 - Moved dbms_repcat_admin to this file.
Rem    celsbern    11/14/96 - Added alter package to cleanup dbms_snapshot.
Rem                           and added synonym to dbms_repcat.
Rem    celsbern    11/06/96 - Created
Rem

Rem
Rem Create the type for dbms_defer_query.get_object_null_vector_arg
Rem If this type is changed, make sure the references to the type in the code
Rem are also changed.
Rem
CREATE TYPE system.repcat$_object_null_vector AS OBJECT
(
  -- type owner, name, hashcode for the type represented by null_vector
  type_owner      VARCHAR2(30),
  type_name       VARCHAR2(30),
  type_hashcode   RAW(17),
  -- null_vector for a particular object instance
  -- ROBJ REVISIT: should only contain the null image, and not version#
  null_vector     RAW(2000)
)
/

@@prvthdcl.plb
@@prvtrpch.plb
@@prvthipk.plb
@@prvthint.plb
@@prvthtop.plb
@@dbmsgen
@@dbmsdefr
@@prvtgen.plb
@@prvthout.plb
@@prvthutl.plb
@@prvtdfri.plb
@@prvthsqu.plb
@@prvtarpp.plb
@@prvthcut.plb
@@prvtdefr.plb
@@prvthobg.plb
@@prvtbobg.plb
@@prvtbog2.plb
@@prvtbog3.plb
@@prvtbint.plb
@@prvtbipk.plb
@@prvtbtop.plb
@@prvtbout.plb
@@dbmshsna
Rem The following synonym makes it look like the dbms_repcat package
Rem is installed even though it is not.
create public synonym dbms_repcat for dbms_repcat_sna
/
Rem Another synomym to hide missing package.  This synonym makes 
Rem the dbms_repcat_rgt package look like it is installed even 
Rem though it is not. None of the dbms_repcat_rgt procedures 
Rem are available at a snapshot site. 
create public synonym dbms_repcat_rgt for dbms_repcat_sna
/
@@prvthsut.plb
@@prvthunt.plb
@@prvthdmn.plb
@@prvthfla.plb
@@prvthfut.plb
@@dbmsofsn
@@prvtbdcl.plb
@@prvtbutl.plb
@@prvtbsqu.plb
@@prvtbcut.plb
@@prvtbsut.plb
@@prvtbsna.plb
@@prvtbunt.plb
@@prvtdrep.plb
@@prvtofsn.plb
@@prvtbdmn.plb
@@prvtbfut.plb
@@prvtbfla.plb
@@prvthoft.plb
@@prvtboft.plb

Rem The following has been added to straighten out a dependency problem
alter package sys.dbms_snapshot compile body
/

Rem The following synonyms make the grant execute on dbms_repcat_% which
Rem exist in master site, but not in snapshot site succesful in
Rem dbms_repcat_admin.grant_admin_%_schema.
create synonym dbms_repcat for dbms_repcat_sna
/
create synonym dbms_internal_repcat for dbms_repcat_sna
/
create synonym dbms_repcat_rpc for dbms_repcat_sna
/
create synonym dbms_repcat_utl2 for dbms_repcat_sna
/
create synonym dbms_rectifier_diff for dbms_repcat_sna
/
create synonym dbmsobjgwrapper for dbms_repcat_sna
/
create synonym dbms_repcat_rgt for dbms_repcat_sna
/
create synonym dbms_offline_og for dbms_repcat_sna
/


Rem Set up export actions for RepAPI tables:
Rem sys.snap_site$ table and system.def$_pushed_transactions

DELETE FROM exppkgact$ WHERE package = 'DBMS_REFRESH_EXP_SITES'
  AND schema = 'SYS' AND class = 2
/
insert into exppkgact$ (package, schema, class, level#)
values('DBMS_REFRESH_EXP_SITES', 'SYS', 2, 1)
/
DELETE FROM exppkgact$ WHERE package = 'DBMS_REFRESH_EXP_LWM'
  AND schema = 'SYS' AND class = 2
/
insert into exppkgact$ (package, schema, class, level#)
values('DBMS_REFRESH_EXP_LWM', 'SYS', 2, 2)
/
COMMIT
/
