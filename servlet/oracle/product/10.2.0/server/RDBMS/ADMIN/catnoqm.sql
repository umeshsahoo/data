Rem
Rem $Header: catnoqm.sql 03-dec-2004.13:02:46 pnath Exp $
Rem
Rem catnoqm.sql
Rem
Rem Copyright (c) 2001, 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catnoqm.sql - CATalog script for removing (NO) XDB
Rem
Rem    DESCRIPTION
Rem      this script drops the metadata created for SQL XML management
Rem      This scirpt must be invoked as sys. It is to be invoked as
Rem
Rem          @@catnoqm
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pnath       11/10/04 - drop all objects created in installation 
Rem    spannala    01/03/02 - tables are not handled by xdb
Rem    spannala    01/02/02 - registry
Rem    spannala    12/20/01 - passing in the resource tablespace name
Rem    tsingh      11/17/01 - remove connection string
Rem    tsingh      06/30/01 - XDB: XML Database merge
Rem    amanikut    02/13/01 - Creation
Rem
Rem  
 
execute dbms_registry.removing('XDB');
drop user xdb cascade;

Rem During the un-installation of XDB, drop every object existing in 
Rem table xdb_installation_tab (explanation of objects inserted into 
Rem xdb_installation_tab is given in catqm.sql). Only certain object 
Rem types are handled. Objects of object type not handled below will 
Rem result in need to modify this block of code. 
DECLARE
   CURSOR c1 IS SELECT unique owner, object_name, object_type FROM xdb_installation_tab;
BEGIN
   FOR item IN c1 LOOP
     IF (item.object_type = 'FUNCTION' or
            item.object_type = 'INDEX' or
            item.object_type = 'PACKAGE' or
            item.object_type = 'PACKAGE BODY' or
            item.object_type = 'PROCEDURE' or
            item.object_type = 'SYNONYM' or
            item.object_type = 'TABLE' or
            item.object_type = 'TABLESPACE' or
            item.object_type = 'TYPE' or
            item.object_type = 'VIEW' or
            item.object_type = 'USER')
     THEN
       BEGIN
         IF item.owner = 'PUBLIC' and item.object_type = 'SYNONYM' THEN
            execute immediate 'DROP PUBLIC SYNONYM "'||item.object_name||'"';
         ELSE    
            execute immediate 'DROP '||item.object_type||' "'||item.owner||'"."'||item.object_name||'"';
         END IF;
       EXCEPTION
           when others then 
              null;
       END;
     ELSE
       raise_application_error(-20000, 'Drop of object in xdb_installation_tab of object type '||item.object_type||' is not handled.');
     END IF;  
   END LOOP;
END;
/

Rem Drop accessory objects 
drop table xdb_installation_tab;
