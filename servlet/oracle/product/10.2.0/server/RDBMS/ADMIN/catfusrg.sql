Rem
Rem $Header: catfusrg.sql 16-may-2005.15:53:07 mlfeng Exp $
Rem
Rem catfusrg.sql
Rem
Rem Copyright (c) 2002, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catfusrg.sql - Catalog registration file for DB Feature Usage clients
Rem
Rem    DESCRIPTION
Rem      Clients of the DB Feature Usage infrastructure can register their
Rem      features and high water marks in this file.
Rem
Rem      It is important to register the following 8 features:
Rem        RAC, Partitioning, OLAP, Data Mining, Oracle Label Security,
Rem        Oracle Advanced Security, Oracle Programmer(?), Oracle Spatial.
Rem
Rem    NOTES
Rem      The tracking for the following advisors is currently disabled:
Rem         Tablespace Advisor - smuthuli
Rem         SGA/Memory Advisor - tlahiri
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mlfeng      05/16/05 - upper to values 
Rem    mlfeng      05/09/05 - fix spatial query 
Rem    rpang       02/18/05 - 4148642: long report in dbms_feature_plsql_native
Rem    pokumar     08/11/04 - change query for Dynamic SGA feature usage
Rem    fayang      08/02/04 - add CSSCAN features usage detection 
Rem    bpwang      08/03/04 - lrg 1726108:  disregard wmsys in streams query
Rem    jywang      08/02/04 - Add temp tbs into DBFUS_LOCALLY_MANAGED_USER_STR 
Rem    ckearney    07/29/04 - fix Olap Cube SQL to match how it is populated 
Rem    pokumar     05/20/04 - change query for Dynamic SGA feature usage 
Rem    veeve       04/28/04 - Populate CLOB column for ADDM
Rem    mrhodes     02/25/04 - OSM->ASM 
Rem    mlfeng      01/14/04 - tune high water mark queries 
Rem    mkeihl      11/10/03 - Bug 3238893: Fix RAC feature usage tracking 
Rem    mlfeng      11/05/03 - add tracking for SQL Tuning Set, AWR 
Rem    gmulagun    10/28/03 - improve performance of audit query 
Rem    mlfeng      10/30/03 - add ASM tracking, services HWM
Rem    mlfeng      10/30/03 - track system/user
Rem    jwlee       10/16/03 - add flashback database feature 
Rem    ckearney    10/08/03 - fix owner of DBA_OLAP2_CUBES
Rem    hbaer       09/30/03 - lrg1578529 
Rem    esoyleme    09/22/03 - change analytic workspace query 
Rem    mlfeng      09/05/03 - change HDM -> ADDM, OMF logic 
Rem    rpang       08/15/03 - Tune SQL for PL/SQL NCOMP sampling
Rem    bpwang      08/08/03 - bug 2993461:  updating streams query
Rem    hbaer       07/31/03 - fix bug 3074607 
Rem    rsahani     07/29/03 - enable SQL TUNING ADVISOR
Rem    myechuri    07/10/03 - change file mapping query
Rem    gngai       07/15/03 - seed db register
Rem    mlfeng      07/02/03 - change high water mark statistics logic
Rem    sbalaram    06/19/03 - Bug 2993464: fix usage query for adv. replication
Rem    tbosman     05/13/03 - add cpu count tracking
Rem    rpang       05/21/03 - Fixed PL/SQL native compilation
Rem    mlfeng      05/02/03 - change unused aux_count from 0 to null
Rem    xcao        05/22/03 - modify Messaging Gateway usage registration
Rem    aime        04/25/03 - aime_going_to_main
Rem    rjanders    03/11/03 - Correct 'standby archival' query for beta1
Rem    mpoladia    03/11/03 - Change audit options query
Rem    dwildfog    03/10/03 - Enable tracking for several advisors
Rem    swerthei    03/07/03 - fix RMAN usage queries
Rem    hbaer       03/07/03 - adjust dbms_feature_part for cdc tables
Rem    mlfeng      02/20/03 - Change name of oracle label security
Rem    wyang       03/06/03 - enable tracking undo advisor
Rem    mlfeng      02/07/03 - Add PL/SQL native and interpreted tracking
Rem    mlfeng      01/31/03 - Add test flag to test features and hwm
Rem    mlfeng      01/23/03 - Updating Feature Names and Descriptions
Rem    mlfeng      01/13/03 - DB Feature Usage
Rem    mlfeng      01/08/03 - Comments for registering DB Features and HWM
Rem    mlfeng      01/08/03 - Added Partitioning procedure and test procs
Rem    mlfeng      11/07/02 - Registering more features
Rem    mlfeng      11/05/02 - Created
Rem


  -- ******************************************************** 
  --  To register a database feature, the following procedure 
  --  is used (A more detailed description of the input
  --  parameters is given in the dbmsfus.sql file):
  --
  --    procedure REGISTER_DB_FEATURE 
  --       ( feature_name           IN VARCHAR2,
  --         install_check_method   IN INTEGER,
  --         install_check_logic    IN VARCHAR2,
  --         usage_detection_method IN INTEGER,
  --         usage_detection_logic  IN VARCHAR2,
  --         feature_description    IN VARCHAR2);
  --
  --  Input arguments:
  --   feature_name           - name of feature
  --   install_check_method   - how to check if the feature is installed.
  --                            currently support the values:
  --                            DBU_INST_ALWAYS_INSTALLED, DBU_INST_OBJECT
  --   install_check_logic    - logic used to check feature installation.
  --                            if method is DBU_INST_ALWAYS_INSTALLED, 
  --                            this argument will take the NULL value.
  --                            if method is DBU_INST_OBJECT, this argument 
  --                            will take the owner and object name for
  --                            an object that must exist if the feature has 
  --                            been installed.
  --   usage_detection_method - how to capture the feature usage, either
  --                            DBU_DETECT_BY_SQL, DBU_DETECT_BY_PROCEDURE, 
  --                            DBU_DETECT_NULL
  --   usage_detection_logic  - logic used to detect usage.  
  --                            If method is DBU_DETECT_BY_SQL, logic will 
  --                            SQL statement used to detect usage.
  --                            If method is DBU_DETECT_BY_PROCEDURE, logic
  --                            will be PL/SQL procedure used to detect usage.
  --                            If method is DBU_DETECT_NULL, this argument
  --                            will not be used. Usage is not tracked.
  --   feature_description    - Description of feature
  --
  --
  --  Examples:
  --
  --  To register the Label Security feature (an install check
  --  is required and the detection method is to use a SQL query), 
  --  the following is used:
  --  
  --  declare
  --   DBFUS_LABEL_SECURITY_STR CONST VARCHAR2(1000) :=
  --       'select count(*), 0, NULL from lbacsys.lbac$polt ' ||
  --        'where owner != ''SA_DEMO''';
  --
  --  begin
  --   dbms_feature_usage.register_db_feature
  --      ('Label Security',
  --       dbms_feature_usage.DBU_INST_OBJECT, 
  --       'LBACSYS.lbac$polt',
  --       dbms_feature_usage.DBU_DETECT_BY_SQL,
  --       DBFUS_LABEL_SECURITY_STR,
  --       'Oracle 9i database security option');
  --  end;
  --
  --  To register the Partitioning feature (an install check is not
  --  required and the detection method is to use a PL/SQL procedure),
  --  the following is used:
  --
  --  declare
  --   DBFUS_PARTN_USER_PROC CONST VARCHAR2(1000) :=
  --       'DBMS_FEATURE_PARTITION_USER';
  --
  --  begin
  --   dbms_feature_usage.register_db_feature
  --      ('Partitioning (user)',
  --       dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
  --       NULL,
  --       dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
  --       DBFUS_PARTN_USER_PROC,
  --       'Partitioning');
  --  end;
  -- ******************************************************** 


  -- ******************************************************** 
  --  To register a high water mark, the following procedure 
  --  is used (A more detailed description of the input
  --  parameters is given in the dbmsfus.sql file):
  -- 
  --    procedure REGISTER_HIGH_WATER_MARK
  --       ( hwm_name   IN VARCHAR2,
  --         hwm_method IN INTEGER,
  --         hwm_logic  IN VARCHAR2,
  --         hwm_desc   IN VARCHAR2);
  --
  --  Input arguments:
  --   hwm_name   - name of high water mark
  --   hwm_method - how to compute the high water mark, either
  --                DBU_HWM_BY_SQL, DBU_HWM_BY_PROCEDURE, or DBU_HWM_NULL
  --   hwm_logic  - logic used for high water mark.
  --                If method is DBU_HWM_BY_SQL, this argument will be SQL 
  --                statement used to compute hwm.
  --                If method is DBU_HWM_BY_PROCEDURE, this argument will be
  --                PL/SQL procedure used to compute hwm.
  --                If method is DBU_HWM_NULL, this argument will not be
  --                used. The high water mark will not be tracked.
  --   hwm_desc   - Description of high water mark
  --
  -- 
  --  Example:
  --
  --  To register the number of user tables (method is SQL), the 
  --  following is used:
  --
  --  declare
  --   HWM_USER_TABLES_STR CONST VARCHAR2(1000) :=
  --       'select count(*) from dba_tables where owner not in ' ||
  --       '(''SYS'', ''SYSTEM'')';
  --
  --  begin
  --   dbms_feature_usage.register_high_water_mark
  --      ('USER_TABLES',
  --       dbms_feature_usage.DBU_HWM_BY_SQL,
  --       HWM_USER_TABLES_STR,
  --       'Number of User Tables');
  --  end;
  -- ******************************************************** 




