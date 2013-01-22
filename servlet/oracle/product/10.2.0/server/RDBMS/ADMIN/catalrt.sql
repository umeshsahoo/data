Rem
Rem $Header: catalrt.sql 09-dec-2004.14:43:16 ysarig Exp $
Rem
Rem catalrt.sql
Rem
Rem Copyright (c) 2002, 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catalrt.sql - Catalog script for server ALeRT 
Rem
Rem    DESCRIPTION
Rem      Creates tables, sequence, type and queue for server alert 
Rem
Rem    NOTES
Rem      Must be run when connected as SYSDBA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ysarig      12/02/04 - bug 3930796 - comment for ALERT_QUE 
Rem    ilistvin    08/13/04 - add METRIC_VALUE_TYPE column to 
Rem                           V$THRESHOLD_TYPES 
Rem    ilistvin    07/19/04 - move start_queue outide of exception block 
Rem    aahluwal    05/25/04 - [OCI Events]: load prvtbdbu/prvthdbu before 
Rem                           prvtslrt 
Rem    jxchen      12/04/03 - Increase size of instance name 
Rem    jxchen      11/17/03 - Bug 3262541 - Increase length of hosting client 
Rem    jxchen      11/05/03 - Add view to expose message arguments for 
Rem                           outstanding alerts 
Rem    jxchen      10/29/03 - Use x$keltosd for dba_thresholds view 
Rem    jxchen      09/22/03 - Add exception handler for set_threshold call 
Rem    jxchen      10/02/03 - Add serial# in alert tables 
Rem    jxchen      09/03/03 - Increase column width for some metadata columns 
Rem    jxchen      07/21/03 - Bug 3050295 - add initial time in alert history
Rem    jxchen      06/10/03 - More verbose comments for views/columns
Rem    jxchen      06/20/03 - Catch object exist error
Rem    jxchen      05/14/03 - Execute dbmsslxp threshold export package
Rem    aime        04/25/03 - aime_going_to_main
Rem    jxchen      04/30/03 - Add alert scope to alert payload
Rem    jxchen      04/02/03 - Move threshold table to SYSAUX
Rem    jxchen      03/14/03 - Use X$KEWMDSM for tablespace metric name
Rem    jxchen      03/05/03 - Add metric value in alert payload
Rem    jxchen      02/20/03 - Add comment for DBA_THRESHOLDS.STATUS
Rem    jxchen      02/17/03 - Expose flags in dba_thresholds.
Rem    jxchen      01/21/03 - Add synonym for V$ALERT_TYPES, V$THRESHOLD_TYPES
Rem    jxchen      01/14/03 - Add comments for views
Rem    jxchen      01/11/03 - Use union for dba_thresholds.
Rem    jxchen      01/09/03 - Add operators
Rem    jxchen      01/07/03 - Change column names of threshold alert table
Rem    smuthuli    01/07/03 - insert db default for tablespace alerts
Rem    jxchen      12/11/02 - Add dba_thresholds view
Rem    jxchen      11/14/02 - jxchen_alrt1
Rem    jxchen      11/13/02 - Add dbms_server_alert package
Rem    jxchen      11/11/02 - Add alert views
Rem    jxchen      10/24/02 - Add alert threshold table
Rem    jxchen      09/01/02 - Created
Rem

-- Create table of outstanding alerts
CREATE TABLE wri$_alert_outstanding(
      reason_id                NUMBER,                    
      object_id                NUMBER,                   
      subobject_id             NUMBER,
      internal_instance_number NUMBER,                  
      owner                    VARCHAR2(30),           
      object_name              VARCHAR2(513),         
      subobject_name           VARCHAR2(30),         
      sequence_id              NUMBER,              
      reason_argument_1        VARCHAR2(581),     
      reason_argument_2        VARCHAR2(581),    
      reason_argument_3        VARCHAR2(581),   
      reason_argument_4        VARCHAR2(581),            
      reason_argument_5        VARCHAR2(581),           
      time_suggested           TIMESTAMP WITH TIME ZONE,
      creation_time            TIMESTAMP WITH TIME ZONE,
      action_argument_1        VARCHAR2(30),           
      action_argument_2        VARCHAR2(30),          
      action_argument_3        VARCHAR2(30),         
      action_argument_4        VARCHAR2(30),        
      action_argument_5        VARCHAR2(30),       
      message_level            NUMBER,            
      hosting_client_id        VARCHAR2(64),     
      process_id               VARCHAR2(128),   
      host_id                  VARCHAR2(256),  
      host_nw_addr             VARCHAR2(256),  
      instance_name            VARCHAR2(16), 
      instance_number          NUMBER,      
      user_id                  VARCHAR2(30),
      execution_context_id     VARCHAR2(60),
      error_instance_id        VARCHAR2(142), 
      context                  RAW(128),    
      metric_value             NUMBER,
      CONSTRAINT wri$_alerts_outstanding_pk PRIMARY KEY (
           reason_id, 
           object_id,
           subobject_id,
           internal_instance_NUMBER)
        USING INDEX TABLESPACE sysaux)
      TABLESPACE sysaux;

