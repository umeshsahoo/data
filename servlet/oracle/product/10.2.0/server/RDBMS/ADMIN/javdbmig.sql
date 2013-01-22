Rem
Rem $Header: javdbmig.sql 17-may-2004.13:03:38 rburns Exp $
Rem
Rem javdbmig.sql
Rem
Rem Copyright (c) 2001, 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      javdbmig.sql - CATalog DataBase MIGration script
Rem
Rem    DESCRIPTION
Rem      This script upgrades the RDBMS java classes
Rem
Rem    NOTES
Rem      It is invoked by the cmpdbmig.sql script after JAVAVM 
Rem      has been upgraded.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rburns      05/17/04 - rburns_single_updown_scripts
Rem    rburns      11/12/02 - use dbms_registry.check_server_instance
Rem    rburns      03/30/02 - restructure queries
Rem    rburns      01/12/02 - Merged rburns_catjava
Rem    rburns      12/18/01 - Created
Rem

Rem *************************************************************************
Rem Check instance version and status; set session attributes
Rem *************************************************************************

WHENEVER SQLERROR EXIT;
EXECUTE dbms_registry.check_server_instance;
WHENEVER SQLERROR CONTINUE;

Rem *************************************************************************
Rem Upgrade Java classes based on old release version
Rem *************************************************************************
 
DECLARE
  vers VARCHAR2(30);
BEGIN
  vers := substr(dbms_registry.version('CATJAVA'),1,5);  /* use first 3 */
  IF vers = '8.1.7' or vers = '9.0.1' THEN
     /* DROP 8.1.7 classes  */
     FOR class_cursor IN (SELECT  nvl(longdbcs, object_name) cname,
                          object_type otype
                          FROM sys.all_objects,sys.javasnm$
                          WHERE short(+) = object_name AND
                                object_type in ('JAVA CLASS','SYNONYM') AND
                             (  nvl(longdbcs, object_name)
                                LIKE 'oracle/repapi/%'
                             OR nvl(longdbcs, object_name)
                                = 'oracle/plsql/web/PLSQLGatewayServlet'
                             OR nvl(longdbcs, object_name)
                                LIKE 'oracle/AQ/xml/AQxml%'
                             OR nvl(longdbcs, object_name)
                                LIKE 'oracle/xml/dburi/OraDbUri%') )
     LOOP
        IF class_cursor.otype = 'JAVA CLASS' THEN
           EXECUTE IMMEDIATE 'DROP JAVA CLASS ' || 
                            '"' || class_cursor.cname || '"';  
        ELSIF class_cursor.otype = 'SYNONYM' THEN
           EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM ' || 
                            '"' || class_cursor.cname || '"';  
        END IF;
     END LOOP;

     IF vers = '9.0.1' THEN
        initjvmaux.drop_sys_class
               ('oracle/aurora/sqljtype/AutonomousTransaction');
        initjvmaux.drop_sys_class
               ('oracle/aurora/sqljtype/AutonomousTransaction$Action');
     END IF;
     COMMIT;
  END IF;
END;
/

Rem *************************************************************************
Rem Reload current version of Java Classes
Rem *************************************************************************

@@catjava
