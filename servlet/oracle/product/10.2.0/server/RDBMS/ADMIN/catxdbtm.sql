Rem
Rem $Header: catxdbtm.sql 30-nov-2004.11:45:45 smukkama Exp $
Rem
Rem catxdbtm.sql
Rem
Rem Copyright (c) 2003, 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catxdbtm.sql - XDB compact xml Token Manager related tables
Rem
Rem    DESCRIPTION
Rem      This script creates the tables required for XDB Compact XML
Rem      token management.         
Rem
Rem    NOTES
Rem      This script should be run as the user "XDB".
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    smukkama    11/19/04 - use even smaller token size (UTF8 ncharset)
Rem    smukkama    10/12/04 - for less than 8K blk sz use smaller token columns
Rem    smukkama    09/30/04 - move xmlidx plsql stuff to catxidx.sql
Rem    smukkama    08/13/04 - add flags column (for attr) to xdb$qname_id
Rem    smukkama    06/23/04 - Remove set echo on
Rem    athusoo     04/06/04 - Add path suffix table function 
Rem    smukkama    02/27/04 - Add reverse path index on xdb$path_id
Rem    smukkama    12/16/03 - Created
Rem

/************ Create Token - ID mapping tables *********************/
/* If the block size is less than 8K use smaller token sizes so
 * that index creation doesn't fail. (see bug 3928505)
 *
 * The max index key sizes for various block sizes are:
 *  2K max index key size = 1478 bytes (on Linux)
 *  4K max index key size = 3118 bytes (on Linux)
 *  8K max index key size = 6398 bytes (on Linux)
 *
 * For each of the various token column sizes below, the maximum token
 * length that would permit token-->id index creation was determined and
 * then a value 5% less (to account for any platform specific variance)
 * was picked as the token size.
 *
 */

declare
  bsz number;
  nmspc_tok_chars  number;
  qname_tok_chars  number;
  path_tok_bytes   number;
begin

    /* figure out block size and use appropriate token size */
   select t.block_size into bsz from user_tablespaces t, user_users u
      where u.default_tablespace = t.tablespace_name;

   if bsz < 4096 then
      nmspc_tok_chars := 464;
      qname_tok_chars := 460;
      path_tok_bytes  := 1395;
   elsif bsz < 8192 then
      nmspc_tok_chars := 984;
      qname_tok_chars := 979;
      path_tok_bytes  := 2000;
   else
      nmspc_tok_chars := 2000;
      qname_tok_chars := 2000;
      path_tok_bytes  := 2000;
   end if;

   execute immediate                           -- Namespace URI ID Token Table
      'create table xdb.xdb$nmspc_id (
         nmspcuri nvarchar2(' || nmspc_tok_chars || '), 
         id        raw(8))';

   execute immediate                           -- QName ID Token Table
      'create table xdb.xdb$qname_id (
         nmspcid      raw(8),
         localname    nvarchar2(' || qname_tok_chars || '),
         flags        raw(4),
         id           raw(8))';

   execute immediate                           -- PathID Token Table
      'create table xdb.xdb$path_id (
         path         raw(' || path_tok_bytes || '),
         id           raw(8))';
end;
/

/************ Insert reserved values into tables *********************/

insert into xdb.xdb$nmspc_id values 
       ('http://www.w3.org/XML/1998/namespace',          HEXTORAW('01'));
insert into xdb.xdb$nmspc_id values 
       ('http://www.w3.org/XML/2000/xmlns',              HEXTORAW('02'));
insert into xdb.xdb$nmspc_id values
       ('http://www.w3.org/2001/XMLSchema-instance',     HEXTORAW('03'));
insert into xdb.xdb$nmspc_id values 
       ('http://www.w3.org/2001/XMLSchema',              HEXTORAW('04'));
insert into xdb.xdb$nmspc_id values 
       ('http://xmlns.oracle.com/2004/csx',              HEXTORAW('05'));
insert into xdb.xdb$nmspc_id values 
       ('http://xmlns.oracle.com/xdb',                   HEXTORAW('06'));
insert into xdb.xdb$nmspc_id values 
       ('http://xmlns.oracle.com/xdb/nonamespace',       HEXTORAW('07'));

insert into xdb.xdb$qname_id values (HEXTORAW('01'), 'space', HEXTORAW('01'), HEXTORAW('10'));
insert into xdb.xdb$qname_id values (HEXTORAW('01'), 'lang', HEXTORAW('01'), HEXTORAW('11'));
insert into xdb.xdb$qname_id values (HEXTORAW('03'), 'type', HEXTORAW('01'), HEXTORAW('12'));
insert into xdb.xdb$qname_id values (HEXTORAW('03'), 'nil', HEXTORAW('01'), HEXTORAW('13'));
insert into xdb.xdb$qname_id values
       (HEXTORAW('03'), 'schemaLocation', HEXTORAW('01'), HEXTORAW('14'));
insert into xdb.xdb$qname_id values
       (HEXTORAW('03'), 'noNamespaceSchemaLocation', HEXTORAW('01'), HEXTORAW('15'));
insert into xdb.xdb$qname_id values (HEXTORAW('02'), 'xmlns', HEXTORAW('01'), HEXTORAW('16'));

commit;

/************ Create Indexes on token tables *********************/

create unique index xdb.xdb$nmspc_id_nmspcuri on
xdb.xdb$nmspc_id (nmspcuri);

create unique index xdb.xdb$nmspc_id_id on
xdb.xdb$nmspc_id (id);


create index xdb.xdb$qname_id_nmspcid on
xdb.xdb$qname_id (nmspcid);

create unique index xdb.xdb$qname_id_qname on
xdb.xdb$qname_id (nmspcid, localname, flags);

create unique index xdb.xdb$qname_id_id on
xdb.xdb$qname_id (id);


create unique index xdb.xdb$path_id_path on
xdb.xdb$path_id (path);

create unique index xdb.xdb$path_id_id on
xdb.xdb$path_id (id);

create unique index xdb.xdb$path_id_revpath on
xdb.xdb$path_id (SYS_PATH_REVERSE(path));
