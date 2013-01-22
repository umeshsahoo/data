Rem
Rem $Header: utlusts.sql 26-jul-2004.09:57:38 rburns Exp $
Rem
Rem utlusts.sql
Rem
Rem Copyright (c) 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      utlusts.sql - UTiLity Upgrade STatuS
Rem
Rem    DESCRIPTION
Rem      Presents Post-upgrade Status in either TEXT or XML
Rem
Rem    NOTES
Rem      Invoked by utlu102s.sql with TEXT parameter
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rburns      07/21/04 - add elapsed time 
Rem    rburns      06/22/04 - rburns_pre_upgrade_util
Rem    rburns      06/16/04 - Created
Rem

SET SERVEROUTPUT ON
SET VERIFY OFF

DECLARE

   display_mode VARCHAR2(4) := '&1';
   display_xml  BOOLEAN := FALSE;
   component    registry$.cname%type;
   prv_time TIMESTAMP; 
   start_time TIMESTAMP; 
   end_time TIMESTAMP; 
   elapsed_time INTERVAL DAY TO SECOND(9) := 
           INTERVAL '0 00:00:00.00' DAY TO SECOND; 
   time_result VARCHAR2(30); 

BEGIN
   IF display_mode = 'XML' THEN
      display_xml := TRUE;
      DBMS_OUTPUT.PUT_LINE('<RDBMSUP version="10.2">');
      DBMS_OUTPUT.PUT_LINE('<Components>');
   ELSE
      DBMS_OUTPUT.PUT_LINE('.');
      DBMS_OUTPUT.PUT_LINE(
             'Oracle Database 10.2 Upgrade Status Utility    ' ||
             LPAD(TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS'),26));
      DBMS_OUTPUT.PUT_LINE('.');
      DBMS_OUTPUT.PUT_LINE(RPAD('Component', 35) || LPAD('Status',12) ||
              LPAD('Version', 16) || LPAD('HH:MM:SS', 10));
   END IF;
   FOR log IN (SELECT comp_id, operation, optime, message
               FROM dba_registry_log WHERE namespace = 'SERVER'
               ORDER BY optime) LOOP
     IF log.comp_id = 'UPGRD_BGN' THEN
        start_time := log.optime;
        prv_time := log.optime;
     ELSIF log.comp_id = 'UPGRD_END' THEN
        end_time := log.optime;
     END IF;
  
     IF log.comp_id LIKE '%_BGN' OR log.comp_id LIKE '%_END' OR
        log.comp_id = 'CATPROC' THEN
        NULL;
     ELSE
        IF log.comp_id = 'RDBMS' THEN
           component := 'Oracle Database Server';
        ELSE
           component :=  dbms_registry.comp_name(log.comp_id);
        END IF;
        elapsed_time := log.optime - prv_time;
        time_result := to_char(elapsed_time);
        IF display_xml THEN
           DBMS_OUTPUT.PUT_LINE ('<Component id="' || component ||
                        '" cid="' || log.comp_id ||
                        '" status="' || LOWER(log.operation) ||
                        '" upgradeTime="' || substr(time_result,5,8) ||
                        '">');
        ELSE
           DBMS_OUTPUT.PUT_LINE(rpad(component,35) ||
                             LPAD(log.operation,12) || ' ' ||
                             LPAD(substr(log.message,1,15),15) ||
                             LPAD(substr(time_result,5,8),10));
        END IF;
        prv_time := log.optime;
     END IF;
   END LOOP;

   IF end_time IS NOT NULL THEN
      elapsed_time := end_time - start_time; 
      time_result := to_char(elapsed_time); 
      IF display_xml THEN
         DBMS_OUTPUT.PUT_LINE('<totalUpgrade time="' || 
                  substr(time_result, 5,8) || '">');
      ELSE
         DBMS_OUTPUT.PUT_LINE('.');
         DBMS_OUTPUT.PUT_LINE('Total Upgrade Time: ' || 
                  substr(time_result, 5,8));
      END IF;
   ELSE
      IF display_xml THEN
            DBMS_OUTPUT.PUT_LINE('<Upgrade incomplete/>');
      ELSE
         DBMS_OUTPUT.PUT_LINE('Upgrade Incomplete');
      END IF;
   END IF;
      IF display_xml THEN
       DBMS_OUTPUT.PUT_LINE('</Components>');
         DBMS_OUTPUT.PUT_LINE('</RDBMSUP>');
      END IF;
END;
/

SET SERVEROUTPUT OFF
SET VERIFY ON
