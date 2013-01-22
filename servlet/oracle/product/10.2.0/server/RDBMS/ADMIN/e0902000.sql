Rem
Rem $Header: e0902000.sql 07-may-2005.09:33:43 rburns Exp $
Rem
Rem e0902000.sql
Rem
Rem Copyright (c) 2000, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      e0902000.sql - downgrade Oracle RDBMS from current release to 9.2.0
Rem
Rem    DESCRIPTION
Rem
Rem
Rem      This script performs the downgrade in the following stages:
Rem        STAGE 1: downgrade from the current release to 10.1;
Rem        STAGE 2: downgrade base data dictionary objects from 10.1 to 9.2.0
Rem                 a. remove new 10.1 system/object privileges
Rem                 b. remove new 10.1 catalog views/synonyms
Rem                    (previous release views will be recreated after)
Rem                 c. remove program units referring to new 10.1 fixed views
Rem                    or non-compiling in 9.2.0
Rem                 d. update new 10.1 columns to NULL or other values,
Rem                    delete rows from new 10.1 tables, and drop new 
Rem                    10.1 type attributes, methods, etc.
Rem                 e. downgrade system types from 10.1 to 9.2.0
Rem
Rem    NOTES
Rem      * This script needs to be run in the current release's environment
Rem        (before installing the release to which you want to downgrade).
Rem      * This script must be run using SQL*PLUS.
Rem      * You must be connected AS SYSDBA to run this script.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rburns      05/07/05 - limit rollback 
Rem    weiwang     05/02/05 - catch queue table not exist error 
Rem    alakshmi    04/12/05 - drop package dbms_streams_mt 
Rem    rburns      04/02/05 - fix lrg problems 
Rem    weiwang     03/29/05 - drop [dba|user]_queue_schedules
Rem    rburns      03/28/05 - drop table for utlip in 10.2 
Rem    evoss       01/25/05 - drop scheduler_int_array_type 
Rem    rramkiss    01/10/05 - drop 10.2 pkg dbms_isched_chain_condition 
Rem    rburns      12/16/04 - dbms_utility fix 
Rem    nshodhan    11/19/04 - bug 4020148 
Rem    jnesheiw    08/04/04 - grant CONNECT to LOGSTDBY_ADMINISTRATOR 
Rem    rburns      07/13/04 - move top-level actions to catdwgrd.sql 
Rem    rburns      06/07/04 - registry downgrade 
Rem    rramkiss    06/14/04 - drop new 10gR2 Scheduler types 
Rem    nfolkert    05/25/04 - no need to drop public synonyms of mv objects
Rem    jstamos     05/17/04 - drop queue in anon block 
Rem    jciminsk    03/05/04 - drop database link cdir$dbl 
Rem    jciminsk    03/04/04 - move grid to e1001000.sql 
Rem    jciminsk    02/06/04 - merge from RDBMS_MAIN_SOLARIS_040203 
Rem    jciminsk    12/12/03 - merge from RDBMS_MAIN_SOLARIS_031209 
Rem    lchidamb    10/30/03 - drop dbms_db_director_rpcs package 
Rem    abegueli    09/15/03 - call drop_cluster_connectivity 
Rem    jciminsk    08/19/03 - branch merge 
Rem    lchidamb    08/14/03 - add director quiesce operations table 
Rem    lchidamb    08/13/03 - add node/service policy tables 
Rem    elu         08/01/03 - drop synonyms for policy table
Rem    htran       07/30/03 - drop director export package
Rem    lchidamb    07/29/03 - truncate escalation table, drop director view
Rem    jstamos     07/31/03 - uppercase director 
Rem    jstamos     07/31/03 - add director queue views 
Rem    jstamos     07/29/03 - drop director views 
Rem    rvenkate    07/16/03 - add services to aq_queues
Rem    lchidamb    07/17/03 - drop new director types
Rem    elu         07/16/03 - add db priority for grid
Rem    bpwang      04/07/04 - Drop internal transform type
Rem    sbalaram    04/13/04 - remove lcr_xml_lib
Rem    rburns      01/07/04 - add calls to 10.1 scripts 
Rem    mhho        12/24/03 - drop dbms_crypto
Rem    gviswana    12/17/03 - Remove utl_recomp views 
Rem    xan         12/18/03 - bug fix: 3320404
Rem    esoyleme    12/15/03 - drop olap_condition 
Rem    htran       12/07/03 - drop _DBA streams message consumers views.
Rem                           Allow parsing of internal subscriber addresses.
Rem    najain      12/08/03 - drop package xml_schema_name_present
Rem    gmulagun    12/03/03 - 3294084: Upgrade user$.audit$ column 
Rem    jciminsk    11/24/03 - lrg-1595981: drop package dbms_prvt_trace 
Rem    qyu         11/14/03 - drop timezone_files fixed views 
Rem    mlfeng      11/24/03 - remove wrh$_rollstat, add latch_misses_summary_bl
Rem    hqian       11/13/03 - OSM -> ASM 
Rem    mkeihl      11/13/03 - Update for new feature usage proc 
Rem    nbhatt      11/21/03 - add evaluation context to aq rules 
Rem    jxchen      11/10/03 - Drop dba_alert_arguments view 
Rem    bgarin      11/07/03 - change log$ downgrade to include contents column
Rem    ksurlake    11/05/03 - Bug 2867252: downgrade for reg_info and reg$
Rem    ksurlake    11/03/03 - Bug 2867252: downgrade for aq$_srvntfn_msg
Rem    gssmith     11/07/03 - Add new advisor view 
Rem    pbelknap    10/28/03 - changing swrf to awr 
Rem    mlfeng      11/01/03 - add dbfus partition routines 
Rem    rramkiss    11/04/03 - lrg-1590893 
Rem    mlfeng      10/30/03 - truncate wri_sch tables 
Rem    najain      11/07/03 - remove XML_SCHEMA_NAME_PRESENT 
Rem    rburns      10/28/03 - drop ldap packages 
Rem    vraja       10/21/03 - rename DBA_TRANSACTION_QUERY to 
Rem                           FLASHBACK_TRANSACTION_QUERY
Rem    wesmith     10/16/03 - drop package dbms_transform_internal 
Rem    rvenkate    10/14/03 - remove buffered from propagation views 
Rem    pbelknap    10/09/03 - removing swrfrpt_internal_type 
Rem    pbelknap    10/02/03 - upd swrfrpt types 
Rem    alakshmi    10/02/03 - Drop package dbms_streams_adm_utl_int 
Rem    gkulkarn    09/27/03 - Bugfix 3140873: set ccol$ spare1 to null 
Rem    zqiu        09/22/03 - drop OLAP runtime cursor functions 
Rem    rramkiss    09/04/03 - drop scheduler queue 
Rem    jawilson    08/04/03 - Remove timezone column from aq$_queue_tables 
Rem    rramkiss    09/15/03 - lrg-1572424 
Rem    raguzman    09/16/03 - drop new logstdby_unsupported_tables view 
Rem    smuthuli    09/24/03 - drop DBA_TABLESPACE_USAGE_METRICS view 
Rem    schakkap    09/09/03 - *_TAB_STATS_HISTORY 
Rem    mlfeng      08/27/03 - drop AWR rac tables/views
Rem    mlfeng      07/28/03 - truncate new wrh$ tables (services)
Rem    sbalaram    09/04/03 - drop column compare views 
Rem    kmeiyyap    09/03/03 - drop v$buffered_propagation_sndr/rcvr
Rem    rburns      08/28/03 - cleanup 
Rem    araghava    09/04/03 - (3127926): use more efficient sql to update 
Rem                           partitioning tables 
Rem    rramkiss    09/04/03 - remove scheduler chains 
Rem    rramkiss    09/04/03 - update for job table update 
Rem    schakkap    08/03/03 - delete stats for RDBMS component schemas
Rem    jeffyu      08/25/03 - dropping dbms_rcvman package - lrg 1561312 
Rem    sdizdar     08/22/03 - remove gv_$rman_status_current 
Rem    jawilson    08/08/03 - Remove streams_pool_advice view 
Rem    sagrawal    08/18/03 - drop library dbms_warning_lib 
Rem    nmacnaug    08/14/03 - add new fixed table 
Rem    skaluska    08/20/03 - fix typo in AQ downgrade 
Rem    htran       08/14/03 - remove director export unregistration
Rem    lchidamb    08/14/03 - remove plb dependent dba views for catalog merge 
Rem    lchidamb    08/14/03 - add director quiesce operations table 
Rem    lchidamb    08/13/03 - add node/service policy tables 
Rem    elu         08/01/03 - drop synonyms for policy table
Rem    htran       07/30/03 - drop director export package
Rem    lchidamb    07/29/03 - truncate escalation table, drop director view
Rem    jstamos     07/31/03 - uppercase director 
Rem    jstamos     07/31/03 - add director queue views 
Rem    jstamos     07/29/03 - drop director views 
Rem    rvenkate    07/16/03 - add services to aq_queues
Rem    lchidamb    07/17/03 - drop new director types
Rem    elu         07/16/03 - add db priority for grid
Rem    skaluska    08/14/03 - Merge dictionary changes to 10i beta2 
Rem    ajadams     08/15/03 - drop logmnr_latch 
Rem    spannala    07/31/03 - update rls$ remove bits > ub1maxval in stmt_type
Rem    htran       08/04/03 - fix patch_queue_table call 
Rem    alakshmi    07/24/03 - add cascade option
Rem    clei        07/23/03 - update synonym policies
Rem    mlfeng      07/25/03 - drop swrf packages
Rem    bpwang      07/15/03 - bug 2771770:  dropping types streams$nv_node 
Rem                           and streams$nv_array
Rem    dsemler     07/10/03 - downgrade for g/v$service
Rem    rpingte     07/07/03 - drop director dblinks
Rem    rburns      07/03/03 - drop more packages
Rem    jstamos     06/30/03 - add director state
Rem    kigoyal     07/16/03 - add v$service_event, v$service_wait_Class
Rem    jstamos     06/30/03 - add director state
Rem    kdias       06/27/03 - advisor fmwk upgrade/downgrade changes
Rem    rramkiss    06/26/03 - remove new sequence for job_name suffixes
Rem    jstamos     06/26/03 - drop resonate result type
Rem    nbhatt      06/25/03 - remove other tables as dependents of queue table
Rem    mramache    06/23/03 - sql profiles
Rem    rramkiss    06/20/03 - drop rules/rulesets on the job queue
Rem    lchidamb    06/19/03 - drop alert propagation
Rem    svivian     06/19/03 - set node_name to NULL
Rem    jstamos     06/19/03 - another director type
Rem    jstamos     06/17/03 - drop another dir queue
Rem    jstamos     06/12/03 - drop more director types
Rem    abegueli    06/04/03 - move director object removal
Rem    jstamos     05/28/03 - remove director inheritance
Rem    lchidamb    05/14/03 - use one type any event queue
Rem    abegueli    05/09/03 - remove srvqueue
Rem    jciminsk    05/06/03 - drop director package dbms_prvt_trace
Rem    lchidamb    05/12/03 - drop public synonyms
Rem    lchidamb    05/09/03 - remove more director objects
Rem    jstamos     04/24/03 - remove director objects
Rem    skaluska    04/15/03 - rename dbms_migration to dbms_tsm
Rem    skaluska    03/20/03 - drop dbms_migration
Rem    schakkap    05/31/03 - change OPTSTAT_SAVSKIP$ to OPTSTAT_HIST_CONTROL$
Rem    jawilson    05/09/03 - rename _NR IOT
Rem    gngai       06/17/03 - renamed wrh$_session_metric_history
Rem    rramkiss    05/09/03 - drop new scheduler types
Rem    alakshmi    04/18/03 - Rename dbms_streams_tablespaces to 
Rem                           dbms_streams_tablespace_adm
Rem    jstamos     03/18/03 - streams tablespaces
Rem    lkaplan     06/04/03 - add convert_long_to_lob_chunk
Rem    dvoss       06/02/03 - drop logmnr_error$ and logmnr_session_evolve$
Rem    liwong      06/01/03 - Add apply$_constraint_columns
Rem    tfyu        06/12/03 - add script for dbms_sum_rweq_export
Rem    mdevin      06/03/03 - Downgrade to smon_scn_time table
Rem    alakshmi    05/21/03 - drop package dbms_streams_lcr_int
Rem    rburns      06/02/03 - more drop packages
Rem    dvoss       06/02/03 - drop logmnr_error$ and logmnr_session_evolve$
Rem    sbalaram    05/31/03 - drop streams$_dest_objs, streams$_dest_obj_cols
Rem    sylin       05/29/03 - Drop utl_sys_compress and UTL_SYS_CMP_LIB
Rem    weiwang     05/12/03 - modify rules downgrade code
Rem    rpang       05/25/03 - Drop new pl/sql compiler parameters
Rem    pabingha    05/21/03 - remove CDC Data Pump actions/callouts
Rem    krajaman    05/20/03 - Add d_owner# depdendency$ for downgrades 
Rem    htran       05/12/03 - put aq expact$ entries back to 9.2 format
Rem                           strip quotes from subscriber addresses
Rem    sdizdar     05/06/03 - no more  v_$obsolete_backup_files
Rem    rvissapr    05/20/03 - bug 2944537 - add exempt identity policy
Rem    weiwang     05/12/03 - fix typo in patch_queue_table
Rem    jxchen      05/29/03 - Drop DBMS_SERVER_ALERT_EXPORT package 
Rem    elu         05/07/03 - set start_scn in streams$_apply_milestone to NULL
Rem    nshodhan    05/07/03 - clear streams_unsupported bit
Rem    ychan       05/10/03 - Drop dbsnmp package
Rem    weiwang     04/22/03 - patch queue tables during downgrade
Rem    bdagevil    05/08/03 - drop v$advisor_progress on downgrades
Rem    gssmith     05/09/03 - Add downgrade scripts for SQL Access Advisor
Rem    alakshmi    05/01/03 - Drop package dbms_streams_adm_utl_invok
Rem    rburns      04/29/03 - cleanup SVRMGMT downgrade
Rem    nshodhan    04/22/03 - bug-2897618
Rem    bdagevil    04/28/03 - merge new file
Rem    nshodhan    04/17/03 - drop type body lcr$_row_unit
Rem    nshodhan    03/20/03 - drop lcr$_row_record.get_long_information
Rem    rburns      04/06/03 - CDC packages
Rem    bemeng      04/01/03 - drop public synonyms of v$filespace_usage
Rem    mlfeng      04/21/03 - downgrade wrh$_optimizer_env
Rem    tbgraves    03/04/03 - drop library dbms_stat_funcs_aux_lib
Rem    rburns      02/21/03 - more drops
Rem    rramkiss    02/21/03 - remove new all_scheduler_* views
Rem    rburns      02/17/03 - add more drop packages
Rem    htran       02/17/03 - drop dbms_streams_datapump* packages
Rem    jawilson    02/13/03 - v$ views for buffered queues
Rem    jawilson    02/10/03 - replace expanded base view on downgrade
Rem    vraja       02/10/03 - remove FLASHBACK ANY TRANSACTION priv
Rem    gviswana    02/03/03 - Invalidate views to pick up synonym dependences
Rem    wyang       02/13/03 - drop flashbacktblist
Rem    tkeefe      02/05/03 - Bug e0902000.sql: Fix double execution of proxy 
Rem                           metadata inserts
Rem    ruchen      02/03/03 - drop px_buffer_advice
Rem    mxiao       01/30/03 - rename MAT VIEW to SNAPSHOT in AUDIT_ACTIONS
Rem    thoang      02/03/03 - alter uritype to remove 10.1 methods 
Rem    rgmani      01/29/03 - Move scheduler job drop to earlier in the file
Rem    liwong      01/23/03 - Drop Streams views support
Rem    kigoyal     01/29/03 - adding v$temp_histogram
Rem    amanikut    01/23/03 - drop insertXML(), deleteXML(), updateXML()
Rem    srajagop    01/25/03 - job log
Rem    rpang       01/21/03 - added *_plsql_objects views
Rem    sltam       01/16/03 - drop package dbms_service
Rem    liwong      01/20/03 - LCR compatible support
Rem    pabingha    01/17/03 - CDC subscription description length
Rem    rramkiss    01/23/03 - drop scheduler *_running_jobs views
Rem    rburns      01/14/03 - add dbms_registry calls, drop more packages
Rem    weiwang     01/15/03 - Fix typo in queue downgrade script
Rem    qialiu      01/17/03 - drop type body of some ojms msg type
Rem    twtong      01/13/03 - fix bug-2677089
Rem    dvoss       01/14/03 - add logminer checkpoint downgrade
Rem    evoss       01/16/03 - scheduler running jobs dynamic views
Rem    ksurlake    01/17/03 - Delete spilled iots
Rem    alakshmi    12/19/02 - turn off hotmining for RAC
Rem    rburns      12/10/02 - registry$ downgrade and move AQ block
Rem    molagapp    12/24/02 - disable db_recovery_file_dest
Rem    htran       12/16/02 - strip quotes from subscriber rule sets
Rem    jwwarner    01/02/03 - drop xmlgenformattype fcn
Rem    weiwang     12/24/02 - add downgrade script for AQ
Rem    akalra      01/13/03 - downgrade for smon_scn_time
Rem    schakkap    12/18/02 - drop optimizer statistics views
Rem    mbrey       12/19/02 - adding columns to cdc_change_tables for 10.1
Rem    mxiao       12/17/02 - rename the priv from mat view to snapshot
Rem    rramkiss    12/20/02 - sync with updated job scheduler views
Rem    gclaborn    12/12/02 - Set column parse_attr to null in metaxslparam$
Rem    rvissapr    12/16/02 - bug 2594538
Rem    raguzman    12/19/02 - drop logstdby_support view on downgrade
Rem    gssmith     12/17/02 - 
Rem    gssmith     12/17/02 - Access Advisor upgrade/downgrade
Rem    jwwarner    12/30/02 - xmltype downgrade stuff
Rem    asundqui    12/11/02 - drop (g)v$osstat
Rem    sslim       11/22/02 - lrg 1112873: logical standby support
Rem    rxgovind    12/09/02 - drop new methods of AnyData on downgrade
Rem    lvbcheng    11/13/02 - Drop plsql profiler packages
Rem    htran       11/21/02 - strip quotes from long procedrue names in
Rem                           Streams tables
Rem    rramkiss    11/19/02 - Remove all_scheduler_* views
Rem    htran       11/15/02 - drop dbms_streams_decl package
Rem    mkrishna    11/14/02 - downgrade xmlgenformattype
Rem    nmacnaug    11/15/02 - add current_block_server view
Rem    sbalaram    11/12/02 - drop dbms_repcat_migration
Rem    alakshmi    11/08/02 - streams$_capture_process.version added in 10.1
Rem    alakshmi    11/06/02 - Downgrade Streams Capture process
Rem    pabingha    11/13/02 - fix CDC sub. downgrade
Rem    sagrawal    10/11/02 - PL/SQL warnings
Rem    jwlee       11/07/02 - drop v$flashback_database_stat
Rem    abrown      11/11/02 - logmnr downgrade
Rem    jgalanes    11/07/02 - Truncate new table on downgrade
Rem    weili       11/08/02 - drop DBMS_FREQUENT_ITEMSET package
Rem    vmaganty    11/05/02 - OJMS array enqueue/dequeue downgrade
Rem    msheehab    11/04/02 - drop olap longops views and synonyms
Rem    rburns      11/01/02 - drop problem fixed views and packages
Rem    vraja       10/28/02 - drop DBA_TRANSACTION_QUERY
Rem    mvemulap    10/14/02 - truncate ncomp_dll
Rem    sagrawal    10/11/02 - PL/SQL warnings
Rem    elu         10/23/02 - queue negative rule sets
Rem    mtyulene    10/21/02 - tab_stats$, ind_stats$
Rem    wyang       10/23/02 - drop dbms_fbt
Rem    bemeng      10/24/02 - drop package dbms_dbverify
Rem    rramkiss    10/29/02 - truncate oldoids table and drop oldoids sequence
Rem    liwong      10/23/02 - Add status_change_time
Rem    qialiu      10/24/02 - Downgrade OJMS message ADT support
Rem    rramkiss    10/23/02 - remove job scheduler privileges
Rem    nmanappa    10/21/02 - Truncating the padding bytes of audit$ column
Rem    dsemler     10/15/02 - service object
Rem    apadmana    10/18/02 - Add table streams$_message_rules
Rem    nfolkert    10/21/02 - drop mv refresh schedule type with FORCE
Rem    mmorsi      10/11/02 - adding type downgrade for binary float/double 
Rem    tbingol     10/14/02 - drop DBMS_STTS package
Rem    kpatel      10/15/02 - add fixed view for sga info
Rem    apadmana    10/14/02 - Sysaux: Streams
Rem    jstamos     10/09/02 - file transfer
Rem    rburns      10/12/02 - drop views, wrap alter system
Rem    sdizdar     10/10/02 - drop v_$RMAN_STATUS and v_$RMAN_OUTPUT
Rem    dalpern     10/12/02 - support triggering java dumps via kga
Rem    masubram    10/06/02 - delete new online redefinition table
Rem    schakkap    10/10/02 - delete fixed table statistics
Rem    mmorsi      10/16/02 - Drop the collect functions
Rem    nfolkert    10/10/02 - drop index util package
Rem    ilam        10/09/02 - drop dbms_server_trace package
Rem    zqiu        10/09/02 - remove new OLAP Service tables
Rem    yhu         10/08/02 - downgrade for ODCIEnv
Rem    rramkiss    10/08/02 - remove job scheduler schedule objects/views
Rem    molagapp    10/07/02 - Drop v$_recovery_file_dest table
Rem    asundqui    10/07/02 - new Resource Manager parameters
Rem    nfolkert    10/07/02 - drop MV refresh schedule objects
Rem    tchorma     10/02/02 - Alter Operator Add/Drop Binding
Rem    weiwang     10/01/02 - add v$rule
Rem    dcassine    10/01/02 - NULL start and end date in 
Rem                         - streams$ capture & apply processes
Rem    bpwang      09/30/02 - Add downgrade code for 
Rem                         -  dba_streams_transform_function and 
Rem                          - all_streams_transform_function
Rem    elu         09/30/02 - add negative rule sets for Streams
Rem    apadmana    09/27/02 - table streams$_privileged_user
Rem    swerthei    09/06/02 - block change tracking
Rem    asundqui    09/27/02 - drop v$enqueue_statistics and v$lock_type
Rem    apareek     09/23/02 - drop transportable views
Rem    mdilman     09/26/02 - delete DEFAULT_TBS_TYPE from props$
Rem    ywu         09/26/02 - drop utl_lms
Rem    masubram    09/18/02 - downgrade for online redefinition
Rem    twtong      09/26/02 - set alias_txt in snap$ to NULL
Rem    rramkiss    09/24/02 - Drop all job scheduler packages
Rem    btao        09/20/02 - revoke privileges from system for access advisor
Rem    kigoyal     10/01/02 - drop v$session_wait_class, v$system_wait_class
Rem    gmulagun    09/16/02 - remove enhancements to fga_log$ and aud$
Rem    rxgovind    09/15/02 - finer grained dependencies
Rem    kdias       09/13/02 - add advisor priv
Rem    lbarton     09/18/02 - add metapathmap$
Rem    rramkiss    09/05/02 - Deal with job scheduler window group tables/views
Rem    htran       08/21/02 - drop [dba|all]_apply_enqueue
Rem                           [dba|all]_apply_execute views
Rem    bdagevil    09/16/02 - handle v$sql_bind_capture during downgrade
Rem    clei        09/02/02 - remove ANALYZE ANY DICTIONARY privilege
Rem    gssmith     09/13/02 - Add more manageability view/syn removals
Rem    twtong      09/10/02 - setting values in sum$ to be NULL
Rem    yhu         09/17/02 - downgrade for domain index array insert
Rem    kigoyal     09/13/02 - adding session_wait_history
Rem    cluu        09/06/02 - drop dispatcher_config views
Rem    bdagevil    09/19/02 - downgrade optimizer_env views
Rem    tkeefe      09/12/02 - Move proxy_data$ and proxy_role_data$ out of 
Rem                           bootstrap region
Rem    rramkiss    08/27/02 - Add script to drop scheduler feature
Rem    apadmana    08/23/02 - code review comments
Rem    apadmana    08/21/02 - view dba_apply_instantiated_schemas
Rem    liwong      08/21/02 - Drop streams$_extra_attrs
Rem    mxiao       08/09/02 - set new columns in mlog$ to NULL
Rem    wnorcott    08/15/02 - add
Rem    clei        08/12/02 - truncate rls_sc$
Rem    twtong      08/26/02 - drop DBA/USER/ALL_REWRITE_EQUIVALENCE
Rem    mjstewar    09/05/02 - Drop new Flashback Database views
Rem    rburns      08/07/02 - drop sysaux views
Rem    masubram    08/01/02 - drop type MVAggRawBitOr_typ
Rem    kigoyal     08/06/02 - drop v$event_histogram and v$file_histogram
Rem    weiwang     07/31/02 - add rules engin downgrade scripts
Rem    smcgee      07/29/02 - Drop DATAGUARD_CONFIG fixed views
Rem    pbagal      07/26/02 - Merge again
Rem    dcassine    07/26/02 - set precommit_handlerin streams$_apply_process 
rem                         - to NULL
Rem    liwong      07/23/02 - LCR extra attributes
Rem    alakshmi    06/19/02 - Remove calls to drop function for lcr_row_record
Rem    xuhuali     07/23/02 - remove v$javapool 
Rem    pabingha    08/07/02 - CDC change source/set changes
Rem    rburns      07/17/02 - fix typo and move some SQL statements
Rem    cchiappa    07/16/02 - Drop V$AW_{AGGREGATE,ALLOCATE}_OP
Rem    gssmith     08/19/02 - Downgrade Manageability Advisor repository
Rem    rburns      07/03/02 - move sysauth updates
Rem    pbagal      06/26/02 - drop v$asm_operation
Rem    sdizdar     04/17/02 - add drop of V$BACKUP_FILES and V$OBOSLETE...
Rem    rburns      06/14/02 - drop rule aggregate fixed views
Rem    twtong      06/19/02 - set attname in dimattr$ to NULL
Rem    rvissapr    06/20/02 - fga dml and multi column support
Rem    yuli        06/07/02 - add DBMS_KCK_LIB
Rem    vmarwah     05/08/02 - Undrop Tables: Remove the new Views for RecycleBin$.
Rem    dcwang      05/23/02 - downgrade changes to "rule" system privileges.
Rem    alakshmi    05/10/02 - LCR member function signature change
Rem    pbagal      04/22/02 - downgrade scripts for ASM views and synomyms.
Rem    araghava    04/30/02 - downgrade partitioning metadata.
Rem    asundqui    05/03/02 - remove consumer group mapping interface
Rem    rburns      04/17/02 - add commit statements
Rem    gclaborn    04/10/02 - Change catnomet to catnodp
Rem    dcwang      04/10/02 - remove import/export full database when downgrade
Rem    lbarton     03/20/02 - metadata API 10.1 dictionary changes
Rem    rburns      03/17/02 - rburns_10i_updown_scripts
Rem    rburns      02/12/02 - Created
Rem

