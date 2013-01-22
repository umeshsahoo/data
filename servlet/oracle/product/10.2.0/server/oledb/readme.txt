-------------------------------------
Oracle Provider for OLE DB 10.2.0.1.0
-------------------------------------
Copyright (C) Oracle Corporation 2005

This document provides information that supplements the Oracle Provider for 
OLE DB documentation.


IMPORTANT INSTALLATION INFORMATION
==================================
The OraOLEDB provider, being a COM component, can have Only one version active 
on a machine at a time.


What's new in 10.2.0.1.0 version
================================
1. Support for Statement Caching
   This feature provides and manages a cache of statements for each session.
   The developer can control what statements are cached and how many. This 
   improves performance and scalability of the database.


What's new in 10.0.1.2.0 version
================================
1. Support for Oracle Grids
   OraOLEDB is grid-enabled, allowing developers to take advantage of Oracle
   database grid support without having to make changes to their application
   code.

2. Support for the following datatypes introduced with Oracle Database 10g:
   BINARY_DOUBLE
   BINARY_FLOAT

3. Support for Multiple Homes
   OraOLEDB can be installed in Multiple Oracle Homes, starting with release 
   10.1.0.2.0. However, being a COM component, only one instance can be 
   active on the computer. This means that the current (latest) installation 
   renders the previous one inactive. In order to make multiple homes available, 
   some of the OraOLEDB files now include a version number, and the use of a 
   HOMEID is required.


What's new in 9.2.0.4.0 version
================================
1. Support for the following datatypes introduced with Oracle9i:
   - TIMESTAMP
   - TIMESTAMP WITH TIME ZONE
   - TIMESTAMP WITH LOCAL TIME ZONE
   - INTERVAL YEAR TO MONTH
   - INTERVAL DAY TO SECOND


OraOLEDB-specific Connection String Attributes
==============================================
1. UseSessionFormat 
   Specifies whether to use the default NLS session formats or let OraOLEDB 
   override some of these formats for the duration of the session.

   Valid values are 0 (FALSE) and 1 (TRUE). The default is FALSE which lets
   OraOLEDB override some of the default NLS session formats. If the value 
   is TRUE, OraOLEDB uses the default NLS session formats.

2. VCharNull
   Enables or disables the NULL termination of VARCHAR OUT parameters from 
   stored procedures. Valid values are 0 (disabled) and 1 (enabled). The 
   default is 1 which indicates that VARCHAR OUT parameters are NULL 
   terminated. A value of 0 indicates that VARCHAR OUT parameters are padded 
   with spaces.

   The default value for this attribute is located under the \\HKEY_LOCAL_
   MACHINE\SOFTWARE\ORACLE\HOMEID\OLEDB registry key. If this attribute is 
   not provided at connection time, the default registry values are used.

   Note that with this connection attribute enabled, applications need to
   pad the stored procedure IN and IN OUT CHAR parameters with spaces
   explicitly, if the parameter is to be used in a WHERE clause.

3. SPPrmDefVal
   Specifies whether to use the default value or a NULL value if the 
   application has not specified a stored procedure parameter value. Valid 
   values are 0 (FALSE) and 1 (TRUE). The default is FALSE which lets 
   OraOLEDB pass a NULL value. If the value is TRUE, OraOLEDB uses the 
   default value.

   The default value for this attribute is located under the \\HKEY_LOCAL_
   MACHINE\SOFTWARE\ORACLE\HOMEID\OLEDB registry key. If this attribute is 
   not provided at connection time, the default registry values are used.


Oracle Technology Network
=========================
For sample code, the latest patches, and other technical information 
on the Oracle Provider for OLE DB, go to
http://otn.oracle.com/tech/windows/ole_db/


TIPS, LIMITATIONS AND KNOWN ISSUES
==================================

Performance
-----------
* To improve performance, do not use ADO method AppendChunk on LONG/LONG RAW 
  columns. Instead, insert or update the entire LONG/LONG RAW column using 
  the ADO AddNew or Update method.

* Use /*+ ... */ as the optimizer hint syntax with the OraOLEDB driver. The 
  hint syntax, --+ ... is currently not supported.


