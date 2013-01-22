rem 
rem $Header: catproc.sql 02-sep-2005.11:07:28 mxu Exp $ 
rem 
Rem Copyright (c) 1991, 2005, Oracle. All rights reserved.  
Rem    NAME
Rem      catproc.sql
Rem    DESCRIPTION
Rem      Run all sql scripts for the procedural option
Rem    RETURNS
Rem 
Rem    NOTES
Rem      This script must be run while connected AS SYSDBA.
Rem    MODIFIED   (MM/DD/YY)
Rem     mxu        09/02/05 - Add dbmshtdb 
Rem     cdilling   08/15/05 - move set of edition to loading time
Rem     srirkris   08/07/05 - remove dbmssjty and prvtsjty
Rem     mbrey      08/08/05 - bug 4531051 
Rem     rburns     08/03/05 - add edition for catproc 
Rem     jmuller    04/18/05 - Fix bug 3741976: dependency of dbms_utility body 
Rem                           on utl_recomp 
Rem     sylin      12/01/04 - Add prvtscrp.plb
Rem     lvbcheng   03/01/05 - Split DBMS_ASSERT from dbmsutil.sql 
Rem     schakkap   02/16/05 - #(4180670) register additional component schemas 
Rem     jnesheiw   02/14/05 - Bug4028220
Rem     jmallory   01/31/05 - Remove prvtdupg (dbms_dbupgrade) 
Rem     kneel      10/04/04 - moving prvtkjhn.plb call to cathae.sql 
Rem     dgagne     10/04/04 - split catdp into package headers and package 
Rem                           body files 
Rem     pyoun      09/29/04 - load prvtdtde.plb 
Rem     pyoun      09/24/04 - add tde_library to catproc in two files, 
Rem                           declaration and body declaration. 
Rem     rburns     09/13/04 - check for SYS user 
Rem     pyoun      08/30/04 - adding prvtdpcr.plb to file 
Rem     ycao       08/23/04 - bug 3841411: move lob$ little endian block 
Rem                           to c0902000.sql
Rem     mxyang     07/30/04 - add dbmspp
Rem     htran      06/21/04 - load prvthlin.plb here. load prvthsdp earlier.
Rem     nikeda     06/29/04 - Add cathae.sql 
Rem     liwong     06/29/04 - load dbmsany before dbmsutil
Rem     kneel      06/09/04 - place prvtkjhn (package dbms_ha_alerts_prvt) 
Rem                           after catsvrm 
Rem     kneel      06/08/04 - add package dbms_ha_alerts_prvt 
Rem     ssvemuri   06/15/04 - change notification catalog
Rem     rburns     06/04/04 - move prvtcr before logical standby
Rem     smuthuli   06/17/04 - move dbms_space to space 
Rem     rvissapr   05/21/04 - Add prvtlink.sql
Rem     gviswana   05/06/04 - Add dbmsddl 
Rem     chiappa    04/28/04 - Call olappl.sql rather than packages
Rem     rdecker    03/19/04 - add utl_match package for OWB
Rem     jciminsk   02/06/04 - merge from RDBMS_MAIN_SOLARIS_040203 
Rem     lvbcheng   01/02/04 - Add utl_nla 
Rem     skaluska   12/15/03 - merge from RDBMS_MAIN_SOLARIS_031209 
Rem     jciminsk   12/12/03 - merge from RDBMS_MAIN_SOLARIS_031209 
Rem     rvenkate   07/23/03 - move prvthlut before AQ
Rem     lchidamb   07/05/03 - move catidir.sql after catsvrm.sql
Rem     mxyang     05/19/04 - add dbmsdbvn.sql
Rem     nfolkert   04/14/04 - moved prvtidxu before prvtsnap
Rem     smuthuli   05/23/04 - auto space advisor
Rem     najain     12/10/03 - remove catxdao.sql
Rem     mxiao      11/04/03 - load prvtsum before prvtsnap
Rem     najain     11/04/03 - call catxdao
Rem     rbollu     10/22/03 - fix bug#3197595 
Rem     gtarora    10/08/03 - little endian 
Rem     weiwang    09/08/03 - move prvttxfm.plb 
Rem     rburns     09/09/03 - cleanup 
Rem     tfyu       08/14/03 - add prvtrwee.plb
Rem     rvenkate   07/23/03 - move prvthlut before AQ
Rem     lchidamb   07/05/03 - move catidir.sql after catsvrm.sql
Rem     ychan      06/26/03 - Change catsnmp order
Rem     sylin      07/02/03 - Move dbmslob before prvtcmpl and utlcomp
Rem     alakshmi   04/09/03 - reorder dbmsxfr.sql
Rem     sltam      05/29/03 - Bug 2982373: remove an extra invocation of dbmssrv
Rem     gssmith    05/29/03 - Remove PRVT_WORKLOAD temp fix
Rem     gssmith    05/28/03 - Apply work-around for PRVT_WORKLOAD invalidation bug
Rem     sylin      04/30/03 - Add prvtcmpl.plb
Rem     gviswana   04/13/03 - Add utlrcmp.sql
Rem     ychan      05/14/03 - Change comment for catsnmp
Rem     pabingha   05/13/03 - add CDC Data Pump support
Rem     ychan      05/11/03 - Move catsnmp
Rem     abegueli   05/05/03 - create sys.srvqueue
Rem     rburns     04/26/03 - use serveroutput for diagnostics
Rem     jstamos    04/24/03 - add director objects
Rem     skaluska   04/17/03 - move from dbmstsm to prvttsms, prvttsmb
Rem     skaluska   04/15/03 - rename dbmsmig to dbmstsm
Rem     nshodhan   04/15/03 - add prvthlut.plb
Rem     skaluska   03/20/03 - add dbmsmig, prvtmig
Rem     raguzman   03/10/03 - move catlsby from catalog to catproc
Rem     veeve      03/12/03 - moved manageability components
Rem                           prvthdm,prvtadv,prvtuadv to catsvrm
Rem     wyang      03/05/03 - move undo advisor after swrf table created
Rem     bdagevil   02/24/03 - run catplan.sql
Rem     htran      02/14/03 - load prvthsdp.plb
Rem     dsemler    02/13/03 - dbms_services start,stop, create, delete
Rem     elu        02/03/03 - move prvtlmrd
Rem     raguzman   02/10/03 - lsby must follow datapump
Rem     weiwang    01/31/03 - move prvtreie after catdp
Rem     sltam      01/16/03 - Add dbmssrv.sql
Rem     schakkap   01/28/03 - catost.sql
Rem     jingliu    12/30/02 - change load order of prvtsnap.sql
Rem     nfolkert   12/18/02 - add prvtidxu,dbmsidxu, mv catsch before prvtsnap
Rem     srtata     12/17/02 - call catdip.sql
Rem     rburns     11/30/02 - add prvtcr
Rem     kdias      11/19/02 - add prvthdm.sql
Rem     sagrawal   10/09/02 - PL/SQL warning code clean up
Rem     weili      11/06/02 - create dbms_frequent_itemset package
Rem     lvbcheng   11/06/02 - Add profiler to catproc
Rem     wyang      10/23/02 - add dbms_fbt
Rem     bemeng     10/23/02 - add dbmsdbv.sql
Rem     wxli       10/29/02 - Adding Apps abd DB upgrade packages
Rem     wyang      11/19/02 - undo advisor
Rem     mmorsi     10/07/02 - Adding the dbmscoll for the collect as UDAG
Rem     pabingha   10/15/02 - move CDC after Streams
Rem     dalpern    10/11/02 - support triggering java dumps via kga
Rem     masubram   10/10/02 - load prvthord after catdp
Rem     nfolkert   10/08/02 - added catidxu before prvtutil
Rem     bdagevil   10/07/02 - move [g]v$sql_bind_capture from catalog.sql
Rem     tbingol    10/03/02 - Add dbmsstts and prvtstts
Rem     btao       09/30/02 - add manageability advisor scripts
Rem     ilam       09/25/02 - add trace conversion
Rem     jstamos    09/17/02 - add file transfer
Rem     ayoaz      09/05/02 - move dbmsany before catodci
Rem     jihuang    09/04/02 - add dbmsfic.sql
Rem     dgagne     08/30/02 - move catdp after dbmsjdwp
Rem     ywu        08/08/02 - add UTL_LMS
Rem     gssmith    08/06/02 - Adding Advisor components
Rem     kmuthukk   06/27/02 - remove embedded plsql gateway code
Rem     yuli       05/09/02 - reorder dbmspitr and dbmsplts
Rem     sagrawal   04/18/02 - PL/SQL warnings
Rem     gclaborn   04/10/02 - add catdp.sql, remove catmet, mv prvtpdi to catdp
Rem     rburns     04/01/02 - use default registry banner
Rem     ebatbout   04/04/02 - Prvthpdi.plb must be loaded before catmet.sql
Rem                           and Prvtbpdi.plb must be loaded after catmet.sql
Rem     ebatbout   03/20/02 - Add prvthpdi.plb,prvtbpdi.plb(datapump data pkg).
Rem     esoyleme   02/27/02 - remove xumuts.plb
Rem     rburns     02/20/02 - re-validate catalog
Rem     rburns     02/11/02 - add registry version
Rem     rpang      01/25/02 - add UTL_GDK
Rem     esoyleme   01/23/02 - bring in changes from oraolap
Rem     cchiappa   01/15/02 - cchiappa_txn100947
Rem     emagrath   01/09/02 - Elim. endian REF problem
Rem     rburns     10/26/01 - add registry validation
Rem     rdecker    11/02/01 - remove owa debug packages (installed BY iAS now)
Rem     skaluska   11/02/01 - add prvtreut.plb
Rem     sbalaram   11/02/02 - add catstr
Rem     wesmith    10/23/01 - remove catplrep.sql
Rem     liwong     10/23/01 - Add catpstr.sql
Rem     skmishra   10/19/01 - merge LOG inot MAIN
Rem     rguzman    09/13/01 - define dbmslsby early so prvtjob can reference it
Rem     weiwang    09/07/01 - add prvtreie
Rem     dvoss      07/25/01 - Load logminer files prvtlmc.plb and prvtlmrd.plb
Rem     skaluska   08/17/01 - move rules engine creation.
Rem     narora     06/28/01 - add catplrep
Rem     esoyleme   09/25/01 - call  catxs.sql.
Rem     ayoaz      10/12/01 - move catodci to before dbmsstat spec
Rem     rburns     10/05/01 - use 9.2.0 as current release
Rem     rdecker    09/18/01 - add owa_debug_jdwp support
Rem     eehrsam    09/28/01 - Move utl_raw above utl_file.
Rem     lbarton    09/05/01 - use mdAPI jacket script
Rem     rburns     08/22/01 - add component registry
Rem     dgagne     08/28/01 - add catnomet as first line for metadata api
Rem     wojeil     08/30/01 - adding prvtmap.plb.
Rem     dvoss      07/25/01 - Load logminer files prvtlmc.plb and prvtlmrd.plb
Rem     pravelin   08/13/01 - Run caths AFTER catrep.
Rem     pravelin   07/26/01 - Add caths for Heterogeneous Services.
Rem     kmuthukk   04/27/01 - conditionally install/upgrade owa pkgs
Rem     qiwang     04/30/01 - add logical standby procedures.
Rem     mkrishna   04/18/01 - add all XML components
Rem     rguzman    04/04/01 - Remove Logical Standby scripts until 9iR2.
Rem     yhu        03/08/01 - add dbms_odci package.
Rem     nle        02/24/01 - Change sql file for embedded gateway
Rem     eehrsam    02/05/01 - add utl_encode package
Rem     abrown     01/11/01 - split wrapped part of dbmslmd into prvtlmd
Rem     arrajara   01/06/01 - Install replication catalog
Rem     jgalanes   12/19/00 - Fix bug 1549046 by changing the order of 
Rem                           the CDC packages.
Rem     wnorcott   12/19/00 - re-order CDC packages.  bug 1549046
Rem     varora     12/15/00 - rename dbmssqljtype to dbmssjty
Rem     rpang      12/10/00 - Add dbmsjdcu.sql
Rem     aime       12/08/00 - move dbmslob before AQ
Rem     lbarton    12/01/00 - metadata api install
Rem     ctrezza    11/09/00 - Adding Data Guard support.
Rem     shihliu    10/23/00 - add dbms_resumable
Rem     ssvemuri   10/27/00 - Invoke dbmstran and prvttran correctly.
Rem     rdecker    04/26/00 - load packages FOR embedded plsql gateway
Rem     varora     09/26/00 - add prvtsqljtype
Rem     rpang      09/18/00 - Added utl_url
Rem     mthiyaga   09/22/00 - Add prvtxrmv.plb
Rem     ssvemuri   09/19/00 - dejaview file rename.
Rem     amganesh   09/13/00 - dejaview.
Rem     jstenois   08/30/00 - add datapump dml types
Rem     nbhatt     09/06/00 - add transformations catalog file
Rem     rpang      07/26/00 - move utl_http after utl_raw
Rem     thoang     07/15/00 - Add dbmstypu & prvttypu 
Rem     rvissapr   06/28/00 - adding prvtctx.sql
Rem     jdavison   07/25/00 - Add xmltype and anydata.
Rem     rpang      06/28/00 - Added prvthttp.plb
Rem     svivian    06/27/00 - move dbmslms.sql before dbmslsby
Rem     ajadams    06/20/00 - add logminer session scripts
Rem     gclaborn   06/20/00 - Add utlcxml.sql
Rem     mkrishna   06/08/00 - fix lrg 42798: backout XMLTYpe creation
Rem     jkundu     05/31/00 - change order of installation of dbmslm and dbmslm
Rem     jkundu     05/24/00 - changing where to call logminer package
Rem     mkrishna   05/23/00 - move dbmsxml packages before dbmsmeta
Rem     masubram   05/18/00 - add dbmshord.sql and prvtbord.plb
Rem     liwong     05/12/00 - Add prvthsye.plb
Rem     liwong     05/08/00 - Add prvthtxn.plb, prvthsye.plb
Rem     mkrishna   05/05/00 - add dbmsxml package to the catproc
Rem     njalali    05/03/00 - Backed out XDB changes
Rem     liwong     05/02/00 - Add prvthjob.plb
Rem     mkrishna   05/02/00 - add dbmsxml.sql to the created packages
Rem     mkrishna   05/02/00 - add dbmsxmlt to the created types
Rem     dmwong     04/24/00 - Catalog views for Fine Grained Auditing
Rem     dalpern    04/17/00 - argus debug
Rem     njalali    04/20/00 - Added catqm.sql
Rem     vvishwan   04/12/00 - Load dbmshias.sql, prvtbias.plb
Rem     svivian    04/10/00 - add logical standby scripts
Rem     wnorcott   03/08/00 - Add dbmscdcp, dbmscdcs
Rem     lbarton    03/01/00 - remove prvtmeta.plb
Rem     wnorcott   02/07/00 - Add dbmscdcu.sql / prvtcdcu.plb
Rem     rwessman   01/25/00 - Corrected omission of the obfuscation toolkit
Rem     rwessman   01/24/00 - Moved dbmsrand.sql from catoctk.sql to 
Rem                           catproc.sql so that all may use it
Rem     btao       01/12/00 - add prvtsms.plb for summary advisor
Rem     gclaborn   11/15/99 - Add dbmsmeta.sql / prvtmeta.plb
Rem     jarnett    09/23/99 - bug 951528 - correct dba_pending_transactions
Rem     rpang      08/13/99 - Added dbms_psp after dbms_sql and utl_raw
Rem     rpang      08/02/99 - Added utl_raw, utl_tcp, utl_smtp and utl_inaddr
Rem     bnainani   07/30/99 - Bug 915265 - change file names to 8 chars
Rem     jkundu     07/21/99 - Logminer sql filenames changed to 8.3 format
Rem     amozes     07/28/99 - add prvtstas.plb                                 
Rem     nshodhan   03/23/99 - add comments
Rem     nshodhan   02/26/99 - bug-789058: Remove obsolete files
Rem     ato        12/12/98 - add prvtzexp.plb
Rem     weiwang    11/16/98 - add system event attribute functions
Rem     slawande   11/04/98 - Load prvtsnap.plb before prvtsum.plb.
Rem     akalra     11/02/98 - get security helper functions for imp-exp
Rem     ato        11/02/98 - add prvtzhelp.plb                               
Rem     lcprice    11/02/98 - add dbms_repair package
Rem     rxgovind   10/14/98 - Remove RowType and RowSet install
Rem     dmwong     09/23/98 - add catactx for application context              
Rem     dmwong     09/22/98 - add views for application role
Rem     hasun      08/25/98 - Reorder <>snap and <>sum for dependencies        
Rem     rshaikh    06/22/98 - add catsvrmg after catspace
Rem     akalra     06/09/98 - catsched.sql -> catrm.sql
Rem     hasun      06/04/98 - Reorder prvtsnap and prvtsum to resolve depdencie
Rem     qiwang     05/28/98 - Add prvtsmv.plb
Rem     mcusson    05/11/98 - Name change: LogViewr -> LogMnr.
Rem     nle        05/13/98 - change file name: plspurity to plspur
Rem     rmurthy    05/04/98 - add catodci.sql
Rem     jwlee      05/18/98 - load catplug
Rem     nle        04/27/98 - execute plspurity
Rem     jwlee      04/05/98 - load prvtplts.plb
Rem     clei       03/09/98 - add catalog for row level security
Rem     sichandr   05/06/98 - make UTL_COLL package part of default installatio
Rem     svivian    04/16/98 - add stored outline metadata
Rem     doshaugh   04/13/98 - Add Logviewr packages
Rem     esoyleme   04/15/98 - add rules
Rem     rxgovind   04/12/98 - install SYS.RowType and SYS.RowSet
Rem     sramakri   04/08/98 - Add loading of prvtsma.plb (Summary Advisor packa
Rem     ciyer      03/30/98 - Load PL/SQL tracing packages
Rem     rxgovind   03/10/98 - make UTL_REF package part of default installation
Rem     clei       03/09/98 - add catalog for row level security
Rem     wnorcott   02/05/98 - Add prvtsum.sql
Rem     akalra     01/20/98 - Add catsched.sql
Rem     amozes     01/09/98 - add dbmsstat package
Rem     bhimatsi   02/27/98 - add call to catspace.sql
Rem     gclossma   09/09/97 - add .plb suffix to load of prvtpckl
Rem     gclossma   08/14/97 - add prvtpckl.plb for dbms_pickler
Rem     gdoherty   05/09/97 - add back catsnmp
Rem     gdoherty   04/29/97 - remove catsnmp.sql
Rem     rwessman   04/18/97 - Deleted catoctk.sql - it must be run after catpro
Rem     dalpern    04/16/97 - added on-disk rman packages
Rem     rwessman   04/15/97 - Add cryptographic toolkit interface
Rem     gclossma   04/14/97 - add pkg utlhttp for http callouts
Rem     gviswana   04/01/97 - Move prvtssql.plb down after dbmssql.sql
Rem     nlewis     03/20/97 - add prvttrst.sql - distributed trust admin
Rem     celsbern   01/07/97 - moved catsnap after catdefer and catqueue
Rem     ato        11/08/96 - add catqueue.sql
Rem     mchien     11/07/96 - fix '@' sign
Rem     wuling     11/07/96 - Add PITR Package
Rem     mchien     10/24/96 - add dbmslob to here
Rem     jmallory   10/22/96 - Load Probe packages
Rem     gdoherty   10/15/96 - move prvtssql.plb above other specs
Rem     mluong     10/14/96 - rearrange order for 'packages used for rdbms func
Rem     apareek    10/08/96 - New file for tspitr views (catpitr.sql)
Rem     sjain      09/09/96 - AQ conversion
Rem     nmichael   08/19/96 - New file for dynamic sql (prvtssql.sql)
Rem     asurpur    08/02/96 - Including prvtxpsw.sql to import password stuff
Rem     asurpur    05/06/96 - Dictionary Protection Implementation
Rem     ajasuja    04/25/96 -  merge OBJ to BIG_0423
Rem     wmaimone   01/04/96 -  7.3 merge
Rem     ldoo       12/10/95 -  Add dbmsitrg
Rem     tpystyne   04/09/96 - do not create standard since it is fixed now
Rem     emendez    09/29/95 -
Rem     dsdaniel   06/07/95 -  clean up .plb
Rem     dposner    04/26/95 -  Adding fileio packages
Rem     kmuthukk   03/13/95 -  add plitblm.sql for pl/sql index-table methods
Rem     wmaimone   05/06/94 -  #184921 run as sys/internal
Rem     dsdaniel   04/07/94 -  merge changes from branch 1.5.710.5
Rem     adowning   03/29/94 -  merge changes from branch 1.5.710.[6,7]
Rem     adowning   02/23/94 -  use prvt*.sql for non-replication
Rem     adowning   02/02/94 -  incorporate public/private file splits
Rem     dsdaniel   01/31/94 -  add dbmspexp.sql for export extensions
Rem     rjenkins   01/19/94 -  merge changes from branch 1.5.710.4
Rem     dsdaniel   01/18/94 -  merge changes from branch 1.5.710.2
Rem     rjenkins   12/08/93 -  un-merging dbmssyer
Rem     rjenkins   11/17/93 -  merge changes from branch 1.5.710.3
Rem     rjenkins   12/20/93 -  creating job queue
Rem     rjenkins   11/03/93 -  do dbmssnap after dbmssql
Rem     dsdaniel   10/30/93 -  add dbmssyer.sql
Rem     dsdaniel   10/29/93 -  run catdefr instead of dbmsdfrd
Rem     rjenkins   10/20/93 -  merge changes from branch 1.5.710.1
Rem     rjenkins   10/14/93 -  calling dbmsdfrd.sql
Rem     rjenkins   10/07/93 -  run dbmsdfrd.sql
Rem     hjakobss   07/09/93 -  add dbmssql
Rem     mmoore     11/03/92 -  add dbmsdesc 
Rem     glumpkin   10/26/92 -  Change catremot catrpc 
Rem     glumpkin   10/25/92 -  Change catstdx.sql to dbmsstdx.sql 
Rem     glumpkin   10/25/92 -  Creation 

WHENEVER SQLERROR EXIT;         
 
DOC 
###################################################################### 
###################################################################### 
    The following PL/SQL block will cause an ORA-20000 error and
    terminate the current SQLPLUS session if the user is not SYS. 
    Disconnect and reconnect with AS SYSDBA. 
###################################################################### 
###################################################################### 
# 
 
DECLARE
  p_user VARCHAR2(30);
BEGIN
    SELECT USER INTO p_user FROM DUAL; 
    IF p_user != 'SYS' THEN 
        RAISE_APPLICATION_ERROR (-20000, 
           'This script must be run AS SYSDBA'); 
    END IF; 
END;
/
WHENEVER SQLERROR CONTINUE;         

Rem indicate that catproc scripts are loading 

BEGIN
   dbms_registry.loading ('CATPROC','Oracle Database Packages and Types',
              'dbms_registry_sys.validate_catproc');
END;
/

Rem basic procedural views
@@catprc
@@catjobq

Rem Remote views
@@catrpc

Rem Setup for pl/sql
@@dbmsstdx
@@plitblm
@@plspur
@@pipidl
rem granting execute on the package created in pipidl.sql 
rem to execute_catalog_role...
grant execute on pidl to execute_catalog_role
/
@@pidian
rem granting execute on the package created in pidian.sql 
rem to execute_catalog_role...
grant execute on diana to execute_catalog_role
/
@@diutil
@@pistub
@@prvtpckl.plb

Rem PL/SQL packages
@@utlfile
@@prvtfile.plb
Rem more PL/SQL I/O packages
Rem  utlraw invocation moved to catalog.sql
@@prvtrawb.plb
@@utlfile
@@prvtfile.plb
@@utltcp
@@prvttcp.plb
@@utlinad
@@prvtinad.plb
@@utlsmtp
@@prvtsmtp.plb
@@utlhttp
@@prvthttp.plb
@@utlurl
@@prvturl.plb
@@utlenc
@@prvtenc.plb
@@utlgdk
@@prvtgdk.plb

Rem pl/sql packages for LOB
@@dbmslob.sql
@@prvtlob.plb

@@prvtcmpl.plb
@@utlcomp
@@prvtcomp.plb
@@utli18n
@@prvti18n.plb
@@utllms
@@prvtlms2.plb
Rem PL/SQL warning settings
@@dbmsplsw.sql

Rem include catspace.sql as it has space mgmt view and packages. we do it
Rem first as one of the following may have a reference to it
@@catspace

Rem Views for Application context ( dbmsutil and prvtutil depends on it )
@@catactx.sql

Rem Server Manager views -- depends on views created in catspace
@@catsvrmg

Rem optimizer stats history tables.
Rem These tables are to be created before running dbmsstat, prvtstas, prvtstat
@@catost

Rem pl/sql packages used for rdbms functionality
@@dbmsany.sql
@@dbmsutil
@@dbmsasrt
@@dbmsspu
@@prvthtxn.plb
@@dbmsapin
@@dbmssyer
@@dbmslock
@@dbmspipe
@@dbmsalrt
@@dbmsotpt
@@dbmsdesc
@@dbmssql
@@dbmspexp
@@dbmsjob
@@catodci.sql
@@dbmsstat
@@dbmsstts
@@dbmsddl
@@dbmslsby.sql
@@dbmspp
Rem[3741976]:
@@utlrcmp
@@prvthddl.plb
@@prvthjob.plb
@@prvthsye.plb
@@prvthssq.plb
@@prvtutil.plb
@@prvtasrt.plb
@@prvtapin.plb
@@prvtsyer.plb
@@prvtlock.plb
@@prvtpipe.plb
@@prvtalrt.plb
@@prvtotpt.plb
@@prvtdesc.plb
@@prvtssql.plb
@@prvtsql.plb
@@prvtpexp.plb
@@prvtzhlp.plb
@@prvtzexp.plb
@@prvtjob.plb
@@prvtstts.plb
@@prvtddl.plb
@@prvtpp.plb
@@prvtscrp.plb

Rem Index Rebuild Header
@@dbmsidxu

Rem PL/SQL Server Pages package
@@dbmspsp
@@prvtpsp.plb
@@dbmstran
@@prvttran.plb

Rem Views for XA recovery
@@catxpend

Rem Transformations
@@cattrans.sql
@@dbmstxfm.sql

Rem AnyType creation
@@prvtany.plb

Rem Rules engine
@@catrule.sql
@@dbmsread.sql
@@prvtread.plb

Rem STREAMS
Rem need to load prvthlut here because of dependency on bit,bis,bic
@@prvthlut.plb
Rem need to load prvthlin here because AQ export needs it
@@prvthlin.plb
Rem Streams Datapump package specs. AQ and LSBY need it.
@@prvthsdp.plb

Rem Tables, Views and Packages for AQ
@@catqueue
@@prvttxfm.plb

Rem Packages for DB Resource Manager
@@catrm

Rem Views and tables for deferred RPC and Materialized Views
@@catdefer
@@catsnap

Rem dbmsdfrd is replaced by dbmsdefr for the replication option
@@prvtdfrd.plb
@@prvtitrg.plb
@@prvtxpsw.plb

Rem Probe packages
@@dbmspb.sql
@@prvtpb.plb

Rem Scheduler 
@@catsch.sql

Rem DBMS Stats
@@prvtstas.plb
@@prvtstat.plb

Rem PL/SQL trace packages
@@dbmspbt.sql
@@prvtpbt.plb

Rem Views for transportable tablespace
@@catplug
@@dbmsplts
@@prvtplts.plb

Rem Views for tablespace point in time recovery
@@catpitr
Rem dbms_pitr package spec and body
@@dbmspitr
@@prvtpitr.plb

Rem pl/sql package for REFs (UTL_REF)
@@utlrefld.sql

Rem pl/sql package for COLLs (UTL_COLL)
@@utlcoll.plb
@@prvtcoll.plb

Rem pl/sql package for distributed trust administration (trusted list admin)
@@dbmstrst
@@prvttrst.plb

Rem on-disk versions of rman support
@@dbmsrman.sql
@@prvtrmns.plb
@@dbmsbkrs.sql
@@prvtbkrs.plb

Rem DIP account creation
@@catdip.sql

Rem Row Level Security package and catalog views
@@catrls
@@dbmsrlsa
@@prvtrlsa.plb

Rem Global Context internal package
@@prvtctx.plb

Rem Database Link Encoding
@@dbmslink.sql
@@prvtlink.plb

Rem Stored outline package and catalog views
@@catol.sql
@@dbmsol.sql
@@prvtol.plb

Rem Script for Extensibility types
@@prvtodci.plb

Rem Script for Application Role
@@catar.sql

Rem Data/Index Repair Package
@@dbmsrpr.sql
@@prvtrpr.plb

Rem System event attribute functions
@@dbmstrig.sql

Rem Random number generator
@@dbmsrand.sql

Rem Obfuscation (encryption) toolkist
@@dbmsobtk.sql
@@prvtobtk.plb

Rem User authentication for HTML DB
@@dbmshtdb.sql
@@prvthtdb.plb

REM packages for Redo LogMiner
REM Make sure these are always called after dbmstrig.sql has been installed
@@dbmslm.sql
@@prvtlm.plb
@@dbmslmd.sql
@@prvtlmd.plb
@@prvtlmc.plb

Rem All XML related types creation
@@catxml.sql

Rem UTL_XML: PL/SQL wrapper around CORE's LPX facility: C-based XML/XSL parsing
@@utlcxml.sql
@@prvtcxml.plb

REM Script for Fine Grained Auditing
@@catfga.sql
@@dbmsfga.sql
@@prvtfga.plb

Rem XDB Schema creation
Rem Comment this out until catqm.sql is finalized.
Rem @@catqm.sql


REM package for LogMiner logmnr_session
@@dbmslms.sql
@@prvtlms.plb


Rem Type Utility 
@@dbmstypu.sql
@@prvttypu.plb

Rem
Rem describe utility (used by mod_plsql)
Rem
drop package sys.wpiutl;
@@wpiutil.sql

Rem
Rem embedded plsql gateway/owa packages
Rem
@@owainst.sql
  
Rem Multi-language debug support
@@dbmsjdwp.sql
@@prvtjdwp.plb
@@dbmsjdcu.sql
@@dbmsjdmp.sql
@@prvtjdmp.plb

Rem Datapump headers
@@catdph.sql
Rem Declaration of TDE_LIBRARY packages NOT THE BODY.
@@prvtdtde.plb

Rem DataPump package body components
@@catdpb.sql
@@dbmspump.sql

Rem rules engin imp/exp and upgrade/downgrade packages
@@prvtreie.plb
@@prvtreut.plb
@@prvtrwee.plb

Rem package for Resumable and ora_space_error_info attribute function
@@dbmsres.sql
@@prvtres.plb

Rem load compelte component registry packages and views (before catlsby)
@@prvtcr.plb

Rem Logical Standby tables & views & procedures
@@catlsby
@@prvtlsby.plb

Rem package for transaction layer internal functions
@@dbmstxin.sql
@@prvttxin.plb

Rem OLAP Services
@@catxs.sql
@@olappl.sql

Rem Data Guard recovery framework support (dbms_drs)
@@dbmsdrs.sql
@@prvtdrs.plb

Rem Index Rebuild Views and Body
@@catidxu
@@prvtidxu.plb

REM packages for Summary Management and Materialized Views
@@dbmssum
@@dbmssnap
@@dbmshord
@@prvtxrmv.plb
@@prvtsum.plb
@@prvtsnap.plb
@@prvtsms.plb
@@prvtsmv.plb
@@prvtsma.plb

Rem iAS packages
@@dbmshias
@@prvtbias.plb  

Rem Replication catalog installation
@@catrep.sql

Rem File Transfer
@@dbmsxfr.sql
@@prvtbxfr.plb

Rem STREAMS
Rem prvthlut should be loaded before here due to dependency on get_str_compat()
Rem catstr is loaded here because of the dependency on queues
@@catstr.sql
@@catpstr.sql

Rem Load package body of online redefinition
@@prvtbord.plb

Rem Heterogeneous Services:  Gateways and external procedures, dbms_hs package
@@caths.sql

Rem File Mapping package
@@dbmsmap.sql
@@prvtmap.plb

Rem Frequent Itemset package
@@dbmsfi.sql
@@prvtfi.plb

Rem DBVerify
@@dbmsdbv.sql
@@prvtdbv.plb

Rem Trace Conversion
@@dbmstcv.sql
@@prvttcv.plb

Rem Collect UDA
@@dbmscoll.sql

REM change data capture packages
REM NOTE: CDC packages removed and placed into initcdc.sql
REM NOTE: CDC dependant on java and catjava.sql will load initcdc.sql

Rem Application upgrade packages
@@prvtupgi.plb
@@prvtupg.plb

Rem profiler package
@@dbmspbp
@@prvtpbp.plb

Rem dbms_service package
@@dbmssrv

Rem Transparent Session Migration
@@cattsm.sql
@@prvttsms.plb
@@prvttsmb.plb

Rem emon based failure detection
@@catemini.sql

Rem global plan_table
@@catplan.sql

Rem UTL_RECOMP body
@@prvtrcmp.plb

Rem Change Notification
@@catchnf.sql
@@dbmschnf
@@prvtchnf.plb
remark
remark  Post catproc "FIXED (VIRTUAL) VIEWS"
remark

Rem
Rem [g]v$sql_bind_capture
Rem   must be create here since it has a dependency with AnyData type
Rem
create or replace view v_$sql_bind_capture as select * from o$sql_bind_capture;
create or replace public synonym v$sql_bind_capture for v_$sql_bind_capture;
grant select on v_$sql_bind_capture to select_catalog_role;

create or replace view gv_$sql_bind_capture as select * from go$sql_bind_capture;
create or replace public synonym gv$sql_bind_capture for gv_$sql_bind_capture;
grant select on gv_$sql_bind_capture to select_catalog_role;
Rem
Rem Server Manageability catalog
Rem NOTICE:
Rem    dbms_swo package references the v$sql_bind_capture fixed view
Rem    therefore the catsvrm must be defined AT this place afer the 
Rem    definition of v$sql_bind_capture view. 
@@catsvrm.sql

@@prvtspcu.plb

Rem SNMP catalog objects  
Rem must be after dbmsdrs, catsvrm.sql, catalrt.sql
@@catsnmp.sql

Rem DBMS_LDAP package 
@@catldap.sql

Rem OWB Match package
@@utlmatch.sql

Rem DBMS_DB_VERSION package
@@dbmsdbvn.sql

Rem HA Events script
@@cathae.sql

Rem TDE utility
@@prvtdpcr.plb

Rem ADD NEW PACKAGES/NEW POST CATPROC FIXED VIEWS ABOVE THIS BLOCK
------------------------------------------------------------------------------

Rem Check for XE edition, do not run additional scripts

VARIABLE xefilename VARCHAR2(30)
COLUMN :xefilename NEW_VALUE xefile NOPRINT 
DECLARE
  p_edition v$instance.edition%type;
BEGIN
  SELECT edition INTO p_edition FROM v$instance;
  IF p_edition = 'XE' THEN 
     :xefilename := 'nothing.sql';
  ELSE
     :xefilename := 'catprocx.sql';
  END IF;
END;
/

-- Run catprocx.sql if not XE, else run nothing.sql
SELECT :xefilename FROM DUAL;
@@&xefile

SET SERVEROUTPUT ON

Rem Indicate CATPROC load complete and check validity
BEGIN
   dbms_registry.update_schema_list('CATPROC',
      dbms_registry.schema_list_t('SYSTEM', 'OUTLN', 'DBSNMP'));
   dbms_registry.loaded('CATPROC');
   dbms_registry_sys.validate_catproc;
   dbms_registry_sys.validate_catalog;
END;
/

SET SERVEROUTPUT OFF