-- Create table of alert history 
CREATE TABLE wri$_alert_history(
      sequence_id              NUMBER,       
      reason_id                NUMBER,       
      owner                    VARCHAR2(30),
      object_name              VARCHAR2(513), 
      subobject_name           VARCHAR2(30), 
      reason_argument_1        VARCHAR2(581), 
      reason_argument_2        VARCHAR2(581),
      reason_argument_3        VARCHAR2(581), 
      reason_argument_4        VARCHAR2(581),
      reason_argument_5        VARCHAR2(581),  
      time_suggested           TIMESTAMP WITH TIME ZONE,  
      creation_time            TIMESTAMP WITH TIME ZONE,
      action_argument_1        VARCHAR2(30),             
      action_argument_2        VARCHAR2(30),            
      action_argument_3        VARCHAR2(30),           
      action_argument_4        VARCHAR2(30),          
      action_argument_5        VARCHAR2(30),         
      message_level            NUMBER,              
      hosting_client_id        VARCHAR2(64),       
      process_id               VARCHAR2(128),     
      host_id                  VARCHAR2(256),    
      host_nw_addr             VARCHAR2(256),    
      instance_name            VARCHAR2(16),   
      instance_number          NUMBER,        
      user_id                  VARCHAR2(30), 
      execution_context_id     VARCHAR2(60),
      error_instance_id        VARCHAR2(142),
      resolution               NUMBER,     
      metric_value             NUMBER,
      CONSTRAINT wri$_alert_history_pk PRIMARY KEY (sequence_id)
        USING INDEX TABLESPACE sysaux)
      TABLESPACE sysaux;

-- Create sequence of alerts
CREATE SEQUENCE sys.wri$_alert_sequence;

-- Create alert type used for in AQ messages 
CREATE TYPE sys.alert_type AS OBJECT (
        timestamp_originating    timestamp with time zone,
        organization_id          varchar2(10),           
        component_id             varchar2(3),           
        message_id               number,               
        hosting_client_id        varchar2(64),        
        message_type             varchar2(12),       
        message_group            varchar2(30),      
        message_level            number,           
        host_id                  varchar2(256),   
        host_nw_addr             varchar2(256),   
        module_id                varchar2(50),  
        process_id               varchar2(128),
        user_id                  varchar2(30),
        upstream_component_id    varchar2(30),            
        downstream_component_id  varchar2(4),            
        execution_context_id     varchar2(21),          
        error_instance_id        varchar2(142),         
        reason_argument_count    number,              
        reason_argument_1        varchar2(513),      
        reason_argument_2        varchar2(513),     
        reason_argument_3        varchar2(513),    
        reason_argument_4        varchar2(513),   
        reason_argument_5        varchar2(513),  
        sequence_id              number,        
        reason_id                number,
        object_owner             varchar2(30), 
        object_name              varchar2(513),           
        subobject_name           varchar2(30),           
        object_type              varchar2(30),          
        instance_name            varchar2(16),         
        instance_number          number,              
        scope                    varchar2(10),
        advisor_name             varchar2(30),
        metric_value             number,         
        suggested_action_msg_id  number,             
        action_argument_count    number,            
        action_argument_1        varchar2(30),     
        action_argument_2        varchar2(30),    
        action_argument_3        varchar2(30),   
        action_argument_4        varchar2(30),  
        action_argument_5        varchar2(30)); 
/

CREATE OR REPLACE PUBLIC SYNONYM alert_type FOR sys.alert_type;
GRANT execute on alert_type TO public;

