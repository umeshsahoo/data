Rem
Rem $Header: catnorul.sql 16-feb-2005.09:02:16 ayalaman Exp $
Rem
Rem catnorul.sql
Rem
Rem Copyright (c) 2004, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catnorul.sql - Uninstall script for Rule Manager 
Rem
Rem    DESCRIPTION
Rem      This script un-installs the Rule Manager component 
Rem
Rem    NOTES
Rem      See Documentation
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ayalaman    02/16/05 - drop the truncate system trigger with uninstall 
Rem    ayalaman    07/16/04 - negation with delay dictionary table 
Rem    ayalaman    06/29/04 - rules with negation and deadline 
Rem    ayalaman    04/23/04 - ayalaman_rule_manager_support 
Rem    ayalaman    04/02/04 - Created
Rem


REM 
REM Drop the Rule Manager specific objects from the EXFSYS schema
REM 
EXECUTE dbms_registry.removing('RUL');

drop package exfsys.dbms_rlmgr_dr;

drop package exfsys.dbms_rlmgr_ir;

drop package exfsys.dbms_rlmgr;

drop package exfsys.dbms_rlmgr_utl;

drop package exfsys.rlm$timecentral;

drop package exfsys.dbms_rlmgr_depasexp;

drop package exfsys.dbms_rlmgr_exp;

drop package exfsys.dbms_rlm4j_dictmaint; 

drop table exfsys.rlm$dmlevttrigs;

drop table exfsys.rlm$orderclsals;

drop table exfsys.rlm4j$ruleset; 

drop table exfsys.rlm4j$evtstructs; 

drop table exfsys.rlm$schactlist;

drop table exfsys.rlm$schacterrs;

drop table exfsys.rlm$equalspec;

drop table exfsys.rlm$eventstruct;

drop table exfsys.rlm$rulesetprivs;

drop table exfsys.rlm$validprivs;

drop table exfsys.rlm$primevttypemap; 

drop table exfsys.rlm$rsprimevents;

drop table exfsys.rlm$errcode;

drop table exfsys.rlm$jobqueue;

drop table exfsys.rlm$ruleset;

drop table exfsys.rlm$rulesetstcode;

drop table exfsys.rlm$parsedcond;

drop view exfsys.user_rlm4j_evtst; 

drop view exfsys.user_rlm4j_ruleclasses; 

drop view exfsys.user_rlmgr_event_structs;

drop view exfsys.all_rlmgr_event_structs;

drop view exfsys.adm_rlmgr_event_structs;

drop view exfsys.user_rlmgr_rule_classes;

drop view exfsys.all_rlmgr_rule_classes;

drop view exfsys.adm_rlmgr_rule_classes;

drop view exfsys.user_rlmgr_privileges;

drop view exfsys.adm_rlmgr_privileges;

drop view exfsys.user_rlmgr_rule_class_status;

drop view exfsys.all_rlmgr_rule_class_status;

drop view exfsys.adm_rlmgr_rule_class_status;

drop view exfsys.all_rlmgr_rule_class_opcodes;

drop view exfsys.user_rlmgr_comprcls_properties; 

drop view exfsys.all_rlmgr_comprcls_properties; 

drop view exfsys.adm_rlmgr_comprcls_properties; 

drop view exfsys.user_rlmgr_action_errors;

drop view exfsys.all_rlmgr_action_errors;

drop view exfsys.adm_rlmgr_action_errors;

-- drop public synonyms --
drop public synonym dbms_rlmgr;

drop public synonym user_rlmgr_rule_classes;

drop public synonym all_rlmgr_rule_classes;

drop public synonym user_rlmgr_privileges;

drop public synonym rlm$eventids;

--drop public synonym all_rlmgr_privileges;

drop public synonym user_rlmgr_event_structs;

drop public synonym all_rlmgr_event_structs;

drop public synonym user_rlmgr_rule_class_status;

drop public synonym all_rlmgr_rule_class_status;

drop public synonym user_rlmgr_comprcls_properties;

drop public synonym all_rlmgr_comprcls_properties;

---drop public synonym rlm$equalattr;

drop type exfsys.rlm$keyval; 

drop type exfsys.rlm$dateval; 

drop type exfsys.rlm$rowidtab;

drop type exfsys.rlm$numval; 

drop type exfsys.rlm$equalattr;

drop function exfsys.rlm$eqlchk;

drop function exfsys.rlm$seqchk;

begin
  -- since this is a fresh install, delete any actions left behind --
  -- from past installations --
  delete from sys.expdepact$ where schema = 'EXFSYS'
     and package = 'DBMS_RLMGR_DEPASEXP';

  delete from sys.exppkgact$ where package = 'DBMS_RLMGR_DEPASEXP'
    and schema = 'EXFSYS';

end;
/

ALTER SESSION SET CURRENT_SCHEMA = EXFSYS;

exec dbms_xmlschema.deleteschema('http://xmlns.oracle.com/rlmgr/rclsprop.xsd');

exec dbms_xmlschema.deleteschema('http://xmlns.oracle.com/rlmgr/rulecond.xsd');

-- create the system trigger without rule manager maintenance --
-- drop the truncate trigger for rule class tables --
drop trigger exfsys.rlmgr_truncate_maint; 

exec exfsys.adm_expfil_systrig.create_systrig_dropobj;

ALTER SESSION SET CURRENT_SCHEMA = SYS;

EXECUTE dbms_registry.removed('RUL');
