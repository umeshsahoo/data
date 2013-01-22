Rem
Rem $Header: catprp.sql 07-mar-2005.11:23:57 narora Exp $
Rem
Rem catprp.sql
Rem
Rem Copyright (c) 2001, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catprp.sql - Streams Propagation Views
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    narora      03/02/05 - bug 4209149: add status to dba_propagation 
Rem    rvenkate    05/11/04 - queue_to_queue support 
Rem    elu         04/23/03 - modify all_propagation
Rem    elu         09/26/02 - add negative rulesets
Rem    sbalaram    06/19/02 - Fix bug 2395423
Rem    weiwang     02/01/02 - fix [dba|all]_propagation views
Rem    wesmith     01/10/02 - add grants to propagation views
Rem    sbalaram    12/10/01 - use create or replace synonym
Rem    alakshmi    11/08/01 - Merged alakshmi_apicleanup
Rem    jingliu     11/06/01 - fix typo
Rem    wesmith     11/04/01 - add public synonym for all_propagation
Rem    liwong      11/04/01 - Add all_propagation
Rem    kmeiyyap    11/02/01 - Created
Rem

CREATE OR REPLACE VIEW DBA_PROPAGATION
(PROPAGATION_NAME, SOURCE_QUEUE_OWNER, SOURCE_QUEUE_NAME, 
 DESTINATION_QUEUE_OWNER, DESTINATION_QUEUE_NAME, DESTINATION_DBLINK,
 RULE_SET_OWNER, RULE_SET_NAME, NEGATIVE_RULE_SET_OWNER, 
 NEGATIVE_RULE_SET_NAME, QUEUE_TO_QUEUE, STATUS,
 ERROR_MESSAGE, ERROR_DATE)
AS
SELECT p.propagation_name, p.source_queue_schema, p.source_queue,
       p.destination_queue_schema, p.destination_queue, p.destination_dblink,
       p.ruleset_schema, p.ruleset, p.negative_ruleset_schema, 
       p.negative_ruleset,
       case when bitand(p.spare1, 1) = 1 THEN 'TRUE' ELSE 'FALSE' END,
       decode (qs.schedule_disabled, 'Y', 'DISABLED', 'N', 'ENABLED', 
                                     null, 'ABORTED'),
       qs.last_error_msg, qs.last_error_date
  FROM sys.streams$_propagation_process p, dba_queue_schedules qs
  WHERE p.source_queue_schema = qs.schema (+) and
        p.source_queue = qs.qname (+) and
        qs.destination (+) = 
        case when bitand(p.spare1, 1) = 1 THEN
        dbms_logrep_util.canonical_concat(p.destination_queue_schema,
                                          p.destination_queue) || '@' ||
        p.destination_dblink
        ELSE p.destination_dblink END and
        qs.message_delivery_mode (+) = 'PERSISTENT'
/
COMMENT ON TABLE dba_propagation IS
'Streams propagation in the database'
/
COMMENT ON COLUMN dba_propagation.propagation_name IS
'name of the Streams propagation'
/
COMMENT ON COLUMN dba_propagation.source_queue_owner IS
'owner of the propgation source queue'
/
COMMENT ON COLUMN dba_propagation.source_queue_name IS
'name of the propagation source queue'
/
COMMENT ON COLUMN dba_propagation.destination_queue_owner IS
'owner of the propagation destination queue'
/
COMMENT ON COLUMN dba_propagation.destination_queue_name IS
'name of the propagation destination queue'
/
COMMENT ON COLUMN dba_propagation.destination_dblink IS
'database link to access the propagation destination queue'
/
COMMENT ON COLUMN dba_propagation.rule_set_owner IS
'propagation rule set owner'
/
COMMENT ON COLUMN dba_propagation.rule_set_name IS
'propagation rule set name'
/
COMMENT ON COLUMN dba_propagation.negative_rule_set_owner IS
'propagation negative rule set owner'
/
COMMENT ON COLUMN dba_propagation.negative_rule_set_name IS
'propagation negative rule set name'
/
COMMENT ON COLUMN dba_propagation.status IS
'Status of the propagation: DISABLED, ENABLED, ABORTED'
/
COMMENT ON COLUMN dba_propagation.error_message IS
'Error message last encountered by propagation'
/
COMMENT ON COLUMN dba_propagation.error_date IS
'The time that propagation last encountered an error'
/

CREATE OR REPLACE PUBLIC SYNONYM dba_propagation FOR dba_propagation
/
GRANT SELECT ON dba_propagation TO select_catalog_role
/


-- View of propagation processes
CREATE OR REPLACE VIEW ALL_PROPAGATION
AS
SELECT p.*
FROM   dba_propagation p, all_queues q
WHERE p.source_queue_owner = q.owner
   AND p.source_queue_name = q.name
   AND ((p.rule_set_owner IS NULL and p.rule_set_name IS NULL) OR
        ((p.rule_set_owner, p.rule_set_name) IN 
          (SELECT r.rule_set_owner, r.rule_set_name
             FROM all_rule_sets r)))
   AND ((p.negative_rule_set_owner IS NULL AND 
         p.negative_rule_set_name IS NULL) OR
        ((p.negative_rule_set_owner, p.negative_rule_set_name) IN 
          (SELECT r.rule_set_owner, r.rule_set_name
             FROM all_rule_sets r)))
/
COMMENT ON TABLE all_propagation IS
'Streams propagation seen by the user'
/
COMMENT ON COLUMN all_propagation.propagation_name IS
'name of the Streams propagation'
/
COMMENT ON COLUMN all_propagation.source_queue_owner IS
'owner of the propgation source queue'
/
COMMENT ON COLUMN all_propagation.source_queue_name IS
'name of the propagation source queue'
/
COMMENT ON COLUMN all_propagation.destination_queue_owner IS
'owner of the propagation destination queue'
/
COMMENT ON COLUMN all_propagation.destination_queue_name IS
'name of the propagation destination queue'
/
COMMENT ON COLUMN all_propagation.destination_dblink IS
'database link to access the propagation destination queue'
/
COMMENT ON COLUMN all_propagation.rule_set_owner IS
'propagation rule set owner'
/
COMMENT ON COLUMN all_propagation.rule_set_name IS
'propagation rule set name'
/
COMMENT ON COLUMN all_propagation.negative_rule_set_owner IS
'propagation negative rule set owner'
/
COMMENT ON COLUMN all_propagation.negative_rule_set_name IS
'propagation negative rule set name'
/
COMMENT ON COLUMN all_propagation.status IS
'Status of the propagation: DISABLED, ENABLED, ABORTED'
/
COMMENT ON COLUMN all_propagation.error_message IS
'Error message last encountered by propagation'
/
COMMENT ON COLUMN all_propagation.error_date IS
'The time that propagation last encountered an error'
/

CREATE OR REPLACE PUBLIC SYNONYM all_propagation FOR all_propagation
/
GRANT SELECT ON all_propagation TO public with grant option
/