Rem =========================================================================
Rem BEGIN STAGE 1: downgrade from the current release to 10.1
Rem =========================================================================

@@e1001000

Rem =========================================================================
Rem END STAGE 1: downgrade from the current release to 10.1
Rem =========================================================================

Rem =========================================================================
Rem BEGIN STAGE 2: downgrade dictionary from 10.1 to 9.2.0
Rem =========================================================================

BEGIN
   dbms_registry.downgrading('CATALOG');
   dbms_registry.downgrading('CATPROC');
END;
/

Rem ============================== Start of MV downgrade ===================

Rem =======================================================================
Rem  Fix bug #3320404: Delete the fast refresh operations for LOB MVs 
Rem  as the refresh operations are different in 9.2. This is done in 10g.
Rem =======================================================================

Rem  Set status of LOB MVs to regenerate refresh operations
UPDATE sys.snap$ s SET s.status = 0
 WHERE bitand(s.flag, 512) = 512 AND s.instsite = 0 ;

Rem  Delete 10g fast refresh operations for LOB MVs
DELETE FROM sys.snap_refop$ sr
 WHERE EXISTS 
  ( SELECT 1 from sys.snap$ s 
     WHERE bitand(s.flag, 512) = 512 AND s.instsite = 0
            AND sr.sowner = s.sowner 
            AND sr.vname = s.vname ) ;
COMMIT; 

Rem ============================== End of MV downgrade ===================


Rem=========================================================================
Rem Rename system privileges here
Rem=========================================================================

update SYSTEM_PRIVILEGE_MAP set name = 'CREATE SNAPSHOT'
  where privilege = -172;
update SYSTEM_PRIVILEGE_MAP set name = 'CREATE ANY SNAPSHOT'
  where privilege = -173;
update SYSTEM_PRIVILEGE_MAP set name = 'ALTER ANY SNAPSHOT'
  where privilege = -174;
update SYSTEM_PRIVILEGE_MAP set name = 'DROP ANY SNAPSHOT'
  where privilege = -175;

Rem=========================================================================
Rem Delete new system privileges here 
Rem=========================================================================

insert into SYSTEM_PRIVILEGE_MAP  values (-64, 'CREATE RULE', 1);
insert into SYSTEM_PRIVILEGE_MAP  values (-65, 'CREATE ANY RULE', 1);
insert into SYSTEM_PRIVILEGE_MAP  values (-66, 'ALTER ANY RULE', 1);
insert into SYSTEM_PRIVILEGE_MAP  values (-67, 'DROP ANY RULE', 1);
insert into SYSTEM_PRIVILEGE_MAP  values (-68, 'EXECUTE ANY RULE', 1);

delete from SYSAUTH$ where privilege# in (-255, -256, -262, -263,
                                          -264, -265, -266, -267, -268, -269,
                                          -275);
delete from SYSTEM_PRIVILEGE_MAP where privilege in (-255, -256, -257,
                                                     -258, -259, -260, -261,
                                                     -262, -263,
                                                     -264, -265, -266, -267,
                                                     -268,-269, -275);
Rem delete SQL Tuning Base privileges
delete from SYSAUTH$ where privilege# in (-274, -270, -271);
delete from SYSTEM_PRIVILEGE_MAP where privilege in (-274, -270, -271);

Rem delete SQL Tuning Set privileges
delete from SYSAUTH$ where privilege# in (-272, -273);
delete from SYSTEM_PRIVILEGE_MAP where privilege in (-272, -273);

commit;

update sysauth$ set privilege# = -64 where privilege# = -257;
update sysauth$ set privilege# = -65 where privilege# = -258;
update sysauth$ set privilege# = -66 where privilege# = -259;
update sysauth$ set privilege# = -67 where privilege# = -260;
update sysauth$ set privilege# = -68 where privilege# = -261;

commit;

revoke create table from system;
revoke create snapshot from system;
revoke select any table from system;
revoke global query rewrite from system;

Rem Grant connect needed for instantiate table
grant connect to logstdby_administrator;

Rem=========================================================================
Rem Delete new object privileges here 
Rem=========================================================================

--delete from OBJAUTH$            where privilege# in ();
--delete from TABLE_PRIVILEGE_MAP where privilege in ();

Rem=========================================================================
Rem Delete new audit options here 
Rem=========================================================================

Rem delete SQL Tuning Base options
delete from AUDIT$                where option# in (274, 270, 271);
delete from STMT_AUDIT_OPTION_MAP where option# in (274, 270, 271);

Rem delete SQL Tuning Set options
delete from AUDIT$                where option# in (272, 273);
delete from STMT_AUDIT_OPTION_MAP where option# in (272, 273);

delete from AUDIT$                where option# in (255, 256, 262, 263, 264,
                                                    265, 266, 267, 268,269,
                                                    275);
delete from STMT_AUDIT_OPTION_MAP where option# in (255, 256, 262, 263, 264,
                                                    265, 266, 267, 268, 269,
                                                    275);

commit;

Rem=========================================================================
Rem Rename audit options here
Rem=========================================================================

update STMT_AUDIT_OPTION_MAP set name = 'CREATE SNAPSHOT'
  where option# = 172;
update STMT_AUDIT_OPTION_MAP set name = 'CREATE ANY SNAPSHOT'
  where option# = 173;
update STMT_AUDIT_OPTION_MAP set name = 'ALTER ANY SNAPSHOT'
  where option# = 174;
update STMT_AUDIT_OPTION_MAP set name = 'DROP ANY SNAPSHOT'
  where option# = 175;

update audit_actions set name = 'CREATE SNAPSHOT LOG'
  where action = 71;
update audit_actions set name = 'ALTER SNAPSHOT LOG'
  where action = 72;
update audit_actions set name = 'DROP SNAPSHOT LOG'
  where action = 73;
update audit_actions set name = 'CREATE SNAPSHOT'
  where action = 74;
update audit_actions set name = 'ALTER SNAPSHOT'
  where action = 75;
update audit_actions set name = 'DROP SNAPSHOT'
  where action = 76;

Rem Avoid ORA-04068 for DBMS_SCHEDULER
execute DBMS_SESSION.RESET_PACKAGE; 

Rem=========================================================================
Rem Do the drop of scheduler objects here because once partition metadata 
Rem is dropped, this fails. The rest of the scheduler code is in its old
Rem place
Rem=========================================================================

DECLARE
  CURSOR all_programs IS
    SELECT program_name, owner from DBA_SCHEDULER_PROGRAMS;
  CURSOR all_jobs IS
    SELECT job_name, owner from DBA_SCHEDULER_JOBS;
  CURSOR all_windows IS
    SELECT window_name from DBA_SCHEDULER_WINDOWS;
  CURSOR all_classes IS
    SELECT job_class_name from DBA_SCHEDULER_JOB_CLASSES;
  CURSOR all_window_groups IS
    SELECT window_group_name from DBA_SCHEDULER_WINDOW_GROUPS;
  CURSOR all_schedules IS
    SELECT schedule_name, owner from DBA_SCHEDULER_SCHEDULES;
BEGIN
  FOR program in all_programs LOOP
    dbms_scheduler.drop_program(program.owner || '.' || program.program_name,
      TRUE);
  END LOOP;

  FOR job in all_jobs LOOP
    dbms_scheduler.drop_job(job.owner || '.' || job.job_name, TRUE);
  END LOOP;

  FOR class in all_classes LOOP
    dbms_scheduler.drop_job_class(class.job_class_name, TRUE);
  END LOOP;

  FOR window in all_windows LOOP
    dbms_scheduler.drop_window(window.window_name, TRUE);
  END LOOP;

  FOR window_group in all_window_groups LOOP
    dbms_scheduler.drop_window_group(window_group.window_group_name, TRUE);
  END LOOP;

  FOR schedule in all_schedules LOOP
    dbms_scheduler.drop_schedule(schedule.owner || '.' ||
      schedule.schedule_name, TRUE);
  END LOOP;
END;
/

-- Drop rules and rulesets on the Scheduler job queue
-- we need to remove the rules/rulesets manually after calling
-- dbms_streams_adm.remove_rule
DECLARE
  type varchartab is table of varchar2(70);
  rules varchartab;
  rulesets varchartab;
  i pls_integer;
BEGIN
  select rule_owner ||'.'|| rule_name name bulk collect into rules
    from dba_streams_message_rules where streams_name
    in ('SCHEDULER_COORDINATOR','SCHEDULER_PICKUP') ;

  select rule_set_owner ||'.'|| rule_set_name name bulk collect into rulesets
    from dba_streams_message_consumers where queue_name = 'SCHEDULER$_JOBQ' ;

  sys.dbms_streams_adm.remove_rule(null, 'DEQUEUE', 'SCHEDULER_COORDINATOR',
    true, true);
  sys.dbms_streams_adm.remove_rule(null, 'DEQUEUE', 'SCHEDULER_PICKUP',
    true, true);

  FOR i IN rules.FIRST..rules.LAST LOOP
    BEGIN
      dbms_rule_adm.drop_rule(rules(i),TRUE);
    EXCEPTION
    WHEN others THEN
      IF sqlcode = -24147 THEN NULL;
      ELSE raise;
      END IF;
    END;
  END LOOP;

  FOR i IN rulesets.FIRST..rulesets.LAST LOOP
    BEGIN
      dbms_rule_adm.drop_rule_set(rulesets(i),TRUE);
    EXCEPTION
    WHEN others THEN
      IF sqlcode = -24141 THEN NULL;
      ELSE raise;
      END IF;
    END;
  END LOOP;
END;
/

Rem Remove Job scheduler queue and queue table AQ downgrade
BEGIN
dbms_aqadm.stop_queue('SYS.SCHEDULER$_JOBQ');
dbms_aqadm.drop_queue('SYS.SCHEDULER$_JOBQ');
dbms_aqadm.drop_queue_table('SYS.SCHEDULER$_JOBQTAB');
commit;
END;
/

Rem Remove ALERT_QUE and AQ agent before AQ downgrade
BEGIN
dbms_aqadm.stop_queue('SYS.ALERT_QUE');
dbms_aqadm.drop_queue('SYS.ALERT_QUE');
dbms_aqadm.drop_queue_table('SYS.ALERT_QT');
commit;
END;
/

Rem Remove AQ agent server_alert
DECLARE
  agent SYS.AQ$_AGENT;
BEGIN
  agent := SYS.AQ$_AGENT('server_alert', NULL, NULL);
  dbms_aqadm.drop_aq_agent('server_alert');
END;
/

Rem=========================================================================
Rem BEGIN Removing emnotify queue
Rem=========================================================================
 
execute dbms_aqadm.stop_queue(queue_name => 'sys.srvqueue');
execute dbms_aqadm.drop_queue(queue_name => 'sys.srvqueue');
 
Rem=========================================================================
Rem END Removing emnotify queue
Rem=========================================================================

Rem=========================================================================
Rem BEGIN Removing director objects
Rem=========================================================================

delete sys.props$ p where p.name like 'DIRECTOR%';



--/////////////////////////////////////////////////////////////////////////////
--                                Drop dblinks
--/////////////////////////////////////////////////////////////////////////////

begin
  EXECUTE IMMEDIATE 'DROP DATABASE LINK cdir$dbl';
exception
   when others then
      if sqlcode = -2024 then null;
      else raise;
      end if;
end;
/


drop view dba_tablespace_usage_metrics;
drop public synonym dba_tablespace_usage_metrics;
drop view database_services;
drop public synonym dba_dir_database_attributes;
drop view dba_dir_database_attributes;
drop public synonym dba_dir_victim_policy;
drop view dba_dir_victim_policy;
drop public synonym dba_db_dir_session_actions;
drop public synonym dba_db_dir_service_actions;
drop public synonym dba_db_dir_quiesce_actions;
drop public synonym dba_db_dir_escalate_actions;
drop public synonym dba_cl_dir_instance_actions;
drop view dba_db_dir_session_actions;
drop view dba_db_dir_service_actions;
drop view dba_db_dir_quiesce_actions;
drop view dba_db_dir_escalate_actions;
drop view dba_cl_dir_instance_actions;
drop package dbms_prvt_trace;

--/////////////////////////////////////////////////////////////////////////////
--                              Stop and Drop Propagation
--/////////////////////////////////////////////////////////////////////////////

declare
  no_propagation exception;
  pragma exception_init(no_propagation, -23601);
begin
  dbms_propagation_adm.drop_propagation('sys$dir$alert_prop');
exception when
  no_propagation then null;
end;
/

declare
  no_propagation exception;
  pragma exception_init(no_propagation, -23601);
begin
  dbms_propagation_adm.drop_propagation('sys$dir$cluster_dir');
exception when
  no_propagation then null;
end;
/

--/////////////////////////////////////////////////////////////////////////////
--                              Stop and Drop Queues
--/////////////////////////////////////////////////////////////////////////////

declare
  no_queue exception;
  pragma exception_init(no_queue, -23605);
begin
  dbms_streams_adm.remove_queue('sys.dir$event_queue');
exception when
  no_queue then null;
end;
/

declare
  no_queue exception;
  pragma exception_init(no_queue, -23605);
begin
  dbms_streams_adm.remove_queue('sys.dir$cluster_dir_queue');
exception when
  no_queue then null;
end;
/


--/////////////////////////////////////////////////////////////////////////////
--                                Drop Types
--/////////////////////////////////////////////////////////////////////////////

drop type sys.dir$start_cmd force;
drop type sys.dir$stop_cmd force;
drop type sys.dir$check_cmd force;
drop type sys.dir$alert force;
drop type sys.dir$escalation_result force;
drop type sys.dir$migrate_job_result force;
drop type sys.dir$service_job_result force;
drop type sys.dir$resonate_job_result force;
drop type sys.dir$quiesce_job_result force;

--/////////////////////////////////////////////////////////////////////////////
--                                Drop Sequences
--/////////////////////////////////////////////////////////////////////////////

drop sequence sys.dir$escalation_id;

--/////////////////////////////////////////////////////////////////////////////
--                                Drop Packages
--/////////////////////////////////////////////////////////////////////////////


--/////////////////////////////////////////////////////////////////////////////
--                                Truncate Tables
--/////////////////////////////////////////////////////////////////////////////

truncate table sys.dir$migrate_operations;
truncate table sys.dir$service_operations;
truncate table sys.dir$escalate_operations;
truncate table sys.dir$quiesce_operations;
truncate table sys.dir$instance_actions;
truncate table sys.dir$resonate_operations;
truncate table sys.dir$database_attributes;
truncate table sys.dir$victim_policy;
truncate table sys.dir$node_attributes;
truncate table sys.dir$service_attributes;

Rem=========================================================================
Rem END Removing director objects
Rem=========================================================================

Rem=========================================================================
Rem Downgrade AQ system objects here
Rem=========================================================================

DELETE FROM sys.reg$
WHERE context_type = 1 OR user_context IS NULL OR context_size IS NULL;

ALTER TABLE sys.reg$
MODIFY (user_context raw(128) NOT NULL, context_size number NOT NULL);

DECLARE
  QTAB_DOES_NOT_EXIST exception;
  pragma              EXCEPTION_INIT(QTAB_DOES_NOT_EXIST, -24002);
BEGIN
  dbms_aqadm_sys.drop_queue_table(queue_table => 'SYS.AQ_SRVNTFN_TABLE',
                                  force=> TRUE);
EXCEPTION
  WHEN QTAB_DOES_NOT_EXIST THEN
    NULL;
  WHEN OTHERS THEN
    RAISE;
END;
/

UPDATE system.aq$_queues
  SET service_name = NULL, 
      network_name = NULL;

UPDATE sys.aq$_message_types 
  SET network_name = NULL;

Rem=========================================================================
Rem Downgrade AQ user objects here
Rem=========================================================================
  
Rem ===== drop other tables as dependent on queue table
declare
  cursor qt_cur is select schema, name, flags 
   from system.aq$_queue_tables where schema != 'SYS';
  stmt_buf VARCHAR2(128);
begin
  for qt in qt_cur loop
    if (sys.dbms_aqadm_sys.mcq_8_1(qt.flags)) then
      begin
        -- Don't Export subscriber table with queue table
        dbms_aqadm_sys.drop_qtab_expdep(qt.schema, qt.name,
                                       'AQ$_'||qt.name||'_S');
        -- Don't Export dequeue iot with queue table
        dbms_aqadm_sys.drop_qtab_expdep(qt.schema, qt.name,
                                       'AQ$_'||qt.name||'_I');
        -- Don't Export history iot with queue table
        dbms_aqadm_sys.drop_qtab_expdep(qt.schema, qt.name,
                                       'AQ$_'||qt.name||'_H');
        -- Don't Export timemanager iot with queue table
        dbms_aqadm_sys.drop_qtab_expdep(qt.schema, qt.name,
                                       'AQ$_'||qt.name||'_T');
        -- Don't Export signature iot with queue table
        dbms_aqadm_sys.drop_qtab_expdep(qt.schema, qt.name,
                                       'AQ$_'||qt.name||'_G');
      exception
        when others then
          null;
      end;
    end if;
  end loop;
end;
/
  
Rem Delete all spilled iots

DECLARE
  qt_schema    VARCHAR2(30);
  qt_name      VARCHAR2(30);
  CURSOR find_qt_c IS select schema, name, flags from system.aq$_queue_tables;
BEGIN

  FOR q_rec IN find_qt_c LOOP         -- iterate all queue tables
    BEGIN
      qt_schema := q_rec.schema;                     -- get queue table schema
      qt_name   := q_rec.name;                         -- get queue table name

      -- Drop spilled table
      sys.dbms_aqadm_sys.drop_spilled_iot(qt_schema, qt_name);

    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  END LOOP;
END;
/

Rem  change columns enq_time, deq_time etc. back to date.
DECLARE
  CURSOR find_qt_c IS SELECT schema, name, flags, sort_cols
                        FROM system.aq$_queue_tables;
  sort_by_eqt      BOOLEAN;
BEGIN
  FOR q_rec IN find_qt_c LOOP         -- iterate all queue tables
    -- patch up time columns
    IF q_rec.sort_cols = 2 OR q_rec.sort_cols = 3 OR q_rec.sort_cols = 7 THEN
      sort_by_eqt := TRUE;
    ELSE
      sort_by_eqt := FALSE;
    END IF;

    dbms_aqadm_sys.patch_queue_table(q_rec.schema, q_rec.name, q_rec.flags, 
                                     sort_by_eqt, FALSE);
  END LOOP;
END;
/

Rem
Rem  Delete buffered queue views
Rem
declare
  cursor qt_cur is select schema, name, flags from system.aq$_queue_tables;

  procedure create_92_base_view(qt_schema   IN VARCHAR2, 
                                qt_name      IN VARCHAR2,
                                qt_flags     IN NUMBER) IS
    viewname       VARCHAR2(64);     -- name of the view created on queue table
    selectcols     VARCHAR2(3072); -- select columns in queue table and history
    fromlist       VARCHAR2(192);                                -- from clause
    newq_8_1_cols  VARCHAR2(256);

    BEGIN

    viewname := qt_schema || '.' || 'AQ$' || qt_name;

    IF (sys.dbms_aqadm_sys.mcq_8_1(qt_flags)) THEN
      selectcols := ' q_name QUEUE, qt.msgid MSG_ID, corrid CORR_ID, '       ||
                    ' priority MSG_PRIORITY, '                               ||
                    ' decode(h.dequeue_time, NULL,    
                                (decode(state, 0,   ''READY'',         
                                               1,   ''WAIT'',          
                                               2,   ''PROCESSED'',             
                                               3,   ''EXPIRED'',
                                               8,   ''DEFERRED'')),      
                                (decode(h.transaction_id,     
                                        NULL, ''UNDELIVERABLE'',    
                                        ''PROCESSED''))) MSG_STATE, '        ||
                   ' delay, expiration, enq_time, enq_uid ENQ_USER_ID, '     ||
                   ' enq_tid ENQ_TXN_ID, '                                   ||
                   ' decode(h.transaction_id, NULL, TO_DATE(NULL),    
                            h.dequeue_time) DEQ_TIME, '                      ||
                   ' h.dequeue_user DEQ_USER_ID, '                           ||
                   ' h.transaction_id DEQ_TXN_ID, '                          ||
                   ' h.retry_count retry_count, '                            ||
                   ' decode (state, 0, exception_qschema, 
                                    1, exception_qschema, 
                                    2, exception_qschema,  
                                    NULL) EXCEPTION_QUEUE_OWNER, '           ||
                   ' decode (state, 0, exception_queue, 
                                    1, exception_queue, 
                                    2, exception_queue,  
                                    NULL) EXCEPTION_QUEUE, '                 ||
                   ' user_data, '                                            ||
                   ' h.propagated_msgid PROPAGATED_MSGID, '                  ||
                   ' sender_name  SENDER_NAME,'                              ||
                   ' sender_address  SENDER_ADDRESS,'                        ||
                   ' sender_protocol  SENDER_PROTOCOL,'                      ||
                   ' dequeue_msgid ORIGINAL_MSGID, '                         ||
                   ' decode (h.dequeue_time, NULL, 
                     decode (state, 3, exception_queue, NULL),
                     decode (h.transaction_id, NULL, NULL, exception_queue)) 
                                  ORIGINAL_QUEUE_NAME, '                     ||
                   ' decode (h.dequeue_time, NULL, 
                     decode (state, 3, exception_qschema, NULL),
                     decode (h.transaction_id, NULL, NULL, exception_qschema)) 
                                  ORIGINAL_QUEUE_OWNER, '                    ||
                   ' decode(h.dequeue_time, NULL, 
                       decode(state, 3, 
                       decode(h.transaction_id, NULL, ''TIME_EXPIRATION'',
                              ''INVALID_TRANSACTION'', NULL,
                              ''MAX_RETRY_EXCEEDED''), NULL),
                       decode(h.transaction_id, NULL, ''PROPAGATION_FAILURE'',
                              NULL)) EXPIRATION_REASON, ';

      fromlist :=  qt_schema || '.' || qt_name || ' qt, '                    ||
                   qt_schema || '.' || 'AQ$_' || qt_name || '_H h, '         ||
                   qt_schema || '.' || 'AQ$_' || qt_name || '_S s ';

      execute immediate ' CREATE OR REPLACE VIEW '                           ||
                   viewname                                                  ||
                   ' AS SELECT '                                             ||
                     selectcols                                              ||
                   ' decode(h.subscriber#, 0, decode(h.name, ''0'', NULL,
                                                                    h.name),
                                              s.name) CONSUMER_NAME, '       ||
                   ' s.address ADDRESS, '                                    ||
                   ' s.protocol PROTOCOL '                                   ||
                   ' FROM '                                                  ||
                   fromlist                                                  ||
                   ' WHERE qt.msgid = h.msgid AND '                          ||
                   ' ((h.subscriber# != 0 AND h.subscriber#=s.subscriber_id)'||
                   '  OR (h.subscriber# = 0 AND h.address#=s.subscriber_id))'||
                   ' AND qt.state != ' || DBMS_AQ.SPILLED                    ||
                   ' WITH READ ONLY';
  ELSE
    IF sys.dbms_aqadm_sys.scq_8_1(qt_flags) THEN
      newq_8_1_cols := ', ' ||  'sender_name SENDER_NAME, '     ||
                                'sender_address SENDER_ADDRESS, '  ||
                                'sender_protocol SENDER_PROTOCOL, '||
                                'dequeue_msgid ORIGINAL_MSGID ';    
    ELSE
      newq_8_1_cols :=  NULL ;
    END IF;

    execute immediate 'CREATE OR REPLACE VIEW '                          ||
                 viewname                                                ||
                 ' AS SELECT '                                           ||
                 'q_name QUEUE, msgid MSG_ID, corrid CORR_ID, '          ||
                 'priority MSG_PRIORITY, '                               ||
                 'decode(state, 0,   ''READY'',
                                1,   ''WAIT'',
                                2,   ''PROCESSED'',
                                3,   ''EXPIRED'') MSG_STATE, '           ||
                 'delay, expiration, enq_time, enq_uid ENQ_USER_ID, '    || 
                 'enq_tid ENQ_TXN_ID, '                                  || 
                 'deq_time, deq_uid DEQ_USER_ID, '                       || 
                 'deq_tid DEQ_TXN_ID, '                                  ||
                 'retry_count, '                                         ||
                  ' decode (state, 0, exception_qschema, 
                                  1, exception_qschema, 
                                  2, exception_qschema,  
                                  NULL) EXCEPTION_QUEUE_OWNER, '         ||
                   ' decode (state, 0, exception_queue, 
                                  1, exception_queue, 
                                  2, exception_queue,  
                                  NULL) EXCEPTION_QUEUE, '                  ||
                 ' user_data, '                                             ||
                   ' decode (state, 3, 
                     decode (deq_tid, ''INVALID_TRANSACTION'', NULL, 
                             exception_queue), NULL)
                                ORIGINAL_QUEUE_NAME, '                   ||
                   ' decode (state, 3, 
                     decode (deq_tid, ''INVALID_TRANSACTION'', NULL, 
                             exception_qschema), NULL)
                                ORIGINAL_QUEUE_OWNER, '                  ||
                 ' decode(state, 3, 
                     decode(deq_time, NULL, 
                       decode(deq_tid, NULL, ''TIME_EXPIRATION'',
                              ''INVALID_TRANSACTION'', NULL,
                              ''MAX_RETRY_EXCEEDED''), NULL), NULL) 
                             EXPIRATION_REASON '                         ||
                 newq_8_1_cols                                           ||
                 ' FROM ' ||qt_schema || '.' ||qt_name                   ||
                 ' WHERE state != ' || DBMS_AQ.SPILLED                   ||
                 ' AND   state != ' || DBMS_AQ.DEFRSPIL                  ||
                 ' WITH READ ONLY';
  END IF;
  end create_92_base_view;

begin
  for qt in qt_cur loop
    begin
      create_92_base_view(qt.schema, qt.name, qt.flags);
      if (sys.dbms_aqadm_sys.mcq_8_1(qt.flags)) then
        sys.dbms_aqadm_sys.drop_buffer_view(qt.schema, qt.name);
      end if;
    exception
      when others then
        null;
    end;
  end loop;
end;
/

