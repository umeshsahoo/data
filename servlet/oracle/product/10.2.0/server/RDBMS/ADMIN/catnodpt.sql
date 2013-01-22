Rem
Rem $Header: catnodpt.sql 16-apr-2004.15:39:07 sdipirro Exp $
Rem
Rem catnodpt.sql
Rem
Rem Copyright (c) 2002, 2004, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      catnodpt.sql - Drop types used by the DataPump
Rem
Rem    DESCRIPTION
Rem     One component of catnodp.sql. Types must be dropped upon install
Rem     because CREATE OR REPLACE TYPE doesn't work. This file is invoked from
Rem     both catdp.sql and catnodp.sql 
Rem
Rem    NOTES
Rem      
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sdipirro    04/16/04 - New dumpfile info type and synonym 
Rem    sdipirro    03/02/04 - New status types and synonyms to drop 
Rem    dgagne      02/04/04 - add drop of type kupc post_mt_init 
Rem    sdipirro    08/11/03 - Versioning for public types
Rem    jkaloger    05/09/03 - Drop file-list objects & messages
Rem    gclaborn    03/11/03 - Remove kupc$q_message
Rem    lbarton     02/21/03 - bugfix
Rem    gclaborn    12/12/02 - Drop new tables
Rem    sdipirro    11/21/02 - Remove obsolete emulation types
Rem    wfisher     10/16/02 - Drop new release_file type
Rem    sdipirro    06/21/02 - New/renamed drops for types in prvtkupc
Rem    gclaborn    05/24/02 - Drop queue table and kupc$q_message
Rem    sdipirro    04/18/02 - Add dbmsdp and kupcc type drops
Rem    gclaborn    04/14/02 - gclaborn_catdp
Rem    gclaborn    04/10/02 - Created
Rem

---------------------------------------------
---     Drop Metadata API types.
---------------------------------------------
@@catnomtt.sql

----------------------------------------------
---     Drop DataPump queue table and other anciallary tables
----------------------------------------------
BEGIN
dbms_aqadm.drop_queue_table(queue_table => 'SYS.KUPC$DATAPUMP_QUETAB',
                            force       => TRUE);
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE = -24002 THEN NULL;
      ELSE RAISE;
      END IF;
END;
/

-- Tables to support EXCLUDE_NOEXP filter... view is dropped in catnodp.sql
DROP TABLE sys.ku_noexp_tab;
DROP TABLE sys.ku$noexp_tab;

----------------------------------------------
---     Drop other DataPump types
----------------------------------------------

-- DataPump message object types

DROP TYPE kupc$_add_device FORCE;
DROP TYPE kupc$_add_file FORCE;
DROP TYPE kupc$_data_filter FORCE;
DROP TYPE kupc$_log_entry FORCE;
DROP TYPE kupc$_log_error FORCE;
DROP TYPE kupc$_metadata_filter FORCE;
DROP TYPE kupc$_metadata_transform FORCE;
DROP TYPE kupc$_metadata_remap FORCE;
DROP TYPE kupc$_open FORCE;
DROP TYPE kupc$_restart FORCE;
DROP TYPE kupc$_set_parallel FORCE;
DROP TYPE kupc$_set_parameter FORCE;
DROP TYPE kupc$_start_job FORCE;
DROP TYPE kupc$_stop_job FORCE;
DROP TYPE kupc$_worker_exit FORCE;
DROP TYPE kupc$_workererror FORCE;
DROP TYPE kupc$_worker_log_entry FORCE;
DROP TYPE kupc$_table_data_array FORCE;
DROP TYPE kupc$_table_datas FORCE;
DROP TYPE kupc$_table_data FORCE;
DROP TYPE kupc$_bad_file FORCE;
DROP TYPE kupc$_device_ident FORCE;
DROP TYPE kupc$_worker_file FORCE;
DROP TYPE kupc$_get_work FORCE;
DROP TYPE kupc$_masterjobinfo FORCE;
DROP TYPE kupc$_mastererror FORCE;
DROP TYPE kupc$_post_mt_init FORCE;
DROP TYPE kupc$_api_ack FORCE;
DROP TYPE kupc$_exit FORCE;
DROP TYPE kupc$_sql_file_job FORCE;
DROP TYPE kupc$_estimate_job FORCE;
DROP TYPE kupc$_load_data FORCE;
DROP TYPE kupc$_load_metadata FORCE;
DROP TYPE kupc$_unload_data FORCE;
DROP TYPE kupc$_unload_metadata FORCE;
DROP TYPE kupc$_release_files FORCE;
DROP TYPE kupc$_sequential_file FORCE;
DROP TYPE kupc$_disk_file FORCE;
DROP TYPE kupc$_worker_file_list FORCE;
DROP TYPE kupc$_file_list FORCE;
DROP TYPE kupc$_worker_msg FORCE;
DROP TYPE kupc$_shadow_msg FORCE;
DROP TYPE kupc$_master_msg FORCE;
DROP TYPE kupc$_message FORCE;

-- Types used by the DataPump message types

DROP TYPE kupc$_JobInfo FORCE;
DROP TYPE kupc$_LogEntries FORCE;
-- The following two types are only used internally by the File Manager.
DROP TYPE kupc$_FileList FORCE;
DROP TYPE kupc$_FileInfo FORCE;

-- Object types for the DBMS_DATAPUMP.GET_STATUS interface

DROP TYPE sys.ku$_Status1020 FORCE;
DROP TYPE sys.ku$_Status1010 FORCE;
DROP TYPE sys.ku$_JobDesc1020 FORCE;
DROP TYPE sys.ku$_JobDesc1010 FORCE;
DROP TYPE sys.ku$_DumpFileSet1010 FORCE;
DROP TYPE sys.ku$_DumpFile1010 FORCE;
DROP TYPE sys.ku$_ParamValues1010 FORCE;
DROP TYPE sys.ku$_ParamValue1010 FORCE;
DROP TYPE sys.ku$_JobStatus1020 FORCE;
DROP TYPE sys.ku$_JobStatus1010 FORCE;
DROP TYPE sys.ku$_LogEntry1010 FORCE;
DROP TYPE sys.ku$_LogLine1010 FORCE;
DROP TYPE sys.ku$_WorkerStatusList1020 FORCE;
DROP TYPE sys.ku$_WorkerStatusList1010 FORCE;
DROP TYPE sys.ku$_WorkerStatus1020 FORCE;
DROP TYPE sys.ku$_WorkerStatus1010 FORCE;

DROP TYPE sys.ku$_dumpfile_info FORCE;
DROP TYPE sys.ku$_dumpfile_item FORCE;