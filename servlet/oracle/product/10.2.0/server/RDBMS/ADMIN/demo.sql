create user demo identified by demo;
grant connect to demo;
grant resource to demo;
alter user demo default tablespace users;
alter user demo temporary tablespace temp;
connect demo/demo
alter session set NLS_TERRITORY = AMERICA;
alter session set NLS_LANGUAGE = AMERICAN;
@@bdemobld.sql
