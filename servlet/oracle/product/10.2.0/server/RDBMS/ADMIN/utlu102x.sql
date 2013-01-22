Rem
Rem $Header: utlu102x.sql 31-may-2005.07:24:49 rburns Exp $
Rem
Rem utlu102x.sql
Rem
Rem Copyright (c) 2004, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      utlu102x.sql - UTiLity Upgrade Information
Rem
Rem    DESCRIPTION
Rem      This script provides information about databases to be
Rem      upgraded to 10.2.  
Rem
Rem      Supported releases: 8.1.7, 9.0.1, 9.2.0, and 10.1.0
Rem
Rem    NOTES
Rem      Run connected AS SYSDBA to the database to be upgraded
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rburns      05/31/05 - check patch version for supported upgrades 
Rem    rburns      05/09/05 - check stale statistics, re-run registry fix 
Rem    rburns      05/09/05 - increase java pool, fix sga_target
Rem    rburns      05/06/05 - adjust rollback size 
Rem    yuli        05/05/05 - bump to 10.2.0.1 production 
Rem    rburns      04/27/05 - total space calc 
Rem    rburns      04/26/05 - use 817 view 
Rem    rburns      03/30/05 - new warnings, disk space calcs 
Rem    rburns      02/10/05 - fix xml 
Rem    rburns      02/02/05 - ROUND init param values 
Rem                         - no recycle bin objects for invalid list
Rem    rburns      01/31/05 - skip HTMLDB 
Rem    rburns      01/04/05 - invalid object and connect warnings 
Rem    rburns      01/04/05 - collect total additional space required for ASM 
Rem    rburns      12/14/04 - fix sysaux query 
Rem    rburns      12/11/04 - fix tablespace amounts 
Rem    rburns      11/27/04 - remove time estimate 
Rem    arithikr    11/01/04 - 3949992 - Fix shared_pool_size 
Rem    rburns      11/08/04 - add HTMLDB 
Rem    rburns      10/28/04 - move CTX before XDB 
Rem    rburns      10/18/04 - check that patch applied 
Rem    rburns      10/19/04 - include ORDVIR 
Rem    rburns      09/22/04 - open file param 
Rem    rburns      08/14/04 - add XDB dependencies 
Rem    rburns      07/15/04 - add time diags and calibrate for 10.2 
Rem    rburns      07/13/04 - Add SDO dependency on XML 
Rem    rburns      06/22/04 - rburns_pre_upgrade_util
Rem    rburns      05/11/04 - Created
Rem

SET SERVEROUTPUT ON;

---------------------------- DECLARATIONS ---------------------------

DECLARE

  utlu_version CONSTANT VARCHAR2(30) := '10.2.0.1';

-- *****************************************************************
-- Database Information 
-- *****************************************************************

  db_name         VARCHAR2(30);
  db_version      VARCHAR2(30);
  db_dict_version VARCHAR2(30);
  db_prev_version VARCHAR2(30);
  db_compat       VARCHAR2(30);
  db_block_size   NUMBER;
  dbv             BINARY_INTEGER; -- (817, 901, 920, 101, 102)
  vers            VARCHAR2(12);   -- major version (e.g., 10.1.0)
  patch           VARCHAR2(12);   -- patch version (e.g., 10.1.0.2)

-- *****************************************************************
-- Component Information 
-- *****************************************************************

  TYPE comp_record_t IS RECORD (
      cid            VARCHAR2(30), -- component id
      cname          VARCHAR2(45), -- component name
      version        VARCHAR2(30), -- version
      status         VARCHAR2(15), -- component status
      schema         VARCHAR2(30), -- owner of component
      def_ts         VARCHAR2(30), -- name of default tablespace
      script         VARCHAR2(128), -- upgrade script name
      processed      BOOLEAN,
      install        BOOLEAN,
      sys_kbytes     NUMBER,
      sysaux_kbytes  NUMBER,
      def_ts_kbytes  NUMBER,
      ins_sys_kbytes NUMBER,
      ins_def_kbytes NUMBER
      );

  TYPE comp_table_t IS TABLE of comp_record_t INDEX BY BINARY_INTEGER;

  cmp_info comp_table_t;      -- Table of component information

-- index values for components (order as in upgrade script)
  catalog CONSTANT BINARY_INTEGER:=1;
  catproc CONSTANT BINARY_INTEGER:=2;
  javavm  CONSTANT BINARY_INTEGER:=3;
  xml     CONSTANT BINARY_INTEGER:=4;
  catjava CONSTANT BINARY_INTEGER:=5;
  context CONSTANT BINARY_INTEGER:=6;
  xdb     CONSTANT BINARY_INTEGER:=7;
  rac     CONSTANT BINARY_INTEGER:=8;
  owm     CONSTANT BINARY_INTEGER:=9;
  odm     CONSTANT BINARY_INTEGER:=10;
  mgw     CONSTANT BINARY_INTEGER:=11;
  aps     CONSTANT BINARY_INTEGER:=12;
  amd     CONSTANT BINARY_INTEGER:=13;
  xoq     CONSTANT BINARY_INTEGER:=14;
  ordim   CONSTANT BINARY_INTEGER:=15;
  sdo     CONSTANT BINARY_INTEGER:=16;
  wk      CONSTANT BINARY_INTEGER:=17;
  ols     CONSTANT BINARY_INTEGER:=18;
  exf     CONSTANT BINARY_INTEGER:=19;
  em      CONSTANT BINARY_INTEGER:=20;
  htmldb  CONSTANT BINARY_INTEGER:=21;
  stats   CONSTANT BINARY_INTEGER:=22;

  max_comps CONSTANT BINARY_INTEGER :=22; -- include STATS for space calcs
  max_components CONSTANT BINARY_INTEGER :=21;

-- *****************************************************************
-- Tablespace Information 
-- *****************************************************************

   TYPE tablespace_record_t IS RECORD (
       name    VARCHAR2(30),  -- tablespace name
       inuse   NUMBER,        -- kbytes inuse in tablespace
       alloc   NUMBER,        -- kbytes allocated to tbs
       auto    NUMBER,        -- autoextend kbytes available
       avail   NUMBER,        -- total kbytes available
       delta   NUMBER,        -- kbytes required for upgrade
       inc_by  NUMBER,        -- kbytes to increase tablespace by
       min     NUMBER,        -- minimum required kbytes to perform upgrade
       addl    NUMBER,        -- additional space allocated during upgrade
       fname   VARCHAR2(513), -- filename in tablespace
       fauto   BOOLEAN,       -- TRUE if there is a file to increase autoextend
       temporary BOOLEAN      -- TRUE if Temporary tablespace
       );

   TYPE tablespace_table_t IS TABLE OF tablespace_record_t
        INDEX BY BINARY_INTEGER;
 
   ts_info tablespace_table_t; -- Tablespace information
   max_ts  BINARY_INTEGER; -- Total number of relevant tablespaces

-- *****************************************************************
-- Rollback Segment Information 
-- *****************************************************************

   TYPE rollback_record_t IS RECORD (
       tbs_name VARCHAR2(30), -- tablespace name
       seg_name VARCHAR2(30), -- segment name
       status   VARCHAR(30),  -- online or offline
       inuse    NUMBER, -- kbytes in use
       next     NUMBER, -- kbytes in NEXT
       max_ext  NUMBER, -- max extents
       auto     NUMBER  -- autoextend available for tablespace
       );

   TYPE rollback_table_t IS TABLE of rollback_record_t
        INDEX BY BINARY_INTEGER;

   rs_info    rollback_table_t;  -- Rollback segment information
   max_rs     BINARY_INTEGER; -- Total number of public rollback segs

-- *****************************************************************
-- Log File Information 
-- *****************************************************************

   TYPE log_file_record_t IS RECORD (
        file_spec    VARCHAR2(513),
        grp          NUMBER, 
        bytes        NUMBER,
        status       VARCHAR2(16)
        );

   TYPE log_file_table_t IS TABLE of log_file_record_t
        INDEX BY BINARY_INTEGER;
 
   lf_info log_file_table_t;  -- Log File Information
   max_lf        BINARY_INTEGER;  -- Total number of log file groups

   min_log_size CONSTANT NUMBER := 4194304;   -- Minimum size 4M
   rmd_log_size CONSTANT NUMBER := 15;        -- Recommended size 15M

-- *****************************************************************
-- Initialization Parameter Information 
-- *****************************************************************

   TYPE obsolete_record_t IS RECORD (
      name VARCHAR2(80),
      db_match BOOLEAN
      );

   TYPE obsolete_table_t IS TABLE of obsolete_record_t
      INDEX BY BINARY_INTEGER;

   op     obsolete_table_t;
   max_op BINARY_INTEGER;

   TYPE renamed_record_t IS RECORD (
      oldname VARCHAR2(80),
      newname VARCHAR2(80),
      db_match BOOLEAN
      );

   TYPE renamed_table_t IS TABLE of renamed_record_t
      INDEX BY BINARY_INTEGER;

   rp      renamed_table_t;
   max_rp  BINARY_INTEGER;

   TYPE special_record_t IS RECORD (
      oldname  VARCHAR2(80),
      oldvalue VARCHAR2(80),
      newname  VARCHAR2(80),
      newvalue VARCHAR2(80),
      db_match BOOLEAN
      );

   TYPE special_table_t IS TABLE of special_record_t
      INDEX BY BINARY_INTEGER;

   sp      special_table_t;
   max_sp  BINARY_INTEGER;

   TYPE required_record_t IS RECORD (
      name     VARCHAR2(80),
      newvalue NUMBER,
      db_match BOOLEAN
      );

   TYPE required_table_t IS TABLE of required_record_t
      INDEX BY BINARY_INTEGER;

   reqp      required_table_t;
   max_reqp  BINARY_INTEGER;

   TYPE minvalue_record_t IS RECORD (
      name     VARCHAR2(80),
      minvalue NUMBER,
      oldvalue NUMBER,
      newvalue NUMBER,
      display  BOOLEAN
      );

   TYPE minvalue_table_t IS TABLE of minvalue_record_t
      INDEX BY BINARY_INTEGER;

   mp        minvalue_table_t;
   max_mp    BINARY_INTEGER;
   sps       NUMBER;  -- shared_pool_size
   cpu       NUMBER;  -- number of CPUs
   sesn      NUMBER;  -- number of sessions 
   sps_ovrhd NUMBER;  -- shared_pool_size overheads

   sp_idx BINARY_INTEGER;  -- shared_pool_size
   jv_idx BINARY_INTEGER;  -- java_pool_size
   st_idx BINARY_INTEGER;  -- streams_pool_size
   lp_idx BINARY_INTEGER;  -- large_pool_size
   tg_idx BINARY_INTEGER;  -- sga_target
   cs_idx BINARY_INTEGER;  -- cache_size
   pg_idx BINARY_INTEGER;  -- pga_aggreate_target

-- *****************************************************************
-- Warning Information 
-- *****************************************************************

   sysaux_exists     BOOLEAN := FALSE; -- TRUE when sysaux tablespace exists
   sysaux_not_online BOOLEAN := FALSE; -- TRUE when sysaux is not online
   sysaux_not_perm   BOOLEAN := FALSE; -- TRUE when sysaux is not permanent
   sysaux_not_local  BOOLEAN := FALSE; -- TRUE when sysaux is not extent local
   sysaux_not_auto   BOOLEAN := FALSE; -- TRUE when sysaux is not auto seg 
   dip_user_exists   BOOLEAN := FALSE; -- TRUE when DIP user found in user$
   cluster_dbs       BOOLEAN := FALSE; -- TRUE when "cluster_database" init
   nls_al24utffss    BOOLEAN := FALSE; -- TRUE when AL24UTFFSS found in
   utf8_al16utf16    BOOLEAN := FALSE; -- TRUE when AL16UTF16 nor UTF8 NCHAR
   owm_replication   BOOLEAN := FALSE; -- TRUE when wmsys.wm$replication_table
   dblinks           BOOLEAN := FALSE; -- TRUE when database links exist
   cdc_data          BOOLEAN := FALSE; -- TRUE when cdc data exists
   post_upgrade      BOOLEAN := FALSE; -- TRUE when OLS post_upgrade required
   version_mismatch  BOOLEAN := FALSE; -- TRUE when dictionary != instance
   connect_role      BOOLEAN := FALSE; -- TRUE when connect role used
   invalid_objs      BOOLEAN := FALSE; -- TRUE when invalid objects exist
   ssl_users         BOOLEAN := FALSE; -- TRUE when potential SSL users
   timezone_v2       BOOLEAN := FALSE; -- TRUE when WITH TIME ZONE datatypes
   stale_stats       BOOLEAN := FALSE; -- TRUE when stale statistics found

-- *****************************************************************
-- Global Constants and Variables
-- *****************************************************************

   idx          BINARY_INTEGER;
   type cursor_t IS REF CURSOR;
   reg_cursor   cursor_t;

   p_null       CHAR(1);
   p_user       VARCHAR2(30);
   p_cid        VARCHAR2(30);
   p_status     VARCHAR2(30);
   n_status     NUMBER;
   p_version    VARCHAR2(30);
   p_schema     VARCHAR2(30);
   n_schema     NUMBER;
   p_value      VARCHAR2(80);
   p_pos        INTEGER;
   p_char       CHAR(1);
   p_undo       VARCHAR2(30);
   p_tsname     VARCHAR2(30);
   
   sum_bytes      NUMBER;
   delta_kbytes   NUMBER;
   delta_sysaux   NUMBER;
   delta_queues   INTEGER;
   rows_processed INTEGER;

   display_xml  BOOLEAN := TRUE;
   collect_diag BOOLEAN := FALSE;
   rerun        BOOLEAN := FALSE;
   inplace      BOOLEAN := FALSE;
   using_ASM    BOOLEAN := FALSE;
   SYS_todo     BOOLEAN := FALSE;
  
-- *****************************************************************
-- ------------- INTERNAL FUNCTIONS AND PROCEDURES -----------------
-- *****************************************************************

--------------------------- store_renamed --------------------------------

PROCEDURE store_renamed (i   IN OUT BINARY_INTEGER,
                         old VARCHAR2,
                         new VARCHAR2)
IS
BEGIN
   i:= i+1;
   rp(i).oldname:=old;
   rp(i).newname:=new;
END store_renamed;

--------------------------- store_removed --------------------------------

PROCEDURE store_removed (i    IN OUT BINARY_INTEGER,
                         name VARCHAR2)
IS
BEGIN
   i:=i+1;
   op(i).name:=name;
END store_removed;

--------------------------- store_special --------------------------------

PROCEDURE store_special (i    IN OUT BINARY_INTEGER,
                         old  VARCHAR2,
                         oldv VARCHAR2,
                         new  VARCHAR2,
                         newv VARCHAR2)
IS
BEGIN
   i:= i+1;
   sp(i).oldname:=old;
   sp(i).oldvalue:=oldv;
   sp(i).newname:=new;
   sp(i).newvalue:=newv;
   
END store_special;

--------------------------- store_minvalue --------------------------------

PROCEDURE store_minvalue (i    IN OUT BINARY_INTEGER,
                          name  VARCHAR2,
                          minv   NUMBER)
IS
BEGIN
   i:= i+1;
   mp(i).name:=name;
   mp(i).minvalue:=minv;
   mp(i).display:=FALSE;

END store_minvalue;

--------------------------- store_comp -----------------------------------

PROCEDURE store_comp (i       BINARY_INTEGER,
                      schema  VARCHAR2,
                      version VARCHAR2,
                      status  NUMBER)
IS
BEGIN

   cmp_info(i).processed := TRUE;
   IF status = 0 THEN
      cmp_info(i).status := 'INVALID';
   ELSIF status = 1 THEN
      cmp_info(i).status := 'VALID';
   ELSIF status = 2 THEN
      cmp_info(i).status := 'LOADING';
   ELSIF status = 3 THEN
      cmp_info(i).status := 'LOADED';
   ELSIF status = 4 THEN
      cmp_info(i).status := 'UPGRADING';
   ELSIF status = 5 THEN
      cmp_info(i).status := 'UPGRADED';
   ELSIF status = 6 THEN
      cmp_info(i).status := 'DOWNGRADING';
   ELSIF status = 7 THEN
      cmp_info(i).status := 'DOWNGRADED';
   ELSIF status = 8 THEN
      cmp_info(i).status := 'REMOVING';
   ELSIF status = 9 THEN
      cmp_info(i).status := 'OPTION OFF';
   ELSIF status = 10 THEN
      cmp_info(i).status := 'NO SCRIPT';
   ELSIF status = 99 THEN
      cmp_info(i).status := 'REMOVED';
   ELSE
      cmp_info(i).status := NULL;
   END IF;
   cmp_info(i).version   := version;
   cmp_info(i).schema    := schema;
   SELECT default_tablespace INTO cmp_info(i).def_ts
   FROM dba_users WHERE username = schema;
