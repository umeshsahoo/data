Rem
Rem utlip.sql
Rem
Rem Copyright (c) 1998, 2005, Oracle. All rights reserved.  
Rem
Rem   NAME
Rem     utlip.sql - UTiLity script to Invalidate & Recompile Pl/sql modules
Rem
Rem   DESCRIPTION
Rem     This script can be used to invalidate all existing PL/SQL modules
Rem     (procedures, functions, packages, types, triggers, views) in a
Rem     database so that they will be forced to be recompiled later on
Rem     either automatically or deliberately.
Rem
Rem     This script must be run when it is necessary to regenerate the
Rem     compiled code because an action was taken that caused the old code's
Rem     format to be inconsistent with what it's supposed to be, e.g., when
Rem     migrating a 32 bit database to a 64 bit database or vice-versa.
Rem
Rem     STEPS:
Rem
Rem     (I) Invalidate all stored PL/SQL units (procedures, functions,
Rem           packages, types, triggers).
Rem
Rem     (II) Reload PL/SQL package STANDARD and package DBMS_STANDARD.
Rem
Rem     (III) Selectively invalidate views and synonyms
Rem
Rem     (IV) Delete rows from IDL_* tables for tables and views
Rem
Rem   NOTES
Rem      * This script must be run using SQL*PLUS.
Rem      * You must be connected AS SYSDBA to run this script.
Rem      * This script expects the following files to be available in the
Rem        current directory:
Rem          standard.sql
Rem          dbmsstdx.sql
Rem      * There should be no other DDL on the database while running the
Rem        script.  Not following this recommendation may lead to deadlocks.
Rem
Rem   MODIFIED   (MM/DD/YY)
Rem    weiwang     05/06/05 - invalidate rules engine objects 
Rem    ciyer       07/24/04 - selectively invalidate views and synonyms 
Rem    jmuller     02/12/04 - Fix bug 3432304: commit even if no rows deleted 
Rem    gviswana    08/28/03 - 3103287: Remove Diana deletions for PL/SQL 
Rem    jmallory    08/18/03 - Hardcode dbms_dbupgrade_subname
Rem    gviswana    06/23/03 - 2985184: Invalidate dependent views
Rem    kquinn      07/22/03 - 3009599: Handle remote dbms_standard case
Rem    jmallory    06/09/03 - Fix null checking
Rem    jmallory    03/31/03 - Exclude dbupgrade objects
Rem    gviswana    04/16/03 - Move system parameter handling to utlirp.sql
Rem    kmuthukk    02/03/03 - fix update performance
Rem    nfolkert    12/23/02 - invalidate summary objects
Rem    kmuthukk    10/22/02 - ncomp dlls in db
Rem    gviswana    10/28/02 - Deferred synonym translation
Rem    rdecker     11/09/01 - remove CREATE library code FOR bug 1952368
Rem    gviswana    08/17/01 - Break up IDL_ deletes to avoid blowing rollback
Rem    rburns      08/23/01 - bug 1950073 - add exit on error
Rem    rburns      08/24/01 - add plitblm
Rem    rburns      07/26/01 - invalidate index types and operators
Rem    rxgovind    04/30/01 - interim fix for bug-1747462
Rem    gviswana    10/19/00 - Disable system triggers for Standard recompile
Rem    sbalaram    06/01/00 - Add prvthssq.sql after resolving Bug 1292760
Rem    thoang      05/26/00 - Do not invalidate earlier type versions 
Rem    jdavison    04/11/00 - Modify usage notes for 8.2 changes.
Rem    rshaikh     09/22/99 - quote library names
Rem    mjungerm    06/15/99 - add java shared data object type
Rem    rshaikh     02/12/99 - dont delete java idl objects
Rem    rshaikh     11/17/98 - remove obsolete comments
Rem    rshaikh     10/30/98 - add slash after last truncate stmt
Rem    abrik       10/01/98 - just truncate idl_*$ tables
Rem    rshaikh     10/14/98 - bug 491101: recreate libraries
Rem    ncramesh    08/04/98 - change for sqlplus
Rem    rshaikh     07/20/98 - add commits
Rem    usundara    06/03/98 - merge from 8.0.5
Rem    usundara    04/29/98 - creation (split from utlirp)
Rem                           Kannan Muthukkaruppan (kmuthukk) was the original
Rem                           author of this script.

Rem ===========================================================================
Rem BEGIN utlip.sql
Rem ===========================================================================

Rem Exit immediately if Any failure in this script
WHENEVER SQLERROR EXIT;        

