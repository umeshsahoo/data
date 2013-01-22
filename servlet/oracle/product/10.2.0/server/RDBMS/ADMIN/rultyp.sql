Rem
Rem $Header: rultyp.sql 23-apr-2004.19:00:24 ayalaman Exp $
Rem
Rem rultyp.sql
Rem
Rem Copyright (c) 2004, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      rultyp.sql - Rule Manager object types 
Rem
Rem    DESCRIPTION
Rem      This script defines the object types that are used for the 
Rem      Rule manager implementation/APIs
Rem
Rem    NOTES
Rem      See Documentation.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ayalaman    04/23/04 - ayalaman_rule_manager_support 
Rem    ayalaman    04/15/04 - synonym for rlm_table_alias 
Rem    ayalaman    04/02/04 - Created
Rem

REM 
REM Rule Manager Object Types
REM 
prompt .. creating Rule Manager object types
/***************************************************************************/
/***                      Public Object Types                            ***/
/***************************************************************************/
---- RLM$ROWIDTAB : Used to represent a list of rowids 
create or replace type exfsys.rlm$rowidtab is table of VARCHAR2(38);
/

grant execute on exfsys.rlm$rowidtab to public;

---- RLM$EVENTIDS : Defined as a synonym for RLM$ROWIDTAB, used to pass
---- list of event identifiers to CONSUME_EVENTS API. 
create or replace public synonym rlm$eventids for exfsys.rlm$rowidtab; 

/***************************************************************************/
/***     Private Object Types  (Used in the generated packages)          ***/
/***************************************************************************/

create or replace type exfsys.rlm$equalattr as VARRAY(32) of VARCHAR2(32);
/

grant execute on rlm$equalattr to public;


create or replace type exfsys.rlm$keyval is table of VARCHAR2(1000);
/

grant execute on exfsys.rlm$keyval to public;


create or replace type exfsys.rlm$dateval is table of timestamp;
/

grant execute on exfsys.rlm$dateval to public;


create or replace type exfsys.rlm$numval is table of number;
/

grant execute on exfsys.rlm$numval to public;

/***************************************************************************/
/*** RLM$TABLE_ALIAS : Used to create event structures with table aliases **/
/***************************************************************************/
create or replace public synonym rlm$table_alias for exfsys.exf$table_alias;