-- Create alert queue table and alert queue
BEGIN
   BEGIN
   dbms_aqadm.create_queue_table(
            queue_table => 'SYS.ALERT_QT',
            queue_payload_type => 'SYS.ALERT_TYPE',
            storage_clause => 'TABLESPACE "SYSAUX"', 
            multiple_consumers => TRUE,
            comment => 'Server Generated Alert Queue Table',
            secure => TRUE);
   dbms_aqadm.create_queue(
            queue_name => 'SYS.ALERT_QUE',
            queue_table => 'SYS.ALERT_QT',
            comment => 'Server Generated Alert Queue');
   EXCEPTION
     when others then
       if sqlcode = -24001 then NULL;
       else raise;
       end if;
   END;
   dbms_aqadm.start_queue('SYS.ALERT_QUE', TRUE, TRUE);
   dbms_aqadm.start_queue('SYS.AQ$_ALERT_QT_E', FALSE, TRUE);
   commit;
EXCEPTION
  when others then
     raise;
END;
/

-- Create an AQ agent to be used to enqueue alert messages
BEGIN
    DECLARE 
      agent SYS.AQ$_AGENT;
    BEGIN
      agent := SYS.AQ$_AGENT('server_alert', NULL, NULL);
      dbms_aqadm.create_aq_agent('server_alert');
    EXCEPTION
      when others then
        if sqlcode = -24089 then NULL;
        else raise;
        end if;
    END;
    dbms_aqadm.enable_db_access('server_alert', 'SYS');
EXCEPTION
  when others then raise;
END;
/

-- Create table storing threshold settings
CREATE TABLE wri$_alert_threshold(
      t_object_type             NUMBER,        
      t_object_name             VARCHAR2(513), 
      t_metrics_id              NUMBER,       
      t_instance_name           VARCHAR2(16),
      t_flags                   NUMBER,     
      t_warning_operator        NUMBER,    
      t_warning_value           VARCHAR2(256), 
      t_critical_operator       NUMBER,       
      t_critical_value          VARCHAR2(256), 
      t_observation_period      NUMBER,       
      t_consecutive_occurrences NUMBER,      
      t_object_id               NUMBER,     
      CONSTRAINT wri$_alert_threshold_pk UNIQUE (
             t_object_type,
             t_object_name,
             t_metrics_id,
             t_instance_name)
      USING INDEX TABLESPACE sysaux)
      TABLESPACE sysaux;

-- Create threshold type for threshold table function
CREATE TYPE threshold_type AS OBJECT(
      object_type               NUMBER,
      object_name               VARCHAR2(513),
      metrics_id                NUMBER,
      instance_name             VARCHAR2(16),
      flags                     NUMBER,
      warning_operator          NUMBER,
      warning_value             VARCHAR2(256),
      critical_operator         NUMBER,
      critical_value            VARCHAR2(256),
      observation_period        NUMBER,
      consecutive_occurrences   NUMBER,
      object_id                 NUMBER);
/

-- Create threshold set type for threshold table function 
CREATE TYPE threshold_type_set AS TABLE OF threshold_type;
/

-- Create the threshold log table
CREATE TABLE wri$_alert_threshold_log(
      sequence_id               NUMBER,
      object_type               NUMBER,
      object_name               VARCHAR2(513),
      object_id                 NUMBER,
      opcode                    NUMBER,
      CONSTRAINT wri$_alert_threshold_log_pk PRIMARY KEY (sequence_id)
        USING INDEX TABLESPACE system)
      TABLESPACE system;

-- Create sequence of threshold log
CREATE SEQUENCE sys.wri$_alert_thrslog_sequence;

-- Create the DBMS_PRVT_TRACE package
@@prvthdbu.plb
@@prvtbdbu.plb

-- Create the DBMS_SERVER_ALERT package
@@dbmsslrt
@@prvtslrt.plb

