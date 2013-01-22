rem
Rem $Header: catnomta.sql 10-may-2005.13:42:33 lbarton Exp $
Rem
Rem catnomta.sql
Rem
Rem Copyright (c) 2002, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catnomta.sql - Drop all Metadata API objects *EXCEPT* types.
Rem
Rem    DESCRIPTION
Rem      Invoked from catnomet (to just unroll the Metadata API) and from
Rem      catnodp to unroll the entire DataPump
Rem
Rem    NOTES
Rem      
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    lbarton     05/10/05 - lrg 1852411: drop find_sgi(c)_cols views 
Rem    lbarton     05/03/05 - bug 4338348: ku$_10_1_sysgrant_view
Rem    lbarton     07/28/04 - encryption support 
Rem    lbarton     06/11/04 - versioning support for dblink, statistics 
Rem    dgagne      05/18/04 - add drops for 10_0_1 objects 
Rem    lbarton     01/28/04 - dbms_metadata_build and dbms_metadata_dpbuild 
Rem    htseng      04/15/04 - drop new template partition views
Rem    htseng      04/12/04 - drop new view ku$_qtab_storage_view 
Rem    dgagne      03/10/04 - change drops to match catmeta for statistics 
Rem    dgagne      01/06/04 - drop new view 
Rem    dgagne      12/03/03 - DROP NEW TYPES AND VIEWS 
Rem    lbarton     10/30/03 - alter_proc_view, etc. 
Rem    lbarton     09/18/03 - Bug 3130275: domain index fix 
Rem    lbarton     07/28/03 - Bug 3045926: ku$_procobj_loc(s)
Rem    lbarton     05/27/03 - add MV/MVlogs to transportable_export
Rem    lbarton     05/16/03 - bug 2949397: support INDEXTYPE options
Rem    lbarton     05/07/03 - bug 2944274: bitmap join indexes
Rem    gclaborn    05/20/03 - Add ku$_unload_method_view
Rem    lbarton     04/11/03 - ku$_ntable_bytes_alloc_view
Rem    lbarton     03/17/03 - bug 2837703: fix table_data bytes_alloc
Rem    lbarton     01/30/03 - add types to transportable_export
Rem    lbarton     01/24/03 - sort types
Rem    lbarton     01/09/03 - ku$_ObjNumSet
Rem    nmanappa    12/27/02 - audit default options
Rem    lbarton     12/11/02 - get more trigger metadata
Rem    lbarton     11/12/02 - procedural object changes
Rem    lbarton     10/09/02 - ku_multi_ddls
Rem    lbarton     09/20/02 - add DATAPUMP_PATHMAP view
Rem    lbarton     10/01/02 - add DATAPUMP_REMAP_OBJECTS
Rem    lbarton     08/02/02 - transportable export
Rem    htseng      06/25/02 - add post/pre table action support
Rem    lbarton     07/18/02 - callouts
Rem    lbarton     06/05/02 - bugfix
Rem    lbarton     05/13/02 - bugfix
Rem    lbarton     04/26/02 - domain index support
Rem    htseng      04/26/02 - add procedural objects and actions API.
Rem    lbarton     04/16/02 - add DPSTREAM_TABLE object
Rem    htseng      04/16/02 - add refresh group monitoring support.
Rem    gclaborn    04/14/02 - gclaborn_catdp
Rem    gclaborn    04/10/02 - Created
Rem

---------------------------------------------
--      Objects created in catmeta.sql
---------------------------------------------