-- Rename signature IOT
declare
  cursor qt_cur is select schema, name, flags from system.aq$_queue_tables;
  stmt_buf  VARCHAR2(200);

  PROCEDURE create_signature_iot_92(qt_schema              IN  VARCHAR2,
                               qt_name          IN  VARCHAR2) IS
  signiot_name    VARCHAR2(30);
  tspace_name     VARCHAR2(30);
  initrans        NUMBER;
  qt_pctfree      NUMBER;
  qt_frlists      NUMBER;
  storage_clause  VARCHAR2(30);
  space_mgmt      VARCHAR2(10);
  BEGIN

    -- The history IOTs are named AQ$_<queue_table_name>_H
    signiot_name := 'AQ$_' || qt_name  || '_NR';

    -- determine the tablespace and initrans for the IOT.
    SELECT tablespace_name, ini_trans, pct_free, freelists
     INTO tspace_name, initrans, qt_pctfree, qt_frlists
    FROM   sys.dba_tables
    WHERE  owner = qt_schema AND table_name = qt_name;

    -- determine the space management for the tablespace
    SELECT segment_space_management
    INTO space_mgmt
    FROM   sys.dba_tablespaces
    WHERE  tablespace_name = tspace_name;

    IF (space_mgmt = 'MANUAL') THEN
      storage_clause :=' STORAGE (FREELISTS ' || qt_frlists || ' ) ';
    END IF;

    -- create atleast one itl for indices
    IF initrans = 1 THEN
       initrans := 2;
    END IF;

    -- create the signature table
    execute immediate 'CREATE TABLE ' || qt_schema || '.' || signiot_name
                                 || '(msgid             RAW(16),'
                                 || ' subscriber#       NUMBER,'
                                 || ' name              VARCHAR2(30),'
                                 || ' address#          NUMBER,'
                                 || ' sign              sys.aq$_sig_prop,'
                                 || ' dbs_sign          sys.aq$_sig_prop,'
                                 || ' PRIMARY KEY (msgid, subscriber#, '
                                 || '              name, address#))'
                                 || ' USAGE QUEUE ORGANIZATION INDEX '
                                 || ' INITRANS ' || initrans
                                 || ' TABLESPACE ' || tspace_name
                                 || ' PCTFREE ' || qt_pctfree
                                 || storage_clause
                                 || ' INCLUDING sign OVERFLOW TABLESPACE '
                                 || tspace_name;

    -- insert a post table action function for the IOT.
    BEGIN
      sys.dbms_aq_sys_exp_internal.register_procedural_action
            (signiot_name, qt_schema, 'DBMS_AQ_EXP_SIGNATURE_TABLES', 'SYS');
    EXCEPTION            -- ignore error if the entry is already in expdepact$
      WHEN OTHERS THEN
        NULL;
    END;

  END  create_signature_iot_92;

begin
  for qt in qt_cur loop
    if (sys.dbms_aqadm_sys.mcq_8_1(qt.flags)) then
      begin
        sys.dbms_prvtaqim.drop_signature_iot(qt.schema,qt.name,TRUE);
        create_signature_iot_92(qt.schema,qt.name);
      exception
        when others then
          null;
      end;
    end if;
  end loop;
end;
/

Rem drop the dba_queue_schedules and user_queue_schedules views
Rem These will be recreated by catqueue again

drop public synonym dba_queue_schedules;
drop view dba_queue_schedules;

drop public synonym user_queue_schedules;
drop view user_queue_schedules;

Rem=========================================================================
Rem Drop new fixed views here
Rem=========================================================================

Rem Drop DBMS_MONITOR fixed views
drop public synonym v$client_stats;
drop view v_$client_stats;
drop public synonym gv$client_stats;
drop view gv_$client_stats;
drop public synonym v$serv_mod_act_stats;
drop view v_$serv_mod_act_stats;
drop public synonym gv$serv_mod_act_stats;
drop view gv_$serv_mod_act_stats;
drop public synonym v$sys_time_model;
drop view v_$sys_time_model;
drop public synonym gv$sys_time_model;
drop view gv_$sys_time_model;

DROP VIEW v_$instance_log_group;
DROP PUBLIC SYNONYM v$instance_log_group;
DROP VIEW gv_$instance_log_group;
DROP PUBLIC SYNONYM gv$instance_log_group;

DROP VIEW v_$osstat;
DROP PUBLIC SYNONYM v$osstat;
DROP VIEW gv_$osstat;
DROP PUBLIC SYNONYM gv$osstat;

Rem -- Drop the Metric Views
DROP VIEW gv_$sysmetric;
DROP PUBLIC synonym gv$sysmetric;
DROP VIEW v_$sysmetric;
DROP PUBLIC synonym v$sysmetric;

DROP VIEW gv_$metric_history;
DROP PUBLIC synonym gv$metric_history;
DROP VIEW v_$metric_history;
DROP PUBLIC synonym v$metric_history;

DROP VIEW gv_$metric;
DROP PUBLIC synonym gv$metric;
DROP VIEW v_$metric;
DROP PUBLIC synonym v$metric;

DROP VIEW gv_$sysmetric_history;
DROP PUBLIC synonym gv$sysmetric_history;
DROP VIEW v_$sysmetric_history;
DROP PUBLIC synonym v$sysmetric_history;

DROP VIEW gv_$metricname;
DROP PUBLIC synonym gv$metricname;
DROP VIEW v_$metricname;
DROP PUBLIC synonym v$metricname;

DROP VIEW gv_$metricgroup;
DROP PUBLIC synonym gv$metricgroup;
DROP VIEW v_$metricgroup;
DROP PUBLIC synonym v$metricgroup;

drop view V_$SYSMETRIC_SUMMARY;
drop public synonym V$SYSMETRIC_SUMMARY;
drop view GV_$SYSMETRIC_SUMMARY;
drop public synonym GV$SYSMETRIC_SUMMARY;

drop view GV_$SESSMETRIC;
drop public synonym GV$SESSMETRIC;
drop view V_$SESSMETRIC;
drop public synonym V$SESSMETRIC;

drop view GV_$FILEMETRIC;
drop public synonym GV$FILEMETRIC;
drop view V_$FILEMETRIC;
drop public synonym V$FILEMETRIC;

drop view GV_$FILEMETRIC_HISTORY;
drop public synonym GV$FILEMETRIC_HISTORY;
drop view V_$FILEMETRIC_HISTORY;
drop public synonym V$FILEMETRIC_HISTORY;

drop view GV_$EVENTMETRIC;
drop public synonym GV$EVENTMETRIC;
drop view V_$EVENTMETRIC;
drop public synonym V$EVENTMETRIC;

drop view GV_$WAITCLASSMETRIC;
drop public synonym GV$WAITCLASSMETRIC;
drop view V_$WAITCLASSMETRIC;
drop public synonym V$WAITCLASSMETRIC;

drop view GV_$WAITCLASSMETRIC_HISTORY;
drop public synonym GV$WAITCLASSMETRIC_HISTORY;
drop view V_$WAITCLASSMETRIC_HISTORY;
drop public synonym V$WAITCLASSMETRIC_HISTORY;

drop view GV_$SERVICEMETRIC_HISTORY;
drop public synonym GV$SERVICEMETRIC_HISTORY;
drop view V_$SERVICEMETRIC_HISTORY; 
drop public synonym V$SERVICEMETRIC_HISTORY;

drop view GV_$WAITCLASSMETRIC_HISTORY;
drop public synonym GV$WAITCLASSMETRIC_HISTORY;
drop view V_$WAITCLASSMETRIC_HISTORY;
drop public synonym V$WAITCLASSMETRIC_HISTORY;

drop view GV_$SERVICEMETRIC;
drop public synonym GV$SERVICEMETRIC;
drop view V_$SERVICEMETRIC;
drop public synonym V$SERVICEMETRIC;

-- Drop alert related V$ views
drop view V_$ALERT_TYPES;
drop public synonym V$ALERT_TYPES;
drop view GV_$ALERT_TYPES;
drop public synonym GV$ALERT_TYPES;

-- Drop threshold related V$ views
drop view V_$THRESHOLD_TYPES;
drop public synonym V$THRESHOLD_TYPES;
drop view GV_$THRESHOLD_TYPES;
drop public synonym GV$THRESHOLD_TYPES;

Rem Drop v$service_stats and v$sess_time_mode
drop public synonym v$service_stats;
drop view v_$service_stats;
drop public synonym gv$service_stats;
drop view gv_$service_stats;
drop public synonym v$sess_time_model;
drop view v_$sess_time_model;
drop public synonym gv$sess_time_model;
drop view gv_$sess_time_model;

-- Drop file space usage views
drop public synonym v$filespace_usage;
drop view v_$filespace_usage;
drop public synonym gv$filespace_usage;
drop view gv_$filespace_usage;

-- Drop timezone_file views
drop public synonym v$timezone_file;
drop view v_$timezone_file;
drop public synonym gv$timezone_file;
drop view gv_$timezone_file;
 
Rem
Rem DROP sga info views
Rem

drop public synonym V$JAVA_LIBRARY_CACHE_MEMORY;
drop view V_$JAVA_LIBRARY_CACHE_MEMORY;
drop public synonym GV$JAVA_LIBRARY_CACHE_MEMORY;
drop view GV_$JAVA_LIBRARY_CACHE_MEMORY;

drop public synonym V$JAVA_POOL_ADVICE;
drop view V_$JAVA_POOL_ADVICE;
drop public synonym GV$JAVA_POOL_ADVICE;
drop view GV_$JAVA_POOL_ADVICE;

drop public synonym V$SGAINFO;
drop view V_$SGAINFO;
drop public synonym GV$SGAINFO;
drop view GV_$SGAINFO;


DROP VIEW v_$session_wait_class;
DROP PUBLIC SYNONYM v$session_wait_class;
DROP VIEW gv_$session_wait_class;
DROP PUBLIC SYNONYM gv$session_wait_class;

DROP VIEW v_$system_wait_class;
DROP PUBLIC SYNONYM v$system_wait_class;
DROP VIEW gv_$system_wait_class;
DROP PUBLIC SYNONYM gv$system_wait_class;

DROP VIEW v_$event_histogram;
DROP PUBLIC SYNONYM v$event_histogram;
DROP VIEW gv_$event_histogram;
DROP PUBLIC SYNONYM gv$event_histogram;

DROP VIEW v_$file_histogram;
DROP PUBLIC SYNONYM v$file_histogram;
DROP VIEW gv_$file_histogram;
DROP PUBLIC SYNONYM gv$file_histogram;

DROP VIEW v_$temp_histogram;
DROP PUBLIC SYNONYM v$temp_histogram;
DROP VIEW gv_$temp_histogram;
DROP PUBLIC SYNONYM gv$temp_histogram;

DROP VIEW v_$enqueue_statistics;
DROP PUBLIC SYNONYM v$enqueue_statistics;
DROP VIEW gv_$enqueue_statistics;
DROP PUBLIC SYNONYM gv$enqueue_statistics;

DROP VIEW v_$lock_type;
DROP PUBLIC SYNONYM v$lock_type;
DROP VIEW gv_$lock_type;
DROP PUBLIC SYNONYM gv$lock_type;

DROP VIEW v_$session_wait_history;
DROP PUBLIC SYNONYM v$session_wait_history;
DROP VIEW gv_$session_wait_history;
DROP PUBLIC SYNONYM gv$session_wait_history;

DROP VIEW v_$service_event;
DROP PUBLIC SYNONYM v$service_event;
DROP VIEW gv_$service_event;
DROP PUBLIC SYNONYM gv$service_event;

DROP VIEW v_$service_wait_class;
DROP PUBLIC SYNONYM v$service_wait_class;
DROP VIEW gv_$service_wait_class;
DROP PUBLIC SYNONYM gv$service_wait_class;

DROP VIEW v_$active_services;
DROP PUBLIC SYNONYM v$active_services;
DROP VIEW gv_$active_services;
DROP PUBLIC SYNONYM gv$active_services;
DROP VIEW v_$services;
DROP PUBLIC SYNONYM v$services;
DROP VIEW gv_$services;
DROP PUBLIC SYNONYM gv$services;

Rem
Rem DROP RAC views
Rem

DROP VIEW v_$current_block_server;
DROP PUBLIC synonym v$current_block_server;
DROP VIEW gv_$current_block_server;
DROP PUBLIC synonym gv$current_block_server;

DROP VIEW v_$instance_cache_transfer;
DROP PUBLIC synonym v$instance_cache_transfer;
DROP VIEW gv_$instance_cache_transfer;
DROP PUBLIC synonym gv$instance_cache_transfer;

Rem
Rem DROP Views to list backups
Rem

DROP VIEW v_$backup_files;
DROP PUBLIC SYNONYM v$backup_files;
  
Rem
Rem DROP asm specific views.
Rem
  
DROP VIEW gv_$asm_template;
DROP PUBLIC synonym gv$asm_template;
DROP VIEW v_$asm_template;
DROP PUBLIC synonym v$asm_template;

DROP VIEW gv_$asm_file;
DROP PUBLIC synonym gv$asm_file;
DROP VIEW v_$asm_file;
DROP PUBLIC synonym v$asm_file;

DROP VIEW gv_$asm_diskgroup;
DROP PUBLIC synonym gv$asm_diskgroup;
DROP VIEW v_$asm_diskgroup;
DROP PUBLIC synonym v$asm_diskgroup;

DROP VIEW gv_$asm_disk;
DROP PUBLIC synonym gv$asm_disk;
DROP VIEW v_$asm_disk;
DROP PUBLIC synonym v$asm_disk;

DROP VIEW gv_$asm_client;
DROP PUBLIC synonym gv$asm_client;
DROP VIEW v_$asm_client;
DROP PUBLIC synonym v$asm_client;

DROP VIEW gv_$asm_alias;
DROP PUBLIC synonym gv$asm_alias;
DROP VIEW v_$asm_alias;
DROP PUBLIC synonym v$asm_alias;

DROP VIEW gv_$asm_operation;
DROP PUBLIC synonym gv$asm_operation;
DROP VIEW v_$asm_operation;
DROP PUBLIC synonym v$asm_operation;

DROP VIEW gv_$rule_set;
DROP PUBLIC synonym gv$rule_set;
DROP VIEW v_$rule_set;
DROP PUBLIC synonym v$rule_set;

DROP VIEW gv_$rule;
DROP PUBLIC synonym gv$rule;
DROP VIEW v_$rule;
DROP PUBLIC synonym v$rule;

DROP VIEW gv_$rule_set_aggregate_stats;
DROP PUBLIC synonym gv$rule_set_aggregate_stats;
DROP VIEW v_$rule_set_aggregate_stats;
DROP PUBLIC synonym v$rule_set_aggregate_stats;

DROP VIEW gv_$javapool;
DROP PUBLIC synonym gv$javapool;
DROP VIEW v_$javapool;
DROP PUBLIC synonym v$javapool;

DROP VIEW gv_$dataguard_config;
DROP PUBLIC synonym gv$dataguard_config;
DROP VIEW v_$dataguard_config;
DROP PUBLIC synonym v$dataguard_config;

DROP VIEW gv_$sysaux_occupants;
DROP PUBLIC synonym gv$sysaux_occupants;
DROP VIEW v_$sysaux_occupants;
DROP PUBLIC synonym v$sysaux_occupants;

DROP VIEW gv_$aw_aggregate_op;
DROP PUBLIC synonym gv$aw_aggregate_op;
DROP VIEW v_$aw_aggregate_op;
DROP PUBLIC synonym v$aw_aggregate_op;

DROP VIEW gv_$aw_allocate_op;
DROP PUBLIC synonym gv$aw_allocate_op;
DROP VIEW v_$aw_allocate_op;
DROP PUBLIC synonym v$aw_allocate_op;

drop public synonym V$AW_LONGOPS;
drop view V_$AW_LONGOPS;
drop public synonym GV$AW_LONGOPS;
drop view GV_$AW_LONGOPS;

Rem
Rem DROP RMAN status and output views
Rem

DROP VIEW v_$rman_status;
DROP PUBLIC synonym v$rman_status;
DROP VIEW v_$rman_output;
DROP PUBLIC synonym v$rman_output;
DROP VIEW gv_$rman_output;
DROP PUBLIC synonym gv$rman_output;

DROP VIEW gv_$transportable_tablespace;
DROP PUBLIC synonym gv$transportable_tablespace;
DROP VIEW v_$transportable_tablespace;
DROP PUBLIC synonym v$transportable_tablespace;

DROP VIEW v_$block_change_tracking;
DROP PUBLIC synonym v$block_change_tracking;

DROP VIEW gv_$dispatcher_config;
DROP PUBLIC synonym gv$dispatcher_config;
DROP VIEW v_$dispatcher_config;
DROP PUBLIC synonym v$dispatcher_config;

DROP VIEW gv_$transportable_platform;
DROP PUBLIC synonym gv$transportable_platform;
DROP VIEW v_$transportable_platform;
DROP PUBLIC synonym v$transportable_platform;

DROP VIEW gv_$sys_optimizer_env;
DROP PUBLIC synonym gv$sys_optimizer_env;
DROP VIEW v_$sys_optimizer_env;
DROP PUBLIC synonym v$sys_optimizer_env;

DROP VIEW gv_$ses_optimizer_env;
DROP PUBLIC synonym gv$ses_optimizer_env;
DROP VIEW v_$ses_optimizer_env;
DROP PUBLIC synonym v$ses_optimizer_env;

DROP VIEW gv_$sql_optimizer_env;
DROP PUBLIC synonym gv$sql_optimizer_env;
DROP VIEW v_$sql_optimizer_env;
DROP PUBLIC synonym v$sql_optimizer_env;

DROP VIEW gv_$sql_bind_capture;
DROP PUBLIC synonym gv$sql_bind_capture;
DROP VIEW v_$sql_bind_capture;
DROP PUBLIC synonym v$sql_bind_capture;

DROP VIEW gv_$advisor_progress;
DROP PUBLIC synonym gv$advisor_progress;
DROP VIEW v_$advisor_progress;
DROP PUBLIC synonym v$advisor_progress;

DROP VIEW v_$recovery_file_dest;
DROP PUBLIC synonym v$recovery_file_dest;

Rem
Rem DROP flashback database specific views.
Rem
  
DROP VIEW gv_$flashback_database_log;
DROP PUBLIC synonym gv$flashback_database_log;
DROP VIEW v_$flashback_database_log;
DROP PUBLIC synonym v$flashback_database_log;

DROP VIEW gv_$flashback_database_logfile;
DROP PUBLIC synonym gv$flashback_database_logfile;
DROP VIEW v_$flashback_database_logfile;
DROP PUBLIC synonym v$flashback_database_logfile;

DROP VIEW gv_$flashback_database_stat;
DROP PUBLIC synonym gv$flashback_database_stat;
DROP VIEW v_$flashback_database_stat;
DROP PUBLIC synonym v$flashback_database_stat;

DROP VIEW V_$ACTIVE_SESSION_HISTORY;
DROP PUBLIC SYNONYM V$ACTIVE_SESSION_HISTORY;
DROP VIEW GV_$ACTIVE_SESSION_HISTORY;
DROP PUBLIC SYNONYM GV$ACTIVE_SESSION_HISTORY;

Rem Drop DBMS_INDEX_UTL views
DROP VIEW utl_all_ind_comps;
DROP PUBLIC SYNONYM utl_all_ind_comps;
DROP VIEW "_utl$_gnp_ind";
DROP VIEW "_utl$_gp_ind_parts";
DROP VIEW "_utl$_lnc_ind_parts";
DROP VIEW "_utl$_lc_ind_subs";

DROP VIEW v_$osstat;
DROP PUBLIC SYNONYM v$osstat;
DROP VIEW gv_$osstat;
DROP PUBLIC SYNONYM gv$osstat;

DROP VIEW v_$px_buffer_advice;
DROP PUBLIC SYNONYM v$px_buffer_advice;
DROP VIEW gv_$px_buffer_advice;
DROP PUBLIC SYNONYM gv$px_buffer_advice;

Rem 
Rem Drop AQ buffered queue views
Rem 
DROP VIEW gv_$buffered_queues;
DROP PUBLIC SYNONYM gv$buffered_queues;
DROP VIEW gv_$buffered_subscribers;
DROP PUBLIC SYNONYM gv$buffered_subscribers;
DROP VIEW gv_$buffered_publishers;
DROP PUBLIC SYNONYM gv$buffered_publishers;
DROP VIEW gv_$propagation_sender;
DROP PUBLIC SYNONYM gv$propagation_sender;
DROP VIEW gv_$propagation_receiver;
DROP PUBLIC SYNONYM gv$propagation_receiver;

DROP VIEW v_$buffered_queues;
DROP PUBLIC SYNONYM v$buffered_queues;
DROP VIEW v_$buffered_subscribers;
DROP PUBLIC SYNONYM v$buffered_subscribers;
DROP VIEW v_$buffered_publishers;
DROP PUBLIC SYNONYM v$buffered_publishers;

DROP VIEW v_$propagation_sender;
DROP PUBLIC SYNONYM v$propagation_sender;
DROP VIEW v_$propagation_receiver;
DROP PUBLIC SYNONYM v$propagation_receiver;

Rem=========================================================================
Rem Drop new ALL/DBA/USER views here
Rem=========================================================================

Rem Drop DBMS_MONITOR views
drop public synonym DBA_ENABLED_TRACES;
drop view DBA_ENABLED_TRACES;

drop public synonym DBA_ENABLED_AGGREGATIONS;
drop view DBA_ENABLED_AGGREGATIONS;

Rem Drop SQL profile views (SQL Tuning Base)
drop public synonym dba_sql_profiles;
drop view dba_sql_profiles;

Rem
Rem Drop the Workload Repository DBA_HIST views
Rem 
drop public synonym DBA_HIST_DATABASE_INSTANCE;
drop view DBA_HIST_DATABASE_INSTANCE;
drop public synonym DBA_HIST_SNAPSHOT;
drop view DBA_HIST_SNAPSHOT;
drop public synonym DBA_HIST_BASELINE;
drop view DBA_HIST_BASELINE;
drop public synonym DBA_HIST_WR_CONTROL;
drop view DBA_HIST_WR_CONTROL;
drop public synonym DBA_HIST_DATAFILE;
drop view DBA_HIST_DATAFILE;
drop public synonym DBA_HIST_FILESTATXS;
drop view DBA_HIST_FILESTATXS;
drop public synonym DBA_HIST_TEMPFILE;
drop view DBA_HIST_TEMPFILE;
drop public synonym DBA_HIST_TEMPSTATXS;
drop view DBA_HIST_TEMPSTATXS;
drop public synonym DBA_HIST_SQLSTAT;
drop view DBA_HIST_SQLSTAT;
drop public synonym DBA_HIST_SQLTEXT;
drop view DBA_HIST_SQLTEXT;
drop public synonym DBA_HIST_SQL_SUMMARY;
drop view DBA_HIST_SQL_SUMMARY;
drop public synonym DBA_HIST_SQL_PLAN;
drop view DBA_HIST_SQL_PLAN;
drop public synonym DBA_HIST_SQLBIND;
drop view DBA_HIST_SQLBIND;
drop public synonym DBA_HIST_OPTIMIZER_ENV;
drop view DBA_HIST_OPTIMIZER_ENV;
drop public synonym DBA_HIST_EVENT_NAME;
drop view DBA_HIST_EVENT_NAME;
drop public synonym DBA_HIST_SYSTEM_EVENT;
drop view DBA_HIST_SYSTEM_EVENT;
drop public synonym DBA_HIST_BG_EVENT_SUMMARY;
drop view DBA_HIST_BG_EVENT_SUMMARY;
drop public synonym DBA_HIST_WAITSTAT;
drop view DBA_HIST_WAITSTAT;
drop public synonym DBA_HIST_ENQUEUE_STAT;
drop view DBA_HIST_ENQUEUE_STAT;
drop public synonym DBA_HIST_LATCH_NAME;
drop view DBA_HIST_LATCH_NAME;
drop public synonym DBA_HIST_LATCH;
drop view DBA_HIST_LATCH;
drop public synonym DBA_HIST_LATCH_CHILDREN;
drop view DBA_HIST_LATCH_CHILDREN;
drop public synonym DBA_HIST_LATCH_PARENT;
drop view DBA_HIST_LATCH_PARENT;
drop public synonym DBA_HIST_LATCH_MISSES_SUMMARY;
drop view DBA_HIST_LATCH_MISSES_SUMMARY;
drop public synonym DBA_HIST_LIBRARYCACHE;
drop view DBA_HIST_LIBRARYCACHE;
drop public synonym DBA_HIST_DB_CACHE_ADVICE;
drop view DBA_HIST_DB_CACHE_ADVICE;
drop public synonym DBA_HIST_BUFFER_POOL_STAT;
drop view DBA_HIST_BUFFER_POOL_STAT;
drop public synonym DBA_HIST_ROWCACHE_SUMMARY;
drop view DBA_HIST_ROWCACHE_SUMMARY;
drop public synonym DBA_HIST_SGA;
drop view DBA_HIST_SGA;
drop public synonym DBA_HIST_SGASTAT;
drop view DBA_HIST_SGASTAT;
drop public synonym DBA_HIST_PGASTAT;
drop view DBA_HIST_PGASTAT;
drop public synonym DBA_HIST_RESOURCE_LIMIT;
drop view DBA_HIST_RESOURCE_LIMIT;
drop public synonym DBA_HIST_SHARED_POOL_ADVICE;
drop view DBA_HIST_SHARED_POOL_ADVICE;
drop public synonym DBA_HIST_SQL_WORKAREA_HSTGRM;
drop view DBA_HIST_SQL_WORKAREA_HSTGRM;
drop public synonym DBA_HIST_PGA_TARGET_ADVICE;
drop view DBA_HIST_PGA_TARGET_ADVICE;
drop public synonym DBA_HIST_INSTANCE_RECOVERY;
drop view DBA_HIST_INSTANCE_RECOVERY;
drop public synonym DBA_HIST_STAT_NAME;
drop view DBA_HIST_STAT_NAME;
drop public synonym DBA_HIST_SYSSTAT;
drop view DBA_HIST_SYSSTAT;
drop public synonym DBA_HIST_PARAMETER_NAME;
drop view DBA_HIST_PARAMETER_NAME;
drop public synonym DBA_HIST_PARAMETER;
drop view DBA_HIST_PARAMETER;
drop public synonym DBA_HIST_UNDOSTAT;
drop view DBA_HIST_UNDOSTAT;
drop public synonym DBA_HIST_SEG_STAT;
drop view DBA_HIST_SEG_STAT;
drop public synonym DBA_HIST_SEG_STAT_OBJ;
drop view DBA_HIST_SEG_STAT_OBJ;
drop public synonym DBA_HIST_METRIC_NAME;
drop view DBA_HIST_METRIC_NAME;
drop public synonym DBA_HIST_SYSMETRIC_HISTORY;
drop view DBA_HIST_SYSMETRIC_HISTORY;
drop public synonym DBA_HIST_SYSMETRIC_SUMMARY;
drop view DBA_HIST_SYSMETRIC_SUMMARY;
drop public synonym DBA_HIST_FILEMETRIC_HISTORY;
drop view DBA_HIST_FILEMETRIC_HISTORY;
drop public synonym DBA_HIST_WAITCLASSMET_HISTORY;
drop view DBA_HIST_WAITCLASSMET_HISTORY;
drop public synonym DBA_HIST_DLM_MISC;
drop view DBA_HIST_DLM_MISC;
drop public synonym DBA_HIST_CR_BLOCK_SERVER;
drop view DBA_HIST_CR_BLOCK_SERVER;
drop public synonym DBA_HIST_CURRENT_BLOCK_SERVER;
drop view DBA_HIST_CURRENT_BLOCK_SERVER;
drop public synonym DBA_HIST_CLASS_CACHE_TRANSFER;
drop view DBA_HIST_CLASS_CACHE_TRANSFER;
drop public synonym DBA_HIST_SERVICE_NAME;
drop view DBA_HIST_SERVICE_NAME;
drop public synonym DBA_HIST_SERVICE_STAT;
drop view DBA_HIST_SERVICE_STAT;
drop public synonym DBA_HIST_SERVICE_WAIT_CLASS;
drop view DBA_HIST_SERVICE_WAIT_CLASS;
drop public synonym DBA_HIST_ACTIVE_SESS_HISTORY;
drop view DBA_HIST_ACTIVE_SESS_HISTORY;
drop public synonym DBA_HIST_TABLESPACE_STAT;
drop view DBA_HIST_TABLESPACE_STAT;
drop public synonym DBA_HIST_LOG;
drop view DBA_HIST_LOG;
drop public synonym DBA_HIST_MTTR_TARGET_ADVICE;
drop view DBA_HIST_MTTR_TARGET_ADVICE;
drop public synonym DBA_HIST_TBSPC_SPACE_USAGE;
drop view DBA_HIST_TBSPC_SPACE_USAGE;
drop public synonym DBA_HIST_SESSMETRIC_HISTORY;
drop view DBA_HIST_SESSMETRIC_HISTORY;
drop public synonym DBA_HIST_SYS_TIME_MODEL;
drop view DBA_HIST_SYS_TIME_MODEL;
drop public synonym DBA_HIST_OSSTAT_NAME;
drop view DBA_HIST_OSSTAT_NAME;
drop public synonym DBA_HIST_OSSTAT;
drop view DBA_HIST_OSSTAT;

