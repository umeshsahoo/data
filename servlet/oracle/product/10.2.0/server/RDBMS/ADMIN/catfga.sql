Rem
Rem $Header: catfga.sql 15-nov-2004.10:57:40 gtarora Exp $
Rem
Rem catfga.sql
Rem
Rem Copyright (c) 1900, 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catfga.sql - Catalog views for Fine Grained Auditing
Rem
Rem    DESCRIPTION
Rem      Creates data dictionary views for fine grained auditing policies
Rem
Rem    NOTES
Rem      MUST BE RUN WHILE CONNECTED AS SYS
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    gtarora     11/12/04 - bug 3984527 
Rem    gmulagun    08/30/04 - bug 3629208 set execution contextid 
Rem    gmulagun    08/23/04 - bug 3803784 add more columns to xml_audit_trail 
Rem    gmulagun    07/21/04 - bug 3784246 XML format audittrail for FGA
Rem    gmulagun    10/16/03 - bug 3198894: Invalid values for 
Rem                           POLICY_COLUMN_OPTIONS column 
Rem    rvissapr    09/10/03 - bug 3095609 - add all columns 
Rem    nmanappa    08/29/03 - Bug 2826225 - Add AUDIT_TRAIL column 
Rem    gmulagun    05/06/03 - create new unified audit view
Rem    gmulagun    03/27/03 - bug 2822534: rename tran_id to xid
Rem    gmulagun    03/13/03 - bug 2824670
Rem    gmulagun    11/20/02 - add lsqlbind clob column
Rem    gmulagun    09/23/02 - correct extended_timestamp column
Rem    rvissapr    09/19/02 - fix stmttype in audit trail
Rem    gmulagun    09/16/02 - enhance fga audit trail
Rem    rvissapr    06/17/02 - add statementtype and relevant column
Rem    dmwong      10/13/01 - sqltext -> lsqltext column.
Rem    dcwang      10/02/01 - add 3 more columns to dba_fga_audit_trail.
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    dmwong      04/26/01 - remove user tables to cover up audit conditions.
Rem    dmwong      07/13/00 - change all and user view definitions.
Rem    dmwong      04/10/00 - catalog views for fine grained auditing
Rem    dmwong      01/00/00 - Created
Rem

create or replace view DBA_AUDIT_POLICIES (OBJECT_SCHEMA, OBJECT_NAME, 
                          POLICY_NAME, POLICY_TEXT, POLICY_COLUMN, PF_SCHEMA, 
                          PF_PACKAGE, PF_FUNCTION, ENABLED, SEL, INS,
                          UPD, DEL, AUDIT_TRAIL, POLICY_COLUMN_OPTIONS)
as
select u.name, o.name, f.pname, f.ptxt, f.pcol, f.pfschma, f.ppname, f.pfname,
       decode(f.enable_flag, 0, 'NO', 1, 'YES', 'NO'),
       decode(bitand(f.stmt_type,1), 0, 'NO', 'YES'),
       decode(bitand(f.stmt_type,2), 0, 'NO', 'YES'),
       decode(bitand(f.stmt_type,4), 0, 'NO', 'YES'),
       decode(bitand(f.stmt_type,8), 0, 'NO', 'YES'),
       decode(bitand(f.stmt_type, 256), 0, 'DB', 'XML') ||
        decode(bitand(f.stmt_type,64), 0, '+EXTENDED'),
       decode(bitand(f.stmt_type, 128), 0, 'ANY_COLUMNS', 'ALL_COLUMNS')
