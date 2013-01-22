rem
rem $Header: catprc.sql 16-apr-2003.19:53:44 weiwang Exp $
rem
Rem Copyright (c) 1990, 2003, Oracle Corporation.  All rights reserved.  
Rem NAME
Rem    CATPRC.SQL
Rem FUNCTION
Rem    Creates data dictionary views for types, stored procedures,
Rem    and triggers.
Rem NOTES
Rem    Must be run while connected to sys or internal.
Rem
Rem MODIFIED
Rem     weiwang    04/16/03  - fix xxx_trigger_cols
Rem     weiwang    02/26/03  - fix all_triggers
Rem     gviswana   12/04/02  - Fix *_DEPENDENCIES for fine-grain deps
Rem     rpang      12/10/02  - Allow source access with debug privilege
Rem     sagrawal   10/15/02  - PL/SQL Compiler warnings
Rem     desinha    10/17/02  - 2603393: *_source should check latest type
Rem     mkrishna   11/07/02  - add XMLSchema to user_dependencies
Rem     nlee       07/11/02  - Add RULE, RULE SET in *_DEPENDENCIES
Rem     nlee       07/11/02  - Add EVALUATION CONTXT in *_DEPENDENCIES
Rem     kamble     05/22/02  - Add OPERATOR, INDEXTYPE in *_DEPENDENCIES
Rem     kamble     05/22/02  - Add LIBRARY in *_DEPENDENCIES
Rem     lvbcheng   10/30/01  - 2077821
Rem     tfyu       07/13/01  - bug 1704085
Rem     gviswana   05/24/01  - CREATE AND REPLACE SYNONYM
Rem     kamble     05/24/01  - Add DIMENSION in *_DEPENDENCIES
Rem     htseng     04/12/01  - eliminate execute twice.
Rem     sbedarka   09/12/00  - #(793824) complete this fix fully
Rem     kosinski   08/07/00 -  Add type 13 to priv 12 check for all_errors
Rem     phchang    07/17/00 -  #(696462) dba_keepsizes does not show triggers
Rem     shihliu    06/01/00  - add suspend event for trigers
Rem     emagrath   07/08/99 -  Correct output of DDL events in trigger views
Rem     mjungerm   06/15/99 -  add java shared data object type
Rem     pmothkur   07/01/99 -  (793824): ALL_ERRORS view should have LIBRARY ty
Rem     weiwang    02/25/99 -  change trigger views to support more events
Rem     atsukerm   09/30/98 -  change trigger views because of new property bit
Rem     weiwang    07/08/98 -  change trigger views for system triggers
Rem     mkrishna   07/09/98 -  change trigger views
Rem     rguzman    06/16/98 -  Add support for dimensions to xxx_ERRORS
Rem     weiwang    05/18/98 -  change trigger views
Rem     akalra     05/14/98 -  Add views *_INTERNAL_TRIGGERS
Rem     najain     04/30/98 -  rewrite all_triggers, dba_triggers, user_trigger
Rem     mkrishna   04/28/98 -  change nested table trigger views
Rem     weiwang    04/16/98 -  change trigger views for system triggers
Rem     mkrishna   03/31/98  - add nested table trigger defns                  
Rem     thoang     12/15/97 -  Modified views to exclude unused columns
Rem     mjungerm   11/07/97 -  Add Java
Rem     nireland   09/04/97 -  Remove leading tab which caused #524252
Rem     skaluska   03/28/97 -  Expose property in dependency$
Rem     tcheng     08/25/96 -  fix user_triggers for instead-of trigger
Rem     gpongrac   06/28/96 -  add comments about disk_and_fixed_objects
Rem     jwijaya    06/14/96 -  check for EXECUTE ANY TYPE
Rem     tpystyne   06/01/96 -  change type to type#
Rem     mmonajje   05/22/96 -  Replace SQL92 RW col name with <col name>#
Rem     gpongrac   05/20/96 -  change dependencies views to be aware of fixed o
Rem     asurpur    04/08/96 -  Dictionary Protection Implementation
Rem     jwijaya    09/26/95 -  mergetrans jwijaya_data_dict_views_for_objects
Rem     jwijaya    09/21/95 -  support ADTs/objects
Rem     mramache   03/13/95 -  user_errors now handles triggers
Rem     wmaimone   05/26/94 -  #186155 add public synoyms for dba_
Rem     jbellemo   05/09/94 -  merge changes from branch 1.2.710.2
Rem     jbellemo   12/17/93 -  merge changes from branch 1.2.710.1
Rem     jbellemo   04/27/94 -  #199905: fix security in ALL_ERRORS
Rem     jbellemo   11/09/93 -  #170173: change uid to userenv schemaid
Rem     tpystyne   10/28/92 -  use create or replace view 
Rem     glumpkin   10/20/92 -  Renamed from PRCTRG.SQL 
Rem     mmoore     10/15/92 - #(131033) add trigger column views for marketing 
Rem     mmoore     09/29/92 - #(131033) add more info to the triggers view 
Rem     jwijaya    08/17/92 -  add sequence to error$ 
Rem     jwijaya    07/17/92 -  remove database link owner from name 
Rem     mmoore     06/03/92 - #(111923) change trigger view names 
Rem     mmoore     06/02/92 - #(96526) remove v$enabledroles 
Rem     mroberts   06/01/92 -  change privileges for all_errors view 
Rem     rkooi      04/15/92 -  test tools 
Rem     rkooi      01/18/92 -  add synonym 
Rem     rkooi      01/18/92 -  add object_sizes views 
Rem     rkooi      01/10/92 -  synchronize with catalog.sql 
Rem     rkooi      12/23/91 -  testing 
Rem     rkooi      10/20/91 -  add public_dependency 
Rem     jwijaya    07/14/91 -  remove LINKNAME IS NULL 
Rem     rkooi      05/22/91 -  get rid of _object in some catalog names 
Rem     rkooi      05/22/91 - change *_references to *_dependencies
Rem     rkooi      05/05/91 - fix up permissions on all* cats 
Rem     jwijaya    04/12/91 - remove LINKNAME IS NULL 
Rem     rkooi      03/29/91 - add views for pcode & diana 
Rem     Kooi       03/12/91 - Creation
Rem     Kooi       03/12/91 - Creation
Rem

remark    This view is needed for the DEPENDENCIES views.  It is not needed
remark    anywhere else and is not documented.  There is no need to grant
remark    access to this view to other users/roles.

