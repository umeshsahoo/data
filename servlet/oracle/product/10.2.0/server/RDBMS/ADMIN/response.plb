/* This table stores the overall snapshot info */
CREATE TABLE dbsnmp.mgmt_snapshot(
       instance_number 		NUMBER NOT NULL,
       snap_id         		NUMBER NOT NULL,
       capture_time    		DATE NOT NULL,
       db_time         		NUMBER,
       cpu_time        		NUMBER,
       application_wait_time	NUMBER,
       cluster_wait_time	NUMBER,
       user_io_wait_time	NUMBER,
       concurrency_wait_time	NUMBER) NOLOGGING;
/* This table is used to store v$sql snapshot, while configuring baseline. */
CREATE TABLE dbsnmp.mgmt_snapshot_sql(
       snap_id         NUMBER NOT NULL,
       sql_id          VARCHAR2(13),
       hash_value      NUMBER NOT NULL,
       child_number    NUMBER NOT NULL,
       elapsed_time    NUMBER NOT NULL,
       executions      NUMBER NOT NULL) NOLOGGING;
/* This table stores the overall baseline info */
CREATE TABLE dbsnmp.mgmt_baseline(
       instance_number 		NUMBER NOT NULL,
       capture_time    		DATE NOT NULL,
       prev_capture_time 	DATE NOT NULL,
       db_time         		NUMBER,
       cpu_time                 NUMBER,
       application_wait_time    NUMBER,
       cluster_wait_time        NUMBER,
       user_io_wait_time        NUMBER,
       concurrency_wait_time    NUMBER);
/* The baseline table stores the identity of the SQL statements as well as
** the baseline elapsed_time_per_execution for those statements.
*/
CREATE TABLE dbsnmp.mgmt_baseline_sql(
       instance_number NUMBER NOT NULL,
       sql_text        VARCHAR2(1000),
       sql_id          VARCHAR2(13),
       hash_value      NUMBER NOT NULL,
       executions      NUMBER,
       elapsed_time    NUMBER,
       t_per_exec      NUMBER NOT NULL);
/* This table stores the overall capture info */
CREATE TABLE dbsnmp.mgmt_capture(
       instance_number 		NUMBER NOT NULL,
       capture_id      		NUMBER NOT NULL,
       capture_time    		DATE NOT NULL,
       db_time         		NUMBER,
       cpu_time                 NUMBER,
       application_wait_time    NUMBER,
       cluster_wait_time        NUMBER,
       user_io_wait_time        NUMBER,
       concurrency_wait_time    NUMBER);
/* Statistics are captured from v$sql at a regular interval and stored in
** the capture table. The columns capture_id and address together form
** the primary key. The elapsed_time and executions columns store cumulative
** values as opposed to deltas.
*/
CREATE TABLE dbsnmp.mgmt_capture_sql(
       capture_id      NUMBER NOT NULL,
       sql_id          VARCHAR2(13),
       hash_value      NUMBER NOT NULL,
       elapsed_time    NUMBER,
       executions      NUMBER);
/* Remember instance startup time in this table so that we can detect when
** the instance has been bounced.
*/
CREATE TABLE dbsnmp.mgmt_response_config(
       instance_number NUMBER NOT NULL,
       startup_time    DATE);
/* This table stores the overall latest metric info */
CREATE TABLE dbsnmp.mgmt_latest(
       instance_number 		NUMBER NOT NULL,
       capture_id      		NUMBER NOT NULL,
       capture_time    		DATE NOT NULL,
       prev_capture_time 	DATE NOT NULL,
       sql_response_time 	NUMBER NOT NULL,
       adjusted_sql_response_time NUMBER NOT NULL,
       baseline_sql_response_time NUMBER NOT NULL,
       relative_sql_response_time NUMBER NOT NULL,
       db_time         		NUMBER,
       cpu_time                 NUMBER,
       application_wait_time    NUMBER,
       cluster_wait_time        NUMBER,
       user_io_wait_time        NUMBER,
       concurrency_wait_time    NUMBER);
/* This table stores the sql info of the latest metric*/
CREATE TABLE dbsnmp.mgmt_latest_sql(
       capture_id      NUMBER NOT NULL,
       sql_id          VARCHAR2(13),
       hash_value      NUMBER NOT NULL,
       executions      NUMBER,
       elapsed_time    NUMBER,
       t_per_exec      NUMBER,
       adjusted_elapsed_time NUMBER);