EXCEPTION
   WHEN NO_DATA_FOUND THEN NULL;
END store_comp;


------------------------------ update_puiu_data ---------------------

PROCEDURE update_puiu_data (dtype varchar2, dname varchar2, delta number)
IS
BEGIN

    IF collect_diag THEN
       EXECUTE IMMEDIATE 'UPDATE sys.puiu$data SET puiu_delta = :delta ' ||
                  'WHERE d_type=:dtype and d_name= :dname'
       USING delta, dtype, dname;
       COMMIT;
    END IF;
EXCEPTION 
    WHEN NO_DATA_FOUND THEN NULL;
END;

------------------------------ insert_puiu_data ---------------------

PROCEDURE insert_puiu_data (dtype varchar2, dname varchar2, delta number)
IS
BEGIN

    IF collect_diag AND NOT display_xml THEN
       EXECUTE IMMEDIATE 'INSERT INTO sys.puiu$data 
              (d_type, d_name, puiu_delta) VALUES (:dtype, :dname, :delta)'
       USING dtype, dname, delta;
       COMMIT;
    END IF;
EXCEPTION 
    WHEN DUP_VAL_ON_INDEX THEN NULL;
END;

-------------------------- is_comp_tablespace ------------------------------------
-- returns TRUE if some existing component has the tablespace as a default

FUNCTION is_comp_tablespace (tsname VARCHAR2) RETURN BOOLEAN
IS
BEGIN
    FOR i IN 1..max_components LOOP
        IF cmp_info(i).processed AND
           tsname = cmp_info(i).def_ts THEN
           RETURN TRUE;
        END IF;
    END LOOP;
    RETURN FALSE;
END is_comp_tablespace;

-------------------------- ts_has_queues ---------------------------------
-- returns TRUE if there is at least one queue in the tablespace

FUNCTION ts_has_queues (tsname VARCHAR2) RETURN BOOLEAN
IS
BEGIN
   SELECT NULL INTO p_null FROM dba_tables t, dba_queues q
   WHERE q.queue_table = t.table_name AND t.tablespace_name = tsname
         AND rownum <=1;
   RETURN TRUE;
EXCEPTION
   WHEN NO_DATA_FOUND THEN RETURN FALSE;
END ts_has_queues;

-------------------------- ts_is_SYS_temporary ---------------------------------
-- returns TRUE if there is at least one queue in the tablespace

FUNCTION ts_is_SYS_temporary (tsname VARCHAR2) RETURN BOOLEAN
IS
BEGIN
   SELECT NULL INTO p_null FROM dba_users
   WHERE username = 'SYS' AND temporary_tablespace = tsname;
   RETURN TRUE;
EXCEPTION
   WHEN NO_DATA_FOUND THEN RETURN FALSE;
END ts_is_SYS_temporary;

-------------------------- display_banner -------------------------------------

PROCEDURE display_banner
IS
BEGIN
    DBMS_OUTPUT.PUT_LINE(
   '**********************************************************************');
END display_banner;

-------------------------- display_database -----------------------------------

PROCEDURE display_database
IS
BEGIN
   IF display_xml THEN
      DBMS_OUTPUT.PUT_LINE('<Database>');
      DBMS_OUTPUT.PUT_LINE('<database Name="' || db_name || '"/>');
      DBMS_OUTPUT.PUT_LINE('<database Version="' || db_version || '"/>');
      DBMS_OUTPUT.PUT_LINE('<database Compatibility="' || db_compat || '"/>');
      DBMS_OUTPUT.PUT_LINE('</Database>');
   ELSE
     display_banner;
     DBMS_OUTPUT.PUT_LINE('Database:');
     display_banner;
     DBMS_OUTPUT.PUT_LINE ('--> name:       ' || db_name );
     DBMS_OUTPUT.PUT_LINE ('--> version:    ' || db_version );
     DBMS_OUTPUT.PUT_LINE ('--> compatible: ' || db_compat );
     DBMS_OUTPUT.PUT_LINE ('.');
   END IF;
END display_database;

------------------------------ display_logfiles -----------------------------
-- Display the names and sizes of all logfiles in lf_info

PROCEDURE display_logfiles
IS

BEGIN
   IF display_xml THEN
      IF max_lf > 0 THEN
         FOR i IN 1..max_lf LOOP
            DBMS_OUTPUT.PUT_LINE(
               '<RedologFile name="' || lf_info(i).file_spec || 
                 '" group="'  || TO_CHAR(lf_info(i).grp) ||
                 '" status="' || lf_info(i).status||
                 '" size="'   || TO_CHAR(rmd_log_size) || 
                 '" unit="MB"/>');
          END LOOP;
      END IF;
      DBMS_OUTPUT.PUT_LINE(
          '<RollbackSegment name="SYSTEM" size="90" unit="MB"/>');
   ELSE
      display_banner;
      DBMS_OUTPUT.PUT_LINE(
           'Logfiles: [make adjustments in the current environment]');
      display_banner;
      IF max_lf > 0 THEN
        FOR i IN 1..max_lf LOOP
            DBMS_OUTPUT.PUT_LINE('--> ' || lf_info(i).file_spec);
            DBMS_OUTPUT.PUT_LINE('.... status="' || lf_info(i).status ||
                                   '", group#="' || TO_CHAR(lf_info(i).grp) ||
                                   '"');
            DBMS_OUTPUT.PUT_LINE(
            '.... current size="' || TO_CHAR(lf_info(i).bytes/1024) || '" KB');

            DBMS_OUTPUT.PUT_LINE(
            '.... suggested new size="' || TO_CHAR(rmd_log_size) || 
                                           '" MB');
        END LOOP;
        DBMS_OUTPUT.PUT_LINE(
             'WARNING: one or more log files is less than 4MB.');
        DBMS_OUTPUT.PUT_LINE('Create additional log files larger ' ||
             'than 4MB, drop the smaller ones and then upgrade.');
      ELSE
         DBMS_OUTPUT.PUT_LINE(
         '--> The existing log files are adequate. No changes are required.');
      END IF;
      DBMS_OUTPUT.PUT_LINE ('.');
   END IF;
END display_logfiles;
 
----------------------- display_crs_xml -----------------------------
-- Display create rollback segment. Display is in xml format, only
-- for use by DBUA. Static. Note: DBMS_OUTPUT.PUT_LINE does no more than
-- 255 bytes.

PROCEDURE display_crs_xml
IS
BEGIN
   DBMS_OUTPUT.PUT_LINE(
        '<CreateRollbackSegments value="ODMA_RBS01" revert="true">');
   DBMS_OUTPUT.PUT_LINE(
        '<InNewTablespace name="ODMA_RBS" size="70" unit="MB">');
   DBMS_OUTPUT.PUT_LINE(
        '<Datafile name="{ORACLE_BASE}/oradata/{DB_NAME}/odma_rbs.dbf"/>');
   DBMS_OUTPUT.PUT_LINE(
        '<Autoextend value="ON">');
   DBMS_OUTPUT.PUT_LINE(
        '<Next value="10" unit="MB"/>');
   DBMS_OUTPUT.PUT_LINE(
        '<Maxsize value="200" unit="MB"/>');
   DBMS_OUTPUT.PUT_LINE(
        '</Autoextend>');
   DBMS_OUTPUT.PUT_LINE(
        '<Storage>');
   DBMS_OUTPUT.PUT_LINE(
        '<Initial value="10" unit="MB"/>');
   DBMS_OUTPUT.PUT_LINE(
        '<Next value="10" unit="MB"/>');
   DBMS_OUTPUT.PUT_LINE(
        '<MinExtents value="1"/>');
   DBMS_OUTPUT.PUT_LINE(
        '<MaxExtents value="30"/>');
   DBMS_OUTPUT.PUT_LINE(
        '</Storage>');
   DBMS_OUTPUT.PUT_LINE(
        '</InNewTablespace>');
   DBMS_OUTPUT.PUT_LINE(
        '</CreateRollbackSegments>');

END display_crs_xml;

---------------------- display_sysaux ------------------------------
PROCEDURE display_sysaux 
IS

BEGIN
   IF display_xml THEN
      DBMS_OUTPUT.PUT_LINE('<SYSAUXtbs>');
   ELSE
      display_banner;
      DBMS_OUTPUT.PUT_LINE('SYSAUX Tablespace:');
      DBMS_OUTPUT.PUT_LINE('[Create tablespace in the Oracle ' ||
                            'Database 10.2 environment]');
      display_banner;
   END IF;

   IF sysaux_exists THEN
      IF display_xml THEN
          DBMS_OUTPUT.PUT_LINE('<SysauxTablespace present="true"/>');
          DBMS_OUTPUT.PUT_LINE('<Attributes>');
          DBMS_OUTPUT.PUT_LINE('<Size value="' || TO_CHAR(delta_sysaux) ||
                                           '" unit="MB"/>');
          IF sysaux_not_online THEN
             DBMS_OUTPUT.PUT_LINE('<Online value="false"/>');
          ELSE 
             DBMS_OUTPUT.PUT_LINE('<Online value="true"/>');
          END IF;

          IF sysaux_not_perm THEN
             DBMS_OUTPUT.PUT_LINE('<Permanent value="false"/>');
          ELSE 
             DBMS_OUTPUT.PUT_LINE('<Permanent value="true"/>');
          END IF;
          -- Online and Readwrite are together
          IF sysaux_not_online THEN
             DBMS_OUTPUT.PUT_LINE('<Readwrite value="false"/>');
          ELSE 
             DBMS_OUTPUT.PUT_LINE('<Readwrite value="true"/>');
          END IF;
          IF sysaux_not_local THEN
             DBMS_OUTPUT.PUT_LINE('<ExtentManagementLocal value="false"/>');
          ELSE 
             DBMS_OUTPUT.PUT_LINE('<ExtentManagementLocal value="true"/>');
          END IF;
          IF sysaux_not_auto THEN
             DBMS_OUTPUT.PUT_LINE(
                           '<SegmentSpaceManagementAuto value="false"/>');
          ELSE 
             DBMS_OUTPUT.PUT_LINE(
                           '<SegmentSpaceManagementAuto value="true"/>');
          END IF;
          DBMS_OUTPUT.PUT_LINE('</Attributes>');
      ELSE
          DBMS_OUTPUT.PUT_LINE('WARNING: SYSAUX tablespace is present.');
          DBMS_OUTPUT.PUT_LINE(
             '.... Minimum required size for database upgrade:' ||
             TO_CHAR(delta_sysaux) || ' MB');
          -- Online and Readwrite are together 
          IF sysaux_not_online THEN
             DBMS_OUTPUT.PUT_LINE('WARNING:.... OFFLINE');
          ELSE 
             DBMS_OUTPUT.PUT_LINE('.... Online');
          END IF;
          IF sysaux_not_perm THEN
             DBMS_OUTPUT.PUT_LINE('WARNING:.... NOT Permanent');
          ELSE 
             DBMS_OUTPUT.PUT_LINE('.... Permanent');
          END IF;
          -- Online and Readwrite are together
          IF sysaux_not_online THEN
             DBMS_OUTPUT.PUT_LINE('WARNING:.... NOT Readwrite');
          ELSE 
             DBMS_OUTPUT.PUT_LINE('.... Readwrite');
          END IF;
          IF sysaux_not_local THEN
             DBMS_OUTPUT.PUT_LINE(
             '.... WARNING:  NOT ExtentManagementLocal');
          ELSE 
             DBMS_OUTPUT.PUT_LINE('.... ExtentManagementLocal');
          END IF;

          IF sysaux_not_auto THEN
             DBMS_OUTPUT.PUT_LINE(
             'WARNING:.... NOT SegmentSpaceManagementAuto');
          ELSE 
             DBMS_OUTPUT.PUT_LINE(
             '.... SegmentSpaceManagementAuto');
          END IF; 
      END IF;
   ELSE  -- SYSAUX tablespace does not exist
      IF display_xml THEN
          DBMS_OUTPUT.PUT_LINE('<SysauxTablespace present="false"/>');
          DBMS_OUTPUT.PUT_LINE('<Attributes>');
          DBMS_OUTPUT.PUT_LINE('<Size value="' ||
                      TO_CHAR(delta_sysaux) || '" unit="MB"/>');
          DBMS_OUTPUT.PUT_LINE('</Attributes>');
      ELSE
          DBMS_OUTPUT.PUT_LINE('--> New "SYSAUX" tablespace ');
          DBMS_OUTPUT.PUT_LINE(
             '.... minimum required size for database upgrade: '  ||
                   TO_CHAR(delta_sysaux) || ' MB');
      END IF;
   END IF;
   IF display_xml THEN
      DBMS_OUTPUT.PUT_LINE('</SYSAUXtbs>');
   ELSE
     DBMS_OUTPUT.PUT_LINE ('.');
   END IF;
END display_sysaux;

--------------------------- display_components -----------------------------

PROCEDURE display_components
IS
   ui VARCHAR2(10);
BEGIN
   IF display_xml THEN
      DBMS_OUTPUT.NEW_LINE;
      DBMS_OUTPUT.PUT_LINE('<Components>');
      DBMS_OUTPUT.PUT_LINE( 
         '<Component id ="Oracle Server" type="SERVER" cid="RDBMS">');
      DBMS_OUTPUT.PUT_LINE(
          '<CEP value="{ORACLE_HOME}/rdbms/admin/rdbmsup.sql"/>');
      DBMS_OUTPUT.PUT_LINE(
          '<SupportedOracleVersions value="8.1.7, 9.0.1, 9.2.0, 10.1.0, 10.2.0"/>');
      DBMS_OUTPUT.PUT_LINE(   
         '<OracleVersion value ="'|| db_version || '"/>'); 
      DBMS_OUTPUT.PUT_LINE('</Component>');

      FOR i IN 3 .. max_components LOOP
         IF cmp_info(i).processed THEN
         DBMS_OUTPUT.PUT_LINE('<Component id="' || cmp_info(i).cname ||
                              '" cid="' || cmp_info(i).cid || 
                              '" script="' || cmp_info(i).script || '">');
         DBMS_OUTPUT.PUT_LINE('<OracleVersion value="' ||
                               cmp_info(i).version || '"/>');
         DBMS_OUTPUT.PUT_LINE('</Component>');
     END IF;
   END LOOP;
   DBMS_OUTPUT.PUT_LINE('</Components>');

ELSE
    DBMS_OUTPUT.new_line;
    display_banner;
    DBMS_OUTPUT.PUT_LINE (
      'Components: [The following database components will be ' ||
      'upgraded or installed]'); 
    display_banner;
    FOR i IN 1..max_components LOOP
        IF cmp_info(i).processed THEN
            IF cmp_info(i).install THEN
               ui := '[install]';
            ELSE
               ui := '[upgrade]';
            END IF;
            DBMS_OUTPUT.PUT_LINE(
            '--> ' || rpad(cmp_info(i).cname, 28) || ' ' ||
                      rpad(ui, 10) || ' ' ||
                      rpad(cmp_info(i).status, 9)); 
            IF (cmp_info(i).cid = 'ORDIM') THEN
               DBMS_OUTPUT.PUT_LINE(
               '...The ''Oracle interMedia Image Accelerator'' is');
               DBMS_OUTPUT.PUT_LINE(
               '...required to be installed from the 10g Companion CD.');
            ELSIF (cmp_info(i).cid  = 'JAVAVM') THEN
               DBMS_OUTPUT.PUT_LINE(
               '...The ''JServer JAVA Virtual Machine'' JAccelerator (NCOMP)');
               DBMS_OUTPUT.PUT_LINE(
               '...is required to be installed from the 10g Companion CD.');
            ELSIF (cmp_info(i).cid  = 'WK') THEN
               DBMS_OUTPUT.PUT_LINE(
               '... To successfully upgrade Ultra Search, install it from');
               DBMS_OUTPUT.PUT_LINE(
               '... the 10g Companion CD.');
            ELSIF (cmp_info(i).cid  = 'OLS') THEN
               DBMS_OUTPUT.PUT_LINE(
               '... To successfully upgrade Oracle Label Security, perform  ');
               DBMS_OUTPUT.PUT_LINE(
               '... a Custom install and select the OLS option.');
            END IF;
        END IF;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE ('.');
END IF;

