Rem
Rem $Header: catxdbvr.sql 16-dec-2003.21:48:06 spannala Exp $
Rem
Rem catxdbvr.sql
Rem
Rem Copyright (c) 2001, 2003, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      catxdbvr.sql - all $table for versioning are defined here.
Rem
Rem    DESCRIPTION
Rem      WSINDEX: (workspace index) table for indexing a versioned table.
Rem               Each versioned table has one associated wsindex table.
Rem      CHECKOUTS: table for all checked-out rows.
Rem
Rem      For regular RDBMS, wsindex and checkouts tables should be
Rem      automatically created by the system for versioned table.
Rem      For XDB, wsindex is created together with workspace, and checkouts
Rem      is created together with the resource table.
Rem
Rem    NOTES
Rem      This file should be executed for each user who has versioned tables.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    spannala    12/16/03 - split the package into dbmxvr.sql 
Rem    sichandr    04/17/02 - add getContents* routines
Rem    sichandr    02/19/02 - fix getPredecessors
Rem    sichandr    02/21/02 - add GetResourceByResId
Rem    sichandr    02/07/02 - add GetPredessors/GetSuccessors
Rem    spannala    01/08/02 - incorporating fge_caxdb_priv_indx_fix
Rem    spannala    12/27/01 - setup should be run as SYS
Rem    najain      12/05/01 - change XDB_VERSION to DBMS_XDB_VERSION
Rem    nagarwal    10/23/01 - Merged nagarwal_deltav
Rem    nle         08/09/01 - Created
Rem

/* vers$wsindex: index table for a versioned table.
 *
 *  Each workspace will have one index table. This table should be created
 *  automatically by the system together with a workspace. We created it here
 *  for our code prototype. It has three columns.
 *
 *   - sys_primary: if the primary key of a row is changed, this is used to
 *     identified the row. This shouldn't be used in this table. It should be
 *     used in the versioned table (i.e. the $resource table for XDB). (???)
 *   - user_primary: its datatype and content are the same as the primary key
 *     of the versioned table. For XDB, the primary key is of varchar(128).
 *     This is the index key of the index table.
 *   - data: this is a rowid of a row in the versioned table (xdb$resource)

create table xdb$wsindex(sys_primary number(6),
                         user_primary varchar2(128),
                         data rowid)
*/

/* vers$checkouts: a table to maintain a list of checkouts.
 *  Checkout table helps to implement checkout/checkin operations.
 *  - version: this column point to the original version of a checked-out row.
 *             if this column is null, the resource has been deleted.
 *  - actid: id of an activity.
 *  - co_stat: checked-out/checked-in. This might not be necessary.
 */
drop table xdb.xdb$checkouts;
create table xdb.xdb$checkouts(vcruid raw(16),
                           workspaceid integer,
                           version raw(16),
                           actid integer,
                           constraint cokey primary key(vcruid, workspaceid))
/


create index xdb.xdb$checkouts_vcruid_idx on xdb.xdb$checkouts (vcruid);
create index xdb.xdb$checkouts_workspaceid_idx on xdb.xdb$checkouts (workspaceid);

-- The package definition has moved into dbmsxvr.sql
@@dbmsxvr.sql