/* This table stores the overall info for those metrics whose metric value
** exceeds the threshold.
*/
CREATE TABLE dbsnmp.mgmt_history(
       instance_number 		NUMBER NOT NULL,
       capture_id      		NUMBER NOT NULL,
       capture_time    		DATE NOT NULL,
       prev_capture_time 	DATE NOT NULL,
       sql_response_time 	NUMBER NOT NULL,
       adjusted_sql_response_time NUMBER NOT NULL,
       baseline_sql_response_time NUMBER NOT NULL,
       relative_sql_response_time NUMBER NOT NULL,
       db_time         		NUMBER,
       cpu_time                 NUMBER,
       application_wait_time    NUMBER,
       cluster_wait_time        NUMBER,
       user_io_wait_time        NUMBER,
       concurrency_wait_time    NUMBER);
/* this table is used to save the baseline and capture data when the sql 
** response time is exceeded four times (THRESHOLD_FOR_HISTORY) of the baseline. 
** We always keep no more than 25 collections for each instance.
*/
CREATE TABLE dbsnmp.mgmt_history_sql(
       capture_id       NUMBER NOT NULL,
       sql_id           VARCHAR2(13),
       hash_value       NUMBER NOT NULL,
       executions       NUMBER,
       elapsed_time     NUMBER,
       t_per_exec       NUMBER,
       adjusted_elapsed_time NUMBER);
CREATE GLOBAL TEMPORARY TABLE dbsnmp.mgmt_tempt_sql(
       sql_id          VARCHAR2(13),
       hash_value      NUMBER NOT NULL,
       elapsed_time    NUMBER NOT NULL,
       executions      NUMBER NOT NULL)
       ON COMMIT DELETE ROWS;
CREATE sequence dbsnmp.mgmt_response_capture_id 
       START WITH 1 INCREMENT BY 1 ORDER;
CREATE sequence dbsnmp.mgmt_response_snapshot_id 
       START WITH 1 INCREMENT BY 1 ORDER;
CREATE OR REPLACE VIEW dbsnmp.mgmt_response_baseline AS
   SELECT b.instance_number, s.sql_text, s.hash_value, v.address, s.t_per_exec
     FROM dbsnmp.mgmt_baseline b, dbsnmp.mgmt_baseline_sql s, v$sqlarea v
    WHERE b.instance_number = s.instance_number
      AND s.hash_value = v.hash_value;
CREATE OR REPLACE PACKAGE dbsnmp.mgmt_response wrapped 
a000000
1
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
9
402 203
5iB/wb0PB5ifCgbVvLvwMIHoE/4wg2NemJ/WfHTN7M8CQMu43Kef110ERM/hYdX6oFjStarM
HdeMZyVrtgYZCvahp4wtSV7v9TJJ8oV/MGC4NESmrcZZDsgDJ7ZSyqSoxmcwRr2DKJcLmytx
paYq8tDbhFkW9HrSQH4LfRCOYJ5vCqLnp1Dn/K98Yf8LrxmiMo28N06PXr9ngzfqp9zOOY2C
nJ66R9Hks/z35r8N1lF/aORYv/dytHpbjqTFBhtdZ1+lozdDJ0Eqf3hKXoM0HkludbYntXvS
wK1FfW7q5Ob4kTY8oCuwusXoKEYUKNt/zPCrgycNrP0FV6dnwYhy6ICNpanX6mS/BQlolQvp
2S7F6naDNJRWtVIvsXN0U03LhppVZ59wC6OsG9Q8k4KKSz+rSZmVnwMxXbfdYfRE3kw29IJD
FR0z/PPPSDdQBU7lwnG8JmhoVHH3+GazxSjetOOof+9MaPuSJ72cnIBXiLvEk4H4JrsPvPtL
bY4j

/
CREATE OR REPLACE PACKAGE BODY dbsnmp.mgmt_response wrapped 
a000000
1
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
b
7d2c 1ab5
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

/
/*
set timing on
variable rc refcursor;
begin

end;
/
print rc
prompt @@  content of mgmt_snapshot
SELECT snap_id FROM dbsnmp.mgmt_snapshot;
prompt @@  content of mgmt_baseline_sql
SELECT sql_id, hash_value, executions, elapsed_time FROM dbsnmp.mgmt_baseline_sql
order by hash_value;
prompt @@  content of mgmt_capture_sql
select capture_id, sql_id, hash_value, executions, elapsed_time from dbsnmp.mgmt_capture_sql
order by hash_value, capture_id;
prompt @@  content of mgmt_history_sql
select capture_id, sql_id, hash_value, executions, elapsed_time, t_per_exec, adjusted_elapsed_time
from dbsnmp.mgmt_history_sql
order by capture_id, sql_id, hash_value DESC;
prompt @@ unique capture_id in mgmt_history_sql
select unique capture_id 
from dbsnmp.mgmt_history_sql;
*/
show errors
