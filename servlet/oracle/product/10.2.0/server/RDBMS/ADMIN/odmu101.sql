Rem ##########################################################################
Rem 
Rem Copyright (c) 2004, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      odmu101.sql
Rem
Rem    DESCRIPTION
Rem      Run all sql scripts for Data Mining 10gR2 upgrade 
Rem
Rem    RETURNS
Rem 
Rem    NOTES
Rem      This script must be run while connected as SYS   
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem       xbarr    04/13/05 - bug#4260574 
Rem       xbarr    03/16/05 - bug#4238290
Rem       xbarr    03/14.05 - fix lrg_1836016
Rem       xbarr    01/09/05 - fix lrg_1816016 
Rem       xbarr    12/09/04 - fix Cluster TYPEs 
Rem       xbarr    12/01/04 - fix bug-4037586
Rem       xbarr    11/03/04 - add type for OCluster
Rem       xbarr    10/29/04 - fix bug-3936558, move validation proc to SYS 
Rem       xbarr    09/13/04 - fix bug-3878879 
Rem       pstengar 08/24/04 - add prvtdmpa.plb 
Rem       xbarr    08/03/04 - update dm 10.2 packages 
Rem       amozes   06/23/04 - remove hard tabs
Rem       xbarr    05/13/04 - xbarr_txn111447
Rem
Rem    xbarr    05/11/04 - Creation
Rem
Rem #########################################################################


ALTER SESSION SET CURRENT_SCHEMA = "SYS";

WHENEVER SQLERROR EXIT;
EXECUTE dbms_registry.check_server_instance;
WHENEVER SQLERROR CONTINUE;


ALTER SESSION SET CURRENT_SCHEMA = "DMSYS";

drop type cluster_type force
/

CREATE or replace TYPE cluster_type AUTHID CURRENT_USER AS OBJECT
  (id                    NUMBER(7)
  ,record_count          NUMBER(10)
  ,tree_level            NUMBER(7)
  ,parent                NUMBER(7)
  ,split_predicate       dmsys.predicate_tab_type
  ,centroid              dmsys.centroid_tab_type
  ,histogram             dmsys.attribute_histogram_tab_type
  ,child                 dmsys.child_tab_type
  )
/

alter type cluster_type compile;
/
grant EXECUTE ON cluster_type TO PUBLIC with grant option;
/
CREATE or replace TYPE cluster_tab_type AS TABLE OF cluster_type
/

alter type cluster_tab_type compile;
/

GRANT EXECUTE ON cluster_tab_type TO PUBLIC with grant option;
/

CREATE or replace TYPE Cluster_rule_tab_type IS TABLE OF Cluster_rule_type
/

alter type Cluster_rule_tab_type compile;
/
GRANT EXECUTE ON Cluster_rule_tab_type TO PUBLIC with grant option;
/

drop type DM_Cluster force;

CREATE OR REPLACE TYPE DM_Cluster AS OBJECT
  (id               NUMBER
  ,record_count     NUMBER
  ,parent           NUMBER
  ,tree_level       NUMBER
  ,dispersion       NUMBER
  ,split_predicate  DM_Predicates
  ,child            DM_Children
  ,centroid         DM_Centroids
  ,histogram        DM_Histograms
  ,rule             DM_rule
  )
/

alter type DM_Cluster compile;
/
GRANT EXECUTE ON DM_Cluster TO PUBLIC with grant option;
/
CREATE OR REPLACE TYPE DM_Clusters AS TABLE OF DM_Cluster
/

drop type DM_Rule force;

CREATE OR REPLACE TYPE DM_Rule AS OBJECT
  (rule_id            INTEGER
  ,antecedent         DM_Predicates
  ,consequent         DM_Predicates
  ,rule_support       NUMBER
  ,rule_confidence    NUMBER
  ,antecedent_support NUMBER
  ,consequent_support NUMBER
  ,number_of_items    INTEGER);
/
CREATE OR REPLACE TYPE DM_Rules AS TABLE OF DM_Rule;
/

alter type DM_Rule compile;
alter type DM_Rules compile;

grant execute on DM_Rule to public with grant option;
/
grant execute on DM_Rules to public with grant option;
/

alter package DBMS_DATA_MINING compile;
alter package DBMS_DATA_MINING compile body;


Rem  Remove DMSYS validation procedure
drop procedure dmsys.validate_odm;

Rem Load DMSYS package/procedure objects
@@dmproc.sql

Rem Load Trusted Code BLAST
@@dbmsdmbl.sql

Rem   Prediction package
@@dbmsdmpa.sql
@@prvtdmpa.plb

Rem   JDM packages  
@@prvtdmj.plb


Rem   Remove 10.1 DMSYS Java objects

ALTER SESSION SET CURRENT_SCHEMA = "DMSYS";

set serveroutput on;

DECLARE
  dropall_cmd VARCHAR2(1000);
begin
  for drop_rec in
    (select dbms_java.longname(object_name) jname
      from dba_objects
      where owner = 'DMSYS')
  loop
     execute immediate
    'DROP JAVA CLASS "DMSYS' || '"."' || drop_rec.jname ||'"';
  end loop;
  commit;
  exception when others then
  null;
  end;
/

Rem  Remove KM package (no longer required in 10.2)
 
drop package dmsys.odm_km_clustering_model;

Rem  Remove NMF package (no longer required in 10.2)

drop package dmsys.dm_nmf_model;

Rem  Remove packages which are no longer existed in 10.2

drop package dmsys.odm_association_rule_model92;
drop package dmsys.odm_mining_transformation;
drop package dmsys.odm_naive_bayes_apply;

Rem Update user view (Bug#4238290)

CREATE OR REPLACE VIEW dm_user_models AS
(SELECT name,
        function_name,
        algorithm_name,
        ctime creation_date,
        build_duration,
        target_attribute,
        model_size
   FROM dm$p_model
  WHERE owner# = SYS_CONTEXT('USERENV','CURRENT_USERID'))
/

Rem  Clean up duplicates if existed in dm$p_model_tables

delete from dm$p_model_tables t1
        where (t1.mod#, t1.table_type) in (select mod#,table_type
                                   from   dm$p_model_tables t2
                                   where  t1.rowid > t2.rowid
                                   and    t1.mod# = t2.mod#
                                   and    t1.table_type = t2.table_type
                                   );
commit;

Rem Add unique constraint on dm$p_model_tables (bug#4260574)

BEGIN
  EXECUTE IMMEDIATE
   'alter table dm$p_model_tables add CONSTRAINT dm$p_modtab_unique UNIQUE (mod#,table_type)';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE IN (-2261) THEN NULL;
      ELSE RAISE;
      END IF;
END;
/

ALTER SESSION SET CURRENT_SCHEMA = "SYS";

Rem  Create ODM validation procedure in SYS
@@odmproc.sql

Rem   PL/SQL API model upgrades (to be run as SYS only)
Rem
exec dmp_sys.upgrade_models('10.2.0');
/
commit;


ALTER SESSION SET CURRENT_SCHEMA = "SYS";

Rem   Validation of ODM upgrade

execute sys.dbms_registry.upgraded('ODM');

execute sys.dbms_utility.compile_schema('DMSYS');

execute sys.validate_odm;

commit;