create or replace view DISK_AND_FIXED_OBJECTS
(obj#, owner#, name, type#, remoteowner, linkname)
as
select obj#, owner#, name, type#, remoteowner, linkname
from sys.obj$
union all
select kobjn_kqfp, 0, name_kqfp,
decode(type_kqfp, 1, 9, 2, 11, 3, 10, 0), NULL, NULL
from sys.x$kqfp
union all
select kqftaobj, 0, kqftanam, 2, NULL, NULL
from sys.x$kqfta
union all
select kqfviobj, 0, kqfvinam, 4, NULL, NULL
from sys.x$kqfvi
/

remark
remark    FAMILY "ERRORS"
remark    Errors for stored objects - currently these are types, type bodies,
remark    PL/SQL packages, package bodies, procedures and functions.
remark

create or replace view USER_ERRORS
(NAME, TYPE, SEQUENCE, LINE, POSITION, text, attribute, message_number)
as
select o.name,
decode(o.type#, 4, 'VIEW', 7, 'PROCEDURE', 8, 'FUNCTION', 9, 'PACKAGE',
               11, 'PACKAGE BODY', 12, 'TRIGGER', 13, 'TYPE', 14, 'TYPE BODY',
               22, 'LIBRARY', 28, 'JAVA SOURCE', 29, 'JAVA CLASS',
               43, 'DIMENSION', 'UNDEFINED'),
  e.sequence#, e.line, e.position#, e.text,
  decode(e.property, 0,'ERROR', 1, 'WARNING', 'UNDEFINED'), e.error#
from sys.obj$ o, sys.error$ e
where o.obj# = e.obj#
  and o.type# in (4, 7, 8, 9, 11, 12, 13, 14, 22, 28, 29, 43)
  and o.owner# = userenv('SCHEMAID')
/
comment on table USER_ERRORS is
'Current errors on stored objects owned by the user'
/
comment on column USER_ERRORS.NAME is
'Name of the object'
/
comment on column USER_ERRORS.TYPE is
'Type: "TYPE", "TYPE BODY", "VIEW", "PROCEDURE", "FUNCTION",
"PACKAGE", "PACKAGE BODY", "TRIGGER",
"JAVA SOURCE" or "JAVA CLASS"'
/
comment on column USER_ERRORS.SEQUENCE is
'Sequence number used for ordering purposes'
/
comment on column USER_ERRORS.LINE is
'Line number at which this error occurs'
/
comment on column USER_ERRORS.POSITION is
'Position in the line at which this error occurs'
/
comment on column USER_ERRORS.TEXT is
'Text of the error'
/
create or replace public synonym USER_ERRORS for USER_ERRORS
/
grant select on USER_ERRORS to public with grant option
/

remark
remark  User is allowed to see errors on any object that they own
remark  or could have created.
remark

create or replace view ALL_ERRORS
(OWNER, NAME, TYPE, SEQUENCE, LINE, POSITION, text, attribute, message_number)
as
select u.name, o.name,
decode(o.type#, 4, 'VIEW', 7, 'PROCEDURE', 8, 'FUNCTION', 9, 'PACKAGE',
               11, 'PACKAGE BODY', 12, 'TRIGGER', 13, 'TYPE', 14, 'TYPE BODY',
               22, 'LIBRARY', 28, 'JAVA SOURCE', 29, 'JAVA CLASS', 
               43, 'DIMENSION', 'UNDEFINED'),
  e.sequence#, e.line, e.position#, e.text,
   decode(e.property, 0,'ERROR', 1, 'WARNING', 'UNDEFINED'), e.error#
from sys.obj$ o, sys.error$ e, sys.user$ u
where o.obj# = e.obj#
  and o.owner# = u.user#
  and o.type# in (4, 7, 8, 9, 11, 12, 13, 14, 22, 28, 29, 43)
  and
  (
    o.owner# in (userenv('SCHEMAID'), 1 /* PUBLIC */)
    or
    (
      (
        (
          (o.type# = 7 or o.type# = 8 or o.type# = 9 or o.type# = 13 or
           o.type# = 28 or o.type# = 29)
          and
          o.obj# in (select obj# from sys.objauth$
                     where grantee# in (select kzsrorol from x$kzsro)
                       and privilege#  = 12 /* EXECUTE */)
        )
        or
        (
          o.type# = 4
          and
          o.obj# in (select obj# from sys.objauth$
                     where grantee# in (select kzsrorol from x$kzsro)
                       and privilege# in (3 /* DELETE */,   6 /* INSERT */,
                                          7 /* LOCK */,     9 /* SELECT */,
                                          10 /* UPDATE */))
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
              (o.type# = 7 or o.type# = 8 or o.type# = 9 or
               o.type# = 28 or o.type# = 29)
              and
              (
                privilege# = -144 /* EXECUTE ANY PROCEDURE */
                or
                privilege# = -141 /* CREATE ANY PROCEDURE */
              )
            )
            or
            (
              /* trigger */
              o.type# = 12 and
              privilege# = -152 /* CREATE ANY TRIGGER */
            )
            or
            (
              /* package body */
              o.type# = 11 and
              privilege# = -141 /* CREATE ANY PROCEDURE */
            )
            or
            (
              /* dimension */
              o.type# = 11 and
              privilege# = -215 /* CREATE ANY DIMENSION */
            )
            or
            (
              /* view */
              o.type# = 4
              and
              (
                privilege# in     ( -91 /* CREATE ANY VIEW */,
                                    -45 /* LOCK ANY TABLE */,
                                    -47 /* SELECT ANY TABLE */,
                                    -48 /* INSERT ANY TABLE */,
                                    -49 /* UPDATE ANY TABLE */,
                                    -50 /* DELETE ANY TABLE */)
              )
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
comment on table ALL_ERRORS is
'Current errors on stored objects that user is allowed to create'
/
comment on column ALL_ERRORS.OWNER is
'Owner of the object'
/
comment on column ALL_ERRORS.NAME is
'Name of the object'
/
comment on column ALL_ERRORS.TYPE is
'Type: "TYPE", "TYPE BODY", "VIEW", "PROCEDURE", "FUNCTION",
"PACKAGE", "PACKAGE BODY", "TRIGGER",
"JAVA SOURCE" or "JAVA CLASS"'
/
comment on column ALL_ERRORS.SEQUENCE is
'Sequence number used for ordering purposes'
/
comment on column ALL_ERRORS.LINE is
'Line number at which this error occurs'
/
comment on column ALL_ERRORS.POSITION is
'Position in the line at which this error occurs'
/
comment on column ALL_ERRORS.TEXT is
'Text of the error'
/
create or replace public synonym ALL_ERRORS for ALL_ERRORS
/
grant select on ALL_ERRORS to public with grant option
/

create or replace view DBA_ERRORS
(OWNER, NAME, TYPE, SEQUENCE, LINE, POSITION, text,attribute, message_number)
as
select u.name, o.name,
decode(o.type#, 4, 'VIEW', 7, 'PROCEDURE', 8, 'FUNCTION', 9, 'PACKAGE',
               11, 'PACKAGE BODY', 12, 'TRIGGER', 13, 'TYPE', 14, 'TYPE BODY',
               22, 'LIBRARY', 28, 'JAVA SOURCE', 29, 'JAVA CLASS',
               43, 'DIMENSION', 'UNDEFINED'),
  e.sequence#, e.line, e.position#, e.text,
  decode(e.property, 0,'ERROR', 1, 'WARNING', 'UNDEFINED'), e.error#
from sys.obj$ o, sys.error$ e, sys.user$ u
where o.obj# = e.obj#
  and o.owner# = u.user#
  and o.type# in (4, 7, 8, 9, 11, 12, 13, 14, 22, 28, 29, 43)
/
create or replace public synonym DBA_ERRORS for DBA_ERRORS
/
grant select on DBA_ERRORS to select_catalog_role
/
comment on table DBA_ERRORS is
'Current errors on all stored objects in the database'
/
comment on column DBA_ERRORS.NAME is
'Name of the object'
/
comment on column DBA_ERRORS.TYPE is
'Type: "TYPE", "TYPE BODY", "VIEW", "PROCEDURE", "FUNCTION",
"PACKAGE", "PACKAGE BODY", "TRIGGER",
"JAVA SOURCE" or "JAVA CLASS"'
/
comment on column DBA_ERRORS.SEQUENCE is
'Sequence number used for ordering purposes'
/
comment on column DBA_ERRORS.LINE is
'Line number at which this error occurs'
/
comment on column DBA_ERRORS.POSITION is
'Position in the line at which this error occurs'
/
comment on column DBA_ERRORS.TEXT is
'Text of the error'
/


remark
remark    FAMILY "SOURCE"
remark    SOURCE for stored objects - currently these are types, type bodies,
remark    PL/SQL packages, package bodies, procedures and functions.
remark

create or replace view USER_SOURCE
(NAME, TYPE, LINE, TEXT)
as
select o.name,
decode(o.type#, 7, 'PROCEDURE', 8, 'FUNCTION', 9, 'PACKAGE',
               11, 'PACKAGE BODY', 12, 'TRIGGER', 13, 'TYPE', 14, 'TYPE BODY',
               'UNDEFINED'),
s.line, s.source
from sys.obj$ o, sys.source$ s
where o.obj# = s.obj#
  and ( o.type# in (7, 8, 9, 11, 12, 14) OR
       ( o.type# = 13 AND o.subname is null))
  and o.owner# = userenv('SCHEMAID')
union all
select o.name, 'JAVA SOURCE', s.joxftlno, s.joxftsrc
from sys.obj$ o, x$joxfs s
where o.obj# = s.joxftobn
  and o.type# = 28
  and o.owner# = userenv('SCHEMAID')
/
comment on table USER_SOURCE is
'Source of stored objects accessible to the user'
/
comment on column USER_SOURCE.NAME is
'Name of the object'
/
comment on column USER_SOURCE.TYPE is
'Type of the object: "TYPE", "TYPE BODY", "PROCEDURE", "FUNCTION",
"PACKAGE", "PACKAGE BODY" or "JAVA SOURCE"'
/
comment on column USER_SOURCE.LINE is
'Line number of this line of source'
/
comment on column USER_SOURCE.TEXT is
'Source text'
/
create or replace public synonym USER_SOURCE for USER_SOURCE
/
grant select on USER_SOURCE to public with grant option
/

create or replace view ALL_SOURCE
(OWNER, NAME, TYPE, LINE, TEXT)
as
select u.name, o.name,
decode(o.type#, 7, 'PROCEDURE', 8, 'FUNCTION', 9, 'PACKAGE',
                11, 'PACKAGE BODY', 12, 'TRIGGER', 13, 'TYPE', 14, 'TYPE BODY',
                'UNDEFINED'),
s.line, s.source
from sys.obj$ o, sys.source$ s, sys.user$ u
where o.obj# = s.obj#
  and o.owner# = u.user#
  and ( o.type# in (7, 8, 9, 11, 12, 14) OR
       ( o.type# = 13 AND o.subname is null))
  and
  (
    o.owner# in (userenv('SCHEMAID'), 1 /* PUBLIC */)
    or
    (
      (
         (
          (o.type# in (7 /* proc */, 8 /* func */, 9 /* pkg */, 13 /* type */))
          and
          o.obj# in (select obj# from sys.objauth$
                     where grantee# in (select kzsrorol from x$kzsro)
                       and privilege# in (12 /* EXECUTE */, 26 /* DEBUG */))
        )
        or
        (
          (o.type# in (11 /* package body */, 14 /* type body */))
          and
          exists
          (
            select null from sys.obj$ specobj, sys.objauth$ oa
            where specobj.owner# = o.owner#
              and specobj.name = o.name
              and specobj.type# = decode(o.type#,
                                         11 /* pkg body */, 9 /* pkg */,
                                         14 /* type body */, 13 /* type */,
                                         null)
              and oa.obj# = specobj.obj#
              and oa.grantee# in (select kzsrorol from x$kzsro)
              and oa.privilege# = 26 /* DEBUG */)
        )
        or
        (
          (o.type# = 12 /* trigger */)
          and
          exists
          (
            select null from sys.trigger$ t, sys.obj$ tabobj, sys.objauth$ oa
            where t.obj# = o.obj#
              and tabobj.obj# = t.baseobject
              and tabobj.owner# = o.owner#
              and oa.obj# = tabobj.obj#
              and oa.grantee# in (select kzsrorol from x$kzsro)
              and oa.privilege# = 26 /* DEBUG */)
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
                or
                privilege# = -241 /* DEBUG ANY PROCEDURE */
              )
            )
            or
            (
              /* package body */
              o.type# = 11 and
              (
                privilege# = -141 /* CREATE ANY PROCEDURE */
                or
                privilege# = -241 /* DEBUG ANY PROCEDURE */
              )
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
                or
                privilege# = -241 /* DEBUG ANY PROCEDURE */
              )
            )
            or
            (
              /* type body */
              o.type# = 14 and
              (
                privilege# = -181 /* CREATE ANY TYPE */
                or
                privilege# = -241 /* DEBUG ANY PROCEDURE */
              )
            )
            or
            (
              /* triggers */
              o.type# = 12 and
              (
                privilege# = -152 /* CREATE ANY TRIGGER */
                or
                privilege# = -241 /* DEBUG ANY PROCEDURE */
              )
            )
          )
        )
      )
    )
  )
union all
select u.name, o.name, 'JAVA SOURCE', s.joxftlno, s.joxftsrc
from sys.obj$ o, x$joxfs s, sys.user$ u
where o.obj# = s.joxftobn
  and o.owner# = u.user#
  and o.type# = 28
  and
  (
    o.owner# in (userenv('SCHEMAID'), 1 /* PUBLIC */)
    or
    (
      (
        (
          o.obj# in (select obj# from sys.objauth$
                     where grantee# in (select kzsrorol from x$kzsro)
                       and privilege# in (12 /* EXECUTE */, 26 /* DEBUG */))
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
              (
                privilege# = -144 /* EXECUTE ANY PROCEDURE */
                or
                privilege# = -141 /* CREATE ANY PROCEDURE */
                or
                privilege# = -241 /* DEBUG ANY PROCEDURE */
              )
            )
          )
        )
      )
    )
  )
/
comment on table ALL_SOURCE is
'Current source on stored objects that user is allowed to create'
/
comment on column ALL_SOURCE.OWNER is
'Owner of the object'
/
comment on column ALL_SOURCE.NAME is
'Name of the object'
/
comment on column ALL_SOURCE.TYPE is
'Type of the object: "TYPE", "TYPE BODY", "PROCEDURE", "FUNCTION",
"PACKAGE", "PACKAGE BODY" or "JAVA SOURCE"'
/
comment on column ALL_SOURCE.LINE is
'Line number of this line of source'
/
comment on column ALL_SOURCE.TEXT is
'Source text'
/
create or replace public synonym ALL_SOURCE for ALL_SOURCE
/
grant select on ALL_SOURCE to public with grant option
/

create or replace view DBA_SOURCE
(OWNER, NAME, TYPE, LINE, TEXT)
as
select u.name, o.name,
decode(o.type#, 7, 'PROCEDURE', 8, 'FUNCTION', 9, 'PACKAGE',
               11, 'PACKAGE BODY', 12, 'TRIGGER', 13, 'TYPE', 14, 'TYPE BODY',
               'UNDEFINED'),
s.line, s.source
from sys.obj$ o, sys.source$ s, sys.user$ u
where o.obj# = s.obj#
  and o.owner# = u.user#
  and ( o.type# in (7, 8, 9, 11, 12, 14) OR
       ( o.type# = 13 AND o.subname is null))
union all
select u.name, o.name, 'JAVA SOURCE', s.joxftlno, s.joxftsrc
from sys.obj$ o, x$joxfs s, sys.user$ u
where o.obj# = s.joxftobn
  and o.owner# = u.user#
  and o.type# = 28
/
create or replace public synonym DBA_SOURCE for DBA_SOURCE
/
grant select on DBA_SOURCE to select_catalog_role
/
comment on table DBA_SOURCE is
'Source of all stored objects in the database'
/
comment on column DBA_SOURCE.NAME is
'Name of the object'
/
comment on column DBA_SOURCE.TYPE is
'Type of the object: "TYPE", "TYPE BODY", "PROCEDURE", "FUNCTION",
"PACKAGE", "PACKAGE BODY" or "JAVA SOURCE"'
/
comment on column DBA_SOURCE.LINE is
'Line number of this line of source'
/
comment on column DBA_SOURCE.TEXT is
'Source text'
/

remark
remark    FAMILY "TRIGGERS"
remark    Database trigger definitions.
remark    This family has no "ALL" member.
remark

create or replace view USER_TRIGGERS
(TRIGGER_NAME, TRIGGER_TYPE, TRIGGERING_EVENT, TABLE_OWNER, BASE_OBJECT_TYPE, 
 TABLE_NAME, COLUMN_NAME , REFERENCING_NAMES, WHEN_CLAUSE, STATUS, 
 DESCRIPTION, ACTION_TYPE, TRIGGER_BODY)
as
select trigobj.name,
decode(t.type#, 0, 'BEFORE STATEMENT',
                1, 'BEFORE EACH ROW',
                2, 'AFTER STATEMENT',
                3, 'AFTER EACH ROW',
                4, 'INSTEAD OF',
                   'UNDEFINED'),
decode(t.insert$*100 + t.update$*10 + t.delete$,
                 100, 'INSERT',
                 010, 'UPDATE',
                 001, 'DELETE',
                 110, 'INSERT OR UPDATE',
                 101, 'INSERT OR DELETE',
                 011, 'UPDATE OR DELETE',
                 111, 'INSERT OR UPDATE OR DELETE',
                 'ERROR'),
u.name, 
decode(bitand(t.property, 1), 1, 'VIEW', 
                              0, 'TABLE',
                                 'UNDEFINED'), 
tabobj.name, NULL,
'REFERENCING NEW AS '||t.refnewname||' OLD AS '||t.refoldname,
t.whenclause,decode(t.enabled, 0, 'DISABLED', 1, 'ENABLED', 'ERROR'),
t.definition,
decode(bitand(t.property, 2), 2, 'CALL',
                                 'PL/SQL     '), 
t.action#
from sys.obj$ trigobj, sys.obj$ tabobj, sys.trigger$ t, sys.user$ u
where   (trigobj.obj#   = t.obj# and 
         tabobj.obj# = t.baseobject and
         trigobj.owner# = userenv('SCHEMAID') 
         and tabobj.owner#  = u.user# 
         and bitand(t.property, 63) < 8) 
union all
select trigobj.name,
decode(t.type#, 0, 'BEFORE EVENT',
                2, 'AFTER EVENT',
                   'UNDEFINED'),
decode(bitand(t.sys_evts, 1), 1, 'STARTUP ') ||
decode(bitand(t.sys_evts, 2), 2, 
       decode(sign(bitand(t.sys_evts, 1)), 1, 'OR SHUTDOWN ',
                                               'SHUTDOWN ')) ||
decode(bitand(t.sys_evts, 4), 4, 
       decode(sign(bitand(t.sys_evts, 3)), 1, 'OR ERROR ',
                                              'ERROR ')) ||
decode(bitand(t.sys_evts, 8), 8,
       decode(sign(bitand(t.sys_evts, 7)), 1, 'OR LOGON ',
                                              'LOGON ')) ||
decode(bitand(t.sys_evts, 16), 16,
       decode(sign(bitand(t.sys_evts, 15)), 1, 'OR LOGOFF ',
                                               'LOGOFF ')) ||
decode(bitand(t.sys_evts, 262176), 32,
       decode(sign(bitand(t.sys_evts, 31)), 1, 'OR CREATE ',
                                               'CREATE ')) ||
decode(bitand(t.sys_evts, 262208), 64,
       decode(sign(bitand(t.sys_evts, 63)), 1, 'OR ALTER ',
                                               'ALTER ')) ||
decode(bitand(t.sys_evts, 262272), 128,
       decode(sign(bitand(t.sys_evts, 127)), 1, 'OR DROP ',
                                                'DROP ')) ||
decode (bitand(t.sys_evts, 262400), 256,
        decode(sign(bitand(t.sys_evts, 255)), 1, 'OR ANALYZE ',
                                                 'ANALYZE ')) ||
decode (bitand(t.sys_evts, 262656), 512,
        decode(sign(bitand(t.sys_evts, 511)), 1, 'OR COMMENT ',
                                                 'COMMENT ')) ||
decode (bitand(t.sys_evts, 263168), 1024,
        decode(sign(bitand(t.sys_evts, 1023)), 1, 'OR GRANT ',
                                                  'GRANT ')) ||
decode (bitand(t.sys_evts, 264192), 2048,
        decode(sign(bitand(t.sys_evts, 2047)), 1, 'OR REVOKE ',
                                                  'REVOKE ')) ||
decode (bitand(t.sys_evts, 266240), 4096,
        decode(sign(bitand(t.sys_evts, 4095)), 1, 'OR TRUNCATE ',
                                                  'TRUNCATE ')) ||
decode (bitand(t.sys_evts, 270336), 8192,
        decode(sign(bitand(t.sys_evts, 8191)), 1, 'OR RENAME ',
                                                  'RENAME ')) ||
decode (bitand(t.sys_evts, 278528), 16384,
        decode(sign(bitand(t.sys_evts, 16383)), 1, 'OR ASSOCIATE STATISTICS ',
                                                   'ASSOCIATE STATISTICS ')) ||
decode (bitand(t.sys_evts, 294912), 32768,
        decode(sign(bitand(t.sys_evts, 32767)), 1, 'OR AUDIT ',
                                                   'AUDIT ')) ||
decode (bitand(t.sys_evts, 327680), 65536,
        decode(sign(bitand(t.sys_evts, 65535)), 1,
               'OR DISASSOCIATE STATISTICS ', 'DISASSOCIATE STATISTICS ')) ||
decode (bitand(t.sys_evts, 393216), 131072,
        decode(sign(bitand(t.sys_evts, 131071)), 1, 'OR NOAUDIT ',
                                                    'NOAUDIT ')) ||
decode (bitand(t.sys_evts, 262144), 262144,
        decode(sign(bitand(t.sys_evts, 31)), 1, 'OR DDL ',
                                                   'DDL ')) ||
decode (bitand(t.sys_evts, 8388608), 8388608,
        decode(sign(bitand(t.sys_evts, 8388607)), 1, 'OR SUSPEND ',
                                                     'SUSPEND ')),
'SYS',
'DATABASE        ',
NULL,
NULL,
'REFERENCING NEW AS '||t.refnewname||' OLD AS '||t.refoldname,
t.whenclause,decode(t.enabled, 0, 'DISABLED', 1, 'ENABLED', 'ERROR'),
t.definition,
decode(bitand(t.property, 2), 2, 'CALL',
                                 'PL/SQL     '), 
t.action#
from sys.obj$ trigobj, sys.trigger$ t
where   (trigobj.obj#   = t.obj# and 
         trigobj.owner# = userenv('SCHEMAID') and 
         bitand(t.property, 63) >= 8 and bitand(t.property, 63) < 16) 
union all
select trigobj.name,
decode(t.type#, 0, 'BEFORE EVENT',
                2, 'AFTER EVENT',
                   'UNDEFINED'),
decode(bitand(t.sys_evts, 1), 1, 'STARTUP ') ||
decode(bitand(t.sys_evts, 2), 2, 
       decode(sign(bitand(t.sys_evts, 1)), 1, 'OR SHUTDOWN ',
                                               'SHUTDOWN ')) ||
decode(bitand(t.sys_evts, 4), 4, 
       decode(sign(bitand(t.sys_evts, 3)), 1, 'OR ERROR ',
                                              'ERROR ')) ||
decode(bitand(t.sys_evts, 8), 8,
       decode(sign(bitand(t.sys_evts, 7)), 1, 'OR LOGON ',
                                              'LOGON ')) ||
decode(bitand(t.sys_evts, 16), 16,
       decode(sign(bitand(t.sys_evts, 15)), 1, 'OR LOGOFF ',
                                               'LOGOFF ')) ||
decode(bitand(t.sys_evts, 262176), 32,
       decode(sign(bitand(t.sys_evts, 31)), 1, 'OR CREATE ',
                                               'CREATE ')) ||
decode(bitand(t.sys_evts, 262208), 64,
       decode(sign(bitand(t.sys_evts, 63)), 1, 'OR ALTER ',
                                               'ALTER ')) ||
decode(bitand(t.sys_evts, 262272), 128,
       decode(sign(bitand(t.sys_evts, 127)), 1, 'OR DROP ',
                                                'DROP ')) ||
decode (bitand(t.sys_evts, 262400), 256,
        decode(sign(bitand(t.sys_evts, 255)), 1, 'OR ANALYZE ',
                                                 'ANALYZE ')) ||
decode (bitand(t.sys_evts, 262656), 512,
        decode(sign(bitand(t.sys_evts, 511)), 1, 'OR COMMENT ',
                                                 'COMMENT ')) ||
decode (bitand(t.sys_evts, 263168), 1024,
        decode(sign(bitand(t.sys_evts, 1023)), 1, 'OR GRANT ',
                                                  'GRANT ')) ||
decode (bitand(t.sys_evts, 264192), 2048,
        decode(sign(bitand(t.sys_evts, 2047)), 1, 'OR REVOKE ',
                                                  'REVOKE ')) ||
decode (bitand(t.sys_evts, 266240), 4096,
        decode(sign(bitand(t.sys_evts, 4095)), 1, 'OR TRUNCATE ',
                                                  'TRUNCATE ')) ||
decode (bitand(t.sys_evts, 270336), 8192,
        decode(sign(bitand(t.sys_evts, 8191)), 1, 'OR RENAME ',
                                                  'RENAME ')) ||
decode (bitand(t.sys_evts, 278528), 16384,
        decode(sign(bitand(t.sys_evts, 16383)), 1, 'OR ASSOCIATE STATISTICS ',
                                                   'ASSOCIATE STATISTICS ')) ||
decode (bitand(t.sys_evts, 294912), 32768,
        decode(sign(bitand(t.sys_evts, 32767)), 1, 'OR AUDIT ',
                                                   'AUDIT ')) ||
decode (bitand(t.sys_evts, 327680), 65536,
        decode(sign(bitand(t.sys_evts, 65535)), 1,
               'OR DISASSOCIATE STATISTICS ', 'DISASSOCIATE STATISTICS ')) ||
decode (bitand(t.sys_evts, 393216), 131072,
        decode(sign(bitand(t.sys_evts, 131071)), 1, 'OR NOAUDIT ',
                                                    'NOAUDIT ')) ||
decode (bitand(t.sys_evts, 262144), 262144,
        decode(sign(bitand(t.sys_evts, 31)), 1, 'OR DDL ',
                                                   'DDL ')) ||
decode (bitand(t.sys_evts, 8388608), 8388608,
        decode(sign(bitand(t.sys_evts, 8388607)), 1, 'OR SUSPEND ',
                                                     'SUSPEND ')),
u.name, 
'SCHEMA',
NULL,
NULL,
'REFERENCING NEW AS '||t.refnewname||' OLD AS '||t.refoldname,
t.whenclause,decode(t.enabled, 0, 'DISABLED', 1, 'ENABLED', 'ERROR'),
t.definition,
decode(bitand(t.property, 2), 2, 'CALL',
                                 'PL/SQL     '), 
t.action#
from sys.obj$ trigobj, sys.trigger$ t, sys.user$ u
where   (trigobj.obj#   = t.obj# and 
         trigobj.owner# = userenv('SCHEMAID') and 
         bitand(t.property, 63) >= 16 and bitand(t.property, 63) < 32 and 
         u.user# = t.baseobject)
union all
select trigobj.name,
decode(t.type#, 0, 'BEFORE STATEMENT',
               1, 'BEFORE EACH ROW',
               2, 'AFTER STATEMENT',
               3, 'AFTER EACH ROW',
               4, 'INSTEAD OF',
               'UNDEFINED'),
decode(t.insert$*100 + t.update$*10 + t.delete$,
                 100, 'INSERT',
                 010, 'UPDATE',
                 001, 'DELETE',
                 110, 'INSERT OR UPDATE',
                 101, 'INSERT OR DELETE',
                 011, 'UPDATE OR DELETE',
                 111, 'INSERT OR UPDATE OR DELETE',
                 'ERROR'),
u.name,
decode(bitand(t.property, 1), 1, 'VIEW', 
                              0, 'TABLE',
                                 'UNDEFINED'), 
tabobj.name,  ntcol.name,
'REFERENCING NEW AS '||t.refnewname||' OLD AS '||t.refoldname
  || ' PARENT AS ' || t.refprtname,
t.whenclause,decode(t.enabled, 0, 'DISABLED', 1, 'ENABLED', 'ERROR'),
t.definition,
decode(bitand(t.property, 2), 2, 'CALL',
                                 'PL/SQL     '), 
t.action#
from sys.obj$ trigobj, sys.obj$ tabobj, sys.trigger$ t, sys.user$ u,
     sys.viewtrcol$ ntcol
where   (trigobj.obj#   = t.obj# and 
         tabobj.obj# = t.baseobject and
         trigobj.owner# = userenv('SCHEMAID') 
         and tabobj.owner#  = u.user# 
         and bitand(t.property, 63) >= 32 
         and t.nttrigcol = ntcol.intcol# 
         and t.nttrigatt = ntcol.attribute# 
         and t.baseobject = ntcol.obj#)
/
comment on table USER_TRIGGERS is
'Triggers owned by the user'
/
comment on column USER_TRIGGERS.TRIGGER_NAME is
'Name of the trigger'
/
comment on column USER_TRIGGERS.TRIGGER_TYPE is
'Type of the trigger (when it fires) - BEFORE/AFTER and STATEMENT/ROW'
/
comment on column USER_TRIGGERS.TRIGGERING_EVENT is
'Statement that will fire the trigger - INSERT, UPDATE and/or DELETE'
/
comment on column USER_TRIGGERS.TABLE_OWNER is
'Owner of the table that this trigger is associated with'
/
comment on column USER_TRIGGERS.TABLE_NAME is
'Name of the table that this trigger is associated with'
/
comment on column USER_TRIGGERS.COLUMN_NAME is
'The name of the column on which the trigger is defined over '
/
comment on column USER_TRIGGERS.REFERENCING_NAMES is
'Names used for referencing to OLD, NEW and PARENT values within the trigger'
/
comment on column USER_TRIGGERS.WHEN_CLAUSE is
'WHEN clause must evaluate to true in order for triggering body to execute'
/
comment on column USER_TRIGGERS.STATUS is
'If DISABLED then trigger will not fire'
/
comment on column USER_TRIGGERS.DESCRIPTION is
'Trigger description, useful for re-creating trigger creation statement'
/
comment on column USER_TRIGGERS.TRIGGER_BODY is
'Action taken by this trigger when it fires'
/
create or replace public synonym USER_TRIGGERS for USER_TRIGGERS
/
grant select on USER_TRIGGERS to public with grant option
/
create or replace view ALL_TRIGGERS
(OWNER, TRIGGER_NAME, TRIGGER_TYPE, TRIGGERING_EVENT, TABLE_OWNER, 
 BASE_OBJECT_TYPE, TABLE_NAME, COLUMN_NAME , REFERENCING_NAMES, WHEN_CLAUSE, 
 STATUS, DESCRIPTION, ACTION_TYPE, TRIGGER_BODY)
as
select triguser.name, trigobj.name,
decode(t.type#, 0, 'BEFORE STATEMENT',
                1, 'BEFORE EACH ROW',
                2, 'AFTER STATEMENT',
                3, 'AFTER EACH ROW',
                4, 'INSTEAD OF',
                   'UNDEFINED'),
decode(t.insert$*100 + t.update$*10 + t.delete$,
                 100, 'INSERT',
                 010, 'UPDATE',
                 001, 'DELETE',
                 110, 'INSERT OR UPDATE',
                 101, 'INSERT OR DELETE',
                 011, 'UPDATE OR DELETE',
                 111, 'INSERT OR UPDATE OR DELETE', 'ERROR'),
tabuser.name, 
decode(bitand(t.property, 1), 1, 'VIEW', 
                              0, 'TABLE',
                                 'UNDEFINED'), 
tabobj.name, NULL,
'REFERENCING NEW AS '||t.refnewname||' OLD AS '||t.refoldname,
t.whenclause,decode(t.enabled, 0, 'DISABLED', 1, 'ENABLED', 'ERROR'),
t.definition,
decode(bitand(t.property, 2), 2, 'CALL',
                                 'PL/SQL     '), 
t.action#
from sys.obj$ trigobj, sys.obj$ tabobj, sys.trigger$ t, sys.user$ tabuser,
     sys.user$ triguser
where (trigobj.obj#   = t.obj# and
       tabobj.obj#    = t.baseobject and
       trigobj.owner# = triguser.user# and
       tabobj.owner#  = tabuser.user# and
       bitand(t.property, 63)    < 8  and 
       (
        trigobj.owner# = userenv('SCHEMAID') or 
        tabobj.owner# = userenv('SCHEMAID') or
        tabobj.obj# in 
          (select oa1.obj# from sys.objauth$ oa1 where grantee# in
             (select kzsrorol from x$kzsro)) or
        exists (select null from v$enabledprivs 
                where priv_number = -152 /* CREATE ANY TRIGGER */)))
union all
select triguser.name, trigobj.name,
decode(t.type#, 0, 'BEFORE EVENT',
                2, 'AFTER EVENT',
                   'UNDEFINED'),
decode(bitand(t.sys_evts, 1), 1, 'STARTUP ') ||
decode(bitand(t.sys_evts, 2), 2, 
       decode(sign(bitand(t.sys_evts, 1)), 1, 'OR SHUTDOWN ',
                                               'SHUTDOWN ')) ||
decode(bitand(t.sys_evts, 4), 4, 
       decode(sign(bitand(t.sys_evts, 3)), 1, 'OR ERROR ',
                                              'ERROR ')) ||
decode(bitand(t.sys_evts, 8), 8,
       decode(sign(bitand(t.sys_evts, 7)), 1, 'OR LOGON ',
                                              'LOGON ')) ||
decode(bitand(t.sys_evts, 16), 16,
       decode(sign(bitand(t.sys_evts, 15)), 1, 'OR LOGOFF ',
                                               'LOGOFF ')) ||
decode(bitand(t.sys_evts, 262176), 32,
       decode(sign(bitand(t.sys_evts, 31)), 1, 'OR CREATE ',
                                               'CREATE ')) ||
decode(bitand(t.sys_evts, 262208), 64,
       decode(sign(bitand(t.sys_evts, 63)), 1, 'OR ALTER ',
                                               'ALTER ')) ||
decode(bitand(t.sys_evts, 262272), 128,
       decode(sign(bitand(t.sys_evts, 127)), 1, 'OR DROP ',
                                                'DROP ')) ||
decode (bitand(t.sys_evts, 262400), 256,
        decode(sign(bitand(t.sys_evts, 255)), 1, 'OR ANALYZE ',
                                                 'ANALYZE ')) ||
decode (bitand(t.sys_evts, 262656), 512,
        decode(sign(bitand(t.sys_evts, 511)), 1, 'OR COMMENT ',
                                                 'COMMENT ')) ||
decode (bitand(t.sys_evts, 263168), 1024,
        decode(sign(bitand(t.sys_evts, 1023)), 1, 'OR GRANT ',
                                                  'GRANT ')) ||
decode (bitand(t.sys_evts, 264192), 2048,
        decode(sign(bitand(t.sys_evts, 2047)), 1, 'OR REVOKE ',
                                                  'REVOKE ')) ||
decode (bitand(t.sys_evts, 266240), 4096,
        decode(sign(bitand(t.sys_evts, 4095)), 1, 'OR TRUNCATE ',
                                                  'TRUNCATE ')) ||
decode (bitand(t.sys_evts, 270336), 8192,
        decode(sign(bitand(t.sys_evts, 8191)), 1, 'OR RENAME ',
                                                  'RENAME ')) ||
decode (bitand(t.sys_evts, 278528), 16384,
        decode(sign(bitand(t.sys_evts, 16383)), 1, 'OR ASSOCIATE STATISTICS ',
                                                   'ASSOCIATE STATISTICS ')) ||
decode (bitand(t.sys_evts, 294912), 32768,
        decode(sign(bitand(t.sys_evts, 32767)), 1, 'OR AUDIT ',
                                                   'AUDIT ')) ||
decode (bitand(t.sys_evts, 327680), 65536,
        decode(sign(bitand(t.sys_evts, 65535)), 1,
               'OR DISASSOCIATE STATISTICS ', 'DISASSOCIATE STATISTICS ')) ||
decode (bitand(t.sys_evts, 393216), 131072,
        decode(sign(bitand(t.sys_evts, 131071)), 1, 'OR NOAUDIT ',
                                                    'NOAUDIT ')) ||
decode (bitand(t.sys_evts, 262144), 262144,
        decode(sign(bitand(t.sys_evts, 31)), 1, 'OR DDL ',
                                                   'DDL ')) ||
decode (bitand(t.sys_evts, 8388608), 8388608,
        decode(sign(bitand(t.sys_evts, 8388607)), 1, 'OR SUSPEND ',
                                                     'SUSPEND ')),
'SYS',
'DATABASE        ',
NULL,
NULL,
'REFERENCING NEW AS '||t.refnewname||' OLD AS '||t.refoldname,
t.whenclause,decode(t.enabled, 0, 'DISABLED', 1, 'ENABLED', 'ERROR'),
t.definition,
decode(bitand(t.property, 2), 2, 'CALL',
                                 'PL/SQL     '), 
t.action#
from sys.obj$ trigobj, sys.trigger$ t, sys.user$ triguser
where (trigobj.obj#    = t.obj# and
       trigobj.owner#  = triguser.user# and
       bitand(t.property, 63)     >= 8  and  bitand(t.property, 63) < 16 and
       (
        trigobj.owner# = userenv('SCHEMAID') or 
        exists (select null from v$enabledprivs 
                where priv_number = -152 /* CREATE ANY TRIGGER */)))
union all
select triguser.name, trigobj.name,
decode(t.type#, 0, 'BEFORE EVENT',
                2, 'AFTER EVENT',
                   'UNDEFINED'),
decode(bitand(t.sys_evts, 1), 1, 'STARTUP ') ||
decode(bitand(t.sys_evts, 2), 2, 
       decode(sign(bitand(t.sys_evts, 1)), 1, 'OR SHUTDOWN ',
                                               'SHUTDOWN ')) ||
decode(bitand(t.sys_evts, 4), 4, 
       decode(sign(bitand(t.sys_evts, 3)), 1, 'OR ERROR ',
                                              'ERROR ')) ||
decode(bitand(t.sys_evts, 8), 8,
       decode(sign(bitand(t.sys_evts, 7)), 1, 'OR LOGON ',
                                              'LOGON ')) ||
decode(bitand(t.sys_evts, 16), 16,
       decode(sign(bitand(t.sys_evts, 15)), 1, 'OR LOGOFF ',
                                               'LOGOFF ')) ||
decode(bitand(t.sys_evts, 262176), 32,
       decode(sign(bitand(t.sys_evts, 31)), 1, 'OR CREATE ',
                                               'CREATE ')) ||
decode(bitand(t.sys_evts, 262208), 64,
       decode(sign(bitand(t.sys_evts, 63)), 1, 'OR ALTER ',
                                               'ALTER ')) ||
decode(bitand(t.sys_evts, 262272), 128,
       decode(sign(bitand(t.sys_evts, 127)), 1, 'OR DROP ',
                                                'DROP ')) ||
decode (bitand(t.sys_evts, 262400), 256,
        decode(sign(bitand(t.sys_evts, 255)), 1, 'OR ANALYZE ',
                                                 'ANALYZE ')) ||
decode (bitand(t.sys_evts, 262656), 512,
        decode(sign(bitand(t.sys_evts, 511)), 1, 'OR COMMENT ',
                                                 'COMMENT ')) ||
decode (bitand(t.sys_evts, 263168), 1024,
        decode(sign(bitand(t.sys_evts, 1023)), 1, 'OR GRANT ',
                                                  'GRANT ')) ||
decode (bitand(t.sys_evts, 264192), 2048,
        decode(sign(bitand(t.sys_evts, 2047)), 1, 'OR REVOKE ',
                                                  'REVOKE ')) ||
decode (bitand(t.sys_evts, 266240), 4096,
        decode(sign(bitand(t.sys_evts, 4095)), 1, 'OR TRUNCATE ',
                                                  'TRUNCATE ')) ||
decode (bitand(t.sys_evts, 270336), 8192,
        decode(sign(bitand(t.sys_evts, 8191)), 1, 'OR RENAME ',
                                                  'RENAME ')) ||
decode (bitand(t.sys_evts, 278528), 16384,
        decode(sign(bitand(t.sys_evts, 16383)), 1, 'OR ASSOCIATE STATISTICS ',
                                                   'ASSOCIATE STATISTICS ')) ||
decode (bitand(t.sys_evts, 294912), 32768,
        decode(sign(bitand(t.sys_evts, 32767)), 1, 'OR AUDIT ',
                                                   'AUDIT ')) ||
decode (bitand(t.sys_evts, 327680), 65536,
        decode(sign(bitand(t.sys_evts, 65535)), 1,
               'OR DISASSOCIATE STATISTICS ', 'DISASSOCIATE STATISTICS ')) ||
decode (bitand(t.sys_evts, 393216), 131072,
        decode(sign(bitand(t.sys_evts, 131071)), 1, 'OR NOAUDIT ',
                                                    'NOAUDIT ')) ||
decode (bitand(t.sys_evts, 262144), 262144,
        decode(sign(bitand(t.sys_evts, 31)), 1, 'OR DDL ',
                                                   'DDL ')) ||
decode (bitand(t.sys_evts, 8388608), 8388608,
        decode(sign(bitand(t.sys_evts, 8388607)), 1, 'OR SUSPEND ',
                                                     'SUSPEND ')),
tabuser.name,
'SCHEMA', 
NULL,
NULL,
'REFERENCING NEW AS '||t.refnewname||' OLD AS '||t.refoldname,
t.whenclause,decode(t.enabled, 0, 'DISABLED', 1, 'ENABLED', 'ERROR'),
t.definition,
decode(bitand(t.property, 2), 2, 'CALL',
                                 'PL/SQL     '), 
t.action#
from sys.obj$ trigobj, sys.trigger$ t, sys.user$ tabuser, sys.user$ triguser
where (trigobj.obj#    = t.obj# and
       trigobj.owner#  = triguser.user# and
       tabuser.user#   = t.baseobject and
       bitand(t.property, 63)     >= 16 and bitand(t.property, 63) < 32 and
       (
         trigobj.owner# = userenv('SCHEMAID') or
        tabuser.user#  = userenv('SCHEMAID') or
        t.baseobject in 
          (select oa2.obj# from sys.objauth$ oa2 where grantee# in
             (select kzsrorol from x$kzsro)) or
        exists (select null from v$enabledprivs 
                where priv_number = -152 /* CREATE ANY TRIGGER */)))
union all
select triguser.name, trigobj.name,
decode(t.type#, 0, 'BEFORE STATEMENT',
               1, 'BEFORE EACH ROW',
               2, 'AFTER STATEMENT',
               3, 'AFTER EACH ROW',
               4, 'INSTEAD OF',
               'UNDEFINED'),
decode(t.insert$*100 + t.update$*10 + t.delete$,
                 100, 'INSERT',
                 010, 'UPDATE',
                 001, 'DELETE',
                 110, 'INSERT OR UPDATE',
                 101, 'INSERT OR DELETE',
                 011, 'UPDATE OR DELETE',
                 111, 'INSERT OR UPDATE OR DELETE', 'ERROR'),
tabuser.name,
decode(bitand(t.property, 1), 1, 'VIEW', 
                              0, 'TABLE',
                                 'UNDEFINED'), 
tabobj.name, ntcol.name,
'REFERENCING NEW AS '||t.refnewname||' OLD AS '||t.refoldname ||
  ' PARENT AS ' || t.refprtname,
t.whenclause,decode(t.enabled, 0, 'DISABLED', 1, 'ENABLED', 'ERROR'),
t.definition,
decode(bitand(t.property, 2), 2, 'CALL',
                                 'PL/SQL     '), 
t.action#
from sys.obj$ trigobj, sys.obj$ tabobj, sys.trigger$ t, sys.user$ tabuser,
     sys.user$ triguser, sys.viewtrcol$ ntcol
where (trigobj.obj#   = t.obj# and
       tabobj.obj#    = t.baseobject and
       trigobj.owner# = triguser.user# and
       tabobj.owner#  = tabuser.user# and
       bitand(t.property, 63)    >=  32  and 
       t.nttrigcol = ntcol.intcol# and
       t.nttrigatt = ntcol.attribute# and
       t.baseobject = ntcol.obj# and 
       (
        trigobj.owner# = userenv('SCHEMAID') or 
        tabobj.owner# = userenv('SCHEMAID') or
        tabobj.obj# in 
          (select oa3.obj# from sys.objauth$ oa3 where grantee# in
             (select kzsrorol from x$kzsro)) or
        exists (select null from v$enabledprivs 
                where priv_number = -152 /* CREATE ANY TRIGGER */)))
/
comment on table ALL_TRIGGERS is
'Triggers accessible to the current user'
/
comment on column ALL_TRIGGERS.OWNER is
'Owner of the trigger'
/
comment on column ALL_TRIGGERS.TRIGGER_NAME is
'Name of the trigger'
/
comment on column ALL_TRIGGERS.TRIGGER_TYPE is
'When the trigger fires - BEFORE/AFTER and STATEMENT/ROW'
/
comment on column ALL_TRIGGERS.TRIGGERING_EVENT is
'Statement that will fire the trigger - INSERT, UPDATE and/or DELETE'
/
comment on column ALL_TRIGGERS.TABLE_OWNER is
'Owner of the table that this trigger is associated with'
/
comment on column ALL_TRIGGERS.TABLE_NAME is
'Name of the table that this trigger is associated with'
/
comment on column ALL_TRIGGERS.COLUMN_NAME is
'The name of the column on which the trigger is defined over'
/
comment on column ALL_TRIGGERS.REFERENCING_NAMES is
'Names used for referencing to OLD and NEW values within the trigger'
/
comment on column ALL_TRIGGERS.WHEN_CLAUSE is
'WHEN clause must evaluate to true in order for triggering body to execute'
/
comment on column ALL_TRIGGERS.STATUS is
'If DISABLED then trigger will not fire'
/
comment on column ALL_TRIGGERS.DESCRIPTION is
'Trigger description, useful for re-creating trigger creation statement'
/
comment on column ALL_TRIGGERS.TRIGGER_BODY is
'Action taken by this trigger when it fires'
/
create or replace public synonym ALL_TRIGGERS for ALL_TRIGGERS
/
grant select on ALL_TRIGGERS to public with grant option
/

create or replace view DBA_TRIGGERS
(OWNER, TRIGGER_NAME, TRIGGER_TYPE, TRIGGERING_EVENT, TABLE_OWNER, 
 BASE_OBJECT_TYPE, TABLE_NAME, COLUMN_NAME , REFERENCING_NAMES, WHEN_CLAUSE, 
 STATUS, DESCRIPTION, ACTION_TYPE, TRIGGER_BODY)
as
select trigusr.name, trigobj.name,
decode(t.type#, 0, 'BEFORE STATEMENT',
                1, 'BEFORE EACH ROW',
                2, 'AFTER STATEMENT',
                3, 'AFTER EACH ROW',
                4, 'INSTEAD OF',
                   'UNDEFINED'),
decode(t.insert$*100 + t.update$*10 + t.delete$,
                 100, 'INSERT',
                 010, 'UPDATE',
                 001, 'DELETE',
                 110, 'INSERT OR UPDATE',
                 101, 'INSERT OR DELETE',
                 011, 'UPDATE OR DELETE',
                 111, 'INSERT OR UPDATE OR DELETE', 'ERROR'),
tabusr.name,
decode(bitand(t.property, 1), 1, 'VIEW', 
                              0, 'TABLE',
                                 'UNDEFINED'), 
tabobj.name, NULL,
'REFERENCING NEW AS '||t.refnewname||' OLD AS '||t.refoldname,
t.whenclause,decode(t.enabled, 0, 'DISABLED', 1, 'ENABLED', 'ERROR'),
t.definition,
decode(bitand(t.property, 2), 2, 'CALL',
                                 'PL/SQL     '), 
t.action#
from sys.obj$ trigobj, sys.obj$ tabobj, sys.trigger$ t,
     sys.user$ tabusr, sys.user$ trigusr
where (trigobj.obj#   = t.obj# and
       tabobj.obj#    = t.baseobject and
       tabobj.owner#  = tabusr.user# and
       trigobj.owner# = trigusr.user# and
       bitand(t.property, 63)     < 8 ) 
union all
select trigusr.name, trigobj.name,
decode(t.type#, 0, 'BEFORE EVENT',
                2, 'AFTER EVENT',
                   'UNDEFINED'),
decode(bitand(t.sys_evts, 1), 1, 'STARTUP ') ||
decode(bitand(t.sys_evts, 2), 2, 
       decode(sign(bitand(t.sys_evts, 1)), 1, 'OR SHUTDOWN ',
                                               'SHUTDOWN ')) ||
decode(bitand(t.sys_evts, 4), 4, 
       decode(sign(bitand(t.sys_evts, 3)), 1, 'OR ERROR ',
                                              'ERROR ')) ||
decode(bitand(t.sys_evts, 8), 8,
       decode(sign(bitand(t.sys_evts, 7)), 1, 'OR LOGON ',
                                              'LOGON ')) ||
decode(bitand(t.sys_evts, 16), 16,
       decode(sign(bitand(t.sys_evts, 15)), 1, 'OR LOGOFF ',
                                               'LOGOFF ')) ||
decode(bitand(t.sys_evts, 262176), 32,
       decode(sign(bitand(t.sys_evts, 31)), 1, 'OR CREATE ',
                                               'CREATE ')) ||
decode(bitand(t.sys_evts, 262208), 64,
       decode(sign(bitand(t.sys_evts, 63)), 1, 'OR ALTER ',
                                               'ALTER ')) ||
decode(bitand(t.sys_evts, 262272), 128,
       decode(sign(bitand(t.sys_evts, 127)), 1, 'OR DROP ',
                                                'DROP ')) ||
decode (bitand(t.sys_evts, 262400), 256,
        decode(sign(bitand(t.sys_evts, 255)), 1, 'OR ANALYZE ',
                                                 'ANALYZE ')) ||
decode (bitand(t.sys_evts, 262656), 512,
        decode(sign(bitand(t.sys_evts, 511)), 1, 'OR COMMENT ',
                                                 'COMMENT ')) ||
decode (bitand(t.sys_evts, 263168), 1024,
        decode(sign(bitand(t.sys_evts, 1023)), 1, 'OR GRANT ',
                                                  'GRANT ')) ||
decode (bitand(t.sys_evts, 264192), 2048,
        decode(sign(bitand(t.sys_evts, 2047)), 1, 'OR REVOKE ',
                                                  'REVOKE ')) ||
decode (bitand(t.sys_evts, 266240), 4096,
        decode(sign(bitand(t.sys_evts, 4095)), 1, 'OR TRUNCATE ',
                                                  'TRUNCATE ')) ||
decode (bitand(t.sys_evts, 270336), 8192,
        decode(sign(bitand(t.sys_evts, 8191)), 1, 'OR RENAME ',
                                                  'RENAME ')) ||
decode (bitand(t.sys_evts, 278528), 16384,
        decode(sign(bitand(t.sys_evts, 16383)), 1, 'OR ASSOCIATE STATISTICS ',
                                                   'ASSOCIATE STATISTICS ')) ||
decode (bitand(t.sys_evts, 294912), 32768,
        decode(sign(bitand(t.sys_evts, 32767)), 1, 'OR AUDIT ',
                                                   'AUDIT ')) ||
decode (bitand(t.sys_evts, 327680), 65536,
        decode(sign(bitand(t.sys_evts, 65535)), 1,
               'OR DISASSOCIATE STATISTICS ', 'DISASSOCIATE STATISTICS ')) ||
decode (bitand(t.sys_evts, 393216), 131072,
        decode(sign(bitand(t.sys_evts, 131071)), 1, 'OR NOAUDIT ',
                                                    'NOAUDIT ')) ||
decode (bitand(t.sys_evts, 262144), 262144,
        decode(sign(bitand(t.sys_evts, 31)), 1, 'OR DDL ',
                                                   'DDL ')) ||
decode (bitand(t.sys_evts, 8388608), 8388608,
        decode(sign(bitand(t.sys_evts, 8388607)), 1, 'OR SUSPEND ',
                                                     'SUSPEND ')),
'SYS',
'DATABASE        ', 
NULL, 
NULL,
'REFERENCING NEW AS '||t.refnewname||' OLD AS '||t.refoldname
  || decode(bitand(t.property,32),32,' PARENT AS ' || t.refprtname,NULL),
t.whenclause,decode(t.enabled, 0, 'DISABLED', 1, 'ENABLED', 'ERROR'),
t.definition,
decode(bitand(t.property, 2), 2, 'CALL',
                                 'PL/SQL     '), 
t.action#
from sys.obj$ trigobj, sys.trigger$ t, sys.user$ trigusr
where (trigobj.obj#   = t.obj# and 
       trigobj.owner# = trigusr.user# and 
       bitand(t.property, 63)    >= 8 and bitand(t.property, 63) < 16) 
union all
select trigusr.name, trigobj.name,
decode(t.type#, 0, 'BEFORE EVENT',
                2, 'AFTER EVENT',
                   'UNDEFINED'),
decode(bitand(t.sys_evts, 1), 1, 'STARTUP ') ||
decode(bitand(t.sys_evts, 2), 2, 
       decode(sign(bitand(t.sys_evts, 1)), 1, 'OR SHUTDOWN ',
                                               'SHUTDOWN ')) ||
decode(bitand(t.sys_evts, 4), 4, 
       decode(sign(bitand(t.sys_evts, 3)), 1, 'OR ERROR ',
                                              'ERROR ')) ||
decode(bitand(t.sys_evts, 8), 8,
       decode(sign(bitand(t.sys_evts, 7)), 1, 'OR LOGON ',
                                              'LOGON ')) ||
decode(bitand(t.sys_evts, 16), 16,
       decode(sign(bitand(t.sys_evts, 15)), 1, 'OR LOGOFF ',
                                               'LOGOFF ')) ||
decode(bitand(t.sys_evts, 262176), 32,
       decode(sign(bitand(t.sys_evts, 31)), 1, 'OR CREATE ',
                                               'CREATE ')) ||
decode(bitand(t.sys_evts, 262208), 64,
       decode(sign(bitand(t.sys_evts, 63)), 1, 'OR ALTER ',
                                               'ALTER ')) ||
decode(bitand(t.sys_evts, 262272), 128,
       decode(sign(bitand(t.sys_evts, 127)), 1, 'OR DROP ',
                                                'DROP ')) ||
decode (bitand(t.sys_evts, 262400), 256,
        decode(sign(bitand(t.sys_evts, 255)), 1, 'OR ANALYZE ',
                                                 'ANALYZE ')) ||
decode (bitand(t.sys_evts, 262656), 512,
        decode(sign(bitand(t.sys_evts, 511)), 1, 'OR COMMENT ',
                                                 'COMMENT ')) ||
decode (bitand(t.sys_evts, 263168), 1024,
        decode(sign(bitand(t.sys_evts, 1023)), 1, 'OR GRANT ',
                                                  'GRANT ')) ||
decode (bitand(t.sys_evts, 264192), 2048,
        decode(sign(bitand(t.sys_evts, 2047)), 1, 'OR REVOKE ',
                                                  'REVOKE ')) ||
decode (bitand(t.sys_evts, 266240), 4096,
        decode(sign(bitand(t.sys_evts, 4095)), 1, 'OR TRUNCATE ',
                                                  'TRUNCATE ')) ||
decode (bitand(t.sys_evts, 270336), 8192,
        decode(sign(bitand(t.sys_evts, 8191)), 1, 'OR RENAME ',
                                                  'RENAME ')) ||
decode (bitand(t.sys_evts, 278528), 16384,
        decode(sign(bitand(t.sys_evts, 16383)), 1, 'OR ASSOCIATE STATISTICS ',
                                                   'ASSOCIATE STATISTICS ')) ||
decode (bitand(t.sys_evts, 294912), 32768,
        decode(sign(bitand(t.sys_evts, 32767)), 1, 'OR AUDIT ',
                                                   'AUDIT ')) ||
decode (bitand(t.sys_evts, 327680), 65536,
        decode(sign(bitand(t.sys_evts, 65535)), 1,
               'OR DISASSOCIATE STATISTICS ', 'DISASSOCIATE STATISTICS ')) ||
decode (bitand(t.sys_evts, 393216), 131072,
        decode(sign(bitand(t.sys_evts, 131071)), 1, 'OR NOAUDIT ',
                                                    'NOAUDIT ')) ||
decode (bitand(t.sys_evts, 262144), 262144,
        decode(sign(bitand(t.sys_evts, 31)), 1, 'OR DDL ',
                                                   'DDL ')) ||
decode (bitand(t.sys_evts, 8388608), 8388608,
        decode(sign(bitand(t.sys_evts, 8388607)), 1, 'OR SUSPEND ',
                                                     'SUSPEND ')),
tabusr.name, 
'SCHEMA',
NULL,
NULL,
'REFERENCING NEW AS '||t.refnewname||' OLD AS '||t.refoldname,
t.whenclause,decode(t.enabled, 0, 'DISABLED', 1, 'ENABLED', 'ERROR'),
t.definition,
decode(bitand(t.property, 2), 2, 'CALL',
                                 'PL/SQL     '), 
t.action#
from sys.obj$ trigobj, sys.trigger$ t, sys.user$ tabusr, sys.user$ trigusr
where (trigobj.obj#   = t.obj# and 
       trigobj.owner# = trigusr.user# and 
       bitand(t.property, 63) >= 16 and bitand(t.property, 63) < 32 and
       tabusr.user# = t.baseobject)
union all
select trigusr.name, trigobj.name,
decode(t.type#, 0, 'BEFORE STATEMENT',
               1, 'BEFORE EACH ROW',
               2, 'AFTER STATEMENT',
               3, 'AFTER EACH ROW',
               4, 'INSTEAD OF',
               'UNDEFINED'),
decode(t.insert$*100 + t.update$*10 + t.delete$,
                 100, 'INSERT',
                 010, 'UPDATE',
                 001, 'DELETE',
                 110, 'INSERT OR UPDATE',
                 101, 'INSERT OR DELETE',
                 011, 'UPDATE OR DELETE',
                 111, 'INSERT OR UPDATE OR DELETE', 'ERROR'),
tabusr.name,
decode(bitand(t.property, 1), 1, 'VIEW', 
                              0, 'TABLE',
                                 'UNDEFINED'), 
tabobj.name, ntcol.name,
'REFERENCING NEW AS '||t.refnewname||' OLD AS '||t.refoldname ||
  ' PARENT AS ' || t.refprtname,
t.whenclause,decode(t.enabled, 0, 'DISABLED', 1, 'ENABLED', 'ERROR'),
t.definition,
decode(bitand(t.property, 2), 2, 'CALL',
                                 'PL/SQL     '), 
t.action#
from sys.obj$ trigobj, sys.obj$ tabobj, sys.trigger$ t,
     sys.user$ tabusr, sys.user$ trigusr, sys.viewtrcol$ ntcol
where (trigobj.obj#   = t.obj# and
       tabobj.obj#    = t.baseobject and
       tabobj.owner#  = tabusr.user# and
       trigobj.owner# = trigusr.user# and
       t.nttrigcol    = ntcol.intcol# and
       t.nttrigatt    = ntcol.attribute# and
       t.baseobject   = ntcol.obj# and
       bitand(t.property, 63)     >= 32) 
/
create or replace public synonym DBA_TRIGGERS for DBA_TRIGGERS
/
grant select on DBA_TRIGGERS to select_catalog_role
/
comment on table DBA_TRIGGERS is
'All triggers in the database'
/
comment on column DBA_TRIGGERS.OWNER is
'Owner of the trigger'
/
comment on column DBA_TRIGGERS.TRIGGER_NAME is
'Name of the trigger'
/
comment on column DBA_TRIGGERS.TRIGGER_TYPE is
'When the trigger fires - BEFORE/AFTER and STATEMENT/ROW'
/
comment on column DBA_TRIGGERS.TRIGGERING_EVENT is
'Statement that will fire the trigger - INSERT, UPDATE and/or DELETE'
/
comment on column DBA_TRIGGERS.TABLE_OWNER is
'Owner of the table that this trigger is associated with'
/
comment on column DBA_TRIGGERS.TABLE_NAME is
'Name of the table that this trigger is associated with'
/
comment on column DBA_TRIGGERS.COLUMN_NAME is
'The name of the column on which the trigger is defined over '
/
comment on column DBA_TRIGGERS.REFERENCING_NAMES is
'Names used for referencing to OLD and NEW values within the trigger'
/
comment on column DBA_TRIGGERS.WHEN_CLAUSE is
'WHEN clause must evaluate to true in order for triggering body to execute'
/
comment on column DBA_TRIGGERS.STATUS is
'If DISABLED then trigger will not fire'
/
comment on column DBA_TRIGGERS.DESCRIPTION is
'Trigger description, useful for re-creating trigger creation statement'
/
comment on column DBA_TRIGGERS.TRIGGER_BODY is
'Action taken by this trigger when it fires'
/
create or replace view USER_INTERNAL_TRIGGERS
    (TABLE_NAME, INTERNAL_TRIGGER_TYPE)
as
select o.name, 'DEFERRED RPC QUEUE'
from sys.tab$ t, sys.obj$ o
where o.owner# = userenv('SCHEMAID')
      and t.obj# = o.obj#
      and bitand(t.trigflag,1) = 1
union
select o.name, 'MVIEW LOG'
from sys.tab$ t, sys.obj$ o
where o.owner# = userenv('SCHEMAID')
      and t.obj# = o.obj#
      and bitand(t.trigflag,2) = 2 
union
select o.name, 'UPDATABLE MVIEW LOG'
from sys.tab$ t, sys.obj$ o
where o.owner# = userenv('SCHEMAID')
       and t.obj# = o.obj#
       and bitand(t.trigflag,4) = 4
union
select o.name, 'CONTEXT'
from sys.tab$ t, sys.obj$ o
where o.owner# = userenv('SCHEMAID')
      and t.obj# = o.obj#
      and bitand(t.trigflag,8) = 8
/
comment on table USER_INTERNAL_TRIGGERS is
'Description of the internal triggers on the user''s own tables'
/
comment on column USER_INTERNAL_TRIGGERS.TABLE_NAME is
'Name of the table'
/
comment on column USER_INTERNAL_TRIGGERS.INTERNAL_TRIGGER_TYPE is
'Type of internal trigger'
/
create or replace public synonym USER_INTERNAL_TRIGGERS
   for USER_INTERNAL_TRIGGERS
/
grant select on USER_INTERNAL_TRIGGERS to PUBLIC with grant option
/
create or replace view ALL_INTERNAL_TRIGGERS
    (TABLE_NAME, INTERNAL_TRIGGER_TYPE)
as
select o.name, 'DEFERRED RPC QUEUE'
from sys.tab$ t, sys.obj$ o
where t.obj# = o.obj#
      and bitand(t.trigflag,1) = 1
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
union
select o.name, 'MVIEW LOG'
from sys.tab$ t, sys.obj$ o
where t.obj# = o.obj#
      and bitand(t.trigflag,2) = 2
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
union
select o.name, 'UPDATABLE MVIEW LOG'
from sys.tab$ t, sys.obj$ o
where t.obj# = o.obj#
      and bitand(t.trigflag,4) = 4
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
union
select o.name, 'CONTEXT'
from sys.tab$ t, sys.obj$ o
where t.obj# = o.obj#
      and bitand(t.trigflag,8) = 8
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
comment on table ALL_INTERNAL_TRIGGERS is
'Description of the internal triggers on the tables accessible to the user'
/
comment on column ALL_INTERNAL_TRIGGERS.TABLE_NAME is
'Name of the table'
/
comment on column ALL_INTERNAL_TRIGGERS.INTERNAL_TRIGGER_TYPE is
'Type of internal trigger'
/
create or replace public synonym ALL_INTERNAL_TRIGGERS
   for ALL_INTERNAL_TRIGGERS
/
grant select on ALL_INTERNAL_TRIGGERS to PUBLIC with grant option
/
create or replace view DBA_INTERNAL_TRIGGERS
    (TABLE_NAME, OWNER_NAME, INTERNAL_TRIGGER_TYPE)
as
select o.name, u.name, 'DEFERRED RPC QUEUE'
from sys.tab$ t, sys.obj$ o, sys.user$ u
where t.obj# = o.obj#
      and u.user# = o.owner#
      and bitand(t.trigflag,1) = 1
union
select o.name, u.name, 'MVIEW LOG'
from sys.tab$ t, sys.obj$ o, sys.user$ u
where t.obj# = o.obj#
      and u.user# = o.owner#
      and bitand(t.trigflag,2) = 2
union
select o.name, u.name, 'UPDATABLE MVIEW LOG'
from sys.tab$ t, sys.obj$ o, sys.user$ u
where t.obj# = o.obj#
      and u.user# = o.owner#
      and bitand(t.trigflag,4) = 4
union
select o.name, u.name, 'CONTEXT'
from sys.tab$ t, sys.obj$ o, sys.user$ u
where t.obj# = o.obj#
      and u.user# = o.owner#
      and bitand(t.trigflag,8) = 8
/
comment on table DBA_INTERNAL_TRIGGERS is
'Description of the internal triggers on all tables in the database'
/
comment on column DBA_INTERNAL_TRIGGERS.TABLE_NAME is
'Name of the table'
/
comment on column DBA_INTERNAL_TRIGGERS.OWNER_NAME is
'Name of the owner'
/
comment on column DBA_INTERNAL_TRIGGERS.INTERNAL_TRIGGER_TYPE is
'Type of internal trigger'
/
create or replace public synonym DBA_INTERNAL_TRIGGERS
   for DBA_INTERNAL_TRIGGERS 
/
grant select on DBA_INTERNAL_TRIGGERS to select_catalog_role
/
remark
remark        USER_TRIGGER_COLS shows usage of columns in triggers owned by the
remark        current user or in triggers on tables owned by the current user
remark
remark This has been rewritten to use unions for the sake of ADTs and
remark nested table triggers. 
remark Logic:
remark  (I) if col type is not an ADT attribute AND  
remark      ( it is not a nested table trigger type OR the bind type is :PARENT)
remark        then we join with col$ and get the column name 
remark (II) if coltype is an ADT attribute AND 
remark      ( it is not a nested table trigger type OR the bind type is :PARENT)
remark        then we join with attrcol$ to find out the bind name
remark (III) if coltype is a nested table trigger type 
remark        AND the intcol# is not zero 
remark      then we match with attribute$ to get the name 
remark      ( We need to join collection$, coltype$ and attribute$)
remark (IV) if coltype is a nested table trigger and intcol is zero 
remark      then the column name is COLUMN_VALUE
remark 
remark We can union all these since they are distinct results 
remark This is the same for DBA_TRIGGER_COLS and ALL_TRIGGER_COLS

create or replace view USER_TRIGGER_COLS
(TRIGGER_OWNER, TRIGGER_NAME, TABLE_OWNER, TABLE_NAME, COLUMN_NAME,
    COLUMN_LIST, COLUMN_USAGE)
as
select /*+ ORDERED NOCOST */ u.name, o.name, u2.name, o2.name,c.name,
   max(decode(tc.type#,0,'YES','NO')) COLUMN_LIST,
   decode(sum(decode(tc.type#,5,  1, -- one occurrence of new in
                              6,  2, -- one occurrence of old in
                              9,  4, -- one occurrence of new out
                             10,  8, -- one occurrence of old out (impossible)
                             13,  5, -- one occurrence of new in out
                             14, 10, -- one occurrence of old in out (imp.)
                             20, 16, -- one occurrence of parent in
                             24, 32, -- one occurrence of parent out (imp)
                             28, 64, -- one occurrence of parent in out (imp)
                              null)
                ), -- result in the following combinations across occurrences
           1, 'NEW IN',
           2, 'OLD IN',
           3, 'NEW IN OLD IN',
           4, 'NEW OUT',
           5, 'NEW IN OUT',
           6, 'NEW OUT OLD IN',
           7, 'NEW IN OUT OLD IN',
          16, 'PARENT IN',
          'NONE')
from sys.trigger$ t, sys.obj$ o, sys.user$ u, sys.user$ u2,
     sys.col$ c, sys.obj$ o2, sys.triggercol$ tc
where t.obj# = tc.obj#                -- find corresponding trigger definition
  and o.obj# = t.obj#                --    and corresponding trigger name
  and c.obj# = t.baseobject         -- and corresponding row in COL$ of
  and c.intcol# = tc.intcol#    -- the referenced column  
  and bitand(c.property,32768) != 32768   -- not unused columns
  and o2.obj# = t.baseobject        -- and name of the table containing the trigger
  and u2.user# = o2.owner#        -- and name of the user who owns the table
  and u.user# = o.owner#        -- and name of user who owns the trigger
  and bitand(c.property,1) <> 1 -- and it is not an adt column
  and (bitand(t.property,32) <> 32 -- and it is not a nested table col
       or 
      bitand(tc.type#,16) = 16) -- or it is a PARENT type column 
  and ((o.owner# = userenv('SCHEMAID') and u.user# = userenv('SCHEMAID')) -- triggers owned by the current user
      or
       (o2.owner# = userenv('SCHEMAID') and u2.user# = userenv('SCHEMAID'))) -- on the current user's tables
group by u.name, o.name, u2.name, o2.name,c.name
union all
select /*+ ORDERED NOCOST */ u.name, o.name, u2.name, o2.name,ac.name,
   max(decode(tc.type#,0,'YES','NO')) COLUMN_LIST,
   decode(sum(decode(tc.type#,5,  1, -- one occurrence of new in
                              6,  2, -- one occurrence of old in
                              9,  4, -- one occurrence of new out
                             10,  8, -- one occurrence of old out (impossible)
                             13,  5, -- one occurrence of new in out
                             14, 10, -- one occurrence of old in out (imp.)
                             20, 16, -- one occurrence of parent in
                             24, 32, -- one occurrence of parent out (imp)
                             28, 64, -- one occurrence of parent in out (imp)
                              null)
                ), -- result in the following combinations across occurrences
           1, 'NEW IN',
           2, 'OLD IN',
           3, 'NEW IN OLD IN',
           4, 'NEW OUT',
           5, 'NEW IN OUT',
           6, 'NEW OUT OLD IN',
           7, 'NEW IN OUT OLD IN',
          16, 'PARENT IN',
          'NONE')
from sys.trigger$ t, sys.obj$ o, sys.user$ u, sys.user$ u2,
     sys.col$ c, sys.obj$ o2, sys.triggercol$ tc, sys.attrcol$ ac
where t.obj# = tc.obj#                -- find corresponding trigger definition
  and o.obj# = t.obj#                --    and corresponding trigger name
  and c.obj# = t.baseobject         -- and corresponding row in COL$ of
  and c.intcol# = tc.intcol#    -- the referenced column  
  and bitand(c.property,32768) != 32768   -- not unused columns
  and o2.obj# = t.baseobject        -- and name of the table containing the trigger
  and u2.user# = o2.owner#        -- and name of the user who owns the table
  and u.user# = o.owner#        -- and name of user who owns the trigger
  and bitand(c.property,1) = 1  -- and it is an adt column
  and (bitand(t.property,32) <> 32 -- and it is not a nested table col
       or 
      bitand(tc.type#,16) = 16) -- or it is a PARENT type column 
  and ac.intcol# = c.intcol# 
  and ac.obj# = c.obj#
  and ((o.owner# = userenv('SCHEMAID') and u.user# = userenv('SCHEMAID')) -- triggers owned by the current user
      or
       (o2.owner# = userenv('SCHEMAID') and u2.user# = userenv('SCHEMAID'))) -- on the current user's tables
group by u.name, o.name, u2.name, o2.name,ac.name
union all
select /*+ ORDERED NOCOST */ u.name, o.name, u2.name, o2.name, attr.name,
   max(decode(tc.type#,0,'YES','NO')) COLUMN_LIST,
   decode(sum(decode(tc.type#,5,  1, -- one occurrence of new in
                              6,  2, -- one occurrence of old in
                              9,  4, -- one occurrence of new out
                             10,  8, -- one occurrence of old out (impossible)
                             13,  5, -- one occurrence of new in out
                             14, 10, -- one occurrence of old in out (imp.)
                              null)
                ), -- result in the following combinations across occurrences
           1, 'NEW IN',
           2, 'OLD IN',
           3, 'NEW IN OLD IN',
           4, 'NEW OUT',
           5, 'NEW IN OUT',
           6, 'NEW OUT OLD IN',
           7, 'NEW IN OUT OLD IN',
          'NONE')
from sys.trigger$ t, sys.obj$ o, sys.user$ u, sys.user$ u2,
     sys.obj$ o2, sys.triggercol$ tc, 
     sys.collection$ coll, sys.coltype$ ctyp, sys.attribute$ attr
where t.obj# = tc.obj#                -- find corresponding trigger definition
  and o.obj# = t.obj#                --    and corresponding trigger name
  and o2.obj# = t.baseobject        -- and name of the table containing the trigger
  and u2.user# = o2.owner#        -- and name of the user who owns the table
  and u.user# = o.owner#        -- and name of user who owns the trigger
  and bitand(t.property,32) = 32 -- and it is not a nested table col
  and bitand(tc.type#,16) <> 16  -- and it is not a PARENT type column 
  and ctyp.obj# = t.baseobject   -- find corresponding column type definition
  and ctyp.intcol# = t.nttrigcol -- and get the column type for the nested table
  and ctyp.toid = coll.toid      -- get the collection toid 
  and ctyp.version# = coll.version# -- get the collection version 
  and attr.attribute# = tc.intcol#  -- get the attribute number
  and attr.toid  = coll.elem_toid  -- get the attribute toid
  and attr.version# = coll.version#  -- get the attribute version
  and ((o.owner# = userenv('SCHEMAID') and u.user# = userenv('SCHEMAID')) -- triggers owned by the current user
      or
       (o2.owner# = userenv('SCHEMAID') and u2.user# = userenv('SCHEMAID'))) -- on the current user's tables
group by u.name, o.name, u2.name, o2.name,attr.name
union all
select /*+ ORDERED NOCOST */ u.name, o.name, u2.name, o2.name, 'COLUMN_VALUE',
   max(decode(tc.type#,0,'YES','NO')) COLUMN_LIST,
   decode(sum(decode(tc.type#,5,  1, -- one occurrence of new in
                              6,  2, -- one occurrence of old in
                              9,  4, -- one occurrence of new out
                             10,  8, -- one occurrence of old out (impossible)
                             13,  5, -- one occurrence of new in out
                             14, 10, -- one occurrence of old in out (imp.)
                              null)
                ), -- result in the following combinations across occurrences
           1, 'NEW IN',
           2, 'OLD IN',
           3, 'NEW IN OLD IN',
           4, 'NEW OUT',
           5, 'NEW IN OUT',
           6, 'NEW OUT OLD IN',
           7, 'NEW IN OUT OLD IN',
          'NONE')
from sys.trigger$ t, sys.obj$ o, sys.user$ u, sys.user$ u2, sys.obj$ o2, 
     sys.triggercol$ tc
where t.obj# = tc.obj#                -- find corresponding trigger definition
  and o.obj# = t.obj#                --    and corresponding trigger name
  and o2.obj# = t.baseobject        -- and name of the table containing the trigger
  and u2.user# = o2.owner#        -- and name of the user who owns the table
  and u.user# = o.owner#        -- and name of user who owns the trigger
  and bitand(t.property,32) = 32 -- and it is not a nested table col
  and bitand(tc.type#,16) <> 16  -- and it is not a PARENT type column 
  and tc.intcol# = 0
  and ((o.owner# = userenv('SCHEMAID') and u.user# = userenv('SCHEMAID')) -- triggers owned by the current user
      or
       (o2.owner# = userenv('SCHEMAID') and u2.user# = userenv('SCHEMAID'))) -- on the current user's tables
group by u.name, o.name, u2.name, o2.name,'COLUMN_VALUE'
/
comment on table USER_TRIGGER_COLS is
'Column usage in user''s triggers'
/
comment on column USER_TRIGGER_COLS.TRIGGER_OWNER is
'Owner of the trigger'
/
comment on column USER_TRIGGER_COLS.TRIGGER_NAME is
'Name of the trigger'
/
comment on column USER_TRIGGER_COLS.TABLE_OWNER is
'Owner of the table'
/
comment on column USER_TRIGGER_COLS.TABLE_NAME is
'Name of the table on which the trigger is defined'
/
comment on column USER_TRIGGER_COLS.COLUMN_NAME is
'Name of the column or the attribute of the ADT column used in trigger definition'
/
comment on column USER_TRIGGER_COLS.COLUMN_LIST is
'Is column specified in UPDATE OF clause?'
/
comment on column USER_TRIGGER_COLS.COLUMN_USAGE is
'Usage of column within trigger body'
/
create or replace public synonym USER_TRIGGER_COLS for USER_TRIGGER_COLS
/
grant select on USER_TRIGGER_COLS to public
/
remark
remark        ALL_TRIGGER_COLS shows usage of columns in triggers owned by the
remark        current user or in triggers on tables owned by the current user
remark        or on all triggers if current user has CREATE ANY TRIGGER privilege
remark        (either directly or through a role).
remark

create or replace view ALL_TRIGGER_COLS
(TRIGGER_OWNER, TRIGGER_NAME, TABLE_OWNER, TABLE_NAME, COLUMN_NAME,
    COLUMN_LIST, COLUMN_USAGE)
as
select /*+ ORDERED NOCOST */ u.name, o.name, u2.name, o2.name, c.name,
   max(decode(tc.type#,0,'YES','NO')) COLUMN_LIST,
   decode(sum(decode(tc.type#, 5,  1, -- one occurrence of new in
                              6,  2, -- one occurrence of old in
                              9,  4, -- one occurrence of new out
                             10,  8, -- one occurrence of old out (impossible)
                             13,  5, -- one occurrence of new in out
                             14, 10, -- one occurrence of old in out (imp.)
                             20, 16, -- one occurrence of parent in 
                             24, 32, -- one occurrence of parent out (imp)
                             28, 64, -- one occurrence of parent in out (imp)
                              null)
                ), -- result in the following combinations across occurrences
           1, 'NEW IN',
           2, 'OLD IN',
           3, 'NEW IN OLD IN',
           4, 'NEW OUT',
           5, 'NEW IN OUT',
           6, 'NEW OUT OLD IN',
           7, 'NEW IN OUT OLD IN',
          16, 'PARENT IN',
          'NONE')
from sys.trigger$ t, sys.obj$ o, sys.user$ u, sys.user$ u2,
     sys.col$ c, sys.obj$ o2, sys.triggercol$ tc
where t.obj# = tc.obj#                -- find corresponding trigger definition
  and o.obj# = t.obj#                --    and corresponding trigger name
  and c.obj# = t.baseobject         -- and corresponding row in COL$ of
  and c.intcol# = tc.intcol#        --    the referenced column
  and bitand(c.property,32768) != 32768   -- not unused columns
  and o2.obj# = t.baseobject        -- and name of the table containing the trigger
  and u2.user# = o2.owner#        -- and name of the user who owns the table
  and u.user# = o.owner#        -- and name of user who owns the trigger
  and bitand(c.property,1) <> 1  -- and the col is not an ADT column
  and (bitand(t.property,32) <> 32 -- and it is not a nested table col
       or
      bitand(tc.type#,16) = 16) -- or it is a PARENT type column
  and
  ( o.owner# = userenv('SCHEMAID') or o2.owner# = userenv('SCHEMAID')
    or
    exists    -- an enabled role (or current user) with CREATE ANY TRIGGER priv
     ( select null from sys.sysauth$ sa    -- does 
       where privilege# = -152             -- CREATE ANY TRIGGER privilege exist
       and (grantee# in                    -- for current user or public
            (select kzsrorol from x$kzsro) -- currently enabled role
           )
      )
   )
group by u.name, o.name, u2.name, o2.name,c.name
union all
select /*+ ORDERED NOCOST */ u.name, o.name, u2.name, o2.name,ac.name,
   max(decode(tc.type#,0,'YES','NO')) COLUMN_LIST,
   decode(sum(decode(tc.type#, 5,  1, -- one occurrence of new in
                              6,  2, -- one occurrence of old in
                              9,  4, -- one occurrence of new out
                             10,  8, -- one occurrence of old out (impossible)
                             13,  5, -- one occurrence of new in out
                             14, 10, -- one occurrence of old in out (imp.)
                             20, 16, -- one occurrence of parent in 
                             24, 32, -- one occurrence of parent out (imp)
                             28, 64, -- one occurrence of parent in out (imp)
                              null)
                ), -- result in the following combinations across occurrences
           1, 'NEW IN',
           2, 'OLD IN',
           3, 'NEW IN OLD IN',
           4, 'NEW OUT',
           5, 'NEW IN OUT',
           6, 'NEW OUT OLD IN',
           7, 'NEW IN OUT OLD IN',
          16, 'PARENT IN',
          'NONE')
from sys.trigger$ t, sys.obj$ o, sys.user$ u, sys.user$ u2,
     sys.col$ c, sys.obj$ o2, sys.triggercol$ tc, sys.attrcol$ ac
where t.obj# = tc.obj#                -- find corresponding trigger definition
  and o.obj# = t.obj#                --    and corresponding trigger name
  and c.obj# = t.baseobject         -- and corresponding row in COL$ of
  and c.intcol# = tc.intcol#        --    the referenced column
  and bitand(c.property,32768) != 32768   -- not unused columns
  and o2.obj# = t.baseobject        -- and name of the table containing the trigger
  and u2.user# = o2.owner#        -- and name of the user who owns the table
  and u.user# = o.owner#        -- and name of user who owns the trigger
  and bitand(c.property,1) = 1  -- and it is an ADT attribute
  and ac.intcol# = c.intcol#    -- and the attribute name
  and (bitand(t.property,32) <> 32 -- and it is not a nested table col
       or
      bitand(tc.type#,16) = 16) -- or it is a PARENT type column
  and
  ( o.owner# = userenv('SCHEMAID') or o2.owner# = userenv('SCHEMAID')
    or
    exists    -- an enabled role (or current user) with CREATE ANY TRIGGER priv
     ( select null from sys.sysauth$ sa    -- does 
       where privilege# = -152             -- CREATE ANY TRIGGER privilege exist
       and (grantee# in                    -- for current user or public
            (select kzsrorol from x$kzsro) -- currently enabled role
           )
      )
   )
group by u.name, o.name, u2.name, o2.name,ac.name
union all
select /*+ ORDERED NOCOST */ u.name, o.name, u2.name, o2.name,attr.name,
   max(decode(tc.type#,0,'YES','NO')) COLUMN_LIST,
   decode(sum(decode(tc.type#, 5,  1, -- one occurrence of new in
                              6,  2, -- one occurrence of old in
                              9,  4, -- one occurrence of new out
                             10,  8, -- one occurrence of old out (impossible)
                             13,  5, -- one occurrence of new in out
                             14, 10, -- one occurrence of old in out (imp.)
                              null)
                ), -- result in the following combinations across occurrences
           1, 'NEW IN',
           2, 'OLD IN',
           3, 'NEW IN OLD IN',
           4, 'NEW OUT',
           5, 'NEW IN OUT',
           6, 'NEW OUT OLD IN',
           7, 'NEW IN OUT OLD IN',
          'NONE')
from sys.trigger$ t, sys.obj$ o, sys.user$ u, sys.user$ u2,
     sys.obj$ o2, sys.triggercol$ tc, 
     sys.collection$ coll, sys.coltype$ ctyp, sys.attribute$ attr
where t.obj# = tc.obj#                -- find corresponding trigger definition
  and o.obj# = t.obj#                --    and corresponding trigger name
  and o2.obj# = t.baseobject        -- and name of the table containing the trigger
  and u2.user# = o2.owner#        -- and name of the user who owns the table
  and u.user# = o.owner#        -- and name of user who owns the trigger
  and bitand(t.property,32) = 32 -- and it is a nested table col
  and bitand(tc.type#,16) <> 16  -- and it is not a PARENT type column 
  and ctyp.obj# = t.baseobject   -- find corresponding column type definition
  and ctyp.intcol# = t.nttrigcol -- and get the column type for the nested table
  and ctyp.toid = coll.toid      -- get the collection toid
  and ctyp.version# = coll.version# -- get the collection version
  and attr.attribute# = tc.intcol#  -- get the attribute number
  and attr.toid  = coll.elem_toid  -- get the attribute toid
  and attr.version# = coll.version#  -- get the attribute version
  and
  ( o.owner# = userenv('SCHEMAID') or o2.owner# = userenv('SCHEMAID')
    or
    exists    -- an enabled role (or current user) with CREATE ANY TRIGGER priv
     ( select null from sys.sysauth$ sa    -- does 
       where privilege# = -152             -- CREATE ANY TRIGGER privilege exist
       and (grantee# in                    -- for current user or public
            (select kzsrorol from x$kzsro) -- currently enabled role
           )
      )
   )
group by u.name, o.name, u2.name, o2.name,attr.name
union all
select /*+ ORDERED NOCOST */ u.name, o.name, u2.name, o2.name,'COLUMN_VALUE',
   max(decode(tc.type#,0,'YES','NO')) COLUMN_LIST,
   decode(sum(decode(tc.type#, 5,  1, -- one occurrence of new in
                              6,  2, -- one occurrence of old in
                              9,  4, -- one occurrence of new out
                             10,  8, -- one occurrence of old out (impossible)
                             13,  5, -- one occurrence of new in out
                             14, 10, -- one occurrence of old in out (imp.)
                              null)
                ), -- result in the following combinations across occurrences
           1, 'NEW IN',
           2, 'OLD IN',
           3, 'NEW IN OLD IN',
           4, 'NEW OUT',
           5, 'NEW IN OUT',
           6, 'NEW OUT OLD IN',
           7, 'NEW IN OUT OLD IN',
          'NONE')
from sys.trigger$ t, sys.obj$ o, sys.user$ u, sys.user$ u2,
     sys.obj$ o2, sys.triggercol$ tc
where t.obj# = tc.obj#                -- find corresponding trigger definition
  and o.obj# = t.obj#                --    and corresponding trigger name
  and o2.obj# = t.baseobject        -- and name of the table containing the trigger
  and u2.user# = o2.owner#        -- and name of the user who owns the table
  and u.user# = o.owner#        -- and name of user who owns the trigger
  and bitand(t.property,32) = 32 -- and it is not a nested table col
  and bitand(tc.type#,16) <> 16  -- and it is not a PARENT type column
  and tc.intcol# = 0
  and
  ( o.owner# = userenv('SCHEMAID') or o2.owner# = userenv('SCHEMAID')
    or
    exists    -- an enabled role (or current user) with CREATE ANY TRIGGER priv
     ( select null from sys.sysauth$ sa    -- does 
       where privilege# = -152             -- CREATE ANY TRIGGER privilege exist
       and (grantee# in                    -- for current user or public
            (select kzsrorol from x$kzsro) -- currently enabled role
           )
      )
   )
group by u.name, o.name, u2.name, o2.name,'COLUMN_VALUE'
/
comment on table ALL_TRIGGER_COLS is
'Column usage in user''s triggers or in triggers on user''s tables'
/
comment on column ALL_TRIGGER_COLS.TRIGGER_OWNER is
'Owner of the trigger'
/
comment on column ALL_TRIGGER_COLS.TRIGGER_NAME is
'Name of the trigger'
/
comment on column ALL_TRIGGER_COLS.TABLE_OWNER is
'Owner of the table'
/
comment on column ALL_TRIGGER_COLS.TABLE_NAME is
'Name of the table on which the trigger is defined'
/
comment on column ALL_TRIGGER_COLS.COLUMN_NAME is
'Name of the column or the attribute of the ADT column used in trigger definition'
/
comment on column ALL_TRIGGER_COLS.COLUMN_LIST is
'Is column specified in UPDATE OF clause?'
/
comment on column ALL_TRIGGER_COLS.COLUMN_USAGE is
'Usage of column within trigger body'
/
create or replace public synonym ALL_TRIGGER_COLS for ALL_TRIGGER_COLS
/
grant select on ALL_TRIGGER_COLS to public
/
remark
remark        DBA_TRIGGER_COLS shows usage of columns in all triggers defined
remark        by any user, on any user's table.
remark

create or replace view DBA_TRIGGER_COLS
(TRIGGER_OWNER, TRIGGER_NAME, TABLE_OWNER, TABLE_NAME, COLUMN_NAME,
    COLUMN_LIST, COLUMN_USAGE)
as
select /*+ ORDERED NOCOST */ u.name, o.name, u2.name, o2.name,c.name,
   max(decode(tc.type#,0,'YES','NO')) COLUMN_LIST,
   decode(sum(decode(tc.type#, 5,  1, -- one occurrence of new in
                              6,  2, -- one occurrence of old in
                              9,  4, -- one occurrence of new out
                             10,  8, -- one occurrence of old out (impossible)
                             13,  5, -- one occurrence of new in out
                             14, 10, -- one occurrence of old in out (imp.)
                             20, 16, -- one occurrence of parent in 
                             24, 32, -- one occurrence of parent out (imp)
                             28, 64, -- one occurrence of parent in out (imp)
                              null)
                ), -- result in the following combinations across occurrences
           1, 'NEW IN',
           2, 'OLD IN',
           3, 'NEW IN OLD IN',
           4, 'NEW OUT',
           5, 'NEW IN OUT',
           6, 'NEW OUT OLD IN',
           7, 'NEW IN OUT OLD IN',
          16, 'PARENT IN',
          'NONE')
from sys.trigger$ t, sys.obj$ o, sys.user$ u, sys.user$ u2,
     sys.col$ c, sys.obj$ o2, sys.triggercol$ tc
where t.obj# = tc.obj#                -- find corresponding trigger definition
  and o.obj# = t.obj#                --    and corresponding trigger name
  and c.obj# = t.baseobject         -- and corresponding row in COL$ of
  and c.intcol# = tc.intcol#        --    the referenced column
  and bitand(c.property,32768) != 32768   -- not unused columns
  and o2.obj# = t.baseobject        -- and name of the table containing the trigger
  and u2.user# = o2.owner#        -- and name of the user who owns the table
  and u.user# = o.owner#        -- and name of user who owns the trigger
  and bitand(c.property,1) <> 1  -- and the col is not an ADT column
  and (bitand(t.property,32) <> 32 -- and it is not a nested table col
       or
      bitand(tc.type#,16) = 16) -- or it is a PARENT type column
group by u.name, o.name, u2.name, o2.name, c.name
union all
select /*+ ORDERED NOCOST */ u.name, o.name, u2.name, o2.name,ac.name,
   max(decode(tc.type#,0,'YES','NO')) COLUMN_LIST,
   decode(sum(decode(tc.type#, 5,  1, -- one occurrence of new in
                              6,  2, -- one occurrence of old in
                              9,  4, -- one occurrence of new out
                             10,  8, -- one occurrence of old out (impossible)
                             13,  5, -- one occurrence of new in out
                             14, 10, -- one occurrence of old in out (imp.)
                             20, 16, -- one occurrence of parent in 
                             24, 32, -- one occurrence of parent out (imp)
                             28, 64, -- one occurrence of parent in out (imp)
                              null)
                ), -- result in the following combinations across occurrences
           1, 'NEW IN',
           2, 'OLD IN',
           3, 'NEW IN OLD IN',
           4, 'NEW OUT',
           5, 'NEW IN OUT',
           6, 'NEW OUT OLD IN',
           7, 'NEW IN OUT OLD IN',
          16, 'PARENT IN',
          'NONE')
from sys.trigger$ t, sys.obj$ o, sys.user$ u, sys.user$ u2,
     sys.col$ c, sys.obj$ o2, sys.triggercol$ tc, sys.attrcol$ ac
where t.obj# = tc.obj#                -- find corresponding trigger definition
  and o.obj# = t.obj#                --    and corresponding trigger name
  and c.obj# = t.baseobject         -- and corresponding row in COL$ of
  and c.intcol# = tc.intcol#        --    the referenced column
  and bitand(c.property,32768) != 32768   -- not unused columns
  and o2.obj# = t.baseobject        -- and name of the table containing the trigger
  and u2.user# = o2.owner#        -- and name of the user who owns the table
  and u.user# = o.owner#        -- and name of user who owns the trigger
  and bitand(c.property,1) = 1  -- and it is an ADT attribute
  and ac.intcol# = c.intcol#    -- and the attribute name
  and (bitand(t.property,32) <> 32 -- and it is not a nested table col
       or
      bitand(tc.type#,16) = 16) -- or it is a PARENT type column
group by u.name, o.name, u2.name, o2.name, ac.name
union all
select /*+ ORDERED NOCOST */ u.name, o.name, u2.name, o2.name,attr.name,
   max(decode(tc.type#,0,'YES','NO')) COLUMN_LIST,
   decode(sum(decode(tc.type#, 5,  1, -- one occurrence of new in
                              6,  2, -- one occurrence of old in
                              9,  4, -- one occurrence of new out
                             10,  8, -- one occurrence of old out (impossible)
                             13,  5, -- one occurrence of new in out
                             14, 10, -- one occurrence of old in out (imp.)
                              null)
                ), -- result in the following combinations across occurrences
           1, 'NEW IN',
           2, 'OLD IN',
           3, 'NEW IN OLD IN',
           4, 'NEW OUT',
           5, 'NEW IN OUT',
           6, 'NEW OUT OLD IN',
           7, 'NEW IN OUT OLD IN',
          'NONE')
from sys.trigger$ t, sys.obj$ o, sys.user$ u, sys.user$ u2,
     sys.obj$ o2, sys.triggercol$ tc,
     sys.collection$ coll, sys.coltype$ ctyp, sys.attribute$ attr
where t.obj# = tc.obj#                -- find corresponding trigger definition
  and o.obj# = t.obj#                --    and corresponding trigger name
  and o2.obj# = t.baseobject        -- and name of the table containing the trigger
  and u2.user# = o2.owner#        -- and name of the user who owns the table
  and u.user# = o.owner#        -- and name of user who owns the trigger
  and bitand(t.property,32) = 32 -- and it is not a nested table col
  and bitand(tc.type#,16) <> 16  -- and it is not a PARENT type column 
  and ctyp.obj# = t.baseobject   -- find corresponding column type definition
  and ctyp.intcol# = t.nttrigcol -- and get the column type for the nested table
  and ctyp.toid = coll.toid      -- get the collection toid
  and ctyp.version# = coll.version# -- get the collection version
  and attr.attribute# = tc.intcol#  -- get the attribute number
  and attr.toid  = coll.elem_toid  -- get the attribute toid
  and attr.version# = coll.version#  -- get the attribute version
group by u.name, o.name, u2.name, o2.name, attr.name
union all
select /*+ ORDERED NOCOST */ u.name, o.name, u2.name, o2.name,'COLUMN_VALUE',
   max(decode(tc.type#,0,'YES','NO')) COLUMN_LIST,
   decode(sum(decode(tc.type#, 5,  1, -- one occurrence of new in
                              6,  2, -- one occurrence of old in
                              9,  4, -- one occurrence of new out
                             10,  8, -- one occurrence of old out (impossible)
                             13,  5, -- one occurrence of new in out
                             14, 10, -- one occurrence of old in out (imp.)
                              null)
                ), -- result in the following combinations across occurrences
           1, 'NEW IN',
           2, 'OLD IN',
           3, 'NEW IN OLD IN',
           4, 'NEW OUT',
           5, 'NEW IN OUT',
           6, 'NEW OUT OLD IN',
           7, 'NEW IN OUT OLD IN',
          'NONE')
from sys.trigger$ t, sys.obj$ o, sys.user$ u, sys.user$ u2,
     sys.obj$ o2, sys.triggercol$ tc
where t.obj# = tc.obj#                -- find corresponding trigger definition
  and o.obj# = t.obj#                --    and corresponding trigger name
  and o2.obj# = t.baseobject        -- and name of the table containing the trigger
  and u2.user# = o2.owner#        -- and name of the user who owns the table
  and u.user# = o.owner#        -- and name of user who owns the trigger
  and bitand(t.property,32) = 32 -- and it is not a nested table col
  and bitand(tc.type#,16) <> 16  -- and it is not a PARENT type column
  and tc.intcol# = 0
group by u.name, o.name, u2.name, o2.name,'COLUMN_VALUE'
/
create or replace public synonym DBA_TRIGGER_COLS for DBA_TRIGGER_COLS
/
grant select on DBA_TRIGGER_COLS to select_catalog_role
/
comment on table DBA_TRIGGER_COLS is
'Column usage in all triggers'
/
comment on column DBA_TRIGGER_COLS.TRIGGER_OWNER is
'Owner of the trigger'
/
comment on column DBA_TRIGGER_COLS.TRIGGER_NAME is
'Name of the trigger'
/
comment on column DBA_TRIGGER_COLS.TABLE_OWNER is
'Owner of the table'
/
comment on column DBA_TRIGGER_COLS.TABLE_NAME is
'Name of the table on which the trigger is defined'
/
comment on column DBA_TRIGGER_COLS.COLUMN_NAME is
'Name of the column or the attribute of the ADT column used in trigger definition'
/
comment on column DBA_TRIGGER_COLS.COLUMN_LIST is
'Is column specified in UPDATE OF clause?'
/
comment on column DBA_TRIGGER_COLS.COLUMN_USAGE is
'Usage of column within trigger body'
/

remark
remark    FAMILY "DEPENDENCIES"
remark    Dependencies between database objects
remark

create or replace view USER_DEPENDENCIES
  (NAME, TYPE, REFERENCED_OWNER, REFERENCED_NAME,
   REFERENCED_TYPE, REFERENCED_LINK_NAME, SCHEMAID, DEPENDENCY_TYPE)
as
select o.name,
       decode(o.type#, 0, 'NEXT OBJECT', 1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER',
                      4, 'VIEW', 5, 'SYNONYM', 6, 'SEQUENCE', 7, 'PROCEDURE',
                      8, 'FUNCTION', 9, 'PACKAGE', 10, 'NON-EXISTENT',
                      11, 'PACKAGE BODY', 12, 'TRIGGER',
                      13, 'TYPE', 14, 'TYPE BODY', 22, 'LIBRARY',
                      28, 'JAVA SOURCE', 29, 'JAVA CLASS', 
                      32, 'INDEXTYPE', 33, 'OPERATOR',
                      42, 'MATERIALIZED VIEW', 43, 'DIMENSION',
                      46, 'RULE SET', 55, 'XML SCHEMA', 56, 'JAVA DATA',
                      59, 'RULE', 62, 'EVALUATION CONTXT',
                      'UNDEFINED'),
       decode(po.linkname, null, pu.name, po.remoteowner), po.name,
       decode(po.type#, 0, 'NEXT OBJECT', 1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER',
                      4, 'VIEW', 5, 'SYNONYM', 6, 'SEQUENCE', 7, 'PROCEDURE',
                      8, 'FUNCTION', 9, 'PACKAGE', 10, 'NON-EXISTENT',
                      11, 'PACKAGE BODY', 12, 'TRIGGER',
                      13, 'TYPE', 14, 'TYPE BODY', 22, 'LIBRARY', 
                      28, 'JAVA SOURCE', 29, 'JAVA CLASS', 
                      32, 'INDEXTYPE', 33, 'OPERATOR',
                      42, 'MATERIALIZED VIEW', 43, 'DIMENSION',
                      46, 'RULE SET', 55, 'XML SCHEMA', 56, 'JAVA DATA',
                      59, 'RULE', 62, 'EVALUATION CONTXT',
                      'UNDEFINED'),
       po.linkname, userenv('SCHEMAID'),
       decode(bitand(d.property, 3), 2, 'REF', 'HARD')
from sys.obj$ o, sys.disk_and_fixed_objects po, sys.dependency$ d, sys.user$ pu
where o.obj# = d.d_obj#
  and po.obj# = d.p_obj#
  and po.owner# = pu.user#
  and o.owner# = userenv('SCHEMAID')
/
comment on table USER_DEPENDENCIES is
'Dependencies to and from a users objects'
/
comment on column USER_DEPENDENCIES.NAME is
'Name of the object'
/
comment on column USER_DEPENDENCIES.TYPE is
'Type of the object'
/
comment on column USER_DEPENDENCIES.REFERENCED_OWNER is
'Owner of referenced object (remote owner if remote object)'
/
comment on column USER_DEPENDENCIES.REFERENCED_NAME is
'Name of referenced object'
/
comment on column USER_DEPENDENCIES.REFERENCED_TYPE is
'Type of referenced object'
/
comment on column USER_DEPENDENCIES.REFERENCED_LINK_NAME is
'Name of dblink if this is a remote object'
/
create or replace public synonym USER_DEPENDENCIES for USER_DEPENDENCIES
/
grant select on USER_DEPENDENCIES to public with grant option
/

create or replace view ALL_DEPENDENCIES
  (OWNER, NAME, TYPE, REFERENCED_OWNER, REFERENCED_NAME,
   REFERENCED_TYPE, REFERENCED_LINK_NAME, DEPENDENCY_TYPE)
as
select u.name, o.name,
       decode(o.type#, 0, 'NEXT OBJECT', 1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER',
                      4, 'VIEW', 5, 'SYNONYM', 6, 'SEQUENCE', 7, 'PROCEDURE',
                      8, 'FUNCTION', 9, 'PACKAGE', 10, 'NON-EXISTENT',
                      11, 'PACKAGE BODY', 12, 'TRIGGER',
                      13, 'TYPE', 14, 'TYPE BODY', 22, 'LIBRARY',
                      28, 'JAVA SOURCE', 29, 'JAVA CLASS', 
                      32, 'INDEXTYPE', 33, 'OPERATOR',
                      42, 'MATERIALIZED VIEW', 43, 'DIMENSION',
                      46, 'RULE SET', 55, 'XML SCHEMA', 56, 'JAVA DATA',
                      59, 'RULE', 62, 'EVALUATION CONTXT',
                      'UNDEFINED'),
       decode(po.linkname, null, pu.name, po.remoteowner), po.name,
       decode(po.type#, 0, 'NEXT OBJECT', 1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER',
                      4, 'VIEW', 5, 'SYNONYM', 6, 'SEQUENCE', 7, 'PROCEDURE',
                      8, 'FUNCTION', 9, 'PACKAGE', 10, 'NON-EXISTENT',
                      11, 'PACKAGE BODY', 12, 'TRIGGER',
                      13, 'TYPE', 14, 'TYPE BODY', 22, 'LIBRARY',
                      28, 'JAVA SOURCE', 29, 'JAVA CLASS', 
                      32, 'INDEXTYPE', 33, 'OPERATOR',
                      42, 'MATERIALIZED VIEW', 43, 'DIMENSION',
                      46, 'RULE SET', 55, 'XML SCHEMA', 56, 'JAVA DATA', 
                      59, 'RULE', 62, 'EVALUATION CONTXT',
                      'UNDEFINED'),
       po.linkname,
       decode(bitand(d.property, 3), 2, 'REF', 'HARD')
from sys.obj$ o, sys.disk_and_fixed_objects po, sys.dependency$ d, sys.user$ u,
  sys.user$ pu
where o.obj# = d.d_obj#
  and o.owner# = u.user#
  and po.obj# = d.p_obj#
  and po.owner# = pu.user#
  and
  (
    o.owner# in (userenv('SCHEMAID'), 1 /* PUBLIC */)
    or
    (
      (
         (
          (o.type# = 7 or o.type# = 8 or o.type# = 9 or
           o.type# = 28 or o.type# = 29 or o.type# = 56)
          and
          o.obj# in (select obj# from sys.objauth$
                     where grantee# in (select kzsrorol from x$kzsro)
                       and privilege#  = 12 /* EXECUTE */)
        )
        or
        (
          o.type# = 4
          and
          o.obj# in (select obj# from sys.objauth$
                     where grantee# in (select kzsrorol from x$kzsro)
                       and privilege# in (3 /* DELETE */,   6 /* INSERT */,
                                                7 /* LOCK */,     9 /* SELECT */,
                                          10 /* UPDATE */))
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
              (o.type# = 7 or o.type# = 8 or o.type# = 9 or
               o.type# = 28 or o.type# = 29 or o.type# = 56)
              and
              (
                privilege# = -144 /* EXECUTE ANY PROCEDURE */
                or
                privilege# = -141 /* CREATE ANY PROCEDURE */
              )
            )
            or
            (
              /* trigger */
              o.type# = 12 and
              privilege# = -152 /* CREATE ANY TRIGGER */
            )
            or
            (
              /* package body */
              o.type# = 11 and
              privilege# = -141 /* CREATE ANY PROCEDURE */
            )
            or
            (
              /* view */
              o.type# = 4
              and
              (
                privilege# in     ( -91 /* CREATE ANY VIEW */,
                                    -45 /* LOCK ANY TABLE */,
                                    -47 /* SELECT ANY TABLE */,
                                    -48 /* INSERT ANY TABLE */,
                                    -49 /* UPDATE ANY TABLE */,
                                    -50 /* DELETE ANY TABLE */)
              )
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
    /* don't worry about tables, sequences, synonyms since they cannot */
    /* depend on anything */
  )
/
comment on table ALL_DEPENDENCIES is
'Dependencies to and from objects accessible to the user'
/
comment on column ALL_DEPENDENCIES.OWNER is
'Owner of the object'
/
comment on column ALL_DEPENDENCIES.NAME is
'Name of the object'
/
comment on column ALL_DEPENDENCIES.TYPE is
'Type of the object'
/
comment on column ALL_DEPENDENCIES.REFERENCED_OWNER is
'Owner of referenced object (remote owner if remote object)'
/
comment on column ALL_DEPENDENCIES.REFERENCED_NAME is
'Name of referenced object'
/
comment on column ALL_DEPENDENCIES.REFERENCED_TYPE is
'Type of referenced object'
/
comment on column ALL_DEPENDENCIES.REFERENCED_LINK_NAME is
'Name of dblink if this is a remote object'
/
create or replace public synonym ALL_DEPENDENCIES for ALL_DEPENDENCIES
/
grant select on ALL_DEPENDENCIES to public with grant option
/

create or replace view DBA_DEPENDENCIES
  (OWNER, NAME, TYPE, REFERENCED_OWNER, REFERENCED_NAME,
   REFERENCED_TYPE, REFERENCED_LINK_NAME, DEPENDENCY_TYPE)
as
select u.name, o.name,
       decode(o.type#, 0, 'NEXT OBJECT', 1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER',
                      4, 'VIEW', 5, 'SYNONYM', 6, 'SEQUENCE', 7, 'PROCEDURE',
                      8, 'FUNCTION', 9, 'PACKAGE', 10, 'NON-EXISTENT',
                      11, 'PACKAGE BODY', 12, 'TRIGGER',
                      13, 'TYPE', 14, 'TYPE BODY', 22, 'LIBRARY',
                      28, 'JAVA SOURCE', 29, 'JAVA CLASS', 
                      32, 'INDEXTYPE', 33, 'OPERATOR',
                      42, 'MATERIALIZED VIEW', 43, 'DIMENSION',
                      46, 'RULE SET', 55, 'XML SCHEMA', 56, 'JAVA DATA',
                      59, 'RULE', 62, 'EVALUATION CONTXT',
                      'UNDEFINED'),
       decode(po.linkname, null, pu.name, po.remoteowner), po.name,
       decode(po.type#, 0, 'NEXT OBJECT', 1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER',
                      4, 'VIEW', 5, 'SYNONYM', 6, 'SEQUENCE', 7, 'PROCEDURE',
                      8, 'FUNCTION', 9, 'PACKAGE', 10, 'NON-EXISTENT',
                      11, 'PACKAGE BODY', 12, 'TRIGGER',
                      13, 'TYPE', 14, 'TYPE BODY', 22, 'LIBRARY',
                      28, 'JAVA SOURCE', 29, 'JAVA CLASS', 
                      32, 'INDEXTYPE', 33, 'OPERATOR',
                      42, 'MATERIALIZED VIEW', 43, 'DIMENSION',
                      46, 'RULE SET', 55, 'XML SCHEMA', 56, 'JAVA DATA',
                      59, 'RULE', 62, 'EVALUATION CONTXT',
                      'UNDEFINED'),
       po.linkname,
       decode(bitand(d.property, 3), 2, 'REF', 'HARD')
from sys.obj$ o, sys.disk_and_fixed_objects po, sys.dependency$ d, sys.user$ u,
  sys.user$ pu
where o.obj# = d.d_obj#
  and o.owner# = u.user#
  and po.obj# = d.p_obj#
  and po.owner# = pu.user#
/
create or replace public synonym DBA_DEPENDENCIES for DBA_DEPENDENCIES
/
grant select on DBA_DEPENDENCIES to select_catalog_role
/
comment on table DBA_DEPENDENCIES is
'Dependencies to and from objects'
/
comment on column DBA_DEPENDENCIES.OWNER is
'Owner of the object'
/
comment on column DBA_DEPENDENCIES.NAME is
'Name of the object'
/
comment on column DBA_DEPENDENCIES.TYPE is
'Type of the object'
/
comment on column DBA_DEPENDENCIES.REFERENCED_OWNER is
'Owner of referenced object (remote owner if remote object)'
/
comment on column DBA_DEPENDENCIES.REFERENCED_NAME is
'Name of referenced object'
/
comment on column DBA_DEPENDENCIES.REFERENCED_TYPE is
'Type of referenced object'
/
comment on column DBA_DEPENDENCIES.REFERENCED_LINK_NAME is
'Name of dblink if this is a remote object'
/


remark
remark    PUBLIC_DEPENDENCIES
remark    Hierarchic dependency information by object number
remark

create or replace view PUBLIC_DEPENDENCY
  (OBJECT_ID, REFERENCED_OBJECT_ID)
as
select d.d_obj#, d.p_obj# from dependency$ d
/
comment on table PUBLIC_DEPENDENCY is
'Dependencies to and from objects, by object number'
/
comment on column PUBLIC_DEPENDENCY.OBJECT_ID is
'Object number'
/
comment on column PUBLIC_DEPENDENCY.REFERENCED_OBJECT_ID is
'The referenced (parent) object'
/
create or replace public synonym PUBLIC_DEPENDENCY for PUBLIC_DEPENDENCY
/
grant select on PUBLIC_DEPENDENCY to public with grant option
/

remark
remark    FAMILY "OBJECT_SIZE"
remark    Sizes of pl/sql items including types and type bodies.
remark       source_size - this part must be in memory when the object
remark                     is compiled, or dynamically recompiled
remark       parsed_size - this part must be in memory when an object that
remark                     references this object is being compiled
remark       code_size   - this part must be in memory when this object
remark                     is executing
remark       error_size  - this part exists if the object has compilation
remark                     errors and need only be in memory until the
remark                     compilation completes
remark    Tables and views will also appear if they were ever referenced by
remark    a pl/sql object.  They will only have a parsed component.
remark

remark Define some of the supporting views

create or replace view CODE_PIECES
(OBJ#, BYTES)
as
  select i.obj#, i.length
  from sys.idl_ub1$ i
  where i.part in (1,2)
union all
  select i.obj#, i.length
  from sys.idl_ub2$ i
  where i.part in (1,2)
union all
  select i.obj#, i.length
  from sys.idl_sb4$ i
  where i.part in (1,2)
union all
  select i.obj#, i.length
  from sys.idl_char$ i
  where i.part in (1,2)
/
grant select on CODE_PIECES to select_catalog_role
/

create or replace view CODE_SIZE
(OBJ#, BYTES)
as
  select c.obj#, sum(c.bytes)
  from sys.code_pieces c
  group by c.obj#
/
grant select on CODE_SIZE to select_catalog_role
/

create or replace view PARSED_PIECES
(OBJ#, BYTES)
as
  select i.obj#, i.length
  from sys.idl_ub1$ i
  where i.part = 0
union all
  select i.obj#, i.length
  from sys.idl_ub2$ i
  where i.part = 0
union all
  select i.obj#, i.length
  from sys.idl_sb4$ i
  where i.part = 0
union all
  select i.obj#, i.length
  from sys.idl_char$ i
  where i.part = 0
/
grant select on PARSED_PIECES to select_catalog_role
/

create or replace view PARSED_SIZE
(OBJ#, BYTES)
as
  select c.obj#, sum(c.bytes)
  from sys.parsed_pieces c
  group by c.obj#
/
grant select on PARSED_SIZE to select_catalog_role
/

create or replace view SOURCE_SIZE
(OBJ#, BYTES)
as
  select s.obj#, sum(length(s.source))
  from sys.source$ s
  group by s.obj#
/
grant select on SOURCE_SIZE to select_catalog_role
/

create or replace view ERROR_SIZE
(OBJ#, BYTES)
as
  select e.obj#, sum(e.textlength)
  from sys.error$ e
  group by e.obj#
/
grant select on ERROR_SIZE to select_catalog_role
/

create or replace view DBA_OBJECT_SIZE
(OWNER, NAME, TYPE, SOURCE_SIZE, PARSED_SIZE, CODE_SIZE, ERROR_SIZE)
as
  select u.name, o.name,
  decode(o.type#, 2, 'TABLE', 4, 'VIEW', 5, 'SYNONYM', 6, 'SEQUENCE',
    7, 'PROCEDURE', 8, 'FUNCTION', 9, 'PACKAGE', 11, 'PACKAGE BODY',
    12, 'TRIGGER', 13, 'TYPE', 14, 'TYPE BODY',
    28, 'JAVA SOURCE', 29, 'JAVA CLASS', 30, 'JAVA RESOURCE', 56, 'JAVA DATA',
    'UNDEFINED'),
  nvl(s.bytes,0), nvl(p.bytes,0), nvl(c.bytes,0), nvl(e.bytes,0)
  from sys.obj$ o, sys.user$ u,
    sys.source_size s, sys.parsed_size p, sys.code_size c, sys.error_size e
  where o.type# in (2, 4, 5, 6, 7, 8, 9, 11, 12, 13, 14, 28, 29, 30, 56)
    and o.owner# = u.user#
    and o.obj# = s.obj# (+)
    and o.obj# = p.obj# (+)
    and o.obj# = c.obj# (+)
    and o.obj# = e.obj# (+)
    and nvl(s.bytes,0) + nvl(p.bytes,0) + nvl(c.bytes,0) + nvl(e.bytes,0) > 0
/
create or replace public synonym DBA_OBJECT_SIZE for DBA_OBJECT_SIZE
/
grant select on DBA_OBJECT_SIZE to select_catalog_role
/
comment on table DBA_OBJECT_SIZE is
'Sizes, in bytes, of various pl/sql objects'
/
comment on column DBA_OBJECT_SIZE.OWNER is
'Owner of the object'
/
comment on column DBA_OBJECT_SIZE.NAME is
'Name of the object'
/
comment on column DBA_OBJECT_SIZE.TYPE is
'Type of the object: "TYPE", "TYPE BODY", "TABLE", "VIEW", "SYNONYM",
"SEQUENCE", "PROCEDURE", "FUNCTION", "PACKAGE", "PACKAGE BODY", "TRIGGER",
"JAVA SOURCE", "JAVA CLASS", "JAVA RESOURCE" or "JAVA DATA"'
/
comment on column DBA_OBJECT_SIZE.SOURCE_SIZE is
'Size of the source, in bytes.  Must be in memory during compilation, or
dynamic recompilation'
/
comment on column DBA_OBJECT_SIZE.PARSED_SIZE is
'Size of the parsed form of the object, in bytes.  Must be in memory when
an object is being compiled that references this object'
/
comment on column DBA_OBJECT_SIZE.CODE_SIZE is
'Code size, in bytes.  Must be in memory when this object is executing'
/
comment on column DBA_OBJECT_SIZE.ERROR_SIZE is
'Size of error messages, in bytes.  In memory during the compilation of the object when there are compilation errors'
/

create or replace view USER_OBJECT_SIZE
(NAME, TYPE, SOURCE_SIZE, PARSED_SIZE, CODE_SIZE, ERROR_SIZE)
as
  select o.name,
  decode(o.type#, 2, 'TABLE', 4, 'VIEW', 5, 'SYNONYM', 6, 'SEQUENCE',
    7, 'PROCEDURE', 8, 'FUNCTION', 9, 'PACKAGE', 11, 'PACKAGE BODY',
    13, 'TYPE', 14, 'TYPE BODY', 
    28, 'JAVA SOURCE', 29, 'JAVA CLASS', 30, 'JAVA RESOURCE', 56, 'JAVA DATA',
    'UNDEFINED'),
  nvl(s.bytes,0), nvl(p.bytes,0), nvl(c.bytes,0), nvl(e.bytes,0)
  from sys.obj$ o,
    sys.source_size s, sys.parsed_size p, sys.code_size c, sys.error_size e
  where o.type# in (2, 4, 5, 6, 7, 8, 9, 11, 28, 29, 30, 56)
    and o.owner# = userenv('SCHEMAID')
    and o.obj# = s.obj# (+)
    and o.obj# = p.obj# (+)
    and o.obj# = c.obj# (+)
    and o.obj# = e.obj# (+)
    and nvl(s.bytes,0) + nvl(p.bytes,0) + nvl(c.bytes,0) + nvl(e.bytes,0) > 0
/
comment on table USER_OBJECT_SIZE is
'Sizes, in bytes, of various pl/sql objects'
/
comment on column USER_OBJECT_SIZE.NAME is
'Name of the object'
/
comment on column USER_OBJECT_SIZE.TYPE is
'Type of the object: "TYPE", "TYPE BODY", "TABLE", "VIEW", "SYNONYM",
"SEQUENCE", "PROCEDURE", "FUNCTION", "PACKAGE", "PACKAGE BODY",
"JAVA SOURCE", "JAVA CLASS", "JAVA RESOURCE" or "JAVA DATA"'
/
comment on column USER_OBJECT_SIZE.SOURCE_SIZE is
'Size of the source, in bytes.  Must be in memory during compilation, or
dynamic recompilation'
/
comment on column USER_OBJECT_SIZE.PARSED_SIZE is
'Size of the parsed form of the object, in bytes.  Must be in memory when
an object is being compiled that references this object'
/
comment on column USER_OBJECT_SIZE.CODE_SIZE is
'Code size, in bytes.  Must be in memory when this object is executing'
/
comment on column USER_OBJECT_SIZE.ERROR_SIZE is
'Size of error messages, in bytes.  In memory during the compilation of the object when there are compilation errors'
/
create or replace public synonym USER_OBJECT_SIZE for USER_OBJECT_SIZE
/
grant select on USER_OBJECT_SIZE to public with grant option
/
