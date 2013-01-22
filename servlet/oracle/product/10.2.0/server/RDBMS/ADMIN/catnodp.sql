Rem
Rem $Header: catnodp.sql 14-apr-2004.10:29:08 tbgraves Exp $
Rem
Rem catnodp.sql
Rem
Rem Copyright (c) 2002, 2004, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem     catnodp.sql - Drop all DataPump components
Rem
Rem    DESCRIPTION
Rem     
Rem
Rem    NOTES
Rem     This gets executed in downgrade scripts, and the old version of the
Rem     DataPump is loaded anew from catproc (catdp). None of the types
Rem     defined by the DataPump are expected to persist in tables, so we're
Rem     free to wipe them out and recreate them rather than perform ALTER
Rem     TYPEs on them.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    tbgraves    04/14/04 - drop DBMS_DATAPUMP_UTL package 
Rem    sdipirro    04/16/04 - New dumpfile info type and synonym 
Rem    sdipirro    03/02/04 - New status types and synonyms to drop 
Rem    sdipirro    08/11/03 - Versioning for public types
Rem    ebatbout    06/03/03 - Drop package, kupd$data
Rem    gclaborn    03/09/03 - Drop package kupc$que_int
Rem    gclaborn    12/12/02 - Drop new tables
Rem    gclaborn    12/06/02 - Add new objects
Rem    sdipirro    11/21/02 - Remove obsolete emulation types
Rem    jkaloger    05/28/02 - Add filemgr internal package
Rem    gclaborn    05/24/02 - Add prvt{h|b}pci
Rem    emagrath    05/13/02 - Add Datapump fixed table support
Rem    sdipirro    04/18/02 - Add datapump packages
Rem    gclaborn    04/14/02 - gclaborn_catdp
Rem    gclaborn    04/09/02 - Created
Rem

----------------------------------------------
--      First, wipe out all types
----------------------------------------------

@@catnodpt.sql


----------------------------------------------
--      Then, everything else
----------------------------------------------

-- Residual Metadata API stuff...
@@catnomta.sql

-- DataPump internal data load/unload package...
DROP PACKAGE sys.kupd$data;
DROP PACKAGE sys.kupd$data_int;

-- DataPump internal message and constant def package
DROP PACKAGE SYS.KUPCC;

-- DataPump API package
DROP PACKAGE SYS.DBMS_DATAPUMP;
DROP PACKAGE SYS.DBMS_DATAPUMP_UTL;

-- DataPump private internal packages
DROP PACKAGE SYS.KUPC$QUEUE;
DROP PACKAGE SYS.KUPC$QUEUE_INT;
DROP PACKAGE SYS.KUPC$QUE_INT;
DROP PACKAGE SYS.KUPW$WORKER;
DROP PACKAGE SYS.KUPM$MCP;
DROP PACKAGE SYS.KUPF$FILE;
DROP PACKAGE SYS.KUPF$FILE_INT;
DROP PACKAGE SYS.KUPP$PROC;
DROP PACKAGE SYS.KUPV$FT;
DROP PACKAGE SYS.KUPV$FT_INT;

-- DataPump private libraries
DROP LIBRARY KUPDLIB;
DROP LIBRARY KUPFLIB;
DROP LIBRARY KUPVLIB;


-- Client views and synonyms
DROP PUBLIC SYNONYM dba_datapump_sessions;
DROP PUBLIC SYNONYM dba_datapump_jobs;
DROP PUBLIC SYNONYM user_datapump_jobs;
DROP VIEW SYS.dba_datapump_sessions;
DROP VIEW SYS.dba_datapump_jobs;
DROP VIEW SYS.user_datapump_jobs;

-- Fixed Views and synonyms
DROP PUBLIC SYNONYM GV$DATAPUMP_SESSION;
DROP PUBLIC SYNONYM GV$DATAPUMP_JOB;
DROP PUBLIC SYNONYM V$DATAPUMP_SESSION;
DROP PUBLIC SYNONYM V$DATAPUMP_JOB;
DROP VIEW SYS.GV_$DATAPUMP_SESSION;
DROP VIEW SYS.GV_$DATAPUMP_JOB;
DROP VIEW SYS.V_$DATAPUMP_SESSION;
DROP VIEW SYS.V_$DATAPUMP_JOB;


-- DataPump API DBMS_DATAPUMP.GET_STATUS public synonyms
DROP PUBLIC SYNONYM ku$_Status;
DROP PUBLIC SYNONYM ku$_Status1010;
DROP PUBLIC SYNONYM ku$_Status1020;
DROP PUBLIC SYNONYM ku$_JobDesc;
DROP PUBLIC SYNONYM ku$_JobDesc1010;
DROP PUBLIC SYNONYM ku$_JobDesc1020;
DROP PUBLIC SYNONYM ku$_DumpFileSet;
DROP PUBLIC SYNONYM ku$_DumpFileSet1010;
DROP PUBLIC SYNONYM ku$_DumpFileSet1020;
DROP PUBLIC SYNONYM ku$_DumpFile;
DROP PUBLIC SYNONYM ku$_DumpFile1010;
DROP PUBLIC SYNONYM ku$_DumpFile1020;
DROP PUBLIC SYNONYM ku$_ParamValues;
DROP PUBLIC SYNONYM ku$_ParamValues1010;
DROP PUBLIC SYNONYM ku$_ParamValues1020;
DROP PUBLIC SYNONYM ku$_ParamValue;
DROP PUBLIC SYNONYM ku$_ParamValue1010;
DROP PUBLIC SYNONYM ku$_ParamValue1020;
DROP PUBLIC SYNONYM ku$_JobStatus;
DROP PUBLIC SYNONYM ku$_JobStatus1010;
DROP PUBLIC SYNONYM ku$_JobStatus1020;
DROP PUBLIC SYNONYM ku$_LogEntry;
DROP PUBLIC SYNONYM ku$_LogEntry1010;
DROP PUBLIC SYNONYM ku$_LogEntry1020;
DROP PUBLIC SYNONYM ku$_LogLine;
DROP PUBLIC SYNONYM ku$_LogLine1010;
DROP PUBLIC SYNONYM ku$_LogLine1020;
DROP PUBLIC SYNONYM ku$_WorkerStatusList;
DROP PUBLIC SYNONYM ku$_WorkerStatusList1010;
DROP PUBLIC SYNONYM ku$_WorkerStatusList1020;
DROP PUBLIC SYNONYM ku$_WorkerStatus;
DROP PUBLIC SYNONYM ku$_WorkerStatus1010;
DROP PUBLIC SYNONYM ku$_WorkerStatus1020;

DROP PUBLIC SYNONYM ku$_dumpfile_info;
DROP PUBLIC SYNONYM ku$_dumpfile_item;

-- Public synonyms for DataPump package and master table object type
DROP PUBLIC SYNONYM dbms_datapump;

-- Objects to support EXPORT_NOEXP filter.
DROP VIEW sys.ku_noexp_view;
