Rem
Rem $Header: catost.sql 09-dec-2003.22:54:07 schakkap Exp $
Rem
Rem catost.sql
Rem
Rem Copyright (c) 2003, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      catost.sql - Optimizer Statistics Tables
Rem
Rem    DESCRIPTION
Rem      This file creates the tables used for storing old versions of
Rem      optimizer statistics
Rem
Rem    NOTES
Rem      These tables are created in sysaux tablespace. 
Rem      SWRF purging mechanism is used to purge these tables.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    schakkap    12/09/03 - set pctfree to 1 for stats history tables 
Rem    schakkap    10/08/03 - support for changing defaults for dbms_stats 
Rem    schakkap    09/24/03 - remove owner column from USER_TAB_STATS_HISTORY 
Rem    schakkap    09/08/03 - *_TAB_STATS_HISTORY 
Rem    schakkap    05/31/03 - change OPTSTAT_SAVSKIP$ to OPTSTAT_HIST_CONTROL$
Rem    aime        04/25/03 - aime_going_to_main
Rem    schakkap    02/08/03 - schakkap_stat_history
Rem    schakkap    01/28/03 - Created
Rem

rem table to store optimizer statistics history 
rem for table and table partition objects
create table WRI$_OPTSTAT_TAB_HISTORY
( obj#          number not null,                            /* object number */
  savtime       timestamp with time zone,      /* timestamp when stats saved */
  flags         number,
  rowcnt        number,                                    /* number of rows */
  blkcnt        number,                                  /* number of blocks */
  avgrln        number,                                /* average row length */
  samplesize    number,                 /* number of rows sampled by Analyze */
  analyzetime   date,                        /* timestamp when last analyzed */
  cachedblk     number,                            /* blocks in buffer cache */
  cachehit      number,                                   /* cache hit ratio */
  logicalread   number,                           /* number of logical reads */
  spare1        number,
  spare2        number,
  spare3        number,
  spare4        varchar2(1000),
  spare5        varchar2(1000),
  spare6        timestamp with time zone
) tablespace SYSAUX 
pctfree 1
enable row movement
/
create unique index I_WRI$_OPTSTAT_TAB_OBJ#_ST on 
  wri$_optstat_tab_history(obj#, savtime)
  tablespace SYSAUX
/
create index I_WRI$_OPTSTAT_TAB_ST on 
  wri$_optstat_tab_history(savtime)
  tablespace SYSAUX
/

rem table to store optimizer statistics history 
rem for index and index partition objects
create table WRI$_OPTSTAT_IND_HISTORY
( obj#          number not null,                            /* object number */
  savtime       timestamp with time zone,      /* timestamp when stats saved */
  flags         number,
  rowcnt        number,                       /* number of rows in the index */
  blevel        number,                                       /* btree level */
  leafcnt       number,                                  /* # of leaf blocks */
  distkey       number,                                   /* # distinct keys */
  lblkkey       number,                          /* avg # of leaf blocks/key */
  dblkkey       number,                          /* avg # of data blocks/key */
  clufac        number,                                 /* clustering factor */
  samplesize    number,                 /* number of rows sampled by Analyze */
  analyzetime   date,                        /* timestamp when last analyzed */
  guessq        number,                                 /* IOT guess quality */
  cachedblk     number,                            /* blocks in buffer cache */
  cachehit      number,                                   /* cache hit ratio */
  logicalread   number,                           /* number of logical reads */
  spare1        number,
  spare2        number,
  spare3        number,
  spare4        varchar2(1000),
  spare5        varchar2(1000),
  spare6        timestamp with time zone
) tablespace SYSAUX
pctfree 1
enable row movement
/
create unique index I_WRI$_OPTSTAT_IND_OBJ#_ST on 
  wri$_optstat_ind_history(obj#, savtime)
  tablespace SYSAUX
/
create index I_WRI$_OPTSTAT_IND_ST on 
  wri$_optstat_ind_history(savtime)
  tablespace SYSAUX
/

rem column statistics history
create table WRI$_OPTSTAT_HISTHEAD_HISTORY
 (obj#            number not null,                          /* object number */
  intcol#         number not null,                 /* internal column number */
  savtime         timestamp with time zone,    /* timestamp when stats saved */
  flags           number,                                           /* flags */
  null_cnt        number,                  /* number of nulls in this column */
  minimum         number,           /* minimum value (if 1-bucket histogram) */
  maximum         number,           /* minimum value (if 1-bucket histogram) */
  distcnt         number,                            /* # of distinct values */
  density         number,                                   /* density value */
  lowval          raw(32),
                        /* lowest value of column (second lowest if default) */
  hival           raw(32),
                      /* highest value of column (second highest if default) */
  avgcln          number,                           /* average column length */
  sample_distcnt  number,                /* sample number of distinct values */
  sample_size     number,             /* for estimated stats, size of sample */
  timestamp#      date,                   /* date of histogram's last update */
  spare1          number,
  spare2          number,
  spare3          number,
  spare4          varchar2(1000),
  spare5          varchar2(1000),
  spare6          timestamp with time zone
) tablespace SYSAUX
pctfree 1
enable row movement
/
create unique index I_WRI$_OPTSTAT_HH_OBJ_ICOL_ST on
  wri$_optstat_histhead_history (obj#, intcol#, savtime)
  tablespace SYSAUX
/
create index I_WRI$_OPTSTAT_HH_ST on
  wri$_optstat_histhead_history (savtime)
  tablespace SYSAUX
/

rem histogram history
create table WRI$_OPTSTAT_HISTGRM_HISTORY
( obj#            number not null,                          /* object number */
  intcol#         number not null,                 /* internal column number */
  savtime         timestamp with time zone,    /* timestamp when stats saved */
  bucket          number not null,                          /* bucket number */
  endpoint        number not null,                  /* endpoint hashed value */
  epvalue         varchar2(1000),              /* endpoint value information */
  spare1          number,
  spare2          number,
  spare3          number,
  spare4          varchar2(1000),
  spare5          varchar2(1000),
  spare6          timestamp with time zone
) tablespace SYSAUX
pctfree 1
enable row movement
/
create index I_WRI$_OPTSTAT_H_OBJ#_ICOL#_ST on 
  wri$_optstat_histgrm_history(obj#, intcol#, savtime)
  tablespace SYSAUX
/
create index I_WRI$_OPTSTAT_H_ST on 
  wri$_optstat_histgrm_history(savtime)
  tablespace SYSAUX
/

rem aux_stats$ history
create table WRI$_OPTSTAT_AUX_HISTORY
( 
  savtime timestamp with time zone,
  sname varchar2(30),  -- M_IDEN
  pname varchar2(30),  -- M_IDEN
  pval1 number,
  pval2 varchar2(255), 
  spare1          number,
  spare2          number,
  spare3          number,
  spare4          varchar2(1000),
  spare5          varchar2(1000),
  spare6          timestamp with time zone
) tablespace SYSAUX
pctfree 1
enable row movement
/
create index I_WRI$_OPTSTAT_AUX_ST on 
  wri$_optstat_aux_history(savtime)
  tablespace SYSAUX
/

rem optimizer stats operations history
create table WRI$_OPTSTAT_OPR
( operation       varchar2(64),
  target          varchar2(64),
  start_time      timestamp with time zone,
  end_time        timestamp with time zone,
  flags           number,
  spare1          number,
  spare2          number,
  spare3          number,
  spare4          varchar2(1000),
  spare5          varchar2(1000),
  spare6          timestamp with time zone
) tablespace SYSAUX
pctfree 1
enable row movement
/
create index I_WRI$_OPTSTAT_OPR_STIME on 
  wri$_optstat_opr(start_time)
  tablespace SYSAUX
/

rem this table contains various settings used in maintaining
rem stats history. Currently the following are stored. 
rem  sname             sval1    sval2  
rem  -----------------------
rem  SKIP_TIME         null   time used for purging history or time
rem                           when we last skiped saving old stats
rem  STATS_RETENTION  retention  null
rem                   in days
rem this table is not created in SYSAUX so that we can
rem write into it even if SYSAUX is offline.
rem
rem This table also contains the default values for dbms_stats
rem procedure arguments. The procedures set_param, get_param 
rem allows the users to change the default.
rem
rem Columns             Used for
rem -----------------------------------------------
rem sname               parameter name
rem sval2               time of setting the default
rem spare1              1 if oracle default, null if set by user.
rem spare4              parameter value (stored in varchar,
rem                       please refer to set_param, get_param)
create table OPTSTAT_HIST_CONTROL$
( 
  sname           varchar2(30),  -- M_IDEN
  sval1           number,
  sval2           timestamp with time zone,
  spare1          number,
  spare2          number,
  spare3          number,
  spare4          varchar2(1000),
  spare5          varchar2(1000),
  spare6          timestamp with time zone
)
/

rem this view contains history of statistics operations performed
rem at schema/database level using dbms_stats package.

create or replace view DBA_OPTSTAT_OPERATIONS
  (OPERATION, TARGET, START_TIME, END_TIME) as 
  select operation, target, start_time, end_time
  from sys.wri$_optstat_opr
/
create or replace public synonym DBA_OPTSTAT_OPERATIONS for 
DBA_OPTSTAT_OPERATIONS
/
grant select on DBA_OPTSTAT_OPERATIONS to select_catalog_role
/
comment on table DBA_OPTSTAT_OPERATIONS is
'History of statistics operations performed'
/
comment on column DBA_OPTSTAT_OPERATIONS.OPERATION is
'Operation name'
/
comment on column DBA_OPTSTAT_OPERATIONS.TARGET is
'Target on which operation performed'
/
comment on column DBA_OPTSTAT_OPERATIONS.START_TIME is
'Start time of operation'
/
comment on column DBA_OPTSTAT_OPERATIONS.END_TIME is
'End time of operation'
/

create or replace view ALL_TAB_STATS_HISTORY
  (OWNER, TABLE_NAME, PARTITION_NAME, SUBPARTITION_NAME, 
   STATS_UPDATE_TIME) as
  -- tables
  select /*+ rule */ u.name, o.name, null, null, h.savtime
  from sys.user$ u, sys.obj$ o, sys.wri$_optstat_tab_history h
  where  h.obj# = o.obj# and o.type# = 2 and o.owner# = u.user#
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
  -- partitions
  select u.name, o.name, o.subname, null, h.savtime
  from  sys.user$ u, sys.obj$ o, sys.obj$ ot,
        sys.wri$_optstat_tab_history h
  where h.obj# = o.obj# and o.type# = 19 and o.owner# = u.user#
        and ot.name = o.name and ot.type# = 2 and ot.owner# = u.user#
        and (ot.owner# = userenv('SCHEMAID')
        or ot.obj# in
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
  -- sub partitions
  select u.name, osp.name, ocp.subname, osp.subname, h.savtime
  from  sys.user$ u, sys.obj$ osp, obj$ ocp,  sys.obj$ ot, 
        sys.tabsubpart$ tsp, sys.wri$_optstat_tab_history h
  where h.obj# = osp.obj# and osp.type# = 34 and osp.obj# = tsp.obj# and
        tsp.pobj# = ocp.obj# and osp.owner# = u.user#
        and ot.name = ocp.name and ot.type# = 2 and ot.owner# = u.user#
        and  (ot.owner# = userenv('SCHEMAID')
        or ot.obj# in
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
  -- fixed tables
  select 'SYS', t.kqftanam, null, null, h.savtime
  from  sys.x$kqfta t, sys.wri$_optstat_tab_history h
  where
  t.kqftaobj = h.obj#
    and (userenv('SCHEMAID') = 0  /* SYS */
         or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-237 /* SELECT ANY DICTIONARY */)
                 )
        )
/
create or replace public synonym ALL_TAB_STATS_HISTORY for
ALL_TAB_STATS_HISTORY
/
grant select on ALL_TAB_STATS_HISTORY to PUBLIC with grant option
/
comment on table ALL_TAB_STATS_HISTORY is
'History of table statistics modifications'
/
comment on column ALL_TAB_STATS_HISTORY.OWNER is
'Owner of the object'
/
comment on column ALL_TAB_STATS_HISTORY.TABLE_NAME is
'Name of the table'
/
comment on column ALL_TAB_STATS_HISTORY.PARTITION_NAME is
'Name of the partition'
/
comment on column ALL_TAB_STATS_HISTORY.SUBPARTITION_NAME is
'Name of the subpartition'
/
comment on column ALL_TAB_STATS_HISTORY.STATS_UPDATE_TIME is
'Time of statistics update'
/


create or replace view DBA_TAB_STATS_HISTORY
  (OWNER, TABLE_NAME, PARTITION_NAME, SUBPARTITION_NAME, 
   STATS_UPDATE_TIME) as
  -- tables
  select u.name, o.name, null, null, h.savtime
  from   sys.user$ u, sys.obj$ o, sys.wri$_optstat_tab_history h
  where  h.obj# = o.obj# and o.type# = 2 and o.owner# = u.user#
  union all
  -- partitions
  select u.name, o.name, o.subname, null, h.savtime
  from   sys.user$ u, sys.obj$ o, sys.wri$_optstat_tab_history h
  where  h.obj# = o.obj# and o.type# = 19 and o.owner# = u.user#
  union all
  -- sub partitions
  select u.name, osp.name, ocp.subname, osp.subname, h.savtime
  from  sys.user$ u,  sys.obj$ osp, obj$ ocp,  sys.tabsubpart$ tsp, 
        sys.wri$_optstat_tab_history h
  where h.obj# = osp.obj# and osp.type# = 34 and osp.obj# = tsp.obj# and
        tsp.pobj# = ocp.obj# and osp.owner# = u.user#
  union all
  -- fixed tables
  select 'SYS', t.kqftanam, null, null, h.savtime
  from  sys.x$kqfta t, sys.wri$_optstat_tab_history h
  where
  t.kqftaobj = h.obj#
/
create or replace public synonym DBA_TAB_STATS_HISTORY for
DBA_TAB_STATS_HISTORY
/
grant select on DBA_TAB_STATS_HISTORY to select_catalog_role
/
comment on table DBA_TAB_STATS_HISTORY is
'History of table statistics modifications'
/
comment on column DBA_TAB_STATS_HISTORY.OWNER is
'Owner of the object'
/
comment on column DBA_TAB_STATS_HISTORY.TABLE_NAME is
'Name of the table'
/
comment on column DBA_TAB_STATS_HISTORY.PARTITION_NAME is
'Name of the partition'
/
comment on column DBA_TAB_STATS_HISTORY.SUBPARTITION_NAME is
'Name of the subpartition'
/
comment on column DBA_TAB_STATS_HISTORY.STATS_UPDATE_TIME is
'Time of statistics update'
/


create or replace view USER_TAB_STATS_HISTORY
  (TABLE_NAME, PARTITION_NAME, SUBPARTITION_NAME, 
   STATS_UPDATE_TIME) as
  -- tables
  select o.name, null, null, h.savtime
  from   sys.obj$ o, sys.wri$_optstat_tab_history h
  where  h.obj# = o.obj# and o.type# = 2 
         and o.owner# = userenv('SCHEMAID')
  union all
  -- partitions
  select o.name, o.subname, null, h.savtime
  from   sys.obj$ o, sys.wri$_optstat_tab_history h
  where  h.obj# = o.obj# and o.type# = 19 
         and o.owner# = userenv('SCHEMAID')
  union all
  -- sub partitions
  select osp.name, ocp.subname, osp.subname, h.savtime
  from  sys.obj$ osp, sys.obj$ ocp,  sys.tabsubpart$ tsp, 
        sys.wri$_optstat_tab_history h
  where h.obj# = osp.obj# and osp.type# = 34 and osp.obj# = tsp.obj# and
        tsp.pobj# = ocp.obj# and osp.owner# = userenv('SCHEMAID')
  union all
  -- fixed tables
  select t.kqftanam, null, null, h.savtime
  from  sys.x$kqfta t, sys.wri$_optstat_tab_history h
  where
  t.kqftaobj = h.obj#
  and userenv('SCHEMAID') = 0  /* SYS */
/
create or replace public synonym USER_TAB_STATS_HISTORY for
USER_TAB_STATS_HISTORY
/
grant select on USER_TAB_STATS_HISTORY to PUBLIC with grant option
/
comment on table USER_TAB_STATS_HISTORY is
'History of table statistics modifications'
/
comment on column USER_TAB_STATS_HISTORY.TABLE_NAME is
'Name of the table'
/
comment on column USER_TAB_STATS_HISTORY.PARTITION_NAME is
'Name of the partition'
/
comment on column USER_TAB_STATS_HISTORY.SUBPARTITION_NAME is
'Name of the subpartition'
/
comment on column USER_TAB_STATS_HISTORY.STATS_UPDATE_TIME is
'Time of statistics update'
/


