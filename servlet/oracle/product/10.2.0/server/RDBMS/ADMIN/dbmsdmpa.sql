Rem
Rem $Header: dbmsdmpa.sql 23-aug-2004.12:14:31 pstengar Exp $
Rem
Rem dbmspa.sql
Rem 
Rem Copyright (c) 2001, 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmspa.sql - DBMS_PREDICTIVE_ANALYTICS
Rem
Rem    DESCRIPTION
Rem      The package provides routines for predictive analytics operations.
Rem
Rem    NOTES
Rem      The procedural option is needed to use this package. This package
Rem      must be created under DMSYS (connect internal). Operations provided 
Rem      by this package are performed under the current calling user, not
Rem      under the package owner DMSYS.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pstengar    08/23/04 - split package header from body 
Rem    xbarr       06/25/04 - xbarr_dm_rdbms_migration
Rem    amozes      06/23/04 - remove hard tabs
Rem    pstengar    06/10/04 - add DATE support for predict and explain
Rem    pstengar    05/17/04 - add accuracy measure to predict api
Rem    pstengar    05/11/04 - add support for float datatype
Rem    pstengar    04/05/04 - pstengar_txn111007
Rem    pstengar    03/16/04 - Creation
Rem
Rem ********************************************************************
Rem THE FUNCTIONS SUPPLIED BY THIS PACKAGE AND ITS EXTERNAL INTERFACE
Rem ARE RESERVED BY ORACLE AND ARE SUBJECT TO CHANGE IN FUTURE RELEASES.
Rem ********************************************************************
Rem
Rem ********************************************************************
Rem THIS PACKAGE MUST NOT BE MODIFIED BY THE CUSTOMER.  DOING SO COULD
Rem CAUSE INTERNAL ERRORS AND SECURITY VIOLATIONS IN THE RDBMS.
Rem ********************************************************************
Rem
Rem ********************************************************************
Rem THIS PACKAGE MUST BE CREATED UNDER DMSYS.
Rem ********************************************************************
Rem
Rem --------------------------------------------
Rem dbms_predictive_analytics PACKAGE DEFINITION
Rem --------------------------------------------
  
CREATE OR REPLACE PACKAGE dbms_predictive_analytics AUTHID CURRENT_USER AS
  --
  -- PUBLIC PROCEDURES AND FUNCTIONS
  --

  -- Procedure: PREDICT
  -- The purpose of this procedure is to produce predictions for unknown targets.
  -- The input data table should contain records where the target value is known (not null).
  -- The known cases will be used to train and test a model. Any cases where the target
  -- is unknown, i.e. where the target value is null, will not be considered during model
  -- training. Once a mining model is built internally, it will be used to score all the
  -- records from the input data (both known and unknown), and a table will be persisted
  -- containing the results. In the case of binary classification, an ROC analysis of the
  -- results will be performed, and the predictions will be adjusted to support the optimal
  -- probability threshold resulting in the highest True Positive Rate (TPR) versus False
  -- Positive Rate (FPR).
  PROCEDURE predict(
                  accuracy            OUT NUMBER,
                  data_table_name     IN VARCHAR2,
                  case_id_column_name IN VARCHAR2,
                  target_column_name  IN VARCHAR2,
                  result_table_name   IN VARCHAR2,
                  data_schema_name    IN VARCHAR2 DEFAULT NULL);

  -- Procedure: EXPLAIN
  -- This procedure is used for identifying attributes that are important/useful for
  -- explaining the variation on an attribute of interest (e.g., a measure of an OLAP
  -- fact table). Only known cases (i.e. cases where the value of the explain column is
  -- not null) will be taken into consideration when assessing the importance of the input
  -- attributes upon the dependent attribute. The resulting table will contain one row for
  -- each of the input attributes.
  PROCEDURE explain(
                  data_table_name     IN VARCHAR2,
                  explain_column_name IN VARCHAR2,
                  result_table_name   IN VARCHAR2,
                  data_schema_name    IN VARCHAR2 DEFAULT NULL);

END dbms_predictive_analytics;
/
CREATE OR REPLACE PUBLIC SYNONYM dbms_predictive_analytics
FOR dmsys.dbms_predictive_analytics
/
GRANT EXECUTE ON dbms_predictive_analytics TO PUBLIC
/
SHOW ERRORS
