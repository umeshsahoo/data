Rem
Rem $Header: xdbpatch.sql 17-aug-2004.08:16:26 rburns Exp $
Rem
Rem xdbpatch.sql
Rem
Rem Copyright (c) 2002, 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      xdbpatch.sql - Branch Specific Minor Version Patch Script for XDB
Rem
Rem    DESCRIPTION
Rem      Patches are minor releases of the database. This script, depending
Rem      on where it is checked in, attempts to migrate all the previous
Rem      minor versions of the database to the version it is checked in to.
Rem      Obviously, this is a no-op for the first major production release
Rem      in any version. In addition, the script is also expected to reload
Rem      all the related PL/SQL packages types when called via catpatch. 
Rem
Rem    NOTES
Rem      Dictionary changes are not supposed to be done in DB Minor versions,
Rem      We should conform to this directive in 10g. Also, several
Rem      irrelevant MODIFIED lines were deleted
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rburns      08/17/04 - conditionally run dbmsxdbt 
Rem    spannala    04/30/04 - revalidate xdb at the end of patch 
Rem    najain      01/28/04 - call prvtxdz0 and prvtxdb0
Rem    spannala    12/16/03 - fix to be correct for main 
Rem    njalali     07/10/02 - Created
Rem

WHENEVER SQLERROR EXIT;
EXECUTE dbms_registry.check_server_instance;
WHENEVER SQLERROR CONTINUE;

Rem Reload the schema registration/compilation module
@@dbmsxsch.sql

Rem Reload the security module
@@dbmsxdbz.sql
@@prvtxdz0.plb

Rem reload definition for various xdb utilities  
@@dbmsxdb.sql
@@prvtxdb0.plb

Rem Create helper package for text index on xdb resource data
COLUMN xdb_name NEW_VALUE xdb_file NOPRINT;
SELECT dbms_registry.script('CONTEXT','@dbmsxdbt.sql') AS xdb_name FROM DUAL;
@&xdb_file

Rem Reload implementation of XDB Utilities
@@prvtxdb.plb

Rem Reload implementation of XDB Security modules
@@prvtxdbz.plb

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
@@dbmsxvr.sql

@@xdbvlo.sql