Rem Drop the AWR report synonyms and types
drop public synonym AWRRPT_TEXT_TYPE_TABLE;
drop public synonym AWRRPT_TEXT_TYPE;
drop public synonym AWRRPT_HTML_TYPE_TABLE;
drop public synonym AWRRPT_HTML_TYPE;
drop public synonym AWRRPT_ROW_TYPE;
drop public synonym NUM_ARY;
drop public synonym VCH_ARY;
drop public synonym CLB_ARY;
drop public synonym AWRRPT_ROW_TYPE;

drop type AWRRPT_TEXT_TYPE_TABLE;
drop type AWRRPT_TEXT_TYPE;
drop type AWRRPT_HTML_TYPE_TABLE;
drop type AWRRPT_HTML_TYPE;
drop type AWRRPT_ROW_TYPE;
drop type NUM_ARY;
drop type VCH_ARY;
drop type CLB_ARY;

Rem Drop DB Feature Usage views
DROP VIEW DBA_FEATURE_USAGE_STATISTICS;
DROP PUBLIC SYNONYM DBA_FEATURE_USAGE_STATISTICS;
DROP VIEW DBA_HIGH_WATER_MARK_STATISTICS;
DROP PUBLIC SYNONYM DBA_HIGH_WATER_MARK_STATISTICS;

Rem Drop Server Alert views
drop public synonym DBA_OUTSTANDING_ALERTS;
drop view DBA_OUTSTANDING_ALERTS;
drop public synonym DBA_ALERT_HISTORY;
drop view DBA_ALERT_HISTORY;
drop public synonym DBA_THRESHOLDS;
drop view DBA_THRESHOLDS;
drop public synonym DBA_ALERT_ARGUMENTS;
drop view DBA_ALERT_ARGUMENTS;

Rem Drop services views
drop view dba_services;
drop view all_services;

DROP VIEW DBA_AUDIT_POLICY_COLUMNS;
DROP public synonym DBA_AUDIT_POLICY_COLUMNS;
DROP VIEW ALL_AUDIT_POLICY_COLUMNS;
DROP public synonym ALL_AUDIT_POLICY_COLUMNS;
DROP VIEW USER_AUDIT_POLICY_COLUMNS;
DROP public synonym USER_AUDIT_POLICY_COLUMNS;

DROP VIEW DBA_COMMON_AUDIT_TRAIL;
DROP public synonym DBA_COMMON_AUDIT_TRAIL;

drop public synonym USER_RECYCLEBIN;
drop public synonym RECYCLEBIN;
drop view USER_RECYCLEBIN;
drop public synonym DBA_RECYCLEBIN;
drop view DBA_RECYCLEBIN;

drop public synonym FLASHBACK_TRANSACTION_QUERY;
drop view FLASHBACK_TRANSACTION_QUERY;

drop public synonym DBA_SERVER_REGISTRY;
drop view DBA_SERVER_REGISTRY;

Rem
Rem BEGIN of dropping STREAMS views
Rem

drop public synonym DBA_APPLY_ENQUEUE;
drop view DBA_APPLY_ENQUEUE;

drop public synonym ALL_APPLY_ENQUEUE;
drop view ALL_APPLY_ENQUEUE;

drop public synonym DBA_APPLY_EXECUTE;
drop view DBA_APPLY_EXECUTE;

drop public synonym ALL_APPLY_EXECUTE;
drop view ALL_APPLY_EXECUTE;

DROP PUBLIC SYNONYM ALL_CAPTURE_EXTRA_ATTRIBUTES;
DROP VIEW ALL_CAPTURE_EXTRA_ATTRIBUTES;

DROP PUBLIC SYNONYM DBA_CAPTURE_EXTRA_ATTRIBUTES;
DROP VIEW DBA_CAPTURE_EXTRA_ATTRIBUTES;

DROP PUBLIC SYNONYM DBA_APPLY_INSTANTIATED_SCHEMAS;
DROP VIEW DBA_APPLY_INSTANTIATED_SCHEMAS;

DROP PUBLIC SYNONYM DBA_APPLY_INSTANTIATED_GLOBAL;
DROP VIEW DBA_APPLY_INSTANTIATED_GLOBAL;

DROP PUBLIC SYNONYM DBA_STREAMS_MESSAGE_RULES;
DROP VIEW DBA_STREAMS_MESSAGE_RULES;

DROP PUBLIC SYNONYM ALL_STREAMS_MESSAGE_RULES;
DROP VIEW ALL_STREAMS_MESSAGE_RULES;

DROP PUBLIC SYNONYM DBA_STREAMS_MESSAGE_CONSUMERS;
DROP VIEW DBA_STREAMS_MESSAGE_CONSUMERS;

DROP PUBLIC SYNONYM ALL_STREAMS_MESSAGE_CONSUMERS;
DROP PUBLIC SYNONYM DBA_STREAMS_TRANSFORM_FUNCTION;

DROP VIEW DBA_STREAMS_TRANSFORM_FUNCTION;
DROP PUBLIC SYNONYM ALL_STREAMS_TRANSFORM_FUNCTION;

DROP VIEW ALL_STREAMS_TRANSFORM_FUNCTION;
DROP PUBLIC SYNONYM DBA_STREAMS_ADMINISTRATOR;

DROP VIEW ALL_STREAMS_MESSAGE_CONSUMERS;
DROP VIEW DBA_STREAMS_ADMINISTRATOR;

DROP VIEW "_DBA_STREAMS_MESSAGE_CONSUMERS";
DROP VIEW "_DBA_STREAMS_MSG_NOTIFICATIONS";
DROP VIEW "_DBA_STREAMS_UNSUPPORTED_9_2";
DROP VIEW "_DBA_STREAMS_UNSUPPORTED_10_1";
DROP VIEW "_DBA_STREAMS_NEWLY_SUPTED_10_1";
DROP PUBLIC SYNONYM DBA_STREAMS_UNSUPPORTED;
DROP VIEW DBA_STREAMS_UNSUPPORTED;
DROP PUBLIC SYNONYM ALL_STREAMS_UNSUPPORTED;
DROP VIEW ALL_STREAMS_UNSUPPORTED;
DROP PUBLIC SYNONYM DBA_STREAMS_NEWLY_SUPPORTED;
DROP VIEW DBA_STREAMS_NEWLY_SUPPORTED;
DROP PUBLIC SYNONYM ALL_STREAMS_NEWLY_SUPPORTED;
DROP VIEW ALL_STREAMS_NEWLY_SUPPORTED;
DROP VIEW "_DBA_APPLY_CONSTRAINT_COLUMNS";
DROP VIEW "_DBA_APPLY_OBJECT_CONSTRAINTS";

DROP VIEW ALL_STREAMS_RULES;
DROP PUBLIC SYNONYM ALL_STREAMS_RULES;

DROP VIEW "_ALL_STREAMS_PROCESSES";

DROP VIEW "_DBA_APPLY_OBJECTS";
DROP VIEW "_DBA_APPLY_TABLE_COLUMNS";
DROP VIEW "_DBA_APPLY_TABLE_COLUMNS_H";
DROP VIEW DBA_APPLY_TABLE_COLUMNS;
DROP PUBLIC SYNONYM DBA_APPLY_TABLE_COLUMNS;
DROP VIEW ALL_APPLY_TABLE_COLUMNS;
DROP PUBLIC SYNONYM ALL_APPLY_TABLE_COLUMNS;

Rem
Rem END of dropping STREAMS views
Rem

Rem
Rem BEGIN dropping Logminer views
Rem
drop public synonym dba_logmnr_log;
drop view dba_logmnr_log;
drop public synonym dba_logmnr_purged_log;
drop view dba_logmnr_purged_log;
drop public synonym dba_logmnr_session;
drop view dba_logmnr_session;
drop public synonym V$LOGMNR_LATCH;
drop view V_$LOGMNR_LATCH;
drop public synonym GV$LOGMNR_LATCH;
drop view GV_$LOGMNR_LATCH;
drop view logstdby_unsupported_tables;
Rem
Rem END dropping Logminer views
Rem

drop public synonym USER_REWRITE_EQUIVALENCE;
drop view USER_REWRITE_EQUIVALENCE;
drop public synonym ALL_REWRITE_EQUIVALENCE;
drop view ALL_REWRITE_EQUIVALENCE;
drop public synonym DBA_REWRITE_EQUIVALENCE;
drop view DBA_REWRITE_EQUIVALENCE;

drop PUBLIC SYNONYM DBA_RSRC_GROUP_MAPPINGS;
drop view DBA_RSRC_GROUP_MAPPINGS;
drop PUBLIC SYNONYM DBA_RSRC_MAPPING_PRIORITY;
drop view DBA_RSRC_MAPPING_PRIORITY;

Rem Drop online redefinition views/synonyms
drop view DBA_REDEFINITION_OBJECTS;
drop view DBA_REDEFINITION_ERRORS;
drop public synonym DBA_REDEFINITION_OBJECTS;
drop public synonym DBA_REDEFINITION_ERRORS;

Rem Drop Logical Standby internal only use view
drop view LOGSTDBY_SUPPORT;

Rem
Rem BEGIN of dropping TSM views
Rem

drop public synonym dba_tsm_history;
drop view dba_tsm_history;

Rem
Rem END of dropping TSM views
Rem


Rem=========================================================================
Rem remove ODCI ALL/DBA/USER views 
Rem=========================================================================
DROP PUBLIC SYNONYM DBA_INDEXTYPE_ARRAYTYPES;
DROP VIEW DBA_INDEXTYPE_ARRAYTYPES;
DROP PUBLIC SYNONYM USER_INDEXTYPE_ARRAYTYPES;
DROP VIEW USER_INDEXTYPE_ARRAYTYPES;
DROP PUBLIC SYNONYM ALL_INDEXTYPE_ARRAYTYPES;

Rem =====  drop PL/SQL warnings related views 
DROP PUBLIC synonym USER_warning_settings;
DROP PUBLIC synonym all_warning_settings;
DROP PUBLIC synonym dba_warning_settings;
DROP VIEW ALL_INDEXTYPE_ARRAYTYPES;
DROP VIEW USER_warning_settings;
DROP VIEW all_warning_settings;
DROP VIEW dba_warning_settings;

Rem
Rem DROP logical standby user views
Rem
DROP VIEW dba_logstdby_history;
DROP PUBLIC SYNONYM dba_logstdby_history;

Rem
Rem DROP optimizer statistics views
Rem
DROP VIEW DBA_TAB_STATISTICS;
DROP PUBLIC SYNONYM DBA_TAB_STATISTICS;
DROP VIEW USER_TAB_STATISTICS;
DROP PUBLIC SYNONYM USER_TAB_STATISTICS;
DROP VIEW ALL_TAB_STATISTICS;
DROP PUBLIC SYNONYM ALL_TAB_STATISTICS;
DROP VIEW DBA_IND_STATISTICS;
DROP PUBLIC SYNONYM DBA_IND_STATISTICS;
DROP VIEW USER_IND_STATISTICS;
DROP PUBLIC SYNONYM USER_IND_STATISTICS;
DROP VIEW ALL_IND_STATISTICS;
DROP PUBLIC SYNONYM ALL_IND_STATISTICS;

Rem
Rem DROP *_plsql_objects views
Rem
DROP VIEW DBA_PLSQL_OBJECTS;
DROP PUBLIC SYNONYM DBA_PLSQL_OBJECTS;
DROP VIEW USER_PLSQL_OBJECTS;
DROP PUBLIC SYNONYM USER_PLSQL_OBJECTS;
DROP VIEW ALL_PLSQL_OBJECTS;
DROP PUBLIC SYNONYM ALL_PLSQL_OBJECTS;
DROP FUNCTION PLSQL_COMPILER_SETTINGS;
DROP TYPE COMPILER_SETTING_COLL;
DROP TYPE COMPILER_SETTING;

Rem=========================================================================
Rem Remove changes to sql.bsq dictionary tables here 
Rem=========================================================================

Rem Truncate SQL Tuning Base tables
truncate table sql$;
truncate table sql$text;
truncate table sqlprof$;
truncate table sqlprof$desc;
truncate table sqlprof$attr;

Rem Truncate auto stats collection table
truncate table stats_target$;

Rem
Rem Drop TSM types
Rem
drop type sys.tsm$session_id force;
drop type sys.tsm$session_id_list force;

Rem=========================================================================
Rem Delete optimizer statistics for fixed tables
Rem=========================================================================
execute dbms_stats.delete_fixed_objects_stats;
Rem=========================================================================
Rem Delete optimizer caching statistics
Rem=========================================================================
execute dbms_stats.delete_database_stats(null, null, null, true, 'cache');
Rem=========================================================================
Rem Delete optimizer statistics for dictionary tables
Rem=========================================================================
execute dbms_stats.delete_dictionary_stats;

Rem 
Rem Begin: drop OLAP Service related system tables
Rem

truncate table aw_obj$;
truncate table aw_prop$;

Rem 
Rem End: drop OLAP Service related system tables
Rem

Rem 
Rem XMLGenformattype downgrade.
Rem 
alter type sys.xmlgenformattype drop attribute controlflag cascade;
alter type sys.xmlgenformattype
 DROP STATIC function createFormat2(
      enclTag in varchar2 := 'ROWSET',
      flags in raw) return sys.xmlgenformattype 
      deterministic parallel_enable
CASCADE;

Rem
Rem Metadata API changes
Rem

DELETE FROM sys.metaview$               WHERE model='ORACLE';
DELETE FROM sys.metafilter$             WHERE model='ORACLE';
DELETE FROM sys.metaxslparam$           WHERE model='ORACLE';
DELETE FROM sys.metaxsl$                WHERE model='ORACLE';
DELETE FROM sys.metastylesheet          WHERE model='ORACLE';
DELETE FROM sys.metascript$             WHERE model='ORACLE';
DELETE FROM sys.metascriptfilter$       WHERE model='ORACLE';
DELETE FROM sys.metanametrans$          WHERE model='ORACLE';
DELETE FROM sys.metapathmap$            WHERE model='ORACLE';

update metaxslparam$ set properties=0;
update metaxslparam$ set parse_attr=NULL;

UPDATE mlog$ SET oldest_seq = NULL;
UPDATE cdc_change_tables$ SET mvl_oldest_seq = NULL;
UPDATE cdc_change_tables$ SET mvl_oldest_seq_time = NULL;

Rem
Rem set attname in dimattr$ to NULL
Rem 

update dimattr$ set attname=NULL;

Rem
Rem set numqbnodes, qbcmarker, markerdty in sum$ to NULL and
Rem clear fields in sum$ used by rewrite equivalence
Rem

update sum$ set numqbnodes=NULL, qbcmarker=NULL, markerdty=NULL,
                rw_name=NULL, dest_stmt=NULL, rw_mode=0, 
                src_stmt=NULL;


Rem
Rem Bigfile Tablespace downgrade
Rem

DELETE FROM sys.props$ WHERE name = 'DEFAULT_TBS_TYPE';

Rem
Rem set alias_txt in snap$ to NULL
Rem

update snap$ set alias_txt=NULL;

COMMIT;

Rem
Rem Truncate all the new online redefinition dictionary tables
Rem
truncate table redef$;
truncate table redef_object$;
truncate table redef_dep_error$;


Rem
Rem Truncate the service$ table
Rem
truncate table service$;


Rem
Rem Truncate the expimp_tts_ct$ table
Rem
truncate table expimp_tts_ct$;


Rem
Rem Move contents of proxy_info$ and proxy_role_info$ back to previous 
Rem locations
Rem

insert into proxy_data$ 
  select client#,
         proxy#,
         decode(credential_type#, 0, 0,/* No Authentication => No Credential */
                                  5, 4),/* Authentication => Oracle Password */
         0,                                                    /* no version */
         0,                                                    /* no version */
         flags
  from proxy_info$;

insert into proxy_role_data$
  select * from proxy_role_info$;

truncate table proxy_info$;

truncate table proxy_role_info$;

truncate TABLE warning_settings$;

UPDATE error$
  SET property =0, error#=0;

Rem 
Rem set nextbindnum column in operator$ to default
Rem
update operator$ set nextbindnum = 0;


Rem=========================================================================
Rem put synonym policies,groups,and context back to base object
update rls$ set ptype = obj# where obj# in (select obj# from syn$);
update rls$ r set obj# = (select object_id from dba_objects o, syn$ s
                                where r.ptype=s.obj# and s.owner=o.owner and
                                      s.name=o.object_name)
  where r.ptype is not null;


update rls_grp$ set synid = obj#  where obj# in (select obj# from syn$);
update rls_grp$ r set obj# = (select object_id from dba_objects o, syn$ s
                                where r.synid=s.obj# and s.owner=o.owner and
                                      s.name=o.object_name)
  where r.synid is not null;


update rls_ctx$ set synid = obj#  where obj# in (select obj# from syn$);
update rls_ctx$ r set obj# = (select object_id from dba_objects o, syn$ s
                                where r.synid=s.obj# and s.owner=o.owner and
                                      s.name=o.object_name)
  where r.synid is not null;
commit;

Rem=========================================================================
Rem Remove support of security relevant columns on VPD policies
Rem=========================================================================
truncate table rls_sc$;
update rls$ set stmt_type = stmt_type - 1024 where stmt_type > 1024;
update rls$ set stmt_type = stmt_type - 512 where stmt_type > 512;
update rls$ set stmt_type = stmt_type - 256 where stmt_type > 256;
commit;

Rem=========================================================================
Rem Begin Streams Downgrade
Rem=========================================================================

Rem set precommit_handler, negative rule, start_date, and end_date 
Rem set in streams$_apply_process to NULL
Rem 

UPDATE streams$_apply_process 
  SET precommit_handler = NULL,
      negative_ruleset_owner = NULL,
      negative_ruleset_name = NULL,
      error_number = NULL,
      error_message = NULL,
      status_change_time = NULL,
      start_date = NULL, end_date = NULL;

Rem set negative rule set in streams$_capture_process
UPDATE streams$_capture_process 
  SET negative_ruleset_owner = NULL, 
      negative_ruleset_name = NULL,
      error_number = NULL,
      error_message = NULL,
      status_change_time = NULL,
      start_date = NULL, 
      end_date = NULL, 
      version = NULL;

Rem set negative rule set in streams$_propagation_process
UPDATE streams$_propagation_process 
  SET negative_ruleset_schema = NULL, 
      negative_ruleset = NULL;

Rem set start_scn in streams$_apply_milestone
UPDATE streams$_apply_milestone
  SET start_scn = NULL;

COMMIT;

alter table sys.apply$_dest_obj_ops modify
(sname varchar2(30) default '$',
 oname varchar2(30) default '$');

drop index i_apply_dest_obj_ops1;

create unique index i_apply_dest_obj_ops1 on
  apply$_dest_obj_ops (object_number, apply_operation);

Rem set and_condition in streams$_rules 
UPDATE streams$_rules
  SET and_condition = NULL;

TRUNCATE TABLE sys.streams$_extra_attrs;
TRUNCATE TABLE streams$_privileged_user;
TRUNCATE TABLE streams$_message_rules;
TRUNCATE TABLE streams$_message_consumers;
TRUNCATE TABLE apply$_constraint_columns;
TRUNCATE TABLE apply$_virtual_obj_cons;
TRUNCATE TABLE streams$_dest_objs;
TRUNCATE TABLE streams$_dest_obj_cols;

rem vacate SYSAUX
alter table streams$_apply_progress move tablespace SYSTEM;
alter table apply$_error move tablespace SYSTEM;
alter index streams$_apply_error_unq rebuild tablespace SYSTEM;

rem strip quotes from procedure names with length > 92 in following columns
rem sys.streams$_apply_process.message_handler, 
rem sys.streams$_apply_process.ddl_handler,
rem sys.apply$_dest_obj_ops.user_apply_procedure
DECLARE
  cursor ap_cur1 is select message_handler from sys.streams$_apply_process
    where nvl(length(message_handler), 0) > 92
    for update of message_handler;
  cursor ap_cur2 is select ddl_handler from sys.streams$_apply_process
    where nvl(length(ddl_handler), 0) > 92
    for update of ddl_handler;
  cursor doo_cur is select user_apply_procedure from sys.apply$_dest_obj_ops
    where nvl(length(user_apply_procedure), 0) > 92
    for update of user_apply_procedure;
BEGIN
  for ap_rec1 in ap_cur1 loop
    update sys.streams$_apply_process
      set message_handler = replace(ap_rec1.message_handler, '"')
      where current of ap_cur1;
    dbms_system.ksdwrt(dbms_system.alert_file,
      'double quotes were removed from procedure name ' ||
       ap_rec1.message_handler ||
      ' in column MESSAGE_HANDLER of table SYS.STREAMS$_APPLY_PROCESS'||
      ' because it was longer than 92 characters');
  end loop;

  for ap_rec2 in ap_cur2 loop
    update sys.streams$_apply_process
      set ddl_handler = replace(ap_rec2.ddl_handler, '"')
      where current of ap_cur2;
    dbms_system.ksdwrt(dbms_system.alert_file,
      'double quotes were removed from procedure name ' ||
       ap_rec2.ddl_handler ||
      ' in column DDL_HANDLER of table SYS.STREAMS$_APPLY_PROCESS because'||
      ' it was longer than 92 characters');
  end loop;

  for doo_rec in doo_cur loop
    update sys.apply$_dest_obj_ops
      set user_apply_procedure = replace(doo_rec.user_apply_procedure, '"')
      where current of doo_cur;
    dbms_system.ksdwrt(dbms_system.alert_file,
      'double quotes were removed from procedure name ' ||
       doo_rec.user_apply_procedure ||
      ' in column USER_APPLY_PROCEDURE of table SYS.APPLY$_DEST_OBJ_OPS'||
      '  because it was longer than 92 characters');
  end loop;

  commit;
END;
/


Rem change expact$ params to 9.2 format
DECLARE
  -- cursor to select non-subscriber AQ expact$ entries
  CURSOR uargs1_cur IS SELECT user_arg FROM sys.expact$ WHERE
                              func_schema = 'SYS'
                              AND func_package = 'DBMS_AQ_IMPORT_INTERNAL'
                              AND func_proc != 'AQ_EXPORT_SUBSCRIBER'
                       FOR UPDATE;
  -- cursor to select subscriber AQ expact$ entries
  CURSOR uargs2_cur IS SELECT user_arg FROM sys.expact$ WHERE
                              func_schema = 'SYS'
                              AND func_package = 'DBMS_AQ_IMPORT_INTERNAL'
                              AND func_proc = 'AQ_EXPORT_SUBSCRIBER'
                       FOR UPDATE;

  new_uargs      VARCHAR2(2000);

  -- this procedure parses the expact entry
  PROCEDURE aq_comma_to_table100(arg_list IN     VARCHAR2, 
                                 argc     OUT    BINARY_INTEGER,
                                 argv     OUT    DBMS_UTILITY.UNCL_ARRAY) IS 

    c_pos     BINARY_INTEGER := 1;
    c_old_pos BINARY_INTEGER := 2;

  BEGIN
    argc := 1;
    LOOP
      -- c_pos points to ending quote that wraps token
      -- c_old_pos points to the character after starting quote of token
      c_pos := INSTR(arg_list, '","', c_pos);

      -- get value (without the wrapping quotes)
      IF c_pos != 0 THEN
        argv(argc) := SUBSTR(arg_list, c_old_pos, c_pos-c_old_pos);
      ELSE 
        argv(argc) := SUBSTR(arg_list, c_old_pos,
                              LENGTH(arg_list)-c_old_pos);
      END IF;
      EXIT WHEN c_pos = 0;

      -- update c_pos to point to start of next token (skipping over ",")
      c_pos     := c_pos + 3;
      c_old_pos := c_pos;
      argc      := argc + 1;

    END LOOP;
  END aq_comma_to_table100;

  -- this function gives the expact string in old format
  FUNCTION get_old_sub_expact_string(arg_list IN VARCHAR2) RETURN VARCHAR2 IS
    argv           dbms_utility.uncl_array;
    argc           BINARY_INTEGER;
    queue_name     VARCHAR2(30);
    sub_name       VARCHAR2(30);
    sub_dest       VARCHAR2(1024);
    sub_pro        VARCHAR2(30);
    old_sub_dest   VARCHAR2(1024);
    old_str        VARCHAR2(2000);         -- the pre 10.1 format expact string
    schema_canon   VARCHAR2(30);
    name_canon     VARCHAR2(30);
    db_name        VARCHAR2(128);
    db_dom         VARCHAR2(128);
  BEGIN
    aq_comma_to_table100(arg_list, argc, argv);

    -- extract the subscriber fields from the argument
    queue_name := argv(1);
    IF (LENGTH(argv(2)) > 4) THEN
      --all the data after the first 4 char
      sub_name   := SUBSTR(argv(2), 5);
    ELSE
      sub_name   := NULL;
    END IF;
  
    IF (LENGTH(argv(3)) > 4) THEN
      --all the data after the first 4 char
      sub_dest   := SUBSTR(argv(3), 5);
    ELSE
      sub_dest   := NULL;
    END IF;

    IF (LENGTH(argv(4)) > 4) THEN
      --all the data after the first 4 char
      sub_pro   := TO_NUMBER(SUBSTR(argv(4), 5)); 
    ELSE
      sub_pro   := NULL;
    END IF;

    old_sub_dest := sub_dest;
    -- only parse the address if internal protocol 0 and address in not null
    IF sub_pro = 0 AND sub_dest IS NOT NULL THEN
      BEGIN
        dbms_aqadm_sys.parse_name(
          dbms_aqadm_sys.AQ_SUBSCRIBER_ADDRESS, sub_dest, schema_canon, 
          name_canon, db_name, db_dom, FALSE);

        old_sub_dest := schema_canon || '.' || name_canon;
        IF db_name IS NOT NULL THEN
          old_sub_dest := old_sub_dest || '@' || db_name;
          IF db_dom IS NOT NULL THEN
             old_sub_dest := old_sub_dest || '.' || db_dom;
          END IF;
        END IF;
      EXCEPTION WHEN others THEN
        -- parsing failed, so use old address and write an alert
        old_sub_dest := sub_dest;
        dbms_system.ksdwrt(dbms_system.alert_file,
          'Subscriber '|| sub_name ||' has invalid address '||
           sub_dest ||'.  Please remove this subscriber since it '||
          'has an unusable address');
      END;
    END IF;

    old_str := queue_name|| ',' ||'NAME'||sub_name||
               ',' || 'ADDR'||old_sub_dest||
               ',' || 'PROT'||TO_CHAR(sub_pro);

    RETURN old_str;
  END get_old_sub_expact_string;

