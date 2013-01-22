-------------------------------------------------------------------------------
--
-- $Header: dmsyssch.sql 07-apr-2005.16:50:38 gtang Exp $
--
--  Copyright (c) 2001, 2003, Oracle. All rights reserved.
--
--    NAME
--    dmsyssch.sql
--
--    DESCRIPTION
--    ODM Schema Definitions
--
--    NOTES
--
--       MODIFIED MM/DD/YY
--       gtang    04/07/05 - Fix bug #4260574 by adding a new constraint on 
--                           DM$P_MODEL_TABLES 
--       pstengar 03/14/05 - bug 4238290: fixed current user identification 
--       mmcracke 12/15/04 - Add public synonyms for types. 
--       mmcracke 11/15/04 - Remove uneeded DMSYS types 
--       mmcracke 11/05/04 - Add ora_mining_varchar2_nt type. 
--       gtang    10/26/04 - ADD Cluster_Rule_Tab_type 
--       fcay     09/27/04 - Add with grant option 
--       amozes   07/08/04 - remove/obsolete dm_target_values
--       xbarr    06/25/04 - xbarr_dm_rdbms_migration
--       mmcracke 06/21/04 - Remove dmsys objects. 
--       xbarr    06/01/04 - comment out certain TYPEs & grants 
--       mmcracke 05/20/04 - Remove Java ODM references
--       gtang    04/15/04 - Add cluster_tab_type
--       mmcracke 12/01/03 - Include INPUT_PDS_ID in DM_RESULT view
--       mmcracke 11/18/03 - Address bug 3215155.  Fix model reference in dm$result
--       jyarmus  10/26/03 - add weight of evidence record
--       hyoon    10/23/03 - to add MDL for AI
--       mmcracke 10/01/03 - Add NMF apply result record
--       mmcracke 07/14/03 - Index table dm$task_arguments
--       fcay     06/23/03 - Update copyright notice
--       mmcracke 05/09/03 - Replace c_approximation with c_regression
--       mmcracke 04/23/03 - 
--       mmcracke 04/04/03 - Fix rule table enum
--       mmcracke 04/03/03 - Remove ABN table types (nodeTable,valueTable,ruleTable)
--       mmcracke 04/03/03 - Add textMining table type
--       mmcracke 03/21/03 - Remove OWNER from dm_result views
--       ddadashe 03/13/03 - remove schema_name from dm_model_tables_2d
--       xbarr    03/08/03 - remove dm$message_log, dm$error_table tables/views/synonyms
--       kakchan  03/03/03 - add type for regression record apply
--       pkuntala 02/21/03 - removing nmftaxonomy and nmfattrmap tables
--       pkuntala 02/19/03 - removing nmf basis and euclidean tables
--       mmcracke 02/14/03 - Add types for AR build
--       kakchan  01/23/03 - renamed SVM table type name
--       jyarmus  02/13/03 - add record apply types for new rule paradigm
--       mmcracke 01/20/03 - Add large VARRAY for > 5000 attributes
--       mmcracke 01/18/03 - Alter DM_CATEGORY_MATRIX_ENTRY view to recognize 'char'
--       cbhagwat 01/17/03 - Moving dbms_dm types to dmpsyssch
--       pkuntala 01/16/03 - adding nmfAttrMappedTable
--       mmcracke 01/07/03 - Add new table types for SVM
--       ramkrish 01/10/03 - Add DM_Rules type
--       mmcracke 12/31/02 - Add model_id to dm$result
--       xbarr    12/10/02 - Remove DROP statements 
--       mmcracke 12/09/02 - Fix bug 2679294
--       mmcracke 11/15/02 - Change category names & values to VARCHAR2(4000)
--       xbarr    11/12/02 - Fix dm_attribute_property view
--       mmcracke 11/12/02 - Fix problem with dm_attribute_property view
--       mmcracke 11/08/02 - Fix bug 2515208
--       mmcracke 10/29/02 - Add input_pds_id to dm$model
--       cbhagwat 10/15/02 - unstructured data type
--       mmcracke 10/15/02 - Fix bug 2446532
--       mmcracke 10/08/02 - Remove view references to sys.obj$
--       dwong    10/09/02 - add NUM_LIST_TYPE and STRVAL_LIST_TYPE
--                         - for ABN detail rule
--       mmcracke 10/08/02 - Change model_tables view for new nmf tables
--       cbhagwat 10/08/02 - Adding property name dm_attribute_property view
--       mmcracke 10/04/02 - Changes to dm$logical_data for data prep
--                         - enhancements
--       mmcracke 10/02/02 - Add new nmf model tables to dm_model_tables view
--       mmcracke 10/02/02 - Fix dm_location_access_data view
--       mmcracke 09/30/02 - Add new  function/algorithm
--       mmcracke 09/23/02 - Fix dm$v$object view (add logicalData back in)
--       xbarr    09/18/02 - add view for error tbs bug[2562249]
--       mmcracke 09/12/02 - Fix dm$v$object view.  Bug 2520186
--       xbarr    09/12/02 - add unique_id sequence
--       jyarmus  09/12/02 - modify cost and priors settings names
--       jyarmus  09/11/02 - change regression to approximation in
--                         - settings_map table
--       mmcracke 09/11/02 - Add new svm table types to views
--       cbhagwat 09/03/02 - Adding internal modelseeker task
--       hyoon    09/11/02 - to revers changes for JDM
--       hyoon    09/06/02 - JDM RI
--       kakchan  08/29/02 - Replaced c_regression with c_approximation
--       pstengar 08/28/02 - Changed dm$task INSTANCE column to be of type
--                         - VARCHAR2 instead of NUMBER
--       pstengar 08/23/02 - Added public synonym for DM$PMML_DTD table
--       mmcracke 08/07/02 - Change names in dm$ms_result_entry to varchar2(64)
--       mmcracke 08/05/02 - Change metadata for new Category design
--       mmcracke 08/01/02 - Fix comboAdaptiveBayesNetwork enum
--       mmcracke 07/30/02 - Change dm$execution_handle to unnamed object
--       dmukhin  07/29/02 - add types for apply_record
--       mmcracke 07/29/02 - Change function to fs_obj_id in
--                         - dm$ms_result_entry table
--       mmcracke 07/28/02 - Change model_seeker_result view
--       mmcracke 07/24/02 - Add deleted flag to dm$model_tables
--       mmcracke 07/22/02 - Add comments to schema fix dm$v$physical_data view
--       xbarr    07/16/02 - add DM_CATALOG_ROLE
--       mmcracke 07/15/02 - Fix dm_result view
--       mmcracke 07/10/02 - Change dm$result, rework input_obj_id..
--       kakchan  07/10/02 - Fixed dm_category_matrix view to handle
--                         - non-string data type category.
--       mmcracke 07/03/02 - model seeker changes..
--       mmcracke 06/28/02 - Create DM_LOCATION_ACCESS_DATA view.
--       mmcracke 06/28/02 - Changes to DM$MODEL_SEEKER_RESULT.
--       mmcracke 06/27/02 - Add start and end time to dm_model view.
--       mmcracke 06/27/02 - add ms_result_entry view.
--       mmcracke 06/26/02 - change create synonym statements.
--       mmcracke 06/25/02 - Add views for dm$apply_output.
--       mmcracke 06/24/02 - Add apply_output views.
--       mmcracke 06/21/02 - Change to dm$apply_output table.
--       mmcracke 06/18/02 - Grant select on result views..
--       mmcracke 06/17/02 - Remove dm$nested_settings table..
--       mmcracke 06/17/02 - Grant execute on dm$category_id_seq to public..
--       mmcracke 06/17/02 - Add view for dm$message_log.
--       mmcracke 06/17/02 - Add 2D dm_model_tables_2d view.
--       mmcracke 06/14/02 - Move package synonyms to dmproc.sql.
--       mmcracke 06/14/02 - Fix model table enum..
--       mmcracke 06/14/02 - Fix dm_category_matrix view..
--       mmcracke 06/13/02 - Add owner field to dm$message_log.
--       mmcracke 06/13/02 - Change object types to authid current_user.
--       mmcracke 06/12/02 - Add synonyms for packages.
--       mmcracke 06/12/02 - Fix dm_model view.
--       mmcracke 06/11/02 - Include funtion and algorithm in dm$v$model view.
--       mmcracke 06/07/02 - Modify dm_location_cell_access_data view.
--       mmcracke 06/06/02 - Add crossValidate type to task enum.
--       mmcracke 06/04/02 - Create views for location_access_data and
--                         - location_cell_access_data.
--       mmcracke 06/04/02 - .
--       mmcracke 06/04/02 - Mods to support Mining Apply Output.
--       mmcracke 05/31/02 - Rework dm$location_cell_access_data.  Add api.
--       mmcracke 05/31/02 - Add view for model_tables.
--       mmcracke 05/29/02 - Add MFS to potential MAS owner in view
--                         - definitions.
--       mmcracke 05/28/02 - Minor view changes.
--       mmcracke 05/23/02 - Add MAS field to DM$MS_RESULT_ENTRY.
--       mmcracke 05/17/02 - Cleanup.
--       mmcracke 05/16/02 - Rework views.
--       mmcracke 05/15/02 - New view definitions.
--       mmcracke 04/09/02 - 10.1 Changes.
--       ddadashe 02/18/02 - 
--       ramkrish 02/01/02 - rollback DerivedField out of BayesInput for 9iR2
--       pstengar 01/28/02 - Modified ODM_MINING_TASK table, changed
--                         - SESSION_ID to INSTANCE..
--       xbarr    01/14/02 - add PMML table ODM_PMML_DTD 
--       ramkrish 01/11/02 - add types for dmnbb:gen_pmml 
--       xbarr    09/01/01 - Creation
--
--
-- Package Synonyms moved to dmproc.sql

