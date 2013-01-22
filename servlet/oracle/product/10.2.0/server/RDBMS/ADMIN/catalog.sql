Rem
Rem $Header: catalog.sql 11-may-2005.17:26:33 svshah Exp $ catalog.sql
Rem
Rem Copyright (c) 1988, 2005, Oracle. All rights reserved.  
Rem
Rem NAME
Rem   CATALOG.SQL
Rem FUNCTION
Rem   Creates data dictionary views.
Rem NOTES
Rem   Must be run when connected AS SYSDBA
Rem
Rem MODIFIED
Rem     ansingh    05/04/05  - 3217740: remove rule hint in all_col_comments 
Rem     svshah     05/11/05  - Add gv$,v$mutex_sleep(_history) 
Rem     mtakahar   01/18/05  - #(3536027) fix wrong histogram type shown
Rem     sourghos   01/05/05  - Fix bug 4043119 
Rem     kumamage   12/12/04  - add gv$parameter_valid_values 
Rem     smuthuli   12/02/04  - move space quotas to catspace.sql
Rem     nireland   11/09/04  - Fix display of pctversion/retention. #3844939 
Rem     wyang      11/01/04  - bug 3981575 
Rem     rvissapr   10/26/04  - remove linksencoding views 
Rem     araghava   10/25/04 - 3448802: don't use partobj$ to get blocksize in 
Rem                           *_LOBS 
Rem     sourghos   10/20/04  - Add comments for clb_goal 
Rem     sourghos   10/19/04  - Adding comments for CLB_GOAL 
Rem     sourghos   10/14/04  - clb_goal has been added 
Rem     sourghos   10/13/04  - Fix bug 3936900 by adding clb_goal in 
Rem                            catalog.sql 
Rem     pthornto   10/07/04  - 
Rem     rburns     09/13/04  - check for SYS user 
Rem     pthornto   10/05/04  - add view DBA_CONNECT_ROLE_GRANTEES 
Rem     jmzhang    08/26/04  - change v$phystdby_status to v$dataguard_stats
Rem                          - add gv/v$standby_threadinfo
Rem     clei       09/10/04  - fix *_encrypted_columns
Rem     mtakahar   06/07/04  - mon_mods$ -> mon_mods_all$
Rem     jmzhang    08/17/04  - add v$phystdby_status
Rem     jmzhang    07/25/04  - add gv$rfs_thread
Rem     mhho       07/20/04  - add wallet views
Rem     clei       06/29/04  - add dictionary views for encrypted columns
Rem     bsinha     06/17/04  - restore_point privilege changes 
Rem     svshah     06/28/04  - Public synonyms for v$, gv$ sqlstats
Rem     bhabeck    06/14/04  - add v$process_memory_detail synonyms 
Rem     suelee     05/29/04  - Add v$rsrc_plan_history 
Rem     kumamage   06/03/04  - add interconnect views 
Rem     bdagevil   06/19/04  - add [g]v$sqlstats and [g]v$sqlarea_plan_hash 
Rem     sridsubr   06/04/04  - Add new RM Stat views 
Rem     gmulagun   05/30/04  - add v$xml_audit_trail 
Rem     jnarasin   05/26/04  - Alter User changes for EUS Proxy project 
Rem     kpatel     05/18/04  - add v$asm_diskgroup_stat and v$asm_disk_stat
Rem     bhabeck    05/13/04  - add public synonyms for g/v$process_memory 
Rem     rvissapr   05/19/04  - mark password column deprecated 
Rem     narora     05/19/04  - add v$streams_pool_advice 
Rem     nikeda     04/12/04  - [OCI Events] Add Notifications enable/disable 
Rem     tcruanes   05/27/04  - add SQL_JOIN_FILTER fixed view synonyms 
Rem     rramkiss   05/13/04  - Update objects views for scheduler chains
Rem     jciminsk   04/28/04  - merge from RDBMS_MAIN_SOLARIS_040426 
Rem     jciminsk   04/07/04  - merge from RDBMS_MAIN_SOLARIS_040405 
Rem     ckantarj   02/27/04  - add cardinality columns to service$ 
Rem     jciminsk   02/06/04  - merge from RDBMS_MAIN_SOLARIS_040203 
Rem     jciminsk   12/12/03  - merge from RDBMS_MAIN_SOLARIS_031209 
Rem     jciminsk   08/19/03  - branch merge 
Rem     ckantarj   07/16/03  - add TAF column comments for service$
Rem     bbhowmic   01/20/04  - #3370034: USER_NESTED_TABLES DBA_NESTED_TABLES 
Rem     pokumar    05/11/04  - add v$sga_target_advice view 
Rem     dsemler    05/03/04  - fix dba_services view decode 
Rem     dsemler    04/13/04  - update views on service$ to add goal 
Rem     wyang      04/27/04  - transportable db 
Rem     molagapp   05/22/04  - add v$flash_recovery_area_usage
Rem     ahwang     05/07/04  - add restore point synonyms 
Rem     mxyang     05/10/04  - add plsql_ccflags
Rem     alakshmi   04/19/04  - system privilege READ_ANY_FILE_GROUP 
Rem     alakshmi   04/14/04  - File Groups 
Rem     smangala   04/16/04  - add logmnr_dictionary_load view 
Rem     vshukla    05/06/04  - add STATUS field to *_TABLES views 
Rem     vmarwah    04/08/04  - Bug 3255906: Do not show RB objects in *_TABLES
Rem     mjaeger    02/26/04  - bug 3369744: all_synonyms: include syns for syns
Rem     nlee       02/24/04  - Fix for bug 3431384.
Rem     bbhowmic   01/20/04  - #3370034: USER_NESTED_TABLES DBA_NESTED_TABLES
Rem     mtakahar   12/18/03  - fix NUM_BUCKETS/HISTOGRAM columns
Rem     najain     12/08/03  - change all_objects: use xml_schema_name_present
Rem     weili      11/18/03  - use RBO for ALL_TAB_COLUMNS & ALL_COL_COMMENTS
Rem     qyu        11/12/03  - add v$timezone_file
Rem     arithikr   11/02/03  - 3121812 - add drop_segments column to mon_mods$
Rem     hqian      10/27/03  - OSM -> ASM
Rem     vraja      10/20/03  - bug3161569: rename DBA_TRANSACTION_QUERY to
Rem                            FLASHBACK_TRANSACTION_QUERY
Rem     rvenkate   10/14/03  - remove buffered from propagation views
Rem     nireland   10/01/03  - Remove dba_procedures grant. #3157539
Rem     agardner   09/10/03  - bug#2658177: ind_columns to report user
Rem                            attribute name rather than sys generated name
Rem     rburns     09/09/03  - cleanup
Rem     qyu        08/27/03  - tab_cols: qualified_col_names, add nested_table_cols
Rem     mlfeng     08/06/03  - change v$svcmetric to v$servicemetric
Rem     kmeiyyap   08/22/03  - buffered propagation views
Rem     skaluska   08/25/03  - fix merge problems
Rem     sdizdar    08/22/03  - remove GV_$RMAN_STATUS_CURRENT
Rem     jawilson   08/08/03  - Remove streams_pool_advice view
Rem     nmacnaug   08/13/03  - add instance cache transfer table
Rem     ckantarj   07/16/03  - add TAF column comments for service$
Rem     ajadams    08/13/03  - add logmnr_latch
Rem     alakshmi   07/17/03  - List types for streams apply/capture objects
Rem     dsemler    07/03/03  - add public synonyms for v$services and gv$services
Rem     vmarwah    06/30/03  - Fix TABLE views for including Dropped Col
Rem     kigoyal    07/16/03  - add v$service_event and v$service_wait_class
Rem     vraja      06/18/03  - decode(commit_scn) in dba_transaction_query
Rem     smuthuli   06/18/03  - add PARTITIONED col to *_LOBS views
Rem     koi        06/17/03  - 2994527: change *_TABLES for IOT LOGGING
Rem     dsemler    06/06/03  - Fix bug where dba/all_services report deleted services
Rem     molagapp   03/28/03  - add type privilege to recovery_catalog_owner
Rem     rpang      05/15/03  - add *_plsql_object_settings views
Rem     njalali    05/12/03  - changing ALL_OBJECTS to use ALL_XML_SCHEMAS2
Rem     bdagevil   05/08/03  - grant select on v$advisor_progress to public
Rem     bdagevil   04/28/03  - merge new file
Rem     skaluska   04/16/03  - add v$tsm_sessions
Rem     raguzman   03/10/03  - move catlsby from catalog to catproc
Rem     abagrawa   03/12/03  - Fix all_objects for XML schemas
Rem     kquinn     03/07/03  - 2644204: speed up index_stats
Rem     jawilson   02/03/03  - add public synonyms for V$BUFFERED_QUEUES
Rem     vraja      02/12/03  - grant select to public on DBA_TRANSACTION_QUERY
Rem     tfyu       02/14/03  - Bug 2803767
Rem     ruchen     01/29/03  - add public synonym for px_buffer_advice
Rem     kigoyal    01/29/03  - adding v$temp_histogram
Rem     evoss      01/06/03  - scheduler fixed views
Rem     rramkiss   01/13/03  - add job scheduler object types
Rem     bdagevil   03/16/03  - add [g]v$advisor_progress dynamic view
Rem     dsemler    02/18/03  - fix the all_services synonym
Rem     lilin      12/19/02  - add fixed table instance_log_group
Rem     gngai      01/15/03  - added synonyms for V$ metric views
Rem     smuthuli   01/18/03  - add tablespace_name to *_lobs views
Rem     wyang      12/19/02  - user_resumable use user#
Rem     dsemler    12/06/02  - create dba, all views for services
Rem     asundqui   12/04/02  - add (g)v$osstat
Rem     schakkap   12/17/02  - fixed table stats
Rem     asundqui   12/04/02  - add (g)v$osstat
Rem     srseshad   12/03/02  - dty code change for binary float/double
Rem     rburns     11/30/02  - postpone validation
Rem     nmacnaug   11/14/02  - add current_block_server view
Rem     gtarora    11/25/02  - xxx_LOBS: new column
Rem     jwlee      11/07/02  - add v$flashback_database_stat
Rem     gngai      12/31/02  - added synonyms for Metric views
Rem     msheehab   10/29/02  - Add V$AW_LONGOPS for olap
Rem     vraja      10/28/02  - add DBA_TRANSACTION_QUERY
Rem     aramarao   10/26/02  - 2643490 change all_objects definition to
Rem                            include clusters
Rem     mtakahar   10/31/02  - reverted the x$ksppcv change due to #(2652698)
Rem     yhu        10/29/02  - handle native data type in _INDEXTYPE_ARRAYTYPES
Rem     wwchan     10/11/02  - add v$active_services
Rem     kpatel     10/15/02  - add fixed view for sga info
Rem     veeve      10/11/02  - added synonym for [g]v$active_session_history
Rem     sdizdar    10/10/02  - add V$RMAN_STATUS and V$RMAN_OUTPUT
Rem     molagapp   09/27/02  - Add v$_recovery_file_dest table
Rem     mtakahar   10/15/02  - put x$ksppi and x$ksppcv in the select list
Rem     weiwang    10/01/02  - add v$rule
Rem     vmarwah    10/04/02  - Undrop Tables: add BASE_OBJ to RecycleBin views
Rem     cluu       10/06/02  - rm v$mts
Rem     swerthei   08/15/02  - block change tracking
Rem     gkulkarn   09/30/02  - 10.1 extensions to LOG_GROUPS view
Rem     asundqui   09/24/02  - add v$enqueue_statistics, v$lock_type
Rem     btao       09/30/02  - add managability advisor script
Rem     mtakahar   09/24/02  - #(2585900): switch order of x$ksppi and x$ksppcv
Rem     apareek    09/20/02  - create synonym for cross transportable views
Rem     mtakahar   09/19/02  - show monitoring=NO for external tables
Rem     kigoyal    10/01/02  - v$session_wait_class, v$system_wait_class
Rem     mtakahar   09/24/02  - #(2563435): fix *_tab_modifications
Rem     vmarwah    09/04/02  - Undrop Tables: modify RecycleBin$ views.
Rem     mtakahar   08/26/02  - tie monitoring to _dml_monitoring_enabled
Rem     yhu        09/11/02  - indextype for array insert
Rem     kigoyal    09/13/02  - adding V$SESSION_WAIT_HISTORY
Rem     cluu       08/21/02  - add v$dispatcher_config, remove v$mts
Rem     asundqui   07/31/02  - consumer group mapping
Rem     mtakahar   08/06/02  - #(2352663) fix num_buckets, add histogram col
Rem     mdcallag   08/20/02  - support binary_float and binary_double
Rem     gssmith    08/21/02  - Adding new Manageability Advisor script
Rem     hbaer      08/08/02  - bug 2474106: added compression to *_TABLES
Rem     mjstewar   09/01/02  - Add flashback views
Rem     vmarwah    07/19/02  - Undrop Tables: Remove DROPPED_BY from RecycleBin
Rem     tchorma    07/23/02  - Support WITH COLUMN CONTEXT clause for operators
Rem     mlfeng     07/17/02  - public synonym for (g)v$sysaux_occupant
Rem     abrumm     07/11/02  - Bug #2427319: external tables have no tablespace
Rem     cchiappa   07/16/02  - Add V$AW_{AGGREGATE,ALLOCATE}_OP
Rem     gssmith    08/06/02  - Adding Advisor components
Rem     aime       06/27/02 -  remove v_$backup_files and v_$obsolete_backup_fi
Rem     pbagal     06/26/02  - Add v$osm_operation
Rem     sdizdar    02/14/02  - add V$OBSOLETE_BACKUP_FILES and V$BACKUP_FILES
Rem     xuhuali    07/02/02  - add v$javapool
Rem     mxiao      06/17/02  - donot show comments for MV in *_TAB_COMMENTS
Rem     dcwang     06/11/02  - modify rules privilege
Rem     qyu        05/29/02  - fix ts in xxx_LOBS
Rem     smcgee     06/10/02  - Add V$DATAGUARD_CONFIG fixed view.
Rem     kigoyal    08/05/02  - adding v$event_histogram and v$file_histogram
Rem     bdagevil   07/28/02  - add views exposing compile environment
Rem     tkeefe     05/23/02  - Add support for new credential type in PROXY
Rem                            views
Rem     rburns     05/06/02  - remove v$mls_parameters
Rem     nireland   04/29/02  - Fix user_sys_privs. #2321697
Rem     pbagal     04/18/02  - Add synonyms for OSM_VIEWS.
Rem     rburns     04/01/02  - use default registry banner
Rem     echong     04/10/02  - redundant pkey elim. for iot sec. idx
Rem     vmarwah    03/14/02  - Undrop Tables: Creating views over RecycleBin$.
Rem     yuli       04/22/02  - 10.1 irreversible compatibility
Rem     skaluska   04/04/02  - add v$rule_set.
Rem     rburns     02/11/02  - add registry version
Rem     kpatel     01/12/02  - add dynamic sga stats
Rem     emagrath   01/09/02  - Elim. endian REF problem
Rem     weiwang    01/04/02  - change definition of all_objects for rules
Rem                            engine objects
Rem     qcao       01/07/02  - fix bug 2168748
Rem     rburns     10/26/01  - add registry validation
Rem     cfreiwal   11/14/01  - move logstby views to catlsby.sql
Rem     sbalaram   11/02/01  - Remove catstr.sql
Rem     apadmana   10/26/01  - catlrep.sql to catstr.sql
Rem     sichandr   11/05/01  - _OBJECTS : handle XMLSchemas
Rem     weiwang    08/07/01  - add evaluation context
Rem     weiwang    07/17/01  - add rule and ruleset to object views
Rem     narora     06/28/01  - add catlrep
Rem     smangala   05/21/01  - add logmnr_stats.
Rem     qiwang     04/29/01  - add catlsby.sql
Rem     molagapp   06/01/01  - add v$database_incarnation changes
Rem     cmlim      10/31/01  - update object_id_type in ref views for unscoped
Rem                            pkrefs
Rem     ayoaz      10/16/01  - change decode-0 to nvl2 for coltype$.synobj#
Rem     somichi    10/19/01  - #(2050584) eliminate unprepared txn
Rem     bdagevil   10/18/01  - fix error on merge
Rem     qcao       10/18/01  - add tablespace_name to dba_object_stats
Rem     esoyleme   10/10/01  - add v$olap
Rem     vshukla    10/16/01  - fix wrong decode values in *_objects for lob
Rem                            (sub)partitions.
Rem     kpatel     10/04/01  - add shared_pool_advice, library_cache_memory
Rem     smuthukr   10/08/01  - fix pga_target_advice_histogram name length
Rem     wojeil     10/30/01  - adding v$ file mapping synonyms.
Rem     rburns     10/01/01  - fix public synonyms, remove drops
Rem     bdagevil   10/04/01  - add v$pga_target_advice_histogram
Rem     smuthukr   09/20/01  - add v$pga_target_advice
Rem     mzait      09/28/01  - support row source execution statistics
Rem     yuli       10/03/01  - add (g)v$statistics_level
Rem     smuthukr   09/10/01  - rename v$sort_usage to v$tempseg_usage
Rem     ayoaz      08/31/01  - change _OBJECT_TABLES view to to get syn by join
Rem     mmorsi     08/29/01  - use create or replace instead of drop & create
Rem     bdagevil   09/01/01  - add v$sql_workarea_histogram
Rem     ayoaz      08/21/01  - Support type synonyms in column types
Rem     sdizdar    08/05/01  - add v$backup_spfile and gv$backup_spfile
Rem     smangala   05/21/01  - add logmnr_stats.
Rem     qiwang     04/29/01  - add catlsby.sql
Rem     nireland   07/26/01  - Fix DBA_JOIN_IND_COLUMNS synonym. #1901895
Rem     smcgee     08/14/01  - phase 1 of DG monitoring project.
Rem     yuli       06/19/01  - add (g)v$MTTR_TARGET_ADVICE
Rem     vmarwah    07/10/01  - add processing for RETENTION LOB storage option.
Rem     gtarora    06/05/01  - replace type$ toid with tvoid
Rem     swerthei   04/03/01  - add v$database_block_corruption
Rem     sbedarka   05/16/01  - #(1775864) decode refact in xxx_constraints
Rem     gviswana   05/24/01  - CREATE OR REPLACE SYNONYM
Rem     gtarora    05/24/01  - inheritance support
Rem     narora     04/24/01  - correction for sqlplus
Rem     narora     04/16/01  - fix USER_NESTED_TABLES,ALL_NESTED_TABLES
Rem     narora     04/16/01  - DBA_NESTED_TABLES: join user$.user# with
Rem                          - parent table's obj$.owner#
Rem     tkeefe     04/11/01  - Fix comment.
Rem     eyho       04/11/01  - reduce identifier length for rac view
Rem     htseng     04/12/01  - eliminate execute twice (remove ;).
Rem     rguzman    04/04/01  - Remove catlsby call until 9iR2.
Rem     rjanders   04/06/01  - Add v$dataguard_status view.
Rem     qyu        03/29/01  - remove ; at the end of xxx_lobs
Rem     sagrawal   03/30/01  - fix procedureinfo$ based views
Rem     tkeefe     04/04/01  - Drop PROXY_ROLES public synonym before
Rem                            trying to create it.
Rem     eyho       04/03/01  - rac name changes
Rem     weiwang    04/09/01  - fix invalid column error in all_lobs & dba_lobs
Rem     ssubrama   03/22/01 -  bug1682637 modify dba_tab_col_statistics
Rem     cunnitha   03/27/01  - #(1642865):add subpartn to all_objects
Rem     tkeefe     03/22/01  - Add data dictionary views for n-tier.
Rem     vle        03/23/01  - bug 1651458
Rem     arithikr   03/15/01  - 1645892: remove drop recovery_catalog_owner role
Rem     smuthuli   03/15/01  - pctused = null for bitmap segments
Rem     qyu        03/14/01  - #1331689: fix xxx_lobs
Rem     tkeefe     03/06/01  - Simplify normalization of n-tier schema.
Rem     sbedarka   02/27/01  - #(1231780) add xxx_tab_cols view family
Rem     mtakahar   02/26/01  - add join order hints to *_tab_histograms
Rem     bdagevil   03/02/01  - add v$pgastat
Rem     wwchan     03/01/01  - adding new ops views
Rem     nshodhan   02/06/01  - Remove dba_consistent_read
Rem     sagrawal   01/08/01  - flags for procedureinfo
Rem     dpotapov   12/27/00  - bugs 954684-954669.
Rem     evoss      12/09/00  - add [g]v.sql_redirection
Rem     bemeng     12/11/00  - change v$object_stats to v$object_usage
Rem     rjenkins   11/22/00  - add char_length, char_used to arguments
Rem     sbedarka   11/21/00  - (1231780) backout txn
Rem     cku        11/17/00 - PBMJI.
Rem     tchou      11/20/00 - add support for ejb generated classes
Rem     spsundar   11/17/00 - fix *_indexes view for tablespace name
Rem     rwessman   11/17/00 - Backed out tab_ovf$ due to problems in upgrade an
Rem     bpanchap   10/10/00 -  Adding sequence_no to all_sumdelta
Rem     kquinn     11/17/00 - 1375879: alter operator -> alter any operator
Rem     heneman    10/20/00 - Rename MTS.
Rem     thoang     10/06/00 - add new columns to tab_columns view
Rem     clei       10/02/00 - add gv$vpd_policy and v$vpd_policy
Rem     qyu        09/25/00 - grant v$timezone_names to public
Rem     shihliu    09/11/00 - resumable view fix
Rem     rburns     09/08/00 - sqlplus fixes
Rem     smuthuli   07/18/00 - fix dba_rollback_segs for SMU.
Rem     sbedarka   08/21/00  - #(1188948) materialized view object type
Rem     kosinski   07/09/00 - Add dba_stored_settings
Rem     rmurthy    08/16/00 - add hierarchy option to tab_privs views
Rem     nireland   07/31/00 - Fix dba_profiles for verify_function. #843856
Rem     spsundar   10/17/00 -  fix *_indexes to reflect null tblspc for dom idx
Rem     kumamage   07/27/00 -  add v$spparameter and gv$spparameter
Rem     rjanders   07/31/00 -  add gv$archive_gap
Rem     svivian    07/25/00 -  add gv$logstdby_stats
Rem     amozes     07/17/00  - bitmap join index
Rem     evoss      07/26/00  - add external table catalog views
Rem     schatter   07/07/00  - add v$enqueue_stat
Rem     bdagevil   07/26/00  - add v$sql_memory_usage
Rem     rmurthy    07/25/00  - add superview info to xxx_views
Rem     rjenkins   05/05/00  - make char_used null for nonstrings
Rem     sdizdar    07/05/00  - RMAN configuration:
Rem                          - add create/drop v_$rman_configuration
Rem     shihliu    06/26/00 - fix dba(user)_resumable column name
Rem     kosinski   06/12/00  - Persistent parameter views
Rem     ayalaman   07/05/00 -  dba_object_tables fix for sqlplus
Rem     lsheng     06/26/00  - change user_, all_, dba_constraints definition.
Rem     rmurthy    06/19/00  - change objauth.option to flag bits
Rem     rmurthy    06/23/00  - xxx_ind_columns:handle attribute names correctly
Rem     rmurthy    06/30/00  - add XXX_PROCEDURES views
Rem     bdagevil   06/05/00  - add v$sql_workarea_active
Rem     bdagevil   06/05/00  - add v$sql_workarea
Rem     bdagevil   06/05/00  - add v$sql_plan
Rem     rjanders   07/05/00 -  Correct v$standby_log definition.
Rem     wnorcott   06/08/00 -  catcdc.sql
Rem     qyu        06/12/00  - DLS: add v$timezone_names, gv$timezone_names
Rem     arhee      06/08/00  - add new Resource Manager views
Rem     rwessman   06/08/00  - N-Tier enhancements
Rem     svivian    06/15/00 -  add logstdby fixed view
Rem     shihliu    05/29/00  - resumable views
Rem     smuthuli   04/06/00  - SMU: Add v$undostat and gv$undostat
Rem     ayalaman   06/08/00 -  guess stats for IOT with mapping table
Rem     atsukerm   05/26/00  - add database_properties view..
Rem     bemeng     05/25/00  - add new view v$object_stats
Rem     liwong     05/19/00  - Add dba_consistent_read
Rem     nagarwal   06/20/00  - add partition_name to *_ustat views
Rem     wixu       04/25/00  - wixu_resman_chg
Rem     tlahiri    04/17/00 -  Add cache size advisory views
Rem     ayalaman   04/14/00 -  key compress suggestion in index_stats
Rem     nagarwal   04/20/00  - fix *_ustat views for partitioned domain indexes
Rem     rjanders   03/30/00 -  Add missing managed standby views.
Rem     najain     03/30/00  - support for v$sql_shared_memory
Rem     rguzman    03/17/00 -  Add views for log groups, exclude log groups fro
Rem     nagarwal   03/31/00  - fix ustat view privileges
Rem     nagarwal   03/21/00  - add partition info to ustat views
Rem     rguzman    04/11/00 -  Logical Standby views and tables
Rem     ayalaman   03/20/00 -  index_stats fix for key compressed indexes
Rem     ayalaman   03/28/00 -  overflow statistics for IOT
Rem     ayalaman   04/04/00 -  iot with mapping table
Rem     rjenkins   02/08/00  - extended unicode support
Rem     nagarwal   03/09/00  - populate version info to association views
Rem     mwjohnso   03/15/00 -  Add $archive_dest_status
Rem     gkulkarn   03/14/00 -  Adding synonyms for LogMiner 8.2 fixed views
Rem     rjanders   03/09/00 -  Add V$MANAGED_STANDBY views.
Rem     rjenkins   02/02/99  - report the index being used by constraints
Rem     nagarwal   03/02/00  - add partition info to ustat views
Rem     nireland   02/01/00  - Fix line length related ORA-942. #1175426
Rem     spsundar   02/14/00 -  update *_indexes views
Rem     nagarwal   01/13/00  - add partitioning info to indextype views
Rem     jklein     01/19/00  -
Rem     nireland   12/20/99  - Add subpartitions to index_stats. #1114064
Rem     nagarwal   01/07/00  - add partition column to indextype views
Rem     yuli       12/28/99  - remove v$targetrba
Rem     nireland   11/20/99  - Fix #691329
Rem     jklein     11/30/99  - row seq #
Rem     liwong     10/13/99  - Expose opaque types in %_tab_columns
Rem     nagarwal   10/29/99 -  fix views for extensible indexing
Rem     attran     09/22/99 -  PIOT: TAB$/blkcnt
Rem     nagarwal   10/02/99  - Add views for extensible indexing - 8.2
Rem     nireland   09/17/99  - Fix ALL_SYNONYMS. #641756
Rem     hyoshiok   10/05/99 -  lrg regression
Rem     hyoshiok   08/31/99 -  #915791, add CLUSTER_OWNER in dba_tables
Rem     nagarwal   09/21/99 -  fix extensible indexing views
Rem     qyu        07/27/99 -  keep YES/NO of cache column in xxx_LOBS
Rem     attran     07/13/99 -  PIOT:pctused$/iotpk_objn
Rem     kosinski   08/13/99 -  Bug 822440: Add PLS_TYPE to *_ARGUMENTS
Rem     anithrak   08/06/99 -  Add V$BUFFER_POOL_STATISTICS
Rem     thoang     07/13/99  - Not using spare1 for datetime
Rem     tnbui      07/21/99  - Implicit -> Local
Rem     kensuzuk   07/14/99 -  Bug932236: fix XXX_TABLES, XXX_OBJECT_TABLES
Rem     evoss      07/11/99  - add  v$hs_parameter synonyms
Rem     mjungerm   06/15/99 -  add java shared data object type
Rem     tnbui      06/24/99  - change in user_arguments
Rem     tnbui      06/18/99  - TIMESTAMP WITH IMPLICIT TZ
Rem     rwessman   06/08/99 -  Bug 895111 - select on v$session_connect_info no
Rem     rshaikh    05/24/99 -  bug 897514: add com on tabs for DICTIONARY view
Rem     bnnguyen   06/01/99 -  bug837941
Rem     amganesh   05/05/99 -  Fast-Start nomenclature change
Rem     nireland   04/22/99 -  Add LOBs to dba_objects and all_objects #852521
Rem     sbedarka   04/16/99 -  #(816507) optimize [user|dba]_role_privs views
Rem     qyu        03/04/99 -  add CACHE READS lob mode
Rem     rshaikh    03/18/99 -  bug 685170: make nls_* value columns longer for
Rem     rshaikh    03/10/99 -  fix typo in ALL_INDEXES comment
Rem     qyu        03/04/99 -  add CACHE READS lob mode
Rem     rshaikh    02/22/99 -  fix bugs 322891,170720
Rem     rherwadk   02/12/99 -  compatibility for parameter tables & views
Rem     rmurthy    12/24/98 -  changes to *_INDEXES for domain indexes
Rem     rmurthy    12/24/98 -  changes to *_INDEXES views (bgoyal)
Rem     rmurthy    11/17/98 -  fix indextype views
Rem     tlahiri    11/09/98 -  Add (g)v_instance_recovery views
Rem     nireland   11/08/98 -  clu$.spare4 is now avgchn. #736363
Rem     spsundar   11/03/98 -  modify *_indexes views to reflect invalid status
Rem     atsukerm   10/12/98 -  fix UROWID type in ARGUMENTS views.
Rem     dmwong     09/23/98  - move application context views to catproc
Rem     sbedarka   09/03/98 -  #(709058) coerce datatype for decoded date expr
Rem     kmuthiah   09/20/98  - added IND_EXPRESSIONS views
Rem     akruglik   08/24/98  - fix for bug 717826:
Rem                              correct definition of ROW_MOVEMENT column
Rem     amozes     07/24/98  - global index stats
Rem     ncramesh   08/06/98 -  change for sqlplus
Rem     smuthuli   07/30/98 -  Bug 696705
Rem     bgoyal     08/06/98  - change *_INDEXES to show DISABLED status
Rem     qyu        08/17/98 -  706957: fix xxx_LOBS
Rem     rshaikh    07/30/98 -  add DATABASE_COMPATIBLE_LEVEL
Rem     wnorcott   08/20/98 -  Get rid of SUMMARY from XXX_OBJECTS
Rem     qyu        07/20/98 -  bug428835, fix xxx_col_comments
Rem     sbedarka   07/17/98 -  #(664195) user_ind_columns modified for perform
Rem     spsundar   07/23/98 -  add ityp_name and parameters to *_indexes
Rem     amozes     08/24/98  - expose endpoint actual value
Rem     sagrawal   06/25/98 -  DTYRID
Rem     rshaikh    06/22/98 -  move catsvrmg to catproc.sql
Rem     arhee      06/15/98 -  shorten name of rsrcmgr view
Rem     akalra     06/12/98 -  inicongroup -> defschclass
Rem     akalra     06/01/98  - Add inicongroup to dba_users, user_users
Rem     nagarwal   06/11/98 -  fix privs on _ustats and _association views
Rem     ayalaman   06/12/98 -  add guess stats to *_indexes
Rem     rjanders   06/01/98 -  Add GV$ARCHIVE_PROCESSES/V$ARCHIVE_PROCESSES vie
Rem     arhee      05/26/98 -  new names for db resource manager
Rem     ayalaman   06/05/98 -  index compression : fix index views
Rem     nagarwal   05/25/98 -  remove rpad from ustats views
Rem     ajoshi     05/22/98 -  Add gv_targetrba
Rem     bgoyal     05/18/98 -  remove *_TABLESPACES from catalog.sql
Rem     qyu        05/08/98 -  add views xxx_VARRAYS
Rem     mcusson    05/11/98 -  Name change: LogViewr -> LogMnr.
Rem     tnbui      05/12/98 -  Re-number datetime types
Rem     anithrak   05/12/98 -  Add V$RESERVED_WORDS
Rem     nagarwal   05/12/98 -  Modify ustat views for new properties
Rem     swerthei   02/17/98 -  add synonyms for backup I/O views
Rem     swerthei   04/13/98 -  add proxy_datafile, proxy_archivelog fixed views
Rem     mcoyle     05/06/98 -  Add GV$BLOCKED_LOCKS
Rem     qyu        05/01/98  - add storage_spec,return_type to *_NESTED_TABLES
Rem     lcprice    05/07/98 -  fix merge errors in *_tables
Rem     lcprice    05/06/98 -  add skip corrupt to dba_tables
Rem     bgoyal     05/07/98  - remove user_tablespaces from catalog.sql, a merg
Rem     bgoyal     04/17/98  - fix row_movement in user_*tables
Rem     weiwang    04/03/98 - add more types in user_objects
Rem     amozes     04/30/98 -  add modification information views
Rem     ato        04/30/98 -  add queues
Rem     spsundar   04/29/98 - add domain indexes to user_ustats view
Rem     kmuthiah   05/01/98 -  add cols. to user_refs and user_object_tables to
Rem     ajoshi     04/20/98 -  add targetrba view
Rem     rwessman   04/01/98 -  Added support for N-tier authentication
Rem     dmwong     04/13/98 -  fix privilege of KZSCAC and KZSDAC in ALL_OBJECTS
Rem     nagarwal   04/10/98 -  Update views for operator
Rem     rpark      04/10/98 -  add v$temporary_lob entries
Rem     syeung     02/25/98 -  add table subpartition to sys_objects list
Rem     pamor      04/10/98  - PX fixed tables
Rem     bhimatsi   04/14/98 -  bitmap ts - fixed view synonyms
Rem     dmwong     04/02/98 - support for app ctx
Rem     nagarwal   04/10/98 -  Add views for user defined stats
Rem     amozes     03/27/98  - add new stats information
Rem     rfrank     04/08/98 -  add log viewer views
Rem     pamor      03/31/98 -  add v$px_session v$px_sesstat
Rem     thoang     04/01/98 -  Define datetime/interval datatypes
Rem     amganesh   03/27/98 -  new views
Rem     thoang     03/27/98  - Add partial_drop_tabs view
Rem     alsrivas   03/30/98 -  removing FILTER info from indextype views
Rem     rjenkins   03/02/98  - adding DESCEND to index columns
Rem     wnorcott   03/28/98 -  Fix all_objects summary # 38-->42
Rem     araghava   03/25/98 -  Add ROW_MOVEMENT to *_TABLES.
Rem     ayalaman   03/27/98 -  use 2 bytes of pctthres for guess quality
Rem     arhee      03/19/98 -  add db scheduler views
Rem     atsukerm   03/24/98 -  add v$obsolete_parameter view.
Rem     kquinn     03/10/98 -  638499: Correct quoted string problems
Rem     eyho       03/10/98 -  add v$dlm_all_locks
Rem     syeung     02/25/98 -  add table subpartition to sys_objects list
Rem     pravelin   02/10/98  - Add HS fixed views
Rem     bhimatsi   03/07/98 -  bitmapped ts - reinstate index_stats
Rem     atsukerm   03/04/98 -  add UROWID column type to arguments and columns
Rem     vkarra     02/10/98 -  single table hash clusters
Rem     cfreiwal   02/24/98 -  key compression : index stats
Rem     thoang     12/12/97 -  Modified views to exclude unused columns.
Rem     rjenkins   01/20/98 -  functional indexes again
Rem     nagarwal   02/19/98 -  Modify optimizer views
Rem     nagarwal   12/30/97 -  Fix access privs on operator views
Rem     wbridge    01/16/98 -  eliminate v$current_bucket, v$recent_bucket
Rem     ato        01/14/98 -  merge from 8.0.4
Rem     nagarwal   12/28/97 -  Add views for extensible optimizer
Rem     akruglik   01/21/98 -  update definitions of _OBJECTS views to
Rem                            display LOB PARTITION and LOB SUBPARTITION
Rem     bhimatsi   02/24/98 -  bitmapped ts - dba_tablespace,data_files etc. vi
Rem     bhimatsi   01/20/98 -  bitmapped ts - dba_data_files
Rem     bnnguyen   12/22/97 -  bug555033
Rem     nagarwal   12/17/97 -  Fix _OPBINDING views
Rem     mcoyle     11/14/97 -  Change v$lock_activity to public
Rem     mjungerm   11/07/97 -  Add Java
Rem     skaluska   11/07/97 -  Add v$rowcache_parent, v$rowcache_subordinate
Rem     wesmith    11/06/97  - sumdelta$ shape change
Rem     jsriniva   11/17/97 -  iot: fix merge problem
Rem     jsriniva   11/17/97 -  move key compression attribute to flag
Rem     spsundar   11/03/97 -  fix views with secondary objects
Rem     rmurthy    10/28/97 -  fix status in index views
Rem     jsriniva   11/16/97 -  iot: add key-compression fields to ALL|USER|DBA_
Rem     rmurthy    10/23/97 -  merge from 8.0.4
Rem     nagarwal   10/23/97 -  Merge fix - decode # for operators
Rem     tnbui      10/21/97 -  Add new column RELY for xxx_CONSTRAINTS view
Rem     spsundar   10/13/97 -  update object views for secondary objects
Rem     spsundar   10/08/97 -  update index views for incomplete domain index
Rem     jingliu    10/06/97 -  Add view all_sumdelta
Rem     jfeenan    12/16/97 -  Add support for summaries to all_objects
Rem     jfeenan    11/06/97 -  add catsum.sql
Rem     bhimatsi   12/27/97 -  enhance dba_data_files for bitmapped tablespaces
Rem     thoang     09/26/97 -  Remove comma before FROM keyword
Rem     tlahiri    09/15/97 -  Add v$current_bucket, v$recent_bucket
Rem     nbhatt     09/15/97 -  change V$/GV$ aq_statistics to v$ gv$aq1
Rem     wuling     07/22/97 -  GV$, and V$RECOVERY_PROGRESS: creation
Rem     hyoshiok   09/05/97 -  nls_session_parameters; remove NLS_NCHAR_CHARACT
Rem     varora     09/10/97 -  fix tab_columns views to filter out nested table
Rem     whuang     09/09/97 -  expose the reverse index inform.
Rem     nbhatt     08/27/97 -  add v$aq_statistics
Rem     mcoyle     08/22/97 -  Add v,gv$ lock_activity - moved from catparr.sql
Rem     gpongrac   08/21/97 -  add v_$kccdi
Rem     gpongrac   08/20/97 -  add v_$kccfe view and grant to system
Rem     mkrishna   08/04/97 -  (bug 517730) change UPDATABLE_COLUMNS views
Rem     isung      08/05/97 -  To add NCHAR column length in character unit at
Rem     nbhatt     08/07/97 -  add synonym for aq_statistics
Rem     spsundar   08/29/97 -  modify index views
Rem     nagarwal   09/03/97 -  Make changes wrt opbinding change
Rem     alsrivas   08/28/97 -  updating indextype views to reflect dictionary c
Rem     eyho       07/16/97 -  add v$dlm_locks
Rem     nireland   07/07/97 -  Definition of dba_users and user_users incorrect
Rem     mkrishna   06/27/97 -  move grant authorization to cat8003
Rem     asurpur    06/04/97 -  Fix definition for dba_roles: add global roles
Rem     mkrishna   05/27/97 -  change # to Rem
Rem     rjenkins   05/14/97 -  functional indexes
Rem     rpark      05/08/97 -  465138: assign a type for lobs in USER_OBJECTS
Rem     alsrivas   06/10/97 -  updating INDEXTYPE_OPERATORS role
Rem     spsundar   06/10/97 -  update index views to reflect domain indexes
Rem     alsrivas   05/28/97 -  updating views for indextype
Rem     mkrishna   04/30/97 -  Add comment line
Rem     skaluska   04/21/97 -  argument$ type support
Rem     syeung     05/07/97 -  pti 8.1 project
Rem     mkrishna   04/15/97 -  Fix bug 479090
Rem     dalpern    04/16/97 -  return of on-disk package STANDARD
Rem     jfischer   04/16/97 -  Add DLM Fixed Views
Rem     alsrivas   05/16/97 -  updating IndexType views to reflect dictionary c
Rem     alsrivas   05/12/97 -  adding views for indextypes
Rem     nagarwal   05/04/97 -  Change OPERATOR name to OPERATORS
Rem     nagarwal   05/02/97 -  Adding catalog entries for operators
Rem     tlahiri    04/10/97 -  Add OPS performance views
Rem     jsriniva   04/01/97 -  iot: fix *_tables to display tablspace correctly
Rem     atsukerm   03/28/97 -  add views on enqueues and transactions.
Rem     ssamu      04/03/97 -  support partition index in INDEX_STATS
Rem     vkrishna   03/24/97 -  remove PACKED
Rem     rjenkins   03/17/97 -  ENFORCE to ENABLE NOVALIDATE
Rem     atsukerm   03/25/97 -  add resource limit views.
Rem     aho        03/25/97 -  gv$buffer_pool
Rem     nlewis     03/25/97 -  add trusted_servers view
Rem     aho        03/22/97 -  fix syntax errors in  USER, ALL, & DBA_LOBS
Rem     rshaikh    03/17/97 -   fix bug 403882 on *_tables
Rem     esoyleme   03/17/97 -  add v$dispatcher_rate
Rem     aho        03/13/97 -  partitioned cache: v$buffer_pool
Rem     aho        02/28/97 -  partitioned cache: add comments for buffer_pool
Rem     aho        02/27/97 -  partitioned cache: add buffer_pool to views
Rem     hpiao      03/10/97 -  add catsnmp.sql
Rem     bhimatsi   03/07/97 -  inline lobs - enhance lob views
Rem     amozes     02/21/97 -  remove execution_location
Rem     tpystyne   02/17/97 -  create recovery_catalog_owner role
Rem     gdoherty   01/20/97 -  remove catsnmp, logs in as another user
Rem     rdbmsint   01/10/97 -  add catsnmp.sql
Rem     cxcheng    01/02/97 -  fix bug where non-existent type is included
Rem                            in table views output
Rem     atsukerm   12/16/96 -  change EXTENTS views to take advantage of ts#.
Rem     thoang     11/22/96 -  Update views for NCHAR
Rem     rjenkins   11/20/96 -  adding column BAD to constraint views
Rem     jwijaya    11/19/96 -  revise object terminologies
Rem     rshaikh    11/08/96 -  fix *_neste_tables views
Rem     jbellemo   11/07/96 -  DistSecDoms: add external to _USERS
Rem     rshaikh    10/25/96 -  add views for nested tables
Rem     amozes     11/05/96 -  qpm - execution tree location
Rem     tpystyne   11/07/96 -  add v$backup_device and v$archive_dest
Rem     rmurthy    10/23/96 -  support attribute names in REF views
Rem     schandra   10/22/96 -  global_transaction synonym - fix typo
Rem     tcheng     10/10/96 -  fix comments for {USER,ALL,DBA}_VIEWS
Rem     tcheng     10/10/96 -  add type owner and name to {USER,ALL,DBA}_VIEWS
Rem     schandra   09/16/96 -  Add GLOBAL_TRANSACTIONS view
Rem     jwijaya    10/03/96 -  add vsession_object_cache
Rem     rmurthy    09/25/96 -  modify views on REF columns
Rem     jsriniva   09/17/96 -  iot: fix include column comment
Rem     jsriniva   09/05/96 -  add inclcol to *_INDEXES
Rem     rmurthy    09/09/96 -  add views for REFS
Rem     rhari      08/30/96 -  Add USER_LIBRARIES, ALL_LIBRARIES, DBA_LIBRARIES
Rem     rxgovind   08/14/96 -  add catalog views for directory objects
Rem     jsriniva   08/12/96 -  fix iot catalogue changes
Rem     skaluska   08/09/96 -  Fix CACHE column for clu$ views
Rem     mcoyle     08/05/96 -  Add synonyms for global fixed views (GV$)
Rem     jsriniva   08/06/96 -  modify views to display iot physical attr
Rem     tcheng     08/01/96 -  show type text in {user,all,dba}_views
Rem     skaluska   07/31/96 -  Fix tab$ and clu$ views
Rem     rjenkins   07/24/96 -  enable vs enforce
Rem     jwijaya    07/25/96 -  test charsetform
Rem     rhari      07/23/96 -  LIBRARY as a PL/SQL object
Rem     atsukerm   07/22/96 -  put 'INDEX/TABLE partition' into OBJECTS views.
Rem     akruglik   07/10/96 -  modify definition of
Rem                            {user|dba|all}_{tables|indexes} to display
Rem                            NULL in place of LOGGING attribute of
Rem                            partitioned tables/indices
Rem     rjenkins   06/18/96 -  add GENERATED column name
Rem     jwijaya    06/14/96 -  check for EXECUTE ANY TYPE
Rem     jwijaya    06/19/96 -  fix COL
Rem     tcheng     06/25/96 -  add column comments for user_views
Rem     tpystyne   06/14/96 -  add v$datafile_header
Rem     atsukerm   06/13/96 -  fix EXTENT views.
Rem     asurpur    06/14/96 -  Fix dba_users and user_users for password manage
Rem     rjenkins   06/10/96 -  correct flag in user constraints
Rem     tcheng     06/11/96 -  change SYS_NC_ROWINFO$
Rem     vkrishna   06/10/96 -  change ROW_INFO to SYS_NC_ROW_INFO
Rem     jpearson   06/11/96 -  correct the EXP_DBA_OBJECTS view
Rem     tcheng     06/01/96 -  don't show hidden cols in *_updatable_columns
Rem     tcheng     05/30/96 -  enhance user_updatable_columns for views with tr
Rem     asurpur    05/30/96 -  Fix the views user_users and dba_users
Rem     mmonajje   05/20/96 -  Replace timestamp col name with timestamp#
Rem     bhimatsi   05/18/96 -  change in lob$ field names, fix views
Rem     rjenkins   05/17/96 -  novalidate constraints
Rem     asurpur    05/15/96 -  Dictionary Protection: Granting privileges
Rem     jsriniva   05/14/96 -  iot-related catalog changes
Rem     schandra   05/13/96 -  V$SORT_USAGE: Creation
Rem     atsukerm   05/13/96 -  change DBA_OBJECTS views to expose partition
Rem                            name and data object ID
Rem     jwijaya    05/06/96 -  add LOBS views
Rem     ajasuja    05/02/96 -  merge OBJ to BIG
Rem     jwijaya    04/29/96 -  check for EXECUTE ANY PROCEDURE for types
Rem     tpystyne   04/26/96 -  speedup DBA_DATA_FILES by eliminating outer join
Rem     jwijaya    04/26/96 -  filter out nested tables from _TABLES
Rem     jwijaya    04/23/96 -  fixed user_tables
Rem     bhimatsi   04/16/96 -  enhance views for lob segments and indexes
Rem     tcheng     04/16/96 -  enhance views on view$ to show typed_view$
Rem     vkrishna   04/09/96 -  fix user_tab_columns and user_tables view querie
Rem     asurpur    04/03/96 -  Dictionary protection implementation
Rem     schatter   03/07/96 -  define v$session_longops
Rem     nmallava   04/18/96 -  create public synonyms for new views
Rem     atsukerm   04/09/96 -  fix ALL_INDEXES.
Rem     achaudhr   04/08/96 -  reorder decodes to eliminate to_number's
Rem     achaudhr   04/04/96 -  fix yet another decode bug
Rem     rjenkins   04/05/96 -  fix user_indexes pct_free
Rem     jwijaya    03/28/96 -  test the property of column
Rem     atsukerm   03/26/96 -  merge fix.
Rem     achaudhr   03/21/96 -  put decodes in {user|all|dba}_{tables|indexes}
Rem     jwijaya    03/21/96 -  support global TOID
Rem     schatter   03/07/96 -  define v$session_longops
Rem     hasun      03/04/96 -  Merge bug fix#284791 into OBJECT branch
Rem     asurpur    03/05/96 -  Password Management implementation
Rem     atsukerm   02/29/96 -  space support for partitions.
Rem     akruglik   02/28/96 -  add logging attribute to
Rem                            {USER | ALL | DBA}_{TABLES | INDICES}
Rem     bhimatsi   02/27/96 -  minimum feature - add new column to ts$
Rem     fsmith     02/22/96 -  Add synonym for v$subcache
Rem     ltan       02/14/96 -  PDML: add logging attribute to dba_tablespaces
Rem     tcheng     02/09/96 -  rename adtcol$ to coltype$
Rem     mramache   01/24/96 -  CM - change usertables definition
Rem     ixhu       01/16/96 -  fix user_indexes syntax error
Rem     lwillis    01/16/96 -  7.3 merge
Rem     atsukerm   01/12/96 -  fix DBA_DATA_FILES.
Rem     jklein     01/11/96 -  free space stats for pdml
Rem     atsukerm   01/03/96 -  tablespace-relative DBAs.
Rem     rjenkins   12/15/95 -  fixing deferred constraints
Rem     gdoherty   12/15/95 -  fix deferred constraints merge with objects
Rem     rdbmsint   12/13/95 -  add v_system_parameter
Rem     achaudhr   12/08/95 -  Change value of STATUS in USER_INDEXES
Rem     msimon     11/21/95 -  Fix suntax error on USER_CLUSTER_HASH_EXPRESSIONS
Rem     lwillis    11/16/95 -  Change *_histograms.bucket_number
Rem     aho        11/13/95 -  iot
Rem     rtaranto   11/09/95 -  Add synonym for v$sql_shared_memory
Rem     jwijaya    11/07/95 -  type privilege fix
Rem     rtaranto   11/03/95 -  Add new bind fixed views
Rem     schandra   11/02/95 -  Migration - change dba_tablespaces view
Rem     achaudhr   10/30/95 -  PTI: Invoke catpart.sql
Rem     rjenkins   10/27/95 -  deferred constraints
Rem     achaudhr   10/27/95 -  PTI: add outer-joins to INDEXES family of views
Rem     achaudhr   10/25/95 -  PTI: Add lpads around degree, instances, cache
Rem     hjakobss   10/19/95 -  bitmap indexes in index views
Rem     schandra   10/17/95 -  Migration - Change dba_tablepsaces view
Rem     achaudhr   10/06/95 -  PTI: cache flag value changed
Rem     skaluska   10/04/95 -  Rename unique$ to property
Rem     achaudhr   10/03/95 -  PTI: change degree, instances, cache
Rem     jbellemo   09/25/95 -  #284791: fix security in ALL_OBJECTS
Rem     jwijaya    09/21/95 -  support ADTs/objects
Rem     wmaimone   08/11/95 -  merge changes from branch 1.182.720.6
Rem     achaudhr   07/20/95 -  PTI: fix flags
Rem     achaudhr   07/20/95 -  PTI: Fix old views and add new ones
Rem     wmaimone   07/17/95 -  add all_arguments views
Rem     arhee      07/06/95 -  add v$active_instances
Rem     amozes     06/23/95 -  add v$pq_tqstat for table queue statistics
Rem     ssamu      06/15/95 -  change views on tab$
Rem     schatter   03/21/95 -  add v$latch_misses for latch tracking
Rem     gngai      03/07/95 -  Added v$locked_object
Rem     jcchou     03/06/95 -  #258792, fixed view TABLE_PRIVILEGES
Rem     atsukerm   02/20/95 -  Sort Segment - Temporary Tablespace Support
Rem     glumpkin   02/10/95 -  fix histogram views
Rem     aho        02/02/95 -  merge changes from branch 1.182.720.5 (95.02.02)
Rem     ksriniva   01/27/95 -  merge of hier. latch stuff from 7.3
Rem     jbellemo   01/25/95 -  merge changes from branch 1.182.720.3
Rem     jbellemo   01/13/95 -  #259639: fix security for pack bodies in all_obj
Rem     glumpkin   01/10/95 -  add sample_size to tab_columns
Rem     jbellemo   01/06/95 -  #211270: speed up table_privileges view
Rem     bhimatsi   01/05/95 -  Add view(s) : DBA_FREE_SPACE_COALESCED
Rem     glumpkin   12/29/94 -  add histogram views
Rem     bhirano    12/29/94 -  merge changes from branch 1.182.720.2
Rem     bhirano    12/28/94 -  bug 257956: add synonym for shared_pool_reserved
Rem     ksriniva   12/22/94 -  add more latch views
Rem     ksriniva   11/16/94 -  merge changes from branch 1.182.720.1
Rem     gpongrac   10/21/94 -  media recovery views
Rem     glumpkin   10/01/94 -  Histograms
Rem     achaudhr   09/19/94 -  UJV: Add UPDATABLE_COLUMNS
Rem     ksriniva   09/17/94 -  bug 236209: add synonyms for v$execution and
Rem                            v$session_connect_info
Rem     aho        07/08/94 -  freelist groups for indexes
Rem     ajasuja    07/07/94 -  add v
Rem     agupta     07/05/94 -  224310 - add comments for freelists
Rem     nmichael   06/21/94 -  Hash expressions for clusters & ALL_CLUSTERS vie
Rem     jloaiza    06/20/94 -  fix all_tables
Rem     jloaiza    06/16/94 -  add disable dml locks
Rem     ksriniva   06/15/94 -  bug 219066: add V$EVENT_NAME
Rem     wmaimone   05/06/94 -  #158950,156147 fix DICTIONARY; 186155 dba_ syns
Rem     jloaiza    05/23/94 -  add new fixed views
Rem     wmaimone   04/07/94 -  merge changes from branch 1.163.710.11
Rem     jcohen     04/07/94 -  merge changes from branch 1.163.710.5
Rem     agupta     03/28/94 -  merge changes from branch 1.163.710.6
Rem     thayes     03/22/94 -  merge changes from branch 1.163.710.12
Rem     ltung      03/02/94 -  merge changes from branch 1.163.710.10
Rem     aho        01/03/95 -  add synonym for v$instance, v$mystat,
Rem                            v$sqltext, and v$shared_pool_reserved
Rem     jbellemo   09/02/94 -  add synonym for v$pwfile_users
Rem     thayes     03/02/94 -  Add compatibility views
Rem     wmaimone   03/02/94 -  add view and public synonym for v$sess_io
Rem     ltung      02/20/94 -  yet another parallel/cache semantic change
Rem     ltung      01/23/94 -  add v$pq_sysstat
Rem     ltung      01/19/94 -  add v$pq_sesstat and v$pq_slave
Rem     ltung      01/15/94 -  new parallel/cache/partitions semantics
Rem     hrizvi     01/03/94 -  bug191476 - omit invalid RSs from
Rem                            dba_rollback_segs
Rem     agupta     01/05/94 -  192948 - change units for *_extents in *_segment
Rem     jcohen     01/04/94 - #(192450) add v$option table
Rem     jcohen     12/20/93 - #(191673) fix number fmt for user_tables,cluster
Rem     jbellemo   12/17/93 -  merge changes from branch 1.163.710.3
Rem     agupta     11/29/93 -  92383 - make seg$ freelist info visible
Rem     jbellemo   11/09/93 -  #170173: change uid to userenv('schemaid')
Rem     gdoherty   11/01/93 -  add call to catsvrmg for Server Manager
Rem     gdoherty   10/20/93 -  add v$nls_valid_values
Rem     hkodaval   11/05/93 -  merge changes from branch 1.163.710.1
Rem     hkodaval   10/14/93 -  merge changes from branch 1.151.312.7
Rem     wbridge    07/02/93 -  add v$controlfile fixed table
Rem     ltung      06/25/93 -  merge changes from branch 1.151.312.4
Rem     jcohen     06/22/93 - #(165117) new view product_component_version
Rem     vraghuna   06/17/93 -  bug 166480 - move resource_map into sql.bsq
Rem     ltung      05/28/93 -  parallel/cache in table/cluster views
Rem     wmaimone   05/20/93 -  merge changes from branch 1.151.312.3
Rem     wmaimone   05/20/93 -  merge changes from branch 1.151.312.1
Rem     jcohen     05/18/93 - #(163749) passwords visible in SYS.DBA_DB_LINKS
Rem     wmaimone   05/18/93 -  fix width of all_indexes
Rem     ltung      05/14/93 - #(157449) add v$dblink
Rem     hkodaval   04/30/93 -  Bug 162360: free lists/groups should show > 0
Rem                             in views user_segments and dba_segments
Rem     rnakhwa    04/12/93 -  merge changes from branch 1.151.312.2
Rem     wbridge    04/02/93 -  read-only tablespaces
Rem     agupta     01/10/93 -  141957 - remove divide by 0 window
Rem     wmaimone   05/07/93 -  #(161964) use system privs for all_*
Rem     rnakhwa    04/12/93 -  Embedded comments are not allowd within SQL stat
Rem     wmaimone   04/02/93 -  #(158143) grant select on nls_parameters
Rem     wmaimone   04/02/93 -  #(158143) grant select on nls_parameters
Rem     ksriniva   11/30/92 -  add synonyms for v$session_event, v$system_event
Rem     tpystyne   11/27/92 -  add nls_* views
Rem     ghallmar   11/20/92 -  fix DBA_2PC_PENDING.GLOBAL_TRAN_ID
Rem     amendels   11/19/92 -  fix 139681, 140003: modify *_constraints
Rem     ksriniva   11/13/92 -  add public synonym for v$session_wait
Rem     pritto     11/09/92 -  add synonym for V$MTS
Rem     tpystyne   11/06/92 -  use create or replace view
Rem     jklein     09/29/92 -  histogram support
Rem     vraghuna   10/29/92 -  bug 130560 - move map tables in sql.bsq
Rem     jloaiza    10/28/92 -  add v$db_object_cache and v$open_cursor
Rem     glumpkin   10/20/92 -  Adjust for new .sql filenames
Rem     ltan       10/20/92 -  rename DBA_ROLLBACK_SEGS status
Rem     mmoore     10/15/92 - #(134232) show more privs in all_tab_privs
Rem     mmoore     10/15/92 - #(133927) speed up table_privileges view
Rem     dsdaniel   10/13/92 -  bug 112376 112374 125947 alter/create profile
Rem     amendels   10/08/92 -  132726: fix *_constraints to show DELETE CASCADE
Rem     mmoore     10/08/92 - #(132956) remove _next_objects from dba_objects
Rem     jwijaya    10/07/92 -  add v$*cursor_cache
Rem     ltan       10/07/92 -  fix undefined status for dba_rollback_segs
Rem     mmoore     10/02/92 -  fix role_privs views
Rem     ltan       09/11/92 -  decode new status for rollback segment
Rem     jbellemo   09/24/92 -  merge changes from branch 1.124.311.2
Rem     jbellemo   09/18/92 -  #126685: show datatype 106 as MLSLABEL in *_TAB_
Rem     mmoore     09/23/92 -  fix comment on dba_role_privs
Rem     aho        09/23/92 -  change view text to upper case & make shorter
Rem     pritto     09/04/92 -  rename dispatcher view synonyms
Rem     jwijaya    09/09/92 -  add v$fixed_table
Rem     aho        08/31/92 -  merge forward status column in *_indexes from v6
Rem                         -  bug 126268
Rem     mmoore     08/28/92 - #(124859) add default role information to role vi
Rem     mmoore     08/10/92 - #(121120) remove create index from system_priv_ma
Rem     rjenkins   07/24/92 -  removing drop & alter snapshot
Rem     hrizvi     07/16/92 -  add v$license
Rem     mmoore     07/13/92 - #(104081) change alter resource priv name -> add
Rem     agupta     06/26/92 -  115032 - add lists,groups to *_segments
Rem     wbridge    06/25/92 -  fixed tables for file headers
Rem     jwijaya    06/25/92 -  MODIFIED -> LAST_DDL_TIME per marketing
Rem     achaudhr   07/20/95 -  PTI: fix flags
Rem     achaudhr   07/20/95 -  PTI: Fix old views and add new ones
Rem     epeeler    06/23/92 -  accomodate new type 7 in cdef$
Rem     jwijaya    06/15/92 -  v$plsarea is obsolete
Rem     jbellemo   06/12/92 -  add mapping for MLSLABEL to *_TAB_COLUMNS
Rem     jwijaya    06/04/92 -  fix a typo
Rem     mmoore     06/04/92 - #(112281) add execute to table_privs
Rem     agupta     06/01/92 -  111558 - user_tablespaces view wrong
Rem     mmoore     06/01/92 - #(111110) fix dba_role_privs
Rem     rlim       05/29/92 -  #110883 - add missing views in dictionary
Rem     jwijaya    05/26/92 -  fix bug 110884 - don't grant on v$sga
Rem     jwijaya    05/19/92 -  add v$type_size
Rem     rlim       05/15/92 -  fix bug 101589 - correct spelling mistakes
Rem     epeeler    05/06/92 -  fix NULL columns - bug 103146
Rem     mmoore     05/01/92 - #(107592) fix all_views to look at enabled roles
Rem     jwijaya    04/23/92 -  status for _NEXT_OBJECT is N/A
Rem     agupta     04/16/92 -  add columns to dba_segments
Rem     mmoore     04/13/92 -  merge changes from branch 1.101.300.1
Rem     mmoore     03/03/92 -  change grant view names
Rem     rnakhwa    03/10/92 -  + synonyms 4 views-v$thread, v$datafile, v$log
Rem     thayes     03/24/92 -  Define v$rollname in catalog.sql instead of kqfv
Rem     wmaimone   02/24/92 -  add v$mls_parameters
Rem     mmoore     02/19/92 -  remove more v$osroles
Rem     mmoore     02/19/92 -  remove v$enabledroles and v$osroles
Rem     jwijaya    02/06/92 -  add v$librarycache
Rem     mmoore     01/31/92 -  fix the user_free_space view
Rem     rkooi      01/23/92 -  drop global naming views before creating them
Rem     rkooi      01/23/92 -  use @@ command for subscripts
Rem     rkooi      01/18/92 -  add synonym
Rem     rkooi      01/18/92 -  add object_sizes views
Rem     rkooi      01/10/92 -  fix up trigger views
Rem     ajasuja    12/31/91 -  fix dba_audit_trail view
Rem     ajasuja    12/30/91 -  audit EXISTS
Rem     amendels   12/23/91 -  simplify *_clusters as clu$.hashkeys cannot be n
Rem     amendels   12/23/91 -  fix *_clusters views for hashing
Rem     agupta     12/23/91 -  89036 - dba_ts_quotas
Rem     rkooi      12/15/91 -  change 'triggering_statement' to 'trigger_body'
Rem     ajasuja    11/27/91 -  add system privilege auditing
Rem     amendels   11/26/91 -  modify user/dba_clusters for hash cluster
Rem     ghallmar   11/08/91 -  add GLOBAL_NAME view
Rem     rjenkins   11/07/91 -  commenting snapshots
Rem     ltan       12/02/91 -  add inst# to undo$
Rem     mroberts   10/30/91 -  apply error view changes (for views) to IMRG
Rem     rkooi      10/20/91 -  add public_dependency, fix priv checking
Rem                            on all_objects
Rem     smcadams   10/19/91 -  tweak audit_action table
Rem                            add execute obj audit option to audit views
Rem                            add new_owner to dba_audit_trail
Rem     mroberts   10/14/91 -  add v$nls_parameters view
Rem     mroberts   10/11/91 -  put VIEW changes in the mainline
Rem     jcleland   10/11/91 -  add mac privileges to sys_priv_map
Rem     epeeler    10/10/91 -  add enabled status columns to constraint views
Rem     cheigham   10/03/91 -  remove extra ;'s
Rem     mmoore     09/18/91 - #(74112) add dba_roles view to show all roles
Rem     agupta     09/03/91 -  add sequence# to tabauth$
Rem     mmoore     09/03/91 -  change trigger view column names again
Rem     ghallmar   08/12/91 -  global naming
Rem     amendels   08/29/91 -  fix dict_columns: 'ALL$' -> 'ALL%'
Rem     rlim       08/22/91 -  add comments regarding dba synonyms
Rem     mmoore     08/17/91 - #77458  change trigger views
Rem     mmoore     08/01/91 -  merge changes from branch 1.59.100.1
Rem     mmoore     08/01/91 -  move column_privileges back
Rem     rlim       07/31/91 -  added remarks column to syscatalog & catalog
Rem     rlim       07/30/91 -  moved dba synonyms to dba_synonyms.sql
Rem     mmoore     07/22/91 - #65139  fix bug in user_tablespaces
Rem     jwijaya    07/14/91 -  remove unnecessary LINKNAME IS NULL
Rem   mmoore     07/08/91 - change trigger view column names
Rem   amendels   07/02/91 - remove change to *_constraints.constraint_type
Rem   mmoore     06/28/91 - move table_privileges back in
Rem   ltan       06/24/91 - bug 65188,add comment on DBA_ROLLBACK_SEGS.BLOCK_ID
Rem   mmoore     06/24/91 - move table and column_privileges to catalog6
Rem   ghallmar   06/11/91 -         new improved 2PC views
Rem   amendels   06/10/91 - move obsolete sql2 views to catalog6.sql;
Rem                       - remove decodes for type 97;
Rem                       - union -> union all;
Rem                       - improve *_constraints.constraint_type (66063)
Rem   mmoore     06/10/91 - add grantable column to privilege views
Rem   smcadams   06/09/91 - add actions to audit_actions
Rem   mmoore     06/03/91 - change user$ column names
Rem   agupta     06/07/91 - syntax error in exp_objects view
Rem   rkooi      10/22/91 - deleted lots of comments (co truncate bug)
Rem   Grayson    03/21/88 - Creation
 
WHENEVER SQLERROR EXIT;         
 
DOC 
###################################################################### 
###################################################################### 
    The following statement will cause an "ORA-01722: invalid number" 
    error and terminate the SQLPLUS session if the user is not SYS.  
    Disconnect and reconnect with AS SYSDBA. 
###################################################################### 
###################################################################### 
# 
 
SELECT TO_NUMBER('MUST_BE_AS_SYSDBA') FROM DUAL 
WHERE USER != 'SYS'; 

WHENEVER SQLERROR CONTINUE;

rem Load PL/SQL Package STANDARD first, so views can depend upon it
@@standard
@@dbmsstdx


Rem Load registry so catalog component can be defined
@@catcr

BEGIN
   dbms_registry.loading('CATALOG', 'Oracle Database Catalog Views',
        'dbms_registry_sys.validate_catalog');
END;
/

remark
remark  FAMILY "FIXED (VIRTUAL) VIEWS"
remark

create or replace view v_$map_library as select * from v$map_library;
create or replace public synonym v$map_library for v_$map_library;
grant select on v_$map_library to select_catalog_role;

create or replace view v_$map_file as select * from v$map_file;
create or replace public synonym v$map_file for v_$map_file;
grant select on v_$map_file to select_catalog_role;

create or replace view v_$map_file_extent as select * from v$map_file_extent;
create or replace public synonym v$map_file_extent for v_$map_file_extent;
grant select on v_$map_file_extent to select_catalog_role;

create or replace view v_$map_element as select * from v$map_element;
create or replace public synonym v$map_element for v_$map_element;
grant select on v_$map_element to select_catalog_role;

create or replace view v_$map_ext_element as select * from v$map_ext_element;
create or replace public synonym v$map_ext_element for v_$map_ext_element;
grant select on v_$map_ext_element to select_catalog_role;

create or replace view v_$map_comp_list as select * from v$map_comp_list;
create or replace public synonym v$map_comp_list for v_$map_comp_list;
grant select on v_$map_comp_list to select_catalog_role;

create or replace view v_$map_subelement as select * from v$map_subelement;
create or replace public synonym v$map_subelement for v_$map_subelement;
grant select on v_$map_subelement to select_catalog_role;

create or replace view v_$map_file_io_stack as select * from v$map_file_io_stack;
create or replace public synonym v$map_file_io_stack for v_$map_file_io_stack;
grant select on v_$map_file_io_stack to select_catalog_role;

create or replace view v_$sql_redirection as select * from v$sql_redirection;
create or replace public synonym v$sql_redirection for v_$sql_redirection;
grant select on v_$sql_redirection to select_catalog_role;

create or replace view v_$sql_plan as select * from v$sql_plan;
create or replace public synonym v$sql_plan for v_$sql_plan;
grant select on v_$sql_plan to select_catalog_role;

create or replace view v_$sql_plan_statistics as
  select * from v$sql_plan_statistics;
create or replace public synonym v$sql_plan_statistics
  for v_$sql_plan_statistics;
grant select on v_$sql_plan_statistics to select_catalog_role;

create or replace view v_$sql_plan_statistics_all as
  select * from v$sql_plan_statistics_all;
create or replace public synonym v$sql_plan_statistics_all
  for v_$sql_plan_statistics_all;
grant select on v_$sql_plan_statistics_all to select_catalog_role;

create or replace view v_$sql_workarea as select * from v$sql_workarea;
create or replace public synonym v$sql_workarea for v_$sql_workarea;
grant select on v_$sql_workarea to select_catalog_role;

create or replace view v_$sql_workarea_active
  as select * from v$sql_workarea_active;
create or replace public synonym v$sql_workarea_active
   for v_$sql_workarea_active;
grant select on v_$sql_workarea_active to select_catalog_role;

create or replace view v_$sql_workarea_histogram
   as select * from v$sql_workarea_histogram;
create or replace public synonym v$sql_workarea_histogram
   for v_$sql_workarea_histogram;
grant select on v_$sql_workarea_histogram to select_catalog_role;

create or replace view v_$pga_target_advice as select * from v$pga_target_advice;
create or replace public synonym v$pga_target_advice for v_$pga_target_advice;
grant select on v_$pga_target_advice to select_catalog_role;

create or replace view v_$pga_target_advice_histogram
  as select * from v$pga_target_advice_histogram;
create or replace public synonym v$pga_target_advice_histogram
  for v_$pga_target_advice_histogram;
grant select on v_$pga_target_advice_histogram to select_catalog_role;

create or replace view v_$pgastat as select * from v$pgastat;
create or replace public synonym v$pgastat for v_$pgastat;
grant select on v_$pgastat to select_catalog_role;

create or replace view v_$sys_optimizer_env
  as select * from v$sys_optimizer_env;
create or replace public synonym v$sys_optimizer_env for v_$sys_optimizer_env;
grant select on v_$sys_optimizer_env to select_catalog_role;

create or replace view v_$ses_optimizer_env
  as select * from v$ses_optimizer_env;
create or replace public synonym v$ses_optimizer_env for v_$ses_optimizer_env;
grant select on v_$ses_optimizer_env to select_catalog_role;

create or replace view v_$sql_optimizer_env
  as select * from v$sql_optimizer_env;
create or replace public synonym v$sql_optimizer_env for v_$sql_optimizer_env;
grant select on v_$sql_optimizer_env to select_catalog_role;

create or replace view v_$dlm_misc as select * from v$dlm_misc;
create or replace public synonym v$dlm_misc for v_$dlm_misc;
grant select on v_$dlm_misc to select_catalog_role;

create or replace view v_$dlm_latch as select * from v$dlm_latch;
create or replace public synonym v$dlm_latch for v_$dlm_latch;
grant select on v_$dlm_latch to select_catalog_role;

create or replace view v_$dlm_convert_local as select * from v$dlm_convert_local;
create or replace public synonym v$dlm_convert_local for v_$dlm_convert_local;
grant select on v_$dlm_convert_local to select_catalog_role;

create or replace view v_$dlm_convert_remote as select * from v$dlm_convert_remote;
create or replace public synonym v$dlm_convert_remote
   for v_$dlm_convert_remote;
grant select on v_$dlm_convert_remote to select_catalog_role;

create or replace view v_$dlm_all_locks as select * from v$dlm_all_locks;
create or replace public synonym v$dlm_all_locks for v_$dlm_all_locks;
grant select on v_$dlm_all_locks to select_catalog_role;

create or replace view v_$dlm_locks as select * from v$dlm_locks;
create or replace public synonym v$dlm_locks for v_$dlm_locks;
grant select on v_$dlm_locks to select_catalog_role;

create or replace view v_$dlm_ress as select * from v$dlm_ress;
create or replace public synonym v$dlm_ress for v_$dlm_ress;
grant select on v_$dlm_ress to select_catalog_role;

create or replace view v_$hvmaster_info as select * from v$hvmaster_info;
create or replace public synonym v$hvmaster_info for v_$hvmaster_info;
grant select on v_$hvmaster_info to select_catalog_role;

create or replace view v_$gcshvmaster_info as select * from v$gcshvmaster_info;
create or replace public synonym v$gcshvmaster_info for v_$gcshvmaster_info;
grant select on v_$gcshvmaster_info to select_catalog_role;

create or replace view v_$gcspfmaster_info as select * from v$gcspfmaster_info;
create or replace public synonym v$gcspfmaster_info for v_$gcspfmaster_info;
grant select on v_$gcspfmaster_info to select_catalog_role;

create or replace view gv_$dlm_traffic_controller as
select * from gv$dlm_traffic_controller;
create or replace public synonym gv$dlm_traffic_controller
   for gv_$dlm_traffic_controller;
grant select on gv_$dlm_traffic_controller to select_catalog_role;

create or replace view v_$dlm_traffic_controller as
select * from v$dlm_traffic_controller;
create or replace public synonym v$dlm_traffic_controller
   for v_$dlm_traffic_controller;
grant select on v_$dlm_traffic_controller to select_catalog_role;

create or replace view v_$ges_enqueue as
select * from v$ges_enqueue;
create or replace public synonym v$ges_enqueue for v_$ges_enqueue;
grant select on v_$ges_enqueue to select_catalog_role;

create or replace view v_$ges_blocking_enqueue as
select * from v$ges_blocking_enqueue;
create or replace public synonym v$ges_blocking_enqueue
   for v_$ges_blocking_enqueue;
grant select on v_$ges_blocking_enqueue to select_catalog_role;

create or replace view v_$gc_element as
select * from v$gc_element;
create or replace public synonym v$gc_element for v_$gc_element;
grant select on v_$gc_element to select_catalog_role;

create or replace view v_$cr_block_server as
select * from v$cr_block_server;
create or replace public synonym v$cr_block_server for v_$cr_block_server;
grant select on v_$cr_block_server to select_catalog_role;

create or replace view v_$current_block_server as
select * from v$current_block_server;
create or replace public synonym v$current_block_server for v_$current_block_server;
grant select on v_$current_block_server to select_catalog_role;

create or replace view v_$gc_elements_w_collisions as
select * from v$gc_elements_with_collisions;
create or replace public synonym v$gc_elements_with_collisions
   for v_$gc_elements_w_collisions;
grant select on v_$gc_elements_w_collisions to select_catalog_role;

create or replace view v_$file_cache_transfer as
select * from v$file_cache_transfer;
create or replace public synonym v$file_cache_transfer
   for v_$file_cache_transfer;
grant select on v_$file_cache_transfer to select_catalog_role;

create or replace view v_$temp_cache_transfer as
select * from v$temp_cache_transfer;
create or replace public synonym v$temp_cache_transfer
   for v_$temp_cache_transfer;
grant select on v_$temp_cache_transfer to select_catalog_role;

create or replace view v_$class_cache_transfer as
select * from v$class_cache_transfer;
create or replace public synonym v$class_cache_transfer
   for v_$class_cache_transfer;
grant select on v_$class_cache_transfer to select_catalog_role;

create or replace view v_$bh as select * from v$bh;
create or replace public synonym v$bh for v_$bh;
grant select on v_$bh to public;

create or replace view v_$lock_element as select * from v$lock_element;
create or replace public synonym v$lock_element for v_$lock_element;
grant select on v_$lock_element to select_catalog_role;

create or replace view v_$locks_with_collisions as
select * from v$locks_with_collisions;
create or replace public synonym v$locks_with_collisions
   for v_$locks_with_collisions;
grant select on v_$locks_with_collisions to select_catalog_role;

create or replace view v_$file_ping as select * from v$file_ping;
create or replace public synonym v$file_ping for v_$file_ping;
grant select on v_$file_ping to select_catalog_role;

create or replace view v_$temp_ping as select * from v$temp_ping;
create or replace public synonym v$temp_ping for v_$temp_ping;
grant select on v_$temp_ping to select_catalog_role;

create or replace view v_$class_ping as select * from v$class_ping;
create or replace public synonym v$class_ping for v_$class_ping;
grant select on v_$class_ping to select_catalog_role;

create or replace view v_$instance_cache_transfer as
select * from v$instance_cache_transfer;
create or replace public synonym v$instance_cache_transfer
   for v_$instance_cache_transfer;
grant select on v_$instance_cache_transfer to select_catalog_role;

create or replace view v_$buffer_pool as select * from v$buffer_pool;
create or replace public synonym v$buffer_pool for v_$buffer_pool;
grant select on v_$buffer_pool to select_catalog_role;

create or replace view v_$buffer_pool_statistics as
select * from v$buffer_pool_statistics;
create or replace public synonym v$buffer_pool_statistics
   for v_$buffer_pool_statistics;
grant select on v_$buffer_pool_statistics to select_catalog_role;

create or replace view v_$instance_recovery as
select * from v$instance_recovery;
create or replace public synonym v$instance_recovery for v_$instance_recovery;
grant select on v_$instance_recovery to select_catalog_role;

create or replace view v_$controlfile as select * from v$controlfile;
create or replace public synonym v$controlfile for v_$controlfile;
grant select on v_$controlfile to select_catalog_role;

create or replace view v_$log as select * from v$log;
create or replace public synonym v$log for v_$log;
grant select on v_$log to SELECT_CATALOG_ROLE;

create or replace view v_$standby_log as select * from v$standby_log;
create or replace public synonym v$standby_log for v_$standby_log;
grant select on v_$standby_log to SELECT_CATALOG_ROLE;

create or replace view v_$dataguard_status as select * from v$dataguard_status;
create or replace public synonym v$dataguard_status for v_$dataguard_status;
grant select on v_$dataguard_status to SELECT_CATALOG_ROLE;

create or replace view v_$thread as select * from v$thread;
create or replace public synonym v$thread for v_$thread;
grant select on v_$thread to select_catalog_role;

create or replace view v_$process as select * from v$process;
create or replace public synonym v$process for v_$process;
grant select on v_$process to select_catalog_role;

create or replace view v_$bgprocess as select * from v$bgprocess;
create or replace public synonym v$bgprocess for v_$bgprocess;
grant select on v_$bgprocess to select_catalog_role;

create or replace view v_$session as select * from v$session;
create or replace public synonym v$session for v_$session;
grant select on v_$session to select_catalog_role;

create or replace view v_$license as select * from v$license;
create or replace public synonym v$license for v_$license;
grant select on v_$license to select_catalog_role;

create or replace view v_$transaction as select * from v$transaction;
create or replace public synonym v$transaction for v_$transaction;
grant select on v_$transaction to select_catalog_role;

create or replace view v_$bsp as select * from v$bsp;
create or replace public synonym v$bsp for v_$bsp;
grant select on v_$bsp to select_catalog_role;

create or replace view v_$fast_start_servers as
select * from v$fast_start_servers;
create or replace public synonym v$fast_start_servers
   for v_$fast_start_servers;
grant select on v_$fast_start_servers to select_catalog_role;

create or replace view v_$fast_start_transactions
as select * from v$fast_start_transactions;
create or replace public synonym v$fast_start_transactions
   for v_$fast_start_transactions;
grant select on v_$fast_start_transactions to select_catalog_role;

create or replace view v_$locked_object as select * from v$locked_object;
create or replace public synonym v$locked_object for v_$locked_object;
grant select on v_$locked_object to select_catalog_role;

create or replace view v_$latch as select * from v$latch;
create or replace public synonym v$latch for v_$latch;
grant select on v_$latch to select_catalog_role;

create or replace view v_$latch_children as select * from v$latch_children;
create or replace public synonym v$latch_children for v_$latch_children;
grant select on v_$latch_children to select_catalog_role;

create or replace view v_$latch_parent as select * from v$latch_parent;
create or replace public synonym v$latch_parent for v_$latch_parent;
grant select on v_$latch_parent to select_catalog_role;

create or replace view v_$latchname as select * from v$latchname;
create or replace public synonym v$latchname for v_$latchname;
grant select on v_$latchname to select_catalog_role;

create or replace view v_$latchholder as select * from v$latchholder;
create or replace public synonym v$latchholder for v_$latchholder;
grant select on v_$latchholder to select_catalog_role;

create or replace view v_$latch_misses as select * from v$latch_misses;
create or replace public synonym v$latch_misses for v_$latch_misses;
grant select on v_$latch_misses to select_catalog_role;

create or replace view v_$session_longops as select * from v$session_longops;
create or replace public synonym v$session_longops for v_$session_longops;
grant select on v_$session_longops to public;

create or replace view v_$resource as select * from v$resource;
create or replace public synonym v$resource for v_$resource;
grant select on v_$resource to select_catalog_role;

create or replace view v_$_lock as select * from v$_lock;
create or replace public synonym v$_lock for v_$_lock;
grant select on v_$_lock to select_catalog_role;

create or replace view v_$lock as select * from v$lock;
create or replace public synonym v$lock for v_$lock;
grant select on v_$lock to select_catalog_role;

create or replace view v_$sesstat as select * from v$sesstat;
create or replace public synonym v$sesstat for v_$sesstat;
grant select on v_$sesstat to select_catalog_role;

create or replace view v_$mystat as select * from v$mystat;
create or replace public synonym v$mystat for v_$mystat;
grant select on v_$mystat to select_catalog_role;

create or replace view v_$subcache as select * from v$subcache;
create or replace public synonym v$subcache for v_$subcache;
grant select on v_$subcache to select_catalog_role;

create or replace view v_$sysstat as select * from v$sysstat;
create or replace public synonym v$sysstat for v_$sysstat;
grant select on v_$sysstat to select_catalog_role;

create or replace view v_$statname as select * from v$statname;
create or replace public synonym v$statname for v_$statname;
grant select on v_$statname to select_catalog_role;

create or replace view v_$osstat as select * from v$osstat;
create or replace public synonym v$osstat for v_$osstat;
grant select on v_$osstat to select_catalog_role;

create or replace view v_$access as select * from v$access;
create or replace public synonym v$access for v_$access;
grant select on v_$access to select_catalog_role;

create or replace view v_$object_dependency as
  select * from v$object_dependency;
create or replace public synonym v$object_dependency for v_$object_dependency;
grant select on v_$object_dependency to select_catalog_role;

create or replace view v_$dbfile as select * from v$dbfile;
create or replace public synonym v$dbfile for v_$dbfile;
grant select on v_$dbfile to select_catalog_role;

create or replace view v_$filestat as select * from v$filestat;
create or replace public synonym v$filestat for v_$filestat;
grant select on v_$filestat to select_catalog_role;

create or replace view v_$tempstat as select * from v$tempstat;
create or replace public synonym v$tempstat for v_$tempstat;
grant select on v_$tempstat to select_catalog_role;

create or replace view v_$logfile as select * from v$logfile;
create or replace public synonym v$logfile for v_$logfile;
grant select on v_$logfile to select_catalog_role;

create or replace view v_$flashback_database_logfile as
  select * from v$flashback_database_logfile;
create or replace public synonym v$flashback_database_logfile
  for v_$flashback_database_logfile;
grant select on v_$flashback_database_logfile to select_catalog_role;

create or replace view v_$flashback_database_log as
  select * from v$flashback_database_log;
create or replace public synonym v$flashback_database_log
  for v_$flashback_database_log;
grant select on v_$flashback_database_log to select_catalog_role;

create or replace view v_$flashback_database_stat as
  select * from v$flashback_database_stat;
create or replace public synonym v$flashback_database_stat
  for v_$flashback_database_stat;
grant select on v_$flashback_database_stat to select_catalog_role;

create or replace view v_$restore_point as
  select * from v$restore_point;
create or replace public synonym v$restore_point
  for v_$restore_point;
grant select on v_$restore_point to public;

create or replace view v_$rollname as select x$kturd.kturdusn usn,undo$.name
   from x$kturd, undo$
   where x$kturd.kturdusn=undo$.us# and x$kturd.kturdsiz!=0;
create or replace public synonym v$rollname for v_$rollname;
grant select on v_$rollname to select_catalog_role;

create or replace view v_$rollstat as select * from v$rollstat;
create or replace public synonym v$rollstat for v_$rollstat;
grant select on v_$rollstat to select_catalog_role;

create or replace view v_$undostat as select * from v$undostat;
create or replace public synonym v$undostat for v_$undostat;
grant select on v_$undostat to select_catalog_role;

create or replace view v_$sga as select * from v$sga;
create or replace public synonym v$sga for v_$sga;
grant select on v_$sga to select_catalog_role;

create or replace view v_$cluster_interconnects 
       as select * from v$cluster_interconnects;
create or replace public synonym v$cluster_interconnects 
       for v_$cluster_interconnects;
grant select on v_$cluster_interconnects to select_catalog_role;

create or replace view v_$configured_interconnects 
       as select * from v$configured_interconnects;
create or replace public synonym v$configured_interconnects 
       for v_$configured_interconnects;
grant select on v_$configured_interconnects to select_catalog_role;

create or replace view v_$parameter as select * from v$parameter;
create or replace public synonym v$parameter for v_$parameter;
grant select on v_$parameter to select_catalog_role;

create or replace view v_$parameter2 as select * from v$parameter2;
create or replace public synonym v$parameter2 for v_$parameter2;
grant select on v_$parameter2 to select_catalog_role;

create or replace view v_$obsolete_parameter as
  select * from v$obsolete_parameter;
create or replace public synonym v$obsolete_parameter
   for v_$obsolete_parameter;
grant select on v_$obsolete_parameter to select_catalog_role;

create or replace view v_$system_parameter as select * from v$system_parameter;
create or replace public synonym v$system_parameter for v_$system_parameter;
grant select on v_$system_parameter to select_catalog_role;

create or replace view v_$system_parameter2 as select * from v$system_parameter2;
create or replace public synonym v$system_parameter2 for v_$system_parameter2;
grant select on v_$system_parameter2 to select_catalog_role;

create or replace view v_$spparameter as select * from v$spparameter;
create or replace public synonym v$spparameter for v_$spparameter;
grant select on v_$spparameter to select_catalog_role;

create or replace view v_$parameter_valid_values 
       as select * from v$parameter_valid_values;
create or replace public synonym v$parameter_valid_values 
       for v_$parameter_valid_values;
grant select on v_$parameter_valid_values to select_catalog_role;

create or replace view v_$rowcache as select * from v$rowcache;
create or replace public synonym v$rowcache for v_$rowcache;
grant select on v_$rowcache to select_catalog_role;

create or replace view v_$rowcache_parent as select * from v$rowcache_parent;
create or replace public synonym v$rowcache_parent for v_$rowcache_parent;
grant select on v_$rowcache_parent to select_catalog_role;

create or replace view v_$rowcache_subordinate as
  select * from v$rowcache_subordinate;
create or replace public synonym v$rowcache_subordinate
   for v_$rowcache_subordinate;
grant select on v_$rowcache_subordinate to select_catalog_role;

create or replace view v_$enabledprivs as select * from v$enabledprivs;
create or replace public synonym v$enabledprivs for v_$enabledprivs;
grant select on v_$enabledprivs to select_catalog_role;

create or replace view v_$nls_parameters as select * from v$nls_parameters;
create or replace public synonym v$nls_parameters for v_$nls_parameters;
grant select on v_$nls_parameters to public;

create or replace view v_$nls_valid_values as
select * from v$nls_valid_values;
create or replace public synonym v$nls_valid_values for v_$nls_valid_values;
grant select on v_$nls_valid_values to public;

create or replace view v_$librarycache as select * from v$librarycache;
create or replace public synonym v$librarycache for v_$librarycache;
grant select on v_$librarycache to select_catalog_role;

create or replace view v_$type_size as select * from v$type_size;
create or replace public synonym v$type_size for v_$type_size;
grant select on v_$type_size to select_catalog_role;

create or replace view v_$archive as select * from v$archive;
create or replace public synonym v$archive for v_$archive;
grant select on v_$archive to select_catalog_role;

create or replace view v_$circuit as select * from v$circuit;
create or replace public synonym v$circuit for v_$circuit;
grant select on v_$circuit to select_catalog_role;

create or replace view v_$database as select * from v$database;
create or replace public synonym v$database for v_$database;
grant select on v_$database to select_catalog_role;

create or replace view v_$instance as select * from v$instance;
create or replace public synonym v$instance for v_$instance;
grant select on v_$instance to select_catalog_role;

create or replace view v_$dispatcher as select * from v$dispatcher;
create or replace public synonym v$dispatcher for v_$dispatcher;
grant select on v_$dispatcher to select_catalog_role;

create or replace view v_$dispatcher_config
  as select * from v$dispatcher_config;
create or replace public synonym v$dispatcher_config for v_$dispatcher_config;
grant select on v_$dispatcher_config to select_catalog_role;

create or replace view v_$dispatcher_rate as select * from v$dispatcher_rate;
create or replace public synonym v$dispatcher_rate for v_$dispatcher_rate;
grant select on v_$dispatcher_rate to select_catalog_role;

create or replace view v_$loghist as select * from v$loghist;
create or replace public synonym v$loghist for v_$loghist;
grant select on v_$loghist to select_catalog_role;

REM create or replace view v_$plsarea as select * from v$plsarea;
REM create or replace public synonym v$plsarea for v_$plsarea;

create or replace view v_$sqlarea as select * from v$sqlarea;
create or replace public synonym v$sqlarea for v_$sqlarea;
grant select on v_$sqlarea to select_catalog_role;

create or replace view v_$sqlarea_plan_hash 
        as select * from v$sqlarea_plan_hash;
create or replace public synonym v$sqlarea_plan_hash for v_$sqlarea_plan_hash;
grant select on v_$sqlarea_plan_hash to select_catalog_role;

create or replace view v_$sqltext as select * from v$sqltext;
create or replace public synonym v$sqltext for v_$sqltext;
grant select on v_$sqltext to select_catalog_role;

create or replace view v_$sqltext_with_newlines as
      select * from v$sqltext_with_newlines;
create or replace public synonym v$sqltext_with_newlines
   for v_$sqltext_with_newlines;
grant select on v_$sqltext_with_newlines to select_catalog_role;

create or replace view v_$sql as select * from v$sql;
create or replace public synonym v$sql for v_$sql;
grant select on v_$sql to select_catalog_role;

create or replace view v_$sqlstats as select * from v$sql;
create or replace public synonym v$sqlstats for v_$sql;
grant select on v_$sqlstats to select_catalog_role;

create or replace view v_$sql_shared_cursor as select * from v$sql_shared_cursor;
create or replace public synonym v$sql_shared_cursor for v_$sql_shared_cursor;
grant select on v_$sql_shared_cursor to select_catalog_role;

create or replace view v_$db_pipes as select * from v$db_pipes;
create or replace public synonym v$db_pipes for v_$db_pipes;
grant select on v_$db_pipes to select_catalog_role;

create or replace view v_$db_object_cache as select * from v$db_object_cache;
create or replace public synonym v$db_object_cache for v_$db_object_cache;
grant select on v_$db_object_cache to select_catalog_role;

create or replace view v_$open_cursor as select * from v$open_cursor;
create or replace public synonym v$open_cursor for v_$open_cursor;
grant select on v_$open_cursor to select_catalog_role;

create or replace view v_$option as select * from v$option;
create or replace public synonym v$option for v_$option;
grant select on v_$option to public;

create or replace view v_$version as select * from v$version;
create or replace public synonym v$version for v_$version;
grant select on v_$version to public;

create or replace view v_$pq_sesstat as select * from v$pq_sesstat;
create or replace public synonym v$pq_sesstat for v_$pq_sesstat;
grant select on v_$pq_sesstat to public;

create or replace view v_$pq_sysstat as select * from v$pq_sysstat;
create or replace public synonym v$pq_sysstat for v_$pq_sysstat;
grant select on v_$pq_sysstat to select_catalog_role;

create or replace view v_$pq_slave as select * from v$pq_slave;
create or replace public synonym v$pq_slave for v_$pq_slave;
grant select on v_$pq_slave to select_catalog_role;

create or replace view v_$queue as select * from v$queue;
create or replace public synonym v$queue for v_$queue;
grant select on v_$queue to select_catalog_role;

create or replace view v_$shared_server_monitor as select * from v$shared_server_monitor;
create or replace public synonym v$shared_server_monitor
   for v_$shared_server_monitor;
grant select on v_$shared_server_monitor to select_catalog_role;

create or replace view v_$dblink as select * from v$dblink;
create or replace public synonym v$dblink for v_$dblink;
grant select on v_$dblink to select_catalog_role;

create or replace view v_$pwfile_users as select * from v$pwfile_users;
create or replace public synonym v$pwfile_users for v_$pwfile_users;
grant select on v_$pwfile_users to select_catalog_role;

create or replace view v_$reqdist as select * from v$reqdist;
create or replace public synonym v$reqdist for v_$reqdist;
grant select on v_$reqdist to select_catalog_role;

create or replace view v_$sgastat as select * from v$sgastat;
create or replace public synonym v$sgastat for v_$sgastat;
grant select on v_$sgastat to select_catalog_role;

create or replace view v_$sgainfo as select * from v$sgainfo;
create or replace public synonym v$sgainfo for v_$sgainfo;
grant select on v_$sgainfo to select_catalog_role;

create or replace view v_$waitstat as select * from v$waitstat;
create or replace public synonym v$waitstat for v_$waitstat;
grant select on v_$waitstat to select_catalog_role;

create or replace view v_$shared_server as select * from v$shared_server;
create or replace public synonym v$shared_server for v_$shared_server;
grant select on v_$shared_server to select_catalog_role;

create or replace view v_$timer as select * from v$timer;
create or replace public synonym v$timer for v_$timer;
grant select on v_$timer to select_catalog_role;

create or replace view v_$recover_file as select * from v$recover_file;
create or replace public synonym v$recover_file for v_$recover_file;
grant select on v_$recover_file to select_catalog_role;

create or replace view v_$backup as select * from v$backup;
create or replace public synonym v$backup for v_$backup;
grant select on v_$backup to select_catalog_role;


create or replace view v_$backup_set as select * from v$backup_set;
create or replace public synonym v$backup_set for v_$backup_set;
grant select on v_$backup_set to select_catalog_role;

create or replace view v_$backup_piece as select * from v$backup_piece;
create or replace public synonym v$backup_piece for v_$backup_piece;
grant select on v_$backup_piece to select_catalog_role;

create or replace view v_$backup_datafile as select * from v$backup_datafile;
create or replace public synonym v$backup_datafile for v_$backup_datafile;
grant select on v_$backup_datafile to select_catalog_role;

create or replace view v_$backup_spfile as select * from v$backup_spfile;
create or replace public synonym v$backup_spfile for v_$backup_spfile;
grant select on v_$backup_spfile to select_catalog_role;

create or replace view v_$backup_redolog as select * from v$backup_redolog;
create or replace public synonym v$backup_redolog for v_$backup_redolog;
grant select on v_$backup_redolog to select_catalog_role;

create or replace view v_$backup_corruption as select * from v$backup_corruption;
create or replace public synonym v$backup_corruption for v_$backup_corruption;
grant select on v_$backup_corruption to select_catalog_role;

create or replace view v_$copy_corruption as select * from v$copy_corruption;
create or replace public synonym v$copy_corruption for v_$copy_corruption;
grant select on v_$copy_corruption to select_catalog_role;

create or replace view v_$database_block_corruption as select * from
   v$database_block_corruption;
create or replace public synonym v$database_block_corruption
   for v_$database_block_corruption;
grant select on v_$database_block_corruption to select_catalog_role;

create or replace view v_$mttr_target_advice as select * from
   v$mttr_target_advice;
create or replace public synonym v$mttr_target_advice
   for v_$mttr_target_advice;
grant select on v_$mttr_target_advice to select_catalog_role;

create or replace view v_$statistics_level as select * from
   v$statistics_level;
create or replace public synonym v$statistics_level
   for v_$statistics_level;
grant select on v_$statistics_level to select_catalog_role;

create or replace view v_$deleted_object as select * from v$deleted_object;
create or replace public synonym v$deleted_object for v_$deleted_object;
grant select on v_$deleted_object to select_catalog_role;

create or replace view v_$proxy_datafile as select * from v$proxy_datafile;
create or replace public synonym v$proxy_datafile for v_$proxy_datafile;
grant select on v_$proxy_datafile to select_catalog_role;

create or replace view v_$proxy_archivedlog as select * from v$proxy_archivedlog;
create or replace public synonym v$proxy_archivedlog for v_$proxy_archivedlog;
grant select on v_$proxy_archivedlog to select_catalog_role;

create or replace view v_$controlfile_record_section as select * from v$controlfile_record_section;
create or replace public synonym v$controlfile_record_section
   for v_$controlfile_record_section;
grant select on v_$controlfile_record_section to select_catalog_role;

create or replace view v_$archived_log as select * from v$archived_log;
create or replace public synonym v$archived_log for v_$archived_log;
grant select on v_$archived_log to select_catalog_role;

create or replace view v_$offline_range as select * from v$offline_range;
create or replace public synonym v$offline_range for v_$offline_range;
grant select on v_$offline_range to select_catalog_role;

create or replace view v_$datafile_copy as select * from v$datafile_copy;
create or replace public synonym v$datafile_copy for v_$datafile_copy;
grant select on v_$datafile_copy to select_catalog_role;

create or replace view v_$log_history as select * from v$log_history;
create or replace public synonym v$log_history for v_$log_history;
grant select on v_$log_history to select_catalog_role;

create or replace view v_$recovery_log as select * from v$recovery_log;
create or replace public synonym v$recovery_log for v_$recovery_log;
grant select on v_$recovery_log to select_catalog_role;

create or replace view v_$archive_gap as select * from v$archive_gap;
create or replace public synonym v$archive_gap for v_$archive_gap;
grant select on v_$archive_gap to select_catalog_role;

create or replace view v_$datafile_header as select * from v$datafile_header;
create or replace public synonym v$datafile_header for v_$datafile_header;
grant select on v_$datafile_header to select_catalog_role;

create or replace view v_$datafile as select * from v$datafile;
create or replace public synonym v$datafile for v_$datafile;
grant select on v_$datafile to SELECT_CATALOG_ROLE;

create or replace view v_$tempfile as select * from v$tempfile;
create or replace public synonym v$tempfile for v_$tempfile;
grant select on v_$tempfile to SELECT_CATALOG_ROLE;

create or replace view v_$tablespace as select * from v$tablespace;
create or replace public synonym v$tablespace for v_$tablespace;
grant select on v_$tablespace to select_catalog_role;

create or replace view v_$backup_device as select * from v$backup_device;
create or replace public synonym v$backup_device for v_$backup_device;
grant select on v_$backup_device to select_catalog_role;

create or replace view v_$managed_standby as select * from v$managed_standby;
create or replace public synonym v$managed_standby for v_$managed_standby;
grant select on v_$managed_standby to select_catalog_role;

create or replace view v_$archive_processes as select * from v$archive_processes;
create or replace public synonym v$archive_processes for v_$archive_processes;
grant select on v_$archive_processes to select_catalog_role;

create or replace view v_$archive_dest as select * from v$archive_dest;
create or replace public synonym v$archive_dest for v_$archive_dest;
grant select on v_$archive_dest to select_catalog_role;

create or replace view v_$dataguard_config as select * from v$dataguard_config;
create or replace public synonym v$dataguard_config for v_$dataguard_config;
grant select on v_$dataguard_config to select_catalog_role;

create or replace view v_$dataguard_stats as select * from v$dataguard_stats;
create or replace public synonym v$dataguard_stats for v_$dataguard_stats;
grant select on v_$dataguard_stats to select_catalog_role;

create or replace view v_$fixed_table as select * from v$fixed_table;
create or replace public synonym v$fixed_table for v_$fixed_table;
grant select on v_$fixed_table to select_catalog_role;

create or replace view v_$fixed_view_definition as
   select * from v$fixed_view_definition;
create or replace public synonym v$fixed_view_definition
   for v_$fixed_view_definition;
grant select on v_$fixed_view_definition to select_catalog_role;

create or replace view v_$indexed_fixed_column as
  select * from v$indexed_fixed_column;
create or replace public synonym v$indexed_fixed_column
   for v_$indexed_fixed_column;
grant select on v_$indexed_fixed_column to select_catalog_role;

create or replace view v_$session_cursor_cache as
  select * from v$session_cursor_cache;
create or replace public synonym v$session_cursor_cache
   for v_$session_cursor_cache;
grant select on v_$session_cursor_cache to select_catalog_role;

create or replace view v_$session_wait_class as
  select * from v$session_wait_class;
create or replace public synonym v$session_wait_class for v_$session_wait_class;
grant select on v_$session_wait_class to select_catalog_role;

create or replace view v_$session_wait as
  select * from v$session_wait;
create or replace public synonym v$session_wait for v_$session_wait;
grant select on v_$session_wait to select_catalog_role;

create or replace view v_$session_wait_history as
  select * from v$session_wait_history;
create or replace public synonym v$session_wait_history for
  v_$session_wait_history;
grant select on v_$session_wait_history to select_catalog_role;

create or replace view v_$session_event as
  select * from v$session_event;
create or replace public synonym v$session_event for v_$session_event;
grant select on v_$session_event to select_catalog_role;

create or replace view v_$session_connect_info as
  select * from v$session_connect_info;
create or replace public synonym v$session_connect_info
   for v_$session_connect_info;
grant select on v_$session_connect_info to public;

create or replace view v_$system_wait_class as
  select * from v$system_wait_class;
create or replace public synonym v$system_wait_class for v_$system_wait_class;
grant select on v_$system_wait_class to select_catalog_role;

create or replace view v_$system_event as
  select * from v$system_event;
create or replace public synonym v$system_event for v_$system_event;
grant select on v_$system_event to select_catalog_role;

create or replace view v_$event_name as
  select * from v$event_name;
create or replace public synonym v$event_name for v_$event_name;
grant select on v_$event_name to select_catalog_role;

create or replace view v_$event_histogram as
  select * from v$event_histogram;
create or replace public synonym v$event_histogram for v_$event_histogram;
grant select on v_$event_histogram to select_catalog_role;

create or replace view v_$file_histogram as
  select * from v$file_histogram;
create or replace public synonym v$file_histogram for v_$file_histogram;
grant select on v_$file_histogram to select_catalog_role;

create or replace view v_$temp_histogram as
  select * from v$temp_histogram;
create or replace public synonym v$temp_histogram for v_$temp_histogram;
grant select on v_$temp_histogram to select_catalog_role;

create or replace view v_$execution as
  select * from v$execution;
create or replace public synonym v$execution for v_$execution;
grant select on v_$execution to select_catalog_role;

create or replace view v_$system_cursor_cache as
  select * from v$system_cursor_cache;
create or replace public synonym v$system_cursor_cache
   for v_$system_cursor_cache;
grant select on v_$system_cursor_cache to select_catalog_role;

create or replace view v_$sess_io as
  select * from v$sess_io;
create or replace public synonym v$sess_io for v_$sess_io;
grant select on v_$sess_io to select_catalog_role;

create or replace view v_$recovery_status as
  select * from v$recovery_status;
create or replace public synonym v$recovery_status for v_$recovery_status;
grant select on v_$recovery_status to select_catalog_role;

create or replace view v_$recovery_file_status as
  select * from v$recovery_file_status;
create or replace public synonym v$recovery_file_status
   for v_$recovery_file_status;
grant select on v_$recovery_file_status to select_catalog_role;

create or replace view v_$recovery_progress as
  select * from v$recovery_progress;
create or replace public synonym v$recovery_progress for v_$recovery_progress;
grant select on v_$recovery_progress to select_catalog_role;

create or replace view v_$shared_pool_reserved as
  select * from v$shared_pool_reserved;
create or replace public synonym v$shared_pool_reserved
   for v_$shared_pool_reserved;
grant select on v_$shared_pool_reserved to select_catalog_role;

create or replace view v_$sort_segment as select * from v$sort_segment;
create or replace public synonym v$sort_segment for v_$sort_segment;
grant select on v_$sort_segment to select_catalog_role;

create or replace view v_$sort_usage as select * from v$sort_usage;
create or replace public synonym v$tempseg_usage for v_$sort_usage;
create or replace public synonym v$sort_usage for v_$sort_usage;
grant select on v_$sort_usage to select_catalog_role;

create or replace view v_$resource_limit as select * from v$resource_limit;
create or replace public synonym v$resource_limit for v_$resource_limit;
grant select on v_$resource_limit to select_catalog_role;

create or replace view v_$enqueue_lock as select * from v$enqueue_lock;
create or replace public synonym v$enqueue_lock for v_$enqueue_lock;
grant select on v_$enqueue_lock to select_catalog_role;

create or replace view v_$transaction_enqueue as select * from v$transaction_enqueue;
create or replace public synonym v$transaction_enqueue
   for v_$transaction_enqueue;
grant select on v_$transaction_enqueue to select_catalog_role;

create or replace view v_$pq_tqstat as select * from v$pq_tqstat;
create or replace public synonym v$pq_tqstat for v_$pq_tqstat;
grant select on v_$pq_tqstat to public;

create or replace view v_$active_instances as select * from v$active_instances;
create or replace public synonym v$active_instances for v_$active_instances;
grant select on v_$active_instances to public;

create or replace view v_$sql_cursor as select * from v$sql_cursor;
create or replace public synonym v$sql_cursor for v_$sql_cursor;
grant select on v_$sql_cursor to select_catalog_role;

create or replace view v_$sql_bind_metadata as
  select * from v$sql_bind_metadata;
create or replace public synonym v$sql_bind_metadata for v_$sql_bind_metadata;
grant select on v_$sql_bind_metadata to select_catalog_role;

create or replace view v_$sql_bind_data as select * from v$sql_bind_data;
create or replace public synonym v$sql_bind_data for v_$sql_bind_data;
grant select on v_$sql_bind_data to select_catalog_role;

create or replace view v_$sql_shared_memory
  as select * from v$sql_shared_memory;
create or replace public synonym v$sql_shared_memory for v_$sql_shared_memory;
grant select on v_$sql_shared_memory to select_catalog_role;

create or replace view v_$global_transaction
  as select * from v$global_transaction;
create or replace public synonym v$global_transaction
   for v_$global_transaction;
grant select on v_$global_transaction to select_catalog_role;

create or replace view v_$session_object_cache as
  select * from v$session_object_cache;
create or replace public synonym v$session_object_cache
   for v_$session_object_cache;
grant select on v_$session_object_cache to select_catalog_role;

CREATE OR replace VIEW v_$kccfe AS
  SELECT * FROM x$kccfe;
GRANT SELECT ON v_$kccfe TO select_catalog_role;

CREATE OR replace VIEW v_$kccdi AS
  SELECT * FROM x$kccdi;
GRANT SELECT ON v_$kccdi TO select_catalog_role;

create or replace view v_$lock_activity as
  select * from v$lock_activity;
create or replace public synonym v$lock_activity for v_$lock_activity;
grant select on v_$lock_activity to public;

create or replace view v_$aq1 as
  select * from v$aq1;
create or replace public synonym v$aq1 for v_$aq1;
grant select on v_$aq1 to select_catalog_role;

create or replace view v_$hs_agent as
  select * from v$hs_agent;
create or replace public synonym v$hs_agent for v_$hs_agent;
grant select on v_$hs_agent to select_catalog_role;

create or replace view v_$hs_session as
  select * from v$hs_session;
create or replace public synonym v$hs_session for v_$hs_session;
grant select on v_$hs_session to select_catalog_role;

create or replace view v_$hs_parameter as
  select * from v$hs_parameter;
create or replace public synonym v$hs_parameter for v_$hs_parameter;
grant select on v_$hs_parameter to select_catalog_role;

create or replace view v_$rsrc_consumer_group_cpu_mth as
  select * from v$rsrc_consumer_group_cpu_mth;
create or replace public synonym v$rsrc_consumer_group_cpu_mth
   for v_$rsrc_consumer_group_cpu_mth;
grant select on v_$rsrc_consumer_group_cpu_mth to public;

create or replace view v_$rsrc_plan_cpu_mth as
  select * from v$rsrc_plan_cpu_mth;
create or replace public synonym v$rsrc_plan_cpu_mth for v_$rsrc_plan_cpu_mth;
grant select on v_$rsrc_plan_cpu_mth to public;

create or replace view v_$rsrc_consumer_group as
  select * from v$rsrc_consumer_group;
create or replace public synonym v$rsrc_consumer_group
   for v_$rsrc_consumer_group;
grant select on v_$rsrc_consumer_group to public;

create or replace view v_$rsrc_session_info as
  select * from v$rsrc_session_info;
create or replace public synonym v$rsrc_session_info
   for v_$rsrc_session_info;
grant select on v_$rsrc_session_info to public;

create or replace view v_$rsrc_plan as
  select * from v$rsrc_plan;
create or replace public synonym v$rsrc_plan for v_$rsrc_plan;
grant select on v_$rsrc_plan to public;

create or replace view v_$rsrc_cons_group_history as
  select * from v$rsrc_cons_group_history;
create or replace public synonym v$rsrc_cons_group_history 
  for v_$rsrc_cons_group_history;
grant select on v_$rsrc_cons_group_history to public;

create or replace view v_$rsrc_plan_history as
  select * from v$rsrc_plan_history;
create or replace public synonym v$rsrc_plan_history for v_$rsrc_plan_history;
grant select on v_$rsrc_plan_history to public;

create or replace view v_$blocking_quiesce as
  select * from v$blocking_quiesce;
create or replace public synonym v$blocking_quiesce
   for v_$blocking_quiesce;
grant select on v_$blocking_quiesce to public;

create or replace view v_$px_buffer_advice as
  select * from v$px_buffer_advice;
create or replace public synonym v$px_buffer_advice for v_$px_buffer_advice;
grant select on v_$px_buffer_advice to select_catalog_role;

create or replace view v_$px_session as
  select * from v$px_session;
create or replace public synonym v$px_session for v_$px_session;
grant select on v_$px_session to select_catalog_role;

create or replace view v_$px_sesstat as
  select * from v$px_sesstat;
create or replace public synonym v$px_sesstat for v_$px_sesstat;
grant select on v_$px_sesstat to select_catalog_role;

create or replace view v_$backup_sync_io as
  select * from v$backup_sync_io;
create or replace public synonym v$backup_sync_io for v_$backup_sync_io;
grant select on v_$backup_sync_io to select_catalog_role;

create or replace view v_$backup_async_io as
  select * from v$backup_async_io;
create or replace public synonym v$backup_async_io for v_$backup_async_io;
grant select on v_$backup_async_io to select_catalog_role;

create or replace view v_$temporary_lobs as select * from v$temporary_lobs;
create or replace public synonym v$temporary_lobs for v_$temporary_lobs;
grant select on v_$temporary_lobs to public;

create or replace view v_$px_process as
  select * from v$px_process;
create or replace public synonym v$px_process for v_$px_process;
grant select on v_$px_process to select_catalog_role;

create or replace view v_$px_process_sysstat as
  select * from v$px_process_sysstat;
create or replace public synonym v$px_process_sysstat for v_$px_process_sysstat;
grant select on v_$px_process_sysstat to select_catalog_role;

create or replace view v_$logmnr_contents as
  select * from v$logmnr_contents;
create or replace public synonym v$logmnr_contents for v_$logmnr_contents;
grant select on v_$logmnr_contents to select_catalog_role;

create or replace view v_$logmnr_parameters as
  select * from v$logmnr_parameters;
create or replace public synonym v$logmnr_parameters for v_$logmnr_parameters;
grant select on v_$logmnr_parameters to select_catalog_role;

create or replace view v_$logmnr_dictionary as
  select * from v$logmnr_dictionary;
create or replace public synonym v$logmnr_dictionary for v_$logmnr_dictionary;
grant select on v_$logmnr_dictionary to select_catalog_role;

create or replace view v_$logmnr_logs as
  select * from v$logmnr_logs;
create or replace public synonym v$logmnr_logs for v_$logmnr_logs;
grant select on v_$logmnr_logs to select_catalog_role;

create or replace view v_$logmnr_stats as select * from v$logmnr_stats;
create or replace public synonym v$logmnr_stats for v_$logmnr_stats;
grant select on v_$logmnr_stats to select_catalog_role;

create or replace view v_$logmnr_dictionary_load as
  select * from v$logmnr_dictionary_load;
create or replace public synonym v$logmnr_dictionary_load
  for v_$logmnr_dictionary_load;
grant select on v_$logmnr_dictionary_load to select_catalog_role;

create or replace view v_$rfs_thread as
  select * from v$rfs_thread;
create or replace public synonym v$rfs_thread
  for v_$rfs_thread;
grant select on v_$rfs_thread to select_catalog_role;

create or replace view v_$standby_apply_snapshot as
  select * from v$standby_apply_snapshot;
create or replace public synonym v$standby_apply_snapshot
  for v_$standby_apply_snapshot;
grant select on v_$standby_apply_snapshot to select_catalog_role;

create or replace view v_$global_blocked_locks as
select * from v$global_blocked_locks;
create or replace public synonym v$global_blocked_locks
   for v_$global_blocked_locks;
grant select on v_$global_blocked_locks to select_catalog_role;

create or replace view v_$aw_olap as select * from v$aw_olap;
create or replace public synonym v$aw_olap for v_$aw_olap;
grant select on v_$aw_olap to public;

create or replace view v_$aw_calc as select * from v$aw_calc;
create or replace public synonym v$aw_calc for v_$aw_calc;
grant select on v_$aw_calc to public;

create or replace view v_$aw_session_info as select * from v$aw_session_info;
create or replace public synonym v$aw_session_info for v_$aw_session_info;
grant select on v_$aw_session_info to public;

create or replace view gv_$aw_aggregate_op as select * from gv$aw_aggregate_op;
create or replace public synonym gv$aw_aggregate_op for gv_$aw_aggregate_op;
grant select on gv_$aw_aggregate_op to public;

create or replace view v_$aw_aggregate_op as select * from v$aw_aggregate_op;
create or replace public synonym v$aw_aggregate_op for v_$aw_aggregate_op;
grant select on v_$aw_aggregate_op to public;

create or replace view gv_$aw_allocate_op as select * from gv$aw_allocate_op;
create or replace public synonym gv$aw_allocate_op for gv_$aw_allocate_op;
grant select on gv_$aw_allocate_op to public;

create or replace view v_$aw_allocate_op as select * from v$aw_allocate_op;
create or replace public synonym v$aw_allocate_op for v_$aw_allocate_op;
grant select on v_$aw_allocate_op to public;

create or replace view v_$aw_longops as select * from v$aw_longops;
create or replace public synonym v$aw_longops for v_$aw_longops;
grant select on v_$aw_longops to public;

create or replace view v_$max_active_sess_target_mth as
  select * from v$max_active_sess_target_mth;
create or replace public synonym v$max_active_sess_target_mth
   for v_$max_active_sess_target_mth;
grant select on v_$max_active_sess_target_mth to public;

create or replace view v_$active_sess_pool_mth as
  select * from v$active_sess_pool_mth;
create or replace public synonym v$active_sess_pool_mth
   for v_$active_sess_pool_mth;
grant select on v_$active_sess_pool_mth to public;


create or replace view v_$parallel_degree_limit_mth as
  select * from v$parallel_degree_limit_mth;
create or replace public synonym v$parallel_degree_limit_mth
   for v_$parallel_degree_limit_mth;
grant select on v_$parallel_degree_limit_mth to public;

create or replace view v_$queueing_mth as
  select * from v$queueing_mth;
create or replace public synonym v$queueing_mth for v_$queueing_mth;
grant select on v_$queueing_mth to public;

create or replace view v_$reserved_words as
  select * from v$reserved_words;
create or replace public synonym v$reserved_words for v_$reserved_words;
grant select on v_$reserved_words to select_catalog_role;

create or replace view v_$archive_dest_status as select * from v$archive_dest_status;
create or replace public synonym v$archive_dest_status
   for v_$archive_dest_status;
grant select on v_$archive_dest_status to select_catalog_role;

create or replace view v_$db_cache_advice as select * from v$db_cache_advice;
create or replace public synonym v$db_cache_advice for v_$db_cache_advice;
grant select on v_$db_cache_advice to select_catalog_role;

create or replace view v_$sga_target_advice as select * from v$sga_target_advice;
create or replace public synonym v$sga_target_advice for v_$sga_target_advice;
grant select on v_$sga_target_advice to select_catalog_role;

create or replace view v_$segment_statistics as
  select * from v$segment_statistics;
create or replace public synonym v$segment_statistics
  for v_$segment_statistics;
grant select on v_$segment_statistics to select_catalog_role;


create or replace view v_$segstat_name as
  select * from v$segstat_name;
create or replace public synonym v$segstat_name
  for v_$segstat_name;
grant select on v_$segstat_name to select_catalog_role;

create or replace view v_$segstat as select * from v$segstat;
create or replace public synonym v$segstat for v_$segstat;
grant select on v_$segstat to select_catalog_role;

create or replace view v_$library_cache_memory as
  select * from v$library_cache_memory;
create or replace public synonym v$library_cache_memory
  for v_$library_cache_memory;
grant select on v_$library_cache_memory to select_catalog_role;

create or replace view v_$java_library_cache_memory as
  select * from v$java_library_cache_memory;
create or replace public synonym v$java_library_cache_memory
  for v_$java_library_cache_memory;
grant select on v_$java_library_cache_memory to select_catalog_role;

create or replace view v_$shared_pool_advice as
  select * from v$shared_pool_advice;
create or replace public synonym v$shared_pool_advice
  for v_$shared_pool_advice;
grant select on v_$shared_pool_advice to select_catalog_role;

create or replace view v_$java_pool_advice as
  select * from v$java_pool_advice;
create or replace public synonym v$java_pool_advice
  for v_$java_pool_advice;
grant select on v_$java_pool_advice to select_catalog_role;

create or replace view v_$streams_pool_advice as
  select * from v$streams_pool_advice;
create or replace public synonym v$streams_pool_advice
  for v_$streams_pool_advice;
grant select on v_$streams_pool_advice to select_catalog_role;

create or replace view v_$sga_current_resize_ops as
  select * from v$sga_current_resize_ops;
create or replace public synonym v$sga_current_resize_ops
  for v_$sga_current_resize_ops;
grant select on v_$sga_current_resize_ops to select_catalog_role;

create or replace view v_$sga_resize_ops as
  select * from v$sga_resize_ops;
create or replace public synonym v$sga_resize_ops
  for v_$sga_resize_ops;
grant select on v_$sga_resize_ops to select_catalog_role;

create or replace view v_$sga_dynamic_components as
  select * from v$sga_dynamic_components;
create or replace public synonym v$sga_dynamic_components
  for v_$sga_dynamic_components;
grant select on v_$sga_dynamic_components to select_catalog_role;

create or replace view v_$sga_dynamic_free_memory as
  select * from v$sga_dynamic_free_memory;
create or replace public synonym v$sga_dynamic_free_memory
  for v_$sga_dynamic_free_memory;
grant select on v_$sga_dynamic_free_memory to select_catalog_role;

create or replace view v_$resumable as select * from v$resumable;
create or replace public synonym v$resumable for v_$resumable;
grant select on v_$resumable to select_catalog_role;

create or replace view v_$timezone_names as select * from v$timezone_names;
create or replace public synonym v$timezone_names for v_$timezone_names;
grant select on v_$timezone_names to public;

create or replace view v_$timezone_file as select * from v$timezone_file;
create or replace public synonym v$timezone_file for v_$timezone_file;
grant select on v_$timezone_file to public;

create or replace view v_$enqueue_stat as select * from v$enqueue_stat;
create or replace public synonym v$enqueue_stat for v_$enqueue_stat;
grant select on v_$enqueue_stat to select_catalog_role;

create or replace view v_$enqueue_statistics as select * from v$enqueue_statistics;
create or replace public synonym v$enqueue_statistics for v_$enqueue_statistics;
grant select on v_$enqueue_statistics to select_catalog_role;

create or replace view v_$lock_type as select * from v$lock_type;
create or replace public synonym v$lock_type for v_$lock_type;
grant select on v_$lock_type to select_catalog_role;

create or replace view v_$rman_configuration as select * from v$rman_configuration;
create or replace public synonym v$rman_configuration
   for v_$rman_configuration;
grant select on v_$rman_configuration to select_catalog_role;

create or replace view v_$database_incarnation as select * from
   v$database_incarnation;
create or replace public synonym v$database_incarnation
   for v_$database_incarnation;
grant select on v_$database_incarnation to select_catalog_role;

create or replace view v_$metric as select * from v$metric;
create or replace public synonym v$metric for v_$metric;
grant select on v_$metric to select_catalog_role;

create or replace view v_$metric_history as
          select * from v$metric_history;
create or replace public synonym v$metric_history for v_$metric_history;
grant select on v_$metric_history to select_catalog_role;

create or replace view v_$sysmetric as select * from v$sysmetric;
create or replace public synonym v$sysmetric for v_$sysmetric;
grant select on v_$sysmetric to select_catalog_role;

create or replace view v_$sysmetric_history as
          select * from v$sysmetric_history;
create or replace public synonym v$sysmetric_history for v_$sysmetric_history;
grant select on v_$sysmetric_history to select_catalog_role;

create or replace view v_$metricname as select * from v$metricname;
create or replace public synonym v$metricname for v_$metricname;
grant select on v_$metricname to select_catalog_role;

create or replace view v_$metricgroup as select * from v$metricgroup;
create or replace public synonym v$metricgroup for v_$metricgroup;
grant select on v_$metricgroup to select_catalog_role;

create or replace view v_$service_wait_class as select * from v$service_wait_class;
create or replace public synonym v$service_wait_class for v_$service_wait_class;
grant select on v_$service_wait_class to select_catalog_role;

create or replace view v_$service_event as select * from v$service_event;
create or replace public synonym v$service_event for v_$service_event;
grant select on v_$service_event to select_catalog_role;

create or replace view v_$active_services as select * from v$active_services;
create or replace public synonym v$active_services for v_$active_services;
grant select on v_$active_services to select_catalog_role;

create or replace view v_$services as select * from v$services;
create or replace public synonym v$services for v_$services;
grant select on v_$services to select_catalog_role;

create or replace view v_$sysmetric_summary as
    select * from v$sysmetric_summary;
create or replace public synonym v$sysmetric_summary
    for v_$sysmetric_summary;
grant select on v_$sysmetric_summary to select_catalog_role;

create or replace view v_$sessmetric as select * from v$sessmetric;
create or replace public synonym v$sessmetric for v_$sessmetric;
grant select on v_$sessmetric to select_catalog_role;

create or replace view v_$filemetric as select * from v$filemetric;
create or replace public synonym v$filemetric for v_$filemetric;
grant select on v_$filemetric to select_catalog_role;

create or replace view v_$filemetric_history as
    select * from v$filemetric_history;
create or replace public synonym v$filemetric_history
    for v_$filemetric_history;
grant select on v_$filemetric_history to select_catalog_role;

create or replace view v_$eventmetric as select * from v$eventmetric;
create or replace public synonym v$eventmetric for v_$eventmetric;
grant select on v_$eventmetric to select_catalog_role;

create or replace view v_$waitclassmetric as
    select * from v$waitclassmetric;
create or replace public synonym v$waitclassmetric for v_$waitclassmetric;
grant select on v_$waitclassmetric to select_catalog_role;

create or replace view v_$waitclassmetric_history as
    select * from v$waitclassmetric_history;
create or replace public synonym v$waitclassmetric_history
    for v_$waitclassmetric_history;
grant select on v_$waitclassmetric_history to select_catalog_role;

create or replace view v_$servicemetric as select * from v$servicemetric;
create or replace public synonym v$servicemetric for v_$servicemetric;
grant select on v_$servicemetric to select_catalog_role;

create or replace view v_$servicemetric_history
    as select * from v$servicemetric_history;
create or replace public synonym v$servicemetric_history
    for v_$servicemetric_history;
grant select on v_$servicemetric_history to select_catalog_role;

create or replace view v_$advisor_progress
    as select * from v$advisor_progress;
create or replace public synonym v$advisor_progress
    for v_$advisor_progress;
grant select on v_$advisor_progress to public;

create or replace view v_$xml_audit_trail
    as select * from v$xml_audit_trail;
create or replace public synonym v$xml_audit_trail
    for v_$xml_audit_trail;
grant select on v_$xml_audit_trail to select_catalog_role;

create or replace view v_$sql_join_filter
    as select * from v$sql_join_filter;
create or replace public synonym v$sql_join_filter
    for v_$sql_join_filter;
grant select on v_$sql_join_filter to select_catalog_role;

create or replace view v_$process_memory as select * from v$process_memory;
create or replace public synonym v$process_memory for v_$process_memory;
grant select on v_$process_memory to select_catalog_role;

create or replace view v_$process_memory_detail
    as select * from v$process_memory_detail;
create or replace public synonym v$process_memory_detail
    for v_$process_memory_detail;
grant select on v_$process_memory_detail to select_catalog_role;

create or replace view v_$process_memory_detail_prog
    as select * from v$process_memory_detail_prog;
create or replace public synonym v$process_memory_detail_prog
    for v_$process_memory_detail_prog;
grant select on v_$process_memory_detail_prog to select_catalog_role;

create or replace view v_$sqlstats as select * from v$sqlstats;
create or replace public synonym v$sqlstats for v_$sqlstats;
grant select on v_$sqlstats to select_catalog_role;

create or replace view v_$mutex_sleep as select * from v$mutex_sleep;
create or replace public synonym v$mutex_sleep for v_$mutex_sleep;
grant select on v_$mutex_sleep to select_catalog_role;

create or replace view v_$mutex_sleep_history as
      select * from v$mutex_sleep_history;
create or replace public synonym v$mutex_sleep_history
   for v_$mutex_sleep_history;
grant select on v_$mutex_sleep_history to select_catalog_role;

remark Create synonyms for the global fixed views
remark
remark

create or replace view gv_$mutex_sleep as select * from gv$mutex_sleep;
create or replace public synonym gv$mutex_sleep for gv_$mutex_sleep;
grant select on gv_$mutex_sleep to select_catalog_role;

create or replace view gv_$mutex_sleep_history as
      select * from gv$mutex_sleep_history;
create or replace public synonym gv$mutex_sleep_history
   for gv_$mutex_sleep_history;
grant select on gv_$mutex_sleep_history to select_catalog_role;

create or replace view gv_$sqlstats as select * from gv$sqlstats;
create or replace public synonym gv$sqlstats for gv_$sqlstats;
grant select on gv_$sqlstats to select_catalog_role;

create or replace view gv_$map_library as select * from gv$map_library;
create or replace public synonym gv$map_library for gv_$map_library;
grant select on gv_$map_library to select_catalog_role;

create or replace view gv_$map_file as select * from gv$map_file;
create or replace public synonym gv$map_file for gv_$map_file;
grant select on gv_$map_file to select_catalog_role;

create or replace view gv_$map_file_extent as select * from gv$map_file_extent;
create or replace public synonym gv$map_file_extent for gv_$map_file_extent;
grant select on gv_$map_file_extent to select_catalog_role;

create or replace view gv_$map_element as select * from gv$map_element;
create or replace public synonym gv$map_element for gv_$map_element;
grant select on gv_$map_element to select_catalog_role;

create or replace view gv_$map_ext_element as select * from gv$map_ext_element;
create or replace public synonym gv$map_ext_element for gv_$map_ext_element;
grant select on gv_$map_ext_element to select_catalog_role;

create or replace view gv_$map_comp_list as select * from gv$map_comp_list;
create or replace public synonym gv$map_comp_list for gv_$map_comp_list;
grant select on gv_$map_comp_list to select_catalog_role;

create or replace view gv_$map_subelement as select * from gv$map_subelement;
create or replace public synonym gv$map_subelement for gv_$map_subelement;
grant select on gv_$map_subelement to select_catalog_role;

create or replace view gv_$map_file_io_stack as select * from gv$map_file_io_stack;
create or replace public synonym gv$map_file_io_stack for gv_$map_file_io_stack;
grant select on gv_$map_file_io_stack to select_catalog_role;

create or replace view gv_$bsp as select * from gv$bsp;
create or replace public synonym gv$bsp for gv_$bsp;
grant select on gv_$bsp to select_catalog_role;

create or replace view gv_$obsolete_parameter as
 select * from gv$obsolete_parameter;
create or replace public synonym gv$obsolete_parameter
   for gv_$obsolete_parameter;
grant select on gv_$obsolete_parameter to select_catalog_role;

create or replace view gv_$fast_start_servers
as select * from gv$fast_start_servers;
create or replace public synonym gv$fast_start_servers
   for gv_$fast_start_servers;
grant select on gv_$fast_start_servers to select_catalog_role;

create or replace view gv_$fast_start_transactions
as select * from gv$fast_start_transactions;
create or replace public synonym gv$fast_start_transactions
   for gv_$fast_start_transactions;
grant select on gv_$fast_start_transactions to select_catalog_role;

create or replace view gv_$enqueue_lock as select * from gv$enqueue_lock;
create or replace public synonym gv$enqueue_lock for gv_$enqueue_lock;
grant select on gv_$enqueue_lock to select_catalog_role;

create or replace view gv_$transaction_enqueue as select * from gv$transaction_enqueue;
create or replace public synonym gv$transaction_enqueue
   for gv_$transaction_enqueue;
grant select on gv_$transaction_enqueue to select_catalog_role;

create or replace view gv_$resource_limit as select * from gv$resource_limit;
create or replace public synonym gv$resource_limit for gv_$resource_limit;
grant select on gv_$resource_limit to select_catalog_role;

create or replace view gv_$sql_redirection as select * from gv$sql_redirection;
create or replace public synonym gv$sql_redirection for gv_$sql_redirection;
grant select on gv_$sql_redirection to select_catalog_role;

create or replace view gv_$sql_plan as select * from gv$sql_plan;
create or replace public synonym gv$sql_plan for gv_$sql_plan;
grant select on gv_$sql_plan to select_catalog_role;

create or replace view gv_$sql_plan_statistics as
  select * from gv$sql_plan_statistics;
create or replace public synonym gv$sql_plan_statistics
  for gv_$sql_plan_statistics;
grant select on gv_$sql_plan_statistics to select_catalog_role;

create or replace view gv_$sql_plan_statistics_all as
  select * from gv$sql_plan_statistics_all;
create or replace public synonym gv$sql_plan_statistics_all
  for gv_$sql_plan_statistics_all;
grant select on gv_$sql_plan_statistics_all to select_catalog_role;

create or replace view gv_$sql_workarea as select * from gv$sql_workarea;
create or replace public synonym gv$sql_workarea for gv_$sql_workarea;
grant select on gv_$sql_workarea to select_catalog_role;

create or replace view gv_$sql_workarea_active
  as select * from gv$sql_workarea_active;
create or replace public synonym gv$sql_workarea_active
   for gv_$sql_workarea_active;
grant select on gv_$sql_workarea_active to select_catalog_role;

create or replace view gv_$sql_workarea_histogram
  as select * from gv$sql_workarea_histogram;
create or replace public synonym gv$sql_workarea_histogram
   for gv_$sql_workarea_histogram;
grant select on gv_$sql_workarea_histogram to select_catalog_role;

create or replace view gv_$pga_target_advice
  as select * from gv$pga_target_advice;
create or replace public synonym gv$pga_target_advice
  for gv_$pga_target_advice;
grant select on gv_$pga_target_advice to select_catalog_role;

create or replace view gv_$pgatarget_advice_histogram
  as select * from gv$pga_target_advice_histogram;
create or replace public synonym gv$pga_target_advice_histogram
  for gv_$pgatarget_advice_histogram;
grant select on gv_$pgatarget_advice_histogram to select_catalog_role;

create or replace view gv_$pgastat as select * from gv$pgastat;
create or replace public synonym gv$pgastat for gv_$pgastat;
grant select on gv_$pgastat to select_catalog_role;

create or replace view gv_$sys_optimizer_env
  as select * from gv$sys_optimizer_env;
create or replace public synonym gv$sys_optimizer_env for gv_$sys_optimizer_env;
grant select on gv_$sys_optimizer_env to select_catalog_role;

create or replace view gv_$ses_optimizer_env
  as select * from gv$ses_optimizer_env;
create or replace public synonym gv$ses_optimizer_env for gv_$ses_optimizer_env;
grant select on gv_$ses_optimizer_env to select_catalog_role;

create or replace view gv_$sql_optimizer_env
  as select * from gv$sql_optimizer_env;
create or replace public synonym gv$sql_optimizer_env for gv_$sql_optimizer_env;
grant select on gv_$sql_optimizer_env to select_catalog_role;

create or replace view gv_$dlm_misc as select * from gv$dlm_misc;
create or replace public synonym gv$dlm_misc for gv_$dlm_misc;
grant select on gv_$dlm_misc to select_catalog_role;

create or replace view gv_$dlm_latch as select * from gv$dlm_latch;
create or replace public synonym gv$dlm_latch for gv_$dlm_latch;
grant select on gv_$dlm_latch to select_catalog_role;

create or replace view gv_$dlm_convert_local as select * from gv$dlm_convert_local;
create or replace public synonym gv$dlm_convert_local
   for gv_$dlm_convert_local;
grant select on gv_$dlm_convert_local to select_catalog_role;

create or replace view gv_$dlm_convert_remote as select * from gv$dlm_convert_remote;
create or replace public synonym gv$dlm_convert_remote
   for gv_$dlm_convert_remote;
grant select on gv_$dlm_convert_remote to select_catalog_role;

create or replace view gv_$dlm_all_locks as select * from gv$dlm_all_locks;
create or replace public synonym gv$dlm_all_locks for gv_$dlm_all_locks;
grant select on gv_$dlm_all_locks to select_catalog_role;

create or replace view gv_$dlm_locks as select * from gv$dlm_locks;
create or replace public synonym gv$dlm_locks for gv_$dlm_locks;
grant select on gv_$dlm_locks to select_catalog_role;

create or replace view gv_$dlm_ress as select * from gv$dlm_ress;
create or replace public synonym gv$dlm_ress for gv_$dlm_ress;
grant select on gv_$dlm_ress to select_catalog_role;

create or replace view gv_$hvmaster_info as select * from gv$hvmaster_info;
create or replace public synonym gv$hvmaster_info for gv_$hvmaster_info;
grant select on gv_$hvmaster_info to select_catalog_role;

create or replace view gv_$gcshvmaster_info as select * from gv$gcshvmaster_info
;
create or replace public synonym gv$gcshvmaster_info for gv_$gcshvmaster_info;
grant select on gv_$gcshvmaster_info to select_catalog_role;

create or replace view gv_$gcspfmaster_info as
select * from gv$gcspfmaster_info;
create or replace public synonym gv$gcspfmaster_info for gv_$gcspfmaster_info;
grant select on gv_$gcspfmaster_info to select_catalog_role;

create or replace view gv_$ges_enqueue as
select * from gv$ges_enqueue;
create or replace public synonym gv$ges_enqueue for gv_$ges_enqueue;
grant select on gv_$ges_enqueue to select_catalog_role;

create or replace view gv_$ges_blocking_enqueue as
select * from gv$ges_blocking_enqueue;
create or replace public synonym gv$ges_blocking_enqueue
   for gv_$ges_blocking_enqueue;
grant select on gv_$ges_blocking_enqueue to select_catalog_role;

create or replace view gv_$gc_element as
select * from gv$gc_element;
create or replace public synonym gv$gc_element for gv_$gc_element;
grant select on gv_$gc_element to select_catalog_role;

create or replace view gv_$cr_block_server as
select * from gv$cr_block_server;
create or replace public synonym gv$cr_block_server for gv_$cr_block_server;
grant select on gv_$cr_block_server to select_catalog_role;

create or replace view gv_$current_block_server as
select * from gv$current_block_server;
create or replace public synonym gv$current_block_server for gv_$current_block_server;
grant select on gv_$current_block_server to select_catalog_role;

create or replace view gv_$gc_elements_w_collisions as
select * from gv$gc_elements_with_collisions;
create or replace public synonym gv$gc_elements_with_collisions for
gv_$gc_elements_w_collisions;
grant select on gv_$gc_elements_w_collisions to select_catalog_role;

create or replace view gv_$file_cache_transfer as
select * from gv$file_cache_transfer;
create or replace public synonym gv$file_cache_transfer
   for gv_$file_cache_transfer;
grant select on gv_$file_cache_transfer to select_catalog_role;

create or replace view gv_$temp_cache_transfer as
select * from gv$temp_cache_transfer;
create or replace public synonym gv$temp_cache_transfer for gv_$temp_cache_transfer;
grant select on gv_$temp_cache_transfer to select_catalog_role;

create or replace view gv_$class_cache_transfer as
select * from gv$class_cache_transfer;
create or replace public synonym gv$class_cache_transfer for gv_$class_cache_transfer;
grant select on gv_$class_cache_transfer to select_catalog_role;

create or replace view gv_$bh as select * from gv$bh;
create or replace public synonym gv$bh for gv_$bh;
grant select on gv_$bh to public;

create or replace view gv_$lock_element as select * from gv$lock_element;
create or replace public synonym gv$lock_element for gv_$lock_element;
grant select on gv_$lock_element to select_catalog_role;

create or replace view gv_$locks_with_collisions as select * from gv$locks_with_collisions;
create or replace public synonym gv$locks_with_collisions
   for gv_$locks_with_collisions;
grant select on gv_$locks_with_collisions to select_catalog_role;

create or replace view gv_$file_ping as select * from gv$file_ping;
create or replace public synonym gv$file_ping for gv_$file_ping;
grant select on gv_$file_ping to select_catalog_role;

create or replace view gv_$temp_ping as select * from gv$temp_ping;
create or replace public synonym gv$temp_ping for gv_$temp_ping;
grant select on gv_$temp_ping to select_catalog_role;

create or replace view gv_$class_ping as select * from gv$class_ping;
create or replace public synonym gv$class_ping for gv_$class_ping;
grant select on gv_$class_ping to select_catalog_role;

create or replace view gv_$instance_cache_transfer as
select * from gv$instance_cache_transfer;
create or replace public synonym gv$instance_cache_transfer for gv_$instance_cache_transfer;
grant select on gv_$instance_cache_transfer to select_catalog_role;

create or replace view gv_$buffer_pool as select * from gv$buffer_pool;
create or replace public synonym gv$buffer_pool for gv_$buffer_pool;
grant select on gv_$buffer_pool to select_catalog_role;

create or replace view gv_$buffer_pool_statistics as select * from gv$buffer_pool_statistics;
create or replace public synonym gv$buffer_pool_statistics
   for gv_$buffer_pool_statistics;
grant select on gv_$buffer_pool_statistics to select_catalog_role;

create or replace view gv_$instance_recovery as select * from gv$instance_recovery;
create or replace public synonym gv$instance_recovery
   for gv_$instance_recovery;
grant select on gv_$instance_recovery to select_catalog_role;

create or replace view gv_$controlfile as select * from gv$controlfile;
create or replace public synonym gv$controlfile for gv_$controlfile;
grant select on gv_$controlfile to select_catalog_role;

create or replace view gv_$log as select * from gv$log;
create or replace public synonym gv$log for gv_$log;
grant select on gv_$log to SELECT_CATALOG_ROLE;

create or replace view gv_$standby_log as select * from gv$standby_log;
create or replace public synonym gv$standby_log for gv_$standby_log;
grant select on gv_$standby_log to SELECT_CATALOG_ROLE;

create or replace view gv_$dataguard_status as select * from gv$dataguard_status;
create or replace public synonym gv$dataguard_status for gv_$dataguard_status;
grant select on gv_$dataguard_status to SELECT_CATALOG_ROLE;

create or replace view gv_$thread as select * from gv$thread;
create or replace public synonym gv$thread for gv_$thread;
grant select on gv_$thread to select_catalog_role;

create or replace view gv_$process as select * from gv$process;
create or replace public synonym gv$process for gv_$process;
grant select on gv_$process to select_catalog_role;

create or replace view gv_$bgprocess as select * from gv$bgprocess;
create or replace public synonym gv$bgprocess for gv_$bgprocess;
grant select on gv_$bgprocess to select_catalog_role;

create or replace view gv_$session as select * from gv$session;
create or replace public synonym gv$session for gv_$session;
grant select on gv_$session to select_catalog_role;

create or replace view gv_$license as select * from gv$license;
create or replace public synonym gv$license for gv_$license;
grant select on gv_$license to select_catalog_role;

create or replace view gv_$transaction as select * from gv$transaction;
create or replace public synonym gv$transaction for gv_$transaction;
grant select on gv_$transaction to select_catalog_role;

create or replace view gv_$locked_object as select * from gv$locked_object;
create or replace public synonym gv$locked_object for gv_$locked_object;
grant select on gv_$locked_object to select_catalog_role;

create or replace view gv_$latch as select * from gv$latch;
create or replace public synonym gv$latch for gv_$latch;
grant select on gv_$latch to select_catalog_role;

create or replace view gv_$latch_children as select * from gv$latch_children;
create or replace public synonym gv$latch_children for gv_$latch_children;
grant select on gv_$latch_children to select_catalog_role;

create or replace view gv_$latch_parent as select * from gv$latch_parent;
create or replace public synonym gv$latch_parent for gv_$latch_parent;
grant select on gv_$latch_parent to select_catalog_role;

create or replace view gv_$latchname as select * from gv$latchname;
create or replace public synonym gv$latchname for gv_$latchname;
grant select on gv_$latchname to select_catalog_role;

create or replace view gv_$latchholder as select * from gv$latchholder;
create or replace public synonym gv$latchholder for gv_$latchholder;
grant select on gv_$latchholder to select_catalog_role;

create or replace view gv_$latch_misses as select * from gv$latch_misses;
create or replace public synonym gv$latch_misses for gv_$latch_misses;
grant select on gv_$latch_misses to select_catalog_role;

create or replace view gv_$session_longops as select * from gv$session_longops;
create or replace public synonym gv$session_longops for gv_$session_longops;
grant select on gv_$session_longops to public;

create or replace view gv_$resource as select * from gv$resource;
create or replace public synonym gv$resource for gv_$resource;
grant select on gv_$resource to select_catalog_role;

create or replace view gv_$_lock as select * from gv$_lock;
create or replace public synonym gv$_lock for gv_$_lock;
grant select on gv_$_lock to select_catalog_role;

create or replace view gv_$lock as select * from gv$lock;
create or replace public synonym gv$lock for gv_$lock;
grant select on gv_$lock to select_catalog_role;

create or replace view gv_$sesstat as select * from gv$sesstat;
create or replace public synonym gv$sesstat for gv_$sesstat;
grant select on gv_$sesstat to select_catalog_role;

create or replace view gv_$mystat as select * from gv$mystat;
create or replace public synonym gv$mystat for gv_$mystat;
grant select on gv_$mystat to select_catalog_role;

create or replace view gv_$subcache as select * from gv$subcache;
create or replace public synonym gv$subcache for gv_$subcache;
grant select on gv_$subcache to select_catalog_role;

create or replace view gv_$sysstat as select * from gv$sysstat;
create or replace public synonym gv$sysstat for gv_$sysstat;
grant select on gv_$sysstat to select_catalog_role;

create or replace view gv_$statname as select * from gv$statname;
create or replace public synonym gv$statname for gv_$statname;
grant select on gv_$statname to select_catalog_role;

create or replace view gv_$osstat as select * from gv$osstat;
create or replace public synonym gv$osstat for gv_$osstat;
grant select on gv_$osstat to select_catalog_role;

create or replace view gv_$access as select * from gv$access;
create or replace public synonym gv$access for gv_$access;
grant select on gv_$access to select_catalog_role;

create or replace view gv_$object_dependency as
  select * from gv$object_dependency;
create or replace public synonym gv$object_dependency
   for gv_$object_dependency;
grant select on gv_$object_dependency to select_catalog_role;

create or replace view gv_$dbfile as select * from gv$dbfile;
create or replace public synonym gv$dbfile for gv_$dbfile;
grant select on gv_$dbfile to select_catalog_role;

create or replace view gv_$datafile as select * from gv$datafile;
create or replace public synonym gv$datafile for gv_$datafile;
grant select on gv_$datafile to SELECT_CATALOG_ROLE;

create or replace view gv_$tempfile as select * from gv$tempfile;
create or replace public synonym gv$tempfile for gv_$tempfile;
grant select on gv_$tempfile to SELECT_CATALOG_ROLE;

create or replace view gv_$tablespace as select * from gv$tablespace;
create or replace public synonym gv$tablespace for gv_$tablespace;
grant select on gv_$tablespace to select_catalog_role;

create or replace view gv_$filestat as select * from gv$filestat;
create or replace public synonym gv$filestat for gv_$filestat;
grant select on gv_$filestat to select_catalog_role;

create or replace view gv_$tempstat as select * from gv$tempstat;
create or replace public synonym gv$tempstat for gv_$tempstat;
grant select on gv_$tempstat to select_catalog_role;

create or replace view gv_$logfile as select * from gv$logfile;
create or replace public synonym gv$logfile for gv_$logfile;
grant select on gv_$logfile to select_catalog_role;

create or replace view gv_$flashback_database_logfile as
  select * from gv$flashback_database_logfile;
create or replace public synonym gv$flashback_database_logfile
  for gv_$flashback_database_logfile;
grant select on gv_$flashback_database_logfile to select_catalog_role;

create or replace view gv_$flashback_database_log as
  select * from gv$flashback_database_log;
create or replace public synonym gv$flashback_database_log
  for gv_$flashback_database_log;
grant select on gv_$flashback_database_log to select_catalog_role;

create or replace view gv_$flashback_database_stat as
  select * from gv$flashback_database_stat;
create or replace public synonym gv$flashback_database_stat
  for gv_$flashback_database_stat;
grant select on gv_$flashback_database_stat to select_catalog_role;

create or replace view gv_$restore_point as
  select * from gv$restore_point;
create or replace public synonym gv$restore_point
  for gv_$restore_point;
grant select on gv_$restore_point to public;

remark This is bad for gv$ views.  Need to fix or just forget -msc-
remark create or replace view gv_$rollname as select
remark     x$kturd.kturdusn usn,undo$.name
remark   from x$kturd, undo$
remark   where x$kturd.kturdusn=undo$.us# and x$kturd.kturdsiz!=0;
remark create or replace public synonym gv$rollname for gv_$rollname;
remark grant select on gv_$rollname to select_catalog_role;

create or replace view gv_$rollstat as select * from gv$rollstat;
create or replace public synonym gv$rollstat for gv_$rollstat;
grant select on gv_$rollstat to select_catalog_role;

create or replace view gv_$undostat as select * from gv$undostat;
create or replace public synonym gv$undostat for gv_$undostat;
grant select on gv_$undostat to select_catalog_role;

create or replace view gv_$sga as select * from gv$sga;
create or replace public synonym gv$sga for gv_$sga;
grant select on gv_$sga to select_catalog_role;

create or replace view gv_$cluster_interconnects 
       as select * from gv$cluster_interconnects;
create or replace public synonym gv$cluster_interconnects 
        for gv_$cluster_interconnects;
grant select on gv_$cluster_interconnects to select_catalog_role;

create or replace view gv_$configured_interconnects 
       as select * from gv$configured_interconnects;
create or replace public synonym gv$configured_interconnects 
       for gv_$configured_interconnects;
grant select on gv_$configured_interconnects to select_catalog_role;

create or replace view gv_$parameter as select * from gv$parameter;
create or replace public synonym gv$parameter for gv_$parameter;
grant select on gv_$parameter to select_catalog_role;

create or replace view gv_$parameter2 as select * from gv$parameter2;
create or replace public synonym gv$parameter2 for gv_$parameter2;
grant select on gv_$parameter2 to select_catalog_role;

create or replace view gv_$system_parameter as select * from gv$system_parameter;
create or replace public synonym gv$system_parameter for gv_$system_parameter;
grant select on gv_$system_parameter to select_catalog_role;

create or replace view gv_$system_parameter2 as select * from gv$system_parameter2;
create or replace public synonym gv$system_parameter2
   for gv_$system_parameter2;
grant select on gv_$system_parameter2 to select_catalog_role;

create or replace view gv_$spparameter as select * from gv$spparameter;
create or replace public synonym gv$spparameter for gv_$spparameter;
grant select on gv_$spparameter to select_catalog_role;

create or replace view gv_$parameter_valid_values 
       as select * from gv$parameter_valid_values;
create or replace public synonym gv$parameter_valid_values 
       for gv_$parameter_valid_values;
grant select on gv_$parameter_valid_values to select_catalog_role;

create or replace view gv_$rowcache as select * from gv$rowcache;
create or replace public synonym gv$rowcache for gv_$rowcache;
grant select on gv_$rowcache to select_catalog_role;

create or replace view gv_$rowcache_parent as select * from gv$rowcache_parent;
create or replace public synonym gv$rowcache_parent for gv_$rowcache_parent;
grant select on gv_$rowcache_parent to select_catalog_role;

create or replace view gv_$rowcache_subordinate as
  select * from gv$rowcache_subordinate;
create or replace public synonym gv$rowcache_subordinate
   for gv_$rowcache_subordinate;
grant select on gv_$rowcache_subordinate to select_catalog_role;

create or replace view gv_$enabledprivs as select * from gv$enabledprivs;
create or replace public synonym gv$enabledprivs for gv_$enabledprivs;
grant select on gv_$enabledprivs to select_catalog_role;

create or replace view gv_$nls_parameters as select * from gv$nls_parameters;
create or replace public synonym gv$nls_parameters for gv_$nls_parameters;
grant select on gv_$nls_parameters to public;

create or replace view gv_$nls_valid_values as
select * from gv$nls_valid_values;
create or replace public synonym gv$nls_valid_values for gv_$nls_valid_values;
grant select on gv_$nls_valid_values to public;

create or replace view gv_$librarycache as select * from gv$librarycache;
create or replace public synonym gv$librarycache for gv_$librarycache;
grant select on gv_$librarycache to select_catalog_role;

create or replace view gv_$type_size as select * from gv$type_size;
create or replace public synonym gv$type_size for gv_$type_size;
grant select on gv_$type_size to select_catalog_role;

create or replace view gv_$archive as select * from gv$archive;
create or replace public synonym gv$archive for gv_$archive;
grant select on gv_$archive to select_catalog_role;

create or replace view gv_$circuit as select * from gv$circuit;
create or replace public synonym gv$circuit for gv_$circuit;
grant select on gv_$circuit to select_catalog_role;

create or replace view gv_$database as select * from gv$database;
create or replace public synonym gv$database for gv_$database;
grant select on gv_$database to select_catalog_role;

create or replace view gv_$instance as select * from gv$instance;
create or replace public synonym gv$instance for gv_$instance;
grant select on gv_$instance to select_catalog_role;

create or replace view gv_$dispatcher as select * from gv$dispatcher;
create or replace public synonym gv$dispatcher for gv_$dispatcher;
grant select on gv_$dispatcher to select_catalog_role;

create or replace view gv_$dispatcher_config
  as select * from gv$dispatcher_config;
create or replace public synonym gv$dispatcher_config
  for gv_$dispatcher_config;
grant select on gv_$dispatcher_config to select_catalog_role;

create or replace view gv_$dispatcher_rate as select * from gv$dispatcher_rate;
create or replace public synonym gv$dispatcher_rate for gv_$dispatcher_rate;
grant select on gv_$dispatcher_rate to select_catalog_role;

create or replace view gv_$loghist as select * from gv$loghist;
create or replace public synonym gv$loghist for gv_$loghist;
grant select on gv_$loghist to select_catalog_role;

REM create or replace view gv_$plsarea as select * from gv$plsarea;
REM create or replace public synonym gv$plsarea for gv_$plsarea;

create or replace view gv_$sqlarea as select * from gv$sqlarea;
create or replace public synonym gv$sqlarea for gv_$sqlarea;
grant select on gv_$sqlarea to select_catalog_role;

create or replace view gv_$sqlarea_plan_hash 
        as select * from gv$sqlarea_plan_hash;
create or replace public synonym gv$sqlarea_plan_hash for gv_$sqlarea_plan_hash;
grant select on gv_$sqlarea_plan_hash to select_catalog_role;

create or replace view gv_$sqltext as select * from gv$sqltext;
create or replace public synonym gv$sqltext for gv_$sqltext;
grant select on gv_$sqltext to select_catalog_role;

create or replace view gv_$sqltext_with_newlines as
      select * from gv$sqltext_with_newlines;
create or replace public synonym gv$sqltext_with_newlines
   for gv_$sqltext_with_newlines;
grant select on gv_$sqltext_with_newlines to select_catalog_role;

create or replace view gv_$sql as select * from gv$sql;
create or replace public synonym gv$sql for gv_$sql;
grant select on gv_$sql to select_catalog_role;

create or replace view gv_$sqlstats as select * from gv$sql;
create or replace public synonym gv$sqlstats for gv_$sql;
grant select on gv_$sqlstats to select_catalog_role;

create or replace view gv_$sql_shared_cursor as select * from gv$sql_shared_cursor;
create or replace public synonym gv$sql_shared_cursor for gv_$sql_shared_cursor;
grant select on gv_$sql_shared_cursor to select_catalog_role;

create or replace view gv_$db_pipes as select * from gv$db_pipes;
create or replace public synonym gv$db_pipes for gv_$db_pipes;
grant select on gv_$db_pipes to select_catalog_role;

create or replace view gv_$db_object_cache as select * from gv$db_object_cache;
create or replace public synonym gv$db_object_cache for gv_$db_object_cache;
grant select on gv_$db_object_cache to select_catalog_role;

create or replace view gv_$open_cursor as select * from gv$open_cursor;
create or replace public synonym gv$open_cursor for gv_$open_cursor;
grant select on gv_$open_cursor to select_catalog_role;

create or replace view gv_$option as select * from gv$option;
create or replace public synonym gv$option for gv_$option;
grant select on gv_$option to public;

create or replace view gv_$version as select * from gv$version;
create or replace public synonym gv$version for gv_$version;
grant select on gv_$version to public;

create or replace view gv_$pq_sesstat as select * from gv$pq_sesstat;
create or replace public synonym gv$pq_sesstat for gv_$pq_sesstat;
grant select on gv_$pq_sesstat to public;

create or replace view gv_$pq_sysstat as select * from gv$pq_sysstat;
create or replace public synonym gv$pq_sysstat for gv_$pq_sysstat;
grant select on gv_$pq_sysstat to select_catalog_role;

create or replace view gv_$pq_slave as select * from gv$pq_slave;
create or replace public synonym gv$pq_slave for gv_$pq_slave;
grant select on gv_$pq_slave to select_catalog_role;

create or replace view gv_$queue as select * from gv$queue;
create or replace public synonym gv$queue for gv_$queue;
grant select on gv_$queue to select_catalog_role;

create or replace view gv_$shared_server_monitor as select * from gv$shared_server_monitor;
create or replace public synonym gv$shared_server_monitor
   for gv_$shared_server_monitor;
grant select on gv_$shared_server_monitor to select_catalog_role;

create or replace view gv_$dblink as select * from gv$dblink;
create or replace public synonym gv$dblink for gv_$dblink;
grant select on gv_$dblink to select_catalog_role;

create or replace view gv_$pwfile_users as select * from gv$pwfile_users;
create or replace public synonym gv$pwfile_users for gv_$pwfile_users;
grant select on gv_$pwfile_users to select_catalog_role;

create or replace view gv_$reqdist as select * from gv$reqdist;
create or replace public synonym gv$reqdist for gv_$reqdist;
grant select on gv_$reqdist to select_catalog_role;

create or replace view gv_$sgastat as select * from gv$sgastat;
create or replace public synonym gv$sgastat for gv_$sgastat;
grant select on gv_$sgastat to select_catalog_role;

create or replace view gv_$sgainfo as select * from gv$sgainfo;
create or replace public synonym gv$sgainfo for gv_$sgainfo;
grant select on gv_$sgainfo to select_catalog_role;

create or replace view gv_$waitstat as select * from gv$waitstat;
create or replace public synonym gv$waitstat for gv_$waitstat;
grant select on gv_$waitstat to select_catalog_role;

create or replace view gv_$shared_server as select * from gv$shared_server;
create or replace public synonym gv$shared_server for gv_$shared_server;
grant select on gv_$shared_server to select_catalog_role;

create or replace view gv_$timer as select * from gv$timer;
create or replace public synonym gv$timer for gv_$timer;
grant select on gv_$timer to select_catalog_role;

create or replace view gv_$recover_file as select * from gv$recover_file;
create or replace public synonym gv$recover_file for gv_$recover_file;
grant select on gv_$recover_file to select_catalog_role;

create or replace view gv_$backup as select * from gv$backup;
create or replace public synonym gv$backup for gv_$backup;
grant select on gv_$backup to select_catalog_role;


create or replace view gv_$backup_set as select * from gv$backup_set;
create or replace public synonym gv$backup_set for gv_$backup_set;
grant select on gv_$backup_set to select_catalog_role;

create or replace view gv_$backup_piece as select * from gv$backup_piece;
create or replace public synonym gv$backup_piece for gv_$backup_piece;
grant select on gv_$backup_piece to select_catalog_role;

create or replace view gv_$backup_datafile as select * from gv$backup_datafile;
create or replace public synonym gv$backup_datafile for gv_$backup_datafile;
grant select on gv_$backup_datafile to select_catalog_role;

create or replace view gv_$backup_spfile as select * from gv$backup_spfile;
create or replace public synonym gv$backup_spfile for gv_$backup_spfile;
grant select on gv_$backup_spfile to select_catalog_role;

create or replace view gv_$backup_redolog as select * from gv$backup_redolog;
create or replace public synonym gv$backup_redolog for gv_$backup_redolog;
grant select on gv_$backup_redolog to select_catalog_role;

create or replace view gv_$backup_corruption as select * from gv$backup_corruption;
create or replace public synonym gv$backup_corruption
   for gv_$backup_corruption;
grant select on gv_$backup_corruption to select_catalog_role;

create or replace view gv_$copy_corruption as select * from gv$copy_corruption;
create or replace public synonym gv$copy_corruption for gv_$copy_corruption;
grant select on gv_$copy_corruption to select_catalog_role;

create or replace view gv_$database_block_corruption as select * from
   gv$database_block_corruption;
create or replace public synonym gv$database_block_corruption
   for gv_$database_block_corruption;
grant select on gv_$database_block_corruption to select_catalog_role;

create or replace view gv_$mttr_target_advice as select * from
   gv$mttr_target_advice;
create or replace public synonym gv$mttr_target_advice
   for gv_$mttr_target_advice;
grant select on gv_$mttr_target_advice to select_catalog_role;

create or replace view gv_$statistics_level as select * from
   gv$statistics_level;
create or replace public synonym gv$statistics_level
   for gv_$statistics_level;
grant select on gv_$statistics_level to select_catalog_role;

create or replace view gv_$deleted_object as select * from gv$deleted_object;
create or replace public synonym gv$deleted_object for gv_$deleted_object;
grant select on gv_$deleted_object to select_catalog_role;

create or replace view gv_$proxy_datafile as select * from gv$proxy_datafile;
create or replace public synonym gv$proxy_datafile for gv_$proxy_datafile;
grant select on gv_$proxy_datafile to select_catalog_role;

create or replace view gv_$proxy_archivedlog as select * from gv$proxy_archivedlog;
create or replace public synonym gv$proxy_archivedlog
   for gv_$proxy_archivedlog;
grant select on gv_$proxy_archivedlog to select_catalog_role;

create or replace view gv_$controlfile_record_section as select * from gv$controlfile_record_section;
create or replace public synonym gv$controlfile_record_section
   for gv_$controlfile_record_section;
grant select on gv_$controlfile_record_section to select_catalog_role;

create or replace view gv_$archived_log as select * from gv$archived_log;
create or replace public synonym gv$archived_log for gv_$archived_log;
grant select on gv_$archived_log to select_catalog_role;

create or replace view gv_$offline_range as select * from gv$offline_range;
create or replace public synonym gv$offline_range for gv_$offline_range;
grant select on gv_$offline_range to select_catalog_role;

create or replace view gv_$datafile_copy as select * from gv$datafile_copy;
create or replace public synonym gv$datafile_copy for gv_$datafile_copy;
grant select on gv_$datafile_copy to select_catalog_role;

create or replace view gv_$log_history as select * from gv$log_history;
create or replace public synonym gv$log_history for gv_$log_history;
grant select on gv_$log_history to select_catalog_role;

create or replace view gv_$recovery_log as select * from gv$recovery_log;
create or replace public synonym gv$recovery_log for gv_$recovery_log;
grant select on gv_$recovery_log to select_catalog_role;

create or replace view gv_$archive_gap as select * from gv$archive_gap;
create or replace public synonym gv$archive_gap for gv_$archive_gap;
grant select on gv_$archive_gap to select_catalog_role;

create or replace view gv_$datafile_header as select * from gv$datafile_header;
create or replace public synonym gv$datafile_header for gv_$datafile_header;
grant select on gv_$datafile_header to select_catalog_role;

create or replace view gv_$backup_device as select * from gv$backup_device;
create or replace public synonym gv$backup_device for gv_$backup_device;
grant select on gv_$backup_device to select_catalog_role;

create or replace view gv_$managed_standby as select * from gv$managed_standby;
create or replace public synonym gv$managed_standby for gv_$managed_standby;
grant select on gv_$managed_standby to select_catalog_role;

create or replace view gv_$archive_processes as select * from gv$archive_processes;
create or replace public synonym gv$archive_processes
   for gv_$archive_processes;
grant select on gv_$archive_processes to select_catalog_role;

create or replace view gv_$archive_dest as select * from gv$archive_dest;
create or replace public synonym gv$archive_dest for gv_$archive_dest;
grant select on gv_$archive_dest to select_catalog_role;

create or replace view gv_$dataguard_config as
   select * from gv$dataguard_config;
create or replace public synonym gv$dataguard_config for gv_$dataguard_config;
grant select on gv_$dataguard_config to select_catalog_role;

create or replace view gv_$fixed_table as select * from gv$fixed_table;
create or replace public synonym gv$fixed_table for gv_$fixed_table;
grant select on gv_$fixed_table to select_catalog_role;

create or replace view gv_$fixed_view_definition as
   select * from gv$fixed_view_definition;
create or replace public synonym gv$fixed_view_definition
   for gv_$fixed_view_definition;
grant select on gv_$fixed_view_definition to select_catalog_role;

create or replace view gv_$indexed_fixed_column as
  select * from gv$indexed_fixed_column;
create or replace public synonym gv$indexed_fixed_column
   for gv_$indexed_fixed_column;
grant select on gv_$indexed_fixed_column to select_catalog_role;

create or replace view gv_$session_cursor_cache as
  select * from gv$session_cursor_cache;
create or replace public synonym gv$session_cursor_cache
   for gv_$session_cursor_cache;
grant select on gv_$session_cursor_cache to select_catalog_role;

create or replace view gv_$session_wait_class as
  select * from gv$session_wait_class;
create or replace public synonym gv$session_wait_class
  for gv_$session_wait_class;
grant select on gv_$session_wait_class to select_catalog_role;

create or replace view gv_$session_wait as
  select * from gv$session_wait;
create or replace public synonym gv$session_wait for gv_$session_wait;
grant select on gv_$session_wait to select_catalog_role;

create or replace view gv_$session_wait_history as
  select * from gv$session_wait_history;
create or replace public synonym gv$session_wait_history
  for gv_$session_wait_history;
grant select on gv_$session_wait_history to select_catalog_role;

create or replace view gv_$session_event as
  select * from gv$session_event;
create or replace public synonym gv$session_event for gv_$session_event;
grant select on gv_$session_event to select_catalog_role;

create or replace view gv_$session_connect_info as
  select * from gv$session_connect_info;
create or replace public synonym gv$session_connect_info
   for gv_$session_connect_info;
grant select on gv_$session_connect_info to select_catalog_role;

create or replace view gv_$system_wait_class as
  select * from gv$system_wait_class;
create or replace public synonym gv$system_wait_class for gv_$system_wait_class;
grant select on gv_$system_wait_class to select_catalog_role;

create or replace view gv_$system_event as
  select * from gv$system_event;
create or replace public synonym gv$system_event for gv_$system_event;
grant select on gv_$system_event to select_catalog_role;

create or replace view gv_$event_name as
  select * from gv$event_name;
create or replace public synonym gv$event_name for gv_$event_name;
grant select on gv_$event_name to select_catalog_role;

create or replace view gv_$event_histogram as
  select * from gv$event_histogram;
create or replace public synonym gv$event_histogram for gv_$event_histogram;
grant select on gv_$event_histogram to select_catalog_role;

create or replace view gv_$file_histogram as
  select * from gv$file_histogram;
create or replace public synonym gv$file_histogram for gv_$file_histogram;
grant select on gv_$file_histogram to select_catalog_role;

create or replace view gv_$temp_histogram as
  select * from gv$temp_histogram;
create or replace public synonym gv$temp_histogram for gv_$temp_histogram;
grant select on gv_$temp_histogram to select_catalog_role;

create or replace view gv_$execution as
  select * from gv$execution;
create or replace public synonym gv$execution for gv_$execution;
grant select on gv_$execution to select_catalog_role;

create or replace view gv_$system_cursor_cache as
  select * from gv$system_cursor_cache;
create or replace public synonym gv$system_cursor_cache
   for gv_$system_cursor_cache;
grant select on gv_$system_cursor_cache to select_catalog_role;

create or replace view gv_$sess_io as
  select * from gv$sess_io;
create or replace public synonym gv$sess_io for gv_$sess_io;
grant select on gv_$sess_io to select_catalog_role;

create or replace view gv_$recovery_status as
  select * from gv$recovery_status;
create or replace public synonym gv$recovery_status for gv_$recovery_status;
grant select on gv_$recovery_status to select_catalog_role;

create or replace view gv_$recovery_file_status as
  select * from gv$recovery_file_status;
create or replace public synonym gv$recovery_file_status
   for gv_$recovery_file_status;
grant select on gv_$recovery_file_status to select_catalog_role;

create or replace view gv_$recovery_progress as
  select * from gv$recovery_progress;
create or replace public synonym gv$recovery_progress
   for gv_$recovery_progress;
grant select on gv_$recovery_progress to select_catalog_role;

create or replace view gv_$shared_pool_reserved as
  select * from gv$shared_pool_reserved;
create or replace public synonym gv$shared_pool_reserved
   for gv_$shared_pool_reserved;
grant select on gv_$shared_pool_reserved to select_catalog_role;

create or replace view gv_$sort_segment as select * from gv$sort_segment;
create or replace public synonym gv$sort_segment for gv_$sort_segment;
grant select on gv_$sort_segment to select_catalog_role;

create or replace view gv_$sort_usage as select * from gv$sort_usage;
create or replace public synonym gv$tempseg_usage for gv_$sort_usage;
create or replace public synonym gv$sort_usage for gv_$sort_usage;
grant select on gv_$sort_usage to select_catalog_role;

create or replace view gv_$pq_tqstat as select * from gv$pq_tqstat;
create or replace public synonym gv$pq_tqstat for gv_$pq_tqstat;
grant select on gv_$pq_tqstat to public;

create or replace view gv_$active_instances as select * from gv$active_instances;
create or replace public synonym gv$active_instances for gv_$active_instances;
grant select on gv_$active_instances to public;

create or replace view gv_$sql_cursor as select * from gv$sql_cursor;
create or replace public synonym gv$sql_cursor for gv_$sql_cursor;
grant select on gv_$sql_cursor to select_catalog_role;

create or replace view gv_$sql_bind_metadata as
  select * from gv$sql_bind_metadata;
create or replace public synonym gv$sql_bind_metadata
   for gv_$sql_bind_metadata;
grant select on gv_$sql_bind_metadata to select_catalog_role;

create or replace view gv_$sql_bind_data as select * from gv$sql_bind_data;
create or replace public synonym gv$sql_bind_data for gv_$sql_bind_data;
grant select on gv_$sql_bind_data to select_catalog_role;

create or replace view gv_$sql_shared_memory
  as select * from gv$sql_shared_memory;
create or replace public synonym gv$sql_shared_memory
   for gv_$sql_shared_memory;
grant select on gv_$sql_shared_memory to select_catalog_role;

create or replace view gv_$global_transaction
  as select * from gv$global_transaction;
create or replace public synonym gv$global_transaction
   for gv_$global_transaction;
grant select on gv_$global_transaction to select_catalog_role;

create or replace view gv_$session_object_cache as
  select * from gv$session_object_cache;
create or replace public synonym gv$session_object_cache
   for gv_$session_object_cache;
grant select on gv_$session_object_cache to select_catalog_role;

create or replace view gv_$aq1 as
  select * from gv$aq1;
create or replace public synonym gv$aq1 for gv_$aq1;
grant select on gv_$aq1 to select_catalog_role;

create or replace view gv_$lock_activity as
  select * from gv$lock_activity;
create or replace public synonym gv$lock_activity for gv_$lock_activity;
grant select on gv_$lock_activity to public;

create or replace view gv_$hs_agent as
  select * from gv$hs_agent;
create or replace public synonym gv$hs_agent for gv_$hs_agent;
grant select on gv_$hs_agent to select_catalog_role;

create or replace view gv_$hs_session as
  select * from gv$hs_session;
create or replace public synonym gv$hs_session for gv_$hs_session;
grant select on gv_$hs_session to select_catalog_role;

create or replace view gv_$hs_parameter as
  select * from gv$hs_parameter;
create or replace public synonym gv$hs_parameter for gv_$hs_parameter;
grant select on gv_$hs_parameter to select_catalog_role;

create or replace view gv_$rsrc_consume_group_cpu_mth as
  select * from gv$rsrc_consumer_group_cpu_mth;
create or replace public synonym gv$rsrc_consumer_group_cpu_mth
   for gv_$rsrc_consume_group_cpu_mth;
grant select on gv_$rsrc_consume_group_cpu_mth to public;

create or replace view gv_$rsrc_plan_cpu_mth as
  select * from gv$rsrc_plan_cpu_mth;
create or replace public synonym gv$rsrc_plan_cpu_mth
   for gv_$rsrc_plan_cpu_mth;
grant select on gv_$rsrc_plan_cpu_mth to public;

create or replace view gv_$rsrc_consumer_group as
  select * from gv$rsrc_consumer_group;
create or replace public synonym gv$rsrc_consumer_group
   for gv_$rsrc_consumer_group;
grant select on gv_$rsrc_consumer_group to public;

create or replace view gv_$rsrc_session_info as
  select * from gv$rsrc_session_info;
create or replace public synonym gv$rsrc_session_info
   for gv_$rsrc_session_info;
grant select on gv_$rsrc_session_info to public;

create or replace view gv_$rsrc_plan as
  select * from gv$rsrc_plan;
create or replace public synonym gv$rsrc_plan for gv_$rsrc_plan;
grant select on gv_$rsrc_plan to public;

create or replace view gv_$rsrc_cons_group_history as
  select * from gv$rsrc_cons_group_history;
create or replace public synonym gv$rsrc_cons_group_history 
  for gv_$rsrc_cons_group_history;
grant select on gv_$rsrc_cons_group_history to public;

create or replace view gv_$rsrc_plan_history as
  select * from gv$rsrc_plan_history;
create or replace public synonym gv$rsrc_plan_history 
  for gv_$rsrc_plan_history;
grant select on gv_$rsrc_plan_history to public;

create or replace view gv_$blocking_quiesce as
  select * from gv$blocking_quiesce;
create or replace public synonym gv$blocking_quiesce
   for gv_$blocking_quiesce;
grant select on gv_$blocking_quiesce to public;

create or replace view gv_$px_buffer_advice as
  select * from gv$px_buffer_advice;
create or replace public synonym gv$px_buffer_advice for gv_$px_buffer_advice;
grant select on gv_$px_buffer_advice to select_catalog_role;

create or replace view gv_$px_session as
  select * from gv$px_session;
create or replace public synonym gv$px_session for gv_$px_session;
grant select on gv_$px_session to select_catalog_role;

create or replace view gv_$px_sesstat as
  select * from gv$px_sesstat;
create or replace public synonym gv$px_sesstat for gv_$px_sesstat;
grant select on gv_$px_sesstat to select_catalog_role;

create or replace view gv_$backup_sync_io as
  select * from gv$backup_sync_io;
create or replace public synonym gv$backup_sync_io for gv_$backup_sync_io;
grant select on gv_$backup_sync_io to select_catalog_role;

create or replace view gv_$backup_async_io as
  select * from gv$backup_async_io;
create or replace public synonym gv$backup_async_io for gv_$backup_async_io;
grant select on gv_$backup_async_io to select_catalog_role;

create or replace view gv_$temporary_lobs as select * from gv$temporary_lobs;
create or replace public synonym gv$temporary_lobs for gv_$temporary_lobs;
grant select on gv_$temporary_lobs to public;

create or replace view gv_$px_process as
  select * from gv$px_process;
create or replace public synonym gv$px_process for gv_$px_process;
grant select on gv_$px_process to select_catalog_role;

create or replace view gv_$px_process_sysstat as
  select * from gv$px_process_sysstat;
create or replace public synonym gv$px_process_sysstat
   for gv_$px_process_sysstat;
grant select on gv_$px_process_sysstat to select_catalog_role;

create or replace view gv_$logmnr_contents as
  select * from gv$logmnr_contents;
create or replace public synonym gv$logmnr_contents for gv_$logmnr_contents;
grant select on gv_$logmnr_contents to select_catalog_role;

create or replace view gv_$logmnr_parameters as
  select * from gv$logmnr_parameters;
create or replace public synonym gv$logmnr_parameters
   for gv_$logmnr_parameters;
grant select on gv_$logmnr_parameters to select_catalog_role;

create or replace view gv_$logmnr_dictionary as
  select * from gv$logmnr_dictionary;
create or replace public synonym gv$logmnr_dictionary
   for gv_$logmnr_dictionary;
grant select on gv_$logmnr_dictionary to select_catalog_role;

create or replace view gv_$logmnr_logs as
  select * from gv$logmnr_logs;
create or replace public synonym gv$logmnr_logs for gv_$logmnr_logs;
grant select on gv_$logmnr_logs to select_catalog_role;

create or replace view gv_$rfs_thread as
  select * from gv$rfs_thread;
create or replace public synonym gv$rfs_thread for gv_$rfs_thread;
grant select on gv_$rfs_thread to select_catalog_role;

create or replace view gv_$standby_apply_snapshot as
  select * from gv$standby_apply_snapshot;
create or replace public synonym gv$standby_apply_snapshot 
  for gv_$standby_apply_snapshot;
grant select on gv_$standby_apply_snapshot to select_catalog_role;

create or replace view gv_$global_blocked_locks as
select * from gv$global_blocked_locks;
create or replace public synonym gv$global_blocked_locks
   for gv_$global_blocked_locks;
grant select on gv_$global_blocked_locks to select_catalog_role;

create or replace view gv_$aw_olap as select * from gv$aw_olap;
create or replace public synonym gv$aw_olap for gv_$aw_olap;
grant select on gv_$aw_olap to public;

create or replace view gv_$aw_calc as select * from gv$aw_calc;
create or replace public synonym gv$aw_calc for gv_$aw_calc;
grant select on gv_$aw_calc to public;

create or replace view gv_$aw_session_info as select * from gv$aw_session_info;
create or replace public synonym gv$aw_session_info for gv_$aw_session_info;
grant select on gv_$aw_session_info to public;

create or replace view gv_$aw_longops as select * from gv$aw_longops;
create or replace public synonym gv$aw_longops for gv_$aw_longops;
grant select on gv_$aw_longops to public;

create or replace view gv_$max_active_sess_target_mth as
  select * from gv$max_active_sess_target_mth;
create or replace public synonym gv$max_active_sess_target_mth
   for gv_$max_active_sess_target_mth;
grant select on gv_$max_active_sess_target_mth to public;

create or replace view gv_$active_sess_pool_mth as
  select * from gv$active_sess_pool_mth;
create or replace public synonym gv$active_sess_pool_mth
   for gv_$active_sess_pool_mth;
grant select on gv_$active_sess_pool_mth to public;

create or replace view gv_$parallel_degree_limit_mth as
  select * from gv$parallel_degree_limit_mth;
create or replace public synonym gv$parallel_degree_limit_mth
   for gv_$parallel_degree_limit_mth;
grant select on gv_$parallel_degree_limit_mth to public;

create or replace view gv_$queueing_mth as
  select * from gv$queueing_mth;
create or replace public synonym gv$queueing_mth for gv_$queueing_mth;
grant select on gv_$queueing_mth to public;

create or replace view gv_$reserved_words as
  select * from gv$reserved_words;
create or replace public synonym gv$reserved_words for gv_$reserved_words;
grant select on gv_$reserved_words to select_catalog_role;

create or replace view gv_$archive_dest_status as select * from gv$archive_dest_status;
create or replace public synonym gv$archive_dest_status
   for gv_$archive_dest_status;
grant select on gv_$archive_dest_status to select_catalog_role;


create or replace view v_$logmnr_logfile as
  select * from v$logmnr_logfile;
create or replace public synonym v$logmnr_logfile for v_$logmnr_logfile;
grant select on v_$logmnr_logfile to select_catalog_role;

create or replace view v_$logmnr_process as
  select * from v$logmnr_process;
create or replace public synonym v$logmnr_process for v_$logmnr_process;
grant select on v_$logmnr_process to select_catalog_role;

create or replace view v_$logmnr_latch as
  select * from v$logmnr_latch;
create or replace public synonym v$logmnr_latch for v_$logmnr_latch;
grant select on v_$logmnr_latch to select_catalog_role;

create or replace view v_$logmnr_transaction as
  select * from v$logmnr_transaction;
create or replace public synonym v$logmnr_transaction
   for v_$logmnr_transaction;
grant select on v_$logmnr_transaction to select_catalog_role;

create or replace view v_$logmnr_region as
  select * from v$logmnr_region;
create or replace public synonym v$logmnr_region for v_$logmnr_region;
grant select on v_$logmnr_region to select_catalog_role;

create or replace view v_$logmnr_callback as
  select * from v$logmnr_callback;
create or replace public synonym v$logmnr_callback for v_$logmnr_callback;
grant select on v_$logmnr_callback to select_catalog_role;

create or replace view v_$logmnr_session as
  select * from v$logmnr_session;
create or replace public synonym v$logmnr_session for v_$logmnr_session;
grant select on v_$logmnr_session to select_catalog_role;


create or replace view gv_$logmnr_logfile as
  select * from gv$logmnr_logfile;
create or replace public synonym gv$logmnr_logfile for gv_$logmnr_logfile;
grant select on gv_$logmnr_logfile to select_catalog_role;

create or replace view gv_$logmnr_process as
  select * from gv$logmnr_process;
create or replace public synonym gv$logmnr_process for gv_$logmnr_process;
grant select on gv_$logmnr_process to select_catalog_role;

create or replace view gv_$logmnr_latch as
  select * from gv$logmnr_latch;
create or replace public synonym gv$logmnr_latch for gv_$logmnr_latch;
grant select on gv_$logmnr_latch to select_catalog_role;

create or replace view gv_$logmnr_transaction as
  select * from gv$logmnr_transaction;
create or replace public synonym gv$logmnr_transaction
   for gv_$logmnr_transaction;
grant select on gv_$logmnr_transaction to select_catalog_role;

create or replace view gv_$logmnr_region as
  select * from gv$logmnr_region;
create or replace public synonym gv$logmnr_region for gv_$logmnr_region;
grant select on gv_$logmnr_region to select_catalog_role;

create or replace view gv_$logmnr_callback as
  select * from gv$logmnr_callback;
create or replace public synonym gv$logmnr_callback for gv_$logmnr_callback;
grant select on gv_$logmnr_callback to select_catalog_role;

create or replace view gv_$logmnr_session as
  select * from gv$logmnr_session;
create or replace public synonym gv$logmnr_session for gv_$logmnr_session;
grant select on gv_$logmnr_session to select_catalog_role;

create or replace view gv_$logmnr_stats as select * from gv$logmnr_stats;
create or replace public synonym gv$logmnr_stats for gv_$logmnr_stats;
grant select on gv_$logmnr_stats to select_catalog_role;

create or replace view gv_$logmnr_dictionary_load as
  select * from gv$logmnr_dictionary_load;
create or replace public synonym gv$logmnr_dictionary_load
  for gv_$logmnr_dictionary_load;
grant select on gv_$logmnr_dictionary_load to select_catalog_role;

create or replace view gv_$db_cache_advice as select * from gv$db_cache_advice;
create or replace public synonym gv$db_cache_advice for gv_$db_cache_advice;
grant select on gv_$db_cache_advice to select_catalog_role;

create or replace view gv_$sga_target_advice as select * from gv$sga_target_advice;
create or replace public synonym gv$sga_target_advice for gv_$sga_target_advice;
grant select on gv_$sga_target_advice to select_catalog_role;

create or replace view gv_$segment_statistics as
  select * from gv$segment_statistics;
create or replace public synonym gv$segment_statistics
  for gv_$segment_statistics;
grant select on gv_$segment_statistics to select_catalog_role;

create or replace view gv_$segstat_name as
  select * from gv$segstat_name;
create or replace public synonym gv$segstat_name
  for gv_$segstat_name;
grant select on gv_$segstat_name to select_catalog_role;

create or replace view gv_$segstat as select * from gv$segstat;
create or replace public synonym gv$segstat for gv_$segstat;
grant select on gv_$segstat to select_catalog_role;

create or replace view gv_$library_cache_memory as
  select * from gv$library_cache_memory;
create or replace public synonym gv$library_cache_memory
  for gv_$library_cache_memory;
grant select on gv_$library_cache_memory to select_catalog_role;

create or replace view gv_$java_library_cache_memory as
  select * from gv$java_library_cache_memory;
create or replace public synonym gv$java_library_cache_memory
  for gv_$java_library_cache_memory;
grant select on gv_$java_library_cache_memory to select_catalog_role;

create or replace view gv_$shared_pool_advice as
  select * from gv$shared_pool_advice;
create or replace public synonym gv$shared_pool_advice
  for gv_$shared_pool_advice;
grant select on gv_$shared_pool_advice to select_catalog_role;

create or replace view gv_$java_pool_advice as
  select * from gv$java_pool_advice;
create or replace public synonym gv$java_pool_advice
  for gv_$java_pool_advice;
grant select on gv_$java_pool_advice to select_catalog_role;

create or replace view gv_$streams_pool_advice as
  select * from gv$streams_pool_advice;
create or replace public synonym gv$streams_pool_advice
  for gv_$streams_pool_advice;
grant select on gv_$streams_pool_advice to select_catalog_role;

create or replace view gv_$sga_current_resize_ops as
  select * from gv$sga_current_resize_ops;
create or replace public synonym gv$sga_current_resize_ops
  for gv_$sga_current_resize_ops;
grant select on gv_$sga_current_resize_ops to select_catalog_role;

create or replace view gv_$sga_resize_ops as
  select * from gv$sga_resize_ops;
create or replace public synonym gv$sga_resize_ops
  for gv_$sga_resize_ops;
grant select on gv_$sga_resize_ops to select_catalog_role;

create or replace view gv_$sga_dynamic_components as
  select * from gv$sga_dynamic_components;
create or replace public synonym gv$sga_dynamic_components
  for gv_$sga_dynamic_components;
grant select on gv_$sga_dynamic_components to select_catalog_role;

create or replace view gv_$sga_dynamic_free_memory as
  select * from gv$sga_dynamic_free_memory;
create or replace public synonym gv$sga_dynamic_free_memory
  for gv_$sga_dynamic_free_memory;
grant select on gv_$sga_dynamic_free_memory to select_catalog_role;

create or replace view gv_$resumable as select * from gv$resumable;
create or replace public synonym gv$resumable for gv_$resumable;
grant select on gv_$resumable to select_catalog_role;

create or replace view gv_$timezone_names as select * from gv$timezone_names;
create or replace public synonym gv$timezone_names for gv_$timezone_names;
grant select on gv_$timezone_names to public;

create or replace view gv_$timezone_file as select * from gv$timezone_file;
create or replace public synonym gv$timezone_file for gv_$timezone_file;
grant select on gv_$timezone_file to public;

create or replace view gv_$enqueue_stat as select * from gv$enqueue_stat;
create or replace public synonym gv$enqueue_stat for gv_$enqueue_stat;
grant select on gv_$enqueue_stat to select_catalog_role;

create or replace view gv_$enqueue_statistics as select * from gv$enqueue_statistics;
create or replace public synonym gv$enqueue_statistics for gv_$enqueue_statistics;
grant select on gv_$enqueue_statistics to select_catalog_role;

create or replace view gv_$lock_type as select * from gv$lock_type;
create or replace public synonym gv$lock_type for gv_$lock_type;
grant select on gv_$lock_type to select_catalog_role;

create or replace view gv_$rman_configuration as select * from gv$rman_configuration;
create or replace public synonym gv$rman_configuration
   for gv_$rman_configuration;
grant select on gv_$rman_configuration to select_catalog_role;

create or replace view gv_$vpd_policy as
  select * from gv$vpd_policy;
create or replace public synonym gv$vpd_policy for gv_$vpd_policy;
grant select on gv_$vpd_policy to select_catalog_role;

create or replace view v_$vpd_policy as
  select * from v$vpd_policy;
create or replace public synonym v$vpd_policy for v_$vpd_policy;
grant select on v_$vpd_policy to select_catalog_role;

create or replace view gv_$database_incarnation as select * from
   gv$database_incarnation;
create or replace public synonym gv$database_incarnation
   for gv_$database_incarnation;
grant select on gv_$database_incarnation to select_catalog_role;

CREATE or replace VIEW gv_$asm_template as
  SELECT * FROM gv$asm_template;
  CREATE or replace PUBLIC synonym gv$asm_template FOR gv_$asm_template;
  GRANT SELECT ON gv_$asm_template TO select_catalog_role;

  CREATE or replace VIEW v_$asm_template as
    SELECT * FROM v$asm_template;
 CREATE or replace PUBLIC synonym v$asm_template FOR v_$asm_template;
 GRANT SELECT ON v_$asm_template TO select_catalog_role;

 CREATE or replace VIEW gv_$asm_file as
  SELECT * FROM gv$asm_file;
  CREATE or replace PUBLIC synonym gv$asm_file FOR gv_$asm_file;
  GRANT SELECT ON gv_$asm_file TO select_catalog_role;

  CREATE or replace VIEW v_$asm_file as
    SELECT * FROM v$asm_file;
 CREATE or replace PUBLIC synonym v$asm_file FOR v_$asm_file;
 GRANT SELECT ON v_$asm_file TO select_catalog_role;

 CREATE or replace VIEW gv_$asm_diskgroup as
  SELECT * FROM gv$asm_diskgroup;
  CREATE or replace PUBLIC synonym gv$asm_diskgroup FOR gv_$asm_diskgroup;
  GRANT SELECT ON gv_$asm_diskgroup TO select_catalog_role;

  CREATE or replace VIEW v_$asm_diskgroup as
    SELECT * FROM v$asm_diskgroup;
 CREATE or replace PUBLIC synonym v$asm_diskgroup FOR v_$asm_diskgroup;
 GRANT SELECT ON v_$asm_diskgroup TO select_catalog_role;

 CREATE or replace VIEW gv_$asm_diskgroup_stat as
  SELECT * FROM gv$asm_diskgroup_stat;
  CREATE or replace PUBLIC synonym gv$asm_diskgroup_stat FOR
    gv_$asm_diskgroup_stat;
  GRANT SELECT ON gv_$asm_diskgroup_stat TO select_catalog_role;

  CREATE or replace VIEW v_$asm_diskgroup_stat as
    SELECT * FROM v$asm_diskgroup_stat;
 CREATE or replace PUBLIC synonym v$asm_diskgroup_stat FOR
    v_$asm_diskgroup_stat;
 GRANT SELECT ON v_$asm_diskgroup_stat TO select_catalog_role;

 CREATE or replace VIEW gv_$asm_disk as
  SELECT * FROM gv$asm_disk;
  CREATE or replace PUBLIC synonym gv$asm_disk FOR gv_$asm_disk;
  GRANT SELECT ON gv_$asm_disk TO select_catalog_role;

  CREATE or replace VIEW v_$asm_disk as
    SELECT * FROM v$asm_disk;
 CREATE or replace PUBLIC synonym v$asm_disk FOR v_$asm_disk;
 GRANT SELECT ON v_$asm_disk TO select_catalog_role;

 CREATE or replace VIEW gv_$asm_disk_stat as
  SELECT * FROM gv$asm_disk_stat;
  CREATE or replace PUBLIC synonym gv$asm_disk_stat FOR gv_$asm_disk_stat;
  GRANT SELECT ON gv_$asm_disk_stat TO select_catalog_role;

  CREATE or replace VIEW v_$asm_disk_stat as
    SELECT * FROM v$asm_disk_stat;
 CREATE or replace PUBLIC synonym v$asm_disk_stat FOR v_$asm_disk_stat;
 GRANT SELECT ON v_$asm_disk_stat TO select_catalog_role;

 CREATE or replace VIEW gv_$asm_client as
  SELECT * FROM gv$asm_client;
  CREATE or replace PUBLIC synonym gv$asm_client FOR gv_$asm_client;
  GRANT SELECT ON gv_$asm_client TO select_catalog_role;

  CREATE or replace VIEW v_$asm_client as
    SELECT * FROM v$asm_client;
 CREATE or replace PUBLIC synonym v$asm_client FOR v_$asm_client;
 GRANT SELECT ON v_$asm_client TO select_catalog_role;

 CREATE or replace VIEW gv_$asm_alias as
  SELECT * FROM gv$asm_alias;
  CREATE or replace PUBLIC synonym gv$asm_alias FOR gv_$asm_alias;
  GRANT SELECT ON gv_$asm_alias TO select_catalog_role;

  CREATE or replace VIEW v_$asm_alias as
    SELECT * FROM v$asm_alias;
 CREATE or replace PUBLIC synonym v$asm_alias FOR v_$asm_alias;
 GRANT SELECT ON v_$asm_alias TO select_catalog_role;

 CREATE or replace VIEW gv_$asm_operation as
  SELECT * FROM gv$asm_operation;
  CREATE or replace PUBLIC synonym gv$asm_operation FOR gv_$asm_operation;
  GRANT SELECT ON gv_$asm_operation TO select_catalog_role;

  CREATE or replace VIEW v_$asm_operation as
    SELECT * FROM v$asm_operation;
 CREATE or replace PUBLIC synonym v$asm_operation FOR v_$asm_operation;
 GRANT SELECT ON v_$asm_operation TO select_catalog_role;

create or replace view gv_$rule_set as select * from gv$rule_set;
create or replace public synonym gv$rule_set for gv_$rule_set;
grant select on gv_$rule_set to select_catalog_role;

create or replace view v_$rule_set as select * from v$rule_set;
create or replace public synonym v$rule_set for v_$rule_set;
grant select on v_$rule_set to select_catalog_role;

create or replace view gv_$rule as select * from gv$rule;
create or replace public synonym gv$rule for gv_$rule;
grant select on gv_$rule to select_catalog_role;

create or replace view v_$rule as select * from v$rule;
create or replace public synonym v$rule for v_$rule;
grant select on v_$rule to select_catalog_role;

create or replace view gv_$rule_set_aggregate_stats as
    select * from gv$rule_set_aggregate_stats;
create or replace public synonym gv$rule_set_aggregate_stats for
    gv_$rule_set_aggregate_stats;
grant select on gv_$rule_set_aggregate_stats to select_catalog_role;

create or replace view v_$rule_set_aggregate_stats as
    select * from v$rule_set_aggregate_stats;
create or replace public synonym v$rule_set_aggregate_stats for
    v_$rule_set_aggregate_stats;
grant select on v_$rule_set_aggregate_stats to select_catalog_role;

create or replace view gv_$javapool as
    select * from gv$javapool;
create or replace public synonym gv$javapool for gv_$javapool;
grant select on gv_$javapool to select_catalog_role;

create or replace view v_$javapool as
    select * from v$javapool;
create or replace public synonym v$javapool for v_$javapool;
grant select on v_$javapool to select_catalog_role;

create or replace view gv_$sysaux_occupants as
    select * from gv$sysaux_occupants;
create or replace public synonym gv$sysaux_occupants for gv_$sysaux_occupants;
grant select on gv_$sysaux_occupants to select_catalog_role;

create or replace view v_$sysaux_occupants as
    select * from v$sysaux_occupants;
create or replace public synonym v$sysaux_occupants for v_$sysaux_occupants;
grant select on v_$sysaux_occupants to select_catalog_role;

create or replace view v_$rman_status as select * from v$rman_status;
create or replace public synonym v$rman_status
   for v_$rman_status;
grant select on v_$rman_status to select_catalog_role;

create or replace view v_$rman_output as select * from v$rman_output;
create or replace public synonym v$rman_output
   for v_$rman_output;
grant select on v_$rman_output to select_catalog_role;

create or replace view gv_$rman_output as select * from gv$rman_output;
create or replace public synonym gv$rman_output
   for gv_$rman_output;
grant select on gv_$rman_output to select_catalog_role;

create or replace view v_$recovery_file_dest as select * from
   v$recovery_file_dest;
create or replace public synonym v$recovery_file_dest
   for v_$recovery_file_dest;
grant select on v_$recovery_file_dest to select_catalog_role;

create or replace view v_$flash_recovery_area_usage as select * from
   v$flash_recovery_area_usage;
create or replace public synonym v$flash_recovery_area_usage
   for v_$flash_recovery_area_usage;
grant select on v_$flash_recovery_area_usage to select_catalog_role;

create or replace view v_$block_change_tracking as
    select * from v$block_change_tracking;
create or replace public synonym v$block_change_tracking for
    v_$block_change_tracking;
grant select on v_$block_change_tracking to select_catalog_role;

create or replace view gv_$metric as select * from gv$metric;
create or replace public synonym gv$metric for gv_$metric;
grant select on gv_$metric to select_catalog_role;

create or replace view gv_$metric_history as
          select * from gv$metric_history;
create or replace public synonym gv$metric_history
          for gv_$metric_history;
grant select on gv_$metric_history to select_catalog_role;

create or replace view gv_$sysmetric as select * from gv$sysmetric;
create or replace public synonym gv$sysmetric for gv_$sysmetric;
grant select on gv_$sysmetric to select_catalog_role;

create or replace view gv_$sysmetric_history as
          select * from gv$sysmetric_history;
create or replace public synonym gv$sysmetric_history
          for gv_$sysmetric_history;
grant select on gv_$sysmetric_history to select_catalog_role;

create or replace view gv_$metricname as select * from gv$metricname;
create or replace public synonym gv$metricname for gv_$metricname;
grant select on gv_$metricname to select_catalog_role;

create or replace view gv_$metricgroup as select * from gv$metricgroup;
create or replace public synonym gv$metricgroup for gv_$metricgroup;
grant select on gv_$metricgroup to select_catalog_role;

create or replace view gv_$active_session_history as
    select * from gv$active_session_history;
create or replace public synonym gv$active_session_history
      for gv_$active_session_history;
grant select on gv_$active_session_history to select_catalog_role;

create or replace view v_$active_session_history as
    select * from v$active_session_history;
create or replace public synonym v$active_session_history
      for v_$active_session_history;
grant select on v_$active_session_history to select_catalog_role;


create or replace view gv_$instance_log_group as
    select * from gv$instance_log_group;
create or replace public synonym gv$instance_log_group
      for gv_$instance_log_group;
grant select on gv_$instance_log_group to select_catalog_role;

create or replace view v_$instance_log_group as
    select * from v$instance_log_group;
create or replace public synonym v$instance_log_group
      for v_$instance_log_group;
grant select on v_$instance_log_group to select_catalog_role;

create or replace view gv_$service_wait_class as select * from gv$service_wait_class;
create or replace public synonym gv$service_wait_class for gv_$service_wait_class;
grant select on gv_$service_wait_class to select_catalog_role;

create or replace view gv_$service_event as select * from gv$service_event;
create or replace public synonym gv$service_event for gv_$service_event;
grant select on gv_$service_event to select_catalog_role;

create or replace view gv_$active_services as select * from gv$active_services;
create or replace public synonym gv$active_services for gv_$active_services;
grant select on gv_$active_services to select_catalog_role;

create or replace view gv_$services as select * from gv$services;
create or replace public synonym gv$services for gv_$services;
grant select on gv_$services to select_catalog_role;

create or replace view v_$scheduler_running_jobs as
    select * from v$scheduler_running_jobs;
create or replace public synonym v$scheduler_running_jobs
      for v_$scheduler_running_jobs;
grant select on v_$scheduler_running_jobs to select_catalog_role;

create or replace view gv_$scheduler_running_jobs as
    select * from gv$scheduler_running_jobs;
create or replace public synonym gv$scheduler_running_jobs
      for gv_$scheduler_running_jobs;
grant select on gv_$scheduler_running_jobs to select_catalog_role;

create or replace view gv_$buffered_queues as
    select * from gv$buffered_queues;
create or replace public synonym gv$buffered_queues
    for gv_$buffered_queues;
grant select on gv_$buffered_queues to select_catalog_role;

create or replace view v_$buffered_queues as
    select * from v$buffered_queues;
create or replace public synonym v$buffered_queues
    for v_$buffered_queues;
grant select on v_$buffered_queues to select_catalog_role;

create or replace view gv_$buffered_subscribers as
    select * from gv$buffered_subscribers;
create or replace public synonym gv$buffered_subscribers
    for gv_$buffered_subscribers;
grant select on gv_$buffered_subscribers to select_catalog_role;

create or replace view v_$buffered_subscribers as
    select * from v$buffered_subscribers;
create or replace public synonym v$buffered_subscribers
    for v_$buffered_subscribers;
grant select on v_$buffered_subscribers to select_catalog_role;

create or replace view gv_$buffered_publishers as
    select * from gv$buffered_publishers;
create or replace public synonym gv$buffered_publishers
    for gv_$buffered_publishers;
grant select on gv_$buffered_publishers to select_catalog_role;

create or replace view v_$buffered_publishers as
    select * from v$buffered_publishers;
create or replace public synonym v$buffered_publishers
    for v_$buffered_publishers;
grant select on v_$buffered_publishers to select_catalog_role;

create or replace view gv_$tsm_sessions as
    select * from gv$tsm_sessions;
create or replace public synonym gv$tsm_sessions
    for gv_$tsm_sessions;
grant select on gv_$tsm_sessions to select_catalog_role;

create or replace view v_$tsm_sessions as
    select * from v$tsm_sessions;
create or replace public synonym v$tsm_sessions
    for v_$tsm_sessions;
grant select on v_$tsm_sessions to select_catalog_role;

create or replace view gv_$propagation_sender as
    select * from gv$propagation_sender;
create or replace public synonym gv$propagation_sender
    for gv_$propagation_sender;
grant select on gv_$propagation_sender to select_catalog_role;

create or replace view v_$propagation_sender as
    select * from v$propagation_sender;
create or replace public synonym v$propagation_sender
    for v_$propagation_sender;
grant select on v_$propagation_sender to select_catalog_role;

create or replace view gv_$propagation_receiver as
    select * from gv$propagation_receiver;
create or replace public synonym gv$propagation_receiver
    for gv_$propagation_receiver;
grant select on gv_$propagation_receiver to select_catalog_role;

create or replace view v_$propagation_receiver as
    select * from v$propagation_receiver;
create or replace public synonym v$propagation_receiver
    for v_$propagation_receiver;
grant select on v_$propagation_receiver to select_catalog_role;

remark Dummy XDB views for all_objects
@@catxdbdv


create or replace view gv_$sysmetric_summary as
    select * from gv$sysmetric_summary;
create or replace public synonym gv$sysmetric_summary
    for gv_$sysmetric_summary;
grant select on gv_$sysmetric_summary to select_catalog_role;

create or replace view gv_$sessmetric as select * from gv$sessmetric;
create or replace public synonym gv$sessmetric for gv_$sessmetric;
grant select on gv_$sessmetric to select_catalog_role;

create or replace view gv_$filemetric as select * from gv$filemetric;
create or replace public synonym gv$filemetric for gv_$filemetric;
grant select on gv_$filemetric to select_catalog_role;

create or replace view gv_$filemetric_history as
    select * from gv$filemetric_history;
create or replace public synonym gv$filemetric_history
    for gv_$filemetric_history;
grant select on gv_$filemetric_history to select_catalog_role;

create or replace view gv_$eventmetric as select * from gv$eventmetric;
create or replace public synonym gv$eventmetric for gv_$eventmetric;
grant select on gv_$eventmetric to select_catalog_role;

create or replace view gv_$waitclassmetric as
    select * from gv$waitclassmetric;
create or replace public synonym gv$waitclassmetric for gv_$waitclassmetric;
grant select on gv_$waitclassmetric to select_catalog_role;

create or replace view gv_$waitclassmetric_history as
    select * from gv$waitclassmetric_history;
create or replace public synonym gv$waitclassmetric_history
    for gv_$waitclassmetric_history;
grant select on gv_$waitclassmetric_history to select_catalog_role;

create or replace view gv_$servicemetric as select * from gv$servicemetric;
create or replace public synonym gv$servicemetric for gv_$servicemetric;
grant select on gv_$servicemetric to select_catalog_role;

create or replace view gv_$servicemetric_history
    as select * from gv$servicemetric_history;
create or replace public synonym gv$servicemetric_history
    for gv_$servicemetric_history;
grant select on gv_$servicemetric_history to select_catalog_role;

create or replace view gv_$advisor_progress
    as select * from gv$advisor_progress;
create or replace public synonym gv$advisor_progress
    for gv_$advisor_progress;
grant select on gv_$advisor_progress to select_catalog_role;

create or replace view gv_$xml_audit_trail
    as select * from gv$xml_audit_trail;
create or replace public synonym gv$xml_audit_trail
    for gv_$xml_audit_trail;
grant select on gv_$xml_audit_trail to select_catalog_role;

create or replace view gv_$sql_join_filter
    as select * from gv$sql_join_filter;
create or replace public synonym gv$sql_join_filter
    for gv_$sql_join_filter;
grant select on gv_$sql_join_filter to select_catalog_role;

create or replace view gv_$process_memory as select * from gv$process_memory;
create or replace public synonym gv$process_memory for gv_$process_memory;
grant select on gv_$process_memory to select_catalog_role;

create or replace view gv_$process_memory_detail
    as select * from gv$process_memory_detail;
create or replace public synonym gv$process_memory_detail
    for gv_$process_memory_detail;
grant select on gv_$process_memory_detail to select_catalog_role;

create or replace view gv_$process_memory_detail_prog
    as select * from gv$process_memory_detail_prog;
create or replace public synonym gv$process_memory_detail_prog
    for gv_$process_memory_detail_prog;
grant select on gv_$process_memory_detail_prog to select_catalog_role;

create or replace view gv_$wallet
    as select * from gv$wallet;
create or replace public synonym gv$wallet
    for gv_$wallet;
grant select on gv_$wallet to select_catalog_role;

create or replace view v_$wallet
    as select * from v$wallet;
create or replace public synonym v$wallet
    for v_$wallet;
grant select on v_$wallet to select_catalog_role;

remark
remark  FAMILY "PRIVILEGE MAP"
remark  Tables for mapping privilege numbers to privilege names.
remark
remark  SYSTEM_PRIVILEGE_MAP now in sql.bsq
remark
remark  TABLE_PRIVILEGE_MAP now in sql.bsq
remark
remark
remark  FAMILY "PRIVS"
remark

create or replace view SESSION_PRIVS
    (PRIVILEGE)
as
select spm.name
from sys.v$enabledprivs ep, system_privilege_map spm
where spm.privilege = ep.priv_number
/
comment on table SESSION_PRIVS is
'Privileges which the user currently has set'
/
comment on column SESSION_PRIVS.PRIVILEGE is
'Privilege Name'
/
create or replace public synonym SESSION_PRIVS for SESSION_PRIVS
/
grant select on SESSION_PRIVS to PUBLIC with grant option
/

remark
remark  FAMILY "ROLES"
remark
create or replace view SESSION_ROLES
    (ROLE)
as
select u.name
from x$kzsro,user$ u
where kzsrorol!=userenv('SCHEMAID') and kzsrorol!=1 and u.user#=kzsrorol
/
comment on table SESSION_ROLES is
'Roles which the user currently has enabled.'
/
comment on column SESSION_ROLES.ROLE is
'Role name'
/
create or replace public synonym SESSION_ROLES for SESSION_ROLES
/
grant select on SESSION_ROLES to PUBLIC with grant option
/
create or replace view ROLE_SYS_PRIVS
    (ROLE, PRIVILEGE, ADMIN_OPTION)
as
select u.name,spm.name,decode(min(option$),1,'YES','NO')
from  sys.user$ u, sys.system_privilege_map spm, sys.sysauth$ sa
where grantee# in
   (select distinct(privilege#)
    from sys.sysauth$ sa
    where privilege# > 0
    connect by prior sa.privilege# = sa.grantee#
    start with grantee#=userenv('SCHEMAID') or grantee#=1 or grantee# in
      (select kzdosrol from x$kzdos))
  and u.user#=sa.grantee# and sa.privilege#=spm.privilege
group by u.name, spm.name
/
comment on table ROLE_SYS_PRIVS is
'System privileges granted to roles'
/
comment on column ROLE_SYS_PRIVS.ROLE is
'Role name'
/
comment on column ROLE_SYS_PRIVS.PRIVILEGE is
'System Privilege'
/
comment on column ROLE_SYS_PRIVS.ADMIN_OPTION is
'Grant was with the ADMIN option'
/
create or replace public synonym ROLE_SYS_PRIVS for ROLE_SYS_PRIVS
/
grant select on ROLE_SYS_PRIVS to PUBLIC with grant option
/
create or replace view ROLE_TAB_PRIVS
    (ROLE, OWNER, TABLE_NAME, COLUMN_NAME, PRIVILEGE, GRANTABLE)
as
select u1.name,u2.name,o.name,col$.name,tpm.name,
       decode(max(mod(oa.option$,2)), 1, 'YES', 'NO')
from  sys.user$ u1,sys.user$ u2,sys.table_privilege_map tpm,
      sys.objauth$ oa,sys.obj$ o,sys.col$
where grantee# in
   (select distinct(privilege#)
    from sys.sysauth$ sa
    where privilege# > 0
    connect by prior sa.privilege# = sa.grantee#
    start with grantee#=userenv('SCHEMAID') or grantee#=1 or grantee# in
      (select kzdosrol from x$kzdos))
   and u1.user#=oa.grantee# and oa.privilege#=tpm.privilege
   and oa.obj#=o.obj# and oa.obj#=col$.obj#(+) and oa.col#=col$.col#(+)
   and u2.user#=o.owner#
  and (col$.property IS NULL OR bitand(col$.property, 32) = 0 )
group by u1.name,u2.name,o.name,col$.name,tpm.name
/

comment on table ROLE_TAB_PRIVS is
'Table privileges granted to roles'
/
comment on column ROLE_TAB_PRIVS.ROLE is
'Role Name'
/
comment on column ROLE_TAB_PRIVS.TABLE_NAME is
'Table Name or Sequence Name'
/
comment on column ROLE_TAB_PRIVS.COLUMN_NAME is
'Column Name if applicable'
/
comment on column ROLE_TAB_PRIVS.PRIVILEGE is
'Table Privilege'
/
create or replace public synonym ROLE_TAB_PRIVS for ROLE_TAB_PRIVS
/
grant select on ROLE_TAB_PRIVS to PUBLIC with grant option
/
create or replace view ROLE_ROLE_PRIVS
    (ROLE, GRANTED_ROLE, ADMIN_OPTION)
as
select u1.name,u2.name,decode(min(option$),1,'YES','NO')
from  sys.user$ u1, sys.user$ u2, sys.sysauth$ sa
where grantee# in
   (select distinct(privilege#)
    from sys.sysauth$ sa
    where privilege# > 0
    connect by prior sa.privilege# = sa.grantee#
    start with grantee#=userenv('SCHEMAID') or grantee#=1 or grantee# in
      (select kzdosrol from x$kzdos))
   and u1.user#=sa.grantee# and u2.user#=sa.privilege#
group by u1.name,u2.name
/
comment on table ROLE_ROLE_PRIVS is
'Roles which are granted to roles'
/
comment on column ROLE_ROLE_PRIVS.ROLE is
'Role Name'
/
comment on column ROLE_ROLE_PRIVS.GRANTED_ROLE is
'Role which was granted'
/
comment on column ROLE_ROLE_PRIVS.ADMIN_OPTION is
'Grant was with the ADMIN option'
/
create or replace public synonym ROLE_ROLE_PRIVS for ROLE_ROLE_PRIVS
/
grant select on ROLE_ROLE_PRIVS to PUBLIC with grant option
/
create or replace view DBA_ROLES (ROLE, PASSWORD_REQUIRED)
as
select name, decode(password, null, 'NO', 'EXTERNAL', 'EXTERNAL',
                      'GLOBAL', 'GLOBAL', 'YES')
from  user$
where type# = 0 and name not in ('PUBLIC', '_NEXT_USER')
/
create or replace public synonym DBA_ROLES for DBA_ROLES
/
grant select on DBA_ROLES to select_catalog_role
/
comment on table DBA_ROLES is
'All Roles which exist in the database'
/
comment on column DBA_ROLES.ROLE is
'Role Name'
/
comment on column DBA_ROLES.PASSWORD_REQUIRED is
'Indicates if the role requires a password to be enabled'
/
remark
remark These are table that actually enables the user to see his or her
remark limits
remark
create or replace view DBA_PROFILES
    (PROFILE, RESOURCE_NAME, RESOURCE_TYPE, LIMIT)
as select
   n.name, m.name,
   decode(u.type#, 0, 'KERNEL', 1, 'PASSWORD', 'INVALID'),
   decode(u.limit#,
          0, 'DEFAULT',
          2147483647, decode(u.resource#,
                             4, decode(u.type#,
                                       1, 'NULL', 'UNLIMITED'),
                             'UNLIMITED'),
          decode(u.resource#,
                 4, decode(u.type#, 1, o.name, u.limit#),
                 decode(u.type#,
                        0, u.limit#,
                        decode(u.resource#,
                               1, trunc(u.limit#/86400, 4),
                               2, trunc(u.limit#/86400, 4),
                               5, trunc(u.limit#/86400, 4),
                               6, trunc(u.limit#/86400, 4),
                               u.limit#))))
  from sys.profile$ u, sys.profname$ n, sys.resource_map m, sys.obj$ o
  where u.resource# = m.resource#
  and u.type#=m.type#
  and o.obj# (+) = u.limit#
  and n.profile# = u.profile#
/
create or replace public synonym DBA_PROFILES for DBA_PROFILES
/
grant select on DBA_PROFILES to select_catalog_role
/
comment on table DBA_PROFILES is
'Display all profiles and their limits'
/
comment on column DBA_PROFILES.PROFILE is
'Profile name'
/
comment on column DBA_PROFILES.RESOURCE_NAME is
'Resource name'
/
comment on column DBA_PROFILES.LIMIT is
'Limit placed on this resource for this profile'
/

REM
REM  This view enables the user to see his own profile limits
REM
create or replace view USER_RESOURCE_LIMITS
    (RESOURCE_NAME, LIMIT)
as select m.name,
          decode (u.limit#, 2147483647, 'UNLIMITED',
                           0, decode (p.limit#, 2147483647, 'UNLIMITED',
                                               p.limit#),
                           u.limit#)
  from sys.profile$ u, sys.profile$ p,
       sys.resource_map m, user$ s
  where u.resource# = m.resource#
  and p.profile# = 0
  and p.resource# = u.resource#
  and u.type# = p.type#
  and p.type# = 0
  and m.type# = 0
  and s.resource$ = u.profile#
  and s.user# = userenv('SCHEMAID')
/
comment on table USER_RESOURCE_LIMITS is
'Display resource limit of the user'
/
comment on column USER_RESOURCE_LIMITS.RESOURCE_NAME is
'Resource name'
/
comment on column USER_RESOURCE_LIMITS.LIMIT is
'Limit placed on this resource'
/
create or replace public synonym USER_RESOURCE_LIMITS for USER_RESOURCE_LIMITS
/
grant select on USER_RESOURCE_LIMITS to PUBLIC with grant option
/
create or replace view USER_PASSWORD_LIMITS
    (RESOURCE_NAME, LIMIT)
as select
  m.name,
  decode(u.limit#,
         2147483647, decode(u.resource#, 4, 'NULL', 'UNLIMITED'),
         -1, 0,
         0, decode(p.limit#,
                   2147483647, decode(p.resource#, 4, 'NULL', 'UNLIMITED'),
                   -1, 0,
                   decode(p.resource#,
                          4, po.name,
                          1, trunc(p.limit#/86400, 4),
                          2, trunc(p.limit#/86400, 4),
                          5, trunc(p.limit#/86400, 4),
                          6, trunc(p.limit#/86400, 4), p.limit#)),
         decode(u.resource#,
                4, uo.name,
                1, trunc(u.limit#/86400, 4),
                2, trunc(u.limit#/86400, 4),
                5, trunc(u.limit#/86400, 4),
                6, trunc(u.limit#/86400, 4),
                u.limit#))
  from sys.profile$ u, sys.profile$ p, sys.obj$ uo, sys.obj$ po,
       sys.resource_map m, sys.user$ s
  where u.resource# = m.resource#
  and p.profile# = 0
  and p.resource# = u.resource#
  and u.type# = p.type#
  and p.type# = 1
  and m.type# = 1
  and uo.obj#(+) = u.limit#
  and po.obj#(+) = p.limit#
  and s.resource$ = u.profile#
  and s.user# = userenv('SCHEMAID')
/
comment on table USER_PASSWORD_LIMITS is
'Display password limits of the user'
/
comment on column USER_PASSWORD_LIMITS.RESOURCE_NAME is
'Resource name'
/
comment on column USER_PASSWORD_LIMITS.LIMIT is
'Limit placed on this resource'
/
create or replace public synonym USER_PASSWORD_LIMITS for USER_PASSWORD_LIMITS
/
grant select on USER_PASSWORD_LIMITS to PUBLIC with grant option
/
REM
REM  This view shows the resource cost of the system
REM
create or replace view RESOURCE_COST
    (RESOURCE_NAME, UNIT_COST)
as select m.name,c.cost
  from sys.resource_cost$ c, sys.resource_map m where
  c.resource# = m.resource#
  and m.type# = 0
  and c.resource# in (2, 4, 7, 8)
/
comment on table RESOURCE_COST is
'Cost for each resource'
/
comment on column RESOURCE_COST.RESOURCE_NAME is
'Name of resource'
/
comment on column RESOURCE_COST.UNIT_COST is
'Cost for resource'
/
create or replace public synonym RESOURCE_COST for RESOURCE_COST
/
grant select on RESOURCE_COST to PUBLIC
/

remark
remark  FAMILY "CATALOG"
remark  Objects which may be used as tables in SQL statements:
remark  Tables, Views, Synonyms.
remark

create or replace view USER_CATALOG
    (TABLE_NAME,
     TABLE_TYPE)
as
select o.name,
       decode(o.type#, 0, 'NEXT OBJECT', 1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER',
                      4, 'VIEW', 5, 'SYNONYM', 6, 'SEQUENCE', 'UNDEFINED')
from sys.obj$ o
where o.owner# = userenv('SCHEMAID')
  and ((o.type# in (4, 5, 6))
       or
       (o.type# = 2     /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192))))
  and o.linkname is null
/
comment on table USER_CATALOG is
'Tables, Views, Synonyms and Sequences owned by the user'
/
comment on column USER_CATALOG.TABLE_NAME is
'Name of the object'
/
comment on column USER_CATALOG.TABLE_TYPE is
'Type of the object'
/
create or replace public synonym USER_CATALOG for USER_CATALOG
/
create or replace public synonym CAT for USER_CATALOG
/
grant select on USER_CATALOG to PUBLIC with grant option
/
remark
remark  This view shows all tables, views, synonyms, and sequences owned by the
remark  user and those tables, views, synonyms, and sequences that PUBLIC
remark  has been granted access.
remark
create or replace view ALL_CATALOG
    (OWNER, TABLE_NAME,
     TABLE_TYPE)
as
select u.name, o.name,
       decode(o.type#, 0, 'NEXT OBJECT', 1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER',
                      4, 'VIEW', 5, 'SYNONYM', 6, 'SEQUENCE', 'UNDEFINED')
from sys.user$ u, sys.obj$ o
where o.owner# = u.user#
  and ((o.type# in (4, 5, 6))
       or
       (o.type# = 2     /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192))))
  and o.linkname is null
  and (o.owner# in (userenv('SCHEMAID'), 1)   /* public objects */
       or
       obj# in ( select obj#  /* directly granted privileges */
                 from sys.objauth$
                 where grantee# in ( select kzsrorol
                                      from x$kzsro
                                    )
                )
       or
       (
          o.type# in (2, 4, 5) /* table, view, synonym */
          and
          exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */))
       )
       or
       ( o.type# = 6 /* sequence */
         and
         exists (select null from v$enabledprivs
                 where priv_number = -109 /* SELECT ANY SEQUENCE */)))
/
comment on table ALL_CATALOG is
'All tables, views, synonyms, sequences accessible to the user'
/
comment on column ALL_CATALOG.OWNER is
'Owner of the object'
/
comment on column ALL_CATALOG.TABLE_NAME is
'Name of the object'
/
comment on column ALL_CATALOG.TABLE_TYPE is
'Type of the object'
/
create or replace public synonym ALL_CATALOG for ALL_CATALOG
/
grant select on ALL_CATALOG to PUBLIC with grant option
/
create or replace view DBA_CATALOG
    (OWNER, TABLE_NAME,
     TABLE_TYPE)
as
select u.name, o.name,
       decode(o.type#, 0, 'NEXT OBJECT', 1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER',
                      4, 'VIEW', 5, 'SYNONYM', 6, 'SEQUENCE', 'UNDEFINED')
from sys.user$ u, sys.obj$ o
where o.owner# = u.user#
  and o.linkname is null
  and ((o.type# in (4, 5, 6))
       or
       (o.type# = 2     /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192))))
/
create or replace public synonym DBA_CATALOG for DBA_CATALOG
/
grant select on DBA_CATALOG to select_catalog_role
/
comment on table DBA_CATALOG is
'All database Tables, Views, Synonyms, Sequences'
/
comment on column DBA_CATALOG.OWNER is
'Owner of the object'
/
comment on column DBA_CATALOG.TABLE_NAME is
'Name of the object'
/
comment on column DBA_CATALOG.TABLE_TYPE is
'Type of the object'
/
remark
remark  FAMILY "CLUSTERS"
remark  CREATE CLUSTER parameters.
remark
create or replace view USER_CLUSTERS
    (CLUSTER_NAME, TABLESPACE_NAME,
     PCT_FREE, PCT_USED, KEY_SIZE,
     INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS,
     AVG_BLOCKS_PER_KEY,
     CLUSTER_TYPE, FUNCTION, HASHKEYS,
     DEGREE, INSTANCES, CACHE, BUFFER_POOL, SINGLE_TABLE, DEPENDENCIES)
as select o.name, ts.name,
          mod(c.pctfree$, 100),
          decode(bitand(ts.flags, 32), 32, to_number(NULL), c.pctused$),
          c.size$,c.initrans,c.maxtrans,
          s.iniexts * ts.blocksize,
          decode(bitand(ts.flags, 3), 1, to_number(NULL),
                               s.extsize * ts.blocksize),
          s.minexts, s.maxexts,
          decode(bitand(ts.flags, 3), 1, to_number(NULL),
                                      s.extpct),
          decode(bitand(ts.flags, 32), 32, to_number(NULL),
             decode(s.lists, 0, 1, s.lists)),
          decode(bitand(ts.flags, 32), 32, to_number(NULL),
             decode(s.groups, 0, 1, s.groups)),
          c.avgchn, decode(c.hashkeys, 0, 'INDEX', 'HASH'),
          decode(c.hashkeys, 0, NULL,
                 decode(c.func, 0, 'COLUMN', 1, 'DEFAULT',
                                2, 'HASH EXPRESSION', 3, 'DEFAULT2', NULL)),
          c.hashkeys,
          lpad(decode(c.degree, 32767, 'DEFAULT', nvl(c.degree,1)),10),
          lpad(decode(c.instances, 32767, 'DEFAULT', nvl(c.instances,1)),10),
          lpad(decode(bitand(c.flags, 8), 8, 'Y', 'N'), 5),
          decode(s.cachehint, 0, 'DEFAULT', 1, 'KEEP', 2, 'RECYCLE', NULL),
          lpad(decode(bitand(c.flags, 65536), 65536, 'Y', 'N'), 5),
          decode(bitand(c.flags, 8388608), 8388608, 'ENABLED', 'DISABLED')
from sys.ts$ ts, sys.seg$ s, sys.clu$ c, sys.obj$ o
where o.owner# = userenv('SCHEMAID')
  and o.obj# = c.obj#
  and c.ts# = ts.ts#
  and c.ts# = s.ts#
  and c.file# = s.file#
  and c.block# = s.block#
/
comment on table USER_CLUSTERS is
'Descriptions of user''s own clusters'
/
comment on column USER_CLUSTERS.CLUSTER_NAME is
'Name of the cluster'
/
comment on column USER_CLUSTERS.TABLESPACE_NAME is
'Name of the tablespace containing the cluster'
/
comment on column USER_CLUSTERS.PCT_FREE is
'Minimum percentage of free space in a block'
/
comment on column USER_CLUSTERS.PCT_USED is
'Minimum percentage of used space in a block'
/
comment on column USER_CLUSTERS.KEY_SIZE is
'Estimated size of cluster key plus associated rows'
/
comment on column USER_CLUSTERS.INI_TRANS is
'Initial number of transactions'
/
comment on column USER_CLUSTERS.MAX_TRANS is
'Maximum number of transactions'
/
comment on column USER_CLUSTERS.INITIAL_EXTENT is
'Size of the initial extent in bytes'
/
comment on column USER_CLUSTERS.NEXT_EXTENT is
'Size of secondary extents in bytes'
/
comment on column USER_CLUSTERS.MIN_EXTENTS is
'Minimum number of extents allowed in the segment'
/
comment on column USER_CLUSTERS.MAX_EXTENTS is
'Maximum number of extents allowed in the segment'
/
comment on column USER_CLUSTERS.PCT_INCREASE is
'Percentage increase in extent size'
/
comment on column USER_CLUSTERS.FREELISTS is
'Number of process freelists allocated in this segment'
/
comment on column USER_CLUSTERS.FREELIST_GROUPS is
'Number of freelist groups allocated in this segment'
/
comment on column USER_CLUSTERS.AVG_BLOCKS_PER_KEY is
'Average number of blocks containing rows with a given cluster key'
/
comment on column USER_CLUSTERS.CLUSTER_TYPE is
'Type of cluster: b-tree index or hash'
/
comment on column USER_CLUSTERS.FUNCTION is
'If a hash cluster, the hash function'
/
comment on column USER_CLUSTERS.HASHKEYS is
'If a hash cluster, the number of hash keys (hash buckets)'
/
comment on column USER_CLUSTERS.DEGREE is
'The number of threads per instance for scanning the cluster'
/
comment on column USER_CLUSTERS.INSTANCES is
'The number of instances across which the cluster is to be scanned'
/
comment on column USER_CLUSTERS.CACHE is
'Whether the cluster is to be cached in the buffer cache'
/
comment on column USER_CLUSTERS.BUFFER_POOL is
'The default buffer pool to be used for cluster blocks'
/
comment on column USER_CLUSTERS.SINGLE_TABLE is
'Whether the cluster can contain only a single table'
/
comment on column USER_CLUSTERS.DEPENDENCIES is
'Should we keep track of row level dependencies?'
/
create or replace public synonym USER_CLUSTERS for USER_CLUSTERS
/
create or replace public synonym CLU for USER_CLUSTERS
/
grant select on USER_CLUSTERS to PUBLIC with grant option
/
create or replace view ALL_CLUSTERS
    (OWNER, CLUSTER_NAME, TABLESPACE_NAME,
     PCT_FREE, PCT_USED, KEY_SIZE,
     INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS,
     AVG_BLOCKS_PER_KEY,
     CLUSTER_TYPE, FUNCTION, HASHKEYS,
     DEGREE, INSTANCES, CACHE, BUFFER_POOL, SINGLE_TABLE, DEPENDENCIES)
as select u.name, o.name, ts.name,
          mod(c.pctfree$, 100),
          decode(bitand(ts.flags, 32), 32, to_number(NULL), c.pctused$),
          c.size$,c.initrans,c.maxtrans,
          s.iniexts * ts.blocksize,
          decode(bitand(ts.flags, 3), 1, to_number(NULL),
                               s.extsize * ts.blocksize),
          s.minexts, s.maxexts,
          decode(bitand(ts.flags, 3), 1, to_number(NULL),
                                      s.extpct),
          decode(bitand(ts.flags, 32), 32, to_number(NULL),
           decode(s.lists, 0, 1, s.lists)),
          decode(bitand(ts.flags, 32), 32, to_number(NULL),
           decode(s.groups, 0, 1, s.groups)),
          c.avgchn, decode(c.hashkeys, 0, 'INDEX', 'HASH'),
          decode(c.hashkeys, 0, NULL,
                 decode(c.func, 0, 'COLUMN', 1, 'DEFAULT',
                                2, 'HASH EXPRESSION', 3, 'DEFAULT2', NULL)),
          c.hashkeys,
          lpad(decode(c.degree, 32767, 'DEFAULT', nvl(c.degree,1)),10),
          lpad(decode(c.instances, 32767, 'DEFAULT', nvl(c.instances,1)),10),
          lpad(decode(bitand(c.flags, 8), 8, 'Y', 'N'), 5),
          decode(s.cachehint, 0, 'DEFAULT', 1, 'KEEP', 2, 'RECYCLE', NULL),
          lpad(decode(bitand(c.flags, 65536), 65536, 'Y', 'N'), 5),
          decode(bitand(c.flags, 8388608), 8388608, 'ENABLED', 'DISABLED')
from sys.user$ u, sys.ts$ ts, sys.seg$ s, sys.clu$ c, sys.obj$ o
where o.owner# = u.user#
  and o.obj#   = c.obj#
  and c.ts#    = ts.ts#
  and c.ts#    = s.ts#
  and c.file#  = s.file#
  and c.block# = s.block#
  and (o.owner# = userenv('SCHEMAID')
       or  /* user has system privilages */
         exists (select null from v$enabledprivs
                 where priv_number in (-61 /* CREATE ANY CLUSTER */,
                                       -62 /* ALTER ANY CLUSTER */,
                                       -63 /* DROP ANY CLUSTER */ )
                )
      )
/
create or replace public synonym ALL_CLUSTERS for ALL_CLUSTERS
/
grant select on ALL_CLUSTERS to PUBLIC with grant option
/
comment on table ALL_CLUSTERS is
'Description of clusters accessible to the user'
/
comment on column ALL_CLUSTERS.OWNER is
'Owner of the cluster'
/
comment on column ALL_CLUSTERS.CLUSTER_NAME is
'Name of the cluster'
/
comment on column ALL_CLUSTERS.TABLESPACE_NAME is
'Name of the tablespace containing the cluster'
/
comment on column ALL_CLUSTERS.PCT_FREE is
'Minimum percentage of free space in a block'
/
comment on column ALL_CLUSTERS.PCT_USED is
'Minimum percentage of used space in a block'
/
comment on column ALL_CLUSTERS.KEY_SIZE is
'Estimated size of cluster key plus associated rows'
/
comment on column ALL_CLUSTERS.INI_TRANS is
'Initial number of transactions'
/
comment on column ALL_CLUSTERS.MAX_TRANS is
'Maximum number of transactions'
/
comment on column ALL_CLUSTERS.INITIAL_EXTENT is
'Size of the initial extent in bytes'
/
comment on column ALL_CLUSTERS.NEXT_EXTENT is
'Size of secondary extents in bytes'
/
comment on column ALL_CLUSTERS.MIN_EXTENTS is
'Minimum number of extents allowed in the segment'
/
comment on column ALL_CLUSTERS.MAX_EXTENTS is
'Maximum number of extents allowed in the segment'
/
comment on column ALL_CLUSTERS.PCT_INCREASE is
'Percentage increase in extent size'
/
comment on column ALL_CLUSTERS.FREELISTS is
'Number of process freelists allocated in this segment'
/
comment on column ALL_CLUSTERS.FREELIST_GROUPS is
'Number of freelist groups allocated in this segment'
/
comment on column ALL_CLUSTERS.AVG_BLOCKS_PER_KEY is
'Average number of blocks containing rows with a given cluster key'
/
comment on column ALL_CLUSTERS.CLUSTER_TYPE is
'Type of cluster: b-tree index or hash'
/
comment on column ALL_CLUSTERS.FUNCTION is
'If a hash cluster, the hash function'
/
comment on column ALL_CLUSTERS.HASHKEYS is
'If a hash cluster, the number of hash keys (hash buckets)'
/
comment on column ALL_CLUSTERS.DEGREE is
'The number of threads per instance for scanning the cluster'
/
comment on column ALL_CLUSTERS.INSTANCES is
'The number of instances across which the cluster is to be scanned'
/
comment on column ALL_CLUSTERS.CACHE is
'Whether the cluster is to be cached in the buffer cache'
/
comment on column ALL_CLUSTERS.BUFFER_POOL is
'The default buffer pool to be used for cluster blocks'
/
comment on column ALL_CLUSTERS.SINGLE_TABLE is
'Whether the cluster can contain only a single table'
/
comment on column ALL_CLUSTERS.DEPENDENCIES is
'Should we keep track of row level dependencies?'
/
create or replace view DBA_CLUSTERS
    (OWNER, CLUSTER_NAME, TABLESPACE_NAME,
     PCT_FREE, PCT_USED, KEY_SIZE,
     INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS,
     AVG_BLOCKS_PER_KEY,
     CLUSTER_TYPE, FUNCTION, HASHKEYS,
     DEGREE, INSTANCES, CACHE, BUFFER_POOL, SINGLE_TABLE, DEPENDENCIES)
as select u.name, o.name, ts.name,
          mod(c.pctfree$, 100),
          decode(bitand(ts.flags, 32), 32, to_number(NULL), c.pctused$),
          c.size$,c.initrans,c.maxtrans,
          s.iniexts * ts.blocksize,
          decode(bitand(ts.flags, 3), 1, to_number(NULL),
                               s.extsize * ts.blocksize),
          s.minexts, s.maxexts,
          decode(bitand(ts.flags, 3), 1, to_number(NULL),
                                      s.extpct),
          decode(bitand(ts.flags, 32), 32, to_number(NULL),
            decode(s.lists, 0, 1, s.lists)),
          decode(bitand(ts.flags, 32), 32, to_number(NULL),
            decode(s.groups, 0, 1, s.groups)),
          c.avgchn, decode(c.hashkeys, 0, 'INDEX', 'HASH'),
          decode(c.hashkeys, 0, NULL,
                 decode(c.func, 0, 'COLUMN', 1, 'DEFAULT',
                                2, 'HASH EXPRESSION', 3, 'DEFAULT2', NULL)),
          c.hashkeys,
          lpad(decode(c.degree, 32767, 'DEFAULT', nvl(c.degree,1)),10),
          lpad(decode(c.instances, 32767, 'DEFAULT', nvl(c.instances,1)),10),
          lpad(decode(bitand(c.flags, 8), 8, 'Y', 'N'), 5),
          decode(s.cachehint, 0, 'DEFAULT', 1, 'KEEP', 2, 'RECYCLE', NULL),
          lpad(decode(bitand(c.flags, 65536), 65536, 'Y', 'N'), 5),
          decode(bitand(c.flags, 8388608), 8388608, 'ENABLED', 'DISABLED')
from sys.user$ u, sys.ts$ ts, sys.seg$ s, sys.clu$ c, sys.obj$ o
where o.owner# = u.user#
  and o.obj# = c.obj#
  and c.ts# = ts.ts#
  and c.ts# = s.ts#
  and c.file# = s.file#
  and c.block# = s.block#
/
create or replace public synonym DBA_CLUSTERS for DBA_CLUSTERS
/
grant select on DBA_CLUSTERS to select_catalog_role
/
comment on table DBA_CLUSTERS is
'Description of all clusters in the database'
/
comment on column DBA_CLUSTERS.OWNER is
'Owner of the cluster'
/
comment on column DBA_CLUSTERS.CLUSTER_NAME is
'Name of the cluster'
/
comment on column DBA_CLUSTERS.TABLESPACE_NAME is
'Name of the tablespace containing the cluster'
/
comment on column DBA_CLUSTERS.PCT_FREE is
'Minimum percentage of free space in a block'
/
comment on column DBA_CLUSTERS.PCT_USED is
'Minimum percentage of used space in a block'
/
comment on column DBA_CLUSTERS.KEY_SIZE is
'Estimated size of cluster key plus associated rows'
/
comment on column DBA_CLUSTERS.INI_TRANS is
'Initial number of transactions'
/
comment on column DBA_CLUSTERS.MAX_TRANS is
'Maximum number of transactions'
/
comment on column DBA_CLUSTERS.INITIAL_EXTENT is
'Size of the initial extent in bytes'
/
comment on column DBA_CLUSTERS.NEXT_EXTENT is
'Size of secondary extents in bytes'
/
comment on column DBA_CLUSTERS.MIN_EXTENTS is
'Minimum number of extents allowed in the segment'
/
comment on column DBA_CLUSTERS.MAX_EXTENTS is
'Maximum number of extents allowed in the segment'
/
comment on column DBA_CLUSTERS.PCT_INCREASE is
'Percentage increase in extent size'
/
comment on column DBA_CLUSTERS.FREELISTS is
'Number of process freelists allocated in this segment'
/
comment on column DBA_CLUSTERS.FREELIST_GROUPS is
'Number of freelist groups allocated in this segment'
/
comment on column DBA_CLUSTERS.AVG_BLOCKS_PER_KEY is
'Average number of blocks containing rows with a given cluster key'
/
comment on column DBA_CLUSTERS.CLUSTER_TYPE is
'Type of cluster: b-tree index or hash'
/
comment on column DBA_CLUSTERS.FUNCTION is
'If a hash cluster, the hash function'
/
comment on column DBA_CLUSTERS.HASHKEYS is
'If a hash cluster, the number of hash keys (hash buckets)'
/
comment on column DBA_CLUSTERS.DEGREE is
'The number of threads per instance for scanning the cluster'
/
comment on column DBA_CLUSTERS.INSTANCES is
'The number of instances across which the cluster is to be scanned'
/
comment on column DBA_CLUSTERS.CACHE is
'Whether the cluster is to be cached in the buffer cache'
/
comment on column DBA_CLUSTERS.BUFFER_POOL is
'The default buffer pool to be used for cluster blocks'
/
comment on column DBA_CLUSTERS.SINGLE_TABLE is
'Whether the cluster can contain only a single table'
/
comment on column DBA_CLUSTERS.DEPENDENCIES is
'Should we keep track of row level dependencies?'
/

remark
remark  FAMILY "CLU_COLUMNS"
remark  Mapping of cluster columns to table columns.
remark  This family has no ALL member.
remark
create or replace view USER_CLU_COLUMNS
    (CLUSTER_NAME, CLU_COLUMN_NAME, TABLE_NAME, TAB_COLUMN_NAME)
as
select oc.name, cc.name, ot.name,
       decode(bitand(tc.property, 1), 1, ac.name, tc.name)
from sys.obj$ oc, sys.col$ cc, sys.obj$ ot, sys.col$ tc, sys.tab$ t,
     sys.attrcol$ ac
where oc.obj#    = cc.obj#
  and t.bobj#    = oc.obj#
  and t.obj#     = tc.obj#
  and tc.segcol# = cc.segcol#
  and t.obj#     = ot.obj#
  and oc.type#   = 3
  and oc.owner#  = userenv('SCHEMAID')
  and tc.obj#    = ac.obj#(+)
  and tc.intcol# = ac.intcol#(+)
/
comment on table USER_CLU_COLUMNS is
'Mapping of table columns to cluster columns'
/
comment on column USER_CLU_COLUMNS.CLUSTER_NAME is
'Cluster name'
/
comment on column USER_CLU_COLUMNS.CLU_COLUMN_NAME is
'Key column in the cluster'
/
comment on column USER_CLU_COLUMNS.TABLE_NAME is
'Clustered table name'
/
comment on column USER_CLU_COLUMNS.TAB_COLUMN_NAME is
'Key column or attribute of object column in the table'
/
create or replace public synonym USER_CLU_COLUMNS for USER_CLU_COLUMNS
/
grant select on USER_CLU_COLUMNS to PUBLIC with grant option
/
create or replace view DBA_CLU_COLUMNS
    (OWNER, CLUSTER_NAME, CLU_COLUMN_NAME, TABLE_NAME, TAB_COLUMN_NAME)
as
select u.name, oc.name, cc.name, ot.name,
       decode(bitand(tc.property, 1), 1, ac.name, tc.name)
from sys.user$ u, sys.obj$ oc, sys.col$ cc, sys.obj$ ot, sys.col$ tc,
     sys.tab$ t, sys.attrcol$ ac
where oc.owner#  = u.user#
  and oc.obj#    = cc.obj#
  and t.bobj#    = oc.obj#
  and t.obj#     = tc.obj#
  and tc.segcol# = cc.segcol#
  and t.obj#     = ot.obj#
  and oc.type#   = 3
  and tc.obj#    = ac.obj#(+)
  and tc.intcol# = ac.intcol#(+)
/
create or replace public synonym DBA_CLU_COLUMNS for DBA_CLU_COLUMNS
/
grant select on DBA_CLU_COLUMNS to select_catalog_role
/
comment on table DBA_CLU_COLUMNS is
'Mapping of table columns to cluster columns'
/
comment on column DBA_CLU_COLUMNS.OWNER is
'Owner of the cluster'
/
comment on column DBA_CLU_COLUMNS.CLUSTER_NAME is
'Cluster name'
/
comment on column DBA_CLU_COLUMNS.CLU_COLUMN_NAME is
'Key column in the cluster'
/
comment on column DBA_CLU_COLUMNS.TABLE_NAME is
'Clustered table name'
/
comment on column DBA_CLU_COLUMNS.TAB_COLUMN_NAME is
'Key column or attribute of object column in the table'
/
remark
remark  FAMILY "COL_COMMENTS"
remark  Comments on columns of tables and views.
remark
create or replace view USER_COL_COMMENTS
    (TABLE_NAME, COLUMN_NAME, COMMENTS)
as
select o.name, c.name, co.comment$
from sys.obj$ o, sys.col$ c, sys.com$ co
where o.owner# = userenv('SCHEMAID')
  and o.type# in (2, 4)
  and o.obj# = c.obj#
  and c.obj# = co.obj#(+)
  and c.intcol# = co.col#(+)
  and bitand(c.property, 32) = 0 /* not hidden column */
/
comment on table USER_COL_COMMENTS is
'Comments on columns of user''s tables and views'
/
comment on column USER_COL_COMMENTS.TABLE_NAME is
'Object name'
/
comment on column USER_COL_COMMENTS.COLUMN_NAME is
'Column name'
/
comment on column USER_COL_COMMENTS.COMMENTS is
'Comment on the column'
/
create or replace public synonym USER_COL_COMMENTS for USER_COL_COMMENTS
/
grant select on USER_COL_COMMENTS to PUBLIC with grant option
/
create or replace view ALL_COL_COMMENTS
    (OWNER, TABLE_NAME, COLUMN_NAME, COMMENTS)
as
select u.name, o.name, c.name, co.comment$
from sys.obj$ o, sys.col$ c, sys.user$ u, sys.com$ co
where o.owner# = u.user#
  and o.type# in (2, 4, 5)
  and o.obj# = c.obj#
  and c.obj# = co.obj#(+)
  and c.intcol# = co.col#(+)
  and bitand(c.property, 32) = 0 /* not hidden column */
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
         (select obj#
          from sys.objauth$
          where grantee# in ( select kzsrorol
                              from x$kzsro
                            )
          )
       or
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */))
      )
/
comment on table ALL_COL_COMMENTS is
'Comments on columns of accessible tables and views'
/
comment on column ALL_COL_COMMENTS.OWNER is
'Owner of the object'
/
comment on column ALL_COL_COMMENTS.TABLE_NAME is
'Name of the object'
/
comment on column ALL_COL_COMMENTS.COLUMN_NAME is
'Name of the column'
/
comment on column ALL_COL_COMMENTS.COMMENTS is
'Comment on the column'
/
create or replace public synonym ALL_COL_COMMENTS for ALL_COL_COMMENTS
/
grant select on ALL_COL_COMMENTS to PUBLIC with grant option
/
create or replace view DBA_COL_COMMENTS
    (OWNER, TABLE_NAME, COLUMN_NAME, COMMENTS)
as
select u.name, o.name, c.name, co.comment$
from sys.obj$ o, sys.col$ c, sys.user$ u, sys.com$ co
where o.owner# = u.user#
  and o.type# in (2, 4)
  and o.obj# = c.obj#
  and c.obj# = co.obj#(+)
  and c.intcol# = co.col#(+)
  and bitand(c.property, 32) = 0 /* not hidden column */
/
create or replace public synonym DBA_COL_COMMENTS for DBA_COL_COMMENTS
/
grant select on DBA_COL_COMMENTS to select_catalog_role
/
comment on table DBA_COL_COMMENTS is
'Comments on columns of all tables and views'
/
comment on column DBA_COL_COMMENTS.OWNER is
'Name of the owner of the object'
/
comment on column DBA_COL_COMMENTS.TABLE_NAME is
'Name of the object'
/
comment on column DBA_COL_COMMENTS.COLUMN_NAME is
'Name of the column'
/
comment on column DBA_COL_COMMENTS.COMMENTS is
'Comment on the object'
/
remark
remark  FAMILY "COL_PRIVS"
remark  Grants on columns.
remark
create or replace view USER_COL_PRIVS
      (GRANTEE, OWNER, TABLE_NAME, COLUMN_NAME, GRANTOR, PRIVILEGE, GRANTABLE)
as
select ue.name, u.name, o.name, c.name, ur.name, tpm.name,
       decode(mod(oa.option$,2), 1, 'YES', 'NO')
from sys.objauth$ oa, sys.obj$ o, sys.user$ u, sys.user$ ur, sys.user$ ue,
     sys.col$ c, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and u.user# = o.owner#
  and oa.obj# = c.obj#
  and oa.col# = c.col#
  and bitand(c.property, 32) = 0 /* not hidden column */
  and oa.col# is not null
  and oa.privilege# = tpm.privilege
  and userenv('SCHEMAID') in (oa.grantor#, oa.grantee#, o.owner#)
/
comment on table USER_COL_PRIVS is
'Grants on columns for which the user is the owner, grantor or grantee'
/
comment on column USER_COL_PRIVS.GRANTEE is
'Name of the user to whom access was granted'
/
comment on column USER_COL_PRIVS.OWNER is
'Username of the owner of the object'
/
comment on column USER_COL_PRIVS.TABLE_NAME is
'Name of the object'
/
comment on column USER_COL_PRIVS.COLUMN_NAME is
'Name of the column'
/
comment on column USER_COL_PRIVS.GRANTOR is
'Name of the user who performed the grant'
/
comment on column USER_COL_PRIVS.PRIVILEGE is
'Column Privilege'
/
comment on column USER_COL_PRIVS.GRANTABLE is
'Privilege is grantable'
/
create or replace public synonym USER_COL_PRIVS for USER_COL_PRIVS
/
grant select on USER_COL_PRIVS to PUBLIC with grant option
/
create or replace view ALL_COL_PRIVS
      (GRANTOR, GRANTEE, TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME,
       PRIVILEGE, GRANTABLE)
as
select ur.name, ue.name, u.name, o.name, c.name, tpm.name,
       decode(mod(oa.option$,2), 1, 'YES', 'NO')
from sys.objauth$ oa, sys.obj$ o, sys.user$ u, sys.user$ ur, sys.user$ ue,
     sys.col$ c, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and u.user# = o.owner#
  and oa.obj# = c.obj#
  and oa.col# = c.col#
  and bitand(c.property, 32) = 0 /* not hidden column */
  and oa.col# is not null
  and oa.privilege# = tpm.privilege
  and (oa.grantor# = userenv('SCHEMAID') or
       oa.grantee# in (select kzsrorol from x$kzsro) or
       o.owner# = userenv('SCHEMAID'))
/
comment on table ALL_COL_PRIVS is
'Grants on columns for which the user is the grantor, grantee, owner,
 or an enabled role or PUBLIC is the grantee'
/
comment on column ALL_COL_PRIVS.GRANTOR is
'Name of the user who performed the grant'
/
comment on column ALL_COL_PRIVS.GRANTEE is
'Name of the user to whom access was granted'
/
comment on column ALL_COL_PRIVS.TABLE_SCHEMA is
'Schema of the object'
/
comment on column ALL_COL_PRIVS.TABLE_NAME is
'Name of the object'
/
comment on column ALL_COL_PRIVS.COLUMN_NAME is
'Name of the column'
/
comment on column ALL_COL_PRIVS.PRIVILEGE is
'Column Privilege'
/
comment on column ALL_COL_PRIVS.GRANTABLE is
'Privilege is grantable'
/
create or replace public synonym ALL_COL_PRIVS for ALL_COL_PRIVS
/
grant select on ALL_COL_PRIVS to PUBLIC with grant option
/
create or replace view DBA_COL_PRIVS
      (GRANTEE, OWNER, TABLE_NAME, COLUMN_NAME, GRANTOR, PRIVILEGE, GRANTABLE)
as
select ue.name, u.name, o.name, c.name, ur.name, tpm.name,
       decode(mod(oa.option$,2), 1, 'YES', 'NO')
from sys.objauth$ oa, sys.obj$ o, sys.user$ u, sys.user$ ur, sys.user$ ue,
     sys.col$ c, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and oa.obj# = c.obj#
  and oa.col# = c.col#
  and bitand(c.property, 32) = 0 /* not hidden column */
  and oa.col# is not null
  and oa.privilege# = tpm.privilege
  and u.user# = o.owner#
/
create or replace public synonym DBA_COL_PRIVS for DBA_COL_PRIVS
/
grant select on DBA_COL_PRIVS to select_catalog_role
/
comment on table DBA_COL_PRIVS is
'All grants on columns in the database'
/
comment on column DBA_COL_PRIVS.GRANTEE is
'Name of the user to whom access was granted'
/
comment on column DBA_COL_PRIVS.OWNER is
'Username of the owner of the object'
/
comment on column DBA_COL_PRIVS.TABLE_NAME is
'Name of the object'
/
comment on column DBA_COL_PRIVS.COLUMN_NAME is
'Name of the column'
/
comment on column DBA_COL_PRIVS.GRANTOR is
'Name of the user who performed the grant'
/
comment on column DBA_COL_PRIVS.PRIVILEGE is
'Column Privilege'
/
comment on column DBA_COL_PRIVS.GRANTABLE is
'Privilege is grantable'
/
remark
remark  FAMILY "COL_PRIVS_MADE"
remark  Grants on columns made by the user.
remark  This family has no DBA member.
remark
create or replace view USER_COL_PRIVS_MADE
      (GRANTEE, TABLE_NAME, COLUMN_NAME, GRANTOR, PRIVILEGE, GRANTABLE)
as
select ue.name, o.name, c.name, ur.name, tpm.name,
       decode(mod(oa.option$,2), 1, 'YES', 'NO')
from sys.objauth$ oa, sys.obj$ o, sys.user$ ue, sys.user$ ur,
     sys.col$ c, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and oa.obj# = c.obj#
  and oa.col# = c.col#
  and bitand(c.property, 32) = 0 /* not hidden column */
  and oa.col# is not null
  and oa.privilege# = tpm.privilege
  and o.owner# = userenv('SCHEMAID')
/
comment on table USER_COL_PRIVS_MADE is
'All grants on columns of objects owned by the user'
/
comment on column USER_COL_PRIVS_MADE.GRANTEE is
'Name of the user to whom access was granted'
/
comment on column USER_COL_PRIVS_MADE.TABLE_NAME is
'Name of the object'
/
comment on column USER_COL_PRIVS_MADE.COLUMN_NAME is
'Name of the column'
/
comment on column USER_COL_PRIVS_MADE.GRANTOR is
'Name of the user who performed the grant'
/
comment on column USER_COL_PRIVS_MADE.PRIVILEGE is
'Column Privilege'
/
comment on column USER_COL_PRIVS_MADE.GRANTABLE is
'Privilege is grantable'
/
create or replace public synonym USER_COL_PRIVS_MADE for USER_COL_PRIVS_MADE
/
grant select on USER_COL_PRIVS_MADE to PUBLIC with grant option
/
create or replace view ALL_COL_PRIVS_MADE
      (GRANTEE, OWNER, TABLE_NAME, COLUMN_NAME, GRANTOR, PRIVILEGE, GRANTABLE)
as
select ue.name, u.name, o.name, c.name, ur.name, tpm.name,
       decode(mod(oa.option$,2), 1, 'YES', 'NO')
from sys.objauth$ oa, sys.obj$ o, sys.user$ u, sys.user$ ur, sys.user$ ue,
     sys.col$ c, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and u.user# = o.owner#
  and oa.obj# = c.obj#
  and oa.col# = c.col#
  and bitand(c.property, 32) = 0 /* not hidden column */
  and oa.col# is not null
  and oa.privilege# = tpm.privilege
  and userenv('SCHEMAID') in (o.owner#, oa.grantor#)
/
comment on table ALL_COL_PRIVS_MADE is
'Grants on columns for which the user is owner or grantor'
/
comment on column ALL_COL_PRIVS_MADE.GRANTEE is
'Name of the user to whom access was granted'
/
comment on column ALL_COL_PRIVS_MADE.OWNER is
'Username of the owner of the object'
/
comment on column ALL_COL_PRIVS_MADE.TABLE_NAME is
'Name of the object'
/
comment on column ALL_COL_PRIVS_MADE.COLUMN_NAME is
'Name of the column'
/
comment on column ALL_COL_PRIVS_MADE.GRANTOR is
'Name of the user who performed the grant'
/
comment on column ALL_COL_PRIVS_MADE.PRIVILEGE is
'Column Privilege'
/
comment on column ALL_COL_PRIVS_MADE.GRANTABLE is
'Privilege is grantable'
/
create or replace public synonym ALL_COL_PRIVS_MADE for ALL_COL_PRIVS_MADE
/
grant select on ALL_COL_PRIVS_MADE to PUBLIC with grant option
/
remark
remark  FAMILY "COL_PRIVS_RECD"
remark  Received grants on columns
remark
create or replace view USER_COL_PRIVS_RECD
      (OWNER, TABLE_NAME, COLUMN_NAME, GRANTOR, PRIVILEGE, GRANTABLE)
as
select u.name, o.name, c.name, ur.name, tpm.name,
       decode(mod(oa.option$,2), 1, 'YES', 'NO')
from sys.objauth$ oa, sys.obj$ o, sys.user$ u, sys.user$ ur,
     sys.col$ c, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and u.user# = o.owner#
  and oa.obj# = c.obj#
  and oa.col# = c.col#
  and bitand(c.property, 32) = 0 /* not hidden column */
  and oa.col# is not null
  and oa.privilege# = tpm.privilege
  and oa.grantee# = userenv('SCHEMAID')
/
comment on table USER_COL_PRIVS_RECD is
'Grants on columns for which the user is the grantee'
/
comment on column USER_COL_PRIVS_RECD.OWNER is
'Username of the owner of the object'
/
comment on column USER_COL_PRIVS_RECD.TABLE_NAME is
'Name of the object'
/
comment on column USER_COL_PRIVS_RECD.COLUMN_NAME is
'Name of the column'
/
comment on column USER_COL_PRIVS_RECD.GRANTOR is
'Name of the user who performed the grant'
/
comment on column USER_COL_PRIVS_RECD.PRIVILEGE is
'Column Privilege'
/
comment on column USER_COL_PRIVS_RECD.GRANTABLE is
'Privilege is grantable'
/
create or replace public synonym USER_COL_PRIVS_RECD for USER_COL_PRIVS_RECD
/
grant select on USER_COL_PRIVS_RECD to PUBLIC with grant option
/
create or replace view ALL_COL_PRIVS_RECD
      (GRANTEE, OWNER, TABLE_NAME, COLUMN_NAME, GRANTOR, PRIVILEGE, GRANTABLE)
as
select ue.name, u.name, o.name, c.name, ur.name, tpm.name,
       decode(mod(oa.option$,2), 1, 'YES', 'NO')
from sys.objauth$ oa, sys.obj$ o, sys.user$ u, sys.user$ ur, sys.user$ ue,
     sys.col$ c, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and u.user# = o.owner#
  and oa.obj# = c.obj#
  and oa.col# = c.col#
  and bitand(c.property, 32) = 0 /* not hidden column */
  and oa.col# is not null
  and oa.privilege# = tpm.privilege
  and oa.grantee# in (select kzsrorol from x$kzsro)
/
comment on table ALL_COL_PRIVS_RECD is
'Grants on columns for which the user, PUBLIC or enabled role is the grantee'
/
comment on column ALL_COL_PRIVS_RECD.GRANTEE is
'Name of the user to whom access was granted'
/
comment on column ALL_COL_PRIVS_RECD.OWNER is
'Username of the owner of the object'
/
comment on column ALL_COL_PRIVS_RECD.TABLE_NAME is
'Name of the object'
/
comment on column ALL_COL_PRIVS_RECD.COLUMN_NAME is
'Name of the column'
/
comment on column ALL_COL_PRIVS_RECD.GRANTOR is
'Name of the user who performed the grant'
/
comment on column ALL_COL_PRIVS_RECD.PRIVILEGE is
'Column privilege'
/
comment on column ALL_COL_PRIVS_RECD.GRANTABLE is
'Privilege is grantable'
/
create or replace public synonym ALL_COL_PRIVS_RECD for ALL_COL_PRIVS_RECD
/
grant select on ALL_COL_PRIVS_RECD to PUBLIC with grant option
/
remark
remark  FAMILY "ENCRYPTED_COLUMNS"
remark  information about encrypted columns.
remark
create or replace view DBA_ENCRYPTED_COLUMNS
  (OWNER, TABLE_NAME, COLUMN_NAME, ENCRYPTION_ALG, SALT) as
   select u.name, o.name, c.name,
          case e.ENCALG when 1 then '3 Key Triple DES 168 bits key'
                        when 2 then 'AES 128 bits key'
                        when 3 then 'AES 192 bits key'
                        when 4 then 'AES 256 bits key'
                        else 'Internal Err'
          end,
          decode(bitand(c.property, 536870912), 0, 'YES', 'NO')
   from user$ u, obj$ o, col$ c, enc$ e
   where e.obj#=o.obj# and o.owner#=u.user# and bitand(flags, 128)=0 and
         e.obj#=c.obj# and bitand(c.property, 67108864) = 67108864
/
comment on table DBA_ENCRYPTED_COLUMNS is
'Encryption information on columns in the database'
/
comment on column DBA_ENCRYPTED_COLUMNS.OWNER is
'Owner of the table'
/
comment on column DBA_ENCRYPTED_COLUMNS.TABLE_NAME is
'Name of the table'
/
comment on column DBA_ENCRYPTED_COLUMNS.COLUMN_NAME is
'Name of the column'
/
comment on column DBA_ENCRYPTED_COLUMNS.ENCRYPTION_ALG is
'Encryption algorithm used for the column'
/
comment on column DBA_ENCRYPTED_COLUMNS.SALT is
'Is this column encrypted with salt? YES or NO'
/
create or replace public synonym DBA_ENCRYPTED_COLUMNS for DBA_ENCRYPTED_COLUMNS
/
grant select on DBA_ENCRYPTED_COLUMNS to select_catalog_role
/
create or replace view ALL_ENCRYPTED_COLUMNS
  (OWNER, TABLE_NAME, COLUMN_NAME, ENCRYPTION_ALG, SALT) as
   select u.name, o.name, c.name,
          case e.ENCALG when 1 then '3 Key Triple DES 168 bits key'
                        when 2 then 'AES 128 bits key'
                        when 3 then 'AES 192 bits key'
                        when 4 then 'AES 256 bits key'
                        else 'Internal Err'
          end,
          decode(bitand(c.property, 536870912), 0, 'YES', 'NO')
   from user$ u, obj$ o, col$ c, enc$ e
   where e.obj#=o.obj# and o.owner#=u.user# and bitand(flags, 128)=0 and
         e.obj#=c.obj# and bitand(c.property, 67108864) = 67108864 and
         (o.owner# = userenv('SCHEMAID')
          or
          e.obj# in (select obj# from sys.objauth$ where grantee# in
                        (select kzsrorol from x$kzsro))
          or
          exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */))
          )
/
comment on table ALL_ENCRYPTED_COLUMNS is
'Encryption information on all accessible columns'
/
comment on column ALL_ENCRYPTED_COLUMNS.OWNER is
'Owner of the table'
/
comment on column ALL_ENCRYPTED_COLUMNS.TABLE_NAME is
'Name of the table'
/
comment on column ALL_ENCRYPTED_COLUMNS.COLUMN_NAME is
'Name of the column'
/
comment on column ALL_ENCRYPTED_COLUMNS.ENCRYPTION_ALG is
'Encryption algorithm used for the column'
/
comment on column ALL_ENCRYPTED_COLUMNS.SALT is
'Is this column encrypted with salt? YES or NO'
/
drop public synonym ALL_ENCRYPTED_COLUMNS
/
create public synonym ALL_ENCRYPTED_COLUMNS for ALL_ENCRYPTED_COLUMNS
/
grant select on ALL_ENCRYPTED_COLUMNS to public
/
create or replace view USER_ENCRYPTED_COLUMNS
  (TABLE_NAME, COLUMN_NAME, ENCRYPTION_ALG, SALT) as
  select TABLE_NAME, COLUMN_NAME, ENCRYPTION_ALG,SALT from DBA_ENCRYPTED_COLUMNS
  where OWNER = SYS_CONTEXT('USERENV','CURRENT_USER')
/
comment on table USER_ENCRYPTED_COLUMNS is
'Encryption information on columns of tables owned by the user'
/
comment on column USER_ENCRYPTED_COLUMNS.TABLE_NAME is
'Name of the table'
/
comment on column USER_ENCRYPTED_COLUMNS.COLUMN_NAME is
'Name of the column'
/
comment on column USER_ENCRYPTED_COLUMNS.ENCRYPTION_ALG is
'Encryption algorithm used for the column'
/
comment on column USER_ENCRYPTED_COLUMNS.SALT is
'Is this column encrypted with salt? YES or NO'
/
drop public synonym USER_ENCRYPTED_COLUMNS
/
create public synonym USER_ENCRYPTED_COLUMNS for USER_ENCRYPTED_COLUMNS
/
grant select on USER_ENCRYPTED_COLUMNS to public
/
remark
remark  FAMILY "DB_LINKS"
remark  All relevant information about database links.
remark
create or replace view USER_DB_LINKS
    (DB_LINK, USERNAME, PASSWORD, HOST, CREATED)
as
select l.name, l.userid, l.password, l.host, l.ctime
from sys.link$ l
where l.owner# = userenv('SCHEMAID')
/
comment on table USER_DB_LINKS is
'Database links owned by the user'
/
comment on column USER_DB_LINKS.DB_LINK is
'Name of the database link'
/
comment on column USER_DB_LINKS.USERNAME is
'Name of user to log on as'
/
comment on column USER_DB_LINKS.PASSWORD is
'Deprecated-Password for logon'
/
comment on column USER_DB_LINKS.HOST is
'SQL*Net string for connect'
/
comment on column USER_DB_LINKS.CREATED is
'Creation time of the database link'
/
create or replace public synonym USER_DB_LINKS for USER_DB_LINKS
/
grant select on USER_DB_LINKS to PUBLIC with grant option
/
create or replace view ALL_DB_LINKS
    (OWNER, DB_LINK, USERNAME, HOST, CREATED)
as
select u.name, l.name, l.userid, l.host, l.ctime
from sys.link$ l, sys.user$ u
where l.owner# in ( select kzsrorol from x$kzsro )
  and l.owner# = u.user#
/
comment on table ALL_DB_LINKS is
'Database links accessible to the user'
/
comment on column ALL_DB_LINKS.DB_LINK is
'Name of the database link'
/
comment on column ALL_DB_LINKS.USERNAME is
'Name of user to log on as'
/
comment on column ALL_DB_LINKS.HOST is
'SQL*Net string for connect'
/
comment on column ALL_DB_LINKS.CREATED is
'Creation time of the database link'
/
create or replace public synonym ALL_DB_LINKS for ALL_DB_LINKS
/
grant select on ALL_DB_LINKS to PUBLIC with grant option
/
create or replace view DBA_DB_LINKS
    (OWNER, DB_LINK, USERNAME, HOST, CREATED)
as
select u.name, l.name, l.userid, l.host, l.ctime
from sys.link$ l, sys.user$ u
where l.owner# = u.user#
/
create or replace public synonym DBA_DB_LINKS for DBA_DB_LINKS
/
grant select on DBA_DB_LINKS to select_catalog_role
/
comment on table DBA_DB_LINKS is
'All database links in the database'
/
comment on column DBA_DB_LINKS.DB_LINK is
'Name of the database link'
/
comment on column DBA_DB_LINKS.USERNAME is
'Name of user to log on as'
/
comment on column DBA_DB_LINKS.HOST is
'SQL*Net string for connect'
/
comment on column DBA_DB_LINKS.CREATED is
'Creation time of the database link'
/


remark
remark  VIEW "DICTIONARY"
remark  Online documentation for data dictionary tables and views.
remark  This view exists outside of the family schema.
remark
/* Find the names of public synonyms for views owned by SYS that
have names different from the synonym name.  This allows the user
to see the short-hand synonyms we have created.
*/
create or replace view DICTIONARY
    (TABLE_NAME, COMMENTS)
as
select o.name, c.comment$
from sys.obj$ o, sys.com$ c
where o.obj# = c.obj#(+)
  and c.col# is null
  and o.owner# = 0
  and o.type# = 4
  and (o.name like 'USER%'
       or o.name like 'ALL%'
       or (o.name like 'DBA%'
           and exists
                   (select null
                    from sys.v$enabledprivs
                    where priv_number = -47 /* SELECT ANY TABLE */)
           )
      )
union all
select o.name, c.comment$
from sys.obj$ o, sys.com$ c
where o.obj# = c.obj#(+)
  and o.owner# = 0
  and o.name in ('AUDIT_ACTIONS', 'COLUMN_PRIVILEGES', 'DICTIONARY',
        'DICT_COLUMNS', 'DUAL', 'GLOBAL_NAME', 'INDEX_HISTOGRAM',
        'INDEX_STATS', 'RESOURCE_COST', 'ROLE_ROLE_PRIVS', 'ROLE_SYS_PRIVS',
        'ROLE_TAB_PRIVS', 'SESSION_PRIVS', 'SESSION_ROLES',
        'TABLE_PRIVILEGES','NLS_SESSION_PARAMETERS','NLS_INSTANCE_PARAMETERS',
        'NLS_DATABASE_PARAMETERS', 'DATABASE_COMPATIBLE_LEVEL',
        'DBMS_ALERT_INFO', 'DBMS_LOCK_ALLOCATED')
  and c.col# is null
union all
select so.name, 'Synonym for ' || sy.name
from sys.obj$ ro, sys.syn$ sy, sys.obj$ so
where so.type# = 5
  and ro.linkname is null
  and so.owner# = 1
  and so.obj# = sy.obj#
  and so.name <> sy.name
  and sy.owner = 'SYS'
  and sy.name = ro.name
  and ro.owner# = 0
  and ro.type# = 4
  and (ro.owner# = userenv('SCHEMAID')
       or ro.obj# in
           (select oa.obj#
            from sys.objauth$ oa
            where grantee# in (select kzsrorol from x$kzsro))
       or exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */)
                  ))
/
comment on table DICTIONARY is
'Description of data dictionary tables and views'
/
comment on column DICTIONARY.TABLE_NAME is
'Name of the object'
/
comment on column DICTIONARY.COMMENTS is
'Text comment on the object'
/

create or replace public synonym DICTIONARY for DICTIONARY
/
create or replace public synonym DICT for DICTIONARY
/
grant select on DICTIONARY to PUBLIC with grant option
/
remark
remark  VIEW "DICT_COLUMNS"
remark  Online documentation for columns in data dictionary tables and views.
remark  This view exists outside of the family schema.
remark
/* Find the column comments for public synonyms for views owned by SYS that
have names different from the synonym name.  This allows the user
to see the columns of the short-hand synonyms we have created.
*/
create or replace view DICT_COLUMNS
    (TABLE_NAME, COLUMN_NAME, COMMENTS)
as
select o.name, c.name, co.comment$
from sys.com$ co, sys.col$ c, sys.obj$ o
where o.owner# = 0
  and o.type# = 4
  and (o.name like 'USER%'
       or o.name like 'ALL%'
       or (o.name like 'DBA%'
           and exists
                   (select null
                    from sys.v$enabledprivs
                    where priv_number = -47 /* SELECT ANY TABLE */)
           )
      )
  and o.obj# = c.obj#
  and c.obj# = co.obj#(+)
  and c.col# = co.col#(+)
  and bitand(c.property, 32) = 0 /* not hidden column */
union all
select o.name, c.name, co.comment$
from sys.com$ co, sys.col$ c, sys.obj$ o
where o.owner# = 0
  and o.name in ('AUDIT_ACTIONS','DUAL','DICTIONARY', 'DICT_COLUMNS')
  and o.obj# = c.obj#
  and c.obj# = co.obj#(+)
  and c.col# = co.col#(+)
  and bitand(c.property, 32) = 0 /* not hidden column */
union all
select so.name, c.name, co.comment$
from sys.com$ co,sys.col$ c, sys.obj$ ro, sys.syn$ sy, sys.obj$ so
where so.type# = 5
  and so.owner# = 1
  and so.obj# = sy.obj#
  and so.name <> sy.name
  and sy.owner = 'SYS'
  and sy.name = ro.name
  and ro.owner# = 0
  and ro.type# = 4
  and ro.obj# = c.obj#
  and c.col# = co.col#(+)
  and bitand(c.property, 32) = 0 /* not hidden column */
  and c.obj# = co.obj#(+)
/
comment on table DICT_COLUMNS is
'Description of columns in data dictionary tables and views'
/
comment on column DICT_COLUMNS.TABLE_NAME is
'Name of the object that contains the column'
/
comment on column DICT_COLUMNS.COLUMN_NAME is
'Name of the column'
/
comment on column DICT_COLUMNS.COMMENTS is
'Text comment on the object'
/
create or replace public synonym DICT_COLUMNS for DICT_COLUMNS
/
grant select on DICT_COLUMNS to PUBLIC with grant option
/
remark
remark  FAMILY "EXP_OBJECTS"
remark  Objects that have been incrementally exported.
remark  This family has a DBA member only.
remark
create or replace view DBA_EXP_OBJECTS
    (OWNER, OBJECT_NAME, OBJECT_TYPE, CUMULATIVE, INCREMENTAL, EXPORT_VERSION)
as
select u.name, o.name,
       decode(o.type#, 1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER',
                      4, 'VIEW', 5, 'SYNONYM', 6, 'SEQUENCE', 7, 'PROCEDURE',
                      8, 'FUNCTION', 9, 'PACKAGE', 11, 'PACKAGE BODY',
                      12, 'TRIGGER', 13, 'TYPE', 14, 'TYPE BODY',
                      22, 'LIBRARY', 28, 'JAVA SOURCE', 29, 'JAVA CLASS',
                      30, 'JAVA RESOURCE', 'UNDEFINED'),
       o.ctime, o.itime, o.expid
from sys.incexp o, sys.user$ u
where o.owner# = u.user#
/
create or replace public synonym DBA_EXP_OBJECTS for DBA_EXP_OBJECTS
/
grant select on DBA_EXP_OBJECTS to select_catalog_role
/
comment on table DBA_EXP_OBJECTS is
'Objects that have been incrementally exported'
/
comment on column DBA_EXP_OBJECTS.OWNER is
'Owner of exported object'
/
comment on column DBA_EXP_OBJECTS.OBJECT_NAME is
'Name of exported object'
/
comment on column DBA_EXP_OBJECTS.OBJECT_TYPE is
'Type of exported object'
/
comment on column DBA_EXP_OBJECTS.CUMULATIVE is
'Timestamp of last cumulative export'
/
comment on column DBA_EXP_OBJECTS.INCREMENTAL is
'Timestamp of last incremental export'
/
comment on column DBA_EXP_OBJECTS.EXPORT_VERSION is
'The id of the export session'
/
remark
remark  FAMILY "EXP_VERSION"
remark  Version number of last incremental export
remark  This family has a DBA member only.
remark
create or replace view DBA_EXP_VERSION
    (EXP_VERSION)
as
select o.expid
from sys.incvid o
/
create or replace public synonym DBA_EXP_VERSION for DBA_EXP_VERSION
/
grant select on DBA_EXP_VERSION to select_catalog_role
/
comment on table DBA_EXP_VERSION is
'Version number of the last export session'
/
comment on column DBA_EXP_VERSION.EXP_VERSION is
'Version number of the last export session'
/
remark
remark  FAMILY "EXP_FILES"
remark  Files created by incremental exports.
remark  This family has a DBA member only.
remark
create or replace view DBA_EXP_FILES
     (EXP_VERSION, EXP_TYPE, FILE_NAME, USER_NAME, TIMESTAMP)
as
select o.expid, decode(o.exptype, 'X', 'COMPLETE', 'C', 'CUMULATIVE',
                                  'I', 'INCREMENTAL', 'UNDEFINED'),
       o.expfile, o.expuser, o.expdate
from sys.incfil o
/
create or replace public synonym DBA_EXP_FILES for DBA_EXP_FILES
/
grant select on DBA_EXP_FILES to select_catalog_role
/
comment on table DBA_EXP_FILES is
'Description of export files'
/
comment on column DBA_EXP_FILES.EXP_VERSION is
'Version number of the export session'
/
comment on column DBA_EXP_FILES.FILE_NAME is
'Name of the export file'
/
comment on column DBA_EXP_FILES.USER_NAME is
'Name of user who executed export'
/
comment on column DBA_EXP_FILES.TIMESTAMP is
'Timestamp of the export session'
/
remark
remark  FAMILY "INDEXES"
remark  CREATE INDEX parameters.
remark
create or replace view USER_INDEXES
    (INDEX_NAME,
     INDEX_TYPE,
     TABLE_OWNER, TABLE_NAME,
     TABLE_TYPE,
     UNIQUENESS,
     COMPRESSION, PREFIX_LENGTH,
     TABLESPACE_NAME, INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE, PCT_THRESHOLD, INCLUDE_COLUMN,
     FREELISTS, FREELIST_GROUPS, PCT_FREE, LOGGING,
     BLEVEL, LEAF_BLOCKS, DISTINCT_KEYS, AVG_LEAF_BLOCKS_PER_KEY,
     AVG_DATA_BLOCKS_PER_KEY, CLUSTERING_FACTOR, STATUS,
     NUM_ROWS, SAMPLE_SIZE, LAST_ANALYZED, DEGREE, INSTANCES, PARTITIONED,
     TEMPORARY, GENERATED, SECONDARY, BUFFER_POOL,
     USER_STATS, DURATION, PCT_DIRECT_ACCESS,
     ITYP_OWNER, ITYP_NAME, PARAMETERS, GLOBAL_STATS, DOMIDX_STATUS,
     DOMIDX_OPSTATUS, FUNCIDX_STATUS, JOIN_INDEX, IOT_REDUNDANT_PKEY_ELIM,
     DROPPED)
as
select o.name,
       decode(bitand(i.property, 16), 0, '', 'FUNCTION-BASED ') ||
        decode(i.type#, 1, 'NORMAL'||
                          decode(bitand(i.property, 4), 0, '', 4, '/REV'),
                      2, 'BITMAP', 3, 'CLUSTER', 4, 'IOT - TOP',
                      5, 'IOT - NESTED', 6, 'SECONDARY', 7, 'ANSI', 8, 'LOB',
                      9, 'DOMAIN'),
       iu.name, io.name,
       decode(io.type#, 0, 'NEXT OBJECT', 1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER',
                       4, 'VIEW', 5, 'SYNONYM', 6, 'SEQUENCE', 'UNDEFINED'),
       decode(bitand(i.property, 1), 0, 'NONUNIQUE', 1, 'UNIQUE', 'UNDEFINED'),
       decode(bitand(i.flags, 32), 0, 'DISABLED', 32, 'ENABLED', null),
       i.spare2,
       decode(bitand(i.property, 34), 0,
           decode(i.type#, 9, null, ts.name), null),
       to_number(decode(bitand(i.property, 2),2, null, i.initrans)),
       to_number(decode(bitand(i.property, 2),2, null, i.maxtrans)),
       s.iniexts * ts.blocksize,
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
                             s.extsize * ts.blocksize),
       s.minexts, s.maxexts,
        decode(bitand(ts.flags, 3), 1, to_number(NULL),
                                     s.extpct),
       decode(i.type#, 4, mod(i.pctthres$,256), NULL), i.trunccnt,
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
          decode(bitand(o.flags, 2), 2, 1, decode(s.lists, 0, 1, s.lists))),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
          decode(bitand(o.flags, 2), 2, 1, decode(s.groups, 0, 1, s.groups))),
       decode(bitand(i.property, 2),0,i.pctfree$,null),
       decode(bitand(i.property, 2), 2, NULL,
                decode(bitand(i.flags, 4), 0, 'YES', 'NO')),
       i.blevel, i.leafcnt, i.distkey, i.lblkkey, i.dblkkey, i.clufac,
       decode(bitand(i.property, 2), 2,
                    decode(i.type#, 9, decode(bitand(i.flags, 8),
                                        8, 'INPROGRS', 'VALID'), 'N/A'),
                     decode(bitand(i.flags, 1), 1, 'UNUSABLE',
                            decode(bitand(i.flags, 8), 8, 'INPROGRS',
                                                'VALID'))),
       rowcnt, samplesize, analyzetime,
       decode(i.degree, 32767, 'DEFAULT', nvl(i.degree,1)),
       decode(i.instances, 32767, 'DEFAULT', nvl(i.instances,1)),
       decode(bitand(i.property, 2), 2, 'YES', 'NO'),
       decode(bitand(o.flags, 2), 0, 'N', 2, 'Y', 'N'),
       decode(bitand(o.flags, 4), 0, 'N', 4, 'Y', 'N'),
       decode(bitand(o.flags, 16), 0, 'N', 16, 'Y', 'N'),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
             decode(s.cachehint, 0, 'DEFAULT', 1, 'KEEP', 2, 'RECYCLE', NULL)),
       decode(bitand(i.flags, 64), 0, 'NO', 'YES'),
       decode(bitand(o.flags, 2), 0, NULL,
          decode(bitand(i.property, 64), 64, 'SYS$SESSION', 'SYS$TRANSACTION')),
       decode(bitand(i.flags, 128), 128, mod(trunc(i.pctthres$/256),256),
              decode(i.type#, 4, mod(trunc(i.pctthres$/256),256), NULL)),
       itu.name, ito.name, i.spare4,
       decode(bitand(i.flags, 2048), 0, 'NO', 'YES'),
       decode(i.type#, 9, decode(o.status, 5, 'IDXTYP_INVLD',
                                           1, 'VALID'),  ''),
       decode(i.type#, 9, decode(bitand(i.flags, 16), 16, 'FAILED', 'VALID'), ''),
       decode(bitand(i.property, 16), 0, '',
              decode(bitand(i.flags, 1024), 0, 'ENABLED', 'DISABLED')),
       decode(bitand(i.property, 1024), 1024, 'YES', 'NO'),
       decode(bitand(i.property, 16384), 16384, 'YES', 'NO'),
       decode(bitand(o.flags, 128), 128, 'YES', 'NO')
from sys.ts$ ts, sys.seg$ s, sys.user$ iu, sys.obj$ io, sys.ind$ i, sys.obj$ o,
     sys.user$ itu, sys.obj$ ito
where o.owner# = userenv('SCHEMAID')
  and o.obj# = i.obj#
  and i.bo# = io.obj#
  and io.owner# = iu.user#
  and bitand(i.flags, 4096) = 0
  and bitand(o.flags, 128) = 0
  and i.ts# = ts.ts# (+)
  and i.file# = s.file# (+)
  and i.block# = s.block# (+)
  and i.ts# = s.ts# (+)
  and i.type# in (1, 2, 3, 4, 6, 7, 8, 9)
  and i.indmethod# = ito.obj# (+)
  and ito.owner# = itu.user# (+)
/
comment on table USER_INDEXES is
'Description of the user''s own indexes'
/
comment on column USER_INDEXES.STATUS is
'Whether the non-partitioned index is in USABLE or not'
/
comment on column USER_INDEXES.INDEX_NAME is
'Name of the index'
/
comment on column USER_INDEXES.TABLE_OWNER is
'Owner of the indexed object'
/
comment on column USER_INDEXES.TABLE_NAME is
'Name of the indexed object'
/
comment on column USER_INDEXES.TABLE_TYPE is
'Type of the indexed object'
/
comment on column USER_INDEXES.UNIQUENESS is
'Uniqueness status of the index:  "UNIQUE",  "NONUNIQUE", or "BITMAP"'
/
comment on column USER_INDEXES.COMPRESSION is
'Compression property of the index: "ENABLED",  "DISABLED", or NULL'
/
comment on column USER_INDEXES.PREFIX_LENGTH is
'Number of key columns in the prefix used for compression'
/
comment on column USER_INDEXES.TABLESPACE_NAME is
'Name of the tablespace containing the index'
/
comment on column USER_INDEXES.INI_TRANS is
'Initial number of transactions'
/
comment on column USER_INDEXES.MAX_TRANS is
'Maximum number of transactions'
/
comment on column USER_INDEXES.INITIAL_EXTENT is
'Size of the initial extent in bytes'
/
comment on column USER_INDEXES.NEXT_EXTENT is
'Size of secondary extents in bytes'
/
comment on column USER_INDEXES.MIN_EXTENTS is
'Minimum number of extents allowed in the segment'
/
comment on column USER_INDEXES.MAX_EXTENTS is
'Maximum number of extents allowed in the segment'
/
comment on column USER_INDEXES.PCT_INCREASE is
'Percentage increase in extent size'
/
comment on column USER_INDEXES.PCT_THRESHOLD is
'Threshold percentage of block space allowed per index entry'
/
comment on column USER_INDEXES.INCLUDE_COLUMN is
'User column-id for last column to be included in index-only table top index'
/
comment on column USER_INDEXES.FREELISTS is
'Number of process freelists allocated in this segment'
/
comment on column USER_INDEXES.FREELIST_GROUPS is
'Number of freelist groups allocated to this segment'
/
comment on column USER_INDEXES.PCT_FREE is
'Minimum percentage of free space in a block'
/
comment on column USER_INDEXES.LOGGING is
'Logging attribute'
/
comment on column USER_INDEXES.BLEVEL is
'B-Tree level'
/
comment on column USER_INDEXES.LEAF_BLOCKS is
'The number of leaf blocks in the index'
/
comment on column USER_INDEXES.DISTINCT_KEYS is
'The number of distinct keys in the index'
/
comment on column USER_INDEXES.AVG_LEAF_BLOCKS_PER_KEY is
'The average number of leaf blocks per key'
/
comment on column USER_INDEXES.AVG_DATA_BLOCKS_PER_KEY is
'The average number of data blocks per key'
/
comment on column USER_INDEXES.CLUSTERING_FACTOR is
'A measurement of the amount of (dis)order of the table this index is for'
/
comment on column USER_INDEXES.NUM_ROWS is
'Number of rows in the index'
/
comment on column USER_INDEXES.SAMPLE_SIZE is
'The sample size used in analyzing this index'
/
comment on column USER_INDEXES.LAST_ANALYZED is
'The date of the most recent time this index was analyzed'
/
comment on column USER_INDEXES.DEGREE is
'The number of threads per instance for scanning the partitioned index'
/
comment on column USER_INDEXES.INSTANCES is
'The number of instances across which the partitioned index is to be scanned'
/
comment on column USER_INDEXES.PARTITIONED is
'Is this index partitioned? YES or NO'
/
comment on column USER_INDEXES.TEMPORARY is
'Can the current session only see data that it place in this object itself?'
/
comment on column USER_INDEXES.GENERATED is
'Was the name of this index system generated?'
/
comment on column USER_INDEXES.SECONDARY is
'Is the index object created as part of icreate for domain indexes?'
/
comment on column USER_INDEXES.BUFFER_POOL is
'The default buffer pool to be used for index blocks'
/
comment on column USER_INDEXES.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column USER_INDEXES.DURATION is
'If index on temporary table, then duration is sys$session or sys$transaction else NULL'
/
comment on column USER_INDEXES.PCT_DIRECT_ACCESS is
'If index on IOT, then this is percentage of rows with Valid guess'
/
comment on column USER_INDEXES.ITYP_OWNER is
'If domain index, then this is the indextype owner'
/
comment on column USER_INDEXES.ITYP_NAME is
'If domain index, then this is the name of the associated indextype'
/
comment on column USER_INDEXES.PARAMETERS is
'If domain index, then this is the parameter string'
/
comment on column USER_INDEXES.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column USER_INDEXES.DOMIDX_STATUS is
'Is the indextype of the domain index valid'
/
comment on column USER_INDEXES.DOMIDX_OPSTATUS is
'Status of the operation on the domain index'
/
comment on column USER_INDEXES.FUNCIDX_STATUS is
'Is the Function-based Index DISABLED or ENABLED?'
/
comment on column USER_INDEXES.JOIN_INDEX is
'Is this index a join index?'
/
comment on column USER_INDEXES.IOT_REDUNDANT_PKEY_ELIM is
'Were redundant primary key columns eliminated from iot secondary index?'
/
comment on column USER_INDEXES.DROPPED is
'Whether index is dropped and is in Recycle Bin'
/
create or replace public synonym USER_INDEXES for USER_INDEXES
/
create or replace public synonym IND for USER_INDEXES
/
grant select on USER_INDEXES to PUBLIC with grant option
/
remark
remark  This view does not include cluster indexes on clusters
remark  containing tables which are accessible to the user.
remark
create or replace view ALL_INDEXES
    (OWNER, INDEX_NAME,
     INDEX_TYPE,
     TABLE_OWNER, TABLE_NAME,
     TABLE_TYPE,
     UNIQUENESS,
     COMPRESSION, PREFIX_LENGTH,
     TABLESPACE_NAME, INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT, MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     PCT_THRESHOLD, INCLUDE_COLUMN,
     FREELISTS,  FREELIST_GROUPS, PCT_FREE, LOGGING,
     BLEVEL, LEAF_BLOCKS, DISTINCT_KEYS, AVG_LEAF_BLOCKS_PER_KEY,
     AVG_DATA_BLOCKS_PER_KEY, CLUSTERING_FACTOR, STATUS,
     NUM_ROWS, SAMPLE_SIZE, LAST_ANALYZED, DEGREE, INSTANCES, PARTITIONED,
     TEMPORARY, GENERATED, SECONDARY, BUFFER_POOL,
     USER_STATS, DURATION, PCT_DIRECT_ACCESS,
     ITYP_OWNER, ITYP_NAME, PARAMETERS, GLOBAL_STATS, DOMIDX_STATUS,
     DOMIDX_OPSTATUS, FUNCIDX_STATUS, JOIN_INDEX, IOT_REDUNDANT_PKEY_ELIM,
     DROPPED)
 as
select u.name, o.name,
       decode(bitand(i.property, 16), 0, '', 'FUNCTION-BASED ') ||
        decode(i.type#, 1, 'NORMAL'||
                          decode(bitand(i.property, 4), 0, '', 4, '/REV'),
                      2, 'BITMAP', 3, 'CLUSTER', 4, 'IOT - TOP',
                      5, 'IOT - NESTED', 6, 'SECONDARY', 7, 'ANSI', 8, 'LOB',
                      9, 'DOMAIN'),
       iu.name, io.name, 'TABLE',
       decode(bitand(i.property, 1), 0, 'NONUNIQUE', 1, 'UNIQUE', 'UNDEFINED'),
       decode(bitand(i.flags, 32), 0, 'DISABLED', 32, 'ENABLED', null),
       i.spare2,
       decode(bitand(i.property, 34), 0,
           decode(i.type#, 9, null, ts.name), null),
       decode(bitand(i.property, 2),0, i.initrans, null),
       decode(bitand(i.property, 2),0, i.maxtrans, null),
       s.iniexts * ts.blocksize,
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
                             s.extsize * ts.blocksize),
       s.minexts, s.maxexts,
        decode(bitand(ts.flags, 3), 1, to_number(NULL),
                                     s.extpct),
       decode(i.type#, 4, mod(i.pctthres$,256), NULL), i.trunccnt,
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
         decode(bitand(o.flags, 2), 2, 1, decode(s.lists, 0, 1, s.lists))),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
         decode(bitand(o.flags, 2), 2, 1, decode(s.groups, 0, 1, s.groups))),
       decode(bitand(i.property, 2),0,i.pctfree$,null),
       decode(bitand(i.property, 2), 2, NULL,
                decode(bitand(i.flags, 4), 0, 'YES', 'NO')),
       i.blevel, i.leafcnt, i.distkey, i.lblkkey, i.dblkkey, i.clufac,
       decode(bitand(i.property, 2), 2,
                   decode(i.type#, 9, decode(bitand(i.flags, 8),
                                        8, 'INPROGRS', 'VALID'), 'N/A'),
                     decode(bitand(i.flags, 1), 1, 'UNUSABLE',
                            decode(bitand(i.flags, 8), 8, 'INRPOGRS',
                                                            'VALID'))),
       rowcnt, samplesize, analyzetime,
       decode(i.degree, 32767, 'DEFAULT', nvl(i.degree,1)),
       decode(i.instances, 32767, 'DEFAULT', nvl(i.instances,1)),
       decode(bitand(i.property, 2), 2, 'YES', 'NO'),
       decode(bitand(o.flags, 2), 0, 'N', 2, 'Y', 'N'),
       decode(bitand(o.flags, 4), 0, 'N', 4, 'Y', 'N'),
       decode(bitand(o.flags, 16), 0, 'N', 16, 'Y', 'N'),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
             decode(s.cachehint, 0, 'DEFAULT', 1, 'KEEP', 2, 'RECYCLE', NULL)),
       decode(bitand(i.flags, 64), 0, 'NO', 'YES'),
       decode(bitand(o.flags, 2), 0, NULL,
           decode(bitand(i.property, 64), 64, 'SYS$SESSION', 'SYS$TRANSACTION')),
       decode(bitand(i.flags, 128), 128, mod(trunc(i.pctthres$/256),256),
              decode(i.type#, 4, mod(trunc(i.pctthres$/256),256), NULL)),
       itu.name, ito.name, i.spare4,
       decode(bitand(i.flags, 2048), 0, 'NO', 'YES'),
       decode(i.type#, 9, decode(o.status, 5, 'IDXTYP_INVLD',
                                           1, 'VALID'),  ''),
       decode(i.type#, 9, decode(bitand(i.flags, 16), 16, 'FAILED', 'VALID'), ''),
       decode(bitand(i.property, 16), 0, '',
              decode(bitand(i.flags, 1024), 0, 'ENABLED', 'DISABLED')),
       decode(bitand(i.property, 1024), 1024, 'YES', 'NO'),
       decode(bitand(i.property, 16384), 16384, 'YES', 'NO'),
       decode(bitand(o.flags, 128), 128, 'YES', 'NO')
from sys.ts$ ts, sys.seg$ s, sys.user$ iu, sys.obj$ io,
     sys.user$ u, sys.ind$ i, sys.obj$ o, sys.user$ itu, sys.obj$ ito
where u.user# = o.owner#
  and o.obj# = i.obj#
  and i.bo# = io.obj#
  and io.owner# = iu.user#
  and io.type# = 2 /* tables */
  and bitand(i.flags, 4096) = 0
  and bitand(o.flags, 128) = 0
  and i.ts# = ts.ts# (+)
  and i.file# = s.file# (+)
  and i.block# = s.block# (+)
  and i.ts# = s.ts# (+)
  and i.type# in (1, 2, 3, 4, 6, 7, 9)
  and i.indmethod# = ito.obj# (+)
  and ito.owner# = itu.user# (+)
  and (io.owner# = userenv('SCHEMAID')
        or
       io.obj# in ( select obj#
                    from sys.objauth$
                    where grantee# in ( select kzsrorol
                                        from x$kzsro
                                      )
                   )
        or
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
       )
/
comment on table ALL_INDEXES is
'Descriptions of indexes on tables accessible to the user'
/
comment on column ALL_INDEXES.OWNER is
'Username of the owner of the index'
/
comment on column ALL_INDEXES.STATUS is
'Whether the non-partitioned index is in USABLE or not'
/
comment on column ALL_INDEXES.INDEX_NAME is
'Name of the index'
/
comment on column ALL_INDEXES.TABLE_OWNER is
'Owner of the indexed object'
/
comment on column ALL_INDEXES.TABLE_NAME is
'Name of the indexed object'
/
comment on column ALL_INDEXES.TABLE_TYPE is
'Type of the indexed object'
/
comment on column ALL_INDEXES.UNIQUENESS is
'Uniqueness status of the index: "UNIQUE",  "NONUNIQUE", or "BITMAP"'
/
comment on column ALL_INDEXES.COMPRESSION is
'Compression property of the index: "ENABLED",  "DISABLED", or NULL'
/
comment on column ALL_INDEXES.PREFIX_LENGTH is
'Number of key columns in the prefix used for compression'
/
comment on column ALL_INDEXES.TABLESPACE_NAME is
'Name of the tablespace containing the index'
/
comment on column ALL_INDEXES.INI_TRANS is
'Initial number of transactions'
/
comment on column ALL_INDEXES.MAX_TRANS is
'Maximum number of transactions'
/
comment on column ALL_INDEXES.INITIAL_EXTENT is
'Size of the initial extent'
/
comment on column ALL_INDEXES.NEXT_EXTENT is
'Size of secondary extents'
/
comment on column ALL_INDEXES.MIN_EXTENTS is
'Minimum number of extents allowed in the segment'
/
comment on column ALL_INDEXES.MAX_EXTENTS is
'Maximum number of extents allowed in the segment'
/
comment on column ALL_INDEXES.PCT_INCREASE is
'Percentage increase in extent size'
/
comment on column ALL_INDEXES.PCT_THRESHOLD is
'Threshold percentage of block space allowed per index entry'
/
comment on column ALL_INDEXES.INCLUDE_COLUMN is
'User column-id for last column to be included in index-organized table top index'
/
comment on column ALL_INDEXES.FREELISTS is
'Number of process freelists allocated in this segment'
/
comment on column ALL_INDEXES.FREELIST_GROUPS is
'Number of freelist groups allocated to this segment'
/
comment on column ALL_INDEXES.PCT_FREE is
'Minimum percentage of free space in a block'
/
comment on column ALL_INDEXES.LOGGING is
'Logging attribute'
/
comment on column ALL_INDEXES.BLEVEL is
'B-Tree level'
/
comment on column ALL_INDEXES.LEAF_BLOCKS is
'The number of leaf blocks in the index'
/
comment on column ALL_INDEXES.DISTINCT_KEYS is
'The number of distinct keys in the index'
/
comment on column ALL_INDEXES.AVG_LEAF_BLOCKS_PER_KEY is
'The average number of leaf blocks per key'
/
comment on column ALL_INDEXES.AVG_DATA_BLOCKS_PER_KEY is
'The average number of data blocks per key'
/
comment on column ALL_INDEXES.CLUSTERING_FACTOR is
'A measurement of the amount of (dis)order of the table this index is for'
/
comment on column ALL_INDEXES.SAMPLE_SIZE is
'The sample size used in analyzing this index'
/
comment on column ALL_INDEXES.LAST_ANALYZED is
'The date of the most recent time this index was analyzed'
/
comment on column ALL_INDEXES.DEGREE is
'The number of threads per instance for scanning the partitioned index'
/
comment on column ALL_INDEXES.INSTANCES is
'The number of instances across which the partitioned index is to be scanned'
/
comment on column ALL_INDEXES.PARTITIONED is
'Is this index partitioned? YES or NO'
/
comment on column ALL_INDEXES.TEMPORARY is
'Can the current session only see data that it place in this object itself?'
/
comment on column ALL_INDEXES.GENERATED is
'Was the name of this index system generated?'
/
comment on column ALL_INDEXES.SECONDARY is
'Is the index object created as part of icreate for domain indexes?'
/
comment on column ALL_INDEXES.BUFFER_POOL is
'The default buffer pool to be used for index blocks'
/
comment on column ALL_INDEXES.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column ALL_INDEXES.DURATION is
'If index on temporary table, then duration is sys$session or sys$transaction else NULL'
/
comment on column ALL_INDEXES.PCT_DIRECT_ACCESS is
'If index on IOT, then this is percentage of rows with Valid guess'
/
comment on column ALL_INDEXES.ITYP_OWNER is
'If domain index, then this is the indextype owner'
/
comment on column ALL_INDEXES.ITYP_NAME is
'If domain index, then this is the name of the associated indextype'
/
comment on column ALL_INDEXES.PARAMETERS is
'If domain index, then this is the parameter string'
/
comment on column ALL_INDEXES.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column ALL_INDEXES.DOMIDX_STATUS is
'Is the indextype of the domain index valid'
/
comment on column ALL_INDEXES.DOMIDX_OPSTATUS is
'Status of the operation on the domain index'
/
comment on column ALL_INDEXES.FUNCIDX_STATUS is
'Is the Function-based Index DISABLED or ENABLED?'
/
comment on column ALL_INDEXES.JOIN_INDEX is
'Is this index a join index?'
/
comment on column ALL_INDEXES.IOT_REDUNDANT_PKEY_ELIM is
'Were redundant primary key columns eliminated from iot secondary index?'
/
comment on column ALL_INDEXES.DROPPED is
'Whether index is dropped and is in Recycle Bin'
/
create or replace public synonym ALL_INDEXES for ALL_INDEXES
/
grant select on ALL_INDEXES to PUBLIC with grant option
/
create or replace view DBA_INDEXES
    (OWNER, INDEX_NAME,
     INDEX_TYPE,
     TABLE_OWNER, TABLE_NAME,
     TABLE_TYPE,
     UNIQUENESS,
     COMPRESSION, PREFIX_LENGTH,
     TABLESPACE_NAME, INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE, PCT_THRESHOLD, INCLUDE_COLUMN,
     FREELISTS, FREELIST_GROUPS, PCT_FREE, LOGGING, BLEVEL,
     LEAF_BLOCKS, DISTINCT_KEYS, AVG_LEAF_BLOCKS_PER_KEY,
     AVG_DATA_BLOCKS_PER_KEY, CLUSTERING_FACTOR, STATUS,
     NUM_ROWS, SAMPLE_SIZE, LAST_ANALYZED, DEGREE, INSTANCES, PARTITIONED,
     TEMPORARY, GENERATED, SECONDARY, BUFFER_POOL,
     USER_STATS, DURATION, PCT_DIRECT_ACCESS,
     ITYP_OWNER, ITYP_NAME, PARAMETERS, GLOBAL_STATS, DOMIDX_STATUS,
     DOMIDX_OPSTATUS, FUNCIDX_STATUS, JOIN_INDEX, IOT_REDUNDANT_PKEY_ELIM,
     DROPPED)
as
select u.name, o.name,
       decode(bitand(i.property, 16), 0, '', 'FUNCTION-BASED ') ||
        decode(i.type#, 1, 'NORMAL'||
                          decode(bitand(i.property, 4), 0, '', 4, '/REV'),
                      2, 'BITMAP', 3, 'CLUSTER', 4, 'IOT - TOP',
                      5, 'IOT - NESTED', 6, 'SECONDARY', 7, 'ANSI', 8, 'LOB',
                      9, 'DOMAIN'),
       iu.name, io.name,
       decode(io.type#, 0, 'NEXT OBJECT', 1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER',
                       4, 'VIEW', 5, 'SYNONYM', 6, 'SEQUENCE', 'UNDEFINED'),
       decode(bitand(i.property, 1), 0, 'NONUNIQUE', 1, 'UNIQUE', 'UNDEFINED'),
       decode(bitand(i.flags, 32), 0, 'DISABLED', 32, 'ENABLED', null),
       i.spare2,
       decode(bitand(i.property, 34), 0,
           decode(i.type#, 9, null, ts.name), null),
       decode(bitand(i.property, 2),0, i.initrans, null),
       decode(bitand(i.property, 2),0, i.maxtrans, null),
       s.iniexts * ts.blocksize,
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
                             s.extsize * ts.blocksize),
       s.minexts, s.maxexts,
        decode(bitand(ts.flags, 3), 1, to_number(NULL),
                                     s.extpct),
       decode(i.type#, 4, mod(i.pctthres$,256), NULL), i.trunccnt,
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
         decode(bitand(o.flags, 2), 2, 1, decode(s.lists, 0, 1, s.lists))),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
         decode(bitand(o.flags, 2), 2, 1, decode(s.groups, 0, 1, s.groups))),
       decode(bitand(i.property, 2),0,i.pctfree$,null),
       decode(bitand(i.property, 2), 2, NULL,
                decode(bitand(i.flags, 4), 0, 'YES', 'NO')),
       i.blevel, i.leafcnt, i.distkey, i.lblkkey, i.dblkkey, i.clufac,
       decode(bitand(i.property, 2), 2,
                   decode(i.type#, 9, decode(bitand(i.flags, 8),
                                        8, 'INPROGRS', 'VALID'), 'N/A'),
                     decode(bitand(i.flags, 1), 1, 'UNUSABLE',
                            decode(bitand(i.flags, 8), 8, 'INPROGRS',
                                                            'VALID'))),
       rowcnt, samplesize, analyzetime,
       decode(i.degree, 32767, 'DEFAULT', nvl(i.degree,1)),
       decode(i.instances, 32767, 'DEFAULT', nvl(i.instances,1)),
       decode(bitand(i.property, 2), 2, 'YES', 'NO'),
       decode(bitand(o.flags, 2), 0, 'N', 2, 'Y', 'N'),
       decode(bitand(o.flags, 4), 0, 'N', 4, 'Y', 'N'),
       decode(bitand(o.flags, 16), 0, 'N', 16, 'Y', 'N'),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
             decode(s.cachehint, 0, 'DEFAULT', 1, 'KEEP', 2, 'RECYCLE', NULL)),
       decode(bitand(i.flags, 64), 0, 'NO', 'YES'),
       decode(bitand(o.flags, 2), 0, NULL,
           decode(bitand(i.property, 64), 64, 'SYS$SESSION', 'SYS$TRANSACTION')),
       decode(bitand(i.flags, 128), 128, mod(trunc(i.pctthres$/256),256),
              decode(i.type#, 4, mod(trunc(i.pctthres$/256),256), NULL)),
       itu.name, ito.name, i.spare4,
       decode(bitand(i.flags, 2048), 0, 'NO', 'YES'),
       decode(i.type#, 9, decode(o.status, 5, 'IDXTYP_INVLD',
                                           1, 'VALID'),  ''),
       decode(i.type#, 9, decode(bitand(i.flags, 16), 16, 'FAILED', 'VALID'), ''),
       decode(bitand(i.property, 16), 0, '',
              decode(bitand(i.flags, 1024), 0, 'ENABLED', 'DISABLED')),
       decode(bitand(i.property, 1024), 1024, 'YES', 'NO'),
       decode(bitand(i.property, 16384), 16384, 'YES', 'NO'),
       decode(bitand(o.flags, 128), 128, 'YES', 'NO')
from sys.ts$ ts, sys.seg$ s,
     sys.user$ iu, sys.obj$ io, sys.user$ u, sys.ind$ i, sys.obj$ o,
     sys.user$ itu, sys.obj$ ito
where u.user# = o.owner#
  and o.obj# = i.obj#
  and i.bo# = io.obj#
  and io.owner# = iu.user#
  and bitand(i.flags, 4096) = 0
  and bitand(o.flags, 128) = 0
  and i.ts# = ts.ts# (+)
  and i.file# = s.file# (+)
  and i.block# = s.block# (+)
  and i.ts# = s.ts# (+)
  and i.indmethod# = ito.obj# (+)
  and ito.owner# = itu.user# (+)
/
create or replace public synonym DBA_INDEXES for DBA_INDEXES
/
grant select on DBA_INDEXES to select_catalog_role
/
comment on table DBA_INDEXES is
'Description for all indexes in the database'
/
comment on column DBA_INDEXES.STATUS is
'Whether non-partitioned index is in UNUSABLE state or not'
/
comment on column DBA_INDEXES.OWNER is
'Username of the owner of the index'
/
comment on column DBA_INDEXES.INDEX_NAME is
'Name of the index'
/
comment on column DBA_INDEXES.TABLE_OWNER is
'Owner of the indexed object'
/
comment on column DBA_INDEXES.TABLE_NAME is
'Name of the indexed object'
/
comment on column DBA_INDEXES.TABLE_TYPE is
'Type of the indexed object'
/
comment on column DBA_INDEXES.UNIQUENESS is
'Uniqueness status of the index: "UNIQUE",  "NONUNIQUE", or "BITMAP"'
/
comment on column DBA_INDEXES.COMPRESSION is
'Compression property of the index: "ENABLED",  "DISABLED", or NULL'
/
comment on column DBA_INDEXES.PREFIX_LENGTH is
'Number of key columns in the prefix used for compression'
/
comment on column DBA_INDEXES.TABLESPACE_NAME is
'Name of the tablespace containing the index'
/
comment on column DBA_INDEXES.INI_TRANS is
'Initial number of transactions'
/
comment on column DBA_INDEXES.MAX_TRANS is
'Maximum number of transactions'
/
comment on column DBA_INDEXES.INITIAL_EXTENT is
'Size of the initial extent'
/
comment on column DBA_INDEXES.NEXT_EXTENT is
'Size of secondary extents'
/
comment on column DBA_INDEXES.MIN_EXTENTS is
'Minimum number of extents allowed in the segment'
/
comment on column DBA_INDEXES.MAX_EXTENTS is
'Maximum number of extents allowed in the segment'
/
comment on column DBA_INDEXES.PCT_INCREASE is
'Percentage increase in extent size'
/
comment on column DBA_INDEXES.PCT_THRESHOLD is
'Threshold percentage of block space allowed per index entry'
/
comment on column DBA_INDEXES.INCLUDE_COLUMN is
'User column-id for last column to be included in index-only table top index'
/
comment on column DBA_INDEXES.FREELISTS is
'Number of process freelists allocated in this segment'
/
comment on column DBA_INDEXES.FREELIST_GROUPS is
'Number of freelist groups allocated to this segment'
/
comment on column DBA_INDEXES.PCT_FREE is
'Minimum percentage of free space in a block'
/
comment on column DBA_INDEXES.LOGGING is
'Logging attribute'
/
comment on column DBA_INDEXES.BLEVEL is
'B-Tree level'
/
comment on column DBA_INDEXES.LEAF_BLOCKS is
'The number of leaf blocks in the index'
/
comment on column DBA_INDEXES.DISTINCT_KEYS is
'The number of distinct keys in the index'
/
comment on column DBA_INDEXES.AVG_LEAF_BLOCKS_PER_KEY is
'The average number of leaf blocks per key'
/
comment on column DBA_INDEXES.AVG_DATA_BLOCKS_PER_KEY is
'The average number of data blocks per key'
/
comment on column DBA_INDEXES.CLUSTERING_FACTOR is
'A measurement of the amount of (dis)order of the table this index is for'
/
comment on column DBA_INDEXES.SAMPLE_SIZE is
'The sample size used in analyzing this index'
/
comment on column DBA_INDEXES.LAST_ANALYZED is
'The date of the most recent time this index was analyzed'
/
comment on column DBA_INDEXES.DEGREE is
'The number of threads per instance for scanning the partitioned index'
/
comment on column DBA_INDEXES.INSTANCES is
'The number of instances across which the partitioned index is to be scanned'
/
comment on column DBA_INDEXES.PARTITIONED is
'Is this index partitioned? YES or NO'
/
comment on column DBA_INDEXES.TEMPORARY is
'Can the current session only see data that it place in this object itself?'
/
comment on column DBA_INDEXES.GENERATED is
'Was the name of this index system generated?'
/
comment on column DBA_INDEXES.SECONDARY is
'Is the index object created as part of icreate for domain indexes?'
/
comment on column DBA_INDEXES.BUFFER_POOL is
'The default buffer pool to be used for index blocks'
/
comment on column DBA_INDEXES.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column DBA_INDEXES.DURATION is
'If index on temporary table, then duration is sys$session or sys$transaction else NULL'
/
comment on column DBA_INDEXES.PCT_DIRECT_ACCESS is
'If index on IOT, then this is percentage of rows with Valid guess'
/
comment on column DBA_INDEXES.ITYP_OWNER is
'If domain index, then this is the indextype owner'
/
comment on column DBA_INDEXES.ITYP_NAME is
'If domain index, then this is the name of the associated indextype'
/
comment on column DBA_INDEXES.PARAMETERS is
'If domain index, then this is the parameter string'
/
comment on column DBA_INDEXES.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column DBA_INDEXES.DOMIDX_STATUS is
'Is the indextype of the domain index valid'
/
comment on column DBA_INDEXES.DOMIDX_OPSTATUS is
'Status of the operation on the domain index'
/
comment on column DBA_INDEXES.FUNCIDX_STATUS is
'Is the Function-based Index DISABLED or ENABLED?'
/
comment on column DBA_INDEXES.JOIN_INDEX is
'Is this index a join index?'
/
comment on column DBA_INDEXES.IOT_REDUNDANT_PKEY_ELIM is
'Were redundant primary key columns eliminated from iot secondary index?'
/
comment on column DBA_INDEXES.DROPPED is
'Whether index is dropped and is in Recycle Bin'
/
remark
remark  FAMILY "IND_COLUMNS"
remark  Displays information on which columns are contained in which
remark  indexes
remark
create or replace view USER_IND_COLUMNS
    (INDEX_NAME, TABLE_NAME, COLUMN_NAME,
     COLUMN_POSITION, COLUMN_LENGTH,
     CHAR_LENGTH, DESCEND)
as
select idx.name, base.name,
       decode(bitand(c.property, 1024), 1024,
              (select decode(bitand(tc.property, 1), 1, ac.name, tc.name)
              from sys.col$ tc, attrcol$ ac
              where tc.intcol# = c.intcol#-1
                and tc.obj# = c.obj#
                and tc.obj# = ac.obj#(+)
                and tc.intcol# = ac.intcol#(+)),
              decode(ac.name, null, c.name, ac.name)),
       ic.pos#, c.length, c.spare3,
       decode(bitand(c.property, 131072), 131072, 'DESC', 'ASC')
from sys.col$ c, sys.obj$ idx, sys.obj$ base, sys.icol$ ic, sys.ind$ i,
       sys.attrcol$ ac
where c.obj# = base.obj#
  and ic.bo# = base.obj#
  and decode(bitand(i.property,1024),0,ic.intcol#,ic.spare2) = c.intcol#
  and base.owner# = userenv('SCHEMAID')
  and base.namespace in (1, 5) /* table or cluster namespace */
  and ic.obj# = idx.obj#
  and idx.obj# = i.obj#
  and i.type# in (1, 2, 3, 4, 6, 7, 9)
  and c.obj# = ac.obj#(+)
  and c.intcol# = ac.intcol#(+)
union all
select idx.name, base.name,
       decode(bitand(c.property, 1024), 1024,
              (select decode(bitand(tc.property, 1), 1, ac.name, tc.name)
               from sys.col$ tc, attrcol$ ac
               where tc.intcol# = c.intcol#-1
                 and tc.obj# = c.obj#
                 and tc.obj# = ac.obj#(+)
                 and tc.intcol# = ac.intcol#(+)),
              decode(ac.name, null, c.name, ac.name)),
       ic.pos#, c.length, c.spare3,
       decode(bitand(c.property, 131072), 131072, 'DESC', 'ASC')
from sys.col$ c, sys.obj$ idx, sys.obj$ base, sys.icol$ ic, sys.ind$ i,
       sys.attrcol$ ac
where c.obj# = base.obj#
  and i.bo# = base.obj#
  and base.owner# != userenv('SCHEMAID')
  and decode(bitand(i.property,1024),0,ic.intcol#,ic.spare2) = c.intcol#
  and idx.owner# = userenv('SCHEMAID')
  and idx.namespace = 4 /* index namespace */
  and ic.obj# = idx.obj#
  and idx.obj# = i.obj#
  and i.type# in (1, 2, 3, 4, 6, 7, 9)
  and c.obj# = ac.obj#(+)
  and c.intcol# = ac.intcol#(+)
/
comment on table USER_IND_COLUMNS is
'COLUMNs comprising user''s INDEXes and INDEXes on user''s TABLES'
/
comment on column USER_IND_COLUMNS.INDEX_NAME is
'Index name'
/
comment on column USER_IND_COLUMNS.TABLE_NAME is
'Table or cluster name'
/
comment on column USER_IND_COLUMNS.COLUMN_NAME is
'Column name or attribute of object column'
/
comment on column USER_IND_COLUMNS.COLUMN_POSITION is
'Position of column or attribute within index'
/
comment on column USER_IND_COLUMNS.COLUMN_LENGTH is
'Maximum length of the column or attribute, in bytes'
/
comment on column USER_IND_COLUMNS.CHAR_LENGTH is
'Maximum length of the column or attribute, in characters'
/
comment on column USER_IND_COLUMNS.DESCEND is
'DESC if this column is sorted descending on disk, otherwise ASC'
/
create or replace public synonym USER_IND_COLUMNS for USER_IND_COLUMNS
/
grant select on USER_IND_COLUMNS to PUBLIC with grant option
/
create or replace view ALL_IND_COLUMNS
    (INDEX_OWNER, INDEX_NAME,
     TABLE_OWNER, TABLE_NAME,
     COLUMN_NAME, COLUMN_POSITION, COLUMN_LENGTH,
     CHAR_LENGTH, DESCEND)
as
select io.name, idx.name, bo.name, base.name,
       decode(bitand(c.property, 1024), 1024,
              (select decode(bitand(tc.property, 1), 1, ac.name, tc.name)
              from sys.col$ tc, attrcol$ ac
              where tc.intcol# = c.intcol#-1
                and tc.obj# = c.obj#
                and tc.obj# = ac.obj#(+)
                and tc.intcol# = ac.intcol#(+)),
              decode(ac.name, null, c.name, ac.name)),
       ic.pos#, c.length, c.spare3,
       decode(bitand(c.property, 131072), 131072, 'DESC', 'ASC')
from sys.col$ c, sys.obj$ idx, sys.obj$ base, sys.icol$ ic,
     sys.user$ io, sys.user$ bo, sys.ind$ i, sys.attrcol$ ac
where ic.bo# = c.obj#
  and decode(bitand(i.property,1024),0,ic.intcol#,ic.spare2) = c.intcol#
  and ic.bo# = base.obj#
  and io.user# = idx.owner#
  and bo.user# = base.owner#
  and ic.obj# = idx.obj#
  and idx.obj# = i.obj#
  and i.type# in (1, 2, 3, 4, 6, 7, 9)
  and c.obj# = ac.obj#(+)
  and c.intcol# = ac.intcol#(+)
  and (idx.owner# = userenv('SCHEMAID') or
       base.owner# = userenv('SCHEMAID')
       or
       base.obj# in ( select obj#
                     from sys.objauth$
                     where grantee# in ( select kzsrorol
                                         from x$kzsro
                                       )
                   )
        or
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
       )
/
comment on table ALL_IND_COLUMNS is
'COLUMNs comprising INDEXes on accessible TABLES'
/
comment on column ALL_IND_COLUMNS.INDEX_OWNER is
'Index owner'
/
comment on column ALL_IND_COLUMNS.INDEX_NAME is
'Index name'
/
comment on column ALL_IND_COLUMNS.TABLE_OWNER is
'Table or cluster owner'
/
comment on column ALL_IND_COLUMNS.TABLE_NAME is
'Table or cluster name'
/
comment on column ALL_IND_COLUMNS.COLUMN_NAME is
'Column name or attribute of object column'
/
comment on column ALL_IND_COLUMNS.COLUMN_POSITION is
'Position of column or attribute within index'
/
comment on column ALL_IND_COLUMNS.COLUMN_LENGTH is
'Maximum length of the column or attribute, in bytes'
/
comment on column ALL_IND_COLUMNS.CHAR_LENGTH is
'Maximum length of the column or attribute, in characters'
/
comment on column ALL_IND_COLUMNS.DESCEND is
'DESC if this column is sorted in descending order on disk, otherwise ASC'
/
create or replace public synonym ALL_IND_COLUMNS for ALL_IND_COLUMNS
/
grant select on ALL_IND_COLUMNS to PUBLIC with grant option
/
create or replace view DBA_IND_COLUMNS
    (INDEX_OWNER, INDEX_NAME,
     TABLE_OWNER, TABLE_NAME,
     COLUMN_NAME, COLUMN_POSITION, COLUMN_LENGTH,
     CHAR_LENGTH, DESCEND)
as
select io.name, idx.name, bo.name, base.name,
       decode(bitand(c.property, 1024), 1024,
              (select decode(bitand(tc.property, 1), 1, ac.name, tc.name)
              from sys.col$ tc, attrcol$ ac
              where tc.intcol# = c.intcol#-1
                and tc.obj# = c.obj#
                and tc.obj# = ac.obj#(+)
                and tc.intcol# = ac.intcol#(+)),
              decode(ac.name, null, c.name, ac.name)),
       ic.pos#, c.length, c.spare3,
       decode(bitand(c.property, 131072), 131072, 'DESC', 'ASC')
from sys.col$ c, sys.obj$ idx, sys.obj$ base, sys.icol$ ic,
     sys.user$ io, sys.user$ bo, sys.ind$ i, sys.attrcol$ ac
where ic.bo# = c.obj#
  and decode(bitand(i.property,1024),0,ic.intcol#,ic.spare2) = c.intcol#
  and ic.bo# = base.obj#
  and io.user# = idx.owner#
  and bo.user# = base.owner#
  and ic.obj# = idx.obj#
  and idx.obj# = i.obj#
  and i.type# in (1, 2, 3, 4, 6, 7, 9)
  and c.obj# = ac.obj#(+)
  and c.intcol# = ac.intcol#(+)
/
create or replace public synonym DBA_IND_COLUMNS for DBA_IND_COLUMNS
/
grant select on DBA_IND_COLUMNS to select_catalog_role
/
comment on table DBA_IND_COLUMNS is
'COLUMNs comprising INDEXes on all TABLEs and CLUSTERs'
/
comment on column DBA_IND_COLUMNS.INDEX_OWNER is
'Index owner'
/
comment on column DBA_IND_COLUMNS.INDEX_NAME is
'Index name'
/
comment on column DBA_IND_COLUMNS.TABLE_OWNER is
'Table or cluster owner'
/
comment on column DBA_IND_COLUMNS.TABLE_NAME is
'Table or cluster name'
/
comment on column DBA_IND_COLUMNS.COLUMN_NAME is
'Column name or attribute of object column'
/
comment on column DBA_IND_COLUMNS.COLUMN_POSITION is
'Position of column or attribute within index'
/
comment on column DBA_IND_COLUMNS.COLUMN_LENGTH is
'Maximum length of the column or attribute, in bytes'
/
comment on column DBA_IND_COLUMNS.CHAR_LENGTH is
'Maximum length of the column or attribute, in characters'
/
comment on column DBA_IND_COLUMNS.DESCEND is
'DESC if this column is sorted in descending order on disk, otherwise ASC'
/
remark
remark  FAMILY "IND_EXPRESSIONS"
remark  Displays information on which functional index expressions
remark
create or replace view USER_IND_EXPRESSIONS
    (INDEX_NAME, TABLE_NAME, COLUMN_EXPRESSION, COLUMN_POSITION)
as
select idx.name, base.name, c.default$, ic.pos#
from sys.col$ c, sys.obj$ idx, sys.obj$ base, sys.icol$ ic, sys.ind$ i
where bitand(ic.spare1,1) = 1       /* an expression */
  and (bitand(i.property,1024) = 0) /* not bmji */
  and c.obj# = base.obj#
  and ic.bo# = base.obj#
  and ic.intcol# = c.intcol#
  and base.owner# = userenv('SCHEMAID')
  and base.namespace in (1, 5)
  and ic.obj# = idx.obj#
  and idx.obj# = i.obj#
  and i.type# in (1, 2, 3, 4, 6, 7, 9)
union all
select idx.name, base.name, c.default$, ic.pos#
from sys.col$ c, sys.obj$ idx, sys.obj$ base, sys.icol$ ic, sys.ind$ i
where bitand(ic.spare1,1) = 1       /* an expression */
  and (bitand(i.property,1024) = 0) /* not bmji */
  and c.obj# = base.obj#
  and i.bo# = base.obj#
  and base.owner# != userenv('SCHEMAID')
  and ic.intcol# = c.intcol#
  and idx.owner# = userenv('SCHEMAID')
  and idx.namespace = 4 /* index namespace */
  and ic.obj# = idx.obj#
  and idx.obj# = i.obj#
  and i.type# in (1, 2, 3, 4, 6, 7, 9)
/
comment on table USER_IND_EXPRESSIONS is
'Functional index expressions in user''s indexes and indexes on user''s tables'
/
comment on column USER_IND_EXPRESSIONS.INDEX_NAME is
'Index name'
/
comment on column USER_IND_EXPRESSIONS.TABLE_NAME is
'Table or cluster name'
/
comment on column USER_IND_EXPRESSIONS.COLUMN_EXPRESSION is
'Functional index expression defining the column'
/
comment on column USER_IND_EXPRESSIONS.COLUMN_POSITION is
'Position of column or attribute within index'
/
create or replace public synonym USER_IND_EXPRESSIONS for USER_IND_EXPRESSIONS
/
grant select on USER_IND_EXPRESSIONS to PUBLIC with grant option
/
create or replace view ALL_IND_EXPRESSIONS
    (INDEX_OWNER, INDEX_NAME,
     TABLE_OWNER, TABLE_NAME, COLUMN_EXPRESSION, COLUMN_POSITION)
as
select io.name, idx.name, bo.name, base.name, c.default$, ic.pos#
from sys.col$ c, sys.obj$ idx, sys.obj$ base, sys.icol$ ic,
     sys.user$ io, sys.user$ bo, sys.ind$ i
where bitand(ic.spare1,1) = 1       /* an expression */
  and (bitand(i.property,1024) = 0) /* not bmji */
  and ic.bo# = c.obj#
  and ic.intcol# = c.intcol#
  and ic.bo# = base.obj#
  and io.user# = idx.owner#
  and bo.user# = base.owner#
  and ic.obj# = idx.obj#
  and idx.obj# = i.obj#
  and i.type# in (1, 2, 3, 4, 6, 7, 9)
  and (idx.owner# = userenv('SCHEMAID') or
       base.owner# = userenv('SCHEMAID')
       or
       base.obj# in ( select obj#
                     from sys.objauth$
                     where grantee# in ( select kzsrorol
                                         from x$kzsro
                                       )
                   )
        or
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
       )
/
comment on table ALL_IND_EXPRESSIONS is
'FUNCTIONAL INDEX EXPRESSIONs on accessible TABLES'
/
comment on column ALL_IND_EXPRESSIONS.INDEX_OWNER is
'Index owner'
/
comment on column ALL_IND_EXPRESSIONS.INDEX_NAME is
'Index name'
/
comment on column ALL_IND_EXPRESSIONS.TABLE_OWNER is
'Table or cluster owner'
/
comment on column ALL_IND_EXPRESSIONS.TABLE_NAME is
'Table or cluster name'
/
comment on column ALL_IND_EXPRESSIONS.COLUMN_EXPRESSION is
'Functional index expression defining the column'
/
comment on column ALL_IND_EXPRESSIONS.COLUMN_POSITION is
'Position of column or attribute within index'
/
create or replace public synonym ALL_IND_EXPRESSIONS for ALL_IND_EXPRESSIONS
/
grant select on ALL_IND_EXPRESSIONS to PUBLIC with grant option
/
create or replace view DBA_IND_EXPRESSIONS
    (INDEX_OWNER, INDEX_NAME,
     TABLE_OWNER, TABLE_NAME, COLUMN_EXPRESSION, COLUMN_POSITION)
as
select io.name, idx.name, bo.name, base.name, c.default$, ic.pos#
from sys.col$ c, sys.obj$ idx, sys.obj$ base, sys.icol$ ic,
     sys.user$ io, sys.user$ bo, sys.ind$ i
where bitand(ic.spare1,1) = 1       /* an expression */
  and (bitand(i.property,1024) = 0) /* not bmji */
  and ic.bo# = c.obj#
  and ic.intcol# = c.intcol#
  and ic.bo# = base.obj#
  and io.user# = idx.owner#
  and bo.user# = base.owner#
  and ic.obj# = idx.obj#
  and idx.obj# = i.obj#
  and i.type# in (1, 2, 3, 4, 6, 7, 9)
/
create or replace public synonym DBA_IND_EXPRESSIONS for DBA_IND_EXPRESSIONS
/
grant select on DBA_IND_EXPRESSIONS to select_catalog_role
/
comment on table DBA_IND_EXPRESSIONS is
'FUNCTIONAL INDEX EXPRESSIONs on all TABLES and CLUSTERS'
/
comment on column DBA_IND_EXPRESSIONS.INDEX_OWNER is
'Index owner'
/
comment on column DBA_IND_EXPRESSIONS.INDEX_NAME is
'Index name'
/
comment on column DBA_IND_EXPRESSIONS.TABLE_OWNER is
'Table or cluster owner'
/
comment on column DBA_IND_EXPRESSIONS.TABLE_NAME is
'Table or cluster name'
/
comment on column DBA_IND_EXPRESSIONS.COLUMN_EXPRESSION is
'Functional index expression defining the column'
/
comment on column DBA_IND_EXPRESSIONS.COLUMN_POSITION is
'Position of column or attribute within index'
/

create or replace view INDEX_STATS as
 select kdxstrot+1      height,
        kdxstsbk        blocks,
        o.name,
        o.subname       partition_name,
        kdxstlrw        lf_rows,
        kdxstlbk        lf_blks,
        kdxstlln        lf_rows_len,
        kdxstlub        lf_blk_len,
        kdxstbrw        br_rows,
        kdxstbbk        br_blks,
        kdxstbln        br_rows_len,
        kdxstbub        br_blk_len,
        kdxstdrw        del_lf_rows,
        kdxstdln        del_lf_rows_len,
        kdxstdis        distinct_keys,
        kdxstmrl        most_repeated_key,
        kdxstlbk*kdxstlub+kdxstbbk*kdxstbub     btree_space,
        kdxstlln+kdxstbln+kdxstpln              used_space,
        ceil(((kdxstlln+kdxstbln+kdxstpln)*100)/
        (kdxstlbk*kdxstlub+kdxstbbk*kdxstbub))
                                                pct_used,
        kdxstlrw/decode(kdxstdis, 0, 1, kdxstdis) rows_per_key,
        kdxstrot+1+(kdxstlrw+kdxstdis)/(decode(kdxstdis, 0, 1, kdxstdis)*2)
                                                blks_gets_per_access,
        kdxstnpr        pre_rows,
        kdxstpln        pre_rows_len,
        kdxstokc        opt_cmpr_count,
        kdxstpsk        opt_cmpr_pctsave
  from obj$ o, ind$ i, seg$ s, x$kdxst
 where kdxstobj = o.obj# and kdxstfil = s.file#
  and  kdxstblk = s.block#
  and  kdxsttsn = s.ts#
  and  s.file#  = i.file#
  and  s.block# = i.block#
  and  s.ts# = i.ts#
  and  i.obj#   = o.obj#
union all
 select kdxstrot+1      height,
        kdxstsbk        blocks,
        o.name,
        o.subname       partition_name,
        kdxstlrw        lf_rows,
        kdxstlbk        lf_blks,
        kdxstlln        lf_rows_len,
        kdxstlub        lf_blk_len,
        kdxstbrw        br_rows,
        kdxstbbk        br_blks,
        kdxstbln        br_rows_len,
        kdxstbub        br_blk_len,
        kdxstdrw        del_lf_rows,
        kdxstdln        del_lf_rows_len,
        kdxstdis        distinct_keys,
        kdxstmrl        most_repeated_key,
        kdxstlbk*kdxstlub+kdxstbbk*kdxstbub     btree_space,
        kdxstlln+kdxstbln+kdxstpln              used_space,
        ceil(((kdxstlln+kdxstbln)*100)/
        (kdxstlbk*kdxstlub+kdxstbbk*kdxstbub))
                                                pct_used,
        kdxstlrw/decode(kdxstdis, 0, 1, kdxstdis) rows_per_key,
        kdxstrot+1+(kdxstlrw+kdxstdis)/(decode(kdxstdis, 0, 1, kdxstdis)*2)
                                                blks_gets_per_access,
        kdxstnpr        pre_rows,
        kdxstpln        pre_rows_len,
        kdxstokc        opt_cmpr_count,
        kdxstpsk        opt_cmpr_pctsave
  from obj$ o, seg$ s, indpart$ ip, x$kdxst
 where kdxstobj = o.obj# and kdxstfil = s.file#
  and  kdxstblk = s.block#
  and  kdxsttsn = s.ts#
  and  s.file#  = ip.file#
  and  s.block# = ip.block#
  and  s.ts#    = ip.ts#
  and  ip.obj#  = o.obj#
union all
 select kdxstrot+1      height,
        kdxstsbk        blocks,
        o.name,
        o.subname       partition_name,
        kdxstlrw        lf_rows,
        kdxstlbk        lf_blks,
        kdxstlln        lf_rows_len,
        kdxstlub        lf_blk_len,
        kdxstbrw        br_rows,
        kdxstbbk        br_blks,
        kdxstbln        br_rows_len,
        kdxstbub        br_blk_len,
        kdxstdrw        del_lf_rows,
        kdxstdln        del_lf_rows_len,
        kdxstdis        distinct_keys,
        kdxstmrl        most_repeated_key,
        kdxstlbk*kdxstlub+kdxstbbk*kdxstbub     btree_space,
        kdxstlln+kdxstbln+kdxstpln              used_space,
        ceil(((kdxstlln+kdxstbln)*100)/
        (kdxstlbk*kdxstlub+kdxstbbk*kdxstbub))
                                                pct_used,
        kdxstlrw/decode(kdxstdis, 0, 1, kdxstdis) rows_per_key,
        kdxstrot+1+(kdxstlrw+kdxstdis)/(decode(kdxstdis, 0, 1, kdxstdis)*2)
                                                blks_gets_per_access,
        kdxstnpr        pre_rows,
        kdxstpln        pre_rows_len,
        kdxstokc        opt_cmpr_count,
        kdxstpsk        opt_cmpr_pctsave
  from obj$ o, seg$ s, indsubpart$ isp, x$kdxst
 where kdxstobj = o.obj# and kdxstfil = s.file#
  and  kdxstblk = s.block#
  and  kdxsttsn = s.ts#
  and  s.file#  = isp.file#
  and  s.block# = isp.block#
  and  s.ts#    = isp.ts#
  and  isp.obj#  = o.obj#
/
comment on table INDEX_STATS is
'statistics on the b-tree'
/
comment on column index_stats.height is
'height of the b-tree'
/
comment on column index_stats.blocks is
'blocks allocated to the segment'
/
comment on column index_stats.name is
'name of the index'
/
comment on column index_stats.partition_name is
'name of the index partition, if partitioned'
/
comment on column index_stats.lf_rows is
'number of leaf rows (values in the index)'
/
comment on column index_stats.lf_blks is
'number of leaf blocks in the b-tree'
/
comment on column index_stats.lf_rows_len is
'sum of the lengths of all the leaf rows'
/
comment on column index_stats.lf_blk_len is
'useable space in a leaf block'
/
comment on column index_stats.br_rows is
'number of branch rows'
/
comment on column index_stats.br_blks is
'number of branch blocks in the b-tree'
/
comment on column index_stats.br_rows_len is
'sum of the lengths of all the branch blocks in the b-tree'
/
comment on column index_stats.br_blk_len is
'useable space in a branch block'
/
comment on column index_stats.del_lf_rows is
'number of deleted leaf rows in the index'
/
comment on column index_stats.del_lf_rows_len is
'total length of all deleted rows in the index'
/
comment on column index_stats.distinct_keys is
'number of distinct keys in the index'
/
comment on column index_stats.most_repeated_key is
'how many times the most repeated key is repeated'
/
comment on column index_stats.btree_space is
'total space currently allocated in the b-tree'
/
comment on column index_stats.used_space is
'total space that is currently being used in the b-tree'
/
comment on column index_stats.pct_used is
'percent of space allocated in the b-tree that is being used'
/
comment on column index_stats.rows_per_key is
'average number of rows per distinct key'
/
comment on column index_stats.blks_gets_per_access is
'Expected number of consistent mode block gets per row. This assumes that a row chosen at random from the table is being searched for using the index'
/
comment on column index_stats.pre_rows is
'number of prefix rows (values in the index)'
/
comment on column index_stats.pre_rows_len is
'sum of lengths of all prefix rows'
/
comment on column index_stats.opt_cmpr_count is
'optimal prefix compression count for the index'
/
comment on column index_stats.opt_cmpr_pctsave is
'percentage storage saving expected from optimal prefix compression'
/
create or replace public synonym INDEX_STATS for INDEX_STATS
/
grant select on INDEX_STATS to public with grant option
/
create or replace view INDEX_HISTOGRAM as
 select hist.indx * power(2, stats.kdxstscl-4)  repeat_count,
        hist.kdxhsval                           keys_with_repeat_count
        from  x$kdxst stats, x$kdxhs hist
/
comment on table INDEX_HISTOGRAM is
'statistics on keys with repeat count'
/
comment on column index_histogram.repeat_count is
'number of times that a key is repeated'
/
comment on column index_histogram.keys_with_repeat_count is
'number of keys that are repeated REPEAT_COUNT times'
/
create or replace public synonym INDEX_HISTOGRAM for INDEX_HISTOGRAM
/
grant select on INDEX_HISTOGRAM to public with grant option
/

remark
remark  FAMILY "JOIN_IND_COLUMNS"
remark  Displays information on the join conditions of join
remark  indexes
remark
create or replace view USER_JOIN_IND_COLUMNS
    (INDEX_NAME,
     INNER_TABLE_OWNER, INNER_TABLE_NAME, INNER_TABLE_COLUMN,
     OUTER_TABLE_OWNER, OUTER_TABLE_NAME, OUTER_TABLE_COLUMN)
as
select
  oi.name,
  uti.name, oti.name, ci.name,
  uto.name, oto.name, co.name
from
  sys.user$ uti, sys.user$ uto,
  sys.obj$ oi, sys.obj$ oti, sys.obj$ oto,
  sys.col$ ci, sys.col$ co,
  sys.jijoin$ ji
where ji.obj# = oi.obj#
  and ji.tab1obj# = oti.obj#
  and oti.owner# = uti.user#
  and ci.obj# = oti.obj#
  and ji.tab1col# = ci.intcol#
  and ji.tab2obj# = oto.obj#
  and oto.owner# = uto.user#
  and co.obj# = oto.obj#
  and ji.tab2col# = co.intcol#
  and oi.owner# = userenv('SCHEMAID')
/
comment on table USER_JOIN_IND_COLUMNS is
'Join Index columns comprising the join conditions'
/
comment on column USER_JOIN_IND_COLUMNS.INDEX_NAME is
'Index name'
/
comment on column USER_JOIN_IND_COLUMNS.INNER_TABLE_OWNER is
'Table owner of inner table (table closer to the fact table)'
/
comment on column USER_JOIN_IND_COLUMNS.INNER_TABLE_NAME is
'Table name of inner table (table closer to the fact table)'
/
comment on column USER_JOIN_IND_COLUMNS.INNER_TABLE_COLUMN is
'Column name of inner table (table closer to the fact table)'
/
comment on column USER_JOIN_IND_COLUMNS.OUTER_TABLE_OWNER is
'Table owner of outer table (table closer to the fact table)'
/
comment on column USER_JOIN_IND_COLUMNS.OUTER_TABLE_NAME is
'Table name of outer table (table closer to the fact table)'
/
comment on column USER_JOIN_IND_COLUMNS.OUTER_TABLE_COLUMN is
'Column name of outer table (table closer to the fact table)'
/
create or replace public synonym USER_JOIN_IND_COLUMNS for USER_JOIN_IND_COLUMNS
/
grant select on USER_JOIN_IND_COLUMNS to PUBLIC with grant option
/
create or replace view ALL_JOIN_IND_COLUMNS
    (INDEX_OWNER, INDEX_NAME,
     INNER_TABLE_OWNER, INNER_TABLE_NAME, INNER_TABLE_COLUMN,
     OUTER_TABLE_OWNER, OUTER_TABLE_NAME, OUTER_TABLE_COLUMN)
as
select
  ui.name, oi.name,
  uti.name, oti.name, ci.name,
  uto.name, oto.name, co.name
from
  sys.user$ ui, sys.user$ uti, sys.user$ uto,
  sys.obj$ oi, sys.obj$ oti, sys.obj$ oto,
  sys.col$ ci, sys.col$ co,
  sys.jijoin$ ji
where ji.obj# = oi.obj#
  and oi.owner# = ui.user#
  and ji.tab1obj# = oti.obj#
  and oti.owner# = uti.user#
  and ci.obj# = oti.obj#
  and ji.tab1col# = ci.intcol#
  and ji.tab2obj# = oto.obj#
  and oto.owner# = uto.user#
  and co.obj# = oto.obj#
  and ji.tab2col# = co.intcol#
  and (oi.owner# = userenv('SCHEMAID')
        or
       oti.owner# = userenv('SCHEMAID')
        or
       oto.owner# = userenv('SCHEMAID')
        or
       oti.obj# in ( select obj#
                    from sys.objauth$
                    where grantee# in ( select kzsrorol
                                        from x$kzsro
                                      )
                   )
        or
       oto.obj# in ( select obj#
                    from sys.objauth$
                    where grantee# in ( select kzsrorol
                                        from x$kzsro
                                      )
                   )
        or
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
       )
/
comment on table ALL_JOIN_IND_COLUMNS is
'Join Index columns comprising the join conditions'
/
comment on column ALL_JOIN_IND_COLUMNS.INDEX_OWNER is
'Index owner'
/
comment on column ALL_JOIN_IND_COLUMNS.INDEX_NAME is
'Index name'
/
comment on column ALL_JOIN_IND_COLUMNS.INNER_TABLE_OWNER is
'Table owner of inner table (table closer to the fact table)'
/
comment on column ALL_JOIN_IND_COLUMNS.INNER_TABLE_NAME is
'Table name of inner table (table closer to the fact table)'
/
comment on column ALL_JOIN_IND_COLUMNS.INNER_TABLE_COLUMN is
'Column name of inner table (table closer to the fact table)'
/
comment on column ALL_JOIN_IND_COLUMNS.OUTER_TABLE_OWNER is
'Table owner of outer table (table closer to the fact table)'
/
comment on column ALL_JOIN_IND_COLUMNS.OUTER_TABLE_NAME is
'Table name of outer table (table closer to the fact table)'
/
comment on column ALL_JOIN_IND_COLUMNS.OUTER_TABLE_COLUMN is
'Column name of outer table (table closer to the fact table)'
/
create or replace public synonym ALL_JOIN_IND_COLUMNS for ALL_JOIN_IND_COLUMNS
/
grant select on ALL_JOIN_IND_COLUMNS to PUBLIC with grant option
/
create or replace view DBA_JOIN_IND_COLUMNS
    (INDEX_OWNER, INDEX_NAME,
     INNER_TABLE_OWNER, INNER_TABLE_NAME, INNER_TABLE_COLUMN,
     OUTER_TABLE_OWNER, OUTER_TABLE_NAME, OUTER_TABLE_COLUMN)
as
select
  ui.name, oi.name,
  uti.name, oti.name, ci.name,
  uto.name, oto.name, co.name
from
  sys.user$ ui, sys.user$ uti, sys.user$ uto,
  sys.obj$ oi, sys.obj$ oti, sys.obj$ oto,
  sys.col$ ci, sys.col$ co,
  sys.jijoin$ ji
where ji.obj# = oi.obj#
  and oi.owner# = ui.user#
  and ji.tab1obj# = oti.obj#
  and oti.owner# = uti.user#
  and ci.obj# = oti.obj#
  and ji.tab1col# = ci.intcol#
  and ji.tab2obj# = oto.obj#
  and oto.owner# = uto.user#
  and co.obj# = oto.obj#
  and ji.tab2col# = co.intcol#
/
comment on table DBA_JOIN_IND_COLUMNS is
'Join Index columns comprising the join conditions'
/
comment on column DBA_JOIN_IND_COLUMNS.INDEX_OWNER is
'Index owner'
/
comment on column DBA_JOIN_IND_COLUMNS.INDEX_NAME is
'Index name'
/
comment on column DBA_JOIN_IND_COLUMNS.INNER_TABLE_OWNER is
'Table owner of inner table (table closer to the fact table)'
/
comment on column DBA_JOIN_IND_COLUMNS.INNER_TABLE_NAME is
'Table name of inner table (table closer to the fact table)'
/
comment on column DBA_JOIN_IND_COLUMNS.INNER_TABLE_COLUMN is
'Column name of inner table (table closer to the fact table)'
/
comment on column DBA_JOIN_IND_COLUMNS.OUTER_TABLE_OWNER is
'Table owner of outer table (table closer to the fact table)'
/
comment on column DBA_JOIN_IND_COLUMNS.OUTER_TABLE_NAME is
'Table name of outer table (table closer to the fact table)'
/
comment on column DBA_JOIN_IND_COLUMNS.OUTER_TABLE_COLUMN is
'Column name of outer table (table closer to the fact table)'
/
create or replace public synonym DBA_JOIN_IND_COLUMNS for DBA_JOIN_IND_COLUMNS
/
grant select on DBA_JOIN_IND_COLUMNS to select_catalog_role
/

remark
remark  FAMILY "OBJECTS"
remark  List of objects, including creation and modify times.
remark
create or replace view USER_OBJECTS
    (OBJECT_NAME, SUBOBJECT_NAME, OBJECT_ID, DATA_OBJECT_ID, OBJECT_TYPE,
     CREATED, LAST_DDL_TIME, TIMESTAMP, STATUS, TEMPORARY, GENERATED,
     SECONDARY)
as
select o.name, o.subname, o.obj#, o.dataobj#,
       decode(o.type#, 0, 'NEXT OBJECT', 1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER',
                      4, 'VIEW', 5, 'SYNONYM', 6, 'SEQUENCE',
                      7, 'PROCEDURE', 8, 'FUNCTION', 9, 'PACKAGE',
                      11, 'PACKAGE BODY', 12, 'TRIGGER',
                      13, 'TYPE', 14, 'TYPE BODY',
                      19, 'TABLE PARTITION', 20, 'INDEX PARTITION', 21, 'LOB',
                      22, 'LIBRARY', 23, 'DIRECTORY',  24, 'QUEUE',
                      28, 'JAVA SOURCE', 29, 'JAVA CLASS', 30, 'JAVA RESOURCE',
                      32, 'INDEXTYPE', 33, 'OPERATOR',
                      34, 'TABLE SUBPARTITION', 35, 'INDEX SUBPARTITION',
                      40, 'LOB PARTITION', 41, 'LOB SUBPARTITION',
                      42, NVL((SELECT distinct 'REWRITE EQUIVALENCE'
                               FROM sum$ s
                               WHERE s.obj#=o.obj#
                                     and bitand(s.xpflags, 8388608) = 8388608),
                              'MATERIALIZED VIEW'),
                      43, 'DIMENSION',
                      44, 'CONTEXT', 46, 'RULE SET', 47, 'RESOURCE PLAN',
                      48, 'CONSUMER GROUP',
                      51, 'SUBSCRIPTION', 52, 'LOCATION',
                      55, 'XML SCHEMA', 56, 'JAVA DATA',
                      57, 'SECURITY PROFILE', 59, 'RULE',
                      60, 'CAPTURE', 61, 'APPLY',
                      62, 'EVALUATION CONTEXT',
                      66, 'JOB', 67, 'PROGRAM', 68, 'JOB CLASS', 69, 'WINDOW',
                      72, 'WINDOW GROUP', 74, 'SCHEDULE', 79, 'CHAIN',
                      81, 'FILE GROUP',
                     'UNDEFINED'),
       o.ctime, o.mtime,
       to_char(o.stime, 'YYYY-MM-DD:HH24:MI:SS'),
       decode(o.status, 0, 'N/A', 1, 'VALID', 'INVALID'),
       decode(bitand(o.flags, 2), 0, 'N', 2, 'Y', 'N'),
       decode(bitand(o.flags, 4), 0, 'N', 4, 'Y', 'N'),
       decode(bitand(o.flags, 16), 0, 'N', 16, 'Y', 'N')
from sys.obj$ o
where o.owner# = userenv('SCHEMAID')
  and o.linkname is null
  and (o.type# not in (1  /* INDEX - handled below */,
                      10 /* NON-EXISTENT */)
       or
       (o.type# = 1 and 1 = (select 1
                             from sys.ind$ i
                            where i.obj# = o.obj#
                              and i.type# in (1, 2, 3, 4, 6, 7, 9))))
  and o.name != '_NEXT_OBJECT'
  and o.name != '_default_auditing_options_'
union all
select l.name, NULL, to_number(null), to_number(null),
       'DATABASE LINK',
       l.ctime, to_date(null), NULL, 'VALID', 'N', 'N', 'N'
from sys.link$ l
where l.owner# = userenv('SCHEMAID')
/
comment on table USER_OBJECTS is
'Objects owned by the user'
/
comment on column USER_OBJECTS.OBJECT_NAME is
'Name of the object'
/
comment on column USER_OBJECTS.SUBOBJECT_NAME is
'Name of the sub-object (for example, partititon)'
/
comment on column USER_OBJECTS.OBJECT_ID is
'Object number of the object'
/
comment on column USER_OBJECTS.DATA_OBJECT_ID is
'Object number of the segment which contains the object'
/
comment on column USER_OBJECTS.OBJECT_TYPE is
'Type of the object'
/
comment on column USER_OBJECTS.CREATED is
'Timestamp for the creation of the object'
/
comment on column USER_OBJECTS.LAST_DDL_TIME is
'Timestamp for the last DDL change (including GRANT and REVOKE) to the object'
/
comment on column USER_OBJECTS.TIMESTAMP is
'Timestamp for the specification of the object'
/
comment on column USER_OBJECTS.STATUS is
'Status of the object'
/
comment on column USER_OBJECTS.TEMPORARY is
'Can the current session only see data that it place in this object itself?'
/
comment on column USER_OBJECTS.GENERATED is
'Was the name of this object system generated?'
/
comment on column USER_OBJECTS.SECONDARY is
'Is this a secondary object created as part of icreate for domain indexes?'
/

create or replace public synonym USER_OBJECTS for USER_OBJECTS
/
create or replace public synonym OBJ for USER_OBJECTS
/
grant select on USER_OBJECTS to PUBLIC with grant option
/
create or replace view ALL_OBJECTS
    (OWNER, OBJECT_NAME, SUBOBJECT_NAME, OBJECT_ID, DATA_OBJECT_ID,
     OBJECT_TYPE, CREATED, LAST_DDL_TIME, TIMESTAMP, STATUS,
     TEMPORARY, GENERATED, SECONDARY)
as
select u.name, o.name, o.subname, o.obj#, o.dataobj#,
       decode(o.type#, 0, 'NEXT OBJECT', 1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER',
                      4, 'VIEW', 5, 'SYNONYM', 6, 'SEQUENCE',
                      7, 'PROCEDURE', 8, 'FUNCTION', 9, 'PACKAGE',
                      11, 'PACKAGE BODY', 12, 'TRIGGER',
                      13, 'TYPE', 14, 'TYPE BODY',
                      19, 'TABLE PARTITION', 20, 'INDEX PARTITION', 21, 'LOB',
                      22, 'LIBRARY', 23, 'DIRECTORY', 24, 'QUEUE',
                      28, 'JAVA SOURCE', 29, 'JAVA CLASS', 30, 'JAVA RESOURCE',
                      32, 'INDEXTYPE', 33, 'OPERATOR',
                      34, 'TABLE SUBPARTITION', 35, 'INDEX SUBPARTITION',
                      40, 'LOB PARTITION', 41, 'LOB SUBPARTITION',
                      42, NVL((SELECT distinct 'REWRITE EQUIVALENCE'
                               FROM sum$ s
                               WHERE s.obj#=o.obj#
                                     and bitand(s.xpflags, 8388608) = 8388608),
                              'MATERIALIZED VIEW'),
                      43, 'DIMENSION',
                      44, 'CONTEXT', 46, 'RULE SET', 47, 'RESOURCE PLAN',
                      48, 'CONSUMER GROUP',
                      55, 'XML SCHEMA', 56, 'JAVA DATA',
                      57, 'SECURITY PROFILE', 59, 'RULE',
                      60, 'CAPTURE', 61, 'APPLY',
                      62, 'EVALUATION CONTEXT',
                      66, 'JOB', 67, 'PROGRAM', 68, 'JOB CLASS', 69, 'WINDOW',
                      72, 'WINDOW GROUP', 74, 'SCHEDULE', 79, 'CHAIN',
                      81, 'FILE GROUP',
                     'UNDEFINED'),
       o.ctime, o.mtime,
       to_char(o.stime, 'YYYY-MM-DD:HH24:MI:SS'),
       decode(o.status, 0, 'N/A', 1, 'VALID', 'INVALID'),
       decode(bitand(o.flags, 2), 0, 'N', 2, 'Y', 'N'),
       decode(bitand(o.flags, 4), 0, 'N', 4, 'Y', 'N'),
       decode(bitand(o.flags, 16), 0, 'N', 16, 'Y', 'N')
from sys.obj$ o, sys.user$ u
where o.owner# = u.user#
  and o.linkname is null
  and (o.type# not in (1  /* INDEX - handled below */,
                      10 /* NON-EXISTENT */)
       or
       (o.type# = 1 and 1 = (select 1
                             from sys.ind$ i
                            where i.obj# = o.obj#
                              and i.type# in (1, 2, 3, 4, 6, 7, 9))))
  and o.name != '_NEXT_OBJECT'
  and o.name != '_default_auditing_options_'
  and
  (
    o.owner# in (userenv('SCHEMAID'), 1 /* PUBLIC */)
    or
    (
      /* EXECUTE privilege does not let user see package/type body */
      o.type# != 11 and o.type# != 14
      and
      o.obj# in (select obj# from sys.objauth$
                 where grantee# in (select kzsrorol from x$kzsro)
                   and privilege# in (3 /* DELETE */,   6 /* INSERT */,
                                      7 /* LOCK */,     9 /* SELECT */,
                                      10 /* UPDATE */, 12 /* EXECUTE */,
                                      11 /* USAGE */,  16 /* CREATE */,
                                      17 /* READ */,   18 /* WRITE  */ ))
    )
    or
    (
       o.type# in (7, 8, 9, 28, 29, 30, 56) /* prc, fcn, pkg */
       and
       exists (select null from v$enabledprivs
               where priv_number in (
                                      -144 /* EXECUTE ANY PROCEDURE */,
                                      -141 /* CREATE ANY PROCEDURE */
                                    )
              )
    )
    or
    (
       o.type# in (12) /* trigger */
       and
       exists (select null from v$enabledprivs
               where priv_number in (
                                      -152 /* CREATE ANY TRIGGER */
                                    )
              )
    )
    or
    (
       o.type# = 11 /* pkg body */
       and
       exists (select null from v$enabledprivs
               where priv_number =   -141 /* CREATE ANY PROCEDURE */
              )
    )
    or
    (
       o.type# in (22) /* library */
       and
       exists (select null from v$enabledprivs
               where priv_number in (
                                      -189 /* CREATE ANY LIBRARY */,
                                      -190 /* ALTER ANY LIBRARY */,
                                      -191 /* DROP ANY LIBRARY */,
                                      -192 /* EXECUTE ANY LIBRARY */
                                    )
              )
    )
    or
    (
       /* index, table, view, synonym, table partn, indx partn, */
       /* table subpartn, index subpartn, cluster               */
       o.type# in (1, 2, 3, 4, 5, 19, 20, 34, 35)
       and
       exists (select null from v$enabledprivs
               where priv_number in (-45 /* LOCK ANY TABLE */,
                                     -47 /* SELECT ANY TABLE */,
                                     -48 /* INSERT ANY TABLE */,
                                     -49 /* UPDATE ANY TABLE */,
                                     -50 /* DELETE ANY TABLE */)
               )
    )
    or
    ( o.type# = 6 /* sequence */
      and
      exists (select null from v$enabledprivs
              where priv_number = -109 /* SELECT ANY SEQUENCE */)
    )
    or
    ( o.type# = 13 /* type */
      and
      exists (select null from v$enabledprivs
              where priv_number in (-184 /* EXECUTE ANY TYPE */,
                                    -181 /* CREATE ANY TYPE */))
    )
    or
    (
      o.type# = 14 /* type body */
      and
      exists (select null from v$enabledprivs
              where priv_number = -181 /* CREATE ANY TYPE */)
    )
    or
    (
       o.type# = 23 /* directory */
       and
       exists (select null from v$enabledprivs
               where priv_number in (
                                      -177 /* CREATE ANY DIRECTORY */,
                                      -178 /* DROP ANY DIRECTORY */
                                    )
              )
    )
    or
    (
       o.type# = 42 /* summary jjf table privs have to change to summary */
       and
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
    )
    or
    (
      o.type# = 32   /* indextype */
      and
      exists (select null from v$enabledprivs
               where priv_number in (
                                      -205  /* CREATE INDEXTYPE */ ,
                                      -206  /* CREATE ANY INDEXTYPE */ ,
                                      -207  /* ALTER ANY INDEXTYPE */ ,
                                      -208  /* DROP ANY INDEXTYPE */
                                    )
             )
    )
    or
    (
      o.type# = 33   /* operator */
      and
      exists (select null from v$enabledprivs
               where priv_number in (
                                      -200  /* CREATE OPERATOR */ ,
                                      -201  /* CREATE ANY OPERATOR */ ,
                                      -202  /* ALTER ANY OPERATOR */ ,
                                      -203  /* DROP ANY OPERATOR */ ,
                                      -204  /* EXECUTE OPERATOR */
                                    )
             )
    )
    or
    (
      o.type# = 44   /* context */
      and
      exists (select null from v$enabledprivs
               where priv_number in (
                                      -222  /* CREATE ANY CONTEXT */,
                                      -223  /* DROP ANY CONTEXT */
                                    )
             )
    )
    or
    (
      o.type# = 48  /* resource consumer group */
      and
      exists (select null from v$enabledprivs
              where priv_number in (12)  /* switch consumer group privilege */
             )
    )
    or
    (
      o.type# = 46 /* rule set */
      and
      exists (select null from v$enabledprivs
               where priv_number in (
                                      -251, /* create any rule set */
                                      -252, /* alter any rule set */
                                      -253, /* drop any rule set */
                                      -254  /* execute any rule set */
                                    )
             )
    )
    or
    (
      o.type# = 55 /* XML schema */
      and
      1 = (select /*+ NO_MERGE */ xml_schema_name_present.is_schema_present(o.name, u2.id2) id1 from (select /*+ NO_MERGE */ userenv('SCHEMAID') id2 from dual) u2)
      /* we need a sub-query instead of the directy invoking
       * xml_schema_name_present, because inside a view even the function
       * arguments are evaluated as definers rights.
       */
    )
    or
    (
      o.type# = 59 /* rule */
      and
      exists (select null from v$enabledprivs
               where priv_number in (
                                      -258, /* create any rule */
                                      -259, /* alter any rule */
                                      -260, /* drop any rule */
                                      -261  /* execute any rule */
                                    )
             )
    )
    or
    (
      o.type# = 62 /* evaluation context */
      and
      exists (select null from v$enabledprivs
               where priv_number in (
                                      -246, /* create any evaluation context */
                                      -247, /* alter any evaluation context */
                                      -248, /* drop any evaluation context */
                                      -249 /* execute any evaluation context */
                                    )
             )
    )
    or
    (
      o.type# = 66 /* scheduler job */
      and
      exists (select null from v$enabledprivs
               where priv_number = -265 /* create any job */
             )
    )
    or
    (
      o.type# IN (67, 79) /* scheduler program or chain */
      and
      exists (select null from v$enabledprivs
               where priv_number in (
                                      -265, /* create any job */
                                      -266 /* execute any program */
                                    )
             )
    )
    or
    (
      o.type# = 68 /* scheduler job class */
      and
      exists (select null from v$enabledprivs
               where priv_number in (
                                      -268, /* manage scheduler */
                                      -267 /* execute any class */
                                    )
             )
    )
    or (o.type# in (69, 72, 74))
    /* scheduler windows, window groups and schedules */
    /* no privileges are needed to view these objects */
    or
    (
      o.type# = 81 /* file group */
      and
      exists (select null from v$enabledprivs
               where priv_number in (
                                       -277, /* manage any file group */
                                       -278  /* read any file group */
                                    )
             )
    )
  )
/

comment on table ALL_OBJECTS is
'Objects accessible to the user'
/
comment on column ALL_OBJECTS.OWNER is
'Username of the owner of the object'
/
comment on column ALL_OBJECTS.OBJECT_NAME is
'Name of the object'
/
comment on column ALL_OBJECTS.SUBOBJECT_NAME is
'Name of the sub-object (for example, partititon)'
/
comment on column ALL_OBJECTS.OBJECT_ID is
'Object number of the object'
/
comment on column ALL_OBJECTS.DATA_OBJECT_ID is
'Object number of the segment which contains the object'
/
comment on column ALL_OBJECTS.OBJECT_TYPE is
'Type of the object'
/
comment on column ALL_OBJECTS.CREATED is
'Timestamp for the creation of the object'
/
comment on column ALL_OBJECTS.LAST_DDL_TIME is
'Timestamp for the last DDL change (including GRANT and REVOKE) to the object'
/
comment on column ALL_OBJECTS.TIMESTAMP is
'Timestamp for the specification of the object'
/
comment on column ALL_OBJECTS.STATUS is
'Status of the object'
/
comment on column ALL_OBJECTS.TEMPORARY is
'Can the current session only see data that it placed in this object itself?'
/
comment on column ALL_OBJECTS.GENERATED is
'Was the name of this object system generated?'
/
comment on column ALL_OBJECTS.SECONDARY is
'Is this a secondary object created as part of icreate for domain indexes?'
/
create or replace public synonym ALL_OBJECTS for ALL_OBJECTS
/
grant select on ALL_OBJECTS to PUBLIC with grant option
/
create or replace view DBA_OBJECTS
    (OWNER, OBJECT_NAME, SUBOBJECT_NAME, OBJECT_ID, DATA_OBJECT_ID,
     OBJECT_TYPE, CREATED, LAST_DDL_TIME, TIMESTAMP, STATUS,
     TEMPORARY, GENERATED, SECONDARY)
as
select u.name, o.name, o.subname, o.obj#, o.dataobj#,
       decode(o.type#, 0, 'NEXT OBJECT', 1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER',
                      4, 'VIEW', 5, 'SYNONYM', 6, 'SEQUENCE',
                      7, 'PROCEDURE', 8, 'FUNCTION', 9, 'PACKAGE',
                      11, 'PACKAGE BODY', 12, 'TRIGGER',
                      13, 'TYPE', 14, 'TYPE BODY',
                      19, 'TABLE PARTITION', 20, 'INDEX PARTITION', 21, 'LOB',
                      22, 'LIBRARY', 23, 'DIRECTORY', 24, 'QUEUE',
                      28, 'JAVA SOURCE', 29, 'JAVA CLASS', 30, 'JAVA RESOURCE',
                      32, 'INDEXTYPE', 33, 'OPERATOR',
                      34, 'TABLE SUBPARTITION', 35, 'INDEX SUBPARTITION',
                      40, 'LOB PARTITION', 41, 'LOB SUBPARTITION',
                      42, NVL((SELECT distinct 'REWRITE EQUIVALENCE'
                               FROM sum$ s
                               WHERE s.obj#=o.obj#
                                     and bitand(s.xpflags, 8388608) = 8388608),
                              'MATERIALIZED VIEW'),
                      43, 'DIMENSION',
                      44, 'CONTEXT', 46, 'RULE SET', 47, 'RESOURCE PLAN',
                      48, 'CONSUMER GROUP',
                      51, 'SUBSCRIPTION', 52, 'LOCATION',
                      55, 'XML SCHEMA', 56, 'JAVA DATA',
                      57, 'SECURITY PROFILE', 59, 'RULE',
                      60, 'CAPTURE', 61, 'APPLY',
                      62, 'EVALUATION CONTEXT',
                      66, 'JOB', 67, 'PROGRAM', 68, 'JOB CLASS', 69, 'WINDOW',
                      72, 'WINDOW GROUP', 74, 'SCHEDULE', 79, 'CHAIN',
                      81, 'FILE GROUP',
                     'UNDEFINED'),
       o.ctime, o.mtime,
       to_char(o.stime, 'YYYY-MM-DD:HH24:MI:SS'),
       decode(o.status, 0, 'N/A', 1, 'VALID', 'INVALID'),
       decode(bitand(o.flags, 2), 0, 'N', 2, 'Y', 'N'),
       decode(bitand(o.flags, 4), 0, 'N', 4, 'Y', 'N'),
       decode(bitand(o.flags, 16), 0, 'N', 16, 'Y', 'N')
from sys.obj$ o, sys.user$ u
where o.owner# = u.user#
  and o.linkname is null
  and (o.type# not in (1  /* INDEX - handled below */,
                      10 /* NON-EXISTENT */)
       or
       (o.type# = 1 and 1 = (select 1
                              from sys.ind$ i
                             where i.obj# = o.obj#
                               and i.type# in (1, 2, 3, 4, 6, 7, 9))))
  and o.name != '_NEXT_OBJECT'
  and o.name != '_default_auditing_options_'
union all
select u.name, l.name, NULL, to_number(null), to_number(null),
       'DATABASE LINK',
       l.ctime, to_date(null), NULL, 'VALID','N','N', 'N'
from sys.link$ l, sys.user$ u
where l.owner# = u.user#
/
create or replace public synonym DBA_OBJECTS for DBA_OBJECTS
/
grant select on DBA_OBJECTS to select_catalog_role
/
comment on table DBA_OBJECTS is
'All objects in the database'
/
comment on column DBA_OBJECTS.OWNER is
'Username of the owner of the object'
/
comment on column DBA_OBJECTS.OBJECT_NAME is
'Name of the object'
/
comment on column DBA_OBJECTS.SUBOBJECT_NAME is
'Name of the sub-object (for example, partititon)'
/
comment on column DBA_OBJECTS.OBJECT_ID is
'Object number of the object'
/
comment on column DBA_OBJECTS.DATA_OBJECT_ID is
'Object number of the segment which contains the object'
/
comment on column DBA_OBJECTS.OBJECT_TYPE is
'Type of the object'
/
comment on column DBA_OBJECTS.CREATED is
'Timestamp for the creation of the object'
/
comment on column DBA_OBJECTS.LAST_DDL_TIME is
'Timestamp for the last DDL change (including GRANT and REVOKE) to the object'
/
comment on column DBA_OBJECTS.TIMESTAMP is
'Timestamp for the specification of the object'
/
comment on column DBA_OBJECTS.STATUS is
'Status of the object'
/
comment on column DBA_OBJECTS.TEMPORARY is
'Can the current session only see data that it place in this object itself?'
/
comment on column DBA_OBJECTS.GENERATED is
'Was the name of this object system generated?'
/
comment on column DBA_OBJECTS.SECONDARY is
'Is this a secondary object created as part of icreate for domain indexes?'
/

remark FAMILY  "PROCEDURES"
remark   List of procedures (and functions) and associated properties

create or replace view USER_PROCEDURES
(OBJECT_NAME, PROCEDURE_NAME, AGGREGATE, PIPELINED,
  IMPLTYPEOWNER, IMPLTYPENAME, PARALLEL,
  INTERFACE, DETERMINISTIC, AUTHID)
as
select o.name, pi.procedurename,
decode(bitand(pi.properties,8),8,'YES','NO'),
decode(bitand(pi.properties,16),16,'YES','NO'),
u2.name, o2.name,
decode(bitand(pi.properties,32),32,'YES','NO'),
decode(bitand(pi.properties,512),512,'YES','NO'),
decode(bitand(pi.properties,256),256,'YES','NO'),
decode(bitand(pi.properties,1024),1024,'CURRENT_USER','DEFINER')
from sys.obj$ o, sys.procedureinfo$ pi, sys.obj$ o2, sys.user$ u2
where o.owner# = userenv('SCHEMAID') and o.obj# = pi.obj#
and pi.itypeobj# = o2.obj# (+) and o2.owner#  = u2.user# (+)
/
comment on table USER_PROCEDURES is
'Description of the users own procedures'
/
comment on column USER_PROCEDURES.OBJECT_NAME is
'Name of the object : top level function/procedure/package name'
/
comment on column USER_PROCEDURES.PROCEDURE_NAME is
'Name of the procedure'
/
comment on column USER_PROCEDURES.AGGREGATE is
'Is it an aggregate function ?'
/
comment on column USER_PROCEDURES.PIPELINED is
'Is it a pipelined table function ?'
/
comment on column USER_PROCEDURES.IMPLTYPEOWNER is
'Name of the owner of the implementation type (if any)'
/
comment on column USER_PROCEDURES.IMPLTYPENAME is
'Name of the implementation type (if any)'
/
comment on column USER_PROCEDURES.PARALLEL is
'Is the procedure parallel enabled ?'
/
create or replace public synonym user_procedures for user_procedures
/
grant select on user_procedures to public with grant option
/

create or replace view ALL_PROCEDURES
(OWNER, OBJECT_NAME, PROCEDURE_NAME, AGGREGATE, PIPELINED,
  IMPLTYPEOWNER, IMPLTYPENAME, PARALLEL,
  INTERFACE, DETERMINISTIC, AUTHID)
as
select u.name, o.name, pi.procedurename,
decode(bitand(pi.properties,8),8,'YES','NO'),
decode(bitand(pi.properties,16),16,'YES','NO'),
u2.name, o2.name,
  decode(bitand(pi.properties,32),32,'YES','NO'),
  decode(bitand(pi.properties,512),512,'YES','NO'),
decode(bitand(pi.properties,256),256,'YES','NO'),
decode(bitand(pi.properties,1024),1024,'CURRENT_USER','DEFINER')
from obj$ o, user$ u, procedureinfo$ pi, obj$ o2, user$ u2
where u.user# = o.owner# and o.obj# = pi.obj#
and pi.itypeobj# = o2.obj# (+) and o2.owner#  = u2.user# (+)
and (o.owner# = userenv('SCHEMAID')
     or exists
      (select null from v$enabledprivs where priv_number in (-144,-141))
     or o.obj# in (select obj# from sys.objauth$ where grantee# in
      (select kzsrorol from x$kzsro) and privilege# = 12))
/
comment on table ALL_PROCEDURES is
'Description of all procedures available to the user'
/
comment on column ALL_PROCEDURES.OBJECT_NAME is
'Name of the object : top level function/procedure/package name'
/
comment on column ALL_PROCEDURES.PROCEDURE_NAME is
'Name of the procedure'
/
comment on column ALL_PROCEDURES.AGGREGATE is
'Is it an aggregate function ?'
/
comment on column ALL_PROCEDURES.PIPELINED is
'Is it a pipelined table function ?'
/
comment on column ALL_PROCEDURES.IMPLTYPEOWNER is
'Name of the owner of the implementation type (if any)'
/
comment on column ALL_PROCEDURES.IMPLTYPENAME is
'Name of the implementation type (if any)'
/
comment on column ALL_PROCEDURES.PARALLEL is
'Is the procedure parallel enabled ?'
/
create or replace public synonym all_procedures for all_procedures
/
grant select on all_procedures to public with grant option
/


create or replace view DBA_PROCEDURES
(OWNER, OBJECT_NAME, PROCEDURE_NAME, AGGREGATE, PIPELINED,
  IMPLTYPEOWNER, IMPLTYPENAME, PARALLEL,
  INTERFACE, DETERMINISTIC, AUTHID)
as
select u.name, o.name, pi.procedurename,
decode(bitand(pi.properties,8),8,'YES','NO'),
decode(bitand(pi.properties,16),16,'YES','NO'),
u2.name, o2.name,
  decode(bitand(pi.properties,32),32,'YES','NO'),
  decode(bitand(pi.properties,512),512,'YES','NO'),
decode(bitand(pi.properties,256),256,'YES','NO'),
decode(bitand(pi.properties,1024),1024,'CURRENT_USER','DEFINER')
from obj$ o, user$ u, procedureinfo$ pi, obj$ o2, user$ u2
where u.user# = o.owner# and o.obj# = pi.obj#
and pi.itypeobj# = o2.obj# (+) and o2.owner#  = u2.user# (+)
/
comment on table DBA_PROCEDURES is
'Description of all procedures'
/
comment on column DBA_PROCEDURES.OBJECT_NAME is
'Name of the object : top level function/procedure/package name'
/
comment on column DBA_PROCEDURES.PROCEDURE_NAME is
'Name of the procedure'
/
comment on column DBA_PROCEDURES.AGGREGATE is
'Is it an aggregate function ?'
/
comment on column DBA_PROCEDURES.PIPELINED is
'Is it a pipelined table function ?'
/
comment on column DBA_PROCEDURES.IMPLTYPEOWNER is
'Name of the owner of the implementation type (if any)'
/
comment on column DBA_PROCEDURES.IMPLTYPENAME is
'Name of the implementation type (if any)'
/
comment on column DBA_PROCEDURES.PARALLEL is
'Is the procedure parallel enabled ?'
/
create or replace public synonym DBA_PROCEDURES for DBA_PROCEDURES
/
grant select on DBA_PROCEDURES to select_catalog_role
/

remark
remark Family STORED_SETTINGS
remark

CREATE OR REPLACE VIEW all_stored_settings
(owner, object_name, object_id, object_type, param_name, param_value)
AS
SELECT u.name, o.name, o.obj#,
DECODE(o.type#,
        7, 'PROCEDURE',
        8, 'FUNCTION',
        9, 'PACKAGE',
       11, 'PACKAGE BODY',
       12, 'TRIGGER',
       13, 'TYPE',
       14, 'TYPE BODY',
       'UNDEFINED'),
p.param, p.value
FROM sys.obj$ o, sys.user$ u, sys.settings$ p
WHERE o.owner# = u.user#
AND o.linkname is null
AND p.obj# = o.obj#
AND (
    o.owner# in (userenv('SCHEMAID'), 1 /* PUBLIC */)
    or
    (
      (
         (
          (o.type# = 7 or o.type# = 8 or o.type# = 9 or o.type# = 13)
          and
          o.obj# in (select obj# from sys.objauth$
                     where grantee# in (select kzsrorol from x$kzsro)
                       and privilege#  = 12 /* EXECUTE */)
        )
        or
        exists
        (
          select null from sys.sysauth$
          where grantee# in (select kzsrorol from x$kzsro)
          and
          (
            (
              /* procedure */
              (o.type# = 7 or o.type# = 8 or o.type# = 9)
              and
              (
                privilege# = -144 /* EXECUTE ANY PROCEDURE */
                or
                privilege# = -141 /* CREATE ANY PROCEDURE */
              )
            )
            or
            (
              /* package body */
              o.type# = 11 and
              privilege# = -141 /* CREATE ANY PROCEDURE */
            )
            or
            (
              /* type */
              o.type# = 13
              and
              (
                privilege# = -184 /* EXECUTE ANY TYPE */
                or
                privilege# = -181 /* CREATE ANY TYPE */
              )
            )
            or
            (
              /* type body */
              o.type# = 14 and
              privilege# = -181 /* CREATE ANY TYPE */
            )
          )
        )
      )
    )
  )
/
comment on table all_stored_settings is
'Parameter settings for objects accessible to the user'
/
comment on column all_stored_settings.owner is
'Username of the owner of the object'
/
comment on column all_stored_settings.object_name is
'Name of the object'
/
comment on column all_stored_settings.object_id is
'Object number of the object'
/
comment on column all_stored_settings.object_type is
'Type of the object'
/
comment on column all_stored_settings.param_name is
'Name of the parameter'
/
comment on column all_stored_settings.param_value is
'Value of the parameter'
/
create or replace public synonym all_stored_settings for all_stored_settings
/
grant select on all_stored_settings to public with grant option
/

CREATE OR REPLACE VIEW user_stored_settings
(object_name, object_id, object_type, param_name, param_value)
AS
SELECT o.name, o.obj#,
DECODE(o.type#,
        7, 'PROCEDURE',
        8, 'FUNCTION',
        9, 'PACKAGE',
       11, 'PACKAGE BODY',
       12, 'TRIGGER',
       13, 'TYPE',
       14, 'TYPE BODY',
       'UNDEFINED'),
p.param, p.value
FROM sys.obj$ o, sys.settings$ p
WHERE o.linkname is null
AND p.obj# = o.obj#
AND o.owner# = userenv('SCHEMAID')
/
comment on table user_stored_settings is
'Parameter settings for objects owned by the user'
/
comment on column user_stored_settings.object_name is
'Name of the object'
/
comment on column user_stored_settings.object_id is
'Object number of the object'
/
comment on column user_stored_settings.object_type is
'Type of the object'
/
comment on column user_stored_settings.param_name is
'Name of the parameter'
/
comment on column user_stored_settings.param_value is
'Value of the parameter'
/
create or replace public synonym user_stored_settings for user_stored_settings
/
grant select on user_stored_settings to public with grant option
/

CREATE OR REPLACE VIEW dba_stored_settings
(owner, object_name, object_id, object_type, param_name, param_value)
AS
SELECT u.name, o.name, o.obj#,
DECODE(o.type#,
        7, 'PROCEDURE',
        8, 'FUNCTION',
        9, 'PACKAGE',
       11, 'PACKAGE BODY',
       12, 'TRIGGER',
       13, 'TYPE',
       14, 'TYPE BODY',
       'UNDEFINED'),
p.param, p.value
FROM sys.obj$ o, sys.user$ u, sys.settings$ p
WHERE o.owner# = u.user#
AND o.linkname is null
AND p.obj# = o.obj#
/
comment on table dba_stored_settings is
'Parameter settings for all objects'
/
comment on column dba_stored_settings.owner is
'Username of the owner of the object'
/
comment on column dba_stored_settings.object_name is
'Name of the object'
/
comment on column dba_stored_settings.object_id is
'Object number of the object'
/
comment on column dba_stored_settings.object_type is
'Type of the object'
/
comment on column dba_stored_settings.param_name is
'Name of the parameter'
/
comment on column dba_stored_settings.param_value is
'Value of the parameter'
/
create or replace public synonym dba_stored_settings for dba_stored_settings
/
grant select on dba_stored_settings to select_catalog_role
/

create or replace view USER_PLSQL_OBJECT_SETTINGS
(NAME, TYPE, PLSQL_OPTIMIZE_LEVEL, PLSQL_CODE_TYPE, PLSQL_DEBUG,
 PLSQL_WARNINGS, NLS_LENGTH_SEMANTICS, PLSQL_CCFLAGS)
as
select o.name,
decode(o.type#, 7, 'PROCEDURE', 8, 'FUNCTION', 9, 'PACKAGE',
                11, 'PACKAGE BODY', 12, 'TRIGGER',
                13, 'TYPE', 14, 'TYPE BODY', 'UNDEFINED'),
(select to_number(value) from settings$ s
  where s.obj# = o.obj# and param = 'plsql_optimize_level'),
(select value from settings$ s
  where s.obj# = o.obj# and param = 'plsql_code_type'),
(select value from settings$ s
  where s.obj# = o.obj# and param = 'plsql_debug'),
(select value from settings$ s
  where s.obj# = o.obj# and param = 'plsql_warnings'),
(select value from settings$ s
  where s.obj# = o.obj# and param = 'nls_length_semantics'),
(select value from settings$ s
  where s.obj# = o.obj# and param = 'plsql_ccflags')
from sys.obj$ o
where o.owner# = userenv('SCHEMAID')
  and o.type# in (7, 8, 9, 11, 12, 13, 14)
/
comment on table USER_PLSQL_OBJECT_SETTINGS is
'Compiler settings of stored objects owned by the user'
/
comment on column USER_PLSQL_OBJECT_SETTINGS.NAME is
'Name of the object'
/
comment on column USER_PLSQL_OBJECT_SETTINGS.TYPE is
'Type of the object: "PROCEDURE", "FUNCTION",
"PACKAGE", "PACKAGE BODY", "TRIGGER", "TYPE" or "TYPE BODY"'
/
comment on column USER_PLSQL_OBJECT_SETTINGS.PLSQL_OPTIMIZE_LEVEL is
'The optimization level to use to compile the object'
/
comment on column USER_PLSQL_OBJECT_SETTINGS.PLSQL_CODE_TYPE is
'The object codes are to be compiled natively or are interpreted'
/
comment on column USER_PLSQL_OBJECT_SETTINGS.PLSQL_DEBUG is
'The object is to be compiled with debug information or not'
/
comment on column USER_PLSQL_OBJECT_SETTINGS.PLSQL_WARNINGS is
'The compiler warning settings to use to compile the object'
/
comment on column USER_PLSQL_OBJECT_SETTINGS.NLS_LENGTH_SEMANTICS is
'The NLS length semantics to use to compile the object'
/
comment on column USER_PLSQL_OBJECT_SETTINGS.PLSQL_CCFLAGS is
'The conditional compilation flag settings to use to compile the object'
/
create or replace public synonym USER_PLSQL_OBJECT_SETTINGS for USER_PLSQL_OBJECT_SETTINGS
/
grant select on USER_PLSQL_OBJECT_SETTINGS to public with grant option
/

create or replace view ALL_PLSQL_OBJECT_SETTINGS
(OWNER, NAME, TYPE, PLSQL_OPTIMIZE_LEVEL, PLSQL_CODE_TYPE, PLSQL_DEBUG,
 PLSQL_WARNINGS, NLS_LENGTH_SEMANTICS, PLSQL_CCFLAGS)
as
select u.name, o.name,
decode(o.type#, 7, 'PROCEDURE', 8, 'FUNCTION', 9, 'PACKAGE',
                11, 'PACKAGE BODY', 12, 'TRIGGER',
                13, 'TYPE', 14, 'TYPE BODY', 'UNDEFINED'),
(select to_number(value) from settings$ s
  where s.obj# = o.obj# and param = 'plsql_optimize_level'),
(select value from settings$ s
  where s.obj# = o.obj# and param = 'plsql_code_type'),
(select value from settings$ s
  where s.obj# = o.obj# and param = 'plsql_debug'),
(select value from settings$ s
  where s.obj# = o.obj# and param = 'plsql_warnings'),
(select value from settings$ s
  where s.obj# = o.obj# and param = 'nls_length_semantics'),
(select value from settings$ s
  where s.obj# = o.obj# and param = 'plsql_ccflags')
from sys.obj$ o, sys.user$ u
where o.owner# = u.user#
  and o.type# in (7, 8, 9, 11, 12, 13, 14)
  and
  (
    o.owner# in (userenv('SCHEMAID'), 1 /* PUBLIC */)
    or
    (
      /* EXECUTE privilege does not let user see package or type body */
      o.type# in (7, 8, 9, 12, 13)
      and
      o.obj# in (select obj# from sys.objauth$
                 where grantee# in (select kzsrorol from x$kzsro)
                   and privilege# = 12 /* EXECUTE */
                )
    )
    or
    (
       o.type# in (7, 8, 9) /* procedure, function, package */
       and
       exists (select null from v$enabledprivs
               where priv_number in (
                                      -144 /* EXECUTE ANY PROCEDURE */,
                                      -141 /* CREATE ANY PROCEDURE */
                                    )
              )
    )
    or
    (
      o.type# = 11 /* package body */
      and
      exists (select null from v$enabledprivs
              where priv_number = -141 /* CREATE ANY PROCEDURE */)
    )
    or
    (
       o.type# = 12 /* trigger */
       and
       exists (select null from v$enabledprivs
               where priv_number = -152 /* CREATE ANY TRIGGER */)
    )
    or
    (
      o.type# = 13 /* type */
      and
      exists (select null from v$enabledprivs
              where priv_number in (-184 /* EXECUTE ANY TYPE */,
                                    -181 /* CREATE ANY TYPE */))
    )
    or
    (
      o.type# = 14 /* type body */
      and
      exists (select null from v$enabledprivs
              where priv_number = -181 /* CREATE ANY TYPE */)
    )
  )
/
comment on table ALL_PLSQL_OBJECT_SETTINGS is
'Compiler settings of stored objects accessible to the user'
/
comment on column ALL_PLSQL_OBJECT_SETTINGS.OWNER is
'Username of the owner of the object'
/
comment on column ALL_PLSQL_OBJECT_SETTINGS.NAME is
'Name of the object'
/
comment on column ALL_PLSQL_OBJECT_SETTINGS.TYPE is
'Type of the object: "PROCEDURE", "FUNCTION",
"PACKAGE", "PACKAGE BODY", "TRIGGER", "TYPE" or "TYPE BODY"'
/
comment on column ALL_PLSQL_OBJECT_SETTINGS.PLSQL_OPTIMIZE_LEVEL is
'The optimization level to use to compile the object'
/
comment on column ALL_PLSQL_OBJECT_SETTINGS.PLSQL_CODE_TYPE is
'The object codes are to be compiled natively or are interpreted'
/
comment on column ALL_PLSQL_OBJECT_SETTINGS.PLSQL_DEBUG is
'The object is to be compiled with debug information or not'
/
comment on column ALL_PLSQL_OBJECT_SETTINGS.PLSQL_WARNINGS is
'The compiler warning settings to use to compile the object'
/
comment on column ALL_PLSQL_OBJECT_SETTINGS.NLS_LENGTH_SEMANTICS is
'The NLS length semantics to use to compile the object'
/
comment on column ALL_PLSQL_OBJECT_SETTINGS.PLSQL_CCFLAGS is
'The conditional compilation flag settings to use to compile the object'
/
create or replace public synonym ALL_PLSQL_OBJECT_SETTINGS for ALL_PLSQL_OBJECT_SETTINGS
/
grant select on ALL_PLSQL_OBJECT_SETTINGS to public with grant option
/

create or replace view DBA_PLSQL_OBJECT_SETTINGS
(OWNER, NAME, TYPE, PLSQL_OPTIMIZE_LEVEL, PLSQL_CODE_TYPE, PLSQL_DEBUG,
 PLSQL_WARNINGS, NLS_LENGTH_SEMANTICS, PLSQL_CCFLAGS)
as
select u.name, o.name,
decode(o.type#, 7, 'PROCEDURE', 8, 'FUNCTION', 9, 'PACKAGE',
                11, 'PACKAGE BODY', 12, 'TRIGGER',
                13, 'TYPE', 14, 'TYPE BODY', 'UNDEFINED'),
(select to_number(value) from settings$ s
  where s.obj# = o.obj# and param = 'plsql_optimize_level'),
(select value from settings$ s
  where s.obj# = o.obj# and param = 'plsql_code_type'),
(select value from settings$ s
  where s.obj# = o.obj# and param = 'plsql_debug'),
(select value from settings$ s
  where s.obj# = o.obj# and param = 'plsql_warnings'),
(select value from settings$ s
  where s.obj# = o.obj# and param = 'nls_length_semantics'),
(select value from settings$ s
  where s.obj# = o.obj# and param = 'plsql_ccflags')
from sys.obj$ o, sys.user$ u
where o.owner# = u.user#
  and o.type# in (7, 8, 9, 11, 12, 13, 14)
/
create or replace public synonym DBA_PLSQL_OBJECT_SETTINGS for DBA_PLSQL_OBJECT_SETTINGS
/
grant select on DBA_PLSQL_OBJECT_SETTINGS to select_catalog_role
/
comment on table DBA_PLSQL_OBJECT_SETTINGS is
'Compiler settings of all objects in the database'
/
comment on column DBA_PLSQL_OBJECT_SETTINGS.OWNER is
'Username of the owner of the object'
/
comment on column DBA_PLSQL_OBJECT_SETTINGS.NAME is
'Name of the object'
/
comment on column DBA_PLSQL_OBJECT_SETTINGS.TYPE is
'Type of the object: "PROCEDURE", "FUNCTION",
"PACKAGE", "PACKAGE BODY", "TRIGGER", "TYPE" or "TYPE BODY"'
/
comment on column DBA_PLSQL_OBJECT_SETTINGS.PLSQL_OPTIMIZE_LEVEL is
'The optimization level to use to compile the object'
/
comment on column DBA_PLSQL_OBJECT_SETTINGS.PLSQL_CODE_TYPE is
'The object codes are to be compiled natively or are interpreted'
/
comment on column DBA_PLSQL_OBJECT_SETTINGS.PLSQL_DEBUG is
'The object is to be compiled with debug information or not'
/
comment on column DBA_PLSQL_OBJECT_SETTINGS.PLSQL_WARNINGS is
'The compiler warning settings to use to compile the object'
/
comment on column DBA_PLSQL_OBJECT_SETTINGS.NLS_LENGTH_SEMANTICS is
'The NLS length semantics to use to compile the object'
/
comment on column DBA_PLSQL_OBJECT_SETTINGS.PLSQL_CCFLAGS is
'The conditional compilation flag settings to use to compile the object'
/

remark
remark Family ARGUMENTS
remark

create or replace view ALL_ARGUMENTS
(OWNER, OBJECT_NAME, PACKAGE_NAME, OBJECT_ID, OVERLOAD,
ARGUMENT_NAME, POSITION, SEQUENCE,
DATA_LEVEL, DATA_TYPE, DEFAULT_VALUE, DEFAULT_LENGTH, IN_OUT, DATA_LENGTH,
DATA_PRECISION, DATA_SCALE, RADIX, CHARACTER_SET_NAME,
TYPE_OWNER, TYPE_NAME, TYPE_SUBNAME, TYPE_LINK, PLS_TYPE,
CHAR_LENGTH, CHAR_USED)
as
select
u.name, /* OWNER */
nvl(a.procedure$,o.name), /* OBJECT_NAME */
decode(a.procedure$,null,null, o.name), /* PACKAGE_NAME */
o.obj#, /* OBJECT_ID */
decode(a.overload#,0,null,a.overload#), /* OVERLOAD */
a.argument, /* ARGUMENT_NAME */
a.position#, /* POSITION */
a.sequence#, /* SEQUENCE */
a.level#, /* DATA_LEVEL */
decode(a.type#,  /* DATA_TYPE */
0, null,
1, decode(a.charsetform, 2, 'NVARCHAR2', 'VARCHAR2'),
2, decode(a.scale, -127, 'FLOAT', 'NUMBER'),
3, 'NATIVE INTEGER',
8, 'LONG',
9, decode(a.charsetform, 2, 'NCHAR VARYING', 'VARCHAR'),
11, 'ROWID',
12, 'DATE',
23, 'RAW',
24, 'LONG RAW',
29, 'BINARY_INTEGER',
69, 'ROWID',
96, decode(a.charsetform, 2, 'NCHAR', 'CHAR'),
100, 'BINARY_FLOAT',
101, 'BINARY_DOUBLE',
102, 'REF CURSOR',
104, 'UROWID',
105, 'MLSLABEL',
106, 'MLSLABEL',
110, 'REF',
111, 'REF',
112, decode(a.charsetform, 2, 'NCLOB', 'CLOB'),
113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
121, 'OBJECT',
122, 'TABLE',
123, 'VARRAY',
178, 'TIME',
179, 'TIME WITH TIME ZONE',
180, 'TIMESTAMP',
181, 'TIMESTAMP WITH TIME ZONE',
231, 'TIMESTAMP WITH LOCAL TIME ZONE',
182, 'INTERVAL YEAR TO MONTH',
183, 'INTERVAL DAY TO SECOND',
250, 'PL/SQL RECORD',
251, 'PL/SQL TABLE',
252, 'PL/SQL BOOLEAN',
'UNDEFINED'),
default$, /* DEFAULT_VALUE */
deflength, /* DEFAULT_LENGTH */
decode(in_out,null,'IN',1,'OUT',2,'IN/OUT','Undefined'), /* IN_OUT */
length, /* DATA_LENGTH */
precision#, /* DATA_PRECISION */
decode(a.type#, 2, scale, 1, null, 96, null, scale), /* DATA_SCALE */
radix, /* RADIX */
decode(a.charsetform, 1, 'CHAR_CS',           /* CHARACTER_SET_NAME */
                      2, 'NCHAR_CS',
                      3, NLS_CHARSET_NAME(a.charsetid),
                      4, 'ARG:'||a.charsetid),
a.type_owner, /* TYPE_OWNER */
a.type_name, /* TYPE_NAME */
a.type_subname, /* TYPE_SUBNAME */
a.type_linkname, /* TYPE_LINK */
a.pls_type, /* PLS_TYPE */
decode(a.type#, 1, a.scale, 96, a.scale, 0), /* CHAR_LENGTH */
decode(a.type#,
        1, decode(bitand(a.properties, 128), 128, 'C', 'B'),
       96, decode(bitand(a.properties, 128), 128, 'C', 'B'), 0) /* CHAR_USED */
from obj$ o,argument$ a,user$ u
where o.obj# = a.obj#
and o.owner# = u.user#
and (owner# = userenv('SCHEMAID')
or exists
  (select null from v$enabledprivs where priv_number in (-144,-141))
or o.obj# in (select obj# from sys.objauth$ where grantee# in
  (select kzsrorol from x$kzsro) and privilege# = 12))
/
comment on table all_arguments is
'Arguments in object accessible to the user'
/
comment on column all_arguments.owner is
'Username of the owner of the object'
/
comment on column all_arguments.object_name is
'Procedure or function name'
/
comment on column all_arguments.overload is
'Overload unique identifier'
/
comment on column all_arguments.package_name is
'Package name'
/
comment on column all_arguments.object_id is
'Object number of the object'
/
comment on column all_arguments.argument_name is
'Argument name'
/
comment on column all_arguments.position is
'Position in argument list, or null for function return value'
/
comment on column all_arguments.sequence is
'Argument sequence, including all nesting levels'
/
comment on column all_arguments.data_level is
'Nesting depth of argument for composite types'
/
comment on column all_arguments.data_type is
'Datatype of the argument'
/
comment on column all_arguments.default_value is
'Default value for the argument'
/
comment on column all_arguments.default_length is
'Length of default value for the argument'
/
comment on column all_arguments.in_out is
'Argument direction (IN, OUT, or IN/OUT)'
/
comment on column all_arguments.data_length is
'Length of the column in bytes'
/
comment on column all_arguments.data_precision is
'Length: decimal digits (NUMBER) or binary digits (FLOAT)'
/
comment on column all_arguments.data_scale is
'Digits to right of decimal point in a number'
/
comment on column all_arguments.radix is
'Argument radix for a number'
/
comment on column all_arguments.character_set_name is
'Character set name for the argument'
/
comment on column all_arguments.type_owner is
'Owner name for the argument type in case of object types'
/
comment on column all_arguments.type_name is
'Object name for the argument type in case of object types'
/
comment on column all_arguments.type_subname is
'Subordinate object name for the argument type in case of object types'
/
comment on column all_arguments.type_link is
'Database link name for the argument type in case of object types'
/
comment on column all_arguments.pls_type is
'PL/SQL type name for numeric arguments'
/
comment on column all_arguments.char_length is
'Character limit for string datatypes'
/
comment on column all_arguments.char_used is
'Is the byte limit (B) or char limit (C) official for this string?'
/
create or replace public synonym all_arguments for all_arguments
/
grant select on all_arguments to public with grant option
/

create or replace view USER_ARGUMENTS
(OBJECT_NAME, PACKAGE_NAME, OBJECT_ID, OVERLOAD,
ARGUMENT_NAME, POSITION, SEQUENCE,
DATA_LEVEL, DATA_TYPE, DEFAULT_VALUE, DEFAULT_LENGTH, IN_OUT, DATA_LENGTH,
DATA_PRECISION, DATA_SCALE, RADIX, CHARACTER_SET_NAME,
TYPE_OWNER, TYPE_NAME, TYPE_SUBNAME, TYPE_LINK, PLS_TYPE,
CHAR_LENGTH, CHAR_USED)
as
select
nvl(a.procedure$,o.name), /* OBJECT_NAME */
decode(a.procedure$,null,null, o.name), /* PACKAGE_NAME */
o.obj#, /* OBJECT_ID */
decode(a.overload#,0,null,a.overload#), /* OVERLOAD */
a.argument, /* ARGUMENT_NAME */
a.position#, /* POSITION */
a.sequence#, /* SEQUENCE */
a.level#, /* DATA_LEVEL */
decode(a.type#,  /* DATA_TYPE */
0, null,
1, decode(a.charsetform, 2, 'NVARCHAR2', 'VARCHAR2'),
2, decode(a.scale, -127, 'FLOAT', 'NUMBER'),
3, 'NATIVE INTEGER',
8, 'LONG',
9, decode(a.charsetform, 2, 'NCHAR VARYING', 'VARCHAR'),
11, 'ROWID',
12, 'DATE',
23, 'RAW',
24, 'LONG RAW',
29, 'BINARY_INTEGER',
69, 'ROWID',
96, decode(a.charsetform, 2, 'NCHAR', 'CHAR'),
100, 'BINARY_FLOAT',
101, 'BINARY_DOUBLE',
102, 'REF CURSOR',
104, 'UROWID',
105, 'MLSLABEL',
106, 'MLSLABEL',
110, 'REF',
111, 'REF',
112, decode(a.charsetform, 2, 'NCLOB', 'CLOB'),
113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
121, 'OBJECT',
122, 'TABLE',
123, 'VARRAY',
178, 'TIME',
179, 'TIME WITH TIME ZONE',
180, 'TIMESTAMP',
181, 'TIMESTAMP WITH TIME ZONE',
231, 'TIMESTAMP WITH LOCAL TIME ZONE',
182, 'INTERVAL YEAR TO MONTH',
183, 'INTERVAL DAY TO SECOND',
250, 'PL/SQL RECORD',
251, 'PL/SQL TABLE',
252, 'PL/SQL BOOLEAN',
'UNDEFINED'),
default$, /* DEFAULT_VALUE */
deflength, /* DEFAULT_LENGTH */
decode(in_out,null,'IN',1,'OUT',2,'IN/OUT','Undefined'), /* IN_OUT */
length, /* DATA_LENGTH */
precision#, /* DATA_PRECISION */
decode(a.type#, 2, scale, 1, null, 96, null, scale), /* DATA_SCALE */
radix, /* RADIX */
decode(a.charsetform, 1, 'CHAR_CS',           /* CHARACTER_SET_NAME */
                      2, 'NCHAR_CS',
                      3, NLS_CHARSET_NAME(a.charsetid),
                      4, 'ARG:'||a.charsetid),
a.type_owner, /* TYPE_OWNER */
a.type_name, /* TYPE_NAME */
a.type_subname, /* TYPE_SUBNAME */
a.type_linkname, /* TYPE_LINK */
a.pls_type, /* PLS_TYPE */
decode(a.type#, 1, a.scale, 96, a.scale, 0), /* CHAR_LENGTH */
decode(a.type#,
        1, decode(bitand(a.properties, 128), 128, 'C', 'B'),
       96, decode(bitand(a.properties, 128), 128, 'C', 'B'), 0) /* CHAR_USED */
from obj$ o,argument$ a
where o.obj# = a.obj#
and owner# = userenv('SCHEMAID')
/
comment on table user_arguments is
'Arguments in object accessible to the user'
/
comment on column user_arguments.object_name is
'Procedure or function name'
/
comment on column user_arguments.overload is
'Overload unique identifier'
/
comment on column user_arguments.package_name is
'Package name'
/
comment on column user_arguments.object_id is
'Object number of the object'
/
comment on column user_arguments.argument_name is
'Argument name'
/
comment on column user_arguments.position is
'Position in argument list, or null for function return value'
/
comment on column user_arguments.sequence is
'Argument sequence, including all nesting levels'
/
comment on column user_arguments.data_level is
'Nesting depth of argument for composite types'
/
comment on column user_arguments.data_type is
'Datatype of the argument'
/
comment on column user_arguments.default_value is
'Default value for the argument'
/
comment on column user_arguments.default_length is
'Length of default value for the argument'
/
comment on column user_arguments.in_out is
'Argument direction (IN, OUT, or IN/OUT)'
/
comment on column user_arguments.data_length is
'Length of the column in bytes'
/
comment on column user_arguments.data_precision is
'Length: decimal digits (NUMBER) or binary digits (FLOAT)'
/
comment on column user_arguments.data_scale is
'Digits to right of decimal point in a number'
/
comment on column user_arguments.radix is
'Argument radix for a number'
/
comment on column user_arguments.character_set_name is
'Character set name for the argument'
/
comment on column user_arguments.type_owner is
'Owner name for the argument type in case of object types'
/
comment on column user_arguments.type_name is
'Object name for the argument type in case of object types'
/
comment on column user_arguments.type_subname is
'Subordinate object name for the argument type in case of object types'
/
comment on column user_arguments.type_link is
'Database link name for the argument type in case of object types'
/
comment on column user_arguments.pls_type is
'PL/SQL type name for numeric arguments'
/
comment on column user_arguments.char_length is
'Character limit for string datatypes'
/
comment on column user_arguments.char_used is
'Is the byte limit (B) or char limit (C) official for this string?'
/
create or replace public synonym user_arguments for user_arguments
/
grant select on user_arguments to public with grant option
/
remark
remark  FAMILY "RESUMABLE"
remark  Resumable statement related information
remark
create or replace view DBA_RESUMABLE
    (USER_ID, SESSION_ID, INSTANCE_ID, COORD_INSTANCE_ID, COORD_SESSION_ID,
     STATUS, TIMEOUT, START_TIME, SUSPEND_TIME, RESUME_TIME, NAME, SQL_TEXT,
     ERROR_NUMBER, ERROR_PARAMETER1, ERROR_PARAMETER2, ERROR_PARAMETER3,
     ERROR_PARAMETER4, ERROR_PARAMETER5, ERROR_MSG)
as
select distinct S.USER# as USER_ID, R.SID as SESSION_ID,
       R.INST_ID as INSTANCE_ID, P.QCINST_ID, P.QCSID,
       R.STATUS, R.TIMEOUT, NVL(T.START_TIME, R.SUSPEND_TIME) as START_TIME,
       R.SUSPEND_TIME, R.RESUME_TIME, R.NAME, Q.SQL_TEXT, R.ERROR_NUMBER,
       R.ERROR_PARAMETER1, R.ERROR_PARAMETER2, R.ERROR_PARAMETER3,
       R.ERROR_PARAMETER4, R.ERROR_PARAMETER5, R.ERROR_MSG
from GV$RESUMABLE R, GV$SESSION S, GV$TRANSACTION T, GV$SQL Q, GV$PX_SESSION P
where S.SID=R.SID and S.INST_ID=R.INST_ID
      and S.SADDR=T.SES_ADDR(+) and S.INST_ID=T.INST_ID(+)
      and S.SQL_ADDRESS=Q.ADDRESS(+) and S.INST_ID=Q.INST_ID(+)
      and S.SADDR=P.SADDR(+) and S.INST_ID=P.INST_ID(+)
      and R.ENABLED='YES' and NVL(T.SPACE(+),'NO')='NO'
/
create or replace public synonym DBA_RESUMABLE for DBA_RESUMABLE
/
grant select on DBA_RESUMABLE to select_catalog_role
/
comment on table DBA_RESUMABLE is
'Resumable session information in the system'
/
comment on column DBA_RESUMABLE.USER_ID is
'User who own this resumable session'
/
comment on column DBA_RESUMABLE.SESSION_ID is
'Session ID of this resumable session'
/
comment on column DBA_RESUMABLE.INSTANCE_ID is
'Instance ID of this resumable session'
/
comment on column DBA_RESUMABLE.COORD_INSTANCE_ID is
'Instance number of parallel query coordinator'
/
comment on column DBA_RESUMABLE.COORD_SESSION_ID is
'Session number of parallel query coordinator'
/
comment on column DBA_RESUMABLE.STATUS is
'Status of this resumable session'
/
comment on column DBA_RESUMABLE.TIMEOUT is
'Timeout of this resumable session'
/
comment on column DBA_RESUMABLE.START_TIME is
'Start time of the current transaction'
/
comment on column DBA_RESUMABLE.SUSPEND_TIME is
'Suspend time of the current statement'
/
comment on column DBA_RESUMABLE.RESUME_TIME is
'Resume time of the current statement'
/
comment on column DBA_RESUMABLE.NAME is
'Name of this resumable session'
/
comment on column DBA_RESUMABLE.SQL_TEXT is
'The current SQL text'
/
comment on column DBA_RESUMABLE.ERROR_NUMBER is
'The current error number'
/
comment on column DBA_RESUMABLE.ERROR_PARAMETER1 is
'The 1st parameter to the current error message'
/
comment on column DBA_RESUMABLE.ERROR_PARAMETER2 is
'The 2nd parameter to the current error message'
/
comment on column DBA_RESUMABLE.ERROR_PARAMETER3 is
'The 3rd parameter to the current error message'
/
comment on column DBA_RESUMABLE.ERROR_PARAMETER4 is
'The 4th parameter to the current error message'
/
comment on column DBA_RESUMABLE.ERROR_PARAMETER5 is
'The 5th parameter to the current error message'
/
comment on column DBA_RESUMABLE.ERROR_MSG is
'The current error message'
/
create or replace view USER_RESUMABLE
    (SESSION_ID, INSTANCE_ID, COORD_INSTANCE_ID, COORD_SESSION_ID, STATUS,
     TIMEOUT, START_TIME, SUSPEND_TIME, RESUME_TIME, NAME, SQL_TEXT,
     ERROR_NUMBER, ERROR_PARAMETER1, ERROR_PARAMETER2, ERROR_PARAMETER3,
     ERROR_PARAMETER4, ERROR_PARAMETER5, ERROR_MSG)
as
select distinct R.SID as SESSION_ID,
       R.INST_ID as INSTANCE_ID, P.QCINST_ID, P.QCSID,
       R.STATUS, R.TIMEOUT, NVL(T.START_TIME, R.SUSPEND_TIME) as START_TIME,
       R.SUSPEND_TIME, R.RESUME_TIME, R.NAME, Q.SQL_TEXT, R.ERROR_NUMBER,
       R.ERROR_PARAMETER1, R.ERROR_PARAMETER2, R.ERROR_PARAMETER3,
       R.ERROR_PARAMETER4, R.ERROR_PARAMETER5, R.ERROR_MSG
from GV$RESUMABLE R, GV$SESSION S, GV$TRANSACTION T, GV$SQL Q, GV$PX_SESSION P
where S.SID=R.SID and S.INST_ID=R.INST_ID
      and S.SADDR=T.SES_ADDR(+) and S.INST_ID=T.INST_ID(+)
      and S.SQL_ADDRESS=Q.ADDRESS(+) and S.INST_ID=Q.INST_ID(+)
      and S.SADDR=P.SADDR(+) and S.INST_ID=P.INST_ID(+)
      and R.ENABLED='YES' and NVL(T.SPACE(+),'NO')='NO'
      and S.USER# = userenv('SCHEMAID')
/
create or replace public synonym USER_RESUMABLE for USER_RESUMABLE
/
grant select on USER_RESUMABLE to public with grant option
/
comment on table USER_RESUMABLE is
'Resumable session information for current user'
/
comment on column USER_RESUMABLE.SESSION_ID is
'Session ID of this resumable session'
/
comment on column USER_RESUMABLE.INSTANCE_ID is
'Instance ID of this resumable session'
/
comment on column USER_RESUMABLE.COORD_INSTANCE_ID is
'Instance number of parallel query coordinator'
/
comment on column USER_RESUMABLE.COORD_SESSION_ID is
'Session number of parallel query coordinator'
/
comment on column USER_RESUMABLE.STATUS is
'Status of this resumable session'
/
comment on column USER_RESUMABLE.TIMEOUT is
'Timeout of this resumable session'
/
comment on column USER_RESUMABLE.START_TIME is
'Start time of the current transaction'
/
comment on column USER_RESUMABLE.SUSPEND_TIME is
'Suspend time of the current statement'
/
comment on column USER_RESUMABLE.RESUME_TIME is
'Resume time of the current statement'
/
comment on column USER_RESUMABLE.NAME is
'Name of this resumable session'
/
comment on column USER_RESUMABLE.SQL_TEXT is
'The current SQL text'
/
comment on column USER_RESUMABLE.ERROR_NUMBER is
'The current error number'
/
comment on column USER_RESUMABLE.ERROR_PARAMETER1 is
'The 1st parameter to the current error message'
/
comment on column USER_RESUMABLE.ERROR_PARAMETER2 is
'The 2nd parameter to the current error message'
/
comment on column USER_RESUMABLE.ERROR_PARAMETER3 is
'The 3rd parameter to the current error message'
/
comment on column USER_RESUMABLE.ERROR_PARAMETER4 is
'The 4th parameter to the current error message'
/
comment on column USER_RESUMABLE.ERROR_PARAMETER5 is
'The 5th parameter to the current error message'
/
comment on column USER_RESUMABLE.ERROR_MSG is
'The current error message'
/

remark
remark  FAMILY "ROLLBACK_SEGS"
remark  CREATE ROLLBACK SEGMENT parameters.
remark  This family has a DBA member only.
remark
create or replace view DBA_ROLLBACK_SEGS
    (SEGMENT_NAME, OWNER, TABLESPACE_NAME, SEGMENT_ID, FILE_ID, BLOCK_ID,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     STATUS, INSTANCE_NUM, RELATIVE_FNO)
as
select un.name, decode(un.user#,1,'PUBLIC','SYS'),
       ts.name, un.us#, f.file#, un.block#,
       s.iniexts * ts.blocksize,
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
                                      s.extsize * ts.blocksize),
       s.minexts, s.maxexts,
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
                                      s.extpct),
       decode(un.status$, 2, 'OFFLINE', 3, 'ONLINE',
                          4, 'UNDEFINED', 5, 'NEEDS RECOVERY',
                          6, 'PARTLY AVAILABLE', 'UNDEFINED'),
       decode(un.inst#, 0, NULL, un.inst#), un.file#
from sys.undo$ un, sys.seg$ s, sys.ts$ ts, sys.file$ f
where un.status$ != 1
  and un.ts# = s.ts#
  and un.file# = s.file#
  and un.block# = s.block#
  and s.type# in (1, 10)
  and s.ts# = ts.ts#
  and un.ts# = f.ts#
  and un.file# = f.relfile#
/
create or replace public synonym DBA_ROLLBACK_SEGS for DBA_ROLLBACK_SEGS
/
grant select on DBA_ROLLBACK_SEGS to select_catalog_role
/
comment on table DBA_ROLLBACK_SEGS is
'Description of rollback segments'
/
comment on column DBA_ROLLBACK_SEGS.SEGMENT_NAME is
'Name of the rollback segment'
/
comment on column DBA_ROLLBACK_SEGS.OWNER is
'Owner of the rollback segment'
/
comment on column DBA_ROLLBACK_SEGS.TABLESPACE_NAME is
'Name of the tablespace containing the rollback segment'
/
comment on column DBA_ROLLBACK_SEGS.SEGMENT_ID is
'ID number of the rollback segment'
/
comment on column DBA_ROLLBACK_SEGS.FILE_ID is
'ID number of the file containing the segment header'
/
comment on column DBA_ROLLBACK_SEGS.BLOCK_ID is
'ID number of the block containing the segment header'
/
comment on column DBA_ROLLBACK_SEGS.INITIAL_EXTENT is
'Initial extent size in bytes'
/
comment on column DBA_ROLLBACK_SEGS.NEXT_EXTENT is
'Secondary extent size in bytes'
/
comment on column DBA_ROLLBACK_SEGS.MIN_EXTENTS is
'Minimum number of extents'
/
comment on column DBA_ROLLBACK_SEGS.MAX_EXTENTS is
'Maximum number of extents'
/
comment on column DBA_ROLLBACK_SEGS.PCT_INCREASE is
'Percent increase for extent size'
/
comment on column DBA_ROLLBACK_SEGS.STATUS is
'Rollback segment status'
/
comment on column DBA_ROLLBACK_SEGS.INSTANCE_NUM is
'Rollback segment owning parallel server instance number'
/
comment on column DBA_ROLLBACK_SEGS.RELATIVE_FNO is
'Relative number of the file containing the segment header'
/
remark
remark  FAMILY "ROLE GRANTS"
remark
remark
create or replace view USER_ROLE_PRIVS
    (USERNAME, GRANTED_ROLE, ADMIN_OPTION, DEFAULT_ROLE, OS_GRANTED)
as
select /*+ ordered */ decode(sa.grantee#, 1, 'PUBLIC', u1.name), u2.name,
       decode(min(option$), 1, 'YES', 'NO'),
       decode(min(u1.defrole), 0, 'NO', 1, 'YES',
              2, decode(min(ud.role#),null,'NO','YES'),
              3, decode(min(ud.role#),null,'YES','NO'), 'NO'), 'NO'
from sysauth$ sa, user$ u1, user$ u2, defrole$ ud
where sa.grantee# in (userenv('SCHEMAID'),1) and sa.grantee#=ud.user#(+)
  and sa.privilege#=ud.role#(+) and u1.user#=sa.grantee#
  and u2.user#=sa.privilege#
group by decode(sa.grantee#,1,'PUBLIC',u1.name),u2.name
union
select su.name,u.name,decode(kzdosadm,'A','YES','NO'),
       decode(kzdosdef,'Y','YES','NO'), 'YES'
 from sys.user$ u,x$kzdos, sys.user$ su
where u.user#=x$kzdos.kzdosrol and
      su.user#=userenv('SCHEMAID');
/
comment on table USER_ROLE_PRIVS is
'Roles granted to current user'
/
comment on column USER_ROLE_PRIVS.USERNAME is
'User Name or PUBLIC'
/
comment on column USER_ROLE_PRIVS.GRANTED_ROLE is
'Granted role name'
/
comment on column USER_ROLE_PRIVS.ADMIN_OPTION is
'Grant was with the ADMIN option'
/
comment on column USER_ROLE_PRIVS.DEFAULT_ROLE is
'Role is designated as a DEFAULT ROLE for the user'
/
comment on column USER_ROLE_PRIVS.OS_GRANTED is
'Role is granted via the operating system (using OS_ROLES = TRUE)'
/
create or replace public synonym USER_ROLE_PRIVS for USER_ROLE_PRIVS
/
grant select on USER_ROLE_PRIVS to PUBLIC with grant option
/
create or replace view DBA_ROLE_PRIVS
    (GRANTEE, GRANTED_ROLE, ADMIN_OPTION, DEFAULT_ROLE)
as
select /*+ ordered */ decode(sa.grantee#, 1, 'PUBLIC', u1.name), u2.name,
       decode(min(option$), 1, 'YES', 'NO'),
       decode(min(u1.defrole), 0, 'NO', 1, 'YES',
              2, decode(min(ud.role#),null,'NO','YES'),
              3, decode(min(ud.role#),null,'YES','NO'), 'NO')
from sysauth$ sa, user$ u1, user$ u2, defrole$ ud
where sa.grantee#=ud.user#(+)
  and sa.privilege#=ud.role#(+) and u1.user#=sa.grantee#
  and u2.user#=sa.privilege#
group by decode(sa.grantee#,1,'PUBLIC',u1.name),u2.name
/
create or replace public synonym DBA_ROLE_PRIVS for DBA_ROLE_PRIVS
/
grant select on DBA_ROLE_PRIVS to select_catalog_role
/
comment on table DBA_ROLE_PRIVS is
'Roles granted to users and roles'
/
comment on column DBA_ROLE_PRIVS.GRANTEE is
'Grantee Name, User or Role receiving the grant'
/
comment on column DBA_ROLE_PRIVS.GRANTED_ROLE is
'Granted role name'
/
comment on column DBA_ROLE_PRIVS.ADMIN_OPTION is
'Grant was with the ADMIN option'
/
comment on column DBA_ROLE_PRIVS.DEFAULT_ROLE is
'Role is designated as a DEFAULT ROLE for the user'
/
remark
remark  FAMILY "SYS GRANTS"
remark
remark
create or replace view USER_SYS_PRIVS
    (USERNAME, PRIVILEGE, ADMIN_OPTION)
as
select decode(sa.grantee#,1,'PUBLIC',su.name),spm.name,
       decode(min(option$),1,'YES','NO')
from  sys.system_privilege_map spm, sys.sysauth$ sa, sys.user$ su
where ((sa.grantee#=userenv('SCHEMAID') and su.user#=sa.grantee#)
       or sa.grantee#=1)
  and sa.privilege#=spm.privilege
group by decode(sa.grantee#,1,'PUBLIC',su.name),spm.name
/
comment on table USER_SYS_PRIVS is
'System privileges granted to current user'
/
comment on column USER_SYS_PRIVS.USERNAME is
'User Name or PUBLIC'
/
comment on column USER_SYS_PRIVS.PRIVILEGE is
'System privilege'
/
comment on column USER_SYS_PRIVS.ADMIN_OPTION is
'Grant was with the ADMIN option'
/
create or replace public synonym USER_SYS_PRIVS for USER_SYS_PRIVS
/
grant select on USER_SYS_PRIVS to PUBLIC with grant option
/
create or replace view DBA_SYS_PRIVS
    (GRANTEE, PRIVILEGE, ADMIN_OPTION)
as
select u.name,spm.name,decode(min(option$),1,'YES','NO')
from  sys.system_privilege_map spm, sys.sysauth$ sa, user$ u
where sa.grantee#=u.user# and sa.privilege#=spm.privilege
group by u.name,spm.name
/
create or replace public synonym DBA_SYS_PRIVS for DBA_SYS_PRIVS
/
grant select on DBA_SYS_PRIVS to select_catalog_role
/
comment on table DBA_SYS_PRIVS is
'System privileges granted to users and roles'
/
comment on column DBA_SYS_PRIVS.GRANTEE is
'Grantee Name, User or Role receiving the grant'
/
comment on column DBA_SYS_PRIVS.PRIVILEGE is
'System privilege'
/
comment on column DBA_SYS_PRIVS.ADMIN_OPTION is
'Grant was with the ADMIN option'
/
remark
remark  FAMILY "SEQUENCES"
remark  CREATE SEQUENCE information.
remark
create or replace view USER_SEQUENCES
  (SEQUENCE_NAME, MIN_VALUE, MAX_VALUE, INCREMENT_BY,
                  CYCLE_FLAG, ORDER_FLAG, CACHE_SIZE, LAST_NUMBER)
as select o.name,
      s.minvalue, s.maxvalue, s.increment$,
      decode (s.cycle#, 0, 'N', 1, 'Y'),
      decode (s.order$, 0, 'N', 1, 'Y'),
      s.cache, s.highwater
from sys.seq$ s, sys.obj$ o
where o.owner# = userenv('SCHEMAID')
  and o.obj# = s.obj#
/
comment on table USER_SEQUENCES is
'Description of the user''s own SEQUENCEs'
/
comment on column USER_SEQUENCES.SEQUENCE_NAME is
'SEQUENCE name'
/
comment on column USER_SEQUENCES.INCREMENT_BY is
'Value by which sequence is incremented'
/
comment on column USER_SEQUENCES.MIN_VALUE is
'Minimum value of the sequence'
/
comment on column USER_SEQUENCES.MAX_VALUE is
'Maximum value of the sequence'
/
comment on column USER_SEQUENCES.CYCLE_FLAG is
'Does sequence wrap around on reaching limit?'
/
comment on column USER_SEQUENCES.ORDER_FLAG is
'Are sequence numbers generated in order?'
/
comment on column USER_SEQUENCES.CACHE_SIZE is
'Number of sequence numbers to cache'
/
comment on column USER_SEQUENCES.LAST_NUMBER is
'Last sequence number written to disk'
/
create or replace public synonym USER_SEQUENCES for USER_SEQUENCES
/
create or replace public synonym SEQ for USER_SEQUENCES
/
grant select on USER_SEQUENCES to PUBLIC with grant option
/
create or replace view ALL_SEQUENCES
  (SEQUENCE_OWNER, SEQUENCE_NAME,
                  MIN_VALUE, MAX_VALUE, INCREMENT_BY,
                  CYCLE_FLAG, ORDER_FLAG, CACHE_SIZE, LAST_NUMBER)
as select u.name, o.name,
      s.minvalue, s.maxvalue, s.increment$,
      decode (s.cycle#, 0, 'N', 1, 'Y'),
      decode (s.order$, 0, 'N', 1, 'Y'),
      s.cache, s.highwater
from sys.seq$ s, sys.obj$ o, sys.user$ u
where u.user# = o.owner#
  and o.obj# = s.obj#
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
        or
         exists (select null from v$enabledprivs
                 where priv_number = -109 /* SELECT ANY SEQUENCE */
                 )
      )
/
comment on table ALL_SEQUENCES is
'Description of SEQUENCEs accessible to the user'
/
comment on column ALL_SEQUENCES.SEQUENCE_OWNER is
'Name of the owner of the sequence'
/
comment on column ALL_SEQUENCES.SEQUENCE_NAME is
'SEQUENCE name'
/
comment on column ALL_SEQUENCES.INCREMENT_BY is
'Value by which sequence is incremented'
/
comment on column ALL_SEQUENCES.MIN_VALUE is
'Minimum value of the sequence'
/
comment on column ALL_SEQUENCES.MAX_VALUE is
'Maximum value of the sequence'
/
comment on column ALL_SEQUENCES.CYCLE_FLAG is
'Does sequence wrap around on reaching limit?'
/
comment on column ALL_SEQUENCES.ORDER_FLAG is
'Are sequence numbers generated in order?'
/
comment on column ALL_SEQUENCES.CACHE_SIZE is
'Number of sequence numbers to cache'
/
comment on column ALL_SEQUENCES.LAST_NUMBER is
'Last sequence number written to disk'
/
create or replace public synonym ALL_SEQUENCES for ALL_SEQUENCES
/
grant select on ALL_SEQUENCES to PUBLIC with grant option
/
create or replace view DBA_SEQUENCES
  (SEQUENCE_OWNER, SEQUENCE_NAME,
                  MIN_VALUE, MAX_VALUE, INCREMENT_BY,
                  CYCLE_FLAG, ORDER_FLAG, CACHE_SIZE, LAST_NUMBER)
as select u.name, o.name,
      s.minvalue, s.maxvalue, s.increment$,
      decode (s.cycle#, 0, 'N', 1, 'Y'),
      decode (s.order$, 0, 'N', 1, 'Y'),
      s.cache, s.highwater
from sys.seq$ s, sys.obj$ o, sys.user$ u
where u.user# = o.owner#
  and o.obj# = s.obj#
/
create or replace public synonym DBA_SEQUENCES for DBA_SEQUENCES
/
grant select on DBA_SEQUENCES to select_catalog_role
/
comment on table DBA_SEQUENCES is
'Description of all SEQUENCEs in the database'
/
comment on column DBA_SEQUENCES.SEQUENCE_OWNER is
'Name of the owner of the sequence'
/
comment on column DBA_SEQUENCES.SEQUENCE_NAME is
'SEQUENCE name'
/
comment on column DBA_SEQUENCES.INCREMENT_BY is
'Value by which sequence is incremented'
/
comment on column DBA_SEQUENCES.MIN_VALUE is
'Minimum value of the sequence'
/
comment on column DBA_SEQUENCES.MAX_VALUE is
'Maximum value of the sequence'
/
comment on column DBA_SEQUENCES.CYCLE_FLAG is
'Does sequence wrap around on reaching limit?'
/
comment on column DBA_SEQUENCES.ORDER_FLAG is
'Are sequence numbers generated in order?'
/
comment on column DBA_SEQUENCES.CACHE_SIZE is
'Number of sequence numbers to cache'
/
comment on column DBA_SEQUENCES.LAST_NUMBER is
'Last sequence number written to disk'
/

remark
remark  FAMILY "SYNONYMS"
remark  CREATE SYNONYM information.
remark

rem The DBA_SYNONYMS view shows all synonyms in the database.
rem It is driven by the OBJ$ table,
rem restricting on type code 5 (synonym).
rem We join with the SYN$ table by object number,
rem to get the owner and name of the base object
rem that the synonym points to.
rem Note that despite the column names TABLE_OWNER and TABLE_NAME,
rem the base object might not be a table at all,
rem but rather a view, stored procedure, synonym, etc.
rem From SYN$, we also get the optional database link.
rem If the database link is null, then it's a local object.
rem Otherwise, it's a remote object.
rem Finally, we join with the USER$ table to get the name
rem of the user who owns the synonym, or PUBLIC.
rem

create or replace view DBA_SYNONYMS
    (OWNER, SYNONYM_NAME, TABLE_OWNER, TABLE_NAME, DB_LINK)
as select u.name, o.name, s.owner, s.name, s.node
from sys.user$ u, sys.syn$ s, sys.obj$ o
where o.obj# = s.obj#
  and o.type# = 5
  and o.owner# = u.user#
/

create or replace public synonym DBA_SYNONYMS for DBA_SYNONYMS
/
grant select on DBA_SYNONYMS to select_catalog_role
/
comment on table DBA_SYNONYMS is
'All synonyms in the database'
/
comment on column DBA_SYNONYMS.OWNER is
'Username of the owner of the synonym'
/
comment on column DBA_SYNONYMS.SYNONYM_NAME is
'Name of the synonym'
/
comment on column DBA_SYNONYMS.TABLE_OWNER is
'Owner of the object referenced by the synonym'
/
comment on column DBA_SYNONYMS.TABLE_NAME is
'Name of the object referenced by the synonym'
/
comment on column DBA_SYNONYMS.DB_LINK is
'Name of the database link referenced in a remote synonym'
/

rem
rem The view USER_SYNONYMS is identical to DBA_SYNONYMS,
rem except that we only look at synonyms owned by the current user,
rem by restricting on the owner id from OBJ$.
rem

create or replace view USER_SYNONYMS
    (SYNONYM_NAME, TABLE_OWNER, TABLE_NAME, DB_LINK)
as select o.name, s.owner, s.name, s.node
from sys.syn$ s, sys.obj$ o
where o.obj# = s.obj#
  and o.type# = 5
  and o.owner# = userenv('SCHEMAID')
/

comment on table USER_SYNONYMS is
'The user''s private synonyms'
/
comment on column USER_SYNONYMS.SYNONYM_NAME is
'Name of the synonym'
/
comment on column USER_SYNONYMS.TABLE_OWNER is
'Owner of the object referenced by the synonym'
/
comment on column USER_SYNONYMS.TABLE_NAME is
'Name of the object referenced by the synonym'
/
comment on column USER_SYNONYMS.DB_LINK is
'Database link referenced in a remote synonym'
/
create or replace public synonym SYN for USER_SYNONYMS
/
create or replace public synonym USER_SYNONYMS for USER_SYNONYMS
/
grant select on USER_SYNONYMS to PUBLIC with grant option
/

rem
rem bug 3369744:
rem The view _ALL_SYNONYMS_FOR_SYNONYMS is a support view for ALL_SYNONYMS.
rem This view is for internal use only and may change without notice.
rem It gives the list of synonyms that are defined for synonyms
rem (as opposed to those that are defined for some base object,
rem such as a table or view).
rem The view should not be publicly viewable (no grants or public synonyms).
rem

create or replace view "_ALL_SYNONYMS_FOR_SYNONYMS"
    (SYN_ID, SYN_OWNER, SYN_NAME, BASE_SYN_ID, BASE_SYN_OWNER, BASE_SYN_NAME)
as
select s.obj#, u.name, o.name, bo.obj#, s.owner, s.name
from sys.syn$ s, sys.obj$ o, sys.user$ u, sys.obj$ bo, sys.user$ bu
where s.obj# = o.obj#           /* get the obj$ entry for the synonym */
  and o.owner# = u.user#        /* get the owner name for the synonym */
  and s.owner = bu.name         /* get the owner id for the base object */
  and bu.user# = bo.owner#      /* get the obj$ entry for the base object */
  and s.name = bo.name          /* get the obj$ entry for the base object */
  and bo.type# = 5              /* restrict to synonyms for synonyms */
/

rem
rem bug 3369744:
rem The view _ALL_SYNONYMS_FOR_AUTH_OBJECTS is a support view for ALL_SYNONYMS.
rem This view is for internal use only and may change without notice.
rem It gives the list of synonyms that are defined directly
rem for an accessible object (and not for another synonym).
rem If the synonym is for an object via a database link,
rem then it won't appear here, because we have no way of knowing
rem whether remote objects are accessible or not.
rem The view should not be publicly viewable (no grants or public synonyms).
rem

create or replace view "_ALL_SYNONYMS_FOR_AUTH_OBJECTS"
    (SYN_ID, BASE_OBJ_OWNER, BASE_OBJ_NAME)
as
select s.obj#, s.owner, s.name
from sys.syn$ s, sys.obj$ bo, sys.user$ bu, sys.objauth$ oa
where s.owner = bu.name
  and bu.user# = bo.owner#
  and s.name = bo.name
  and bo.obj# = oa.obj#
  and s.node is null /* don't know accessibility if synonym for db link */
  /* user has any privs on base object */
  and ( oa.grantee# in (select kzsrorol from x$kzsro)
     or oa.grantor# = USERENV('SCHEMAID')
     )
/

rem
rem bug 3369744:
rem The view _ALL_SYNONYMS_TREE is a support view for ALL_SYNONYMS.
rem The view is for internal use only and may change without notice.
rem It gives the hierarchical tree of synonyms that ultimately point
rem to a base object that is accessible by the current user and session.
rem It may perform poorly, due to the CONNECT BY clause.
rem It should not be made publicly viewable (no grants or public synonyms).
rem

create or replace view "_ALL_SYNONYMS_TREE"
    (SYN_ID, SYN_OWNER, SYN_NAME, BASE_SYN_ID, BASE_SYN_OWNER, BASE_SYN_NAME)
as
select s.syn_id, s.syn_owner, s.syn_name,
       s.base_syn_id, s.base_syn_owner, s.base_syn_name
from sys."_ALL_SYNONYMS_FOR_SYNONYMS" s
/* user has any privs on ultimate base object */
start with exists (
  select null
  from sys."_ALL_SYNONYMS_FOR_AUTH_OBJECTS" sa
  where s.base_syn_id = sa.syn_id
  )
connect by prior s.syn_id = s.base_syn_id
/

rem
rem The view ALL_SYNONYMS shows synonyms that are "accessible"
rem to the current user and session.
rem That includes all private synonyms (owned by the user);
rem plus all public synonyms;
rem plus synonyms that ultimately resolve to a base object
rem that is accessible to the current user and session.
rem The latter condition includes synonyms that resolve
rem through a chain of synonyms to an accessible base object.
rem Finally, if the user has special privileges,
rem then we also show all synonyms that point to local objects.
rem

create or replace view ALL_SYNONYMS
    (OWNER, SYNONYM_NAME, TABLE_OWNER, TABLE_NAME, DB_LINK)
as
select u.name, o.name, s.owner, s.name, s.node
from sys.user$ u, sys.syn$ s, sys.obj$ o
where o.obj# = s.obj#
  and o.type# = 5
  and o.owner# = u.user#
  and (
       o.owner# in (USERENV('SCHEMAID'), 1 /* PUBLIC */)  /* user's private, any public */
       or /* user has any privs on base object in local database */
        exists
        (select null
         from sys.objauth$ ba, sys.obj$ bo, sys.user$ bu
         where s.node is null /* don't know accessibility if syn for db link */
           and bu.name = s.owner
           and bo.name = s.name
           and bu.user# = bo.owner#
           and ba.obj# = bo.obj#
           and (   ba.grantee# in (select kzsrorol from x$kzsro)
                or ba.grantor# = USERENV('SCHEMAID')
               )
        )
       or /* local object, and user has system privileges */
         (s.node is null /* don't know accessibility if syn is for db link */
          and exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                     )
         )
       )
union
select u.name, o.name, s.owner, s.name, s.node
from sys.user$ u, sys.syn$ s, sys.obj$ o, sys."_ALL_SYNONYMS_TREE" st
where o.obj# = s.obj#
  and o.type# = 5
  and o.owner# = u.user#
  and o.obj# = st.syn_id /* syn is in tree pointing to accessible base obj */
  and s.obj# = st.syn_id /* syn is in tree pointing to accessible base obj */
/

comment on table ALL_SYNONYMS is
'All synonyms for base objects accessible to the user and session'
/
comment on column ALL_SYNONYMS.OWNER is
'Owner of the synonym'
/
comment on column ALL_SYNONYMS.SYNONYM_NAME is
'Name of the synonym'
/
comment on column ALL_SYNONYMS.TABLE_OWNER is
'Owner of the object referenced by the synonym'
/
comment on column ALL_SYNONYMS.TABLE_NAME is
'Name of the object referenced by the synonym'
/
comment on column ALL_SYNONYMS.DB_LINK is
'Name of the database link referenced in a remote synonym'
/
create or replace public synonym ALL_SYNONYMS for ALL_SYNONYMS
/
grant select on ALL_SYNONYMS to PUBLIC with grant option
/

remark
remark  FAMILY "TABLES"
remark  CREATE TABLE parameters.
remark
create or replace view USER_TABLES
    (TABLE_NAME, TABLESPACE_NAME, CLUSTER_NAME, IOT_NAME, STATUS,
     PCT_FREE, PCT_USED,
     INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS, LOGGING,
     BACKED_UP, NUM_ROWS, BLOCKS, EMPTY_BLOCKS,
     AVG_SPACE, CHAIN_CNT, AVG_ROW_LEN,
     AVG_SPACE_FREELIST_BLOCKS, NUM_FREELIST_BLOCKS,
     DEGREE, INSTANCES, CACHE, TABLE_LOCK,
     SAMPLE_SIZE, LAST_ANALYZED, PARTITIONED,
     IOT_TYPE, TEMPORARY, SECONDARY, NESTED,
     BUFFER_POOL, ROW_MOVEMENT,
     GLOBAL_STATS, USER_STATS, DURATION, SKIP_CORRUPT, MONITORING,
     CLUSTER_OWNER, DEPENDENCIES, COMPRESSION, DROPPED)
as
select o.name, decode(bitand(t.property, 2151678048), 0, ts.name, null),
       decode(bitand(t.property, 1024), 0, null, co.name),
       decode((bitand(t.property, 512)+bitand(t.flags, 536870912)),
              0, null, co.name),
       decode(bitand(t.trigflag, 1073741824), 1073741824, 'UNUSABLE', 'VALID'),
       decode(bitand(t.property, 32+64), 0, mod(t.pctfree$, 100), 64, 0, null),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
          decode(bitand(t.property, 32+64), 0, t.pctused$, 64, 0, null)),
       decode(bitand(t.property, 32), 0, t.initrans, null),
       decode(bitand(t.property, 32), 0, t.maxtrans, null),
       s.iniexts * ts.blocksize,
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
                                      s.extsize * ts.blocksize),
       s.minexts, s.maxexts,
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
                                      s.extpct),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
         decode(bitand(o.flags, 2), 2, 1, decode(s.lists, 0, 1, s.lists))),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
         decode(bitand(o.flags, 2), 2, 1, decode(s.groups, 0, 1, s.groups))),
       decode(bitand(t.property, 32+64), 0,
                decode(bitand(t.flags, 32), 0, 'YES', 'NO'), null),
       decode(bitand(t.flags,1), 0, 'Y', 1, 'N', '?'),
       t.rowcnt,
       decode(bitand(t.property, 64), 0, t.blkcnt, null),
       decode(bitand(t.property, 64), 0, t.empcnt, null),
       decode(bitand(t.property, 64), 0, t.avgspc, null),
       t.chncnt, t.avgrln, t.avgspc_flb,
       decode(bitand(t.property, 64), 0, t.flbcnt, null),
       lpad(decode(t.degree, 32767, 'DEFAULT', nvl(t.degree,1)),10),
       lpad(decode(t.instances, 32767, 'DEFAULT', nvl(t.instances,1)),10),
       lpad(decode(bitand(t.flags, 8), 8, 'Y', 'N'),5),
       decode(bitand(t.flags, 6), 0, 'ENABLED', 'DISABLED'),
       t.samplesize, t.analyzetime,
       decode(bitand(t.property, 32), 32, 'YES', 'NO'),
       decode(bitand(t.property, 64), 64, 'IOT',
               decode(bitand(t.property, 512), 512, 'IOT_OVERFLOW',
               decode(bitand(t.flags, 536870912), 536870912, 'IOT_MAPPING', null))),
       decode(bitand(o.flags, 2), 0, 'N', 2, 'Y', 'N'),
       decode(bitand(o.flags, 16), 0, 'N', 16, 'Y', 'N'),
       decode(bitand(t.property, 8192), 8192, 'YES',
              decode(bitand(t.property, 1), 0, 'NO', 'YES')),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
             decode(s.cachehint, 0, 'DEFAULT', 1, 'KEEP', 2, 'RECYCLE', NULL)),
       decode(bitand(t.flags, 131072), 131072, 'ENABLED', 'DISABLED'),
       decode(bitand(t.flags, 512), 0, 'NO', 'YES'),
       decode(bitand(t.flags, 256), 0, 'NO', 'YES'),
       decode(bitand(o.flags, 2), 0, NULL,
           decode(bitand(t.property, 8388608), 8388608,
                  'SYS$SESSION', 'SYS$TRANSACTION')),
       decode(bitand(t.flags, 1024), 1024, 'ENABLED', 'DISABLED'),
       decode(bitand(o.flags, 2), 2, 'NO',
           decode(bitand(t.property, 2147483648), 2147483648, 'NO',
              decode(ksppcv.ksppstvl, 'TRUE', 'YES', 'NO'))),
       decode(bitand(t.property, 1024), 0, null, cu.name),
       decode(bitand(t.flags, 8388608), 8388608, 'ENABLED', 'DISABLED'),
       decode(bitand(t.property, 32), 32, null,
                decode(bitand(s.spare1, 2048), 2048, 'ENABLED', 'DISABLED')),
       decode(bitand(o.flags, 128), 128, 'YES', 'NO')
from sys.ts$ ts, sys.seg$ s, sys.obj$ co, sys.tab$ t, sys.obj$ o,
     sys.obj$ cx, sys.user$ cu, x$ksppcv ksppcv, x$ksppi ksppi
where o.owner# = userenv('SCHEMAID')
  and o.obj# = t.obj#
  and bitand(t.property, 1) = 0
  and bitand(o.flags, 128) = 0
  and t.bobj# = co.obj# (+)
  and t.ts# = ts.ts#
  and t.file# = s.file# (+)
  and t.block# = s.block# (+)
  and t.ts# = s.ts# (+)
  and t.dataobj# = cx.obj# (+)
  and cx.owner# = cu.user# (+)
  and ksppi.indx = ksppcv.indx
  and ksppi.ksppinm = '_dml_monitoring_enabled'
/
comment on table USER_TABLES is
'Description of the user''s own relational tables'
/
comment on column USER_TABLES.TABLE_NAME is
'Name of the table'
/
comment on column USER_TABLES.TABLESPACE_NAME is
'Name of the tablespace containing the table'
/
comment on column USER_TABLES.CLUSTER_NAME is
'Name of the cluster, if any, to which the table belongs'
/
comment on column USER_TABLES.IOT_NAME is
'Name of the index-only table, if any, to which the overflow or mapping table entry belongs'
/
comment on column USER_TABLES.STATUS is
'Status of the table will be UNUSABLE if a previous DROP TABLE operation failed,
VALID otherwise'
/
comment on column USER_TABLES.PCT_FREE is
'Minimum percentage of free space in a block'
/
comment on column USER_TABLES.PCT_USED is
'Minimum percentage of used space in a block'
/
comment on column USER_TABLES.INI_TRANS is
'Initial number of transactions'
/
comment on column USER_TABLES.MAX_TRANS is
'Maximum number of transactions'
/
comment on column USER_TABLES.INITIAL_EXTENT is
'Size of the initial extent in bytes'
/
comment on column USER_TABLES.NEXT_EXTENT is
'Size of secondary extents in bytes'
/
comment on column USER_TABLES.MIN_EXTENTS is
'Minimum number of extents allowed in the segment'
/
comment on column USER_TABLES.MAX_EXTENTS is
'Maximum number of extents allowed in the segment'
/
comment on column USER_TABLES.PCT_INCREASE is
'Percentage increase in extent size'
/
comment on column USER_TABLES.FREELISTS is
'Number of process freelists allocated in this segment'
/
comment on column USER_TABLES.FREELIST_GROUPS is
'Number of freelist groups allocated in this segment'
/
comment on column USER_TABLES.LOGGING is
'Logging attribute'
/
comment on column USER_TABLES.BACKED_UP is
'Has table been backed up since last modification?'
/
comment on column USER_TABLES.NUM_ROWS is
'The number of rows in the table'
/
comment on column USER_TABLES.BLOCKS is
'The number of used blocks in the table'
/
comment on column USER_TABLES.EMPTY_BLOCKS is
'The number of empty (never used) blocks in the table'
/
comment on column USER_TABLES.AVG_SPACE is
'The average available free space in the table'
/
comment on column USER_TABLES.CHAIN_CNT is
'The number of chained rows in the table'
/
comment on column USER_TABLES.AVG_ROW_LEN is
'The average row length, including row overhead'
/
comment on column USER_TABLES.AVG_SPACE_FREELIST_BLOCKS is
'The average freespace of all blocks on a freelist'
/
comment on column USER_TABLES.NUM_FREELIST_BLOCKS is
'The number of blocks on the freelist'
/
comment on column USER_TABLES.DEGREE is
'The number of threads per instance for scanning the table'
/
comment on column USER_TABLES.INSTANCES is
'The number of instances across which the table is to be scanned'
/
comment on column USER_TABLES.CACHE is
'Whether the table is to be cached in the buffer cache'
/
comment on column USER_TABLES.TABLE_LOCK is
'Whether table locking is enabled or disabled'
/
comment on column USER_TABLES.SAMPLE_SIZE is
'The sample size used in analyzing this table'
/
comment on column USER_TABLES.LAST_ANALYZED is
'The date of the most recent time this table was analyzed'
/
comment on column USER_TABLES.PARTITIONED is
'Is this table partitioned? YES or NO'
/
comment on column USER_TABLES.IOT_TYPE is
'If index-only table, then IOT_TYPE is IOT or IOT_OVERFLOW or IOT_MAPPING else NULL'
/
comment on column USER_TABLES.TEMPORARY is
'Can the current session only see data that it place in this object itself?'
/
comment on column USER_TABLES.SECONDARY is
'Is this table object created as part of icreate for domain indexes?'
/
comment on column USER_TABLES.NESTED is
'Is the table a nested table?'
/
comment on column USER_TABLES.BUFFER_POOL is
'The default buffer pool to be used for table blocks'
/
comment on column USER_TABLES.ROW_MOVEMENT is
'Whether partitioned row movement is enabled or disabled'
/
comment on column USER_TABLES.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column USER_TABLES.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column USER_TABLES.DURATION is
'If temporary table, then duration is sys$session or sys$transaction else NULL'
/
comment on column USER_TABLES.SKIP_CORRUPT is
'Whether skip corrupt blocks is enabled or disabled'
/
comment on column USER_TABLES.MONITORING is
'Should we keep track of the amount of modification?'
/
comment on column USER_TABLES.CLUSTER_OWNER is
'Owner of the cluster, if any, to which the table belongs'
/
comment on column USER_TABLES.DEPENDENCIES is
'Should we keep track of row level dependencies?'
/
comment on column USER_TABLES.COMPRESSION is
'Whether table compression is enabled or not'
/
comment on column USER_TABLES.DROPPED is
'Whether table is dropped and is in Recycle Bin'
/
create or replace public synonym USER_TABLES for USER_TABLES
/
create or replace public synonym TABS for USER_TABLES
/
grant select on USER_TABLES to PUBLIC with grant option
/
create or replace view USER_OBJECT_TABLES
    (TABLE_NAME, TABLESPACE_NAME, CLUSTER_NAME, IOT_NAME, STATUS, 
     PCT_FREE, PCT_USED,
     INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS, LOGGING,
     BACKED_UP, NUM_ROWS, BLOCKS, EMPTY_BLOCKS,
     AVG_SPACE, CHAIN_CNT, AVG_ROW_LEN,
     AVG_SPACE_FREELIST_BLOCKS, NUM_FREELIST_BLOCKS,
     DEGREE, INSTANCES, CACHE, TABLE_LOCK,
     SAMPLE_SIZE, LAST_ANALYZED, PARTITIONED,
     IOT_TYPE, OBJECT_ID_TYPE,
     TABLE_TYPE_OWNER, TABLE_TYPE, TEMPORARY, SECONDARY, NESTED,
     BUFFER_POOL, ROW_MOVEMENT,
     GLOBAL_STATS, USER_STATS, DURATION, SKIP_CORRUPT, MONITORING,
     CLUSTER_OWNER, DEPENDENCIES, COMPRESSION, DROPPED)
as
select o.name, decode(bitand(t.property, 2151678048), 0, ts.name, null),
       decode(bitand(t.property, 1024), 0, null, co.name),
       decode((bitand(t.property, 512)+bitand(t.flags, 536870912)),
              0, null, co.name),           
       decode(bitand(t.trigflag, 1073741824), 1073741824, 'UNUSABLE', 'VALID'),
       decode(bitand(t.property, 32+64), 0, mod(t.pctfree$, 100), 64, 0, null),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
          decode(bitand(t.property, 32+64), 0, t.pctused$, 64, 0, null)),
       decode(bitand(t.property, 32), 0, t.initrans, null),
       decode(bitand(t.property, 32), 0, t.maxtrans, null),
       s.iniexts * ts.blocksize,
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
                                      s.extsize * ts.blocksize),
       s.minexts, s.maxexts,
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
                                      s.extpct),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
         decode(bitand(o.flags, 2), 2, 1, decode(s.lists, 0, 1, s.lists))),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
         decode(bitand(o.flags, 2), 2, 1, decode(s.groups, 0, 1, s.groups))),
       decode(bitand(t.property, 32), 32, null,
                decode(bitand(t.flags, 32), 0, 'YES', 'NO')),
       decode(bitand(t.flags,1), 0, 'Y', 1, 'N', '?'),
       t.rowcnt,
       decode(bitand(t.property, 64), 0, t.blkcnt, null),
       decode(bitand(t.property, 64), 0, t.empcnt, null),
       decode(bitand(t.property, 64), 0, t.avgspc, null),
       t.chncnt, t.avgrln, t.avgspc_flb,
       decode(bitand(t.property, 64), 0, t.flbcnt, null),
       lpad(decode(t.degree, 32767, 'DEFAULT', nvl(t.degree,1)),10),
       lpad(decode(t.instances, 32767, 'DEFAULT', nvl(t.instances,1)),10),
       lpad(decode(bitand(t.flags, 8), 8, 'Y', 'N'),5),
       decode(bitand(t.flags, 6), 0, 'ENABLED', 'DISABLED'),
       t.samplesize, t.analyzetime,
       decode(bitand(t.property, 32), 32, 'YES', 'NO'),
       decode(bitand(t.property, 64), 64, 'IOT',
               decode(bitand(t.property, 512), 512, 'IOT_OVERFLOW',
               decode(bitand(t.flags, 536870912), 536870912, 'IOT_MAPPING', null))),
       decode(bitand(t.property, 4096), 4096, 'USER-DEFINED',
                                              'SYSTEM GENERATED'),
       nvl2(ac.synobj#, su.name, tu.name),
       nvl2(ac.synobj#, so.name, ty.name),
       decode(bitand(o.flags, 2), 0, 'N', 2, 'Y', 'N'),
       decode(bitand(o.flags, 16), 0, 'N', 16, 'Y', 'N'),
       decode(bitand(t.property, 8192), 8192, 'YES', 'NO'),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
             decode(s.cachehint, 0, 'DEFAULT', 1, 'KEEP', 2, 'RECYCLE', NULL)),
       decode(bitand(t.flags, 131072), 131072, 'ENABLED', 'DISABLED'),
       decode(bitand(t.flags, 512), 0, 'NO', 'YES'),
       decode(bitand(t.flags, 256), 0, 'NO', 'YES'),
       decode(bitand(o.flags, 2), 0, NULL,
          decode(bitand(t.property, 8388608), 8388608,
                 'SYS$SESSION', 'SYS$TRANSACTION')),
       decode(bitand(t.flags, 1024), 1024, 'ENABLED', 'DISABLED'),
       decode(bitand(o.flags, 2), 2, 'NO',
           decode(bitand(t.property, 2147483648), 2147483648, 'NO',
              decode(ksppcv.ksppstvl, 'TRUE', 'YES', 'NO'))),
       decode(bitand(t.property, 1024), 0, null, cu.name),
       decode(bitand(t.flags, 8388608), 8388608, 'ENABLED', 'DISABLED'),
       decode(bitand(t.property, 32), 32, null,
                decode(bitand(s.spare1, 2048), 2048, 'ENABLED', 'DISABLED')),
       decode(bitand(o.flags, 128), 128, 'YES', 'NO')
from sys.ts$ ts, sys.seg$ s, sys.obj$ co, sys.tab$ t, sys.obj$ o,
     sys.coltype$ ac, sys.obj$ ty, sys.user$ tu, sys.col$ tc,
     sys.obj$ cx, sys.user$ cu, sys.obj$ so, sys.user$ su,
     x$ksppcv ksppcv, x$ksppi ksppi
where o.owner# = userenv('SCHEMAID')
  and o.obj# = t.obj#
  and bitand(t.property, 1) = 1
  and bitand(o.flags, 128) = 0
  and t.obj# = tc.obj#
  and tc.name = 'SYS_NC_ROWINFO$'
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and ac.toid = ty.oid$
  and ty.type# <> 10
  and ty.owner# = tu.user#
  and t.bobj# = co.obj# (+)
  and t.ts# = ts.ts#
  and t.file# = s.file# (+)
  and t.block# = s.block# (+)
  and t.ts# = s.ts# (+)
  and t.dataobj# = cx.obj# (+)
  and cx.owner# = cu.user# (+)
  and ac.synobj# = so.obj# (+)
  and so.owner# = su.user# (+)
  and ksppi.indx = ksppcv.indx
  and ksppi.ksppinm = '_dml_monitoring_enabled'
/
comment on table USER_OBJECT_TABLES is
'Description of the user''s own object tables'
/
comment on column USER_OBJECT_TABLES.TABLE_NAME is
'Name of the table'
/
comment on column USER_OBJECT_TABLES.TABLESPACE_NAME is
'Name of the tablespace containing the table'
/
comment on column USER_OBJECT_TABLES.CLUSTER_NAME is
'Name of the cluster, if any, to which the table belongs'
/
comment on column USER_OBJECT_TABLES.IOT_NAME is
'Name of the index-only table, if any, to which the overflow or mapping table
entry belongs'
/
comment on column USER_OBJECT_TABLES.STATUS is
'Status of the table will be UNUSABLE if a previous DROP TABLE operation failed,
VALID otherwise'
/
comment on column USER_OBJECT_TABLES.PCT_FREE is
'Minimum percentage of free space in a block'
/
comment on column USER_OBJECT_TABLES.PCT_USED is
'Minimum percentage of used space in a block'
/
comment on column USER_OBJECT_TABLES.INI_TRANS is
'Initial number of transactions'
/
comment on column USER_OBJECT_TABLES.MAX_TRANS is
'Maximum number of transactions'
/
comment on column USER_OBJECT_TABLES.INITIAL_EXTENT is
'Size of the initial extent in bytes'
/
comment on column USER_OBJECT_TABLES.NEXT_EXTENT is
'Size of secondary extents in bytes'
/
comment on column USER_OBJECT_TABLES.MIN_EXTENTS is
'Minimum number of extents allowed in the segment'
/
comment on column USER_OBJECT_TABLES.MAX_EXTENTS is
'Maximum number of extents allowed in the segment'
/
comment on column USER_OBJECT_TABLES.PCT_INCREASE is
'Percentage increase in extent size'
/
comment on column USER_OBJECT_TABLES.FREELISTS is
'Number of process freelists allocated in this segment'
/
comment on column USER_OBJECT_TABLES.FREELIST_GROUPS is
'Number of freelist groups allocated in this segment'
/
comment on column USER_OBJECT_TABLES.LOGGING is
'Logging attribute'
/
comment on column USER_OBJECT_TABLES.BACKED_UP is
'Has table been backed up since last modification?'
/
comment on column USER_OBJECT_TABLES.NUM_ROWS is
'The number of rows in the table'
/
comment on column USER_OBJECT_TABLES.BLOCKS is
'The number of used blocks in the table'
/
comment on column USER_OBJECT_TABLES.EMPTY_BLOCKS is
'The number of empty (never used) blocks in the table'
/
comment on column USER_OBJECT_TABLES.AVG_SPACE is
'The average available free space in the table'
/
comment on column USER_OBJECT_TABLES.CHAIN_CNT is
'The number of chained rows in the table'
/
comment on column USER_OBJECT_TABLES.AVG_ROW_LEN is
'The average row length, including row overhead'
/
comment on column USER_OBJECT_TABLES.AVG_SPACE_FREELIST_BLOCKS is
'The average freespace of all blocks on a freelist'
/
comment on column USER_OBJECT_TABLES.NUM_FREELIST_BLOCKS is
'The number of blocks on the freelist'
/
comment on column USER_OBJECT_TABLES.DEGREE is
'The number of threads per instance for scanning the table'
/
comment on column USER_OBJECT_TABLES.INSTANCES is
'The number of instances across which the table is to be scanned'
/
comment on column USER_OBJECT_TABLES.CACHE is
'Whether the table is to be cached in the buffer cache'
/
comment on column USER_OBJECT_TABLES.TABLE_LOCK is
'Whether table locking is enabled or disabled'
/
comment on column USER_OBJECT_TABLES.SAMPLE_SIZE is
'The sample size used in analyzing this table'
/
comment on column USER_OBJECT_TABLES.LAST_ANALYZED is
'The date of the most recent time this table was analyzed'
/
comment on column USER_OBJECT_TABLES.PARTITIONED is
'Is this table partitioned? YES or NO'
/
comment on column USER_OBJECT_TABLES.IOT_TYPE is
'If index-only table, then IOT_TYPE is IOT or IOT_OVERFLOW or IOT_MAPPING else NULL'
/
comment on column USER_OBJECT_TABLES.OBJECT_ID_TYPE is
'If user-defined OID, then USER-DEFINED, else if system generated OID, then SYSTEM GENERATED'
/
comment on column USER_OBJECT_TABLES.TABLE_TYPE_OWNER is
'Owner of the type of the table if the table is an object table'
/
comment on column USER_OBJECT_TABLES.TABLE_TYPE is
'Type of the table if the table is an object table'
/
comment on column USER_OBJECT_TABLES.TEMPORARY is
'Can the current session only see data that it place in this object itself?'
/
comment on column USER_OBJECT_TABLES.SECONDARY is
'Is this table object created as part of icreate for domain indexes?'
/
comment on column USER_OBJECT_TABLES.NESTED is
'Is the table a nested table?'
/
comment on column USER_OBJECT_TABLES.BUFFER_POOL is
'The default buffer pool to be used for table blocks'
/
comment on column USER_OBJECT_TABLES.ROW_MOVEMENT is
'Whether partitioned row movement is enabled or disabled'
/
comment on column USER_OBJECT_TABLES.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column USER_OBJECT_TABLES.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column USER_OBJECT_TABLES.DURATION is
'If temporary table, then duration is sys$session or sys$transaction else NULL'
/
comment on column USER_OBJECT_TABLES.SKIP_CORRUPT is
'Whether skip corrupt blocks is enabled or disabled'
/
comment on column USER_OBJECT_TABLES.MONITORING is
'Should we keep track of the amount of modification?'
/
comment on column USER_OBJECT_TABLES.CLUSTER_OWNER is
'Owner of the cluster, if any, to which the table belongs'
/
comment on column USER_OBJECT_TABLES.DEPENDENCIES is
'Should we keep track of row level dependencies?'
/
comment on column USER_OBJECT_TABLES.COMPRESSION is
'Whether table compression is enabled or not'
/
comment on column USER_OBJECT_TABLES.DROPPED is
'Whether table is dropped and is in Recycle Bin'
/
create or replace public synonym USER_OBJECT_TABLES for USER_OBJECT_TABLES
/
grant select on USER_OBJECT_TABLES to PUBLIC with grant option
/
create or replace view USER_ALL_TABLES
    (TABLE_NAME, TABLESPACE_NAME, CLUSTER_NAME, IOT_NAME, STATUS,
     PCT_FREE, PCT_USED,
     INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS, LOGGING,
     BACKED_UP, NUM_ROWS, BLOCKS, EMPTY_BLOCKS,
     AVG_SPACE, CHAIN_CNT, AVG_ROW_LEN,
     AVG_SPACE_FREELIST_BLOCKS, NUM_FREELIST_BLOCKS,
     DEGREE, INSTANCES, CACHE, TABLE_LOCK,
     SAMPLE_SIZE, LAST_ANALYZED, PARTITIONED,
     IOT_TYPE, OBJECT_ID_TYPE,
     TABLE_TYPE_OWNER, TABLE_TYPE, TEMPORARY, SECONDARY, NESTED,
     BUFFER_POOL, ROW_MOVEMENT,
     GLOBAL_STATS, USER_STATS, DURATION, SKIP_CORRUPT, MONITORING,
     CLUSTER_OWNER, DEPENDENCIES, COMPRESSION, DROPPED)
as
select TABLE_NAME, TABLESPACE_NAME, CLUSTER_NAME, IOT_NAME, STATUS, 
     PCT_FREE, PCT_USED,
     INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS, LOGGING,
     BACKED_UP, NUM_ROWS, BLOCKS, EMPTY_BLOCKS,
     AVG_SPACE, CHAIN_CNT, AVG_ROW_LEN,
     AVG_SPACE_FREELIST_BLOCKS, NUM_FREELIST_BLOCKS,
     DEGREE, INSTANCES, CACHE, TABLE_LOCK,
     SAMPLE_SIZE, LAST_ANALYZED, PARTITIONED,
     IOT_TYPE,
     NULL, NULL, NULL, TEMPORARY, SECONDARY, NESTED,
     BUFFER_POOL, ROW_MOVEMENT,
     GLOBAL_STATS, USER_STATS, DURATION, SKIP_CORRUPT, MONITORING,
     CLUSTER_OWNER, DEPENDENCIES, COMPRESSION, DROPPED
from user_tables
union all
select TABLE_NAME, TABLESPACE_NAME, CLUSTER_NAME, IOT_NAME, STATUS,
     PCT_FREE, PCT_USED,
     INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS, LOGGING,
     BACKED_UP, NUM_ROWS, BLOCKS, EMPTY_BLOCKS,
     AVG_SPACE, CHAIN_CNT, AVG_ROW_LEN,
     AVG_SPACE_FREELIST_BLOCKS, NUM_FREELIST_BLOCKS,
     DEGREE, INSTANCES, CACHE, TABLE_LOCK,
     SAMPLE_SIZE, LAST_ANALYZED, PARTITIONED,
     IOT_TYPE, OBJECT_ID_TYPE,
     TABLE_TYPE_OWNER, TABLE_TYPE, TEMPORARY, SECONDARY, NESTED,
     BUFFER_POOL, ROW_MOVEMENT,
     GLOBAL_STATS, USER_STATS, DURATION, SKIP_CORRUPT, MONITORING,
     CLUSTER_OWNER, DEPENDENCIES, COMPRESSION, DROPPED
from user_object_tables
/
comment on table USER_ALL_TABLES is
'Description of all object and relational tables owned by the user''s'
/
comment on column USER_ALL_TABLES.TABLE_NAME is
'Name of the table'
/
comment on column USER_ALL_TABLES.TABLESPACE_NAME is
'Name of the tablespace containing the table'
/
comment on column USER_ALL_TABLES.CLUSTER_NAME is
'Name of the cluster, if any, to which the table belongs'
/
comment on column USER_ALL_TABLES.IOT_NAME is
'Name of the index-only table, if any, to which the overflow or mapping table entry belongs'
/
comment on column USER_ALL_TABLES.STATUS is
'Status of the table will be UNUSABLE if a previous DROP TABLE operation failed,
VALID otherwise'
/
comment on column USER_ALL_TABLES.PCT_FREE is
'Minimum percentage of free space in a block'
/
comment on column USER_ALL_TABLES.PCT_USED is
'Minimum percentage of used space in a block'
/
comment on column USER_ALL_TABLES.INI_TRANS is
'Initial number of transactions'
/
comment on column USER_ALL_TABLES.MAX_TRANS is
'Maximum number of transactions'
/
comment on column USER_ALL_TABLES.INITIAL_EXTENT is
'Size of the initial extent in bytes'
/
comment on column USER_ALL_TABLES.NEXT_EXTENT is
'Size of secondary extents in bytes'
/
comment on column USER_ALL_TABLES.MIN_EXTENTS is
'Minimum number of extents allowed in the segment'
/
comment on column USER_ALL_TABLES.MAX_EXTENTS is
'Maximum number of extents allowed in the segment'
/
comment on column USER_ALL_TABLES.PCT_INCREASE is
'Percentage increase in extent size'
/
comment on column USER_ALL_TABLES.FREELISTS is
'Number of process freelists allocated in this segment'
/
comment on column USER_ALL_TABLES.FREELIST_GROUPS is
'Number of freelist groups allocated in this segment'
/
comment on column USER_ALL_TABLES.LOGGING is
'Logging attribute'
/
comment on column USER_ALL_TABLES.BACKED_UP is
'Has table been backed up since last modification?'
/
comment on column USER_ALL_TABLES.NUM_ROWS is
'The number of rows in the table'
/
comment on column USER_ALL_TABLES.BLOCKS is
'The number of used blocks in the table'
/
comment on column USER_ALL_TABLES.EMPTY_BLOCKS is
'The number of empty (never used) blocks in the table'
/
comment on column USER_ALL_TABLES.AVG_SPACE is
'The average available free space in the table'
/
comment on column USER_ALL_TABLES.CHAIN_CNT is
'The number of chained rows in the table'
/
comment on column USER_ALL_TABLES.AVG_ROW_LEN is
'The average row length, including row overhead'
/
comment on column USER_ALL_TABLES.AVG_SPACE_FREELIST_BLOCKS is
'The average freespace of all blocks on a freelist'
/
comment on column USER_ALL_TABLES.NUM_FREELIST_BLOCKS is
'The number of blocks on the freelist'
/
comment on column USER_ALL_TABLES.DEGREE is
'The number of threads per instance for scanning the table'
/
comment on column USER_ALL_TABLES.INSTANCES is
'The number of instances across which the table is to be scanned'
/
comment on column USER_ALL_TABLES.CACHE is
'Whether the table is to be cached in the buffer cache'
/
comment on column USER_ALL_TABLES.TABLE_LOCK is
'Whether table locking is enabled or disabled'
/
comment on column USER_ALL_TABLES.SAMPLE_SIZE is
'The sample size used in analyzing this table'
/
comment on column USER_ALL_TABLES.LAST_ANALYZED is
'The date of the most recent time this table was analyzed'
/
comment on column USER_ALL_TABLES.PARTITIONED is
'Is this table partitioned? YES or NO'
/
comment on column USER_ALL_TABLES.IOT_TYPE is
'If index-only table, then IOT_TYPE is IOT or IOT_OVERFLOW or IOT_MAPPING else NULL'
/
comment on column USER_ALL_TABLES.OBJECT_ID_TYPE is
'If user-defined OID, then USER-DEFINED, else if system generated OID, then SYST
EM GENERATED'
/
comment on column USER_ALL_TABLES.TABLE_TYPE_OWNER is
'Owner of the type of the table if the table is an object table'
/
comment on column USER_ALL_TABLES.TABLE_TYPE is
'Type of the table if the table is an object table'
/
comment on column USER_ALL_TABLES.TEMPORARY is
'Can the current session only see data that it place in this object itself?'
/
comment on column USER_ALL_TABLES.SECONDARY is
'Is this table object created as part of icreate for domain indexes?'
/
comment on column USER_ALL_TABLES.NESTED is
'Is the table a nested table?'
/
comment on column USER_ALL_TABLES.BUFFER_POOL is
'The default buffer pool to be used for table blocks'
/
comment on column USER_ALL_TABLES.ROW_MOVEMENT is
'Whether partitioned row movement is enabled or disabled'
/
comment on column USER_ALL_TABLES.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column USER_ALL_TABLES.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column USER_ALL_TABLES.DURATION is
'If temporary table, then duration is sys$session or sys$transaction else NULL'
/
comment on column USER_ALL_TABLES.SKIP_CORRUPT is
'Whether skip corrupt blocks is enabled or disabled'
/
comment on column USER_ALL_TABLES.MONITORING is
'Should we keep track of the amount of modification?'
/
comment on column USER_ALL_TABLES.CLUSTER_OWNER is
'Owner of the cluster, if any, to which the table belongs'
/
comment on column USER_ALL_TABLES.DEPENDENCIES is
'Should we keep track of row level dependencies?'
/
comment on column USER_ALL_TABLES.COMPRESSION is
'Whether table compression is enabled or not'
/
comment on column USER_ALL_TABLES.DROPPED is
'Whether table is dropped and is in Recycle Bin'
/
create or replace public synonym USER_ALL_TABLES for USER_ALL_TABLES
/
grant select on USER_ALL_TABLES to PUBLIC with grant option
/
create or replace view ALL_TABLES
    (OWNER, TABLE_NAME, TABLESPACE_NAME, CLUSTER_NAME, IOT_NAME, STATUS,
     PCT_FREE, PCT_USED,
     INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS, LOGGING,
     BACKED_UP, NUM_ROWS, BLOCKS, EMPTY_BLOCKS,
     AVG_SPACE, CHAIN_CNT, AVG_ROW_LEN,
     AVG_SPACE_FREELIST_BLOCKS, NUM_FREELIST_BLOCKS,
     DEGREE, INSTANCES, CACHE, TABLE_LOCK,
     SAMPLE_SIZE, LAST_ANALYZED, PARTITIONED,
     IOT_TYPE, TEMPORARY, SECONDARY, NESTED,
     BUFFER_POOL, ROW_MOVEMENT,
     GLOBAL_STATS, USER_STATS, DURATION, SKIP_CORRUPT, MONITORING,
     CLUSTER_OWNER, DEPENDENCIES, COMPRESSION, DROPPED)
as
select u.name, o.name,decode(bitand(t.property, 2151678048), 0, ts.name, null),
       decode(bitand(t.property, 1024), 0, null, co.name),
       decode((bitand(t.property, 512)+bitand(t.flags, 536870912)),
              0, null, co.name),
       decode(bitand(t.trigflag, 1073741824), 1073741824, 'UNUSABLE', 'VALID'),
       decode(bitand(t.property, 32+64), 0, mod(t.pctfree$, 100), 64, 0, null),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
          decode(bitand(t.property, 32+64), 0, t.pctused$, 64, 0, null)),
       decode(bitand(t.property, 32), 0, t.initrans, null),
       decode(bitand(t.property, 32), 0, t.maxtrans, null),
       s.iniexts * ts.blocksize,
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
                                      s.extsize * ts.blocksize),
       s.minexts, s.maxexts,
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
                                      s.extpct),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
         decode(bitand(o.flags, 2), 2, 1, decode(s.lists, 0, 1, s.lists))),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
         decode(bitand(o.flags, 2), 2, 1, decode(s.groups, 0, 1, s.groups))),
       decode(bitand(t.property, 32+64), 0,
                decode(bitand(t.flags, 32), 0, 'YES', 'NO'), null),
       decode(bitand(t.flags,1), 0, 'Y', 1, 'N', '?'),
       t.rowcnt,
       decode(bitand(t.property, 64), 0, t.blkcnt, null),
       decode(bitand(t.property, 64), 0, t.empcnt, null),
       decode(bitand(t.property, 64), 0, t.avgspc, null),
       t.chncnt, t.avgrln, t.avgspc_flb,
       decode(bitand(t.property, 64), 0, t.flbcnt, null),
       lpad(decode(t.degree, 32767, 'DEFAULT', nvl(t.degree,1)),10),
       lpad(decode(t.instances, 32767, 'DEFAULT', nvl(t.instances,1)),10),
       lpad(decode(bitand(t.flags, 8), 8, 'Y', 'N'),5),
       decode(bitand(t.flags, 6), 0, 'ENABLED', 'DISABLED'),
       t.samplesize, t.analyzetime,
       decode(bitand(t.property, 32), 32, 'YES', 'NO'),
       decode(bitand(t.property, 64), 64, 'IOT',
               decode(bitand(t.property, 512), 512, 'IOT_OVERFLOW',
               decode(bitand(t.flags, 536870912), 536870912, 'IOT_MAPPING', null))),
       decode(bitand(o.flags, 2), 0, 'N', 2, 'Y', 'N'),
       decode(bitand(o.flags, 16), 0, 'N', 16, 'Y', 'N'),
       decode(bitand(t.property, 8192), 8192, 'YES',
              decode(bitand(t.property, 1), 0, 'NO', 'YES')),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
             decode(s.cachehint, 0, 'DEFAULT', 1, 'KEEP', 2, 'RECYCLE', NULL)),
       decode(bitand(t.flags, 131072), 131072, 'ENABLED', 'DISABLED'),
       decode(bitand(t.flags, 512), 0, 'NO', 'YES'),
       decode(bitand(t.flags, 256), 0, 'NO', 'YES'),
       decode(bitand(o.flags, 2), 0, NULL,
          decode(bitand(t.property, 8388608), 8388608,
                 'SYS$SESSION', 'SYS$TRANSACTION')),
       decode(bitand(t.flags, 1024), 1024, 'ENABLED', 'DISABLED'),
       decode(bitand(o.flags, 2), 2, 'NO',
           decode(bitand(t.property, 2147483648), 2147483648, 'NO',
              decode(ksppcv.ksppstvl, 'TRUE', 'YES', 'NO'))),
       decode(bitand(t.property, 1024), 0, null, cu.name),
       decode(bitand(t.flags, 8388608), 8388608, 'ENABLED', 'DISABLED'),
       decode(bitand(t.property, 32), 32, null,
                decode(bitand(s.spare1, 2048), 2048, 'ENABLED', 'DISABLED')),
       decode(bitand(o.flags, 128), 128, 'YES', 'NO')
from sys.user$ u, sys.ts$ ts, sys.seg$ s, sys.obj$ co, sys.tab$ t, sys.obj$ o,
     sys.obj$ cx, sys.user$ cu, x$ksppcv ksppcv, x$ksppi ksppi
where o.owner# = u.user#
  and o.obj# = t.obj#
  and bitand(t.property, 1) = 0
  and bitand(o.flags, 128) = 0
  and t.bobj# = co.obj# (+)
  and t.ts# = ts.ts#
  and t.file# = s.file# (+)
  and t.block# = s.block# (+)
  and t.ts# = s.ts# (+)
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
  and t.dataobj# = cx.obj# (+)
  and cx.owner# = cu.user# (+)
  and ksppi.indx = ksppcv.indx
  and ksppi.ksppinm = '_dml_monitoring_enabled'
/
comment on table ALL_TABLES is
'Description of relational tables accessible to the user'
/
comment on column ALL_TABLES.OWNER is
'Owner of the table'
/
comment on column ALL_TABLES.TABLE_NAME is
'Name of the table'
/
comment on column ALL_TABLES.TABLESPACE_NAME is
'Name of the tablespace containing the table'
/
comment on column ALL_TABLES.CLUSTER_NAME is
'Name of the cluster, if any, to which the table belongs'
/
comment on column ALL_TABLES.IOT_NAME is
'Name of the index-only table, if any, to which the overflow or mapping table entry belongs'
/
comment on column ALL_TABLES.STATUS is
'Status of the table will be UNUSABLE if a previous DROP TABLE operation failed,
VALID otherwise'
/
comment on column ALL_TABLES.PCT_FREE is
'Minimum percentage of free space in a block'
/
comment on column ALL_TABLES.PCT_USED is
'Minimum percentage of used space in a block'
/
comment on column ALL_TABLES.INI_TRANS is
'Initial number of transactions'
/
comment on column ALL_TABLES.MAX_TRANS is
'Maximum number of transactions'
/
comment on column ALL_TABLES.INITIAL_EXTENT is
'Size of the initial extent in bytes'
/
comment on column ALL_TABLES.NEXT_EXTENT is
'Size of secondary extents in bytes'
/
comment on column ALL_TABLES.MIN_EXTENTS is
'Minimum number of extents allowed in the segment'
/
comment on column ALL_TABLES.MAX_EXTENTS is
'Maximum number of extents allowed in the segment'
/
comment on column ALL_TABLES.PCT_INCREASE is
'Percentage increase in extent size'
/
comment on column ALL_TABLES.FREELISTS is
'Number of process freelists allocated in this segment'
/
comment on column ALL_TABLES.FREELIST_GROUPS is
'Number of freelist groups allocated in this segment'
/
comment on column ALL_TABLES.LOGGING is
'Logging attribute'
/
comment on column ALL_TABLES.BACKED_UP is
'Has table been backed up since last modification?'
/
comment on column ALL_TABLES.NUM_ROWS is
'The number of rows in the table'
/
comment on column ALL_TABLES.BLOCKS is
'The number of used blocks in the table'
/
comment on column ALL_TABLES.EMPTY_BLOCKS is
'The number of empty (never used) blocks in the table'
/
comment on column ALL_TABLES.AVG_SPACE is
'The average available free space in the table'
/
comment on column ALL_TABLES.CHAIN_CNT is
'The number of chained rows in the table'
/
comment on column ALL_TABLES.AVG_ROW_LEN is
'The average row length, including row overhead'
/
comment on column ALL_TABLES.AVG_SPACE_FREELIST_BLOCKS is
'The average freespace of all blocks on a freelist'
/
comment on column ALL_TABLES.NUM_FREELIST_BLOCKS is
'The number of blocks on the freelist'
/
comment on column ALL_TABLES.DEGREE is
'The number of threads per instance for scanning the table'
/
comment on column ALL_TABLES.INSTANCES is
'The number of instances across which the table is to be scanned'
/
comment on column ALL_TABLES.CACHE is
'Whether the table is to be cached in the buffer cache'
/
comment on column ALL_TABLES.TABLE_LOCK is
'Whether table locking is enabled or disabled'
/
comment on column ALL_TABLES.SAMPLE_SIZE is
'The sample size used in analyzing this table'
/
comment on column ALL_TABLES.LAST_ANALYZED is
'The date of the most recent time this table was analyzed'
/
comment on column ALL_TABLES.PARTITIONED is
'Is this table partitioned? YES or NO'
/
comment on column ALL_TABLES.IOT_TYPE is
'If index-only table, then IOT_TYPE is IOT or IOT_OVERFLOW or IOT_MAPPING else NULL'
/
comment on column ALL_TABLES.TEMPORARY is
'Can the current session only see data that it place in this object itself?'
/
comment on column ALL_TABLES.SECONDARY is
'Is this table object created as part of icreate for domain indexes?'
/
comment on column ALL_TABLES.NESTED is
'Is the table a nested table?'
/
comment on column ALL_TABLES.BUFFER_POOL is
'The default buffer pool to be used for table blocks'
/
comment on column ALL_TABLES.ROW_MOVEMENT is
'Whether partitioned row movement is enabled or disabled'
/
comment on column ALL_TABLES.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column ALL_TABLES.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column ALL_TABLES.DURATION is
'If temporary table, then duration is sys$session or sys$transaction else NULL'
/
comment on column ALL_TABLES.SKIP_CORRUPT is
'Whether skip corrupt blocks is enabled or disabled'
/
comment on column ALL_TABLES.MONITORING is
'Should we keep track of the amount of modification?'
/
comment on column ALL_TABLES.CLUSTER_OWNER is
'Owner of the cluster, if any, to which the table belongs'
/
comment on column ALL_TABLES.DEPENDENCIES is
'Should we keep track of row level dependencies?'
/
comment on column ALL_TABLES.COMPRESSION is
'Whether table compression is enabled or not'
/
comment on column ALL_TABLES.DROPPED is
'Whether table is dropped and is in Recycle Bin'
/
create or replace public synonym ALL_TABLES for ALL_TABLES
/
grant select on ALL_TABLES to PUBLIC with grant option
/
create or replace view ALL_OBJECT_TABLES
    (OWNER, TABLE_NAME, TABLESPACE_NAME, CLUSTER_NAME, IOT_NAME, STATUS,
     PCT_FREE, PCT_USED,
     INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS, LOGGING,
     BACKED_UP, NUM_ROWS, BLOCKS, EMPTY_BLOCKS,
     AVG_SPACE, CHAIN_CNT, AVG_ROW_LEN,
     AVG_SPACE_FREELIST_BLOCKS, NUM_FREELIST_BLOCKS,
     DEGREE, INSTANCES, CACHE, TABLE_LOCK,
     SAMPLE_SIZE, LAST_ANALYZED, PARTITIONED,
     IOT_TYPE, OBJECT_ID_TYPE,
     TABLE_TYPE_OWNER, TABLE_TYPE, TEMPORARY, SECONDARY, NESTED,
     BUFFER_POOL, ROW_MOVEMENT,
     GLOBAL_STATS, USER_STATS, DURATION, SKIP_CORRUPT, MONITORING,
     CLUSTER_OWNER, DEPENDENCIES, COMPRESSION, DROPPED)
as
select u.name, o.name, decode(bitand(t.property, 2151678048), 0, ts.name, null),
       decode(bitand(t.property, 1024), 0, null, co.name),
       decode((bitand(t.property, 512)+bitand(t.flags, 536870912)),
              0, null, co.name),
       decode(bitand(t.trigflag, 1073741824), 1073741824, 'UNUSABLE', 'VALID'),
       decode(bitand(t.property, 32+64), 0, mod(t.pctfree$, 100), 64, 0, null),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
          decode(bitand(t.property, 32+64), 0, t.pctused$, 64, 0, null)),
       decode(bitand(t.property, 32), 0, t.initrans, null),
       decode(bitand(t.property, 32), 0, t.maxtrans, null),
       s.iniexts * ts.blocksize,
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
                                      s.extsize * ts.blocksize),
       s.minexts, s.maxexts,
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
                                      s.extpct),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
         decode(bitand(o.flags, 2), 2, 1, decode(s.lists, 0, 1, s.lists))),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
         decode(bitand(o.flags, 2), 2, 1, decode(s.groups, 0, 1, s.groups))),
       decode(bitand(t.property, 32), 32, null,
                decode(bitand(t.flags, 32), 0, 'YES', 'NO')),
       decode(bitand(t.flags,1), 0, 'Y', 1, 'N', '?'),
       t.rowcnt,
       decode(bitand(t.property, 64), 0, t.blkcnt, null),
       decode(bitand(t.property, 64), 0, t.empcnt, null),
       t.avgspc, t.chncnt, t.avgrln, t.avgspc_flb,
       decode(bitand(t.property, 64), 0, t.flbcnt, null),
       lpad(decode(t.degree, 32767, 'DEFAULT', nvl(t.degree,1)),10),
       lpad(decode(t.instances, 32767, 'DEFAULT', nvl(t.instances,1)),10),
       lpad(decode(bitand(t.flags, 8), 8, 'Y', 'N'),5),
       decode(bitand(t.flags, 6), 0, 'ENABLED', 'DISABLED'),
       t.samplesize, t.analyzetime,
       decode(bitand(t.property, 32), 32, 'YES', 'NO'),
       decode(bitand(t.property, 64), 64, 'IOT',
               decode(bitand(t.property, 512), 512, 'IOT_OVERFLOW',
               decode(bitand(t.flags, 536870912), 536870912, 'IOT_MAPPING', null))),
       decode(bitand(t.property, 4096), 4096, 'USER-DEFINED',
                                              'SYSTEM GENERATED'),
       nvl2(ac.synobj#, su.name, tu.name),
       nvl2(ac.synobj#, so.name, ty.name),
       decode(bitand(o.flags, 2), 0, 'N', 2, 'Y', 'N'),
       decode(bitand(o.flags, 16), 0, 'N', 16, 'Y', 'N'),
       decode(bitand(t.property, 8192), 8192, 'YES', 'NO'),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
             decode(s.cachehint, 0, 'DEFAULT', 1, 'KEEP', 2, 'RECYCLE', NULL)),
       decode(bitand(t.flags, 131072), 131072, 'ENABLED', 'DISABLED'),
       decode(bitand(t.flags, 512), 0, 'NO', 'YES'),
       decode(bitand(t.flags, 256), 0, 'NO', 'YES'),
       decode(bitand(o.flags, 2), 0, NULL,
          decode(bitand(t.property, 8388608), 8388608,
                 'SYS$SESSION', 'SYS$TRANSACTION')),
       decode(bitand(t.flags, 1024), 1024, 'ENABLED', 'DISABLED'),
       decode(bitand(o.flags, 2), 2, 'NO',
           decode(bitand(t.property, 2147483648), 2147483648, 'NO',
              decode(ksppcv.ksppstvl, 'TRUE', 'YES', 'NO'))),
       decode(bitand(t.property, 1024), 0, null, cu.name),
       decode(bitand(t.flags, 8388608), 8388608, 'ENABLED', 'DISABLED'),
       decode(bitand(t.property, 32), 32, null,
                decode(bitand(s.spare1, 2048), 2048, 'ENABLED', 'DISABLED')),
       decode(bitand(o.flags, 128), 128, 'YES', 'NO')
from sys.user$ u, sys.ts$ ts, sys.seg$ s, sys.obj$ co, sys.tab$ t, sys.obj$ o,
     sys.coltype$ ac, sys.obj$ ty, sys.user$ tu, sys.col$ tc,
     sys.obj$ cx, sys.user$ cu, sys.obj$ so, sys.user$ su,
     x$ksppcv ksppcv, x$ksppi ksppi
where o.owner# = u.user#
  and o.obj# = t.obj#
  and bitand(t.property, 1) = 1
  and bitand(o.flags, 128) = 0
  and t.obj# = tc.obj#
  and tc.name = 'SYS_NC_ROWINFO$'
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and ac.toid = ty.oid$
  and ty.type# <> 10
  and ty.owner# = tu.user#
  and t.bobj# = co.obj# (+)
  and t.ts# = ts.ts#
  and t.file# = s.file# (+)
  and t.block# = s.block# (+)
  and t.ts# = s.ts# (+)
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
  and t.dataobj# = cx.obj# (+)
  and cx.owner# = cu.user# (+)
  and ac.synobj# = so.obj# (+)
  and so.owner# = su.user# (+)
  and ksppi.indx = ksppcv.indx
  and ksppi.ksppinm = '_dml_monitoring_enabled'
/
comment on table ALL_OBJECT_TABLES is
'Description of all object tables accessible to the user'
/
comment on column ALL_OBJECT_TABLES.OWNER is
'Owner of the table'
/
comment on column ALL_OBJECT_TABLES.TABLE_NAME is
'Name of the table'
/
comment on column ALL_OBJECT_TABLES.TABLESPACE_NAME is
'Name of the tablespace containing the table'
/
comment on column ALL_OBJECT_TABLES.CLUSTER_NAME is
'Name of the cluster, if any, to which the table belongs'
/
comment on column ALL_OBJECT_TABLES.IOT_NAME is
'Name of the index-only table, if any, to which the overflow or mapping table entry belongs'
/
comment on column ALL_OBJECT_TABLES.STATUS is
'Status of the table will be UNUSABLE if a previous DROP TABLE operation failed,
VALID otherwise'
/
comment on column ALL_OBJECT_TABLES.PCT_FREE is
'Minimum percentage of free space in a block'
/
comment on column ALL_OBJECT_TABLES.PCT_USED is
'Minimum percentage of used space in a block'
/
comment on column ALL_OBJECT_TABLES.INI_TRANS is
'Initial number of transactions'
/
comment on column ALL_OBJECT_TABLES.MAX_TRANS is
'Maximum number of transactions'
/
comment on column ALL_OBJECT_TABLES.INITIAL_EXTENT is
'Size of the initial extent in bytes'
/
comment on column ALL_OBJECT_TABLES.NEXT_EXTENT is
'Size of secondary extents in bytes'
/
comment on column ALL_OBJECT_TABLES.MIN_EXTENTS is
'Minimum number of extents allowed in the segment'
/
comment on column ALL_OBJECT_TABLES.MAX_EXTENTS is
'Maximum number of extents allowed in the segment'
/
comment on column ALL_OBJECT_TABLES.PCT_INCREASE is
'Percentage increase in extent size'
/
comment on column ALL_OBJECT_TABLES.FREELISTS is
'Number of process freelists allocated in this segment'
/
comment on column ALL_OBJECT_TABLES.FREELIST_GROUPS is
'Number of freelist groups allocated in this segment'
/
comment on column ALL_OBJECT_TABLES.LOGGING is
'Logging attribute'
/
comment on column ALL_OBJECT_TABLES.BACKED_UP is
'Has table been backed up since last modification?'
/
comment on column ALL_OBJECT_TABLES.NUM_ROWS is
'The number of rows in the table'
/
comment on column ALL_OBJECT_TABLES.BLOCKS is
'The number of used blocks in the table'
/
comment on column ALL_OBJECT_TABLES.EMPTY_BLOCKS is
'The number of empty (never used) blocks in the table'
/
comment on column ALL_OBJECT_TABLES.AVG_SPACE is
'The average available free space in the table'
/
comment on column ALL_OBJECT_TABLES.CHAIN_CNT is
'The number of chained rows in the table'
/
comment on column ALL_OBJECT_TABLES.AVG_ROW_LEN is
'The average row length, including row overhead'
/
comment on column ALL_OBJECT_TABLES.AVG_SPACE_FREELIST_BLOCKS is
'The average freespace of all blocks on a freelist'
/
comment on column ALL_OBJECT_TABLES.NUM_FREELIST_BLOCKS is
'The number of blocks on the freelist'
/
comment on column ALL_OBJECT_TABLES.DEGREE is
'The number of threads per instance for scanning the table'
/
comment on column ALL_OBJECT_TABLES.INSTANCES is
'The number of instances across which the table is to be scanned'
/
comment on column ALL_OBJECT_TABLES.CACHE is
'Whether the table is to be cached in the buffer cache'
/
comment on column ALL_OBJECT_TABLES.TABLE_LOCK is
'Whether table locking is enabled or disabled'
/
comment on column ALL_OBJECT_TABLES.SAMPLE_SIZE is
'The sample size used in analyzing this table'
/
comment on column ALL_OBJECT_TABLES.LAST_ANALYZED is
'The date of the most recent time this table was analyzed'
/
comment on column ALL_OBJECT_TABLES.PARTITIONED is
'Is this table partitioned? YES or NO'
/
comment on column ALL_OBJECT_TABLES.IOT_TYPE is
'If index-only table, then IOT_TYPE is IOT or IOT_OVERFLOW or IOT_MAPPING else NULL'
/
comment on column ALL_OBJECT_TABLES.OBJECT_ID_TYPE is
'If user-defined OID, then USER-DEFINED, else if system generated OID, then SYSTEM GENERATED'
/
comment on column ALL_OBJECT_TABLES.TABLE_TYPE_OWNER is
'Owner of the type of the table if the table is an object table'
/
comment on column ALL_OBJECT_TABLES.TABLE_TYPE is
'Type of the table if the table is an object table'
/
comment on column ALL_OBJECT_TABLES.TEMPORARY is
'Can the current session only see data that it place in this object itself?'
/
comment on column ALL_OBJECT_TABLES.SECONDARY is
'Is this table object created as part of icreate for domain indexes?'
/
comment on column ALL_OBJECT_TABLES.NESTED is
'Is the table a nested table?'
/
comment on column ALL_OBJECT_TABLES.BUFFER_POOL is
'The default buffer pool to be used for table blocks'
/
comment on column ALL_OBJECT_TABLES.ROW_MOVEMENT is
'Whether partitioned row movement is enabled or disabled'
/
comment on column ALL_OBJECT_TABLES.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column ALL_OBJECT_TABLES.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column ALL_OBJECT_TABLES.DURATION is
'If temporary table, then duration is sys$session or sys$transaction else NULL'
/
comment on column ALL_OBJECT_TABLES.SKIP_CORRUPT is
'Whether skip corrupt blocks is enabled or disabled'
/
comment on column ALL_OBJECT_TABLES.MONITORING is
'Should we keep track of the amount of modification?'
/
comment on column ALL_OBJECT_TABLES.CLUSTER_OWNER is
'Owner of the cluster, if any, to which the table belongs'
/
comment on column ALL_OBJECT_TABLES.DEPENDENCIES is
'Should we keep track of row level dependencies?'
/
comment on column ALL_OBJECT_TABLES.COMPRESSION is
'Whether table compression is enabled or not'
/
comment on column ALL_OBJECT_TABLES.DROPPED is
'Whether table is dropped and is in Recycle Bin'
/
create or replace public synonym ALL_OBJECT_TABLES for ALL_OBJECT_TABLES
/
grant select on ALL_OBJECT_TABLES to PUBLIC with grant option
/
create or replace view ALL_ALL_TABLES
    (OWNER, TABLE_NAME, TABLESPACE_NAME, CLUSTER_NAME, IOT_NAME, STATUS,
     PCT_FREE, PCT_USED,
     INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS, LOGGING,
     BACKED_UP, NUM_ROWS, BLOCKS, EMPTY_BLOCKS,
     AVG_SPACE, CHAIN_CNT, AVG_ROW_LEN,
     AVG_SPACE_FREELIST_BLOCKS, NUM_FREELIST_BLOCKS,
     DEGREE, INSTANCES, CACHE, TABLE_LOCK,
     SAMPLE_SIZE, LAST_ANALYZED, PARTITIONED,
     IOT_TYPE, OBJECT_ID_TYPE,
     TABLE_TYPE_OWNER, TABLE_TYPE, TEMPORARY, SECONDARY, NESTED,
     BUFFER_POOL, ROW_MOVEMENT,
     GLOBAL_STATS, USER_STATS, DURATION, SKIP_CORRUPT, MONITORING,
     CLUSTER_OWNER, DEPENDENCIES, COMPRESSION, DROPPED)
as
select OWNER, TABLE_NAME, TABLESPACE_NAME, CLUSTER_NAME, IOT_NAME, STATUS, 
     PCT_FREE, PCT_USED,
     INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS, LOGGING,
     BACKED_UP, NUM_ROWS, BLOCKS, EMPTY_BLOCKS,
     AVG_SPACE, CHAIN_CNT, AVG_ROW_LEN,
     AVG_SPACE_FREELIST_BLOCKS, NUM_FREELIST_BLOCKS,
     DEGREE, INSTANCES, CACHE, TABLE_LOCK,
     SAMPLE_SIZE, LAST_ANALYZED, PARTITIONED,
     IOT_TYPE, NULL, NULL, NULL, TEMPORARY, SECONDARY, NESTED,
     BUFFER_POOL, ROW_MOVEMENT,
     GLOBAL_STATS, USER_STATS, DURATION, SKIP_CORRUPT, MONITORING,
     CLUSTER_OWNER, DEPENDENCIES, COMPRESSION, DROPPED
from all_tables
union all
select OWNER, TABLE_NAME, TABLESPACE_NAME, CLUSTER_NAME, IOT_NAME, STATUS,
     PCT_FREE, PCT_USED,
     INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS, LOGGING,
     BACKED_UP, NUM_ROWS, BLOCKS, EMPTY_BLOCKS,
     AVG_SPACE, CHAIN_CNT, AVG_ROW_LEN,
     AVG_SPACE_FREELIST_BLOCKS, NUM_FREELIST_BLOCKS,
     DEGREE, INSTANCES, CACHE, TABLE_LOCK,
     SAMPLE_SIZE, LAST_ANALYZED, PARTITIONED,
     IOT_TYPE, OBJECT_ID_TYPE,
     TABLE_TYPE_OWNER, TABLE_TYPE, TEMPORARY, SECONDARY, NESTED,
     BUFFER_POOL, ROW_MOVEMENT,
     GLOBAL_STATS, USER_STATS, DURATION, SKIP_CORRUPT, MONITORING,
     CLUSTER_OWNER, DEPENDENCIES, COMPRESSION, DROPPED
from all_object_tables
/
comment on table ALL_ALL_TABLES is
'Description of all object and relational tables accessible to the user'
/
comment on column ALL_ALL_TABLES.OWNER is
'Owner of the table'
/
comment on column ALL_ALL_TABLES.TABLE_NAME is
'Name of the table'
/
comment on column ALL_ALL_TABLES.TABLESPACE_NAME is
'Name of the tablespace containing the table'
/
comment on column ALL_ALL_TABLES.CLUSTER_NAME is
'Name of the cluster, if any, to which the table belongs'
/
comment on column ALL_ALL_TABLES.IOT_NAME is
'Name of the index-only table, if any, to which the overflow or mapping table entry belongs'
/
comment on column ALL_ALL_TABLES.STATUS is
'Status of the table will be UNUSABLE if a previous DROP TABLE operation failed,
VALID otherwise'
/
comment on column ALL_ALL_TABLES.PCT_FREE is
'Minimum percentage of free space in a block'
/
comment on column ALL_ALL_TABLES.PCT_USED is
'Minimum percentage of used space in a block'
/
comment on column ALL_ALL_TABLES.INI_TRANS is
'Initial number of transactions'
/
comment on column ALL_ALL_TABLES.MAX_TRANS is
'Maximum number of transactions'
/
comment on column ALL_ALL_TABLES.INITIAL_EXTENT is
'Size of the initial extent in bytes'
/
comment on column ALL_ALL_TABLES.NEXT_EXTENT is
'Size of secondary extents in bytes'
/
comment on column ALL_ALL_TABLES.MIN_EXTENTS is
'Minimum number of extents allowed in the segment'
/
comment on column ALL_ALL_TABLES.MAX_EXTENTS is
'Maximum number of extents allowed in the segment'
/
comment on column ALL_ALL_TABLES.PCT_INCREASE is
'Percentage increase in extent size'
/
comment on column ALL_ALL_TABLES.FREELISTS is
'Number of process freelists allocated in this segment'
/
comment on column ALL_ALL_TABLES.FREELIST_GROUPS is
'Number of freelist groups allocated in this segment'
/
comment on column ALL_ALL_TABLES.LOGGING is
'Logging attribute'
/
comment on column ALL_ALL_TABLES.BACKED_UP is
'Has table been backed up since last modification?'
/
comment on column ALL_ALL_TABLES.NUM_ROWS is
'The number of rows in the table'
/
comment on column ALL_ALL_TABLES.BLOCKS is
'The number of used blocks in the table'
/
comment on column ALL_ALL_TABLES.EMPTY_BLOCKS is
'The number of empty (never used) blocks in the table'
/
comment on column ALL_ALL_TABLES.AVG_SPACE is
'The average available free space in the table'
/
comment on column ALL_ALL_TABLES.CHAIN_CNT is
'The number of chained rows in the table'
/
comment on column ALL_ALL_TABLES.AVG_ROW_LEN is
'The average row length, including row overhead'
/
comment on column ALL_ALL_TABLES.AVG_SPACE_FREELIST_BLOCKS is
'The average freespace of all blocks on a freelist'
/
comment on column ALL_ALL_TABLES.NUM_FREELIST_BLOCKS is
'The number of blocks on the freelist'
/
comment on column ALL_ALL_TABLES.DEGREE is
'The number of threads per instance for scanning the table'
/
comment on column ALL_ALL_TABLES.INSTANCES is
'The number of instances across which the table is to be scanned'
/
comment on column ALL_ALL_TABLES.CACHE is
'Whether the table is to be cached in the buffer cache'
/
comment on column ALL_ALL_TABLES.TABLE_LOCK is
'Whether table locking is enabled or disabled'
/
comment on column ALL_ALL_TABLES.SAMPLE_SIZE is
'The sample size used in analyzing this table'
/
comment on column ALL_ALL_TABLES.LAST_ANALYZED is
'The date of the most recent time this table was analyzed'
/
comment on column ALL_ALL_TABLES.PARTITIONED is
'Is this table partitioned? YES or NO'
/
comment on column ALL_ALL_TABLES.IOT_TYPE is
'If index-only table, then IOT_TYPE is IOT or IOT_OVERFLOW or IOT_MAPPING else NULL'
/
comment on column ALL_ALL_TABLES.OBJECT_ID_TYPE is
'If user-defined OID, then USER-DEFINED, else if system generated OID, then SYST
EM GENERATED'
/
comment on column ALL_ALL_TABLES.TABLE_TYPE_OWNER is
'Owner of the type of the table if the table is an object table'
/
comment on column ALL_ALL_TABLES.TABLE_TYPE is
'Type of the table if the table is an object table'
/
comment on column ALL_ALL_TABLES.TEMPORARY is
'Can the current session only see data that it place in this object itself?'
/
comment on column ALL_ALL_TABLES.SECONDARY is
'Is this table object created as part of icreate for domain indexes?'
/
comment on column ALL_ALL_TABLES.NESTED is
'Is the table a nested table?'
/
comment on column ALL_ALL_TABLES.BUFFER_POOL is
'The default buffer pool to be used for table blocks'
/
comment on column ALL_ALL_TABLES.ROW_MOVEMENT is
'Whether partitioned row movement is enabled or disabled'
/
comment on column ALL_ALL_TABLES.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column ALL_ALL_TABLES.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column ALL_ALL_TABLES.DURATION is
'If temporary table, then duration is sys$session or sys$transaction else NULL'
/
comment on column ALL_ALL_TABLES.SKIP_CORRUPT is
'Whether skip corrupt blocks is enabled or disabled'
/
comment on column ALL_ALL_TABLES.MONITORING is
'Should we keep track of the amount of modification?'
/
comment on column ALL_ALL_TABLES.CLUSTER_OWNER is
'Owner of the cluster, if any, to which the table belongs'
/
comment on column ALL_ALL_TABLES.DEPENDENCIES is
'Should we keep track of row level dependencies?'
/
comment on column ALL_ALL_TABLES.COMPRESSION is
'Whether table compression is enabled or not'
/
comment on column ALL_ALL_TABLES.DROPPED is
'Whether table is dropped and is in Recycle Bin'
/
create or replace public synonym ALL_ALL_TABLES for ALL_ALL_TABLES
/
grant select on ALL_ALL_TABLES to PUBLIC with grant option
/
create or replace view DBA_TABLES
    (OWNER, TABLE_NAME, TABLESPACE_NAME, CLUSTER_NAME, IOT_NAME, STATUS,
     PCT_FREE, PCT_USED,
     INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS, LOGGING,
     BACKED_UP, NUM_ROWS, BLOCKS, EMPTY_BLOCKS,
     AVG_SPACE, CHAIN_CNT, AVG_ROW_LEN,
     AVG_SPACE_FREELIST_BLOCKS, NUM_FREELIST_BLOCKS,
     DEGREE, INSTANCES, CACHE, TABLE_LOCK,
     SAMPLE_SIZE, LAST_ANALYZED, PARTITIONED,
     IOT_TYPE, TEMPORARY, SECONDARY, NESTED,
     BUFFER_POOL, ROW_MOVEMENT,
     GLOBAL_STATS, USER_STATS, DURATION, SKIP_CORRUPT, MONITORING,
     CLUSTER_OWNER, DEPENDENCIES, COMPRESSION, DROPPED)
as
select u.name, o.name, decode(bitand(t.property,2151678048), 0, ts.name, null),
       decode(bitand(t.property, 1024), 0, null, co.name),
       decode((bitand(t.property, 512)+bitand(t.flags, 536870912)),
              0, null, co.name),
       decode(bitand(t.trigflag, 1073741824), 1073741824, 'UNUSABLE', 'VALID'),
       decode(bitand(t.property, 32+64), 0, mod(t.pctfree$, 100), 64, 0, null),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
          decode(bitand(t.property, 32+64), 0, t.pctused$, 64, 0, null)),
       decode(bitand(t.property, 32), 0, t.initrans, null),
       decode(bitand(t.property, 32), 0, t.maxtrans, null),
       s.iniexts * ts.blocksize,
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
                                      s.extsize * ts.blocksize),
       s.minexts, s.maxexts,
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
                                      s.extpct),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
         decode(bitand(o.flags, 2), 2, 1, decode(s.lists, 0, 1, s.lists))),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
         decode(bitand(o.flags, 2), 2, 1, decode(s.groups, 0, 1, s.groups))),
       decode(bitand(t.property, 32+64), 0,
                decode(bitand(t.flags, 32), 0, 'YES', 'NO'), null),
       decode(bitand(t.flags,1), 0, 'Y', 1, 'N', '?'),
       t.rowcnt,
       decode(bitand(t.property, 64), 0, t.blkcnt, null),
       decode(bitand(t.property, 64), 0, t.empcnt, null),
       t.avgspc, t.chncnt, t.avgrln, t.avgspc_flb,
       decode(bitand(t.property, 64), 0, t.flbcnt, null),
       lpad(decode(t.degree, 32767, 'DEFAULT', nvl(t.degree,1)),10),
       lpad(decode(t.instances, 32767, 'DEFAULT', nvl(t.instances,1)),10),
       lpad(decode(bitand(t.flags, 8), 8, 'Y', 'N'),5),
       decode(bitand(t.flags, 6), 0, 'ENABLED', 'DISABLED'),
       t.samplesize, t.analyzetime,
       decode(bitand(t.property, 32), 32, 'YES', 'NO'),
       decode(bitand(t.property, 64), 64, 'IOT',
               decode(bitand(t.property, 512), 512, 'IOT_OVERFLOW',
               decode(bitand(t.flags, 536870912), 536870912, 'IOT_MAPPING', null))),
       decode(bitand(o.flags, 2), 0, 'N', 2, 'Y', 'N'),
       decode(bitand(o.flags, 16), 0, 'N', 16, 'Y', 'N'),
       decode(bitand(t.property, 8192), 8192, 'YES',
              decode(bitand(t.property, 1), 0, 'NO', 'YES')),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
             decode(s.cachehint, 0, 'DEFAULT', 1, 'KEEP', 2, 'RECYCLE', NULL)),
       decode(bitand(t.flags, 131072), 131072, 'ENABLED', 'DISABLED'),
       decode(bitand(t.flags, 512), 0, 'NO', 'YES'),
       decode(bitand(t.flags, 256), 0, 'NO', 'YES'),
       decode(bitand(o.flags, 2), 0, NULL,
          decode(bitand(t.property, 8388608), 8388608,
                 'SYS$SESSION', 'SYS$TRANSACTION')),
       decode(bitand(t.flags, 1024), 1024, 'ENABLED', 'DISABLED'),
       decode(bitand(o.flags, 2), 2, 'NO',
           decode(bitand(t.property, 2147483648), 2147483648, 'NO',
              decode(ksppcv.ksppstvl, 'TRUE', 'YES', 'NO'))),
       decode(bitand(t.property, 1024), 0, null, cu.name),
       decode(bitand(t.flags, 8388608), 8388608, 'ENABLED', 'DISABLED'),
       decode(bitand(t.property, 32), 32, null,
                decode(bitand(s.spare1, 2048), 2048, 'ENABLED', 'DISABLED')),
       decode(bitand(o.flags, 128), 128, 'YES', 'NO')
from sys.user$ u, sys.ts$ ts, sys.seg$ s, sys.obj$ co, sys.tab$ t, sys.obj$ o,
     sys.obj$ cx, sys.user$ cu, x$ksppcv ksppcv, x$ksppi ksppi
where o.owner# = u.user#
  and o.obj# = t.obj#
  and bitand(t.property, 1) = 0
  and bitand(o.flags, 128) = 0
  and t.bobj# = co.obj# (+)
  and t.ts# = ts.ts#
  and t.file# = s.file# (+)
  and t.block# = s.block# (+)
  and t.ts# = s.ts# (+)
  and t.dataobj# = cx.obj# (+)
  and cx.owner# = cu.user# (+)
  and ksppi.indx = ksppcv.indx
  and ksppi.ksppinm = '_dml_monitoring_enabled'
/
create or replace public synonym DBA_TABLES for DBA_TABLES
/
grant select on DBA_TABLES to select_catalog_role
/
comment on table DBA_TABLES is
'Description of all relational tables in the database'
/
comment on column DBA_TABLES.OWNER is
'Owner of the table'
/
comment on column DBA_TABLES.TABLE_NAME is
'Name of the table'
/
comment on column DBA_TABLES.TABLESPACE_NAME is
'Name of the tablespace containing the table'
/
comment on column DBA_TABLES.CLUSTER_NAME is
'Name of the cluster, if any, to which the table belongs'
/
comment on column DBA_TABLES.IOT_NAME is
'Name of the index-only table, if any, to which the overflow or mapping table entry belongs'
/
comment on column DBA_TABLES.STATUS is
'Status of the table will be UNUSABLE if a previous DROP TABLE operation failed,
VALID otherwise'
/
comment on column DBA_TABLES.PCT_FREE is
'Minimum percentage of free space in a block'
/
comment on column DBA_TABLES.PCT_USED is
'Minimum percentage of used space in a block'
/
comment on column DBA_TABLES.INI_TRANS is
'Initial number of transactions'
/
comment on column DBA_TABLES.MAX_TRANS is
'Maximum number of transactions'
/
comment on column DBA_TABLES.INITIAL_EXTENT is
'Size of the initial extent in bytes'
/
comment on column DBA_TABLES.NEXT_EXTENT is
'Size of secondary extents in bytes'
/
comment on column DBA_TABLES.MIN_EXTENTS is
'Minimum number of extents allowed in the segment'
/
comment on column DBA_TABLES.MAX_EXTENTS is
'Maximum number of extents allowed in the segment'
/
comment on column DBA_TABLES.PCT_INCREASE is
'Percentage increase in extent size'
/
comment on column DBA_TABLES.FREELISTS is
'Number of process freelists allocated in this segment'
/
comment on column DBA_TABLES.FREELIST_GROUPS is
'Number of freelist groups allocated in this segment'
/
comment on column DBA_TABLES.LOGGING is
'Logging attribute'
/
comment on column DBA_TABLES.BACKED_UP is
'Has table been backed up since last modification?'
/
comment on column DBA_TABLES.NUM_ROWS is
'The number of rows in the table'
/
comment on column DBA_TABLES.BLOCKS is
'The number of used blocks in the table'
/
comment on column DBA_TABLES.EMPTY_BLOCKS is
'The number of empty (never used) blocks in the table'
/
comment on column DBA_TABLES.AVG_SPACE is
'The average available free space in the table'
/
comment on column DBA_TABLES.CHAIN_CNT is
'The number of chained rows in the table'
/
comment on column DBA_TABLES.AVG_ROW_LEN is
'The average row length, including row overhead'
/
comment on column DBA_TABLES.AVG_SPACE_FREELIST_BLOCKS is
'The average freespace of all blocks on a freelist'
/
comment on column DBA_TABLES.NUM_FREELIST_BLOCKS is
'The number of blocks on the freelist'
/
comment on column DBA_TABLES.DEGREE is
'The number of threads per instance for scanning the table'
/
comment on column DBA_TABLES.INSTANCES is
'The number of instances across which the table is to be scanned'
/
comment on column DBA_TABLES.CACHE is
'Whether the table is to be cached in the buffer cache'
/
comment on column DBA_TABLES.TABLE_LOCK is
'Whether table locking is enabled or disabled'
/
comment on column DBA_TABLES.SAMPLE_SIZE is
'The sample size used in analyzing this table'
/
comment on column DBA_TABLES.LAST_ANALYZED is
'The date of the most recent time this table was analyzed'
/
comment on column DBA_TABLES.PARTITIONED is
'Is this table partitioned? YES or NO'
/
comment on column DBA_TABLES.IOT_TYPE is
'If index-only table, then IOT_TYPE is IOT or IOT_OVERFLOW or IOT_MAPPING else NULL'
/
comment on column DBA_TABLES.TEMPORARY is
'Can the current session only see data that it place in this object itself?'
/
comment on column DBA_TABLES.SECONDARY is
'Is this table object created as part of icreate for domain indexes?'
/
comment on column DBA_TABLES.NESTED is
'Is the table a nested table?'
/
comment on column DBA_TABLES.BUFFER_POOL is
'The default buffer pool to be used for table blocks'
/
comment on column DBA_TABLES.ROW_MOVEMENT is
'Whether partitioned row movement is enabled or disabled'
/
comment on column DBA_TABLES.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column DBA_TABLES.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column DBA_TABLES.DURATION is
'If temporary table, then duration is sys$session or sys$transaction else NULL'
/
comment on column DBA_TABLES.SKIP_CORRUPT is
'Whether skip corrupt blocks is enabled or disabled'
/
comment on column DBA_TABLES.MONITORING is
'Should we keep track of the amount of modification?'
/
comment on column DBA_TABLES.CLUSTER_OWNER is
'Owner of the cluster, if any, to which the table belongs'
/
comment on column DBA_TABLES.DEPENDENCIES is
'Should we keep track of row level dependencies?'
/
comment on column DBA_TABLES.COMPRESSION is
'Whether table compression is enabled or not'
/
comment on column DBA_TABLES.DROPPED is
'Whether table is dropped and is in Recycle Bin'
/
create or replace view DBA_OBJECT_TABLES
    (OWNER, TABLE_NAME, TABLESPACE_NAME, CLUSTER_NAME, IOT_NAME, STATUS,
     PCT_FREE, PCT_USED,
     INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS, LOGGING,
     BACKED_UP, NUM_ROWS, BLOCKS, EMPTY_BLOCKS,
     AVG_SPACE, CHAIN_CNT, AVG_ROW_LEN,
     AVG_SPACE_FREELIST_BLOCKS, NUM_FREELIST_BLOCKS,
     DEGREE, INSTANCES, CACHE, TABLE_LOCK,
     SAMPLE_SIZE, LAST_ANALYZED, PARTITIONED,
     IOT_TYPE, OBJECT_ID_TYPE,
     TABLE_TYPE_OWNER, TABLE_TYPE, TEMPORARY, SECONDARY, NESTED,
     BUFFER_POOL, ROW_MOVEMENT,
     GLOBAL_STATS, USER_STATS, DURATION, SKIP_CORRUPT, MONITORING,
     CLUSTER_OWNER, DEPENDENCIES, COMPRESSION, DROPPED)
as
select u.name, o.name, decode(bitand(t.property,2151678048), 0, ts.name, null),
       decode(bitand(t.property, 1024), 0, null, co.name),
       decode((bitand(t.property, 512)+bitand(t.flags, 536870912)),
              0, null, co.name),
       decode(bitand(t.trigflag, 1073741824), 1073741824, 'UNUSABLE', 'VALID'),
       decode(bitand(t.property, 32+64), 0, mod(t.pctfree$, 100), 64, 0, null),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
          decode(bitand(t.property, 32+64), 0, t.pctused$, 64, 0, null)),
       decode(bitand(t.property, 32), 0, t.initrans, null),
       decode(bitand(t.property, 32), 0, t.maxtrans, null),
       s.iniexts * ts.blocksize,
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
                                      s.extsize * ts.blocksize),
       s.minexts, s.maxexts,
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
                                      s.extpct),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
         decode(bitand(o.flags, 2), 2, 1, decode(s.lists, 0, 1, s.lists))),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
         decode(bitand(o.flags, 2), 2, 1, decode(s.groups, 0, 1, s.groups))),
       decode(bitand(t.property, 32), 32, null,
                decode(bitand(t.flags, 32), 0, 'YES', 'NO')),
       decode(bitand(t.flags,1), 0, 'Y', 1, 'N', '?'),
       t.rowcnt,
       decode(bitand(t.property, 64), 0, t.blkcnt, null),
       decode(bitand(t.property, 64), 0, t.empcnt, null),
       t.avgspc, t.chncnt, t.avgrln, t.avgspc_flb,
       decode(bitand(t.property, 64), 0, t.flbcnt, null),
       lpad(decode(t.degree, 32767, 'DEFAULT', nvl(t.degree,1)),10),
       lpad(decode(t.instances, 32767, 'DEFAULT', nvl(t.instances,1)),10),
       lpad(decode(bitand(t.flags, 8), 8, 'Y', 'N'),5),
       decode(bitand(t.flags, 6), 0, 'ENABLED', 'DISABLED'),
       t.samplesize, t.analyzetime,
       decode(bitand(t.property, 32), 32, 'YES', 'NO'),
       decode(bitand(t.property, 64), 64, 'IOT',
               decode(bitand(t.property, 512), 512, 'IOT_OVERFLOW',
               decode(bitand(t.flags, 536870912), 536870912, 'IOT_MAPPING', null))),
       decode(bitand(t.property, 4096), 4096, 'USER-DEFINED',
                                              'SYSTEM GENERATED'),
       nvl2(ac.synobj#, su.name, tu.name),
       nvl2(ac.synobj#, so.name, ty.name),
       decode(bitand(o.flags, 2), 0, 'N', 2, 'Y', 'N'),
       decode(bitand(o.flags, 16), 0, 'N', 16, 'Y', 'N'),
       decode(bitand(t.property, 8192), 8192, 'YES', 'NO'),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
             decode(s.cachehint, 0, 'DEFAULT', 1, 'KEEP', 2, 'RECYCLE', NULL)),
       decode(bitand(t.flags, 131072), 131072, 'ENABLED', 'DISABLED'),
       decode(bitand(t.flags, 512), 0, 'NO', 'YES'),
       decode(bitand(t.flags, 256), 0, 'NO', 'YES'),
       decode(bitand(o.flags, 2), 0, NULL,
          decode(bitand(t.property, 8388608), 8388608,
                 'SYS$SESSION', 'SYS$TRANSACTION')),
       decode(bitand(t.flags, 1024), 1024, 'ENABLED', 'DISABLED'),
       decode(bitand(o.flags, 2), 2, 'NO',
           decode(bitand(t.property, 2147483648), 2147483648, 'NO',
              decode(ksppcv.ksppstvl, 'TRUE', 'YES', 'NO'))),
       decode(bitand(t.property, 1024), 0, null, cu.name),
       decode(bitand(t.flags, 8388608), 8388608, 'ENABLED', 'DISABLED'),
       decode(bitand(t.property, 32), 32, null,
                decode(bitand(s.spare1, 2048), 2048, 'ENABLED', 'DISABLED')),
       decode(bitand(o.flags, 128), 128, 'YES', 'NO')
from sys.user$ u, sys.ts$ ts, sys.seg$ s, sys.obj$ co, sys.tab$ t, sys.obj$ o,
     sys.coltype$ ac, sys.obj$ ty, sys.user$ tu, sys.col$ tc,
     sys.obj$ cx, sys.user$ cu, sys.obj$ so, sys.user$ su,
     x$ksppcv ksppcv, x$ksppi ksppi
where o.owner# = u.user#
  and o.obj# = t.obj#
  and bitand(t.property, 1) = 1
  and bitand(o.flags, 128) = 0
  and t.obj# = tc.obj#
  and tc.name = 'SYS_NC_ROWINFO$'
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and ac.toid = ty.oid$
  and ty.owner# = tu.user#
  and ty.type# <> 10
  and t.bobj# = co.obj# (+)
  and t.ts# = ts.ts#
  and t.file# = s.file# (+)
  and t.block# = s.block# (+)
  and t.ts# = s.ts# (+)
  and t.dataobj# = cx.obj# (+)
  and cx.owner# = cu.user# (+)
  and ac.synobj# = so.obj# (+)
  and so.owner# = su.user# (+)
  and ksppi.indx = ksppcv.indx
  and ksppi.ksppinm = '_dml_monitoring_enabled'
/
create or replace public synonym DBA_OBJECT_TABLES for DBA_OBJECT_TABLES
/
grant select on DBA_OBJECT_TABLES to select_catalog_role
/
comment on table DBA_OBJECT_TABLES is
'Description of all object tables in the database'
/
comment on column DBA_OBJECT_TABLES.OWNER is
'Owner of the table'
/
comment on column DBA_OBJECT_TABLES.TABLE_NAME is
'Name of the table'
/
comment on column DBA_OBJECT_TABLES.TABLESPACE_NAME is
'Name of the tablespace containing the table'
/
comment on column DBA_OBJECT_TABLES.CLUSTER_NAME is
'Name of the cluster, if any, to which the table belongs'
/
comment on column DBA_OBJECT_TABLES.IOT_NAME is
'Name of the index-only table, if any, to which the overflow or mapping table entry belongs'
/
comment on column DBA_OBJECT_TABLES.STATUS is
'Status of the table will be UNUSABLE if a previous DROP TABLE operation failed,
VALID otherwise'
/
comment on column DBA_OBJECT_TABLES.PCT_FREE is
'Minimum percentage of free space in a block'
/
comment on column DBA_OBJECT_TABLES.PCT_USED is
'Minimum percentage of used space in a block'
/
comment on column DBA_OBJECT_TABLES.INI_TRANS is
'Initial number of transactions'
/
comment on column DBA_OBJECT_TABLES.MAX_TRANS is
'Maximum number of transactions'
/
comment on column DBA_OBJECT_TABLES.INITIAL_EXTENT is
'Size of the initial extent in bytes'
/
comment on column DBA_OBJECT_TABLES.NEXT_EXTENT is
'Size of secondary extents in bytes'
/
comment on column DBA_OBJECT_TABLES.MIN_EXTENTS is
'Minimum number of extents allowed in the segment'
/
comment on column DBA_OBJECT_TABLES.MAX_EXTENTS is
'Maximum number of extents allowed in the segment'
/
comment on column DBA_OBJECT_TABLES.PCT_INCREASE is
'Percentage increase in extent size'
/
comment on column DBA_OBJECT_TABLES.FREELISTS is
'Number of process freelists allocated in this segment'
/
comment on column DBA_OBJECT_TABLES.FREELIST_GROUPS is
'Number of freelist groups allocated in this segment'
/
comment on column DBA_OBJECT_TABLES.LOGGING is
'Logging attribute'
/
comment on column DBA_OBJECT_TABLES.BACKED_UP is
'Has table been backed up since last modification?'
/
comment on column DBA_OBJECT_TABLES.NUM_ROWS is
'The number of rows in the table'
/
comment on column DBA_OBJECT_TABLES.BLOCKS is
'The number of used blocks in the table'
/
comment on column DBA_OBJECT_TABLES.EMPTY_BLOCKS is
'The number of empty (never used) blocks in the table'
/
comment on column DBA_OBJECT_TABLES.AVG_SPACE is
'The average available free space in the table'
/
comment on column DBA_OBJECT_TABLES.CHAIN_CNT is
'The number of chained rows in the table'
/
comment on column DBA_OBJECT_TABLES.AVG_ROW_LEN is
'The average row length, including row overhead'
/
comment on column DBA_OBJECT_TABLES.AVG_SPACE_FREELIST_BLOCKS is
'The average freespace of all blocks on a freelist'
/
comment on column DBA_OBJECT_TABLES.NUM_FREELIST_BLOCKS is
'The number of blocks on the freelist'
/
comment on column DBA_OBJECT_TABLES.DEGREE is
'The number of threads per instance for scanning the table'
/
comment on column DBA_OBJECT_TABLES.INSTANCES is
'The number of instances across which the table is to be scanned'
/
comment on column DBA_OBJECT_TABLES.CACHE is
'Whether the table is to be cached in the buffer cache'
/
comment on column DBA_OBJECT_TABLES.TABLE_LOCK is
'Whether table locking is enabled or disabled'
/
comment on column DBA_OBJECT_TABLES.SAMPLE_SIZE is
'The sample size used in analyzing this table'
/
comment on column DBA_OBJECT_TABLES.LAST_ANALYZED is
'The date of the most recent time this table was analyzed'
/
comment on column DBA_OBJECT_TABLES.PARTITIONED is
'Is this table partitioned? YES or NO'
/
comment on column DBA_OBJECT_TABLES.IOT_TYPE is
'If index-only table, then IOT_TYPE is IOT or IOT_OVERFLOW or IOT_MAPPING else NULL'
/
comment on column DBA_OBJECT_TABLES.OBJECT_ID_TYPE is
'If user-defined OID, then USER-DEFINED, else if system generated OID, then SYSTEM GENERATED'
/
comment on column DBA_OBJECT_TABLES.TABLE_TYPE_OWNER is
'Owner of the type of the table if the table is an object table'
/
comment on column DBA_OBJECT_TABLES.TABLE_TYPE is
'Type of the table if the table is an object table'
/
comment on column DBA_OBJECT_TABLES.TEMPORARY is
'Can the current session only see data that it place in this object itself?'
/
comment on column DBA_OBJECT_TABLES.SECONDARY is
'Is this table object created as part of icreate for domain indexes?'
/
comment on column DBA_OBJECT_TABLES.NESTED is
'Is the table a nested table?'
/
comment on column DBA_OBJECT_TABLES.BUFFER_POOL is
'The default buffer pool to be used for table blocks'
/
comment on column DBA_OBJECT_TABLES.ROW_MOVEMENT is
'Whether partitioned row movement is enabled or disabled'
/
comment on column DBA_OBJECT_TABLES.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column DBA_OBJECT_TABLES.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column DBA_OBJECT_TABLES.DURATION is
'If temporary table, then duration is sys$session or sys$transaction else NULL'
/
comment on column DBA_OBJECT_TABLES.SKIP_CORRUPT is
'Whether skip corrupt blocks is enabled or disabled'
/
comment on column DBA_OBJECT_TABLES.MONITORING is
'Should we keep track of the amount of modification?'
/
comment on column DBA_OBJECT_TABLES.CLUSTER_OWNER is
'Owner of the cluster, if any, to which the table belongs'
/
comment on column DBA_OBJECT_TABLES.DEPENDENCIES is
'Should we keep track of row level dependencies?'
/
comment on column DBA_OBJECT_TABLES.COMPRESSION is
'Whether table compression is enabled or not'
/
comment on column DBA_OBJECT_TABLES.DROPPED is
'Whether table is dropped and is in Recycle Bin'
/
create or replace view DBA_ALL_TABLES
    (OWNER, TABLE_NAME, TABLESPACE_NAME, CLUSTER_NAME, IOT_NAME, STATUS, 
     PCT_FREE, PCT_USED,
     INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS, LOGGING,
     BACKED_UP, NUM_ROWS, BLOCKS, EMPTY_BLOCKS,
     AVG_SPACE, CHAIN_CNT, AVG_ROW_LEN,
     AVG_SPACE_FREELIST_BLOCKS, NUM_FREELIST_BLOCKS,
     DEGREE, INSTANCES, CACHE, TABLE_LOCK,
     SAMPLE_SIZE, LAST_ANALYZED, PARTITIONED,
     IOT_TYPE, OBJECT_ID_TYPE,
     TABLE_TYPE_OWNER, TABLE_TYPE, TEMPORARY, SECONDARY, NESTED,
     BUFFER_POOL, ROW_MOVEMENT,
     GLOBAL_STATS, USER_STATS, DURATION, SKIP_CORRUPT, MONITORING,
     CLUSTER_OWNER, DEPENDENCIES, COMPRESSION, DROPPED)
as
select OWNER, TABLE_NAME, TABLESPACE_NAME, CLUSTER_NAME, IOT_NAME, STATUS,
     PCT_FREE, PCT_USED,
     INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS, LOGGING,
     BACKED_UP, NUM_ROWS, BLOCKS, EMPTY_BLOCKS,
     AVG_SPACE, CHAIN_CNT, AVG_ROW_LEN,
     AVG_SPACE_FREELIST_BLOCKS, NUM_FREELIST_BLOCKS,
     DEGREE, INSTANCES, CACHE, TABLE_LOCK,
     SAMPLE_SIZE, LAST_ANALYZED, PARTITIONED,
     IOT_TYPE, NULL, NULL, NULL, TEMPORARY, SECONDARY, NESTED,
     BUFFER_POOL, ROW_MOVEMENT,
     GLOBAL_STATS, USER_STATS, DURATION, SKIP_CORRUPT, MONITORING,
     CLUSTER_OWNER, DEPENDENCIES, COMPRESSION, DROPPED
from dba_tables
union all
select * from dba_object_tables
/
create or replace public synonym DBA_ALL_TABLES for DBA_ALL_TABLES
/
grant select on DBA_ALL_TABLES to select_catalog_role
/
comment on table DBA_ALL_TABLES is
'Description of all object and relational tables in the database'
/
comment on column DBA_ALL_TABLES.OWNER is
'Owner of the table'
/
comment on column DBA_ALL_TABLES.TABLE_NAME is
'Name of the table'
/
comment on column DBA_ALL_TABLES.TABLESPACE_NAME is
'Name of the tablespace containing the table'
/
comment on column DBA_ALL_TABLES.CLUSTER_NAME is
'Name of the cluster, if any, to which the table belongs'
/
comment on column DBA_ALL_TABLES.IOT_NAME is
'Name of the index-only table, if any, to which the overflow or mapping table entry belongs'
/
comment on column DBA_ALL_TABLES.STATUS is
'Status of the table will be UNUSABLE if a previous DROP TABLE operation failed,
VALID otherwise'
/
comment on column DBA_ALL_TABLES.PCT_FREE is
'Minimum percentage of free space in a block'
/
comment on column DBA_ALL_TABLES.PCT_USED is
'Minimum percentage of used space in a block'
/
comment on column DBA_ALL_TABLES.INI_TRANS is
'Initial number of transactions'
/
comment on column DBA_ALL_TABLES.MAX_TRANS is
'Maximum number of transactions'
/
comment on column DBA_ALL_TABLES.INITIAL_EXTENT is
'Size of the initial extent in bytes'
/
comment on column DBA_ALL_TABLES.NEXT_EXTENT is
'Size of secondary extents in bytes'
/
comment on column DBA_ALL_TABLES.MIN_EXTENTS is
'Minimum number of extents allowed in the segment'
/
comment on column DBA_ALL_TABLES.MAX_EXTENTS is
'Maximum number of extents allowed in the segment'
/
comment on column DBA_ALL_TABLES.PCT_INCREASE is
'Percentage increase in extent size'
/
comment on column DBA_ALL_TABLES.FREELISTS is
'Number of process freelists allocated in this segment'
/
comment on column DBA_ALL_TABLES.FREELIST_GROUPS is
'Number of freelist groups allocated in this segment'
/
comment on column DBA_ALL_TABLES.LOGGING is
'Logging attribute'
/
comment on column DBA_ALL_TABLES.BACKED_UP is
'Has table been backed up since last modification?'
/
comment on column DBA_ALL_TABLES.NUM_ROWS is
'The number of rows in the table'
/
comment on column DBA_ALL_TABLES.BLOCKS is
'The number of used blocks in the table'
/
comment on column DBA_ALL_TABLES.EMPTY_BLOCKS is
'The number of empty (never used) blocks in the table'
/
comment on column DBA_ALL_TABLES.AVG_SPACE is
'The average available free space in the table'
/
comment on column DBA_ALL_TABLES.CHAIN_CNT is
'The number of chained rows in the table'
/
comment on column DBA_ALL_TABLES.AVG_ROW_LEN is
'The average row length, including row overhead'
/
comment on column DBA_ALL_TABLES.AVG_SPACE_FREELIST_BLOCKS is
'The average freespace of all blocks on a freelist'
/
comment on column DBA_ALL_TABLES.NUM_FREELIST_BLOCKS is
'The number of blocks on the freelist'
/
comment on column DBA_ALL_TABLES.DEGREE is
'The number of threads per instance for scanning the table'
/
comment on column DBA_ALL_TABLES.INSTANCES is
'The number of instances across which the table is to be scanned'
/
comment on column DBA_ALL_TABLES.CACHE is
'Whether the table is to be cached in the buffer cache'
/
comment on column DBA_ALL_TABLES.TABLE_LOCK is
'Whether table locking is enabled or disabled'
/
comment on column DBA_ALL_TABLES.SAMPLE_SIZE is
'The sample size used in analyzing this table'
/
comment on column DBA_ALL_TABLES.LAST_ANALYZED is
'The date of the most recent time this table was analyzed'
/
comment on column DBA_ALL_TABLES.PARTITIONED is
'Is this table partitioned? YES or NO'
/
comment on column DBA_ALL_TABLES.IOT_TYPE is
'If index-only table, then IOT_TYPE is IOT or IOT_OVERFLOW or IOT_MAPPING else NULL'
/
comment on column DBA_ALL_TABLES.OBJECT_ID_TYPE is
'If user-defined OID, then USER-DEFINED, else if system generated OID, then SYST
EM GENERATED'
/
comment on column DBA_ALL_TABLES.TABLE_TYPE_OWNER is
'Owner of the type of the table if the table is an object table'
/
comment on column DBA_ALL_TABLES.TABLE_TYPE is
'Type of the table if the table is an object table'
/
comment on column DBA_ALL_TABLES.TEMPORARY is
'Can the current session only see data that it place in this object itself?'
/
comment on column DBA_ALL_TABLES.SECONDARY is
'Is this table object created as part of icreate for domain indexes?'
/
comment on column DBA_ALL_TABLES.NESTED is
'Is the table a nested table?'
/
comment on column DBA_ALL_TABLES.BUFFER_POOL is
'The default buffer pool to be used for table blocks'
/
comment on column DBA_ALL_TABLES.ROW_MOVEMENT is
'Whether partitioned row movement is enabled or disabled'
/
comment on column DBA_ALL_TABLES.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column DBA_ALL_TABLES.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column DBA_ALL_TABLES.DURATION is
'If temporary table, then duration is sys$session or sys$transaction else NULL'
/
comment on column DBA_ALL_TABLES.SKIP_CORRUPT is
'Whether skip corrupt blocks is enabled or disabled'
/
comment on column DBA_ALL_TABLES.MONITORING is
'Should we keep track of the amount of modification?'
/
comment on column DBA_ALL_TABLES.CLUSTER_OWNER is
'Owner of the cluster, if any, to which the table belongs'
/
comment on column DBA_ALL_TABLES.DEPENDENCIES is
'Should we keep track of row level dependencies?'
/
comment on column DBA_ALL_TABLES.COMPRESSION is
'Whether table compression is enabled or not'
/
comment on column DBA_ALL_TABLES.DROPPED is
'Whether table is dropped and is in Recycle Bin'
/
remark
remark  FAMILY "TAB_COLS"
remark  The columns that make up objects:  Tables, Views, Clusters
remark  Includes information specified or implied by user in
remark  CREATE/ALTER TABLE/VIEW/CLUSTER.
remark
create or replace view USER_TAB_COLS
    (TABLE_NAME, COLUMN_NAME, DATA_TYPE, DATA_TYPE_MOD, DATA_TYPE_OWNER,
     DATA_LENGTH, DATA_PRECISION, DATA_SCALE, NULLABLE, COLUMN_ID,
     DEFAULT_LENGTH, DATA_DEFAULT, NUM_DISTINCT, LOW_VALUE, HIGH_VALUE,
     DENSITY, NUM_NULLS, NUM_BUCKETS, LAST_ANALYZED, SAMPLE_SIZE,
     CHARACTER_SET_NAME, CHAR_COL_DECL_LENGTH,
     GLOBAL_STATS, USER_STATS, AVG_COL_LEN, CHAR_LENGTH, CHAR_USED,
     V80_FMT_IMAGE, DATA_UPGRADED, HIDDEN_COLUMN, VIRTUAL_COLUMN,
     SEGMENT_COLUMN_ID, INTERNAL_COLUMN_ID, HISTOGRAM, QUALIFIED_COL_NAME)
as
select o.name,
       c.name,
       decode(c.type#, 1, decode(c.charsetform, 2, 'NVARCHAR2', 'VARCHAR2'),
                       2, decode(c.scale, null,
                                 decode(c.precision#, null, 'NUMBER', 'FLOAT'),
                                 'NUMBER'),
                       8, 'LONG',
                       9, decode(c.charsetform, 2, 'NCHAR VARYING', 'VARCHAR'),
                       12, 'DATE',
                       23, 'RAW', 24, 'LONG RAW',
                       58, nvl2(ac.synobj#, (select o.name from obj$ o
                                where o.obj#=ac.synobj#), ot.name),
                       69, 'ROWID',
                       96, decode(c.charsetform, 2, 'NCHAR', 'CHAR'),
                       100, 'BINARY_FLOAT',
                       101, 'BINARY_DOUBLE',
                       105, 'MLSLABEL',
                       106, 'MLSLABEL',
                       111, nvl2(ac.synobj#, (select o.name from obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       112, decode(c.charsetform, 2, 'NCLOB', 'CLOB'),
                       113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
                       121, nvl2(ac.synobj#, (select o.name from obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       122, nvl2(ac.synobj#, (select o.name from obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       123, nvl2(ac.synobj#, (select o.name from obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       178, 'TIME(' ||c.scale|| ')',
                       179, 'TIME(' ||c.scale|| ')' || ' WITH TIME ZONE',
                       180, 'TIMESTAMP(' ||c.scale|| ')',
                       181, 'TIMESTAMP(' ||c.scale|| ')' || ' WITH TIME ZONE',
                       231, 'TIMESTAMP(' ||c.scale|| ')' || ' WITH LOCAL TIME ZONE',
                       182, 'INTERVAL YEAR(' ||c.precision#||') TO MONTH',
                       183, 'INTERVAL DAY(' ||c.precision#||') TO SECOND(' ||
                             c.scale || ')',
                       208, 'UROWID',
                       'UNDEFINED'),
       decode(c.type#, 111, 'REF'),
       nvl2(ac.synobj#, (select u.name from user$ u, obj$ o
            where o.owner#=u.user# and o.obj#=ac.synobj#), ut.name),
       c.length, c.precision#, c.scale,
       decode(sign(c.null$),-1,'D', 0, 'Y', 'N'),
       decode(c.col#, 0, to_number(null), c.col#), c.deflength,
       c.default$, h.distcnt, h.lowval, h.hival, h.density, h.null_cnt,
       case when nvl(h.distcnt,0) = 0 then h.distcnt
            when h.row_cnt = 0 then 1
	    when (h.bucket_cnt > 255
                  or
                  (h.bucket_cnt > h.distcnt
                   and h.row_cnt = h.distcnt
                   and h.density*h.bucket_cnt*2 <= 1))
                then h.row_cnt
            else h.bucket_cnt
       end,
       h.timestamp#, h.sample_size,
       decode(c.charsetform, 1, 'CHAR_CS',
                             2, 'NCHAR_CS',
                             3, NLS_CHARSET_NAME(c.charsetid),
                             4, 'ARG:'||c.charsetid),
       decode(c.charsetid, 0, to_number(NULL),
                           nls_charset_decl_len(c.length, c.charsetid)),
       decode(bitand(h.spare2, 2), 2, 'YES', 'NO'),
       decode(bitand(h.spare2, 1), 1, 'YES', 'NO'),
       h.avgcln,
       c.spare3,
       decode(c.type#, 1, decode(bitand(c.property, 8388608), 0, 'B', 'C'),
                      96, decode(bitand(c.property, 8388608), 0, 'B', 'C'),
                      null),
       decode(bitand(ac.flags, 128), 128, 'YES', 'NO'),
       decode(o.status, 1, decode(bitand(ac.flags, 256), 256, 'NO', 'YES'),
                        decode(bitand(ac.flags, 2), 2, 'NO',
                               decode(bitand(ac.flags, 4), 4, 'NO',
                                      decode(bitand(ac.flags, 8), 8, 'NO',
                                             'N/A')))),
       decode(c.property, 0, 'NO', decode(bitand(c.property, 32), 32, 'YES',
                                          'NO')),
       decode(c.property, 0, 'NO', decode(bitand(c.property, 8), 8, 'YES',
                                          'NO')),
       decode(c.segcol#, 0, to_number(null), c.segcol#), c.intcol#,
       case when nvl(h.row_cnt,0) = 0 then 'NONE'
            when (h.bucket_cnt > 255
                  or
                  (h.bucket_cnt > h.distcnt and h.row_cnt = h.distcnt
                   and h.density*h.bucket_cnt*2 <= 1))
                then 'FREQUENCY'
            else 'HEIGHT BALANCED'
       end,
       decode(bitand(c.property, 1024), 1024,
              (select decode(bitand(cl.property, 1), 1, rc.name, cl.name)
               from sys.col$ cl, attrcol$ rc where cl.intcol# = c.intcol#-1
               and cl.obj# = c.obj# and c.obj# = rc.obj#(+) and
               cl.intcol# = rc.intcol#(+)),
              decode(bitand(c.property, 1), 0, c.name,
                     (select tc.name from sys.attrcol$ tc
                      where c.obj# = tc.obj# and c.intcol# = tc.intcol#)))
from sys.col$ c, sys.obj$ o, sys.hist_head$ h, sys.coltype$ ac, sys.obj$ ot,
     sys.user$ ut
where o.obj# = c.obj#
  and o.owner# = userenv('SCHEMAID')
  and c.obj# = h.obj#(+) and c.intcol# = h.intcol#(+)
  and c.obj# = ac.obj#(+) and c.intcol# = ac.intcol#(+)
  and ac.toid = ot.oid$(+)
  and ot.type#(+) = 13
  and ot.owner# = ut.user#(+)
  and (o.type# in (3, 4)                                    /* cluster, view */
       or
       (o.type# = 2    /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192))))
/
comment on table USER_TAB_COLS is
'Columns of user''s tables, views and clusters'
/
comment on column USER_TAB_COLS.TABLE_NAME is
'Table, view or cluster name'
/
comment on column USER_TAB_COLS.COLUMN_NAME is
'Column name'
/
comment on column USER_TAB_COLS.DATA_LENGTH is
'Length of the column in bytes'
/
comment on column USER_TAB_COLS.DATA_TYPE is
'Datatype of the column'
/
comment on column USER_TAB_COLS.DATA_TYPE_MOD is
'Datatype modifier of the column'
/
comment on column USER_TAB_COLS.DATA_TYPE_OWNER is
'Owner of the datatype of the column'
/
comment on column USER_TAB_COLS.DATA_PRECISION is
'Length: decimal digits (NUMBER) or binary digits (FLOAT)'
/
comment on column USER_TAB_COLS.DATA_SCALE is
'Digits to right of decimal point in a number'
/
comment on column USER_TAB_COLS.NULLABLE is
'Does column allow NULL values?'
/
comment on column USER_TAB_COLS.COLUMN_ID is
'Sequence number of the column as created'
/
comment on column USER_TAB_COLS.DEFAULT_LENGTH is
'Length of default value for the column'
/
comment on column USER_TAB_COLS.DATA_DEFAULT is
'Default value for the column'
/
comment on column USER_TAB_COLS.NUM_DISTINCT is
'The number of distinct values in the column'
/
comment on column USER_TAB_COLS.LOW_VALUE is
'The low value in the column'
/
comment on column USER_TAB_COLS.HIGH_VALUE is
'The high value in the column'
/
comment on column USER_TAB_COLS.DENSITY is
'The density of the column'
/
comment on column USER_TAB_COLS.NUM_NULLS is
'The number of nulls in the column'
/
comment on column USER_TAB_COLS.NUM_BUCKETS is
'The number of buckets in histogram for the column'
/
comment on column USER_TAB_COLS.LAST_ANALYZED is
'The date of the most recent time this column was analyzed'
/
comment on column USER_TAB_COLS.SAMPLE_SIZE is
'The sample size used in analyzing this column'
/
comment on column USER_TAB_COLS.CHARACTER_SET_NAME is
'Character set name'
/
comment on column USER_TAB_COLS.CHAR_COL_DECL_LENGTH is
'Declaration length of character type column'
/
comment on column USER_TAB_COLS.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column USER_TAB_COLS.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column USER_TAB_COLS.AVG_COL_LEN is
'The average length of the column in bytes'
/
comment on column USER_TAB_COLS.CHAR_LENGTH is
'The maximum length of the column in characters'
/
comment on column USER_TAB_COLS.CHAR_USED is
'C is maximum length given in characters, B if in bytes'
/
comment on column USER_TAB_COLS.V80_FMT_IMAGE is
'Is column data in 8.0 image format?'
/
comment on column USER_TAB_COLS.DATA_UPGRADED is
'Has column data been upgraded to the latest type version format?'
/
comment on column USER_TAB_COLS.HIDDEN_COLUMN is
'Is this a hidden column?'
/
comment on column USER_TAB_COLS.VIRTUAL_COLUMN is
'Is this a virtual column?'
/
comment on column USER_TAB_COLS.SEGMENT_COLUMN_ID is
'Sequence number of the column in the segment'
/
comment on column USER_TAB_COLS.INTERNAL_COLUMN_ID is
'Internal sequence number of the column'
/
comment on column USER_TAB_COLS.QUALIFIED_COL_NAME is
'Qualified column name'
/
create or replace public synonym USER_TAB_COLS for USER_TAB_COLS
/
grant select on USER_TAB_COLS to PUBLIC with grant option
/
create or replace view ALL_TAB_COLS
    (OWNER, TABLE_NAME,
     COLUMN_NAME, DATA_TYPE, DATA_TYPE_MOD, DATA_TYPE_OWNER,
     DATA_LENGTH, DATA_PRECISION, DATA_SCALE, NULLABLE, COLUMN_ID,
     DEFAULT_LENGTH, DATA_DEFAULT, NUM_DISTINCT, LOW_VALUE, HIGH_VALUE,
     DENSITY, NUM_NULLS, NUM_BUCKETS, LAST_ANALYZED, SAMPLE_SIZE,
     CHARACTER_SET_NAME, CHAR_COL_DECL_LENGTH,
     GLOBAL_STATS, USER_STATS, AVG_COL_LEN, CHAR_LENGTH, CHAR_USED,
     V80_FMT_IMAGE, DATA_UPGRADED, HIDDEN_COLUMN, VIRTUAL_COLUMN,
     SEGMENT_COLUMN_ID, INTERNAL_COLUMN_ID, HISTOGRAM, QUALIFIED_COL_NAME)
as
select u.name, o.name,
       c.name,
       decode(c.type#, 1, decode(c.charsetform, 2, 'NVARCHAR2', 'VARCHAR2'),
                       2, decode(c.scale, null,
                                 decode(c.precision#, null, 'NUMBER', 'FLOAT'),
                                 'NUMBER'),
                       8, 'LONG',
                       9, decode(c.charsetform, 2, 'NCHAR VARYING', 'VARCHAR'),
                       12, 'DATE',
                       23, 'RAW', 24, 'LONG RAW',
                       58, nvl2(ac.synobj#, (select o.name from obj$ o
                                where o.obj#=ac.synobj#), ot.name),
                       69, 'ROWID',
                       96, decode(c.charsetform, 2, 'NCHAR', 'CHAR'),
                       100, 'BINARY_FLOAT',
                       101, 'BINARY_DOUBLE',
                       105, 'MLSLABEL',
                       106, 'MLSLABEL',
                       111, nvl2(ac.synobj#, (select o.name from obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       112, decode(c.charsetform, 2, 'NCLOB', 'CLOB'),
                       113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
                       121, nvl2(ac.synobj#, (select o.name from obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       122, nvl2(ac.synobj#, (select o.name from obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       123, nvl2(ac.synobj#, (select o.name from obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       178, 'TIME(' ||c.scale|| ')',
                       179, 'TIME(' ||c.scale|| ')' || ' WITH TIME ZONE',
                       180, 'TIMESTAMP(' ||c.scale|| ')',
                       181, 'TIMESTAMP(' ||c.scale|| ')' || ' WITH TIME ZONE',
                       231, 'TIMESTAMP(' ||c.scale|| ')' || ' WITH LOCAL TIME ZONE',
                       182, 'INTERVAL YEAR(' ||c.precision#||') TO MONTH',
                       183, 'INTERVAL DAY(' ||c.precision#||') TO SECOND(' ||
                             c.scale || ')',
                       208, 'UROWID',
                       'UNDEFINED'),
       decode(c.type#, 111, 'REF'),
       nvl2(ac.synobj#, (select u.name from user$ u, obj$ o
            where o.owner#=u.user# and o.obj#=ac.synobj#), ut.name),
       c.length, c.precision#, c.scale,
       decode(sign(c.null$),-1,'D', 0, 'Y', 'N'),
       decode(c.col#, 0, to_number(null), c.col#), c.deflength,
       c.default$, h.distcnt, h.lowval, h.hival, h.density, h.null_cnt,
       case when nvl(h.distcnt,0) = 0 then h.distcnt
            when h.row_cnt = 0 then 1
	    when (h.bucket_cnt > 255
                  or
                  (h.bucket_cnt > h.distcnt
                   and h.row_cnt = h.distcnt
                   and h.density*h.bucket_cnt*2 <= 1))
                then h.row_cnt
            else h.bucket_cnt
       end,
       h.timestamp#, h.sample_size,
       decode(c.charsetform, 1, 'CHAR_CS',
                             2, 'NCHAR_CS',
                             3, NLS_CHARSET_NAME(c.charsetid),
                             4, 'ARG:'||c.charsetid),
       decode(c.charsetid, 0, to_number(NULL),
                           nls_charset_decl_len(c.length, c.charsetid)),
       decode(bitand(h.spare2, 2), 2, 'YES', 'NO'),
       decode(bitand(h.spare2, 1), 1, 'YES', 'NO'),
       h.avgcln,
       c.spare3,
       decode(c.type#, 1, decode(bitand(c.property, 8388608), 0, 'B', 'C'),
                      96, decode(bitand(c.property, 8388608), 0, 'B', 'C'),
                      null),
       decode(bitand(ac.flags, 128), 128, 'YES', 'NO'),
       decode(o.status, 1, decode(bitand(ac.flags, 256), 256, 'NO', 'YES'),
                        decode(bitand(ac.flags, 2), 2, 'NO',
                               decode(bitand(ac.flags, 4), 4, 'NO',
                                      decode(bitand(ac.flags, 8), 8, 'NO',
                                             'N/A')))),
       decode(c.property, 0, 'NO', decode(bitand(c.property, 32), 32, 'YES',
                                          'NO')),
       decode(c.property, 0, 'NO', decode(bitand(c.property, 8), 8, 'YES',
                                          'NO')),
       decode(c.segcol#, 0, to_number(null), c.segcol#), c.intcol#,
       case when nvl(h.row_cnt,0) = 0 then 'NONE'
            when (h.bucket_cnt > 255
                  or
                  (h.bucket_cnt > h.distcnt and h.row_cnt = h.distcnt
                   and h.density*h.bucket_cnt*2 <= 1))
                then 'FREQUENCY'
            else 'HEIGHT BALANCED'
       end,
       decode(bitand(c.property, 1024), 1024,
              (select decode(bitand(cl.property, 1), 1, rc.name, cl.name)
               from sys.col$ cl, attrcol$ rc where cl.intcol# = c.intcol#-1
               and cl.obj# = c.obj# and c.obj# = rc.obj#(+) and
               cl.intcol# = rc.intcol#(+)),
              decode(bitand(c.property, 1), 0, c.name,
                     (select tc.name from sys.attrcol$ tc
                      where c.obj# = tc.obj# and c.intcol# = tc.intcol#)))
from sys.col$ c, sys.obj$ o, sys.hist_head$ h, sys.user$ u,
     sys.coltype$ ac, sys.obj$ ot, sys.user$ ut
where o.obj# = c.obj#
  and o.owner# = u.user#
  and c.obj# = h.obj#(+) and c.intcol# = h.intcol#(+)
  and c.obj# = ac.obj#(+) and c.intcol# = ac.intcol#(+)
  and ac.toid = ot.oid$(+)
  and ot.type#(+) = 13
  and ot.owner# = ut.user#(+)
  and (o.type# in (3, 4)                                     /* cluster, view */
       or
       (o.type# = 2     /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192))))
  and (o.owner# = userenv('SCHEMAID')
        or
        o.obj# in ( select obj#
                    from sys.objauth$
                    where grantee# in ( select kzsrorol
                                         from x$kzsro
                                       )
                  )
        or /* user has system privileges */
          exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */)
                  )
       )
/
comment on table ALL_TAB_COLS is
'Columns of user''s tables, views and clusters'
/
comment on column ALL_TAB_COLS.TABLE_NAME is
'Table, view or cluster name'
/
comment on column ALL_TAB_COLS.COLUMN_NAME is
'Column name'
/
comment on column ALL_TAB_COLS.DATA_LENGTH is
'Length of the column in bytes'
/
comment on column ALL_TAB_COLS.DATA_TYPE is
'Datatype of the column'
/
comment on column ALL_TAB_COLS.DATA_TYPE_MOD is
'Datatype modifier of the column'
/
comment on column ALL_TAB_COLS.DATA_TYPE_OWNER is
'Owner of the datatype of the column'
/
comment on column ALL_TAB_COLS.DATA_PRECISION is
'Length: decimal digits (NUMBER) or binary digits (FLOAT)'
/
comment on column ALL_TAB_COLS.DATA_SCALE is
'Digits to right of decimal point in a number'
/
comment on column ALL_TAB_COLS.NULLABLE is
'Does column allow NULL values?'
/
comment on column ALL_TAB_COLS.COLUMN_ID is
'Sequence number of the column as created'
/
comment on column ALL_TAB_COLS.DEFAULT_LENGTH is
'Length of default value for the column'
/
comment on column ALL_TAB_COLS.DATA_DEFAULT is
'Default value for the column'
/
comment on column ALL_TAB_COLS.NUM_DISTINCT is
'The number of distinct values in the column'
/
comment on column ALL_TAB_COLS.LOW_VALUE is
'The low value in the column'
/
comment on column ALL_TAB_COLS.HIGH_VALUE is
'The high value in the column'
/
comment on column ALL_TAB_COLS.DENSITY is
'The density of the column'
/
comment on column ALL_TAB_COLS.NUM_NULLS is
'The number of nulls in the column'
/
comment on column ALL_TAB_COLS.NUM_BUCKETS is
'The number of buckets in histogram for the column'
/
comment on column ALL_TAB_COLS.LAST_ANALYZED is
'The date of the most recent time this column was analyzed'
/
comment on column ALL_TAB_COLS.SAMPLE_SIZE is
'The sample size used in analyzing this column'
/
comment on column ALL_TAB_COLS.CHARACTER_SET_NAME is
'Character set name'
/
comment on column ALL_TAB_COLS.CHAR_COL_DECL_LENGTH is
'Declaration length of character type column'
/
comment on column ALL_TAB_COLS.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column ALL_TAB_COLS.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column ALL_TAB_COLS.AVG_COL_LEN is
'The average length of the column in bytes'
/
comment on column ALL_TAB_COLS.CHAR_LENGTH is
'The maximum length of the column in characters'
/
comment on column ALL_TAB_COLS.CHAR_USED is
'C if maximum length is specified in characters, B if in bytes'
/
comment on column ALL_TAB_COLS.V80_FMT_IMAGE is
'Is column data in 8.0 image format?'
/
comment on column ALL_TAB_COLS.DATA_UPGRADED is
'Has column data been upgraded to the latest type version format?'
/
comment on column ALL_TAB_COLS.HIDDEN_COLUMN is
'Is this a hidden column?'
/
comment on column ALL_TAB_COLS.VIRTUAL_COLUMN is
'Is this a virtual column?'
/
comment on column ALL_TAB_COLS.SEGMENT_COLUMN_ID is
'Sequence number of the column in the segment'
/
comment on column ALL_TAB_COLS.INTERNAL_COLUMN_ID is
'Internal sequence number of the column'
/
comment on column ALL_TAB_COLS.QUALIFIED_COL_NAME is
'Qualified column name'
/
create or replace public synonym ALL_TAB_COLS for ALL_TAB_COLS
/
grant select on ALL_TAB_COLS to PUBLIC with grant option
/
create or replace view DBA_TAB_COLS
    (OWNER, TABLE_NAME,
     COLUMN_NAME, DATA_TYPE, DATA_TYPE_MOD, DATA_TYPE_OWNER,
     DATA_LENGTH, DATA_PRECISION, DATA_SCALE, NULLABLE, COLUMN_ID,
     DEFAULT_LENGTH, DATA_DEFAULT, NUM_DISTINCT, LOW_VALUE, HIGH_VALUE,
     DENSITY, NUM_NULLS, NUM_BUCKETS, LAST_ANALYZED, SAMPLE_SIZE,
     CHARACTER_SET_NAME, CHAR_COL_DECL_LENGTH,
     GLOBAL_STATS, USER_STATS, AVG_COL_LEN, CHAR_LENGTH, CHAR_USED,
     V80_FMT_IMAGE, DATA_UPGRADED, HIDDEN_COLUMN, VIRTUAL_COLUMN,
     SEGMENT_COLUMN_ID, INTERNAL_COLUMN_ID, HISTOGRAM, QUALIFIED_COL_NAME)
as
select u.name, o.name,
       c.name,
       decode(c.type#, 1, decode(c.charsetform, 2, 'NVARCHAR2', 'VARCHAR2'),
                       2, decode(c.scale, null,
                                 decode(c.precision#, null, 'NUMBER', 'FLOAT'),
                                 'NUMBER'),
                       8, 'LONG',
                       9, decode(c.charsetform, 2, 'NCHAR VARYING', 'VARCHAR'),
                       12, 'DATE',
                       23, 'RAW', 24, 'LONG RAW',
                       58, nvl2(ac.synobj#, (select o.name from obj$ o
                                where o.obj#=ac.synobj#), ot.name),
                       69, 'ROWID',
                       96, decode(c.charsetform, 2, 'NCHAR', 'CHAR'),
                       100, 'BINARY_FLOAT',
                       101, 'BINARY_DOUBLE',
                       105, 'MLSLABEL',
                       106, 'MLSLABEL',
                       111, nvl2(ac.synobj#, (select o.name from obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       112, decode(c.charsetform, 2, 'NCLOB', 'CLOB'),
                       113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
                       121, nvl2(ac.synobj#, (select o.name from obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       122, nvl2(ac.synobj#, (select o.name from obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       123, nvl2(ac.synobj#, (select o.name from obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       178, 'TIME(' ||c.scale|| ')',
                       179, 'TIME(' ||c.scale|| ')' || ' WITH TIME ZONE',
                       180, 'TIMESTAMP(' ||c.scale|| ')',
                       181, 'TIMESTAMP(' ||c.scale|| ')' || ' WITH TIME ZONE',
                       231, 'TIMESTAMP(' ||c.scale|| ')' || ' WITH LOCAL TIME ZONE',
                       182, 'INTERVAL YEAR(' ||c.precision#||') TO MONTH',
                       183, 'INTERVAL DAY(' ||c.precision#||') TO SECOND(' ||
                             c.scale || ')',
                       208, 'UROWID',
                       'UNDEFINED'),
       decode(c.type#, 111, 'REF'),
       nvl2(ac.synobj#, (select u.name from user$ u, obj$ o
            where o.owner#=u.user# and o.obj#=ac.synobj#), ut.name),
       c.length, c.precision#, c.scale,
       decode(sign(c.null$),-1,'D', 0, 'Y', 'N'),
       decode(c.col#, 0, to_number(null), c.col#), c.deflength,
       c.default$, h.distcnt, h.lowval, h.hival, h.density, h.null_cnt,
       case when nvl(h.distcnt,0) = 0 then h.distcnt
            when h.row_cnt = 0 then 1
	    when (h.bucket_cnt > 255
                  or
                  (h.bucket_cnt > h.distcnt
                   and h.row_cnt = h.distcnt
                   and h.density*h.bucket_cnt*2 <= 1))
                then h.row_cnt
            else h.bucket_cnt
       end,
       h.timestamp#, h.sample_size,
       decode(c.charsetform, 1, 'CHAR_CS',
                             2, 'NCHAR_CS',
                             3, NLS_CHARSET_NAME(c.charsetid),
                             4, 'ARG:'||c.charsetid),
       decode(c.charsetid, 0, to_number(NULL),
                           nls_charset_decl_len(c.length, c.charsetid)),
       decode(bitand(h.spare2, 2), 2, 'YES', 'NO'),
       decode(bitand(h.spare2, 1), 1, 'YES', 'NO'),
       h.avgcln,
       c.spare3,
       decode(c.type#, 1, decode(bitand(c.property, 8388608), 0, 'B', 'C'),
                      96, decode(bitand(c.property, 8388608), 0, 'B', 'C'),
                      null),
       decode(bitand(ac.flags, 128), 128, 'YES', 'NO'),
       decode(o.status, 1, decode(bitand(ac.flags, 256), 256, 'NO', 'YES'),
                        decode(bitand(ac.flags, 2), 2, 'NO',
                               decode(bitand(ac.flags, 4), 4, 'NO',
                                      decode(bitand(ac.flags, 8), 8, 'NO',
                                             'N/A')))),
       decode(c.property, 0, 'NO', decode(bitand(c.property, 32), 32, 'YES',
                                          'NO')),
       decode(c.property, 0, 'NO', decode(bitand(c.property, 8), 8, 'YES',
                                          'NO')),
       decode(c.segcol#, 0, to_number(null), c.segcol#), c.intcol#,
       case when nvl(h.row_cnt,0) = 0 then 'NONE'
            when (h.bucket_cnt > 255
                  or
                  (h.bucket_cnt > h.distcnt and h.row_cnt = h.distcnt
                   and h.density*h.bucket_cnt*2 <= 1))
                then 'FREQUENCY'
            else 'HEIGHT BALANCED'
       end,
       decode(bitand(c.property, 1024), 1024,
              (select decode(bitand(cl.property, 1), 1, rc.name, cl.name)
               from sys.col$ cl, attrcol$ rc where cl.intcol# = c.intcol#-1
               and cl.obj# = c.obj# and c.obj# = rc.obj#(+) and
               cl.intcol# = rc.intcol#(+)),
              decode(bitand(c.property, 1), 0, c.name,
                     (select tc.name from sys.attrcol$ tc
                      where c.obj# = tc.obj# and c.intcol# = tc.intcol#)))
from sys.col$ c, sys.obj$ o, sys.hist_head$ h, sys.user$ u,
     sys.coltype$ ac, sys.obj$ ot, sys.user$ ut
where o.obj# = c.obj#
  and o.owner# = u.user#
  and c.obj# = h.obj#(+) and c.intcol# = h.intcol#(+)
  and c.obj# = ac.obj#(+) and c.intcol# = ac.intcol#(+)
  and ac.toid = ot.oid$(+)
  and ot.type#(+) = 13
  and ot.owner# = ut.user#(+)
  and (o.type# in (3, 4)                                     /* cluster, view */
       or
       (o.type# = 2     /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192))))
/
comment on table DBA_TAB_COLS is
'Columns of user''s tables, views and clusters'
/
comment on column DBA_TAB_COLS.TABLE_NAME is
'Table, view or cluster name'
/
comment on column DBA_TAB_COLS.COLUMN_NAME is
'Column name'
/
comment on column DBA_TAB_COLS.DATA_LENGTH is
'Length of the column in bytes'
/
comment on column DBA_TAB_COLS.DATA_TYPE is
'Datatype of the column'
/
comment on column DBA_TAB_COLS.DATA_TYPE_MOD is
'Datatype modifier of the column'
/
comment on column DBA_TAB_COLS.DATA_TYPE_OWNER is
'Owner of the datatype of the column'
/
comment on column DBA_TAB_COLS.DATA_PRECISION is
'Length: decimal digits (NUMBER) or binary digits (FLOAT)'
/
comment on column DBA_TAB_COLS.DATA_SCALE is
'Digits to right of decimal point in a number'
/
comment on column DBA_TAB_COLS.NULLABLE is
'Does column allow NULL values?'
/
comment on column DBA_TAB_COLS.COLUMN_ID is
'Sequence number of the column as created'
/
comment on column DBA_TAB_COLS.DEFAULT_LENGTH is
'Length of default value for the column'
/
comment on column DBA_TAB_COLS.DATA_DEFAULT is
'Default value for the column'
/
comment on column DBA_TAB_COLS.NUM_DISTINCT is
'The number of distinct values in the column'
/
comment on column DBA_TAB_COLS.LOW_VALUE is
'The low value in the column'
/
comment on column DBA_TAB_COLS.HIGH_VALUE is
'The high value in the column'
/
comment on column DBA_TAB_COLS.DENSITY is
'The density of the column'
/
comment on column DBA_TAB_COLS.NUM_NULLS is
'The number of nulls in the column'
/
comment on column DBA_TAB_COLS.NUM_BUCKETS is
'The number of buckets in histogram for the column'
/
comment on column DBA_TAB_COLS.LAST_ANALYZED is
'The date of the most recent time this column was analyzed'
/
comment on column DBA_TAB_COLS.SAMPLE_SIZE is
'The sample size used in analyzing this column'
/
comment on column DBA_TAB_COLS.CHARACTER_SET_NAME is
'Character set name'
/
comment on column DBA_TAB_COLS.CHAR_COL_DECL_LENGTH is
'Declaration length of character type column'
/
comment on column DBA_TAB_COLS.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column DBA_TAB_COLS.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column DBA_TAB_COLS.AVG_COL_LEN is
'The average length of the column in bytes'
/
comment on column DBA_TAB_COLS.CHAR_LENGTH is
'The maximum length of the column in characters'
/
comment on column DBA_TAB_COLS.CHAR_USED is
'C if the width was specified in characters, B if in bytes'
/
comment on column DBA_TAB_COLS.V80_FMT_IMAGE is
'Is column data in 8.0 image format?'
/
comment on column DBA_TAB_COLS.DATA_UPGRADED is
'Has column data been upgraded to the latest type version format?'
/
comment on column DBA_TAB_COLS.HIDDEN_COLUMN is
'Is this a hidden column?'
/
comment on column DBA_TAB_COLS.VIRTUAL_COLUMN is
'Is this a virtual column?'
/
comment on column DBA_TAB_COLS.SEGMENT_COLUMN_ID is
'Sequence number of the column in the segment'
/
comment on column DBA_TAB_COLS.INTERNAL_COLUMN_ID is
'Internal sequence number of the column'
/
comment on column DBA_TAB_COLS.QUALIFIED_COL_NAME is
'Qualified column name'
/
create or replace public synonym DBA_TAB_COLS for DBA_TAB_COLS
/
grant select on DBA_TAB_COLS to select_catalog_role
/
remark
remark  FAMILY "TAB_COLUMNS"
remark  The columns that make up objects:  Tables, Views, Clusters
remark  Includes information specified or implied by user in
remark  CREATE/ALTER TABLE/VIEW/CLUSTER.
remark
create or replace view USER_TAB_COLUMNS
    (TABLE_NAME, COLUMN_NAME, DATA_TYPE, DATA_TYPE_MOD, DATA_TYPE_OWNER,
     DATA_LENGTH, DATA_PRECISION, DATA_SCALE, NULLABLE, COLUMN_ID,
     DEFAULT_LENGTH, DATA_DEFAULT, NUM_DISTINCT, LOW_VALUE, HIGH_VALUE,
     DENSITY, NUM_NULLS, NUM_BUCKETS, LAST_ANALYZED, SAMPLE_SIZE,
     CHARACTER_SET_NAME, CHAR_COL_DECL_LENGTH,
     GLOBAL_STATS, USER_STATS, AVG_COL_LEN, CHAR_LENGTH, CHAR_USED,
     V80_FMT_IMAGE, DATA_UPGRADED, HISTOGRAM)
as
select TABLE_NAME, COLUMN_NAME, DATA_TYPE, DATA_TYPE_MOD, DATA_TYPE_OWNER,
       DATA_LENGTH, DATA_PRECISION, DATA_SCALE, NULLABLE, COLUMN_ID,
       DEFAULT_LENGTH, DATA_DEFAULT, NUM_DISTINCT, LOW_VALUE, HIGH_VALUE,
       DENSITY, NUM_NULLS, NUM_BUCKETS, LAST_ANALYZED, SAMPLE_SIZE,
       CHARACTER_SET_NAME, CHAR_COL_DECL_LENGTH,
       GLOBAL_STATS, USER_STATS, AVG_COL_LEN, CHAR_LENGTH, CHAR_USED,
       V80_FMT_IMAGE, DATA_UPGRADED, HISTOGRAM
  from USER_TAB_COLS
 where HIDDEN_COLUMN = 'NO'
/
comment on table USER_TAB_COLUMNS is
'Columns of user''s tables, views and clusters'
/
comment on column USER_TAB_COLUMNS.TABLE_NAME is
'Table, view or cluster name'
/
comment on column USER_TAB_COLUMNS.COLUMN_NAME is
'Column name'
/
comment on column USER_TAB_COLUMNS.DATA_LENGTH is
'Length of the column in bytes'
/
comment on column USER_TAB_COLUMNS.DATA_TYPE is
'Datatype of the column'
/
comment on column USER_TAB_COLUMNS.DATA_TYPE_MOD is
'Datatype modifier of the column'
/
comment on column USER_TAB_COLUMNS.DATA_TYPE_OWNER is
'Owner of the datatype of the column'
/
comment on column USER_TAB_COLUMNS.DATA_PRECISION is
'Length: decimal digits (NUMBER) or binary digits (FLOAT)'
/
comment on column USER_TAB_COLUMNS.DATA_SCALE is
'Digits to right of decimal point in a number'
/
comment on column USER_TAB_COLUMNS.NULLABLE is
'Does column allow NULL values?'
/
comment on column USER_TAB_COLUMNS.COLUMN_ID is
'Sequence number of the column as created'
/
comment on column USER_TAB_COLUMNS.DEFAULT_LENGTH is
'Length of default value for the column'
/
comment on column USER_TAB_COLUMNS.DATA_DEFAULT is
'Default value for the column'
/
comment on column USER_TAB_COLUMNS.NUM_DISTINCT is
'The number of distinct values in the column'
/
comment on column USER_TAB_COLUMNS.LOW_VALUE is
'The low value in the column'
/
comment on column USER_TAB_COLUMNS.HIGH_VALUE is
'The high value in the column'
/
comment on column USER_TAB_COLUMNS.DENSITY is
'The density of the column'
/
comment on column USER_TAB_COLUMNS.NUM_NULLS is
'The number of nulls in the column'
/
comment on column USER_TAB_COLUMNS.NUM_BUCKETS is
'The number of buckets in histogram for the column'
/
comment on column USER_TAB_COLUMNS.LAST_ANALYZED is
'The date of the most recent time this column was analyzed'
/
comment on column USER_TAB_COLUMNS.SAMPLE_SIZE is
'The sample size used in analyzing this column'
/
comment on column USER_TAB_COLUMNS.CHARACTER_SET_NAME is
'Character set name'
/
comment on column USER_TAB_COLUMNS.CHAR_COL_DECL_LENGTH is
'Declaration length of character type column'
/
comment on column USER_TAB_COLUMNS.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column USER_TAB_COLUMNS.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column USER_TAB_COLUMNS.AVG_COL_LEN is
'The average length of the column in bytes'
/
comment on column USER_TAB_COLUMNS.CHAR_LENGTH is
'The maximum length of the column in characters'
/
comment on column USER_TAB_COLUMNS.CHAR_USED is
'C is maximum length given in characters, B if in bytes'
/
comment on column USER_TAB_COLUMNS.V80_FMT_IMAGE is
'Is column data in 8.0 image format?'
/
comment on column USER_TAB_COLUMNS.DATA_UPGRADED is
'Has column data been upgraded to the latest type version format?'
/
create or replace public synonym USER_TAB_COLUMNS for USER_TAB_COLUMNS
/
create or replace public synonym COLS for USER_TAB_COLUMNS
/
grant select on USER_TAB_COLUMNS to PUBLIC with grant option
/
create or replace view ALL_TAB_COLUMNS
    (OWNER, TABLE_NAME,
     COLUMN_NAME, DATA_TYPE, DATA_TYPE_MOD, DATA_TYPE_OWNER,
     DATA_LENGTH, DATA_PRECISION, DATA_SCALE, NULLABLE, COLUMN_ID,
     DEFAULT_LENGTH, DATA_DEFAULT, NUM_DISTINCT, LOW_VALUE, HIGH_VALUE,
     DENSITY, NUM_NULLS, NUM_BUCKETS, LAST_ANALYZED, SAMPLE_SIZE,
     CHARACTER_SET_NAME, CHAR_COL_DECL_LENGTH,
     GLOBAL_STATS, USER_STATS, AVG_COL_LEN, CHAR_LENGTH, CHAR_USED,
     V80_FMT_IMAGE, DATA_UPGRADED, HISTOGRAM)
as
select /*+ rule */ OWNER, TABLE_NAME,
       COLUMN_NAME, DATA_TYPE, DATA_TYPE_MOD, DATA_TYPE_OWNER,
       DATA_LENGTH, DATA_PRECISION, DATA_SCALE, NULLABLE, COLUMN_ID,
       DEFAULT_LENGTH, DATA_DEFAULT, NUM_DISTINCT, LOW_VALUE, HIGH_VALUE,
       DENSITY, NUM_NULLS, NUM_BUCKETS, LAST_ANALYZED, SAMPLE_SIZE,
       CHARACTER_SET_NAME, CHAR_COL_DECL_LENGTH,
       GLOBAL_STATS, USER_STATS, AVG_COL_LEN, CHAR_LENGTH, CHAR_USED,
       V80_FMT_IMAGE, DATA_UPGRADED, HISTOGRAM
  from ALL_TAB_COLS
 where HIDDEN_COLUMN = 'NO'
/
comment on table ALL_TAB_COLUMNS is
'Columns of user''s tables, views and clusters'
/
comment on column ALL_TAB_COLUMNS.TABLE_NAME is
'Table, view or cluster name'
/
comment on column ALL_TAB_COLUMNS.COLUMN_NAME is
'Column name'
/
comment on column ALL_TAB_COLUMNS.DATA_LENGTH is
'Length of the column in bytes'
/
comment on column ALL_TAB_COLUMNS.DATA_TYPE is
'Datatype of the column'
/
comment on column ALL_TAB_COLUMNS.DATA_TYPE_MOD is
'Datatype modifier of the column'
/
comment on column ALL_TAB_COLUMNS.DATA_TYPE_OWNER is
'Owner of the datatype of the column'
/
comment on column ALL_TAB_COLUMNS.DATA_PRECISION is
'Length: decimal digits (NUMBER) or binary digits (FLOAT)'
/
comment on column ALL_TAB_COLUMNS.DATA_SCALE is
'Digits to right of decimal point in a number'
/
comment on column ALL_TAB_COLUMNS.NULLABLE is
'Does column allow NULL values?'
/
comment on column ALL_TAB_COLUMNS.COLUMN_ID is
'Sequence number of the column as created'
/
comment on column ALL_TAB_COLUMNS.DEFAULT_LENGTH is
'Length of default value for the column'
/
comment on column ALL_TAB_COLUMNS.DATA_DEFAULT is
'Default value for the column'
/
comment on column ALL_TAB_COLUMNS.NUM_DISTINCT is
'The number of distinct values in the column'
/
comment on column ALL_TAB_COLUMNS.LOW_VALUE is
'The low value in the column'
/
comment on column ALL_TAB_COLUMNS.HIGH_VALUE is
'The high value in the column'
/
comment on column ALL_TAB_COLUMNS.DENSITY is
'The density of the column'
/
comment on column ALL_TAB_COLUMNS.NUM_NULLS is
'The number of nulls in the column'
/
comment on column ALL_TAB_COLUMNS.NUM_BUCKETS is
'The number of buckets in histogram for the column'
/
comment on column ALL_TAB_COLUMNS.LAST_ANALYZED is
'The date of the most recent time this column was analyzed'
/
comment on column ALL_TAB_COLUMNS.SAMPLE_SIZE is
'The sample size used in analyzing this column'
/
comment on column ALL_TAB_COLUMNS.CHARACTER_SET_NAME is
'Character set name'
/
comment on column ALL_TAB_COLUMNS.CHAR_COL_DECL_LENGTH is
'Declaration length of character type column'
/
comment on column ALL_TAB_COLUMNS.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column ALL_TAB_COLUMNS.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column ALL_TAB_COLUMNS.AVG_COL_LEN is
'The average length of the column in bytes'
/
comment on column ALL_TAB_COLUMNS.CHAR_LENGTH is
'The maximum length of the column in characters'
/
comment on column ALL_TAB_COLUMNS.CHAR_USED is
'C if maximum length is specified in characters, B if in bytes'
/
comment on column ALL_TAB_COLUMNS.V80_FMT_IMAGE is
'Is column data in 8.0 image format?'
/
comment on column ALL_TAB_COLUMNS.DATA_UPGRADED is
'Has column data been upgraded to the latest type version format?'
/
create or replace public synonym ALL_TAB_COLUMNS for ALL_TAB_COLUMNS
/
grant select on ALL_TAB_COLUMNS to PUBLIC with grant option
/
create or replace view DBA_TAB_COLUMNS
    (OWNER, TABLE_NAME,
     COLUMN_NAME, DATA_TYPE, DATA_TYPE_MOD, DATA_TYPE_OWNER,
     DATA_LENGTH, DATA_PRECISION, DATA_SCALE, NULLABLE, COLUMN_ID,
     DEFAULT_LENGTH, DATA_DEFAULT, NUM_DISTINCT, LOW_VALUE, HIGH_VALUE,
     DENSITY, NUM_NULLS, NUM_BUCKETS, LAST_ANALYZED, SAMPLE_SIZE,
     CHARACTER_SET_NAME, CHAR_COL_DECL_LENGTH,
     GLOBAL_STATS, USER_STATS, AVG_COL_LEN, CHAR_LENGTH, CHAR_USED,
     V80_FMT_IMAGE, DATA_UPGRADED, HISTOGRAM)
as
select OWNER, TABLE_NAME,
       COLUMN_NAME, DATA_TYPE, DATA_TYPE_MOD, DATA_TYPE_OWNER,
       DATA_LENGTH, DATA_PRECISION, DATA_SCALE, NULLABLE, COLUMN_ID,
       DEFAULT_LENGTH, DATA_DEFAULT, NUM_DISTINCT, LOW_VALUE, HIGH_VALUE,
       DENSITY, NUM_NULLS, NUM_BUCKETS, LAST_ANALYZED, SAMPLE_SIZE,
       CHARACTER_SET_NAME, CHAR_COL_DECL_LENGTH,
       GLOBAL_STATS, USER_STATS, AVG_COL_LEN, CHAR_LENGTH, CHAR_USED,
       V80_FMT_IMAGE, DATA_UPGRADED, HISTOGRAM
  from DBA_TAB_COLS
 where HIDDEN_COLUMN = 'NO'
/
comment on table DBA_TAB_COLUMNS is
'Columns of user''s tables, views and clusters'
/
comment on column DBA_TAB_COLUMNS.TABLE_NAME is
'Table, view or cluster name'
/
comment on column DBA_TAB_COLUMNS.COLUMN_NAME is
'Column name'
/
comment on column DBA_TAB_COLUMNS.DATA_LENGTH is
'Length of the column in bytes'
/
comment on column DBA_TAB_COLUMNS.DATA_TYPE is
'Datatype of the column'
/
comment on column DBA_TAB_COLUMNS.DATA_TYPE_MOD is
'Datatype modifier of the column'
/
comment on column DBA_TAB_COLUMNS.DATA_TYPE_OWNER is
'Owner of the datatype of the column'
/
comment on column DBA_TAB_COLUMNS.DATA_PRECISION is
'Length: decimal digits (NUMBER) or binary digits (FLOAT)'
/
comment on column DBA_TAB_COLUMNS.DATA_SCALE is
'Digits to right of decimal point in a number'
/
comment on column DBA_TAB_COLUMNS.NULLABLE is
'Does column allow NULL values?'
/
comment on column DBA_TAB_COLUMNS.COLUMN_ID is
'Sequence number of the column as created'
/
comment on column DBA_TAB_COLUMNS.DEFAULT_LENGTH is
'Length of default value for the column'
/
comment on column DBA_TAB_COLUMNS.DATA_DEFAULT is
'Default value for the column'
/
comment on column DBA_TAB_COLUMNS.NUM_DISTINCT is
'The number of distinct values in the column'
/
comment on column DBA_TAB_COLUMNS.LOW_VALUE is
'The low value in the column'
/
comment on column DBA_TAB_COLUMNS.HIGH_VALUE is
'The high value in the column'
/
comment on column DBA_TAB_COLUMNS.DENSITY is
'The density of the column'
/
comment on column DBA_TAB_COLUMNS.NUM_NULLS is
'The number of nulls in the column'
/
comment on column DBA_TAB_COLUMNS.NUM_BUCKETS is
'The number of buckets in histogram for the column'
/
comment on column DBA_TAB_COLUMNS.LAST_ANALYZED is
'The date of the most recent time this column was analyzed'
/
comment on column DBA_TAB_COLUMNS.SAMPLE_SIZE is
'The sample size used in analyzing this column'
/
comment on column DBA_TAB_COLUMNS.CHARACTER_SET_NAME is
'Character set name'
/
comment on column DBA_TAB_COLUMNS.CHAR_COL_DECL_LENGTH is
'Declaration length of character type column'
/
comment on column DBA_TAB_COLUMNS.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column DBA_TAB_COLUMNS.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column DBA_TAB_COLUMNS.AVG_COL_LEN is
'The average length of the column in bytes'
/
comment on column DBA_TAB_COLUMNS.CHAR_LENGTH is
'The maximum length of the column in characters'
/
comment on column DBA_TAB_COLUMNS.CHAR_USED is
'C if the width was specified in characters, B if in bytes'
/
comment on column DBA_TAB_COLUMNS.V80_FMT_IMAGE is
'Is column data in 8.0 image format?'
/
comment on column DBA_TAB_COLUMNS.DATA_UPGRADED is
'Has column data been upgraded to the latest type version format?'
/
create or replace public synonym DBA_TAB_COLUMNS for DBA_TAB_COLUMNS
/
grant select on DBA_TAB_COLUMNS to select_catalog_role
/
remark
remark  FAMILY "_NESTED_TABLE_COLS"
remark  The columns of the nested table's storage tables
remark
create or replace view USER_NESTED_TABLE_COLS
    (TABLE_NAME, COLUMN_NAME, DATA_TYPE, DATA_TYPE_MOD, DATA_TYPE_OWNER,
     DATA_LENGTH, DATA_PRECISION, DATA_SCALE, NULLABLE, COLUMN_ID,
     DEFAULT_LENGTH, DATA_DEFAULT, NUM_DISTINCT, LOW_VALUE, HIGH_VALUE,
     DENSITY, NUM_NULLS, NUM_BUCKETS, LAST_ANALYZED, SAMPLE_SIZE,
     CHARACTER_SET_NAME, CHAR_COL_DECL_LENGTH,
     GLOBAL_STATS, USER_STATS, AVG_COL_LEN, CHAR_LENGTH, CHAR_USED,
     V80_FMT_IMAGE, DATA_UPGRADED, HIDDEN_COLUMN, VIRTUAL_COLUMN,
     SEGMENT_COLUMN_ID, INTERNAL_COLUMN_ID, HISTOGRAM, QUALIFIED_COL_NAME)
as
select o.name,
       c.name,
       decode(c.type#, 1, decode(c.charsetform, 2, 'NVARCHAR2', 'VARCHAR2'),
                       2, decode(c.scale, null,
                                 decode(c.precision#, null, 'NUMBER', 'FLOAT'),
                                 'NUMBER'),
                       8, 'LONG',
                       9, decode(c.charsetform, 2, 'NCHAR VARYING', 'VARCHAR'),
                       12, 'DATE',
                       23, 'RAW', 24, 'LONG RAW',
                       58, nvl2(ac.synobj#, (select o.name from obj$ o
                                where o.obj#=ac.synobj#), ot.name),
                       69, 'ROWID',
                       96, decode(c.charsetform, 2, 'NCHAR', 'CHAR'),
                       100, 'BINARY_FLOAT',
                       101, 'BINARY_DOUBLE',
                       105, 'MLSLABEL',
                       106, 'MLSLABEL',
                       111, nvl2(ac.synobj#, (select o.name from obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       112, decode(c.charsetform, 2, 'NCLOB', 'CLOB'),
                       113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
                       121, nvl2(ac.synobj#, (select o.name from obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       122, nvl2(ac.synobj#, (select o.name from obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       123, nvl2(ac.synobj#, (select o.name from obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       178, 'TIME(' ||c.scale|| ')',
                       179, 'TIME(' ||c.scale|| ')' || ' WITH TIME ZONE',
                       180, 'TIMESTAMP(' ||c.scale|| ')',
                       181, 'TIMESTAMP(' ||c.scale|| ')' || ' WITH TIME ZONE',
                       231, 'TIMESTAMP(' ||c.scale|| ')' || ' WITH LOCAL TIME ZONE',
                       182, 'INTERVAL YEAR(' ||c.precision#||') TO MONTH',
                       183, 'INTERVAL DAY(' ||c.precision#||') TO SECOND(' ||
                             c.scale || ')',
                       208, 'UROWID',
                       'UNDEFINED'),
       decode(c.type#, 111, 'REF'),
       nvl2(ac.synobj#, (select u.name from user$ u, obj$ o
            where o.owner#=u.user# and o.obj#=ac.synobj#), ut.name),
       c.length, c.precision#, c.scale,
       decode(sign(c.null$),-1,'D', 0, 'Y', 'N'),
       decode(c.col#, 0, to_number(null), c.col#), c.deflength,
       c.default$, h.distcnt, h.lowval, h.hival, h.density, h.null_cnt,
       case when nvl(h.distcnt,0) = 0 then h.distcnt
            when h.row_cnt = 0 then 1
	    when (h.bucket_cnt > 255
                  or
                  (h.bucket_cnt > h.distcnt
                   and h.row_cnt = h.distcnt
                   and h.density*h.bucket_cnt*2 <= 1))
                then h.row_cnt
            else h.bucket_cnt
       end,
       h.timestamp#, h.sample_size,
       decode(c.charsetform, 1, 'CHAR_CS',
                             2, 'NCHAR_CS',
                             3, NLS_CHARSET_NAME(c.charsetid),
                             4, 'ARG:'||c.charsetid),
       decode(c.charsetid, 0, to_number(NULL),
                           nls_charset_decl_len(c.length, c.charsetid)),
       decode(bitand(h.spare2, 2), 2, 'YES', 'NO'),
       decode(bitand(h.spare2, 1), 1, 'YES', 'NO'),
       h.avgcln,
       c.spare3,
       decode(c.type#, 1, decode(bitand(c.property, 8388608), 0, 'B', 'C'),
                      96, decode(bitand(c.property, 8388608), 0, 'B', 'C'),
                      null),
       decode(bitand(ac.flags, 128), 128, 'YES', 'NO'),
       decode(o.status, 1, decode(bitand(ac.flags, 256), 256, 'NO', 'YES'),
                        decode(bitand(ac.flags, 2), 2, 'NO',
                               decode(bitand(ac.flags, 4), 4, 'NO',
                                      decode(bitand(ac.flags, 8), 8, 'NO',
                                             'N/A')))),
       decode(c.property, 0, 'NO', decode(bitand(c.property, 32), 32, 'YES',
                                          'NO')),
       decode(c.property, 0, 'NO', decode(bitand(c.property, 8), 8, 'YES',
                                          'NO')),
       decode(c.segcol#, 0, to_number(null), c.segcol#), c.intcol#,
       case when nvl(h.row_cnt,0) = 0 then 'NONE'
            when (h.bucket_cnt > 255
                  or
                  (h.bucket_cnt > h.distcnt and h.row_cnt = h.distcnt
                   and h.density*h.bucket_cnt*2 <= 1))
                then 'FREQUENCY'
            else 'HEIGHT BALANCED'
       end,
       decode(bitand(c.property, 1024), 1024,
              (select decode(bitand(cl.property, 1), 1, rc.name, cl.name)
               from sys.col$ cl, attrcol$ rc where cl.intcol# = c.intcol#-1
               and cl.obj# = c.obj# and c.obj# = rc.obj#(+) and
               cl.intcol# = rc.intcol#(+)),
              decode(bitand(c.property, 1), 0, c.name,
                     (select tc.name from sys.attrcol$ tc
                      where c.obj# = tc.obj# and c.intcol# = tc.intcol#)))
from sys.col$ c, sys.obj$ o, sys.hist_head$ h, sys.coltype$ ac, sys.obj$ ot,
     sys.user$ ut, sys.tab$ t
where o.obj# = c.obj#
  and o.owner# = userenv('SCHEMAID')
  and c.obj# = h.obj#(+) and c.intcol# = h.intcol#(+)
  and c.obj# = ac.obj#(+) and c.intcol# = ac.intcol#(+)
  and ac.toid = ot.oid$(+)
  and ot.type#(+) = 13
  and ot.owner# = ut.user#(+)
  and o.obj# = t.obj#
  and bitand(t.property, 8192) = 8192           /* nested tables */
/
comment on table USER_NESTED_TABLE_COLS is
'Columns of nested tables'
/
comment on column USER_NESTED_TABLE_COLS.TABLE_NAME is
'Nested table name'
/
comment on column USER_NESTED_TABLE_COLS.COLUMN_NAME is
'Column name'
/
comment on column USER_NESTED_TABLE_COLS.DATA_LENGTH is
'Length of the column in bytes'
/
comment on column USER_NESTED_TABLE_COLS.DATA_TYPE is
'Datatype of the column'
/
comment on column USER_NESTED_TABLE_COLS.DATA_TYPE_MOD is
'Datatype modifier of the column'
/
comment on column USER_NESTED_TABLE_COLS.DATA_TYPE_OWNER is
'Owner of the datatype of the column'
/
comment on column USER_NESTED_TABLE_COLS.DATA_PRECISION is
'Length: decimal digits (NUMBER) or binary digits (FLOAT)'
/
comment on column USER_NESTED_TABLE_COLS.DATA_SCALE is
'Digits to right of decimal point in a number'
/
comment on column USER_NESTED_TABLE_COLS.NULLABLE is
'Does column allow NULL values?'
/
comment on column USER_NESTED_TABLE_COLS.COLUMN_ID is
'Sequence number of the column as created'
/
comment on column USER_NESTED_TABLE_COLS.DEFAULT_LENGTH is
'Length of default value for the column'
/
comment on column USER_NESTED_TABLE_COLS.DATA_DEFAULT is
'Default value for the column'
/
comment on column USER_NESTED_TABLE_COLS.NUM_DISTINCT is
'The number of distinct values in the column'
/
comment on column USER_NESTED_TABLE_COLS.LOW_VALUE is
'The low value in the column'
/
comment on column USER_NESTED_TABLE_COLS.HIGH_VALUE is
'The high value in the column'
/
comment on column USER_NESTED_TABLE_COLS.DENSITY is
'The density of the column'
/
comment on column USER_NESTED_TABLE_COLS.NUM_NULLS is
'The number of nulls in the column'
/
comment on column USER_NESTED_TABLE_COLS.NUM_BUCKETS is
'The number of buckets in histogram for the column'
/
comment on column USER_NESTED_TABLE_COLS.LAST_ANALYZED is
'The date of the most recent time this column was analyzed'
/
comment on column USER_NESTED_TABLE_COLS.SAMPLE_SIZE is
'The sample size used in analyzing this column'
/
comment on column USER_NESTED_TABLE_COLS.CHARACTER_SET_NAME is
'Character set name'
/
comment on column USER_NESTED_TABLE_COLS.CHAR_COL_DECL_LENGTH is
'Declaration length of character type column'
/
comment on column USER_NESTED_TABLE_COLS.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column USER_NESTED_TABLE_COLS.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column USER_NESTED_TABLE_COLS.AVG_COL_LEN is
'The average length of the column in bytes'
/
comment on column USER_NESTED_TABLE_COLS.CHAR_LENGTH is
'The maximum length of the column in characters'
/
comment on column USER_NESTED_TABLE_COLS.CHAR_USED is
'C is maximum length given in characters, B if in bytes'
/
comment on column USER_NESTED_TABLE_COLS.V80_FMT_IMAGE is
'Is column data in 8.0 image format?'
/
comment on column USER_NESTED_TABLE_COLS.DATA_UPGRADED is
'Has column data been upgraded to the latest type version format?'
/
comment on column USER_NESTED_TABLE_COLS.HIDDEN_COLUMN is
'Is this a hidden column?'
/
comment on column USER_NESTED_TABLE_COLS.VIRTUAL_COLUMN is
'Is this a virtual column?'
/
comment on column USER_NESTED_TABLE_COLS.SEGMENT_COLUMN_ID is
'Sequence number of the column in the segment'
/
comment on column USER_NESTED_TABLE_COLS.INTERNAL_COLUMN_ID is
'Internal sequence number of the column'
/
comment on column USER_NESTED_TABLE_COLS.QUALIFIED_COL_NAME is
'Qualified column name'
/
create or replace public synonym USER_NESTED_TABLE_COLS for USER_NESTED_TABLE_COLS
/
grant select on USER_NESTED_TABLE_COLS to PUBLIC with grant option
/
create or replace view ALL_NESTED_TABLE_COLS
    (OWNER, TABLE_NAME,
     COLUMN_NAME, DATA_TYPE, DATA_TYPE_MOD, DATA_TYPE_OWNER,
     DATA_LENGTH, DATA_PRECISION, DATA_SCALE, NULLABLE, COLUMN_ID,
     DEFAULT_LENGTH, DATA_DEFAULT, NUM_DISTINCT, LOW_VALUE, HIGH_VALUE,
     DENSITY, NUM_NULLS, NUM_BUCKETS, LAST_ANALYZED, SAMPLE_SIZE,
     CHARACTER_SET_NAME, CHAR_COL_DECL_LENGTH,
     GLOBAL_STATS, USER_STATS, AVG_COL_LEN, CHAR_LENGTH, CHAR_USED,
     V80_FMT_IMAGE, DATA_UPGRADED, HIDDEN_COLUMN, VIRTUAL_COLUMN,
     SEGMENT_COLUMN_ID, INTERNAL_COLUMN_ID, HISTOGRAM, QUALIFIED_COL_NAME)
as
select u.name, o.name,
       c.name,
       decode(c.type#, 1, decode(c.charsetform, 2, 'NVARCHAR2', 'VARCHAR2'),
                       2, decode(c.scale, null,
                                 decode(c.precision#, null, 'NUMBER', 'FLOAT'),
                                 'NUMBER'),
                       8, 'LONG',
                       9, decode(c.charsetform, 2, 'NCHAR VARYING', 'VARCHAR'),
                       12, 'DATE',
                       23, 'RAW', 24, 'LONG RAW',
                       58, nvl2(ac.synobj#, (select o.name from obj$ o
                                where o.obj#=ac.synobj#), ot.name),
                       69, 'ROWID',
                       96, decode(c.charsetform, 2, 'NCHAR', 'CHAR'),
                       100, 'BINARY_FLOAT',
                       101, 'BINARY_DOUBLE',
                       105, 'MLSLABEL',
                       106, 'MLSLABEL',
                       111, nvl2(ac.synobj#, (select o.name from obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       112, decode(c.charsetform, 2, 'NCLOB', 'CLOB'),
                       113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
                       121, nvl2(ac.synobj#, (select o.name from obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       122, nvl2(ac.synobj#, (select o.name from obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       123, nvl2(ac.synobj#, (select o.name from obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       178, 'TIME(' ||c.scale|| ')',
                       179, 'TIME(' ||c.scale|| ')' || ' WITH TIME ZONE',
                       180, 'TIMESTAMP(' ||c.scale|| ')',
                       181, 'TIMESTAMP(' ||c.scale|| ')' || ' WITH TIME ZONE',
                       231, 'TIMESTAMP(' ||c.scale|| ')' || ' WITH LOCAL TIME ZONE',
                       182, 'INTERVAL YEAR(' ||c.precision#||') TO MONTH',
                       183, 'INTERVAL DAY(' ||c.precision#||') TO SECOND(' ||
                             c.scale || ')',
                       208, 'UROWID',
                       'UNDEFINED'),
       decode(c.type#, 111, 'REF'),
       nvl2(ac.synobj#, (select u.name from user$ u, obj$ o
            where o.owner#=u.user# and o.obj#=ac.synobj#), ut.name),
       c.length, c.precision#, c.scale,
       decode(sign(c.null$),-1,'D', 0, 'Y', 'N'),
       decode(c.col#, 0, to_number(null), c.col#), c.deflength,
       c.default$, h.distcnt, h.lowval, h.hival, h.density, h.null_cnt,
       case when nvl(h.distcnt,0) = 0 then h.distcnt
            when h.row_cnt = 0 then 1
	    when (h.bucket_cnt > 255
                  or
                  (h.bucket_cnt > h.distcnt
                   and h.row_cnt = h.distcnt
                   and h.density*h.bucket_cnt*2 <= 1))
                then h.row_cnt
            else h.bucket_cnt
       end,
       h.timestamp#, h.sample_size,
       decode(c.charsetform, 1, 'CHAR_CS',
                             2, 'NCHAR_CS',
                             3, NLS_CHARSET_NAME(c.charsetid),
                             4, 'ARG:'||c.charsetid),
       decode(c.charsetid, 0, to_number(NULL),
                           nls_charset_decl_len(c.length, c.charsetid)),
       decode(bitand(h.spare2, 2), 2, 'YES', 'NO'),
       decode(bitand(h.spare2, 1), 1, 'YES', 'NO'),
       h.avgcln,
       c.spare3,
       decode(c.type#, 1, decode(bitand(c.property, 8388608), 0, 'B', 'C'),
                      96, decode(bitand(c.property, 8388608), 0, 'B', 'C'),
                      null),
       decode(bitand(ac.flags, 128), 128, 'YES', 'NO'),
       decode(o.status, 1, decode(bitand(ac.flags, 256), 256, 'NO', 'YES'),
                        decode(bitand(ac.flags, 2), 2, 'NO',
                               decode(bitand(ac.flags, 4), 4, 'NO',
                                      decode(bitand(ac.flags, 8), 8, 'NO',
                                             'N/A')))),
       decode(c.property, 0, 'NO', decode(bitand(c.property, 32), 32, 'YES',
                                          'NO')),
       decode(c.property, 0, 'NO', decode(bitand(c.property, 8), 8, 'YES',
                                          'NO')),
       decode(c.segcol#, 0, to_number(null), c.segcol#), c.intcol#,
       case when nvl(h.row_cnt,0) = 0 then 'NONE'
            when (h.bucket_cnt > 255
                  or
                  (h.bucket_cnt > h.distcnt and h.row_cnt = h.distcnt
                   and h.density*h.bucket_cnt*2 <= 1))
                then 'FREQUENCY'
            else 'HEIGHT BALANCED'
       end,
       decode(bitand(c.property, 1024), 1024,
              (select decode(bitand(cl.property, 1), 1, rc.name, cl.name)
               from sys.col$ cl, attrcol$ rc where cl.intcol# = c.intcol#-1
               and cl.obj# = c.obj# and c.obj# = rc.obj#(+) and
               cl.intcol# = rc.intcol#(+)),
              decode(bitand(c.property, 1), 0, c.name,
                     (select tc.name from sys.attrcol$ tc
                      where c.obj# = tc.obj# and c.intcol# = tc.intcol#)))
from sys.col$ c, sys.obj$ o, sys.hist_head$ h, sys.user$ u,
     sys.coltype$ ac, sys.obj$ ot, sys.user$ ut, sys.tab$ t
where o.obj# = c.obj#
  and o.owner# = u.user#
  and c.obj# = h.obj#(+) and c.intcol# = h.intcol#(+)
  and c.obj# = ac.obj#(+) and c.intcol# = ac.intcol#(+)
  and ac.toid = ot.oid$(+)
  and ot.type#(+) = 13
  and ot.owner# = ut.user#(+)
  and o.obj# = t.obj#
  and bitand(t.property, 8192) = 8192        /* nested tables */
  and (o.owner# = userenv('SCHEMAID')
        or
        o.obj# in ( select obj#
                    from sys.objauth$
                    where grantee# in ( select kzsrorol
                                         from x$kzsro
                                       )
                  )
        or /* user has system privileges */
          exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */)
                  )
       )
/
comment on table ALL_NESTED_TABLE_COLS is
'Columns of nested tables'
/
comment on column ALL_NESTED_TABLE_COLS.TABLE_NAME is
'Nested table name'
/
comment on column ALL_NESTED_TABLE_COLS.COLUMN_NAME is
'Column name'
/
comment on column ALL_NESTED_TABLE_COLS.DATA_LENGTH is
'Length of the column in bytes'
/
comment on column ALL_NESTED_TABLE_COLS.DATA_TYPE is
'Datatype of the column'
/
comment on column ALL_NESTED_TABLE_COLS.DATA_TYPE_MOD is
'Datatype modifier of the column'
/
comment on column ALL_NESTED_TABLE_COLS.DATA_TYPE_OWNER is
'Owner of the datatype of the column'
/
comment on column ALL_NESTED_TABLE_COLS.DATA_PRECISION is
'Length: decimal digits (NUMBER) or binary digits (FLOAT)'
/
comment on column ALL_NESTED_TABLE_COLS.DATA_SCALE is
'Digits to right of decimal point in a number'
/
comment on column ALL_NESTED_TABLE_COLS.NULLABLE is
'Does column allow NULL values?'
/
comment on column ALL_NESTED_TABLE_COLS.COLUMN_ID is
'Sequence number of the column as created'
/
comment on column ALL_NESTED_TABLE_COLS.DEFAULT_LENGTH is
'Length of default value for the column'
/
comment on column ALL_NESTED_TABLE_COLS.DATA_DEFAULT is
'Default value for the column'
/
comment on column ALL_NESTED_TABLE_COLS.NUM_DISTINCT is
'The number of distinct values in the column'
/
comment on column ALL_NESTED_TABLE_COLS.LOW_VALUE is
'The low value in the column'
/
comment on column ALL_NESTED_TABLE_COLS.HIGH_VALUE is
'The high value in the column'
/
comment on column ALL_NESTED_TABLE_COLS.DENSITY is
'The density of the column'
/
comment on column ALL_NESTED_TABLE_COLS.NUM_NULLS is
'The number of nulls in the column'
/
comment on column ALL_NESTED_TABLE_COLS.NUM_BUCKETS is
'The number of buckets in histogram for the column'
/
comment on column ALL_NESTED_TABLE_COLS.LAST_ANALYZED is
'The date of the most recent time this column was analyzed'
/
comment on column ALL_NESTED_TABLE_COLS.SAMPLE_SIZE is
'The sample size used in analyzing this column'
/
comment on column ALL_NESTED_TABLE_COLS.CHARACTER_SET_NAME is
'Character set name'
/
comment on column ALL_NESTED_TABLE_COLS.CHAR_COL_DECL_LENGTH is
'Declaration length of character type column'
/
comment on column ALL_NESTED_TABLE_COLS.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column ALL_NESTED_TABLE_COLS.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column ALL_NESTED_TABLE_COLS.AVG_COL_LEN is
'The average length of the column in bytes'
/
comment on column ALL_NESTED_TABLE_COLS.CHAR_LENGTH is
'The maximum length of the column in characters'
/
comment on column ALL_NESTED_TABLE_COLS.CHAR_USED is
'C if maximum length is specified in characters, B if in bytes'
/
comment on column ALL_NESTED_TABLE_COLS.V80_FMT_IMAGE is
'Is column data in 8.0 image format?'
/
comment on column ALL_NESTED_TABLE_COLS.DATA_UPGRADED is
'Has column data been upgraded to the latest type version format?'
/
comment on column ALL_NESTED_TABLE_COLS.HIDDEN_COLUMN is
'Is this a hidden column?'
/
comment on column ALL_NESTED_TABLE_COLS.VIRTUAL_COLUMN is
'Is this a virtual column?'
/
comment on column ALL_NESTED_TABLE_COLS.SEGMENT_COLUMN_ID is
'Sequence number of the column in the segment'
/
comment on column ALL_NESTED_TABLE_COLS.INTERNAL_COLUMN_ID is
'Internal sequence number of the column'
/
comment on column ALL_NESTED_TABLE_COLS.QUALIFIED_COL_NAME is
'Qualified column name'
/
create or replace public synonym ALL_NESTED_TABLE_COLS for ALL_NESTED_TABLE_COLS
/
grant select on ALL_NESTED_TABLE_COLS to PUBLIC with grant option
/
create or replace view DBA_NESTED_TABLE_COLS
    (OWNER, TABLE_NAME,
     COLUMN_NAME, DATA_TYPE, DATA_TYPE_MOD, DATA_TYPE_OWNER,
     DATA_LENGTH, DATA_PRECISION, DATA_SCALE, NULLABLE, COLUMN_ID,
     DEFAULT_LENGTH, DATA_DEFAULT, NUM_DISTINCT, LOW_VALUE, HIGH_VALUE,
     DENSITY, NUM_NULLS, NUM_BUCKETS, LAST_ANALYZED, SAMPLE_SIZE,
     CHARACTER_SET_NAME, CHAR_COL_DECL_LENGTH,
     GLOBAL_STATS, USER_STATS, AVG_COL_LEN, CHAR_LENGTH, CHAR_USED,
     V80_FMT_IMAGE, DATA_UPGRADED, HIDDEN_COLUMN, VIRTUAL_COLUMN,
     SEGMENT_COLUMN_ID, INTERNAL_COLUMN_ID, HISTOGRAM, QUALIFIED_COL_NAME)
as
select u.name, o.name,
       c.name,
       decode(c.type#, 1, decode(c.charsetform, 2, 'NVARCHAR2', 'VARCHAR2'),
                       2, decode(c.scale, null,
                                 decode(c.precision#, null, 'NUMBER', 'FLOAT'),
                                 'NUMBER'),
                       8, 'LONG',
                       9, decode(c.charsetform, 2, 'NCHAR VARYING', 'VARCHAR'),
                       12, 'DATE',
                       23, 'RAW', 24, 'LONG RAW',
                       58, nvl2(ac.synobj#, (select o.name from obj$ o
                                where o.obj#=ac.synobj#), ot.name),
                       69, 'ROWID',
                       96, decode(c.charsetform, 2, 'NCHAR', 'CHAR'),
                       100, 'BINARY_FLOAT',
                       101, 'BINARY_DOUBLE',
                       105, 'MLSLABEL',
                       106, 'MLSLABEL',
                       111, nvl2(ac.synobj#, (select o.name from obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       112, decode(c.charsetform, 2, 'NCLOB', 'CLOB'),
                       113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
                       121, nvl2(ac.synobj#, (select o.name from obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       122, nvl2(ac.synobj#, (select o.name from obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       123, nvl2(ac.synobj#, (select o.name from obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       178, 'TIME(' ||c.scale|| ')',
                       179, 'TIME(' ||c.scale|| ')' || ' WITH TIME ZONE',
                       180, 'TIMESTAMP(' ||c.scale|| ')',
                       181, 'TIMESTAMP(' ||c.scale|| ')' || ' WITH TIME ZONE',
                       231, 'TIMESTAMP(' ||c.scale|| ')' || ' WITH LOCAL TIME ZONE',
                       182, 'INTERVAL YEAR(' ||c.precision#||') TO MONTH',
                       183, 'INTERVAL DAY(' ||c.precision#||') TO SECOND(' ||
                             c.scale || ')',
                       208, 'UROWID',
                       'UNDEFINED'),
       decode(c.type#, 111, 'REF'),
       nvl2(ac.synobj#, (select u.name from user$ u, obj$ o
            where o.owner#=u.user# and o.obj#=ac.synobj#), ut.name),
       c.length, c.precision#, c.scale,
       decode(sign(c.null$),-1,'D', 0, 'Y', 'N'),
       decode(c.col#, 0, to_number(null), c.col#), c.deflength,
       c.default$, h.distcnt, h.lowval, h.hival, h.density, h.null_cnt,
       case when nvl(h.distcnt,0) = 0 then h.distcnt
            when h.row_cnt = 0 then 1
	    when (h.bucket_cnt > 255
                  or
                  (h.bucket_cnt > h.distcnt
                   and h.row_cnt = h.distcnt
                   and h.density*h.bucket_cnt*2 <= 1))
                then h.row_cnt
            else h.bucket_cnt
       end,
       h.timestamp#, h.sample_size,
       decode(c.charsetform, 1, 'CHAR_CS',
                             2, 'NCHAR_CS',
                             3, NLS_CHARSET_NAME(c.charsetid),
                             4, 'ARG:'||c.charsetid),
       decode(c.charsetid, 0, to_number(NULL),
                           nls_charset_decl_len(c.length, c.charsetid)),
       decode(bitand(h.spare2, 2), 2, 'YES', 'NO'),
       decode(bitand(h.spare2, 1), 1, 'YES', 'NO'),
       h.avgcln,
       c.spare3,
       decode(c.type#, 1, decode(bitand(c.property, 8388608), 0, 'B', 'C'),
                      96, decode(bitand(c.property, 8388608), 0, 'B', 'C'),
                      null),
       decode(bitand(ac.flags, 128), 128, 'YES', 'NO'),
       decode(o.status, 1, decode(bitand(ac.flags, 256), 256, 'NO', 'YES'),
                        decode(bitand(ac.flags, 2), 2, 'NO',
                               decode(bitand(ac.flags, 4), 4, 'NO',
                                      decode(bitand(ac.flags, 8), 8, 'NO',
                                             'N/A')))),
       decode(c.property, 0, 'NO', decode(bitand(c.property, 32), 32, 'YES',
                                          'NO')),
       decode(c.property, 0, 'NO', decode(bitand(c.property, 8), 8, 'YES',
                                          'NO')),
       decode(c.segcol#, 0, to_number(null), c.segcol#), c.intcol#,
       case when nvl(h.row_cnt,0) = 0 then 'NONE'
            when (h.bucket_cnt > 255
                  or
                  (h.bucket_cnt > h.distcnt and h.row_cnt = h.distcnt
                   and h.density*h.bucket_cnt*2 <= 1))
                then 'FREQUENCY'
            else 'HEIGHT BALANCED'
       end,
       decode(bitand(c.property, 1024), 1024,
              (select decode(bitand(cl.property, 1), 1, rc.name, cl.name)
               from sys.col$ cl, attrcol$ rc where cl.intcol# = c.intcol#-1
               and cl.obj# = c.obj# and c.obj# = rc.obj#(+) and
               cl.intcol# = rc.intcol#(+)),
              decode(bitand(c.property, 1), 0, c.name,
                     (select tc.name from sys.attrcol$ tc
                      where c.obj# = tc.obj# and c.intcol# = tc.intcol#)))
from sys.col$ c, sys.obj$ o, sys.hist_head$ h, sys.user$ u,
     sys.coltype$ ac, sys.obj$ ot, sys.user$ ut, sys.tab$ t
where o.obj# = c.obj#
  and o.owner# = u.user#
  and c.obj# = h.obj#(+) and c.intcol# = h.intcol#(+)
  and c.obj# = ac.obj#(+) and c.intcol# = ac.intcol#(+)
  and ac.toid = ot.oid$(+)
  and ot.type#(+) = 13
  and ot.owner# = ut.user#(+)
  and o.obj# = t.obj#
  and bitand(t.property, 8192) = 8192            /* nested tables */
/
comment on table DBA_NESTED_TABLE_COLS is
'Columns of nested tables'
/
comment on column DBA_NESTED_TABLE_COLS.TABLE_NAME is
'Nested table name'
/
comment on column DBA_NESTED_TABLE_COLS.COLUMN_NAME is
'Column name'
/
comment on column DBA_NESTED_TABLE_COLS.DATA_LENGTH is
'Length of the column in bytes'
/
comment on column DBA_NESTED_TABLE_COLS.DATA_TYPE is
'Datatype of the column'
/
comment on column DBA_NESTED_TABLE_COLS.DATA_TYPE_MOD is
'Datatype modifier of the column'
/
comment on column DBA_NESTED_TABLE_COLS.DATA_TYPE_OWNER is
'Owner of the datatype of the column'
/
comment on column DBA_NESTED_TABLE_COLS.DATA_PRECISION is
'Length: decimal digits (NUMBER) or binary digits (FLOAT)'
/
comment on column DBA_NESTED_TABLE_COLS.DATA_SCALE is
'Digits to right of decimal point in a number'
/
comment on column DBA_NESTED_TABLE_COLS.NULLABLE is
'Does column allow NULL values?'
/
comment on column DBA_NESTED_TABLE_COLS.COLUMN_ID is
'Sequence number of the column as created'
/
comment on column DBA_NESTED_TABLE_COLS.DEFAULT_LENGTH is
'Length of default value for the column'
/
comment on column DBA_NESTED_TABLE_COLS.DATA_DEFAULT is
'Default value for the column'
/
comment on column DBA_NESTED_TABLE_COLS.NUM_DISTINCT is
'The number of distinct values in the column'
/
comment on column DBA_NESTED_TABLE_COLS.LOW_VALUE is
'The low value in the column'
/
comment on column DBA_NESTED_TABLE_COLS.HIGH_VALUE is
'The high value in the column'
/
comment on column DBA_NESTED_TABLE_COLS.DENSITY is
'The density of the column'
/
comment on column DBA_NESTED_TABLE_COLS.NUM_NULLS is
'The number of nulls in the column'
/
comment on column DBA_NESTED_TABLE_COLS.NUM_BUCKETS is
'The number of buckets in histogram for the column'
/
comment on column DBA_NESTED_TABLE_COLS.LAST_ANALYZED is
'The date of the most recent time this column was analyzed'
/
comment on column DBA_NESTED_TABLE_COLS.SAMPLE_SIZE is
'The sample size used in analyzing this column'
/
comment on column DBA_NESTED_TABLE_COLS.CHARACTER_SET_NAME is
'Character set name'
/
comment on column DBA_NESTED_TABLE_COLS.CHAR_COL_DECL_LENGTH is
'Declaration length of character type column'
/
comment on column DBA_NESTED_TABLE_COLS.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column DBA_NESTED_TABLE_COLS.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column DBA_NESTED_TABLE_COLS.AVG_COL_LEN is
'The average length of the column in bytes'
/
comment on column DBA_NESTED_TABLE_COLS.CHAR_LENGTH is
'The maximum length of the column in characters'
/
comment on column DBA_NESTED_TABLE_COLS.CHAR_USED is
'C if the width was specified in characters, B if in bytes'
/
comment on column DBA_NESTED_TABLE_COLS.V80_FMT_IMAGE is
'Is column data in 8.0 image format?'
/
comment on column DBA_NESTED_TABLE_COLS.DATA_UPGRADED is
'Has column data been upgraded to the latest type version format?'
/
comment on column DBA_NESTED_TABLE_COLS.HIDDEN_COLUMN is
'Is this a hidden column?'
/
comment on column DBA_NESTED_TABLE_COLS.VIRTUAL_COLUMN is
'Is this a virtual column?'
/
comment on column DBA_NESTED_TABLE_COLS.SEGMENT_COLUMN_ID is
'Sequence number of the column in the segment'
/
comment on column DBA_NESTED_TABLE_COLS.INTERNAL_COLUMN_ID is
'Internal sequence number of the column'
/
comment on column DBA_NESTED_TABLE_COLS.QUALIFIED_COL_NAME is
'Qualified column name'
/
create or replace public synonym DBA_NESTED_TABLE_COLS for DBA_NESTED_TABLE_COLS
/
grant select on DBA_NESTED_TABLE_COLS to select_catalog_role
/
remark
remark FAMILY "TAB_COL_STATISTICS"
remark This family of views contains column statistics and histogram
remark information for table columns.
remark
create or replace view USER_TAB_COL_STATISTICS
    (TABLE_NAME, COLUMN_NAME, NUM_DISTINCT, LOW_VALUE, HIGH_VALUE,
     DENSITY, NUM_NULLS, NUM_BUCKETS, LAST_ANALYZED, SAMPLE_SIZE,
     GLOBAL_STATS, USER_STATS, AVG_COL_LEN, HISTOGRAM)
as
select table_name, column_name, num_distinct, low_value, high_value,
       density, num_nulls, num_buckets, last_analyzed, sample_size,
       global_stats, user_stats, avg_col_len, HISTOGRAM
from user_tab_columns
where last_analyzed is not null
union all
select /* fixed table column stats */
       ft.kqftanam, c.kqfconam,
       h.distcnt, h.lowval, h.hival,
       h.density, h.null_cnt,
       case when nvl(h.distcnt,0) = 0 then h.distcnt
            when h.row_cnt = 0 then 1
	    when (h.bucket_cnt > 255
                  or
                  (h.bucket_cnt > h.distcnt
                   and h.row_cnt = h.distcnt
                   and h.density*h.bucket_cnt*2 <= 1))
                then h.row_cnt
            else h.bucket_cnt
       end,
       h.timestamp#, h.sample_size,
       decode(bitand(h.spare2, 2), 2, 'YES', 'NO'),
       decode(bitand(h.spare2, 1), 1, 'YES', 'NO'),
       h.avgcln,
       case when nvl(h.row_cnt,0) = 0 then 'NONE'
            when (h.bucket_cnt > 255
                  or
                  (h.bucket_cnt > h.distcnt and h.row_cnt = h.distcnt
                   and h.density*h.bucket_cnt*2 <= 1))
                then 'FREQUENCY'
            else 'HEIGHT BALANCED'
       end
from   sys.x$kqfta ft, sys.fixed_obj$ fobj,
         sys.x$kqfco c, sys.hist_head$ h
where
       ft.kqftaobj = fobj. obj#
       and c.kqfcotob = ft.kqftaobj
       and h.obj# = ft.kqftaobj
       and h.intcol# = c.kqfcocno
       /*
        * if fobj and st are not in sync (happens when db open read only
        * after upgrade), do not display stats.
        */
       and ft.kqftaver =
             fobj.timestamp - to_date('01-01-1991', 'DD-MM-YYYY')
       and h.timestamp# is not null
       and userenv('SCHEMAID') = 0  /* SYS */
/
comment on table USER_TAB_COL_STATISTICS is
'Columns of user''s tables, views and clusters'
/
comment on column USER_TAB_COL_STATISTICS.TABLE_NAME is
'Table, view or cluster name'
/
comment on column USER_TAB_COL_STATISTICS.COLUMN_NAME is
'Column name'
/
comment on column USER_TAB_COL_STATISTICS.NUM_DISTINCT is
'The number of distinct values in the column'
/
comment on column USER_TAB_COL_STATISTICS.LOW_VALUE is
'The low value in the column'
/
comment on column USER_TAB_COL_STATISTICS.HIGH_VALUE is
'The high value in the column'
/
comment on column USER_TAB_COL_STATISTICS.DENSITY is
'The density of the column'
/
comment on column USER_TAB_COL_STATISTICS.NUM_NULLS is
'The number of nulls in the column'
/
comment on column USER_TAB_COL_STATISTICS.NUM_BUCKETS is
'The number of buckets in histogram for the column'
/
comment on column USER_TAB_COL_STATISTICS.LAST_ANALYZED is
'The date of the most recent time this column was analyzed'
/
comment on column USER_TAB_COL_STATISTICS.SAMPLE_SIZE is
'The sample size used in analyzing this column'
/
comment on column USER_TAB_COL_STATISTICS.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column USER_TAB_COL_STATISTICS.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column USER_TAB_COL_STATISTICS.AVG_COL_LEN is
'The average length of the column in bytes'
/
create or replace public synonym USER_TAB_COL_STATISTICS for USER_TAB_COL_STATISTICS
/
grant select on USER_TAB_COL_STATISTICS to PUBLIC with grant option
/
create or replace view ALL_TAB_COL_STATISTICS
    (OWNER, TABLE_NAME, COLUMN_NAME, NUM_DISTINCT, LOW_VALUE, HIGH_VALUE,
     DENSITY, NUM_NULLS, NUM_BUCKETS, LAST_ANALYZED, SAMPLE_SIZE,
     GLOBAL_STATS, USER_STATS, AVG_COL_LEN, HISTOGRAM)
as
select owner, table_name, column_name, num_distinct, low_value, high_value,
       density, num_nulls, num_buckets, last_analyzed, sample_size,
       global_stats, user_stats, avg_col_len, HISTOGRAM
from all_tab_columns
where last_analyzed is not null
union all
select /* fixed table column stats */
       'SYS', ft.kqftanam, c.kqfconam,
       h.distcnt, h.lowval, h.hival,
       h.density, h.null_cnt,
       case when nvl(h.distcnt,0) = 0 then h.distcnt
            when h.row_cnt = 0 then 1
	    when (h.bucket_cnt > 255
                  or
                  (h.bucket_cnt > h.distcnt
                   and h.row_cnt = h.distcnt
                   and h.density*h.bucket_cnt*2 <= 1))
                then h.row_cnt
            else h.bucket_cnt
       end,
       h.timestamp#, h.sample_size,
       decode(bitand(h.spare2, 2), 2, 'YES', 'NO'),
       decode(bitand(h.spare2, 1), 1, 'YES', 'NO'),
       h.avgcln,
       case when nvl(h.row_cnt,0) = 0 then 'NONE'
            when (h.bucket_cnt > 255
                  or
                  (h.bucket_cnt > h.distcnt and h.row_cnt = h.distcnt
                   and h.density*h.bucket_cnt*2 <= 1))
                then 'FREQUENCY'
            else 'HEIGHT BALANCED'
       end
from   sys.x$kqfta ft, sys.fixed_obj$ fobj,
         sys.x$kqfco c, sys.hist_head$ h
where
       ft.kqftaobj = fobj. obj#
       and c.kqfcotob = ft.kqftaobj
       and h.obj# = ft.kqftaobj
       and h.intcol# = c.kqfcocno
       /*
        * if fobj and st are not in sync (happens when db open read only
        * after upgrade), do not display stats.
        */
       and ft.kqftaver =
             fobj.timestamp - to_date('01-01-1991', 'DD-MM-YYYY')
       and h.timestamp# is not null
       and (userenv('SCHEMAID') = 0  /* SYS */
            or /* user has system privileges */
            exists (select null from v$enabledprivs
                    where priv_number in (-237 /* SELECT ANY DICTIONARY */)
                   )
           )
/
comment on table ALL_TAB_COL_STATISTICS is
'Columns of user''s tables, views and clusters'
/
comment on column ALL_TAB_COL_STATISTICS.OWNER is
'Table, view or cluster owner'
/
comment on column ALL_TAB_COL_STATISTICS.TABLE_NAME is
'Table, view or cluster name'
/
comment on column ALL_TAB_COL_STATISTICS.COLUMN_NAME is
'Column name'
/
comment on column ALL_TAB_COL_STATISTICS.NUM_DISTINCT is
'The number of distinct values in the column'
/
comment on column ALL_TAB_COL_STATISTICS.LOW_VALUE is
'The low value in the column'
/
comment on column ALL_TAB_COL_STATISTICS.HIGH_VALUE is
'The high value in the column'
/
comment on column ALL_TAB_COL_STATISTICS.DENSITY is
'The density of the column'
/
comment on column ALL_TAB_COL_STATISTICS.NUM_NULLS is
'The number of nulls in the column'
/
comment on column ALL_TAB_COL_STATISTICS.NUM_BUCKETS is
'The number of buckets in histogram for the column'
/
comment on column ALL_TAB_COL_STATISTICS.LAST_ANALYZED is
'The date of the most recent time this column was analyzed'
/
comment on column ALL_TAB_COL_STATISTICS.SAMPLE_SIZE is
'The sample size used in analyzing this column'
/
comment on column ALL_TAB_COL_STATISTICS.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column ALL_TAB_COL_STATISTICS.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column ALL_TAB_COL_STATISTICS.AVG_COL_LEN is
'The average length of the column in bytes'
/
create or replace public synonym ALL_TAB_COL_STATISTICS for ALL_TAB_COL_STATISTICS
/
grant select on ALL_TAB_COL_STATISTICS to PUBLIC with grant option
/
create or replace view DBA_TAB_COL_STATISTICS
    (OWNER, TABLE_NAME, COLUMN_NAME, NUM_DISTINCT, LOW_VALUE, HIGH_VALUE,
     DENSITY, NUM_NULLS, NUM_BUCKETS, LAST_ANALYZED, SAMPLE_SIZE,
     GLOBAL_STATS, USER_STATS, AVG_COL_LEN, HISTOGRAM)
as
select owner, table_name, column_name, num_distinct, low_value, high_value,
       density, num_nulls, num_buckets, last_analyzed, sample_size,
       global_stats, user_stats, avg_col_len, HISTOGRAM
from dba_tab_columns
where last_analyzed is not null
union all
select /* fixed table column stats */
       'SYS', ft.kqftanam, c.kqfconam,
       h.distcnt, h.lowval, h.hival,
       h.density, h.null_cnt,
       case when nvl(h.distcnt,0) = 0 then h.distcnt
            when h.row_cnt = 0 then 1
	    when (h.bucket_cnt > 255
                  or
                  (h.bucket_cnt > h.distcnt
                   and h.row_cnt = h.distcnt
                   and h.density*h.bucket_cnt*2 <= 1))
                then h.row_cnt
            else h.bucket_cnt
       end,
       h.timestamp#, h.sample_size,
       decode(bitand(h.spare2, 2), 2, 'YES', 'NO'),
       decode(bitand(h.spare2, 1), 1, 'YES', 'NO'),
       h.avgcln,
       case when nvl(h.row_cnt,0) = 0 then 'NONE'
            when (h.bucket_cnt > 255
                  or
                  (h.bucket_cnt > h.distcnt and h.row_cnt = h.distcnt
                   and h.density*h.bucket_cnt*2 <= 1))
                then 'FREQUENCY'
            else 'HEIGHT BALANCED'
       end
from   sys.x$kqfta ft, sys.fixed_obj$ fobj,
         sys.x$kqfco c, sys.hist_head$ h
where
       ft.kqftaobj = fobj. obj#
       and c.kqfcotob = ft.kqftaobj
       and h.obj# = ft.kqftaobj
       and h.intcol# = c.kqfcocno
       /*
        * if fobj and st are not in sync (happens when db open read only
        * after upgrade), do not display stats.
        */
       and ft.kqftaver =
             fobj.timestamp - to_date('01-01-1991', 'DD-MM-YYYY')
       and h.timestamp# is not null
/
comment on table DBA_TAB_COL_STATISTICS is
'Columns of user''s tables, views and clusters'
/
comment on column DBA_TAB_COL_STATISTICS.OWNER is
'Table, view or cluster owner'
/
comment on column DBA_TAB_COL_STATISTICS.TABLE_NAME is
'Table, view or cluster name'
/
comment on column DBA_TAB_COL_STATISTICS.COLUMN_NAME is
'Column name'
/
comment on column DBA_TAB_COL_STATISTICS.NUM_DISTINCT is
'The number of distinct values in the column'
/
comment on column DBA_TAB_COL_STATISTICS.LOW_VALUE is
'The low value in the column'
/
comment on column DBA_TAB_COL_STATISTICS.HIGH_VALUE is
'The high value in the column'
/
comment on column DBA_TAB_COL_STATISTICS.DENSITY is
'The density of the column'
/
comment on column DBA_TAB_COL_STATISTICS.NUM_NULLS is
'The number of nulls in the column'
/
comment on column DBA_TAB_COL_STATISTICS.NUM_BUCKETS is
'The number of buckets in histogram for the column'
/
comment on column DBA_TAB_COL_STATISTICS.LAST_ANALYZED is
'The date of the most recent time this column was analyzed'
/
comment on column DBA_TAB_COL_STATISTICS.SAMPLE_SIZE is
'The sample size used in analyzing this column'
/
comment on column DBA_TAB_COL_STATISTICS.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column DBA_TAB_COL_STATISTICS.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column DBA_TAB_COL_STATISTICS.AVG_COL_LEN is
'The average length of the column in bytes'
/
create or replace public synonym DBA_TAB_COL_STATISTICS for DBA_TAB_COL_STATISTICS
/
grant select on DBA_TAB_COL_STATISTICS to select_catalog_role
/
remark
remark  FAMILY "TAB_HISTOGRAMS"
remark  The histograms (part of the statistics used by the cost-based
remark    optimizer) on columns.
remark  The TAB_COL_STATISTICS contain general information about
remark    each histogram, including the number of buckets.
remark  These views contains that actual histogram data.
remark
create or replace view USER_TAB_HISTOGRAMS
    (TABLE_NAME, COLUMN_NAME, ENDPOINT_NUMBER, ENDPOINT_VALUE,
     ENDPOINT_ACTUAL_VALUE)
as
select /*+ ordered */ o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       h.bucket,
       h.endpoint,
       h.epvalue
from sys.obj$ o, sys.col$ c, sys.histgrm$ h, sys.attrcol$ a
where o.obj# = c.obj#
  and o.owner# = userenv('SCHEMAID')
  and c.obj# = h.obj# and c.intcol# = h.intcol#
  and (o.type# in (3, 4)                                     /* cluster, view */
       or
       (o.type# = 2     /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192))))
  and c.obj# = a.obj#(+)
  and c.intcol# = a.intcol#(+)
union all
select /*+ ordered */ o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       0,
       h.minimum,
       null
from sys.obj$ o, sys.col$ c, sys.hist_head$ h, sys.attrcol$ a
where o.obj# = c.obj#
  and o.owner# = userenv('SCHEMAID')
  and c.obj# = h.obj# and c.intcol# = h.intcol#
  and (o.type# in (3, 4)                                     /* cluster, view */
       or
       (o.type# = 2     /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192))))
  and h.row_cnt = 0 and h.distcnt > 0
  and c.obj# = a.obj#(+)
  and c.intcol# = a.intcol#(+)
union all
select /*+ ordered */ o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       1,
       h.maximum,
       null
from sys.obj$ o, sys.col$ c, sys.hist_head$ h, sys.attrcol$ a
where o.obj# = c.obj#
  and o.owner# = userenv('SCHEMAID')
  and c.obj# = h.obj# and c.intcol# = h.intcol#
  and (o.type# in (3, 4)                                     /* cluster, view */
       or
       (o.type# = 2     /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192))))
  and h.row_cnt = 0 and h.distcnt > 0
  and c.obj# = a.obj#(+)
  and c.intcol# = a.intcol#(+)
union all
select /*+ ordered */
       ft.kqftanam,
       c.kqfconam,
       h.bucket,
       h.endpoint,
       h.epvalue
from   sys.x$kqfta ft, sys.fixed_obj$ fobj, sys.x$kqfco c, sys.histgrm$ h
where  ft.kqftaobj = fobj. obj#
  and c.kqfcotob = ft.kqftaobj
  and h.obj# = ft.kqftaobj
  and h.intcol# = c.kqfcocno
  /*
   * if fobj and st are not in sync (happens when db open read only
   * after upgrade), do not display stats.
   */
  and ft.kqftaver =
         fobj.timestamp - to_date('01-01-1991', 'DD-MM-YYYY')
  and userenv('SCHEMAID') = 0  /* SYS */
/
comment on table USER_TAB_HISTOGRAMS is
'Histograms on columns of user''s tables'
/
comment on column USER_TAB_HISTOGRAMS.TABLE_NAME is
'Table name'
/
comment on column USER_TAB_HISTOGRAMS.COLUMN_NAME is
'Column name or attribute of object column'
/
comment on column USER_TAB_HISTOGRAMS.ENDPOINT_NUMBER is
'Endpoint number'
/
comment on column USER_TAB_HISTOGRAMS.ENDPOINT_VALUE is
'Normalized endpoint value'
/
comment on column USER_TAB_HISTOGRAMS.ENDPOINT_ACTUAL_VALUE is
'Actual endpoint value'
/
create or replace public synonym USER_TAB_HISTOGRAMS for USER_TAB_HISTOGRAMS
/
grant select on USER_TAB_HISTOGRAMS to PUBLIC with grant option
/
rem For backwark compatibility with ORACLE7's catalog
create or replace public synonym USER_HISTOGRAMS for USER_TAB_HISTOGRAMS
/
create or replace view ALL_TAB_HISTOGRAMS
    (OWNER, TABLE_NAME, COLUMN_NAME, ENDPOINT_NUMBER, ENDPOINT_VALUE,
     ENDPOINT_ACTUAL_VALUE)
as
select /*+ ordered */ u.name,
       o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       h.bucket,
       h.endpoint,
       h.epvalue
from sys.user$ u, sys.obj$ o, sys.col$ c, sys.histgrm$ h, sys.attrcol$ a
where o.obj# = c.obj#
  and (o.owner# = userenv('SCHEMAID')
        or
        o.obj# in ( select obj#
                    from sys.objauth$
                    where grantee# in ( select kzsrorol
                                         from x$kzsro
                                       )
                  )
        or /* user has system privileges */
          exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */)
                  )
       )
  and o.owner# = u.user#
  and c.obj# = h.obj# and c.intcol# = h.intcol#
  and (o.type# in (3, 4)                                     /* cluster, view */
       or
       (o.type# = 2     /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192))))
  and c.obj# = a.obj#(+)
  and c.intcol# = a.intcol#(+)
union all
select /*+ ordered */ u.name,
       o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       0,
       h.minimum,
       null
from sys.user$ u, sys.obj$ o, sys.col$ c, sys.hist_head$ h, sys.attrcol$ a
where o.obj# = c.obj#
  and (o.owner# = userenv('SCHEMAID')
        or
        o.obj# in ( select obj#
                    from sys.objauth$
                    where grantee# in ( select kzsrorol
                                         from x$kzsro
                                       )
                  )
        or /* user has system privileges */
          exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */)
                  )
       )
  and o.owner# = u.user#
  and c.obj# = h.obj# and c.intcol# = h.intcol#
  and (o.type# in (3, 4)                                     /* cluster, view */
       or
       (o.type# = 2     /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192))))
  and h.row_cnt = 0 and h.distcnt > 0
  and c.obj# = a.obj#(+)
  and c.intcol# = a.intcol#(+)
union all
select /*+ ordered */ u.name,
       o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       1,
       h.maximum,
       null
from sys.user$ u, sys.obj$ o, sys.col$ c, sys.hist_head$ h, sys.attrcol$ a
where o.obj# = c.obj#
  and (o.owner# = userenv('SCHEMAID')
        or
        o.obj# in ( select obj#
                    from sys.objauth$
                    where grantee# in ( select kzsrorol
                                         from x$kzsro
                                       )
                  )
        or /* user has system privileges */
          exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */)
                  )
       )
  and o.owner# = u.user#
  and c.obj# = h.obj# and c.intcol# = h.intcol#
  and (o.type# in (3, 4)                                     /* cluster, view */
       or
       (o.type# = 2     /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192))))
  and h.row_cnt = 0 and h.distcnt > 0
  and c.obj# = a.obj#(+)
  and c.intcol# = a.intcol#(+)
union all
select /*+ ordered */
       'SYS',
       ft.kqftanam,
       c.kqfconam,
       h.bucket,
       h.endpoint,
       h.epvalue
from   sys.x$kqfta ft, sys.fixed_obj$ fobj, sys.x$kqfco c, sys.histgrm$ h
where  ft.kqftaobj = fobj. obj#
  and c.kqfcotob = ft.kqftaobj
  and h.obj# = ft.kqftaobj
  and h.intcol# = c.kqfcocno
  /*
   * if fobj and st are not in sync (happens when db open read only
   * after upgrade), do not display stats.
   */
  and ft.kqftaver =
         fobj.timestamp - to_date('01-01-1991', 'DD-MM-YYYY')
  and (userenv('SCHEMAID') = 0  /* SYS */
       or /* user has system privileges */
       exists (select null from v$enabledprivs
               where priv_number in (-237 /* SELECT ANY DICTIONARY */)
              )
      )
/
comment on table ALL_TAB_HISTOGRAMS is
'Histograms on columns of all tables visible to user'
/
comment on column ALL_TAB_HISTOGRAMS.OWNER is
'Owner of table'
/
comment on column ALL_TAB_HISTOGRAMS.TABLE_NAME is
'Table name'
/
comment on column ALL_TAB_HISTOGRAMS.COLUMN_NAME is
'Column name or attribute of object column'
/
comment on column ALL_TAB_HISTOGRAMS.ENDPOINT_NUMBER is
'Endpoint number'
/
comment on column ALL_TAB_HISTOGRAMS.ENDPOINT_VALUE is
'Normalized endpoint value'
/
comment on column ALL_TAB_HISTOGRAMS.ENDPOINT_ACTUAL_VALUE is
'Actual endpoint value'
/
create or replace public synonym ALL_TAB_HISTOGRAMS for ALL_TAB_HISTOGRAMS
/
grant select on ALL_TAB_HISTOGRAMS to PUBLIC with grant option
/
rem For backwark compatibility with ORACLE7's catalog
create or replace public synonym ALL_HISTOGRAMS for ALL_TAB_HISTOGRAMS
/
create or replace view DBA_TAB_HISTOGRAMS
    (OWNER, TABLE_NAME, COLUMN_NAME, ENDPOINT_NUMBER, ENDPOINT_VALUE,
     ENDPOINT_ACTUAL_VALUE)
as
select /*+ ordered */ u.name,
       o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       h.bucket,
       h.endpoint,
       h.epvalue
from sys.user$ u, sys.obj$ o, sys.col$ c, sys.histgrm$ h, sys.attrcol$ a
where o.obj# = c.obj#
  and o.owner# = u.user#
  and c.obj# = h.obj# and c.intcol# = h.intcol#
  and (o.type# in (3, 4)                                     /* cluster, view */
       or
       (o.type# = 2     /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192))))
  and c.obj# = a.obj#(+)
  and c.intcol# = a.intcol#(+)
union all
select /*+ ordered */ u.name,
       o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       0,
       h.minimum,
       null
from sys.user$ u, sys.obj$ o, sys.col$ c, sys.hist_head$ h, sys.attrcol$ a
where o.obj# = c.obj#
  and o.owner# = u.user#
  and c.obj# = h.obj# and c.intcol# = h.intcol#
  and (o.type# in (3, 4)                                     /* cluster, view */
       or
       (o.type# = 2     /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192))))
  and h.row_cnt = 0 and h.distcnt > 0
  and c.obj# = a.obj#(+)
  and c.intcol# = a.intcol#(+)
union all
select /*+ ordered */ u.name,
       o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       1,
       h.maximum,
       null
from sys.user$ u, sys.obj$ o, sys.col$ c, sys.hist_head$ h, sys.attrcol$ a
where o.obj# = c.obj#
  and o.owner# = u.user#
  and c.obj# = h.obj# and c.intcol# = h.intcol#
  and (o.type# in (3, 4)                                     /* cluster, view */
       or
       (o.type# = 2     /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192))))
  and h.row_cnt = 0 and h.distcnt > 0
  and c.obj# = a.obj#(+)
  and c.intcol# = a.intcol#(+)
union all
select /*+ ordered */
       'SYS',
       ft.kqftanam,
       c.kqfconam,
       h.bucket,
       h.endpoint,
       h.epvalue
from   sys.x$kqfta ft, sys.fixed_obj$ fobj, sys.x$kqfco c, sys.histgrm$ h
where  ft.kqftaobj = fobj. obj#
  and c.kqfcotob = ft.kqftaobj
  and h.obj# = ft.kqftaobj
  and h.intcol# = c.kqfcocno
  /*
   * if fobj and st are not in sync (happens when db open read only
   * after upgrade), do not display stats.
   */
  and ft.kqftaver =
         fobj.timestamp - to_date('01-01-1991', 'DD-MM-YYYY')
/
comment on table DBA_TAB_HISTOGRAMS is
'Histograms on columns of all tables'
/
comment on column DBA_TAB_HISTOGRAMS.OWNER is
'Owner of table'
/
comment on column DBA_TAB_HISTOGRAMS.TABLE_NAME is
'Table name'
/
comment on column DBA_TAB_HISTOGRAMS.COLUMN_NAME is
'Column name or attribute of object column'
/
comment on column DBA_TAB_HISTOGRAMS.ENDPOINT_NUMBER is
'Endpoint number'
/
comment on column DBA_TAB_HISTOGRAMS.ENDPOINT_VALUE is
'Normalized endpoint value'
/
comment on column DBA_TAB_HISTOGRAMS.ENDPOINT_ACTUAL_VALUE is
'Actual endpoint value'
/
create or replace public synonym DBA_TAB_HISTOGRAMS for DBA_TAB_HISTOGRAMS
/
grant select on DBA_TAB_HISTOGRAMS to select_catalog_role
/
rem For backwark compatibility with ORACLE7's catalog
create or replace public synonym DBA_HISTOGRAMS for DBA_TAB_HISTOGRAMS
/
remark
remark  FAMILY "TAB_COMMENTS"
remark  Comments on objects.
remark
create or replace view USER_TAB_COMMENTS
    (TABLE_NAME,
     TABLE_TYPE,
     COMMENTS)
as
select o.name,
       decode(o.type#, 0, 'NEXT OBJECT', 1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER',
                      4, 'VIEW', 5, 'SYNONYM', 'UNDEFINED'),
       c.comment$
from sys.obj$ o, sys.com$ c
where o.owner# = userenv('SCHEMAID')
  and (o.type# in (4)                                                /* view */
       or
       (o.type# = 2                                                /* tables */
        AND         /* excluding iot-overflow, nested or mv container tables */
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192 OR
                            bitand(t.property, 67108864) = 67108864))))
  and o.obj# = c.obj#(+)
  and c.col#(+) is null
/
comment on table USER_TAB_COMMENTS is
'Comments on the tables and views owned by the user'
/
comment on column USER_TAB_COMMENTS.TABLE_NAME is
'Name of the object'
/
comment on column USER_TAB_COMMENTS.TABLE_TYPE is
'Type of the object:  "TABLE" or "VIEW"'
/
comment on column USER_TAB_COMMENTS.COMMENTS is
'Comment on the object'
/
create or replace public synonym USER_TAB_COMMENTS for USER_TAB_COMMENTS
/
grant select on USER_TAB_COMMENTS to PUBLIC with grant option
/
create or replace view ALL_TAB_COMMENTS
    (OWNER, TABLE_NAME,
     TABLE_TYPE,
     COMMENTS)
as
select u.name, o.name,
       decode(o.type#, 0, 'NEXT OBJECT', 1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER',
                      4, 'VIEW', 5, 'SYNONYM', 'UNDEFINED'),
       c.comment$
from sys.obj$ o, sys.user$ u, sys.com$ c
where o.owner# = u.user#
  and o.obj# = c.obj#(+)
  and c.col#(+) is null
  and (o.type# in (4)                                                /* view */
       or
       (o.type# = 2                                                /* tables */
        AND         /* excluding iot-overflow, nested or mv container tables */
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192 OR
                            bitand(t.property, 67108864) = 67108864))))
  and (o.owner# = userenv('SCHEMAID')
        or
        o.obj# in ( select obj#
                    from sys.objauth$
                    where grantee# in ( select kzsrorol
                                         from x$kzsro
                                       )
                  )
        or /* user has system privileges */
          exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */)
                  )
       )
/
comment on table ALL_TAB_COMMENTS is
'Comments on tables and views accessible to the user'
/
comment on column ALL_TAB_COMMENTS.OWNER is
'Owner of the object'
/
comment on column ALL_TAB_COMMENTS.TABLE_NAME is
'Name of the object'
/
comment on column ALL_TAB_COMMENTS.TABLE_TYPE is
'Type of the object'
/
comment on column ALL_TAB_COMMENTS.COMMENTS is
'Comment on the object'
/
create or replace public synonym ALL_TAB_COMMENTS for ALL_TAB_COMMENTS
/
grant select on ALL_TAB_COMMENTS to PUBLIC with grant option
/
create or replace view DBA_TAB_COMMENTS
    (OWNER, TABLE_NAME,
     TABLE_TYPE,
     COMMENTS)
as
select u.name, o.name,
       decode(o.type#, 0, 'NEXT OBJECT', 1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER',
                      4, 'VIEW', 5, 'SYNONYM', 'UNDEFINED'),
       c.comment$
from sys.obj$ o, sys.user$ u, sys.com$ c
where o.owner# = u.user#
  and (o.type# in (4)                                                /* view */
       or
       (o.type# = 2                                                /* tables */
        AND         /* excluding iot-overflow, nested or mv container tables */
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192 OR
                            bitand(t.property, 67108864) = 67108864))))
  and o.obj# = c.obj#(+)
  and c.col#(+) is null
/
create or replace public synonym DBA_TAB_COMMENTS for DBA_TAB_COMMENTS
/
grant select on DBA_TAB_COMMENTS to select_catalog_role
/
comment on table DBA_TAB_COMMENTS is
'Comments on all tables and views in the database'
/
comment on column DBA_TAB_COMMENTS.OWNER is
'Owner of the object'
/
comment on column DBA_TAB_COMMENTS.TABLE_NAME is
'Name of the object'
/
comment on column DBA_TAB_COMMENTS.TABLE_TYPE is
'Type of the object'
/
comment on column DBA_TAB_COMMENTS.COMMENTS is
'Comment on the object'
/
remark
remark  FAMILY "TAB_PRIVS"
remark  Grants on objects.
remark
create or replace view USER_TAB_PRIVS
      (GRANTEE, OWNER, TABLE_NAME, GRANTOR, PRIVILEGE, GRANTABLE, HIERARCHY)
as
select ue.name, u.name, o.name, ur.name, tpm.name,
       decode(mod(oa.option$,2), 1, 'YES', 'NO'),
       decode(bitand(oa.option$,2), 2, 'YES', 'NO')
from sys.objauth$ oa, sys.obj$ o, sys.user$ u, sys.user$ ur, sys.user$ ue,
     table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and oa.col# is null
  and u.user# = o.owner#
  and oa.privilege# = tpm.privilege
  and userenv('SCHEMAID') in (oa.grantor#, oa.grantee#, o.owner#)
/
comment on table USER_TAB_PRIVS is
'Grants on objects for which the user is the owner, grantor or grantee'
/
comment on column USER_TAB_PRIVS.GRANTEE is
'Name of the user to whom access was granted'
/
comment on column USER_TAB_PRIVS.OWNER is
'Owner of the object'
/
comment on column USER_TAB_PRIVS.TABLE_NAME is
'Name of the object'
/
comment on column USER_TAB_PRIVS.GRANTOR is
'Name of the user who performed the grant'
/
comment on column USER_TAB_PRIVS.PRIVILEGE is
'Table Privilege'
/
comment on column USER_TAB_PRIVS.GRANTABLE is
'Privilege is grantable'
/
comment on column USER_TAB_PRIVS.HIERARCHY is
'Privilege is with hierarchy option'
/
create or replace public synonym USER_TAB_PRIVS for USER_TAB_PRIVS
/
grant select on USER_TAB_PRIVS to PUBLIC with grant option
/
create or replace view ALL_TAB_PRIVS
      (GRANTOR, GRANTEE, TABLE_SCHEMA, TABLE_NAME, PRIVILEGE, GRANTABLE,
       HIERARCHY)
as
select ur.name, ue.name, u.name, o.name, tpm.name,
       decode(mod(oa.option$,2), 1, 'YES', 'NO'),
       decode(bitand(oa.option$,2), 2, 'YES', 'NO')
from sys.objauth$ oa, sys.obj$ o, sys.user$ u, sys.user$ ur, sys.user$ ue,
     table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and oa.col# is null
  and u.user# = o.owner#
  and oa.privilege# = tpm.privilege
  and (oa.grantor# = userenv('SCHEMAID') or
       oa.grantee# in (select kzsrorol from x$kzsro) or
       o.owner# = userenv('SCHEMAID'))
/
comment on table ALL_TAB_PRIVS is
'Grants on objects for which the user is the grantor, grantee, owner,
 or an enabled role or PUBLIC is the grantee'
/
comment on column ALL_TAB_PRIVS.GRANTOR is
'Name of the user who performed the grant'
/
comment on column ALL_TAB_PRIVS.GRANTEE is
'Name of the user to whom access was granted'
/
comment on column ALL_TAB_PRIVS.TABLE_SCHEMA is
'Schema of the object'
/
comment on column ALL_TAB_PRIVS.TABLE_NAME is
'Name of the object'
/
comment on column ALL_TAB_PRIVS.PRIVILEGE is
'Table Privilege'
/
comment on column ALL_TAB_PRIVS.GRANTABLE is
'Privilege is grantable'
/
comment on column ALL_TAB_PRIVS.HIERARCHY is
'Privilege is with hierarchy option'
/
create or replace public synonym ALL_TAB_PRIVS for ALL_TAB_PRIVS
/
grant select on ALL_TAB_PRIVS to PUBLIC with grant option
/
create or replace view DBA_TAB_PRIVS
      (GRANTEE, OWNER, TABLE_NAME, GRANTOR, PRIVILEGE, GRANTABLE, HIERARCHY)
as
select ue.name, u.name, o.name, ur.name, tpm.name,
       decode(mod(oa.option$,2), 1, 'YES', 'NO'),
       decode(bitand(oa.option$,2), 2, 'YES', 'NO')
from sys.objauth$ oa, sys.obj$ o, sys.user$ u, sys.user$ ur, sys.user$ ue,
     table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and oa.col# is null
  and oa.privilege# = tpm.privilege
  and u.user# = o.owner#
/
create or replace public synonym DBA_TAB_PRIVS for DBA_TAB_PRIVS
/
grant select on DBA_TAB_PRIVS to select_catalog_role
/
comment on table DBA_TAB_PRIVS is
'All grants on objects in the database'
/
comment on column DBA_TAB_PRIVS.GRANTEE is
'User to whom access was granted'
/
comment on column DBA_TAB_PRIVS.OWNER is
'Owner of the object'
/
comment on column DBA_TAB_PRIVS.TABLE_NAME is
'Name of the object'
/
comment on column DBA_TAB_PRIVS.GRANTOR is
'Name of the user who performed the grant'
/
comment on column DBA_TAB_PRIVS.PRIVILEGE is
'Table Privilege'
/
comment on column DBA_TAB_PRIVS.GRANTABLE is
'Privilege is grantable'
/
comment on column DBA_TAB_PRIVS.HIERARCHY is
'Privilege is with hierarchy option'
/
remark
remark  FAMILY "TAB_PRIVS_MADE"
remark  Grants made on objects.
remark  This family has no DBA member.
remark
create or replace view USER_TAB_PRIVS_MADE
      (GRANTEE, TABLE_NAME, GRANTOR, PRIVILEGE, GRANTABLE, HIERARCHY)
as
select ue.name, o.name, ur.name, tpm.name,
       decode(mod(oa.option$,2), 1, 'YES', 'NO'),
       decode(bitand(oa.option$,2), 2, 'YES', 'NO')
from sys.objauth$ oa, sys.obj$ o, sys.user$ ue, sys.user$ ur,
     table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and oa.col# is null
  and oa.privilege# = tpm.privilege
  and o.owner# = userenv('SCHEMAID')
/
comment on table USER_TAB_PRIVS_MADE is
'All grants on objects owned by the user'
/
comment on column USER_TAB_PRIVS_MADE.GRANTEE is
'Name of the user to whom access was granted'
/
comment on column USER_TAB_PRIVS_MADE.TABLE_NAME is
'Name of the object'
/
comment on column USER_TAB_PRIVS_MADE.GRANTOR is
'Name of the user who performed the grant'
/
comment on column USER_TAB_PRIVS_MADE.PRIVILEGE is
'Table Privilege'
/
comment on column USER_TAB_PRIVS_MADE.GRANTABLE is
'Privilege is grantable'
/
comment on column USER_TAB_PRIVS_MADE.HIERARCHY is
'Privilege is with hierarchy option'
/
create or replace public synonym USER_TAB_PRIVS_MADE for USER_TAB_PRIVS_MADE
/
grant select on USER_TAB_PRIVS_MADE to PUBLIC with grant option
/
create or replace view ALL_TAB_PRIVS_MADE
      (GRANTEE, OWNER, TABLE_NAME, GRANTOR, PRIVILEGE, GRANTABLE, HIERARCHY)
as
select ue.name, u.name, o.name, ur.name, tpm.name,
       decode(mod(oa.option$,2), 1, 'YES', 'NO'),
       decode(bitand(oa.option$,2), 2, 'YES', 'NO')
from sys.objauth$ oa, sys.obj$ o, sys.user$ u, sys.user$ ur, sys.user$ ue,
     table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and u.user# = o.owner#
  and oa.col# is null
  and oa.privilege# = tpm.privilege
  and userenv('SCHEMAID') in (o.owner#, oa.grantor#)
/
comment on table ALL_TAB_PRIVS_MADE is
'User''s grants and grants on user''s objects'
/
comment on column ALL_TAB_PRIVS_MADE.GRANTEE is
'Name of the user to whom access was granted'
/
comment on column ALL_TAB_PRIVS_MADE.OWNER is
'Owner of the object'
/
comment on column ALL_TAB_PRIVS_MADE.TABLE_NAME is
'Name of the object'
/
comment on column ALL_TAB_PRIVS_MADE.GRANTOR is
'Name of the user who performed the grant'
/
comment on column ALL_TAB_PRIVS_MADE.PRIVILEGE is
'Table Privilege'
/
comment on column ALL_TAB_PRIVS_MADE.GRANTABLE is
'Privilege is grantable'
/
comment on column ALL_TAB_PRIVS_MADE.HIERARCHY is
'Privilege is with hierarchy option'
/
create or replace public synonym ALL_TAB_PRIVS_MADE for ALL_TAB_PRIVS_MADE
/
grant select on ALL_TAB_PRIVS_MADE to PUBLIC with grant option
/
remark
remark  FAMILY "TAB_PRIVS_RECD"
remark  Grants received on objects.
remark  This family has no DBA member.
remark
create or replace view USER_TAB_PRIVS_RECD
      (OWNER, TABLE_NAME, GRANTOR, PRIVILEGE, GRANTABLE, HIERARCHY)
as
select u.name, o.name, ur.name, tpm.name,
       decode(mod(oa.option$,2), 1, 'YES', 'NO'),
       decode(bitand(oa.option$,2), 2, 'YES', 'NO')
from sys.objauth$ oa, sys.obj$ o, sys.user$ u, sys.user$ ur,
     table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and u.user# = o.owner#
  and oa.col# is null
  and oa.privilege# = tpm.privilege
  and oa.grantee# = userenv('SCHEMAID')
/
comment on table USER_TAB_PRIVS_RECD is
'Grants on objects for which the user is the grantee'
/
comment on column USER_TAB_PRIVS_RECD.OWNER is
'Owner of the object'
/
comment on column USER_TAB_PRIVS_RECD.TABLE_NAME is
'Name of the object'
/
comment on column USER_TAB_PRIVS_RECD.GRANTOR is
'Name of the user who performed the grant'
/
comment on column USER_TAB_PRIVS_RECD.PRIVILEGE is
'Table Privilege'
/
comment on column USER_TAB_PRIVS_RECD.GRANTABLE is
'Privilege is grantable'
/
comment on column USER_TAB_PRIVS_RECD.HIERARCHY is
'Privilege is with hierarchy option'
/
create or replace public synonym USER_TAB_PRIVS_RECD for USER_TAB_PRIVS_RECD
/
grant select on USER_TAB_PRIVS_RECD to PUBLIC with grant option
/
create or replace view ALL_TAB_PRIVS_RECD
      (GRANTEE, OWNER, TABLE_NAME, GRANTOR, PRIVILEGE, GRANTABLE, HIERARCHY)
as
select ue.name, u.name, o.name, ur.name, tpm.name,
       decode(mod(oa.option$,2), 1, 'YES', 'NO'),
       decode(bitand(oa.option$,2), 2, 'YES', 'NO')
from sys.objauth$ oa, sys.obj$ o, sys.user$ u, sys.user$ ur, sys.user$ ue,
     table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and u.user# = o.owner#
  and oa.col# is null
  and oa.privilege# = tpm.privilege
  and oa.grantee# in (select kzsrorol from x$kzsro)
/
comment on table ALL_TAB_PRIVS_RECD is
'Grants on objects for which the user, PUBLIC or enabled role is the grantee'
/
comment on column ALL_TAB_PRIVS_RECD.GRANTEE is
'Name of the user to whom access was granted'
/
comment on column ALL_TAB_PRIVS_RECD.OWNER is
'Owner of the object'
/
comment on column ALL_TAB_PRIVS_RECD.TABLE_NAME is
'Name of the object'
/
comment on column ALL_TAB_PRIVS_RECD.GRANTOR is
'Name of the user who performed the grant'
/
comment on column ALL_TAB_PRIVS_RECD.PRIVILEGE is
'Table Privilege'
/
comment on column ALL_TAB_PRIVS_RECD.GRANTABLE is
'Privilege is grantable'
/
comment on column ALL_TAB_PRIVS_RECD.HIERARCHY is
'Privilege is with hierarchy option'
/
create or replace public synonym ALL_TAB_PRIVS_RECD for ALL_TAB_PRIVS_RECD
/
grant select on ALL_TAB_PRIVS_RECD to PUBLIC with grant option
/
remark
remark  FAMILY "USERS"
remark  Users enrolled in the database.
remark
create or replace view USER_USERS
    (USERNAME, USER_ID, ACCOUNT_STATUS, LOCK_DATE, EXPIRY_DATE,
        DEFAULT_TABLESPACE, TEMPORARY_TABLESPACE, CREATED,
        INITIAL_RSRC_CONSUMER_GROUP, EXTERNAL_NAME)
as
select u.name, u.user#,
       m.status,
       decode(u.astatus, 4, u.ltime,
                         5, u.ltime,
                         6, u.ltime,
                         8, u.ltime,
                         9, u.ltime,
                         10, u.ltime, to_date(NULL)),
       decode(u.astatus,
              1, u.exptime,
              2, u.exptime,
              5, u.exptime,
              6, u.exptime,
              9, u.exptime,
              10, u.exptime,
              decode(u.ptime, '', to_date(NULL),
                decode(p.limit#, 2147483647, to_date(NULL),
                 decode(p.limit#, 0,
                   decode(dp.limit#, 2147483647, to_date(NULL), u.ptime +
                     dp.limit#/86400),
                   u.ptime + p.limit#/86400)))),
       dts.name, tts.name, u.ctime,
       nvl(cgm.consumer_group, 'DEFAULT_CONSUMER_GROUP'),
       u.ext_username
from sys.user$ u left outer join sys.resource_group_mapping$ cgm
     on (cgm.attribute = 'ORACLE_USER' and cgm.status = 'ACTIVE' and
         cgm.value = u.name),
     sys.ts$ dts, sys.ts$ tts, sys.user_astatus_map m,
     profile$ p, profile$ dp
where u.datats# = dts.ts#
  and u.tempts# = tts.ts#
  and u.astatus = m.status#
  and u.type# = 1
  and u.user# = userenv('SCHEMAID')
  and u.resource$ = p.profile#
  and dp.profile# = 0
  and dp.type# = 1
  and dp.resource# = 1
  and p.type# = 1
  and p.resource# = 1
/
comment on table USER_USERS is
'Information about the current user'
/
comment on column USER_USERS.USERNAME is
'Name of the user'
/
comment on column USER_USERS.USER_ID is
'ID number of the user'
/
comment on column USER_USERS.DEFAULT_TABLESPACE is
'Default tablespace for data'
/
comment on column USER_USERS.TEMPORARY_TABLESPACE is
'Default tablespace for temporary tables'
/
comment on column USER_USERS.CREATED is
'User creation date'
/
comment on column USER_USERS.INITIAL_RSRC_CONSUMER_GROUP is
'User''s initial consumer group'
/
comment on column USER_USERS.EXTERNAL_NAME is
'User external name'
/
create or replace public synonym USER_USERS for USER_USERS
/
grant select on USER_USERS to PUBLIC with grant option
/
create or replace view ALL_USERS
    (USERNAME, USER_ID, CREATED)
as
select u.name, u.user#, u.ctime
from sys.user$ u, sys.ts$ dts, sys.ts$ tts
where u.datats# = dts.ts#
  and u.tempts# = tts.ts#
  and u.type# = 1
/
comment on table ALL_USERS is
'Information about all users of the database'
/
comment on column ALL_USERS.USERNAME is
'Name of the user'
/
comment on column ALL_USERS.USER_ID is
'ID number of the user'
/
comment on column ALL_USERS.CREATED is
'User creation date'
/
create or replace public synonym ALL_USERS for ALL_USERS
/
grant select on ALL_USERS to PUBLIC with grant option
/
create or replace view DBA_USERS
    (USERNAME, USER_ID, PASSWORD, ACCOUNT_STATUS, LOCK_DATE, EXPIRY_DATE,
        DEFAULT_TABLESPACE, TEMPORARY_TABLESPACE, CREATED, PROFILE,
        INITIAL_RSRC_CONSUMER_GROUP,EXTERNAL_NAME)
as
select u.name, u.user#, u.password,
       m.status,
       decode(u.astatus, 4, u.ltime,
                         5, u.ltime,
                         6, u.ltime,
                         8, u.ltime,
                         9, u.ltime,
                         10, u.ltime, to_date(NULL)),
       decode(u.astatus,
              1, u.exptime,
              2, u.exptime,
              5, u.exptime,
              6, u.exptime,
              9, u.exptime,
              10, u.exptime,
              decode(u.ptime, '', to_date(NULL),
                decode(pr.limit#, 2147483647, to_date(NULL),
                 decode(pr.limit#, 0,
                   decode(dp.limit#, 2147483647, to_date(NULL), u.ptime +
                     dp.limit#/86400),
                   u.ptime + pr.limit#/86400)))),
       dts.name, tts.name, u.ctime, p.name,
       nvl(cgm.consumer_group, 'DEFAULT_CONSUMER_GROUP'),
       u.ext_username
       from sys.user$ u left outer join sys.resource_group_mapping$ cgm
            on (cgm.attribute = 'ORACLE_USER' and cgm.status = 'ACTIVE' and
                cgm.value = u.name),
            sys.ts$ dts, sys.ts$ tts, sys.profname$ p,
            sys.user_astatus_map m, sys.profile$ pr, sys.profile$ dp
       where u.datats# = dts.ts#
       and u.resource$ = p.profile#
       and u.tempts# = tts.ts#
       and u.astatus = m.status#
       and u.type# = 1
       and u.resource$ = pr.profile#
       and dp.profile# = 0
       and dp.type#=1
       and dp.resource#=1
       and pr.type# = 1
       and pr.resource# = 1
/
create or replace public synonym DBA_USERS for DBA_USERS
/
grant select on DBA_USERS to select_catalog_role
/
comment on table DBA_USERS is
'Information about all users of the database'
/
comment on column DBA_USERS.USERNAME is
'Name of the user'
/
comment on column DBA_USERS.USER_ID is
'ID number of the user'
/
comment on column DBA_USERS.PASSWORD is
'Encrypted password'
/
comment on column DBA_USERS.DEFAULT_TABLESPACE is
'Default tablespace for data'
/
comment on column DBA_USERS.TEMPORARY_TABLESPACE is
'Default tablespace for temporary tables'
/
comment on column DBA_USERS.CREATED is
'User creation date'
/
comment on column DBA_USERS.PROFILE is
'User resource profile name'
/
comment on column DBA_USERS.INITIAL_RSRC_CONSUMER_GROUP is
'User''s initial consumer group'
/
comment on column DBA_USERS.EXTERNAL_NAME is
'User external name'
/

remark
remark  FAMILY "PROXIES"
remark  Allowed proxy authentication methods
remark
create or replace view USER_PROXIES
    (CLIENT, AUTHENTICATION, AUTHORIZATION_CONSTRAINT, ROLE)
as
select u.name,
       decode(p.credential_type#, 0, 'NO',
                                  5, 'YES'),
       decode(p.flags, 0, null,
                       1, 'PROXY MAY ACTIVATE ALL CLIENT ROLES',
                       2, 'NO CLIENT ROLES MAY BE ACTIVATED',
                       4, 'PROXY MAY ACTIVATE ROLE',
                       5, 'PROXY MAY ACTIVATE ALL CLIENT ROLES',
                       8, 'PROXY MAY NOT ACTIVATE ROLE'),
       (select u.name from sys.user$ u where pr.role# = u.user#)
from sys.user$ u, sys.proxy_info$ p, sys.proxy_role_info$ pr
where u.user#  = p.client#
  and p.proxy#  = pr.proxy#(+)
  and p.client# = pr.client#(+)
  and p.proxy# = userenv('SCHEMAID')
/
comment on table USER_PROXIES is
'Description of connections the user is allowed to proxy'
/
comment on column USER_PROXIES.CLIENT is
'Name of the client user who the proxy user can act on behalf of'
/
comment on column USER_PROXIES.AUTHENTICATION is
'Indicates whether proxy is required to supply client''s authentication credentials'
/
comment on column USER_PROXIES.AUTHORIZATION_CONSTRAINT is
'Indicates the proxy''s authority to exercise roles on client''s behalf'
/
comment on column USER_PROXIES.ROLE is
'Name of the role referenced in authorization constraint'
/
create or replace public synonym USER_PROXIES for USER_PROXIES
/
grant select on USER_PROXIES to PUBLIC with grant option
/

create or replace view DBA_PROXIES
    (PROXY, CLIENT, AUTHENTICATION, AUTHORIZATION_CONSTRAINT, ROLE, PROXY_AUTHORITY)
as
select u1.name,
       u2.name,
       decode(p.credential_type#, 0, 'NO',
                                  5, 'YES'),
       decode(p.flags, 0, null,
                       1, 'PROXY MAY ACTIVATE ALL CLIENT ROLES',
                       2, 'NO CLIENT ROLES MAY BE ACTIVATED',
                       4, 'PROXY MAY ACTIVATE ROLE',
                       5, 'PROXY MAY ACTIVATE ALL CLIENT ROLES',
                       8, 'PROXY MAY NOT ACTIVATE ROLE',
                      16, 'PROXY MAY ACTIVATE ALL CLIENT ROLES'),
       (select u.name from sys.user$ u where pr.role# = u.user#),
       case p.flags when 16 then 'DIRECTORY' else 'DATABASE' end
from sys.user$ u1, sys.user$ u2,
     sys.proxy_info$ p, sys.proxy_role_info$ pr
where u1.user#(+)  = p.proxy#
  and u2.user#     = p.client#
  and p.proxy#     = pr.proxy#(+)
  and p.client#    = pr.client#(+)
/
comment on table DBA_PROXIES is
'Information about all proxy connections'
/
comment on column DBA_PROXIES.PROXY is
'Name of the proxy user'
/
comment on column DBA_PROXIES.CLIENT is
'Name of the client user who the proxy user can act on behalf of'
/
comment on column DBA_PROXIES.AUTHENTICATION is
'Indicates whether proxy is required to supply client''s authentication credentials'
/
comment on column DBA_PROXIES.AUTHORIZATION_CONSTRAINT is
'Indicates the proxy''s authority to exercise roles on client''s behalf'
/
comment on column DBA_PROXIES.ROLE is
'Name of the role referenced in authorization constraint'
/
comment on column DBA_PROXIES.PROXY_AUTHORITY is
'Indicates where proxy permissions are managed'
/
create or replace public synonym DBA_PROXIES for DBA_PROXIES
/
grant select on DBA_PROXIES to select_catalog_role
/

rem Contains a list of all proxy users and the clients upon whose behalf they
rem can act
create or replace view PROXY_USERS
    (PROXY, CLIENT, AUTHENTICATION, FLAGS)
as
select u1.name,
       u2.name,
       decode(p.credential_type#, 0, 'NO',
                                  5, 'YES'),
       decode(p.flags, 0, null,
                       1, 'PROXY MAY ACTIVATE ALL CLIENT ROLES',
                       2, 'NO CLIENT ROLES MAY BE ACTIVATED',
                       4, 'PROXY MAY ACTIVATE ROLE',
                       5, 'PROXY MAY ACTIVATE ALL CLIENT ROLES',
                       8, 'PROXY MAY NOT ACTIVATE ROLE')
from sys.user$ u1, sys.user$ u2, sys.proxy_info$ p
where u1.user# = p.proxy#
  and u2.user# = p.client#
/
comment on table PROXY_USERS is
'List of proxy users and the client on whose behalf they can act.'
/
comment on column PROXY_USERS.PROXY is
'Name of a proxy user'
/
comment on column PROXY_USERS.CLIENT is
'Name of the client user who the proxy user can act as'
/
comment on column PROXY_USERS.AUTHENTICATION is
'Indicates whether proxy is required to supply client''s authentication credentials'
/
comment on column PROXY_USERS.FLAGS is
'Flags associated with the proxy/client pair'
/
create or replace public synonym PROXY_USERS for PROXY_USERS
/
grant select on PROXY_USERS to SELECT_CATALOG_ROLE
/

rem List of roles that may executed by a proxy user on behalf of a client.
create or replace view PROXY_ROLES (PROXY, CLIENT, ROLE)
as
select u1.name,
       u2.name,
       u3.name
from sys.user$ u1, sys.user$ u2, sys.user$ u3, sys.proxy_role_info$ p
where u1.user# = p.proxy#
  and u2.user# = p.client#
  and u3.user# = p.role#
/
comment on table PROXY_ROLES is
'Table of roles that a proxy can set on behalf of a client'
/
comment on column PROXY_ROLES.PROXY is
'Name of a proxy user'
/
comment on column PROXY_ROLES.CLIENT is
'Name of the client user who the proxy user acts as'
/
comment on column PROXY_ROLES.ROLE is
'Name of the role that the proxy can execute'
/
create or replace public synonym PROXY_ROLES for PROXY_ROLES
/
grant select on PROXY_ROLES to SELECT_CATALOG_ROLE
/

rem List of all proxies, clients and roles.
create or replace view PROXY_USERS_AND_ROLES (PROXY, CLIENT, FLAGS, ROLE)
as
select u.proxy,
       u.client,
       u.flags,
       r.role
from sys.proxy_users u, sys.proxy_roles r
where u.proxy  = r.proxy
  and u.client = r.client
/
comment on table PROXY_USERS_AND_ROLES is
'List of all proxies, clients and roles.'
/
comment on column PROXY_USERS_AND_ROLES.PROXY is
'Name of the proxy user'
/
comment on column PROXY_USERS_AND_ROLES.CLIENT is
'Name of the client user'
/
comment on column PROXY_USERS_AND_ROLES.FLAGS is
'Flags corresponding to the proxy/client combination'
/
comment on column PROXY_USERS_AND_ROLES.ROLE is
'Name of the role that a proxy can execute while acting on behalf of the
client'
/
create or replace public synonym PROXY_USERS_AND_ROLES
   for PROXY_USERS_AND_ROLES
/
grant select on PROXY_USERS_AND_ROLES to SELECT_CATALOG_ROLE
/

remark
remark  FAMILY "VIEWS"
remark  All relevant information about views, except columns.
remark
create or replace view USER_VIEWS
    (VIEW_NAME, TEXT_LENGTH, TEXT, TYPE_TEXT_LENGTH, TYPE_TEXT,
     OID_TEXT_LENGTH, OID_TEXT, VIEW_TYPE_OWNER, VIEW_TYPE, SUPERVIEW_NAME)
as
select o.name, v.textlength, v.text, t.typetextlength, t.typetext,
       t.oidtextlength, t.oidtext, t.typeowner, t.typename,
       decode(bitand(v.property, 134217728), 134217728,
              (select sv.name from superobj$ h, obj$ sv
              where h.subobj# = o.obj# and h.superobj# = sv.obj#), null)
from sys.obj$ o, sys.view$ v, sys.typed_view$ t
where o.obj# = v.obj#
  and o.obj# = t.obj#(+)
  and o.owner# = userenv('SCHEMAID')
/
comment on table USER_VIEWS is
'Description of the user''s own views'
/
comment on column USER_VIEWS.VIEW_NAME is
'Name of the view'
/
comment on column USER_VIEWS.TEXT_LENGTH is
'Length of the view text'
/
comment on column USER_VIEWS.TEXT is
'View text'
/
comment on column USER_VIEWS.TYPE_TEXT_LENGTH is
'Length of the type clause of the object view'
/
comment on column USER_VIEWS.TYPE_TEXT is
'Type clause of the object view'
/
comment on column USER_VIEWS.OID_TEXT_LENGTH is
'Length of the WITH OBJECT OID clause of the object view'
/
comment on column USER_VIEWS.OID_TEXT is
'WITH OBJECT OID clause of the object view'
/
comment on column USER_VIEWS.VIEW_TYPE_OWNER is
'Owner of the type of the view if the view is a object view'
/
comment on column USER_VIEWS.VIEW_TYPE is
'Type of the view if the view is a object view'
/
comment on column USER_VIEWS.SUPERVIEW_NAME is
'Name of the superview, if view is a subview'
/
create or replace public synonym USER_VIEWS for USER_VIEWS
/
grant select on USER_VIEWS to PUBLIC with grant option
/
create or replace view ALL_VIEWS
    (OWNER, VIEW_NAME, TEXT_LENGTH, TEXT, TYPE_TEXT_LENGTH, TYPE_TEXT,
     OID_TEXT_LENGTH, OID_TEXT, VIEW_TYPE_OWNER, VIEW_TYPE, SUPERVIEW_NAME)
as
select u.name, o.name, v.textlength, v.text, t.typetextlength, t.typetext,
       t.oidtextlength, t.oidtext, t.typeowner, t.typename,
       decode(bitand(v.property, 134217728), 134217728,
              (select sv.name from superobj$ h, obj$ sv
              where h.subobj# = o.obj# and h.superobj# = sv.obj#), null)
from sys.obj$ o, sys.view$ v, sys.user$ u, sys.typed_view$ t
where o.obj# = v.obj#
  and o.obj# = t.obj#(+)
  and o.owner# = u.user#
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where oa.grantee# in ( select kzsrorol
                                         from x$kzsro
                                  )
            )
        or /* user has system privileges */
          exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */)
                  )
      )
/
comment on table ALL_VIEWS is
'Description of views accessible to the user'
/
comment on column ALL_VIEWS.OWNER is
'Owner of the view'
/
comment on column ALL_VIEWS.VIEW_NAME is
'Name of the view'
/
comment on column ALL_VIEWS.TEXT_LENGTH is
'Length of the view text'
/
comment on column ALL_VIEWS.TEXT is
'View text'
/
comment on column ALL_VIEWS.TYPE_TEXT_LENGTH is
'Length of the type clause of the object view'
/
comment on column ALL_VIEWS.TYPE_TEXT is
'Type clause of the object view'
/
comment on column ALL_VIEWS.OID_TEXT_LENGTH is
'Length of the WITH OBJECT OID clause of the object view'
/
comment on column ALL_VIEWS.OID_TEXT is
'WITH OBJECT OID clause of the object view'
/
comment on column ALL_VIEWS.VIEW_TYPE_OWNER is
'Owner of the type of the view if the view is an object view'
/
comment on column ALL_VIEWS.VIEW_TYPE is
'Type of the view if the view is an object view'
/
comment on column ALL_VIEWS.SUPERVIEW_NAME is
'Name of the superview, if view is a subview'
/
create or replace public synonym ALL_VIEWS for ALL_VIEWS
/
grant select on ALL_VIEWS to PUBLIC with grant option
/
create or replace view DBA_VIEWS
    (OWNER, VIEW_NAME, TEXT_LENGTH, TEXT, TYPE_TEXT_LENGTH, TYPE_TEXT,
     OID_TEXT_LENGTH, OID_TEXT, VIEW_TYPE_OWNER, VIEW_TYPE, SUPERVIEW_NAME)
as
select u.name, o.name, v.textlength, v.text, t.typetextlength, t.typetext,
       t.oidtextlength, t.oidtext, t.typeowner, t.typename,
       decode(bitand(v.property, 134217728), 134217728,
              (select sv.name from superobj$ h, obj$ sv
              where h.subobj# = o.obj# and h.superobj# = sv.obj#), null)
from sys.obj$ o, sys.view$ v, sys.user$ u, sys.typed_view$ t
where o.obj# = v.obj#
  and o.obj# = t.obj#(+)
  and o.owner# = u.user#
/
create or replace public synonym DBA_VIEWS for DBA_VIEWS
/
grant select on DBA_VIEWS to select_catalog_role
/
comment on table DBA_VIEWS is
'Description of all views in the database'
/
comment on column DBA_VIEWS.OWNER is
'Owner of the view'
/
comment on column DBA_VIEWS.VIEW_NAME is
'Name of the view'
/
comment on column DBA_VIEWS.TEXT_LENGTH is
'Length of the view text'
/
comment on column DBA_VIEWS.TEXT is
'View text'
/
comment on column DBA_VIEWS.TYPE_TEXT_LENGTH is
'Length of the type clause of the object view'
/
comment on column DBA_VIEWS.TYPE_TEXT is
'Type clause of the object view'
/
comment on column DBA_VIEWS.OID_TEXT_LENGTH is
'Length of the WITH OBJECT OID clause of the object view'
/
comment on column DBA_VIEWS.OID_TEXT is
'WITH OBJECT OID clause of the object view'
/
comment on column DBA_VIEWS.VIEW_TYPE_OWNER is
'Owner of the type of the view if the view is an object view'
/
comment on column DBA_VIEWS.VIEW_TYPE is
'Type of the view if the view is an object view'
/
comment on column DBA_VIEWS.SUPERVIEW_NAME is
'Name of the superview, if view is a subview'
/
remark
remark  FAMILY "CONSTRAINTS"
remark
create or replace view USER_CONSTRAINTS
    (OWNER, CONSTRAINT_NAME, CONSTRAINT_TYPE,
     TABLE_NAME, SEARCH_CONDITION, R_OWNER,
     R_CONSTRAINT_NAME, DELETE_RULE, STATUS,
     DEFERRABLE, DEFERRED, VALIDATED, GENERATED,
     BAD, RELY, LAST_CHANGE, INDEX_OWNER, INDEX_NAME,
     INVALID, VIEW_RELATED)
as
select ou.name, oc.name,
       decode(c.type#, 1, 'C', 2, 'P', 3, 'U',
              4, 'R', 5, 'V', 6, 'O', 7,'C', '?'),
       o.name, c.condition, ru.name, rc.name,
       decode(c.type#, 4,
              decode(c.refact, 1, 'CASCADE', 2, 'SET NULL', 'NO ACTION'),
              NULL),
       decode(c.type#, 5, 'ENABLED',
              decode(c.enabled, NULL, 'DISABLED', 'ENABLED')),
       decode(bitand(c.defer, 1), 1, 'DEFERRABLE', 'NOT DEFERRABLE'),
       decode(bitand(c.defer, 2), 2, 'DEFERRED', 'IMMEDIATE'),
       decode(bitand(c.defer, 4), 4, 'VALIDATED', 'NOT VALIDATED'),
       decode(bitand(c.defer, 8), 8, 'GENERATED NAME', 'USER NAME'),
       decode(bitand(c.defer,16),16, 'BAD', null),
       decode(bitand(c.defer,32),32, 'RELY', null),
       c.mtime,
       decode(c.type#, 2, ui.name, 3, ui.name, null),
       decode(c.type#, 2, oi.name, 3, oi.name, null),
       decode(bitand(c.defer, 256), 256,
              decode(c.type#, 4,
                     case when (bitand(c.defer, 128) = 128
                                or o.status in (3, 5)
                                or ro.status in (3, 5)) then 'INVALID'
                          else null end,
                     case when (bitand(c.defer, 128) = 128
                                or o.status in (3, 5)) then 'INVALID'
                          else null end
                    ),
              null),
       decode(bitand(c.defer, 256), 256, 'DEPEND ON VIEW', null)
from sys.con$ oc, sys.con$ rc, sys.user$ ou, sys.user$ ru, sys.obj$ ro,
     sys.obj$ o, sys.cdef$ c, sys.obj$ oi, sys.user$ ui
where oc.owner# = ou.user#
  and oc.con# = c.con#
  and c.obj# = o.obj#
  and c.rcon# = rc.con#(+)
  and c.enabled = oi.obj#(+)
  and oi.owner# = ui.user#(+)
  and rc.owner# = ru.user#(+)
  and c.robj# = ro.obj#(+)
  and o.owner# = userenv('SCHEMAID')
  and c.type# != 8
  and c.type# != 12       /* don't include log groups */
/
comment on table USER_CONSTRAINTS is
'Constraint definitions on user''s own tables'
/
comment on column USER_CONSTRAINTS.OWNER is
'Owner of the table'
/
comment on column USER_CONSTRAINTS.CONSTRAINT_NAME is
'Name associated with constraint definition'
/
comment on column USER_CONSTRAINTS.CONSTRAINT_TYPE is
'Type of constraint definition'
/
comment on column USER_CONSTRAINTS.TABLE_NAME is
'Name associated with table with constraint definition'
/
comment on column USER_CONSTRAINTS.SEARCH_CONDITION is
'Text of search condition for table check'
/
comment on column USER_CONSTRAINTS.R_OWNER is
'Owner of table used in referential constraint'
/
comment on column USER_CONSTRAINTS.R_CONSTRAINT_NAME is
'Name of unique constraint definition for referenced table'
/
comment on column USER_CONSTRAINTS.DELETE_RULE is
'The delete rule for a referential constraint'
/
comment on column USER_CONSTRAINTS.STATUS is
'Enforcement status of constraint -  ENABLED or DISABLED'
/
comment on column USER_CONSTRAINTS.DEFERRABLE is
'Is the constraint deferrable - DEFERRABLE or NOT DEFERRABLE'
/
comment on column USER_CONSTRAINTS.DEFERRED is
'Is the constraint deferred by default -  DEFERRED or IMMEDIATE'
/
comment on column USER_CONSTRAINTS.VALIDATED is
'Was this constraint system validated? -  VALIDATED or NOT VALIDATED'
/
comment on column USER_CONSTRAINTS.GENERATED is
'Was the constraint name system generated? -  GENERATED NAME or USER NAME'
/
comment on column USER_CONSTRAINTS.BAD is
'Creating this constraint should give ORA-02436.  Rewrite it before 2000 AD.'
/
comment on column USER_CONSTRAINTS.RELY is
'If set, this flag will be used in optimizer'
/
comment on column USER_CONSTRAINTS.LAST_CHANGE is
'The date when this column was last enabled or disabled'
/
comment on column USER_CONSTRAINTS.INDEX_OWNER is
'The owner of the index used by the constraint'
/
comment on column USER_CONSTRAINTS.INDEX_NAME is
'The index used by the constraint'
/
grant select on USER_CONSTRAINTS to public with grant option
/
create or replace public synonym USER_CONSTRAINTS for USER_CONSTRAINTS
/
create or replace view ALL_CONSTRAINTS
    (OWNER, CONSTRAINT_NAME, CONSTRAINT_TYPE,
     TABLE_NAME, SEARCH_CONDITION, R_OWNER,
     R_CONSTRAINT_NAME, DELETE_RULE, STATUS,
     DEFERRABLE, DEFERRED, VALIDATED, GENERATED,
     BAD, RELY, LAST_CHANGE, INDEX_OWNER, INDEX_NAME,
     INVALID, VIEW_RELATED)
as
select ou.name, oc.name,
       decode(c.type#, 1, 'C', 2, 'P', 3, 'U',
              4, 'R', 5, 'V', 6, 'O', 7,'C', '?'),
       o.name, c.condition, ru.name, rc.name,
       decode(c.type#, 4,
              decode(c.refact, 1, 'CASCADE', 2, 'SET NULL', 'NO ACTION'),
              NULL),
       decode(c.type#, 5, 'ENABLED',
              decode(c.enabled, NULL, 'DISABLED', 'ENABLED')),
       decode(bitand(c.defer, 1), 1, 'DEFERRABLE', 'NOT DEFERRABLE'),
       decode(bitand(c.defer, 2), 2, 'DEFERRED', 'IMMEDIATE'),
       decode(bitand(c.defer, 4), 4, 'VALIDATED', 'NOT VALIDATED'),
       decode(bitand(c.defer, 8), 8, 'GENERATED NAME', 'USER NAME'),
       decode(bitand(c.defer,16),16, 'BAD', null),
       decode(bitand(c.defer,32),32, 'RELY', null),
       c.mtime,
       decode(c.type#, 2, ui.name, 3, ui.name, null),
       decode(c.type#, 2, oi.name, 3, oi.name, null),
       decode(bitand(c.defer, 256), 256,
              decode(c.type#, 4,
                     case when (bitand(c.defer, 128) = 128
                                or o.status in (3, 5)
                                or ro.status in (3, 5)) then 'INVALID'
                          else null end,
                     case when (bitand(c.defer, 128) = 128
                                or o.status in (3, 5)) then 'INVALID'
                          else null end
                    ),
              null),
       decode(bitand(c.defer, 256), 256, 'DEPEND ON VIEW', null)
from sys.con$ oc, sys.con$ rc, sys.user$ ou, sys.user$ ru, sys.obj$ ro,
     sys.obj$ o, sys.cdef$ c, sys.obj$ oi, sys.user$ ui
where oc.owner# = ou.user#
  and oc.con# = c.con#
  and c.obj# = o.obj#
  and c.type# != 8
  and c.type# != 12       /* don't include log groups */
  and c.rcon# = rc.con#(+)
  and c.enabled = oi.obj#(+)
  and oi.obj# = ui.user#(+)
  and rc.owner# = ru.user#(+)
  and c.robj# = ro.obj#(+)
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in (select obj#
                     from sys.objauth$
                     where grantee# in ( select kzsrorol
                                         from x$kzsro
                                       )
                    )
        or /* user has system privileges */
          exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */)
                  )
      )
/
comment on table ALL_CONSTRAINTS is
'Constraint definitions on accessible tables'
/
comment on column ALL_CONSTRAINTS.OWNER is
'Owner of the table'
/
comment on column ALL_CONSTRAINTS.CONSTRAINT_NAME is
'Name associated with constraint definition'
/
comment on column ALL_CONSTRAINTS.CONSTRAINT_TYPE is
'Type of constraint definition'
/
comment on column ALL_CONSTRAINTS.TABLE_NAME is
'Name associated with table with constraint definition'
/
comment on column ALL_CONSTRAINTS.SEARCH_CONDITION is
'Text of search condition for table check'
/
comment on column ALL_CONSTRAINTS.R_OWNER is
'Owner of table used in referential constraint'
/
comment on column ALL_CONSTRAINTS.R_CONSTRAINT_NAME is
'Name of unique constraint definition for referenced table'
/
comment on column ALL_CONSTRAINTS.DELETE_RULE is
'The delete rule for a referential constraint'
/
comment on column ALL_CONSTRAINTS.STATUS is
'Enforcement status of constraint - ENABLED or DISABLED'
/
comment on column ALL_CONSTRAINTS.DEFERRABLE is
'Is the constraint deferrable - DEFERRABLE or NOT DEFERRABLE'
/
comment on column ALL_CONSTRAINTS.DEFERRED is
'Is the constraint deferred by default -  DEFERRED or IMMEDIATE'
/
comment on column ALL_CONSTRAINTS.VALIDATED is
'Was this constraint system validated? -  VALIDATED or NOT VALIDATED'
/
comment on column ALL_CONSTRAINTS.GENERATED is
'Was the constraint name system generated? -  GENERATED NAME or USER NAME'
/
comment on column ALL_CONSTRAINTS.BAD is
'Creating this constraint should give ORA-02436.  Rewrite it before 2000 AD.'
/
comment on column ALL_CONSTRAINTS.RELY is
'If set, this flag will be used in optimizer'
/
comment on column ALL_CONSTRAINTS.LAST_CHANGE is
'The date when this column was last enabled or disabled'
/
comment on column ALL_CONSTRAINTS.INDEX_OWNER is
'The owner of the index used by this constraint'
/
comment on column ALL_CONSTRAINTS.INDEX_NAME is
'The index used by this constraint'
/
grant select on ALL_CONSTRAINTS to public with grant option
/

create or replace public synonym ALL_CONSTRAINTS for ALL_CONSTRAINTS
/
create or replace view DBA_CONSTRAINTS
    (OWNER, CONSTRAINT_NAME, CONSTRAINT_TYPE,
     TABLE_NAME, SEARCH_CONDITION, R_OWNER,
     R_CONSTRAINT_NAME, DELETE_RULE, STATUS,
     DEFERRABLE, DEFERRED, VALIDATED, GENERATED,
     BAD, RELY, LAST_CHANGE, INDEX_OWNER, INDEX_NAME,
     INVALID, VIEW_RELATED)
as
select ou.name, oc.name,
       decode(c.type#, 1, 'C', 2, 'P', 3, 'U',
              4, 'R', 5, 'V', 6, 'O', 7,'C', '?'),
       o.name, c.condition, ru.name, rc.name,
       decode(c.type#, 4,
              decode(c.refact, 1, 'CASCADE', 2, 'SET NULL', 'NO ACTION'),
              NULL),
       decode(c.type#, 5, 'ENABLED',
              decode(c.enabled, NULL, 'DISABLED', 'ENABLED')),
       decode(bitand(c.defer, 1), 1, 'DEFERRABLE', 'NOT DEFERRABLE'),
       decode(bitand(c.defer, 2), 2, 'DEFERRED', 'IMMEDIATE'),
       decode(bitand(c.defer, 4), 4, 'VALIDATED', 'NOT VALIDATED'),
       decode(bitand(c.defer, 8), 8, 'GENERATED NAME', 'USER NAME'),
       decode(bitand(c.defer,16),16, 'BAD', null),
       decode(bitand(c.defer,32),32, 'RELY', null),
       c.mtime,
       decode(c.type#, 2, ui.name, 3, ui.name, null),
       decode(c.type#, 2, oi.name, 3, oi.name, null),
       decode(bitand(c.defer, 256), 256,
              decode(c.type#, 4,
                     case when (bitand(c.defer, 128) = 128
                                or o.status in (3, 5)
                                or ro.status in (3, 5)) then 'INVALID'
                          else null end,
                     case when (bitand(c.defer, 128) = 128
                                or o.status in (3, 5)) then 'INVALID'
                          else null end
                    ),
              null),
       decode(bitand(c.defer, 256), 256, 'DEPEND ON VIEW', null)
from sys.con$ oc, sys.con$ rc, sys.user$ ou, sys.user$ ru, sys.obj$ ro,
     sys.obj$ o, sys.cdef$ c, sys.obj$ oi, sys.user$ ui
where oc.owner# = ou.user#
  and oc.con# = c.con#
  and c.obj# = o.obj#
  and c.type# != 8        /* don't include hash expressions */
  and c.type# != 12       /* don't include log groups */
  and c.rcon# = rc.con#(+)
  and c.enabled = oi.obj#(+)
  and oi.owner# = ui.user#(+)
  and rc.owner# = ru.user#(+)
  and c.robj# = ro.obj#(+)
/
create or replace public synonym DBA_CONSTRAINTS for DBA_CONSTRAINTS
/
grant select on DBA_CONSTRAINTS to select_catalog_role
/
comment on table DBA_CONSTRAINTS is
'Constraint definitions on all tables'
/
comment on column DBA_CONSTRAINTS.OWNER is
'Owner of the table'
/
comment on column DBA_CONSTRAINTS.CONSTRAINT_NAME is
'Name associated with constraint definition'
/
comment on column DBA_CONSTRAINTS.CONSTRAINT_TYPE is
'Type of constraint definition'
/
comment on column DBA_CONSTRAINTS.TABLE_NAME is
'Name associated with table with constraint definition'
/
comment on column DBA_CONSTRAINTS.SEARCH_CONDITION is
'Text of search condition for table check'
/
comment on column DBA_CONSTRAINTS.R_OWNER is
'Owner of table used in referential constraint'
/
comment on column DBA_CONSTRAINTS.R_CONSTRAINT_NAME is
'Name of unique constraint definition for referenced table'
/
comment on column DBA_CONSTRAINTS.DELETE_RULE is
'The delete rule for a referential constraint'
/
comment on column DBA_CONSTRAINTS.STATUS is
'Enforcement status of constraint - ENABLED or DISABLED'
/
comment on column DBA_CONSTRAINTS.DEFERRABLE is
'Is the constraint deferrable - DEFERRABLE or NOT DEFERRABLE'
/
comment on column DBA_CONSTRAINTS.DEFERRED is
'Is the constraint deferred by default -  DEFERRED or IMMEDIATE'
/
comment on column DBA_CONSTRAINTS.VALIDATED is
'Was this constraint system validated? -  VALIDATED or NOT VALIDATED'
/
comment on column DBA_CONSTRAINTS.GENERATED is
'Was the constraint name system generated? -  GENERATED NAME or USER NAME'
/
comment on column DBA_CONSTRAINTS.BAD is
'Creating this constraint should give ORA-02436.  Rewrite it before 2000 AD.'
/
comment on column DBA_CONSTRAINTS.RELY is
'If set, this flag will be used in optimizer'
/
comment on column DBA_CONSTRAINTS.LAST_CHANGE is
'The date when this column was last enabled or disabled'
/
comment on column DBA_CONSTRAINTS.INDEX_OWNER is
'The owner of the index used by this constraint'
/
comment on column DBA_CONSTRAINTS.INDEX_NAME is
'The index used by this constraint'
/

remark
remark  FAMILY "LOG_GROUPS"
remark
create or replace view USER_LOG_GROUPS
    (OWNER, LOG_GROUP_NAME, TABLE_NAME, LOG_GROUP_TYPE, ALWAYS, GENERATED)
as
select ou.name, oc.name, o.name,
       case c.type# when 14 then 'PRIMARY KEY LOGGING'
                    when 15 then 'UNIQUE KEY LOGGING'
                    when 16 then 'FOREIGN KEY LOGGING'
                    when 17 then 'ALL COLUMN LOGGING'
                    else 'USER LOG GROUP'
       end,
       case bitand(c.defer,64) when 64 then 'ALWAYS'
                               else  'CONDITIONAL'
       end,
       case bitand(c.defer,8) when 8 then 'GENERATED NAME'
                              else  'USER NAME'
       end
from sys.con$ oc,  sys.user$ ou,
     sys.obj$ o, sys.cdef$ c
where oc.owner# = ou.user#
  and oc.con# = c.con#
  and c.obj# = o.obj#
  and o.owner# = userenv('SCHEMAID')
  and
  (c.type# = 12 or c.type# = 14 or
   c.type# = 15 or c.type# = 16 or
   c.type# = 17)
/
comment on table USER_LOG_GROUPS is
'Log group definitions on user''s own tables'
/
comment on column USER_LOG_GROUPS.OWNER is
'Owner of the table'
/
comment on column USER_LOG_GROUPS.LOG_GROUP_NAME is
'Name associated with log group definition'
/
comment on column USER_LOG_GROUPS.TABLE_NAME is
'Name of the table on which this log group is defined'
/
comment on column USER_LOG_GROUPS.LOG_GROUP_TYPE is
'Type of the log group'
/
comment on column USER_LOG_GROUPS.ALWAYS is
'Is this an ALWAYS or a CONDITIONAL supplemental log group?'
/
comment on column USER_LOG_GROUPS.GENERATED is
'Was the name of this supplemental log group system generated?'
/
grant select on USER_LOG_GROUPS to public with grant option
/
create or replace public synonym USER_LOG_GROUPS for USER_LOG_GROUPS
/
create or replace view ALL_LOG_GROUPS
    (OWNER, LOG_GROUP_NAME, TABLE_NAME, LOG_GROUP_TYPE, ALWAYS, GENERATED)
as
select ou.name, oc.name, o.name,
       case c.type# when 14 then 'PRIMARY KEY LOGGING'
                    when 15 then 'UNIQUE KEY LOGGING'
                    when 16 then 'FOREIGN KEY LOGGING'
                    when 17 then 'ALL COLUMN LOGGING'
                    else 'USER LOG GROUP'
       end,
       case bitand(c.defer,64) when 64 then 'ALWAYS'
                               else  'CONDITIONAL'
       end,
       case bitand(c.defer,8) when 8 then 'GENERATED NAME'
                              else  'USER NAME'
       end
from sys.con$ oc,  sys.user$ ou,
     sys.obj$ o, sys.cdef$ c
where oc.owner# = ou.user#
  and oc.con# = c.con#
  and c.obj# = o.obj#
  and
  (c.type# = 12 or c.type# = 14 or
   c.type# = 15 or c.type# = 16 or
   c.type# = 17)
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in (select obj#
                     from sys.objauth$
                     where grantee# in ( select kzsrorol
                                         from x$kzsro
                                       )
                    )
        or /* user has system privileges */
          exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */)
                  )
      )
/
comment on table ALL_LOG_GROUPS is
'Log group definitions on accessible tables'
/
comment on column ALL_LOG_GROUPS.OWNER is
'Owner of the table'
/
comment on column ALL_LOG_GROUPS.LOG_GROUP_NAME is
'Name associated with log group definition'
/
comment on column USER_LOG_GROUPS.TABLE_NAME is
'Name of the table on which this log group is defined'
/
comment on column USER_LOG_GROUPS.LOG_GROUP_TYPE is
'Type of the log group'
/
comment on column ALL_LOG_GROUPS.ALWAYS is
'Is this an ALWAYS or a CONDITIONAL supplemental log group?'
/
comment on column ALL_LOG_GROUPS.GENERATED is
'Was the name of this supplemental log group system generated?'
/
grant select on ALL_LOG_GROUPS to public with grant option
/
create or replace public synonym ALL_LOG_GROUPS for ALL_LOG_GROUPS
/
create or replace view DBA_LOG_GROUPS
    (OWNER, LOG_GROUP_NAME, TABLE_NAME, LOG_GROUP_TYPE, ALWAYS, GENERATED)
as
select ou.name, oc.name, o.name,
       case c.type# when 14 then 'PRIMARY KEY LOGGING'
                    when 15 then 'UNIQUE KEY LOGGING'
                    when 16 then 'FOREIGN KEY LOGGING'
                    when 17 then 'ALL COLUMN LOGGING'
                    else 'USER LOG GROUP'
       end,
       case bitand(c.defer,64) when 64 then 'ALWAYS'
                               else  'CONDITIONAL'
       end,
       case bitand(c.defer,8) when 8 then 'GENERATED NAME'
                              else  'USER NAME'
       end
from sys.con$ oc, sys.user$ ou, sys.obj$ o, sys.cdef$ c
where oc.owner# = ou.user#
  and oc.con# = c.con#
  and c.obj# = o.obj#
  and
  (c.type# = 12 or c.type# = 14 or
   c.type# = 15 or c.type# = 16 or
   c.type# = 17)
/

comment on column DBA_LOG_GROUPS.GENERATED is
'Was the name of this supplemental log group system generated?'
/
create or replace public synonym DBA_LOG_GROUPS for DBA_LOG_GROUPS
/
grant select on DBA_LOG_GROUPS to select_catalog_role
/
comment on table DBA_LOG_GROUPS is
'Log group definitions on all tables'
/
comment on column DBA_LOG_GROUPS.OWNER is
'Owner of the table'
/
comment on column DBA_LOG_GROUPS.LOG_GROUP_NAME is
'Name associated with log group definition'
/
comment on column USER_LOG_GROUPS.TABLE_NAME is
'Name of the table on which this log group is defined'
/
comment on column USER_LOG_GROUPS.LOG_GROUP_TYPE is
'Type of the log group'
/
comment on column DBA_LOG_GROUPS.ALWAYS is
'Is this an ALWAYS or a CONDITIONAL supplemental log group?'
/
comment on column ALL_LOG_GROUPS.GENERATED is
'Was the name of this supplemental log group system generated?'
/


remark
remark FAMILY CLUSTER_HASH_EXPRESSIONS
remark
create or replace view USER_CLUSTER_HASH_EXPRESSIONS
    (OWNER, CLUSTER_NAME, HASH_EXPRESSION)
as
select us.name, o.name, c.condition
from sys.cdef$ c, sys.user$ us, sys.obj$ o
where c.type#   = 8
and   c.obj#   = o.obj#
and   us.user# = o.owner#
and   us.user# = userenv('SCHEMAID')
/

comment on table USER_CLUSTER_HASH_EXPRESSIONS is
'Hash functions for the user''s hash clusters'
/
comment on column USER_CLUSTER_HASH_EXPRESSIONS.OWNER is
'Name of owner of cluster'
/
comment on column USER_CLUSTER_HASH_EXPRESSIONS.CLUSTER_NAME is
'Name of cluster'
/
comment on column USER_CLUSTER_HASH_EXPRESSIONS.HASH_EXPRESSION is
'Text of hash function of cluster'
/
grant select on USER_CLUSTER_HASH_EXPRESSIONS to public with grant option
/
create or replace public synonym USER_CLUSTER_HASH_EXPRESSIONS for
 USER_CLUSTER_HASH_EXPRESSIONS
/

create or replace view ALL_CLUSTER_HASH_EXPRESSIONS
    (OWNER, CLUSTER_NAME, HASH_EXPRESSION)
as
select us.name, o.name, c.condition
from sys.cdef$ c, sys.user$ us, sys.obj$ o
where c.type#   = 8
and   c.obj#   = o.obj#
and   us.user# = o.owner#
and   ( us.user# = userenv('SCHEMAID')
        or  /* user has system privilages */
           exists (select null from v$enabledprivs
               where priv_number in (-61 /* CREATE ANY CLUSTER */,
                                     -62 /* ALTER ANY CLUSTER */,
                                     -63 /* DROP ANY CLUSTER */ )
                  )
      )
/

comment on table ALL_CLUSTER_HASH_EXPRESSIONS is
'Hash functions for all accessible clusters'
/
comment on column ALL_CLUSTER_HASH_EXPRESSIONS.OWNER is
'Name of owner of cluster'
/
comment on column ALL_CLUSTER_HASH_EXPRESSIONS.CLUSTER_NAME is
'Name of cluster'
/
comment on column ALL_CLUSTER_HASH_EXPRESSIONS.HASH_EXPRESSION is
'Text of hash function of cluster'
/
grant select on ALL_CLUSTER_HASH_EXPRESSIONS to public with grant option
/
create or replace public synonym ALL_CLUSTER_HASH_EXPRESSIONS for
 ALL_CLUSTER_HASH_EXPRESSIONS
/

create or replace view DBA_CLUSTER_HASH_EXPRESSIONS
    (OWNER, CLUSTER_NAME, HASH_EXPRESSION)
as
select us.name, o.name, c.condition
from sys.cdef$ c, sys.user$ us, sys.obj$ o
where c.type# = 8
and c.obj#   = o.obj#
and us.user# = o.owner#
/

comment on table DBA_CLUSTER_HASH_EXPRESSIONS is
'Hash functions for all clusters'
/
comment on column DBA_CLUSTER_HASH_EXPRESSIONS.OWNER is
'Name of owner of cluster'
/
comment on column DBA_CLUSTER_HASH_EXPRESSIONS.CLUSTER_NAME is
'Text of hash function of the cluster'
/
comment on column DBA_CLUSTER_HASH_EXPRESSIONS.HASH_EXPRESSION is
'Text of hash function of cluster'
/
create or replace public synonym DBA_CLUSTER_HASH_EXPRESSIONS for
 DBA_CLUSTER_HASH_EXPRESSIONS
/
grant select on DBA_CLUSTER_HASH_EXPRESSIONS to select_catalog_role
/

remark
remark  FAMILY "CONS_COLUMNS"
remark
create or replace view USER_CONS_COLUMNS
    (OWNER, CONSTRAINT_NAME, TABLE_NAME, COLUMN_NAME, POSITION)
as
select u.name, c.name, o.name,
       decode(ac.name, null, col.name, ac.name), cc.pos#
from sys.user$ u, sys.con$ c, sys.col$ col, sys.ccol$ cc, sys.cdef$ cd,
     sys.obj$ o, sys.attrcol$ ac
where c.owner# = u.user#
  and c.con# = cd.con#
  and cd.type# != 12       /* don't include log groups */
  and cd.con# = cc.con#
  and cc.obj# = col.obj#
  and cc.intcol# = col.intcol#
  and cc.obj# = o.obj#
  and c.owner# = userenv('SCHEMAID')
  and col.obj# = ac.obj#(+)
  and col.intcol# = ac.intcol#(+)
/
comment on table USER_CONS_COLUMNS is
'Information about accessible columns in constraint definitions'
/
comment on column USER_CONS_COLUMNS.OWNER is
'Owner of the constraint definition'
/
comment on column USER_CONS_COLUMNS.CONSTRAINT_NAME is
'Name associated with the constraint definition'
/
comment on column USER_CONS_COLUMNS.TABLE_NAME is
'Name associated with table with constraint definition'
/
comment on column USER_CONS_COLUMNS.COLUMN_NAME is
'Name associated with column or attribute of object column specified in the constraint definition'
/
comment on column USER_CONS_COLUMNS.POSITION is
'Original position of column or attribute in definition'
/
grant select on USER_CONS_COLUMNS to public with grant option
/
create or replace public synonym USER_CONS_COLUMNS for USER_CONS_COLUMNS
/
create or replace view ALL_CONS_COLUMNS
    (OWNER, CONSTRAINT_NAME, TABLE_NAME, COLUMN_NAME, POSITION)
as
select u.name, c.name, o.name,
       decode(ac.name, null, col.name, ac.name), cc.pos#
from sys.user$ u, sys.con$ c, sys.col$ col, sys.ccol$ cc, sys.cdef$ cd,
     sys.obj$ o, sys.attrcol$ ac
where c.owner# = u.user#
  and c.con# = cd.con#
  and cd.type# != 12       /* don't include log groups */
  and cd.con# = cc.con#
  and cc.obj# = col.obj#
  and cc.intcol# = col.intcol#
  and cc.obj# = o.obj#
  and (c.owner# = userenv('SCHEMAID')
       or cd.obj# in (select obj#
                      from sys.objauth$
                      where grantee# in ( select kzsrorol
                                         from x$kzsro
                                       )
                     )
        or /* user has system privileges */
          exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */)
                  )
      )
  and col.obj# = ac.obj#(+)
  and col.intcol# = ac.intcol#(+)
/
comment on table ALL_CONS_COLUMNS is
'Information about accessible columns in constraint definitions'
/
comment on column ALL_CONS_COLUMNS.OWNER is
'Owner of the constraint definition'
/
comment on column ALL_CONS_COLUMNS.CONSTRAINT_NAME is
'Name associated with the constraint definition'
/
comment on column ALL_CONS_COLUMNS.TABLE_NAME is
'Name associated with table with constraint definition'
/
comment on column ALL_CONS_COLUMNS.COLUMN_NAME is
'Name associated with column or attribute of object column specified in the constraint definition'
/
comment on column ALL_CONS_COLUMNS.POSITION is
'Original position of column or attribute in definition'
/
grant select on ALL_CONS_COLUMNS to public with grant option
/
create or replace public synonym ALL_CONS_COLUMNS for ALL_CONS_COLUMNS
/
create or replace view DBA_CONS_COLUMNS
    (OWNER, CONSTRAINT_NAME, TABLE_NAME, COLUMN_NAME, POSITION)
as
select u.name, c.name, o.name,
       decode(ac.name, null, col.name, ac.name), cc.pos#
from sys.user$ u, sys.con$ c, sys.col$ col, sys.ccol$ cc, sys.cdef$ cd,
     sys.obj$ o, sys.attrcol$ ac
where c.owner# = u.user#
  and c.con# = cd.con#
  and cd.type# != 12       /* don't include log groups */
  and cd.con# = cc.con#
  and cc.obj# = col.obj#
  and cc.intcol# = col.intcol#
  and cc.obj# = o.obj#
  and col.obj# = ac.obj#(+)
  and col.intcol# = ac.intcol#(+)
/
create or replace public synonym DBA_CONS_COLUMNS for DBA_CONS_COLUMNS
/
grant select on DBA_CONS_COLUMNS to select_catalog_role
/
comment on table DBA_CONS_COLUMNS is
'Information about accessible columns in constraint definitions'
/
comment on column DBA_CONS_COLUMNS.OWNER is
'Owner of the constraint definition'
/
comment on column DBA_CONS_COLUMNS.CONSTRAINT_NAME is
'Name associated with the constraint definition'
/
comment on column DBA_CONS_COLUMNS.TABLE_NAME is
'Name associated with table with constraint definition'
/
comment on column DBA_CONS_COLUMNS.COLUMN_NAME is
'Name associated with column or attribute of object column specified in the constraint definition'
/
comment on column DBA_CONS_COLUMNS.POSITION is
'Original position of column or attribute in definition'
/

remark
remark  FAMILY "LOG_GROUP_COLUMNS"
remark
create or replace view USER_LOG_GROUP_COLUMNS
    (OWNER, LOG_GROUP_NAME, TABLE_NAME, COLUMN_NAME, POSITION,LOGGING_PROPERTY)
as
select u.name, c.name, o.name,
       decode(ac.name, null, col.name, ac.name), cc.pos#,
       decode(cc.spare1, 1, 'NO LOG', 'LOG')
from sys.user$ u, sys.con$ c, sys.col$ col, sys.ccol$ cc, sys.cdef$ cd,
     sys.obj$ o, sys.attrcol$ ac
where c.owner# = u.user#
  and c.con# = cd.con#
  and cd.type# = 12
  and cd.con# = cc.con#
  and cc.obj# = col.obj#
  and cc.intcol# = col.intcol#
  and cc.obj# = o.obj#
  and c.owner# = userenv('SCHEMAID')
  and col.obj# = ac.obj#(+)
  and col.intcol# = ac.intcol#(+)
/
comment on table USER_LOG_GROUP_COLUMNS is
'Information about columns in log group definitions'
/
comment on column USER_LOG_GROUP_COLUMNS.OWNER is
'Owner of the log group definition'
/
comment on column USER_LOG_GROUP_COLUMNS.LOG_GROUP_NAME is
'Name associated with the log group definition'
/
comment on column USER_LOG_GROUP_COLUMNS.TABLE_NAME is
'Name associated with table with log group definition'
/
comment on column USER_LOG_GROUP_COLUMNS.COLUMN_NAME is
'Name associated with column or attribute of object column specified in the log group definition'
/
comment on column USER_LOG_GROUP_COLUMNS.POSITION is
'Original position of column or attribute in definition'
/
comment on column USER_LOG_GROUP_COLUMNS.LOGGING_PROPERTY is
'Whether the column or attribute would be supplementally logged'
/
grant select on USER_LOG_GROUP_COLUMNS to public with grant option
/
create or replace public synonym USER_LOG_GROUP_COLUMNS
   for USER_LOG_GROUP_COLUMNS
/
create or replace view ALL_LOG_GROUP_COLUMNS
   (OWNER, LOG_GROUP_NAME, TABLE_NAME, COLUMN_NAME, POSITION,LOGGING_PROPERTY)
as
select u.name, c.name, o.name,
       decode(ac.name, null, col.name, ac.name), cc.pos#,
       decode(cc.spare1, 1, 'NO LOG', 'LOG')
from sys.user$ u, sys.con$ c, sys.col$ col, sys.ccol$ cc, sys.cdef$ cd,
     sys.obj$ o, sys.attrcol$ ac
where c.owner# = u.user#
  and c.con# = cd.con#
  and cd.type# = 12
  and cd.con# = cc.con#
  and cc.obj# = col.obj#
  and cc.intcol# = col.intcol#
  and cc.obj# = o.obj#
  and (c.owner# = userenv('SCHEMAID')
       or cd.obj# in (select obj#
                      from sys.objauth$
                      where grantee# in ( select kzsrorol
                                         from x$kzsro
                                       )
                     )
        or /* user has system privileges */
          exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */)
                  )
      )
  and col.obj# = ac.obj#(+)
  and col.intcol# = ac.intcol#(+)
/
comment on table ALL_LOG_GROUP_COLUMNS is
'Information about columns in log group definitions'
/
comment on column ALL_LOG_GROUP_COLUMNS.OWNER is
'Owner of the log group definition'
/
comment on column ALL_LOG_GROUP_COLUMNS.LOG_GROUP_NAME is
'Name associated with the log group definition'
/
comment on column ALL_LOG_GROUP_COLUMNS.TABLE_NAME is
'Name associated with table with log group definition'
/
comment on column ALL_LOG_GROUP_COLUMNS.COLUMN_NAME is
'Name associated with column or attribute of object column specified in the log group definition'
/
comment on column ALL_LOG_GROUP_COLUMNS.POSITION is
'Original position of column or attribute in definition'
/
comment on column ALL_LOG_GROUP_COLUMNS.LOGGING_PROPERTY is
'Whether the column or attribute would be supplementally logged'
/

grant select on ALL_LOG_GROUP_COLUMNS to public with grant option
/
create or replace public synonym ALL_LOG_GROUP_COLUMNS
   for ALL_LOG_GROUP_COLUMNS
/
create or replace view DBA_LOG_GROUP_COLUMNS
   (OWNER, LOG_GROUP_NAME, TABLE_NAME, COLUMN_NAME, POSITION,LOGGING_PROPERTY)
as
select u.name, c.name, o.name,
       decode(ac.name, null, col.name, ac.name), cc.pos#,
       decode(cc.spare1, 1, 'NO LOG', 'LOG')
from sys.user$ u, sys.con$ c, sys.col$ col, sys.ccol$ cc, sys.cdef$ cd,
     sys.obj$ o, sys.attrcol$ ac
where c.owner# = u.user#
  and c.con# = cd.con#
  and cd.type# = 12
  and cd.con# = cc.con#
  and cc.obj# = col.obj#
  and cc.intcol# = col.intcol#
  and cc.obj# = o.obj#
  and col.obj# = ac.obj#(+)
  and col.intcol# = ac.intcol#(+)
/
create or replace public synonym DBA_LOG_GROUP_COLUMNS
   for DBA_LOG_GROUP_COLUMNS
/
grant select on DBA_LOG_GROUP_COLUMNS to select_catalog_role
/
comment on table DBA_LOG_GROUP_COLUMNS is
'Information about columns in log group definitions'
/
comment on column DBA_LOG_GROUP_COLUMNS.OWNER is
'Owner of the log group definition'
/
comment on column DBA_LOG_GROUP_COLUMNS.LOG_GROUP_NAME is
'Name associated with the log group definition'
/
comment on column DBA_LOG_GROUP_COLUMNS.TABLE_NAME is
'Name associated with table with log group definition'
/
comment on column DBA_LOG_GROUP_COLUMNS.COLUMN_NAME is
'Name associated with column or attribute of object column specified in the log group definition'
/
comment on column DBA_LOG_GROUP_COLUMNS.POSITION is
'Original position of column or attribute in definition'
/
comment on column DBA_LOG_GROUP_COLUMNS.LOGGING_PROPERTY is
'Whether the column or attribute would be supplementally logged'
/

remark
remark  FAMILY "NLS"
remark

create or replace view NLS_SESSION_PARAMETERS (PARAMETER, VALUE) as
select substr(parameter, 1, 30),
       substr(value, 1, 40)
from v$nls_parameters
where parameter != 'NLS_CHARACTERSET' and
 parameter != 'NLS_NCHAR_CHARACTERSET'
/
comment on table NLS_SESSION_PARAMETERS is
'NLS parameters of the user session'
/
comment on column NLS_SESSION_PARAMETERS.PARAMETER is
'Parameter name'
/
comment on column NLS_SESSION_PARAMETERS.VALUE is
'Parameter value'
/
create or replace public synonym NLS_SESSION_PARAMETERS
   for NLS_SESSION_PARAMETERS
/
grant select on NLS_SESSION_PARAMETERS to PUBLIC with grant option
/
create or replace view NLS_INSTANCE_PARAMETERS (PARAMETER, VALUE) as
select substr(upper(name), 1, 30),
       substr(value, 1, 40)
from v$parameter
where name like 'nls%'
/
comment on table NLS_INSTANCE_PARAMETERS is
'NLS parameters of the instance'
/
comment on column NLS_INSTANCE_PARAMETERS.PARAMETER is
'Parameter name'
/
comment on column NLS_INSTANCE_PARAMETERS.VALUE is
'Parameter value'
/
create or replace public synonym NLS_INSTANCE_PARAMETERS
   for NLS_INSTANCE_PARAMETERS
/
grant select on NLS_INSTANCE_PARAMETERS to PUBLIC with grant option
/
create or replace view NLS_DATABASE_PARAMETERS (PARAMETER, VALUE) as
select name,
       substr(value$, 1, 40)
from props$
where name like 'NLS%'
/
comment on table NLS_DATABASE_PARAMETERS is
'Permanent NLS parameters of the database'
/
comment on column NLS_DATABASE_PARAMETERS.PARAMETER is
'Parameter name'
/
comment on column NLS_DATABASE_PARAMETERS.VALUE is
'Parameter value'
/
create or replace public synonym NLS_DATABASE_PARAMETERS
   for NLS_DATABASE_PARAMETERS
/
grant select on NLS_DATABASE_PARAMETERS to PUBLIC with grant option
/

rem
rem family "DATABASE"
rem
create or replace view DATABASE_COMPATIBLE_LEVEL
    (value, description)
  as
select value,description
from v$parameter
where name = 'compatible'
/
comment on table DATABASE_COMPATIBLE_LEVEL is
'Database compatible parameter set via init.ora'
/
comment on column DATABASE_COMPATIBLE_LEVEL.VALUE is
'Parameter value'
/
comment on column DATABASE_COMPATIBLE_LEVEL.DESCRIPTION is
'Description of value'
/
create or replace public synonym DATABASE_COMPATIBLE_LEVEL
   for DATABASE_COMPATIBLE_LEVEL
/
grant select on DATABASE_COMPATIBLE_LEVEL to PUBLIC with grant option
/

create or replace view DATABASE_PROPERTIES
  (PROPERTY_NAME, PROPERTY_VALUE, DESCRIPTION)
as
  select name, value$, comment$
  from props$
/
comment on table DATABASE_PROPERTIES is
'Permanent database properties'
/
comment on column DATABASE_PROPERTIES.PROPERTY_NAME is
'Property name'
/
comment on column DATABASE_PROPERTIES.PROPERTY_VALUE is
'Property value'
/
comment on column DATABASE_PROPERTIES.DESCRIPTION is
'Property description'
/
create or replace public synonym DATABASE_PROPERTIES for DATABASE_PROPERTIES
/
grant select on DATABASE_PROPERTIES to PUBLIC with grant option
/

rem
rem V5 views required for other Oracle products
rem

create or replace view syscatalog_
    (tname, creator, creatorid, tabletype, remarks)
  as
  select o.name, u.name, o.owner#,
         decode(o.type#, 2, 'TABLE', 4, 'VIEW', 6, 'SEQUENCE','?'), c.comment$
  from  sys.user$ u, sys.obj$ o, sys.com$ c
  where u.user# = o.owner#
  and (o.type# in (4, 6)                                    /* view, sequence */
       or
       (o.type# = 2     /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192))))
    and o.linkname is null
    and o.obj# = c.obj#(+)
    and ( o.owner# = userenv('SCHEMAID')
          or o.obj# in
             (select oa.obj#
              from   sys.objauth$ oa
              where  oa.grantee# in (userenv('SCHEMAID'), 1)
              )
          or
          (
            (o.type# in (4)                                           /* view */
             or
             (o.type# = 2 /* tables, excluding iot-overflow and nested tables */
              and
              not exists (select null
                            from sys.tab$ t
                           where t.obj# = o.obj#
                             and (bitand(t.property, 512) = 512 or
                                  bitand(t.property, 8192) = 8192))))
          and
          exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */)
                  )
           )
          or
         ( o.type# = 6 /* sequence */
           and
           exists (select null from v$enabledprivs
                   where priv_number = -109 /* SELECT ANY SEQUENCE */)
         )
       )
/
grant select on syscatalog_ to select_catalog_role
/
create or replace view syscatalog (tname, creator, tabletype, remarks) as
  select tname, creator, tabletype, remarks
  from syscatalog_
/
grant select on syscatalog to public with grant option;
create or replace synonym system.syscatalog for syscatalog;
rem
rem The catalog view returns almost all tables accessible to the user
rem except tables in SYS and SYSTEM ("dictionary tables").
rem
create or replace view catalog (tname, creator, tabletype, remarks) as
  select tname, creator, tabletype, remarks
  from  syscatalog_
  where creatorid not in (select user# from sys.user$ where name in
        ('SYS','SYSTEM'))
/
grant select on catalog to public with grant option;
create or replace synonym system.catalog for catalog;

create or replace view tab (tname, tabtype, clusterid) as
   select o.name,
      decode(o.type#, 2, 'TABLE', 3, 'CLUSTER',
             4, 'VIEW', 5, 'SYNONYM'), t.tab#
  from  sys.tab$ t, sys.obj$ o
  where o.owner# = userenv('SCHEMAID')
  and o.type# >=2
  and o.type# <=5
  and o.linkname is null
  and o.obj# = t.obj# (+)
/
grant select on tab to public with grant option;
create or replace synonym system.tab for tab;
create or replace public synonym tab for tab;
create or replace view col
  (tname, colno, cname, coltype, width, scale, precision, nulls, defaultval,
   character_set_name) as
  select t.name, c.col#, c.name,
         decode(c.type#, 1, decode(c.charsetform, 2, 'NVARCHAR2', 'VARCHAR2'),
                         2, decode(c.scale, null,
                                   decode(c.precision#, null, 'NUMBER', 'FLOAT'),
                                  'NUMBER'),
                         8, 'LONG',
                         9, decode(c.charsetform, 2, 'NCHAR VARYING', 'VARCHAR'),
                         12, 'DATE',
                         23, 'RAW', 24, 'LONG RAW',
                         69, 'ROWID',
                         96, decode(c.charsetform, 2, 'NCHAR', 'CHAR'),
                         100, 'BINARY_FLOAT',
                         101, 'BINARY_DOUBLE',
                         105, 'MLSLABEL',
                         106, 'MLSLABEL',
                         111, 'REF '||'"'||ut.name||'"'||'.'||'"'||ot.name||'"',
                         112, decode(c.charsetform, 2, 'NCLOB', 'CLOB'),
                         113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
                         121, '"'||ut.name||'"'||'.'||'"'||ot.name||'"',
                         122, '"'||ut.name||'"'||'.'||'"'||ot.name||'"',
                         123, '"'||ut.name||'"'||'.'||'"'||ot.name||'"',
                         178, 'TIME(' ||c.scale|| ')',
                         179, 'TIME(' ||c.scale|| ')' || ' WITH TIME ZONE',
                         180, 'TIMESTAMP(' ||c.scale|| ')',
                         181, 'TIMESTAMP(' ||c.scale|| ')'||' WITH TIME ZONE',
                         231, 'TIMESTAMP(' ||c.scale|| ')'||' WITH LOCAL TIME ZONE',
                         182, 'INTERVAL YEAR(' ||c.precision#||') TO MONTH',
                         183, 'INTERVAL DAY(' ||c.precision#||') TO SECOND(' ||
                               c.scale || ')',
                         208, 'UROWID',
                         'UNDEFINED'),
         c.length, c.scale, c.precision#,
         decode(sign(c.null$),-1,'NOT NULL - DISABLED', 0, 'NULL',
        'NOT NULL'), c.default$,
         decode(c.charsetform, 1, 'CHAR_CS',
                               2, 'NCHAR_CS',
                               3, NLS_CHARSET_NAME(c.charsetid),
                               4, 'ARG:'||c.charsetid)
  from  sys.col$ c, sys.obj$ t, sys.coltype$ ac, sys.obj$ ot, sys.user$ ut
  where t.obj# = c.obj#
  and   t.type# in (2, 3, 4)
  and   t.owner# = userenv('SCHEMAID')
  and   bitand(c.property, 32) = 0 /* not hidden column */
  and   c.obj# = ac.obj#(+)
  and   c.intcol# = ac.intcol#(+)
  and   ac.toid = ot.oid$(+)
  and   ot.owner# = ut.user#(+)
/
grant select on col to public with grant option;
create or replace synonym system.col for col;
create or replace public synonym col for col;
create or replace view syssegobj
    (obj#, file#, block#, type, pctfree$, pctused$) as
  select obj#,
       decode(bitand(property, 32+64), 0, file#, to_number(null)),
       decode(bitand(property, 32+64), 0, block#, to_number(null)),
       'TABLE',
       decode(bitand(property, 32+64), 0, mod(pctfree$, 100), to_number(null)),
       decode(bitand(property, 32+64), 0, pctused$, to_number(null))
  from sys.tab$
  union all
  select obj#, file#, block#, 'CLUSTER', pctfree$, pctused$ from sys.clu$
  union all
  select obj#, file#, block#, 'INDEX', to_number(null), to_number(null)
         from sys.ind$
/
grant select on syssegobj to public with grant option;
create or replace view tabquotas (tname, type, objno, nextext, maxext, pinc,
                       pfree, pused) as
  select t.name, so.type, t.obj#,
  decode(bitand(ts.flags, 3), 1, to_number(NULL),
                                s.extsize * ts.blocksize),
  s.maxexts,
  decode(bitand(ts.flags, 3), 1, to_number(NULL),
                                      s.extpct),
  so.pctfree$, decode(bitand(ts.flags, 32), 32, to_number(NULL), so.pctused$)
  from  sys.ts$ ts, sys.seg$ s, sys.obj$ t, syssegobj so
  where t.owner# = userenv('SCHEMAID')
  and   t.obj# = so.obj#
  and   so.file# = s.file#
  and   so.block# = s.block#
  and   s.ts# = ts.ts#
/
grant select on tabquotas to public with grant option;
create or replace synonym system.tabquotas for tabquotas;

rem ### do we need to fix this for bitmapped tablespaces
create or replace view sysfiles (tsname, fname, blocks) as
  select ts.name, dbf.name, f.blocks
  from  sys.ts$ ts, sys.file$ f, sys.v$dbfile dbf
  where ts.ts# = f.ts#(+) and dbf.file# = f.file# and f.status$ = 2
/
grant select on sysfiles to public with grant option;
create or replace synonym system.sysfiles for sysfiles;
create or replace view synonyms
    (sname, syntype, creator, tname, database, tabtype) as
  select s.name,
         decode(s.owner#,1,'PUBLIC','PRIVATE'), t.owner, t.name, 'LOCAL',
         decode(ot.type#, 1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER', 4, 'VIEW',
                         5, 'SYNONYM', 6, 'SEQUENCE', 7, 'PROCEDURE',
                         8, 'FUNCTION', 9, 'PACKAGE', 22, 'LIBRARY',
                         29, 'JAVA CLASS', 'UNDEFINED')
  from  sys.obj$ s, sys.obj$ ot, sys.syn$ t, sys.user$ u
  where s.obj# = t.obj#
    and ot.linkname is null
    and s.type# = 5
    and ot.name = t.name
    and t.owner = u.name
    and ot.owner# = u.user#
    and s.owner# in (1,userenv('SCHEMAID'))
    and t.node is null
union all
  select s.name, decode(s.owner#, 1, 'PUBLIC', 'PRIVATE'),
         t.owner, t.name, t.node, 'REMOTE'
  from  sys.obj$ s, sys.syn$ t
  where s.obj# = t.obj#
    and s.type# = 5
    and s.owner# in (1, userenv('SCHEMAID'))
    and t.node is not null
/
grant select on synonyms to public with grant option;
create or replace view publicsyn (sname, creator, tname, database, tabtype) as
  select sname, creator, tname, database, tabtype
  from  synonyms
  where syntype = 'PUBLIC'
/
grant select on publicsyn to public with grant option;
create or replace synonym system.publicsyn for publicsyn;

rem
rem V6 views required for other Oracle products
rem

create or replace view TABLE_PRIVILEGES
      (GRANTEE, OWNER, TABLE_NAME, GRANTOR,
       SELECT_PRIV, INSERT_PRIV, DELETE_PRIV,
       UPDATE_PRIV, REFERENCES_PRIV, ALTER_PRIV, INDEX_PRIV,
       CREATED)
as
select ue.name, u.name, o.name, ur.name,
    decode(substr(lpad(sum(power(10, privilege#*2) +
      decode(mod(option$,2), 1, power(10, privilege#*2 + 1), 0)), 26, '0'), 7, 2),
      '00', 'N', '01', 'Y', '11', 'G', 'N'),
     decode(substr(lpad(sum(decode(col#, null, power(10, privilege#*2) +
       decode(mod(option$,2), 1, power(10, privilege#*2 + 1), 0), 0)), 26, '0'),
              13, 2), '01', 'A', '11', 'G',
          decode(sum(decode(col#,
                            null, 0,
                            decode(privilege#, 6, 1, 0))), 0, 'N', 'S')),
    decode(substr(lpad(sum(power(10, privilege#*2) +
      decode(mod(option$,2), 1, power(10, privilege#*2 + 1), 0)), 26, '0'), 19, 2),
      '00', 'N', '01', 'Y', '11', 'G', 'N'),
    decode(substr(lpad(sum(decode(col#, null, power(10, privilege#*2) +
      decode(mod(option$,2), 1, power(10, privilege#*2 + 1), 0), 0)), 26, '0'),
             5, 2),'01', 'A', '11', 'G',
          decode(sum(decode(col#,
                            null, 0,
                            decode(privilege#, 10, 1, 0))), 0, 'N', 'S')),
    decode(substr(lpad(sum(decode(col#, null, power(10, privilege#*2) +
      decode(mod(option$,2), 1, power(10, privilege#*2 + 1), 0), 0)), 26, '0'),
             3, 2), '01', 'A', '11', 'G',
          decode(sum(decode(col#,
                            null, 0,
                            decode(privilege#, 11, 1, 0))), 0, 'N', 'S')),
   decode(substr(lpad(sum(power(10, privilege#*2) +
      decode(mod(option$,2), 1, power(10, privilege#*2 + 1), 0)), 26, '0'), 25, 2),
      '00', 'N', '01', 'Y', '11', 'G', 'N'),
    decode(substr(lpad(sum(power(10, privilege#*2) +
      decode(mod(option$,2), 1, power(10, privilege#*2 + 1), 0)), 26, '0'), 15, 2),
      '00', 'N', '01', 'Y', '11', 'G', 'N'), min(null)
from sys.objauth$ oa, sys.obj$ o, sys.user$ ue, sys.user$ ur, sys.user$ u
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and u.user# = o.owner#
  and (oa.grantor# = userenv('SCHEMAID') or
       oa.grantee# in (select kzsrorol from x$kzsro) or
       o.owner# = userenv('SCHEMAID'))
  group by u.name, o.name, ur.name, ue.name
/
comment on table TABLE_PRIVILEGES is
'Grants on objects for which the user is the grantor, grantee, owner,
 or an enabled role or PUBLIC is the grantee'
/
comment on column TABLE_PRIVILEGES.GRANTEE is
'Name of the user to whom access was granted'
/
comment on column TABLE_PRIVILEGES.OWNER is
'Owner of the object'
/
comment on column TABLE_PRIVILEGES.TABLE_NAME is
'Name of the object'
/
comment on column TABLE_PRIVILEGES.GRANTOR is
'Name of the user who performed the grant'
/
comment on column TABLE_PRIVILEGES.SELECT_PRIV is
'Permission to SELECT from the object?'
/
comment on column TABLE_PRIVILEGES.INSERT_PRIV is
'Permission to INSERT into the object?'
/
comment on column TABLE_PRIVILEGES.DELETE_PRIV is
'Permission to DELETE from the object?'
/
comment on column TABLE_PRIVILEGES.UPDATE_PRIV is
'Permission to UPDATE the object?'
/
comment on column TABLE_PRIVILEGES.REFERENCES_PRIV is
'Permission to make REFERENCES to the object?'
/
comment on column TABLE_PRIVILEGES.ALTER_PRIV is
'Permission to ALTER the object?'
/
comment on column TABLE_PRIVILEGES.INDEX_PRIV is
'Permission to create/drop an INDEX on the object?'
/
comment on column TABLE_PRIVILEGES.CREATED is
'Timestamp for the grant'
/
create or replace public synonym TABLE_PRIVILEGES for TABLE_PRIVILEGES
/
grant select on TABLE_PRIVILEGES to PUBLIC
/
create or replace view COLUMN_PRIVILEGES
      (GRANTEE, OWNER, TABLE_NAME, COLUMN_NAME, GRANTOR,
       INSERT_PRIV, UPDATE_PRIV, REFERENCES_PRIV,
       CREATED)
as
select ue.name, u.name, o.name, c.name, ur.name,
    decode(substr(lpad(sum(power(10, privilege#*2) +
      decode(mod(option$,2), 1, power(10, privilege#*2 + 1), 0)), 26, '0'), 13, 2),
      '00', 'N', '01', 'Y', '11', 'G', 'N'),
    decode(substr(lpad(sum(power(10, privilege#*2) +
      decode(mod(option$,2), 1, power(10, privilege#*2 + 1), 0)), 26, '0'), 5, 2),
      '00', 'N', '01', 'Y', '11', 'G', 'N'),
    decode(substr(lpad(sum(power(10, privilege#*2) +
      decode(mod(option$,2), 1, power(10, privilege#*2 + 1), 0)), 26, '0'), 3, 2),
      '00', 'N', '01', 'Y', '11', 'G', 'N'), min(null)
from sys.objauth$ oa, sys.col$ c,sys.obj$ o, sys.user$ ue, sys.user$ ur,
     sys.user$ u
where oa.col# is not null
  and oa.obj# = c.obj#
  and oa.col# = c.col#
  and bitand(c.property, 32) = 0 /* not hidden column */
  and oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and u.user# = o.owner#
  and (oa.grantor# = userenv('SCHEMAID') or
       oa.grantee# in (select kzsrorol from x$kzsro) or
       o.owner# = userenv('SCHEMAID'))
  group by u.name, o.name, c.name, ur.name, ue.name
/
comment on table COLUMN_PRIVILEGES is
'Grants on columns for which the user is the grantor, grantee, owner, or
 an enabled role or PUBLIC is the grantee'
/
comment on column COLUMN_PRIVILEGES.GRANTEE is
'Name of the user to whom access was granted'
/
comment on column COLUMN_PRIVILEGES.OWNER is
'Username of the owner of the object'
/
comment on column COLUMN_PRIVILEGES.TABLE_NAME is
'Name of the object'
/
comment on column COLUMN_PRIVILEGES.COLUMN_NAME is
'Name of the column'
/
comment on column COLUMN_PRIVILEGES.GRANTOR is
'Name of the user who performed the grant'
/
comment on column COLUMN_PRIVILEGES.INSERT_PRIV is
'Permission to INSERT into the column?'
/
comment on column COLUMN_PRIVILEGES.UPDATE_PRIV is
'Permission to UPDATE the column?'
/
comment on column COLUMN_PRIVILEGES.REFERENCES_PRIV is
'Permission to make REFERENCES to the column?'
/
comment on column COLUMN_PRIVILEGES.CREATED is
'Timestamp for the grant'
/
create or replace public synonym COLUMN_PRIVILEGES for COLUMN_PRIVILEGES
/
grant select on COLUMN_PRIVILEGES to PUBLIC
/

rem     **********************************************************************
rem             DBA TWO PHASE COMMIT DECISION / DAMAGE ASSESSMENT TABLES
rem     **********************************************************************
rem     PSS1$: used to add user name column to pending_sub_sessions$
create or replace view pss1$ as
select  pss.*, u.name owner_name
from    sys.pending_sub_sessions$ pss, sys.user$ u
where   pss.link_owner = u.user#;
grant select on pss1$ to select_catalog_role;

rem     PS1$: used to add user name column to pending_sessions$
create or replace view ps1$ ( local_tran_id, session_id, branch_id,
        interface, type, parent_dbid, parent_db, db_userid, db_user) as
select  ps.*, u.name db_user
from    sys.pending_sessions$ ps, sys.user$ u
where   ps.db_userid = u.user#;
grant select on ps1$ to select_catalog_role;

rem     DBA_2PC_PENDING
rem     use this view to find info about pending (i.e. incomplete) distributed
rem     transactions at this DB.  Use os_user and db_userid to help track down
rem     a responsible party.  Use DBA_2PC_NEIGHBORS to find the commit point.
rem     Or take the advice, if offered.

create or replace view DBA_2PC_PENDING
    (local_tran_id, global_tran_id, state, mixed,
     advice, tran_comment, fail_time, force_time,
     retry_time, os_user, os_terminal, host, db_user, commit#) as
select  local_tran_id,
        nvl(global_oracle_id, global_tran_fmt||'.'||global_foreign_id),
        state, decode(status,'D','yes','no'), heuristic_dflt, tran_comment,
        fail_time, heuristic_time, reco_time,
        top_os_user, top_os_terminal, top_os_host, top_db_user, global_commit#
from    sys.pending_trans$;
create or replace public synonym DBA_2PC_PENDING for DBA_2PC_PENDING;
grant select on DBA_2PC_PENDING to select_catalog_role;
comment on table DBA_2PC_PENDING is
  'info about distributed transactions awaiting recovery';
comment on column DBA_2PC_PENDING.local_tran_id is
  'string of form: n.n.n, n a number';
comment on column DBA_2PC_PENDING.global_tran_id is
  'globally unique transaction id';
comment on column DBA_2PC_PENDING.state is
  'collecting, prepared, committed, forced commit, or forced rollback';
comment on column DBA_2PC_PENDING.mixed is
  'yes => part of the transaction committed and part rolled back (commit or rollback with the FORCE option was used)';
comment on column DBA_2PC_PENDING.advice is
  'C for commit, R for rollback, else null';
comment on column DBA_2PC_PENDING.tran_comment is
  'text for "commit work comment <text>"';
comment on column DBA_2PC_PENDING.fail_time is
  'value of SYSDATE when the row was inserted (tx or system recovery)';
comment on column DBA_2PC_PENDING.force_time is
 'time of manual force decision (null if not forced locally)';
comment on column DBA_2PC_PENDING.retry_time is
 'time automatic recovery (RECO) last tried to recover the transaction';
comment on column DBA_2PC_PENDING.os_user is
  'operating system specific name for the end-user';
comment on column DBA_2PC_PENDING.os_terminal is
  'operating system specific name for the end-user terminal';
comment on column DBA_2PC_PENDING.host is
  'name of the host machine for the end-user';
comment on column DBA_2PC_PENDING.db_user is
  'Oracle user name of the end-user at the topmost database';
comment on column DBA_2PC_PENDING.commit# is
  'global commit number for committed transactions';

rem     DBA_2PC_NEIGHBORS: use this view to obtain info about incoming and
rem       outgoing connections for a particular transaction.  It is suggested
rem       that it be queried using:
rem         select * from dba_2pc_neighbors where local_tran_id = <id>
rem          order by sess#, "IN_OUT";
rem       This will group sessions, with outgoing connections following the
rem       incoming connection for each session.
rem   columns:
rem     IN_OUT: 'in' for incoming connections, 'out' for outgoing
rem     DATABASE: if 'in', the name of the client database, else name of
rem       outgoing db link
rem     DBUSER_OWNER: if 'in', name of local user, else owner of db link
rem     INTERFACE: 'C' hold commit, else 'N'.  For incoming links, 'C'
rem       means that we or a DB at the other end of one of our outgoing links
rem       is the commit point (and must not forget until told by the client).
rem       For outgoing links, 'C' means that the child at the other end is the
rem       commit point, and will know whether the tran should commit or abort.
rem       If we are indoubt and do not find a 'C' on an outgoing link, then
rem       the top level user/DB, or the client, should be able to locate the
rem       commit point.
rem     DBID: the database id at the other end of the connection
rem     SESS#: session number at this database of the connection.  Sessions are
rem       numbered consecutively from 1; there is always at least 1 session,
rem       and exactly 1 incoming connection per session.
rem     BRANCH_ID: transaction branch.  An incoming branch is a two byte
rem       hexadecimal number.  The first byte is the session_id of the
rem       remote parent session.  The second byte is the branch_id of the
rem       remote parent session.  If the remote parent session is not Oracle,
rem       the branch_id can be up to 64 bytes.

create or replace view DBA_2PC_NEIGHBORS(local_tran_id, in_out, database,
                               dbuser_owner, interface, dbid,
                               sess#, branch) as
select  local_tran_id, 'in', parent_db, db_user, interface, parent_dbid,
        session_id, rawtohex(branch_id)
from    sys.ps1$
union all
select  local_tran_id, 'out', dblink, owner_name, interface, dbid,
        session_id, to_char(sub_session_id)
from    sys.pss1$;
create or replace public synonym DBA_2PC_NEIGHBORS for DBA_2PC_NEIGHBORS;
grant select on DBA_2PC_NEIGHBORS to select_catalog_role;
comment on table DBA_2PC_NEIGHBORS is
  'information about incoming and outgoing connections for pending transactions';
comment on column DBA_2PC_NEIGHBORS.in_out is
  '"in" for incoming connections, "out" for outgoing';
comment on column DBA_2PC_NEIGHBORS.database is
  'in: client database name; out: outgoing db link';
comment on column DBA_2PC_NEIGHBORS.dbuser_owner is
  'in: name of local user; out: owner of db link';
comment on column DBA_2PC_NEIGHBORS.interface is
  '"C" for request commit, else "N" for prepare or request readonly commit';
comment on column DBA_2PC_NEIGHBORS.dbid is
  'the database id at the other end of the connection';
comment on column DBA_2PC_NEIGHBORS.sess# is
  'session number at this database of the connection';
comment on column DBA_2PC_NEIGHBORS.branch is
  'transaction branch ID at this database of the connection'
/

Rem     GLOBAL DATABASE NAME

create or replace view GLOBAL_NAME ( GLOBAL_NAME ) as
       select value$ from sys.props$ where name = 'GLOBAL_DB_NAME'
/
comment on table GLOBAL_NAME is 'global database name'
/
comment on column GLOBAL_NAME.GLOBAL_NAME is 'global database name'
/
grant select on GLOBAL_NAME to public with grant option
/
create or replace public synonym GLOBAL_NAME for GLOBAL_NAME
/

Rem     PRODUCT COMPONENT VERSION
create or replace view product_component_version(product,version,status) as
(select
substr(banner,1, instr(banner,'Version')-1),
substr(banner, instr(banner,'Version')+8,
instr(banner,' - ')-(instr(banner,'Version')+8)),
substr(banner,instr(banner,' - ')+3)
from v$version
where instr(banner,'Version') > 0
and
((instr(banner,'Version') <   instr(banner,'Release')) or
instr(banner,'Release') = 0))
union
(select
substr(banner,1, instr(banner,'Release')-1),
substr(banner, instr(banner,'Release')+8,
instr(banner,' - ')-(instr(banner,'Release')+8)),
substr(banner,instr(banner,' - ')+3)
from v$version
where instr(banner,'Release') > 0
and
instr(banner,'Release') <   instr(banner,' - '))
/
comment on table product_component_version is
'version and status information for component products'
/
comment on column product_component_version.product is
'product name'
/
comment on column product_component_version.version is
'version number'
/
comment on column product_component_version.status is
'status of release'
/
grant select on product_component_version to public with grant option
/
create or replace public synonym product_component_version
   for product_component_version
/
remark
remark  FAMILY "UPDATABLE_COLUMNS"
remark
create or replace view USER_UPDATABLE_COLUMNS
(OWNER, TABLE_NAME, COLUMN_NAME, UPDATABLE, INSERTABLE, DELETABLE)
as
select u.name, o.name, c.name,
       decode(bitand(c.fixedstorage,2),
              2, decode(bitand(v.flags,8192), 8192, 'YES', 'NO'),
              decode(bitand(c.property,4096),4096,'NO','YES')),
       decode(bitand(c.fixedstorage,2),
              2, decode(bitand(v.flags,4096), 4096, 'YES', 'NO'),
              decode(bitand(c.property,2048),2048,'NO','YES')),
       decode(bitand(c.fixedstorage,2),
              2, decode(bitand(v.flags,16384), 16384, 'YES', 'NO'),
              decode(bitand(c.property,8192),8192,'NO','YES'))
from sys.obj$ o, sys.user$ u, sys.col$ c, sys.view$ v
where u.user# = o.owner#
  and c.obj#  = o.obj#
  and c.obj#  = v.obj#(+)
  and u.user# = userenv('SCHEMAID')
  and bitand(c.property, 32) = 0 /* not hidden column */
/
comment on table USER_UPDATABLE_COLUMNS is
'Description of updatable columns'
/
comment on column USER_UPDATABLE_COLUMNS.OWNER is
'Table owner'
/
comment on column USER_UPDATABLE_COLUMNS.TABLE_NAME is
'Table name'
/
comment on column USER_UPDATABLE_COLUMNS.COLUMN_NAME is
'Column name'
/
comment on column USER_UPDATABLE_COLUMNS.UPDATABLE is
'Is the column updatable?'
/
comment on column USER_UPDATABLE_COLUMNS.INSERTABLE is
'Is the column insertable?'
/
comment on column USER_UPDATABLE_COLUMNS.DELETABLE is
'Is the column deletable?'
/
create or replace public synonym USER_UPDATABLE_COLUMNS
   for USER_UPDATABLE_COLUMNS
/
grant select on USER_UPDATABLE_COLUMNS to PUBLIC with grant option
/
create or replace view ALL_UPDATABLE_COLUMNS
(OWNER, TABLE_NAME, COLUMN_NAME, UPDATABLE, INSERTABLE, DELETABLE)
as
select u.name, o.name, c.name,
       decode(bitand(c.fixedstorage,2),
              2, decode(bitand(v.flags,8192), 8192, 'YES', 'NO'),
              decode(bitand(c.property,4096),4096,'NO','YES')),
       decode(bitand(c.fixedstorage,2),
              2, decode(bitand(v.flags,4096), 4096, 'YES', 'NO'),
              decode(bitand(c.property,2048),2048,'NO','YES')),
       decode(bitand(c.fixedstorage,2),
              2, decode(bitand(v.flags,16384), 16384, 'YES', 'NO'),
              decode(bitand(c.property,8192),8192,'NO','YES'))
from sys.obj$ o, sys.user$ u, sys.col$ c, sys.view$ v
where o.owner# = u.user#
  and o.obj#  = c.obj#
  and c.obj#  = v.obj#(+)
  and bitand(c.property, 32) = 0 /* not hidden column */
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
/
comment on table ALL_UPDATABLE_COLUMNS is
'Description of all updatable columns'
/
comment on column ALL_UPDATABLE_COLUMNS.OWNER is
'Table owner'
/
comment on column ALL_UPDATABLE_COLUMNS.TABLE_NAME is
'Table name'
/
comment on column ALL_UPDATABLE_COLUMNS.COLUMN_NAME is
'Column name'
/
comment on column ALL_UPDATABLE_COLUMNS.UPDATABLE is
'Is the column updatable?'
/
comment on column ALL_UPDATABLE_COLUMNS.INSERTABLE is
'Is the column insertable?'
/
comment on column ALL_UPDATABLE_COLUMNS.DELETABLE is
'Is the column deletable?'
/
create or replace public synonym ALL_UPDATABLE_COLUMNS
   for ALL_UPDATABLE_COLUMNS
/
grant select on ALL_UPDATABLE_COLUMNS to PUBLIC with grant option
/
create or replace view DBA_UPDATABLE_COLUMNS
(OWNER, TABLE_NAME, COLUMN_NAME, UPDATABLE, INSERTABLE, DELETABLE)
as
select u.name, o.name, c.name,
       decode(bitand(c.fixedstorage,2),
              2, decode(bitand(v.flags,8192), 8192, 'YES', 'NO'),
              decode(bitand(c.property,4096),4096,'NO','YES')),
       decode(bitand(c.fixedstorage,2),
              2, decode(bitand(v.flags,4096), 4096, 'YES', 'NO'),
              decode(bitand(c.property,2048),2048,'NO','YES')),
       decode(bitand(c.fixedstorage,2),
              2, decode(bitand(v.flags,16384), 16384, 'YES', 'NO'),
              decode(bitand(c.property,8192),8192,'NO','YES'))
from sys.obj$ o, sys.user$ u, sys.col$ c, sys.view$ v
where u.user# = o.owner#
  and c.obj#  = o.obj#
  and c.obj#  = v.obj#(+)
  and bitand(c.property, 32) = 0 /* not hidden column */
/
comment on table DBA_UPDATABLE_COLUMNS is
'Description of dba updatable columns'
/
comment on column DBA_UPDATABLE_COLUMNS.OWNER is
'table owner'
/
comment on column DBA_UPDATABLE_COLUMNS.TABLE_NAME is
'table name'
/
comment on column DBA_UPDATABLE_COLUMNS.COLUMN_NAME is
'column name'
/
comment on column DBA_UPDATABLE_COLUMNS.UPDATABLE is
'Is the column updatable?'
/
comment on column DBA_UPDATABLE_COLUMNS.INSERTABLE is
'Is the column insertable?'
/
comment on column DBA_UPDATABLE_COLUMNS.DELETABLE is
'Is the column deletable?'
/
create or replace public synonym DBA_UPDATABLE_COLUMNS
   for DBA_UPDATABLE_COLUMNS
/
grant select on DBA_UPDATABLE_COLUMNS to select_catalog_role
/
remark
remark  FAMILY "LOBS"
remark
remark  Views for showing information about LOBs:
remark  USER_LOBS, ALL_LOBS, and DBA_LOBS
remark
create or replace view USER_LOBS
    (TABLE_NAME, COLUMN_NAME, SEGMENT_NAME, TABLESPACE_NAME, INDEX_NAME,
     CHUNK, PCTVERSION, RETENTION, FREEPOOLS, CACHE, LOGGING, IN_ROW, FORMAT,
     PARTITIONED)
as
select o.name,
       decode(bitand(c.property, 1), 1, ac.name, c.name),
       lo.name,
       decode(bitand(l.property, 8), 8, ts1.name, ts.name), io.name,
       l.chunk * decode(bitand(l.property, 8), 8, ts1.blocksize,
                        ts.blocksize),
       decode(bitand(l.flags, 32), 0, l.pctversion$, to_number(NULL)),
       decode(bitand(l.flags, 32), 32, l.retention, to_number(NULL)),
       decode(l.freepools, 0, to_number(NULL), 65534, to_number(NULL),
              65535, to_number(NULL), l.freepools),
       decode(bitand(l.flags, 27), 1, 'NO', 2, 'NO', 8, 'CACHEREADS',
                                   16, 'CACHEREADS', 'YES'),
       decode(bitand(l.flags, 18), 2, 'NO', 16, 'NO', 'YES'),
       decode(bitand(l.property, 2), 2, 'YES', 'NO'),
       decode(c.type#, 113, 'NOT APPLICABLE ',
              decode(bitand(l.property, 512), 512,
                     'ENDIAN SPECIFIC', 'ENDIAN NEUTRAL ')),
       decode(bitand(ta.property, 32), 32, 'YES', 'NO')
from sys.obj$ o, sys.col$ c, sys.attrcol$ ac, sys.lob$ l, sys.obj$ lo,
     sys.obj$ io, sys.ts$ ts, sys.tab$ ta, sys.user$ ut, sys.ts$ ts1
where o.owner# = userenv('SCHEMAID')
  and o.obj# = c.obj#
  and c.obj# = l.obj#
  and c.intcol# = l.intcol#
  and l.lobj# = lo.obj#
  and l.ind# = io.obj#
  and l.ts# = ts.ts#(+)
  and o.owner# = ut.user#
  and ut.tempts# = ts1.ts#
  and c.obj# = ac.obj#(+)
  and c.intcol# = ac.intcol#(+)
  and bitand(c.property,32768) != 32768           /* not unused column */
  and o.obj# = ta.obj#
  and bitand(ta.property, 32) != 32           /* not partitioned table */
union all
select o.name,
       decode(bitand(c.property, 1), 1, ac.name, c.name),
       lo.name,
       NVL(ts1.name,
        (select ts2.name 
        from    ts$ ts2, partobj$ po 
        where   o.obj# = po.obj# and po.defts# = ts2.ts#)), 
       io.name,
       plob.defchunk * NVL(ts1.blocksize, NVL((
        select ts2.blocksize
        from   sys.ts$ ts2, sys.lobfrag$ lf
        where  l.lobj# = lf.parentobj# and
               lf.ts# = ts2.ts# and rownum < 2),
        (select ts2.blocksize
        from   sys.ts$ ts2, sys.lobcomppart$ lcp, sys.lobfrag$ lf
        where  l.lobj# = lcp.lobj# and lcp.partobj# = lf.parentobj# and
               lf.ts# = ts2.ts# and rownum < 2))),
       decode(plob.defpctver$, 101, to_number(NULL), 102, to_number(NULL),
                                   plob.defpctver$),
       decode(l.retention, -1, to_number(NULL), l.retention),
       decode(l.freepools, 0, to_number(NULL), 65534, to_number(NULL),
              65535, to_number(NULL), l.freepools),
       decode(bitand(plob.defflags, 27), 1, 'NO', 2, 'NO', 8, 'CACHEREADS',
                                         16, 'CACHEREADS', 'YES'),
       decode(bitand(plob.defflags,22), 0,'NONE', 4,'YES', 2,'NO',
                                        16,'NO', 'UNKNOWN'),
       decode(bitand(plob.defpro, 2), 2, 'YES', 'NO'),
       decode(c.type#, 113, 'NOT APPLICABLE ',
              decode(bitand(l.property, 512), 512,
                     'ENDIAN SPECIFIC', 'ENDIAN NEUTRAL ')),
       decode(bitand(ta.property, 32), 32, 'YES', 'NO')
from sys.obj$ o, sys.col$ c, sys.attrcol$ ac, sys.partlob$ plob,
     sys.lob$ l, sys.obj$ lo, sys.obj$ io, sys.ts$ ts1, sys.tab$ ta
where o.owner# = userenv('SCHEMAID')
  and o.obj# = c.obj#
  and c.obj# = l.obj#
  and c.intcol# = l.intcol#
  and l.lobj# = lo.obj#
  and l.ind# = io.obj#
  and l.lobj# = plob.lobj#
  and plob.defts# = ts1.ts# (+)
  and c.obj# = ac.obj#(+)
  and c.intcol# = ac.intcol#(+)
  and bitand(c.property,32768) != 32768           /* not unused column */
  and o.obj# = ta.obj#
  and bitand(ta.property, 32) = 32                /* partitioned table */
/
comment on table USER_LOBS is
'Description of the user''s own LOBs contained in the user''s own tables'
/
comment on column USER_LOBS.TABLE_NAME is
'Name of the table containing the LOB'
/
comment on column USER_LOBS.COLUMN_NAME is
'Name of the LOB column or attribute'
/
comment on column USER_LOBS.SEGMENT_NAME is
'Name of the LOB segment'
/
comment on column USER_LOBS.TABLESPACE_NAME is
'Name of the tablespace containing the LOB segment'
/
comment on column USER_LOBS.INDEX_NAME is
'Name of the LOB index'
/
comment on column USER_LOBS.CHUNK is
'Size of the LOB chunk as a unit of allocation/manipulation in bytes'
/
comment on column USER_LOBS.PCTVERSION is
'Maximum percentage of the LOB space used for versioning'
/
comment on column USER_LOBS.RETENTION is
'Maximum time duration for versioning of the LOB space'
/
comment on column USER_LOBS.FREEPOOLS is
'Number of freepools for this LOB segment'
/
comment on column USER_LOBS.CACHE is
'Is the LOB accessed through the buffer cache?'
/
comment on column USER_LOBS.LOGGING is
'Are changes to the LOB logged?'
/
comment on column USER_LOBS.IN_ROW is
'Are some of the LOBs stored with the base row?'
/
comment on column USER_LOBS.FORMAT is
'Is the LOB storage format dependent on the endianness of the platform?'
/
comment on column USER_LOBS.PARTITIONED is
'Is the LOB column in a partitioned table?'
/
create or replace public synonym USER_LOBS for USER_LOBS
/
grant select on USER_LOBS to PUBLIC with grant option
/
create or replace view ALL_LOBS
    (OWNER, TABLE_NAME, COLUMN_NAME, SEGMENT_NAME, TABLESPACE_NAME, INDEX_NAME,
     CHUNK, PCTVERSION, RETENTION, FREEPOOLS, CACHE, LOGGING, IN_ROW, FORMAT,
     PARTITIONED)
as
select u.name, o.name,
       decode(bitand(c.property, 1), 1, ac.name, c.name), lo.name,
       decode(bitand(l.property, 8), 8, ts1.name, ts.name),
       io.name,
       l.chunk * decode(bitand(l.property, 8), 8, ts1.blocksize,
                        ts.blocksize),
       decode(bitand(l.flags, 32), 0, l.pctversion$, to_number(NULL)),
       decode(bitand(l.flags, 32), 32, l.retention, to_number(NULL)),
       decode(l.freepools, 0, to_number(NULL), 65534, to_number(NULL),
              65535, to_number(NULL), l.freepools),
       decode(bitand(l.flags, 27), 1, 'NO', 2, 'NO', 8, 'CACHEREADS',
                                   16, 'CACHEREADS', 'YES'),
       decode(bitand(l.flags, 18), 2, 'NO', 16, 'NO', 'YES'),
       decode(bitand(l.property, 2), 2, 'YES', 'NO'),
       decode(c.type#, 113, 'NOT APPLICABLE ',
              decode(bitand(l.property, 512), 512,
                     'ENDIAN SPECIFIC', 'ENDIAN NEUTRAL ')),
       decode(bitand(ta.property, 32), 32, 'YES', 'NO')
from sys.obj$ o, sys.col$ c, sys.attrcol$ ac, sys.tab$ ta, sys.lob$ l,
     sys.obj$ lo, sys.obj$ io, sys.user$ u, sys.ts$ ts, sys.ts$ ts1
where o.owner# = u.user#
  and o.obj# = c.obj#
  and c.obj# = l.obj#
  and c.intcol# = l.intcol#
  and l.lobj# = lo.obj#
  and l.ind# = io.obj#
  and l.ts# = ts.ts#(+)
  and u.tempts# = ts1.ts#
  and c.obj# = ac.obj#(+)
  and c.intcol# = ac.intcol#(+)
  and bitand(c.property,32768) != 32768           /* not unused column */
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */)
                 )
      )
  and o.obj# = ta.obj#
  and bitand(ta.property, 32) != 32    /* not partitioned table */
union all
select u.name, o.name,
       decode(bitand(c.property, 1), 1, ac.name, c.name),
       lo.name,
       NVL(ts1.name,
        (select ts2.name 
        from    ts$ ts2, partobj$ po 
        where   o.obj# = po.obj# and po.defts# = ts2.ts#)), 
       io.name,
       plob.defchunk * NVL(ts1.blocksize, NVL((
        select ts2.blocksize
        from   sys.ts$ ts2, sys.lobfrag$ lf
        where  l.lobj# = lf.parentobj# and
               lf.ts# = ts2.ts# and rownum < 2),
        (select ts2.blocksize
        from   sys.ts$ ts2, sys.lobcomppart$ lcp, sys.lobfrag$ lf
        where  l.lobj# = lcp.lobj# and lcp.partobj# = lf.parentobj# and
               lf.ts# = ts2.ts# and rownum < 2))),
       decode(plob.defpctver$, 101, to_number(NULL), 102, to_number(NULL),
                               plob.defpctver$),
       decode(l.retention, -1, to_number(NULL), l.retention),
       decode(l.freepools, 0, to_number(NULL), 65534, to_number(NULL),
              65535, to_number(NULL), l.freepools),
       decode(bitand(plob.defflags, 27), 1, 'NO', 2, 'NO', 8, 'CACHEREADS',
                                         16, 'CACHEREADS', 'YES'),
       decode(bitand(plob.defflags,22), 0,'NONE', 4,'YES', 2,'NO',
                                        16,'NO', 'UNKNOWN'),
       decode(bitand(plob.defpro, 2), 2, 'YES', 'NO'),
       decode(c.type#, 113, 'NOT APPLICABLE ',
              decode(bitand(l.property, 512), 512,
                     'ENDIAN SPECIFIC', 'ENDIAN NEUTRAL ')),
       decode(bitand(ta.property, 32), 32, 'YES', 'NO')
from sys.obj$ o, sys.col$ c, sys.attrcol$ ac, sys.partlob$ plob,
     sys.lob$ l, sys.obj$ lo, sys.obj$ io, sys.ts$ ts1, sys.tab$ ta,
     sys.user$ u
where o.owner# = u.user#
  and o.obj# = c.obj#
  and c.obj# = l.obj#
  and c.intcol# = l.intcol#
  and l.lobj# = lo.obj#
  and l.ind# = io.obj#
  and l.lobj# = plob.lobj#
  and plob.defts# = ts1.ts# (+)
  and c.obj# = ac.obj#(+)
  and c.intcol# = ac.intcol#(+)
  and bitand(c.property,32768) != 32768           /* not unused column */
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */)
                 )
      )
  and o.obj# = ta.obj#
  and bitand(ta.property, 32) = 32         /* partitioned table */
/
comment on table ALL_LOBS is
'Description of LOBs contained in tables accessible to the user'
/
comment on column ALL_LOBS.OWNER is
'Owner of the table containing the LOB'
/
comment on column ALL_LOBS.TABLE_NAME is
'Name of the table containing the LOB'
/
comment on column ALL_LOBS.COLUMN_NAME is
'Name of the LOB column or attribute'
/
comment on column ALL_LOBS.SEGMENT_NAME is
'Name of the LOB segment'
/
comment on column ALL_LOBS.TABLESPACE_NAME is
'Name of the tablespace containing the LOB segment'
/
comment on column ALL_LOBS.INDEX_NAME is
'Name of the LOB index'
/
comment on column ALL_LOBS.CHUNK is
'Size of the LOB chunk as a unit of allocation/manipulation in bytes'
/
comment on column ALL_LOBS.PCTVERSION is
'Maximum percentage of the LOB space used for versioning'
/
comment on column ALL_LOBS.RETENTION is
'Maximum time duration for versioning of the LOB space'
/
comment on column ALL_LOBS.FREEPOOLS is
'Number of freepools for this LOB segment'
/
comment on column ALL_LOBS.CACHE is
'Is the LOB accessed through the buffer cache?'
/
comment on column ALL_LOBS.LOGGING is
'Are changes to the LOB logged?'
/
comment on column ALL_LOBS.IN_ROW is
'Are some of the LOBs stored with the base row?'
/
comment on column ALL_LOBS.FORMAT is
'Is the LOB storage format dependent on the endianness of the platform?'
/
comment on column ALL_LOBS.PARTITIONED is
'Is the LOB column in a partitioned table?'
/
create or replace public synonym ALL_LOBS for ALL_LOBS
/
grant select on ALL_LOBS to PUBLIC with grant option
/
create or replace view DBA_LOBS
    (OWNER, TABLE_NAME, COLUMN_NAME, SEGMENT_NAME, TABLESPACE_NAME, INDEX_NAME,
     CHUNK, PCTVERSION, RETENTION, FREEPOOLS, CACHE, LOGGING, IN_ROW, FORMAT,
     PARTITIONED)
as
select u.name, o.name,
       decode(bitand(c.property, 1), 1, ac.name, c.name), lo.name,
       decode(bitand(l.property, 8), 8, ts1.name, ts.name),
       io.name,
       l.chunk * decode(bitand(l.property, 8), 8, ts1.blocksize,
                        ts.blocksize),
       decode(bitand(l.flags, 32), 0, l.pctversion$, to_number(NULL)),
       decode(bitand(l.flags, 32), 32, l.retention, to_number(NULL)),
       decode(l.freepools, 0, to_number(NULL), 65534, to_number(NULL),
              65535, to_number(NULL), l.freepools),
       decode(bitand(l.flags, 27), 1, 'NO', 2, 'NO', 8, 'CACHEREADS',
                                   16, 'CACHEREADS', 'YES'),
       decode(bitand(l.flags, 18), 2, 'NO', 16, 'NO', 'YES'),
       decode(bitand(l.property, 2), 2, 'YES', 'NO'),
       decode(c.type#, 113, 'NOT APPLICABLE ',
              decode(bitand(l.property, 512), 512,
                     'ENDIAN SPECIFIC', 'ENDIAN NEUTRAL ')),
       decode(bitand(ta.property, 32), 32, 'YES', 'NO')
from sys.obj$ o, sys.col$ c, sys.attrcol$ ac, sys.tab$ ta, sys.lob$ l,
     sys.obj$ lo, sys.obj$ io, sys.user$ u, sys.ts$ ts, sys.ts$ ts1
where o.owner# = u.user#
  and o.obj# = c.obj#
  and c.obj# = l.obj#
  and c.intcol# = l.intcol#
  and l.lobj# = lo.obj#
  and l.ind# = io.obj#
  and l.ts# = ts.ts#(+)
  and u.tempts# = ts1.ts#
  and c.obj# = ac.obj#(+)
  and c.intcol# = ac.intcol#(+)
  and bitand(c.property,32768) != 32768           /* not unused column */
  and o.obj# = ta.obj#
  and bitand(ta.property, 32) != 32           /* not partitioned table */
union all
select u.name, o.name,
       decode(bitand(c.property, 1), 1, ac.name, c.name),
       lo.name,
       NVL(ts1.name,
        (select ts2.name 
        from    ts$ ts2, partobj$ po 
        where   o.obj# = po.obj# and po.defts# = ts2.ts#)), 
       io.name,
       plob.defchunk * NVL(ts1.blocksize, NVL((
        select ts2.blocksize
        from   sys.ts$ ts2, sys.lobfrag$ lf
        where  l.lobj# = lf.parentobj# and
               lf.ts# = ts2.ts# and rownum < 2),
        (select ts2.blocksize
        from   sys.ts$ ts2, sys.lobcomppart$ lcp, sys.lobfrag$ lf
        where  l.lobj# = lcp.lobj# and lcp.partobj# = lf.parentobj# and
               lf.ts# = ts2.ts# and rownum < 2))),
       decode(plob.defpctver$, 101, to_number(NULL), 102, to_number(NULL),
                                           plob.defpctver$),
       decode(l.retention, -1, to_number(NULL), l.retention),
       decode(l.freepools, 0, to_number(NULL), 65534, to_number(NULL),
              65535, to_number(NULL), l.freepools),
       decode(bitand(plob.defflags, 27), 1, 'NO', 2, 'NO', 8, 'CACHEREADS',
                                         16, 'CACHEREADS', 'YES'),
       decode(bitand(plob.defflags,22), 0,'NONE', 4,'YES', 2,'NO',
                                        16,'NO', 'UNKNOWN'),
       decode(bitand(plob.defpro, 2), 2, 'YES', 'NO'),
       decode(c.type#, 113, 'NOT APPLICABLE ',
              decode(bitand(l.property, 512), 512,
                     'ENDIAN SPECIFIC', 'ENDIAN NEUTRAL ')),
       decode(bitand(ta.property, 32), 32, 'YES', 'NO')
from sys.obj$ o, sys.col$ c, sys.attrcol$ ac, sys.partlob$ plob,
     sys.lob$ l, sys.obj$ lo, sys.obj$ io, sys.ts$ ts1, sys.tab$ ta,
     sys.user$ u
where o.owner# = u.user#
  and o.obj# = c.obj#
  and c.obj# = l.obj#
  and c.intcol# = l.intcol#
  and l.lobj# = lo.obj#
  and l.ind# = io.obj#
  and l.lobj# = plob.lobj#
  and plob.defts# = ts1.ts# (+)
  and c.obj# = ac.obj#(+)
  and c.intcol# = ac.intcol#(+)
  and bitand(c.property,32768) != 32768           /* not unused column */
  and o.obj# = ta.obj#
  and bitand(ta.property, 32) = 32                /* partitioned table */
/
comment on table DBA_LOBS is
'Description of LOBs contained in all tables'
/
comment on column DBA_LOBS.OWNER is
'Owner of the table containing the LOB'
/
comment on column DBA_LOBS.TABLE_NAME is
'Name of the table containing the LOB'
/
comment on column DBA_LOBS.COLUMN_NAME is
'Name of the LOB column or attribute'
/
comment on column DBA_LOBS.SEGMENT_NAME is
'Name of the LOB segment'
/
comment on column DBA_LOBS.TABLESPACE_NAME is
'Name of the tablespace containing the LOB segment'
/
comment on column DBA_LOBS.INDEX_NAME is
'Name of the LOB index'
/
comment on column DBA_LOBS.CHUNK is
'Size of the LOB chunk as a unit of allocation/manipulation in bytes'
/
comment on column DBA_LOBS.PCTVERSION is
'Maximum percentage of the LOB space used for versioning'
/
comment on column DBA_LOBS.RETENTION is
'Maximum time duration for versioning of the LOB space'
/
comment on column DBA_LOBS.FREEPOOLS is
'Number of freepools for this LOB segment'
/
comment on column DBA_LOBS.CACHE is
'Is the LOB accessed through the buffer cache?'
/
comment on column DBA_LOBS.LOGGING is
'Are changes to the LOB logged?'
/
comment on column DBA_LOBS.IN_ROW is
'Are some of the LOBs stored with the base row?'
/
comment on column DBA_LOBS.FORMAT is
'Is the LOB storage format dependent on the endianness of the platform?'
/
comment on column DBA_LOBS.PARTITIONED is
'Is the LOB column in a partitioned table?'
/
create or replace public synonym DBA_LOBS for DBA_LOBS
/
grant select on DBA_LOBS to select_catalog_role
/
remark
remark  FAMILY "DIRECTORIES"
remark
remark  Views for showing information about directories:
remark  ALL_DIRECTORIES and DBA_DIRECTORIES
remark
create or replace view ALL_DIRECTORIES
       (OWNER, DIRECTORY_NAME, DIRECTORY_PATH)
as
select u.name, o.name, d.os_path
from sys.user$ u, sys.obj$ o, sys.dir$ d
where u.user# = o.owner#
  and o.obj# = d.obj#
  and ( o.owner# =  userenv('SCHEMAID')
        or o.obj# in
           (select oa.obj#
            from sys.objauth$ oa
            where grantee# in (select kzsrorol
                               from x$kzsro
                              )
           )
        or exists (select null from v$enabledprivs
                   where priv_number in (-177, /* CREATE ANY DIRECTORY */
                                         -178  /* DROP ANY DIRECTORY */)
                  )
      )
/
comment on table ALL_DIRECTORIES is
'Description of all directories accessible to the user'
/
comment on column ALL_DIRECTORIES.OWNER is
'Owner of the directory (always SYS)'
/
comment on column ALL_DIRECTORIES.DIRECTORY_NAME is
'Name of the directory'
/
comment on column ALL_DIRECTORIES.DIRECTORY_PATH is
'Operating system pathname for the directory'
/
create or replace public synonym ALL_DIRECTORIES for ALL_DIRECTORIES
/
grant select on ALL_DIRECTORIES to PUBLIC with grant option
/
create or replace view DBA_DIRECTORIES
       (OWNER, DIRECTORY_NAME, DIRECTORY_PATH)
as
select u.name, o.name, d.os_path
from sys.user$ u, sys.obj$ o, sys.dir$ d
where u.user# = o.owner#
  and o.obj# = d.obj#
/
comment on table DBA_DIRECTORIES is
'Description of all directories'
/
comment on column DBA_DIRECTORIES.OWNER is
'Owner of the directory (always SYS)'
/
comment on column DBA_DIRECTORIES.DIRECTORY_NAME is
'Name of the directory'
/
comment on column DBA_DIRECTORIES.DIRECTORY_PATH is
'Operating system pathname for the directory'
/
create or replace public synonym DBA_DIRECTORIES for DBA_DIRECTORIES
/
grant select on DBA_DIRECTORIES to select_catalog_role
/

remark
remark  FAMILY "LIBRARIES"
remark
remark  Views for showing information about PL/SQL Libraries:
remark  USER_LIBRARIES, ALL_LIBRARIES and DBA_LIBRARIES
remark
create or replace view USER_LIBRARIES
(LIBRARY_NAME, FILE_SPEC, DYNAMIC, STATUS)
as
select o.name,
       l.filespec,
       decode(bitand(l.property, 1), 0, 'Y', 1, 'N', NULL),
       decode(o.status, 0, 'N/A', 1, 'VALID', 'INVALID')
from sys.obj$ o, sys.library$ l
where o.owner# = userenv('SCHEMAID')
  and o.obj# = l.obj#
/
rem  and ((l.property is null) or (bitand(l.property, 2) = 0))
comment on table USER_LIBRARIES is
'Description of the user''s own libraries'
/
comment on column USER_LIBRARIES.LIBRARY_NAME is
'Name of the library'
/
comment on column USER_LIBRARIES.FILE_SPEC is
'Operating system file specification of the library'
/
comment on column USER_LIBRARIES.DYNAMIC is
'Is the library dynamically loadable'
/
comment on column USER_LIBRARIES.STATUS is
'Status of the library'
/
create or replace public synonym USER_LIBRARIES for USER_LIBRARIES
/
grant select on USER_LIBRARIES to PUBLIC with grant option
/

create or replace view ALL_LIBRARIES
(OWNER, LIBRARY_NAME, FILE_SPEC, DYNAMIC, STATUS)
as
select u.name,
       o.name,
       l.filespec,
       decode(bitand(l.property, 1), 0, 'Y', 1, 'N', NULL),
       decode(o.status, 0, 'N/A', 1, 'VALID', 'INVALID')
from sys.obj$ o, sys.library$ l, sys.user$ u
where o.owner# = u.user#
  and o.obj# = l.obj#
  and (o.owner# in (userenv('SCHEMAID'), 1 /* PUBLIC */)
       or o.obj# in
          ( select oa.obj#
            from sys.objauth$ oa
            where grantee# in (select kzsrorol from x$kzsro)
          )
       or (
            exists (select NULL from v$enabledprivs
                    where priv_number in (
                                      -189 /* CREATE ANY LIBRARY */,
                                      -190 /* ALTER ANY LIBRARY */,
                                      -191 /* DROP ANY LIBRARY */,
                                      -192 /* EXECUTE ANY LIBRARY */
                                         )
                   )
          )
      )
/
comment on table ALL_LIBRARIES is
'Description of libraries accessible to the user'
/
comment on column ALL_LIBRARIES.OWNER is
'Owner of the library'
/
comment on column ALL_LIBRARIES.LIBRARY_NAME is
'Name of the library'
/
comment on column ALL_LIBRARIES.FILE_SPEC is
'Operating system file specification of the library'
/
comment on column ALL_LIBRARIES.DYNAMIC is
'Is the library dynamically loadable'
/
comment on column ALL_LIBRARIES.STATUS is
'Status of the library'
/
create or replace public synonym ALL_LIBRARIES for ALL_LIBRARIES
/
grant select on ALL_LIBRARIES to PUBLIC with grant option
/

create or replace view DBA_LIBRARIES
(OWNER, LIBRARY_NAME, FILE_SPEC, DYNAMIC, STATUS)
as
select u.name,
       o.name,
       l.filespec,
       decode(bitand(l.property, 1), 0, 'Y', 1, 'N', NULL),
       decode(o.status, 0, 'N/A', 1, 'VALID', 'INVALID')
from sys.obj$ o, sys.library$ l, sys.user$ u
where o.owner# = u.user#
  and o.obj# = l.obj#
/
comment on table DBA_LIBRARIES is
'Description of all libraries in the database'
/
comment on column DBA_LIBRARIES.OWNER is
'Owner of the library'
/
comment on column DBA_LIBRARIES.LIBRARY_NAME is
'Name of the library'
/
comment on column DBA_LIBRARIES.FILE_SPEC is
'Operating system file specification of the library'
/
comment on column DBA_LIBRARIES.DYNAMIC is
'Is the library dynamically loadable'
/
comment on column DBA_LIBRARIES.STATUS is
'Status of the library'
/
create or replace public synonym DBA_LIBRARIES for DBA_LIBRARIES
/
grant select on DBA_LIBRARIES to select_catalog_role
/

remark
remark  FAMILY "REFS"
remark
remark  Views for showing information about REFs:
remark  USER_REFS, ALL_REFS, and DBA_REFS
remark
create or replace view USER_REFS
    (TABLE_NAME, COLUMN_NAME, WITH_ROWID, IS_SCOPED,
     SCOPE_TABLE_OWNER, SCOPE_TABLE_NAME, OBJECT_ID_TYPE)
as
select distinct o.name,
       decode(bitand(c.property, 1), 1, ac.name, c.name),
       decode(bitand(rc.reftyp, 2), 2, 'YES', 'NO'),
       decode(bitand(rc.reftyp, 1), 1, 'YES', 'NO'),
       su.name, so.name,
       case
         when bitand(reftyp,4) = 4 then 'USER-DEFINED'
         when bitand(reftyp, 8) = 8 then 'SYSTEM GENERATED AND USER-DEFINED'
         else 'SYSTEM GENERATED'
       end
from sys.obj$ o, sys.col$ c, sys.refcon$ rc, sys.obj$ so, sys.user$ su,
     sys.attrcol$ ac
where o.owner# = userenv('SCHEMAID')
  and o.obj# = c.obj#
  and c.obj# = rc.obj#
  and c.col# = rc.col#
  and c.intcol# = rc.intcol#
  and rc.stabid = so.oid$(+)
  and so.owner# = su.user#(+)
  and c.obj# = ac.obj#(+)
  and c.intcol# = ac.intcol#(+)
  and bitand(c.property,32768) != 32768           /* not unused column */
/

comment on table USER_REFS is
'Description of the user''s own REF columns contained in the user''s own tables'
/
comment on column USER_REFS.TABLE_NAME is
'Name of the table containing the REF column'
/
comment on column USER_REFS.COLUMN_NAME is
'Column name or attribute of object column'
/
comment on column USER_REFS.WITH_ROWID is
'Is the REF value stored with the rowid?'
/
comment on column USER_REFS.IS_SCOPED is
'Is the REF column scoped?'
/
comment on column USER_REFS.SCOPE_TABLE_OWNER is
'Owner of the scope table, if it exists'
/
comment on column USER_REFS.SCOPE_TABLE_NAME is
'Name of the scope table, if it exists'
/
comment on column USER_REFS.OBJECT_ID_TYPE is
'If ref contains user-defined OID, then USER-DEFINED, else if it contains system generated OID, then SYSTEM GENERATED'
/
create or replace public synonym USER_REFS for USER_REFS
/
grant select on USER_REFS to PUBLIC with grant option
/
create or replace view ALL_REFS
    (OWNER, TABLE_NAME, COLUMN_NAME, WITH_ROWID, IS_SCOPED,
     SCOPE_TABLE_OWNER, SCOPE_TABLE_NAME, OBJECT_ID_TYPE)
as
select distinct u.name, o.name,
       decode(bitand(c.property, 1), 1, ac.name, c.name),
       decode(bitand(rc.reftyp, 2), 2, 'YES', 'NO'),
       decode(bitand(rc.reftyp, 1), 1, 'YES', 'NO'),
       su.name, so.name,
       case
         when bitand(reftyp,4) = 4 then 'USER-DEFINED'
         when bitand(reftyp, 8) = 8 then 'SYSTEM GENERATED AND USER-DEFINED'
         else 'SYSTEM GENERATED'
       end
from sys.user$ u, sys.obj$ o, sys.col$ c, sys.refcon$ rc, sys.obj$ so,
     sys.user$ su, sys.attrcol$ ac
where o.owner# = u.user#
  and o.obj# = c.obj#
  and c.obj# = rc.obj#
  and c.col# = rc.col#
  and c.intcol# = rc.intcol#
  and rc.stabid = so.oid$(+)
  and so.owner# = su.user#(+)
  and c.obj# = ac.obj#(+)
  and c.intcol# = ac.intcol#(+)
  and bitand(c.property,32768) != 32768           /* not unused column */
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */)
                 )
      )
/
comment on table ALL_REFS is
'Description of REF columns contained in tables accessible to the user'
/
comment on column ALL_REFS.OWNER is
'Owner of the table containing the REF column'
/
comment on column ALL_REFS.TABLE_NAME is
'Name of the table containing the REF column'
/
comment on column ALL_REFS.COLUMN_NAME is
'Column name or attribute of object column'
/
comment on column ALL_REFS.WITH_ROWID is
'Is the REF value stored with the rowid?'
/
comment on column ALL_REFS.IS_SCOPED is
'Is the REF column scoped?'
/
comment on column ALL_REFS.SCOPE_TABLE_OWNER is
'Owner of the scope table, if it exists'
/
comment on column ALL_REFS.SCOPE_TABLE_NAME is
'Name of the scope table, if it exists'
/
comment on column ALL_REFS.OBJECT_ID_TYPE is
'If ref contains user-defined OID, then USER-DEFINED, else if it contains system
 generated OID, then SYSTEM GENERATED'
/
create or replace public synonym ALL_REFS for ALL_REFS
/
grant select on ALL_REFS to PUBLIC with grant option
/
create or replace view DBA_REFS
    (OWNER, TABLE_NAME, COLUMN_NAME, WITH_ROWID, IS_SCOPED,
     SCOPE_TABLE_OWNER, SCOPE_TABLE_NAME, OBJECT_ID_TYPE)
as
select distinct u.name, o.name,
       decode(bitand(c.property, 1), 1, ac.name, c.name),
       decode(bitand(rc.reftyp, 2), 2, 'YES', 'NO'),
       decode(bitand(rc.reftyp, 1), 1, 'YES', 'NO'),
       su.name, so.name,
       case
         when bitand(reftyp,4) = 4 then 'USER-DEFINED'
         when bitand(reftyp, 8) = 8 then 'SYSTEM GENERATED AND USER-DEFINED'
         else 'SYSTEM GENERATED'
       end
from sys.obj$ o, sys.col$ c, sys.user$ u, sys.refcon$ rc, sys.obj$ so,
     sys.user$ su, sys.attrcol$ ac
where o.owner# = u.user#
  and o.obj# = c.obj#
  and c.obj# = rc.obj#
  and c.col# = rc.col#
  and c.intcol# = rc.intcol#
  and rc.stabid = so.oid$(+)
  and so.owner# = su.user#(+)
  and c.obj# = ac.obj#(+)
  and c.intcol# = ac.intcol#(+)
  and bitand(c.property,32768) != 32768           /* not unused column */
/
comment on table DBA_REFS is
'Description of REF columns contained in all tables'
/
comment on column DBA_REFS.OWNER is
'Owner of the table containing the REF column'
/
comment on column DBA_REFS.TABLE_NAME is
'Name of the table containing the REF column'
/
comment on column DBA_REFS.COLUMN_NAME is
'Column name or attribute of object column'
/
comment on column DBA_REFS.WITH_ROWID is
'Is the REF value stored with the rowid?'
/
comment on column DBA_REFS.IS_SCOPED is
'Is the REF column scoped?'
/
comment on column DBA_REFS.SCOPE_TABLE_OWNER is
'Owner of the scope table, if it exists'
/
comment on column DBA_REFS.SCOPE_TABLE_NAME is
'Name of the scope table, if it exists'
/
comment on column DBA_REFS.OBJECT_ID_TYPE is
'If ref contains user-defined OID, then USER-DEFINED, else if it contains system
 generated OID, then SYSTEM GENERATED'
/
create or replace public synonym DBA_REFS for DBA_REFS
/
grant select on DBA_REFS to select_catalog_role
/
REM
REM  NESTED TABLES:
REM  Views for showing information about nested tables
REM
create or replace view USER_NESTED_TABLES
    (TABLE_NAME, TABLE_TYPE_OWNER, TABLE_TYPE_NAME, PARENT_TABLE_NAME,
     PARENT_TABLE_COLUMN, STORAGE_SPEC, RETURN_TYPE, ELEMENT_SUBSTITUTABLE)
as
select o.name,
       nvl2(ct.synobj#, (select u.name from user$ u, obj$ o
            where o.owner#=u.user# and o.obj#=ct.synobj#), ut.name),
       nvl2(ct.synobj#, (select o.name from obj$ o
            where o.obj#=ct.synobj#), ot.name),
       op.name, ac.name,
       lpad(decode(bitand(ct.flags, 64), 64, 'USER_SPECIFIED', 'DEFAULT'), 30),
       lpad(decode(bitand(ct.flags, 32), 32, 'LOCATOR', 'VALUE'), 20),
       lpad((case when bitand(ct.flags, 5120)=0 and bitand(t.properties, 8)= 8
       then 'Y' else 'N' end), 25)
from sys.ntab$ n, sys.obj$ o, sys.obj$ op, sys.obj$ ot,
  sys.col$ c, sys.coltype$ ct, sys.user$ ut, sys.attrcol$ ac,
  sys.type$ t, sys.collection$ cl
where o.owner# = userenv('SCHEMAID')
  and op.owner# = userenv('SCHEMAID')
  and n.obj# = op.obj#
  and n.ntab# = o.obj#
  and c.obj# = op.obj#
  and n.intcol# = c.intcol#
  and c.obj# = ac.obj#
  and c.intcol# = ac.intcol#
  and op.obj# = ct.obj#
  and ct.toid = ot.oid$
  and ct.intcol#=n.intcol#
  and ot.owner# = ut.user#
  and ct.toid=cl.toid
  and cl.elem_toid=t.tvoid
  and bitand(ct.flags,4)=4
  and bitand(c.property,32768) != 32768           /* not unused column */
union all
select o.name,
       nvl2(ct.synobj#, (select u.name from user$ u, obj$ o
            where o.owner#=u.user# and o.obj#=ct.synobj#), ut.name),
       nvl2(ct.synobj#, (select o.name from obj$ o
            where o.obj#=ct.synobj#), ot.name),
       op.name, c.name,
       lpad(decode(bitand(ct.flags, 64), 64, 'USER_SPECIFIED', 'DEFAULT'), 30),
       lpad(decode(bitand(ct.flags, 32), 32, 'LOCATOR', 'VALUE'), 20),
       lpad((case when bitand(ct.flags, 5120)=0 and bitand(t.properties, 8)= 8
       then 'Y' else 'N' end), 25)
from sys.ntab$ n, sys.obj$ o, sys.obj$ op, sys.obj$ ot,
  sys.col$ c, sys.coltype$ ct, sys.user$ ut, sys.type$ t, sys.collection$ cl
where o.owner# = userenv('SCHEMAID')
  and op.owner# = userenv('SCHEMAID')
  and  n.obj# = op.obj#
  and n.ntab# = o.obj#
  and c.obj# = op.obj#
  and n.intcol# = c.intcol#
  and bitand(c.property,1)=0
  and op.obj# = ct.obj#
  and ct.toid = ot.oid$
  and ct.intcol#=n.intcol#
  and ot.owner# = ut.user#
  and ct.toid=cl.toid
  and cl.elem_toid=t.tvoid
  and bitand(ct.flags,4)=4
  and bitand(c.property,32768) != 32768           /* not unused column */
/
create or replace public synonym USER_NESTED_TABLES for USER_NESTED_TABLES
/
grant select on USER_NESTED_TABLES to PUBLIC with grant option
/
comment on table USER_NESTED_TABLES is
'Description of nested tables contained in the user''s own tables'
/
comment on column USER_NESTED_TABLES.TABLE_NAME is
'Name of the nested table'
/
comment on column USER_NESTED_TABLES.TABLE_TYPE_OWNER is
'Owner of the type of which the nested table was created'
/
comment on column USER_NESTED_TABLES.TABLE_TYPE_NAME is
'Name of the type of the nested table'
/
comment on column USER_NESTED_TABLES.PARENT_TABLE_NAME is
'Name of the parent table containing the nested table'
/
comment on column USER_NESTED_TABLES.PARENT_TABLE_COLUMN is
'Column name of the parent table that corresponds to the nested table'
/
comment on column USER_NESTED_TABLES.ELEMENT_SUBSTITUTABLE is
'Indication of whether the nested table element is substitutable or not'
/

create or replace view ALL_NESTED_TABLES
    (OWNER, TABLE_NAME, TABLE_TYPE_OWNER, TABLE_TYPE_NAME, PARENT_TABLE_NAME,
     PARENT_TABLE_COLUMN, STORAGE_SPEC, RETURN_TYPE, ELEMENT_SUBSTITUTABLE)
as
select u.name, o.name,
       nvl2(ct.synobj#, (select u.name from user$ u, obj$ o
            where o.owner#=u.user# and o.obj#=ct.synobj#), ut.name),
       nvl2(ct.synobj#, (select o.name from obj$ o
            where o.obj#=ct.synobj#), ot.name),
       op.name, ac.name,
       lpad(decode(bitand(ct.flags, 64), 64, 'USER_SPECIFIED', 'DEFAULT'), 30),
       lpad(decode(bitand(ct.flags, 32), 32, 'LOCATOR', 'VALUE'), 20),
       lpad((case when bitand(ct.flags, 5120)=0 and bitand(t.properties, 8)= 8
       then 'Y' else 'N' end), 25)
from sys.ntab$ n, sys.obj$ o, sys.obj$ op, sys.obj$ ot,
  sys.col$ c, sys.coltype$ ct, sys.user$ u, sys.user$ ut, sys.attrcol$ ac,
  sys.type$ t, sys.collection$ cl
where o.owner# = u.user#
  and op.owner# = u.user#
  and n.obj# = op.obj#
  and n.ntab# = o.obj#
  and c.obj# = op.obj#
  and n.intcol# = c.intcol#
  and c.obj# = ac.obj#
  and c.intcol# = ac.intcol#
  and op.obj# = ct.obj#
  and ct.toid = ot.oid$
  and ct.intcol#=n.intcol#
  and ot.owner# = ut.user#
  and ct.toid=cl.toid
  and cl.elem_toid=t.tvoid
  and bitand(ct.flags,4)=4
  and bitand(c.property,32768) != 32768           /* not unused column */
  and (op.owner# = userenv('SCHEMAID')
       or op.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
union all
select u.name, o.name,
       nvl2(ct.synobj#, (select u.name from user$ u, obj$ o
            where o.owner#=u.user# and o.obj#=ct.synobj#), ut.name),
       nvl2(ct.synobj#, (select o.name from obj$ o
            where o.obj#=ct.synobj#), ot.name),
       op.name, c.name,
       lpad(decode(bitand(ct.flags, 64), 64, 'USER_SPECIFIED', 'DEFAULT'), 30),
       lpad(decode(bitand(ct.flags, 32), 32, 'LOCATOR', 'VALUE'), 20),
       lpad((case when bitand(ct.flags, 5120)=0 and bitand(t.properties, 8)= 8
       then 'Y' else 'N' end), 25)
from sys.ntab$ n, sys.obj$ o, sys.obj$ op, sys.obj$ ot, sys.col$ c,
  sys.coltype$ ct, sys.user$ u, sys.user$ ut, sys.type$ t, sys.collection$ cl
where o.owner# = u.user#
  and op.owner# = u.user#
  and n.obj# = op.obj#
  and n.ntab# = o.obj#
  and c.obj# = op.obj#
  and n.intcol# = c.intcol#
  and bitand(c.property,1)=0
  and op.obj# = ct.obj#
  and ct.toid = ot.oid$
  and ct.intcol#=n.intcol#
  and ot.owner# = ut.user#
  and ct.toid=cl.toid
  and cl.elem_toid=t.tvoid
  and bitand(ct.flags,4)=4
  and bitand(c.property,32768) != 32768           /* not unused column */
  and (op.owner# = userenv('SCHEMAID')
       or op.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
/
create or replace public synonym ALL_NESTED_TABLES for ALL_NESTED_TABLES
/
grant select on ALL_NESTED_TABLES to PUBLIC with grant option
/
comment on table ALL_NESTED_TABLES is
'Description of nested tables in tables accessible to the user'
/
comment on column ALL_NESTED_TABLES.OWNER is
'Owner of the nested table'
/
comment on column ALL_NESTED_TABLES.TABLE_NAME is
'Name of the nested table'
/
comment on column ALL_NESTED_TABLES.TABLE_TYPE_OWNER is
'Owner of the type of which the nested table was created'
/
comment on column ALL_NESTED_TABLES.TABLE_TYPE_NAME is
'Name of the type of the nested table'
/
comment on column ALL_NESTED_TABLES.PARENT_TABLE_NAME is
'Name of the parent table containing the nested table'
/
comment on column ALL_NESTED_TABLES.PARENT_TABLE_COLUMN is
'Column name of the parent table that corresponds to the nested table'
/
comment on column ALL_NESTED_TABLES.ELEMENT_SUBSTITUTABLE is
'Indication of whether the nested table element is substitutable or not'
/

create or replace view DBA_NESTED_TABLES
    (OWNER, TABLE_NAME, TABLE_TYPE_OWNER, TABLE_TYPE_NAME, PARENT_TABLE_NAME,
     PARENT_TABLE_COLUMN, STORAGE_SPEC, RETURN_TYPE, ELEMENT_SUBSTITUTABLE)
as
select u.name, o.name,
       nvl2(ct.synobj#, (select u.name from user$ u, obj$ o
            where o.owner#=u.user# and o.obj#=ct.synobj#), ut.name),
       nvl2(ct.synobj#, (select o.name from obj$ o
            where o.obj#=ct.synobj#), ot.name),
       op.name, ac.name,
       lpad(decode(bitand(ct.flags, 64), 64, 'USER_SPECIFIED', 'DEFAULT'), 30),
       lpad(decode(bitand(ct.flags, 32), 32, 'LOCATOR', 'VALUE'), 20),
       lpad((case when bitand(ct.flags, 5120)=0 and bitand(t.properties, 8)= 8
       then 'Y' else 'N' end), 25)
from sys.ntab$ n, sys.obj$ o, sys.obj$ op, sys.obj$ ot,
  sys.col$ c, sys.coltype$ ct, sys.user$ u, sys.user$ ut, sys.attrcol$ ac,
  sys.type$ t, sys.collection$ cl
where o.owner# = u.user#
  and op.owner# = u.user#
  and n.obj# = op.obj#
  and n.ntab# = o.obj#
  and c.obj# = op.obj#
  and n.intcol# = c.intcol#
  and c.obj# = ac.obj#
  and c.intcol# = ac.intcol#
  and op.obj# = ct.obj#
  and ct.toid = ot.oid$
  and ct.intcol#=n.intcol#
  and ot.owner# = ut.user#
  and ct.toid=cl.toid
  and cl.elem_toid=t.tvoid
  and bitand(ct.flags,4)=4
  and bitand(c.property,32768) != 32768           /* not unused column */
union all
select u.name, o.name,
       nvl2(ct.synobj#, (select u.name from user$ u, obj$ o
            where o.owner#=u.user# and o.obj#=ct.synobj#), ut.name),
       nvl2(ct.synobj#, (select o.name from obj$ o
            where o.obj#=ct.synobj#), ot.name),
       op.name, c.name,
       lpad(decode(bitand(ct.flags, 64), 64, 'USER_SPECIFIED', 'DEFAULT'), 30),
       lpad(decode(bitand(ct.flags, 32), 32, 'LOCATOR', 'VALUE'), 20),
       lpad((case when bitand(ct.flags, 5120)=0 and bitand(t.properties, 8)= 8
       then 'Y' else 'N' end), 25)
from sys.ntab$ n, sys.obj$ o, sys.obj$ op, sys.obj$ ot, sys.col$ c,
  sys.coltype$ ct, sys.user$ u, sys.user$ ut, sys.type$ t, sys.collection$ cl
where o.owner# = u.user#
  and op.owner# = u.user#
  and n.obj# = op.obj#
  and n.ntab# = o.obj#
  and c.obj# = op.obj#
  and n.intcol# = c.intcol#
  and bitand(c.property,1)=0
  and op.obj# = ct.obj#
  and ct.toid = ot.oid$
  and ct.intcol#=n.intcol#
  and ot.owner# = ut.user#
  and ct.toid=cl.toid
  and cl.elem_toid=t.tvoid
  and bitand(ct.flags,4)=4
  and bitand(c.property,32768) != 32768           /* not unused column */
/
create or replace public synonym DBA_NESTED_TABLES for DBA_NESTED_TABLES
/
grant select on DBA_NESTED_TABLES to select_catalog_role
/
comment on table DBA_NESTED_TABLES is
'Description of nested tables contained in all tables'
/
comment on column DBA_NESTED_TABLES.OWNER is
'Owner of the nested table'
/
comment on column DBA_NESTED_TABLES.TABLE_NAME is
'Name of the nested table'
/
comment on column DBA_NESTED_TABLES.TABLE_TYPE_OWNER is
'Owner of the type of which the nested table was created'
/
comment on column DBA_NESTED_TABLES.TABLE_TYPE_NAME is
'Name of the type of the nested table'
/
comment on column DBA_NESTED_TABLES.PARENT_TABLE_NAME is
'Name of the parent table containing the nested table'
/
comment on column DBA_NESTED_TABLES.PARENT_TABLE_COLUMN is
'Column name of the parent table that corresponds to the nested table'
/
comment on column DBA_NESTED_TABLES.ELEMENT_SUBSTITUTABLE is
'Indication of whether the nested table element is substitutable or not'
/

REM
REM  VARRAYS:
REM  Views for showing information about varrays
REM
create or replace view USER_VARRAYS
    (PARENT_TABLE_NAME, PARENT_TABLE_COLUMN, TYPE_OWNER, TYPE_NAME,
     LOB_NAME, STORAGE_SPEC, RETURN_TYPE, ELEMENT_SUBSTITUTABLE)
as
select distinct op.name, ac.name,
       nvl2(ct.synobj#, (select u.name from user$ u, obj$ o
            where o.owner#=u.user# and o.obj#=ct.synobj#), ut.name),
       nvl2(ct.synobj#, (select o.name from obj$ o
            where o.obj#=ct.synobj#), ot.name),
       NULL,
       lpad(decode(bitand(ct.flags, 64), 64, 'USER_SPECIFIED', 'DEFAULT'), 30),
       lpad(decode(bitand(ct.flags, 32), 32, 'LOCATOR', 'VALUE'), 20),
       lpad((case when bitand(ct.flags, 5120)=0 and bitand(t.properties, 8)= 8
       then 'Y' else 'N' end), 25)
from sys.obj$ op, sys.obj$ ot, sys.col$ c, sys.coltype$ ct, sys.user$ u,
  sys.user$ ut, sys.attrcol$ ac, sys.type$ t, sys.collection$ cl
where op.owner# = userenv('SCHEMAID')
  and c.obj# = op.obj#
  and c.obj# = ac.obj#
  and c.intcol# = ac.intcol#
  and op.obj# = ct.obj#
  and ct.toid = ot.oid$
  and ct.intcol# = c.intcol#
  and ot.owner# = ut.user#
  and ct.toid=cl.toid
  and cl.elem_toid=t.tvoid
  and bitand(ct.flags,8) = 8
  and bitand(c.property, 128) != 128
  and bitand(c.property,32768) != 32768           /* not unused column */
union all
select distinct op.name, ac.name,
       nvl2(ct.synobj#, (select u.name from user$ u, obj$ o
            where o.owner#=u.user# and o.obj#=ct.synobj#), ut.name),
       nvl2(ct.synobj#, (select o.name from obj$ o
            where o.obj#=ct.synobj#), ot.name),
       o.name,
       lpad(decode(bitand(ct.flags, 64), 64, 'USER_SPECIFIED', 'DEFAULT'), 30),
       lpad(decode(bitand(ct.flags, 32), 32, 'LOCATOR', 'VALUE'), 20),
       lpad((case when bitand(ct.flags, 5120)=0 and bitand(t.properties, 8)= 8
       then 'Y' else 'N' end), 25)
from sys.lob$ l, sys.obj$ o, sys.obj$ op, sys.obj$ ot, sys.col$ c,
  sys.coltype$ ct, sys.user$ u, sys.user$ ut, sys.attrcol$ ac, sys.type$ t,
  sys.collection$ cl
where o.owner# = userenv('SCHEMAID')
  and l.obj# = op.obj#
  and l.lobj# = o.obj#
  and c.obj# = op.obj#
  and l.intcol# = c.intcol#
  and c.obj# = ac.obj#
  and c.intcol# = ac.intcol#
  and op.obj# = ct.obj#
  and ct.toid = ot.oid$
  and ct.intcol#=l.intcol#
  and ot.owner# = ut.user#
  and ct.toid=cl.toid
  and cl.elem_toid=t.tvoid
  and bitand(ct.flags,8) = 8
  and bitand(c.property, 128) = 128
  and bitand(c.property,32768) != 32768           /* not unused column */
union all
select op.name, c.name,
       nvl2(ct.synobj#, (select u.name from user$ u, obj$ o
            where o.owner#=u.user# and o.obj#=ct.synobj#), ut.name),
       nvl2(ct.synobj#, (select o.name from obj$ o
            where o.obj#=ct.synobj#), ot.name),
       NULL,
       lpad(decode(bitand(ct.flags, 64), 64, 'USER_SPECIFIED', 'DEFAULT'), 30),
       lpad(decode(bitand(ct.flags, 32), 32, 'LOCATOR', 'VALUE'), 20),
       lpad((case when bitand(ct.flags, 5120)=0 and bitand(t.properties, 8)= 8
       then 'Y' else 'N' end), 25)
from sys.obj$ op, sys.obj$ ot, sys.col$ c, sys.coltype$ ct, sys.user$ ut,
  sys.type$ t, sys.collection$ cl
where op.owner# = userenv('SCHEMAID')
  and c.obj# = op.obj#
  and bitand(c.property,1)=0
  and op.obj# = ct.obj#
  and ct.toid = ot.oid$
  and ct.intcol# = c.intcol#
  and ot.owner# = ut.user#
  and ct.toid=cl.toid
  and cl.elem_toid=t.tvoid
  and bitand(ct.flags,8)=8
  and bitand(c.property, 128) != 128
  and bitand(c.property,32768) != 32768           /* not unused column */
union all
select op.name, c.name,
       nvl2(ct.synobj#, (select u.name from user$ u, obj$ o
            where o.owner#=u.user# and o.obj#=ct.synobj#), ut.name),
       nvl2(ct.synobj#, (select o.name from obj$ o
            where o.obj#=ct.synobj#), ot.name),
       o.name,
       lpad(decode(bitand(ct.flags, 64), 64, 'USER_SPECIFIED', 'DEFAULT'), 30),
       lpad(decode(bitand(ct.flags, 32), 32, 'LOCATOR', 'VALUE'), 20),
       lpad((case when bitand(ct.flags, 5120)=0 and bitand(t.properties, 8)= 8
       then 'Y' else 'N' end), 25)
from sys.lob$ l, sys.obj$ o, sys.obj$ op, sys.obj$ ot,
  sys.col$ c, sys.coltype$ ct, sys.user$ ut, sys.type$ t, sys.collection$ cl
where o.owner# = userenv('SCHEMAID')
  and l.obj# = op.obj#
  and l.lobj# = o.obj#
  and c.obj# = op.obj#
  and l.intcol# = c.intcol#
  and bitand(c.property,1)=0
  and op.obj# = ct.obj#
  and ct.toid = ot.oid$
  and ct.intcol#=l.intcol#
  and ot.owner# = ut.user#
  and ct.toid=cl.toid
  and cl.elem_toid=t.tvoid
  and bitand(ct.flags,8)=8
  and bitand(c.property, 128) = 128
  and bitand(c.property,32768) != 32768           /* not unused column */
/
create or replace public synonym USER_VARRAYS for USER_VARRAYS
/
grant select on USER_VARRAYS to PUBLIC with grant option
/
comment on table USER_VARRAYS is
'Description of varrays contained in the user''s own tables'
/
comment on column USER_VARRAYS.PARENT_TABLE_NAME is
'Name of the parent table containing the varray'
/
comment on column USER_VARRAYS.PARENT_TABLE_COLUMN is
'Column name of the parent table that corresponds to the varray'
/
comment on column USER_VARRAYS.TYPE_OWNER is
'Owner of the type of which the varray was created'
/
comment on column USER_VARRAYS.TYPE_NAME is
'Name of the type of the varray'
/
comment on column USER_VARRAYS.LOB_NAME is
'Name of the lob if varray is stored in a lob'
/
comment on column USER_VARRAYS.STORAGE_SPEC is
'Indication of default or user-specified storage for the varray'
/
comment on column USER_VARRAYS.RETURN_TYPE is
'Return type of the varray column locator or value'
/
comment on column USER_VARRAYS.ELEMENT_SUBSTITUTABLE is
'Indication of whether the varray element is substitutable or not'
/

create or replace view ALL_VARRAYS
    (OWNER, PARENT_TABLE_NAME, PARENT_TABLE_COLUMN, TYPE_OWNER, TYPE_NAME,
     LOB_NAME, STORAGE_SPEC, RETURN_TYPE, ELEMENT_SUBSTITUTABLE)
as
select u.name, op.name, ac.name,
       nvl2(ct.synobj#, (select u.name from user$ u, obj$ o
            where o.owner#=u.user# and o.obj#=ct.synobj#), ut.name),
       nvl2(ct.synobj#, (select o.name from obj$ o
            where o.obj#=ct.synobj#), ot.name),
       NULL,
       lpad(decode(bitand(ct.flags, 64), 64, 'USER_SPECIFIED', 'DEFAULT'), 30),
       lpad(decode(bitand(ct.flags, 32), 32, 'LOCATOR', 'VALUE'), 20),
       lpad((case when bitand(ct.flags, 5120)=0 and bitand(t.properties, 8)= 8
       then 'Y' else 'N' end), 25)
from sys.obj$ op, sys.obj$ ot, sys.col$ c, sys.coltype$ ct, sys.user$ u,
  sys.user$ ut, sys.attrcol$ ac, sys.type$ t, sys.collection$ cl
where op.owner# = u.user#
  and c.obj# = op.obj#
  and c.obj# = ac.obj#
  and c.intcol# = ac.intcol#
  and op.obj# = ct.obj#
  and ct.toid = ot.oid$
  and ct.intcol#=c.intcol#
  and ot.owner# = ut.user#
  and ct.toid=cl.toid
  and cl.elem_toid=t.tvoid
  and bitand(ct.flags,8)=8
  and bitand(c.property, 128) != 128
  and bitand(c.property,32768) != 32768           /* not unused column */
  and (op.owner# = userenv('SCHEMAID')
       or op.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
union all
select u.name, op.name, ac.name,
       nvl2(ct.synobj#, (select u.name from user$ u, obj$ o
            where o.owner#=u.user# and o.obj#=ct.synobj#), ut.name),
       nvl2(ct.synobj#, (select o.name from obj$ o
            where o.obj#=ct.synobj#), ot.name),
       o.name,
       lpad(decode(bitand(ct.flags, 64), 64, 'USER_SPECIFIED', 'DEFAULT'), 30),
       lpad(decode(bitand(ct.flags, 32), 32, 'LOCATOR', 'VALUE'), 20),
       lpad((case when bitand(ct.flags, 5120)=0 and bitand(t.properties, 8)= 8
       then 'Y' else 'N' end), 25)
from sys.lob$ l, sys.obj$ o, sys.obj$ op, sys.obj$ ot, sys.col$ c,
  sys.coltype$ ct, sys.user$ u, sys.user$ ut, sys.attrcol$ ac, sys.type$ t,
  sys.collection$ cl
where o.owner# = u.user#
  and l.obj# = op.obj#
  and l.lobj# = o.obj#
  and c.obj# = op.obj#
  and l.intcol# = c.intcol#
  and c.obj# = ac.obj#
  and c.intcol# = ac.intcol#
  and op.obj# = ct.obj#
  and ct.toid = ot.oid$
  and ct.intcol#=l.intcol#
  and ot.owner# = ut.user#
  and ct.toid=cl.toid
  and cl.elem_toid=t.tvoid
  and bitand(ct.flags,8)=8
  and bitand(c.property, 128) = 128
  and bitand(c.property,32768) != 32768           /* not unused column */
  and (op.owner# = userenv('SCHEMAID')
       or op.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
union all
select u.name, op.name, c.name,
       nvl2(ct.synobj#, (select u.name from user$ u, obj$ o
            where o.owner#=u.user# and o.obj#=ct.synobj#), ut.name),
       nvl2(ct.synobj#, (select o.name from obj$ o
            where o.obj#=ct.synobj#), ot.name),
       NULL,
       lpad(decode(bitand(ct.flags, 64), 64, 'USER_SPECIFIED', 'DEFAULT'), 30),
       lpad(decode(bitand(ct.flags, 32), 32, 'LOCATOR', 'VALUE'), 20),
       lpad((case when bitand(ct.flags, 5120)=0 and bitand(t.properties, 8)= 8
       then 'Y' else 'N' end), 25)
from sys.obj$ op, sys.obj$ ot, sys.col$ c, sys.coltype$ ct, sys.user$ u,
  sys.user$ ut, sys.type$ t, sys.collection$ cl
where op.owner# = u.user#
  and c.obj# = op.obj#
  and bitand(c.property,1)=0
  and op.obj# = ct.obj#
  and ct.toid = ot.oid$
  and ct.intcol#=c.intcol#
  and ot.owner# = ut.user#
  and ct.toid=cl.toid
  and cl.elem_toid=t.tvoid
  and bitand(ct.flags,8)=8
  and bitand(c.property, 128) != 128
  and bitand(c.property,32768) != 32768           /* not unused column */
  and (op.owner# = userenv('SCHEMAID')
       or op.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
union all
select u.name, op.name, c.name,
       nvl2(ct.synobj#, (select u.name from user$ u, obj$ o
            where o.owner#=u.user# and o.obj#=ct.synobj#), ut.name),
       nvl2(ct.synobj#, (select o.name from obj$ o
            where o.obj#=ct.synobj#), ot.name),
       o.name,
       lpad(decode(bitand(ct.flags, 64), 64, 'USER_SPECIFIED', 'DEFAULT'), 30),
       lpad(decode(bitand(ct.flags, 32), 32, 'LOCATOR', 'VALUE'), 20),
       lpad((case when bitand(ct.flags, 5120)=0 and bitand(t.properties, 8)= 8
       then 'Y' else 'N' end), 25)
from sys.lob$ l, sys.obj$ o, sys.obj$ op, sys.obj$ ot, sys.col$ c,
  sys.coltype$ ct, sys.user$ u, sys.user$ ut, sys.type$ t, sys.collection$ cl
where o.owner# = u.user#
  and l.obj# = op.obj#
  and l.lobj# = o.obj#
  and c.obj# = op.obj#
  and l.intcol# = c.intcol#
  and bitand(c.property,1)=0
  and op.obj# = ct.obj#
  and ct.toid = ot.oid$
  and ct.intcol#=l.intcol#
  and ot.owner# = ut.user#
  and ct.toid=cl.toid
  and cl.elem_toid=t.tvoid
  and bitand(ct.flags,8)=8
  and bitand(c.property, 128) = 128
  and bitand(c.property,32768) != 32768           /* not unused column */
  and (op.owner# = userenv('SCHEMAID')
       or op.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
/
create or replace public synonym ALL_VARRAYS for ALL_VARRAYS
/
grant select on ALL_VARRAYS to PUBLIC with grant option
/
comment on table ALL_VARRAYS is
'Description of varrays in tables accessible to the user'
/
comment on column ALL_VARRAYS.OWNER is
'Owner of the varray'
/
comment on column ALL_VARRAYS.PARENT_TABLE_NAME is
'Name of the parent table containing the varray'
/
comment on column ALL_VARRAYS.PARENT_TABLE_COLUMN is
'Column name of the parent table that corresponds to the varray'
/
comment on column ALL_VARRAYS.TYPE_OWNER is
'Owner of the type of which the varray was created'
/
comment on column ALL_VARRAYS.TYPE_NAME is
'Name of the type of the varray'
/
comment on column ALL_VARRAYS.LOB_NAME is
'Name of the lob if varray is stored in a lob'
/
comment on column ALL_VARRAYS.STORAGE_SPEC is
'Indication of default or user-specified storage for the varray'
/
comment on column ALL_VARRAYS.RETURN_TYPE is
'Return type of the varray column locator or value'
/
comment on column ALL_VARRAYS.ELEMENT_SUBSTITUTABLE is
'Indication of whether the varray element is substitutable or not'
/

create or replace view DBA_VARRAYS
    (OWNER, PARENT_TABLE_NAME, PARENT_TABLE_COLUMN, TYPE_OWNER, TYPE_NAME,
     LOB_NAME, STORAGE_SPEC, RETURN_TYPE, ELEMENT_SUBSTITUTABLE)
as
select u.name, op.name, ac.name,
       nvl2(ct.synobj#, (select u.name from user$ u, obj$ o
            where o.owner#=u.user# and o.obj#=ct.synobj#), ut.name),
       nvl2(ct.synobj#, (select o.name from obj$ o
            where o.obj#=ct.synobj#), ot.name),
       NULL,
       lpad(decode(bitand(ct.flags, 64), 64, 'USER_SPECIFIED', 'DEFAULT'), 30),
       lpad(decode(bitand(ct.flags, 32), 32, 'LOCATOR', 'VALUE'), 20),
       lpad((case when bitand(ct.flags, 5120)=0 and bitand(t.properties, 8)= 8
       then 'Y' else 'N' end), 25)
from sys.obj$ op, sys.obj$ ot, sys.col$ c, sys.coltype$ ct, sys.user$ u,
  sys.user$ ut, sys.attrcol$ ac, sys.type$ t, sys.collection$ cl
where op.owner# = u.user#
  and c.obj# = op.obj#
  and c.obj# = ac.obj#
  and c.intcol# = ac.intcol#
  and op.obj# = ct.obj#
  and ct.toid = ot.oid$
  and ct.intcol#=c.intcol#
  and ot.owner# = ut.user#
  and ct.toid=cl.toid
  and cl.elem_toid=t.tvoid
  and bitand(ct.flags,8)=8
  and bitand(c.property, 128) != 128
  and bitand(c.property,32768) != 32768           /* not unused column */
union all
select u.name, op.name, ac.name,
       nvl2(ct.synobj#, (select u.name from user$ u, obj$ o
            where o.owner#=u.user# and o.obj#=ct.synobj#), ut.name),
       nvl2(ct.synobj#, (select o.name from obj$ o
            where o.obj#=ct.synobj#), ot.name),
       o.name,
       lpad(decode(bitand(ct.flags, 64), 64, 'USER_SPECIFIED', 'DEFAULT'), 30),
       lpad(decode(bitand(ct.flags, 32), 32, 'LOCATOR', 'VALUE'), 20),
       lpad((case when bitand(ct.flags, 5120)=0 and bitand(t.properties, 8)= 8
       then 'Y' else 'N' end), 25)
from sys.lob$ l, sys.obj$ o, sys.obj$ op, sys.obj$ ot, sys.col$ c,
  sys.coltype$ ct, sys.user$ u, sys.user$ ut, sys.attrcol$ ac, sys.type$ t,
  sys.collection$ cl
where o.owner# = u.user#
  and l.obj# = op.obj#
  and l.lobj# = o.obj#
  and c.obj# = op.obj#
  and l.intcol# = c.intcol#
  and c.obj# = ac.obj#
  and c.intcol# = ac.intcol#
  and op.obj# = ct.obj#
  and ct.toid = ot.oid$
  and ct.intcol#=l.intcol#
  and ot.owner# = ut.user#
  and ct.toid=cl.toid
  and cl.elem_toid=t.tvoid
  and bitand(ct.flags,8)=8
  and bitand(c.property, 128) = 128
  and bitand(c.property,32768) != 32768           /* not unused column */
union all
select u.name, op.name, c.name,
       nvl2(ct.synobj#, (select u.name from user$ u, obj$ o
            where o.owner#=u.user# and o.obj#=ct.synobj#), ut.name),
       nvl2(ct.synobj#, (select o.name from obj$ o
            where o.obj#=ct.synobj#), ot.name),
       NULL,
       lpad(decode(bitand(ct.flags, 64), 64, 'USER_SPECIFIED', 'DEFAULT'), 30),
       lpad(decode(bitand(ct.flags, 32), 32, 'LOCATOR', 'VALUE'), 20),
       lpad((case when bitand(ct.flags, 5120)=0 and bitand(t.properties, 8)= 8
       then 'Y' else 'N' end), 25)
from sys.obj$ op, sys.obj$ ot, sys.col$ c, sys.coltype$ ct, sys.user$ u,
  sys.user$ ut, sys.type$ t, sys.collection$ cl
where op.owner# = u.user#
  and c.obj# = op.obj#
  and bitand(c.property,1)=0
  and op.obj# = ct.obj#
  and ct.toid = ot.oid$
  and ct.intcol#=c.intcol#
  and ot.owner# = ut.user#
  and ct.toid=cl.toid
  and cl.elem_toid=t.tvoid
  and bitand(ct.flags,8)=8
  and bitand(c.property, 128) != 128
  and bitand(c.property,32768) != 32768           /* not unused column */
union all
select u.name, op.name, c.name,
       nvl2(ct.synobj#, (select u.name from user$ u, obj$ o
            where o.owner#=u.user# and o.obj#=ct.synobj#), ut.name),
       nvl2(ct.synobj#, (select o.name from obj$ o
            where o.obj#=ct.synobj#), ot.name),
       o.name,
       lpad(decode(bitand(ct.flags, 64), 64, 'USER_SPECIFIED', 'DEFAULT'), 30),
       lpad(decode(bitand(ct.flags, 32), 32, 'LOCATOR', 'VALUE'), 20),
       lpad((case when bitand(ct.flags, 5120)=0 and bitand(t.properties, 8)= 8
       then 'Y' else 'N' end), 25)
from sys.lob$ l, sys.obj$ o, sys.obj$ op, sys.obj$ ot, sys.col$ c,
  sys.coltype$ ct, sys.user$ u, sys.user$ ut, sys.type$ t, sys.collection$ cl
where o.owner# = u.user#
  and l.obj# = op.obj#
  and l.lobj# = o.obj#
  and c.obj# = op.obj#
  and l.intcol# = c.intcol#
  and bitand(c.property,1)=0
  and op.obj# = ct.obj#
  and ct.toid = ot.oid$
  and ct.intcol#=l.intcol#
  and ot.owner# = ut.user#
  and ct.toid=cl.toid
  and cl.elem_toid=t.tvoid
  and bitand(ct.flags,8)=8
  and bitand(c.property, 128) = 128
  and bitand(c.property,32768) != 32768           /* not unused column */
/
create or replace public synonym DBA_VARRAYS for DBA_VARRAYS
/
grant select on DBA_VARRAYS to select_catalog_role
/
comment on table DBA_VARRAYS is
'Description of varrays in tables accessible to the user'
/
comment on column DBA_VARRAYS.OWNER is
'Owner of the varray'
/
comment on column DBA_VARRAYS.PARENT_TABLE_NAME is
'Name of the parent table containing the varray'
/
comment on column DBA_VARRAYS.PARENT_TABLE_COLUMN is
'Column name of the parent table that corresponds to the varray'
/
comment on column DBA_VARRAYS.TYPE_OWNER is
'Owner of the type of which the varray was created'
/
comment on column DBA_VARRAYS.TYPE_NAME is
'Name of the type of the varray'
/
comment on column DBA_VARRAYS.LOB_NAME is
'Name of the lob if varray is stored in a lob'
/
comment on column DBA_VARRAYS.STORAGE_SPEC is
'Indication of default or user-specified storage for the varray'
/
comment on column DBA_VARRAYS.RETURN_TYPE is
'Return type of the varray column locator or value'
/
comment on column DBA_VARRAYS.ELEMENT_SUBSTITUTABLE is
'Indication of whether the varray element is substitutable or not'
/

REM
REM Object Columns and Attributes
REM
create or replace view USER_OBJ_COLATTRS
    (TABLE_NAME, COLUMN_NAME, SUBSTITUTABLE)
as
select o.name, c.name, lpad(decode(bitand(ct.flags, 512), 512, 'Y', 'N'), 15)
from sys.coltype$ ct, sys.obj$ o, sys.col$ c
where o.owner# = userenv('SCHEMAID')
  and bitand(ct.flags, 2) = 2                                 /* ADT column */
  and o.obj#=ct.obj#
  and o.obj#=c.obj#
  and c.intcol#=ct.intcol#
  and bitand(c.property,32768) != 32768                /* not unused column */
  and not exists (select null                  /* Doesn't exist in attrcol$ */
                  from sys.attrcol$ ac
                  where ac.intcol#=ct.intcol#
                        and ac.obj#=ct.obj#)
union all
select o.name, ac.name, lpad(decode(bitand(ct.flags, 512), 512, 'Y', 'N'), 15)
from sys.coltype$ ct, sys.obj$ o, sys.attrcol$ ac, col$ c
where o.owner# = userenv('SCHEMAID')
  and bitand(ct.flags, 2) = 2                                  /* ADT column */
  and o.obj#=ct.obj#
  and o.obj#=c.obj#
  and o.obj#=ac.obj#
  and c.intcol#=ct.intcol#
  and c.intcol#=ac.intcol#
  and bitand(c.property,32768) != 32768                 /* not unused column */
/
create or replace public synonym USER_OBJ_COLATTRS for USER_OBJ_COLATTRS
/
grant select on USER_OBJ_COLATTRS to PUBLIC with grant option
/
comment on table USER_OBJ_COLATTRS is
'Description of object columns and attributes contained in tables owned by the user'
/
comment on column USER_OBJ_COLATTRS.TABLE_NAME is
'Name of the table containing the object column or attribute'
/
comment on column USER_OBJ_COLATTRS.COLUMN_NAME is
'Fully qualified name of the object column or attribute'
/
comment on column USER_OBJ_COLATTRS.SUBSTITUTABLE is
'Indication of whether the column is substitutable or not'
/

create or replace view ALL_OBJ_COLATTRS
    (OWNER, TABLE_NAME, COLUMN_NAME, SUBSTITUTABLE)
as
select u.name, o.name, c.name,
  lpad(decode(bitand(ct.flags, 512), 512, 'Y', 'N'), 15)
from sys.coltype$ ct, sys.obj$ o, sys.col$ c, sys.user$ u
where o.owner# = u.user#
  and bitand(ct.flags, 2) = 2                                 /* ADT column */
  and o.obj#=ct.obj#
  and o.obj#=c.obj#
  and c.intcol#=ct.intcol#
  and bitand(c.property,32768) != 32768                 /* not unused column */
  and not exists (select null                   /* Doesn't exist in attrcol$ */
                  from sys.attrcol$ ac
                  where ac.intcol#=ct.intcol#
                        and ac.obj#=ct.obj#)
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
union all
select u.name, o.name, ac.name,
  lpad(decode(bitand(ct.flags, 512), 512, 'Y', 'N'), 15)
from sys.coltype$ ct, sys.obj$ o, sys.attrcol$ ac, sys.user$ u, col$ c
where o.owner# = u.user#
  and bitand(ct.flags, 2) = 2                                /* ADT column */
  and o.obj#=ct.obj#
  and o.obj#=c.obj#
  and o.obj#=ac.obj#
  and c.intcol#=ct.intcol#
  and c.intcol#=ac.intcol#
  and bitand(c.property,32768) != 32768               /* not unused column */
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
/
create or replace public synonym ALL_OBJ_COLATTRS for ALL_OBJ_COLATTRS
/
grant select on ALL_OBJ_COLATTRS to PUBLIC with grant option
/
comment on table ALL_OBJ_COLATTRS is
'Description of object columns and attributes contained in the tables accessible to the user'
/
comment on column ALL_OBJ_COLATTRS.OWNER is
'Owner of the table'
/
comment on column ALL_OBJ_COLATTRS.TABLE_NAME is
'Name of the table containing the object column or attribute'
/
comment on column ALL_OBJ_COLATTRS.COLUMN_NAME is
'Fully qualified name of the object column or attribute'
/
comment on column ALL_OBJ_COLATTRS.SUBSTITUTABLE is
'Indication of whether the column is substitutable or not'
/

create or replace view DBA_OBJ_COLATTRS
    (OWNER, TABLE_NAME, COLUMN_NAME, SUBSTITUTABLE)
as
select u.name, o.name, c.name,
  lpad(decode(bitand(ct.flags, 512), 512, 'Y', 'N'), 15)
from sys.coltype$ ct, sys.obj$ o, sys.col$ c, sys.user$ u
where o.owner# = u.user#
  and bitand(ct.flags, 2) = 2                                 /* ADT column */
  and o.obj#=ct.obj#
  and o.obj#=c.obj#
  and c.intcol#=ct.intcol#
  and bitand(c.property,32768) != 32768                 /* not unused column */
  and not exists (select null                   /* Doesn't exist in attrcol$ */
                  from sys.attrcol$ ac
                  where ac.intcol#=ct.intcol#
                        and ac.obj#=ct.obj#)
union all
select u.name, o.name, ac.name,
  lpad(decode(bitand(ct.flags, 512), 512, 'Y', 'N'), 15)
from sys.coltype$ ct, sys.obj$ o, sys.attrcol$ ac, sys.user$ u, col$ c
where o.owner# = u.user#
  and bitand(ct.flags, 2) = 2                                 /* ADT column */
  and o.obj#=ct.obj#
  and o.obj#=c.obj#
  and o.obj#=ac.obj#
  and c.intcol#=ct.intcol#
  and c.intcol#=ac.intcol#
  and bitand(c.property,32768) != 32768                /* not unused column */
/
create or replace public synonym DBA_OBJ_COLATTRS for DBA_OBJ_COLATTRS
/
grant select on DBA_OBJ_COLATTRS to select_catalog_role
/
comment on table DBA_OBJ_COLATTRS is
'Description of object columns and attributes contained in all tables in the database'
/
comment on column DBA_OBJ_COLATTRS.OWNER is
'Owner of the table'
/
comment on column DBA_OBJ_COLATTRS.TABLE_NAME is
'Name of the table containing the object column or attribute'
/
comment on column DBA_OBJ_COLATTRS.COLUMN_NAME is
'Fully qualified name of the object column or attribute'
/
comment on column DBA_OBJ_COLATTRS.SUBSTITUTABLE is
'Indication of whether the column is substitutable or not'
/

Rem
Rem Constrained substitutability info
Rem
create or replace view USER_CONS_OBJ_COLUMNS
    (TABLE_NAME, COLUMN_NAME, CONS_TYPE_OWNER, CONS_TYPE_NAME, CONS_TYPE_ONLY)
as
select oc.name, c.name, ut.name, ot.name,
       lpad(decode(bitand(sc.flags, 2), 2, 'Y', 'N'), 15)
from sys.obj$ oc, sys.col$ c, sys.user$ ut, sys.obj$ ot, sys.subcoltype$ sc
where oc.owner# = userenv('SCHEMAID')
  and bitand(sc.flags, 1) = 1      /* Type is specified in the IS OF clause */
  and oc.obj#=sc.obj#
  and oc.obj#=c.obj#
  and c.intcol#=sc.intcol#
  and sc.toid=ot.oid$
  and ot.owner#=ut.user#
  and bitand(c.property,32768) != 32768                /* not unused column */
  and not exists (select null                  /* Doesn't exist in attrcol$ */
                  from sys.attrcol$ ac
                  where ac.intcol#=sc.intcol#
                        and ac.obj#=sc.obj#)
union all
select oc.name, ac.name, ut.name, ot.name,
       lpad(decode(bitand(sc.flags, 2), 2, 'Y', 'N'), 15)
from sys.obj$ oc, sys.col$ c, sys.user$ ut, sys.obj$ ot, sys.subcoltype$ sc,
     sys.attrcol$ ac
where oc.owner# = userenv('SCHEMAID')
  and bitand(sc.flags, 1) = 1      /* Type is specified in the IS OF clause */
  and oc.obj#=sc.obj#
  and oc.obj#=c.obj#
  and oc.obj#=ac.obj#
  and c.intcol#=sc.intcol#
  and ac.intcol#=sc.intcol#
  and sc.toid=ot.oid$
  and ot.owner#=ut.user#
  and bitand(c.property,32768) != 32768                /* not unused column */
/
create or replace public synonym USER_CONS_OBJ_COLUMNS for USER_CONS_OBJ_COLUMNS
/
grant select on USER_CONS_OBJ_COLUMNS to PUBLIC with grant option
/
comment on table USER_CONS_OBJ_COLUMNS is
'List of types an object column or attribute is constrained to in the tables owned by the user'
/
comment on column USER_CONS_OBJ_COLUMNS.TABLE_NAME is
'Name of the table containing the object column or attribute'
/
comment on column USER_CONS_OBJ_COLUMNS.COLUMN_NAME is
'Fully qualified name of the object column or attribute'
/
comment on column USER_CONS_OBJ_COLUMNS.CONS_TYPE_OWNER is
'Owner of the type that the column is constrained to'
/
comment on column USER_CONS_OBJ_COLUMNS.CONS_TYPE_NAME is
'Name of the type that the column is constrained to'
/
comment on column USER_CONS_OBJ_COLUMNS.CONS_TYPE_ONLY is
'Indication of whether the column is constrained to ONLY type'
/

create or replace view ALL_CONS_OBJ_COLUMNS
    (OWNER, TABLE_NAME, COLUMN_NAME, CONS_TYPE_OWNER, CONS_TYPE_NAME,
     CONS_TYPE_ONLY)
as
select uc.name, oc.name, c.name, ut.name, ot.name,
       lpad(decode(bitand(sc.flags, 2), 2, 'Y', 'N'), 15)
from sys.user$ uc, sys.obj$ oc, sys.col$ c, sys.user$ ut, sys.obj$ ot,
     sys.subcoltype$ sc
where oc.owner# = uc.user#
  and bitand(sc.flags, 1) = 1      /* Type is specified in the IS OF clause */
  and oc.obj#=sc.obj#
  and oc.obj#=c.obj#
  and c.intcol#=sc.intcol#
  and sc.toid=ot.oid$
  and ot.owner#=ut.user#
  and bitand(c.property,32768) != 32768                /* not unused column */
  and not exists (select null                  /* Doesn't exist in attrcol$ */
                  from sys.attrcol$ ac
                  where ac.intcol#=sc.intcol#
                        and ac.obj#=sc.obj#)
  and (oc.owner# = userenv('SCHEMAID')
       or oc.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
union all
select uc.name, oc.name, ac.name, ut.name, ot.name,
       lpad(decode(bitand(sc.flags, 2), 2, 'Y', 'N'), 15)
from sys.user$ uc, sys.obj$ oc, sys.col$ c, sys.user$ ut, sys.obj$ ot,
     sys.subcoltype$ sc, sys.attrcol$ ac
where oc.owner# = uc.user#
  and bitand(sc.flags, 1) = 1      /* Type is specified in the IS OF clause */
  and oc.obj#=sc.obj#
  and oc.obj#=c.obj#
  and oc.obj#=ac.obj#
  and c.intcol#=sc.intcol#
  and ac.intcol#=sc.intcol#
  and sc.toid=ot.oid$
  and ot.owner#=ut.user#
  and bitand(c.property,32768) != 32768                /* not unused column */
  and (oc.owner# = userenv('SCHEMAID')
       or oc.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
/
create or replace public synonym ALL_CONS_OBJ_COLUMNS for ALL_CONS_OBJ_COLUMNS
/
grant select on ALL_CONS_OBJ_COLUMNS to PUBLIC with grant option
/
comment on table ALL_CONS_OBJ_COLUMNS is
'List of types an object column or attribute is constrained to in the tables accessible to the user'
/
comment on column ALL_CONS_OBJ_COLUMNS.OWNER is
'Owner of the table'
/
comment on column ALL_CONS_OBJ_COLUMNS.TABLE_NAME is
'Name of the table containing the object column or attribute'
/
comment on column ALL_CONS_OBJ_COLUMNS.COLUMN_NAME is
'Fully qualified name of the object column or attribute'
/
comment on column ALL_CONS_OBJ_COLUMNS.CONS_TYPE_OWNER is
'Owner of the type that the column is constrained to'
/
comment on column ALL_CONS_OBJ_COLUMNS.CONS_TYPE_NAME is
'Name of the type that the column is constrained to'
/
comment on column ALL_CONS_OBJ_COLUMNS.CONS_TYPE_ONLY is
'Indication of whether the column is constrained to ONLY type'
/

create or replace view DBA_CONS_OBJ_COLUMNS
    (OWNER, TABLE_NAME, COLUMN_NAME, CONS_TYPE_OWNER, CONS_TYPE_NAME,
     CONS_TYPE_ONLY)
as
select uc.name, oc.name, c.name, ut.name, ot.name,
       lpad(decode(bitand(sc.flags, 2), 2, 'Y', 'N'), 15)
from sys.user$ uc, sys.obj$ oc, sys.col$ c, sys.user$ ut, sys.obj$ ot,
     sys.subcoltype$ sc
where oc.owner# = uc.user#
  and bitand(sc.flags, 1) = 1      /* Type is specified in the IS OF clause */
  and oc.obj#=sc.obj#
  and oc.obj#=c.obj#
  and c.intcol#=sc.intcol#
  and sc.toid=ot.oid$
  and ot.owner#=ut.user#
  and bitand(c.property,32768) != 32768                /* not unused column */
  and not exists (select null                  /* Doesn't exist in attrcol$ */
                  from sys.attrcol$ ac
                  where ac.intcol#=sc.intcol#
                        and ac.obj#=sc.obj#)
union all
select uc.name, oc.name, ac.name, ut.name, ot.name,
       lpad(decode(bitand(sc.flags, 2), 2, 'Y', 'N'), 15)
from sys.user$ uc, sys.obj$ oc, sys.col$ c, sys.user$ ut, sys.obj$ ot,
     sys.subcoltype$ sc, sys.attrcol$ ac
where oc.owner# = uc.user#
  and bitand(sc.flags, 1) = 1      /* Type is specified in the IS OF clause */
  and oc.obj#=sc.obj#
  and oc.obj#=c.obj#
  and oc.obj#=ac.obj#
  and c.intcol#=sc.intcol#
  and ac.intcol#=sc.intcol#
  and sc.toid=ot.oid$
  and ot.owner#=ut.user#
  and bitand(c.property,32768) != 32768                /* not unused column */
/
create or replace public synonym DBA_CONS_OBJ_COLUMNS for DBA_CONS_OBJ_COLUMNS
/
grant select on DBA_CONS_OBJ_COLUMNS to select_catalog_role
/
comment on table DBA_CONS_OBJ_COLUMNS is
'List of types an object column or attribute is constrained to in all tables in the database'
/
comment on column DBA_CONS_OBJ_COLUMNS.OWNER is
'Owner of the table'
/
comment on column DBA_CONS_OBJ_COLUMNS.TABLE_NAME is
'Name of the table containing the object column or attribute'
/
comment on column DBA_CONS_OBJ_COLUMNS.COLUMN_NAME is
'Fully qualified name of the object column or attribute'
/
comment on column DBA_CONS_OBJ_COLUMNS.CONS_TYPE_OWNER is
'Owner of the type that the column is constrained to'
/
comment on column DBA_CONS_OBJ_COLUMNS.CONS_TYPE_NAME is
'Name of the type that the column is constrained to'
/
comment on column DBA_CONS_OBJ_COLUMNS.CONS_TYPE_ONLY is
'Indication of whether the column is constrained to ONLY type'
/

Rem
Rem ALL_SUMDELTA View
Rem
create or replace view ALL_SUMDELTA
    (TABLEOBJ#, PARTITIONOBJ#, DMLOPERATION, SCN,
     TIMESTAMP, LOWROWID, HIGHROWID, SEQUENCE)
as select s.TABLEOBJ#, s.PARTITIONOBJ#, s.DMLOPERATION, s.SCN,
          s.TIMESTAMP, s.LOWROWID, s.HIGHROWID, s.SEQUENCE
from  sys.obj$ o, sys.user$ u, sys.sumdelta$ s
where o.type# = 2
  and o.owner# = u.user#
  and s.tableobj# = o.obj#
  and (o.owner# = userenv('SCHEMAID')
    or o.obj# in
      (select oa.obj#
         from sys.objauth$ oa
         where grantee# in ( select kzsrorol from x$kzsro)
      )
    or /* user has system privileges */
      exists (select null from v$enabledprivs
        where priv_number in (-45 /* LOCK ANY TABLE */,
                              -47 /* SELECT ANY TABLE */,
                              -48 /* INSERT ANY TABLE */,
                              -49 /* UPDATE ANY TABLE */,
                              -50 /* DELETE ANY TABLE */)
              )
      )
/
comment on table ALL_SUMDELTA is
'Direct path load entries accessible to the user'
/
comment on column ALL_SUMDELTA.TABLEOBJ# is
'Object number of the table'
/
comment on column ALL_SUMDELTA.PARTITIONOBJ# is
'Object number of table partitions (if the table is partitioned)'
/
comment on column ALL_SUMDELTA.DMLOPERATION is
'Type of DML operation applied to the table'
/
comment on column ALL_SUMDELTA.SCN is
'SCN when the bulk DML occurred'
/
comment on column ALL_SUMDELTA.TIMESTAMP is
'Timestamp of log entry'
/
comment on column ALL_SUMDELTA.LOWROWID is
'The start ROWID in the loaded rowid range'
/
comment on column ALL_SUMDELTA.HIGHROWID is
'The end ROWID in the loaded rowid range'
/
comment on column ALL_SUMDELTA.SEQUENCE is
'The sequence# of the direct load'
/
create or replace public synonym ALL_SUMDELTA for ALL_SUMDELTA
/
grant select on ALL_SUMDELTA to PUBLIC with grant option
/

create or replace view DBA_OPERATORS
    (OWNER, OPERATOR_NAME, NUMBER_OF_BINDS)
as
select c.name, b.name, a.numbind from
  sys.operator$ a, sys.obj$ b, sys.user$ c where
  a.obj# = b.obj# and b.owner# = c.user#
/
create or replace public synonym DBA_OPERATORS for DBA_OPERATORS
/
grant select on DBA_OPERATORS to select_catalog_role
/
comment on table DBA_OPERATORS is
'All operators'
/
comment on column DBA_OPERATORS.OWNER is
'Owner of the operator'
/
comment on column DBA_OPERATORS.OPERATOR_NAME is
'Name of the operator'
/
comment on column DBA_OPERATORS.NUMBER_OF_BINDS is
'Number of bindings associated with the operator'
/

create or replace view ALL_OPERATORS
    (OWNER, OPERATOR_NAME, NUMBER_OF_BINDS)
as
select c.name, b.name, a.numbind from
  sys.operator$ a, sys.obj$ b, sys.user$ c where
  a.obj# = b.obj# and b.owner# = c.user# and
  ( b.owner# = userenv ('SCHEMAID')
    or
    b.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or exists (select null from v$enabledprivs
                  where priv_number in (-200 /* CREATE OPERATOR */,
                                        -201 /* CREATE ANY OPERATOR */,
                                        -202 /* ALTER ANY OPERATOR */,
                                        -203 /* DROP ANY OPERATOR */,
                                        -204 /* EXECUTE OPERATOR */)
                 )
      )
/
create or replace public synonym ALL_OPERATORS for ALL_OPERATORS
/
grant select on ALL_OPERATORS to PUBLIC with grant option
/
Comment on table ALL_OPERATORS is
'All operators available to the user'
/
Comment on column ALL_OPERATORS.OWNER is
'Owner of the operator'
/
Comment on column ALL_OPERATORS.OPERATOR_NAME is
'Name of the operator'
/
Comment on column ALL_OPERATORS.NUMBER_OF_BINDS is
'Number of bindings associated with the operator'
/

create or replace view USER_OPERATORS
    (OWNER, OPERATOR_NAME, NUMBER_OF_BINDS)
as
select c.name, b.name, a.numbind from
  sys.operator$ a, sys.obj$ b, sys.user$ c where
  a.obj# = b.obj# and b.owner# = c.user# and
  b.owner# = userenv ('SCHEMAID')
/
create or replace public synonym USER_OPERATORS for USER_OPERATORS
/
grant select on USER_OPERATORS to PUBLIC with grant option
/
Comment on table USER_OPERATORS is
'All user operators'
/
Comment on column USER_OPERATORS.OWNER is
'Owner of the operator'
/
Comment on column USER_OPERATORS.OPERATOR_NAME is
'Name of the operator'
/
Comment on column USER_OPERATORS.NUMBER_OF_BINDS is
'Number of bindings associated with the operator'
/

create or replace view DBA_OPBINDINGS
    (OWNER, OPERATOR_NAME, BINDING#, FUNCTION_NAME, RETURN_SCHEMA,
     RETURN_TYPE, IMPLEMENTATION_TYPE_SCHEMA, IMPLEMENTATION_TYPE, PROPERTY)
as
select c.name, b.name, a.bind#, a.functionname, a.returnschema,
        a.returntype, a.impschema, a.imptype,
        decode(bitand(a.property,31), 1, 'WITH INDEX CONTEXT',
               3 , 'COMPUTE ANCILLARY DATA', 4 , 'ANCILLARY TO' ,
               16 , 'WITH COLUMN CONTEXT' ,
               17,  'WITH INDEX, COLUMN CONTEXT',
               19, 'COMPUTE ANCILLARY DATA, WITH COLUMN CONTEXT')
  from  sys.opbinding$ a, sys.obj$ b, sys.user$ c
  where a.obj# = b.obj# and b.owner# = c.user#
/
create or replace public synonym DBA_OPBINDINGS for DBA_OPBINDINGS
/
grant select on DBA_OPBINDINGS to select_catalog_role
/
Comment on table DBA_OPBINDINGS is
'All operator binding functiosn or methods'
/
Comment on column DBA_OPBINDINGS.OWNER is
'Owner of the operator'
/
Comment on column DBA_OPBINDINGS.OPERATOR_NAME is
'Name of the operator'
/
Comment on column DBA_OPBINDINGS.BINDING# is
'Binding# of the operator'
/
Comment on column DBA_OPBINDINGS.FUNCTION_NAME is
'Name of the binding function or method as specified by the user'
/
Comment on column DBA_OPBINDINGS.RETURN_SCHEMA is
'Name of the schema of the return type - not null only for ADTs'
/
Comment on column DBA_OPBINDINGS.RETURN_TYPE is
'Name of the return type'
/
Comment on column DBA_OPBINDINGS.IMPLEMENTATION_TYPE_SCHEMA is
'Schema of the implementation type of the indextype '
/
Comment on column DBA_OPBINDINGS.IMPLEMENTATION_TYPE is
'Implementation type of the indextype'
/
Comment on column DBA_OPBINDINGS.PROPERTY is
'Property of the operator binding'
/

create or replace view USER_OPBINDINGS
    (OWNER, OPERATOR_NAME, BINDING#, FUNCTION_NAME, RETURN_SCHEMA,
     RETURN_TYPE, IMPLEMENTATION_TYPE_SCHEMA, IMPLEMENTATION_TYPE, PROPERTY)
as
select  c.name, b.name, a.bind#, a.functionname, a.returnschema,
        a.returntype, a.impschema, a.imptype,
        decode(bitand(a.property,31), 1, 'WITH INDEX CONTEXT',
               3 , 'COMPUTE ANCILLARY DATA', 4 , 'ANCILLARY TO',
               16 , 'WITH COLUMN CONTEXT' ,
               17,  'WITH INDEX, COLUMN CONTEXT',
               19, 'COMPUTE ANCILLARY DATA, WITH COLUMN CONTEXT')
  from  sys.opbinding$ a, sys.obj$ b, sys.user$ c
  where a.obj# = b.obj# and b.owner# = c.user#
  and b.owner# = userenv ('SCHEMAID')
/
create or replace public synonym USER_OPBINDINGS for USER_OPBINDINGS
/
grant select on USER_OPBINDINGS to PUBLIC with grant option
/
Comment on table USER_OPBINDINGS is
'All binding functions or methods on operators defined by the user'
/
Comment on column USER_OPBINDINGS.OWNER is
'Owner of the operator'
/
Comment on column USER_OPBINDINGS.OPERATOR_NAME is
'Name of the operator'
/
Comment on column USER_OPBINDINGS.BINDING# is
'Binding# of the operator'
/
Comment on column USER_OPBINDINGS.FUNCTION_NAME is
'Name of the binding function or method as specified by the user'
/
Comment on column USER_OPBINDINGS.RETURN_SCHEMA is
'Name of the schema of the return type - not null only for ADTs'
/
Comment on column USER_OPBINDINGS.RETURN_TYPE is
'Name of the return type'
/
Comment on column USER_OPBINDINGS.IMPLEMENTATION_TYPE_SCHEMA is
'Schema of the implementation type of the indextype '
/
Comment on column USER_OPBINDINGS.IMPLEMENTATION_TYPE is
'Implementation type of the indextype'
/
Comment on column USER_OPBINDINGS.PROPERTY is
'Property of the operator binding'
/

create or replace view ALL_OPBINDINGS
    (OWNER, OPERATOR_NAME, BINDING#, FUNCTION_NAME, RETURN_SCHEMA,
     RETURN_TYPE, IMPLEMENTATION_TYPE_SCHEMA, IMPLEMENTATION_TYPE, PROPERTY)
as
select   c.name, b.name, a.bind#, a.functionname, a.returnschema,
         a.returntype, a.impschema, a.imptype,
        decode(bitand(a.property,31), 1, 'WITH INDEX CONTEXT',
               3 , 'COMPUTE ANCILLARY DATA', 4 , 'ANCILLARY TO' ,
               16 , 'WITH COLUMN CONTEXT' ,
               17,  'WITH INDEX, COLUMN CONTEXT',
               19, 'COMPUTE ANCILLARY DATA, WITH COLUMN CONTEXT')
   from  sys.opbinding$ a, sys.obj$ b, sys.user$ c where
  a.obj# = b.obj# and b.owner# = c.user#
  and ( b.owner# = userenv ('SCHEMAID')
    or
    b.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or exists (select null from v$enabledprivs
                  where priv_number in (-200 /* CREATE OPERATOR */,
                                        -201 /* CREATE ANY OPERATOR */,
                                        -202 /* ALTER ANY OPERATOR */,
                                        -203 /* DROP ANY OPERATOR */,
                                        -204 /* EXECUTE OPERATOR */)
                 )
      )
/
create or replace public synonym ALL_OPBINDINGS for ALL_OPBINDINGS
/
grant select on ALL_OPBINDINGS to PUBLIC with grant option
/
Comment on table ALL_OPBINDINGS is
'All binding functions for operators available to the user'
/
Comment on column ALL_OPBINDINGS.OWNER is
'Owner of the operator'
/
Comment on column ALL_OPBINDINGS.OPERATOR_NAME is
'Name of the operator'
/
Comment on column ALL_OPBINDINGS.BINDING# is
'Binding# of the operator'
/
Comment on column ALL_OPBINDINGS.FUNCTION_NAME is
'Name of the binding function or method as specified by the user'
/
Comment on column ALL_OPBINDINGS.RETURN_SCHEMA is
'Name of the schema of the return type - not null only for ADTs'
/
Comment on column ALL_OPBINDINGS.RETURN_TYPE is
'Name of the return type'
/
Comment on column ALL_OPBINDINGS.IMPLEMENTATION_TYPE_SCHEMA is
'Schema of the implementation type of the indextype '
/
Comment on column ALL_OPBINDINGS.IMPLEMENTATION_TYPE is
'Implementation type of the indextype'
/
Comment on column ALL_OPBINDINGS.PROPERTY is
'Property of the operator binding'
/

create or replace view DBA_OPANCILLARY
   (OWNER, OPERATOR_NAME, BINDING#, PRIMOP_OWNER, PRIMOP_NAME, PRIMOP_BIND#)
as
select distinct u.name, o.name, a.bind#, u1.name, o1.name, a1.primbind#
from   sys.user$ u, sys.obj$ o, sys.opancillary$ a, sys.user$ u1, sys.obj$ o1,
       sys.opancillary$ a1
where  a.obj#=o.obj# and o.owner#=u.user#  AND
       a1.primop#=o1.obj# and o1.owner#=u1.user# and a.obj#=a1.obj#
/
create or replace public synonym DBA_OPANCILLARY for DBA_OPANCILLARY
/
grant select on DBA_OPANCILLARY to select_catalog_role
/
Comment on table DBA_OPANCILLARY is
'All ancillary operators'
/
Comment on column DBA_OPANCILLARY.OWNER is
'Owner of ancillary operator'
/
Comment on column DBA_OPANCILLARY.OPERATOR_NAME is
'Name of ancillary operator'
/
Comment on column DBA_OPANCILLARY.BINDING# is
'Binding number of ancillary operator'
/
Comment on column DBA_OPANCILLARY.PRIMOP_OWNER is
'Owner of primary operator'
/
Comment on column DBA_OPANCILLARY.PRIMOP_NAME is
'Name of primary operator'
/
Comment on column DBA_OPANCILLARY.PRIMOP_BIND# is
'Binding number of primary operator'
/

create or replace view USER_OPANCILLARY
   (OWNER, OPERATOR_NAME, BINDING#, PRIMOP_OWNER, PRIMOP_NAME, PRIMOP_BIND#)
as
select distinct u.name, o.name, a.bind#, u1.name, o1.name, a1.primbind#
from   sys.user$ u, sys.obj$ o, sys.opancillary$ a, sys.user$ u1, sys.obj$ o1,
       sys.opancillary$ a1
where  a.obj#=o.obj# and o.owner#=u.user#   AND
       a1.primop#=o1.obj# and o1.owner#=u1.user# and a.obj#=a1.obj#
       and o.owner#=userenv('SCHEMAID')
/
create or replace public synonym USER_OPANCILLARY for USER_OPANCILLARY
/
grant select on USER_OPANCILLARY to PUBLIC with grant option
/
Comment on table USER_OPANCILLARY is
'All ancillary opertors defined by user'
/
Comment on column USER_OPANCILLARY.OWNER is
'Owner of ancillary operator'
/
Comment on column USER_OPANCILLARY.OPERATOR_NAME is
'Name of ancillary operator'
/
Comment on column USER_OPANCILLARY.BINDING# is
'Binding number of ancillary operator'
/
Comment on column USER_OPANCILLARY.PRIMOP_OWNER is
'Owner of primary operator'
/
Comment on column USER_OPANCILLARY.PRIMOP_NAME is
'Name of primary operator'
/
Comment on column USER_OPANCILLARY.PRIMOP_BIND# is
'Binding number of primary operator'
/

create or replace view ALL_OPANCILLARY
   (OWNER, OPERATOR_NAME, BINDING#, PRIMOP_OWNER, PRIMOP_NAME, PRIMOP_BIND#)
as
select distinct u.name, o.name, a.bind#, u1.name, o1.name, a1.primbind#
from   sys.user$ u, sys.obj$ o, sys.opancillary$ a, sys.user$ u1, sys.obj$ o1,
       sys.opancillary$ a1
where  a.obj#=o.obj# and o.owner#=u.user#   AND
       a1.primop#=o1.obj# and o1.owner#=u1.user# and a.obj#=a1.obj#
  and ( o.owner# = userenv ('SCHEMAID')
    or
    o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or exists (select null from v$enabledprivs
                  where priv_number in (-200 /* CREATE OPERATOR */,
                                        -201 /* CREATE ANY OPERATOR */,
                                        -202 /* ALTER ANY OPERATOR */,
                                        -203 /* DROP ANY OPERATOR */,
                                        -204 /* EXECUTE OPERATOR */)
                 )
      )
/
create or replace public synonym ALL_OPANCILLARY for ALL_OPANCILLARY
/
grant select on ALL_OPANCILLARY to PUBLIC with grant option
/
Comment on table ALL_OPANCILLARY is
'All ancillary operators available to the user'
/
Comment on column ALL_OPANCILLARY.OWNER is
'Owner of ancillary operator'
/
Comment on column ALL_OPANCILLARY.OPERATOR_NAME is
'Name of ancillary operator'
/
Comment on column ALL_OPANCILLARY.BINDING# is
'Binding number of ancillary operator'
/
Comment on column ALL_OPANCILLARY.PRIMOP_OWNER is
'Owner of primary operator'
/
Comment on column ALL_OPANCILLARY.PRIMOP_NAME is
'Name of primary operator'
/
Comment on column ALL_OPANCILLARY.PRIMOP_BIND# is
'Binding number of primary operator'
/

create or replace view DBA_OPARGUMENTS
    (OWNER, OPERATOR_NAME, BINDING#, POSITION, ARGUMENT_TYPE)
as
select  c.name, b.name, a.bind#, a.position, a.type
  from  sys.oparg$ a, sys.obj$ b, sys.user$ c
  where a.obj# = b.obj# and b.owner# = c.user#
/
create or replace public synonym DBA_OPARGUMENTS for DBA_OPARGUMENTS
/
grant select on DBA_OPARGUMENTS to select_catalog_role
/
Comment on table DBA_OPARGUMENTS is
'All operator arguments'
/
Comment on column DBA_OPARGUMENTS.OWNER is
'Owner of the operator'
/
Comment on column DBA_OPARGUMENTS.OPERATOR_NAME is
'Name of the operator'
/
Comment on column DBA_OPARGUMENTS.BINDING# is
'Binding# of the operator'
/
Comment on column DBA_OPARGUMENTS.POSITION is
'Position of the operator argument'
/
Comment on column DBA_OPARGUMENTS.ARGUMENT_TYPE is
'Datatype of the operator argument'
/

create or replace view USER_OPARGUMENTS
    (OWNER, OPERATOR_NAME, BINDING#, POSITION, ARGUMENT_TYPE)
as
select  c.name, b.name, a.bind#, a.position, a.type
  from  sys.oparg$ a, sys.obj$ b, sys.user$ c
  where a.obj# = b.obj# and b.owner# = c.user#
  and   b.owner# = userenv ('SCHEMAID')
/
create or replace public synonym USER_OPARGUMENTS for USER_OPARGUMENTS
/
grant select on USER_OPARGUMENTS to PUBLIC with grant option
/
Comment on table USER_OPARGUMENTS is
'All operator arguments of operators defined by user'
/
Comment on column USER_OPARGUMENTS.OWNER is
'Owner of the operator'
/
Comment on column USER_OPARGUMENTS.OPERATOR_NAME is
'Name of the operator'
/
Comment on column USER_OPARGUMENTS.BINDING# is
'Binding# of the operator'
/
Comment on column USER_OPARGUMENTS.POSITION is
'Position of the operator argument'
/
Comment on column USER_OPARGUMENTS.ARGUMENT_TYPE is
'Datatype of the operator argument'
/

create or replace view ALL_OPARGUMENTS
    (OWNER, OPERATOR_NAME, BINDING#, POSITION, ARGUMENT_TYPE)
as
select  c.name, b.name, a.bind#, a.position, a.type
  from  sys.oparg$ a, sys.obj$ b, sys.user$ c
  where a.obj# = b.obj# and b.owner# = c.user#
  and  (b.owner# = userenv ('SCHEMAID')
        or
        b.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
           or exists (select null from v$enabledprivs
                  where priv_number in (-200 /* CREATE OPERATOR */,
                                        -201 /* CREATE ANY OPERATOR */,
                                        -202 /* ALTER ANY OPERATOR */,
                                        -203 /* DROP ANY OPERATOR */,
                                        -204 /* EXECUTE OPERATOR */)
                 )
      )
/
create or replace public synonym ALL_OPARGUMENTS for ALL_OPARGUMENTS
/
grant select on ALL_OPARGUMENTS to PUBLIC with grant option
/
Comment on table ALL_OPARGUMENTS is
'All arguments of the operators available to the user'
/
Comment on column ALL_OPARGUMENTS.OWNER is
'Owner of the operator'
/
Comment on column ALL_OPARGUMENTS.OPERATOR_NAME is
'Name of the operator'
/
Comment on column ALL_OPARGUMENTS.BINDING# is
'Binding# of the operator'
/
Comment on column ALL_OPARGUMENTS.POSITION is
'Position of the operator argument'
/
Comment on column ALL_OPARGUMENTS.ARGUMENT_TYPE is
'Datatype of the operator argument'
/

create or replace view DBA_OPERATOR_COMMENTS
    (OWNER, OPERATOR_NAME, COMMENTS)
as
select u.name, o.name, c.comment$
from   sys.obj$ o, sys.operator$ op, sys.com$ c, sys.user$ u
where  o.obj# = op.obj# and c.obj# = op.obj# and u.user# = o.owner#
/
create or replace public synonym DBA_OPERATOR_COMMENTS
   for DBA_OPERATOR_COMMENTS
/
grant select on DBA_OPERATOR_COMMENTS to select_catalog_role
/
comment on table DBA_OPERATOR_COMMENTS is
'Comments for user-defined operators'
/
comment on column DBA_OPERATOR_COMMENTS.OWNER is
'Owner of the user-defined operator'
/
comment on column DBA_OPERATOR_COMMENTS.OPERATOR_NAME is
'Name of the user-defined operator'
/
comment on column DBA_OPERATOR_COMMENTS.COMMENTS is
'Comment for the user-defined operator'
/

create or replace view USER_OPERATOR_COMMENTS
    (OWNER, OPERATOR_NAME, COMMENTS)
as
select u.name, o.name, c.comment$
from   sys.obj$ o, sys.operator$ op, sys.com$ c, sys.user$ u
where  o.obj# = op.obj# and c.obj# = op.obj# and u.user# = o.owner#
       and o.owner# = userenv('SCHEMAID')
/
create or replace public synonym USER_OPERATOR_COMMENTS
   for USER_OPERATOR_COMMENTS
/
grant select on USER_OPERATOR_COMMENTS to PUBLIC with grant option
/
comment on table USER_OPERATOR_COMMENTS is
'Comments for user-defined operators'
/
comment on column USER_OPERATOR_COMMENTS.OWNER is
'Owner of the user-defined operator'
/
comment on column USER_OPERATOR_COMMENTS.OPERATOR_NAME is
'Name of the user-defined operator'
/
comment on column USER_OPERATOR_COMMENTS.COMMENTS is
'Comment for the user-defined operator'
/

create or replace view ALL_OPERATOR_COMMENTS
    (OWNER, OPERATOR_NAME, COMMENTS)
as
select u.name, o.name, c.comment$
from   sys.obj$ o, sys.operator$ op, sys.com$ c, sys.user$ u
where  o.obj# = op.obj# and c.obj# = op.obj# and u.user# = o.owner#
       and
       ( o.owner# = userenv('SCHEMAID')
         or
         o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
         or exists (select null from v$enabledprivs
                    where priv_number in (-200 /* CREATE OPERATOR */,
                                        -201 /* CREATE ANY OPERATOR */,
                                        -202 /* ALTER ANY OPERATOR */,
                                        -203 /* DROP ANY OPERATOR */,
                                        -204 /* EXECUTE OPERATOR */)
                 )
      )
/
create or replace public synonym ALL_OPERATOR_COMMENTS
   for ALL_OPERATOR_COMMENTS
/
grant select on ALL_OPERATOR_COMMENTS to PUBLIC with grant option
/
comment on table ALL_OPERATOR_COMMENTS is
'Comments for user-defined operators'
/
comment on column ALL_OPERATOR_COMMENTS.OWNER is
'Owner of the user-defined operator'
/
comment on column ALL_OPERATOR_COMMENTS.OPERATOR_NAME is
'Name of the user-defined operator'
/
comment on column ALL_OPERATOR_COMMENTS.COMMENTS is
'Comment for the user-defined operator'
/

Rem
Rem Indextype Views
Rem
create or replace view DBA_INDEXTYPES
(OWNER, INDEXTYPE_NAME, IMPLEMENTATION_SCHEMA,
IMPLEMENTATION_NAME, INTERFACE_VERSION, IMPLEMENTATION_VERSION,
NUMBER_OF_OPERATORS, PARTITIONING, ARRAY_DML)
as
select u.name, o.name, u1.name, o1.name, i.interface_version#, t.version#,
io.opcount, decode(bitand(i.property, 48), 0, 'NONE', 16, 'RANGE', 32, 'HASH', 48, 'HASH,RANGE'),
decode(bitand(i.property, 2), 0, 'NO', 2, 'YES')
from sys.indtypes$ i, sys.user$ u, sys.obj$ o,
sys.user$ u1, (select it.obj#, count(*) opcount from
sys.indop$ io1, sys.indtypes$ it where
io1.obj# = it.obj# and bitand(io1.property, 4) != 4
group by it.obj#) io, sys.obj$ o1,
sys.type$ t
where i.obj# = o.obj# and o.owner# = u.user# and
u1.user# = o.owner# and io.obj# = i.obj# and
o1.obj# = i.implobj# and o1.oid$ = t.toid
/
create or replace public synonym DBA_INDEXTYPES for DBA_INDEXTYPES
/
grant select on DBA_INDEXTYPES to select_catalog_role
/
comment on table DBA_INDEXTYPES is
'All indextypes'
/
comment on column DBA_INDEXTYPES.OWNER is
'Owner of the indextype'
/
comment on column DBA_INDEXTYPES.INDEXTYPE_NAME is
'Name of the indextype'
/
comment on column DBA_INDEXTYPES.IMPLEMENTATION_SCHEMA is
'Name of the schema for indextype implementation'
/
comment on column DBA_INDEXTYPES.IMPLEMENTATION_NAME is
'Name of indextype implementation'
/
comment on column DBA_INDEXTYPES.INTERFACE_VERSION is
'Version of indextype interface'
/
comment on column DBA_INDEXTYPES.IMPLEMENTATION_VERSION is
'Version of indextype implementation'
/
comment on column DBA_INDEXTYPES.NUMBER_OF_OPERATORS is
'Number of operators associated with the indextype'
/
comment on column DBA_INDEXTYPES.PARTITIONING is
'Kinds of local partitioning supported by the indextype'
/
comment on column DBA_INDEXTYPES.ARRAY_DML is
'Does this indextype support array dml'
/

create or replace view USER_INDEXTYPES
(OWNER, INDEXTYPE_NAME, IMPLEMENTATION_SCHEMA,
IMPLEMENTATION_NAME, INTERFACE_VERSION, IMPLEMENTATION_VERSION,
NUMBER_OF_OPERATORS, PARTITIONING, ARRAY_DML)
as
select u.name, o.name, u1.name, o1.name, i.interface_version#, t.version#,
io.opcount, decode(bitand(i.property, 48), 0, 'NONE', 16, 'RANGE', 32, 'HASH', 48, 'HASH,RANGE'),
decode(bitand(i.property, 2), 0, 'NO', 2, 'YES')
from sys.indtypes$ i, sys.user$ u, sys.obj$ o,
sys.user$ u1, (select it.obj#, count(*) opcount from
sys.indop$ io1, sys.indtypes$ it where
io1.obj# = it.obj# and bitand(io1.property, 4) != 4
group by it.obj#) io, sys.obj$ o1,
sys.type$ t
where i.obj# = o.obj# and o.owner# = u.user# and
u1.user# = o.owner# and io.obj# = i.obj# and
o1.obj# = i.implobj# and o1.oid$ = t.toid and
o.owner# = userenv ('SCHEMAID')
/
create or replace public synonym USER_INDEXTYPES for USER_INDEXTYPES
/
grant select on USER_INDEXTYPES to PUBLIC with grant option
/
comment on table USER_INDEXTYPES is
'All user indextypes'
/
comment on column USER_INDEXTYPES.OWNER is
'Owner of the indextype'
/
comment on column USER_INDEXTYPES.INDEXTYPE_NAME is
'Name of the indextype'
/
comment on column USER_INDEXTYPES.IMPLEMENTATION_SCHEMA is
'Name of the schema for indextype implementation'
/
comment on column USER_INDEXTYPES.IMPLEMENTATION_NAME is
'Name of indextype implementation'
/
comment on column USER_INDEXTYPES.INTERFACE_VERSION is
'Version of indextype interface'
/
comment on column USER_INDEXTYPES.IMPLEMENTATION_VERSION is
'Version of indextype implementation'
/
comment on column USER_INDEXTYPES.NUMBER_OF_OPERATORS is
'Number of operators associated with the indextype'
/
comment on column USER_INDEXTYPES.PARTITIONING is
'Kinds of local partitioning supported by the indextype'
/
comment on column USER_INDEXTYPES.ARRAY_DML is
'Does this indextype support array dml'
/

create or replace view ALL_INDEXTYPES
(OWNER, INDEXTYPE_NAME, IMPLEMENTATION_SCHEMA,
IMPLEMENTATION_NAME, INTERFACE_VERSION, IMPLEMENTATION_VERSION,
NUMBER_OF_OPERATORS, PARTITIONING, ARRAY_DML)
as
select u.name, o.name, u1.name, o1.name, i.interface_version#, t.version#,
io.opcount, decode(bitand(i.property, 48), 0, 'NONE', 16, 'RANGE', 32, 'HASH', 48, 'HASH,RANGE'),
decode(bitand(i.property, 2), 0, 'NO', 2, 'YES')
from sys.indtypes$ i, sys.user$ u, sys.obj$ o,
sys.user$ u1, (select it.obj#, count(*) opcount from
sys.indop$ io1, sys.indtypes$ it where
io1.obj# = it.obj# and bitand(io1.property, 4) != 4
group by it.obj#) io, sys.obj$ o1,
sys.type$ t
where i.obj# = o.obj# and o.owner# = u.user# and
u1.user# = o.owner# and io.obj# = i.obj# and
o1.obj# = i.implobj# and o1.oid$ = t.toid and
( o.owner# = userenv ('SCHEMAID')
    or
    o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or exists (select null from v$enabledprivs
                  where priv_number in (-205 /* CREATE INDEXTYPE */,
                                        -206 /* CREATE ANY INDEXTYPE */,
                                        -207 /* ALTER ANY INDEXTYPE */,
                                        -208 /* DROP ANY INDEXTYPE */)
                 )
      )
/
create or replace public synonym ALL_INDEXTYPES for ALL_INDEXTYPES
/
grant select on ALL_INDEXTYPES to PUBLIC with grant option
/
Comment on table ALL_INDEXTYPES is
'All indextypes available to the user'
/
comment on column ALL_INDEXTYPES.OWNER is
'Owner of the indextype'
/
comment on column ALL_INDEXTYPES.INDEXTYPE_NAME is
'Name of the indextype'
/
comment on column ALL_INDEXTYPES.IMPLEMENTATION_SCHEMA is
'Name of the schema for indextype implementation'
/
comment on column ALL_INDEXTYPES.IMPLEMENTATION_NAME is
'Name of indextype implementation'
/
comment on column ALL_INDEXTYPES.INTERFACE_VERSION is
'Version of indextype interface'
/
comment on column ALL_INDEXTYPES.IMPLEMENTATION_VERSION is
'Version of indextype implementation'
/
comment on column ALL_INDEXTYPES.NUMBER_OF_OPERATORS is
'Number of operators associated with the indextype'
/
comment on column ALL_INDEXTYPES.PARTITIONING is
'Kinds of local partitioning supported by the indextype'
/
comment on column DBA_INDEXTYPES.ARRAY_DML is
'Does this indextype support array dml'
/

create or replace view DBA_INDEXTYPE_COMMENTS
  (OWNER, INDEXTYPE_NAME, COMMENTS)
as
select  u.name, o.name, c.comment$
from    sys.obj$ o, sys.user$ u, sys.indtypes$ i, sys.com$ c
where   o.obj# = i.obj# and u.user# = o.owner# and c.obj# = i.obj#
/
create or replace public synonym DBA_INDEXTYPE_COMMENTS for DBA_INDEXTYPE_COMMENTS
/
grant select on DBA_INDEXTYPE_COMMENTS to select_catalog_role
/
comment on table DBA_INDEXTYPE_COMMENTS is
'Comments for user-defined indextypes'
/
comment on column DBA_INDEXTYPE_COMMENTS.OWNER is
'Owner of the user-defined indextype'
/
comment on column DBA_INDEXTYPE_COMMENTS.INDEXTYPE_NAME is
'Name of the user-defined indextype'
/
comment on column DBA_INDEXTYPE_COMMENTS.COMMENTS is
'Comment for the user-defined indextype'
/

create or replace view USER_INDEXTYPE_COMMENTS
  (OWNER, INDEXTYPE_NAME, COMMENTS)
as
select  u.name, o.name, c.comment$
from    sys.obj$ o, sys.user$ u, sys.indtypes$ i, sys.com$ c
where   o.obj# = i.obj# and u.user# = o.owner# and c.obj# = i.obj#
        and o.owner# = userenv('SCHEMAID')
/
create or replace public synonym USER_INDEXTYPE_COMMENTS
   for USER_INDEXTYPE_COMMENTS
/
grant select on USER_INDEXTYPE_COMMENTS to PUBLIC with grant option
/
comment on table USER_INDEXTYPE_COMMENTS is
'Comments for user-defined indextypes'
/
comment on column USER_INDEXTYPE_COMMENTS.OWNER is
'Owner of the user-defined indextype'
/
comment on column USER_INDEXTYPE_COMMENTS.INDEXTYPE_NAME is
'Name of the user-defined indextype'
/
comment on column USER_INDEXTYPE_COMMENTS.COMMENTS is
'Comment for the user-defined indextype'
/

create or replace view ALL_INDEXTYPE_COMMENTS
  (OWNER, INDEXTYPE_NAME, COMMENTS)
as
select  u.name, o.name, c.comment$
from    sys.obj$ o, sys.user$ u, sys.indtypes$ i, sys.com$ c
where   o.obj# = i.obj# and u.user# = o.owner# and c.obj# = i.obj# and
( o.owner# = userenv ('SCHEMAID')
    or
    o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or exists (select null from v$enabledprivs
                  where priv_number in (-205 /* CREATE INDEXTYPE */,
                                        -206 /* CREATE ANY INDEXTYPE */,
                                        -207 /* ALTER ANY INDEXTYPE */,
                                        -208 /* DROP ANY INDEXTYPE */)
                 )
 )
/
create or replace public synonym ALL_INDEXTYPE_COMMENTS
   for ALL_INDEXTYPE_COMMENTS
/
grant select on ALL_INDEXTYPE_COMMENTS to PUBLIC with grant option
/
comment on table ALL_INDEXTYPE_COMMENTS is
'Comments for user-defined indextypes'
/
comment on column ALL_INDEXTYPE_COMMENTS.OWNER is
'Owner of the user-defined indextype'
/
comment on column ALL_INDEXTYPE_COMMENTS.INDEXTYPE_NAME is
'Name of the user-defined indextype'
/
comment on column ALL_INDEXTYPE_COMMENTS.COMMENTS is
'Comment for the user-defined indextype'
/

create or replace view DBA_INDEXTYPE_ARRAYTYPES
(OWNER, INDEXTYPE_NAME, BASE_TYPE_SCHEMA, BASE_TYPE_NAME, BASE_TYPE,
ARRAY_TYPE_SCHEMA, ARRAY_TYPE_NAME)
as
select indtypu.name, indtypo.name,
decode(i.type, 121, (select baseu.name from user$ baseu
       where baseo.owner#=baseu.user#), null),
decode(i.type, 121, baseo.name, null),
decode(i.type,  /* DATA_TYPE */
0, null,
1, 'VARCHAR2',
2, 'NUMBER',
3, 'NATIVE INTEGER',
8, 'LONG',
9, 'VARCHAR',
11, 'ROWID',
12, 'DATE',
23, 'RAW',
24, 'LONG RAW',
29, 'BINARY_INTEGER',
69, 'ROWID',
96, 'CHAR',
100, 'BINARY_FLOAT',
101, 'BINARY_DOUBLE',
102, 'REF CURSOR',
104, 'UROWID',
105, 'MLSLABEL',
106, 'MLSLABEL',
110, 'REF',
111, 'REF',
112, 'CLOB',
113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
121, 'OBJECT',
122, 'TABLE',
123, 'VARRAY',
178, 'TIME',
179, 'TIME WITH TIME ZONE',
180, 'TIMESTAMP',
181, 'TIMESTAMP WITH TIME ZONE',
231, 'TIMESTAMP WITH LOCAL TIME ZONE',
182, 'INTERVAL YEAR TO MONTH',
183, 'INTERVAL DAY TO SECOND',
250, 'PL/SQL RECORD',
251, 'PL/SQL TABLE',
252, 'PL/SQL BOOLEAN',
'UNDEFINED'),
arrayu.name, arrayo.name
from sys.user$ indtypu, sys.indarraytype$ i, sys.obj$ indtypo,
sys.obj$ baseo, sys.obj$ arrayo, sys.user$ arrayu
where i.obj# = indtypo.obj# and  indtypu.user# = indtypo.owner# and
      i.basetypeobj# = baseo.obj#(+) and i.arraytypeobj# = arrayo.obj# and
      arrayu.user# = arrayo.owner#
/
create or replace public synonym DBA_INDEXTYPE_ARRAYTYPES
for DBA_INDEXTYPE_ARRAYTYPES
/
grant select on DBA_INDEXTYPE_ARRAYTYPES to select_catalog_role
/
comment on table DBA_INDEXTYPE_ARRAYTYPES is
'All array types specified by the indextype'
/
comment on column DBA_INDEXTYPE_ARRAYTYPES.OWNER is
'Owner of the indextype'
/
comment on column DBA_INDEXTYPE_ARRAYTYPES.INDEXTYPE_NAME is
'Name of the indextype'
/
comment on column DBA_INDEXTYPE_ARRAYTYPES.BASE_TYPE_SCHEMA is
'Name of the base type schema'
/
comment on column DBA_INDEXTYPE_ARRAYTYPES.BASE_TYPE_NAME is
'Name of the base type name'
/
comment on column DBA_INDEXTYPE_ARRAYTYPES.BASE_TYPE is
'Datatype of the base type'
/
comment on column DBA_INDEXTYPE_ARRAYTYPES.ARRAY_TYPE_SCHEMA is
'Name of the array type schema'
/
comment on column DBA_INDEXTYPE_ARRAYTYPES.ARRAY_TYPE_NAME is
'Name of the array type name'
/

create or replace view USER_INDEXTYPE_ARRAYTYPES
(OWNER, INDEXTYPE_NAME, BASE_TYPE_SCHEMA, BASE_TYPE_NAME, BASE_TYPE,
ARRAY_TYPE_SCHEMA, ARRAY_TYPE_NAME)
as
select indtypu.name, indtypo.name,
decode(i.type, 121, (select baseu.name from user$ baseu
       where baseo.owner#=baseu.user#), null),
decode(i.type, 121, baseo.name, null),
decode(i.type,  /* DATA_TYPE */
0, null,
1, 'VARCHAR2',
2, 'NUMBER',
3, 'NATIVE INTEGER',
8, 'LONG',
9, 'VARCHAR',
11, 'ROWID',
12, 'DATE',
23, 'RAW',
24, 'LONG RAW',
29, 'BINARY_INTEGER',
69, 'ROWID',
96, 'CHAR',
100, 'BINARY_FLOAT',
101, 'BINARY_DOUBLE',
102, 'REF CURSOR',
104, 'UROWID',
105, 'MLSLABEL',
106, 'MLSLABEL',
110, 'REF',
111, 'REF',
112, 'CLOB',
113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
121, 'OBJECT',
122, 'TABLE',
123, 'VARRAY',
178, 'TIME',
179, 'TIME WITH TIME ZONE',
180, 'TIMESTAMP',
181, 'TIMESTAMP WITH TIME ZONE',
231, 'TIMESTAMP WITH LOCAL TIME ZONE',
182, 'INTERVAL YEAR TO MONTH',
183, 'INTERVAL DAY TO SECOND',
250, 'PL/SQL RECORD',
251, 'PL/SQL TABLE',
252, 'PL/SQL BOOLEAN',
'UNDEFINED'),
arrayu.name, arrayo.name
from sys.user$ indtypu, sys.indarraytype$ i, sys.obj$ indtypo,
sys.obj$ baseo,  sys.obj$ arrayo, sys.user$ arrayu
where i.obj# = indtypo.obj# and  indtypu.user# = indtypo.owner# and
      i.basetypeobj# = baseo.obj#(+) and i.arraytypeobj# = arrayo.obj# and
      arrayu.user# = arrayo.owner# and indtypo.owner# = userenv ('SCHEMAID')
/
create or replace public synonym USER_INDEXTYPE_ARRAYTYPES
for USER_INDEXTYPE_ARRAYTYPES
/
grant select on USER_INDEXTYPE_ARRAYTYPES to PUBLIC with grant option
/
comment on table USER_INDEXTYPE_ARRAYTYPES is
'All array types specified by the indextype'
/
comment on column USER_INDEXTYPE_ARRAYTYPES.OWNER is
'Owner of the indextype'
/
comment on column USER_INDEXTYPE_ARRAYTYPES.INDEXTYPE_NAME is
'Name of the indextype'
/
comment on column USER_INDEXTYPE_ARRAYTYPES.BASE_TYPE_SCHEMA is
'Name of the base type schema'
/
comment on column USER_INDEXTYPE_ARRAYTYPES.BASE_TYPE_NAME is
'Name of the base type name'
/
comment on column USER_INDEXTYPE_ARRAYTYPES.BASE_TYPE is
'Datatype of the base type'
/
comment on column USER_INDEXTYPE_ARRAYTYPES.ARRAY_TYPE_SCHEMA is
'Name of the array type schema'
/
comment on column USER_INDEXTYPE_ARRAYTYPES.ARRAY_TYPE_NAME is
'Name of the array type name'
/

create or replace view ALL_INDEXTYPE_ARRAYTYPES
(OWNER, INDEXTYPE_NAME, BASE_TYPE_SCHEMA, BASE_TYPE_NAME, BASE_TYPE,
ARRAY_TYPE_SCHEMA, ARRAY_TYPE_NAME)
as
select indtypu.name, indtypo.name,
decode(i.type, 121, (select baseu.name from user$ baseu
       where baseo.owner#=baseu.user#), null),
decode(i.type, 121, baseo.name, null),
decode(i.type,  /* DATA_TYPE */
0, null,
1, 'VARCHAR2',
2, 'NUMBER',
3, 'NATIVE INTEGER',
8, 'LONG',
9, 'VARCHAR',
11, 'ROWID',
12, 'DATE',
23, 'RAW',
24, 'LONG RAW',
29, 'BINARY_INTEGER',
69, 'ROWID',
96, 'CHAR',
100, 'BINARY_FLOAT',
101, 'BINARY_DOUBLE',
102, 'REF CURSOR',
104, 'UROWID',
105, 'MLSLABEL',
106, 'MLSLABEL',
110, 'REF',
111, 'REF',
112, 'CLOB',
113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
121, 'OBJECT',
122, 'TABLE',
123, 'VARRAY',
178, 'TIME',
179, 'TIME WITH TIME ZONE',
180, 'TIMESTAMP',
181, 'TIMESTAMP WITH TIME ZONE',
231, 'TIMESTAMP WITH LOCAL TIME ZONE',
182, 'INTERVAL YEAR TO MONTH',
183, 'INTERVAL DAY TO SECOND',
250, 'PL/SQL RECORD',
251, 'PL/SQL TABLE',
252, 'PL/SQL BOOLEAN',
'UNDEFINED'),
arrayu.name, arrayo.name
from sys.user$ indtypu, sys.indarraytype$ i, sys.obj$ indtypo,
sys.obj$ baseo, sys.obj$ arrayo, sys.user$ arrayu
where i.obj# = indtypo.obj# and  indtypu.user# = indtypo.owner# and
      i.basetypeobj# = baseo.obj#(+) and i.arraytypeobj# = arrayo.obj# and
      arrayu.user# = arrayo.owner# and
      ( indtypo.owner# = userenv ('SCHEMAID')
        or
        indtypo.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
        or exists (select null from v$enabledprivs
                   where priv_number in (-205 /* CREATE INDEXTYPE */,
                                        -206 /* CREATE ANY INDEXTYPE */,
                                        -207 /* ALTER ANY INDEXTYPE */,
                                        -208 /* DROP ANY INDEXTYPE */)
                  )
      )
/
create or replace public synonym ALL_INDEXTYPE_ARRAYTYPES
for ALL_INDEXTYPE_ARRAYTYPES
/
grant select on ALL_INDEXTYPE_ARRAYTYPES to PUBLIC with grant option
/
comment on table ALL_INDEXTYPE_ARRAYTYPES is
'All array types specified by the indextype'
/
comment on column ALL_INDEXTYPE_ARRAYTYPES.OWNER is
'Owner of the indextype'
/
comment on column ALL_INDEXTYPE_ARRAYTYPES.INDEXTYPE_NAME is
'Name of the indextype'
/
comment on column ALL_INDEXTYPE_ARRAYTYPES.BASE_TYPE_SCHEMA is
'Name of the base type schema'
/
comment on column ALL_INDEXTYPE_ARRAYTYPES.BASE_TYPE_NAME is
'Name of the base type name'
/
comment on column ALL_INDEXTYPE_ARRAYTYPES.BASE_TYPE is
'Datatype of the base type'
/
comment on column ALL_INDEXTYPE_ARRAYTYPES.ARRAY_TYPE_SCHEMA is
'Name of the array type schema'
/
comment on column ALL_INDEXTYPE_ARRAYTYPES.ARRAY_TYPE_NAME is
'Name of the array type name'
/

create or replace view DBA_INDEXTYPE_OPERATORS
(OWNER, INDEXTYPE_NAME, OPERATOR_SCHEMA, OPERATOR_NAME, BINDING#)
as
select u.name, o.name, u1.name, op.name, i.bind#
from sys.user$ u, sys.indop$ i, sys.obj$ o,
sys.obj$ op, sys.user$ u1
where i.obj# = o.obj# and i.oper# = op.obj# and
      u.user# = o.owner# and bitand(i.property, 4) != 4 and
      u1.user#=op.owner#
/
create or replace public synonym DBA_INDEXTYPE_OPERATORS
for DBA_INDEXTYPE_OPERATORS
/
grant select on DBA_INDEXTYPE_OPERATORS to select_catalog_role
/
comment on table DBA_INDEXTYPE_OPERATORS is
'All indextype operators'
/
comment on column DBA_INDEXTYPE_OPERATORS.OWNER is
'Owner of the indextype'
/
Comment on column DBA_INDEXTYPE_OPERATORS.INDEXTYPE_NAME is
'Name of the indextype'
/
Comment on column DBA_INDEXTYPE_OPERATORS.OPERATOR_SCHEMA is
'Name of the operator schema'
/
Comment on column DBA_INDEXTYPE_OPERATORS.OPERATOR_NAME is
'Name of the operator for which the indextype is defined'
/
Comment on column DBA_INDEXTYPE_OPERATORS.BINDING# is
'Binding# associated with the operator'
/

create or replace view USER_INDEXTYPE_OPERATORS
(OWNER, INDEXTYPE_NAME, OPERATOR_SCHEMA, OPERATOR_NAME, BINDING#)
as
select u.name, o.name, u1.name, op.name, i.bind#
from sys.user$ u, sys.indop$ i, sys.obj$ o,
sys.obj$ op, sys.user$ u1
where i.obj# = o.obj# and i.oper# = op.obj# and
      u.user# = o.owner# and u1.user#=op.owner# and
      o.owner# = userenv ('SCHEMAID') and bitand(i.property, 4) != 4
/
create or replace public synonym USER_INDEXTYPE_OPERATORS
for USER_INDEXTYPE_OPERATORS
/
grant select on USER_INDEXTYPE_OPERATORS to PUBLIC
with grant option
/
Comment on table USER_INDEXTYPE_OPERATORS is
'All user indextype operators'
/
Comment on column USER_INDEXTYPE_OPERATORS.OWNER is
'Owner of the indextype'
/
Comment on column USER_INDEXTYPE_OPERATORS.INDEXTYPE_NAME is
'Name of the indextype'
/
Comment on column USER_INDEXTYPE_OPERATORS.OPERATOR_SCHEMA is
'Name of the operator schema'
/
Comment on column USER_INDEXTYPE_OPERATORS.OPERATOR_NAME is
'Name of the operator for which the indextype is defined'
/
Comment on column USER_INDEXTYPE_OPERATORS.BINDING# is
'Binding# associated with the operator'
/

create or replace view ALL_INDEXTYPE_OPERATORS
(OWNER, INDEXTYPE_NAME, OPERATOR_SCHEMA, OPERATOR_NAME, BINDING#)
as
select u.name, o.name, u1.name, op.name, i.bind#
from sys.user$ u, sys.indop$ i, sys.obj$ o,
sys.obj$ op, sys.user$ u1
where i.obj# = o.obj# and i.oper# = op.obj# and
      u.user# = o.owner# and bitand(i.property, 4) != 4 and u1.user#=op.owner# and
      ( o.owner# = userenv ('SCHEMAID')
      or
      o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or exists (select null from v$enabledprivs
                  where priv_number in (-205 /* CREATE INDEXTYPE */,
                                        -206 /* CREATE ANY INDEXTYPE */,
                                        -207 /* ALTER ANY INDEXTYPE */,
                                        -208 /* DROP ANY INDEXTYPE */)
                 )
      )
/
create or replace public synonym ALL_INDEXTYPE_OPERATORS
for ALL_INDEXTYPE_OPERATORS
/
grant select on ALL_INDEXTYPE_OPERATORS to PUBLIC
with grant option
/
Comment on table ALL_INDEXTYPE_OPERATORS is
'All operators available to the user'
/
Comment on column ALL_INDEXTYPE_OPERATORS.OWNER is
'Owner of the indextype'
/
Comment on column ALL_INDEXTYPE_OPERATORS.INDEXTYPE_NAME is
'Name of the indextype'
/
Comment on column ALL_INDEXTYPE_OPERATORS.OPERATOR_SCHEMA is
'Name of the operator schema'
/
Comment on column ALL_INDEXTYPE_OPERATORS.OPERATOR_NAME is
'Name of the operator for which the indextype is defined'
/
Comment on column ALL_INDEXTYPE_OPERATORS.BINDING# is
'Binding# associated with the operator'
/

remark
remark  FAMILY "UNUSED_COL_TABS"
remark
remark  Views for showing information about tables with unused columns:
remark  USER_UNUSED_COL_TABS, ALL_UNUSED_COL_TABS, and DBA_UNUSED_COL_TABS
remark
create or replace view USER_UNUSED_COL_TABS
    (TABLE_NAME, COUNT)
as
select o.name, count(*)
from sys.col$ c, sys.obj$ o
where o.obj# = c.obj#
  and o.owner# = userenv('SCHEMAID')
  and bitand(c.property, 32768) = 32768             -- is unused columns
  and bitand(c.property, 1) != 1                    -- not ADT attribute col
  and bitand(c.property, 1024) != 1024              -- not NTAB's setid col
  group by o.name
/
create or replace public synonym USER_UNUSED_COL_TABS for USER_UNUSED_COL_TABS
/
grant select on USER_UNUSED_COL_TABS to PUBLIC with grant option
/
comment on table USER_UNUSED_COL_TABS is
'User tables with unused columns'
/
Comment on column USER_UNUSED_COL_TABS.TABLE_NAME is
'Name of the table'
/
Comment on column USER_UNUSED_COL_TABS.COUNT is
'Number of unused columns in table'
/
create or replace view ALL_UNUSED_COL_TABS
    (OWNER, TABLE_NAME, COUNT)
as
select u.name, o.name, count(*)
from sys.user$ u, sys.obj$ o, sys.col$ c
where o.owner# = u.user#
  and o.obj# = c.obj#
  and bitand(c.property,32768) = 32768              -- is unused column
  and bitand(c.property, 1) != 1                    -- not ADT attribute col
  and bitand(c.property, 1024) != 1024              -- not NTAB's setid col
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */)
                 )
      )
  group by u.name, o.name
/
comment on table ALL_UNUSED_COL_TABS is
'All tables with unused columns accessible to the user'
/
Comment on column ALL_UNUSED_COL_TABS.OWNER is
'Owner of the table'
/
Comment on column ALL_UNUSED_COL_TABS.TABLE_NAME is
'Name of the table'
/
Comment on column ALL_UNUSED_COL_TABS.COUNT is
'Number of unused columns in table'
/
create or replace public synonym ALL_UNUSED_COL_TABS for ALL_UNUSED_COL_TABS
/
grant select on ALL_UNUSED_COL_TABS to PUBLIC with grant option
/
create or replace view DBA_UNUSED_COL_TABS
(OWNER, TABLE_NAME, COUNT)
as
select u.name, o.name, count(*)
from sys.user$ u, sys.obj$ o, sys.col$ c
where c.obj# = o.obj#
      and bitand(c.property,32768) = 32768          -- is unused column
      and bitand(c.property, 1) != 1                -- not ADT attribute col
      and bitand(c.property, 1024) != 1024          -- not NTAB's setid col
      and u.user# = o.owner#
      group by u.name, o.name
/
comment on table DBA_UNUSED_COL_TABS is
'All tables with unused columns in the database'
/
Comment on column DBA_UNUSED_COL_TABS.OWNER is
'Owner of the table'
/
Comment on column DBA_UNUSED_COL_TABS.TABLE_NAME is
'Name of the table'
/
Comment on column DBA_UNUSED_COL_TABS.COUNT is
'Number of unused columns in table'
/
create or replace public synonym DBA_UNUSED_COL_TABS for DBA_UNUSED_COL_TABS
/
grant select on DBA_UNUSED_COL_TABS to select_catalog_role
/
remark
remark  FAMILY "PARTIAL_DROP_TABS"
remark
remark  Views for showing tables with partial dropped columns:
remark  USER_PARTIAL_DROP_TABS, ALL_PARTIAL_DROP_TABS, DBA_PARTIAL_DROP_TABS
remark
create or replace view USER_PARTIAL_DROP_TABS
    (TABLE_NAME)
as
select o.name from sys.tab$ t, sys.obj$ o
where o.obj# = t.obj#
  and o.owner# = userenv('SCHEMAID')
  and bitand(t.flags, 32768) = 32768
/
create or replace public synonym USER_PARTIAL_DROP_TABS
   for USER_PARTIAL_DROP_TABS
/
grant select on USER_PARTIAL_DROP_TABS to PUBLIC with grant option
/
comment on table USER_PARTIAL_DROP_TABS is
'User tables with unused columns'
/
Comment on column USER_PARTIAL_DROP_TABS.TABLE_NAME is
'Name of the table'
/
create or replace view ALL_PARTIAL_DROP_TABS
    (OWNER, TABLE_NAME)
as
select u.name, o.name
from sys.user$ u, sys.obj$ o, sys.tab$ t
where o.owner# = u.user#
  and o.obj# = t.obj#
  and bitand(t.flags,32768) = 32768
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */)
                 )
      )
  group by u.name, o.name
/
comment on table ALL_PARTIAL_DROP_TABS is
'All tables with patially dropped columns accessible to the user'
/
Comment on column ALL_PARTIAL_DROP_TABS.OWNER is
'Owner of the table'
/
Comment on column ALL_PARTIAL_DROP_TABS.TABLE_NAME is
'Name of the table'
/
create or replace public synonym ALL_PARTIAL_DROP_TABS
   for ALL_PARTIAL_DROP_TABS
/
grant select on ALL_PARTIAL_DROP_TABS to PUBLIC with grant option
/
create or replace view DBA_PARTIAL_DROP_TABS
(OWNER, TABLE_NAME)
as
select u.name, o.name
from sys.user$ u, sys.obj$ o, sys.tab$ t
where t.obj# = o.obj#
      and bitand(t.flags,32768) = 32768
      and u.user# = o.owner#
      group by u.name, o.name
/
comment on table DBA_PARTIAL_DROP_TABS is
'All tables with partially dropped columns in the database'
/
Comment on column DBA_PARTIAL_DROP_TABS.OWNER is
'Owner of the table'
/
Comment on column DBA_PARTIAL_DROP_TABS.TABLE_NAME is
'Name of the table'
/
create or replace public synonym DBA_PARTIAL_DROP_TABS
   for DBA_PARTIAL_DROP_TABS
/
grant select on DBA_PARTIAL_DROP_TABS to select_catalog_role
/
create or replace view DBA_ASSOCIATIONS
  (OBJECT_OWNER, OBJECT_NAME, COLUMN_NAME, OBJECT_TYPE, STATSTYPE_SCHEMA,
   STATSTYPE_NAME, DEF_SELECTIVITY, DEF_CPU_COST, DEF_IO_COST, DEF_NET_COST,
   INTERFACE_VERSION )
as
  select u.name, o.name, c.name,
         decode(a.property, 1, 'COLUMN', 2, 'TYPE', 3, 'PACKAGE', 4,
                'FUNCTION', 5, 'INDEX', 6, 'INDEXTYPE', 'INVALID'),
         u1.name, o1.name,a.default_selectivity,
         a.default_cpu_cost, a.default_io_cost, a.default_net_cost,
         a.interface_version#
   from  sys.association$ a, sys.obj$ o, sys.user$ u,
         sys.obj$ o1, sys.user$ u1, sys.col$ c
   where a.obj#=o.obj# and o.owner#=u.user#
   AND   a.statstype#=o1.obj# (+) and o1.owner#=u1.user# (+)
   AND   a.obj# = c.obj#  (+)  and a.intcol# = c.intcol# (+)
/
create or replace public synonym DBA_ASSOCIATIONS for DBA_ASSOCIATIONS
/
grant select on DBA_ASSOCIATIONS to select_catalog_role
/
Comment on table DBA_ASSOCIATIONS is
'All associations'
/
Comment on column DBA_ASSOCIATIONS.OBJECT_OWNER is
'Owner of the object for which the association is being defined'
/
Comment on column DBA_ASSOCIATIONS.OBJECT_NAME is
'Object name for which the association is being defined'
/
Comment on column DBA_ASSOCIATIONS.COLUMN_NAME is
'Column name in the object for which the association is being defined'
/
Comment on column DBA_ASSOCIATIONS.OBJECT_TYPE is
'Schema type of the object - table, type, package or function'
/
Comment on column DBA_ASSOCIATIONS.STATSTYPE_SCHEMA is
'Owner of the statistics type'
/
Comment on column DBA_ASSOCIATIONS.STATSTYPE_NAME is
'Name of Statistics type which contains the cost, selectivity or stats funcs'
/
Comment on column DBA_ASSOCIATIONS.DEF_SELECTIVITY is
'Default Selectivity if any of the object'
/
Comment on column DBA_ASSOCIATIONS.DEF_CPU_COST is
'Default CPU cost if any of the object'
/
Comment on column DBA_ASSOCIATIONS.DEF_IO_COST is
'Default I/O cost if any of the object'
/
Comment on column DBA_ASSOCIATIONS.DEF_NET_COST is
'Default Networking cost if any of the object'
/
Comment on column DBA_ASSOCIATIONS.INTERFACE_VERSION is
'Version number of Statistics type interface implemented'
/

create or replace view USER_ASSOCIATIONS
  (OBJECT_OWNER, OBJECT_NAME, COLUMN_NAME, OBJECT_TYPE, STATSTYPE_SCHEMA,
   STATSTYPE_NAME, DEF_SELECTIVITY, DEF_CPU_COST, DEF_IO_COST, DEF_NET_COST,
   INTERFACE_VERSION )
as
  select u.name, o.name, c.name,
         decode(a.property, 1, 'COLUMN', 2, 'TYPE', 3, 'PACKAGE', 4,
                'FUNCTION', 5, 'INDEX', 6, 'INDEXTYPE', 'INVALID'),
         u1.name, o1.name,a.default_selectivity,
         a.default_cpu_cost, a.default_io_cost, a.default_net_cost,
         a.interface_version#
   from  sys.association$ a, sys.obj$ o, sys.user$ u,
         sys.obj$ o1, sys.user$ u1, sys.col$ c
   where a.obj#=o.obj# and o.owner#=u.user#
   AND   a.statstype#=o1.obj# (+) and o1.owner#=u1.user# (+)
   AND   a.obj# = c.obj#  (+)  and a.intcol# = c.intcol# (+)
   and o.owner#=userenv('SCHEMAID')
/
create or replace public synonym USER_ASSOCIATIONS for USER_ASSOCIATIONS
/
grant select on USER_ASSOCIATIONS to public with grant option
/
Comment on table USER_ASSOCIATIONS is
'All assocations defined by the user'
/
Comment on column USER_ASSOCIATIONS.OBJECT_OWNER is
'Owner of the object for which the association is being defined'
/
Comment on column USER_ASSOCIATIONS.OBJECT_NAME is
'Object name for which the association is being defined'
/
Comment on column USER_ASSOCIATIONS.COLUMN_NAME is
'Column name in the object for which the association is being defined'
/
Comment on column USER_ASSOCIATIONS.OBJECT_TYPE is
'Schema type of the object - table, type, package or function'
/
Comment on column USER_ASSOCIATIONS.STATSTYPE_SCHEMA is
'Owner of the statistics type'
/
Comment on column USER_ASSOCIATIONS.STATSTYPE_NAME is
'Name of Statistics type which contains the cost, selectivity or stats funcs'
/
Comment on column USER_ASSOCIATIONS.DEF_SELECTIVITY is
'Default Selectivity if any of the object'
/
Comment on column USER_ASSOCIATIONS.DEF_CPU_COST is
'Default CPU cost if any of the object'
/
Comment on column USER_ASSOCIATIONS.DEF_IO_COST is
'Default I/O cost if any of the object'
/
Comment on column USER_ASSOCIATIONS.DEF_NET_COST is
'Default Networking cost if any of the object'
/
Comment on column USER_ASSOCIATIONS.INTERFACE_VERSION is
'Interface number of Statistics type interface implemented'
/

create or replace view ALL_ASSOCIATIONS
  (OBJECT_OWNER, OBJECT_NAME, COLUMN_NAME, OBJECT_TYPE, STATSTYPE_SCHEMA,
   STATSTYPE_NAME, DEF_SELECTIVITY, DEF_CPU_COST, DEF_IO_COST, DEF_NET_COST,
   INTERFACE_VERSION )
as
  select u.name, o.name, c.name,
         decode(a.property, 1, 'COLUMN', 2, 'TYPE', 3, 'PACKAGE', 4,
                'FUNCTION', 5, 'INDEX', 6, 'INDEXTYPE', 'INVALID'),
         u1.name, o1.name,a.default_selectivity,
         a.default_cpu_cost, a.default_io_cost, a.default_net_cost,
         a.interface_version#
   from  sys.association$ a, sys.obj$ o, sys.user$ u,
         sys.obj$ o1, sys.user$ u1, sys.col$ c
   where a.obj#=o.obj# and o.owner#=u.user#
   AND   a.statstype#=o1.obj# (+) and o1.owner#=u1.user# (+)
   AND   a.obj# = c.obj#  (+)  and a.intcol# = c.intcol# (+)
   and (o.owner# = userenv('SCHEMAID')
        or
        o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or
       ( o.type# in (2)  /* table */
         and
         exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */,
                                        -42 /* ALTER ANY TABLE */)
                 )
       )
       or
       ( o.type# in (8, 9)   /* package or function */
         and
         exists (select null from v$enabledprivs
                  where priv_number in (-140 /* CREATE PROCEDURE */,
                                        -141 /* CREATE ANY PROCEDURE */,
                                        -142 /* ALTER ANY PROCEDURE */,
                                        -143 /* DROP ANY PROCEDURE */,
                                        -144 /* EXECUTE ANY PROCEDURE */)
                 )
       )
       or
       ( o.type# in (13)     /* type */
         and
         exists (select null from v$enabledprivs
                  where priv_number in (-180 /* CREATE TYPE */,
                                        -181 /* CREATE ANY TYPE */,
                                        -182 /* ALTER ANY TYPE */,
                                        -183 /* DROP ANY TYPE */,
                                        -184 /* EXECUTE ANY TYPE */)
                 )
       )
       or
       ( o.type# in (1)     /* index */
         and
         exists (select null from v$enabledprivs
                  where priv_number in (-71 /* CREATE ANY INDEX */,
                                        -72 /* ALTER ANY INDEX */,
                                        -73 /* DROP ANY INDEX */)
                 )
       )
       or
       ( o.type# in (32)     /* indextype */
         and
         exists (select null from v$enabledprivs
                  where priv_number in (-205 /* CREATE INDEXTYPE */,
                                        -206 /* CREATE ANY INDEXTYPE */,
                                        -207 /* ALTER ANY INDEXTYPE */,
                                        -208 /* DROP ANY INDEXTYPE */)
                 )
       )
    )
/
create or replace public synonym ALL_ASSOCIATIONS for ALL_ASSOCIATIONS
/
grant select on ALL_ASSOCIATIONS to PUBLIC with grant option
/
Comment on table ALL_ASSOCIATIONS is
'All associations available to the user'
/
Comment on column ALL_ASSOCIATIONS.OBJECT_OWNER is
'Owner of the object for which the association is being defined'
/
Comment on column ALL_ASSOCIATIONS.OBJECT_NAME is
'Object name for which the association is being defined'
/
Comment on column ALL_ASSOCIATIONS.COLUMN_NAME is
'Column name in the object for which the association is being defined'
/
Comment on column ALL_ASSOCIATIONS.OBJECT_TYPE is
'Schema type of the object - column, type, package or function'
/
Comment on column ALL_ASSOCIATIONS.STATSTYPE_SCHEMA is
'Owner of the statistics type'
/
Comment on column ALL_ASSOCIATIONS.STATSTYPE_NAME is
'Name of Statistics type which contains the cost, selectivity or stats funcs'
/
Comment on column ALL_ASSOCIATIONS.DEF_SELECTIVITY is
'Default Selectivity if any of the object'
/
Comment on column ALL_ASSOCIATIONS.DEF_CPU_COST is
'Default CPU cost if any of the object'
/
Comment on column ALL_ASSOCIATIONS.DEF_IO_COST is
'Default I/O cost if any of the object'
/
Comment on column ALL_ASSOCIATIONS.DEF_NET_COST is
'Default Networking cost if any of the object'
/
Comment on column ALL_ASSOCIATIONS.INTERFACE_VERSION is
'Version number of Statistics type interface implemented'
/

create or replace view DBA_USTATS
  (OBJECT_OWNER, OBJECT_NAME, PARTITION_NAME, OBJECT_TYPE, ASSOCIATION,
   COLUMN_NAME, STATSTYPE_SCHEMA, STATSTYPE_NAME, STATISTICS)
as
  select u.name, o.name, o.subname,
         decode (bitand(s.property, 3), 1, 'INDEX', 2, 'COLUMN'),
         decode (bitand(s.property, 12), 8, 'DIRECT', 4, 'IMPLICIT'),
         c.name, u1.name, o1.name, s.statistics
  from   sys.user$ u, sys.obj$ o, sys.col$ c, sys.ustats$ s,
         sys.user$ u1, sys.obj$ o1
  where  bitand(s.property, 3)=2 and s.obj#=o.obj# and o.owner#=u.user#
  and    s.intcol#=c.intcol# and s.statstype#=o1.obj#
  and    o1.owner#=u1.user# and c.obj#=s.obj#
union all    -- partition case
  select u.name, o.name, o.subname,
         decode (bitand(s.property, 3), 1, 'INDEX', 2, 'COLUMN'),
         decode (bitand(s.property, 12), 8, 'DIRECT', 4, 'IMPLICIT'),
         c.name, u1.name, o1.name, s.statistics
  from   sys.user$ u, sys.user$ u1, sys.obj$ o, sys.obj$ o1, sys.col$ c,
         sys.ustats$ s, sys.tabpart$ t, sys.obj$ o2
  where  bitand(s.property, 3)=2 and s.obj# = o.obj#
  and    s.obj# = t.obj# and t.bo# = o2.obj# and o2.owner# = u.user#
  and    s.intcol# = c.intcol# and s.statstype#=o1.obj# and o1.owner#=u1.user#
  and    t.bo#=c.obj#
union all
  select u.name, o.name, o.subname,
         decode (bitand(s.property, 3), 1, 'INDEX', 2, 'COLUMN'),
         decode (bitand(s.property, 12), 8, 'DIRECT', 4, 'IMPLICIT'),
          NULL, u1.name, o1.name, s.statistics
  from   sys.user$ u, sys.obj$ o, sys.ustats$ s,
         sys.user$ u1, sys.obj$ o1
  where  bitand(s.property, 3)=1 and s.obj#=o.obj# and o.owner#=u.user#
  and    s.statstype#=o1.obj# and o1.owner#=u1.user# and o.type#=1
union all -- index partition
  select u.name, o.name, o.subname,
         decode (bitand(s.property, 3), 1, 'INDEX', 2, 'COLUMN'),
         decode (bitand(s.property, 12), 8, 'DIRECT', 4, 'IMPLICIT'),
         NULL, u1.name, o1.name, s.statistics
  from   sys.user$ u, sys.user$ u1, sys.obj$ o, sys.obj$ o1,
         sys.ustats$ s, sys.indpart$ i, sys.obj$ o2
  where  bitand(s.property, 3)=1 and s.obj# = o.obj#
  and    s.obj# = i.obj# and i.bo# = o2.obj# and o2.owner# = u.user#
  and    s.statstype#=o1.obj# and o1.owner#=u1.user#
/
create or replace public synonym DBA_USTATS for DBA_USTATS
/
grant select on DBA_USTATS to select_catalog_role
/
Comment on table DBA_USTATS is
'All statistics collected on either tables or indexes'
/
Comment on column DBA_USTATS.OBJECT_OWNER is
'Owner of the table or index for which the statistics have been collected'
/
Comment on column DBA_USTATS.OBJECT_NAME is
'Name of the table or index for which the statistics have been collected'
/
Comment on column DBA_USTATS.PARTITION_NAME is
'Name of the partition (if applicable) for which the stats have been collected'
/
Comment on column DBA_USTATS.OBJECT_TYPE is
'Type of the object - Column or Index'
/
Comment on column DBA_USTATS.ASSOCIATION is
'If the statistics type association is direct or implicit'
/
Comment on column DBA_USTATS.COLUMN_NAME is
'Column name, if property is column for which statistics have been collected'
/
Comment on column DBA_USTATS.STATSTYPE_SCHEMA is
'Schema of statistics type which was used to collect the statistics '
/
Comment on column DBA_USTATS.STATSTYPE_NAME is
'Name of statistics type which was used to collect statistics'
/
Comment on column DBA_USTATS.STATISTICS is
'User collected statistics for the object'
/

create or replace view USER_USTATS
  (OBJECT_OWNER, OBJECT_NAME, PARTITION_NAME, OBJECT_TYPE, ASSOCIATION,
   COLUMN_NAME, STATSTYPE_SCHEMA, STATSTYPE_NAME, STATISTICS)
as
  select u.name, o.name, o.subname,
         decode (bitand(s.property, 3), 1, 'INDEX', 2, 'COLUMN'),
         decode (bitand(s.property, 12), 8, 'DIRECT', 4, 'IMPLICIT'),
         c.name, u1.name, o1.name, s.statistics
  from   sys.user$ u, sys.obj$ o, sys.col$ c, sys.ustats$ s,
         sys.user$ u1, sys.obj$ o1
  where  bitand(s.property, 3)=2 and s.obj#=o.obj# and o.owner#=u.user#
  and    s.intcol#=c.intcol# and s.statstype#=o1.obj#
  and    o1.owner#=u1.user# and c.obj#=s.obj#
  and    o.owner#=userenv('SCHEMAID')
union all    -- partition case
  select u.name, o.name, o.subname,
         decode (bitand(s.property, 3), 1, 'INDEX', 2, 'COLUMN'),
         decode (bitand(s.property, 12), 8, 'DIRECT', 4, 'IMPLICIT'),
         c.name, u1.name, o1.name, s.statistics
  from   sys.user$ u, sys.user$ u1, sys.obj$ o, sys.obj$ o1, sys.col$ c,
         sys.ustats$ s, sys.tabpart$ t, sys.obj$ o2
  where  bitand(s.property, 3)=2 and s.obj# = o.obj#
  and    s.obj# = t.obj# and t.bo# = o2.obj# and o2.owner# = u.user#
  and    s.intcol# = c.intcol# and s.statstype#=o1.obj# and o1.owner#=u1.user#
  and    t.bo#=c.obj#  and o.owner#=userenv('SCHEMAID')
union all
  select u.name, o.name, o.subname,
         decode (bitand(s.property, 3), 1, 'INDEX', 2, 'COLUMN'),
         decode (bitand(s.property, 12), 8, 'DIRECT', 4, 'IMPLICIT'),
          NULL, u1.name, o1.name, s.statistics
  from   sys.user$ u, sys.obj$ o, sys.ustats$ s,
         sys.user$ u1, sys.obj$ o1
  where  bitand(s.property, 3)=1 and s.obj#=o.obj# and o.owner#=u.user#
  and    s.statstype#=o1.obj# and o1.owner#=u1.user# and o.type#=1
  and    o.owner#= userenv('SCHEMAID')
union all -- index partition
  select u.name, o.name, o.subname,
         decode (bitand(s.property, 3), 1, 'INDEX', 2, 'COLUMN'),
         decode (bitand(s.property, 12), 8, 'DIRECT', 4, 'IMPLICIT'),
         NULL, u1.name, o1.name, s.statistics
  from   sys.user$ u, sys.user$ u1, sys.obj$ o, sys.obj$ o1,
         sys.ustats$ s, sys.indpart$ i, sys.obj$ o2
  where  bitand(s.property, 3)=1 and s.obj# = o.obj#
  and    s.obj# = i.obj# and i.bo# = o2.obj# and o2.owner# = u.user#
  and    s.statstype#=o1.obj# and o1.owner#=u1.user#
  and    o.owner#=userenv('SCHEMAID')
/
create or replace public synonym USER_USTATS for USER_USTATS
/
grant select on USER_USTATS to public with grant option
/
Comment on table USER_USTATS is
'All statistics on tables or indexes owned by the user'
/
Comment on column USER_USTATS.OBJECT_OWNER is
'Owner of the table or index for which the statistics have been collected'
/
Comment on column USER_USTATS.OBJECT_NAME is
'Name of the table or index for which the statistics have been collected'
/
Comment on column USER_USTATS.PARTITION_NAME is
'Name of the partition (if applicable) for which the stats have been collected'
/
Comment on column USER_USTATS.OBJECT_TYPE is
'Type of the object - Column or Index'
/
Comment on column USER_USTATS.ASSOCIATION is
'If the statistics type association is direct or implicit'
/
Comment on column USER_USTATS.COLUMN_NAME is
'Column name, if property is column for which statistics have been collected'
/
Comment on column USER_USTATS.STATSTYPE_SCHEMA is
'Schema of statistics type which was used to collect the statistics '
/
Comment on column USER_USTATS.STATSTYPE_NAME is
'Name of statistics type which was used to collect statistics'
/
Comment on column USER_USTATS.STATISTICS is
'User collected statistics for the object'
/

create or replace view ALL_USTATS
  (OBJECT_OWNER, OBJECT_NAME, PARTITION_NAME, OBJECT_TYPE, ASSOCIATION,
   COLUMN_NAME, STATSTYPE_SCHEMA, STATSTYPE_NAME, STATISTICS)
as
  select u.name, o.name, o.subname,
         decode (bitand(s.property, 3), 1, 'INDEX', 2, 'COLUMN'),
         decode (bitand(s.property, 12), 8, 'DIRECT', 4, 'IMPLICIT'),
         c.name, u1.name, o1.name, s.statistics
  from   sys.user$ u, sys.obj$ o, sys.col$ c, sys.ustats$ s,
         sys.user$ u1, sys.obj$ o1
  where  bitand(s.property, 3)=2 and s.obj#=o.obj# and o.owner#=u.user#
  and    s.intcol#=c.intcol# and s.statstype#=o1.obj#
  and    o1.owner#=u1.user# and c.obj#=s.obj#
  and    ( o.owner#=userenv('SCHEMAID')
           or
        o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or
       ( o.type# in (2)  /* table */
         and
         exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */,
                                        -42 /* ALTER ANY TABLE */)
                 )
       )
    )
union all    -- partition case
  select u.name, o.name, o.subname,
         decode (bitand(s.property, 3), 1, 'INDEX', 2, 'COLUMN'),
         decode (bitand(s.property, 12), 8, 'DIRECT', 4, 'IMPLICIT'),
         c.name, u1.name, o1.name, s.statistics
  from   sys.user$ u, sys.user$ u1, sys.obj$ o, sys.obj$ o1, sys.col$ c,
         sys.ustats$ s, sys.tabpart$ t, sys.obj$ o2
  where  bitand(s.property, 3)=2 and s.obj# = o.obj#
  and    s.obj# = t.obj# and t.bo# = o2.obj# and o2.owner# = u.user#
  and    s.intcol# = c.intcol# and s.statstype#=o1.obj# and o1.owner#=u1.user#
  and    t.bo#=c.obj#
  and    ( o.owner#=userenv('SCHEMAID')
           or
        o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or
       ( o.type# in (2)  /* table */
         and
         exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */,
                                        -42 /* ALTER ANY TABLE */)
                 )
       )
    )
union all
  select u.name, o.name, o.subname,
         decode (bitand(s.property, 3), 1, 'INDEX', 2, 'COLUMN'),
         decode (bitand(s.property, 12), 8, 'DIRECT', 4, 'IMPLICIT'),
          NULL, u1.name, o1.name, s.statistics
  from   sys.user$ u, sys.obj$ o, sys.ustats$ s,
         sys.user$ u1, sys.obj$ o1
  where  bitand(s.property, 3)=1 and s.obj#=o.obj# and o.owner#=u.user#
  and    s.statstype#=o1.obj# and o1.owner#=u1.user# and o.type#=1
  and    ( o.owner#=userenv('SCHEMAID')
           or
        o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or
       ( o.type# in (1)  /* index */
         and
         exists (select null from v$enabledprivs
                  where priv_number in (-71 /* CREATE ANY INDEX */,
                                        -72 /* ALTER ANY INDEX */,
                                        -73 /* DROP ANY INDEX */)
                 )
       )
    )
union all -- index partition
  select u.name, o.name, o.subname,
         decode (bitand(s.property, 3), 1, 'INDEX', 2, 'COLUMN'),
         decode (bitand(s.property, 12), 8, 'DIRECT', 4, 'IMPLICIT'),
         NULL, u1.name, o1.name, s.statistics
  from   sys.user$ u, sys.user$ u1, sys.obj$ o, sys.obj$ o1,
         sys.ustats$ s, sys.indpart$ i, sys.obj$ o2
  where  bitand(s.property, 3)=1 and s.obj# = o.obj#
  and    s.obj# = i.obj# and i.bo# = o2.obj# and o2.owner# = u.user#
  and    s.statstype#=o1.obj# and o1.owner#=u1.user#
  and    ( o.owner#=userenv('SCHEMAID')
           or
        o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or
       ( o.type# in (1)  /* index */
         and
         exists (select null from v$enabledprivs
                  where priv_number in (-71 /* CREATE ANY INDEX */,
                                        -72 /* ALTER ANY INDEX */,
                                        -73 /* DROP ANY INDEX */)
                 )
       )
    )
/
create or replace public synonym ALL_USTATS for ALL_USTATS
/
grant select on ALL_USTATS to public with grant option
/
Comment on table ALL_USTATS is
'All statistics'
/
Comment on column ALL_USTATS.OBJECT_OWNER is
'Owner of the table or index for which the statistics have been collected'
/
Comment on column ALL_USTATS.OBJECT_NAME is
'Name of the table or index for which the statistics have been collected'
/
Comment on column ALL_USTATS.PARTITION_NAME is
'Name of the partition (if applicable) for which the stats have been collected'
/
Comment on column ALL_USTATS.OBJECT_TYPE is
'Type of the object - Column or Index'
/
Comment on column ALL_USTATS.ASSOCIATION is
'If the statistics type association is direct or implicit'
/
Comment on column ALL_USTATS.COLUMN_NAME is
'Column name, if property is column for which statistics have been collected'
/
Comment on column ALL_USTATS.STATSTYPE_SCHEMA is
'Schema of statistics type which was used to collect the statistics '
/
Comment on column ALL_USTATS.STATSTYPE_NAME is
'Name of statistics type which was used to collect statistics'
/
Comment on column ALL_USTATS.STATISTICS is
'User collected statistics for the object'
/
Rem
Rem Trusted Servers View
Rem
create or replace view TRUSTED_SERVERS(TRUST, NAME)
as
select a.trust, b.dbname from sys.trusted_list$ b,
(select decode (dbname, '+*','Untrusted', '-*', 'Trusted') trust
from sys.trusted_list$ where dbname like '%*') a
where b.dbname not like '%*'
union
select decode (dbname, '-*', 'Untrusted', '+*', 'Trusted') trust, 'All'
from sys.trusted_list$
where dbname like '%*'
/
create or replace public synonym TRUSTED_SERVERS for TRUSTED_SERVERS
/
grant select on TRUSTED_SERVERS to select_catalog_role
/
comment on table TRUSTED_SERVERS is
'Trustedness of Servers'
/
comment on column TRUSTED_SERVERS.TRUST is
'Trustedness of the server listed. Unlisted servers have opposite trustedness.'
/
comment on column TRUSTED_SERVERS.NAME is
'Server name'
/
Rem
Rem Family "TAB_MODIFICATIONS"
Rem
Rem These views provide information about the amount and type of
Rem modifications made to rows in a table.
Rem
create or replace view USER_TAB_MODIFICATIONS
(TABLE_NAME, PARTITION_NAME, SUBPARTITION_NAME, INSERTS, UPDATES,
 DELETES, TIMESTAMP, TRUNCATED, DROP_SEGMENTS)
as
select o.name, null, null,
       m.inserts, m.updates, m.deletes, m.timestamp,
       decode(bitand(m.flags,1),1,'YES','NO'),
       m.drop_segments
from sys.mon_mods_all$ m, sys.obj$ o, sys.tab$ t
where o.owner# = userenv('SCHEMAID') and o.obj# = m.obj# and o.obj# = t.obj#
union all
  select o.name, o.subname, null,
       m.inserts, m.updates, m.deletes, m.timestamp,
       decode(bitand(m.flags,1),1,'YES','NO'),
       m.drop_segments
  from sys.mon_mods_all$ m, sys.obj$ o
  where o.owner# = userenv('SCHEMAID') and o.obj# = m.obj# and o.type#=19
union all
select o.name, o2.subname, o.subname,
       m.inserts, m.updates, m.deletes, m.timestamp,
       decode(bitand(m.flags,1),1,'YES','NO'),
       m.drop_segments
from sys.mon_mods_all$ m, sys.obj$ o, sys.tabsubpart$ tsp, sys.obj$ o2
where o.owner# = userenv('SCHEMAID') and o.obj# = m.obj# and
      o.obj# = tsp.obj# and o2.obj# = tsp.pobj#
/
comment on table USER_TAB_MODIFICATIONS is
'Information regarding modifications to tables'
/
comment on column USER_TAB_MODIFICATIONS.TABLE_NAME is
'Modified table'
/
comment on column USER_TAB_MODIFICATIONS.PARTITION_NAME is
'Modified partition'
/
comment on column USER_TAB_MODIFICATIONS.SUBPARTITION_NAME is
'Modified subpartition'
/
comment on column USER_TAB_MODIFICATIONS.INSERTS is
'Approximate number of rows inserted since last analyze'
/
comment on column USER_TAB_MODIFICATIONS.UPDATES is
'Approximate number of rows updated since last analyze'
/
comment on column USER_TAB_MODIFICATIONS.DELETES is
'Approximate number of rows deleted since last analyze'
/
comment on column USER_TAB_MODIFICATIONS.TIMESTAMP is
'Timestamp of last time this row was modified'
/
comment on column USER_TAB_MODIFICATIONS.TRUNCATED is
'Was this object truncated since the last analyze?'
/
comment on column USER_TAB_MODIFICATIONS.DROP_SEGMENTS is
'Number of (sub)partition segment dropped since the last analyze?'
/
create or replace public synonym USER_TAB_MODIFICATIONS for USER_TAB_MODIFICATIONS
/
grant select on USER_TAB_MODIFICATIONS to PUBLIC with grant option
/
create or replace view ALL_TAB_MODIFICATIONS
(TABLE_OWNER, TABLE_NAME, PARTITION_NAME, SUBPARTITION_NAME, INSERTS,
 UPDATES, DELETES, TIMESTAMP, TRUNCATED, DROP_SEGMENTS)
as
select u.name, o.name, null, null,
       m.inserts, m.updates, m.deletes, m.timestamp,
       decode(bitand(m.flags,1),1,'YES','NO'),
       m.drop_segments
from sys.mon_mods_all$ m, sys.obj$ o, sys.tab$ t, sys.user$ u
where o.obj# = m.obj# and o.obj# = t.obj# and o.owner# = u.user#
      and (o.owner# = userenv('SCHEMAID')
           or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in (select kzsrorol from x$kzsro))
           or /* user has system privileges */
             exists (select null from v$enabledprivs
                       where priv_number in (-45 /* LOCK ANY TABLE */,
                                             -47 /* SELECT ANY TABLE */,
                                             -48 /* INSERT ANY TABLE */,
                                             -49 /* UPDATE ANY TABLE */,
                                             -50 /* DELETE ANY TABLE */,
                                             -165/* ANALYZE ANY */))
          )
union all
select u.name, o.name, o.subname, null,
       m.inserts, m.updates, m.deletes, m.timestamp,
       decode(bitand(m.flags,1),1,'YES','NO'),
       m.drop_segments
from sys.mon_mods_all$ m, sys.obj$ o, sys.user$ u
where o.owner# = u.user# and o.obj# = m.obj# and o.type#=19
      and (o.owner# = userenv('SCHEMAID')
           or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in (select kzsrorol from x$kzsro))
           or /* user has system privileges */
             exists (select null from v$enabledprivs
                       where priv_number in (-45 /* LOCK ANY TABLE */,
                                             -47 /* SELECT ANY TABLE */,
                                             -48 /* INSERT ANY TABLE */,
                                             -49 /* UPDATE ANY TABLE */,
                                             -50 /* DELETE ANY TABLE */,
                                             -165/* ANALYZE ANY */))
          )
union all
select u.name, o.name, o2.subname, o.subname,
       m.inserts, m.updates, m.deletes, m.timestamp,
       decode(bitand(m.flags,1),1,'YES','NO'),
       m.drop_segments
from sys.mon_mods_all$ m, sys.obj$ o, sys.tabsubpart$ tsp, sys.obj$ o2,
     sys.user$ u
where o.obj# = m.obj# and o.owner# = u.user# and
      o.obj# = tsp.obj# and o2.obj# = tsp.pobj#
      and (o.owner# = userenv('SCHEMAID')
           or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in (select kzsrorol from x$kzsro))
           or /* user has system privileges */
             exists (select null from v$enabledprivs
                       where priv_number in (-45 /* LOCK ANY TABLE */,
                                             -47 /* SELECT ANY TABLE */,
                                             -48 /* INSERT ANY TABLE */,
                                             -49 /* UPDATE ANY TABLE */,
                                             -50 /* DELETE ANY TABLE */,
                                             -165/* ANALYZE ANY */))
          )
/
comment on table ALL_TAB_MODIFICATIONS is
'Information regarding modifications to tables'
/
comment on column ALL_TAB_MODIFICATIONS.TABLE_OWNER is
'Owner of modified table'
/
comment on column ALL_TAB_MODIFICATIONS.TABLE_NAME is
'Modified table'
/
comment on column ALL_TAB_MODIFICATIONS.PARTITION_NAME is
'Modified partition'
/
comment on column ALL_TAB_MODIFICATIONS.SUBPARTITION_NAME is
'Modified subpartition'
/
comment on column ALL_TAB_MODIFICATIONS.INSERTS is
'Approximate number of rows inserted since last analyze'
/
comment on column ALL_TAB_MODIFICATIONS.UPDATES is
'Approximate number of rows updated since last analyze'
/
comment on column ALL_TAB_MODIFICATIONS.DELETES is
'Approximate number of rows deleted since last analyze'
/
comment on column ALL_TAB_MODIFICATIONS.TIMESTAMP is
'Timestamp of last time this row was modified'
/
comment on column ALL_TAB_MODIFICATIONS.TRUNCATED is
'Was this object truncated since the last analyze?'
/
comment on column ALL_TAB_MODIFICATIONS.DROP_SEGMENTS is
'Number of (sub)partition segment dropped since the last analyze?'
/
create or replace public synonym ALL_TAB_MODIFICATIONS for ALL_TAB_MODIFICATIONS
/
grant select on ALL_TAB_MODIFICATIONS to PUBLIC with grant option
/
create or replace view DBA_TAB_MODIFICATIONS
(TABLE_OWNER, TABLE_NAME, PARTITION_NAME, SUBPARTITION_NAME, INSERTS,
 UPDATES, DELETES, TIMESTAMP, TRUNCATED, DROP_SEGMENTS)
as
select u.name, o.name, null, null,
       m.inserts, m.updates, m.deletes, m.timestamp,
       decode(bitand(m.flags,1),1,'YES','NO'),
       m.drop_segments
from sys.mon_mods_all$ m, sys.obj$ o, sys.tab$ t, sys.user$ u
where o.obj# = m.obj# and o.obj# = t.obj# and o.owner# = u.user#
union all
select u.name, o.name, o.subname, null,
       m.inserts, m.updates, m.deletes, m.timestamp,
       decode(bitand(m.flags,1),1,'YES','NO'),
       m.drop_segments
from sys.mon_mods_all$ m, sys.obj$ o, sys.user$ u
where o.owner# = u.user# and o.obj# = m.obj# and o.type#=19
union all
select u.name, o.name, o2.subname, o.subname,
       m.inserts, m.updates, m.deletes, m.timestamp,
       decode(bitand(m.flags,1),1,'YES','NO'),
       m.drop_segments
from sys.mon_mods_all$ m, sys.obj$ o, sys.tabsubpart$ tsp, sys.obj$ o2,
     sys.user$ u
where o.obj# = m.obj# and o.owner# = u.user# and
      o.obj# = tsp.obj# and o2.obj# = tsp.pobj#
/
comment on table DBA_TAB_MODIFICATIONS is
'Information regarding modifications to tables'
/
comment on column DBA_TAB_MODIFICATIONS.TABLE_OWNER is
'Owner of modified table'
/
comment on column DBA_TAB_MODIFICATIONS.TABLE_NAME is
'Modified table'
/
comment on column DBA_TAB_MODIFICATIONS.PARTITION_NAME is
'Modified partition'
/
comment on column DBA_TAB_MODIFICATIONS.SUBPARTITION_NAME is
'Modified subpartition'
/
comment on column DBA_TAB_MODIFICATIONS.INSERTS is
'Approximate number of rows inserted since last analyze'
/
comment on column DBA_TAB_MODIFICATIONS.UPDATES is
'Approximate number of rows updated since last analyze'
/
comment on column DBA_TAB_MODIFICATIONS.DELETES is
'Approximate number of rows deleted since last analyze'
/
comment on column DBA_TAB_MODIFICATIONS.TIMESTAMP is
'Timestamp of last time this row was modified'
/
comment on column DBA_TAB_MODIFICATIONS.TRUNCATED is
'Was this object truncated since the last analyze?'
/
comment on column DBA_TAB_MODIFICATIONS.DROP_SEGMENTS is
'Number of (sub)partition segment dropped since the last analyze?'
/
grant select on DBA_TAB_MODIFICATIONS to select_catalog_role
/

rem
rem   FAMILY  "SECONDARY_OBJECT"
rem   Comments on secondary objects associated with a domain index
rem
create or replace view DBA_SECONDARY_OBJECTS
   (INDEX_OWNER, INDEX_NAME, SECONDARY_OBJECT_OWNER, SECONDARY_OBJECT_NAME)
as
select u.name, o.name, u1.name, o1.name
from   sys.user$ u, sys.obj$ o, sys.user$ u1, sys.obj$ o1, sys.secobj$ s
where  s.obj# = o.obj# and o.owner# = u.user# and
       s.secobj# = o1.obj#  and  o1.owner# = u1.user#
/
create or replace public synonym DBA_SECONDARY_OBJECTS for DBA_SECONDARY_OBJECTS
/
grant select on DBA_SECONDARY_OBJECTS to select_catalog_role
/
comment on table DBA_SECONDARY_OBJECTS is
'All secondary objects for domain indexes'
/
comment on column DBA_SECONDARY_OBJECTS.INDEX_OWNER is
'Name of the domain index owner'
/
comment on column DBA_SECONDARY_OBJECTS.INDEX_NAME is
'Name of the domain index'
/
comment on column DBA_SECONDARY_OBJECTS.SECONDARY_OBJECT_OWNER is
'Owner of the secondary object'
/
comment on column DBA_SECONDARY_OBJECTS.SECONDARY_OBJECT_NAME is
'Name of the secondary object'
/

create or replace view USER_SECONDARY_OBJECTS
   (INDEX_OWNER, INDEX_NAME, SECONDARY_OBJECT_OWNER, SECONDARY_OBJECT_NAME)
as
select u.name, o.name, u1.name, o1.name
from   sys.user$ u, sys.obj$ o, sys.user$ u1, sys.obj$ o1, sys.secobj$ s
where  s.obj# = o.obj# and o.owner# = u.user# and
       s.secobj# = o1.obj#  and  o1.owner# = u1.user# and
       o.owner# = userenv('SCHEMAID')
/
create or replace public synonym USER_SECONDARY_OBJECTS
   for USER_SECONDARY_OBJECTS
/
grant select on USER_SECONDARY_OBJECTS to PUBLIC with grant option
/
comment on table USER_SECONDARY_OBJECTS is
'All secondary objects for domain indexes'
/
comment on column USER_SECONDARY_OBJECTS.INDEX_OWNER is
'Name of the domain index owner'
/
comment on column USER_SECONDARY_OBJECTS.INDEX_NAME is
'Name of the domain index'
/
comment on column USER_SECONDARY_OBJECTS.SECONDARY_OBJECT_OWNER is
'Owner of the secondary object'
/
comment on column USER_SECONDARY_OBJECTS.SECONDARY_OBJECT_NAME is
'Name of the secondary object'
/

create or replace view ALL_SECONDARY_OBJECTS
   (INDEX_OWNER, INDEX_NAME, SECONDARY_OBJECT_OWNER, SECONDARY_OBJECT_NAME)
as
select u.name, o.name, u1.name, o1.name
from   sys.user$ u, sys.obj$ o, sys.user$ u1, sys.obj$ o1, sys.secobj$ s
where  s.obj# = o.obj# and o.owner# = u.user# and
       s.secobj# = o1.obj#  and  o1.owner# = u1.user# and
       ( o.owner# = userenv('SCHEMAID')
         or
         o.obj# in ( select obj#
                    from sys.objauth$
                    where grantee# in ( select kzsrorol
                                        from x$kzsro
                                      )
                   )
         or
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
       )
/
create or replace public synonym ALL_SECONDARY_OBJECTS
   for ALL_SECONDARY_OBJECTS
/
grant select on ALL_SECONDARY_OBJECTS to PUBLIC with grant option
/
comment on table ALL_SECONDARY_OBJECTS is
'All secondary objects for domain indexes'
/
comment on column ALL_SECONDARY_OBJECTS.INDEX_OWNER is
'Name of the domain index owner'
/
comment on column ALL_SECONDARY_OBJECTS.INDEX_NAME is
'Name of the domain index'
/
comment on column ALL_SECONDARY_OBJECTS.SECONDARY_OBJECT_OWNER is
'Owner of the secondary object'
/
comment on column ALL_SECONDARY_OBJECTS.SECONDARY_OBJECT_NAME is
'Name of the secondary object'
/

REM change data capture views
@@catcdc

Rem Auditing views
@@cataudit

Rem Add support for ejb generated classes
Rem This is just a stub view - the actual view is created during
Rem the JIS initialization
Rem This statement must happen before @catexp.
create or replace view sns$ejb$gen$ (owner, shortname) as
  select u.name, o.name from user$ u, obj$ o where 1=2
/

Rem  Define UTL_RAW package/functions needed by catexp
Rem   (moved here from catproc.sql)
@@utlraw

Rem Import/export views
@@catexp

Rem Loader views
@@catldr

Rem Partitioning views
@@catpart

Rem Object views
@@catadt

Rem Summary views
@@catsum

Rem Manageability Advisor
@@catadvtb
@@dbmsadv
@@catadv
@@catsumaa

Rem External Table views
@@catxtb

Rem Recovery Catalog owner role
Rem Do not drop this role recovery_catalog_owner.
Rem Drop this role will revoke this role from all rman users.
Rem If this role exists, ORA-1921 is expected.
create role recovery_catalog_owner;
grant create session,alter session,create synonym,create view,
  create database link,create table,create cluster,create sequence,
  create trigger,create procedure, create type to recovery_catalog_owner;

Rem
Rem unused index
Rem
create or replace view V$OBJECT_USAGE
    (INDEX_NAME,
     TABLE_NAME,
     MONITORING,
     USED,
     START_MONITORING,
     END_MONITORING)
as
select io.name, t.name,
       decode(bitand(i.flags, 65536), 0, 'NO', 'YES'),
       decode(bitand(ou.flags, 1), 0, 'NO', 'YES'),
       ou.start_monitoring,
       ou.end_monitoring
from sys.obj$ io, sys.obj$ t, sys.ind$ i, sys.object_usage ou
where io.owner# = userenv('SCHEMAID')
  and i.obj# = ou.obj#
  and io.obj# = ou.obj#
  and t.obj# = i.bo#
/
create or replace public synonym V$OBJECT_USAGE for V$OBJECT_USAGE
/
grant select on V$OBJECT_USAGE to public
/
comment on table V$OBJECT_USAGE is
'Record of index usage'
/
comment on column V$OBJECT_USAGE.INDEX_NAME is
'Name of the index'
/
comment on column V$OBJECT_USAGE.TABLE_NAME is
'Name of the table upon which the index was build'
/
comment on column V$OBJECT_USAGE.MONITORING is
'Whether the monitoring feature is on'
/
comment on column V$OBJECT_USAGE.USED is
'Whether the index has been accessed'
/
comment on column V$OBJECT_USAGE.START_MONITORING is
'When the monitoring feature is turned on'
/
comment on column V$OBJECT_USAGE.END_MONITORING is
'When the monitoring feature is turned off'
/


remark
remark  FAMILY "RECYCLEBIN"
remark  List of objects in recycle bin
remark
create or replace view USER_RECYCLEBIN
    (OBJECT_NAME, ORIGINAL_NAME, OPERATION, TYPE, TS_NAME,
     CREATETIME, DROPTIME, DROPSCN, PARTITION_NAME, CAN_UNDROP, CAN_PURGE,
     RELATED, BASE_OBJECT, PURGE_OBJECT, SPACE)
as
select o.name, r.original_name,
       decode(r.operation, 0, 'DROP', 1, 'TRUNCATE', 'UNDEFINED'),
       decode(r.type#, 1, 'TABLE', 2, 'INDEX', 3, 'INDEX',
                       4, 'NESTED TABLE', 5, 'LOB', 6, 'LOB INDEX',
                       7, 'DOMAIN INDEX', 8, 'IOT TOP INDEX',
                       9, 'IOT OVERFLOW SEGMENT', 10, 'IOT MAPPING TABLE',
                       11, 'TRIGGER', 12, 'CONSTRAINT', 13, 'Table Partition',
                       14, 'Table Composite Partition', 15, 'Index Partition',
                       16, 'Index Composite Partition', 17, 'LOB Partition',
                       18, 'LOB Composite Partition',
                       'UNDEFINED'),
       t.name,
       to_char(o.ctime, 'YYYY-MM-DD:HH24:MI:SS'),
       to_char(r.droptime, 'YYYY-MM-DD:HH24:MI:SS'),
       r.dropscn, r.partition_name,
       decode(bitand(r.flags, 4), 0, 'NO', 4, 'YES', 'NO'),
       decode(bitand(r.flags, 2), 0, 'NO', 2, 'YES', 'NO'),
       r.related, r.bo, r.purgeobj, r.space
from sys.obj$ o, sys.recyclebin$ r, sys.ts$ t
where r.owner# = userenv('SCHEMAID')
  and o.obj# = r.obj#
  and r.ts# = t.ts#(+)
/
comment on table USER_RECYCLEBIN is
'User view of his recyclebin'
/
comment on column USER_RECYCLEBIN.OBJECT_NAME is
'New name of the object'
/
comment on column USER_RECYCLEBIN.ORIGINAL_NAME is
'Original name of the object'
/
comment on column USER_RECYCLEBIN.OPERATION is
'Operation carried out on the object'
/
comment on column USER_RECYCLEBIN.TYPE is
'Type of the object'
/
comment on column USER_RECYCLEBIN.TS_NAME is
'Tablespace Name to which object belongs'
/
comment on column USER_RECYCLEBIN.CREATETIME is
'Timestamp for the creating of the object'
/
comment on column USER_RECYCLEBIN.DROPTIME is
'Timestamp for the dropping of the object'
/
comment on column USER_RECYCLEBIN.DROPSCN is
'SCN of the transaction which moved object to Recycle Bin'
/
comment on column USER_RECYCLEBIN.PARTITION_NAME is
'Partition Name which was dropped'
/
comment on column USER_RECYCLEBIN.CAN_UNDROP is
'User can undrop this object'
/
comment on column USER_RECYCLEBIN.CAN_PURGE is
'User can undrop this object'
/
comment on column USER_RECYCLEBIN.RELATED is
'Parent objects Obj#'
/
comment on column USER_RECYCLEBIN.BASE_OBJECT is
'Base objects Obj#'
/
comment on column USER_RECYCLEBIN.PURGE_OBJECT is
'Obj# for object which gets purged'
/
comment on column USER_RECYCLEBIN.SPACE is
'Number of blocks used by this object'
/
create or replace public synonym USER_RECYCLEBIN for USER_RECYCLEBIN
/
create or replace public synonym RECYCLEBIN for USER_RECYCLEBIN
/
grant select on USER_RECYCLEBIN to PUBLIC with grant option
/

create or replace view DBA_RECYCLEBIN
    (OWNER, OBJECT_NAME, ORIGINAL_NAME, OPERATION, TYPE, TS_NAME,
     CREATETIME, DROPTIME, DROPSCN, PARTITION_NAME, CAN_UNDROP, CAN_PURGE,
     RELATED, BASE_OBJECT, PURGE_OBJECT, SPACE)
as
select u.name, o.name, r.original_name,
       decode(r.operation, 0, 'DROP', 1, 'TRUNCATE', 'UNDEFINED'),
       decode(r.type#, 1, 'TABLE', 2, 'INDEX', 3, 'INDEX',
                       4, 'NESTED TABLE', 5, 'LOB', 6, 'LOB INDEX',
                       7, 'DOMAIN INDEX', 8, 'IOT TOP INDEX',
                       9, 'IOT OVERFLOW SEGMENT', 10, 'IOT MAPPING TABLE',
                       11, 'TRIGGER', 12, 'CONSTRAINT', 13, 'Table Partition',
                       14, 'Table Composite Partition', 15, 'Index Partition',
                       16, 'Index Composite Partition', 17, 'LOB Partition',
                       18, 'LOB Composite Partition',
                       'UNDEFINED'),
       t.name,
       to_char(o.ctime, 'YYYY-MM-DD:HH24:MI:SS'),
       to_char(r.droptime, 'YYYY-MM-DD:HH24:MI:SS'),
       r.dropscn, r.partition_name,
       decode(bitand(r.flags, 4), 0, 'NO', 4, 'YES', 'NO'),
       decode(bitand(r.flags, 2), 0, 'NO', 2, 'YES', 'NO'),
       r.related, r.bo, r.purgeobj, r.space
from sys.obj$ o, sys.recyclebin$ r, sys.user$ u, sys.ts$ t
where o.obj# = r.obj#
  and r.owner# = u.user#
  and r.ts# = t.ts#(+)
/
comment on table DBA_RECYCLEBIN is
'Description of the Recyclebin view accessible to the user'
/
comment on column DBA_RECYCLEBIN.OWNER is
'Name of the original owner of the object'
/
comment on column DBA_RECYCLEBIN.OBJECT_NAME is
'New name of the object'
/
comment on column DBA_RECYCLEBIN.ORIGINAL_NAME is
'Original name of the object'
/
comment on column DBA_RECYCLEBIN.OPERATION is
'Operation carried out on the object'
/
comment on column DBA_RECYCLEBIN.TYPE is
'Type of the object'
/
comment on column DBA_RECYCLEBIN.TS_NAME is
'Tablespace Name to which object belongs'
/
comment on column DBA_RECYCLEBIN.CREATETIME is
'Timestamp for the creating of the object'
/
comment on column DBA_RECYCLEBIN.DROPTIME is
'Timestamp for the dropping of the object'
/
comment on column DBA_RECYCLEBIN.DROPSCN is
'SCN of the transaction which moved object to Recycle Bin'
/
comment on column DBA_RECYCLEBIN.PARTITION_NAME is
'Partition Name which was dropped'
/
comment on column DBA_RECYCLEBIN.CAN_UNDROP is
'User can undrop this object'
/
comment on column DBA_RECYCLEBIN.CAN_PURGE is
'User can purge this object'
/
comment on column DBA_RECYCLEBIN.RELATED is
'Parent objects Obj#'
/
comment on column DBA_RECYCLEBIN.BASE_OBJECT is
'Base objects Obj#'
/
comment on column DBA_RECYCLEBIN.PURGE_OBJECT is
'Obj# for object which gets purged'
/
comment on column DBA_RECYCLEBIN.SPACE is
'Number of blocks used by this object'
/
create or replace public synonym DBA_RECYCLEBIN for DBA_RECYCLEBIN
/
grant select on DBA_RECYCLEBIN to select_catalog_role
/
create or replace view V_$TRANSPORTABLE_PLATFORM
as select * from V$TRANSPORTABLE_PLATFORM
/
create or replace public synonym V$TRANSPORTABLE_PLATFORM
for V_$TRANSPORTABLE_PLATFORM
/
grant select on V_$TRANSPORTABLE_PLATFORM to select_catalog_role
/
create or replace view GV_$TRANSPORTABLE_PLATFORM
as select * from GV$TRANSPORTABLE_PLATFORM
/
create or replace public synonym GV$TRANSPORTABLE_PLATFORM
for GV$_TRANSPORTABLE_PLATFORM
/
grant select on GV_$TRANSPORTABLE_PLATFORM to select_catalog_role
/
create or replace view FLASHBACK_TRANSACTION_QUERY
as select xid, start_scn, start_timestamp,
          decode(commit_scn, 0, commit_scn, 281474976710655, NULL, commit_scn)
          commit_scn, commit_timestamp,
          logon_user, undo_change#, operation, table_name, table_owner,
          row_id, undo_sql
from sys.x$ktuqqry
/
comment on table FLASHBACK_TRANSACTION_QUERY is
'Description of the flashback transaction query view'
/
comment on column FLASHBACK_TRANSACTION_QUERY.XID is
'Transaction identifier'
/
comment on column FLASHBACK_TRANSACTION_QUERY.START_SCN is
'Transaction start SCN'
/
comment on column FLASHBACK_TRANSACTION_QUERY.START_TIMESTAMP is
'Transaction start timestamp'
/
comment on column FLASHBACK_TRANSACTION_QUERY.COMMIT_SCN is
'Transaction commit SCN'
/
comment on column FLASHBACK_TRANSACTION_QUERY.COMMIT_TIMESTAMP is
'Transaction commit timestamp'
/
comment on column FLASHBACK_TRANSACTION_QUERY.LOGON_USER is
'Logon user for transaction'
/
comment on column FLASHBACK_TRANSACTION_QUERY.UNDO_CHANGE# is
'1-based undo change number'
/
comment on column FLASHBACK_TRANSACTION_QUERY.OPERATION is
'forward operation for this undo'
/
comment on column FLASHBACK_TRANSACTION_QUERY.TABLE_NAME is
'table name to which this undo applies'
/
comment on column FLASHBACK_TRANSACTION_QUERY.TABLE_OWNER is
'owner of table to which this undo applies'
/
comment on column FLASHBACK_TRANSACTION_QUERY.ROW_ID is
'rowid to which this undo applies'
/
comment on column FLASHBACK_TRANSACTION_QUERY.UNDO_SQL is
'SQL corresponding to this undo'
/
create or replace public synonym FLASHBACK_TRANSACTION_QUERY
     for FLASHBACK_TRANSACTION_QUERY
/
grant select on FLASHBACK_TRANSACTION_QUERY to public;
/

Rem Add workgroup services views
create or replace view DBA_SERVICES
as select SERVICE_ID, NAME, NAME_HASH, NETWORK_NAME,
          CREATION_DATE, CREATION_DATE_HASH,
          FAILOVER_METHOD, FAILOVER_TYPE, FAILOVER_RETRIES, FAILOVER_DELAY,
          MIN_CARDINALITY, MAX_CARDINALITY,
          decode(GOAL, 0, 'NONE', 1, 'SERVICE_TIME', 2, 'THROUGHPUT', NULL)
            GOAL,
          decode(bitand(FLAGS, 2), 2, 'Y', 'N') DTP,
          decode(bitand(FLAGS, 1), 1, 'YES', 0, 'NO') ENABLED,
          decode(bitand(NVL(FLAGS,0), 4), 4, 'YES',
                                   0, 'NO', 'NO') AQ_HA_NOTIFICATIONS,
          decode(bitand(NVL(FLAGS,0), 8), 8, 'LONG', 0, 'SHORT', 'SHORT') CLB_GOAL
   from service$
where DELETION_DATE is null
/

comment on column DBA_SERVICES.SERVICE_ID is
'The unique ID for this service'
/

comment on column DBA_SERVICES.NAME is
'The short name for the service'
/

comment on column DBA_SERVICES.NAME_HASH is
'The hash of the short name for the service'
/

comment on column DBA_SERVICES.NETWORK_NAME is
'The network name used to connect to the service'
/

comment on column DBA_SERVICES.CREATION_DATE is
'The date the service was created'
/

comment on column DBA_SERVICES.CREATION_DATE_HASH is
'The hash of the creation date'
/

comment on column DBA_SERVICES.FAILOVER_METHOD is
'The failover method (BASIC or NONE) for the service'
/

comment on column DBA_SERVICES.FAILOVER_TYPE is
'The failover type (SESSION or SELECT) for the service'
/

comment on column DBA_SERVICES.FAILOVER_RETRIES is
'The number of retries when failing over the service'
/

comment on column DBA_SERVICES.FAILOVER_DELAY is
'The delay between retries when failing over the service'
/

comment on column DBA_SERVICES.MIN_CARDINALITY is
'The minimum cardinality of this service to be maintained by director'
/

comment on column DBA_SERVICES.MAX_CARDINALITY is
'The maximum cardinality of this service to be allowed by director'
/

comment on column DBA_SERVICES.ENABLED is
'Indicates whether or not this service will be started/maintained by director'
/

comment on column DBA_SERVICES.AQ_HA_NOTIFICATIONS is
'Indicates whether AQ notifications are sent for HA events'
/

comment on column DBA_SERVICES.GOAL is
'The service workload management goal'
/

comment on column DBA_SERVICES.DTP is
'DTP flag for services'
/

comment on column DBA_SERVICES.CLB_GOAL is
'Connection load balancing goal for services'
/

create or replace public synonym DBA_SERVICES
     for DBA_SERVICES
/
grant select on DBA_SERVICES to select_catalog_role
/


create or replace view ALL_SERVICES
as select * from dba_services
/
create or replace public synonym ALL_SERVICES
     for ALL_SERVICES
/
grant select on ALL_SERVICES to select_catalog_role
/

commit;

create or replace view V_$DB_TRANSPORTABLE_PLATFORM
as select * from V$DB_TRANSPORTABLE_PLATFORM
/
create or replace public synonym V$DB_TRANSPORTABLE_PLATFORM
for V_$DB_TRANSPORTABLE_PLATFORM
/
grant select on V_$DB_TRANSPORTABLE_PLATFORM to select_catalog_role
/
create or replace view GV_$DB_TRANSPORTABLE_PLATFORM
as select * from GV$DB_TRANSPORTABLE_PLATFORM
/
create or replace public synonym GV$DB_TRANSPORTABLE_PLATFORM
for GV$_DB_TRANSPORTABLE_PLATFORM
/
grant select on GV_$DB_TRANSPORTABLE_PLATFORM to select_catalog_role
/

create or replace view DBA_CONNECT_ROLE_GRANTEES
  (GRANTEE, PATH_OF_CONNECT_ROLE_GRANT, ADMIN_OPT)
as
select grantee, connect_path, admin_option
from (select grantee,
             'CONNECT'||SYS_CONNECT_BY_PATH(grantee, '/') connect_path,
             granted_role, admin_option
      from   sys.dba_role_privs
      where decode((select type# from user$ where name = upper(grantee)),
               0, 'ROLE',
               1, 'USER') = 'USER'
      connect by nocycle granted_role = prior grantee
      start with granted_role = upper('CONNECT'))
/
comment on table DBA_CONNECT_ROLE_GRANTEES is
'Information regarding which users are granted CONNECT'
/
comment on column DBA_CONNECT_ROLE_GRANTEES.GRANTEE is
'User or schema to which CONNECT is granted'
/
comment on column DBA_CONNECT_ROLE_GRANTEES.PATH_OF_CONNECT_ROLE_GRANT is
'The path of role inheritence through which the grantee is granted CONNECT'
/
comment on column DBA_CONNECT_ROLE_GRANTEES.ADMIN_OPT is
'If the grantee was granted the CONNECT role with Admin Option'
/
create or replace public synonym DBA_CONNECT_ROLE_GRANTEES
for DBA_CONNECT_ROLE_GRANTEES
/
grant select on DBA_CONNECT_ROLE_GRANTEES to select_catalog_role
/
Rem ADD NEW VIEWS ABOVE THIS BLOCK
------------------------------------------------------------------------------

Rem Indicate load complete

BEGIN
   dbms_registry.loaded('CATALOG');
END;
/