END display_components;

--------------------------- display_tablespaces -----------------------------
-- Display the names and sizes of all tablespaces in ts_info

PROCEDURE display_tablespaces
IS
BEGIN

   IF display_xml THEN
      DBMS_OUTPUT.PUT_LINE('<SystemResource>');
      DBMS_OUTPUT.PUT_LINE('<MinFreeSpace>');
      FOR i IN 1..max_ts LOOP
         IF ts_info(i).inc_by > 0 OR ts_info(i).addl > 0 THEN
            IF ts_info(i).fauto = FALSE THEN
               DBMS_OUTPUT.PUT_LINE(
                    '<DefaultTablespace value="' || ts_info(i).name ||
                 '"> <AdditionalSize size="' ||
                             TO_CHAR(ROUND(ts_info(i).inc_by)) ||
                             '" unit="MB"/>' ||
                 ' <TotalSize size="' ||
                             TO_CHAR(ROUND(ts_info(i).min)) ||
                             '" unit="MB"/>');
               DBMS_OUTPUT.PUT_LINE(' </DefaultTablespace>');
            ELSE 
               -- Autoextend is ON
               IF ts_info(i).inc_by > 0 THEN
                  DBMS_OUTPUT.PUT_LINE(
                        '<DefaultTablespace value="' || ts_info(i).name ||
                     '"> <Datafile name="' || ts_info(i).fname ||
                    '"/> <AdditionalSize size="' ||
                             TO_CHAR(ROUND(ts_info(i).inc_by)) ||
                             '" unit="MB"' ||
                    '/> <TotalSize size="' ||
                             TO_CHAR(ROUND(ts_info(i).min)) ||
                             '" unit="MB"/>');
                  DBMS_OUTPUT.PUT_LINE(
                     '<Autoextend value="ON"> <Next value="10" unit="MB"/>' ||
                    ' <Maxsize value="' ||
                             TO_CHAR(ROUND(ts_info(i).min)) ||
                             '" unit="MB"/> ' ||
                     '</Autoextend>');
                  DBMS_OUTPUT.PUT_LINE('</DefaultTablespace>');
               ELSIF ts_info(i).addl > 0 THEN
                  DBMS_OUTPUT.PUT_LINE(
                        '<DefaultTablespace value="' || ts_info(i).name ||
                     '"> <Datafile name="' || ts_info(i).fname ||
                    '"/> <AdditionalAlloc size="' ||
                             TO_CHAR(ROUND(ts_info(i).addl)) ||
                             '" unit="MB"/>');
                  DBMS_OUTPUT.PUT_LINE('</DefaultTablespace>');
               END IF;
            END IF;
         END IF;
      END LOOP;

      display_logfiles;
      DBMS_OUTPUT.PUT_LINE('</MinFreeSpace>');

      -- Display the DBUA required create rollback segment static tags
      display_crs_xml;
      DBMS_OUTPUT.PUT_LINE('</SystemResource>');

      -- Report the SYSAUX tablespace
      IF dbv NOT IN (101,102) THEN
         display_sysaux;
      END IF;

   ELSE -- display TEXT output
      display_banner;
      DBMS_OUTPUT.PUT_LINE(
           'Tablespaces: [make adjustments in the current environment]');
      display_banner;
      IF max_ts > 0 THEN
         FOR i IN 1..max_ts LOOP
           IF ts_info(i).inc_by = 0 THEN
              DBMS_OUTPUT.PUT_LINE(
                '--> ' || ts_info(i).name || 
                     ' tablespace is adequate for the upgrade.');
              DBMS_OUTPUT.PUT_LINE(
                '.... minimum required size: ' ||
                TO_CHAR(ROUND(ts_info(i).min)) || ' MB');

              IF ts_info(i) .addl > 0 THEN
                 DBMS_OUTPUT.PUT_LINE(
                     '.... AUTOEXTEND additional space required: ' ||
                     TO_CHAR(ROUND(ts_info(i).addl)) || ' MB');
              END IF;
           ELSE  -- need more space in tablespace
              DBMS_OUTPUT.PUT_LINE(
                'WARNING: --> ' || ts_info(i).name || 
                          ' tablespace is not large enough for the upgrade.');
              DBMS_OUTPUT.PUT_LINE(
                 '.... currently allocated size: ' ||
                  TO_CHAR(ROUND(ts_info(i).alloc)) || ' MB');
              DBMS_OUTPUT.PUT_LINE(
                 '.... minimum required size: ' ||
                  TO_CHAR(ROUND(ts_info(i).min)) || ' MB');
              DBMS_OUTPUT.PUT_LINE(
                 '.... increase current size by: ' ||
                  TO_CHAR(ROUND(ts_info(i).inc_by)) || ' MB');
              IF ts_info(i).fauto THEN
                 DBMS_OUTPUT.PUT_LINE(
                   '.... tablespace is AUTOEXTEND ENABLED.');
              ELSE 
                 DBMS_OUTPUT.PUT_LINE(
                  '.... tablespace is NOT AUTOEXTEND ENABLED.');
              END IF;    
           END IF; 
        END LOOP;

      DBMS_OUTPUT.PUT_LINE ('.');
      END IF;
   END IF;
END display_tablespaces;
 
------------------------------ display_rollback_segs ---------------------
-- Display information about public rollback segments

PROCEDURE display_rollback_segs
IS
  auto VARCHAR2(3);

BEGIN
   IF NOT display_xml THEN
      IF max_rs > 0 THEN
         display_banner;
         DBMS_OUTPUT.PUT_LINE('Rollback Segments: [make adjustments ' ||
                              'immediately prior to upgrading]');
         display_banner;
         -- Loop through the rs_info table
         FOR i IN 1..max_rs LOOP
            IF rs_info(i).auto > 0 THEN 
               auto:='ON'; 
            ELSE
               auto:='OFF'; 
            END IF;
            DBMS_OUTPUT.PUT_LINE(
                '--> ' || rs_info(i).seg_name || ' in tablespace ' || 
                          rs_info(i).tbs_name || ' is ' || 
                          rs_info(i).status ||
                          '; AUTOEXTEND is ' || auto);
            DBMS_OUTPUT.PUT_LINE(
                '.... currently allocated: ' || rs_info(i).inuse 
                      || 'K');
            DBMS_OUTPUT.PUT_LINE(
                '.... next extent size: ' || rs_info(i).next 
                      || 'K; max extents: ' || rs_info(i).max_ext);
         END LOOP;
         DBMS_OUTPUT.PUT_LINE(
               'WARNING: --> For the upgrade, use a large (minimum 70M) ' ||
                            'public rollback segment');
         IF max_rs >1 THEN
            DBMS_OUTPUT.PUT_LINE(
             'WARNING: --> Take smaller public rollback segments OFFLINE');
         END IF;
         DBMS_OUTPUT.PUT_LINE ('.');
      END IF;
   END IF;

END display_rollback_segs;

------------------------------- display_parameters ------------------------
-- Display any renamed, obsolete, and special parameters.

PROCEDURE display_parameters
IS

  changes_req BOOLEAN := FALSE;

BEGIN
  IF display_xml THEN
    DBMS_OUTPUT.PUT_LINE('<InitParams>');
    DBMS_OUTPUT.PUT_LINE('<Update>');

    -- minimum value parameters
    FOR i IN 1..max_mp LOOP
      IF mp(i).display THEN
        DBMS_OUTPUT.PUT_LINE('<Parameter name="' ||
           mp(i).name ||
           '" atleast="' ||
           TO_CHAR(ROUND(mp(i).newvalue)) ||
           '" type="NUMBER"/>');
      END IF;
    END LOOP;

    -- Parameters with new names
    FOR i IN 1..max_sp LOOP
       IF sp(i).db_match = TRUE AND
          sp(i).oldvalue IS NOT NULL THEN
          DBMS_OUTPUT.PUT_LINE(
             '<Parameter name="' || sp(i).newname ||
            '" setThis="' || sp(i).oldvalue || '" type="STRING"/>');
       END IF;
    END LOOP;

    -- Required values if missing
    FOR i IN 1..max_reqp LOOP
       IF reqp(i).db_match = FALSE THEN
          DBMS_OUTPUT.PUT_LINE('<Parameter name="' ||
           reqp(i).name ||
           '" setThis="' ||
           TO_CHAR(ROUND(reqp(i).newvalue)) ||
           '" type="NUMBER"/>');
       END IF;
    END LOOP;

    -- Display the minimum compatibility static tag
    IF dbv IN (817, 901, 920) THEN
       DBMS_OUTPUT.PUT_LINE(
        '<Parameter name="compatible" atleast="9.2.0" type="VERSION"/>');
    END IF;

    DBMS_OUTPUT.PUT_LINE('</Update>');

    -- Static tags for Migration and NonHandled go here (XML, only)
    DBMS_OUTPUT.PUT_LINE('<Migration>');
--    DBMS_OUTPUT.PUT_LINE('<Parameter name="optimizer_mode" value="choose"/>');
    DBMS_OUTPUT.PUT_LINE('</Migration>');

    DBMS_OUTPUT.PUT_LINE('<NonHandled>');
    DBMS_OUTPUT.PUT_LINE('<Parameter name="remote_listener"/>');
    DBMS_OUTPUT.PUT_LINE('</NonHandled>');

    -- Renamed Parameters
    DBMS_OUTPUT.PUT_LINE('<Rename>');
    FOR i IN 1..max_rp LOOP
       IF rp(i).db_match = TRUE THEN
          DBMS_OUTPUT.PUT_LINE(
           '<Parameter oldName="' || rp(i).oldname || 
                    '" newName="' || rp(i).newname || '"/>');
       END IF;
    END LOOP;  

    -- Display parameters that have a new name and a new value
    FOR i IN 1..max_sp LOOP
       IF sp(i).db_match = TRUE AND
          sp(i).oldvalue IS NULL THEN
          DBMS_OUTPUT.PUT_LINE('<Parameter oldName="' || sp(i).oldname ||
           '" newName="' || sp(i).newname ||
           '" newValue="' || sp(i).newvalue || '"/>');
       END IF;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('</Rename>');

    -- Display Obsolete Parameters to remove
    DBMS_OUTPUT.PUT_LINE('<Remove>');
    FOR i IN 1..max_op LOOP
       IF op(i).db_match = TRUE THEN
          DBMS_OUTPUT.PUT_LINE('<Parameter name="' ||
           op(i).name || '"/>');
       END IF;
    END LOOP;  
    DBMS_OUTPUT.PUT_LINE('</Remove>');
    DBMS_OUTPUT.PUT_LINE('</InitParams>');

  ELSE  -- Display TEXT parameter output
    display_banner;
    DBMS_OUTPUT.PUT_LINE(
      'Update Parameters: [Update Oracle Database 10.2 init.ora or spfile]');
    display_banner;

    -- Display the minimum compatibility static tag
    IF dbv IN (817, 901) OR
       (dbv = 920 AND SUBSTR(db_version,1,5) != '9.2.0') THEN
       DBMS_OUTPUT.PUT_LINE('WARNING: --> "compatible" must be '||
               'set to at least 9.2.0');
       changes_req := TRUE;
    END IF;

    -- parameters with minimum values
    FOR i IN 1..max_mp LOOP
      IF mp(i).display THEN
        changes_req := TRUE;
        IF mp(i).oldvalue IS NULL THEN
           DBMS_OUTPUT.PUT_LINE ('WARNING: --> "'||mp(i).name ||
               '" is not currently defined and needs a value of at least ' ||
                  TO_CHAR(ROUND(mp(i).newvalue)));

        ELSE
           IF mp(i).oldvalue < mp(i).newvalue THEN
              DBMS_OUTPUT.PUT_LINE(
                     'WARNING: --> "'||mp(i).name ||
                     '" needs to be increased to at least ' ||
                      TO_CHAR(ROUND(mp(i).newvalue)));
           ELSE
              DBMS_OUTPUT.PUT_LINE(
                  '--> "'||mp(i).name || '" is already at ' ||
                 TO_CHAR(ROUND(mp(i).oldvalue)) ||
                 '; calculated minimum value is ' ||
                 TO_CHAR(ROUND(mp(i).newvalue)));
           END IF;
        END IF; -- null oldvalue
      END IF; -- display
    END LOOP;

    -- Required values if missing
    FOR i IN 1..max_reqp LOOP
       IF reqp(i).db_match = FALSE THEN
          changes_req := TRUE;
          DBMS_OUTPUT.PUT_LINE('WARNING: --> "' ||
           reqp(i).name || '" is not defined and must have a value=' ||
           TO_CHAR(ROUND(reqp(i).newvalue)));
       END IF;
    END LOOP;

    IF  NOT changes_req THEN
       DBMS_OUTPUT.PUT_LINE(
           '-- No update parameter changes are required.');
    END IF;
    DBMS_OUTPUT.PUT_LINE('.');     

    display_banner;
    DBMS_OUTPUT.PUT_LINE(
    'Deprecated Parameters: [Update Oracle Database 10.2 init.ora or spfile]');
    display_banner;
    changes_req := FALSE;

    -- renamed parameters
    FOR i IN 1..max_rp LOOP
       IF rp(i).db_match = TRUE THEN
          changes_req := TRUE;
          DBMS_OUTPUT.PUT_LINE('WARNING: --> "' || rp(i).oldname ||
           '" new name is "' || rp(i).newname || '"');
       END IF;
    END LOOP;

    -- renamed parameters with new values
    FOR i IN 1..max_sp LOOP
       IF sp(i).db_match = TRUE THEN
          changes_req := TRUE;
          IF sp(i).oldvalue IS NULL THEN
             DBMS_OUTPUT.PUT_LINE('WARNING: --> "' || sp(i).oldname ||
               '" new name is "' || sp(i).newname ||
               '" new value is "' || sp(i).newvalue || '"');
          ELSE
             DBMS_OUTPUT.PUT_LINE('WARNING: --> "' || sp(i).oldname ||
               '" old value was "' || sp(i).oldvalue || '";' ||
               '" new name is "' || sp(i).newname ||
               '" new value is "' || sp(i).newvalue || '"');
          END IF;
       END IF;
    END LOOP;

    IF  NOT changes_req THEN
       DBMS_OUTPUT.PUT_LINE(
       '-- No deprecated parameters found. No changes are required.');
    END IF;
    DBMS_OUTPUT.PUT_LINE('.');

    display_banner;
    DBMS_OUTPUT.PUT_LINE(
     'Obsolete Parameters: [Update Oracle Database 10.2 init.ora or spfile]');
    display_banner;
    changes_req := FALSE;

    -- obsolete (removed) parameters
    FOR i IN 1..max_op LOOP
       IF op(i).db_match = TRUE THEN
          changes_req := TRUE;
          DBMS_OUTPUT.PUT_LINE('--> "' || op(i).name || '"');
       END IF;
    END LOOP;  
    IF NOT changes_req THEN
       DBMS_OUTPUT.PUT_LINE(
       '-- No obsolete parameters found. No changes are required');
    END IF;

    DBMS_OUTPUT.PUT_LINE('.');
  END IF;
END display_parameters;

----------------- display_misc_warnings ------------------------------

procedure display_misc_warnings
IS

