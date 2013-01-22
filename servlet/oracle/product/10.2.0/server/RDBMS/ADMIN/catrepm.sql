Rem
Rem $Header: catrepm.sql 03-dec-2002.09:36:08 alakshmi Exp $
Rem
Rem catrepm.sql
Rem
Rem Copyright (c) 1996, 2002, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      catrepm.sql - catalog script for master replication packages
Rem
Rem    DESCRIPTION
Rem      This script contains the packages for master replication.
Rem      This script should only be run after the catreps.sql 
Rem      script.  
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    alakshmi    11/21/02 - add post-schema procedural action for cleanup
Rem    sbalaram    05/30/02 - add prvthmig and prvtbmig
Rem    alakshmi    07/17/00 - Bug 1347847: remove semicolon
Rem    liwong      06/08/00 - Add prvthofl.plb
Rem    liwong      05/17/00 - add_master_db w/o quiesce
Rem    celsbern    04/28/00 - added prvtbrrq.sql prvthrrq.sql
Rem    wesmith     11/11/98 - Register an exp/imp procedural action for 
Rem                           system.repcat$_template_sites
Rem    wesmith     11/01/98 - Drop user cascade support for template tables    
Rem    celsbern    10/22/98 - added dbmsrint.sql and prvtbnt.sql.              
Rem    liwong      06/19/98 - add prvt{b,h}irp.sql
Rem    jstamos     04/17/98 - snapshot factoring for flavors                   
Rem    celsbern    03/26/98 - added support for refresh group template packages
Rem    jstamos     03/30/98 - add flavor packages for Al                       
Rem    liwong      04/18/97 - prvthrmg.plb --> dbmshrmg.sql
Rem    liwong      03/24/97 - add prvtbrmg.plb prvthrmg.plb
Rem    celsbern    01/02/97 - added insert into sys.duc$ and sys.expact$
Rem    liwong      11/25/96 - Move prvthunt.plb and prvtbunt.plb to catreps.sql
Rem    liwong      11/20/96 - Added system.repcatlogtrig
Rem    liwong      11/15/96 - Moved prvtdrep.plb to catreps.sql
Rem    celsbern    11/14/96 - Moved dbms_repcat_admin package to catreps.sql
Rem    celsbern    11/06/96 - Created
Rem
Rem The following install the replication PL/SQL packages.
Rem The dbmshrep.sql file must be first, followed by prvthdcl.plb.  
Rem Anything else can follow
@@dbmshrep.sql
@@prvthirp.plb
@@prvtsath.plb
@@prvthath.plb
@@prvthcnf.plb
@@prvthmas.plb
@@prvthrpc.plb
@@prvthrut.plb
@@prvthut2.plb
@@prvthut3.plb
@@prvthut4.plb
@@prvthval.plb
@@prvthowp.plb
@@prvthfma.plb
@@prvthrrq.plb
@@prvthadd.plb
@@prvthofl.plb
@@prvthmig.plb
@@dbmshrmg.sql
@@prvtbath.plb
@@prvtbcnf.plb
@@prvtbmas.plb
@@prvtbowp.plb
@@prvtbrep.plb
@@prvtbmig.plb
@@prvtbirp.plb
@@prvtbrpc.plb
@@prvtbrut.plb
@@prvtbut2.plb
@@prvtbut3.plb
@@prvtbut4.plb
@@prvtbval.plb
@@prvtbrmg.plb
@@prvtbfma.plb
@@prvtbrrq.plb
@@prvtbadd.plb
Rem end of replication packages
@@dbmsrctf
@@prvtrctf.plb
@@dbmsofln
@@prvtofln.plb
Rem refresh group templates
@@dbmsrgt
@@prvthrgt.plb
@@prvtbrgt.plb
@@dbmsrint
@@prvtbrnt.plb

Rem Added to support dbms_repcat.wait_master_log
GRANT EXECUTE ON dbms_alert TO system
/
CREATE OR REPLACE TRIGGER system.repcatlogtrig
AFTER UPDATE OR DELETE ON system.repcat$_repcatlog
BEGIN
  sys.dbms_alert.signal('repcatlog_alert', '');
END;
/

Rem  support sanity check upon import of system.repcat$_repschema
DELETE FROM sys.expact$
  WHERE owner='SYSTEM' AND name='REPCAT$_REPSCHEMA'
    AND func_proc='REPCAT_IMPORT_REPSCHEMA_STRING'
/
INSERT INTO sys.expact$(owner, name, func_schema, func_package, func_proc,
                        code, callorder, obj_type)
  VALUES('SYSTEM', 'REPCAT$_REPSCHEMA', 'SYS', 'DBMS_REPCAT',
         'REPCAT_IMPORT_REPSCHEMA_STRING', 2, 1, 2)
/
GRANT EXECUTE ON dbms_repcat TO SYSTEM
/

Rem support DROP USER CASCADE
DELETE FROM sys.duc$ WHERE owner='SYS' AND pack='DBMS_REPCAT_UTL' 
  AND proc='DROP_USER_REPSCHEMA' AND operation#=1
/
INSERT INTO sys.duc$ (owner, pack, proc, operation#, seq, com)
  VALUES ('SYS', 'DBMS_REPCAT_UTL', 'DROP_USER_REPSCHEMA', 1, 1,
          'Drop any local repschema for this user')
/
DELETE FROM sys.duc$ WHERE owner='SYS' and pack='DBMS_REPCAT_RGT_UTL' 
  and proc='DROP_USER_TEMPLATES' and operation#=1
/
INSERT INTO sys.duc$ (owner, pack, proc, operation#, seq, com)
  VALUES ('SYS','DBMS_REPCAT_RGT_UTL','DROP_USER_TEMPLATES', 1, 1,
          'Run during drop user cascade to drop all user template info')
/
commit
/
DELETE FROM exppkgact$ WHERE package = 'DBMS_REPCAT_RGT_EXP'
  AND schema = 'SYS' AND class = 2
/
insert into exppkgact$ (package, schema, class, level#)
values('DBMS_REPCAT_RGT_EXP', 'SYS', 2, 2)
/
COMMIT
/

Rem system-level
Rem This should be one of the first system-level actions to be executed,
Rem so set level# to 1.
DELETE FROM exppkgact$ WHERE package = 'DBMS_REPCAT_EXP'
  AND schema = 'SYS' AND class = 1
/
INSERT INTO exppkgact$ (package, schema, class, level#)
VALUES ('DBMS_REPCAT_EXP', 'SYS', 1, 1)
/
COMMIT
/

Rem schema-level
Rem This should be one of the last schema-level actions to be executed,
Rem so set level# to 5000
DELETE FROM exppkgact$ WHERE package = 'DBMS_REPCAT_EXP'
  AND schema = 'SYS' AND class = 2
/
INSERT INTO exppkgact$ (package, schema, class, level#)
VALUES ('DBMS_REPCAT_EXP', 'SYS', 2, 5000)
/
COMMIT
/
