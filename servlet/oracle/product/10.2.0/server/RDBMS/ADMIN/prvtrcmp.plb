DROP TABLE utl_recomp_sorted;
DROP TABLE utl_recomp_compiled;
DROP TABLE utl_recomp_errors;
CREATE TABLE utl_recomp_sorted
(
  obj#      number not null,
  owner     varchar2(30),
  objname   varchar2(30),
  namespace number,
  depth     number,
  batch#    number
);
CREATE TABLE utl_recomp_compiled
(
  obj#        number not null,
  batch#      number,
  compiled_at timestamp,
  compiled_by varchar2(64)
);
CREATE TABLE utl_recomp_errors
(
  obj#        number,
  error_at    timestamp,
  compile_err varchar2(4000)
);
CREATE OR REPLACE VIEW utl_recomp_all_objects AS
   SELECT o.obj#, u.name owner, o.name objname, o.type#, o.namespace, o.status
   FROM obj$ o, user$ u
   WHERE     o.owner# = u.user#
         AND o.remoteowner IS NULL
         AND (   o.type# IN (1, 2, 4, 5, 7, 8, 9, 11, 12, 14,
                             22, 24, 29, 32, 33, 42, 43, 46, 59, 62)
              OR (o.type# = 13 AND o.subname IS NULL AND
                  NOT REGEXP_LIKE(o.name, 'SYS_PLSQL_[0-9]+_[0-9]+_[12]')))
         AND (BITAND(o.flags, 128) = 0);
CREATE OR REPLACE VIEW utl_recomp_invalid_all AS
   SELECT * FROM utl_recomp_all_objects
      WHERE status in (4, 5, 6) AND
            obj# NOT IN (SELECT obj# from utl_recomp_compiled);
CREATE OR REPLACE VIEW utl_recomp_invalid_seq AS
   SELECT * FROM utl_recomp_invalid_all WHERE type# IN (29, 42);
CREATE OR REPLACE VIEW utl_recomp_invalid_parallel AS
   SELECT * FROM utl_recomp_invalid_all WHERE type# NOT IN (29, 42);
CREATE OR REPLACE VIEW utl_recomp_invalid_java_syn AS
   SELECT * FROM utl_recomp_all_objects
   WHERE type# = 5 AND status in (4, 5, 6) AND
         obj# IN (SELECT d.d_obj# FROM obj$ o, dependency$ d
                  WHERE o.obj# = d.p_obj# and o.type# = 29);
CREATE OR REPLACE PACKAGE BODY utl_recomp wrapped 
a000000
1
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
b
34ec f9e
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

/
show errors;