-- Create dba_outstanding_alerts view
CREATE OR REPLACE VIEW dba_outstanding_alerts
  AS SELECT sequence_id, 
            reason_id,
            owner, 
            object_name, 
            subobject_name, 
            typnam_keltosd AS object_type, 
            dbms_server_alert.expand_message(userenv('LANGUAGE'), 
                                             mid_keltsd, 
                                             reason_argument_1, 
                                             reason_argument_2, 
                                             reason_argument_3, 
                                             reason_argument_4,
                                             reason_argument_5) AS reason, 
            time_suggested, 
            creation_time,
            dbms_server_alert.expand_message(userenv('LANGUAGE'), 
                                             amid_keltsd,
                                             action_argument_1, 
                                             action_argument_2, 
                                             action_argument_3, 
                                             action_argument_4,
                                             action_argument_5) 
              AS suggested_action, 
            advisor_name, 
            metric_value,
            decode(message_level, 32, 'Notification', 'Warning') 
              AS message_type, 
            nam_keltgsd AS message_group, 
            message_level, 
            hosting_client_id, 
            mdid_keltsd AS module_id, 
            process_id, 
            host_id, 
            host_nw_addr, 
            instance_name, 
            instance_number, 
            user_id,  
            execution_context_id, 
            error_instance_id 
  FROM wri$_alert_outstanding, X$KELTSD, X$KELTOSD, X$KELTGSD, 
       dba_advisor_definitions
  WHERE reason_id = rid_keltsd 
    AND otyp_keltsd = typid_keltosd 
    AND grp_keltsd = id_keltgsd 
    AND aid_keltsd = advisor_id(+); 

CREATE OR REPLACE PUBLIC SYNONYM dba_outstanding_alerts
   FOR sys.dba_outstanding_alerts;
GRANT select on dba_outstanding_alerts TO select_catalog_role;

comment on table DBA_OUTSTANDING_ALERTS is
'Description of all outstanding alerts';

comment on column DBA_OUTSTANDING_ALERTS.SEQUENCE_ID is
'Alert sequence number';

comment on column DBA_OUTSTANDING_ALERTS.REASON_ID is
'Alert reason id';

comment on column DBA_OUTSTANDING_ALERTS.OWNER is
'Owner of object on which alert is issued';

comment on column DBA_OUTSTANDING_ALERTS.OBJECT_NAME is
'Name of the object';

comment on column DBA_OUTSTANDING_ALERTS.SUBOBJECT_NAME is
'Name of the subobject (partition)';

comment on column DBA_OUTSTANDING_ALERTS.OBJECT_TYPE is
'Type of the object (table, tablespace, etc)';

comment on column DBA_OUTSTANDING_ALERTS.REASON is
'Reason for the alert';

comment on column DBA_OUTSTANDING_ALERTS.TIME_SUGGESTED is
'Time when the alert was last updated';

comment on column DBA_OUTSTANDING_ALERTS.CREATION_TIME is
'Time when the alert was first created';

comment on column DBA_OUTSTANDING_ALERTS.SUGGESTED_ACTION is 
'Advice of recommended action';

comment on column DBA_OUTSTANDING_ALERTS.ADVISOR_NAME is
'Name of advisor to be invoked for more information';

comment on column DBA_OUTSTANDING_ALERTS.METRIC_VALUE is
'Value of the related metrics';

comment on column DBA_OUTSTANDING_ALERTS.MESSAGE_TYPE is
'Message type - warning or notification';

comment on column DBA_OUTSTANDING_ALERTS.MESSAGE_GROUP is
'Name of the group that the alert belongs to';

comment on column DBA_OUTSTANDING_ALERTS.MESSAGE_LEVEL is
'Severity level (1-32)';

comment on column DBA_OUTSTANDING_ALERTS.HOSTING_CLIENT_ID is
'ID of the client or security group etc. that the alert relates to';

comment on column DBA_OUTSTANDING_ALERTS.MODULE_ID is
'ID of the module that originated the alert';

comment on column DBA_OUTSTANDING_ALERTS.PROCESS_ID is
'Process id';

comment on column DBA_OUTSTANDING_ALERTS.HOST_ID is
'DNS hostname of originating host';

comment on column DBA_OUTSTANDING_ALERTS.HOST_NW_ADDR is
'IP or other network address of originating host';

comment on column DBA_OUTSTANDING_ALERTS.INSTANCE_NAME is
'Originating instance name';

comment on column DBA_OUTSTANDING_ALERTS.INSTANCE_NUMBER is
'Originating instance number';

comment on column DBA_OUTSTANDING_ALERTS.USER_ID is
'User id';

comment on column DBA_OUTSTANDING_ALERTS.EXECUTION_CONTEXT_ID is
'ID of the threshold of execution';