Unsupported Parameter Types with OLE DB .NET Data Provider 
----------------------------------------------------------
* The Provider does not support LongVarChar, LongVarWChar, LongVarBinary, and 
  BSTR IN/OUT and OUT parameter types with OLE DB .NET Data Provider because 
  of a Microsoft's OLE DB .NET Data Provider known limitation.


Unsupported Datatypes
---------------------
* The Trusted Oracle datatype MLSLABEL is not supported by the OraOLEDB driver.

* The Provider does not currently support Object datatypes.


About LOB
---------
* The Command object currently errors out when updating LOBs on more than 
  one row at a time.

  For example:
  UPDATE SomeTable SET LobCol = ? WHERE ...
  will error out if the UPDATE statement affects more than one row in the table. 
  This restriction is limited to LOBs (BLOB/CLOB) and not LONGs (LONG/LONG RAW).

* As most LOB write (INSERT and UPDATE) operations involve multiple write 
  operations within the provider, it is recommended that the transaction be 
  enabled for such operations. Enabling transaction will allow consumers to 
  rollback the entire write operation in the event of some failure. This is 
  recommended when writing LOBs from the Command or the Recordset object.


DBLINK
------
To enable creating rowsets using queries containing Oracle Database Links, the 
connection string attribute, DistribTx, should be disabled. Such rowsets are 
currently limited to being read-only.


Transaction
-----------
* During a Local or Global Transaction, do not execute SQLs COMMIT, ROLLBACK or 
  SAVEPOINT using the Command interface as they may affect the data consistency 
  in the Rowsets. The same holds for executing DDLs (CREATE TABLE, ALTER VIEW, 
  etc.) in this explicit transaction mode, as DDLs in Oracle perform an implicit 
  Commit to the database. Execute DDLs only in the Auto-Commit mode.

* To enable Autonomous Transaction support, the connection string attribute, 
  DistribTx, should be disabled. Using this feature, consumers can execute 
  Stored Procedures having COMMITs and/or ROLLBACKs.

  Note that Commit/Rollback in a stored procedure should be performed with 
  caution. As OraOLEDB provides transactional capability on rowsets, whose data 
  is cached locally on the client-side, performing an explicit commit/rollback 
  in a stored procedure, with an open rowset, could cause the rowset to be out 
  of sync with the database. In these cases, all commits and rollbacks (aborts) 
  should be performed from the client-side (con.Commit or con.Abort). The 
  exception is if the user is making use of Autonomous Transactions in the stored 
  procedure. By using this, the transaction in the stored procedure is isolated
  from the main one; thus allowing for localized commits/aborts. Autonomous 
  Transactions have been introduced only in Oracle8i (8.1.5) and are not 
  available in the earlier releases of the RDBMS.

  For more information on Autonomous Transactions, refer to Oracle10g "Application 
  Developer's Guide - Fundamentals" and "PL/SQL User's Guide and Reference".


Stored Procedures
-----------------
For overloaded PL/SQL stored procedures and functions, the PROCEDURE_PARAMETERS 
Schema Rowset returns the parameter information for only the first overloaded 
stored procedure/function. This is because the OLE DB specification currently 
does not have any provision for overloaded procedures/functions.


Case Sensibility
----------------
OraOLEDB currently expects the case of the objects specified in the Schema 
Rowset Restriction to be exactly the same as in the database. That is, it 
does not support passing "emp" to access the table "EMP".

  For example:

  Dim restrictions As Variant
  ...
  ' Schemarowset contains table EMP owned by SCOTT
  restrictions = Array(Empty, "SCOTT", "EMP", Empty)
  Set objRst = objCon.OpenSchema(adSchemaTables, restrictions)
  ...
  ' Schemarowset created with no rows
  restrictions = Array(Empty, "scott", "emp", Empty)
  Set objRst = objCon.OpenSchema(adSchemaTables, restrictions)
  ...


Microsoft Visual Basic 6.0 Notes
--------------------------------
The Microsoft ActiveX Data Objects and Microsoft ActiveX Data Objects Recordset 
libraries must be included as Project References.


Microsoft Visual C++ 6.0 Notes
------------------------------
OraOLEDB.h must be included in the relevant .cpp files in the VC++ project. 
Also, #define DBINITCONSTANTS needs to be added to one of the .cpp files 
in the project.
