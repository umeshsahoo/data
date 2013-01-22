Rem
Rem $Header: initxqry.sql 28-apr-2005.17:23:48 ayoaz Exp $
Rem
Rem initxqry.sql
Rem
Rem Copyright (c) 2004, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      initxqry.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED
Rem    ayoaz       03/14/05 - change bind arg to xmltype
Rem    hxzhang     05/03/05 - added setLazyDom
Rem    kmuthiah    02/23/05 - load xquery in initxml.sql, not here
Rem    mkrishna    11/19/04 - pass in schema 
Rem    mkrishna    11/18/04 - multi args to JAva 
Rem    mkrishna    11/15/04 - remove references to xmlparser 
Rem    mkrishna    09/13/04 - make str size to be 4K 
Rem    mkrishna    08/23/04 - handle exceptions correctly 
Rem    mkrishna    08/21/04 - handle null entries in fetchall 
Rem    mkrishna    08/19/04 - use /a/node() instead of * 
Rem    mkrishna    08/15/04 - add new initxqry 
Rem    kmuthiah    08/11/04 - do not load private xmlparserv2.jar 
Rem    mkrishna    07/31/04 - add -f option 
Rem    mkrishna    07/23/04 - use nls_sort 
Rem    yinlu       07/21/04 - force to load xmlparserv2.jar 
Rem    mkrishna    06/15/04 - use clobs instead of strings 
Rem    zliu        05/11/04 - make execute parallel enabled
Rem    mkrishna    04/28/04 - mkrishna_xquery_server
Rem    mkrishna    03/31/04 - remove C dependency 
Rem    mkrishna    01/21/04 - change to DBMS_XQUERYINT 
Rem    mkrishna    01/15/04 - support function registeration 
Rem    mkrishna    01/15/04 - use CLOBS 
Rem    mkrishna    01/13/04 - use clobs 
Rem    mkrishna    01/07/04 - add range predicate 
Rem    mkrishna    12/22/03 - add public synonym for dbms_xquery 
Rem    mkrishna    12/08/03 - add getting XQueryX out 
Rem    mkrishna    09/04/03 - Created
Rem

create or replace package dbms_xqueryint authid current_user is 
 
 /* Fragment flag */
 QMXQRS_JAVA_FRAGMENT    CONSTANT NUMBER := 1;
 QMXQRS_JAVA_SCHEMABASED CONSTANT NUMBER := 2;

 function exec(hdl in number, retseq in number) 
   return sys.xmltype parallel_enable;

 FUNCTION execall(xqry in varchar2,  nlssrt in varchar2, nlscmp in varchar2, 
        dbchr in varchar2, retseq in number, lazydom in number)
  return sys.xmltype parallel_enable;

 function execute(xqry in varchar2, xctx in xmltype := null, 
                  retseq in number := 0) 
   return sys.xmltype parallel_enable;

 function getXQueryX(xqry in varchar2) return clob parallel_enable;

  function prepare (xqry in varchar2, nlssrt in varchar2, nlscmp in varchar2, dbchr in varchar2) return number;
  procedure bind(hdl in number, name in varchar2, flags in number, xctx in clob, schema in varchar2 ) ; 

 function bindXML(hdl in number, name in varchar2, xctx in sys.xmltype) 
  return number
  as LANGUAGE JAVA NAME
   'oracle.xquery.OXQServer.bindXML(int, java.lang.String, oracle.xdb.XMLType) 
     return int'; 

  procedure execQuery(hdl in number);
  function fetchAll(hdl in number, xctx in out clob, flags in out number)
  return number;
  function fetchOne(hdl in number, xctx in out clob, flags in out number, str out varchar2) return number;
  procedure closeHdl(hdl in number);
  procedure setLazyDom(hdl in number, lazy in number);

end;
/

