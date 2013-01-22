Rem
Rem $Header: catsvrm.sql 17-may-2005.17:53:09 mlfeng Exp $
Rem
Rem catsvrm.sql
Rem
Rem Copyright (c) 2002, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catsvrm.sql - Catalog script for Server Manageability
Rem
Rem    DESCRIPTION
Rem      Runs all scripts for Server Manageability
Rem
Rem    NOTES
Rem      This script must be run when connected as SYSDBA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mlfeng      04/26/05 - move creation of db feature usage 
Rem    kyagoub     09/26/04 - add catsqltv to create sqltune views 
Rem    mlfeng      08/19/04 - reorganize files
Rem    pbelknap    10/28/03 - swrf to awr, everywhere 
Rem    kdias       05/02/03 - move prvthdm after prvtadv
Rem    gssmith     05/02/03 - Add prvtwrk package
Rem    jxchen      05/12/03 - Add maintenance window definition scripts
Rem    veeve       03/12/03 - moved manageability components like HDM
Rem                           adv framework, undo adv here from catproc
Rem    bdagevil    02/07/03 - remmove cathints.sql
Rem    mlfeng      01/24/03 - Add catdbfus.sql
Rem    atsukerm    12/23/02 - add cathints.sql
Rem    kyagoub     12/10/02 - add sqltune and swo catalog
Rem    jxchen      10/16/02 - Add server alert schema creation
Rem    atsukerm    10/23/02 - end-to-end tracing
Rem    mlfeng      07/08/02 - swrf flushing
Rem    mlfeng      06/11/02 - Created
Rem

Rem Create the DB Feature Usage tables/views
@@catdbfus

Rem Create server alert schema
@@catalrt

Rem Run DBMS_MONITOR script
@@catmntr

Rem Maintenance window and job definition
@@catmwin.sql

Rem packages for manageability advisor
  
Rem Advisory framework
@@prvtadv.plb

Rem SQL Access Advisor workload
@@prvtwrk.plb
  
Rem Access advisor
@@prvtsmaa.plb

Rem Advisory framework (DBMS_ADVISOR API)
@@prvtdadv.plb
  
REM --------------------------------------------------------------
REM the following must be included AFTER prvtadv
REM --------------------------------------------------------------

Rem The following script will create the AWR tables
@@catawrtb.sql
    
Rem Sqltune catalog: sqlprofile/sqlset/sqltune advisor
@@catsqlt.sql

Rem Create the DBMS_WORKLOAD_REPOSITORY package
@@dbmsawr.sql

Rem packages for manageability undo advisor 
@@dbmsuadv.sql

Rem SQL Tuning Package specification
@@dbmssqlt.sql

Rem sqltune views: sqlprofile/sqlset/sqltune advisor
@@catsqltv.sql

Rem The following script will create the DBA_HIST views for the 
Rem Automatic Workload Repository (AWR).  This script must follow
Rem dbmssqlt.sql since we use a dbms_sqltune routine in one of 
Rem the DBA_HIST views.
@@catawrvw.sql

Rem Create DBMS_ASH_INTERNAL package and package body
Rem NOTE: prvtawr uses functions in prvtash, so include prvtash first.
@@prvtash.plb

Rem Create DBMS_WORKLOAD_REPOSITORY package body,
Rem Create DBMS_SWRF_INTERNAL package and package body,
Rem Create DBMS_SWRF_REPORT_INTERNAL package and package body
Rem NOTE: prvtawr uses functions in prvtash, so include prvtash first.
@@prvtawr.plb

REM hdm pkg
@@prvthdm.plb    

Rem package body for the manageability undo advisor
@@prvtuadv.plb

Rem Create the private portion of the SQL Tuning package
@@prvtsqlt.plb

Rem Create the DB Feature Usage Packages
Rem NOTE: This must be created after prvtawr.plb since the DB Feature
Rem       report uses the AWR reporting infrastructure
@@dbmsfus
@@prvtfus.plb

Rem Register the Features and High Water Marks located in  
Rem the CATFUSRG.SQL file
Rem 
Rem Note: Additional Features and High Water Marks not placed
Rem       in the CATFUSRG.SQL file must be registered after the
Rem       DBMSFUS package has been loaded.
@@catfusrg.sql
