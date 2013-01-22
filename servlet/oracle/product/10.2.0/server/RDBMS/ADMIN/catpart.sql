rem 
rem $Header:
rem 
Rem Copyright (c) 1988, 2005, Oracle. All rights reserved.  
Rem
Rem NAME
Rem   CATPART.SQL
Rem FUNCTION
Rem   Creates data dictionary views for the partitioning table.
Rem NOTES
Rem   1. Must be run when connected to SYS or INTERNAL.
Rem   2. This script is standalone, but it is also run from catalog.sql.
Rem   3. To drop these views run CATNOPRT.SQL.
Rem MODIFIED
Rem    bvaranas   05/17/05  - Bug 4339223: Modify definitions of 
Rem                           partitioning views to better use index on obj$
Rem    mtakahar   01/18/05  - #(3536027) fix wrong histogram type shown
Rem    mtakahar   09/09/04  - mon_mods$ -> mon_mods_all$
Rem    vshukla    07/12/04  - #(3699607): hide *IND|LOB|*PARTITIONS entries 
Rem                           for an unusable table 
Rem    schakkap   06/08/04  - stale_stats column for *STATISTICS views.
Rem                           table_owner, table_name, stattype_locked
Rem                             for *IND_STATISTICS views.
Rem                           expose physical part# in *partv views.
Rem    vshukla    05/25/04  - fix iot join condition 
Rem    vshukla    05/06/04  - add STATUS field to *_PART_TABLES, filter out 
Rem                           rows belonging to unusable tables 
Rem    mtakahar   12/18/03  - fix NUM_BUCKETS/HISTOGRAM columns
Rem    kshergil   11/03/03  - 3092470: remove LOB indexes from 
Rem                           ALL_PART_INDEXES and ALL_IND_[SUB]PARTITIONS
Rem    schakkap   10/29/03  - #(3223755): fix *_IND_STATISTICS views 
Rem    schakkap   09/09/03  - comment on stattype_locked 
Rem    vshukla    09/15/03  - #3087013: add the missing the predicate in 
Rem                           [USER | DBA | ALL]_lob_[sub]partitions
Rem    koi        06/17/03  - 2994527: change *_TAB_PARTITIONS for IOT LOGGING
Rem    araghava   05/08/03  - add COMPRESSION to *_IND_SUBPARTITIONS
Rem    schakkap   04/15/03  - Change values for lock bits
Rem    schakkap   01/01/03  - lock/unlock statistics
Rem    schakkap   12/17/02 -  add missing cols for *_TAB_STATS and *_IND_STATS
Rem                          *_TAB_STATS -> *_TAB_STATISTICS
Rem                          *_IND_STATS -> *_IND_STATISTICS
Rem                          fixed table stats in *_TAB_STATISTICS
Rem    mtyulene   10/20/02 - add [ALL DBA USER]_TAB_STATS AND
Rem                          [ALL DBA USER]_IND_STATS
Rem    mtakahar   08/06/02 - #(2352663) fix num_buckets, add histogram col
Rem    arithikr   01/16/02 - 1534815: fix dba_part_indexes view
Rem    attran     12/05/01 - List Sub_PIOT.
Rem    araghava   11/21/01 - 1912886: use row_number function to get 
Rem                          partition_position.
Rem    shshanka   11/16/01 - Fix user_lob_templates view.
Rem    vshukla    10/28/01 - hsc: row movement course correction!.
Rem    vshukla    09/26/01 - modify *_PART_TABLES, *_TAB_[SUB]PARTITIONS.
Rem                          to include compression/row movement.
Rem    sbedarka   10/01/01 - #(1551726) correct COMPOSITE column typo
Rem    aime       08/28/01 - Fix view ALL_IND_SUBPARTITIONS
Rem    sbasu      08/16/01 - modify views for Range List partitioning.
Rem    shshanka   07/17/01 - Add views on top of defsubpart$ and defsubpartlob$.
Rem    gviswana   05/24/01 - CREATE AND REPLACE SYNONYM
Rem    htseng     04/12/01 - eliminate execute twice (remove ;).
Rem    smuthuli   03/15/01 - pctused,freelist,flgroups=NULL for bitmapsegs
Rem    spsundar   10/17/00 - fix *_ind_partitions for null tblspc for dom idx
Rem    attran     04/28/00 - PIOT: List Partitioning *_PART_TABLES.
Rem    ayalaman   03/28/00 - overflow statistics for IOT
Rem    spsundar   02/14/00 - update *_part_indexes and *_ind_partitions
Rem    sbasu      02/03/00 - support for List partitioning
Rem    attran     09/22/99 - PIOT: TABPART$/blkcnt
Rem    qyu        09/16/99 - undo cache reads lob mode logging fix
Rem    qyu        07/27/99 - keep YES/NO value in cache columns for lob
Rem    tlee       06/28/99 - cache reads lob mode logging fix
Rem    attran     03/31/99 - PIOT: definitions of *_PART_TABLES
Rem    qyu        03/04/99 - add CACHE READS lob mode
Rem    thoang     11/13/98 - Mod views to return attribute name for ADT col    
Rem    mjaganna   11/12/98 - Fix PIOT view related bugs (750662)
Rem    ielayyan   11/02/98 - 748786, make ALL_ views visible to grantee
Rem    sbasu      09/08/98 - replace 2147483647 with NULL in decode expressions 
Rem                          for deftiniexts, defextsize, defminexts, defmaxexts,
Rem                          defextpct in *_PART_TABLE and *_PART_INDEXES views 
Rem    tlee       08/19/98 - remove to_char of extsize in lob_subpartitions
Rem    amozes     07/24/98 - global index stats                                
Rem    smuthuli   07/30/98 - Bug 696705
Rem    amozes     08/24/98 - expose endpoint actual value                      
Rem    ayalaman   07/21/98 - change tab_partitions views to show iot tabpart
Rem    akruglik   07/22/98 - in *_PART_LOBS and *_LOB_PARTITIONS (describing 
Rem                          Composite partitions) DEFAULT BUFFER_POOL will be
Rem                          represented by 0, not NULL
Rem    ayalaman   06/12/98 - add guess stats to user_ind_partitions
Rem    akruglik   05/29/98 - correct predicate in _PART_LOBS views             
Rem    amozes     06/01/98 - analyze composite statistics                      
Rem    ayalaman   06/05/98 - add COMPRESSION to *_ind_part views
Rem    syeung     05/08/98 - store unspecified dflt logging attr. for Composite
Rem                          partition in _TAB_PARTITIONS and _IND_PARTITIONS 
Rem                          views
Rem    akruglik   05/14/98 - modify definitions of *_LOB_[SUB]PARTITIONS to 
Rem                          display CHUNK size of physical fragments in bytes 
Rem                          rahter than blocks
Rem    akruglik   05/01/98 - define {USER|ALL|DBA}_PART_LOBS, 
Rem                          {USER|ALL|DBA}_LOB_PARTITIONS, and 
Rem                          {USER|ALL|DBA}_LOB_SUBPARTITIONS
Rem    syeung     02/24/98 - default tablespace for Composite partition can no
Rem                          longer be KTSNINV (i.e. remove outer join in 
Rem                          _TAB_PARTITIONS views for Composite table)
Rem    amozes     03/27/98 - add new stats information                         
Rem    sbasu      02/25/98 - support for range-composite part. local indexes
Rem                          change ref. comppart$->tabcompart$
Rem    thoang     12/15/97 - Modified views to exclude unused columns.
Rem    syeung     12/31/97 - code cleanups for partitioning project:
Rem                          - rename EXTHASH->HASH & remove HYBRID from 
Rem                            partitioning_type of {USER|ALL|DBA}_PART_TABLES
Rem                             and {USER|ALL|DBA}_PART_INDEXES views 
Rem                          - remove TABLESPACE_COUNT from _PART_TABLES and
Rem                            {USER|ALL|DBA}_TAB_PARTITIONS views
Rem                          - remove {USER|ALL|DBA}_TABLESPACE_LISTS views
Rem                          - change ref. to hybpart$->comppart$
Rem    syeung     12/16/97 - boolean column HYBRID in ALL_TAB_PARTITIONS & DBA_
Rem    syeung     12/09/97 - decode deflists and defgroups in USER_TAB_PARTITIO
Rem    syeung     11/17/97 - add object_type for _TABLESPACE_LISTS views
Rem    sbasu      11/10/97 - alter definition of alignment field in PART_INDEXES
Rem                          family of views to correctly display local 
Rem                          SYSTEM partitioned indexes
Rem    akruglik   11/03/97 - default number of subpartitions may ne upto 64K, 
Rem    syeung     11/01/97 - refer to partobj$.spare2 for tscnt
Rem    syeung     10/07/97 - use hybpart$ for Hybrid partition information
Rem                          so the expression in *_PART_TABLES should use 
Rem                          mod 65536
Rem    nireland   09/19/97 - Remove magic numbers. #502160
Rem    akruglik   09/11/97 - add OBJECT_TYPE column to *_PART_KEY_COLUMNS views
Rem    sbasu      07/30/97 - #504196: Add freelist_groups to *_IND_PARTITIONS
Rem    syeung     07/03/97 - add SUBPART_KEY_COLUMNS family
Rem    akruglik   06/09/97 - Hybrid partitioning will no longer be
Rem                          determinable by checking patytype - subparttype
Rem                          should be checked instead
Rem    akruglik   05/21/97 - alter WHERE-clause of {USER|ALL|DBA}_PART_INDEXES
Rem                          so it does not rely on system-specific value of 
Rem                          KTSNINV
Rem    aho        04/18/97 - partitioned cache
Rem    syeung     05/07/97 - pti 8.1 project
Rem    akruglik   05/02/97 - 8.1 Partitioning Project: 
Rem                          alter definitions of view in PART_TABLES and 
Rem                          PART_INDEXES families to correctly display 
Rem                          PARTITIONING_TYPE of objects partitioned by 
Rem                          System, Extensible Hash and Hybrid
Rem    achaudhr   03/10/97 - #(454169): catnopart.sql -> catnoprt.sql
Rem    achaudhr   11/22/96 - PART_COL_STATISTICS: reorder columns
Rem    ssamu      08/13/96 - fix view xxx_part_key_columns to show index partit
Rem    mmonajje   05/20/96 - Replace timestamp col name with timestamp#
Rem    atsukerm   05/13/96 - tablespace-relative DBAs - fix TAB_PARTITIONS and
Rem                          IND_PARTITIONS
Rem    asurpur    04/08/96 - Dictionary Protection Implementation
Rem    jwijaya    03/29/96 - test for hidden columns
Rem    achaudhr   03/21/96 - fix PART_HISTOGRAMS
Rem    akruglik   03/21/96 - another change related to default tablespace of
Rem                          LOCAL indexes - since we are using an outer join
Rem                          in the definition of user|all|dba_part_indexes, 
Rem                          there is no reason to decode po.defts#
Rem    akruglik   03/20/96 - definitions of {user|dba|all}_part_indexes need to
Rem    akruglik   03/12/96 - change qualification of 
Rem                          {user|dba|all}_part_indexes to account for the 
Rem                          fact that LOCAL indexes may have no default 
Rem                          TABLESPACE associated with them
Rem    akruglik   02/28/96 - add def_logging and logging attributes to
Rem                          {USER | ALL | DBA}_PART_{INDEXES | TABLES} and 
Rem                          {USER | ALL | DBA}_{IND | TAB}_PARTITIONS
Rem    sbasu      11/21/95 - Add STATUS field to {USER|ALL_DBA}_IND_PARTITIONS and modify names 
Rem    achaudhr   10/30/95 - Create the views
Rem

remark
remark  FAMILY "PART_TABLES"
remark   This family of views will describe the object level partitioning 
remark   information for partitioned tables. 
remark   pctused, freelists, freelist groups are null for bitmap segments
remark
create or replace view USER_PART_TABLES 
  (TABLE_NAME, PARTITIONING_TYPE, SUBPARTITIONING_TYPE, 
   PARTITION_COUNT, DEF_SUBPARTITION_COUNT, PARTITIONING_KEY_COUNT, 
   SUBPARTITIONING_KEY_COUNT, STATUS,
   DEF_TABLESPACE_NAME, DEF_PCT_FREE, DEF_PCT_USED, DEF_INI_TRANS, 
   DEF_MAX_TRANS, DEF_INITIAL_EXTENT, DEF_NEXT_EXTENT, DEF_MIN_EXTENTS, 
   DEF_MAX_EXTENTS, DEF_PCT_INCREASE, DEF_FREELISTS, DEF_FREELIST_GROUPS,
   DEF_LOGGING, DEF_COMPRESSION, DEF_BUFFER_POOL)
as 
select o.name,
       decode(po.parttype, 1, 'RANGE', 2, 'HASH', 3, 'SYSTEM', 4, 'LIST', 
                                                                  'UNKNOWN'), 
       decode(mod(po.spare2, 256), 0, 'NONE', 2, 'HASH', 3, 'SYSTEM', 
                                      4, 'LIST', 'UNKNOWN'),
       po.partcnt, mod(trunc(po.spare2/65536), 65536), po.partkeycols, 
       mod(trunc(po.spare2/256), 256),
       decode(bitand(t.trigflag, 1073741824), 1073741824, 'UNUSABLE', 'VALID'),
       ts.name, po.defpctfree, 
       decode(bitand(ts.flags, 32), 32, to_number(NULL), po.defpctused), 
       po.definitrans,
       po.defmaxtrans, 
       decode(po.deftiniexts, NULL, 'DEFAULT', po.deftiniexts),
       decode(po.defextsize, NULL, 'DEFAULT', po.defextsize),
       decode(po.defminexts, NULL, 'DEFAULT', po.defminexts),
       decode(po.defmaxexts, NULL, 'DEFAULT', po.defmaxexts),
       decode(po.defextpct, NULL, 'DEFAULT', po.defextpct),
       po.deflists, po.defgroups,
       decode(po.deflogging, 0, 'NONE', 1, 'YES', 2, 'NO', 'UNKNOWN'),
       decode(mod(trunc(po.spare2/4294967296),256), 0, 'NONE', 1, 'ENABLED',  
                     2, 'DISABLED', 'UNKNOWN'),
       decode(po.spare1, 0, 'DEFAULT', 1, 'KEEP', 2, 'RECYCLE', NULL)
from   sys.obj$ o, sys.partobj$ po, sys.ts$ ts, sys.tab$ t
where  o.obj# = po.obj# and po.defts# = ts.ts# and t.obj# = o.obj# and
       o.owner# = userenv('SCHEMAID') and o.subname IS NULL and
       o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL and
       bitand(t.property, 64 + 128) = 0
union all -- NON-IOT and IOT
select o.name,
       decode(po.parttype, 1, 'RANGE', 2, 'HASH', 3, 'SYSTEM', 4, 'LIST', 
                                                                  'UNKNOWN'), 
       decode(mod(po.spare2, 256), 0, 'NONE', 2, 'HASH', 3, 'SYSTEM', 
                                      4, 'LIST', 'UNKNOWN'),
       po.partcnt, mod(trunc(po.spare2/65536), 65536), po.partkeycols, 
       mod(trunc(po.spare2/256), 256),
       decode(bitand(t.trigflag, 1073741824), 1073741824, 'UNUSABLE', 'VALID'),
       NULL, TO_NUMBER(NULL),TO_NUMBER(NULL),TO_NUMBER(NULL),TO_NUMBER(NULL),
       NULL,--decode(po.deftiniexts, NULL, 'DEFAULT', po.deftiniexts),
       NULL,--decode(po.defextsize, NULL, 'DEFAULT', po.defextsize),
       NULL,--decode(po.defminexts, NULL, 'DEFAULT', po.defminexts),
       NULL,--decode(po.defmaxexts, NULL, 'DEFAULT', po.defmaxexts),
       NULL,--decode(po.defextpct, NULL, 'DEFAULT', po.defextpct),
       TO_NUMBER(NULL),TO_NUMBER(NULL),--po.deflists, po.defgroups,
       decode(po.deflogging, 0, 'NONE', 1, 'YES', 2, 'NO', 'UNKNOWN'),
       'N/A', 
       decode(po.spare1, 0, 'DEFAULT', 1, 'KEEP', 2, 'RECYCLE', NULL)
from   sys.obj$ o, sys.partobj$ po, sys.tab$ t
where  o.obj# = po.obj# and t.obj# = o.obj# and
       o.owner# = userenv('SCHEMAID') and o.subname IS NULL and
       o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL and
       bitand(t.property, 64 + 128) != 0
/ 
create or replace public synonym USER_PART_TABLES for USER_PART_TABLES 
/
grant select on USER_PART_TABLES to PUBLIC with grant option
/
create or replace view ALL_PART_TABLES 
  (OWNER, TABLE_NAME, PARTITIONING_TYPE, SUBPARTITIONING_TYPE, 
   PARTITION_COUNT, DEF_SUBPARTITION_COUNT, PARTITIONING_KEY_COUNT, 
   SUBPARTITIONING_KEY_COUNT, STATUS,
   DEF_TABLESPACE_NAME, DEF_PCT_FREE, DEF_PCT_USED, DEF_INI_TRANS, 
   DEF_MAX_TRANS, DEF_INITIAL_EXTENT, DEF_NEXT_EXTENT, DEF_MIN_EXTENTS, 
   DEF_MAX_EXTENTS, DEF_PCT_INCREASE, DEF_FREELISTS, DEF_FREELIST_GROUPS,
   DEF_LOGGING, DEF_COMPRESSION, DEF_BUFFER_POOL)
as 
select u.name, o.name, 
       decode(po.parttype, 1, 'RANGE', 2, 'HASH', 3, 'SYSTEM', 4, 'LIST', 
                                                                  'UNKNOWN'), 
       decode(mod(po.spare2, 256), 0, 'NONE', 2, 'HASH', 3, 'SYSTEM', 
                                      4, 'LIST', 'UNKNOWN'),
       po.partcnt, mod(trunc(po.spare2/65536), 65536), po.partkeycols,
       mod(trunc(po.spare2/256), 256), 
       decode(bitand(t.trigflag, 1073741824), 1073741824, 'UNUSABLE', 'VALID'),
       ts.name, po.defpctfree,
       decode(bitand(ts.flags, 32), 32, to_number(NULL), po.defpctused),
       po.definitrans,
       po.defmaxtrans,
       decode(po.deftiniexts, NULL, 'DEFAULT', po.deftiniexts),
       decode(po.defextsize, NULL, 'DEFAULT', po.defextsize),
       decode(po.defminexts, NULL, 'DEFAULT', po.defminexts),
       decode(po.defmaxexts, NULL, 'DEFAULT', po.defmaxexts),
       decode(po.defextpct, NULL, 'DEFAULT', po.defextpct),
       decode(bitand(ts.flags, 32), 32, to_number(NULL), po.deflists),
       decode(bitand(ts.flags, 32), 32,  to_number(NULL),po.defgroups),
       decode(po.deflogging, 0, 'NONE', 1, 'YES', 2, 'NO', 'UNKNOWN'),
       decode(mod(trunc(po.spare2/4294967296),256), 0, 'NONE', 1, 'ENABLED',  
                     2, 'DISABLED', 'UNKNOWN'),
       decode(po.spare1, 0, 'DEFAULT', 1, 'KEEP', 2, 'RECYCLE', NULL)
