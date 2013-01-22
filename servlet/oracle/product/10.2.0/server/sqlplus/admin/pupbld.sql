--
-- Copyright (c) Oracle Corporation 1988, 2003.  All Rights Reserved.
--
-- NAME
--   pupbld.sql
--
-- DESCRIPTION
--   Script to install the SQL*Plus PRODUCT_USER_PROFILE tables.  These
--   tables allow SQL*Plus to disable commands per user.  The tables
--   are used only by SQL*Plus and do not affect other client tools
--   that access the database.  Refer to the SQL*Plus manual for table
--   usage information.
--
--   This script should be run on every database that SQL*Plus connects
--   to, even if the tables are not used to restrict commands.

-- USAGE
--   sqlplus system/<system_password> @pupbld
--
--   Connect as SYSTEM before running this script


-- If PRODUCT_USER_PROFILE exists, use its values and drop it

DROP SYNONYM PRODUCT_USER_PROFILE;

CREATE TABLE SQLPLUS_PRODUCT_PROFILE AS
  SELECT PRODUCT, USERID, ATTRIBUTE, SCOPE, NUMERIC_VALUE, CHAR_VALUE,
  DATE_VALUE FROM PRODUCT_USER_PROFILE;

DROP TABLE PRODUCT_USER_PROFILE;
ALTER TABLE SQLPLUS_PRODUCT_PROFILE ADD (LONG_VALUE LONG);

-- Create SQLPLUS_PRODUCT_PROFILE from scratch

CREATE TABLE SQLPLUS_PRODUCT_PROFILE
(
  PRODUCT        VARCHAR2 (30) NOT NULL,
  USERID         VARCHAR2 (30),
  ATTRIBUTE      VARCHAR2 (240),
  SCOPE          VARCHAR2 (240),
  NUMERIC_VALUE  DECIMAL (15,2),
  CHAR_VALUE     VARCHAR2 (240),
  DATE_VALUE     DATE,
  LONG_VALUE     LONG
);

-- Remove SQL*Plus V3 name for sqlplus_product_profile

DROP TABLE PRODUCT_PROFILE;

-- Create the view PRODUCT_PRIVS and grant access to that

DROP VIEW PRODUCT_PRIVS;
CREATE VIEW PRODUCT_PRIVS AS
  SELECT PRODUCT, USERID, ATTRIBUTE, SCOPE,
         NUMERIC_VALUE, CHAR_VALUE, DATE_VALUE, LONG_VALUE
  FROM SQLPLUS_PRODUCT_PROFILE
  WHERE USERID = 'PUBLIC' OR USER LIKE USERID;

GRANT SELECT ON PRODUCT_PRIVS TO PUBLIC;
DROP PUBLIC SYNONYM PRODUCT_PROFILE;
CREATE PUBLIC SYNONYM PRODUCT_PROFILE FOR SYSTEM.PRODUCT_PRIVS;
DROP SYNONYM PRODUCT_USER_PROFILE;
CREATE SYNONYM PRODUCT_USER_PROFILE FOR SYSTEM.SQLPLUS_PRODUCT_PROFILE;
DROP PUBLIC SYNONYM PRODUCT_USER_PROFILE;
CREATE PUBLIC SYNONYM PRODUCT_USER_PROFILE FOR SYSTEM.PRODUCT_PRIVS;

-- End of pupbld.sql