drop view ku$_schemaobj_view;
drop view ku$_coltype_view;
drop view ku$_subcoltype_view;
drop view ku$_oidindex_view;
drop view ku$_lobindex_view;
drop view ku$_lob_view;
drop view ku$_partlob_view;
drop view ku$_lobfragindex_view;
drop view ku$_sublobfragindex_view;
drop view ku$_lobfrag_view;
drop view ku$_piotlobfrag_view;
drop view ku$_sublobfrag_view;
drop view ku$_lobcomppart_view;
drop view ku$_tlob_comppart_view;
drop view ku$_temp_subpartdata_view;
drop view ku$_temp_subpart_view;
drop view ku$_temp_subpartlob_view;
drop view ku$_temp_subpartlobfrg_view;
drop view ku$_ov_table_view;
drop view ku$_nt_parent_view;
drop view ku$_hnt_view;
drop view ku$_iont_view;
drop view ku$_prim_column_view;
drop view ku$_column_view;
drop view ku$_pcolumn_view;
drop view ku$_constraint_col_view;
drop view ku$_constraint0_view;
drop view ku$_constraint1_view;
drop view ku$_constraint2_view;
drop view ku$_pkref_constraint_view;
drop view ku$_tabcluster_col_view;
drop view ku$_tabcluster_view;
drop view ku$_htable_view;
drop view ku$_phtable_view;
drop view ku$_fhtable_view;
drop view ku$_pfhtable_view;
drop view ku$_iotable_view;
drop view ku$_ov_tabpart_view;
drop view ku$_iot_partobj_view;
drop view ku$_piotable_view;
drop view ku$_10_1_htable_view;
drop view ku$_10_1_phtable_view;
drop view ku$_10_1_fhtable_view;
drop view ku$_10_1_pfhtable_view;
drop view ku$_10_1_iotable_view;
drop view ku$_10_1_piotable_view;
drop view ku$_exttab_view;
drop view ku$_bytes_alloc_view;
drop view ku$_htable_bytes_alloc_view;
drop view ku$_ntable_bytes_alloc_view;
drop view ku$_htable_data_view;
drop view ku$_htpart_bytes_alloc_view;
drop view ku$_htpart_data_view;
drop view ku$_htspart_bytes_alloc_view;
drop view ku$_htspart_data_view;
drop view ku$_ntable_data_view;
drop view ku$_iotable_bytes_alloc_view;
drop view ku$_iotable_data_view;
drop view ku$_iotpart_bytes_alloc_view;
drop view ku$_iotpart_data_view;
drop view ku$_table_data_view;
drop view ku$_10_1_table_data_view;
drop view ku$_tabprop_view;
drop view ku$_mvprop_view;
drop view ku$_mvlprop_view;
drop view ku$_storage_view;
drop view ku$_tablespace_view;
drop view ku$_switch_compiler_view;
drop view ku$_jijoin_table_view;
drop view ku$_jijoin_view;
drop view ku$_index_view;
drop view ku$_2ndtab_info_view;
drop view ku$_domidx_2ndtab_view;
drop view ku$_domidx_plsql_view;
drop view ku$_index_col_view;
drop view ku$_tab_part_view;
drop view ku$_tab_subpart_view;
drop view ku$_tab_tsubpart_view;
drop view ku$_tab_compart_view;
drop view ku$_piot_part_view;
drop view ku$_ind_part_view;
drop view ku$_ind_subpart_view;
drop view ku$_ind_compart_view;
drop view ku$_tab_part_col_view;
drop view ku$_tab_subpart_col_view;
drop view ku$_ind_part_col_view;
drop view ku$_ind_subpart_col_view;
drop view ku$_partobj_view;
drop view ku$_tab_partobj_view;
drop view ku$_ind_partobj_view;
drop view ku$_type_view;
drop view ku$_type_body_view;
drop view ku$_full_type_view;
drop view ku$_exp_type_body_view;
drop view ku$_inc_type_view;
drop view ku$_deptypes_view;
drop view ku$_deptypes_base_view;
drop view ku$_simple_col_view;
drop view ku$_simple_setid_col_view;
drop view ku$_simple_pkref_col_view;
drop view ku$_base_proc_view;
drop view ku$_proc_view;
drop view ku$_func_view;
drop view ku$_pkg_view;
drop view ku$_pkgbdy_view;
drop view ku$_full_pkg_view;
drop view ku$_exp_pkg_body_view;
drop view ku$_alter_proc_view;
drop view ku$_alter_func_view;
drop view ku$_alter_pkgspc_view;
drop view ku$_alter_pkgbdy_view;
drop view ku$_indextype_view;
drop view ku$_indarraytype_view;
drop view ku$_indexop_view;
drop view ku$_operator_view;
drop view ku$_opbinding_view;
drop view ku$_opancillary_view;
drop view ku$_objgrant_view;
drop view ku$_sysgrant_view;
drop view ku$_10_1_sysgrant_view;
drop view ku$_triggercol_view;
drop view ku$_trigger_view;
drop view ku$_view_view;
drop view ku$_view_objnum_view;
drop view ku$_depviews_base_view;
drop view ku$_depviews_view;
drop view ku$_outline_view;
drop view ku$_synonym_view;
drop view ku$_directory_view;
drop view ku$_file_view;
drop view ku$_rollback_view;
drop view ku$_dblink_view;
drop view ku$_10_1_dblink_view;
drop view ku$_trlink_view;
drop view ku$_fga_policy_view;
drop view ku$_rls_policy_view;
drop view ku$_rls_group_view;
drop view ku$_rls_context_view;
drop view ku$_m_view_h_view;
drop view ku$_m_view_ph_view;
drop view ku$_m_view_fh_view;
drop view ku$_m_view_pfh_view;
drop view ku$_m_view_iot_view;
drop view ku$_m_view_piot_view;
drop view ku$_m_view_view;
drop view ku$_m_view_log_h_view;
drop view ku$_m_view_log_ph_view;
drop view ku$_m_view_log_fh_view;
drop view ku$_m_view_log_pfh_view;
drop view ku$_m_view_log_view;
drop view ku$_constraint_view;
drop view ku$_ref_constraint_view;
drop view ku$_find_hidden_cons_view;
drop view ku$_library_view;
drop view ku$_user_view;
drop view ku$_role_view;
drop view ku$_profile_attr_view;
drop view ku$_profile_view;
drop view ku$_defrole_view;
drop view ku$_defrole_list_view;
drop view ku$_rogrant_view;
drop view ku$_proxy_role_list_view;
drop view ku$_proxy_view;
drop view ku$_10_1_proxy_view;
drop view ku$_tsquota_view;
drop view ku$_resocost_list_view;
drop view ku$_resocost_view;
drop view ku$_sequence_view;
drop view ku$_context_view;
drop view ku$_dimension_view;
drop view ku$_assoc_view;
drop view ku$_pwdvfc_view;
drop view ku$_comment_view;
drop view ku$_10_1_comment_view;
drop view ku$_cluster_view;
drop view ku$_audit_view;
drop view ku$_audit_obj_base_view;
drop view ku$_audit_obj_view;
drop view ku$_audit_default_view;
drop view ku$_java_objnum_view;
drop view ku$_java_source_view;
drop view ku$_qtab_storage_view;
drop view ku$_queue_table_view;
drop view ku$_queues_view;
drop view ku$_qtrans_view;
drop view ku$_job_view;
drop view ku$_tts_view;
drop view ku$_tab_ts_view;
drop view ku$_xmlschema_view;
drop view ku$_xmlschema_elmt_view;
drop view ku$_opqtype_view;
drop view ku$_find_sgi_cols_view;
drop view ku$_find_sgc_cols_view;
drop view ku$_find_sgc_view;
drop view ku$_10_1_ind_stats_view;
drop view ku$_ind_stats_view;
drop view ku$_ind_col_view;
drop view ku$_10_1_spind_stats_view;
drop view ku$_spind_stats_view;
drop view ku$_10_1_pind_stats_view;
drop view ku$_pind_stats_view;
drop view ku$_10_1_tab_stats_view;
drop view ku$_tab_stats_view;
drop view ku$_tab_col_view;
drop view ku$_10_1_ptab_stats_view;
drop view ku$_ptab_stats_view;
drop view ku$_10_1_tab_only_stats_view;
drop view ku$_tab_only_stats_view;
drop view ku$_col_stats_view;
drop view ku$_10_1_ptab_col_stats_view;
drop view ku$_10_1_tab_col_stats_view;
drop view ku$_tab_cache_stats_view;
drop view ku$_ind_cache_stats_view;
drop view ku$_10_1_histgrm_min_view;
drop view ku$_10_1_histgrm_max_view;
drop view ku$_histgrm_view;
drop view ku$_java_resource_view ;
drop view ku$_java_class_view ;
drop view ku$_rmgr_plan_view;
drop view ku$_rmgr_plan_direct_view;
drop view ku$_rmgr_consumer_view;
drop view ku$_rmgr_init_consumer_view;
drop view ku$_psw_hist_list_view;
drop view ku$_psw_hist_view;
drop view ku$_strmsubcoltype_view;
drop view ku$_strmcoltype_view;
drop view ku$_strmcol_view;
drop view ku$_strmtable_view;
drop view ku$_refgroup_view;
drop view ku$_add_snap_view;
drop view ku$_monitor_view;
drop view ku$_objpkg_view;
drop view ku$_proc_grant_view;
drop view ku$_proc_audit_view;
drop view ku$_procobj_view;
drop view ku$_procobj_objnum_view;
drop view ku$_procobj_grant_view;
drop view ku$_procobj_audit_view;
drop view ku$_procdepobj_view;
drop view ku$_procdepobj_grant_view;
drop view ku$_procdepobj_audit_view;
drop view ku$_procact_sys_view;
drop view ku$_procact_schema_view;
drop view ku$_procact_instance_view;
drop view ku$_expact_view;
drop view ku$_pre_table_view;
drop view ku$_post_table_view;
drop view ku$_syscallout_view;
drop view ku$_schema_callout_view;
drop view ku$_instance_callout_view;
drop view ku$_tts_ind_view;
drop view ku$_ind_ts_view;
drop view ku$_clu_ts_view;
drop view ku$_mv_ts_view;
drop view ku$_mvl_ts_view;
drop view ku$_tts_mv_view;
drop view ku$_tts_mvl_view;
drop view ku$_plugts_begin_view;
drop view ku$_plugts_tsname_view;
drop view ku$_plugts_checkpl_view;
drop view ku$_plugts_blk_view;
drop view ku$_htable_objnum_view;
drop view ku$_ntable_objnum_view;
drop view ku$_table_objnum_view;
drop view ku$_table_types_view;
drop view ku$_domidx_objnum_view;
drop view ku$_unload_method_view;

