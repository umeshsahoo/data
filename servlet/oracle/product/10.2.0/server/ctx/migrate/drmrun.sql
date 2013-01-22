Rem
Rem $Header: drmrun.sql 02-jun-98.14:22:18 gkaminag Exp $
Rem
Rem drmrun.sql
Rem
Rem  Copyright (c) Oracle Corporation 1998. All Rights Reserved.
Rem
Rem    NAME
Rem      drmrun.sql - Migration RUN
Rem
Rem    DESCRIPTION
Rem      run migration for a 2.X database
Rem
Rem    NOTES
Rem      run in SQL*Plus.  May not work in svrmgr
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    gkaminag    06/02/98 - migration run script
Rem    gkaminag    06/02/98 - Created
Rem

truncate table dr$msql;
exec dr_migrate.migrate;

set pages 0
set heading off
set lines 200
set feedback off
select text from dr$msql order by line
.

spool migrate.sql
/
spool off

