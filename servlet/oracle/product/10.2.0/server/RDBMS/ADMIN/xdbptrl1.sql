Rem DEPENDENCIES
Rem it might be a good idea to move all the dbms* before the prvt*. Here
Rem is the list of dependencies that i have realized exist
Rem prvtxdbz.plb depends on prvtxdb.plb (prvtxdbz invokes dbms_xdbutil_int)
Rem prvtxdb.plb depends on dbmsxdbt (calls some function from that pkg)
Rem dbmsxdbt depends on dbmsxdbz  (call dbms_xdbz.get_username)

Rem reload xmltype
@@dbmsxmlt.sql
@@prvtxmlt.plb

Rem Reload the schema registration/compilation module
@@dbmsxsch.sql

Rem Reload the security module
@@dbmsxdbz.sql
@@prvtxdz0.plb

Rem reload definition for various xdb utilities  
@@dbmsxdb.sql
@@prvtxdb0.plb

Rem reload Path Index
@@catxdbpi.sql

Rem Reload implementation of XDB Utilities
COLUMN xdb_name NEW_VALUE xdb_file NOPRINT;
SELECT dbms_registry.script('CONTEXT','@dbmsxdbt.sql') AS xdb_name FROM DUAL;
@&xdb_file

@@prvtxdb.plb

Rem Reload implementation of XDB Security modules
@@prvtxdbz.plb

Rem Resource View
@@prvtxdr0.plb
@@catxdbr.sql 

Rem Resource view implementaion
@@prvtxdbr.plb

Rem XDB Path Index Implementation
@@prvtxdbp.plb 

@@dbmsxmld.sql
@@dbmsxmlp.sql
@@dbmsxslp.sql
@@prvtxmld.plb
@@prvtxmlp.plb
@@prvtxslp.plb

@@prvtxsch.plb

Rem reload the Versioning Package 
@@catxdbvr.sql

Rem reload Path View
@@catxdbpv

Rem reload xmlindex packages
@@catxidx

Rem reload various views to be created on xdb data
Rem This needs to be done after 9.2.0.2 migration
Rem @@catxdbv

Rem reload embedded PL/SQL gateway package
@@dbmsepg.sql
@@prvtepg.plb
