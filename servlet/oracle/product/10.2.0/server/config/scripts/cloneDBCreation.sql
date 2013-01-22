connect "SYS"/"&&sysPassword" as SYSDBA
set echo on
spool C:\oraclexe\app\oracle\product\10.2.0\server\config\log\cloneDBCreation.log
Create controlfile reuse set database "XE"
MAXINSTANCES 8
MAXLOGHISTORY 1
MAXLOGFILES 16
MAXLOGMEMBERS 3
MAXDATAFILES 100
Datafile 
'C:\oraclexe\oradata\XE\system.dbf',
'C:\oraclexe\oradata\XE\undo.dbf',
'C:\oraclexe\oradata\XE\sysaux.dbf',
'C:\oraclexe\oradata\XE\users.dbf'
LOGFILE 
GROUP 1 SIZE 51200K,
GROUP 2 SIZE 51200K,
RESETLOGS;
exec dbms_backup_restore.zerodbid(0);
shutdown immediate;
startup nomount pfile="C:\oraclexe\app\oracle\product\10.2.0\server\config\scripts\initXETemp.ora";
Create controlfile reuse set database "XE"
MAXINSTANCES 8
MAXLOGHISTORY 1
MAXLOGFILES 16
MAXLOGMEMBERS 3
MAXDATAFILES 100
Datafile 
'C:\oraclexe\oradata\XE\system.dbf',
'C:\oraclexe\oradata\XE\undo.dbf',
'C:\oraclexe\oradata\XE\sysaux.dbf',
'C:\oraclexe\oradata\XE\users.dbf'
LOGFILE 
GROUP 1 SIZE 51200K,
GROUP 2 SIZE 51200K,
RESETLOGS;
alter system enable restricted session;
alter database "XE" open resetlogs;
alter database rename global_name to "XE";
alter system switch logfile;
alter system checkpoint;
alter database drop logfile group 3;
ALTER TABLESPACE TEMP ADD TEMPFILE 'C:\oraclexe\oradata\XE\temp.dbf' SIZE 20480K REUSE AUTOEXTEND ON NEXT 640K MAXSIZE UNLIMITED;
select tablespace_name from dba_tablespaces where tablespace_name='USERS';
select sid, program, serial#, username from v$session;
alter user sys identified by "&&sysPassword";
alter user system identified by "&&systemPassword";
alter system disable restricted session;