comment on column DBA_OUTSTANDING_ALERTS.ERROR_INSTANCE_ID is
'ID of an error instance plus a sequence number';

CREATE OR REPLACE VIEW dba_alert_history
  AS select sequence_id, 
            reason_id, 
            owner, 
            object_name, 
            subobject_name, 
            typnam_keltosd AS object_type, 
            dbms_server_alert.expand_message(userenv('LANGUAGE'), 
                                             mid_keltsd, 
                                             reason_argument_1, 
                                             reason_argument_2, 
                                             reason_argument_3, 
                                             reason_argument_4,
                                             reason_argument_5) AS reason, 
            time_suggested, 
            creation_time,
            dbms_server_alert.expand_message(userenv('LANGUAGE'), 
                                             amid_keltsd,
                                             action_argument_1, 
                                             action_argument_2, 
                                             action_argument_3, 
                                             action_argument_4,
                                             action_argument_5) 
              AS suggested_action, 
            advisor_name, 
            metric_value,
            decode(message_level, 32, 'Notification', 'Warning') 
              AS message_type, 
            nam_keltgsd AS message_group, 
            message_level, 
            hosting_client_id, 
            mdid_keltsd AS module_id, 
            process_id, 
            host_id, 
            host_nw_addr, 
            instance_name, 
            instance_number, 
            user_id,  
            execution_context_id, 
            error_instance_id, 
            decode(resolution, 1, 'cleared', 'N/A') AS resolution
  FROM wri$_alert_history, X$KELTSD, X$KELTOSD, X$KELTGSD, 
       dba_advisor_definitions
  WHERE reason_id = rid_keltsd 
    AND otyp_keltsd = typid_keltosd 
    AND grp_keltsd = id_keltgsd 
    AND aid_keltsd = advisor_id(+); 

CREATE OR REPLACE PUBLIC SYNONYM dba_alert_history
   FOR sys.dba_alert_history;
GRANT select on dba_alert_history TO select_catalog_role;

comment on table DBA_ALERT_HISTORY is
'Description on alert history';

comment on column DBA_ALERT_HISTORY.SEQUENCE_ID is
'Alert sequence number';

comment on column DBA_ALERT_HISTORY.REASON_ID is
'Alert reason id';

comment on column DBA_ALERT_HISTORY.OWNER is
'Owner of the object on which alert is issued';

comment on column DBA_ALERT_HISTORY.OBJECT_NAME is
'Name of the object';

comment on column DBA_ALERT_HISTORY.SUBOBJECT_NAME is
'Name of the subobject (partition)';

comment on column DBA_ALERT_HISTORY.OBJECT_TYPE is
'Type of the object (table, tablespace, etc)';

comment on column DBA_ALERT_HISTORY.REASON is
'Reason for the alert';

comment on column DBA_ALERT_HISTORY.TIME_SUGGESTED is
'Time when the alert was last updated';

comment on column DBA_ALERT_HISTORY.CREATION_TIME is
'Time when the alert was first produced';

comment on column DBA_ALERT_HISTORY.SUGGESTED_ACTION is
'Advice of recommended action';

comment on column DBA_ALERT_HISTORY.ADVISOR_NAME is
'Name of advisor to be invoked for more information';

comment on column DBA_ALERT_HISTORY.METRIC_VALUE is
'Value of the related metrics';

comment on column DBA_ALERT_HISTORY.MESSAGE_TYPE is
'Message type - warning or notification';

comment on column DBA_ALERT_HISTORY.MESSAGE_GROUP is
'Name of the group that the alert belongs to';

comment on column DBA_ALERT_HISTORY.MESSAGE_LEVEL is
'Severity level (1-32)';

comment on column DBA_ALERT_HISTORY.HOSTING_CLIENT_ID is
'ID of the client or security group etc. that the alert relates to';

comment on column DBA_ALERT_HISTORY.MODULE_ID is
'ID of the module that originated the alert';

comment on column DBA_ALERT_HISTORY.PROCESS_ID is
'Process id';

comment on column DBA_ALERT_HISTORY.HOST_ID is
'DNS hostname of originating host';

comment on column DBA_ALERT_HISTORY.HOST_NW_ADDR is
'IP or other network address of originating host';

comment on column DBA_ALERT_HISTORY.INSTANCE_NAME is
'Originating instance name';

