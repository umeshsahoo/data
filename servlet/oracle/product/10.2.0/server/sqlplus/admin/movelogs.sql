Rem
Rem $Header: movelogs.sql 19-jan-2006.00:23:11 banand Exp $
Rem
Rem movelogs.sql
Rem
Rem Copyright (c) 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      movelogs.sql - move online logs to new Flash Recovery Area
Rem
Rem    DESCRIPTION
Rem      This script can be used to move online logs from old online log
Rem      location to Flash Recovery Area. It assumes that the database 
Rem      instance is started with new Flash Recovery Area location.
Rem
Rem    NOTES
Rem      For use to rename online logs after moving Flash Recovery Area.
Rem      The script can be executed using following command
Rem          sqlplus '/ as sysdba' @movelogs.sql
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    banand      01/19/06 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100
declare
   cursor rlc is
      select group# grp, thread# thr, bytes/1024 bytes_k
        from v$log
      order by 1;
   stmt     varchar2(2048);
   swtstmt  varchar2(1024) := 'alter system switch logfile';
   ckpstmt  varchar2(1024) := 'alter system checkpoint global';
begin
   for rlcRec in rlc loop
  stmt := 'alter database add logfile thread ' ||
               rlcRec.thr || ' size ' ||
               rlcRec.bytes_k || 'K';
      execute immediate stmt;
      begin
         stmt := 'alter database drop logfile group ' || rlcRec.grp;
         execute immediate stmt;
      exception
         when others then
            execute immediate swtstmt;
            execute immediate ckpstmt;
            execute immediate stmt;
      end;
      execute immediate swtstmt;
   end loop;
end;
/

