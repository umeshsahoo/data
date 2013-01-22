Rem
Rem $Header: initexf.sql 26-sep-2002.06:09:51 ayalaman Exp $
Rem
Rem initexf.sql
Rem
Rem Copyright (c) 2002, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      initexf.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ayalaman    09/26/02 - ayalaman_expression_filter_support
Rem    ayalaman    09/06/02 - 
Rem    ayalaman    09/06/02 - Created
Rem


call sys.dbms_java.loadjava(' -v -f -r -schema exfsys rdbms/jlib/ExprFilter.jar');

