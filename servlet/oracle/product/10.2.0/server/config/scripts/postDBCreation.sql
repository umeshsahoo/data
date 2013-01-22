DEFINE sysPassword = "&1"
connect "SYS"/"&&sysPassword" as SYSDBA
set echo on
spool C:\oraclexe\app\oracle\product\10.2.0\server\config\log\postDBCreation.log
connect "SYS"/"&&sysPassword" as SYSDBA
set echo on
//create or replace directory DB_BACKUPS as 'C:\oraclexe\app\oracle\flash_recovery_area';
begin
   dbms_xdb.sethttpport('8081');
   dbms_xdb.setftpport('0');
end;
/
create spfile='C:\oraclexe\app\oracle\product\10.2.0\server\dbs/spfileXE.ora' FROM pfile='C:\oraclexe\app\oracle\product\10.2.0\server\config\scripts\init.ora';
shutdown immediate;
connect "SYS"/"&&sysPassword" as SYSDBA
startup ;
select 'utl_recomp_begin: ' || to_char(sysdate, 'HH:MI:SS') from dual;
execute utl_recomp.recomp_serial();
select 'utl_recomp_end: ' || to_char(sysdate, 'HH:MI:SS') from dual;
alter user hr password expire account lock;
alter user ctxsys password expire account lock;
alter user outln password expire account lock;
alter user MDSYS password expire;
alter user FLOWS_FILES password expire;
alter user FLOWS_020100 password expire;
spool off;
exit