from user$ u, obj$ o, fga$ f
where u.user# = o.owner#
and f.obj# = o.obj#
/
create or replace public synonym DBA_AUDIT_POLICIES for DBA_AUDIT_POLICIES
/
comment on table DBA_AUDIT_POLICIES is
'Fine grained auditing policies in the database'
/
comment on column DBA_AUDIT_POLICIES.OBJECT_SCHEMA is
'Owner of the table or view'
/
comment on column DBA_AUDIT_POLICIES.OBJECT_NAME is
'Name of the table or view'
/
comment on column DBA_AUDIT_POLICIES.POLICY_NAME is
'Name of the policy'
/
comment on column DBA_AUDIT_POLICIES.POLICY_TEXT is
'Audit condition'
/
comment on column DBA_AUDIT_POLICIES.POLICY_COLUMN is
'Deprecated'
/
comment on column DBA_AUDIT_POLICIES.PF_SCHEMA is
'Owner of the audit handler function'
/
comment on column DBA_AUDIT_POLICIES.PF_PACKAGE is
'Name of the package containing the audit handler function'
/
comment on column DBA_AUDIT_POLICIES.PF_FUNCTION is
'Name of the audit handler function'
/
comment on column DBA_AUDIT_POLICIES.ENABLED is
'Is this policy is enabled?'
/
comment on column DBA_AUDIT_POLICIES.SEL is
'If YES, policy is applied to query on the object'
/
comment on column DBA_AUDIT_POLICIES.INS is
'If YES, policy is applied to insert on the object'
/
comment on column DBA_AUDIT_POLICIES.UPD is
'If YES, policy is applied to update on the object'
/
comment on column DBA_AUDIT_POLICIES.DEL is
'If YES, policy is applied to delete on the object'
/
comment on column DBA_AUDIT_POLICIES.AUDIT_TRAIL is
'Whether to populate SQLTEXT and SQLBIND columns in audit trail for this policy. DB_EXTENDED -> Populate; DB -> Do not populate'
/
comment on column DBA_AUDIT_POLICIES.POLICY_COLUMN_OPTIONS is
'If ALL_COLUMNS then all relevant columns apply else any of the relevant columns apply'
/
grant select on DBA_AUDIT_POLICIES to select_catalog_role
/
create or replace view DBA_AUDIT_POLICY_COLUMNS(OBJECT_SCHEMA, OBJECT_NAME,
          POLICY_NAME, POLICY_COLUMN)
as
select u.name, o.name, f.pname, c.name
from user$ u, obj$ o, fga$ f, fgacol$ fc, col$ c
where u.user# = o.owner#
 and  f.obj#  = o.obj# 
 and  f.obj#  = fc.obj# and  f.pname = fc.pname
 and  c.obj#  = fc.obj# and  c.intcol#   = fc.intcol#
/
create or replace public synonym DBA_AUDIT_POLICY_COLUMNS for 
DBA_AUDIT_POLICY_COLUMNS
/
comment on table DBA_AUDIT_POLICY_COLUMNS is
'All fine grained auditing policy columns in the database'
/
comment on column DBA_AUDIT_POLICY_COLUMNS.OBJECT_SCHEMA is
'Owner of the table or view'
/
comment on column DBA_AUDIT_POLICY_COLUMNS.OBJECT_NAME is
'Object on which the policy is created'
/
comment on column DBA_AUDIT_POLICY_COLUMNS.POLICY_NAME is
'Name of the Fine Grain Audit policy'
/
comment on column DBA_AUDIT_POLICY_COLUMNS.POLICY_COLUMN is
'Audit relevant column of the policy'
/
grant select on DBA_AUDIT_POLICY_COLUMNS to select_catalog_role
/ 
create or replace view ALL_AUDIT_POLICIES (OBJECT_SCHEMA, OBJECT_NAME, 
                          POLICY_NAME, POLICY_TEXT, POLICY_COLUMN, PF_SCHEMA, 
                          PF_PACKAGE, PF_FUNCTION, ENABLED, SEL, INS, UPD,
                           DEL,AUDIT_TRAIL, POLICY_COLUMN_OPTIONS)
as
SELECT OBJECT_SCHEMA, OBJECT_NAME, POLICY_NAME, POLICY_TEXT,  POLICY_COLUMN,
       PF_SCHEMA, PF_PACKAGE, PF_FUNCTION, ENABLED, 
       SEL, INS, UPD, DEL, AUDIT_TRAIL, POLICY_COLUMN_OPTIONS
FROM DBA_AUDIT_POLICIES, ALL_TABLES t
WHERE 
(OBJECT_SCHEMA = t.OWNER AND OBJECT_NAME = t.TABLE_NAME) 
union
SELECT OBJECT_SCHEMA, OBJECT_NAME, POLICY_NAME, POLICY_TEXT,  POLICY_COLUMN,
       PF_SCHEMA, PF_PACKAGE, PF_FUNCTION, ENABLED,
       SEL, INS, UPD, DEL, AUDIT_TRAIL, POLICY_COLUMN_OPTIONS