from   sys.obj$ o, sys.partobj$ po, sys.ts$ ts, sys.tab$ t, sys.user$ u
where  o.obj# = po.obj# and po.defts# = ts.ts# and t.obj# = o.obj# and
       o.owner# = u.user# and 
       bitand(t.property, 64 + 128) = 0 and o.subname IS NULL and 
       o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL and
       (o.owner# = userenv('SCHEMAID')
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
union all -- NON-IOT and IOT
select u.name, o.name, 
       decode(po.parttype, 1, 'RANGE', 2, 'HASH', 3, 'SYSTEM', 4, 'LIST', 
                                                                  'UNKNOWN'), 
       decode(mod(po.spare2, 256), 0, 'NONE', 2, 'HASH', 3, 'SYSTEM', 
                                      4, 'LIST', 'UNKNOWN'),
       po.partcnt, mod(trunc(po.spare2/65536), 65536), po.partkeycols,
       mod(trunc(po.spare2/256), 256), 
       decode(bitand(t.trigflag, 1073741824), 1073741824, 'UNUSABLE', 'VALID'),
       NULL, TO_NUMBER(NULL),TO_NUMBER(NULL),TO_NUMBER(NULL),TO_NUMBER(NULL),
       NULL,--decode(po.deftiniexts, NULL, 'DEFAULT', po.deftiniexts),
       NULL,--decode(po.defextsize, NULL, 'DEFAULT', po.defextsize),
       NULL,--decode(po.defminexts, NULL, 'DEFAULT', po.defminexts),
       NULL,--decode(po.defmaxexts, NULL, 'DEFAULT', po.defmaxexts),
       NULL,--decode(po.defextpct, NULL, 'DEFAULT', po.defextpct),
       TO_NUMBER(NULL),TO_NUMBER(NULL),--po.deflists, po.defgroups,
       decode(po.deflogging, 0, 'NONE', 1, 'YES', 2, 'NO', 'UNKNOWN'),
       'N/A',
       decode(po.spare1, 0, 'DEFAULT', 1, 'KEEP', 2, 'RECYCLE', NULL)
from   sys.obj$ o, sys.partobj$ po, sys.tab$ t, sys.user$ u
where  o.obj# = po.obj# and t.obj# = o.obj# and
       o.owner# = u.user# and 
       bitand(t.property, 64 + 128) != 0 and o.subname IS NULL and 
       o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL and
       (o.owner# = userenv('SCHEMAID')
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
create or replace public synonym ALL_PART_TABLES for ALL_PART_TABLES 
/
grant select on ALL_PART_TABLES to PUBLIC with grant option
/
create or replace view DBA_PART_TABLES 
  (OWNER, TABLE_NAME, PARTITIONING_TYPE, SUBPARTITIONING_TYPE, 
   PARTITION_COUNT, DEF_SUBPARTITION_COUNT, PARTITIONING_KEY_COUNT, 
   SUBPARTITIONING_KEY_COUNT, STATUS,
   DEF_TABLESPACE_NAME, DEF_PCT_FREE, DEF_PCT_USED, DEF_INI_TRANS, 
   DEF_MAX_TRANS, DEF_INITIAL_EXTENT, DEF_NEXT_EXTENT, DEF_MIN_EXTENTS, 
   DEF_MAX_EXTENTS, DEF_PCT_INCREASE, DEF_FREELISTS, DEF_FREELIST_GROUPS,
   DEF_LOGGING, DEF_COMPRESSION, DEF_BUFFER_POOL)
as 
select u.name, o.name, 
       decode(po.parttype, 1, 'RANGE', 2, 'HASH', 3, 'SYSTEM', 4, 'LIST', 
                                                                  'UNKNOWN'), 
       decode(mod(po.spare2, 256), 0, 'NONE', 2, 'HASH', 3, 'SYSTEM',
                                      4, 'LIST', 'UNKNOWN'),
       po.partcnt, mod(trunc(po.spare2/65536), 65536), po.partkeycols, 
       mod(trunc(po.spare2/256), 256),
       decode(bitand(t.trigflag, 1073741824), 1073741824, 'UNUSABLE', 'VALID'),
       ts.name, po.defpctfree, 
       decode(bitand(ts.flags, 32), 32,  to_number(NULL),po.defpctused),
       po.definitrans,
       po.defmaxtrans,
       decode(po.deftiniexts, NULL, 'DEFAULT', po.deftiniexts),
       decode(po.defextsize, NULL, 'DEFAULT', po.defextsize),
       decode(po.defminexts, NULL, 'DEFAULT', po.defminexts),
       decode(po.defmaxexts, NULL, 'DEFAULT', po.defmaxexts),
       decode(po.defextpct, NULL, 'DEFAULT', po.defextpct),
       decode(bitand(ts.flags, 32), 32,  to_number(NULL),po.deflists),
       decode(bitand(ts.flags, 32), 32, to_number(NULL), po.defgroups),
       decode(po.deflogging, 0, 'NONE', 1, 'YES', 2, 'NO', 'UNKNOWN'),
       decode(mod(trunc(po.spare2/4294967296),256), 0, 'NONE', 1, 'ENABLED',  
                     2, 'DISABLED', 'UNKNOWN'),
       decode(po.spare1, 0, 'DEFAULT', 1, 'KEEP', 2, 'RECYCLE', NULL)
from   sys.obj$ o, sys.partobj$ po, sys.ts$ ts, sys.tab$ t, sys.user$ u
where  o.obj# = po.obj# and po.defts# = ts.ts# and t.obj# = o.obj# and
       o.owner# = u.user# and o.subname IS NULL and
       o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL and
       bitand(t.property, 64 + 128) = 0
union all -- NON-IOT and IOT
select u.name, o.name, 
       decode(po.parttype, 1, 'RANGE', 2, 'HASH', 3, 'SYSTEM', 4, 'LIST', 
                                                                  'UNKNOWN'), 
       decode(mod(po.spare2, 256), 0, 'NONE', 2, 'HASH', 3, 'SYSTEM',
                                     4, 'LIST', 'UNKNOWN'),
       po.partcnt, mod(trunc(po.spare2/65536), 65536), po.partkeycols, 
       mod(trunc(po.spare2/256), 256),
       decode(bitand(t.trigflag, 1073741824), 1073741824, 'UNUSABLE', 'VALID'),
       NULL, TO_NUMBER(NULL),TO_NUMBER(NULL),TO_NUMBER(NULL),TO_NUMBER(NULL),
       NULL,--decode(po.deftiniexts, NULL, 'DEFAULT', po.deftiniexts),
       NULL,--decode(po.defextsize, NULL, 'DEFAULT', po.defextsize),
       NULL,--decode(po.defminexts, NULL, 'DEFAULT', po.defminexts),
       NULL,--decode(po.defmaxexts, NULL, 'DEFAULT', po.defmaxexts),
       NULL,--decode(po.defextpct, NULL, 'DEFAULT', po.defextpct),
       TO_NUMBER(NULL),TO_NUMBER(NULL),--po.deflists, po.defgroups,
       decode(po.deflogging, 0, 'NONE', 1, 'YES', 2, 'NO', 'UNKNOWN'),
       'N/A',
       decode(po.spare1, 0, 'DEFAULT', 1, 'KEEP', 2, 'RECYCLE', NULL)
from   sys.obj$ o, sys.partobj$ po, sys.tab$ t, sys.user$ u
where  o.obj# = po.obj# and t.obj# = o.obj# and
       o.owner# = u.user# and o.subname IS NULL and 
       o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL and
       bitand(t.property, 64 + 128) != 0
/ 
create or replace public synonym DBA_PART_TABLES for DBA_PART_TABLES
/
grant select on DBA_PART_TABLES to select_catalog_role
/

remark
remark  FAMILY "PART_INDEXES"
remark   This family of views will describe the object level partitioning
remark   information for partitioned indexes.
remark
create or replace view USER_PART_INDEXES
  (INDEX_NAME, TABLE_NAME, PARTITIONING_TYPE, SUBPARTITIONING_TYPE, 
   PARTITION_COUNT, DEF_SUBPARTITION_COUNT, 
   PARTITIONING_KEY_COUNT, SUBPARTITIONING_KEY_COUNT, 
   LOCALITY, ALIGNMENT, DEF_TABLESPACE_NAME, 
   DEF_PCT_FREE, DEF_INI_TRANS, DEF_MAX_TRANS, DEF_INITIAL_EXTENT, 
   DEF_NEXT_EXTENT, DEF_MIN_EXTENTS, DEF_MAX_EXTENTS, DEF_PCT_INCREASE, 
   DEF_FREELISTS, DEF_FREELIST_GROUPS, DEF_LOGGING, DEF_BUFFER_POOL,
   DEF_PARAMETERS)
as 
select io.name, o.name,
        decode(po.parttype, 1, 'RANGE', 2, 'HASH', 3, 'SYSTEM', 4, 'LIST', 
                                                                   'UNKNOWN'),
        decode(mod(po.spare2, 256), 0, 'NONE', 2, 'HASH', 3, 'SYSTEM', 
                                      4, 'LIST', 'UNKNOWN'),
       po.partcnt, mod(trunc(po.spare2/65536), 65536), 
       po.partkeycols,  mod(trunc(po.spare2/256), 256),
       decode(bitand(po.flags, 1), 1, 'LOCAL',    'GLOBAL'),
       decode(po.partkeycols, 0, 'NONE', decode(bitand(po.flags,2), 2, 'PREFIXED', 'NON_PREFIXED')),
       ts.name, po.defpctfree, po.definitrans,
       po.defmaxtrans,
       decode(po.deftiniexts, NULL, 'DEFAULT', po.deftiniexts),
       decode(po.defextsize, NULL, 'DEFAULT', po.defextsize),
       decode(po.defminexts, NULL, 'DEFAULT', po.defminexts),
       decode(po.defmaxexts, NULL, 'DEFAULT', po.defmaxexts),
       decode(po.defextpct, NULL, 'DEFAULT', po.defextpct),
       po.deflists, po.defgroups,
       decode(po.deflogging, 0, 'NONE', 1, 'YES', 2, 'NO', 'UNKNOWN'),
       decode(po.spare1, 0, 'DEFAULT', 1, 'KEEP', 2, 'RECYCLE', NULL),
       po.parameters
from   sys.obj$ io, sys.obj$ o, sys.partobj$ po, sys.ts$ ts, sys.ind$ i
where  io.obj# = po.obj# and po.defts# = ts.ts# (+) and i.obj# = io.obj#
       and o.obj# = i.bo# and io.owner# = userenv('SCHEMAID') and
       io.namespace = 4 and io.remoteowner IS NULL and io.linkname IS NULL 
       and io.subname IS NULL
/ 
create or replace public synonym USER_PART_INDEXES for USER_PART_INDEXES
/
grant select on USER_PART_INDEXES to PUBLIC with grant option
/
create or replace view ALL_PART_INDEXES
  (OWNER, INDEX_NAME, TABLE_NAME, PARTITIONING_TYPE, SUBPARTITIONING_TYPE, 
   PARTITION_COUNT, DEF_SUBPARTITION_COUNT, PARTITIONING_KEY_COUNT,
   SUBPARTITIONING_KEY_COUNT, LOCALITY, ALIGNMENT, DEF_TABLESPACE_NAME,
   DEF_PCT_FREE, DEF_INI_TRANS, DEF_MAX_TRANS, DEF_INITIAL_EXTENT,
   DEF_NEXT_EXTENT, DEF_MIN_EXTENTS, DEF_MAX_EXTENTS, DEF_PCT_INCREASE,
   DEF_FREELISTS, DEF_FREELIST_GROUPS, DEF_LOGGING, DEF_BUFFER_POOL,
   DEF_PARAMETERS)
as 
select u.name, io.name, o.name,
       decode(po.parttype, 1, 'RANGE', 2, 'HASH', 3, 'SYSTEM', 4, 'LIST',
                                                                  'UNKNOWN'),
       decode(mod(po.spare2, 256), 0, 'NONE', 2, 'HASH', 3, 'SYSTEM', 
                                      4, 'LIST', 'UNKNOWN'), 
       po.partcnt, mod(trunc(po.spare2/65536), 65536), 
       po.partkeycols, mod(trunc(po.spare2/256), 256),
       decode(bitand(po.flags, 1), 1, 'LOCAL',    'GLOBAL'),
       decode(po.partkeycols, 0, 'NONE', decode(bitand(po.flags,2), 2, 'PREFIXED', 'NON_PREFIXED')),
       ts.name, po.defpctfree, po.definitrans,
       po.defmaxtrans,
       decode(po.deftiniexts, NULL, 'DEFAULT', po.deftiniexts),
       decode(po.defextsize, NULL, 'DEFAULT', po.defextsize),
       decode(po.defminexts, NULL, 'DEFAULT', po.defminexts),
       decode(po.defmaxexts, NULL, 'DEFAULT', po.defmaxexts),
       decode(po.defextpct, NULL, 'DEFAULT', po.defextpct),
       po.deflists, po.defgroups,
       decode(po.deflogging, 0, 'NONE', 1, 'YES', 2, 'NO', 'UNKNOWN'),
       decode(po.spare1, 0, 'DEFAULT', 1, 'KEEP', 2, 'RECYCLE', NULL),
       po.parameters
from   sys.obj$ io, sys.obj$ o, sys.partobj$ po, sys.ts$ ts, sys.ind$ i,
       sys.user$ u
where  io.obj# = po.obj# and po.defts# = ts.ts# (+) and
       i.obj# = io.obj# and o.obj# = i.bo# and u.user# = io.owner# and
       i.type# != 8 and      /* not LOB index */ 
       io.subname IS NULL and 
       io.namespace = 4 and io.remoteowner IS NULL and io.linkname IS NULL and
       (io.owner# = userenv('SCHEMAID') 
        or
        i.bo# in ( select obj#
                    from objauth$
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
create or replace public synonym ALL_PART_INDEXES for ALL_PART_INDEXES
/
grant select on ALL_PART_INDEXES to PUBLIC with grant option
/
create or replace view DBA_PART_INDEXES
  (OWNER, INDEX_NAME, TABLE_NAME, PARTITIONING_TYPE, SUBPARTITIONING_TYPE,
   PARTITION_COUNT, DEF_SUBPARTITION_COUNT, PARTITIONING_KEY_COUNT,
   SUBPARTITIONING_KEY_COUNT,
   LOCALITY, ALIGNMENT, DEF_TABLESPACE_NAME, DEF_PCT_FREE, DEF_INI_TRANS, 
   DEF_MAX_TRANS, DEF_INITIAL_EXTENT, DEF_NEXT_EXTENT, DEF_MIN_EXTENTS, 
   DEF_MAX_EXTENTS, DEF_PCT_INCREASE, DEF_FREELISTS, DEF_FREELIST_GROUPS,
   DEF_LOGGING, DEF_BUFFER_POOL, DEF_PARAMETERS)
as 
select u.name, io.name, o.name,
       decode(po.parttype, 1, 'RANGE', 2, 'HASH', 3, 'SYSTEM', 4, 'LIST',
                                                                  'UNKNOWN'), 
       decode(mod(po.spare2, 256), 0, 'NONE', 2, 'HASH', 3, 'SYSTEM',
                                      4, 'LIST', 'UNKNOWN'),
       po.partcnt, mod(trunc(po.spare2/65536), 65536), po.partkeycols, 
       mod(trunc(po.spare2/256), 256), decode(bitand(po.flags, 1), 1, 'LOCAL',    'GLOBAL'),
       decode(po.partkeycols, 0, 'NONE', decode(bitand(po.flags,2), 2, 'PREFIXED', 'NON_PREFIXED')),       
       ts.name, po.defpctfree, po.definitrans,
       po.defmaxtrans,
       decode(po.deftiniexts, NULL, 'DEFAULT', po.deftiniexts),
       decode(po.defextsize, NULL, 'DEFAULT', po.defextsize),
       decode(po.defminexts, NULL, 'DEFAULT', po.defminexts),
       decode(po.defmaxexts, NULL, 'DEFAULT', po.defmaxexts),
       decode(po.defextpct,  NULL, 'DEFAULT', po.defextpct),
       po.deflists, po.defgroups,
       decode(po.deflogging, 0, 'NONE', 1, 'YES', 2, 'NO', 'UNKNOWN'),
       decode(po.spare1, 0, 'DEFAULT', 1, 'KEEP', 2, 'RECYCLE', NULL),
       po.parameters
from   sys.obj$ io, sys.obj$ o, sys.partobj$ po, sys.ts$ ts, sys.ind$ i,
       sys.user$ u
where  io.obj# = po.obj# and po.defts# = ts.ts# (+) and
       i.obj# = io.obj# and o.obj# = i.bo# and u.user# = io.owner# and
       io.namespace = 4 and io.remoteowner IS NULL and io.linkname IS NULL 
       and io.subname IS NULL
/ 
create or replace public synonym DBA_PART_INDEXES for DBA_PART_INDEXES
/
grant select on DBA_PART_INDEXES to select_catalog_role
/

remark
remark  FAMILY "PART_KEY_COLUMNS"
remark   This family of views will describe the partitioning key columns for
remark   all partitioned objects.
remark
remark   using an UNION rather than an OR for speed.
create or replace view USER_PART_KEY_COLUMNS
  (NAME, OBJECT_TYPE, COLUMN_NAME, COLUMN_POSITION)
as
select o.name, 'TABLE', 
  decode(bitand(c.property, 1), 1, a.name, c.name), pc.pos#
from partcol$ pc, obj$ o, col$ c, attrcol$ a
where pc.obj# = o.obj# and pc.obj# = c.obj# and c.intcol# = pc.intcol# and
      o.owner# = userenv('SCHEMAID') and o.subname IS NULL and
      o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  and c.obj#    = a.obj#(+)
  and c.intcol# = a.intcol#(+)
union
select io.name, 'INDEX', 
  decode(bitand(c.property, 1), 1, a.name, c.name), pc.pos#
from partcol$ pc, obj$ io, col$ c, ind$ i, attrcol$ a
where pc.obj# = i.obj# and i.obj# = io.obj# and i.bo# = c.obj# and 
c.intcol# = pc.intcol# and io.owner# = userenv('SCHEMAID') and
  io.namespace = 4 and io.remoteowner IS NULL and io.linkname IS NULL 
  and io.subname IS NULL 
  and c.obj#    = a.obj#(+)
  and c.intcol# = a.intcol#(+)
/
create or replace public synonym USER_PART_KEY_COLUMNS
   for USER_PART_KEY_COLUMNS
/
grant select on USER_PART_KEY_COLUMNS to PUBLIC with grant option
/
create or replace view ALL_PART_KEY_COLUMNS
  (OWNER, NAME, OBJECT_TYPE, COLUMN_NAME, COLUMN_POSITION)
as
select u.name, o.name, 'TABLE', 
  decode(bitand(c.property, 1), 1, a.name, c.name), pc.pos#
from partcol$ pc, obj$ o, col$ c, user$ u, attrcol$ a
where pc.obj# = o.obj# and pc.obj# = c.obj# and c.intcol# = pc.intcol# and
      c.obj#    = a.obj#(+) and c.intcol# = a.intcol#(+) and
      u.user# = o.owner# and o.subname IS NULL and 
      o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL and
      (o.owner# = userenv('SCHEMAID')
       or pc.obj# in
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
union
select u.name, io.name, 'INDEX', 
  decode(bitand(c.property, 1), 1, a.name, c.name), pc.pos#
from partcol$ pc, obj$ io, col$ c, user$ u, ind$ i, attrcol$ a
where pc.obj# = i.obj# and i.obj# = io.obj# and i.bo# = c.obj# and 
     c.intcol# = pc.intcol# and u.user# = io.owner# and 
     c.obj# = a.obj#(+) and c.intcol# = a.intcol#(+) and 
     io.subname IS NULL and
     io.namespace = 4 and io.remoteowner IS NULL and io.linkname IS NULL and
      (io.owner# = userenv('SCHEMAID')
       or i.bo# in
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
create or replace public synonym ALL_PART_KEY_COLUMNS for ALL_PART_KEY_COLUMNS
/
grant select on ALL_PART_KEY_COLUMNS to PUBLIC with grant option
/
create or replace view DBA_PART_KEY_COLUMNS
  (OWNER, NAME, OBJECT_TYPE, COLUMN_NAME, COLUMN_POSITION)
as
select u.name, o.name, 'TABLE', 
  decode(bitand(c.property, 1), 1, a.name, c.name), pc.pos#
from partcol$ pc, obj$ o, col$ c, user$ u, attrcol$ a
where pc.obj# = o.obj# and pc.obj# = c.obj# and c.intcol# = pc.intcol# and
      u.user# = o.owner# and c.obj# = a.obj#(+) and c.intcol# = a.intcol#(+)
      and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL 
      and o.subname IS NULL
union 
select u.name, io.name, 'INDEX', 
  decode(bitand(c.property, 1), 1, a.name, c.name), pc.pos#
from partcol$ pc, obj$ io, col$ c, user$ u, ind$ i, attrcol$ a
where pc.obj# = i.obj# and i.obj# = io.obj# and i.bo# = c.obj# and 
        c.intcol# = pc.intcol# and u.user# = io.owner# 
        and c.obj# = a.obj#(+) and c.intcol# = a.intcol#(+) and
        io.namespace = 4 and io.remoteowner IS NULL and io.linkname IS NULL 
        and io.subname IS NULL
/
create or replace public synonym DBA_PART_KEY_COLUMNS for DBA_PART_KEY_COLUMNS
/
grant select on DBA_PART_KEY_COLUMNS to select_catalog_role
/

remark 
remark  The following views are created because the fragment# in the 
remark  dictionaries no longer go from 1->n. Instead they go from a->b
remark  Further we now allows holes in the number sequence.
remark  These views are used to replicate the old behaviour of fragment#s.
remark  The phypart# is exposed in these views. It can be used in place
remark  of partition position where holes are not an issue. 
remark  eg:  It is used in *_IND_STATISTICS views in join to find 
remark  corresponding table partition of an index partition.
remark  Using part# will be slow because of row_number() function.

create or replace view tabpartv$
  (obj#, dataobj#, bo#, part#, hiboundlen, hiboundval, ts#, file#, block#, 
   pctfree$, pctused$, initrans, maxtrans, flags, analyzetime, samplesize, 
   rowcnt, blkcnt, empcnt, avgspc, chncnt, avgrln, phypart#)
as select obj#, dataobj#, bo#, 
          row_number() over (partition by bo# order by part#),
          hiboundlen, hiboundval, ts#, file#, block#, pctfree$, pctused$, 
          initrans, maxtrans, flags, analyzetime, samplesize, rowcnt, blkcnt, 
          empcnt, avgspc, chncnt, avgrln, part#
from tabpart$
/

grant select on tabpartv$ to select_catalog_role
/

create or replace view tabcompartv$
  (obj#, dataobj#, bo#, part#, hiboundlen, hiboundval, subpartcnt, flags,
   defts#, defpctfree, defpctused, definitrans, defmaxtrans, definiexts,
   defextsize, defminexts, defmaxexts, defextpct, deflists, defgroups,
   deflogging, defbufpool, analyzetime, samplesize, rowcnt, blkcnt,
   empcnt, avgspc, chncnt, avgrln, spare1, spare2, spare3, phypart#)
as select obj#, dataobj#, bo#, 
          row_number() over (partition by bo# order by part#), 
          hiboundlen, hiboundval, subpartcnt, flags, defts#, defpctfree, 
          defpctused, definitrans, defmaxtrans, definiexts,
          defextsize, defminexts, defmaxexts, defextpct, deflists, defgroups,
          deflogging, defbufpool, analyzetime, samplesize, rowcnt, blkcnt,
          empcnt, avgspc, chncnt, avgrln, spare1, spare2, spare3, part#
from tabcompart$;

grant select on tabcompartv$ to select_catalog_role
/

create or replace view tabsubpartv$
  (obj#, dataobj#, pobj#, subpart#, flags, ts#, file#, block#, pctfree$,
   pctused$, initrans, maxtrans, analyzetime, samplesize, rowcnt, blkcnt,
   empcnt, avgspc, chncnt, avgrln, spare1, spare2, spare3,
   hiboundlen, hiboundval, physubpart#)
as select obj#, dataobj#, pobj#, 
          row_number() over (partition by pobj# order by subpart#), 
          flags, ts#, file#, block#, pctfree$,
          pctused$, initrans, maxtrans, analyzetime, samplesize, rowcnt, 
          blkcnt, empcnt, avgspc, chncnt, avgrln, spare1, spare2, spare3,
          hiboundlen, hiboundval, subpart#
from tabsubpart$
/

grant select on tabsubpartv$ to select_catalog_role
/

create or replace view indpartv$
  (obj#, dataobj#, bo#, part#, hiboundlen, hiboundval, flags, ts#, file#, 
   block#, pctfree$, pctthres$, initrans, maxtrans, analyzetime, samplesize,
   rowcnt, blevel, leafcnt, distkey, lblkkey, dblkkey, clufac, spare1,
   spare2, spare3, inclcol, phypart#)
as select obj#, dataobj#, bo#, 
          row_number() over (partition by bo# order by part#),
          hiboundlen, hiboundval, flags, ts#, file#, block#,
          pctfree$, pctthres$, initrans, maxtrans, analyzetime, samplesize,
          rowcnt, blevel, leafcnt, distkey, lblkkey, dblkkey, clufac, spare1,
          spare2, spare3, inclcol, part#
from indpart$
/

grant select on indpartv$ to select_catalog_role
/

create or replace view indcompartv$
  (obj#, dataobj#, bo#, part#, hiboundlen, hiboundval, subpartcnt, flags, 
   defts#, defpctfree, definitrans, defmaxtrans, definiexts, defextsize,
   defminexts, defmaxexts, defextpct, deflists, defgroups, deflogging,
   defbufpool, analyzetime, samplesize, rowcnt, blevel, leafcnt, distkey,
   lblkkey, dblkkey, clufac, spare1, spare2, spare3, phypart#)
as select obj#, dataobj#, bo#, 
          row_number() over (partition by bo# order by part#),
          hiboundlen, hiboundval, subpartcnt, flags, defts#,
          defpctfree, definitrans, defmaxtrans, definiexts, defextsize,
          defminexts, defmaxexts, defextpct, deflists, defgroups, deflogging,
          defbufpool, analyzetime, samplesize, rowcnt, blevel, leafcnt, 
          distkey, lblkkey, dblkkey, clufac, spare1, spare2, spare3, part#
from indcompart$
/

grant select on indcompartv$ to select_catalog_role
/

create or replace view indsubpartv$
  (obj#, dataobj#, pobj#, subpart#, flags, ts#, file#, block#, pctfree$,
   initrans, maxtrans, analyzetime, samplesize, rowcnt, blevel, leafcnt,
   distkey, lblkkey, dblkkey, clufac, spare1, spare2, spare3,
   hiboundlen, hiboundval, physubpart#)
as select obj#, dataobj#, pobj#, 
          row_number() over (partition by pobj# order by subpart#),
          flags, ts#, file#, block#, pctfree$,
          initrans, maxtrans, analyzetime, samplesize, rowcnt, blevel, leafcnt,
          distkey, lblkkey, dblkkey, clufac, spare1, spare2, spare3,
          hiboundlen, hiboundval, subpart#
from indsubpart$
/

grant select on indsubpartv$ to select_catalog_role
/

create or replace view lobfragv$
  (fragobj#, parentobj#, tabfragobj#, indfragobj#, frag#, fragtype$,
   ts#, file#, block#, chunk, pctversion$, fragflags, fragpro,
   spare1, spare2, spare3)
as select fragobj#, parentobj#, tabfragobj#, indfragobj#,
          row_number() over (partition by parentobj# order by frag#),
          fragtype$, ts#, file#, block#, chunk, pctversion$, fragflags, 
          fragpro, spare1, spare2, spare3
from lobfrag$
/

grant select on lobfragv$ to select_catalog_role
/

create or replace view lobcomppartv$
  (partobj#, lobj#, tabpartobj#, indpartobj#, part#, defts#, defchunk,
   defpctver$, defflags, defpro, definiexts, defextsize, defminexts,
   defmaxexts, defextpct, deflists, defgroups, defbufpool,
   spare1, spare2, spare3)
as select partobj#, lobj#, tabpartobj#, indpartobj#,
          row_number() over (partition by lobj# order by part#),
          defts#, defchunk, defpctver$, defflags, defpro, definiexts, 
          defextsize, defminexts, defmaxexts, defextpct, deflists, 
          defgroups, defbufpool, spare1, spare2, spare3
from lobcomppart$
/

grant select on lobcomppartv$ to select_catalog_role
/

remark
remark  FAMILY "TAB_PARTITIONS"
remark   This family of views will describe, for each table partition, the
remark   partition level information, the storage parameters for the 
remark   partition, and various partition statistics determined by ANALYZE.
remark   pctused, freelists, freelist groups are null for bitmap segments
remark
create or replace view USER_TAB_PARTITIONS
  (TABLE_NAME, COMPOSITE, PARTITION_NAME, SUBPARTITION_COUNT, 
   HIGH_VALUE, HIGH_VALUE_LENGTH, 
   PARTITION_POSITION, TABLESPACE_NAME, PCT_FREE, PCT_USED, 
   INI_TRANS, MAX_TRANS, INITIAL_EXTENT, NEXT_EXTENT, MIN_EXTENT, MAX_EXTENT,
   PCT_INCREASE, FREELISTS, FREELIST_GROUPS, LOGGING, COMPRESSION, 
   NUM_ROWS, BLOCKS, EMPTY_BLOCKS, AVG_SPACE, CHAIN_CNT, AVG_ROW_LEN, 
   SAMPLE_SIZE, LAST_ANALYZED, BUFFER_POOL, GLOBAL_STATS, USER_STATS)
as 
select o.name, 'NO', o.subname, 0,
       tp.hiboundval, tp.hiboundlen, tp.part#, ts.name, 
       tp.pctfree$, 
       decode(bitand(ts.flags, 32), 32, to_number(NULL), tp.pctused$), 
       tp.initrans, tp.maxtrans, s.iniexts * ts.blocksize, 
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
                               s.extsize * ts.blocksize),
       s.minexts, s.maxexts,
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
                                      s.extpct),
       decode(bitand(ts.flags, 32), 32, to_number(NULL), 
          decode(s.lists, 0, 1, s.lists)), 
       decode(bitand(ts.flags, 32), 32, to_number(NULL), 
          decode(s.groups, 0, 1, s.groups)),
       decode(mod(trunc(tp.flags / 4), 2), 0, 'YES', 'NO'),
       decode(bitand(s.spare1, 2048), 2048, 'ENABLED', 'DISABLED'),
       tp.rowcnt, tp.blkcnt, tp.empcnt, tp.avgspc, tp.chncnt, tp.avgrln,
       tp.samplesize, tp.analyzetime,
       decode(s.cachehint, 0, 'DEFAULT', 1, 'KEEP', 2, 'RECYCLE', NULL),
       decode(bitand(tp.flags, 16), 0, 'NO', 'YES'),
       decode(bitand(tp.flags, 8), 0, 'NO', 'YES')
from   obj$ o, tabpartv$ tp, ts$ ts, sys.seg$ s, sys.tab$ t
where  o.obj# = tp.obj# and ts.ts# = tp.ts# and 
       tp.file#=s.file# and tp.block#=s.block# and tp.ts#=s.ts# and 
       tp.bo# = t.obj# and bitand(t.trigflag, 1073741824) != 1073741824 and
       o.owner# = userenv('SCHEMAID')
       and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
union all -- IOT PARTITIONS
select o.name, 'NO', o.subname, 0,
       tp.hiboundval, tp.hiboundlen, tp.part#, NULL,
       TO_NUMBER(NULL),TO_NUMBER(NULL),TO_NUMBER(NULL),TO_NUMBER(NULL),
       TO_NUMBER(NULL),
       TO_NUMBER(NULL),TO_NUMBER(NULL),TO_NUMBER(NULL),TO_NUMBER(NULL),
       TO_NUMBER(NULL),TO_NUMBER(NULL),
       NULL,
       'N/A', 
       tp.rowcnt, TO_NUMBER(NULL), TO_NUMBER(NULL), 0, tp.chncnt, tp.avgrln, 
       tp.samplesize, tp.analyzetime, NULL,
       decode(bitand(tp.flags, 16), 0, 'NO', 'YES'),
       decode(bitand(tp.flags, 8), 0, 'NO', 'YES')
from   obj$ o, tabpartv$ tp, tab$ t
where  o.obj# = tp.obj# and tp.file#=0 and tp.block#=0 and 
       tp.bo# = t.obj# and bitand(t.trigflag, 1073741824) != 1073741824 and
       o.owner# = userenv('SCHEMAID')
       and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
union all -- COMPOSITE PARTITIONS
select o.name, 'YES', o.subname, tcp.subpartcnt,
       tcp.hiboundval, tcp.hiboundlen, tcp.part#, ts.name, 
       tcp.defpctfree, 
       decode(bitand(ts.flags, 32), 32, to_number(NULL), tcp.defpctused), 
       tcp.definitrans, tcp.defmaxtrans,
       tcp.definiexts, tcp.defextsize, tcp.defminexts, tcp.defmaxexts, 
       tcp.defextpct, 
       decode(bitand(ts.flags, 32), 32, to_number(NULL), tcp.deflists),
       decode(bitand(ts.flags, 32), 32,  to_number(NULL),tcp.defgroups),
       decode(tcp.deflogging, 0, 'NONE', 1, 'YES', 2, 'NO', 'UNKNOWN'),
       decode(mod(tcp.spare2,256), 0, 'NONE', 1, 'ENABLED', 2, 'DISABLED', 
                                      'UNKNOWN'),
       tcp.rowcnt, tcp.blkcnt, tcp.empcnt, tcp.avgspc, tcp.chncnt, tcp.avgrln,
       tcp.samplesize, tcp.analyzetime, 
       decode(tcp.defbufpool, 0, 'DEFAULT', 1, 'KEEP', 2, 'RECYCLE', NULL),
       decode(bitand(tcp.flags, 16), 0, 'NO', 'YES'),
       decode(bitand(tcp.flags, 8), 0, 'NO', 'YES')
from   obj$ o, tabcompartv$ tcp, ts$ ts, tab$ t
where  o.obj# = tcp.obj# and tcp.defts# = ts.ts# and 
       o.owner# = userenv('SCHEMAID') and
       o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL and
       tcp.bo# = t.obj# 
       and bitand(t.trigflag, 1073741824) != 1073741824
/
create or replace public synonym USER_TAB_PARTITIONS for USER_TAB_PARTITIONS
/
grant select on USER_TAB_PARTITIONS to PUBLIC with grant option
/
create or replace view ALL_TAB_PARTITIONS
  (TABLE_OWNER, TABLE_NAME, COMPOSITE, PARTITION_NAME, SUBPARTITION_COUNT, 
   HIGH_VALUE, HIGH_VALUE_LENGTH, 
   PARTITION_POSITION, TABLESPACE_NAME, PCT_FREE, PCT_USED, 
   INI_TRANS, MAX_TRANS, INITIAL_EXTENT, NEXT_EXTENT, MIN_EXTENT, MAX_EXTENT,
   PCT_INCREASE, FREELISTS, FREELIST_GROUPS, LOGGING, COMPRESSION, 
   NUM_ROWS, BLOCKS, EMPTY_BLOCKS, AVG_SPACE, CHAIN_CNT, AVG_ROW_LEN, 
   SAMPLE_SIZE, LAST_ANALYZED, BUFFER_POOL, GLOBAL_STATS, USER_STATS)
as 
select u.name, o.name, 'NO', o.subname, 0,
       tp.hiboundval, tp.hiboundlen, tp.part#, ts.name, 
       tp.pctfree$, 
       decode(bitand(ts.flags, 32), 32, to_number(NULL), tp.pctused$), 
       tp.initrans, tp.maxtrans, s.iniexts * ts.blocksize, 
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
                               s.extsize * ts.blocksize),
       s.minexts, s.maxexts,
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
                                      s.extpct),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
          decode(s.lists, 0, 1, s.lists)), 
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
          decode(s.groups, 0, 1, s.groups)),
       decode(mod(trunc(tp.flags / 4), 2), 0, 'YES', 'NO'),
       decode(bitand(s.spare1, 2048), 2048, 'ENABLED', 'DISABLED'),
       tp.rowcnt, tp.blkcnt, tp.empcnt, tp.avgspc, tp.chncnt, tp.avgrln,
       tp.samplesize, tp.analyzetime,
       decode(s.cachehint, 0, 'DEFAULT', 1, 'KEEP', 2, 'RECYCLE', NULL),
       decode(bitand(tp.flags, 16), 0, 'NO', 'YES'),
       decode(bitand(tp.flags, 8), 0, 'NO', 'YES')
from   obj$ o, tabpartv$ tp, ts$ ts, sys.seg$ s, user$ u, tab$ t
where  o.obj# = tp.obj# and ts.ts# = tp.ts# and u.user# = o.owner# and 
       tp.file#=s.file# and tp.block#=s.block# and tp.ts#=s.ts# and 
       tp.bo# = t.obj# and bitand(t.trigflag, 1073741824) != 1073741824 and
       o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL and
       (o.owner# = userenv('SCHEMAID') 
        or tp.bo# in
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
union all -- IOT PARTITIONS
select u.name, o.name, 'NO', o.subname, 0,
       tp.hiboundval, tp.hiboundlen, tp.part#, NULL, 
       TO_NUMBER(NULL),TO_NUMBER(NULL),TO_NUMBER(NULL),TO_NUMBER(NULL),
       TO_NUMBER(NULL),
       TO_NUMBER(NULL),TO_NUMBER(NULL),TO_NUMBER(NULL),TO_NUMBER(NULL),
       TO_NUMBER(NULL),TO_NUMBER(NULL),
       NULL,
       'N/A',
       tp.rowcnt, TO_NUMBER(NULL), TO_NUMBER(NULL), 0, tp.chncnt, tp.avgrln, 
       tp.samplesize, tp.analyzetime, NULL,
       decode(bitand(tp.flags, 16), 0, 'NO', 'YES'),
       decode(bitand(tp.flags, 8), 0, 'NO', 'YES')
from   obj$ o, tabpartv$ tp, user$ u, tab$ t
where  o.obj# = tp.obj# and o.owner# = u.user# and 
       tp.file#=0 and tp.block#=0 and tp.bo# = t.obj# and
       bitand(t.trigflag, 1073741824) != 1073741824 and
       o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL and
       (o.owner# = userenv('SCHEMAID')
        or tp.bo# in
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
union all -- COMPOSITE PARTITIONS
select u.name, o.name, 'YES', o.subname, tcp.subpartcnt, 
       tcp.hiboundval, tcp.hiboundlen, tcp.part#, ts.name, 
       tcp.defpctfree, 
       decode(bitand(ts.flags, 32), 32, to_number(NULL), tcp.defpctused),
       tcp.definitrans, tcp.defmaxtrans, 
       tcp.definiexts, tcp.defextsize, tcp.defminexts, tcp.defmaxexts, 
       tcp.defextpct, 
       decode(bitand(ts.flags, 32), 32, to_number(NULL), tcp.deflists),
       decode(bitand(ts.flags, 32), 32, to_number(NULL), tcp.defgroups),
       decode(tcp.deflogging, 0, 'NONE', 1, 'YES', 2, 'NO', 'UNKNOWN'),
       decode(mod(tcp.spare2,256), 0, 'NONE', 1, 'ENABLED', 2, 'DISABLED',
                                   'UNKNOWN'),
       tcp.rowcnt, tcp.blkcnt, tcp.empcnt, tcp.avgspc, tcp.chncnt, tcp.avgrln,
       tcp.samplesize, tcp.analyzetime, 
       decode(tcp.defbufpool, 0, 'DEFAULT', 1, 'KEEP', 2, 'RECYCLE', NULL),
       decode(bitand(tcp.flags, 16), 0, 'NO', 'YES'),
       decode(bitand(tcp.flags, 8), 0, 'NO', 'YES')
from   obj$ o, tabcompartv$ tcp, ts$ ts, user$ u, tab$ t
where  o.obj# = tcp.obj# and tcp.defts# = ts.ts# and u.user# = o.owner# and
       tcp.bo# = t.obj# 
       and bitand(t.trigflag, 1073741824) != 1073741824 and
       o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL and
       (o.owner# = userenv('SCHEMAID') 
        or tcp.bo# in
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
create or replace public synonym ALL_TAB_PARTITIONS for ALL_TAB_PARTITIONS
/
grant select on ALL_TAB_PARTITIONS to PUBLIC with grant option
/
create or replace view DBA_TAB_PARTITIONS
  (TABLE_OWNER, TABLE_NAME, COMPOSITE, PARTITION_NAME, SUBPARTITION_COUNT, 
   HIGH_VALUE, HIGH_VALUE_LENGTH, 
   PARTITION_POSITION, TABLESPACE_NAME, PCT_FREE, PCT_USED, 
   INI_TRANS, MAX_TRANS, INITIAL_EXTENT, NEXT_EXTENT, MIN_EXTENT, MAX_EXTENT,
   PCT_INCREASE, FREELISTS, FREELIST_GROUPS, LOGGING, COMPRESSION, 
   NUM_ROWS, BLOCKS, EMPTY_BLOCKS, AVG_SPACE, CHAIN_CNT, AVG_ROW_LEN, 
   SAMPLE_SIZE, LAST_ANALYZED, BUFFER_POOL, GLOBAL_STATS, USER_STATS)
as 
select u.name, o.name, 'NO', o.subname, 0,
       tp.hiboundval, tp.hiboundlen, tp.part#, ts.name, 
       tp.pctfree$, 
       decode(bitand(ts.flags, 32), 32, to_number(NULL), tp.pctused$), 
       tp.initrans, tp.maxtrans, s.iniexts * ts.blocksize, 
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
                               s.extsize * ts.blocksize),
       s.minexts, s.maxexts,
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
                                      s.extpct),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
          decode(s.lists, 0, 1, s.lists)), 
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
          decode(s.groups, 0, 1, s.groups)),
       decode(mod(trunc(tp.flags / 4), 2), 0, 'YES', 'NO'),
       decode(bitand(s.spare1, 2048), 2048, 'ENABLED', 'DISABLED'),
       tp.rowcnt, tp.blkcnt, tp.empcnt, tp.avgspc, tp.chncnt, tp.avgrln,
       tp.samplesize, tp.analyzetime,
       decode(s.cachehint, 0, 'DEFAULT', 1, 'KEEP', 2, 'RECYCLE', NULL),
       decode(bitand(tp.flags, 16), 0, 'NO', 'YES'),
       decode(bitand(tp.flags, 8), 0, 'NO', 'YES')
from   obj$ o, tabpartv$ tp, ts$ ts, sys.seg$ s, user$ u, tab$ t
where  o.obj# = tp.obj# and ts.ts# = tp.ts# and u.user# = o.owner# and 
       tp.file#=s.file# and tp.block#=s.block# and tp.ts#=s.ts# and
       tp.bo# = t.obj# and bitand(t.trigflag, 1073741824) != 1073741824
       and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
union all -- IOT PARTITIONS
select u.name, o.name, 'NO', o.subname, 0, 
       tp.hiboundval, tp.hiboundlen, tp.part#, NULL, 
       TO_NUMBER(NULL),TO_NUMBER(NULL),TO_NUMBER(NULL),TO_NUMBER(NULL),
       TO_NUMBER(NULL),
       TO_NUMBER(NULL),TO_NUMBER(NULL),TO_NUMBER(NULL),TO_NUMBER(NULL),
       TO_NUMBER(NULL),TO_NUMBER(NULL),
       NULL,
       'N/A', 
       tp.rowcnt, TO_NUMBER(NULL), TO_NUMBER(NULL), 0, tp.chncnt, tp.avgrln, 
       tp.samplesize, tp.analyzetime, NULL,
       decode(bitand(tp.flags, 16), 0, 'NO', 'YES'),
       decode(bitand(tp.flags, 8), 0, 'NO', 'YES')
from   obj$ o, tabpartv$ tp, user$ u, tab$ t
where  o.obj# = tp.obj# and o.owner# = u.user# and 
       tp.file#=0 and tp.block#=0 and tp.bo# = t.obj# and
       bitand(t.trigflag, 1073741824) != 1073741824
       and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
union all -- COMPOSITE PARTITIONS
select u.name, o.name, 'YES', o.subname, tcp.subpartcnt, 
       tcp.hiboundval, tcp.hiboundlen, tcp.part#, ts.name,
       tcp.defpctfree, decode(bitand(ts.flags, 32), 32, to_number(NULL), 
       tcp.defpctused),
       tcp.definitrans, tcp.defmaxtrans, 
       tcp.definiexts, tcp.defextsize, tcp.defminexts, tcp.defmaxexts, 
       tcp.defextpct, 
       decode(bitand(ts.flags, 32), 32, to_number(NULL), tcp.deflists),
       decode(bitand(ts.flags, 32), 32, to_number(NULL), tcp.defgroups),
       decode(tcp.deflogging, 0, 'NONE', 1, 'YES', 2, 'NO', 'UNKNOWN'),
       decode(mod(tcp.spare2,256), 0, 'NONE', 1, 'ENABLED',  2, 'DISABLED',
                                   'UNKNOWN'),
       tcp.rowcnt, tcp.blkcnt, tcp.empcnt, tcp.avgspc, tcp.chncnt, tcp.avgrln,
       tcp.samplesize, tcp.analyzetime, 
       decode(tcp.defbufpool, 0, 'DEFAULT', 1, 'KEEP', 2, 'RECYCLE', NULL),
       decode(bitand(tcp.flags, 16), 0, 'NO', 'YES'),
       decode(bitand(tcp.flags, 8), 0, 'NO', 'YES')
from   obj$ o, tabcompartv$ tcp, ts$ ts, user$ u, tab$ t
where  o.obj# = tcp.obj# and tcp.defts# = ts.ts# and u.user# = o.owner# and
       tcp.bo# = t.obj# 
       and bitand(t.trigflag, 1073741824) != 1073741824
       and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
/
create or replace public synonym DBA_TAB_PARTITIONS for DBA_TAB_PARTITIONS
/
grant select on DBA_TAB_PARTITIONS to select_catalog_role
/

remark
remark  FAMILY "IND_PARTITIONS"
remark   This family of views will describe, for each index partition, the
remark   partition level information, the storage parameters for the 
remark   partition, and various partition statistics determined by ANALYZE.
remark   pctused, freelists, freelist groups are null for bitmap segments
remark
create or replace view USER_IND_PARTITIONS
  (INDEX_NAME, COMPOSITE, PARTITION_NAME, SUBPARTITION_COUNT, 
   HIGH_VALUE, HIGH_VALUE_LENGTH, 
   PARTITION_POSITION, STATUS, TABLESPACE_NAME, PCT_FREE, INI_TRANS, MAX_TRANS,
   INITIAL_EXTENT, NEXT_EXTENT, MIN_EXTENT, MAX_EXTENT, PCT_INCREASE, 
   FREELISTS, FREELIST_GROUPS, LOGGING, COMPRESSION, BLEVEL, LEAF_BLOCKS, 
   DISTINCT_KEYS, AVG_LEAF_BLOCKS_PER_KEY, AVG_DATA_BLOCKS_PER_KEY, 
   CLUSTERING_FACTOR, NUM_ROWS, SAMPLE_SIZE, LAST_ANALYZED, BUFFER_POOL, 
   USER_STATS, PCT_DIRECT_ACCESS, GLOBAL_STATS, DOMIDX_OPSTATUS, PARAMETERS)
as 
select io.name, 'NO', io.subname, 0,
       ip.hiboundval, ip.hiboundlen, 
       ip.part#, decode(bitand(ip.flags, 1), 1, 'UNUSABLE', 'USABLE'), ts.name,
       ip.pctfree$, ip.initrans, ip.maxtrans, s.iniexts * ts.blocksize, 
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
                               s.extsize * ts.blocksize),
       s.minexts, s.maxexts,
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
                                      s.extpct),
       decode(bitand(ts.flags, 32), 32, to_number(NULL), 
         decode(s.lists, 0, 1, s.lists)),
       decode(bitand(ts.flags, 32), 32, to_number(NULL), 
         decode(s.groups, 0, 1, s.groups)),
       decode(mod(trunc(ip.flags / 4), 2), 0, 'YES', 'NO'), 
       decode(bitand(ip.flags, 1024), 0, 'DISABLED', 1024, 'ENABLED', null),
       ip.blevel, ip.leafcnt, ip.distkey, ip.lblkkey, ip.dblkkey, 
       ip.clufac, ip.rowcnt, ip.samplesize, ip.analyzetime,
       decode(s.cachehint, 0, 'DEFAULT', 1, 'KEEP', 2, 'RECYCLE', NULL),
       decode(bitand(ip.flags, 8), 0, 'NO', 'YES'), ip.pctthres$,
       decode(bitand(ip.flags, 16), 0, 'NO', 'YES'), '',''
from   obj$ io, indpartv$ ip, ts$ ts, sys.seg$ s, ind$ i, tab$ t
where  io.obj# = ip.obj# and ts.ts# = ip.ts# and ip.file#=s.file# and
       ip.block#=s.block# and ip.ts#=s.ts# and 
       io.owner# = userenv('SCHEMAID') and ip.bo# = i.obj# and 
       i.bo# = t.obj# and bitand(t.trigflag, 1073741824) != 1073741824
       and io.namespace = 4 and io.remoteowner IS NULL and io.linkname IS NULL
union all
select io.name, 'YES', io.subname,icp.subpartcnt, 
       icp.hiboundval, icp.hiboundlen, 
       icp.part#, 'N/A', ts.name,  
       icp.defpctfree, icp.definitrans, icp.defmaxtrans,
       icp.definiexts, icp.defextsize, icp.defminexts, icp.defmaxexts, 
       icp.defextpct, icp.deflists, icp.defgroups,
       decode(icp.deflogging, 0, 'NONE', 1, 'YES', 2, 'NO', 'UNKNOWN'),
       decode(bitand(icp.flags, 1024), 0, 'DISABLED', 1024, 'ENABLED', null),
       icp.blevel, icp.leafcnt, icp.distkey, icp.lblkkey, icp.dblkkey, 
       icp.clufac, icp.rowcnt, icp.samplesize, icp.analyzetime,
       decode(icp.defbufpool, 0, 'DEFAULT', 1, 'KEEP', 2, 'RECYCLE', NULL),
       decode(bitand(icp.flags, 8), 0, 'NO', 'YES'), TO_NUMBER(NULL),
       decode(bitand(icp.flags, 16), 0, 'NO', 'YES'), '',''
from   obj$ io, indcompartv$ icp, ts$ ts, ind$ i, tab$ t
where  io.obj# = icp.obj# and icp.defts# = ts.ts# (+) and
       io.owner# = userenv('SCHEMAID') and
       icp.bo# = i.obj# and i.bo# = t.obj# and
       bitand(t.trigflag, 1073741824) != 1073741824
       and io.namespace = 4 and io.remoteowner IS NULL and io.linkname IS NULL
union all
select io.name, 'NO', io.subname, 0,
       ip.hiboundval, ip.hiboundlen, 
       ip.part#, decode(bitand(ip.flags, 1), 1, 'UNUSABLE', 
               decode(bitand(ip.flags, 4096), 4096, 'INPROGRS', 'USABLE')), 
       null,
       ip.pctfree$, ip.initrans, ip.maxtrans,  
       0, 0, 0, 0, 0, 0, 0,
       decode(mod(trunc(ip.flags / 4), 2), 0, 'YES', 'NO'), 
       decode(bitand(ip.flags, 1024), 0, 'DISABLED', 1024, 'ENABLED', null),
       ip.blevel, ip.leafcnt, ip.distkey, ip.lblkkey, ip.dblkkey, 
       ip.clufac, ip.rowcnt, ip.samplesize, ip.analyzetime,
       'DEFAULT',
       decode(bitand(ip.flags, 8), 0, 'NO', 'YES'), ip.pctthres$,
       decode(bitand(ip.flags, 16), 0, 'NO', 'YES'),
       decode(i.type#, 
             9, decode(bitand(ip.flags, 8192), 8192, 'FAILED', 'VALID'),
             ''), 
       ipp.parameters
from   obj$ io, indpartv$ ip, indpart_param$ ipp, ind$ i, tab$ t
where  io.obj# = ip.obj# and ip.obj# = ipp.obj# and
       ip.bo# = i.obj# and io.owner# = userenv('SCHEMAID') and
       io.namespace = 4 and io.remoteowner IS NULL and io.linkname IS NULL and
       i.bo# = t.obj# and bitand(t.trigflag, 1073741824) != 1073741824
/
create or replace public synonym USER_IND_PARTITIONS for USER_IND_PARTITIONS
/
grant select on USER_IND_PARTITIONS to PUBLIC with grant option
/
create or replace view ALL_IND_PARTITIONS
  (INDEX_OWNER, INDEX_NAME, COMPOSITE, PARTITION_NAME, SUBPARTITION_COUNT, 
   HIGH_VALUE, HIGH_VALUE_LENGTH, 
   PARTITION_POSITION, STATUS, TABLESPACE_NAME, PCT_FREE, INI_TRANS, MAX_TRANS,
   INITIAL_EXTENT, NEXT_EXTENT, MIN_EXTENT, MAX_EXTENT, PCT_INCREASE, 
   FREELISTS, FREELIST_GROUPS, LOGGING, COMPRESSION, BLEVEL, LEAF_BLOCKS, 
   DISTINCT_KEYS, AVG_LEAF_BLOCKS_PER_KEY, AVG_DATA_BLOCKS_PER_KEY, 
   CLUSTERING_FACTOR, NUM_ROWS, SAMPLE_SIZE, LAST_ANALYZED, BUFFER_POOL, 
   USER_STATS, PCT_DIRECT_ACCESS, GLOBAL_STATS, DOMIDX_OPSTATUS, PARAMETERS)
as 
select u.name, io.name, 'NO', io.subname, 0,
       ip.hiboundval, ip.hiboundlen, ip.part#, 
       decode(bitand(ip.flags, 1), 1, 'UNUSABLE', 'USABLE'),ts.name,
       ip.pctfree$, ip.initrans, ip.maxtrans, s.iniexts * ts.blocksize, 
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
                               s.extsize * ts.blocksize),
       s.minexts, s.maxexts,
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
                                      s.extpct),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
          decode(s.lists, 0, 1, s.lists)),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
          decode(s.groups, 0, 1, s.groups)),
       decode(mod(trunc(ip.flags / 4), 2), 0, 'YES', 'NO'), 
       decode(bitand(ip.flags, 1024), 0, 'DISABLED', 1024, 'ENABLED', null),
       ip.blevel, ip.leafcnt, ip.distkey, ip.lblkkey, ip.dblkkey, 
       ip.clufac, ip.rowcnt, ip.samplesize, ip.analyzetime,
       decode(s.cachehint, 0, 'DEFAULT', 1, 'KEEP', 2, 'RECYCLE', NULL),
       decode(bitand(ip.flags, 8), 0, 'NO', 'YES'), ip.pctthres$,
       decode(bitand(ip.flags, 16), 0, 'NO', 'YES'), '',''
from obj$ io, indpartv$ ip, ts$ ts, sys.seg$ s, ind$ i, sys.user$ u, tab$ t
where io.obj# = ip.obj# and ts.ts# = ip.ts# and ip.file#=s.file# and
      ip.block#=s.block# and ip.ts#=s.ts# and io.owner# = u.user# and 
      i.obj# = ip.bo# and i.bo# = t.obj# and
      bitand(t.trigflag, 1073741824) != 1073741824 and
      i.type# != 8 and      /* not LOB index */
      io.namespace = 4 and io.remoteowner IS NULL and io.linkname IS NULL and
        (io.owner# = userenv('SCHEMAID') 
        or
        i.bo# in (select obj#
                    from objauth$
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
union all
select u.name, io.name, 'YES', io.subname, icp.subpartcnt,
       icp.hiboundval, icp.hiboundlen, icp.part#, 'N/A', ts.name,
       icp.defpctfree, icp.definitrans, icp.defmaxtrans,
       icp.definiexts, icp.defextsize, icp.defminexts, icp.defmaxexts, 
       icp.defextpct, icp.deflists, icp.defgroups,
       decode(icp.deflogging, 0, 'NONE', 1, 'YES', 2, 'NO', 'UNKNOWN'),
       decode(bitand(icp.flags, 1024), 0, 'DISABLED', 1024, 'ENABLED', null),
       icp.blevel, icp.leafcnt, icp.distkey, icp.lblkkey, icp.dblkkey, 
       icp.clufac, icp.rowcnt, icp.samplesize, icp.analyzetime,
       decode(icp.defbufpool, 0, 'DEFAULT', 1, 'KEEP', 2, 'RECYCLE', NULL),
       decode(bitand(icp.flags, 8), 0, 'NO', 'YES'), TO_NUMBER(NULL),
       decode(bitand(icp.flags, 16), 0, 'NO', 'YES'), '',''
from   obj$ io, indcompartv$ icp, ts$ ts, ind$ i, user$ u, tab$ t
where  io.obj# = icp.obj# and icp.defts# = ts.ts# (+) and io.owner# = u.user# and
       i.obj# = icp.bo# and i.bo# = t.obj# and
       bitand(t.trigflag, 1073741824) != 1073741824 and
       i.type# != 8 and      /* not LOB index */
       io.namespace = 4 and io.remoteowner IS NULL and io.linkname IS NULL and
       (io.owner# = userenv('SCHEMAID') 
        or 
        i.bo# in (select oa.obj#
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
select u.name, io.name, 'NO', io.subname, 0,
       ip.hiboundval, ip.hiboundlen, ip.part#, 
       decode(bitand(ip.flags, 1), 1, 'UNUSABLE', 
               decode(bitand(ip.flags, 4096), 4096, 'INPROGRS', 'USABLE')),
       null, ip.pctfree$, ip.initrans, ip.maxtrans, 
       0, 0, 0, 0, 0, 0, 0,
       decode(mod(trunc(ip.flags / 4), 2), 0, 'YES', 'NO'), 
       decode(bitand(ip.flags, 1024), 0, 'DISABLED', 1024, 'ENABLED', null),
       ip.blevel, ip.leafcnt, ip.distkey, ip.lblkkey, ip.dblkkey, 
       ip.clufac, ip.rowcnt, ip.samplesize, ip.analyzetime,
       'DEFAULT', 
       decode(bitand(ip.flags, 8), 0, 'NO', 'YES'), ip.pctthres$,
       decode(bitand(ip.flags, 16), 0, 'NO', 'YES'), 
       decode(i.type#, 
             9, decode(bitand(ip.flags, 8192), 8192, 'FAILED', 'VALID'),
             ''), 
       ipp.parameters
from obj$ io, indpartv$ ip, ind$ i, sys.user$ u, indpart_param$ ipp, tab$ t
where io.obj# = ip.obj# and io.owner# = u.user# and 
      i.obj# = ip.bo# and ip.obj# = ipp.obj# and 
      i.bo# = t.obj# and bitand(t.trigflag, 1073741824) != 1073741824 and
      io.namespace = 4 and io.remoteowner IS NULL and io.linkname IS NULL and
        (io.owner# = userenv('SCHEMAID') 
        or
        i.bo# in (select obj#
                    from objauth$
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
create or replace public synonym ALL_IND_PARTITIONS for ALL_IND_PARTITIONS
/
grant select on ALL_IND_PARTITIONS to PUBLIC with grant option
/
create or replace view DBA_IND_PARTITIONS
  (INDEX_OWNER, INDEX_NAME, COMPOSITE, PARTITION_NAME, SUBPARTITION_COUNT, 
   HIGH_VALUE, HIGH_VALUE_LENGTH, 
   PARTITION_POSITION, STATUS, TABLESPACE_NAME, PCT_FREE, INI_TRANS, MAX_TRANS,
   INITIAL_EXTENT, NEXT_EXTENT, MIN_EXTENT, MAX_EXTENT, PCT_INCREASE, 
   FREELISTS, FREELIST_GROUPS, LOGGING, COMPRESSION, BLEVEL, LEAF_BLOCKS, 
   DISTINCT_KEYS, AVG_LEAF_BLOCKS_PER_KEY, AVG_DATA_BLOCKS_PER_KEY, 
   CLUSTERING_FACTOR, NUM_ROWS, SAMPLE_SIZE, LAST_ANALYZED, BUFFER_POOL, 
   USER_STATS, PCT_DIRECT_ACCESS, GLOBAL_STATS, DOMIDX_OPSTATUS, PARAMETERS)
as 
select u.name, io.name, 'NO', io.subname, 0, 
       ip.hiboundval, ip.hiboundlen, ip.part#,
       decode(bitand(ip.flags, 1), 1, 'UNUSABLE', 'USABLE'), ts.name,
       ip.pctfree$,ip.initrans, ip.maxtrans, s.iniexts * ts.blocksize, 
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
                               s.extsize * ts.blocksize),
       s.minexts, s.maxexts,
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
                                      s.extpct),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
         decode(s.lists, 0, 1, s.lists)),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
         decode(s.groups, 0, 1, s.groups)),
       decode(mod(trunc(ip.flags / 4), 2), 0, 'YES', 'NO'), 
       decode(bitand(ip.flags, 1024), 0, 'DISABLED', 1024, 'ENABLED', null),
       ip.blevel, ip.leafcnt, ip.distkey, ip.lblkkey, ip.dblkkey, 
       ip.clufac, ip.rowcnt, ip.samplesize, ip.analyzetime,
       decode(s.cachehint, 0, 'DEFAULT', 1, 'KEEP', 2, 'RECYCLE', NULL),
       decode(bitand(ip.flags, 8), 0, 'NO', 'YES'), ip.pctthres$,
       decode(bitand(ip.flags, 16), 0, 'NO', 'YES'),'',''
from   obj$ io, indpartv$ ip, ts$ ts, sys.seg$ s, user$ u, ind$ i, tab$ t
where  io.obj# = ip.obj# and ts.ts# = ip.ts# and ip.file#=s.file# and
       ip.block#=s.block# and ip.ts#=s.ts# and io.owner# = u.user# and
       i.obj# = ip.bo# and i.bo# = t.obj# and
       bitand(t.trigflag, 1073741824) != 1073741824
       and io.namespace = 4 and io.remoteowner IS NULL and io.linkname IS NULL
      union all
select u.name, io.name, 'YES', io.subname, icp.subpartcnt,
       icp.hiboundval, icp.hiboundlen, icp.part#, 'N/A', ts.name,
       icp.defpctfree, icp.definitrans, icp.defmaxtrans,
       icp.definiexts, icp.defextsize, icp.defminexts, icp.defmaxexts, 
       icp.defextpct, icp.deflists, icp.defgroups,
       decode(icp.deflogging, 0, 'NONE', 1, 'YES', 2, 'NO', 'UNKNOWN'),
       decode(bitand(icp.flags, 1024), 0, 'DISABLED', 1024, 'ENABLED', null),
       icp.blevel, icp.leafcnt, icp.distkey, icp.lblkkey, icp.dblkkey, 
       icp.clufac, icp.rowcnt, icp.samplesize, icp.analyzetime,
       decode(icp.defbufpool, 0, 'DEFAULT', 1, 'KEEP', 2, 'RECYCLE', NULL),
       decode(bitand(icp.flags, 8), 0, 'NO', 'YES'), TO_NUMBER(NULL),
       decode(bitand(icp.flags, 16), 0, 'NO', 'YES'),'',''
from   obj$ io, indcompartv$ icp, ts$ ts, user$ u, ind$ i, tab$ t
where  io.obj# = icp.obj# and icp.defts# = ts.ts# (+) and 
       u.user# = io.owner# and i.obj# = icp.bo# and i.bo# = t.obj# and 
       bitand(t.trigflag, 1073741824) != 1073741824
       and io.namespace = 4 and io.remoteowner IS NULL and io.linkname IS NULL
      union all
select u.name, io.name, 'NO', io.subname, 0, 
       ip.hiboundval, ip.hiboundlen, ip.part#, 
       decode(bitand(ip.flags, 1), 1, 'UNUSABLE', 
                decode(bitand(ip.flags, 4096), 4096, 'INPROGRS', 'USABLE')), 
       null, ip.pctfree$, ip.initrans, ip.maxtrans, 
       0, 0, 0, 0, 0, 0, 0,
       decode(mod(trunc(ip.flags / 4), 2), 0, 'YES', 'NO'), 
       decode(bitand(ip.flags, 1024), 0, 'DISABLED', 1024, 'ENABLED', null),
       ip.blevel, ip.leafcnt, ip.distkey, ip.lblkkey, ip.dblkkey, 
       ip.clufac, ip.rowcnt, ip.samplesize, ip.analyzetime,
       'DEFAULT', 
       decode(bitand(ip.flags, 8), 0, 'NO', 'YES'), ip.pctthres$,
       decode(bitand(ip.flags, 16), 0, 'NO', 'YES'),
       decode(i.type#, 
             9, decode(bitand(ip.flags, 8192), 8192, 'FAILED', 'VALID'),
             ''), 
       ipp.parameters
from   obj$ io, indpartv$ ip,  user$ u, ind$ i, indpart_param$ ipp, tab$ t
where  io.obj# = ip.obj# and io.owner# = u.user# and
       ip.bo# = i.obj# and ip.obj# = ipp.obj# and i.bo# = t.obj# and 
       bitand(t.trigflag, 1073741824) != 1073741824
       and io.namespace = 4 and io.remoteowner IS NULL and io.linkname IS NULL
/
create or replace public synonym DBA_IND_PARTITIONS for DBA_IND_PARTITIONS
/
grant select on DBA_IND_PARTITIONS to select_catalog_role
/

remark
remark  FAMILY "TAB_SUBPARTITIONS"
remark   This family of views will describe, for each table subpartition,
remark   the subpartition level information, the storage parameters for the
remark   subpartition, and various subpartition statistics determined by
remark   ANALYZE.
remark   pctused, freelists, freelist groups are null for bitmap segments
remark
create or replace view USER_TAB_SUBPARTITIONS
  (TABLE_NAME, PARTITION_NAME, SUBPARTITION_NAME,
   HIGH_VALUE, HIGH_VALUE_LENGTH, SUBPARTITION_POSITION,               
   TABLESPACE_NAME, PCT_FREE, PCT_USED,
   INI_TRANS, MAX_TRANS, INITIAL_EXTENT, NEXT_EXTENT, MIN_EXTENT, MAX_EXTENT,
   PCT_INCREASE, FREELISTS, FREELIST_GROUPS, LOGGING, COMPRESSION,
   NUM_ROWS, BLOCKS, EMPTY_BLOCKS, AVG_SPACE, CHAIN_CNT, AVG_ROW_LEN, 
   SAMPLE_SIZE, LAST_ANALYZED, BUFFER_POOL, GLOBAL_STATS, USER_STATS)
as
select po.name, po.subname, so.subname,  
       tsp.hiboundval, tsp.hiboundlen, tsp.subpart#,
       ts.name,  tsp.pctfree$, 
       decode(bitand(ts.flags, 32), 32, to_number(NULL), tsp.pctused$), 
       tsp.initrans, tsp.maxtrans,
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
       decode(mod(trunc(tsp.flags / 4), 2), 0, 'YES', 'NO'),
       decode(bitand(s.spare1, 2048), 2048, 'ENABLED', 'DISABLED'),
       tsp.rowcnt, tsp.blkcnt, tsp.empcnt, tsp.avgspc, tsp.chncnt, 
       tsp.avgrln, tsp.samplesize, tsp.analyzetime,
       decode(s.cachehint, 0, 'DEFAULT', 1, 'KEEP', 2, 'RECYCLE', NULL),
       decode(bitand(tsp.flags, 16), 0, 'NO', 'YES'),
       decode(bitand(tsp.flags, 8), 0, 'NO', 'YES')
from   sys.obj$ so, sys.obj$ po, sys.tabcompartv$ tcp, sys.tabsubpartv$ tsp,
       sys.tab$ t, sys.ts$ ts, sys.seg$ s
where  so.obj# = tsp.obj# and po.obj# = tsp.pobj# and tcp.obj# = tsp.pobj# and
       tcp.bo# = t.obj# and bitand(t.trigflag, 1073741824) != 1073741824 and
       tsp.ts# = ts.ts# and
       tsp.file# = s.file# and tsp.block# = s.block# and tsp.ts# = s.ts# and
       po.owner# = userenv('SCHEMAID') and so.owner# = userenv('SCHEMAID')
       and po.namespace = 1 and po.remoteowner IS NULL and po.linkname IS NULL
       and so.namespace = 1 and so.remoteowner IS NULL and so.linkname IS NULL  
/
create or replace public synonym USER_TAB_SUBPARTITIONS
   for USER_TAB_SUBPARTITIONS
/
grant select on USER_TAB_SUBPARTITIONS to PUBLIC with grant option
/
create or replace view ALL_TAB_SUBPARTITIONS
  (TABLE_OWNER, TABLE_NAME, PARTITION_NAME, SUBPARTITION_NAME,
   HIGH_VALUE, HIGH_VALUE_LENGTH, SUBPARTITION_POSITION,
   TABLESPACE_NAME, PCT_FREE, PCT_USED,
   INI_TRANS, MAX_TRANS, INITIAL_EXTENT, NEXT_EXTENT, MIN_EXTENT, MAX_EXTENT,
   PCT_INCREASE, FREELISTS, FREELIST_GROUPS, LOGGING, COMPRESSION,
   NUM_ROWS, BLOCKS, EMPTY_BLOCKS, AVG_SPACE, CHAIN_CNT, AVG_ROW_LEN, 
   SAMPLE_SIZE, LAST_ANALYZED, BUFFER_POOL, GLOBAL_STATS, USER_STATS)
as 
select u.name, po.name, po.subname, so.subname, 
       tsp.hiboundval, tsp.hiboundlen, tsp.subpart#, 
       ts.name, tsp.pctfree$, 
       decode(bitand(ts.flags, 32), 32, to_number(NULL), tsp.pctused$), 
       tsp.initrans, tsp.maxtrans, s.iniexts * ts.blocksize, 
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
                               s.extsize * ts.blocksize),
       s.minexts, s.maxexts,
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
                                      s.extpct),
       decode(bitand(ts.flags, 32), 32, to_number(NULL), 
           decode(s.lists, 0, 1, s.lists)), 
       decode(bitand(ts.flags, 32), 32, to_number(NULL), 
           decode(s.groups, 0, 1, s.groups)),
       decode(mod(trunc(tsp.flags / 4), 2), 0, 'YES', 'NO'),
       decode(bitand(s.spare1, 2048), 2048, 'ENABLED', 'DISABLED'),
       tsp.rowcnt, tsp.blkcnt, tsp.empcnt, tsp.avgspc, tsp.chncnt, 
       tsp.avgrln, tsp.samplesize, tsp.analyzetime,
       decode(s.cachehint, 0, 'DEFAULT', 1, 'KEEP', 2, 'RECYCLE', NULL),
       decode(bitand(tsp.flags, 16), 0, 'NO', 'YES'),
       decode(bitand(tsp.flags, 8), 0, 'NO', 'YES')
from   obj$ po, obj$ so, tabcompartv$ tcp, tabsubpartv$ tsp, tab$ t,
       ts$ ts, sys.seg$ s, user$ u
where  so.obj# = tsp.obj# and po.obj# = tcp.obj# and tcp.obj# = tsp.pobj# and
       tcp.bo# = t.obj# and bitand(t.trigflag, 1073741824) != 1073741824 and
       ts.ts# = tsp.ts# and u.user# = po.owner# and tsp.file# = s.file# and
       tsp.block# = s.block# and tsp.ts# = s.ts# and
       po.namespace = 1 and po.remoteowner IS NULL and po.linkname IS NULL and
       so.namespace = 1 and so.remoteowner IS NULL and so.linkname IS NULL and
       ((po.owner# = userenv('SCHEMAID') and so.owner# = userenv('SCHEMAID'))
        or tcp.bo# in
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
create or replace public synonym ALL_TAB_SUBPARTITIONS
   for ALL_TAB_SUBPARTITIONS
/
grant select on ALL_TAB_SUBPARTITIONS to PUBLIC with grant option
/
create or replace view DBA_TAB_SUBPARTITIONS
  (TABLE_OWNER, TABLE_NAME, PARTITION_NAME, SUBPARTITION_NAME,
   HIGH_VALUE, HIGH_VALUE_LENGTH, SUBPARTITION_POSITION,
   TABLESPACE_NAME, PCT_FREE, PCT_USED,
   INI_TRANS, MAX_TRANS, INITIAL_EXTENT, NEXT_EXTENT, MIN_EXTENT, MAX_EXTENT,
   PCT_INCREASE, FREELISTS, FREELIST_GROUPS, LOGGING, COMPRESSION,
   NUM_ROWS, BLOCKS, EMPTY_BLOCKS, AVG_SPACE, CHAIN_CNT, AVG_ROW_LEN, 
   SAMPLE_SIZE, LAST_ANALYZED, BUFFER_POOL, GLOBAL_STATS, USER_STATS)
as
select u.name, po.name, po.subname, so.subname, 
       tsp.hiboundval, tsp.hiboundlen, tsp.subpart#, 
       ts.name,  tsp.pctfree$, 
       decode(bitand(ts.flags, 32), 32, to_number(NULL), tsp.pctused$), 
       tsp.initrans, tsp.maxtrans,
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
       decode(mod(trunc(tsp.flags / 4), 2), 0, 'YES', 'NO'),
       decode(bitand(s.spare1, 2048), 2048, 'ENABLED', 'DISABLED'),
       tsp.rowcnt, tsp.blkcnt, tsp.empcnt, tsp.avgspc, tsp.chncnt, 
       tsp.avgrln, tsp.samplesize, tsp.analyzetime,
       decode(s.cachehint, 0, 'DEFAULT', 1, 'KEEP', 2, 'RECYCLE', NULL),
       decode(bitand(tsp.flags, 16), 0, 'NO', 'YES'),
       decode(bitand(tsp.flags, 8), 0, 'NO', 'YES')
from   sys.obj$ so, sys.obj$ po, tabcompartv$ tcp, sys.tabsubpartv$ tsp, 
       sys.tab$ t, sys.ts$ ts, sys.seg$ s, sys.user$ u
where  so.obj# = tsp.obj# and po.obj# = tsp.pobj# and tcp.obj# = tsp.pobj# and
       tcp.bo# = t.obj# and bitand(t.trigflag, 1073741824) != 1073741824 and
       tsp.ts# = ts.ts# and u.user# = po.owner# and 
       tsp.file# = s.file# and tsp.block# = s.block# and
       tsp.ts# = s.ts#
       and po.namespace = 1 and po.remoteowner IS NULL and po.linkname IS NULL
       and so.namespace = 1 and so.remoteowner IS NULL and so.linkname IS NULL
/
create or replace public synonym DBA_TAB_SUBPARTITIONS
   for DBA_TAB_SUBPARTITIONS
/
grant select on DBA_TAB_SUBPARTITIONS to select_catalog_role
/
remark
remark  FAMILY "IND_SUBPARTITIONS"
remark   This family of views will describe, for each index subpartition,
remark   the subpartition level information, the storage parameters for the
remark   subpartition, and various subpartition statistics determined by
remark   ANALYZE.
remark   pctused, freelists, freelist groups are null for bitmap segments
remark
create or replace view USER_IND_SUBPARTITIONS
  (INDEX_NAME, PARTITION_NAME, SUBPARTITION_NAME, 
   HIGH_VALUE, HIGH_VALUE_LENGTH, SUBPARTITION_POSITION,
   STATUS, TABLESPACE_NAME, PCT_FREE, 
   INI_TRANS, MAX_TRANS, INITIAL_EXTENT, NEXT_EXTENT, MIN_EXTENT, MAX_EXTENT,
   PCT_INCREASE, FREELISTS, FREELIST_GROUPS, LOGGING, COMPRESSION, BLEVEL, 
   LEAF_BLOCKS, 
   DISTINCT_KEYS, AVG_LEAF_BLOCKS_PER_KEY, AVG_DATA_BLOCKS_PER_KEY, 
   CLUSTERING_FACTOR, NUM_ROWS, SAMPLE_SIZE, LAST_ANALYZED, BUFFER_POOL,
   USER_STATS, GLOBAL_STATS)
as
select po.name, po.subname, so.subname, isp.hiboundval, isp.hiboundlen,
       isp.subpart#,
       decode(bitand(isp.flags, 1), 1, 'UNUSABLE', 'USABLE'), ts.name,  
       isp.pctfree$, isp.initrans, isp.maxtrans,
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
       decode(mod(trunc(isp.flags / 4), 2), 0, 'YES', 'NO'),
       decode(bitand(isp.flags, 1024), 0, 'DISABLED', 1024, 'ENABLED', null),
       isp.blevel, isp.leafcnt, isp.distkey, isp.lblkkey, isp.dblkkey, 
       isp.clufac, isp.rowcnt, isp.samplesize, isp.analyzetime,
       decode(s.cachehint, 0, 'DEFAULT', 1, 'KEEP', 2, 'RECYCLE', NULL),
       decode(bitand(isp.flags, 8), 0, 'NO', 'YES'),
       decode(bitand(isp.flags, 16), 0, 'NO', 'YES')
from   sys.obj$ so, sys.obj$ po, sys.indsubpartv$ isp, sys.indcompartv$ icp,
       sys.ts$ ts, sys.seg$ s, sys.ind$ i, sys.tab$ t
where  so.obj# = isp.obj# and 
       po.obj# = icp.obj# and icp.obj# = isp.pobj# and 
       isp.ts# = ts.ts# and
       isp.file# = s.file# and isp.block# = s.block# and isp.ts# = s.ts# and
       po.owner# = userenv('SCHEMAID') and so.owner# = userenv('SCHEMAID') and
       i.obj# = icp.bo# and i.bo# = t.obj# and
       bitand(t.trigflag, 1073741824) != 1073741824
       and po.namespace = 4 and po.remoteowner IS NULL and po.linkname IS NULL
       and so.namespace = 4 and so.remoteowner IS NULL and so.linkname IS NULL

/
create or replace public synonym USER_IND_SUBPARTITIONS
   for USER_IND_SUBPARTITIONS
/
grant select on USER_IND_SUBPARTITIONS to PUBLIC with grant option
/

create or replace view ALL_IND_SUBPARTITIONS
  (INDEX_OWNER, INDEX_NAME, PARTITION_NAME, SUBPARTITION_NAME, 
   HIGH_VALUE, HIGH_VALUE_LENGTH, SUBPARTITION_POSITION,
   STATUS, TABLESPACE_NAME, PCT_FREE, 
   INI_TRANS, MAX_TRANS, INITIAL_EXTENT, NEXT_EXTENT, MIN_EXTENT, MAX_EXTENT,
   PCT_INCREASE, FREELISTS, FREELIST_GROUPS, LOGGING, COMPRESSION, BLEVEL, 
   LEAF_BLOCKS, 
   DISTINCT_KEYS, AVG_LEAF_BLOCKS_PER_KEY, AVG_DATA_BLOCKS_PER_KEY, 
   CLUSTERING_FACTOR, NUM_ROWS, SAMPLE_SIZE, LAST_ANALYZED, BUFFER_POOL,
   USER_STATS, GLOBAL_STATS)
as
select u.name, po.name, po.subname, so.subname, 
       isp.hiboundval, isp.hiboundlen, isp.subpart#,
       decode(bitand(isp.flags, 1), 1, 'UNUSABLE', 'USABLE'), ts.name,  
       isp.pctfree$, isp.initrans, isp.maxtrans,
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
       decode(mod(trunc(isp.flags / 4), 2), 0, 'YES', 'NO'),
       decode(bitand(isp.flags, 1024), 0, 'DISABLED', 1024, 'ENABLED', null),
       isp.blevel, isp.leafcnt, isp.distkey, isp.lblkkey, isp.dblkkey, 
       isp.clufac, isp.rowcnt, isp.samplesize, isp.analyzetime,
       decode(s.cachehint, 0, 'DEFAULT', 1, 'KEEP', 2, 'RECYCLE', NULL),
       decode(bitand(isp.flags, 8), 0, 'NO', 'YES'),
       decode(bitand(isp.flags, 16), 0, 'NO', 'YES')
from   obj$ so, sys.obj$ po, ind$ i, indcompartv$ icp, indsubpartv$ isp, 
       ts$ ts, seg$ s, user$ u, tab$ t
where  so.obj# = isp.obj# and po.obj# = icp.obj# and icp.obj# = isp.pobj# and
       i.obj# = icp.bo# and ts.ts# = isp.ts# and isp.file# = s.file# and
       isp.block# = s.block# and isp.ts# = s.ts# and u.user# = po.owner# and
       i.bo# = t.obj# and bitand(t.trigflag, 1073741824) != 1073741824 and
       i.type# != 8 and      /* not LOB index */
       po.namespace = 4 and po.remoteowner IS NULL and po.linkname IS NULL and
       so.namespace = 4 and so.remoteowner IS NULL and so.linkname IS NULL and
       ((po.owner# = userenv('SCHEMAID') and so.owner# = userenv('SCHEMAID'))
        or i.bo# in
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
create or replace public synonym ALL_IND_SUBPARTITIONS
   for ALL_IND_SUBPARTITIONS
/
grant select on ALL_IND_SUBPARTITIONS to PUBLIC with grant option
/

create or replace view DBA_IND_SUBPARTITIONS
  (INDEX_OWNER, INDEX_NAME, PARTITION_NAME, SUBPARTITION_NAME, 
   HIGH_VALUE, HIGH_VALUE_LENGTH, SUBPARTITION_POSITION,
   STATUS, TABLESPACE_NAME, PCT_FREE, 
   INI_TRANS, MAX_TRANS, INITIAL_EXTENT, NEXT_EXTENT, MIN_EXTENT, MAX_EXTENT,
   PCT_INCREASE, FREELISTS, FREELIST_GROUPS, LOGGING, COMPRESSION, BLEVEL, 
   LEAF_BLOCKS, 
   DISTINCT_KEYS, AVG_LEAF_BLOCKS_PER_KEY, AVG_DATA_BLOCKS_PER_KEY, 
   CLUSTERING_FACTOR, NUM_ROWS, SAMPLE_SIZE, LAST_ANALYZED, BUFFER_POOL,
   USER_STATS, GLOBAL_STATS)
as
select u.name, po.name, po.subname, so.subname, 
       isp.hiboundval, isp.hiboundlen, isp.subpart#, 
       decode(bitand(isp.flags, 1), 1, 'UNUSABLE', 'USABLE'), ts.name,  
       isp.pctfree$, isp.initrans, isp.maxtrans,
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
       decode(mod(trunc(isp.flags / 4), 2), 0, 'YES', 'NO'),
       decode(bitand(isp.flags, 1024), 0, 'DISABLED', 1024, 'ENABLED', null),
       isp.blevel, isp.leafcnt, isp.distkey, isp.lblkkey, isp.dblkkey, 
       isp.clufac, isp.rowcnt, isp.samplesize, isp.analyzetime,
       decode(s.cachehint, 0, 'DEFAULT', 1, 'KEEP', 2, 'RECYCLE', NULL),
       decode(bitand(isp.flags, 8), 0, 'NO', 'YES'),
       decode(bitand(isp.flags, 16), 0, 'NO', 'YES')
from   sys.obj$ so, sys.obj$ po, sys.indcompartv$ icp, sys.indsubpartv$ isp, 
       sys.ts$ ts, sys.seg$ s, sys.user$ u, sys.ind$ i, sys.tab$ t
where  so.obj# = isp.obj# and po.obj# = icp.obj# and
       icp.obj# = isp.pobj# and isp.ts# = ts.ts# and u.user# = po.owner# and 
       isp.file# = s.file# and isp.block# = s.block# and isp.ts# = s.ts# and
       icp.bo# = i.obj# and i.bo# = t.obj# and 
       bitand(t.trigflag, 1073741824) != 1073741824
       and po.namespace = 4 and po.remoteowner IS NULL and po.linkname IS NULL
       and so.namespace = 4 and so.remoteowner IS NULL and so.linkname IS NULL
/
create or replace public synonym DBA_IND_SUBPARTITIONS
   for DBA_IND_SUBPARTITIONS
/
grant select on DBA_IND_SUBPARTITIONS to select_catalog_role
/

remark 
remark  FAMILY "PART_COL_STATISTICS"
remark   These views contain column statistics and histogram information
remark   for table partitions.
remark
create or replace view TP$ as
select tp.obj#, tp.bo#, c.intcol#, 
      decode(bitand(c.property, 1), 1, a.name, c.name) cname
      from sys.col$ c, sys.tabpart$ tp, attrcol$ a 
      where tp.bo# = c.obj# and
      c.obj# = a.obj#(+) and c.intcol# = a.intcol#(+) and 
      bitand(c.property,32768) != 32768    /* not unused columns */
union
select tcp.obj#, tcp.bo#, c.intcol#, 
      decode(bitand(c.property, 1), 1, a.name, c.name) cname
      from sys.col$ c, sys.tabcompart$ tcp, attrcol$ a 
      where tcp.bo# = c.obj# and
      c.obj# = a.obj#(+) and c.intcol# = a.intcol#(+) and 
      bitand(c.property,32768) != 32768    /* not unused columns */
/
grant select on TP$ to select_catalog_role
/
create or replace view USER_PART_COL_STATISTICS 
  (TABLE_NAME, PARTITION_NAME, COLUMN_NAME, NUM_DISTINCT, LOW_VALUE,
   HIGH_VALUE, DENSITY, NUM_NULLS, NUM_BUCKETS, SAMPLE_SIZE, LAST_ANALYZED,
   GLOBAL_STATS, USER_STATS, AVG_COL_LEN, HISTOGRAM)
as
select o.name, o.subname, tp.cname, h.distcnt, h.lowval, h.hival,
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
       h.sample_size, h.timestamp#,
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
from  obj$ o, sys.hist_head$ h, tp$ tp
where o.obj# = tp.obj#
  and tp.obj# = h.obj#(+) and tp.intcol# = h.intcol#(+)
  and o.type# = 19 /* TABLE PARTITION */
  and o.owner# = userenv('SCHEMAID')
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
/
create or replace public synonym USER_PART_COL_STATISTICS
   for USER_PART_COL_STATISTICS 
/
grant select on USER_PART_COL_STATISTICS to PUBLIC with grant option
/
create or replace view ALL_PART_COL_STATISTICS 
  (OWNER, TABLE_NAME, PARTITION_NAME, COLUMN_NAME, NUM_DISTINCT, LOW_VALUE,
   HIGH_VALUE, DENSITY, NUM_NULLS, NUM_BUCKETS, SAMPLE_SIZE, LAST_ANALYZED,
   GLOBAL_STATS, USER_STATS, AVG_COL_LEN, HISTOGRAM)
as
select u.name, o.name, o.subname, tp.cname, h.distcnt, h.lowval, h.hival, 
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
       h.sample_size, h.timestamp#,
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
from sys.obj$ o, sys.hist_head$ h, tp$ tp, user$ u
where o.obj# = tp.obj# and o.owner# = u.user#
  and tp.obj# = h.obj#(+) and tp.intcol# = h.intcol#(+)
  and o.type# = 19 /* TABLE PARTITION */
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  and (o.owner# = userenv('SCHEMAID')
        or tp.bo# in
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
create or replace public synonym ALL_PART_COL_STATISTICS
   for ALL_PART_COL_STATISTICS 
/
grant select on ALL_PART_COL_STATISTICS to PUBLIC with grant option
/
create or replace view DBA_PART_COL_STATISTICS 
  (OWNER, TABLE_NAME, PARTITION_NAME, COLUMN_NAME, NUM_DISTINCT, LOW_VALUE,
   HIGH_VALUE, DENSITY, NUM_NULLS, NUM_BUCKETS, SAMPLE_SIZE, LAST_ANALYZED,
   GLOBAL_STATS, USER_STATS, AVG_COL_LEN, HISTOGRAM)
as
select u.name, o.name, o.subname, tp.cname, h.distcnt, h.lowval, h.hival, 
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
       h.sample_size, h.timestamp#,
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
from sys.obj$ o, sys.hist_head$ h, tp$ tp, user$ u
where o.obj# = tp.obj# and o.owner# = u.user#
  and tp.obj# = h.obj#(+) and tp.intcol# = h.intcol#(+)
  and o.type# = 19 /* TABLE PARTITION */
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
/
create or replace public synonym DBA_PART_COL_STATISTICS
   for DBA_PART_COL_STATISTICS
/
grant select on DBA_PART_COL_STATISTICS to select_catalog_role
/

remark
remark  FAMILY "PART_HISTOGRAMS"
remark   These views contain the actual histogram data (end-points per
remark   histogram) for histograms on table partitions.
remark
create or replace view USER_PART_HISTOGRAMS
  (TABLE_NAME, PARTITION_NAME, COLUMN_NAME, BUCKET_NUMBER, 
   ENDPOINT_VALUE, ENDPOINT_ACTUAL_VALUE)
as
select o.name, o.subname,
       tp.cname,
       h.bucket,
       h.endpoint,
       h.epvalue
from sys.obj$ o, sys.histgrm$ h, tp$ tp
where o.obj# = h.obj# and h.obj# = tp.obj#
  and tp.intcol# = h.intcol#
  and o.type# = 19 /* TABLE PARTITION */
  and o.owner# = userenv('SCHEMAID')
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
union
select o.name, o.subname,
       tp.cname,
       0,
       h.minimum,
       null
from sys.obj$ o, sys.hist_head$ h, tp$ tp
where o.obj# = tp.obj# and tp.obj# = h.obj#
  and tp.intcol# = h.intcol#
  and o.type# = 19 /* TABLE PARTITION */
  and h.row_cnt = 0 and h.distcnt > 0
  and o.owner# = userenv('SCHEMAID')
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
union
select o.name, o.subname,
       tp.cname,
       1,
       h.maximum,
       null
from sys.obj$ o, sys.hist_head$ h, tp$ tp
where o.obj# = tp.obj# and tp.obj# = h.obj#
  and tp.intcol# = h.intcol#
  and o.type# = 19 /* TABLE PARTITION */
  and h.row_cnt = 0 and h.distcnt > 0
  and o.owner# = userenv('SCHEMAID')
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
/
create or replace public synonym USER_PART_HISTOGRAMS for USER_PART_HISTOGRAMS
/
grant select on USER_PART_HISTOGRAMS to PUBLIC with grant option
/
create or replace view ALL_PART_HISTOGRAMS
  (OWNER, TABLE_NAME, PARTITION_NAME, COLUMN_NAME, BUCKET_NUMBER, 
   ENDPOINT_VALUE, ENDPOINT_ACTUAL_VALUE)
as
select u.name,
       o.name, o.subname,
       tp.cname,
       h.bucket,
       h.endpoint,
       h.epvalue
from sys.obj$ o, sys.histgrm$ h, sys.user$ u, tp$ tp
where o.obj# = tp.obj# and tp.obj# = h.obj#
      and tp.intcol# = h.intcol#
      and o.type# = 19 /* TABLE PARTITION */
      and o.owner# = u.user# and
      o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL and
      (o.owner# = userenv('SCHEMAID')
        or
        tp.bo# in ( select obj#
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
union
select u.name,
       o.name, o.subname,
       tp.cname,
       0,
       h.minimum,
       null
from sys.obj$ o, sys.hist_head$ h, sys.user$ u, tp$ tp
where o.obj# = tp.obj# and tp.obj# = h.obj#
      and tp.intcol# = h.intcol#
      and o.type# = 19 /* TABLE PARTITION */
      and h.row_cnt = 0 and h.distcnt > 0
      and o.owner# = u.user# and
      o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL and
      (o.owner# = userenv('SCHEMAID')
        or
        tp.bo# in ( select obj#
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
union
select u.name,
       o.name, o.subname,
       tp.cname,
       1,
       h.maximum,
       null
from sys.obj$ o, sys.hist_head$ h, sys.user$ u, tp$ tp
where o.obj# = tp.obj# and tp.obj# = h.obj#
      and tp.intcol# = h.intcol#
      and o.type# = 19 /* TABLE PARTITION */
      and h.row_cnt = 0 and h.distcnt > 0
      and o.owner# = u.user# and
      o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL and
      (o.owner# = userenv('SCHEMAID')
        or
        tp.bo# in ( select obj#
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
create or replace public synonym ALL_PART_HISTOGRAMS for ALL_PART_HISTOGRAMS
/
grant select on ALL_PART_HISTOGRAMS to PUBLIC with grant option
/
create or replace view DBA_PART_HISTOGRAMS
  (OWNER, TABLE_NAME, PARTITION_NAME, COLUMN_NAME, BUCKET_NUMBER, 
   ENDPOINT_VALUE, ENDPOINT_ACTUAL_VALUE)
as
select u.name,
       o.name, o.subname,
       tp.cname,
       h.bucket,
       h.endpoint,
       h.epvalue
from sys.obj$ o, sys.histgrm$ h, sys.user$ u, tp$ tp
where o.obj# = tp.obj# and tp.obj# = h.obj# 
  and tp.intcol# = h.intcol#
  and o.type# = 19 /* TABLE PARTITION */
  and o.owner# = u.user#
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
union
select u.name,
       o.name, o.subname,
       tp.cname,
       0,
       h.minimum,
       null
from sys.obj$ o, sys.hist_head$ h, sys.user$ u, tp$ tp
where o.obj# = tp.obj# and tp.obj# = h.obj# 
  and tp.intcol# = h.intcol#
  and o.type# = 19 /* TABLE PARTITION */
  and h.row_cnt = 0 and h.distcnt > 0
  and o.owner# = u.user#
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
union
select u.name,
       o.name, o.subname,
       tp.cname,
       1,
       h.maximum,
       null
from sys.obj$ o, sys.hist_head$ h, sys.user$ u, tp$ tp
where o.obj# = tp.obj# and tp.obj# = h.obj# 
  and tp.intcol# = h.intcol#
  and o.type# = 19 /* TABLE PARTITION */
  and h.row_cnt = 0 and h.distcnt > 0
  and o.owner# = u.user#
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
/
create or replace public synonym DBA_PART_HISTOGRAMS for DBA_PART_HISTOGRAMS
/
grant select on DBA_PART_HISTOGRAMS to select_catalog_role
/

remark 
remark  FAMILY "SUBPART_COL_STATISTICS"
remark   These views contain column statistics and histogram information
remark   for table subpartitions.
remark
create or replace view TSP$ as
select tsp.obj#, tcp.bo#, c.intcol#, 
      decode(bitand(c.property, 1), 1, a.name, c.name) cname
      from sys.col$ c, sys.tabsubpart$ tsp, sys.tabcompart$ tcp, attrcol$ a 
      where tsp.pobj# = tcp.obj# and tcp.bo# = c.obj#
      and bitand(c.property,32768) != 32768    /* not unused columns */
      and c.obj# = a.obj#(+) and c.intcol# = a.intcol#(+)
/
grant select on TSP$ to select_catalog_role
/
create or replace view USER_SUBPART_COL_STATISTICS 
  (TABLE_NAME, SUBPARTITION_NAME, COLUMN_NAME, NUM_DISTINCT, LOW_VALUE,
   HIGH_VALUE, DENSITY, NUM_NULLS, NUM_BUCKETS, SAMPLE_SIZE, LAST_ANALYZED,
   GLOBAL_STATS, USER_STATS, AVG_COL_LEN, HISTOGRAM)
as
select o.name, o.subname, tsp.cname, h.distcnt, h.lowval, h.hival,
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
       h.sample_size, h.timestamp#,
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
from sys.obj$ o, sys.hist_head$ h, tsp$ tsp
where o.obj# = tsp.obj#
  and tsp.obj# = h.obj#(+) and tsp.intcol# = h.intcol#(+)
  and o.type# = 34 /* TABLE SUBPARTITION */
  and o.owner# = userenv('SCHEMAID')
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
/
create or replace public synonym USER_SUBPART_COL_STATISTICS
   for USER_SUBPART_COL_STATISTICS 
/
grant select on USER_SUBPART_COL_STATISTICS to PUBLIC with grant option
/
create or replace view ALL_SUBPART_COL_STATISTICS 
  (OWNER, TABLE_NAME, SUBPARTITION_NAME, COLUMN_NAME, NUM_DISTINCT, LOW_VALUE,
   HIGH_VALUE, DENSITY, NUM_NULLS, NUM_BUCKETS, SAMPLE_SIZE, LAST_ANALYZED,
   GLOBAL_STATS, USER_STATS, AVG_COL_LEN, HISTOGRAM)
as
select u.name, o.name, o.subname, tsp.cname, h.distcnt, h.lowval, h.hival, 
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
       h.sample_size, h.timestamp#,
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
from sys.obj$ o, sys.hist_head$ h, tsp$ tsp, user$ u
where o.obj# = tsp.obj# and tsp.obj# = h.obj#(+)
  and tsp.intcol# = h.intcol#(+)
  and o.type# = 34 /* TABLE SUBPARTITION */
  and o.owner# = u.user#
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  and (o.owner# = userenv('SCHEMAID')
        or tsp.bo# in
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
create or replace public synonym ALL_SUBPART_COL_STATISTICS
   for ALL_SUBPART_COL_STATISTICS 
/
grant select on ALL_SUBPART_COL_STATISTICS to PUBLIC with grant option
/
create or replace view DBA_SUBPART_COL_STATISTICS 
  (OWNER, TABLE_NAME, SUBPARTITION_NAME, COLUMN_NAME, NUM_DISTINCT, LOW_VALUE,
   HIGH_VALUE, DENSITY, NUM_NULLS, NUM_BUCKETS, SAMPLE_SIZE, LAST_ANALYZED,
   GLOBAL_STATS, USER_STATS, AVG_COL_LEN, HISTOGRAM)
as
select u.name, o.name, o.subname, tsp.cname, h.distcnt, h.lowval, h.hival, 
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
       h.sample_size, h.timestamp#,
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
from sys.obj$ o, sys.hist_head$ h, tsp$ tsp, user$ u
where o.obj# = tsp.obj# and tsp.obj# = h.obj#(+)
  and tsp.intcol# = h.intcol#(+)
  and o.type# = 34 /* TABLE SUBPARTITION */
  and o.owner# = u.user#
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
/
create or replace public synonym DBA_SUBPART_COL_STATISTICS
   for DBA_SUBPART_COL_STATISTICS
/
grant select on DBA_SUBPART_COL_STATISTICS to select_catalog_role
/

remark
remark  FAMILY "SUBPART_HISTOGRAMS"
remark   These views contain the actual histogram data (end-points per
remark   histogram) for histograms on table subpartitions.
remark
create or replace view USER_SUBPART_HISTOGRAMS
  (TABLE_NAME, SUBPARTITION_NAME, COLUMN_NAME, BUCKET_NUMBER, 
   ENDPOINT_VALUE, ENDPOINT_ACTUAL_VALUE)
as
select o.name, o.subname,
       tsp.cname,
       h.bucket,
       h.endpoint,
       h.epvalue
from sys.obj$ o, sys.histgrm$ h, tsp$ tsp
where o.obj# = h.obj# and h.obj# = tsp.obj#
  and tsp.intcol# = h.intcol#
  and o.type# = 34 /* TABLE SUBPARTITION */
  and o.owner# = userenv('SCHEMAID')
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
union
select o.name, o.subname,
       tsp.cname,
       0,
       h.minimum,
       null
from sys.obj$ o, sys.hist_head$ h, tsp$ tsp
where o.obj# = tsp.obj# and tsp.obj# = h.obj#
  and tsp.intcol# = h.intcol#
  and o.type# = 34 /* TABLE SUBPARTITION */
  and h.row_cnt = 0 and h.distcnt > 0
  and o.owner# = userenv('SCHEMAID')
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
union
select o.name, o.subname,
       tsp.cname,
       1,
       h.maximum,
       null
from sys.obj$ o, sys.hist_head$ h, tsp$ tsp
where o.obj# = tsp.obj# and tsp.obj# = h.obj#
  and tsp.intcol# = h.intcol#
  and o.type# = 34 /* TABLE SUBPARTITION */
  and h.row_cnt = 0 and h.distcnt > 0
  and o.owner# = userenv('SCHEMAID')
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
/
create or replace public synonym USER_SUBPART_HISTOGRAMS
   for USER_SUBPART_HISTOGRAMS
/
grant select on USER_SUBPART_HISTOGRAMS to PUBLIC with grant option
/
create or replace view ALL_SUBPART_HISTOGRAMS
  (OWNER, TABLE_NAME, SUBPARTITION_NAME, COLUMN_NAME, BUCKET_NUMBER, 
   ENDPOINT_VALUE, ENDPOINT_ACTUAL_VALUE)
as
select u.name,
       o.name, o.subname,
       tsp.cname,
       h.bucket,
       h.endpoint,
       h.epvalue
from sys.obj$ o, sys.histgrm$ h, sys.user$ u, tsp$ tsp
where o.obj# = tsp.obj# and tsp.obj# = h.obj#
  and tsp.intcol# = h.intcol#
  and o.type# = 34 /* TABLE SUBPARTITION */
  and o.owner# = u.user#
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  and (o.owner# = userenv('SCHEMAID')
        or
        tsp.bo# in ( select obj#
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
union
select u.name,
       o.name, o.subname,
       tsp.cname,
       0,
       h.minimum,
       null
from sys.obj$ o, sys.hist_head$ h, sys.user$ u, tsp$ tsp
where o.obj# = tsp.obj# and tsp.obj# = h.obj#
  and tsp.intcol# = h.intcol#
  and o.type# = 34 /* TABLE SUBPARTITION */
  and h.row_cnt = 0 and h.distcnt > 0
  and o.owner# = u.user#
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  and (o.owner# = userenv('SCHEMAID')
        or
        tsp.bo# in ( select obj#
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
union
select u.name,
       o.name, o.subname,
       tsp.cname,
       1,
       h.maximum,
       null
from sys.obj$ o, sys.hist_head$ h, sys.user$ u, tsp$ tsp
where o.obj# = tsp.obj# and tsp.obj# = h.obj#
  and tsp.intcol# = h.intcol#
  and o.type# = 34 /* TABLE SUBPARTITION */
  and h.row_cnt = 0 and h.distcnt > 0
  and o.owner# = u.user#
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  and (o.owner# = userenv('SCHEMAID')
        or
        tsp.bo# in ( select obj#
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
create or replace public synonym ALL_SUBPART_HISTOGRAMS
   for ALL_SUBPART_HISTOGRAMS
/
grant select on ALL_SUBPART_HISTOGRAMS to PUBLIC with grant option
/
create or replace view DBA_SUBPART_HISTOGRAMS
  (OWNER, TABLE_NAME, SUBPARTITION_NAME, COLUMN_NAME, BUCKET_NUMBER, 
   ENDPOINT_VALUE, ENDPOINT_ACTUAL_VALUE)
as
select u.name,
       o.name, o.subname,
       tsp.cname,
       h.bucket,
       h.endpoint,
       h.epvalue
from sys.obj$ o, sys.histgrm$ h, sys.user$ u, tsp$ tsp
where o.obj# = tsp.obj# and tsp.obj# = h.obj#
  and tsp.intcol# = h.intcol#
  and o.type# = 34 /* TABLE SUBPARTITION */
  and o.owner# = u.user#
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
union
select u.name,
       o.name, o.subname,
       tsp.cname,
       0,
       h.minimum,
       null
from sys.obj$ o, sys.hist_head$ h, sys.user$ u, tsp$ tsp
where o.obj# = tsp.obj# and tsp.obj# = h.obj#
  and tsp.intcol# = h.intcol#
  and o.type# = 34 /* TABLE SUBPARTITION */
  and h.row_cnt = 0 and h.distcnt > 0
  and o.owner# = u.user#
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
union
select u.name,
       o.name, o.subname,
       tsp.cname,
       1,
       h.maximum,
       null
from sys.obj$ o, sys.hist_head$ h, sys.user$ u, tsp$ tsp
where o.obj# = tsp.obj# and tsp.obj# = h.obj#
  and tsp.intcol# = h.intcol#
  and o.type# = 34 /* TABLE SUBPARTITION */
  and h.row_cnt = 0 and h.distcnt > 0
  and o.owner# = u.user#
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
/
create or replace public synonym DBA_SUBPART_HISTOGRAMS
   for DBA_SUBPART_HISTOGRAMS
/
grant select on DBA_SUBPART_HISTOGRAMS to select_catalog_role
/


remark
remark  FAMILY "SUBPART_KEY_COLUMNS"
remark   This family of views will describe the subpartitioning key columns for
remark   all Range Composite (R+H) partitioned objects.
remark
remark   using an UNION rather than an OR for speed.
create or replace view USER_SUBPART_KEY_COLUMNS
      (NAME, OBJECT_TYPE, COLUMN_NAME, COLUMN_POSITION)
as
select o.name, 'TABLE', 
  decode(bitand(c.property, 1), 1, a.name, c.name), spc.pos#
from   obj$ o, subpartcol$ spc, col$ c, attrcol$ a
where  spc.obj# = o.obj# and spc.obj# = c.obj#
       and c.intcol# = spc.intcol# and o.owner# = userenv('SCHEMAID')
       and c.obj# = a.obj#(+) and c.intcol# = a.intcol#(+)
       and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
       and o.subname IS NULL
union
select o.name, 'INDEX', 
  decode(bitand(c.property, 1), 1, a.name, c.name), spc.pos#
from   obj$ o, subpartcol$ spc, col$ c, ind$ i, attrcol$ a
where  spc.obj# = i.obj# and i.obj# = o.obj# and i.bo# = c.obj#
       and c.intcol# = spc.intcol# and o.owner# = userenv('SCHEMAID')
       and c.obj# = a.obj#(+) and c.intcol# = a.intcol#(+)
       and o.namespace = 4 and o.remoteowner IS NULL and o.linkname IS NULL
       and o.subname IS NULL
/
create or replace public synonym USER_SUBPART_KEY_COLUMNS
   for USER_SUBPART_KEY_COLUMNS
/
grant select on USER_SUBPART_KEY_COLUMNS to PUBLIC with grant option
/
create or replace view ALL_SUBPART_KEY_COLUMNS
  (OWNER, NAME, OBJECT_TYPE, COLUMN_NAME, COLUMN_POSITION)
as
select u.name, o.name, 'TABLE', 
  decode(bitand(c.property, 1), 1, a.name, c.name), spc.pos#
from   obj$ o, subpartcol$ spc, col$ c, user$ u, attrcol$ a
where  spc.obj# = o.obj# and spc.obj# = c.obj#
       and c.intcol# = spc.intcol#
       and u.user# = o.owner# and
       c.obj# = a.obj#(+) and c.intcol# = a.intcol#(+) and 
       o.subname IS NULL and 
       o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL and
      (o.owner# = userenv('SCHEMAID')
       or spc.obj# in
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
union
select u.name, o.name, 'INDEX', 
  decode(bitand(c.property, 1), 1, a.name, c.name), spc.pos#
from   obj$ o, subpartcol$ spc, col$ c, user$ u, ind$ i, attrcol$ a
where spc.obj# = i.obj# and i.obj# = o.obj# and i.bo# = c.obj# 
      and c.intcol# = spc.intcol#
      and u.user# = o.owner# and 
      c.obj# = a.obj#(+) and c.intcol# = a.intcol#(+) and 
      o.subname IS NULL and 
      o.namespace = 4 and o.remoteowner IS NULL and o.linkname IS NULL and
      (o.owner# = userenv('SCHEMAID')
       or i.bo# in
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
create or replace public synonym ALL_SUBPART_KEY_COLUMNS
   for ALL_SUBPART_KEY_COLUMNS
/
grant select on ALL_SUBPART_KEY_COLUMNS to PUBLIC with grant option
/
create or replace view DBA_SUBPART_KEY_COLUMNS
  (OWNER, NAME, OBJECT_TYPE, COLUMN_NAME, COLUMN_POSITION)
as
select u.name, o.name, 'TABLE', 
  decode(bitand(c.property, 1), 1, a.name, c.name), spc.pos#
from   obj$ o, subpartcol$ spc, col$ c, user$ u, attrcol$ a
where  spc.obj# = o.obj# and spc.obj# = c.obj#
       and c.intcol# = spc.intcol#
       and u.user# = o.owner# 
       and c.obj# = a.obj#(+) and c.intcol# = a.intcol#(+)
       and o.subname IS NULL
       and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
union 
select u.name, o.name, 'INDEX', 
  decode(bitand(c.property, 1), 1, a.name, c.name), spc.pos#
from   obj$ o, subpartcol$ spc, col$ c, user$ u, ind$ i, attrcol$ a
where  spc.obj# = i.obj# and i.obj# = o.obj# and i.bo# = c.obj#
       and c.intcol# = spc.intcol#
       and u.user# = o.owner# 
       and c.obj# = a.obj#(+) and c.intcol# = a.intcol#(+)
       and o.subname IS NULL
       and o.namespace = 4 and o.remoteowner IS NULL and o.linkname IS NULL
/
create or replace public synonym DBA_SUBPART_KEY_COLUMNS
   for DBA_SUBPART_KEY_COLUMNS
/
grant select on DBA_SUBPART_KEY_COLUMNS to select_catalog_role
/
remark
remark  FAMILY "PART_LOBS"
remark   This family of views will describe the object level information
remark   for LOB columns contained in partitioned tables.
remark
create or replace view USER_PART_LOBS 
  (TABLE_NAME, COLUMN_NAME, LOB_NAME, LOB_INDEX_NAME, DEF_CHUNK,
   DEF_PCTVERSION, DEF_CACHE, DEF_IN_ROW,
   DEF_TABLESPACE_NAME, DEF_INITIAL_EXTENT, DEF_NEXT_EXTENT, DEF_MIN_EXTENTS, 
   DEF_MAX_EXTENTS, DEF_PCT_INCREASE, DEF_FREELISTS, DEF_FREELIST_GROUPS,
   DEF_LOGGING, DEF_BUFFER_POOL)
as 
select o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       lo.name, 
       io.name,
       plob.defchunk,
       plob.defpctver$,
       decode(bitand(plob.defflags, 27), 1, 'NO', 2, 'NO', 8, 'CACHEREADS',
                                         16, 'CACHEREADS', 'YES'),
       decode(plob.defpro, 0, 'NO', 'YES'),
       ts.name,
       decode(plob.definiexts, NULL, 'DEFAULT', plob.definiexts),
       decode(plob.defextsize, NULL, 'DEFAULT', plob.defextsize),
       decode(plob.defminexts, NULL, 'DEFAULT', plob.defminexts),
       decode(plob.defmaxexts, NULL, 'DEFAULT', plob.defmaxexts),
       decode(plob.defextpct,  NULL, 'DEFAULT', plob.defextpct),
       decode(plob.deflists,   NULL, 'DEFAULT', plob.deflists),
       decode(plob.defgroups,  NULL, 'DEFAULT', plob.defgroups),
       decode(bitand(plob.defflags,22), 0,'NONE', 4,'YES', 2,'NO',  
                                        16,'NO', 'UNKNOWN'),
       decode(plob.defbufpool, 0, 'DEFAULT', 1, 'KEEP', 2, 'RECYCLE', NULL)
from   sys.obj$ o, sys.col$ c, sys.lob$ l, sys.partlob$ plob, 
       sys.obj$ lo, sys.obj$ io, sys.ts$ ts, attrcol$ a
where o.owner# = userenv('SCHEMAID')
  and o.obj# = c.obj#
  and c.obj# = l.obj#
  and c.intcol# = l.intcol#
  and l.lobj# = lo.obj#
  and l.ind# = io.obj#
  and l.lobj# = plob.lobj#
  and plob.defts# = ts.ts# (+)
  and bitand(c.property,32768) != 32768           /* not unused column */
  and c.obj# = a.obj#(+) and c.intcol# = a.intcol#(+)
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  and o.subname IS NULL  
  and lo.namespace = 8 and lo.remoteowner IS NULL and lo.linkname IS NULL
  and lo.subname IS NULL and lo.owner# = userenv('SCHEMAID')
/ 
create or replace public synonym USER_PART_LOBS for USER_PART_LOBS 
/
grant select on USER_PART_LOBS to PUBLIC with grant option
/
create or replace view ALL_PART_LOBS 
  (TABLE_OWNER, TABLE_NAME, COLUMN_NAME, LOB_NAME, LOB_INDEX_NAME, DEF_CHUNK,
   DEF_PCTVERSION, DEF_CACHE, DEF_IN_ROW,
   DEF_TABLESPACE_NAME, DEF_INITIAL_EXTENT, DEF_NEXT_EXTENT, DEF_MIN_EXTENTS, 
   DEF_MAX_EXTENTS, DEF_PCT_INCREASE, DEF_FREELISTS, DEF_FREELIST_GROUPS,
   DEF_LOGGING, DEF_BUFFER_POOL)
as 
select u.name, 
       o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       lo.name, 
       io.name,
       plob.defchunk,
       plob.defpctver$,
       decode(bitand(plob.defflags, 27), 1, 'NO', 2, 'NO', 8, 'CACHEREADS',
                                         16, 'CACHEREADS', 'YES'), 
       decode(plob.defpro, 0, 'NO', 'YES'),
       ts.name,
       decode(plob.definiexts, NULL, 'DEFAULT', plob.definiexts),
       decode(plob.defextsize, NULL, 'DEFAULT', plob.defextsize),
       decode(plob.defminexts, NULL, 'DEFAULT', plob.defminexts),
       decode(plob.defmaxexts, NULL, 'DEFAULT', plob.defmaxexts),
       decode(plob.defextpct,  NULL, 'DEFAULT', plob.defextpct),
       decode(plob.deflists,   NULL, 'DEFAULT', plob.deflists),
       decode(plob.defgroups,  NULL, 'DEFAULT', plob.defgroups),
       decode(bitand(plob.defflags,22), 0,'NONE', 4,'YES', 2,'NO',
                                        16,'NO', 'UNKNOWN'),
       decode(plob.defbufpool, 0, 'DEFAULT', 1, 'KEEP', 2, 'RECYCLE', NULL)
from   sys.obj$ o, sys.col$ c, sys.lob$ l, sys.partlob$ plob, 
       sys.obj$ lo, sys.obj$ io, sys.ts$ ts, sys.user$ u, attrcol$ a
where o.owner# = u.user#
  and o.obj# = c.obj#
  and c.obj# = l.obj#
  and c.intcol# = l.intcol#
  and l.lobj# = lo.obj#
  and l.ind# = io.obj#
  and l.lobj# = plob.lobj#
  and plob.defts# = ts.ts# (+)
  and bitand(c.property,32768) != 32768           /* not unused column */
  and c.obj# = a.obj#(+) and c.intcol# = a.intcol#(+)
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  and o.subname IS NULL and lo.subname IS NULL
  and lo.namespace = 8 and lo.remoteowner IS NULL and lo.linkname IS NULL 
  and ((o.owner# = userenv('SCHEMAID') and lo.owner# = userenv('SCHEMAID'))
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
create or replace public synonym ALL_PART_LOBS for ALL_PART_LOBS 
/
grant select on ALL_PART_LOBS to PUBLIC with grant option
/
create or replace view DBA_PART_LOBS 
  (TABLE_OWNER, TABLE_NAME, COLUMN_NAME, LOB_NAME, LOB_INDEX_NAME, DEF_CHUNK,
   DEF_PCTVERSION, DEF_CACHE, DEF_IN_ROW,
   DEF_TABLESPACE_NAME, DEF_INITIAL_EXTENT, DEF_NEXT_EXTENT, DEF_MIN_EXTENTS, 
   DEF_MAX_EXTENTS, DEF_PCT_INCREASE, DEF_FREELISTS, DEF_FREELIST_GROUPS,
   DEF_LOGGING, DEF_BUFFER_POOL)
as 
select u.name, 
       o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       lo.name, 
       io.name,
       plob.defchunk,
       plob.defpctver$,
       decode(bitand(plob.defflags, 27), 1, 'NO', 2, 'NO', 8, 'CACHEREADS',
                                         16, 'CACHEREADS', 'YES'), 
       decode(plob.defpro, 0, 'NO', 'YES'),
       ts.name,
       decode(plob.definiexts, NULL, 'DEFAULT', plob.definiexts),
       decode(plob.defextsize, NULL, 'DEFAULT', plob.defextsize),
       decode(plob.defminexts, NULL, 'DEFAULT', plob.defminexts),
       decode(plob.defmaxexts, NULL, 'DEFAULT', plob.defmaxexts),
       decode(plob.defextpct,  NULL, 'DEFAULT', plob.defextpct),
       decode(plob.deflists,   NULL, 'DEFAULT', plob.deflists),
       decode(plob.defgroups,  NULL, 'DEFAULT', plob.defgroups),
       decode(bitand(plob.defflags,22), 0,'NONE', 4,'YES', 2,'NO', 
                                        16,'NO', 'UNKNOWN'),
       decode(plob.defbufpool, 0, 'DEFAULT', 1, 'KEEP', 2, 'RECYCLE', NULL)
from   sys.obj$ o, sys.col$ c, sys.lob$ l, sys.partlob$ plob, 
       sys.obj$ lo, sys.obj$ io, sys.ts$ ts, sys.user$ u, attrcol$ a
where o.owner# = u.user#
  and o.obj# = c.obj#
  and c.obj# = l.obj#
  and c.intcol# = l.intcol#
  and l.lobj# = lo.obj#
  and l.ind# = io.obj#
  and l.lobj# = plob.lobj#
  and plob.defts# = ts.ts# (+)
  and bitand(c.property,32768) != 32768           /* not unused column */
  and c.obj# = a.obj#(+) and c.intcol# = a.intcol#(+)
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  and o.subname IS NULL and lo.subname IS NULL 
  and lo.namespace = 8 and lo.remoteowner IS NULL and lo.linkname IS NULL
/ 
create or replace public synonym DBA_PART_LOBS for DBA_PART_LOBS
/
grant select on DBA_PART_LOBS to select_catalog_role
/
remark
remark  FAMILY "LOB_PARTITIONS"
remark   This family of views will describe partitions of LOB columns 
remark   belonging to partitioned tables
remark
create or replace view USER_LOB_PARTITIONS 
  (TABLE_NAME, COLUMN_NAME, LOB_NAME, 
   PARTITION_NAME, LOB_PARTITION_NAME, LOB_INDPART_NAME, PARTITION_POSITION, 
   COMPOSITE, CHUNK, PCTVERSION, CACHE, IN_ROW,
   TABLESPACE_NAME, INITIAL_EXTENT, NEXT_EXTENT, MIN_EXTENTS, 
   MAX_EXTENTS, PCT_INCREASE, FREELISTS, FREELIST_GROUPS,
   LOGGING, BUFFER_POOL)
as 
select o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       lo.name,
       po.subname,
       lpo.subname,
       lipo.subname,
       lf.frag#,
       'NO',
       lf.chunk * ts.blocksize,
       lf.pctversion$,
       decode(bitand(lf.fragflags,27), 1, 'NO', 2, 'NO', 8, 'CACHEREADS',
                                       16, 'CACHEREADS', 'YES'), 
       decode(lf.fragpro, 0, 'NO', 'YES'),
       ts.name,
       to_char(s.iniexts * ts.blocksize), 
       to_char(decode(bitand(ts.flags, 3), 1, to_number(NULL),
            s.extsize * ts.blocksize)),
       to_char(s.minexts),
       to_char(s.maxexts),
       to_char(decode(bitand(ts.flags, 3), 1, to_number(NULL),s.extpct)),
       to_char(decode(s.lists, 0, 1, s.lists)), 
       to_char(decode(s.groups, 0, 1, s.groups)),
       decode(bitand(lf.fragflags, 18), 2, 'NO', 16, 'NO', 'YES'),
       decode(s.cachehint, 0, 'DEFAULT', 1, 'KEEP', 2, 'RECYCLE', NULL)
from   sys.obj$ o, sys.col$ c, 
       sys.lob$ l, sys.obj$ lo, 
       sys.lobfragv$ lf, sys.obj$ lpo, 
       sys.obj$ po, sys.obj$ lipo, 
       sys.partobj$ pobj, sys.tab$ t,
       sys.ts$ ts, sys.seg$ s, attrcol$ a
where o.owner# = userenv('SCHEMAID')
  and pobj.obj# = o.obj#
  and o.obj# = t.obj#
  and bitand(t.trigflag, 1073741824) != 1073741824
  and mod(pobj.spare2, 256) = 0
  and o.obj# = c.obj#
  and c.obj# = l.obj#
  and c.intcol# = l.intcol#
  and l.lobj# = lo.obj#
  and l.lobj# = lf.parentobj#
  and lf.tabfragobj# = po.obj#
  and lf.fragobj# = lpo.obj#
  and lf.indfragobj# = lipo.obj#
  and lf.ts# = s.ts#
  and lf.file# = s.file#
  and lf.block# = s.block#
  and lf.ts# = ts.ts#
  and bitand(c.property,32768) != 32768           /* not unused column */
  and c.obj# = a.obj#(+) and c.intcol# = a.intcol#(+)
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  and lo.namespace = 8 and lo.remoteowner IS NULL and lo.linkname IS NULL
  and lo.owner# = userenv('SCHEMAID')
union all
select o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       lo.name,
       po.subname,
       lpo.subname,
       lipo.subname,
       lcp.part#,
       'YES',
       lcp.defchunk,
       lcp.defpctver$,
       decode(bitand(lcp.defflags,27), 1, 'NO', 2, 'NO', 8, 'CACHEREADS',
                                       16, 'CACHEREADS', 'YES'), 
       decode(lcp.defpro, 0, 'NO', 'YES'),
       ts.name,
       decode(lcp.definiexts, NULL, 'DEFAULT', lcp.definiexts),
       decode(lcp.defextsize, NULL, 'DEFAULT', lcp.defextsize),
       decode(lcp.defminexts, NULL, 'DEFAULT', lcp.defminexts),
       decode(lcp.defmaxexts, NULL, 'DEFAULT', lcp.defmaxexts),
       decode(lcp.defextpct,  NULL, 'DEFAULT', lcp.defextpct),
       decode(lcp.deflists,   NULL, 'DEFAULT', lcp.deflists),
       decode(lcp.defgroups,  NULL, 'DEFAULT', lcp.defgroups),
       decode(bitand(lcp.defflags,22), 0,'NONE', 4,'YES', 2,'NO', 16,'NO', 'UNKNOWN'),
       decode(lcp.defbufpool, 0, 'DEFAULT', 1, 'KEEP', 2, 'RECYCLE', NULL)
from   sys.obj$ o, sys.col$ c, 
       sys.lob$ l, sys.obj$ lo, 
       sys.lobcomppartv$ lcp, sys.obj$ lpo, 
       sys.obj$ po, sys.obj$ lipo, 
       sys.ts$ ts, sys.partobj$ pobj, sys.tab$ t, attrcol$ a
where o.owner# = userenv('SCHEMAID')
  and pobj.obj# = o.obj#
  and o.obj# = t.obj#
  and bitand(t.trigflag, 1073741824) != 1073741824
  and mod(pobj.spare2, 256) != 0
  and o.obj# = c.obj#
  and c.obj# = l.obj#
  and c.intcol# = l.intcol#
  and l.lobj# = lo.obj#
  and l.lobj# = lcp.lobj#
  and lcp.tabpartobj# = po.obj#
  and lcp.partobj# = lpo.obj#
  and lcp.indpartobj# = lipo.obj#
  and lcp.defts# = ts.ts# (+)
  and bitand(c.property,32768) != 32768           /* not unused column */
  and c.obj# = a.obj#(+) and c.intcol# = a.intcol#(+)
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  and lo.namespace = 8 and lo.remoteowner IS NULL and lo.linkname IS NULL
  and lo.owner# = userenv('SCHEMAID')
/ 
create or replace public synonym USER_LOB_PARTITIONS for USER_LOB_PARTITIONS 
/
grant select on USER_LOB_PARTITIONS to PUBLIC with grant option
/
create or replace view ALL_LOB_PARTITIONS 
  (TABLE_OWNER, TABLE_NAME, COLUMN_NAME, LOB_NAME, 
   PARTITION_NAME, LOB_PARTITION_NAME, LOB_INDPART_NAME, PARTITION_POSITION, 
   COMPOSITE, CHUNK, PCTVERSION, CACHE, IN_ROW,
   TABLESPACE_NAME, INITIAL_EXTENT, NEXT_EXTENT, MIN_EXTENTS, 
   MAX_EXTENTS, PCT_INCREASE, FREELISTS, FREELIST_GROUPS,
   LOGGING, BUFFER_POOL)
as 
select u.name,
       o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       lo.name,
       po.subname,
       lpo.subname,
       lipo.subname,
       lf.frag#,
       'NO',
       lf.chunk * ts.blocksize,
       lf.pctversion$,
       decode(bitand(lf.fragflags,27), 1, 'NO', 2, 'NO', 8, 'CACHEREADS',
                                       16, 'CACHEREADS', 'YES'), 
       decode(lf.fragpro, 0, 'NO', 'YES'),
       ts.name,
       to_char(s.iniexts * ts.blocksize), 
       to_char(decode(bitand(ts.flags, 3), 1, to_number(NULL),
            s.extsize * ts.blocksize)),
       to_char(s.minexts),
       to_char(s.maxexts),
       to_char(decode(bitand(ts.flags, 3), 1, to_number(NULL),s.extpct)),
       to_char(decode(s.lists, 0, 1, s.lists)), 
       to_char(decode(s.groups, 0, 1, s.groups)),
       decode(bitand(lf.fragflags, 18), 2, 'NO', 16, 'NO', 'YES'),
       decode(s.cachehint, 0, 'DEFAULT', 1, 'KEEP', 2, 'RECYCLE', NULL)
from   sys.obj$ o, sys.col$ c, 
       sys.lob$ l, sys.obj$ lo, 
       sys.lobfragv$ lf, sys.obj$ lpo, 
       sys.obj$ po, sys.obj$ lipo, 
       sys.partobj$ pobj, sys.tab$ t,
       sys.ts$ ts, sys.seg$ s, sys.user$ u, attrcol$ a
where o.owner# = u.user#
  and pobj.obj# = o.obj#
  and o.obj# = t.obj#
  and bitand(t.trigflag, 1073741824) != 1073741824
  and mod(pobj.spare2, 256) = 0
  and o.obj# = c.obj#
  and c.obj# = l.obj#
  and c.intcol# = l.intcol#
  and l.lobj# = lo.obj#
  and l.lobj# = lf.parentobj#
  and lf.tabfragobj# = po.obj#
  and lf.fragobj# = lpo.obj#
  and lf.indfragobj# = lipo.obj#
  and lf.ts# = s.ts#
  and lf.file# = s.file#
  and lf.block# = s.block#
  and lf.ts# = ts.ts#
  and bitand(c.property,32768) != 32768           /* not unused column */
  and c.obj# = a.obj#(+) and c.intcol# = a.intcol#(+)
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  and lo.namespace = 8 and lo.remoteowner IS NULL and lo.linkname IS NULL 
  and ((o.owner# = userenv('SCHEMAID') and lo.owner# = userenv('SCHEMAID'))
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
union all
select u.name,
       o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       lo.name,
       po.subname,
       lpo.subname,
       lipo.subname,
       lcp.part#,
       'YES',
       lcp.defchunk,
       lcp.defpctver$,
       decode(bitand(lcp.defflags, 27), 1, 'NO', 2, 'NO', 8, 'CACHEREADS',
                                       16, 'CACHEREADS', 'YES'), 
       decode(lcp.defpro, 0, 'NO', 'YES'),
       ts.name,
       decode(lcp.definiexts, NULL, 'DEFAULT', lcp.definiexts),
       decode(lcp.defextsize, NULL, 'DEFAULT', lcp.defextsize),
       decode(lcp.defminexts, NULL, 'DEFAULT', lcp.defminexts),
       decode(lcp.defmaxexts, NULL, 'DEFAULT', lcp.defmaxexts),
       decode(lcp.defextpct,  NULL, 'DEFAULT', lcp.defextpct),
       decode(lcp.deflists,   NULL, 'DEFAULT', lcp.deflists),
       decode(lcp.defgroups,  NULL, 'DEFAULT', lcp.defgroups),
       decode(bitand(lcp.defflags,22), 0,'NONE', 4,'YES', 2,'NO', 16,'NO', 'UNKNOWN'),
       decode(lcp.defbufpool, 0, 'DEFAULT', 1, 'KEEP', 2, 'RECYCLE', NULL)
from   sys.obj$ o, sys.col$ c, 
       sys.lob$ l, sys.obj$ lo, 
       sys.lobcomppartv$ lcp, sys.obj$ lpo, 
       sys.obj$ po, sys.obj$ lipo, 
       sys.ts$ ts, partobj$ pobj, sys.tab$ t, sys.user$ u, attrcol$ a
where o.owner# = u.user#
  and pobj.obj# = o.obj#
  and o.obj# = t.obj#
  and bitand(t.trigflag, 1073741824) != 1073741824
  and mod(pobj.spare2, 256) != 0
  and o.obj# = c.obj#
  and c.obj# = l.obj#
  and c.intcol# = l.intcol#
  and l.lobj# = lo.obj#
  and l.lobj# = lcp.lobj#
  and lcp.tabpartobj# = po.obj#
  and lcp.partobj# = lpo.obj#
  and lcp.indpartobj# = lipo.obj#
  and lcp.defts# = ts.ts# (+)
  and bitand(c.property,32768) != 32768           /* not unused column */
  and c.obj# = a.obj#(+) and c.intcol# = a.intcol#(+)
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  and lo.namespace = 8 and lo.remoteowner IS NULL and lo.linkname IS NULL
  and ((o.owner# = userenv('SCHEMAID') and lo.owner# = userenv('SCHEMAID'))
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
create or replace public synonym ALL_LOB_PARTITIONS for ALL_LOB_PARTITIONS 
/
grant select on ALL_LOB_PARTITIONS to PUBLIC with grant option
/
create or replace view DBA_LOB_PARTITIONS 
  (TABLE_OWNER, TABLE_NAME, COLUMN_NAME, LOB_NAME, 
   PARTITION_NAME, LOB_PARTITION_NAME, LOB_INDPART_NAME, PARTITION_POSITION, 
   COMPOSITE, CHUNK, PCTVERSION, CACHE, IN_ROW,
   TABLESPACE_NAME, INITIAL_EXTENT, NEXT_EXTENT, MIN_EXTENTS, 
   MAX_EXTENTS, PCT_INCREASE, FREELISTS, FREELIST_GROUPS,
   LOGGING, BUFFER_POOL)
as 
select u.name,
       o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       lo.name,
       po.subname,
       lpo.subname,
       lipo.subname,
       lf.frag#,
       'NO',
       lf.chunk * ts.blocksize,
       lf.pctversion$,
       decode(bitand(lf.fragflags,27), 1, 'NO', 2, 'NO', 8, 'CACHEREADS',
                                       16, 'CACHEREADS', 'YES'), 
       decode(lf.fragpro, 0, 'NO', 'YES'),
       ts.name,
       to_char(s.iniexts * ts.blocksize), 
       to_char(decode(bitand(ts.flags, 3), 1, to_number(NULL),
            s.extsize * ts.blocksize)),
       to_char(s.minexts),
       to_char(s.maxexts),
       to_char(decode(bitand(ts.flags, 3), 1, to_number(NULL),s.extpct)),
       to_char(decode(s.lists, 0, 1, s.lists)), 
       to_char(decode(s.groups, 0, 1, s.groups)),
       decode(bitand(lf.fragflags, 18), 2, 'NO', 16, 'NO', 'YES'),
       decode(s.cachehint, 0, 'DEFAULT', 1, 'KEEP', 2, 'RECYCLE', NULL)
from   sys.obj$ o, sys.col$ c, 
       sys.lob$ l, sys.obj$ lo, 
       sys.lobfragv$ lf, sys.obj$ lpo, 
       sys.obj$ po, sys.obj$ lipo, 
       sys.partobj$ pobj, sys.tab$ t,
       sys.ts$ ts, sys.seg$ s, sys.user$ u, attrcol$ a
where o.owner# = u.user#
  and pobj.obj# = o.obj#
  and o.obj# = t.obj#
  and bitand(t.trigflag, 1073741824) != 1073741824
  and mod(pobj.spare2, 256) = 0
  and o.obj# = c.obj#
  and c.obj# = l.obj#
  and c.intcol# = l.intcol#
  and l.lobj# = lo.obj#
  and l.lobj# = lf.parentobj#
  and lf.tabfragobj# = po.obj#
  and lf.fragobj# = lpo.obj#
  and lf.indfragobj# = lipo.obj#
  and lf.ts# = s.ts#
  and lf.file# = s.file#
  and lf.block# = s.block#
  and lf.ts# = ts.ts#
  and bitand(c.property,32768) != 32768           /* not unused column */
  and c.obj# = a.obj#(+) and c.intcol# = a.intcol#(+)
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  and lo.namespace = 8 and lo.remoteowner IS NULL and lo.linkname IS NULL
union all
select u.name,
       o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       lo.name,
       po.subname,
       lpo.subname,
       lipo.subname,
       lcp.part#,
       'YES',
       lcp.defchunk,
       lcp.defpctver$,
       decode(bitand(lcp.defflags, 27), 1, 'NO', 2, 'NO', 8, 'CACHEREADS',
                                       16, 'CACHEREADS', 'YES'), 
       decode(lcp.defpro, 0, 'NO', 'YES'),
       ts.name,
       decode(lcp.definiexts, NULL, 'DEFAULT', lcp.definiexts),
       decode(lcp.defextsize, NULL, 'DEFAULT', lcp.defextsize),
       decode(lcp.defminexts, NULL, 'DEFAULT', lcp.defminexts),
       decode(lcp.defmaxexts, NULL, 'DEFAULT', lcp.defmaxexts),
       decode(lcp.defextpct,  NULL, 'DEFAULT', lcp.defextpct),
       decode(lcp.deflists,   NULL, 'DEFAULT', lcp.deflists),
       decode(lcp.defgroups,  NULL, 'DEFAULT', lcp.defgroups),
       decode(bitand(lcp.defflags,22), 0,'NONE', 4,'YES', 2,'NO', 16,'NO', 'UNKNOWN'),
       decode(lcp.defbufpool, 0, 'DEFAULT', 1, 'KEEP', 2, 'RECYCLE', NULL)
from   sys.obj$ o, sys.col$ c, 
       sys.lob$ l, sys.obj$ lo, 
       sys.lobcomppartv$ lcp, sys.obj$ lpo, 
       sys.obj$ po, sys.obj$ lipo, 
       sys.ts$ ts, sys.partobj$ pobj, sys.tab$ t, sys.user$ u, attrcol$ a
where o.owner# = u.user#
  and pobj.obj# = o.obj#
  and o.obj# = t.obj#
  and bitand(t.trigflag, 1073741824) != 1073741824
  and mod(pobj.spare2, 256) != 0
  and o.obj# = c.obj#
  and c.obj# = l.obj#
  and c.intcol# = l.intcol#
  and l.lobj# = lo.obj#
  and l.lobj# = lcp.lobj#
  and lcp.tabpartobj# = po.obj#
  and lcp.partobj# = lpo.obj#
  and lcp.indpartobj# = lipo.obj#
  and lcp.defts# = ts.ts# (+)
  and bitand(c.property,32768) != 32768           /* not unused column */
  and c.obj# = a.obj#(+) and c.intcol# = a.intcol#(+)
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  and lo.namespace = 8 and lo.remoteowner IS NULL and lo.linkname IS NULL
/ 
create or replace public synonym DBA_LOB_PARTITIONS for DBA_LOB_PARTITIONS
/
grant select on DBA_LOB_PARTITIONS to select_catalog_role
/
remark
remark  FAMILY "LOB_SUBPARTITIONS"
remark   This family of views will describe subpartitions of LOB columns 
remark   belonging to partitioned tables
remark
create or replace view USER_LOB_SUBPARTITIONS 
  (TABLE_NAME, COLUMN_NAME, LOB_NAME, LOB_PARTITION_NAME, 
   SUBPARTITION_NAME, LOB_SUBPARTITION_NAME, LOB_INDSUBPART_NAME, 
   SUBPARTITION_POSITION, 
   CHUNK, PCTVERSION, CACHE, IN_ROW,
   TABLESPACE_NAME, INITIAL_EXTENT, NEXT_EXTENT, MIN_EXTENTS, 
   MAX_EXTENTS, PCT_INCREASE, FREELISTS, FREELIST_GROUPS,
   LOGGING, BUFFER_POOL)
as 
select o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       lo.name,
       lpo.subname,
       spo.subname,
       lspo.subname,
       lispo.subname,
       lf.frag#,
       lf.chunk * ts.blocksize,
       lf.pctversion$,
       decode(bitand(lf.fragflags,27), 1, 'NO', 2, 'NO', 8, 'CACHEREADS',
                                       16, 'CACHEREADS', 'YES'), 
       decode(lf.fragpro, 0, 'NO', 'YES'),
       ts.name,
       s.iniexts * ts.blocksize, 
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
            s.extsize * ts.blocksize),
       s.minexts,
       s.maxexts,
       decode(bitand(ts.flags, 3), 1, to_number(NULL),s.extpct),
       decode(s.lists, 0, 1, s.lists), 
       decode(s.groups, 0, 1, s.groups),
       decode(bitand(lf.fragflags, 18), 2, 'NO', 16, 'NO', 'YES'),
       decode(s.cachehint, 0, 'DEFAULT', 1, 'KEEP', 2, 'RECYCLE', NULL)
from   sys.obj$ o, sys.col$ c, 
       sys.lob$ l, sys.obj$ lo, 
       sys.lobcomppartv$ lcp, sys.obj$ lpo,
       sys.lobfragv$ lf, sys.obj$ lspo, 
       sys.obj$ spo, sys.obj$ lispo, 
       sys.partobj$ pobj, sys.tab$ t,
       sys.ts$ ts, sys.seg$ s, attrcol$ a
where o.owner# = userenv('SCHEMAID')
  and pobj.obj# = o.obj#
  and o.obj# = t.obj#
  and bitand(t.trigflag, 1073741824) != 1073741824
  and mod(pobj.spare2, 256) != 0
  and o.obj# = c.obj#
  and c.obj# = l.obj#
  and c.intcol# = l.intcol#
  and l.lobj# = lo.obj#
  and l.lobj# = lcp.lobj#
  and lcp.partobj# = lpo.obj#
  and lf.parentobj# = lcp.partobj#
  and lf.tabfragobj# = spo.obj#
  and lf.fragobj# = lspo.obj#
  and lf.indfragobj# = lispo.obj#
  and lf.ts# = s.ts#
  and lf.file# = s.file#
  and lf.block# = s.block#
  and lf.ts# = ts.ts#
  and bitand(c.property,32768) != 32768           /* not unused column */
  and c.obj# = a.obj#(+) and c.intcol# = a.intcol#(+)
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  and lo.namespace = 8 and lo.remoteowner IS NULL and lo.linkname IS NULL
/ 
create or replace public synonym USER_LOB_SUBPARTITIONS
   for USER_LOB_SUBPARTITIONS 
/
grant select on USER_LOB_SUBPARTITIONS to PUBLIC with grant option
/
create or replace view ALL_LOB_SUBPARTITIONS 
  (TABLE_OWNER, TABLE_NAME, COLUMN_NAME, LOB_NAME, LOB_PARTITION_NAME, 
   SUBPARTITION_NAME, LOB_SUBPARTITION_NAME, LOB_INDSUBPART_NAME, 
   SUBPARTITION_POSITION, 
   CHUNK, PCTVERSION, CACHE, IN_ROW,
   TABLESPACE_NAME, INITIAL_EXTENT, NEXT_EXTENT, MIN_EXTENTS, 
   MAX_EXTENTS, PCT_INCREASE, FREELISTS, FREELIST_GROUPS,
   LOGGING, BUFFER_POOL)
as 
select u.name,
       o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       lo.name,
       lpo.subname,
       spo.subname,
       lspo.subname,
       lispo.subname,
       lf.frag#,
       lf.chunk * ts.blocksize,
       lf.pctversion$,
       decode(bitand(lf.fragflags,27), 1, 'NO', 2, 'NO', 8, 'CACHEREADS',
                                       16, 'CACHEREADS', 'YES'), 
       decode(lf.fragpro, 0, 'NO', 'YES'),
       ts.name,
       s.iniexts * ts.blocksize, 
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
            s.extsize * ts.blocksize),
       s.minexts,
       s.maxexts,
       decode(bitand(ts.flags, 3), 1, to_number(NULL),s.extpct),
       decode(s.lists, 0, 1, s.lists), 
       decode(s.groups, 0, 1, s.groups),
       decode(bitand(lf.fragflags, 18), 2, 'NO', 16, 'NO', 'YES'),
       decode(s.cachehint, 0, 'DEFAULT', 1, 'KEEP', 2, 'RECYCLE', NULL)
from   sys.obj$ o, sys.col$ c, 
       sys.lob$ l, sys.obj$ lo, 
       sys.lobcomppartv$ lcp, sys.obj$ lpo,
       sys.lobfragv$ lf, sys.obj$ lspo, 
       sys.obj$ spo, sys.obj$ lispo, 
       sys.partobj$ pobj, sys.tab$ t,
       sys.ts$ ts, sys.seg$ s, sys.user$ u, attrcol$ a
where o.owner# = u.user#
  and pobj.obj# = o.obj#
  and o.obj# = t.obj#
  and bitand(t.trigflag, 1073741824) != 1073741824
  and mod(pobj.spare2, 256) != 0
  and o.obj# = c.obj#
  and c.obj# = l.obj#
  and c.intcol# = l.intcol#
  and l.lobj# = lo.obj#
  and l.lobj# = lcp.lobj#
  and lcp.partobj# = lpo.obj#
  and lf.parentobj# = lcp.partobj#
  and lf.tabfragobj# = spo.obj#
  and lf.fragobj# = lspo.obj#
  and lf.indfragobj# = lispo.obj#
  and lf.ts# = s.ts#
  and lf.file# = s.file#
  and lf.block# = s.block#
  and lf.ts# = ts.ts#
  and bitand(c.property,32768) != 32768           /* not unused column */
  and c.obj# = a.obj#(+) and c.intcol# = a.intcol#(+)
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  and lo.namespace = 8 and lo.remoteowner IS NULL and lo.linkname IS NULL
  and ((o.owner# = userenv('SCHEMAID') and lo.owner# = userenv('SCHEMAID'))
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
create or replace public synonym ALL_LOB_SUBPARTITIONS
   for ALL_LOB_SUBPARTITIONS 
/
grant select on ALL_LOB_SUBPARTITIONS to PUBLIC with grant option
/
create or replace view DBA_LOB_SUBPARTITIONS 
  (TABLE_OWNER, TABLE_NAME, COLUMN_NAME, LOB_NAME, LOB_PARTITION_NAME, 
   SUBPARTITION_NAME, LOB_SUBPARTITION_NAME, LOB_INDSUBPART_NAME, 
   SUBPARTITION_POSITION, 
   CHUNK, PCTVERSION, CACHE, IN_ROW,
   TABLESPACE_NAME, INITIAL_EXTENT, NEXT_EXTENT, MIN_EXTENTS, 
   MAX_EXTENTS, PCT_INCREASE, FREELISTS, FREELIST_GROUPS,
   LOGGING, BUFFER_POOL)
as 
select u.name,
       o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       lo.name,
       lpo.subname,
       spo.subname,
       lspo.subname,
       lispo.subname,
       lf.frag#,
       lf.chunk * ts.blocksize,
       lf.pctversion$,
       decode(bitand(lf.fragflags,27), 1, 'NO', 2, 'NO', 8, 'CACHEREADS',
                                       16, 'CACHEREADS', 'YES'), 
       decode(lf.fragpro, 0, 'NO', 'YES'),
       ts.name,
       s.iniexts * ts.blocksize, 
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
            s.extsize * ts.blocksize),
       s.minexts,
       s.maxexts,
       decode(bitand(ts.flags, 3), 1, to_number(NULL),s.extpct),
       decode(s.lists, 0, 1, s.lists), 
       decode(s.groups, 0, 1, s.groups),
       decode(bitand(lf.fragflags, 18), 2, 'NO', 16, 'NO', 'YES'),
       decode(s.cachehint, 0, 'DEFAULT', 1, 'KEEP', 2, 'RECYCLE', NULL)
from   sys.obj$ o, sys.col$ c, 
       sys.lob$ l, sys.obj$ lo, 
       sys.lobcomppartv$ lcp, sys.obj$ lpo,
       sys.lobfragv$ lf, sys.obj$ lspo, 
       sys.obj$ spo, sys.obj$ lispo, 
       sys.partobj$ pobj, sys.tab$ t,
       sys.ts$ ts, sys.seg$ s, sys.user$ u, attrcol$ a
where o.owner# = u.user#
  and pobj.obj# = o.obj#
  and o.obj# = t.obj#
  and bitand(t.trigflag, 1073741824) != 1073741824
  and mod(pobj.spare2, 256) != 0
  and o.obj# = c.obj#
  and c.obj# = l.obj#
  and c.intcol# = l.intcol#
  and l.lobj# = lo.obj#
  and l.lobj# = lcp.lobj#
  and lcp.partobj# = lpo.obj#
  and lf.parentobj# = lcp.partobj#
  and lf.tabfragobj# = spo.obj#
  and lf.fragobj# = lspo.obj#
  and lf.indfragobj# = lispo.obj#
  and lf.ts# = s.ts#
  and lf.file# = s.file#
  and lf.block# = s.block#
  and lf.ts# = ts.ts#
  and bitand(c.property,32768) != 32768           /* not unused column */
  and c.obj# = a.obj#(+) and c.intcol# = a.intcol#(+)
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  and lo.namespace = 8 and lo.remoteowner IS NULL and lo.linkname IS NULL
/ 
create or replace public synonym DBA_LOB_SUBPARTITIONS
   for DBA_LOB_SUBPARTITIONS
/
grant select on DBA_LOB_SUBPARTITIONS to select_catalog_role
/

remark Views for template descriptions
create or replace view USER_SUBPARTITION_TEMPLATES 
  (TABLE_NAME, SUBPARTITION_NAME, SUBPARTITION_POSITION, TABLESPACE_NAME, 
  HIGH_BOUND)
as 
select o.name, st.spart_name, st.spart_position + 1, ts.name, st.hiboundval
from sys.obj$ o, sys.defsubpart$ st, sys.ts$ ts
where st.bo# = o.obj# and st.ts# = ts.ts#(+) and o.owner# = userenv('SCHEMAID')
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  and o.subname IS NULL
/
create or replace public synonym USER_SUBPARTITION_TEMPLATES for 
       USER_SUBPARTITION_TEMPLATES
/
grant select on USER_SUBPARTITION_TEMPLATES to PUBLIC with grant option
/
create or replace view DBA_SUBPARTITION_TEMPLATES 
  (USER_NAME, TABLE_NAME, SUBPARTITION_NAME, SUBPARTITION_POSITION, 
  TABLESPACE_NAME, HIGH_BOUND)
as 
select u.name, o.name, st.spart_name, st.spart_position + 1, ts.name, 
       st.hiboundval
from sys.obj$ o, sys.defsubpart$ st, sys.ts$ ts, sys.user$ u
where st.bo# = o.obj# and st.ts# = ts.ts#(+) and o.owner# = u.user#
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  and o.subname IS NULL
/
create or replace public synonym DBA_SUBPARTITION_TEMPLATES for 
       DBA_SUBPARTITION_TEMPLATES
/
grant select on DBA_SUBPARTITION_TEMPLATES to  select_catalog_role
/
create or replace view ALL_SUBPARTITION_TEMPLATES 
  (USER_NAME, TABLE_NAME, SUBPARTITION_NAME, SUBPARTITION_POSITION, 
  TABLESPACE_NAME, HIGH_BOUND)
as 
select u.name, o.name, st.spart_name, st.spart_position + 1, ts.name, 
       st.hiboundval
from sys.obj$ o, sys.defsubpart$ st, sys.ts$ ts, sys.user$ u
where st.bo# = o.obj# and st.ts# = ts.ts#(+) and o.owner# = u.user# and
      o.subname IS NULL and
      o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL and
      (o.owner# = userenv('SCHEMAID') or
       o.obj# in (select oa.obj# from sys.objauth$ oa 
                  where grantee# in ( select kzsrorol from x$kzsro )) or
       exists (select null from v$enabledprivs
               where priv_number in (-45 /* LOCK ANY TABLE */,
                                     -47 /* SELECT ANY TABLE */,
                                     -48 /* INSERT ANY TABLE */,
                                     -49 /* UPDATE ANY TABLE */,
                                     -50 /* DELETE ANY TABLE */)))
/
create or replace public synonym ALL_SUBPARTITION_TEMPLATES for 
       ALL_SUBPARTITION_TEMPLATES
/
grant select on ALL_SUBPARTITION_TEMPLATES to PUBLIC with grant option
/
create or replace view USER_LOB_TEMPLATES
  (TABLE_NAME, LOB_COL_NAME, SUBPARTITION_NAME, LOB_SEGMENT_NAME, 
  TABLESPACE_NAME)
as
select o.name, decode(bitand(c.property, 1), 1, ac.name, c.name), 
       st.spart_name, lst.lob_spart_name, ts.name
from sys.obj$ o, sys.defsubpart$ st, sys.defsubpartlob$ lst, sys.ts$ ts, 
     sys.col$ c, sys.attrcol$ ac
where o.obj# = lst.bo# and st.bo# = lst.bo# and 
      st.spart_position =  lst.spart_position and 
      lst.lob_spart_ts# = ts.ts#(+) and c.obj# = lst.bo# and 
      c.intcol# = lst.intcol# and o.owner# = userenv('SCHEMAID') and
      o.subname IS NULL and
      o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL and
      lst.intcol# = ac.intcol#(+) and lst.bo# = ac.obj#(+)
/
create or replace public synonym USER_LOB_TEMPLATES for USER_LOB_TEMPLATES
/
grant select on USER_LOB_TEMPLATES to PUBLIC with grant option
/
create or replace view DBA_LOB_TEMPLATES
  (USER_NAME, TABLE_NAME, LOB_COL_NAME, SUBPARTITION_NAME, LOB_SEGMENT_NAME, 
  TABLESPACE_NAME)
as
select u.name, o.name, decode(bitand(c.property, 1), 1, ac.name, c.name), 
       st.spart_name, lst.lob_spart_name, ts.name
from sys.obj$ o, sys.defsubpart$ st, sys.defsubpartlob$ lst, sys.ts$ ts, 
     sys.col$ c, sys.attrcol$ ac, sys.user$ u
where o.obj# = lst.bo# and st.bo# = lst.bo# and 
      st.spart_position =  lst.spart_position and 
      lst.lob_spart_ts# = ts.ts#(+) and c.obj# = lst.bo# and 
      c.intcol# = lst.intcol# and lst.intcol# = ac.intcol#(+) and 
      o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL and
      o.owner# = u.user# and o.subname IS NULL
/
create or replace public synonym DBA_LOB_TEMPLATES for DBA_LOB_TEMPLATES
/
grant select on DBA_LOB_TEMPLATES to select_catalog_role
/
create or replace view ALL_LOB_TEMPLATES
  (USER_NAME, TABLE_NAME, LOB_COL_NAME, SUBPARTITION_NAME, LOB_SEGMENT_NAME, 
  TABLESPACE_NAME)
as
select u.name, o.name, decode(bitand(c.property, 1), 1, ac.name, c.name), 
       st.spart_name, lst.lob_spart_name, ts.name
from sys.obj$ o, sys.defsubpart$ st, sys.defsubpartlob$ lst, sys.ts$ ts, 
     sys.col$ c, sys.attrcol$ ac, sys.user$ u
where o.obj# = lst.bo# and st.bo# = lst.bo# and 
      st.spart_position =  lst.spart_position and 
      lst.lob_spart_ts# = ts.ts#(+) and c.obj# = lst.bo# and 
      c.intcol# = lst.intcol# and lst.intcol# = ac.intcol#(+) and 
      o.owner# = u.user# and
      o.subname IS NULL and
      o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL and
      (o.owner# = userenv('SCHEMAID') or
       o.obj# in (select oa.obj# from sys.objauth$ oa 
                  where grantee# in ( select kzsrorol from x$kzsro )) or
       exists (select null from v$enabledprivs
               where priv_number in (-45 /* LOCK ANY TABLE */,
                                     -47 /* SELECT ANY TABLE */,
                                     -48 /* INSERT ANY TABLE */,
                                     -49 /* UPDATE ANY TABLE */,
                                     -50 /* DELETE ANY TABLE */)))
/
create or replace public synonym ALL_LOB_TEMPLATES for ALL_LOB_TEMPLATES
/
grant select on ALL_LOB_TEMPLATES to PUBLIC with grant option
/

/* table and index optimizer statistics */
/*
 * *_TAB_STATISTICS views can be used to display  statistics for
 * tables(including fixed objects)/partitions.
 * The view has the following union all branches
 *   - tables
 *   - non iot partitions
 *   - iot partitions
 *   - composite partitions
 *   - subpartitions
 *   - fixed objects
 * stale_stats column values
 *   null => if not analyzed or if it is fixed table
 *   YES  => if truncated or if more than 10% modification
 *   NO   => otherwise
 */
CREATE OR REPLACE VIEW ALL_TAB_STATISTICS
 (
  owner,
  table_name,
  partition_name,
  partition_position,
  subpartition_name,
  subpartition_position,
  object_type,
  num_rows,
  blocks,
  empty_blocks,
  avg_space,
  chain_cnt,
  avg_row_len,
  avg_space_freelist_blocks,
  num_freelist_blocks,
  avg_cached_blocks,
  avg_cache_hit_ratio,
  sample_size,
  last_analyzed,
  global_stats, 
  user_stats,
  stattype_locked,
  stale_stats
  )
  AS
  SELECT /* TABLES */
    u.name, o.name, NULL, NULL, NULL, NULL, 'TABLE', t.rowcnt,
    decode(bitand(t.property, 64), 0, t.blkcnt, TO_NUMBER(NULL)), 
    decode(bitand(t.property, 64), 0, t.empcnt, TO_NUMBER(NULL)), 
    decode(bitand(t.property, 64), 0, t.avgspc, TO_NUMBER(NULL)),
    t.chncnt, t.avgrln, t.avgspc_flb,
    decode(bitand(t.property, 64), 0, t.flbcnt, TO_NUMBER(NULL)), 
    ts.cachedblk, ts.cachehit, t.samplesize, t.analyzetime,
    decode(bitand(t.flags, 512), 0, 'NO', 'YES'),
    decode(bitand(t.flags, 256), 0, 'NO', 'YES'),
    decode(bitand(t.trigflag, 67108864) + bitand(t.trigflag, 134217728),
           0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL'),
    case
      when t.analyzetime is null then null
      when ((m.inserts + m.deletes + m.updates) > t.rowcnt * 0.1 or
            bitand(m.flags,1) = 1) then 'YES'
      else  'NO' 
    end
  FROM
    sys.user$ u, sys.obj$ o, sys.tab$ t, sys.tab_stats$ ts, sys.mon_mods_all$ m
  WHERE
        o.owner# = u.user#
    and o.obj# = t.obj#
    and bitand(t.property, 1) = 0 /* not a typed table */ 
    and o.obj# = ts.obj# (+)
    and t.obj# = m.obj# (+)
    and o.subname IS NULL
    and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
    and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             FROM sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 FROM x$kzsro
                               )
            )
       or /* user has system privileges */
         exists (select null FROM v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
  UNION ALL
  SELECT /* PARTITIONS,  NOT IOT */
    u.name, o.name, o.subname, tp.part#, NULL, NULL, 'PARTITION', 
    tp.rowcnt, tp.blkcnt, tp.empcnt, tp.avgspc,
    tp.chncnt, tp.avgrln, TO_NUMBER(NULL), TO_NUMBER(NULL), 
    ts.cachedblk, ts.cachehit, tp.samplesize, tp.analyzetime,
    decode(bitand(tp.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(tp.flags, 8), 0, 'NO', 'YES'),
    decode(bitand(tab.trigflag, 67108864) + bitand(tab.trigflag, 134217728),
           0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL'),
    case
      when tp.analyzetime is null then null
      when ((m.inserts + m.deletes + m.updates) > tp.rowcnt * 0.1 or
            bitand(m.flags,1) = 1) then 'YES'
      else  'NO' 
    end
  FROM
    sys.user$ u, sys.obj$ o, sys.tabpartv$ tp, sys.tab_stats$ ts, sys.tab$ tab,
    sys.mon_mods_all$ m
  WHERE
        o.owner# = u.user#
    and o.obj# = tp.obj#
    and tp.bo# = tab.obj#
    and tp.file# > 0 
    and tp.block# > 0 
    and o.obj# = ts.obj# (+)
    and tp.obj# = m.obj# (+)
    and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
    and (o.owner# = userenv('SCHEMAID')
        or tp.bo# in
            (select oa.obj#
             FROM sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 FROM x$kzsro
                               ) 
            )
        or /* user has system privileges */
         exists (select null FROM v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
  UNION ALL
  SELECT /* IOT Partitions */
    u.name, o.name, o.subname, tp.part#, NULL, NULL, 'PARTITION', 
    tp.rowcnt, TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL),
    tp.chncnt, tp.avgrln, TO_NUMBER(NULL), TO_NUMBER(NULL), 
    TO_NUMBER(NULL), TO_NUMBER(NULL), tp.samplesize, tp.analyzetime, 
    decode(bitand(tp.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(tp.flags, 8), 0, 'NO', 'YES'),
    decode(bitand(tab.trigflag, 67108864) + bitand(tab.trigflag, 134217728),
           0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL'),
    case 
      when tp.analyzetime is null then null
      when ((m.inserts + m.deletes + m.updates) > tp.rowcnt * 0.1 or
            bitand(m.flags,1) = 1) then 'YES'
      else 'NO' 
    end
  FROM
    sys.user$ u, sys.obj$ o, sys.tabpartv$ tp, sys.tab$ tab, sys.mon_mods_all$ m
  WHERE
        o.owner# = u.user#
    and o.obj# = tp.obj#
    and tp.bo# = tab.obj#
    and tp.file# = 0
    and tp.block# = 0 
    and tp.obj# = m.obj# (+)
    and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
    and (o.owner# = userenv('SCHEMAID')
        or tp.bo# in
            (select oa.obj#
             FROM sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 FROM x$kzsro
                               ) 
            )
        or /* user has system privileges */
         exists (select null FROM v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
  UNION ALL
  SELECT /* COMPOSITE PARTITIONS */
    u.name, o.name, o.subname, tcp.part#, NULL, NULL, 'PARTITION', 
    tcp.rowcnt, tcp.blkcnt, tcp.empcnt, tcp.avgspc,
    tcp.chncnt, tcp.avgrln, NULL, NULL, ts.cachedblk, ts.cachehit,
    tcp.samplesize, tcp.analyzetime, 
    decode(bitand(tcp.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(tcp.flags, 8), 0, 'NO', 'YES'),
    decode(bitand(tab.trigflag, 67108864) + bitand(tab.trigflag, 134217728),
           0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL'),
    case 
      when tcp.analyzetime is null then null 
      when ((m.inserts + m.deletes + m.updates) > tcp.rowcnt * 0.1 or
            bitand(m.flags,1) = 1) then 'YES'
      else 'NO' 
    end
  FROM
    sys.user$ u, sys.obj$ o, sys.tabcompartv$ tcp, 
    sys.tab_stats$ ts, sys.tab$ tab, sys.mon_mods_all$ m
  WHERE
        o.owner# = u.user#
    and o.obj# = tcp.obj#
    and tcp.bo# = tab.obj#
    and o.obj# = ts.obj# (+)
    and tcp.obj# = m.obj# (+)
    and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
    and (o.owner# = userenv('SCHEMAID')
        or tcp.bo# in
            (select oa.obj#
             FROM sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 FROM x$kzsro
                               ) 
            )
        or /* user has system privileges */
         exists (select null FROM v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
  UNION ALL
  SELECT /* SUBPARTITIONS */
    u.name, po.name, po.subname, tcp.part#,  so.subname, tsp.subpart#,
   'SUBPARTITION', tsp.rowcnt,
    tsp.blkcnt, tsp.empcnt, tsp.avgspc,
    tsp.chncnt, tsp.avgrln, NULL, NULL,
    ts.cachedblk, ts.cachehit, tsp.samplesize, tsp.analyzetime,
    decode(bitand(tsp.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(tsp.flags, 8), 0, 'NO', 'YES'),
    decode(bitand(tab.trigflag, 67108864) + bitand(tab.trigflag, 134217728),
           0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL'),
    case 
      when tsp.analyzetime is null then null
      when ((m.inserts + m.deletes + m.updates) > tsp.rowcnt * 0.1 or
            bitand(m.flags,1) = 1) then 'YES'
      else  'NO' 
    end
  FROM
    sys.user$ u, sys.obj$ po, sys.obj$ so, sys.tabcompartv$ tcp, 
    sys.tabsubpartv$ tsp,  sys.tab_stats$ ts, sys.tab$ tab, sys.mon_mods_all$ m
  WHERE
        so.obj# = tsp.obj# 
    and po.obj# = tcp.obj# 
    and tcp.obj# = tsp.pobj#
    and tcp.bo# = tab.obj#
    and u.user# = po.owner# 
    and tsp.file# > 0
    and tsp.block# > 0 
    and so.obj# = ts.obj# (+)
    and tsp.obj# = m.obj# (+)
    and po.namespace = 1 and po.remoteowner IS NULL and po.linkname IS NULL
    and (po.owner# = userenv('SCHEMAID') 
         or tcp.bo# in
            (select oa.obj#
             FROM sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 FROM x$kzsro
                               ) 
            )
        or /* user has system privileges */
          exists (select null FROM v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */)
                 )
       )
  UNION ALL
  SELECT /* FIXED TABLES */
    'SYS', t.kqftanam, NULL, NULL, NULL, NULL, 'FIXED TABLE',
    decode(nvl(fobj.obj#, 0), 0, TO_NUMBER(NULL), st.rowcnt), 
    TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL), 
    decode(nvl(fobj.obj#, 0), 0, TO_NUMBER(NULL), st.avgrln), 
    TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL),
    decode(nvl(fobj.obj#, 0), 0, TO_NUMBER(NULL), st.samplesize), 
    decode(nvl(fobj.obj#, 0), 0, TO_DATE(NULL), st.analyzetime), 
    decode(nvl(fobj.obj#, 0), 0, NULL, 
           decode(nvl(st.obj#, 0), 0, NULL, 'YES')), 
    decode(nvl(fobj.obj#, 0), 0, NULL, 
           decode(nvl(st.obj#, 0), 0, NULL, 
                  decode(bitand(st.flags, 1), 0, 'NO', 'YES'))),
    decode(nvl(fobj.obj#, 0), 0, NULL, 
           decode (bitand(fobj.flags, 67108864) + 
                     bitand(fobj.flags, 134217728), 
                   0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL')),
    NULL 
    FROM sys.x$kqfta t, sys.fixed_obj$ fobj, sys.tab_stats$ st
    where
    t.kqftaobj = fobj.obj#(+) 
    /* 
     * if fobj and st are not in sync (happens when db open read only
     * after upgrade), do not display stats.
     */
    and t.kqftaver = fobj.timestamp (+) - to_date('01-01-1991', 'DD-MM-YYYY')
    and t.kqftaobj = st.obj#(+)
    and (userenv('SCHEMAID') = 0  /* SYS */
         or /* user has system privileges */
         exists (select null FROM v$enabledprivs
                 where priv_number in (-237 /* SELECT ANY DICTIONARY */)
                 )
        )
/
create or replace public synonym ALL_TAB_STATISTICS for ALL_TAB_STATISTICS
/
grant select on ALL_TAB_STATISTICS to PUBLIC with grant option
/
comment on table ALL_TAB_STATISTICS is
'Optimizer statistics for all tables accessible to the user'
/
comment on column ALL_TAB_STATISTICS.OWNER is
'Owner of the object'
/
comment on column ALL_TAB_STATISTICS.TABLE_NAME is
'Name of the table'
/  
comment on column ALL_TAB_STATISTICS.PARTITION_NAME is
'Name of the partition'
/  
comment on column ALL_TAB_STATISTICS.PARTITION_POSITION is
'Position of the partition within table'
/  
comment on column ALL_TAB_STATISTICS.SUBPARTITION_NAME is
'Name of the subpartition'
/  
comment on column ALL_TAB_STATISTICS.SUBPARTITION_POSITION is
'Position of the subpartition within partition'
/  
comment on column ALL_TAB_STATISTICS.OBJECT_TYPE is
'Type of the object (TABLE, PARTITION, SUBPARTITION)'
/  
comment on column ALL_TAB_STATISTICS.NUM_ROWS is
'The number of rows in the object'
/
comment on column ALL_TAB_STATISTICS.BLOCKS is
'The number of used blocks in the object'
/
comment on column ALL_TAB_STATISTICS.EMPTY_BLOCKS is
'The number of empty blocks in the object'
/
comment on column ALL_TAB_STATISTICS.AVG_SPACE is
'The average available free space in the object'
/
comment on column ALL_TAB_STATISTICS.CHAIN_CNT is
'The number of chained rows in the object'
/
comment on column ALL_TAB_STATISTICS.AVG_ROW_LEN is
'The average row length, including row overhead'
/
comment on column ALL_TAB_STATISTICS.AVG_SPACE_FREELIST_BLOCKS is
'The average freespace of all blocks on a freelist'
/
comment on column ALL_TAB_STATISTICS.NUM_FREELIST_BLOCKS is
'The number of blocks on the freelist'
/
comment on column ALL_TAB_STATISTICS.AVG_CACHED_BLOCKS is
'Average number of blocks in buffer cache'
/
comment on column ALL_TAB_STATISTICS.AVG_CACHE_HIT_RATIO is
'Average cache hit ratio for the object'
/
comment on column ALL_TAB_STATISTICS.SAMPLE_SIZE is
'The sample size used in analyzing this table'
/
comment on column ALL_TAB_STATISTICS.LAST_ANALYZED is
'The date of the most recent time this table was analyzed'
/
comment on column ALL_TAB_STATISTICS.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column ALL_TAB_STATISTICS.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column ALL_TAB_STATISTICS.STATTYPE_LOCKED is
'type of statistics lock'
/
comment on column ALL_TAB_STATISTICS.STALE_STATS is
'Whether statistics for the object is stale or not'
/

CREATE OR REPLACE VIEW DBA_TAB_STATISTICS
 (
  owner,
  table_name,
  partition_name,
  partition_position,
  subpartition_name,
  subpartition_position,
  object_type,
  num_rows,
  blocks,
  empty_blocks,
  avg_space,
  chain_cnt,
  avg_row_len,
  avg_space_freelist_blocks,
  num_freelist_blocks,
  avg_cached_blocks,
  avg_cache_hit_ratio,
  sample_size,
  last_analyzed,
  global_stats, 
  user_stats,
  stattype_locked,
  stale_stats
  )
  AS
  SELECT /* TABLES */
    u.name, o.name, NULL, NULL, NULL, NULL, 'TABLE', t.rowcnt,
    decode(bitand(t.property, 64), 0, t.blkcnt, TO_NUMBER(NULL)), 
    decode(bitand(t.property, 64), 0, t.empcnt, TO_NUMBER(NULL)), 
    decode(bitand(t.property, 64), 0, t.avgspc, TO_NUMBER(NULL)),
    t.chncnt, t.avgrln, t.avgspc_flb,
    decode(bitand(t.property, 64), 0, t.flbcnt, TO_NUMBER(NULL)), 
    ts.cachedblk, ts.cachehit, t.samplesize, t.analyzetime,
    decode(bitand(t.flags, 512), 0, 'NO', 'YES'),
    decode(bitand(t.flags, 256), 0, 'NO', 'YES'),
    decode(bitand(t.trigflag, 67108864) + bitand(t.trigflag, 134217728),
           0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL'),
    case
      when t.analyzetime is null then null
      when ((m.inserts + m.deletes + m.updates) > t.rowcnt * 0.1 or
            bitand(m.flags,1) = 1) then 'YES'
      else  'NO' 
    end
  FROM
    sys.user$ u, sys.obj$ o, sys.tab$ t, sys.tab_stats$ ts, sys.mon_mods_all$ m
  WHERE
        o.owner# = u.user#
    and o.obj# = t.obj#
    and bitand(t.property, 1) = 0 /* not a typed table */ 
    and o.obj# = ts.obj# (+)
    and t.obj# = m.obj# (+)
    and o.subname IS NULL
    and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  UNION ALL
  SELECT /* PARTITIONS,  NOT IOT */
    u.name, o.name, o.subname, tp.part#, NULL, NULL, 'PARTITION', 
    tp.rowcnt, tp.blkcnt, tp.empcnt, tp.avgspc,
    tp.chncnt, tp.avgrln, TO_NUMBER(NULL), TO_NUMBER(NULL), 
    ts.cachedblk, ts.cachehit, tp.samplesize, tp.analyzetime,
    decode(bitand(tp.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(tp.flags, 8), 0, 'NO', 'YES'),
    decode(bitand(tab.trigflag, 67108864) + bitand(tab.trigflag, 134217728),
           0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL'),
    case
      when tp.analyzetime is null then null
      when ((m.inserts + m.deletes + m.updates) > tp.rowcnt * 0.1 or
            bitand(m.flags,1) = 1) then 'YES'
      else  'NO' 
    end
  FROM
    sys.user$ u, sys.obj$ o, sys.tabpartv$ tp, sys.tab_stats$ ts, sys.tab$ tab,
    sys.mon_mods_all$ m
  WHERE
        o.owner# = u.user#
    and o.obj# = tp.obj#
    and tp.bo# = tab.obj#
    and tp.file# > 0 
    and tp.block# > 0 
    and o.obj# = ts.obj# (+)
    and tp.obj# = m.obj# (+)
    and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  UNION ALL
  SELECT /* IOT Partitions */
    u.name, o.name, o.subname, tp.part#, NULL, NULL, 'PARTITION', 
    tp.rowcnt, TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL),
    tp.chncnt, tp.avgrln, TO_NUMBER(NULL), TO_NUMBER(NULL), 
    TO_NUMBER(NULL), TO_NUMBER(NULL), tp.samplesize, tp.analyzetime, 
    decode(bitand(tp.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(tp.flags, 8), 0, 'NO', 'YES'),
    decode(bitand(tab.trigflag, 67108864) + bitand(tab.trigflag, 134217728),
           0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL'),
    case 
      when tp.analyzetime is null then null
      when ((m.inserts + m.deletes + m.updates) > tp.rowcnt * 0.1 or
            bitand(m.flags,1) = 1) then 'YES'
      else 'NO' 
    end
  FROM
    sys.user$ u, sys.obj$ o, sys.tabpartv$ tp, sys.tab$ tab, sys.mon_mods_all$ m
  WHERE
        o.owner# = u.user#
    and o.obj# = tp.obj#
    and tp.bo# = tab.obj#
    and tp.obj# = m.obj# (+)
    and tp.file# = 0
    and tp.block# = 0 
    and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  UNION ALL
  SELECT /* COMPOSITE PARTITIONS */
    u.name, o.name, o.subname, tcp.part#, NULL, NULL, 'PARTITION', 
    tcp.rowcnt, tcp.blkcnt, tcp.empcnt, tcp.avgspc,
    tcp.chncnt, tcp.avgrln, NULL, NULL, ts.cachedblk, ts.cachehit,
    tcp.samplesize, tcp.analyzetime, 
    decode(bitand(tcp.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(tcp.flags, 8), 0, 'NO', 'YES'),
    decode(bitand(tab.trigflag, 67108864) + bitand(tab.trigflag, 134217728),
           0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL'),
    case 
      when tcp.analyzetime is null then null 
      when ((m.inserts + m.deletes + m.updates) > tcp.rowcnt * 0.1 or
            bitand(m.flags,1) = 1) then 'YES'
      else 'NO' 
    end
  FROM
    sys.user$ u, sys.obj$ o, sys.tabcompartv$ tcp, 
    sys.tab_stats$ ts, sys.tab$ tab, sys.mon_mods_all$ m
  WHERE
        o.owner# = u.user#
    and o.obj# = tcp.obj#
    and tcp.bo# = tab.obj#
    and o.obj# = ts.obj# (+)
    and tcp.obj# = m.obj# (+)
    and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  UNION ALL
  SELECT /* SUBPARTITIONS */
    u.name, po.name, po.subname, tcp.part#,  so.subname, tsp.subpart#,
   'SUBPARTITION', tsp.rowcnt,
    tsp.blkcnt, tsp.empcnt, tsp.avgspc,
    tsp.chncnt, tsp.avgrln, NULL, NULL,
    ts.cachedblk, ts.cachehit, tsp.samplesize, tsp.analyzetime,
    decode(bitand(tsp.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(tsp.flags, 8), 0, 'NO', 'YES'),
    decode(bitand(tab.trigflag, 67108864) + bitand(tab.trigflag, 134217728),
           0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL'),
    case 
      when tsp.analyzetime is null then null
      when ((m.inserts + m.deletes + m.updates) > tsp.rowcnt * 0.1 or
            bitand(m.flags,1) = 1) then 'YES'
      else  'NO' 
    end
  FROM
    sys.user$ u, sys.obj$ po, sys.obj$ so, sys.tabcompartv$ tcp, 
    sys.tabsubpartv$ tsp,  sys.tab_stats$ ts, sys.tab$ tab, sys.mon_mods_all$ m
  WHERE
        so.obj# = tsp.obj# 
    and po.obj# = tcp.obj# 
    and tcp.obj# = tsp.pobj#
    and tcp.bo# = tab.obj#
    and u.user# = po.owner# 
    and tsp.file# > 0
    and tsp.block# > 0 
    and so.obj# = ts.obj# (+)
    and tsp.obj# = m.obj# (+)
    and po.namespace = 1 and po.remoteowner IS NULL and po.linkname IS NULL
  UNION ALL
  SELECT /* FIXED TABLES */
    'SYS', t.kqftanam, NULL, NULL, NULL, NULL, 'FIXED TABLE',
    decode(nvl(fobj.obj#, 0), 0, TO_NUMBER(NULL), st.rowcnt), 
    TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL), 
    decode(nvl(fobj.obj#, 0), 0, TO_NUMBER(NULL), st.avgrln), 
    TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL),
    decode(nvl(fobj.obj#, 0), 0, TO_NUMBER(NULL), st.samplesize), 
    decode(nvl(fobj.obj#, 0), 0, TO_DATE(NULL), st.analyzetime), 
    decode(nvl(fobj.obj#, 0), 0, NULL, 
           decode(nvl(st.obj#, 0), 0, NULL, 'YES')), 
    decode(nvl(fobj.obj#, 0), 0, NULL, 
           decode(nvl(st.obj#, 0), 0, NULL, 
                  decode(bitand(st.flags, 1), 0, 'NO', 'YES'))),
    decode(nvl(fobj.obj#, 0), 0, NULL, 
           decode (bitand(fobj.flags, 67108864) + 
                     bitand(fobj.flags, 134217728), 
                   0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL')),
    NULL
    FROM sys.x$kqfta t, sys.fixed_obj$ fobj, sys.tab_stats$ st
    where
    t.kqftaobj = fobj.obj#(+) 
    /* 
     * if fobj and st are not in sync (happens when db open read only
     * after upgrade), do not display stats.
     */
    and t.kqftaver = fobj.timestamp (+) - to_date('01-01-1991', 'DD-MM-YYYY')
    and t.kqftaobj = st.obj#(+)
/
create or replace public synonym DBA_TAB_STATISTICS for DBA_TAB_STATISTICS
/
grant select on DBA_TAB_STATISTICS to select_catalog_role
/
comment on table DBA_TAB_STATISTICS is
'Optimizer statistics for all tables in the database'
/
comment on column DBA_TAB_STATISTICS.OWNER is
'Owner of the object'
/
comment on column DBA_TAB_STATISTICS.TABLE_NAME is
'Name of the table'
/  
comment on column DBA_TAB_STATISTICS.PARTITION_NAME is
'Name of the partition'
/  
comment on column DBA_TAB_STATISTICS.PARTITION_POSITION is
'Position of the partition within table'
/  
comment on column DBA_TAB_STATISTICS.SUBPARTITION_NAME is
'Name of the subpartition'
/  
comment on column DBA_TAB_STATISTICS.SUBPARTITION_POSITION is
'Position of the subpartition within partition'
/  
comment on column DBA_TAB_STATISTICS.OBJECT_TYPE is
'Type of the object (TABLE, PARTITION, SUBPARTITION)'
/  
comment on column DBA_TAB_STATISTICS.NUM_ROWS is
'The number of rows in the object'
/
comment on column DBA_TAB_STATISTICS.BLOCKS is
'The number of used blocks in the object'
/
comment on column DBA_TAB_STATISTICS.EMPTY_BLOCKS is
'The number of empty blocks in the object'
/
comment on column DBA_TAB_STATISTICS.AVG_SPACE is
'The average available free space in the object'
/
comment on column DBA_TAB_STATISTICS.CHAIN_CNT is
'The number of chained rows in the object'
/
comment on column DBA_TAB_STATISTICS.AVG_ROW_LEN is
'The average row length, including row overhead'
/
comment on column DBA_TAB_STATISTICS.AVG_SPACE_FREELIST_BLOCKS is
'The average freespace of all blocks on a freelist'
/
comment on column DBA_TAB_STATISTICS.NUM_FREELIST_BLOCKS is
'The number of blocks on the freelist'
/
comment on column DBA_TAB_STATISTICS.AVG_CACHED_BLOCKS is
'Average number of blocks in buffer cache'
/
comment on column DBA_TAB_STATISTICS.AVG_CACHE_HIT_RATIO is
'Average cache hit ratio for the object'
/
comment on column DBA_TAB_STATISTICS.SAMPLE_SIZE is
'The sample size used in analyzing this table'
/
comment on column DBA_TAB_STATISTICS.LAST_ANALYZED is
'The date of the most recent time this table was analyzed'
/
comment on column DBA_TAB_STATISTICS.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column DBA_TAB_STATISTICS.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column DBA_TAB_STATISTICS.STATTYPE_LOCKED is
'type of statistics lock'
/
comment on column DBA_TAB_STATISTICS.STALE_STATS is
'Whether statistics for the object is stale or not'
/


CREATE OR REPLACE VIEW USER_TAB_STATISTICS
 (
  table_name,
  partition_name,
  partition_position,
  subpartition_name,
  subpartition_position,
  object_type,
  num_rows,
  blocks,
  empty_blocks,
  avg_space,
  chain_cnt,
  avg_row_len,
  avg_space_freelist_blocks,
  num_freelist_blocks,
  avg_cached_blocks,
  avg_cache_hit_ratio,
  sample_size,
  last_analyzed,
  global_stats, 
  user_stats,
  stattype_locked,
  stale_stats
  )
  AS
  SELECT /* TABLES */
    o.name, NULL, NULL, NULL, NULL, 'TABLE', t.rowcnt,
    decode(bitand(t.property, 64), 0, t.blkcnt, TO_NUMBER(NULL)), 
    decode(bitand(t.property, 64), 0, t.empcnt, TO_NUMBER(NULL)), 
    decode(bitand(t.property, 64), 0, t.avgspc, TO_NUMBER(NULL)),
    t.chncnt, t.avgrln, t.avgspc_flb,
    decode(bitand(t.property, 64), 0, t.flbcnt, TO_NUMBER(NULL)), 
    ts.cachedblk, ts.cachehit, t.samplesize, t.analyzetime,
    decode(bitand(t.flags, 512), 0, 'NO', 'YES'),
    decode(bitand(t.flags, 256), 0, 'NO', 'YES'),
    decode(bitand(t.trigflag, 67108864) + bitand(t.trigflag, 134217728),
           0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL'),
    case
      when t.analyzetime is null then null
      when ((m.inserts + m.deletes + m.updates) > t.rowcnt * 0.1 or
            bitand(m.flags,1) = 1) then 'YES'
      else  'NO' 
    end
  FROM
    sys.obj$ o, sys.tab$ t, sys.tab_stats$ ts, sys.mon_mods_all$ m
  WHERE
        o.obj# = t.obj#
    and bitand(t.property, 1) = 0 /* not a typed table */ 
    and o.obj# = ts.obj# (+)
    and t.obj# = m.obj# (+)
    and o.owner# = userenv('SCHEMAID') and o.subname IS NULL
    and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  UNION ALL
  SELECT /* PARTITIONS,  NOT IOT */
    o.name, o.subname, tp.part#, NULL, NULL, 'PARTITION', 
    tp.rowcnt, tp.blkcnt, tp.empcnt, tp.avgspc,
    tp.chncnt, tp.avgrln, TO_NUMBER(NULL), TO_NUMBER(NULL), 
    ts.cachedblk, ts.cachehit, tp.samplesize, tp.analyzetime,
    decode(bitand(tp.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(tp.flags, 8), 0, 'NO', 'YES'),
    decode(bitand(tab.trigflag, 67108864) + bitand(tab.trigflag, 134217728),
           0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL'),
    case
      when tp.analyzetime is null then null
      when ((m.inserts + m.deletes + m.updates) > tp.rowcnt * 0.1 or
            bitand(m.flags,1) = 1) then 'YES'
      else  'NO' 
    end
  FROM
    sys.obj$ o, sys.tabpartv$ tp, sys.tab_stats$ ts, sys.tab$ tab, 
    sys.mon_mods_all$ m
  WHERE
        o.obj# = tp.obj#
    and tp.bo# = tab.obj#
    and tp.file# > 0
    and tp.block# > 0
    and o.obj# = ts.obj# (+)
    and tp.obj# = m.obj# (+)
    and o.owner# = userenv('SCHEMAID') 
    and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  UNION ALL
  SELECT /* IOT Partitions */
    o.name, o.subname, tp.part#, NULL, NULL, 'PARTITION', 
    tp.rowcnt, TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL),
    tp.chncnt, tp.avgrln, TO_NUMBER(NULL), TO_NUMBER(NULL), 
    TO_NUMBER(NULL), TO_NUMBER(NULL), tp.samplesize, tp.analyzetime, 
    decode(bitand(tp.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(tp.flags, 8), 0, 'NO', 'YES'),
    decode(bitand(tab.trigflag, 67108864) + bitand(tab.trigflag, 134217728),
           0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL'),
    case 
      when tp.analyzetime is null then null
      when ((m.inserts + m.deletes + m.updates) > tp.rowcnt * 0.1 or
            bitand(m.flags,1) = 1) then 'YES'
      else 'NO' 
    end
  FROM
    sys.obj$ o, sys.tabpartv$ tp, sys.tab$ tab, sys.mon_mods_all$ m
  WHERE
        o.obj# = tp.obj#
    and tp.bo# = tab.obj#
    and tp.file# = 0
    and tp.block# = 0 
    and tp.obj# = m.obj# (+)
    and o.owner# = userenv('SCHEMAID') 
    and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  UNION ALL
  SELECT /* COMPOSITE PARTITIONS */
    o.name, o.subname, tcp.part#, NULL, NULL, 'PARTITION', 
    tcp.rowcnt, tcp.blkcnt, tcp.empcnt, tcp.avgspc,
    tcp.chncnt, tcp.avgrln, NULL, NULL, ts.cachedblk, ts.cachehit,
    tcp.samplesize, tcp.analyzetime, 
    decode(bitand(tcp.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(tcp.flags, 8), 0, 'NO', 'YES'),
    decode(bitand(tab.trigflag, 67108864) + bitand(tab.trigflag, 134217728),
           0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL'),
    case 
      when tcp.analyzetime is null then null 
      when ((m.inserts + m.deletes + m.updates) > tcp.rowcnt * 0.1 or
            bitand(m.flags,1) = 1) then 'YES'
      else 'NO' 
    end
  FROM
    sys.obj$ o, sys.tabcompartv$ tcp, sys.tab_stats$ ts, sys.tab$ tab,
    sys.mon_mods_all$ m
  WHERE
        o.obj# = tcp.obj#
    and tcp.bo# = tab.obj#
    and o.obj# = ts.obj# (+)
    and tcp.obj# = m.obj# (+)
    and o.owner# = userenv('SCHEMAID') 
    and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  UNION ALL
  SELECT /* SUBPARTITIONS */
    po.name, po.subname, tcp.part#,  so.subname, tsp.subpart#,
   'SUBPARTITION', tsp.rowcnt,
    tsp.blkcnt, tsp.empcnt, tsp.avgspc,
    tsp.chncnt, tsp.avgrln, NULL, NULL,
    ts.cachedblk, ts.cachehit, tsp.samplesize, tsp.analyzetime,
    decode(bitand(tsp.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(tsp.flags, 8), 0, 'NO', 'YES'),
    decode(bitand(tab.trigflag, 67108864) + bitand(tab.trigflag, 134217728),
           0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL'),
    case 
      when tsp.analyzetime is null then null
      when ((m.inserts + m.deletes + m.updates) > tsp.rowcnt * 0.1 or
            bitand(m.flags,1) = 1) then 'YES'
      else  'NO' 
    end
  FROM
    sys.obj$ po, sys.obj$ so, sys.tabcompartv$ tcp, sys.tabsubpartv$ tsp,
    sys.tab_stats$ ts, sys.tab$ tab, sys.mon_mods_all$ m
  WHERE
        so.obj# = tsp.obj# 
    and po.obj# = tcp.obj# 
    and tcp.obj# = tsp.pobj#
    and tcp.bo# = tab.obj#
    and tsp.file# > 0
    and tsp.block# > 0
    and so.obj# = ts.obj# (+)
    and tsp.obj# = m.obj# (+)
    and po.owner# = userenv('SCHEMAID') 
    and po.namespace = 1 and po.remoteowner IS NULL and po.linkname IS NULL
  UNION ALL
  SELECT /* FIXED TABLES */
    t.kqftanam, NULL, NULL, NULL, NULL, 'FIXED TABLE',
    decode(nvl(fobj.obj#, 0), 0, TO_NUMBER(NULL), st.rowcnt), 
    TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL), 
    decode(nvl(fobj.obj#, 0), 0, TO_NUMBER(NULL), st.avgrln), 
    TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL),
    decode(nvl(fobj.obj#, 0), 0, TO_NUMBER(NULL), st.samplesize), 
    decode(nvl(fobj.obj#, 0), 0, TO_DATE(NULL), st.analyzetime), 
    decode(nvl(fobj.obj#, 0), 0, NULL, 
           decode(nvl(st.obj#, 0), 0, NULL, 'YES')), 
    decode(nvl(fobj.obj#, 0), 0, NULL, 
           decode(nvl(st.obj#, 0), 0, NULL, 
                  decode(bitand(st.flags, 1), 0, 'NO', 'YES'))),
    decode(nvl(fobj.obj#, 0), 0, NULL, 
           decode (bitand(fobj.flags, 67108864) + 
                     bitand(fobj.flags, 134217728), 
                   0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL')),
    NULL
    FROM sys.x$kqfta t, sys.fixed_obj$ fobj, sys.tab_stats$ st
    where
    t.kqftaobj = fobj.obj#(+) 
    /* 
     * if fobj and st are not in sync (happens when db open read only
     * after upgrade), do not display stats.
     */
    and t.kqftaver = fobj.timestamp (+) - to_date('01-01-1991', 'DD-MM-YYYY')
    and t.kqftaobj = st.obj#(+)
    and userenv('SCHEMAID') = 0  /* SYS */
/
create or replace public synonym USER_TAB_STATISTICS for USER_TAB_STATISTICS
/
grant select on USER_TAB_STATISTICS to PUBLIC with grant option
/
comment on table USER_TAB_STATISTICS is
'Optimizer statistics of the user''s own tables'
/
comment on column USER_TAB_STATISTICS.TABLE_NAME is
'Name of the table'
/  
comment on column USER_TAB_STATISTICS.PARTITION_NAME is
'Name of the partition'
/  
comment on column USER_TAB_STATISTICS.PARTITION_POSITION is
'Position of the partition within table'
/  
comment on column USER_TAB_STATISTICS.SUBPARTITION_NAME is
'Name of the subpartition'
/  
comment on column USER_TAB_STATISTICS.SUBPARTITION_POSITION is
'Position of the subpartition within partition'
/  
comment on column USER_TAB_STATISTICS.OBJECT_TYPE is
'Type of the object (TABLE, PARTITION, SUBPARTITION)'
/  
comment on column USER_TAB_STATISTICS.NUM_ROWS is
'The number of rows in the object'
/
comment on column USER_TAB_STATISTICS.BLOCKS is
'The number of used blocks in the object'
/
comment on column USER_TAB_STATISTICS.EMPTY_BLOCKS is
'The number of empty blocks in the object'
/
comment on column USER_TAB_STATISTICS.AVG_SPACE is
'The average available free space in the object'
/
comment on column USER_TAB_STATISTICS.CHAIN_CNT is
'The number of chained rows in the object'
/
comment on column USER_TAB_STATISTICS.AVG_ROW_LEN is
'The average row length, including row overhead'
/
comment on column USER_TAB_STATISTICS.AVG_SPACE_FREELIST_BLOCKS is
'The average freespace of all blocks on a freelist'
/
comment on column USER_TAB_STATISTICS.NUM_FREELIST_BLOCKS is
'The number of blocks on the freelist'
/
comment on column USER_TAB_STATISTICS.AVG_CACHED_BLOCKS is
'Average number of blocks in buffer cache'
/
comment on column USER_TAB_STATISTICS.AVG_CACHE_HIT_RATIO is
'Average cache hit ratio for the object'
/
comment on column USER_TAB_STATISTICS.SAMPLE_SIZE is
'The sample size used in analyzing this table'
/
comment on column USER_TAB_STATISTICS.LAST_ANALYZED is
'The date of the most recent time this table was analyzed'
/
comment on column USER_TAB_STATISTICS.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column USER_TAB_STATISTICS.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column USER_TAB_STATISTICS.STATTYPE_LOCKED is
'type of statistics lock'
/
comment on column USER_TAB_STATISTICS.STALE_STATS is
'Whether statistics for the object is stale or not'
/

/*
 * *_IND_STATISTICS views can be used to display  statistics for
 * index/index partitions.
 * The view has the following union all branches
 *   - indexes (types 1, 2, 4, 6, 7, 8)
 *   - cluster indexes (staleness, stattype_locked is different from above)
 *   - partitions
 *   - composite partitions
 *   - subpartitions
 *
 * We don't display domain indexes since it is not available in dictionary 
 * tables (ind$, indpart$ ...). So type 9 is excluded.
 *
 * index types:
 *    normal : 1
 *    bitmap : 2
 *    cluster: 3
 *    iot - top : 4
 *    iot - nested : 5
 *    secondary : 6
 *    ansi : 7
 *    lob : 8
 *    cooperative index method (domain indexes) : 9
 * stale_stats column values
 *   null => if index/table (partition) is not analyzed 
 *   YES  => if global index
 *             if corresponding table is stale OR
 *                the index is analyzed before table 
 *           if local_index
 *             if corresponding table partition is stale OR
 *                the index partition is analyzed before table partition
 *           if cluster index
 *             if one of the tables in cluster is stale
 *   NO   => otherwise
 */
create or replace view ALL_IND_STATISTICS
  (
  OWNER, INDEX_NAME, TABLE_OWNER, TABLE_NAME,
  PARTITION_NAME, PARTITION_POSITION,
  SUBPARTITION_NAME, SUBPARTITION_POSITION, OBJECT_TYPE,
  BLEVEL, LEAF_BLOCKS, 
  DISTINCT_KEYS, AVG_LEAF_BLOCKS_PER_KEY, AVG_DATA_BLOCKS_PER_KEY,
  CLUSTERING_FACTOR, NUM_ROWS, 
  AVG_CACHED_BLOCKS, AVG_CACHE_HIT_RATIO,
  SAMPLE_SIZE, LAST_ANALYZED, GLOBAL_STATS, USER_STATS,
  STATTYPE_LOCKED, STALE_STATS
  )
  AS
  SELECT
    u.name, o.name, ut.name, ot.name,
    NULL,NULL, NULL, NULL, 'INDEX',
    i.blevel, i.leafcnt, i.distkey, i.lblkkey, i.dblkkey, i.clufac, i.rowcnt,
    ins.cachedblk, ins.cachehit, i.samplesize, i.analyzetime,
    decode(bitand(i.flags, 2048), 0, 'NO', 'YES'),
    decode(bitand(i.flags, 64), 0, 'NO', 'YES'),
    decode(bitand(t.trigflag, 67108864) + bitand(t.trigflag, 134217728),
           0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL'),
    case when
           (i.analyzetime is null or 
            t.analyzetime is null) then null
         when (i.analyzetime < t.analyzetime or
               (((m.inserts + m.deletes + m.updates) > t.rowcnt * 0.1 or
                bitand(m.flags,1) = 1))) then 'YES'
         else  'NO' 
    end
  FROM
    sys.user$ u, sys.ind$ i, sys.obj$ o, sys.ind_stats$ ins,
    sys.obj$ ot, sys.user$ ut, sys.tab$ t, sys.mon_mods_all$ m
  WHERE
      u.user# = o.owner#
  and o.obj# = i.obj#
  and bitand(i.flags, 4096) = 0
  and i.type# in (1, 2, 4, 6, 7, 8)
  and i.obj# = ins.obj# (+)
  and i.bo# = ot.obj# 
  and ot.type# = 2
  and ot.owner# = ut.user#
  and ot.obj# = t.obj#
  and t.obj# = m.obj# (+)
  and o.subname IS NULL
  and o.namespace = 4 and o.remoteowner IS NULL and o.linkname IS NULL
  and (o.owner# = userenv('SCHEMAID')
        or
       o.obj# in ( select obj#
                    FROM sys.objauth$
                    where grantee# in ( select kzsrorol
                                        FROM x$kzsro
                                      )
                   )
        or
         exists (select null FROM v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
       )
  UNION ALL
  SELECT
    u.name, o.name, ut.name, ot.name,
    NULL,NULL, NULL, NULL, 'INDEX',
    i.blevel, i.leafcnt, i.distkey, i.lblkkey, i.dblkkey, i.clufac, i.rowcnt,
    ins.cachedblk, ins.cachehit, i.samplesize, i.analyzetime,
    decode(bitand(i.flags, 2048), 0, 'NO', 'YES'),
    decode(bitand(i.flags, 64), 0, 'NO', 'YES'),
    -- a cluster index is considered locked if any of the table in
    -- the cluster is locked.
    decode((select
           decode(nvl(sum(decode(bitand(t.trigflag, 67108864), 0, 0, 1)),0),
                  0, 0, 67108864) +
           decode(nvl(sum(decode(bitand(nvl(t.trigflag, 0), 134217728), 
                                 0, 0, 1)), 0),
                  0, 0, 134217728) 
           from  sys.tab$ t where i.bo# = t.bobj#),
           0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL'),
    case 
         when i.analyzetime is null then null
         when
           (select                                 -- STALE
              sum(case when
                      i.analyzetime < tab.analyzetime or
                      bitand(m.flags,1) = 1 or
                      m.inserts + m.updates + m.deletes > (.1 * tab.rowcnt)
                  then 1 else 0 end)
            from sys.tab$ tab, mon_mods_all$ m
            where
              m.obj#(+) = tab.obj# and tab.bobj# = i.bo#) > 0 then 'YES'
         else 'NO' end
  FROM
    sys.user$ u, sys.ind$ i, sys.obj$ o, sys.ind_stats$ ins,
    sys.obj$ ot, sys.user$ ut
  WHERE
      u.user# = o.owner#
  and o.obj# = i.obj#
  and bitand(i.flags, 4096) = 0
  and i.type# = 3 /* Cluster index */
  and i.obj# = ins.obj# (+)
  and i.bo# = ot.obj# 
  and ot.owner# = ut.user#
  and o.subname IS NULL
  and o.namespace = 4 and o.remoteowner IS NULL and o.linkname IS NULL
  and (o.owner# = userenv('SCHEMAID')
        or
       o.obj# in ( select obj#
                    FROM sys.objauth$
                    where grantee# in ( select kzsrorol
                                        FROM x$kzsro
                                      )
                   )
        or
         exists (select null FROM v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
       )
  UNION ALL
  SELECT 
    u.name, io.name, ut.name, ot.name,
    io.subname, ip.part#, NULL, NULL, 'PARTITION',
    ip.blevel, ip.leafcnt, ip.distkey, ip.lblkkey, ip.dblkkey, 
    ip.clufac, ip.rowcnt, ins.cachedblk, ins.cachehit,
    ip.samplesize, ip.analyzetime,
    decode(bitand(ip.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(ip.flags, 8), 0, 'NO', 'YES'),
    decode(bitand(t.trigflag, 67108864) + bitand(t.trigflag, 134217728),
           0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL'),
    (select 
       case     when (i.analyzetime is null or
                      tab.analyzetime is null) then null
                when (i.analyzetime < tab.analyzetime  or
                      ((m.inserts + m.deletes + m.updates) > tab.rowcnt * 0.1 or
                       bitand(m.flags,1) = 1)) then 'YES'
                else 'NO'
       end
       FROM sys.tab$ tab, sys.mon_mods_all$ m 
       where tab.obj# = i.bo# and tab.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 0   -- not local index
     union all
     select
       case     when (i.analyzetime is null or
                      tp.analyzetime is null) then null
                when (i.analyzetime < tp.analyzetime  or
                      ((m.inserts + m.deletes + m.updates) > tp.rowcnt * 0.1 or
                       bitand(m.flags,1) = 1)) then 'YES'
                else 'NO'
       end
       FROM sys.tabpartv$ tp, sys.mon_mods_all$ m 
       where tp.bo# = i.bo# and tp.phypart# = ip.phypart# and
             tp.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 1)  -- local index
  FROM 
    sys.obj$ io, sys.indpartv$ ip, 
    sys.user$ u, sys.ind_stats$ ins,
    sys.ind$ i, sys.obj$ ot, sys.user$ ut, sys.partobj$ po, sys.tab$ t
  WHERE
      io.obj# = ip.obj# 
  and ip.bo# = i.obj# 
  and io.owner# = u.user#
  and ip.obj# = ins.obj# (+)
  and ip.bo# = i.obj#
  and i.type# != 9  --  no domain indexes
  and i.bo# = ot.obj#
  and ot.type# = 2
  and ot.owner# = ut.user#
  and i.obj# = po.obj#
  and ot.obj# = t.obj#
  and io.namespace = 4 and io.remoteowner IS NULL and io.linkname IS NULL
  and (io.owner# = userenv('SCHEMAID') 
        or
        i.bo# in (select obj#
                    FROM sys.objauth$
                    where grantee# in ( select kzsrorol
                                        FROM x$kzsro
                                      )
                   )
        or
         exists (select null FROM v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
       )
  UNION ALL
  SELECT 
    u.name, io.name, ut.name, ot.name,
    io.subname, icp.part#, NULL, NULL, 'PARTITION',
    icp.blevel, icp.leafcnt, icp.distkey, icp.lblkkey, icp.dblkkey, 
    icp.clufac, icp.rowcnt, ins.cachedblk, ins.cachehit,
    icp.samplesize, icp.analyzetime,
    decode(bitand(icp.flags, 16), 0, 'NO', 'YES'), 
    decode(bitand(icp.flags, 8), 0, 'NO', 'YES'),
    decode(bitand(t.trigflag, 67108864) + bitand(t.trigflag, 134217728),
           0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL'),
    (select 
       case     when (i.analyzetime is null or
                      tab.analyzetime is null) then null
                when (i.analyzetime < tab.analyzetime  or
                      ((m.inserts + m.deletes + m.updates) > tab.rowcnt * 0.1 or
                       bitand(m.flags,1) = 1)) then 'YES'
                else 'NO'
       end
       FROM sys.tab$ tab, sys.mon_mods_all$ m 
       where tab.obj# = i.bo# and tab.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 0   -- not local index
     union all
     select
       case     when (i.analyzetime is null or
                      tcp.analyzetime is null) then null
                when (i.analyzetime < tcp.analyzetime  or
                      ((m.inserts + m.deletes + m.updates) > tcp.rowcnt * 0.1 or
                       bitand(m.flags,1) = 1)) then 'YES'
                else 'NO'
       end
       FROM sys.tabcompartv$ tcp, sys.mon_mods_all$ m 
       where tcp.bo# = i.bo# and tcp.phypart# = icp.phypart# and
             tcp.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 1)  -- local index
  FROM
    sys.obj$ io, sys.indcompartv$ icp, sys.user$ u, sys.ind_stats$ ins,
    sys.ind$ i, sys.obj$ ot, sys.user$ ut, sys.partobj$ po, sys.tab$ t
  WHERE  
      io.obj# = icp.obj# 
  and io.owner# = u.user#
  and icp.obj# = ins.obj# (+)
  and i.obj# = icp.bo# 
  and icp.bo# = i.obj#
  and i.type# != 9  --  no domain indexes
  and i.bo# = ot.obj#
  and ot.type# = 2
  and ot.owner# = ut.user#
  and i.obj# = po.obj#
  and ot.obj# = t.obj#
  and io.namespace = 4 and io.remoteowner IS NULL and io.linkname IS NULL
  and (io.owner# = userenv('SCHEMAID') 
        or 
        i.bo# in (select oa.obj#
                  FROM sys.objauth$ oa
                    where grantee# in ( select kzsrorol
                                        FROM x$kzsro
                                      ) 
                   )
        or /* user has system privileges */
         exists (select null FROM v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
  UNION ALL
  SELECT 
    u.name, op.name, ut.name, ot.name,
    op.subname, icp.part#, os.subname, isp.subpart#, 
    'SUBPARTITION',
    isp.blevel, isp.leafcnt, isp.distkey, isp.lblkkey, isp.dblkkey, 
    isp.clufac, isp.rowcnt, ins.cachedblk, ins.cachehit,
    isp.samplesize, isp.analyzetime,
    decode(bitand(isp.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(isp.flags, 8), 0, 'NO', 'YES'),
    decode(bitand(t.trigflag, 67108864) + bitand(t.trigflag, 134217728),
           0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL'),
    (select 
       case     when (i.analyzetime is null or
                      tab.analyzetime is null) then null
                when (i.analyzetime < tab.analyzetime  or
                      ((m.inserts + m.deletes + m.updates) > tab.rowcnt * 0.1 or
                       bitand(m.flags,1) = 1)) then 'YES'
                else 'NO'
       end
       FROM sys.tab$ tab, sys.mon_mods_all$ m 
       where tab.obj# = i.bo# and tab.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 0   -- not local index
     union all
     select
       case     when (i.analyzetime is null or
                      tsp.analyzetime is null) then null
                when (i.analyzetime < tsp.analyzetime  or
                      ((m.inserts + m.deletes + m.updates) > tsp.rowcnt * 0.1 or
                       bitand(m.flags,1) = 1)) then 'YES'
                else 'NO'
       end
       FROM  sys.tabcompartv$ tcp, sys.tabsubpartv$ tsp, sys.mon_mods_all$ m 
       where tcp.bo# = i.bo# and tcp.phypart# = icp.phypart# and
             tsp.pobj# = tcp.obj# and  
             isp.physubpart# = tsp.physubpart# and
             tsp.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 1)  -- local index
  FROM
    sys.obj$ os, sys.obj$ op, sys.indcompartv$ icp, sys.indsubpartv$ isp, 
    sys.user$ u,  sys.ind_stats$ ins,
    sys.ind$ i, sys.obj$ ot, sys.user$ ut, sys.partobj$ po, sys.tab$ t
  WHERE  
      os.obj# = isp.obj# 
  and op.obj# = icp.obj# 
  and icp.obj# = isp.pobj# 
  and icp.bo# = i.obj# 
  and i.type# != 9  --  no domain indexes
  and u.user# = op.owner# 
  and isp.obj# = ins.obj# (+)
  and icp.bo# = i.obj#
  and i.bo# = ot.obj#
  and ot.type# = 2
  and ot.owner# = ut.user#
  and i.obj# = po.obj#
  and ot.obj# = t.obj#
  and op.namespace = 4 and op.remoteowner IS NULL and op.linkname IS NULL
  and (op.owner# = userenv('SCHEMAID')
        or i.bo# in
            (select oa.obj#
             FROM sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 FROM x$kzsro
                               ) 
            )
        or /* user has system privileges */
         exists (select null FROM v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
/
create or replace public synonym ALL_IND_STATISTICS for ALL_IND_STATISTICS
/
grant select on ALL_IND_STATISTICS to PUBLIC with grant option
/
comment on table ALL_IND_STATISTICS is
'Optimizer statistics for all indexes on tables accessible to the user'
/
comment on column ALL_IND_STATISTICS.OWNER is
'Username of the owner of the index'
/
comment on column ALL_IND_STATISTICS.INDEX_NAME is
'Name of the index'
/
comment on column ALL_IND_STATISTICS.TABLE_OWNER is
'Owner of the indexed object'
/
comment on column ALL_IND_STATISTICS.TABLE_NAME is
'Name of the indexed object'
/
comment on column ALL_IND_STATISTICS.PARTITION_NAME is
'Name of the partition'
/  
comment on column ALL_IND_STATISTICS.PARTITION_POSITION is
'Position of the partition within index'
/  
comment on column ALL_IND_STATISTICS.SUBPARTITION_NAME is
'Name of the subpartition'
/  
comment on column ALL_IND_STATISTICS.SUBPARTITION_POSITION is
'Position of the subpartition within partition'
/  
comment on column ALL_IND_STATISTICS.OBJECT_TYPE is
'Type of the object (INDEX, PARTITION, SUBPARTITION)'
/  
comment on column ALL_IND_STATISTICS.NUM_ROWS is
'The number of rows in the index'
/
comment on column ALL_IND_STATISTICS.BLEVEL is
'B-Tree level'
/
comment on column ALL_IND_STATISTICS.LEAF_BLOCKS is
'The number of leaf blocks in the index'
/
comment on column ALL_IND_STATISTICS.DISTINCT_KEYS is
'The number of distinct keys in the index'
/
comment on column ALL_IND_STATISTICS.AVG_LEAF_BLOCKS_PER_KEY is
'The average number of leaf blocks per key'
/
comment on column ALL_IND_STATISTICS.AVG_DATA_BLOCKS_PER_KEY is
'The average number of data blocks per key'
/
comment on column ALL_IND_STATISTICS.CLUSTERING_FACTOR is
'A measurement of the amount of (dis)order of the table this index is for'
/
comment on column ALL_IND_STATISTICS.AVG_CACHED_BLOCKS is
'Average number of blocks in buffer cache'
/
comment on column ALL_IND_STATISTICS.AVG_CACHE_HIT_RATIO is
'Average cache hit ratio for the object'
/
comment on column ALL_IND_STATISTICS.SAMPLE_SIZE is
'The sample size used in analyzing this index'
/
comment on column ALL_IND_STATISTICS.LAST_ANALYZED is
'The date of the most recent time this index was analyzed'
/
comment on column ALL_IND_STATISTICS.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column ALL_IND_STATISTICS.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column ALL_IND_STATISTICS.STATTYPE_LOCKED is
'type of statistics lock'
/
comment on column ALL_IND_STATISTICS.STALE_STATS is
'Whether statistics for the object is stale or not'
/

create or replace view DBA_IND_STATISTICS
  (
  OWNER, INDEX_NAME, TABLE_OWNER, TABLE_NAME,
  PARTITION_NAME, PARTITION_POSITION,
  SUBPARTITION_NAME, SUBPARTITION_POSITION, OBJECT_TYPE,
  BLEVEL, LEAF_BLOCKS, 
  DISTINCT_KEYS, AVG_LEAF_BLOCKS_PER_KEY, AVG_DATA_BLOCKS_PER_KEY,
  CLUSTERING_FACTOR, NUM_ROWS, 
  AVG_CACHED_BLOCKS, AVG_CACHE_HIT_RATIO,
  SAMPLE_SIZE, LAST_ANALYZED, GLOBAL_STATS, USER_STATS,
  STATTYPE_LOCKED, STALE_STATS
  )
  AS
  SELECT
    u.name, o.name, ut.name, ot.name,
    NULL,NULL, NULL, NULL, 'INDEX',
    i.blevel, i.leafcnt, i.distkey, i.lblkkey, i.dblkkey, i.clufac, i.rowcnt,
    ins.cachedblk, ins.cachehit, i.samplesize, i.analyzetime,
    decode(bitand(i.flags, 2048), 0, 'NO', 'YES'),
    decode(bitand(i.flags, 64), 0, 'NO', 'YES'),
    decode(bitand(t.trigflag, 67108864) + bitand(t.trigflag, 134217728),
           0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL'),
    case when
          (i.analyzetime is null or 
            t.analyzetime is null) then null
         when (i.analyzetime < t.analyzetime or
               (((m.inserts + m.deletes + m.updates) > t.rowcnt * 0.1 or
                bitand(m.flags,1) = 1))) then 'YES'
         else  'NO' 
    end
  FROM
    sys.user$ u, sys.ind$ i, sys.obj$ o, sys.ind_stats$ ins,
    sys.obj$ ot, sys.user$ ut, sys.tab$ t, sys.mon_mods_all$ m
  WHERE
      u.user# = o.owner#
  and o.obj# = i.obj#
  and bitand(i.flags, 4096) = 0
  and i.type# in (1, 2, 4, 6, 7, 8)
  and i.obj# = ins.obj# (+)
  and i.bo# = ot.obj# 
  and ot.type# = 2
  and ot.owner# = ut.user#
  and ot.obj# = t.obj#
  and t.obj# = m.obj# (+)
  and o.subname IS NULL
  and o.namespace = 4 and o.remoteowner IS NULL and o.linkname IS NULL
  UNION ALL
  SELECT
    u.name, o.name, ut.name, ot.name,
    NULL,NULL, NULL, NULL, 'INDEX',
    i.blevel, i.leafcnt, i.distkey, i.lblkkey, i.dblkkey, i.clufac, i.rowcnt,
    ins.cachedblk, ins.cachehit, i.samplesize, i.analyzetime,
    decode(bitand(i.flags, 2048), 0, 'NO', 'YES'),
    decode(bitand(i.flags, 64), 0, 'NO', 'YES'),
    -- a cluster index is considered locked if any of the table in
    -- the cluster is locked.
    decode((select
           decode(nvl(sum(decode(bitand(t.trigflag, 67108864), 0, 0, 1)),0),
                  0, 0, 67108864) +
           decode(nvl(sum(decode(bitand(nvl(t.trigflag, 0), 134217728), 
                                 0, 0, 1)), 0),
                  0, 0, 134217728) 
           from  sys.tab$ t where i.bo# = t.bobj#),
           0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL'),
    case
         when i.analyzetime is null then null
         when
           (select                                 -- STALE
              sum(case when
                      i.analyzetime < tab.analyzetime or
                      bitand(m.flags,1) = 1 or
                      m.inserts + m.updates + m.deletes > (.1 * tab.rowcnt)
                  then 1 else 0 end)
            from sys.tab$ tab, mon_mods_all$ m
            where
              m.obj#(+) = tab.obj# and tab.bobj# = i.bo#) > 0 then 'YES'
         else 'NO' end
  FROM
    sys.user$ u, sys.ind$ i, sys.obj$ o, sys.ind_stats$ ins,
    sys.obj$ ot, sys.user$ ut
  WHERE
      u.user# = o.owner#
  and o.obj# = i.obj#
  and bitand(i.flags, 4096) = 0
  and i.type# = 3
  and i.obj# = ins.obj# (+)
  and i.bo# = ot.obj# 
  and ot.owner# = ut.user#
  and o.subname IS NULL
  and o.namespace = 4 and o.remoteowner IS NULL and o.linkname IS NULL
  UNION ALL
  SELECT 
    u.name, io.name, ut.name, ot.name,
    io.subname, ip.part#, NULL, NULL, 'PARTITION',
    ip.blevel, ip.leafcnt, ip.distkey, ip.lblkkey, ip.dblkkey, 
    ip.clufac, ip.rowcnt, ins.cachedblk, ins.cachehit,
    ip.samplesize, ip.analyzetime,
    decode(bitand(ip.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(ip.flags, 8), 0, 'NO', 'YES'),
    decode(bitand(t.trigflag, 67108864) + bitand(t.trigflag, 134217728),
           0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL'),
    (select 
       case     when (i.analyzetime is null or
                      tab.analyzetime is null) then null
                when (i.analyzetime < tab.analyzetime  or
                      ((m.inserts + m.deletes + m.updates) > tab.rowcnt * 0.1 or
                       bitand(m.flags,1) = 1)) then 'YES'
                else 'NO'
       end
       FROM sys.tab$ tab, sys.mon_mods_all$ m 
       where tab.obj# = i.bo# and tab.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 0   -- not local index
     union all
     select
       case     when (i.analyzetime is null or
                      tp.analyzetime is null) then null
                when (i.analyzetime < tp.analyzetime  or
                      ((m.inserts + m.deletes + m.updates) > tp.rowcnt * 0.1 or
                       bitand(m.flags,1) = 1)) then 'YES'
                else 'NO'
       end
       FROM sys.tabpartv$ tp, sys.mon_mods_all$ m 
       where tp.bo# = i.bo# and tp.phypart# = ip.phypart# and
             tp.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 1)  -- local index
  FROM 
    sys.obj$ io, sys.indpartv$ ip, 
    sys.user$ u, sys.ind_stats$ ins,
    sys.ind$ i, sys.obj$ ot, sys.user$ ut, sys.partobj$ po, sys.tab$ t
  WHERE
      io.obj# = ip.obj# 
  and io.owner# = u.user#
  and ip.obj# = ins.obj# (+)
  and ip.bo# = i.obj#
  and i.type# != 9  --  no domain indexes
  and i.bo# = ot.obj#
  and ot.type# = 2
  and ot.owner# = ut.user#
  and i.obj# = po.obj#
  and ot.obj# = t.obj#
  and io.namespace = 4 and io.remoteowner IS NULL and io.linkname IS NULL
  UNION ALL
  SELECT 
    u.name, io.name, ut.name, ot.name,
    io.subname, icp.part#, NULL, NULL, 'PARTITION',
    icp.blevel, icp.leafcnt, icp.distkey, icp.lblkkey, icp.dblkkey, 
    icp.clufac, icp.rowcnt, ins.cachedblk, ins.cachehit,
    icp.samplesize, icp.analyzetime,
    decode(bitand(icp.flags, 16), 0, 'NO', 'YES'), 
    decode(bitand(icp.flags, 8), 0, 'NO', 'YES'),
    decode(bitand(t.trigflag, 67108864) + bitand(t.trigflag, 134217728),
           0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL'),
    (select 
       case     when (i.analyzetime is null or
                      tab.analyzetime is null) then null
                when (i.analyzetime < tab.analyzetime  or
                      ((m.inserts + m.deletes + m.updates) > tab.rowcnt * 0.1 or
                       bitand(m.flags,1) = 1)) then 'YES'
                else 'NO'
       end
       FROM sys.tab$ tab, sys.mon_mods_all$ m 
       where tab.obj# = i.bo# and tab.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 0   -- not local index
     union all
     select
       case     when (i.analyzetime is null or
                      tcp.analyzetime is null) then null
                when (i.analyzetime < tcp.analyzetime  or
                      ((m.inserts + m.deletes + m.updates) > tcp.rowcnt * 0.1 or
                       bitand(m.flags,1) = 1)) then 'YES'
                else 'NO'
       end
       FROM sys.tabcompartv$ tcp, sys.mon_mods_all$ m 
       where tcp.bo# = i.bo# and tcp.phypart# = icp.phypart# and
             tcp.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 1)  -- local index
  FROM
    sys.obj$ io, sys.indcompartv$ icp, sys.user$ u, sys.ind_stats$ ins,
    sys.ind$ i, sys.obj$ ot, sys.user$ ut, sys.partobj$ po, sys.tab$ t
  WHERE  
      io.obj# = icp.obj# 
  and io.owner# = u.user#
  and icp.obj# = ins.obj# (+)
  and icp.bo# = i.obj#
  and i.type# != 9  --  no domain indexes
  and i.bo# = ot.obj#
  and ot.type# = 2
  and ot.owner# = ut.user#
  and i.obj# = po.obj#
  and ot.obj# = t.obj#
  and io.namespace = 4 and io.remoteowner IS NULL and io.linkname IS NULL
  UNION ALL
  SELECT 
    u.name, op.name, ut.name, ot.name,
    op.subname, icp.part#, os.subname, isp.subpart#, 
    'SUBPARTITION',
    isp.blevel, isp.leafcnt, isp.distkey, isp.lblkkey, isp.dblkkey, 
    isp.clufac, isp.rowcnt, ins.cachedblk, ins.cachehit,
    isp.samplesize, isp.analyzetime,
    decode(bitand(isp.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(isp.flags, 8), 0, 'NO', 'YES'),
    decode(bitand(t.trigflag, 67108864) + bitand(t.trigflag, 134217728),
           0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL'),
    (select 
       case     when (i.analyzetime is null or
                      tab.analyzetime is null) then null
                when (i.analyzetime < tab.analyzetime  or
                      ((m.inserts + m.deletes + m.updates) > tab.rowcnt * 0.1 or
                       bitand(m.flags,1) = 1)) then 'YES'
                else 'NO'
       end
       FROM sys.tab$ tab, sys.mon_mods_all$ m 
       where tab.obj# = i.bo# and tab.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 0   -- not local index
     union all
     select
       case     when (i.analyzetime is null or
                      tsp.analyzetime is null) then null
                when (i.analyzetime < tsp.analyzetime  or
                      ((m.inserts + m.deletes + m.updates) > tsp.rowcnt * 0.1 or
                       bitand(m.flags,1) = 1)) then 'YES'
                else 'NO'
       end
       FROM  sys.tabcompartv$ tcp, sys.tabsubpartv$ tsp, sys.mon_mods_all$ m 
       where tcp.bo# = i.bo# and tcp.phypart# = icp.phypart# and
             tsp.pobj# = tcp.obj# and  
             isp.physubpart# = tsp.physubpart# and
             tsp.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 1)  -- local index
  FROM
    sys.obj$ os, sys.obj$ op, sys.indcompartv$ icp, sys.indsubpartv$ isp, 
    sys.user$ u,  sys.ind_stats$ ins,
    sys.ind$ i, sys.obj$ ot, sys.user$ ut, sys.partobj$ po, sys.tab$ t
  WHERE  
      os.obj# = isp.obj# 
  and op.obj# = icp.obj# 
  and icp.obj# = isp.pobj# 
  and u.user# = op.owner# 
  and isp.obj# = ins.obj# (+)
  and icp.bo# = i.obj#
  and i.type# != 9  --  no domain indexes
  and i.bo# = ot.obj#
  and ot.type# = 2
  and ot.owner# = ut.user#
  and i.obj# = po.obj#
  and ot.obj# = t.obj#
  and op.namespace = 4 and op.remoteowner IS NULL and op.linkname IS NULL
/
create or replace public synonym DBA_IND_STATISTICS for DBA_IND_STATISTICS
/
grant select on DBA_IND_STATISTICS to select_catalog_role 
/
comment on table DBA_IND_STATISTICS is
'Optimizer statistics for all indexes in the database'
/
comment on column DBA_IND_STATISTICS.OWNER is
'Username of the owner of the index'
/
comment on column DBA_IND_STATISTICS.INDEX_NAME is
'Name of the index'
/
comment on column DBA_IND_STATISTICS.TABLE_OWNER is
'Owner of the indexed object'
/
comment on column DBA_IND_STATISTICS.TABLE_NAME is
'Name of the indexed object'
/
comment on column DBA_IND_STATISTICS.PARTITION_NAME is
'Name of the partition'
/  
comment on column DBA_IND_STATISTICS.PARTITION_POSITION is
'Position of the partition within index'
/  
comment on column DBA_IND_STATISTICS.SUBPARTITION_NAME is
'Name of the subpartition'
/  
comment on column DBA_IND_STATISTICS.SUBPARTITION_POSITION is
'Position of the subpartition within partition'
/  
comment on column DBA_IND_STATISTICS.OBJECT_TYPE is
'Type of the object (INDEX, PARTITION, SUBPARTITION)'
/  
comment on column DBA_IND_STATISTICS.NUM_ROWS is
'The number of rows in the index'
/
comment on column DBA_IND_STATISTICS.BLEVEL is
'B-Tree level'
/
comment on column DBA_IND_STATISTICS.LEAF_BLOCKS is
'The number of leaf blocks in the index'
/
comment on column DBA_IND_STATISTICS.DISTINCT_KEYS is
'The number of distinct keys in the index'
/
comment on column DBA_IND_STATISTICS.AVG_LEAF_BLOCKS_PER_KEY is
'The average number of leaf blocks per key'
/
comment on column DBA_IND_STATISTICS.AVG_DATA_BLOCKS_PER_KEY is
'The average number of data blocks per key'
/
comment on column DBA_IND_STATISTICS.CLUSTERING_FACTOR is
'A measurement of the amount of (dis)order of the table this index is for'
/
comment on column DBA_IND_STATISTICS.AVG_CACHED_BLOCKS is
'Average number of blocks in buffer cache'
/
comment on column DBA_IND_STATISTICS.AVG_CACHE_HIT_RATIO is
'Average cache hit ratio for the object'
/
comment on column DBA_IND_STATISTICS.SAMPLE_SIZE is
'The sample size used in analyzing this index'
/
comment on column DBA_IND_STATISTICS.LAST_ANALYZED is
'The date of the most recent time this index was analyzed'
/
comment on column DBA_IND_STATISTICS.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column DBA_IND_STATISTICS.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column DBA_IND_STATISTICS.STATTYPE_LOCKED is
'type of statistics lock'
/
comment on column DBA_IND_STATISTICS.STALE_STATS is
'Whether statistics for the object is stale or not'
/

create or replace view USER_IND_STATISTICS
  (
  INDEX_NAME, TABLE_OWNER, TABLE_NAME,
  PARTITION_NAME, PARTITION_POSITION,
  SUBPARTITION_NAME, SUBPARTITION_POSITION, OBJECT_TYPE,
  BLEVEL, LEAF_BLOCKS, 
  DISTINCT_KEYS, AVG_LEAF_BLOCKS_PER_KEY, AVG_DATA_BLOCKS_PER_KEY,
  CLUSTERING_FACTOR, NUM_ROWS, 
  AVG_CACHED_BLOCKS, AVG_CACHE_HIT_RATIO,
  SAMPLE_SIZE, LAST_ANALYZED, GLOBAL_STATS, USER_STATS,
  STATTYPE_LOCKED, STALE_STATS
  )
  AS
  SELECT
    o.name, ut.name, ot.name,
    NULL,NULL, NULL, NULL, 'INDEX',
    i.blevel, i.leafcnt, i.distkey, i.lblkkey, i.dblkkey, i.clufac, i.rowcnt,
    ins.cachedblk, ins.cachehit, i.samplesize, i.analyzetime,
    decode(bitand(i.flags, 2048), 0, 'NO', 'YES'),
    decode(bitand(i.flags, 64), 0, 'NO', 'YES'),
    decode(bitand(t.trigflag, 67108864) + bitand(t.trigflag, 134217728),
           0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL'),
    case when
           (i.analyzetime is null or 
            t.analyzetime is null) then null
         when (i.analyzetime < t.analyzetime or
               (((m.inserts + m.deletes + m.updates) > t.rowcnt * 0.1 or
                bitand(m.flags,1) = 1))) then 'YES'
         else  'NO' 
    end
  FROM
    sys.ind$ i, sys.obj$ o, sys.ind_stats$ ins,
    sys.obj$ ot, sys.user$ ut, sys.tab$ t, sys.mon_mods_all$ m
  WHERE
      o.obj# = i.obj#
  and bitand(i.flags, 4096) = 0
  and i.type# in (1, 2, 4, 6, 7, 8)
  and i.obj# = ins.obj# (+)
  and i.bo# = ot.obj# 
  and ot.type# = 2
  and ot.owner# = ut.user#
  and ot.obj# = t.obj#
  and t.obj# = m.obj# (+)
  and o.owner# = userenv('SCHEMAID') and o.subname IS NULL
  and o.namespace = 4 and o.remoteowner IS NULL and o.linkname IS NULL
  UNION ALL
  SELECT
    o.name, ut.name, ot.name,
    NULL,NULL, NULL, NULL, 'INDEX',
    i.blevel, i.leafcnt, i.distkey, i.lblkkey, i.dblkkey, i.clufac, i.rowcnt,
    ins.cachedblk, ins.cachehit, i.samplesize, i.analyzetime,
    decode(bitand(i.flags, 2048), 0, 'NO', 'YES'),
    decode(bitand(i.flags, 64), 0, 'NO', 'YES'),
    -- a cluster index is considered locked if any of the table in
    -- the cluster is locked.
    decode((select
           decode(nvl(sum(decode(bitand(t.trigflag, 67108864), 0, 0, 1)),0),
                  0, 0, 67108864) +
           decode(nvl(sum(decode(bitand(nvl(t.trigflag, 0), 134217728), 
                                 0, 0, 1)), 0),
                  0, 0, 134217728) 
           from  sys.tab$ t where i.bo# = t.bobj#),
           0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL'),
    case 
         when i.analyzetime is null then null
         when
           (select                                 -- STALE
              sum(case when
                      i.analyzetime < tab.analyzetime or
                      bitand(m.flags,1) = 1 or
                      m.inserts + m.updates + m.deletes > (.1 * tab.rowcnt)
                  then 1 else 0 end)
            from sys.tab$ tab, mon_mods_all$ m
            where
              m.obj#(+) = tab.obj# and tab.bobj# = i.bo#) > 0 then 'YES'
         else 'NO' end
  FROM
    sys.ind$ i, sys.obj$ o, sys.ind_stats$ ins,
    sys.obj$ ot, sys.user$ ut
  WHERE
      o.obj# = i.obj#
  and bitand(i.flags, 4096) = 0
  and i.type# = 3  /* Cluster index */
  and i.obj# = ins.obj# (+)
  and i.bo# = ot.obj# 
  and ot.owner# = ut.user#
  and o.owner# = userenv('SCHEMAID') and o.subname IS NULL
  and o.namespace = 4 and o.remoteowner IS NULL and o.linkname IS NULL
  UNION ALL
  SELECT 
    io.name, ut.name, ot.name,
    io.subname, ip.part#, NULL, NULL, 'PARTITION',
    ip.blevel, ip.leafcnt, ip.distkey, ip.lblkkey, ip.dblkkey, 
    ip.clufac, ip.rowcnt, ins.cachedblk, ins.cachehit,
    ip.samplesize, ip.analyzetime,
    decode(bitand(ip.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(ip.flags, 8), 0, 'NO', 'YES'),
    decode(bitand(t.trigflag, 67108864) + bitand(t.trigflag, 134217728),
           0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL'),
    (select 
       case     when (i.analyzetime is null or
                      tab.analyzetime is null) then null
                when (i.analyzetime < tab.analyzetime  or
                      ((m.inserts + m.deletes + m.updates) > tab.rowcnt * 0.1 or
                       bitand(m.flags,1) = 1)) then 'YES'
                else 'NO'
       end
       FROM sys.tab$ tab, sys.mon_mods_all$ m 
       where tab.obj# = i.bo# and tab.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 0   -- not local index
     union all
     select
       case     when (i.analyzetime is null or
                      tp.analyzetime is null) then null
                when (i.analyzetime < tp.analyzetime  or
                      ((m.inserts + m.deletes + m.updates) > tp.rowcnt * 0.1 or
                       bitand(m.flags,1) = 1)) then 'YES'
                else 'NO'
       end
       FROM sys.tabpartv$ tp, sys.mon_mods_all$ m 
       where tp.bo# = i.bo# and tp.phypart# = ip.phypart# and
             tp.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 1)  -- local index
  FROM 
    sys.obj$ io, sys.indpartv$ ip, sys.ind_stats$ ins,
    sys.ind$ i, sys.obj$ ot, sys.user$ ut, sys.partobj$ po, sys.tab$ t
  WHERE
      io.obj# = ip.obj# 
  and ip.obj# = ins.obj# (+)
  and ip.bo# = i.obj#
  and i.type# != 9  --  no domain indexes
  and i.bo# = ot.obj#
  and ot.type# = 2
  and ot.owner# = ut.user#
  and i.obj# = po.obj#
  and ot.obj# = t.obj#
  and io.owner# = userenv('SCHEMAID') 
  and io.namespace = 4 and io.remoteowner IS NULL and io.linkname IS NULL
  UNION ALL
  SELECT 
    io.name, ut.name, ot.name,
    io.subname, icp.part#, NULL, NULL, 'PARTITION',
    icp.blevel, icp.leafcnt, icp.distkey, icp.lblkkey, icp.dblkkey, 
    icp.clufac, icp.rowcnt, ins.cachedblk, ins.cachehit,
    icp.samplesize, icp.analyzetime,
    decode(bitand(icp.flags, 16), 0, 'NO', 'YES'), 
    decode(bitand(icp.flags, 8), 0, 'NO', 'YES'),
    decode(bitand(t.trigflag, 67108864) + bitand(t.trigflag, 134217728),
           0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL'),
    (select 
       case     when (i.analyzetime is null or
                      tab.analyzetime is null) then null
                when (i.analyzetime < tab.analyzetime  or
                      ((m.inserts + m.deletes + m.updates) > tab.rowcnt * 0.1 or
                       bitand(m.flags,1) = 1)) then 'YES'
                else 'NO'
       end
       FROM sys.tab$ tab, sys.mon_mods_all$ m 
       where tab.obj# = i.bo# and tab.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 0   -- not local index
     union all
     select
       case     when (i.analyzetime is null or
                      tcp.analyzetime is null) then null
                when (i.analyzetime < tcp.analyzetime  or
                      ((m.inserts + m.deletes + m.updates) > tcp.rowcnt * 0.1 or
                       bitand(m.flags,1) = 1)) then 'YES'
                else 'NO'
       end
       FROM sys.tabcompartv$ tcp, sys.mon_mods_all$ m 
       where tcp.bo# = i.bo# and tcp.phypart# = icp.phypart# and
             tcp.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 1)  -- local index
  FROM
    sys.obj$ io, sys.indcompartv$ icp, sys.ind_stats$ ins,
    sys.ind$ i, sys.obj$ ot, sys.user$ ut, sys.partobj$ po, sys.tab$ t 
  WHERE  
      io.obj# = icp.obj# 
  and io.obj# = ins.obj# (+)
  and icp.bo# = i.obj#
  and i.type# != 9  --  no domain indexes
  and i.bo# = ot.obj#
  and ot.type# = 2
  and ot.owner# = ut.user#
  and i.obj# = po.obj#
  and ot.obj# = t.obj#
  and io.owner# = userenv('SCHEMAID') 
  and io.namespace = 4 and io.remoteowner IS NULL and io.linkname IS NULL
  UNION ALL
  SELECT 
    op.name, ut.name, ot.name,
    op.subname, icp.part#, os.subname, isp.subpart#,
    'SUBPARTITION',
    isp.blevel, isp.leafcnt, isp.distkey, isp.lblkkey, isp.dblkkey, 
    isp.clufac, isp.rowcnt, ins.cachedblk, ins.cachehit,
    isp.samplesize, isp.analyzetime,
    decode(bitand(isp.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(isp.flags, 8), 0, 'NO', 'YES'),
    decode(bitand(t.trigflag, 67108864) + bitand(t.trigflag, 134217728),
           0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL'),
    (select 
       case     when (i.analyzetime is null or
                      tab.analyzetime is null) then null
                when (i.analyzetime < tab.analyzetime  or
                      ((m.inserts + m.deletes + m.updates) > tab.rowcnt * 0.1 or
                       bitand(m.flags,1) = 1)) then 'YES'
                else 'NO'
       end
       FROM sys.tab$ tab, sys.mon_mods_all$ m 
       where tab.obj# = i.bo# and tab.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 0   -- not local index
     union all
     select
       case     when (i.analyzetime is null or
                      tsp.analyzetime is null) then null
                when (i.analyzetime < tsp.analyzetime  or
                      ((m.inserts + m.deletes + m.updates) > tsp.rowcnt * 0.1 or
                       bitand(m.flags,1) = 1)) then 'YES'
                else 'NO'
       end
       FROM  sys.tabcompartv$ tcp, sys.tabsubpartv$ tsp, sys.mon_mods_all$ m 
       where tcp.bo# = i.bo# and tcp.phypart# = icp.phypart# and
             tsp.pobj# = tcp.obj# and  
             isp.physubpart# = tsp.physubpart# and
             tsp.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 1)  -- local index
  FROM
    sys.obj$ os, sys.obj$ op, sys.indcompartv$ icp, sys.indsubpartv$ isp, 
    sys.ind_stats$ ins,
    sys.ind$ i, sys.obj$ ot, sys.user$ ut, sys.partobj$ po, sys.tab$ t
  WHERE  
      os.obj# = isp.obj# 
  and op.obj# = icp.obj# 
  and icp.obj# = isp.pobj# 
  and isp.obj# = ins.obj# (+)
  and icp.bo# = i.obj#
  and i.type# != 9  --  no domain indexes
  and i.bo# = ot.obj#
  and ot.type# = 2
  and ot.owner# = ut.user#
  and i.obj# = po.obj#
  and ot.obj# = t.obj#
  and op.owner# = userenv('SCHEMAID')
  and op.namespace = 4 and op.remoteowner IS NULL and op.linkname IS NULL
/
create or replace public synonym USER_IND_STATISTICS for USER_IND_STATISTICS
/
grant select on USER_IND_STATISTICS to PUBLIC with grant option 
/
comment on table USER_IND_STATISTICS is
'Optimizer statistics for user''s own indexes'
/
comment on column USER_IND_STATISTICS.INDEX_NAME is
'Name of the index'
/
comment on column USER_IND_STATISTICS.TABLE_OWNER is
'Owner of the indexed object'
/
comment on column USER_IND_STATISTICS.TABLE_NAME is
'Name of the indexed object'
/
comment on column USER_IND_STATISTICS.PARTITION_NAME is
'Name of the partition'
/  
comment on column USER_IND_STATISTICS.PARTITION_POSITION is
'Position of the partition within index'
/  
comment on column USER_IND_STATISTICS.SUBPARTITION_NAME is
'Name of the subpartition'
/  
comment on column USER_IND_STATISTICS.SUBPARTITION_POSITION is
'Position of the subpartition within partition'
/  
comment on column USER_IND_STATISTICS.OBJECT_TYPE is
'Type of the object (INDEX, PARTITION, SUBPARTITION)'
/  
comment on column USER_IND_STATISTICS.NUM_ROWS is
'The number of rows in the index'
/
comment on column USER_IND_STATISTICS.BLEVEL is
'B-Tree level'
/
comment on column USER_IND_STATISTICS.LEAF_BLOCKS is
'The number of leaf blocks in the index'
/
comment on column USER_IND_STATISTICS.DISTINCT_KEYS is
'The number of distinct keys in the index'
/
comment on column USER_IND_STATISTICS.AVG_LEAF_BLOCKS_PER_KEY is
'The average number of leaf blocks per key'
/
comment on column USER_IND_STATISTICS.AVG_DATA_BLOCKS_PER_KEY is
'The average number of data blocks per key'
/
comment on column USER_IND_STATISTICS.CLUSTERING_FACTOR is
'A measurement of the amount of (dis)order of the table this index is for'
/
comment on column USER_IND_STATISTICS.AVG_CACHED_BLOCKS is
'Average number of blocks in buffer cache'
/
comment on column USER_IND_STATISTICS.AVG_CACHE_HIT_RATIO is
'Average cache hit ratio for the object'
/
comment on column USER_IND_STATISTICS.SAMPLE_SIZE is
'The sample size used in analyzing this index'
/
comment on column USER_IND_STATISTICS.LAST_ANALYZED is
'The date of the most recent time this index was analyzed'
/
comment on column USER_IND_STATISTICS.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column USER_IND_STATISTICS.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column USER_IND_STATISTICS.STATTYPE_LOCKED is
'type of statistics lock'
/
comment on column USER_IND_STATISTICS.STALE_STATS is
'Whether statistics for the object is stale or not'
/

