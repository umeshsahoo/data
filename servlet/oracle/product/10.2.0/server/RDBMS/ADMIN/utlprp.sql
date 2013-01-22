Rem Copyright (c) 2003, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      utlprp.sql - Recompile invalid objects in the database
Rem
Rem    DESCRIPTION
Rem      This script recompiles invalid objects in the database.
Rem
Rem      This script is typically used to recompile invalid objects
Rem      remaining at the end of a database upgrade or downgrade. 
Rem 
Rem      Although invalid objects are automatically recompiled on demand,
Rem      running this script ahead of time will reduce or eliminate
Rem      latencies due to automatic recompilation.
Rem
Rem      This script is a wrapper based on the UTL_RECOMP package. 
Rem      UTL_RECOMP provides a more general recompilation interface,
Rem      including options to recompile objects in a single schema. Please
Rem      see the documentation for package UTL_RECOMP for more details.
Rem
Rem    INPUTS
Rem      The degree of parallelism for recompilation can be controlled by
Rem      providing a parameter to this script. If this parameter is 0 or
Rem      NULL, UTL_RECOMP will automatically determine the appropriate
Rem      level of parallelism based on Oracle parameters cpu_count and
Rem      parallel_threads_per_cpu. If the parameter is 1, sequential
Rem      recompilation is used. Please see the documentation for package
Rem      UTL_RECOMP for more details.
Rem
Rem    NOTES
Rem      * You must be connected AS SYSDBA to run this script.
Rem      * There should be no other DDL on the database while running the
Rem        script.  Not following this recommendation may lead to deadlocks.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rburns      03/17/05 - use dbms_registry_sys 
Rem    gviswana    02/07/05 - Post-compilation diagnostics 
Rem    gviswana    09/09/04 - Auto tuning and diagnosability
Rem    rburns      09/20/04 - fix validate_components 
Rem    gviswana    12/09/03 - Move functional-index re-enable here 
Rem    gviswana    06/04/03 - gviswana_bug-2814808
Rem    gviswana    05/28/03 - Created
Rem

SET VERIFY OFF;

SELECT dbms_registry_sys.time_stamp('utlrp_bgn') as timestamp from dual;

DOC
   The following PL/SQL block invokes UTL_RECOMP to recompile invalid
   objects in the database. Recompilation time is proportional to the
   number of invalid objects in the database, so this command may take
   a long time to execute on a database with a large number of invalid
   objects.
  
   Use the following queries to track recompilation progress:
   
   1. Query returning the number of invalid objects remaining. This
      number should decrease with time.
         SELECT COUNT(*) FROM obj$ WHERE status IN (4, 5, 6);
   
   2. Query returning the number of objects compiled so far. This number
      should increase with time.
         SELECT COUNT(*) FROM UTL_RECOMP_COMPILED;
  
   This script automatically chooses serial or parallel recompilation
   based on the number of CPUs available (parameter cpu_count) multiplied
   by the number of threads per CPU (parameter parallel_threads_per_cpu).
   On RAC, this number is added across all RAC nodes.
  
   UTL_RECOMP uses DBMS_SCHEDULER to create jobs for parallel
   recompilation. Jobs are created without instance affinity so that they
   can migrate across RAC nodes. Use the following queries to verify
   whether UTL_RECOMP jobs are being created and run correctly:
  
   1. Query showing jobs created by UTL_RECOMP
         SELECT job_name FROM dba_scheduler_jobs
            WHERE job_name like 'UTL_RECOMP_SLAVE_%';
  
   2. Query showing UTL_RECOMP jobs that are running
         SELECT job_name FROM dba_scheduler_running_jobs
            WHERE job_name like 'UTL_RECOMP_SLAVE_%';
#

DECLARE
   threads pls_integer := &&1;
BEGIN
   utl_recomp.recomp_parallel(threads);
END;
/

SELECT dbms_registry_sys.time_stamp('utlrp_end') as timestamp from dual;

Rem
Rem Re-enable functional indexes disabled by the recompile
Rem
DECLARE
   TYPE tab_char IS TABLE OF VARCHAR2(32767) INDEX BY BINARY_INTEGER;
   commands tab_char;
   table_exists number;
BEGIN
   -- Check for existence of the table marking disabled functional indices
   SELECT count(*) INTO table_exists FROM DBA_OBJECTS
      WHERE owner = 'SYS' and object_name = 'UTLIRP_ENABLED_FUNC_INDEXES' and
            object_type = 'TABLE';

   IF (table_exists > 0) THEN
      -- Select indices to be re-enabled
      EXECUTE IMMEDIATE q'+
         SELECT 'ALTER INDEX "' || u.name || '"."' || o.name || '" ENABLE'
            FROM   utlirp_enabled_func_indexes e, ind$ i, obj$ o, user$ u
            WHERE  e.obj# = i.obj# AND i.obj# = o.obj# and o.owner# = u.user#
              AND bitand(i.flags, 1024) != 0+'
      BULK COLLECT INTO commands;

      IF (commands.count() > 0) THEN
         FOR i IN 1 .. commands.count() LOOP
            EXECUTE IMMEDIATE commands(i);
         END LOOP;
      END IF;

      EXECUTE IMMEDIATE 'DROP TABLE utlirp_enabled_func_indexes';
   END IF;
END;
/

DOC
 The following query reports the number of objects that have compiled
 with errors (objects that compile with errors have status set to 3 in
 obj$). If the number is higher than expected, please examine the error
 messages reported with each object (using SHOW ERRORS) to see if they
 point to system misconfiguration or resource constraints that must be
 fixed before attempting to recompile these objects.
#
select COUNT(*) "OBJECTS WITH ERRORS" from obj$ where status = 3;


DOC
 The following query reports the number of errors caught during
 recompilation. If this number is non-zero, please query the error
 messages in the table UTL_RECOMP_ERRORS to see if any of these errors
 are due to misconfiguration or resource constraints that must be
 fixed before objects can compile successfully.
#
select COUNT(*) "ERRORS DURING RECOMPILATION" from utl_recomp_errors;


Rem =====================================================================
Rem Run component validation procedure
Rem =====================================================================

SET serveroutput on
EXECUTE dbms_registry_sys.validate_components; 
SET serveroutput off

