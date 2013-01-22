Rem ##########################################################################
Rem 
Rem Copyright (c) 2001, 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catodm.sql
Rem
Rem    DESCRIPTION
Rem      Run all sql scripts for Data Mining Installation 
Rem
Rem    RETURNS
Rem 
Rem    NOTES
Rem      This script must be run while connected as SYS   
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem       xbarr    11/05/04 - remove validation proc from dmsys 
Rem       pstengar 08/24/04 - add prvtdmpa.plb 
Rem       fcay     06/30/04 - Use dbmsdmpa.sql 
Rem       svenkaya 06/29/04 - added prvtdmj 
Rem       xbarr    06/28/04 - run dmsyssch.sql only 
Rem       xbarr    06/23/04 - Merge dmpproc to dmproc, remove dmapi/dmutil
Rem       mmcracke 06/21/04 - Merge dmpsyssch.sql into dmsyssch.sql 
Rem       cbhagwat 06/18/04 - Change blast name
Rem       amozes   06/23/04 - remove hard tabs
Rem       cbhagwat 06/09/04 - code reorg
Rem       xbarr    06/07/04 - update ojdm
Rem       xbarr    10/20/03 - update pmml dtd loading 
Rem       fcay     06/23/03 - Update copyright notice
Rem       xbarr    06/02/03 - remove dmpsysup 
Rem       xbarr    03/10/03 - add dmcl.plb 
Rem       xbarr    03/08/03 - remove odmerr.sql 
Rem       xbarr    02/26/03 - fix error in odm.log 
Rem       xbarr    02/03/03 - add odmproc      
Rem       xbarr    01/27/03 - add dmpsysup 
Rem       xbarr    01/06/03 - add PL/SQL api code for Beta
Rem       xbarr    11/19/02 - add blast 
Rem       xbarr    10/10/02 - remove odmcrt from script. To be run by dminst
Rem       xbarr    09/25/02 - xbarr_txn104463
Rem       xbarr    09/24/02 - updated for 10i installation to be called by odminst 
Rem       xbarr    09/24/02 - replicated from 9202 branch
Rem       xbarr    08/02/02 - xbarr_txn102957
Rem       xbarr    06/06/02 - relocate odmdbmig script to in dm/admin/odmu901.sql
Rem       xbarr    03/12/02 - add dmerrtbl_mig 
Rem       xbarr    03/08/02 - add registry information in dba_registry 
Rem       xbarr    03/07/02 - add error table loading
Rem       xbarr    03/07/02 - use separate sqlldr related file
Rem       xbarr    03/07/02 - remove odmupd line
Rem       xbarr    01/24/02 - add dmmig.sql for R2 privileges 
Rem       xbarr    01/21/02 - add PMML dataset addition 
Rem       xbarr    01/14/02 - commented out dmupd. Will be replaced by dmconfig
Rem       xbarr    01/14/02 - use .plb 
Rem       xbarr    12/10/01 - Merged xbarr_update_shipit
Rem       xbarr    12/04/01 - Merged xbarr_migration_scripts
Rem
Rem    xbarr    12/10/01 - Updated script name and location
Rem    xbarr    12/03/01 - Updated to be called by ODMA
Rem    xbarr    10/27/01 - Creation
Rem
Rem #########################################################################


ALTER SESSION SET CURRENT_SCHEMA = "DMSYS";

Rem Load 10i DMSYS schema definition
@@dmsyssch.sql

Rem Load DMSYS package/procedure objects
@@dmproc.sql

Rem Load Trusted Code BLAST
@@dbmsdmbl.sql

Rem Load ODM Predictive package
@@dbmsdmpa.sql
@@prvtdmpa.plb

Rem Load OJDM internal package
@@prvtdmj.plb

Rem DM validate proc
Rem @@odmproc.sql