BEGIN
  
   IF display_xml THEN
      DBMS_OUTPUT.PUT_LINE('<Warnings>');
   
      IF version_mismatch THEN
          DBMS_OUTPUT.PUT_LINE('<warning name="VERSION_MISMATCH"/>');
      END IF;
   
      IF cluster_dbs THEN
          DBMS_OUTPUT.PUT_LINE('<warning name="CLUSTER_DATABASE"/>');
      END IF;

      IF dip_user_exists THEN
           DBMS_OUTPUT.PUT_LINE('<warning name="DIP_USER_PRESENT"/>');
      END IF;

      IF nls_al24utffss THEN
          DBMS_OUTPUT.PUT_LINE(
            '<warning name="DESUPPORTED_CHARSET_AL24UTFFSS"/>');
      END IF;

      IF utf8_al16utf16 THEN
          DBMS_OUTPUT.PUT_LINE(
            '<warning name="NCHAR_TYPE_NOT_SUPP"/>');
      END IF;

      IF owm_replication THEN
          DBMS_OUTPUT.PUT_LINE('<warning name="WMSYS_REPLICATION_PRESENT"/>');
      END IF;

      IF dblinks  THEN
          DBMS_OUTPUT.PUT_LINE('<warning name="DBLINKS_WITH_PASSWORDS"/>');
      END IF;

      IF cdc_data THEN
          DBMS_OUTPUT.PUT_LINE('<warning name="CDC_CHANGE_SOURCE"/>');
      END IF;

      IF connect_role THEN
          DBMS_OUTPUT.PUT_LINE('<warning name="CONNECT_ROLE_IN_USE"/>');
      END IF;

      IF invalid_objs THEN
          DBMS_OUTPUT.PUT_LINE('<warning name="INVALID_OBJECTS_EXIST"/>');
      END IF;

      IF ssl_users THEN
          DBMS_OUTPUT.PUT_LINE('<warning name="SSL_USERS_EXIST"/>');
      END IF;

      IF timezone_v2 THEN
          DBMS_OUTPUT.PUT_LINE('<warning name="WITH_TIME_ZONES_EXIST"/>');
      END IF;

      IF stale_stats THEN
          DBMS_OUTPUT.PUT_LINE('<warning name="STALE_STATISTICS"/>');
      END IF;

      DBMS_OUTPUT.PUT_LINE('</Warnings>');

      IF post_upgrade THEN
         DBMS_OUTPUT.PUT_LINE('<Post_Upgrade>');
         DBMS_OUTPUT.PUT_LINE
             ('<script name="{ORACLE_HOME}/rdbms/admin/olstrig.sql"/>');
         DBMS_OUTPUT.PUT_LINE('</Post_Upgrade>');
      END IF;

   ELSE
      IF version_mismatch or cluster_dbs OR dip_user_exists OR 
         nls_al24utffss OR ssl_users OR timezone_v2 OR stale_stats OR
         utf8_al16utf16 OR owm_replication OR dblinks OR connect_role OR 
         invalid_objs OR cdc_data or post_upgrade THEN
            display_banner;
            DBMS_OUTPUT.PUT_LINE('Miscellaneous Warnings');
            display_banner;
      ELSE
         RETURN;
      END IF;

      IF version_mismatch THEN
         DBMS_OUTPUT.PUT_LINE(
             'WARNING: --> The database has not been patched to release ' ||
             db_version || '.');
         DBMS_OUTPUT.PUT_LINE('... Run catpatch.sql prior to upgrading.');
      END IF;

      IF cluster_dbs THEN
         DBMS_OUTPUT.PUT_LINE(
             'WARNING: --> The "cluster_database" parameter '||
             'is currently "TRUE" and must be set to "FALSE" prior to ' ||
             'running the upgrade.');
      END IF;

      IF dip_user_exists THEN
         DBMS_OUTPUT.PUT_LINE('WARNING: --> "DIP" user found in database.');
         DBMS_OUTPUT.PUT_LINE(
             '* This is a generic account used for '||
             'connecting to ');
         DBMS_OUTPUT.PUT_LINE(
            '* the Database when processing DIP ' ||
             'callback functions.');
         DBMS_OUTPUT.PUT_LINE(
             '* Oracle may add additional privileges to this account '||
             'during the upgrade.');
      END IF;

      IF nls_al24utffss THEN
         DBMS_OUTPUT.PUT_LINE('WARNING: --> "nls_characterset" has ' ||
               ' "AL24UTFFSS" character set.');
         DBMS_OUTPUT.PUT_LINE(
             ' * The database must be converted to a supported character ' ||
             'set prior to upgrading.');
      END IF;

      IF utf8_al16utf16 THEN
         DBMS_OUTPUT.PUT_LINE('WARNING: --> Your database is using an ' ||
                     'obsolete NCHAR character set.');
         DBMS_OUTPUT.PUT_LINE(
             'In Oracle Database 10g, the NCHAR data types ' ||
             '(NCHAR, NVARCHAR2, and NCLOB)');
         DBMS_OUTPUT.PUT_LINE('are limited to the Unicode character ' ||
              'set encoding (UTF8 and AL16UTF16), only.');
         DBMS_OUTPUT.PUT_LINE('See "Database Character Sets" in chapter 5' ||
             ' of the Oracle 10g Database Upgrade');
         DBMS_OUTPUT.PUT_LINE(' Guide for further information. ' );
      END IF;

      IF owm_replication THEN
         DBMS_OUTPUT.PUT_LINE(
           'WARNING: --> Workspace Manager replication is in use.');
         DBMS_OUTPUT.PUT_LINE(
           '.... Drop OWM replication support before upgrading:');
         DBMS_OUTPUT.PUT_LINE(
           '.... EXECUTE dbms_wm.DropReplicationSupport;');
      END IF;

      IF dblinks  THEN
         DBMS_OUTPUT.PUT_LINE(
           'WARNING: --> Passwords exist in some database links.');
         DBMS_OUTPUT.PUT_LINE(
           '.... Passwords will be encrypted during the upgrade.');
         DBMS_OUTPUT.PUT_LINE(
          '.... Downgrade of database links with passwords is not supported.');
      END IF;

      IF cdc_data THEN
         DBMS_OUTPUT.PUT_LINE(
           'WARNING: --> CDC change sources exist; for full 10.2 support, alter ');
         DBMS_OUTPUT.PUT_LINE(
           '.... the change source on the staging database after the upgrade.');
      END IF;

      IF connect_role THEN
         DBMS_OUTPUT.PUT_LINE(
           'WARNING: --> Deprecated CONNECT role granted to some user/roles.');
         DBMS_OUTPUT.PUT_LINE(
           '.... CONNECT role after upgrade has only CREATE SESSION privilege.');
      END IF;

      IF timezone_v2 THEN
         DBMS_OUTPUT.PUT_LINE(
         'WARNING: --> Database contains TIMESTAMP WITH TIME ZONE datatypes.');
         DBMS_OUTPUT.PUT_LINE(
           '.... Refer to the 10g Upgrade Guide to identify affected columns');
         DBMS_OUTPUT.PUT_LINE(
           '.... before upgrading the database.');
      END IF;

      IF stale_stats THEN
         DBMS_OUTPUT.PUT_LINE(
         'WARNING: --> Database contains stale optimizer statistics.');
         DBMS_OUTPUT.PUT_LINE(
           '.... Refer to the 10g Upgrade Guide for instructions to update' );
         DBMS_OUTPUT.PUT_LINE(
           '.... statistics prior to upgrading the database.');
         DBMS_OUTPUT.PUT_LINE(
           '.... Component Schemas with stale statistics:');
         -- list schemas with stale statistics
         SYS_todo := TRUE;
         FOR i IN 1..max_comps LOOP 
           IF cmp_info(i).processed THEN
             BEGIN
               SELECT NULL INTO p_null 
               FROM sys.tab$ t, sys.obj$ o, sys.user$ u
               WHERE u.name = cmp_info(i).schema AND
                 t.obj# = o.obj# and o.owner# = u.user# AND
                 bitand(t.flags,16) != 16 AND -- not analyzed
                 -- we don't collect stats for the following types.
                 bitand(t.property,512) != 512 AND  -- not an iot overflow
                 bitand(t.flags,536870912) != 536870912 AND  
                                                    -- not an iot mapping table
                 bitand(t.property,2147483648) != 2147483648 AND 
                                                    -- not external table
                 bitand(o.flags, 128) != 128 AND    -- not in recycle bin
                 NOT (bitand(o.flags, 16) = 16 AND o.name like 'DR$%') AND 
                                                    -- no CTX
                 bitand(t.property,4194304) != 4194304 AND 
                                                    -- no global temp tables
                 bitand(t.property,8388608) != 8388608 AND 
                                                    -- no session temp tables
                 NOT EXISTS  -- not an mv log
                    (SELECT * FROM sys.mlog$
                     WHERE (mowner = u.name AND log = o.name) OR
                           (mowner = u.name AND temp_log = o.name)) AND
                 ROWNUM <= 1;
               IF cmp_info(i).schema != 'SYS' OR SYS_todo THEN
                  DBMS_OUTPUT.PUT_LINE('....   ' || cmp_info(i).schema);
               END IF;
               IF cmp_info(i).schema = 'SYS' THEN
                  SYS_todo := FALSE;
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN NULL;
            END;
           END IF;
         END LOOP;
      END IF;

      IF invalid_objs THEN
         DBMS_OUTPUT.PUT_LINE(
           'WARNING: --> Database contains INVALID objects prior to upgrade.');
         FOR obj IN (SELECT owner, count(*) AS num FROM DBA_OBJECTS
                     WHERE status = 'INVALID' AND 
                           object_name NOT LIKE 'BIN$%' 
                     GROUP BY owner) LOOP
             DBMS_OUTPUT.PUT_LINE(
                '.... USER ' || obj.owner || ' has ' || obj.num || 
                ' INVALID objects.');
         END LOOP;
      END IF;

      IF ssl_users THEN
         DBMS_OUTPUT.PUT_LINE(
         'WARNING: --> Database contains globally authenticated users.');
         DBMS_OUTPUT.PUT_LINE(
           '.... Refer to the 10g Upgrade Guide to upgrade SSL users.');
      END IF;

      IF post_upgrade THEN
        DBMS_OUTPUT.PUT_LINE(
           'WARNING: --> OLS requires post-upgrade action to update policy triggers.');
         DBMS_OUTPUT.PUT_LINE(
           '.... Run rdbms/admin/olstrig.sql after the upgrade.');
      END IF;
 
      DBMS_OUTPUT.PUT_LINE('.');
   END IF;

END display_misc_warnings;

--------------------------- pvalue_to_number --------------------------------
-- This function converts a parameter string to a number. The function takes
-- into account that the parameter string may have a 'K' or 'M' multiplier
-- character.
FUNCTION pvalue_to_number (value_string VARCHAR2) RETURN NUMBER
IS
  ilen NUMBER;
  pvalue_number NUMBER;

BEGIN
    -- How long is the input string?
    ilen := LENGTH ( value_string );

    -- Is there a 'K' or 'M' in last position?
    IF SUBSTR(UPPER(value_string), ilen, 1) = 'K' THEN
         RETURN (1024 * TO_NUMBER (SUBSTR (value_string, 1, ilen-1)));

    ELSIF SUBSTR(UPPER(value_string), ilen, 1) = 'M' THEN
         RETURN (1024 * 1024 * TO_NUMBER (SUBSTR (value_string, 1, ilen-1)));
    END IF;

    -- A multiplier wasn't found. Simply convert this string to a number.
    RETURN (TO_NUMBER (value_string));

 END pvalue_to_number;

-- *****************************************************************
-- --------------------- MAIN PROGRAM ------------------------------
-- *****************************************************************
 
BEGIN

    -- Increase SERVEROUTPUT limit.
    DBMS_OUTPUT.ENABLE(29000);

    -- Check for SYSDBA
    SELECT USER INTO p_user
       FROM DUAL;
    IF p_user != 'SYS' THEN
        RAISE_APPLICATION_ERROR (-20000,
           'This script must be run AS SYSDBA');
    END IF;

    -- Turn on diagnostic collection
    BEGIN
        SELECT NULL INTO p_null FROM obj$
        WHERE owner#=0 AND type#=2 AND name='PUIU$DATA';
        collect_diag := TRUE;
    EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
    END;
 
