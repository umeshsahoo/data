Rem
Rem $Header: olsu101.sql 22-jun-2004.14:12:05 cchui Exp $
Rem
Rem olsu101.sql
Rem
Rem Copyright (c) 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      olsu101.sql - upgrade from 10.1 to 10.2
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    cchui       06/22/04 - grant new privileges 
Rem    cchui       05/11/04 - Clean up all the SETs 
Rem    srtata      03/26/04 - srtata_bug-3440113 
Rem    srtata      02/12/04 - Created
Rem

-- Grant new privileges
GRANT SELECT ON GV_$SESSION TO LBACSYS;
GRANT SELECT ON V_$INSTANCE TO LBACSYS;
GRANT SELECT ON GV_$INSTANCE TO LBACSYS;