FROM DBA_AUDIT_POLICIES, ALL_VIEWS v
WHERE
(OBJECT_SCHEMA = v.OWNER AND OBJECT_NAME = v.VIEW_NAME)
/
create or replace public synonym ALL_AUDIT_POLICIES for ALL_AUDIT_POLICIES
/
comment on table ALL_AUDIT_POLICIES is
'All fine grained auditing policies in the database'
/
comment on column ALL_AUDIT_POLICIES.OBJECT_SCHEMA is
'Owner of the table or view'
/
comment on column ALL_AUDIT_POLICIES.OBJECT_NAME is
'Name of the table or view'
/
comment on column ALL_AUDIT_POLICIES.POLICY_NAME is
'Name of the policy'
/
comment on column ALL_AUDIT_POLICIES.POLICY_TEXT is
'Audit condition'
/
comment on column ALL_AUDIT_POLICIES.POLICY_COLUMN is
'Deprecated'
/
comment on column ALL_AUDIT_POLICIES.PF_SCHEMA is
'Owner of the audit handler function'
/
comment on column ALL_AUDIT_POLICIES.PF_PACKAGE is
'Name of the package containing the audit handler function'
/
comment on column ALL_AUDIT_POLICIES.PF_FUNCTION is
'Name of the audit handler function'
/
comment on column ALL_AUDIT_POLICIES.ENABLED is
'Is this policy is enabled?'
/
comment on column ALL_AUDIT_POLICIES.SEL is
'If YES, policy is applied to query on the object'
/
comment on column ALL_AUDIT_POLICIES.INS is
'If YES, policy is applied to insert on the object'
/
comment on column ALL_AUDIT_POLICIES.UPD is
'If YES, policy is applied to update on the object'
/
comment on column ALL_AUDIT_POLICIES.DEL is
'If YES, policy is applied to delete on the object'
/
comment on column ALL_AUDIT_POLICIES.AUDIT_TRAIL is
'Whether to populate SQLTEXT and SQLBIND columns in audit trail for this policy. DB_EXTENDED -> Populate; DB -> Do not populate'
/
comment on column ALL_AUDIT_POLICIES.POLICY_COLUMN_OPTIONS is
'If ALL_COLUMNS then all relevant columns apply else any of the relevant columns apply'
/
grant select on ALL_AUDIT_POLICIES to select_catalog_role
/
create or replace view ALL_AUDIT_POLICY_COLUMNS (OBJECT_SCHEMA, OBJECT_NAME,
          POLICY_NAME, POLICY_COLUMN)
as
(select d.OBJECT_SCHEMA, d.OBJECT_NAME,
          d.POLICY_NAME, d.POLICY_COLUMN
from DBA_AUDIT_POLICY_COLUMNS d, ALL_TABLES t
where d.OBJECT_SCHEMA = t.OWNER AND d.OBJECT_NAME = t.TABLE_NAME)
union
(select d.OBJECT_SCHEMA, d.OBJECT_NAME,
          d.POLICY_NAME, d.POLICY_COLUMN
from DBA_AUDIT_POLICY_COLUMNS d, ALL_VIEWS v
where d.OBJECT_SCHEMA = v.OWNER AND d.OBJECT_NAME = v.VIEW_NAME)
/
create or replace public synonym ALL_AUDIT_POLICY_COLUMNS for 
ALL_AUDIT_POLICY_COLUMNS
/
comment on table ALL_AUDIT_POLICY_COLUMNS is
'All fine grained auditing policy columns in the database'
/
comment on column ALL_AUDIT_POLICY_COLUMNS.OBJECT_SCHEMA is
'Owner of the table or view'
/
comment on column ALL_AUDIT_POLICY_COLUMNS.OBJECT_NAME is
'Object on which the policy is created'
/
comment on column ALL_AUDIT_POLICY_COLUMNS.POLICY_NAME is
'Name of the Fine Grain Audit policy'
/
comment on column ALL_AUDIT_POLICY_COLUMNS.POLICY_COLUMN is
'Audit relevant column of the policy'
/
grant select on ALL_AUDIT_POLICY_COLUMNS to select_catalog_role
/
create or replace view USER_AUDIT_POLICIES (OBJECT_NAME, 
                          POLICY_NAME, POLICY_TEXT, POLICY_COLUMN, PF_SCHEMA, 
                          PF_PACKAGE, PF_FUNCTION, ENABLED, 
                          SEL, INS, UPD, DEL, AUDIT_TRAIL,
                          POLICY_COLUMN_OPTIONS)