Rem *********************************************************
Rem Procedures used by the Features to Track Usage
Rem *********************************************************

/***************************************************************
 * DBMS_FEATURE_PARTITION_USER
 *  The procedure to detect usage for Partitioning (user)
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_partition_user
      (is_used OUT number, data_ratio OUT number, clob_rest OUT clob)
AS  
BEGIN
  -- initialize
  is_used := 0;
  data_ratio := 0;
  clob_rest := NULL;

  FOR crec IN (select num||':'||idx_or_tab||':'||ptype||':'||subptype||':'||pcnt||':'||subpcnt||':'||
                      pcols||':'||subpcols||':'||idx_flags||':'||
                      idx_type||':'||idx_uk||'|' my_string
               from (select * from
                     (select /*+ full(o) */ dense_rank() over 
                             (order by  decode(i.bo#,null,p.obj#,i.bo#)) NUM,
                      decode(o.type#,1,'I',2,'T',null)  IDX_OR_TAB, 
                      decode(p.parttype, 1, 'RANGE', 2, 'HASH', 3, 'SYSTEM', 4, 'LIST', 
                                            'UNKNOWN') PTYPE, 
                      decode(mod(p.spare2, 256), 0, null, 2, 'HASH', 3,'SYSTEM', 4, 'LIST', 
                                                    'UNKNOWN') SUBPTYPE,
                      p.partcnt PCNT, 
                      mod(trunc(p.spare2/65536), 65536) SUBPCNT,
                      p.partkeycols PCOLS, 
                      mod(trunc(p.spare2/256), 256) SUBPCOLS,
                      decode(p.flags,0,null,decode(mod(p.flags,3),0,'LP',1,'L',2,'GP'
                                            ,null)) IDX_FLAGS, 
                      decode(i.type#, 1, 'NORMAL'||
                                     decode(bitand(i.property, 4), 0, '', 4, '/REV'),
                      2, 'BITMAP', 3, 'CLUSTER', 4, 'IOT - TOP',
                      5, 'IOT - NESTED', 6, 'SECONDARY', 7, 'ANSI', 8, 'LOB',
                      9, 'DOMAIN') IDX_TYPE,
                      decode(i.property, null,null,
                                         decode(bitand(i.property, 1), 0, 'NONUNIQUE', 
                                         1, 'UNIQUE', 'UNDEFINED')) IDX_UK
                      from partobj$ p, obj$ o, user$ u, ind$ i
                      where o.obj# = i.obj#(+)
                      and   o.owner# = u.user# 
                      and   p.obj# = o.obj# 
                      and   u.name not in ('SYS','SYSTEM','SH')
                      -- fix bug 3074607 - filter on obj$
                      and o.type# in (1,2,19,20,25,34,35)
                      -- exclude change tables
                      and o.obj# not in ( select obj# from cdc_change_tables$)
                      -- exclude local partitioned indexes on change tables
                      and i.bo# not in  ( select obj# from cdc_change_tables$)
                union all
                -- global nonpartitioned indexes on partitioned tables
                select dense_rank() over (order by  decode(i.bo#,null,p.obj#,i.bo#)) NUM,
                       'I' IDX_OR_TAB,
                              null,null,null,null,cols PCOLS,null,
                       'GNP' IDX_FLAGS, 
                       decode(i.type#, 1, 'NORMAL'||
                                      decode(bitand(i.property, 4), 0, '', 4, '/REV'),
                                      2, 'BITMAP', 3, 'CLUSTER', 4, 'IOT - TOP',
                                      5, 'IOT - NESTED', 6, 'SECONDARY', 7, 'ANSI', 8, 'LOB',
                                      9, 'DOMAIN') IDX_TYPE,
                       decode(i.property, null,null,
                                          decode(bitand(i.property, 1), 0, 'NONUNIQUE', 
                                          1, 'UNIQUE', 'UNDEFINED')) IDX_UK
                from partobj$ p, user$ u, obj$ o, ind$ i
                where p.obj# = i.bo#
                -- exclude global nonpartitioned indexes on change tables
                and   i.bo# not in  ( select obj# from cdc_change_tables$)
                and   o.owner# = u.user# 
                and   p.obj# = o.obj# 
                and   p.flags =0
                and   bitand(i.property, 2) <>2
                and   u.name not in ('SYS','SYSTEM','SH'))
                order by num, idx_or_tab desc )) LOOP 

     if (is_used = 0) then
       is_used:=1;
     end if;  

     clob_rest := clob_rest||crec.my_string;
   end loop;

   if (is_used = 1) then
     select pcnt into data_ratio
     from
     (
       SELECT c1, TRUNC((ratio_to_report(sum_blocks) over())*100,2) pcnt  
       FROM
       (
        select decode(p.obj#,null,'REST','PARTTAB') c1, sum(s.blocks) sum_blocks
        from tabpart$ p, seg$ s
        where s.file#=p.file#(+)
        and s.block#=p.block#(+)
        and s.type#=5
        group by  decode(p.obj#,null,'REST','PARTTAB')
        )
      )
      where c1 = 'PARTTAB';
   end if;
end;
/


/***************************************************************
 * DBMS_FEATURE_PARTITION_SYSTEM
 *  The procedure to detect usage for Partitioning (system)
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_partition_system
      (is_used OUT number, data_ratio OUT number, clob_rest OUT clob)
AS  
BEGIN
  -- initialize
  is_used := 0;
  data_ratio := 0;
  clob_rest := NULL;

  FOR crec IN (select num||':'||idx_or_tab||':'||ptype||':'||subptype||':'||pcnt||':'||subpcnt||':'||
                      pcols||':'||subpcols||':'||idx_flags||':'||
                      idx_type||':'||idx_uk||'|' my_string
               from (select * from
                     (select /*+ full(o) */ dense_rank() over 
                             (order by  decode(i.bo#,null,p.obj#,i.bo#)) NUM,
                      decode(o.type#,1,'I',2,'T',null)  IDX_OR_TAB, 
                      decode(p.parttype, 1, 'RANGE', 2, 'HASH', 3, 'SYSTEM', 4, 'LIST', 
                                            'UNKNOWN') PTYPE, 
                      decode(mod(p.spare2, 256), 0, null, 2, 'HASH', 3,'SYSTEM', 4, 'LIST', 
                                                    'UNKNOWN') SUBPTYPE,
                      p.partcnt PCNT, 
                      mod(trunc(p.spare2/65536), 65536) SUBPCNT,
                      p.partkeycols PCOLS, 
                      mod(trunc(p.spare2/256), 256) SUBPCOLS,
                      decode(p.flags,0,null,decode(mod(p.flags,3),0,'LP',1,'L',2,'GP'
                                            ,null)) IDX_FLAGS, 
                      decode(i.type#, 1, 'NORMAL'||
                                     decode(bitand(i.property, 4), 0, '', 4, '/REV'),
                      2, 'BITMAP', 3, 'CLUSTER', 4, 'IOT - TOP',
                      5, 'IOT - NESTED', 6, 'SECONDARY', 7, 'ANSI', 8, 'LOB',
                      9, 'DOMAIN') IDX_TYPE,
                      decode(i.property, null,null,
                                         decode(bitand(i.property, 1), 0, 'NONUNIQUE', 
                                         1, 'UNIQUE', 'UNDEFINED')) IDX_UK
                      from partobj$ p, obj$ o, ind$ i
                      where o.obj# = i.obj#(+)
                      and   p.obj# = o.obj# 
                      -- fix bug 3074607 - filter on obj$
                      and o.type# in (1,2,19,20,25,34,35)
                      -- exclude change tables
                      and o.obj# not in ( select obj# from cdc_change_tables$)
                      -- exclude local partitioned indexes on change tables
                      and i.bo# not in  ( select obj# from cdc_change_tables$)
                union all
                -- global nonpartitioned indexes on partitioned tables
                select dense_rank() over (order by  decode(i.bo#,null,p.obj#,i.bo#)) NUM,
                       'I' IDX_OR_TAB,
                              null,null,null,null,cols PCOLS,null,
                       'GNP' IDX_FLAGS, 
                       decode(i.type#, 1, 'NORMAL'||
                                      decode(bitand(i.property, 4), 0, '', 4, '/REV'),
                                      2, 'BITMAP', 3, 'CLUSTER', 4, 'IOT - TOP',
                                      5, 'IOT - NESTED', 6, 'SECONDARY', 7, 'ANSI', 8, 'LOB',
                                      9, 'DOMAIN') IDX_TYPE,
                       decode(i.property, null,null,
                                          decode(bitand(i.property, 1), 0, 'NONUNIQUE', 
                                          1, 'UNIQUE', 'UNDEFINED')) IDX_UK
                from partobj$ p, obj$ o, ind$ i
                where p.obj# = i.bo#
                -- exclude global nonpartitioned indexes on change tables
                and   i.bo# not in  ( select obj# from cdc_change_tables$)
                and   p.obj# = o.obj# 
                and   p.flags =0
                and   bitand(i.property, 2) <>2)
                order by num, idx_or_tab desc )) LOOP 

     if (is_used = 0) then
       is_used:=1;
     end if;  

     clob_rest := clob_rest||crec.my_string;
   end loop;

   if (is_used = 1) then
     select pcnt into data_ratio
     from
     (
       SELECT c1, TRUNC((ratio_to_report(sum_blocks) over())*100,2) pcnt  
       FROM
       (
        select decode(p.obj#,null,'REST','PARTTAB') c1, sum(s.blocks) sum_blocks
        from tabpart$ p, seg$ s
        where s.file#=p.file#(+)
        and s.block#=p.block#(+)
        and s.type#=5
        group by  decode(p.obj#,null,'REST','PARTTAB')
        )
      )
      where c1 = 'PARTTAB';
   end if;
end;
/


/***************************************************************
 * DBMS_FEATURE_PLSQL_NATIVE
 *  The procedure to detect usage for PL/SQL Native
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_plsql_native (
  o_is_used     OUT           number,
  o_aux_count   OUT           number, -- not used, set to zero
  o_report      OUT           clob )

  --
  -- Find ncomp usage from ncomp_dll$
  --
  -- When >0 NATIVE units, sets "o_is_used=1". Always generates XML report,
  -- for example...
  --
  -- <plsqlNativeReport date ="04-feb-2003 14:34">
  -- <owner name="1234" native="2" interpreted="1"/>
  -- <owner name="1235" native="10" interpreted="1"/>
  -- <owner name="CTXSYS" native="118"/>
  -- ...
  -- <owner name="SYS" native="1292" interpreted="6"/>
  -- <owner name="SYSTEM" native="6"/>
  -- ...
  -- <owner name="XDB" native="176"/>
  -- </plsqlNativeReport>
  --

is
  YES      constant number := 1;
  NO       constant number := 0;
  NEWLINE  constant varchar2(2 char) := '
';
  v_date   constant varchar2(30) := to_char(sysdate, 'dd-mon-yyyy hh24:mi');
  v_report          varchar2(400); -- big enough to hold one "<owner .../>"
begin

  o_is_used   := NO;
  o_aux_count := 0;
  o_report    := '<plsqlNativeReport date ="' || v_date || '">' || NEWLINE;

  -- For security and privacy reasons, we do not collect the names of the
  -- non-Oracle schemas. In the case statement below, we filter the schema
  -- names against v$sysaux_occupants, which contains the list of Oracle
  -- schemas.
  for r in (select (case when u.name in
                              (select distinct schema_name
                                 from v$sysaux_occupants)
                         then u.name
                         else to_char(u.user#)
                    end) name,
              count(o.obj#) total, count(d.obj#) native
              from user$ u, ncomp_dll$ d, obj$ o
              where o.obj# = d.obj# (+)
                and o.type# in (7,8,9,11,12,13,14)
                and u.user# = o.owner#
              group by u.name, u.user#
              order by u.name) loop
    if (r.native > 0) then
      o_is_used := YES;
    end if;
    v_report := '<owner name="'|| r.name || '"';
    if (r.native > 0) then
      v_report := v_report || ' native="' || r.native || '"';
    end if;
    if (r.total > r.native) then
      v_report := v_report || ' interpreted="' || (r.total - r.native) || '"';
    end if;
    v_report := v_report || '/>' || NEWLINE;
    o_report := o_report || v_report;
  end loop;
  o_report := o_report || '</plsqlNativeReport>';
end dbms_feature_plsql_native;
/


/***************************************************************
 * DBMS_FEATURE_RAC
 *  The procedure to detect usage for RAC
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_rac
      (is_used OUT number, nodes OUT number, clob_rest OUT clob)
AS
   cpu_count_current number;
   cpu_stddev_current number;
   rac_active_passive number;
BEGIN
  -- initialize
  clob_rest := NULL;
  nodes := NULL;
  cpu_count_current := NULL;
  cpu_stddev_current := NULL;

  select count(*) into is_used from v$system_parameter where
     name='cluster_database' and value='TRUE';
   -- if RAC is used see if only active/passive or active/active
   if (is_used = 1) then
       select count(*) into nodes from gv$instance;
       select sum(cpu_count_current), round(stddev(cpu_count_current),1)
          into cpu_count_current, cpu_stddev_current from gv$license;
       select value into rac_active_passive from v$system_parameter where
          name='active_instance_count';
       if (rac_active_passive = 1) then
            clob_rest:='usage:Active Passive';
       else clob_rest:='usage:All Active';
       end if;
       clob_rest:=clob_rest||':cpu_count_current:'||cpu_count_current
                ||':cpu_stddev_current:'||cpu_stddev_current;
  end if;
END;
/

  -- ******************************************************** 
  --   TEST_PROC_1
  -- ******************************************************** 

create or replace procedure DBMS_FEATURE_TEST_PROC_1
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
begin
     
    /* doesn't matter what I do here as long as the values get 
     * returned correctly 
     */
    feature_boolean := 0;
    aux_count := 12;
    feature_info := NULL;
    
end;
/

  -- ******************************************************** 
  --   TEST_PROC_2
  -- ******************************************************** 

create or replace procedure DBMS_FEATURE_TEST_PROC_2
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
begin
     
    /* doesn't matter what I do here as long as the values get 
     * returned correctly 
     */
    feature_boolean := 1;
    aux_count := 33;
    feature_info := 'Extra Feature Information for TEST_PROC_2';    
end;
/


-- ******************************************************** 
--   TEST_PROC_3
-- ******************************************************** 

create or replace procedure DBMS_FEATURE_TEST_PROC_3
  ( current_value  OUT  NUMBER) 
AS
begin
     
    /* doesn't matter what I do here as long as the values get 
     * returned correctly.
     */
    current_value := 101;    
end;
/

  -- ******************************************************** 
  --   TEST_PROC_4
  -- ******************************************************** 

create or replace procedure DBMS_FEATURE_TEST_PROC_4
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
begin
    
    /* raise an application error to make sure the error is being
     * handled correctly 
     */     
    raise_application_error(-20020, 'Error for Test Proc 4 ');
    
end;
/

  -- ******************************************************** 
  --   TEST_PROC_5
  -- ******************************************************** 

create or replace procedure DBMS_FEATURE_TEST_PROC_5
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
begin
    
    /* What happens if values are not set? */     
    feature_info := 'TEST PROC 5';
    
end;
/

/*************************************************
 * Database Features Usage Tracking Registration 
 *************************************************/

create or replace procedure DBMS_FEATURE_REGISTER_ALLFEAT
as
begin

  /********************** 
   * Advanced Replication
   **********************/

  declare 
    DBFUS_ADV_REPLICATION_STR CONSTANT VARCHAR2(1000) := 
        'select count(*), NULL, NULL from dba_repcat';

  begin
    dbms_feature_usage.register_db_feature
     ('Advanced Replication',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_ADV_REPLICATION_STR,
      'Advanced Replication has been enabled.');
  end;

  /********************** 
   * Advanced Security
   **********************/

  declare 
    DBFUS_ADV_SECURITY_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from dba_users where ' ||
        'password in (''GLOBAL'', ''EXTERNAL'')';

  begin
    dbms_feature_usage.register_db_feature
     ('Advanced Security',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_ADV_SECURITY_STR,
      'External Global users are configured.');
  end;

  /********************** 
   * Audit Options
   **********************/

  declare 
    DBFUS_AUDIT_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from audit$ where exists ' ||
       '(select 1 from v$parameter where name = ''audit_trail'' and ' ||
          'upper(value) != ''FALSE'' and upper(value) != ''NONE'')';
  begin
    dbms_feature_usage.register_db_feature
     ('Audit Options',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_AUDIT_STR,
      'Audit options in use.');
  end;

  /***********************************************
   * Automatic Database Diagnostic Monitor (ADDM)
   ***********************************************/

  declare 
    DBFUS_ADDM_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, prvt_hdm.db_feature_clob ' ||
        'from wri$_adv_usage u, wri$_adv_definitions a ' ||
        'where a.name = ''ADDM'' and ' ||
              'u.advisor_id = a.id and  ' ||
              'u.num_execs > 0 and ' ||
              'u.last_exec_time >= (select max(last_sample_date) ' ||
                                     'from wri$_dbu_usage_sample)';

  begin
    dbms_feature_usage.register_db_feature
     ('Automatic Database Diagnostic Monitor',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_ADDM_STR,
      'A task for the Automatic Database Diagnostic Monitor ' || 
      'has been executed.');
  end;

  /**********************************************
   * Automatic Segment Space Management (system)
   **********************************************/

  declare 
    DBFUS_BITMAP_SEGMENT_SYS_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from dba_tablespaces where ' ||
        'segment_space_management = ''AUTO''';

  begin
    dbms_feature_usage.register_db_feature
     ('Automatic Segment Space Management (system)',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_BITMAP_SEGMENT_SYS_STR,
      'Extents of locally managed tablespaces are managed ' ||
      'automatically by Oracle.');
  end;

  /********************************************
   * Automatic Segment Space Management (user)
   ********************************************/

  declare 
    DBFUS_BITMAP_SEGMENT_USER_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from dba_tablespaces where ' ||
        'segment_space_management = ''AUTO'' and ' ||
        'tablespace_name not in (''SYSTEM'', ''SYSAUX'')';

  begin
    dbms_feature_usage.register_db_feature
     ('Automatic Segment Space Management (user)',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_BITMAP_SEGMENT_USER_STR,
      'Extents of locally managed user tablespaces are managed ' ||
      'automatically by Oracle.');
  end;

  /*********************************
   * Automatic SQL Execution Memory
   *********************************/

  declare 
    DBFUS_AUTO_PGA_STR CONSTANT VARCHAR2(1000) := 
      'select decode(pga + wap, 2, 1, 0), pga_aux + wap_aux, NULL from ' ||
        '(select count(*) pga, 0 pga_aux from v$system_parameter ' ||
          'where name = ''pga_aggregate_target'' and value != ''0''), ' ||
        '(select count(*) wap, 0 wap_aux from v$system_parameter ' ||
          'where name = ''workarea_size_policy'' and upper(value) = ''AUTO'')';

  begin
    dbms_feature_usage.register_db_feature
     ('Automatic SQL Execution Memory',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_AUTO_PGA_STR,
      'Sizing of work areas for all dedicated sessions (PGA) is automatic.');
  end;

  /******************************** 
   * Automatic Storage Management
   ******************************/

  declare 
    DBFUS_AUT_STORAGE_MNGT_STR CONSTANT VARCHAR2(1000) := 
       'select count(*), NULL, NULL from V$ASM_CLIENT';
 
  begin
    dbms_feature_usage.register_db_feature
     ('Automatic Storage Manager',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_AUT_STORAGE_MNGT_STR,
      'Automatic Storage Management has been enabled');
  end;

  /***************************
   * Automatic Undo Management
   ***************************/

  declare 
    DBFUS_AUM_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from v$system_parameter where ' ||
        'name = ''undo_management'' and upper(value) = ''AUTO''';

  begin
    dbms_feature_usage.register_db_feature
     ('Automatic Undo Management',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_AUM_STR,
      'Oracle automatically manages undo data using an UNDO tablespace.');
  end;

  /**************************************
   * Automatic Workload Repository (AWR)
   **************************************/

  declare 
    DBFUS_AWR_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL ' ||
        'from wrm$_snapshot ' ||
        'where dbid = (select dbid from v$database) ' ||
          'and status = 0 ' ||
          'and bitand(snap_flag, 1) = 1 ' ||
          'and end_interval_time > (select max(last_sample_date) ' ||
                                     'from wri$_dbu_usage_sample)'; 

  begin
    dbms_feature_usage.register_db_feature
     ('Automatic Workload Repository',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_AWR_STR,
      'A manual Automatic Workload Repository (AWR) snapshot was taken ' ||
      'in the last sample period.');
  end;

  /************************ 
   * Block Change Tracking
   ************************/

  declare 
    DBFUS_BLOCK_CHANGE_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL ' ||
        'from v$block_change_tracking where status = ''ENABLED''';

  begin
    dbms_feature_usage.register_db_feature
     ('Change-Aware Incremental Backup',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_BLOCK_CHANGE_STR,
      'Track blocks that have changed in the database.');
  end;

  /********************** 
   * Client Identifier
   **********************/

  declare 
    DBFUS_CLIENT_IDN_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from v$session ' ||
      'where client_identifier is not null';

  begin
    dbms_feature_usage.register_db_feature
     ('Client Identifier',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_CLIENT_IDN_STR,
      'Application User Proxy Authentication: Client Identifier is ' ||
      'used at this specific time.');
  end;

  /****************************** 
   * CSSCAN - character set scan
   *******************************/

  declare 
    DBFUS_CSSCAN_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), null, null  from ' ||
      'csmig.csm$parameters c ' ||
      'where c.name=''TIME_START'' and ' ||
      'to_date(c.value, ''YYYY-MM-DD HH24:MI:SS'') ' ||
      '>= (select max(last_sample_date) from wri$_dbu_usage_sample) ' ;

  begin
    dbms_feature_usage.register_db_feature
     ('CSSCAN',
      dbms_feature_usage.DBU_INST_OBJECT, 
      'CSMIG.csm$parameters',
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_CSSCAN_STR,
      'Oracle Database has been scanned at least once for character set:' ||
      'CSSCAN has been run at least once.');
  end;
  
 
  /****************************** 
   * Character semantics turned on
   *******************************/

  declare 
    DBFUS_CHAR_SEMANTICS_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), null, null  from ' ||
      'sys.v$nls_parameters where ' ||
      'parameter=''NLS_LENGTH_SEMANTICS'' and upper(value)=''CHAR'' ';

  begin
    dbms_feature_usage.register_db_feature
     ('Character Semantics',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_CHAR_SEMANTICS_STR,
      'Character length semantics is used in Oracle Database');
  end;
  
  /**************************** 
   * Character Set of Database
   ****************************/

  declare 
    DBFUS_CHAR_SET_STR CONSTANT VARCHAR2(1000) := 
      'select 1, null, value  from ' ||
      'sys.v$nls_parameters where ' ||
      'parameter=''NLS_CHARACTERSET'' ';

  begin
    dbms_feature_usage.register_db_feature
     ('Character Set',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_CHAR_SET_STR,
      'Character set is used in Oracle Database');
  end;
  

  /********************** 
   * Data Guard
   **********************/

  declare 
    DBFUS_DATA_GUARD_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from v$archive_dest ' ||
        'where status = ''VALID'' and target = ''STANDBY''';

  begin
    dbms_feature_usage.register_db_feature
     ('Data Guard',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_DATA_GUARD_STR,
      'Data Guard, a set of services, is being used to create, ' ||
      'maintain, manage, and monitor one or more standby databases.');
  end;

  /********************** 
   * Data Guard Broker
   **********************/

  declare 
    DBFUS_DG_BROKER_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from v$system_parameter ' ||
        'where name = ''dg_broker_start'' and upper(value) = ''TRUE''';

  begin
    dbms_feature_usage.register_db_feature
     ('Data Guard Broker',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_DG_BROKER_STR,
      'Data Guard Broker, the framework that handles the creation ' ||
      'maintenance, and monitoring of Data Guard, is being used');
  end;

  /********************** 
   * Data Mining
   **********************/

  declare 
    DBFUS_ODM_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from dba_registry ' ||
        'where comp_id = ''ODM'' and status != ''REMOVED'' and ' ||
        'exists (select 1 from dmsys.dm$object) and ' ||
        'exists (select 1 from dmsys.dm$task) and ' ||
        'exists (select 1 from dmsys.dm$model) and ' ||
        'exists (select 1 from dmsys.dm$result)';

  begin
    dbms_feature_usage.register_db_feature
     ('Data Mining',
      dbms_feature_usage.DBU_INST_OBJECT, 
      'DMSYS.dm$object',
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_ODM_STR,
      'Oracle Data Mining option is being used.');
  end;

  /********************** 
   * Dynamic SGA
   **********************/

  declare 
    DBFUS_DYN_SGA_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from v$sga_resize_ops where ' ||
      'oper_type in (''GROW'', ''SHRINK'')';

  begin
    dbms_feature_usage.register_db_feature
     ('Dynamic SGA',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_DYN_SGA_STR,
      'The Oracle SGA has been dynamically resized through an ' ||
      'ALTER SYSTEM SET statement.');
  end;

  /********************** 
   * File Mapping
   **********************/

  declare 
    DBFUS_FILE_MAPPING_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from v$system_parameter where ' ||
        'name = ''file_mapping'' and upper(value) = ''TRUE'' and ' ||
        'exists (select 1 from v$map_file)';

  begin
    dbms_feature_usage.register_db_feature
     ('File Mapping',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_FILE_MAPPING_STR,
      'File Mapping, the mechanism that shows a complete mapping ' ||
      'of a file to logical volumes and physical devices, is ' ||
      'being used.');
  end;


  /***************************
   * Flashback Database
   ***************************/

  declare 
    DBFUS_FB_DB_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from v$database where ' ||
        'flashback_on = ''YES''';

  begin
    dbms_feature_usage.register_db_feature
     ('Flashback Database',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_FB_DB_STR,
      'Flashback Database, a rewind button for the database, is enabled');
  end;



  /******************************
   * Internode Parallel Execution
   ******************************/

  declare 
    DBFUS_INODE_PRL_EXEC_STR CONSTANT VARCHAR2(1000) := 
      'select value, NULL, NULL from v$sysstat ' ||
        'where name = ''PX remote messages sent''';

  begin
    dbms_feature_usage.register_db_feature
     ('Internode Parallel Execution',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_INODE_PRL_EXEC_STR,
      'Internode Parallel Execution is being used.');
  end;

  /********************** 
   * Label Security
   **********************/

  declare 
    DBFUS_LABEL_SECURITY_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from lbacsys.lbac$polt ' ||
       'where owner != ''SA_DEMO''';

  begin
    dbms_feature_usage.register_db_feature
     ('Label Security',
      dbms_feature_usage.DBU_INST_OBJECT, 
      'LBACSYS.lbac$polt',
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_LABEL_SECURITY_STR,
      'Oracle Label Security, that enables label-based access control ' ||
      'Oracle applications, is being used.');
  end;

  /***************************************
   * Locally Managed Tablespaces (system)
   ***************************************/

  declare 
    DBFUS_LOCALLY_MANAGED_SYS_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from dba_tablespaces where ' ||
        'extent_management = ''LOCAL''';

  begin
    dbms_feature_usage.register_db_feature
     ('Locally Managed Tablespaces (system)',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_LOCALLY_MANAGED_SYS_STR,
      'There exists tablespaces that are locally managed in ' ||
      'the database.');
  end;

  /*************************************
   * Locally Managed Tablespaces (user)
   *************************************/

  declare 
    DBFUS_LOCALLY_MANAGED_USER_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from dba_tablespaces where ' ||
        'extent_management = ''LOCAL'' and ' ||
        'tablespace_name not in (''SYSTEM'', ''SYSAUX'',''TEMP'')';

  begin
    dbms_feature_usage.register_db_feature
     ('Locally Managed Tablespaces (user)',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_LOCALLY_MANAGED_USER_STR,
      'There exists user tablespaces that are locally managed in ' ||
      'the database.');
  end;

  /******************************
   * Messaging Gateway
   ******************************/

  declare
    DBFUS_MSG_GATEWAY_STR CONSTANT VARCHAR2(1000) :=
      'select count(*), NULL, NULL from dba_registry ' ||
        'where comp_id = ''MGW'' and status != ''REMOVED'' and ' ||
        'exists (select 1 from mgw$_links)';

  begin
    dbms_feature_usage.register_db_feature
     ('Messaging Gateway',
      dbms_feature_usage.DBU_INST_OBJECT,
      'SYS.MGW$_GATEWAY',
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_MSG_GATEWAY_STR,
      'Messaging Gateway, that enables communication between non-Oracle ' ||
      'messaging systems and Advanced Queuing (AQ), link configured.');
  end;

  /********************** 
   * MTTR Advisor
   **********************/

  declare 
    DBFUS_MTTR_ADV_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from v$statistics_level where ' ||
        'statistics_name = ''MTTR Advice'' and ' ||
        'system_status = ''ENABLED'' and ' ||
        'exists (select 1 from v$instance_recovery ' ||
                  'where target_mttr != 0) and ' ||
        'exists (select 1 from v$mttr_target_advice ' ||
                  'where advice_status = ''ON'')';

  begin
    dbms_feature_usage.register_db_feature
     ('MTTR Advisor',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_MTTR_ADV_STR,
      'Mean Time to Recover Advisor is enabled.');
  end;

  /*********************** 
   * Multiple Block Sizes
   ***********************/

  declare 
    DBFUS_MULT_BLOCK_SIZE_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from v$system_parameter where ' ||
        'name like ''db_%_cache_size'' and value != ''0''';

  begin
    dbms_feature_usage.register_db_feature
     ('Multiple Block Sizes',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_MULT_BLOCK_SIZE_STR,
      'Multiple Block Sizes are being used with this database.');
  end;

  /***************************** 
   * OLAP - Analytic Workspaces
   *****************************/

  declare 
    DBFUS_OLAP_AW_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), count(*), NULL from dba_aws where AW_NUMBER >= 1000';

  begin
    dbms_feature_usage.register_db_feature
     ('OLAP - Analytic Workspaces',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_OLAP_AW_STR,
      'OLAP - the analytic workspaces stored in the database.');
  end;

  /***************************** 
   * OLAP - Cubes
   *****************************/

  declare 
    DBFUS_OLAP_CUBE_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), count(*), NULL from DBA_OLAP2_CUBES ' ||
        'where invalid != ''Y'' and OWNER = ''SYS'' ' ||
        'and CUBE_NAME = ''STKPRICE_TBL''';

  begin
    dbms_feature_usage.register_db_feature
     ('OLAP - Cubes',
      dbms_feature_usage.DBU_INST_OBJECT,
      'PUBLIC.DBA_OLAP2_CUBES',
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_OLAP_CUBE_STR,
      'OLAP - number of cubes in the OLAP catalog that are fully ' ||
      'mapped and accessible by the OLAP API.');
  end;

  /*********************** 
   * Oracle Managed Files 
   ***********************/

  declare 
    DBFUS_OMF_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from dba_data_files where ' ||
        'upper(file_name) like ''%O1_MF%''';

  begin
    dbms_feature_usage.register_db_feature
     ('Oracle Managed Files',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_OMF_STR,
      'Database files are being managed by Oracle.');
  end;

  /*******************************
   * Parallel SQL DDL Execution
   *******************************/

  declare 
    DBFUS_PSQL_DDL_STR CONSTANT VARCHAR2(1000) := 
      'select value, NULL, NULL from v$pq_sysstat ' ||
        'where rtrim(statistic,'' '') = ''DDL Initiated''';

  begin
    dbms_feature_usage.register_db_feature
     ('Parallel SQL DDL Execution',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_PSQL_DDL_STR,
      'Parallel SQL DDL Execution is being used.');
  end;

  /*******************************
   * Parallel SQL DML Execution
   *******************************/

  declare 
    DBFUS_PSQL_DML_STR CONSTANT VARCHAR2(1000) := 
      'select value, NULL, NULL from v$pq_sysstat ' ||
        'where rtrim(statistic,'' '') = ''DML Initiated''';

  begin
    dbms_feature_usage.register_db_feature
     ('Parallel SQL DML Execution',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_PSQL_DML_STR,
      'Parallel SQL DML Execution is being used.');
  end;

  /*******************************
   * Parallel SQL Query Execution
   *******************************/

  declare 
    DBFUS_PSQL_QUERY_STR CONSTANT VARCHAR2(1000) := 
      'select value, NULL, NULL from v$pq_sysstat ' ||
        'where rtrim(statistic,'' '') = ''Queries Initiated''';

  begin
    dbms_feature_usage.register_db_feature
     ('Parallel SQL Query Execution',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_PSQL_QUERY_STR,
      'Parallel SQL Query Execution is being used.');
  end;

  /************************
   * Partitioning (system)
   ************************/

  declare 
    DBFUS_PARTN_SYS_PROC CONSTANT VARCHAR2(1000) := 
      'DBMS_FEATURE_PARTITION_SYSTEM';

  begin
    dbms_feature_usage.register_db_feature
     ('Partitioning (system)',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_PARTN_SYS_PROC,
      'Oracle Partitioning option is being used - there is at ' ||
      'least one partitioned object created.');
  end;

  /**********************
   * Partitioning (user)
   **********************/

  declare 
    DBFUS_PARTN_USER_PROC CONSTANT VARCHAR2(1000) := 
      'DBMS_FEATURE_PARTITION_USER';

  begin
    dbms_feature_usage.register_db_feature
     ('Partitioning (user)',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_PARTN_USER_PROC,
      'Oracle Partitioning option is being used - there is at ' ||
      'least one user partitioned object created.');
  end;

  /****************************
   * PL/SQL Native Compilation
   ****************************/

  declare 
    DBFUS_PLSQL_NATIVE_PROC CONSTANT VARCHAR2(1000) := 
      'DBMS_FEATURE_PLSQL_NATIVE';

  begin
    dbms_feature_usage.register_db_feature
     ('PL/SQL Native Compilation',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_PLSQL_NATIVE_PROC,
      'PL/SQL Native Compilation is being used - there is at least one ' ||
      'natively compiled PL/SQL library unit in the database.');
  end;

  /*******************************************
   * Protection Mode - Maximum Availability
   *******************************************/

  declare 
    DBFUS_PRMODE_MAXAVAIL_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from v$database ' ||
        'where protection_mode = ''MAXIMUM AVAILABILITY''';

  begin
    dbms_feature_usage.register_db_feature
     ('Protection Mode - Maximum Availability',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_PRMODE_MAXAVAIL_STR,
      'Data Guard configuration data protection mode is ' ||
      'Maximum Availability.');
  end;

  /*******************************************
   * Protection Mode - Maximum Performance
   *******************************************/

  declare 
    DBFUS_PRMODE_MAXPERF_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from v$database ' ||
        'where protection_mode = ''MAXIMUM PERFORMANCE''';

  begin
    dbms_feature_usage.register_db_feature
     ('Protection Mode - Maximum Performance',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_PRMODE_MAXPERF_STR,
      'Data Guard configuration data protection mode is Maximum Performance.');
  end;

  /*******************************************
   * Protection Mode - Maximum Protection
   *******************************************/

  declare 
    DBFUS_PRMODE_MAXPROT_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from v$database ' ||
        'where protection_mode = ''MAXIMUM PROTECTION''';

  begin
    dbms_feature_usage.register_db_feature
     ('Protection Mode - Maximum Protection',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_PRMODE_MAXPROT_STR,
      'Data Guard configuration data protection mode is Maximum Protection.');
  end;

  /*******************************************
   * Protection Mode - Unprotected
   *******************************************/

  declare 
    DBFUS_PRMODE_UNPROT_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from v$database ' ||
        'where protection_mode = ''UNPROTECTED''';

  begin
    dbms_feature_usage.register_db_feature
     ('Protection Mode - Unprotected',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_PRMODE_UNPROT_STR,
      'Data Guard configuration data protection mode is Unprotected.');
  end;

  /****************************
   * Real Application Clusters 
   ****************************/

  declare 
    DBFUS_RAC_PROC CONSTANT VARCHAR2(1000) := 'DBMS_FEATURE_RAC';

  begin
    dbms_feature_usage.register_db_feature
     ('Real Application Clusters (RAC)',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_RAC_PROC,
      'Real Application Clusters (RAC) is configured.');
  end;

  /********************** 
   * Recovery Area
   **********************/

  declare 
    DBFUS_RECOVERY_AREA_STR CONSTANT VARCHAR2(1000) := 
      'select p, s, NULL from ' ||
        '(select count(*) p from v$parameter ' ||
         'where name = ''db_recovery_file_dest'' and value is not null), ' ||
        '(select to_number(value) s from v$parameter ' ||
         'where name = ''db_recovery_file_dest_size'')';

  begin
    dbms_feature_usage.register_db_feature
     ('Recovery Area',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_RECOVERY_AREA_STR,
      'The recovery area is configured.');
  end;

  /**************************
   * Recovery Manager (RMAN)
   **************************/

  /* This query returns 1 if there are any backup pieces or image copies,
   * on any device type, whose status is 'available'.
   * Controlfile autobackups are ignored, because we don't want to 
   * consider RMAN in use if they just turned on the controlfile autobackup
   * feature. */

  declare 
    DBFUS_RMAN_STR CONSTANT VARCHAR2(1000) := 
      'select decode(count(*), 0, 0, 1), count(*), NULL from ' ||
      ' (select * from ' ||
      '  (select set_count sc1 from v$backup_piece where status=''A'') ' ||
      '  left outer join ' ||
      '  (select set_count sc2 from v$backup_datafile df ' ||
      '   join v$backup_piece bp using (set_count) ' ||
      '   where bp.status=''A'' ' ||
      '   group by set_count having max(df.file#) = 0) ' ||
      '  on sc1 = sc2 where sc2 is null ' ||
      '  union all ' ||
      '  select recid, stamp from v$datafile_copy ' ||
      '  where file# != 0 and status = ''A'')';

  begin
    dbms_feature_usage.register_db_feature
     ('Recovery Manager (RMAN)',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_RMAN_STR,
      'Recovery Manager (RMAN) is being used to backup the database.');
  end;

  /********************** 
   * RMAN - Disk Backup
   **********************/

  /* This query returns 1 if there are any backup pieces or image copies,
   * on device type DISK, whose status is 'available'.
   * Controlfile autobackups are ignored, because we don't want to 
   * consider RMAN in use if they just turned on the controlfile autobackup
   * feature. */

  declare 
    DBFUS_RMAN_DISK_BACKUP_STR CONSTANT VARCHAR2(1000) := 
      'select decode(count(*), 0, 0, 1), count(*), NULL from ' ||
      ' (select * from ' ||
      '  (select set_count sc1 from v$backup_piece ' ||
      '   where status=''A'' and device_type = ''DISK'') ' ||
      '  left outer join ' ||
      '  (select set_count sc2 from v$backup_datafile df ' ||
      '   join v$backup_piece bp using (set_count) ' ||
      '   where bp.status=''A'' and bp.device_type = ''DISK'' ' ||
      '   group by set_count having max(df.file#) = 0) ' ||
      '  on sc1 = sc2 where sc2 is null ' ||
      '  union all ' ||
      '  select recid, stamp from v$datafile_copy ' ||
      '  where file# != 0 and status = ''A'')';

  begin
    dbms_feature_usage.register_db_feature
     ('RMAN - Disk Backup',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_RMAN_DISK_BACKUP_STR,
      'Recovery Manager (RMAN) is being used to backup the database to disk.');
  end;

  /********************** 
   * RMAN - Tape Backup
   **********************/

  /* This query returns 1 if there are any backup pieces
   * on non-DISK devices, whose status is 'available'.
   * Controlfile autobackups are ignored, because we don't want to 
   * consider RMAN in use if they just turned on the controlfile autobackup
   * feature. */

  declare 
    DBFUS_RMAN_TAPE_BACKUP_STR CONSTANT VARCHAR2(1000) := 
      'select decode(count(*), 0, 0, 1), count(*), NULL from ' ||
      ' (select set_count sc1 from v$backup_piece ' ||
      '  where status=''A'' and device_type != ''DISK'') ' ||
      ' left outer join ' ||
      ' (select set_count sc2 from v$backup_datafile df ' ||
      '  join v$backup_piece bp using (set_count) ' ||
      '  where bp.status=''A'' and bp.device_type != ''DISK'' ' ||
      '  group by set_count having max(df.file#) = 0) ' ||
      ' on sc1 = sc2 where sc2 is null';

  begin
    dbms_feature_usage.register_db_feature
     ('RMAN - Tape Backup',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_RMAN_TAPE_BACKUP_STR,
      'Recovery Manager (RMAN) is being used to backup the database to tape.');
  end;

  /********************** 
   * Resource Manager
   **********************/

  declare 
    DBFUS_RESOURCE_MGR_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from v$system_parameter where ' ||
        'name = ''resource_manager_plan'' and value is not null';

  begin
    dbms_feature_usage.register_db_feature
     ('Resource Manager',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_RESOURCE_MGR_STR,
      'Oracle Database Resource Manager is being used to control ' ||
      'database resources.');
  end;

  /******************
   * Segment Advisor
   ******************/

  declare
    DBFUS_SEGMENT_ADV_STR CONSTANT VARCHAR2(1000) :=
      'select count(*), NULL, NULL ' ||
        'from wri$_adv_usage u, wri$_adv_definitions a ' ||
        'where a.name = ''Segment Advisor'' and ' ||
              'u.advisor_id = a.id and  ' ||
              'u.num_execs > 0 and ' ||
              'u.last_exec_time >= (select max(last_sample_date) ' ||
                                     'from wri$_dbu_usage_sample)';

  begin
    dbms_feature_usage.register_db_feature
     ('Segment Advisor',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_SEGMENT_ADV_STR,
      'A task for Segment Advisor has been executed.');
  end;

  /************************ 
   * Server Parameter File
   ************************/

  declare 
    DBFUS_SPFILE_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from v$system_parameter where ' ||
        'name = ''spfile'' and value is not null';

  begin
    dbms_feature_usage.register_db_feature
     ('Server Parameter File',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_SPFILE_STR,
      'The server parameter file (SPFILE) was used to startup the database.');
  end;

  /******************************
   * SGA/Memory Advisor
   ******************************/

  declare 
    DBFUS_SGA_ADV_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL ' ||
        'from wri$_adv_usage u, wri$_adv_definitions a ' ||
        'where a.name = ''SGA/Memory Advisor'' and ' ||
              'u.advisor_id = a.id and  ' ||
              'u.num_execs > 0 and ' ||
              'u.last_exec_time >= (select max(last_sample_date) ' ||
                                     'from wri$_dbu_usage_sample)';

  begin
    dbms_feature_usage.register_db_feature
     ('SGA/Memory Advisor',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_NULL,
      DBFUS_SGA_ADV_STR,
      'SGA/Memory Advisor has been used.');
  end;

  /********************** 
   * Shared Server
   **********************/

  declare 
    DBFUS_MTS_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from v$system_parameter ' ||
        'where name = ''shared_servers'' and value != ''0'' and ' ||
        'exists (select 1 from v$shared_server where busy > 0)';

  begin
    dbms_feature_usage.register_db_feature
     ('Shared Server',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_MTS_STR,
      'The database is configured as Shared Server, where the server ' ||
      'process can service multiple user processes.');
  end;

  /********************** 
   * Spatial
   **********************/

  declare 
    DBFUS_SPATIAL_STR CONSTANT VARCHAR2(1000) := 
     'select atc+ix, atc+ix, NULL from ' ||
       '(select count(*) atc ' ||
          'from mdsys.sdo_geom_metadata_table '||
         'where sdo_owner not in (''MDSYS'', ''OE'')), ' ||
       '(select count(*) ix ' ||
          'from mdsys.sdo_index_metadata_table)';

  begin
    dbms_feature_usage.register_db_feature
     ('Spatial',
      dbms_feature_usage.DBU_INST_OBJECT, 
      'MDSYS.all_sdo_index_metadata',
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_SPATIAL_STR,
      'There is at least one usage of the Oracle Spatial index ' ||
      'metadata table.');
  end;

  /******************************
   * SQL Access Advisor
   ******************************/

  declare 
    DBFUS_SQL_ACCESS_ADV_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL ' ||
        'from wri$_adv_usage u, wri$_adv_definitions a ' ||
        'where a.name = ''SQL Access Advisor'' and ' ||
              'u.advisor_id = a.id and  ' ||
              'u.num_execs > 0 and ' ||
              'u.last_exec_time >= (select max(last_sample_date) ' ||
                                     'from wri$_dbu_usage_sample)';

  begin
    dbms_feature_usage.register_db_feature
     ('SQL Access Advisor',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_SQL_ACCESS_ADV_STR,
      'A task for SQL Access Advisor has been executed.');
  end;

  /******************************
   * SQL Tuning Advisor
   ******************************/

  declare 
    DBFUS_SQL_TUNING_ADV_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL ' ||
        'from wri$_adv_usage u, wri$_adv_definitions a ' ||
        'where a.name = ''SQL Tuning Advisor'' and ' ||
              'u.advisor_id = a.id and  ' ||
              'u.num_execs > 0 and ' ||
              'u.last_exec_time >= (select max(last_sample_date) ' ||
                                     'from wri$_dbu_usage_sample)';

  begin
    dbms_feature_usage.register_db_feature
     ('SQL Tuning Advisor',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_SQL_TUNING_ADV_STR,
      'SQL Tuning Advisor has been used.');
  end;

  /******************************
   * SQL Tuning Set
   ******************************/

  declare 
    DBFUS_SQL_TUNING_SET_STR CONSTANT VARCHAR2(1000) := 
      'select numss, numref, NULL from ' ||
        '(select count(*) numss  from wri$_sqlset_definitions), ' ||
        '(select count(*) numref from wri$_sqlset_references)';

  begin
    dbms_feature_usage.register_db_feature
     ('SQL Tuning Set',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_SQL_TUNING_SET_STR,
      'A SQL Tuning Set has been created in the database.');
  end;

  /**********************************
   * Standby Archival - LGWR
   **********************************/

  declare 
    DBFUS_STARC_LGWR_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from v$archive_dest ' ||
        'where status = ''VALID'' and target = ''STANDBY'' ' ||
        'and archiver = ''LGWR''';

  begin
    dbms_feature_usage.register_db_feature
     ('Standby Archival - LGWR',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_STARC_LGWR_STR,
      'Data Guard configuration: Remote archival is done by LGWR.');
  end;

  /**********************************
   * Standby Archival - ARCH
   **********************************/

  declare 
    DBFUS_STARC_ARCH_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from v$archive_dest ' ||
        'where status = ''VALID'' and target = ''STANDBY'' ' ||
        'and archiver like ''ARC%''';

  begin
    dbms_feature_usage.register_db_feature
     ('Standby Archival - ARCH',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_STARC_ARCH_STR,
      'Data Guard configuration: Remote archival is done by ARCH.');
  end;

  /************************************
   * Standby Transmission
   ************************************/

  declare 
    DBFUS_STANDBY_TRANS_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from v$archive_dest ' ||
        'where status = ''VALID'' and target = ''STANDBY'' ';

  begin
    dbms_feature_usage.register_db_feature
     ('Standby Transmission',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_STANDBY_TRANS_STR,
      'Standby database: Network transmission mode was chosen ' ||
      'for a standby destination.');
  end;

  /********************** 
   * Streams (system)
   **********************/

  declare 
    DBFUS_STREAMS_SYS_STR CONSTANT VARCHAR2(1000) := 
     'select decode(cap + app + prop + msg + aq , 0, 0, 1), 0, NULL from ' ||
       '(select decode (count(*), 0, 0, 1) cap from dba_capture), ' ||  
       '(select decode (count(*), 0, 0, 1) app from dba_apply), ' ||
       '(select decode (count(*), 0, 0, 1) prop from dba_propagation), ' ||
       -- for streams messaging, these consumers are in the db by default
       '(select decode (count(*), 0, 0, 1) msg ' ||
       '  from dba_streams_message_consumers ' ||
       '  where streams_name != ''SCHEDULER_COORDINATOR'' and' ||
       '  streams_name != ''SCHEDULER_PICKUP''),' ||
       '(select decode (count(*), 0, 0, 1) aq ' ||
       '  from system.aq$_queue_tables)';

  begin
    dbms_feature_usage.register_db_feature
     ('Streams (system)',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_STREAMS_SYS_STR,
      'Oracle Streams has been configured');
  end;

  /********************** 
   * Streams (user)
   **********************/

  declare 
    DBFUS_STREAMS_USER_STR CONSTANT VARCHAR2(1000) := 
     'select decode(cap + app + prop + msg + aq , 0, 0, 1), 0, NULL from ' ||
       '(select decode (count(*), 0, 0, 1) cap from dba_capture), ' ||  
       '(select decode (count(*), 0, 0, 1) app from dba_apply), ' ||
       '(select decode (count(*), 0, 0, 1) prop from dba_propagation), ' ||
       -- for streams messaging, these consumers are in the db by default
       '(select decode (count(*), 0, 0, 1) msg ' ||
       '  from dba_streams_message_consumers ' ||
       '  where streams_name != ''SCHEDULER_COORDINATOR'' and' ||
       '  streams_name != ''SCHEDULER_PICKUP''),' ||
       -- for AQ, there are default queues in the sys, system, ix, and wmsys
       -- schemas which we do not want to count towards feature usage
       '(select decode (count(*), 0, 0, 1) aq ' ||
       '  from system.aq$_queue_tables where schema not in ' ||
       '  (''SYS'', ''SYSTEM'', ''IX'', ''WMSYS''))';

  begin
    dbms_feature_usage.register_db_feature
     ('Streams (user)',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_STREAMS_USER_STR,
      'Users have configured Oracle Streams');
  end;

  /******************************
   * Tablespace Advisor
   ******************************/

  declare 
    DBFUS_TABLESPACE_ADV_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL ' ||
        'from wri$_adv_usage u, wri$_adv_definitions a ' ||
        'where a.name = ''Tablespace Advisor'' and ' ||
              'u.advisor_id = a.id and  ' ||
              'u.num_execs > 0 and ' ||
              'u.last_exec_time >= (select max(last_sample_date) ' ||
                                     'from wri$_dbu_usage_sample)';

  begin
    dbms_feature_usage.register_db_feature
     ('Tablespace Advisor',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_NULL,
      DBFUS_TABLESPACE_ADV_STR,
      'Tablespace Advisor has been used.');
  end;

  /********************** 
   * Transparent Gateway
   **********************/

  declare 
    DBFUS_GATEWAYS_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from hs_fds_class_date ' || 
        'where fds_class_name != ''BITE''';

  begin
    dbms_feature_usage.register_db_feature
     ('Transparent Gateway',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_GATEWAYS_STR,
      'Heterogeneous Connectivity, access to a non-Oracle system, has ' ||
      'been configured.');
  end;

  /******************************
   * Undo Advisor
   ******************************/

  declare 
    DBFUS_UNDO_ADV_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL ' ||
        'from wri$_adv_usage u, wri$_adv_definitions a ' ||
        'where a.name = ''Undo Advisor'' and ' ||
              'u.advisor_id = a.id and  ' ||
              'u.num_execs > 0 and ' ||
              'u.last_exec_time >= (select max(last_sample_date) ' ||
                                     'from wri$_dbu_usage_sample)';

  begin
    dbms_feature_usage.register_db_feature
     ('Undo Advisor',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_UNDO_ADV_STR,
      'Undo Advisor has been used.');
  end;

  /***************************
   * Virtual Private Database
   ***************************/

  declare 
    DBFUS_VPD_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from rls$';

  begin
    dbms_feature_usage.register_db_feature
     ('Virtual Private Database (VPD)',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_VPD_STR,
      'Virtual Private Database (VPD) policies are being used.');
  end;



  /*********************************************
   * TEST features to test the infrastructure 
   *********************************************/

  dbms_feature_usage.register_db_feature
     ('_DBFUS_TEST_SQL_1',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED + 
      dbms_feature_usage.DBU_INST_TEST,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      'select 1, 0, NULL from dual',
      'Test sql 1');

  dbms_feature_usage.register_db_feature
     ('_DBFUS_TEST_SQL_2',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED + 
      dbms_feature_usage.DBU_INST_TEST,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      'select 0, 10, to_clob(''hi, mike'') from dual',
      'Test sql 2');

  dbms_feature_usage.register_db_feature
     ('_DBFUS_TEST_SQL_3',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED + 
      dbms_feature_usage.DBU_INST_TEST,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      'select 13, NULL, to_clob(''hello, mike'') from dual',
      'Test sql 3');

  dbms_feature_usage.register_db_feature
     ('_DBFUS_TEST_SQL_4',
      dbms_feature_usage.DBU_INST_OBJECT + 
      dbms_feature_usage.DBU_INST_TEST,
      'sys.tab$',
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      'select 11, 11, to_clob(''test sql 4 check tab$'') from dual',
      'Test sql 4');

  dbms_feature_usage.register_db_feature
     ('_DBFUS_TEST_SQL_5',
      dbms_feature_usage.DBU_INST_OBJECT + 
      dbms_feature_usage.DBU_INST_TEST,
      'sys.foo',
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      'select 2, 0, to_clob(''check foo'') from dual',
      'Test sql 5');

  dbms_feature_usage.register_db_feature
     ('_DBFUS_TEST_SQL_6',
      dbms_feature_usage.DBU_INST_OBJECT + 
      dbms_feature_usage.DBU_INST_TEST,
      'sys.tab$',
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      'select 0, 0, to_clob(''should not see'') from dual',
      'Test sql 6');

  dbms_feature_usage.register_db_feature
     ('_DBFUS_TEST_SQL_7',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED + 
      dbms_feature_usage.DBU_INST_TEST,
      NULL,
      dbms_feature_usage.DBU_DETECT_NULL,
      'junk',
      'Test sql 7');

  dbms_feature_usage.register_db_feature
     ('_DBFUS_TEST_SQL_8',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED + 
      dbms_feature_usage.DBU_INST_TEST,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      'select junk from foo',
      'Test sql 8 - Test error case');

  dbms_feature_usage.register_db_feature
     ('_DBFUS_TEST_SQL_9',
      dbms_feature_usage.DBU_INST_OBJECT + 
      dbms_feature_usage.DBU_INST_TEST,
      'test.test',
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      'select junk from foo',
      'Test sql 9 - Test error case for install');

  dbms_feature_usage.register_db_feature
     ('_DBFUS_TEST_SQL_10',
      dbms_feature_usage.DBU_INST_OBJECT + 
      dbms_feature_usage.DBU_INST_TEST,
      'sys.dbu_test_table',
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      'select count(*), count(*), max(letter) from dbu_test_table',
      'Test sql 10 - Test infrastructure');

  dbms_feature_usage.register_db_feature
     ('_DBFUS_TEST_PROC_1',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED + 
      dbms_feature_usage.DBU_INST_TEST,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_TEST_PROC_1',
      'Test feature 1');

  dbms_feature_usage.register_db_feature
     ('_DBFUS_TEST_PROC_2',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED + 
      dbms_feature_usage.DBU_INST_TEST,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_TEST_PROC_2',
      'Test feature 2');

  dbms_feature_usage.register_db_feature
     ('_DBFUS_TEST_PROC_3',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED + 
      dbms_feature_usage.DBU_INST_TEST,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'Junk Procedure',
      'Test feature 3 - Bad procedure name');

  dbms_feature_usage.register_db_feature
     ('_DBFUS_TEST_PROC_4',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED + 
      dbms_feature_usage.DBU_INST_TEST,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_TEST_PROC_4',
      'Test feature 4');

  dbms_feature_usage.register_db_feature
     ('_DBFUS_TEST_PROC_5',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED + 
      dbms_feature_usage.DBU_INST_TEST,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_TEST_PROC_5',
      'Test feature 5');

end;
/


Rem ************************************
Rem     High Water Mark Registration
Rem ************************************

create or replace procedure DBMS_FEATURE_REGISTER_ALLHWM
as
begin

  /**************************
   * User Tables
   **************************/

  declare 
    HWM_USER_TABLES_STR CONSTANT VARCHAR2(1000) := 
     'select count(*) from sys.tab$ t, sys.obj$ o ' ||
       'where t.obj# = o.obj# ' ||
         'and bitand(t.property, 1) = 0 ' ||
         'and o.owner# not in (select u.user# from user$ u ' ||
                                'where u.name in (''SYS'', ''SYSTEM''))';

  begin
    dbms_feature_usage.register_high_water_mark
     ('USER_TABLES',
      dbms_feature_usage.DBU_HWM_BY_SQL,
      HWM_USER_TABLES_STR,
      'Number of User Tables');
  end;

  /**************************
   * Segment Size 
   **************************/

  declare 
    HWM_SEG_SIZE_STR CONSTANT VARCHAR2(1000) := 
      'select max(bytes) from dba_segments';

  begin
    dbms_feature_usage.register_high_water_mark
     ('SEGMENT_SIZE',
      dbms_feature_usage.DBU_HWM_BY_SQL,
      HWM_SEG_SIZE_STR,
      'Size of Largest Segment (Bytes)');
  end;

  /**************************
   * Partition Tables
   **************************/

  declare 
    HWM_PART_TABLES_STR CONSTANT VARCHAR2(1000) := 
     'select nvl(max(p.partcnt), 0) from sys.partobj$ p, sys.obj$ o ' ||
       'where p.obj# = o.obj# ' ||
         'and o.type# = 2 ' ||
         'and o.owner# not in (select u.user# from user$ u ' ||
                               'where u.name in (''SYS'', ''SYSTEM'', ''SH''))';

  begin
    dbms_feature_usage.register_high_water_mark
     ('PART_TABLES',
      dbms_feature_usage.DBU_HWM_BY_SQL,
      HWM_PART_TABLES_STR,
      'Maximum Number of Partitions belonging to an User Table');
  end;

  /**************************
   * Partition Indexes
   **************************/

  declare 
    HWM_PART_INDEXES_STR CONSTANT VARCHAR2(1000) := 
     'select nvl(max(p.partcnt), 0) from sys.partobj$ p, sys.obj$ o ' ||
       'where p.obj# = o.obj# ' ||
         'and o.type# = 1 ' ||
         'and o.owner# not in (select u.user# from user$ u ' ||
                               'where u.name in (''SYS'', ''SYSTEM'', ''SH''))';

  begin
    dbms_feature_usage.register_high_water_mark
     ('PART_INDEXES',
      dbms_feature_usage.DBU_HWM_BY_SQL,
      HWM_PART_INDEXES_STR,
      'Maximum Number of Partitions belonging to an User Index');
  end;

  /**************************
   * User Indexes
   **************************/

  declare 
    HWM_USER_INDEX_STR CONSTANT VARCHAR2(1000) := 
     'select count(*) from sys.ind$ i, sys.obj$ o ' ||
       'where i.obj# = o.obj# ' ||
         'and bitand(i.flags, 4096) = 0 ' ||
         'and o.owner# not in (select u.user# from user$ u ' ||
                                'where u.name in (''SYS'', ''SYSTEM''))';

  begin
    dbms_feature_usage.register_high_water_mark
     ('USER_INDEXES',
      dbms_feature_usage.DBU_HWM_BY_SQL,
      HWM_USER_INDEX_STR,
      'Number of User Indexes');
  end;

  /**************************
   * Sessions
   **************************/

  declare 
    HWM_SESSIONS_STR CONSTANT VARCHAR2(1000) := 
      'select sessions_highwater from V$LICENSE';

  begin
    dbms_feature_usage.register_high_water_mark
     ('SESSIONS',
      dbms_feature_usage.DBU_HWM_BY_SQL,
      HWM_SESSIONS_STR,
      'Maximum Number of Concurrent Sessions seen in the database');
  end;

  /**************************
   * DB Size
   **************************/

  declare 
    HWM_DB_SIZE_STR CONSTANT VARCHAR2(1000) := 
      'select sum(bytes) from dba_data_files';

  begin
    dbms_feature_usage.register_high_water_mark
     ('DB_SIZE',
      dbms_feature_usage.DBU_HWM_BY_SQL,
      HWM_DB_SIZE_STR,
      'Maximum Size of the Database (Bytes)');
  end;

  /**************************
   * Datafiles
   **************************/

  declare 
    HWM_DATAFILES_STR CONSTANT VARCHAR2(1000) := 
      'select count(*) from dba_data_files';

  begin
    dbms_feature_usage.register_high_water_mark
     ('DATAFILES',
      dbms_feature_usage.DBU_HWM_BY_SQL,
      HWM_DATAFILES_STR,
      'Maximum Number of Datafiles');
  end;

  /**************************
   * Tablespaces
   **************************/

  declare 
    HWM_TABLESPACES_STR CONSTANT VARCHAR2(1000) := 
     'select count(*) from sys.ts$ ts ' ||
       'where ts.online$ != 3 ' ||
         'and bitand(ts.flags, 2048) != 2048';

  begin
    dbms_feature_usage.register_high_water_mark
     ('TABLESPACES',
      dbms_feature_usage.DBU_HWM_BY_SQL,
      HWM_TABLESPACES_STR,
      'Maximum Number of Tablespaces');
  end;

  /**************************
   * CPU count
   **************************/

  declare 
    HWM_CPU_COUNT_STR CONSTANT VARCHAR2(1000) := 
      'select sum(cpu_count_highwater) from gv$license';

  begin
    dbms_feature_usage.register_high_water_mark
     ('CPU_COUNT',
      dbms_feature_usage.DBU_HWM_BY_SQL,
      HWM_CPU_COUNT_STR,
      'Maximum Number of CPUs');
  end;

  /**************************
   * Query Length
   **************************/

  declare 
    HWM_QUERY_LENGTH_STR CONSTANT VARCHAR2(1000) := 
      'select max(maxquerylen) from v$undostat';

  begin
    dbms_feature_usage.register_high_water_mark
     ('QUERY_LENGTH',
      dbms_feature_usage.DBU_HWM_BY_SQL,
      HWM_QUERY_LENGTH_STR,
      'Maximum Query Length');
  end;

  /****************************** 
   * National Character Set Usage
   *******************************/

  declare 
    HWM_NCHAR_COLUMNS_STR CONSTANT VARCHAR2(1000) := 
      'select count(*) from col$ c, obj$ o ' ||
      ' where c.charsetform = 2 and c.obj# = o.obj# ' ||
      ' and o.owner# not in ' || 
      ' (select distinct u.user_id from all_users u, ' ||
      ' sys.ku_noexp_view k where (k.OBJ_TYPE=''USER'' and ' ||
      ' k.name=u.username) or (u.username=''SYSTEM'')) ' ;

  begin
    dbms_feature_usage.register_high_water_mark
     ('SQL_NCHAR_COLUMNS',
      dbms_feature_usage.DBU_HWM_BY_SQL,
      HWM_NCHAR_COLUMNS_STR,
      'Maximum Number of SQL NCHAR Columns');
  end;
  
  /********************************
   * Services
   *********************************/

  declare
    HWM_SERVICES_STR CONSTANT VARCHAR2(1000) :=
      'select count(*) from gv$services';

  begin
    dbms_feature_usage.register_high_water_mark
     ('SERVICES',
      dbms_feature_usage.DBU_HWM_BY_SQL,
      HWM_SERVICES_STR,
      'Maximum Number of Services');
  end;

  /**************************
   * Test HWM
   **************************/

  declare 
    HWM_TEST_PROC CONSTANT VARCHAR2(1000) := 
      'DBMS_FEATURE_TEST_PROC_3';

  begin
    dbms_feature_usage.register_high_water_mark
     ('_HWM_TEST_1',
      dbms_feature_usage.DBU_HWM_BY_PROCEDURE +
      dbms_feature_usage.DBU_HWM_TEST,
      HWM_TEST_PROC,
      'Test HWM 1');
  end;

  dbms_feature_usage.register_high_water_mark
     ('_HWM_TEST_2',
      dbms_feature_usage.DBU_HWM_NULL +
      dbms_feature_usage.DBU_HWM_TEST,
      'Junk',
      'Test HWM 2');
  
  dbms_feature_usage.register_high_water_mark
     ('_HWM_TEST_3',
      dbms_feature_usage.DBU_HWM_BY_SQL +
      dbms_feature_usage.DBU_HWM_TEST,
      'select 10 from dual',
      'Test HWM 3');

  dbms_feature_usage.register_high_water_mark  
     ('_HWM_TEST_4',
      dbms_feature_usage.DBU_HWM_BY_SQL +
      dbms_feature_usage.DBU_HWM_TEST,
      'select 1240 from foo',
      'Test HWM 4 - Error case');

end;
/


/* register all the features and high water marks */
begin
  DBMS_FEATURE_REGISTER_ALLFEAT;
  DBMS_FEATURE_REGISTER_ALLHWM;
end;
/

