CREATE OR REPLACE TYPE lcr$_procedure_parameter wrapped 
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
d
73 9e
5EWR9j0U9+gj5NXK+06ya0dqiwswg5n0dLhcpVLLCfQo55u/nzK9ssDwKLh0wNIyslKyCbh0
K6W/m8Ayy8xQjwlppR0YxcpndQvIAwcLyPdA9Dc3N+hKrOFp9G0L4+/x8Y+FcACAnVpGFpzo
Kh2meJYEKQ==

/
CREATE OR REPLACE TYPE lcr$_parameter_list AS TABLE 
  OF lcr$_procedure_parameter;
/
CREATE OR REPLACE LIBRARY lcr_prc_lib wrapped 
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
16
26 59
cNzRxRAXvob3W8TrxtdzMGfU0uYwg04I9Z7AdBjDpVLLGCjnwEr+CPUJ572esstSMsy4dCvn
y1J0CPXJpqZ3+54w

/
CREATE OR REPLACE TYPE LCR$_PROCEDURE_RECORD 
OID '00000000000000000000000000020015' 
AS OPAQUE VARYING (*)
USING LIBRARY lcr_prc_lib
( 
  MAP MEMBER FUNCTION map_lcr RETURN NUMBER,
  MEMBER FUNCTION  get_source_database_name RETURN VARCHAR2,
  MEMBER FUNCTION  get_scn                  RETURN NUMBER,
  MEMBER FUNCTION  get_transaction_id       RETURN VARCHAR2,
  MEMBER FUNCTION  get_publication          RETURN VARCHAR2,
  MEMBER FUNCTION  get_package_owner        RETURN VARCHAR2,
  MEMBER FUNCTION  get_package_name         RETURN VARCHAR2,
  MEMBER FUNCTION  get_procedure_name       RETURN VARCHAR2,
  MEMBER FUNCTION  get_parameters           RETURN SYS.LCR$_PARAMETER_LIST
)
/
GRANT EXECUTE ON LCR$_PROCEDURE_RECORD TO PUBLIC;
/
CREATE OR REPLACE PACKAGE dbms_streams_lcr_int wrapped 
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
9
ef d6
xheD9rWyXriKRr3QsaadjPmEDAkwgxDQLssVZ+cCTP6OVh7UmfUCgk22uujuxlcKvrViGtQE
Ll+9vSiF+KmU65RyNjpTEeq2FYXH8Ye0plXRbITA8+Ae4hSpe3Smu1etSdWNqFy891SdlsfE
RajUyIiyoCmoGg2NM8qR0eSKqMQEhtJPxFXTNKZfOOP86/iVEs3nHFL5OlCgEqaq9yTm

/
CREATE OR REPLACE PUBLIC SYNONYM dbms_streams_lcr_int FOR 
sys.dbms_streams_lcr_int
/
GRANT EXECUTE ON sys.dbms_streams_lcr_int TO execute_catalog_role
/