CREATE TABLE dm$p_model(
  mod#             NUMBER NOT NULL,
  owner#           NUMBER NOT NULL,
  name             VARCHAR2(25) NOT NULL,
  function_name    VARCHAR2(30),
  algorithm_name   VARCHAR2(30),
  ctime            DATE,
  build_duration   NUMBER,
  target_attribute VARCHAR2(30),
  model_size       NUMBER,
  CONSTRAINT dm$p_model_unique UNIQUE (name, owner#))
/

CREATE TABLE dm$p_model_tables(
  mod#       NUMBER NOT NULL,
  table_type VARCHAR2(30) NOT NULL,
  table_name VARCHAR2(30),
  CONSTRAINT dm$p_modtab_unique UNIQUE (mod#, table_type))
/

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

-------------------------------------------------------------------------------
-- SEQUENCES 
-------------------------------------------------------------------------------

-- sequence used by export/import jobs
CREATE SEQUENCE DM$EXPIMP_ID_SEQ
/

-------------------------------------------------------------------------------
-- TYPES
-------------------------------------------------------------------------------
CREATE TYPE ora_mining_number_nt AS TABLE OF NUMBER
/
CREATE TYPE ora_mining_varchar2_nt AS TABLE OF VARCHAR2(4000)
/
--
-- TYPES required for CL rules persistence
--
CREATE TYPE category_type AUTHID CURRENT_USER AS OBJECT
  (value                 NUMBER(5)
  )
/
CREATE TYPE category_tab_type AS TABLE OF dmsys.category_type
/
CREATE TYPE predicate_type AUTHID CURRENT_USER AS OBJECT
  (attribute_name        VARCHAR2(30)
  ,attribute_id          NUMBER(6)
  ,comparison_function   NUMBER(2)
  ,value                 dmsys.category_tab_type
  )
/
CREATE TYPE predicate_tab_type AS TABLE OF dmsys.predicate_type
/
CREATE TYPE cl_predicate_type AUTHID CURRENT_USER AS OBJECT
  (comparison_function   NUMBER(2)
  ,value                 dmsys.category_tab_type
  )
/
CREATE TYPE cl_predicate_tab_type AS TABLE OF dmsys.cl_predicate_type
/
CREATE TYPE cluster_rule_element_type AUTHID CURRENT_USER AS OBJECT
  (attribute_name        VARCHAR2(30)
  ,attribute_id          NUMBER(6)
  ,attribute_relevance   NUMBER
  ,record_count          NUMBER(10)
  ,entries               dmsys.cl_predicate_tab_type
  )
/
CREATE TYPE cluster_rule_element_tab_type AS TABLE OF dmsys.cluster_rule_element_type
/
CREATE TYPE centroid_entry_type AUTHID CURRENT_USER AS OBJECT
  (attribute_name        VARCHAR2(30)
  ,attribute_id          NUMBER(6)
  ,value                 NUMBER(5)
  )
/
CREATE TYPE centroid_tab_type AS TABLE OF dmsys.centroid_entry_type
/
CREATE TYPE histogram_entry_type AUTHID CURRENT_USER AS OBJECT
  (count                 NUMBER
  ,value                 NUMBER(5)
  )
/
CREATE TYPE histogram_entry_tab_type AS TABLE OF dmsys.histogram_entry_type
/
CREATE TYPE attribute_histogram_type AUTHID CURRENT_USER AS OBJECT
  (attribute_name        VARCHAR2(32)
  ,attribute_id          NUMBER(6)
  ,entries               dmsys.histogram_entry_tab_type
  )
/
CREATE TYPE attribute_histogram_tab_type AS TABLE OF dmsys.attribute_histogram_type
/
CREATE TYPE child_type AUTHID CURRENT_USER AS OBJECT
  (id                    NUMBER(7)
  )
/
CREATE TYPE child_tab_type AS TABLE OF dmsys.child_type
/
CREATE TYPE cluster_type AUTHID CURRENT_USER AS OBJECT
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
CREATE TYPE cluster_tab_type AS TABLE OF dmsys.cluster_type
/
CREATE TYPE Cluster_rule_type AUTHID CURRENT_USER AS OBJECT
  (cluster_id            NUMBER(7)
  ,record_count          NUMBER(10)
  ,antecedent            dmsys.cluster_rule_element_tab_type
  )
/
CREATE TYPE Cluster_rule_tab_type IS TABLE OF Cluster_rule_type 
/
--CREATE TYPE integer_tab_type IS TABLE OF NUMBER(10)
--/
--CREATE TYPE number_tab_type IS TABLE OF NUMBER
--/
--CREATE TYPE range_array_type IS VARRAY(2) OF NUMBER(5)
--/
--CREATE TYPE range_tab_type IS TABLE OF dmsys.range_array_type
--/
--CREATE TYPE histogram_tab_type IS TABLE OF dmsys.ora_mining_number_nt
--/
--CREATE TYPE cluster_node_type AUTHID CURRENT_USER AS OBJECT
--  (parent                NUMBER(7)
--  ,children              dmsys.ora_mining_number_nt
--  ,tree_level            NUMBER(7)
--  ,points                dmsys.ora_mining_number_nt
--  ,splitter              NUMBER(6)
--  )
--/
--CREATE TYPE cell_type AUTHID CURRENT_USER AS OBJECT
--  (count                 NUMBER(10)
--  ,ranges                dmsys.range_tab_type
--  ,histograms            dmsys.histogram_tab_type
--  )
--/
--CREATE TYPE cluster_internal_type AUTHID CURRENT_USER AS OBJECT
--  (number_points         NUMBER(10)
--  ,centroid              dmsys.number_tab_type
--  ,histograms            dmsys.histogram_tab_type
--  ,dispersion            NUMBER
--  )
--/

--
--
--
--CREATE OR REPLACE TYPE model_tables_record AS OBJECT
--  (table_name VARCHAR2(30)
--  ,table_type VARCHAR2(30));
--/
--CREATE OR REPLACE TYPE model_tables_list AS TABLE OF model_tables_record;
--/
--
--CREATE OR REPLACE TYPE setting_type as OBJECT
--  (setting_id    NUMBER
--  ,setting_value VARCHAR2(128));
--/
--CREATE OR REPLACE TYPE settings_list as TABLE of setting_type;
--/
--
CREATE OR REPLACE TYPE DM_Model_Signature_Attribute AS OBJECT
  (attribute_name VARCHAR2(30)
  ,attribute_type VARCHAR2(106));
/
CREATE OR REPLACE TYPE DM_Model_Signature
AS TABLE OF DM_Model_Signature_Attribute;
/

CREATE OR REPLACE TYPE DM_Model_Setting AS OBJECT
  (setting_name  VARCHAR2(30)
  ,setting_value VARCHAR2(128))
/
CREATE OR REPLACE TYPE DM_Model_Settings AS TABLE OF DM_Model_Setting
/

CREATE TYPE DM_Predicate AUTHID CURRENT_USER AS OBJECT
  (attribute_name       VARCHAR2(30)
  ,conditional_operator CHAR(2) /* =, <>, <, >, <=, >= */
  ,attribute_num_value  NUMBER
  ,attribute_str_value  VARCHAR2(4000)
  ,attribute_support    NUMBER
  ,attribute_confidence NUMBER)
/
CREATE OR REPLACE TYPE DM_Predicates AS TABLE OF DM_Predicate;
/

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

CREATE OR REPLACE TYPE DM_Items AS TABLE OF VARCHAR2(4000);
/
CREATE OR REPLACE TYPE DM_ItemSet AS OBJECT
  (itemset_id      INTEGER
  ,items           DM_Items
  ,support         NUMBER
  ,number_of_items NUMBER);
/
CREATE OR REPLACE TYPE DM_ItemSets AS TABLE OF DM_ItemSet;
/

CREATE OR REPLACE TYPE DM_Centroid AS OBJECT
  (attribute_name VARCHAR2(30)
  ,mean           NUMBER
  ,mode_value     VARCHAR2(4000)
  ,variance       NUMBER
  )
/
CREATE OR REPLACE TYPE DM_Centroids AS TABLE OF DM_Centroid
/
CREATE OR REPLACE TYPE DM_Histogram_bin AS OBJECT
  (attribute_name VARCHAR2(30)
  ,bin_id         NUMBER
  ,lower_bound    NUMBER
  ,upper_bound    NUMBER
  ,label          VARCHAR2(4000)
  ,count          NUMBER
  )
/
CREATE OR REPLACE TYPE DM_Histograms AS TABLE OF DM_histogram_bin
/
CREATE OR REPLACE TYPE DM_Child AS OBJECT
  (id NUMBER
  )
/
CREATE OR REPLACE TYPE DM_Children AS TABLE OF DM_Child
/    
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
CREATE OR REPLACE TYPE DM_Clusters AS TABLE OF DM_Cluster
/

CREATE OR REPLACE TYPE DM_Conditional AS OBJECT
  (attribute_name          VARCHAR2(30)
  ,attribute_str_value     VARCHAR2(4000)
  ,attribute_num_value     NUMBER
  ,conditional_probability NUMBER)
/    
CREATE OR REPLACE TYPE DM_Conditionals AS TABLE OF DM_Conditional
/
CREATE OR REPLACE TYPE DM_NB_Detail AS OBJECT
  (target_attribute_name      VARCHAR2(30)
  ,target_attribute_str_value VARCHAR2(4000)
  ,target_attribute_num_value NUMBER
  ,prior_probability          NUMBER
  ,conditionals               DM_Conditionals)
/  
CREATE OR REPLACE TYPE DM_NB_Details AS TABLE OF DM_NB_Detail 
/

CREATE OR REPLACE TYPE DM_ABN_Detail AS OBJECT
  (rule_id      INTEGER
  ,antecedent   DM_Predicates
  ,consequent   DM_Predicates
  ,rule_support NUMBER)
/  
CREATE OR REPLACE TYPE DM_ABN_Details AS TABLE OF DM_ABN_Detail 
/

CREATE TYPE DM_NMF_Attribute AS OBJECT
  (attribute_name  VARCHAR2(30)
  ,attribute_value VARCHAR2(4000)
  ,coefficient     NUMBER)
/
CREATE TYPE DM_NMF_Attribute_Set AS TABLE OF DM_NMF_Attribute
/
CREATE TYPE DM_NMF_Feature AS OBJECT
  (feature_id    NUMBER
  ,attribute_set DM_NMF_Attribute_Set)
/
CREATE TYPE DM_NMF_Feature_Set AS TABLE OF DM_NMF_Feature
/
  
CREATE TYPE DM_SVM_Attribute AS OBJECT
  (attribute_name  VARCHAR2(30)
  ,attribute_value VARCHAR2(4000)
  ,coefficient     NUMBER)
/
CREATE TYPE DM_SVM_Attribute_Set AS TABLE OF DM_SVM_Attribute
/
CREATE TYPE DM_SVM_Linear_Coeff AS OBJECT
  (class         VARCHAR2(4000)
  ,attribute_set DM_SVM_Attribute_Set)
/
CREATE TYPE DM_SVM_Linear_Coeff_Set AS TABLE OF DM_SVM_Linear_Coeff
/

CREATE OR REPLACE TYPE DM_Nested_Numerical AS OBJECT
  (attribute_name VARCHAR2(30)
  ,value          NUMBER)
/
CREATE OR REPLACE TYPE DM_Nested_Numericals AS TABLE OF DM_Nested_Numerical
/
CREATE OR REPLACE TYPE DM_Nested_Categorical AS OBJECT
  (attribute_name VARCHAR2(30)
  ,value          VARCHAR2(4000))
/
CREATE OR REPLACE TYPE DM_Nested_Categoricals AS TABLE OF DM_Nested_Categorical
/

CREATE OR REPLACE TYPE dm_ranked_attribute AS OBJECT
  (attribute_name    VARCHAR2(30),
   importance_value  NUMBER,
   rank              NUMBER(38))
/
CREATE OR REPLACE TYPE dm_ranked_attributes AS TABLE OF dm_ranked_attribute
/    
-------------------------------------------------------------------------------
-- SYNONYMS
-------------------------------------------------------------------------------

-- VIEW SYNONYMS

CREATE OR REPLACE PUBLIC SYNONYM dm_user_models FOR dmsys.dm_user_models
/

-- TYPE SYNONYMS

CREATE OR REPLACE PUBLIC SYNONYM DM_Model_Signature_Attribute
FOR dmsys.DM_Model_Signature_Attribute
/
CREATE OR REPLACE PUBLIC SYNONYM DM_Model_Signature
FOR dmsys.DM_Model_Signature
/
CREATE OR REPLACE PUBLIC SYNONYM DM_Model_Setting
FOR dmsys.DM_Model_Setting
/
CREATE OR REPLACE PUBLIC SYNONYM DM_Model_Settings
FOR dmsys.DM_Model_Settings
/
CREATE OR REPLACE PUBLIC SYNONYM DM_Predicate
FOR dmsys.DM_Predicate
/
CREATE OR REPLACE PUBLIC SYNONYM DM_Predicates
FOR dmsys.DM_Predicates
/
CREATE OR REPLACE PUBLIC SYNONYM DM_Rule
FOR dmsys.DM_Rule
/
CREATE OR REPLACE PUBLIC SYNONYM DM_Rules
FOR dmsys.DM_Rules
/
CREATE OR REPLACE PUBLIC SYNONYM DM_Centroid
FOR dmsys.DM_Centroid
/
CREATE OR REPLACE PUBLIC SYNONYM DM_Centroids
FOR dmsys.DM_Centroids
/
CREATE OR REPLACE PUBLIC SYNONYM DM_Histogram_bin
FOR dmsys.DM_Histogram_bin
/
CREATE OR REPLACE PUBLIC SYNONYM DM_Histograms
FOR dmsys.DM_Histograms
  /
CREATE OR REPLACE PUBLIC SYNONYM DM_Child
FOR dmsys.DM_Child
/
CREATE OR REPLACE PUBLIC SYNONYM DM_Children
FOR dmsys.DM_Children
/
CREATE OR REPLACE PUBLIC SYNONYM DM_Cluster
FOR dmsys.DM_Cluster
/
CREATE OR REPLACE PUBLIC SYNONYM DM_Clusters
FOR dmsys.DM_Clusters
/
CREATE OR REPLACE PUBLIC SYNONYM DM_Conditional
FOR dmsys.DM_Conditional
/
CREATE OR REPLACE PUBLIC SYNONYM DM_Conditionals
FOR dmsys.DM_Conditionals
/
CREATE OR REPLACE PUBLIC SYNONYM DM_NB_Detail
FOR dmsys.DM_NB_Detail
/
CREATE OR REPLACE PUBLIC SYNONYM DM_NB_Details
FOR dmsys.DM_NB_Details
/
CREATE OR REPLACE PUBLIC SYNONYM DM_ABN_Detail
FOR dmsys.DM_ABN_Detail
/
CREATE OR REPLACE PUBLIC SYNONYM DM_ABN_Details
FOR dmsys.DM_ABN_Details
/
CREATE OR REPLACE PUBLIC SYNONYM DM_NMF_Attribute
FOR dmsys.DM_NMF_Attribute
/
CREATE OR REPLACE PUBLIC SYNONYM DM_NMF_Attribute_Set
FOR dmsys.DM_NMF_Attribute_Set
/
CREATE OR REPLACE PUBLIC SYNONYM DM_NMF_Feature
FOR dmsys.DM_NMF_Feature
/
CREATE OR REPLACE PUBLIC SYNONYM DM_NMF_Feature_Set
FOR dmsys.DM_NMF_Feature_Set
/
CREATE OR REPLACE PUBLIC SYNONYM DM_SVM_Attribute
FOR dmsys.DM_SVM_Attribute
/
CREATE OR REPLACE PUBLIC SYNONYM DM_SVM_Attribute_Set
FOR dmsys.DM_SVM_Attribute_Set
/
CREATE OR REPLACE PUBLIC SYNONYM DM_SVM_Linear_Coeff
FOR dmsys.DM_SVM_Linear_Coeff
/
CREATE OR REPLACE PUBLIC SYNONYM DM_SVM_Linear_Coeff_Set
FOR dmsys.DM_SVM_Linear_Coeff_Set
/
CREATE OR REPLACE PUBLIC SYNONYM DM_Nested_Numerical
FOR dmsys.DM_Nested_Numerical
/
CREATE OR REPLACE PUBLIC SYNONYM DM_Nested_Numericals
FOR dmsys.DM_Nested_Numericals
/
CREATE OR REPLACE PUBLIC SYNONYM DM_Nested_Categorical
FOR dmsys.DM_Nested_Categorical
/
CREATE OR REPLACE PUBLIC SYNONYM DM_Nested_Categoricals
FOR dmsys.DM_Nested_Categoricals
/
CREATE OR REPLACE PUBLIC SYNONYM DM_Items
FOR dmsys.DM_Items
/
CREATE OR REPLACE PUBLIC SYNONYM DM_ItemSet
FOR dmsys.DM_ItemSet
/
CREATE OR REPLACE PUBLIC SYNONYM DM_ItemSets
FOR dmsys.DM_ItemSets
/
CREATE OR REPLACE PUBLIC SYNONYM dm_ranked_attribute
FOR dmsys.dm_ranked_attribute  
/
CREATE OR REPLACE PUBLIC SYNONYM dm_ranked_attributes
FOR dmsys.dm_ranked_attributes
/
CREATE OR REPLACE PUBLIC SYNONYM ORA_MINING_NUMBER_NT
FOR DMSYS.ORA_MINING_NUMBER_NT
/
CREATE OR REPLACE PUBLIC SYNONYM ORA_MINING_VARCHAR2_NT
FOR DMSYS.ORA_MINING_VARCHAR2_NT
/
CREATE OR REPLACE PUBLIC SYNONYM CLUSTER_RULE_TYPE
FOR DMSYS.CLUSTER_RULE_TYPE
/
CREATE OR REPLACE PUBLIC SYNONYM CLUSTER_TYPE
FOR DMSYS.CLUSTER_TYPE
/

---------------------------------------------------------------------
-- GRANTS
---------------------------------------------------------------------

-- VIEW GRANTS

GRANT SELECT ON dm_user_models TO PUBLIC WITH GRANT OPTION
/

-- SEQUENCE GRANTS

GRANT SELECT ON DM$EXPIMP_ID_SEQ TO PUBLIC WITH GRANT OPTION
/

-- TYPE GRANTS
GRANT EXECUTE ON ora_mining_number_nt TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON ora_mining_varchar2_nt TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON category_type TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON category_tab_type TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON predicate_type TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON predicate_tab_type TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON cl_predicate_type TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON cl_predicate_tab_type TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON cluster_rule_element_type TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON cluster_rule_element_tab_type TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON centroid_entry_type TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON centroid_tab_type TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON histogram_entry_type TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON histogram_entry_tab_type TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON attribute_histogram_type TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON attribute_histogram_tab_type TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON child_type TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON child_tab_type TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON cluster_type TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON cluster_tab_type TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON Cluster_rule_type TO PUBLIC WITH GRANT OPTION
/
--
--
--
--GRANT EXECUTE ON model_tables_record TO PUBLIC WITH GRANT OPTION
--/
--GRANT EXECUTE ON model_tables_list TO PUBLIC WITH GRANT OPTION
--/
GRANT EXECUTE ON dm_model_signature_attribute TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON dm_model_signature TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON dm_model_setting TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON dm_model_settings TO PUBLIC WITH GRANT OPTION
/
--GRANT EXECUTE ON setting_type to PUBLIC WITH GRANT OPTION
--/
--GRANT EXECUTE ON settings_list to PUBLIC WITH GRANT OPTION
--/
GRANT EXECUTE ON dm_predicate TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON dm_predicates TO PUBLIC WITH GRANT OPTION  
/
GRANT EXECUTE ON dm_rule TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON dm_rules TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON dm_centroid TO PUBLIC WITH GRANT OPTION
/  
GRANT EXECUTE ON dm_centroids TO PUBLIC WITH GRANT OPTION 
/
GRANT EXECUTE ON dm_histogram_bin TO PUBLIC WITH GRANT OPTION
/  
GRANT EXECUTE ON dm_histograms TO PUBLIC WITH GRANT OPTION 
/
GRANT EXECUTE ON dm_child TO PUBLIC WITH GRANT OPTION 
/
GRANT EXECUTE ON dm_children TO PUBLIC WITH GRANT OPTION 
/
GRANT EXECUTE ON dm_cluster TO PUBLIC WITH GRANT OPTION   
/
GRANT EXECUTE ON dm_clusters TO PUBLIC WITH GRANT OPTION 
/
GRANT EXECUTE ON dm_conditional TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON dm_conditionals TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON dm_nb_detail TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON dm_nb_details TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON dm_abn_detail TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON dm_abn_details TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON dm_nmf_attribute TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON dm_nmf_attribute_set TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON dm_nmf_feature TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON dm_nmf_feature_set TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON dm_svm_attribute TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON dm_svm_attribute_set TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON dm_svm_linear_coeff TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON dm_svm_linear_coeff_set TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON dm_nested_numerical TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON dm_nested_numericals TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON dm_nested_categorical TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON dm_nested_categoricals TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON dm_items TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON dm_itemset TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON dm_itemsets TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON dm_ranked_attribute TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON dm_ranked_attributes TO PUBLIC WITH GRANT OPTION
/



