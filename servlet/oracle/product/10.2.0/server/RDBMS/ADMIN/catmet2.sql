Rem
Rem $Header: catmet2.sql 22-jun-2004.12:13:12 lbarton Exp $
Rem
Rem catmet2.sql
Rem
Rem Copyright (c) 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catmet2.sql - Creates heterogeneous types for Data Pump's mdapi
Rem
Rem    DESCRIPTION
Rem      Creates heterogeneous type definitions for
Rem        TABLE_EXPORT
Rem        SCHEMA_EXPORT
Rem        DATABASE_EXPORT
Rem        TRANSPORTABLE_EXPORT
Rem      Also loads xsl stylesheets
Rem      All this must be delayed until the packages have been built.
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    lbarton     06/22/04 - Bug 3695154: obsolete initmeta.sql 
Rem    lbarton     04/27/04 - lbarton_bug-3334702
Rem    lbarton     01/28/04 - Created
Rem

-- create the types

exec dbms_metadata_build.set_debug(false);
exec DBMS_METADATA_DPBUILD.create_table_export;
exec DBMS_METADATA_DPBUILD.create_schema_export;
exec DBMS_METADATA_DPBUILD.create_database_export;
exec DBMS_METADATA_DPBUILD.create_transportable_export;

-- load XSL stylesheets

exec SYS.DBMS_METADATA_UTIL.LOAD_STYLESHEETS;
