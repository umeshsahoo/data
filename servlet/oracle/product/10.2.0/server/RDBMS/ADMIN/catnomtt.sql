Rem
Rem $Header: catnomtt.sql 11-may-2005.07:11:40 lbarton Exp $
Rem
Rem catnomtt.sql
Rem
Rem Copyright (c) 2002, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catnomtt.sql - Drop Metadata API types
Rem
Rem    DESCRIPTION
Rem      Invoked from both catnomet.sql (for just unrolling the Metadata API)
Rem      and catnodpt.sql for unrolling the entire DataPump.
Rem
Rem    NOTES
Rem      Put Metadata API type drops and obsolete Metadata API views here...
Rem      Put all other Metadata API object drops in catnomta.sql. Put other
Rem      DataPump type drops in catnodpt.sql.
Rem
Rem      Must be kept in sync with catmeta.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    lbarton     05/11/05 - lrg 1852411: drop find_hidden_cont_t, 
Rem                           switch_compiler_t 
Rem    lbarton     05/03/05 - drop sgi types 
Rem    lbarton     06/11/04 - rename 10_0_1 to 10_1 
Rem    jdavison    06/01/04 - Add drop of ku$_10_0_1_col_stats_list_t 
Rem    dgagne      05/18/04 - add drops for 10_0_1 objects 
Rem    htseng      04/15/04 - drop new template partition types 
Rem    htseng      04/12/04 - drop new type ku$_qtab_storage_t 
Rem    dgagne      03/10/04 - drop new types added to catmeta.sql
Rem                         - drop obsoleted views removed from catmeta.sql
Rem    dgagne      01/06/04 - drop new type 
Rem    dgagne      12/03/03 - DROP NEW TYPES AND VIEWS 
Rem    lbarton     10/30/03 - alter_proc_t 
Rem    jdavison    11/10/03 - Drop ku$_find_sgc_t 
Rem    lbarton     07/28/03 - Bug 3045926: ku$_procobj_loc(s)
Rem    lbarton     05/16/03 - bug 2949397: support INDEXTYPE options
Rem    lbarton     05/07/03 - bug 2944274: bitmap join indexes
Rem    gclaborn    05/20/03 - Remove ku$_select_mode_t
Rem    lbarton     03/17/03 - bug 2837703: fix table_data bytes_alloc
Rem    lbarton     02/21/03 - bugfix
Rem    lbarton     01/24/03 - sort types
Rem    lbarton     01/09/03 - ku$_ObjNumSet
Rem    nmanappa    12/27/02 - audit default options
Rem    lbarton     12/11/02 - get more trigger metadata
Rem    lbarton     11/12/02 - procedural object changes
Rem    rvissapr    09/18/02 - fga imp exp
Rem    lbarton     10/09/02 - ku_multi_ddls
Rem    clei        09/04/02 - drop sec relevant cols list type
Rem    lbarton     08/02/02 - transportable export
Rem    htseng      06/25/02 - add post/pre table action support
Rem    lbarton     07/18/02 - callouts
Rem    lbarton     04/26/02 - domain index support
Rem    htseng      05/09/02 - remove some type.
Rem    htseng      04/26/02 - add procedural objects and actions API.
Rem    lbarton     04/16/02 - add DPSTREAM_TABLE object
Rem    htseng      04/16/02 - refresh group/ monitorinf support.
Rem    gclaborn    04/14/02 - gclaborn_catdp
Rem    gclaborn    04/10/02 - Created
Rem

