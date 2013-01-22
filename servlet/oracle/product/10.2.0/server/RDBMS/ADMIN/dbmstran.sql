Rem
Rem $Header: dbmstran.sql 30-dec-2002.06:50:19 akalra Exp $
Rem
Rem dbmstrans.sql
Rem
Rem Copyright (c) 2000, 2002, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      dbmstrans.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      Transactions Package
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    akalra      12/30/02 - provide time-scn mapping functions
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    akalra      01/17/01 - grant execute priv. only to dba.
Rem    ssvemuri    09/21/00 - ICDs to trusted callouts.
Rem    amganesh    09/15/00 - diffs fix.
Rem    amganesh    09/15/00 - 
Rem    amganesh    09/12/00 - Created
Rem
create or replace package dbms_flashback AUTHID CURRENT_USER as

 ----------------
 -- OVERVIEW
 -- Procedures for enabling and disabling dbms_flashback.
 --
 ---------------------------
 -- PROCEDURES AND FUNCTIONS

procedure enable_at_time(query_time in TIMESTAMP);
procedure enable_at_system_change_number(query_scn in NUMBER);
procedure disable;
function get_system_change_number return NUMBER;
end;
/
create or replace public synonym dbms_flashback for sys.dbms_flashback
/
grant execute on dbms_flashback to dba
/
CREATE OR REPLACE LIBRARY dbms_tran_lib trusted as static
/

create or replace function timestamp_to_scn(query_time IN TIMESTAMP)
return NUMBER
IS EXTERNAL
NAME "ktfexttoscn"
WITH CONTEXT
PARAMETERS(context,
           query_time OCIDATETIME,
           RETURN)
LIBRARY DBMS_TRAN_LIB;
/

create or replace function scn_to_timestamp(query_scn IN NUMBER)
return TIMESTAMP
IS EXTERNAL
NAME "ktfexscntot"
WITH CONTEXT
PARAMETERS(context,
           query_scn OCINUMBER,
           RETURN)
LIBRARY DBMS_TRAN_LIB;
/

create or replace public synonym timestamp_to_scn for sys.timestamp_to_scn
/
create or replace public synonym scn_to_timestamp for sys.scn_to_timestamp
/
grant execute on timestamp_to_scn to PUBLIC
/
grant execute on scn_to_timestamp to PUBLIC
/
