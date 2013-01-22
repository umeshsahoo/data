rem
Rem $Header: catdip.sql 22-jan-2003.09:52:09 srtata Exp $
Rem
Rem catdip.sql
Rem
Rem Copyright (c) 2002, 2003, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      catdip.sql - Creates a DIP account for provisioning event processing.
Rem
Rem    DESCRIPTION
Rem      Creates a generic user account DIP for processing events propagated
Rem      by DIP. This account would be used by all applications using
Rem      the DIP provisioning service when connecting to the database.
Rem
Rem    NOTES
Rem      Called from catproc.sql
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    srtata      01/22/03 - srtata_bug-2629661
Rem    srtata      12/17/02 - Created
Rem

create user DIP identified by DIP password expire account lock;

grant create session to DIP;