comment on column DBA_ALERT_HISTORY.INSTANCE_NUMBER is
'Originating instance number';

comment on column DBA_ALERT_HISTORY.USER_ID is
'User id';

comment on column DBA_ALERT_HISTORY.EXECUTION_CONTEXT_ID is
'ID of the thread of execution';

comment on column DBA_ALERT_HISTORY.ERROR_INSTANCE_ID is
'ID of an error instance plus a sequence number';

comment on column DBA_ALERT_HISTORY.RESOLUTION is
'Cleared or not';


-- Create dba_thresholds view
CREATE OR REPLACE VIEW dba_thresholds 
  AS select m.name AS metrics_name,
            decode(a.warning_operator, 0, 'GT',
                                       1, 'EQ',
                                       2, 'LT',
                                       3, 'LE',
                                       4, 'GE',
                                       5, 'CONTAINS',
                                       6, 'NE',
                                       7, 'DO NOT CHECK',
                                          'NONE') AS warning_operator,
            a.warning_value AS warning_value,
            decode(a.critical_operator, 0, 'GT',
                                        1, 'EQ',
                                        2, 'LT',
                                        3, 'LE',
                                        4, 'GE',
                                        5, 'CONTAINS',
                                        6, 'NE',
                                        7, 'DO_NOT_CHECK',
                                           'NONE') AS critical_operator,
            a.critical_value AS critical_value,
            a.observation_period AS observation_period,
            a.consecutive_occurrences AS consecutive_occurrences,
            decode(a.instance_name, ' ', null, 
                                       instance_name) AS instance_name,
            o.typnam_keltosd AS object_type,
            a.object_name AS object_name,
            decode(a.flags, 1, 'VALID',
                            0, 'INVALID') AS status
  FROM table(dbms_server_alert.view_thresholds) a,
       X$KEWMDSM m, 
       X$KELTOSD o 
  WHERE a.object_type != 2 
    AND m.metricid(+) = a.metrics_id
    AND a.object_type = o.typid_keltosd
  UNION
     select m.name AS metrics_name,
            decode(a.warning_operator, 0, 'GT',
                                       1, 'EQ',
                                       2, 'LT',
                                       3, 'LE',
                                       4, 'GE',
                                       5, 'CONTAINS',
                                       6, 'NE',
                                       7, 'DO_NOT_CHECK',
                                          'NONE') AS warning_operator,
            a.warning_value AS warning_value,
            decode(a.critical_operator, 0, 'GT',
                                        1, 'EQ',
                                        2, 'LT',
                                        3, 'LE',
                                        4, 'GE',
                                        5, 'CONTAINS',
                                        6, 'NE',
                                        7, 'DO NOT CHECK',
                                           'NONE') AS critical_operator,
            a.critical_value AS critical_value,
            a.observation_period AS observation_period,
            a.consecutive_occurrences AS consecutive_occurrences,
            decode(a.instance_name, ' ', null,
                                       instance_name) AS instance_name,
            o.typnam_keltosd AS object_type,
            f.name AS object_name,
            decode(a.flags, 1, 'VALID',
                            0, 'INVALID') AS status
  FROM table(dbms_server_alert.view_thresholds) a,
       X$KEWMDSM m, sys.v$dbfile f, X$KELTOSD o
  WHERE a.object_type = 2
    AND m.metricid = a.metrics_id
    AND a.object_id = f.file#
    AND a.object_type = o.typid_keltosd;

CREATE OR REPLACE PUBLIC SYNONYM dba_thresholds
   FOR sys.dba_thresholds;
GRANT select on dba_thresholds TO select_catalog_role;

comment on table DBA_THRESHOLDS is
'Desription of all thresholds';

comment on column DBA_THRESHOLDS.METRICS_NAME is
'Metrics name';

comment on column DBA_THRESHOLDS.WARNING_OPERATOR is
'Relational operator for warning thresholds';

comment on column DBA_THRESHOLDS.WARNING_VALUE is
'Warning threshold value';

comment on column DBA_THRESHOLDS.CRITICAL_OPERATOR is
'Relational operator for critical thresholds';

comment on column DBA_THRESHOLDS.CRITICAL_VALUE is
'Critical threshold value';

comment on column DBA_THRESHOLDS.OBSERVATION_PERIOD is
'Observation period length (in minutes)';