---------------------------------------------
--    Drop Metadata API types.
---------------------------------------------
drop type ku$_ind_part_t force;
drop type ku$_ind_part_list_t force;
drop type ku$_piot_part_t force;
drop type ku$_piot_part_list_t force;
drop type ku$_tab_part_t force;
drop type ku$_tab_part_list_t force;
drop type ku$_tab_subpart_t force;
drop type ku$_tab_subpart_list_t force;
drop type ku$_tab_tsubpart_t force;
drop type ku$_tab_tsubpart_list_t force;
drop type ku$_tab_compart_t force;
drop type ku$_tab_compart_list_t force;
drop type ku$_ind_subpart_t force;
drop type ku$_ind_subpart_list_t force;
drop type ku$_ind_compart_t force;
drop type ku$_ind_compart_list_t force;
drop type ku$_part_col_t force;
drop type ku$_part_col_list_t force;
drop type ku$_partobj_t force;
drop type ku$_tab_partobj_t force;
drop type ku$_ind_partobj_t force;
drop type ku$_schemaobj_t force;
drop type ku$_constraint_col_t force;
drop type ku$_storage_t force;
drop type ku$_tablespace_t force;
drop type ku$_switch_compiler_t force;
drop type ku$_column_t force;
drop type ku$_column_list_t force;
drop type ku$_pcolumn_t force;
drop type ku$_pcolumn_list_t force;
drop type ku$_simple_col_t force;
drop type ku$_simple_col_list_t force;
drop type ku$_prim_column_t force;
drop type ku$_prim_column_list_t force;
drop type ku$_coltype_t force;
drop type ku$_subcoltype_t force;
drop type ku$_subcoltype_list_t force;
drop type ku$_oidindex_t force;
drop type ku$_lobindex_t force;
drop type ku$_lob_t force;
drop type ku$_partlob_t force;
drop type ku$_lobfragindex_t force;
drop type ku$_lobfrag_t force;
drop type ku$_lobfrag_list_t force;
drop type ku$_lobcomppart_t force;
drop type ku$_lobcomppart_list_t force;
drop type ku$_tlob_comppart_t force;
drop type ku$_tlob_comppart_list_t force;
drop type ku$_temp_subpart_t force; 
drop type ku$_temp_subpartdata_t force; 
drop type ku$_temp_subpartlobfrg_t force;
drop type ku$_temp_subpartlob_t force;
drop type ku$_nt_t force;
drop type ku$_hnt_t force;
drop type ku$_iont_t force;
drop type ku$_nt_list_t force;
drop type ku$_nt_parent_t force;
drop type ku$_ov_table_t force;
drop type ku$_constraint_col_list_t force;
drop type ku$_constraint0_t force;
drop type ku$_constraint0_list_t force;
drop type ku$_constraint1_t force;
drop type ku$_constraint1_list_t force;
drop type ku$_constraint2_t force;
drop type ku$_constraint2_list_t force;
drop type ku$_pkref_constraint_list_t force;
drop type ku$_pkref_constraint_t force;
drop type ku$_tabcluster_t force;
drop type ku$_htable_t force;
drop type ku$_phtable_t force;
drop type ku$_fhtable_t force;
drop type ku$_pfhtable_t force;
drop type ku$_iotable_t force;
drop type ku$_ov_tabpart_t force;
drop type ku$_ov_tabpart_list_t force;
drop type ku$_iot_partobj_t force;
drop type ku$_piotable_t force;
drop type ku$_table_objnum_t force;
drop type ku$_exttab_t force;
drop type ku$_extloc_list_t force;
drop type ku$_extloc_t force;
drop type ku$_index_list_t force;
drop type ku$_index_t force;
drop type ku$_index_col_t force;
drop type ku$_index_col_list_t force;
drop type ku$_jijoin_table_t force;
drop type ku$_jijoin_table_list_t force;
drop type ku$_jijoin_t force;
drop type ku$_jijoin_list_t force;
drop type ku$_bytes_alloc_t force;
drop type ku$_tab_bytes_alloc_t force;
drop type ku$_table_data_t force;
drop type ku$_domidx_2ndtab_list_t force;
drop type ku$_domidx_2ndtab_t force;
drop type ku$_domidx_plsql_t force;
drop type ku$_operator_t force;
drop type ku$_oparg_t force;
drop type ku$_oparg_list_t force;
drop type ku$_opbinding_t force;
drop type ku$_opbinding_list_t force;
drop type ku$_opancillary_t force;
drop type ku$_opancillary_list_t force;
drop type ku$_indextype_t force;
drop type ku$_indarraytype_t force;
drop type ku$_indarraytype_list_t force;
drop type ku$_indexop_t force;
drop type ku$_indexop_list_t force;
drop type ku$_source_t force;
drop type ku$_source_list_t force;
drop type ku$_type_t force;
drop type ku$_type_body_t force;
drop type ku$_full_type_t force;
drop type ku$_exp_type_body_t force;
drop type ku$_proc_t force;
drop type ku$_full_pkg_t force;
drop type ku$_exp_pkg_body_t force;
drop type ku$_alter_proc_t force;
drop type ku$_objgrant_t force;
drop type ku$_sysgrant_t force;
drop type ku$_triggercol_t force;
drop type ku$_triggercol_list_t force;
drop type ku$_trigger_t force;
drop type ku$_view_t force;
drop type ku$_outline_hint_t force;
drop type ku$_outline_hint_list_t force;
drop type ku$_outline_node_t force;
drop type ku$_outline_node_list_t force;
drop type ku$_outline_t force;
drop type ku$_synonym_t force;
drop type ku$_directory_t force;
drop type ku$_file_list_t force;
drop type ku$_file_t force;
drop type ku$_rollback_t force;
drop type ku$_dblink_t force;
drop type ku$_trlink_t force;
drop type ku$_fga_rel_col_t force;
drop type ku$_fga_rel_col_list_t force;
drop type ku$_fga_policy_t force;
drop type ku$_rls_sec_rel_col_t force;
drop type ku$_rls_sec_rel_col_list_t force;
drop type ku$_rls_policy_t force;
drop type ku$_rls_group_t force;
drop type ku$_rls_context_t force;
drop type ku$_m_view_h_t force;
drop type ku$_m_view_ph_t force;
drop type ku$_m_view_fh_t force;
drop type ku$_m_view_pfh_t force;
drop type ku$_m_view_iot_t force;
drop type ku$_m_view_piot_t force;
drop type ku$_m_view_t force;
drop type ku$_m_view_srt_list_t force;
drop type ku$_m_view_srt_t force;
drop type ku$_m_view_scm_list_t force;
drop type ku$_m_view_scm_t force;
drop type ku$_m_view_log_h_t force;
drop type ku$_m_view_log_ph_t force;
drop type ku$_m_view_log_fh_t force;
drop type ku$_m_view_log_pfh_t force;
drop type ku$_m_view_log_t force;
drop type ku$_refcol_list_t force;
drop type ku$_refcol_t force;
drop type ku$_slog_list_t force;
drop type ku$_slog_t force;
drop type ku$_constraint_t force;
drop type ku$_ref_constraint_t force;
drop type ku$_find_hidden_cons_t force;
drop type ku$_user_t force;
drop type ku$_library_t force;
drop type ku$_role_t force;
drop type ku$_profile_t force;
drop type ku$_profile_list_t force;
drop type ku$_profile_attr_t force;
drop type ku$_defrole_t force;
drop type ku$_defrole_list_t force;
drop type ku$_defrole_item_t force;
drop type ku$_proxy_t force;
drop type ku$_proxy_role_list_t force;
drop type ku$_proxy_role_item_t force;
drop type ku$_rogrant_t force;
drop type ku$_tsquota_t force;
drop type ku$_resocost_t force;
drop type ku$_resocost_list_t force;
drop type ku$_resocost_item_t force;
drop type ku$_sequence_t force;
drop type ku$_context_t force;
drop type ku$_dimension_t force;
drop type ku$_assoc_t force;
drop type ku$_comment_t force;
drop type ku$_cluster_t force;
drop type ku$_audit_t force;
drop type ku$_audit_obj_t force;
drop type ku$_audit_default_t force;
drop type ku$_java_source_t force;
drop type ku$_qtab_storage_t force;
drop type ku$_queue_table_t force;
drop type ku$_queues_t force;
drop type ku$_qtrans_t force;
drop type ku$_job_t force;
drop type ku$_xmlschema_t force;
drop type ku$_xmlschema_elmt_t force;
drop type ku$_opqtype_t force;
drop type ku$_10_1_ind_stats_t force;
drop type ku$_ind_stats_t force;
drop type ku$_ind_col_list_t force;
drop type ku$_ind_col_t force;
drop type ku$_10_1_spind_stats_list_t force;
drop type ku$_10_1_spind_stats_t force;
drop type ku$_spind_stats_list_t force;
drop type ku$_spind_stats_t force;
drop type ku$_10_1_pind_stats_list_t force;
drop type ku$_10_1_pind_stats_t force;
drop type ku$_pind_stats_list_t force;
drop type ku$_pind_stats_t force;
drop type ku$_10_1_tab_stats_t force;
drop type ku$_tab_stats_t force;
drop type ku$_tab_col_list_t force;
drop type ku$_tab_col_t force;
drop type ku$_10_1_ptab_stats_list_t force;
drop type ku$_10_1_tab_ptab_stats_t force;
drop type ku$_ptab_stats_list_t force;
drop type ku$_tab_ptab_stats_t force;
drop type ku$_cached_stats_t force;
drop type ku$_col_stats_list_t force;
drop type ku$_col_stats_t force;
drop type ku$_10_1_col_stats_t force;
drop type ku$_10_1_col_stats_list_t force;
drop type ku$_histgrm_list_t force;
drop type ku$_histgrm_t force;
drop type ku$_java_resource_t force;
drop type ku$_java_class_t force;
drop type ku$_rmgr_plan_t force;
drop type ku$_rmgr_plan_direct_t force;
drop type ku$_rmgr_consumer_t force;
drop type ku$_rmgr_init_consumer_t force;
drop type ku$_psw_hist_t force;
drop type ku$_psw_hist_list_t force;
drop type ku$_psw_hist_item_t force;
drop type sys.ku$_ErrorLine force;
drop type sys.ku$_ErrorLines force;
drop type sys.ku$_SubmitResult force;
drop type sys.ku$_SubmitResults force;
drop type sys.ku$_ddl force;
drop type sys.ku$_ddls force;
drop type sys.ku$_multi_ddl force;
drop type sys.ku$_multi_ddls force;
drop type sys.ku$_parsed_item force;
drop type sys.ku$_parsed_items force;
drop type ku$_vcnt force;
drop type sys.ku$_ObjNumSet force;
drop type sys.ku$_ObjNumPair force;
drop type sys.ku$_ObjNumPairList force;
drop type sys.ku$_audobj_t force;
drop type sys.ku$_audit_list_t force;
drop type sys.ku$_auddef_t force;
drop type sys.ku$_audit_default_list_t force;
drop type sys.ku$_chunk_t force;
drop type sys.ku$_chunk_list_t force;
drop type sys.ku$_java_t force;
drop type ku$_strmsubcoltype_t force;
drop type ku$_strmsubcoltype_list_t force;
drop type ku$_strmcoltype_t force;
drop type ku$_strmcol_list_t force;
drop type ku$_strmcol_t force;
drop type ku$_strmtable_t force;
drop type ku$_refgroup_t force;
drop type ku$_add_snap_list_t force;
drop type ku$_add_snap_t force;
drop type ku$_monitor_t force;
drop type ku$_objpkg_t force;
drop type ku$_objpkg_privs_t force;
drop type ku$_procobj_t force;
drop type ku$_procobj_grant_t force;
drop type ku$_procobj_audit_t force;
drop type ku$_procdepobj_t force; 
drop type ku$_procdepobjg_t force; 
drop type ku$_procdepobja_t force; 
drop type ku$_procact_t force; 
drop type ku$_procact_schema_t force; 
drop type ku$_procact_instance_t force; 
drop type ku$_procobj_loc force;
drop type ku$_procobj_locs force;
drop type ku$_procobj_line force;
drop type ku$_procobj_lines force;
drop type sys.ku$_taction_t force;
drop type sys.ku$_taction_list_t force;
drop type ku$_prepost_table_t force;
drop type ku$_callout_t force;
drop type ku$_plugts_blk_t force;
drop type ku$_find_sgc_t force;
drop type ku$_sgi_col_list_t force;
drop type ku$_sgi_col_t force;

---------------------------------------------
--    Drop Obsolete Metadata API views.
--
-- NOTE:
--      During an upgrade, catnomtt is called to drop the types, but catnomta
--      is not called.  Views are created using "create or replace" and this
--      will effectively drop the old view and create the new view.  However,
--      views that are no longer needed never get dropped and if the type
--      that describes the object view changes, the view will get recompiled
--      and the recompiliation will fail.  So, instead of having invalid views
--      that are no longer needed, put the drop here. Since catnomtt is always
--      called, the obsolete types will be dropped during an upgrade.
---------------------------------------------
drop view ku$_ptab_col_stats_view;
drop view ku$_tab_col_stats_view;
drop view ku$_histgrm_max_view;
drop view ku$_histgrm_min_view;
