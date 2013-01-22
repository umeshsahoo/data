Rem
Rem $Header: dr0ulib.sql 04-feb-2003.12:20:39 gkaminag Exp $
Rem
Rem dr0ulib.sql
Rem
Rem Copyright (c) 2001, 2003, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      dr0ulib.sql - upgrade shared library
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    gkaminag    02/04/03 - remove ctxx
Rem    ehuang      07/31/02 - add trusted library
Rem    gkaminag    03/27/01 - Created
Rem


PROMPT ... creating trusted callout library
create or replace library dr$lib trusted as static;
/
