rem
rem $Header: pistub.sql 28-may-99.14:18:53 jmuller Exp $
rem
Rem  Copyright (c) 1991, 1999 by Oracle Corporation
Rem    NAME
Rem      pistub.sql - subprogram stub generator
Rem    DESCRIPTION
Rem      equivalent to v7$pls:[qa]pstub.pls
Rem    MODIFIED   (MM/DD/YY)
Rem     jmuller    05/28/99 -  Fix bug 708690: TAB -> blank
Rem     pshaw      10/21/92 -  modify script for bug 131187 
Rem     gclossma   09/08/92 -  allow null dbname in cursor in pstub 
Rem     gclossma   08/05/92 -  impl pstub in terms of pistub 
Rem     gclossma   07/14/92 -  pstubT: add constraints to CHARs; bigger pkgs 
Rem     gclossma   06/22/92 -  pstubt: gen stubs into table PSTUBTBL 
Rem     gclossma   05/08/92 -  simplify; check buffer lengths 
Rem     gclossma   04/10/92 -  gen CHAR stead of VARCHAR2 for sqlforms3 for v6 
Rem     ahong      03/24/92 -  add s_notInPackage 
Rem     ahong      03/13/92 -  rpc 
Rem     ahong      03/10/92 -  fix func stub 
Rem     ahong      02/26/92 -  fix subptxt 
Rem     ahong      01/07/92 -  icd for DESCRIBE
Rem     pdufour    01/03/92 -  remove connect internal and add drop package
Rem     gclossma   11/27/91 -  Creation



-- pstub:         procedure returning stub text of a subprogram
--         In:  pname - subprogram name
--              subname - NULL or member name of package pname
--              uname - user name, NULL or '' to mean current user
--              flags - string,  '6' for v6 compatibility mode in which
--                      'CHAR' is gen'd in place of 'VARCHAR2' in stubs
--         Out:
--              stubSpec - null if subprogram is a top level proc/func
--                         else contain package spec
--              stubText - contains stub body
--                  '$$$ s_subpNotFound' -> subprog not found; stubSpec empty
--                  '$$$ s_notInPackage' -> cannot find subname in pname
--                  '$$$ s_stubTooLong' -> stub text too long; stubSpec empty
--                  '$$$ s_logic' -> logic error; stubSpec empty
--                  '$$$ s_defaultVal' -> default parameter values exist;
--                                       stubSpec empty
--                  '$$$ s_other' -> other failure

-- pstub calls diutil.pstub:
--         In:  pname - subprogram name
--              subname - NULL or member name of package pname
--              uname - user name, NULL or '' to mean current user
--              dbname - database name, null or '' for current
--              dbowner - database owner, null or '' for current
--              flags - string,  '6' for v6 compatibility mode in which
--                      'CHAR' is gen'd in place of 'VARCHAR2' in stubs
--         Out:
--              stubSpec - null if subprogram is a top level proc/func
--                         else contain package spec
--              stubText - contains stub body
--              status - error code, see package DIUTIL

-- NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE
-- NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE
-- NOTE: you must be connected "internal" (as user SYS) to run this script.
-- NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE
-- NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE


---------------------------------------------------------------------

-- pstubt:      generates stub text into table PSTUBTBL
--         In:  pname - program (package or subprogram) name
--              uname - user name, NULL or '' to mean current user
--              dbname - unused, for compatitility with plsv1 psdglu()
--              flags - string,  '6' for v6 compatibility mode in which
--                      'CHAR' is gen'd in place of 'VARCHAR2' in stubs
--         Out:
--              rc - an OUT varchar2 of length 40.  It is set as follows:
--                  'PKG' if package stub was successfully generated to table
--                  'SUB' if subprogram stub was successfully gen'd to table
--                  '$$$ s_subpNotFound' -> program not found
--                  '$$$ s_notInPackage' -> cannot find subname in pname
--                  '$$$ s_stubTooLong' -> stub text too long
--                  '$$$ s_logic' -> logic error
--                  '$$$ s_defaultVal' -> default parameter values exist;
--                  '$$$ s_other' -> other failure

