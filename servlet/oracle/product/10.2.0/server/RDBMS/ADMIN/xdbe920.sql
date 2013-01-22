Rem
Rem $Header: xdbe920.sql 27-sep-2004.16:54:12 spannala Exp $
Rem
Rem xdbe920.sql
Rem
Rem Copyright (c) 2002, 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      xdbe920.sql - XDB downgradE from 10i to 9.2
Rem
Rem    DESCRIPTION
Rem      Downgrade script from 10i to 9.2
Rem
Rem    NOTES
Rem      None
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    spannala    09/27/04 - calling xdbeall.sql 
Rem    spannala    08/23/04 - adding 10.1 downgrade to 9.2 downgrade 
Rem    spannala    05/13/04 - move functions to utilities
Rem    thbaby      04/21/04 - adding 10.1 downgrade 
Rem    spannala    02/11/04 - remove objects which are not present in 9205
Rem    spannala    11/11/03 - fix resource schema downgrade
Rem    alakshmi    11/17/03 - Downgrade LCR schema without CopyEvolve 
Rem    spannala    11/07/03 - fixing errors in LCR downgrade 
Rem    spannala    10/03/03 - use force for disassociate statistics 
Rem    spannala    10/02/03 - fix status correctly 
Rem    fge         08/08/03 - drop secondary index on xdb.xdb$h_link.child_oid 
Rem    bkhaladk    08/19/03 - downgrade of plsql dom 
Rem    spannala    08/26/03 - accomodate for the changes in upgrade
Rem    spannala    08/21/03 - using copy evolve to downgrade lcr schema 
Rem    spannala    07/26/03 - drop the listingschema
Rem    spannala    07/23/03 - objects introduced by catxdbeo should be dropped
Rem    spannala    07/20/03 - following additional guidelines
Rem    spannala    07/14/03 - adding downgrade to 9.2.0.4
Rem    njalali     11/21/02 - njalali_migscripts_10i
Rem    njalali     11/21/02 - Created
Rem

-- Load utilities
@@xdbuuc.sql

-- Set status correctly, use the same trick as upgrade to set
-- status here.
-- Note that this means that none of the xdbes* scripts should use status.
BEGIN
  IF dbms_registry.status('XDB') = 'VALID' THEN
    -- This will get commited along with the 'downgrading' call below
    update xdb.migr9202status set n = 1000;
  END IF;
END;
/

-- Set the status to downgrading.
EXECUTE DBMS_REGISTRY.DOWNGRADING('XDB');

-- call common downgrade
@@xdbeall.sql

-- First run data downgrade to 9.2
@@xdbeu920.sql

-- Then run schema downgrade to 9.2
@@xdbes920.sql

select n from xdb.migr9202status;

-- downgrade the config schema
-- move the migr9202status down to 460
@@xdbuud.sql
Rem Signify that XDB has been downgraded.
execute dbms_registry.downgraded('XDB','9.2.0');

