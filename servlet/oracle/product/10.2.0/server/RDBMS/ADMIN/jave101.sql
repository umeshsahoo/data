Rem
Rem $Header: jave101.sql 18-mar-2005.11:01:56 kmuthiah Exp $
Rem
Rem jave101.sql
Rem
Rem Copyright (c) 2004, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      jave101.sql - downgrade catJAVa to 10.1
Rem
Rem    DESCRIPTION
Rem      Downgrade CATJAVA from current release to 10.1
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    kmuthiah    02/23/05 - rm 'dropjava xquery.jar'
Rem    mkrishna    11/15/04 - remove java classes 
Rem    rburns      05/17/04 - rburns_single_updown_scripts
Rem    rburns      02/09/04 - Created
Rem

Rem Downgrade from current release to 10.2
Rem @@jave102

execute dbms_registry.downgrading('CATJAVA');

Rem Add CATJAVA downgrade actions here

Rem downgrade and remove XQuery jar files/packages.
drop package sys.dbms_xqueryint;

execute dbms_registry.downgraded('CATJAVA','10.1.0');