-- Step (I)
--
-- First we invalidate all stored PL/SQL units (procs, fns, pkgs,
-- types, triggers.)
--
--   The type# in the update statement below indicates the KGL
--   type of the object. They have the following interpretation:
--       7 - pl/sql stored procedure
--       8 - pl/sql stored function
--       9 - pl/sql pkg spec
--      11 - pl/sql pkg body
--      12 - trigger
--      13 - type spec
--      14 - type body
--      22 - library
--      32 - indextype
--      33 - operator
-- 
-- Earlier type versions do not need to be invalidated since all pgm
-- units reference latest type versions. There is no mechanisms to
-- recompile earlier type versions anyway. They must be kept valid so
-- we can get access to its TDO to handle image conversion from one type
-- version to another. 
-- All earlier type versions has the version name stored in obj$.subname
-- and the latest type version always has a null subname. We use this
-- fact to invalidate only the latest type version.
update obj$ set status = 6 
        where ((type# in (7, 8, 9, 11, 12, 14, 22, 32, 33)) or
               (type# = 13 and subname is null)) 
        and ((subname is null) or (subname <> 'DBMS_DBUPGRADE_BABY'))
        and status not in (5,6) 
        and linkname is null
        and not exists (select 1
                        from type$ 
                        where (bitand(properties, 16) = 16) 
                        and toid = obj$.oid$)
/
commit
/

Rem Always invalidate MVs during upgrades/ downgrades
update obj$ set status = 5 where type# = 42;
commit;

UPDATE sys.obj$ SET status = 5
where obj# in
  ((select obj# from obj$ where type# = 62 or type# = 46 or type# = 59)
   union all
   (select /*+ index (dependency$ i_dependency2) */ 
      d_obj# from dependency$
      connect by prior d_obj# = p_obj#
      start with p_obj# in
        (select obj# from obj$ where type# = 62 or type# = 46 or type# = 59)))
/
commit
/

alter system flush shared_pool
/

-- Step (II)
--
-- Recreate package standard and dbms_standard. This is needed to execute
-- subsequent anonymous blocks
@@standard
@@dbmsstdx

-- Step (III)
--
-- Invalidate views and synonyms which depend (directly or indirectly) on
-- invalid objects.
begin
  loop
    update obj$ o_outer set status = 6
    where     type# in (4, 5)
          and status not in (5, 6)
          and linkname is null
          and ((subname is null) or (subname <> 'DBMS_DBUPGRADE_BABY'))
          and exists (select o.obj# from obj$ o, dependency$ d
                      where     d.d_obj# = o_outer.obj#
                            and d.p_obj# = o.obj#
                            and (bitand(d.property, 1) = 1)
                            and o.status > 1);
    exit when sql%notfound;
  end loop;
end;
/

commit;

alter system flush shared_pool 
/ 

-- Step (IV)
--
-- Delete Diana for tables and views
--
-- The DELETEs are coded in chunks using a PL/SQL loop to avoid running
-- into rollback segment limits.
--
-- Bug 3432304: Ensure we 'commit' even if no rows are deleted.  Otherwise,
-- we'll be in an open transaction at the end of this script, making it
-- impossible to shut down the database. 
begin

   loop
      delete from idl_ub1$ where
         obj# in (select o.obj# from obj$ o where o.type# in (2, 4))
         and rownum < 5000;
      exit when sql%rowcount = 0;
      commit;
   end loop;
   
   -- 
   -- IDL_UB2$ must use dynamic SQL because its PIECE type is not
   -- understood by PL/SQL.
   --
   loop
      execute immediate
         'delete from idl_ub2$ where
          obj# in (select o.obj# from obj$ o where o.type# in (2, 4))
          and rownum < 5000';
      exit when sql%rowcount = 0;
      commit;
   end loop;
      
   -- 
   -- IDL_SB4$ must use dynamic SQL because its PIECE type is not
   -- understood by PL/SQL.
   --
   loop
      execute immediate
         'delete from idl_sb4$ where
          obj# in (select o.obj# from obj$ o where o.type# in (2, 4))
          and rownum < 5000';
      exit when sql%rowcount = 0;
      commit;
   end loop;

   loop
      delete from idl_char$ where
         obj# in (select o.obj# from obj$ o where o.type# in (2, 4))
         and rownum < 5000;
      exit when sql%rowcount = 0;
      commit;
   end loop;
end;
/
commit
/
 
alter system flush shared_pool
/

Rem Continue even if there are SQL errors 
WHENEVER SQLERROR CONTINUE;  

Rem ===========================================================================
Rem END utlip.sql
Rem ===========================================================================