BEGIN
  -- downgrade the non-subscriber entries
  FOR uargs1_rec IN uargs1_cur LOOP
    -- for idempotence, don't change values that start with double quote
    IF SUBSTR(uargs1_rec.user_arg, 1, 1) = '"' THEN
      -- replace '","' with ',' and remove quote at begining and end
      new_uargs := REPLACE(uargs1_rec.user_arg, '","', ',');
      -- copy values between start and end quote.
      new_uargs := SUBSTR(new_uargs, 2, LENGTH(new_uargs)-2);
      UPDATE sys.expact$ SET user_arg = new_uargs WHERE CURRENT OF uargs1_cur;
    END IF;
  END LOOP;

  -- downgrade the subscriber entries
  FOR uargs2_rec IN uargs2_cur LOOP
    -- for idempotence, don't change values that start with double quote
    IF SUBSTR(uargs2_rec.user_arg, 1, 1) = '"' THEN
      new_uargs := get_old_sub_expact_string(uargs2_rec.user_arg);
      UPDATE sys.expact$ SET user_arg = new_uargs WHERE CURRENT OF uargs2_cur;
    END IF;
  END LOOP;

  COMMIT;
END;
/

Rem downgrade 8.0 subscribers.  Leave unparseable address as is.
DECLARE
  CURSOR subs_cur IS SELECT subscribers FROM system.aq$_queues
                       WHERE subscribers IS NOT NULL FOR UPDATE;
  subs             AQ$_SUBSCRIBERS;
  new_address      VARCHAR2(1024);                       -- downgraded address
  schema_canon     VARCHAR2(30);
  name_canon       VARCHAR2(30);
  db_name          VARCHAR2(128);
  db_dom           VARCHAR2(128);
BEGIN
  FOR subs_rec IN subs_cur LOOP
    subs := subs_rec.subscribers;
    FOR i IN 1..subs.COUNT LOOP
      -- if a subscriber with an address is found and protocol is null or 0
      -- then put the address into 9.2 format.
      IF subs.EXISTS(i) AND subs(i) IS NOT NULL
         AND subs(i).address IS NOT NULL
         AND (subs(i).protocol IS NULL OR subs(i).protocol = 0) THEN
        -- parse name to get components and form new name.
        -- catch exceptions and leave value alone
        BEGIN
          dbms_aqadm_sys.parse_name(
            dbms_aqadm_sys.AQ_SUBSCRIBER_ADDRESS, subs(i).address,
            schema_canon, name_canon, db_name, db_dom, FALSE);

            new_address := schema_canon || '.' ||name_canon;
            IF db_name IS NOT NULL THEN
              new_address := new_address || '@' || db_name;
              IF db_dom IS NOT NULL THEN
                new_address := new_address || '.' || db_dom;
              END IF;
            END IF;
            -- assign new address
            subs(i).address := new_address;
         EXCEPTION WHEN others THEN
           dbms_system.ksdwrt(dbms_system.alert_file,
             'Subscriber '|| subs(i).name ||' with address '||
             subs(i).address ||' has an invalid address.' ||
             'Please remove this subscriber since it has an unusable address');
         END;
      END IF;
    END LOOP;
    -- update with new subscribers entry
    UPDATE system.aq$_queues SET subscribers = subs
      WHERE CURRENT OF subs_cur;
  END LOOP;
  COMMIT;
END;
/

Rem Remove negative rule set column from AQ subscriber tables
Rem Remove quotes from ruleset_name
Rem Downgrade 8.1 subscriber queue addresses
DECLARE
  qt_schema    VARCHAR2(30);
  qt_name      VARCHAR2(30);
  qt_flags     NUMBER;
  CURSOR find_qt_c IS select schema, name, flags from system.aq$_queue_tables;
  upd_sql      VARCHAR2(300);
  a_upd_sql    VARCHAR2(256);
  a_sel_sql    VARCHAR2(512);      -- sql for selecting addresses to downgrade
  sub_id       NUMBER;
  TYPE cur_type IS REF CURSOR;
  a_cv         CUR_TYPE;
  old_address  VARCHAR2(1024);
  new_address  VARCHAR2(1024);
  sub_name     VARCHAR2(30);
  schema_canon VARCHAR2(30);
  name_canon   VARCHAR2(30);
  db_name      VARCHAR2(128);
  db_dom       VARCHAR2(128);
BEGIN

  FOR q_rec IN find_qt_c LOOP         -- iterate all queue tables
    qt_schema := q_rec.schema;                     -- get queue table schema
    qt_name   := q_rec.name;                         -- get queue table name
    qt_flags  := q_rec.flags;

    -- set user_property to NULL
    IF (bitand(qt_flags, 8) = 8) THEN
      upd_sql := 'UPDATE "' || qt_schema || '"."' || qt_name ||
                      '" set user_prop = NULL';
      EXECUTE IMMEDIATE upd_sql;
      commit;
    END IF;

    -- downgrade subscriber table
    IF ((bitand(qt_flags, 8) = 8) AND (bitand(qt_flags, 1) = 1)) THEN
      upd_sql := 'UPDATE '
                 || '"'||qt_schema||'"' || '.' || '"'||'AQ$_'
                 || qt_name ||'_S'||'"'
                 || ' set negative_ruleset_name = NULL,'
                 || ' ruleset_name = replace(ruleset_name, ''"'')';

      -- selecting addresses that need to be downgraded
      a_sel_sql := 'SELECT name, address, subscriber_id FROM '
                      || '"'||qt_schema||'"' || '.' || '"'||'AQ$_'|| qt_name
                      ||'_S'||'"'|| ' WHERE (protocol is NULL '
                      ||'OR protocol = 0) AND address IS NOT NULL '
                      ||'AND (bitand(subscriber_type, 4) = 4 '
                      ||'  OR bitand(subscriber_type, 2) = 2 '
                      ||'  OR bitand(subscriber_type, 1) = 1) FOR UPDATE';

      -- for updating the address
      a_upd_sql := 'UPDATE '
                      || '"'||qt_schema||'"' || '.' || '"'||'AQ$_'|| qt_name
                      ||'_S'||'"'|| ' set address = :1 WHERE '
                      ||'subscriber_id = :2';
      BEGIN
        EXECUTE IMMEDIATE upd_sql;

        -- downgrade address
        OPEN a_cv FOR a_sel_sql;
        LOOP
          FETCH a_cv into sub_name, old_address, sub_id;
          EXIT WHEN a_cv%NOTFOUND;
        
          BEGIN
            dbms_aqadm_sys.parse_name(
              dbms_aqadm_sys.AQ_SUBSCRIBER_ADDRESS, old_address, schema_canon, 
              name_canon, db_name, db_dom, FALSE);

            new_address := schema_canon || '.' || name_canon;
            IF db_name IS NOT NULL THEN
              new_address := new_address || '@' || db_name;
              IF db_dom IS NOT NULL THEN
                new_address := new_address || '.' || db_dom;
              END IF;
            END IF;
          EXCEPTION WHEN others THEN
            -- parsing failed, so use old address and write an alert
            new_address := old_address;
            dbms_system.ksdwrt(dbms_system.alert_file,
              'Subscriber '|| sub_name ||' has invalid address '||
              old_address ||'.  Please remove this subscriber since it '||
              'has an unusable address');
          END;

          -- do update
          EXECUTE IMMEDIATE a_upd_sql USING new_address, sub_id;
        END LOOP;
        CLOSE a_cv;
      EXCEPTION
      WHEN OTHERS THEN
        RAISE;
      END;

      COMMIT;

      dbms_prvtaqis.downgrade_rule_frm10i(qt_schema, qt_name);

    END IF;  -- if 81 style multiconsumer
  END LOOP;
END;
/