-- *****************************************************************
-- Collect Database Information
-- *****************************************************************

   SELECT name    INTO db_name    from v$database;
   SELECT version INTO db_version from v$instance;
   SELECT value   INTO db_compat  from v$parameter
          WHERE name = 'compatible';
   SELECT value   INTO db_block_size FROM v$parameter
          WHERE name = 'db_block_size';

   vers  := SUBSTR(db_version,1,6);   -- get 3 digit version
   patch := SUBSTR(db_version,1,8);   -- get 4 digit version

   IF vers = '10.2.0' AND 
      SUBSTR(db_version,1,8) = utlu_version THEN -- rerun or inplace
      BEGIN -- rerun or inplace upgrade since instance is current version
         EXECUTE IMMEDIATE 'SELECT version, prv_version FROM registry$ 
                            WHERE cid = ''CATPROC'''
                 INTO db_dict_version, db_prev_version;
         IF db_dict_version = db_version THEN  -- catproc upgraded, rerun 
            rerun := TRUE;
            vers := substr(db_prev_version,1,6);   -- use prev catproc version 
         ELSIF substr(db_dict_version,1,6) IN ('10.1.0', '10.2.0') THEN
            inplace := TRUE;
            vers := substr(db_dict_version,1,6);   -- use CATPROC version 
         END IF;
         
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            rerun := TRUE;  -- registry$ exists, but no CATPROC entry
         WHEN OTHERS THEN
            IF SQLCODE = -942 THEN  
               rerun := TRUE;  -- registry$ does not exist
            ELSE
              RAISE;
            END IF;
      END;
   END IF;

   IF rerun THEN
      IF display_xml THEN
         DBMS_OUTPUT.PUT_LINE('<RDBMSUP version="10.2">');
         DBMS_OUTPUT.PUT_LINE(
             '<SupportedOracleVersions value="8.1.7, 9.0.1, 9.2.0, 10.1.0, 10.2.0"/>');
         display_database;
         DBMS_OUTPUT.PUT_LINE(
            '<OracleVersion rerun="TRUE"/>');
         DBMS_OUTPUT.PUT_LINE('<Components>');
         IF vers IS NOT NULL THEN  -- If null, then is a newly created DB
            DBMS_OUTPUT.PUT_LINE(
               '<Component id ="Oracle Server" type="SERVER" cid="RDBMS">');
            DBMS_OUTPUT.PUT_LINE(
             '<CEP value="{ORACLE_HOME}/rdbms/admin/rdbmsup.sql"/>');
            DBMS_OUTPUT.PUT_LINE(
             '<SupportedOracleVersions value="8.1.7, 9.0.1, 9.2.0, 10.1.0, 10.2.0"/>');
            DBMS_OUTPUT.PUT_LINE(
              '<OracleVersion value ="'|| db_version || '"/>');
            DBMS_OUTPUT.PUT_LINE('</Component>');
         END IF;
         DBMS_OUTPUT.PUT_LINE('</Components>');
         DBMS_OUTPUT.PUT_LINE('</RDBMSUP>');
      ELSE
         DBMS_OUTPUT.PUT_LINE(
             'Oracle Database 10.2 Upgrade Information Utility    ' ||
             TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS'));
         DBMS_OUTPUT.PUT_LINE('.');
         display_database;
         DBMS_OUTPUT.PUT_LINE('Database already upgraded; to rerun upgrade ' ||
             'use rdbms/admin/catupgrd.sql.');
      END IF;
   RETURN;
   END IF;

   IF patch = '8.1.7.4.' THEN
      dbv := 817;
   ELSIF patch in ('9.0.1.4.','9.0.1.5.') THEN 
      dbv := 901;
   ELSIF vers = '9.2.0.' AND 
         patch NOT IN ('9.2.0.1.', '9.2.0.2.', '9.2.0.3.') THEN 
      dbv := 920;
   ELSIF vers = '10.1.0' THEN 
      dbv := 101;
   ELSIF vers = '10.2.0' THEN 
      dbv := 102;
   ELSE
        RAISE_APPLICATION_ERROR (-20000,
           'Version ' || db_version || 
           ' not supported for upgrade to release 10.2.0');
   END IF;


-- *****************************************************************
-- START of Constant Data
-- *****************************************************************

-- *****************************************************************
-- Constant Initialization Parameter Data
-- *****************************************************************

-- Load Obsolete parameters

   -- Obsolete initialization parameters in release 8.0 --
   idx:=0;
   store_removed(idx,'checkpoint_process');
   store_removed(idx,'fast_cache_flush');
   store_removed(idx,'gc_db_locks');
   store_removed(idx,'gc_freelist_groups');
   store_removed(idx,'gc_rollback_segments');
   store_removed(idx,'gc_save_rollback_locks');
   store_removed(idx,'gc_segments');
   store_removed(idx,'gc_tablespaces');
   store_removed(idx,'io_timeout');
   store_removed(idx,'init_sql_files');
   store_removed(idx,'ipq_address');
   store_removed(idx,'ipq_net');
   store_removed(idx,'lm_domains');
   store_removed(idx,'lm_non_fault_tolerant');
   store_removed(idx,'mls_label_format');
   store_removed(idx,'optimizer_parallel_pass');
   store_removed(idx,'parallel_default_max_scans');
   store_removed(idx,'parallel_default_scan_size');
   store_removed(idx,'post_wait_device');
   store_removed(idx,'sequence_cache_hash_buckets');
   store_removed(idx,'unlimited_rollback_segments');
   store_removed(idx,'use_readv');
   store_removed(idx,'use_sigio');
   store_removed(idx,'v733_plans_enabled');

   -- Obsolete in 8.1
   store_removed(idx,'allow_partial_sn_results');
   store_removed(idx,'arch_io_slaves');
   store_removed(idx,'b_tree_bitmap_plans');
   store_removed(idx,'backup_disk_io_slaves');
   store_removed(idx,'cache_size_threshold');
   store_removed(idx,'cleanup_rollback_entries');
   store_removed(idx,'close_cached_open_cursors');
   store_removed(idx,'complex_view_merging');
   store_removed(idx,'db_block_checkpoint_batch');
   store_removed(idx,'db_block_lru_extended_statistics');
   store_removed(idx,'db_block_lru_statistics');
   store_removed(idx,'db_file_simultaneous_writes');
   store_removed(idx,'delayed_logging_block_cleanouts');
   store_removed(idx,'discrete_transactions_enabled');
   store_removed(idx,'distributed_recovery_connection_hold_time');
   store_removed(idx,'ent_domain_name');
   store_removed(idx,'fast_full_scan_enabled');
   store_removed(idx,'freeze_DB_for_fast_instance_recovery');
   store_removed(idx,'gc_latches');
   store_removed(idx,'gc_lck_procs');
   store_removed(idx,'job_queue_keep_connections');
   store_removed(idx,'large_pool_min_alloc');
   store_removed(idx,'lgwr_io_slaves');
   store_removed(idx,'lm_locks');
   store_removed(idx,'lm_procs');
   store_removed(idx,'lm_ress');
   store_removed(idx,'lock_sga_areas');
   store_removed(idx,'log_archive_buffer_size');
   store_removed(idx,'log_archive_buffers');
   store_removed(idx,'log_block_checksum');
   store_removed(idx,'log_files');
   store_removed(idx,'log_simultaneous_copies');
   store_removed(idx,'log_small_entry_max_size');
   store_removed(idx,'mts_rate_log_size');
   store_removed(idx,'mts_rate_scale');
   store_removed(idx,'ogms_home');
   store_removed(idx,'ops_admin_group');
   store_removed(idx,'optimizer_search_limit');
   store_removed(idx,'parallel_default_max_instances');
   store_removed(idx,'parallel_min_message_pool');
   store_removed(idx,'parallel_server_idle_time');
   store_removed(idx,'parallel_transaction_resource_timeout');
   store_removed(idx,'push_join_predicate');
   store_removed(idx,'reduce_alarm');
   store_removed(idx,'row_cache_cursors');
   store_removed(idx,'sequence_cache_entries');
   store_removed(idx,'sequence_cache_hash_buckets');
   store_removed(idx,'shared_pool_reserved_min_alloc');
   store_removed(idx,'snapshot_refresh_interval');
   store_removed(idx,'snapshot_refresh_keep_connections');
   store_removed(idx,'snapshot_refresh_processes');
   store_removed(idx,'sort_direct_writes');
   store_removed(idx,'sort_read_fac');
   store_removed(idx,'sort_spacemap_size');
   store_removed(idx,'sort_write_buffer_size');
   store_removed(idx,'sort_write_buffers');
   store_removed(idx,'spin_count');
   store_removed(idx,'temporary_table_locks');
   store_removed(idx,'use_ism');

   -- Obsolete in 9.0.1
   store_removed(idx,'always_anti_join');
   store_removed(idx,'always_semi_join');
   store_removed(idx,'db_block_lru_latches');
   store_removed(idx,'db_block_max_dirty_target');
   store_removed(idx,'gc_defer_time');
   store_removed(idx,'gc_releasable_locks');
   store_removed(idx,'gc_rollback_locks');
   store_removed(idx,'hash_multiblock_io_count');
   store_removed(idx,'instance_nodeset');
   store_removed(idx,'job_queue_interval');
   store_removed(idx,'ops_interconnects');
   store_removed(idx,'optimizer_percent_parallel');
   store_removed(idx,'sort_multiblock_read_count');
   store_removed(idx,'text_enable');

   -- Obsolete in 9.2
   store_removed(idx,'distributed_transactions');
   store_removed(idx,'max_transaction_branches');
   store_removed(idx,'parallel_broadcast_enabled');
   store_removed(idx,'standby_preserves_names');

   -- Obsolete in 10.1 (mts_ renames commented out)
   store_removed(idx,'dblink_encrypt_login');
   store_removed(idx,'hash_join_enabled');
   store_removed(idx,'log_parallelism');
   store_removed(idx,'max_rollback_segments');
--   store_removed(idx,'mts_circuits');
--   store_removed(idx,'mts_dispatchers');
   store_removed(idx,'mts_listener_address');
--   store_removed(idx,'mts_max_dispatchers');
--   store_removed(idx,'mts_max_servers');
   store_removed(idx,'mts_multiple_listeners');
--   store_removed(idx,'mts_servers');
   store_removed(idx,'mts_service');
--   store_removed(idx,'mts_sessions');
   store_removed(idx,'optimizer_max_permutations');
   store_removed(idx,'oracle_trace_collection_name');
   store_removed(idx,'oracle_trace_collection_path');
   store_removed(idx,'oracle_trace_collection_size');
   store_removed(idx,'oracle_trace_enable');
   store_removed(idx,'oracle_trace_facility_name');
   store_removed(idx,'oracle_trace_facility_path');
   store_removed(idx,'partition_view_enabled');
   store_removed(idx,'plsql_native_c_compiler');
   store_removed(idx,'plsql_native_linker');
   store_removed(idx,'plsql_native_make_file_name');
   store_removed(idx,'plsql_native_make_utility');
   store_removed(idx,'row_locking');
   store_removed(idx,'serializable');
   store_removed(idx,'transaction_auditing');
   store_removed(idx,'undo_suppress_errors');

   -- Deprecated in 10.1, no new value
   store_removed(idx,'global_context_pool_size');
   store_removed(idx,'log_archive_start');
   store_removed(idx,'max_enabled_roles');
   store_removed(idx,'parallel_automatic_tuning');

   store_removed(idx,'_average_dirties_half_life');
   store_removed(idx,'_compatible_no_recovery');
   store_removed(idx,'_db_no_mount_lock');
   store_removed(idx,'_lm_direct_sends');
   store_removed(idx,'_lm_multiple_receivers');
   store_removed(idx,'_lm_statistics');
   store_removed(idx,'_oracle_trace_events');
   store_removed(idx,'_oracle_trace_facility_version');
   store_removed(idx,'_seq_process_cache_const');

   -- Obsolete in 10.2  
   store_removed(idx,'enqueue_resources');

   -- Deprecated, but not renamed in 10.2
   store_removed(idx,'logmnr_max_persistent_sessions');
   store_removed(idx,'remote_archive_enable');
   store_removed(idx,'serial_reuse');
   store_removed(idx,'sql_trace');


   store_removed(idx,'cpu_count');  -- should not be set in initialization

   max_op := idx; 

-- Load Renamed parameters

   -- Initialization Parameters Renamed in Release 8.0 --
   idx:=0;
   store_renamed(idx,'async_read','disk_asynch_io');
   store_renamed(idx,'async_write','disk_asynch_io');
   store_renamed(idx,'ccf_io_size','db_file_direct_io_count');
   store_renamed(idx,'db_file_standby_name_convert','db_file_name_convert');
   store_renamed(idx,'db_writers','dbwr_io_slaves');
   store_renamed(idx,'log_file_standby_name_convert',
                     'log_file_name_convert');
   store_renamed(idx,'snapshot_refresh_interval','job_queue_interval');

   -- Initialization Parameters Renamed in Release 8.1.4 --
   store_renamed(idx,'mview_rewrite_enabled','query_rewrite_enabled');
   store_renamed(idx,'rewrite_integrity','query_rewrite_integrity');

   -- Initialization Parameters Renamed in Release 8.1.5 --
   store_renamed(idx,'nls_union_currency','nls_dual_currency');
   store_renamed(idx,'parallel_transaction_recovery',
                     'fast_start_parallel_rollback');

   -- Initialization Parameters Renamed in Release 9.0.1 --
   store_renamed(idx,'fast_start_io_target','fast_start_mttr_target');
   store_renamed(idx,'mts_circuits','circuits');
   store_renamed(idx,'mts_dispatchers','dispatchers');
   store_renamed(idx,'mts_max_dispatchers','max_dispatchers');
   store_renamed(idx,'mts_max_servers','max_shared_servers');
   store_renamed(idx,'mts_servers','shared_servers');
   store_renamed(idx,'mts_sessions','shared_server_sessions');
   store_renamed(idx,'parallel_server','cluster_database');
   store_renamed(idx,'parallel_server_instances',
                     'cluster_database_instances');

   -- Initialization Parameters Renamed in Release 9.2 --
   store_renamed(idx,'drs_start','dg_broker_start');

   -- Initialization Parameters Renamed in Release 10.1 --
   store_renamed(idx,'buffer_pool_keep','db_keep_cache_size');
   store_renamed(idx,'buffer_pool_recycle','db_recycle_cache_size');
   store_renamed(idx,'lock_name_space','db_unique_name');

   -- Initialization Parameters Renamed in Release 10.2 --
   -- none as of 4/1/05

   max_rp := idx; 

-- Initialize special initialization parameters

   idx := 0;
   store_special(idx,'rdbms_server_dn',NULL,'ldap_directory_access','SSL');
   store_special(idx,'plsql_compiler_flags','INTERPRETED',
                     'plsql_code_type','INTERPRETED');
   store_special(idx,'plsql_compiler_flags','NATIVE',
                     'plsql_code_type','NATIVE');
   store_special(idx,'plsql_compiler_flags','DEBUG',
                     'plsql_debug','TRUE');
   store_special(idx,'plsql_compiler_flags','NON_DEBUG',
                     'plsql_debug','FALSE');

   max_sp := idx;   

-- Initialization parameter with required values if missing
   reqp(1).name:= 'db_block_size';
   reqp(1).newvalue := 2048;

   max_reqp :=1;

-- Initialize parameters with minimum values

   idx := 0;
   store_minvalue(idx,'sga_target',      244*1024*1024); --  244 MB 
   tg_idx := idx;
   store_minvalue(idx,'shared_pool_size',160*1024*1024); -- 160 MB
   sp_idx := idx;  -- save the value for isga calculation
   store_minvalue(idx,'java_pool_size',   64*1024*1024); -- 64 MB
   jv_idx := idx;
   store_minvalue(idx,'streams_pool_size',    50331648); --  48 MB
   st_idx := idx; 
   store_minvalue(idx,'db_cache_size',    50331648); --  48 MB
   cs_idx := idx;
   store_minvalue(idx,'large_pool_size',       8388608); --   8 MB
   lp_idx := idx;
   store_minvalue(idx,'pga_aggregate_target', 25165824); --  24 MB
   pg_idx := idx;
   store_minvalue(idx,'session_max_open_files', 20); -- 20 open files

   max_mp := idx;

-- *****************************************************************
-- Store Constant Component Data
-- *****************************************************************

-- Clear all variable component data
   FOR i IN 1..max_comps LOOP
       cmp_info(i).sys_kbytes:=     0;
       cmp_info(i).sysaux_kbytes:=  0;
       cmp_info(i).def_ts_kbytes:=  0;
       cmp_info(i).ins_sys_kbytes:= 0;
       cmp_info(i).ins_def_kbytes:= 0;
       cmp_info(i).def_ts     := NULL;
       cmp_info(i).processed  := FALSE;
       cmp_info(i).install    := FALSE;
   END LOOP;

-- Load component id and name
   cmp_info(catalog).cid := 'CATALOG';
   cmp_info(catalog).cname := 'Oracle Catalog Views';
   cmp_info(catproc).cid := 'CATPROC';
   cmp_info(catproc).cname := 'Oracle Packages and Types';
   cmp_info(javavm).cid := 'JAVAVM';
   cmp_info(javavm).cname := 'JServer JAVA Virtual Machine';
   cmp_info(xml).cid := 'XML';
   cmp_info(xml).cname := 'Oracle XDK for Java';
   cmp_info(catjava).cid := 'CATJAVA';
   cmp_info(catjava).cname := 'Oracle Java Packages';
   cmp_info(xdb).cid := 'XDB';
   cmp_info(xdb).cname := 'Oracle XML Database';
   cmp_info(rac).cid := 'RAC';
   cmp_info(rac).cname := 'Real Application Clusters';
   cmp_info(owm).cid := 'OWM';
   cmp_info(owm).cname := 'Oracle Workspace Manager';
   cmp_info(odm).cid := 'ODM';
   cmp_info(odm).cname := 'Oracle Data Mining';
   cmp_info(mgw).cid := 'MGW';
   cmp_info(mgw).cname := 'Messaging Gateway';
   cmp_info(aps).cid := 'APS';
   cmp_info(aps).cname := 'OLAP Analytic Workspace';
   cmp_info(amd).cid := 'AMD';
   cmp_info(amd).cname := 'OLAP Catalog';
   cmp_info(xoq).cid := 'XOQ';
   cmp_info(xoq).cname := 'Oracle OLAP API';
   cmp_info(ordim).cid := 'ORDIM';
   cmp_info(ordim).cname := 'Oracle interMedia';
   cmp_info(sdo).cid := 'SDO';
   cmp_info(sdo).cname := 'Spatial';
   cmp_info(context).cid := 'CONTEXT';
   cmp_info(context).cname := 'Oracle Text';
   cmp_info(wk).cid := 'WK';
   cmp_info(wk).cname := 'Oracle Ultra Search';
   cmp_info(ols).cid := 'OLS';
   cmp_info(ols).cname := 'Oracle Label Security';
   cmp_info(exf).cid := 'EXF';
   cmp_info(exf).cname := 'Expression Filter';
   cmp_info(em).cid := 'EM';
   cmp_info(em).cname := 'EM Repository';
   cmp_info(htmldb).cid := 'HTMLDB';
   cmp_info(htmldb).cname := 'Oracle HTML DB';
   cmp_info(stats).cid := 'STATS';
   cmp_info(stats).cname := 'Gather Statistics';
   
-- Initialize script names
   cmp_info(catalog).script := '?/rdbms/admin/catalog.sql';
   cmp_info(catproc).script := '?/rdbms/admin/catproc.sql';
   cmp_info(javavm).script  := '?/javavm/install/jvmdbmig.sql'; 
   cmp_info(xml).script     := '?/xdk/admin/xmldbmig.sql';
   cmp_info(xdb).script     := '?/rdbms/admin/xdbdbmig.sql';
   cmp_info(rac).script     := '?/rdbms/admin/catclust.sql';
   cmp_info(ols).script     := '?/rdbms/admin/olsdbmig.sql';
   cmp_info(exf).script     := '?/rdbms/admin/exfdbmig.sql';
   cmp_info(owm).script     := '?/rdbms/admin/owmdbmig.sql';
   cmp_info(ordim).script   := '?/ord/im/admin/imdbmig.sql';
   cmp_info(sdo).script     := '?/md/admin/sdodbmig.sql';
   cmp_info(context).script := '?/ctx/admin/ctxdbmig.sql';
   cmp_info(odm).script     := '?/rdbms/admin/odmdbmig.sql';
   cmp_info(wk).script      := '?/ultrasearch/admin/wkdbmig.sql';
   cmp_info(mgw).script     := '?/mgw/admin/mgwdbmig.sql';
   cmp_info(amd).script     := '?/olap/admin/amddbmig.sql';
   cmp_info(aps).script     := '?/olap/admin/apsdbmig.sql';
   cmp_info(xoq).script     := '?/olap/admin/xoqdbmig.sql';
   cmp_info(em).script      := '?/sysman/admin/emdrep/sql/empatch.sql';
   cmp_info(htmldb).script  := '?/htmldb/core/htmldbmig.sql';

-- *****************************************************************
-- Store Release Dependent Data
-- *****************************************************************

-- Populate the component tablespace requirements
-- All numbers in kbytes CALIBRATION LABEL - RDBMS_10.1.0.2.0_RELEASE

-- kbytes for component installs (into SYSTEM and DEFAULT tablespaces)
   cmp_info(javavm).ins_sys_kbytes:= 105972;
   cmp_info(xml).ins_sys_kbytes:=      4818;
   cmp_info(catjava).ins_sys_kbytes:=  5760;
   cmp_info(xdb).ins_sys_kbytes:=      5632;
   cmp_info(xdb).ins_def_kbytes:=     48512;
   cmp_info(ordim).ins_sys_kbytes:=   23064;
   cmp_info(ordim).ins_def_kbytes:=     448;

   IF dbv = 817 THEN

      cmp_info(catalog).sys_kbytes:= 118592;  
      cmp_info(catproc).sys_kbytes:=    384;
      cmp_info(javavm).sys_kbytes:=   28672;
      cmp_info(xml).sys_kbytes:=       1152;
      cmp_info(catjava).sys_kbytes:=    832;
      cmp_info(context).sys_kbytes:=   2880;
      cmp_info(ordim).sys_kbytes:=    13888;
      cmp_info(sdo).sys_kbytes:=       7808;
      cmp_info(ols).sys_kbytes:=        264;
      cmp_info(stats).sys_kbytes:=     4832;

      cmp_info(catalog).sysaux_kbytes:=  34176;
      cmp_info(catproc).sysaux_kbytes:=      0;
      cmp_info(ordim).sysaux_kbytes:=      256;
      cmp_info(sdo).sysaux_kbytes:=        320;
      cmp_info(stats).sysaux_kbytes:= 1216+192;

      cmp_info(catproc).def_ts_kbytes:=   2816; -- SYSTEM 
      cmp_info(context).def_ts_kbytes:=    896; -- CTXSYS 
      cmp_info(ordim).def_ts_kbytes:=      448; -- ORDSYS 
      cmp_info(sdo).def_ts_kbytes:=     102208; -- MDSYS 

   ELSIF dbv=901 THEN

      cmp_info(catalog).sys_kbytes:=   1120;
      cmp_info(catproc).sys_kbytes:=  88144; 
      cmp_info(javavm).sys_kbytes:=   37064;
      cmp_info(xml).sys_kbytes:=        320;
      cmp_info(context).sys_kbytes:=   1320;
      cmp_info(owm).sys_kbytes:=        792;
      cmp_info(amd).sys_kbytes:=       3536;
      cmp_info(ordim).sys_kbytes:=     6296;
      cmp_info(sdo).sys_kbytes:=       8272;
      cmp_info(wk).sys_kbytes:=        1024;
      cmp_info(ols).sys_kbytes:=        264;
      cmp_info(stats).sys_kbytes:=     4832;

      cmp_info(catalog).sysaux_kbytes:=      0;
      cmp_info(catproc).sysaux_kbytes:=  34176;
      cmp_info(owm).sysaux_kbytes:=       5312;
      cmp_info(amd).sysaux_kbytes:=      11712;
      cmp_info(ordim).sysaux_kbytes:=      256;
      cmp_info(sdo).sysaux_kbytes:=        320;
      cmp_info(stats).sysaux_kbytes:=  1216+192;

      cmp_info(catproc).def_ts_kbytes:=      0; -- SYSTEM user
      cmp_info(owm).def_ts_kbytes:=        472; -- WMSYS
      cmp_info(amd).def_ts_kbytes:=       9536; -- ORAOLAP
      cmp_info(wk).def_ts_kbytes:=  4544+12288; -- WKSYS + WK_TEST
      cmp_info(ols).def_ts_kbytes:=        112; -- LBACSYS
      cmp_info(ordim).def_ts_kbytes:=       96; -- ORDSYS
      cmp_info(sdo).def_ts_kbytes:=      95712; -- MDSYS
      cmp_info(context).def_ts_kbytes:=    448; -- CTXSYS

   ELSIF dbv=920 THEN

      cmp_info(catalog).sys_kbytes:=    768;  -- solaris 512
      cmp_info(catproc).sys_kbytes:=  43408;  -- solaris 32896
      cmp_info(javavm).sys_kbytes:=     384;
      cmp_info(xml).sys_kbytes:=         64;
      cmp_info(catjava).sys_kbytes:=     64;
      cmp_info(context).sys_kbytes:=     64; 
      cmp_info(xdb).sys_kbytes:=        192;
      cmp_info(owm).sys_kbytes:=        192;
      cmp_info(odm).sys_kbytes:=        256;
      cmp_info(mgw).sys_kbytes:=       1792;
      cmp_info(aps).sys_kbytes:=          0;
      cmp_info(amd).sys_kbytes:=       1024;
      cmp_info(xoq).sys_kbytes:=       2240;
      cmp_info(ordim).sys_kbytes:=     1408;
      cmp_info(sdo).sys_kbytes:=        512;
      cmp_info(wk).sys_kbytes:=           0;
      cmp_info(ols).sys_kbytes:=         64;
      cmp_info(stats).sys_kbytes:=     5824;

      cmp_info(catalog).sysaux_kbytes:=      0;
      cmp_info(catproc).sysaux_kbytes:=  34176;
      cmp_info(owm).sysaux_kbytes:=       5312 ;
      cmp_info(odm).sysaux_kbytes:=        192;
      cmp_info(aps).sysaux_kbytes:=      11712;
      cmp_info(xoq).sysaux_kbytes:=        704;
      cmp_info(sdo).sysaux_kbytes:=          0;
      cmp_info(stats).sysaux_kbytes:= 1600+192;

      cmp_info(amd).def_ts_kbytes:=        512; -- OLAPSYS
      cmp_info(context).def_ts_kbytes:=    256; -- CTXSYS
      cmp_info(wk).def_ts_kbytes:=  2752+12288; -- WKSYS + WK_TEST
      cmp_info(odm).def_ts_kbytes:=        128; -- ODM + ODM_MTR
      cmp_info(owm).def_ts_kbytes:=          0; -- WMSYS
      cmp_info(ordim).def_ts_kbytes:=      384; -- ORDSYS
      cmp_info(sdo).def_ts_kbytes:=      94400; -- MDSYS
      cmp_info(catproc).def_ts_kbytes:=      0; -- SYSTEM user
      cmp_info(xdb).def_ts_kbytes:=       2880; -- XDB
      cmp_info(ols).def_ts_kbytes:=        448; -- LBACSYS

   ELSIF dbv = 101 THEN

      cmp_info(catalog).sys_kbytes:=   1024;
      cmp_info(catproc).sys_kbytes:=  18512;  -- solaris 11664
      cmp_info(javavm).sys_kbytes:=   10496;  -- solaris 7936
      cmp_info(xml).sys_kbytes:=       1024;  -- solaris 128
      cmp_info(catjava).sys_kbytes:=     64;
      cmp_info(context).sys_kbytes:=    128;  
      cmp_info(xdb).sys_kbytes:=       3200;  -- solaris 1088
      cmp_info(owm).sys_kbytes:=       1024;  
      cmp_info(odm).sys_kbytes:=       1216;  
      cmp_info(mgw).sys_kbytes:=       1344;
      cmp_info(aps).sys_kbytes:=          0;
      cmp_info(amd).sys_kbytes:=         64;
      cmp_info(xoq).sys_kbytes:=       2304;
      cmp_info(ordim).sys_kbytes:=      576;
      cmp_info(sdo).sys_kbytes:=       2560;
      cmp_info(wk).sys_kbytes:=        2048;
      cmp_info(ols).sys_kbytes:=       1024;
      cmp_info(exf).sys_kbytes:=       1024;
      cmp_info(em).sys_kbytes:=        2240;
      cmp_info(stats).sys_kbytes:=     3456;

      cmp_info(catalog).sysaux_kbytes:=      0;
      cmp_info(catproc).sysaux_kbytes:=   7670;  
      cmp_info(owm).sysaux_kbytes:=          0;
      cmp_info(xdb).sysaux_kbytes:=        768;
      cmp_info(odm).sysaux_kbytes:=          0;
      cmp_info(aps).sysaux_kbytes:=       5440;
      cmp_info(xoq).sysaux_kbytes:=        704;
      cmp_info(ordim).sysaux_kbytes:=      128;
      cmp_info(sdo).sysaux_kbytes:=          0;
      cmp_info(exf).sysaux_kbytes:=          0;
      cmp_info(em).sysaux_kbytes:=           0;
      cmp_info(stats).sysaux_kbytes:=     1920;

      cmp_info(amd).def_ts_kbytes:=          0; -- OLAPSYS
      cmp_info(context).def_ts_kbytes:=      0; -- CTXSYS
      cmp_info(wk).def_ts_kbytes:=        1792; -- WKSYS + WK_TEST
      cmp_info(odm).def_ts_kbytes:=          0; -- DMSYS
      cmp_info(owm).def_ts_kbytes:=          0; -- WKSYS
      cmp_info(ordim).def_ts_kbytes:=        0; -- ORDSYS
      cmp_info(sdo).def_ts_kbytes:=      93248; -- MDSYS
      cmp_info(catproc).def_ts_kbytes:=   1088; -- SYSTEM 
      cmp_info(xdb).def_ts_kbytes:=       1408; -- XDB
      cmp_info(ols).def_ts_kbytes:=        128; -- LBACSYS
      cmp_info(exf).def_ts_kbytes:=        576; -- EXFSYS
      cmp_info(em).def_ts_kbytes:=        1408; -- SYSMAN

   ELSIF dbv = 102 THEN

      -- TBD for patch upgrade after release
      NULL;

   END IF;

-- *****************************************************************
-- END of Constant Data
-- *****************************************************************

-- *****************************************************************
-- START of Collect Section
-- *****************************************************************

-- *****************************************************************
-- Collect Variable Component Information 
-- *****************************************************************


   BEGIN -- Check for registry$ table - if exists, get components
      SELECT NULL INTO p_null FROM obj$ WHERE TYPE#=2 AND owner#=0
        AND name='REGISTRY$';
      
      IF dbv = 920 THEN  -- No namespace
         OPEN reg_cursor FOR 
              'SELECT cid, status, version, schema# ' ||
              'FROM registry$';
      ELSE
         OPEN reg_cursor FOR 
              'SELECT cid, status, version, schema# ' ||
              'FROM registry$ WHERE namespace =''SERVER''';
      END IF;

      LOOP
         FETCH reg_cursor INTO p_cid, n_status, p_version, n_schema;
         EXIT WHEN reg_cursor%NOTFOUND;
         IF n_status NOT IN (99,8) THEN -- not REMOVED or REMOVING
            SELECT name INTO p_schema FROM user$ 
                   WHERE user#=n_schema;
            FOR i IN 1..max_components LOOP
               IF p_cid = cmp_info(i).cid THEN
                  store_comp(i, p_schema, p_version, n_status);
                  EXIT; -- from component search loop
               END IF;
            END LOOP;  -- ignore if not in component list
         END IF;
      END LOOP;
      CLOSE reg_cursor;

      -- Ultra Search not in 10.1.0.2 registry so check schema
      IF NOT cmp_info(wk).processed THEN
         BEGIN
            SELECT NULL into p_null FROM user$ WHERE name = 'WKSYS';
            store_comp(wk, 'WKSYS', db_version, NULL);           
         EXCEPTION
            WHEN NO_DATA_FOUND THEN NULL;
         END;
      END IF;

