Rem
Rem $Header: catnojav.sql 18-mar-2005.11:00:36 kmuthiah Exp $
Rem
Rem catnojav.sql
Rem
Rem Copyright (c) 2002, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catnojav.sql - CATalog NO JAVa classes for RDBMS
Rem
Rem    DESCRIPTION
Rem      This script removes the RDBMS Java classes and system 
Rem      triggers created by the CATJAVA.SQL script.
Rem
Rem    NOTES
Rem      Must be run AS SYSDBA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    kmuthiah    02/23/05 - rm 'dropjava xquery.jar' 
Rem    mkrishna    11/16/04 - remove XQuery jar files 
Rem    rburns      07/16/02 - rburns_bug-2415848_main
Rem    rburns      06/13/02 - Created
Rem

Rem =====================================================================
Rem Check CATJAVA and JAVAVM status; conditionally abort the script
Rem =====================================================================

WHENEVER SQLERROR EXIT;

BEGIN
   IF dbms_registry.status('CATJAVA') IS NULL THEN
      RAISE_APPLICATION_ERROR(-20000,
           'CATJAVA has not been loaded into the database.');   
   END IF;
   IF dbms_registry.is_loaded('JAVAVM') != 1 THEN
      RAISE_APPLICATION_ERROR(-20000,
           'JServer is not operational in the database; ' ||
           'JServer is required to remove CATJAVA from the database.');   
   END IF;
END;
/

WHENEVER SQLERROR CONTINUE;

EXECUTE dbms_registry.removing('CATJAVA');

Rem =====================================================================
Rem Change Data Capture (initcdc.sql)
Rem =====================================================================

@@rmcdc.sql

Rem =====================================================================
Rem Summary Advisor (initqsma.sql)
Rem =====================================================================

EXECUTE sys.dbms_java.dropjava('-s rdbms/jlib/qsma.jar');

Rem =====================================================================
Rem SQLJTYPE (initsjty.sql)
Rem =====================================================================

EXECUTE sys.dbms_java.dropjava('-s rdbms/jlib/sqljtype.jar');

Rem =====================================================================
Rem AQ JMS (initjms.sql)
Rem =====================================================================

EXECUTE sys.dbms_java.dropjava('-s rdbms/jlib/aqapi.jar');
EXECUTE sys.dbms_java.dropjava('-s rdbms/jlib/jmscommon.jar');

Rem =====================================================================
Rem Application Context (initapcx.sql)
Rem =====================================================================

EXECUTE sys.dbms_java.dropjava('-s rdbms/jlib/appctxapi.jar');

Rem =====================================================================
Rem ODCI and Cartridge Services (initsoxx.sql)
Rem =====================================================================

EXECUTE sys.dbms_java.dropjava('-s rdbms/jlib/CartridgeServices.jar');
EXECUTE sys.dbms_java.dropjava('-s rdbms/jlib/ODCI.jar');

Rem =====================================================================
Rem Set CATJAVA status
Rem =====================================================================

EXECUTE dbms_registry.removed('CATJAVA');

Rem *********************************************************************
/*
 END CATNOJAV.SQL */
Rem *********************************************************************