comment on column DBA_THRESHOLDS.CONSECUTIVE_OCCURRENCES is
'Has to occur so many times before an alert is issued';

comment on column DBA_THRESHOLDS.INSTANCE_NAME is
'Instance name - NULL for database-wide alerts';

comment on column DBA_THRESHOLDS.OBJECT_TYPE is
'Object type: SYSTEM, TABLESPACE, SERVICE, FILE, etc';

comment on column DBA_THRESHOLDS.OBJECT_NAME is
'Name of the object for which the threshold is set';

comment on column DBA_THRESHOLDS.STATUS is
'Whether threshold is applicable on a valid object';

-- v_$alert_types
CREATE OR REPLACE VIEW v_$alert_types 
  AS SELECT * FROM v$alert_types;

comment on table V_$ALERT_TYPES is
'Description of server alert types';

comment on column V_$ALERT_TYPES.REASON_ID is
'Alert reason id';

comment on column V_$ALERT_TYPES.OBJECT_TYPE is
'Object type';

comment on column V_$ALERT_TYPES.TYPE is
'Alert type (stateful vs. stateless)';

comment on column V_$ALERT_TYPES.GROUP_NAME is
'Group name (space, performance etc.)';

comment on column V_$ALERT_TYPES.SCOPE is
'Scope (database vs. instance)';

comment on column V_$ALERT_TYPES.INTERNAL_METRIC_CATEGORY is
'Internal metric category';

comment on column V_$ALERT_TYPES.INTERNAL_METRIC_NAME is
'Internal metric name'; 

CREATE OR REPLACE PUBLIC SYNONYM v$alert_types FOR v_$alert_types;
GRANT select on v_$alert_types TO select_catalog_role;

-- gv_$alert_types
CREATE OR REPLACE VIEW gv_$alert_types
  AS SELECT * FROM gv$alert_types;

comment on table GV_$ALERT_TYPES is
'Description of server alert types';

comment on column GV_$ALERT_TYPES.REASON_ID is
'Alert reason id';

comment on column GV_$ALERT_TYPES.OBJECT_TYPE is
'Object type';

comment on column GV_$ALERT_TYPES.TYPE is
'Alert type (stateful vs. stateless)';

comment on column GV_$ALERT_TYPES.GROUP_NAME is
'Group name (space, performance etc.)';

comment on column GV_$ALERT_TYPES.SCOPE is
'Scope (database vs. instance)';

comment on column GV_$ALERT_TYPES.INTERNAL_METRIC_CATEGORY is
'Internal metric category';

comment on column GV_$ALERT_TYPES.INTERNAL_METRIC_NAME is
'Internal metric name';
 
CREATE OR REPLACE PUBLIC SYNONYM gv$alert_types FOR gv_$alert_types;
GRANT select on gv_$alert_types TO select_catalog_role;

-- v_$threshold_types
CREATE OR REPLACE VIEW v_$threshold_types
  AS SELECT * FROM v$threshold_types;

comment on table V_$THRESHOLD_TYPES is
'Description of threshold types';

comment on column V_$THRESHOLD_TYPES.METRICS_ID is
'Metrics id';

comment on column V_$THRESHOLD_TYPES.METRICS_GROUP_ID is
'Metrics group id';

comment on column V_$THRESHOLD_TYPES.OPERATOR_MASK is
'Operator mask';

comment on column V_$THRESHOLD_TYPES.OBJECT_TYPE is
'Object type';

comment on column V_$THRESHOLD_TYPES.ALERT_REASON_ID is
'Alert reason id';

comment on column V_$THRESHOLD_TYPES.METRIC_VALUE_TYPE is
'Metric value type';

CREATE OR REPLACE PUBLIC SYNONYM v$threshold_types FOR v_$threshold_types;
GRANT select on v_$threshold_types TO select_catalog_role;

-- gv_$threshold_types
CREATE OR REPLACE VIEW gv_$threshold_types
  AS SELECT * FROM gv$threshold_types;

comment on table GV_$THRESHOLD_TYPES is
'Description on threshold types';

comment on column GV_$THRESHOLD_TYPES.INST_ID is
'Instance id';

comment on column GV_$THRESHOLD_TYPES.METRICS_ID is
'Metrics id';