/* no HTML DB yet

      -- Check for HTML DB in 9.2.0 and 10.1 databases
      BEGIN
         EXECUTE IMMEDIATE 
            'SELECT FLOWS_010500.wwv_flows_release from dual'
         INTO p_version;
         store_comp(htmldb,'FLOWS_010500',p_version, NULL);
      EXCEPTION
         WHEN OTHERS THEN NULL;
      END;

      BEGIN
         EXECUTE IMMEDIATE 
            'SELECT FLOWS_010600.wwv_flows_release from dual'
         INTO p_version;
         store_comp(htmldb,'FLOWS_010600',p_version, NULL);
      EXCEPTION
         WHEN OTHERS THEN NULL;
      END;

 end of HTML DB identify */

   EXCEPTION WHEN NO_DATA_FOUND THEN -- no registry, so look for schemas
      store_comp(catalog, 'SYS', db_version, NULL);            
      store_comp(catproc, 'SYS', db_version, NULL);            

      -- JAVA
      BEGIN
         SELECT NULL into p_null FROM obj$ WHERE type#=29 AND
              owner#=0 and rownum <=1;
         store_comp(javavm, 'SYS', db_version, NULL);           
      EXCEPTION
         WHEN NO_DATA_FOUND THEN NULL;
      END;

      -- XML
      BEGIN
        SELECT NULL INTO p_null FROM obj$ WHERE type#=29
         AND owner#=0  AND name like 'oracle/xml/parser%' and ROWNUM<=1;
         store_comp(xml, 'SYS', db_version, NULL);           
      EXCEPTION
         WHEN NO_DATA_FOUND THEN NULL;
      END;

      -- CONTEXT (CTX)
      BEGIN
         SELECT NULL into p_null FROM user$ WHERE name = 'CTXSYS';
         store_comp(context, 'CTXSYS', db_version, NULL);           
      EXCEPTION
         WHEN NO_DATA_FOUND THEN NULL;
      END;

      -- Real Application Clusters
      BEGIN
         SELECT null INTO p_null FROM obj$
             WHERE owner#=0 AND name='V$PING' AND ROWNUM <=1;
         store_comp(rac, 'SYS', db_version, NULL);           
      EXCEPTION
         WHEN NO_DATA_FOUND THEN NULL;
      END;

      -- Oracle Workspace Manager
      BEGIN
         SELECT NULL into p_null FROM user$ WHERE name = 'WMSYS';
         store_comp(owm, 'WMSYS', db_version, NULL);           
      EXCEPTION
         WHEN NO_DATA_FOUND THEN  -- look for OWM table in SYSTEM
           BEGIN
             SELECT NULL INTO p_null FROM obj$ o, user$ u
             WHERE u.name = 'SYSTEM' AND
                 o.name = 'WM$ENV_VARS' AND
                 u.user#=o.owner# and o.type#=2;
             store_comp(owm,'WMSYS',db_version,NULL);
           EXCEPTION
              WHEN NO_DATA_FOUND THEN NULL;
           END;
      END;

      -- Spatial
      BEGIN
         SELECT NULL into p_null FROM user$ WHERE name = 'MDSYS';
         store_comp(sdo, 'MDSYS', db_version, NULL);           
      EXCEPTION
         WHEN NO_DATA_FOUND THEN NULL;
      END;

      -- Intermedia
      BEGIN
         SELECT NULL into p_null FROM user$ WHERE name = 'ORDSYS';
         EXECUTE IMMEDIATE 'SELECT NULL ' ||
                           'FROM ordsys.ord_installations ' ||
                           'WHERE short_name = ''ORDIM'''
                            INTO p_null;
         store_comp(ordim, 'ORDSYS', db_version, NULL);           
      EXCEPTION
         WHEN NO_DATA_FOUND THEN NULL;
      END;

      -- Oracle Label Security
      BEGIN
         SELECT NULL into p_null FROM user$ WHERE name = 'LBACSYS';
         store_comp(ols, 'LBACSYS', db_version, NULL);           
      EXCEPTION
         WHEN NO_DATA_FOUND THEN NULL;
      END;

      -- Oracle Data Mining
      BEGIN
         SELECT NULL into p_null FROM user$ WHERE name = 'ODM';
         store_comp(odm, 'ODM', db_version, NULL);           
      EXCEPTION
         WHEN NO_DATA_FOUND THEN NULL;
      END;

      -- Ultrasearch
      BEGIN
         SELECT NULL into p_null FROM user$ WHERE name = 'WKSYS';
         store_comp(wk, 'WKSYS', db_version, NULL);           
      EXCEPTION
         WHEN NO_DATA_FOUND THEN NULL;
      END;

       -- CWMLite (OLAP Catalog)
      BEGIN
        SELECT NULL into p_null FROM user$ WHERE name = 'OLAPSYS';
        store_comp(amd, 'OLAPSYS', db_version, NULL);           
      EXCEPTION
         WHEN NO_DATA_FOUND THEN NULL;
      END;
   END;   -- exception block for registry$ table

   -- if SDO, ORDIM, WK, EXF, or ODM components are present, need JAVAVM
   IF NOT cmp_info(javavm).processed THEN
      IF cmp_info(ordim).processed OR cmp_info(wk).processed OR 
         cmp_info(exf).processed OR
         cmp_info(sdo).processed OR cmp_info(odm).processed THEN
         store_comp(javavm, 'SYS', NULL, NULL);           
         cmp_info(javavm).install := TRUE;
         store_comp(catjava, 'SYS', NULL, NULL);           
         cmp_info(catjava).install := TRUE;
      END IF;
   END IF;
 
   -- If there is a JAVAVM component
   -- THEN include the CATJAVA component.
   IF cmp_info(javavm).processed AND NOT cmp_info(catjava).processed THEN
      store_comp(catjava, 'SYS', NULL, NULL);           
      cmp_info(catjava).install := TRUE;
   END IF;

   -- If InterMedia or Spatial component, but no XML, Then
   -- install XML
   IF NOT cmp_info(xml).processed AND
         (cmp_info(ordim).processed OR cmp_info(sdo).processed) THEN
      store_comp(xml, 'SYS', NULL, NULL);           
      cmp_info(xml).install := TRUE;
   END IF;
   
   -- If XML, InterMedia or Spatial component, but no XDB, Then
   -- install XDB
   IF NOT cmp_info(xdb).processed AND
         (cmp_info(ordim).processed OR cmp_info(sdo).processed OR
          cmp_info(xml).processed) THEN
      store_comp(xdb, 'XDB', NULL, NULL);           
      cmp_info(xdb).install := TRUE;
      cmp_info(xdb).def_ts := 'SYSAUX';
   END IF;
   
   -- If Spatial component, but no ORDIM, Then
   -- install ORDIM
   IF NOT cmp_info(ordim).processed AND
         (cmp_info(sdo).processed) THEN
      store_comp(ordim, 'ORDSYS', NULL, NULL);           
      cmp_info(ordim).install := TRUE;
      cmp_info(ordim).def_ts := 'SYSAUX';
   END IF;

   -- if statistics have not been gathered, set stats to processed
   -- TBD, determine if statistics have been gathered
   cmp_info(stats).processed := TRUE;

