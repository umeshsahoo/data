Rem
Rem NAME
Rem   CATPLUG.SQL
Rem FUNCTION
Rem   Pluggable Tablespace check views
Rem NOTES
Rem   This script must be run while connected as SYS or INTERNAL
Rem    MODIFIED   (MM/DD/YY)
Rem     clei      06/11/04  - disallow tables with encrypted columns
Rem     ahwang    05/20/04  - catch unupgraded evolved type data 
Rem     apareek   03/23/04  - fix domain idx tablespace 0 problem - Bug3543844
Rem     ahwang    11/13/03  - system owned objects filering
Rem     ahwang    10/08/03  - filter out recyclebin objects 
Rem     ahwang    09/23/03  - correct checking on REFs with partitions and 
Rem                           IOT;correct checking on bitmap join index; 
Rem     ahwang    09/10/03  - remove the incorrect REF self-containment check 
Rem     apareek   05/20/03  - allow MV support 
Rem     ahwang    03/16/03  - bug2723389 - proper detection of unsupported 
Rem                           MV objects
Rem     apareek   03/06/03  - allow ref col to be transported (Bug 895775)
Rem     amsrivas  10/18/02  - 2477350: check snapshots on partitioned tables
Rem     amsrivas  10/08/02  - 2447432: iot constraints should use ind$
Rem     araghava  02/12/02  - bug 1912886: partition numbers no longer go 
Rem                           from 1 -> n.
Rem     apareek   12/27/00  - bug 1560639
Rem     apareek   10/24/00 -  default tablespace for coop indexes ignored
Rem     apareek   08/15/00 -  allow non PL/SQL functional indexes in tts set
Rem     apareek   08/15/00 -  allow sec objs in tts set
Rem     amozes    07/21/00  - bitmap join index
Rem     amsrivas  04/06/00  - 1167617 capture indexes enforcing unique key
Rem     rshaikh   11/10/99 -  fix for sqlplus
Rem     apareek   08/05/99 -  block REF with referential cons- bug895775
Rem     apareek   07/19/99 -  fix bug 860417
Rem     mjungerm  06/15/99 -  add java shared data object type
Rem     apareek   06/16/99 -  ignore dropped undo segs
Rem     apareek   03/25/99 -  iots with lobs should go against ind$
Rem     apareek   02/22/99 -  bug824907 - partitioned iots
Rem     apareek   03/11/99 -  go against ind$ for iots
Rem     jwlee     01/06/99 -  Allow AQ to be transported
Rem     apareek   12/03/98 -  fix blanks for sqlplus
Rem     apareek   10/20/98 -  block functional indexes
Rem     apareek   10/12/98 -  add check for default tablespace
Rem     apareek   09/01/98 -  check for undo segs
Rem     apareek   08/25/98 -  IOT and overflow segment self contained
Rem     apareek   08/24/98 -  foreign key constraint is only a 1 way violation
Rem     apareek   08/20/98 -  allow VARRAY, NESTED TABLES, IOTS
Rem     apareek   08/06/98 -  disallow SYS owned objects
Rem     apareek   08/06/98 -  capture secondary objects, domain indexes
Rem     apareek   08/05/98 -  allow FILE columns
Rem     apareek   07/31/98 -  fix bug 707999
Rem     apareek   07/31/98 -  add checks for subpartitions, partitioned lobs
Rem     ncramesh  08/04/98 -  change for sqlplus
Rem     apareek   06/24/98 -  TS_PITR_INFO -> TS_PLUG_INFO
Rem     apareek   05/19/98 -  Add mesg_id column
Rem     jwlee     05/18/98 -  STRADDLING_RS_OBJECTS -> STRADDLING_TS_OBJECTS
Rem     jwlee     05/03/98 -  pluggable_set_check -> transportable_set_check
Rem     apareek   04/27/98 -  creation
Rem     apareek   04/06/98 -  Creation
Rem

REM
REM  tts_tab_view is a view used by TTS containment check. 
REM  tts_tab_view column set is a subset of of tab$'s except it resolves 
REM  the tablespace nmber. Note that tab$.ts# is zero for objects like IOTs
REM  and partitioned tables. This view currenly resolves ts# for 'normal'
REM  tables, IOTs, partitioned tables. It is currently employed by REF
REM  and joined index containment check. If ts# resolution for other table
REM  types are necessary, one can add to this union view definition.
REM