----------------------------------------------
--      Catalog views (created in catmeta.sql)
----------------------------------------------

drop view DATAPUMP_PATHS;
drop view DATAPUMP_PATHMAP;
drop view DATAPUMP_TABLE_DATA;
drop view DATAPUMP_OBJECT_CONNECT;
drop view DATAPUMP_DDL_TRANSFORM_PARAMS;
drop view DBA_EXPORT_OBJECTS;
drop view TABLE_EXPORT_OBJECTS;
drop view SCHEMA_EXPORT_OBJECTS;
drop view DATABASE_EXPORT_OBJECTS;
drop view TABLESPACE_EXPORT_OBJECTS;
drop view TRANSPORTABLE_EXPORT_OBJECTS;
drop view DATAPUMP_REMAP_OBJECTS;
drop public synonym DATAPUMP_PATHS;
drop public synonym DATAPUMP_PATHMAP;
drop public synonym DATAPUMP_TABLE_DATA;
drop public synonym DATAPUMP_OBJECT_CONNECT;
drop public synonym DBA_EXPORT_OBJECTS;
drop public synonym TABLE_EXPORT_OBJECTS;
drop public synonym SCHEMA_EXPORT_OBJECTS;
drop public synonym DATABASE_EXPORT_OBJECTS;
drop public synonym TABLESPACE_EXPORT_OBJECTS;
drop public synonym TRANSPORTABLE_EXPORT_OBJECTS;
drop public synonym DATAPUMP_REMAP_OBJECTS;

