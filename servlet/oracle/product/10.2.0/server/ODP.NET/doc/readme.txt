========================================
Oracle Data Provider for .NET 10.2.0.1.0
========================================

Copyright (C) Oracle Corporation 2005

This document provides information that supplements the Oracle Data Provider 
for .NET (ODP.NET) documentation. 


=======================
DOCUMENTATION ADDENDUMS
=======================

1. Connection Pool Management Methods (New Feature)

   Two new connection pool management methods have been introduced in ODP.NET 
   10.2.0.1.0.  ODP.NET applications can explicitly clear connections in a 
   connection pool through the ClearPool() or ClearAllPools() static method 
   on the OracleConnection object.

   ClearPool Method
   ----------------

	Description
	-----------
	This method clears the connection pool that is associated with the 
	provided OracleConnection object.
 
	Declaration
	-----------
	// C#
	public static void ClearPool(OracleConnection connection);

	Remarks
	-------
	When this method is invoked, all idle connections are closed and freed 
        from the pool.  Currently active connections remain usable and will be 
        placed back into the pool when the user invokes Close() on the 
        OracleConnection object.

	The connection pool is usable once this method is invoked. Therefore, 
        connection requests succeed even after the invocation of this method. 
        Connections created after this method invocation are not cleared unless 
        another invocation is made.

	This method can be invoked with an OracleConnection object before 
        opening the connection as well as after, provided the ConnectionString
	is properly set.

	This method cannot be invoked for an OracleConnection with 
        "context connection=true".

	Exceptions
	----------
	InvalidOperationException - Either the connection pool cannot be found 
	or the provided connection string is invalid.

   ClearAllPools Method
   --------------------

	Description
	-----------
	This method clears all the connections from all the conection pools in 
	the application domain.

	Declaration
	-----------
	// C#
	public static void ClearAllPools();

	Remarks
	-------
	This call is analogous to calling ClearPool for all the connection 
	pools that are created for the application.

	This method cannot be invoked for an OracleConnection with 
        "context connection=true".

	Exceptions
	----------
	InvalidOperationException - No connection pool could be found for the 
	application.

2. Metadata Caching: "metadata pool" connection string attribute (New Feature)

   The new "metadata pool" connection string attribute accepts "true" or 
   "false".  By default, this attribute is set to "true".  In this case, the 
   metadata information for executed queries are cached for performance.  If
   it's set to "false", the metadata information is not cached.  Setting this 
   attribute to "false" will be useful if tables in the database get re-created
   periodically with different columns.

3. Dynamic Distributed Transaction Enlistment: "enlist=dynamic" (New Feature)

   For those applications that dynamically enlist in distributed transactions 
   through the EnlistDistributedTransaction() method of the OracleConnection 
   object, the "enlist" attribute must now be set to a value of "dynamic".  
   Having "enlist=false" in the connection string will no longer allow 
   applications to enlist in distributed transactions through the 
   EnlistDistributedTransaction() method.

   If the application cannot be rebuilt with changes mentioned above, a 
   registry string value name of DynamicEnlistment of type REG_SZ can be 
   created under HKEY_LOCAL_MACHINE\SOFTWARE\ORACLE\KEY_<HOMENAME>\ODP.NET
   where <HOMENAME> is the appropriate Oracle Home where ODP.NET is installed.
   If ODP.NET was properly installed, there should already be value names such
   as StatementCacheSize, TraceFileName, etc. under the same ODP.NET key.

   If DynamicEnlistment registry key is set to 0 (or if the registry entry does 
   not exit), it will not affect the application in any way.  However, if 
   DynamicEnlistment is set to 1, "enlist=false" will be treated the same as 
   "enlist=dynamic", enabling applications to enlist successfully through 
   EnlistDistributedTransaction() without any code change.  Having 
   DynamicEnlistment set to 1 does not affect OracleConnections that have 
   "enlist=true" or "endlist=dynamic" in the connection string.

4. "HA Events" Connection String Attribute Used with Non-RAC Databases

   If "HA Events" connection string attribute is set to true and the connection
   is established to a non-RAC database, the "HA Events" setting is ignored and
   no error will be returned.  "HA Events" can only be used with RAC 
   databases.