comment on column GV_$THRESHOLD_TYPES.METRICS_GROUP_ID is
'Metrics group id';

comment on column GV_$THRESHOLD_TYPES.OPERATOR_MASK is
'Operator mask';

comment on column GV_$THRESHOLD_TYPES.OBJECT_TYPE is
'Object type';

comment on column GV_$THRESHOLD_TYPES.ALERT_REASON_ID is
'Alert reason id';

comment on column GV_$THRESHOLD_TYPES.METRIC_VALUE_TYPE is
'Metric value type';

CREATE OR REPLACE PUBLIC SYNONYM gv$threshold_types FOR gv_$threshold_types;
GRANT select on gv_$threshold_types TO select_catalog_role;

-- Create dba_alert_arguments view
CREATE OR REPLACE VIEW dba_alert_arguments
  AS SELECT sequence_id,
            mid_keltsd AS reason_message_id,
            npm_keltsd AS reason_argument_count,
            reason_argument_1,
            reason_argument_2,
            reason_argument_3,
            reason_argument_4,
            reason_argument_5,
            amid_keltsd AS action_message_id,
            anpm_keltsd AS action_argument_count,
            action_argument_1,
            action_argument_2,
            action_argument_3,
            action_argument_4,
            action_argument_5
    FROM wri$_alert_outstanding, X$KELTSD
    WHERE reason_id = rid_keltsd; 

CREATE OR REPLACE PUBLIC SYNONYM dba_alert_arguments
  FOR sys.dba_alert_arguments;
GRANT select on dba_alert_arguments TO select_catalog_role;

comment on table DBA_ALERT_ARGUMENTS is
'Message Id and arguments of outstanding alerts';

comment on column DBA_ALERT_ARGUMENTS.SEQUENCE_ID is
'Alert sequence number';

comment on column DBA_ALERT_ARGUMENTS.REASON_MESSAGE_ID is
'Id of alert reason message';

comment on column DBA_ALERT_ARGUMENTS.REASON_ARGUMENT_COUNT is
'Number of alert reason message arguments';

comment on column DBA_ALERT_ARGUMENTS.REASON_ARGUMENT_1 is
'First argument of alert reason message';

comment on column DBA_ALERT_ARGUMENTS.REASON_ARGUMENT_2 is
'Second argument of alert reason message';

comment on column DBA_ALERT_ARGUMENTS.REASON_ARGUMENT_3 is
'Third argument of alert reason message';

comment on column DBA_ALERT_ARGUMENTS.REASON_ARGUMENT_4 is
'Fourth argument of alert reason message';

comment on column DBA_ALERT_ARGUMENTS.REASON_ARGUMENT_5 is
'Fifth argument of alert reason message';

comment on column DBA_ALERT_ARGUMENTS.ACTION_MESSAGE_ID is
'Id of alert action message';

comment on column DBA_ALERT_ARGUMENTS.ACTION_ARGUMENT_COUNT is
'Number of alert action message arguments';

comment on column DBA_ALERT_ARGUMENTS.ACTION_ARGUMENT_1 is
'First argument of alert action message';

comment on column DBA_ALERT_ARGUMENTS.ACTION_ARGUMENT_2 is
'Second argument of alert action message';

comment on column DBA_ALERT_ARGUMENTS.ACTION_ARGUMENT_3 is
'Third argument of alert action message';

comment on column DBA_ALERT_ARGUMENTS.ACTION_ARGUMENT_4 is
'Fourth argument of alert action message';

comment on column DBA_ALERT_ARGUMENTS.ACTION_ARGUMENT_5 is
'Fifth argument of alert action message';

-- Set the default database thresholds
BEGIN
dbms_server_alert.set_threshold(9000,null,null,null,null,1,1,'',5,'');
EXCEPTION
  when others then
    if sqlcode = -00001 then NULL;         -- unique constraint error
    else raise;
    end if;
END;
/

-- Create DBMS_SERVER_ALERT_EXPORT package
@@dbmsslxp
@@prvtslxp.plb

-- Register export package as a sysstem export action
DELETE FROM exppkgact$ WHERE package = 'DBMS_SERVER_ALERT_EXPORT'
/
INSERT INTO exppkgact$ (package, schema, class, level#)
  VALUES ('DBMS_SERVER_ALERT_EXPORT', 'SYS', 1, 1000)
/
commit
/

