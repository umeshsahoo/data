@echo off
TITLE Oracle XE - Configration
echo Adding user to ORA_DBA group...
C:\oraclexe\app\oracle\product\10.2.0\server\bin\oradim.exe -ex network useradd ORA_DBA "JANANI-J\janani" "Oracle DBA Group"
echo Creating Directories...
mkdir C:\oraclexe\app\oracle\admin\XE\adump
mkdir C:\oraclexe\app\oracle\admin\XE\bdump
mkdir C:\oraclexe\app\oracle\admin\XE\cdump
mkdir C:\oraclexe\app\oracle\admin\XE\dpdump
mkdir C:\oraclexe\app\oracle\admin\XE\pfile
mkdir C:\oraclexe\app\oracle\admin\XE\udump
mkdir C:\oraclexe\app\oracle\product\10.2.0\server\dbs
mkdir C:\oraclexe\oradata\XE
set ORACLE_SID=XE
echo Creating Instance...
C:\oraclexe\app\oracle\product\10.2.0\server\bin\oradim.exe -new -sid XE -startmode manual -spfile > C:\oraclexe\app\oracle\product\10.2.0\server\config\log\XE.bat.log
echo Starting Instance...
C:\oraclexe\app\oracle\product\10.2.0\server\bin\oradim.exe -edit -sid XE -startmode auto -srvcstart system >> C:\oraclexe\app\oracle\product\10.2.0\server\config\log\XE.bat.log
REM unset SQLPATH
set SQLPATH=
echo Database creation in progress...
C:\oraclexe\app\oracle\product\10.2.0\server\bin\orapwd.exe file=C:\oraclexe\app\oracle\product\10.2.0\server\database\PWDXE.ora password=%1 force=y
C:\oraclexe\app\oracle\product\10.2.0\server\bin\sqlplus /nolog @C:\oraclexe\app\oracle\product\10.2.0\server\config\scripts\XE.sql %1 %2
echo SPFILE='C:\oraclexe\app\oracle\product\10.2.0\server\dbs/spfileXE.ora' > C:\oraclexe\app\oracle\product\10.2.0\server\database\initXE.ora
C:\oraclexe\app\oracle\product\10.2.0\server\bin\sqlplus /nolog @C:\oraclexe\app\oracle\product\10.2.0\server\config\scripts\postDBCreation.sql %1
echo Seed Creation complete...
echo on