CREATE OR REPLACE PACKAGE BODY dbms_xqueryint  AS
 
 FUNCTION prepare(xqry in varchar2,  
              nlssrt in varchar2, nlscmp in varchar2, dbchr in varchar2)  return number
   as LANGUAGE JAVA NAME
   'oracle.xquery.OXQServer.prepareQuery(java.lang.String, 
         java.lang.String, java.lang.String, java.lang.String) return int';

 /*pass null for context binds. */
 procedure bind(hdl in number, name  in varchar2, flags  in number, 
    xctx in clob, schema in varchar2)
  as LANGUAGE JAVA NAME
   'oracle.xquery.OXQServer.bind(int, java.lang.String, int, oracle.sql.CLOB,
     java.lang.String)'; 

 FUNCTION fetchOne(hdl in number, xctx in out clob, flags in out number,
     str out varchar2) return number as LANGUAGE JAVA NAME
   'oracle.xquery.OXQServer.fetch(int, oracle.sql.CLOB[], int[],
     java.lang.String[]) return int';

 FUNCTION fetchAll(hdl in number, xctx in out clob, flags in out number)
   return number
      as LANGUAGE JAVA NAME
   'oracle.xquery.OXQServer.fetchAll(int, oracle.sql.CLOB[], int[]) return int';

 procedure execQuery(hdl in number) as LANGUAGE JAVA NAME
   'oracle.xquery.OXQServer.execute(int)' ;

 procedure closeHdl(hdl in number) as LANGUAGE JAVA NAME
   'oracle.xquery.OXQServer.closeHdl(int)' ;

 procedure setLazyDom(hdl in number, lazy in number) as LANGUAGE JAVA NAME
   'oracle.xquery.OXQServer.setLazyDom(int, boolean)' ;

 /* return xmltype(content) */
 FUNCTION exec_cont(hdl in number) return sys.xmltype is
    clb clob := ' '; 
   ret xmltype := null;
   outflg number := 0;
   fetch_ok number ;
 begin
  
   fetch_ok := fetchAll(hdl, clb, outflg); 

   if  fetch_ok >= 1 then 
     if outflg  = QMXQRS_JAVA_FRAGMENT then
       ret :=  
       xmltype.createxml('<A>'||  clb || '</A>',null,1,1).extract('/A/node()'); 
     else
        ret :=  xmltype.createxml(clb, null, 1,1); 
     end if;
   end if;

   closeHdl(hdl);
   return ret;

 end;

 /* return a sequence */
 FUNCTION exec_seq(hdl in number) return sys.xmltype is
  fetch_ok number;
  str varchar2(4000);
  clb clob := ' '; 
   xval xmltype;
   ret xmltype := null;
  outflg number := 0;
 begin
  
   loop 

     fetch_ok := fetchOne(hdl, clb, outflg, str);
     if  fetch_ok = 0 then exit; end if;

     if  str is not null then
       select SYS_XQ_PKSQL2XML(str,  1,2) into xval from dual;
     else
       if outflg = QMXQRS_JAVA_FRAGMENT then
         xval := 
          xmltype.createxml('<A>'||clb ||'</A>',null,1,1).extract('/A/node()'); 
       else
         xval := xmltype.createxml(clb,null,1,1); 
       end if;
       clb := ' ';
     end if;
       
     select sys_xqconcat(ret, xval) into ret from dual; 
       
   end loop; 

   closeHdl(hdl); 
   return ret; 
 end;

 FUNCTION exec(hdl in number, retseq in number) 
  return sys.xmltype is
 begin
   if retseq = 1 then
     return exec_seq(hdl);
   else
     return exec_cont(hdl);
   end if;
 end;

 FUNCTION getXQueryX(xqry in varchar2)  return clob  as LANGUAGE JAVA NAME
 'oracle.xquery.OXQServer.getXQueryX(java.lang.String) return oracle.sql.CLOB';

 FUNCTION execall(xqry in varchar2,  nlssrt in varchar2, nlscmp in varchar2, 
        dbchr in varchar2, retseq in number, lazydom in number)  
  return sys.xmltype is
    hdl number;
 begin
  hdl := prepare(xqry, nlssrt, nlscmp, dbchr);
  if lazydom = 1 then
    setLazyDom(hdl,lazydom);
  end if;
  execQuery(hdl);
  return exec(hdl, retseq);
 end;

 /* testing function */
 FUNCTION execute(xqry in varchar2, xctx in xmltype:=null, retseq in number := 0) 
  return sys.xmltype  parallel_enable is
   a number := 0;
   dbchr varchar2(30);
   nlscmp varchar2(30);
   nlssrt varchar2(30);
   hdl number;
 begin

  select value into dbchr from v$nls_parameters where 
      parameter = 'NLS_CHARACTERSET';
  select value into nlssrt from v$nls_parameters where 
      parameter = 'NLS_SORT';
  select value into nlscmp from v$nls_parameters where 
      parameter = 'NLS_COMP';

   hdl := prepare(xqry, nlssrt, nlscmp, dbchr);

   if xctx is not null then
      if xctx.isFragment() = 1 then
        a := QMXQRS_JAVA_FRAGMENT;
      end if; 
      bind(hdl, null, a, xctx.getclobval(), xctx.getSchemaURL());
   end if;

  execQuery(hdl);
  return exec(hdl, retseq);

 end;

end;
/
show errors;

grant execute on dbms_xqueryint to public with grant option;
