Rem ##########################################################################
Rem
Rem Copyright (c) 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      odmu101s.sql
Rem
Rem    DESCRIPTION
Rem      Run all sql scripts for Data Mining 10gR2 upgrade cleanups
Rem
Rem    RETURNS
Rem
Rem    NOTES
Rem      This script should be run while connected as SYS
Rem      The script will clean up DMSYS schema for 10gR2 operation
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem       xbarr    11/04/04 - 
Rem       xbarr    09/19/04 - xbarr_bug-3878879
Rem
Rem    xbarr    09/14/04 - updated for post-upgrade DMSYS cleanup
Rem    xbarr    08/02/04 - Creation
Rem
Rem #########################################################################

Rem  Drop all 10gR1 Java objects

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


Rem  Drop 10gR1 schema objects

drop FUNCTION DM_NMF_BUILD;                                                     
drop FUNCTION DM_NMF_APPLY;                                                     
drop FUNCTION DM_SVM_BUILD;                                                     
drop FUNCTION DM_SVM_APPLY;                                                     
drop FUNCTION DM_CL_APPLY;                                                      
drop FUNCTION DM_CL_BUILD;                                                      

drop LIBRARY DMUTIL_LIB;                                                        
drop LIBRARY DMBLAST_LIB;                                                       
drop LIBRARY DMNMF_LIB;                                                         
drop LIBRARY DMNMFA_LIB;                                                        
drop LIBRARY DMSVM_LIB;                                                         
drop LIBRARY DMCL_LIB;                                                          
drop LIBRARY DMSVMA_LIB;                                                        

drop PACKAGE DM_SEC;                                                            
drop PACKAGE DM_SEC_USR;                                                        
drop PACKAGE DM_SEC_SYS;                                                        
drop PACKAGE DM_JSTP;                                                           

drop SEQUENCE DM$CATEGORY_MATRIX_SEQ;                                           
drop SEQUENCE DM$CATEGORY_SET_SEQ;                                              
drop SEQUENCE DM$CATEGORY_ID_SEQ;                                               
drop SEQUENCE DM$LOCATION_ACCESS_DATA_SEQ;                                      
drop SEQUENCE DM$OBJECT_SEQ;                                                    
drop SEQUENCE DM$SETTING_ARRAY_SEQ;                                             
drop SEQUENCE DM$UNIQUE_ID_SEQ;                                                 
drop SEQUENCE DM$PRIOR_PROBABILITY_SEQ;                                         
drop SEQUENCE DM$LOC_CELL_ACCESS_DATA_SEQ;                                      

drop TABLE DM$PHYSICAL_DATA;                                                    
drop TABLE DM$LOCATION_ACCESS_DATA;                                             
drop TABLE DM$OBJECT_STATE;                                                     
drop TABLE DM$TASK_ARGUMENTS;                                                   
drop TABLE DM$MODEL_PROPERTY_ARRAY;                                             
drop TABLE DM$ALGORITHM_SETTINGS;

drop TABLE DM$MODEL_PROPERTY;                                                   
drop TABLE DM$LIFT_RESULT_ENTRY;                                                
drop TABLE DM$PRIOR_PROBABILITY_ENTRY;                                          
drop TABLE DM$CATEGORY_MATRIX_ENTRY;                                            
drop TABLE DM$CATEGORY_SET;                                                     
drop TABLE DM$CATEGORY_EX;                                                      
drop TABLE DM$CATEGORY;                                                         
drop TABLE DM$ATTRIBUTE_PROPERTY;                                               
drop TABLE DM$SETTINGS_MAP;                                                     
drop TABLE DM$SETTING_ARRAY;                                                    
drop TABLE DM$SETTING;                                                          
drop TABLE DM$ATTRIBUTE;                                                        
drop TABLE DM$APPLY_CONTENT_SETTING_ARRAY;                                      

drop TABLE DM$APPLY_CONTENT_ITEM;                                               
drop TABLE DM$PMML_DTD;                                                         
drop TABLE DM$INTERNAL_CONFIGURATION;                                           
drop TABLE DM$CONFIGURATION;                                                    
drop TABLE JAVA$CLASS$MD5$TABLE;                                                
drop TABLE CREATE$JAVA$LOB$TABLE;                                               
drop TABLE DM$APPLY_OUTPUT;                                                     
drop TABLE DM$MS_RESULT_ENTRY;                                                  
drop TABLE DM$MODEL_SEEKER_RESULT;                                              
drop TABLE DM$RESULT_PROPERTY;                                                  

drop TABLE DM$RESULT;                                                           
drop TABLE DM$EXECUTION_STATUS;                                                 
drop TABLE DM$EXECUTION_HANDLE;                                                 
drop TABLE DM$TASK;                                                             
drop TABLE DM$LOCATION_CELL_ACCESS_DATA;                                        
drop TABLE DM$LOGICAL_DATA;                                                     
drop TABLE DM$NESTED_SETTINGS;                                                  
drop TABLE DM$FUNCTION_SETTINGS;                                                
drop TABLE DM$MODEL;                                                            
drop TABLE DM$MODEL_TABLES;                                                     
drop TABLE DM$OBJECT;