5. "Load Balancing" Connection String Attribute Used with Non-RAC Databases

   Setting "Load Balancing=true" for a connection that attempts to connect to a 
   non-RAC database will cause an OracleException to be thrown with an error of 
   "ORA-1031: insufficient privileges."  "Load Balancing" can only be used with
   RAC databases.

6. Database Change Notification Returning ROWIDs

   In Oracle SQL, the ROWIDTOCHAR(ROWID) and ROWIDTONCHAR(ROWID) functions
   convert a ROWID value to VARCHAR2 and NVARCHAR datatypes, respectively.  
   If these functions are used within a SQL call, ROWIDs will not be returned 
   within the OracleNotificationEventArgs object that's passed to the database 
   change notification callback.

7. DBLinks with Context Connection

   DBLinks are not supported with a context connection.

8. VS.NET Help Integration 

   The reference sections of ODP.NET documentation has been integrated with 
   VS.NET IDE help system. This integration will allow developers to search and
   view information regarding ODP.NET classes and structures from within the 
   VS.NET IDE.

9. This product is not certified against Microsoft .NET Framework 2.0.


=========================
DOCUMENTATION CORRECTIONS
=========================

1. LOB Accessors when OracleCommand.InitialLOBFetchSize = -1

   Prior to Oracle Database 10g Release 2, if the InitialLOBFetchSize is set to 
   a nonzero value, GetOracleBlob and GetOracleClob methods were disabled. 
   BLOB and CLOB data was fetched by using GetBytes and GetChars methods, 
   respectively.  

   In Oracle Database 10g Release 2 and ODP.NET 10.2.0.1.0, this restriction no 
   longer exists. GetOracleBlob and GetOracleClob methods can be used for any 
   InitialLOBFetchSize value zero or greater.

2. "Statement cache size" with Context Connection

   The "statement cache size" string attribute is the only connection string
   attribute that can be set along with "Context Connection=true".

3. XML Date and Timestamp Formats

   Starting with 10g Release 2, the date and timestamp formats in generated XML 
   will not be based on database settings.  They will now be based on the 
   standard XML Schema formats.  For the XML Schema specification of XML date 
   and timestamp formats, see 
   http://www.w3.org/TR/2004/REC-xmlschema-2-20041028/datatypes.html#isoformats 
   For more information on date and timestamp formats in generated XML, read 
   Oracle XML DB Developer's Guide.


==================================
TIPS, LIMITATIONS AND KNOWN ISSUES
==================================

1.  OracleDbType.Single parameter type supports six precisions.

2.  Use /*+ ... */ as the optimizer hint syntax. Hint syntax, --+ ... is not 
    supported.

3.  Data truncation errors can be encountered when fetching LONG data from a 
    UTF8 database. [bug #2573580].

4.  To minimize the number of open server cursors, explicitly dispose 
    OracleCommand, OracleRefCursor, and OracleDataReader objects.
     
5.  When using SQL with "FOR UPDATE" or a "RETURNING" clause, use explicit 
    transactions. This is not required, if using global transactions.

6.  For distributed transactions, ODP.NET does not support proxy 
    authentication without a client password because of an OraMTS limitation.

7.  OS Authenticated connections are not pooled by ODP.NET, even if pooling
    is enabled.

8.  Thread.Abort() should not be used, as unmanaged resources may remain
    unreleased properly, which can potentially cause memory leaks and hangs.

9.  Data truncation errors can be encountered when fetching LONG data from a 
    UTF8 database. 
    [bug 2573580].

10. PL/SQL LONG, LONG RAW, RAW, VARCHAR data types cannot be bound with more 
    than 32512 bytes.
    [bug 3772804, 3639234]

11. Having a command execution terminated through either the invocation of 
    OracleCommand's Cancel method or expiration of OracleCommand's 
    CommandTimeout property value may return ORA-00936 or ORA-00604, rather 
    than the expected ORA-01013.
    [bug 3715959]

12. Statement Caching is not currently supported in an environment where 
    failover is enabled.
    [bug 3395423]

13. XML Save functionality is not supported in this release.