/* PSTUBT: stores generated stubs in rows of table PSTUBTBL */
drop procedure sys.pstubt;
create procedure sys.pstubt (pname varchar2, uname varchar2, dbname varchar2,
                             flags varchar2, rc OUT varchar2) is
  status diutil.ub4 := 0;
  lutype varchar2(10);
begin
  rc := '';
  diutil.pstub(pname, '', uname, dbname, '', status, flags, lutype);
  if (status <> diutil.s_ok and status <> diutil.s_defaultVal) then
        if (status = diutil.s_subpNotFound) then
            rc := '$$$ s_subpNotFound';
        elsif (status = diutil.s_stubTooLong) then
            rc := '$$$ s_stubTooLong';
        elsif (status = diutil.s_logic) then
            rc := '$$$ s_logic';
        elsif (status = diutil.s_notInPackage) then
            rc := '$$$ s_notInPackage';
        elsif (status = diutil.s_notv6Compat) then
            rc := '$$$ s_notv6Compat';
        else rc := '$$$ s_other';
        end if;
  else rc := lutype;
  end if;
end;
/
grant execute on pstubt to public;

-- pstub is older interface, now implemented in terms of pstubt

drop procedure sys.pstub;
create procedure sys.pstub(pname varchar2, uname varchar2,
                        stubSpec in out varchar2, stubText in out varchar2,
                        flags varchar2 := '6') is
  rc varchar2(40);
  ty varchar2(5);
  cursor tub (una varchar2, dbna varchar2, luna varchar2, luty varchar2) is
        select line from sys.pstubtbl 
        where (una is null or username = una) and
              (dbna is null or dbname = dbna) and
              lun = luna and lutype = luty
        order by lineno;
begin -- main
  sys.pstubt(pname, uname, '', flags, rc);
  if rc like '$$$%' then stubText := rc; return; end if;
  if not (rc = 'PKG' or rc = 'SUB') 
    then stubText := '$$$ other'; return; 
  end if;
  stubSpec := '';
  stubText := '';
  if rc = 'PKG' then
    for s in tub(uname, '', pname, 'PKS') loop
      stubSpec := stubSpec || s.line;
    end loop;
  end if;
  if rc = 'PKG' then ty := 'PKB'; else ty := 'SUB'; end if;
  for s in tub(uname, '', pname, ty) loop
    stubText := stubText || s.line;
  end loop;
end;
/
grant execute on pstub to public;


---------------------------------------------------------------------
--
--  subptxt2: returns the text of a subprogram source (DESCRIBE).
--      In: name - package or toplevel proc/func name;
--          subname - non-null to specify proc/func in package <name>.
--          usr - user name
--          dbname - database name, null or '' for current
--          dbowner - database owner, null or '' for current
--      Out:  subprogram text in txt
--          '$$$ s_subpNotFound' -> subprog not found; txt empty
--          '$$$ s_stubTooLong' -> stub text too long; txt empty
--          '$$$ s_logic' -> logic error; txt empty
--          '$$$ s_notInPackage' -> cannot find subname in package <name>
--          '$$$ s_other' -> other failure

drop procedure sys.subptxt2;
create procedure sys.subptxt2(name varchar2, subname varchar2, usr varchar2,
                             dbname varchar2, dbowner varchar2,
                             txt in out varchar2) is
status diutil.ub4;

begin -- main
    diutil.subptxt(name, subname, usr, dbname, dbowner, txt, status);
    if (status <> diutil.s_ok) then
        if (status = diutil.s_subpNotFound) then
            txt := '$$$ s_subpNotFound';
        elsif (status = diutil.s_stubTooLong) then
            txt := '$$$ s_stubTooLong';
        elsif (status = diutil.s_logic) then
            txt := '$$$ s_logic';
        elsif (status = diutil.s_notInPackage) then
            txt := '$$$ s_notInPackage';
        else txt := '$$$ s_other';
        end if;
    end if;
end subptxt2;
/

---------------------------------------------------------------------

-- subptxt - similar to subptxt2, but w/o dbname and dbowner


drop procedure sys.subptxt;
create procedure sys.subptxt(name varchar2, subname varchar2, usr varchar2,
                             txt in out varchar2) is
begin
    subptxt2(name, subname, usr, null, null, txt);
end;
/
grant execute on subptxt to public;

