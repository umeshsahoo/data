Rem
Rem $Header: xdbe101.sql 27-sep-2004.16:54:13 spannala Exp $
Rem
Rem xdbe101.sql
Rem
Rem Copyright (c) 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      xdbe101.sql - downgrade to the 10.1 release
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    spannala    09/27/04 - calling xdbeall.sql 
Rem    spannala    08/23/04 - factoring 10.1 downgrade out into another file 
Rem    thbaby      07/28/04 - update sequence model in the resource too 
Rem    abagrawa    06/28/04 - Fix downgrade_resource_schema 
Rem    spannala    05/11/04 - set the status correctly at the end
Rem    spannala    05/10/04 - remove http2-listener 
Rem    thbaby      04/26/04 - Merge transaction thbaby_https
Rem    thbaby      04/21/04 - Created
Rem

call dbms_registry.downgrading('XDB');

-- Load utility functions
@@xdbuuc.sql

-- call common downgrade
@@xdbeall.sql

-- downgrade from 10.2 to 10.1
@@xdbeu101.sql
@@xdbes101.sql

-- remove utility functions
@@xdbuud.sql

-- commit the txn
commit;

-- signify that the downgrade is complete.
execute dbms_registry.downgraded('XDB', '10.1.0');

