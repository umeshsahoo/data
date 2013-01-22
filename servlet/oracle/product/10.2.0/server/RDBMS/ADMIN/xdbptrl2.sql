COLUMN :eoscr_name NEW_VALUE eoscr_file NOPRINT
VARIABLE eoscr_name VARCHAR2(50)

Rem Reload the schema registration/compilation module
@@prvtxsch.plb

Rem reload various views to be created on xdb data
@@catxdbv

Rem reload dbmsxdbt package
COLUMN xdb_name NEW_VALUE xdb_file NOPRINT;
SELECT dbms_registry.script('CONTEXT','@dbmsxdbt.sql') AS xdb_name FROM DUAL;
@&xdb_file

Rem reload helper package for xml index
@@dbmsxidx

DECLARE
  version      varchar2(60);
  ct           integer;
BEGIN
  select count(*) into ct from xdb.xdb$schema s
  where s.xmldata.schema_url = 'http://xmlns.oracle.com/xdb/stats.xsd';

  IF ct = 0 THEN
    :eoscr_name := '@catxdbeo.sql';
  ELSE
    :eoscr_name := '@nothing.sql';
  END IF;
END;
/

Rem Reload repository view extensible optimizer
SELECT :eoscr_name FROM DUAL;
@&eoscr_file
