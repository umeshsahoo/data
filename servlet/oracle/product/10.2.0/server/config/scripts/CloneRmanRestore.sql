connect "SYS"/"&&sysPassword" as SYSDBA
set echo on
spool C:\oraclexe\app\oracle\product\10.2.0\server\config\log\CloneRmanRestore.log
startup nomount pfile="C:\oraclexe\app\oracle\product\10.2.0\server\config\scripts\init.ora";
@C:\oraclexe\app\oracle\product\10.2.0\server\config\scripts\rmanRestoreDatafiles.sql;
