Rem
Rem $Header: dr0lib.sql 04-feb-2003.12:20:42 gkaminag Exp $
Rem
Rem dr0lib.sql
Rem
Rem Copyright (c) 1999, 2003, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      dr0lib.sql - <one-line expansion of the name>
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
Rem    ehuang      07/11/02 - add PROMPT
Rem    gkaminag    03/12/99 - work around SQL*Plus bug
Rem    dyu         02/02/99 - create library for ctxx
Rem    dyu         02/02/99 - Created
Rem

PROMPT ... creating trusted callout library
create or replace library dr$lib trusted as static;
/




