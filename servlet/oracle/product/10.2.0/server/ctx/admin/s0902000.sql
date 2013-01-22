Rem
Rem s0902000.sql
Rem
Rem Copyright (c) 2000, 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      s0902000.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem     This script upgrades an 9.2.0.X schema to 10.
Rem     This script should be run as SYS on an 9.2.0 ctxsys schema
Rem     No other users or schema versions are supported.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    gkaminag    08/02/04 - deprecation of connect 
Rem    ekwan       10/06/03 - 3161706: grant select on HIST_HEAD AND COLTYPE
Rem    surman      09/04/03 - 3101316: Update duc$ for drop user cascade 
Rem    gkaminag    08/19/03 - allow ctxsys to admin ctxapp 
Rem    gkaminag    02/05/03 - priv problem
Rem    gkaminag    01/24/03 - security changes
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>

grant select on SYS.CCOL$ to ctxsys with grant option;
grant select on SYS.CDEF$ to ctxsys with grant option;
grant select on SYS.COL$ to ctxsys with grant option;
grant select on SYS.CON$ to ctxsys with grant option;
grant select on SYS.ICOL$ to ctxsys with grant option;
grant select on SYS.LOB$ to ctxsys with grant option;
grant select on SYS.LOB$ to ctxsys with grant option;
grant select on SYS.LOBFRAG$ to ctxsys with grant option;
grant select on SYS.LOBFRAG$ to ctxsys with grant option;
grant select on SYS.PARTOBJ$ to ctxsys with grant option;
grant select on SYS.DBA_INDEXTYPES to ctxsys with grant option;
grant select on SYS.HIST_HEAD$ to ctxsys;
grant select on SYS.COLTYPE$ to ctxsys;

update sys.registry$ set invoker# = 0 where cname = 'Oracle Text';
commit;

rem this is not a mistake -- the number of system privs that
rem constitute "all privileges" is different from version to
rem version of the database.  If you try to revoke all privs from
rem a ctxsys that was created in 9.2 (137 privs) you get an error
rem because all privs in 10i is 147 privs.  
rem so to get around the error, we grant then revoke.

GRANT ALL PRIVILEGES TO CTXSYS;
REVOKE ALL PRIVILEGES FROM CTXSYS;

REVOKE DBA FROM CTXSYS;

grant create session, alter session, create view, create synonym, resource,
create public synonym, drop public synonym to ctxsys; 
grant ctxapp to ctxsys with admin option;

REM Support DROP USER CASCADE
DELETE FROM sys.duc$
  WHERE owner = 'CTXSYS'
    AND pack = 'CTX_ADM'
    AND proc = 'DROP_USER_OBJECTS'
    AND operation# = 1;

INSERT INTO sys.duc$ (owner, pack, proc, operation#, seq, com)
  VALUES ('CTXSYS', 'CTX_ADM', 'DROP_USER_OBJECTS', 1, 1,
          'Drops any Text objects for this user');

COMMIT;
