Rem
Rem $Header: catias.sql 18-apr-2001.11:31:32 celsbern Exp $
Rem
Rem catias.sql
Rem
Rem  Copyright (c) Oracle Corporation 1900, 2000. All Rights Reserved.
Rem
Rem    NAME
Rem      catias.sql - drivers for installing IAS catalog and packages
Rem
Rem    DESCRIPTION
Rem      
Rem
Rem    NOTES
Rem      execute connected as sys and after the catrepc.sql and 
Rem      replication packages have been installed.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    celsbern    04/18/01 - rm prvtiasi added prvthiai and prvtbiai.
Rem    jingliu     08/01/00 - remove catiexp.sql
Rem    jingliu     05/02/00 - add catiexp.sql
Rem    masubram    04/16/00 - add prvtiasu
Rem    masubram    04/12/00 - add prvtiasi.sql
Rem    celsbern    03/28/00 - changed to real installation script
Rem    celsbern    03/26/00 - Created
Rem

-- IAS views
@@catiasc

-- IAS package specifications
@@dbmsiast
@@prvthiai.plb
@@prvthiau.plb

-- IAS package bodies
@@prvtbiat.plb
@@prvtbiai.plb
@@prvtbiau.plb