-- *****************************************************************
-- Collect Variable Initialization Parameter Information
-- *****************************************************************

   -- Find renamed parameters in use
   FOR i IN 1..max_rp LOOP
      BEGIN
         SELECT NULL INTO p_null
         FROM v$parameter WHERE name = LOWER(rp(i).oldname) AND
              isdefault = 'FALSE';
         rp(i).db_match := TRUE;
      EXCEPTION WHEN NO_DATA_FOUND THEN
         rp(i).db_match := FALSE;
      END;
   END LOOP;
 
   -- Find obsolete parameters in use
   FOR i IN 1..max_op LOOP
      BEGIN
         SELECT NULL INTO p_null
         FROM v$parameter WHERE name = LOWER(op(i).name) AND
              isdefault = 'FALSE';
         op(i).db_match := TRUE;
      EXCEPTION WHEN NO_DATA_FOUND THEN
         op(i).db_match := FALSE;
      END;
   END LOOP;

   -- Find special parameters in use
   FOR i IN 1..max_sp LOOP
      BEGIN
         SELECT value INTO p_value
         FROM v$parameter WHERE name = LOWER(sp(i).oldname) AND
              isdefault = 'FALSE';
         IF sp(i).oldvalue IS NULL OR
            p_value = sp(i).oldvalue THEN
            sp(i).db_match := TRUE;
         ELSE
            sp(i).db_match := FALSE;
         END IF;
      EXCEPTION WHEN NO_DATA_FOUND THEN
         sp(i).db_match := FALSE;
      END;
   END LOOP;
 
   -- Find required values
   FOR i IN 1..max_reqp LOOP
      BEGIN
         SELECT value INTO p_value
         FROM v$parameter WHERE name = LOWER(reqp(i).name) AND
              isdefault = 'FALSE';
         reqp(i).db_match := TRUE;
      EXCEPTION WHEN NO_DATA_FOUND THEN
         sp(i).db_match := FALSE;
      END;
   END LOOP;

   -- Find values for initialization parameters with minimum values
   -- Convert to numeric values
   FOR i IN 1..max_mp LOOP
     IF i = sp_idx and dbv NOT IN (101, 102) THEN
        -- This block of code is dealing with shared_pool_size
        SELECT SUM(bytes) INTO mp(sp_idx).oldvalue FROM v$sgastat
        WHERE pool='shared pool';

        SELECT value INTO p_value FROM v$parameter WHERE name = LOWER(mp(i).name);
        sps := pvalue_to_number(p_value);

        SELECT value INTO p_value FROM v$parameter WHERE name = 'cpu_count';
        cpu := pvalue_to_number(p_value);

        SELECT value INTO p_value FROM v$parameter WHERE name = 'sessions';
        sesn := pvalue_to_number(p_value);

        -- On a large database, the minimum of 144M may not be enough for shared 
        -- pool size, we have to factor in the number of CPU, the number of session,
        -- and some new added features. So here is the formula:
        -- Recommended minimum share_pool_size = mp(sp_idx).minvalue + 
        -- (Num_of_CPU * 2MB) +
        -- (Num_of_sessiions * 17408) + 
        -- (10% of the old shared_pool_size for overhead)
        sps_ovrhd := sps * 0.1;

        IF collect_diag THEN
          DBMS_OUTPUT.PUT_LINE('DIAG-sps_min: ' || mp(sp_idx).minvalue);
--          DBMS_OUTPUT.PUT_LINE('DIAG-cpu: ' || cpu 
--                    || ', cpu*2097152: ' || cpu * 2097152);
          DBMS_OUTPUT.PUT_LINE('DIAG-sesn: ' || sesn || ', sesn*17408: ' 
                                || sesn * 17408);
          DBMS_OUTPUT.PUT_LINE('DIAG-sps: ' || sps || 
                                ', sps_ovrhd(10%): ' || sps_ovrhd);
           mp(sp_idx).minvalue := mp(sp_idx).minvalue + 
/* avoid CPU dependency in DIAG mode (cpu * 2097152) +  */
                                (sesn * 17408) + 
                                (sps_ovrhd);
        ELSE
           mp(sp_idx).minvalue := mp(sp_idx).minvalue + 
                                (cpu * 2097152) + 
                                (sesn * 17408) + 
                                (sps_ovrhd);
        END IF;
     ELSE
        BEGIN
           SELECT value INTO p_value  
           FROM v$parameter WHERE name = LOWER(mp(i).name);

           mp(i).oldvalue := pvalue_to_number(p_value);

        EXCEPTION WHEN NO_DATA_FOUND THEN
           mp(i).oldvalue := NULL;
        END;
     END IF;
   END LOOP;

   IF mp(tg_idx).oldvalue != 0 THEN  -- SGA_TARGET in use
      mp(tg_idx).newvalue := mp(tg_idx).minvalue + mp(cs_idx).oldvalue +
                             mp(jv_idx).oldvalue + mp(lp_idx).oldvalue;
      IF mp(tg_idx).newvalue > mp(tg_idx).oldvalue THEN
           mp(tg_idx).display := TRUE;
      END IF;
      FOR i IN 1..max_mp LOOP
        IF i NOT IN (tg_idx,cs_idx,jv_idx,lp_idx,sp_idx) AND 
          (mp(i).oldvalue IS NULL OR
           mp(i).oldvalue < mp(i).minvalue) THEN  
           mp(i).display := TRUE;
           mp(i).newvalue := mp(i).minvalue;
         END IF;
      END LOOP;
   ELSE -- pool sizes included 
     FOR i IN 1..max_mp LOOP
       IF i NOT IN (tg_idx,cs_idx) AND 
          (mp(i).oldvalue IS NULL OR
           mp(i).oldvalue < mp(i).minvalue) THEN  
           mp(i).display := TRUE;
           mp(i).newvalue := mp(i).minvalue;
        END IF;
      END LOOP;
   END IF;

-- *****************************************************************
-- Collect Tablespace Information
-- *****************************************************************

   idx := 0;
   FOR ts IN (SELECT tablespace_name, contents FROM dba_tablespaces) LOOP
       IF ts.tablespace_name IN ('SYSTEM', 'SYSAUX') OR 
          is_comp_tablespace(ts.tablespace_name) OR
          ts_has_queues (ts.tablespace_name) OR 
          ts_is_SYS_temporary (ts.tablespace_name) THEN

          idx:=idx+1;
          ts_info(idx).name  :=ts.tablespace_name;
          IF ts.contents = 'TEMPORARY' THEN
             ts_info(idx).temporary := TRUE;
          ELSE
             ts_info(idx).temporary := FALSE;
          END IF;

          -- Get number of kbytes used
          SELECT SUM(bytes) INTO sum_bytes
                 FROM dba_segments seg 
                 WHERE seg.tablespace_name = ts.tablespace_name;
          IF sum_bytes IS NULL THEN 
             ts_info(idx).inuse:=0;
          ELSIF sum_bytes <= 1024 THEN
             ts_info(idx).inuse:=1;
          ELSE
             ts_info(idx).inuse :=ROUND(sum_bytes/1024);
          END IF;  

          -- Get number of kbytes allocated
          IF ts_info(idx).temporary AND dbv != 817 THEN
             SELECT ROUND(SUM(bytes)/1024) INTO sum_bytes
                    FROM dba_temp_files files 
                    WHERE files.tablespace_name = ts.tablespace_name;
          ELSE
             SELECT ROUND(SUM(bytes)/1024) INTO sum_bytes
                    FROM dba_data_files files 
                    WHERE files.tablespace_name = ts.tablespace_name;
          END IF;
          IF sum_bytes IS NULL THEN
             sum_bytes := 0;
          END IF;
          
          ts_info(idx).alloc := sum_bytes;

          -- Get number of kbytes of unused autoextend
          IF ts_info(idx).temporary AND dbv != 817 THEN
             SELECT ROUND(SUM(decode(maxbytes, 0, 0,maxbytes-bytes)/1024))
                    INTO sum_bytes
                    FROM dba_temp_files 
                    WHERE tablespace_name=ts.tablespace_name;
          ELSE
             SELECT ROUND(SUM(decode(maxbytes, 0, 0,maxbytes-bytes)/1024))
                    INTO sum_bytes
                    FROM dba_data_files 
                    WHERE tablespace_name=ts.tablespace_name;
          END IF;
          ts_info(idx).auto :=sum_bytes; 
          
          -- total available is allocated plus auto extend
          ts_info(idx).avail := ts_info(idx).alloc + ts_info(idx).auto;
      END IF;
   END LOOP;
   max_ts := idx;   -- max tablespaces of interest

   -- check for ASM 
   IF dbv NOT IN (817, 901, 920) THEN
      BEGIN
         EXECUTE IMMEDIATE 'SELECT NULL FROM v$asm_client 
                 WHERE rownum <=1'
         INTO P_NULL;
         using_ASM := TRUE;
      EXCEPTION 
         WHEN NO_DATA_FOUND THEN NULL;
      END;
   END IF;

-- *****************************************************************
-- Collect Public Rollback Information
-- *****************************************************************

   idx:=0;
   BEGIN
     SELECT value INTO p_undo FROM v$parameter
           WHERE name = 'undo_management';
   EXCEPTION 
     WHEN NO_DATA_FOUND THEN
       p_undo := 'ROLLBACK';
   END;

   IF p_undo != 'AUTO' THEN  -- using rollback segments
      FOR rs IN (SELECT segment_name, next_extent, max_extents, status 
                 FROM dba_rollback_segs WHERE owner = 'PUBLIC' OR
                 (owner='SYS' AND segment_name != 'SYSTEM')) LOOP
        BEGIN
          SELECT tablespace_name, sum(bytes) INTO p_tsname, sum_bytes 
                 FROM dba_segments
                 WHERE segment_name = rs.segment_name
                 GROUP BY tablespace_name;
          IF sum_bytes < 1024 THEN
             sum_bytes := 1;
          ELSE
             sum_bytes := sum_bytes/1024;
          END IF;
        EXCEPTION WHEN NO_DATA_FOUND THEN
          sum_bytes := NULL;
        END;

        IF sum_bytes IS NOT NULL THEN
           idx:=idx + 1;
           rs_info(idx).tbs_name := p_tsname;
           rs_info(idx).seg_name := rs.segment_name;
           rs_info(idx).status := rs.status;
           rs_info(idx).next := rs.next_extent/1024;
           rs_info(idx).max_ext := rs.max_extents;
           rs_info(idx).status := rs.status;
           rs_info(idx).inuse := sum_bytes;
           SELECT ROUND(SUM(decode(maxbytes, 0, 0,maxbytes-bytes)/1024))
                  INTO rs_info(idx).auto
                  FROM dba_data_files 
                  WHERE tablespace_name=p_tsname;
        END IF;
      END LOOP;
   END IF;  -- using undo tablespace, not rollback

   max_rs := idx;

-- *****************************************************************
-- Collect Log File Information
-- *****************************************************************

   idx := 0;
   FOR log IN (SELECT lf.member, l.bytes, l.status, l.group#
            FROM  v$logfile lf, v$log l 
            WHERE lf.group# = l.group# 
            AND   l.bytes < min_log_size 
            ORDER BY l.status DESC) LOOP
      idx := idx + 1;
      lf_info(idx).file_spec := log.member;
      lf_info(idx).grp       := log.group#;
      lf_info(idx).bytes     := log.bytes;
      lf_info(idx).status    := log.status;
   END LOOP;
   max_lf := idx;

-- *****************************************************************
-- Collect Misc Information for Warnings
-- *****************************************************************

   -- Check for patch applied in DBs with registry
   BEGIN
      IF dbv NOT IN (817, 901) THEN
         EXECUTE IMMEDIATE 
             'SELECT NULL FROM registry$ 
              WHERE cid = ''CATPROC'' AND version != :inst_version'
         INTO p_null USING db_version;
         version_mismatch := TRUE;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
   END;

   -- Check for RAC
   BEGIN
      SELECT NULL INTO p_null FROM v$parameter
      WHERE name = 'cluster_database' AND value = 'TRUE';
      cluster_dbs := TRUE;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
   END;

   -- Check for pre-existing DIP user in pre-10.1 databases
   BEGIN
      SELECT NULL INTO p_null FROM user$ WHERE name='DIP';
      IF dbv NOT IN (101,102) THEN
         dip_user_exists:=TRUE;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
   END;

   -- Check for Database Character Set for use of AL24UTFFSS
   BEGIN
       SELECT NULL INTO p_null FROM v$nls_parameters
       WHERE parameter = 'NLS_CHARACTERSET' AND value = 'AL24UTFFSS';
       nls_AL24UTFFSS := TRUE;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
   END;
 
   -- Check for supported NCHAR character set
   BEGIN
       SELECT NULL INTO p_null FROM v$nls_parameters WHERE
       parameter='NLS_NCHAR_CHARACTERSET' AND
       value NOT IN ('UTF8','AL16UTF16');
       UTF8_AL16UTF16 := TRUE;
   EXCEPTION
       WHEN NO_DATA_FOUND THEN NULL;
   END;
   
   -- Check for OWM replication
   IF cmp_info(owm).processed THEN
      BEGIN
         -- Does this database have wmsys replication?
         SELECT NULL INTO p_null FROM obj$ o, user$ u
             WHERE o.name = 'WM$REPLICATION_TABLE'
             AND u.name='WMSYS'
             AND u.user#=o.owner# and o.type#=2;

         EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM wmsys.wm$replication_table'
              INTO rows_processed;

         IF rows_processed >0 THEN
            -- Is the Advanced Replication option installed?
            SELECT NULL INTO p_null FROM v$option
                WHERE parameter = 'Advanced replication' AND
                value = 'TRUE';
            -- If we made it this far then this installation has
            -- replication installed and is using it for OWM
            owm_replication := TRUE;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN NULL;
      END;
   END IF;
 
   -- Check for database links
   BEGIN
      SELECT NULL INTO p_null FROM link$ 
      WHERE (password IS NOT NULL OR 
            authpwd IS NOT NULL) AND rownum <=1;
      dblinks := TRUE;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
   END;

   -- Check for CDC streams
   BEGIN
      IF dbv IN (920, 101) THEN
         EXECUTE IMMEDIATE 'SELECT NULL 
             FROM dba_capture cap, dba_queues q, dba_queue_tables qt
             WHERE substr(cap.capture_name,4) = substr(q.name,4) AND
                     substr(q.name,4) = substr(qt.queue_table,4) AND
                     cap.queue_owner = q.owner AND
                     cap.queue_name = q.name AND
                     q.owner = qt.owner AND
                     q.queue_table = qt.queue_table AND
                     rownum <= 1'
         INTO p_null;
         cdc_data := TRUE;
       END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
   END;

   -- Check for CONNECT role
   BEGIN
     SELECT NULL INTO p_null FROM dba_role_privs
     WHERE granted_role = 'CONNECT' AND
           grantee NOT IN (
                   'SYS', 'OUTLN', 'SYSTEM', 'CTXSYS', 'DBSNMP', 
                   'LOGSTDBY_ADMINISTRATOR', 'ORDSYS',  
                   'ORDPLUGINS',  'OEM_MONITOR', 'WKSYS', 'WKPROXY', 
                   'WK_TEST', 'WKUSER', 'MDSYS', 'LBACSYS', 'DMSYS',
                   'WMSYS',  'OLAPDBA', 'OLAPSVR', 'OLAP_USER',  
                   'OLAPSYS', 'EXFSYS', 'SYSMAN', 'MDDATA',
                   'SI_INFORMTN_SCHEMA','XDB', 'ODM') AND
            rownum <= 1;
      connect_role := TRUE;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
   END;

   -- Check for INVALID objectx
   BEGIN
      SELECT NULL INTO p_null FROM dba_objects
      WHERE status = 'INVALID' AND object_name NOT LIKE 'BIN$%' AND rownum <=1;
      invalid_objs := TRUE;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
   END;

   -- Check for OLS
   IF cmp_info(ols).processed THEN
      post_upgrade := TRUE;
   END IF;

   -- Check for externally authenticated SSL users
   BEGIN
      SELECT NULL INTO p_null FROM sys.user$ 
      WHERE ext_username IS NOT NULL AND 
            password = 'GLOBAL' and rownum <=1;
      ssl_users := TRUE;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
   END;

   -- Check for use of WITH TIME ZONE datatypes
   IF dbv IN (901, 920) THEN
      BEGIN
         SELECT NULL INTO p_null FROM dba_tab_columns
         WHERE data_type LIKE 'TIMESTAMP%WITH TIME ZONE'
               AND rownum <= 1;
         timezone_v2 := TRUE;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN NULL;
      END;
   END IF;

   -- Check for stale statistics
   IF dbv != 817 THEN
     FOR i IN 1..max_comps LOOP 
       IF cmp_info(i).processed THEN
         BEGIN
           SELECT NULL INTO p_null 
           FROM sys.tab$ t, sys.obj$ o, sys.user$ u
           WHERE u.name = cmp_info(i).schema AND
                 t.obj# = o.obj# and o.owner# = u.user# AND
                 bitand(t.flags,16) != 16 AND -- not analyzed
                 -- we don't collect stats for the following types.
                 bitand(t.property,512) != 512 AND  -- not an iot overflow
                 bitand(t.flags,536870912) != 536870912 AND  
                                                    -- not an iot mapping table
                 bitand(t.property,2147483648) != 2147483648 AND 
                                                    -- not external table
                 bitand(o.flags, 128) != 128 AND    -- not in recycle bin
                 NOT (bitand(o.flags, 16) = 16 AND o.name like 'DR$%') AND 
                                                    -- no CTX
                 bitand(t.property,4194304) != 4194304 AND 
                                                    -- no global temp tables
                 bitand(t.property,8388608) != 8388608 AND 
                                                    -- no session temp tables
                 NOT EXISTS  -- not an mv log
                    (SELECT * FROM sys.mlog$
                     WHERE (mowner = u.name AND log = o.name) OR
                           (mowner = u.name AND temp_log = o.name)) AND
                 ROWNUM <= 1;
            stale_stats := TRUE;
            EXIT;    -- some stale statistics found
          EXCEPTION
            WHEN NO_DATA_FOUND THEN NULL;
          END;
       END IF;
     END LOOP;
   END IF;