as
SELECT OBJECT_NAME, POLICY_NAME, POLICY_TEXT,  POLICY_COLUMN,
       PF_SCHEMA, PF_PACKAGE, PF_FUNCTION, ENABLED,
       SEL, INS, UPD, DEL, AUDIT_TRAIL, POLICY_COLUMN_OPTIONS
FROM DBA_AUDIT_POLICIES
WHERE OBJECT_SCHEMA = SYS_CONTEXT('USERENV','CURRENT_SCHEMA')
/
create or replace public synonym USER_AUDIT_POLICIES for USER_AUDIT_POLICIES
/
comment on table USER_AUDIT_POLICIES is
'All fine grained auditing policies for objects in user schema'
/
comment on column USER_AUDIT_POLICIES.OBJECT_NAME is
'Name of the table or view'
/
comment on column USER_AUDIT_POLICIES.POLICY_NAME is
'Name of the policy'
/
comment on column USER_AUDIT_POLICIES.POLICY_TEXT is
'Audit condition'
/
comment on column USER_AUDIT_POLICIES.POLICY_COLUMN is
'Deprecated'
/
comment on column USER_AUDIT_POLICIES.PF_SCHEMA is
'Owner of the audit handler function'
/
comment on column USER_AUDIT_POLICIES.PF_PACKAGE is
'Name of the package containing the audit handler function'
/
comment on column USER_AUDIT_POLICIES.PF_FUNCTION is
'Name of the audit handler function'
/
comment on column USER_AUDIT_POLICIES.ENABLED is
'Is this policy is enabled?'
/
comment on column USER_AUDIT_POLICIES.SEL is
'If YES, policy is applied to query on the object'
/
comment on column USER_AUDIT_POLICIES.INS is
'If YES, policy is applied to insert on the object'
/
comment on column USER_AUDIT_POLICIES.UPD is
'If YES, policy is applied to update on the object'
/
comment on column USER_AUDIT_POLICIES.DEL is
'If YES, policy is applied to delete on the object'
/
comment on column USER_AUDIT_POLICIES.AUDIT_TRAIL is
'Whether to populate SQLTEXT and SQLBIND columns in audit trail for this policy. DB_EXTENDED -> Populate; DB -> Do not populate'
/
comment on column USER_AUDIT_POLICIES.POLICY_COLUMN_OPTIONS is
'If ALL_COLUMNS then all relevant columns apply else any of the relevant columns apply'
/
grant select on USER_AUDIT_POLICIES to select_catalog_role
/
create or replace view USER_AUDIT_POLICY_COLUMNS(OBJECT_SCHEMA, OBJECT_NAME,
          POLICY_NAME, POLICY_COLUMN)
as
select OBJECT_SCHEMA, OBJECT_NAME,
          POLICY_NAME, POLICY_COLUMN
from DBA_AUDIT_POLICY_COLUMNS
WHERE OBJECT_SCHEMA = SYS_CONTEXT('USERENV','CURRENT_SCHEMA')
/
create or replace public synonym USER_AUDIT_POLICY_COLUMNS for 
USER_AUDIT_POLICY_COLUMNS
/
comment on table USER_AUDIT_POLICY_COLUMNS is
'Users fine grained auditing policy columns in the database'
/
comment on column USER_AUDIT_POLICY_COLUMNS.OBJECT_SCHEMA is
'Owner of the table or view'
/
comment on column USER_AUDIT_POLICY_COLUMNS.OBJECT_NAME is
'Object on which the policy is created'
/
comment on column USER_AUDIT_POLICY_COLUMNS.POLICY_NAME is
'Name of the Fine Grain Audit policy'
/
comment on column USER_AUDIT_POLICY_COLUMNS.POLICY_COLUMN is
'Audit relevant column of the policy'
/
grant select on USER_AUDIT_POLICY_COLUMNS to select_catalog_role
/
create or replace view DBA_FGA_AUDIT_TRAIL (
      SESSION_ID, 
      TIMESTAMP, 
      DB_USER, OS_USER, USERHOST, CLIENT_ID, ECONTEXT_ID, EXT_NAME,
      OBJECT_SCHEMA, OBJECT_NAME, POLICY_NAME, SCN, SQL_TEXT, 
      SQL_BIND, COMMENT$TEXT, 
      STATEMENT_TYPE, 
      EXTENDED_TIMESTAMP, 
      PROXY_SESSIONID, GLOBAL_UID, INSTANCE_NUMBER, OS_PROCESS, 
      TRANSACTIONID, STATEMENTID, ENTRYID)