create or replace view tts_tab_view(obj#, ts#, property) as
/* 'simple' case, no IOT, no parition - return object's ts#*/
select t.obj#,t.ts#, t.property
from   tab$ t
where  BITAND(t.property, 2151678048)=0
union all
/* IOT - returns IOT index object's ts# */
select t.obj#, i.ts#, t.property
from   tab$ t, ind$ i
where  BITAND(t.property, 72)=72 AND i.bo#=t.obj#
union all
/* partitioned table - returns partitioned objects default ts#.
   Note that it is not necessary to check against all partitions and
   subpartitions because (1) there is already a check for containment
   among default tablespace and partition and subpartition tablespaces,
   (2) containment property is transitive.
*/
select t.obj#, po.defts#, t.property
from   tab$ t, partobj$ po
where  BITAND(t.property, 40)=40 and po.obj#=t.obj#;

REM tts_obj_view - view of obj$ that filters out recyclebin objects
create or replace view tts_obj_view as
select * from obj$ where bitand(flags, 128)=0;

grant select on tts_obj_view to SELECT_CATALOG_ROLE;
grant select on tts_tab_view to SELECT_CATALOG_ROLE;

Rem
Rem View Name   : PLUGGABLE_SET_CHECK
Rem
Rem View Schema 
Rem ===========
Rem
Rem     (OBJ1_OWNER,OBJ1_NAME,OBJ1_SUBNAME,OBJ1_TYPE,TS1_NAME,
Rem      OBJ2_NAME,OBJ2_SUBNAME,OBJ2_TYPE,OBJ2_OWNER, TS2_NAME,
Rem      CONSTRAINT_NAME,REASON
Rem     )
Rem
Rem Column Name                    Description
Rem ======================================================
Rem  OBJ1_OWNER                   Owner of object 1
Rem  OBJ1_NAME                    Object 1
Rem  OBJ1_SUBNAME                 SubObject1Name
Rem  OBJ1_TYPE                    Object Type     
Rem  TS1_NAME                     Tablespace containing Object 1 
Rem  OBJ2_NAME                    Object Name 
Rem  OBJ2_SUBNAME                 SubObject2Name
Rem  OBJ2_TYPE                    Object Type
Rem  OBJ2_OWNER                   Object owner of second object 
Rem  TS2_NAME                     Tablespace containing Object 1
Rem  CONSTRAINT_NAME              Name of dependent constraint
Rem  REASON                       Reason for Pluggable check violation
Rem
Rem
Rem
Rem Comments on View : PLUGGABLE_SET_CHECK
Rem ==========================================
Rem
Rem
Rem
Rem A transportable set needs to be self contained.  This means that there
Rem should be no dependencies that exist on objects that are not contained
Rem in the tablespaces that are being transported.
Rem To transport a tablespace in Oracle Version 8.1 
Rem at the time of export there can be no references going out of the 
Rem the Pluggable Set(PS) i.e the set of non-system tablespaces to be
Rem transported.  This view captures any  references not fully contained in
Rem the pluggable set.

Rem In addition, it checks for presence of objects in the pluggable set
Rem that are not supported 
Rem
Rem
Rem The view needs to return 0 rows for the export phase to proceed.

Rem The following scenarios will show up in the view:



Rem     - Replication master tables are in the pluggable set
Rem     - Tables/Clusters and associated indexes not fully contained in the RS
Rem     - Partitioned Objects (tables and indexes) not fully contained in the
Rem       PS
Rem     - includes, straddling table partitions and straddling table and index
Rem       partition
Rem     - Tables that have a parent-child relationship via referential 
Rem       integrity
Rem       constraints are not fully contained in the RS
Rem     - Lob Segments, Lob Indexes and referencing tables are not fully 
Rem       contained in the RS





Rem =========================================================================
Rem 05/05/2002
Rem In 10i we will allow transport of objects having ref columns.  Please see
Rem Bugs 802824, 895775, 907734 which all were fixed after column ordering
Rem support was added to the kernel and export and import. I earlier had a 
Rem check that would catch these types of objects (col$.property = 0x80000)
Rem and prevent them for being exported.  (Msg id 42)
Rem
Rem 05/09/2002
Rem Allow primary key-based IOD$ column (property 0x1000)

Rem ==========================================================================


create or replace view STRADDLING_TS_OBJECTS 
    (OBJECT1,TS1,OBJECT2,TS2,REASON_ID,MESG_ID) 
as
/* check whether base table and lob segment are in different tablespaces */
/* Exclude iots */
(select t.obj#, t.ts#, l.lobj#, l.ts#,'Base table and lob object not fully contained in pluggable set',1
from  tab$ t, lob$ l
where l.ts#!=t.ts# 
  and l.obj#=t.obj#
  and bitand(t.property,64)=0)
union all
/* check iots having lobs */
select t.obj#,i.ts#,l.lobj#, l.ts#,'Base table and lob object not fully contained in pluggable set',41
from  tab$ t, lob$ l, ind$ i
where bitand(t.property,64)!=0
  and l.ts#!=i.ts# 
  and l.obj#=t.obj#
  and i.bo# = t.obj#
union all
/* check that iot and overflow segment are in same tablespace */
/* the following will capture the IOT table */
select t.obj#, t.ts#, i.obj#, i.ts#, 'IOT and Overflow segment not self contained',30
from   tab$ t, ind$ i
where  t.bobj# = i.bo#
  and  t.ts# !=  i.ts#
  and  bitand(t.property,512) != 0
union all
/* 
   Are there dependencies between objects in different tablespaces that 
   are enforced through constraints, also ignore constraints that are 
   disabled
   Exclude IOTs (property 0x40) and partitioned (property 0x20) tables 
   since their tablespace # is always 0. These have to be checked 
   separately.
*/
select t.obj#,t.ts#,cdef$.obj#,t2.ts#,'Constraint between tables not contained in pluggable set',2
from tab$ t2,cdef$, tab$ t
where cdef$.robj#=t.obj# 
  and cdef$.obj#=t2.obj#
  and t.ts# != t2.ts#
  and cdef$.enabled is not null
  and bitand(t.property,96)=0
  and bitand(t2.property,96)=0
union all
/* 
Check for a table constraint referencing a iot 
*/ 
select rt.obj#,i.ts#,cdef$.obj#,bt.ts#,'A table has a constraint on a IOT that is not contained in pluggable set', 2
from tab$ bt, cdef$, tab$ rt, ind$ i
where cdef$.robj# = rt.obj#
  and cdef$.obj#  = bt.obj#
  and i.bo#       = rt.obj#
  and i.ts#      != bt.ts#
  and cdef$.enabled is not null
  and bitand(rt.property,64)!= 0
union all
/* tables whose indexes are not in the same tablespace. Ignore partitioned
   objects , they are checked for separately. Also don't check for indexes
   on any unsupported TSPITR objects, also ignore indexes enforcing primary 
   key constraints and unique constraints, these are checked for separately */
/* Exclude iots */
/* For domain indexes we do separate checks so ignore those here */
select t.obj# object1, t.ts# ts1, i.obj# object2, i.ts# ts2, 'Tables and associated indexes not fully contained in the pluggable set',3
from  tab$ t, ind$ i
where t.obj#=i.bo# 
  and t.ts# != i.ts#
  and bitand(t.property,32) = 0
  and bitand(i.property,2) =0
  and bitand(t.property, 131072)=0
  and bitand(t.property,64)=0
  and i.type# != 9
minus  /* indexes enforcing primary key constraints */
/* fix bug 860417 - exclude partitioned objects */
/* bug 1167617    - exclude indexes enforcing unique key constraints */
select t.obj# object1, t.ts# ts1, i.obj# object2, i.ts# ts2, 'Tables and associated indexes not fully contained in the pluggable set',3
from  tab$ t, ind$ i , cdef$ cf
where t.obj#=cf.obj#
  and i.obj#=cf.enabled
  and cf.type# in( 2,3) 
  and t.ts# != i.ts#
  and i.bo#=t.obj#
  and bitand(t.property,32)= 0 
union all
/* The tablespace for partitioned tables defaults to 0 and thus there will   */
/* always be a violation */
select t.obj# object1, t.ts# ts1, i.obj# object2, i.ts# ts2, 'Table and Index enforcing primary key/unique key constraint not in same tablespace',4
from  tab$ t, ind$ i , cdef$ cf
where t.obj#=cf.obj#
  and i.obj#=cf.enabled
  and cf.type# in (2,3) 
  and t.ts# != i.ts#
  and i.bo#=t.obj#
  and bitand(t.property,64)=0
  and bitand(t.property,32)= 0
union all
/* clusters whose indexes are not in the same tablespace */
select c.obj# object1, c.ts# ts1, i.obj# object2, i.ts# ts2,'Tables/Clusters and associated indexes not fully contained in the pluggable set',5
from clu$ c, ind$ i
where c.obj#=i.bo# 
  and c.ts# != i.ts#
union all
/* partitioned tables with at least two partitions in different tablespaces */
select tp1.obj#, tp1.ts#, tp.obj#, tp.ts#, ' Partitioned Objects not fully contained in the pluggable set',6
from tabpart$ tp, 
     (select  bo#, 
              min(ts#) keep (dense_rank first order by part#) ts#,
              min(file#) keep (dense_rank first order by part#) file#,
              min(block#) keep (dense_rank first order by part#) block#,
              min(obj#) keep (dense_rank first order by part#) obj#
      from     tabpart$
      where file# != 0 and block# != 0
      group by bo#) tp1
where tp1.bo# = tp.bo#
  and tp1.ts# != tp.ts#
  and tp.file# !=0
  and tp.block# !=0
union all
/* partitioned indexes that are in tablespace different than any table 
   partitions, Exclude partitioned iots - no storage (check for null header)
*/
select tp1.obj#,tp1.ts#,ip.obj#,ip.ts#, '  Partitioned Objects not fully contained in the pluggable set',7
from indpart$ ip, ind$ i,
     (select   bo#, 
               min(ts#) keep (dense_rank first order by part#) ts#,
               min(file#) keep (dense_rank first order by part#) file#,
               min(block#) keep (dense_rank first order by part#) block#,
               min(obj#) keep (dense_rank first order by part#) obj#
      from     tabpart$
      where    file# != 0 and block# != 0
      group by bo#) tp1
where tp1.bo# = i.bo#
  and ip.bo#  = i.obj#
  and tp1.ts# != ip.ts#
union all
/* partitioned table and non-partitioned index in different tablespaces */ 
select tp.obj#, tp.ts#, i.obj#, i.ts#, ' Partitioned Objects not fully contained in the pluggable set',8
from tabpart$ tp, ind$ i
where tp.ts#!=i.ts#
  and bitand(i.property,2) =0
  and tp.bo#=i.bo#
union all
/*  partitioned index and non-partitioned table in different tablespaces */
select t.obj#, t.ts#, ip.obj#, ip.ts#, ' Partitioned Objects not fully contained in the pluggable set',9
from indpart$ ip, tab$ t, ind$ i
where ip.ts#!=t.ts#
  and t.property=0
  and ip.bo#=i.obj#
  and i.bo#=t.obj#
union all
/* Handle Composite partitions */
/* Subpartitions that are not in the same tablespace */
/* Check the tablespace of the first subpartition of partition 1
   against all tablespaces of other subpartitions for the same object */ 
select V1.obj#, V1.ts# , V2.obj#, V2.ts#, 'Subpartitions not fully contained in Transportable Set',15
from
      ( select   min(tsp.obj#) keep (dense_rank first 
                   order by tcp.part#, tsp.subpart#) obj#,
                 min(tsp.ts#) keep (dense_rank first 
                   order by tcp.part#, tsp.subpart#) ts#,
                 tcp.bo# bo# 
        from     tabcompart$ tcp, tabsubpart$ tsp 
        where    tsp.pobj# = tcp.obj#
        group by tcp.bo#) V1,
      ( select tsp.obj#,ts#,tcp.bo# 
        from   tabcompart$ tcp, tabsubpart$ tsp 
        where  tsp.pobj# = tcp.obj#) V2
where
      V1.bo# = V2.bo#
  and V1.ts# != V2.ts#
union all
/* Make sure that composite table partitions and index composite partitions 
   are in the same tablespace */
select V3.obj#,V3.ts#,V4.obj#,V4.ts#, 'Table subpartition and index subpartition not fully contained in the Transportable Set',16
from
      ( select   min(tsp.obj#) keep (dense_rank first 
                   order by tcp.part#, tsp.subpart#) obj#,
                 min(tsp.ts#) keep (dense_rank first 
                   order by tcp.part#, tsp.subpart#) ts#,
                 tcp.bo# bo# 
        from     tabcompart$ tcp, tabsubpart$ tsp 
        where    tsp.pobj# = tcp.obj#
        group by tcp.bo#) V3,
      ( select isp.obj#,ts#,icp.bo# 
         from  indcompart$ icp, indsubpart$ isp 
         where isp.pobj# = icp.obj#) V4, ind$ i
where
        i.bo#  =  V3.bo# 
  and   V4.bo# =  i.obj# 
  and   V4.ts# != V3.ts#
union all
select lf.fragobj#,lf.ts#, tp.obj#,tp.ts#,'Table partition and lob fragment not in Transportable Set',17
from   lobfrag$ lf, tabpart$ tp
where  lf.tabfragobj# = tp.obj# 
  and  tp.ts# !=lf.ts# 
  union all
/* Subpartitions having lob fragments */
select tsp.obj#,tsp.ts#,lf.fragobj#,lf.ts#,'Table Subpartition and lob fragment not fully contained in pluggable set',18
from tabsubpart$ tsp, lobfrag$ lf
where tsp.obj# = lf.tabfragobj#
  and tsp.ts# != lf.ts#
union all
/* Objects that are not supported 
        tab$.property
          - 0x20000 = AQs  
*/
/* Extract all objects that have the above violations
   Need to hit all objects that have storage
   Tables, IOTs, Partitions, Subpartitions 
*/
/* 8.0 compatible AQ with multiple recipients */
select t.obj#, t.ts#, -1, -1 , 'Object not allowed in Pluggable Set',10
from sys.dba_queue_Tables q, obj$ o, user$ u, tab$ t
where q.recipients = 'MULTIPLE'
  and substr(q.compatible,1,3) = '8.0'
  and q.queue_table = o.name
  and q.owner = u.name
  and u.user# = o.owner#
  and o.obj# = t.obj#
union all
/*
   Capture tables having scoped REF constraints in different tablespace.
   t.property  8 (0x08) -> has REF column.
   Note that this is a one-way dependency.
*/
SELECT t2.obj#, t2.ts#, o.obj#, t.ts#, 
       'based table and its scoped REF object are in different tablespaces',
       44
FROM   tts_obj_view o, tts_tab_view t, refcon$ c, 
       tts_obj_view o2, tts_tab_view t2
WHERE  o.obj#=t.obj# AND c.obj#=o.obj# 
       AND c.stabid=o2.oid$ AND BITAND(c.reftyp,1) != 0 AND o2.obj#=t2.obj#
       AND t.ts# != t2.ts# AND BITAND(t.property, 8)=8
UNION ALL
/* 
   Join indexes are allowed. The logging tables of join indexes are used
   during a transaction for updating purpose. They are not relevant for
   TTS since TTS  are made read-only.
   Note that this is a one-way dependency.
*/
SELECT o1.obj#, t1.ts#, o2.obj#, t2.ts#, 
       'Tables of the join index are not in the same tablespace',43
FROM   tts_obj_view o1, tts_obj_view o2, jijoin$ j, 
       tts_tab_view t1, tts_tab_view t2
WHERE  j.tab1obj#=o1.obj# AND j.tab2obj#=o2.obj#
       AND o1.obj#=t1.obj# AND o2.obj#=t2.obj#
       AND t1.ts# != t2.ts#
UNION ALL
/****************************************************/
/*                                                  */
/* Don't allow objects owned by SYS                 */     
/*                                                  */
/****************************************************/
/* Capture non-partitioned tables owned by SYS */
select o.obj#, t.ts#,-1,-1, 'Sys owned tables not allowed in Transportable Set',19
from tab$ t, obj$ o
where t.obj# = o.obj#
 and bitand(t.property,32) = 0
 and o.owner# = 0
union all
/* Capture partitioned tables owned by SYS */
select o.obj#, tp.ts#,-1,-1, 'Sys owned partitions not allowed in Transportable Set',20
from tabpart$ tp, obj$ o
where tp.obj# = o.obj#
  and o.owner# = 0
union all
/* Capture clusters owned by SYS */
select o.obj#, c.ts#,-1,-1, 'Sys owned clusters not allowed in Transportable Set',21
from clu$ c, obj$ o
where c.obj# = o.obj#
  and o.owner# = 0
union all
/* Capture subpartitions owned by SYS */
select o.obj#, tsp.ts#,-1,-1, 'Sys owned subpartitions not allowed in Transportable Set',22
from tabsubpart$ tsp, obj$ o
where tsp.obj# = o.obj#
  and o.owner# = 0
union all
/* Capture non-partitioned indexes owned by SYS */
select o.obj#, i.ts#,-1,-1, 'Sys owned indexes not allowed in Transportable Set',23
from ind$ i, obj$ o
where i.obj# = o.obj#
  and o.owner# = 0
  and bitand(i.property,2) =0
union all
/* Capture partitioned indexes owned by SYS */
select o.obj#, ip.ts#,-1,-1, 'Sys owned partitioned indexes not allowed in Transportable Set',24
from indpart$ ip, obj$ o
where ip.obj# = o.obj#
  and o.owner# = 0
union all
/* Capture subpartitioned indexes owned by SYS */
select o.obj#, isp.ts#,-1,-1, 'Sys owned subpartitioned indexes not allowed in Transportable Set',25
from indsubpart$ isp, obj$ o
where isp.obj# = o.obj#
  and o.owner# = 0
union all
/* Capture SYS owned lobs */
select l.lobj#, l.ts#,-1,-1, 'Sys owned lobs not allowed in Transportable Set',26
from lob$ l, obj$ o
where l.lobj# = o.obj#
  and o.owner# = 0
union all
/* Capture partitioned lobs */
select lf.fragobj#, lf.ts#,-1,-1, 'Sys owned lob fragments not allowed in Transportable Set',27
from lobfrag$ lf, obj$ o
where lf.fragobj# = o.obj#
  and o.owner# = 0
union all
/* PL/SQL Functional Indexes not supported */
select i.obj#,i.ts#,-1,-1,'PLSQL Functional Indexes not allowed in Transportable Set',29
from ind$ i
   where bitand(i.property, 2048) = 2048
union all
/* the following cases ensure that default storage for a partitioned object
   is also part of the transportable set.  If not, then the pseudo create
   at the target will fail if the default tablespace doesn't exist 
   Logical partitions are being excluded since they don't occupy storage */
/* Exclude logical partitions */
/* Ensure that the default partition  tablespace for  table partitions is self contained */
select po.obj#, defts#, tp.obj#, tp.ts#, 'Default tablespace and partition not selfcontained',33
from tabpart$ tp, partobj$ po
where po.obj# = tp.bo# 
  and po.defts# != tp.ts#
  and tp.block#!=0
  and tp.file# !=0
union all
/* Ensure that the default partition  tablespace for index partitions is self contained */
select po.obj#, defts#, ip.obj#, ip.ts#, 'Default tablespace and partition not selfcontained',34
from ind$ i, indpart$ ip, partobj$ po
where po.obj# = ip.bo# 
  and po.defts# != ip.ts#
  and i.obj# = ip.bo#
  and i.type# != 9
union all
/* Ensure that the default partition tablespace for subpartitions is self contained for Tables */
select tcp.obj#, defts#, tsp.obj#, tsp.ts#, 'Default tablespace and partition not selfcontained',35
from tabcompart$ tcp, tabsubpart$ tsp
where tcp.obj# = tsp.pobj# 
  and tcp.defts# != tsp.ts#
union all
/* Ensure that the default partition tablespace for subpartitions is self contained for Indexes */
select icp.obj#, defts#, isp.obj#, isp.ts#, 'Default tablespace and partition not selfcontained',36
from indcompart$ icp, indsubpart$ isp
where icp.obj# = isp.pobj# 
  and icp.defts# != isp.ts#
union all
/* Default for partitioned object  and table subpartition are self contained */
select po.obj#, po.defts#, tcp.obj#, tcp.defts#, 'Default tablespace and partition not selfcontained',37
from tabcompart$ tcp, partobj$ po
where tcp.bo# = po.obj#
  and tcp.defts# != po.defts#
union all
/* Default for partitioned object  and index subpartition are self contained */
select po.obj#, po.defts#, icp.obj#, icp.defts#, 'Default tablespace and partition not selfcontained',38
from indcompart$ icp, partobj$ po
where icp.bo# = po.obj#
  and icp.defts# != po.defts#
union all
/* Make sure that for IOTs the index partitions are all self contained */
select ip1.obj#, ip1.ts#, ip2.obj#, ip2.ts# ,' IOT partitions not self 
contained', 39 
from (select   bo#, 
               min(ts#) keep (dense_rank first order by part#) ts#,
               min(obj#) keep (dense_rank first order by part#) obj#
      from     indpart$
      group by bo#) ip1, indpart$ ip2, ind$ i, tab$ t
where ip1.bo#= i.obj# 
and ip1.ts# != ip2.ts#
and ip2.bo# = i.obj#
and i.bo# = t.obj#
and bitand(t.property,64)!=0
union all
/* Make sure that for IOTs, overflow segments and index partitions are self
contained. We can take the first overflow segment partition and run it against
all the index partitions.  This guarantees completeness since all index
partitions are checked for seperately for self containment */
select tp.obj#, tp.ts#,ip.obj#,ip.ts#, ' Overflow and index partition not self contained',40
from   indpart$ ip, ind$ i, tab$ t,
       (select  bo#, 
                min(ts#) keep (dense_rank first order by part#) ts#,
                min(obj#) keep (dense_rank first order by part#) obj#
        from     tabpart$
        group by bo#) tp
where  tp.bo# = t.obj#
  and  bitand(t.property,512)!=0
  and  t.bobj# = i.bo# 
  and  ip.bo#= i.obj#
  and  ip.ts# != tp.ts#
/****************************************************/
/* Disallow evolved type data that have not been    */
/* upgraded.                                        */
/****************************************************/
union all
select o.obj#, t.ts#,-1,-1, 'Evolved type data that have not been upgraded are not allowed in a Transportable Set',45
from coltype$ c, obj$ o, tts_tab_view t 
where o.obj#=c.obj# and t.obj#=o.obj# and bitand(c.flags, 256) != 0 
union all
/* Tables with encrypted columns not supported */
select t.obj#,t.ts#,-1,-1,'Tables with encrypted columns not allowed in Transportable Set',46
from tab$ t, tts_obj_view o
where t.obj# = o.obj# and
      bitand(t.trigflag, 65536) = 65536
;

grant select on STRADDLING_TS_OBJECTS to SELECT_CATALOG_ROLE;


Rem =============================================================================
Rem                                                                             #
Rem      VIEW NAME     TS_PLUG_INFO                                             #
Rem                                                                             #
Rem =============================================================================

/* need to exclude recyclebin objects by checking obj$.flags mask 128 */

create or replace view TS_PLUG_INFO 
       (OBJ1_OWNER,OBJ1_NAME,OBJ1_SUBNAME,OBJ1_TYPE,TS1_NAME,
        OBJ2_NAME,OBJ2_SUBNAME,OBJ2_TYPE,OBJ2_OWNER,TS2_NAME,
        CONSTRAINT_NO,REASON,MESG_ID)
as
select u.name owner,o1.name,o1.subname,
       decode(o1.type#,0, 'NEXT OBJECT', 1, 'INDEX',
                          2, 'TABLE', 3, 'CLUSTER',
                          4, 'VIEW', 5, 'SYNONYM', 6, 'SEQUENCE',
                          7, 'PROCEDURE', 8, 'FUNCTION', 9, 'PACKAGE',
                          11, 'PACKAGE BODY', 12, 'TRIGGER',
                          13, 'TYPE', 14, 'TYPE BODY',
                          19, 'TABLE PARTITION', 20, 'INDEX PARTITION',
                          21, 'LOB', 22, 'LIBRARY', 23, 'DIRECTORY',
                          28, 'JAVA SOURCE', 29, 'JAVA CLASS',
                          30, 'JAVA RESOURCE', 34, 'TABLE SUBPARTITION', 
                          40, 'LOB', 56, 'JAVA DATA', '         '),
        ts1.name,o2.name,o2.subname, 
        decode(o2.type#, 0, 'NEXT OBJECT', 1, 'INDEX',
                          2, 'TABLE', 3, 'CLUSTER',
                          4, 'VIEW', 5, 'SYNONYM', 6, 'SEQUENCE',
                          7, 'PROCEDURE', 8, 'FUNCTION', 9, 'PACKAGE',
                          11, 'PACKAGE BODY', 12, 'TRIGGER',
                          13, 'TYPE', 14, 'TYPE BODY',
                          19, 'TABLE PARTITION', 20, 'INDEX PARTITION',
                          21, 'LOB', 22, 'LIBRARY', 23, 'DIRECTORY',
                          28, 'JAVA SOURCE', 29, 'JAVA CLASS',
                          30, 'JAVA RESOURCE', 34,'TABLE SUBPARTITION', 
                          40, 'LOB', 56, 'JAVA DATA', '         '),
        o2.owner#,ts2.name,cf.con#,s.reason_id,mesg_id
from straddling_ts_objects s, obj$ o1, obj$ o2, ts$ ts1, ts$ ts2 , user$ u,cdef$ cf
where s.object1=o1.obj# 
  and s.object2=o2.obj#(+)
  and s.ts1=ts1.ts#
  and s.ts2=ts2.ts#(+)
  and o1.owner#=u.user#
  and s.object2=cf.obj#(+)
  and bitand(o1.flags, 128)=0
  and (o2.flags is null or bitand(o2.flags, 128)=0)
union all
/* capture undo segs in transportable set */
select 'SYS', u.name, NULL, 'ROLLBACK SEGMENT', ts.name,NULL , NULL, NULL,-1, NULL,-1,'Rollback Segment not allowed in transportable set', 32 
from   undo$ u, ts$ ts
where  u.ts# = ts.ts# 
  and  ts.ts# != 0
  and  u.status$ != 1;


grant select on TS_PLUG_INFO to SELECT_CATALOG_ROLE;

Rem ===========================================================================
Rem                                                                           #
Rem     VIEW NAME       UNI_PLUGGABLE_SET_CHECK                               #
Rem                                                                           #
Rem ===========================================================================



create or replace view UNI_PLUGGABLE_SET_CHECK
        (OBJ1_OWNER,OBJ1_NAME,OBJ1_SUBNAME,OBJ1_TYPE,TS1_NAME,
         OBJ2_NAME,OBJ2_SUBNAME,OBJ2_TYPE,OBJ2_OWNER,TS2_NAME,
         CONSTRAINT_NAME,REASON,MESG_ID)
as
   select obj1_owner,obj1_name,obj1_subname,obj1_type,ts1_name,
          obj2_name,obj2_subname,obj2_type,u.name,nvl(ts2_name,'-1'),
          c.name,reason,mesg_id
   from  ts_plug_info t, user$ u, con$ c
   where u.user#(+)=t.obj2_owner
   and   c.con#(+)=t.constraint_no ;



Rem ===========================================================================
Rem                                                                           #
Rem     VIEW NAME       PLUGGABLE_SET_CHECK                                   #
Rem                                                                           #
Rem ===========================================================================


Rem Create the main view as a self union of UNI_PLUGGABLE_SET_CHECK so that we
Rem can capture dependencies in either direction

create or replace view PLUGGABLE_SET_CHECK
        (OBJ1_OWNER,OBJ1_NAME,OBJ1_SUBNAME,OBJ1_TYPE,TS1_NAME,
         OBJ2_NAME,OBJ2_SUBNAME,OBJ2_TYPE,OBJ2_OWNER,TS2_NAME,
         CONSTRAINT_NAME,REASON,MESG_ID)
as
    select * from UNI_PLUGGABLE_SET_CHECK
union all
    select OBJ2_OWNER,OBJ2_NAME,OBJ2_SUBNAME,OBJ2_TYPE,TS2_NAME,
           OBJ1_NAME,OBJ1_SUBNAME,OBJ1_TYPE,OBJ1_OWNER,TS1_NAME,
           CONSTRAINT_NAME,REASON,MESG_ID
    from  UNI_PLUGGABLE_SET_CHECK
    where obj1_type in ('TABLE PARTITION','LOB','TABLE',
                        'TABLE SUBPARTITION') and  
          obj2_type in ('TABLE PARTITION','LOB','TABLE',
                        'TABLE SUBPARTITION') 
      and mesg_id not in (2, 43, 44) or mesg_id in (30);

/* Note that we skip 2, 43, 44 since they are one-way  dependencies. */
/* mesg_id 30 is the IOT and overflow straddling, a two-way dependency */

grant select on PLUGGABLE_SET_CHECK to SELECT_CATALOG_ROLE;

Rem============================================================================
