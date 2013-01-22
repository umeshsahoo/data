Rem
Rem $Header: initsjty.sql 07-aug-2005.23:43:57 srirkris Exp $
Rem
Rem initsqljtype.sql
Rem
Rem Copyright (c) 2000, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      initsqljtype.sql - initialization for sqlj types
Rem
Rem    DESCRIPTION
Rem      load java classes required for sqljtype validation 
Rem      and generation of helper classes.
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    srirkris    08/04/05 - add dbmssjty and prvtsjty
Rem    varora      09/01/00 - Created
Rem

call sys.dbms_java.loadjava('-v -r rdbms/jlib/sqljtype.jar');
@@dbmssjty.sql
@@prvtsjty.plb
