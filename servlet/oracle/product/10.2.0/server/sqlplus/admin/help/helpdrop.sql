--
-- Copyright (c) Oracle Corporation 1998, 2000.  All Rights Reserved.
--
-- NAME
--   helpdrop.sql
--
-- DESCRIPTION
--   Drops the SQL*Plus HELP table
--
-- USAGE
--   Connect as SYSTEM to run this script e.g.
--       sqlplus system/<system_password> @helpdrop.sql

SET TERMOUT OFF

DROP TABLE HELP;
DROP VIEW HELP_TEMP_VIEW;

EXIT