drop VIEW DM_APPLY_CONTENT_ITEM;                                                
drop VIEW DM_APPLY_CONTENT_SETTING;                                             
drop VIEW DM_APPLY_CONTENT_SETTING_ARRAY;                                       
drop VIEW DM_ATTRIBUTE;                                                         
drop VIEW DM_ATTRIBUTE_PROPERTY;                                                
drop VIEW DM_SETTING;                                                           
drop VIEW DM_SETTING_ARRAY;                                                     
drop VIEW DM_SETTINGS_MAP;                                                      
drop VIEW DM_MODEL_PROPERTY;                                                    

drop VIEW DM_MODEL_PROPERTY_ARRAY;                                              
drop VIEW DM_CATEGORY_SET;                                                      
drop VIEW DM_CATEGORY_TB;                                                       
drop VIEW DM_CATEGORY_EX;                                                       
drop VIEW DM_CATEGORY;                                                          
drop VIEW DM_CATEGORY_MATRIX_ENTRY;                                             
drop VIEW DM_PRIOR_PROBABILITY_ENTRY;                                           
drop VIEW DM_SETTING_CATEGORY;                                                  
drop VIEW DM_LIFT_RESULT_ENTRY;                                                 
drop VIEW DM$V$OBJECT;                                                          
drop VIEW DM$V$MODEL_INT;                                                       
drop VIEW DM$V$MODEL_SEEKER_RESULT_INT;                                         
drop VIEW DM$V$RESULT_INT;                                                      

drop VIEW DM$V$RESULT_PROPERTY;                                                 
drop VIEW DM$V$MODEL_TABLES;                                                    
drop VIEW DM$V$FUNCTION_SETTINGS;                                               
drop VIEW DM$V$ALGORITHM_SETTINGS;                                              
drop VIEW DM$V$MS_ALGORITHM_SETTINGS;                                           
drop VIEW DM$V$NESTED_SETTINGS;                                                 
drop VIEW DM$V$LOGICAL_DATA_INT;                                                
drop VIEW DM$V$LOGICAL_DATA;                                                    
drop VIEW DM$V$TASK;                                                            
drop VIEW DM$V$TASK_ARGUMENTS;                                                  
drop VIEW DM$V$MODEL;                                                           
drop VIEW DM$V$PHYSICAL_DATA_NAMED;                                             
drop VIEW DM$V$PHYSICAL_DATA_UNNAMED;                                           

drop VIEW DM$V$PHYSICAL_DATA_INT;                                               
drop VIEW DM$V$PHYSICAL_DATA;                                                   
drop VIEW DM$V$LOCATION_CELL_ACCESS_DATA;                                       
drop VIEW DM$V$LOCATION_ACCESS_DATA;                                            
drop VIEW DM$V$EXECUTION_HANDLE;                                                
drop VIEW DM$V$EXECUTION_STATUS;                                                
drop VIEW DM$V$CONFIGURATION;                                                   
drop VIEW DM$V$APPLY_OUTPUT;                                                    
drop VIEW DM$V$RESULT;                                                          
drop VIEW DM$V$MODEL_SEEKER_RESULT;                                             
drop VIEW DM$V$MS_RESULT_ENTRY;                                                 
drop VIEW DM_OBJECT;                                                            
drop VIEW DM_MODEL;                                                             

drop VIEW DM_RESULT;                                                            
drop VIEW DM_LIFT_RESULT;                                                       
drop VIEW DM_TEST_RESULT;                                                       
drop VIEW DM_APPLY_RESULT;                                                      
drop VIEW DM_RESULT_PROPERTY;                                                   
drop VIEW DM_MODEL_SEEKER_RESULT;                                               
drop VIEW DM_MS_RESULT_ENTRY;                                                   
drop VIEW DM_MODEL_TABLES;                                                      
drop VIEW DM_MODEL_TABLES_2D;                                                   
drop VIEW DM_FUNCTION_SETTINGS;                                                 
drop VIEW DM_ALGORITHM_SETTINGS;                                                
drop VIEW DM_NESTED_SETTINGS;                                                   

drop VIEW DM_LOGICAL_DATA;                                                      
drop VIEW DM_TASK;                                                              
drop VIEW DM_TASK_ARGUMENTS;                                                    
drop VIEW DM_PHYSICAL_DATA;                                                     
drop VIEW DM_EXECUTION_HANDLE;                                                  
drop VIEW DM_EXECUTION_STATUS;                                                  
drop VIEW DM_CONFIGURATION;                                                     
drop VIEW DM_LOCATION_ACCESS_DATA;                                              
drop VIEW DM_LOCATION_CELL_ACCESS_DATA;                                         
drop VIEW DM_APPLY_OUTPUT;                                                      
