Rem
Rem $Header: occidemoxe.sql 16-oct-2005.22:46:39 sudsrini Exp $
Rem
Rem occidemoxe.sql
Rem
Rem Copyright (c) 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      occidemoxe.sql - OCCI DEMO SQL Script
Rem
Rem    DESCRIPTION
Rem      SQL script to create OCCI demo objects
Rem      Assume HR schema is setup
Rem      Execute this script before any of the OCCI demos are run
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sudsrini    10/16/05 - sudsrini_fix_xe_demos
Rem    sudsrini    10/14/05 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

connect hr/hr;

/* Drop objects before creating them */ 

DROP TABLE elements;
DROP TABLE author_tab;
DROP TABLE publisher_tab;

DROP TYPE publ_address;

CREATE TABLE elements (
  element_name VARCHAR2(25),
  molar_volume BINARY_FLOAT,
  atomic_weight BINARY_DOUBLE
);

CREATE TABLE author_tab ( 
  author_id NUMBER, 
  author_name VARCHAR2(25) 
); 

INSERT INTO author_tab (author_id, author_name) VALUES (333, 'JOE');
INSERT INTO author_tab (author_id, author_name) VALUES (444, 'SMITH');

CREATE OR REPLACE TYPE publ_address AS OBJECT ( 
  street_no NUMBER, 
  city VARCHAR2(25) 
) 
/ 

CREATE TABLE publisher_tab ( 
  publisher_id NUMBER, 
  publisher_add publ_address 
); 

INSERT INTO publisher_tab (publisher_id, publisher_add) VALUES 
(11, publ_address (121, 'NEW YORK'));

COMMIT;