as
select 
      sessionid, 
      CAST (
        (FROM_TZ(ntimestamp#,'00:00') AT LOCAL) AS DATE
      ), 
      dbuid, osuid, oshst, clientid, auditid, extid, 
      obj$schema, obj$name, policyname, scn, to_nchar(substr(lsqltext,1,2000)),
      to_nchar(substr(lsqlbind,1,2000)), comment$text,
      DECODE(stmt_type,
              1, 'SELECT', 2, 'INSERT', 4, 'UPDATE', 8, 'DELETE', 'INVALID'),
      FROM_TZ(ntimestamp#,'00:00') AT LOCAL,
      proxy$sid, user$guid, instance#, process#,
      xid, statement, entryid
from sys.fga_log$
/
create or replace public synonym DBA_FGA_AUDIT_TRAIL for DBA_FGA_AUDIT_TRAIL
/
comment on table DBA_FGA_AUDIT_TRAIL is
'All fine grained audit event logs'
/
comment on column DBA_FGA_AUDIT_TRAIL.SESSION_ID is
'Session id of the query'
/
comment on column DBA_FGA_AUDIT_TRAIL.TIMESTAMP is
'Date/Time of the query in the session time zone'
/
comment on column DBA_FGA_AUDIT_TRAIL.DB_USER is
'Database username who executes the query'
/
comment on column DBA_FGA_AUDIT_TRAIL.OS_USER is
'OS username who executes the query'
/
comment on column DBA_FGA_AUDIT_TRAIL.USERHOST is
'Client host machine name'
/
comment on column DBA_FGA_AUDIT_TRAIL.CLIENT_ID is
'Client identifier in each Oracle session'
/
comment on column DBA_FGA_AUDIT_TRAIL.ECONTEXT_ID is
'Execution Context Identifier for each action'
/
comment on column DBA_FGA_AUDIT_TRAIL.EXT_NAME is
'External name'
/
comment on column DBA_FGA_AUDIT_TRAIL.OBJECT_SCHEMA is
'Owner of the table or view'
/
comment on column DBA_FGA_AUDIT_TRAIL.OBJECT_NAME is
'Name of the table or view'
/
comment on column DBA_FGA_AUDIT_TRAIL.POLICY_NAME is
'Name of Fine Grained Auditing Policy'
/
comment on column DBA_FGA_AUDIT_TRAIL.SCN is
'SCN of the query'
/
comment on column DBA_FGA_AUDIT_TRAIL.SQL_TEXT is
'SQL text of the query'
/
comment on column DBA_FGA_AUDIT_TRAIL.SQL_BIND is
'Bind variable data of the query'
/
comment on column DBA_FGA_AUDIT_TRAIL.COMMENT$TEXT is
'Comments'
/
comment on column DBA_FGA_AUDIT_TRAIL.STATEMENT_TYPE IS
'Statement Type of the query'
/
comment on column DBA_FGA_AUDIT_TRAIL.EXTENDED_TIMESTAMP is
'Timestamp of the query in the session time zone'
/
comment on column DBA_FGA_AUDIT_TRAIL.PROXY_SESSIONID is
'Proxy session serial number, if enterprise user has logged in through proxy mechanism'
/
comment on column DBA_FGA_AUDIT_TRAIL.GLOBAL_UID is
'Global user identifier for the user, if the user had logged in as enterprise user'
/
comment on column DBA_FGA_AUDIT_TRAIL.INSTANCE_NUMBER is
'Instance number as specified in initialization parameter file ''init.ora'''
/
comment on column DBA_FGA_AUDIT_TRAIL.OS_PROCESS is
'Operating System process identifier of the Oracle server process'
/
comment on column DBA_FGA_AUDIT_TRAIL.TRANSACTIONID is
'Transaction identifier of the transaction in which the object is accessed or modified'
/
comment on column DBA_FGA_AUDIT_TRAIL.STATEMENTID is
'Numeric ID for each statement run (a statement may cause many actions)'
/
comment on column DBA_FGA_AUDIT_TRAIL.ENTRYID is
'Numeric ID for each audit trail entry in the session'
/
grant select on DBA_FGA_AUDIT_TRAIL to select_catalog_role
/

create or replace view DBA_COMMON_AUDIT_TRAIL (AUDIT_TYPE, SESSION_ID,
    PROXY_SESSIONID, STATEMENTID, ENTRYID, EXTENDED_TIMESTAMP, GLOBAL_UID,
    DB_USER, CLIENT_ID, ECONTEXT_ID, EXT_NAME, OS_USER, 
    USERHOST, OS_PROCESS, TERMINAL,
    INSTANCE_NUMBER, OBJECT_SCHEMA, OBJECT_NAME, POLICY_NAME, NEW_OWNER,
    NEW_NAME, ACTION, STATEMENT_TYPE, AUDIT_OPTION, TRANSACTIONID, RETURNCODE, 
    SCN, COMMENT_TEXT, SQL_BIND, SQL_TEXT, OBJ_PRIVILEGE, SYS_PRIVILEGE, 
    ADMIN_OPTION, OS_PRIVILEGE, GRANTEE, PRIV_USED,
    SES_ACTIONS, LOGOFF_TIME, LOGOFF_LREAD, LOGOFF_PREAD, LOGOFF_LWRITE,
    LOGOFF_DLOCK, SESSION_CPU)
as
select 'Standard Audit', SESSIONID,
    PROXY_SESSIONID, STATEMENTID, ENTRYID, EXTENDED_TIMESTAMP, GLOBAL_UID,
    USERNAME, CLIENT_ID, ECONTEXT_ID, Null, OS_USERNAME, 
    USERHOST, OS_PROCESS, TERMINAL,
    INSTANCE_NUMBER, OWNER, OBJ_NAME, Null, NEW_OWNER,
    NEW_NAME, ACTION, ACTION_NAME, AUDIT_OPTION, TRANSACTIONID, RETURNCODE, 
    SCN, COMMENT_TEXT, SQL_BIND, SQL_TEXT,
    OBJ_PRIVILEGE, SYS_PRIVILEGE, ADMIN_OPTION, 'NONE', GRANTEE, PRIV_USED,
    SES_ACTIONS, LOGOFF_TIME, LOGOFF_LREAD, LOGOFF_PREAD, LOGOFF_LWRITE,
    LOGOFF_DLOCK, SESSION_CPU
  from DBA_AUDIT_TRAIL
UNION ALL
select DECODE(BITAND(audit_type, 15), 1, 'Standard XML Audit', 
                                      2, 'Fine Grained XML Audit',
                                      4, 'SYS XML Audit',
                                      8, 'Mandatory XML Audit'),
    SESSION_ID,
    PROXY_SESSIONID, STATEMENTID, ENTRYID, EXTENDED_TIMESTAMP, GLOBAL_UID,
    DB_USER, CLIENTIDENTIFIER, ECONTEXT_ID, EXT_NAME, OS_USER, 
    OS_HOST, OS_PROCESS, TERMINAL,
    INSTANCE_NUMBER, OBJECT_SCHEMA, OBJECT_NAME, POLICY_NAME, NEW_OWNER,
    NEW_NAME, xad.ACTION, 
    DECODE(BITAND(audit_type, 15), 
        1,                              /* Standard Audit actions */
        act.name,
        2,                              /* Fine Grained Audit actions */
        DECODE(statement_type, 1, 'SELECT',  2, 'INSERT', 
                               4, 'UPDATE',  8, 'DELETE',  'INVALID'),
        Null),
    Null,                                            /* AUDIT_OPTION */
    TRANSACTIONID, RETURNCODE, 
    SCN, COMMENT_TEXT, TO_NCHAR(sql_bind), TO_NCHAR(sql_text),
    DECODE(xad.action,
        108 /* grant  sys_priv */, Null,
        109 /* revoke sys_priv */, Null,
        114 /* grant  role */,     Null,
        115 /* revoke role */,     Null,
        auth_privileges),                            /* OBJ_PRIVILEGE */
    Null,                                            /* SYS_PRIVILEGE */
    DECODE(xad.action, 
        108 /* grant  sys_priv */, SUBSTR(auth_privileges,1,1), 
        109 /* revoke sys_priv */, SUBSTR(auth_privileges,1,1), 
        114 /* grant  role */,     SUBSTR(auth_privileges,1,1),
        115 /* revoke role */,     SUBSTR(auth_privileges,1,1), 
        Null),                                        /* ADMIN_OPTION */
    OS_PRIVILEGE, GRANTEE, spx.name, SES_ACTIONS, 
    Null, Null, Null, Null, Null, Null
  from GV$XML_AUDIT_TRAIL xad,
       SYSTEM_PRIVILEGE_MAP spx, AUDIT_ACTIONS act
  where xad.action      = act.action    (+)
  and - xad.priv_used   = spx.privilege (+)
UNION ALL
select 'Fine Grained Audit', SESSION_ID,
    PROXY_SESSIONID, STATEMENTID, ENTRYID, EXTENDED_TIMESTAMP, GLOBAL_UID,
    DB_USER, CLIENT_ID, ECONTEXT_ID, EXT_NAME, OS_USER, 
    USERHOST, OS_PROCESS, Null,
    INSTANCE_NUMBER, OBJECT_SCHEMA, OBJECT_NAME, POLICY_NAME, Null,
    Null, Null, STATEMENT_TYPE, Null, TRANSACTIONID, Null, 
    SCN, COMMENT$TEXT, SQL_BIND, SQL_TEXT,
    Null, Null, Null, 'NONE', Null,
    Null, Null, Null, Null, Null,
    Null, Null, Null
  from DBA_FGA_AUDIT_TRAIL
/
create or replace public synonym DBA_COMMON_AUDIT_TRAIL for DBA_COMMON_AUDIT_TRAIL
/
grant select on DBA_COMMON_AUDIT_TRAIL  to select_catalog_role
/
comment on table DBA_COMMON_AUDIT_TRAIL is
'Combined Standard and Fine Grained audit trail entries'
/
comment on column DBA_COMMON_AUDIT_TRAIL.AUDIT_TYPE is
'Audit trail type'
/
comment on column DBA_COMMON_AUDIT_TRAIL.SESSION_ID is
'Numeric id for the Oracle session'
/
comment on column DBA_COMMON_AUDIT_TRAIL.PROXY_SESSIONID is
'Proxy session serial number, if enterprise user has logged through proxy mechanism'
/
comment on column DBA_COMMON_AUDIT_TRAIL.STATEMENTID is
'Numeric id for the statement run (a statement may cause multiple audit records)'
/
comment on column DBA_COMMON_AUDIT_TRAIL.ENTRYID is
'Numeric id for the audit trail entry in the session'
/
comment on column DBA_COMMON_AUDIT_TRAIL.EXTENDED_TIMESTAMP is
'Timestamp of the audited operation (Timestamp of the user''s logon for entries created by AUDIT SESSION) in session''s time zone'
/
comment on column DBA_COMMON_AUDIT_TRAIL.GLOBAL_UID is
'Global user identifier for the user, if the user had logged in as enterprise user'
/
comment on column DBA_COMMON_AUDIT_TRAIL.DB_USER is
'Database username of the user whose actions were audited'
/
comment on column DBA_COMMON_AUDIT_TRAIL.CLIENT_ID is
'Client identifier in the Oracle session'
/
comment on column DBA_COMMON_AUDIT_TRAIL.ECONTEXT_ID is
'Execution Context Identifier for each action'
/
comment on column DBA_COMMON_AUDIT_TRAIL.EXT_NAME is
'User external name'
/
comment on column DBA_COMMON_AUDIT_TRAIL.OS_USER is
'Operating System logon user name of the user whose actions were audited'
/
comment on column DBA_COMMON_AUDIT_TRAIL.USERHOST is
'Client host machine name'
/
comment on column DBA_COMMON_AUDIT_TRAIL.OS_PROCESS is
'Operating System process identifier of the Oracle server process'
/
comment on column DBA_COMMON_AUDIT_TRAIL.TERMINAL is
'Identifier for the user''s terminal'
/
comment on column DBA_COMMON_AUDIT_TRAIL.INSTANCE_NUMBER is
'Instance number as specified in the initialization parameter file ''init.ora'''
/
comment on column DBA_COMMON_AUDIT_TRAIL.OBJECT_SCHEMA is
'Owner of the audited object'
/
comment on column DBA_COMMON_AUDIT_TRAIL.OBJECT_NAME is
'Name of the object affected by the action'
/
comment on column DBA_COMMON_AUDIT_TRAIL.POLICY_NAME is
'Name of Fine Grained Auditing Policy'
/
comment on column DBA_COMMON_AUDIT_TRAIL.NEW_OWNER is
'Owner of the object named in the NEW_NAME column'
/
comment on column DBA_COMMON_AUDIT_TRAIL.NEW_NAME is
'New name of object after RENAME, or name of underlying object (e.g. CREATE INDEX owner.obj_name ON new_owner.new_name)'
/
comment on column DBA_COMMON_AUDIT_TRAIL.ACTION is
'Numeric action type code'
/
comment on column DBA_COMMON_AUDIT_TRAIL.STATEMENT_TYPE is
'Action type corresponding to the numeric code in ACTION'
/
comment on column DBA_COMMON_AUDIT_TRAIL.AUDIT_OPTION is
'Auditing option set with the standard audit statement'
/
comment on column DBA_COMMON_AUDIT_TRAIL.TRANSACTIONID is
'Transaction identifier of the transaction in which the object is accessed or modified'
/
comment on column DBA_COMMON_AUDIT_TRAIL.RETURNCODE is
'Oracle error code generated by the action. Zero if the action succeeded'
/
comment on column DBA_COMMON_AUDIT_TRAIL.SCN is
'SCN (System Change Number) of the query'
/
comment on column DBA_COMMON_AUDIT_TRAIL.COMMENT_TEXT is
'Text comment on the audit trail entry.
Also indicates how the user was authenticated. The method can be one of the
following:
1. "DATABASE" - authentication was done by password.
2. "NETWORK"  - authentication was done by Net8 or the Advanced Networking
   Option.
3. "PROXY"    - the client was authenticated by another user. The name of the
   proxy user follows the method type.'
/
comment on column DBA_COMMON_AUDIT_TRAIL.SQL_BIND is
'Bind variable data of the query'
/
comment on column DBA_COMMON_AUDIT_TRAIL.SQL_TEXT is
'SQL text of the query'
/
comment on column DBA_COMMON_AUDIT_TRAIL.OBJ_PRIVILEGE is
'Object privileges granted/revoked by a GRANT/REVOKE statement'
/
comment on column DBA_COMMON_AUDIT_TRAIL.SYS_PRIVILEGE is
'System privileges granted/revoked by a GRANT/REVOKE statement'
/
comment on column DBA_COMMON_AUDIT_TRAIL.ADMIN_OPTION is
'If role/sys_priv was granted WITH ADMIN OPTON, A/-'
/
remark  There is one audit entry for each grantee.

comment on column DBA_COMMON_AUDIT_TRAIL.OS_PRIVILEGE is
'Operating Privilege (SYSDBA/SYSOPER) used in the session. If no privilege is used, it will be NONE'
/
comment on column DBA_COMMON_AUDIT_TRAIL.GRANTEE is
'The name of the grantee specified in a GRANT/REVOKE statement'
/
comment on column DBA_COMMON_AUDIT_TRAIL.PRIV_USED is
'System privilege used to perform the action'
/
comment on column DBA_COMMON_AUDIT_TRAIL.SES_ACTIONS is
'Session summary.  A string of 12 characters, one for each action type, in thisorder: Alter, Audit, Comment, Delete, Grant, Index, Insert, Lock, Rename, Select, Update, Flashback.  Values:  "-" = None, "S" = Success, "F" = Failure, "B" = Both'
/
remark  A single audit entry describes both the logon and logoff.
remark  The logoff_* columns are null while a user is logged in.

comment on column DBA_COMMON_AUDIT_TRAIL.LOGOFF_TIME is
'Timestamp for user logoff'
/
comment on column DBA_COMMON_AUDIT_TRAIL.LOGOFF_LREAD is
'Number of logical reads in the session'
/
comment on column DBA_COMMON_AUDIT_TRAIL.LOGOFF_PREAD is
'Number of physical reads in the session'
/
comment on column DBA_COMMON_AUDIT_TRAIL.LOGOFF_LWRITE is
'Number of logical writes of the session'
/
comment on column DBA_COMMON_AUDIT_TRAIL.LOGOFF_DLOCK is
'Number of deadlocks detected during the session'
/
comment on column DBA_COMMON_AUDIT_TRAIL.SESSION_CPU is
'Amount of cpu time used by the Oracle session'
/