Rem Turn off hotmining for RAC
BEGIN
  IF dbms_utility.is_cluster_database THEN
    UPDATE system.logmnr_session$ x
    SET session_attr = DECODE(BITAND(session_attr, 8388608), 8388608,
                                     session_attr-8388608, session_attr)
    WHERE EXISTS (SELECT c.logmnr_sid
                  FROM sys.streams$_capture_process c
                  WHERE c.LOGMNR_SID = x.session#) ;
    COMMIT;
  END IF;
END;
/

Rem Bug 4020148 
Rem Update logminer session_attr to reflect flags used by 9.2.X code
Rem Only update sessions created by streams capture 
Rem
Rem Add KRVX_SESSION_RECORD_GLOBALNAME flag 
UPDATE system.logmnr_session$ x
   SET x.session_attr = x.session_attr + 1073741824 
 WHERE bitand(x.session_attr, 1073741824) != 1073741824   
   AND EXISTS (SELECT c.logmnr_sid
                 FROM sys.streams$_capture_process c
                WHERE c.logmnr_sid = x.session#);   
COMMIT;

Rem Remove KRVX_ATTACH_MULTIPLE flag
UPDATE system.logmnr_session$ x
   SET x.session_attr = x.session_attr - 128
 WHERE bitand(x.session_attr, 128) = 128   
   AND EXISTS (SELECT c.logmnr_sid
                 FROM sys.streams$_capture_process c
                WHERE c.logmnr_sid = x.session#);   
COMMIT;

Rem clear streams unsupported bit
BEGIN
  UPDATE tab$
  SET trigflag = (trigflag - 268435456)
  WHERE BITAND(trigflag, 268435456) = 268435456;
  
  COMMIT;
END;
/

Rem Drop name-value types
drop type sys.streams$nv_node force; 
drop type sys.streams$nv_array force; 

Rem Drop internal transform type
-- Note:  This is a 10gR2 type, but because dbms_streams_adm is called
-- in this script, we must wait to drop this type until after the last
-- call to dbms_streams_adm
begin
  execute immediate 'drop type sys.streams$transformation_info force'; 
end;
/

Rem=========================================================================
Rem End Streams Downgrade
Rem=========================================================================

Rem=========================================================================
Rem Begin Logminer Downgrade
Rem=========================================================================

-- Downgrade checkpoint data to 9.2 form

execute dbms_logmnr_internal.downgrade_ckpt;


-- LOGMNRC_GTCS and LOGMNR_LOG$ have new shapes to their primary keys.
-- LOGMNR_SESSION$ has a new primary key and a new unique key.
-- LOGMNRC_GTCS's key was incorrect, so we leave it upgraded.
-- LOGMNR_LOG$ new key relies on columns which were not present in 9i.
-- This new key will be removed, we ensure uniqueness of the 9.2 key,
-- then we recreate the 9.2 key.
-- LOGMNR_SESSION$ should always have had the primary key, so leave as is.
-- The new unique key on LOGMNR_SESSION$ must be removed since 9.2
-- session did not require a session_name.

   delete (select l.*
           from system.Logmnr_log$ l, system.logmnr_session$ s
           where l.session# = s.session# and 
                   (l.db_id <> s.db_id or 
                    l.resetlogs_change# <> s.resetlogs_change# or
                    l.reset_timestamp <> s.reset_timestamp));
   commit;



--   5.
--   Other:
--
    
DECLARE
  LOGMNR_DWNGRADE_01451 EXCEPTION;
              /* column to be modified to NULL cannot be modified to NULL */
  PRAGMA EXCEPTION_INIT(LOGMNR_DWNGRADE_01451, -1451);
  LOGMNR_DWNGRADE_2260 EXCEPTION;  /* table can have only one primary key */
  PRAGMA EXCEPTION_INIT(LOGMNR_DWNGRADE_2260, -2260);
  LOGMNR_DWNGRADE_02441 EXCEPTION;  /* Cannot drop nonexistent primary key */
  PRAGMA EXCEPTION_INIT(LOGMNR_DWNGRADE_02441, -02441);
  LOGMNR_DWNGRADE_02442 EXCEPTION;  /* Cannot drop nonexistent unique key */
  PRAGMA EXCEPTION_INIT(LOGMNR_DWNGRADE_02442, -02442);

  buf varchar2(1000);
  tablespacename varchar2(100);
  LocalString varchar2(16);

--
-- Returns TRUE if the Logminer table LOGMNRC_GTCS$ exists and is currently
-- partitioned.
-- Returns FALSE if there is no idication that LOGMNRC_GTCS$ is
-- partitioned.
-- Raises "ORA-01403: no data found" if LOGMNRC_GTCS$ does not exist.  This
-- condition is never suppose to occur.
--
  FUNCTION IsPartitioningUsed RETURN BOOLEAN IS
    PartitioningUsed BOOLEAN;
    PartProperty     NUMBER;
  BEGIN
    SELECT bitand(t.property, 32) INTO PartProperty
    FROM tab$ t, obj$ o, user$ u
    WHERE o.owner# = u.user# and t.obj# = o.obj# and o.name = 'LOGMNRC_GTCS'
          and u.name = 'SYSTEM';
    commit;
    RETURN (32 = PartProperty);
  END IsPartitioningUsed;

BEGIN
-- eliminate new out of line constraints
  buf := 'alter table SYSTEM.LOGMNR_LOG$ drop primary key cascade';
  BEGIN
    execute immediate buf;
  EXCEPTION
    WHEN LOGMNR_DWNGRADE_02441 THEN
      NULL;
  END;

  buf := 'alter table system.logmnr_session$ drop
            unique (session_name) cascade';
  BEGIN
    execute immediate buf;
  EXCEPTION
    WHEN LOGMNR_DWNGRADE_02442 THEN
      NULL;
  END;

-- eliminate new inline constraints

  buf := 'alter table SYSTEM.LOGMNR_SESSION$ modify (SESSION_NAME NULL)';
  BEGIN
    execute immediate buf;
  EXCEPTION
    WHEN LOGMNR_DWNGRADE_01451 THEN
      NULL;
  END;


-- What tablespace are Logminer tables currently in?
    BEGIN
      select s.name into tablespacename
         from obj$ o, ts$ s, user$ u, tab$ t
         where s.ts# = t.ts# and o.obj# = t.obj# and
            o.owner# = u.user# and u.name = 'SYSTEM' and
            o.name = 'LOGMNR_SESSION$' and rownum = 1;
    EXCEPTION
      WHEN OTHERS THEN
         tablespacename := 'SYSTEM';
    END;
    commit;

    IF IsPartitioningUsed() THEN
      LocalString := ' LOCAL ';
    ELSE
      LocalString := ' ';
    END IF;

-- restore the 9i primary key for Logmnr_log$
    buf := 'alter table SYSTEM.LOGMNR_LOG$ add constraint LOGMNR_LOG$_PK
             primary key (SESSION#, THREAD#, SEQUENCE#) using index
             tablespace ' || tablespacename || ' LOGGING';
    begin
      execute immediate buf;
    exception
      when LOGMNR_DWNGRADE_2260 THEN
         NULL;
    end;

END;
/

--   4.
--   Drop the newly Created logmnr_ tables.
--
   drop table SYSTEM.LOGMNR_ERROR$;
   drop table SYSTEM.LOGMNR_SESSION_EVOLVE$;


-- 3.
-- Do not Remove all of the newly added columns.  Some requests in 9i
-- use * rather than explicit column lists. Bug 2660185 has been filed
-- and must be fixed in 9.2.0.3 for Logminer to function following a
-- downgrade.
--
-- Set all new columns to NULL.

-- LOGMNR_OBJ$: 10.1 -> 9.2
   update SYSTEM.LOGMNR_OBJ$ set FLAGS = NULL, SPARE3 = NULL, STIME = NULL;
   commit;
-- LOGMNR_TAB$: 10.1 -> 9.2
   update SYSTEM.LOGMNR_TAB$ set KERNELCOLS = NULL, BOBJ# = NULL,
        TRIGFLAG = NULL, FLAGS = NULL;
   commit;

-- LOGMNR_BUILDLOG: 10.1 -> 9.2
   update SYS.LOGMNR_BUILDLOG set MARKED_LOG_FILE_LOW_SCN = NULL;
   commit;

-- LOGMNRC_GTLO: 10.1 -> 9.2
   update SYSTEM.LOGMNRC_GTLO SET COLS = NULL, KERNELCOLS = NULL,
                    TAB_FLAGS = NULL, TRIGFLAG = NULL, OBJ_FLAGS = NULL,
                    LOGMNR_SPARE5 = NULL,  LOGMNR_SPARE6 = NULL, 
                    LOGMNR_SPARE7 = NULL, LOGMNR_SPARE8 = NULL,
                    LOGMNR_SPARE9 = NULL;
   commit;

-- LOGMNRC_GTCS: 10.1 -> 9.2
   update SYSTEM.LOGMNRC_GTCS set LOGMNR_SPARE5 = NULL, LOGMNR_SPARE6 = NULL,
                    LOGMNR_SPARE7 = NULL, LOGMNR_SPARE8 = NULL,
                    LOGMNR_SPARE9 = NULL;
   commit;

-- LOGMNR_LOG$: 10.1 -> 9.2
   update SYSTEM.LOGMNR_LOG$ set DB_ID = NULL, RESETLOGS_CHANGE# = NULL,
                    RESET_TIMESTAMP = NULL, PREV_RESETLOGS_CHANGE# = NULL,
                    BLOCKS = NULL, BLOCK_SIZE = NULL, CONTENTS = NULL, 
                    SPARE1 = NULL, SPARE2 = NULL, SPARE3 = NULL, 
                    SPARE4 = NULL, SPARE5 = NULL;
   commit;

-- LOGMNR_SPILL$: 10.1 -> 9.2
   update SYSTEM.LOGMNR_SPILL$ set SPARE1 = NULL, SPARE2 = NULL;
   commit;

-- LOGMNR_AGE_SPILL$: 10.1 -> 9.2
   update SYSTEM.LOGMNR_AGE_SPILL$ set SPARE1 = NULL, SPARE2 = NULL;
   commit;

-- LOGMNR_RESTART_CKPT$: 10.1 -> 9.2
   update SYSTEM.LOGMNR_RESTART_CKPT$ set CKPT_INFO = NULL, FLAG = NULL,
                    SPARE1 = NULL, SPARE2 = NULL;
   commit;

-- LOGMNR_SESSION$: 10.1 -> 9.2
   update SYSTEM.LOGMNR_SESSION$ set RESUME_SCN = 0,
                    GLOBAL_DB_NAME = NULL, RESET_TIMESTAMP = NULL,
                    BRANCH_SCN = NULL, SPARE1 = NULL, SPARE2 = NULL,
                    SPARE3 = NULL, SPARE4 = NULL, SPARE5 = NULL, SPARE6 = NULL;
   commit;

--

-- 2.
-- dbmslmd.sql for 9.2.0.3 will ensure that G and T tables are recreated.

-- 1.
-- Leave the new constraints names in place.

--
-- Reset the NOLOG property of any supplemental log group
-- For 10G to 9i*, we can safely set ccol$'s spare1 column
-- to null as this was an unused column in 9i code base
--
-- for large databases, limit the number of rows changed before commit to
-- avoid rollback problems during downgrade
begin
  loop
      execute immediate
        'update sys.ccol$ set spare1 = NULL
                where spare1 IS NOT NULL and
                      rownum <10000';
      exit when sql%rowcount = 0;
      commit;
   end loop;
end;
/
commit;


Rem=========================================================================
Rem End Logminer Downgrade
Rem=========================================================================

Rem=========================================================================
Rem Remove Changes to Fine Grain Auditing (FGA) 
Rem=========================================================================
ALTER TABLE fga$ MODIFY (ptxt VARCHAR2(4000) DEFAULT '1=1' NOT NULL);

UPDATE fga$ x
SET x.pcol = 
   (SELECT c.NAME FROM col$ c , fgacol$ fc
    WHERE c.obj# = fc.obj# AND
    fc.obj# = x.obj# AND
    fc.pname = x.pname AND
    fc.intcol# = c.col#);

COMMIT;

Rem=========================================================================
Rem Remove enhancements to fga_log$ and aud$ trails. Do not drop newly
Rem added columns. Populate timestamp# column from ntimestamp#.
Rem=========================================================================

UPDATE fga_log$
    SET timestamp# =
        CAST (
           CAST (
              FROM_TZ(ntimestamp#, '00:00') AS TIMESTAMP WITH LOCAL TIME ZONE
           )
           AS DATE
        )
    WHERE timestamp# IS NULL;

UPDATE aud$
    SET timestamp# =
        CAST (
           CAST (
              FROM_TZ(ntimestamp#, '00:00') AS TIMESTAMP WITH LOCAL TIME ZONE
           )
           AS DATE
        )
    WHERE timestamp# IS NULL;

Rem=========================================================================
Rem Partitioning metadata downgrade.
Rem=========================================================================

merge /*+ use_hash (tp0) */ into tabpart$ tp0 using 
  (select row_number() over (partition by bo# order by part#) part#, obj#
   from   tabpart$ tp) tp1
on (tp1.obj# = tp0.obj#)
when matched then
update set tp0.part# = tp1.part#
when not matched then
insert (obj#) values (null);

merge /*+ use_hash (ip0) */ into indpart$ ip0 using 
  (select row_number() over (partition by bo# order by part#) part#, obj#
   from   indpart$ ip) ip1
on (ip1.obj# = ip0.obj#)
when matched then
update set ip0.part# = ip1.part#
when not matched then
insert (obj#) values (null);

merge /*+ use_hash (tcp0) */ into tabcompart$ tcp0 using 
  (select row_number() over (partition by bo# order by part#) part#, obj#
   from   tabcompart$ tcp) tcp1
on (tcp1.obj# = tcp0.obj#)
when matched then
update set tcp0.part# = tcp1.part#
when not matched then
insert (obj#) values (null);

merge /*+ use_hash (icp0) */ into indcompart$ icp0 using 
  (select row_number() over (partition by bo# order by part#) part#, obj#
   from   indcompart$ icp) icp1
on (icp1.obj# = icp0.obj#)
when matched then
update set icp0.part# = icp1.part#
when not matched then
insert (obj#) values (null);

merge /*+ use_hash (tsp0) */ into tabsubpart$ tsp0 using 
  (select row_number() over (partition by pobj# order by subpart#) subpart#,
     obj#
   from   tabsubpart$ tsp) tsp1
on (tsp1.obj# = tsp0.obj#)
when matched then
update set tsp0.subpart# = tsp1.subpart#
when not matched then
insert (obj#) values (null);

merge /*+ use_hash (isp0) */ into indsubpart$ isp0 using 
  (select row_number() over (partition by pobj# order by subpart#) subpart#,
     obj#
  from   indsubpart$ isp) isp1
on (isp1.obj# = isp0.obj#)
when matched then
update set isp0.subpart# = isp1.subpart#
when not matched then
insert (obj#) values (null);

Rem the following 2 updated must be run after the above updates
Rem since they depend on values updated above.

update lobcomppart$ lcp set part# =
  (select part# from tabcompart$ tcp
  where lcp.tabpartobj# = tcp.obj#);

update lobfrag$ lf set frag# =
  (select part# from tabpart$ tp
  where lf.tabfragobj# = tp.obj#
  union
  select subpart# from tabsubpart$ tsp
  where lf.tabfragobj# = tsp.obj#);

commit;

drop view tabpartv$;
drop view indpartv$;
drop view tabcompartv$;
drop view indcompartv$;
drop view tabsubpartv$;
drop view indsubpartv$;
drop view lobcomppartv$;
drop view lobfragv$;

Rem=========================================================================
Rem End partitioning metadata downgrade
Rem=========================================================================

Rem
Rem Begin CDC changes here
Rem

Rem Delete the new predefined change sources
delete from cdc_change_sources$
where source_name = 'HOTLOG_SOURCE' or source_name = 'SYNC_SOURCE';

Rem Insert the original 9i predefined change source
insert into cdc_change_sources$
  (source_name,dbid,logfile_location,logfile_suffix,source_description,created,
   source_type)
  values('SYNC_SOURCE',NULL,'N/A',NULL,'SYNCHRONOUS CHANGE SOURCE',SYSDATE,
          4);

Rem Delete the new predefined change set
delete from cdc_change_sets$
where set_name = 'SYNC_SET';

Rem Insert the original 9i predefined change set
insert into cdc_change_sets$
  (set_name,change_source_name,begin_date,end_date,begin_scn,end_scn,
   freshness_date,freshness_scn,advance_enabled,ignore_ddl,created,
   rollback_segment_name,advancing,purging,lowest_scn,tablespace,
   lm_session_id,partial_tx_detected,last_advance,last_purge,
   stop_on_ddl,capture_enabled,capture_error)
  values('SYNC_SET','SYNC_SOURCE',SYSDATE,NULL,NULL,0,
   NULL,NULL,'N','Y',SYSDATE,NULL,'N','N',0,'N/A',NULL,'N',NULL,NULL,
   'N','Y','N');

Rem drop new subscriber subscription_name-based unique index
begin
  execute immediate 'DROP INDEX i_cdc_subscribers$';
exception
   when others then
      if sqlcode = -1418 then null;
      else raise;
      end if;
end;
/

Rem Use default value for subscriber columns introduced in 10.1 and
Rem truncate description to 9i length 
update sys.cdc_subscribers$ 
  set subscription_name = 'NONE', reserved1 = NULL,
      description = substr(description, 1, 30);

Rem recreate old subscriber handle-based unique index
begin
  execute immediate 'CREATE UNIQUE INDEX i_cdc_subscribers$ on 
                     sys.cdc_subscribers$(handle)';
exception
   when others then
      if sqlcode = -942 then null;
      else raise;
      end if;
end;
/

Rem set columns added in 10.1 to null
UPDATE cdc_change_tables$ SET source_table_obj# = NULL;
UPDATE cdc_change_tables$ SET source_table_ver = NULL;

Rem remove CDC Data Pump support
DROP PACKAGE dbms_cdc_impdp;
DROP PACKAGE dbms_cdc_expvdp;
DROP PACKAGE dbms_cdc_expdp;
DROP PACKAGE dbms_cdc_dputil;

Rem
Rem End CDC changes here
Rem

Rem=========================================================================
Rem Remove ODCI changes to sql.bsq dictionary tables 
Rem=========================================================================
truncate table indarraytype$;

REM truncate ncomp_dll$ TABLE
truncate TABLE ncomp_dll$;

Rem disable domain index array insert with column data
update indtypes$ set property = property - 2
where bitand(property, 2) =2 AND bitand(property, 1) = 0;

Rem
Rem start Resource Manager changes
Rem

update resource_plan_directive$ set
  max_idle_time = NULL, max_idle_blocker_time = NULL,
  switch_back = NULL;

update user$ u set u.defschclass =
  nvl((select consumer_group from resource_group_mapping$
         where attribute = 'ORACLE_USER' and value = u.name and 
               status = 'ACTIVE'),
      'DEFAULT_CONSUMER_GROUP');
truncate table resource_group_mapping$;
truncate table resource_mapping_priority$;

Rem
Rem end Resource Manager changes
Rem

Rem=========================================================================
Rem ALTER types to drop 10.1.0 attributes, methods, etc.
Rem=========================================================================

Rem Drop SQL Tuning Base types
drop public synonym sqlprof_attr;
drop type sys.sqlprof_attr force;

Rem
Rem Drop types and associated functions used by 10.1 MV refresh
Rem
drop type MVAggRawBitOr_typ force;
drop function MVAggRawBitOr;

Rem
Rem Alter types and associated functions related to lcr$_row_XXXX 
Rem

ALTER TYPE lcr$_row_record DROP MEMBER FUNCTION
   get_extra_attribute(
        attribute_name         IN VARCHAR2) RETURN Sys.AnyData CASCADE
/

ALTER TYPE lcr$_row_record DROP MEMBER PROCEDURE
    set_extra_attribute(self in out nocopy lcr$_row_record,
        attribute_name         IN VARCHAR2,
        attribute_value        IN Sys.AnyData) CASCADE
/

ALTER TYPE lcr$_row_record DROP MEMBER FUNCTION
   get_compatible RETURN NUMBER CASCADE
/

ALTER TYPE lcr$_row_record DROP MEMBER FUNCTION
   get_long_information(
        value_type             IN VARCHAR2,
        column_name            IN VARCHAR2,
        use_old                IN VARCHAR2  DEFAULT 'Y') RETURN NUMBER CASCADE
/

ALTER TYPE lcr$_row_record DROP MEMBER PROCEDURE 
   convert_long_to_lob_chunk(
        self in out nocopy lcr$_row_record) CASCADE
/

ALTER TYPE lcr$_ddl_record DROP MEMBER FUNCTION
   get_extra_attribute(
        attribute_name         IN VARCHAR2) RETURN Sys.AnyData CASCADE
/

ALTER TYPE lcr$_ddl_record DROP MEMBER PROCEDURE
    set_extra_attribute(self in out nocopy lcr$_ddl_record,
        attribute_name         IN VARCHAR2,
        attribute_value        IN Sys.AnyData) CASCADE
/

ALTER TYPE lcr$_ddl_record DROP MEMBER FUNCTION
   get_compatible RETURN NUMBER CASCADE
/

Rem Workaround for bug 2897618
Rem Drop methods from lcr$_row_record before lcr$_row_unit type evolution and 
Rem add them back after the type has evolved

ALTER TYPE lcr$_row_record DROP STATIC FUNCTION construct(
     source_database_name       in varchar2,
     command_type               in varchar2,
     object_owner               in varchar2,
     object_name                in varchar2,
     tag                        in raw               DEFAULT NULL,
     transaction_id             in varchar2          DEFAULT NULL,
     scn                        in number            DEFAULT NULL,
     old_values                 in sys.lcr$_row_list DEFAULT NULL,
     new_values                 in sys.lcr$_row_list DEFAULT NULL
   )  RETURN lcr$_row_record CASCADE;

ALTER TYPE lcr$_row_record DROP MEMBER FUNCTION get_values(
        value_type          IN VARCHAR2,
        use_old             IN VARCHAR2  DEFAULT 'Y')
        return sys.lcr$_row_list CASCADE;

ALTER TYPE lcr$_row_record DROP MEMBER procedure set_values(
        self in out nocopy lcr$_row_record,
        value_type          IN VARCHAR2,
        value_list          IN sys.lcr$_row_list) CASCADE;

Rem Evolve type lcr$_row_unit 
DROP TYPE BODY lcr$_row_unit
/

ALTER TYPE lcr$_row_unit DROP CONSTRUCTOR FUNCTION lcr$_row_unit(
    column_name        VARCHAR2,
    data               SYS.ANYDATA,
    lob_information    NUMBER,
    lob_offset         NUMBER,
    lob_operation_size NUMBER)
    RETURN SELF AS RESULT CASCADE
/

ALTER TYPE lcr$_row_unit DROP ATTRIBUTE long_information CASCADE
/

Rem Now add those methods back to lcr$_row_record
ALTER TYPE lcr$_row_record ADD STATIC FUNCTION construct(
     source_database_name       in varchar2,
     command_type               in varchar2,
     object_owner               in varchar2,
     object_name                in varchar2,
     tag                        in raw               DEFAULT NULL,
     transaction_id             in varchar2          DEFAULT NULL,
     scn                        in number            DEFAULT NULL,
     old_values                 in sys.lcr$_row_list DEFAULT NULL,
     new_values                 in sys.lcr$_row_list DEFAULT NULL
   )  RETURN lcr$_row_record CASCADE;

ALTER TYPE lcr$_row_record ADD MEMBER FUNCTION get_values(
        value_type          IN VARCHAR2,
        use_old             IN VARCHAR2  DEFAULT 'Y')
        return sys.lcr$_row_list CASCADE;

ALTER TYPE lcr$_row_record ADD MEMBER procedure set_values(
        self in out nocopy lcr$_row_record,
        value_type          IN VARCHAR2,
        value_list          IN sys.lcr$_row_list) CASCADE;


Rem The following three ADD MEMBER FUNCTIONs are added to prevent errors 
Rem when dbmslcr of 9.2 version is run after downgrade
ALTER TYPE lcr$_row_record ADD MEMBER FUNCTION 
  get_value (value_type IN VARCHAR2, column_name IN VARCHAR2) 
            RETURN sys.AnyData CASCADE
/

ALTER TYPE lcr$_row_record ADD MEMBER FUNCTION 
  get_values (value_type IN VARCHAR2) RETURN sys.lcr$_row_list CASCADE
/

ALTER TYPE lcr$_row_record ADD MEMBER FUNCTION
  get_lob_information (value_type IN VARCHAR2, column_name IN VARCHAR2) 
                      RETURN NUMBER CASCADE
/

Rem Drop type associated with external table
drop type oracle_datapump force; 

Rem Drop type associated with DBMS_FREQUENT_ITEMSET package
Rem
drop type ora_fi_Imp_t     force; 
drop type ora_fi_Slv_Imp_t force; 
drop library ora_fi_lib;

Rem XMLType downgrade stuff
alter type sys.XMLType
 DROP member function getBlobVal(csid IN number) return BLOB deterministic
                 parallel_enable,
 DROP STATIC FUNCTION createXML (xmlData IN AnyData,
                 schema in varchar2 := NULL, element in varchar2 := NULL, 
                 validated in number := 0) 
     return sys.XMLType deterministic parallel_enable,
 DROP STATIC FUNCTION createXML (xmlData IN bfile, csid IN number,
                 schema IN varchar2,
                 validated IN number := 0, wellformed IN number := 0)
                 return sys.XMLType deterministic parallel_enable,
 DROP STATIC FUNCTION createXML (xmlData IN blob, csid IN number,
                 schema IN varchar2,
                 validated IN number := 0, wellformed IN number := 0) 
                 return sys.XMLType deterministic parallel_enable,
 DROP MEMBER FUNCTION insertXMLBefore(xpath IN VARCHAR2, value_expr IN 
                 XMLType, namespace IN VARCHAR2 := NULL) 
                 return XMLType deterministic parallel_enable,
 DROP MEMBER FUNCTION appendChildXML(xpath IN VARCHAR2, value_expr IN XMLType, 
                 namespace IN VARCHAR2 := NULL) 
                 return XMLType deterministic parallel_enable,
 DROP MEMBER FUNCTION deleteXML(xpath IN VARCHAR2, namespace IN 
                 VARCHAR2 := NULL)
                 return XMLType deterministic parallel_enable,
 DROP constructor function XMLType(xmlData IN blob, csid IN number, 
                               schema IN varchar2 := NULL,
                validated IN number := 0, wellformed IN number := 0) 
    return self as result deterministic parallel_enable,
 DROP constructor function XMLType(xmlData IN bfile, csid IN number, 
                               schema IN varchar2 := NULL,
                validated IN number := 0, wellformed IN number := 0) 
    return self as result deterministic parallel_enable,
 DROP constructor function XMLType (xmlData IN AnyData,
                schema IN varchar2 := NULL, element IN varchar2 := NULL,
                validated IN number := 0) 
    return self as result deterministic parallel_enable
CASCADE;

alter type sys.XMLType replace
  authid current_user as opaque varying (*) 
  using library xmltype_lib 
(
  -- creates the XML data 
  static function createXML (xmlData IN clob) return sys.XMLType deterministic,
  static function createXML (xmlData IN varchar2) return sys.XMLType deterministic,
  -- extract function
  member function extract(xpath IN varchar2) return sys.XMLType deterministic,
  -- existsNode function
  member function existsNode(xpath IN varchar2) return number deterministic,
  -- is it a fragment? 
  member function isFragment return number deterministic,
  -- extraction functions..!  
  -- do we want the encoding to be specified in the result or not ..? 
  member function getClobVal return CLOB deterministic,
  member function getStringVal return varchar2 deterministic,
  member function getNumberVal return number deterministic,
  -- FUNCTIONS NEW IN 9iR2
  -- new versions of createxml
  STATIC FUNCTION createXML (xmlData IN clob, schema IN varchar2,
                 validated IN number := 0, wellformed IN number := 0) 
                 return sys.XMLType deterministic,
  STATIC FUNCTION createXML (xmlData IN varchar2, schema IN varchar2,
                 validated IN number := 0, wellformed IN number := 0) 
                 return sys.XMLType deterministic,
  STATIC FUNCTION createXML (xmlData IN "<ADT_1>",
                 schema IN varchar2 := NULL, element IN varchar2 := NULL,
                 validated IN NUMBER := 0)
    return sys.XMLType deterministic,
  STATIC FUNCTION createXML (xmlData IN SYS_REFCURSOR,
                 schema in varchar2 := NULL, element in varchar2 := NULL, 
                 validated in number := 0) 
     return sys.XMLType deterministic,
  -- new versions of extract and existsnode with nsmap
  MEMBER FUNCTION extract(xpath IN varchar2, nsmap IN VARCHAR2)
    return sys.XMLType deterministic,
  MEMBER FUNCTION existsNode(xpath in varchar2, nsmap in varchar2)
    return number deterministic,
  -- transform function
  member function transform(xsl IN sys.XMLType,
                                parammap in varchar2 := NULL)
    return sys.XMLType deterministic,
  -- conversion functions
  MEMBER PROCEDURE toObject(SELF in sys.XMLType, object OUT "<ADT_1>",
                                schema in varchar2 := NULL,
                                element in varchar2 := NULL),
  -- schema related functions
  MEMBER FUNCTION isSchemaBased return number deterministic,
  MEMBER FUNCTION getSchemaURL return varchar2 deterministic,
  MEMBER FUNCTION getRootElement return varchar2 deterministic,
  -- create schema and nonschema based
  MEMBER FUNCTION createSchemaBasedXML(schema IN varchar2 := NULL)
     return sys.XMLType deterministic,
  -- creates a non schema based document from self
  MEMBER FUNCTION createNonSchemaBasedXML return sys.XMLType deterministic,
  member function getNamespace return varchar2 deterministic,
  -- validates schema based document if VALIDATED flag is false
  member procedure schemaValidate(self IN OUT NOCOPY XMLType),
  -- returns the value of the VALIDATED flag of the document; tells if
  -- a schema based doc. has been actually validated against its schema.
  member function isSchemaValidated return NUMBER deterministic,
  -- sets the VALIDATED flag to user desired value
  member procedure setSchemaValidated(self IN OUT NOCOPY XMLType, 
                                      flag IN BINARY_INTEGER := 1),
  -- checks if doc is conformant to a specified schema; non mutating
  member function isSchemaValid(schurl IN VARCHAR2 := NULL, 
                         elem IN VARCHAR2 := NULL) return NUMBER deterministic,
  -- constructors
  constructor function XMLType(xmlData IN clob, schema IN varchar2 := NULL,
                validated IN number := 0, wellformed IN number := 0) 
    return self as result deterministic,
  constructor function XMLType(xmlData IN varchar2, schema IN varchar2 := NULL
                , validated IN number := 0, wellformed IN number := 0) 
    return self as result deterministic,
  constructor function XMLType (xmlData IN "<ADT_1>",
                schema IN varchar2 := NULL, element IN varchar2 := NULL,
                validated IN number := 0) 
    return self as result deterministic,
  constructor function XMLType(xmlData IN SYS_REFCURSOR,
                schema in varchar2 := NULL, element in varchar2 := NULL, 
                validated in number := 0) 
    return self as result deterministic
);

Rem drop XML_SCHEMA_NAME_PRESENT created for XDB upgrade
drop package XML_SCHEMA_NAME_PRESENT;

Rem URIType downgrade stuff
alter type sys.FtpUriType
 DROP member function getBlob(csid IN number) return BLOB
CASCADE;

alter type sys.HttpUriType
 DROP member function getBlob(csid IN number) return BLOB
CASCADE;

alter type sys.DBUriType
 DROP member function getBlob(csid IN number) return BLOB
CASCADE;

alter type sys.XDBUriType
 DROP member function getBlob(csid IN number) return BLOB
CASCADE;

alter type sys.UriType
 DROP member function getBlob(csid IN number) return BLOB,
 DROP static function makeBlobFromClob(src_clob IN OUT clob, 
                                       csid IN NUMBER := 0) RETURN blob
CASCADE;

Rem=========================================================================
Rem Remove the function for the collect aggregate
Rem=========================================================================

drop function SYS_NT_COLLECT;
drop type SYS_NT_COLLECT_IMP force;

Rem=========================================================================
Rem Remove ODCI TYPE changes 
Rem=========================================================================
drop type ODCINumberList force;
drop type ODCIVarchar2List force;
drop type ODCIDateList force;
drop type ODCIBfileList force;
drop type ODCIRawList force;
drop type ODCIEnv force;
 
Rem ========================================================================
Rem downgrade ANYDATA
Rem ========================================================================

ALTER TYPE ANYDATA
  DROP STATIC FUNCTION ConvertBFloat(fl IN BINARY_FLOAT) return AnyData,
  DROP STATIC FUNCTION ConvertBDouble(dbl IN BINARY_DOUBLE) return AnyData,
  DROP STATIC FUNCTION ConvertURowid(rid IN UROWID) return AnyData,
  DROP MEMBER PROCEDURE SetBFloat(self IN OUT NOCOPY AnyData,
         fl IN BINARY_FLOAT, last_elem IN boolean DEFAULT FALSE),
  DROP MEMBER PROCEDURE SetBDouble(self IN OUT NOCOPY AnyData,
         dbl IN BINARY_DOUBLE, last_elem IN boolean DEFAULT FALSE),
  DROP MEMBER FUNCTION GetBFloat(self IN AnyData, fl OUT NOCOPY BINARY_FLOAT)
      return PLS_INTEGER,
  DROP MEMBER FUNCTION GetBDouble(self IN AnyData,
         dbl OUT NOCOPY BINARY_DOUBLE) return PLS_INTEGER,
  DROP MEMBER FUNCTION AccessBFloat(self IN AnyData) return BINARY_FLOAT
          DETERMINISTIC,
  DROP MEMBER FUNCTION AccessBDouble(self IN AnyData) return BINARY_DOUBLE
          DETERMINISTIC,
  DROP MEMBER FUNCTION AccessURowid(self IN AnyData) return UROWID
          DETERMINISTIC
CASCADE;

ALTER TYPE ANYDATASET
  DROP MEMBER PROCEDURE SetBFloat(self IN OUT NOCOPY AnyDataSet,
      fl IN BINARY_FLOAT, last_elem IN boolean DEFAULT FALSE),
  DROP MEMBER PROCEDURE SetBDouble(self IN OUT NOCOPY AnyDataSet,
      dbl IN BINARY_DOUBLE, last_elem IN boolean DEFAULT FALSE),
  DROP MEMBER PROCEDURE SetURowid(self IN OUT NOCOPY AnyDataSet, rid IN UROWID,
      last_elem IN boolean DEFAULT FALSE),
  DROP MEMBER FUNCTION GetBFloat(self IN AnyDataSet,
      fl OUT NOCOPY BINARY_FLOAT) return PLS_INTEGER,
  DROP MEMBER FUNCTION GetBDouble(self IN AnyDataSet,
      dbl OUT NOCOPY BINARY_DOUBLE) return PLS_INTEGER,
  DROP MEMBER FUNCTION GetURowid(self IN AnyDataSet, rid OUT NOCOPY UROWID)
       return PLS_INTEGER
CASCADE;

Rem=========================================================================
Rem  downgrade system types 
Rem=========================================================================

CREATE OR REPLACE LIBRARY UPGRADE_LIB TRUSTED AS STATIC
/

CREATE OR REPLACE PROCEDURE downgrade_system_types_to_920 IS
LANGUAGE C
NAME "DOWNG_TO_920"
LIBRARY UPGRADE_LIB;
/

execute downgrade_system_types_to_920();

drop procedure downgrade_system_types_to_920;

Rem=========================================================================
Rem Remove changes to other SYS dictionary objects here 
Rem=========================================================================

Rem=========================================================================
REM Default Permanent Tablespace Downgrade
Rem=========================================================================

Rem
Rem Remove TSM tables
Rem
truncate table tsm_hist$;

delete from props$ where name = 'DEFAULT_PERMANENT_TABLESPACE';
commit
/

Rem Truncate DBMS_MONITOR tables
truncate table WRI$_TRACING_ENABLED;
truncate table WRI$_AGGREGATION_ENABLED;

Rem Truncate optimizer stats history tables
truncate table WRI$_OPTSTAT_TAB_HISTORY;
truncate table WRI$_OPTSTAT_IND_HISTORY;
truncate table WRI$_OPTSTAT_HISTHEAD_HISTORY;
truncate table WRI$_OPTSTAT_HISTGRM_HISTORY;
truncate table WRI$_OPTSTAT_AUX_HISTORY;
truncate table WRI$_OPTSTAT_OPR;
truncate table OPTSTAT_HIST_CONTROL$;
drop view DBA_OPTSTAT_OPERATIONS;
drop public synonym DBA_OPTSTAT_OPERATIONS;
drop view ALL_TAB_STATS_HISTORY;
drop public synonym ALL_TAB_STATS_HISTORY;
drop view DBA_TAB_STATS_HISTORY;
drop public synonym DBA_TAB_STATS_HISTORY;
drop view USER_TAB_STATS_HISTORY;
drop public synonym USER_TAB_STATS_HISTORY;

Rem
Rem Truncate all the Workload Repository  
Rem Metadata (WRM$) and History (WRH$) Tables
Rem
truncate table WRH$_DATAFILE;
truncate table WRH$_FILESTATXS;
truncate table WRH$_FILESTATXS_BL;
truncate table WRH$_TEMPFILE;
truncate table WRH$_TEMPSTATXS;
truncate table WRH$_SQLSTAT;
truncate table WRH$_SQLSTAT_BL;
truncate table WRH$_SQLTEXT;
truncate table WRH$_SQL_SUMMARY;
truncate table WRH$_SQL_PLAN;
truncate table WRH$_SQLBIND;
truncate table WRH$_SQLBIND_BL;
truncate table WRH$_OPTIMIZER_ENV;
truncate table WRH$_EVENT_NAME;
truncate table WRH$_SYSTEM_EVENT;
truncate table WRH$_SYSTEM_EVENT_BL;
truncate table WRH$_BG_EVENT_SUMMARY;
truncate table WRH$_WAITSTAT;
truncate table WRH$_WAITSTAT_BL;
truncate table WRH$_ENQUEUE_STAT;
truncate table WRH$_LATCH_NAME;
truncate table WRH$_LATCH;
truncate table WRH$_LATCH_BL;
truncate table WRH$_LATCH_CHILDREN;
truncate table WRH$_LATCH_CHILDREN_BL;
truncate table WRH$_LATCH_PARENT;
truncate table WRH$_LATCH_PARENT_BL;
truncate table WRH$_LATCH_MISSES_SUMMARY;
truncate table WRH$_LATCH_MISSES_SUMMARY_BL;
truncate table WRH$_LIBRARYCACHE;
truncate table WRH$_DB_CACHE_ADVICE;
truncate table WRH$_DB_CACHE_ADVICE_BL;
truncate table WRH$_BUFFER_POOL_STATISTICS;
truncate table WRH$_ROWCACHE_SUMMARY;
truncate table WRH$_ROWCACHE_SUMMARY_BL;
truncate table WRH$_SGA;
truncate table WRH$_SGASTAT;
truncate table WRH$_SGASTAT_BL;
truncate table WRH$_PGASTAT;
truncate table WRH$_RESOURCE_LIMIT;
truncate table WRH$_SHARED_POOL_ADVICE;
truncate table WRH$_SQL_WORKAREA_HISTOGRAM;
truncate table WRH$_PGA_TARGET_ADVICE;
truncate table WRH$_INSTANCE_RECOVERY;
truncate table WRH$_STAT_NAME;
truncate table WRH$_SYSSTAT;
truncate table WRH$_SYSSTAT_BL;
truncate table WRH$_PARAMETER_NAME;
truncate table WRH$_PARAMETER;
truncate table WRH$_PARAMETER_BL;
truncate table WRH$_UNDOSTAT;
truncate table WRH$_SEG_STAT;
truncate table WRH$_SEG_STAT_BL;
truncate table WRH$_SEG_STAT_OBJ;
truncate table WRH$_METRIC_NAME;
truncate table WRH$_SYSMETRIC_HISTORY;
truncate table WRH$_SYSMETRIC_SUMMARY;
truncate table WRH$_SESSMETRIC_HISTORY;
truncate table WRH$_FILEMETRIC_HISTORY;
truncate table WRH$_WAITCLASSMETRIC_HISTORY;
truncate table WRH$_DLM_MISC;
truncate table WRH$_DLM_MISC_BL;
truncate table WRH$_CR_BLOCK_SERVER;
truncate table WRH$_CURRENT_BLOCK_SERVER;
truncate table WRH$_CLASS_CACHE_TRANSFER;
truncate table WRH$_CLASS_CACHE_TRANSFER_BL;
truncate table WRH$_SERVICE_NAME;
truncate table WRH$_SERVICE_STAT;
truncate table WRH$_SERVICE_STAT_BL;
truncate table WRH$_SERVICE_WAIT_CLASS;
truncate table WRH$_SERVICE_WAIT_CLASS_BL;
truncate table WRH$_ACTIVE_SESSION_HISTORY;
truncate table WRH$_ACTIVE_SESSION_HISTORY_BL;
truncate table WRH$_TABLESPACE_STAT;
truncate table WRH$_TABLESPACE_STAT_BL;
truncate table WRH$_LOG;
truncate table WRH$_MTTR_TARGET_ADVICE;
truncate table WRH$_TABLESPACE_SPACE_USAGE;
truncate table WRH$_SYS_TIME_MODEL;
truncate table WRH$_SYS_TIME_MODEL_BL;
truncate table WRH$_OSSTAT;
truncate table WRH$_OSSTAT_BL;
truncate table WRH$_OSSTAT_NAME;
truncate table WRM$_BASELINE;
truncate table WRM$_WR_CONTROL;
truncate table WRM$_SNAPSHOT;
truncate table WRM$_SNAP_ERROR;
delete from WRM$_DATABASE_INSTANCE;

Rem
Rem Truncate the Maintenance Window Schedule (WRI$_SCH) Tables 
Rem
truncate table WRI$_SCH_CONTROL;
truncate table WRI$_SCH_VOTES;

Rem
Rem Truncate the DB Feature Usage (WRI$_DBU) Tables
Rem 
truncate table WRI$_DBU_FEATURE_USAGE;
truncate table WRI$_DBU_FEATURE_METADATA;
truncate table WRI$_DBU_HIGH_WATER_MARK;
truncate table WRI$_DBU_HWM_METADATA;
truncate table WRI$_DBU_USAGE_SAMPLE;

truncate table  cache_stats_0$;
truncate table  cache_stats_1$;

Rem
Rem Drop public plan table, sequence number and synonyms
Rem
drop public synonym plan_table;
truncate table plan_table$;


Rem=========================================================================
Rem Remove all Job Scheduler Views, Synonyms, Packages and Libraries
Rem=========================================================================

-- Scheduler objects are dropped in a section above because of a dependency on
-- partition metadata.

-- Rules and rulesets on the job queue are dropped above because the PL/SQL
-- block refers to streams views which are dropped

-- Drop views and their synonyms
DROP VIEW dba_scheduler_programs;
DROP PUBLIC SYNONYM dba_scheduler_programs;
DROP VIEW user_scheduler_programs;
DROP PUBLIC SYNONYM user_scheduler_programs;
DROP VIEW all_scheduler_programs;
DROP PUBLIC SYNONYM all_scheduler_programs;
DROP VIEW dba_scheduler_jobs;
DROP PUBLIC SYNONYM dba_scheduler_jobs;
DROP VIEW user_scheduler_jobs;
DROP PUBLIC SYNONYM user_scheduler_jobs;
DROP VIEW all_scheduler_jobs;
DROP PUBLIC SYNONYM all_scheduler_jobs;
DROP VIEW dba_scheduler_job_classes;
DROP PUBLIC SYNONYM dba_scheduler_job_classes;
DROP VIEW all_scheduler_job_classes;
DROP PUBLIC SYNONYM all_scheduler_job_classes;
DROP VIEW dba_scheduler_windows;
DROP PUBLIC SYNONYM dba_scheduler_windows;
DROP VIEW all_scheduler_windows;
DROP PUBLIC SYNONYM all_scheduler_windows;
DROP VIEW dba_scheduler_program_args;
DROP PUBLIC SYNONYM dba_scheduler_program_args;
DROP VIEW user_scheduler_program_args;
DROP PUBLIC SYNONYM user_scheduler_program_args;
DROP VIEW all_scheduler_program_args;
DROP PUBLIC SYNONYM all_scheduler_program_args;
DROP VIEW dba_scheduler_job_args;
DROP PUBLIC SYNONYM dba_scheduler_job_args;
DROP VIEW user_scheduler_job_args;
DROP PUBLIC SYNONYM user_scheduler_job_args;
DROP VIEW all_scheduler_job_args;
DROP PUBLIC SYNONYM all_scheduler_job_args;
DROP VIEW dba_scheduler_job_log;
DROP PUBLIC SYNONYM dba_scheduler_job_log;
DROP VIEW dba_scheduler_job_run_details;
DROP PUBLIC SYNONYM dba_scheduler_job_run_details;
DROP VIEW user_scheduler_job_log;
DROP PUBLIC SYNONYM user_scheduler_job_log;
DROP VIEW user_scheduler_job_run_details;
DROP PUBLIC SYNONYM user_scheduler_job_run_details;
DROP VIEW all_scheduler_job_log;
DROP PUBLIC SYNONYM all_scheduler_job_log;
DROP VIEW all_scheduler_job_run_details;
DROP PUBLIC SYNONYM all_scheduler_job_run_details;
DROP VIEW dba_scheduler_window_log;
DROP PUBLIC SYNONYM dba_scheduler_window_log;
DROP VIEW dba_scheduler_window_details;
DROP PUBLIC SYNONYM dba_scheduler_window_details;
DROP VIEW all_scheduler_window_log;
DROP PUBLIC SYNONYM all_scheduler_window_log;
DROP VIEW all_scheduler_window_details;
DROP PUBLIC SYNONYM all_scheduler_window_details;
DROP VIEW dba_scheduler_window_groups;
DROP PUBLIC SYNONYM dba_scheduler_window_groups;
DROP VIEW all_scheduler_window_groups;
DROP PUBLIC SYNONYM all_scheduler_window_groups;
DROP VIEW dba_scheduler_wingroup_members;
DROP PUBLIC SYNONYM dba_scheduler_wingroup_members;
DROP VIEW all_scheduler_wingroup_members;
DROP PUBLIC SYNONYM all_scheduler_wingroup_members;
DROP VIEW dba_scheduler_schedules;
DROP PUBLIC SYNONYM dba_scheduler_schedules;
DROP VIEW user_scheduler_schedules;
DROP PUBLIC SYNONYM user_scheduler_schedules;
DROP VIEW all_scheduler_schedules;
DROP PUBLIC SYNONYM all_scheduler_schedules;
DROP VIEW dba_scheduler_running_jobs;
DROP PUBLIC SYNONYM dba_scheduler_running_jobs;
DROP VIEW user_scheduler_running_jobs;
DROP PUBLIC SYNONYM user_scheduler_running_jobs;
DROP VIEW all_scheduler_running_jobs;
DROP PUBLIC SYNONYM all_scheduler_running_jobs;
DROP VIEW V_$SCHEDULER_RUNNING_JOBS;
DROP PUBLIC SYNONYM V$SCHEDULER_RUNNING_JOBS;
DROP VIEW GV_$SCHEDULER_RUNNING_JOBS;
DROP PUBLIC SYNONYM GV$SCHEDULER_RUNNING_JOBS;

-- Drop other scheduler stuff
DROP FUNCTION scheduler$_argpipe;
DROP FUNCTION scheduler$_jobpipe;
DROP SEQUENCE sys.scheduler$_jobsuffix_s;
DROP SEQUENCE sys.scheduler$_instance_s;
DROP LIBRARY dbms_scheduler_lib;
DROP PACKAGE dbms_scheduler;
DROP PUBLIC SYNONYM dbms_scheduler;
DROP PACKAGE dbms_isched;
TRUNCATE TABLE sys.scheduler$_oldoids;
TRUNCATE TABLE sys.scheduler$_job_chain;
TRUNCATE TABLE sys.scheduler$_chain_varlist;
TRUNCATE TABLE sys.scheduler$_job_step_state;
TRUNCATE TABLE sys.scheduler$_job_step;
DROP SEQUENCE sys.scheduler$_oldoids_s;
DROP LIBRARY scheduler_job_lib;

-- drop scheduler types
drop type SCHEDULER$_JOB_EXTERNAL FORCE;
drop type SCHEDULER$_JOB_RESULTS FORCE;
drop type SCHEDULER$_JOB_FIXED FORCE;
drop type SCHEDULER$_JOB_MUTABLE FORCE;
drop type SCHEDULER$_JOB_VIEW_T FORCE;
drop type SCHEDULER$_JOBARG_VIEW_T FORCE;
drop type SCHEDULER$_JOBARGLST_T FORCE;
drop type SCHEDULER$_JOBLST_T FORCE;
drop type SCHEDULER$_JOB_ARGUMENT_T FORCE;
drop type SCHEDULER$_JOB_T FORCE;
drop type SCHEDULER$_JOB_STEP_TYPE FORCE;

-- Drop new 10gR2 Scheduler types and views
DROP TYPE sys.scheduler$_int_array_type FORCE;
DROP TYPE sys.scheduler$_chain_link_list FORCE;
DROP TYPE sys.scheduler$_chain_link FORCE;
DROP TYPE sys.scheduler$_step_type_list FORCE;
DROP TYPE sys.scheduler$_step_type FORCE;
DROP TYPE sys.scheduler$_rule_list FORCE;
DROP TYPE sys.scheduler$_rule FORCE;
DROP VIEW dba_scheduler_chains;
DROP PUBLIC SYNONYM dba_scheduler_chains;
DROP VIEW user_scheduler_chains;
DROP PUBLIC SYNONYM user_scheduler_chains;
DROP VIEW all_scheduler_chains;
DROP PUBLIC SYNONYM all_scheduler_chains;
DROP VIEW dba_scheduler_chain_rules;
DROP PUBLIC SYNONYM dba_scheduler_chain_rules;
DROP VIEW user_scheduler_chain_rules;
DROP PUBLIC SYNONYM user_scheduler_chain_rules;
DROP VIEW all_scheduler_chain_rules;
DROP PUBLIC SYNONYM all_scheduler_chain_rules;
DROP VIEW dba_scheduler_chain_steps;
DROP PUBLIC SYNONYM dba_scheduler_chain_steps;
DROP VIEW user_scheduler_chain_steps;
DROP PUBLIC SYNONYM user_scheduler_chain_steps;
DROP VIEW all_scheduler_chain_steps;
DROP PUBLIC SYNONYM all_scheduler_chain_steps;
DROP VIEW dba_scheduler_running_chains;
DROP PUBLIC SYNONYM dba_scheduler_running_chains;
DROP VIEW user_scheduler_running_chains;
DROP PUBLIC SYNONYM user_scheduler_running_chains;
DROP VIEW all_scheduler_running_chains;
DROP PUBLIC SYNONYM all_scheduler_running_chains;

-- drop export packages and entries
DROP PACKAGE dbms_sched_main_export;
DROP PUBLIC SYNONYM dbms_sched_main_export;
DROP PACKAGE dbms_sched_program_export;
DROP PUBLIC SYNONYM dbms_sched_program_export;
DROP PACKAGE dbms_sched_job_export;
DROP PUBLIC SYNONYM dbms_sched_job_export;
DROP PACKAGE dbms_sched_window_export;
DROP PUBLIC SYNONYM dbms_sched_window_export;
DROP PACKAGE dbms_sched_wingrp_export;
DROP PUBLIC SYNONYM dbms_sched_wingrp_export;
DROP PACKAGE dbms_sched_class_export;
DROP PUBLIC SYNONYM  dbms_sched_class_export;
DROP PACKAGE dbms_sched_schedule_export;
DROP PUBLIC SYNONYM  dbms_sched_schedule_export;
DROP PACKAGE dbms_sched_export_callouts;
DROP PUBLIC SYNONYM dbms_sched_export_callouts;
DROP PACKAGE dbms_sum_rweq_export;
DROP PUBLIC SYNONYM dbms_sum_rweq_export;
DROP PACKAGE dbms_sum_rweq_export_internal;
DROP PUBLIC SYNONYM dbms_sum_rweq_export_internal;

-- drop 10.2 package dbms_isched_chain_condition here
-- (the 10.2 versions of dbms_scheduler and dbms_isched depend on it)
DROP PACKAGE dbms_isched_chain_condition;

-- Drop materialized view refresh scheduler objects
DROP TYPE SYS.MVRefreshSchedule FORCE;
DROP TYPE SYS.MVScheduleEntry FORCE;
DROP TYPE SYS.MVScheduleDependencies FORCE;

drop procedure ODCITABFUNCINFODUMP;
drop type ODCITABFUNCINFO force;
drop type OLAPRanCurImpl_t force;
drop operator OLAP_EXPRESSION_BOOL force;
drop operator OLAP_EXPRESSION_DATE force;
drop operator OLAP_EXPRESSION_TEXT force;
drop function OLAPRC_TABLE;
drop function OLAP_BOOL_SRF;     
drop function OLAP_DATE_SRF;     
drop function OLAP_TEXT_SRF;     
drop function OLAP_CONDITION;     
drop function ORA_FI_SLVAH;   
drop function ORA_FI_SLVAT;   
drop function SCN_TO_TIMESTAMP;
drop function TIMESTAMP_TO_SCN; 
drop package DBMS_ADVANCED_REWRITE;    
drop package DBMS_ADVISOR;   
drop package DBMS_AQ_BQVIEW;    
drop package DBMS_DBUPGRADE;    
drop package DBMS_DIMENSION;    
drop package DBMS_INTERNAL_SAFE_SCN;   
drop package DBMS_I_INDEX_UTL;
drop package DBMS_REPCAT_EXP;   
drop package DBMS_RULE_EXP_UTLI;
drop package DBMS_SCHEMA_COPY;
drop package DBMS_STREAMS_CDC_ADM;
drop package DBMS_STREAMS_RPC;
drop package DBMS_STREAMS_RPC_INTERNAL;   
drop package DBMS_UPGRADE_INTERNAL;    
drop package DBMS_XMLSTORE;     
drop package PRVT_ACCESS_ADVISOR; 
drop package PRVT_ADVISOR;   
drop package PRVT_DIMENSION_SYS_UTIL;     
drop package PRVT_SYS_TUNE_MVIEW;
drop package PRVT_TUNE_MVIEW;   
drop type body  AGGXMLINPUTTYPE;
drop type body  DBMS_XPLAN_TYPE_TABLE; 
drop type body  DBMS_XPLAN_TYPE;
drop type body  EXPLAINMVARRAYTYPE; 
drop type body  EXPLAINMVMESSAGE;
drop type body  KUPC$Q_MESSAGE;
drop type body  LOCALADT; 
drop type body  MYADT; 
drop type body  ODCIARGDESC;
drop type body  ODCICOLINFO;
drop type body  ODCICOST; 
drop type body  ODCIEXTTABLEINFO;
drop type body  ODCIFUNCCALLINFO;
drop type body  ODCIINDEXINFO;
drop type body  ODCITABFUNCSTATS;
drop type body  REWRITEARRAYTYPE;
drop type body  REWRITEMESSAGE;
drop type body  UROWID; 
drop type body  XMLSEQCUR2_IMP_T;
drop type body  XMLSEQCUR_IMP_T;
drop type body  XMLSEQ_IMP_T;

drop library COLLECTION_LIB;
drop library DBMS_CDCPUB_LIB;
drop library DBMS_FBT_LIB;
drop library DBMS_FILE_TRANSFER_LIB; 
drop library DBMS_KEA_LIB;
drop library DBMS_PROFILER_LIB;
drop library DBMS_RWEQUIV_LIB;
drop library DBMS_SUMA_LIB;
drop library DBMS_TUNEMV_LIB;
drop library DBMS_UPG_LIB;
drop library KGL_TEST_LIB;
drop library KUPP_PROC_LIB;
drop library UPGRADE_LIB;
drop library UTL_SYS_CMP_LIB;
drop library UTL_CMP_LIB;
drop library UTL_I18_LIB;
drop library UTL_LMS_LIB; 

COMMIT;

Rem =========================================================================
Rem downgrade smon_scn_time
Rem =========================================================================

update sys.smon_scn_time 
       set num_mappings = 0, tim_scn_map = NULL, thread = orig_thread;
commit;

Rem =========================================================================
Rem downgrade rules engine objects
Rem =========================================================================

UPDATE sys.rec_tab$ set tab_id = NULL, tab_obj# = NULL;
UPDATE sys.rec_var$ set var_id = NULL, var_dty = NULL, precision# = NULL,
       scale = NULL, maxlen = NULL, charsetid = NULL, charsetform = NULL, 
       toid = NULL, version = NULL, num_attrs = NULL;
commit;
TRUNCATE TABLE sys.rule_set_ee$;
TRUNCATE TABLE sys.rule_set_te$;
TRUNCATE TABLE sys.rule_set_ve$;
TRUNCATE TABLE sys.rule_set_re$;
TRUNCATE TABLE sys.rule_set_ror$;
TRUNCATE TABLE sys.rule_set_fob$;
TRUNCATE TABLE sys.rule_set_nl$;
TRUNCATE TABLE sys.rule_set_rdep$;
TRUNCATE TABLE sys.rule_set_iot$;

Rem =========================================================================
Rem Downgrade OJMS message ADT support
Rem =========================================================================
DROP TYPE BODY aq$_jms_message;
DROP TYPE BODY aq$_jms_bytes_message;
DROP TYPE BODY aq$_jms_stream_message;
DROP TYPE BODY aq$_jms_map_message;

alter type aq$_jms_message
  DROP STATIC FUNCTION construct( text_msg IN  aq$_jms_text_message) 
       RETURN aq$_jms_message,
  DROP STATIC FUNCTION construct( bytes_msg IN  aq$_jms_bytes_message) 
       RETURN aq$_jms_message,
  DROP STATIC FUNCTION construct( stream_msg IN  aq$_jms_stream_message) 
       RETURN aq$_jms_message,
  DROP STATIC FUNCTION construct( map_msg IN  aq$_jms_map_message) 
       RETURN aq$_jms_message,
  DROP STATIC FUNCTION construct( object_msg IN  aq$_jms_object_message) 
       RETURN aq$_jms_message,
  DROP MEMBER FUNCTION cast_to_text_msg 
       RETURN aq$_jms_text_message,
  DROP MEMBER FUNCTION cast_to_bytes_msg 
       RETURN aq$_jms_bytes_message,
  DROP MEMBER FUNCTION cast_to_stream_msg 
       RETURN aq$_jms_stream_message,
  DROP MEMBER FUNCTION cast_to_map_msg 
       RETURN aq$_jms_map_message,
  DROP MEMBER FUNCTION cast_to_object_msg 
       RETURN aq$_jms_object_message
CASCADE;

alter type aq$_jms_bytes_message
  DROP STATIC FUNCTION get_exception 
       RETURN AQ$_JMS_EXCEPTION,
  DROP STATIC PROCEDURE clean_all,
  DROP MEMBER FUNCTION prepare (id IN PLS_INTEGER) 
       RETURN PLS_INTEGER,
  DROP MEMBER FUNCTION clear_body (id IN PLS_INTEGER) 
       RETURN PLS_INTEGER,
  DROP MEMBER FUNCTION get_mode (id IN PLS_INTEGER) 
       RETURN PLS_INTEGER,
  DROP MEMBER PROCEDURE reset (id IN PLS_INTEGER),
  DROP MEMBER PROCEDURE flush (id IN PLS_INTEGER),  
  DROP MEMBER PROCEDURE clean (id IN PLS_INTEGER),
  DROP MEMBER FUNCTION read_boolean (id IN PLS_INTEGER) 
       RETURN BOOLEAN,
  DROP MEMBER FUNCTION read_byte (id IN PLS_INTEGER) 
       RETURN PLS_INTEGER,
  DROP MEMBER FUNCTION read_bytes (
         id IN PLS_INTEGER, value OUT NOCOPY BLOB, length IN PLS_INTEGER) 
       RETURN PLS_INTEGER,
  DROP MEMBER FUNCTION read_char (id IN PLS_INTEGER) 
       RETURN CHAR,
  DROP MEMBER FUNCTION read_double (id IN PLS_INTEGER) 
       RETURN DOUBLE PRECISION,
  DROP MEMBER FUNCTION read_float (id IN PLS_INTEGER) 
       RETURN FLOAT,
  DROP MEMBER FUNCTION read_int (id IN PLS_INTEGER) 
       RETURN PLS_INTEGER,
  DROP MEMBER FUNCTION read_long (id IN PLS_INTEGER) 
       RETURN NUMBER,
  DROP MEMBER FUNCTION read_short (id IN PLS_INTEGER) 
       RETURN PLS_INTEGER,
  DROP MEMBER FUNCTION read_unsigned_byte (id IN PLS_INTEGER) 
       RETURN PLS_INTEGER,
  DROP MEMBER FUNCTION read_unsigned_short (id IN PLS_INTEGER) 
       RETURN PLS_INTEGER,
  DROP MEMBER PROCEDURE read_utf (id IN PLS_INTEGER, value OUT NOCOPY CLOB),
  DROP MEMBER PROCEDURE write_boolean (id IN PLS_INTEGER, value IN BOOLEAN), 
  DROP MEMBER PROCEDURE write_byte (id IN PLS_INTEGER, value IN PLS_INTEGER),
  DROP MEMBER PROCEDURE write_bytes (id IN PLS_INTEGER, value IN RAW),
  DROP MEMBER PROCEDURE write_bytes (id IN PLS_INTEGER, value IN BLOB),
  DROP MEMBER PROCEDURE write_bytes (
         id IN PLS_INTEGER, value IN RAW, 
         offset IN PLS_INTEGER, length IN PLS_INTEGER),
  DROP MEMBER PROCEDURE write_bytes (
         id IN PLS_INTEGER, value IN BLOB,
         offset IN PLS_INTEGER,length IN PLS_INTEGER),
  DROP MEMBER PROCEDURE write_char (id IN PLS_INTEGER, value IN CHAR),
  DROP MEMBER PROCEDURE write_double (
         id IN PLS_INTEGER, value IN DOUBLE PRECISION), 
  DROP MEMBER PROCEDURE write_float (id IN PLS_INTEGER, value IN FLOAT),
  DROP MEMBER PROCEDURE write_int (id IN PLS_INTEGER, value IN PLS_INTEGER),
  DROP MEMBER PROCEDURE write_long (id IN PLS_INTEGER, value IN NUMBER),
  DROP MEMBER PROCEDURE write_short (id IN PLS_INTEGER, value IN PLS_INTEGER),
  DROP MEMBER PROCEDURE write_utf (id IN PLS_INTEGER, value IN VARCHAR2),
  DROP MEMBER PROCEDURE write_utf (id IN PLS_INTEGER, value IN CLOB)
CASCADE;

alter type aq$_jms_stream_message
  DROP STATIC FUNCTION get_exception 
       RETURN AQ$_JMS_EXCEPTION,
  DROP STATIC PROCEDURE clean_all,
  DROP MEMBER FUNCTION prepare (id IN PLS_INTEGER) 
       RETURN PLS_INTEGER,
  DROP MEMBER FUNCTION clear_body (id IN PLS_INTEGER) 
       RETURN PLS_INTEGER,
  DROP MEMBER FUNCTION get_mode (id IN PLS_INTEGER) 
       RETURN PLS_INTEGER,
  DROP MEMBER PROCEDURE reset (id IN PLS_INTEGER),
  DROP MEMBER PROCEDURE flush (id IN PLS_INTEGER), 
  DROP MEMBER PROCEDURE clean (id IN PLS_INTEGER),
  DROP MEMBER PROCEDURE read_object (
         id IN PLS_INTEGER, value OUT NOCOPY AQ$_JMS_VALUE),
  DROP MEMBER FUNCTION read_boolean (id IN PLS_INTEGER) 
       RETURN BOOLEAN,
  DROP MEMBER FUNCTION read_byte (id IN PLS_INTEGER) 
       RETURN PLS_INTEGER,
  DROP MEMBER PROCEDURE read_bytes (id IN PLS_INTEGER, value OUT NOCOPY BLOB),
  DROP MEMBER FUNCTION read_char (id IN PLS_INTEGER) 
       RETURN CHAR,
  DROP MEMBER FUNCTION read_double (id IN PLS_INTEGER) 
       RETURN DOUBLE PRECISION,
  DROP MEMBER FUNCTION read_float (id IN PLS_INTEGER) 
       RETURN FLOAT,
  DROP MEMBER FUNCTION read_int (id IN PLS_INTEGER) 
       RETURN PLS_INTEGER,
  DROP MEMBER FUNCTION read_long (id IN PLS_INTEGER) 
       RETURN NUMBER,
  DROP MEMBER FUNCTION read_short (id IN PLS_INTEGER) 
       RETURN PLS_INTEGER,
  DROP MEMBER PROCEDURE read_string (id IN PLS_INTEGER, value OUT NOCOPY CLOB), 
  DROP MEMBER PROCEDURE write_boolean (id IN PLS_INTEGER, value IN BOOLEAN), 
  DROP MEMBER PROCEDURE write_byte (id IN PLS_INTEGER, value IN PLS_INTEGER),
  DROP MEMBER PROCEDURE write_bytes (id IN PLS_INTEGER, value IN RAW),
  DROP MEMBER PROCEDURE write_bytes (id IN PLS_INTEGER, value IN BLOB),
  DROP MEMBER PROCEDURE write_bytes (
         id IN PLS_INTEGER, value IN RAW,
         offset IN PLS_INTEGER, length IN PLS_INTEGER),
  DROP MEMBER PROCEDURE write_bytes (
         id IN PLS_INTEGER, value IN BLOB,
         offset IN PLS_INTEGER, length IN PLS_INTEGER),
  DROP MEMBER PROCEDURE write_char (id IN PLS_INTEGER, value IN CHAR),
  DROP MEMBER PROCEDURE write_double (
         id IN PLS_INTEGER, value IN DOUBLE PRECISION), 
  DROP MEMBER PROCEDURE write_float (id IN PLS_INTEGER, value IN FLOAT),
  DROP MEMBER PROCEDURE write_int (id IN PLS_INTEGER, value IN PLS_INTEGER),
  DROP MEMBER PROCEDURE write_long (id IN PLS_INTEGER, value IN NUMBER),
  DROP MEMBER PROCEDURE write_short (id IN PLS_INTEGER, value IN PLS_INTEGER),
  DROP MEMBER PROCEDURE write_string (id IN PLS_INTEGER, value IN VARCHAR2),
  DROP MEMBER PROCEDURE write_string (id IN PLS_INTEGER, value IN CLOB)
CASCADE;

alter type aq$_jms_map_message
  DROP STATIC FUNCTION get_exception 
       RETURN AQ$_JMS_EXCEPTION,
  DROP STATIC PROCEDURE clean_all,
  DROP MEMBER FUNCTION prepare (id IN PLS_INTEGER) 
       RETURN PLS_INTEGER,
  DROP MEMBER FUNCTION clear_body (id IN PLS_INTEGER) 
       RETURN PLS_INTEGER,
  DROP MEMBER PROCEDURE flush (id IN PLS_INTEGER),  
  DROP MEMBER PROCEDURE clean (id IN PLS_INTEGER),
  DROP MEMBER FUNCTION get_size (id IN PLS_INTEGER) 
       RETURN PLS_INTEGER,
  DROP MEMBER FUNCTION get_names (id IN PLS_INTEGER) 
       RETURN AQ$_JMS_NAMEARRAY,
  DROP MEMBER FUNCTION get_names (
         id IN PLS_INTEGER, names OUT AQ$_JMS_NAMEARRAY,
         offset IN PLS_INTEGER, length IN PLS_INTEGER) 
       RETURN PLS_INTEGER,
  DROP MEMBER FUNCTION item_exists (id IN PLS_INTEGER, name IN VARCHAR2) 
       RETURN BOOLEAN,
  DROP MEMBER PROCEDURE get_object (
         id IN PLS_INTEGER, name IN VARCHAR2, 
         value OUT NOCOPY AQ$_JMS_VALUE), 
  DROP MEMBER FUNCTION get_boolean (id IN PLS_INTEGER, name IN VARCHAR2) 
       RETURN BOOLEAN,
  DROP MEMBER FUNCTION get_byte (id IN PLS_INTEGER, name IN VARCHAR2) 
       RETURN PLS_INTEGER,
  DROP MEMBER PROCEDURE get_bytes (
         id IN PLS_INTEGER, name IN VARCHAR2, value OUT NOCOPY BLOB),
  DROP MEMBER FUNCTION get_char (id IN PLS_INTEGER, name IN VARCHAR2) 
       RETURN CHAR,
  DROP MEMBER FUNCTION get_double (id IN PLS_INTEGER, name IN VARCHAR2) 
       RETURN DOUBLE PRECISION,
  DROP MEMBER FUNCTION get_float (id IN PLS_INTEGER, name IN VARCHAR2) 
       RETURN FLOAT,
  DROP MEMBER FUNCTION get_int (id IN PLS_INTEGER, name IN VARCHAR2) 
       RETURN PLS_INTEGER,
  DROP MEMBER FUNCTION get_long (id IN PLS_INTEGER, name IN VARCHAR2) 
       RETURN NUMBER,
  DROP MEMBER FUNCTION get_short (id IN PLS_INTEGER, name IN VARCHAR2) 
       RETURN PLS_INTEGER,
  DROP MEMBER PROCEDURE get_string (
         id IN PLS_INTEGER, name IN VARCHAR2, value OUT NOCOPY CLOB), 
  DROP MEMBER PROCEDURE set_boolean (
         id IN PLS_INTEGER, name IN VARCHAR2, value IN BOOLEAN), 
  DROP MEMBER PROCEDURE set_byte (
         id IN PLS_INTEGER, name IN VARCHAR2, value IN PLS_INTEGER),
  DROP MEMBER PROCEDURE set_bytes (
         id IN PLS_INTEGER, name IN VARCHAR2, value IN RAW),
  DROP MEMBER PROCEDURE set_bytes (
         id IN PLS_INTEGER, name IN VARCHAR2, value IN BLOB),
  DROP MEMBER PROCEDURE set_bytes (
         id IN PLS_INTEGER, name IN VARCHAR2, value IN RAW,
         offset IN PLS_INTEGER, length IN PLS_INTEGER),
  DROP MEMBER PROCEDURE set_bytes (
         id IN PLS_INTEGER, name IN VARCHAR2, value IN BLOB,
         offset IN PLS_INTEGER, length IN PLS_INTEGER),
  DROP MEMBER PROCEDURE set_char (
         id IN PLS_INTEGER, name IN VARCHAR2, value IN CHAR),
  DROP MEMBER PROCEDURE set_double (
         id IN PLS_INTEGER, name IN VARCHAR2, value IN DOUBLE PRECISION), 
  DROP MEMBER PROCEDURE set_float (
         id IN PLS_INTEGER, name IN VARCHAR2, value IN FLOAT),
  DROP MEMBER PROCEDURE set_int (
         id IN PLS_INTEGER, name IN VARCHAR2, value IN PLS_INTEGER),
  DROP MEMBER PROCEDURE set_long (
         id IN PLS_INTEGER, name IN VARCHAR2, value IN NUMBER),
  DROP MEMBER PROCEDURE set_short (
         id IN PLS_INTEGER, name IN VARCHAR2, value IN PLS_INTEGER),
  DROP MEMBER PROCEDURE set_string (
         id IN PLS_INTEGER, name IN VARCHAR2, value IN VARCHAR2),
  DROP MEMBER PROCEDURE set_string (
         id IN PLS_INTEGER, name IN VARCHAR2, value IN CLOB)
CASCADE;

DROP PACKAGE dbms_jms_plsql;

DROP TYPE aq$_jms_value FORCE;
DROP TYPE aq$_jms_exception FORCE;
DROP TYPE aq$_jms_namearray FORCE;

Rem =========================================================================
Rem End downgrading OJMS message ADT support
Rem =========================================================================

Rem=========================================================================
Rem Downgrade OJMS array enqueue/dequeue objects and procedures
Rem=========================================================================

DROP PACKAGE dbms_aqjms_internal;

DROP TYPE aq$_jms_messages FORCE;
DROP TYPE aq$_jms_text_messages FORCE;
DROP TYPE aq$_jms_bytes_messages FORCE;
DROP TYPE aq$_jms_stream_messages FORCE;
DROP TYPE aq$_jms_map_messages FORCE;
DROP TYPE aq$_jms_object_messages FORCE;
DROP TYPE aq$_jms_message_properties FORCE;
DROP TYPE aq$_jms_message_property FORCE;
DROP TYPE aq$_jms_array_msgid_info FORCE; 
DROP TYPE aq$_jms_array_msgids FORCE;
DROP TYPE aq$_jms_array_errors FORCE;
DROP TYPE aq$_jms_array_error_info FORCE;

Rem=========================================================================
Rem Downgrade SYS types for AQ notification
Rem=========================================================================

Rem Evolve type  sys.aq$_srvntfn_message

ALTER TYPE sys.aq$_srvntfn_message
DROP ATTRIBUTE(anysub_context, context_type) CASCADE
/

Rem Evolve type sys.aq$_reg_info

DROP TYPE BODY sys.aq$_reg_info
/

ALTER TYPE sys.aq$_reg_info DROP CONSTRUCTOR FUNCTION aq$_reg_info(
  name             VARCHAR2,
  namespace        NUMBER,
  callback         VARCHAR2,
  context          RAW)
  RETURN SELF AS RESULT CASCADE
/

ALTER TYPE sys.aq$_reg_info
DROP ATTRIBUTE (anyctx, ctxtype) CASCADE
/

Rem=========================================================================
Rem Downgrade manageability advisor repository
Rem=========================================================================

DROP VIEW DBA_ADVISOR_ACTIONS;
DROP VIEW DBA_ADVISOR_COMMANDS;
DROP VIEW DBA_ADVISOR_DEF_PARAMETERS;
DROP VIEW DBA_ADVISOR_DEFINITIONS;
DROP VIEW DBA_ADVISOR_DIRECTIVES;
DROP VIEW DBA_ADVISOR_JOURNAL;
DROP VIEW DBA_ADVISOR_LOG;
DROP VIEW DBA_ADVISOR_OBJECT_TYPES;
DROP VIEW DBA_ADVISOR_OBJECTS;
DROP VIEW DBA_ADVISOR_PARAMETERS;
DROP VIEW DBA_ADVISOR_PARAMETERS_PROJ;
DROP VIEW DBA_ADVISOR_FINDINGS;
DROP VIEW DBA_ADVISOR_RATIONALE;
DROP VIEW DBA_ADVISOR_RECOMMENDATIONS;
DROP VIEW DBA_ADVISOR_TASKS;
DROP VIEW DBA_ADVISOR_TEMPLATES;
DROP VIEW DBA_ADVISOR_USAGE;

DROP VIEW DBA_ADVISOR_SQLA_WK_MAP;
DROP VIEW DBA_ADVISOR_SQLA_REC_SUM;
DROP VIEW DBA_ADVISOR_SQLA_WK_STMTS;
DROP VIEW DBA_ADVISOR_SQLW_SUM;
DROP VIEW DBA_ADVISOR_SQLW_TEMPLATES;
DROP VIEW DBA_ADVISOR_SQLW_STMTS;
DROP VIEW DBA_ADVISOR_SQLW_TABLES;
DROP VIEW DBA_ADVISOR_SQLW_TABVOL;
DROP VIEW DBA_ADVISOR_SQLW_COLVOL;
DROP VIEW DBA_ADVISOR_SQLW_PARAMETERS;
DROP VIEW DBA_ADVISOR_SQLW_JOURNAL;

DROP VIEW USER_ADVISOR_ACTIONS;
DROP VIEW USER_ADVISOR_DIRECTIVES;
DROP VIEW USER_ADVISOR_JOURNAL;
DROP VIEW USER_ADVISOR_LOG;
DROP VIEW USER_ADVISOR_OBJECTS;
DROP VIEW USER_ADVISOR_FINDINGS;
DROP VIEW USER_ADVISOR_PARAMETERS;
DROP VIEW USER_ADVISOR_RATIONALE;
DROP VIEW USER_ADVISOR_RECOMMENDATIONS;
DROP VIEW USER_ADVISOR_TASKS;
DROP VIEW USER_ADVISOR_TEMPLATES;

DROP VIEW USER_ADVISOR_SQLA_WK_MAP;
DROP VIEW USER_ADVISOR_SQLA_REC_SUM;
DROP VIEW USER_ADVISOR_SQLA_WK_STMTS;
DROP VIEW USER_ADVISOR_SQLW_SUM;
DROP VIEW USER_ADVISOR_SQLW_TEMPLATES;
DROP VIEW USER_ADVISOR_SQLW_STMTS;
DROP VIEW USER_ADVISOR_SQLW_TABLES;
DROP VIEW USER_ADVISOR_SQLW_TABVOL;
DROP VIEW USER_ADVISOR_SQLW_COLVOL;
DROP VIEW USER_ADVISOR_SQLW_PARAMETERS;
DROP VIEW USER_ADVISOR_SQLW_JOURNAL;

DROP PUBLIC SYNONYM DBA_ADVISOR_ACTIONS;
DROP PUBLIC SYNONYM DBA_ADVISOR_COMMANDS;
DROP PUBLIC SYNONYM DBA_ADVISOR_DEF_PARAMETERS;
DROP PUBLIC SYNONYM DBA_ADVISOR_DEFINITIONS;
DROP PUBLIC SYNONYM DBA_ADVISOR_DIRECTIVES;
DROP PUBLIC SYNONYM DBA_ADVISOR_JOURNAL;
DROP PUBLIC SYNONYM DBA_ADVISOR_LOG;
DROP PUBLIC SYNONYM DBA_ADVISOR_OBJECT_TYPES;
DROP PUBLIC SYNONYM DBA_ADVISOR_OBJECTS;
DROP PUBLIC SYNONYM DBA_ADVISOR_PARAMETERS;
DROP PUBLIC SYNONYM DBA_ADVISOR_PARAMETERS_PROJ;
DROP PUBLIC SYNONYM DBA_ADVISOR_FINDINGS;
DROP PUBLIC SYNONYM DBA_ADVISOR_RATIONALE;
DROP PUBLIC SYNONYM DBA_ADVISOR_RECOMMENDATIONS;
DROP PUBLIC SYNONYM DBA_ADVISOR_TASKS;
DROP PUBLIC SYNONYM DBA_ADVISOR_TEMPLATES;
DROP PUBLIC SYNONYM DBA_ADVISOR_USAGE;

DROP PUBLIC SYNONYM DBA_ADVISOR_SQLA_REC_SUM;
DROP PUBLIC SYNONYM DBA_ADVISOR_SQLA_WK_MAP;
DROP PUBLIC SYNONYM DBA_ADVISOR_SQLA_WK_STMTS;
DROP PUBLIC SYNONYM DBA_ADVISOR_SQLW_STMTS;
DROP PUBLIC SYNONYM DBA_ADVISOR_SQLW_SUM;
DROP PUBLIC SYNONYM DBA_ADVISOR_SQLW_TEMPLATES;
DROP PUBLIC SYNONYM DBA_ADVISOR_SQLW_TABLES;
DROP PUBLIC SYNONYM DBA_ADVISOR_SQLW_TABVOL;
DROP PUBLIC SYNONYM DBA_ADVISOR_SQLW_COLVOL;
DROP PUBLIC SYNONYM DBA_ADVISOR_SQLW_PARAMETERS;
DROP PUBLIC SYNONYM DBA_ADVISOR_SQLW_JOURNAL;

DROP PUBLIC SYNONYM USER_ADVISOR_ACTIONS;
DROP PUBLIC SYNONYM USER_ADVISOR_DIRECTIVES;
DROP PUBLIC SYNONYM USER_ADVISOR_JOURNAL;
DROP PUBLIC SYNONYM USER_ADVISOR_LOG;
DROP PUBLIC SYNONYM USER_ADVISOR_OBJECTS;
DROP PUBLIC SYNONYM USER_ADVISOR_FINDINGS;
DROP PUBLIC SYNONYM USER_ADVISOR_PARAMETERS;
DROP PUBLIC SYNONYM USER_ADVISOR_RATIONALE;
DROP PUBLIC SYNONYM USER_ADVISOR_RECOMMENDATIONS;
DROP PUBLIC SYNONYM USER_ADVISOR_TASKS;
DROP PUBLIC SYNONYM USER_ADVISOR_TEMPLATES;

DROP PUBLIC SYNONYM USER_ADVISOR_SQLA_REC_SUM;
DROP PUBLIC SYNONYM USER_ADVISOR_SQLA_WK_MAP;
DROP PUBLIC SYNONYM USER_ADVISOR_SQLA_WK_STMTS;
DROP PUBLIC SYNONYM USER_ADVISOR_SQLW_STMTS;
DROP PUBLIC SYNONYM USER_ADVISOR_SQLW_SUM;
DROP PUBLIC SYNONYM USER_ADVISOR_SQLW_TEMPLATES;
DROP PUBLIC SYNONYM USER_ADVISOR_SQLW_TABLES;
DROP PUBLIC SYNONYM USER_ADVISOR_SQLW_TABVOL;
DROP PUBLIC SYNONYM USER_ADVISOR_SQLW_COLVOL;
DROP PUBLIC SYNONYM USER_ADVISOR_SQLW_PARAMETERS;
DROP PUBLIC SYNONYM USER_ADVISOR_SQLW_JOURNAL;

DROP PUBLIC SYNONYM DBMS_ADVISOR;

drop TABLE wri$_adv_definitions;

DROP TYPE wri$_adv_hdm_t force;
DROP TYPE wri$_adv_sqlaccess_adv force;
DROP TYPE wri$_adv_tunemview_adv force;
DROP TYPE wri$_adv_workload force;
DROP TYPE wri$_adv_undo_adv force;
DROP TYPE wri$_adv_sqltune force;
DROP TYPE wri$_adv_objspace_ctable_t force;
DROP TYPE wri$_adv_objspace_cindex_t force;
DROP TYPE wri$_adv_objspace_trend_t force;
DROP TYPE wri$_adv_abstract_t force;

  
Rem=========================================================================
Rem END Downgrade manageability advisor repository
Rem=========================================================================

Rem ========================================================================
Rem Downgrade component registry
Rem ========================================================================

Rem first indicate downgrade complete (almost)
BEGIN
   dbms_registry.downgraded('CATALOG','9.2.0');
   dbms_registry.downgraded('CATPROC','9.2.0');
END;
/

Rem new 10.2 table has foreign key reference
DROP TABLE registry$schemas;
ALTER TABLE registry$ DROP CONSTRAINT registry_parent_fk;
ALTER TABLE registry$ DROP CONSTRAINT registry_pk;

ALTER TABLE registry$ ADD CONSTRAINT registry_pk  
      PRIMARY KEY (cid);

ALTER TABLE registry$ ADD CONSTRAINT registry_parent_fk 
      FOREIGN KEY (pid)
      REFERENCES registry$ (cid) 
      ON DELETE CASCADE;

UPDATE registry$ set prv_version = NULL, org_version = NULL, namespace=NULL;

COMMIT;

Rem Block Change Tracking does not exist in 9.2.0.
BEGIN
  EXECUTE IMMEDIATE 'alter database disable block change tracking';
EXCEPTION
   WHEN OTHERS THEN
--    Not enabled
      IF SQLCODE = -19759 THEN NULL;  
      ELSE RAISE;
      END IF;
END;
/ 

Rem Recovery Area does not exist in 9.2.0.
BEGIN
   EXECUTE IMMEDIATE 'alter system set db_recovery_file_dest='''' sid=''*''';
EXCEPTION
   WHEN OTHERS THEN
--    Not enabled
      IF SQLCODE = -02097 THEN NULL;
      ELSE RAISE;
      END IF;
END;
/

Rem=========================================================================
Rem Remove changes to SYSTEM objects here 
Rem=========================================================================

Rem
Rem UPDATE Logical Standby tables
Rem
UPDATE system.logstdby$scn
  SET objname = NULL,
      schema = NULL,
      type = NULL;

Rem
Rem Remove 10.1 skip settings while retaining 9i settings
Rem
DELETE FROM system.logstdby$skip where
  use_like is not null or esc is not null; 

TRUNCATE TABLE system.logstdby$history;

Rem Clear FGR Flag (0x4) by and'ing with 0xfffb = 65531.
Rem We currently do not use as many flags as in a ub2. Still using ub2 mask
Rem is safe. Clearing the FGR dependency and making it a regular dependency
Rem is also safe during a downgrade.

update dependency$ set property = bitand(property, 65531);
update dependency$ set d_attrs = NULL;
update dependency$ set d_reason = NULL;

commit;

REM DROP *_plsql_object_settings views
REM

DROP VIEW dba_plsql_object_settings;
DROP PUBLIC synonym dba_plsql_object_settings;
DROP VIEW user_plsql_object_settings;
DROP PUBLIC synonym user_plsql_object_settings;
DROP VIEW all_plsql_object_settings;
DROP PUBLIC synonym all_plsql_object_settings;

Rem=========================================================================
Rem Drop new packages here
Rem       Any program unit with a dependency on the fixed views above
Rem       must be deleted during downgrade.
Rem       Also, any new program units that will not compile in 9.2.0
Rem       must also be deleted.
Rem=========================================================================

drop package DBMS_REGISTRY_SERVER;
drop package DBMS_STREAMS_PUB_RPC;
drop package DBMS_WARNING_INTERNAL;
 
Rem additional SVRMGMT packages
drop package PRVT_HDM;
drop package DBMS_STATS_INTERNAL;
drop library DBMS_HDM_LIB;
drop package DBMS_SQLTUNE_INTERNAL;
drop package PRVT_UADV;

Rem Drop DBMS_MONITOR package
drop package DBMS_MONITOR;
drop library DBMS_MONITOR_LIB;

Rem Drop SQL Tuning package and the related Export package
drop public synonym dbms_sqltune;
drop package dbms_sqltune;
drop library DBMS_SQLTUNE_LIB;
drop public synonym dbmshsxp;
drop package dbmshsxp;

Rem Drop Access Advisor workload
DROP PACKAGE PRVT_WORKLOAD;
DROP LIBRARY dbms_suma_lib;

Rem  drop DBMS_UNDO_ADV
drop public synonym DBMS_UNDO_ADV;
drop package DBMS_UNDO_ADV;
drop library DBMS_UNDOADV_LIB;

Rem 
Rem Drop the DBMS_WORKLOAD_REPOSITORY package
Rem
drop public synonym DBMS_WORKLOAD_REPOSITORY;
drop package DBMS_WORKLOAD_REPOSITORY;
drop library DBMS_SWRF_LIB;
drop package DBMS_SWRF_INTERNAL;
drop package DBMS_SWRF_REPORT_INTERNAL;

Rem
Rem Drop DB Feature Usage Package
Rem
drop public synonym dbms_feature_usage;
drop package dbms_feature_usage;
drop package dbms_feature_usage_internal;
drop procedure DBMS_FEATURE_PARTITION_USER;
drop procedure DBMS_FEATURE_PARTITION_SYSTEM;
drop procedure DBMS_FEATURE_PLSQL_NATIVE;
drop procedure DBMS_FEATURE_RAC;
drop procedure DBMS_FEATURE_TEST_PROC_1;
drop procedure DBMS_FEATURE_TEST_PROC_2;
drop procedure DBMS_FEATURE_TEST_PROC_3;
drop procedure DBMS_FEATURE_TEST_PROC_4;
drop procedure DBMS_FEATURE_TEST_PROC_5;
drop procedure DBMS_FEATURE_REGISTER_ALLFEAT;
drop procedure DBMS_FEATURE_REGISTER_ALLHWM;

Rem Drop DBMS_SERVER_ALERT Package 
DROP PUBLIC SYNONYM DBMS_SERVER_ALERT;
DROP PACKAGE DBMS_SERVER_ALERT;
DROP LIBRARY DBMS_SVRALRT_LIB;

Rem Drop DBMS_SERVER_ALERT_EXPORT Package
DROP PUBLIC SYNONYM DBMS_SERVER_ALERT_EXPORT;
DROP PACKAGE DBMS_SERVER_ALERT_EXPORT;

Rem Truncate alert related tables
TRUNCATE TABLE sys.wri$_alert_outstanding;
TRUNCATE TABLE sys.wri$_alert_history;
TRUNCATE TABLE sys.wri$_alert_threshold;

Rem Drop server alert related types
DROP TYPE alert_type FORCE;
DROP TYPE threshold_type_set FORCE;
DROP TYPE threshold_type FORCE;
DROP SEQUENCE sys.wri$_alert_sequence;

Rem Drop the DBMS_SERVICE package
drop package dbms_service;

drop package utl_sys_compress;
drop package utl_compress;
drop public synonym utl_compress;
drop package utl_i18n;
drop public synonym utl_i18n;
drop function sys$rawtoany;

drop package UTL_LMS;
DROP PACKAGE DBMS_FREQUENT_ITEMSET;
DROP PACKAGE DBMS_INDEX_UTL;
drop package DBMS_STTS;
DROP PACKAGE DBMS_INTERNAL_LOGSTDBY;

Rem drop plsql profiler package
drop public synonym dbms_profiler;
drop package sys.dbms_profiler;

Rem
Rem drop REPCAT packages
Rem 

drop package dbms_repcat_migration;

Rem
Rem drop STREAMS packages
Rem 

drop package dbms_streams_datapump;
drop package dbms_streams_datapump_internal;
drop package dbms_streams_datapump_util;
drop package dbms_streams_decl;
drop public synonym dbms_streams_auth;
drop package dbms_streams_auth;
drop public synonym dbms_streams_messaging;
drop package dbms_streams_messaging;
drop public synonym dbms_file_transfer;
drop package dbms_file_transfer;
drop package dbms_logrep_util_invok;
drop package dbms_streams_adm_utl_int;
drop package dbms_streams_adm_utl_invok;
drop package dbms_streams_tablespace_adm;
drop public synonym dbms_streams_tablespace_adm;
drop library dbms_streams_tbs_lib;
drop package dbms_streams_tbs_int;
drop package dbms_streams_tbs_int_invok;

drop public synonym dbms_streams_lcr_int;
drop package dbms_streams_lcr_int;

-- Note:  This is a 10gR2 package, but because dbms_streams_adm is called
-- in this script, we must wait to drop this package until after the last
-- call to dbms_streams_adm since dbms_streams_adm could get invalidated.
DROP PACKAGE dbms_streams_mt;


DROP PACKAGE dbms_server_trace;
DROP LIBRARY dbms_server_trace_lib;
DROP PUBLIC SYNONYM dbms_server_trace;
Rem Drop PL/SQL warnings related packages and library
DROP PACKAGE sys.dbms_warning;
drop library dbms_plsql_warning_lib;

drop public synonym dbms_java_dump;
drop package dbms_java_dump;

Rem
Rem  Drop dbms_aq_bqview
Rem
drop package sys.dbms_aq_bqview;

Rem
Rem  Drop dbms_transform_internal
Rem
drop package sys.dbms_transform_internal;

Rem
Rem  Drop dbms_fbt package
Rem
drop public synonym dbms_fbt;
drop package dbms_fbt;
drop type flashbacktblist force;

drop library dbms_dbv_lib;
drop public synonym dbms_dbverify;
drop package dbms_dbverify;

Rem
Rem  Drop dbms_service package
Rem
drop public synonym dbms_service;
drop package dbms_service;

Rem  DROP CDC packages
drop package DBMS_CDC_IPUBLISH;
drop package DBMS_CDC_ISUBSCRIBE;

drop library DBMS_STAT_FUNCS_AUX_LIB;
drop package DBMS_STAT_FUNCS;
drop package DBMS_STAT_FUNCS_AUX;

Rem Drop LDAP packages
drop library DBMS_LDAP_API_LIB;
drop package DBMS_LDAP_API_FFI;
drop package DBMS_LDAP;
drop public synonym DBMS_LDAP;
drop package DBMS_LDAP_UTL;
drop public synonym DBMS_LDAP_UTL;

Rem
Rem Drop UTL_RECOMP objects
Rem
drop table utl_recomp_invalid;
drop table utl_recomp_sorted;
drop table utl_recomp_compiled;
drop table utl_recomp_errors;
drop type utl_recomp_job_list force;
drop view utl_recomp_invalid_db;
drop view utl_recomp_invalid_all;
drop view utl_recomp_invalid_seq;
drop view utl_recomp_invalid_parallel;
drop view utl_recomp_invalid_java_syn;
drop package utl_recomp;

Rem
Rem Drop DBMS_CRYPTO package
Rem
drop package DBMS_CRYPTO;
drop public synonym DBMS_CRYPTO;
drop package DBMS_CRYPTO_FFI;
drop public synonym DBMS_CRYPTO_FFI;

Rem ========================================================================
Rem START Downgrade synonym dependency model
Rem ========================================================================

Rem Remove dependences from synonyms to base objects
begin
   loop
      delete from dependency$
         where d_obj# in (select obj# from obj$ where type# = 5)
           and rownum < 10000;
      exit when sql%rowcount = 0;
      commit;
   end loop;
end;
/

Rem Mark all synonyms valid
update obj$ set status = 1 where type# = 5 and status != 1;
commit;
   
Rem Invalidate views so that they pick up all dependences correctly
update obj$ set status = 6 where status not in (5, 6) and type# = 4;
commit;

Rem ========================================================================
Rem END Downgrade synonym model
Rem ========================================================================

Rem=================================
Rem dbsnmp em package downgrade.
Rem=================================
DROP TABLE dbsnmp.mgmt_response_v$sql_snapshot;
DROP TABLE dbsnmp.mgmt_response_baseline;
DROP TABLE dbsnmp.mgmt_response_capture;
DROP TABLE dbsnmp.mgmt_response_config;
DROP TABLE dbsnmp.mgmt_response_tempt;
DROP SEQUENCE dbsnmp.mgmt_response_capture_id;
DROP SEQUENCE dbsnmp.mgmt_response_snapshot_id;
DROP PACKAGE dbsnmp.mgmt_response;
Rem=================================
Rem END dbsnmp em package downgrade.
Rem=================================

Rem Drop 10.1 DBMS_ASSERT now (after all PL/SQL has been done)
drop public synonym dbms_assert;
drop package dbms_assert;

Rem=========================================================================
Rem Reset compatibility types for downgrade.
Rem=========================================================================

CREATE OR REPLACE LIBRARY DBMS_KCK_LIB TRUSTED AS STATIC;
/
CREATE OR REPLACE PROCEDURE kckreset9 (ver IN BINARY_INTEGER) IS
LANGUAGE C
NAME     "KCK_RESET"
PARAMETERS (ver)
LIBRARY  DBMS_KCK_LIB;
/

BEGIN
   SYS.kckreset9(2);
END;
/

DROP PROCEDURE kckreset9;
DROP LIBRARY DBMS_KCK_LIB;

Rem=========================================================================
Rem BEGIN Setup d_owner# in dependency$ 
Rem=========================================================================

BEGIN                                                                           
 FOR rec IN (SELECT obj#, owner# FROM obj$ ORDER BY obj#) 
  LOOP
   UPDATE dependency$ SET d_owner# = rec.owner# WHERE d_obj# = rec.obj#;
   COMMIT;
  END LOOP;
END;                                                                            
/

Rem Dangling ones, well I can't do anything
Rem UPDATE dependency$ SET d_owner# = 0 WHERE d_owner# = NULL;
Rem COMMIT;

Rem Make d_owner not null back
Rem ALTER TABLE dependency$ MODIFY(d_owner# number NOT NULL);

Rem=========================================================================
Rem END Setup d_owner# in dependency$ 
Rem=========================================================================

Rem ========================================================================
Rem Plan Stability changes
Rem ========================================================================

update outln.ol$nodes set node_name = NULL;
commit;

Rem ========================================================================
Rem Downgrade PL/SQL compiler parameters
Rem ========================================================================

DELETE FROM settings$ WHERE param IN ('plsql_optimize_level',
                                      'plsql_code_type',
                                      'plsql_debug',
                                      'plsql_warnings');
commit;

Rem ========================================================================
Rem Drop the table used in catupgrd.sql to determine if utlip.sql 
Rem needs to be run during upgrade.  For re-upgrade of 9.2, this table
Rem should not exist so that utlip.sql will be run.
Rem ========================================================================

drop table STATS_TARGET$;

Rem ========================================================================
Rem  Move from 10.2 script due to dependencies
Rem ========================================================================

alter table scheduler$_job_run_details modify 
     (cpu_used number);
drop package dbms_propagation_internal;

Rem=========================================================================
Rem BEGIN Truncating audit$ column value
Rem Remove the values set in the 8 padding bytes of audit$ column in 10.1
Rem Use 12th position for Flashback in 10.1, which was unused in 9.2
Rem=========================================================================

commit;
update view$      set audit$ = substr(audit$,1,22) || '--' || substr(audit$,25,8);
update procedure$ set audit$ = substr(audit$,1,32);
update dir$       set audit$ = substr(audit$,1,32);
update type_misc$ set audit$ = substr(audit$,1,32);
update library$   set audit$ = substr(audit$,1,32);
update tab$       set audit$ = substr(audit$,1,22) || '--' || substr(audit$,25,8);
update seq$       set audit$ = substr(audit$,1,32);
update user$      set audit$ = substr(audit$,1,32);
commit;

Rem=========================================================================
Rem END Truncating audit$ column value
Rem DO NOT DO ANY DDL operations on any of the 
Rem table, view, sequence, procedure, directory, type and library objects
Rem after this line !!!!!!!!!!!!!!!!!!!!!!!!!
Rem=========================================================================

Rem =========================================================================
Rem END STAGE 2: downgrade dictionary from 10.1 to 9.2.0
Rem =========================================================================

Rem *************************************************************************
Rem END e0902000.sql
Rem *************************************************************************