-- *****************************************************************
-- Collect SYSAUX Information for Warnings
-- *****************************************************************

   IF dbv NOT IN (101,102) THEN
      BEGIN
        SELECT NULL INTO p_null FROM DBA_TABLESPACES
        WHERE tablespace_name = 'SYSAUX';
        -- SYSAUX already exists, so check attributes
        sysaux_exists := TRUE;

     -- permanent
        BEGIN 
           SELECT NULL INTO p_null FROM DBA_TABLESPACES
           WHERE tablespace_name = 'SYSAUX' AND
                 CONTENTS != 'PERMANENT';
           sysaux_not_perm := TRUE;
        EXCEPTION
           WHEN NO_DATA_FOUND THEN NULL;
        END;

     -- online
        BEGIN
           SELECT NULL INTO p_null FROM DBA_TABLESPACES
           WHERE tablespace_name = 'SYSAUX' AND
                 STATUS != 'ONLINE';
           sysaux_not_online := TRUE;
        EXCEPTION
           WHEN NO_DATA_FOUND THEN NULL;
        END;
 
     -- local extent management
        BEGIN
           SELECT NULL INTO p_null FROM DBA_TABLESPACES
           WHERE tablespace_name = 'SYSAUX' AND
                 extent_management != 'LOCAL';
           sysaux_not_local := TRUE;
        EXCEPTION
           WHEN NO_DATA_FOUND THEN NULL;
        END;

     -- auto segment space management
        IF dbv = 817 THEN 
           sysaux_not_auto := TRUE;
        ELSE
           BEGIN 
              EXECUTE IMMEDIATE 'SELECT NULL FROM DBA_TABLESPACES
              WHERE tablespace_name = ''SYSAUX'' AND
                    segment_space_management != ''AUTO'''
              INTO p_null;
              sysaux_not_auto := TRUE;
           EXCEPTION
              WHEN NO_DATA_FOUND THEN NULL;
           END;
        END IF;

      EXCEPTION -- No SYSAUX tablespace
         WHEN NO_DATA_FOUND THEN NULL;
      END;
   END IF; -- 10.1 does not need SYSAUX check

-- *****************************************************************
-- END of Collect Section
-- *****************************************************************

-- *****************************************************************
-- START of Calculate Section
-- *****************************************************************

-- *****************************************************************
-- Calculate Tablespace Requirements
-- *****************************************************************

    -- Look at all relevant tablespaces
   FOR t IN 1..max_ts LOOP
       delta_kbytes:=0;   -- initialize calculated tablespace delta

       IF ts_info(t).name = 'SYSTEM' THEN -- sum the component SYS kbytes
          FOR i IN 1..max_comps LOOP
              IF cmp_info(i).processed THEN
                 IF cmp_info(i).install THEN
                    delta_kbytes := delta_kbytes + cmp_info(i).ins_sys_kbytes;
                    IF collect_diag THEN
                       dbms_output.put_line('DIAG-CMPTS: SYS    ' || 
                             LPAD(cmp_info(i).cid, 10) || ' ' ||
                             LPAD(cmp_info(i).ins_sys_kbytes,10));   
                    END IF;
                 ELSE
                    delta_kbytes := delta_kbytes + cmp_info(i).sys_kbytes;
                    IF collect_diag THEN
                       dbms_output.put_line('DIAG-CMPTS: SYS    ' || 
                                LPAD(cmp_info(i).cid, 10) || ' ' ||
                                LPAD(cmp_info(i).sys_kbytes,10));
                    END IF;
                 END IF;
              END IF;
           END LOOP;
        END IF;  -- end of special SYSTEM tablespace processing

        IF ts_info(t).name = 'SYSAUX' THEN -- sum the component SYSAUX kbytes
          FOR i IN 1..max_comps LOOP
              IF cmp_info(i).processed THEN
                 delta_kbytes := delta_kbytes + cmp_info(i).sysaux_kbytes;
                 IF collect_diag THEN
                    dbms_output.put_line('DIAG-CMPTS: SYSAUX ' || 
                             LPAD(cmp_info(i).cid, 10) || ' ' ||
                             LPAD(cmp_info(i).sysaux_kbytes,10));
                 END IF;
              END IF;
           END LOOP;
        END IF;  -- end of special SYSAUX tablespace processing

        -- Now add in component default tablespace deltas
        -- def_tablespace_name is NULL for unprocessed comps
        FOR i IN 1..max_comps LOOP 
           IF ts_info(t).name = cmp_info(i).def_ts AND
              cmp_info(i).processed THEN
              IF cmp_info(i).install THEN  -- use install amount
                 delta_kbytes := delta_kbytes + cmp_info(i).ins_def_kbytes;
                 IF collect_diag THEN
                    dbms_output.put_line('DIAG-CMPTS: ' || 
                           RPAD(ts_info(t).name, 10) ||
                           LPAD(cmp_info(i).cid, 10) || ' ' ||
                           LPAD(cmp_info(i).ins_def_kbytes,10));   
                 END IF;
              ELSE  -- use default tablespace amount
                 delta_kbytes :=  delta_kbytes + cmp_info(i).def_ts_kbytes;
                 IF collect_diag THEN
                    dbms_output.put_line('DIAG-CMPTS: ' || 
                             RPAD(ts_info(t).name, 10) ||
                             LPAD(cmp_info(i).cid, 10) || ' ' ||
                             LPAD(cmp_info(i).def_ts_kbytes,10));
                    update_puiu_data('SCHEMA', 
                             ts_info(t).name || '-' || cmp_info(i).schema,
                             cmp_info(i).def_ts_kbytes);
                 END IF;
              END IF;
           END IF;
        END LOOP; -- end of default tablespace calculations 

        -- Now look for queues in user schemas
        SELECT count(*) INTO delta_queues 
        FROM dba_tables tb, dba_queues q
        WHERE q.queue_table = tb.table_name AND
              tb.tablespace_name = ts_info(t).name AND tb.owner NOT IN
              ('SYS','SYSTEM','MDSYS','ORDSYS','OLAPSYS','XDB',
               'LBACSYS','CTXSYS','ODM','DMSYS', 'WKSYS','WMSYS',
               'SYSMAN','EXFSYS');
        IF delta_queues > 0 THEN
           IF collect_diag THEN
              dbms_output.put_line('DIAG-QUES: ' || 
                          RPAD(ts_info(t).name, 10) ||
                          ' QUEUE count = ' || delta_queues);
           END IF;
           -- estimate 48K per queue
           delta_kbytes := delta_kbytes + delta_queues*48; 
        END IF;

        -- See if this is the temporary tablespace for SYS
        IF ts_is_SYS_temporary(ts_info(t).name) THEN
           delta_kbytes := delta_kbytes + 50*1024;  -- Add 50M for TEMP
        END IF;

        -- Put a 15% safety factor on DELTA and round it off
        delta_kbytes := ROUND(delta_kbytes*1.15);            

        -- Finally, save DELTA value
        ts_info(t).delta := delta_kbytes;

        -- Recomendation for minimum tablespace size is
        -- the "delta" plus existing in use amount
        ts_info(t).min   := ts_info(t).inuse + ts_info(t).delta;
   
        IF collect_diag THEN
           DBMS_OUTPUT.PUT_LINE('DIAG-TS: ' || RPAD(ts_info(t).name,10) || 
                              ' used =    ' || LPAD(ts_info(t).inuse,10));
           DBMS_OUTPUT.PUT_LINE('DIAG-TS: ' || RPAD(ts_info(t).name,10) || 
                              ' delta=    ' || LPAD(ts_info(t).delta,10));
           DBMS_OUTPUT.PUT_LINE('DIAG-TS: ' || RPAD(ts_info(t).name,10) || 
                              ' total req=' || LPAD(ts_info(t).min,10));
           DBMS_OUTPUT.PUT_LINE('DIAG-TS: ' || RPAD(ts_info(t).name,10) || 
                           '    alloc=      ' || LPAD(ts_info(t).alloc,10));
           DBMS_OUTPUT.PUT_LINE('DIAG-TS: ' || RPAD(ts_info(t).name,10) || 
                           '    auto_avail= ' || LPAD(ts_info(t).auto,10));
           DBMS_OUTPUT.PUT_LINE('DIAG-TS: ' || RPAD(ts_info(t).name,10) || 
                           '    total avail=' ||  LPAD(ts_info(t).avail,10));
        END IF;

        -- put calculated delta into puiu$data if it exists
        update_puiu_data('TABLESPACE', ts_info(t).name, delta_kbytes);

        -- convert to MB
        ts_info(t).min := ts_info(t).min/1024;
        ts_info(t).alloc := ts_info(t).alloc/1024;
        ts_info(t).avail := ts_info(t).avail/1024;

        -- Determine amount of additional space needed
        -- independent of autoextend on/off
        IF ts_info(t).min > ts_info(t).alloc THEN
           ts_info(t).addl  := ts_info(t).min - ts_info(t).alloc;
        ELSE
           ts_info(t).addl := 0;
        END IF;

        -- Do we have enough space in the existing tablespace?
        IF ts_info(t).min < ts_info(t).avail  THEN
           ts_info(t).inc_by := 0;
        ELSE
           -- need to add space
           ts_info(t).inc_by := ts_info(t).min - ts_info(t).avail; 
        END IF;

        -- Find a file in the tablespace with autoextend on
        -- DBUA will use this information to add to autoextend
        -- or to check for total space on disk
        IF ts_info(t).addl > 0 OR ts_info(t).inc_by > 0 THEN
           ts_info(t).fauto := FALSE;
           IF ts_info(t).temporary AND dbv != 817 THEN
              FOR f IN (SELECT file_name, autoextensible 
                        FROM dba_temp_files
                        WHERE tablespace_name = ts_info(t).name) LOOP
                  IF f.autoextensible= 'YES' THEN
                     ts_info(t).fname := f.file_name;
                     ts_info(t).fauto := TRUE;
                     EXIT;
                  END IF;
              END LOOP;
           ELSE
              FOR f IN (SELECT file_name, autoextensible 
                        FROM dba_data_files
                        WHERE tablespace_name = ts_info(t).name) LOOP
                  IF f.autoextensible= 'YES' THEN
                     ts_info(t).fname := f.file_name;
                     ts_info(t).fauto := TRUE;
                     EXIT;
                  END IF;
              END LOOP;
           END IF;
        END IF;
    END LOOP;  -- end of tablespace loop

-- *****************************************************************
-- Calculate SYSAUX Requirements for pre-10.1 databases
-- *****************************************************************

   delta_sysaux := 0;

   IF dbv NOT IN (101,102) THEN
   -- sum the component SYSAUX usage for earlier releases
      FOR i IN 1..max_comps LOOP
         IF cmp_info(i).processed THEN -- add upgrade amount
            delta_sysaux := delta_sysaux + cmp_info(i).sysaux_kbytes;
            IF collect_diag THEN
               dbms_output.put_line('DIAG-CMPTS:  SYSAUX ' || 
                                  LPAD(cmp_info(i).cid, 10) || ' ' ||
                                  LPAD(cmp_info(i).sysaux_kbytes,10));   
            END IF;
         END IF;
         IF cmp_info(i).install AND 
            cmp_info(i).def_ts = 'SYSAUX' THEN  -- add def_ts install amount also
            delta_sysaux := delta_sysaux + cmp_info(i).ins_def_kbytes;
            IF collect_diag THEN
               dbms_output.put_line('DIAG-CMPTS:  SYSAUX ' || 
                      LPAD(cmp_info(i).cid, 10) || ' ' ||
                      LPAD(cmp_info(i).ins_def_kbytes,10));   
            END IF;
         END IF;
       END LOOP;

       -- Add a base of 62000 bytes to our calculation
       delta_sysaux := delta_sysaux + 62000;

       IF collect_diag THEN
           DBMS_OUTPUT.PUT_LINE('DIAG-TS:   SYSAUX' || 
                              ' total req=' || LPAD(delta_sysaux,10));
       END IF;

    -- Put a 500MB (512000KB) floor on delta_sysaux
       IF delta_sysaux < 512000 THEN
          delta_sysaux := 512000;
       END IF;
   ELSE  -- TBD calculate 10.1 sysaux delta
     delta_sysaux := 0;
   END IF;

   delta_sysaux := ROUND(delta_sysaux/1024); -- convert to MB

-- *****************************************************************
-- END of Calculate Section
-- *****************************************************************

-- *****************************************************************
-- START of Display Section
-- *****************************************************************

   IF display_xml THEN
       DBMS_OUTPUT.PUT_LINE('<RDBMSUP version="10.2">');
      DBMS_OUTPUT.PUT_LINE(
          '<SupportedOracleVersions value="8.1.7, 9.0.1, 9.2.0, 10.1.0, 10.2.0"/>');
      DBMS_OUTPUT.PUT_LINE(   
         '<OracleVersion value ="'|| vers || '"/>'); 
      display_database;
      IF dbv != 102 THEN -- database not upgraded yet
           display_parameters;
           display_components;
           display_tablespaces;
           display_misc_warnings;
      END IF;
      DBMS_OUTPUT.PUT_LINE('</RDBMSUP>');
   ELSE
      DBMS_OUTPUT.PUT_LINE(
             'Oracle Database 10.2 Upgrade Information Utility    ' ||
             TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS'));
      DBMS_OUTPUT.PUT_LINE('.');

      display_database;
      IF dbv != 102 THEN  -- database not upgraded yet
         display_logfiles;
         display_tablespaces;
         display_rollback_segs;
         display_parameters;
         display_components;
         display_misc_warnings;
         IF dbv NOT IN (101,102) THEN
            display_sysaux;
         END IF;
      END IF;
   END IF;

-- *****************************************************************
-- END of Display Section
-- *****************************************************************

END;
/

SET SERVEROUTPUT OFF

-- *****************************************************************
-- END utlu102x.sql
-- *****************************************************************