-------------------------------------------------------------------
--      Objects created in dbmsmeta.sql, dbmsmeti.sql, dbmsmetu.sql
-------------------------------------------------------------------

DROP PUBLIC SYNONYM ku$_ErrorLine;
DROP PUBLIC SYNONYM ku$_ErrorLines;
DROP PUBLIC SYNONYM ku$_SubmitResult;
DROP PUBLIC SYNONYM ku$_SubmitResults;
DROP PUBLIC SYNONYM ku$_ddl;
DROP PUBLIC SYNONYM ku$_ddls;
DROP PUBLIC SYNONYM ku$_multi_ddl;
DROP PUBLIC SYNONYM ku$_multi_ddls;
DROP PUBLIC SYNONYM ku$_parsed_item;
DROP PUBLIC SYNONYM ku$_parsed_items;

DROP PUBLIC SYNONYM ku$_vcnt;
DROP PUBLIC SYNONYM ku$_ObjNumSet;
DROP PUBLIC SYNONYM ku$_ObjNumPair;
DROP PUBLIC SYNONYM ku$_ObjNumPairList;
DROP PUBLIC SYNONYM ku$_audobj_t;
DROP PUBLIC SYNONYM ku$_audit_list_t;
DROP PUBLIC SYNONYM ku$_auddef_t;
DROP PUBLIC SYNONYM ku$_audit_default_list_t;
DROP PUBLIC SYNONYM ku$_taction_t;
DROP PUBLIC SYNONYM ku$_taction_list_t;

DROP PUBLIC SYNONYM ku$_chunk_t;
DROP PUBLIC SYNONYM ku$_chunk_list_t;
DROP PUBLIC SYNONYM ku$_java_t;
DROP PUBLIC SYNONYM ku$_procobj_loc;
DROP PUBLIC SYNONYM ku$_procobj_locs;
DROP PUBLIC SYNONYM ku$_procobj_line;
DROP PUBLIC SYNONYM ku$_procobj_lines;

DROP PUBLIC SYNONYM dbms_metadata;
DROP PUBLIC SYNONYM dbms_metadata_build;
DROP PUBLIC SYNONYM dbms_metadata_dpbuild;
DROP PACKAGE dbms_metadata;
DROP PACKAGE dbms_metadata_int;
DROP PACKAGE dbms_metadata_util;
DROP PACKAGE dbms_metadata_build;
DROP PACKAGE dbms_metadata_dpbuild;
