connect "SYS"/"&&sysPassword" as SYSDBA
set echo on
spool C:\oraclexe\app\oracle\product\10.2.0\server\config\log\postScripts.log
@C:\oraclexe\app\oracle\product\10.2.0\server\rdbms\admin\dbmssml.sql;
@C:\oraclexe\app\oracle\product\10.2.0\server\rdbms\admin\dbmsclr.plb;
create or replace directory DATA_PUMP_DIR as 'C:\oraclexe\app\oracle\admin\XE\dpdump\';
commit;
connect "SYS"/"&&sysPassword" as SYSDBA
execute dbms_swrf_internal.cleanup_database(cleanup_local => FALSE);
commit;
spool off
